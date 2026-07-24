# Engine -> Lua: the callback ABI

## What this establishes

The **engine -> Lua** half of the seam. Sibling docs cover the Lua -> engine direction; this one answers
how a Lua callback is *held* by C++ and *reached* from a C++ frame.

The headline result is that **The Saboteur does not store Lua function values at all.** There is no
`luaL_ref` registry handle anywhere in the callback family. A callback is registered as a **name string**
plus an optional **`self` table** and an optional **user table**, and is resolved by name at fire time.
This makes the whole callback surface late-bound, and it is why `Util.BroadcastFunction(h, "AttackTarget", {...})`
and `Vehicle.SetDeathCallback(h, "OnDeath", self, {...})` are the *same mechanism* wearing different hats.

Three further results fall out of the registration machinery, all byte-level:

1. ⚠️ **CORRECTED 2026-07-24 — true for 722 of 898, not all.** ~~Every binding is a
   `LuaGlueFunctor0<&F>` … so **every binding returns exactly one result to Lua, always**.~~
   **176 of the 898 are `LuaGlueFunctor0R`** (`int F(lua_State*)`), whose thunk is a bare `jmp` with
   no `mov eax,1` anywhere — the implementation's own `eax` becomes the Lua result count, so those
   bindings *can* vary it (typically 0 or 1). Counted from the retail image:
   `?$LuaGlueFunctor0@` = 722, `?$LuaGlueFunctor0R@` = 176, `.?AVLuaGlueFunctor@@` = 1 → 899
   descriptors; and `data/lua_registration_map.tsv` gives the same 722/176 split with
   `nresults` = `1` (709) / `eax` (172) / blank (17).
   Example: `Util.GetHandleByName`'s thunk at `0x0075d460` is `e9 cb b6 ff ff` = `jmp 0x00758b30`,
   and `FUN_00758b30` returns `0` on bad args, `1` after pushing.
   The hardcoded-`return 1` description is correct **only** for the 722 `LuaGlueFunctor0` bindings —
   see [`00-seam-overview.md`](00-seam-overview.md) §8.1, which adjudicated this.
2. The registration code is **not in the decompile** — it is the un-recovered region the project notes
   flagged as an anomaly. It is plain code, and it is walkable directly from the PE.
3. The C++ symbol names in [`data/lua_bindings.txt`](../../data/lua_bindings.txt) are **not** the
   Lua-visible names. The mapping is not derivable from the symbol — but ⚠️ **it does not have to come
   from the corpus** (corrected 2026-07-24): the Lua name is a plain `.rdata` string in each
   registration stanza, and all 898 are tabulated in `data/lua_registration_map.tsv`. Use that.

Scope note: 64 callback-registration bindings, 58 resolved to a body VA; the ABI below is derived from
`SetDeathCallback` / `ClearDeathCallback` / `BroadcastFunction`, verified against the Lua corpus.

Lua version is **5.1**, confirmed by the version string `Lua 5.1 Copyright (C) 1994-2006 Lua.o` in
`Saboteur.exe`. All `lua_type` constants below are read against 5.1.

---

## 1. The registration machine (confirmed)

The 898 names were originally recovered from `LuaGlueFunctor` RTTI. The RTTI type descriptor spells the
whole contract out. For `SetDeathCallback`, at file offset `0x00d34e71`:

```
.?AV?$LuaGlueFunctor0@$1?SetDeathCallback@@YAXPAUlua_State@@@Z@@
```

Demangled, that is `LuaGlueFunctor0<&SetDeathCallback>` where the template argument is a pointer to
`void __cdecl SetDeathCallback(struct lua_State *)`. Note the return type: **`void`**, not `int`. This is
not a stock `lua_CFunction`.

Each name additionally appears **twice** as a bare string in `.rdata`, 4-byte aligned, in a dense pool:

```
00fe8b30  67 65 64 43 61 6c 6c 62 61 63 6b 00 53 65 74 44  gedCallback.SetD
00fe8b40  65 61 74 68 43 61 6c 6c 62 61 63 6b 00 00 00 00  eathCallback....
00fe8b50  53 65 74 44 65 61 74 68 43 61 6c 6c 62 61 63 6b  SetDeathCallback
00fe8b60  00 00 00 00 43 6c 65 61 72 44 65 61 74 68 43 61  ....ClearDeathCa
```

Both copies are referenced from exactly one place each, and both are in `.text` — this is **code**, not a
table. Disassembling the registration unit at `0x007622ae` (Ghidra recovered no function here; the
nearest preceding is `FUN_00760c20`, which ends at `0x00760cbb`):

