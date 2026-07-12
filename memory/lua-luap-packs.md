---
name: lua-luap-packs
description: .luap = flat uncompressed hash-keyed Lua pack, format confirmed against retail (321/321); the cheapest entry point into game content and the seed for the name->hash dictionary the megapack reader needs
metadata:
  type: reference
---

**★Start here.** `.luap` is the one big content container that does NOT go through the
megapack→SBLA→MSHA stack — loose in the install root, flat, **uncompressed**. Format derived from
loader `FUN_00706670` @ `0x00706670` and **confirmed byte-for-byte on retail** via `tools/saboteur_lua`
(321/321 chunks valid LuaQ, contiguous, hashes reproduce).

**Layout:** `u32 count` → `count` × descriptor → bytecode blob. Descriptor is **21 bytes PACKED on
disk** — the loader's `count*0x18` alloc is in-memory stride only; reading at 24 desyncs instantly.
Fields: `+0x00` map key (**preimage OPEN** — not the source path under any normalization, not
crc32/adler32) · `+0x04` **`pandemic_hash(basename-no-ext)`** ✅321/321 · `+0x08` **absolute file
offset** (loader slurps the whole file; first chunk at 6745 == `4+321*21`) · `+0x0C` stored size ==
`+0x10` size · `+0x14` **is-module flag** (0/1; all 86 `flag==1` are under `Modules\`).

**★`pandemic_hash` GOTCHA** (`FUN_00dc1e20` @ `0x00dc1e20`): FNV-1a, basis `0x811C9DC5`, per byte
`h = ((c|0x20) ^ h) * 0x1000193`, finalize `**(h ^ 0x2A) * PRIME**` — XOR **then** multiply. Doing
`(h*PRIME) ^ 0x2A` yields plausible garbage and cost an hour. `|0x20` is a raw-byte fold, NOT
`tolower()` (`\` folds to `|`). Verified `hash("ANY") == 0xED057225` → the Mercs 2 lineage claim in
[[read-lineage-and-divergence]] **holds**, now confirmed against the Saboteur binary, not assumed.

**Not shipped:** `LuaMissions.luap` and a `Scripts\Modules` dir are referenced by the loaders but are
**absent from retail** — `Modules\*` ships inside `LuaScripts.luap` (that's what the flag byte marks).
Don't chase them as files; they may be in `loosefiles_BinPC.pack`.

**Why first:** megapack indices are hash-only (no path strings) → extraction yields `0x8f3a21c4.bin`
until you have a name→hash dictionary. Lua bytecode carries asset/mission/template names as string
constants (28,022 harvested) → doing Lua first **feeds that dictionary**, and pairs with the 898 named
bindings (`data/lua_bindings.txt`) to make the 36,935-fn decomp navigable.
See [[archive-and-patch-megapack]], [[clean-binary-and-symbols]]. docs/formats/lua_scripts.md.

**Blocked:** decompiling to source needs `unluac.jar` → **no JRE installed on this machine**.
