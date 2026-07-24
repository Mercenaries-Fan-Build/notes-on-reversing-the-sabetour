# Family 18 — Cinematics / Camera / Face-expression bindings

> **Verified:** All 16 VAs re-checked against the tsv (exact match) and the decomp (14 present, 2 genuinely
> absent as claimed); every stub's six bytes, the `60.0f`/`0.6f`/`-1.0f` constants, all bit-masks, the
> `bLoop`→flag-`0x20` link, and every quoted corpus file:line re-read and confirmed; counts (88/28/25/27/10/5,
> 24/24 boundary, 86 `inlined`) all reproduce. Corrected: the `60.0f` is in `.data`, not `.rdata`; the claim
> that scripts "never" call the node bindings directly (three sites do, two of them cited in this doc's own
> table); an unreproducible "16 of 21" wrapper count (actual: 10 wrapper sites vs 3 direct); `camera.md`'s
> open item is only *partially* closed (`GetPointInViewOnRoad` remains unpinned); "tail-calls" → `call`;
> "differing only in its last argument" (middle args differ too); `FUN_006f7020 = lua_pushboolean` downgraded
> to inferred.

Part of the [engine↔Lua seam series](00-seam-overview.md). Read [`02-marshalling-abi.md`](02-marshalling-abi.md)
first — every signature below is derived with that decoder ring, and its traps (hidden `this`, silent
zero-on-mismatch, `void` meaning nothing, `family` deciding `nresults`) all bite here.

