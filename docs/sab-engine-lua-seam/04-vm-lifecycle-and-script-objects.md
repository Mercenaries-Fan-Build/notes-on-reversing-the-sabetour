# VM lifecycle and script objects

## What this establishes

There is **exactly one `lua_State`** in *The Saboteur*, created once at level-load by a thin C++ wrapper
over an otherwise **stock, statically-linked Lua 5.1**. It is owned by a single ~88 KB manager singleton at
`DAT_0142d324` — the object the existing [`../symbol_map/task-managers.md`](../symbol_map/task-managers.md)
calls a "world object", which this document **corrects**: it is the script manager, and `FUN_006f96e0` is its
lazy constructor, not a `WSContext::GetGlobal`.

The engine **never calls an `Update` method on script objects**. Gameplay systems enqueue events into
per-type, lock-guarded queues on the manager; once per frame `FUN_006fb2c0` drains them and calls named Lua
handlers. `OnEnter`/`OnExit` come from a *separate* path (the controller FSM), not the tick.

It also **closes the open question in [`../formats/lua_scripts.md`](../formats/lua_scripts.md)**: descriptor
`+0x00` is `pandemic_hash("d:\" + <Scripts-relative path> + ".luac")` — reproduced **321/321**, and
round-tripped from **26/26** real `require()` strings in the corpus. The container itself is not re-derived
here; only the lookup key and the `require` path are.

Peers: [`02-marshalling-abi.md`](02-marshalling-abi.md) (the per-binding arg protocol),
[`03-handle-and-object-model.md`](03-handle-and-object-model.md) (handles → objects),
[`06-lua-side-wrapper-layer.md`](06-lua-side-wrapper-layer.md) (the `Util.*`/`Actor.*` namespacing).

---

## 1. The Lua core is stock 5.1, statically linked

Lua 5.1 is compiled into `.text` at roughly `0x00401000`–`0x0042xxxx`. Two constants pin this beyond doubt,
because they are Lua's pseudo-indices appearing as raw immediates:

| Immediate | Value | Lua 5.1 constant |
|---|---|---|
| `0xffffd8ee` | −10002 | `LUA_GLOBALSINDEX` |
| `0xffffd8f0` | −10000 | `LUA_REGISTRYINDEX` |

And the `lua_State` field layout is legible directly in the decompiled bodies — `FUN_00408310` computes
`L->top - (nargs+1)*8` and `FUN_0064c610` pushes a type tag of `6` (`LUA_TFUNCTION`):

| Offset | Field |
|---|---|
| `+0x08` | `L->top` |
| `+0x10` | `G(L)` (global_State) |
| `+0x14` | `L->ci` |
| `+0x20` | `L->stack` |

Identified core entry points (all **confirmed** by body shape against the Lua 5.1 sources):

| VA | Lua API |
|---|---|
| `FUN_00404680` | `lua_newstate(f, ud)` |
| `FUN_00404840` | `luaL_openlibs` |
| `FUN_0040b2f0` | `lua_load` |
| `FUN_00408310` | `lua_pcall(L, nargs, nresults, errfunc)` |
| `FUN_015fe1a0` | `luaL_loadstring` (wraps `lua_load` with reader `LAB_00404130`) |
| `FUN_00402120` | `lua_gc(L, what, data)` |
| `FUN_00401c40` | `lua_setfield` |
| `FUN_00401850` | `lua_pushstring` |
| `FUN_004011d0` | `lua_gettop` |
| `FUN_00466c30` | `lua_type` |
| `FUN_0064c610` | `lua_pushcclosure` |
| `FUN_00489e30` | `lua_gettable` |
| `FUN_015fc5c0` | `lua_getfield` |
| `FUN_004cb830` | `lua_isstring` |
| `FUN_006ac630` | `lua_tolstring` |
| `FUN_015fc53c` | `lua_settop` |
| `FUN_004047b0` | `lua_close` / `close_state` (GC-finalizer drain) |

> Confidence: **confirmed** for the pseudo-index constants, the `lua_State` offsets, and `lua_pcall` /
> `lua_pushcclosure` / `lua_newstate` / `lua_gc`. The remaining rows are **inferred** from call-site shape
> and argument counts; none carries a symbol or assert string.

### There is one VM, and only one

`lua_newstate` (`FUN_00404680`) has exactly **two** callers:

- `0x004042b7` → `FUN_004042b0`, which is the **stock `lua.c` standalone interpreter's** `newstate`
  (it installs a panic function and nothing else). It has `callers=[]` and is **dead code** left in the link.
- `0x0163950a` → `FUN_01639500`, the wrapper constructor. This is the **only live `lua_State` creation site
  in the binary**.

> Confidence: **confirmed**. A single live `lua_newstate` caller is a strong, checkable claim.

---

## 2. The wrapper class at `0x0163xxxx`

A small C++ class wraps the VM. Its instance is a **4-byte heap object whose only field is the `lua_State*`**
— every method dereferences `*param_1`. It is allocated by `FUN_00db39e0(4,1)` in the manager init.

**`FUN_01639500` — the constructor** (`0x01639500`), transcribed:

```c
uVar1 = FUN_00404680(FUN_006f72a0, 0);   // lua_newstate(alloc = FUN_006f72a0, ud = 0)
*param_1 = uVar1;
DAT_0142cfb8 = 0;                        // clear last-error string
FUN_00404840(*param_1);                  // luaL_openlibs  -> base/string/table/math/io/os/package/coroutine/debug
thunk_FUN_015fe1a0(*param_1, "package.path = \"Scripts\\?.lua\";");
thunk_FUN_00408310(*param_1, 0, 0, 0);   // lua_pcall(L,0,0,0)  -- the loadstring/pcall "dostring" pair
FUN_00402120(*param_1, 6, 0);            // lua_gc(L, LUA_GCSETPAUSE,   0)
FUN_00402120(*param_1, 7, 4);            // lua_gc(L, LUA_GCSETSTEPMUL, 4)
thunk_FUN_0048c250(*param_1, 0x28);      // lua_checkstack(L, 40)
```

Three things fall out of this, all load-bearing later:

1. `FUN_006f72a0` is the **engine allocator handed to Lua** — Lua's heap is the game's heap.
2. `package.path = "Scripts\?.lua"` — **backslash**, no `Scripts/` forward-slash form. This is what turns
   `require("Includes\WRAPPER_Util")` into `Scripts\Includes\WRAPPER_Util.lua`. See §5.
3. `lua_checkstack(L, 40)` matches the guard in `FUN_01639630`, which bails when `lua_gettop(L) > 0x27` (39).
   Forty stack slots is the wrapper's hard budget.

Other wrapper methods:

| VA | Role | Evidence |
|---|---|---|
| `FUN_01639470` | push global by name; error if `lua_type(L,-1) == LUA_TNIL` | `lua_getfield(L, LUA_GLOBALSINDEX, name)` |
| `FUN_01638f90` | get field from table at `idx`; out-flag set iff `lua_type == 6` (`LUA_TFUNCTION`) | body |
| `FUN_016395d0` | **the pcall wrapper** — `lua_pcall(L, nargs, LUA_MULTRET, 0)`; on non-zero calls the reporter | body |
| `FUN_016390b0` | **error reporter** | see below |
| `FUN_01639190` | registry ref (`lua_*` at `LUA_REGISTRYINDEX`) | `0xffffd8f0` |

**`FUN_016390b0` — the error path** (`0x016390b0`):

```c
iVar1 = lua_isstring(L, -1);
_Source = iVar1 ? (char*)lua_tolstring(L, -1, 0)
                : "Unknown Lua script error - next assert may help, or check output window if available";
_strncpy(&DAT_0142cfb8, _Source, 0x100);   // 256-byte last-error buffer
DAT_0142d0b7 = 0;
(*(code *)PTR_FUN_011249d8)(_Source, param_2);  // report/assert hook
thunk_FUN_015fc53c(*param_1, 0xfffffffe);       // lua_settop(L, -2) -- pop the error
```

Note the **`errfunc` argument to `lua_pcall` is always `0`** — there is no `debug.traceback` handler
installed. A script error yields the bare message only, stashed at **`DAT_0142cfb8` (256 bytes)**, which is
also cleared by the constructor and before each pcall. That is why in-game Lua errors have no stack trace.

> Confidence: **confirmed** for the constructor transcription and `FUN_016390b0` (both bodies are clean and
> carry a literal string). **Inferred** for `FUN_01639190`'s exact ref semantics.

---

## 3. The manager singleton — correcting `task-managers.md`

```
DAT_0142d324  : WSScriptManager* (proposed name), 0x15c90 bytes (88,720)
```

The lazy-init idiom is **inlined at ~920 sites** across the binary, always in this exact shape:

```c
if (DAT_0142d324 == 0) {
    iVar3 = FUN_00db39e0(0x15c90, 0);         // alloc 0x15c90
    if (iVar3 == 0) { DAT_0142d324 = 0; }
    else            { DAT_0142d324 = FUN_006f96e0(); }   // construct
}
```

`FUN_006f96e0` (`0x006f96e0`, 7 bytes) → `FUN_004d2941` (12 bytes) → **`FUN_006f96e7`** (947 bytes) — the
latter is the real constructor. The two hops are incremental-linker thunks.

### The correction

[`../symbol_map/task-managers.md`](../symbol_map/task-managers.md) lists `FUN_006f96e0` as
`WSContext::GetGlobal` ("thin accessor") and describes `DAT_0142d324` as "the ~0x15c90-byte world object".
Its own adversarial-verification section already flags this as "the lowest-confidence item in the doc" and
"pure inference (no string, no RTTI)". **The field evidence says it is the script manager:**

| Field | Meaning | Evidence |
|---|---|---|
| `+0x124` | **`lua_State*` wrapper slot array**, indexed `+0x124 + i*4` | 32 sites index it by a variable; 377 access slot 0 directly |
| `+0x15c00` | `bool` — "`LuaHook_Require` is installed in `package.loaders`" latch | `FUN_006f8a90`, `FUN_006faad0` |
| `+0x15c14` | flag byte — bit1 = initialised, bit2 = `.luap` pack loaded | `FUN_006faad0` sets `|2`, clears `&0xfb` |
| `+0x15c88` | **suspend / reload counter** — every script entry point early-outs when non-zero | ~20 sites |
| `+0xdc` / `+0xe0`, count `+0xe8` | intrusive listener list | `FUN_00432040` |
| `+0x114` / `+0x118`, count `+0x120` | intrusive listener list | `FUN_00432040` |
| `+0xb48` / `+0xb4c`, count `+0xb54` | intrusive listener list (broadcast targets) | `FUN_006f8960`, `FUN_00646460` |