```asm
007622ae  6a 01                push 1
007622b0  6a 04                push 4
007622b2  c7 47 04 3c 8b fe 00 mov  dword ptr [edi + 4], 0xfe8b3c   ; name string -> node+4
007622b9  e8 22 17 65 00       call 0xdb39e0                        ; operator new(4)
007622c1  3b c6                cmp  eax, esi
007622c3  74 12                je   0x7622d7
007622c5  c7 00 d0 8f fe 00    mov  dword ptr [eax], 0xfe8fd0       ; LuaGlueFunctor0 vftable
007622cb  c7 05 e8 e5 42 01 50 8b fe 00  mov dword ptr [0x142e5e8], 0xfe8b50  ; 2nd name copy -> global
007622d9  57                   push edi
007622da  8b cb                mov  ecx, ebx                        ; registrar `this` = the table
007622dc  89 07                mov  dword ptr [edi], eax
007622de  e8 7d 43 f9 ff       call 0x6f6660                        ; the registrar
```

So each registration allocates a **0x14-byte node** (`[0]` = functor, `[4]` = name string, `[8..0x10]` = 0)
and a **4-byte functor** whose only member is a vftable pointer, then calls the registrar at
**`0x006f6660`** with `ecx` = some receiver object (`ebx`). Units repeat contiguously.

The `LuaGlueFunctor0` vftables are packed 8 bytes apart, interleaved with their RTTI complete-object
locators — i.e. `[COL][vfunc0]`, **one virtual method each**. `vfunc0` is a getter:

```asm
00765640  b8 f0 54 76 00       mov eax, 0x7654f0
00765645  c3                   ret
```

and `0x007654f0` is the generated glue:

```asm
007654f0  mov  eax, dword ptr [esp + 4]   ; lua_State* L
007654f4  push eax
007654f5  call 0x762da0                   ; the real SetDeathCallback(lua_State*)
007654fa  add  esp, 4
007654fd  mov  eax, 1                     ; nresults = 1, unconditionally
00765502  ret
```

**This is the whole trick.** The template adapts a `void(lua_State*)` body to a `lua_CFunction` by
hardcoding `return 1`. Every one of the resolved bindings has this identical five-instruction shape.

> **Consequence, confirmed:** a binding cannot vary its return count. It always claims exactly one
> result. A binding that pushes nothing still returns 1, so Lua receives whatever stack slot was
> there — bindings that "return nothing" are returning an unspecified value, not `nil` by construction.

Walking `name string -> vftable -> vfunc0 -> thunk -> body` mechanically resolves **663 of the 898
bindings** to real body VAs, including 58 of the 64 callback registrars. The method is a byte-level
walk over the PE, not a heuristic.

**Confidence: confirmed** (byte-level, reproducible from `Saboteur.exe` alone).

---

## 2. The marshalling primitives, decoded

The project notes named these but not their semantics. Each is a thin wrapper over the Lua 5.1 C API;
`thunk_FUN_00466c30` is `lua_type` and the comparison constant is the type tag:

| VA | Body | Meaning (Lua 5.1) |
|---|---|---|
| `FUN_006f6970` | `lua_gettop` | **argc** — used for overload dispatch |
| `FUN_006f71a0` | `lua_type(L,n) == 2` | is arg *n* **LUA_TLIGHTUSERDATA** -> **a handle** |
| `FUN_006f71c0` | `lua_type(L,n) == 5` | is arg *n* **LUA_TTABLE** |
| `FUN_006f7100` | `lua_type(L,n) == 0` | is arg *n* **LUA_TNIL** |
| `FUN_006f7160` | `lua_isstring(L,n) != 0` | is arg *n* a string |
| `FUN_006f7140` | `lua_isnumber(L,n) != 0` | is arg *n* a number |
| `FUN_006f6ec0` | `type==2 ? lua_touserdata : 0` | **fetch handle** |
| `FUN_006f7a80` | `isstring ? lua_tolstring(L,n,0) : 0` | **fetch `const char*`** |
| `FUN_006f7950` | `lua_tonumber` | fetch float |
| `FUN_006f8470` | frame/context setup | per-binding prologue |

**Engine handles are `LUA_TLIGHTUSERDATA`** — this is why `hActor` values pass through Lua opaquely and
why `WRAPPER_CheckForHandle` exists on the script side.

**Confidence: confirmed** for the type-tag readings (direct comparison constants against the 5.1 tag
values, with the 5.1 version string as the anchor).

---

## 3. The callback ABI

### 3.1 Storage: by name, not by reference

