# sab_havok65

Decoder and glTF exporter for **The Saboteur**'s Havok 6.5 `hkaSplineCompressedAnimation` clips —
the format the whole animation corpus (`Animations.pack`) uses. std-only Rust, no dependencies.

See [`../../docs/formats/animation_havok65.md`](../../docs/formats/animation_havok65.md) for the
byte-level format spec and how it was reverse-engineered (double-blind two-investigator + adjudicator,
resolved against a direct `Saboteur.exe` disassembly).

## Build

```
cargo build --release
```

## Usage

```
# Inspect a few clips (headers, invariants, first-frame poses)
sab_havok65 "C:\GOG Games\The Saboteur\Animations.pack"

# Inspect one clip by index
sab_havok65 "…\Animations.pack" 100

# Decode & validate ALL clips (invariant sweep)
sab_havok65 "…\Animations.pack" all
#   -> fully-clean (unit quats, exact frame count): 2214 / 2214

# Export one clip to binary glTF (.glb) — open in Blender / any glTF viewer
sab_havok65 "…\Animations.pack" gltf <index> out.glb

# Export EVERY clip to a folder (clip_0000.glb … clip_2213.glb)
sab_havok65 "…\Animations.pack" gltf-all <outdir>
#   -> exported 2214 clips -> <outdir>  (~204 MB)
```

`gltf-all` covers the **2214 clips in the main blob**. The pack also holds ~7,494 *streamed*
single-clip sub-packfiles (one anim each); enumerating those is a small follow-up (the decoder already
handles the format — only the packfile discovery differs).

## What the glTF export contains (and its v1 limit)

Each animation **transform track** becomes a glTF node driven by a LINEAR animation of the decoded
per-frame local `hkQsTransform` (translation / rotation / scale). No coordinate conversion is applied:
Havok and glTF are both right-handed, +Y-up, metres, quaternion `(x,y,z,w)`.

**v1 emits the bones FLAT** (all under one root), because the parent hierarchy and bind pose live in
the character **MESH** skeleton (`MSHA`/`MESH` in `Dynamic0.megapack`), not in the animation pack
(`hkaSkeleton` / `hkaAnimationBinding` counts in `Animations.pack` are zero). A viewer therefore shows
every bone animating in its own local frame — a moving "joint rig" that proves the decode, but is not
anatomically composed.

**Phase 2** (a proper nested, skinned rig) needs the MSHA/MESH skeleton reader: read the character
skeleton (parent indices, bind pose, bone name-hashes), match the AP0L `ANIM` track hashes to skeleton
bones, and re-parent these same per-track TRS channels onto the real hierarchy. No change to the decode
or the channel data is required — only the node graph.

## Scope

Confirmed against the whole retail corpus (2214 clips, uniform `ctrl=0x45`, single-block). The
multi-block path and the unused rotation quant types (0/2/3/4/5) + 16-bit translation/scale are
structurally handled but not exercised by this pack — see the spec's risk register.
