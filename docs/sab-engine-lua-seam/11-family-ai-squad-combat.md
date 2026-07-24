# Family 11 — AI: Squad, Combat, Target & Formation

> **Verified:** all 91 VAs re-checked against the decomp and `lua_registration_map.tsv` (0 VA/symbol
> mismatches, 0 fabricated args, no Mercs 2 imports) and all 72 line-numbered corpus citations re-read
> (0 broken); corrected four errors — `Nav.FormationMoveOnPath` *does* have a corpus caller
> (`Act_1_Escape.lua:548`), `ResetPlayerTargetPriority`'s call sites are in `Paris_3_Mission_1.lua` not
> `Act_3_Mission_3.lua`, `+0x42cc` hangs off `*(component+0x1c)` not off the component, and two prose
> call-counts disagreed with the table.

The bindings that let Lua drive the soldier brain: who an NPC hates, where it stands when bored, when it
may shoot, and how it is grouped with its friends. This is the seam that mission scripts lean on hardest —
`Combat.*` and `Squad.*` together account for well over a thousand call sites in the Lua corpus.

Read [02-marshalling-abi.md](02-marshalling-abi.md) first; every signature below was derived with that
decoder ring. Engine-side context for the classes named here is in
[symbol_map/ai-behavior.md](../symbol_map/ai-behavior.md).

## Inclusion rule (auditable)

`data/lua_registration_map.tsv` is the authority for what a binding is *called*. I selected:

1. **every binding whose `table` is `Combat` (65) or `Squad` (18)** — these are first-class engine-created
   namespaces, which makes the boundary mechanical rather than a judgement call;
2. **the six `Nav.*Formation*` bindings** (`CreateFormation`, `AddMemberToFormation`, `EnterFormation`,
   `ExitFormation`, `FormationMoveToPoint`, `FormationMoveOnPath`) — formations are explicitly in scope and
   are squad-shaped, but they register into `Nav`, not `Squad`;
3. **`Actor.OverrideCombatAI` and `Actor.IsInCombat`** — combat behaviour-state, claimed here despite living
   in the `Actor` table. Overlap with the Actor family is intentional.

**Total: 91 bindings.**