`Vehicle.SetDeathCallback` -> body **`FUN_00762da0`** (via thunk `0x007654f0`). Reduced:

```c
FUN_006f8470(param_1);                       // frame setup
cVar1 = FUN_006f71a0(1);                     // arg1 must be a handle (lightuserdata)
if (cVar1 && (cVar1 = FUN_006f7160(2))) {    // arg2 must be a STRING
  uVar4 = FUN_006f6ec0(1);                   // fetch handle
  iVar2 = FUN_0067c0a0(uVar4);               // handle -> object
  iVar2 = (**(...+ 0x194))();                // -> subsystem component
  pcVar5 = (char *)FUN_006f7a80(2);          // fetch the callback NAME
  if (pcVar5 != NULL && *pcVar5 != '\0') {   // rejected if empty
    ...
    _sprintf(acStack_20,"Event%d",uVar4);    // synthesise a unique event id
    puVar8 = FUN_00db7e10("DeathEvent",1);   // interned event-type atom
    ...
    FUN_0070a180(pcVar5);                    // install the callback NAME
    uVar4 = FUN_006f8250();
    *puVar8 = uVar4;
    if (FUN_006f71c0(3)) { FUN_0070a4b0(3); }               // arg3: table  (self)
    if (FUN_006f71c0(4)) { thunk_FUN_00481ae6(uVar3,4,0); } // arg4: table  (user table)
  }
}
```

Nothing here creates a registry reference. The only thing retained from the Lua side is the **string**
from `FUN_006f7a80(2)` plus two **tables**. The signature is therefore:

```
Vehicle.SetDeathCallback(hObject : lightuserdata,
                         sCallbackName : string,     -- non-empty, required
                         self : table,               -- optional
                         tUserTable : table)         -- optional
```

This is corroborated on the caller side. [`WRAPPER_Event.lua`](../saboteur-luacd/src/Includes/WRAPPER_Event.lua)
builds exactly this shape, and independently reproduces both the `"DeathEvent"` atom and the
`(name, self, userTable)` triple that the disassembly shows:

```lua
Vehicle.RegisterWaterLoggedCallback(a_vActor, a_sCallbackFunction, self, a_tUserTable)
eEvent = Util.CreateEvent({EventType = "DeathEvent", ObjectHandle = a_vActor},
                          a_sCallbackFunction, self, tUserTable)
```

The `"DeathEvent"` string built inside `FUN_00762da0` and the `EventType = "DeathEvent"` passed to
`Util.CreateEvent` are the same atom: `SetDeathCallback` is a shorthand that constructs the same event
object `Util.CreateEvent` constructs explicitly.

**Confidence: confirmed** for by-name storage and the string/table argument types (`lua_isstring` +
`lua_tolstring` on arg 2 is direct byte evidence; the empty-string rejection is explicit).
**Inferred** for the `self` / user-table *roles* of args 3 and 4 — the decompile proves only that both
are table-typed; the naming comes from the wrapper corpus.

### 3.2 Name resolution is dotted

`FUN_0070a180` — the function that installs the name — is a string routine that scans for `0x2e` (`'.'`)
via `FUN_00db4de0(0x2e,1)` and splits around it into two buffers. So a callback name is not an opaque
key: **`"Table.Function"` is parsed into table and field**. Bare names take the non-dotted path
(`FUN_00db47e0` guard fails -> early return with the name copied verbatim).

**Confidence: confirmed** that the name is split on `'.'`; **inferred** that the two halves are used as
table/field for the eventual lookup (the consuming code is in the un-recovered region — see Open questions).

### 3.3 Teardown

`Vehicle.ClearDeathCallback` -> **`FUN_00760a60`**: takes only arg1 (handle check `FUN_006f71a0(1)`,
fetch `FUN_006f6ec0(1)`), resolves the same `+0x194` component, and calls `thunk_FUN_004d7ec0(0)` —
i.e. installs a null callback. Clears are **per-object, not per-callback-name**: there is no name
argument, so one clear drops the object's registration wholesale.

**Confidence: confirmed** (the function takes exactly one argument and passes literal `0`).

---

## 4. `Util.BroadcastFunction` — by-name dynamic dispatch

Body **`FUN_00758d80`** (thunk `0x0075d485`). It is **overloaded on `lua_gettop`**:

```c
iVar3 = FUN_006f6970();          // argc
if (iVar3 == 3) {
  if (FUN_006f71a0(1) &&                       // arg1: handle
      FUN_006f7160(2) &&                       // arg2: string  (function name)
      (FUN_006f71c0(3) || FUN_006f7100(3))) {  // arg3: table OR nil
    FUN_006f6ec0(1); iVar3 = FUN_00498440();
    if (iVar3 != 0) { FUN_006f7a80(); FUN_00db4580(); ... }
  }
}
else if (argc >= 4 && argc <= 5) {
  // three floats (position) via FUN_006f7140/FUN_006f7950, then a radius float,
  // then FUN_006f7160(string) ...
}
```

Two forms exist:

| Form | Signature | Evidence |
|---|---|---|
| by handle | `Util.BroadcastFunction(hTarget, sFuncName, tArgs_or_nil)` | argc==3 path, `FUN_00758d80` |
| by area | `Util.BroadcastFunction(x, y, z, radius, sFuncName, ...)` | argc 4..5 path, three `lua_tonumber` fetches then a string |

The argc==3 path matches the corpus exactly —
[`Experimental/AttackAction.lua:21`](../saboteur-luacd/src/Experimental/AttackAction.lua)
`Util.BroadcastFunction(hActor, "AttackTarget", {hTarget})`, and
[`Experimental/Checkpoint.lua:203`](../saboteur-luacd/src/Experimental/Checkpoint.lua)
`Util.BroadcastFunction(self.hController, "OnCheckpointPass", {})`. Note the explicit
`FUN_006f7100(3)` **nil** acceptance: passing `nil` as the arg table is legal, not merely tolerated.

`BroadcastFunction` is the *same* by-name dispatch as the callback family — a function name string
resolved against a script object at call time. It is dispatch into script objects with no C-side
knowledge of what will answer.

**Confidence: confirmed** for the argc overload and the arg types on the argc==3 path.
**Inferred** for the exact by-area parameter order (the float/string sequence is visible, but the
decompile is heavily register-mangled and the trailing optional argument is not pinned).

---

## 5. The C++ name is not the Lua name

`lua_bindings.txt` holds **RTTI C++ symbols**. The **registered** name is the `.rdata` string. They differ,
and the Lua-visible *table* is a third thing again — set by the registrar's `this` (`ecx`/`ebx`), which is
in the un-recovered region. Cross-checking 33 callbacks against the corpus shows the prefix is **not** a
reliable oracle:

| C++ symbol | Registered string | Actual Lua name (corpus) | Prefix rule holds? |
|---|---|---|---|
| `TrigClearCallback` | `ClearCallback` | `Trigger.ClearCallback` | no — `Trig` != `Trigger` |
| `WSTrain::TrainRegisterCarriageCallback` | `TrainRegisterCarriageCallback` | `Train.TrainRegisterCarriageCallback` | no — `WSTrain` != `Train` |
| `SetDeathCallback` | `SetDeathCallback` | `Vehicle.SetDeathCallback` | no — table with no prefix |
| `SetDisguiseCallback` | `SetDisguiseCallback` | `Util.SetDisguiseCallback` | no — table with no prefix |
| `SetAmbientOnInitCallback` | `SetAmbientOnInitCallback` | `Freeplay.SetAmbientOnInitCallback` | no — table with no prefix |
| `RegisterWaterLoggedCallback` | `RegisterWaterLoggedCallback` | `Vehicle.RegisterWaterLoggedCallback` | no — table with no prefix |
| `HUDAddProgressBarCallback` | `AddProgressBarCallback` | `HUD.AddProgressBarCallback` | yes |
| `FocusPtSetOnFocusCallback` | `SetOnFocusCallback` | `FocusPt.SetOnFocusCallback` | yes |
| `SaveLoadSetupSpecialLuaTimerCallback` | `SetupSpecialLuaTimerCallback` | `SaveLoad.SetupSpecialLuaTimerCallback` | yes |
| `CombatSetFollowBoardCallback` | `SetFollowBoardCallback` | *(not called in corpus)* | unknown |

So: **where a C++ prefix exists it is a hint, sometimes abbreviated (`Trig`->`Trigger`, `WSTrain`->`Train`);
where it is absent the binding is still namespaced.** The prefix is a C++ symbol-collision workaround, not
the namespace. ⚠️ **Corrected 2026-07-24:** the corpus is *not* the only authority — the binary is.
Each registration stanza stores the Lua name as an `.rdata` C string (twice), so
`data/lua_registration_map.tsv` gives the authoritative name for all 898, including the ones the
corpus never calls.

One further irregularity: C++ `TrainRegisterTrainDecoupledCallback` registers the string
`TrainRegisterDecoupledCallback` — the difference is an *infix*, not a prefix, so even suffix-matching
the symbol against the registered string is not safe in general.