An object that owns the `lua_State` array, the `package.loaders` latch, and the script suspend counter is
the script manager. It is a **process-lifetime singleton**: across all ~920 idiom sites there is **no
teardown assignment** — `DAT_0142d324` is only ever nulled in the *allocation-failure* branch of the idiom
itself.

> Confidence: **confirmed** that `DAT_0142d324` owns the VM slots and the script latches (field evidence,
> hundreds of sites). **Inferred** for the name `WSScriptManager` — no assert string or RTTI ties it.
> `FUN_006f96e7` being the real constructor is **confirmed** (call chain).

### One VM or several?

The `+0x124` **array** shows multi-VM was *designed for* — 32 sites index it by a runtime variable, and in
`FUN_00705540` that index comes from the **script object's own first field** (`iVar1 = *param_2`), i.e. each
script object records which VM it belongs to. But:

- `FUN_006faad0` writes **only slot 0** (`*(param_1 + 0x124) = uVar4`).
- No site indexes with a constant `> 0`.
- `lua_newstate` has one live caller.

So: **one VM in retail, in slot 0**; the array is vestigial capacity. It is **not** per-thread and **not**
per-script — it is per-*bank*, with one bank shipped. (The obvious candidate for slot 1 is
`LuaMissions.luap`, which retail does not ship.)

> Confidence: **confirmed** (one live VM). The *intent* of the array is **inferred**.

---

## 4. Boot and init — `FUN_006faad0`

`FUN_006faad0` (`0x006faad0`) is `WSScriptManager::Init` (proposed). Callers: `FUN_006faf00` and the bare
address `0x0043d8af` — inside the **un-headered task-vtable region** that
[`../symbol_map/task-managers.md`](../symbol_map/task-managers.md) already flags as a gap (no `FUN_` between
`0x438864` and `0x439420`). This is the same anomaly the project notes for the binding registration table.

```c
if (DAT_0132b534 == 0) {                       // one-time registration of a named profile/timer block
    _DAT_0132b52c = 10; _DAT_0132b528 = 10;
    DAT_0132b540 = DAT_0132b540 & 0xfd | 1;
    _DAT_0132b524 = 0x34; _DAT_0132b538 = 7;
    _strncpy(&DAT_0132b504, "LuaUpdateFunction", 0x1f);
}
iVar3 = FUN_00db39e0(4, 1);                    // alloc the 4-byte wrapper
uVar4 = iVar3 ? thunk_FUN_01639500() : 0;      // construct -> lua_newstate + openlibs + package.path + gc
*(undefined4 *)(param_1 + 0x124) = uVar4;      // install into VM slot 0
FUN_006f8a90(uVar4);                           // register bindings, then install the require hook (see §5)
uVar4 = **(undefined4 **)(param_1 + 0x124);    // -> lua_State*
thunk_FUN_0064c610(uVar4, &LAB_006f8220, 0);   // lua_pushcclosure(L, <engine print>, 0)
FUN_00401c40(uVar4, 0xffffd8ee, "print");      // lua_setfield(L, LUA_GLOBALSINDEX, "print")
cVar2 = FUN_00706670("LuaScripts.luap", 0);
if (cVar2 == '\0') {                           // pack MISSING -> fall back to loose files
    *(byte *)(param_1 + 0x15c14) &= 0xfb;
    puVar1 = *(undefined4 **)(param_1 + 0x124);
    if (*(char *)(param_1 + 0x15c00) != '\0') {
        thunk_FUN_015fe1a0(*puVar1, "table.remove(package.loaders, 2);");
        *(undefined1 *)(param_1 + 0x15c00) = 0;
        thunk_FUN_00408310(*puVar1, 0, 0, 0);
    }
}
FUN_006fa920("Scripts\\Modules", 0, 1);
FUN_00706670("LuaMissions.luap", 1);
FUN_00706130();
*(byte *)(param_1 + 0x15c14) |= 2;             // mark initialised
```

Two notable facts:

- **`print` is overridden** with an engine C closure at `LAB_006f8220` (routes to the debug output).
- The `.luap` pack is **optional by design**. If `LuaScripts.luap` fails to open, the engine *removes* its
  own `package.loaders` entry and lets stock Lua resolve via `package.path = "Scripts\?.lua"` from disk.
  This is exactly why `DLC/01/Scripts/*.lua` ships as **plaintext source** rather than compiled chunks —
  noted but unexplained in [`../formats/lua_scripts.md`](../formats/lua_scripts.md).

**`FUN_006faf00`** (`0x006faf00`) is the reload/resume counterpart. It decrements `+0x15c88`, and when the
counter reaches zero it calls `FUN_006faad0` again and then kicks the mission system:

```c
FUN_00705cc0(0, "Locator_MissionLauncher", "SetMission", uVar2, uVar3);
```

That is `<vm slot 0>`, object name, method name — the engine's call-by-name entry (§7). Because
`FUN_006faad0` unconditionally allocates a **fresh** wrapper and `lua_State`, a reload **replaces** the VM.

