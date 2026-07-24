# sab_mesh

Extracts the **renderable, skinned geometry** of a character MESH from *The Saboteur* (2009) and
emits two files:

1. **`SMSH`** — a compact binary geometry dump (positions, normals, UVs, 4 bone indices as
   **global** skeleton bone ids, 4 weights, u32 triangle indices, per-drawcall primitive ranges).
   This is the hand-off to a glTF assembler.
2. **`.glb`** — a standalone **skinned bind-pose glTF**: mesh + the full 191-bone skeleton + skin
   (JOINTS_0 / WEIGHTS_0 + inverseBindMatrices). Open in Blender to see the character in its
   modeled/bind pose. Untextured (v1: no materials/DTEX).

It reuses `sab_skeleton`'s container + skeleton parsing verbatim and adds the vertex/index geometry
and skinning. Byte layout: see [`docs/formats/mesh_geometry.md`](../../docs/formats/mesh_geometry.md).

## Usage

```
sab_mesh <megapack> [name_substr] <out.smsh> [out.glb]
```
`name_substr` defaults to `CH_AL_SeanDevlin_01_GR` (the mesh `sab_skeleton` picks — richest, 191 bones).
Among matching MSHA it chooses the one with the most bones. Example:

```
sab_mesh "C:/GOG Games/The Saboteur/Global/Dynamic0.megapack" sean.smsh sean.glb
```

## SMSH format (little-endian)

```
"SMSH"   u32 magic
1        u32 version
numVerts u32
numIndices u32
numPrims u32
positions numVerts*3 f32
normals   numVerts*3 f32   (zero if absent)
uvs       numVerts*2 f32   (zero if absent)
joints    numVerts*4 u16   (GLOBAL skeleton bone indices, 0..numBones-1)
weights   numVerts*4 f32   (normalized, sum ~= 1)
indices   numIndices*u32   (triangle list)
prims     numPrims * { u32 indexStart; u32 indexCount; u32 materialHash; u32 flags }
```
`prims` is one entry per DrawCall (`flags` = source primitiveIndex). Ranges may overlap (LOD/material
variants). The `.glb` instead draws each stream's full index range once for a clean render.

## Validation (CH_AL_SeanDevlin_01_GR)

- 3389 verts, 3348 triangles, 1 stream (format `0x1B003106`, stride 36), 12-bone palette, 5 drawcalls.
- Tail parse cursor lands exactly at body end (36600/36600).
- Weights sum 1.0000; all joint indices ≤ 183 < 191; all vertex indices ≤ 3388 < 3389.
- Positions finite, humanoid-scale (torso/coat piece, bbox Y 0.831–1.585 m).
- GLB is valid glTF 2.0; `nodeWorld · IBM ≈ I` (6.3e-7) and skinned-vs-authored drift 1.5e-7 m at bind.

Extracted asset data (`.smsh`, `.glb`, decompressed blobs) is **not** committed.