**Confidence: confirmed** that C++ symbol != registered string != Lua name (all three are directly
observed). **Confirmed** for each corpus-attested row above. The remaining tables are **open**.

---

## 6. Table: callback-registration bindings

`C++ symbol` from `lua_bindings.txt`; `Lua name` from corpus attestation where available (rows marked
"table open" are resolved to a body but their table is not corpus-attested); `body` is the real
`void(lua_State*)`; `thunk` is the `LuaGlueFunctor0` glue; `vftable` is the functor vftable.

| C++ symbol | Lua name | body VA | thunk VA | vftable |
|---|---|---|---|---|
| `AddInteriorLoadCallback` | `Util.AddInteriorLoadCallback` | `0x00751700` | `0x0075c400` | `0x00fe7e34` |
| `BinkDemoCallback` | `BinkDemoCallback` (table open) | `0x0071e2b0` | `0x0071f010` | `0x00fdfc08` |
| `CancelInteriorLoadCallback` | `Util.CancelInteriorLoadCallback` | `0x00751840` | `0x0075c420` | `0x00fe7e3c` |
| `ClearAllInteriorLoadCallbacks` | `Util.ClearAllInteriorLoadCallbacks` | `0x009caff0` | `0x0075b480` | `0x00fe7e44` |
| `ClearDeathCallback` | `Vehicle.ClearDeathCallback` | `0x00760a60` | `0x00764ec0` | `0x00fe8fd8` |
| `ClearDisguiseCallback` | (unresolved) | — | — | — |
| `ClearDisguiseCompleteCallback` | `ClearDisguiseCompleteCallback` (table open) | `0x005bcea0` | `0x0075ab60` | `0x00fe7d4c` |
| `ClearDisguiseStartedCallback` | (unresolved) | — | — | — |
| `ClearLostDisguiseCallback` | (unresolved) | — | — | — |
| `ClearRagdollCallback` | `ClearRagdollCallback` (table open) | `0x0070c490` | `0x00716580` | `0x00fde9d8` |
| `CombatSetFollowBoardCallback` | `SetFollowBoardCallback` (table open) | `0x00723de0` | `0x00725930` | `0x00fe0810` |
| `CombatSetFollowUnboardCallback` | `SetFollowUnboardCallback` (table open) | `0x00723f20` | `0x00725950` | `0x00fe0818` |
| `DrunkEffectFilterCallback` | (unresolved) | — | — | — |
| `FocusPtSetOnFailFocusCallback` | `SetOnFailFocusCallback` (table open) | `0x00729780` | `0x00729d90` | `0x00fe0e10` |
| `FocusPtSetOnFocusCallback` | `FocusPt.SetOnFocusCallback` | `0x00729680` | `0x00729d70` | `0x00fe0e08` |
| `HUDAddProgressBarCallback` | `HUD.AddProgressBarCallback` | `0x0072fd10` | `0x00731d30` | `0x00fe1e58` |
| `HeatShimmerFilterCallback` | (unresolved) | — | — | — |
| `MakeEscalationCallback` | `Util.MakeEscalationCallback` | `0x0074c420` | `0x0075b890` | `0x00fe79f4` |
| `ObjectSetOnTrappedCallback` | `SetOnTrappedCallback` (table open) | `0x0073ad20` | `0x0073ced0` | `0x00fe3350` |
| `RainCallback` | (unresolved) | — | — | — |
| `RegisterRagdollCallback` | `RegisterRagdollCallback` (table open) | `0x0070efd0` | `0x007167e0` | `0x00fde9d0` |
| `RegisterWaterCallback` | `RegisterWaterCallback` (table open) | `0x007639d0` | `0x007656d0` | `0x00fe8fc0` |
| `RegisterWaterLoggedCallback` | `Vehicle.RegisterWaterLoggedCallback` | `0x00763af0` | `0x007656f0` | `0x00fe8fc8` |
| `SaveLoadSetupSpecialLuaTimerCallback` | `SaveLoad.SetupSpecialLuaTimerCallback` | `0x00741c10` | `0x00742080` | `0x00fe4240` |
| `SetAmbientOnCompleteCallback` | `Freeplay.SetAmbientOnCompleteCallback` | `0x0072b810` | `0x0072c440` | `0x00fe13b4` |
| `SetAmbientOnInitCallback` | `Freeplay.SetAmbientOnInitCallback` | `0x0072b920` | `0x0072c420` | `0x00fe13ac` |
| `SetAmbientOnReloadCallback` | `Freeplay.SetAmbientOnReloadCallback` | `0x0072ba30` | `0x0072c460` | `0x00fe13bc` |
| `SetDeathCallback` | `Vehicle.SetDeathCallback` | `0x00762da0` | `0x007654f0` | `0x00fe8fd0` |
| `SetDisguiseCallback` | `Util.SetDisguiseCallback` | `0x00758080` | `0x0075d1d0` | `0x00fe7d14` |
| `SetDisguiseCompleteCallback` | `Util.SetDisguiseCompleteCallback` | `0x00753510` | `0x0075c170` | `0x00fe7d44` |
| `SetDisguiseStartedCallback` | `Util.SetDisguiseStartedCallback` | `0x007581d0` | `0x0075d240` | `0x00fe7d24` |
| `SetDoMeleeCallbacks` | `SetDoMeleeCallbacks` (table open) | `0x00724590` | `0x007259f0` | `0x00fe0858` |
| `SetFollowObjectBoardCallback` | `SetFollowObjectBoardCallback` (table open) | `0x00735cf0` | `0x00737020` | `0x00fe288c` |
| `SetFollowObjectUnboardCallback` | `SetFollowObjectUnboardCallback` (table open) | `0x00735e10` | `0x00737040` | `0x00fe2894` |
| `SetLostDisguiseCallback` | `Util.SetLostDisguiseCallback` | `0x00758320` | `0x0075d2b0` | `0x00fe7d34` |
| `SetPlayerLappedCallback` | `Vehicle.SetPlayerLappedCallback` | `0x00762c90` | `0x007654b0` | `0x00fe8f80` |
| `SetPlayerPlantedTrapCallback` | `SetPlayerPlantedTrapCallback` (table open) | `0x0070f220` | `0x00716800` | `0x00fdeb20` |
| `SetPlayerSpeedCallback` | `SetPlayerSpeedCallback` (table open) | `0x00762d00` | `0x007654d0` | `0x00fe8f88` |
| `SetRaceCheckPointCallback` | `SetRaceCheckPointCallback` (table open) | `0x00762b10` | `0x00765450` | `0x00fe8f68` |
| `SetRaceFinishedCallback` | `Vehicle.SetRaceFinishedCallback` | `0x007629c0` | `0x007653f0` | `0x00fe8f50` |
| `SetRaceLoadedCallback` | `Vehicle.SetRaceLoadedCallback` | `0x007628e0` | `0x007653b0` | `0x00fe8f40` |
| `SetRaceOffTrackCallback` | `Vehicle.SetRaceOffTrackCallback` | `0x00762aa0` | `0x00765430` | `0x00fe8f60` |
| `SetRacePlaceChangeCallback` | `Vehicle.SetRacePlaceChangeCallback` | `0x00762c20` | `0x00765490` | `0x00fe8f78` |
| `SetRaceStartCallback` | `Vehicle.SetRaceStartCallback` | `0x00762950` | `0x007653d0` | `0x00fe8f48` |
| `SetRaceWrongWayCallback` | `SetRaceWrongWayCallback` (table open) | `0x00762a30` | `0x00765410` | `0x00fe8f58` |
| `SetRacerNearPlayerCallback` | `Vehicle.SetRacerNearPlayerCallback` | `0x00762b80` | `0x00765470` | `0x00fe8f70` |
| `SetStuckCallback` | `SetStuckCallback` (table open) | `0x007634d0` | `0x00765690` | `0x00fe8ed8` |
| `SetupCollectableCallback` | `Freeplay.SetupCollectableCallback` | `0x0072bb40` | `0x0072c480` | `0x00fe13dc` |
| `TrigClearCallback` | `Trigger.ClearCallback` | `0x0074ad70` | `0x0074ba60` | `0x00fe57b0` |
| `WSTrain::TrainRegisterCarriageCallback` | `Train.TrainRegisterCarriageCallback` | `0x00623550` | `0x006274c0` | `0x00fbc43c` |
| `WSTrain::TrainRegisterCreationCallback` | `TrainRegisterCreationCallback` (table open) | `0x00623350` | `0x00627480` | `0x00fbc42c` |
| `WSTrain::TrainRegisterDeathCallback` | `TrainRegisterDeathCallback` (table open) | `0x00623f70` | `0x00627520` | `0x00fbc454` |
| `WSTrain::TrainRegisterEngineCallback` | `Train.TrainRegisterEngineCallback` | `0x00623450` | `0x006274a0` | `0x00fbc434` |
| `WSTrain::TrainRegisterFinishRegistrationCallback` | `Train.TrainRegisterFinishRegistrationCallback` | `0x00623650` | `0x006274e0` | `0x00fbc444` |
| `WSTrain::TrainRegisterLocationCallback` | `TrainRegisterLocationCallback` (table open) | `0x00623250` | `0x00627460` | `0x00fbc424` |
| `WSTrain::TrainRegisterPlayerCarriageTriggerCallback` | `Train.TrainRegisterPlayerCarriageTriggerCallback` | `0x00623e50` | `0x00627600` | `0x00fbc48c` |
| `WSTrain::TrainRegisterPlayerDistanceCallback` | `Train.TrainRegisterPlayerDistanceCallback` | `0x00624070` | `0x00627620` | `0x00fbc494` |
| `WSTrain::TrainRegisterStreamoutCallback` | `Train.TrainRegisterStreamoutCallback` | `0x00623750` | `0x00627500` | `0x00fbc44c` |
| `WSTrain::TrainRegisterTrainAmmoCallback` | `TrainRegisterTrainAmmoCallback` (table open) | `0x00623a50` | `0x00627580` | `0x00fbc46c` |
| `WSTrain::TrainRegisterTrainDecoupledCallback` | `TrainRegisterDecoupledCallback` (table open) | `0x00623d50` | `0x006275e0` | `0x00fbc484` |
| `WSTrain::TrainRegisterTrainItemCallback` | `TrainRegisterTrainItemCallback` (table open) | `0x00623850` | `0x00627540` | `0x00fbc45c` |
| `WSTrain::TrainRegisterTrainNaziCallback` | `Train.TrainRegisterTrainNaziCallback` | `0x00623b50` | `0x006275a0` | `0x00fbc474` |
| `WSTrain::TrainRegisterTrainNaziDeathCallback` | `TrainRegisterTrainNaziDeathCallback` (table open) | `0x00623c50` | `0x006275c0` | `0x00fbc47c` |
| `WSTrain::TrainRegisterTrainWeaponCallback` | `TrainRegisterTrainWeaponCallback` (table open) | `0x00623950` | `0x00627560` | `0x00fbc464` |

