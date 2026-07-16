# The Saboteur (2009) — `GameTemplates.wsd` (magic `AULB`) format

The GameTemplates file is the game's **object-definition layer**: a flat table of
named "templates" (a disguise use-point, a car, a weapon, a prop, a light setting,
a particle effect, …), each carrying a bag of `{property-hash → data}` pairs.
`global.map` / the world streamer reference these templates by name-hash.

Two files were used as ground truth:

| file | size | entries | note |
|------|------|---------|------|
| `DLC/01/GameTemplates.wsd` (loose) | 3969 B | 5 templates, 0 markers | small, no markers |
| main game, embedded in `France/loosefiles_BinPC.pack` @ **0x2732C50** (dec 41107152) | 8 204 431 B | 11072 entries = 10761 templates + 311 markers | full object DB |

Both parse with **exact byte consumption** and re-emit **byte-identical** (SHA-256 match).

---

## Loader (decomp oracle)

Boot calls `thunk_FUN_0162bfa0("%s\\GameTemplates.wsd", 0)` at decomp line 823978/823979.
The real loader is **`FUN_0162bfa0` @ `0x0162bfa0`** (decomp line 1756841). It:

1. opens the file (`FUN_00dc1060`), gets its size (`FUN_00dc13a0`), allocates
   (`FUN_00db3a30`) and reads the whole thing into memory (`FUN_00dc14e0`);
2. reads the header via `FUN_00463b00(&count)` — **`FUN_00463b00` @ `0x00463b00`** is a
   generic *"read little-endian u32, advance cursor 4"* helper (line 56856:
   `*param_2 = *(u32*)(base+cursor); cursor += 4;`);
3. loops per entry, and per pair calls `FUN_0045f440` — **`FUN_0045f440` @ `0x0045f440`**
   — a *"copy NUL-terminated string, advance cursor past the NUL"* helper (line 54222:
   `cursor += len + 1;`). This is why strings are stored with a trailing NUL.

All integer reads are native x86 `*(u32*)` → **little-endian**.

---

## Byte layout

```
Header
  char   magic[4]     = "AULB"            @0x00
  u32    entry_count                       @0x04   (LE)  -- includes markers
  entry_count × Entry                      @0x08 …         (contiguous, no padding)
```

### Entry = Marker | Template

Peek the entry: if the next 12 bytes are `08 00 00 00 00 00 00 00 00 00 00 00`
it is a **Marker**; otherwise it is a **Template**. A Marker is a degenerate record
(`total_size == 8`, body = two zero u32s); no real template can have `total_size == 8`,
so the discriminator is unambiguous. A Marker **still consumes one `entry_count` slot**
(10761 + 311 = 11072). Markers act as group separators; the DLC file has none.
This is the `peek(12)=={8,0,…}` case the community "GameTemplates-Helper" special-cases.

### Template record

| off (rel) | field | type | meaning |
|-----------|-------|------|---------|
| +0 | `total_size` | u32 LE | bytes of this record **after** this field. `4 + total_size` = full record. |
| +4 | `unk1` | u32 LE | always `0` observed |
| +8 | `unk2` | u32 LE | always `1` observed (`0` inside markers) |
| +12 | `name_len` | u32 LE | `strlen(name)+1` (includes NUL) |
| +16 | `name` | u8[name_len] | ASCII + trailing `\0` |
| … | `type_len` | u32 LE | `strlen(type)+1` |
| … | `type` | u8[type_len] | ASCII + trailing `\0` |
| … | `pair_count` | u32 LE | number of property pairs |
| … | `pair_count × Pair` | | |

Verified on template 0 of the DLC file: `name="UsePt_BrothelHat"` (@0x18),
`type="AIAttractionPt"` (@0x2d), `pair_count=81` (@0x3c), `total_size=1042` which
equals exactly the bytes from offset 0x0c to the end of the record.

### Pair

| field | type | meaning |
|-------|------|---------|
| `hash` | u32 **LE** | `pandemic_hash(property_name)` |
| `data_size` | u32 LE | length of `data` |
| `data` | u8[data_size] | value (see below) |

**Endianness of the hash — resolved.** The engine reads the hash with the same
LE u32 reader as everything else. Interpreting the 4 hash bytes **little-endian**
matches `pandemic_hash` of real property names; big-endian matches nothing:

