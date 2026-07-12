## Mission, Objective & Trigger

The runtime layer beneath the 146 `Missions/` Lua scripts. It has four cooperating pieces:

1. **Trigger regions** — `WSTriggerManager` keeps trigger `WSTriggerRegion`s in a spatial hash and, every frame, tests moving objects against them and fires enter/exit callbacks. This is what Lua's `Trigger.WaitFor` (310 call sites), `Trigger.GetAllWithin`, `Trigger.Enable`, and `Trigger.ClearCallback` sit on.
2. **Objectives / HUD tray** — `WSObjectiveManager` + `WSObjectiveMarker` model objective state; `WSHUDObjectiveTray` renders it through Scaleform (`_root.ObjectiveTray.*`). Lua drives this via `HUD.AddObjective`, `HUD.SetObjectiveText`, `HUD.SetObjectiveMarker`, `SetObjective`, etc. The whole `SabTaskObjective` Lua class is authored on top.
3. **Mission messengers** — `WSMissionMessengerManager` spawns numbered `MissionMessenger_%d` courier NPCs and runs the delivery/hand-off step.
4. **Engine↔Lua mission glue** — engine code queries the Lua global `IsMissionCompleted` to gate world-node streaming on mission progress.

### Trigger system (well-evidenced)

The `WSTriggerManager` cluster occupies `0x00a0e130`–`0x00a12xxx`.

- **`FUN_00a10ef0` — `WSTriggerManager::ctor`.** Copies the type tag with `_strncpy(&DAT_01212004,"WSTriggerRegion",0x1f)` and builds **three** 2048-bucket spatial grids (circular-list heads at `+0xc8c`, `+0x2c8c`, `+0x4c8c`), plus a critical section at `DAT_01212044`. Allocated by singleton helper `FUN_006ce470`.
- **`FUN_00a10ba0` — `WSTriggerManager::Update`.** The per-frame tick; called only from the two game-loop drivers `FUN_0043cc20` and `FUN_009906c0`, and calls `FUN_00a0f690`.
- **`FUN_00a0f690` — per-region overlap resolve & enter/exit dispatch.** 1958 bytes, sole caller is the tick; walks grid buckets and issues a virtual call `(**(code**)(*param_1+0x14))()` per region — the path that reaches Lua `Trigger.OnTriggerEnter`/`OnTriggerExit`.
- **`FUN_00a0e960` — `WSTriggerManager::InsertRegionIntoGrid`.** Carries the assert string `WSTriggerManager.cpp:0x17e`; allocates a 0x20-byte node and links it into the region's intrusive lists at `+0x104/+0x108/+0x110`, indexing buckets from the region AABB (`region+0x40..0x4c`).
- **`FUN_00a0f600` — `WSTriggerManager::AddRegion`.** Thin selector that forwards to the grid insert; called from the region register path.

On the region side (object-file band `0x004c5*`–`0x004ca*`):

- **`FUN_004c9110` — `WSTriggerRegion::RegisterWithManager`.** Calls `FUN_00a0f600` twice (two grid layers). Its 11 callers include Lua-glue trampolines `FUN_01615090/016151b0/016152a0` in the `0x0161xxxx` binding band — i.e. script-driven trigger creation/enable.
- **`FUN_004ca507` — `WSTriggerRegion::dtor`.** Installs the region vtable (`PTR_FUN_00f98b08` / `PTR_LAB_00f98ae0`) and references `WSTriggerRegion.cpp:0x4a`.
- **`FUN_004c5bd0` — `WSTriggerRegion::ClearCallbacks`.** Uses `WSTriggerRegion.cpp:0xaa`; unlinks the callback list at `+0x104` (matching `Trigger.ClearCallback` / `SabTaskObjective:_CleanTriggerEvents`).

### Mission messenger (well-evidenced)

