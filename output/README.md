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