| stored bytes | LE value | pandemic_hash of |
|--------------|----------|------------------|
| `24 c8 e5 1d` | `0x1de5c824` | `"Name"` |
| `50 42 72 5b` | `0x5b724250` | `"Model"` |
| `19 90 51 87` | `0x87519019` | `"Priority"` |
| `a0 89 25 98` | `0x982589a0` | `"Offset"` |
| `24 3a 47 92` | `0x92473a24` | `"AIAttractionPt"` |

(0 big-endian matches over all 325 DLC pairs.) The Helper's "big-endian" is a
*display* choice for the reversed bytes, **not** the value the game uses.

### `pandemic_hash`

FNV-1a variant, case-folded via `|0x20`, with a `^0x2A` finalize:

```
h = 0x811C9DC5
for c in bytes(s):  h = ((c | 0x20) ^ h) * 0x01000193   (mod 2^32)
h = (h ^ 0x2A) * 0x01000193                              (mod 2^32)
```

Self-test: `hash("ANY") == 0xED057225`, `hash("none") == 0x4FF9F863`.

### Pair `data` payloads

`data` is untyped bytes; the meaning depends on the property. Observed in the DLC file
(data-size histogram: `1B×111, 4B×198, 5B×3, 8B×6, 12B×3, 21/24/25/28B×1`):

* **1 byte** — bool/enum (`0`/`1`).
* **4 bytes** — one of: `u32`/`int`, `float32`, or **another `pandemic_hash`**.
  Confirmed hash-valued data: `0x4FF9F863` = `"none"` (28×, an explicit null-ref),
  and cross-references to sibling templates by name-hash —
  `0xFB5E3070` = `"KnifeThrow"`, `0x8F4F6379` = `"CP_Burlesque_Stool"` (both are
  templates in the same file). Floats look normal, e.g. `0x3C23D70A` = `0.01`,
  `0x42480000` = `50.0`.
* **larger** — packed structs (vectors, colors, curves) — property-specific, opaque here.

---

## What a template looks like per `type`

`type` is a free ASCII class name. 108 distinct types in the main file. Top types and
some gameplay-relevant ones:

```
1828 Prop          914 ParticleEffect   757 ParticleEffectSpawner  736 LightSettings
 690 FxHumanBodyPart 527 AIAttractionPt  459 Spore     402 Sound     357 Human
  92 Weapon          82 Explosion        63 Ammo        60 CAR        …
```

* **Vehicle** definitions: `type=CAR` (e.g. `SmallCar`, `LimoCar`, `MilitaryCar`, 345
  pairs each) plus the `VirVehicle*` family (`VirVehicleEngine`, `VirVehicleChassis`,
  `VirVehicleWheel`, `VirVehicleTransmission`, `VirVehicleSetup`), `VehicleCollision`,
  `VehicleWheelFx`.
* **Disguise / use-point** definitions: `type=AIAttractionPt` (e.g. `UsePt_BrothelHat`,
  `UsePt_Brothel`), `PairedAttrPt`.
* **Weapons**: `type=Weapon` (`Artillery`, `RocketLauncher`), `MeleeWeapon`, `Ammo`.
* **Characters**: `Human`, `FxHumanBodyPart`, `FxHumanHead`, `Player`.

A modder edits a definition by locating its template (by name) and rewriting the
`data` of the pair whose key is `pandemic_hash("<PropertyName>")`.

---

## Confidence

| claim | status |
|-------|--------|
| magic `AULB`, `u32 entry_count`, LE throughout | **CONFIRMED** (bytes + `FUN_00463b00`) |
| record = total_size, unk1, unk2, len-prefixed+NUL name & type, pair_count, pairs | **CONFIRMED** (exact-consume both files; `FUN_0045f440` string reader) |
| `total_size` excludes its own 4 bytes | **CONFIRMED** (measured == stored, all 10766 records) |
| pairs = `{u32 hash LE, u32 size, bytes}` | **CONFIRMED** (bytes) |
| hash is `pandemic_hash(name)`, read **little-endian** | **CONFIRMED** (5 exact name matches, 0 BE matches) |
| 4-byte data may itself be a `pandemic_hash` ref (`"none"`, sibling templates) | **CONFIRMED** (matches) |
| Marker = `08 00 00 00`+8 zero bytes, counts as one entry, group separator | **CONFIRMED** (311 markers, 10761+311==11072==count, exact-consume) |
| `unk1` always 0; `unk2` always 1 (0 in markers) | **INFERRED** (constant across all records; role unknown) |
| per-`type` payload schemas (which hash = which field beyond the 5 named) | **INFERRED / partial** — data is untyped; only the 5 tabulated property names reversed so far |
