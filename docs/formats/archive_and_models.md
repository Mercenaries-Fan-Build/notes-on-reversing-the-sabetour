# Archives & Models

How The Saboteur stores and overrides assets, and the model (MESH) format. Cross-checked against the
clean decomp and PredatorCZ/SaboteurToolset. See [`../lineage_and_divergence.md`](../lineage_and_divergence.md)
for how each of these differs from Mercenaries 2 — **do not** assume Mercs 2 UCFX/FFCS layout here.

## Archive hierarchy

```
.megapack (magic MP00 / "00PM" LE)        outer archive; 64-bit offsets
  └── SBLA sub-pack (magic "ALBS" LE)      per-asset bundle (meshes/textures/physics/layout)
        └── MSHA wrapper                    wraps a MESH (metadata) + .dat (VB/IB) pair, with name + comp info
              └── MESH                       flat model
        └── DTEX                             standalone texture (own doc TBD)
  compression: sges (SEGS)                   same as Mercs 2, byte-identical
```

On-disk containers (retail install):

| File | Magic | Contents |
|---|---|---|
| `France\Mega0/1/2.megapack` | MP00 | world + models (~2.5 GB) |
| `Global\Dynamic0.megapack` | MP00 | dynamic objects (vehicles, characters) |
| `Global\Palettes0.megapack` | MP00 | palette/shared assets |
| `France\Start0.kiloPack`, `BelleStart0.kiloPack` | MP00 | startup bundles (same format, smaller) |
| `DLC\01\*.dynpack` | SBLA | loose DLC dynamic packs |
| `particle.pack` | FX01 | particle effects |
| `France\loosefiles_BinPC.pack` | (non-MP00) | loose binary configs/scripts |

Megapack index entry (`megapack.hpp`): `{ uint32 crc; uint32 index; uint32 size; uint64 offset; }`.
No embedded path strings (unlike Mercs 2 PTHS) — hash-only, resolved via an external string dictionary.

## Asset override — the built-in patch layer  ★ the "vz-patch.wad parallel"

Decomp-confirmed (mounter `FUN_00e34f70(name, 1, 0x600, 0x180, priority)`; caller ~`FUN_009f2xxx`).
Right after mounting each base pack, the engine unconditionally looks for a `patch*` sibling and mounts
it at a **~1000× higher priority**, so it wins the by-hash lookup:

| Base pack | Patch overlay | Priority (base → patch) |
|---|---|---|
| `France\Mega0.megapack` … | `patchmega0.megapack` / `patchmega%d.megapack` | — |
| `Global\Dynamic0.megapack` | `patchdynamic0.megapack` | 100 → 100,100 (0x18704) |
| `Global\Palettes0.megapack` | `patchpalettes0.megapack` | 90 → 100,090 (0x186fa) |

Each mount is guarded by a "slot == -1" check (mount once). This is "highest-priority-wins" like Mercs 1's
`RedVirtualDisk` "last-opened-file wins."

**To mod an asset:** build a megapack containing the replacement `SBLA`/`MSHA` under the **same asset
hash**, name it `patchmega0.megapack` (or `patchdynamic0`/`patchpalettes0`), drop it next to the base
pack. No base rebuild, no block-injection surgery — much cleaner than Mercs 2's WAD overlay. (Writer
tool not yet built — see [`../community_tooling.md`](../community_tooling.md).)

## MESH format (from SaboteurToolset `mesh/mesh_to_gltf.cpp`, cross-checked vs decomp)

Flat binary (no chunk tree):

```
MESH header:  BBOX, name(hash), numBones0, numBoneRemaps, numStreams, numPrimitives, numDrawCalls
[skeleton]:   boneIds[], localTMS[], bones[], transforms[], parentIds[]   (if skinned)
BoneRemaps[]  (if skinned)
Streams[]     vertex/index buffer descriptors (offsets into companion .dat)
Primitives[]  sub-mesh draw ranges (per-primitive BBOX)
DrawCalls[]   { uint32 primitiveIndex; hash material; uint16 parentBone; uint16 unk; }
```

Stream descriptor: `{ numVertices, format, vbOffset, vbSize, vbStride, ibOffset, ibSize, faceType, numIndices }`.
`faceType == 1` always → **triangle lists** (no strips, unlike Mercs 2).

Vertex `format` is an explicit **bitfield** (not stride-guessed):
`positionType:2 | skinType:2 | numColors:4 | numUVs:4 | normal:1 | tangent:1 | reserved:10 | constTag:8`
with `constTag == 0x1B`. ~18 known codes, e.g.:

| Code | Layout |
|---|---|
| `0x1b001102` | Pos(f16) + UV + Normal |
| `0x1b003102` | Pos(f16) + UV + Normal + Tangent |
| `0x1b001106` | Pos(f16) + BoneWeights + BoneIndices + UV + Normal |
| `0x1b003106` | + Tangent |

- Positions: half-float (R16G16B16A16). Skinning: 4-bone, UNORM8 weights / UINT8 indices.
- Materials are **external** — the drawcall references a material by hash into `.materials` (`WSAO`)
  files, not an inline chunk. LOD/damage-state handling not yet observed in the toolset (TBD).

## Status / next
- Format documented; **no Rust reader written yet.** SaboteurToolset already converts MESH→glTF, so the
  fastest validation is to run it against `Dynamic0.megapack` and confirm a character/vehicle extracts.
- A native reader (Rust) would let us pair with our own pipeline and is a prerequisite for a writer.