> Confidence: **confirmed** for the transcription, the `print` override, and the `package.loaders`
> add/remove pair (all literal strings in the body). **Inferred** that `"LuaUpdateFunction"` names a
> per-frame profile bucket — `DAT_0132b504` is **written here and read nowhere else in the decomp**, so its
> consumer is unpinned. **Open**: whether the old `lua_State` is closed on reload (see Open questions).

---

## 5. `require` and the module path — **solved**

### The chain

```
Lua:     require("Includes\WRAPPER_Util")
  |      package.path = "Scripts\?.lua"        <- set by FUN_01639500
  v
         "Scripts\Includes\WRAPPER_Util.lua"
  |      Util.LuaHook_Require  (package.loaders[2])
  v      FUN_00706190 @0x00706190
         "d:\Scripts\Includes\WRAPPER_Util.luac"
  |      pandemic_hash (FUN_00dc1e20)
  v
         0xda8b14f5  -> BST lookup (FUN_00706910) -> descriptor -> chunk
```

### How the hook is installed — `FUN_006f8a90` @ `0x006f8a90`

```c
if (((*(byte *)(param_1 + 0x15c14) & 4) != 0) && (*(char *)(param_1 + 0x15c00) != '\x01')) {
    thunk_FUN_015fe1a0(*param_2, "table.insert(package.loaders, 2, Util.LuaHook_Require);");
    *(undefined1 *)(param_1 + 0x15c00) = 1;
    thunk_FUN_00408310(*param_2, 0, 0, 0);
}
```

The engine does not replace Lua's `require`. It uses **stock Lua 5.1 `package.loaders`**, splicing its own
loader in at **position 2** — ahead of the file searcher but behind the `package.preload` searcher. This
is a `luaL_loadstring` + `lua_pcall` pair executed as a *Lua source string*, which is why `LuaHook_Require`
appears in `lua_bindings.txt` (it is a registered binding under the `Util` namespace — see
[`06-lua-side-wrapper-layer.md`](06-lua-side-wrapper-layer.md)) yet has no C-side caller.

### The lookup-name builder — `FUN_00706190` @ `0x00706190`

The three `.rdata` constants that [`../formats/lua_scripts.md`](../formats/lua_scripts.md) said "would
settle it" are now read out of `Saboteur.exe` (image base `0x400000`; `.rdata` VA `0xf71000`, raw `0xb70200`):

| VA | Bytes | Value |
|---|---|---|
| `DAT_00fdc408` | `64 3a 5c 00` | **`"d:\"`** — a *string*, not the pointer Ghidra's `PTR_LAB_00fdc408` implies |
| `DAT_00fdc40c` | `2e 6c 75 61 00` | **`".lua"`** |
| `DAT_00fdc414` | `63 00` | **`"c"`** |

Which makes the function read exactly:

```c
s  = "d:\";                                  // DAT_00fdc408
s += arg;                                    // "Scripts\Includes\WRAPPER_Util.lua"
for (c in s) if (c == '/') c = '\\';         // normalize
if (ends_with(s, ".lua"))                    // DAT_00fdc40c
    s += "c";                                // DAT_00fdc414   ->  ".lua" + "c" = ".luac"
```

The odd-looking `"c"` is the tail of `".luac"`: a `.lua` request is rewritten to the **compiled** name. The
`"d:\"` prefix is a fossil of the build machine's drive — the hash was baked at cook time from a path rooted
at `d:\`, and the runtime faithfully reproduces that prefix to make the key match.

### Verification

Reimplementing `FUN_00706190` verbatim and hashing with the already-confirmed `pandemic_hash`
(`FUN_00dc1e20`), against retail `LuaScripts.luap`:

```
[A] engine-exact rebuild of +0x00 key: 321/321
[B] distinct require() args in corpus: 26; resolve to a real chunk: 26; miss: 0
[C] flag==1: 86; under Scripts\Modules\: 86; agree: 321/321
```

`[A]` takes each chunk's own LuaQ debug source path, cuts it at `\bincommon\scripts\` + 0xb (exactly what
`FUN_00706200` does with `FUN_00db4400`), and rebuilds the key. `[B]` goes the other way: it takes the 26
distinct literal `require()` arguments across the 321-file corpus, pushes them through
`package.path` → `FUN_00706190` → `pandemic_hash`, and every one lands on a real descriptor. Worked example:

```
require("Includes\WRAPPER_Util")
  -> Scripts\Includes\WRAPPER_Util.lua
  -> "d:\Scripts\Includes\WRAPPER_Util.luac"
  -> pandemic_hash = 0xda8b14f5
  -> Scripts\Includes\WRAPPER_Util.lua      (descriptor found)