> **Addendum (post-dates the verify pass).** A later pass added a fourth selector — **the whole `Sensory`
> table (8)** — which was orphaned in no doc at all despite being AI perception. Those 8 rows are covered in
> [The `Sensory` table — AI perception](#the-sensory-table--ai-perception) at the foot of this document,
> with their own coverage statement, and are **not** counted in the 91 or in the "Coverage honesty" section
> below — both of which record the original, verified scope. **Family total is now 99 bindings.**

Deliberately **excluded**, despite matching `*Target*` on the name: `Searchlight.SetTarget`,
`Vehicle.SetRacerTarget`, `HUD.SetGPSTarget`/`ClearGPSTarget`/`SetGPSTargetToFocus`,
`AttrPt.SetMiniGameTarget`, `AttractionPt.GetTargetPos`, `Cin.SetEnterMusicOverride`/`SetExitMusicOverride`,
`Suspicion.EnableResistanceEscalation`, `Object.GetDistance`. These are name-collisions that drive sibling
subsystems (searchlights, racing, HUD, cinematics), not the combat AI. Named here so the omission is visible
rather than silent.

## Coverage honesty

*(This section states the original 91-binding scope as verified. The 8 `Sensory` rows added later carry
their own coverage statement in [their own section](#the-sensory-table--ai-perception); they are not folded
into the counts here.)*

**91 of 91 bindings in this family located** (name, table, VA and return contract are byte-level facts from
the tsv, not inferences). Of those:

- **89 decomp bodies read.** Signatures derived for all 89.
- **1 confirmed by assertion string** — `Nav.EnterFormation`, which is the *only* member of this family
  carrying an EALA `__FILE__`/`__LINE__` pair (`Script\Interface\Navigation.cpp:1342`). The rest of the
  family does not assert. This is expected: only 12 of 898 bindings engine-wide have one.
- **75 corroborated by at least one real Lua call site** (arg order and semantics cross-checked against
  the corpus). Marked *inferred (corroborated)* — decomp and corpus independently agree.
- **14 derived from the decomp body alone**, with no call site in the corpus. Marked *inferred*. These are
  mostly the melee bindings (`LockIntoMelee`, `UnlockMeleeMove`, `SetDoMeleeCallbacks`,
  `GetMeleeHandleByName`) and the `Squad.*Objective*` group — see Open questions.
- **1 not found: `Nav.FormationMoveOnPath`** (`0x00734630`). It is registered — that is a byte-level fact —
  but no `FUN_` exists at that VA in the decomp. It *is* called by a shipped mission
  (`Missions/Act_1_Escape.lua:548`), so its arity is known from the corpus but no body-derived signature is
  offered.
- **1 has no standalone body: `Combat.ResetPlayerTargetPriority`** — `shape=inlined`, so its body is folded
  into the thunk itself. Arity 0 is read from the corpus, not the decomp.

No row below is a guess. Where I could not derive something, the row says so.

## The two shapes: Combat keys on handles, Squad keys on names

The clearest structural fact in this family, and it falls straight out of the arg-1 type check:

> **Every *per-actor* `Combat.*` binding takes a handle as argument 1 (58 of 65). Every `Squad.*` binding
> takes a *name string* (18 of 18).**

The seven `Combat.*` bindings that do not take a handle are precisely the ones that are **not per-actor**,
which is what makes the rule meaningful rather than merely usual:

| Binding | Arg 1 | Why it has no actor |
|---|---|---|
| `Combat.GlobalAllowGrenades` | `bool` | global switch |
| `Combat.SetGlobalAllowCombatHijacking` | `bool` | global switch |
| `Combat.SetGlobalHostileToResistance` | `bool` | global switch |
| `Combat.SetPlayerTargetPriority` | `number` | acts on the player, implicitly |
| `Combat.ResetPlayerTargetPriority` | *(none)* | acts on the player, implicitly |
| `Combat.GetMeleeHandleByName` | `string` | it is a *lookup* — name → handle |
| `Combat.UnlockMeleeMove` | `string`, `string`, `bool` | keyed by move name, not by actor |

So the rule is: **if a `Combat.*` binding addresses an actor at all, it addresses it by handle.**

`Combat.SetCombat` opens with `FUN_006f71a0(1)` (lightuserdata); `Squad.Create` opens with
`FUN_006f7160(1)` (string) and additionally rejects the empty string:

```c
cVar1 = FUN_006f7160(1);                                     // arg 1 is a STRING
if (((cVar1 != '\0') && (pcVar3 = (char *)FUN_006f7a80(1), pcVar3 != (char *)0x0)) &&
   (*pcVar3 != '\0')) {                                      // ...and non-empty
  FUN_00db7e10(pcVar3,1);                                    // copy out of Lua ownership
  iVar2 = thunk_FUN_0051db09(&uStack_4);                     // string -> squad lookup
  ...
```
(`FUN_00745540 @0x00745540`, `Squad.Create`.)

This is a real design split, not an accident. Squads are addressed through an engine-side **string→squad
map**, so a squad name is stable across save/load in a way a handle is not (§7 of the ABI notes: handles are
session-scoped and do not survive a reload). Scripts create a squad by name in one file and add members to
it from another without ever passing an object reference — e.g. `Squad.Create("Ambush")` then
`Squad.AddMember("Ambush", hNazi)`. The cost is that **every `Squad.*` call is a string lookup**, and that a
typo'd squad name fails completely silently.

## Argument-1 failure is silent, and that shapes the scripts

Per §7 of the ABI notes, all three handle-resolution failure edges are silent. Combat inherits this: a
`Combat.SetTarget(hDeadGuy, hSab)` on a despawned actor is a no-op with no error, no log, no return value.
Because `LuaGlueFunctor0` bindings also hard-claim 1 result regardless of what they pushed, **a Lua caller
cannot distinguish "the actor is dead" from "it worked"**. The corpus visibly copes with this by
re-validating handles itself before combat calls rather than trusting the engine to complain.

## The combat component: `+0x140`

Nearly every `Combat.*` binding walks the same chain and then gates on one pointer:

```c
uStack_4 = FUN_006f6ec0(1);                     // arg 1: handle
EnterCriticalSection(DAT_0143db28);
iVar2 = FUN_004436f0(&uStack_4);                // handle -> proxy (guarded map)
LeaveCriticalSection(...);
iVar2 = (**(code **)(*piVar3 + 0x1c))();        // proxy -> object
iVar2 = *(int *)(iVar2 + 0x140);                // <-- the COMBAT COMPONENT
if (iVar2 != 0) { ...work... }
```

`+0x140` is the actor's combat/AI component pointer, and it is what `Combat.IsCombatant` literally reports:

```c
iVar2 = (**(code **)(*piVar3 + 0x1c))();
thunk_FUN_0043fbc6(*(int *)(iVar2 + 0x140) != 0);   // push (component != NULL)
return 1;
```
(`FUN_007241e0 @0x007241e0`.) So **`Combat.IsCombatant(h)` does not ask "is this actor fighting" — it asks
"does this actor have a combat component at all"**, i.e. is it a soldier rather than a civilian or a prop.
`Actor.IsInCombat` (`0x00713990`) is the binding that answers the *state* question. The two are easy to
confuse and the corpus uses both. *(Inferred: the "component" reading comes from the field's use as a gate
across ~60 bindings plus the two vtable hops above; the field is never named in a string.)*

Sub-structures hanging off it, each derived byte-level from the binding that touches it:

| Offset | Width | Meaning | Evidence |
|---|---|---|---|
| `+0x44/+0x48/+0x4c` | 3×`float` | **idle position** (x,y,z) | written by `Combat.SetIdlePos` `0x00722ec0` |
| `+0x210` | `u16` | **target-flag bitfield** | set/cleared by `Combat.AddTargetFlag` `0x00721520` |
| `+0x225` | byte, bit 0 | "currently targeting the player" | read by `Combat.GetTarget` `0x007212d0` |

One field is **one dereference further out** and does *not* hang off the component directly:

| Offset | Base | Width | Meaning | Evidence |
|---|---|---|---|---|
| `+0x42cc` | `*(component + 0x1c)` | byte, bit 7 | `bInvestigateFirst` | written by `Combat.SetHunt` `0x00723090` |

In `SetHunt` the chain is `iVar1 = piVar5[0x50]` (i.e. `*(obj + 0x140)`, the component), then
`iVar3 = *(int *)(iVar1 + 0x1c)`, and it is *that* object the `+0x42cc` byte belongs to. The same object
also takes `& 0xdf` (bit 5 cleared) and a float at `+0x42a4` on every `SetHunt` call; neither is decoded
here.

## Target flags — a decoded enum, confirmed double-blind

`Combat.AddTargetFlag` (`FUN_00721520 @0x00721520`) bounds-checks the flag and sets a bit:

```c
uVar5 = FUN_006f7990();              // arg 2: int
if (uVar5 < 0x11) {                  // flags 0..16 accepted
  puVar1 = (ushort *)(iVar3 + 0x210);
  *puVar1 = *puVar1 | (ushort)(1 << ((byte)uVar5 & 0x1f));
  cVar2 = FUN_006f71c0();            // arg 3: TABLE...
  if ((cVar2 != '\0') && (1 << ((byte)uVar5 & 0x1f) == 4)) {   // ...only accepted for flag 2
```

The engine accepts a table for **exactly one** flag value: the one where `1<<n == 4`, i.e. **n == 2**.
Independently, the Lua corpus defines its constants in
[`Modules/__MagicNumbers.lua:38-47`](../saboteur-luacd/src/Modules/__MagicNumbers.lua):

| Value | Constant | Takes a table? |
|---:|---|---|
| 0 | `cTARGET_ALLENEMIES` | no |
| 1 | `cTARGET_ALLENEMIESHOSTILE` | no |
| **2** | **`cTARGET_ENEMYLIST`** | **yes** |
| 3 | `cTARGET_PLAYER` | no |
| 4 | `cTARGET_NAZI` | no |
| 5 | `cTARGET_CIVILIAN` | no |
| 6 | `cTARGET_RESISTANCE` | no |
| 7 | `cTARGET_REACTTODAMAGE` | no |
| 8 | `cTARGET_SQUADASSIST` | no |
| 9 | `cTARGET_NOAUTORESPONSE` | no |

`cTARGET_ENEMYLIST = 2` is the only constant the corpus ever passes a table to
(`Missions/P2FP_Trap.lua:139`, `Missions/Act_1_Farm.lua:1002`, `Missions/P1FP_Jailbreak.lua:766`, …), and it
is the only value the engine will accept a table for. Neither side was consulted to produce the other — the
binary's `1<<n==4` and the script's `= 2` agree. That pins the enum's base and confirms these are flag
**indices**, not masks.

Two quirks fall out. The engine reserves **17** flag slots (`< 0x11`) but Lua only names 10 — slots 10-16
are engine-side or were cut. And slot 16 is a latent bug: `(ushort)(1 << 16)` truncates to `0`, so
`Combat.AddTargetFlag(h, 16)` passes the bounds check and then sets nothing.

## Bug 1 — `Combat.SetIdlePos` reads its coordinates from the wrong arguments

`FUN_00722ec0 @0x00722ec0`, in full after the handle resolve:

```c
cVar1 = FUN_006f71a0(1);                    // arg 1 must be a HANDLE
if (cVar1 != '\0') {
  uStack_14 = FUN_006f6ec0(1);
  ... iVar2 = *(int *)(iVar2 + 0x140) ...   // combat component
  cVar1 = FUN_006f7140(1);                  // <-- arg 1 must be a NUMBER ?!
  if (((cVar1 != '\0') && (cVar1 = FUN_006f7140(2), cVar1 != '\0')) &&
     (cVar1 = FUN_006f7140(3), cVar1 != '\0')) {
    fVar4 = (float10)FUN_006f7950(1); fStack_10 = (float)fVar4;
    fVar4 = (float10)FUN_006f7950(2); fStack_c  = (float)fVar4;
    fVar4 = (float10)FUN_006f7950(3); fStack_8  = (float)fVar4;
  }
  *(float *)(iVar2 + 0x44) = fStack_10;     // written UNCONDITIONALLY
  *(float *)(iVar2 + 0x48) = fStack_c;
  *(float *)(iVar2 + 0x4c) = fStack_8;
}
```

Argument 1 is required to be lightuserdata by the first check, so `lua_isnumber(L,1)` on that same slot is
always false (§3: the `lua_type ==` checks are exact, and `isnumber` does not coerce lightuserdata). The
fetch block is therefore **unreachable**, and `fStack_10/_c/_8` — never initialised on that path — are
written to the idle position anyway. The intended indices were plainly 2, 3, 4.

The one call site in the corpus passes exactly what a *correct* binding would want:

```lua
local x, y, z = Object.GetPosition(hObj)
Combat.SetIdlePos(a_EntitySelf.hController, x, y, z)   -- Modules/Libraries/ScriptSequence.lua:425
Combat.SetIdleAngle(a_EntitySelf.hController, nRot)    -- :426
```

Its sibling on the very next line, `Combat.SetIdleAngle` (`0x00722cf0`), correctly reads `(handle@1,
number@2)`. So `SetIdlePos` is anomalous against both its caller and its neighbour: **in retail, this
binding writes uninitialised stack floats into the actor's idle position.** With one call site, on a
scripted-sequence path, the blast radius is small — which is presumably why it shipped.

*(Confidence: the misread is **confirmed** — the indices are unambiguous in the body. That the resulting
floats are true garbage is **inferred**: it depends on the compiler not having initialised that stack slot,
which I read from the decompiled prologue, not from a live run.)*

## The target-or-position overload (`SetHunt`, `SetTether`, and the cut `SetInvestigate`)

Three bindings share one hand-written argument parser, and it is the most intricate thing in the family:
argument 2 may be **a handle**, **three numbers**, or **nil**, and *every subsequent argument shifts index
accordingly*. `Combat.SetHunt` (`FUN_00723090 @0x00723090`):

```c
iStack_2c = 0;
cVar2 = FUN_006f71a0(2);              // arg 2 a HANDLE?
if (cVar2 == '\0') {
  cVar2 = FUN_006f7140(2);            // no -> three NUMBERS?
  if ((... FUN_006f7140(3) ... FUN_006f7140(4) ...) == '\0') {
    cVar2 = FUN_006f7100(2);          // no -> NIL? (use own position, vtable+0x50)
    if (cVar2 == '\0') return;
    pfVar8 = (float *)(**(code **)(*piVar5 + 0x50))(auStack_10);
    goto LAB_00723216;                //    -> iVar3 = 3
  }
  ... fetch x,y,z from 2,3,4 ...
  iVar3 = 5;                          // <-- POSITION form: next arg is 5
} else {
  uVar6 = FUN_006f6ec0(2);
  iVar3 = 3;                          // <-- HANDLE form: next arg is 3
  ...
}
LAB_0072322a:
cVar2 = FUN_006f7120(iVar3);          // bUrgent
uStack_24 = FUN_006f6e60(iVar3);
cVar2 = FUN_006f7120(iVar3 + 1);      // bSurpriseDelay
...
iVar9 = iVar3 + 2;
cVar2 = FUN_006f7160(iVar9);          // sCallback (string)
if (cVar2 == '\0') {
  cVar2 = FUN_006f7100(iVar9);        // ...or nil -> skip the callback group
  if (cVar2 != '\0') iVar9 = iVar3 + 5;
} else {
  iStack_28 = FUN_006f7a80(iVar9);
  ... FUN_0070a180(iStack_28); FUN_0070a4b0(iVar3 + 3);
  iVar9 = iVar3 + 4;
  cVar2 = FUN_006f71c0(iVar9);        // tSelf (table) or nil
  ... iVar9 = iVar3 + 5;
}
iVar3 = *(int *)(iVar1 + 0x1c);       // <-- iVar3 REUSED: no longer an arg index, now an object ptr
                                      //     (iVar1 = piVar5[0x50] = *(obj+0x140), the component)
cVar2 = FUN_006f7120(iVar9);          // FINAL bool, still at the old iVar3+5 == iVar9
if (cVar2 != '\0') {
  cVar2 = FUN_006f6e60(iVar9);
  *(byte *)(iVar3 + 0x42cc) = *(byte *)(iVar3 + 0x42cc) & 0x7f | cVar2 << 7;   // bInvestigateFirst
}
```

This arithmetic makes a **falsifiable prediction**: in the position form, `iVar3 = 5`, so the trailing bool
must sit at argument `5 + 5 = 10`, with the callback group at 7/8/9. The corpus obliges, and it is an exact
hit — three explicit `nil` placeholders to skip the callback group, then the tenth argument:

```lua
Combat.SetHunt(self.hController, a_tArgs.hTarget, true, false)                       -- Experimental/SoldierState_Hunt.lua:13
Combat.SetHunt(self.hController, a_tArgs.vHuntLocation.x, a_tArgs.vHuntLocation.y,
               a_tArgs.vHuntLocation.z, true, false, nil, nil, nil, bInvestigateFirst) -- Experimental/SoldierState_Hunt.lua:15
Combat.SetHunt(hNazi, nil, true, false)                                              -- Missions/P1FP_Carbomb.lua:1021
```

All three branches — handle, position, nil — appear in shipped scripts, and the 10-argument call lands the
final bool precisely where `iVar3+5` says it must. `Combat.SetTether` (`FUN_007236d0 @0x007236d0`) uses the
same parser with a shorter tail, and the corpus again exercises both forms:
`Combat.SetTether(hOfficer, hLoc, 2.5)` (`Missions/P1FP_KillCourtyard01.lua:476`) versus
`Combat.SetTether(self.hSmoker, x, y, z, 20, 15)` (`Missions/CFP_GiselleRescue.lua:357`). A negative radius
is a sentinel: `Combat.SetTether(a_hEntity, a_nX, a_nY, a_nZ, -1)`
(`Missions/CFP_GiselleRescue.lua:477`), and the body indeed clamps
`if (fStack_1c < 0.0) { fStack_1c = _DAT_010a45c8; }`.

Note the ergonomic trap this creates: because the fetches never throw (§4) and the whole parser `return`s
silently if arg 2 is none of the three accepted forms, **passing a bad position to `SetHunt` does nothing at
all**.

## Formations are numeric IDs — a third addressing scheme

Distinct from both Combat's handles and Squad's names. `Nav.CreateFormation` (`0x007344f0`) takes no
arguments and is `LuaGlueFunctor0R` — it pushes and returns a value, a **numeric formation ID**.
`Nav.AddMemberToFormation` (`0x00736ae0`) then reads `(number@1, handle@2)`: the ID first, the actor second.
So this one family uses all three addressing modes, one per subsystem.

`Nav.EnterFormation` is the family's only assertion-anchored binding, which pins it exactly:

```c
pcStack_10 = "C:\\EALA-BUILD-SAB1\\p4\\Ref_Sab_POV\\wildstar\\POV\\code\\WildStar\\Script\\Interface\\Navigation.cpp";
pcStack_c  = "EnterFormation";
fStack_8   = 1.88054e-42;         // <- the LINE NUMBER, reinterpreted as float by Ghidra
```

(Ghidra typed the stack slot as `float` because of neighbouring FP writes; the bit pattern of
`1.88054e-42` is `0x0000053E` = **1342**. Source: `Script\Interface\Navigation.cpp:1342`.)

Its signature is `(handle@1, handle@2, number@3, number@4, number@5 [, int@6])` — follower, leader, and an
x/y/z **offset**, which the corpus confirms is an offset rather than a world position:

```lua
Nav.EnterFormation(hActor, hLeader, tOffsets[nCurrentOffset].x, 0, tOffsets[nCurrentOffset].z)
-- Modules/Libraries/Formation.lua:110
```

The optional sixth argument is an integer mode with two magic values visible in the body: `5` dispatches
straight to `vtable+0x30`, and `100` is a hardcoded special case that force-loads the animation
`"shrd_M_prisoner_march_UB1"` and sets bit 2 at `+0x1fc`. **Mode 100 is the prisoner-march formation** — a
piece of mission-specific content welded into a generic navigation binding. No corpus script passes a sixth
argument, so this path appears dead in the shipped scripts. *(Inferred: the string and the constant are
confirmed; "prisoner march" as the mode's meaning is read from the animation name.)*

## Ten `Combat.*` functions the scripts call that the engine does not have

Grepping the corpus for `Combat.<name>(` and diffing against the registration map turns up ten names that
are **called but never registered**, and which have no Lua-side definition either (no
`function Combat.X` / `Combat.X = function` anywhere in the 321 sources):

| Called name | Call sites | Status |
|---|---|---|
| `Combat.SetInvestigate` | `Experimental/SoldierState_InvestigateThreat.lua:11`, `Experimental/Soldier_Internal.lua:76,90` | not registered |
| `Combat.SetQuestioning` | `Experimental/Checkpoint.lua:118,127,138,308` | not registered |
| `Combat.Init` | `Experimental/MgrHarasser.lua:281`, `Experimental/NaziTest_Idle.lua:16` | not registered |
| `Combat.TakeCover` | `Experimental/NaziTest_Combat.lua:7` | not registered |
| `Combat.DoRandomRangedMovement` | `Experimental/NaziTest_Combat.lua:9` | not registered |
| `Combat.SetFriendlyFire` | `Experimental/SoldierState_Combat.lua:24` | not registered |
| `Combat.SetAutoFire` | `Experimental/SoldierState_Combat.lua:25` | not registered |
| `Combat.LockIntoCombat` | `Missions/SOE_2_Mission_2.lua:2266`, `Modules/Libraries/ScriptSequence.lua:354` | not registered |
| `Combat.SetQuestioningState` | `Modules/Behavior/Human/Starter/FreeplayStarter.lua:36` | not registered |
| `Combat.AlwaysSeeTarget` | `Modules/Libraries/AggroSpawner.lua:221` | not registered |

Absence is a byte-level fact from the tsv (read from the exe's registration stanzas), and it is corroborated
by a raw string scan of `Saboteur.exe` itself: eight of the ten names (`SetInvestigate`, `SetQuestioning`,
`TakeCover`, `DoRandomRangedMovement`, `SetFriendlyFire`, `SetAutoFire`, `LockIntoCombat`,
`SetQuestioningState`) occur **0×** in the file as ASCII or UTF-16, while every registered neighbour is
there in the clear (`SetAlwaysSeeTarget` 3×, `LockIntoMelee` 3×, `SetHunt` 3×). `AlwaysSeeTarget` matches 3×
only as a substring of `SetAlwaysSeeTarget`, and `Init` is too generic to test. ⚠️ *(corrected 2026-07-24:
this previously cited "none of the ten appears as a string anywhere in the 54 MB decomp", which proves
nothing — registration name strings live in `.rdata`, not in decompiled code, so **registered** bindings
score 0 there too. `SetAlwaysSeeTarget` is registered as `Combat.SetAlwaysSeeTarget` at `0x00722370` and has
0 decomp hits. The exe string scan is the discriminating test; the conclusion is unchanged.)* In Lua 5.1
these calls index a nil field, which raises
`attempt to call field 'X' (a nil value)` — a hard error, not a silent no-op like a bad handle.

Most are in `Experimental/`, which is plainly a dev sandbox and probably never loaded at runtime. But four
are not: `Combat.LockIntoCombat` in a shipped mission and in `ScriptSequence`, `Combat.SetQuestioningState`
in a Freeplay behaviour starter, and `Combat.AlwaysSeeTarget` in `AggroSpawner`. Two of these are
near-misses against surviving bindings — `AlwaysSeeTarget` vs. the registered `Combat.SetAlwaysSeeTarget`
(`0x00722370`), and `LockIntoCombat` vs. the registered `LockIntoMelee`/`LockIntoRanged` — which reads like
a rename late in development that the scripts were not fully updated for.

The honest reading: **the Lua corpus in `docs/saboteur-luacd/src` is not exactly the retail script set.** It
is close enough that 75 of 89 signatures corroborate perfectly, but it drifts against retail at the edges,
and `Combat.SetInvestigate` — whose handle-or-xyz-then-callback call shape is *identical* to the surviving
`Combat.SetHunt` — looks very much like the function that was merged into `SetHunt` (which is why `SetHunt`
carries a `bInvestigateFirst` flag at all). *(Inferred: the merge is a reading of the shared parser plus the
flag name, not something the binary states.)*

## What this family says about the game's AI

The picture that emerges is a **fully externalised soldier brain**. The engine owns the FSM
(`WSAIHelperCombat`, `WSAIBhvr*` — see [ai-behavior.md](../symbol_map/ai-behavior.md)), but essentially
every *policy* knob is a Lua setter, and the corpus turns them constantly:

- **`Combat.SetIdleScripted` — 163 call sites**, the single most-called binding in the family. Idle
  behaviour is the default thing missions override.
- **`Actor.OverrideCombatAI` — 151 call sites**, by far the most-used combat-state binding anywhere. Its
  signature is a bare `(handle, bool)` (`FUN_00714090 @0x00714090`), i.e. one global "let script drive this
  actor" switch that missions flip constantly.
- `Combat.SetTarget` (95), `Combat.SetCombat` (85), `Combat.SetObjective` (51).
- The `SetRespondTo*` cluster (`Damage`, `DeadBodies`, `Events`, `FriendlyDamage`, `Sound`,
  `PaperCheckEvent`) — six separate `(handle, bool)` bindings, each gating one perception channel. Missions
  do not tune an aggression scalar; they switch entire *senses* off. `SetRespondToPaperCheckEvent` is the
  checkpoint/disguise system's hook into combat, tying this family to
  [human-disguise.md](../symbol_map/human-disguise.md).
- `Combat.SetWimpy` / `SetWimpyUntilProvoked` — the "civilian who flees until you shoot at him" pair.
- `Combat.SetAimAndHitNoMiss` (9 sites) is a scripted-drama knob: guarantee the shot lands.
- `Combat.SetDryFire` — make an NPC fire without damage. Theatre, not combat.

The `Squad.*` half is thinner in practice than the API implies: `AddMember` (66) and `Create` (38)
dominate, while the entire objective group (`AddObjective`, `RemoveObjective`, `ClearObjectives`,
`DefendObjectives`) has **zero** call sites in the corpus despite being registered and implemented. Squads
in shipped content are mostly used as *grouping for target propagation* — create, add members, `SetEnemy` —
rather than as a tactical objective system. `Combat.SetSquadAssist` (20 sites) plus the
`cTARGET_SQUADASSIST` flag is how one soldier's target becomes the squad's target.

Note also that of the 65 `Combat.*` bindings, **26 take exactly `(handle, bool)` and nothing else** — 40% of
the table is a one-bit switch on one actor. Add the three global `bool` switches and nearly half the API is
boolean. This is not a rich tactical interface; it is a large panel of toggles, which is exactly what you
would expect from a mission-scripted stealth-action game where designers need to disable emergent AI on
demand so a set-piece plays out.

## Open questions

- **`Nav.FormationMoveOnPath` (`0x00734630`)** is registered but has no function body in the decomp —
  while a shipped mission calls it (`Missions/Act_1_Escape.lua:548`,
  `Nav.FormationMoveOnPath(NaziFormationID, sPath, cPATHTYPE_ONCE)`, three lines below the
  `CreateFormation`/`AddMemberToFormation` pair cited above). A live registration plus a shipped caller
  makes **decomp extraction gap** much the likelier reading over "cut feature". Needs a look at the raw
  bytes at that VA to confirm the body is really there.
- **Target flag slots 10-16** are accepted by the engine but unnamed by Lua. Do the `WSAI*` classes read
  them internally, or are they cut?
- **`+0x140`'s type.** I call it "the combat component" from its gating role; its actual class name is not
  in any string I found. Candidates from RTTI: `WSAIHelperCombat`, `WSAIHelperEnemy`. Resolving the vtable
  at that pointer would settle it.
- **The melee sub-family** (`LockIntoMelee`, `UnlockMeleeMove`, `DoMeleeMove`, `RequestMeleeBP`,
  `SetDoMeleeCallbacks`, `GetMeleeHandleByName`) has almost no corpus usage — `DoMeleeMove` has 3 sites,
  the rest none. `RequestMeleeBP` — "BP" is presumably *blueprint* (cf. `WSAIControllerBlueprint`), but
  that is a guess I have not verified.
- **`Combat.GetTarget`'s player special-case.** The body has **two** result paths, and only the second is
  the `+0x225` one. First it calls `FUN_0083a200()` and, if that is non-null *and* its `vtable+0xc` call
  returns true, it pushes `*(FUN_005109a0() + 0xd7c)` — a different object entirely, not decoded here.
  Only when that guard fails does it fall to the player path: check bit 0 of `+0x225`, then push the handle
  of the object from `FUN_0059db40()` — believed to be the player/Saboteur getter, but not confirmed
  (`FUN_0059db40` is a 17-byte forwarder to `FUN_00510e91` gated on `*(param+0x10)`). So the narrower
  reading — "`GetTarget` can only ever report the player" — holds *only* on the fallback path; the
  first path can report something else. Needs both `FUN_0059db40` and `FUN_005109a0`/`FUN_0083a200` pinned.
- **`Combat.SetIdlePos`'s garbage write** should be confirmed on a live run (x32dbg breakpoint at
  `0x00722ec0`, inspect `+0x44` after return) rather than left as a static reading.
- **Squad objectives** are implemented but unused by shipped scripts. Was the tactical layer cut, or is it
  driven from a script set not present in this corpus?

## Full binding table

Signatures use the ABI notation: `h`=handle (lightuserdata), `b`=boolean, `n`=number, `s`=string,
`t`=table; the digit is the **Lua stack index** = argument position. `[x]` = optional. `|` = an accepted
alternative form. Where a name is descriptive (`hActor`, `bUrgent`) it came from a corroborating call site.

**Return contract** is `family` from the tsv, not from the body (§6): all rows are `LuaGlueFunctor0` — the
thunk hard-claims 1 result regardless of what the body pushed — *except* `Combat.GetTarget`,
`Combat.GetMeleeHandleByName`, `Combat.IsCombatant`, `Actor.IsInCombat` and `Nav.CreateFormation`, which are
`LuaGlueFunctor0R` and return their own result count.

| Binding | Namespaced form | VA | Source (file:line) | Signature | Confidence | Evidence |
|---|---|---|---|---|---|---|
| `IsInCombat` | `Actor.IsInCombat` | `0x00713990` | — | `Actor.IsInCombat(hActor) -> bool` | inferred (corroborated) | 6 call sites, e.g. `Missions/Act_1_BarFight.lua:983` |
| `OverrideCombatAI` | `Actor.OverrideCombatAI` | `0x00714090` | — | `Actor.OverrideCombatAI(h1, b2)` | inferred (corroborated) | 151 call sites, e.g. `Missions/Act_1_BarFight.lua:480` |
| `AddTargetFlag` | `Combat.AddTargetFlag` | `0x00721520` | — | `Combat.AddTargetFlag(hActor, nFlag [, tEnemyList])` | inferred (corroborated) | hand-read; nFlag<=0x10, bit set in u16 at +0x210; table only when nFlag==2; 36 call sites, e.g. `Missions/Act_1_Farm.lua:159` |
| `BroadcastRetreat` | `Combat.BroadcastRetreat` | `0x0071f900` | — | `Combat.BroadcastRetreat(h1, n2, n3)` | inferred (corroborated) | 1 call sites, e.g. `Modules/SabTaskObjective.lua:719` |
| `BroadcastSound` | `Combat.BroadcastSound` | `0x0071f780` | — | `Combat.BroadcastSound(h1, n2, n3)` | inferred (corroborated) | 1 call sites, e.g. `Missions/Paris_1_Mission_1.lua:768` |
| `CombatClearLeader` | `Combat.ClearLeader` | `0x00723d30` | — | `Combat.ClearLeader(h1)` | inferred (corroborated) | 7 call sites, e.g. `Missions/P2FP_Trap.lua:421` |
| `ClearObjective` | `Combat.ClearObjective` | `0x00721be0` | — | `Combat.ClearObjective(h1)` | inferred (corroborated) | 4 call sites, e.g. `Missions/Paris_1_Mission_6.lua:1331` |
| `ClearStateLock` | `Combat.ClearStateLock` | `0x00723ad0` | — | `Combat.ClearStateLock(h1)` | inferred (corroborated) | 3 call sites, e.g. `Missions/Paris_3_Mission_1.lua:1770` |
| `ClearTarget` | `Combat.ClearTarget` | `0x00721220` | — | `Combat.ClearTarget(h1)` | inferred (corroborated) | 1 call sites, e.g. `Missions/P1FP_Carbomb.lua:1020` |
| `ClearTargetFlags` | `Combat.ClearTargetFlags` | `0x007217c0` | — | `Combat.ClearTargetFlags(h1)` | inferred (corroborated) | 2 call sites, e.g. `Missions/P3FP_OKCorral.lua:451` |
| `DoMeleeMove` | `Combat.DoMeleeMove` | `0x007242a0` | — | `Combat.DoMeleeMove(h1, s2, h3, b4)` | inferred (corroborated) | 3 call sites, e.g. `Missions/Act_1_BarFight.lua:629` |
| `ExitCombat` | `Combat.Exit` | `0x00724130` | — | `Combat.Exit(h1)` | inferred (corroborated) | 11 call sites, e.g. `Experimental/MgrHarasser.lua:303` |
| `GetMeleeHandleByName` | `Combat.GetMeleeHandleByName` | `0x00721080` | — | `Combat.GetMeleeHandleByName(sName) -> handle` | inferred | no corpus call site; decomp body only |
| `GetTarget` | `Combat.GetTarget` | `0x007212d0` | — | `Combat.GetTarget(hActor) -> hTarget | nil` | inferred (corroborated) | hand-read; 0 results on bad handle; 3 call sites, e.g. `Experimental/Soldier_Broadcasts.lua:51` |
| `GlobalAllowGrenades` | `Combat.GlobalAllowGrenades` | `0x0071f9d0` | — | `Combat.GlobalAllowGrenades(b1)` | inferred (corroborated) | 8 call sites, e.g. `Missions/Act_1_Factory.lua:38` |
| `IsCombatant` | `Combat.IsCombatant` | `0x007241e0` | — | `Combat.IsCombatant(hActor) -> bool` | inferred (corroborated) | hand-read; pushes (obj+0x140)!=0; 9 call sites, e.g. `Missions/Act_1_BarFight.lua:276` |
| `LockIntoMelee` | `Combat.LockIntoMelee` | `0x00723950` | — | `Combat.LockIntoMelee(h1)` | inferred | no corpus call site; decomp body only |
| `LockIntoRanged` | `Combat.LockIntoRanged` | `0x00723a10` | — | `Combat.LockIntoRanged(h1)` | inferred (corroborated) | 23 call sites, e.g. `Missions/Act_3_Mission_2.lua:1254` |
| `RemoveTargetFlag` | `Combat.RemoveTargetFlag` | `0x00721710` | — | `Combat.RemoveTargetFlag(h1, n2)` | inferred (corroborated) | 1 call sites, e.g. `Missions/Paris_3_Mission_1.lua:1771` |
| `RequestMeleeBP` | `Combat.RequestMeleeBP` | `0x00724060` | — | `Combat.RequestMeleeBP(h1, s2)` | inferred (corroborated) | 1 call sites, e.g. `Missions/Act_1_BarFight.lua:1684` |
| `ReturnToIdlePos` | `Combat.ReturnToIdlePos` | `0x00722d90` | — | `Combat.ReturnToIdlePos(h1)` | inferred (corroborated) | 3 call sites, e.g. `Missions/P1FP_Carbomb.lua:960` |
| `SetAimAndHitNoMiss` | `Combat.SetAimAndHitNoMiss` | `0x00722630` | — | `Combat.SetAimAndHitNoMiss(h1, b2)` | inferred (corroborated) | 9 call sites, e.g. `Missions/Act_1_Escape.lua:463` |
| `SetAlwaysSeeTarget` | `Combat.SetAlwaysSeeTarget` | `0x00722370` | — | `Combat.SetAlwaysSeeTarget(h1, b2)` | inferred (corroborated) | 41 call sites, e.g. `Missions/Act_1_BarFight.lua:476` |
| `SetBroadcastEnteredCombat` | `Combat.SetBroadcastEnteredCombat` | `0x00722210` | — | `Combat.SetBroadcastEnteredCombat(h1, b2)` | inferred (corroborated) | 9 call sites, e.g. `Missions/Act_3_Mission_2.lua:2029` |
| `SetBroadcastWeaponFire` | `Combat.SetBroadcastWeaponFire` | `0x007222c0` | — | `Combat.SetBroadcastWeaponFire(h1, b2)` | inferred (corroborated) | 12 call sites, e.g. `Missions/Act_1_Farm.lua:998` |
| `SetCombat` | `Combat.SetCombat` | `0x007233b0` | — | `Combat.SetCombat(h1)` | inferred (corroborated) | 85 call sites, e.g. `Experimental/SoldierState_Combat.lua:21` |
| `SetDoMeleeCallbacks` | `Combat.SetDoMeleeCallbacks` | `0x00724590` | — | `Combat.SetDoMeleeCallbacks(h1, b2)` | inferred | no corpus call site; decomp body only |
| `SetDryFire` | `Combat.SetDryFire` | `0x00722580` | — | `Combat.SetDryFire(h1, b2)` | inferred (corroborated) | 8 call sites, e.g. `Missions/P1FP_Carbomb.lua:820` |
| `CombatSetFollowBoardCallback` | `Combat.SetFollowBoardCallback` | `0x00723de0` | — | `Combat.SetFollowBoardCallback(h1, s2, t3, t4)` | inferred | no corpus call site; decomp body only |
| `CombatSetFollowUnboardCallback` | `Combat.SetFollowUnboardCallback` | `0x00723f20` | — | `Combat.SetFollowUnboardCallback(h1, s2, t3, t4)` | inferred | no corpus call site; decomp body only |
| `SetGlobalAllowCombatHijacking` | `Combat.SetGlobalAllowCombatHijacking` | `0x0071fa40` | — | `Combat.SetGlobalAllowCombatHijacking(b1)` | inferred (corroborated) | 2 call sites, e.g. `Managers/RewardsManager.lua:5275` |
| `SetGlobalHostileToResistance` | `Combat.SetGlobalHostileToResistance` | `0x0071f690` | — | `Combat.SetGlobalHostileToResistance(b1)` | inferred (corroborated) | 3 call sites, e.g. `Missions/P3FP_OKCorral.lua:551` |
| `SetGrabbable` | `Combat.SetGrabbable` | `0x007235f0` | — | `Combat.SetGrabbable(h1, b2)` | inferred (corroborated) | 32 call sites, e.g. `Missions/Act_1_GetCaught.lua:494` |
| `SetHostileTargetsOnly` | `Combat.SetHostileTargetsOnly` | `0x00721df0` | — | `Combat.SetHostileTargetsOnly(h1, b2)` | inferred (corroborated) | 1 call sites, e.g. `Missions/Paris_4_Mission_1.lua:923` |
| `SetHunt` | `Combat.SetHunt` | `0x00723090` | — | `Combat.SetHunt(hActor, hTarget|nX,nY,nZ|nil, bUrgent, bSurpriseDelay [, sCallback, tSelf, tArgs, bInvestigateFirst])` | inferred (corroborated) | hand-read; 3-way overload, later arg indices SHIFT by form; 16 call sites, e.g. `Experimental/SoldierState_Hunt.lua:13` |
| `SetIdleAngle` | `Combat.SetIdleAngle` | `0x00722cf0` | — | `Combat.SetIdleAngle(h1, n2)` | inferred (corroborated) | 2 call sites, e.g. `Modules/Libraries/ScriptSequence.lua:265` |
| `SetIdleAttrPt` | `Combat.SetIdleAttrPt` | `0x00722bf0` | — | `Combat.SetIdleAttrPt(h1, s2, s3)` | inferred | no corpus call site; decomp body only |
| `SetIdleDisperse` | `Combat.SetIdleDisperse` | `0x00722fe0` | — | `Combat.SetIdleDisperse(h1, b2)` | inferred (corroborated) | 5 call sites, e.g. `Missions/Act_1_Mission_2B.lua:312` |
| `SetIdleHoldWeapon` | `Combat.SetIdleHoldWeapon` | `0x00722900` | — | `Combat.SetIdleHoldWeapon(h1, b2)` | inferred (corroborated) | 21 call sites, e.g. `Missions/Act_1_Farm.lua:631` |
| `SetIdlePath` | `Combat.SetIdlePath` | `0x00722af0` | — | `Combat.SetIdlePath(h1, s2, n3)` | inferred (corroborated) | 2 call sites, e.g. `Modules/Behavior/Human/Nazi/Soldier.lua:163` |
| `SetIdlePos` | `Combat.SetIdlePos` | `0x00722ec0` | — | `Combat.SetIdlePos(hActor, nX, nY, nZ)` | inferred (corroborated) | hand-read; **engine reads XYZ from args 1-3, not 2-4 — see Bug 1**; 1 call sites, e.g. `Modules/Libraries/ScriptSequence.lua:425` |
| `SetIdleScripted` | `Combat.SetIdleScripted` | `0x00722a50` | — | `Combat.SetIdleScripted(h1, b2)` | inferred (corroborated) | 163 call sites, e.g. `Experimental/Checkpoint.lua:73` |
| `SetIdleUseNeeds` | `Combat.SetIdleUseNeeds` | `0x007229b0` | — | `Combat.SetIdleUseNeeds(h1, b2)` | inferred (corroborated) | 2 call sites, e.g. `Modules/Behavior/Human/Human_Null.lua:13` |
| `SetIgnoreCombatInVehicle` | `Combat.SetIgnoreCombatInVehicle` | `0x00722850` | — | `Combat.SetIgnoreCombatInVehicle(h1, b2)` | inferred (corroborated) | 6 call sites, e.g. `Missions/P2FP_GrandSniper.lua:752` |
| `CombatSetLeader` | `Combat.SetLeader` | `0x00723b90` | — | `Combat.SetLeader(h1, h2, b3, n4, n5)` | inferred (corroborated) | 28 call sites, e.g. `Missions/Act_1_BarFight.lua:947` |
| `SetLethalForce` | `Combat.SetLethalForce` | `0x00721ca0` | — | `Combat.SetLethalForce(h1, b2)` | inferred (corroborated) | 22 call sites, e.g. `Missions/Act_1_BarFight.lua:1617` |
| `SetObjective` | `Combat.SetObjective` | `0x00721920` | — | `Combat.SetObjective(h1, h2, b3, n4, b5)` | inferred (corroborated) | 51 call sites, e.g. `Missions/Act_3_Mission_3.lua:1524` |
| `SetObjectivePath` | `Combat.SetObjectivePath` | `0x00721a90` | — | `Combat.SetObjectivePath(h1, h2, b3, n4)` | inferred (corroborated) | 4 call sites, e.g. `Missions/Paris_2_Mission_5.lua:1878` |
| `SetPlayerTargetPriority` | `Combat.SetPlayerTargetPriority` | `0x0071f710` | — | `Combat.SetPlayerTargetPriority(n1)` | inferred (corroborated) | 6 call sites, e.g. `Missions/Act_3_Mission_2.lua:49` |
| `SetReactImmediately` | `Combat.SetReactImmediately` | `0x007224d0` | — | `Combat.SetReactImmediately(h1, b2)` | inferred (corroborated) | 43 call sites, e.g. `Missions/Act_1_BarFight.lua:472` |
| `SetRespondToDamage` | `Combat.SetRespondToDamage` | `0x00721f50` | — | `Combat.SetRespondToDamage(h1, b2)` | inferred (corroborated) | 25 call sites, e.g. `Missions/Act_1_BarFight.lua:280` |
| `SetRespondToDeadBodies` | `Combat.SetRespondToDeadBodies` | `0x00721ea0` | — | `Combat.SetRespondToDeadBodies(h1, b2)` | inferred (corroborated) | 14 call sites, e.g. `Missions/P1FP_Carbomb.lua:1079` |
| `SetRespondToEvents` | `Combat.SetRespondToEvents` | `0x007220b0` | — | `Combat.SetRespondToEvents(h1, b2)` | inferred (corroborated) | 45 call sites, e.g. `Missions/Act_1_BarFight.lua:278` |
| `SetRespondToFriendlyDamage` | `Combat.SetRespondToFriendlyDamage` | `0x00722000` | — | `Combat.SetRespondToFriendlyDamage(h1, b2)` | inferred | no corpus call site; decomp body only |
| `SetRespondToPaperCheckEvent` | `Combat.SetRespondToPaperCheckEvent` | `0x00722160` | — | `Combat.SetRespondToPaperCheckEvent(h1, b2)` | inferred (corroborated) | 1 call sites, e.g. `Modules/Behavior/Human/Nazi/Soldier.lua:18` |
| `SetRespondToSound` | `Combat.SetRespondToSound` | `0x00721d50` | — | `Combat.SetRespondToSound(h1, b2)` | inferred (corroborated) | 28 call sites, e.g. `Missions/Act_1_BarFight.lua:279` |
| `SetSquadAssist` | `Combat.SetSquadAssist` | `0x00722420` | — | `Combat.SetSquadAssist(h1, b2)` | inferred (corroborated) | 20 call sites, e.g. `Missions/Act_1_BarFight.lua:281` |
| `SetStationary` | `Combat.SetStationary` | `0x00723500` | — | `Combat.SetStationary(h1, b2)` | inferred (corroborated) | 40 call sites, e.g. `Experimental/SoldierState_Combat.lua:22` |
| `SetTarget` | `Combat.SetTarget` | `0x00721150` | — | `Combat.SetTarget(h1, h2)` | inferred (corroborated) | 95 call sites, e.g. `Experimental/MgrHarasser.lua:282` |
| `SetTargetAggressively` | `Combat.SetTargetAggressively` | `0x00721870` | — | `Combat.SetTargetAggressively(h1, b2)` | inferred (corroborated) | 9 call sites, e.g. `Missions/Act_1_BarFight.lua:477` |
| `SetTargetTeam` | `Combat.SetTargetTeam` | `0x00721410` | — | `Combat.SetTargetTeam(h1, n2)` | inferred (corroborated) | 3 call sites, e.g. `Missions/P1FP_NaziParty.lua:1060` |
| `SetTether` | `Combat.SetTether` | `0x007236d0` | — | `Combat.SetTether(hActor, hLoc|nX,nY,nZ|nil, nRadius [, nInner])` | inferred (corroborated) | hand-read; both overloads used in corpus; 25 call sites, e.g. `Experimental/SoldierState_Configure.lua:68` |
| `SetWimpy` | `Combat.SetWimpy` | `0x007226e0` | — | `Combat.SetWimpy(h1, b2)` | inferred (corroborated) | 2 call sites, e.g. `Missions/P3FP_Hit.lua:294` |
| `SetWimpyUntilProvoked` | `Combat.SetWimpyUntilProvoked` | `0x00722790` | — | `Combat.SetWimpyUntilProvoked(h1, b2)` | inferred (corroborated) | 1 call sites, e.g. `Modules/Behavior/Human/Nazi/Soldier.lua:22` |
| `ThrowGrenade` | `Combat.ThrowGrenade` | `0x00724640` | — | `Combat.ThrowGrenade(h1)` | inferred (corroborated) | 5 call sites, e.g. `Missions/Act_1_BarFight.lua:946` |
| `UnlockMeleeMove` | `Combat.UnlockMeleeMove` | `0x00724470` | — | `Combat.UnlockMeleeMove(s1, s2, b3)` | inferred | no corpus call site; decomp body only |
| `AddMemberToFormation` | `Nav.AddMemberToFormation` | `0x00736ae0` | — | `Nav.AddMemberToFormation(n1, h2)` | inferred (corroborated) | 1 call sites, e.g. `Missions/Act_1_Escape.lua:545` |
| `CreateFormation` | `Nav.CreateFormation` | `0x007344f0` | — | `Nav.CreateFormation() -> nFormationId` | inferred (corroborated) | hand-read; no args; 1 call sites, e.g. `Missions/Act_1_Escape.lua:539` |
| `EnterFormation` | `Nav.EnterFormation` | `0x00736b90` | `Navigation.cpp:1342` | `Nav.EnterFormation(hActor, hLeader, nX, nY, nZ [, nMoveMode])` | confirmed | **assertion string**: Navigation.cpp:1342; 5 call sites, e.g. `Missions/P1FP_Entourage.lua:419` |
| `ExitFormation` | `Nav.ExitFormation` | `0x00736df0` | — | `Nav.ExitFormation(h1)` | inferred (corroborated) | 3 call sites, e.g. `Missions/P1FP_Entourage.lua:485` |
| `FormationMoveToPoint` | `Nav.FormationMoveToPoint` | `0x00734560` | — | `Nav.FormationMoveToPoint(n1, n2, n3, n4)` | inferred | no corpus call site; decomp body only |
| `AddToSquad` | `Squad.AddMember` | `0x00746770` | — | `Squad.AddMember(s1, h2)` | inferred (corroborated) | 66 call sites, e.g. `Experimental/Checkpoint.lua:50` |
| `AddSquadObjective` | `Squad.AddObjective` | `0x00745b40` | — | `Squad.AddObjective(s1, h2, n3)` | inferred | no corpus call site; decomp body only |
| `ClearSquadBehavior` | `Squad.ClearBehavior` | `0x00745d90` | — | `Squad.ClearBehavior(s1)` | inferred (corroborated) | 4 call sites, e.g. `Missions/Paris_1_Mission_1_ConnectB.lua:119` |
| `ClearSquadLeader` | `Squad.ClearLeader` | `0x00745ab0` | — | `Squad.ClearLeader(s1)` | inferred (corroborated) | 1 call sites, e.g. `Modules/Libraries/Joe.lua:65` |
| `ClearSquadObjectives` | `Squad.ClearObjectives` | `0x00745cf0` | — | `Squad.ClearObjectives(s1, h2)` | inferred | no corpus call site; decomp body only |
| `CreateSquad` | `Squad.Create` | `0x00745540` | — | `Squad.Create(s1)` | inferred (corroborated) | 38 call sites, e.g. `Experimental/Checkpoint.lua:49` |
| `DefendSquadObjectives` | `Squad.DefendObjectives` | `0x00745eb0` | — | `Squad.DefendObjectives(s1)` | inferred | no corpus call site; decomp body only |
| `DeleteSquad` | `Squad.Delete` | `0x007455d0` | — | `Squad.Delete(s1)` | inferred (corroborated) | 10 call sites, e.g. `Missions/Act_1_Farm.lua:96` |
| `FollowSquadLeader` | `Squad.FollowLeader` | `0x00745e20` | — | `Squad.FollowLeader(s1)` | inferred (corroborated) | 7 call sites, e.g. `Missions/Act_1_BarFight.lua:1366` |
| `RemoveFromSquad` | `Squad.RemoveMember` | `0x00746860` | — | `Squad.RemoveMember(s1, h2)` | inferred (corroborated) | 7 call sites, e.g. `Missions/Act_1_BarFight.lua:1147` |
| `RemoveSquadObjective` | `Squad.RemoveObjective` | `0x00745c30` | — | `Squad.RemoveObjective(s1, h2)` | inferred | no corpus call site; decomp body only |
| `SetSquadEnemy` | `Squad.SetEnemy` | `0x00745650` | — | `Squad.SetEnemy(s1, s2, b3)` | inferred (corroborated) | 22 call sites, e.g. `Missions/Act_1_BarFight.lua:325` |
| `SetSquadLeader` | `Squad.SetLeader` | `0x00746920` | — | `Squad.SetLeader(s1, h2)` | inferred (corroborated) | 12 call sites, e.g. `Missions/Act_1_BarFight.lua:1365` |
| `SetSquadLeaderPath` | `Squad.SetLeaderPath` | `0x007465b0` | — | `Squad.SetLeaderPath(s1, s2, b3, s4, t5, t6)` | inferred (corroborated) | 1 call sites, e.g. `Modules/SabTaskObjectiveDeliver.lua:126` |
| `SetSquadLeaderPt` | `Squad.SetLeaderPt` | `0x00745820` | — | `Squad.SetLeaderPt(s1, n2, n3, n4, b5)` | inferred | no corpus call site; decomp body only |
| `SetSquadLethal` | `Squad.SetLethal` | `0x00745a00` | — | `Squad.SetLethal(s1, b2)` | inferred (corroborated) | 8 call sites, e.g. `Missions/Act_1_BarFight.lua:1598` |
| `SetSquadParent` | `Squad.SetParent` | `0x00745750` | — | `Squad.SetParent(s1, s2)` | inferred (corroborated) | 4 call sites, e.g. `Missions/Paris_1_Mission_6.lua:433` |
| `SetSquadRadius` | `Squad.SetRadius` | `0x00745960` | — | `Squad.SetRadius(s1, n2)` | inferred (corroborated) | 9 call sites, e.g. `Missions/Act_1_BarFight.lua:1367` |
| `ResetPlayerTargetPriority` | `Combat.ResetPlayerTargetPriority` | `0x00724f40` | — | `Combat.ResetPlayerTargetPriority()` | inferred (corroborated) | `inlined` shape — body folded into the thunk, no standalone `FUN_`; 3 call sites, e.g. `Missions/Paris_3_Mission_1.lua:1941` |
| `FormationMoveOnPath` | `Nav.FormationMoveOnPath` | `0x00734630` | — | `Nav.FormationMoveOnPath(nFormationId, sPath, nPathType)` — *corpus-only* | **body not found** | registered (tsv, byte-level) but no `FUN_` at this VA in the decomp; signature read from its 1 call site `Missions/Act_1_Escape.lua:548`, **not** from a body |

---

# The `Sensory` table — AI perception

> **This section post-dates the adversarial verify pass recorded at the top of this document.** Nothing
> above it was altered except the two coverage notes that point here; no verified claim was rewritten.
>
> **Verified (adversarial pass, scoped to this `Sensory` section only — the content above retains its own
> earlier verified line).** Re-derived independently, not taken on report:
> - **All 8 `impl_va` re-partitioned** from the tsv (`awk -F'\t' '$1=="Sensory"'` → 8 rows) and matched
>   against the table: no omission, no extra, every VA correct. All 8 are real function starts in
>   `Saboteur.exe` (each opens `8b0d24d34201` / `mov ecx,[0x142d324]`); all 8 bodies exist in the decomp at
>   sizes 238–683, as claimed. No `33 c0 c3` stub — confirmed in both directions.
> - **Every byte-level claim re-disassembled with pefile + capstone and confirmed**: the four `push 1`
>   sites (`0x0074297f`, `0x00742bff`, `0x00742da5`, `0x00742aef`); the caps `push 0xa` @ `0x007429eb` /
>   `0x00742c92` and `push 0x14` @ `0x00742e4b`; `mov ecx,[ebp+0x148]` @ `0x007433be`; `test bl,bl` @
>   `0x00743377` (`84db742b` → `je 0x7433a6`, as stated).
> - **The Ghidra-constant finding is real.** `0xf7bf80` reads `0000000000005940` (double `100.0`) but
>   `float`-of-low-4 = `0.0`; `0xf9eeb8` reads `00000040e17a843f` but `float`-of-low-4 = `2.0` — exactly the
>   `0.0`/`2.0` the decomp prints. One overclaim corrected: the constants are reciprocal to `float`
>   precision, not exactly (see the precision footnote below).
> - **Every corpus citation greps clean and every count re-counted matches**: 27 total, 27 direct-call form,
>   and 18/2/2/1/1/3/0/0 per binding. The five `== false` sites and the four inside `Act_1_GetCaught.lua`
>   both re-counted correct. No fabricated call site was found.
> - **Cross-doc claim checked**: doc 12 mentions `Sensory`/`CanSee`/`HaveLOS` **zero** times (a loose grep
>   hits only "closing" and "loses"). `SetAlwaysSeeTarget` = **41** corpus-wide, as quoted.
> - **Spot-checks that could have refuted the section and did not**: `FUN_0082da90` really is
>   `size=337 callers=[0x0074300c(FUN_00742f00)]` — one caller, this binding; `FUN_0082c8b0` is `size=46`
>   with engine-wide callers; `FUN_00497430`/`FUN_00497470` are genuinely byte-identical (63 bytes, verified
>   `memcmp`-equal in the image); the `thunk_FUN_0043fbc6` chain really does run
>   `0x6f7020 → jmp 0x43fbc6 → jmp back 0x6f7025 → call 0x4019b0`; `FUN_006f6cc0` really does
>   `gettop / pushnumber((float)key) / pushlightuserdata / settable`; and `AddTrackObject`'s `iVar3` = 3/5
>   overload does put the two trailing numbers at args 3,4 (handle) and 5,6 (position).
> - **The `GetVisibleEnemyList` asymmetry is real**, not a misread: `0x00742bc0` carries the
>   `piVar6[7] & 0xffffff` querying-actor generation check and `0x00742940` does not. Correctly filed as open.
> - **Tiering accepted**: no row claims an assertion anchor, and none carries an `EALA-BUILD-SAB1` literal —
>   the "0 confirmed" self-assessment is honest. No Mercenaries 2 import found.
>
> Corrections applied by this pass: the "exact reciprocals" overclaim, and a miscounted line distance
> ("five lines above" → three). Both are noted inline. Everything else stood.

The eight `Sensory` bindings were orphaned — in no family doc at all — yet this is the "can that soldier
see me?" surface, which in a stealth game is not a peripheral concern. They belong here: `Sensory` is the
input side of the same soldier brain whose output side is `Combat.*`. Selected mechanically, by table
membership, exactly as `Combat` and `Squad` were:

```
awk -F'\t' '$1=="Sensory"' data/lua_registration_map.tsv   # -> 8 rows
```

**8 of 8 located, 0 confirmed by assertion string, 6 inferred (corroborated), 2 inferred, 0 not found.**
All eight bodies exist in the decomp and were read in full; six were additionally re-derived from
`Saboteur.exe` with pefile + capstone (doc 19's method), which mattered — see
[the constants Ghidra got wrong](#the-constant-ghidra-got-wrong). No `Sensory` binding carries an EALA
assertion string, so per the house rule **no row here is assertion-anchored**; identity is the registration
map's, and "inferred (corroborated)" means the body and a shipped caller independently agree.

## The table

Notation as in [the full binding table](#full-binding-table): `h`=handle, `n`=number, `t`=table; the digit
is the Lua stack index. Return contract is `family` from the tsv: the six `LuaGlueFunctor0R` rows return
their own result count (so they can and do return **nothing**, which Lua sees as `nil`); the two
`LuaGlueFunctor0` rows hard-claim 1 result regardless.

| Binding | VA | Shape | Signature | Confidence | Evidence |
|---|---|---|---|---|---|
| `Sensory.CanSee` | `0x00742f00` | `0R` / `jmp` | `Sensory.CanSee(hLooker, hTarget) -> bool` | inferred (corroborated) | hand-read; `FUN_006f71a0(1)`+`(2)`, drives `FUN_0082da90`, pushes bool via `0x4019b0`; **0 results** if either arg is not a handle, either fails to resolve, or `hLooker == hTarget`; 18 call sites, e.g. `Experimental/SoldierState_PaperCheckLeader.lua:41` |
| `Sensory.HaveLOS` | `0x00743040` | `0R` / `jmp` | `Sensory.HaveLOS(hA, hB) -> bool` | inferred (corroborated) | hand-read; drives `FUN_0082c8b0`; additionally gates on `*(s16)(obj+0x11c) != -1` for **both** objects; 2 call sites, `Missions/P1FP_Traitor.lua:1064,1084` |
| `Sensory.GetVisibleEnemyList` | `0x00742940` | `0R` / `jmp` | `Sensory.GetVisibleEnemyList(hActor) -> tHandles \| nil` | inferred (corroborated) | hand-read + exe; `push 1` at `0x0074297f`; **`push 0xa` at `0x007429eb` — capped at 10**; drives `FUN_00877310`; pushes nil when empty; 2 call sites, e.g. `Experimental/MgrHarasser.lua:365` |
| `Sensory.GetVisibleFriendList` | `0x00742bc0` | `0R` / `jmp` | `Sensory.GetVisibleFriendList(hActor) -> tHandles \| nil` | inferred (corroborated) | hand-read + exe; `push 1` at `0x00742bff`; **`push 0xa` at `0x00742c92` — capped at 10**; drives `FUN_00877360`; 1 call site, `Experimental/MgrHarasser.lua:379` |
| `Sensory.GetClosestVisibleEnemy` | `0x00742ab0` | `0R` / `jmp` | `Sensory.GetClosestVisibleEnemy(hActor) -> hEnemy` | inferred (corroborated) | hand-read + exe; `push 1` at `0x00742aef`; drives `FUN_008776b0`; pushes the handle at `obj+0x20` via `lua_pushlightuserdata` (`0x4019d0`); **0 results** if nothing visible; 1 call site, `Experimental/SoldierState_PaperCheckLeader.lua:42` |
| `Sensory.GetAllCanSee` | `0x00742d60` | `0R` / `jmp` | `Sensory.GetAllCanSee(hActor) -> tHandles \| nil` | inferred (corroborated) | hand-read + exe; `push 1` at `0x00742da5`; **`push 0x14` at `0x00742e4b` — capped at 20**; drives `FUN_0082cb20`; same `+0x11c != -1` gate as `HaveLOS`; 3 call sites, e.g. `Experimental/SoldierState_Combat.lua:31` |
| `Sensory.AddTrackObject` | `0x00743130` | `adapter` | `Sensory.AddTrackObject(hActor, hTarget, n3, nPct4)` **or** `Sensory.AddTrackObject(hActor, nX, nY, nZ, n5, nPct6)` | inferred | hand-read + exe; no corpus call site; 3-way-style parser shifts trailing indices by form (`iVar3` = 3 handle / 5 position); trailing pct bounded `0 < x <= 100` then `*= 0.01`; drives `FUN_0087cc20` (position) / `FUN_0087cc50` (handle) on the component at `+0x148` |
| `Sensory.ClearAllTrackObjects` | `0x007433e0` | `adapter` | `Sensory.ClearAllTrackObjects(hActor)` | inferred | hand-read; no corpus call site; zeroes `*(u32)(component+0x24)` and clears bit 0 of `*(u8)(component+0x40)` on the `+0x148` component |

**Corpus counts were produced by grep, not estimated**, and direct calls were not merged with bare table
references — for `Sensory` the distinction is moot and worth stating: `grep -rn "Sensory\."` returns **27**
lines and `grep -rn "Sensory\.[A-Za-z]*("` also returns **27**. Every reference to the table in the corpus
is a direct call; the table is never passed around as a value. 18 + 2 + 2 + 1 + 1 + 3 + 0 + 0 = 27.

## Two shapes again, and they fall on the same seam

The split that organises `Combat`/`Squad` reappears here almost too neatly. **Six of the eight are
`LuaGlueFunctor0R` queries that ask the perception system a question; two are `LuaGlueFunctor0` void
setters that mutate it.** And the split is not cosmetic — it is a different *component pointer*:

| Group | Rows | Component | Corpus use |
|---|---|---|---|
| Queries | `CanSee`, `HaveLOS`, `GetVisibleEnemyList`, `GetVisibleFriendList`, `GetClosestVisibleEnemy`, `GetAllCanSee` | none — they go straight to the object from `vtable+0x1c` | **27 call sites** |
| Track objects | `AddTrackObject`, `ClearAllTrackObjects` | **`*(obj + 0x148)`**, and both bail if it is null | **0 call sites** |

`+0x148` is byte-level, not read off the decomp's pointer arithmetic — `ClearAllTrackObjects` and
`AddTrackObject` both gate on it, and the exe shows it loaded straight into `ECX` as the receiver:

```
007433be  8b8d48010000    mov ecx, dword ptr [ebp + 0x148]
007433c4  e887981300      call 0x87cc50            ; AddTrackObject, handle form
```

This sits **8 bytes after the combat component at `+0x140`** that the verified part of this document
decodes. Two adjacent component slots on the same actor object, one combat, one track-object. That does not
contradict anything above — it constrains it: [the open question on `+0x140`'s
type](#open-questions) should be read as "which component *array* slot is this", since `+0x140` and `+0x148`
are plainly neighbours in one table of component pointers. *(Inferred: "table of component pointers" is a
reading of two adjacent gated slots, not something the binary states.)*

The two track-object bindings having **zero** call sites while the six queries carry all 27 is the same
pattern the verified section found in `Squad.*Objective*` — implemented, registered, and unused by shipped
content.

## `CanSee` is not `HaveLOS`, and the corpus knows it

These two look like synonyms and are not. They resolve their handles differently, gate differently, and
call different engine functions:

- **`CanSee`** (`FUN_00742f00`) resolves both handles through `FUN_00498440` → `FUN_004970d0`, refuses when
  the two objects are **the same** (`iVar3 != iVar5`), and calls **`FUN_0082da90`** — a 337-byte function
  whose `callers=[0x0074300c]` list contains **only this binding**. It is bespoke perception: full sensory
  evaluation, presumably FOV and awareness.
- **`HaveLOS`** (`FUN_00743040`) resolves through the `vtable+0x1c` accessor, requires `*(s16)(obj+0x11c)
  != -1` on both, and calls **`FUN_0082c8b0`** — 46 bytes, with callers all over the engine
  (`0x0078ae07`, `0x00893c3c`, `0x008d21a8`, …). It is the shared, general-purpose **geometric line-of-sight
  test**, not a perception query.

So `HaveLOS` answers "is there clear air between these two points"; `CanSee` answers "does this brain
currently perceive that thing". A soldier can have LOS to Sean and not see him — which is exactly what a
disguise is for. `Missions/P1FP_Traitor.lua` uses both, and uses them for different jobs: `CanSee` at
`:984` to decide whether the General has *spotted* Sean (`and not Actor.IsDisguised(self.hSab)` on the same
line — the script hand-checks the disguise the perception call does not), and `HaveLOS` at `:1064` and
`:1084` to decide whether a *shot* or a tail is geometrically possible. That one file exercising both
correctly is the best corroboration the split has.

## The `nil` vs `false` trap, and the corpus falls into it

Every one of the six queries is `LuaGlueFunctor0R` and every one of them has a **silent zero-result path**.
`CanSee` returns nothing — not `false` — when either argument is not lightuserdata, when either handle
fails to resolve, or when the two handles name the same object. Per §6 of the ABI notes, zero results
reaches Lua as `nil`. And in Lua 5.1, **`nil == false` is `false`**.

The corpus is split between the two idioms, and they are not equivalent:

```lua
if Sensory.CanSee(hTarget, self.hController) == false then     -- SoldierState_PaperCheckLeader.lua:41
if not Sensory.CanSee(self.hController, sab) then              -- Modules/Behavior/Human/Nazi/Soldier.lua:52
```

The `== false` form (also `Missions/Act_1_GetCaught.lua:1607,1623,1696,1702`) fires **only** on a genuine
engine "cannot see". If the actor has despawned and the handle no longer resolves, the call returns `nil`,
`nil == false` is false, and the branch does not fire — the script silently behaves as though the target
*can* be seen. The `not` form treats a dead handle and a genuine miss identically. Both readings are
defensible; what is not defensible is that the `== false` form — **5 sites corpus-wide, 4 of them in
`Act_1_GetCaught.lua` alone** — fails toward "seen" on a stale handle. *(Confirmed: the zero-result paths
are unambiguous in the body. **Inferred**: that any of these 5 sites is ever actually reached with a stale
handle — that would need a live run, not a static read.)*

The list queries dodge this by pushing an explicit `nil` on empty rather than an empty table
(`FUN_006f7010(); return 1;`), and the corpus reads them exactly that way — double-blind, since neither side
was consulted to produce the other:

```lua
if ... and Sensory.GetVisibleEnemyList(tParams.Handle) == nil then   -- Experimental/NaziTest_Combat.lua:27
                                                                     -- "I've lost my target!"
```

An engine that returns nil-for-empty and a script that tests `== nil` to mean "sees nobody" agree exactly.

## The lists are capped, and the cap is low

All three list queries build a **fixed stack buffer** and fill it. The capacity is a literal, and it is
confirmed in the exe rather than read off Ghidra's stack-array sizing:

| Binding | Buffer | Capacity | Byte evidence |
|---|---|---|---|
| `GetVisibleEnemyList` | `auStack_50` (80 = 10×8) | **10** | `007429eb  6a0a  push 0xa` |
| `GetVisibleFriendList` | `auStack_50` (80 = 10×8) | **10** | `00742c92  6a0a  push 0xa` |
| `GetAllCanSee` | `auStack_a0` (160 = 20×8) | **20** | `00742e4b  6a14  push 0x14` |

So **`Sensory.GetVisibleEnemyList` can never report more than 10 enemies**, and `GetAllCanSee` never more
than 20 observers, no matter how many are actually there. There is no overflow indicator — a script cannot
tell "10 enemies" from "10 or more". `Experimental/MgrHarasser.lua:368` does
`tVisibleEnemies[math.random(#tVisibleEnemies)]`, i.e. picks a random visible enemy; in a crowd it is
picking from a truncated sample of 10. For an ambient-life harasser that is fine; it is a real constraint
on anyone modding this surface.

The table itself is built by two wrapper primitives the [ABI doc](02-marshalling-abi.md)'s decoder ring does
not list, so both were read in full:

- **`FUN_006f69c0(n, 0)`** → `thunk_FUN_00623b60(L, n, 0)` = `lua_createtable(L, narr, nrec)`.
- **`FUN_006f6cc0(idx, key, value)`** → if `idx == -1`, `idx = lua_gettop(L)`; then
  `lua_pushnumber(L, (float)key)`, `lua_pushlightuserdata(L, value)`, `lua_settable(L, idx)`.

That pins the return shape exactly: a **1-based array whose values are lightuserdata handles**, keyed by
numbers that pass through doc 02's `float` `lua_Number` cast. `SoldierState_Combat.lua:32-38` reads it back
as precisely that (`for i = 1, #tCanSeeSoldier do ... Actor.HasLabel(tCanSeeSoldier[i], "Nazi")`).

Each entry is generation-checked before it is pushed (`piVar6[-1] & 0xffffff` against `DAT_01321e98`, the
generation byte against `DAT_01321e9c`) — this is [doc 03](03-handle-and-object-model.md)'s 24-bit-slot +
8-bit-generation handle model, independently visible here. `FUN_00497430` and `FUN_00497470`, which
`GetClosestVisibleEnemy` calls back-to-back, are **byte-identical 63-byte twins** performing that same
check — another COMDAT-fold escapee like [ABI Q4](02-marshalling-abi.md#open-questions)'s `FUN_006f6e80`.

One asymmetry, stated because it is odd rather than because it is understood: **`GetVisibleEnemyList` does
not generation-check the *querying actor* itself, and `GetVisibleFriendList` does.** `0x00742940` goes
straight from the null test to `vtable+0x1c`; `0x00742bc0` interposes the `piVar6[7] & 0xffffff` check that
every other `Sensory` binding performs. Two functions that are otherwise near-clones of each other differ
on one validity gate. *(Open — this could be a genuine missing check or a compiler artifact of the shared
inline; I did not chase it to a conclusion.)*

## The constant Ghidra got wrong

`AddTrackObject`'s trailing argument is bounds-checked and then scaled. The decomp renders this as:

```c
if ((fStack_1c < 0.0 == (fStack_1c == 0.0)) && (fStack_1c <= (float)_DAT_00f7bf80)) {
  fStack_1c = fStack_1c * (float)_DAT_00f9eeb8;
```

Read literally — `(float)` at both `DAT`s — those constants are **`0.0` and `2.0`**, which would make the
binding accept only zero. They are not. The exe loads both as **`qword`**:

```
00743361  dc1580bff700    fcom qword ptr [0xf7bf80]      ; 100.0
0074336e  dc0db8eef900    fmul qword ptr [0xf9eeb8]      ; 0.01
```

`0x00f7bf80` = `00 00 00 00 00 00 59 40` = **100.0** (double); `0x00f9eeb8` = `00 00 00 40 e1 7a 84 3f` =
**0.01** (double). Ghidra typed a `double` operand as `float` and read the low four bytes. The argument is a
**percentage, validated to `0 < x <= 100` and normalised to `(0, 1]`** — 100.0 and 0.01 being reciprocals is
the tell.

*(Precision footnote, re-derived: the `0.01` is not the nearest double to 1/100 — that would be
`3f 84 7a e1 47 ae 14 7b`. The stored value is `3f 84 7a e1 40 00 00 00` = `0.009999999776482582`, i.e. the
**`float` constant `0.01f` widened to `double`**, low mantissa bits zeroed. So the pair is reciprocal only to
`float` precision, not exactly. This does not weaken the reading — a `0.01f` written in C++ and promoted for
an x87 `fmul` is precisely what a percentage-normalising constant looks like — but "exact reciprocals" was
overstated and is corrected here.)* This is the doc-19 lesson repeating: the decomp is a lossy view, and *where the exe
and the decomp disagree, the exe wins*.

The bound is strict at the bottom, which the decomp's contorted rendering hides. `fldz; fcom st(1);
fnstsw ax; test ah, 0x41; jnp` bails on both `x < 0` **and** `x == 0` (only `C3=C0=0`, i.e. `x > 0`, has even
parity and falls through). So **`AddTrackObject(h, t, n, 0)` is silently a no-op** — zero percent is
rejected, not passed through as zero.

`AddTrackObject` also reuses the target-or-position overload the verified section documents for
`SetHunt`/`SetTether`: argument 2 is a handle *or* three numbers, and the trailing indices shift with the
form (`iVar3` = 3 or 5) — the same hand-written parser idiom, in a third table. Both trailing numbers are
mandatory in both forms: the type check has no `else`, so a missing one falls straight through to `ret`.

## How perception reaches suspicion — the seam is in Lua, not in the engine

[Doc 12](12-family-suspicion-wtf-alarm.md) does not mention `Sensory`, `CanSee`, or line-of-sight **once**
(grepped). That is not an oversight in doc 12 — it is the finding. **There is no engine-side binding that
wires perception to suspicion.** The two subsystems meet in the Lua FSM, and you can watch the join happen:

```lua
function Soldier:OnPlayerEntersWarnProximity()          -- Modules/Behavior/Human/Nazi/Soldier.lua:49
  Soldier.SetWarnProximityEvent(self, false)
  local sab = Handle("Saboteur")
  if not Sensory.CanSee(self.hController, sab) then     -- :52   <- the perception gate
    return
  end
  if Actor.IsInVehicle(sab) then return end             -- :55
  if Actor.IsDisguised(sab) then return end             -- :58
  ... ScriptSequence.Run(self.hController, tSeq)        -- :78   "nazi_halt_1"
  Cin.PlayConversationWith("cht_com_halt", ...)         -- :79
```

The engine fires a **proximity** event. Lua then asks `Sensory.CanSee`, and only if that passes — and the
player is not in a vehicle, and not disguised — does the soldier escalate. Proximity is engine; sight is a
Lua-initiated query; the decision is Lua's. The same shape appears at the checkpoint:

```lua
Suspicion.SetState(self.hController, "FlashingYellow")             -- SoldierState_PaperCheckLeader.lua:40
if Sensory.CanSee(hTarget, self.hController) == false then         -- :41
  local hClosestNazi = Sensory.GetClosestVisibleEnemy(Util.GetHandleByName("Saboteur"))  -- :42
```

Note what is in the **looker** slot at `:41` — `CanSee(hTarget, self.hController)` asks "can the *player*
see the *soldier*". The parameter order is the same `(hLooker, hTarget)` as everywhere else; what is
unusual is that this site deliberately puts the player there. The soldier is checking whether the man he is
about to challenge can see *him*, and if not, it finds a different Nazi who *is* visible to the player and
hails him instead. That is a staging decision, not a perception one: the game is making sure the "halt!"
comes from someone on screen.

`SoldierState_Combat.lua:31-38` shows the third pattern — perception as a **broadcast filter**:

```lua
Suspicion.SetState(self.hController, "Red")                        -- :26
local tCanSeeSoldier = Sensory.GetAllCanSee(self.hController)      -- :31
if tCanSeeSoldier ~= nil then
  for i = 1, #tCanSeeSoldier do
    if Actor.HasLabel(tCanSeeSoldier[i], "Nazi") then
      Util.BroadcastFunction(tCanSeeSoldier[i], "AttackTarget", {hTarget})
```

`GetAllCanSee` is the **inverse** query — not "who can I see" but "who can see me" — and it is used to
propagate a target only to Nazis who actually witnessed the soldier enter combat. Compare
`Util.BroadcastFunction(self.hController, cDISTANCE_YELL, "OnHeardFriendlyEnterCombat", ...)` three lines
above it (`:28`, its argument list running to `:30`), which propagates by **radius**. So the corpus has two alarm-propagation channels — one
geometric-by-distance, one gated by real line of sight — and this file uses both in the same function, for
different alarm types. Sound travels through walls; sight does not. That is the beating heart of the stealth
game, and it is implemented in script.

The wider picture this puts on the verified section: it noted the six `Combat.SetRespondTo*` bindings
"switch entire *senses* off" and that missions turn `Combat.SetAlwaysSeeTarget` on at **41** call sites.
`Sensory` is the read side of that same wall. `SetAlwaysSeeTarget` is a designer forcing the perception
answer; `Sensory.CanSee` is a designer asking for it. **Both exist because the AI's senses are a policy
surface, not a simulation** — and with 41 `SetAlwaysSeeTarget` sites against 18 `CanSee` sites, shipped
content overrides perception more than twice as often as it consults it.

## Open questions

- **`*(s16)(obj + 0x11c)` — the `!= -1` gate** shared by `HaveLOS` and `GetAllCanSee` but by none of the
  other six. A `-1` sentinel in a signed 16-bit field reads like an index into some registry (a physics
  proxy? a sensory-grid cell?) with "unregistered" as `-1`. Both bindings that touch geometry check it and
  the pure-perception ones do not, which is suggestive but not conclusive. Undecoded.
- **Is `+0x148` a *sensory* component or a *track-object* component?** Only the two track-object bindings
  gate on it; the six queries never touch it. So the name "sensory component" is unearned — it may be
  narrower than the table's name implies. Its vtable would settle it, as it would for
  [`+0x140`](#open-questions).
- **`FUN_0082da90` (`CanSee`) has exactly one caller — this binding.** A 337-byte bespoke perception routine
  reachable *only from Lua* is a strange thing for an engine to contain. Either the engine-internal AI
  reaches perception by another path entirely, or this is a script-only convenience wrapper over something
  shared. Worth pinning: it decides what "seeing" means in this game.
- **`AddTrackObject`'s two trailing numbers are unnamed.** The second is a percentage (byte-level).
  The first is unbounded and unscaled, and is passed as the middle float to `FUN_0087cc20`/`FUN_0087cc50`.
  Radius is the obvious guess and I have not verified it, so it is left as `n3`/`n5`.
- **Why does `GetVisibleEnemyList` skip the generation check that `GetVisibleFriendList` performs?**
  See the asymmetry above. If it is a real missing check, calling it on a stale handle reads a freed object.
- **The 10-entry cap has no overflow flag.** Whether the engine's `FUN_00877310` truncates or fails on
  overflow was not established — the binding cannot tell either way.
- **`AddTrackObject`/`ClearAllTrackObjects` have zero shipped callers.** Registered, implemented, and
  reachable, with a percentage argument and a three-way overload nobody uses. Cut feature, or driven from a
  script set not present in this corpus? Same question the verified section asks of `Squad.*Objective*` — and
  the [2008 pre-release build](../../docs/community_tooling.md) would settle both at once.

## Confidence

**Medium-high.** All 8 bodies read; 6 re-derived from `Saboteur.exe` with capstone. The **byte-level
confirmed** facts are: every arg-1 index (`push 1`), the 10/10/20 caps (`push 0xa`/`push 0x14`), the
100.0/0.01 doubles and the strict `x > 0` bound, `+0x148` as the track component (`mov ecx, [ebp+0x148]`),
and the identity of the push primitives (`0x4019b0` `lua_pushboolean`, `0x4019d0`
`lua_pushlightuserdata`, `FUN_006f69c0` `lua_createtable`, `FUN_006f6cc0` `lua_settable`). **Inferred** are
the semantic readings — `CanSee` vs `HaveLOS` as perception vs geometry (argued from distinct callees and
distinct corpus usage), the percentage interpretation (argued from the 100/0.01 reciprocal pair), and the
component-array reading of `+0x140`/`+0x148`. **No row is assertion-anchored**; identity for all 8 rests on
the registration map, which is [the catalog's known single point of failure](README.md). Nothing here is
imported from Mercenaries 2.