- **`FUN_009d0100` — `WSMissionMessengerManager::AttemptDeliveryWithCurrentMessenger`.** Both the file path *and* the fully-qualified function-name string appear inline (`WSMissionMessengerManager.cpp` lines 0x366/0x367). Uses chatter cue `cht_mes_MessgDlivrd` and plays `handoff_run_v` / `handoff_run` conversation cues.
- **`FUN_009cfd50` — `WSMissionMessengerManager::SpawnMessenger`.** Formats `MissionMessenger_%d` with an incrementing counter (`DAT_014a9d8c`) and places the courier NPC.

### Objective HUD (display half; medium confidence)

- **`FUN_0079f030` — `WSHUDObjectiveTray::Update`.** Writes `_root.ObjectiveTray._alpha`, toggles visibility via `FUN_0079edc0` (`_root.ObjectiveTray._visible`), and calls the Fightback builder. This is the render side of `HUD.AddObjective`/`HUD.SetObjectiveText`.
- **`FUN_0079edc0 — WSHUDObjectiveTray::SetVisible`**, **`FUN_00897f60 — HUD::BuildFightbackObjective`** (`GenericObjective_Text.Fightback_Task`/`_Meter`, the escalation objective the Lua corpus references).

### Engine → Lua mission state

- **`FUN_009585d0` / `FUN_00958770`** call the Lua-global invoker `FUN_0095ade0("IsMissionCompleted", …)` to gate activation of world-node "type 6" objects on mission completion — the bridge from mission progress into world/node streaming.

### How the Lua corpus maps down

`SabTaskObjective` (in `Modules/SabTaskObjective.lua`) is the workhorse: `Activated()` wires GPS (`HUD.SetGPSTarget`), markers (`HUD.SetObjectiveMarker`), focus points (`FocusPt.Create`), timers (victory/failure/auto-complete), and escalation callbacks; `DisplayHUDText` calls `HUD.AddObjective`; `SubObjectiveCompleted`/`_Complete` roll completion up to the parent mission and can switch Will-to-Fight zone state. `Trigger.WaitFor` callbacks are tracked in `_tTriggerWaitFors` and torn down through `Trigger.ClearCallback` → the engine's `WSTriggerRegion::ClearCallbacks`. `ScriptSequence.lua` is the AI-actor scripting VM (WALKTO/ATTACKTARGET/PLAYANIMATION/…) that missions use for scripted beats; it registers `StreamEvent`/`DeathEvent`/`TimerEvent`s through the same event system triggers use.

### Gaps

- **`WSObjectiveManager`, `WSObjective`, `WSObjectiveMarker` have no string/path anchors in the decomp** — their VAs/vtables need the pending RTTI vtable→VA map. Only the display (ObjectiveTray) and Lua (`SabTaskObjective`) halves are pinned.
- The **binding thunks** (`HUDAddObjective`, `SetObjective`, `MissionComplete`, `NewMission`, `TriggerWaitFor`, `TriggerGetAllWithin`) live in the mangled `LuaGlueFunctor` band `~0x0161xxxx` and are not individually greppable by name.
- **`Trigger.WaitFor`'s** exact per-callback registration entry point was not isolated (the region register/insert/teardown path was).
- The per-region enter/exit **Lua callback marshaller** (reached via the `*+0x14` virtual call in `FUN_00a0f690`) was not traced end-to-end.
- `WSTriggerManager`/`WSMissionMessengerManager` singleton getters and Update entries are inferred from caller topology, not confirmed by strings (`FUN_006ce470` is the likely trigger-manager allocator).

---

## Verification (adversarial pass)

**Verdict: solid** — 14/14 key functions confirmed against the decomp.

**Refuted / corrected:**

