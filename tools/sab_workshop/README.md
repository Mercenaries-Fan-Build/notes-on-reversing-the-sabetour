# sab_workshop

A native **wgpu + egui** viewer for *The Saboteur* characters. It loads a merged skinned
mesh + skeleton, lists every animation clip in a searchable panel, decodes the selected clip
on demand from `Animations.pack`, and plays it back with **real-time GPU skinning** under an
orbit camera.

![pipeline: load → decode-on-select → skin → render]

## Run

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
  --mesh  c:/Users/Shadow/Desktop/notes-on-reversing-the-sabetour/output/skeletons/sean_full.smsh \
  --skel  c:/Users/Shadow/Desktop/notes-on-reversing-the-sabetour/output/skeletons/CH_AL_SeanDevlin.skel \
  --index c:/Users/Shadow/Desktop/notes-on-reversing-the-sabetour/output/anim_bone_map.json \
  --pack  "C:/GOG Games/The Saboteur/Animations.pack"
```

Other flags:

- `--help` — usage + controls.
- `--selftest [N]` — **headless** verification (no window): loads the assets, decodes the
  N-th playable clip, runs skinning over several frames, and prints sanity stats. Useful on a
  machine with no display / no GPU surface.

## Controls

| Input            | Action                          |
|------------------|---------------------------------|
| LMB drag         | orbit (rotate)                  |
| MMB drag         | pan                             |
| mouse wheel      | zoom                            |
| Space            | play / pause                    |
| Esc              | quit                            |
| Left panel       | search box + click a clip to play |
| Bottom panel     | play/pause, loop, speed, time scrubber, grid toggle |

## What it does

1. **Load** the SMSH skinned mesh (positions / normals / UVs / `JOINTS_0` u16×4 /
   `WEIGHTS_0` f32×4 / indices) and the `.skel` skeleton (bind-pose local TRS + row-major
   inverse-bind per bone).
2. **List** every clip from `anim_bone_map.json`. By default only clips authored on this rig
   are shown (`bone_repr == "index"` && `subset_of_skeleton == true`, ~2155 of 2214); tick
   *show all* to include the rest. The list is searchable by name.
3. **Play** the selected clip: on click, the packfile is re-parsed and the clip's
   `hkaSplineCompressedAnimation` (the N-th spline anim in file order, where N is the clip's
   `index`) is decoded into a self-contained `SplineAnim`. Each frame it is sampled at the
   current time to per-track local transforms.
4. **Skin** on the GPU: the CPU composes `world[i] = world[parent] * local[i]` and uploads
   `jointMatrix[i] = world[i] * inv_bind[i]` (191 mat4) to a storage buffer; the vertex shader
   does `skinnedPos = Σ weightₖ · jointMatrix[jointₖ] · pos`.
5. **Render** untextured flat/lambert shading with a ground grid, under an orbit camera.

## Architecture

```
main.rs        CLI / config (default paths), --selftest, --help
app.rs         winit event loop; owns all state; load → decode-on-select → skin → render;
               egui panels (searchable clip list, playback controls); mouse camera control
render.rs      wgpu 0.20: surface/device, depth, skinned-mesh pipeline (WGSL skinning in the
               vertex shader), grid pipeline, camera uniform + joint storage buffer
skinning.rs    pose composition: bind/anim locals → world matrices → jointMatrix = world·inv_bind
camera.rs      orbit camera (yaw/pitch/distance, look_at_rh + perspective_rh)
gui.rs         hand-rolled winit-0.29 → egui-0.28 event bridge + egui-wgpu paint
havok.rs       COPIED from tools/sab_havok65: AP0L + Havok 6.5 packfile parse, spline decoder
               (Packfile, parse_ap0l, read_spline_anim, SplineAnim::sample_at → QsTransform)
formats.rs     COPIED from tools/sab_havok65: read_smsh, read_skel, Bone, Smsh
anim_index.rs  parse anim_bone_map.json → per-clip name / duration / track→bone map / playable
```

Data is right-handed, +Y up, metres (Havok/glTF) — the camera matches (`look_at_rh` +
`perspective_rh`).

### Known gaps / shortcuts

- **Untextured.** Flat two-sided lambert shading only (as specified). UVs are read but unused.
- The clip list re-parses the Havok packfile on each *selection* (cheap; it only resolves the
  object's `hkArray`s). Per-frame sampling does not re-parse.
- The Havok decoder's multi-block path and non-THREECOMP40 rotation quantizations are present
  but untested — the Saboteur corpus is uniform single-block THREECOMP40 (see `havok.rs`).
- No animation blending / no playback of multiple clips at once.

## Provenance

The format code in `havok.rs` and `formats.rs` is copied verbatim (CLI/diagnostics stripped)
from `tools/sab_havok65` — the validated decoder + readers. The egui↔winit bridge in `gui.rs`
mirrors the Mercs2 workshop's hand-rolled bridge (egui-winit 0.28 pins winit 0.30, which
conflicts with winit 0.29).
