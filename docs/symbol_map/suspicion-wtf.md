## Suspicion, Alarm & Will-to-Fight

Slug: `suspicion-wtf`

### Overview

This subsystem is The Saboteur's signature "getting caught" model. It has three
tightly-coupled layers, all living in `WildStar/Ai/Helpers/Combat/WSAICombatHiveMind.cpp`
and the Scaleform HUD:

1. **Suspicion meter** — a per-encounter awareness gauge with discrete color states
   (Green → Yellow → Orange → Red). Individual peds (soldiers) advance/retreat through
   these states; the engine keeps a *global census* of how many peds are in each state.
2. **Escalation** — the game's "wanted level," an integer **0..5** (`ESCALATION_LEVEL_%d`).
   This is what Lua calls `Suspicion.GetEscalation()` / `Suspicion.SetEscalationLevel()`.
   Rising escalation spawns reinforcement waves (chase cars, backup, tanks) and fires the
   `OnEscalation%d` / `OnBaseEscalation%d` script events that mission objectives listen for.
3. **Will-to-Fight (WTF)** — the district-level resistance/occupation state. Zones are
   `cZONESTATE_LOWWTF (0)` / `cZONESTATE_HIGHWTF (1)`; the `WSWillToFightGrid` renders an
   influence texture and a transition ("blast ring") FX when a zone flips.

There is **no separate "Alarm" or "Wanted" string subsystem** in the binary — physical
alarms are Lua-side `AttractionPt_Alarm` attraction points, and the "wanted level" *is* the
Escalation integer. Grepping the decomp for `Wanted` yields zero hits; `Alarm` appears only
as achievement-stat text (`Stats.De-Escalations by Alarm Deactivation`, line 880658).

### RTTI classes owned

From `ws_engine_classes.txt` / `rtti_classes_all.txt`:

- `WSHUDSuspicionMeter`, `WSHUDSuspicionMeterBlueprint` — Scaleform HUD gauge.
- `WSPlayerShedSuspicionAction` — the player action that drops suspicion (e.g. hiding, greeting).
- `WSAISuspicionRadius` (`PblTree<WSAISuspicionRadius>`, line 1227) — the runtime suspicion volume.
- `WSWillToFight` / `WSWillToFightBlueprint`, `WSWillToFightGrid`, `WSWillToFightNode` /
  `WSWillToFightNodeBlueprint`, `WSWillToFightPortal`, `WSWillToFightPortalManager`,
  `WSWillToFightTask`, `WSWillToFightTransition` — the WTF district-flip machinery (several are
  `PblSingleton<>`: `WSWillToFight`, `WSWillToFightGrid`, `WSWillToFightPortalManager`,
  `WSWillToFightTransition`).
- Internal (string-only, not in RTTI dump): `WSAISuspicionTracker`, `WSAIEscalation`,
  `WSAIEscalationVehicle` (all in `WSAIEscalation.cpp` / `WSAICombatHiveMind.cpp`).

### Lua API surface

C bindings (`lua_bindings.txt`), grouped:

- **Suspicion/Escalation:** `EnableSuspicion`, `EnableSuspicionGlobal`, `IsSuspicionEnabled`,
  `ResetSuspicion`, `ResetSuspicionMeter`, `SetupSuspicionRadius`, `KillSuspicionRadius`,
  `TrigCreateSuspicionZone`, `SuspicionSetEscalated`, `SuspicionSetEscalatedWithWhistle`,
  `SuspicionIsEscalated`.
- **WTF:** `SetGlobalWTF`, `ClearGlobalWTF`, `SetNumWTFZones`, `RecordWTFZoneFlipped`,
  `GlobalEnableHighWTFCivMelee`, `WTFGetInfluence`, `WTFEnableNode`, `WTFExitActivePortal`,
  `WTFFinishTransition`, `WTFBlendOverrideBlueprint`, `WTF{Set,Clear}[High|Low]OverrideBlueprint`,
  `WTFOverrideTransition{BlastTime,Position,SwitchTime}`.

