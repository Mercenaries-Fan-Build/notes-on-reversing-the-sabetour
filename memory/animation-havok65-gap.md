---
name: animation-havok65-gap
description: Saboteur = Havok 6.5 (NOT 5.5); AP0L anim pack; community can't decode hkx → our flagship RE target
metadata:
  type: reference
---

**★Saboteur uses Havok 6.5.0** (`Havok-6.5.0-r1`, build path `d:\Projects\WildStar\Main\code\Havok_65\`), NOT the 5.5 Mercs 2 uses. 6.5 classes: `hkaWaveletCompressedAnimation`/`hkaSplineCompressedAnimation`/`hkaDeltaCompressedAnimation`/`hkaInterleavedUncompressedAnimation` (note: adds spline). Struct offsets + quantization changed 5.5→6.5 → a Mercs-2-style 5.5 wavelet decoder does NOT transfer byte-for-byte; only the algorithm (inverse-Haar lifting, static-mask, quant-format) carries. See [[read-lineage-and-divergence]].

**AP0L pack** (`animations.pack`): ANIM(clip meta: duration/bones/flags/id) / SEQC / TRAN / EDGE(~5030 FSM) / BANK / SSP0(streamed offsets) / INTV/ALPH/ADD1/ANMA, then `u32 numAnims; u32 hkSize;` + one concatenated `animations.hkx` blob.

**Community blocker (SaboteurToolset verbatim):** "no way to convert extracted hkx because of separated metadata." Two coupled issues: (1) re-pair ANIM meta with blob; (2) decode compressed HKX (needs Havok 6.5 decompressor).

**Why we can crack it (flagship target):** clean unpacked exe → the 6.5 sampling/decompress code is readable in the decomp (grep `hka*Compressed*`, `sampleTracks`, `hkQsTransform`); re-derive 6.5 quant struct from the binary, validate vs a known clip, build Rust `hkx6.5→glTF`. Coordinate with PredatorCZ (owns AP0L metadata pairing). Status: NOT started. docs/formats/animation_havok65.md, [[community-contribution-plan]].
