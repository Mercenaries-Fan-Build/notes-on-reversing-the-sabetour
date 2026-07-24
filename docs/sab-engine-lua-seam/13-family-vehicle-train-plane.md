# Family 13 — Vehicle / Train / Plane / Racer / MiniZep

> **Verified:** re-checked all 125 rows against `data/lua_registration_map.tsv`, every claimed VA
> against the decomp, all 19 ILT stubs byte-level against `Saboteur.exe`, and every corpus citation.
> The ILT resolutions (19/19 byte-exact), the RTTI 898 = 867 + 31 `WSTrain` partition, the
> `Script\Interface\Vehicle.cpp:2912` assertion, the `WSTrain` offsets, the 15 dual-type bindings and
> **all ~115 table citations and call-site counts** verified exact — no fabrications. Corrected: two
> rows refuted byte-level (`Util.AddSplinePlaneAttackLocation` is 12-arg not 1-arg;
> `Vehicle.GetOccupantList` does take a handle), the registrar counts (**29 = 19 + 10**, not 30 = 19 + 11),
> "four" flag-write verbs (seven), and the "10 with no body" story — **7 are `inlined`, 3 are export
> gaps**, and three of the seven are complete do-nothing stubs, which kills a live `WRAPPER_Vehicle`
> code path. Coverage re-tiered 92/30/3.
> **Confidence: high** for the structural claims and the table; see Open questions for what remains.

The driving-and-rails corner of the engine↔Lua seam: 125 bindings covering road vehicles, traffic,
the race minigames, the DLC train system, the MiniZep airship, and the Luftwaffe strafing runs.

Read [02-marshalling-abi.md](02-marshalling-abi.md) first — this doc assumes the primitives
(`FUN_006f71a0` = "arg *n* is a handle", `FUN_006f7160` = "arg *n* is a string", …) and the
`LuaGlueFunctor0` / `LuaGlueFunctor0R` return contract. Engine-side internals for the same subsystem
live in [../symbol_map/vehicle-train.md](../symbol_map/vehicle-train.md); this doc is the *seam* view
(what script can call, with what arguments) and deliberately does not re-derive the simulation.

## Inclusion rule (auditable)

`data/lua_registration_map.tsv` resolves every binding to a `table` — the real Lua-visible namespace,
read byte-level from the registration stanzas. The boundary is drawn on that column, **not** on the
spelling of the C++ symbol:

1. every row with `table == "Vehicle"` (80) — this sweeps in the whole Racer/race API, which is
   registered into `Vehicle`, not a table of its own;
2. every row with `table == "Train"` (31);
3. every row with `table == "Util"` whose `cpp_symbol` contains `Plane` or `MiniZep` (14).

**125 rows.** Rule 3 is the one judgement call: there is **no `Plane` table and no `MiniZep` table**.
Those bindings are registered flat into `Util` alongside 159 unrelated ones. I claim them here because
the assignment names them and because `Util` is far too large to be a coherent family; the sibling
`Util` doc should cite this file rather than duplicate the rows.

Deliberately **excluded** — vehicle-*flavoured* names that the tsv puts in another table, and which
belong to that table's family doc. Listed so the omission is not silent:

| Row | Table | VA | Ceded to |
|---|---|---|---|
| `BoardVehicle` | `Actor.BoardVehicle` | `0x00711a40` | Actor — and it carries the family's *other* assertion string, `Script\Interface\Actor.cpp:1371` |
| `UnboardVehicle`, `PullFromVehicle`, `GetVehicle`, `IsInVehicle`, `SetVehicleAvoidance`, `SetBailWhenVehicleOnFire` | `Actor.*` | `0x00711be0`, `0x00711cd0`, `0x00711ff0`, `0x00711ed0`, `0x00713b20`, `0x00714b20` | Actor |
| `ObjectIsVehicle`, `SpawnInVehicle` | `Object.*` | `0x00738b80`, `0x0073c480` | Object |
| `NavBoardVehicle` | `Nav.BoardVehicle` | `0x00735f30` | Nav |
| `CheckpointSetIgnoreVehicles`, `CheckpointSetRequiredVehicle`, `CheckpointSetVehicleChecker` | `Checkpoint.*` | `0x0071abb0`, `0x0071ace0`, `0x0071a9d0` | Checkpoint |
| `SetIgnoreCombatInVehicle` | `Combat.*` | `0x00722850` | Combat |
| `EnableEscalationVehicles`, `OverrideEnableEscalationVehicles` | `Suspicion.*` | `0x00747070`, `0x007470e0` | Suspicion |
| `ClearAndDeleteLastKnownPlayerVehicle` | `Util.*` | `0x00758430` | Util (no `Plane`/`MiniZep` token; rule 3 does not reach it) |

## Coverage honesty

**125 of 125 located, 92 confirmed, 30 inferred, 3 not found** — every row has a table, Lua name, VA
and return contract read byte-level from the exe. The tiers below grade the *argument signature*,
which is what actually needed deriving:

- **92 confirmed** — body read *and* corroborated by ≥1 real call site in the Lua corpus (or, for the
  three retail stubs below, complete byte-level).
- **30 inferred** — body read, but **no call site anywhere in the 321-file corpus**. Proposals.
- **3 open** — **not found in the decomp export**; no body to read. Signature not derived.

On *identity* — what pins the name to the VA — the family is thinner than the table suggests:

- **1 of 125 carries an assertion string**: `Vehicle.StartPlayback @0x00762fa0` embeds
  `…\WildStar\Script\Interface\Vehicle.cpp` with `uStack_4 = 0xb60` (= line **2912**) and the literal
  `"StartPlayback"`. Verified in the decomp body.
- **10 of 125 self-name via a dotted string literal**: the race callbacks each pass their own Lua-visible
  name to `FUN_007627d0` (`"Vehicle.SetRaceStartCallback"`, …). These are exactly the ten
  `"Vehicle.*"` string literals in the whole 54 MB decomp, so their identity is *self-evidencing* and
  does not rest on the tsv.
- **The other 114 rest on the registration map alone.** The assertion idiom does not rescue this
  family; the corpus and those ten literals do.

### The 3 with no body — and the 7 that do have one

Only **three** rows are genuinely absent from the export, and all three are `shape=jmp`:
`Train.TrainGetBoardingPosition @0x006245c0`, `Train.TrainIsStreamedIn @0x0061f500`,
`Vehicle.IsNaziVehicle @0x00763c20`. Their VAs are real code — `TrainIsStreamedIn` begins
`8b 0d 24 d3 42 01` (`mov ecx,[0x0142d324]`), the script-manager singleton load that opens every
binding — so this is a **gap in the Ghidra export, not a bad tsv row**.

The other seven are `shape=inlined` (`impl_va == thunk_va`), and "inlined" does **not** mean
unreadable: each is a short, complete function the exporter simply never emitted. Read byte-level:

- `Util.RemovePlane @0x0075b380` (30 bytes), `Util.KillPlane @0x0075b3a0` (28),
  `Util.ClearMiniZepSpline @0x0075b440` (21), `Util.KillMiniZep @0x0075b460` (28) — each loads a
  singleton, calls one or two helpers, ends `b8 01 00 00 00 c3` (`mov eax,1; ret`). **None calls any
  `FUN_006f7…` argument primitive**, so all four are `() -> ()`. `ClearMiniZepSpline()` and
  `KillMiniZep()` are called with empty parens in the corpus, corroborating.
- `Vehicle.GetNextExitSeat @0x00763f60` and `Vehicle.CanPassengerGetOut @0x00763fa0` are
  **`33 c0 c3`** — `xor eax,eax; ret`, followed by `cc` padding. `Vehicle.ChangeSeat @0x007640c0` is
  **`b8 01 00 00 00 c3`** — `mov eax,1; ret`. These three are **complete do-nothing stubs in retail**:
  they read no arguments and push no results. See "the dead seat-shuffle path" below.

### Two corrections to the tsv, for this family

**1. 19 Train `impl_va`s point at incremental-link (ILT) jump stubs, not bodies.** The byte at those
VAs is `E9` (`jmp rel32`). `TrainStart`'s `impl_va` is `0x0061f210`, whose five bytes are
`e9 5b 6c 00 01` — i.e. `0x0061f210 + 5 + 0x00016c5b` = the real body at **`0x01625e70`**, out in the
high `.text` range where the incrementally-linked code lives. Ghidra folds these stubs away, which is exactly
why `FUN_0061f210` "doesn't exist" in the decomp. All 19 are Train; **zero** Vehicle or Util rows are
stubbed. The `VA` column below gives the resolved body and notes the stub. Anyone grepping the decomp
by tsv `impl_va` for a Train binding will get a false negative without this step.