```

Two corrections to [`../formats/lua_scripts.md`](../formats/lua_scripts.md) fall out:

- `+0x00` is **not** a hash-map key. `FUN_00706910` is a **binary search tree** walk — it compares the u32
  key against the node, then follows `u16` left/right child *indices* with `0xffff` as the null sentinel
  (`node = idx * DAT_0150282c + DAT_0150283c`). Ghidra mistypes the node as `PRTL_CRITICAL_SECTION_DEBUG`.
- The `+0x14` is-module flag is now **explained, not just observed**: `FUN_00706200` @ `0x00706200` loops all
  descriptors and, for each whose `+0x14` equals its filter argument, loads and runs that chunk. It is the
  **autorun-at-init pass** — `flag==1` means "execute this chunk during `Init`, don't wait for a `require`".
  `[C]` reconfirms `flag==1` ⟺ under `Scripts\Modules\` at 321/321.

> Confidence: **confirmed**. 321/321 forward and 26/26 reverse against retail bytes, with every constant in
> `FUN_00706190` read from the shipped `.exe` and every step accounted for. This is byte-level proof.

---

## 6. The per-frame tick — an event pump, not an `Update` call

**`FUN_00439ff0`** (`0x00439ff0`, 647 bytes, `callers=[]` — reached by task vtable, in the same un-headered
`0x0043xxxx` region) is a per-frame update that calls ~30 subsystem updates in a flat sequence against a
delta-time global (`_DAT_014e1c68`). Partway through, it does the lazy-init idiom for `DAT_0142d324` and
then calls:

```c
FUN_006fb2c0();     // WSScriptManager::Update  (proposed)
```

**`FUN_006fb2c0`** (`0x006fb2c0`, 2819 bytes) is the script tick. Callers: `0x0043a16d` (`FUN_00439ff0`),
`0x0043a681` (`FUN_0043a280`), and bare `0x0043ca78` — all in the task region. Its shape:

```c
if (*(int *)(param_1 + 0x15c88) != 0) return;    // suspended -> skip entirely
...
while (local_10 < *(uint *)(param_1 + 0xe58)) {          // count, read under lock
    EnterCriticalSection(param_1 + 0xef0);
    LeaveCriticalSection(param_1 + 0xef0);
    if (*(int *)(local_38 + iVar9) != 0)
        FUN_00597430("OnMeleeAttack", uVar5, ..., 0);
    local_10++; local_38 += 0xc;
}
// ... repeated per event type
FUN_004cc4c0("OnStateChange",    uVar5);
FUN_004cc4c0("OnGrabbedAttack",  uVar5);
FUN_004cc4c0("OnGrabbedEnter",   uVar5);
```

This is the core architectural fact of the seam:

**Script objects are not ticked.** There is no `for each script object: call obj:Update(dt)`. Instead each
event *type* has its own fixed-capacity queue and its own `CRITICAL_SECTION` on the manager. Gameplay code —
running on **other threads** — appends to those queues. Once per frame, on the game thread, `FUN_006fb2c0`
drains every queue under its lock and calls the named Lua handler for each entry.

The critical sections are the tell: they exist because producers are multi-threaded while **the `lua_State`
is single-threaded and only ever entered from this pump** (and from the FSM path in §7). This is a
marshalling boundary, not a mutex on Lua itself.

Handler names literal in `FUN_006fb2c0`, cross-checked against the corpus:

| Handler | Corpus evidence |
|---|---|
| `OnStateChange` | `Missions/Act_1_BarFight.lua:661` — `EventType = "OnStateChange"` |
| `OnActorComplete` | `Experimental/Checkpoint_v2.lua:47` — `EventType = "OnActorComplete"` |
| `OnVehicleEnter` | `Experimental/Soldier_Broadcasts.lua:126` — `function Soldier:OnVehicleEnter(a_hVehicle)` |
| `OnVehicleExit` | `Experimental/Soldier_Broadcasts.lua:129` — `function Soldier:OnVehicleExit(a_hVehicle)` |
| `OnPurchase` | `Managers/ShopManager.lua:400` — `function ShopManager:OnPurchase(crcShopName, crcWeaponName)` |
| `OnMeleeAttack` | none — engine-side name with no corpus consumer |
| `OnGrabbedAttack`, `OnGrabbedEnter` | none |
| `FSCommand`, `ScaleForm` | Flash/HUD bridge (out of scope — see the HUD symbol map) |

The two shapes on the Lua side are visible in that table: some handlers are **subscribed** via
`Util.CreateEvent{ EventType = "..." }`, others are **plain methods on a named global table** the engine
resolves at call time. Both land in the same pump.

> Confidence: **confirmed** that `FUN_00439ff0` calls `FUN_006fb2c0` once per frame and that `FUN_006fb2c0`
> is a lock-guarded, per-type queue drain dispatching those literal names (bodies + string literals).
> **Inferred** for the names `WSScriptManager::Update` and for "producers are other threads" — the latter
> from the critical-section pattern, not from an observed cross-thread producer.

---

## 7. ScriptControllers: `OnEnter` / `OnExit`

A `ScriptController` is, on the Lua side, just a **global table named after its file** with FSM methods.
`docs/saboteur-luacd/src/ScriptControllers/Null.lua` is the minimal case in full:

```lua
if not Null then
  Null = {}
end
function Null:OnEnter()
end
function Null:OnExit()
end
```

The engine side is `FUN_0083ad20` @ `0x0083ad20` — a state-transition function that fires `OnExit` on the
outgoing controller name and `OnEnter` on the incoming one:

```c
pcVar2 = (char *)(param_1 + 0x34);              // current controller name, inline char[]
... if (name is non-empty)
    FUN_0083ab80((char *)(param_1 + 0x34), "OnExit");
