# World/startup megapack key (`France\Mega*`, `Start0`, `BelleStart0`) — findings

Companion to `megapack_key_derivation.md` (which solved `Global\Dynamic0`/`Palettes0`). This pins
what the world/startup packs key on, corrects the assumed `name_crc` model, and states exactly
which string is missing to reproduce `path_crc`.

Same container as all `.megapack`: magic `00PM`, `u32 count`, `count` × 20-byte entries
`{u32 path_crc; u32 name_crc; u32 size; u64 offset}`, then a `count`×8 `{path_crc,name_crc}` table.
Verified on `France/Mega0.megapack` (244 entries, PC/GOG). `path_crc` is the bsearch key
(loader `FUN_00e428c0` @ `0x00e428c0` qsorts by field0; lookup `FUN_00e42740` @ `0x00e42740`
compares field0 only) — confirmed: the on-disk index is load-order, not sorted by either field.

## What is CONFIRMED

### 1. The request-string FORM is `pandemic_hash("<name>.pack")`
The streamblock/world sub-pack loader `FUN_00658870` @ `0x00658870` (decomp line 331753) builds the
resource request with:
```c
_sprintf(local_4bc, "%s.%s", *(char**)(param_1 + 0x20), &DAT_00fc4594);  // "<name>.pack"
FUN_009ef620(local_4bc, ...);                                            // resolve
```
- **`DAT_00fc4594` = `"pack"`** — read directly from `Saboteur.exe`: PE imagebase `0x400000`,
  VA `0x00FC4594` → `.rdata` file offset, bytes `70 61 63 6B 00` = `"pack"`.
- The resolver `FUN_009ef620` @ `0x009ef620` suffix-routes: `"dynpack"`→dynamic pack,
  `"palettepack"`→palette pack, `DAT_0104fcd0`=`".wsd"`→`FUN_0064b600`. `".pack"` matches none, so it
  falls through to the **default megapack branch** (`this+0xdca0` → `FUN_00e350d0` @ `0x00e350d0`
  → bsearch `FUN_00e42740`). `DAT_0104fcd0` = `".wsd"` was likewise read from the exe (VA
  `0x0104FCD0`).
- Hashing is `pandemic_hash` (`FUN_00db7c10`→`FUN_00dc1e20`) — the SAME kernel that reproduces every
  `Global\Dynamic0` key (self-check: `pandemic_hash("global\Act1_IntKey.dynpack")==0xD3EF69E0`,
  `pandemic_hash("ANY")==0xED057225`).
- Pack files are mounted by `FUN_009f4320` @ `0x009f4320`: `_sprintf("%s\\%s%d.megapack", "France",
  "Mega", i)` → `France\Mega0.megapack` etc., then `FUN_00e34f70` @ `0x00e34f70`.

### 2. `name_crc` is a RAW ID, not `pandemic_hash(name)` (corrects the prior assumption)
On `France\Mega0`:
- **Streamblock entries** (ALBS with `packHash==0`): `name_crc` == the literal grid ID that appears
  in the baked mesh name. E.g. entry with meshes `France_Streamblock_1177344_baked_{3,4,8,9}` has
  `name_crc == 0x0011F700 == 1177344`; `..._1177856...` → `0x0011F800 == 1177856`. (Decimal ID,
  stored raw.)
- **Asset entries** (ALBS with `packHash != 0`): `name_crc` is a small **sequential ordinal**
  (`0x66, 0x6A, 0x6D, 0x74, 0x78, …`). `packHash` (ALBS+0x08) IS `pandemic_hash(assetName)` —
  verified on 40/54 asset packs (e.g. `pandemic_hash("VH_OP_Aurora_racer")==0x9C14F36C`).

So the Global-pack identity `name_crc == pandemic_hash(name)` **does NOT hold** for world packs.

### 3. `path_crc` encodes a per-instance path, not the asset/streamblock name
The same asset appears under multiple entries with the SAME `packHash` but DIFFERENT `path_crc` and
`name_crc` (e.g. `VH_OP_Aurora_racer` at `path_crc` `0xA9A4553E` / `0x52233CCC` / `0xA1BA2C1E`) —
so `path_crc` is a function of the placement/instance, exactly like `Global\Dynamic0` `#0` vs `#3`.

## What is MISSING (why `path_crc` is not reproducible from the pack)
`path_crc = pandemic_hash("<name>.pack")`, but **`<name>` (the object's runtime logical name,
`FUN_00658870` `param_1+0x20`) is not present in the megapack or the ALBS payload.** Exhaustively
disproven against real `France\Mega0` data:
- 25 unique, name-verified asset entries (`packHash==pandemic_hash(name)`): NONE reproduce
  `path_crc` for any `<folder>\<name>.pack` / `.dynpack` / `.wsd` / `.megapack` form.
- Streamblocks: millions of `<level><sep>Streamblock<sep><id><ext>` permutations (levels, folders,
  separators, dec/hex IDs, `.pack`/`.wsd`/`.streamblock`/…) — no hit; the short index `805`
  (from embedded textures `France_805_Diffuse`, `FranceMM_1177344`) also fails.
- Testing **every** embedded string (1199–2808 per block) × 42 folder/ext forms — no hit.

The `<name>` is assigned by the world **map-file** loader (prototype `WSStreamingManager::
LoadMapFileLevel` / `AppendBlock`, `PblTree<WSStreamBlock, PblCRC>` — see `WildStar_d.map`), which
is not one of the files in scope here. Recovering it needs either that map file's block/instance
name table or a runtime dump of the engine's hash→string debug table (`FUN_00db7c10` registers it).

## Practical modding note
For **streamblocks**, the recoverable key is `name_crc` = the grid ID (the number in
`France_Streamblock_<ID>_baked_*`). A modder can locate/replace a streamblock by that ID directly.
`path_crc` still must match for the by-hash fetch, so an in-place streamblock override must copy the
base entry's `path_crc` (as with `patchdynamic0`) — the same override tactic that sidesteps needing
the pre-image.

## Confidence table
| Claim | Status | Evidence |
|-------|--------|----------|
| Container = `00PM` + `{path_crc,name_crc,size,offset}` (same as Global) | **CONFIRMED** | 244 entries parse; ALBS at every offset |
| Request form `pandemic_hash("<name>.pack")`, ext `DAT_00fc4594="pack"` | **CONFIRMED** | `FUN_00658870` L331753; exe bytes at VA 0xFC4594 = "pack" |
| Resolver routes `.pack` to default megapack bsearch (path_crc key) | **CONFIRMED** | `FUN_009ef620`; `.wsd`=`DAT_0104fcd0`; `FUN_00e42740` key=field0 |
| Mount via `%s\%s%d.megapack` → `France\Mega0.megapack` | **CONFIRMED** | `FUN_009f4320`; exe fmt strings `%s\%s%d.megapack` |
| `name_crc` = raw grid ID (streamblocks) / sequential ordinal (assets) | **CONFIRMED** | `name_crc 0x11F700==1177344`==ID in baked name; ordinals 0x66,0x6A,… |
| `packHash` (ALBS+8) = `pandemic_hash(assetName)` | **CONFIRMED** | 40/54 asset packs; `VH_OP_Aurora_racer→0x9C14F36C` |
| `name_crc == pandemic_hash(name)` (prior Global assumption) | **REFUTED** for world packs | name_crc is a raw integer, not a hash |
| `path_crc` reproducible from pack contents | **NO — pre-image external** | 25 unique assets + millions of streamblock forms + all embedded strings fail |
| Missing field = runtime object name (`FUN_00658870` +0x20), from world map file | **PINNED** | sprintf source known; string absent from megapack + ALBS |
