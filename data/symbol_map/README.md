# PC symbol map — names recovered from the 2008 prototype

`pc_symbol_map.tsv` names **1,414 functions** in the stripped PC retail `Saboteur.exe` decomp, recovered
by correlating it with the **2008-05-20 Xbox-360 prototype**, which ships full symbols
(see memory `prototype-symbols-goldmine`). Columns: `pc_va · name · source · method`.

## How the names were recovered (two independent methods)

1. **RTTI vtable alignment** — PC MSVC RTTI (`vtable[-1]→COL→TypeDescriptor→".?AVClass@@"`) gives each
   class's ordered vtable = virtual-method **VAs**. The 360 linker map's `??_7Class@@6B@` vftable, read
   big-endian out of the PowerPC `WildStar_d.exe`, gives the same class's virtual methods **by name**.
   Same C++ layout ⇒ slot *i* is the same method ⇒ the 360 name transfers to the PC VA.
   **Gated to classes with identical vtable length in both builds** — the detectable signal that the
   layout did not drift 2008→2009. Drifted classes (the `WSConduit` game-object hierarchy grew) are
   **excluded**, not guessed.
2. **Assert-string anchors** — retail kept EA's `__FILE__`/`__FUNCTION__` asserts; a `"WSFoo::Bar"`
   literal unique to one function body names it directly (reaches non-virtual functions RTTI can't).

## Adjudication (double-blind)

Two investigators derived this independently. They **converged on the method and the equal-length gate**.
Their overlap was 836 VAs with **only 10 true class conflicts (98.8% agreement)** — the rest were pure
formatting (namespace prefix, `~dtor` vs `` `deleting dtor' ``, template demangling). The 10 conflicts
are the classic shared-base-virtual ambiguity (base vs derived attribution); reconciled toward the
**base class** (e.g. `PblRef::Kill`, `hkUnaryAction::*`), except the `_purecall` stub.

`source` column:
- `both` (824) — **double-blind confirmed**, both methods/investigators agree. Highest trust.
- `both-conflict(base-preferred)` / `both-reconciled` (12) — overlap, conflict resolved as above.
- `single-A` (558) / `single-B` (20) — one investigator only (from a broader equal-length set); high
  confidence per method, but single-source.

## Validation (accuracy oracle)
- Assert method vs the curated `docs/symbol_map` catalog: **53/54 (98%)**, 0 wrong.
- RTTI exact tier vs asserts: **5/5**; structural pure-virtual test (pure slots must land on the single
  `_purecall`): **118/118 (100%)** — a name-oracle-free proof that slot-*i*==slot-*i* for shipped tier.

## ⚠️ Caveats
- **Names transfer; addresses do NOT.** 360 is PPC/big-endian @0x82000000; PC is x86/LE @0x00400000.
  Every VA here is a fresh **PC** address; the name came from the 360.
- **Drifted classes are excluded.** RTTI alignment only covers virtual methods of layout-stable classes.
  The `WSConduit`/game-object hierarchy (`WSHuman`/`WSVehicle`/`WSWeapon`…) shifted between builds — class
  identity is known but per-method slots are NOT reliable; those are not in this map.
- 2008 pre-release ≠ 2009 retail: verify anything load-bearing against the PC decomp itself.

## Reproduce
Scripts in [`../../tools/xsym/`](../../tools/xsym/): `pe.py` (RTTI/vtable walk), `build_pc.py` /
`build_360.py`, `demangle.py`, `body_names.py` (asserts), `join.py` / `finalize.py`. They read the game
binaries by absolute path (never copied). The 360 map/exe/pdb live in `game-files/symbols/` (gitignored).
