# Saboteur (2009) `.megapack` — WRITE-format specification

How to author a `.megapack` the engine's mounter accepts. Inverse of the `sab_mesh` /
`sab_skeleton` readers. All fields little-endian. Verified against `Global/Dynamic0.megapack`
(759 entries, PC/GOG build) and the decompiled mounter.

**Oracle:** `FUN_00e428c0` @ decomp VA `0x00e428c0` (the index reader/parser),
`FUN_00e42740` @ `0x00e42740` (by-key bsearch lookup), `FUN_00e34f70` @ `0x00e34f70`
(pack mount + priority), call site @ `0x00e428cb…0x00e429a2`.

## File layout

```
+0x00  char  magic[4] = "00PM"          ; bytes 30 30 50 4D. Engine test: u32==0x4D503030
+0x04  u32   count                       ; number of entries
+0x08  Entry index[count]                ; 20 bytes each (see below), FILE order
       Pair  table2[count]               ; 8 bytes each: {u32 crc, u32 index}, FILE order
       pad   → next 2048 boundary         ; never read by engine (real packs fill 0xCB)
       per entry (in `offset` order):
           u8  subpack[size]  @ offset    ; the ALBS sub-pack bytes, verbatim
           pad → next 2048 boundary
```

### Entry (20 bytes on disk)
| off | type | field | notes |
|----:|------|-------|-------|
| 0x00 | u32 | **crc**    | FIELD0 — the engine's **lookup key** (bsearch, see below) |
| 0x04 | u32 | **index**  | FIELD1 — a second path/instance hash; stored, not the primary key |
| 0x08 | u32 | **size**   | exact byte length of the sub-pack at `offset` |
| 0x0C | u64 | **offset** | absolute file offset of the sub-pack |

The reader loop (`FUN_00e428c0`) reads three `u32` with `FUN_00427cb0` (`crc`,`index`,`size`)
then one `u64` with `FUN_006ca430` (`offset`) — i.e. **20 bytes on disk**, stored 24-byte
(0x18) aligned *in memory* (offset at struct+0x10). Decomp:
```
uVar5=FUN_00427cb0(); *(iVar4+0x00+f0)=uVar5;   // crc
uVar5=FUN_00427cb0(); *(iVar4+0x04+f0)=uVar5;   // index
uVar5=FUN_00427cb0(); *(iVar4+0x08+f0)=uVar5;   // size
uVar6=FUN_006ca430(); *(iVar4+0x10+f0)=lo; *(iVar4+0x14+f0)=hi;  // offset u64
iVar4+=0x18;
```

### table2 (`count` × 8 bytes) — REQUIRED
After the index and an in-memory `qsort` by FIELD0, the engine reads a second table of
`count` × `{u32,u32}` = 8 bytes, in original **file** order, via the stream's virtual read
(`FUN_00e428c0` second loop → `param_1[0xf6]`). On disk each pair is `{crc,index}` — the same
first two fields of the corresponding `index[]` entry. It must be present or the engine reads
into the data region. Empirically: `8 + count*20 + count*8`, padded to 2048, equals the first
data offset (`0x5800` for count=759 ⇒ `8+15180+6072=21260 → 22528`).

### Alignment / padding
Every real data `offset` is **2048-aligned**. Functionally the engine only `seek`s to the
stored `offset`, so alignment is not validated — but replicate it (disc/streaming reads assume
sectors). Padding bytes are never read; real packs use filler `0xCB`, writer uses `0x00`.

## The lookup key — what `crc` and `index` are

- **`crc` (FIELD0) is the primary key.** `FUN_00e42740` does
  `_bsearch(&key, entries, count, 0x18, cmp)` with `key = param_2` written to `local_18[0]`
  only (the first u32). Because only offset 0 of the key buffer is set, the comparator can only
  read entry+0 = FIELD0. On a hit it seeks to entry+0x10 (offset) and takes entry+0x08 (size).
- **`crc`/`index` are hashes of the requested *resource path*, not of the asset.** Proven:
  entries `#0` and `#3` of Dynamic0 have **byte-identical** 14133-byte sub-packs (both
  `P_Keys_KeyRing_A`, nameHash `0xF4B78198`) yet carry different keys
  (`crc 0xD3EF69E0/index 0xB333DA43` vs `0x708B49A0/0x5E3513B5`). The same physical asset is
  mounted under two logical paths. Therefore neither field is a content checksum
  (`crc32(data)=0x6BB5A08D ≠ 0xD3EF69E0`) nor a function of the asset name
  (`crc ≠ pandemic(name)` on all 578 named samples).
