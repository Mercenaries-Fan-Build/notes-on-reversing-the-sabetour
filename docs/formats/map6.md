# The Saboteur (2009) — `global.map` (MAP6) format

`global.map` is the boot-time asset/template registry loaded by
`FUN_009f3370` @ **0x009f3370**. It is a `MAP6` container. `France.map` shares
the magic and the record *prefix* but is a different, world-placement subformat
loaded by `FUN_009f75f0` @ 0x009f75f0.

All integers little-endian. Offsets below are into `DLC/01/Global.map` (356 B).

## Header (16 bytes)

| off | type   | value        | meaning |
|-----|--------|--------------|---------|
| 0x00 | u32   | 0x4D415036   | magic `MAP6` (on disk: `36 50 41 4d` = "6PAM"). Checked at FUN_009f3370 line ~885179. |
| 0x04 | u32   | 2            | `record_count`. Read by `FUN_0049ee70` (u32 stream read) and accumulated into `this+0xA0` (line 885185–186). |
| 0x08 | u8[8] | 0            | reserved / zero padding. |

## Record (variable length)

Read back-to-back, `record_count` times, starting at 0x10.

| field | type | notes |
|-------|------|-------|
| `name_hash` | u32 | `pandemic_hash(name)`. **CONFIRMED**: 0x315C74B2==hash("MM_Belle_VIP"), 0xFB5E3070==hash("KnifeThrow"). |
| `name_len` | u16 | length of `name` **including** the NUL. |
| `name` | u8[name_len] | NUL-terminated ASCII asset/template name. |
| `slot_a` | f32[3] | zero in global.map. Shared with France B/C records where the same slot is a bbox min corner. |
| `slot_b` | f32[3] | zero in global.map. France: bbox max corner. |
| `flag_a` | u16 | =1 in both records (INFERRED type/version). |
| `flag_b` | u16 | =2 in both records. |
| `entry_count` | u32 | number of referenced-asset entries. |
| `entries` | Entry[entry_count] | see below. |
| `trailer` | u8[56] | fixed 56-byte block, mostly zero (see below). |

### Entry (8 bytes)

| field | type | notes |
|-------|------|-------|
| `ref_hash` | u32 | `pandemic_hash` of a referenced asset/animation name (INFERRED; not reversed without a name dictionary). |
| `flags`    | u32 | opaque. For `KnifeThrow` every entry's low byte is 0x18 (likely a category tag) plus scattered bits (0x10/0x40/0x04…). |

### Trailer (56 bytes, fixed)

Mostly zero. Non-zero slots observed:
* `+0x04` u32: 28 (MM_Belle_VIP) / 388 (KnifeThrow) — a size-like value (INFERRED).
* `+0x0C` u32: echoes `entry_count` (1 / 15).
* `+0x24` u32: 1 for KnifeThrow only.

## Worked example

```
rec1  @0x10  MM_Belle_VIP  entry_count=1   (a disguise/model registration)
rec2  @0x83  KnifeThrow    entry_count=15  (an ability + its 15 animation refs)
```
16 (header) + 115 (rec1) + 225 (rec2) = **356** = file size, 0 leftover.

## Adding an entry (for modders)

Append a record and bump `record_count` at 0x04:
1. `name_hash` = `pandemic_hash(name)` (FNV-1a variant: basis 0x811C9DC5, per byte
   `h=((c|0x20)^h)*0x01000193`, finalize `(h^0x2A)*0x01000193`; `hash("ANY")==0xED057225`).
2. `name_len` (incl. NUL) + the name bytes.
3. 24 zero bytes (`slot_a`/`slot_b`) unless placing in the world.
4. `flag_a=1`, `flag_b=2`.
5. `entry_count` + that many `{ref_hash, flags}` referencing existing asset hashes.
6. A 56-byte trailer — copy an existing one and set `+0x0C` to `entry_count`.

## Confidence

| claim | status |
|-------|--------|
| magic 0x4D415036 at 0x00 | CONFIRMED (decomp 0x009f3370 + bytes) |
| u32 record_count at 0x04 | CONFIRMED (decomp FUN_0049ee70 read + bytes: 2 named recs) |
| record = hash+len+name prefix | CONFIRMED (both name hashes match pandemic_hash) |
| 24-byte slot = 2×vec3 | INFERRED (zero here; matches France B/C bbox slot) |
| flag_a/flag_b, entry layout | CONFIRMED count (exact consume); flag *meaning* INFERRED |
| 56-byte fixed trailer | CONFIRMED size (exact consume); field meanings INFERRED |
| whole-file exact consume | CONFIRMED (356/356, 0 leftover) |

## France.map (cross-check, NOT byte-exact here)

`FUN_009f75f0`: magic → header (region name "FRANCE" + world bbox floats) → then
**three sections**, each `u32 count` + that many records read by
`FUN_009f3900` (0x009f3900, tile-visibility), `FUN_009f3bf0` (0x009f3bf0) and
`FUN_009f3fa0` (0x009f3fa0) — the latter two identical placement readers that
read `u32 hash, u16 name_len, name, vec3 min, vec3 max, u16, u16`. Named records
verified: 0xD71075A6==hash("midnightshow"), 0x2369B026==hash("dance_a"), etc.
The per-record variable trailers (nested counts) were not fully decoded; a
byte-exact France reader is left open.
