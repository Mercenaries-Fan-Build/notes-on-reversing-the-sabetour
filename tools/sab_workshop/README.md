# sab_workshop

A native **wgpu + egui** modding workshop for *The Saboteur*. It has two halves:

- **Inspect** (page 1) — the character/animation viewer: a merged skinned mesh + skeleton, textures
  resolved straight out of the megapack, every clip searchable, decoded on demand from
  `Animations.pack` and played back **textured** with real-time GPU skinning under an orbit camera.
- **Templates · GameText · Icons** (pages 2–4) — the mod editor, built on the byte-verified
  `sab_formats` codecs. See [The mod-editor pages](#the-mod-editor-pages) below.

## The mod-editor pages

Pages 2–4 replace the old Textures/Materials/Rig tabs with a data editor over the game's own files:

- **Templates** — load a `GameTemplates.wsd` (AULB), search templates by name/type, and edit any
  property pair. A 4-byte value shows as int / float / hash; known property names (`Name`, `Model`,
  `Texture`, …) are resolved. Set a value as an int, float, raw hash, or **texture name** (which is
  hashed with `pandemic_hash` — that is exactly how a template references a texture). Save writes the
  file byte-faithfully.
- **GameText** — load a `Cinematics/Dialog/<Lang>/GameText.dlg`, browse/search all UI strings and VO
  subtitles, edit any string (any length), and **add a brand-new UI id** (keyed by
  `pandemic_hash("File_Text.Key")` — no Lua registration needed). Save re-emits the container and
  rebases its trailing `DNEC` section automatically.
- **Icons** — scan a megapack for its DTEX texture names and their `pandemic_hash`, and hash any name
  you plan to pack, so you can wire a custom icon into a template's texture value. (Packing the DTEX
  itself is done with `sab_dtex` / `sab_pack`; the format chain is documented in
  `../../docs/formats/gametext.md` and `../../docs/formats/gametemplates.md`.)

The original character/animation viewer is unchanged and is page 1.

![pipeline: load → resolve textures → decode-on-select → skin → render]

## Run

> **Use `--release`.** A debug build is far too slow for the 715 MB megapack sweep + BC decode
> (minutes vs ~1.4 s).

From the repo root (or anywhere — the default input paths are absolute):

```
cargo run -p sab_workshop --release
```

If you are not in a Cargo workspace that includes this crate, run it from the crate directory:

```
cd tools/sab_workshop
cargo run --release
```

Override any input path (all default to the generated Sean assets):

```
cargo run --release -- \
  --mesh     c:/Users/Shadow/Desktop/notes-on-reversing-the-sabetour/output/skeletons/sean_full.smsh \
  --skel     c:/Users/Shadow/Desktop/notes-on-reversing-the-sabetour/output/skeletons/CH_AL_SeanDevlin.skel \
  --index    c:/Users/Shadow/Desktop/notes-on-reversing-the-sabetour/output/anim_bone_map.json \
  --pack     "C:/GOG Games/The Saboteur/Animations.pack" \
  --megapack "C:/GOG Games/The Saboteur/Global/Dynamic0.megapack" \
  --char     SeanDevlinn
```

- `--megapack <path>` — the megapack holding the character's DTEX bundles (textures).
- `--char <token>` — case-insensitive token selecting which bundles are this character's.

Other flags:

- `--help` — usage + controls.
- `--selftest [N]` — **headless** verification (no window): loads the assets, decodes the
  N-th playable clip, runs skinning over several frames, resolves textures + prints the
  per-submesh assignment, and prints sanity stats. Useful on a machine with no display / GPU.

## Controls

| Input            | Action                          |
|------------------|---------------------------------|
| LMB drag         | orbit (rotate)                  |
| MMB drag         | pan                             |
| mouse wheel      | zoom                            |
| Space            | play / pause                    |
| Esc              | quit                            |
| Navigator (left) | search box + click a clip to play |
| Inspector (right)| Character stats · **Materials** (per-submesh texture picker) · Clip details |
| Transport (bottom)| play/pause, loop, speed, time scrubber, grid + textures toggles |

## What it does

1. **Load** the SMSH skinned mesh (positions / normals / UVs / `JOINTS_0` u16×4 /
   `WEIGHTS_0` f32×4 / indices / **prims**) and the `.skel` skeleton (bind-pose local TRS +
   row-major inverse-bind per bone).
2. **Cover** the index buffer with a non-overlapping per-material draw list. `sab_mesh` emits one
   prim per *drawcall*, so ranges overlap (a coarse "whole" primitive plus its split children, and
   several materials/passes on one range). `formats::submesh_cover` keeps only **leaf** ranges and
   collapses duplicates — for Sean that's 34 prims → **14 submeshes** tiling all 114,402 indices.
