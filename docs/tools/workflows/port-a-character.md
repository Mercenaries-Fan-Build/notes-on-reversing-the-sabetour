# Port a character

Getting a new character model into the game, animating correctly with the stock moveset. This is
the hardest thing in the toolset and the least automated — read this before starting, because most
of the cost is in mistakes that only show up in-game.

**Status:** the write path is **proven but not yet graduated**. Every step below works and is
byte-verified against retail data, but the mesh writer still lives in `sab_poc`, which is a holding
pen rather than a shipped tool — you build it from source. Textures, packing and validation use the
shipped tools.

**Read first:** [`docs/mattias_port_plan.md`](../../mattias_port_plan.md) — the staged plan, with
what is verified at each gate and what isn't.

---

## The shape of the problem

A Saboteur character is not one model. Sean is **five parts** — `_HD` (head), `_UB` (upper body),
`_LB` (lower body), `_GR` (gloves), `_HAT` — each its own MESH, each with its **own skeleton and its
own bone count** (168/182/182/191/105), and **bone index N is not the same bone across parts**. Your
source model is almost certainly one mesh with one rig.

Reconciling those two facts is the whole job. Three things follow from it:

1. Bones join **by `pandemic_hash(name)`**, never by index.
2. The extracted skeleton comes from whichever part has the most bones (the glove).
3. **You must split your model across the parts.** See [the part-splitting
   trap](#the-part-splitting-trap) — this is the single most expensive mistake in this workflow.

## 1. Read the target rig

```sh
sab_skeleton "$GAME/Global/Dynamic0.megapack" --list                          # every CH_AL_* + bone count
sab_skeleton "$GAME/Global/Dynamic0.megapack" CH_AL_SeanDevlin_01_GR sean.json  # bone tree + bind pose
sab_mesh     "$GAME/Global/Dynamic0.megapack" CH_AL_SeanDevlin_01_GR sean.smsh sean.glb
```

Load the result in [`sab_workshop`](../../../tools/sab_workshop/README.md) and play a few clips.
That is your reference for "correct", and the viewer is where every later stage gets checked
**before** the game is touched.

## 2. Retarget your rig onto it

Both Pandemic humanoid skeletons hash their bone names the same way, so the correspondence is a
**hash join, not a manual bone map**. For the Mercenaries 2 → Saboteur case, measured against real
assets: **59 of 116 joints match directly, 57 fold to a hash-matched ancestor, 0 orphans.**

Folding is a real, stated fidelity loss — folded bones (typically fingers and facial detail) move
with their parent because the target rig can't drive them. The tool lists every folded bone. A
vertex that cannot be assigned a real target bone is an **error**, never a silent pin.

```sh
cargo run --release --manifest-path tools/sab_poc/Cargo.toml -- gltf-info --gltf model.gltf --skel CH_AL_SeanDevlin.skel
cargo run --release --manifest-path tools/sab_poc/Cargo.toml -- retarget  --gltf model.gltf --skel CH_AL_SeanDevlin.skel --out port/
```

`retarget` also emits an SMSH and runs a headless spatial-coherence check — the distance from each
vertex to its dominant bone's rest position, which catches a hand bound to a foot. For Mattias:
median 0.13 m, p95 0.26 m, 99.5% within 0.40 m. **That is a pre-check, not the gate.** The gate is
loading the SMSH against the target skeleton in the workshop and watching idle/walk/aim.

> Nothing about a bad rig is visible at bind pose: `jointMatrix = world · inv_bind` is identity for
> any self-consistent-but-wrong chain, so a broken character renders perfectly until a clip plays.
> If yours looks right standing still and explodes when it moves, run
> [`sab_probe`](../../../tools/sab_probe/README.md) `parts` / `bones`.

## 3. Encode the mesh and textures

```sh
cargo run --release --manifest-path tools/sab_poc/Cargo.toml -- mesh-import --gltf model.gltf --skel CH_AL_SeanDevlin.skel --out port/
cargo run --release --manifest-path tools/sab_poc/Cargo.toml -- tex-import  --gltf model.gltf
```

Textures bind the engine's way: `drawcall.material` → WSMA record in `France.materials` (WSAO) →
`WSTX` texture-hash slice → DTEX by `pandemic_hash`. The `sab_poc mattias` command does mesh +
textures + a patched `France.materials` in one shot and self-verifies that whole chain.

**Regenerate the mesh after any change to the encoder before you deploy.** A stale MSHA is
indistinguishable from a live one on disk and has already cost one debugging cycle — the symptom was
a see-through, texture-swimming character.

## 4. Package and install

Mesh and textures go into the character's bundle, which becomes an additive
`Global/patchdynamic0.megapack` — see [replace-a-texture](replace-a-texture.md) for the packing
mechanics. The player bundle is `FBS_RS_Sean` (assetIndex 2016137252). **`global.map` is never
rewritten**; the override works by asset index.

```sh
sab_validator patchdynamic0.megapack
```

Reversible: delete the patch megapack and restore the `France.materials.bak`.

---

## The part-splitting trap

**Do not bake your whole model into one part slot.** It is the obvious shortcut and it produces a
character that is *visible in gameplay and invisible in every cutscene*.

The reason: gameplay renders the merged near-LOD, so a single fat part looks fine. The
**combined-LOD / cutscene path renders per-part**, reading the body-setup blueprint's LOD slots —
which point at `_LB`, `_UB`, `_GR`. If those are empty stubs, nothing draws.

A port that put 24,893 verts in `_HD` and 3-vert stubs in `_LB`/`_UB`/`_GR`/`_HAT` (vanilla:
10675/8456/3389/657) hit exactly this. The shipped mitigation fills the **`_LB`** slot instead of
`_HD` — the slot the combined LOD actually reads — which restores cutscene visibility for outfits
that carry `_LB`. Outfits without one still fall back to `_HD` and are still broken in cutscenes.

**The real fix is splitting your geometry across the parts the way the stock character is split.**
The mitigation buys you a working character; it doesn't make one fat part correct.

## Known invariants a hand-built MESH violates

These are authoring rules the cooker always upholds and the engine quietly assumes. Run
[`sab_validator`](../../../tools/sab_validator/README.md) — it exists largely because of this list:

- vertex/stream `usz` and pad-0 alignment
- the identity matrix at header `@148`
- a real bounding box (a zero bbox on a part is a symptom, not a cause)
- stored inverse-bind matrices — the **only** place face-bone offsets exist; the derived chain
  collapses that subtree because local translations are `(0,0,0)` on disk
- declared vs actual stream sizes
- `pos.w` carrying opacity
- LOD/coincident-triangle overlap (dedup, or you get patchy dither)
- primitive count and tangents (missing tangents = swimming textures)

## Where this is going

`sab_poc` commands graduate into proper `tools/` crates once they are in-game confirmed and general
enough. When the mesh writer graduates, this guide gets a copy-paste recipe. Until then, treat it as
a map of a route that has been walked once, not a paved road.
