# Porting Mattias (Mercenaries 2) into The Saboteur as Sean — staged plan

**Goal:** replace the player character Sean Devlin with Mattias Nilsson, ported from the Mercenaries 2
work in the sibling repo. This is a **multi-stage project**, not a one-shot. This doc scopes every stage
with its inputs/outputs, effort, risk, and a concrete verification gate, so the scope can be chosen before
any code is written.

> **⚠️ Status (2026-07-24): this is no longer a pre-implementation plan.** The line that used to sit
> here — *"Nothing here is built yet except Stage 0"* — contradicted the rest of the document:
> **Stages 1–4 are each marked ✅ DONE below, and Stage 5 records "Deployed (`sab_poc deploy`)"**. All
> six `sab_poc` subcommands the doc invokes exist (`mesh-import`, `retarget`, `tex-import`, `mattias`,
> `deploy`, `gltf-info`) and `output/mattias_port/` holds the built artifacts.
>
> **It is deployed with a known defect, not finished.** Per `memory/mattias-parts-all-in-HD-stub-bug`,
> the port baked the whole body (24,893 verts) into `_HD` and left `_LB`/`_UB`/`_GR`/`_HAT` as 3-vert
> stubs. Because the combined-LOD/cutscene path renders **per part**, the character is invisible in
> cutscenes. Sean's real split is `_HD` 168 / `_UB` 182 / `_LB` 182 / `_GR` 191 / `_HAT` 105 bones
> (plus `_FM` face and `_FX`). The fix is to port the part-splitting — see the "part-splitting trap"
> section of [`tools/workflows/port-a-character.md`](tools/workflows/port-a-character.md), which
> documents it properly. Read Stage 5 below as *open*, not delivered.

> **Three meanings of "replace Sean with Mattias" — pick the target.**
> 1. **Cosmetic reskin** — Mattias's *textures* on Sean's *geometry*. Cheap, but it's Sean's body shape.
> 2. **Static model swap** — Mattias's geometry appears, but animates wrong (still rigged to his own bones).
> 3. **Full animating swap** — Mattias moves with Sean's entire moveset. The real goal; needs the retarget.
> The stages below build toward (3); (1) and (2) are reachable checkpoints along the way.

## What we already have (the reason this is feasible)

| Asset / capability | Where | State |
|---|---|---|
| Mattias geometry, **rigged** (skin + skeleton) | `notes-on-the-released-game/output/char/mattias.glb` (29 MB) | ✅ glTF — **116 joints**, skin (JOINTS_0/WEIGHTS_0 + invBind), 97 clips. The rig source. |
| Mattias geometry+materials, **static** | ⚠️ `…/tools/wad_simulator/workshop_export/pmc_hum_mattias/` **no longer exists** (that dir now holds only `pmc_hum_jen_v3`); the surviving source is `…/tools/mercs2-skinner/templates/pmc_hum_mattias{,_v2,_v3,_v4}/` | ✅ 22,512 v / 35,344 tri / 34 mats (Kd/Bump/Ks); **no rig** — material map only |
| Mattias textures + raw blocks | `…/output/human_blocks/…mattias_v*`, DLC head | ✅ present |
| Sean's skeleton (Saboteur rig) | `output/skeletons/CH_AL_SeanDevlin.skel` | ✅ ~190 bones, named (`Bone_Hips`, `Bone_LThigh`…) |
| Sean's merged mesh + parts | `output/skeletons/CH_AL_SeanDevlin.smsh`, `parts/sean_{HD,UB,LB,GR,HAT}.smsh` | ✅ read |
| Texture write (DTEX) | `tools/sab_poc` (`repack`) | ✅ proven, self-verified |
| MESH/MSHA write | `tools/sab_poc` (`mesh-roundtrip`) | ✅ **Stage 1 done** — 6529/6529 skinned models re-serialize byte-exact |
| Bundle rebuild (ALBS) | `repack_poc` | ✅ **921/923 byte-exact** null round-trip |
| Patch megapack writer (w/ 2nd table) | `repack_poc` | ✅ proven |
| MESH / MSHA format | [`formats/archive_and_models.md`](formats/archive_and_models.md) + `sab_workshop/src/meshload.rs` | ✅ documented, **read-only** |
| Skinned-mesh + animation viewer | `tools/sab_workshop` | ✅ **the test harness** — renders SMSH+skel, plays clips |