local_104[0] = '\0'; local_108 = 0x100;
thunk_FUN_016397e0(param_2 + 4, &local_108);    // fetch the NEW controller name into local_104
... if (new name is non-empty)
    FUN_0083ab80(local_104, "OnEnter");
```

`FUN_0083ab80` @ `0x0083ab80` does the lazy-init idiom, gates on the suspend counter, and dispatches:

```c
if (*(int *)(DAT_0142d324 + 0x15c88) == 0) {
    iVar2 = param_1[8];
    uVar3 = (**(code **)(*param_1 + 0x6c))(iVar2);         // vtable+0x6c -> the object's handle
    cVar1 = thunk_FUN_00647bd0(0, param_2, param_3, uVar3, iVar2);   // slot 0, name, method, handle
    if (cVar1 != '\0') { FUN_0083a820(param_3); return; }
    FUN_00497380();                                        // dispatch failed
}
```

Crucially, **`OnEnter`/`OnExit` are NOT part of the frame tick**. They are edge-triggered by the controller
FSM. `PoisonField.lua` shows the idiomatic consequence: `OnEnter` does not do work, it *subscribes* —

```lua
function PoisonField:OnEnter()
  self.t_AllEvents = {}
  table.insert(self.t_AllEvents, Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = PoisonField.BuildStreamEventTable(self)
  }, "PoisonField.Configure", self))
