# Human, Ragdoll & Disguise

*Subsystem slug: `human-disguise` — Pandemic WildStar/Odin engine, The Saboteur (2009).*

The `WSHuman` object is the actor/character model for every on-foot person in the
game (player, Nazis, civilians, resistance). This subsystem covers the human's
~30-entry **state machine**, its **physics/ragdoll** and fall/impact damage, the
**death** code paths, and the **disguise-suspicion perception system** that
governs how NPCs react to the player's cover.

Confidence is **high** for everything pinned below: nearly every function carries a
retail assert string of the form `WSHuman.cpp` + `"WSClass::Method"` + a line number,
or reads a named config key. The main gap is that without an RTTI vtable→VA map the
per-state class vtables and the `WSHumanStateDisguise` state class itself cannot be
tied to addresses (see Gaps).

## Class inventory (RTTI)

Core: `WSHuman`, `WSHumanManager` (singleton), `WSHumanPhysics`, `WSHumanRagdoll`,
`WSHumanAnimationManager` (singleton), `WSGlobalHumanParams`, `WSPhysicsHumanGear`.

Blueprints/setup: `WSHumanBlueprint`, `WSHumanBodySetup(+Blueprint)`,
`WSHumanBodyPartBlueprint`, `WSHumanSkeletonScale`, `WSHumanSpore(+Manager)`.

State machine (`WSHumanState` + subclasses): `OnGround`, `Ragdoll`, `Dying`, `Pain`,
`Pushed`, `Stumble`, `Passenger`, `Pickup`, `Attack`, `Melee`, `Grapple`, `Grabbed`,
`Climb`, `Clamber`, `Cover`, `Hang`, `HorizRope`, `Jump`, `Land`, `Drag`, `Shop`,
`Swimming`, `MiniGame(+Sabotage/Valve/Tappy/Waggle)`, `Disguise`, `Animate`.

AI/jobs: `WSAIControllerHuman`, `WSAIPathFollowerHuman`, `WSAIDisposableHumanManager`,
`WSHumanPhysicsJob`, `WSSyncedHumanUpdateJob`, `WSHavokEndOfHumanPhysicsJob`,
`WSPlayerDisguiseAction`. Havok ragdoll backing: `hkaRagdollInstance`,
`hkpRagdollConstraintData`.

## The state machine

`FUN_004f2bc0` (**WSHuman::GetStateName**) is a switch that maps the human-state enum
to a display string — `ONGROUND`(0), `RAGDOLL`, `HANGING`, `CLIMBING`, `PASSENGER`,
`MELEE`, `ATTACK`, `GRAPPLE`, `STUMBLE`, `DYING`, `SWIMMING`, `PICKUP`, `MINI_GAME`,
`PUSHED`, … `UNKNOWN_STATE_`. This gives the concrete enum ordering behind the
`WSHumanState*` classes. `FUN_0050d8c0` (**WSHuman::Update**, `this + float dt`) is the
per-frame tick, driven by the human update job (caller `0x005ad11b`).

## Physics, ragdoll & damage

- `FUN_00586fe0` — **WSHumanPhysics::DoUpdatePhysics** (physics job body).
- `FUN_005897e0` — **WSHumanPhysics::TakeFallDamage** (backs Lua `SetFallDamageRagdoll`).
- `FUN_00589bc0` — **WSHumanPhysics::TakeImpactDamage** (vehicle/blast impacts).
- `FUN_00577490` — **WSHumanStateRagdoll::TestCollisionWithOthers** (active ragdoll state).
- `FUN_0060c210` — **WSGhostOfDeath::ApplyRagdollIfRelevant** (corpse settling; calls
  `WSHuman::NotifyVehicleCollision`).
- `FUN_00714230` — **`lua_ActorRagdoll`**: the `Actor.cpp` Lua trampoline. Resolves a
  handle to a `WSHuman` (vtable slot `+0x1c`) and calls `FUN_0099bc00(obj,0,1.0f)`.

## Death paths

`FUN_004f69f0` (**WSHuman::Die**) is a thin forwarder; the real teardown is split
between `FUN_00503160` (**DieImmediateDropAndRagdoll**) and `FUN_0050c010`
(**DieImmediateNoDropOrRagdoll**), both dispatched from `FUN_0050cf70`. Damage enters
through `FUN_00506140` (**WSHuman::ApplyDamage**) and collisions through `FUN_004ffc10`
(**WSHuman::Collide**).

