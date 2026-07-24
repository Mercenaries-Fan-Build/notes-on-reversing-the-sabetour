# Family 12 — Suspicion, Escalation & Will-to-Fight

> **Verified:** all 56 VAs re-checked against the decomp (43 bodies exist, the 13 "open" rows are
> genuinely absent — exactly as claimed) and against `data/lua_registration_map.tsv`; every quoted C
> body, offset, bit and corpus `file:line` re-read and found accurate. Corrected: the corpus **call**
> counts (several were mention-counts inflated by function-reference sites), the renamed-row count
> (eight, not seven), the never-called set (**18**, not nine — and it is not WTF-only), and open
> question 4, which is refuted by a real two-arg `EnableEscalation` call site.

The engine↔Lua seam for The Saboteur's signature "getting caught" system. Engine-internal
machinery is already pinned in [`docs/symbol_map/suspicion-wtf.md`](../symbol_map/suspicion-wtf.md);
this document covers **only the binding layer** — what Lua can call, with what arguments, and what
comes back. Read [`02-marshalling-abi.md`](02-marshalling-abi.md) first; every derivation below
applies that decoder ring.

## Inclusion rule (auditable)

A binding is in this family if **any** of:

1. It is registered into the **`Suspicion` table** — the whole table, all 34 rows, no exceptions.
   Several members (`SetNoTail`, `EnableHidePts`, `EnableEspritDeCorps`, `IsSomeoneHostile*`,
   `*SpecialCaseFillMultiplier`) do not match a `Suspicion|WTF|Escalat` keyword grep but are claimed
   anyway: table membership is the stronger signal than the name.
2. Its C++ symbol contains `WTF` (16 rows, all in the **`Render`** table plus one in `Actor`).
3. It is an escalation/suspicion straggler in another table: `Trigger.CreateSuspicionZone`,
   `Util.MakeEscalationCallback`, `Util.SetNumWTFZones`, `Util.RecordWTFZoneFlipped`,
   `Vehicle.SetCanJoinEscalation`.

**Total: 56 bindings.** Boundary calls, stated so they are auditable:

- **`Render.HeatShimmerFilter`** (`0x0073d2d0`) is **excluded**. It matches a `Heat` keyword grep of
  `lua_bindings.txt` (line 305) but "heat" here is the optical heat-haze post-filter, not escalation
  heat. It is a `render-fx-light` binding.
- **`Actor.GlobalEnableHighWTFCivMelee`** is **claimed** though it lives in `Actor`; it gates civilian
  melee on high-WTF districts and is meaningless outside this subsystem.
- **`Render.WTF*`** are **claimed** despite the `Render` table (see "WTF is two systems" below).

### The naming trap this family sets

Eight of the 34 `Suspicion` rows are renamed by the registration table, and the prefix is *not*
mechanically strippable — exactly the hazard §0 of the ABI sheet warns about:

| C++ symbol (`lua_bindings.txt`) | Actual callable name |
|---|---|
| `EnableSuspicion` | `Suspicion.Enable` |
| `EnableSuspicionGlobal` | `Suspicion.EnableGlobal` |
| `IsSuspicionEnabled` | `Suspicion.IsEnabled` |
| `ResetSuspicion` | `Suspicion.Reset` |
| `ResetSuspicionMeter` | `Suspicion.ResetMeter` |
| `SuspicionIsEscalated` | `Suspicion.IsEscalated` |
| `SuspicionSetEscalated` | `Suspicion.SetEscalated` |
| `SuspicionSetEscalatedWithWhistle` | `Suspicion.SetEscalatedWithWhistle` |

But `SetupSuspicionRadius` and `KillSuspicionRadius` keep their `Suspicion` infix and register as
`Suspicion.SetupSuspicionRadius` / `Suspicion.KillSuspicionRadius` — stuttering, and confirmed by
call sites ([`Act_1_Mission_2B.lua:273`](../saboteur-luacd/src/Missions/Act_1_Mission_2B.lua)).
Names below come from `data/lua_registration_map.tsv`, never from inference.

## Coverage honesty

**56 of 56 bindings located** in the registration map (byte-level from the exe: table, name, family,
shape). But *located* and *readable* are different things:

- **0 confirmed by assertion string.** There is **no `Script\Interface\Suspicion.cpp`** — the 11
  `Script\*.cpp` paths in the 54 MB decomp do not include one, and not one of the 56 C++ symbols
  appears as a quoted string literal anywhere in the decomp. The assertion-string method that pins
  `Actor.Ragdoll` yields **nothing** here. This family's identity rests entirely on the registration
  map.
- **43 of 56 have a readable body** in the decomp → signature derived from primitives.
- **13 of 56 have no Ghidra function at all** → signature **open**, arity from corpus only.

Of the 13 unreadable: **12 are `shape=inlined`** (`impl_va == thunk_va`; the body was folded into the
registered thunk and Ghidra recovered no function). The 13th is the odd one out — **`Suspicion.IsSomeoneHostile`
(`0x00747510`)** is `shape=jmp` and *should* have a body: `FUN_007474b0` (size=96) ends exactly at
`0x00747510` and the next recovered function starts at `0x00747580`, leaving a genuine **112-byte hole
Ghidra never disassembled**. The function is real and registered; the decomp simply lacks it.

