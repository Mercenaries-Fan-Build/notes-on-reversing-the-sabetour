# HUD & UI (Scaleform)

The Saboteur's front-end is a classic Pandemic WildStar/Odin HUD layered on **Autodesk Scaleform GFx**. A single **`WSHUDManager`** owns ~55 `WSHUD*` widget classes, each of which is (or wraps) a Scaleform **`GFxMovie`**. The manager runs a **template state-machine** (loading / default / cinematic / pause / minigame / ...) and pumps all per-frame data into ActionScript through a **double-buffered command queue** of `SetVariable` / `Invoke` operations. Lua drives the whole thing through the `HUD.*` binding namespace.

## Architecture

### 1. Per-frame tick — `WSHUDManager::Update` (`FUN_009c2d10`)
Called from the game main loop (callers `0x0043101e`, `0x0043a6aa`, `0x004388c9`, `0x0043ca83`). Each frame it:
1. Promotes the **pending template** (`this+0xbbdc`, written by `SetTemplate`) into the **staged template** (`this+0xbbd8`).
2. Runs the transition: `FUN_009c0880` (tear down the *current* template `+0xbbd4`) then `FUN_009c1240` (set up the *staged* template `+0xbbd8`), using the `+0xbbe8` "transition complete" flag to sequence them across frames.
3. **Swaps the Scaleform command ring**: `DAT_0143cb4c ^= 1` (decomp line 854633) and resets the new bank's entry count.
4. Iterates **41 (`0x29`) sub-widget pointers** starting at `this+0x34`, calling each one's `vtable+0x20` (widget `Update`).

### 2. Template state-machine
Two symmetric dispatchers switch on a template enum:

| | field | function |
|---|---|---|
| Setup staged template | `+0xbbd8` | `FUN_009c1240` = `WSHUDManager::SetupCurrentTemplate` |
| Tear down current | `+0xbbd4` | `FUN_009c0880` = `WSHUDManager::TeardownCurrentTemplate` |

Confirmed enum → handler cases (from the `FUN_009c1240` switch, several named by embedded `__FUNCTION__` strings):

| enum | setup handler | name |
|---|---|---|
| 3,4,10,11 | `FUN_009bdfc0` | `SetupLoadingTemplate` |
| 5 | `FUN_009c0a00` | `SetupDefaultTemplate` |
| 6 | `FUN_009c0dc0` | `SetupCinematicTemplate` |
| 12 (`0xc`) | `FUN_009be9d0` | `SetupPerksPopupTemplate` |
| 15 (`0xf`) | `FUN_009befb0` | `SetupDLCMiniGameTemplate` |

`WSHUDManager::SetTemplate` (`FUN_009bc2a0`, `this+0xbbdc = id`) is the request entry point and the C backend of the Lua `HUDSetTemplate` binding. `WSHUDManager::DeleteHUDObject` (`FUN_009bd620`) is name-anchored via its assert.

### 3. Deferred Scaleform command queue
All `SetVariable` traffic goes through a **double-buffered ring** (base `DAT_01436a40` region; per-bank count at `DAT_0143cb44`; active bank index `DAT_0143cb4c`; up to `0x10` entries/bank, stride `0x308` bytes; each entry stores {target-movie, name[0x100], value, type-tag}). Four typed enqueue helpers:

| function | type tag | value |
|---|---|---|
| `FUN_0079de80` | 1 | string (`strncpy`) |
| `FUN_0079e040` | 2 | bool |
| `FUN_0079e110` | 4 | int (as GFx Number) |
| `FUN_0079e1e0` | 5 | float |

Each has an **immediate path** (when the "flush now" arg is set) that instead calls `GFxMovie::SetVariable` directly (`FUN_00434120` for strings, `vtable+0x2c` for numbers). The flush/apply side is **`FUN_0079e4a0`** (`WSHUDObject::FlushQueuedVarsAndAdvance`): it reads the *previous* bank (`DAT_0143cb4c ^ 1`), replays every entry whose target matches the movie, then advances the movie via `GFxMovie` `vtable+0xc8`. It is called from every widget's update.

### 4. GFxMovie interface (offsets inferred from call sites)
- `vtable+0x2c` — `SetVariable`
- `vtable+0x48` — `Invoke` (call an ActionScript function, e.g. `exRaceHUD_Show`, `closeDialogBox`, `exActivateMainScreen`)
- `vtable+0xc8` — `Advance`
- movie pointer is stored at `widget+0x10` on every `WSHUDObject`.

## Representative widgets
- **`WSHUDTimer` / RaceHUD** (`FUN_007725d0`): `Invoke("exRaceTimer_Start" / "exRaceHUD_Show" / "exRaceTimers_Show")` plus `_root.RaceHUD.racePlace/raceLap` and `_root.TimerHUD.raceTimeOverall` variables.
- **`WSHUDMessagebox::Update`** (`FUN_007880f0`, name-anchored): dialog boxes; `Invoke("closeDialogBox")`.
- **`WSHUDStartScreen::Update`** (`FUN_007b2cfa`, file-anchored): title/start menu; `Invoke("exRestart" / "exActivateMainScreen")`.