Six rows are unresolved by the vftable walk (`ClearDisguiseCallback`, `ClearDisguiseStartedCallback`,
`ClearLostDisguiseCallback`, `DrunkEffectFilterCallback`, `HeatShimmerFilterCallback`, `RainCallback`).
They have RTTI but their registration unit did not match the `mov [edi+4], <name>` shape — they are
likely registered by a different code path (see Open questions), not absent.

`ClearAllInteriorLoadCallbacks` resolving to `0x009caff0` — far from its neighbours in the `0x0075xxxx`
band — is genuine and worth flagging: its thunk `0x0075b480` sits with the others, but the body lives in
a separate cluster.

**Confidence: confirmed** for every VA in the table (each is a mechanical walk from the registered
string). **Confirmed** for the Lua names that are corpus-attested; **open** for those marked "table open".

---

## 7. Callback parameter lists

The parameter list a callback *receives* is not derivable from the registrar — the registrar only stores a
name and two tables. The invocation site builds the argument list, and those sites are in the
un-recovered region. What the registrars *do* pin, for the whole family, is the **registration** shape:

```
<Table>.<SetXxxCallback>(hObject, sCallbackName, self, tUserTable)
```

verified directly for `SetDeathCallback` (`FUN_00762da0`) and corroborated for
`RegisterWaterLoggedCallback` by `WRAPPER_Event.lua`. The wrapper corpus shows the *script-side*
convention is `function self:CallbackName(...)` invoked with `self` as receiver and the user table
threaded through — consistent with args 3 and 4 being `self` and `tUserTable`.