Confidence tiers used below: **confirmed** = body read, primitives unambiguous, and/or corpus call
site agrees. **inferred** = callee/offset reasoning. **open** = no body.

## The bindings

| Binding | Namespaced form | VA | Source | Signature | Confidence | Evidence |
|---|---|---|---|---|---|---|
| `GetEscalation` | `Suspicion.GetEscalation` | `0x007471c0` | — | `() -> number` (0..5; **0 if escalated-lite**) | confirmed | Body: pushes `+0x1154`, or `0` if `+0x1253 & 0x10`. 79 corpus calls |
| `SetEscalationLevel` | `Suspicion.SetEscalationLevel` | `0x00747760` | — | `(nLevel:number) -> ()` — **rejects ≥6** | confirmed | `FUN_006f7990(1)` then `uVar3 < 6` unsigned. [`Act_1_GetCaught.lua:649`](../saboteur-luacd/src/Missions/Act_1_GetCaught.lua) |
| `SetFixedEscalationLevel` | `Suspicion.SetFixedEscalationLevel` | `0x00747810` | — | `(nLevel:number) -> ()` | confirmed | `thunk_FUN_004c923d(n, 0)` — same callee as above with flag `0` |
| `SetEscalationCap` | `Suspicion.SetEscalationCap` | `0x00747880` | — | `(nMax:number) -> ()` | confirmed | `FUN_0089e930(int)`. [`RewardsManager.lua:5240`](../saboteur-luacd/src/Managers/RewardsManager.lua) |
| `IsEscalated` | `Suspicion.IsEscalated` | `0x007472d0` | — | `() -> boolean` (`level>0 AND NOT lite`) | confirmed | Body reads `+0x1154` and `+0x1253&0x10` |
| `IsEscalatedLite` | `Suspicion.IsEscalatedLite` | `0x00747350` | — | `() -> boolean` (bit `+0x1253 & 0x10`) | confirmed | `>> 4 & 1`. [`CoDSpawner.lua:94`](../saboteur-luacd/src/ScriptControllers/CoDSpawner.lua) |
| `EnableEscalation` | `Suspicion.EnableEscalation` | `0x00746fc0` | — | `(bEnable:boolean [, bArg2:boolean=false]) -> ()` — **variadic** | confirmed | `FUN_006f6970()`; `if (1 < argc)` → `FUN_0089e990(a,b)`. 37 corpus calls: 28 `(true)`, 8 `(false)`, **1 `(false, true)`** ([`Act_3_Mission_2.lua:1572`](../saboteur-luacd/src/Missions/Act_3_Mission_2.lua)) |
| `EnableEscalationVehicles` | `Suspicion.EnableEscalationVehicles` | `0x00747070` | — | `(bEnable:boolean) -> ()` → bit `+0x1252 & 0x10` | confirmed | Body bitfield write |
| `OverrideEnableEscalationVehicles` | `Suspicion.OverrideEnableEscalationVehicles` | `0x007470e0` | — | `(bEnable:boolean) -> ()` → bit `+0x1252 & 0x80` | confirmed | `& 0x7f \| cVar1 << 7` |
| `EnableReEscalation` | `Suspicion.EnableReEscalation` | `0x00747150` | — | `(bEnable:boolean) -> ()` → bit `+0x1252 & 0x20` | confirmed | Body bitfield write |
| `EnableResistanceEscalation` | `Suspicion.EnableResistanceEscalation` | `0x00747650` | — | `(bEnable:boolean) -> ()` → bit `+0x1253 & 0x80` | confirmed | Body bitfield write |
| `SetEscalationLiteInfinitely` | `Suspicion.SetEscalationLiteInfinitely` | `0x00747970` | — | `(bEnable:boolean) -> ()` → bit `+0x1253 & 0x20` | confirmed | Body bitfield write |
| `SetInescapableEscalation` | `Suspicion.SetInescapableEscalation` | `0x00747a50` | — | `(bEnable:boolean) -> ()` → bit **`+0x1255` `& 0x10`** | confirmed | Body — note the *third* flag byte |
| `SuspicionSetEscalatedWithWhistle` | `Suspicion.SetEscalatedWithWhistle` | `0x00747230` | — | `([hActor:handle]) -> ()` | confirmed | Handle optional: falls through to `FUN_00898590(0,1)` on absent/stale |
| `SetWhistleEscalationEnabled` | `Suspicion.SetWhistleEscalationEnabled` | `0x00748b10` | — | `(hActor:handle, bEnable:boolean) -> ()` → bit `+0x227 & 0x04` on `+0x140` | confirmed | Body |
| `SetEscalationBPSet` | `Suspicion.SetEscalationBPSet` | `0x007478e0` | — | `(sBPSet:string) -> ()` — **rejects len ≥ 0x40** | confirmed | Inline `strlen` then `< 0x40` guard → `FUN_008adba0` |
| `Enable` | `Suspicion.Enable` | `0x00748860` | — | `(hActor:handle, bEnable:boolean) -> ()` → bit `+0x20 & 1` | confirmed | Both args mandatory (`&&`-chained) |
| `EnableGlobal` | `Suspicion.EnableGlobal` | `0x00746f60` | — | `(bEnable:boolean) -> ()` → global `DAT_011bb674` | confirmed | 42 corpus calls (+3 sites passing it as a bare function reference) |
| `IsEnabled` | `Suspicion.IsEnabled` | `0x00748930` | — | `([hActor:handle]) -> boolean\|nil` — **3 result shapes** | confirmed | See "IsEnabled" below |
| `IsActingSuspiciously` | `Suspicion.IsActingSuspiciously` | `0x00748760` | — | `(hActor:handle) -> boolean` (`state > 2`) | confirmed | `thunk_FUN_0043fbc6(2 < *(int *)(iVar2 + 0x1900))` |
| `IsSomeoneHostileOrHunting` | `Suspicion.IsSomeoneHostileOrHunting` | `0x00747580` | — | `() -> boolean` | confirmed | `FUN_008a6cb0(1,0,0)` → `FUN_008992c0(q,1,0,0)` |
| `IsSomeoneHostile` | `Suspicion.IsSomeoneHostile` | `0x00747510` | — | `() -> boolean` *(arity from corpus)* | **open** | **No body** — 112-byte hole Ghidra missed. Registered `jmp`. 4 corpus calls, all `()` |
| `Reset` | `Suspicion.Reset` | `0x00748660` | — | `(hActor:handle) -> ()` | confirmed | Full handle idiom → `FUN_008e8d40(0,0,0)` (census reset) |
| `SetupSuspicionRadius` | `Suspicion.SetupSuspicionRadius` | `0x007473b0` | — | `(hOrigin:handle, fRadius:number [, fDuration:number]) -> nID:number` | confirmed | Arg 3 defaults to `_DAT_00f7b148`. [`Act_1_Mission_2B.lua:273`](../saboteur-luacd/src/Missions/Act_1_Mission_2B.lua) |
| `KillSuspicionRadius` | `Suspicion.KillSuspicionRadius` | `0x007474b0` | — | `(nID:number) -> ()` | confirmed | `FUN_006f7990(1)` **int** → `FUN_0089bb30`. Consumes the ID above ([`P1FP_Jailbreak.lua:713`](../saboteur-luacd/src/Missions/P1FP_Jailbreak.lua)) |
| `SetNoTail` | `Suspicion.SetNoTail` | `0x00748a60` | — | `(hActor:handle, bNoTail:boolean) -> ()` → bit `+0x22a & 0x20` | confirmed | Body |
| `EnableHidePts` | `Suspicion.EnableHidePts` | `0x007475f0` | — | `(bEnable:boolean) -> ()` → global `DAT_01115108` | confirmed | Body |
| `EnableEspritDeCorps` | `Suspicion.EnableEspritDeCorps` | `0x007476c0` | — | `(bEnable:boolean [, bArg2:boolean=true]) -> ()` | confirmed | Arg 2 **defaults to 1**, not 0 → `FUN_008972f0`. [`RewardsManager.lua:5270`](../saboteur-luacd/src/Managers/RewardsManager.lua) |
| `SetSpecialCaseFillMultiplier` | `Suspicion.SetSpecialCaseFillMultiplier` | `0x007479e0` | — | `(fMult:number) -> ()` → `+0x90`, sets bit `+0x9c & 0x10` | confirmed | Body |
| `ClearSpecialCaseFillMultiplier` | `Suspicion.ClearSpecialCaseFillMultiplier` | `0x00749080` | — | `() -> ()` *(corpus)* | **open** | `inlined`, no body. 1 corpus call, `()` |
| `ResetEscalation` | `Suspicion.ResetEscalation` | `0x00749020` | — | `() -> ()` *(corpus)* | **open** | `inlined`, no body. 31 corpus calls (29 `()`, 2 `(false)`) — see the outlier below |
| `ResetEscalationBPSet` | `Suspicion.ResetEscalationBPSet` | `0x00749060` | — | `() -> ()` *(corpus)* | **open** | `inlined`, no body. Pairs with `SetEscalationBPSet` |
| `ResetMeter` | `Suspicion.ResetMeter` | `0x00749000` | — | `() -> ()` *(corpus)* | **open** | `inlined`, no body |
| `SuspicionSetEscalated` | `Suspicion.SetEscalated` | `0x00749040` | — | `() -> ()` *(corpus)* | **open** | `inlined`, no body. 28 corpus calls, all `()` ([`Act_1_Mission_2B.lua:309`](../saboteur-luacd/src/Missions/Act_1_Mission_2B.lua)) |
| `SetGlobalWTF` | `Render.SetGlobalWTF` | `0x0073da50` | — | `(bHigh:boolean) -> ()` | confirmed | `true`→`FUN_0096f290`, `false`→`FUN_0096f2c0`. [`Act_1_BarFight.lua:20`](../saboteur-luacd/src/Missions/Act_1_BarFight.lua) |
| `ClearGlobalWTF` | `Render.ClearGlobalWTF` | `0x007400f0` | — | `() -> ()` *(corpus)* | **open** | `inlined`, no body |
| `WTFGetInfluence` | `Render.WTFGetInfluence` | `0x0073db10` | — | `(x:number, y:number, z:number) -> number` — **unchecked** | confirmed | See "the unguarded one" below |
| `WTFEnableNode` | `Render.WTFEnableNode` | `0x0073d500` | — | `(sNodeName:string) -> ()` → sets `+0x5c = 1` | confirmed | Intern → `FUN_00975e10` node lookup |
| `WTFSetOverrideBlueprint` | `Render.WTFSetOverrideBlueprint` | `0x0073d780` | — | `(sBP:string) -> ()` → `DAT_0147dd2c[+0x10]` | confirmed | 24 corpus calls ([`Act_1_Factory.lua:170`](../saboteur-luacd/src/Missions/Act_1_Factory.lua)) |
| `WTFSetHighOverrideBlueprint` | `Render.WTFSetHighOverrideBlueprint` | `0x0073d810` | — | `(sBP:string) -> ()` → `[+0x8]`, weight `[+0x0]=1.0f` | confirmed | `*DAT_0147dd2c = 0x3f800000` |
| `WTFSetLowOverrideBlueprint` | `Render.WTFSetLowOverrideBlueprint` | `0x0073d8a0` | — | `(sBP:string) -> ()` → `[+0xc]`, weight `[+0x4]=1.0f` | confirmed | Body |
| `WTFBlendOverrideBlueprint` | `Render.WTFBlendOverrideBlueprint` | `0x0073d670` | — | `(sBPa:string, sBPb:string, fBlend:number) -> ()` | confirmed | All 3 `&&`-chained → `FUN_00970ca0(a,b,t)` |
| `WTFClearOverrideBlueprint` | `Render.WTFClearOverrideBlueprint` | `0x00740080` | — | `() -> ()` *(corpus)* | **open** | `inlined`, no body. 10 corpus calls (+1 bare function reference) |
| `WTFClearHighOverrideBlueprint` | `Render.WTFClearHighOverrideBlueprint` | `0x0073ffb0` | — | `() -> ()` | **open** | `inlined`, no body. **No corpus call** |
| `WTFClearLowOverrideBlueprint` | `Render.WTFClearLowOverrideBlueprint` | `0x0073ffd0` | — | `() -> ()` | **open** | `inlined`, no body. **No corpus call** |
| `WTFOverrideTransitionPosition` | `Render.WTFOverrideTransitionPosition` | `0x0073d930` | — | `(sObjName:string) -> ()` → copies vec3 to `+0x640`, flag `+0x63c` | confirmed | **Takes a NAME, not x/y/z** — `FUN_009a0010` lookup, `vtable+0x14` → position |
| `WTFOverrideTransitionBlastTime` | `Render.WTFOverrideTransitionBlastTime` | `0x0073d9e0` | — | `(fTime:number) -> ()` → `+0x66c`, flag `+0x668` | confirmed | Body |
| `WTFOverrideTransitionSwitchTime` | `Render.WTFOverrideTransitionSwitchTime` | `0x0073d5f0` | — | `(fTime:number) -> ()` → `+0x674`, flag `+0x670` | confirmed | Body |
| `WTFExitActivePortal` | `Render.WTFExitActivePortal` | `0x0073ff80` | — | `() -> ()` *(corpus)* | **open** | `inlined`, no body. 4 corpus calls |
| `WTFFinishTransition` | `Render.WTFFinishTransition` | `0x0073fff0` | — | `() -> ()` | **open** | `inlined`, no body. **No corpus call** |
| `GlobalEnableHighWTFCivMelee` | `Actor.GlobalEnableHighWTFCivMelee` | `0x0070c830` | — | `(bEnable:boolean) -> ()` → global `DAT_011b9cb4` | confirmed | [`RewardsManager.lua:5265`](../saboteur-luacd/src/Managers/RewardsManager.lua) |
| `SetNumWTFZones` | `Util.SetNumWTFZones` | `0x00753350` | — | `(nZones:number) -> ()` → `DAT_014aadcc[+0x19c]` | confirmed | Body. **No corpus call** |
| `RecordWTFZoneFlipped` | `Util.RecordWTFZoneFlipped` | `0x0075b3c0` | — | ? | **open** | `inlined`, no body. **No corpus call** |
| `TrigCreateSuspicionZone` | `Trigger.CreateSuspicionZone` | `0x0074b210` | — | `(hCtrl:handle [, bA:boolean=true] [, bB:boolean=true]) -> ()` | confirmed | Bits `+0x11d & 4` / `& 2`. [`SuspicionZonePed.lua:6`](../saboteur-luacd/src/Modules/Behavior/Triggers/SuspicionZonePed.lua) passes `(h, true, false)` |
| `MakeEscalationCallback` | `Util.MakeEscalationCallback` | `0x0074c420` | — | `(sCallbackName:string [, tSelf:table] [, tUser:table]) -> ()` | confirmed | Callback-by-name idiom (§10). **Gated on `IsEscalated`** — see below |
| `SetCanJoinEscalation` | `Vehicle.SetCanJoinEscalation` | `0x00760af0` | — | `(hVehicle:handle [, bCan:boolean=false]) -> ()` | confirmed | [`Act_1_Mission_2B.lua:310`](../saboteur-luacd/src/Missions/Act_1_Mission_2B.lua) |