The viewer is the key de-risker: **every stage can be validated in the viewer before the game is ever
touched.** A retarget that looks right playing a Sean clip in the viewer is most of the battle.

## The two genuine gaps

- **No mesh writer.** We can write DTEX textures byte-right, but not MESH/MSHA/`.dat`. Tractable — same
  shape of work as the texture writer, provable the same way (Stage 1).
- **Skeleton retargeting.** Mattias's glb is rigged to the *Mercs 2* skeleton; Sean's animations are keyed
  to the *Saboteur* skeleton. Re-skinning Mattias onto Sean's ~190 bones is the hard, uncertain part
  (Stage 3). Both are Pandemic humanoid bipeds, so correspondence is *plausible*, not guaranteed.

## Stage 0 — Foundations ✅ DONE

Texture DTEX encode, ALBS bundle rebuild, patch-megapack writer (incl. the second `(crc,index)` table),
global.map read + bundle↔megapack link. All in `tools/sab_poc` (`repack` command) and byte-verified.
**global.map is NOT rewritten** — replacement overrides by `assetIndex`, so all later stages inherit a
no-global.map-edit path. See [`../tools/sab_poc/README.md`](../tools/sab_poc/README.md).

## Stage 1 — MESH/MSHA writer + null round-trip on Sean   ·   ✅ DONE

Built the inverse of `meshload.rs` in `tools/sab_poc` (`mesh-roundtrip` / `mesh-audit`): parse the
decompressed **MESH** body into a full section model (header + MESHSkeleton + tail streams/primitives/
drawcalls/bone-remaps), and re-serialize it by writing every known field back from parsed values — a
field-level writer, not a memcpy.

- **Verification gate — met:** the *decompressed* MESH body re-serializes **byte-exact**. `mesh-audit`
  over `Dynamic0`: **6529/6529 skinned models byte-exact, 0 mismatch** (278 non-skinned props skipped —
  different header path, irrelevant to the character port). Sean's own parts (HD/UB/LB/GR/HAT + disguise
  variants): 167/167 byte-exact.
- **Still open (not blocking Stage 2):** in-game confirmation that a re-emitted MSHA loads (the zlib
  container is re-compressed, so the gate is on the decompressed body, same nuance as DTEX); and wiring
  the MSHA re-wrap + bundle repackage into an installable patch (the pieces — deflate + Stage-0 ALBS
  rebuild — already exist; only the glue remains).
- **Why it was first:** every later stage writes a MESH. The writer is now proven against the whole
  skinned-model corpus, so Stage 2 (Mattias geometry → MESH) builds on a verified encoder.

## Stage 2 — Mattias geometry → Saboteur MESH   ·   ✅ DONE (geometry + skin verified)

> **2b done — the MESH encoder** (`sab_poc mesh-import`). Builds a Saboteur MESH for Mattias: the full
> 191-bone Sean skeleton **synthesized** from `CH_AL_SeanDevlin.skel` (records/`localTMS`/`transforms`
> per the decoded layout), Mattias's 29,023 verts / 106,032 indices / 34 drawcalls encoded as canonical
> vertex streams + `.dat`, bone indices hash-remapped onto Sean. **Verified:** the encoded MESH decodes
> back (via the same reader path the game uses) to Mattias's exact geometry — positions within half
> precision, indices exact, and the per-bone weight map matches with **zero wrong bone influences**. The
> geometry encoder was first proven by round-tripping Sean's own parts (HD/LB/FX/FM) through the semantic
> layer. Writes `pmc_hum_mattias.msha`. **Not yet confirmed: in-game load** (needs the game running);
> materials are placeholder hashes (Stage 4); `boneRemap.ibm` is zeroed (engine recomputes / reader
> ignores). Next: Stage 4 textures + Stage 5 packaging into Sean's bundle.

