# Family: Utility / SaveLoad / Object / Trigger

> **Verified:** all 253 VAs, C++ symbols and tables re-checked against `data/lua_registration_map.tsv` and
> the decomp (0 mismatches; the 51 "open" rows are genuinely absent, split 26 `inlined` / 25 `jmp` as
> claimed); all 5 assertion anchors re-read and byte-exact (line numbers `0xfc`=252, `0x8e`=142,
> `0x16e6`=5862, `0x28c`=652, `0x250`=592); `Util.Assert`, `CreateEvent` + both delegates, `SaveLoad`
> float/table, `FUN_0099bc00`'s 7 callers and the five field accessors' full name vocabulary all confirmed;
> corpus citations spot-checked and real. **Corrected:** the `require` evidence (29 of 321 files, not
> "every script"), the `Trigger` counts (9 `Create*`, not 13; 23 of 23 handle-first, not 20; **three** `0R`
> members, not two — `Trigger.WaitFor` returns a trigger ID, and **58 of its 309 direct call sites bind
> that return value**; *clarified 2026-07-24, the earlier "at 58 call sites" read as a call count*), the `vtable+0xdb8`
> misreading, and "no binding raises a Lua error" downgraded from asserted fact to inferred per
> [02](02-marshalling-abi.md).

The general-purpose end of the seam: object lifecycle (`Object.*`), the **event system** (`Util.CreateEvent`
and friends — the script layer's only scheduler), volume/zone triggers (`Trigger.*`), the **save/load
stream** (`SaveLoad.*`), and the grab-bag of world queries and debug hooks that make up the 173-entry
`Util` table.

Read [02-marshalling-abi.md](02-marshalling-abi.md) first — this document assumes the decoder ring and does
not restate it. Identity (Lua name, table, VA, return family) comes from
[`data/lua_registration_map.tsv`](../../data/lua_registration_map.tsv), which is byte-level read from the
exe; **`data/lua_bindings.txt` lists C++ symbols and is not callable Lua**.

## Inclusion rule (auditable)

A binding is in this family **iff its `table` column in the registration map is one of `Util`, `Object`,
`Trigger`, `SaveLoad`.** That is the whole rule — it is mechanical, and it partitions cleanly because the
`table` column is derived from the registration stanza itself, not from name shape.

Consequences worth stating out loud, because the assignment's scope was phrased by name-prefix:

- **`Event*` and `Locator*` are not tables.** There is no `Event` table and no `Locator` table in the
  registration map. The event API lives in `Util` (`Util.CreateEvent`, `Util.KillEvent`, `Util.UserEvent`,
  `Util.KillAllEvents`, `Util.DumpEvents`); the two locator bindings live in `Object`
  (`Object.LocatorSetParent`, `Object.PlayerTeleportToLocator`). Both are claimed here.
- **`LuaAssert` → `Util.Assert`** and **`LuaHook_Require` → `Util.LuaHook_Require`** are both in `Util`, so
  both are claimed. Note `LuaAssert` is the C++ symbol; the callable name is `Util.Assert`.
- **Debug bindings are claimed** where they land in `Util` (`Util.DumpEvents` ← `DEBUG_DumpEvents`,
  `Util.DEBUGClearStreamblockChangeListTree`). `Cin.DEBUGTeleportToLocator` (`0x0071eaf0`) is **not**
  claimed despite the `Locator` name — it is in the `Cin` table and belongs to
  [18-family-cinematics-camera-face.md](18-family-cinematics-camera-face.md).
- **Boundary overlaps I am deliberately claiming:** `Object.SetOnTrappedCallback`,
  `Util.BroadcastHarassmentEventAtActor`, and `Util.EnableAmbientEvents` all touch AI/freeplay territory
  covered by [11](11-family-ai-squad-combat.md) and [12](12-family-suspicion-wtf-alarm.md). They are in my
  tables, so they are here; the sibling docs may describe the engine side more deeply.
- **Not claimed:** `Checkpoint` (24), `AttractionPt` (25), `FocusPt` (18), `Zone` (2), `Filter` (3) are
  separate tables and belong to siblings, even though `Trigger.CreateDeleteZone` and `Zone.*` clearly
  interoperate.

## Coverage honesty

**253 of 253 bindings in this family are located** (`Util` 173, `Object` 44, `Trigger` 23, `SaveLoad` 13).
"Located" is a weak claim and I mean it narrowly: name, table, VA, and return family are pinned by the
registration map for all 253. Signature derivation is a separate, weaker result:

| | count | meaning |
|---|---:|---|
| Located (name + VA + return family) | **253 / 253** | from the byte-level registration map |
| Decompiled body readable | **202** | present in `saboteur_all_functions_decomp.txt` |
| Body **absent** from the decomp | **51** | Ghidra exported no function at that VA — signature **open** |
| Signature derived from body | **202** | 191 with arguments, 11 genuinely zero-argument |
| **Confirmed** by ≥1 Lua corpus call site | **157** | body read *and* real usage agrees |
| **Inferred** (body read, no call site) | **45** | decomp only — a proposal |
| **Open** (no body) | **51** | of which **32** are attested in the corpus but not derived |
| Anchored by an assertion string (`file:line`) | **5** | the only *proof-grade* identity anchors here |
| Arity cross-checked against corpus | **149** | 139 agree; 10 exceed — all 10 explained below |

The 51 absent bodies are not random: **all 51 are `inlined` (26) or `jmp` (25) shapes** — never `adapter`.
Ghidra's exporter dropped the tiny leaf functions. They cluster in the `Util` getters (`GetGameTime`,
`GetNameFromHandle`, `GetCRC`, `IsDaytime`, `IsPlayerInInterior`, …), which is exactly where a reader most
wants a signature. I have not invented one for any of them; where the corpus attests usage I record the
observed call arity as corpus evidence and leave the type derivation open.

## Method, and where it is weak

For each binding I extracted the decomp body at `impl_va`, scraped the `FUN_006f7*` type-check and fetch
primitives with **literal** stack indices, followed one level of delegation, and cross-checked the derived
maximum arity against every real call site in the 321-file Lua corpus. Two systematic failure modes came
out of that cross-check, and both are visible in the table:

1. **Delegating bindings.** The registered function checks only argument 1, then hands the raw
   `lua_State*` to a second function that parses the rest. Literal scraping of the outer body alone
   undercounts. `Util.CreateEvent` is the worst case: the outer body (`0x007587a0`) checks one table and
   would look 1-argument, but it dispatches into `0x007585c0` / `0x0074c120`, which parse arguments 2–5.
   I follow delegates two levels deep; that fixed `Util.CreateEvent` and `Util.SetDisableControls`.
2. **Computed stack indices.** Some bindings walk arguments with an index held in a register, which Ghidra
   renders as `FUN_006f7100(iVar11)` or even `FUN_006f7160()` with the argument lost entirely. Literal
   scraping cannot see these. **16 bindings are flagged `⚠` in the table; for them the derived arity is a
   lower bound, not a signature.** `Object.Spawn` is the clearest case — derived 6, corpus passes 10.

After delegate-following, 139 of 149 cross-checkable bindings had corpus arity within the derived bound.
Of the 10 that exceeded it, **7 are `⚠` computed-index bindings** (expected). The remaining 3 —
`Util.Assert`, `Util.EnableTutorial`, `Util.AddMissionMessage` — are not derivation failures at all: the
engine really does read fewer arguments than the scripts pass, and silently drops the rest (see below).
Nothing in this table is a guess dressed as a reading; a row I could not derive says so.

**Signature notation:** `hObj` handle (light userdata) · `s` string · `n` number · `i` integer · `b`
boolean · `t` table · `fn` function · `num|str` an argument guarded by a coercing check that accepts both ·
`[x]` argument is optional (independently checked, engine supplies a default) · `?n` argument position
read with an index this method could not resolve · `⚠` computed indices, arity is a lower bound.
Return counts are **not** a table column: they follow mechanically from `family` (§6 of the ABI doc) —
`LuaGlueFunctor0` (174 `adapter` + 27 `inlined` here) always claims exactly 1 result regardless of what the
body pushed; the 52 `LuaGlueFunctor0R jmp` bindings return their own `EAX` and are the only ones with a
real, varying result count.

## The bindings

### `Util` — 173 bindings