- **The container's own hash is separate:** the ALBS sub-pack stores `pandemic_hash(assetName)`
  at ALBS+0x08 (and +0x24). Verified `pandemic_hash("P_Keys_KeyRing_A")==0xF4B78198` and on all
  578 named sub-packs. This is *not* the megapack key.
- The engine performs **no crc/index validation** against data, so a writer may choose any
  values. For an **override**, copy the base asset's `crc` (and `index`) from the base pack —
  the by-hash lookup then resolves to your entry.

## Sub-pack (ALBS) — copied verbatim
The writer copies the `[offset, offset+size)` slice, so the ALBS/MSHA/zlib bytes are preserved
exactly; no (de)compression is needed. Sub-pack anatomy (for reference; see
[`mesh_geometry.md`](mesh_geometry.md)): `"ALBS"`(0x414C4253) header, then `"MSHA"`(disk `AHSM`)
wrappers `{u32 magic; u32 unc0; u32 unc1; u32 c0; u32 c1; char name[0x100]}` + two zlib blobs
(`78 01`).

## Patch-override packs
`FUN_00e34f70(name,1,0x600,0x180,priority)` mounts a pack and qsorts the mounted list by
priority (desc). Observed priorities (call site @ `0x00d81…`, decomp lines 885093–885102):
`Dynamic0`=100, `palettes0`=0x5A, **`patchdynamic0`=0x18704 (100100)**, `patchpalettes0`=0x186FA.
`dynpack` lookups (`FUN_009ef620`→`FUN_00e35140`, param_3=500) consult any pack with
priority>499 first, in descending order. So a `Global/patchdynamic0.megapack` whose single
entry's `crc` equals a base asset's `crc` overrides it with no base rebuild.

## Minimal writer recipe (single entry)
1. `count = 1`.
2. `header_end = 8 + 20 + 8 = 36`; `data_off = align_up(36, 2048) = 2048`.
3. Write `"00PM"`, `count`, then `Entry{crc,index,size=len(sub),offset=2048}`, then
   `Pair{crc,index}`, zero-pad to 2048, then `sub` bytes, zero-pad to 2048.
4. Choose `crc`/`index`: for a round-trip or override, copy them from the source entry.

## Confidence table
| Claim | Status | Evidence |
|-------|--------|----------|
| magic "00PM", u32==0x4D503030 | **CONFIRMED** | decomp `if (iVar4==0x4d503030)`; file bytes `30 30 50 4D` |
| header = magic + u32 count | **CONFIRMED** | `FUN_00e428c0` reads magic then count then loops count |
| Entry = {crc,index,size (u32×3), offset (u64)} = 20B disk | **CONFIRMED** | decomp read order (3× `FUN_00427cb0` + `FUN_006ca430`); reproduces real offsets |
| second table `count`×8 `{crc,index}` after index | **CONFIRMED** | decomp 2nd loop; `8+count*20+count*8`→2048 == first data offset (0x5800) |
| data offsets 2048-aligned; padding unread (0xCB filler) | **CONFIRMED** | all 759 offsets %2048==0; header pad bytes = 0xCB |
| FIELD0 (`crc`) is the bsearch lookup key | **CONFIRMED** | `FUN_00e42740` sets only `local_18[0]`; seeks entry+0x10, size entry+0x08 |
| `crc`/`index` hash external resource *paths*, not content | **CONFIRMED** | #0 vs #3: identical bytes, different crc/index; `crc≠crc32(data)`; `crc≠pandemic(name)` |
| ALBS+0x08 = `pandemic_hash(assetName)` | **CONFIRMED** | 578/578 named sub-packs; `pandemic("ANY")==0xED057225` self-check |
| engine does NOT validate crc/index vs data | **CONFIRMED** | `FUN_00e428c0` stores fields verbatim, no re-hash/compare |
| patch priority 0x18704 ≫ base 100; by-hash override | **CONFIRMED** | decomp mount call sites 885093/885098; `FUN_00e350d0/e35140` priority gate 499/500 |
| exact string→`crc`/`index` transform (path→hash) | **UNKNOWN** | keys hash resource-DB paths not stored in the megapack; not recoverable from pack alone |