## How the subsystem actually works

### WTF is two systems wearing one name

The single most useful structural fact: **`WTF*` bindings register into the `Render` table**, not a
gameplay table. Will-to-Fight is a *district colour/atmosphere* system at the Lua seam — every `WTF*`
binding drives either the `WSWillToFightGrid` influence field or a blueprint override that swaps the
district's visual set. The *gameplay* consequences of WTF (civilian melee, resistance reinforcement)
are reached through entirely different tables: `Actor.GlobalEnableHighWTFCivMelee` and
`Suspicion.EnableResistanceEscalation`. Scripts confirm the split — `Render.SetGlobalWTF(true)` opens
[`Act_1_BarFight.lua:20`](../saboteur-luacd/src/Missions/Act_1_BarFight.lua) purely to force the
mission's look, and `Render.WTFSetOverrideBlueprint("WillToFight_INT_Dopp_Car_low")`
([`Act_1_Factory.lua:170`](../saboteur-luacd/src/Missions/Act_1_Factory.lua)) names a *blueprint
asset*. The de-saturated-Paris fiction and the wanted-level fiction are separate engine systems that
the design deliberately correlates; the binding tables are where that seam shows.

The three override slots form one small struct at `DAT_0147dd2c` — `[+0x0]` high weight, `[+0x4]` low
weight, `[+0x8]` high BP, `[+0xc]` low BP, `[+0x10]` plain BP — and the `Set{High,Low}` variants each
write `0x3f800000` (`1.0f`) into their weight as they store the pointer, i.e. *setting* an override
pins its blend to fully-on. `WTFBlendOverrideBlueprint(a, b, t)` is the manual-blend escape hatch.
The transition ("blast ring") tuning lives in a second struct at `DAT_0147e674`, where each override
is a **flag byte + value** pair (`+0x63c`/`+0x640` position, `+0x668`/`+0x66c` blast time,
`+0x670`/`+0x674` switch time) — the flag is what makes it an *override* rather than a value.