## Localization & Scaleform core
- ⚠️ **REFUTED 2026-07-24.** ~~**`LocalizedString_Fetch`** (`FUN_00db7e10` → `FUN_00db7c10`): string-table lookup by id~~ — this is **`HashedString`'s constructor**, i.e. the engine-wide `pandemic_hash`, not a localization fetch. The body is `if (p2) { *p1 = FUN_00db7c10(p2,p3); }` — it **returns no string**, it writes a 32-bit hash to an out-param. `FUN_00db7c10` calls `FUN_00dc1e20`, which is verbatim the case-insensitive FNV-1a with the `^0x2A` finalizer (`hash("ANY") == 0xED057225`). `camera.md`, `vehicle-train.md`, `cinematics.md` and `suspicion-wtf.md` all describe this same VA correctly as a type-name interner / CRC hash; this doc was the outlier. The keys `HUD.Saving`, `HUD.Locked`, `HUD.AmmoFull`, `HUD.PickedUp`, `LanguageSelection`, `LegalInfo` are the **dotted GameText IDs being hashed** — the localized-text lookup happens *downstream* of the returned hash (see [`../formats/gametext.md`](../formats/gametext.md), where `asset_id == pandemic_hash(dottedID)` is the store key).
- **Scaleform GFx library**: named symbol `GFxLoader::~GFxLoader @0x00b95400` survives. ⚠️ **REFUTED:** ~~`FUN_00ba2a00` loads movies by filename (`IME.swf`, `gfxfontlib.swf`)~~ — its body is `strlen` + `FUN_00ba2990` (a `GString` assign), not a movie loader. `WSHUDFileOpener` / `WSHUDMemFile` implement the GFx `GFileOpener` interface; `WSHudFlashRenderer` / `WSHudFlashTexture` bridge GFx rendering to the engine's `WSGfxSubsystem`(`Job`).

## Lua surface (`HUD.*`)
From `docs/saboteur-luacd` the mission scripts call e.g. `HUD.AddObjective(eOT_HEART, "...", 2)`, `HUD.SetupProgressBar`, `HUD.SetProgressBarValue`, `HUD.AddProgressBarCallback`, `HUD.SetObjectiveMarker`, `HUD.RemoveObjective`, `HUD.SetGPSTarget/ClearGPSTarget`, `HUD.SetWaypoint/ClearWaypoint`, `HUD.KeepObjectivesVisible`, `HUD.FlashRestrictedAreas` (see `Missions/Act_1_GetCaught.lua`). These bindings dispatch into `WSHUDManager`; their individual C entry points still need the binding-table / vtable map.

## Gaps
See structured `gaps`. ✅ **The RTTI vtable→VA map and the binding map now exist** ([`pc_vtables.tsv`](../../data/symbol_map/pc_vtables.tsv), [`lua_registration_map.tsv`](../../data/lua_registration_map.tsv)) — this doc predates both, so the 41 widget classes in the `+0x34` array are still not individually resolved here and most `HUD.*` binding backends and the un-named template cases (1,2,7,8,9,13,14,16-19) remain unpinned **in this document**; both are now resolvable. The flash-renderer / GfxSubsystem GPU path genuinely carries no name strings.

---

## Verification (adversarial pass)

**Verdict: solid** — 19/20 key functions confirmed against the decomp.

**Refuted / corrected:**

- `0x00ba2a00` — Doc calls it 'GFxLoader_CreateMovieByFilename / the GFx movie-load core'. The body is NOT a loader: it computes strlen(param_1) then calls FUN_00ba2990(str,len) (or FUN_00ba2990(0,0) for null). FUN_00ba2990 is a refcounted tagged-pointer string assign (*param_1 & 3 low-bit type tag, InterlockedExchangeAdd(-1) release, FUN_00ba25e0 copy) = classic Scaleform GString storage. So FUN_00ba2a00 is GString::operator=(const char*) / GString-ctor-from-cstr. 'IME.swf' is the FILENAME being wrapped into a GString, not a movie being created. The doc's own evidence is circular (size=52, ~100+ callers, 'sits next to GFxLoader::~GFxLoader') — a 52-byte function with 100+ heterogeneous callers argues AGAINST a movie loader and FOR a string constructor. The real CreateMovie sits elsewhere in the 0x00b9-0x00c8 block and consumes these GStrings.

**Seams (cross-subsystem):**

