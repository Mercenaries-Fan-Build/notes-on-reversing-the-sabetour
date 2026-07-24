# sab_skeleton

Extracts a **character skeleton** (bone hierarchy + bind pose) from *The Saboteur* (2009) `MESH`
assets, so a decoded Havok 6.5 animation (see [`../sab_havok65`](../sab_havok65)) can be rigged onto it.
`Animations.pack` contains no `hkaSkeleton`, so the bone tree and rest pose must come from the MESH — that
is what this tool produces.

## Build & run

```
cargo build --release

# extract the richest skinned mesh whose name contains the filter (default: CH_AL_SeanDevlin)
sab_skeleton "C:\GOG Games\The Saboteur\Global\Dynamic0.megapack" CH_AL_SeanDevlin_01_GR out.json

# list every character mesh (CH_AL_*) with its bone count
sab_skeleton "…\Dynamic0.megapack" --list
```

Output JSON per bone: `{ index, name_hash (u32), name_hash_hex, name?, parent (i32, -1=root),
local:{t[3],r[4] xyzw,s[3]}, world:{t,r,s,m[16]}, inv_bind:{m[16]} }`, plus `root_count`.

## How it works

The engine (codename *WildStar*) stacks: `.megapack` → `SBLA` sub-pack → `MSHA` wrapper → zlib → `MESH`.
The `MSHA` header (magic `AHSM`, sizes, and a 256-byte **ASCII asset name**) is stored *uncompressed*
inside the SBLA pack, so this tool locates meshes by scanning the raw megapack for the `AHSM` magic and
reading the name directly — no `global.map`/loosefiles navigation or external string dictionary needed.
Character meshes are named `CH_AL_<Name>_<part>`; only skinned meshes (`numBones0 > 1`) carry a skeleton.

`name_hash == boneName0 == pandemic_hash(bone name)` — the exact key the animation system uses (these
hashes appear in `Animations.pack`'s `ANIM` bone list). See [docs/formats/skeleton.md](../../docs/formats/skeleton.md) for
the confirmed byte layout.

Reference: PredatorCZ/SaboteurToolset (`mesh/mesh_to_gltf.cpp`, `include/meshpack.hpp`), cross-checked
byte-for-byte against `Dynamic0.megapack` (PC/GOG build).
