# Family: navigation, movement and pathing

> **Verified:** All 23 VAs re-checked against the registration TSV, the decomp and `Saboteur.exe`; the
> `EnterFormation` assertion, the `ChooseWanderPoint` stub bytes, the 16/898 stub sweep, the 0-hit string
> test, the `push 0x70` sites, the `FormationMoveOnPath` disassembly, all 23 RTTI entries, the call-site
> census and all 14 corpus citations reproduce exactly. Four claims were wrong and are corrected here: the
> `FUN_0082e310` caller list omitted `Util.SpawnGooseSteppers` (§4); `CancelScriptedPath`/`CancelFollowObject`
> do **not** enter the redirect via `FUN_00498440` (§4); `TreysMoveSeanToPointDangerous` is **not** alone in
> using the `DAT_01321e38` map (§1, open q6); and the trailing optional args are not all index-dropped
> (open q4).
>
> ⚠️ *(corrected 2026-07-24)* The call-site census counted **name occurrences**, not calls. Six rows were
> each one too high because the name also appears once as a bare **function value** in a deferred-action
> table: `CancelFollowObject` 24→23, `CancelScriptedPath` 35→34, `FollowObject` 36→35, `MoveToObject`
> 127→126, `SetScriptedPathSpeed` 103→102, `StopMoving` 29→28. All other counts in this document are
> unaffected (`SetScriptedPath` 233, `MoveToPoint` 31, `SetScriptedPathMoveMode` 84, `SetScriptedPathType`
> 32 — re-measured, all exact).

## What this establishes

The `Nav` table is the AI locomotion seam: 23 bindings that let a mission script tell a character or a
vehicle **where to go and how to get there**. It is a small, unusually clean family — every binding lives
in one contiguous slab of `0x00734040`–`0x007372d0`, every one is registered into a single table, and the
Lua names are byte-identical to the C++ symbols in 22 of 23 cases (the exception is `NavBoardVehicle` →
`Nav.BoardVehicle`).

Four findings are worth stating before the table, because they are the ones that change how you read the
family:

1. **`Nav.ChooseWanderPoint` is an empty stub.** Its entire implementation is `mov eax,1; ret`. It is
   registered, callable, and does nothing. Any script relying on it is relying on a no-op.
2. **A move order is not issued to the actor you name — it is issued to whatever is currently driving
   that actor.** Every movement binding runs the same "if this character is in a vehicle, retarget the
   order to the vehicle's follower" redirect. This is the single most important behavioural fact in the
   family.
3. **`Nav.SetScriptedPathMoveMode` silently rejects `cMOVE_GOOSESTEP`.** It range-checks `< 5`, and
   goosestep is 5. The mode is reachable through `Nav.MoveToPoint` and formations, but not through this
   setter.
