# Family 15 — Mission / Objective / Checkpoint / Task bindings

> **Verified:** All 73 `impl_va`s re-checked against the Ghidra export (58 present / 15 in gaps, exactly as
> claimed), the 73-binding inclusion rule re-derived from both lists, the 3 assertion strings and 1 dotted
> literal re-confirmed, and ~30 corpus citations spot-checked (all exact). Corrected: `Util.RemoveAvailableMissionMessage`
> has **2** call sites, not zero (removed from the unused list; the 10/73 count is unaffected); the
> `FUN_007411c0` twin is near-identical, not byte-identical; `FUN_009d1520`'s `param_3` is a search-restrict
> flag, not create-if-missing; two section counts were off by one; `Checkpoint.*` is 24 bindings, not 25;
> the entry-ECX caveat generalised to its three sibling stores.

Part of the [engine↔Lua seam series](00-seam-overview.md). Read [`02-marshalling-abi.md`](02-marshalling-abi.md)
first — every signature below is derived with that decoder ring, and the traps it documents
(hidden `this`, silent zero-on-mismatch, `void` meaning nothing) all bite here.

Engine-side subsystem cross-reference: [`../symbol_map/mission-objective.md`](../symbol_map/mission-objective.md)
(`WSTriggerManager`, `WSObjectiveManager`, `WSMissionMessengerManager`), plus
[`../symbol_map/task-managers.md`](../symbol_map/task-managers.md) and [`../symbol_map/hud-ui.md`](../symbol_map/hud-ui.md).

## Inclusion rule (auditable)

A binding is in this family iff the case-insensitive regex `mission|objective|checkpoint|task` matches
**either** its `cpp_symbol` **or** its `lua_name` in [`../../data/lua_registration_map.tsv`](../../data/lua_registration_map.tsv).

That yields **73 bindings**. The same regex over the flat 898-name
[`../../data/lua_bindings.txt`](../../data/lua_bindings.txt) yields the identical 73-name set (verified by set
difference — both directions empty), so the partition is stable regardless of which list you start from.

Deliberate consequences of the rule, called out so the boundary is auditable:

- **Claimed despite ambiguity.** `Combat.SetObjective` / `SetObjectivePath` / `ClearObjective` and the four
  `Squad.*Objective*` bindings are AI-steering calls ("go stand there"), not HUD/mission-tracker calls. They
  match on `objective` and are claimed here. They overlap the AI/combat family — see
  [`../symbol_map/ai-behavior.md`](../symbol_map/ai-behavior.md).
- **`Vehicle.SetRaceCheckPointCallback`** matches on `checkpoint` but is one of ten sibling race callbacks
  (`Vehicle.SetRace*Callback`); the other nine belong to the vehicle/race family. Claimed here, sibling context noted.
- **`Actor.SetMissionCriticalNPC`**, **`Vehicle.SetAsMissionCritical`**, **`Object.SetOnActiveMission`** are
  world-object flags that happen to be mission-scoped. Claimed.