`WTFOverrideTransitionPosition` is worth flagging for anyone writing a signature from its name: it
takes **a string object name**, not coordinates. It interns the name, resolves an object via
`FUN_009a0010`, calls `vtable+0x14` to get a vec3, and copies three words. Guessing `(x,y,z)` here
would have been wrong — and its sibling `WTFGetInfluence` *does* take `(x,y,z)`.

### Escalation is a 0..5 integer with a hard engine-side clamp

`Suspicion.SetEscalationLevel` fetches an int and tests `uVar3 < 6` **unsigned** — so `0..5` is
confirmed byte-level (independently corroborating the `ESCALATION_LEVEL_%d` string evidence in the
symbol map), and a negative level wraps to a huge unsigned and is *rejected*, not clamped. Out-of-range
calls are silent no-ops, consistent with the family-wide no-error rule.

The level lives at `DAT_0143e6f4 + 0x1154`. Two flag bytes carry the modifiers, and the bindings let
me pin individual bits that the symbol map only described as "flag bytes":

| Bit | Set by | Meaning (inferred from binding name) |
|---|---|---|
| `+0x1252 & 0x10` | `EnableEscalationVehicles` | escalation vehicles enabled |
| `+0x1252 & 0x20` | `EnableReEscalation` | re-escalation allowed |
| `+0x1252 & 0x40` | `SetEscalationLevel` (when `level>0`) | **script-forced escalation latch** |
| `+0x1252 & 0x80` | `OverrideEnableEscalationVehicles` | vehicle-enable override |
| `+0x1253 & 0x10` | *(engine)* | **escalated-lite** — read by `GetEscalation`/`IsEscalated`/`IsEscalatedLite` |
| `+0x1253 & 0x20` | `SetEscalationLiteInfinitely` | lite never times out |
| `+0x1253 & 0x80` | `EnableResistanceEscalation` | resistance escalation |
| `+0x1255 & 0x10` | `SetInescapableEscalation` | inescapable |

