---
name: animation-100pct-spline
description: Saboteur uses ONLY hkaSplineCompressedAnimation (9709 hits in Animations.pack; wavelet/delta/interleaved = 0). The whole anim-decode effort is one KNOWN format, not the blocked Mercs2 wavelet.
metadata:
  type: project
---

**★Decisive finding (2026-07-12).** Scanned retail `Animations.pack` (187,341,107 bytes, magic
`AP0L`/"L0PA" LE): class-name string counts are **`hkaSplineCompressedAnimation` = 9709**, and
`hkaWaveletCompressedAnimation` / `hkaDeltaCompressedAnimation` / `hkaInterleavedUncompressedAnimation`
= **0**. Havok packfile magic `0x57e0e057` present (first hits 0xdece1, 0x970e4b, 0x97230f).

**Consequences for the flagship anim-decode target:**
- The entire Saboteur animation corpus is **one format**: Havok 6.5 spline-compressed. No wavelet, no
  delta, no interleaved. This overturns the earlier framing in [[animation-havok65-gap]] that leaned on
  the Mercs2 inverse-Haar wavelet work — that decoder is IRRELEVANT here.
- Spline-compressed is a **documented, community-understood format** (HavokLib/PredatorCZ; also the
  Skyrim-era Havok anim format) — MORE tractable than the 5.5 wavelet that Mercs2 never cracked
  (`mercs2_formats::anim` only ever decoded the interleaved path; wavelet stayed blocked).
- The symbol map already pinned the sampler: `FUN_00eb7e00` =
  `hkaSplineCompressedAnimation::sampleAndDecompress` (control byte → R `&3` / T `>>2&0xf` / S `>>6`
  quant types), R/T/S decoders `FUN_00eb7880/7830/7930`, shared NURBS eval `FUN_00eb73a0`, block
  resolver `FUN_00eb8120`, shared chunk-data seam `FUN_00f227c0`, ctor `FUN_00eb5de0` (vtable
  `PTR_FUN_0109c8ac`, 7 header fields, 5 block arrays at 0x10/0x13/0x16/0x19/0x1c). See
  docs/symbol_map/animation.md (incl. its adversarial-verification corrections).

**Reuse from wad_simulator (Mercs2):** `mercs2_formats::havok` packfile walker + `anim.rs` QsTransform +
interleaved sampler = version-agnostic scaffold to PORT. `mercs2_anim::pose/ik/controller` = reusable
pose math. The DECODE itself (spline) is new work but well-specified. See [[symbol-map-methodology]].

Target: standalone `sab_havok65` decoder crate (user chose "decoder crate first"). Being cracked via a
double-blind two-investigator + validator agent protocol.
