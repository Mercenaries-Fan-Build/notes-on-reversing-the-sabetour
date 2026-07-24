# The Lua-side wrapper layer

> ## ⚠️ Read this first — parts of this document are superseded
>
> This doc predates **`data/lua_registration_map.tsv`**, which carries the Lua table, Lua name, C++
> symbol and VAs for all 898 bindings. It recovered the Lua↔C++ mapping heuristically, by
> *correspondence with the Lua corpus*, and that heuristic has a measurable error rate. Three of its
> named conclusions are retracted inline below (§"What this establishes" item 4, the `Squad` API
> paragraph, and the `Util.EnableTrigger` row).
>
> **Its central caveat — "the Lua-visible spelling is not in the decompiled function set, so every
> mapping here is recovered by correspondence" — no longer holds.** The Lua name is a plain `.rdata`
> C string in each registration stanza, present *twice*: for `Actor.Ragdoll` at `0x0070d6eb`,
> `c7 47 04 d0 dc fd 00` → `0x00fddcd0` = `"Ragdoll"`, and `c7 05 1c d8 42 01 d8 dc fd 00` →
> `0x00fddcd8` = a second copy. All 898 are readable this way.
>
> **The statistical claims in §3 and §4** (448 identity / 131 prefixed / 25 permuted / 122 near /
> 7 bare / 165 unreferenced, and the 165–294 dead-surface spread) are products of that same matcher.
> They should be **recomputed as a mechanical join** against the registration map, not merely
> re-tiered. Everything about the *structure* of the wrapper layer — namespace tables injected into
> `_G`, the `WRAPPER_*` modules, the require hook — is unaffected and still good.

## What this establishes

The 898 names in [`data/lua_bindings.txt`](../../data/lua_bindings.txt) are **C++ function names**, not
Lua-visible names. That single fact — which this document verifies rather than assumes — reshapes the
whole seam. The Lua side never sees a flat name. It sees ~20 namespace tables (`Util.`, `Actor.`,
`Combat.`, …) that **the engine injects into `_G` before any script runs**, and the mapping from
`Ns.Method` to a C++ binding name is **not 1:1**: it is identity for about half the surface, namespace-
prefixed for a large minority, and outright reordered or renamed for the rest.

Concretely, four things are established here:

1. The namespace tables are **engine-injected, not Lua-built** — proven by the `if not X then X = {} end`
   guard idiom, which is dead code at runtime. Lua *extends* these tables; it does not create them.
2. The name mapping has **four distinct classes**, with worked examples of each. `Util.GetHandleByName`
   *is* identity; `Actor.Ragdoll` is **not** — it is C++ `ActorRagdoll`; `Object.Despawn` is C++
   `DespawnObject`; `Util.CreateEvent` is C++ `CreateEventA`.
3. **At least 165 of the 898 bindings are unreachable from the entire 321-file corpus** — a real dead/
   debug/cut surface, listed below.
4. ⚠️ **RETRACTED 2026-07-24.** ~~**46 namespaced calls hit engine tables but have no binding in the
   898 under any mapping rule** … The 898 list is therefore **incomplete**, not merely mismatched.~~
   **The 898 list is complete; the matcher was wrong.** Of the 28 orphans this doc actually names, at
   least 5 are in `data/lua_registration_map.tsv` — **including the load-bearing example** this
   section rests on:

   | claimed orphan | actually registered as |
   |---|---|
   | `Util.SetDisableControls` | C++ `SetDisableControlsTable`, impl `0x00750110` |
   | `Actor.ExitSpecialKillMode` | C++ `PlayerKillModeCancel`, impl `0x007163c0` |
   | `Vehicle.SetupRace` | C++ `SetPlayerRoad`, impl `0x0075ffb0` |
   | `SaveLoad.ClearCheckpoint` | C++ `SaveLoadClearcheckpoint`, impl `0x00741ed0` |
   | `AttractionPt.EnableBroadcast` | C++ `AttractionPtEnable`, impl `0x00717790` |

   Root cause: this document predates `lua_registration_map.tsv` and recovered the Lua↔C++ mapping by
   *corpus correspondence*. See [`00-seam-overview.md`](00-seam-overview.md) §8.2, which reaches the
   same conclusion independently. **≈24 genuine orphans remain**, not 46.

The `.luap` container itself is solved elsewhere — see [`docs/formats/lua_scripts.md`](../formats/lua_scripts.md).
Engine-side subsystem VAs live in [`docs/symbol_map/`](../symbol_map/). This doc is the caller side only.
The registration-table region (the unexplained `0x00716a85`-class call sites) is the sibling topic that
would close the loop; at time of writing this directory contains no other files, so no sibling link is
given rather than a fabricated one.

---

## 1. Provenance: what the 898 names actually are

This is the load-bearing premise, so it is worth pinning hard.