**Confidence: inferred**, and deliberately not enumerated per-callback. Fabricating 58 parameter lists
from naming alone would be exactly the kind of confident-and-wrong output the project rules forbid.

---

## 8. Where the invocation lives, and what I could not close

The registration region, the invocation region, and the namespace-table assignment are all in code Ghidra
did not recover — the same anomaly recorded in the project notes (callers at `0x00716a85`, `0x00716b25`
"inside no exported function"). This doc **explains** that anomaly: the region is real, dense,
compiler-generated registration code, and it is walkable straight from the PE (Section 1). But the
consumer side of `FUN_0070a180`'s stored name is in that same blind spot.

I tried and failed to pin the invocation primitive honestly:

- `FUN_0040a580` is `luaD_rawrunprotected` (`__setjmp3` + indirect call, restores `L->errorJmp` at `+0x5c`);
  its sole caller `FUN_0045ee96` is `luaD_pcall`. So the Lua core **does** have protected-call machinery.
- `FUN_00404680` is `lua_newstate`, not `lua_pcall` — the Lua C API is heavily inlined here, and I could
  not walk `luaD_pcall` up to an engine-side caller.
- `FUN_006f8330` longjmps to a **global** `jmp_buf` `DAT_0142d0c0` and sits in the Lua-wrapper cluster,
  which makes it a tempting `lua_atpanic` handler. **It is not claimed here:** a byte scan for the
  literal `0x006f8330` finds **zero** references anywhere in the image, so it is unreferenced code. The
  single `PANIC: unprotected error in call to Lua API (%s)` string is Lua's stock default, not evidence
  of a custom handler.