## Vehicles, conversation & AI hooks

`FUN_004fa8b0` (**EnterPilotable**) and `FUN_00570020`
(**WSHumanStatePassenger::FinishEject**) tie the human into the vehicle seat system;
`FUN_004fad70` (**NotifyVehicleCollision**) feeds impact reactions. `FUN_004fa7e0`
(**BeginConversation**) fronts the Lua conversation queries. `FUN_00840b70`
(**WSAIControllerHuman::UpdateRooftop**) and `FUN_009c4bb0`
(**WSHumanAnimationManager::UpdateSharedAnimations**) drive AI and shared animation.

## Disguise-suspicion perception

The "disguise" mechanic is implemented as a **suspicion meter** whose accrual and
detection radius depend on what the disguised player is doing:

- `FUN_008e6bd0` (**DisguiseSuspicionMeter::InitParams**) loads the tuning table via
  `FUN_00838410`: `Susp_YellowTimeUp`, `Susp_{SuperLow..High}Mult`, `Susp_CooldownMult(_Fast)`,
  and the disguised-side mirror `Disg_{SuperLow..High}Mult`, `Disg_CooldownMult(_Fast)`,
  `Disg_CooldownRate{Min,Max,Time}`.
- `FUN_008e77c0` (**DisguiseSuspicion::GetActivityRadius**) picks a detection radius by
  activity: `Disg_DisguiseRadius`, `Disg_SuspicionZoneRadius`, `Disg_SabotageRadius`,
  `Disg_StealthKillRadius`, `Disg_RagdollRadius`, `Disg_GrenadeThrowRadius`,
  `Disg_WeaponAimedRadius`, `Disg_Sneaking/Loiter/Jog/SprintRadius`. Paired with
  `FUN_008e7d10`, both called each frame from `FUN_008e8100`.
- `FUN_016224e0` (**WSPlayer::ShortcutForceDisguise**) is the debug shortcut that forces
  the player into disguise state `0x16` via transition helper `FUN_009998a0`.

## Lua API surface (`Actor` namespace)

`ActorRagdoll`, `ActorIsAlive`, `ActorIsDisguised`, `ActorHasUseableDisguise`,
`ActorSetDisguise` / `ActorRemoveDisguise` / `ActorSetNeverBloodyDisguise`,
`ObjectIsHuman`, `AllowHumanDamage`, `IsRagdollInWater`, `SetFallDamageRagdoll` /
`ResetFallDamageRagdoll`, `SetDropWeaponWhenRagdolled`, plus the callback registrars
`RegisterRagdollCallback` / `SetDisguise{,Started,Complete}Callback` /
`SetLostDisguiseCallback` and their `Clear*` pairs. Corpus usage:
`Util.SetDisguiseCallback("<Mission>.GotDisguise", self)` (e.g. `FuelDepot_E3.lua`,
`Paris_1_Mission_1B.lua`); disguise closets via the `SpawnCloset*` use-points.

## Gaps

- No vtable→VA map: `WSHuman` ctor/vtable, `WSHumanManager`, and each
  `WSHumanState*` subclass's Enter/Update/Exit are unpinned.
- `WSHumanStateDisguise` has no string anchor — the disguise evidence pins the
  *suspicion meter* and `WSPlayer::ShortcutForceDisguise`, not the state class.
- `WSHumanRagdoll` / `hkaRagdollInstance` bone-mapping wrappers not located by string.
- Actor.cpp Lua bindings other than `ActorRagdoll` are not string-greppable; they
  cluster near `FUN_00714230` under a registration caller (~`0x00716b25`).
- Disguise/ragdoll **callback** bindings and `WSHumanSpore*` / `WSAIDisposableHumanManager`
  had no usable anchor in the sampled regions.

---

## Verification (adversarial pass)

**Verdict: solid** — 25/25 key functions confirmed against the decomp.

**Seams (cross-subsystem):**

