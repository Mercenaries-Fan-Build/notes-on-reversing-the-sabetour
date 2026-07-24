# The point primitives: `AttractionPt`, `FocusPt`, `Sabotage`, `Searchlight`

> **Verified:** adversarial re-check against `Saboteur.exe`, the registration map, the decomp and all 321
> corpus files. Re-derived all 53 VAs, every argument-check sequence, every component slot, the `+0x2ec`
> flag bits, both inlined stubs, `OnSet`'s registrar, and all 25 corpus citations + the full 241-call
> census — all held. Three byte-level claims corrected: `IsSet`/`IsArmed` differ at 14 byte positions
> (13 are `call rel32` displacements; only **one** is semantic — the claim now says so), `SetTexture` is
> ~92 KB from the `Sabotage` bodies (not "six hundred bytes"), and `Detonate`'s virtual call is vtable
> slot `+0xe4` reached via `[edx]`, not `[eax+0xe4]`.

## What this establishes

Four tables — **53 bindings** — that share one idea: a **named, world-anchored marker** that something in
the game goes to. Civilians walk to attraction points to lean on a bar; the camera swings to focus points
to show you an objective; charges attach to sabotage points; searchlights track targets. Nobody owned the
primitive itself, because each sibling doc took the rows that touched *its* subsystem and left the marker
underneath undocumented. This doc covers all 53, including the six that docs 15 and 18 already pinned.

Three results are worth the read on their own:

