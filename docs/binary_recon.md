# The Saboteur (2009) — Binary Recon from the GOG Install

First-pass reconnaissance of the local GOG (DRM-free) install at `C:\GOG Games\The Saboteur`.
Pairs with [lineage_and_divergence.md](lineage_and_divergence.md) (format genealogy vs Mercs 2).
Engine = Pandemic "WildStar" (confirmed from build paths), sibling of Mercs 2's engine on the
shared **Pebble** core (`Pbl*`/`Pcl*`). *(Corrected 2026-07-24: `Odin*` is the **renderer**, not part
of the shared core — all 38 `Odin*` RTTI classes are graphics-layer (`OdinShader`, `OdinDrawlist`,
`OdinBucket`, `OdinMesh`, `OdinCloth*`, …), and there is no evidence the renderer is shared with
Mercs 2.)*

## Headline: the binary is CLEAN and UNPACKED

`Saboteur.exe` — 14.8 MB, 32-bit (Machine 0x14C), TimeDateStamp **2009-12-11**, LARGE_ADDRESS_AWARE set.

| Section | VA | VSize | Notes |
|---|---|---|---|
| `.text` | 0x001000 | 0xB70000 (~11.9 MB) | code |
| `.rdata` | 0xB71000 | 0x1A0000 | consts, RTTI, vtables |
| `.data` | 0xD11000 | 0x4E5000 | |
| `.rsrc` | 0x11F6000 | 0x6000 | |
| `.secu` | 0x11FC000 | 0x40A40 | SecuROM residue |

- **`.text` entropy averages 6.49 with no 64 KiB window above 6.84** — plain, unencrypted x86, nowhere near the >7.5 that packing or encryption produces. No packed/encrypted regions. *(Corrected 2026-07-24: this previously claimed "a flat 6.2–6.7". Measured over the 11,992,591-byte raw `.text`: overall 6.4943; 64 KiB windows n=182, min 5.243 / max 6.839 / mean 6.307, **22.5% fall outside 6.2–6.7**; 4 KiB windows n=2927, min 2.955 / max 6.754 / mean 6.016, 60% outside. The conclusion holds; the "flat" band did not, and window size must be stated.)*
- **Entry point (RVA 0xA4C4D4) is in normal `.text`, NOT in `.secu`**, and the image needs no unwrap step. *(Corrected 2026-07-24: the stronger claim that "`.secu` is dead weight, not an execution wrapper" is **not established**. `.secu` is 91.5% non-zero (243,527 of 266,240 bytes), carries `CODE|EXEC|READ|WRITE` characteristics, and **928 functions inside its VA range are present in the decomp** — with 649 non-`.secu` functions listing a `.secu` caller, and 3 `.secu` functions called from `.text`. Even `pandemic_hash` (`FUN_00dc1e20`) has two `.secu` callers. Whether any of it executes at runtime has not been tested; `tools/sab_asi` could settle it. What is certain: nothing is hidden — `.secu` disassembles normally, which is why [`sab-engine-lua-seam/01`](sab-engine-lua-seam/01-registration-and-dispatch.md) was wrong to call the registry ctor unreadable.)*
- **This is the opposite situation from Mercenaries 2.** Mercs 2 required a 743-site devirtualization effort and still leaves the damage/explosion solver behind a SecuROM/VM wall. Here the whole engine is directly disassemblable with no unpacking, no live-dump requirement, no x32dbg dependency.

## RTTI symbol map — 2,765 class names in the clear

`.rdata` carries **2,765 unique `.?AV...@@` RTTI type descriptors** — an effective symbol map for the engine. Dumps: [`data/rtti_classes_all.txt`](../data/rtti_classes_all.txt), [`data/ws_engine_classes.txt`](../data/ws_engine_classes.txt).

- **823 `WS*` engine classes** (WildStar). Subsystem census (count of distinct classes):
  AI 143, Manager 77, Human 62, Vehicle 32, Physics 27, Mission/Task ~30, Camera 21,
  Light 17, Particle 17, Damage 16, Train 16, Sound 13, Water 11, Fx 11, Perk 10,
  Weapon 8, Render 7, Explosion 4, Grapple/Climb 2 each.
- Middleware present (named, unobfuscated): **Havok 6.5** (`hkaSplineCompressedAnimation`, `hkaWaveletCompressedAnimation`, `hkaDeltaCompressedAnimation`, `hkaInterleavedUncompressedAnimation`) — ⚠️ *corrected 2026-07-24: **not** "the same anim codecs as Mercs 2". The names resemble Mercs 2's 5.5 codecs but the structs and quantization differ (see [`lineage_and_divergence.md`](lineage_and_divergence.md), which is the authority per `AGENTS.md`), and the retail corpus is **100% spline-compressed** (2,214/2,214) — a codec Mercs 2 does not use at all*, **Scaleform GFx**, **FaceFX**, **Pebble/Pcl** core (`PclKeyboard`, `PblSingleton`, `PblTree`, `PblTask` — the Mercs 1 lineage core library).
- **Boot/frame task graph is legible from `WS*Task`/`WS*Context` names**: Bootup→Legal→PermLoad→InitLoad→LoadGlobal→GameSetup, then the in-game task ring: Game, Rendering, SceneManagement, Physics, Sound, HUD, Streaming, WillToFight, AIPathfinder. Contexts: Application / Bootup / Loading / Ingame / MiniBoot.

