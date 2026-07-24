# sab_validator

A **modification validator** for The Saboteur (2009). It parses game assets the way the engine's
mount path does — guided by the disassembled loaders — and reports anything the engine would choke
on. Point it at a mod's repacked archive to answer *"will this load, and if not, why?"* before the
game ever touches it.

Built on [`sab_formats`](../sab_formats), which implements the Saboteur-specific containers and
reuses the shared Pandemic-engine primitives (resource hash, SGES, bounds-checked cursor) from the
published `mercs2_formats` crate.

## Usage

```
sab_validator <asset> [--limit N] [--json out.json] [--max-issues N] [--quiet]
```

Dispatches by magic:

* `00PM` **.megapack / .kilopack** — walks the whole archive: index → every `ALBS` sub-pack → every
  contained texture and mesh.
* `ALBS` **sub-pack** — validates one sub-pack directly.

Flags: `--limit N` descends only the first N megapack entries (fast smoke test); `--json out.json`
writes the machine-readable report; `--max-issues N` caps printed issues (default 60, `0` = all);
`--quiet` prints the summary only. **Exit code 0 = no fatal findings, 1 = fatal, 2 = usage/IO.**

## The mount path it mirrors

```
.megapack (00PM)   mounter FUN_00e428c0        index + entry byte-ranges + 2048 alignment
  └─ ALBS sub-pack  loader  FUN_00658870        directory-chain integrity (soft; see below)
       ├─ DTEX      texture FUN_009bb910         record + zlib streams + mip payload + mip tiling
       └─ MSHA/MESH stream  loader               body/.dat decode to declared uncompressed size
```

An ALBS sub-pack wraps several resource kinds (mesh/texture directory, particle `CFX`, empty stub,
named config, terrain…). The mesh/texture *directory* model is only one of them, so — like the real
extractors — the validator does not gate on it: directory integrity is a **soft** check (fatal only
when the directory cleanly parses *and* a blob range genuinely overruns). The load-bearing checks
are content-scanning for DTEX textures and MSHA meshes and validating each the way the engine
consumes it.

## Severity

| Tier | Meaning | Gates exit code |
|------|---------|-----------------|
| **FATAL** | the loader would reject or fault on it — the asset will not load | yes |
| **WARN** | loads, but breaks an invariant the cooker always upholds (e.g. mip size vs dimensions) | no |
| **INFO** | heuristic/cosmetic deviation from retail (e.g. non-sector-aligned offset) | no |

Every rule cites the decompiled function it is derived from (`engine_ref`), so each diagnostic is
auditable back to the disassembly. The single `Report::exit_code` funnel keeps the "which findings
gate a build" policy in one auditable place.

## Ground-truth oracle

The validator is calibrated to **0 false positives on the shipped `Global/` packs** — but *not* on
every retail archive; see the `France/` row below.

| Pack | sub-packs | textures | meshes | verdict |
|------|-----------|----------|--------|---------|
| `Dynamic0.megapack` | 759 | 8 980 | 6 807 | 0 fatal / 0 warn |
| `Palettes0.megapack` | 321 | 3 579 | 50 | 0 fatal / 0 warn |
| `patchdynamic0.megapack` | 1 | 29 | 8 | 0 fatal / 0 warn |
| `France/Start0.kiloPack` | 12 | 498 | 441 | 0 fatal / 0 warn |
| `France/BelleStart0.kiloPack` | 95 | 1 716 | 2 348 | ⚠️ **96 fatal** — see below |

> ### ⚠️ Known false positives: `BelleStart0.kiloPack`
>
> Untouched retail data produces **96 fatals**, all from the single rule
> `mesh.prim-tricount-mismatch`, concentrated in a handful of entries and overwhelmingly on
> `France_Streamblock_*_baked_*` meshes (plus a few objects such as `OccLt_Main_NZFlag_D`). The
> reported values are plainly garbage (`numIndices=432042701`, `tricount=973768353`), which points at
> the *reader* slicing these blobs at the wrong place rather than at genuinely corrupt retail assets.
>
> Confirmed **pre-existing and independent of the 2026-07-24 `Model::Middle` correction** — an A/B
> build with the old absolute base produces the identical 96. The prime suspect is the streamblock
> (`flags=0x3C`) `Tail` placement, which is the one ALBS variant whose blob base is still unverified
> (`sab_sbla replace` warns on it for the same reason).
>
> **Consequence:** on `France/` packs a FATAL is not automatically a real defect. On `Global/` packs
> — which is where texture and character mods are built — the 0-false-positive calibration holds.

And it has teeth — deliberately corrupted copies are all caught: bad megapack magic, out-of-range
entry, truncated archive (`megapack.entry-out-of-range`), a flipped mesh blob byte
(`mesh.blob-inflate-mismatch`), and a flipped DTEX stream byte (`dtex.stream-inflate-failed`).

## Coverage & roadmap

Covered: megapack container, ALBS directory integrity, DTEX textures, MSHA/MESH decode.

Not yet: deeper MESH geometry invariants (skin weights sum to 255, unit-length normals,
`index < numVertices`), WSAO material→texture bindings, `.luap` scripts, `1KCP` audio, `AP0L`/Havok
animation, `AULB` templates, `MAP6`. The `sab_formats` parsers for several of these already exist in
sibling tools and can be lifted in as consumers.