end
```

— registering a callback that the §6 pump will later deliver. `Activate`/`Deactivate`/`Configure` in that
same file are **not** engine-invoked names; they are called from Lua (`PoisonField.Activate(self)`) or named
as event callbacks by string (`"PoisonField.Configure"`).

> Confidence: **confirmed** that `"OnEnter"`/`"OnExit"` are dispatched by name from `FUN_0083ad20` via
> `FUN_0083ab80` (literal strings, clean call graph). **Inferred** for the exact argument roles inside
> `FUN_0083ab80`/`FUN_00647bd0` — Ghidra's `__thiscall` recovery is broken here (see Open questions), so
> "arg 1 = VM slot 0" is read from the *pattern* shared with `FUN_00705cc0`, not proven positionally.

---

## 8. Calling into Lua: the two entry shapes

`FUN_00647bd0` @ `0x00647bd0` is the guard that every engine→Lua call passes:

```c
if (*(int *)(param_1 + 0x15c88) != 0) return 0;              // suspended
if (*(int *)(param_1 + 0x124 + param_2 * 4) == 0) return 0;  // no VM in that slot
thunk_FUN_016159b0(param_3, param_4, param_5, param_6);
thunk_FUN_00646460(param_3, param_4, param_5, param_6);
```

Below it sit the two dispatch shapes, and the difference is the whole "namespaced Lua, flat C" story for the
**engine→Lua** direction:

| VA | Shape | Resolution |
|---|---|---|
| `FUN_01611b50` | **global function** by name | `lua_getfield(L, LUA_GLOBALSINDEX, name)` → pcall |
| `FUN_01611c60` | **method on a named global table** | `lua_getfield(L, LUA_GLOBALSINDEX, obj)` → `FUN_01638f90(-1, method)` → pcall |

`FUN_01611c60` transcribed (the `Object:Method()` case):

```c
cVar4 = thunk_FUN_01639470(param_2, param_2);        // push _G[objName]; fail if nil
if (cVar4 != '\0') {
    thunk_FUN_01638f90(0xffffffff, param_3, &param_2);  // _G[objName][methodName]; flag = is-function
    if ((char)param_2 == '\0' || !push(param_4) || !push(param_5)) bVar1 = false;
    else bVar1 = true;
    FUN_00707040(param_1);
    if (bVar1 && thunk_FUN_016395d0(*(int *)(iVar3 + 0xc) + 2, uVar2))   // pcall
        uVar6 = 1;
}
```

So the engine resolves `_G[name][method]` **by string, at call time, on every call**. Nothing is cached —
no registry ref for the method, no precomputed index. That is what makes the Lua side hot-swappable and why
a renamed global silently no-ops rather than crashing (`FUN_01639470` reports through `FUN_016390b0` and
returns 0).

`FUN_00705540` @ `0x00705540` shows where the VM index comes from for a *script object*:

```c
iVar1 = *param_2;                                    // the object's own VM-slot index, field +0x00
uVar6 = *(undefined4 *)(param_1 + 0x124 + iVar1 * 4);
FUN_006f6970(); FUN_006f69c0(2, 0);                  // frame setup, 2 args
FUN_006f6d50(0xffffffff, 1, &local_1c);              // push arg 1
FUN_006f6d50(0xffffffff, 2, param_4);                // push arg 2
FUN_0070a310();
uVar3 = FUN_0049f8c0(iVar1, <name at param_2+0x24>, param_2 + 2, uVar6);
```

The `FUN_006f6970` / `FUN_006f69c0` / `FUN_006f6d50` primitives here are the **outbound mirror** of the
inbound marshalling primitives documented in [`02-marshalling-abi.md`](02-marshalling-abi.md)
(`FUN_006f8470` / `FUN_006f71a0` / `FUN_006f6ec0`).

`FUN_00646460` @ `0x00646460` is the **broadcast**: it walks the intrusive list at `+0xb48`, filters each
node by name (`FUN_00708c20`), and dispatches to every match — the C side of `Util.BroadcastFunction`.

> Confidence: **confirmed** for the by-name `_G[obj][method]` resolution and the no-caching claim (bodies are
> clean, pseudo-index constants are unambiguous). **Inferred** that `FUN_00646460` is
> `Util.BroadcastFunction`'s implementation — the list-walk-and-filter shape matches, but no string ties it.

---

## 9. Coroutines: present, unused

- `luaL_openlibs` (`FUN_00404840`) opens the **stock** `coroutine` library — the strings
  `"cannot resume dead coroutine"` and `"attempt to yield across metamethod/C-call boundary"` are present.
- Their only callers (`FUN_00414340`, `FUN_00414420` around `FUN_00414260`) are **inside the Lua library
  itself** — the standard `co_resume` / `auxresume` pair. No engine code reaches them.
- **`grep -rl "coroutine" --include=*.lua` over all 321 corpus files returns zero.**

There are no `lua_newthread` calls outside the stdlib and no engine threading of the VM. Asynchrony in
scripts is expressed entirely through the §6 event queues and callback registration, **not** coroutines.

> Confidence: **confirmed** (zero corpus hits; library-internal callers only).

---

## 10. Who owns script instance state?

**Lua owns the state; the engine owns a handle and a reference.**

- The per-instance table is a **Lua table**. Scripts reach it with `Actor.GetSelf(handle)` —
  e.g. `Experimental/SoldierState_Hunt.lua:26` (`local tSoldierSelf = Actor.GetSelf(hSoldier)`) and
  `Experimental/MISSION_CFrench.lua:36` (`Actor.GetSelf(hSab).bHDV_Papers = true`). That second line is the
  proof: scripts **add arbitrary fields** to the self table at runtime. The engine has no struct for
  `bHDV_Papers`; it cannot own that.
- `GetSelf` is a **C binding** (`data/lua_bindings.txt:284`), so the engine performs the handle → table
  mapping. `LUA_REGISTRYINDEX` (`0xffffd8f0`) appears at exactly **6 sites**, `FUN_01639190` among them —
  the standard way to hold a Lua value from C.
- The engine owns the **identity and lifetime**: the handle, the intrusive listener-list node, and the
  `+0x254` flag byte tested by `FUN_00646460` / `FUN_006fac90` before every dispatch.
- On reload the manager builds a **fresh `lua_State`** (§4), so all self tables are discarded wholesale.
  Anything that must survive is engine-side, which is why the `SaveLoad*` bindings exist as C functions.

> Confidence: **inferred**, but well-supported. The corpus behaviour (dynamic fields on `GetSelf` results) is
> decisive for "Lua owns the table"; `GetSelf`'s C function is **not** VA-pinned (see below), so the exact
> ref mechanism is proposed, not proven.

---

## Open questions

1. **Is the old `lua_State` closed on reload?** `FUN_006faad0` unconditionally allocates a fresh wrapper and
   VM into slot 0. `lua_close` (`FUN_004047b0`) has `callers=[]` and only 3 textual references in the whole
   decomp. If nothing closes the previous state, **every level reload leaks a full `lua_State`**. Not
   provable from the decomp — vtable/`atexit` paths are invisible. A breakpoint on `FUN_004047b0` in x32dbg
   across a checkpoint reload would settle it in minutes.
2. **`FUN_00706670`'s `0`/`1` argument is not the VM slot** — and this doc does not claim it is.
   Ghidra recovers `FUN_00706670(int *param_1, undefined4 param_2)` as `__thiscall`, yet the body uses
   `param_1` as an object (`param_1[4]` is a vtable) *and* `param_2` as a `%s` filename argument to the
   error formatter at `DAT_00fdc3e0` (`"%s"`, `"\bincommon\scripts\"`, `"LuaScripts.luap"` are adjacent in
   `.rdata`). Those are inconsistent: the true signature is almost certainly
   `(this, const char* filename, int flag)` with `ECX` dropped. What the flag selects is **open**.
3. **`"LuaUpdateFunction"` has no reader.** `DAT_0132b504` is written by `FUN_006faad0` and read nowhere in
   the decomp. The surrounding fields (`0x34`, `10`, `10`, `7`) smell like a profile/timer bucket
   registration, which would imply a *named* Lua update hook somewhere. Nothing found. Possibly vestigial.
4. **`FUN_0083ab80` / `FUN_00647bd0` / `FUN_006f8be0` argument positions are unreliable.** All three are
   rendered `__thiscall` with one fewer parameter than their call sites pass; `ECX` is dropped. The roles
   are legible from the field accesses (`+0x15c88`, `+0x124 + i*4`) but the positional mapping is inference.
5. **`GetSelf` is not VA-pinned.** The string `"GetSelf"` does not appear in the decomp at all — the name is
   known only from `lua_bindings.txt`. Finding its C function needs the registration table
   (the `0x00716a85`/`0x00716b25` anomaly; see [`02-marshalling-abi.md`](02-marshalling-abi.md)).
6. **`OnMeleeAttack`, `OnGrabbedAttack`, `OnGrabbedEnter` have no corpus consumer.** The engine dispatches
   them every frame and no shipped script handles them. Either cut content, or handlers live in the
   unshipped `LuaMissions.luap`.