[`docs/binary_recon.md:37`](../binary_recon.md) states the list was parsed from `LuaGlueFunctor`
templates "whose RTTI **embeds the bound C++ function name**". Three independent checks agree:

- Only **12 of the 898** appear anywhere in the decompilation as a quoted string. If these were Lua
  registration names, they would appear as string literals at a registration site; they do not.
- The ones that *do* appear are EALA assertion arguments, not registration arguments. `FUN_007411c0
  @0x007411c0` sets `local_c = "…\Script\Interface\SaveLoad.cpp"` then `local_8 =
  "SaveLoadLoadCheckpoint"` — the C++ identifier, alongside its source file.
- `"GetHandleByName"` — the single most-called binding in the corpus — appears **zero** times as a quoted
  string in the decomp, yet is in the 898.

So: the 898 are C++ symbol names. The Lua-visible spelling is assigned at the registration table, which
is not in the decompiled function set. **Every mapping below is therefore recovered by correspondence
between the corpus and the C++ names, not read directly from a registration site.** That is the central
caveat of this document.

> **Confidence: confirmed** for "the 898 are C++ names" (three converging lines: the `binary_recon.md`
> extraction method, the assertion-string context at `FUN_007411c0`, and the 12/898 string-presence
> ratio). **Open** for any individual Lua↔C++ pair below that is not marked confirmed.

---

## 2. The namespace tables are engine-injected

**The decisive evidence is a guard that never fires.** Every Lua file that touches a namespace table
opens with the same idiom:

```lua
-- Modules/Behavior/Vehicles/Vehicle.lua:1
if not Vehicle then
  Vehicle = {}
end

function Vehicle:OnEnter()
end
```

`Vehicle` is already a table when this file loads — the engine put it there — so the constructor is
skipped and the file **adds `OnEnter` to the engine's table**. The guard exists only so the file is
loadable standalone (in a tools context, or before the engine populates `_G`). The same pattern appears
at `Modules/Behavior/Triggers/Trigger.lua:1`, `Modules/Libraries/TipsLib.lua:1`,
`Modules/Libraries/ScriptSequence.lua:1`, and `Modules/Behavior/AttractionPts/AttractionPt.lua:1`.

A direct scan for global assignment across all 321 files confirms it. **`Util`, `Actor`, `Combat`,
`Object`, `Nav`, `Cin`, `Render`, `Sound`, `Suspicion`, `Inventory`, `Freeplay`, `Sensory`, `Damage`,
`HUD`, `Zone`, `Squad`, `Formation`, `SaveLoad`, `FocusPt`, `Saboteur` and `Filter` are never assigned
anywhere in the corpus** — not once. They are pure engine injections. The only apparent counter-example,
`Freeplay = {` at `Managers/GlobalMissionFile.lua:56`, is a *key inside the `gtMissionsFile` table
constructor* (the enclosing table opens at line 1), not a global — a false positive.

### The `Trigger` table is genuinely mixed

`Trigger` is the clearest demonstration that these are one shared table, not two:

| Call | Source | Side |
|---|---|---|
| `Trigger.WaitFor(...)` | `Includes/WRAPPER_Event.lua:78` | engine — `WaitFor` **is** in the 898 |
| `Trigger.CreateRestrictedArea(h)` | `Modules/Behavior/Triggers/RestrictedArea.lua:12` | engine — *not* in the 898 |
| `Trigger.OnEnter()` | `Modules/Behavior/Triggers/Trigger.lua:5` | **Lua-defined stub** |

Of 24 distinct `Trigger.*` methods the corpus calls, 12 resolve to a binding and 12 do not; four of the
latter are Lua-defined callback stubs the engine calls *back* into. So `Trigger` is simultaneously an
engine API surface and a Lua-defined behaviour interface, in one table.

### What this means for modders

**A modder cannot add a C binding from script alone.** The tables are injected; Lua can only add Lua
functions to them. But the corollary is the useful half: **any engine namespace table can be extended,
shadowed, or monkey-patched from pure Lua**, because they are ordinary globals with no protection —
no `__newindex` guard, no `readonly` metatable is set on any of them anywhere in the corpus. Overwriting
`Util.Assert` from a mod script would take effect globally. The behaviour modules already rely on
exactly this to install their `OnEnter`/`OnActorEnter` callbacks.

> **Confidence: confirmed.** The guard idiom, the zero-assignment scan, and the mixed `Trigger` table
> are all directly citable. **Inferred:** that no metatable protection exists — established by absence
> of evidence across the corpus, which is weaker than a positive proof.

---

## 3. The mapping is not 1:1 — four classes

Classifying all 898 C++ names against every `Ns.Method(` call site in the corpus:

| Class | Count | Rule | Example |
|---|---:|---|---|
| **identity** | 448 | `Ns.Method` → `Method` | `Util.GetHandleByName` → `GetHandleByName` |
| **prefixed** | 131 | `Ns.Method` → `NsMethod` | `HUD.AddObjective` → `HUDAddObjective` |
| **permuted** | 25 | token reorder | `Object.Despawn` → `DespawnObject` |
| **near** (heuristic) | 122 | token superset | `Util.Assert` → `LuaAssert` |
| bare token only | 7 | appears as a string/flat ref | — |
| **unreferenced** | **165** | no match under any rule | `BinkDemoPlay` |

**The assignment's headline question — does `Util.GetHandleByName` map 1:1 to C `GetHandleByName`? —
answers *yes, but it is the exception that misleads.*** `Util` is the most identity-shaped namespace in
the game (114 of its 123 methods are identity, exactly 1 prefixed). Generalising from `Util` to the rest
of the API is precisely the error this table exists to prevent.

### Per-namespace breakdown

Namespaces sorted by how they resolve. `PLAIN` = identity, `PREFIXED` = `Ns`+`Method`:

| Namespace | PLAIN | PREFIXED | BOTH | NEITHER | Shape |
|---|---:|---:|---:|---:|---|
| `Util` | 114 | 1 | 0 | 8 | identity |
| `Actor` | 67 | 7 | 2 | 5 | **mixed** |
| `Combat` | 54 | 2 | 0 | 11 | identity |
| `Vehicle` | 38 | 25 | 0 | 2 | **mixed** |
| `Object` | 36 | 3 | 0 | 12 | identity |
| `Suspicion` | 24 | 3 | 0 | 5 | identity |
| `Freeplay` | 20 | 0 | 0 | 1 | identity |
| `Cin` | 19 | 0 | 0 | 0 | identity (total) |
| `Render` | 19 | 0 | 0 | 3 | identity |
| `Nav` | 17 | 0 | 1 | 2 | identity |
| `Sound` | 15 | 0 | 0 | 1 | identity |
| `Inventory` | 12 | 0 | 0 | 0 | identity (total) |
| `Trigger` | 10 | 2 | 0 | 12 | mixed + Lua |
| **`HUD`** | **1** | **37** | 0 | 2 | **prefixed** |
| **`Checkpoint`** | **0** | **23** | 1 | 15 | **prefixed** |
| **`FocusPt`** | **0** | **8** | 1 | 0 | **prefixed** |
| **`AttractionPt`** | **0** | **7** | 0 | 2 | **prefixed** |
| **`SaveLoad`** | **0** | **6** | 0 | 5 | **prefixed** |

The pattern is legible: **the C++ side prefixes when the bare method name would collide across
interfaces.** `HUD.AddObjective`/`Checkpoint.New`/`FocusPt.Create`/`AttractionPt.Enable` are all verbs
generic enough to clash (`New`, `Create`, `Delete`, `Enable`, `SetDoor`), so `Script\Interface\*.cpp`
disambiguates with the interface name. Where the verb is already unique (`GetHandleByName`,
`BroadcastFunction`), it stays bare. `Actor` and `Vehicle` are mixed precisely because they are large
enough to contain both kinds — hence `Actor.GetSelf` (identity) *and* `Actor.Ragdoll` → `ActorRagdoll`.

**This retro-explains the project's own confirmed anchor.** `FUN_00714230` asserts `"ActorRagdoll"` from
`Script\Interface\Actor.cpp:0xcd5`. No script ever calls `ActorRagdoll`. The corpus calls
`Actor.Ragdoll` — because `ActorRagdoll` is the *C++* name and `Ragdoll` is the *Lua* name. The anchor
and the corpus agree once the naming rule is applied.

### The renamed class — the interesting one

These are not mechanical transforms; someone chose a different Lua name than the C++ name:

| Lua call | C++ binding | Why (inferred) |
|---|---|---|
| `Util.CreateEvent` | `CreateEventA` | **Win32 macro collision.** `CreateEvent` is a `windows.h` macro that expands to `CreateEventA`; the C++ symbol was mangled by the preprocessor, the Lua name was not. |
| `Util.Assert` | `LuaAssert` | disambiguated from the C `assert` macro |
| `Object.Spawn` | `SpawnObject` | verb/noun reorder |
| `Object.Despawn` | `DespawnObject` | verb/noun reorder |
| `Object.Actuate` | `ActuateObject` | verb/noun reorder |
| `Object.Teleport` | `TeleportObject` | verb/noun reorder |
| `Object.SpawnOnRoad` | `SpawnObjectOnRoad` | verb/noun reorder |
| `Object.SetKeyFramed` | `SetObjectKeyFramed` | noun infix |
| `Suspicion.Enable` | `EnableSuspicion` | verb/noun reorder |
| `Suspicion.EnableGlobal` | `EnableSuspicionGlobal` | noun infix |
| `Suspicion.ResetMeter` | `ResetSuspicionMeter` | noun infix |
| `Combat.Exit` | `ExitCombat` | verb/noun reorder |
| ~~`Util.EnableTrigger`~~ ⚠️ | `TriggerEnable` | **CORRECTED 2026-07-24:** `TriggerEnable` registers as **`Trigger.Enable`** (38 corpus call sites), not under `Util`. `Util.EnableTrigger` has 2 corpus sites and resolves to nothing — it is a genuine orphan, wrongly used here to "explain" a binding that belongs to another table. |
| `Vehicle.EnableTraffic` | `TrafficEnable` | reorder |
| `Object.PlayerTeleportToLocator` | `MissionTeleportPlayerToLocator` | interface renamed `Mission`→`Object` |
| `Render.HeatShimmerFilter` | `HeatShimmerFilterCallback` | suffix dropped |
| `SaveLoad.LoadTable` | `SaveLoadLoadLuaTable` | prefix + `Lua` infix |