Convert Mattias geometry into a Stage-1 MESH: positions → half-float, normals, UVs, indices (triangle
lists, `faceType==1`), 4-bone skin (UNORM8 weights / UINT8 indices), material groups → primitives/drawcalls.

> **2a done — glTF ingest + bone remap** (`sab_poc gltf-info`, verified against the real files): the
> re-export `model.gltf` parses to **34 primitives, 29,023 verts, 35,344 tris, 13 materials, 116 joints**,
> bbox `Y[-0.13,1.90]` (Sean's scale — no transform needed), **0 verts with bad weight sums**. The bone
> hash-remap onto Sean's 191-bone rig reproduces in-tool: **59 direct, 57 folded-to-ancestor, 0 orphan**.
> So the source reads cleanly and every vertex has a valid Sean bone target.
>
> **2b next — the MESH geometry encoder** (semantic geometry → vertex streams + `.dat` VB/IB + primitives
> + drawcalls, remapped bone indices), reusing the Stage-1 section model.
>
> **Skeleton-authoring question — RESOLVED** (detour 2026-07-17; see
> [`formats/skeleton.md`](formats/skeleton.md)). The 64-byte bone
> record is fully decoded: `boneName1 == boneName0`, `unk0 == 0`, per-bone BBOX is an empty sentinel
> (`min 0`, `max -10000`) for every non-root bone, and `boneIds` is identity. A synthesized record matched
> **167/168** of Sean's real bytes (root differs only in BBOX). So the **entire skeleton section is
> synthesizable from `CH_AL_SeanDevlin.skel`** — no donor MESH, no unknown bytes. That was the only real
> unknown blocking 2b. Remaining 2b work is mechanical: emit `boneIds`/`localTMS`/`bones`/`transforms`/
> `parentIds` from the `.skel`, then the geometry (streams + `.dat` + prims + drawcalls) with bone indices
> hash-remapped. Prove the geometry encoder by re-encoding a Sean part and decoding it back before feeding
> Mattias in.

- **Scale is confirmed no-op:** the OBJ export and Sean's skeleton share units/up-axis (Mattias verts
  y≈1.05; Sean `Bone_Root` y=1.065). One less transform to get wrong.
- **Rig source = the glb (resolved).** The OBJ is geometry+materials only, so the 4-bone skin the MESH
  format needs comes from **`mattias.glb`** (confirmed: 116 joints, `JOINTS_0`/`WEIGHTS_0`, inverse-bind
  matrices). The OBJ's `model.mtl` is still used — as the clean material→texture map (34 materials, each
  Kd/Bump/Ks → diffuse/normal/spec). So: **geometry+skin from the glb, material→texture map from the OBJ.**
  A static-only swap could run from the OBJ alone, but the animating port reads the glb.
- **Verification gate:** load the result in the viewer against **Mattias's own** skeleton (from the rigged
  source) — it renders in his bind pose. Confirms the geometry+skin encode independently of retargeting.
- **Risk drivers:** UV/normal conventions; vertex-format code selection; stream/primitive count; matching
  the OBJ's 34 material groups to drawcall material references.

## Stage 3 — Skeleton retarget onto Sean's rig   ·   ✅ headless gate passed (visual gate = user)

