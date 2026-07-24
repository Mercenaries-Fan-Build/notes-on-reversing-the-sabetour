# AI & Behavior

The AI & Behavior subsystem is the largest in the WildStar/Odin engine (~103 `WSAI*` RTTI classes). It implements the full NPC brain stack for *The Saboteur*: per-actor **controllers** that translate decisions into input, swappable **behavior/helper** state machines (idle, combat, hunt, investigate, paper-check, tail, panic), **pathfinding + path-following**, **attraction points** (the scheduling system that sends NPCs to use world "props"/animations), and a set of world **managers** (crowd, traffic, escalation/alert level, corpse, spawn, execution). Mission and ambient Lua scripts drive it almost entirely through the `Nav.*`, `Squad.*`, `AttractionPt.*`, and `Object.Spawner*` binding families.

## How the evidence was obtained

The Ghidra decomp of the retail binary retains the original EA build's `__FILE__`/`__FUNCTION__` assertion strings, e.g.
`"...\WildStar\Ai\Helpers\WSAIPanicker.cpp"` immediately followed by `"WSAIPanicker::Update"`. These string pairs sit inside the very function body they name, so each pins a concrete `FUN_` VA to a real `Class::Method`. Every VA below was located that way (path+method anchor inside the function) and cross-checked against the `WSAI*` RTTI class list and the Lua corpus behavior. This is far more reliable than a vtable→VA lookup (which now also exists — [`pc_vtables.tsv`](../../data/symbol_map/pc_vtables.tsv), 2,586 classes / 81,561 slots), and covers the controller / path-follower / helper / behavior / attraction-point / reactor / manager code paths that carry assertions.

## Architecture (as recovered)

- **Controllers** (`WSAIController*`): one per actor kind — `Human`, `Vehicle`, `Searcher`, `Turret`. They own the actor and expose an input surface (`WSControllerInputHumanAI`, `...VehicleAI`, `...SearcherAI`, `...TurretAI`). `WSAIControllerManager` / `WSAIControllerBlueprint` register and configure them.
- **Behaviors** (`WSAIBhvr*`): pluggable state objects — `WSAIBhvrIdle`, `WSAIBhvrInvestigate`, `WSAIBhvrCheckpoint`, `WSAIBhvrPaperCheck`, `WSAIBhvrTail`. These map directly onto the `SoldierState_*` Lua files (`Idle`, `Hunt`, `Investigate`, `PaperCheckLeader/Backup`, `Combat`).
- **Combat helpers** (`WSAIHelperCombat*`, `WSAIHelperEnemy`, `WSAIHelperHunter`, `WSAICombatHiveMind`): the actual fighting AI. `WSAICombatHiveMind` is the shared "squad brain" that broadcasts events (dead body spotted, vehicle damage gawk, escalation-lite) to nearby combatants; `WSAISuspicionRadius` drives the see→suspect→alarm perception ramp.
- **Pathfinding** (`WSAIPathfinder*`, `WSGpsPathFinder`, `WSAIPathFollower*`): task-based pathfinder (`WSAIPathfinderTaskStatic/Dynamic`) feeding path-followers that also choose cover/idle anims while moving.
- **Attraction points** (`WSAIAttractionPt*`, `WSAIAttractionPtManager`, `WSAIAttrPtQueue`): the ambient scheduler. NPCs request a point-of-interest that plays an animation; heavily used by ambient scripts (`AttrPtRequest`, `AttractionPt.EnableUse`, `AttractionPt.FindPtInObject`).
- **World managers**: `WSAICrowdManager`/`WSAICrowder`, `WSAITrafficManager`/`WSAITrafficAvoider`, `WSAIResistanceEscalation`/`WSAIEscalation*` (the Nazi alert/escalation level), `WSAICorpseManager`, `WSAISpawnManager`/`WSAISpawner`, `WSAIExecutionManager`, `WSAIAutoPopManager`, `WSAISidewalkManager`.

## Lua API surface (binding families → C++ subsystem)

From `lua_bindings.txt` and usage counts in the Lua corpus (`docs/saboteur-luacd/src`):