**2. Do not read a `Train.*` name off `lua_bindings.txt`.** See next section.

## Why `lua_bindings.txt` says `WSTrain::TrainSuperCull`

The flat list carries 31 entries with a literal `WSTrain::` prefix. This is **not a different
registration shape** — it is a demangling artifact, and the tsv already normalises it away.

Every binding is an instantiation of `LuaGlueFunctor0<&F>`, and MSVC emits an RTTI type descriptor
per instantiation whose mangled name embeds `F`'s own symbol. Scanning all
`.?AV?$LuaGlueFunctor0…` descriptors in `Saboteur.exe` partitions **898 = 867 + 31**:

| Descriptor form | Count | Meaning |
|---|---:|---|
| `.?AV?$LuaGlueFunctor0@$1?AddPlane@@YAXPAUlua_State@@@Z@@` | 867 | `@@YA` — **free function**, `__cdecl`, global scope |
| `.?AV?$LuaGlueFunctor0@$1?TrainSystemEnable@WSTrain@@SAXPAUlua_State@@@Z@@` | 31 | `@@SA` — **static member function of class `WSTrain`** |

The class-qualified 31 are *exactly* the Train set, and `WSTrain` is the only class that appears —
no other subsystem wrote its Lua glue as class statics. So `WSTrain::` is the C++ scope leaking
through whatever demangler produced `lua_bindings.txt`; it says something about how the train code
was organised, and nothing about how it is registered. (This corroborates, from the RTTI side, the
`?...@WSTrain@@SAX...` observation already recorded in
[../symbol_map/vehicle-train.md](../symbol_map/vehicle-train.md).)

Downstream the 31 are utterly ordinary: `family=LuaGlueFunctor0`, `shape=adapter`, same 32-byte
thunk, same 84-byte stanza, inserted into the same per-table registry as everything else.

**The Lua-visible name keeps the stutter.** The table is `Train` and the name is `TrainCreate`, so
scripts really do write `Train.TrainCreate` — confirmed 11× in the corpus, e.g.
[Act_1_Farm.lua:1092](../saboteur-luacd/src/Missions/Act_1_Farm.lua). The prefix that looks redundant
is load-bearing: strip it and the call breaks. One name is *not* a straight copy —
`TrainRegisterTrainDecoupledCallback` (the C++ symbol, and what `lua_bindings.txt` lists) registers as
**`Train.TrainRegisterDecoupledCallback`**. Read the tsv.

## How the subsystem actually works

### Two different addressing models, in one family

This is the family's defining fact, and it cuts across the Vehicle/Train line.

**Vehicle is handle-addressed**, like Actor — but through a *different map*. Where `Actor.Ragdoll`
resolves via `FUN_004436f0` under `DAT_0143db28`, every Vehicle binding calls **`FUN_0067c0a0`**, the
second map at `DAT_01321e38` with the extra `+0x18` flag gate (ABI §7). `Vehicle.GetSpeed @0x0075da10`
is the whole pattern in nine lines:

```c
cVar1 = FUN_006f71a0(1);                  // arg 1: handle
if (cVar1 != '\0') {
  uVar3 = FUN_006f6ec0(1);                // fetch it
  iVar2 = FUN_0067c0a0(uVar3);            // vehicle map, NOT FUN_004436f0
  if ((iVar2 != 0) &&
      (iVar2 = (**(code **)(... + 0x194))(), iVar2 != 0)   // vtable+0x194 -> vehicle component
      && (*(int *)(iVar2 + 0x1390) != 0)) {
    FUN_006f7060(*(undefined4 *)(*(int *)(iVar2 + 0x1390) + 0x9b4));   // push speed
    return 1;
  }
}
return 0;                                 // silent: 0 results
```

`vtable+0x194` recurs in nearly every Vehicle binding and is the family's signature move — *inferred*
to be the object→vehicle-component accessor, from usage only. `+0x1390` is a sub-object that must be
non-null (a physics/virtual-vehicle pointer, **open**), and speed lives at `+0x9b4` within it.

**Train is name-addressed.** No handle, no map. Arg 1 is the **track-spline path string**, and it is
resolved by a helper unique to this family, `FUN_01625950` (always reached via `thunk_FUN_01625950`):

```c
cVar1 = FUN_006f7160(param_3);        // arg N must be a string
if (cVar1 == '\0') { /* type-name ladder */ return -1; }
uVar2 = FUN_006f7a80(param_3);        // fetch it
FUN_00db7e10(uVar2, uVar4);           // copy out of Lua ownership (ABI §8)
iVar3 = FUN_0096b980(param_1);        // name -> train INDEX
return (iVar3 < 0) ? -1 : iVar3;
```

That index then goes through **`FUN_0096ba30`**, a bounds-checked array lookup
(`param_2 < *(int *)(param_1 + 0x34)`) returning the `WSTrain*` — the train-system analogue of the
handle map. Scripts therefore pass the same long literal path to every call:

```lua
Train.TrainCreate("CountrySide\\champagneardennes\\traintracks\\DTrain_TEST", "Dtrain3")
Train.TrainSetMaxSpeed("CountrySide\\champagneardennes\\traintracks\\DTrain_TEST", "28")
```
— [Act_1_Farm.lua:1092-1093](../saboteur-luacd/src/Missions/Act_1_Farm.lua)

The failure path in `FUN_01625950` is worth a note: it calls all eight type predicates
(`FUN_006f7100`/`7120`/`7140`/`7160`/`71a0`/`71c0`/…) in sequence and discards the results. That is a
type-*name* lookup ladder for a diagnostic message — the same shape as `FUN_00707516` in ABI §5 — and
in retail the message goes nowhere. It still returns `-1`, and `FUN_0096ba30(-1)` fails the
`-1 < param_2` bound and returns 0, so **a typo'd track path is a silent no-op**, consistent with the
rest of the seam.

**And the family mixes both models.** Train *system* verbs take the path string; Train *carriage*
verbs take a handle, because a carriage is a real world object with a proxy:

```lua
Train.TrainDecoupleCarriage(self.tCarriageHandles[11])              -- SOE_2_Mission_2.lua:480
Train.TrainRegisterPlayerCarriageTriggerCallback(TrainMGR.tTrainStructs[sID][i], ...)
```
`TrainDecoupleCarriage @0x00624500` is a textbook Actor-style body — `FUN_006f71a0(1)` →
`FUN_006f6ec0(1)` → `EnterCriticalSection(DAT_0143db28)` → `FUN_004436f0` — i.e. the *first* map,
the one Vehicle never uses. Three maps are live in this one family.

### The WSTrain control block

Seven Train verbs write the `WSTrain` control block at fixed offsets — five of them pure one-byte
flag writes with a literal — which pins a small struct region **confirmed** by seven independent bodies:

| Offset | Written by | Value | Meaning |
|---|---|---|---|
| `+0x00dd` | `TrainCull @0x004ec5b0` | `1` | cull request |
| `+0x00de` | `TrainSuperCull @0x0068ae50` | `1` | super-cull request (distinct byte — the two are not the same flag) |
| `+0x1848` | `TrainSetStopAtStation @0x01626160` | arg 2 (bool) | stop-at-station |
| `+0x1850` | `TrainStart @0x01625e70` → `0`<br>`TrainStop @0x01625fc0` → `1` | | **stopped** (note the polarity: Start clears it) |
| `+0x1851` | `TrainUseTrackMaxSpeed @0x01626090` → `1`<br>`TrainSetMaxSpeed @0x0061f390` → `0` | | use-track-max-speed |
| `+0x1854` | `TrainSetMaxSpeed @0x0061f390` | arg 2 (float) | max speed |

`TrainSetMaxSpeed` writing **both** `+0x1851 = 0` and `+0x1854 = speed` is the interesting one: setting
an explicit speed *implicitly disables* track-authored speed limits, and `TrainUseTrackMaxSpeed` is the
one-way ticket back. They are two halves of one switch, and script must not assume independence.

`TrainSystemEnable @0x01625d80` takes no train at all — `FUN_006f7120(1)` → `FUN_006f6e60(1)` →
`FUN_0096bc20(bool)`, a global toggle. It is used to suppress the whole rail system during interiors
([InteriorManager.lua:548,569](../saboteur-luacd/src/Managers/InteriorManager.lua)).

`TrainSetCurrSpeed @0x006231c0` is a quiet anomaly: it resolves the train (`FUN_0096ba30`), checks
`iVar2 != 0` — then calls `FUN_0061fb20(0, speed)`, passing a literal **`0`**, not the train it just
resolved. The resolve is used only as a guard. Either the current-speed setter is global-by-design or
this is a bug; it has exactly one call site
([SOE_2_Mission_2.lua:945](../saboteur-luacd/src/Missions/SOE_2_Mission_2.lua)) and I cannot tell which
from static evidence. **Open.**