> **Done: the retarget is applied and headlessly validated** (`sab_poc retarget`). The hash-remap is
> baked into the mesh in Stage 2b (vertex bone indices point at Sean's bones). Stage 3 adds the
> **spatial-coherence check** — the distance from each vertex to its dominant bone's bind-pose rest
> position, which catches a mis-mapped bone (a hand vertex bound to a foot bone would be ~1 m away):
> **median 0.13 m, p95 0.26 m, max 0.48 m; 99.5% of vertices within 0.40 m of their bound bone.** That
> is exactly a limb-radius envelope — the remap connected geometry to the right bones. It also exports
> `pmc_hum_mattias.smsh` for the workshop viewer. **The visual gate remains the user's:** open it with
> `sab_workshop --mesh pmc_hum_mattias.smsh` — which rigs it on Sean's skeleton straight from the
> install, so no `.skel` file is involved — and eyeball idle/walk/aim. The
> headless coherence is a pre-check, not a substitute for watching the animated deformation.

Re-skin Mattias onto Sean's skeleton so Saboteur animation clips drive him. **The correspondence is a
`pandemic_hash` bone-identity join** — both characters share the Pandemic skeleton, so each bone's
name-hash is stable across them (verified: Sean's named bones hash to the same values as Mattias's joint
suffixes). Measured against the real assets (`model.gltf` skin ↔ `CH_AL_SeanDevlin.skel`):

| Mattias joints (116) | → Sean | Handling |
|---|---|---|
| **59** core | direct hash match | 1:1 index remap — includes every animated bone: `Root`, `Hips`, `L/R Thigh+Shin`, `Spine1`, `Chest`, `Neck`, `Head` |
| **57** detail | no direct match, but **all 57 have a hash-matched ancestor** (47 leaves, 10 short chains) | fold each to its nearest matched ancestor — deterministic and reported per bone |
| **0** | no valid target | — nothing to pin arbitrarily |

- So the retarget is: hash-join the 59, fold the 57 up their own hierarchy, remap every vertex's bone
  indices, keep weights. Bind-pose/scale already align (Stage 2 finding). No manual bone map needed.
- **Fidelity limit, stated plainly (not a bug):** the 10 folded chains are articulation Sean's rig can't
  drive (Mattias fingers/face detail) — those regions move with their parent bone. The tool **lists every
  folded bone** so this is a visible, chosen loss, never a silent one.
- **Verification gate:** in the viewer, load Mattias's mesh bound to `CH_AL_SeanDevlin.skel` and play
  several Sean clips (idle, walk, aim); judge deformation by eye. Validated entirely in the viewer — no
  game build needed. **No silent fallbacks:** any vertex that can't be assigned a real Sean bone is an
  error the tool reports, not a pin-and-pretend.

## Stage 4 — Mattias textures → DTEX   ·   ✅ DONE (encode verified)

`sab_poc tex-import`: decodes the exported PNGs, BC-compresses (real BC1 + BC3-alpha encoders), builds
mipped DTEX records keyed by each texture's original hash, and **verifies by decoding each back** — all
**24/24 textures round-trip within BC tolerance (worst mean RGB error 2.3/255)**. Roles come from the
glTF material names (`mat_d0x…_n0x…_s0x…`): diffuse→BC1/BC3, normal→BC1, spec→BC1. Writes `*.dtex`.

- **Material→texture binding — SOLVED and wired.** WSAO is *present* on PC as the loose `France.materials`
  (the "absent" belief was a scanning miss; memory `wsao-material-format-and-gap` corrected). Binding:
  `drawcall.material` → WSMA record → `WSTX[textureBegin..+n]` slice → DTEX by `pandemic_hash`. The
  `sab_poc mattias` command does the whole port in one shot — mesh + DTEX + patched `France.materials`
  (cloning a working character material's shader, retargeting identity + texture slice) — and self-verifies
  the SMSH→WSAO→DTEX chain. The workshop viewer now resolves textures the engine's way (`--wsao`/`--dtexdir`)
  and binds **34/34 of Mattias's submeshes** (runtime-confirmed). Remaining: in-game deployment — package
  MESH+DTEX into a bundle and install the patched `France.materials` (user-tested).

## Stage 5 — Package into Sean's slot + install   ·   effort **M** · risk **Med**

Put the new MESH (MSHA) + DTEX into Sean's bundle(s), rebuild via Stage 0, emit `patchdynamic0.megapack`,
install. **Complication:** Sean is a **merged multi-part** character (HD/UB/LB/GR/HAT), each part a
mesh/bundle; Mattias is one model. Decide whether to map Mattias onto Sean's part structure or replace the
merged whole and neutralize the extra parts.

- **Verification gate:** in-game — Mattias walks Paris with Sean's moveset. The end goal.

> **Deployed (`sab_poc deploy`).** Overrides the player bundle **`FBS_RS_Sean`** (assetIndex 2016137252,
> 8 mesh + 29 tex — a clean 1:1 count match, no global.map edit) via an additive
> `Global/patchdynamic0.megapack`: all mesh slots = Mattias's MSHA, all tex slots = his DTEX keyed by
> hash; phys kept. Plus the patched `France.materials` (backed up to `.bak`). Reversible: delete the patch
> megapack, restore the `.bak`. **In-game confirmation is the user's** (I can't launch the game). Known
> risks stacked here, untested in-game: MSHA load, the WSAO edit, 8× mesh overdraw (all slots = Mattias),
> and whether `FBS_RS_Sean` is the sole player bundle (disguise/cutscene Sean live in other bundles).

## Recommended sequencing & decision points

```
Stage 0 ✅ ── Stage 1 (mesh writer, prove on Sean) ── Stage 2 (Mattias geometry in)
                        │                                     │
                        │                              Stage 3 (retarget) ⚠ GO/NO-GO
                        │                                     │
                        └───────────── Stage 4 (textures) ────┴── Stage 5 (package, in-game)
```

- **Stage 1 is the correct first brick** and is low-drama: it either round-trips Sean byte-exact or it
  doesn't, and it unblocks everything.
- **Stage 3's correspondence is already solved** (hash join, 0 orphans), so it's no longer a project-risk
  unknown — it's a deformation-quality check in the viewer. Do it right after Stage 2. Worst realistic
  case is finger/face detail that moves with its parent, which is a fidelity note, not a project stopper.
- Cheapest *visible* result at any time: Stage 4 alone on Sean's existing mesh = the **cosmetic reskin**
  (Mattias's skin on Sean's body). Not the goal, but a quick morale checkpoint.

## Open questions / unknowns to resolve as we go

**Still open:**

- Sean's merged-parts structure vs Mattias's single mesh (Stage 5) — **now the blocking defect**, not
  merely unclear: see the status banner at the top. Sean's split is known
  (`_HD`/`_UB`/`_LB`/`_GR`/`_HAT` = 168/182/182/191/105 bones); what is missing is the port emitting it.
- Face/hands/accessories fidelity (fingers, facial rig) under retarget.

**✅ Resolved — these were answered elsewhere in this same document:**

- ~~Exact scale/coordinate transform Mercs 2 → Saboteur (Stage 2/3).~~ Answered in Stage 2: **scale is
  a confirmed no-op**.
- ~~Whether Mattias's Mercs 2 bone names survive … or whether the map is mostly manual (Stage 3).~~
  Answered in Stage 3: **59 direct / 57 folded to ancestors / 0 orphans**.
- ~~Material/drawcall hashes … **PC has no WSAO**, so textures resolve by DTEX name-hash.~~ ❌ **The
  premise was wrong.** WSAO **is** present on PC, as the loose `France.materials` (4,288,448 bytes) —
  this document already says so at Stage 4 ("the 'absent' belief was a scanning miss"), and
  `memory/wsao-material-format-and-gap` records the correction. The real chain is
  `drawcall.material → WSMA record → WSTX texture-hash slice → DTEX by pandemic_hash`.

## Provenance & cross-repo note

Mattias assets and Mercs 2 tooling live in the sibling repo (`notes-on-the-released-game`), which is a
**different engine (Mercs 2, Havok 5.5)** — per [`../AGENTS.md`](../AGENTS.md), bring over *geometry and
methodology*, never Mercs 2 format offsets. The Saboteur MESH/MSHA/DTEX encoders are derived from the
Saboteur binary and this repo's format docs, not from Mercs 2 code.