`Util.CreateEvent` → `CreateEventA` deserves emphasis: it is the single highest-traffic event primitive
in the game (it is the engine call under nearly every `EVENT_*` wrapper in `WRAPPER_Event.lua`), and its
C++ name is an *accident of the Windows preprocessor*. Anyone matching names mechanically will miss it.

> **Confidence: confirmed** for identity/prefixed/permuted classes (448 + 131 + 25 = 604 of 898) — these
> are exact string equalities or exact token-multiset equalities against real call sites.
> **Inferred** for the whole "renamed" table above: each is a plausible-reading correspondence, not a
> read registration entry. `Util.CreateEvent`→`CreateEventA` and `Object.Spawn`→`SpawnObject` are the
> strongest (no competing candidate exists); `Object.PlayerTeleportToLocator`→`MissionTeleportPlayerToLocator`
> is weaker (the interface prefix changes, which no other example does). **Open:** all of them until the
> registration table is read.

---

## 4. Bindings never referenced from the corpus

**165 of 898 (18%) are unreachable from all 321 files** under identity, prefix, permutation, *and*
generous superset matching, and do not appear as a bare token anywhere. This is a conservative floor —
it credits every fuzzy match as "reached". Under strict matching (identity + prefix + permutation only)
the unreferenced count rises to **294**. **The true dead surface is therefore between 165 and 294.**

By family:

| Family | Count |
|---|---:|
| (misc) | 133 |
| `HUD*` | 11 |
| `FocusPt*` | 8 |
| `AttractionPt*` / `Attr*` | 8 |
| `Bink*` | 2 |
| `DEBUG*` | 2 |
| `Lua*` | 1 |

The character of the dead list is legible and falls into four groups:

**Debug/dev tooling** — never shipped in script:
`DEBUGTeleportToLocator`, `DEBUGClearStreamblockChangeListTree`, `DEBUG_DumpEvents`, `BreakpointIndex`,
`GetScriptArgNum`, `LuaHook_Require`.

⚠️ **RETRACTED 2026-07-24 — the Squad API is live, not cut.** ~~**The Squad API — an entire cut
subsystem.** … **none of those 13 resolve to any of these bindings**, which is a strong hint that
shipped `Squad` is a *different, Lua-side* table that reuses the name.~~

**All 13 called methods resolve — to exactly the bindings called dead here.** `Squad` is one of the
26 registered tables (18 bindings). The corpus's 189 call sites map cleanly:

```
Squad.AddMember    66 -> AddToSquad          Squad.Create      38 -> CreateSquad
Squad.Delete       10 -> DeleteSquad         Squad.SetEnemy    22 -> SetSquadEnemy
Squad.FollowLeader  7 -> FollowSquadLeader   Squad.ClearLeader  1 -> ClearSquadLeader
Squad.ClearBehavior 4 -> ClearSquadBehavior  Squad.SetLeader   12 -> SetSquadLeader
...  13/13 resolve, 0 orphans
```