### The dead seat-shuffle path

The three retail stubs are not cut content nobody calls — `WRAPPER_Vehicle.lua` still drives all three,
and the byte-level reading says the path cannot work
([WRAPPER_Vehicle.lua:64-89](../saboteur-luacd/src/Includes/WRAPPER_Vehicle.lua)):

```lua
function _VEHICLE_OnSeated(self, a_hVehicle, a_hPassenger, a_sCallback, a_tCallbackParams)
  if Vehicle.CanPassengerGetOut(a_hVehicle, a_hPassenger) then   -- 33 c0 c3 -> 0 results -> nil -> FALSE
    _VEHICLE_Exit(...)                                            -- never taken
  else
    local hNextSeat = Vehicle.GetNextExitSeat(a_hVehicle, a_hPassenger)  -- 33 c0 c3 -> nil
    if hNextSeat then ... else print("NoNextSeat!") end           -- always "NoNextSeat!"
```

`CanPassengerGetOut` is `LuaGlueFunctor0R`, so its `eax` **is** the result count: `xor eax,eax`
returns **zero results**, which Lua reads as `nil`, so the `if` is unconditionally false. The `else`
branch then calls `GetNextExitSeat`, also `…0R` and also `33 c0 c3`, so `hNextSeat` is always `nil` and
the function always falls through to `print("NoNextSeat!")`. `Vehicle.ChangeSeat` (`mov eax,1; ret`) is
worse in a quieter way: as `LuaGlueFunctor0` it *claims* one result while pushing none, and does
nothing at all. Whatever passenger-reseating feature these four wrapper functions were written against
was stubbed out before ship, and the Lua was left behind. **Confirmed** byte-level; the arguments the
call sites pass are read by nothing.

### Dual-type argument 1 — `handle OR string`

Fifteen Vehicle bindings accept **either** a handle or a name string in arg 1, via an explicit
`||` and a re-check — `AddToTraffic`, `Crash`, `EnableInput`, `FreeRacer`, `FreeRacerWhenBehind`,
`RemoveFromTraffic`, `RemoveRacer`, `SetCrashThrough`, `SetForceNeverFlip`, `SetForceSelfRight`,
`SetRacerRoad`, `SetRacerSpeed`, `SetRacerTarget`, `TurnHeadlightsOff`, `TurnHeadlightsOn`.
`Vehicle.AddToTraffic @0x0075e990`:

```c
if ((cVar1 = FUN_006f71a0(1), cVar1 != '\0') || (cVar1 = FUN_006f7160(1), cVar1 != '\0')) {
  if (FUN_006f71a0(1) == '\0') {          // not a handle -> must be a string
    uVar6 = FUN_006f7a80(1);
    FUN_00db7e10(uVar6, 1);               // copy out
  } else {
    uVar5 = FUN_006f6ec0(1);              // handle path
  }
  iVar4 = FUN_0067c0a0(uVar5);            // both converge on the vehicle map
  ...
```

This is a genuine convenience overload, and the corpus exercises **both** branches — sometimes in one
call. Racers are identified by *name string*, while their vehicle is a handle:

```lua
self.tInfo.Javier = "Missions\\act_1\\racetogermany\\javier\\javier_race"   -- :69, a STRING
...
Vehicle.AddRacer(self.tInfo.Javier, Handle(self.tInfo.RaceCar), "RaceToGermany", 0, 90, 100)  -- :413
Vehicle.RemoveRacer(self.tInfo.Javier)                                                        -- :445
```
— [Act_1_RaceToGermany.lua:69,413,445](../saboteur-luacd/src/Missions/Act_1_RaceToGermany.lua).
Arg 1 goes in as a raw path string; arg 2 is explicitly wrapped in `Handle(...)` because *it* has no
string branch. Elsewhere the same bindings take handles —
`Vehicle.SetRacerSpeed(a_tDude[1], …)` ([Act_1_Race.lua:582](../saboteur-luacd/src/Missions/Act_1_Race.lua)) —
and `Vehicle.SetRacerRoad(a_sRacer, "ParisGPCrash")`
([Act_3_Mission_1.lua:531](../saboteur-luacd/src/Missions/Act_3_Mission_1.lua)) takes the string. The
Hungarian prefixes (`a_sRacer` vs `a_hTruck`) track the distinction reliably.

No call site passes a *literal* string in arg 1 — always a variable — so the branch is only visible
from the decomp; the corpus confirms the types, not the syntax. *Inferred:* since `FUN_006f7160` is
the coercing `lua_isstring`, a number would also take the string branch (ABI §3), making
`Vehicle.AddToTraffic(42)` a stringify rather than an error. Not observed; no script does it.

### `SetupRace` proves the ABI's "no default arguments" claim is too strong

ABI §5 says arity is fixed and defaults do not exist. Five bindings in this family disprove the
general form of that by using a **cursor**: a running `int` index into the Lua stack, incremented as
optional arguments are consumed. `Vehicle.SetupRace @0x0075ffb0` (C++ symbol `SetPlayerRoad` — the
rename is real, see tsv):

```c
if (FUN_006f7160(1)) {                       // arg 1: road name, mandatory
  uVar3 = FUN_006f7a80(1); FUN_00db7e10(uVar3, 1);
  iVar2 = 2;
  FUN_00db7e10("FinishLine", 1);             // <-- DEFAULT, baked in as a literal
  uVar3 = 2; uVar5 = 0;                      // <-- more defaults
  if (FUN_006f7160(2)) {                     // arg 2 present AND a string?
    uVar4 = FUN_006f7a80(2); ...
    iVar2 = 3;                               // cursor advances
  }
  if (FUN_006f7140(iVar2)) { uVar3 = FUN_006f7990(iVar2); iVar2 = iVar2 + 1; }   // optional int
  if (FUN_006f7140(iVar2)) { uVar5 = FUN_006f7990(iVar2); iVar2 = iVar2 + 1; }   // optional int
  if (FUN_006f7140(iVar2) == '\0') { uVar4 = 1; } else { ... }                   // optional, default 1
```

So the real signature is
`Vehicle.SetupRace(sRoad [, sFinishLine="FinishLine"] [, nLaps=2] [, n=0] [, n=1])`, and
`Vehicle.SetupRace("SaarbruckenRace", "FinishLine", 3, -1, 24)`
([Act_1_Race.lua:384](../saboteur-luacd/src/Missions/Act_1_Race.lua)) fills all five. Defaults are
compile-time constants inlined into the body rather than a mechanism — but from Lua they are
indistinguishable from real defaults, and *the arg list is not the count of literal indices in the
body*. My extractor keys on literal indices, so for the five cursor bindings
(`SetupRace`, `SpawnRacer`, `CreateRacer`, `SetStuckCallback`, `Train.TrainSpawnNazi`) the table's arg
shape is a **lower bound**, flagged inline. `Vehicle.CreateRacer`'s true shape is visible in the
corpus: `CreateRacer(sName, sCar, "PILOT", sDriver, sTrack, iLap [, fMinSpeed, fMaxSpeed])`, called
both 6- and 8-arg from [Act_1_Race.lua:674,676](../saboteur-luacd/src/Missions/Act_1_Race.lua).

### Return contracts

Only **20 of 125** are `LuaGlueFunctor0R` — the family's real getters, and the only rows whose result
count is their own. The other 105 are `LuaGlueFunctor0`, whose adapter thunk hardcodes `mov eax,1`
regardless of what the body pushed (ABI §6).

Two `R`-family details worth having:

- **`Vehicle.GetPilot @0x0075d930` genuinely returns `nil`**, and it is one of the few places in the
  seam where that phrase is accurate: on an empty seat it calls `FUN_006f7010()` (`lua_pushnil`) and
  `return 1`. It returns **0 results** for a *bad handle*. So `Vehicle.GetPilot(h)` distinguishes
  "no driver" (nil) from "handle is garbage" (nothing) — and Lua sees `nil` either way, which is
  precisely why the corpus wraps it ([WRAPPER_Vehicle.lua:5](../saboteur-luacd/src/Includes/WRAPPER_Vehicle.lua)).
- **`Vehicle.GetBoardingPosition @0x0075d810` pushes three numbers and returns 3** — matching
  `local x, y, z = Vehicle.GetBoardingPosition(hVehicle, a_sSeatName)`
  ([WRAPPER_Vehicle.lua:141](../saboteur-luacd/src/Includes/WRAPPER_Vehicle.lua)). Multi-return exists
  in this family; it is just rare.

### Callbacks: 29 registrars, in two distinct shapes

