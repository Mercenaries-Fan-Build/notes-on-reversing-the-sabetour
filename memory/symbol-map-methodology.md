---
name: symbol-map-methodology
description: The proven Mercs2 workflow for turning a raw decomp into a documented symbol map — categorize assembly, fan out parallel agents to document, then gap/seam passes. Apply to the Saboteur decomp.
metadata:
  type: project
---

**Goal chosen by the user (2026-07-12):** make the Saboteur engine legible — publish a symbol
map / named function catalog from the 36,935-fn decomp, not (yet) chase Havok 6.5. This is exactly
the "source map" the user said is OK to expose.

**The method that worked on Mercs2 base game (user's own words):**
1. **Categorize** the decompiled assembly into buckets first (by subsystem) — don't fan out blind.
2. **Fan out parallel agents**, each owning a bucket, to *identify and document* their functions.
3. **Additional passes** to find **seams** (bucket boundaries / cross-refs) and **fill gaps** in
   understanding or in **decompilation corruption** (Ghidra mis-recovery).

**Why:** apply to a 54 MB, ~36.9k-fn corpus. Do NOT try to document it in one pass or one agent.

**How to apply — anchors available on THIS binary (unusually rich):**
- **RTTI → vtable → VA**: 2,765 `.?AV` class descriptors; the vtable sits at a fixed `.rdata` offset
  before each `type_info`. Walking it auto-names member fns by class → the backbone of the categories.
  (823 `WS*` engine classes already bucketed by subsystem in `data/ws_engine_classes.txt`.)
- **898 Lua bindings** (`data/lua_bindings.txt`): names live in `LuaGlueFunctor` RTTI, NOT as inline
  strings — name→VA is its own correlation pass (glue vtable → thunk → bound fn).
- **The decompiled Lua corpus** (116,681 lines, `docs/saboteur-luacd/src`): the API namespaces the
  scripts call — `Util` 4675, `Actor` 1432, `Object` 1334, `Combat` 1024, `Nav`, `Cin`, `Vehicle`,
  `Sound`, `Trigger`, `Render`, `Suspicion`, `HUD`, … — are the binding domains. This is the Rosetta
  Stone tying script-facing names to the binding surface to the C++ bodies.
- **Call graph is in-file**: every `==== FUN_ … callers=[…]` header lists callers → cluster for free.
- **String anchors**: 5,211 bodies carry literals; Ghidra renders as `s_Name_00xxxxxx` (only ~838
  inlined — most are `DAT_` refs, so a strings-listing cross-ref helps).

**Caveat to remember:** "CreateExplosion" etc. are NOT greppable as inline strings in the decomp — the
Lua binding names are in RTTI. Don't expect string-search to find the binding bodies.

See [[clean-binary-and-symbols]], [[lua-luap-packs]]. docs/community_tooling.md #3 (symbol map).

**Before a big fan-out:** it's billable and large — scope agent count / bucket granularity with the
user first (parallel Agent tool, or a Workflow only if the user opts in).
