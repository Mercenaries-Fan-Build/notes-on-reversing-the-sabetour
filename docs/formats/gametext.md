# The Saboteur (2009) — `GameText.dlg` (magic `TXTD` records) format

`GameText.dlg` is the game's **complete localized-text container**: every on-screen UI string
(objectives, mission names, tooltips, fail messages, garage/shop and object display names — the
strings `GameTemplates` and the Lua mission scripts reference) **and** every cinematic VO subtitle,
in one file per language.

There is one file per shipped language, all loose on disk:

```
Cinematics/Dialog/English/GameText.dlg   1 068 005 B   11 333 records
Cinematics/Dialog/French/GameText.dlg    1 120 831 B   11 335 records
Cinematics/Dialog/German/GameText.dlg    1 104 199 B   11 333 records
Cinematics/Dialog/Italian/GameText.dlg   1 071 241 B   11 333 records
Cinematics/Dialog/Polish/GameText.dlg    1 050 803 B   11 333 records
Cinematics/Dialog/Russian/GameText.dlg   1 026 329 B   11 333 records
```

All six **parse with exact byte consumption and re-emit byte-identical** (round-trip proven, see
[Validation](#validation)). There is also a sibling `Cinematics/Dialog/Random/RandomText.rnd`
(random ambient barks) loaded by the same subsystem; not covered here.

---

## Loader (decomp oracle)

`Cin.LoadGameTextFile` (`0x0071c810`) and the boot path both funnel through the region loader
`FUN_0095fb40 @0x0095fb40`, which builds the path with
`_sprintf(buf,"%s%sGameText.dlg", basePath, langDir)` (decomp line 797142) and calls the parser
**`FUN_0095f370 @0x0095f370`** with a create flag. `FUN_0095f370`:

1. reads the header, gates on `version == 5` (decomp: `if (unaff_EDI == 5)`);
2. reads `recordCount` and `totalStringCodeUnits`, allocates `recordCount × 0x24` in-memory entry
   records (36-byte `WSGameTextEntry`) and a `totalStringCodeUnits × 2` UTF-16 string heap;
3. per record, hashes the key with **`FUN_00dc1e20`** (= `pandemic_hash`, called at `0x0095f615`)
   to key the global store `DAT_0147db78`.

Lookup is `Cin.GetLocalizedText` (`0x0071c910`): `pandemic_hash(sTextID)` → `FUN_0095e4e0` on the
store. Each in-memory entry carries the localized string (`+0x20`) and a VO/audio asset id (`+0x1c`);
`Sound.PlayTextID` fires the latter. All integers are little-endian.

---

## Byte layout (little-endian)

```
Header (12 bytes)
  u32  version = 5
  u32  record_count
  u32  total_string_code_units      -- Σ str_len over the base records (NOT the DNEC sub-tables)

record_count × Record               -- contiguous, no padding
  char  magic[4] = "TXTD"
  u32   asset_id                     -- see "The asset_id / lookup key" below
  u16   key_len                      -- bytes of `key` INCLUDING its trailing NUL; 0 for UI text
  char  key[key_len]                 -- ASCII, NUL-terminated (VO records); ABSENT when key_len==0
  u16   str_len                      -- UTF-16 code units (NOT bytes)
  u16   str[str_len]                 -- UTF-16LE, NOT NUL-terminated

"DNEC" section                       -- per-cinematic-scene VO overlays (see below)
  u32   group_count
  group_count × { u32 scene_hash; u32 file_offset }
  ... sub-blobs to EOF
```

### The `asset_id` / lookup key  ★ the load-bearing fact for modding

Records come in **two kinds**, distinguished by `key_len`:

| kind | `key_len` | `key` | `asset_id` | store lookup key | count (EN) |
|------|-----------|-------|------------|------------------|-----------:|
| **UI text** | `0` | absent | `pandemic_hash(fullDottedID)` | `asset_id` (key is empty ⇒ `pandemic_hash("")==0`, so the engine uses the stored id) | 4037 |
| **VO subtitle** | `>0` | `"vo_…"` ASCII + NUL | audio/VO event id (NOT `pandemic_hash(key)`) | `pandemic_hash(key)` recomputed at load | 7296 |

* **UI text is keyed only by the hash of its dotted ID.** Proven: `pandemic_hash` of a dotted ID
  such as `"A1M0_Text.TASK_RaceJavier"` equals the record's `asset_id`, and the value is the on-screen
  string (`"Race Javier"`). **627 / 651** distinct `<File>_Text.<Key>` / `tooltips.<Key>` IDs harvested
  from `LuaScripts.luap` match a base-record `asset_id` exactly. The `<File>_Text` prefix is part of the
  hashed string, **not** a separate on-disk group — there is no per-file table for UI text; it is one
  flat namespace in the base records.
* **VO subtitles** additionally store an ASCII `vo_…` key; the engine keys the store by
  `pandemic_hash(key)` and keeps `asset_id` as the audio event to fire. `asset_id ≠ pandemic_hash(key)`
  for VO records (0 / 7296 match) — do not assume it is.

**To add a brand-new UI string:** append a record `{ "TXTD", asset_id = pandemic_hash("MyFile_Text.MyKey"),
key_len = 0, str_len, utf16le }`, bump `record_count`, add `str_len` to `total_string_code_units`, and
rebase the `DNEC` offsets (below). Because UI text lives in the always-loaded base records, **no Lua
`LoadGameTextFile` registration is required** for the new ID to resolve.

### `DNEC` section — per-scene VO overlays

After the base records, magic `DNEC` (bytes `44 4E 45 43`) begins a directory:
`u32 group_count`, then `group_count × { u32 scene_hash, u32 file_offset }`. Each `scene_hash` is the
hash of a cinematic scene (matches the `Global/<hash>.pov` filenames, e.g. `2721ff0b`, `955a92d4`);
each `file_offset` is an **absolute file offset** to a self-contained sub-table
(`u32 version=5, u32 …, TXTD records`) of that scene's dialogue. For a byte-faithful writer the whole
`DNEC` section is preserved verbatim; when the base-record section changes size by `Δ`, every
`file_offset` must be rebased by `Δ` (they are absolute). Editing/adding **UI** strings never touches
the sub-tables' contents, only their position.

### `pandemic_hash`

Identical to the engine kernel `FUN_00dc1e20` and to `mercs2_formats::hash::pandemic_hash_m2`:
FNV-1a/32, basis `0x811C9DC5`, prime `0x01000193`, per-byte `|0x20` case-fold, finalize
`^0x2A` then `*prime`; empty string ⇒ 0. Sanity: `pandemic_hash("ANY") == 0xED057225`.

---

## Validation

A prototype parser (`tools/` scratch, to become `sab_gametext`) run over all six language files:

* **Exact byte consumption** — the record loop + `DNEC` section consume every byte; cursor == filesize.
* **Round-trip byte-identical** — re-serializing header + records + verbatim `DNEC` tail reproduces the
  original file exactly (all 6 languages).
* **`total_string_code_units == Σ str_len`** over the base records — exact, all 6 languages.
* **Semantic** — 627 / 651 Lua-referenced dotted UI IDs hash to a base record `asset_id`; the ~24 misses
  are dynamically-constructed IDs or per-scene overlay strings, not format failures.

---

## Confidence

| claim | status |
|-------|--------|
| header `{u32 ver=5, u32 count, u32 totalCU}`, LE | **CONFIRMED** (bytes + parser `FUN_0095f370` version gate + alloc sizes) |
| record = `"TXTD"`, u32 asset_id, u16 key_len(incl NUL), key, u16 str_len(CU), utf16le | **CONFIRMED** (exact-consume + byte-identical round-trip, 6 langs) |
| UI text: key_len==0, asset_id == `pandemic_hash(dottedID)` | **CONFIRMED** (627/651 semantic matches) |
| VO: ascii key present, store keyed by `pandemic_hash(key)`, asset_id = audio event | **CONFIRMED (key/lookup) / INFERRED (asset_id role)** (0/7296 asset_id==hash(key); store-key via parser `0x0095f615`; +0x1c VO slot per `19-family-ui-hud-tutorial.md`) |
| `total_string_code_units == Σ str_len` (base) | **CONFIRMED** (exact, 6 langs) |
| `DNEC` = per-scene overlay directory of `{scene_hash, abs file_offset}` + sub-tables | **CONFIRMED (framing) / INFERRED (sub-table header fields)** (scene_hash==.pov names; sub-blob starts `05 00 00 00 …`) |
