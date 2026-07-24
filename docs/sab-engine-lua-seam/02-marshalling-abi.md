# The marshalling ABI: how a Saboteur Lua binding reads its arguments

## What this establishes

Every engine-side Lua binding in `The Saboteur` is a **stock Lua 5.1 `lua_CFunction`** —
`int f(lua_State *L)` — and the recurring `FUN_006f7xxx` "primitives" are **not** a bespoke
Pandemic calling convention. They are one-line `__thiscall` methods on a thin C++ wrapper class
whose field 0 is the `lua_State *`, each forwarding to a single stock Lua C API call.

That means the decoder ring is small and total: **the `n` in `FUN_006f71a0(n)` is a plain Lua stack
index, and each primitive is `lua_is*`/`lua_to*` for exactly one Lua type.** Once you know which
primitive maps to which type, you can read any binding's signature straight off its decomp body
without further reversing.

Two corrections to the working assumptions this doc was started from, both load-bearing:

- **`FUN_006f8470` is not "frame setup."** It is a `lua_State *` → wrapper-object lookup on the
  script-manager singleton. See [The `this` pointer Ghidra hid](#the-this-pointer-ghidra-hid).
- **`*(int *)(iVar2 + 0xb8) == 9` is not a Lua type tag.** It is an engine object field, read after
  the handle has already left the Lua stack. Lua tags never exceed 8. See [Not a type tag](#not-a-type-tag).

Scope boundary: this doc covers argument marshalling and the return path only. The registration
table that installs these functions into the VM, and the `WRAPPER_*.lua` namespace mapping, belong
to sibling docs in this directory. The `.luap` container is already solved in
[`docs/formats/lua_scripts.md`](../formats/lua_scripts.md); engine-side subsystem VAs live under
[`docs/symbol_map/`](../symbol_map/README.md).

---

## 1. The three layers

| Layer | Address range (observed) | What it is |
|---|---|---|
| Lua 5.1 core, statically linked, symbols stripped | `0x00401000`–`0x0040bxxx`, plus folded strays at `0x0044xxxx`, `0x0046xxxx`, `0x004cxxxx`, `0x006acxxx` | Unmodified PUC-Rio `lapi.c` / `lvm.c` / `lobject.c` |
| Pandemic wrapper class (one method = one API call) | `0x006f68a0`–`0x006f84xx` | `__thiscall` methods; `this[0]` is the `lua_State *` |
| The bindings themselves | `0x00700000`–`0x00760000` | `lua_CFunction`s, one per Lua-visible name |

The wrapper layer is **not** an abstraction over Lua — it adds no state, no coercion policy, and no
dispatch. It exists only so engine C++ can say `state->IsHandle(1)` instead of
`lua_type(L,1)==LUA_TLIGHTUSERDATA`. Every method is 25–57 bytes and inlines to one or two Lua calls.

**Confidence: confirmed** — every function cited below was read in full; the layering follows from
the bodies, not from naming.

---

## 2. Proving it is Lua 5.1 (not 5.0, not custom)

The binary exports no `lua_*` symbols (a `grep` for `lua_`/`luaL_` over all 36,935 functions returns
only the string `"lua_debug> "` at two call sites, from the standalone `lua.c` REPL that got linked
in). Identification is therefore structural. `FUN_00401000` is `index2adr`:

```c
undefined4 * __fastcall FUN_00401000(int param_1 /* idx */, int param_2 /* L */)
{
  if (param_1 < 1) {
    if (-10000 < param_1) return (undefined4 *)(*(int *)(param_2 + 8) + param_1 * 8);
    if (param_1 == -0x2712) puVar2 = (undefined4 *)(param_2 + 0x44);       // LUA_GLOBALSINDEX
    else {
      if (param_1 == -0x2711) {                                            // LUA_ENVIRONINDEX
        *(undefined4 *)(param_2 + 0x4c) = *(undefined4 *)(**(int **)(*(int *)(param_2 + 0x14) + 4) + 0xc);
        *(undefined4 *)(param_2 + 0x50) = 5;                               // tt = LUA_TTABLE
        return (undefined4 *)(param_2 + 0x4c);
      }
      if (param_1 == -10000) return (undefined4 *)(*(int *)(param_2 + 0x10) + 0x5c); // LUA_REGISTRYINDEX
      iVar1 = **(int **)(*(int *)(param_2 + 0x14) + 4);                    // curr_func(L)
      puVar2 = (undefined4 *)(iVar1 + 0xc + (-0x2712 - param_1) * 8);      // cl->upvalue[n]
      if ((int)(uint)*(byte *)(iVar1 + 7) < -0x2712 - param_1) return &DAT_010a28ac; // nupvalues
    }
  }
  else {
    puVar2 = (undefined4 *)(*(int *)(param_2 + 0xc) + -8 + param_1 * 8);   // L->base + (idx-1)
    if (*(undefined4 **)(param_2 + 8) <= puVar2) return &DAT_010a28ac;     // >= L->top -> nilobject
  }
  return puVar2;
}
```

The decisive constant is **`-0x2711` (-10001) = `LUA_ENVIRONINDEX`**. Lua 5.0 has no
`LUA_ENVIRONINDEX` and places `LUA_GLOBALSINDEX` at -10001; Lua 5.1 introduced `LUA_ENVIRONINDEX`
at -10001 and moved `LUA_GLOBALSINDEX` to -10002. This binary uses the **5.1** triple
(`-10000` registry, `-10001` environ, `-10002` globals), and the upvalue arithmetic
`base + 0xc + (LUA_GLOBALSINDEX - idx) * 8` with `nupvalues` at closure offset 7 is 5.1's
`ClosureHeader` layout exactly.

Corroborating layout facts, all consistent with unmodified 5.1:

| Struct | Field | Offset here | Stock Lua 5.1 |
|---|---|---|---|
| `lua_State` | `top` | `+0x08` | `+0x08` |
| `lua_State` | `base` | `+0x0c` | `+0x0c` |
| `lua_State` | `l_G` | `+0x10` | `+0x10` |
| `lua_State` | `ci` | `+0x14` | `+0x14` |
| `lua_State` | `l_gt` (globals table) | `+0x44` | `+0x44` |
| `lua_State` | `env` | `+0x4c` | `+0x4c` |
| `global_State` | registry | `+0x5c` | `+0x5c` |
| `ClosureHeader` | `nupvalues` | `+0x07` | `+0x07` |
| `ClosureHeader` | `env` | `+0x0c` | `+0x0c` |
| `TString` | `len` / `svalue` | `+0x0c` / `+0x10` | `+0x0c` / `+0x10` |
| `Udata` | payload start | `+0x18` | `+0x18` |

`&DAT_010a28ac` is `luaO_nilobject`. `&PTR_DAT_010a2744` is `luaT_typenames[]`, indexed directly by
tag in `FUN_00402c50` (`(&PTR_DAT_010a2744)[puVar3[1]]`, with `-1` → the literal `"no value"`) —
that is 5.1's `tag_error`/`luaL_typerror` verbatim.

**Confidence: confirmed.**

### The one real customization: `lua_Number` is `float`, not `double`

`TValue` here is **8 bytes**, not the stock 16. Four independent proofs:

1. `FUN_004011d0` (`lua_gettop`) is `return *(int *)(L + 8) - *(int *)(L + 0xc) >> 3;` — a `>> 3`
   divide, i.e. stride 8. A stock `double` build divides by 16.
2. `index2adr` scales indices by `* 8` (above).
3. `FUN_004017d0` (`lua_pushnumber`) writes a **4-byte** value then `tt` at `[1]`:
   ```c
   puVar1 = *(undefined4 **)(param_1 + 8);   // L->top
   *puVar1 = param_2;                        // 4-byte value
   puVar1[1] = 3;                            // tt = LUA_TNUMBER
   *(int *)(param_1 + 8) = *(int *)(param_1 + 8) + 8;  // api_incr_top
   ```
4. `FUN_00401510` (`lua_tonumber`) types the slot as `float *` and returns `(float10)*pfVar1`;
   `FUN_0040b430` (`luaO_str2d`) parses into a `float` local.

So this is a `LUAI_NUMBER=float` build of Lua 5.1. **This is why every wrapper push method casts:**
`FUN_004017d0(*param_1,(float)param_4)`. It is a genuine precision property of the scripting
seam, not a decompiler artifact — Lua numbers in The Saboteur carry ~24 bits of mantissa, and
integer handles/IDs above 2^24 would not survive a round-trip through a Lua number. (Handles do not
round-trip as numbers; they are lightuserdata — see below — so this is a latent constraint, not an
observed bug.)

**Confidence: confirmed** for `TValue` = 8 bytes and `lua_Number` = `float`. **Inferred** that no
handle is ever passed as a number (argued from the lightuserdata pathway, not exhaustively checked).

### The Lua 5.1 tag enum, as used by this binary

Every comparison found in the wrapper layer resolves against stock `lua.h`:

| Tag | Constant | Seen in |
|---|---|---|
| `-1` | `LUA_TNONE` (invalid/absent index) | `FUN_00466c30` returns `0xffffffff` for `nilobject` |
| `0` | `LUA_TNIL` | `FUN_006f7100`, `FUN_004017b0` |
| `1` | `LUA_TBOOLEAN` | `FUN_006f7120`, `FUN_00460596` |
| `2` | `LUA_TLIGHTUSERDATA` | `FUN_006f71a0`, `FUN_004019d0`, `FUN_004cc330` |
| `3` | `LUA_TNUMBER` | `FUN_004017d0`, `FUN_004013c0`, `FUN_00401510` |
| `4` | `LUA_TSTRING` | `FUN_004cb830`, `FUN_006ac630` |
| `5` | `LUA_TTABLE` | `FUN_006f71c0`, `index2adr` environ path |
| `6` | `LUA_TFUNCTION` | `FUN_00465770` |
| `7` | `LUA_TUSERDATA` | `FUN_004cc330` (`return *piVar1 + 0x18`) |
| `8` | `LUA_TTHREAD` | not observed in the wrapper layer |

**Confidence: confirmed.**

---

## 3. The identified raw Lua 5.1 C API functions

These are the stock entry points the wrapper forwards to. Names are assigned from body-shape match
against PUC-Rio 5.1 source.

| VA | Stock name | Body evidence |
|---|---|---|
| `0x00401000` | `index2adr` | pseudo-index triple, `nilobject` returns |
| `0x004011d0` | `lua_gettop` | `(L->top - L->base) >> 3` |
| `0x00401510` | `lua_tonumber` | `tt==3` → `*(float*)o`; `tt==4` → `luaO_str2d` |
| `0x004017b0` | `lua_pushnil` | writes `tt=0`, `top += 8` |
| `0x004017d0` | `lua_pushnumber` | writes value + `tt=3`, `top += 8` |
| `0x00401850` | `lua_pushstring` | `NULL` → pushnil, else string path |
| `0x004018f0` | `lua_pushfstring` | `"%s expected, got %s"` formatter |
| `0x004019b0` → `0x00460596` → `0x004019c4` | `lua_pushboolean` | sets `tt=1`, `top += 8` |
| `0x004019d0` | `lua_pushlightuserdata` | writes value + `tt=2`, `top += 8` |
| `0x00402c50` | `luaL_checkinteger` | isnumber-or-`luaO_str2d`, else `tag_error("number")` |
| `0x00403bb0` | `lua_getfield`-family (registry path) | `luaO_nilobject` guard + `luaV_gettable` |
| `0x0040b430` | `luaO_str2d` | `strtoul` base-16 on `'x'`/`'X'`, result into `float` |
| `0x00441120` | `lua_toboolean` | `tt != 0 && (tt != 1 \|\| value != 0)` = `!l_isfalse(o)` |
| `0x004658d0` | `lua_pushvalue` | copies both `TValue` words, `top += 8` |
| `0x00466c30` | `lua_type` | `nilobject` → `-1`, else `o->tt` |
| `0x004cb830` | `lua_isstring` | `tt == 4 \|\| tt == 3` |
| `0x004cc330` | `lua_touserdata` | `tt==2` → `pvalue`; `tt==7` → `rawuvalue + 0x18`; else `0` |
| `0x006ac630` | `lua_tolstring` | `luaV_tostring` + GC step, returns `ts + 0x10`, len at `ts + 0xc` |

**Confidence: confirmed** for all rows except `0x00403bb0`, which is **inferred** (shape matches the
`lua_getfield`/`luaV_gettable` family but the exact 5.1 entry point was not disambiguated).

---

## 4. The `this` pointer Ghidra hid

This is the single fact that makes the primitives legible. Ghidra recovered them as
`__thiscall`:

```c
bool __thiscall FUN_006f71a0(undefined4 *param_1, undefined4 param_2)
{
  int iVar1;
  iVar1 = thunk_FUN_00466c30(*param_1, param_2);   // lua_type(this->L, param_2)
  return iVar1 == 2;                                // == LUA_TLIGHTUSERDATA
}
```

`param_1` is `this` (in `ECX`, invisible at the call site); `param_2` is the **only real argument**,
and it is the **Lua stack index**. `*param_1` — `this[0]` — is the `lua_State *`. So when a binding's
decomp reads `FUN_006f71a0(1)`, the source was `state->IsHandle(1)`, and it compiles to
`lua_type(L, 1) == LUA_TLIGHTUSERDATA`.

**The index is a plain Lua stack index, with full stock semantics:** `1` is the first argument,
`2` the second, and negative values work — `FUN_00707516 @0x00707516` calls `FUN_006f7140(0xffffffff)`
i.e. index `-1` (top of stack). It is *not* a private slot numbering.

### `FUN_006f8470` is a state→wrapper lookup, not frame setup

```c
undefined4 __thiscall FUN_006f8470(int param_1 /* this: script mgr */, int param_2 /* L */)
{
  iVar1 = 0;
  puVar2 = (undefined4 *)(param_1 + 0x124);
  do {
    if (*(int *)*puVar2 == param_2) {                              // wrapper->L == L ?
      return *(undefined4 *)(param_1 + 0x124 + iVar1 * 4);
    }
    iVar1 = iVar1 + 1;
    puVar2 = puVar2 + 1;
  } while (iVar1 < 1);
  return 0;
}
```

An array of wrapper pointers at `this + 0x124` — **exactly one slot in this build** (`while (iVar1 < 1)`)
— searched for the wrapper whose field 0 equals the incoming `lua_State *`. It returns that wrapper
in `EAX`. The binding prologue is therefore:

```c
if (DAT_0142d324 == 0) {                       // script manager singleton
  iVar2 = FUN_00db39e0(0x15c90, 0);            // alloc 0x15c90 bytes
  DAT_0142d324 = (iVar2 == 0) ? 0 : FUN_006f96e0();
}
FUN_006f8470(param_1);                         // ECX = DAT_0142d324; EAX = the wrapper for L
```

and the `EAX` result is what feeds `ECX` for every subsequent `FUN_006f7xxx` call. Ghidra drops both
the `ECX` argument and the `EAX` result, which is why the call looks like a bare
`FUN_006f8470(param_1)` returning void.

Note the returned wrapper is used **without a null check** in every binding examined
(`FUN_00714230`, `FUN_00710750`, `FUN_00743cf0`, `FUN_00714090`) — a `lua_State *` not in the table
would dereference `0`. With a single-entry table and a single scripting VM this is unreachable in
practice.

**Confidence:** the body, the `+0x124` array, the 1-entry bound, and `wrapper[0] == lua_State *`
are **confirmed** (the latter follows from every accessor doing `*param_1` and passing it where
stock Lua expects `L`). That `ECX` at the call site is specifically `DAT_0142d324`, and that `EAX`
is threaded into the following calls, is **inferred** — it is the only assignment consistent with
the singleton null-check immediately preceding it and with the accessors being `__thiscall`, but
`ECX` dataflow was not confirmed against raw disassembly.

---

## 5. The decoder ring

`n` is a Lua stack index in every row. `this` is the wrapper; `L` is `this[0]`.

### Type checks — `bool` return

Each returns `true` only if the slot exists **and** holds that exact type. Because `lua_type`
returns `LUA_TNONE` (`-1`) for an absent or out-of-range index, **these are combined
presence-and-type checks** — a missing argument and a wrong-typed argument are indistinguishable to
the caller. This answers the standing question about `FUN_006f71a0`'s `char` return: it is neither
"presence" nor "type-match" alone, but the conjunction, specialised to one type.

| Primitive | Lowers to | True when | Lua type moved |
|---|---|---|---|
| `FUN_006f7100` | `lua_type(L,n) == 0` | slot is `nil` | nil |
| `FUN_006f7120` | `lua_type(L,n) == 1` | slot is a boolean | boolean |
| `FUN_006f7140` | `lua_isnumber(L,n)` (`0x004013c0`) | number, **or** string coercible via `luaO_str2d` | number |
| `FUN_006f7160` | `lua_isstring(L,n)` (`0x004cb830`) | string **or** number | string |
| `FUN_006f71a0` | `lua_type(L,n) == 2` | slot is lightuserdata | **handle** |
| `FUN_00465770` | `lua_type(L,n) == 6` | slot is a function | function |
| `FUN_006f71c0` | `lua_type(L,n) == 5` | slot is a table | table |

Note the asymmetry inherited from stock Lua: `FUN_006f7140` and `FUN_006f7160` are **coercing**
checks (a number passes `isstring`, a numeric string passes `isnumber`), while the `lua_type ==`
rows are **exact**. A binding that guards a handle with `FUN_006f71a0` will reject a number; a
binding that guards a name with `FUN_006f7160` will silently accept `Util.Foo(42)`.

### Value fetches

| Primitive | Lowers to | Returns | Lua type moved |
|---|---|---|---|
| `FUN_006f6e60` | `lua_toboolean(L,n) == 1` (`0x00441120`) | `bool` | boolean |
| `FUN_006f7950` | `lua_isnumber` ? `lua_tonumber` : `0.0` | `float` | number |
| `FUN_006f7990` | `lua_isnumber` ? `luaL_checkinteger` : `0` | `int` | number (as integer) |
| `FUN_006f7a80` | `lua_isstring` ? `lua_tolstring(L,n,NULL)` : `0` | `const char *` | string |
| `FUN_006f6ec0` | `lua_type==2` ? `lua_touserdata` : `0` | `void *` | **handle** |
| `FUN_006f6e80` | *byte-identical to `FUN_006f6ec0`* | `void *` | handle (dead copy, no callers) |

Every fetch **re-checks the type internally and returns a zero value on mismatch** — none of them
raise a Lua error. This is the wrapper's only real editorial decision over stock Lua: it converts
`luaL_check*`'s throw-on-bad-argument into silent zero. (`FUN_006f7990` calls `luaL_checkinteger`,
which *can* throw, but only after `lua_isnumber` has already guaranteed it will not.)

### Pushes

| Primitive | Lowers to | Returns | Lua type moved |
|---|---|---|---|
| `FUN_006f7010` | `lua_pushnil(L)` | void | nil |
| `FUN_006f7040` | `lua_pushnumber(L,(float)n)` | void | number (int→float cast) |
| `FUN_006f7060` | `lua_pushnumber(L,v)` | void | number (already float) |
| `FUN_006f6f90` | `lua_pushnumber(L,(float)n)` | **`1`** | number |
| `FUN_006f6fb0` | `lua_pushnumber(L,v)` | **`1`** | number |

`FUN_006f6f90`/`FUN_006f6fb0` are the same push as `FUN_006f7040`/`FUN_006f7060` but return `1` —
they are `return state->PushNumber(x);` convenience forms for a one-result binding.

### Stack management

| Primitive | Lowers to | Meaning |
|---|---|---|
| `FUN_006f6970` | `lua_gettop(L)` | **argument count** in a binding |
| `FUN_006f6980` | `lua_settop(L,n)` | set/truncate stack |
| `FUN_006f7290` | `lua_settop(L,-2)` | `lua_pop(L,1)` |

**Confidence: confirmed** for every row (each wrapper body and each target body was read in full).
The `FUN_006f7990` → `luaL_checkinteger` identification is **inferred** at the name level
(`0x00402c50`'s `tag_error("number")` path is diagnostic) though its behaviour is confirmed.

### Not a type tag

The `*(int *)(iVar2 + 0xb8) == 9` pattern (e.g. `FUN_00714090 @0x00714090`) compares a field on an
**engine object**, reached only *after* the value has left Lua:

```c
uVar3 = FUN_006f6ec0(1);                          // lua_touserdata -> handle
piVar4 = (int *)FUN_00498440(uVar3);              // handle -> object
iVar2 = (**(code **)(*piVar4 + 0x1c))();          // virtual accessor
iVar2 = *(int *)(iVar2 + 0x140);                  // sub-object
if (*(int *)(iVar2 + 0xb8) == 9) { ... }          // engine enum, NOT a Lua tag
```

Lua tags in this build never exceed `8`, are always read at `TValue + 4` off a stack slot, and are
always compared inside the `0x004xxxxx` core or the wrapper layer — never at `+0xb8` off an engine
object. `9` here is an engine-side state/mode enum whose meaning belongs to the relevant subsystem
doc under [`docs/symbol_map/`](../symbol_map/README.md), not to the ABI.

**Confidence: confirmed** that it is not a Lua type tag. Its actual meaning: **open**.

---

## 6. The return path

There is no Pandemic return abstraction. **Bindings are stock `lua_CFunction`s and report arity by
returning the result count in `EAX`.** Ghidra frequently types them `void` because many bindings
return `0` on all paths and the compiler leaves `EAX` visibly dead.

The proof is `FUN_00710750 @0x00710750`, which has both shapes in one body:

```c
undefined4 FUN_00710750(undefined4 param_1)
{
  ...
  cVar1 = FUN_006f71a0(1);
  if ((cVar1 == '\0') || (cVar1 = FUN_006f71a0(2), cVar1 == '\0')) {
    return 0;                      // <-- bad args: 0 results
  }
  ...
  FUN_006f7060(piStack_34);        // lua_pushnumber(L, dist)
  return 1;                        // <-- exactly 1 result
}
```

Push-then-`return <count>`, early-out-with-`return 0`. That is the stock protocol, unmodified.
Consistent with this, `FUN_006f6f90`/`FUN_006f6fb0` exist precisely to collapse the common
one-result tail into `return state->PushNumber(x);`.

On the **inbound** side, arity is read with `FUN_006f6970` = `lua_gettop(L)`, and bindings use it
for overload dispatch — see worked example 3.

No `lua_error`/`luaL_error` call was found in any binding examined; bad arguments produce a silent
`return 0` (zero results, which Lua sees as `nil`). Callers in the Lua corpus therefore cannot
distinguish "failed" from "returned nothing".

**Confidence: confirmed** for the return-count protocol and `lua_gettop`-as-argc. **Inferred** that
*no* binding raises a Lua error — argued from a sample of bindings, not from an exhaustive sweep of
all 898.

---

## 7. Recipe: reading any binding's signature from its decomp body

Copy-pasteable procedure. Given a `FUN_` that appears in the binding address range and opens with
the `DAT_0142d324` / `FUN_006f8470` prologue:

1. **Confirm it is a binding.** The prologue is the tell:
   `if (DAT_0142d324 == 0) { ... FUN_00db39e0(0x15c90,0) ... } FUN_006f8470(param_1);`
   Its `param_1` is the `lua_State *`. Ignore the singleton block entirely — it is lazy-init noise
   emitted into every binding.
2. **Find the name.** Scan for a `"C:\\EALA-BUILD-SAB1\\...\\Script\\...\\*.cpp"` string assignment;
   the next string literal is the Lua-visible binding name and the following integer is the line
   number. If absent, the binding is unnamed in the decomp — fall back to the registration table.
3. **Read arguments in order.** Walk the `FUN_006f7*` type checks top-to-bottom. Each
   `FUN_006f71a0(k)` / `FUN_006f7120(k)` / `FUN_006f7140(k)` / `FUN_006f7160(k)` / `FUN_006f71c0(k)`
   declares that **argument `k` is** handle / boolean / number / string / table respectively
   (§5 table). The literal `k` is the 1-based Lua argument position — read it straight off.
4. **Confirm with the matching fetch.** Checks and fetches come in pairs; the fetch confirms the
   type and gives you the C type:
   `FUN_006f71a0`→`FUN_006f6ec0` (`void*`), `FUN_006f7120`→`FUN_006f6e60` (`bool`),
   `FUN_006f7140`→`FUN_006f7950` (`float`) or `FUN_006f7990` (`int`),
   `FUN_006f7160`→`FUN_006f7a80` (`const char*`).
5. **Get the arity.** If `FUN_006f6970()` appears and is compared to constants, the binding is
   **variadic** and each constant is an accepted argument count. Otherwise arity is the highest `k`
   seen in step 3, and any argument guarded by a check that can fall through to a `return` is
   **mandatory**.
6. **Get the results.** Count `FUN_006f7040`/`FUN_006f7060`/`FUN_006f7010`/`FUN_006f6f90`/`FUN_006f6fb0`
   pushes on the success path and read the terminal `return <count>`. `return 0` with no pushes =
   returns nothing.
7. **Handles are lightuserdata.** `FUN_006f6ec0(k)` yields an opaque handle; it is resolved to an
   object by `FUN_004436f0` (under `DAT_0143db28`) or `FUN_00498440`. The object model is out of
   scope here.

---

## 8. Worked examples

### Example 1 — `ActorRagdoll` (`FUN_00714230 @0x00714230`), named, 1 arg, 0 results

```c
FUN_006f8470(param_1);                 // step 1: it's a binding, param_1 = L
cVar1 = FUN_006f71a0(1);               // step 3: arg 1 is a HANDLE (lightuserdata)
if (cVar1 != '\0') {
  uStack_10 = FUN_006f6ec0(1);         // step 4: fetch it as void*
  ...
  pcStack_c = "...\\Script\\Interface\\Actor.cpp";
  pcStack_8 = "ActorRagdoll";          // step 2: the name
  uStack_4 = 0xcd5;
}
return;                                // step 6: no pushes -> 0 results
```

**Signature: `ActorRagdoll(handle) -> ()`.** Source: `Script\Interface\Actor.cpp:3285`.

### Example 2 — `FUN_00714090 @0x00714090`, unnamed, 2 args of different types

```c
FUN_006f8470(param_1);
cVar1 = FUN_006f71a0(1);                        // arg 1: HANDLE
if ((cVar1 != '\0') && (cVar1 = FUN_006f7120(2), cVar1 != '\0')) {   // arg 2: BOOLEAN
  uVar3 = FUN_006f6ec0(1);                      // fetch handle
  piVar4 = (int *)FUN_00498440(uVar3);          // handle -> object
  ...
  cVar1 = FUN_006f6e60(2);                      // fetch boolean
  if (cVar1 == '\0') { if (*(int *)(iVar2 + 0xb8) == 9) FUN_008d3580(0,0); }
  else if ((*(int *)(iVar2 + 0xb8) != 9) && (*(int *)(iVar2 + 0xbc) != 9)) FUN_008d3580(9,0);
}
```

Note the idiom: **both checks are ANDed before either fetch**. The `&&` short-circuit means arg 2's
type is validated before arg 1 is even converted — so a call with a good handle and a bad flag does
nothing at all rather than half-executing.

**Signature: `<unnamed>(handle, boolean) -> ()`** — a toggle that flips an engine mode enum
(`+0xb8`) between `0`/`9`. No assertion string, so the name must come from the registration table.

### Example 3 — `FUN_00743cf0 @0x00743cf0`, variadic via `lua_gettop`

```c
FUN_006f8470(param_1);
iVar2 = FUN_006f6970();                          // step 5: argc = lua_gettop(L)
if ((iVar2 != 0) && (cVar1 = FUN_006f7160(1), cVar1 != '\0')) {   // argc>=1 and arg 1 is a STRING
  ...
  uVar4 = FUN_006f7a80(1);                       // fetch const char*
  FUN_00db7e10(uVar4,1);                         // copy it out of Lua's ownership
  iVar2 = FUN_006f6970();
  if (iVar2 == 1) {                              // 1-arg overload
    if (piVar3 == (int *)0x0) { FUN_00911400(uStack_8); return; }
    FUN_00784860(&uStack_8); return;
  }
  cVar1 = FUN_006f7160(2);                       // 2-arg overload: arg 2 is a STRING
  if (cVar1 != '\0') {
    uVar4 = FUN_006f7a80(2);
    FUN_00db7e10(uVar4,1);
    ...
  }
}
return;                                          // 0 results on every path
```

**Signature: `<unnamed>(string [, string]) -> ()`** — a genuine 1-or-2-argument overload, dispatched
on `lua_gettop`. This is the canonical shape for optional trailing arguments: **there is no
"default argument" mechanism**; the binding branches on `argc` and each branch calls a different
engine function (`FUN_00911400` vs `FUN_00911440`).

The `FUN_00db7e10(uVar4, 1)` immediately after each `FUN_006f7a80` is the second half of the string
idiom: `lua_tolstring` returns a pointer **into a live Lua `TString`**, so the engine copies it out
before any call that could trigger GC. Expect this pairing after every `FUN_006f7a80`.

---

## Open questions

1. **`ECX` dataflow is inferred, not proven.** That `FUN_006f8470`'s `this` is `DAT_0142d324`, and
   that its `EAX` result becomes `this` for the following accessors, is the only reading consistent
   with the evidence — but it was derived from Ghidra's `__thiscall` recovery plus the singleton
   prologue, not from raw disassembly. A single look at `0x00714230`'s bytes in a disassembler
   would settle it. Nothing else in this doc depends on it.
2. **The wrapper class has no name.** The RTTI sets
   ([`data/rtti_classes_all.txt`](../../data/rtti_classes_all.txt),
   [`data/ws_engine_classes.txt`](../../data/ws_engine_classes.txt)) were not cross-referenced
   against `DAT_0142d324`'s vtable. The `0x15c90`-byte manager and the `+0x124` wrapper array
   should be nameable from RTTI.
3. **Only one wrapper slot exists** (`while (iVar1 < 1)`). Whether that is a build-time constant or
   a coincidence of a one-VM game is unresolved — it bears on whether coroutines/threads ever reach
   a binding with a different `lua_State *`. `LUA_TTHREAD` (tag 8) is checked nowhere in the wrapper
   layer, which is suggestive but not conclusive.
4. **`FUN_006f6e80` is a dead byte-identical twin of `FUN_006f6ec0`** with zero callers. Probably a
   COMDAT that escaped folding; possibly a distinct accessor in source that happened to compile
   identically. Harmless either way.
5. **`0x00403bb0`'s exact stock identity** within the `lua_getfield`/`luaV_gettable` family.
6. **The meaning of the engine enum at object `+0xb8`** (value `9`). Belongs to a subsystem doc.
7. **`FUN_006f6f10 @0x006f6f10` is unexplained and probably not part of this ABI.** It is
   TLS-keyed (`TlsGetValue(DAT_0148e2c0)`), writes 8-byte pairs into a **`0x40`-entry** array at
   `param_1 + 0x204`, and touches no `lua_State`. It looks like an engine event/callback argument
   buffer that merely lives nearby. Flagged so a later reader does not mistake it for a Lua
   marshalling primitive.
8. **"No binding raises a Lua error"** is generalised from a handful of bodies. A sweep for
   `luaL_error`/`lua_error` call sites across the binding range would confirm or refute it.
9. **The `float` `lua_Number` consequence is untested.** Whether any binding actually pushes an
   integer large enough to lose precision (>2^24) through `FUN_006f7040`'s `(float)` cast is not
   established. Worth a targeted check on ID-returning bindings.

## Confidence summary

| Claim | Tier |
|---|---|
| Bindings are stock Lua 5.1 `lua_CFunction`s; arity is the `EAX` return | **confirmed** |
| The engine is unmodified Lua 5.1 (not 5.0, not a custom VM) | **confirmed** — `LUA_ENVIRONINDEX == -10001` |
| `lua_Number` is `float`; `TValue` is 8 bytes | **confirmed** — four independent proofs |
| The `n` in every primitive is a plain 1-based Lua stack index; negatives work | **confirmed** |
| Each primitive maps to one stock Lua API call (§5 tables) | **confirmed** — all bodies read |
| `FUN_006f71a0` = combined presence + `LUA_TLIGHTUSERDATA` check | **confirmed** |
| Handles cross the seam as lightuserdata (tag 2) | **confirmed** |
| Fetches return zero on type mismatch rather than throwing | **confirmed** |
| The wrapper is a naming shim, not an abstraction (adds no policy) | **confirmed** |
| `FUN_006f8470` = `lua_State *` → wrapper lookup at `mgr + 0x124` | **confirmed** (body) |
| `FUN_006f8470`'s `this` is `DAT_0142d324` and its `EAX` threads to later calls | **inferred** |
| `FUN_006f7990` is specifically `luaL_checkinteger` | **inferred** (behaviour confirmed) |
| `0x00403bb0`'s exact stock identity | **open** |
| No binding raises a Lua error | **inferred** (sampled) |
| Meaning of engine enum `+0xb8 == 9` | **open** |

## Sources

All function bodies cited were read from
`C:/Users/Shadow/Desktop/notes-on-the-released-game/output/_ghidra_saboteur/saboteur_all_functions_decomp.txt`
(36,935 functions). Binding names are from
[`data/lua_bindings.txt`](../../data/lua_bindings.txt). No fact in this doc was carried over from
Mercenaries 2 work; every offset and tag was re-derived against this binary.