The Lua `Suspicion.*` namespace (e.g. `Suspicion.GetEscalation`, `Suspicion.SetState`,
`Suspicion.ResetEscalation`, `Suspicion.IsEscalatedLite`) are thin wrappers over these bindings.
Usage in the corpus: `SabTaskObjectiveEscalation.lua` waits on `OnEscalation<level>` events;
`SoldierState_*` (Investigate/Hunt/Combat/PaperCheck) drive `Suspicion.SetState`;
`SuspicionZone.lua` → `Trigger.CreateSuspicionZone` (binding `TrigCreateSuspicionZone`).

### Pinned functions

The `0x0089xxxx` cluster is the `WSAICombatHiveMind.cpp` / `WSAISuspicionRadius` core; the
`0x008adxxx-0x008b2xxx` cluster is `WSAIEscalation.cpp`; the `0x008e8xxx` cluster is the
per-ped suspicion-state state machine; `0x0097xxxx` is `WSWillToFightGrid` rendering.

| VA | Proposed name | Evidence |
|----|---------------|----------|
| `FUN_0089e2de` | `WSSuspicion::SetEscalationLevel` | Fires `ESCALATION_LEVEL_%d` audio (667941/667946), `OnEscalation%d` + `OnEscalation` + `OnBaseEscalation%d` events (667973-667979); stores level at `+0x1154`; matches Lua `Suspicion.SetEscalationLevel` and `SabTaskObjectiveEscalation` listeners |
| `FUN_008e8d40` | `WSAISuspicionRadius::SetPedSuspicionState` | Maintains global census `DAT_0143ec04[0..8]` (decrement old state, increment new), plays `cht_com_Attack`/`cht_Spo_Susp`/`cht_Spo_Disgs`, fires `OnEscalationNoOneRed` (719562), tail-calls `FUN_008e8a90` |
| `FUN_008e8a90` | `WSSuspicionState::BroadcastEnterEvent` | `switch(state)` → `OnSuspicionEnter{Green,Yellow,YellowInvestigateThreat,FlashingYellow,YellowWarning,Orange,Red,Scripted}` (719384-719405) |
| `FUN_008e8c35` | `WSSuspicionCensus::OnPedLeaveState` | Decrements census `DAT_0143ec04[state]`, fires `OnEveryoneGreen` when all peds return to green (719444) |
| `FUN_0089f840` | `WSAISuspicionRadius::Update` | Debug label `"WSAISuspicionRadius::Update"` (668729); ticks radius expansion, calls BroadcastEscLite when timer exceeds `_DAT_00f7b148` |
| `FUN_0089bd20` | `WSAISuspicionRadius::BroadcastEscLite` | Debug label `"WSAISuspicionRadius::BroadcastEscLite"` (665988); iterates hive-mind combatants to pick nearest and propagate escalation-lite |
| `FUN_0089f630` | `WSAISuspicionRadius::SetEscalatedLite` | Broadcasts `OnEscalationLite` (668593), sets flag bit `+0x1253 & 0x10`, calls escalate-lite helper `FUN_0089e060`; corresponds to `Suspicion.IsEscalatedLite` / `SuspicionSetEscalated` |
| `FUN_0089e060` | `WSAISuspicionRadius::EscalateLite_impl` | Reads tunable `"EscLite_SuspicionRadius"` via `FUN_00838410` (667762); helper invoked by SetEscalatedLite |
| `FUN_005a8f40` | `WSPlayerShedSuspicionAction::Execute` | Debug label `"WSPlayerShedSuspicionAction::Execute"` + source `WSPlayer.cpp` (241944-241945); plays `nazi_greet` |
| `FUN_0081fbb0` | `WSAISuspicionTracker::ctor` | strncpy of literal `"WSAISuspicionTracker"` into a debug/name field (583649); initializes two `CRITICAL_SECTION`s and vtables — singleton/tracker construction |
| `FUN_007b4280` | `WSHUDSuspicionMeter::SetVisible` | Sets Scaleform `"_root.SuspicionMeter._visible"` (521498) |
| `FUN_008ae698` | `WSAIEscalationVehicle::EnterState` | Debug label `"WSAIEscalationVehicle::EnterState"` + `WSAIEscalation.cpp` (680116); spawns escalation reinforcements: `RndEscalation_Chase_Vehicle`/`Backup_Vehicle`, tank `VH_NZ_TK_Maus_01`, names `EscalationVehicle%d` (679920-679948) |
| `FUN_008ad830` | `WSAIEscalation::BuildStateName` | Builds `"Escalation%d"` state-name string (679292) |
| `FUN_008b2a40` | `WSAIEscalation::HighWTFReinforce` | Plays `EscHWTF_Resistance`, references `EscHWTF_DynLocNodes` (682651/682768) — high-WTF-district resistance reinforcement audio/logic |
| `FUN_00975e40` | `WSWillToFightGrid::InitInfluenceTextures` | `_sprintf("WTFInfluenceGridTexture%d")` (808575), `LowResWorldWTF`/`LowResWorldWTFVertex` (808624-808631) |
| `FUN_0097b4b0` | `WSWillToFightTransition::PlayBlastFX` | Triggers `0FX_WTF_Buildup` / `0FX_WTF_Blast` transition effects (811108/811140) |
| `FUN_00461590` | `WSBlueprint::RegisterFields` (partial) | 9126-byte blueprint-field registrar; interns field names incl. `WillToFight`, `WillToFightNode`, `Escalation`, `EscHWTF` via `FUN_00db7e10(name,1)` (56192-56616) |

