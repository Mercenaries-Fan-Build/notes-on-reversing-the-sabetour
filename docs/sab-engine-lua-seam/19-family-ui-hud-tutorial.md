# Family 19 — UI / HUD / Tutorial / text / filter bindings (Scaleform-backed)

> **Verified:** all 78 `impl_va` re-checked against the tsv (all correct) and the 46/32 decomp-gap split
> reproduced exactly; the FNV-1a body, all 10 `SendPerkMessage` hash reversals (re-cracked independently),
> the `[10,12]` range check, the `jt[4]==jt[0xa]` factory collision, both 6-byte stubs, the `0x100` buffer,
> `cmp eax,0x30`, the 11 `Script\*.cpp` paths and every corpus `file:line` all re-confirmed. **Corrected:**
> slot `0x1b` is **`WSHUDLanguageSelect`**, not empty (independent RTTI walk — a hard error in the widget
> map, and it propagates to the ‡ note and open question 2); the corpus-call-site counts (**53 called / 25
> zero**, not 57/21 — the doc's own table already annotated 25); the `cHTM_*` enum's source file
> (`Modules/__MagicNumbers.lua`, not `__UtilFunctions.lua`); the "all `inlined`/`jmp` are gaps" rule (one
> exception); the `rtti_classes_all.txt` vtable citation (that file is name-only); and a `(10)`→`(9)`
> section count.
>
> **Confidence: high.** Every byte-level claim I could re-derive from `Saboteur.exe` independently
> reproduced, including the ones the decomp cannot see. No fabricated call sites were found.

Part of the [engine↔Lua seam series](00-seam-overview.md). Read [`02-marshalling-abi.md`](02-marshalling-abi.md)
first — every signature below is derived with that decoder ring. This doc also **corrects two claims** in
that decoder ring and **closes the largest stated gap** in
[`../symbol_map/hud-ui.md`](../symbol_map/hud-ui.md); see [Corrections to existing docs](#corrections-to-existing-docs).

Engine-side subsystem cross-reference: [`../symbol_map/hud-ui.md`](../symbol_map/hud-ui.md) (`WSHUDManager`,
the Scaleform command ring, the template state machine). Sibling family overlap:
[`15-family-mission-objective-task.md`](15-family-mission-objective-task.md) (the objective tray).

## Method note — this doc is derived from the retail exe, not only from the decomp

The Ghidra export (`saboteur_all_functions_decomp.txt`) is **missing 32 of this family's 78 bodies**: almost
every binding whose tsv `shape` is `inlined` or `jmp` lands in a gap where the analysis pass never created a
function. (33 rows are `inlined`/`jmp`; **32** are absent. The one exception is **`Filter.New`**
(`0x00728230`, `jmp`), which Ghidra *did* recover — `size=210`. So the shape is a strong predictor of the
gap, not a law.) Rather than mark 32 rows *inferred*, I disassembled them **directly out of
`C:\GOG Games\The Saboteur\Saboteur.exe`** with capstone, using the section table from
[`../../tools/dump_lua_registration.py`](../../tools/dump_lua_registration.py) for VA→file-offset mapping.

So the evidence tier here is *byte-level disassembly of retail code* for all 78 — strictly stronger than the
decomp pseudocode for establishing **what the code does**. It is not a substitute for an assertion string,
which anchors something disassembly cannot reach: the binding's **identity and provenance** (which C++
source file and symbol it was compiled from). The two are different kinds of evidence; this family has only
the first. Scripts used are throwaway; the reproduction
recipe is in [Open questions](#open-questions) if anyone wants them permanent.

## Inclusion rule (auditable)

A binding is in this family iff, in [`../../data/lua_registration_map.tsv`](../../data/lua_registration_map.tsv):

1. its `table` is **`HUD`** (57) or **`Filter`** (3); **or**
2. its `cpp_symbol` matches the case-sensitive regex
   `Tutorial|GameText|GetLocalizedText|SubtitlesOn|PrintMessage|PrintMissionText|AddMissionMessage|DisplayMissionMessage|RemoveAvailableMissionMessage|SendPerkMessage|PlayTextID|SetOverrideLoadScreenFadeIn|HQSetOnMiniMap` (18).

That yields **78 bindings**. Deliberate consequences, called out so the boundary is auditable:

- **Claimed despite overlap with family 15.** Fourteen `HUD.*` bindings (the objective tray, progress bars,
  objective markers, `ShowMissionTitle`, `RemoveCheckpointFromMap`) are already tabled in
  [`15-family-mission-objective-task.md`](15-family-mission-objective-task.md). Rule 1 claims the whole `HUD`
  table, so they appear here too. **This doc supersedes family 15 for those rows**: family 15 marked six of
  them *inferred, no body (gap)* — I have their bodies from the exe now. Where I confirm family 15's guess I
  say so; where I correct it I say so.
- **`Render.DrunkEffectFilter` / `Render.HeatShimmerFilter` are EXCLUDED** despite matching "Filter" in
  spirit. They are post-process screen effects (`Render` table), an unrelated sense of the word from
  `Filter.*` (an *entity predicate*). See [Three unrelated meanings of "filter"](#three-unrelated-meanings-of-filter).
- **`Trigger.AddFilter` / `Trigger.RemoveFilter` are EXCLUDED** — they *consume* `Filter.New`'s id but belong
  to the trigger family. Cross-referenced below, not tabled.
- **`Render.FadeScreen`, `FocusPt.SetTexture` are EXCLUDED** — screen/render family; no text or HUD widget.
- **`Util.HQSetOnMiniMap` is claimed** on a thin pretext (minimap). It is really a progression/rewards call.
  Ambiguous; claimed and flagged.
- **There is no `Text` or `GameText` table.** The four game-text bindings live under **`Cin`**, which is
  otherwise the cinematics table. That is a real and initially confusing fact, not an omission — see
  [Why the localization bindings live under `Cin`](#why-the-localization-bindings-live-under-cin).

## Coverage honesty

| Measure | Count |
|---|---:|
| Bindings in family (M) | **78** |
| Located — VA, table, real Lua name, return contract, byte-level from the tsv | **78 / 78** |
| Body read at byte level (decomp export **or** capstone over retail `Saboteur.exe`) → signature derived | **78 / 78** |
| └ body present in the Ghidra decomp export | 46 |
| └ body **absent** from the export, recovered from the exe by disassembly | 32 |
| Confirmed by an **EALA assertion string** (source `file:line`) | **0 / 78** |
| Corroborated by ≥1 real Lua corpus call site | **53 / 78** |
| **Zero** corpus call sites (engine-side only) | **25 / 78** |
| Signatures I consider **open** (body read but intent unresolved) | **2** (`HUD.StartMiniGame`, `HUD.AddTimer`) |

**Coverage, stated plainly: 78 of 78 located, 76 confirmed, 0 inferred, 2 open, 0 not found.**
**Confidence: high** — but read "confirmed" here precisely: it means *the body was read at byte level and
the signature follows from it*, *not* that an assertion string names the binding (**0 of 78** carry one).
Identity comes from `lua_registration_map.tsv`, which is byte-level but **derived**; it is not an assertion
anchor. If the map is wrong about a row, this doc is wrong about that row in exactly the same way.

**On the zero assertion strings.** There is **no `Script\Interface\HUD.cpp`**. A sweep of the whole 54 MB
decomp finds exactly 11 distinct `Script\*.cpp` assertion paths (Actor, Object, Vehicle, Utility, Navigation,
Inventory, SaveLoad, the three Freeplay files, WSStreamEvent) — **none of them HUD, Tutorial, or text**. So
the `file:line` column below is **empty for all 78 rows**, and that is a fact about the binary, not a gap in
my work. The assertion idiom yields 12/898 seam-wide; this family's share is zero. Every signature here rests
on the disassembly instead.

**On the 25 with no call sites.** (Counting only real call sites — `Name(` — across the 321 corpus scripts;
this is the number of rows the table below annotates **zero corpus call sites**.) Not dead code
necessarily — many are plausibly driven by DLC scripts,
the `.luap` files I did not decompile, or C++ callers. But `HUD.AddTimer` / `HUD.StartMiniGame` having no
caller *and* an unresolvable argument is why they are marked open.

## The table

`VA` is `impl_va` from the tsv. `Ret` is the **return contract from the tsv `family` column**, not from the
body (§6 of the ABI doc): `1*` = `LuaGlueFunctor0`, whose adapter thunk hardcodes `mov eax,1` regardless of
what the impl pushed — treat the "result" as meaningless. A real count means `LuaGlueFunctor0R`.

### `HUD.*` — text boxes and messages (9)

| Binding | Namespaced form | VA | Source (file:line) | Signature | Ret | Confidence | Evidence |
|---|---|---|---|---|---|---|---|
| HUDSetTutorialText | `HUD.SetTutorialText` | `0x0072cd40` | — | `(fDuration, sTextID, sGlyphID) -> bOk` | eax | confirmed | exe; `6f7140(1)`+`6f7160(2)`+`6f7160(3)`; both strings must resolve in the game-text table else `pushboolean(false)`, `return 0`; Saboteur.lua:219 |
| HUDClearTutorialText | `HUD.ClearTutorialText` | `0x007313f0` | — | `()` | 1* | confirmed | exe; `GetHUDObject(0x12)`→`FUN_007b5390`; Saboteur.lua:214 |
| HUDAddToolTip | `HUD.AddToolTip` | `0x0072d5a0` | — | `(sTextID [, fDuration [, nR, nG, nB]]) -> hMsg` | eax | confirmed | exe; `GetHUDObject(0xa)`=`WSHUDToolTipBox`, vtable+8; RGB packed `r<<16\|g<<8\|b`; SabTaskObjective.lua:1405 |
| HUDAddUpdateBoxText | `HUD.AddUpdateBoxText` | `0x0072cf40` | — | `(sText [, fDuration [, nR, nG, nB [, bFlag [, nExtra]]]]) -> hMsg` | eax | confirmed | exe; `GetHUDObject(0xb)`=`WSHUDUpdateBox`; SabTaskMission.lua:606; Saboteur.lua:317 |
| HUDAddSubtitle | `HUD.AddSubtitle` | `0x0072d2f0` | — | `(sTextID, fDuration) -> hMsg` | eax | confirmed | exe; `GetHUDObject(0xc)`=`WSHUDSubtitleBox`; Paris_1_Mission_1.lua:581; ScriptSequence.lua:883 |
| HUDRemoveMessage | `HUD.RemoveMessage` | `0x0072d790` | — | `(nWidgetId∈[10,12], hMsg)` | 1* | confirmed | exe; `lea ecx,[eax-0xa]; cmp ecx,2; ja reject` @`0x72d7ef`; **every shipped call site passes 6–8 → silent no-op**, see below |
| HUDModifyMessageString | `HUD.ModifyMessageString` | `0x0072d830` | — | `(nWidgetId∈[10,12], hMsg, sTextID)` | 1* | confirmed | exe; same range check @`0x72d8b1`; **zero corpus call sites** |
| HUDModifyMessageColor | `HUD.ModifyMessageColor` | `0x0072d990` | — | `(nWidgetId∈[10,12], hMsg, nR, nG, nB)` | 1* | confirmed | exe; same range check @`0x72da27`; **zero corpus call sites** |
| HUDAddContraband | `HUD.AddContraband` | `0x0072d180` | — | `(fAmount, sText, n, nNum, nDen [, bForce])` | 1* | confirmed | exe; `GetHUDObject(0x6)`=`WSHUDMoneyTracker`→`FUN_0079d700`; AmbientRubberStamp.lua:557 |

### `HUD.*` — tutorial widgets (4)

| Binding | Namespaced form | VA | Source (file:line) | Signature | Ret | Confidence | Evidence |
|---|---|---|---|---|---|---|---|
| HUDPlayAdvancedTutorial | `HUD.PlayAdvancedTutorial` | `0x007300e0` | — | `(nTemplateId, sCallbackName [, tSelf [, tUser]])` | 1* | confirmed | exe; `SetTemplate(arg1)` (`FUN_009bc2a0`) **then** `GetHUDObject(0x24)`=`WSHUDAdvancedTutorial`→`FUN_0076dab0`; Paris_1_Mission_1B.lua:390 |
| HUDAddLoadScreenTutorials | `HUD.AddLoadScreenTutorials` | `0x0072ce70` | — | `(tTextIDs)` | 1* | confirmed | exe; only table-typed arg in the family (`6f71c0(1)`); walks it via `FUN_006f7d90`/`FUN_006f7f00`, hashes each entry; `GetHUDObject(0x22)`=`WSHUDLoadingScreen`; RewardsManager.lua:5103 |
| HUDClearLoadScreenTutorials | `HUD.ClearLoadScreenTutorials` | `0x00731410` | — | `()` | 1* | confirmed | exe; `GetHUDObject(0x22)`; zeroes `+0x4f0`/`+0x4f4`; **zero corpus call sites** |
| HUDSetTransitionScreenParams | `HUD.SetTransitionScreenParams` | `0x0072e750` | — | `(nil) \| (sA, sB [, sC])` | 1* | confirmed | exe; `GetHUDObject(0x22)`; nil-arg branch → `FUN_0072c4e0` (reset); **zero corpus call sites** |

### `HUD.*` — GPS, waypoints, minimap (12)

| Binding | Namespaced form | VA | Source (file:line) | Signature | Ret | Confidence | Evidence |
|---|---|---|---|---|---|---|---|
| HUDSetGPSTarget | `HUD.SetGPSTarget` | `0x00730b30` | — | `(fX, fZ)` \| `(hTarget)` | 1* | confirmed | exe; `argc()==2` → `FUN_00780470(x,z)`, else handle → `FUN_007801c0`; **both forms in corpus**: Act_1_Escape.lua:653 vs SabTaskObjective.lua:241 |
| HUDClearGPSTarget | `HUD.ClearGPSTarget` | `0x00731470` | — | `()` | 1* | confirmed | exe; `FUN_0077f0a0(0)` on `DAT_014368b4`; Act_1_GetCaught.lua:1228 |
| HUDSetGPSTargetToFocus | `HUD.SetGPSTargetToFocus` | `0x00731450` | — | `()` | 1* | confirmed | exe; `FUN_007804e0(0)`; **zero corpus call sites** |
| HUDSetGPSCourse | `HUD.SetGPSCourse` | `0x0072e1c0` | — | `(sCourseName)` | 1* | confirmed | exe; hashes name → `FUN_007800d0`; Act_1_Race.lua:416 (`"Saarbrucken"`) |
| HUDClearGPSCourse | `HUD.ClearGPSCourse` | `0x00731490` | — | **`()` — takes NO arguments** | 1* | confirmed | exe; `FUN_0077f940(0,0,2)`, all operands hardcoded; **Act_3_Mission_1.lua:1071 passes `"ParisRace"` — silently ignored** |
| HUDSetWaypoint | `HUD.SetWaypoint` | `0x0072e500` | — | `(fX, fZ [, fY])` | 1* | confirmed | exe; `FUN_00780680`; Act_1_Farm.lua:1097 |
| HUDClearWaypoint | `HUD.ClearWaypoint` | `0x00731500` | — | `()` | 1* | confirmed | exe; `FUN_0077f020(0)`; Act_1_Farm.lua:106 |
| HUDHasWaypoint | `HUD.HasWaypoint` | `0x0072e670` | — | `() -> bHas` | eax | confirmed | exe; `FUN_0077ecc0` → `pushboolean`; **zero corpus call sites** |
| HUDGetWaypointPosition | `HUD.GetWaypointPosition` | `0x0072e6d0` | — | `() -> fX, fZ` | eax | confirmed | exe; `FUN_0077ec70` then **two** `pushnumber` → `return 2`; **zero corpus call sites** |
| SetEnableAllGPSEdgesInTrigger | `HUD.SetEnableAllGPSEdgesInTrigger` | `0x0072e5e0` | — | `(sTriggerPath, bEnable)` | 1* | confirmed | exe; hashes path → `FUN_00782980`; P3FP_OKCorral.lua:619 (backslash-separated world path) |
| HUDSetMinimapZoom | `HUD.SetMinimapZoom` | `0x0072e240` | — | `(bZoomed [, fZoom])` | 1* | confirmed | exe; `GetHUDObject(0x16)`=`WSHUDMinimap`; Paris_3_Mission_1.lua:1029 (`true, 0.7`) |
| HUDFlashRestrictedAreas | `HUD.FlashRestrictedAreas` | `0x007314d0` | — | `()` | 1*† | confirmed | exe; `GetHUDObject(0x16)`, vtable+0x14 gate, then `[obj+0xbc] = 1.0f` (`DAT_00ff1158`); Act_1_GetCaught.lua:2000 |

† tsv `nresults` is **empty** for this one row (the only such row in the family) — the body nonetheless sets
`eax=1` on every path, so the contract is `1*` like its siblings. The empty cell is a tsv extraction artifact,
not a different contract.

### `HUD.*` — objective tray, progress bars, markers (14) — *shared with [family 15](15-family-mission-objective-task.md)*

| Binding | Namespaced form | VA | Source (file:line) | Signature | Ret | Confidence | Evidence |
|---|---|---|---|---|---|---|---|
| HUDAddObjective | `HUD.AddObjective` | `0x0072daa0` | — | `(nIcon, sTextID, nPriority [, nParent \| nil [, bOptional \| nil [, n \| nil [, n \| nil]]]])-> nObjID` | eax | confirmed | **exe — family 15 had no body and marked this inferred**; args 4–7 each accept *number-or-nil* (`6f7140(k)` ‖ `6f7100(k)`); `FUN_009d1710`; Act_1_Farm.lua:224 |
| HUDRemoveObjective | `HUD.RemoveObjective` | `0x0072e120` | — | `(nObjID [, bImmediate])` | 1* | confirmed | exe; `FUN_009d1870`; confirms family 15 |
| HUDSetObjectiveText | `HUD.SetObjectiveText` | `0x0072e080` | — | `(nObjID, sTextID [, nNumVars, ...])` | 1* | confirmed | exe; `FUN_0072c770` (varargs formatter) → `FUN_009d1b60`; CFP_KoenigDestroy.lua:312 |
| HUDSetObjectiveStatus | `HUD.SetObjectiveStatus` | `0x0072df90` | — | `(nObjID, nStatus)` | 1* | confirmed | exe; `FUN_009d1ae0`; **zero corpus call sites** |
| HUDClearAllObjectives | `HUD.ClearAllObjectives` | `0x00731430` | — | `()` | 1* | confirmed | **exe — family 15 marked inferred**; `FUN_009d1cb0` on `DAT_014a9ddc`; SabTask.lua:1652 |
| HUDKeepObjectivesVisible | `HUD.KeepObjectivesVisible` | `0x0072e010` | — | `(b)` | 1* | confirmed | exe; `byte [DAT_014a9ddc + 0xe75] = b` @`0x72e069` — **confirms family 15 exactly** |
| HUDSetupProgressBar | `HUD.SetupProgressBar` | `0x0072dd20` | — | `(nObjID, hTarget \| nil)` \| `(nObjID, fMin, fMax, fCur)` | 1* | confirmed | exe; `argc()>=4` → 3 floats, else handle-or-nil; `FUN_004ab2c0`; **both forms in corpus**: Act_1_Farm.lua:225 vs Act_1_GetCaught.lua:1480 |
| HUDSetProgressBarValue | `HUD.SetProgressBarValue` | `0x0072df00` | — | `(nObjID, fValue)` | 1* | confirmed | exe; `FUN_009d1520` (id→bar) → `FUN_004ab1b0`; Act_1_GetCaught.lua:646 |
| HUDGetProgressBarValue | `HUD.GetProgressBarValue` | `0x0072de70` | — | `(nObjID) -> fValue` | eax | confirmed | exe; `FUN_009d1520`, gated on `byte [bar+0x239]`; **zero corpus call sites** |
| HUDAddProgressBarCallback | `HUD.AddProgressBarCallback` | `0x0072fd10` | — | `(nObjID, sCallbackName, fThreshold [, tSelf [, tUser]])` | 1* | confirmed | exe; callback-by-name idiom (`FUN_0070a180`); Act_1_GetCaught.lua:1482 |
| HUDSetObjectiveMarker | `HUD.SetObjectiveMarker` | `0x007303d0` | — | `(h, nMMIcon, nBlipType [, b [, b [, bMinimapEdge [, fHeight [, sStarterIcon]]]]]) -> bOk` | eax | confirmed | **exe — family 15 marked inferred**; `FUN_0078b760`/`FUN_0078b570`; InteriorManager.lua:662 |
| HUDShowObjectiveMarker | `HUD.ShowObjectiveMarker` | `0x00730710` | — | `(h, bMiniMap, bWorld)` | 1* | confirmed | exe; tries `FUN_0067c0a0` **then** `FUN_00498440`; confirms family 15 |
| HUDRemoveObjectiveMarker | `HUD.RemoveObjectiveMarker` | `0x00730610` | — | `(h) -> bOk` | eax | confirmed | **exe — family 15 marked inferred**; `FUN_00789c90`/`FUN_0078bb40`; ShopManager.lua:210 |
| HUDFlashObjectiveMarker | `HUD.FlashObjectiveMarker` | `0x00730810` | — | `([hMarker]) -> bOk` | eax | confirmed | exe; `6f71a0(1)` @`0x730854` is **optional**: no-handle branch @`0x73085d` calls `FUN_00993680(DAT_01494360)` (flashes the *current* marker) and returns `true`; handle branch @`0x73087c` flashes that one. Confirms family 15's `()`. Act_1_BarFight.lua:54 |

### `HUD.*` — screens, templates, widgets, misc (18)

| Binding | Namespaced form | VA | Source (file:line) | Signature | Ret | Confidence | Evidence |
|---|---|---|---|---|---|---|---|
| HUDSetTemplate | `HUD.SetTemplate` | `0x0072c9e0` | — | `(nTemplateId)` | 1* | confirmed | exe; `FUN_009bc2a0` = `WSHUDManager::SetTemplate`; Paris_1_Mission_1B.lua:830 (`cHTM_Tutorial_Disguise`) |
| HUDLoadObject | `HUD.LoadObject` | `0x0072ca50` | — | `(nWidgetId, sName)` | 1* | confirmed | exe; `FUN_009bbb30` = the widget factory; **zero corpus call sites**; see the id-10 bug below |
| HUDUnloadObject | `HUD.UnloadObject` | `0x0072cae0` | — | `(nWidgetId)` | 1* | confirmed | exe; `FUN_009bd620` = `DeleteHUDObject`; **zero corpus call sites** |
| HUDAddTimer | `HUD.AddTimer` | `0x0072cb50` | — | **open** | 1* | open | exe; body read, drives `WSHUDTimer` (slot `0xe`), but arg intent unresolved and **zero corpus call sites** |
| HUDPauseTimer | `HUD.PauseTimer` | `0x0072ccc0` | — | `(bPaused)` | 1* | confirmed | exe; `GetHUDObject(0xe)`=`WSHUDTimer`; **zero corpus call sites** |
| HUDRemoveTimer | `HUD.RemoveTimer` | `0x007313d0` | — | `()` | 1* | confirmed | exe; `DeleteHUDObject(0xe)` — note: **deletes the widget**, not a timer entry; SabTaskObjective.lua:108 |
| HUDArrowOn | `HUD.ArrowOn` (C++ `DirectionalArrowOn`) | `0x007301f0` | — | `(…)` | 1* | confirmed | exe; **lazily constructs `WSHUDArrow` itself** (`FUN_0076de30` @`0x73034a`) rather than using the factory; **zero corpus call sites** |
| HUDArrowOff | `HUD.ArrowOff` (C++ `DirectionalArrowOff`) | `0x00731380` | — | `()` | 1* | confirmed | exe; `GetHUDObject(0xd)`=`WSHUDArrow`, vtable+0x30(0); null-guarded; **zero corpus call sites** |
| HUDAddButtonPrompt | `HUD.AddButtonPrompt` | `0x0072fed0` | — | `(sPromptID [, fDuration [, sCallbackName [, tSelf [, tUser]]]]) -> nId` | eax | confirmed | exe; name→hash→lookup in map `0x0142e6f0`; `GetHUDObject(0x13)`=`WSHUDButtonPrompt`; **zero corpus call sites** |
| HUDClearButtonPrompt | `HUD.ClearButtonPrompt` | `0x0072e3c0` | — | `(nId)` | 1* | confirmed | exe; `GetHUDObject(0x13)`→`FUN_00770ee0`; **zero corpus call sites** |
| HUDShowMissionTitle | `HUD.ShowMissionTitle` | `0x0072e440` | — | `(sTitleID [, sSubtitleID])` | 1* | confirmed | exe; `GetHUDObject(0x13)`=`WSHUDButtonPrompt`(!)→`FUN_0076f9b0`; SabTaskMission.lua:400 |
| HUDSetPauseMenuPos | `HUD.SetPauseMenuPos` | `0x0072e2f0` | — | `(fX, fY, fZ)` | 1* | confirmed | exe; `GetHUDObject(0x23)`=`WSHUDPauseMenu`; Paris_3_Mission_1.lua:386 |
| HUDClearPauseMenuPos | `HUD.ClearPauseMenuPos` | `0x007314b0` | — | `()` | 1* | confirmed | exe; `GetHUDObject(0x23)`; `byte [obj+0xc8] = 0`; Teleporter.lua:44 |
| HUDStartMiniGame | `HUD.StartMiniGame` | `0x0072e8b0` | — | `(sName)` — **semantics open** | 1* | open | exe; `FUN_007754c0`; **zero corpus call sites**; relation to `WSHUDMiniGameValve`(0x14)/`WSHUDDLCMiniGame`(0x1d) unresolved |
| HUDRemoveCheckpointFromMap | `HUD.RemoveCheckpointFromMap` | `0x0072e920` | — | `(fX, fY, fZ)` | 1* | confirmed | exe; `FUN_00731560`; confirms family 15; **zero corpus call sites** |
| HUDAddGroundDecal | `HUD.AddGroundDecal` | `0x00730930` | — | `(h) -> bOk` | eax | confirmed | exe; `FUN_0067c0a0`/`FUN_004436f0` dual lookup → `FUN_0078bc60`; SabTaskObjective.lua:461 |
| HUDRemoveGroundDecal | `HUD.RemoveGroundDecal` | `0x00730a30` | — | `(h) -> bOk` | eax | confirmed | exe; `FUN_0078bcf0`/`FUN_0078e4f0`; SabTaskObjective.lua:582 |
| HUDClearAllObjectiveMarkers | `HUD.ClearAllObjectiveMarkers` | `0x007313b0` | — | `()` | 1* | confirmed | **exe — family 15 marked inferred**; does **not** touch the HUD manager: `byte [DAT_01436948 + 0xa514] = 1`; SabTask.lua:1985 |

### `Filter.*` — entity predicates (3)

| Binding | Namespaced form | VA | Source (file:line) | Signature | Ret | Confidence | Evidence |
|---|---|---|---|---|---|---|---|
| NewFilter | `Filter.New` | `0x00728230` | — | `(sExpr) -> nFilterId` **(a number, not a handle)** | eax | confirmed | exe; non-string → `pushnil`; else copies expr into a **0x100-byte** buffer (`FUN_00db4580`) → `FUN_006f8c70` → `pushnumber`; Checkpoint.lua:275 (`"!Nazi"`) |
| MatchFilter | `Filter.Match` | `0x00728510` | — | `(nFilterId, hEntity) -> bMatch` | eax | confirmed | exe; `6f7140(1)` + `6f71a0(2)`; `FUN_00498440` resolves the entity; Checkpoint.lua:277 |
| DeleteFilter | `Filter.Delete` | `0x00728310` | — | `(nFilterId)` | 1* | confirmed | exe; `FUN_006f9190`; Checkpoint.lua:288 |

### `Cin.*` — game text / localization (4)

| Binding | Namespaced form | VA | Source (file:line) | Signature | Ret | Confidence | Evidence |
|---|---|---|---|---|---|---|---|
| GetLocalizedText | `Cin.GetLocalizedText` | `0x0071c910` | — | `(sTextID) -> sText \| nil` | eax | confirmed | exe; hash → `FUN_0095e4e0` on `DAT_0147db78` → `FUN_006f7080` (push string); miss → `pushnil`; GameTips.lua:54 |
| LoadGameTextFile | `Cin.LoadGameTextFile` | `0x0071c810` | — | `(sFileName)` | 1* | confirmed | exe; hash → `FUN_0095f7f0`; **zero corpus call sites** |
| ReleaseGameTextFile | `Cin.ReleaseGameTextFile` | `0x0071c890` | — | `(sFileName)` | 1* | confirmed | exe; hash → `FUN_0095fbe0`; **zero corpus call sites** |
| SubtitlesOn | `Cin.SubtitlesOn` | `0x0071e950` | — | `(b)` — **SHIPPED STUB, body is `mov eax,1; ret`** | 1* | confirmed | exe; the entire function is 6 bytes @`0x71e950`; **called 4× in P1FP_Traitor.lua** (`:909`, `:1105`, `:1132`, `:1140` — *corrected 2026-07-24, was 3×*) and does nothing |

### `Util.*` — tutorial system (5)

| Binding | Namespaced form | VA | Source (file:line) | Signature | Ret | Confidence | Evidence |
|---|---|---|---|---|---|---|---|
| EnableTutorial | `Util.EnableTutorial` | `0x007535f0` | — | `(nId∈[0,48] \| sTextID [, bEnable=true])` | 1* | confirmed | exe; **polymorphic arg 1**: number → `cmp eax,0x30; ja reject` → `FUN_00a12490(id,b)`; string → hash → `FUN_00a12450`. Act_1_Factory.lua:934. **Connect_AmbientFP.lua:231 passes 4 args — 3 and 4 are ignored** |
| QueueTutorial | `Util.QueueTutorial` | `0x007536f0` | — | `(sTitleID, sBodyID [, fDuration [, b [, s [, b [, s [, b]]]]]])` | 1* | confirmed | exe; both names hashed; negative/zero duration clamped to `DAT_00f7d3bc` @`0x7537cf`; RewardsManager.lua:5228; Act_1_BarFight.lua:667 (8 args) |
| ClearAllPendingTutorials | `Util.ClearAllPendingTutorials` | `0x0075b420` | — | `()` | 1* | confirmed | exe; `FUN_00a126d0` on `DAT_014abdbc` = `WSTutorialManager`; Act_1_BarFight.lua:687 |
| EnableDynamicTutorialSystem | `Util.EnableDynamicTutorialSystem` | `0x00753930` | — | `(bEnable)` | 1* | confirmed | exe; `FUN_00a12440`; **zero corpus call sites** |
| SetAllDynamicTutorialsToDisabled | `Util.SetAllDynamicTutorialsToDisabled` | `0x0075b400` | — | `()` | 1* | confirmed | exe; `FUN_00a124b0`; **zero corpus call sites** |

### `Util.*` / `Render.*` / `Sound.*` — messages and text (9)

| Binding | Namespaced form | VA | Source (file:line) | Signature | Ret | Confidence | Evidence |
|---|---|---|---|---|---|---|---|
| AddMissionMessage | `Util.AddMissionMessage` | `0x00757cb0` | — | `(sMission, sConv, sMsg, nType, nPriority [, fDelay \| nil [, sSpore \| nil [, sCbAttempt \| nil [, sCbDelivered \| nil [, sCbRead \| nil [, tSelf \| nil [, tUser \| nil]]]]]]])` | 1* | confirmed | exe; **12 args — the widest binding in the family**; three independent callback-by-name registrations; `FUN_009cf6a0`/`FUN_009ce850`/`FUN_009cf710`; SabTaskObjectiveInteract.lua:615 |
| DisplayMissionMessage | `Util.DisplayMissionMessage` | `0x007522a0` | — | `(sMsgID, nType, sConvVO [, sCallback \| nil [, tSelf \| nil [, tUser \| nil]]])` | 1* | confirmed | exe; `FUN_009d0450`; P1FP_Traitor.lua:867 |
| RemoveAvailableMissionMessage | `Util.RemoveAvailableMissionMessage` | `0x007520d0` | — | `(sMission)` | 1* | confirmed | exe; hash → `FUN_009cf770`; RewardsManager.lua:5370 |
| SendPerkMessage | `Util.SendPerkMessage` | `0x00751d70` | — | `(sEvent)` — **10 accepted values, enumerated below** | 1* | confirmed | exe; copies string, hashes it, compares against 10 literal FNV constants; **all 10 cracked**; FP_CountryRace_1.lua:249 |
| SetOverrideLoadScreenFadeIn | `Util.SetOverrideLoadScreenFadeIn` | `0x00752490` | — | `(b)` | 1* | confirmed | exe; `FUN_009cc9e0`; Act_3_Mission_2.lua:1920 |
| HQSetOnMiniMap | `Util.HQSetOnMiniMap` | `0x0074e950` | — | `(sHQName, bOn)` | 1* | confirmed | exe; hash → `FUN_009ba700`; RewardsManager.lua:4681 |
| PlayTextID | `Sound.PlayTextID` | `0x00743eb0` | — | `(hSpeaker, sTextID)` \| `(sTextID, sX)` | 1* | confirmed | exe; hashes text id, looks it up in the game-text table, gated on `[entry+0x1c] != 0` → `FUN_0095df40`; **zero corpus call sites** |
| PrintMissionText | `Render.PrintMissionText` | `0x0073def0` | — | `(s)` — **SHIPPED STUB: validates and discards its argument** | 1* | confirmed | exe; `6f7160(1)` then `6f7a80(1)` @`0x73df3d`, result never used, `ret` @`0x73df43`; **zero corpus call sites** |
| PrintMessage | `Render.PrintMessage` | `0x0073fcb0` | — | `(s)` — **SHIPPED STUB, body is `mov eax,1; ret`** | 1* | confirmed | exe; 6 bytes @`0x73fcb0`; **called 6× in Experimental/Checkpoint_v2.lua** (`:30`, `:42`, `:59`, `:73`, `:83`, `:94` — *corrected 2026-07-24, was 3×*) and does nothing |

---

## How the subsystem actually works

### The `WSHUDManager` widget array — 41 slots, now resolved (38 classes + 3 genuinely empty)

[`hud-ui.md`](../symbol_map/hud-ui.md) established that `WSHUDManager::Update` iterates **41 (`0x29`)
sub-widget pointers starting at `this+0x34`**, and listed as its top gap: *"no RTTI vtable→VA map yet, so the
41 widget classes in the `+0x34` array are not individually resolved."*

That gap is now closed. Three independent derivations agree:

1. **`FUN_009bbb20`** — the function every `HUD.*` binding calls — is just
   `return *(void**)(mgr + 0x34 + id*4)`. So **the "HUD object id" a binding passes IS the array index.**
   `DAT_014a9b14` is the manager singleton.
2. **`FUN_009bbb30`** (the backend of `HUD.LoadObject`) is a **widget factory**: a jump table at
   `0x009bbfb8`, 41 entries, `id → (sizeof, ctor)`. Feeding each ctor to an RTTI walker
   (vtable → `[vtable-4]` COL → `COL+0xc` type descriptor → mangled name) names the class.
3. **The ctors self-register.** Every widget ctor passes `(<id>, 1)` down to `FUN_0079e410` — the
   `WSHUDObject` base ctor, which stores the id at `this+4` — and ends with `FUN_009bd5f0`, which does
   `*(mgr + 0x34 + *(obj+4)*4) = obj`, i.e. `mgr->slots[id] = this`. Example: `WSHUDMessagebox`'s ctor at
   `0x00788510` does `push 1` @`0x00788529`, `push 0x28` @`0x0078852d`, `call 0x79e410` @`0x00788533`.
   **The id is a compile-time constant baked into each ctor**, so it is authoritative and independent of the
   factory. Two caveats for anyone re-running this: the call is not always *direct* — three intermediate
   base ctors forward the id (`WSHUDTextBox` `0x007b44f0` for slots 0xa/0xb/0xc, `WSHUDCommon` `0x00784620`
   for 0x1f/0x23), and some ctors push the id from a register rather than as an immediate
   (`WSHUDCredits`: `xor edi,edi; push edi` → id 0). A scan that only matches `push imm; call 0x79e410`
   silently misses seven slots.

Derivation 3 agrees with derivation 2 on every slot where both are defined — except one, which is a real bug
(below). The map:

| id | Class | id | Class |
|---:|---|---:|---|
| 0 | `WSHUDCredits` | 0x16 (22) | `WSHUDMinimap` |
| 1 | `WSHUDTitleScreen` | 0x17 (23) | `WSHUDPerksPopup` |
| 2 | `WSHUDCrosshairs` | 0x18 (24) | `WSHUDMissionMessage` |
| 3 | `WSHUDBirdHunt` | 0x19 (25) | `WSHUDMissionMessageNotification` |
| 4 | `WSHUDDamageIndicator` | 0x1a (26) | `WSHUDMissionComplete` |
| 5 | `WSHUDHealthBar` | 0x1b (27) | `WSHUDLanguageSelect` ‡ |
| 6 | `WSHUDMoneyTracker` | 0x1c (28) | `WSLegal` |
| 7 | `WSHUDSabotage` | 0x1d (29) | `WSHUDDLCMiniGame` |
| 8 | *— empty —* | 0x1e (30) | `WSHUDBladeScreen` ‡ |
| 9 | `WSHUDObjectiveTray` | 0x1f (31) | `WSHUDStartScreen` |
| 0xa (10) | `WSHUDToolTipBox` † | 0x20 (32) | `WSHUDShop` |
| 0xb (11) | `WSHUDUpdateBox` | 0x21 (33) | `WSHUDGarage` |
| 0xc (12) | `WSHUDSubtitleBox` | 0x22 (34) | `WSHUDLoadingScreen` |
| 0xd (13) | `WSHUDArrow` | 0x23 (35) | `WSHUDPauseMenu` |
| 0xe (14) | `WSHUDTimer` | 0x24 (36) | `WSHUDAdvancedTutorial` ‡ |
| 0xf (15) | `WSHUDSuspicionMeter` | 0x25 (37) | *— empty —* |
| 0x10 (16) | `WSHUDButtonSelect` | 0x26 (38) | *— empty —* |
| 0x11 (17) | `WSHUDInventory` | 0x27 (39) | `WSHUDAutoSave` |
| 0x12 (18) | `WSHUDTutorial` | 0x28 (40) | `WSHUDMessagebox` |
| 0x13 (19) | `WSHUDButtonPrompt` | | |
| 0x14 (20) | `WSHUDMiniGameValve` | | |
| 0x15 (21) | `WSHUDCarDashboard` | | |

† **Slot 0xa is `WSHUDToolTipBox`, and the factory disagrees — the factory is wrong.** See the bug below.
‡ **Not reachable through the factory at all** (`jt[0x1b]`, `jt[0x1e]` and `jt[0x24]` all point at the same
default `return 0` arm, `0x009bbb5f`). All three are constructed instead by `FUN_009bcb70`, the manager's
construct-all-widgets routine (sole caller `0x0043c6e2`), which news them directly.
`HUD.PlayAdvancedTutorial`'s `GetHUDObject(0x24)` therefore works at runtime even though
`HUD.LoadObject(36, …)` could never create it.

**Correction (verification pass): slot `0x1b` is not empty.** An earlier revision of this table listed it
as *— empty —*, reasoning from the factory's default arm. That was the same mistake the ‡ note warns
against. The class is **`WSHUDLanguageSelect`**: its ctor does `push 1` @`0x0078439c`, `push 0x1b`
@`0x007843a0`, `call 0x79e410` @`0x007843a6`, and its vtable `0x00fefa64` walks
(`[vt-4]` → COL `0x010cc3d4` → `+0xc` → TD `0x01137f5c` → `+8`) to `.?AVWSHUDLanguageSelect@@`. The name is
also present in [`../../data/rtti_classes_all.txt`](../../data/rtti_classes_all.txt) (line 2344). It is the
widget behind template **1 `cHTM_LanguageSelection`**, which the template table below independently pins to
`FUN_009bc2e0` fetching the string `"LanguageSelection"` — so the slot map and the template enum now
corroborate each other here too. **Only slots 8, 0x25 and 0x26 are genuinely empty.**

This map is what makes the binding table above readable: `HUD.AddToolTip` → slot `0xa` → `WSHUDToolTipBox`;
`HUD.SetMinimapZoom` → slot `0x16` → `WSHUDMinimap`; `HUD.ClearTutorialText` → slot `0x12` → `WSHUDTutorial`.
Ten bindings independently corroborate their slot's class by name.

The one genuinely odd pairing is **`HUD.ShowMissionTitle` → slot `0x13` = `WSHUDButtonPrompt`**. That is what
the code does (`0x0072e440` → `GetHUDObject(0x13)` → `FUN_0076f9b0`); the mission-title banner appears to be
a second responsibility bolted onto the button-prompt widget. Not a misreading, just untidy engine code.

### The template enum — `cHTM_*` closes the other hud-ui.md gap

`hud-ui.md` confirmed five template cases from the `FUN_009c1240` switch and listed *"the un-named template
cases (1,2,7,8,9,13,14,16-19) are unpinned"* as a gap. **The Lua side names all of them.**
[`Modules/__MagicNumbers.lua:147-166`](../saboteur-luacd/src/Modules/__MagicNumbers.lua) defines the
complete enum — a single contiguous block, `cHTM_Blank = 0` through `cHTM_Tutorial_WTF = 19` — and it
agrees exactly with the engine-side cases hud-ui.md did pin:

| id | `cHTM_*` | hud-ui.md engine finding |
|---:|---|---|
| 0 | `Blank` | — |
| 1 | `LanguageSelection` | ✔ case 1 → `FUN_009bc2e0`, fetches `"LanguageSelection"` (matches `WSHUDLanguageSelect`, slot 0x1b) |
| 2 | `LegalInfo` | — (matches `WSLegal`, slot 0x1c) |
| 3 | `Loading` | ✔ 3,4,10,11 → `SetupLoadingTemplate` |
| 4 | `Transition` | ✔ |
| 5 | `Default` | ✔ case 5 → `SetupDefaultTemplate` |
| 6 | `Cinematic` | ✔ case 6 → `SetupCinematicTemplate` |
| 7 | `Shop` | — (matches `WSHUDShop`, slot 0x20) |
| 8 | `Garage` | — (matches `WSHUDGarage`, slot 0x21) |
| 9 | `PauseMenu` | — (matches `WSHUDPauseMenu`, slot 0x23) |
| 10 | `MissionFail` | ✔ |
| 11 | `Death` | ✔ |
| 12 | `PerksPopup` | ✔ case 12 → `SetupPerksPopupTemplate` |
| 13 | `MissionMessage` | — (matches `WSHUDMissionMessage`, slot 0x18) |
| 14 | `BirdHunt` | — (matches `WSHUDBirdHunt`, slot 3) |
| 15 | `DLCMiniGame` | ✔ case 15 → `SetupDLCMiniGameTemplate` |
| 16 | `Tutorial_Ambient` | — |
| 17 | `Tutorial_Disguise` | — |
| 18 | `Tutorial_Suspicion` | — |
| 19 | `Tutorial_WTF` | — |

Six independent agreements with hud-ui.md's engine-derived cases, zero conflicts. This is a **double-blind
confirmation**: the Lua constants were written by designers, the switch cases were recovered from
disassembly, and they match. The remaining names (2, 7, 8, 9, 13, 14, 16–19) should now be treated as
**confirmed** rather than open — each of 2/7/8/9/13/14 additionally corroborates by pointing at exactly the
widget class the slot map independently named.

Note the **template enum and the widget-slot enum are different enums** — templates run 0–19, slots run
0–0x28. `HUD.SetTemplate(cHTM_Tutorial_Suspicion)` = 18 = a template; `GetHUDObject(0x12)` = 18 = the
`WSHUDTutorial` widget. **They collide numerically and mean unrelated things.** `HUD.PlayAdvancedTutorial` is
the one binding that takes a *template* id (`cHTM_Tutorial_*`) — Paris_1_Mission_1B.lua:390 passes
`cHTM_Tutorial_Suspicion`, and the body forwards it to `SetTemplate` before touching slot 0x24.

### The name-hash — `FUN_00dc1e20` is FNV-1a, and I can prove it

The single most useful function in this family:

```c
int FUN_00dc1e20(char *s) {            // @0x00dc1e20
  if (!s || !*s) return 0;
  uint h = 0x811c9dc5;                 // FNV-1a offset basis
  do { h = ((*s | 0x20) ^ h) * 0x1000193; } while (*++s);   // |0x20 => case-INSENSITIVE
  return (h ^ 0x2a) * 0x1000193;       // one extra avalanche round with a 0x2a salt
}
```

This is **32-bit FNV-1a, lower-cased, with a non-standard final round**. Its wrapper
`FUN_00db7e10(&out, s, 1)` stores the hash and (when arg 3 is set) registers the string in a reverse-lookup
table via `FUN_00db7920` — i.e. it is **`WSSymbol::WSSymbol(const char*)`**, not a string copy.

Because the hash is fully specified, **hash constants in the binary are reversible against a dictionary.**
Worked example — `Util.SendPerkMessage` (`0x00751d70`) hashes its argument and compares it against ten
literal constants. Hashing every string in the Lua corpus plus every ASCII string in `Saboteur.exe` cracks
**10 of 10**:

| constant | string | corpus call site |
|---|---|---|
| `0x8f375b01` | `BridgeBlowUp` | — |
| `0x3e75fc90` | `LouvreLiberated` | — |
| `0x138ac486` | `TimeTrial` | FP_Paris_Qualifier.lua:163 |
| `0x14913b24` | `AmbientFreeplayDestroyed` | — |
| `0x4096696a` | `StealthKillGeneral` | — |
| `0x739d66bb` | `NeighborhoodLiberated` | — |
| `0xa8b4e827` | `FreeplayRacePlace` | FP_CountryRace_1.lua:249 |
| `0x97bcb514` | `PantheonLiberated` | — |
| `0xa0aad3a8` | `FreeplayRaceWin` | FP_CountryRace_2.lua:225 |
| `0xed48ed29` | `TowerBlownUp` | — |

**`Util.SendPerkMessage` accepts exactly these ten strings and silently ignores everything else** — a
complete, closed enumeration of the game's perk-trigger events, recovered without a single assertion string.
Three are confirmed live by corpus call sites; the other seven name the remaining perk triggers
(bridge/tower demolition, Louvre/Pantheon/neighborhood liberation, ambient freeplay destruction, general
stealth kills). This technique generalises to every `cmp eax, <imm32>` after a `FUN_00db7e10` in the binary.

### The game-text table

`DAT_0147db78` is the localization registry. The fetch idiom is a **pair**, not one function:

```
FUN_00db7e10(&sym, sTextID, 1)   // hash the id (FNV-1a above)
FUN_0095e4e0(DAT_0147db78, sym)  // two-level lookup under two critical sections -> entry, or 0
```

`FUN_0095e4e0` tries a primary map (lock at `+0x14`), falls back to a secondary map (lock at `+0x3c`), and on
the fallback path re-resolves through `FUN_0095de20` — consistent with a **base table plus a per-file overlay
loaded by `Cin.LoadGameTextFile`**. The entry's localized string sits at `+0x20` (`HUD.AddToolTip` reads it
at `0x0072d640`); `Sound.PlayTextID` instead gates on `+0x1c` (the VO asset), so **one text entry carries
both the on-screen string and its voice line**.

Text ids are dotted and file-scoped: `"P2M5_Text.TelephoneWire"`, `"MissionNames_Text.A3M2"`,
`"TutorialTip_Text.Weapon_Grenade"`, `"GenericObjective_Text.BAR_Health"`. The prefix before the `.` is the
game-text file; that is what `Cin.LoadGameTextFile` / `Cin.ReleaseGameTextFile` take.

`HUD.AddToolTip` shows the miss path plainly: on lookup failure it substitutes the constant string at
`0x00fe149c` and, if the caller's raw id was non-null, appends it — i.e. **a missing text id renders as a
visible placeholder rather than an empty tooltip**.

### Why the localization bindings live under `Cin`

`Cin.GetLocalizedText`, `Cin.LoadGameTextFile`, `Cin.ReleaseGameTextFile`, `Cin.SubtitlesOn` are registered
into the **`Cin`** (cinematics) table — see their `table` column in the tsv. There is no `Text` table. The
tell is `Cin.SubtitlesOn`: game text entered the engine as *cinematic subtitle* data, the table grew to own
the whole string system, and the name never changed. Scripts use it as a general-purpose facility far outside
cinematics (`Modules/GameTips.lua:54` fetches a tooltip through `Cin.GetLocalizedText`). This is a naming
accident of the C++ registration, not a semantic grouping — do not infer that these calls are
cinematics-only.

### The tutorial system

`DAT_014abdbc` is a **`PblSingleton<WSTutorialManager>`** — *inferred*, not confirmed. The class exists: the
RTTI name `?$PblSingleton@VWSTutorialManager@@` is in
[`../../data/rtti_classes_all.txt`](../../data/rtti_classes_all.txt) (line 1103). But that file is a
**name-only list — it carries no addresses**, so it cannot tie the *name* to *this DAT*, and the vtables
`0x01054600` / `0x01054344` cited in an earlier revision are not sourced from it. What is solid is that all
five `Util.*` tutorial bindings funnel through `DAT_014abdbc` into the `FUN_00a12xxx` block, and that a
singleton of exactly this class exists; the identification is the natural reading of that, not a proven
vtable match. Five `Util.*` bindings drive it:

| binding | method | meaning |
|---|---|---|
| `Util.EnableTutorial` | `FUN_00a12490(id,b)` / `FUN_00a12450(sym,b)` | enable one tutorial, by index **or** by text id |
| `Util.QueueTutorial` | `FUN_00a12xxx` | queue a title+body popup |
| `Util.ClearAllPendingTutorials` | `FUN_00a126d0` | drop the queue |
| `Util.EnableDynamicTutorialSystem` | `FUN_00a12440(b)` | master switch |
| `Util.SetAllDynamicTutorialsToDisabled` | `FUN_00a124b0` | disable all |

There are **at most 49 numbered tutorials** — `Util.EnableTutorial`'s number branch does
`cmp eax, 0x30; ja reject` at `0x0075368e`, so valid ids are `[0, 48]`.

Three *separate* tutorial surfaces exist and should not be conflated:

- **`WSTutorialManager`** (slot-less, a `PblSingleton`) — the dynamic tip queue, driven by `Util.*`.
- **`WSHUDTutorial`** (slot `0x12`) — the on-screen tip text, driven by `HUD.SetTutorialText` /
  `HUD.ClearTutorialText`.
- **`WSHUDAdvancedTutorial`** (slot `0x24`) — the scripted interactive tutorial, driven by
  `HUD.PlayAdvancedTutorial`, with its own callback class `WSAdvancedTutorialCallback`.

Plus **load-screen tutorials** (`WSHUDLoadingScreen`, slot `0x22`), a fourth, driven by
`HUD.AddLoadScreenTutorials`. That binding is the **only table-typed argument in all 78** — it takes a Lua
array of text ids (`RewardsManager.lua:5103` builds `tPart1Table`), walks it with `FUN_006f7d90` /
`FUN_006f7f00`, and hashes each element.

`HUD.SetTutorialText`'s third argument is a **button-glyph text id**: `Saboteur.lua:219` passes
`cSOLDIER_JUMP`, defined as the literal string `"<SJP>"`. Both arg 2 and arg 3 must resolve in the game-text
table or the binding pushes `false` and returns 0 — so the glyph token is itself a localized entry, letting
the tip text swap keyboard/controller glyphs per platform.

### Three unrelated meanings of "filter"

The word appears in three unrelated senses in `lua_bindings.txt`, and conflating them is the obvious trap:

1. **`Filter.New` / `Match` / `Delete`** — an **entity predicate**. `Filter.New` takes an expression string
   in a small boolean mini-language: `Filter.New("Human && Nazi")` (SoldierState_PaperCheckLeader.lua:91),
   `Filter.New("!Nazi")` and `Filter.New("Civilian")` (Checkpoint.lua:275-276). So the grammar has at least
   `&&` and prefix `!` over entity-type/faction atoms. The expression is copied into a **256-byte** buffer
   (`FUN_00db4580` with capacity `0x100` set at `0x007282a7`), which bounds expression length.
2. **`Trigger.AddFilter` / `Trigger.RemoveFilter`** — attach a *sense-1* filter to a trigger volume.
   Excluded from this family; they are the consumers.
3. **`Render.DrunkEffectFilter` / `Render.HeatShimmerFilter`** — full-screen post-process effects. Nothing to
   do with 1 or 2. Excluded.

**`Filter.New` returns a plain number, not a handle.** The body ends `FUN_006f8c70` → `pushnumber`, and
`Filter.Match` checks arg 1 with `FUN_006f7140` (*isnumber*), not `FUN_006f71a0` (*lightuserdata*). The
corpus names the variable `hFilter` (Checkpoint.lua:275), which is misleading Hungarian — it is an id into a
side table, not a salted object handle, so **none of the handle machinery in
[`03-handle-and-object-model.md`](03-handle-and-object-model.md) applies to it**. On a non-string argument
`Filter.New` pushes **nil** and returns 1 — one of the few bindings in the family that reports failure at all.

---

## What this reveals about the shipped game

### Three bindings are shipped stubs, and scripts still call two of them

| binding | body | called from |
|---|---|---|
| `Render.PrintMessage` `0x0073fcb0` | `mov eax,1; ret` (6 bytes) | Experimental/Checkpoint_v2.lua:30, 42, 59, 73, 83, 94 (6 sites) |
| `Cin.SubtitlesOn` `0x0071e950` | `mov eax,1; ret` (6 bytes) | Missions/P1FP_Traitor.lua:909, 1105, 1132, 1140 (4 sites) |
| `Render.PrintMissionText` `0x0073def0` | type-checks arg 1, fetches it, **discards it**, returns | — |

`Render.PrintMessage` was the debug-print binding; it survives in the registration table (so
`Render.PrintMessage("…")` is a valid call that raises nothing) but the retail build compiled its body away.
`Render.PrintMissionText` is the more interesting one: the argument marshalling
(`FUN_006f7160(1)` @`0x73df30`, `FUN_006f7a80(1)` @`0x73df3d`) **survived** while the work did not — the
signature of a body wrapped in a shipping-disabled macro, leaving the `luaL_check`-equivalent prologue behind.

`Cin.SubtitlesOn` is the one with consequences: **P1FP_Traitor.lua explicitly turns subtitles on for a
scripted sequence and off afterwards, and the engine ignores all three calls.**

### `HUD.RemoveMessage` never worked

The clearest defect this family exposes, and it is fully evidenced on both sides:

**Engine side** (`0x0072d790`, from the exe):
```
0072d7ea  call  0x6f7990          ; arg1 = lua_tointeger(L, 1)
0072d7ef  lea   ecx, [eax - 0xa]
0072d7f2  cmp   ecx, 2
0072d7f5  ja    0x72d82b          ; reject unless arg1 ∈ [0xa, 0xc]
0072d7ff  call  0x9bbb20          ; GetHUDObject(arg1)
```
Arg 1 must be a **raw widget slot id in [10, 12]** — `WSHUDToolTipBox`, `WSHUDUpdateBox`, `WSHUDSubtitleBox`.

**Script side** ([`Includes/__UtilFunctions.lua:26-29`](../saboteur-luacd/src/Includes/__UtilFunctions.lua)):
```lua
cOBJECTIVE_TEXT = 5
cTOOLTIP_TEXT   = 6
cUPDATE_TEXT    = 7
cSUBTITLE_TEXT  = 8
```
and [`Modules/SabTaskObjective.lua:1493`](../saboteur-luacd/src/Modules/SabTaskObjective.lua):
```lua
function SabTaskObjective:RemoveHUDText(cType, hMessage)
  if cType == cOBJECTIVE_TEXT then HUD.RemoveObjective(hMessage)
  else                             HUD.RemoveMessage(cType, hMessage) end
end
```

`SabTaskObjective:SetHUDText` stores `MessageType = cType` (6/7/8) at line 1415; `RemoveHUDText` and
`CleanUpHUDText` (line 1510) hand that value straight to `HUD.RemoveMessage`. **6, 7 and 8 all fail the
`[10,12]` range check.** Every `HUD.RemoveMessage` call in the shipped scripts is a silent no-op — the
constants are off by exactly 4 from the widget ids they need to be.

Because §6 of the ABI doc holds — **no binding raises a Lua error, bad args produce a silent `return`** — the
script layer never learns. The visible consequence is that tooltips and update-box text created through
`SabTaskObjective:SetHUDText` are never torn down by the task system; they expire only on their own duration
timer. `HUD.ModifyMessageString` and `HUD.ModifyMessageColor` carry the identical range check (`0x72d8b1`,
`0x72da27`) and have **zero call sites** — consistent with a designer trying them, seeing nothing happen, and
giving up.

*Caveat, stated honestly:* this rests on the decompiled Lua corpus being faithful to retail `LuaScripts.luap`
for those four constants. They are integer constants in a decompiled constant block — about the most reliable
thing a Lua decompiler produces — but I did not re-extract them from the retail container to double-check.

### `HUD.LoadObject(10, …)` corrupts the damage indicator

The factory jump table at `0x009bbfb8` has **`jt[0x04] == jt[0x0a] == 0x009bbbf6`** — id 10 runs the id-4
arm, which allocates `0x46c` bytes and calls the `WSHUDDamageIndicator` ctor. But that ctor self-registers
into **slot 4** (its baked-in id). So `HUD.LoadObject(10, "…")` constructs a *second damage indicator*, points
`mgr->slots[4]` at it (orphaning the first), and leaves slot 10 — the tooltip box — untouched. The correct
ctor for slot 10 is `WSHUDToolTipBox` at `0x007b5280` (`push 0xa; call 0x7b44f0` @`0x007b5299`), which the
factory never calls; only the manager's construct-all routine does.

This is latent, not live: `HUD.LoadObject` has **zero corpus call sites**. But it is reachable from any script
and it is why derivations 2 and 3 above disagree on exactly one slot. **Trust the ctors, not the factory.**

### Arguments the engine silently ignores

The family is full of call sites passing arguments no one reads — direct evidence that
[§6's silent-failure rule](02-marshalling-abi.md) let script/engine drift go unnoticed for the whole project:

| call site | passes | engine reads |
|---|---|---|
| `Act_3_Mission_1.lua:1071` `HUD.ClearGPSCourse("ParisRace")` | 1 arg | **0** — `FUN_0077f940(0,0,2)` is fully hardcoded |
| `Connect_AmbientFP.lua:231` `Util.EnableTutorial(s, true, -1, true)` | 4 args | **2** |
| `Missions/P1FP_Traitor.lua:909` `Cin.SubtitlesOn(true)` | 1 arg | **0** — the body is `mov eax,1; ret` |

`HUD.ClearGPSCourse` is the sharpest: `Act_1_Race.lua:1068` calls it with no argument and
`Act_3_Mission_1.lua:1071` calls it with `"ParisRace"`. **Both do exactly the same thing**, because
`FUN_0077f940(0, 0, 2)`'s operands are immediates. The author of the second call site evidently believed
courses were cleared by name — they are not; there is one global GPS course.

The symmetric hazard is over-reading the corpus. Family 15 inferred `HUD.FlashObjectiveMarker` as `()` from
its call sites; the body *does* type-check a handle at arg 1 (`0x730854`), which looks at first like the
call sites are wrong. They are not — the check guards an **optional** parameter, and the no-handle branch at
`0x73085d` is a real fallback that flashes the current marker. Corpus usage proves *intent*, the body proves
*contract*, and **neither alone is sufficient**: reading only the corpus would have missed the optional
handle, and reading only the type-check would have wrongly condemned two correct call sites.

---

## Corrections to existing docs

1. **[`02-marshalling-abi.md`](02-marshalling-abi.md) §8 — `FUN_00db7e10` is not a string copy.** The doc says
   *"`FUN_00db7e10(uVar4, 1)` — copy out of Lua's ownership"* and presents it as the GC-safety idiom after
   every `FUN_006f7a80`. It is **`WSSymbol` construction**: `FUN_00db7c10` → `FUN_00dc1e20`, the FNV-1a hash
   above. It stores a **4-byte hash**, not a string. The genuine fixed-buffer string copy is a *different*
   function, **`FUN_00db4580(&buf, s)`** (`buf[0]` = capacity, then `strncpy(buf+4, s, cap)`) — used by
   `Filter.New` (`0x007282af`) and `Util.SendPerkMessage`. Both idioms follow `FUN_006f7a80`; they are not
   interchangeable, and the distinction matters because *the hash is reversible and the copy is not*.

2. **[`02-marshalling-abi.md`](02-marshalling-abi.md) §6 — the push-primitive table is incomplete.** Add:
   - **`FUN_006f7020` = `lua_pushboolean(L, b)`** — `__thiscall(this, bool)`, `ret 4`. Used by
     `HUD.SetTutorialText`, `Filter.Match`, `HUD.HasWaypoint`, and every `bOk`-returning row above. Reading it
     requires care: `0x006f7020` is `jmp 0x0043fbc6`, and `0x0043fbc6` is `movzx eax, byte [esp+4]; jmp 0x006f7025`
     — an incremental-link/hot-patch thunk that relocated the function's first instruction. The effective body
     is `movzx eax, byte[esp+4]; mov ecx,[ecx]; push eax; push ecx; call 0x4019b0; add esp,8; ret 4`.
   - **`FUN_006f7080` = push string** (*inferred* — used by `Cin.GetLocalizedText`'s success path; not traced
     to the underlying `lua_pushstring`/`lua_pushlstring`).

3. **[`../symbol_map/hud-ui.md`](../symbol_map/hud-ui.md) — the `FUN_00db7e10` = "LocalizedString_Fetch"
   claim is half right.** `FUN_00db7e10` alone does **not** fetch anything; it only hashes. The fetch is the
   *pair* `FUN_00db7e10` + `FUN_0095e4e0(DAT_0147db78, sym)`. The doc's observed keys (`HUD.Saving`,
   `HUD.Locked`, `"LanguageSelection"`) are genuine — they are the strings being hashed.

4. **[`../symbol_map/hud-ui.md`](../symbol_map/hud-ui.md) — two stated gaps are now closed**: the 41 widget
   classes are individually resolved (table above), and template cases 1, 2, 7, 8, 9, 13, 14, 16–19 are named
   by the `cHTM_*` enum with six independent cross-confirmations. Both should be promoted from *gap* to
   *confirmed*. `FUN_009bbb20` should be named `WSHUDManager::GetHUDObject(id)` and `FUN_009bbb30`
   `WSHUDManager::CreateHUDObject(id, name)` (the factory), `FUN_0079e410` `WSHUDObject::WSHUDObject(id, …)`,
   `FUN_009bd5f0` `WSHUDManager::RegisterHUDObject(this)`.

5. **[`15-family-mission-objective-task.md`](15-family-mission-objective-task.md) — six rows upgrade from
   *inferred* to *confirmed*, none are refuted.** `HUD.AddObjective`, `HUD.ClearAllObjectives`,
   `HUD.ClearAllObjectiveMarkers`, `HUD.SetObjectiveMarker`, `HUD.RemoveObjectiveMarker` and
   `HUD.FlashObjectiveMarker` all now have bodies (from the exe). Family 15's inferences hold up; two gain
   precision — `HUD.AddObjective`'s args 4–7 each accept *number-or-nil*, and `HUD.FlashObjectiveMarker`'s
   handle is *optional* (`()` and `(h)` are both valid, doing different things). Family 15's note that *"no
   return count in this family is verified from a body"* no longer holds for its `HUD.*` rows.

---

## Open questions

1. **`HUD.AddTimer` (`0x0072cb50`) and `HUD.StartMiniGame` (`0x0072e8b0`).** Bodies read; argument *intent*
   unresolved and no corpus call sites to anchor it. `StartMiniGame` takes a string and calls `FUN_007754c0`;
   its relationship to `WSHUDMiniGameValve` (slot 0x14) and `WSHUDDLCMiniGame` (slot 0x1d) is unresolved.
   `HUD.RemoveTimer` deletes the *widget* (`DeleteHUDObject(0xe)`), which sits oddly with `AddTimer` — is
   `AddTimer` really `LoadObject(0xe)` in disguise?

2. **Slots 8, 0x25, 0x26 are empty in both the factory and the construct-all routine.** Are they
   removed widgets (the enum has holes where classes were cut) or filled by DLC? `WSHUDLanguageSelect` (0x1b),
   `WSHUDBladeScreen` (0x1e) and `WSHUDAdvancedTutorial` (0x24) are the precedent for "factory-unreachable but
   real" — and 0x1b was wrongly listed as empty here until the verification pass caught it — so absence from
   the factory proves nothing on its own. Resolving this needs a memory dump of `mgr+0x34` at runtime — x32dbg
   is available in this environment and would settle it in one breakpoint. The honest status of these three is
   **open**, not "empty": no ctor bakes those ids, which is evidence but not proof.

3. **`HUD.ShowMissionTitle` → `WSHUDButtonPrompt` (slot 0x13).** Confirmed from the code but semantically
   weird. Does `WSHUDButtonPrompt` own a generic "banner" sub-movie that both features share? Reading
   `FUN_0076f4e0` (its ctor) and `FUN_0076f9b0` against the Scaleform `Invoke` names would answer it.

4. **The `Filter.New` expression grammar.** Three literals observed (`"!Nazi"`, `"Civilian"`,
   `"Human && Nazi"`). Is there `||`? Parentheses? What is the atom vocabulary? `FUN_006f8c70` is the parser
   entry — unread. The 256-byte buffer is the only hard bound established.

5. **`FUN_0095e4e0`'s two-map structure.** I read it as base-table + overlay (which is what
   `Cin.LoadGameTextFile` / `ReleaseGameTextFile` would imply), but I did not confirm that
   `Cin.LoadGameTextFile` populates the *second* map. `FUN_0095f7f0` / `FUN_0095fbe0` are unread.

6. **`*(int *)(entry + 0x1c)` in `Sound.PlayTextID`.** Gates VO playback. I claim it is the VO asset pointer
   from context (`+0x20` is provably the string). Not verified.

7. **The seven un-called `SendPerkMessage` events.** Cracked from hashes, so the *strings* are certain. But
   none appear at a corpus call site — are they fired from C++, from DLC scripts, or dead? Grepping the DLC
   `.luap` containers under `C:\GOG Games\The Saboteur\DLC` would settle it.

8. **Reproducibility.** The 32 exe-recovered bodies came from throwaway capstone scripts. If this technique is
   going to be load-bearing for other families — and it should be, since ~1/3 of all bindings are `inlined`
   or `jmp` shapes invisible to the Ghidra export — it deserves a real tool alongside
   [`../../tools/dump_lua_registration.py`](../../tools/dump_lua_registration.py): VA → check/fetch ladder →
   candidate signature, plus the hash-dictionary cracker. Both are ~80 lines.