- **`Nav.*`** → path-following & formations. Top calls: `SetScriptedPath` (233), `MoveToObject` (127), `SetScriptedPathSpeed` (103), `SetScriptedPathMoveMode` (84), `FollowObject`, `BoardVehicle`, `MoveToPoint`, `StopMoving`, `EnterFormation`/`ExitFormation`, `CreateFormation`, `CanPathfind`. Fronts `WSAIPathFollowerHuman/Vehicle`, `WSAIScriptedPathFollower*`, `WSAIFormation(s)`.
- **`Squad.*`** → `WSAISquad`-family / `WSAICombatHiveMind`. `AddMember` (66), `Create` (38), `SetEnemy`, `SetLeader`, `Delete`, `SetRadius`, `SetLethal`, `FollowLeader`, `SetParent`, `ClearBehavior`.
- **`AttractionPt.*` / `AttrPt*`** → `WSAIAttractionPtManager`. `EnableUse` (112), `FindPtInObject` (54), `IsAvailable`, `FinishNow`, `EnableBroadcast`, `Create`, `SetAnimation`.
- **`Object.Spawner*` / `Object.Spawn*`** → `WSAISpawner`/`WSAISpawnManager`: `EnableSpawner`, `SpawnerPurge`, `SpawnerQueueSpawn`, `SpawnObject`, `SpawnInVehicle`, `FindSafeSpawnPoint`.
- **Escalation / panic / traffic**: `SetEscalationLevel`, `EnableEscalation`, `ResetEscalation`, `SetPanicMode`, `TrafficEnable`, `VehicleAddToTraffic`.

Worked examples in the corpus: `ScriptControllers/HumanSpawner.lua` (spawn → `Nav.SetScriptedPath` on `OnSpawn`, `Object.EnableSpawner`, `Object.SpawnerPurge`); `Modules/Libraries/Formation.lua` (`Nav.EnterFormation` grid offsets, `Util.FindSafeSpawnPoint`); `Experimental/SoldierState_*.lua` (the soldier FSM mirroring `WSAIBhvr*`).

## Key functions (pinned with evidence)

| VA | Proposed name | Evidence |
|----|---------------|----------|
| `FUN_008bf650` | `WSAIHelperCombat::Update` | 13,260-byte function; contains `WSAIHelperCombat.cpp` + `"WSAIHelperCombat::Update"` at line 694156. Largest AI function — the core soldier combat tick. |
| `FUN_0088446c` | `WSAIPanicker::Update` | 7,087 bytes; `WSAIPanicker.cpp` + `"WSAIPanicker::Update"`. Civilian panic/flee behavior (`SetPanicMode` binding). |
| `FUN_008e4650` | `WSAIBhvrPaperCheck::EnterState` | `"WSAIBhvrPaperCheck::EnterState"`; matches `SoldierState_PaperCheckLeader/Backup.lua` checkpoint behavior. |
| `FUN_0088c180` | `WSAIReactor::Update` | `"WSAIReactor::Update"` anchor. Reactor = ambient NPC reaction FSM. |
| `FUN_0088a250` | `WSAIReactor::ObservePlayer` | `"WSAIReactor::ObservePlayer"` anchor. |
| `FUN_0089f840` | `WSAISuspicionRadius::Update` | `"WSAISuspicionRadius::Update"` anchor; the perception/alert ramp. |
| `FUN_0089a1b0` | `WSAICombatHiveMind::BroadcastDeadBody` | `WSAICombatHiveMind.cpp` + `"...::BroadcastDeadBody"`. Squad-brain event broadcast. |
| `FUN_00898440` | `WSAICombatHiveMind::BroadcastVehicleDamageGawkEvent` | `"...::BroadcastVehicleDamageGawkEvent"` anchor. |
| `FUN_008d4240` | `WSAIHelperEnemy::UpdateTarget` | `WSAIHelperEnemy.cpp` + `"...::UpdateTarget"`; 2,630 bytes target selection. |
| `FUN_008d0250` | `WSAIHelperEnemy::UpdateGrenadeDodge` | `"WSAIHelperEnemy::UpdateGrenadeDodge"` anchor. |
| `FUN_008d7b70` | `WSAIHelperHunter::Hibernate` | `WSAIHelperHunter.cpp` + `"...::Hibernate"`; matches `SoldierState_Hunt.lua`. |
| `FUN_00840b70` | `WSAIControllerHuman::UpdateRooftop` | `WSAIControllerHuman.cpp` + `"...::UpdateRooftop"` (line 0x2b4). |
| `FUN_00848000` | `WSAIControllerVehicle::ScaryEvent` | `WSAIControllerVehicle.cpp` + `"...::ScaryEvent"`. |
| `FUN_00864738` | `WSAIPathFollowerHuman::BeginState` | `WSAIPathFollowerHuman.cpp` + `"...::BeginState"` (many anchors). Backs `Nav.SetScriptedPath`. |
| `FUN_00861c40` | `WSAIPathFollowerHuman::ChooseAndPlayCoverAnims` | `"...::ChooseAndPlayCoverAnims"` anchor; move-while-cover anim selection. |
| `FUN_0087f0a0` | `WSAIObjectFollower::EnterState` | `WSAIObjectFollower.cpp` + `"...::EnterState"`; backs `Nav.FollowObject`. |
| `FUN_008eaa30` | `WSAIAttractionPt::PlayAnimation` | `WSAIAttractionPt.cpp` + `"...::PlayAnimation"`; core of the attraction-point animation play (`AttractionPt.SetAnimation`). |
| `FUN_008ed1e0` | `WSAIAttractionPt::DeleteSynched` | `"WSAIAttractionPt::DeleteSynched"` anchor. |
| `FUN_0087b7d0` | `WSAICrowd::GatherPeople` | `"WSAICrowd::GatherPeople"` anchor; crowd assembly. |
| `FUN_008ae698` | `WSAIEscalationVehicle::EnterState` | `"WSAIEscalationVehicle::EnterState"`; 2,473 bytes; the alert-level vehicle spawn/response (`EnableEscalationVehicles`). |
| `FUN_0081a4d0` | `WSAIExecutionManager::Update` | `"WSAIExecutionManager::Update"` anchor; the NPC execution scheduler. |
| `FUN_00819430` | `WSAIExecutionManager::KillVictim` | `"WSAIExecutionManager::KillVictim"` anchor. |
| `FUN_0088f180` | `WSAISocializer::PlaySalutingCinematic` | `"WSAISocializer::PlaySalutingCinematic"` anchor; ambient saluting/socializing. |