### Key state offsets (on the `DAT_0143e6f4` hive-mind / suspicion singleton)

- `+0x1154` — current **Escalation level** (int 0..5). Read/compared throughout `0x008e8xxx`.
- `+0x1252 / +0x1253` — suspicion/escalation flag bytes; `+0x1253 & 0x10` = "escalated-lite" bit.
- `DAT_0143ec04[0..8]` — **per-state suspicion census** (count of peds in each color state);
  `DAT_0143ec2c` = total; `DAT_0143ec31` = "someone hostile" latch.

### Shared helpers (not owned by this subsystem)

- `FUN_00db7e10(name, 1)` — string→atom/CRC interner used pervasively for event/audio/BP names.
- `FUN_004c32a0(name)` / `FUN_008a2fc0`/`FUN_008a30d0`/`FUN_008a31c0` — script-event broadcast
  family (fire `On...` events into the Lua event bus).
- `FUN_00838410(name)` — float tunable ("magic number") lookup by name.

---

## Verification (adversarial pass)

**Verdict: solid** — 17/17 key functions confirmed against the decomp.

**Seams (cross-subsystem):**

- FUN_0089e060 (EscLite_impl) does more than read the tunable: it broadcasts FUN_008a2fc0("OnEscLiteSuspRadius", pos) at line 667775 — an OnEscLiteSuspRadius script event the doc omits (distinct from the OnEscalationLite fired by FUN_0089f630).
- lite->full escalation wiring: FUN_0089f630 (SetEscalatedLite) calls FUN_0089e2d0(1,0,1), the escalation-level entry thunk that reaches FUN_0089e2de (SetEscalationLevel). So 'escalated-lite' directly drives the full escalation-level path; the doc treats them as separate.
- SetEscalationLevel (FUN_0089e2de) is reached via a thunk chain FUN_0089e2d0 -> FUN_005100e2 (11-byte thunk) -> FUN_0089e2de, NOT called directly from a Lua binding; the 'directly matches Lua Suspicion.SetEscalationLevel' claim is an inference, not a static call edge.
- Scripting-subsystem seam: the census/state functions (FUN_008e8a90, FUN_008e8c35, FUN_008e8d40) and SetEscalationLevel all fire game-script events through FUN_004c32a0 / FUN_008a30d0 / FUN_008a31c0 / FUN_008a2fc0 (event-broadcast helpers) — the doc under-describes this as the common event bus.
- Audio-subsystem seam: escalation/suspicion transitions route audio atoms through FUN_00db7e10 followed by FUN_0083a2f0 (SetEscalationLevel) and FUN_0068b470 (FUN_008e8d40 after cht_* atoms); these are the audio-engine hand-offs.
- FUN_008e8d40 also tail-calls FUN_008d68d0(param_2,&param_3) when *(iVar6+0x140)!=0 (per-ped state notify) in addition to the FUN_008e8a90 tail-call the doc names.
- Tank atom VH_NZ_TK_Maus_01 is shared: besides FUN_008ae698 (line 679936) it is also referenced at line 258167 in an unrelated function, so the Maus spawn atom is not exclusive to the escalation-vehicle path.

