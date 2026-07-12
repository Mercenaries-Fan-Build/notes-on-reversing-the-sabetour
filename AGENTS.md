# Working in this repository (humans and AI agents)

This is a reverse-engineering knowledge base for **The Saboteur (2009)**. Read this before making
changes. It defines conventions and — importantly — how NOT to over-import from the Mercenaries 2 work
this project descends from.

## Prime directive: verify lineage before you reuse

The Saboteur runs a **later revision of the Pandemic engine** than Mercenaries 2. Some things are
byte-identical (the hash, `sges` compression); most concrete formats are **different** (megapack vs
FFCS WAD, Havok 6.5 vs 5.5, Wwise `1KCP` vs PWS wavebanks, flat MESH vs UCFX, WSAO vs MTRL).

Before stating that a Mercs 2 fact applies here, check [`docs/lineage_and_divergence.md`](docs/lineage_and_divergence.md).
If it isn't in the "shared" column, treat it as **unverified** and confirm against the Saboteur binary
or assets. Never copy a Mercs 2 offset, struct, or hash into a Saboteur doc without re-deriving it.

## Ground truth, in priority order

1. **The clean decomp** — `output/_ghidra_saboteur/saboteur_all_functions_decomp.txt` (36,935 fns,
   local/regenerable). The exe is unpacked, so the decomp is authoritative for engine behavior. Grep it.
2. **RTTI / bindings** — `data/rtti_classes_all.txt`, `data/ws_engine_classes.txt`, `data/lua_bindings.txt`.
3. **The retail install** — `C:\GOG Games\The Saboteur` (assets, `LuaScripts.luap`, `.pck`, megapacks).
4. **SaboteurToolset** (PredatorCZ) & **SabTool** — community format prior art to cross-check, not to trust blindly.

## Conventions

- **Prefer Rust for tooling** (see `tools/saboteur_audio`). Small std-only binaries; document how to run.
- **Verify artifacts by hash**, not size/mtime, when you produce or deploy anything.
- **Ask, don't assume** on unverified setup/intent facts. State the defaults you pick.
- **Minimal, faithful edits** to others' files; don't reword working prose.
- **Don't commit game assets or huge regenerated outputs** — they're gitignored. Commit the *method*
  to regenerate them, plus small reference dumps.
- Every format claim should cite its evidence: a decomp function VA, a byte offset in a named file, or
  a cross-reference to SaboteurToolset source.

## What is deliberately NOT carried over from the Mercs 2 repo

- SecuROM devirtualization workflow — **irrelevant**; the Saboteur exe is already clean.
- The x32dbg live-debugging playbook tied to Mercs 2's SecuROM-unpacked image.
- The FFCS/WAD (`vz.wad`, `vz-patch.wad`) block-injection machinery — Saboteur uses megapacks + a
  built-in `patchmega*.megapack` override layer instead.
- The Mercs 2 64-bit Rust/wgpu reimplementation program.
- Havok **5.5** struct offsets — Saboteur is **6.5** (different layout).

Bring over *methodology* (Ghidra headless flow, hash pipeline, Wwise/vgmstream approach), not *facts*.

## Memory

`memory/` holds durable cross-session notes; `memory/MEMORY.md` is the one-line index. Add a note when
you establish something non-obvious and reusable; keep index lines short.