- Fall/impact damage share a WSHuman-side dispatcher the doc missed: FUN_0058ad00 calls BOTH WSHumanPhysics::TakeFallDamage (0x0058ace3) and WSHumanPhysics::TakeImpactDamage (0x0058acef) back-to-back; FUN_0058ad00 is itself called by FUN_005074e0 (WSHuman TU). Doc treats the two damage fns separately and never names their common caller.
- Generic-object module 0x0099xxxx is the real hub tying this subsystem to Lua + death + disguise: WSHuman::Die -> FUN_009997a0; lua_ActorRagdoll -> FUN_0099bc00; WSPlayer::ShortcutForceDisguise -> FUN_009998a0; and the death dispatcher FUN_0050cf70's OWN caller is FUN_0099bd00 (0x0099bdea). Doc cites the individual calls but never identifies this shared 'generic object action' module as one seam.
- WSHuman::ExitMeleeStateAI (FUN_004f7dd0) is called by 12+ AI-controller functions in the 0x0087-0x0095 range (FUN_008c8140, 008b8610, 008c6640, 008ca620, 00950c30, 00878f60, ...) = strong seam into the AI/combat subsystem; doc only says 'heavily-called' without naming the AI side.
- Human physics update job chain: FUN_004f8840 -> FUN_00588f60 (job wrapper) -> WSHumanPhysics::DoUpdatePhysics (FUN_00586fe0). Doc names only the immediate wrapper.
- WSGhostOfDeath::ApplyRagdollIfRelevant (FUN_0060c210) is driven from two update paths: FUN_01624d70 (0x01624df0) and FUN_0060c6d0 (0x0060c7f9) — corpse settling is invoked from the ghost-of-death update loop, doc only describes its callee (NotifyVehicleCollision).

**Additional gaps / suspected decomp corruption:**

- DieImmediateDropAndRagdoll (FUN_00503160) has a 5th caller the doc's caller list omits: 0x00568735 (FUN_005686b0, itself called by FUN_0056ead0) — a non-passenger death path not mentioned alongside the passenger/eject callers.
- Four key functions show callers=[] (Collide FUN_004ffc10, ApplyDamage FUN_00506140, UpdateSharedAnimations FUN_009c4bb0, ShortcutForceDisguise FUN_016224e0). These are vtable-virtual / Lua-thunk / debug-cheat dispatched, so absence of static xrefs is expected, but the doc should mark them as such rather than implying normal direct-call reachability.
- Several xref call-sites resolve to a bare address with no enclosing FUN_ label in the decomp (0x005ad11b for Update, 0x0058ace3/0x0058acef for the physics-damage pair, 0x0057836d/0x005786a5 for TestCollisionWithOthers, 0x0084194d for UpdateRooftop, 0x00716b25 for lua_ActorRagdoll, 0x00512106 for DeleteSynched). Not corruption, but the enclosing functions were not carved out by the disassembler — worth a re-analysis pass to name those callers.
- Secondary/interpretive 'fronts/backs Lua' claims are unverified by the embedded strings: e.g. BeginConversation (FUN_004fa7e0) 'fronts Lua GetHumanConversationID / IsHumanInConversation' — the string only proves the method name; those Lua getters more plausibly read a conversation-id field than route through BeginConversation. Treat the Lua<->method pairings as hypotheses, not established.

**Verifier corrections:**

All 25 key VAs verified: every header exists, every claimed embedded `WSxxx::Method` string sits at the exact claimed line and inside the correct function body, caller lists match, all 24 sampled classes are present in rtti_classes_all.txt, and all 23 sampled Lua bindings are present in lua_bindings.txt. GetStateName (FUN_004f2bc0) additionally emits DISGUISE at case 0x16 (consistent with ShortcutForceDisguise forcing state 0x16) plus a JUMP (MARIO) easter-egg branch — doc's string list is a partial sample, fine.

Fold-in edits:
- TakeFallDamage / TakeImpactDamage: add shared dispatcher FUN_0058ad00 (WSHuman-side via FUN_005074e0); it invokes both at 0x0058ace3 and 0x0058acef.
- DieImmediateDropAndRagdoll (FUN_00503160): add 5th caller 0x00568735 (FUN_005686b0).
- Note the shared generic-object module (FUN_009997a0 / 009998a0 / 0099bc00 / 0099bd00) as the hub linking Die, ragdoll, disguise-state-transition, and the death dispatcher FUN_0050cf70.
- Mark Collide, ApplyDamage, UpdateSharedAnimations, ShortcutForceDisguise as vtable/Lua/debug-dispatched (explains callers=[]).
- Downgrade the "BeginConversation fronts GetHumanConversationID/IsHumanInConversation" pairing to a hypothesis.
