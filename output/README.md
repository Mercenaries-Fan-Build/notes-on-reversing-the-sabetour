# output/

Canonical location for **generated artifacts** — anything our tools produce from a local game
install. **Everything here except this README is gitignored** (see `.gitignore`: `output/*` +
`!output/README.md`), because these files are derived from copyrighted game assets and must not be
committed. Regenerate them from your own retail install with the commands below.

## Layout

```
output/
  skeletons/   character skeletons + rigs
    <mesh>.json   sab_skeleton dump (bones: name_hash, parent, bind pose, world, inv_bind)
    <mesh>.skel   flat skeleton for sab_havok65 (parent name  t r s per line)
    <mesh>.glb    bind-pose rig, viewable in Blender / any glTF viewer
  anim_gltf/     decoded animations exported to glTF (create as needed)
```

## Regenerate

Build the tools once (`cargo build --release` in each of `tools/sab_skeleton`, `tools/sab_havok65`),
then:

```sh
# Extract a character skeleton (paths reference a local GOG install)
sab_skeleton "C:/GOG Games/The Saboteur/Global/Dynamic0.megapack" CH_AL_SeanDevlin \
    output/skeletons/CH_AL_SeanDevlin.json

# JSON -> .skel -> viewable bind-pose glTF
python tools/json_to_skel.py output/skeletons/CH_AL_SeanDevlin.json output/skeletons/CH_AL_SeanDevlin.skel
sab_havok65 skeleton output/skeletons/CH_AL_SeanDevlin.skel output/skeletons/CH_AL_SeanDevlin.glb

# Decoded animations -> glTF (all clips, or one)
sab_havok65 "C:/GOG Games/The Saboteur/Animations.pack" gltf-all output/anim_gltf
sab_havok65 "C:/GOG Games/The Saboteur/Animations.pack" gltf 100 output/anim_gltf/clip100.glb

# List every extractable character skeleton (name + bone count)
sab_skeleton "C:/GOG Games/The Saboteur/Global/Dynamic0.megapack" --list
```

## Full animated character preview (skinned mesh + skeleton + animation)

End-to-end: extract skeleton + mesh, bind a clip, render one glTF you can open in Blender.

```sh
MEGA="C:/GOG Games/The Saboteur/Global/Dynamic0.megapack"
PACK="C:/GOG Games/The Saboteur/Animations.pack"

# 1. skeleton (JSON -> .skel WITH inverse-bind matrices for skinning)
sab_skeleton "$MEGA" CH_AL_SeanDevlin output/skeletons/CH_AL_SeanDevlin.json
python tools/json_to_skel.py output/skeletons/CH_AL_SeanDevlin.json output/skeletons/CH_AL_SeanDevlin.skel

# 2. skinned mesh geometry (SMSH)
sab_mesh "$MEGA" CH_AL_SeanDevlin_01_GR output/skeletons/CH_AL_SeanDevlin.smsh

# 3. animation -> bone binding, pick a clip (2155/2214 are biped-playable)
sab_animmeta "$PACK" output/skeletons/CH_AL_SeanDevlin.json output/anim_bone_map.json
python tools/extract_trackmap.py output/anim_bone_map.json 0 output/anim_gltf/clip0.trackmap

# 4. combine -> Sean's mesh, rigged, playing clip 0 (crowd_walk)
sab_havok65 "$PACK" preview 0 \
    output/skeletons/CH_AL_SeanDevlin.skel \
    output/skeletons/CH_AL_SeanDevlin.smsh \
    output/anim_gltf/sean_walk_skinned.glb \
    output/anim_gltf/clip0.trackmap
```

Notes: `CH_AL_SeanDevlin_01_GR` is Sean's coat/torso sub-mesh (the full body is
split across `_UB/_LB/_HD/_HAT/…` parts, each skinned to the same skeleton — same
command, different `name_substr`). Untextured for now. Validated: `world ·
inverseBind ≈ I` (6e-6), skinned bind pose reproduces the authored mesh (1e-6),
the rig animates (191 bones move, stays humanoid, no NaN).