1. **`FocusPt` does not use handles — and that is *why* it has a fixed pool.**
   [15 §264](15-family-mission-objective-task.md) already established the fact for `SetObjective` ("the `h`
   prefix in this corpus is unreliable — trust the type check"). This doc extends it to **all 18 rows**
   (every `FocusPt` ID argument is `is_number`→`->int`, never `is_handle`) and supplies the reason: a
   `FocusPt` ID is a **pool index**, `Create` returns **-1** when the pool is exhausted, and the corpus
   stores IDs in *save* tables. Handles are session-scoped and cannot survive save/load
   ([03](03-handle-and-object-model.md)); a pool index can. The design buys save-safety and pays a fixed
   ceiling for it.
2. **`Sabotage` is a live engine→Lua surface with zero shipped callers.** All 8 bindings are real code —
   none is a stub — and `Sabotage.OnSet` registers a callback *name* through `FUN_0070a180`, the exact
   mechanism [05](05-engine-to-lua-callbacks.md) documents. An engine-internal-only table would not need a
   Lua callback registrar. See [§4](#4-the-sabotage-question).
3. **`shape=inlined` is explained.** It is not a Ghidra failure. It means the C++ body was trivial enough
   that the compiler folded it *into* the `LuaGlueFunctor0` thunk, so `impl_va == thunk_va`. For
   `FocusPt.SetTexture` the "body" is six bytes: `mov eax,1; ret`.

Scope: the 53 rows selected from [`data/lua_registration_map.tsv`](../../data/lua_registration_map.tsv) by
`awk -F'\t' '$1=="AttractionPt"||$1=="FocusPt"||$1=="Sabotage"||$1=="Searchlight"'` — 25 + 18 + 8 + 2 = 53.

**Coverage: 53 of 53 located, 48 confirmed, 5 inferred, 0 not found.** 13 bodies are absent from the Ghidra
export and were read directly out of `Saboteur.exe`; every VA below was re-derived from the retail bytes.

---

## 1. What an attraction point *is*

An attraction point is a marker placed in the world data with a name like
`AIAttractionPt_Civ_F_Sing`, carrying a position, a facing, an animation, and a *need* it satisfies. The
ambient-life system hands them out: an idle civilian with a "be entertained" need queries for a nearby
point advertising it, reserves it, plays the animation the point names, and releases it. It is the engine's
answer to "what do a thousand NPCs do when nobody is looking at them."

The shipped scripts corroborate the shape directly. `Missions/P3FP_Hit.lua:414-418` is the whole loop in
five lines — resolve the marker by world path, ask whether anyone has it, hand it to an actor:

```lua
hMicAttrPt = Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\main\\AIAttractionPt_Civ_F_Sing")
if AttractionPt.IsBeingUsedBySomeone(hMicAttrPt) == false and Suspicion.GetEscalation() == 0 then
  Actor.RequestAttrPt(self.hFran, hMicAttrPt)
end
```

Note the split of responsibility, and it is the reason this family was orphaned: **the point is queried
through `AttractionPt.*`, but it is *assigned* through `Actor.RequestAttrPt`** — an
[10](10-family-actor-human.md)/[11](11-family-ai-squad-combat.md) row. The marker and the consumer live in
different tables. `Suspicion.GetEscalation()` in the same condition is [12](12-family-suspicion-wtf-alarm.md)'s.

Points nest. `GetSuperAttrPt`/`AddSubAttrPt`/`UseLeaf`/`GetParent`/`SetParent` describe a tree: a "super"
point (a bar) owns leaf points (each stool). `IsAvailable` at `0x00717d60` walks that tree in the bytes —
it fetches the component, calls the accessor at `+0x264`, checks a child list's count at `+0x40`, and only
then queries the leaf (`0x00717e1e: cmp dword ptr [eax + 0x40], 0` / `jle`). A super point with no
children is unavailable.

The engine object exposes each subsystem as a component reached by a fixed vtable slot on the same
nested-pointer expression. That is what actually distinguishes these four tables:

| Table | Component slot | Reached from |
|---|---|---|
| `AttractionPt` | `+0x224` | handle → `FUN_0067c0a0` → object |
| `Sabotage` | `+0x234` | same object, different slot |
| `Searchlight` | `+0x23c` (and `+0x244`) | same object, different slot |
| `FocusPt` | *none* — global singleton `DAT_01494360` | not handle-based at all |

**Confirmed** — read from the bytes of every body (e.g. `0x00717ddd: mov edx, dword ptr [eax + 0x224]` in
`IsAvailable`; `0x00740b00`'s Sabotage path takes `+0x234`). The `DAT_01494360` singleton is
[18](18-family-cinematics-camera-face.md)'s identification, independently re-confirmed here: my
disassembly of `FocusPt.UnloadMissionPictures` opens `mov ecx, dword ptr [0x1494360]`.

So `AttractionPt`, `Sabotage` and `Searchlight` are **three views of one world object**, selected by
component slot; `FocusPt` is a different thing entirely that merely shares the "point" noun.

---

## 2. The bindings

`Shape` and `VA` are from the registration map, re-derived against `Saboteur.exe`. `nresults` is `1` for
every `adapter` row by construction ([05 §1](05-engine-to-lua-callbacks.md)); `jmp` rows are
`LuaGlueFunctor0R` and return their own count in `EAX`. Argument indices were read from the retail bytes,
not the decomp. Corpus counts are **direct call sites only**, counted by regex with a word boundary over
all 321 `.lua` files; bare table references are excluded and noted separately in [§5](#5-the-corpus).

### `AttractionPt` (25)

| Binding | VA | Shape | Signature | Confidence | Evidence |
|---|---|---|---|---|---|
| `EnableBroadcast` | `0x00717790` | adapter | `(h, bEnable) -> ()` | **confirmed** | `is_handle(1)`,`is_bool(2)`; comp `+0x224` → `FUN_008e9a40`; 9 calls, Act_1_BarFight.lua:374 |
| `Delete` | `0x00717840` | adapter | `(h) -> ()` | **confirmed** | `is_handle(1)`; `+0x224`, then `FUN_00836370`; 1 call, SabTaskObjective.lua:816 |
| `GetActor` | `0x007178f0` | jmp | `(h) -> hActor \| nil` | **confirmed** | exe-only; `is_handle(1)`, `+0x224`, `pushnil` on the miss path |
| `IsBroadcastEnabled` | `0x007179a0` | jmp | `(h) -> b` | **confirmed** | exe-only; `is_handle(1)`, `+0x224`, pushbool |
| `SetAnimation` | `0x00717a40` | adapter | `(h, nIndex, sAnim) -> ()` | **confirmed** | `is_handle(1)`,`is_number(2)`,`is_string(3)`+`STRCPY`; 2 calls, AttractionPt_SuspKiss.lua:33 |
| `SetParent` | `0x00717b10` | adapter | `(h, hParent) -> ()` | **confirmed** | two handles; comps `+0x224`,`+0x264`; 0 calls |
| `GetParent` | `0x00717c00` | jmp | `(h) -> hParent \| nil` | **confirmed** | exe-only; `is_handle(1)`, `+0x224`, `pushnil` miss path; 0 calls |
| `Restart` | `0x00717cd0` | adapter | `(h) -> ()` | **confirmed** | `is_handle(1)`, `+0x224`; 0 calls |
| `IsAvailable` | `0x00717d60` | jmp | `(h) -> b` | **confirmed** | exe-only; tree walk `+0x224`/`+0x264`, child count `+0x40`, leaf query `[eax+0x78]`; **12 calls**, Act_1_BarFight.lua:576 |
| `IsBeingUsedBySomeone` | `0x00717e80` | jmp | `(h) -> b` | **confirmed** | exe-only; same tree walk; 2 calls, P1FP_NaziParty.lua:1069, P3FP_Hit.lua:416 |
| `GetTargetPos` | `0x00717f70` | jmp | `(h) -> {x,y,z}` | inferred | exe-only; `is_handle(1)`, `+0x224`, builds a table (`FUN_006f69c0`); component field roles not pinned; 0 calls. Explicitly excluded by [11](11-family-ai-squad-combat.md):40 |
| `FindPtInObject` | `0x00718070` | jmp | `(hObject, sPtName) -> hPt \| nil` | **confirmed** | exe-only; `is_handle(1)`,`is_string(2)`+`STRCPY`, comp `+0x264`; **54 calls**, Act_3_Mission_4.lua:186 |
| `EnableAlts` | `0x00718190` | adapter | `(h, bEnable) -> ()` | **confirmed** | `is_handle(1)`,`is_bool(2)`, `+0x224`; 0 calls |
| `EnableUse` | `0x00718240` | adapter | `(h, bEnable) -> ()` | **confirmed** | `is_handle(1)`,`is_bool(2)`; comps `+0x224`,`+0x22c`; **112 calls** — the most-called row in scope; Act_1_BarFight.lua:268 |
| `AddSubAttrPt` | `0x00718300` | adapter | `(hSuper, hSub) -> ()` | **confirmed** | two handles, both `H2OBJ`, `+0x224`; 0 calls |
| `GetSuperAttrPt` | `0x00718470` | jmp | `(h) -> hSuper \| nil` | **confirmed** | exe-only; `is_handle(1)`, `+0x224`; 0 calls |
| `GetAllByNeed` | `0x00718510` | jmp | `(x, y, z, fRadius, nNeed) -> {h,…}` | inferred | exe-only; `is_number(1..3)`→float, `is_number(4)`→float, `is_number(5)`→**int**, then `FUN_006f69c0` (new table) + `FUN_006f6cc0` (set field) in a loop. The need **enum values are not pinned**; 0 calls |
| `SetMiniGameTarget` | `0x00718690` | adapter | `(h, hTarget) -> ()` | **confirmed** | two handles, `+0x224`; 0 calls. Excluded by [11](11-family-ai-squad-combat.md):40 |
| `SpawnHumanInClosetCODECALLBACK` | `0x00718800` | adapter | `(h, sName) -> ()` | inferred | `is_handle(1)`,`is_string(2)`+`STRCPY`, `+0x224`. The `CODECALLBACK` suffix is **in the registered name**, not an annotation; 0 calls |
| `SpawnHumanInCloset` | `0x007191e0` | adapter | `(h, sName [, sCallback [, self [, tUser]]]) -> ()` | **confirmed** | `is_handle(1)`,`is_string(2)`; then `ARGC`-gated `is_string(3)`→`FUN_0070a180` (**callback name**), `is_table(3)`→`FUN_0070a4b0` (self); 0 calls |
| `Create` | `0x007193d0` | adapter | `(sName, x, y, z, fParam [, hParent\|nil [, tOpts\|nil [, sCallback [, self [, tUser]]]]])` | **confirmed** | see [§3](#3-attractionptcreate-and-the-sliding-cursor); 4 calls, MISSION_CFrench.lua:234 |
| `FinishNow` | `0x00719770` | adapter | `(h [, hActor]) -> ()` | **confirmed** | `is_handle(1)`, `+0x224`, optional `is_handle(2)`; 10 calls, Act_1_BarFight.lua:690 |
| `AbortTo` | `0x00719830` | adapter | `(h, hTarget) -> ()` | **confirmed** | two handles, `+0x224`; 0 calls |
| `UseLeaf` | `0x00719900` | jmp | `(hSuper, hLeaf, hActor) -> b` | inferred | exe-only; **three** handles, `+0x224`, pushbool. Arg *roles* read from the sibling tree API, not proven; 0 calls |
| `IsBeingUsedBy` | `0x00719a50` | jmp | `(hPt, hActor) -> b` | **confirmed** | exe-only; two handles, `+0x224`, pushbool; 0 calls |

### `FocusPt` (18) — the pool, not the handle

Every `FocusPt` row that takes an ID takes it as `is_number` → `->int`, never `is_handle`.

| Binding | VA | Shape | Signature | Confidence | Evidence |
|---|---|---|---|---|---|
| `Create` | `0x007286f0` | jmp | `(x,y,z,fRange,nPriority,bStartActive [,bExterior [,hAnchor [,sLabel [,sLabel2]]]]) -> nID` | **confirmed** | `is_number(1..5)`,`is_bool(6)`; optionals at 7/8/9/**10** via an `EDI` cursor (`0x007287ea: mov edi,7`); `pushnum` → **returns a number**; 8 calls, InteriorManager.lua:577 |
| `Delete` | `0x00728970` | adapter | `(nID) -> ()` | **confirmed** | `is_number(1)`→`->int`; 12 calls, InteriorManager.lua:585 |
| `Enable` | `0x007289d0` | adapter | `(nID, bEnable) -> ()` | **confirmed** | `is_number(1)`,`is_bool(2)`; 1 call, SabTaskObjective.lua:1079 |
| `IsEnabled` | `0x00728a60` | jmp | `(nID) -> b` | **confirmed** | `is_number(1)`, pushbool; 0 calls |
| `Exists` | `0x00728ae0` | jmp | `(nID) -> b` | **confirmed** | `is_number(1)`, pushbool; 0 calls |
| `SetPictureInfo` | `0x00728b60` | adapter | `(nID, nPicture [, bFlag]) -> ()` | **confirmed** | `is_number(1)`,`is_number(2)`, `ARGC`-gated `is_nil(3)`/`is_bool(3)`; 0 calls |
| `LoadMissionPictures` | `0x00728c40` | adapter | `(sFile) -> ()` | **confirmed** | `is_string(1)`, **no `STRCPY`** — see [15 Q7](15-family-mission-objective-task.md); 1 call, SabTaskMission.lua:355. Pinned by [15](15-family-mission-objective-task.md):178 |
| `SetObjective` | `0x00728ca0` | adapter | `(nID, nObjectiveID) -> ()` | **confirmed** | both `is_number`; 1 call, SabTaskObjective.lua:1433. Pinned by [15](15-family-mission-objective-task.md):177 |
| `SetPriority` | `0x00728d40` | adapter | `(nID, fPriority) -> ()` | **confirmed** | `->int(1)`, `->float(2)` — **id is int, priority is float**; 0 calls |
| `SetRange` | `0x00728de0` | adapter | `(nID, fRange) -> ()` | **confirmed** | `->int(1)`, `->float(2)`; 0 calls |
| `SetExteriorPts` | `0x00728e70` | adapter | `(bEnable) -> ()` | **confirmed** | `is_bool(1)` **only — no ID; a global toggle**; 2 calls, InteriorManager.lua:753 |
| `SetInteriorPts` | `0x00728ee0` | adapter | `(bEnable) -> ()` | **confirmed** | `is_bool(1)` only; global toggle; 2 calls, InteriorManager.lua:754 |
| `SetForceCameraFocus` | `0x00728f50` | adapter | `(bForce) -> ()` | **confirmed** | `is_bool(1)`; 0 calls. Pinned by [18](18-family-cinematics-camera-face.md):86 (bit `0x02` of `DAT_01494360+0x10c60`) |
| `GetForceCameraFocus` | `0x00728fc0` | jmp | `() -> b` | **confirmed** | **no arguments**; pushbool; 0 calls. Pinned by [18](18-family-cinematics-camera-face.md):87 |
| `SetOnFocusCallback` | `0x00729680` | adapter | `(nID, sCallback [, self [, tUser]]) -> ()` | **confirmed** | `is_number(1)`→`->int`, `is_string(2)`→`FUN_0070a180`, `is_table(3)`→`FUN_0070a4b0`, `is_table(4)`; 1 call, Paris_2_Mission_5.lua:367 |
| `SetOnFailFocusCallback` | `0x00729780` | adapter | `(sCallback, bFlag [, self [, tUser]]) -> ()` | inferred | `is_string(1)`,`is_bool(2)`, then `FUN_0070a180`; **takes no ID** — asymmetric with `SetOnFocusCallback`; 0 calls |
| `SetTexture` | `0x00729940` | inlined | `(…) -> ()` — **retail do-nothing stub** | **confirmed** | bytes are `b8 01 00 00 00 c3` = `mov eax,1; ret`. Reads no arguments. Independently re-derived; [18](18-family-cinematics-camera-face.md):282 found this first |
| `UnloadMissionPictures` | `0x00729ae0` | inlined | `() -> ()` | **confirmed** | `mov ecx,[0x1494360]; call 0x992f60; mov eax,1; ret`. **Real, not a stub**; 1 call, SabTaskMission.lua:412. Upgrades [15](15-family-mission-objective-task.md):179's "inferred — no body (gap)" |

### `Sabotage` (8) — all real, none called

| Binding | VA | Shape | Signature | Confidence | Evidence |
|---|---|---|---|---|---|
| `Detonate` | `0x007407d0` | adapter | `(h) -> ()` | **confirmed** | `is_handle(1)`, comp `+0x234`, then a tail-jmp through **vtable slot `+0xe4`** (`0x0074084c: mov edx,[eax]; mov eax,[edx+0xe4]; jmp eax`); 0 calls |
| `IsSet` | `0x00740860` | jmp | `(h) -> b` | **confirmed** | `+0x2ec`: `test al,4` / `test al,0x10` → true iff **`0x04` set and `0x10` clear**; 0 calls |
| `IsArmed` | `0x00740920` | jmp | `(h) -> b` | **confirmed** | same bytes, `je` instead of `jne` → true iff **`0x04` set and `0x10` set**; 0 calls |
| `Arm` | `0x007409e0` | adapter | `(h) -> ()` | **confirmed** | `+0x234`, then `push 1; call 0x4c0150`; 0 calls |
| `Disarm` | `0x00740a70` | adapter | `(h) -> ()` | **confirmed** | `+0x234`, then `push 0; call 0x4c0150` — **same callee as `Arm`, inverted flag**; 0 calls |
| `Set` | `0x00740b00` | adapter | `(h [, bFlag]) -> ()` | **confirmed** | `is_handle(1)`, `ARGC`-gated `is_bool(2)` defaulting to `0`; `+0x234` → `FUN_004c1db0`; 0 calls |
| `UnSet` | `0x00740bd0` | adapter | `(h) -> ()` | **confirmed** | `+0x234` → `FUN_004c0a20`; 0 calls |
| `OnSet` | `0x00740f70` | adapter | `(h, sCallback [, self]) -> ()` | **confirmed** | `is_handle(1)`,`is_string(2)` (non-empty checked), `FUN_00626e00` event node, **`FUN_0070a180(name)`**, `is_table(3)`→`FUN_0070a4b0`; 0 calls |

### `Searchlight` (2)

| Binding | VA | Shape | Signature | Confidence | Evidence |
|---|---|---|---|---|---|
| `SetTarget` | `0x00742130` | adapter | `(h, sLightName, hTarget \| nil) -> ()` | **confirmed** | `is_handle(1)`, comp `+0x23c`, `is_string(2)`+`STRCPY`, `is_handle(3)` **or** `is_nil(3)` — nil clears; 4 calls, Checkpoint.lua:190. Excluded by [11](11-family-ai-squad-combat.md):38 |
| `EnableLights` | `0x00742290` | adapter | `(h, sLightName, bEnable) -> ()` | **confirmed** | `is_handle(1)`, comps `+0x23c`,`+0x244`, `is_string(2)`+`STRCPY`, `is_bool(3)`; 2 calls, DestructionSequence.lua:62 |

Both take a **string sub-light name** after the handle: one world object owns several named lamps.

---

## 3. `AttractionPt.Create` and the sliding cursor

`Create` (`0x007193d0`, 921 bytes) is the largest body in scope and the only one whose argument positions
are not fixed. After five mandatory arguments (`is_string(1)`, `is_number(2..5)`) it parses the tail with a
**cursor** that advances only when the optional argument it points at is present:

```c
iVar8 = 6;
if (argc >= 6) {
  if (is_nil(6))    { iVar8 = 7; goto TAIL; }
  if (is_handle(6)) { ToHandle(6); FUN_00498440(); iVar8 = 7; }   // parent object
}
TAIL:
if (iVar8 <= argc) {
  if (is_table(iVar8))    { thunk_FUN_00481ae6(uVar3, iVar8); iVar8++; }   // user table
  else if (is_nil(iVar8)) { iVar8++; }
  else goto NAME;                        // <-- cursor does NOT advance
}
NAME:
if (iVar8 <= argc && is_string(iVar8)) {
  FUN_0070a180(...);                     // callback NAME  (doc 05)
  if (is_table(iVar8+1)) FUN_0070a4b0(...);   // self
  if (is_table(iVar8+2)) thunk_FUN_00481ae6(...);  // user table
}
```

Both shipped shapes fall out. `Experimental/MISSION_CFrench.lua:234` passes six —
`AttractionPt.Create("AttractionPt_Boiler", 0, 0, 0, 180, hdoodle)` — and stops. `Modules/Behavior/Human/Starter/FreeplayStarter.lua:4`
passes ten:

```lua
AttractionPt.Create("MissionStarterAttrPt", 0, 0, 0, 180, self.hController, nil,
                    "FreeplayStarter.OnAttractionPtLoaded", self, {})
```

Trace it: arg 6 is a handle → cursor 7; arg 7 is `nil` → cursor 8; arg 8 is the string → callback name;
arg 9 the `self` table; arg 10 the user table. That is the `(name, self, tUserTable)` triple
[05 §3.1](05-engine-to-lua-callbacks.md) documents, reached through a cursor rather than a fixed index —
and the dotted `"FreeplayStarter.OnAttractionPtLoaded"` is exactly the `'.'`-split name
[05 §3.2](05-engine-to-lua-callbacks.md) describes.

Two notes on honesty. All four shipped `Create` sites pass literally `0, 0, 0, 180`, so the corpus
**cannot** discriminate the roles of arguments 2–5; `(x, y, z, fParam)` is the natural reading given a
parent handle is also supplied (a local offset plus a heading), but the fourth float's meaning is
**inferred**, not confirmed. Second, script-created points are named by the engine, not the caller: the
body does `_sprintf(acStack_8c, "AttrPtLuaCreated%d", DAT_0142d9b0++)`. The `sName` in argument 1 is a
*type* to instantiate (`"AttractionPt_Boiler"`, `"MissionStarterAttrPt"`, `"Generic_Use"`), not the
instance's identity — which is why `Modules/Behavior/AttractionPts/` contains a `.lua` module per point
*type*.

---

## 4. The `Sabotage` question

`Sabotage.*` is called from **none** of the 321 shipped scripts. The shipped path to the same objects goes
through the attraction-point API by name string — `Missions/Act_3_Mission_4.lua:186`:

```lua
local hSabPoint = AttractionPt.FindPtInObject(self.hMainTrainEngine, "SabotagePt_Dynamite01")
```

A sabotage point is an attraction point named `SabotagePt_*` hanging inside a parent object, found through
`FindPtInObject` (`0x00718070`, 54 call sites — the second most-called row in scope). Nothing in the
shipped mission ever calls `Sabotage.Set` on the result; it hands it to a task module instead
(`sTaskType = "SabTaskObjectiveDestroy"`, `sTaskSubType = "Sabotage"` — Act_3_Mission_4.lua:189-190).

**A counting trap, flagged for the next reader.** A naive `grep "Sabotage\.[A-Za-z]*("` over the corpus
returns one hit, `Sabotage.SetupGamepadListener`. It is a **substring artifact**: the real line is
`Missions/P3FP_RadioSabotage.lua:34: function P3FP_RadioSabotage.SetupGamepadListener()`. With a word
boundary, `(?<![A-Za-z0-9_])Sabotage\.` matches **zero** times in all 321 files. The headline survives, but
only if you count it correctly.

So: superseded API, or engine-internal-only? **The bytes settle it, and the answer is neither.**

`SabotagePtOnSet` @ `0x00740f70` is a callback registrar of exactly the shape
[05 §3.1](05-engine-to-lua-callbacks.md) derived from `Vehicle.SetDeathCallback`:

```c
if (is_handle(1) && is_string(2)) {
  obj = FUN_0067c0a0(ToHandle(1));
  comp = (**(obj + 0x234))();                 // the sabotage component
  name = ToString(2);
  if (name && *name != '\0') {                // empty string rejected
    node = FUN_00626e00(0);                   // event node — same allocator as SetDeathCallback
    *node = FUN_006f8250();
    FUN_0070a180(name);                       // <-- installs the callback NAME
    if (is_table(3)) FUN_0070a4b0(3);         // <-- self table
  }
}
```

Per [05](05-engine-to-lua-callbacks.md), `FUN_0070a180` is the by-name callback install and `FUN_0070a4b0`
stores the `self` table. **The table is a live C→Lua surface**: the engine is prepared to call *into* Lua
when a charge is set on a point. Option (b) — engine-internal-only — is refuted by these bytes. A table
that exists only for the engine's own use has no reason to carry a Lua callback registrar at all, let
alone one wired to the same event-node allocator (`FUN_00626e00`) as the shipped `Vehicle` callbacks.

Nor is it dead code kept alive by accident. **None of the 8 is a stub.** Every one reads its arguments,
resolves the `+0x234` component and calls into the demolition subsystem. `Arm` and `Disarm` are the same
call with an inverted flag — `push 1; call 0x4c0150` at `0x00740a60` versus `push 0; call 0x4c0150` at
`0x00740af0`. Compare `FocusPt.SetTexture` (`0x00729940`, ~92 KB earlier in `.text`), which *is* a stub:
the contrast is visible in the bytes, and `Sabotage` is on the live side of it.

The state machine is the strongest evidence that this is a designed, coherent API rather than a leftover.
`IsSet` and `IsArmed` read the **same flag byte** at component `+0x2ec` and differ by exactly **one
semantic byte**. (Precisely: over their `0xb4`-byte bodies the two differ at 14 byte positions, but 13 of
those are `call rel32` displacements encoding the *same* call targets from a different origin. Exactly one
*instruction* differs, and it is the second branch:)

```asm
; IsSet  @0x007408e1                    ; IsArmed @0x007409a1
mov al, byte ptr [eax + 0x2ec]          mov al, byte ptr [eax + 0x2ec]
test al, 4                              test al, 4
je   <false>                            je   <false>
test al, 0x10                           test al, 0x10
jne  <false>          ; <-- 0x75        je   <false>          ; <-- 0x74
mov  al, 1                              mov  al, 1
```

Read off: bit `0x04` is *a charge is attached*, bit `0x10` is *armed*. `IsSet` = attached **and not** armed;
`IsArmed` = attached **and** armed. The two are mutually exclusive by construction, which is why the API
needs both and why `Set`/`UnSet` are distinct from `Arm`/`Disarm`: `Set` attaches the charge, `Arm` starts
the timer, `Detonate` fires it. That is a four-verb lifecycle nobody would build by accident.

**The honest verdict.** The table is a complete, live, engine-backed C↔Lua surface that the shipped
scripts do not use — closest to the brief's option (a), a surface kept alive for a script path that did not
ship, but the evidence proves *liveness*, not *supersession*. `FindPtInObject` is not a replacement for
`Sabotage.Set`; they do different things (find a marker vs. attach a charge). What the corpus shows is that
the shipped game routes charge-placement through the **task/objective modules** rather than through direct
`Sabotage.*` calls — the player plants dynamite through `SabTaskObjectiveDestroy`, and the C++ side of that
task presumably drives the same `+0x234` component from C, never crossing the seam. `Sabotage.OnSet` exists
so a script *could* be notified; no shipped script asks. Whether `LuaMissions.luap` asks is **open** and is
exactly what the [2008 pre-release build](../community_tooling.md) would settle.

**Confidence: confirmed** that all 8 bodies are real and non-stub, that `OnSet` installs a callback name
and a self table, and for the `+0x2ec` bit semantics. **Inferred** for the `Set`→`Arm`→`Detonate` ordering
(argued from the flag gates, not observed at runtime). **Open**: why it never shipped a caller.

---

## 5. The corpus

Counted by walking all 321 `.lua` files and matching `(?<![A-Za-z0-9_])<Table>\.(\w+)\s*\(` — direct calls
only. **241 direct call sites across 20 of the 53 bindings; 33 bindings have none.** Two bare
(non-call) references exist and are *not* in the totals: `AttractionPt.EnableBroadcast` ×1 and
`FocusPt.Create` ×1.

| Table | Bindings | With ≥1 call site | Direct calls |
|---|---|---|---|
| `AttractionPt` | 25 | 9 | 206 |
| `FocusPt` | 18 | 9 | 29 |
| `Sabotage` | 8 | **0** | **0** |
| `Searchlight` | 2 | 2 | 6 |
| **Total** | **53** | **20** | **241** |

The distribution is lopsided: `EnableUse` alone is 112 of the 241, and `FindPtInObject` another 54. Two
bindings are 69% of all traffic. What scripts actually do with attraction points is **turn them on and off**
(`AttractionPt.EnableUse(hDoor, not bLocked)` — Act_1_BarFight.lua:268) and **look them up inside an
object**. The rich part of the API — the super/leaf tree, `AbortTo`, `UseLeaf`, `GetAllByNeed` — is driven
entirely from C++; script only opens and closes the gates.

`FocusPt`'s pool is corpus-visible. `Modules/SabTaskObjective.lua:1054` prints
`"SabTaskObjective:SetFocusObjective - FocusPt.Create returned -1 perhaps we are out of focuspts"` — so
`Create` returns **-1 on exhaustion** and the pool is fixed-size. That is the direct consequence of the
integer-ID design: a `Create` that returned a handle could allocate freely.

Beware the naming: the scripts call these IDs *handles*. `SabTaskObjective.lua:1079` reads
`FocusPt.Enable(tFocusTable.FocusHandle, bOn)` and `:1433` `FocusPt.SetObjective(tFocusTable.FocusHandle, messagehandle)`
— a field named `FocusHandle` holding a number that the engine type-checks with `FUN_006f7140` (isnumber).
[15 §264](15-family-mission-objective-task.md) caught this first and proved it independently of the decomp:
`SabTaskObjective.lua:1432` tests `tFocusTable.FocusHandle ~= -1`, and `-1` is a sentinel no lightuserdata
could ever equal. Trust the type check, not the Hungarian notation — across all 18 rows, not just the one.

And that design earns itself back at save time. `Missions/Paris_2_Mission_5.lua:366` stores the ID in
`self.tSaveInfo.FID` — a *save* table. Per [03](03-handle-and-object-model.md) handles are session-scoped
light userdata carrying a generation counter and cannot survive save/load; a pool index can, provided the
pool is rebuilt deterministically. `FocusPt` is the one table in this family whose IDs are allowed to
outlive the session, and it pays a fixed pool for the privilege.

The interior/exterior toggle is the clearest single use. `Managers/InteriorManager.lua:750-756`:

```lua
function InteriorManager.ToggleFocus()
  local tSabSelf = Actor.GetSelf(hSab)
  if tSabSelf.bInInterior then
    FocusPt.SetExteriorPts(false)
    FocusPt.SetInteriorPts(true)
  else
    FocusPt.SetExteriorPts(true)
```

Neither takes an ID — they are **global** class toggles on the `DAT_01494360` singleton. When Sean walks
indoors the engine mutes every exterior focus point at once rather than iterating them. That is why the
signature has no ID and why it looked anomalous next to `Enable(nID, b)`.

---

## 6. Where this doc disagrees with its brief

Stated plainly, with the evidence, per [AGENTS.md](../../AGENTS.md).

The task framing for this doc held that "doc 11 took 5 `AttractionPt` rows because *needs* are AI" and
"docs 15/18 took 7 `FocusPt` rows". **Neither is right, and the README already said so.**

- **Doc 11 pinned zero of these rows.** It does not claim them — it *explicitly excludes* them.
  [11](11-family-ai-squad-combat.md):38-40 lists `Searchlight.SetTarget`, `AttrPt.SetMiniGameTarget` and
  `AttractionPt.GetTargetPos` under "Deliberately **excluded**, despite matching `*Target*` on the name".
  Three mentions, zero table rows.
- **Docs 15 and 18 pinned six distinct `FocusPt` rows, not seven**: `SetObjective` and
  `LoadMissionPictures` ([15](15-family-mission-objective-task.md):177-178), `UnloadMissionPictures`
  (both), `SetForceCameraFocus`, `GetForceCameraFocus` and `SetTexture`
  ([18](18-family-cinematics-camera-face.md):86-87, 282).

The [README](README.md) coverage table is correct as written — `AttractionPt` 0 pinned, `FocusPt` 6 pinned,
`Sabotage` 0, `Searchlight` 0 — and this doc's count of 53 previously-uncovered-or-partly-covered rows
should be read against that, not against the brief.

One genuine correction to a sibling, offered rather than asserted over their heads:
[15](15-family-mission-objective-task.md):179 marks `FocusPt.UnloadMissionPictures` **inferred — "no body
(gap)"**. There is a body; it is four instructions at `0x00729ae0`
(`mov ecx,[0x1494360]; call 0x992f60; mov eax,1; ret`), absent from the Ghidra export because the compiler
inlined it into its own thunk. [18](18-family-cinematics-camera-face.md):285 already read it from the exe
and got the same bytes. Doc 15's row can be upgraded to **confirmed**, `() -> ()`.

I claim no novelty for the `FocusPt.SetTexture` stub: I re-derived `b8 01 00 00 00 c3` independently from
`Saboteur.exe` before reading doc 18, but [18](18-family-cinematics-camera-face.md):282 found it first and
says so plainly. Two independent reads agreeing on six bytes is worth recording as corroboration, not as a
discovery.

---

## 7. A byte-level note that closes an open question elsewhere

[02 Q1](02-marshalling-abi.md#open-questions) records as **inferred, not proven** that `FUN_006f8470`'s
`EAX` result becomes the `ECX` `this` for every following primitive — "derived from Ghidra's `__thiscall`
recovery plus the singleton prologue, not from raw disassembly. A single look at `0x00714230`'s bytes in a
disassembler would settle it."

Disassembling any body in this family settles it. `AttractionPt.IsAvailable` @ `0x00717d60`:

```asm
0x00717d93  8b 44 24 14   mov  eax, dword ptr [esp + 0x14]   ; the lua_State* argument
0x00717d97  50            push eax
0x00717d98  e8 d3 06 fe ff call 0x6f8470                     ; FUN_006f8470(L)
0x00717d9d  8b d8         mov  ebx, eax                      ; <-- EAX result saved
0x00717d9f  6a 01         push 1                             ; stack index 1
0x00717da1  8b cb         mov  ecx, ebx                      ; <-- threaded into ECX as `this`
0x00717da3  e8 f8 f3 fd ff call 0x6f71a0                     ; state->IsHandle(1)
```

`mov ebx, eax` / `mov ecx, ebx` is the dataflow doc 02 could only infer. The same pattern holds in
`0x00717e80` (via `EDI`: `mov edi, eax` / `mov ecx, edi`) and in every body I disassembled here.
**Doc 02's open question 1 can be closed: confirmed.** Doc 02 is not edited by this doc; the finding is
recorded here for whoever revises it.

---

## Open questions

1. **What are the `need` enum values?** `AttractionPt.GetAllByNeed` (`0x00718510`) takes its fifth
   argument as an **integer** (`FUN_006f7990`, not `FUN_006f7950`) and filters points by it. No shipped
   script calls it, so the corpus offers no attested constant, and the enum lives in the C++ side of the
   ambient-life system. Pinning it would name every point type in the world data. Highest-value item here.
2. **Does `LuaMissions.luap` call `Sabotage.*`?** The single question that would convert [§4](#4-the-sabotage-question)'s
   "live but uncalled" into a definite history. The [2008 pre-release build](../community_tooling.md)
   settles it directly, and would also test whether `Sabotage.OnSet` ever had a registered name.
3. **Why is `SetOnFailFocusCallback` asymmetric with `SetOnFocusCallback`?** `SetOnFocusCallback`
   (`0x00729680`) takes `(nID, sCallback, …)`; `SetOnFailFocusCallback` (`0x00729780`) takes
   `(sCallback, bFlag, …)` with **no ID** — so failure is global while success is per-point. Read as
   designed, that means "the player failed to focus *anything*", but nothing in the corpus exercises it.
4. **What is `AttractionPt.Create`'s fourth float?** All four shipped call sites pass `180`, and all four
   pass `0, 0, 0` for the first three. A heading in degrees is the natural reading against a parent handle,
   but the corpus cannot discriminate it and the component field it lands in was not chased.
5. **`SpawnHumanInClosetCODECALLBACK`.** The suffix is part of the *registered string*, not a comment. It
   sits beside `SpawnHumanInCloset` (which has the full callback-name machinery) and takes only
   `(h, sName)`. It looks like a C-side entry point that was exposed to Lua by accident of the registration
   macro. Neither is called by any shipped script.
6. **`EnableUse` touches a second component (`+0x22c`) that no sibling row touches.** With 112 call sites
   it is the most-exercised binding in scope and the only `AttractionPt` row reaching `+0x22c`. What that
   component is was not chased.
7. **Is `FocusPt`'s pool rebuilt deterministically across save/load?** The integer-ID design only works if
   it is, and `tSaveInfo.FID` (Paris_2_Mission_5.lua:366) bets the mission on it. The pool size and its
   rebuild path were not located.

## Confidence

**High**, with the catalog-wide caveat. All 53 rows are located and every VA was re-derived from
`Saboteur.exe` rather than trusted from the decomp — including the 13 bodies (11 `AttractionPt`, 2
`FocusPt`) that are absent from the Ghidra export entirely. **48 rows are confirmed** (registration-map
identity + body read at byte level + primitives unambiguous) and **5 are inferred** — `GetTargetPos`,
`GetAllByNeed`, `UseLeaf`, `SpawnHumanInClosetCODECALLBACK`, `SetOnFailFocusCallback`. None not found.

Three claims outside the table are **inferred** and should not be read as carried by their rows' confirmed
tier: the *roles* (not the types, which are byte-level) of `AttractionPt.Create`'s arguments 2–5; the
`Set`→`Arm`→`Detonate` lifecycle ordering in [§4](#4-the-sabotage-question), argued from the flag gates
rather than observed at runtime; and the reading of bit `0x04`/`0x10` at `+0x2ec` as *attached*/*armed* —
the bit **tests** are confirmed bytes, the English names for them are inference from the binding names that
read them.

Per the [README](README.md)'s tiering rule, "confirmed" here does **not** mean assertion-anchored: no
binding in this family carries an EALA assertion string, so all 53 identities come from
[`data/lua_registration_map.tsv`](../../data/lua_registration_map.tsv) and inherit its single-point-of-failure
risk. Signatures, component slots, flag bits and the stub finding are independent of the map — they were
read from the retail bytes and do not fall if the map's stanza parser is wrong; only the *names* would.

Corpus counts were produced by grepping, not estimated: 241 direct calls over 321 files, direct calls kept
separate from the 2 bare table references, and the one `Sabotage` "hit" run down and shown to be a
substring artifact.

## Reproducing

The 13 missing bodies need only `Saboteur.exe` (image base `0x400000`), pefile and capstone — the method
[19](19-family-ui-hud-tutorial.md) established:

1. Take `impl_va` from the registration map.
2. Map VA → section → raw offset; read ~400 bytes.
3. Disassemble 32-bit; the `LuaGlueFunctor0` prologue (`mov ecx,[0x142d324]` … `call 0x6f8470`) confirms
   it is a binding.
4. Every `call` to a `0x6f7xxx`/`0x6f6xxx` target is a primitive from [02 §5](02-marshalling-abi.md); the
   immediately preceding `push <imm>` is its **Lua stack index**. Where the index is in a register
   (`EDI` in `FocusPt.Create`, the `iVar8` cursor in `AttractionPt.Create`), it is a variadic tail — read
   the register, not the last `push`.
5. `int3` (`0xcc`) padding marks the end of the body.

Two traps worth inheriting. `impl_va == thunk_va` in the map means `shape=inlined` — the body was folded
into the thunk and Ghidra emitted no function; go to the exe. And a scanner that stops at the first `ret`
will truncate every `jmp`-shaped (`LuaGlueFunctor0R`) row at its bad-argument early-out and report no
component slot: bound the read by the next row's VA instead.

## See also

- [03-handle-and-object-model.md](03-handle-and-object-model.md) — why `FocusPt`'s integer IDs are not handles
- [05-engine-to-lua-callbacks.md](05-engine-to-lua-callbacks.md) — `FUN_0070a180` / `FUN_0070a4b0`, the mechanism behind `Sabotage.OnSet`
- [11-family-ai-squad-combat.md](11-family-ai-squad-combat.md) — `Actor.RequestAttrPt`, the consumer side
- [14-family-navigation-movement.md](14-family-navigation-movement.md) — how an actor gets to the point
- [15-family-mission-objective-task.md](15-family-mission-objective-task.md) — `FocusPt.SetObjective`, `LoadMissionPictures`
- [18-family-cinematics-camera-face.md](18-family-cinematics-camera-face.md) — the `DAT_01494360` focus-point manager and the `SetTexture` stub
- [`Modules/Behavior/AttractionPts/`](../saboteur-luacd/src/Modules/Behavior/AttractionPts) — one Lua module per point *type*