`+0x1252 & 0x40` is a genuinely new fact: `SetEscalationLevel` sets it as a side effect whenever the
requested level is positive, and no binding in this family ever clears it. Note also `SetInescapableEscalation`
writes a **third** flag byte, `+0x1255`, that the symbol map does not mention at all.

### Escalated-lite masks the escalation level from Lua — and scripts work around it

`Suspicion.GetEscalation()` does **not** simply return the level:

```c
if ((*(byte *)(DAT_0143e6f4 + 0x1253) & 0x10) == 0) {
  FUN_006f7040(*(undefined4 *)(DAT_0143e6f4 + 0x1154));   // push real level
  return 1;
}
FUN_006f7040(0);                                          // lite -> push 0
return 1;
```

When the escalated-**lite** bit is set, `GetEscalation()` reports **0** regardless of the real level,
and `IsEscalated()` likewise returns false (`level>0 AND NOT lite`). "Lite" is a pre-alarm state —
soldiers are suspicious and closing in, but the world is not yet officially in a wanted state — and
the engine models it by *hiding* the level from scripts rather than by keeping a separate counter.

This is not a curiosity; it is load-bearing, and the corpus proves scripts know about it. The
recurring idiom is an explicit two-term test:

- `if Suspicion.GetEscalation() > 0 or Suspicion.IsEscalatedLite() then` —
  [`P1FP_DestroyConvoy.lua:188`](../saboteur-luacd/src/Missions/P1FP_DestroyConvoy.lua), `:329`