3. **Resolve textures** in-process from the megapack: find the bundles carrying the character token,
   walk their DTEX records (names are plaintext), classify each by suffix (`_D` diffuse, `_N`/`_NM`
   normal, `_S` spec, `_WM`/`_MASK` mask), and **auto-seed** each submesh's diffuse by body part
   (HD→head, UB→jacket, LB→pants, GR→hand, HAT→hat). Decoding is lazy — only bound textures are
   BC-decoded. A saved sidecar overrides the seed (see below).
4. **List** every clip from `anim_bone_map.json`. By default only clips authored on this rig
   are shown (`bone_repr == "index"` && `subset_of_skeleton == true`, ~2155 of 2214); tick
   *show all* to include the rest. The list is searchable by name.
5. **Play** the selected clip: on click, the packfile is re-parsed and the clip's
   `hkaSplineCompressedAnimation` (the N-th spline anim in file order, where N is the clip's
   `index`) is decoded into a self-contained `SplineAnim`. Each frame it is sampled at the
   current time to per-track local transforms.
6. **Skin** on the GPU: the CPU composes `world[i] = world[parent] * local[i]` and uploads
   `jointMatrix[i] = world[i] * inv_bind[i]` (191 mat4) to a storage buffer; the vertex shader
   does `skinnedPos = Σ weightₖ · jointMatrix[jointₖ] · pos`.
7. **Render** one draw per submesh, each binding its own diffuse (1×1 white when unassigned),
   modulated by two-sided lambert, with a ground grid, under an orbit camera.

## Materials: why a picker, not a lookup

A prim carries a `materialHash` — a `pandemic_hash` of a name in the **WSAO** material library, which
is what would name each material's textures. **WSAO is not present in the retail PC install** (an
exhaustive raw + brute-zlib scan of all 42 archives finds no container, and none of Sean's material
hashes appear anywhere); the corpus appears to be Xbox-360-only, and that build is big-endian, so
using it means an endian-converting pipeline over pre-release data. See the memory note
`wsao-material-format-and-gap`.

So the submesh→texture *identity* WSAO would give is supplied instead by:

- an **auto-seed** by body part (a heuristic — it will be wrong wherever one part uses several
  textures, e.g. the head's eyes/mouth all seed to `Head_D`), and
- the **Materials picker** in the inspector: reassign any submesh to any texture in the character's
  bundles (accessories like `CH_AC_Eyes_*` / `CH_AC_Mouth` are included), persisted to
  `<mesh>.materials.json` next to the mesh. The sidecar wins over the auto-seed on the next run.

## Architecture

```
main.rs        CLI / config (default paths, --megapack/--char), --selftest, --help
app.rs         winit event loop; owns all state; load → resolve textures → decode-on-select →
               skin → render; the egui shell (command bar, navigator, inspector, status,
               transport); the Materials picker + sidecar persistence; mouse camera control
render.rs      wgpu 0.20: surface/device, depth, skinned-mesh pipeline (WGSL skinning in the
               vertex shader, diffuse sampled over UV), per-submesh texture bind groups + white
               fallback, grid pipeline, camera uniform + joint storage buffer
skinning.rs    pose composition: bind/anim locals → world matrices → jointMatrix = world·inv_bind
camera.rs      orbit camera (yaw/pitch/distance, look_at_rh + perspective_rh)
gui.rs         hand-rolled winit-0.29 → egui-0.28 event bridge (+ OS clipboard & cursor delivery)
               + egui-wgpu paint; `theme` — the shared visual system (palette, fonts, widgets)
havok.rs       COPIED from tools/sab_havok65: AP0L + Havok 6.5 packfile parse, spline decoder
               (Packfile, parse_ap0l, read_spline_anim, SplineAnim::sample_at → QsTransform)
formats.rs     COPIED from tools/sab_havok65: read_smsh, read_skel, Bone, Smsh; + the prims block
               (Prim) and `submesh_cover` (the non-overlapping per-material draw list)
dtex.rs        COPIED from tools/sab_dtex (parse/payload/mips/find_records) + BC1/BC2/BC3 and
               uncompressed decoders (BC1/BC3 from the Mercs2 workshop's texpng) → CpuTexture
editor.rs      the mod-editor pages (Templates / GameText / Icons) over the sab_formats codecs;
               each is a self-contained CentralPanel with a path field, Load/Save, and edit forms
pack.rs        COPIED from tools/sab_pack: megapack index reader + pandemic_hash
resolve.rs     character texture resolution: bundle sweep → DTEX records → role classify →
               body-part auto-seed → `<mesh>.materials.json` sidecar load/save
anim_index.rs  parse anim_bone_map.json → per-clip name / duration / track→bone map / playable
```

Data is right-handed, +Y up, metres (Havok/glTF) — the camera matches (`look_at_rh` +
`perspective_rh`).

### Known gaps / shortcuts

- **Materials are heuristic, not resolved** — see *Materials: why a picker* above. WSAO is absent
  from the PC build, so wrong slots are fixed by hand in the inspector.
- **Diffuse only.** The resolved `_N`/`_S`/`_WM` maps are listed and pickable but not yet used by
  the shader (no normal/spec lighting); textures are uploaded as `Rgba8Unorm` (no sRGB decode), to
  stay consistent with the flat/grid passes.
- **Startup is non-blocking and progressive.** The megapacks are **memory-mapped** (`open` is instant —
  no 715 MB read, only touched pages fault in), and the heavy work runs on a **worker thread**
  (`background_load`) that **streams results in stages** (`BgMsg`): clip list → model list → character
  textures → megapacks (click-to-load) → `Animations.pack` (playback). The window is interactive at once
  and each section fills in as it lands.
- **The model list is near-instant.** `list_meshes` walks the **MSHA chain** — the mesh headers in a
  bundle are contiguous (`next = pos + 276 + compSize0 + compSize1`), so it reads only the 276-byte
  headers (~2 MB for all 6807 meshes) and skips every compressed blob. Verified bit-for-bit against the
  old full-file scan (6807 == 6807 across 759 bundles).
- **The character texture scan won't freeze the UI.** Finding the boot character's textures needs a
  full-content token scan (the name lives deep in its bundle), so it can't be windowed — but it now
  reads each sub-pack via a **buffered, reused-buffer file read** (`Megapack::read_into`) instead of
  mmap-faulting all 714 MB into the working set, and **yields** periodically. It runs as the last
  background stage. **Clicking a model** in the browser is the same: the mesh loads and shows instantly
  (untextured), and its texture resolve — which for a character is that same whole-pack token scan —
  runs on a worker (`resolve_model_textures`) and streams in, so a click never blocks the UI. Debug
  builds are far slower at BC decode — use `--release`.

## The model browser (assembled assets, from the game's own data)

The Inspect navigator lists **assembled assets**, not raw mesh parts — and the grouping is the game's,
not a heuristic. `src/assets.rs` reads `GameTemplates` and follows the real references:
`FxHumanBodySetup` (a character) → `FxHumanHead` + `FxHumanBodyPart` → mesh; `Weapon` / `CAR` / `Prop` /
`Ammo` reference their meshes directly. So the 6807 mesh parts fold into **979 assets** — Characters
(268), Props (225), Weapons (155), Vehicles (100) — plus **Ungrouped** (231 meshes no template claims;
never hidden). Proven: `FBS_RS_Sean` → FX, FM, HD, UB, LB, HAT, GR, Hair.

- **Click an asset** → loads its primary part into the viewer and fills the right inspector's **Parts**
  panel with every part; **click a part** to load/inspect it individually.
- **Right-click an asset → Move to group** to override its category; saved to
  `sab_workshop_model_groups.json` next to the game, winning over the template default on later runs.
- The clip list re-parses the Havok packfile on each *selection* (cheap; it only resolves the
  object's `hkArray`s). Per-frame sampling does not re-parse.
- The Havok decoder's multi-block path and non-THREECOMP40 rotation quantizations are present
  but untested — the Saboteur corpus is uniform single-block THREECOMP40 (see `havok.rs`).
- No animation blending / no playback of multiple clips at once.

## Provenance

The format code in `havok.rs` and `formats.rs` is copied verbatim (CLI/diagnostics stripped)
from `tools/sab_havok65` — the validated decoder + readers; `dtex.rs` and `pack.rs` likewise from
`tools/sab_dtex` and `tools/sab_pack`. The egui↔winit bridge in `gui.rs` mirrors the Mercs2
workshop's hand-rolled bridge (egui-winit 0.28 pins winit 0.30, which conflicts with winit 0.29),
including its clipboard/cursor delivery; `gui::theme` and the command-bar / navigator / inspector /
status / transport shell are adapted from the Mercs2 workshop's rewrite (its 4-way activity rail and
Unreal-style Details vec3 scrub widgets are omitted — sab is a single character/anim view). The
BC1/BC3 block decoders come from that workshop's `texpng.rs`.
