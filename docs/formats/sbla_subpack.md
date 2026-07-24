# SBLA / ALBS sub-pack format (read + write)

An `SBLA` ("ALBS" LE) sub-pack is the per-asset bundle inside a `.megapack` entry (one megapack index
entry → one ALBS sub-pack). It holds one or more compressed blocks (an `MSHA`/`AHSM` mesh, `DTEX`
textures, physics, layout…) with an internal directory. To splice an edited asset into a multi-asset
sub-pack you must rebuild this directory (recompute offsets). Reverse-engineered from `FUN_00658870`
@0x00658870 (loader), `FUN_0065a900` @0x0065a900 (directory read), `FUN_006617d0` @0x006617d0 (block
inflate), verified byte-identical on 1000+ real sub-packs. Two independent investigators converged.

## Byte layout (little-endian)

```
HEADER (0x20 bytes for object packs; 0x44 for streamblock packs)
  +0x00  char  magic[4] = "ALBS"   (u32 0x53424C41; loader also accepts 0x41444139)
  +0x04  u32   variant             0x00 = object (mesh/texture asset); 0x3C = streamblock (baked cell)
  +0x08  u32   packNameHash        pandemic_hash(assetName)   (0 for streamblocks)
  +0x0C  u32   reserved (0)
  +0x10  u32   leadCompSize        stored (zlib) length of the leading/primary block
  +0x14  u32   leadUncSize
  +0x18  u32   reserved (0)
  +0x1C  u32   flags1
  (streamblock variant carries extra header words to 0x44)

DIRECTORY  (object: @0x20; streamblock: @0x44)  — N × 0x18 (24-byte) descriptors:
  +0x00  u32   hash        pandemic_hash of the sub-asset/type name; 0 = SECTION-BOUNDARY placeholder
  +0x04  u32   offset      blob offset, ALWAYS RELATIVE to a base — never an absolute file offset
                           (the loader seeks `base + offset`, see below). object: base = dir_end,
                           so offset[0] = leadCompSize = the MIDDLE region's byte length;
                           streamblock: base 0, offset[0] = 0.
                           offset[i] = offset[i-1] + compSize[i-1]  (real records only)
  +0x08  u32   compSize    stored (zlib) length  (the loader's read length)
  +0x0C  u32   uncSize     decompressed length   (the loader's inflate target)
  +0x10  u32   f4          lod/flag (0/1)
  +0x14  u32   f5          aux (0/small)

  N is NOT stored — the array is self-delimiting: it ends at the first record whose `offset` breaks
  the running-cursor chain (that word is the next region's magic, e.g. "AHSM"). A `hash==0` record is
  a section boundary: it shares the next record's offset and does NOT advance the cursor (0 body bytes).

MIDDLE   uncompressed MSHA/DTEX descriptors (opaque; preserved verbatim)
         object packs: [dir_end, dir_end + offset[0]) — i.e. exactly offset[0] bytes long
BODY     compressed blocks back-to-back, one per real record; total = Σ compSize
         object packs: at dir_end + offset[0]; streamblock packs: at EOF − Σ compSize
TRAILING footer/padding (preserved verbatim); usually EMPTY for object packs
```

> **`offset` is relative to `dir_end`, not absolute.** Confirmed over every ALBS sub-pack in
> `Dynamic0` + `Palettes0` + `Mega0` + `Start0` + `BelleStart0`: for the object variant
> `dir_end + offset[0] + Σ compSize == fileSize` **exactly** in 1080 of 1137 packs (the other 57 have
> a genuine small footer). Reading `offset` as absolute puts every blob `dir_end` bytes early and
> leaves a phantom TRAILING region of exactly `dir_end` bytes — a parse→rebuild round-trip cannot
> detect this (it relays regions verbatim), but any *splice* corrupts the preceding asset. This bug
> shipped in `sab_sbla replace` until 2026-07-24.

Loader evidence: `FUN_00658870` walks the directory accumulating sizes with `piVar4 += 6` (6 dwords =
24-byte stride) and reads `*(rec+8)` = compSize; `FUN_009f2660` seeks `base + offset` (field[1]);
`FUN_006617d0` reads `compSize` (field[2]) and inflates to `uncSize` (field[3]). Real example
(`Dynamic0` #0 `P_Keys_KeyRing_A`): `packNameHash = 0xF4B78198 = pandemic_hash("P_Keys_KeyRing_A")`,
`leadCompSize = 0x3604` (the AHSM record length), one descriptor `{0xF4B78198, off=0x3604, comp=0xF9,…}`.

## Tooling — `tools/sab_sbla` (std-only)
`info`/`list` · `roundtrip` (parse → re-derive the directory from block lengths → re-emit; asserts
byte-identical) · `rebuild` · `replace <recIdx> <blob.bin> <uncSize>` (swap a record's compressed blob,
recompute its compSize + all downstream offsets, re-emit) · `extract` · `scan <megapack>` (rebuild every
in-scope sub-pack).

## Validation (oracle) & scope
`scan` reports **0 in-scope mismatches**: Dynamic0 722/759, Mega0 226/244, plus Palettes0/Start0/Belle —
1000+ sub-packs rebuilt byte-identical. Splice proven: no-op `replace` → byte-identical; a size-changing
`replace` shifts all downstream offsets by Δ and re-parses cleanly. Composes with `sab_pack` (spliced
sub-pack → single-entry megapack → re-scan round-trips).

**Out of scope (the tool refuses these, not failures):** terrain/heightfield packs (`Mega2`, variant
0xB4…0x304, `HEI1`, embedded float bounds) and small blueprint/`Locator` node packs — different resource
layout, not MSHA/DTEX. In-engine load of an edited pack is INFERRED (byte-faithful) — confirm with the
x32dbg validation.
