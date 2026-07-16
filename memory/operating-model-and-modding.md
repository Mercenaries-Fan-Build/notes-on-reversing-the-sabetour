---
name: operating-model-and-modding
description: How to run this project — double-blind RE studies, Rust tooling, agent-groups for assembly analysis, x32dbg deferred. Plus the modding/write-path program (the community's universal gap).
metadata:
  type: project
---

**★Operating model (user directive, 2026-07-12):**
- **Novel reverse engineering → double-blind studies.** ≥2 independent investigators (isolated
  worktrees, blind to each other) derive the same thing, then a third agent adjudicates the divergences
  against the decomp/real bytes. Proven on Havok 6.5, skeleton, mesh, ANIM binding. Use a hard oracle
  (round-trip byte-equality, cursor-consumes-file, unit-norm, count matches).
- **New durable tooling → Rust** (std-only where feasible; `flate2` for zlib). Small binaries under
  `tools/`, validated by round-trip. See [[symbol-map-methodology]], [[havok65-spline-decode]].
- **Assembly analysis → dispatch GROUPS of agents** to review/categorize/analyze `FUN_*` bodies and
  document ACTUAL engine behavior (deepen docs/symbol_map). Same pattern that produced the 15-subsystem
  map; scalable to on-demand deep dives.
- **x32dbg live debugging → deferred.** Reserve for later in-depth deep-dives (dynamic capture of
  samplers/solvers). Static decomp is the oracle for now.
- Work streams are **parallel**, not sequential — don't force a single priority.

**★Modding / write-path program (the community's universal gap).** Contact: the **Global Mod** author
(the ~only Saboteur mod). The community has extract/read (SabTool, SaboteurToolset, FileConvTool,
LuapExplorer) but NO write/repack. Undocumented even on the saboteur-team wiki: global.map, GameTemplates,
megapack WRITE, and the patch-override.

Our unique assets (from the clean decomp):
- **Patch-override layer** (`FUN_00e34f70`): engine auto-mounts `patchdynamic0.megapack` (prio 0x18704),
  `patchpalettes0.megapack` (0x186fa), `patchmega/patchmega0/patchmega%d.megapack` at ~1000× base
  priority; by-hash lookup, highest wins. ⇒ OVERRIDE existing assets with a small patch pack — NO base
  rebuild, NO global.map edit. Not documented anywhere in the community. See [[archive-and-patch-megapack]].
- **global.map = MAP6** (magic `0x4D415036`, loader `FUN_009f3370`; reads u32 magic via `FUN_0049ee70`).
  Loaded at boot beside `GameTemplates.wsd` and `France.map` (`FUN_009f75f0`). Files: `DLC/01/Global.map`,
  `DLC/01/FRANCE.map` (base copies inside packs).
- **GameTemplates.wsd** = magic `"AULB"` → u32 count → records `{i32 size, 2×i32 unk, len+name, len+type,
  count + (u32 hash BE, i32 dataSize, data)…}` (from Daniel-McCarthy/Saboteur-GameTemplates-Helper source;
  that tool is read-only). This is the disguise/vehicle/object definition file — what the user edits.
- Validated **readers to invert into writers**: sab_mesh/sab_skeleton (MESH), sges, DTEX.

**Write-path streams — wave 1 DONE (double-blind + adjudicated, 2026-07):**
- ✅ **megapack WRITE** → `tools/sab_pack` (49ee123). Format from `FUN_00e428c0` (self-verified): `"00PM"`
  + u32 count + count×20B index `{crc,index,size,u64 offset}` + a **count×8B {crc,index} MIRROR table our
  readers missed** (a writer MUST emit it) + 0x800-aligned verbatim SBLA blobs. `crc` = bsearch key =
  `pandemic_hash(external resource-DB PATH)`, NOT the asset — so repack/override COPY the base entry's
  crc/index (proved: identical bytes, different keys). Byte-identical round-trips ≤3.4 MB. `sab_pack patch`
  emits a `patchdynamic0.megapack` override (mounts prio 0x18704). ⚠️ in-engine load INFERRED, not live-tested.
- ✅ **global.map / MAP6** → `tools/sab_map6` (52b8ab8). Magic `0x4D415036`, loader `FUN_009f3370`. Header
  (16B) + records `{u32 name_hash=pandemic_hash(name), u16 len, name, vec3, vec3 (transform), u16, u16,
  u32 sub_count, sub_count×{u32 asset_hash,u16,u16}, 56B trailer(trailer[3]==sub_count)}`. Consumes
  Global.map exactly (356/356). Add an entry = append + bump record_count.

**Wave 2 (next parallel streams):** (3) **DTEX** read/write for reskins; (4) **GameTemplates.wsd** (`AULB`)
WRITE; (5) the **conduit-path→crc/index** pipeline (the one thing blocking brand-NEW assets — keys hash
external paths absent from the pack; likely in `loosefiles_BinPC.pack`/resource DB). **Live validation
(x32dbg, later):** drop a `patchdynamic0.megapack`, breakpoint the mount (`FUN_00e34f70`) + bsearch
(`FUN_00e42740`) to confirm the override actually loads. **RE goldmine:** the 2008-05-20 pre-release build
(often less stripped). See [[community-contribution-plan]].