## Notes / cross-cutting

- The controller→behavior→helper split means one soldier is several cooperating objects: `WSAIControllerHuman` (ownership/input) + a `WSAIBhvr*` (high-level state) + `WSAIHelperCombat`/`WSAIHelperEnemy` (fight logic) + `WSAIPathFollowerHuman` (locomotion). The Lua `Soldier` FSM (`Soldier_Internal.lua`, `SoldierState_*`) sits above all of them and toggles states via `Util.BroadcastFunction`/`ScriptSequence`.
- `WSAICombatHiveMind` + `WSAISuspicionRadius` together implement the game's signature "notoriety"/alert propagation; escalation level is owned by `WSAIResistanceEscalation`/`WSAIEscalation*`.

## Gaps

- **Spawner / pathfinder / manager method names are not pinned by string.** `WSAISpawner`, `WSAISpawnManager`, `WSAIManager`, `WSAIPathfinder`, `WSAIPathfinderTask*`, `WSGpsPathFinder`, `WSAIWanderer`, `WSAINeedsTracker`, and `WSAISquad` carry few/no `__FUNCTION__` assertions, so their concrete VAs must come from the **vtable→VA map** — which now exists ([`pc_vtables.tsv`](../../data/symbol_map/pc_vtables.tsv)); this promotion pass has not yet been run.  ⚠️ Note `WSAISquad` is not a real class (see the retraction below); the `Squad.*` bindings are real. The three `WSAI*` name strings that *do* appear for these (`WSAIWanderer`, `WSAINeedsTracker`, `WSAIPanicker` near lines 583545-583609) are RTTI type-name `strncpy`s in a constructor/registration blob, not method bodies — useful for locating the classes but not individual methods.
- ~~**Lua binding thunks not linked to C++ impls.**~~ ✅ **Resolved 2026-07-24.** The registration table was located: [`lua_registration_map.tsv`](../../data/lua_registration_map.tsv) maps all **898** bindings to `impl_va` / `thunk_va` / `vtable_va` plus the C++ symbol. `Nav.SetScriptedPath`, `Squad.Create` and the rest are now proven edges, not behavioural inferences. (Use that file, **not** `lua_bindings.txt`, which lists C++ symbols — 256 of 898 differ from the Lua name.)
- **`WSAIPathFollowerHuman::ChooseAndPlayCoverAnims` vs `BeginState`** share a file; the two VAs (`FUN_00861c40`, `FUN_00864738`) are distinguished only by their own anchor strings — correct, but the surrounding helpers (cover-point selection) are unnamed.
- Several manager update loops (`WSAICrowdManager`, `WSAITrafficManager`, `WSAIAutoPopManager`, `WSAICorpseManager`) were seen only via their `WSAICrowder`/`WSAITrafficAvoider` per-agent classes; the manager-level tick functions remain unpinned.

---

## Verification (adversarial pass)

**Verdict: solid** — 23/23 key functions confirmed against the decomp.

**Seams (cross-subsystem):**

