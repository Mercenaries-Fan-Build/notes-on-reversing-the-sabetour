# Family 10 — Actor / Human / disguise / ragdoll / health-state

> **Verified:** adversarial re-check against the decomp, `Saboteur.exe` bytes and the Lua corpus. All 111
> VAs/names/`cpp_symbol`s reconcile with `lua_registration_map.tsv` (0 mismatches); the 12 decomp-absent
> rows are exactly the 10 `impl==thunk` + 2 gap rows; exactly 4 bodies carry an `Actor.cpp` assert string
> (names and lines 475/1371/1717/3285 all check out); all 77 corpus citations resolve to the named call;
> the 34-dead set is set-equal across corpus and `LuaScripts.luap` as claimed; every byte-level listing
> (pushboolean/pushnumber chains, the 4 `Reset*` thunks, the 4 no-ops, `PlayerBlockSabLighting`,
> `ExitSpecialKillMode`, the setter→slot pairing, all eight `-99.0`) reproduces exactly; no argument is
> fabricated (every claimed index is fetched by its body); no Mercenaries 2 import found.
> **Corrected:** the doc's cross-references were the weak point — four `§` refs pointed at the wrong
> section or the wrong document (the "never a name hash" and "double gate" claims are the *handle
> model's* §7/§4, not the ABI note's; the prologue is ABI §4, not §1), `DispatchCollisionDamage` is named
> by *damage-physics.md*, not human-disguise.md, and `WSHumanStateDying` is an RTTI-list class not
> mentioned in human-disguise.md at all; the series link pointed at a `README.md` that does not exist in
> this directory (now `00-seam-overview.md`), so the "all 10 links resolve" self-check was wrong. Substantively:
> `TakeFallDamage` is not the sole reader of the tunables (4 readers; a second named consumer,
> `TakeImpactDamage`, added) and it is assert-string–confirmed in its own body rather than inherited from
> a sibling doc; the "arithmetic is unreachable" mechanism was wrong (the gate *passes* — the arithmetic
> runs and yields negative damage; the conclusion that fall damage is inert is unchanged and now rests on
> the right instruction); `GetHandleByName` pushes the symbol on two exit paths, not one; the
> `lua_pushboolean` find is narrowed to the *wrapper* (the raw chain was already in the ABI note's §3);
> `RequestAttrPt`'s table row now carries the trailer its own prose derives; trailer-slot overloading in
> the `PlayAnimation*` rows and six body-absent annex rows are now flagged.

*Part of the [engine↔Lua seam](00-seam-overview.md) series. Engine-side subsystem notes live in
[docs/symbol_map/human-disguise.md](../symbol_map/human-disguise.md); the ABI used to read every
body below is [02-marshalling-abi.md](02-marshalling-abi.md); the handle model is
[03-handle-and-object-model.md](03-handle-and-object-model.md).*

The `Actor` table is the script layer's interface to `WSHuman` — every on-foot person in the game.
It is the largest single binding table after `Util` and it is where the mission scripts spend most
of their time: disguises, ragdolls, panic, needs/schedules, attraction points, vehicle boarding
and animation all enter here.

## Inclusion rule (auditable boundary)

A binding is **in this family** iff it satisfies (A) or (B):

- **(A) Table membership.** Its `table` column in [`data/lua_registration_map.tsv`](../../data/lua_registration_map.tsv)
  is `Actor`. This is the anchor rule and yields **111** bindings. It is used unconditionally, even
  where the binding's *subject* belongs to a sibling family — `Actor.BoardVehicle` is claimed here
  (not by vehicle), `Actor.PlayAnimation` is claimed here (not by animation), `Actor.RequestAttrPt`
  is claimed here (not by attraction-point). Those are **deliberate overlaps**, flagged in the table.
- **(B) Subject match outside the `Actor` table.** Its `lua_name`/`cpp_symbol` concerns disguise,
  ragdoll, human-ness, or health/death state while living in another table. This yields **20** more,
  listed separately in the [Boundary annex](#boundary-annex-family-subject-outside-the-actor-table)
  and *not* counted in the core coverage figures, because tables `Object`, `Util`, `Cin`, `Combat`
  and `Render` are owned by sibling docs.

Rule (A) is mechanical and complete. Rule (B) is a judgement call: I claim these names rather than
omit them silently, but a sibling family may legitimately claim them too.

**Ambiguous names claimed here and why:** `Actor.SurgeonGeneral` (obscure name, global boolean, it
gates civilian gore — claimed on the health-state reading), `Actor.TurnOnDude` (name says nothing;
body is a per-actor enable), `Actor.Immolate` (fire damage — overlaps damage-physics).

## Coverage

| | count |
|---|---:|
| Bindings in family core (rule A) | **111** |
| Located (VA pinned **and** body read) | **111 / 111** |
| — body available in the Ghidra decomp | 99 |
| — **body absent from the decomp**, recovered by hand-disassembling `Saboteur.exe` | **12** |
| **Confirmed** (assertion string, or byte-level disassembly) | **16** |
| — of which by EALA assertion string (`Script\Interface\Actor.cpp`) | 4 |
| — of which by hand-disassembly of bytes Ghidra never emitted | 12 |
| **Inferred** (body read + ABI decode; 71 also have a real call site) | **95** |
| **Not found** | **0** |
| Signature independently agreed by two derivation methods | 92 / 99 |
| Referenced by at least one shipped script | **77 / 111** |
| **Never referenced by any shipped script (dead surface)** | **34 / 111** |

Every row is `inferred` unless marked **confirmed**. `inferred` means: the prologue matched
[02-marshalling-abi.md](02-marshalling-abi.md) §4, the `FUN_006f7*` checks decode to the argument list
shown, and (for 71 of them) a real call site agrees. It is a proposal, not a fact.

## Method note — why 12 bindings needed hand-disassembly

Twelve `Actor` bindings have **no function body in the 54 MB decomp at all**, so they cannot be read
the normal way. They split into two causes, both verified against the retail exe
(`C:\GOG Games\The Saboteur\Saboteur.exe`, imagebase `0x00400000`):

- **Ten `shape=inlined` rows** where `impl_va == thunk_va`: the C++ functor body was inlined *into*
  the registered `lua_CFunction`, so there is no separate function for Ghidra to name.
- **Two `shape=jmp` rows** — `Actor.IsDisguised` (`0x0070c6a0`) and `Actor.IsRagdollInWater`
  (`0x0070c300`) — that simply fall in gaps Ghidra never decompiled. `FUN_0070c640` (size 90) ends at
  `0x0070c69a`, and the next emitted function is `FUN_0070c730`; `0x0070c6a0` sits in that hole. Both
  are ordinary bindings with the canonical prologue of [02-marshalling-abi.md](02-marshalling-abi.md) §4.

Naïvely disassembling a fixed byte window from `impl_va` produces **wrong signatures** — it runs past
the function end into the next one. (`Actor.Ragdoll` gains a phantom `a2:boolean`; `Actor.IsDisguised`
gains a phantom `a1:string` borrowed from `EnableLongIdle` next door.) Every scan below is bounded by
the decomp's `size=` field, or where absent, by the next known code start.

## A wrapper the cheat sheet's push table is missing: `FUN_006f7020`

Every `Is*` predicate in this family pushes its result through **`FUN_006f7020`**. The ABI note already
identifies the *raw* `lua_pushboolean` (its §3 table lists `0x004019b0` → `0x00460596` → `0x004019c4`,
`tt=1`, `top += 8`) — what it does not list is the Pandemic **wrapper** method that the bindings actually
call, so its wrapper push table (§5, "Pushes") has an entry missing. The chain:

`0x006f7020` `jmp 0x0043fbc6` → `movzx eax, byte [esp+4]` (an out-of-line argument-widening
prologue) → `jmp 0x006f7025` → `mov ecx,[ecx]; push eax; push ecx; call 0x004019b0` → the already-known
raw `lua_pushboolean`, whose `0x00460596` leg writes `mov [ecx+4], 1` = `LUA_TBOOLEAN`.

So: **`FUN_006f7020` = `lua_pushboolean(L, b)`**, `__thiscall(wrapper, bool)`, `void` (the callers set
`eax = 1` themselves). *(confirmed, byte-level.)* It belongs alongside `FUN_006f7010`/`FUN_006f7040`/
`FUN_006f7060` in that table.

En route, `FUN_006f7060` (`lua_pushnumber`) tailing into `0x004017d0` — `fld [esp+8]; fstp [ecx];
mov [ecx+4], 3; add [L+8], 8` — re-confirms from bytes that `lua_Number` is **float**, `LUA_TNUMBER` is
`3`, and `TValue` is **8 bytes**. That is a re-derivation of the ABI note's §2 finding, not a new one.

## The table

Arg shorthand: `h`=handle (lightuserdata), `s`=string, `n`=number, `b`=boolean, `t`=table, `i`=int;
`[x]`=optional (nil-probed or arity-gated). The digit is the **1-based Lua stack index**. `→ 1 (forced)`
means the `LuaGlueFunctor0` adapter hardcodes `nresults=1` regardless of what the body pushed — it is
*not* a return value (see [02-marshalling-abi.md](02-marshalling-abi.md) §6). `→ 0 or 1` marks the
`LuaGlueFunctor0R` family, the only one whose result count is real.

| Binding | Namespaced form | VA | Source (file:line) | Signature | Confidence | Evidence |
|---|---|---|---|---|---|---|
| `AddFaceExpression` | `Actor.AddFaceExpression` | `0x0070f0f0` | — | `Actor.AddFaceExpression(h1,s2,n3)` → 1 (forced) *(arg overload: arg1:{handle\|string})* | inferred | body only — **DEAD (0 script refs)** |
| `AddNeed` | `Actor.AddNeed` | `0x00710a80` | — | `Actor.AddNeed(h1,n2,n3)` → 1 (forced) | inferred | body + `Experimental/Soldier_Internal.lua:69` |
| `AddSafetyNeed` | `Actor.AddSafetyNeed` | `0x00710b60` | — | `Actor.AddSafetyNeed(h1,n2,h3,n4,n5)` → 1 (forced) *(arg overload: arg3:{handle\|number})* | inferred | body + `Missions/Act_1_Race.lua:1041` |
| `AreNeedsEnabled` | `Actor.AreNeedsEnabled` | `0x00712340` | — | `Actor.AreNeedsEnabled(h1)` → 0 or 1 | inferred | body only — **DEAD (0 script refs)** |
| `BoardVehicle` | `Actor.BoardVehicle` | `0x00711a40` | `Actor.cpp:1371` | `Actor.BoardVehicle(h1,h2,s3,b4)` → 1 (forced) | **confirmed** | assert string + `Experimental/SoldierState_Idle.lua:34` |
| `BroadcastScaryEvent` | `Actor.BroadcastScaryEvent` | `0x0070c3c0` | `Actor.cpp:1717` | `Actor.BroadcastScaryEvent(h1,n2)` → 1 (forced) | **confirmed** | assert string — **DEAD (0 script refs)** |
| `CalcFacingTo` | `Actor.CalcFacingTo` | `0x00710550` | — | `Actor.CalcFacingTo(h1,h2,n3,n4)` → 0 or 1 *(arg overload: arg2:{handle\|number})* | inferred | body + `Missions/Act_1_ConnectToBar.lua:182` |
| `CancelAnimation` | `Actor.CancelAnimation` | `0x00710210` | — | `Actor.CancelAnimation(h1)` → 1 (forced) | inferred | body + `Experimental/MgrHarasser.lua:280` |
| `CancelAttrPt` | `Actor.CancelAttrPt` | `0x00711590` | — | `Actor.CancelAttrPt(h1,b2)` → 1 (forced) | inferred | body + `Experimental/Checkpoint.lua:315` |
| `CancelAttrPtRequest` | `Actor.CancelAttrPtRequest` | `0x00711720` | — | `Actor.CancelAttrPtRequest(h1,b2)` → 1 (forced) | inferred | body + `Missions/Act_3_Mission_3.lua:750` |
| `ChangeModule` | `Actor.ChangeModule` | `0x0070f370` | — | `Actor.ChangeModule(h1,s2)` → 1 (forced) | inferred | body + `Experimental/Checkpoint_v2.lua:61` |
| `ClearRagdollCallback` | `Actor.ClearRagdollCallback` | `0x0070c490` | — | `Actor.ClearRagdollCallback(h1)` → 1 (forced) | inferred | body only — **DEAD (0 script refs)** |
| `EnableAllLongIdles` | `Actor.EnableAllLongIdles` | `0x00714790` | — | `Actor.EnableAllLongIdles(h1,b2)` → 1 (forced) | inferred | body + `Missions/SeptemberTrailer.lua:131` |
| `EnableLongIdle` | `Actor.EnableLongIdle` | `0x0070c730` | — | `Actor.EnableLongIdle(s1,b2)` → 1 (forced) | inferred | body only — **DEAD (0 script refs)** |
| `EnableNeed` | `Actor.EnableNeed` | `0x00712270` | — | `Actor.EnableNeed(h1,i2,b3)` → 1 (forced) | inferred | body only — **DEAD (0 script refs)** |
| `EnableNeeds` | `Actor.EnableNeeds` | `0x00712190` | — | `Actor.EnableNeeds(h1,b2)` → 1 (forced) | inferred | body + `Missions/Act_1_BarFight.lua:443` |
| `EnableSchedule` | `Actor.EnableSchedule` | `0x007120e0` | — | `Actor.EnableSchedule(h1,b2)` → 1 (forced) | inferred | body + `Experimental/IdleCiv.lua:6` |
| `PlayerEnterSpecialKillMode` | `Actor.EnterSpecialKillMode` | `0x00715290` | — | `Actor.EnterSpecialKillMode(h1,h2,n3,n4)` → 1 (forced) | inferred | body + `Missions/Act_3_Mission_2.lua:1882` |
| `PlayerKillModeCancel` | `Actor.ExitSpecialKillMode` | `0x007163c0` | — | `Actor.ExitSpecialKillMode()` → 1 (forced) | **confirmed** | hand-disasm (absent from decomp) + `Missions/Act_3_Mission_2.lua:1403` |
| `FireCurrentWeapon` | `Actor.FireCurrentWeapon` | `0x00710d70` | — | `Actor.FireCurrentWeapon(h1,n2)` → 1 (forced) | inferred | body + `Missions/Act_3_Mission_1_E3.lua:449` |
| `ForceLongIdle` | `Actor.ForceLongIdle` | `0x00714840` | — | `Actor.ForceLongIdle(s1,h2,s3,t5)` → 1 (forced) | inferred | body + `Missions/SeptemberTrailer.lua:113` |
| `ForceSmoking` | `Actor.ForceSmoking` | `0x007149b0` | — | `Actor.ForceSmoking(h1)` → 1 (forced) | inferred | body + `Missions/CFP_GiselleRescue.lua:345` |
| `GetActorDist` | `Actor.GetActorDist` | `0x00710750` | — | `Actor.GetActorDist(h1,h2)` → 0 or 1 | inferred | body + `Experimental/SoldierState_Investigate.lua:27` |
| `GetCurrentModule` | `Actor.GetCurrentModule` | `0x0070f420` | — | `Actor.GetCurrentModule(h1)` → 0 or 1 | inferred | body + `Experimental/MgrHarasser.lua:232` |
| `GetFacingDir` | `Actor.GetFacingDir` | `0x00710300` | — | `Actor.GetFacingDir(h1)` → 0 or 1 | inferred | body + `Experimental/Checkpoint.lua:48` |
| `GetModuleInputs` | `Actor.GetModuleInputs` | `0x00716920` | — | `Actor.GetModuleInputs()` → see body | **confirmed** | hand-disasm (absent from decomp) — **DEAD (0 script refs)** |
| `ActorGetPosition` | `Actor.GetPosition` | `0x00710990` | — | `Actor.GetPosition(h1)` → see body | inferred | body + `Missions/P1FP_DestroyConvoy.lua:592` |
| `GetPredefinedModule` | `Actor.GetPredefinedModule` | `0x00716890` | — | `Actor.GetPredefinedModule()` → see body | **confirmed** | hand-disasm (absent from decomp) — **DEAD (0 script refs)** |
| `GetSelf` | `Actor.GetSelf` | `0x007126c0` | — | `Actor.GetSelf(h1)` → 0 or 1 | inferred | body + `Experimental/Checkpoint.lua:463` |
| `GetVehicle` | `Actor.GetVehicle` | `0x00711ff0` | — | `Actor.GetVehicle(h1)` → 0 or 1 | inferred | body + `Experimental/SoldierState_PaperCheckLeader.lua:105` |
| `GetWeaponPitch` | `Actor.GetWeaponPitch` | `0x00710e50` | — | `Actor.GetWeaponPitch(h1)` → 0 or 1 | inferred | body + `Missions/Paris_1_Mission_1B.lua:1813` |
| `GlobalEnableHighWTFCivMelee` | `Actor.GlobalEnableHighWTFCivMelee` | `0x0070c830` | — | `Actor.GlobalEnableHighWTFCivMelee(b1)` → 1 (forced) | inferred | body + `Managers/RewardsManager.lua:5265` |
| `HasLabel` | `Actor.HasLabel` | `0x007125e0` | — | `Actor.HasLabel(h1,s2)` → 0 or 1 | inferred | body + `Experimental/Checkpoint.lua:161` |
| `ActorHasUseableDisguise` | `Actor.HasUseableDisguise` | `0x00712b60` | — | `Actor.HasUseableDisguise(h1)` → 0 or 1 *(arg overload: arg1:{handle\|string})* | inferred | body + `Missions/P1FP_Traitor.lua:815` |
| `HolsterWeaponImmediate` | `Actor.HolsterWeaponImmediate` | `0x00714a60` | — | `Actor.HolsterWeaponImmediate(h1)` → 1 (forced) | inferred | body + `Includes/__UtilFunctions.lua:576` |
| `Immolate` | `Actor.Immolate` | `0x00713bf0` | — | `Actor.Immolate(h1)` → 1 (forced) | inferred | body + `Missions/Paris_2_Mission_5.lua:3055` |
| `IsAShop` | `Actor.IsAShop` | `0x00713050` | — | `Actor.IsAShop(h1)` → 0 or 1 | inferred | body only — **DEAD (0 script refs)** |
| `ActorIsAlive` | `Actor.IsAlive` | `0x00713620` | — | `Actor.IsAlive(h1)` → 0 or 1 | inferred | body + `Missions/P1FP_NaziParty.lua:152` |
| `IsDisguisable` | `Actor.IsDisguisable` | `0x00715060` | — | `Actor.IsDisguisable(h1)` → 0 or 1 | inferred | body + `Missions/Paris_1_Mission_1B.lua:1087` |
| `ActorIsDisguised` | `Actor.IsDisguised` | `0x0070c6a0` | — | `Actor.IsDisguised(h1)` → 0 or 1 | **confirmed** | hand-disasm (absent from decomp) + `Missions/P1FP_Jailbreak.lua:977` |
| `IsInCombat` | `Actor.IsInCombat` | `0x00713990` | — | `Actor.IsInCombat(h1)` → 0 or 1 | inferred | body + `Missions/Act_1_BarFight.lua:983` |
| `IsInHunt` | `Actor.IsInHunt` | `0x007138b0` | — | `Actor.IsInHunt(h1)` → 0 or 1 | inferred | body only — **DEAD (0 script refs)** |
| `IsInIdle` | `Actor.IsInIdle` | `0x007136f0` | — | `Actor.IsInIdle(h1)` → 0 or 1 | inferred | body only — **DEAD (0 script refs)** |
| `IsInInvestigate` | `Actor.IsInInvestigate` | `0x007137d0` | — | `Actor.IsInInvestigate(h1)` → 0 or 1 | inferred | body only — **DEAD (0 script refs)** |
| `IsInVehicle` | `Actor.IsInVehicle` | `0x00711ed0` | — | `Actor.IsInVehicle(h1,b2)` → 0 or 1 | inferred | body + `Experimental/Checkpoint.lua:96` |
| `IsRagdollInWater` | `Actor.IsRagdollInWater` | `0x0070c300` | — | `Actor.IsRagdollInWater(h1)` → 0 or 1 | **confirmed** | hand-disasm (absent from decomp) + `Missions/Paris_1_Mission_1B.lua:1108` |
| `IsSlacker` | `Actor.IsSlacker` | `0x00712f80` | — | `Actor.IsSlacker(h1)` → 0 or 1 | inferred | body only — **DEAD (0 script refs)** |
| `IsTalkable` | `Actor.IsTalkable` | `0x007133b0` | — | `Actor.IsTalkable(h1)` → 0 or 1 | inferred | body + `Modules/SabTaskObjectiveInteract.lua:578` |
| `IsUsingAttrPt` | `Actor.IsUsingAttrPt` | `0x00711920` | — | `Actor.IsUsingAttrPt(h1)` → 0 or 1 | inferred | body + `Experimental/Checkpoint.lua:314` |
| `OverrideCombatAI` | `Actor.OverrideCombatAI` | `0x00714090` | — | `Actor.OverrideCombatAI(h1,b2)` → 1 (forced) | inferred | body + `Missions/Act_1_BarFight.lua:480` |
| `PlayAnimation` | `Actor.PlayAnimation` | `0x0070f4f0` | — | `Actor.PlayAnimation(h1,s2,n3,b4,n5,s6,t8,b9,s10,b11)` → 1 (forced) | inferred | body + `Experimental/Checkpoint.lua:284` |
| `PlayAnimationToBone` | `Actor.PlayAnimationToBone` | `0x0070fa40` | — | `Actor.PlayAnimationToBone(h1,s2,h3,h4,s5,t7)` → 1 (forced) | inferred | body + `Missions/SOE_2_Mission_2.lua:1865` |
| `PlayAnimationToPoint` | `Actor.PlayAnimationToPoint` | `0x0070fe00` | `Actor.cpp:475` | `Actor.PlayAnimationToPoint(h1,s2,n3,n4,n5,n6,n7,n8,b9,s10,t11)` → 1 (forced) | **confirmed** | assert string — **DEAD (0 script refs)** |
| `PlayLongIdle` | `Actor.PlayLongIdle` | `0x00714680` | — | `Actor.PlayLongIdle(h1,s2)` → 1 (forced) | inferred | body only — **DEAD (0 script refs)** |
| `PlayerBlockSabLighting` | `Actor.PlayerBlockSabLighting` | `0x00716330` | — | `Actor.PlayerBlockSabLighting()` → 1 (forced) | **confirmed** | hand-disasm (absent from decomp) — **DEAD (0 script refs)** |
| `PlayerOnSabSetGrenadeToExplode` | `Actor.PlayerOnSabSetGrenadeToExplode` | `0x0070c890` | — | `Actor.PlayerOnSabSetGrenadeToExplode(n1)` → 1 (forced) | inferred | body only — **DEAD (0 script refs)** |
| `PullFromVehicle` | `Actor.PullFromVehicle` | `0x00711cd0` | — | `Actor.PullFromVehicle(h1,h2,s3)` → 1 (forced) | inferred | body only — **DEAD (0 script refs)** |
| `ActorRagdoll` | `Actor.Ragdoll` | `0x00714230` | `Actor.cpp:3285` | `Actor.Ragdoll(h1)` → 1 (forced) | **confirmed** | assert string + `Missions/Act_1_Farm.lua:755` |
| `RegisterRagdollCallback` | `Actor.RegisterRagdollCallback` | `0x0070efd0` | — | `Actor.RegisterRagdollCallback(h1,s2,t3,t4)` → 1 (forced) | inferred | body only — **DEAD (0 script refs)** |
| `ActorRemoveDisguise` | `Actor.RemoveDisguise` | `0x00712a70` | — | `Actor.RemoveDisguise(h1)` → 1 (forced) *(arg overload: arg1:{handle\|string})* | inferred | body + `Missions/Act_1_Race.lua:1087` |
| `RequestAttrPt` | `Actor.RequestAttrPt` | `0x00710fa0` | — | `Actor.RequestAttrPt(h1,h2,[b3],[s3′,[t4′],[t5′]])` → 1 (forced) *(sliding trailer — see [below](#the-optional-callback-trailer-and-a-decoding-trap))* | inferred | body + `Missions/Act_3_Mission_2.lua:854` |
| `ResetFallDamageDeath` | `Actor.ResetFallDamageDeath` | `0x007157c0` | — | `Actor.ResetFallDamageDeath()` → 1 (forced) | **confirmed** | hand-disasm (absent from decomp) — **DEAD (0 script refs)** |
| `ResetFallDamageMinSpeed` | `Actor.ResetFallDamageMinSpeed` | `0x00715860` | — | `Actor.ResetFallDamageMinSpeed()` → 1 (forced) | **confirmed** | hand-disasm (absent from decomp) — **DEAD (0 script refs)** |
| `ResetFallDamageMult` | `Actor.ResetFallDamageMult` | `0x00715810` | — | `Actor.ResetFallDamageMult()` → 1 (forced) | **confirmed** | hand-disasm (absent from decomp) — **DEAD (0 script refs)** |
| `ResetFallDamageRagdoll` | `Actor.ResetFallDamageRagdoll` | `0x00715770` | — | `Actor.ResetFallDamageRagdoll()` → 1 (forced) | **confirmed** | hand-disasm (absent from decomp) — **DEAD (0 script refs)** |
| `SetAnimPriority` | `Actor.SetAnimPriority` | `0x00712510` | — | `Actor.SetAnimPriority(h1,n2)` → 1 (forced) | inferred | body + `Missions/P1FP_NaziParty.lua:546` |
| `ActorSetAttrPt` | `Actor.SetAttrPt` | `0x00711870` | — | `Actor.SetAttrPt(h1,s2)` → 1 (forced) | inferred | body + `Modules/Behavior/Human/Nazi/Soldier.lua:40` |
| `SetAutoSeatTransition` | `Actor.SetAutoSeatTransition` | `0x00714bd0` | — | `Actor.SetAutoSeatTransition(h1,b2)` → 1 (forced) | inferred | body + `Includes/__UtilFunctions.lua:403` |
| `SetAutoUnboardOnOtherTeamBoard` | `Actor.SetAutoUnboardOnOtherTeamBoard` | `0x00714c80` | — | `Actor.SetAutoUnboardOnOtherTeamBoard(h1,b2)` → 1 (forced) | inferred | body only — **DEAD (0 script refs)** |
| `SetBailWhenVehicleOnFire` | `Actor.SetBailWhenVehicleOnFire` | `0x00714b20` | — | `Actor.SetBailWhenVehicleOnFire(h1,b2)` → 1 (forced) | inferred | body + `Missions/Act_1_Race.lua:1005` |
| `SetBreadCrumbs` | `Actor.SetBreadCrumbs` | `0x00714fe0` | — | `Actor.SetBreadCrumbs(h1,b2)` → 1 (forced) | inferred | body only — **DEAD (0 script refs)** |
| `SetCannotGetOutOfSeat` | `Actor.SetCannotGetOutOfSeat` | `0x00711e20` | — | `Actor.SetCannotGetOutOfSeat(h1,b2)` → 1 (forced) | inferred | body + `Missions/Act_1_GetCaught.lua:287` |
| `ActorSetDisguise` | `Actor.SetDisguise` | `0x00712920` | — | `Actor.SetDisguise(h1,s2,b3)` → 1 (forced) *(arg overload: arg1:{handle\|string})* | inferred | body + `Missions/Act_1_BarFight.lua:22` |
| `SetDistantRagdollSound` | `Actor.SetDistantRagdollSound` | `0x00714170` | — | `Actor.SetDistantRagdollSound(h1)` → 1 (forced) | inferred | body + `Missions/Act_3_Mission_2.lua:1031` |
| `SetDontSpawnDeadGuys` | `Actor.SetDontSpawnDeadGuys` | `0x0070ca90` | — | `Actor.SetDontSpawnDeadGuys(b1)` → 1 (forced) | inferred | body + `Missions/SOE_1_Mission_7.lua:154` |
| `SetDropWeaponWhenRagdolled` | `Actor.SetDropWeaponWhenRagdolled` | `0x007143d0` | — | `Actor.SetDropWeaponWhenRagdolled(h1,b2)` → 1 (forced) | inferred | body + `Missions/Paris_1_Mission_6.lua:895` |
| `SetEscDespawnImmune` | `Actor.SetEscDespawnImmune` | `0x00713a70` | — | `Actor.SetEscDespawnImmune(h1,b2)` → 1 (forced) | inferred | body only — **DEAD (0 script refs)** |
| `SetFacingDir` | `Actor.SetFacingDir` | `0x00710400` | — | `Actor.SetFacingDir(h1,n2)` → 1 (forced) *(arg overload: arg2:{handle\|number})* | inferred | body + `Includes/WRAPPER_Actor.lua:36` |
| `SetFallDamageDeath` | `Actor.SetFallDamageDeath` | `0x0070c580` | — | `Actor.SetFallDamageDeath(n1)` → 1 (forced) | inferred | body only — **DEAD (0 script refs)** |
| `SetFallDamageMinSpeed` | `Actor.SetFallDamageMinSpeed` | `0x0070c5e0` | — | `Actor.SetFallDamageMinSpeed(n1)` → 1 (forced) | inferred | body only — **DEAD (0 script refs)** |
| `SetFallDamageMult` | `Actor.SetFallDamageMult` | `0x0070c640` | — | `Actor.SetFallDamageMult(n1)` → 1 (forced) | inferred | body only — **DEAD (0 script refs)** |
| `SetFallDamageRagdoll` | `Actor.SetFallDamageRagdoll` | `0x0070c520` | — | `Actor.SetFallDamageRagdoll(n1)` → 1 (forced) | inferred | body only — **DEAD (0 script refs)** |
| `SetForceRedInReticule` | `Actor.SetForceRedInReticule` | `0x00715410` | — | `Actor.SetForceRedInReticule(h1,b2)` → 1 (forced) | inferred | body + `Missions/P1FP_EustacheSniper.lua:535` |
| `SetHealthRecoveryPct` | `Actor.SetHealthRecoveryPct` | `0x007145e0` | — | `Actor.SetHealthRecoveryPct(h1,n2)` → 1 (forced) | inferred | body + `Missions/Paris_2_Mission_5.lua:1247` |
| `SetLabel` | `Actor.SetLabel` | `0x00712420` | — | `Actor.SetLabel(h1,s2,b3)` → 1 (forced) | inferred | body + `Experimental/SoldierState_PaperCheckLeader.lua:86` |
| `SetMissionCriticalNPC` | `Actor.SetMissionCriticalNPC` | `0x00715150` | — | `Actor.SetMissionCriticalNPC(h1,b2)` → 1 (forced) | inferred | body + `Missions/Act_1_GetCaught.lua:1365` |
| `SetModuleInputs` | `Actor.SetModuleInputs` | `0x00716930` | — | `Actor.SetModuleInputs()` → 1 (forced) | **confirmed** | hand-disasm (absent from decomp) + `Experimental/Checkpoint_v2.lua:63` |
| `ActorSetNeverBloodyDisguise` | `Actor.SetNeverBloodyDisguise` | `0x00712cb0` | — | `Actor.SetNeverBloodyDisguise(h1,b2)` → 1 (forced) *(arg overload: arg1:{handle\|string})* | inferred | body + `Missions/P1FP_Traitor.lua:829` |
| `SetNonKnockdownable` | `Actor.SetNonKnockdownable` | `0x007151f0` | — | `Actor.SetNonKnockdownable(h1,b2)` → 1 (forced) | inferred | body + `Missions/Act_1_Farm.lua:676` |
| `SetPanicEnabled` | `Actor.SetPanicEnabled` | `0x00713e40` | — | `Actor.SetPanicEnabled(h1,b2)` → 1 (forced) | inferred | body + `Missions/Act_1_Factory.lua:330` |
| `SetPanicFleeingEnabled` | `Actor.SetPanicFleeingEnabled` | `0x00713f10` | — | `Actor.SetPanicFleeingEnabled(h1,b2)` → 1 (forced) | inferred | body + `Modules/Behavior/Human/Civilian/KissingGirl.lua:4` |
| `SetPanicMode` | `Actor.SetPanicMode` | `0x00712dd0` | — | `Actor.SetPanicMode(h1,n2)` → 1 (forced) | inferred | body + `Missions/P1FP_Traitor.lua:1036` |
| `SetPanicOnceMode` | `Actor.SetPanicOnceMode` | `0x00712ea0` | — | `Actor.SetPanicOnceMode(h1,b2)` → 1 (forced) | inferred | body + `Missions/Act_1_BarFight.lua:1089` |
| `SetPanicWalkAwayEnabled` | `Actor.SetPanicWalkAwayEnabled` | `0x00713fd0` | — | `Actor.SetPanicWalkAwayEnabled(h1,b2)` → 1 (forced) | inferred | body + `Missions/P1FP_NaziParty.lua:196` |
| `SetPersistent` | `Actor.SetPersistent` | `0x00712880` | — | `Actor.SetPersistent(h1,b2)` → 1 (forced) | inferred | body only — **DEAD (0 script refs)** |
| `SetPlayerPlantedTrapCallback` | `Actor.SetPlayerPlantedTrapCallback` | `0x0070f220` | — | `Actor.SetPlayerPlantedTrapCallback(s1,nil2)` → 1 (forced) | inferred | body only — **DEAD (0 script refs)** |
| `SetPredefinedModule` | `Actor.SetPredefinedModule` | `0x00716880` | — | `Actor.SetPredefinedModule()` → 1 (forced) | **confirmed** | hand-disasm (absent from decomp) — **DEAD (0 script refs)** |
| `SetReactorEnabled` | `Actor.SetReactorEnabled` | `0x00714f30` | — | `Actor.SetReactorEnabled(h1,b2)` → 1 (forced) | inferred | body + `Modules/Behavior/AttractionPts/AttractionPt_SuspKiss.lua:16` |
| `SetRunsFromFire` | `Actor.SetRunsFromFire` | `0x00714320` | — | `Actor.SetRunsFromFire(h1,b2)` → 1 (forced) | inferred | body + `Missions/Act_1_Farm.lua:1018` |
| `SetSlowCollision` | `Actor.SetSlowCollision` | `0x00714530` | — | `Actor.SetSlowCollision(h1,b2)` → 1 (forced) | inferred | body + `Missions/SOE_2_Mission_2.lua:1863` |
| `SetStuckBashEnabled` | `Actor.SetStuckBashEnabled` | `0x00714e90` | — | `Actor.SetStuckBashEnabled(h1,b2)` → 1 (forced) | inferred | body + `Missions/P1FP_NaziParty.lua:549` |
| `SetTalkable` | `Actor.SetTalkable` | `0x00713470` | — | `Actor.SetTalkable(h1,b2,s3,s4,b5)` → 1 (forced) | inferred | body + `Missions/Paris_1_Mission_1B.lua:1446` |
| `SetUseHitReactions` | `Actor.SetUseHitReactions` | `0x00714480` | — | `Actor.SetUseHitReactions(h1,b2)` → 1 (forced) | inferred | body + `Missions/Act_1_Farm.lua:540` |
| `SetVehicleAvoidance` | `Actor.SetVehicleAvoidance` | `0x00713b20` | — | `Actor.SetVehicleAvoidance(h1,b2)` → 1 (forced) | inferred | body + `Experimental/Checkpoint.lua:75` |
| `SetupShop` | `Actor.SetupShop` | `0x00713110` | — | `Actor.SetupShop(h1,[s2],[s3],[s4],[s5],[s6],[s7])` → 1 (forced) *(arg overload: arg2:{nil\|string} arg3:{nil\|string} arg4:{nil\|string} arg5:{nil\|string} arg6:{nil\|string} arg7:{nil\|string})* | inferred | body + `Managers/ShopManager.lua:225` |
| `SurgeonGeneral` | `Actor.SurgeonGeneral` | `0x0070c7d0` | — | `Actor.SurgeonGeneral(b1)` → 1 (forced) | inferred | body + `Modules/InteriorLevels/Belle_Interior.lua:189` |
| `TurnOnDude` | `Actor.TurnOnDude` | `0x00712780` | — | `Actor.TurnOnDude(h1,b2)` → 1 (forced) | inferred | body + `Missions/Act_1_Factory.lua:33` |
| `UnboardVehicle` | `Actor.UnboardVehicle` | `0x00711be0` | — | `Actor.UnboardVehicle(h1,b2)` → 1 (forced) | inferred | body + `Includes/WRAPPER_Actor.lua:224` |
| `UseAttrPt` | `Actor.UseAttrPt` | `0x007111f0` | — | `Actor.UseAttrPt(h1,h2,s3,t5,b6)` → 1 (forced) | inferred | body + `Experimental/Checkpoint_v2.lua:43` |
| `UseSubAttrPt` | `Actor.UseSubAttrPt` | `0x00711470` | — | `Actor.UseSubAttrPt(h1,h2)` → 1 (forced) | inferred | body only — **DEAD (0 script refs)** |
| `WalkToDespawnLocation` | `Actor.WalkToDespawnLocation` | `0x00714d30` | — | `Actor.WalkToDespawnLocation(h1,b2)` → 1 (forced) | inferred | body + `Missions/P1FP_Jailbreak.lua:830` |

### Boundary annex (family subject, outside the `Actor` table)

Claimed by rule (B); **not** counted in the coverage figures above. Signatures derived by the same
method; all `inferred`. `used=` is the reference count in retail `LuaScripts.luap`. Six of these twenty
have **no body in the decomp** and were read from the exe like the core family's twelve — the four
`Util.Clear*` (`inlined`, `impl==thunk`) and the two `Cin` rows (`shape=jmp`, landing in decompiler gaps);
they are flagged in the Note column.

| Binding | VA | Signature | used | Note |
|---|---|---|---:|---|
| `Object.IsAlive` | `0x00737df0` | `(h1)` → 0 or 1 | 154 | **distinct binding** from `Actor.IsAlive` |
| `Object.Kill` | `0x00737e90` | `(h1)` → 1 (forced) | 189 | the workhorse death call |
| `Object.GetHealth` | `0x0073b250` | `(h1)` → 0 or 1 | 52 | |
| `Object.SetHealth` | `0x00738020` | `(h1,n2)` → 1 (forced) | 51 | |
| `Object.IsDead` | `0x00737d50` | `(h1)` → 0 or 1 | 20 | not the negation of `IsAlive` — see open questions |
| `Object.GetMaxHealth` | `0x00737f70` | `(h1)` → 0 or 1 | 9 | |
| `Object.IsHuman` | `0x0073c670` | `(h1)` → 0 or 1 | 4 | the `WSHuman` type test |
| `Cin.IsHumanInConversation` | `0x0071cb20` | `(h1)` → 0 or 1 | 20 | `shape=jmp`, **no decomp body** — hand-read |
| `Cin.AllowHumanDamage` | `0x0071ce60` | `(b1)` → 1 (forced) | 2 | global |
| `Cin.GetHumanConversationID` | `0x0071cc00` | `(h1)` → 0 or 1 | 0 | `shape=jmp`, **no decomp body** — hand-read; dead |
| `Combat.SetRespondToDeadBodies` | `0x00721ea0` | `(h1,b2)` → 1 (forced) | 10 | |
| `Render.EnableHumanHalos` | `0x0073d4a0` | `(b1)` → 1 (forced) | 3 | global |
| `Util.SetDisguiseCallback` | `0x00758080` | `(s1,t2,t3)` → 1 (forced) | 2 | name, self, user-table |
| `Util.SetDisguiseStartedCallback` | `0x007581d0` | `(s1,t2,t3)` → 1 (forced) | 2 | |
| `Util.SetLostDisguiseCallback` | `0x00758320` | `(s1,t2,t3)` → 1 (forced) | 1 | |
| `Util.SetDisguiseCompleteCallback` | `0x00753510` | `(s1,t2,t3)` → 1 (forced) | 1 | |
| `Util.ClearDisguiseCallback` | `0x0075d1f0` | `()` → 1 (forced) | 2 | `inlined` |
| `Util.ClearDisguiseStartedCallback` | `0x0075d260` | `()` → 1 (forced) | 2 | `inlined` |
| `Util.ClearLostDisguiseCallback` | `0x0075d2d0` | `()` → 1 (forced) | 2 | `inlined` |
| `Util.ClearDisguiseCompleteCallback` | `0x0075ab60` | `()` → 1 (forced) | 0 | `inlined`, dead |

The four `Util.Set*DisguiseCallback` bindings take **no actor handle** — disguise notification is a
*global* event stream, not a per-actor subscription. Their shape `(sCallbackName, tSelf, tUserTable)`
matches the family-wide callback convention exactly.

## How the subsystem actually works

### Disguise is name-or-handle polymorphic — and that is the family's tell

Four of the disguise bindings type-switch on argument 1:

| Binding | VA | arg 1 accepts |
|---|---|---|
| `Actor.SetDisguise` | `0x00712920` | `handle \| string` |
| `Actor.RemoveDisguise` | `0x00712a70` | `handle \| string` |
| `Actor.HasUseableDisguise` | `0x00712b60` | `handle \| string` |
| `Actor.SetNeverBloodyDisguise` | `0x00712cb0` | `handle \| string` |

`Actor.SetDisguise` (`0x00712920`) is the clearest specimen:

```c
if (!IS_HANDLE(1)) {
    if (!IS_STR(1)) return;                      // neither -> silent no-op
    id = *(u32*)FUN_00db7e10(to_string(1), 1);   // name -> 32-bit id
} else {
    id = to_handle(1);                           // handle -> the same 32-bit id
}
if (IS_STR(2)) {                                 // arg 2 (disguise name) is MANDATORY
    if (IS_BOOL(3)) flag = to_bool(3);           // arg 3 optional, defaults 0
    EnterCriticalSection(DAT_0143db28);
    e = FUN_004436f0(&id);                       // SAME map for both branches
    ...
    FUN_00503c70(FUN_00db7e10(to_string(2),1), flag, 0);
}
```

Both branches converge on the **same** `FUN_004436f0` lookup. That is only possible because a name
and a handle live in one 32-bit id space.

### `FUN_00db7e10` is not "copy the string out" — it is `Symbol(name)`

The ABI note describes `FUN_00db7e10` as copying a string out of Lua's ownership before GC can move
it (§8). That undersells it. It is a **4-byte-struct constructor** whose `this` is the hidden return
buffer:

```c
undefined4 * __thiscall FUN_00db7e10(undefined4 *ret, int str, undefined4 mode)
{ *ret = (str != 0) ? FUN_00db7c10(str, mode) : 0; return ret; }
```

and `FUN_00db7c10(str, bRegister)` is:

```c
uVar1 = FUN_00dc1e20(param_1);          // hash the string
if (param_2 != '\0') {                  // mode=1: also record it
    if ((_DAT_014e1cf8 & 1) == 0) { ... FUN_00db7ad0(); _atexit(...); }  // one-time table init
    FUN_00db7920(uVar1, param_1, 0);    // register hash -> string (reverse lookup)
}
return uVar1;                           // the 32-bit symbol
```

So the recurring `to_string(k)` → `FUN_00db7e10(...)` pairing **interns a name into a 32-bit symbol**,
and `mode=1` additionally files the string in a reverse table (a debug-name registry). The copy-out
effect is real but incidental; the *value* is the point. `Util.GetHandleByName` (`0x00758b30`) confirms
the direction of travel: it hashes its argument the same way, then tries a cascade of symbol-keyed
lookups — and on **two** of its exit paths (the `FUN_00430350` branch, and the `FUN_00498440 != 0`
fall-through at the end of the body) it pushes **the symbol itself** back to Lua as the handle.

This means the claim in [03-handle-and-object-model.md](03-handle-and-object-model.md) §7 that a handle
"is **not** a name hash" is **too strong for this family**: for named world objects the handle a script
holds can be exactly the name's symbol. That section rests on the observation that `FUN_00dc1e20` (the
confirmed `pandemic_hash`) "has only ten callers and none of them is in the `0x0070f000`–`0x0076xxxx`
binding block or touches `DAT_0143db28`" — which is literally true of its *direct* callers (verified: ten,
none in the block), but one of those ten is `FUN_00db7c10 @0x00db7c10`, and that is exactly what
`FUN_00db7e10` calls on behalf of `Actor.SetDisguise @0x00712920` — a binding inside the block that *does*
take `DAT_0143db28`. The name→handle path reaches `pandemic_hash` one level of indirection deeper than
that census looked. It is
plausible that dynamically spawned objects use the salted `slot|generation` form while level-authored
named objects use the name symbol, and that the map accommodates both — but I did not prove that, so
the reconciliation is **open** (see below). What *is* proven byte-level is that one `FUN_004436f0`
call resolves both forms in `Actor.SetDisguise`.

Practically, this is why mission scripts can hand the disguise calls a raw name and skip
`Util.GetHandleByName` — and why the family tolerates handles not surviving save/load.

### Fall damage: a fully script-owned tuning block that no script ever touches

Eight bindings — four setters and four resetters — form the cleanest closed structure in the family.
The four `Reset*` are `inlined` thunks Ghidra never emitted; disassembled, each is two instructions:

```asm
ResetFallDamageDeath    @0x007157c0:  fld [0x011174a8] ; mov eax,1 ; fstp [0x01117498] ; ret
ResetFallDamageMult     @0x00715810:  fld [0x011174a0] ; mov eax,1 ; fstp [0x01117490] ; ret
ResetFallDamageRagdoll  @0x00715770:  fld [0x011174a4] ; mov eax,1 ; fstp [0x01117494] ; ret
ResetFallDamageMinSpeed @0x00715860:  fld [0x0111749c] ; mov eax,1 ; fstp [0x0111748c] ; ret
```

Each copies a **defaults** slot onto a **live** slot. The four `Set*` bindings write exactly those
live slots, which pins the pairing byte-level with no inference:

| Tunable | `Actor.SetFallDamage*` | writes live | `Actor.ResetFallDamage*` | restores from |
|---|---|---|---|---|
| MinSpeed | `0x0070c5e0` | `0x0111748c` | `0x00715860` | `0x0111749c` |
| Mult | `0x0070c640` | `0x01117490` | `0x00715810` | `0x011174a0` |
| Ragdoll | `0x0070c520` | `0x01117494` | `0x00715770` | `0x011174a4` |
| Death | `0x0070c580` | `0x01117498` | `0x007157c0` | `0x011174a8` |

Two parallel `float[4]` tables exactly `0x10` apart. All four setters take a **bare number and no
handle** — fall damage is **global tuning, not per-actor state**.

The tunables have **four** readers in the decomp, not one. The principal consumer is `FUN_005897e0`, whose
own body carries the assertion string `…\WildStar\Objects\WSHumanPhysics.cpp` / `"WSHumanPhysics::TakeFallDamage"`
/ line `0xf26` = 3878 — so the name is **confirmed here byte-level**, not merely inherited from
[human-disguise.md](../symbol_map/human-disguise.md), which names it independently. The others are
`FUN_00589bc0` — likewise self-named, **`WSHumanPhysics::TakeImpactDamage`**, which reads Mult/Ragdoll/Death
in the same shape (so this block tunes *impact* damage too, not only falls) — plus `FUN_0058a480` (reads
MinSpeed/Mult) and `FUN_00588f60` (reads Death), neither of which carries a name. `TakeFallDamage` reads
them as:

```c
if (v < -MinSpeed) {                                   // speed gate
    damage = Mult * (fabs(v) - MinSpeed);              // linear above the gate
    if (health_query() < damage && damage < Death)     // sub-threshold hits cannot kill:
        damage = health_query() - epsilon;             //   clamp to just-survivable
    if (state != 3 && damage > Ragdoll) {              // <-- the damage dispatch lives INSIDE
        ...ragdoll...; DispatchCollisionDamage(...);   //     this test; below Ragdoll, nothing
    }                                                  //     happens at all
}
```

So `Death` is not "damage that kills" — it is the threshold **below which a fall is forbidden from
killing**, with damage clamped to leave the actor barely alive. *(inferred from the arithmetic;
`param_2[7]` as impact velocity is inferred from context, not proven.)*

The striking part is the census. In the whole 54 MB decomp, the **only** writers of the four live
globals are the four `Actor.SetFallDamage*` bindings — nothing else. The four defaults slots
(`0x0111749c`–`0x011174a8`) have **zero** references in the decomp, precisely because their only
readers are the four thunks Ghidra failed to emit. On disk all eight floats are **`-99.0`**. And no
shipped script — neither in the 321-file corpus nor anywhere in retail `LuaScripts.luap` — ever calls
any of the eight.

Therefore the entire fall-damage override system is **inert in the retail game**: the live values are
`-99` at load and nothing ever changes them. The mechanism is worth stating precisely, because it is not
the gate that saves you. With `MinSpeed = -99` the gate is `v < 99`, which any fall passes, so the
arithmetic **does** run; it is the *result* that is inert. `damage = -99 * (fabs(v) + 99)` is large and
negative, so `damage > Ragdoll (-99)` is false and the whole ragdoll block — which is where the
`DispatchCollisionDamage` call lives — is skipped. The kill-clamp is likewise never taken, since it needs
`health < damage` and damage is negative. No fall ever damages or ragdolls. Whether `-99` means "disabled" or
"uninitialised, expected to be filled by a tuning pass that was cut" is **open**.

### Four bindings are registered no-ops

Disassembly of the `inlined` module bindings shows they have no body at all:

```asm
Actor.SetPredefinedModule @0x00716880:  mov eax,1 ; ret
Actor.GetPredefinedModule @0x00716890:  xor eax,eax ; ret
Actor.GetModuleInputs     @0x00716920:  xor eax,eax ; ret
Actor.SetModuleInputs     @0x00716930:  mov eax,1 ; ret
```

They never touch the `lua_State`. The `Set*` pair claims 1 result and does nothing; the `Get*` pair
returns **0 results**, so `local m = Actor.GetPredefinedModule(h)` yields `nil` — not because lookup
failed but because the function is empty. All four are also unreferenced by any script. They are
stubs left in the registration table. *(confirmed, byte-level.)*

`Actor.PlayerBlockSabLighting` (`0x00716330`) is nearly as thin and more interesting:

```asm
mov eax, [0x1240328]          ; the player singleton
or  byte [eax+0x16e8], 0x80   ; set bit 7 — one-way
mov eax, 1 ; ret
```

It takes no arguments and **only ever sets** the bit; no binding in the family clears it. Whatever it
blocks stays blocked for the session. It too is dead in retail. `Actor.ExitSpecialKillMode`
(`0x007163c0`, C++ `PlayerKillModeCancel`) reads the same `0x01240328` singleton and calls
`0x005ab710` on it — pinning `0x01240328` as a **global player object** used directly, bypassing the
handle map entirely.

### The optional callback trailer, and a decoding trap

Several bindings accept a trailing `(sCallbackName, tSelf, tUserTable)` group at a **sliding base
index**. `Actor.RequestAttrPt` (`0x00710fa0`) is the model:

```c
iVar3 = 3;
if (IS_BOOL(3)) { to_bool(3); iVar3 = 4; }        // optional bool shifts everything
if (IS_STR(iVar3)) {                              // callback NAME (never a function)
    FUN_0070a180(to_string(iVar3));               // split & bind
    if (IS_TABLE(iVar3+1)) FUN_0070a4b0(iVar3+1);            // self
    if (IS_TABLE(iVar3+2)) thunk_FUN_00481ae6(iVar3+2);      // user table
}
```

⇒ `Actor.RequestAttrPt(hActor, hAttrPt, [bFlag], [sCallback, [tSelf], [tUserTable]])`.

`FUN_0070a180` is the callback-name binder, and it calls `FUN_00db4de0(0x2e, 1)` — **`0x2e` is `'.'`** —
independently confirming the ABI note's claim that callback names are dotted and split into
table+field. This is the family-wide convention: **no binding here ever takes a Lua function.**

**A second trap, in the same place:** where the trailer base index is *literal* rather than register-computed,
the trailer slots are **overloaded**, and a flat signature hides it. `Actor.PlayAnimationToPoint`
(`0x0070fe00`) is the specimen: bounded disassembly shows slot 9 read both as `to_str(9)` (the callback
name, at `0x0071000d`) **and** as `IS_BOOL(9)`/`to_bool(9)` (at `0x0071006f`/`0x0071007c`), and slot 10
read both as the callback's self-table (`FUN_0070a4b0`, `push 0xa` at `0x00710049`) **and** as
`IS_STR(10)`/`to_str(10)` (at `0x00710090`/`0x0071009f`). These are not contradictory readings: the
callback group is guarded by `to_str(9)` returning a non-empty string, and `lua_tostring` on a boolean
yields `NULL`, so slot 9 is `{sCallback | bool}` and slot 10 is `{tSelf | string}` — two mutually
exclusive tail forms. The flat signatures in the table pick one reading each and should be read as **one
valid form, not the whole contract**; the same caveat applies to `PlayAnimation` and `PlayAnimationToBone`.
Every index those rows claim is genuinely fetched by the body — none is fabricated — but the *types* at
the trailer slots are form-dependent.

The first trap: because `iVar3+1`/`iVar3+2` are computed in registers, a disassembly scan looking for
`push <imm>` **cannot see these arguments at all**, and the decomp text shows literal indices only
where Ghidra constant-folded. The two methods fail in opposite directions — disassembly wins when
Ghidra drops a parameter list (`Actor.Immolate`, the three `PlayAnimation*`), decomp wins on
sliding-index variadics (`RequestAttrPt`, `SetPlayerPlantedTrapCallback`). Signatures with an index
gap (`ForceLongIdle` showing `a1,a2,a3,a5`) are this pattern, not a missing argument. Where both
methods produced a signature, they agree on **92 of 99**; all 7 disagreements are one method being
strictly richer, none are contradictions.

### `Actor.Ragdoll` and the two liveness gates

The worked example holds up exactly. `Actor.Ragdoll(hActor)` (`0x00714230`, `Script\Interface\Actor.cpp:3285`)
takes one handle, runs the double gate of [03-handle-and-object-model.md](03-handle-and-object-model.md)
§4 — map lookup under `DAT_0143db28`, then vtable `+0x1c`, then
the weak-ref re-check `FUN_0083a200` — and calls `FUN_0099bc00`, which
[damage-physics.md](../symbol_map/damage-physics.md) names **`WSHumanPhysics::DispatchCollisionDamage`**
and specifies as `(desc, target, 0, dmg)` — here with `dmg = 0x3f800000` = `1.0f`. So scripted ragdolling
is implemented as *building and dispatching a `WSDamageEvent` carrying 1.0 damage* — not a physics impulse
— which is why it routes through the damage system rather than the physics API. (That sibling doc's own
review notes already record `FUN_00714230` as one of this helper's non-physics callers, at
`0x0071430b`, and caution that the "collision" in the name is narrower than the helper's actual use.)

`Actor.IsRagdollInWater` (`0x0070c300`, recovered by hand) shows the read side, and a different map:

```asm
call 0x6f71a0        ; IS_HANDLE(1) — absent/wrong type -> 0 results (not false!)
call 0x6f6ec0        ; to_handle(1)
call 0x67c0a0        ; the SECOND map (DAT_01321e38), not FUN_004436f0
call [eax+0x174]     ; -> subobject; null -> push false
call 0x4f37c0        ; -> ragdoll; null -> push false
test byte [eax+0x78], 0x80   ; bit 7 = the in-water flag
call 0x6f7020        ; lua_pushboolean
```

Note the asymmetry, which matters to callers: a **bad handle returns 0 results** (`nil`), while a
**good handle on a dry/absent ragdoll returns `false`**. `if Actor.IsRagdollInWater(h) == false` and
`if not Actor.IsRagdollInWater(h)` are therefore not equivalent. `Actor.IsDisguised` (`0x0070c6a0`)
has the same shape but skips the `IS_HANDLE` pre-check entirely, relying on `to_handle`'s internal
type re-check to return 0 — so it cannot distinguish "not a handle" from "lookup miss"; both give
0 results.

### What the dead surface says about development

34 of 111 `Actor` bindings (31%) are referenced by no shipped script. The evidence is unusually firm:
the 321-file decompiled corpus and the 5 MB retail `LuaScripts.luap` — **fully independent sources** —
identify the *same* 77 used names and the *same* 34 unused ones, with zero disagreement in either
direction. That agreement also validates the decompiled corpus as complete with respect to `Actor` usage.

The dead set clusters, and the clusters are legible as cut features:

- **All 8 fall-damage bindings** — a tuning API wired end-to-end and never used.
- **The whole ragdoll-callback pair** (`RegisterRagdollCallback` `0x0070efd0`, `ClearRagdollCallback`
  `0x0070c490`) — scripts can ragdoll an actor but never subscribe to the result.
- **The 4 module stubs**, which have no bodies at all.
- **The AI-state read API**: `IsInHunt`, `IsInIdle`, `IsInInvestigate`, `IsSlacker`, `AreNeedsEnabled`
  are all dead, while their *write* counterparts (`SetPanicEnabled` 45 uses, `EnableNeeds` 46) are
  heavily used. Scripts drive the AI and never interrogate it.
- **`Actor.PlayAnimationToPoint`** is dead *and* carries an assertion string — a fully-built,
  fully-instrumented entry point (`Actor.cpp:475`) with an 11-argument signature that shipped unused.

Note the `Actor.cpp` line numbers on the four assertion-bearing bindings — 475
(`PlayAnimationToPoint`), 1371 (`BoardVehicle`), 1717 (`BroadcastScaryEvent`), 3285 (`ActorRagdoll`) —
give four fixed points in a source file of at least ~3.3k lines.

### A shipped bug in the wrapper layer

`Includes/WRAPPER_Actor.lua` is the namespaced façade over the flat C API. `ACTOR_FaceObject` resolves
the *wrong* variable:

```lua
function ACTOR_FaceObject(a_vCharacter, a_vTarget)
  local hCharacter = WRAPPER_CheckForHandle(a_vCharacter)
  local hTarget = WRAPPER_CheckForHandle(a_vCharacter)   -- <-- a_vCharacter, should be a_vTarget
  ...
  Actor.SetFacingDir(hCharacter, hTarget)
end
```

([`WRAPPER_Actor.lua:31`](../saboteur-luacd/src/Includes/WRAPPER_Actor.lua), the bug is at line 33.)
`a_vTarget` is never read, so the call always makes the character face **itself**. The engine side is
blameless and the failure is silent — `Actor.SetFacingDir` is overloaded on arg 2 (`IS_NUM(2)` → face
an angle, else `IS_HANDLE(2)` → face an object; `0x00710400`), so a valid self-handle takes the
handle path and no-ops geometrically rather than erroring. The sibling `ACTOR_FaceDirection` exercises
the number form and is correct. This is exactly the class of defect the family's silent-failure
contract hides: no `lua_error`, no assert, no log.

## Open questions

1. **The handle/symbol reconciliation.** `Actor.SetDisguise` proves one `FUN_004436f0` call resolves
   both a name symbol and a handle, and `Util.GetHandleByName` can return the symbol itself as a
   handle. But [03-handle-and-object-model.md](03-handle-and-object-model.md) documents handles as
   salted `slot|generation`. Are these two id producers sharing one keyspace (and if so what prevents
   a hash/slot collision), or is the salted form used only for spawned objects? Not resolved here.
2. **Why two handle maps?** This family uses `FUN_004436f0`/`DAT_0143db28` (`Ragdoll`, `SetDisguise`,
   `RequestAttrPt`) *and* `FUN_0067c0a0`/`DAT_01321e38` (`IsDisguised`, `IsRagdollInWater`,
   `SetFacingDir`'s target branch) with no obvious rule. Some bindings use both in one body
   (`RequestAttrPt`: `FUN_004436f0` for the actor, `FUN_0067c0a0` for the attraction point). The
   split may be actor-vs-object, but that is a guess.
3. **The `-99` sentinel.** Disabled-by-design, or an uninitialised tuning table whose loader was cut?
   Nothing in the decomp writes the defaults. Note that `-99` does **not** disable the system cleanly at
   the gate — `MinSpeed = -99` makes the speed gate pass on every fall, and the system is inert only
   because the resulting damage is absurdly negative downstream. A value chosen to mean "disabled" would
   more naturally be a large *positive* MinSpeed. That argues for "never finished" — but it is not proof.
4. **`vtable+0x1e8` vs `vtable+0x1c`.** The disguise/predicate bindings reach their subobject through
   an adjustor sequence (`mov ecx,[eax+8]; mov edx,[ecx+8]; lea ecx,[edx+eax+8]; call [eax+0x1e8]`)
   that differs from the `+0x1c` idiom the ABI note documents. This looks like multiple-inheritance
   base adjustment, but neither slot is identified. `+0x174` (`IsRagdollInWater`) and `+0x950`
   (`Immolate`) are likewise unnamed.
5. **`Actor.SurgeonGeneral(bool)`** (`0x0070c7d0`) — a global boolean, called with `false` from
   interior-level modules (`Modules/InteriorLevels/Belle_Interior.lua:189`). The name suggests a gore
   toggle and the call sites suggest "suppress corpses indoors", but the body was not traced to a
   consumer. Claimed on the health-state reading; the reading is unverified.
6. **`Actor.Immolate` names its effects.** The body builds a string via
   `sprintf(buf, "Actor.Immolate%d", InterlockedIncrement(&DAT_0142d780))`, so every immolation
   registers a uniquely-named, globally-counted effect instance. Why a *name* (and a process-wide
   atomic counter) is needed for a fire effect is unexplained — possibly so the effect can be found
   and cancelled later, but no binding in this family looks one up.
7. **`Object.IsDead` is not `not Object.IsAlive`.** They are separate bindings at `0x00737d50` and
   `0x00737df0` and both are used (20 / 154). Whether a third state exists (dying, ragdolling,
   destroyed-but-present) is unresolved; the existence of a `WSHumanStateDying` class
   ([`data/rtti_classes_all.txt:2400`](../../data/rtti_classes_all.txt),
   [`data/ws_engine_classes.txt:459`](../../data/ws_engine_classes.txt)) suggests it does. Neither
   binding's body was traced against that class here, so this remains a name-level hint only.
8. **Sliding-index arities are lower bounds.** For bindings using the callback trailer, the maximum
   arity depends on register-computed indices. I report the observed structure, but a binding could
   accept a further optional argument no static read reveals.