Every one takes a **callback name string**, never a function (ABI §10) — there is no `luaL_ref` in the
family. But they split cleanly, and the split is informative. (Thirty rows carry `Callback` in the Lua
name; `Vehicle.ClearDeathCallback` is a *clearer*, not a registrar, leaving 29.)

**19 are per-target**, following the standard ABI §10 shape `(target, sCallbackName, self, tUserTable)`,
with arg 2 rejected when empty (`if (*pcVar5 != '\0')`) and args 3/4 checked with `FUN_006f71c0` (table).

**10 are global** — the race callbacks. They have **no target argument at all**, because there is only
ever one race. All ten `SetRace*`/`SetPlayerLapped`/`SetPlayerSpeed` registrars funnel through one
shared helper, `FUN_007627d0`, which takes a *pointer to a cursor*:

```c
uVar2 = FUN_006f8470(param_1);
uStack_4 = 1;                                                  // cursor := arg 1
iVar1 = FUN_007627d0(uVar2, &uStack_4, "Vehicle.SetRaceStartCallback");   // identity tag
```
```c
// FUN_007627d0:
cVar1 = FUN_006f7160(*param_2);       // arg *cursor* must be a string -- the callback name
if (cVar1 == '\0') { return 0; }
```

So `Vehicle.SetRaceStartCallback("Act_1_Race.StartRace", self)`
([Act_1_Race.lua:420](../saboteur-luacd/src/Missions/Act_1_Race.lua)) — name first, no vehicle.
`Vehicle.SetRacerNearPlayerCallback` is the odd one out: it sets the cursor to **2** and reads a float
from arg 1 first, giving `SetRacerNearPlayerCallback(nDistance, sCallbackName, self)` —
`Vehicle.SetRacerNearPlayerCallback(5, "Act_1_Race.SetBuddyTalk", self)`
([Act_1_Race.lua:458](../saboteur-luacd/src/Missions/Act_1_Race.lua)), and registered three times at
different distances (20/10/5) to drive tiered buddy banter.

Because the index is `*param_2`, these 10 are cursor bindings too — my extractor keys on literal
indices and shows them with a bare or leading-float arg shape. **Their table rows understate the
signature**; the true shape is the one above.

The per-target 19 show arg 3 routinely `nil`:

```lua
Train.TrainRegisterStreamoutCallback(sRailName, "TrainMGR.ReCreateTrainAfterDespawn", nil, {sID})
Train.TrainRegisterCarriageCallback(sRailName, "TrainMGR.AddCarriageHandleToTable", nil, {sID})
```
— [TrainMGR.lua:14,26](../saboteur-luacd/src/Modules/Libraries/TrainMGR.lua)

Because `FUN_006f71c0` is a presence-AND-type test, `nil` and "absent" are the same thing here, and
the binding simply skips the store. `TrainMGR` is the family's one real consumer: it rebuilds trains
on streamout, which is how a rail system that culls aggressively (`+0xdd`/`+0xde`) stays consistent
with mission state.

### What the family says about the game

**The race minigame is a scripted overlay, not a mode.** There is no race engine — there is
`Vehicle.SetupRace`, a `SetRace*Callback` set, and `CreateRacer`/`SpawnRacer`/`SetRacerSpeed`. The
racers are ordinary AI vehicles with `SetForceAIController`; the *rubber-banding is in Lua*, visible
as `Vehicle.SetRacerSpeed(a_tDude[1], self.iMinFast - 40, self.iMaxFast - 40)`
([Act_1_Race.lua:582](../saboteur-luacd/src/Missions/Act_1_Race.lua)) — a min/max speed window the
script widens or narrows per opponent per tick. `Vehicle.SetMagicRacer` and
`Vehicle.FreeRacerWhenBehind` name the same intent from the engine side.

**Trains are DLC and script-owned.** All 31 verbs are creation/culling/speed/callback plumbing —
there is no "run the railway" call, because `TrainMGR.lua` *is* the railway controller. This matches
the DLC-gated `.railway`/`dlc01mega0.megapack` streaming already documented in
[../symbol_map/vehicle-train.md](../symbol_map/vehicle-train.md).

**The Plane API has two generations, and the older one is dead.** `AddPlane`, `RemovePlane`,
`KillPlane` and `SetPlaneHealth` have **zero call sites** in 321 files. Everything shipped goes through
`AddSplinePlaneAttackLocation` / `AddSplinePlaneAttackObject` (11 and 33 call sites) — spline-authored
strafing runs rather than free-flying planes:

```lua
Util.AddSplinePlaneAttackLocation("Missions\\act_1\\farm_on_fire\\planesnbombs\\CIN_PlaneAttack01_05_1",
                                  100, false, 2125, 30, -2031, true)
```
— [Act_1_Farm.lua:1024](../saboteur-luacd/src/Missions/Act_1_Farm.lua). Note the first-generation names
still carry the old model (a plane you spawn, damage and kill); the second generation only has "attack
this point from this spline". The Luftwaffe you see is on rails.

**The MiniZep is a singleton.** Every MiniZep verb except `TeleportMiniZep` takes a bare `bool` and no
target — `EnableMiniZep`, `EnableMiniZepShooting`, `FreezeMiniZep`, `ForceMiniZepTargetPlayer`. There
is exactly one, globally, and script toggles it. `TeleportMiniZep` takes a handle (a locator).

## The table

`Derived arg shape` reads `index:checked-type->fetched-type`, straight from the primitives — e.g.
`1:handle->handle 2:bool->bool` is `f(hThing, bFlag)`. `trackpath(str)` marks the Train name-resolver
in arg 1. `VA` is the **resolved body**; where an ILT stub intervenes the tsv's `impl_va` is shown
beneath it. Every row's table/name/VA/return-contract is byte-level from the exe; the `Confidence`
column grades the **argument signature** only.