- `if Suspicion.GetEscalation() == 0 and not Suspicion.IsEscalatedLite() then` —
  [`P1FP_NaziParty.lua:177`](../saboteur-luacd/src/Missions/P1FP_NaziParty.lua), `:187`
- `if Suspicion.IsEscalated() or Suspicion.IsEscalatedLite() then` —
  [`CoDSpawner.lua:94`](../saboteur-luacd/src/ScriptControllers/CoDSpawner.lua), `:103`

Every "is the player in trouble at all?" check in the corpus is a manual OR of the two. A mission
author who wrote only `GetEscalation() > 0` would silently fail to notice lite alerts — and the next
section shows the shipped code doing exactly that.

### A shipped bug in `EVENT_OnEscalationLite`

`Util.MakeEscalationCallback` exists to solve an ordering problem: `EVENT_OnEscalation` registers an
event that fires *when* escalation begins, but if escalation is **already** active the event will
never fire, so the wrapper fires the callback immediately instead
([`WRAPPER_Event.lua:602-605`](../saboteur-luacd/src/Includes/WRAPPER_Event.lua)):

```lua
if Suspicion.GetEscalation() ~= 0 then
  Util.MakeEscalationCallback(a_sCallbackFunction, self, a_tUserTable)
  return
end
```

The binding body carries its own internal gate — and it is precisely the `IsEscalated` condition:

```c
if ((cVar1 != '\0') && (pcVar4 = FUN_006f7a80(1), pcVar4 != 0) && (*pcVar4 != '\0') &&
    ((0 < *(int *)(DAT_0143e6f4 + 0x1154) && ((*(byte *)(DAT_0143e6f4 + 0x1253) & 0x10) == 0)))) {
```

i.e. `level > 0 AND NOT lite`. Now read the *lite* wrapper twenty lines further down
([`WRAPPER_Event.lua:623-625`](../saboteur-luacd/src/Includes/WRAPPER_Event.lua)):

```lua
if Suspicion.IsEscalatedLite() then
  Util.MakeEscalationCallback(a_sCallbackFunction, self, a_tUserTable)
  return
end
```

The wrapper calls `MakeEscalationCallback` **exactly when the lite bit is set** — the one condition
under which the binding's own gate is guaranteed to fail. The callback never fires, and the `return`
skips the fallback `Util.CreateEvent` path too, so the caller gets **nothing**: no immediate call, no
registered event. Any script using `EVENT_OnEscalationLite` while already escalated-lite silently
loses its callback. Given the family-wide silent-failure rule (§6/§7 of the ABI sheet: no
`lua_error`, bad args just `return`), nothing would ever have surfaced this in testing.

I am calling this **confirmed as a static contradiction** — the two conditions are read from the same
byte in the same call with no intervening write. What I have *not* done is observe it live, so the
possibility that some caller path clears bit `0x10` first remains formally open. It is the single
highest-value lead in this family for anyone modding escalation events.

A milder sibling bug sits in the same function: `EVENT_OnEscalation` normalises a non-table
`a_tUserTable` into `tUserTable = {a_tUserTable}` and passes **`tUserTable`** to `Util.CreateEvent`,
but passes the **raw `a_tUserTable`** to `Util.MakeEscalationCallback`
([`WRAPPER_Event.lua:596-604`](../saboteur-luacd/src/Includes/WRAPPER_Event.lua)). The binding checks
arg 3 with `FUN_006f71c0` (exact table test), so a scalar user-value survives the deferred path but is
silently dropped on the immediate path.

### `Suspicion.IsEnabled` returns three different shapes

Most bindings here are uniform; this one is a genuine outlier and worth quoting, because it is the
family's only binding that can return `nil`:

- **No handle passed** → returns the global `DAT_011bb674` (the `EnableGlobal` flag) as a boolean.
- **Handle passed, resolves, suspicion component present** → returns `perActor(+0x20 & 1) AND global`.
- **Handle passed, resolves, component missing** (`+0x154 == 0`) → `FUN_006f7010()` = **pushes nil**, `return 1`.
- **Handle passed but stale** → `return 0` = **no results at all** (reads as `nil` to the caller, but
  by a different mechanism).

So `Suspicion.IsEnabled(h)` distinguishes "explicitly disabled" (`false`) from "this actor has no
suspicion component" (`nil`) — a distinction no other binding in the family makes. Note the per-actor
bit is AND-ed with the global, so `EnableGlobal(false)` makes every actor report disabled regardless
of its own bit.

### The radius handshake is the family's only real resource

`SetupSuspicionRadius` is one of just seven `LuaGlueFunctor0R` bindings here and the only one that
*allocates*. It returns an **integer ID** (not a handle — `FUN_006f7040` pushes a number), and
`KillSuspicionRadius` takes that integer back via `FUN_006f7990`. The corpus treats it as an owned
resource with nil-guarded cleanup:

```lua
self.SusZoneID = Suspicion.SetupSuspicionRadius(Handle(self.tInfo.SuspicionCircle), 30)
...
if self.SusZoneID then
  Suspicion.KillSuspicionRadius(self.SusZoneID)
  self.SusZoneID = nil
end
```
([`Act_1_Mission_2B.lua:273,127-130`](../saboteur-luacd/src/Missions/Act_1_Mission_2B.lua); same
pattern at [`P1FP_Jailbreak.lua:671,713`](../saboteur-luacd/src/Missions/P1FP_Jailbreak.lua))

