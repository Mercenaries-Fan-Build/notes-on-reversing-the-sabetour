---
name: havok65-spline-decode
description: The Havok 6.5 hkaSplineCompressedAnimation format is CRACKED — two blind investigators independently decoded all Saboteur clips. Backbone converged; two subtle points under adjudication.
metadata:
  type: project
---

**★FLAGSHIP TARGET CRACKED (2026-07-12).** The community-wide open problem — decode Saboteur's Havok
6.5 animations — is solved. Two independent double-blind investigators (isolated worktrees, no shared
context) each built a std-only Rust decoder that decodes the real `Animations.pack`: one validated all
2214 main-blob clips (133,531 tracks), the other all 9,708 clips across 7,495 packfiles (67.3M
quaternions) — **0 failures, 0 non-unit quaternions, 0 non-finite values.** See [[animation-100pct-spline]].

**Converged backbone (both blind-agree → high confidence):**
- **AP0L carve:** `u32 numAnims; u32 hkSize;` immediately precede the Havok magic `57 e0 e0 57`; blob =
  hkSize bytes. Main blob @0xDECE1, numAnims=2214, hkSize=0x80FB00; self-check `blob+hkSize` = packfile end.
- **Packfile (HK6.5 LE 32-bit):** 3 sections (`__classnames__`/`__types__`/`__data__`); section header
  = 20-byte tag + 7×u32 `[absStart,localFix,globalFix,virtualFix,exp,imp,end]`; `data_pk = body0 +
  classnames.end + types.end`; `__data__` absStart 0x160; virtual fixups bind objects→class. Structurally
  identical to the Mercs2 5.5 walker.
- **Struct (runtime, from ctor `FUN_00eb5de0`/dtor `FUN_00eb7740`):** type@0x08=5, duration@0x0C,
  numTransformTracks@0x10, numFloatTracks@0x14, numFrames@0x24, numBlocks@0x28, maxFramesPerBlock@0x2C,
  **maskAndQuantizationSize@0x30**, blockDuration@0x34, blockInvDuration@0x38, frameDuration@0x3C, then
  hkArrays blockOffsets@0x40 / floatBlockOffsets@0x4C / transformOffsets@0x58 / floatOffsets@0x64 /
  data@0x70. hkArray = {ptr(local-fixup), i32 size, u32 capFlags}.
- **Per-track spline data starts at `blockStart + maskAndQuantizationSize(0x30)`**, NOT numTracks*4
  (padding for large skeletons — both independently hit 111 tracks → 456 not 444). transformOffsets
  empty ⇒ sequential per-track parse.
- **Per-track 4-byte mask** `[ctrl, transMask, rotMask, scaleMask]`; `transType=ctrl&3`,
  `rotType=(ctrl>>2)&0xf`, `scaleType=ctrl>>6`. Corpus is uniformly ctrl=0x45 (type-1 everything, scale≡1).
- **★SYMBOL-MAP CORRECTION (both flag independently):** in `FUN_00eb7e00`, the `ctrl&3` channel
  (`FUN_00eb7880`→`73a0`) writes the **TRANSLATION** slot (0x00); `(ctrl>>2)&0xf` (`FUN_00eb7830`→`72c0`)
  writes **ROTATION** (0x10); `ctrl>>6` (`FUN_00eb7930`) writes SCALE (0x20). docs/symbol_map/animation.md
  labels 7880 as rotation — WRONG. Fix animation.md after adjudication.
- **Trans/scale:** per-component NURBS (`FUN_00eb73a0`): static=1 f32, spline=2 f32 (min,max)+quantized
  CPs; 8-bit÷255 (`_DAT_00f8b710`) or 16-bit÷65535 (`_DAT_00ffad68`); value=min+q·(max−min).
- **Rotation:** THREECOMP40 (type 1), 5 bytes/CP (`DAT_0109dad0[1]=5`), 3×12-bit + implicit largest.
- **NURBS:** `u16 numItems(=numCP−1); u8 degree; u8 knots[numItems+degree+2]`; clamped B-spline (de Boor),
  degree blenders `DAT_011de968[degree]` (`FUN_00eb6a60/6dc0`).

**Two contested points — ADJUDICATED (the validator disassembled Saboteur.exe directly; the THREECOMP40
unpacker `FUN_00f22470` is FPU-heavy and NOT in the Ghidra decomp):**
1. **THREECOMP40 bits — neither investigator fully right.** Correct: 3×12-bit small comps, each
   `value = (raw − 2047)/(2047·√2)` (offset **2047** @0xf22505; scale `1/(2047·√2)` from consts 2.0/2047.0
   @0xf2247a); **index = bits 36-37** (A right, B wrong); **sign = bit 38** (`fchs` @0xf225a3 — A dropped
   the sign entirely = biggest bug; B had a sign but at wrong bit 37); **bit 39 unused**;
   `largest = ±√(1−Σsmall²)`.
2. **Spline time param — Investigator A right.** de Boor at **continuous blockTime seconds**, knots
   **×frameDuration** (`FUN_00eb7830`@0x784f feeds frameDuration as knot scale; `FUN_00eb65a0` line 1665089),
   integer `frameInBlock` used ONLY for findSpan (`FUN_00eb6420`). B's integer-u/raw-knot model is wrong
   off-frame. `FUN_00eb8120`: `blockIndex=clamp(trunc(t·blockInvDur),0,nBlocks−1)`, `blockTime=t−bi·blockDur`,
   `frameInBlk=trunc(blockTime·blockInvDur·(maxFPB−1))`; `FUN_00e47360`=cvttsd2si(trunc); t∈[0,duration].

**DONE:** authoritative decoder = Investigator A's base + the THREECOMP40 patch → `tools/sab_havok65`
(builds, decodes 2214/2214 clean). Spec written to docs/formats/animation_havok65.md; channel-label error
fixed in docs/symbol_map/animation.md.

**Residual risk (adjudicator register):** multi-block path (corpus all single-block), rotation quant modes
0/2/3/4/5 + 16-bit trans/scale (corpus all ctrl=0x45 type-1), and the `maskAndQuantizationSize@0x30`
sequential-parse fallback (shipping sampler indexes transformOffsets@0x58; empty here) are INFERRED —
close via out-of-corpus assets or a live x32dbg capture of `FUN_00eb7e00`.

**Next:** previewer/modifier = reuse `mercs2_anim::pose/ik` + `mercs2_engine` wgpu + `mercs2_workshop` egui
(see wad_simulator crate reuse map), pairing sab_havok65 output with AP0L bone lists + MSHA skeleton.
See [[symbol-map-methodology]], [[animation-100pct-spline]].