| Binding (C++ symbol) | Namespaced form | VA | Source (file:line) | Derived arg shape | Confidence | Evidence |
|---|---|---|---|---|---|---|
| `TrainCreate` | `Train.TrainCreate` | `0x006254e0` | — | 1:trackpath(str) 2:string->string | confirmed | decomp; 11 call sites (docs/saboteur-luacd/src/Missions/Act_1_Farm.lua:1092) |
| `TrainCull` | `Train.TrainCull` | `0x004ec5b0`<br>*(ILT `0x0061f2d0`)* | — | 1:trackpath(str) | inferred | decomp; no call site |
| `TrainDecoupleCarriage` | `Train.TrainDecoupleCarriage` | `0x00624500` | — | 1:handle->handle | confirmed | decomp; 4 call sites (docs/saboteur-luacd/src/Missions/SOE_2_Mission_2.lua:480) |
| `TrainGetBoardingPosition` | `Train.TrainGetBoardingPosition` | `0x006245c0` | — | *(not derived)* | open | `shape=jmp`, real code (`8b 0d 24 d3 42 01`), **absent from the decomp export**. No call site — arity unknown |
| `TrainIsStreamedIn` | `Train.TrainIsStreamedIn` | `0x0061f500` | — | *(not derived; corpus arity 1)* | open | `shape=jmp`, real code (`8b 0d 24 d3 42 01`), **absent from the decomp export**. 5 call sites, all 1-arg trackpath (docs/saboteur-luacd/src/Missions/SOE_2_Mission_2.lua:703) |
| `TrainRegisterCarriageCallback` | `Train.TrainRegisterCarriageCallback` | `0x016271e0`<br>*(ILT `0x00623550`)* | — | 1:trackpath(str) 2:string->string 3:table 4:table | confirmed | decomp; 3 call sites (docs/saboteur-luacd/src/Missions/SOE_2_Mission_2.lua:554) |
| `TrainRegisterCreationCallback` | `Train.TrainRegisterCreationCallback` | `0x01626cd0`<br>*(ILT `0x00623350`)* | — | 1:trackpath(str) 2:string->string 3:table 4:table | inferred | decomp; no call site |
| `TrainRegisterDeathCallback` | `Train.TrainRegisterDeathCallback` | `0x01628770`<br>*(ILT `0x00623f70`)* | — | 1:trackpath(str) 2:string->string 3:table 4:table | inferred | decomp; no call site |
| `TrainRegisterTrainDecoupledCallback` | `Train.TrainRegisterDecoupledCallback` | `0x016284f0`<br>*(ILT `0x00623d50`)* | — | 1:trackpath(str) 2:string->string 3:table 4:table | inferred | decomp; no call site |
| `TrainRegisterEngineCallback` | `Train.TrainRegisterEngineCallback` | `0x01626f60`<br>*(ILT `0x00623450`)* | — | 1:trackpath(str) 2:string->string 3:table 4:table | confirmed | decomp; 5 call sites (docs/saboteur-luacd/src/Missions/Act_3_Mission_4.lua:24) |
| `TrainRegisterFinishRegistrationCallback` | `Train.TrainRegisterFinishRegistrationCallback` | `0x01627470`<br>*(ILT `0x00623650`)* | — | 1:trackpath(str) 2:string->string 3:table 4:table | confirmed | decomp; 1 call site (docs/saboteur-luacd/src/Modules/Libraries/TrainMGR.lua:28) |
| `TrainRegisterLocationCallback` | `Train.TrainRegisterLocationCallback` | `0x00623250` | — | 1:trackpath(str) 2:string->string 3:table 4:table | inferred | decomp; no call site |
| `TrainRegisterPlayerCarriageTriggerCallback` | `Train.TrainRegisterPlayerCarriageTriggerCallback` | `0x00623e50` | — | 1:handle->handle 2:string->string 3:table 4:table | confirmed | decomp; 4 call sites (docs/saboteur-luacd/src/Missions/SOE_2_Mission_2.lua:1466) |
| `TrainRegisterPlayerDistanceCallback` | `Train.TrainRegisterPlayerDistanceCallback` | `0x00624070` | — | 1:trackpath(str) 2:string->string 3:number->float 4:table 5:table | confirmed | decomp; 5 call sites (docs/saboteur-luacd/src/Missions/SOE_2_Mission_2.lua:788) |
| `TrainRegisterStreamoutCallback` | `Train.TrainRegisterStreamoutCallback` | `0x016276e0`<br>*(ILT `0x00623750`)* | — | 1:trackpath(str) 2:string->string 3:table 4:table | confirmed | decomp; 6 call sites (docs/saboteur-luacd/src/Missions/SOE_2_Mission_2.lua:447) |
| `TrainRegisterTrainAmmoCallback` | `Train.TrainRegisterTrainAmmoCallback` | `0x01627d80`<br>*(ILT `0x00623a50`)* | — | 1:trackpath(str) 2:string->string 3:table 4:table | inferred | decomp; no call site |
| `TrainRegisterTrainItemCallback` | `Train.TrainRegisterTrainItemCallback` | `0x01627900`<br>*(ILT `0x00623850`)* | — | 1:trackpath(str) 2:string->string 3:table 4:table | inferred | decomp; no call site |
| `TrainRegisterTrainNaziCallback` | `Train.TrainRegisterTrainNaziCallback` | `0x01627fb0`<br>*(ILT `0x00623b50`)* | — | 1:trackpath(str) 2:string->string 3:table 4:table | confirmed | decomp; 1 call site (docs/saboteur-luacd/src/Missions/SOE_2_Mission_2.lua:449) |
| `TrainRegisterTrainNaziDeathCallback` | `Train.TrainRegisterTrainNaziDeathCallback` | `0x01628230`<br>*(ILT `0x00623c50`)* | — | 1:trackpath(str) 2:string->string 3:table 4:table | inferred | decomp; no call site |
| `TrainRegisterTrainWeaponCallback` | `Train.TrainRegisterTrainWeaponCallback` | `0x01627b60`<br>*(ILT `0x00623950`)* | — | 1:trackpath(str) 2:string->string 3:table 4:table | inferred | decomp; no call site |
| `TrainReleaseToPhysics` | `Train.TrainReleaseToPhysics` | `0x006215e0` | — | 1:trackpath(str) | inferred | decomp; no call site |
| `TrainSetCurrSpeed` | `Train.TrainSetCurrSpeed` | `0x006231c0` | — | 1:trackpath(str) 2:number->float | confirmed | decomp; 1 call site (docs/saboteur-luacd/src/Missions/SOE_2_Mission_2.lua:945) |
| `TrainSetMaxSpeed` | `Train.TrainSetMaxSpeed` | `0x0061f390` | — | 1:trackpath(str) 2:number->float | confirmed | decomp; 17 call sites (docs/saboteur-luacd/src/Missions/Act_1_Farm.lua:1093) |
| `TrainSetStopAtStation` | `Train.TrainSetStopAtStation` | `0x01626160`<br>*(ILT `0x0061f480`)* | — | 1:trackpath(str) 2:bool->bool | confirmed | decomp; 4 call sites (docs/saboteur-luacd/src/Missions/SOE_2_Mission_2.lua:594) |
| `TrainSpawnNazi` | `Train.TrainSpawnNazi` | `0x006241b0` | — | 1:handle->handle 2:string->string 3:bool->bool 4:number/string->string 5:number 6:number<br>*(cursor — lower bound)* | confirmed | decomp; 3 call sites (docs/saboteur-luacd/src/Missions/SOE_2_Mission_2.lua:1693) |
| `TrainSpawnNaziReachedDestination` | `Train.TrainSpawnNaziReachedDestination` | `0x00624420` | — | 1:handle->handle 2:handle->handle | confirmed | decomp; 2 call sites (docs/saboteur-luacd/src/Missions/SOE_2_Mission_2.lua:1708) |
| `TrainStart` | `Train.TrainStart` | `0x01625e70`<br>*(ILT `0x0061f210`)* | — | 1:trackpath(str) | confirmed | decomp; 8 call sites (docs/saboteur-luacd/src/Missions/Act_3_Mission_4.lua:105) |
| `TrainStop` | `Train.TrainStop` | `0x01625fc0`<br>*(ILT `0x0061f270`)* | — | 1:trackpath(str) | confirmed | decomp; 9 call sites (docs/saboteur-luacd/src/Missions/Act_3_Mission_4.lua:26) |
| `TrainSuperCull` | `Train.TrainSuperCull` | `0x0068ae50`<br>*(ILT `0x0061f330`)* | — | 1:trackpath(str) | confirmed | decomp; 16 call sites (docs/saboteur-luacd/src/Missions/SOE_2_Mission_2.lua:2605) |
| `TrainSystemEnable` | `Train.TrainSystemEnable` | `0x01625d80`<br>*(ILT `0x0061f1a0`)* | — | 1:bool->bool | confirmed | decomp; 9 call sites (docs/saboteur-luacd/src/Managers/InteriorManager.lua:548) |
| `TrainUseTrackMaxSpeed` | `Train.TrainUseTrackMaxSpeed` | `0x01626090`<br>*(ILT `0x0061f420`)* | — | 1:trackpath(str) | confirmed | decomp; 1 call site (docs/saboteur-luacd/src/Missions/SOE_2_Mission_2.lua:1328) |
| `AddPlane` | `Util.AddPlane` | `0x0074f620` | — | 1:?->bool | inferred | decomp; no call site |
| `AddSplinePlaneAttackLocation` | `Util.AddSplinePlaneAttackLocation` | `0x0074fbb0` | — | 1:string->string 2:number->float 3:bool->bool 4:number 5:number 6:number 7:bool->bool 8:number->float 9:string->string 10:table 11:table 12:string->string<br>*(variadic — args 8-12 optional)* | confirmed | decomp; 11 call sites (docs/saboteur-luacd/src/Missions/Act_1_Farm.lua:1024) |
| `AddSplinePlaneAttackObject` | `Util.AddSplinePlaneAttackObject` | `0x0074f9b0` | — | 1:string->string 2:number->float 3:bool->bool 4:handle->handle 5:bool->bool 6:number->float 7:string->string 8:table 9:table 10:string->string | confirmed | decomp; 33 call sites (docs/saboteur-luacd/src/Missions/Act_1_Farm.lua:1072) |
| `ClearMiniZepSpline` | `Util.ClearMiniZepSpline` | `0x0075b440` | — | *(no args)* | confirmed | `inlined`; 21 bytes read from the exe, no arg primitive; 1 call site `()` (docs/saboteur-luacd/src/Missions/Paris_2_Mission_5.lua:3315) |
| `EnableMiniZep` | `Util.EnableMiniZep` | `0x0074fee0` | — | 1:bool->bool | confirmed | decomp; 13 call sites (docs/saboteur-luacd/src/Missions/Act_1_BarFight.lua:149) |
| `EnableMiniZepShooting` | `Util.EnableMiniZepShooting` | `0x0074ff50` | — | 1:bool->bool | confirmed | decomp; 3 call sites (docs/saboteur-luacd/src/Missions/Act_3_Mission_2.lua:48) |
| `ForceMiniZepTargetPlayer` | `Util.ForceMiniZepTargetPlayer` | `0x007500a0` | — | 1:bool->bool | inferred | decomp; no call site |
| `FreezeMiniZep` | `Util.FreezeMiniZep` | `0x0074fdc0` | — | 1:bool->bool | confirmed | decomp; 4 call sites (docs/saboteur-luacd/src/Missions/Act_3_Mission_2.lua:2193) |
| `KillMiniZep` | `Util.KillMiniZep` | `0x0075b460` | — | *(no args)* | confirmed | `inlined`; 28 bytes read from the exe, no arg primitive; 1 call site `()` (docs/saboteur-luacd/src/Missions/Act_3_Mission_2.lua:2203) |
| `KillPlane` | `Util.KillPlane` | `0x0075b3a0` | — | *(no args)* | inferred | `inlined`; 28 bytes read from the exe, no arg primitive; no call site |
| `RemovePlane` | `Util.RemovePlane` | `0x0075b380` | — | *(no args)* | inferred | `inlined`; 30 bytes read from the exe, no arg primitive; no call site |
| `SetMiniZepSpline` | `Util.SetMiniZepSpline` | `0x0074fe30` | — | 1:string->string 2:bool->bool | confirmed | decomp; 4 call sites (docs/saboteur-luacd/src/Missions/Act_3_Mission_2.lua:2199) |
| `SetPlaneHealth` | `Util.SetPlaneHealth` | `0x0074f950` | — | 1:?->float | inferred | decomp; no call site |
| `TeleportMiniZep` | `Util.TeleportMiniZep` | `0x0074ffc0` | — | 1:handle->handle | confirmed | decomp; 1 call site (docs/saboteur-luacd/src/Missions/Act_3_Mission_2.lua:2192) |
| `AddRacer` | `Vehicle.AddRacer` | `0x0075f420` | — | 1:string->string 2:handle/string->handle/string 3:string->string 4:number->int 5:number->int 6:number->int | confirmed | decomp; 4 call sites (docs/saboteur-luacd/src/Missions/Act_1_RaceToGermany.lua:413) |
| `VehicleAddToTraffic` | `Vehicle.AddToTraffic` | `0x0075e990` | — | 1:handle/string->handle/string 2:bool->bool 3:bool->bool 4:number 5:number 6:number | confirmed | decomp; 9 call sites (docs/saboteur-luacd/src/Missions/Act_1_Escape.lua:197) |
| `BrakeTo` | `Vehicle.BrakeTo` | `0x007605d0` | — | 1:handle->handle 2:number->float | confirmed | decomp; 20 call sites (docs/saboteur-luacd/src/Includes/__UtilFunctions.lua:655) |
| `VehicleCanBoard` | `Vehicle.CanBoard` | `0x0075e1b0` | — | 1:handle->handle 2:handle->handle 3:handle/string->handle/string | confirmed | decomp; 1 call site (docs/saboteur-luacd/src/Includes/WRAPPER_Vehicle.lua:70) |
| `VehicleCanPassengerGetOut` | `Vehicle.CanPassengerGetOut` | `0x00763fa0` | — | *(reads no args)* | confirmed | **retail stub**: `33 c0 c3` = `xor eax,eax; ret` → 0 results. Called 2-arg (docs/saboteur-luacd/src/Includes/WRAPPER_Vehicle.lua:65); args ignored |
| `VehicleChangeSeat` | `Vehicle.ChangeSeat` | `0x007640c0` | — | *(reads no args)* | confirmed | **retail stub**: `b8 01 00 00 00 c3` = `mov eax,1; ret` → no-op. Called 3-arg (docs/saboteur-luacd/src/Includes/WRAPPER_Vehicle.lua:93); args ignored |
| `ClearDeathCallback` | `Vehicle.ClearDeathCallback` | `0x00760a60` | — | 1:handle->handle | confirmed | decomp; 6 call sites (docs/saboteur-luacd/src/Missions/Act_1_GetCaught.lua:641) |
| `Crash` | `Vehicle.Crash` | `0x00763870` | — | 1:handle/string->handle/string 2:number->float 3:number->float 4:number->float 5:bool->bool | inferred | decomp; no call site |
| `CreateRacer` | `Vehicle.CreateRacer` | `0x0075f1e0` | — | 1:?->string 2:?->string 3:?->string 4:?->string 5:?->string 6:number->int 7:number->float 8:number->float<br>*(cursor — lower bound)* | confirmed | decomp; 16 call sites (docs/saboteur-luacd/src/Missions/Act_1_Race.lua:674) |
| `VehicleEnableInput` | `Vehicle.EnableInput` | `0x0075ef00` | — | 1:handle/string->handle/string 2:bool->bool | inferred | decomp; no call site |
| `EnableParked` | `Vehicle.EnableParked` | `0x0075eca0` | — | 1:bool->bool | inferred | decomp; no call site |
| `TrafficEnable` | `Vehicle.EnableTraffic` | `0x0075ebf0` | — | 1:bool->bool 2:bool->bool | confirmed | decomp; 71 call sites (docs/saboteur-luacd/src/Includes/__UtilFunctions.lua:634) |
| `VehicleForceKeyframing` | `Vehicle.ForceKeyframing` | `0x00760c20` | — | 1:handle->handle | inferred | decomp; no call site |
| `FreeRacer` | `Vehicle.FreeRacer` | `0x0075f360` | — | 1:handle/string->handle/string | inferred | decomp; no call site |
| `FreeRacerWhenBehind` | `Vehicle.FreeRacerWhenBehind` | `0x0075f6a0` | — | 1:handle/string->handle/string | inferred | decomp; no call site |
| `VehicleGetActorInSeat` | `Vehicle.GetActorInSeat` | `0x0075df80` | — | 1:handle->handle 2:string->string | confirmed | decomp; 21 call sites (docs/saboteur-luacd/src/Missions/P1FP_DestroyConvoy.lua:813) |
| `VehicleGetBoardingPosition` | `Vehicle.GetBoardingPosition` | `0x0075d810` | — | 1:handle->handle 2:string->string  push[num,num,num] | confirmed | decomp; 3 call sites (docs/saboteur-luacd/src/Includes/WRAPPER_Actor.lua:172) |
| `GetFireThreshold` | `Vehicle.GetFireThreshold` | `0x0075e570` | — | 1:handle->handle  push[num] | confirmed | decomp; 3 call sites (docs/saboteur-luacd/src/Missions/P1FP_Carbomb.lua:1239) |
| `VehicleGetNextExitSeat` | `Vehicle.GetNextExitSeat` | `0x00763f60` | — | *(reads no args)* | confirmed | **retail stub**: `33 c0 c3` = `xor eax,eax; ret` → 0 results. Called 2-arg (docs/saboteur-luacd/src/Includes/WRAPPER_Vehicle.lua:68); args ignored |
| `VehicleGetNumSeats` | `Vehicle.GetNumSeats` | `0x0075e410` | — | 1:handle->handle  push[num(int)] | confirmed | decomp; 4 call sites (docs/saboteur-luacd/src/Modules/SabTaskObjectiveDeliver.lua:872) |
| `VehicleGetNumWheelsOnGround` | `Vehicle.GetNumWheelsOnGround` | `0x00760460` | — | 1:handle->handle  push[num(int)] | confirmed | decomp; 2 call sites (docs/saboteur-luacd/src/Experimental/MISSION_CFrench.lua:440) |
| `VehicleGetOccupantList` | `Vehicle.GetOccupantList` | `0x0075dbe0` | — | 1:handle->handle | confirmed | decomp; 6 call sites (docs/saboteur-luacd/src/Includes/WRAPPER_Vehicle.lua:24) |
| `VehicleGetPassengers` | `Vehicle.GetPassengers` | `0x0075dac0` | — | 1:handle->handle | confirmed | decomp; 8 call sites (docs/saboteur-luacd/src/Includes/WRAPPER_Vehicle.lua:14) |
| `VehicleGetPilot` | `Vehicle.GetPilot` | `0x0075d930` | — | 1:handle->handle  push[nil] | confirmed | decomp; 40 call sites (docs/saboteur-luacd/src/Experimental/Checkpoint.lua:84) |
| `VehicleGetSeat` | `Vehicle.GetSeat` | `0x0075e090` | — | 1:handle->handle 2:handle->handle | inferred | decomp; no call site |
| `VehicleGetSeatActor` | `Vehicle.GetSeatActor` | `0x0075e320` | — | 1:handle->handle 2:string->string | confirmed | decomp; 6 call sites (docs/saboteur-luacd/src/Missions/P1FP_DestroyConvoy.lua:894) |
| `GetSmokeThreshold` | `Vehicle.GetSmokeThreshold` | `0x0075e4c0` | — | 1:handle->handle  push[num] | confirmed | decomp; 3 call sites (docs/saboteur-luacd/src/Modules/Libraries/ConvoHelper.lua:74) |
| `VehicleGetSpeed` | `Vehicle.GetSpeed` | `0x0075da10` | — | 1:handle->handle  push[num] | confirmed | decomp; 14 call sites (docs/saboteur-luacd/src/Experimental/MISSION_CFrench.lua:419) |
| `HardSetLinVel` | `Vehicle.HardSetLinVel` | `0x00760510` | — | 1:handle->handle 2:number->float | confirmed | decomp; 9 call sites (docs/saboteur-luacd/src/Missions/Act_1_Farm.lua:607) |
| `VehicleIsNaziVehicle` | `Vehicle.IsNaziVehicle` | `0x00763c20` | — | *(not derived; corpus arity 1)* | open | `shape=jmp`, real code (`51 8b 0d 24 d3 42`), **absent from the decomp export**. 2 call sites, 1-arg handle (docs/saboteur-luacd/src/Missions/Paris_1_Mission_1_ConnectB.lua:274) |
| `IsTrafficEnabled` | `Vehicle.IsTrafficEnabled` | `0x0075ed10` | — | *(no args)* | confirmed | decomp; 12 call sites (docs/saboteur-luacd/src/Missions/Act_1_Mission_2B.lua:124) |
| `VehicleLockAllSeats` | `Vehicle.LockAllSeats` | `0x0075e750` | — | 1:handle->handle 2:bool->bool | confirmed | decomp; 23 call sites (docs/saboteur-luacd/src/Missions/Act_1_GetCaught.lua:508) |
| `VehicleLockSeat` | `Vehicle.LockSeat` | `0x0075e620` | — | 1:handle->handle 2:handle/string->handle/string 3:bool->bool | confirmed | decomp; 8 call sites (docs/saboteur-luacd/src/Missions/Act_1_GetCaught.lua:279) |
| `MakeInvincible` | `Vehicle.MakeInvincible` | `0x00760310` | — | 1:handle->handle 2:bool->bool | confirmed | decomp; 2 call sites (docs/saboteur-luacd/src/Missions/Act_1_Escape.lua:625) |
| `OverrideBraking` | `Vehicle.OverrideBraking` | `0x007607c0` | — | 1:handle->handle 2:bool->bool 3:number->float | confirmed | decomp; 4 call sites (docs/saboteur-luacd/src/Includes/__UtilFunctions.lua:656) |
| `OverrideHorsepower` | `Vehicle.OverrideHorsepower` | `0x0075f9c0` | — | 1:handle->handle 2:bool->bool 3:number->float | confirmed | decomp; 11 call sites (docs/saboteur-luacd/src/Missions/Act_1_Race.lua:447) |
| `OverrideMaxSpeed` | `Vehicle.OverrideMaxSpeed` | `0x0075f8e0` | — | 1:handle->handle 2:bool->bool 3:number->float | inferred | decomp; no call site |
| `RegisterWaterCallback` | `Vehicle.RegisterWaterCallback` | `0x007639d0` | — | 1:handle->handle 2:string->string 3:table 4:table | inferred | decomp; no call site |
| `RegisterWaterLoggedCallback` | `Vehicle.RegisterWaterLoggedCallback` | `0x00763af0` | — | 1:handle->handle 2:string->string 3:table 4:table | confirmed | decomp; 3 call sites (docs/saboteur-luacd/src/Includes/WRAPPER_Event.lua:34) |
| `VehicleRemoveFromTraffic` | `Vehicle.RemoveFromTraffic` | `0x0075eb20` | — | 1:handle/string->handle/string | inferred | decomp; no call site |
| `RemoveRacer` | `Vehicle.RemoveRacer` | `0x0075f5e0` | — | 1:handle/string->handle/string | confirmed | decomp; 3 call sites (docs/saboteur-luacd/src/Missions/Act_1_RaceToGermany.lua:445) |
| `SetAsMissionCritical` | `Vehicle.SetAsMissionCritical` | `0x00763d00` | — | 1:handle->handle 2:bool->bool | confirmed | decomp; 10 call sites (docs/saboteur-luacd/src/Missions/Paris_4_Mission_1.lua:866) |
| `SetCanJoinEscalation` | `Vehicle.SetCanJoinEscalation` | `0x00760af0` | — | 1:handle->handle 2:bool->bool | confirmed | decomp; 5 call sites (docs/saboteur-luacd/src/Missions/Act_1_Escape.lua:425) |
| `VehicleSetCrashThrough` | `Vehicle.SetCrashThrough` | `0x0075edf0` | — | 1:handle/string->handle/string 2:bool->bool | confirmed | decomp; 6 call sites (docs/saboteur-luacd/src/Missions/P1FP_Carbomb.lua:1066) |
| `SetDeathCallback` | `Vehicle.SetDeathCallback` | `0x00762da0` | — | 1:handle->handle 2:string->string 3:table 4:table | confirmed | decomp; 6 call sites (docs/saboteur-luacd/src/Missions/P1FP_KillCourtyard01.lua:777) |
| `SetForceAIController` | `Vehicle.SetForceAIController` | `0x0075f840` | — | 1:handle->handle 2:bool->bool | confirmed | decomp; 19 call sites (docs/saboteur-luacd/src/Missions/Act_1_Escape.lua:624) |
| `VehicleSetForceNeverFlip` | `Vehicle.SetForceNeverFlip` | `0x0075f0e0` | — | 1:handle/string->handle/string 2:bool->bool | confirmed | decomp; 3 call sites (docs/saboteur-luacd/src/Missions/Act_1_GetCaught.lua:1316) |
| `VehicleSetForceSelfRight` | `Vehicle.SetForceSelfRight` | `0x0075efe0` | — | 1:handle/string->handle/string 2:bool->bool | confirmed | decomp; 2 call sites (docs/saboteur-luacd/src/Missions/Act_1_Race.lua:465) |
| `SetFullWheelRayScheduling` | `Vehicle.SetFullWheelRayScheduling` | `0x007603c0` | — | 1:handle->handle 2:bool->bool | confirmed | decomp; 1 call site (docs/saboteur-luacd/src/Missions/SOE_1_Mission_7.lua:646) |
| `SetMagicRacer` | `Vehicle.SetMagicRacer` | `0x0075fb80` | — | 1:handle->handle 2:bool->bool | confirmed | decomp; 4 call sites (docs/saboteur-luacd/src/Missions/Act_3_Mission_1.lua:471) |
| `SetPinned` | `Vehicle.SetPinned` | `0x0075fad0` | — | 1:handle->handle 2:bool->bool | confirmed | decomp; 3 call sites (docs/saboteur-luacd/src/Missions/Paris_1_Mission_1.lua:2585) |
| `SetPlayerLappedCallback` | `Vehicle.SetPlayerLappedCallback` | `0x00762c90` | — | 1:string(callback name) 2:table(self) *(via `FUN_007627d0`)* | confirmed | decomp; 2 call sites (docs/saboteur-luacd/src/Missions/Act_1_Race.lua:461) |
| `SetPlayerSpeedCallback` | `Vehicle.SetPlayerSpeedCallback` | `0x00762d00` | — | 1:string(callback name) 2:table(self) *(via `FUN_007627d0`)* | inferred | decomp; no call site |
| `SetRaceCheckPointCallback` | `Vehicle.SetRaceCheckPointCallback` | `0x00762b10` | — | 1:string(callback name) 2:table(self) *(via `FUN_007627d0`)* | inferred | decomp; no call site |
| `SetRaceCollisionMultiplier` | `Vehicle.SetRaceCollisionMultiplier` | `0x00760690` | — | 1:number->float | confirmed | decomp; 1 call site (docs/saboteur-luacd/src/Missions/Act_1_Race.lua:385) |
| `SetRaceFinishedCallback` | `Vehicle.SetRaceFinishedCallback` | `0x007629c0` | — | 1:string(callback name) 2:table(self) *(via `FUN_007627d0`)* | confirmed | decomp; 6 call sites (docs/saboteur-luacd/src/Missions/Act_1_Race.lua:459) |
| `SetRaceLoadedCallback` | `Vehicle.SetRaceLoadedCallback` | `0x007628e0` | — | 1:string(callback name) 2:table(self) *(via `FUN_007627d0`)* | confirmed | decomp; 4 call sites (docs/saboteur-luacd/src/Missions/Act_1_Race.lua:399) |
| `SetRaceOffTrackCallback` | `Vehicle.SetRaceOffTrackCallback` | `0x00762aa0` | — | 1:string(callback name) 2:table(self) *(via `FUN_007627d0`)* | confirmed | decomp; 1 call site (docs/saboteur-luacd/src/Missions/Act_1_Race.lua:460) |
| `SetRacePlaceChangeCallback` | `Vehicle.SetRacePlaceChangeCallback` | `0x00762c20` | — | 1:string(callback name) 2:table(self) *(via `FUN_007627d0`)* | confirmed | decomp; 4 call sites (docs/saboteur-luacd/src/Missions/Act_1_Race.lua:975) |
| `SetRaceStartCallback` | `Vehicle.SetRaceStartCallback` | `0x00762950` | — | 1:string(callback name) 2:table(self) *(via `FUN_007627d0`)* | confirmed | decomp; 5 call sites (docs/saboteur-luacd/src/Missions/Act_1_Race.lua:420) |
| `SetRaceWrongWayCallback` | `Vehicle.SetRaceWrongWayCallback` | `0x00762a30` | — | 1:string(callback name) 2:table(self) *(via `FUN_007627d0`)* | inferred | decomp; no call site |
| `SetRacerNearPlayerCallback` | `Vehicle.SetRacerNearPlayerCallback` | `0x00762b80` | — | 1:number->float 2:string(callback name) 3:table(self) *(via `FUN_007627d0`)* | confirmed | decomp; 14 call sites (docs/saboteur-luacd/src/Missions/Act_1_Race.lua:458) |
| `SetRacerRoad` | `Vehicle.SetRacerRoad` | `0x0075fed0` | — | 1:handle/string->handle/string 2:string->string | confirmed | decomp; 2 call sites (docs/saboteur-luacd/src/Missions/Act_3_Mission_1.lua:531) |
| `SetRacerSpeed` | `Vehicle.SetRacerSpeed` | `0x0075fc30` | — | 1:handle/string->handle/string 2:number->float 3:number->float | confirmed | decomp; 50 call sites (docs/saboteur-luacd/src/Missions/Act_1_Race.lua:582) |
| `SetRacerTarget` | `Vehicle.SetRacerTarget` | `0x0075fd40` | — | 1:handle/string->handle/string 2:handle/string->handle/string 3:number->float | confirmed | decomp; 10 call sites (docs/saboteur-luacd/src/Missions/Act_1_Race.lua:592) |
| `SetRacing` | `Vehicle.SetRacing` | `0x0075f760` | — | 1:bool->bool 2:bool->bool 3:number->int | confirmed | decomp; 24 call sites (docs/saboteur-luacd/src/Missions/Act_1_Race.lua:52) |
| `SetStuckCallback` | `Vehicle.SetStuckCallback` | `0x007634d0` | — | 1:handle->handle 2:string->string 3:nil/table<br>*(cursor — lower bound)* | inferred | decomp; no call site |
| `SetSuperHeavy` | `Vehicle.SetSuperHeavy` | `0x00760270` | — | 1:handle->handle 2:bool->bool | confirmed | decomp; 6 call sites (docs/saboteur-luacd/src/Missions/Act_1_GetCaught.lua:1315) |
| `SetTakeDamageInCinematic` | `Vehicle.SetTakeDamageInCinematic` | `0x00760720` | — | 1:handle->handle 2:bool->bool | confirmed | decomp; 1 call site (docs/saboteur-luacd/src/Missions/Paris_6_Mission_1.lua:1442) |
| `SetPlayerRoad` | `Vehicle.SetupRace` | `0x0075ffb0` | — | 1:string->string 2:string->string<br>*(cursor — lower bound)* | confirmed | decomp; 8 call sites (docs/saboteur-luacd/src/Missions/Act_1_Race.lua:384) |
| `VehicleShowRaceTimer` | `Vehicle.ShowRaceTimer` | `0x007600e0` | — | 1:bool->bool 2:?->float | confirmed | decomp; 2 call sites (docs/saboteur-luacd/src/Missions/FP_Paris_Qualifier.lua:52) |
| `SpawnRacer` | `Vehicle.SpawnRacer` | `0x007636a0` | — | 1:string->string 2:?->float 3:?->float 4:?->float 5:nil/table<br>*(cursor — lower bound)* | confirmed | decomp; 10 call sites (docs/saboteur-luacd/src/Missions/Act_1_Race.lua:686) |
| `VehicleStartFireEffect` | `Vehicle.StartFireEffect` | `0x0075e8e0` | — | 1:handle->handle | confirmed | decomp; 2 call sites (docs/saboteur-luacd/src/Missions/Act_1_Race.lua:1009) |
| `StartPlayback` | `Vehicle.StartPlayback` | `0x00762fa0` | `Script\Interface\Vehicle.cpp:2912` | 1:handle->handle 2:string->string 3:string->string 4:table 5:table | confirmed | decomp; 7 call sites (docs/saboteur-luacd/src/Missions/Act_1_Race.lua:1007) |
| `VehicleStartRaceTimer` | `Vehicle.StartRaceTimer` | `0x007601e0` | — | 1:bool->bool  push[num] | confirmed | decomp; 2 call sites (docs/saboteur-luacd/src/Missions/FP_Paris_Qualifier.lua:93) |
| `VehicleStartSmokeEffect` | `Vehicle.StartSmokeEffect` | `0x0075e830` | — | 1:handle->handle | confirmed | decomp; 1 call site (docs/saboteur-luacd/src/ScriptControllers/DamageVehicle.lua:24) |
| `TrafficAccidentResponse` | `Vehicle.TrafficAccidentResponse` | `0x0075ed90` | — | 1:bool->bool | inferred | decomp; no call site |
| `TurnHeadlightsOff` | `Vehicle.TurnHeadlightsOff` | `0x007609a0` | — | 1:handle/string->handle/string | confirmed | decomp; 1 call site (docs/saboteur-luacd/src/Missions/SOE_2_Mission_2.lua:3516) |
| `TurnHeadlightsOn` | `Vehicle.TurnHeadlightsOn` | `0x007608a0` | — | 1:handle/string->handle/string 2:bool->bool | confirmed | decomp; 1 call site (docs/saboteur-luacd/src/Missions/SOE_2_Mission_2.lua:3514) |
| `VehicleUnboardAll` | `Vehicle.UnboardAll` | `0x00763100` | — | 1:handle->handle 2:bool/table->bool 3:string->string 4:table 5:table 6:string->string 7:table 8:table | confirmed | decomp; 22 call sites (docs/saboteur-luacd/src/Includes/WRAPPER_Vehicle.lua:18) |