| Binding (C++ symbol) | Namespaced form | VA | Source (file:line) | Signature | Conf. | Evidence |
|---|---|---|---|---|---|---|
| `ActivateAmbush` | `Util.ActivateAmbush` | `0x00753c30` | — | `ActivateAmbush(s1, b2, [n3], [n4])` | inferred | body only |
| `AddInterior` | `Util.AddInterior` | `0x00750eb0` | — | `AddInterior([t1])` | confirmed | [SabTaskGameMaster.lua:189](../saboteur-luacd/src/Modules/SabTaskGameMaster.lua#L189) |
| `AddInteriorLoadCallback` | `Util.AddInteriorLoadCallback` | `0x00751700` | — | `AddInteriorLoadCallback(?1, s2, t3, [t4], b5)` ⚠ | confirmed | [InteriorManager.lua:553](../saboteur-luacd/src/Managers/InteriorManager.lua#L553) +16 |
| `AddMissionFolder` | `Util.AddMissionFolder` | `0x00759de0` | — | body absent; corpus arity [2] | open | [GlobalMissionFile.lua:105](../saboteur-luacd/src/Managers/GlobalMissionFile.lua#L105) |
| `AddMissionMessage` | `Util.AddMissionMessage` | `0x00757cb0` | — | `AddMissionMessage(s1, s2, s3, i4, i5, n6, s7, s8, s9, s10)` | confirmed | [SabTaskObjectiveInteract.lua:615](../saboteur-luacd/src/Modules/SabTaskObjectiveInteract.lua#L615) |
| `AddMissionToFolder` | `Util.AddMissionToFolder` | `0x00759e20` | — | body absent; corpus arity [2] | open | [GlobalMissionFile.lua:108](../saboteur-luacd/src/Managers/GlobalMissionFile.lua#L108) |
| `AddPlane` | `Util.AddPlane` | `0x0074f620` | — | `AddPlane(b1)` | inferred | body only |
| `AddSplinePlaneAttackLocation` | `Util.AddSplinePlaneAttackLocation` | `0x0074fbb0` | — | `AddSplinePlaneAttackLocation(s1)` ⚠ | confirmed | [Act_1_Farm.lua:1024](../saboteur-luacd/src/Missions/Act_1_Farm.lua#L1024) +10 |
| `AddSplinePlaneAttackObject` | `Util.AddSplinePlaneAttackObject` | `0x0074f9b0` | — | `AddSplinePlaneAttackObject(s1, n2, b3, hObj4, b5, n6, s7, t8, t9, s10)` | confirmed | [Act_1_Farm.lua:1072](../saboteur-luacd/src/Missions/Act_1_Farm.lua#L1072) +32 |
| `LuaAssert` | `Util.Assert` | `0x0074c650` | — | `Assert([b1], [s2])` | confirmed | [SoldierState_Configure.lua:43](../saboteur-luacd/src/Experimental/SoldierState_Configure.lua#L43) +173 |
| `BlendTimeOfDay` | `Util.BlendTimeOfDay` | `0x0074df50` | — | `BlendTimeOfDay(n1, n2)` | confirmed | [Act_1_GetCaught.lua:159](../saboteur-luacd/src/Missions/Act_1_GetCaught.lua#L159) |
| `BreakpointIndex` | `Util.BreakpointIndex` | `0x0074d810` | — | body absent, no call site | open | body only |
| `BroadcastFunction` | `Util.BroadcastFunction` | `0x00758d80` | — | `BroadcastFunction()` ⚠ | confirmed | [AttackAction.lua:21](../saboteur-luacd/src/Experimental/AttackAction.lua#L21) +34 |
| `BroadcastHarassmentEventAtActor` | `Util.BroadcastHarassmentEventAtActor` | `0x00759920` | Utility.cpp:5862 | `BroadcastHarassmentEventAtActor([hObj1])` | confirmed | assert [Paris_1_Mission_1.lua:1143](../saboteur-luacd/src/Missions/Paris_1_Mission_1.lua#L1143) |
| `BroadcastNeed` | `Util.BroadcastNeed` | `0x0074c940` | — | `BroadcastNeed([hObj1], n2, i3, n4, s5)` | inferred | body only |
| `CancelExecutionScene` | `Util.CancelExecutionScene` | `0x00759860` | — | `CancelExecutionScene([hObj1])` | inferred | body only |
| `CancelInteriorLoadCallback` | `Util.CancelInteriorLoadCallback` | `0x00751840` | — | `CancelInteriorLoadCallback(s1, b2)` | confirmed | [P1FP_RoofFetch01.lua:788](../saboteur-luacd/src/Missions/P1FP_RoofFetch01.lua#L788) +5 |
| `ClearAllInteriorLoadCallbacks` | `Util.ClearAllInteriorLoadCallbacks` | `0x0075b480` | — | body absent; corpus arity [0] | open | [SabTask.lua:1617](../saboteur-luacd/src/Modules/SabTask.lua#L1617) +2 |
| `ClearAllPendingTutorials` | `Util.ClearAllPendingTutorials` | `0x0075b420` | — | body absent; corpus arity [0] | open | [Act_1_BarFight.lua:687](../saboteur-luacd/src/Missions/Act_1_BarFight.lua#L687) +14 |
| `ClearAndDeleteLastKnownPlayerVehicle` | `Util.ClearAndDeleteLastKnownPlayerVehicle` | `0x00758430` | — | `ClearAndDeleteLastKnownPlayerVehicle()` | inferred | body only |
| `ClearDisguiseCallback` | `Util.ClearDisguiseCallback` | `0x0075d1f0` | — | body absent; corpus arity [0] | open | [Paris_1_Mission_1B.lua:178](../saboteur-luacd/src/Missions/Paris_1_Mission_1B.lua#L178) +1 |
| `ClearDisguiseCompleteCallback` | `Util.ClearDisguiseCompleteCallback` | `0x0075ab60` | — | body absent, no call site | open | body only |
| `ClearDisguiseStartedCallback` | `Util.ClearDisguiseStartedCallback` | `0x0075d260` | — | body absent; corpus arity [0] | open | [P1FP_Traitor.lua:856](../saboteur-luacd/src/Missions/P1FP_Traitor.lua#L856) +1 |
| `ClearLostDisguiseCallback` | `Util.ClearLostDisguiseCallback` | `0x0075d2d0` | — | body absent; corpus arity [0] | open | [P1FP_Traitor.lua:874](../saboteur-luacd/src/Missions/P1FP_Traitor.lua#L874) +1 |
| `ClearMiniZepSpline` | `Util.ClearMiniZepSpline` | `0x0075b440` | — | body absent; corpus arity [0] | open | [Paris_2_Mission_5.lua:3315](../saboteur-luacd/src/Missions/Paris_2_Mission_5.lua#L3315) |
| `CreateEventA` | `Util.CreateEvent` | `0x007587a0` | — | `CreateEvent([t1], s2, t3, t4, b5)` | confirmed | [Checkpoint.lua:17](../saboteur-luacd/src/Experimental/Checkpoint.lua#L17) +1028 |
| `CreateExecutionScene` | `Util.CreateExecutionScene` | `0x00759660` | — | `CreateExecutionScene([hObj1], t2, i3, s4, [t5], [t6])` | confirmed | [Act_3_Mission_2.lua:1580](../saboteur-luacd/src/Missions/Act_3_Mission_2.lua#L1580) +4 |
| `CreateExplosion` | `Util.CreateExplosion` | `0x00757b90` | — | `CreateExplosion([s1], [n2], [n3], [n4])` | confirmed | [Act_3_Mission_3.lua:1900](../saboteur-luacd/src/Missions/Act_3_Mission_3.lua#L1900) +44 |
| `DEBUGClearStreamblockChangeListTree` | `Util.DEBUGClearStreamblockChangeListTree` | `0x0075b360` | — | body absent, no call site | open | body only |
| `DisableDisguising` | `Util.DisableDisguising` | `0x007539a0` | — | `DisableDisguising([b1])` | confirmed | [RewardsManager.lua:5250](../saboteur-luacd/src/Managers/RewardsManager.lua#L5250) +4 |
| `DisableShopKeeperBlip` | `Util.DisableShopKeeperBlip` | `0x00753fa0` | — | `DisableShopKeeperBlip(s1, b2)` | confirmed | [Act_3_Mission_2.lua:66](../saboteur-luacd/src/Missions/Act_3_Mission_2.lua#L66) +55 |
| `DisplayMissionMessage` | `Util.DisplayMissionMessage` | `0x007522a0` | — | `DisplayMissionMessage(s1, i2, s3, s4, t5, t6)` | confirmed | [P1FP_Traitor.lua:867](../saboteur-luacd/src/Missions/P1FP_Traitor.lua#L867) +2 |
| `DEBUG_DumpEvents` | `Util.DumpEvents` | `0x00759e60` | — | body absent, no call site | open | body only |
| `EnableAmbientEvents` | `Util.EnableAmbientEvents` | `0x00750e40` | — | `EnableAmbientEvents(b1)` | confirmed | [Act_3_Mission_1.lua:1084](../saboteur-luacd/src/Missions/Act_3_Mission_1.lua#L1084) +4 |
| `EnableBirds` | `Util.EnableBirds` | `0x00752680` | — | `EnableBirds([b1])` | confirmed | [Act_3_Mission_5.lua:34](../saboteur-luacd/src/Missions/Act_3_Mission_5.lua#L34) +5 |
| `EnableBridgeKillers` | `Util.EnableBridgeKillers` | `0x00753f30` | — | `EnableBridgeKillers(b1)` | inferred | body only |
| `EnableDynamicTutorialSystem` | `Util.EnableDynamicTutorialSystem` | `0x00753930` | — | `EnableDynamicTutorialSystem([b1])` | inferred | body only |
| `EnableGooseSteppers` | `Util.EnableGooseSteppers` | `0x0074e240` | — | `EnableGooseSteppers([b1])` | confirmed | [__UtilFunctions.lua:636](../saboteur-luacd/src/Includes/__UtilFunctions.lua#L636) +10 |
| `EnableMiniZep` | `Util.EnableMiniZep` | `0x0074fee0` | — | `EnableMiniZep([b1])` | confirmed | [Act_1_BarFight.lua:149](../saboteur-luacd/src/Missions/Act_1_BarFight.lua#L149) +12 |
| `EnableMiniZepShooting` | `Util.EnableMiniZepShooting` | `0x0074ff50` | — | `EnableMiniZepShooting([b1])` | confirmed | [Act_3_Mission_2.lua:48](../saboteur-luacd/src/Missions/Act_3_Mission_2.lua#L48) +2 |
| `EnableRoadsInRegion` | `Util.EnableRoadsInRegion` | `0x0074dac0` | — | `EnableRoadsInRegion([b1], hObj2)` | confirmed | [Connect_A3_M1b_ReturnToBelle.lua:30](../saboteur-luacd/src/Missions/Connect_A3_M1b_ReturnToBelle.lua#L30) +17 |
| `EnableSidewalksInRegion` | `Util.EnableSidewalksInRegion` | `0x0074da30` | — | `EnableSidewalksInRegion(b1, s2)` | confirmed | [P2FP_MadeleineSniper.lua:598](../saboteur-luacd/src/Missions/P2FP_MadeleineSniper.lua#L598) +7 |
| `EnableSporesInRegion` | `Util.EnableSporesInRegion` | `0x0074d9a0` | — | `EnableSporesInRegion(b1, s2)` | inferred | body only |
| `EnableSuperSpores` | `Util.EnableSuperSpores` | `0x0074db80` | — | `EnableSuperSpores([b1])` | confirmed | [__UtilFunctions.lua:633](../saboteur-luacd/src/Includes/__UtilFunctions.lua#L633) +29 |
| `EnableTutorial` | `Util.EnableTutorial` | `0x007535f0` | — | `EnableTutorial([num|str1], b2)` | confirmed | [Act_1_Factory.lua:934](../saboteur-luacd/src/Missions/Act_1_Factory.lua#L934) +7 |
| `EnableVendors` | `Util.EnableVendors` | `0x0074dbf0` | — | `EnableVendors([b1])` | inferred | body only |
| `EnterInterior` | `Util.EnterInterior` | `0x00751260` | — | `EnterInterior(s1, s2, [s3], [b4], [t5])` | confirmed | [Belle_Interior.lua:167](../saboteur-luacd/src/Modules/InteriorLevels/Belle_Interior.lua#L167) +12 |
| `ExitInterior` | `Util.ExitInterior` | `0x00751410` | — | `ExitInterior([s1], s2, [b3], [b4])` | confirmed | [Belle_Interior.lua:196](../saboteur-luacd/src/Modules/InteriorLevels/Belle_Interior.lua#L196) +12 |
| `FindSafeSpawnPoint` | `Util.FindSafeSpawnPoint` | `0x0074d490` | — | body absent; corpus arity [5] | open | [Formation.lua:47](../saboteur-luacd/src/Modules/Libraries/Formation.lua#L47) +4 |
| `FindUnseenPtFromList` | `Util.FindUnseenPtFromList` | `0x0074d5f0` | — | `FindUnseenPtFromList(t1, s2, t3, [t4])` | inferred | body only |
| `ForceMiniZepTargetPlayer` | `Util.ForceMiniZepTargetPlayer` | `0x007500a0` | — | `ForceMiniZepTargetPlayer([b1])` | inferred | body only |
| `FreezeMiniZep` | `Util.FreezeMiniZep` | `0x0074fdc0` | — | `FreezeMiniZep([b1])` | confirmed | [Act_3_Mission_2.lua:2193](../saboteur-luacd/src/Missions/Act_3_Mission_2.lua#L2193) +3 |
| `UtilGetCRC` | `Util.GetCRC` | `0x0074c830` | — | body absent; corpus arity [1] | open | [ShopManager.lua:387](../saboteur-luacd/src/Managers/ShopManager.lua#L387) +20 |
| `GetDisableControls` | `Util.GetDisableControls` | `0x007509a0` | — | body absent, no call site | open | body only |
| `GetEditNodeContents` | `Util.GetEditNodeContents` | `0x007592e0` | — | `GetEditNodeContents()` ⚠ | confirmed | [Act_1_Farm.lua:154](../saboteur-luacd/src/Missions/Act_1_Farm.lua#L154) +2 |
| `GetGameTime` | `Util.GetGameTime` | `0x0074c6c0` | — | body absent; corpus arity [0] | open | [Checkpoint.lua:274](../saboteur-luacd/src/Experimental/Checkpoint.lua#L274) +13 |
| `GetHandleByName` | `Util.GetHandleByName` | `0x00758b30` | — | `GetHandleByName(s1)` | confirmed | [AttackAction.lua:19](../saboteur-luacd/src/Experimental/AttackAction.lua#L19) +1552 |
| `GetIntFromHandle` | `Util.GetIntFromHandle` | `0x0074c720` | — | body absent; corpus arity [1] | open | [TipsLib.lua:31](../saboteur-luacd/src/Modules/Libraries/TipsLib.lua#L31) +1 |
| `GetInteriorNameByScript` | `Util.GetInteriorNameByScript` | `0x00751b80` | — | body absent; corpus arity [1] | open | [DoorTeleporter.lua:36](../saboteur-luacd/src/Modules/Behavior/AttractionPts/DoorTeleporter.lua#L36) +1 |
| `GetInteriorScriptByName` | `Util.GetInteriorScriptByName` | `0x00751aa0` | — | body absent; corpus arity [1] | open | [InteriorManager.lua:878](../saboteur-luacd/src/Managers/InteriorManager.lua#L878) +4 |
| `GetNameFromHandle` | `Util.GetNameFromHandle` | `0x0074c7b0` | — | body absent; corpus arity [1] | open | [Checkpoint.lua:99](../saboteur-luacd/src/Experimental/Checkpoint.lua#L99) +30 |
| `GetPlayersInterior` | `Util.GetPlayersInterior` | `0x00751900` | — | body absent; corpus arity [0] | open | [InteriorManager.lua:789](../saboteur-luacd/src/Managers/InteriorManager.lua#L789) +11 |
| `GetPointInViewOnRoad` | `Util.GetPointInViewOnRoad` | `0x0074e110` | — | body absent, no call site | open | body only |
| `GetRaceDifficulty` | `Util.GetRaceDifficulty` | `0x0074ee00` | — | body absent; corpus arity [0] | open | [Act_1_Race.lua:349](../saboteur-luacd/src/Missions/Act_1_Race.lua#L349) +4 |
| `GetScriptArgNum` | `Util.GetScriptArgNum` | `0x00750040` | — | body absent, no call site | open | body only |
| `GetTime` | `Util.GetTime` | `0x0074dd90` | — | body absent; corpus arity [0] | open | [SabTask.lua:1521](../saboteur-luacd/src/Modules/SabTask.lua#L1521) +2 |
| `HQIsUnlocked` | `Util.HQIsUnlocked` | `0x0074e8c0` | — | body absent, no call site | open | body only |
| `HQSetAllowedOverride` | `Util.HQSetAllowedOverride` | `0x0074e780` | — | `HQSetAllowedOverride([s1], [b2])` | confirmed | [SOE_Zeppelin.lua:28](../saboteur-luacd/src/Missions/SOE_Zeppelin.lua#L28) |
| `HQSetOnMiniMap` | `Util.HQSetOnMiniMap` | `0x0074e950` | — | `HQSetOnMiniMap([s1], [b2])` | confirmed | [RewardsManager.lua:4681](../saboteur-luacd/src/Managers/RewardsManager.lua#L4681) +1 |
| `HQSetUnlocked` | `Util.HQSetUnlocked` | `0x0074e820` | — | `HQSetUnlocked([s1], [b2])` | confirmed | [RewardsManager.lua:4677](../saboteur-luacd/src/Managers/RewardsManager.lua#L4677) +2 |
| `HideVeryFarSceneMesh` | `Util.HideVeryFarSceneMesh` | `0x00753a90` | — | `HideVeryFarSceneMesh([s1])` | inferred | body only |
| `InitMissionList` | `Util.InitMissionList` | `0x00759da0` | — | body absent, no call site | open | body only |
| `InteriorLoadSetDisableTeleport` | `Util.InteriorLoadSetDisableTeleport` | `0x0075c440` | — | body absent; corpus arity [0] | open | [InteriorManager.lua:931](../saboteur-luacd/src/Managers/InteriorManager.lua#L931) +1 |
| `IsAchievementGranted` | `Util.IsAchievementGranted` | `0x007525c0` | — | body absent, no call site | open | body only |
| `IsBlockLoaded` | `Util.IsBlockLoaded` | `0x00757b00` | — | `IsBlockLoaded([s1])` | confirmed | [__UtilFunctions.lua:90](../saboteur-luacd/src/Includes/__UtilFunctions.lua#L90) +20 |
| `IsCustomTagLoaded` | `Util.IsCustomTagLoaded` | `0x0074d210` | — | body absent; corpus arity [1] | open | [Act_3_Mission_1.lua:799](../saboteur-luacd/src/Missions/Act_3_Mission_1.lua#L799) +7 |
| `IsDaytime` | `Util.IsDaytime` | `0x0074de80` | — | body absent, no call site | open | body only |
| `IsHandleValid` | `Util.IsHandleValid` | `0x00758cd0` | — | `IsHandleValid([hObj1])` | confirmed | [ShopManager.lua:218](../saboteur-luacd/src/Managers/ShopManager.lua#L218) +24 |
| `IsInteriorEnabled` | `Util.IsInteriorEnabled` | `0x00751a00` | — | body absent; corpus arity [1] | open | [DoorTeleporter.lua:37](../saboteur-luacd/src/Modules/Behavior/AttractionPts/DoorTeleporter.lua#L37) +1 |
| `IsLoadingFrance` | `Util.IsLoadingFrance` | `0x0074ed30` | — | body absent; corpus arity [0] | open | [Main_Saboteur_Game.lua:19](../saboteur-luacd/src/Modules/Main_Saboteur_Game.lua#L19) |
| `IsObjectHandleValid` | `Util.IsObjectHandleValid` | `0x0074c8c0` | — | body absent; corpus arity [1] | open | [Act_1_GetCaught.lua:1536](../saboteur-luacd/src/Missions/Act_1_GetCaught.lua#L1536) +7 |
| `IsPlayerInInterior` | `Util.IsPlayerInInterior` | `0x007519a0` | — | body absent; corpus arity [0] | open | [InteriorManager.lua:971](../saboteur-luacd/src/Managers/InteriorManager.lua#L971) |
| `KillAllEvents` | `Util.KillAllEvents` | `0x007588e0` | — | `KillAllEvents([hObj1])` | confirmed | [AmbientTankPatrol.lua:137](../saboteur-luacd/src/ScriptControllers/AmbientTankPatrol.lua#L137) +1 |
| `KillEvent` | `Util.KillEvent` | `0x0074c2c0` | — | `KillEvent(num|str1)` | confirmed | [Checkpoint.lua:459](../saboteur-luacd/src/Experimental/Checkpoint.lua#L459) +479 |
| `KillMiniZep` | `Util.KillMiniZep` | `0x0075b460` | — | body absent; corpus arity [0] | open | [Act_3_Mission_2.lua:2203](../saboteur-luacd/src/Missions/Act_3_Mission_2.lua#L2203) |
| `KillMission` | `Util.KillMission` | `0x00758a80` | — | `KillMission([hObj1])` | inferred | body only |
| `KillPlane` | `Util.KillPlane` | `0x0075b3a0` | — | body absent, no call site | open | body only |
| `LoadAnimGroup` | `Util.LoadAnimGroup` | `0x00753e30` | — | `LoadAnimGroup([s1])` | confirmed | [Belle_Interior.lua:16](../saboteur-luacd/src/Modules/InteriorLevels/Belle_Interior.lua#L16) +3 |
| `LoadDynamicNode` | `Util.LoadDynamicNode` | `0x00757950` | — | `LoadDynamicNode(s1, s2, t3, [t4])` | confirmed | [Act_1_Race.lua:1152](../saboteur-luacd/src/Missions/Act_1_Race.lua#L1152) +4 |
| `LoadStaticENTag` | `Util.LoadStaticENTag` | `0x0074d0b0` | — | `LoadStaticENTag([s1], [b2])` | confirmed | [__UtilFunctions.lua:120](../saboteur-luacd/src/Includes/__UtilFunctions.lua#L120) +135 |
| `LockInteriorDoors` | `Util.LockInteriorDoors` | `0x00751cc0` | — | `LockInteriorDoors(s1, b2)` | inferred | body only |
| `LuaHook_Require` | `Util.LuaHook_Require` | `0x00753b20` | — | body absent, no call site | open | body only |
| `MakeEscalationCallback` | `Util.MakeEscalationCallback` | `0x0074c420` | — | `MakeEscalationCallback(s1, [t2], [t3])` | confirmed | [WRAPPER_Event.lua:603](../saboteur-luacd/src/Includes/WRAPPER_Event.lua#L603) +1 |
| `MissionComplete` | `Util.MissionComplete` | `0x0075b170` | — | body absent; corpus arity [0] | open | [SabTaskMission.lua:493](../saboteur-luacd/src/Modules/SabTaskMission.lua#L493) |
| `MissionFail` | `Util.MissionFail` | `0x00752790` | — | `MissionFail([s1])` | confirmed | [SabTask.lua:985](../saboteur-luacd/src/Modules/SabTask.lua#L985) +3 |
| `NewMission` | `Util.NewMission` | `0x0074c590` | — | body absent; corpus arity [2] | open | [France.lua:9](../saboteur-luacd/src/Modules/France.lua#L9) +1 |
| `Pause` | `Util.Pause` | `0x0074d340` | — | `Pause([b1])` | confirmed | [Act_3_Mission_1_E3.lua:435](../saboteur-luacd/src/Missions/Act_3_Mission_1_E3.lua#L435) +3 |
| `PreloadAnimGroup` | `Util.PreloadAnimGroup` | `0x00753db0` | — | `PreloadAnimGroup([s1])` | inferred | body only |
| `QueueTutorial` | `Util.QueueTutorial` | `0x007536f0` | — | `QueueTutorial(s1, s2, n3, b4)` ⚠ | confirmed | [RewardsManager.lua:5228](../saboteur-luacd/src/Managers/RewardsManager.lua#L5228) +18 |
| `RecordMissionComplete` | `Util.RecordMissionComplete` | `0x0075b3e0` | — | body absent; corpus arity [0] | open | [RewardsManager.lua:5236](../saboteur-luacd/src/Managers/RewardsManager.lua#L5236) |
| `RecordRaceTime` | `Util.RecordRaceTime` | `0x007533c0` | — | `RecordRaceTime(n1, i2)` | inferred | body only |
| `RecordWTFZoneFlipped` | `Util.RecordWTFZoneFlipped` | `0x0075b3c0` | — | body absent, no call site | open | body only |
| `RegisterLuaUpdate` | `Util.RegisterLuaUpdate` | `0x00752150` | — | `RegisterLuaUpdate(s1, [t2], [t3])` | confirmed | [Act_1_GetCaught.lua:1484](../saboteur-luacd/src/Missions/Act_1_GetCaught.lua#L1484) +5 |
| `ReloadAllWSDData` | `Util.ReloadAllWSDData` | `0x0075b340` | — | body absent, no call site | open | body only |
| `RemoveAvailableMissionMessage` | `Util.RemoveAvailableMissionMessage` | `0x007520d0` | — | `RemoveAvailableMissionMessage([s1])` | confirmed | [RewardsManager.lua:5370](../saboteur-luacd/src/Managers/RewardsManager.lua#L5370) +1 |
| `RemoveFromMultigrid` | `Util.RemoveFromMultigrid` | `0x00753d40` | — | `RemoveFromMultigrid([hObj1])` | inferred | body only |
| `RemovePlane` | `Util.RemovePlane` | `0x0075b380` | — | body absent, no call site | open | body only |
| `RequestDynamicBlueprint` | `Util.RequestDynamicBlueprint` | `0x0074e680` | — | `RequestDynamicBlueprint(s1)` | confirmed | [Paris_1_Mission_1B.lua:2231](../saboteur-luacd/src/Missions/Paris_1_Mission_1B.lua#L2231) +6 |
| `RequestNode` | `Util.RequestNode` | `0x00751090` | — | `RequestNode([s1], s2, [i3], [b4], [b5], [b6], b7)` | confirmed | [InteriorManager.lua:795](../saboteur-luacd/src/Managers/InteriorManager.lua#L795) +7 |
| `ResetDayTimeScale` | `Util.ResetDayTimeScale` | `0x0075b320` | — | body absent; corpus arity [0] | open | [Act_1_GetCaught.lua:2630](../saboteur-luacd/src/Missions/Act_1_GetCaught.lua#L2630) +3 |
| `ScriptLoaded` | `Util.ScriptLoaded` | `0x0074dc60` | — | `ScriptLoaded([s1])` | inferred | body only |
| `SelectRandomBlueprint` | `Util.SelectRandomBlueprint` | `0x00759570` | — | `SelectRandomBlueprint(s1)` | inferred | body only |
| `SendPerkMessage` | `Util.SendPerkMessage` | `0x00751d70` | — | `SendPerkMessage([s1])` | confirmed | [FP_CountryRace_1.lua:249](../saboteur-luacd/src/Missions/FP_CountryRace_1.lua#L249) +5 |
| `SetAllDynamicTutorialsToDisabled` | `Util.SetAllDynamicTutorialsToDisabled` | `0x0075b400` | — | body absent, no call site | open | body only |
| `SetBirdDensity` | `Util.SetBirdDensity` | `0x007526f0` | — | `SetBirdDensity([n1])` | inferred | body only |
| `SetDayTimeScale` | `Util.SetDayTimeScale` | `0x0074dee0` | — | `SetDayTimeScale([n1])` | confirmed | [SabTask.lua:1579](../saboteur-luacd/src/Modules/SabTask.lua#L1579) +1 |
| `SetDifficultySkew` | `Util.SetDifficultySkew` | `0x0074eda0` | — | `SetDifficultySkew([n1])` | inferred | body only |
| `SetDisableAuroraGuns` | `Util.SetDisableAuroraGuns` | `0x00751fe0` | — | `SetDisableAuroraGuns(b1)` | confirmed | [Act_1_Race.lua:346](../saboteur-luacd/src/Missions/Act_1_Race.lua#L346) +2 |
| `SetDisableControlsTable` | `Util.SetDisableControls` | `0x00750110` | — | `SetDisableControls([s1], b2)` | confirmed | [__UtilFunctions.lua:608](../saboteur-luacd/src/Includes/__UtilFunctions.lua#L608) +29 |
| `SetDisableMessengers` | `Util.SetDisableMessengers` | `0x00752060` | — | `SetDisableMessengers([b1])` | confirmed | [E3_EiffelDemo.lua:34](../saboteur-luacd/src/Missions/E3_EiffelDemo.lua#L34) +1 |
| `SetDisguiseCallback` | `Util.SetDisguiseCallback` | `0x00758080` | — | `SetDisguiseCallback(s1, t2, t3)` | confirmed | [FuelDepot_E3.lua:85](../saboteur-luacd/src/Missions/FuelDepot_E3.lua#L85) +1 |
| `SetDisguiseCompleteCallback` | `Util.SetDisguiseCompleteCallback` | `0x00753510` | — | `SetDisguiseCompleteCallback(s1, [t2], [t3])` | confirmed | [Connect_A1_M2c_JulesToTrack.lua:54](../saboteur-luacd/src/Missions/Connect_A1_M2c_JulesToTrack.lua#L54) |
| `SetDisguiseStartedCallback` | `Util.SetDisguiseStartedCallback` | `0x007581d0` | — | `SetDisguiseStartedCallback(s1, t2, t3)` | confirmed | [P1FP_Traitor.lua:830](../saboteur-luacd/src/Missions/P1FP_Traitor.lua#L830) +1 |
| `SetDynamicPriority` | `Util.SetDynamicPriority` | `0x00752fc0` | — | `SetDynamicPriority(s1, i2, [b3])` | confirmed | [Act_1_GetCaught.lua:33](../saboteur-luacd/src/Missions/Act_1_GetCaught.lua#L33) +66 |
| `SetGarageEnable` | `Util.SetGarageEnable` | `0x00752960` | — | `SetGarageEnable(b1)` | confirmed | [RewardsManager.lua:5054](../saboteur-luacd/src/Managers/RewardsManager.lua#L5054) |
| `SetInteriorFloorData` | `Util.SetInteriorFloorData` | `0x00751550` | — | `SetInteriorFloorData(s1, i2, n3, n4, n5, n6, n7, n8)` | confirmed | [SabTaskGameMaster.lua:192](../saboteur-luacd/src/Modules/SabTaskGameMaster.lua#L192) |
| `SetLastMissionChatter` | `Util.SetLastMissionChatter` | `0x0074ec40` | — | `SetLastMissionChatter([s1])` | confirmed | [RewardsManager.lua:5280](../saboteur-luacd/src/Managers/RewardsManager.lua#L5280) +1 |
| `SetLostDisguiseCallback` | `Util.SetLostDisguiseCallback` | `0x00758320` | — | `SetLostDisguiseCallback(s1, [t2], [t3])` | confirmed | [P1FP_Traitor.lua:854](../saboteur-luacd/src/Missions/P1FP_Traitor.lua#L854) |
| `SetLuaSaveVersion` | `Util.SetLuaSaveVersion` | `0x00752430` | — | `SetLuaSaveVersion([i1])` | inferred | body only |
| `SetMiniZepSpline` | `Util.SetMiniZepSpline` | `0x0074fe30` | — | `SetMiniZepSpline(s1, [b2])` | confirmed | [Act_3_Mission_2.lua:2199](../saboteur-luacd/src/Missions/Act_3_Mission_2.lua#L2199) +3 |
| `SetNumMissions` | `Util.SetNumMissions` | `0x007532e0` | — | `SetNumMissions(i1)` | confirmed | [RewardsManager.lua:55](../saboteur-luacd/src/Managers/RewardsManager.lua#L55) |
| `SetNumWTFZones` | `Util.SetNumWTFZones` | `0x00753350` | — | `SetNumWTFZones(i1)` | inferred | body only |
| `SetOverrideLoadScreenFadeIn` | `Util.SetOverrideLoadScreenFadeIn` | `0x00752490` | — | `SetOverrideLoadScreenFadeIn([b1])` | confirmed | [Act_3_Mission_1.lua:605](../saboteur-luacd/src/Missions/Act_3_Mission_1.lua#L605) +10 |
| `SetPerkAvailable` | `Util.SetPerkAvailable` | `0x00751f30` | — | `SetPerkAvailable([s1], b2)` | confirmed | [RewardsManager.lua:5300](../saboteur-luacd/src/Managers/RewardsManager.lua#L5300) +5 |
| `SetPlaneHealth` | `Util.SetPlaneHealth` | `0x0074f950` | — | `SetPlaneHealth(n1)` | inferred | body only |
| `SetPlayerAtHQ` | `Util.SetPlayerAtHQ` | `0x0074eab0` | — | `SetPlayerAtHQ([b1])` | confirmed | [InteriorManager.lua:552](../saboteur-luacd/src/Managers/InteriorManager.lua#L552) +1 |
| `SetPlayerCurrentAct` | `Util.SetPlayerCurrentAct` | `0x0074ecc0` | — | `SetPlayerCurrentAct(i1)` | inferred | body only |
| `SetPlayerCurrentMission` | `Util.SetPlayerCurrentMission` | `0x0074eb20` | — | `SetPlayerCurrentMission([s1])` | confirmed | [SabTaskMission.lua:305](../saboteur-luacd/src/Modules/SabTaskMission.lua#L305) +1 |
| `SetPlayerLastCompletedMission` | `Util.SetPlayerLastCompletedMission` | `0x0074ebb0` | — | `SetPlayerLastCompletedMission([s1])` | confirmed | [SabTaskMission.lua:542](../saboteur-luacd/src/Modules/SabTaskMission.lua#L542) |
| `SetPlayerLastHQ` | `Util.SetPlayerLastHQ` | `0x0074e9f0` | — | `SetPlayerLastHQ([s1])` | confirmed | [SabTaskMission.lua:372](../saboteur-luacd/src/Modules/SabTaskMission.lua#L372) +3 |
| `SetShopDisplayLockedByPerks` | `Util.SetShopDisplayLockedByPerks` | `0x00752c40` | — | `SetShopDisplayLockedByPerks([b1])` | inferred | body only |
| `SetShopEnable` | `Util.SetShopEnable` | `0x007528f0` | — | `SetShopEnable(b1)` | confirmed | [RewardsManager.lua:5047](../saboteur-luacd/src/Managers/RewardsManager.lua#L5047) +4 |
| `SetTime` | `Util.SetTime` | `0x0074dcf0` | — | `SetTime(n1, n2)` | confirmed | [Act_1_BarFight.lua:306](../saboteur-luacd/src/Missions/Act_1_BarFight.lua#L306) +25 |
| `SetTimeScale` | `Util.SetTimeScale` | `0x0074d3e0` | — | `SetTimeScale([n1])` | confirmed | [Act_1_Escape.lua:621](../saboteur-luacd/src/Missions/Act_1_Escape.lua#L621) +13 |
| `ShopMacro` | `Util.ShopMacro` | `0x007529d0` | — | `ShopMacro([b1])` | inferred | body only |
| `ShowAchievements` | `Util.ShowAchievements` | `0x0075b070` | — | body absent, no call site | open | body only |
| `ShowVeryFarSceneMesh` | `Util.ShowVeryFarSceneMesh` | `0x00753a00` | — | `ShowVeryFarSceneMesh([s1])` | inferred | body only |
| `SpawnCinematicNode` | `Util.SpawnCinematicNode` | `0x0074cef0` | — | `SpawnCinematicNode([s1], s2, t3, [t4])` | confirmed | [WorldSMEDNodes.lua:34](../saboteur-luacd/src/Managers/WorldSMEDNodes.lua#L34) +3 |
| `SpawnDeleteNode` | `Util.SpawnDeleteNode` | `0x0074ca90` | — | `SpawnDeleteNode(s1)` | confirmed | [SabTask.lua:610](../saboteur-luacd/src/Modules/SabTask.lua#L610) |
| `SpawnEditNode` | `Util.SpawnEditNode` | `0x0074cb00` | — | `SpawnEditNode([s1], s2, [t3], [t4])` | confirmed | [__UtilFunctions.lua:77](../saboteur-luacd/src/Includes/__UtilFunctions.lua#L77) +81 |
| `SpawnGooseSteppers` | `Util.SpawnGooseSteppers` | `0x0074e2b0` | — | `SpawnGooseSteppers([s1])` | inferred | body only |
| `SpawnInterior` | `Util.SpawnInterior` | `0x0074cd30` | — | `SpawnInterior([s1], s2, t3, [t4])` | confirmed | [__UtilFunctions.lua:99](../saboteur-luacd/src/Includes/__UtilFunctions.lua#L99) +1 |
| `SpawnRocket` | `Util.SpawnRocket` | `0x0074e330` | — | `SpawnRocket(s1, n2, n3, n4, n5, n6, n7)` | confirmed | [Act_3_Mission_2.lua:742](../saboteur-luacd/src/Missions/Act_3_Mission_2.lua#L742) +40 |
| `StartSlowMotionCamera` | `Util.StartSlowMotionCamera` | `0x00753440` | — | `StartSlowMotionCamera(s1, s2, [b3])` | inferred | body only |
| `SwapBlueprint` | `Util.SwapBlueprint` | `0x00759470` | — | `SwapBlueprint(s1, s2)` | inferred | body only |
| `SwitchFence` | `Util.SwitchFence` | `0x0074dfe0` | — | `SwitchFence(n1, n2, n3, b4)` | inferred | body only |
| `TeleportMiniZep` | `Util.TeleportMiniZep` | `0x0074ffc0` | — | `TeleportMiniZep([hObj1])` | confirmed | [Act_3_Mission_2.lua:2192](../saboteur-luacd/src/Missions/Act_3_Mission_2.lua#L2192) |
| `TestTest` | `Util.TestTest` | `0x00752cb0` | — | `TestTest(i1)` | confirmed | [Shopkeeper.lua:27](../saboteur-luacd/src/Modules/Behavior/Human/Resistance/Shopkeeper.lua#L27) |
| `UnloadAnimGroup` | `Util.UnloadAnimGroup` | `0x00753eb0` | — | `UnloadAnimGroup([s1])` | confirmed | [Belle_Interior.lua:179](../saboteur-luacd/src/Modules/InteriorLevels/Belle_Interior.lua#L179) +3 |
| `UnloadCinematicNode` | `Util.UnloadCinematicNode` | `0x0074d020` | — | `UnloadCinematicNode([s1])` | confirmed | [WorldSMEDNodes.lua:68](../saboteur-luacd/src/Managers/WorldSMEDNodes.lua#L68) +2 |
| `UnloadDynamicNode` | `Util.UnloadDynamicNode` | `0x0074d2c0` | — | `UnloadDynamicNode([s1])` | confirmed | [Act_1_Race.lua:1182](../saboteur-luacd/src/Missions/Act_1_Race.lua#L1182) |
| `UnloadEditNode` | `Util.UnloadEditNode` | `0x0074cc50` | — | `UnloadEditNode(s1, [b2], b3)` | confirmed | [__UtilFunctions.lua:91](../saboteur-luacd/src/Includes/__UtilFunctions.lua#L91) +88 |
| `UnloadInterior` | `Util.UnloadInterior` | `0x0074ce70` | — | `UnloadInterior([s1])` | confirmed | [__UtilFunctions.lua:108](../saboteur-luacd/src/Includes/__UtilFunctions.lua#L108) |
| `UnloadStaticENTag` | `Util.UnloadStaticENTag` | `0x0074d150` | — | `UnloadStaticENTag([s1], [b2], [b3])` | confirmed | [__UtilFunctions.lua:126](../saboteur-luacd/src/Includes/__UtilFunctions.lua#L126) +194 |
| `UnlockAchievement` | `Util.UnlockAchievement` | `0x00752530` | — | body absent; corpus arity [1] | open | [AchievementsManager.lua:87](../saboteur-luacd/src/Managers/AchievementsManager.lua#L87) |
| `UnlockAllAchievements` | `Util.UnlockAllAchievements` | `0x0075b4a0` | — | body absent, no call site | open | body only |
| `UnlockGarageLabel` | `Util.UnlockGarageLabel` | `0x00752f40` | — | `UnlockGarageLabel([s1])` | inferred | body only |
| `UnlockPerk` | `Util.UnlockPerk` | `0x00753100` | — | `UnlockPerk(i1, i2, b3)` | inferred | body only |
| `UnlockPerkReward` | `Util.UnlockPerkReward` | `0x007531d0` | — | `UnlockPerkReward([num|str1], b2)` | inferred | body only |
| `UnlockShopLabel` | `Util.UnlockShopLabel` | `0x00752e90` | — | `UnlockShopLabel([s1], b2)` | confirmed | [RewardsManager.lua:5050](../saboteur-luacd/src/Managers/RewardsManager.lua#L5050) +3 |
| `UnlockStrike` | `Util.UnlockStrike` | `0x00752850` | — | `UnlockStrike(i1, b2)` | confirmed | [RewardsManager.lua:4776](../saboteur-luacd/src/Managers/RewardsManager.lua#L4776) |
| `UnregisterLuaUpdate` | `Util.UnregisterLuaUpdate` | `0x00752220` | — | `UnregisterLuaUpdate(s1)` | confirmed | [Act_1_GetCaught.lua:341](../saboteur-luacd/src/Missions/Act_1_GetCaught.lua#L341) +14 |
| `UserEvent` | `Util.UserEvent` | `0x00758980` | — | `UserEvent(s1, hObj2)` | inferred | body only |

### `Object` — 44 bindings

| Binding (C++ symbol) | Namespaced form | VA | Source (file:line) | Signature | Conf. | Evidence |
|---|---|---|---|---|---|---|
| `ActuateObject` | `Object.Actuate` | `0x00739210` | — | `Actuate([hObj1], b2)` | confirmed | [Act_1_BarFight.lua:1538](../saboteur-luacd/src/Missions/Act_1_BarFight.lua#L1538) +30 |
| `CreateSpawner` | `Object.CreateSpawner` | `0x0073c730` | — | `CreateSpawner()` ⚠ | inferred | body only |
| `DespawnObject` | `Object.Despawn` | `0x0073bda0` | — | `Despawn([hObj1], [n2], [b3], n4, [n5], n6, b7)` | confirmed | [Act_1_Escape.lua:433](../saboteur-luacd/src/Missions/Act_1_Escape.lua#L433) +23 |
| `EnableAnimatedPropPart` | `Object.EnableAnimatedPropPart` | `0x00739620` | — | `EnableAnimatedPropPart([hObj1], b2, s3)` | confirmed | [Act_3_Mission_3.lua:2181](../saboteur-luacd/src/Missions/Act_3_Mission_3.lua#L2181) +3 |
| `EnableSpawner` | `Object.EnableSpawner` | `0x00738dc0` | — | `EnableSpawner([hObj1], [b2])` | confirmed | [Act_1_BarFight.lua:254](../saboteur-luacd/src/Missions/Act_1_BarFight.lua#L254) +51 |
| `ForceClose` | `Object.ForceClose` | `0x00739560` | — | `ForceClose([hObj1], [b2])` | confirmed | [Act_1_Factory.lua:179](../saboteur-luacd/src/Missions/Act_1_Factory.lua#L179) +35 |
| `ForceOpen` | `Object.ForceOpen` | `0x007394a0` | — | `ForceOpen([hObj1], [b2])` | confirmed | [Act_1_BarFight.lua:1642](../saboteur-luacd/src/Missions/Act_1_BarFight.lua#L1642) +57 |
| `GetAngle` | `Object.GetAngle` | `0x00737b70` | — | `GetAngle([hObj1])` | confirmed | [Act_1_GetCaught.lua:1075](../saboteur-luacd/src/Missions/Act_1_GetCaught.lua#L1075) +31 |
| `GetAttrPtAttachments` | `Object.GetAttrPtAttachments` | `0x00738c30` | — | `GetAttrPtAttachments([hObj1])` | confirmed | [ShopManager.lua:245](../saboteur-luacd/src/Managers/ShopManager.lua#L245) +6 |
| `GetBoneHandleFromCarriage` | `Object.GetBoneHandleFromCarriage` | `0x00739770` | — | `GetBoneHandleFromCarriage(hObj1, b2)` | confirmed | [SOE_2_Mission_2.lua:420](../saboteur-luacd/src/Missions/SOE_2_Mission_2.lua#L420) +2 |
| `ObjectGetDistance` | `Object.GetDistance` | `0x00738a10` | — | `GetDistance([hObj1], hObj2, n3, n4)` | confirmed | [SoldierState_PaperCheckLeader.lua:132](../saboteur-luacd/src/Experimental/SoldierState_PaperCheckLeader.lua#L132) +39 |
| `GetHealth` | `Object.GetHealth` | `0x0073b250` | — | `GetHealth([hObj1])` | confirmed | [__UtilFunctions.lua:288](../saboteur-luacd/src/Includes/__UtilFunctions.lua#L288) +55 |
| `GetMaxHealth` | `Object.GetMaxHealth` | `0x00737f70` | — | `GetMaxHealth([hObj1])` | confirmed | [Act_1_Farm.lua:273](../saboteur-luacd/src/Missions/Act_1_Farm.lua#L273) +8 |
| `GetObjectsWithLabel` | `Object.GetObjectsWithLabel` | `0x00738fc0` | — | `GetObjectsWithLabel()` ⚠ | confirmed | [Paris_1_Mission_6.lua:1852](../saboteur-luacd/src/Missions/Paris_1_Mission_6.lua#L1852) +1 |
| `GetPosition` | `Object.GetPosition` | `0x00737aa0` | — | `GetPosition([hObj1])` | confirmed | [Checkpoint.lua:47](../saboteur-luacd/src/Experimental/Checkpoint.lua#L47) +280 |
| `IsAlive` | `Object.IsAlive` | `0x00737df0` | — | `IsAlive([hObj1])` | confirmed | [WRAPPER_Vehicle.lua:117](../saboteur-luacd/src/Includes/WRAPPER_Vehicle.lua#L117) +146 |
| `IsAttrPt` | `Object.IsAttrPt` | `0x00738d20` | — | `IsAttrPt([hObj1])` | confirmed | [SabTaskObjectiveInteract.lua:39](../saboteur-luacd/src/Modules/SabTaskObjectiveInteract.lua#L39) +3 |
| `IsDead` | `Object.IsDead` | `0x00737d50` | — | `IsDead([hObj1])` | confirmed | [MgrHarasser.lua:45](../saboteur-luacd/src/Experimental/MgrHarasser.lua#L45) +7 |
| `IsDoorOpen` | `Object.IsDoorOpen` | `0x007393e0` | — | `IsDoorOpen([hObj1])` | confirmed | [P1FP_Jailbreak.lua:679](../saboteur-luacd/src/Missions/P1FP_Jailbreak.lua#L679) +10 |
| `ObjectIsHuman` | `Object.IsHuman` | `0x0073c670` | — | `IsHuman([hObj1])` | confirmed | [Act_1_Farm.lua:157](../saboteur-luacd/src/Missions/Act_1_Farm.lua#L157) +8 |
| `IsInvincibleToAI` | `Object.IsInvincibleToAI` | `0x00738250` | — | `IsInvincibleToAI([hObj1])` | confirmed | [__UtilFunctions.lua:401](../saboteur-luacd/src/Includes/__UtilFunctions.lua#L401) |
| `ObjectIsVehicle` | `Object.IsVehicle` | `0x00738b80` | — | `IsVehicle([hObj1])` | confirmed | [Checkpoint.lua:83](../saboteur-luacd/src/Experimental/Checkpoint.lua#L83) +16 |
| `Kill` | `Object.Kill` | `0x00737e90` | — | `Kill([hObj1])` | confirmed | [MISSION_CFrench.lua:354](../saboteur-luacd/src/Experimental/MISSION_CFrench.lua#L354) +105 |
| `LocatorSetParent` | `Object.LocatorSetParent` | `0x00738950` | — | `LocatorSetParent([hObj1], [hObj2])` | confirmed | [Act_1_Escape.lua:212](../saboteur-luacd/src/Missions/Act_1_Escape.lua#L212) |
| `MissionTeleportPlayerToLocator` | `Object.PlayerTeleportToLocator` | `0x0073ab70` | Object.cpp:652 | `PlayerTeleportToLocator([hObj1], [b2])` ⚠ | confirmed | assert [Act_1_BarFight.lua:296](../saboteur-luacd/src/Missions/Act_1_BarFight.lua#L296) +36 |
| `MissionTeleportPlayerToPos` | `Object.PlayerTeleportToPos` | `0x0073a930` | Object.cpp:592 | `PlayerTeleportToPos(n1, n2, [n3], n4, [b5])` ⚠ | confirmed | assert [Act_1_GetCaught.lua:306](../saboteur-luacd/src/Missions/Act_1_GetCaught.lua#L306) +13 |
| `SetDoorCloseDelay` | `Object.SetDoorCloseDelay` | `0x00739300` | — | `SetDoorCloseDelay([hObj1], n2)` | confirmed | [Connect_JulesisDeadCin.lua:92](../saboteur-luacd/src/Missions/Connect_JulesisDeadCin.lua#L92) |
| `SetGrenadeToExplode` | `Object.SetGrenadeToExplode` | `0x00739860` | — | `SetGrenadeToExplode([hObj1], n2)` | inferred | body only |
| `SetHealth` | `Object.SetHealth` | `0x00738020` | — | `SetHealth(hObj1, n2)` | confirmed | [Act_1_BarFight.lua:467](../saboteur-luacd/src/Missions/Act_1_BarFight.lua#L467) +65 |
| `SetInvincible` | `Object.SetInvincible` | `0x007380f0` | — | `SetInvincible(hObj1, b2)` | confirmed | [__UtilFunctions.lua:320](../saboteur-luacd/src/Includes/__UtilFunctions.lua#L320) +79 |
| `SetInvincibleToAI` | `Object.SetInvincibleToAI` | `0x007381a0` | — | `SetInvincibleToAI(hObj1, b2)` | confirmed | [__UtilFunctions.lua:422](../saboteur-luacd/src/Includes/__UtilFunctions.lua#L422) +33 |
| `SetObjectKeyFramed` | `Object.SetKeyFramed` | `0x007383d0` | — | `SetKeyFramed()` ⚠ | confirmed | [Paris_2_Mission_5.lua:2438](../saboteur-luacd/src/Missions/Paris_2_Mission_5.lua#L2438) |
| `SetOnActiveMission` | `Object.SetOnActiveMission` | `0x007382f0` | — | `SetOnActiveMission(hObj1, b2, b3)` | confirmed | [SabTaskMission.lua:335](../saboteur-luacd/src/Modules/SabTaskMission.lua#L335) |
| `ObjectSetOnTrappedCallback` | `Object.SetOnTrappedCallback` | `0x0073ad20` | — | `SetOnTrappedCallback(hObj1, s2, t3)` ⚠ | inferred | body only |
| `SetShouldNeverRegisterGameObjectEvents` | `Object.SetShouldNeverRegisterGameObjectEvents` | `0x00737c80` | — | `SetShouldNeverRegisterGameObjectEvents(hObj1, b2)` | confirmed | [Act_1_GetCaught.lua:2209](../saboteur-luacd/src/Missions/Act_1_GetCaught.lua#L2209) +4 |
| `SpawnObject` | `Object.Spawn` | `0x0073b340` | — | `Spawn(?1, ?2, ?3, ?4, ?5, t6)` ⚠ | confirmed | [WRAPPER_Actor.lua:242](../saboteur-luacd/src/Includes/WRAPPER_Actor.lua#L242) +23 |
| `SpawnAICrowdBlocker` | `Object.SpawnAICrowdBlocker` | `0x0073aff0` | — | `SpawnAICrowdBlocker(n1, n2, n3, n4, n5, n6, t7)` ⚠ | inferred | body only |
| `SpawnFromList` | `Object.SpawnFromList` | `0x0073c100` | — | `SpawnFromList(s1, i2, t3, [b4])` ⚠ | confirmed | [WRAPPER_Actor.lua:229](../saboteur-luacd/src/Includes/WRAPPER_Actor.lua#L229) |
| `SpawnInVehicle` | `Object.SpawnInVehicle` | `0x0073c480` | — | `SpawnInVehicle(s1, s2, hObj3, s4, t5, t6)` | confirmed | [Act_1_Farm.lua:416](../saboteur-luacd/src/Missions/Act_1_Farm.lua#L416) +23 |
| `SpawnObjectOnRoad` | `Object.SpawnOnRoad` | `0x0073b810` | — | `SpawnOnRoad(?1, ?2, ?3, ?4, ?5, t6)` ⚠ | confirmed | [Saboteur.lua:378](../saboteur-luacd/src/Modules/Behavior/Player/Saboteur.lua#L378) +3 |
| `SpawnerPurge` | `Object.SpawnerPurge` | `0x00738f10` | — | `SpawnerPurge([hObj1], [b2])` | confirmed | [Act_1_BarFight.lua:256](../saboteur-luacd/src/Missions/Act_1_BarFight.lua#L256) +19 |
| `SpawnerQueueSpawn` | `Object.SpawnerQueueSpawn` | `0x0073ae90` | — | `SpawnerQueueSpawn([hObj1], [s2], [s3], [t4], [t5])` | confirmed | [AggroSpawner.lua:123](../saboteur-luacd/src/Modules/Libraries/AggroSpawner.lua#L123) |
| `SpawnerReset` | `Object.SpawnerReset` | `0x00738e80` | — | `SpawnerReset([hObj1])` | confirmed | [Act_3_Mission_3.lua:2474](../saboteur-luacd/src/Missions/Act_3_Mission_3.lua#L2474) +1 |
| `TeleportObject` | `Object.Teleport` | `0x007385f0` | — | `Teleport()` ⚠ | confirmed | [MISSION_CFrench.lua:390](../saboteur-luacd/src/Experimental/MISSION_CFrench.lua#L390) +43 |

### `Trigger` — 23 bindings

| Binding (C++ symbol) | Namespaced form | VA | Source (file:line) | Signature | Conf. | Evidence |
|---|---|---|---|---|---|---|
| `AddFilter` | `Trigger.AddFilter` | `0x0074a580` | — | `AddFilter(hObj1, i2, [s3], t4, [t5], [i6], [b7])` | inferred | body only |
| `AddNoEscSpawnZone` | `Trigger.AddNoEscSpawnZone` | `0x00749a50` | — | `AddNoEscSpawnZone([hObj1])` | confirmed | [NoEscSpawnZone.lua:6](../saboteur-luacd/src/Modules/Behavior/Triggers/NoEscSpawnZone.lua#L6) |
| `AddRoadBlock` | `Trigger.AddRoadBlock` | `0x00749950` | — | `AddRoadBlock([hObj1])` | confirmed | [RoadBlockZone.lua:6](../saboteur-luacd/src/Modules/Behavior/Triggers/RoadBlockZone.lua#L6) |
| `TrigClearCallback` | `Trigger.ClearCallback` | `0x0074ad70` | — | `ClearCallback(hObj1, i2)` | confirmed | [P1FP_EustacheSniper.lua:543](../saboteur-luacd/src/Missions/P1FP_EustacheSniper.lua#L543) +26 |
| `CreateCafe` | `Trigger.CreateCafe` | `0x0074ae90` | — | `CreateCafe([hObj1])` | confirmed | [CafeRegion.lua:4](../saboteur-luacd/src/Modules/Behavior/Triggers/CafeRegion.lua#L4) |
| `TrigCreateDeleteZone` | `Trigger.CreateDeleteZone` | `0x0074af50` | — | `CreateDeleteZone([hObj1])` | confirmed | [DeleteZone.lua:6](../saboteur-luacd/src/Modules/Behavior/Triggers/DeleteZone.lua#L6) |
| `TrigCreateFightBackZone` | `Trigger.CreateFightBackZone` | `0x0074b570` | — | `CreateFightBackZone([hObj1])` | inferred | body only |
| `TrigCreateHostileZone` | `Trigger.CreateHostileZone` | `0x0074b330` | — | `CreateHostileZone([hObj1])` | confirmed | [HostileZone.lua:6](../saboteur-luacd/src/Modules/Behavior/Triggers/HostileZone.lua#L6) |
| `TrigCreateNoFlyZone` | `Trigger.CreateNoFlyZone` | `0x0074b3f0` | — | `CreateNoFlyZone([hObj1])` | confirmed | [NoFlyZone.lua:6](../saboteur-luacd/src/Modules/Behavior/Triggers/NoFlyZone.lua#L6) |
| `TrigCreateRedZone` | `Trigger.CreateRedZone` | `0x0074b150` | — | `CreateRedZone([hObj1])` | confirmed | [RedZone.lua:6](../saboteur-luacd/src/Modules/Behavior/Triggers/RedZone.lua#L6) |
| `TrigCreateRestrictedArea` | `Trigger.CreateRestrictedArea` | `0x0074b010` | — | `CreateRestrictedArea([hObj1], [i2], [b3], [b4])` | confirmed | [RestrictedArea.lua:12](../saboteur-luacd/src/Modules/Behavior/Triggers/RestrictedArea.lua#L12) +6 |
| `TrigCreateSuspicionZone` | `Trigger.CreateSuspicionZone` | `0x0074b210` | — | `CreateSuspicionZone([hObj1], [b2], [b3])` | confirmed | [SuspicionZone.lua:6](../saboteur-luacd/src/Modules/Behavior/Triggers/SuspicionZone.lua#L6) +2 |
| `TrigCreateWorldBorderZone` | `Trigger.CreateWorldBorderZone` | `0x0074b4b0` | — | `CreateWorldBorderZone([hObj1])` | confirmed | [WorldBorder.lua:6](../saboteur-luacd/src/Modules/Behavior/Triggers/WorldBorder.lua#L6) |
| `DoNotWaitFor` | `Trigger.DoNotWaitFor` | `0x0074aa70` | — | `DoNotWaitFor(hObj1, hObj2)` | confirmed | [FP_CountryRace_1.lua:189](../saboteur-luacd/src/Missions/FP_CountryRace_1.lua#L189) +33 |
| `TriggerEnable` | `Trigger.Enable` | `0x0074a470` | — | `Enable(hObj1, b2)` | confirmed | [Act_3_Mission_3.lua:1139](../saboteur-luacd/src/Missions/Act_3_Mission_3.lua#L1139) +37 |
| `TriggerGetAllWithin` | `Trigger.GetAllWithin` | `0x0074abc0` | — | `GetAllWithin([hObj1], [i2])` | confirmed | [Act_1_GetCaught.lua:568](../saboteur-luacd/src/Missions/Act_1_GetCaught.lua#L568) +44 |
| `IsPointWithin` | `Trigger.IsPointWithin` | `0x00749b50` | — | `IsPointWithin([hObj1], n2, n3, n4)` | confirmed | [P3FP_Hit.lua:274](../saboteur-luacd/src/Missions/P3FP_Hit.lua#L274) |
| `RemoveFilter` | `Trigger.RemoveFilter` | `0x0074a780` | — | `RemoveFilter(hObj1, i2)` | inferred | body only |
| `RemoveNoEscSpawnZone` | `Trigger.RemoveNoEscSpawnZone` | `0x00749ad0` | — | `RemoveNoEscSpawnZone([hObj1])` | confirmed | [NoEscSpawnZone.lua:10](../saboteur-luacd/src/Modules/Behavior/Triggers/NoEscSpawnZone.lua#L10) |
| `RemoveRoadBlock` | `Trigger.RemoveRoadBlock` | `0x007499d0` | — | `RemoveRoadBlock([hObj1])` | confirmed | [RoadBlockZone.lua:10](../saboteur-luacd/src/Modules/Behavior/Triggers/RoadBlockZone.lua#L10) |
| `SetAllowInVeh` | `Trigger.SetAllowInVeh` | `0x0074b630` | — | `SetAllowInVeh(hObj1, b2)` | confirmed | [SOE_Zeppelin.lua:700](../saboteur-luacd/src/Missions/SOE_Zeppelin.lua#L700) |
| `SetAllowOnFoot` | `Trigger.SetAllowOnFoot` | `0x0074b730` | — | `SetAllowOnFoot(hObj1, b2)` | confirmed | [SOE_Zeppelin.lua:701](../saboteur-luacd/src/Missions/SOE_Zeppelin.lua#L701) |
| `WaitFor` | `Trigger.WaitFor` | `0x0074a860` | — | `WaitFor(hObj1, hObj2, [s3], [t4], [t5], [i6], [b7])` | confirmed | [WRAPPER_Event.lua:78](../saboteur-luacd/src/Includes/WRAPPER_Event.lua#L78) +308 |

### `SaveLoad` — 13 bindings

| Binding (C++ symbol) | Namespaced form | VA | Source (file:line) | Signature | Conf. | Evidence |
|---|---|---|---|---|---|---|
| `SaveLoadClearcheckpoint` | `SaveLoad.ClearCheckpoint` | `0x00741ed0` | — | body absent; corpus arity [0] | open | [SabTaskMission.lua:279](../saboteur-luacd/src/Modules/SabTaskMission.lua#L279) +1 |
| `SaveLoadClearSnapshot` | `SaveLoad.ClearSnapshot` | `0x00741ef0` | — | body absent; corpus arity [0] | open | [SabTask.lua:1621](../saboteur-luacd/src/Modules/SabTask.lua#L1621) +5 |
| `SaveLoadCreateAutoSave` | `SaveLoad.CreateAutoSave` | `0x00741a90` | — | `CreateAutoSave(t1, [s2])` | confirmed | [SabTaskGameMaster.lua:160](../saboteur-luacd/src/Modules/SabTaskGameMaster.lua#L160) |
| `SaveLoadCreateSnapshot` | `SaveLoad.CreateSnapshot` | `0x00741b50` | — | `CreateSnapshot(t1, [s2])` | confirmed | [SabTaskMission.lua:382](../saboteur-luacd/src/Modules/SabTaskMission.lua#L382) |
| `SaveLoadLoadCheckpoint` | `SaveLoad.LoadCheckpoint` | `0x00741e90` | SaveLoad.cpp:142 | `LoadCheckpoint()` | confirmed | assert [Act_1_Race.lua:549](../saboteur-luacd/src/Missions/Act_1_Race.lua#L549) |
| `SaveLoadLoadLuaFloat` | `SaveLoad.LoadFloat` | `0x007413b0` | — | `LoadFloat()` | inferred | body only |
| `SaveLoadLoadLuaString` | `SaveLoad.LoadString` | `0x00741420` | — | `LoadString()` | confirmed | [SabTask.lua:1631](../saboteur-luacd/src/Modules/SabTask.lua#L1631) +2 |
| `SaveLoadLoadLuaTable` | `SaveLoad.LoadTable` | `0x00741950` | — | `LoadTable()` | confirmed | [SabTask.lua:1636](../saboteur-luacd/src/Modules/SabTask.lua#L1636) +19 |
| `SaveLoadSaveCheckpoint` | `SaveLoad.SaveCheckpoint` | `0x007419d0` | — | `SaveCheckpoint([t1], [hObj2])` | confirmed | [SabTask.lua:1822](../saboteur-luacd/src/Modules/SabTask.lua#L1822) |
| `SaveLoadSaveLuaFloat` | `SaveLoad.SaveFloat` | `0x007412e0` | — | `SaveFloat([num|str1])` | inferred | body only |
| `SaveLoadSaveLuaString` | `SaveLoad.SaveString` | `0x00741350` | — | `SaveString([s1])` | confirmed | [SabTask.lua:1596](../saboteur-luacd/src/Modules/SabTask.lua#L1596) +2 |
| `SaveLoadSaveLuaTable` | `SaveLoad.SaveTable` | `0x00741210` | — | `SaveTable([t1])` | confirmed | [SabTask.lua:1597](../saboteur-luacd/src/Modules/SabTask.lua#L1597) +19 |
| `SaveLoadSetupSpecialLuaTimerCallback` | `SaveLoad.SetupSpecialLuaTimerCallback` | `0x00741c10` | SaveLoad.cpp:252 | `SetupSpecialLuaTimerCallback(t1, s2, n3)` | confirmed | assert [SabTaskMission.lua:172](../saboteur-luacd/src/Modules/SabTaskMission.lua#L172) |

## How the subsystem actually works

### `Util.Assert` is a no-op in retail, and that changes how you read the whole corpus

This is the single most consequential finding in the family, and it is confirmed at byte level rather than
inferred. `Util.Assert` (C++ symbol `LuaAssert`) is `FUN_0074c650 @0x0074c650`, 106 bytes, and its entire
body after the lazy-singleton prologue is:

```c
FUN_006f8470(param_1);
cVar1 = FUN_006f7120(1);        // arg 1 is a boolean?
if (cVar1 != '\0') {
  FUN_006f6e60(1);              // fetch it ... and discard it
  cVar1 = FUN_006f7160(2);      // arg 2 is a string?
  if (cVar1 != '\0') {
    FUN_006f7a80(2);            // fetch it ... and discard it
  }
}
return;
```

Both fetched values are dropped on the floor. There is no comparison against the condition, no call to a
logging or assert sink, no `lua_error`, not even the `FUN_00db7e10` copy-out that normally follows every
`FUN_006f7a80`. The assertion body was compiled out of the retail build and only the argument marshalling
survived. **`Util.Assert(false, "...")` does nothing at all.**

The corpus calls it **174 times**. Every one of them is dead code in retail. That matters because the script
layer's entire error-reporting strategy routes through it —
[`WRAPPER_Util.lua:1-17`](../saboteur-luacd/src/Includes/WRAPPER_Util.lua) is the canonical example:

```lua
function WRAPPER_CheckForHandle(a_vVariable)
  local sType = type(a_vVariable)
  if sType == "userdata" then return a_vVariable
  elseif sType == "string" then
    local hObject = Util.GetHandleByName(a_vVariable)
    if hObject == nil then
      Util.Assert(false, "Wrapper cannot get handle for (" .. a_vVariable .. ")!")
      return                                   -- returns nil, silently
    else return hObject end
  else
    Util.Assert(false, "Passed variable is neither a HANDLE nor STRING!")
  end
end
```

In a dev build that mis-typed argument produces a diagnostic. In retail it returns `nil`, the caller passes
`nil` into a binding, the binding's `FUN_006f71a0` handle check fails, and — per §6 of the ABI doc — the
binding silently returns without doing anything. Combined with the *inferred* rule that no binding raises a
Lua error, **a script bug in retail Saboteur plausibly has no observable signal at all**: no log, no assert,
no exception, just an action that quietly does not happen. That would be the mechanism behind a whole class
of this game's shipped bugs.

Two honest caveats on that last step, because it is the doc's most quotable sentence and it rests on a
weaker leg than the stub itself. The `Util.Assert` stub is **confirmed** at byte level. "No binding raises a
Lua error" is **inferred**: [02](02-marshalling-abi.md) tiers it *inferred (sampled)* and lists an
exhaustive sweep as an open question. A sweep of all **202 readable bodies in this family** finds no call to
`lua_error`/`luaL_error` or to the diagnostic primitives `FUN_00402c50` / `FUN_004018f0` — which corroborates
it here — but 51 bodies are unreadable and delegates were not followed exhaustively, so the negative is not
proven. `print()` also remains a live signal path the corpus uses independently of `Util.Assert` (e.g.
[`WRAPPER_Event.lua:76`](../saboteur-luacd/src/Includes/WRAPPER_Event.lua#L76)), so "no signal whatsoever"
overstates it: the accurate claim is that the *engine* returns no error, not that the script layer is mute.

A nice corroboration of the "extra arguments are silently dropped" rule falls out of the same binding.
`Util.Assert` reads exactly two arguments, but
[`WRAPPER_Vehicle.lua:150`](../saboteur-luacd/src/Includes/WRAPPER_Vehicle.lua) calls it with four:

```lua
Util.Assert(false, "No handle for ", a_actor, " in VEHICLE_MoveToBoardAtPosition")
```

The author meant `..` and typed `,`. Arguments 3 and 4 are never read, so even in a dev build the message
would have been truncated to `"No handle for "`. Two latent bugs stacked on a third — and none of them can
fire, because the binding is a stub. `Util.EnableTutorial` (corpus passes up to 4, engine reads 2) and
`Util.AddMissionMessage` (corpus passes 12, engine reads 10) are the other two instances of scripts
over-supplying arguments into the void.

### The assignment's premise about `FUN_0099bc00` does not survive contact with the evidence

The brief for this family states that "the error/assert path via `FUN_0099bc00` matters". It does not — not
for this family, and not as an assert path at all. The facts:

- `FUN_0099bc00 @0x0099bc00` has exactly **7 callers in the entire 54 MB decomp**:
  `0x008ed2af`, `0x005881bd`, `0x005881f0`, `0x00589b29`, `0x006ab2ee`, `0x0058a428`, `0x0071430b`.
- **Zero of the 253 bindings in this family call it.** `Util.Assert` — the one binding whose name implies it
  should — does not reference it.
- The single Lua-binding caller is `0x0071430b`, inside `FUN_00714230` = `Actor.Ragdoll`, which belongs to
  [10-family-actor-human.md](10-family-actor-human.md).
- Its shape is `FUN_0099bc00(&{file, symbol, line}, obj, 0, 0x3f800000)` — a source-location record, an
  object, and a float `1.0f` — forwarding to `FUN_00999cd0` after a virtual call on a **sub-object stored at
  `obj+0xdb8`**, dispatched through slot `+8` of *that* object's vtable
  (`(**(code **)(*(int *)(param_2 + 0xdb8) + 8))(...)`). `0xdb8` is a field offset, not a vtable offset. It
  sits on the **success** path, not a failure path.

A four-argument call carrying a source location, an object, and a `1.0f` weight, invoked from seven sites
on success, is not an assert. It is more consistent with a debug-draw or telemetry/profiling emit, but I
did not trace `FUN_00999cd0` and **its meaning is open** (below). What is confirmed is the negative: the
family's error path is not `FUN_0099bc00`, because this family has no error path.

### The event system is the script layer's only scheduler

`Util.CreateEvent` is the busiest binding in the family — **1029 call sites** across the corpus, more than
five times any other. It is the mechanism by which every mission script waits for anything. Its signature
is `Util.CreateEvent(tDescriptor, sCallbackName, tSelf, tUserData, bPersistent)` and it returns **one
number, an event ID** (`LuaGlueFunctor0R`, pushed via `FUN_006f7040` at `0x007588c2`).

The registered function `FUN_007587a0 @0x007587a0` is a **dispatcher**, which is why naive scraping reads
it as one-argument. It checks that argument 1 is a table, then routes on the descriptor's contents:

| Descriptor has | Route | Delegate |
|---|---|---|
| a `Target` field (handle) | targeted event | `FUN_007585c0 @0x007585c0` |
| `EventType` matching one interned string (`DAT_00fe59c8`) | special-cased type | `FUN_0074c120 @0x0074c120` |
| otherwise | generic path | `FUN_006f9aa0 @0x006f9aa0` |

Both traced delegates parse arguments 2–5 identically — `s2` callback name (non-empty, required), `t3`
self, `t4` user data, `b5` persistent — build a 600-byte event object (`FUN_00db39e0(600,6)`), resolve the
`EventType` string to a factory via `FUN_00708d90`, and return the ID from `+0x14`. The `bPersistent` flag
is written as bit 1 of `+0x254`. The two delegates differ only in argument *guarding*: `FUN_007585c0` gates
arguments 3–5 behind `lua_gettop` count checks, while `FUN_0074c120` relies on type checks alone. The
corpus exercises all of 2, 3, 4 and 5 arguments, which is what confirms the derived shape.

Note the callback is a **name string**, never a function value — the family-wide rule from §10 of the ABI
doc. [`Checkpoint.lua:38`](../saboteur-luacd/src/Experimental/Checkpoint.lua) is representative:

```lua
local tFlypaperEvent = {
  EventType = "OnTriggerEnter",
  Target = Util.GetHandleByName(self.SMEDTable.sFlypaperTriggerName)
}
self.eFlypaperListener = Util.CreateEvent(tFlypaperEvent, "Checkpoint.OnFlypaperZoneEntered", self, {}, true)
```

Teardown is by ID: `Util.KillEvent` (`0x0074c2c0`, 480 call sites) accepts **either** a number **or** a
string — it type-tests argument 1 with `FUN_006f7140` first and falls through to `FUN_006f7160`, taking
`FUN_006f84f0(id)` on the numeric branch and a name lookup on the string branch. It is one of the few
genuine overloads in the seam. `Util.KillAllEvents(hObj)` (`0x007588e0`) kills every event bound to one
object handle.

### The event-descriptor schema (an extension to the ABI doc)

Descriptor tables are not read with the positional `FUN_006f7*` primitives at all. There is a **parallel
table-field accessor family** that the ABI cheat sheet does not cover. Each member has the identical shape
`__thiscall (wrapper, stackIndex, "FieldName", &bFound)` — push the field name, `lua_gettable`, type-test at
`-1`, convert, and report presence through the out-flag. All are guarded by a `lua_gettop() > 0x27` stack
check that fails closed.

| Accessor | Field type | Lowers to | Field names observed in the binary |
|---|---|---|---|
| `FUN_00658080` | **handle** | `lua_type(L,-1)==2` → `lua_touserdata` | `Target`, `Target1`, `Target2`, `ObjectHandle`, `ObjectA`, `ObjectB`, `BoneA`, `BoneB`, `Locator`, `Vehicle`, `VehicleHandle`, `Passenger`, `SeatName`, `hController` |
| `FUN_01639630` | **string** | `lua_isstring` → `lua_tolstring` | `EventType`, `EventName`, `CinematicName`, `Anim1`, `Anim2`, `Sound1`, `Sound2`, `Text1`, `Text2`, `Locator`, `Vehicle`, `VehicleBlueprint`, `SeatName`, `sName`, `sScript`, `sWTFBP`, `sExtTeleLoc`, `sIntTeleLoc` |
| `FUN_01639350` | **boolean** | `lua_type(L,-1)==1` → `lua_toboolean` | `WaitForGameObject`, `WaitForPathfinding`, `WaitForPhysics`, `WaitForStreamOut`, `Check3D`, `Negate`, `bUnlocked`, plus ~27 input-action names (`Sprint`, `Sneak`, `Grenade`, `Nitrous`, …) |
| `FUN_01639230` | **table** | type-test → `thunk_FUN_00481ae6` (deep copy) | `Objects`, `SeatNames` |
| `FUN_01638f90` | **function** | `lua_type(L,-1)==6` | — |

Two things fall out of this table that are not obvious from the Lua side:

1. **`Locator`, `Vehicle`, and `SeatName` appear under *both* the handle and the string accessor.** The
   engine accepts either a live handle or a name to resolve, per field. That is the same
   handle-or-name duality the `WRAPPER_*` layer implements in Lua, but here it is in the engine.
2. **The `WaitFor*` booleans are descriptor fields, not bindings.** `WaitForPathfinding`,
   `WaitForPhysics`, `WaitForStreamOut` and `WaitForGameObject` are how a script says "don't fire this
   event until the world is ready" — which is what makes `EventType = "StreamEvent"` with an `Objects`
   list ([`Checkpoint.lua:17-27`](../saboteur-luacd/src/Experimental/Checkpoint.lua)) the standard
   idiom for "run my setup once these six named objects have streamed in".

The `Objects` and `ObjectHandle` fields are read at `FUN_007088b0`, `FUN_00708a60` and `FUN_0070b700` —
functions reached from the untraced generic path, using a *variable* stack index, which is precisely why
they are invisible to literal scraping. The **full descriptor schema per `EventType` is open** (below).

### `SaveLoad` is a positional stream, not a key-value store

The `SaveLoad` table has no keys anywhere in it, and that is the whole design. `SaveLoad.LoadFloat`
(`FUN_007413b0 @0x007413b0`) takes **no arguments at all**:

```c
FUN_006f8470(param_2);
fVar2 = (float10)FUN_006524c0();   // pull next float from the stream cursor
FUN_006f7060((float)fVar2);        // push it
return 1;
```

`SaveLoad.SaveFloat` (`0x007412e0`) is the mirror: one argument in, `FUN_00652440(float)` out. `SaveTable`
(`0x00741210`) serialises argument 1 through `thunk_FUN_00481ae6` — the same deep-copy routine the
`Objects` field accessor uses — into `FUN_006529e0`. Save and load are a **cursor over a serial stream**:
the Nth `Load*` returns whatever the Nth `Save*` wrote, and nothing names or checks it.

The corpus proves the model exactly. [`SabTask.lua:1594-1610`](../saboteur-luacd/src/Modules/SabTask.lua)
writes a version string then fourteen values; [`SabTask.lua:1631-1649`](../saboteur-luacd/src/Modules/SabTask.lua)
reads them back in **positionally identical order**:

| # | `SaveGameCallback` (1596→) | `LoadGameCallback` (1631→) |
|---|---|---|
| 1 | `SaveString(SabTask._saveversion)` | `local saveversion = SaveLoad.LoadString()` |
| 2 | `SaveTable(SabTask.tOpenMissionList)` | `SabTask.tOpenMissionList = SaveLoad.LoadTable()` |
| 3 | `SaveTable(StarterManager.Save_IsStarterHiddenList)` | `StarterManager.Save_IsStarterHiddenList = SaveLoad.LoadTable()` |
| … | … | … |
| 15 | `SaveString(sSabInterior)` | `tempPlayersInterior = SaveLoad.LoadString()` |

The leading `_saveversion` string is the only integrity mechanism: read it first, and if it does not match,
bail before the stream desynchronises. **Insert or remove a single `Save*` call and every subsequent
`Load*` in the save file shifts by one slot** — with no type error, because `LoadFloat` on string data just
returns whatever `FUN_006524c0` yields. This is the strongest argument in the family for why the script
layer passes names rather than handles across a save boundary (§7 of the ABI doc: handles are
session-scoped and do not survive save/load).

`SaveLoad.SetupSpecialLuaTimerCallback` is anchored at `Script\Interface\SaveLoad.cpp:252` and
`SaveLoad.LoadCheckpoint` at `SaveLoad.cpp:142` — two of the family's five assertion-string anchors.

### `Trigger` is a thin, remarkably uniform wrapper over volumes

The 23 `Trigger` bindings are the most regular set in the family: **all 23 take a handle as argument 1**,
and **9 are `Trigger.CreateXxxZone(hVolume)`-shaped** taggers that assign a behaviour to an existing volume —
`CreateRedZone`, `CreateHostileZone`, `CreateNoFlyZone`, `CreateSuspicionZone`, `CreateRestrictedArea`,
`CreateWorldBorderZone`, `CreateDeleteZone`, `CreateFightBackZone`, `CreateCafe`. Seven of those nine take
nothing but the volume handle; `CreateRestrictedArea` and `CreateSuspicionZone` carry extra flags. The zone
volume itself is authored in the level editor; Lua only assigns semantics to it at runtime.

**Three** members are `LuaGlueFunctor0R` and return a value: `Trigger.IsPointWithin(hTrig, n, n, n)`,
`Trigger.GetAllWithin(hTrig, i)` — and `Trigger.WaitFor`, which returns a **trigger-event ID**. That last one
matters and is easy to miss: 58 corpus call sites bind its result, e.g.
[`WRAPPER_Event.lua:78`](../saboteur-luacd/src/Includes/WRAPPER_Event.lua#L78) does
`local hTriggerID = Trigger.WaitFor(...)` and hands it to `self:RegisterTriggerEvent(hTriggerID, ...)`.
`Trigger.WaitFor` is therefore ID-issuing in the same way `Util.CreateEvent` is.

`Trigger.WaitFor` / `Trigger.DoNotWaitFor` are the interesting pair, and they connect to the `WaitFor*`
descriptor booleans above — the same "gate on world readiness" concept, exposed once as a binding and once
as an event-descriptor field. I have not established whether they share an implementation; that is open.

### `Object` is the object-lifecycle table, and its spawners are the family's worst-derived corner

40 of 44 `Object` bindings are corroborated by corpus call sites — the best ratio in the family. The simple
half is exactly what it looks like: `Object.GetPosition`, `GetHealth`, `IsAlive`, `IsDead`, `Kill`,
`SetInvincible`, `Teleport` — all handle-first, most of them `LuaGlueFunctor0R` getters.

The spawner half (`Object.Spawn`, `SpawnFromList`, `SpawnOnRoad`, `SpawnInVehicle`, `SpawnAICrowdBlocker`,
`CreateSpawner`) is where this method degrades, and I want to be explicit rather than quietly optimistic.
These are variadic — they call `FUN_006f6970` (`lua_gettop`) repeatedly and then walk arguments with a
*register-held* index (`FUN_006f7100(iVar11)`, `FUN_006f7160()` with the index lost). `Object.Spawn`'s
derived signature says 6 arguments; the corpus passes 8, 9 and 10:

```lua
Object.Spawn(a_sBlueprintName, x, y, z, nRotation, nil, "_ACTOR_SpawnAtLocatorAndAttack", nil, {hTarget}, false)
```
— [`WRAPPER_Actor.lua:242`](../saboteur-luacd/src/Includes/WRAPPER_Actor.lua)

Read against that call site the shape is legible — blueprint name, position triple, rotation, a nil slot,
callback name, self, callback params, a flag — and it matches the `(sName, x, y, z, rot, …, sCallback,
tSelf, tParams, bFlag)` pattern the wrapper layer documents. But I did not *derive* it, so I have not
written it into the table as though I had. Every such binding carries `⚠`, and its listed arity is a lower
bound. Resolving these needs disassembly rather than decomp scraping (below).

### What this family says about how the game was built

Three things, none of which I would have predicted from the Lua side:

- **The engine trusts scripts completely and tells them nothing.** No binding among the 202 readable bodies
  raises an error (*inferred* for all 253 — see the caveat above); the one diagnostic primitive is a
  compiled-out stub; every failure edge — bad type, missing argument, stale handle, dead object — is the
  same silent no-op. The seam appears to have no error channel in the engine→script direction.
- **The interesting logic lives in data, not in the API.** The `Util` table is 173 entries wide and mostly
  shallow; the depth is in the event descriptor, a free-form Lua table whose schema is enforced only by
  which field accessor the engine happens to call. `Util.CreateEvent`'s 1029 call sites versus
  `Util.UserEvent`'s zero tells you where the design settled.
- **The `Util` table is a junk drawer, and its shape is archaeological.** It holds the event system, the
  interior/streaming API, tutorials, achievements, disguise callbacks, mission-folder bookkeeping, CRC
  hashing, and the debug hooks. `Util.DumpEvents` (← `DEBUG_DumpEvents`) and
  `Util.DEBUGClearStreamblockChangeListTree` shipped in the retail registration table — the debug surface
  was never stripped, only the assert body was.

## Open questions

1. **The 51 absent bodies.** All are `inlined` or `jmp` shapes that Ghidra did not export, and 32 of them
   are actively used by scripts — including `Util.GetNameFromHandle`, `Util.GetGameTime`, `Util.GetCRC`,
   `Util.GetIntFromHandle`, and `Util.IsObjectHandleValid`. Their VAs are pinned; re-running the exporter
   with a forced function start at each `impl_va`, or reading the bytes directly, would close this cheaply.
   This is the highest-value, lowest-effort follow-up in the family.
2. **`Util.LuaHook_Require` (`0x00753b20`) — body absent, and the interesting question is unresolved.**
   It is registered as `Util.LuaHook_Require` (`LuaGlueFunctor0R`), yet **zero scripts call it by that
   name**. Meanwhile the scripts that do use `require` pass a **backslash-delimited path** —
   `require("Includes\\WRAPPER_Util")` — not stock Lua 5.1's dotted module name, and there is no
   `require = ...` alias anywhere in the corpus. Scale, stated accurately: **29 of the 321 corpus files
   call `require` at all**, 77 calls total across 26 distinct targets; the most common is
   `require("Includes\\WRAPPER_Event")` (17 files), and only 4 files require `Includes\\WRAPPER_Util`
   (`WRAPPER_Actor`, `WRAPPER_Event`, `WRAPPER_Vehicle` and one other open with it on line 1). It is *not*
   the case that every script opens with a `require`. *Inferred:* the same C++ function is also installed over the global
   `require` to load modules out of the `.luap` container documented in
   [../formats/lua_scripts.md](../formats/lua_scripts.md). I could not confirm it — the body is absent and
   I did not locate a second registration site. Confirming this would pin how script loading actually works.
3. **The generic `CreateEvent` path (`FUN_006f9aa0`) is untraced**, so the **per-`EventType` descriptor
   schema is unknown**. I have the accessor vocabulary and the field names present in the binary, but not
   the mapping from an `EventType` string (`"StreamEvent"`, `"OnTriggerEnter"`, `"DeathEvent"`,
   `"OnPaperCheckSuccess"`, …) to its required and optional fields. That mapping is the most valuable
   missing artifact in this family, and `FUN_00708d90` (the `EventType` → factory resolver) is the thread
   to pull.
4. **Which interned string is `DAT_00fe59c8`?** `FUN_007587a0` compares the descriptor's `EventType`
   against exactly one constant to select the `FUN_0074c120` route. Its value is unread — I did not
   resolve the `.rdata` bytes — and it names a special-cased event type. One `MemoryRead` would settle it.
5. **The 16 `⚠` computed-index bindings need disassembly**, not decomp. `Object.Spawn` and the spawner
   cluster are the priority; their real signatures are readable from the corpus but not yet derived from
   the binary, and the two should be reconciled rather than assumed.
6. **`FUN_0099bc00`'s actual purpose is open.** Seven callers, a `{file, symbol, line}` record plus an
   object and `1.0f`, a virtual call through the sub-object at field `+0xdb8` (vtable slot `+8`),
   forwarding to `FUN_00999cd0`, always on the success path. Debug-draw and telemetry are both plausible; I have no evidence for either. Whatever it is, it is
   not this family's error path.
7. **`Trigger.WaitFor` vs. the `WaitFor*` descriptor booleans** — same concept, two surfaces. Whether they
   share an implementation is untested.
8. **`Util.UserEvent` (`0x00758980`) has zero call sites** in 321 files despite a clean derived signature
   `(sName, hTarget)` and a real body that resolves the handle and copies a 0x88-byte record. It appears to
   be a dead or editor-only API. `Object.SetShouldNeverRegisterGameObjectEvents` is similarly unused.
9. **Optionality is under-derived.** The `[x]` markers come from a conservative pattern match on
   independently-guarded checks; an argument without brackets is not thereby proven mandatory. Only the
   `&&`-chained guards (where a failed check reaches a `return`) are solid.
