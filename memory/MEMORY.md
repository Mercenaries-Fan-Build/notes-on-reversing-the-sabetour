# Memory Index — Reversing The Saboteur

One line per durable note. Detail lives in the note file and in `docs/`. Keep lines short.

## Orientation
- [Read lineage_and_divergence first](../docs/lineage_and_divergence.md) — ★shared-vs-different vs Mercs 2; never copy a Mercs 2 offset/struct/Havok detail without re-deriving. Identical: hash, sges, LuaQ 5.1, f16, Pebble. Different: everything binary-layout.
- [clean-binary-and-symbols](clean-binary-and-symbols.md) — retail GOG Saboteur.exe is UNPACKED (no SecuROM); 2765 RTTI + 898 Lua bindings + 36,935-fn decomp = the oracle. docs/binary_recon.md.

## Formats
- [lua-luap-packs](lua-luap-packs.md) — ★START HERE: .luap is flat/uncompressed/hash-keyed (layout from loader FUN_00706670), bypasses the megapack stack; Lua strings feed the name dict megapacks need. LuaMissions.luap + Scripts\Modules = new leads. docs/formats/lua_scripts.md.
- [archive-and-patch-megapack](archive-and-patch-megapack.md) — MP00 megapack→SBLA→MSHA→flat MESH; override = built-in patchmega0/patchdynamic0/patchpalettes0.megapack (hash wins, no injection). docs/formats/archive_and_models.md.
- [audio-1kcp-wwise](audio-1kcp-wwise.md) — Wwise 1KCP .pck; tools/saboteur_audio extracted all 80,872 VO WAV. GOTCHA: vgmstream batch ≤200. docs/formats/audio_1kcp.md.
- [animation-havok65-gap](animation-havok65-gap.md) — ★Havok 6.5 (NOT 5.5); AP0L pack; community can't decode hkx → our flagship target. docs/formats/animation_havok65.md.
- [animation-100pct-spline](animation-100pct-spline.md) — ★Animations.pack is 100% hkaSplineCompressedAnimation (9709×; wavelet/delta/interleaved=0). One KNOWN format, not the blocked Mercs2 wavelet.
- [havok65-spline-decode](havok65-spline-decode.md) — ★FLAGSHIP CRACKED: double-blind 2-investigator + adjudicator decoded all clips. Authoritative decoder = tools/sab_havok65 (2214/2214 clean). THREECOMP40 + time model adjudicated from Saboteur.exe disasm.

## Symbol map
- [decomp-assertion-strings](decomp-assertion-strings.md) — ★backbone: decomp keeps EA-LA build __FILE__/__FUNCTION__ strings pinning FUN_ VAs to Class::Method. Hard ceiling: 199 methods / 98 .cpp files; beyond that = inferred. docs/symbol_map/.
- [symbol-map results](../docs/symbol_map/README.md) — 15 subsystems documented+verified; 286 fns pinned, 264 confirmed-exist. Vehicle&Train verify was re-run after a workflow error.

## Program
- [operating-model-and-modding](operating-model-and-modding.md) — ★HOW WE WORK: double-blind RE studies, Rust tooling, agent-groups for assembly analysis, x32dbg deferred. + the modding/write-path program (patch-override, global.map=MAP6, GameTemplates=AULB; community's universal gap). Contact = Global Mod author.
- [symbol-map-methodology](symbol-map-methodology.md) — ★USER'S GOAL + proven Mercs2 workflow: categorize decomp → parallel agents document → gap/seam passes. Rich anchors (RTTI vtables, 898 bindings, 116k-line Lua corpus, in-file call graph). Scope fan-out with user first.
- [community-contribution-plan](community-contribution-plan.md) — where our RE amplifies SaboteurToolset/SabTool (extract-only): anim decode, audio (have it), symbol map, repack. docs/community_tooling.md.