## Open questions

1. **`TrainSetCurrSpeed @0x006231c0` passes a literal `0` where the resolved train should go**
   (`FUN_0061fb20(0, speed)`), using the lookup only as a guard. Global-by-design or a shipped bug?
   One call site, so the corpus cannot arbitrate.
2. **The 3 missing bodies.** Seven of the ten rows the export lacks are `shape=inlined` and are now
   read byte-level from the exe (four `() -> ()` MiniZep/Plane verbs, three retail stubs). Only
   `Train.TrainIsStreamedIn @0x0061f500`, `Train.TrainGetBoardingPosition @0x006245c0` and
   `Vehicle.IsNaziVehicle @0x00763c20` are genuine export gaps — all three `shape=jmp`, all three
   `LuaGlueFunctor0R`, i.e. the family's only undocumented *return* contracts. Corpus gives arity for
   two of them (1 arg); `TrainGetBoardingPosition` has no call site and is unconstrained. Re-export
   these three from Ghidra and the family closes.
3. **`vtable+0x194`** — proposed vehicle-component accessor, from usage only across ~40 bodies. Never
   named by a string. Same evidentiary status as `vtable+0x1c` in ABI §7, and should be resolved the
   same way.
4. **`+0x1390` inside the vehicle component** must be non-null before speed/threshold reads. Virtual
   vs. physics vehicle pointer (the two-layer split in the symbol map)? If so, `Vehicle.GetSpeed`
   silently returns nothing for a vehicle in the *other* representation — a real script-visible
   behaviour nobody has tested.
5. **Three handle maps in one family** — `FUN_004436f0`/`DAT_0143db28` (Actor, and
   `TrainDecoupleCarriage`), `FUN_0067c0a0`/`DAT_01321e38` (all Vehicle), and
   `FUN_0096ba30` (trains, by index). Why carriages use the Actor map and vehicles do not is
   unexplained; it may simply be that a carriage is a `WSObject` and a car is not.
6. **30 inferred rows have no call site in the shipped corpus.** `Vehicle.SetStuckCallback`,
   `Vehicle.Crash`, `Vehicle.TrafficAccidentResponse`, `Vehicle.RegisterWaterCallback` and the
   never-called Plane four are all plausible cut content — but the corpus is the *decompiled* set, and
   absence there is weaker evidence than absence in `LuaScripts.luap`. Worth a pass against the retail
   container before calling anything dead.
7. **Does `FUN_01625950`'s type-name ladder reach anything in retail?** It computes a diagnostic and
   discards it. If a debug build logged it, the strings may still be in `.rdata` and would name the
   Train arg-1 parameter directly.
