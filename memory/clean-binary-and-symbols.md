---
name: clean-binary-and-symbols
description: Retail GOG Saboteur.exe is a clean unpacked binary — no SecuROM wall; 2765 RTTI + 898 Lua bindings + full decomp
metadata:
  type: reference
---

The retail GOG `Saboteur.exe` (14.8 MB, ts 2009-12-11, LAA) is **fully unpacked**: `.text` entropy flat ~6.2–6.7 across all 11.9 MB, entry point in normal `.text`, `.secu` section inert. Directly disassemblable — the entire [[read-lineage-and-divergence]] SecuROM playbook from Mercs 2 is irrelevant here.

**Symbols in the clear:** 2,765 `.?AV@@` RTTI names → 823 `WS*` (WildStar) engine classes + Pebble `Pbl*`/`Pcl*` core; 898 named Lua bindings (from `LuaGlueFunctor` RTTI); 321 uncompressed LuaQ 5.1 scripts in `LuaScripts.luap` (build paths `D:\projects\WildStar\pov\BinCommon\Scripts`). Middleware: D3D9, Havok 6.5, Wwise, Scaleform GFx, FaceFX, Bink.

**Full Ghidra decomp = the oracle:** 36,935 functions, `output/_ghidra_saboteur/saboteur_all_functions_decomp.txt` (54 MB, gitignored, regenerate via tools/ghidra/DecompileSaboteur.java). Because the exe is unpacked, the decomp authoritatively shows how any format is parsed/produced — grep it before speculating.

Reference dumps committed: data/rtti_classes_all.txt, data/ws_engine_classes.txt, data/lua_bindings.txt, data/havok_version_evidence.txt. Full recon: docs/binary_recon.md.