- FUN_009c2d10 (master tick) calls FUN_00795af0 at line 854635 — a large 2403-byte function called ONLY from the tick, immediately after the ring-bank swap and BEFORE the 41-widget vtable+0x20 loop. It iterates a stride-0x80 slot array at param+0xa10c/count param+0xa30c resetting transform/color state (0x3f800000=1.0f). This is the bulk per-frame HUD object transform/command-generation pass and is entirely omitted from the doc's FUN_009c2d10 description.
- FUN_009c2d10 tail (lines 854645-854656) has a one-shot init path gated on flags +0xbb9f/+0xbb9c: reads *(DAT_01442960+0x17d), conditionally calls FUN_0091d9a0, then FUN_00914b30(&DAT_01042050, FUN_00913d20, 0) and sets DAT_014e1c20=1 — a deferred registration/callback the doc doesn't mention (likely WSGfxSubsystem/render-thread hookup).
- Template dispatch case 1 (both setup FUN_009c1240 and the case-1 setup FUN_009bc2e0) is the Language-Select template: FUN_009bc2e0 calls FUN_00db7e10("LanguageSelection",1) and walks a 0x3f-entry table at param+0x10c stride 9. This ties template enum 1 to the WSHUDLanguageSelect class and to the localization seam; the doc lists 'LanguageSelection' only under FUN_00db7e10 without connecting it to case 1.
- The wstring SetVariable path is real: FUN_0079df81 (@0x0079df81) tags ring type 2 via _wcsncpy and immediate-dispatches to FUN_0079ea20; this is the case-2 handler in FUN_0079e4a0's flush. Doc mentions FUN_0079ea20 only in passing and never names FUN_0079df81 as the wstring queue-writer (the sibling of FUN_0079de80).

**Additional gaps / suspected decomp corruption:**

- FUN_0079e040 immediate path stores GFxValue::Type=2 (Boolean) in local_10[0] (line 508252), but its RING-BUFFER tag is 3 (line 508245), matching flush case 3. The doc's phrasing 'tags GFxValue type 2' inside a sentence about the 'ring-buffer pattern' conflates the two numbering schemes and could mislead a reader into thinking the queue tag is 2. (For int the doc correctly gave both: ring 4 / GFxValue Number 3.)
- Doc cites '_root.RaceHUD._visible (line 482477)' as an FUN_0079e040 example; that call site (482477) is just BEFORE the FUN_007725d0 header (482501), i.e. in the preceding function, not inside RaceHUD::Update. Minor line-attribution slip; the string/call are genuine.
- FUN_0079e4a0's immediate-advance block uses more GFxMovie vtable slots than the doc's single '+0xc8': +0x78 (line 508484, SetVisible/pause?), +4 and +8 (GetCurrentFrame/GetFrameCount), then +0xc8 (Advance). Worth documenting the full advance sequence.
- Not independently spot-checked (headers exist, strings self-certify): FUN_009bd620 DeleteHUDObject body semantics beyond the __FUNCTION__ string; the claimed RTTI class list and the ~25 claimed Lua HUD* bindings were NOT verified against ws_engine_classes.txt / lua_bindings.txt in this pass — recommend a follow-up to confirm those API names actually resolve to registered bindings rather than being inferred.

**Verifier corrections:**

## HUD & UI — verification corrections

**FUN_00ba2a00 — REFUTED name.** Not `GFxLoader_CreateMovieByFilename`. Body = `strlen(param_1)` then `FUN_00ba2990(str,len)`; FUN_00ba2990 is a refcounted tagged-pointer (low-2-bit type) string assign with InterlockedExchangeAdd release + FUN_00ba25e0 copy. Rename to **`GString::operator=(const char*)` / GString ctor-from-cstr** (Scaleform GString storage). `'IME.swf'`/`'gfxfontlib.swf'` are filenames being wrapped into GStrings, then consumed by the actual CreateMovie elsewhere in the 0x00b9–0x00c8 block.

**FUN_009c2d10 — add the missed per-frame call.** Between the ring-bank swap (`DAT_0143cb4c ^= 1`, 854633) and the 41-widget loop, it calls **FUN_00795af0** (854635, 2403 bytes, sole caller) — the main HUD-object transform/command-generation pass (stride-0x80 slots at +0xa10c, count +0xa30c, resets 1.0f transforms). Also note the flag-gated one-shot init tail (854645-854656): FUN_0091d9a0 / FUN_00914b30(&DAT_01042050, FUN_00913d20, 0) / DAT_014e1c20=1.

**FUN_0079e040 — clarify tag numbers.** Ring-buffer tag = **3** (508245, = flush case 3), while the *immediate* GFxValue::Type = 2 (Boolean, local_10[0], 508254 via vtable+0x2c). Reword "tags GFxValue type 2" so the queue tag (3) and the GFxValue enum (2) aren't conflated.

**Add FUN_0079df81** (@0x0079df81) as the **wstring** queue-writer (ring tag 2, `_wcsncpy`, immediate → FUN_0079ea20) — the sibling of FUN_0079de80 and the case-2 handler in the flush.

**Template enum 1 = Language-Select** (FUN_009bc2e0, case 1 of FUN_009c1240/FUN_009c0880) — calls FUN_00db7e10("LanguageSelection",1); backs WSHUDLanguageSelect. (Enums 2/7/8/9/0xd/0xe similarly have dedicated setup/teardown pairs the doc's dispatch summary omits.)

**Unverified in this pass:** claimed RTTI class list and the ~25 Lua `HUD*` bindings were not cross-checked against the data files — flag for follow-up.
