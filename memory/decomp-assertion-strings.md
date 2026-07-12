---
name: decomp-assertion-strings
description: The Saboteur decomp retains EA-LA build __FILE__/__FUNCTION__ assertion strings that pin FUN_ VAs to real Class::Method names — the primary symbol-map anchor, ~199 methods / 98 files
metadata:
  type: reference
---

**★The symbol-map backbone.** The retail `Saboteur.exe` decomp keeps the original EA Los Angeles
build's assertion strings: each `assert`-carrying function body contains its own source path
**immediately followed by** its function signature, e.g.:

```
"C:\EALA-BUILD-SAB1\p4\Ref_Sab_POV\wildstar\POV\code\WildStar\Ai\Helpers\WSAIPanicker.cpp"
"WSAIPanicker::Update"
```

Because both strings sit **inside the very function they name**, each pins a concrete `FUN_xxxxxxxx`
VA → real `Class::Method`. Grep the decomp for `WS[A-Za-z0-9_]+\.cpp` (path) and
`WS[A-Za-z0-9_]+::[A-Za-z0-9_]+` (signature) and correlate by function body.

**Coverage ceiling (calibration — don't oversell):** only **199 distinct `WSClass::Method` strings
across 98 `.cpp` files** exist in the whole decomp. So assertion strings hard-name ~199 methods; any
symbol-map entry beyond that is **inferred** (caller/callee chains from the in-file `callers=[..]`
lists, string proximity, or behavior match vs the Lua corpus) and should be marked as a proposal, not
a hard ID. Build root string also confirms provenance: EA-LA, Perforce (`p4`), codename WildStar/POV.

**This was the surprise that reframed the effort:** binding names like `CreateExplosion` are NOT
inline strings (they're in RTTI glue — see [[lua-luap-packs]] caveat), but the *assertion* strings are,
and they cover the assert-heavy AI/vehicle/physics/anim code richly. The still-being-written
`tools/rtti_symbol_map.py` (RTTI vtable→VA) is complementary: it will name classes whose methods carry
no assertions, promoting inferred labels to hard IDs.

Used by the 15-subsystem symbol map: `docs/symbol_map/` (286 fns pinned, 264 verifier-confirmed-exist).
See [[symbol-map-methodology]], [[clean-binary-and-symbols]].
