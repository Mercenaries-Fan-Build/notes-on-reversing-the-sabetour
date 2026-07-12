# The Saboteur (2009) — Binary Recon from the GOG Install

First-pass reconnaissance of the local GOG (DRM-free) install at `C:\GOG Games\The Saboteur`.
Pairs with [lineage_and_divergence.md](lineage_and_divergence.md) (format genealogy vs Mercs 2).
Engine = Pandemic "WildStar" (confirmed from build paths), sibling of Mercs 2's engine on the
shared Pebble/Odin core.

## Headline: the binary is CLEAN and UNPACKED

`Saboteur.exe` — 14.8 MB, 32-bit (Machine 0x14C), TimeDateStamp **2009-12-11**, LARGE_ADDRESS_AWARE set.

| Section | VA | VSize | Notes |
|---|---|---|---|
| `.text` | 0x001000 | 0xB70000 (~11.9 MB) | code |
| `.rdata` | 0xB71000 | 0x1A0000 | consts, RTTI, vtables |
| `.data` | 0xD11000 | 0x4E5000 | |
| `.rsrc` | 0x11F6000 | 0x6000 | |
| `.secu` | 0x11FC000 | 0x40A40 | SecuROM residue |

- **`.text` entropy is a flat 6.2–6.7 across the entire 11.9 MB** — plain, unencrypted x86. No packed/encrypted regions.
- **Entry point (RVA 0xA4C4D4) is in normal `.text`, NOT in `.secu`.** The GOG build's SecuROM is inert; `.secu` is dead weight, not an execution wrapper.
- **This is the opposite situation from Mercenaries 2.** Mercs 2 required a 743-site devirtualization effort and still leaves the damage/explosion solver behind a SecuROM/VM wall. Here the whole engine is directly disassemblable with no unpacking, no live-dump requirement, no x32dbg dependency.

## RTTI symbol map — 2,765 class names in the clear

`.rdata` carries **2,765 unique `.?AV...@@` RTTI type descriptors** — an effective symbol map for the engine. Dumps: [`data/rtti_classes_all.txt`](../data/rtti_classes_all.txt), [`data/ws_engine_classes.txt`](../data/ws_engine_classes.txt).

- **823 `WS*` engine classes** (WildStar). Subsystem census (count of distinct classes):
  AI 143, Manager 77, Human 62, Vehicle 32, Physics 27, Mission/Task ~30, Camera 21,
  Light 17, Particle 17, Damage 16, Train 16, Sound 13, Water 11, Fx 11, Perk 10,
  Weapon 8, Render 7, Explosion 4, Grapple/Climb 2 each.
- Middleware present (named, unobfuscated): **Havok** (hkaWavelet/hkaDelta/hkaInterleaved — same anim codecs as Mercs 2), **Scaleform GFx**, **FaceFX**, **Pebble/Pcl** core (`PclKeyboard`, `PblSingleton`, `PblTree`, `PblTask` — the Mercs 1 lineage core library).
- **Boot/frame task graph is legible from `WS*Task`/`WS*Context` names**: Bootup→Legal→PermLoad→InitLoad→LoadGlobal→GameSetup, then the in-game task ring: Game, Rendering, SceneManagement, Physics, Sound, HUD, Streaming, WillToFight, AIPathfinder. Contexts: Application / Bootup / Loading / Ingame / MiniBoot.

## Lua binding surface — 898 named engine functions in the clear

The Lua→engine glue is emitted as `LuaGlueFunctor` templates whose RTTI **embeds the bound C++ function name**. Parsed **898 unique bindings** (dump: [`data/lua_bindings.txt`](../data/lua_bindings.txt)). This is the layer that in Mercs 2 was binding-table-only (names but no bodies); here we have names AND directly-disassemblable bodies.

Domain coverage (count of bindings): Vehicle 46, Spawn 28, Mission 25, Damage 14, Disguise 13, Sound 11, Weapon 10, Fire 7, Health 5, Perk 5, Explosion 2 (`CreateExplosion`, `CameraShakeExplosion`), plus Alarm/WillToFight/Wanted/Contraband/Grapple/Climb families. Notable named entry points: `SetHealth`/`GetHealth`/`GetMaxHealth`, `SetDamageState`/`GetDamageState`, `CreateExplosion`, `FireCurrentWeapon`, `ActorSetDisguise`, `UnlockPerk`.

## Lua scripts — plaintext-recoverable

- `LuaScripts.luap` (4.8 MB) — flat pack, **321 entries**, **uncompressed LuaQ 5.1 bytecode** (magic `1B 4C 75 61 51` confirmed at first entry). Debug info intact.
- **323 embedded source paths recovered**, all rooted at `D:\projects\WildStar\pov\BinCommon\Scripts\...` — this is Pandemic's build tree and the internal engine codename ("WildStar") in the clear. Rich AI/soldier state-machine scripts (`SoldierState_*`, `MISSION_*`, `NaziTest_*`).
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

## Follow-on candidates (not yet done)
- Hash the 898 binding names + 823 class names through `pandemic_hash_m2` and diff against Mercs 2 unresolved ASET/registry hashes for shared-name resolution.
- Decompile `LuaScripts.luap` in full (321 scripts) via unluac → mirror the `docs/mercs2-luacd` corpus.
- Map RTTI vtable pointers → function VAs to auto-name the disassembly (vtable is at a fixed `.rdata` offset preceding each `.?AV` descriptor's `type_info`).
- Correlate `WSDamageable`/`WSExplosion` bodies against Mercs 2 `FUN_0051cff0` weapon driver + the un-reversed damage solver.