- FUN_008bf650 WSAIHelperCombat::Update has callers=[] — it is virtual-dispatched (vtable) from a controller tick, never statically called; the doc presents it as the 'core soldier combat tick' but omits that there is no direct xref, so the caller seam (which controller's Update invokes it) is undocumented.
- FUN_00898440 BroadcastVehicleDamageGawkEvent is called by FUN_005ceed0 @0x005cf028 — a seam from the vehicle-damage subsystem (~0x5c range) into the AI hive mind; doc treats hive-mind broadcasts as self-contained.
- FUN_0089a1b0 BroadcastDeadBody is called by FUN_0080f410 @0x0080f50e — seam from the combat/damage-death subsystem (~0x80f) feeding the hive mind; not mentioned.
- FUN_00848000 WSAIControllerVehicle::ScaryEvent has a cross-subsystem caller FUN_00554980 @0x00554c44 (well outside the 0x84x AI range) in addition to FUN_00881f10; the external trigger source is undocumented.
- FUN_008ed1e0 WSAIAttractionPt::DeleteSynched has many callers spanning subsystems (0x00483a43, 0x004c1275, FUN_0048fbb0, FUN_008f5e10) — an entity/network-sync cleanup seam the doc does not describe.
- FUN_00864738 WSAIPathFollowerHuman::BeginState is called by FUN_00545962 @0x00545968 (low address, outside AI range) — likely the Nav.SetScriptedPath Lua-binding glue; this is the concrete Lua->AI seam the doc asserts but never pins to a caller VA.

**Additional gaps / suspected decomp corruption:**

- ws_engine_classes.txt is NOT exhaustive: WSAISuspicionRadius, WSAIExecutionManager, and a bare 'WSAICrowd' class are absent from it (it only lists WSAICrowder/WSAICrowdManager/WSAICrowdBlocker), yet all three appear as __FUNCTION__ strings in the decomp. Class-existence claims for those rest solely on the anchor strings, not on the RTTI/class list.
- Role attributions rest on __FUNCTION__/assertion anchor strings + .cpp path constants, NOT on verified decompiled control flow. The bodies are heavy Ghidra pointer-soup (FUN_008bf650 is declared as void __thiscall FUN_008bf650(int*, int******) with `int ******` locals); the logic itself was not shown to implement the claimed behavior, only that the function was compiled from the named source file. This is strong-but-indirect evidence.
- ~~Lua binding namespaces (Nav., Squad., AttractionPt.) are the doc author's inference — lua_bindings.txt is a flat, prefix-less list, so the table groupings are unproven from this data.~~ **Resolved 2026-07-24: the groupings are correct and now provable.** `lua_bindings.txt` is prefix-less because it lists *C++ symbols*; `data/lua_registration_map.tsv` carries the real Lua table + name for all 898 bindings, and `Nav.`/`Squad.`/`AttractionPt.` are all genuine registered tables.

**Verifier corrections:**

## AI & Behavior — verification corrections

**Functions: all 23 key VAs CONFIRMED.** Headers exist at claimed VAs, anchor strings land at the exact claimed line numbers inside the correct bodies, and every asserted size matches (13260/7087/2630/2473). `.cpp` source-path constants corroborate the subsystem for each.

**~~Lua API naming is partly wrong~~ — ❌ RETRACTED 2026-07-24. The corrections below were themselves
wrong; the doc's original `Squad.` / `AttractionPt.` / `Nav.` groupings are correct. Do not apply them.**

Root cause: **`data/lua_bindings.txt` is a list of C++ symbols, not Lua-callable names**, and 256 of
the 898 differ. The verifier looked up the Lua name, failed to find it, and concluded the table did
not exist. `data/lua_registration_map.tsv` (which carries both) settles it:

- ~~"there is no `Squad.` table"~~ — **there is**: 18 registered bindings. `Squad.Create` → C++
  `CreateSquad`, `Squad.AddMember` → `AddToSquad`, `Squad.SetEnemy` → `SetSquadEnemy`,
  `Squad.ClearBehavior` → `ClearSquadBehavior`, … Every name the doc listed resolves. (Independently
  reconfirmed from the Lua corpus: 13 distinct `Squad.*` methods across 189 call sites, all 13
  resolving — see `docs/sab-engine-lua-seam/06-lua-side-wrapper-layer.md`.)
- ~~"`AttractionPt.EnableUse` does not exist; it is `AttractionPtEnable`"~~ — **both exist and this
  inverts them**: `AttractionPt.EnableUse` → C++ `UsePtEnable`, while C++ `AttractionPtEnable` is
  registered as `AttractionPt.**EnableBroadcast**`. Applying this "fix" would have swapped two
  distinct bindings.
- The `Nav.` prefix is likewise real (23 registered `Nav.*` rows), not "a reasonable but unproven
  grouping". 22 of the 23 Lua names are byte-identical to the C++ symbol; the sole exception is
  `NavBoardVehicle`.

**Read `data/lua_registration_map.tsv`, not `lua_bindings.txt`, for anything Lua-visible.**

**Class list caveat:** WSAISuspicionRadius, WSAIExecutionManager, and a bare WSAICrowd class are referenced by the decomp anchors but are absent from ws_engine_classes.txt (which lists WSAICrowder/WSAICrowdManager/WSAICrowdBlocker instead). Treat ws_engine_classes.txt as a partial list, not authoritative for existence.