4. **`Nav.SetScriptedPathMoveType` and `Nav.MoveToSchedulePoint` do not exist.**
   [Doc 06 §5](06-lua-side-wrapper-layer.md) flagged both as unresolved ("engine binding, or live script
   bug?"). They are live script bugs, and one of them sits on the completion path of a shipped mission.
   Proof is in §6.

The marshalling ABI itself (`FUN_006f8470`, `FUN_006f71a0`, the handle idiom, the `LuaGlueFunctor0`
return contract) is the scope of docs [02](02-marshalling-abi.md) and [03](03-handle-and-object-model.md)
and is used here, not re-derived.

---

## 1. Inclusion rule — how the boundary was drawn

**Rule: a binding is in this family iff its `table` column in
[`data/lua_registration_map.tsv`](../../data/lua_registration_map.tsv) is `Nav`.** That yields exactly 23
rows. The rule is mechanical and auditable — re-run `awk -F'\t' '$1=="Nav"' data/lua_registration_map.tsv`.

I chose the registration table over a name-keyword scan deliberately. A keyword scan for
`path|move|wander|spline|follow|formation` is actively misleading here: `move` is a substring of
**Re**`move`, so the scan drags in `Actor.RemoveDisguise`, `HUD.RemoveTimer`, `Trigger.RemoveFilter` and
~20 other unrelated bindings while telling you nothing about locomotion.

**Deliberately excluded, with reasons** (these are real boundary calls, listed so the omission is not
silent):

| Excluded | Table | Why |
|---|---|---|
| `Combat.SetIdlePath`, `Combat.SetObjectivePath` | `Combat` | Genuine overlap — both call `FUN_0082e310`, the same named-path lookup `Nav.SetScriptedPath` uses. They are combat-AI path *assignment*, not navigation. Claimed by family 13. |
| `Combat.SetFollowBoardCallback` / `SetFollowUnboardCallback` | `Combat` | Near-twins of the `Nav.SetFollowObject*Callback` pair. Same shape, different table. |
| `Squad.FollowLeader`, `Squad.SetLeaderPath` | `Squad` | Squad-level; `SetSquadLeaderPath` also calls `FUN_0082e310`. |
| `Cin.*ObjectSpline`, `Util.*SplinePlaneAttack*`, `Util.SetMiniZepSpline` | `Cin`/`Util` | "Spline" in this engine is **cinematic/vehicle rail**, a different subsystem (`WSCinemaSpline`) from AI pathing (`WSAIScriptedPaths`). Not navigation despite the keyword. |
| `Actor.WalkToDespawnLocation` | `Actor` | Ambient-population despawn, drives no `Nav` object. |
| `HUD.SetWaypoint` / `GetWaypointPosition` | `HUD` | Map UI marker, not AI pathing. A real false friend. |

**Ambiguous, and claimed anyway:** `Nav.TreysMoveSeanToPointDangerous` is a player-specific one-off named
after a developer that drives `FUN_005a2b80` — not a follower at all. It is in the `Nav` table, so it is in
this family, but it does not fit the subsystem described in §4. Its distinguishing feature is the
`FUN_005a2b80` target, *not* its handle lookup: it resolves arg 1 through `FUN_0067c0a0` (the `DAT_01321e38`
map), which is the same resolver `Nav.MoveToObject`, `FollowObject`, `SetScriptedPath`, `SetScriptedPathType`
and `BoardVehicle` all use.

---

## 2. Coverage

**23 of 23 bindings in this family located. 1 confirmed by assertion string. 18 of 23 signatures
corroborated by a real Lua call site. 5 derived from the binary alone. 0 not found.**

Unpacking that honestly, because "located" is doing two different jobs:

- **Identity (table, Lua name, VA, return family) is confirmed for all 23** — read byte-level from the
  registration stanzas, and independently cross-checked against the RTTI in
  [`data/rtti_classes_all.txt`](../../data/rtti_classes_all.txt), which carries all 23 mangled
  `?$LuaGlueFunctor0@$1?<symbol>@@YAXPAUlua_State@@@Z` names. All 23 `cpp_symbol`s are present exactly
  once in `data/lua_bindings.txt`.
- **Only 1 of 23 carries an EALA assertion string** — `EnterFormation`, at
  `Script\Interface\Navigation.cpp:1342`. It is the *only* `Navigation.cpp` reference in the entire 54 MB
  decomp. The assertion idiom does not generalise here.
- **21 of 23 bodies were read from the decomp. 2 were not in it at all** — Ghidra never recovered
  `0x00734630` (`FormationMoveOnPath`) or `0x00737160` (`ChooseWanderPoint`). Both were recovered by
  disassembling `Saboteur.exe` directly with capstone; both are reported below as **confirmed**, since raw
  instruction bytes are stronger evidence than pseudocode, not weaker. Recovering `FormationMoveOnPath`
  also revealed a call edge (`0x007346fb → FUN_0081c1c0`) that is missing from Ghidra's `callers=[...]`
  list for `FUN_0081c1c0` — a caution about treating that list as complete.
- **5 bindings have zero references in the 321-file Lua corpus** — not as calls, not as strings:
  `EnableParadePath`, `FormationMoveToPoint`, `SetFollowObjectBoardCallback`,
  `SetFollowObjectUnboardCallback`, `ChooseWanderPoint`. Their signatures come from the body only.

**Return contract:** 22 of 23 are `LuaGlueFunctor0` — the thunk hardcodes `nresults = 1` regardless of
what the body pushed, so per doc 02 §6 these do not meaningfully return anything. `Nav.CreateFormation`
is the family's only `LuaGlueFunctor0R`, and the only one that really returns a value. RTTI corroborates
this directly: it alone is mangled `?$LuaGlueFunctor0R@H$1?CreateFormation@@YAHPAUlua_State@@@Z` — `H`
for `int`, `YAH` for an `int` return — while the other 22 are `YAX` (`void`).

---

## 3. The bindings

Signature notation: `h` = handle (lightuserdata), `f` = number, `n` = integer, `s` = string, `b` =
boolean, `t` = table. `[x]` = optional. All are `Nav.<name>`; the C++ symbol equals the Lua name except
where noted.

| Binding | Namespaced form | VA | Source (file:line) | Signature | Confidence | Evidence |
|---|---|---|---|---|---|---|
| `AddMemberToFormation` | `Nav.AddMemberToFormation` | `0x00736ae0` | — | `(nFormationID, hActor) -> ()` | **confirmed** | Body: `isNumber(1)`+`isHandle(2)` → `FUN_0081b540(id)`, `FUN_0081b7b0(obj,-1)`. Call site [`Missions/Act_1_Escape.lua:545`](../saboteur-luacd/src/Missions/Act_1_Escape.lua#L545) |
| `BoardVehicle` | `Nav.BoardVehicle` | `0x00735f30` | — | `(hActor, hVehicle, [sSeat], [bRun\|nMode 0..5], [sCallback], [tSelf], [tUserData]) -> ()` | **confirmed** (args 1–6) | Body indices from stack spills `pcStack_30 = 0x1..0x7`. C++ symbol is `NavBoardVehicle`. Call site [`Missions/Act_1_GetCaught.lua:1317`](../saboteur-luacd/src/Missions/Act_1_GetCaught.lua#L1317); `"PILOT"`/`"SHOTGUN"` seats at [`Act_1_RaceToGermany.lua:293`](../saboteur-luacd/src/Missions/Act_1_RaceToGermany.lua#L293) |
| `CancelFollowObject` | `Nav.CancelFollowObject` | `0x00736910` | — | `(hActor) -> ()` | **confirmed** | Body: `isHandle(1)` only, then `FUN_0083c900`/`FUN_0083c810`. 23 calls (+1 function-value reference), e.g. [`Act_1_GetCaught.lua:2521`](../saboteur-luacd/src/Missions/Act_1_GetCaught.lua#L2521) |
| `CancelScriptedPath` | `Nav.CancelScriptedPath` | `0x00736800` | — | `(hActor) -> ()` | **confirmed** | Body: `isHandle(1)` only. 34 calls (+1 function-value reference) |
| `CanPathfind` | `Nav.CanPathfind` | `0x007350d0` | — | `(fX1,fY1,fZ1, fX2,fY2,fZ2, sCallback, [tSelf], [tUserData]) -> ()` | **confirmed** | Body: 6× `isNumber`, `toString(7)`, `argc>7`→self(8), `argc>8`→table(9). Exactly 9 args at [`Experimental/SoldierState_PaperCheckLeader.lua:108`](../saboteur-luacd/src/Experimental/SoldierState_PaperCheckLeader.lua#L108) |
| `ChooseWanderPoint` | `Nav.ChooseWanderPoint` | `0x00737160` | — | **empty stub — takes anything, does nothing** | **confirmed** | Body is literally `b8 01 00 00 00 c3` = `mov eax,1; ret`. Name string `"ChooseWanderPoint"` at `0x00fe26b8`, vtable `0x00fe28e4` → stub `0x007372a0` → impl. See §5 |
| `CreateFormation` | `Nav.CreateFormation` | `0x007344f0` | — | `() -> nFormationID` | **confirmed** | Only `LuaGlueFunctor0R` in the family; `FUN_0081c410(0)` → pushes `*(obj+0x24)`, `return 1`; `return 0` on alloc failure. [`Act_1_Escape.lua:539`](../saboteur-luacd/src/Missions/Act_1_Escape.lua#L539) |
| `EnableParadePath` | `Nav.EnableParadePath` | `0x00734710` | — | `(sPathName, bEnabled) -> ()` | *inferred* | Body only, indices clean: `isString(1)`+`isBool(2)` → `FUN_0082e310(name)` → sets bit 1 (mask `2`) of `path+0x24`. **No corpus call site** |
| `EnterFormation` | `Nav.EnterFormation` | `0x00736b90` | **`Navigation.cpp:1342`** | `(hActor, hLeader, fX, fY, fZ, [nMode]) -> ()` | **confirmed** (args 1–5); *inferred* (arg 6) | The family's only assertion string. 5 call sites, all 5-arg, e.g. [`Modules/Libraries/Formation.lua:132`](../saboteur-luacd/src/Modules/Libraries/Formation.lua#L132). Arg 6 never used by any script — see §5 |
| `ExitFormation` | `Nav.ExitFormation` | `0x00736df0` | — | `(hActor) -> ()` | **confirmed** | Body: `isHandle(1)`, vtable`+0x30` → `FUN_00864c40`. [`Modules/Libraries/ScriptSequence.lua:758`](../saboteur-luacd/src/Modules/Libraries/ScriptSequence.lua#L758) |
| `FollowObject` | `Nav.FollowObject` | `0x00735960` | — | `(hActor\|sName, hTarget\|sName, fDist, [bRun\|nMode 0..5], [b], [b], [b]) -> ()` | **confirmed** (args 1–4); *inferred* (args 5–7) | Indices from spills `puStack_34 = 0x1..0x7`. Args 1 **and** 2 each accept handle **or** string. 35 calls (+1 function-value reference), all 4-arg, e.g. [`Act_1_ConnectToBar.lua:141`](../saboteur-luacd/src/Missions/Act_1_ConnectToBar.lua#L141) |
| `FormationMoveOnPath` | `Nav.FormationMoveOnPath` | `0x00734630` | — | `(nFormationID, sPathName, [nPathType]) -> ()` | **confirmed** | **Absent from the decomp**; recovered by disassembly (§2). `isNumber(1)`→`FUN_0081b540`; `isString(2)`→`FUN_0082e310`; optional `toInt(3)`; `FUN_0081c1c0(path, type, 1)`. Exactly 3 args at [`Act_1_Escape.lua:548`](../saboteur-luacd/src/Missions/Act_1_Escape.lua#L548) |
| `FormationMoveToPoint` | `Nav.FormationMoveToPoint` | `0x00734560` | — | `(nFormationID, fX, fY, fZ) -> ()` | *inferred* | Body only, indices clean. `FUN_0081c110(&vec3, 0, 1)` → move mode **5 = goosestep**, hardcoded. **No corpus call site** |
| `MoveToObject` | `Nav.MoveToObject` | `0x007355e0` | — | `(hActor, hTarget, fDist, [bRun\|nMode 0..5], [sCallback], [tSelf], [tUserData], [b], [b], [n]) -> ()` | **confirmed** (args 1–7); *inferred* (args 8–10) | 126 calls (+1 function-value reference) — the family's workhorse. 7-arg form at [`Act_1_Escape.lua:468`](../saboteur-luacd/src/Missions/Act_1_Escape.lua#L468). **arg 5 must contain a `.`** — see §5 |
| `MoveToPoint` | `Nav.MoveToPoint` | `0x00735280` | — | `(hActor\|sName, fX, fY, fZ, [bRun\|nMode 0..5], [sCallback], [tSelf], [tUserData], [n], [b], [n]) -> ()` | **confirmed** (args 1–8); *inferred* (args 9–11) | Arg 1 accepts handle **or** string. Drives follower vtable`+0x90`. 31 call sites, e.g. [`Experimental/Checkpoint_v2.lua:35`](../saboteur-luacd/src/Experimental/Checkpoint_v2.lua#L35) |
| `SetFollowObjectBoardCallback` | `Nav.SetFollowObjectBoardCallback` | `0x00735cf0` | — | `(hActor, sCallback, [tSelf], [tUserData]) -> ()` | *inferred* | Body only. Terminal `FUN_0087f5e0`. **No corpus call site** |
| `SetFollowObjectUnboardCallback` | `Nav.SetFollowObjectUnboardCallback` | `0x00735e10` | — | `(hActor, sCallback, [tSelf], [tUserData]) -> ()` | *inferred* | **Byte-identical** to the Board twin across all 283 bytes except call displacements and one terminal call (`FUN_0087f630`). **No corpus call site** |
| `SetScriptedPath` | `Nav.SetScriptedPath` | `0x007361c0` | — | `(hActor, sPathName, [b], [sCallback], [tSelf], [tUserData]) -> ()` | **confirmed** | 233 call sites — the most-used binding in the family. `FUN_0082e310(name)` → path; callback index shifts with arg 3 (§5). 6-arg form at [`Missions/Act_1_ConnectToBar.lua:247`](../saboteur-luacd/src/Missions/Act_1_ConnectToBar.lua#L247) |
| `SetScriptedPathMoveMode` | `Nav.SetScriptedPathMoveMode` | `0x007364b0` | — | `(hActor, bUrgent\|nMode 0..4) -> ()` | **confirmed** | Accepts bool **or** number at arg 2; `if (mode < 5)` → writes `+0x30`. **Rejects `cMOVE_GOOSESTEP`(5)** — §5. 84 call sites, nearly all boolean |
| `SetScriptedPathSpeed` | `Nav.SetScriptedPathSpeed` | `0x007366c0` | — | `(hActor, fSpeed, [b]) -> ()` | **confirmed** (args 1–2); *inferred* (arg 3) | `toFloat(2)`, optional `isBool(3)` default `1`; drives `*(obj+0x13c)` vtable`+0x70`. 102 calls (+1 function-value reference), all 2-arg |
| `SetScriptedPathType` | `Nav.SetScriptedPathType` | `0x007365b0` | — | `(hActor, nPathType 0..3) -> ()` | **confirmed** | `toInt(2)` → `FUN_0088d700`. No range check in the binding. 32 call sites, all passing `cPATHTYPE_*` |
| `StopMoving` | `Nav.StopMoving` | `0x00736a20` | — | `(hActor) -> ()` | **confirmed** | Body: `isHandle(1)`, then follower vtable`+0xa4(1)`. 28 calls (+1 function-value reference) |
| `TreysMoveSeanToPointDangerous` | `Nav.TreysMoveSeanToPointDangerous` | `0x007347c0` | — | `(hPoint, fSpeed, [b]) -> ()` | **confirmed** | `isHandle(1)`+`isNumber(2)`, optional `isBool(3)`; resolves arg 1 via the **`DAT_01321e38` map** (`FUN_0067c0a0`), reads its transform through vtable`+0x14`, calls `FUN_005a2b80`. Sole call site [`Missions/Paris_1_Mission_1.lua:566`](../saboteur-luacd/src/Missions/Paris_1_Mission_1.lua#L566) |

---

## 4. How the subsystem actually works

### The three singletons

RTTI names the family's backing objects precisely — `data/rtti_classes_all.txt` carries
`?$PblSingleton@VWSAIFormations@@`, `?$PblSingleton@VWSAIPathfinder@@`,
`?$PblSingleton@VWSAIScriptedPaths@@` and `?$PblSingleton@VWSGpsPathFinder@@`. Disassembling
`FormationMoveOnPath` pinned two of their instance pointers directly:

| Singleton | Instance | Reached by |
|---|---|---|
| `WSAIFormations` | `DAT_0143d900` | `FUN_0081b540` (find by ID), `FUN_0081c410` (create) |
| `WSAIScriptedPaths` | `DAT_0143da28` | `FUN_0082e310` (find path by name) |
| `WSAIPathfinder` | *open* | `FUN_0082e270` (async query) |

`FUN_0082e310` is the family's shared name→path resolver: a `PblTree` lookup under a critical section at
`mgr+0x18`, returning the manager's default at `mgr+0x38` on a miss. Who calls it is the honest map of who
assigns paths — `Nav.SetScriptedPath`, `Nav.EnableParadePath`, `Nav.FormationMoveOnPath`,
`Combat.SetIdlePath` (`FUN_00722af0`), `Combat.SetObjectivePath` (`FUN_00721a90`), `Squad.SetLeaderPath`
(`FUN_007465b0`) and **`Util.SpawnGooseSteppers`** (`FUN_0074e2b0`), plus one non-binding caller,
`FUN_008d5720`, which is unidentified. That is exactly why the `Combat.*Path` and `Squad.*Path` exclusions in
§1 are boundary calls rather than clean cuts — and `Util.SpawnGooseSteppers` reaching the same resolver is a
loose end worth pulling given the goosestep finding below.

> *Provenance:* this is **not** Ghidra's `callers=[...]` list for `FUN_0082e310`, which lists only
> `EnableParadePath`, the four `Combat`/`Squad`/`Util` sites and `FUN_008d5720`. `Nav.SetScriptedPath`'s edge
> was confirmed by reading its body (`FUN_007361c0` calls `FUN_0082e310` directly) and
> `Nav.FormationMoveOnPath`'s by disassembly (`0x007346d0`). Two independent missing edges in one function's
> caller list — treat that list as a lower bound, never as complete.

### The vehicle redirect — the family's defining behaviour

The redirect — the `vtable+0x194` test and the `FUN_0067bf70` retarget — is present in eight bindings:
`MoveToPoint`, `MoveToObject`, `FollowObject`, `SetScriptedPath`, `SetScriptedPathType`,
`SetScriptedPathSpeed`, `CancelScriptedPath` and `CancelFollowObject`. The **first hop differs**, though:
the six issuing bindings reach the follower through `FUN_00498440` as below, while `CancelScriptedPath` and
`CancelFollowObject` never call `FUN_00498440` at all — they take the `EnterCriticalSection(DAT_0143db28)` /
`FUN_004436f0` handle-table idiom (doc 03) and join the chain at `vtable+0x1c`. The tail is common to all
eight:

```c
piVar5 = FUN_00498440(handle);              // handle -> registered proxy
piVar5 = (**(code **)(*piVar5 + 0x1c))();   // proxy -> weak-ref-holding target
iVar3  = FUN_0083a200();                    // weak ref: is it still alive?
if (iVar3 != 0 && FUN_00440a00() != 0) {
  iVar3 = (**(...+ 0x194))();               // "am I mounted in something?"
  if (iVar3 != 0 && (piVar5 = FUN_0067bf70()) != 0)
      /* issue the order to THIS object instead */
}
```

`FUN_0067bf70` is a two-hop accessor (`vtable+0x20` then `vtable+0x1c`) that yields a *different*
follower. Read against the RTTI class list — which carries `WSAIPathFollower`, `WSAIPathFollowerHuman`,
`WSAIPathFollowerVehicle`, `WSAIScriptedPathFollower` and `WSAIScriptedPathFollowerVehicle` — the
reading is clear: **when the named character is in a vehicle, the order is transparently retargeted from
the human follower to the vehicle follower.** `Nav.MoveToPoint(hSoldier, ...)` on a soldier sitting in a
truck drives the *truck*.

Doc 06 §5 notes `Vehicle.SetupRace` and friends; this is the same design instinct — the script layer names
*characters*, and the engine figures out what is actually doing the moving. It is why the corpus can call
`Nav.SetScriptedPathSpeed(hVehicle, 300)` and `Nav.SetScriptedPathSpeed(hCaravan_01, 1)` through the same
binding that steers pedestrians.

> **Confidence: inferred.** The chain is confirmed as *code*; the "vehicle" reading comes from the RTTI
> class names plus corpus usage, not from a symbol on `FUN_0067bf70` or `vtable+0x194`. The mapping of
> `+0x194` to "is mounted" is a proposal.

### Order objects have a fixed size and a fixed lifecycle

Every issuing binding follows the same four beats: cancel whatever is running, allocate, construct,
install. `FUN_0083c900` reads the live order at `follower+0x14c` (`vtable+0x28`); `FUN_0083c810` tears it
down and resets `+0x14c` to 0. Allocation is a bare size-class call — the disassembly shows
`push 0x70` immediately before `FUN_00734040` in `MoveToObject`, `FollowObject` and `BoardVehicle`, so
**a move order is a 0x70-byte object**, constructed by `FUN_0087e940`. Scripted paths take the other
allocator, `FUN_00734100` (`FUN_00dc1940` under `DAT_0132a504`), and are constructed by `FUN_0088e500`.

This is why `Nav.StopMoving`, `Nav.CancelScriptedPath` and `Nav.CancelFollowObject` are three bindings
rather than one: they differ only in *which* order they interrogate before clearing it —
`CancelScriptedPath` probes the scripted-path component (`thunk_FUN_00408600`), `CancelFollowObject`
probes the generic order slot (`FUN_0083c900`), and `StopMoving` skips the probe entirely and slams
`vtable+0xa4(1)`.

### Formations are small, and they goosestep

`FUN_0081b7b0` (add member) opens with `if (param_1[0xe] < 10)` — **a formation holds at most 10
members**, and the add silently no-ops on the 11th. The member's slot offset is computed inline:

```c
local_10[0] = (float)(idx & 1) * 2;                 // column: 0 or 2 metres
local_10[1] = 0.0;
local_10[2] = (float)(idx >> 1) * _DAT_00ff6fb0;    // row
```

That is a **two-abreast column** — a marching formation, generated rather than authored. And
`FUN_0081c110`, the engine call behind `FormationMoveToPoint`, hardcodes the move mode:

```c
(**(code **)(*piVar1 + 0x90))(param_1, -(param_3 != '\0') & 5, 0, 0, 5, 0, 1, 0, 0);
```

`FormationMoveToPoint` passes `param_3 = 1`, so `-(1) & 5` = **5** = `cMOVE_GOOSESTEP`. Formations
marched to a point goosestep by default. In a game about occupied Paris, the AI formation primitive is a
Nazi parade column, and `Nav.EnableParadePath` sits right beside it.

### `Nav` has no Lua wrapper

`Includes/` contains `WRAPPER_Actor.lua`, `WRAPPER_Event.lua`, `WRAPPER_Util.lua` and
`WRAPPER_Vehicle.lua` — and no `WRAPPER_Nav.lua`. Nothing in the corpus assigns to a `Nav` table. Scripts
call the engine-injected `Nav` table raw, which is why (unlike the `Util` family) the namespaced form here
is always exactly `Nav.` + the C++ symbol, and why there is no Lua-side layer absorbing the silent-failure
semantics described in doc 02 §6.

---

## 5. What this reveals about game logic

**The enum decoder ring is in the corpus, not the binary.**
[`Modules/__MagicNumbers.lua:22-25,87-93`](../saboteur-luacd/src/Modules/__MagicNumbers.lua#L87) defines
every constant this family consumes:

| Constant | Value | Constant | Value |
|---|---:|---|---:|
| `cPATHTYPE_ONCE` | 0 | `cMOVE_NORMAL` | 0 |
| `cPATHTYPE_LOOP` | 1 | `cMOVE_FAST` | 1 |
| `cPATHTYPE_BOUNCE` | 2 | `cMOVE_STALK` | 2 |
| `cPATHTYPE_RANDOM` | 3 | `cMOVE_PANIC` | 3 |
| | | `cMOVE_FORCERUN` | 4 |
| | | `cMOVE_GOOSESTEP` | 5 |
| | | `cMOVE_PRISONER` | **100** |

These line up exactly with the binary's range checks, and the alignment is what makes the next three
findings legible.

**`cMOVE_PRISONER = 100` is the magic number that explains `EnterFormation`'s assertion.** The one
assertion string in the family sits in a branch reachable only when arg 6 is `100`:

```c
if (iVar2 == 5) { (**(code **)(*piVar5 + 0x30))(5); return; }        // goosestep
if ((iVar2 == 100) && (FUN_0083a200() != 0)) {                       // cMOVE_PRISONER
  FUN_00db7e10("shrd_M_prisoner_march_UB1", 1);                      // hardcoded animation
  *(byte *)(iVar6 + 0x1fc) |= 4;
  pcStack_10 = "...\\Script\\Interface\\Navigation.cpp";
  pcStack_c  = "EnterFormation";
  fStack_8   = 1.88054e-42;                                          // = 1342 (see note)
  FUN_0099a660(&pcStack_10, iVar2, fStack_18, ...);
}
```

The prisoner-march mode isn't a movement speed at all — it force-plays a named animation asset
(`shrd_M_prisoner_march_UB1`) and sets a flag bit. That is why its value is 100 and not 6: it is a
different *kind* of thing wearing the move-mode enum's clothes. **No script in the corpus ever passes
arg 6**, so this whole branch — and the game's only `Navigation.cpp` assertion — appears to be dead in
the shipped scripts.

> *Reading the line number:* Ghidra prints the assertion's line-number slot as `1.88054e-42` because the
> struct field is float-typed and the integer is being punned through it. Reinterpreting the bits gives
> exactly **1342**. Line numbers are free precision — but only if you unpack the denormal.

**`Nav.SetScriptedPathMoveMode` cannot reach goosestep.** The setter range-checks `if (uVar3 < 5)`, so
0–4 are accepted and `cMOVE_GOOSESTEP` (5) is silently dropped on the floor. `Nav.MoveToPoint`,
`MoveToObject`, `FollowObject` and `BoardVehicle` all check `if (n < 0 || 5 < n) return;` instead — an
*inclusive* 0..5 — so they accept goosestep. Same enum, two different validity windows, in one family.
Every one of the 84 corpus call sites passes a boolean, which coerces to 0/1 — so the scripts only ever
select `cMOVE_NORMAL` or `cMOVE_FAST`, and "urgent" in the script layer literally means `cMOVE_FAST`.

**A callback name without a dot is silently discarded.** `Nav.MoveToObject` does not merely require a
string at arg 5 — it requires a *dotted* one:

```c
if (pcVar7 == 0 || *pcVar7 == '\0' || _strstr(pcVar7, ".") == 0) goto LAB_00735941;
```

`_strstr(name, ".")` returning null aborts the **entire binding** — not just the callback, the move order
too. This is the marshalling layer's silent-failure rule (doc 02 §6) at its sharpest: `Nav.MoveToObject(h,
t, 1, false, "MyCallback")` doesn't warn, doesn't move, doesn't fire. It just does nothing. Every corpus
call site passes `"Module.Function"` form, which is exactly the dotted convention doc 05 documents for
callback resolution.

**The `SetScriptedPath` callback index is positional and shifts.** The body computes it:

```c
iVar9 = 3;
if (argc > 2) { if (!isBool(3)) goto fail; toBool(3); iVar9 = 4; }
if (argc >= iVar9) { /* callback at iVar9 */ ... SetUserData(iVar9 + 2); }
```

So with arg 3 present the callback is arg 4, self is arg 5 and the user table is arg 6 — which is exactly
the 6-argument shape all 233 corpus call sites use. Omit arg 3 and the callback slides to index 3. It is a
hand-rolled optional-argument scheme in a layer that doc 02 §5 establishes has no default-argument
mechanism.

**Handles or names, interchangeably.** `Nav.MoveToPoint` arg 1, and `Nav.FollowObject` args 1 *and* 2,
each begin `isHandle(n) || isString(n)` and resolve the string branch through `FUN_00db7e10` before the
same `FUN_00498440` lookup. This is the workaround doc 03 predicts for handles not surviving save/load,
implemented directly in the binding rather than in a wrapper.

**`Nav.ChooseWanderPoint` is a no-op.** [Doc 06 §4](06-lua-side-wrapper-layer.md) groups it into "a
needs/wander AI layer" alongside `BroadcastNeed`/`EnableNeed`. That grouping is right about intent and
wrong about function: the binding is
fully registered — name string `"ChooseWanderPoint"` at `0x00fe26b8`, vtable at `0x00fe28e4`, stub at
`0x007372a0` — and its implementation is six bytes, `mov eax,1; ret`. The C++ body was empty, so the
compiler folded it into the `LuaGlueFunctor0` adapter's own epilogue, which is precisely why the tsv
records `shape = inlined` with `impl_va == thunk_va`. A sweep of the whole binding set finds **16 of 898
bindings are empty stubs** by this test; `Nav` contributes exactly one. Whatever wander behaviour ships in
the retail game, no script triggers it through this binding.

---

## 6. Two `Nav` calls that cannot work

[Doc 06 §5](06-lua-side-wrapper-layer.md) lists `Nav.MoveToSchedulePoint` and `Nav.SetScriptedPathMoveType`
among 46 namespaced calls with no matching binding, and leaves the disposition open: engine binding missed
by the extraction, or live script bug? For these two the question is now closed.

A binding cannot be registered under a name whose string is not in the image — `luaL_register` needs the
literal. So the name string is a necessary condition, and it is directly testable. Every genuine `Nav`
name appears at least three times in `Saboteur.exe` (the registration name, the C++ symbol, the mangled
RTTI entry):

| Name | ASCII hits in the 14.8 MB image |
|---|---:|
| `ChooseWanderPoint` | 3 |
| `SetScriptedPathType` | 3 |
| `SetScriptedPathMoveMode` | 3 |
| `FormationMoveOnPath` | 3 |
| `EnterFormation` | 4 |
| **`SetScriptedPathMoveType`** | **0** |
| **`MoveToSchedulePoint`** | **0** |

Zero hits — as ASCII, as UTF-16LE, and lowercased. **Both are live script bugs.** In Lua 5.1 each is an
`attempt to call field '...' (a nil value)` error that aborts the enclosing call.

The consequential one is [`Missions/CFP_KoenigDestroy.lua:425`](../saboteur-luacd/src/Missions/CFP_KoenigDestroy.lua#L425)
— a shipped mission, not an `Experimental/` file:

```lua
function CFP_KoenigDestroy:MechanicDoMove(a_nMode, a_hPoint)
  if a_nMode == 1 then
    Nav.MoveToObject(self.hTankMechanic, a_hPoint, 1, false, "CFP_KoenigDestroy.MechanicPickNewPt", self, {a_hPoint})
  elseif a_nMode == 2 then
    Nav.SetScriptedPath(self.hTankMechanic, self.sMechBackupPath, false, "CFP_KoenigDestroy.MechanicDoMove", self, {2})
    Nav.SetScriptedPathMoveMode(self.hTankMechanic, false)
    Nav.SetScriptedPathMoveType(self.hTankMechanic, cPATHTYPE_ONCE)   -- <-- nil
  end
end
```

The `a_nMode == 2` branch is reachable: `MechanicPickNewPt` dispatches it on a 10-second timer at
[line 392](../saboteur-luacd/src/Missions/CFP_KoenigDestroy.lua#L392), guarded by `if nAlive == 0` — i.e.
**once the player has destroyed all the tanks, which is the mission's objective.** Lines 423–424 execute
first, so the path and move mode are applied and only the path *type* is lost, along with the rest of the
function. The author appears to have conflated the two real bindings, `SetScriptedPathMoveMode` (line 424,
correct) and `SetScriptedPathType` (line 425, intended) — and note line 425 passes a `cPATHTYPE_*`
constant, which is `SetScriptedPathType`'s argument, not `SetScriptedPathMoveMode`'s.

The same function carries a second, independent typo at
[line 383](../saboteur-luacd/src/Missions/CFP_KoenigDestroy.lua#L383): `local hRndPt = a_hPrevousPoint`
reads an undeclared global (the parameter is `a_hPreviousPoint`), so `hRndPt` is `nil`.

> **Confidence: confirmed** that neither name exists in the binary and that both call sites are therefore
> nil-index errors. **Inferred** that the `a_nMode == 2` branch is reached in normal play — that reading
> comes from the script's own control flow, not from observed runtime behaviour. This resolves the `Nav`
> row of doc 06 §5's table; the other 44 orphans are untouched by this evidence and remain open.

---

## Open questions

1. **`vtable+0x194` and `FUN_0067bf70` are unnamed.** The "is mounted → retarget to the vehicle follower"
   reading (§4) is the load-bearing inference of this whole doc and rests on RTTI class names plus corpus
   usage. A single assertion string or a debugger session on a soldier entering a truck would settle it.
2. **`WSAIPathfinder`'s singleton pointer is unidentified.** `FUN_0082e270` is reached as a `__thiscall`
   whose `this` Ghidra dropped. Its structure is nonetheless informative: a **fixed pool of 6 slots**
   (`while (iVar4 < 6)`, stride `0x14`, in-use bit 0 at `+0x4c`) that returns 0 when full. So
   `Nav.CanPathfind` can silently fail under load — but the binding is `LuaGlueFunctor0`, so the return is
   discarded anyway and the *only* signal is whether the callback ever fires. Whether the 2 corpus call
   sites can exhaust the pool is untested.
3. **`SetScriptedPathSpeed`'s units are unknown.** The corpus passes 1, 120, 150 and 300 through one
   binding, to caravans and cars alike. Whether the vehicle redirect means these are interpreted against
   different scales, or whether `1` is a scripting error, is open.
4. **The trailing optional args are never exercised, so their *meaning* is open** — but their positions and
   types are read directly, and are firmer than "inferred" suggests. `MoveToPoint` args 9–11 carry explicit
   indices (`FUN_006f7140(9)`, `FUN_006f7120(10)`, `FUN_006f7140(0xb)`); `FollowObject` args 5–7 are
   recovered from the `puStack_34 = 0x5..0x7` spills; only `MoveToObject` args 8–9 are genuinely
   index-dropped (its arg 10 is gated by an explicit `9 < iStack_18`). What no evidence pins is what they
   *do*: no corpus call site reaches any of them. `MoveToPoint`'s arg 9 defaults to `5` and feeds the same
   follower `vtable+0x90` slot that `FUN_0081c110` passes `5` into — suggesting the two are the same
   parameter, but that is a guess.
5. **`EnableParadePath`'s bit has no reader identified.** It sets mask `2` of `path+0x24`; who tests it,
   and whether a parade path is a distinct path class or an ordinary one with a flag, is open. Given §4's
   goosestep finding, this is the thread most likely to lead somewhere interesting.
6. **`FUN_005a2b80` (`TreysMoveSeanToPointDangerous`) is unexamined** — why this one binding routes to a
   bespoke Sean-specific mover instead of a follower is the open question. (Its use of the `DAT_01321e38`
   map via `FUN_0067c0a0` is *not* unusual — five other `Nav` bindings do the same; doc 03's note that this
   map carries an extra `+0x18` flag gate is confirmed in `FUN_0067c0a0`'s body, but it is the family norm,
   not a `TreysMove` quirk.)
7. **Why is `ChooseWanderPoint` still registered?** An empty body that survived to retail suggests a
   feature cut late, with the binding left in so scripts calling it would not error. Whether the other 15
   empty stubs share that story is a question for a cross-family sweep, not this doc.

---

## Reproduction

```bash
# Family partition (23 rows)
awk -F'\t' 'NR==1 || $1=="Nav"' data/lua_registration_map.tsv | column -t -s$'\t'

# The family's only assertion string (1 site in 54 MB)
python - <<'PY'
import re
D = open(r'.../saboteur_all_functions_decomp.txt', encoding='utf-8', errors='replace').read()
print([f.split('\n',1)[0] for f in re.split(r'(?m)^==== ', D) if 'Navigation.cpp' in f])
PY
# NOTE: grep -F 'Script\Interface' returns 0 hits under Git Bash (backslash mangling). Use Python.

# Corpus call-site census
grep -rohE "Nav\.[A-Za-z_]+" --include=*.lua docs/saboteur-luacd/src | sort | uniq -c | sort -rn
```

The two decomp-absent bodies and the empty-stub sweep were produced with capstone against
`C:\GOG Games\The Saboteur\Saboteur.exe` (image base `0x00400000`); the stub test is a 6-byte compare
against `b8 01 00 00 00 c3` at each `impl_va`.