- **`SaveLoad.{Save,Load,Clear}Checkpoint`** are save-system bindings; "checkpoint" here means *savegame
  checkpoint*, an unrelated sense from `Checkpoint.*` (which means *German road checkpoint*). Both claimed;
  **do not conflate them** — see [Two unrelated meanings of "checkpoint"](#two-unrelated-meanings-of-checkpoint).
- **No `Task*` binding exists.** `task` matches nothing in either list. `SabTask*` is a pure-Lua class
  hierarchy (`Modules/SabTask*.lua`) built *on top of* these bindings; it has no C counterpart. This is a
  substantive finding, not an omission — see [The SabTask layer is Lua-only](#the-sabtask-layer-is-lua-only).

## Coverage honesty

| Measure | Count |
|---|---:|
| Bindings in family (M) | **73** |
| Located — VA + table + real Lua name + return contract, byte-level from the tsv | **73 / 73** |
| Body present in the Ghidra decomp export and read → signature derived directly | **58 / 73** |
| Body **absent** from the decomp export (coverage gaps, not my omission) | **15 / 73** |
| └ of those, signature reconstructed from corpus call sites (**inferred**) | 14 |
| └ of those, neither body nor any call site (**open**) | 1 (`Util.InitMissionList`) |
| Carry an EALA assertion string giving source `file:line` (**confirmed** identity) | **3** |
| Carry their namespaced Lua name as a string literal (a *second* anchor class) | **1** |

**On the 15 missing bodies.** These are not "not found" in the usual sense. Every one has a byte-level
`impl_va` from the tsv, but that address falls in a **gap in the Ghidra export**. Example: `HUDAddObjective`
`impl_va=0x0072daa0` sits between a function ending at `0x0072da9a` and the next header at `0x0072dd20` —
real code, never turned into a function by the analysis pass. All six `LuaGlueFunctor0R`/`jmp` bindings in
this family land in such gaps, which is why **no return count in this family is verified from a body** — the
counts below come from the tsv `family` column and corpus usage. Recovering these needs a disassembly pass
over the exe, not more grepping. See [Open questions](#open-questions).

Assertion-string yield is low (3/73), consistent with the seam-wide 12/898 rate. The idiom is an anchor, not a method.

## The table

Signature notation: `n`=number, `s`=string, `b`=boolean, `h`=handle (lightuserdata), `t`=table,
`[...]`=optional. **Every argument is silently optional in practice** — a failed type check falls out of the
`if` with no error (§3/§6 of the ABI doc). "Mandatory" below means *the binding no-ops without it*.

Confidence: **confirmed** = body read in decomp; identity byte-level from tsv; arg order corroborated by a
corpus call site where one exists. **inferred** = no body in export; signature reconstructed from corpus
call sites + tsv family. **open** = neither.

### `Checkpoint.*` — German road checkpoints (24, + one `HUD.*` row)

25 rows: the 24 `Checkpoint.*` bindings, plus `HUD.RemoveCheckpointFromMap`, parked here because it belongs
to this subsystem rather than the objective tray (it is counted in the `Object.*`/… section total, not here).

All setters take the integer checkpoint ID from `Checkpoint.New` as arg 1 (`FUN_006f7140`→`FUN_006f7990`,
i.e. **isnumber→int**, *not* a handle), resolved by `thunk_FUN_0040a136(id)`. Sole consumer:
[`ScriptControllers/CheckpointMgr.lua`](../saboteur-luacd/src/ScriptControllers/CheckpointMgr.lua).

| Binding | Namespaced form | VA | Source (file:line) | Signature | Confidence | Evidence |
|---|---|---|---|---|---|---|
| CheckpointNew | `Checkpoint.New` | `0x0071bd90` | — | `(hController) -> nCheckpointID` | inferred | no body (gap); tsv `LuaGlueFunctor0R`/`jmp`; CheckpointMgr.lua:6 |
| CheckpointKill | `Checkpoint.Kill` | `0x0071a6a0` | — | `(nID)` | confirmed | body; `FUN_00897e40`→`FUN_0080a6a0`→`FUN_00db41e0` (free); CheckpointMgr.lua:79 |
| CheckpointSetCheckZone | `Checkpoint.SetCheckZone` | `0x0071a730` | — | `(nID, sZoneName)` | confirmed | body; `FUN_00a0ffa0`→`FUN_0080ab70`; CheckpointMgr.lua:7 |
| CheckpointSetExitZone | `Checkpoint.SetExitZone` | `0x0071a7e0` | — | `(nID, sZoneName)` | confirmed | body; `FUN_00a0ffa0`→`FUN_0080aba0`; CheckpointMgr.lua:8 |
| CheckpointSetInteriorRestrictedArea | `Checkpoint.SetInteriorRestrictedArea` | `0x0071af80` | — | `(nID, sZoneName)` | confirmed | body; `FUN_00a0ffa0`→`FUN_0080ab10`; CheckpointMgr.lua:35 |
| CheckpointSetLinkedEnterZone | `Checkpoint.SetLinkedEnterZone` | `0x0071ae20` | — | `(nID, sZoneName)` | confirmed | body; `FUN_00a0ffa0`→`FUN_0071a650`; CheckpointMgr.lua:29 |
| CheckpointSetLinkedExitZone | `Checkpoint.SetLinkedExitZone` | `0x0071aed0` | — | `(nID, sZoneName)` | confirmed | body; `FUN_00a0ffa0`→`FUN_0071a670`; CheckpointMgr.lua:32 |
| CheckpointSetDoor | `Checkpoint.SetDoor` | `0x0071aa70` | — | `(nID, hSwitchPt)` | confirmed | body; arg2 `FUN_006f71a0`→`FUN_0067c0a0`→`FUN_0080abd0`; CheckpointMgr.lua:88 |
| CheckpointAddSearchlight | `Checkpoint.AddSearchlight` | `0x0071b480` | — | `(nID, hSearchlight)` | confirmed | body; arg2 handle→`FUN_0067c0a0`, vtable+0x20 then +0x3c→`FUN_0080ac50`; CheckpointMgr.lua:96 |
| CheckpointSetDoorman | `Checkpoint.SetDoorman` | `0x0071a930` | — | `(nID, sName)` | confirmed | body; `FUN_0080ae00`; CheckpointMgr.lua:20 |
| CheckpointSetPaperChecker | `Checkpoint.SetPaperChecker` | `0x0071a890` | — | `(nID, sName)` | confirmed | body; `FUN_0080ad90`; CheckpointMgr.lua:17 |
| CheckpointSetVehicleChecker | `Checkpoint.SetVehicleChecker` | `0x0071a9d0` | — | `(nID, sName)` | confirmed | body; `FUN_0080ae70`; CheckpointMgr.lua:23 |
| CheckpointSetOneSided | `Checkpoint.SetOneSided` | `0x0071b030` | — | `(nID, bOneSided)` | confirmed | body; `FUN_0080a3e0`; CheckpointMgr.lua:37 |
| CheckpointSetIgnorePedestrians | `Checkpoint.SetIgnorePedestrians` | `0x0071ac50` | — | `(nID, b)` | confirmed | body; sets bit `0x10` @ `cp+0xb8`; CheckpointMgr.lua:14 |
| CheckpointSetIgnoreVehicles | `Checkpoint.SetIgnoreVehicles` | `0x0071abb0` | — | `(nID, b)` | confirmed | body; sets bit `0x08` @ `cp+0xb8`; CheckpointMgr.lua:15 |
| CheckpointSetPapers | `Checkpoint.SetPapers` | `0x0071ab10` | — | `(nID, sPapers)` | confirmed | body; hash → `cp+0x40`; CheckpointMgr.lua:12 |
| CheckpointSetRequiredVehicle | `Checkpoint.SetRequiredVehicle` | `0x0071ace0` | — | `(nID, sVehicle)` | confirmed | body; hash → `cp+0x44`; CheckpointMgr.lua:10 |
| CheckpointSetLinkedCheckpoint | `Checkpoint.SetLinkedCheckpoint` | `0x0071ad80` | — | `(nID, sName)` | confirmed | body; hash → `cp+0x70`; CheckpointMgr.lua:26 |
| CheckpointSetHaltConv | `Checkpoint.SetHaltConv` | `0x0071b0c0` | — | `(nID, sConv)` | confirmed | body; hash → `cp+0x84`; CheckpointMgr.lua:41 |
| CheckpointSetPapersPleaseConv | `Checkpoint.SetPapersPleaseConv` | `0x0071b160` | — | `(nID, sConv)` | confirmed | body; hash → `cp+0x88`; CheckpointMgr.lua:44 |
| CheckpointSetPlayerHasPapersConv | `Checkpoint.SetPlayerHasPapersConv` | `0x0071b200` | — | `(nID, sConv)` | confirmed | body; hash → `cp+0x8c`; CheckpointMgr.lua:47 |
| CheckpointSetPlayerDoesNotHavePapersConv | `Checkpoint.SetPlayerDoesNotHavePapersConv` | `0x0071b2a0` | — | `(nID, sConv)` | confirmed | body; hash → `cp+0x90`; CheckpointMgr.lua:50 |
| CheckpointSetPaperCheckPassConv | `Checkpoint.SetPaperCheckPassConv` | `0x0071b340` | — | `(nID, sConv)` | confirmed | body; hash → `cp+0x94`; CheckpointMgr.lua:53 |
| CheckpointSetPaperCheckFailConv | `Checkpoint.SetPaperCheckFailConv` | `0x0071b3e0` | — | `(nID, sConv)` | confirmed | body; hash → `cp+0x98`; CheckpointMgr.lua:56 |
| HUDRemoveCheckpointFromMap | `HUD.RemoveCheckpointFromMap` | `0x0072e920` | — | `(x, y, z)` | confirmed | body; three `FUN_006f7950`→`FUN_00731560`; **zero corpus call sites** |

### `HUD.*` — the objective tray (12)

Objectives are keyed by an **integer objective ID**, not a handle (see
[Objectives and focus points are integer IDs](#objectives-and-focus-points-are-integer-ids-that-lua-calls-handles)).

| Binding | Namespaced form | VA | Source (file:line) | Signature | Confidence | Evidence |
|---|---|---|---|---|---|---|
| HUDAddObjective | `HUD.AddObjective` | `0x0072daa0` | — | `(eIcon, sTextID, nPriority [, nParentID [, bOptional [, n]]]) -> nObjID` | inferred | no body (gap); tsv `…0R`/`jmp`; SabTaskObjective.lua:1375; Act_1_Farm.lua:224 |
| HUDRemoveObjective | `HUD.RemoveObjective` | `0x0072e120` | — | `(nObjID [, bImmediate])` | confirmed | body; `FUN_009d1870(id, bImmediate?3:4, _DAT_00f7df54)`; SabTaskObjective.lua:1504 |
| HUDSetObjectiveText | `HUD.SetObjectiveText` | `0x0072e080` | — | `(nObjID, sTextID [, nNumVars, v1, v2, v3])` | confirmed | body; `thunk_FUN_00441da9(buf, s, L, 3)` then `FUN_009d1b60`; SabTaskObjective.lua:177 |
| HUDSetObjectiveStatus | `HUD.SetObjectiveStatus` | `0x0072df90` | — | `(nObjID, nStatus)` | confirmed | body; `FUN_009d1ae0`; **zero corpus call sites** |
| HUDKeepObjectivesVisible | `HUD.KeepObjectivesVisible` | `0x0072e010` | — | `(b)` | confirmed | body; byte @ `DAT_014a9ddc+0xe75`; P1FP_Traitor.lua:940 |
| HUDShowMissionTitle | `HUD.ShowMissionTitle` | `0x0072e440` | — | `(sTitleID [, sSubtitleID])` | confirmed | body; screen `FUN_009bbb20(0x13)`; SabTaskMission.lua:400 |
| HUDClearAllObjectives | `HUD.ClearAllObjectives` | `0x00731430` | — | `()` | inferred | no body (gap); SabTask.lua:1652 |
| HUDClearAllObjectiveMarkers | `HUD.ClearAllObjectiveMarkers` | `0x007313b0` | — | `()` | inferred | no body (gap); SabTask.lua:1985 |
| HUDSetObjectiveMarker | `HUD.SetObjectiveMarker` | `0x007303d0` | — | `(h, nMMIcon, nBlipType, b, b, bRenderMinimapEdge [, fHeight [, mmStarterIcon]]) -> bSuccess` | inferred | no body (gap); tsv `…0R`/`jmp`; SabTaskObjective.lua:471; InteriorManager.lua:662 |
| HUDShowObjectiveMarker | `HUD.ShowObjectiveMarker` | `0x00730710` | — | `(hMarker, bMiniMap, bWorld)` | confirmed | body; tries `FUN_0067c0a0` **and** `FUN_00498440`→`FUN_0078bac0`/`FUN_0078ba40`; SabTask.lua:1405 |
| HUDRemoveObjectiveMarker | `HUD.RemoveObjectiveMarker` | `0x00730610` | — | `(h)` | inferred | no body (gap); tsv `…0R`/`jmp`; SabTaskObjective.lua:759 |
| HUDFlashObjectiveMarker | `HUD.FlashObjectiveMarker` | `0x00730810` | — | `()` | inferred | no body (gap); tsv `…0R`/`jmp`; Act_1_BarFight.lua:54 |

### `Util.*` — mission lifecycle, messages, debug list (15)

| Binding | Namespaced form | VA | Source (file:line) | Signature | Confidence | Evidence |
|---|---|---|---|---|---|---|
| NewMission | `Util.NewMission` | `0x0074c590` | — | `(sName, sScript) -> hMission` | inferred | no body (gap); tsv `…0R`/`jmp`; France.lua:9; Saboteur.lua:552 |
| KillMission | `Util.KillMission` | `0x00758a80` | — | `(hMission)` | confirmed | body; map lookup then vtable`+0x40`, gated on `FUN_0044a090()==0`; **zero corpus call sites** |
| MissionComplete | `Util.MissionComplete` | `0x0075b170` | — | `()` | inferred | no body (gap); SabTaskMission.lua:493 |
| RecordMissionComplete | `Util.RecordMissionComplete` | `0x0075b3e0` | — | `()` | inferred | no body (gap); RewardsManager.lua:5236 |
| MissionFail | `Util.MissionFail` | `0x00752790` | — | `([sMessageID])` | confirmed | body; hash→`FUN_009bbb20(0x22)+0x50c`; `FUN_009bc2a0(10)`; SabTask.lua:1012; SabTaskMission.lua:642 |
| SetPlayerCurrentMission | `Util.SetPlayerCurrentMission` | `0x0074eb20` | — | `(sMissionNameID)` | confirmed | body; hash→`DAT_01240328+0x2154`, validated by `FUN_0095e4e0`; `""`→0 clears is *inferred* (corpus-only, see Q8); SabTaskMission.lua:305, :425 |
| SetPlayerLastCompletedMission | `Util.SetPlayerLastCompletedMission` | `0x0074ebb0` | — | `(sMissionNameID)` | confirmed | body; hash→`DAT_01240328+0x2150`; SabTaskMission.lua:542 |
| SetLastMissionChatter | `Util.SetLastMissionChatter` | `0x0074ec40` | — | `(sChatter)` | confirmed | body; hash→`DAT_01240328+0x220c`; RewardsManager.lua:5280 |
| SetNumMissions | `Util.SetNumMissions` | `0x007532e0` | — | `(n)` | confirmed | body; `DAT_014aadcc+0x198`; RewardsManager.lua:55 |
| AddMissionMessage | `Util.AddMissionMessage` | `0x00757cb0` | — | `(sMission, sConv, sMessage, nType, nPriority [, nDelay [, sBlockingSpore [, sOnAttempt [, sOnDelivered [, sOnRead [, tSelf [, tUser]]]]]]])` | confirmed | body (12 args, `FUN_006f6970`-gated); SabTaskObjectiveInteract.lua:615 |
| DisplayMissionMessage | `Util.DisplayMissionMessage` | `0x007522a0` | — | `(sMessage, nType, sConvVO [, sCallback [, tSelf [, tUser]]])` | confirmed | body; `FUN_009d0450`; P1FP_Traitor.lua:867 |
| RemoveAvailableMissionMessage | `Util.RemoveAvailableMissionMessage` | `0x007520d0` | — | `(sName)` | confirmed | body; `FUN_009cf770`; RewardsManager.lua:5370; SabTaskObjectiveInteract.lua:431 |
| AddMissionFolder | `Util.AddMissionFolder` | `0x00759de0` | — | `(sKey, sParentName)` | inferred | no body (gap); GlobalMissionFile.lua:105 |
| AddMissionToFolder | `Util.AddMissionToFolder` | `0x00759e20` | — | `(sValue, sParentName)` | inferred | no body (gap); GlobalMissionFile.lua:108 |
| InitMissionList | `Util.InitMissionList` | `0x00759da0` | — | **unknown** | **open** | no body (gap); **zero corpus call sites**; only tsv identity |

### `Combat.*` / `Squad.*` — AI objective steering (7)

| Binding | Namespaced form | VA | Source (file:line) | Signature | Confidence | Evidence |
|---|---|---|---|---|---|---|
| SetObjective | `Combat.SetObjective` | `0x00721920` | — | `(hActor, hTarget [, b [, fRange [, b]]])` | confirmed | body; `FUN_008d16b0`; default `fRange=DAT_00f7ac80`; Act_3_Mission_3.lua:1524 (51 sites) |
| SetObjectivePath | `Combat.SetObjectivePath` | `0x00721a90` | — | `(hActor, hPath [, b [, fRange]])` | confirmed | body; `FUN_0082e310`→`FUN_008cfe80`; Paris_3_Mission_1.lua:2138 |
| ClearObjective | `Combat.ClearObjective` | `0x00721be0` | — | `(hActor)` | confirmed | body; `FUN_008d16b0(0,0,DAT_00f7ac80,0)`; Paris_1_Mission_6.lua:1331 |
| AddSquadObjective | `Squad.AddObjective` | `0x00745b40` | — | `(sSquadName, hTarget [, fWeight=1.0])` | confirmed | body; `thunk_FUN_0051db09`→`FUN_008a4f80`; **zero corpus call sites** |
| RemoveSquadObjective | `Squad.RemoveObjective` | `0x00745c30` | — | `(sSquadName, hTarget)` | confirmed | body; `FUN_008a5d20`; **zero corpus call sites** |
| ClearSquadObjectives | `Squad.ClearObjectives` | `0x00745cf0` | — | `(sSquadName, hIgnored)` | confirmed | body; **requires arg2 handle but never reads it**; `FUN_008a3f80()`; **zero corpus call sites** |
| DefendSquadObjectives | `Squad.DefendObjectives` | `0x00745eb0` | — | `(sSquadName)` | confirmed | body; gated on `squad+0xac > 0`→`thunk_FUN_00539e21(2,1)`; **zero corpus call sites** |

### `Object.*` / `Actor.*` / `Vehicle.*` / `FocusPt.*` / `Render.*` / `SaveLoad.*` (14, + `HUD.RemoveCheckpointFromMap` = 15)

| Binding | Namespaced form | VA | Source (file:line) | Signature | Confidence | Evidence |
|---|---|---|---|---|---|---|
| MissionTeleportPlayerToLocator | `Object.PlayerTeleportToLocator` | `0x0073ab70` | **`Script\Interface\Object.cpp:652`** (`0x28c`) | `(hLocator [, b [, b]] [, sCallback [, tSelf [, tUser]]])` | **confirmed** | assertion string; body; Act_1_BarFight.lua:1453 (37 sites) |
| MissionTeleportPlayerToPos | `Object.PlayerTeleportToPos` | `0x0073a930` | **`Script\Interface\Object.cpp:592`** (`0x250`) | `(x, y, z, heading [, b [, b]] [, sCallback, tSelf [, tUser]])` | **confirmed** | assertion string; body; Act_1_GetCaught.lua:306 |
| SetOnActiveMission | `Object.SetOnActiveMission` | `0x007382f0` | — | `(hObj, bActive [, bNoWitnessEligible])` | confirmed | body; vtable`+0x1e8`→`thunk_FUN_01622420`; SabTaskMission.lua:335 |
| SetMissionCriticalNPC | `Actor.SetMissionCriticalNPC` | `0x00715150` | — | `(hActor, bCritical)` | confirmed | body; `FUN_00498440`→vtable`+0x1c`→bit `0x20` @ `+0x1d4`; Act_1_GetCaught.lua:1365 |
| SetAsMissionCritical | `Vehicle.SetAsMissionCritical` | `0x00763d00` | — | `(hVehicle, bCritical)` | confirmed | body; vtable`+0x194`→`FUN_007649a0`/`FUN_00765770` |
| SetRaceCheckPointCallback | `Vehicle.SetRaceCheckPointCallback` | `0x00762b10` | — | `(sCallbackName [, tSelf [, tUser]])` | **confirmed** | body; **literal `"Vehicle.SetRaceCheckPointCallback"` in the clear**; `FUN_007627d0`→`FUN_008f9a30`; **zero corpus call sites** |
| FocusPtSetObjective | `FocusPt.SetObjective` | `0x00728ca0` | — | `(nFocusID, nObjectiveID)` | confirmed | body; **both args isnumber**; `FUN_00992f70`, `FUN_009d1520`, store @ `+0xec`; SabTaskObjective.lua:1433 |
| FocusPtLoadMissionPictures | `FocusPt.LoadMissionPictures` | `0x00728c40` | — | `(sFile)` | confirmed | body; `FUN_00992f50`; **no `FUN_00db7e10` copy-out** (see note); SabTaskMission.lua:355 |
| FocusPtUnloadMissionPictures | `FocusPt.UnloadMissionPictures` | `0x00729ae0` | — | `()` | inferred | no body (gap); SabTaskMission.lua:412 |
| PrintMissionText | `Render.PrintMissionText` | `0x0073def0` | — | `(s)` — **no-op stub** | confirmed | body; fetches arg 1 and **discards it**; **zero corpus call sites** |
| ShowMissionComplete | `Render.ShowMissionComplete` | `0x0073df50` | — | `([nDisplayID])` | confirmed | body; screen `FUN_009bbb20(0x1a)`, `piVar3[0x15]=id` |
| SaveLoadSaveCheckpoint | `SaveLoad.SaveCheckpoint` | `0x007419d0` | — | `(tSelf [, hLocator])` | confirmed | body; arg1 **table**, arg2 optional handle; SabTask.lua:1822 |
| SaveLoadLoadCheckpoint | `SaveLoad.LoadCheckpoint` | `0x00741e90` | **`Script\Interface\SaveLoad.cpp:142`** (`0x8e`) | `()` — **no-op stub** | **confirmed** | assertion string; 51-byte body = logger + `return 1`; Act_1_Race.lua:549 |
| SaveLoadClearcheckpoint | `SaveLoad.ClearCheckpoint` | `0x00741ed0` | — | `()` | inferred | no body (gap); SabTaskMission.lua:279 |

(`HUD.RemoveCheckpointFromMap` is listed in the [`Checkpoint.*`](#checkpoint---german-road-checkpoints-25) table above.)

## How the subsystem actually works

### Two unrelated meanings of "checkpoint"

The regex conflates two subsystems that share a word and nothing else:

- **`Checkpoint.*` (24 bindings: `0x0071a6a0`–`0x0071b480`, plus `Checkpoint.New` out of band at `0x0071bd90`)** — German road checkpoints: the papers-check
  encounter. Driven entirely by `CheckpointMgr.lua` from a SMED-authored `SMEDTable`.
- **`SaveLoad.{Save,Load,Clear}Checkpoint` (3 bindings, `0x007419d0`–`0x00741ed0`)** — savegame restore points.

They share no code, no data, and no ID space. Anyone grepping "checkpoint" in this engine will hit both.

### Checkpoints are integer IDs; almost everything else is a handle

This is the family's sharpest departure from the seam-wide handle idiom documented in
[`03-handle-and-object-model.md`](03-handle-and-object-model.md). `Checkpoint.New` returns an **integer**, and
**all 23 other `Checkpoint.*` bindings** (`Kill` plus the 22 setters — verified individually, no exceptions)
type-check arg 1 with `FUN_006f7140` (isnumber) and fetch with `FUN_006f7990` (int), then
resolve it with `thunk_FUN_0040a136(id)` — a thunk into `FUN_0089ad26`, *not* the salted-handle path
(`FUN_004436f0` / `FUN_00498440` / `FUN_0067c0a0`) that the rest of the seam uses.

Consequence: **the handle family's two liveness gates do not apply to checkpoints.** No generation counter,
no weak-ref re-check. A stale checkpoint ID is an ordinary integer with no way to detect staleness, and
`CheckpointMgr` guards this only by scoping the ID to one controller's `OnEnter`/`OnExit` lifetime
(CheckpointMgr.lua:6, :79). Because `FUN_006f7140` is the *coercing* isnumber check (ABI §3),
`Checkpoint.Kill("7")` is accepted.

Handles do appear in the family, but only as arg 2 and only for world objects:
`Checkpoint.SetDoor(nID, hSwitchPt)` and `Checkpoint.AddSearchlight(nID, hSearchlight)`, both fetched with
`FUN_006f6ec0` and resolved through `FUN_0067c0a0` (CheckpointMgr.lua:88, :96).

### The checkpoint struct, mapped by its setters

Because each `Set*Conv`-style binding is a one-line store, the 25 bindings collectively map a chunk of the
checkpoint object. Every string here is **hashed by `FUN_00db7e10` and stored as a 4-byte ID** — the raw
characters are not retained:

| Offset | Set by | Holds |
|---|---|---|
| `+0x40` | `SetPapers` | papers ID |
| `+0x44` | `SetRequiredVehicle` | required-vehicle ID |
| `+0x70` | `SetLinkedCheckpoint` | linked checkpoint name |
| `+0x84` | `SetHaltConv` | conversation ID |
| `+0x88` | `SetPapersPleaseConv` | conversation ID |
| `+0x8c` | `SetPlayerHasPapersConv` | conversation ID |
| `+0x90` | `SetPlayerDoesNotHavePapersConv` | conversation ID |
| `+0x94` | `SetPaperCheckPassConv` | conversation ID |
| `+0x98` | `SetPaperCheckFailConv` | conversation ID |
| `+0xb8` bit `0x10` | `SetIgnorePedestrians` | flag |
| `+0xb8` bit `0x08` | `SetIgnoreVehicles` | flag |

**False friend, resolved.** ABI §10 warns that `*(int *)(obj + 0xb8) == 9` is *not* a Lua type tag and is an
"engine state enum, meaning open" — but that warning is about the **actor** object reached via
`FUN_00498440`→vtable`+0x1c`→`+0x140`→`+0xb8`. The `+0xb8` here is on the **checkpoint** object reached via
`thunk_FUN_0040a136`, and it is a **bitfield**, not an enum. Different struct, same offset, unrelated meaning.
Do not merge these two facts.

The six consecutive conversation slots (`+0x84`…`+0x98`) are the whole papers-check dialogue tree laid out in
authored order, and `CheckpointMgr.lua:40-57` sets each only `if self.SMEDTable.<X>Conv` — so unset slots keep
whatever the constructor left, which the decomp does not show. Zone names (`SetCheckZone`, `SetExitZone`,
`SetInteriorRestrictedArea`, `SetLinkedEnterZone`, `SetLinkedExitZone`) do **not** go into the struct as
hashes; they resolve through `FUN_00a0ffa0`, which guards on `DAT_01212044` — the `WSTriggerManager` critical
section already pinned in [`../symbol_map/mission-objective.md`](../symbol_map/mission-objective.md). **Checkpoint zones are `WSTriggerRegion`s**, which is
how a checkpoint knows the player entered it.

### Objectives and focus points are integer IDs that Lua calls "handles"

`HUD.AddObjective` returns an integer objective ID. The four HUD objective mutators
(`FUN_009d1870`, `FUN_009d1ae0`, `FUN_009d1b60`, `FUN_009d1520`) share one shape: `__thiscall(hudMgr, int id, …)`
that walks **two intrusive linked lists** — heads at `mgr+0xe64` and `mgr+0xe54` — comparing `*(int*)(node+0x10) == id`.
So the objective registry is two lists (plausibly active + pending/free; the split is **open**) keyed by an
int at node`+0x10`, with **O(n) lookup per call**.

The Lua corpus names these values `hMessage`, `hHUDObjective`, `FocusHandle` — but they are **not handles**.
Proof, independent of the decomp: `SabTaskObjective.lua:1432` tests
`messagehandle ~= -1 and tFocusTable.FocusHandle ~= -1`. `-1` is a sentinel no lightuserdata could ever equal,
and the engine side type-checks both `FocusPt.SetObjective` args with `FUN_006f7140` (isnumber). **The `h`
prefix in this corpus is unreliable** — trust the type check, not the Hungarian notation.

### Mission messages ride the messenger manager

`Util.AddMissionMessage` is the widest binding in the family — **12 arguments**, dispatched on
`FUN_006f6970()` with each optional slot individually nil-checked (`FUN_006f7100`) before its type check, so
callers may pass `nil` in a middle slot. It builds a record via `FUN_009ce850`, keyed by the arg-1 mission
name hash and deduplicated by `FUN_009cf6a0`, and commits with `FUN_009cf710`. Those helpers sit in the
`0x009c*`/`0x009d*` band that [`../symbol_map/mission-objective.md`](../symbol_map/mission-objective.md) pins as
`WSMissionMessengerManager` (`FUN_009cfd50` `SpawnMessenger`, `FUN_009d0100` `AttemptDelivery`) — i.e. **the
courier NPC who physically hands Sean a note is the same system as the mission-message queue.**
`Util.DisplayMissionMessage` (`FUN_009d0450`) is the immediate no-courier path.

Arguments 8/9/10 are **callback name strings**, matching ABI §10: registration takes a name, never a function.

### Retail contains at least two dead bindings

- **`SaveLoad.LoadCheckpoint` (`0x00741e90`) does nothing.** Its entire 51-byte body loads the
  `{file, name, line}` triple `SaveLoad.cpp:142`, calls the tracer (`thunk_FUN_0162c850`), and returns 1. The
  tracer early-outs unless `*(byte *)(this + 0x4b848) & 2` — a debug channel. There is no load call.
  A **near-identical** twin at `FUN_007411c0` (same string, same line, `callers=[]`) is dead code — not
  byte-identical: it is 46 bytes to `FUN_00741e90`'s 51 and falls through `void` instead of `return 1`.
  **This matters for game logic**: `Act_1_Race:Reboot()` (Act_1_Race.lua:549) is the sole caller — reached
  from `MissedRace` via a 3-second timer — and it is a no-op. Whatever "reboot the race" was meant to do,
  retail does not do it.
- **`Render.PrintMissionText` (`0x0073def0`)** type-checks arg 1, calls `FUN_006f7a80(1)`, and **discards the
  result**. No corpus call sites. A debug leftover.

Note the tracer triple is **not an assertion** in the "check failed" sense: it sits on the success path and is
channel-gated. It names the call being made. (ABI §9 makes the same point.)

### The `SabTask` layer is Lua-only

There is no `Task*` binding. The `SabTask` / `SabTaskMission` / `SabTaskObjective` / `SabTaskObjectiveInteract`
hierarchy is authored entirely in Lua and composes the primitives above: `SabTaskMission:_MissionComplete`
(SabTaskMission.lua:489-497) calls `Util.MissionComplete()`, then schedules
`Render.ShowMissionComplete` via `EVENT_Timer`, then consults `RewardsManager`. The engine exposes
*mechanism* (add an objective row, set its text, flag a vehicle) and Lua supplies **all** *policy* (what an
objective is, quotas, optional-ness, completion). The `SabTaskObjective*` classes are the intended usage
pattern the assignment points at, and they are the only thing that makes the flat HUD tray behave like a
mission system.

### Whole tables that shipped unused

Four `Squad.*` objective bindings exist, are fully implemented in C, and have **zero call sites across all 321
Lua sources**. Ditto `Util.KillMission`, `HUD.SetObjectiveStatus`,
`HUD.RemoveCheckpointFromMap`, `Render.PrintMissionText`, `Vehicle.SetRaceCheckPointCallback`, and
`Util.InitMissionList` — 10 of 73 (13.7%) are registered but never called by shipped script. Squad-level AI
objectives look like a designed-and-abandoned feature: the C works, the scripts steer individuals with
`Combat.SetObjective` (51 sites) instead.

`Squad.ClearObjectives` also carries a real quirk: it demands a handle in arg 2 (`FUN_006f71a0`) and **never
reads it**. Passing only the squad name makes the call silently no-op. That is exactly the kind of bug an
unused binding keeps.

## Open questions

1. **The 15 missing bodies.** Their `impl_va`s fall in gaps in the Ghidra export. This includes **every**
   `LuaGlueFunctor0R` binding in the family, so **no return count here is verified against a body** — most
   importantly `Checkpoint.New`, `HUD.AddObjective`, and `HUD.SetObjectiveMarker`, whose returns are asserted
   only from corpus usage. Resolving this needs a disassembly pass over `Saboteur.exe` at those addresses.
2. **`Util.InitMissionList` is entirely open** — no body, no call site. Only its registration is known.
3. **`Util.AddMissionMessage` arg 9 (`sOnDelivered`) may be dropped.** In `FUN_00757cb0` the arg-9 callback
   record is allocated (`FUN_00626e00`) into `puVar5`, then `puVar5` is **reset to 0** before the arg-10
   block reuses it; the commit stores `puVar6[6]=puVar8` (arg 8), **`puVar6[7]=0`**, `puVar6[8]=puVar5`
   (arg 10). Read literally, `SabTaskObjectiveInteract:OnDeliveredMessage` (defined at
   SabTaskObjectiveInteract.lua:648 and passed at :615) can never fire. **Inferred, and I do not trust it
   yet**: Ghidra coalesces variables, the function carries three "Removing unreachable block" warnings, and
   the arg-9 slot may be committed on a path the decompiler dropped. Needs disassembly to settle.
4. **What are the two objective lists?** `mgr+0xe64` and `mgr+0xe54` are both searched, `+0xe64` first.
   Active vs. pending is a guess. `FUN_009d1520`'s `param_3` is a **search-restrict flag, not create-if-missing**
   (the function is a pure lookup — it allocates nothing): a non-zero `param_3` searches `+0xe64` only, while
   `param_3 == 0` falls through to `+0xe54` as well. `FocusPt.SetObjective` passes 0, so it searches both.
   That the caller can opt out of `+0xe54` is a hint the two lists differ in kind, but it does not say how.
5. **`HUD.RemoveObjective`'s mode constants.** `bImmediate` selects `3` vs `4` into `FUN_009d1870`'s
   `param_2`. The enum is unnamed and its other values are unexplored.
6. **`Checkpoint.*` conversation slot defaults.** `CheckpointMgr` sets `+0x84`…`+0x98` conditionally; the
   constructor's initialisation of unset slots is not visible in the binding bodies.
7. **`FocusPt.LoadMissionPictures` does not copy its string out.** Every other string-taking binding in the
   family pairs `FUN_006f7a80` with `FUN_00db7e10` (ABI §8). `FUN_00728c40` passes the raw
   `lua_tolstring` pointer straight to `FUN_00992f50`. Either `FUN_00992f50` copies internally, or this is a
   latent GC-lifetime bug. Unresolved.
8. **The entry-ECX stores.** The decomp shows `*(DAT_01240328+0x2154) = param_1` in
   `Util.SetPlayerCurrentMission`, where `param_1` is entry-ECX — a decompiler artifact; the value is really
   the `FUN_00db7e10` hash. The **same artifact appears in three siblings** and the caveat applies to each
   equally: `Util.SetPlayerLastCompletedMission` (`+0x2150`), `Util.SetLastMissionChatter` (`+0x220c`), and
   `Checkpoint.SetRequiredVehicle` (`cp+0x44`, where Ghidra renders it `unaff_ESI`). The `""`→0-clears
   behaviour (SabTaskMission.lua:425) corroborates the reading, but it is **not visible in any of these
   bodies** — the register flow is inferred throughout.
9. **`thunk_FUN_0040a136` → `FUN_0089ad26`** is the checkpoint ID→object resolver. Whether it is an array
   index, a slot map, or a list walk is unexamined — it decides whether stale checkpoint IDs alias live
   checkpoints.