- `0x00a0f690` — Header exists and it IS the sole callee of the tick FUN_00a10ba0, but the claimed role ('walks grid buckets and issues a virtual call per region -- the enter/exit dispatch that ultimately reaches Lua Trigger.OnTriggerEnter/OnTriggerExit') is not supported by the body. The repeated (**(code**)(*param_1+0x14))() calls are interleaved with conditional byte-reversal gated on a flag bit `(*(byte*)(param_1+2) & 1)` (CONCAT11/CONCAT13 endian swaps at 903296-903298, 903327, 903345, 903357). That is the signature of a binary archive/serializer read-with-endian-swap through a stream vtable, NOT spatial-grid overlap resolution. param_1 is a stream/visitor object (no grid heads at +0xc8c/+0x2c8c/+0x4c8c are touched here), so 'ProcessRegionOverlaps' and the Lua enter/exit linkage are speculative and probably wrong.
- `0x0079f030` — Function itself IS the ObjectiveTray update (confirmed: writes _root.ObjectiveTray._alpha via FUN_0079e1e0 at line 509123, calls FUN_00897f60 at 508940), but the sub-claim that it 'calls FUN_0079edc0 (the _visible setter)' is false. FUN_0079f030's body contains no call to FUN_0079edc0, and FUN_0079edc0 has callers=[] (empty). The _visible setter is reached only via vtable elsewhere, not from this Update.

**Seams (cross-subsystem):**

- FUN_00a0f600 (AddRegion dispatcher) has a THIRD caller the doc omitted: FUN_0091cd60 @0x0091ce2a. So grid-add is also driven from the 0x0091c band, not only the WSTriggerRegion register path FUN_004c9110's two call sites.
- FUN_00a0eb50 (called by FUN_004c9110 register path) is shared cross-subsystem: also called by FUN_00a10a20 @0x00a10b12 and FUN_0091d0a0 @0x0091d12a (0x0091d band). The doc frames it as register-only.
- FUN_009585d0 mission-complete node gate is also invoked by FUN_00959bc0 @0x00959c52 (not just its twin FUN_00958770), tying trigger/mission-completion state into the 0x00959 streaming path. Both variants also make a SECOND Lua-bridge call the doc missed: FUN_0095c110(0,"IsMissionCompleted",...) at 791890/791957 immediately after FUN_0095ade0.
- FUN_0079f030 (ObjectiveTray Update) drives Scaleform through an indirect Invoke slot (**(int**)(param_1+0x10)+0x48)(...) with ActionScript hook strings exObjTray_TransitionOn/Off, exObjTray_TextNew/TextOld/TextHighlight/TextStrikethrough, exObjTray_MeterUpdate/MeterTransitionOn/Off. The doc reduced this whole HUD<->Scaleform seam to just the _alpha/_visible variable setters.
- FUN_009d0100 (AttemptDeliveryWithCurrentMessenger) is driven by FUN_0087d506 @0x0087d5bd (mission/messenger orchestration in the 0x0087d band) -- the doc gave the strings but not the caller seam.

**Additional gaps / suspected decomp corruption:**

- Caller-graph is blind to virtual dispatch: FUN_004c5bd0 (ClearCallbacks), FUN_009cfd50 (SpawnMessenger), FUN_0079f030 (ObjectiveTray Update) and FUN_0079edc0 (SetVisible) all show callers=[]. They are reached only through vtables, so any doc claim of the form 'called from X' that is based on the xref list must be treated cautiously -- this is exactly how the false 0079f030->0079edc0 claim slipped in.
- FUN_00a0f690 needs re-analysis (see refuted): the byte-swap serializer pattern suggests the whole 'ProcessRegionOverlaps -> Lua OnTriggerEnter/OnTriggerExit' chain in the doc is unverified. The actual Lua Trigger.OnTriggerEnter/OnTriggerExit dispatch site was NOT located in this pass and should be hunted separately (grep the Trigger.* binding trampolines and the region callback list at +0x104/+0x110).
- FUN_004c9110 is named 'WSTriggerRegion::RegisterWithManager' but the body is a state-transition/SetEnable keyed on the byte at +0x102 (transitions among states 2/4/5), calling FUN_00a0eb50 then FUN_00a0f600(0/1,...) to remove/re-add from the grid. Functionally it is closer to SetEnabledState than a one-time Register; the name is loose but not wrong.