7. **The `+0x124` array bound is unknown.** The next identified field is the list head at `+0xb48`, giving a
   useless upper bound of 614 slots. Only slot 0 is ever written.
8. **`FUN_006fb2c0`'s full handler set is not exhausted** here — the queue-drain loops continue past the
   names tabulated in §6, and the tail calls `FUN_00705da0` (`0x006fb928`). A full enumeration of its
   ~2819 bytes would complete the engine→Lua event vocabulary.

---

## Confidence summary

| Claim | Tier |
|---|---|
| Stock Lua 5.1, statically linked; `LUA_GLOBALSINDEX`/`LUA_REGISTRYINDEX` and `lua_State` offsets | **confirmed** |
| Exactly one live `lua_State`; created only by `FUN_01639500`; the other `lua_newstate` caller is dead `lua.c` | **confirmed** |
| `FUN_01639500` constructor transcription (`openlibs`, `package.path`, `lua_gc`, `lua_checkstack(40)`) | **confirmed** |
| `lua_pcall` always uses `errfunc = 0`; errors land in the 256-byte `DAT_0142cfb8`; no traceback | **confirmed** |
| `DAT_0142d324` (0x15c90) owns the VM slot array, the `package.loaders` latch, the suspend counter | **confirmed** |
| `FUN_006f96e0` → `FUN_004d2941` → `FUN_006f96e7` is the manager's lazy constructor | **confirmed** |
| `task-managers.md`'s "world object" / `WSContext::GetGlobal` reading is **wrong** for this object | **confirmed** (as a refutation) |
| Name `WSScriptManager` | **inferred** — no string, no RTTI |
| `require` key = `pandemic_hash("d:\" + Scripts-relative + ".luac")`; 321/321 and 26/26 | **confirmed** (byte-level) |
| `DAT_00fdc408`=`"d:\"`, `DAT_00fdc40c`=`".lua"`, `DAT_00fdc414`=`"c"` | **confirmed** (read from retail `.exe`) |
| `+0x00` is a **BST** key, not a hash-map key | **confirmed** |
| `+0x14` is-module flag = "autorun during Init" (`FUN_00706200`); ⟺ `Scripts\Modules\` at 321/321 | **confirmed** |
| Require hook is stock `package.loaders[2]`, installed by executing a Lua string | **confirmed** |
| `.luap` is optional; absent pack → `table.remove(package.loaders,2)` → loose-file fallback | **confirmed** |
| `FUN_00439ff0` → `FUN_006fb2c0` once per frame | **confirmed** |
| The tick is a lock-guarded per-type event-queue drain, **not** an `Update` on script objects | **confirmed** |
| Producers of those queues are other threads | **inferred** (from the CS pattern) |
| `OnEnter`/`OnExit` dispatched by name from `FUN_0083ad20` via `FUN_0083ab80`, edge-triggered not ticked | **confirmed** |
| Engine resolves `_G[obj][method]` by string on every call, with no caching | **confirmed** |
| `FUN_00646460` is `Util.BroadcastFunction`'s C side | **inferred** |
| No coroutines used by engine or shipped scripts | **confirmed** |
| Lua owns instance tables; engine owns handle + ref + lifetime flags | **inferred** (strongly) |
| Old `lua_State` closed on reload? | **open** |

---

## Cross-links

- [`../formats/lua_scripts.md`](../formats/lua_scripts.md) — the `.luap` container (solved there; §5 above
  closes its `+0x00` open question and corrects "hash-map" → BST).
- [`../symbol_map/task-managers.md`](../symbol_map/task-managers.md) — the Task ring and the un-headered
  `0x0043xxxx` region that `FUN_00439ff0`, `FUN_006fb2c0` and `FUN_006faad0` are dispatched from; §3 above
  corrects its reading of `DAT_0142d324` / `FUN_006f96e0`.
- [`02-marshalling-abi.md`](02-marshalling-abi.md) — inbound arg protocol; §8 documents the outbound mirror.
- [`03-handle-and-object-model.md`](03-handle-and-object-model.md) — handles, `FUN_004436f0`, `DAT_0143db28`.
- [`06-lua-side-wrapper-layer.md`](06-lua-side-wrapper-layer.md) — `Util.LuaHook_Require`'s namespace and the
  `WRAPPER_*.lua` bridge.

## Reproducing §5

```python
def pandemic_hash(s):                      # FUN_00dc1e20
    h = 0x811C9DC5
    for ch in s.encode('latin-1'):
        h = (((ch | 0x20) ^ h) * 0x1000193) & 0xFFFFFFFF
    return ((h ^ 0x2A) * 0x1000193) & 0xFFFFFFFF

def lookup_name(arg):                      # FUN_00706190 @0x00706190
    s = "d:\\" + arg.replace("/", "\\")    # DAT_00fdc408
    if s.lower().endswith(".lua"):         # DAT_00fdc40c
        s += "c"                           # DAT_00fdc414
    return s

def require_key(module):                   # package.path = "Scripts\?.lua"
    return pandemic_hash(lookup_name("Scripts\\" + module.replace("/", "\\") + ".lua"))

assert require_key("Includes\\WRAPPER_Util") == 0xda8b14f5
```