The failure is the same one behind item 4 above: this doc matched Lua names against **C++ symbols**,
and every `Squad.*` binding is renamed at registration (`Squad.AddMember` ← `AddToSquad`, etc.).
**This also inflates the §4 "165 unreferenced" figure**, which should be recomputed as a mechanical
join against `data/lua_registration_map.tsv` rather than re-tiered. Open Q3 ("what is the shipped
`Squad` table?") is answered and withdrawn.

**A needs/wander AI layer** — `BroadcastNeed`, `EnableNeed`, `AreNeedsEnabled`, `ChooseWanderPoint`,
`AttrPtGetAllByNeed`, `FindUnseenPtFromList`, `GetSuperAttrPt`, `BroadcastScaryEvent`. `__MagicNumbers.lua:15-21`
still defines the enum this layer consumed (`cNEED_FOOD`=0 … `cNEED_HUNT`=6), so the *data* survived the
code's disuse — the classic signature of a cut feature.

**Bink demo/attract mode** — `BinkDemoPlay`, `BinkDemoCallback`. Kiosk/demo-build surface.

Plus scattered one-offs that read as cut content: `ForceMiniZepTargetPlayer`, `FreeRacer`,
`FreeRacerWhenBehind`, `EnableSporesInRegion`, `CancelExecutionScene`, `HQIsUnlocked`,
`ClearAndDeleteLastKnownPlayerVehicle`, `DrunkEffectFilterCallback`.

> **Confidence: confirmed** that these 165 are not reached by any `Ns.Method(` call or bare token in the
> corpus — it is an exhaustive scan. **Inferred** that they are "dead/cut": a binding can be called from
> a `.luap` script outside this 321-file corpus, from DLC (`DLC/01/Scripts/*.lua` ships plaintext), or by
> name-string dispatch through `StringToFileFunction` (`Includes/__UtilFunctions.lua:462`). The corpus is
> 321 of the ~323 known scripts, so the gap is small — but "unreferenced here" ≠ "unreachable".

---

## 5. Namespaced calls with no C binding — the 898 list is incomplete

The mirror list. **46 calls land on engine namespace tables, resolve to no binding under any rule, and
are not defined in Lua anywhere.** They must be engine-side, so the 898 extraction missed them:

| Namespace | Orphaned calls |
|---|---|
| `Util` | `FindObjectHandle`, `RegisterListener`, `UnregisterListener`, `ReleaseInterior` |
| `Actor` | `AddToShop`, `ExitSpecialKillMode`, `GetUserFlag`, `SetUserFlag` |
| `Combat` | `TakeCover`, `LockIntoCombat`, `SetAutoFire`, `SetFriendlyFire`, `SetInvestigate`, `SetQuestioning`, `SetQuestioningState`, `DoRandomRangedMovement` |
| `Object` | `Blip` |
| `Nav` | `MoveToSchedulePoint`, `SetScriptedPathMoveType` |
| `Render` | `WTFGetStage` |
| `Suspicion` | `Suspend`, `GetSuspicionMeterState` |
| `Freeplay` | `DisableAmbientFreeplay` |
| `HUD` | `RemoveObject` |
| `SaveLoad` | `ClearCheckpoint` |
| `AttractionPt` | `EnableBroadcast` |
| `Vehicle` | `SetupRace` |

`Util.SetDisableControls` is the load-bearing example: it is the engine call under every
`SetDisableControl` in `Includes/__UtilFunctions.lua:597-614`, which every conversation-disable helper in
the game funnels through. It is definitively engine-side, definitively called, and definitively not in
the 898 (only `GetDisableControls` and `SetDisableControlsTable` are).

This means **`data/lua_bindings.txt` is a floor, not a census.** The real binding count exceeds 898. The
likely cause is that the `LuaGlueFunctor` RTTI parse only catches bindings emitted through that one
template; bindings registered by a different mechanism (a hand-written thunk, a different functor arity)
would be invisible to it. `WSTrain::TrainGetBoardingPosition` sitting in the list with a `::` in it is a
hint that at least two emission shapes exist.

> **Confidence: confirmed** that these 46 are called and are not Lua-defined (exhaustive scan for
> `function Ns.Method(` / `function Ns:Method(` across all 321 files). **Inferred** that they are
> therefore engine bindings — the alternative is that they are calls to nonexistent functions, i.e. live
> script bugs. For most this is implausible (`Util.SetDisableControls` demonstrably works in the shipped
> game); for a few (`Object.Blip`, `Object.GetPilot`) a genuine script bug is credible, since
> `Vehicle.GetPilot` exists and `Object.GetPilot` may be a typo'd call on the wrong table.

---

## 6. What the WRAPPER_* files actually are

They are **not** the namespace layer. This is the most common misreading and the corpus refutes it
immediately: `Includes/WRAPPER_Util.lua` is 41 lines and defines exactly three flat global functions —
`WRAPPER_CheckForHandle`, `WRAPPER_CheckForHandleNil`, `WRAPPER_SanityCheck`. It defines no table.

The wrappers are a **flat, SHOUTY-prefixed convenience layer *on top of* the namespaced engine API**,
solving three concrete problems:

**(a) String-or-handle polymorphism.** The engine API demands a `userdata` handle. Designers want to type
a name. `WRAPPER_CheckForHandle` (`Includes/WRAPPER_Util.lua:1-17`) accepts either and coerces:

```lua
function WRAPPER_CheckForHandle(a_vVariable)
  local sType = type(a_vVariable)
  if sType == "userdata" then
    return a_vVariable
  elseif sType == "string" then
    local hObject = Util.GetHandleByName(a_vVariable)
    ...
```

This is the single most important function in the wrapper layer — it is why designers write
`ACTOR_WalkToObject("Sean", "Cafe")` instead of resolving handles by hand. It is called at the head of
nearly every `ACTOR_*` / `EVENT_*` / `VEHICLE_*` function.

**(b) Composition.** One wrapper call fans out to several engine calls. `ACTOR_WalkPathOnce`
(`Includes/WRAPPER_Actor.lua:62-68`) is three `Nav.*` calls plus an enum:

```lua
Nav.SetScriptedPath(hCharacter, a_sPathName, true)
Nav.SetScriptedPathMoveMode(hCharacter, false)
Nav.SetScriptedPathType(hCharacter, cPATHTYPE_ONCE)
```

The `Walk`/`Run` × `Once`/`Loop`/`Bounce`/`Random` matrix is eight near-identical wrappers over the same
three calls, differing only in the `false`/`true` move-mode and the `cPATHTYPE_*` constant.
`ACTOR_AttackTarget` (line 126) is `Combat.SetTarget` + `Combat.SetCombat`. `EVENT_FadeInOut` (line 496)
composes `Render.FadeTo` with a `Util.CreateEvent` timer.

**(c) Event-struct construction.** `WRAPPER_Event.lua` is 712 lines and is essentially one idea repeated
~30 times: turn a named helper into a `Util.CreateEvent` call with a hand-built descriptor table. Every
`EVENT_*` function has the same skeleton:

```lua
local eEvent = Util.CreateEvent({EventType = "DeathEvent", ObjectHandle = a_vActor},
                                a_sCallbackFunction, self, tUserTable)
if self and self._SELFTABLE_ID then
  self:RegisterEvent(eEvent)
end
return eEvent
```

The `EventType` string is the real dispatch key into the engine. The corpus reveals the vocabulary:
`TimerEvent`, `DeathEvent`, `OnDamage`, `ProximityEvent`, `StreamEvent`, `OnVehicleEnter`,
`OnVehicleExit`, `EnteredVehicleEvent`, `OnCombatEnter`, `OnHuntFail`, `OnHuntSuccess`,
`OnInvestigateFail`, `OnInvestigateSuccess`, `OnWeaponFire`, `OnEscalation`, `OnEscalation0`,
`OnEscalationLite`, `OnSeatLocked`, `SeatEmptyEvent`, `SeatChangedEvent`. The descriptor keys vary by
type (`ObjectHandle`, `Target`, `ObjectA`/`ObjectB`/`Proximity`/`Check3D`/`Negate`, `Objects`/
`WaitForGameObject`/`WaitForStreamOut`, `Vehicle`/`SeatName`/`Passenger`).

**`_SELFTABLE_ID` is the lifetime mechanism** (53 references corpus-wide). If the caller passes a `self`
carrying `_SELFTABLE_ID`, the wrapper registers the event against it so it can be torn down with the
mission. `ScriptSequence.Run` explicitly *rejects* such tables — `Modules/Libraries/ScriptSequence.lua:12`
asserts `"It's dangerous to pass mission self tables to ScriptSequences!"`.

### Bugs visible in the shipped wrapper layer

The decompiled corpus preserves real defects, worth knowing before trusting a wrapper:

- **`ACTOR_FaceObject`** (`Includes/WRAPPER_Actor.lua:31-37`) resolves `hTarget` from `a_vCharacter`, not
  `a_vTarget` — the target argument is silently ignored, so an actor is told to face itself.
- **`ACTOR_WalkPathBounce`** (line 94) takes parameter `a_sPathname` (lowercase `n`) but passes
  `a_sPathName` (uppercase) to `Nav.SetScriptedPath` — a global nil read. Its seven sibling functions
  spell it correctly.
- **`VEHICLE_UnboardAllNotGunner`** (`Includes/WRAPPER_Vehicle.lua:56-57`) assigns both `tPassengers` and
  `tPilot` from `tOccupants.Passengers`, so the "not gunner" filter cannot work as named.
- **`EVENT_PlayerToActorProximity`** (`WRAPPER_Event.lua:220`) reads a global `hSab` that the function
  never defines — unlike `EVENT_PlayerEntersTrigger` (line 167) which correctly does
  `local hSab = WRAPPER_CheckForHandle("Saboteur")`. Several `EVENT_Player*` functions depend on `hSab`
  being set globally elsewhere.
- **`EVENT_ActorEntersCombat`** (line 397) builds `tUserTable` by type-testing `a_vActor` instead of
  `a_tUserTable` — the user table is discarded.

> **Confidence: confirmed** — all are direct reads of cited lines. Note the corpus is *decompiled*
> bytecode; a decompiler can in principle mangle a variable name. But `a_sPathname`/`a_sPathName` differ
> across sibling functions in one file, which a decompiler would not invent, and `LuaScripts.luap` ships
> with debug info intact (per [`docs/formats/lua_scripts.md`](../formats/lua_scripts.md)), so names are
> recovered rather than synthesised.

---

## 7. The inheritance idiom

The behaviour scripts are built on **single-inheritance via `setmetatable(Child, {__index = Parent})`** —
61 uses across the corpus, always this exact shape. `Experimental/ScriptHelper.lua` is the canonical
example and shows the whole idiom in nine lines:

```lua
if not ScriptHelper then
  ScriptHelper = {}
  if AttractionPt == nil then
  end
end
setmetatable(ScriptHelper, {__index = AttractionPt})

function ScriptHelper:OnEnter()
  self.bEnabled = true
end
```

Note the vestigial `if AttractionPt == nil then end` — an empty guard whose body was removed, leaving the
test. It is a fossil of the same "engine-injected, don't clobber" defensive pattern seen in §2.
`ScriptHelper` inherits from `AttractionPt`, which is an **engine-injected table** — so this is Lua code
inheriting from an engine class. `ScriptHelper:PrintToConsole` calls `Util.GetNameFromHandle(self.hController)`,
telling us instances carry an `hController` handle field bound by the engine.

The resulting hierarchy is shallow and real:

```
AttractionPt (engine)
  └── ScriptHelper
        ├── TriggerWatcher
        └── UsePathAction
Trigger (engine)
  ├── RestrictedArea → RestrictedAreaPed, RestrictedAreaVeh
  ├── SuspicionZone  → SuspicionZonePed, SuspicionZoneVeh
  ├── RedZone, RoadBlockZone, WorldBorder
InteriorManager (Lua)
  ├── Zeppelin_Int, SaarHQ_Interior, …  (one per interior)
MissionStarter (Lua)
  ├── Vendor, Shopkeeper
Soldier (Lua)  └── Resistance
IdleCiv (Lua)  └── testCrossingGuard
```

Two instantiation styles coexist. `Includes/List.lua:5-12` uses the classic Lua idiom (with a latent
bug — `self.__index = self` and `first`/`last` are set on the *class*, not the instance, so two `List`
instances share cursors). `Includes/__UtilFunctions.lua:679-686` (`ConvManager.Create`) uses a
`setmetatable(self, {__index = o})` variant that writes to a global `self` before returning it.

> **Confidence: confirmed** — the hierarchy is extracted by scanning all `setmetatable(X, {__index = Y})`
> sites. **Inferred:** that `__index` inheritance from `AttractionPt`/`Trigger` works because the engine
> instantiates these as prototypes — consistent with `self.hController` but not directly proven.

---

## 8. Enum tables and the ScriptSequence sub-language

**`Modules/__MagicNumbers.lua`** (301 lines) is a flat wall of globals — no table, no namespace, every
constant straight into `_G`. It is the shared enum vocabulary between designers and the engine, and its
families map onto engine concepts: `cTEAM_*` (5), `cPATHTYPE_*` (4, consumed by `WRAPPER_Actor.lua:67`),
`cSTATE_*`, `cTARGET_*` (10), `cMUSIC_*` (8), `cTRIGGEREVENT_*` (4, consumed by `WRAPPER_Event.lua:78`),
`cNEED_*` (7 — the cut needs layer, §4), `cHTM_*` (20 HUD templates), `cT*` (41 HUD screens),
`cMESSAGETYPE_*`, `eSAB_ITEM_*`, `cEXECUTION_*`.

Two sub-vocabularies deserve note. **Aliases encode design intent**: `cMESSAGETYPE_SKYLAR =
cMESSAGETYPE_LACE`, `cMESSAGETYPE_BISHOP = cMESSAGETYPE_TELEGRAM` (lines 280-288) — per-character
message styling collapsed onto shared art. And **the input tokens are strings, not numbers**:
`cSOLDIER_MOVE_FORWARD = "<SMF>"`, `cVEHICLE_HONK = "<VHK>"` (lines 216-270) — an angle-bracketed
three-letter code, presumably parsed engine-side.

**`Modules/__MissionTypes.lua`** is tiny by contrast — 11 lines, and it is a *tuning* file rather than an
enum: `cMission_Gather`=1/`cMission_Assassinate`=2/`cMission_SearchDestroy`=3 plus timing
(`cTime_Event_Duration`=45) and frequency weights. **The weights tell a story**:
`cEvent_Frequency_Gather = 100` while `Assass`, `SAndD`, and `Others` are all **0** — of three declared
mission types, two are weighted out entirely.

**`ScriptSequence`** deserves flagging as a *separate string-keyed sub-language* nested inside the seam.
`ScriptSequence.Run(hCharacter, tSequence)` takes a table of `{VERB, {args}}` pairs dispatched by string
compare (`Modules/Libraries/ScriptSequence.lua:172`, `:178`, `:788`). The verb vocabulary includes
`WALKTOPOINT`, `RUNTOPOINT`, `WALKTOOBJECT`, `RUNTOOBJECT`, `WALKTORANDOM`, `RUNTORANDOM`,
`WALKPATHONCE`, `WALKPATHONCE_NOWAIT`, `RUNPATHONCE`, `RUNPATHONCE_NOWAIT`, `WALKPATH`, `FOLLOWOBJECT`,
`ENTERSEAT`, `STREAMEVENT`, `ENDSEQUENCE`, `NONE`. `ACTOR_BoardVehicle` (`WRAPPER_Actor.lua:177-191`)
builds one of these tables inline. This is a third API style — after "flat C bindings" and "namespaced
tables" — and it is implemented **entirely in Lua** (28 of its 30 methods resolve to no binding).

**`Includes/__SabMissionIncludes.lua`** is the load order, and it is worth reading as the dependency
graph of the whole script layer: `__UtilFunctions` → `List` → `SabTask` → the five Managers → the seven
`SabTask*` modules → the four `WRAPPER_*` files → `WorldSMEDNodes` → `GlobalMissionFile`. Note the
wrappers load **late** — after the managers that they do not depend on, but before the mission files that
do. Every file is `require`-guarded by a `__SENTINEL == nil` check (line 1), the same
idempotent-include idiom as the namespace guards.

> **Confidence: confirmed** — all read directly from the cited files.

---

## Open questions

1. **The registration table remains the missing link.** Every Lua↔C++ pair in §3 outside the identity
   class is a correspondence *argument*, not a *reading*. The registration region (call sites near
   `0x00716a85`/`0x00716b25`, inside no exported function, after `FUN_007166a0` ends ~`0x007166e3`)
   should contain `(namespace, name, fnptr)` triples. Reading it would convert ~450 inferred pairs into
   confirmed ones and would settle §5 outright. **This is the highest-value next step for the seam.**
2. **Why is `data/lua_bindings.txt` incomplete?** 46 demonstrably-live engine calls are absent. Does the
   `LuaGlueFunctor` RTTI parse miss a template arity, or is a second registration mechanism in play? The
   presence of `WSTrain::TrainGetBoardingPosition` (class-qualified) among otherwise-bare names suggests
   at least two emission shapes. Re-running the extraction with a widened pattern would test this.
3. **What is the shipped `Squad` table?** The corpus calls `Squad.*` 189 times across 13 methods; the
   `CreateSquad`/`AddToSquad`/`AddSquadObjective` binding family is 100% unreferenced; and the 13 called
   methods match none of them. Either `Squad` is a Lua table defined outside this corpus, or the calls
   are dead. Not resolved here.
4. **How are namespace tables actually injected?** Nothing in the corpus creates them, so the engine
   does — but whether via `lua_setglobal` per table at VM init, or lazily through
   `FUN_006f96e0`/`DAT_0142d324` (the lazily-created VM/manager singleton noted in the project anchors),
   is unestablished. This determines whether a mod script can reliably patch a table at load time.
5. **Is `hSab` engine-set?** Several `EVENT_Player*` wrappers read a global `hSab` they never define,
   while their siblings define it locally. Either the engine pre-sets `hSab`, or those wrappers are
   broken. Both readings fit the corpus; `__UtilFunctions.lua:173` (`Actor.GetSelf(hSab)`) reads it
   globally too, which mildly favours engine-set.
6. **Is the dead surface 165 or 294?** The spread is entirely due to whether the heuristic "near" class
   (122 bindings) represents real renames or coincidental token overlap. Only the registration table
   settles this.
7. **DLC scripts are outside this corpus.** `DLC/01/Scripts/*.lua` ships plaintext and is not part of the
   321 files analysed. Some "unreferenced" bindings may be live there. Cheap to check; not done here.
8. **`Object.GetPilot`/`Object.Blip` — binding or bug?** `Vehicle.GetPilot` exists and resolves; the
   `Object.` spelling does not. This may be a shipped script bug rather than a missing binding.

## Confidence summary

| Claim | Tier |
|---|---|
| The 898 are C++ names, not Lua names | **confirmed** |
| Namespace tables are engine-injected; Lua only extends them | **confirmed** |
| Modders cannot add bindings from script; can freely patch existing tables | **confirmed** / inferred (no metatable protection) |
| Mapping is not 1:1; identity + prefixed + permuted = 604/898 | **confirmed** |
| `Util` is identity (114/123) but is unrepresentative | **confirmed** |
| Prefixing is driven by cross-interface name collision | **inferred** (strong: fits all 131 cases) |
| The specific renames (`CreateEventA`, `SpawnObject`, …) | **inferred** |
| ≥165 of 898 unreferenced in the corpus | **confirmed** (as "not referenced"); **inferred** as "cut/dead" |
| 46 live calls have no binding → the 898 list is a floor | **confirmed** (calls + absence); **inferred** (that all 46 are engine-side) |
| `WRAPPER_*` are a flat layer over the namespaced API, not the namespace layer | **confirmed** |
| Wrapper bugs (`ACTOR_FaceObject`, `ACTOR_WalkPathBounce`, …) | **confirmed** |
| `setmetatable(C, {__index = P})` hierarchy; Lua inherits from engine tables | **confirmed** |
| Enum/tuning tables and the `ScriptSequence` verb sub-language | **confirmed** |