## Lua binding surface — 898 named engine functions in the clear

The Lua→engine glue is emitted as `LuaGlueFunctor` templates whose RTTI **embeds the bound C++ function name**. Parsed **898 unique bindings** (dump: [`data/lua_bindings.txt`](../data/lua_bindings.txt)). This is the layer that in Mercs 2 was binding-table-only (names but no bodies); here we have names AND directly-disassemblable bodies.

Domain coverage (count of bindings): Vehicle 46, Spawn 28, Mission 25, Damage 14, Disguise 13, Sound 11, Weapon 10, Fire 7, Health 5, Perk 5, Explosion 2 (`CreateExplosion`, `CameraShakeExplosion`), plus Alarm/WillToFight/Wanted/Contraband/Grapple/Climb families. Notable named entry points: `SetHealth`/`GetHealth`/`GetMaxHealth`, `SetDamageState`/`GetDamageState`, `CreateExplosion`, `FireCurrentWeapon`, `ActorSetDisguise`, `UnlockPerk`.

## Lua scripts — plaintext-recoverable

- `LuaScripts.luap` (4.8 MB) — flat pack, **321 entries**, **uncompressed LuaQ 5.1 bytecode** (magic `1B 4C 75 61 51` confirmed at first entry). Debug info intact.
- **321 embedded source paths recovered — one per entry**, all rooted at `D:\projects\WildStar\pov\BinCommon\Scripts\...` — this is Pandemic's build tree and the internal engine codename ("WildStar") in the clear. *(Corrected 2026-07-24 from "323". Five independent measures all give 321: the header count field, the `1B 4C 75 61 51` LuaQ signature count, drive-rooted path strings, `WildStar`-containing strings, and `@`-prefixed Lua debug source fields — with zero non-`.lua` drive-rooted strings. `docs/saboteur-luacd/src/` likewise holds exactly 321 files.)* Rich AI/soldier state-machine scripts (`SoldierState_*`, `MISSION_*`, `NaziTest_*`).
- DLC ships **plaintext `.lua`** (`DLC/01/Scripts/*.lua`) — not even compiled.
- Bytecode is Lua 5.1 → same `unluac`/ChunkSpy path already proven on Mercs 2 and DLC corpora.

## What this unlocks

**For understanding Saboteur** (our toolchain applies directly):
- `pandemic_hash_m2` is byte-identical → hash any Saboteur name, resolve asset hashes.
- `sges` decompressor is byte-identical → megapacks/kiloPacks decompress with existing code.
- SaboteurToolset (PredatorCZ) already documents the mesh/texture/material/anim container formats; our decoders cross-check against it.
- No DRM wall → straight Ghidra/IDA disassembly of any subsystem, keyed by the RTTI names.

**For our Mercenaries 2 reverse-engineering** (Saboteur as a Rosetta Stone):
- The **damage/explosion solver** — the Mercs 2 wall — is here named (`WSDamageable*`, `WSExplosion*`, `WSExplosionApplyImpulseFunction`, `CreateExplosion`) and in clean code. The successor engine's solver is the reference implementation for the one we can't read in Mercs 2.
- The **animation FSM** (SEQC/TRAN/EDGE/BANK) that Mercs 2 hides is exposed here as `WSHumanState*` classes + `AnimText/` plaintext (`MeleeStates`, `MeleeCombos`, `MeleeReactions`).
- 823 named WS classes give a naming oracle for un-named Mercs 2 `FUN_*` bodies where the two engines share a subsystem.

## Follow-on candidates

**✅ Done since this was written:**
- ~~Decompile `LuaScripts.luap` in full (321 scripts) via unluac~~ — done: all 321 are in
  [`docs/saboteur-luacd/src/`](saboteur-luacd/src/) (116,681 lines). *(The old line pointed at
  `docs/mercs2-luacd`, a path from the Mercenaries 2 repo that does not exist here.)*
- ~~Map RTTI vtable pointers → function VAs to auto-name the disassembly~~ — done:
  [`data/symbol_map/pc_vtables.tsv`](../data/symbol_map/pc_vtables.tsv) (2,586 classes / 81,561 slots)
  and [`data/symbol_map/pc_symbol_map.tsv`](../data/symbol_map/pc_symbol_map.tsv) (1,414 named
  functions), via `tools/rtti_symbol_map.py` and the 2008 prototype's PDB/linker map. The Lua side is
  likewise mapped in [`data/lua_registration_map.tsv`](../data/lua_registration_map.tsv) (all 898
  bindings, Lua name + C++ symbol + VAs).

**Still open:**
- Hash the 898 binding names + 823 class names through `pandemic_hash_m2` and diff against Mercs 2 unresolved ASET/registry hashes for shared-name resolution.
- Correlate `WSDamageable`/`WSExplosion` bodies against Mercs 2 `FUN_0051cff0` weapon driver + the un-reversed damage solver.