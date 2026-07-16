---
name: prototype-symbols-goldmine
description: The 2008-05-20 Xbox360 pre-release prototype ships FULL debug symbols — PDBs + a 119,119-symbol linker map with source .obj per function. The RE force-multiplier for the whole project.
metadata:
  type: reference
---

**★GOLDMINE.** `game-files/The Saboteur (2008-05-20 prototype).7z` (8.4 GB, Xbox 360 pre-release, built
May 20 2008) ships **full debug symbols**. Extracted to `game-files/symbols/` (gitignored — copyrighted):
- **PDBs:** `WildStar_d.pdb` (67 MB, debug), `WildStar_p.pdb` (43 MB), `Saboteur.pdb` (16 MB) — full
  symbols + types/struct layouts (needs a PDB tool: `llvm-pdbutil`, `pdbparse`, or DIA).
- **Linker maps:** `WildStar_d.map` (**119,119 public symbols**), `WildStar_p.map`. Plaintext.
- exes/xex (`WildStar_d.exe`, `Saboteur.xex`, …), prototype `Global.map`/`France.map`.

**Why it's transformative:** the `.map` line format is
`SECT:OFF   ?Mangled@Class@@sig   ADDR f i <SourceFile>.obj`. So each symbol maps to
**(real C++ name) + (360 address) + its source `.obj`** — a source-file attribution for the WHOLE engine
(**2,275 translation units**), not just the ~199 assert-string funcs we had in the PC decomp.

**Named systems already found (real names for our `FUN_*`):**
- **`PblCRC`** = the hash (our "pandemic_hash"). `GetCRC`, and **`Invert()` → `const char*`** = the
  hash→string reverse table (source of the resource/conduit names conduit-B was reversing). See
  [[operating-model-and-modding]] key-derivation.
- **`WSConduit`** = the resource/object resolver (typed `GetCar/GetHuman/GetDamageable/…` per WS type) —
  the `FUN_009ef620` resolve-by-name layer.
- `IndexEntry` / `PblHashTable<PblCRC>` = the megapack/hashtable machinery. `WSPackFile.obj`,
  `WSLoaderXenon.obj`, `WSStreamBlockJob.obj` = pack/loader/streaming. `hkBinaryPackfileReader/Writer.obj`
  = Havok pack read/WRITE (HKX authoring reference).
- **Mercs2 damage/explosion wall NAMED:** `WSDamageable::ApplyDamage(const WSDamageDesc&)`,
  `WSExplosion::Update(float)`/`::UpdateDeferred`, `WSDestructable::UpdatePhysicsObjects/::UpdateSynched`.
  The solver SecuROM-locked in Mercs2 — full signatures here, clean code in the PC decomp.

**Caveat:** it's a DIFFERENT platform (PPC/Xenon, big-endian) and an EARLIER build — 360 addresses ≠ PC,
some code differs. Use it as a **naming oracle** (name + source-file + signature), then verify each
against the PC decomp. Don't assume a 2008 struct offset holds in the 2009 retail PC build.

**✅ DONE — PC symbol map built** (`data/symbol_map/pc_symbol_map.tsv`, 6d71a44): **1,414 PC function
names** from the 360 prototype via double-blind (RTTI vtable-slot alignment gated to equal-length classes
+ assert anchors). 824 double-blind-confirmed (`source=both`), 578 single-source, 12 conflict-reconciled.
Validated: 98% vs assert catalog, 118/118 pure-virtual structural test. **Excluded** the drifted
`WSConduit`/game-object hierarchy (vtables grew 2008→2009 — class ID known, method slots NOT). Names
transfer, addresses do NOT. Methodology in `tools/xsym/`; see data/symbol_map/README.md.

**Next force-multipliers:** (1) a shift-aware rescue of the drifted `WSConduit`/`WSHuman`/`WSVehicle`/
`WSWeapon` families (align via anchors, not naive slot). (2) parse the PDBs for struct FIELD names.
(3) the full [[vmx128-xenon-decomp]] (decompile the 360 .xex → named logic, richer than the .map).
Also: prototype `Global.map`/`GameTemplates`/`.lua`/`.hkx` for format cross-checks.