**Additional gaps / suspected decomp corruption:**

- Class-label provenance: WSAISuspicionTracker, WSSuspicion(::SetEscalationLevel), WSSuspicionState(::BroadcastEnterEvent) and WSSuspicionCensus(::OnPedLeaveState) are NOT in rtti_classes_all.txt or ws_engine_classes.txt. Only the string literal 'WSAISuspicionTracker' exists (in FUN_0081fbb0 body). The census/state functions (FUN_008e8a90/008e8c35/008e8d40) are free functions over globals (DAT_0143ec04..DAT_0143ec2c) with no owning RTTI class — those class-qualified labels are speculative and should be marked inferred.
- FUN_008e8a90 switch has no case 5: it handles states 0,1,2,3,4,6,7,8 only. Doc says 'states 0-8' which is imprecise — state 5 fires no OnSuspicionEnter* event.
- Ghidra artifact in FUN_008e8d40 (~line 719508): a duplicated/unreachable guard produces `iVar6 = (**(code **)(_DAT_00000000 + 0x1c))();` — a deref of null _DAT_00000000. It is dead code from a doubled condition, not a real null-deref; note so it isn't mistaken for a real code path.
- FUN_0089e2de recovered signature is imperfect: `this` appears as unaff_ESI and many in_stack_0000xxxx params look uninitialized — thiscall/stack-param recovery is degraded (does not affect the confirmed behavior, but the param list in the doc should not be trusted literally).
- FUN_008ad830 has a second caller 0x008ade25 that is NOT resolved to a FUN_ symbol (raw address, mid-function), so one xref into BuildStateName is unattributed.
- FUN_005a8f40 (ShedSuspicionAction::Execute) and FUN_007b4280 (HUDSuspicionMeter::SetVisible) both have callers=[] — reached only via vtable dispatch, so no static caller graph; expected for virtuals but worth flagging that there is no direct xref evidence tying them into the runtime flow.
- A second '_root.SuspicionMeter._visible' reference exists at line 851440 (pcStack_a4) in a different function than FUN_007b4280 — there is another HUD path touching the same Scaleform var not covered by the doc.

**Verifier corrections:**

Fold in these adjustments:
- Mark class-qualified labels for the census/state/tracker functions (FUN_008e8a90, FUN_008e8c35, FUN_008e8d40, FUN_0081fbb0) as INFERRED — no RTTI class WSAISuspicionTracker/WSSuspicion/WSSuspicionState/WSSuspicionCensus exists; only the 'WSAISuspicionTracker' string literal is real. These are free functions over the global census array DAT_0143ec04[0..8]/DAT_0143ec2c.
- FUN_008e8a90: correct 'states 0-8' to 'states 0,1,2,3,4,6,7,8 (no event for state 5)'.
- FUN_0089e060: add that it also broadcasts OnEscLiteSuspRadius (FUN_008a2fc0, line 667775), not just reads the EscLite_SuspicionRadius tunable.
- FUN_0089f630: note it calls FUN_0089e2d0(1,0,1), tying escalated-lite into the full SetEscalationLevel path (FUN_0089e2de).
- FUN_0089e2de: the caller is a thunk chain (FUN_0089e2d0 -> FUN_005100e2 -> FUN_0089e2de), not a direct Lua binding; downgrade 'directly matches Lua' to 'exposed to Lua via the FUN_0089e2d0 wrapper'. Also note the decomp signature (unaff_ESI = this, in_stack_* params) is imperfectly recovered.
- FUN_008e8d40: the null-deref of _DAT_00000000 is a dead duplicated-guard Ghidra artifact, not a real path; it also tail-calls FUN_008d68d0 alongside FUN_008e8a90.