The optional third argument is a duration defaulting to the tunable `_DAT_00f7b148` — the same global
the symbol map identifies in `WSAISuspicionRadius::Update`'s escalate-lite timer, which ties the
script-created radius to the same timeout machinery as engine-spawned ones. Every corpus call passes
only two arguments and takes the default.

### The `Experimental/` folder calls a Suspicion API that does not exist

Four names are called by scripts but are **not registered bindings**:
`Suspicion.SetState`, `Suspicion.Suspend`, `Suspicion.GetSuspicionMeterState`, `Render.WTFGetStage`.
None appears in `lua_registration_map.tsv`; none is defined anywhere in the Lua corpus. There *is* a
flat `SetState` in `lua_bindings.txt:710` — but the map resolves it to **`Sound.SetState`**
(`0x00743fc0`), a different subsystem entirely. This is the §0 trap in its purest form: the flat name
exists, and reading the flat list alone would have "confirmed" a `Suspicion.SetState` that is not real.

Every caller of these four is in **`Experimental/`** (`SoldierState_Combat`, `_Hunt`, `_Investigate`,
`_InvestigateThreat`, `_PaperCheckBackup`, `_PaperCheckLeader`, `Soldier_Callbacks`,
`Soldier_Internal`, `MgrHarasser`) — plus one stray in
[`ScriptSequence.lua`](../saboteur-luacd/src/Modules/Libraries/ScriptSequence.lua). They read like a
prototype ped-suspicion FSM driven from Lua (`Suspicion.SetState(hSoldier, "Orange")`,
[`SoldierState_Hunt.lua:30`](../saboteur-luacd/src/Experimental/SoldierState_Hunt.lua)) that was
abandoned when the FSM moved into C++ — the retail engine sets those states itself via
`FUN_008e8d40`/`FUN_008e8a90` and merely *broadcasts* `OnSuspicionEnter*` events to Lua. `MgrHarasser`
likewise compares `Render.WTFGetStage()` against a `cWTF_LIBERATION` constant that no longer has a
binding behind it. In retail these are dead calls that would raise "attempt to call a nil value" if
the files ever loaded.

**This corrects [`docs/symbol_map/suspicion-wtf.md`](../symbol_map/suspicion-wtf.md)**, which states
"`SoldierState_*` (Investigate/Hunt/Combat/PaperCheck) drive `Suspicion.SetState`". They attempt to;
there is no such binding in the retail build.

### The unguarded one

`Render.WTFGetInfluence` skips type checks entirely — no `FUN_006f7140` before the fetches:

```c
fVar2 = (float10)FUN_006f7950(1);
fVar3 = (float10)FUN_006f7950(2);
fVar4 = (float10)FUN_006f7950(3);
fStack_8 = (float)fVar4;  uStack_4 = 0;              // vec3 + 0.0f pad
fStack_10 = (float)fVar2; fStack_c = (float)fVar3;
fVar2 = (float10)FUN_009758e0(&fStack_10);           // sample the influence grid
FUN_006f7060((float)fVar2);
return 1;
```

Because `FUN_006f7950` returns `0.0` on a type mismatch (§4), `Render.WTFGetInfluence()` with no
arguments does not fail — it samples the origin `(0,0,0)` and returns a plausible float. It is the
family's clearest example of why "returns a number" is not the same as "worked". Unusually for a
zero-check binding it is `LuaGlueFunctor0R`, so it genuinely returns 1 result. It has **no corpus
call site**.

### Registered but never called

**Eighteen** of the 56 are registered and never called by any of the 321 corpus scripts (counting only
call sites — `Name(`; three `Suspicion.EnableGlobal` and one `Render.WTFClearOverrideBlueprint`
mentions are bare function references passed to another table, and those two bindings *are* otherwise
called):

| Table | Never called |
|---|---|
| `Render` (11) | `WTFGetInfluence`, `WTFEnableNode`, `WTFBlendOverrideBlueprint`, `WTFSet{High,Low}OverrideBlueprint`, `WTFClear{High,Low}OverrideBlueprint`, `WTFOverrideTransition{Position,BlastTime,SwitchTime}`, `WTFFinishTransition` |
| `Suspicion` (5) | `Reset`, `IsEnabled`, `IsActingSuspiciously`, `EnableReEscalation`, `OverrideEnableEscalationVehicles` |
| `Util` (2) | `SetNumWTFZones`, `RecordWTFZoneFlipped` |

The `Render` cluster is the interesting one: **the entire fine-grained WTF grid/transition control
surface is dead in shipped content**. Missions use only the coarse verbs (`SetGlobalWTF`,
`ClearGlobalWTF`, `WTFSetOverrideBlueprint`, `WTFClearOverrideBlueprint`, `WTFExitActivePortal`) and
leave zone counting, node enabling, influence sampling and blast-ring tuning to the engine. Note that
even `WTFSet{High,Low}OverrideBlueprint` — whose bodies are readable and whose weight-pinning
behaviour is described above — have no call site; only the plain `WTFSetOverrideBlueprint` is used.