So: **whether engine->Lua callbacks are invoked under `lua_pcall` or a bare `lua_call`, and what happens
when one errors mid-frame, is OPEN.** I could not answer it from the decompile, and I am not going to
guess it.

---

## Open questions

1. **Protected or not?** Is the by-name invocation wrapped in `lua_pcall`? A script error inside
   `OnDeath` either aborts the frame or is swallowed — this is the single highest-value unknown here and
   it is unresolved. Resolving it needs the un-recovered region disassembled (or a live breakpoint on
   `luaD_pcall` = `FUN_0045ee96` with a deliberately-erroring callback).
2. **The registrar's receiver.** `0x006f6660` is called with `ecx = ebx`. Recovering where `ebx` is set
   per registration block would yield the Lua table for **all 663** resolved bindings mechanically, and
   would close every "table open" row in Section 6. This is the highest-leverage next step.
3. **The second name copy.** Each name is in `.rdata` twice; copy 2 goes to a per-binding global
   (`0x0142e5e8` for `SetDeathCallback`). Its purpose is unknown — plausibly a debug/profiler name, but
   unverified.
4. **The six unresolved registrars.** `ClearDisguiseCallback`, `ClearDisguiseStartedCallback`,
   `ClearLostDisguiseCallback`, `DrunkEffectFilterCallback`, `HeatShimmerFilterCallback`, `RainCallback`
   have RTTI but no matching registration unit. Which alternate path registers them?
5. **Argument lists at fire time.** Blocked on (1)/(2).
6. **`WSStreamEvent.cpp`.** Both assertion sites (`FUN_0070b700`, `FUN_0070b990`, lines `0xb9` and `0x98`)
   are in functions with **empty caller lists** — reached only indirectly. They are allocator/list
   plumbing (`FUN_00db85b0(0x14, ...)`), not the event dispatch itself. The `Event.*` wrapper
   (`WRAPPER_Event.lua`) is documented above through `Util.CreateEvent`; the C++ stream-event dispatch
   behind it is **not** reversed here.

## Reproducing

The name -> body walk is mechanical and needs only `Saboteur.exe`:

1. Find the binding name as a NUL-terminated string in `.rdata` (image base `0x00400000`;
   `.rdata` VA `0x00f71000`, raw `0x00b70200`).
2. Find the single `.text` reference to it — it is the operand of `mov [edi+4], <name>`.
3. Within `0x24` bytes, read the operand of `mov [eax], <vftable>`.
4. `vftable[0]` is a getter of the form `mov eax, <thunk>; ret` (`b8 ?? ?? ?? ?? c3`).
5. The thunk's single `call` target is the body.

A note for anyone grepping the decompile on Windows: **Git Bash mangles backslashes in command
arguments**, so `grep -F 'Script\\Interface'` silently returns zero hits against a file that plainly
contains the string. Use a character class (`grep -o 'Script..[A-Za-z]*..[A-Za-z]*[.]cpp'`) or Python.
There are only **21** `Script\*.cpp` assertion sites in the whole 54 MB decompile, and only **12** of the
898 binding names appear as quoted C strings anywhere in it — the assertion-string method that pins
`ActorRagdoll` does not generalise, which is why this doc works from the PE instead.

## See also

- [`data/lua_bindings.txt`](../../data/lua_bindings.txt) — the 898 RTTI C++ symbols (not Lua names; see Section 5)
- [`docs/formats/lua_scripts.md`](../formats/lua_scripts.md) — the `.luap` container (solved elsewhere)
- [`docs/symbol_map/`](../symbol_map/) — per-subsystem VA maps; `vehicle-train.md` and `human-disguise.md`
  overlap this callback set
- [`WRAPPER_Event.lua`](../saboteur-luacd/src/Includes/WRAPPER_Event.lua) — the `Event.*` wrapper