Engine-side subsystem cross-reference: [`../symbol_map/cinematics.md`](../symbol_map/cinematics.md)
(`WSCinematicsManager`, `WSCinematic`) and [`../symbol_map/camera.md`](../symbol_map/camera.md)
(`WSGameCamera`, camera-shake, `WSSlowMotionCameraBlueprint`). This doc **pins four of the five Lua binding
entry VAs that `camera.md` explicitly lists as unpinned** (its open item: *"Lua binding thunks … are
`LuaGlueFunctor` wrappers and are not inline strings — only their downstream implementations are pinned, not
the binding entry VAs"* — the fifth, `GetPointInViewOnRoad`, is outside this family), and **corrects two
identifications in `cinematics.md`** — see [Corrections](#corrections-to-the-existing-symbol-map).

## Inclusion rule (auditable)

A binding is in this family iff the case-insensitive regex `cinemat|camera|faceexpression` matches
its `cpp_symbol` in [`../../data/lua_bindings.txt`](../../data/lua_bindings.txt). The same regex over the
`cpp_symbol` column of [`../../data/lua_registration_map.tsv`](../../data/lua_registration_map.tsv) yields
the identical set (verified both directions), so the partition is stable regardless of which list you start
from. That yields **16 bindings**.

Deliberate consequences, called out so the boundary is auditable:

- **Do not use `cam` or `fov` as a substring.** `fov` matches `WTFOverrideTransition*` — the letters `FOv` of "WTFOverride" — (three `Render.*`
  bindings). They are **not** in this family.
- **The `Cin` table has 32 rows; only 8 match.** The other 24 (`Cin.PlayConversation`,
  `Cin.PlayBinkMovie`, `Cin.GetLocalizedText`, `Cin.ActivateObjectSpline`, `Cin.SetSpeakerWeight`, …) are
  conversation / Bink / localisation / spline bindings that happen to live in the cinematics *table*. They
  are **not silently omitted** — they are enumerated in [Boundary: the rest of the `Cin` table](#boundary-the-rest-of-the-cin-table)
  below, with VAs, and left to the conversation/dialogue family. Note the corollary: **the `Cin` table is
  not the cinematics family**, and three of this family's members (`Util.SpawnCinematicNode`,
  `Util.UnloadCinematicNode`, `Util.StartSlowMotionCamera`) are not in the `Cin` table at all.
- **Claimed despite ambiguity.** `Actor.AddFaceExpression` is an animation binding (it drives a facial-anim
  sub-object, not a camera); it is claimed here only because the assignment scopes `FaceExpression`. See
  [`../symbol_map/animation.md`](../symbol_map/animation.md). `Vehicle.SetTakeDamageInCinematic` is a
  vehicle-damage flag; it matches on `cinematic` and is claimed, overlapping
  [`13-family-vehicle-train-plane.md`](13-family-vehicle-train-plane.md).
  `FocusPt.{Get,Set}ForceCameraFocus` are two of eighteen `FocusPt.*` bindings; the other sixteen belong to
  the mission/objective family ([`15-family-mission-objective-task.md`](15-family-mission-objective-task.md)).
  Claimed here, sibling context noted.

## Coverage

**16 of 16 bindings in this family located. 0 confirmed by assertion string. 16 confirmed by the
registration map (byte-level identity). 14 bodies read from the decomp; 2 bodies not present in the decomp
and disassembled directly from retail `Saboteur.exe` (see [Method note](#method-note-two-bindings-are-not-in-the-decomp)).
11 corroborated by real Lua call sites; 5 have no caller anywhere in the 321-file corpus. 0 not found.**

**Not one binding in this family carries an EALA assertion string** — the whole
`Script\Interface\Cinematics.cpp`-shaped anchor does not exist. Every identity below rests on the
registration map, and every signature on the body. Where the two disagree with existing prose, the bytes win.

## The table

`VA` = `impl_va` from [`../../data/lua_registration_map.tsv`](../../data/lua_registration_map.tsv).
Signatures use `h` = handle (lightuserdata), `s` = string, `b` = boolean, `n` = number, `t` = table.
Optional args in `[]`. "Source (file:line)" is empty for all 16 — **no assertion strings in this family**.

| Binding | Namespaced form | VA | Source (file:line) | Signature | Confidence | Evidence |
|---|---|---|---|---|---|---|
| `PlayCinematic` | `Cin.PlayCinematic` | `0x0071dbc0` | — (no assert) | `(sName [, bLoop] [, sCallback, self] [, tParams] [, bFade] [, sMusic]) -> ()` | **confirmed** (identity, marshalling); *inferred* (arg names) | tsv row 180 (`LuaGlueFunctor0`/`adapter`); body `FUN_0071dbc0`; 88 corpus sites, widest is `Act_3_Mission_3.lua:1367` (7 args) |
| `LoadCinematic` | `Cin.LoadCinematic` | `0x0071dd80` | — | `(sName [, sCallback, self] [, tParams]) -> ()` | **confirmed** (identity, marshalling) | tsv row 176; body `FUN_0071dd80` → `FUN_00951270(name, cb)`; 28 corpus sites, **all 1-arg** (`Act_1_BarFight.lua:33`) |
| `PrePlayCinematic` | `Cin.PrePlayCinematic` | `0x0071c3b0` | — | `(sName) -> ()` | **confirmed** (identity, marshalling); *open* (semantics) | tsv row 184; body calls `FUN_0094f710(name, **1**, 0,0,0,0,&0)` — mode 1, vs mode 2 for Play. **Zero corpus call sites** |
| `PauseCinematic` | `Cin.PauseCinematic` | `0x0071c430` | — | `(sName) -> ()` | **confirmed** | tsv row 178; body → `FUN_0094cab0(name)` → `FUN_00944b60()`; `Paris_6_Mission_1.lua:301,303,527,529` |
| `StopCinematic` | `Cin.StopCinematic` | `0x0071c490` | — | `(sName [, bHard=true]) -> ()` | **confirmed** (marshalling); *inferred* (arg-2 meaning) | tsv row 191; body → `FUN_0094cb10(name, !bHard)`; 25 corpus sites, one 2-arg: `Act_1_Farm.lua:95` |
| `IsPlayerCloseToCinematic` | `Cin.IsPlayerCloseToCinematic` | `0x0071c9f0` | — | `(hLocator \| sLocatorPath) -> b` | **confirmed** (disassembled from exe; threshold read from `.data`) | tsv row 175 (`LuaGlueFunctor0R`/`jmp`); disasm `0x0071c9f0`–`0x0071cb19`; 10 corpus sites, all `if …then` (`P3FP_BiggerGun.lua:367`) |
| `SetCinematicStreaming` | `Cin.SetCinematicStreaming` | `0x0071e7f0` | — | `(bAny) -> ()` — **STUB, does nothing** | **confirmed** (byte-level: `B8 01 00 00 00 C3`) | tsv row 186 (`inlined`); disasm `0x0071e7f0` = `mov eax,1; ret`. Called for real at `P3FP_FountainSniper.lua:624` |
| `AllowAttackingDuringCinematics` | `Cin.AllowAttackingDuringCinematics` | `0x0071cdf0` | — | `(bAllow) -> ()` | **confirmed** | tsv row 163; body sets bit 3 (mask `0x08`) of `*(byte*)(DAT_0143e6f4 + 0x1255)`; 5 corpus sites |
| `SpawnCinematicNode` | `Util.SpawnCinematicNode` | `0x0074cef0` | — | `(sNode [, sCallback, self] [, tParams]) -> ()` | **confirmed** (marshalling) | tsv row 792; body → `FUN_009f2950(nodeCRC, 0)`; `WorldSMEDNodes.lua:34,36,47`; `Act_3_Mission_2.lua:1356` |
| `UnloadCinematicNode` | `Util.UnloadCinematicNode` | `0x0074d020` | — | `(sNode) -> ()` | **confirmed** | tsv row 804; body → `FUN_009f4fa0(nodeCRC)`; `WorldSMEDNodes.lua:68`; `Connect_ST_405_BackToSaarbruken.lua:168` |
| `CameraShakeExplosion` | `Render.CameraShakeExplosion` | `0x0073e7b0` | — | `(nX, nY, nZ [, n4=0] [, n5=0] [, n6=0]) -> ()` | **confirmed** (marshalling); *open* (meaning of args 4–6) | tsv row 445; body → `FUN_00677c60(&vec3, n4, n5, n6, 0.6f, 0, 0)`; 27 corpus sites, always 6-arg (`Act_3_Mission_3.lua:1335`) |
| `StartSlowMotionCamera` | `Util.StartSlowMotionCamera` | `0x00753440` | — | `(sTargetName, sBlueprintName, bEnable) -> ()` | *inferred* (identity confirmed; arg roles from callee) | tsv row 798; disasm `0x00753440` → `FUN_0067a660` (thunk → `FUN_01631380` = `SlowMotionCamera::Apply`, [`camera.md`](../symbol_map/camera.md)). **Zero corpus call sites** |
| `AddFaceExpression` | `Actor.AddFaceExpression` | `0x0070f0f0` | — | `(hActor \| sActorName, sExpression [, nWeight=-1.0]) -> ()` | **confirmed** (marshalling); *inferred* (arg-3 = weight) | tsv row 2 (table `Actor`); body `FUN_0070f0f0`; default `DAT_00f7ac80` = `-1.0f` read from `.rdata`. **Zero corpus call sites** |
| `SetTakeDamageInCinematic` | `Vehicle.SetTakeDamageInCinematic` | `0x00760720` | — | `(hVehicle, bTakeDamage) -> ()` | **confirmed** | tsv row 886; body writes `*(byte*)(vehicle + 0x16f8) = b`; `Paris_6_Mission_1.lua:1442` |
| `FocusPtSetForceCameraFocus` | `FocusPt.SetForceCameraFocus` | `0x00728f50` | — | `(bForce) -> ()` | **confirmed** | tsv row 272; body sets bit 1 (mask `0x02`) of `*(byte*)(DAT_01494360 + 0x10c60)`. **Zero corpus call sites** |
| `FocusPtGetForceCameraFocus` | `FocusPt.GetForceCameraFocus` | `0x00728fc0` | — | `() -> b` | **confirmed** | tsv row 268 (`LuaGlueFunctor0R`/`jmp`); body pushes `(*(byte*)(DAT_01494360+0x10c60) >> 1) & 1`, `return 1`. **Zero corpus call sites** |

Note the flat-vs-namespaced spread: eight names pass through unchanged into `Cin.*`, three unchanged into
`Util.*`, one into `Render.*`, one into `Actor.*`, one into `Vehicle.*`, and the two `FocusPt*` names lose
their prefix (`FocusPtSetForceCameraFocus` → `FocusPt.SetForceCameraFocus`). Exactly as
[`02-marshalling-abi.md`](02-marshalling-abi.md) §0 warns, the prefix rule is not mechanical — read the tsv.

## Method note: two bindings are not in the decomp

`0x0071c9f0` (`IsPlayerCloseToCinematic`) and `0x0071e7f0` (`SetCinematicStreaming`) have **no `==== FUN_…`
stanza** in `saboteur_all_functions_decomp.txt` — Ghidra never created a function there, because both are
reached only through the generated registration table (the un-disassembled thunk region
[`01-registration-and-dispatch.md`](01-registration-and-dispatch.md) documents). The registration map pins
their VAs anyway, because it is read from the exe's bytes rather than from Ghidra's function list.

Both bodies below were therefore recovered by disassembling retail `Saboteur.exe`
(`ImageBase 0x00400000`, `capstone` x86-32) at the tsv's `impl_va`. **This is the general escape hatch when
the tsv names a VA the decomp does not cover**, and it is worth knowing: the tsv's coverage of the binding
set is strictly better than the decomp's.

## How the subsystem actually works

### Cinematics: a name-keyed manager, and Play is Load

Every one of the eight `Cin.*` cinematic bindings does the same first thing: it takes a **name string**,
never a handle, and hands it to the `WSCinematicsManager` singleton, which CRC-interns it via `FUN_00db7e10`
and looks it up in a `PblTree<WSCinematicBlueprint, PblCRC>` under the critical section at `manager+0x80`
([`../symbol_map/cinematics.md`](../symbol_map/cinematics.md) pins these). Handles never appear. This is the
save/load story from [`03-handle-and-object-model.md`](03-handle-and-object-model.md) §7 playing out: a
cinematic outlives any session-scoped handle, so the seam is a string.

The four verbs are one function with a mode byte. `FUN_0094f710` is
`__thiscall(mgr, sName, nMode, pCallback, 0, bLoop, bFade, pMusicCRC)`:

| Lua | Calls | Mode |
|---|---|---|
| `Cin.PrePlayCinematic` (`FUN_0071c3b0`) | `FUN_0094f710(name, **1**, 0,0,0,0,&0)` | 1 |
| `Cin.PlayCinematic` (`FUN_0071dbc0`) | `FUN_0094f710(name, **2**, cb, 0, bLoop, bFade, &musicCRC)` | 2 |

and `FUN_0094f710` branches on `(char)param_3 == '\x02'` for the play path. `Cin.LoadCinematic`
(`FUN_0071dd80`) skips the mode dispatcher entirely and calls `FUN_00951270(name, cb)` directly.

The important behavioural fact is what happens on a **tree miss**: both `FUN_0094f710` and `FUN_00951270`
fall through to `FUN_00950ef0` — the same streaming-load routine. Its **last** argument is the telling
difference, `1` for Play and `0` for Load; the middle arguments differ too (Play forwards its whole
parameter block `FUN_00950ef0(name, mode, cb, p5, bLoop, bFade, pMusic, 1)`, whereas Load hardcodes zeros
and passes the callback in slot 3: `FUN_00950ef0(name, 0, cb, 0, 0, 0, &local, 0)`). **So
`Cin.PlayCinematic` on an unloaded cinematic loads it on demand.** The
28 `Cin.LoadCinematic` call sites in the corpus are a *latency* optimisation, not a correctness
requirement — which is why they always appear a few hundred lines before the matching `PlayCinematic`
(`Act_1_BarFight.lua:33` loads `"106_CinA_BarFight"`; the mission plays it much later) and why
`Act_3_Mission_1.lua:544-570` fires six `PlayCinematic` calls with no `Load` in sight at all.

`FUN_00951270` also reveals the load-callback contract: on a tree **hit** with a non-null callback, it
invokes the callback **immediately, synchronously, inside the binding call**, rather than deferring it. A
script that does `Cin.LoadCinematic(n, "M.Ready", self)` and expects `M.Ready` on a later frame is wrong if
`n` is already resident. The corpus never finds out: **all 28 `Cin.LoadCinematic` sites pass exactly one
argument**, so the callback path of `LoadCinematic` is dead code in the shipped scripts.

### `Cin.PlayCinematic`'s argument list is positionally ambiguous — deliberately

`FUN_0071dbc0` is the most intricate body in the family and the only one in it that shifts its own argument
numbering. After `sName` at index 1 it computes a cursor `iVar9`:

```c
cVar1 = FUN_006f7120(2);          // is arg 2 a BOOLEAN?
if (cVar1 != '\0') {
  uStack_c = FUN_006f6e60(2);     //   yes -> that's bLoop
  if (argc < 3) goto call;
  if (!FUN_006f7160(3)) return;   //   and the callback name must then be at 3
  iVar9 = 3;
} else { iVar9 = 2; }             //   no  -> the callback name is at 2, bLoop defaults false
pcVar5 = FUN_006f7a80(iVar9);     // callback NAME
... FUN_0070a4b0(iVar9 + 1);      // self table
... FUN_006f71c0(iVar9 + 2)       // optional tParams
... FUN_006f7120(iVar9 + 3)       // bFade
... FUN_006f7160(iVar9 + 4)       // sMusic (interned)
```

So `bLoop` is **skippable**, and every downstream argument slides by one when you skip it. This is the only
default-argument-like mechanism anywhere in the 898 — and it is not one; it is a hand-written type probe.
It also explains why the shipped scripts are so rigid about writing `false` explicitly:

```lua
-- Act_3_Mission_3.lua:1367  (all seven slots, iVar9 = 3)
Cin.PlayCinematic("A3M3_Skylar_FirstFly_Cam", false, "Act_3_Mission_3.SetupDestroyedStateOfBombing", self, nil, false, "")
-- Act_3_Mission_1_E3.lua:434  (four slots)
Cin.PlayCinematic("221_CinA_BlimpCrash", false, "Act_3_Mission_1_E3.E3_UnPause", self)
-- Act_1_BarFight.lua:70      (one slot)
Cin.PlayCinematic("A1M1_Barflyby")
```

Every multi-arg site in the corpus passes the boolean, i.e. **`iVar9 = 3` universally in shipped content**;
the `iVar9 = 2` branch is reachable but unexercised. Note also that the callback here follows the family
rule from [`02-marshalling-abi.md`](02-marshalling-abi.md) §10 exactly — **arg 3 is a dotted callback
*name string*, split on `'.'` by `FUN_0070a180`, never a function value.** There is no `luaL_ref` here either.

`FUN_0070a4b0(iVar9+1)` is the `self` binder: it reads `"hController"` from the table, or falls back to
`"_SELFTABLE_ID"`, and stores the result plus a discriminator into the callback record — the same mechanism
[`05-engine-to-lua-callbacks.md`](05-engine-to-lua-callbacks.md) describes. Passing `self` is how a
mission's method gets a receiver.

### `Cin.StopCinematic`'s second argument is inverted, and mostly inert

```c
cVar1 = '\x01';                                    // default
if (argc > 1 && FUN_006f7120(2)) cVar1 = FUN_006f6e60(2);
FUN_0094cb10(name, cVar1 == '\0');                 // <-- NOT the argument
```

The engine receives `!arg2`. Inside `FUN_0094cb10`, a **true** third parameter takes a soft path — *if* the
instance's flag `0x20` at `+500` is set, clear it and return; otherwise hard-stop via
`FUN_00945110(1)` (`WSCinematic::Stop`, pinned by its own assert in
[`../symbol_map/cinematics.md`](../symbol_map/cinematics.md)). Flag `0x20` is the same bit `FUN_0094f710`
writes from `PlayCinematic`'s `bLoop`. So the mechanism is: *"if this cinematic is looping, first cancel the
loop rather than cutting the camera."*

The inversion means `Cin.StopCinematic(name)` and `Cin.StopCinematic(name, true)` are **identical** — both
send `false` and hard-stop. Only `Cin.StopCinematic(name, false)` reaches the loop-cancel path, and **no
call site in the corpus ever does that**: `Act_1_Farm.lua:95` passes `true` to stop
`"A1M5_LODPlanesLoop_01"` — a cinematic whose name says it loops, taking the *hard* path. Either the script
author had the polarity backwards, or the intended reading of arg 2 is the opposite of `bLoopCancel`. The
argument's authored meaning is **open**; its mechanics are confirmed.

### `Cin.IsPlayerCloseToCinematic`: a hardcoded 60-unit, 2-D check

This is the only interesting getter in the family, and it was invisible until disassembled:

```asm
0071ca35  call  0x6f71a0          ; arg 1 lightuserdata? -> handle
0071ca42  call  0x6f6ec0
0071ca49  call  0x6f7160          ; else string? -> intern to a symbol
0071ca5c  call  0x6f7a80
0071ca66  call  0xdb7e10
0071ca72  call  0x67c0a0          ; symbol/ID -> object   (esi)
0071ca8a  mov   edx, [ecx+0x950]  ; DAT_01240328 + 0x950
0071ca99  call  eax               ;   vtable+0x28 -> ebx = player position
0071caa4  call  eax               ; esi vtable+0x14 -> eax = locator position
0071caa6  fld   [eax]  / fsub [ebx]        ; dx  = X difference
0071cab0  fld   [eax+8]/ fsub [ebx+8]      ; dz  = Z difference   <-- +4 (Y) is SKIPPED
0071cac2  fld   [0x11c1fb0]                ; 60.0f
...       ; compare (dx*dx + dz*dz) against (60.0 * 60.0)
0071caeb  push 1 / call 0x6f7020 / mov eax,1 / ret     ; push true, 1 result
0071cafe  push 0 / call 0x6f7020 / mov eax,1 / ret     ; push false, 1 result
0071cb11  xor eax, eax / ret                           ; bad arg -> 0 results
```

Three findings:

1. **The threshold is a hardcoded `60.0f`** at `.data:0x011c1fb0` (bytes `00 00 70 42`). It is not a
   parameter and cannot be reached from script. (It lives in `.data`, not `.rdata` — the exe's `.rdata`
   ends at `0x01111000`. Nothing reads or writes it but this one `fld`, so it is constant in practice, but
   a runtime patch could move it in a way a true `.rdata` constant could not.) Every one of the ten `if Cin.IsPlayerCloseToCinematic(…)`
   sites is asking exactly one question: *"is the player within 60 units?"* — including
   `P1FP_PalaisBombe.lua:141`, whose own locator is named `WTF_Shift_DistCheck`, and
   `FP_AMB_ChemFactoryStart.lua:140` (`LOC_ChemFac_WTFDist`). The scripts name their locators after a
   distance they cannot set.
2. **The check is horizontal.** It reads the position's `+0` and `+8` and skips `+4`. Under the
   engine's Y-up convention that is X and Z — **altitude is ignored**. `P3FP_BiggerGun.lua:367` checks
   `"Missions\cinematics\wtf\wtf_fp_pantheon\FX_Explosion"`; a player 200 units above the Panthéon on a
   rooftop still counts as "close".
3. **The bad-argument path returns 0 results, not `false`.** `xor eax,eax; ret` at `0x0071cb11` means Lua
   sees `nil`. Since `if nil then` and `if false then` behave identically, a typo'd locator path is
   indistinguishable from "player is far away" — the silent-failure pattern of
   [`02-marshalling-abi.md`](02-marshalling-abi.md) §6, here with a genuinely deceptive result.

This also surfaces a marshalling primitive the ABI doc does not list: **`FUN_006f7020` is a boolean push** —
*inferred*, not proven to be `lua_pushboolean` by name. It is `jmp 0x43fbc6`, which does
`movzx eax, byte [esp+4]` and jumps straight back to `0x006f7025` (another Ghidra split across an
inter-procedural jump), i.e. it byte-truncates its argument before pushing — exactly what a boolean push
does. `FocusPt.GetForceCameraFocus` at `0x00728fc0` **calls** it the same way (at `0x00729011`, then
`mov eax,1; ret` — a regular call, not a tail-call), pushing a value already masked to `0`/`1`. The
callee-name attribution is a proposal for [`02-marshalling-abi.md`](02-marshalling-abi.md) §6's push list,
not a pin.

### `Cin.SetCinematicStreaming` is a stub, and it is not alone

```asm
0071e7f0  B8 01 00 00 00   mov  eax, 1
0071e7f5  C3               ret
```

Six bytes. The whole binding. It reads no argument and touches no state; the `1` is only the
`nresults` the `inlined` shape must return. `P3FP_FountainSniper.lua:624` calls
`Cin.SetCinematicStreaming(true)` in shipped retail content, and **nothing happens**.

Because the tsv's `shape` column made these cheap to find, I swept the sibling `inlined` bindings in the
same registration blocks. `inlined` does **not** imply stub — but five nearby ones are:

| Binding | VA | Bytes | Verdict |
|---|---|---|---|
| `Cin.SetCinematicStreaming` | `0x0071e7f0` | `mov eax,1; ret` | **stub** (in this family) |
| `Cin.SubtitlesOn` | `0x0071e950` | `mov eax,1; ret` | **stub** |
| `Cin.SetSpeakerWeight` | `0x0071ea30` | `mov eax,1; ret` | **stub** |
| `Cin.DEBUGTeleportToLocator` | `0x0071eaf0` | `mov eax,1; ret` | **stub** (debug, stripped for retail) |
| `FocusPt.SetTexture` | `0x00729940` | `mov eax,1; ret` | **stub** |
| `Cin.StopBinkMovie` | `0x0071ebf0` | `mov ecx,[0x143ceac]; call 0x7c4310; …` | real |
| `Cin.BinkDemoPlay` | `0x0071ebb0` | `cmp byte [0x11286ec],0; …` | real |
| `FocusPt.UnloadMissionPictures` | `0x00729ae0` | `mov ecx,[0x1494360]; call 0x992f60; …` | real |

`Cin.SubtitlesOn` being a stub is the striking one, and it is outside my family — flagged for the
conversation/dialogue family rather than claimed. `FocusPt.SetTexture` is likewise flagged for the
mission/objective family; note [`../symbol_map/render-fx-light.md`](../symbol_map/render-fx-light.md) lists
`FocusPtSetTexture` as a "backend not yet pinned" binding, and the answer is that **there is no backend**.

The generalisable lesson: **the tsv's `shape` column is a stub detector.** A `LuaGlueFunctor0`/`inlined` row
is a five-second disassembly away from a yes/no answer on whether a binding does anything at all. This
family alone turns up one live-but-inert call in shipped content; a full sweep of all 86 `inlined` rows
would likely turn up more.

### Cinematic nodes are a different subsystem wearing the same word

`Util.SpawnCinematicNode` / `Util.UnloadCinematicNode` are **not** `WSCinematicsManager` calls at all —
they go to `FUN_009f2950` / `FUN_009f4fa0` in the `0x009fxxxx` streaming cluster. A "cinematic node" is a
**SMED world node** (a chunk of props/geometry), not a cinematic. Both bindings begin by basename-ing their
argument:

```c
pcVar4 = FUN_006f7a80(1);
pcVar5 = _strrchr(pcVar4, 0x5c);              // '\\'
if (pcVar5 != NULL) pcVar4 = _strrchr(pcVar4, 0x5c) + 1;   // keep only the leaf
```

So `Util.SpawnCinematicNode("Missions\\act_3\\411cinprops")` and `Util.SpawnCinematicNode("411cinprops")`
are the same call — the path is decoration. The corpus is consistent with this: `WorldSMEDNodes.lua` and
`Act_3_Mission_2.lua:1356` pass bare leaf names, and `WorldSMEDNodes.CallbackCinematicNodeLoaded`
(`WorldSMEDNodes.lua:53-60`) compares with `string.upper()` on both sides — the Lua layer independently
re-implements the case-insensitivity the engine gets for free from CRC interning.

`Util.SpawnCinematicNode`'s callback binds identically to `PlayCinematic`'s (`FUN_00626e00` record,
`FUN_0070a180` name split, `FUN_0070a4b0(3)` self, optional table at 4, registered by
`thunk_FUN_0162df80`), except the cursor is fixed at 2 — no `bLoop` to skip.

This is a real seam-design observation: **scripts are meant to reach these bindings only through a wrapper,
and three sites don't.** `WorldSMEDNodes.lua` wraps both behind `LoadCinematicNode` /
`PreLoadCinematicNode` / `UnloadCinematicNode`, maintaining `tWorldCinematicNodeList` with
`cSM_LOADING`/`cSM_LOADED` states, because the engine offers **no "is this node loaded?" binding** —
`WorldSMEDNodes.IsCinematicNodeLoaded` is pure Lua bookkeeping over `Common.IsNodeLoaded`. The wrapper also
adds a `bForceUnload` parameter the binding does not have (`Act_3_Mission_2.lua:912` uses it).

The exact split, counted over the corpus: **ten** wrapper call sites outside `WorldSMEDNodes.lua`
(`WorldSMEDNodes.{Load,PreLoad,Unload}CinematicNode`, e.g. `SabTask.lua:603,648`,
`Act_3_Mission_2.lua:912,1399`, `Paris_1_Mission_1.lua:155,159,1499`), against **four** binding calls inside
the wrapper itself (`:34,36,47,68`) and **three** mission-script sites that call the binding *directly*,
bypassing the bookkeeping entirely: `Act_3_Mission_2.lua:1356` (`Util.SpawnCinematicNode`) and
`Connect_ST_405_BackToSaarbruken.lua:168` and `:172` (`Util.UnloadCinematicNode`). Note that this makes the
load state **script state**, and those three sites are precisely the hazard: a script that loads or unloads
a node behind the wrapper's back desynchronises `tWorldCinematicNodeList` permanently. Whether that is a
real defect depends on whether those nodes are ever also tracked through the wrapper — not checked.

`FUN_009f4fa0` is more than a free: it increments a 5-bit counter in the node's bit-field
(`*p = (*p & ~0xf8) | (((*p & 0xf8) + 8) & 0xf8)` — a generation/refcount at bits 3–7) before calling
`FUN_00a08330` and taking **two** critical sections (`DAT_014ab064`, `DAT_014ab0ac`) around
`FUN_00a07730`. Streaming nodes are touched by more than one thread; cinematics are not.

### Camera: three bindings, and a shared render-context gate

`Render.CameraShakeExplosion` (`FUN_0073e7b0`) is the family's workhorse — 27 corpus sites, always six
arguments. Only the first three are guarded:

```c
if (FUN_006f7140(1) && FUN_006f7140(2) && FUN_006f7140(3)) {
  FUN_006f79d0(auStack_10, 1);       // read the position vector starting at index 1
  FUN_006f7140(4); f4 = FUN_006f7950(4);   // <-- check result DISCARDED
  FUN_006f7140(5); f5 = FUN_006f7950(5);
  FUN_006f7140(6); f6 = FUN_006f7950(6);
  if (0 < DAT_01321b78 && DAT_01321b74 != 0)
    FUN_00677c60(&vec3, f4, f5, f6, 0.6f, 0, 0);
}
```

The three `FUN_006f7140(4..6)` calls have their return values thrown away — so arguments 4, 5 and 6 are
**optional with default `0.0`**, since `FUN_006f7950` silently returns zero on a non-number. `(x,y,z)` alone
is a legal call that shakes nothing. The `0.6f` is `_DAT_00f82634`, read from `.rdata` — a hardcoded
constant slotted between the script floats and two zeros.

What arguments 4–6 *mean* is **open**. [`../symbol_map/camera.md`](../symbol_map/camera.md) calls the
fourth `radius` and pins `FUN_00678e20` as the distance-attenuated explosion-shake computer using
`((_DAT_00f7bf80 - dist)/_DAT_00f7bf80)`, which is consistent with arg 4 being a radius — but the binding
does not call `FUN_00678e20`; it calls `FUN_00677c60`, and I did not trace the chain between them. The
corpus offers only ranges: `(20,10,12)` at `Act_3_Mission_3.lua:1335`, `(70,70,70)` at
`Act_3_Mission_3.lua:2648`, `(105,90,90)` at `Paris_3_Mission_1.lua:923`, `(25,30,100)` at
`Paris_6_Mission_1.lua:1276`, and — most informative — `Paris_2_Mission_5.lua:1948` scaling only the
**fourth** with mission progress: `(x, y, z, 1 + (self.tSaveInfo.BoilerSplode - 1), 20, 30)`, then
`(x, y, z, 8 + 2*(self.tSaveInfo.BoilerSplode - 1), 20, 30)` at line 2029. **Arg 4 is the one that grows as
the boiler gets closer to blowing**, which reads as magnitude or radius, not duration. That is a hint, not a
derivation.

One correction is worth flagging: `FUN_00677c60` is not a forwarder despite its 8-byte Ghidra listing. It
disassembles to `push ebp; mov ebp,esp; jmp 0x520496`, and `0x00677c69` — which `camera.md` calls "the
per-frame shake integrator" — is `mov [ebp-0xb0], ecx`, i.e. **the continuation of the same function's
prologue**. `FUN_00677c60` and `FUN_00677c69` are one function, split by Ghidra across an obfuscated
inter-procedural jump. Its four callers are `0x00677c4c`, `0x006a4851`, `0x0093dd04`, and — pinned here —
the Lua binding at `0x0073e8b6`.

`Util.StartSlowMotionCamera` (`0x00753440`) is the family's only unexercised camera binding and needed
disassembly to read, because Ghidra's decomp mangles its stack:

```asm
00753484  call 0x6f7a80        ; arg 1 as string  -- NOTE: no type check first
00753490  call 0xdb7e10        ;   intern it
0075349a  mov  ecx, [0x1494484]
007534a0  call 0x9a0010        ; symbol -> world object (edi)
007534b0  call 0x6f7a80        ; arg 2 as string (ebx)   -- again unchecked
007534bf  call 0x6f6e60        ; arg 3 toboolean
007534cc  call 0x6f7120        ;   ...and arg 3 MUST be a boolean, else bail
007534dc  call 0xdb7e10        ; intern arg 2
007534e7  cmp  [0x1321b78], ecx
007534ee  setle cl
007534f7  sub  ecx, 1
007534fa  and  ecx, [0x1321b74]     ; ecx = render context, or NULL if 01321b78 <= 0
00753500  call 0x67a660             ; -> FUN_01631380 = SlowMotionCamera::Apply
```

`FUN_0067a660` is the thunk to `FUN_01631380`, which
[`../symbol_map/camera.md`](../symbol_map/camera.md) pins as the routine that loads the
`SlowMotionCamera_Default` blueprint (line 1760304) and applies it via `FUN_0067aee0`, setting state `4` at
`+0x2c`. Given `camera.md`'s blueprint table — `SlowMotionCamera` is a factory type with instances named
`SlowMotionCamera_Default` and `SlowMotionCamera_Melee` (`FUN_0050c010`, the kill-cam driver, picks between
them) — **argument 2 is almost certainly a `SlowMotionCamera` blueprint name** and argument 1 the object to
focus on. That is *inferred* from the callee, not proven: the binding has zero corpus callers to check it
against, and `Act_1_Escape.lua:619/631`'s `StartSlowMotion`/`StopSlowMotion` are unrelated pure-Lua methods
that do not touch it. Bullet-time in retail is engine-driven from `FUN_0050c010`, not scripted.

Note the shared gate. Both camera bindings consult `DAT_01321b74`/`DAT_01321b78` — the render context that
[`../symbol_map/cinematics.md`](../symbol_map/cinematics.md) records `WSCinematic::Stop` also writing
(`+0x1200`/`+0x1204`/`+0x22c`). They handle its absence differently: `CameraShakeExplosion` **skips the call
entirely**, `StartSlowMotionCamera` **calls with `this = NULL`** via the `setle`/`sub`/`and` idiom. Two
authors, two conventions, one global.

`FocusPt.{Set,Get}ForceCameraFocus` are a matched pair over a single bit — bit 1 of
`*(byte*)(DAT_01494360 + 0x10c60)` — set by `0x00728f50` with the standard XOR-mask idiom
(`b ^= ((arg<<1) ^ b) & 2`) and read back by `0x00728fc0` as `(b >> 1) & 1`. `DAT_01494360` is the same
singleton `FocusPt.UnloadMissionPictures` (`0x00729ae0`) dereferences, so it is the focus-point manager.
The getter takes **no arguments at all** — one of very few zero-arity bindings in the 898. Neither has a
single caller in the corpus: this is a designer-facing toggle that shipped with no script using it.

### The two outliers

`Actor.AddFaceExpression` (`0x0070f0f0`) is the family's only polymorphic-argument binding:

```c
if (!FUN_006f71a0(1)) {                       // not a handle?
  if (!FUN_006f7160(1)) return;               //   must then be a string
  puVar4 = FUN_00db7e10(FUN_006f7a80(1), 1);  //   intern the name
  uVar3 = *puVar4;
} else uVar3 = FUN_006f6ec0(1);               // handle
iVar2 = FUN_0067c0a0(uVar3);                  // the DAT_01321e38 map (ABI doc §7)
... (**(vtable + 0x174))() ...                // -> the facial sub-object
if (FUN_006f7160(2)) {
  FUN_00db7e10(FUN_006f7a80(2), 1);
  iVar2 = thunk_FUN_0160beb0(&fStack_8);      // expression name -> record
  if (iVar2 && (iVar2 = *(int*)(iVar2 + 0x14))) {
    fStack_8 = FUN_006f7140(3) ? FUN_006f7950(3) : DAT_00f7ac80;   // -1.0f default
    FUN_004f1ce0(iVar2, fStack_8);
  }
}
```

**Argument 1 accepts a handle *or* a name string interchangeably** — the same duality
`IsPlayerCloseToCinematic` has, and both resolve through `FUN_0067c0a0`, confirming the ABI doc's §7 note
that an interned symbol is a valid key for that map. Argument 3's default is `DAT_00f7ac80` = `-1.0f`, read
from `.rdata`; a negative default for a third float on an "Add…" call reads as a weight/blend sentinel
meaning "use the authored value", but that is *inferred* from the constant's sign alone. The whole binding
has no corpus caller, which suggests facial expressions are driven by the animation/FSM layer rather than
by script — consistent with the engine-side picture in [`../symbol_map/animation.md`](../symbol_map/animation.md), where
per-character animation selection is FSM-driven rather than script-driven.

`Vehicle.SetTakeDamageInCinematic` (`0x00760720`) is the cleanest body in the family and the tightest
confirmed fact:

```c
if (FUN_006f71a0(1) && FUN_006f7120(2)) {          // handle, boolean -- both mandatory
  iVar3 = FUN_0067c0a0(FUN_006f6ec0(1));
  if (iVar3 && (iVar3 = (**(vtable + 0x194))())) {
    *(undefined1 *)(iVar3 + 0x16f8) = FUN_006f6e60(2);
  }
}
```

One byte, at `vehicle + 0x16f8`, and its single corpus caller is
`Paris_6_Mission_1.lua:1442`: `Vehicle.SetTakeDamageInCinematic(hVehicle, true)`. Note the `&&`-chain — a
`nil` second argument makes the whole call a no-op, silently.

## Corrections to the existing symbol map

The registration map settles two questions [`../symbol_map/cinematics.md`](../symbol_map/cinematics.md)
records as open, and one of its guesses is wrong:

| `cinematics.md` says | tsv says | Verdict |
|---|---|---|
| line 102: *"`FUN_0071c430` … **almost certainly the `Cin.StopCinematic` binding***" | `0x0071c430` = **`Cin.PauseCinematic`** | **Wrong.** `StopCinematic` is `0x0071c490` (the doc's own "further Cin.* binding left unmapped" on the same line). `FUN_0071c430`→`FUN_0094cab0`→`FUN_00944b60` is the pause path; `FUN_0071c490`→`FUN_0094cb10`→`FUN_00945110` (`WSCinematic::Stop`) is the stop path |
| line 61: *"`FUN_0071c3b0` — `lua_Cin_LoadCinematic/PrePlay`"* | `0x0071c3b0` = **`Cin.PrePlayCinematic`**; `Cin.LoadCinematic` is `0x0071dd80` | **Resolved.** The slash disambiguates: mode 1 is PrePlay, and Load is a separate binding that bypasses `FUN_0094f710` |
| line 103: *"the exact Load-vs-PrePlay-vs-node distinction among `FUN_0071c3b0` / `FUN_0071dd80` / `FUN_0071de80` remains unresolved"* | `0x0071c3b0` = `Cin.PrePlayCinematic`, `0x0071dd80` = `Cin.LoadCinematic`, `0x0071de80` = **`Cin.ActivateObjectSpline`** | **Resolved.** `FUN_0071de80` was never in the load family at all — it is the spline binding, which is why it did not fit |

And for [`../symbol_map/camera.md`](../symbol_map/camera.md):

- Its open item (line 45) *"Lua binding thunks (`CameraShakeExplosion`, `StartSlowMotionCamera`, `FocusPt*`,
  `GetPointInViewOnRoad`) are `LuaGlueFunctor` wrappers and are not inline strings — only their downstream
  implementations are pinned, not the binding entry VAs"* is **closed for four of its five names** by the
  table above: `0x0073e7b0`, `0x00753440`, `0x00728f50`, `0x00728fc0`. The fifth,
  `Util.GetPointInViewOnRoad`, is outside this family's regex and is **not** pinned here; for the record the
  tsv gives `0x0074e110` (`LuaGlueFunctor0R`/`jmp`), body not read.
- Its line 29 treats `FUN_00677c69` as a separate "per-frame shake integrator" from `FUN_00677c60`. They
  are **one function**; `0x00677c60` is its prologue and `0x00677c69` its continuation across a
  `jmp 0x520496`. Ghidra's function split is an artifact.
- Its line 38 claim that *"the focus-point and slow-mo bindings are declared but rarely scripted"* is
  understated: they are scripted **zero** times in the 321-file corpus.

## Boundary: the rest of the `Cin` table

Twenty-four of the 32 `Cin.*` rows do **not** match this family's regex. Listed here so the omission is
explicit and auditable rather than silent — VAs from
[`../../data/lua_registration_map.tsv`](../../data/lua_registration_map.tsv), bodies **not read**, no
signatures claimed. They are conversation / Bink / localisation / spline bindings and belong to a sibling
family.

| Lua name | `impl_va` | `family`/`shape` | Cluster |
|---|---|---|---|
| `Cin.PlayConversation` | `0x0071dfe0` | `LuaGlueFunctor0`/`adapter` | conversation |
| `Cin.PlayConversationWith` | `0x0071e100` | `LuaGlueFunctor0`/`adapter` | conversation |
| `Cin.StopConversation` | `0x0071c680` | `LuaGlueFunctor0`/`adapter` | conversation |
| `Cin.InterruptConversation` | `0x0071c710` | `LuaGlueFunctor0`/`adapter` | conversation |
| `Cin.IsHumanInConversation` | `0x0071cb20` | `LuaGlueFunctor0R`/`jmp` | conversation |
| `Cin.GetHumanConversationID` | `0x0071cc00` | `LuaGlueFunctor0R`/`jmp` | conversation |
| `Cin.ConversationConditionPassed` | `0x0071c790` | `LuaGlueFunctor0`/`adapter` | conversation |
| `Cin.SetSpeakerWeight` | `0x0071ea30` | `LuaGlueFunctor0`/`inlined` | conversation — **stub** (see above) |
| `Cin.SubtitlesOn` | `0x0071e950` | `LuaGlueFunctor0`/`inlined` | conversation — **stub** (see above) |
| `Cin.PlayBinkMovie` | `0x0071cca0` | `LuaGlueFunctor0`/`adapter` | Bink |
| `Cin.BinkDemoPlay` | `0x0071ebb0` | `LuaGlueFunctor0`/`inlined` | Bink |
| `Cin.BinkDemoCallback` | `0x0071e2b0` | `LuaGlueFunctor0`/`adapter` | Bink |
| `Cin.StopBinkMovie` | `0x0071ebf0` | `LuaGlueFunctor0`/`inlined` | Bink |
| `Cin.GetLocalizedText` | `0x0071c910` | `LuaGlueFunctor0R`/`jmp` | localisation |
| `Cin.LoadGameTextFile` | `0x0071c810` | `LuaGlueFunctor0`/`adapter` | localisation |
| `Cin.ReleaseGameTextFile` | `0x0071c890` | `LuaGlueFunctor0`/`adapter` | localisation |
| `Cin.ActivateObjectSpline` | `0x0071de80` | `LuaGlueFunctor0`/`adapter` | spline |
| `Cin.DeactivateObjectSpline` | `0x0071c520` | `LuaGlueFunctor0`/`adapter` | spline |
| `Cin.GetSplineObject` | `0x0071c5b0` | `LuaGlueFunctor0R`/`jmp` | spline |
| `Cin.PlayComplexAnim` | `0x0071e3b0` | `LuaGlueFunctor0`/`adapter` | animation |
| `Cin.AllowHumanDamage` | `0x0071ce60` | `LuaGlueFunctor0`/`adapter` | gameplay gate (sibling of `AllowAttackingDuringCinematics`) |
| `Cin.SetEnterMusicOverride` | `0x0071ced0` | `LuaGlueFunctor0`/`adapter` | music |
| `Cin.SetExitMusicOverride` | `0x0071cfd0` | `LuaGlueFunctor0`/`adapter` | music |
| `Cin.DEBUGTeleportToLocator` | `0x0071eaf0` | `LuaGlueFunctor0`/`inlined` | debug — **stub** (see above) |

Two of these are near-misses worth naming. **`Cin.AllowHumanDamage` (`0x0071ce60`)** sits immediately after
`Cin.AllowAttackingDuringCinematics` (`0x0071cdf0`) in the binary and is near-certainly the adjacent bit in
the same `DAT_0143e6f4 + 0x1255` byte — it fails the regex only because its name omits "Cinematic". If you
are chasing the cinematic gameplay gates, read it with this family, not against it. **`Cin.PlayComplexAnim`
(`0x0071e3b0`)** is the other binding that plausibly belongs to cinematics-proper rather than conversation;
its name gives no purchase either way, and I did not read it.

## Open questions

1. **What do `Render.CameraShakeExplosion`'s arguments 4, 5 and 6 mean?** The binding passes them straight
   through to `FUN_00677c60(&vec3, f4, f5, f6, 0.6f, 0, 0)` and I did not trace `FUN_00677c60`'s body to its
   parameter uses. `camera.md`'s `FUN_00678e20` attenuation model suggests radius for arg 4, and
   `Paris_2_Mission_5.lua:1948/2029` scaling only arg 4 with mission state corroborates *magnitude-like*,
   but 5 and 6 are unconstrained. Resolvable by reading `FUN_00677c60` proper (`0x00677c60`–`0x00677c69`+).
2. **What is the hardcoded `0.6f` (`_DAT_00f82634`) in the shake call?** It sits between the script floats
   and two zeros in a 7-argument call, so `FUN_00677c60` has at least one parameter no script can reach.
3. **What does `Cin.PrePlayCinematic` (mode 1) actually do that `LoadCinematic` does not?** Both reach
   `FUN_00950ef0`, but mode 1 goes through `FUN_0094f710`'s non-play branch (which I did not read past
   line 61 of the extract) and passes `1` as `FUN_00950ef0`'s last argument, whereas `LoadCinematic` passes
   `0`. Zero corpus call sites, so the script layer cannot arbitrate. Requires reading `FUN_00950ef0`.
4. **Is `Cin.StopCinematic`'s second argument's polarity a bug?** Mechanically the engine gets `!arg2`, so
   the only site that passes it (`Act_1_Farm.lua:95`, `true`, on a cinematic named `…LoopLoop_01`) takes
   the *hard*-stop path — the opposite of what "stop a loop gently" would want. Either the author had it
   backwards or `bHard` is the wrong name. Needs `FUN_0094cb10`'s callers outside Lua
   (`0x009ce530` in `FUN_009ccf30`, `0x0071c5a6` in `Cin.DeactivateObjectSpline`) for a second opinion.
5. **Is `Cin.SetCinematicStreaming` a stripped debug feature or an abandoned one?** The pre-release 2008 build would answer this directly — if the prototype's
   `0x0071e7f0`-equivalent has a body, retail stubbed a working feature; if it is empty there too, it never
   existed. Same question for `Cin.SubtitlesOn`, which is the more alarming stub.
6. **How many of the 86 `LuaGlueFunctor0`/`inlined` bindings are stubs?** This family's sweep found 5 stubs
   among 8 sampled. A full pass over the tsv's `inlined` rows is ~86 six-byte reads and would produce a
   definitive "these bindings do nothing" list — arguably the highest value-per-effort item in the whole
   seam project. Note `Cin.SubtitlesOn` and `FocusPt.SetTexture` are outside this family and are flagged,
   not claimed.
7. **Is `DAT_01240328 + 0x950` the player, or the camera?** `IsPlayerCloseToCinematic`'s name says player,
   and it calls `vtable+0x28` on that sub-object to get a position. Given the binding lives in the
   *cinematics* table and ignores altitude, a camera-position reading is not impossible. Unresolved without
   pinning `DAT_01240328`'s class.
8. **What is `AddFaceExpression`'s `-1.0f` default (`DAT_00f7ac80`) for?** A negative weight is a sentinel,
   not a value. `FUN_004f1ce0(record, weight)` is a 17-byte forwarder to `FUN_00406f01` — trivially
   traceable, not traced.
9. **Why does `AddFaceExpression` use `vtable+0x174` while `SetTakeDamageInCinematic` uses `vtable+0x194`
   and `StartSlowMotionCamera`'s `FUN_009a0010` uses `vtable+0x1a8`?** Three different accessors on
   (presumably) the same world-object interface, none named. A vtable layout for that class would name all
   three at once and pay off far beyond this family — the ABI doc's §7 `vtable+0x1c` proposal
   (`GetTargetRef()`) is the fourth unnamed slot on what may be the same interface.
10. **Does the `iVar9 = 2` branch of `Cin.PlayCinematic` (skipping `bLoop`) actually work?** It is
    reachable, and no shipped script takes it. Untested code paths in a shipped binary are where bugs live;
    a Lua console call of `Cin.PlayCinematic(name, "M.Cb", self)` would settle it in one shot.