The five unused `Suspicion` rows do **not** fit that story and should not be read as part of it: they
are ordinary gameplay verbs (a per-actor reset, two queries, and two escalation toggles) that shipped
content simply had no occasion to call. `Suspicion.IsEnabled` is notable — the family's most
structurally interesting binding (see above) has zero callers.

Either the corpus is incomplete (it is a decompilation, and `Missions/` may not be exhaustive) or
these are designer-facing APIs the shipped content never needed. `Util.SetNumWTFZones` and
`RecordWTFZoneFlipped` look like a matched pair for a district-progress HUD that the corpus drives
some other way.

## Open questions

1. **Is the `EVENT_OnEscalationLite` bug live?** The static contradiction is airtight, but confirming
   it needs a breakpoint on `0x0074c420` with bit `+0x1253 & 0x10` set. Highest-value item here.
2. **`Suspicion.IsSomeoneHostile` (`0x00747510`)** — a real 112-byte function Ghidra never
   disassembled. It should be forced to disassemble; it is the only *readable-in-principle* gap.
   Its sibling `IsSomeoneHostileOrHunting` calls `FUN_008992c0(FUN_008a6cb0(1,0,0), 1, 0, 0)`, so
   `IsSomeoneHostile` most likely differs only in those trailing literals — but that is a guess and
   is not recorded as a signature above.
3. **The 12 `inlined` bindings have no recoverable body.** Their arity is corpus-only — and for four
   of them (`Render.WTFClear{High,Low}OverrideBlueprint`, `Render.WTFFinishTransition`,
   `Util.RecordWTFZoneFlipped`) there is no corpus call either, so their arity is simply **unknown**.
   Of the eight that are called, all sites pass `()` — except **`Suspicion.ResetEscalation(false)`**
   at [`Belle_Interior.lua:57`](../saboteur-luacd/src/Modules/InteriorLevels/Belle_Interior.lua) and
   [`Belle_Interior_Destroyed.lua:32`](../saboteur-luacd/src/Modules/InteriorLevels/Belle_Interior_Destroyed.lua),
   against 29 zero-arg calls elsewhere. Either the binding takes an optional bool that the other 29
   sites omit, or two interior scripts pass an argument that is silently discarded. Cannot be
   resolved without disassembling `0x00749020`.
4. **What is `EnableEscalation`'s second argument?** The binding is variadic (`FUN_006f6970`) and
   `FUN_0089e990(bEnable, bArg2)` takes it, defaulting arg 2 to `0`. The corpus uses the two-arg form
   exactly **once**: `Suspicion.EnableEscalation(false, true)` in `Act_3_Mission_2:SetupExecution`
   ([`Act_3_Mission_2.lua:1572`](../saboteur-luacd/src/Missions/Act_3_Mission_2.lua)), immediately
   followed by `Suspicion.EnableGlobal(false)` — i.e. a hard "shut the whole system off for a scripted
   execution beat". That the *only* two-arg site pairs `(false, true)` with a global disable hints
   arg 2 is a force/immediate qualifier on the disable rather than a second mode flag, but one call
   site cannot settle it; `FUN_0089e990` must be read. Compare `EnableEspritDeCorps`, whose arg 2
   defaults to **`1`** — a non-obvious default that suggests its two-arg form was the original API.
5. **`+0x1252 & 0x40`** — set by `SetEscalationLevel` whenever `level > 0`, cleared by nothing in this
   family. A "script forced the level" latch is the natural reading, but the consumer is unidentified.
6. **`+0x1255`** is a third escalation flag byte, touched only by `SetInescapableEscalation` and absent
   from the symbol map. Its other bits are unmapped.
7. **`IsActingSuspiciously` thresholds at `state > 2`** (`+0x1900` on the AI object). Mapping `3` onto
   the named colour states (Green/Yellow/Orange/Red) would let the meter be read exactly; the symbol
   map's `FUN_008e8a90` switch is the place to resolve it.
8. **`SetEscalationBPSet` silently rejects names ≥ 0x40 chars** — a fixed 64-byte buffer downstream in
   `FUN_008adba0`. Whether longer blueprint-set names exist in shipped data is unchecked.
9. **The `Suspicion` table has no `Script\Interface\Suspicion.cpp`.** Given `Actor`, `Object`,
   `Vehicle`, `Utility`, `Navigation`, `Inventory` and `SaveLoad` all have one, the suspicion bindings
   were probably authored in an AI-side file (`WSAIEscalation.cpp`?) that carries no assertions.
   Nothing in the decomp confirms where they live.

## See also

- [`docs/symbol_map/suspicion-wtf.md`](../symbol_map/suspicion-wtf.md) — engine internals: the
  `DAT_0143e6f4` hive-mind singleton, the `DAT_0143ec04[0..8]` census, `WSAIEscalation`,
  `WSWillToFightGrid`, and the `OnEscalation*` / `OnSuspicionEnter*` event set these bindings sit on top of.
- [`02-marshalling-abi.md`](02-marshalling-abi.md) — the primitive decoder ring used throughout.
- [`05-engine-to-lua-callbacks.md`](05-engine-to-lua-callbacks.md) — the callback-by-name mechanism
  behind `Util.MakeEscalationCallback`.
