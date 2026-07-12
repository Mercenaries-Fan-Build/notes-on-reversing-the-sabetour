---
name: archive-and-patch-megapack
description: Saboteur archives = MP00 megapack→SBLA→MSHA→flat MESH; asset override = built-in patchmega*.megapack high-priority layer
metadata:
  type: reference
---

**Archives:** `.megapack` (magic MP00 / "00PM" LE, 64-bit offsets, index `{crc,index,size,u64 offset}`) → `SBLA` sub-packs ("ALBS" LE) → `MSHA` wrapper → flat **MESH** + companion `.dat` (VB/IB). kiloPacks = MP00 startup bundles; `.dynpack` = loose SBLA (DLC); particle.pack = FX01. Compression = `sges` (identical to Mercs 2). NO embedded path strings (hash-only).

**MESH:** flat header (BBOX, name-hash, bone/remap/stream/prim/drawcall counts) + optional skeleton + streams (explicit vertex `format` BITFIELD, constTag 0x1B, ~18 codes) + primitives + drawcalls (material=hash, parentBone). f16 positions, **triangle LISTS** (faceType=1), 4-bone UNORM8/UINT8 skin, materials EXTERNAL (WSAO .materials). Differs structurally from Mercs2 UCFX — see [[read-lineage-and-divergence]].

**★Override = the "vz-patch.wad parallel":** decomp mounter `FUN_00e34f70(name,1,0x600,0x180,priority)` mounts, right after each base pack, a `patch*` sibling at ~1000× priority (hash wins): `patchmega0.megapack` (overlay Mega0/1/2), `patchdynamic0.megapack` (prio 100100 vs base 100), `patchpalettes0.megapack`. Mount-once guarded (slot==-1). To mod: build a megapack with the replacement SBLA/MSHA under the same asset hash, name it patchmega0.megapack, drop by the base pack. No block surgery. Reader/writer not yet built. docs/formats/archive_and_models.md.
