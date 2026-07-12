# Animation — Havok 6.5 + the `AP0L` pack

Animation is the flagship open problem: the whole community can *extract* Saboteur animation but nobody
can *decode* it into keyframes. This doc records the ground truth and why we're well-positioned to crack
it — with an honest note on why our Mercs 2 decoder does **not** just drop in.

> **★ UPDATE (2026-07-12) — the format is 100% spline-compressed.** A class-name scan of retail
> `Animations.pack` (187 MB) found **`hkaSplineCompressedAnimation` × 9,709 and wavelet / delta /
> interleaved × 0.** The entire corpus is a *single* format — Havok 6.5 **spline-compressed** — which is
> a documented, community-understood format (HavokLib; Skyrim-era tooling), NOT the inverse-Haar wavelet
> that Mercs 2 leaned on (and never fully cracked). The wavelet framing below is therefore **superseded**:
> the decode target is spline only. The symbol map pins the sampler (`FUN_00eb7e00`
> `sampleAndDecompress` and friends — see [`../symbol_map/animation.md`](../symbol_map/animation.md)),
> and a double-blind two-investigator + validator agent effort is deriving the exact quantization. This
> doc will be rewritten with the validated spec once that lands. See memory `animation-100pct-spline`.

## ⚠️ Version: Havok **6.5.0**, not 5.5

Confirmed from the exe: `Havok-6.5.0-r1`, build path `d:\Projects\WildStar\Main\code\Havok_65\`
(see [`../../data/havok_version_evidence.txt`](../../data/havok_version_evidence.txt)). Mercenaries 2 is
Havok **5.5** (HK550). Consequences:

- Compressed-animation class names differ:
  - Saboteur (6.5): `hkaWaveletCompressedAnimation`, `hkaSplineCompressedAnimation`,
    `hkaDeltaCompressedAnimation`, `hkaInterleavedUncompressedAnimation`
  - Mercs 2 (5.5): `hkaWaveletSkeletalAnimation`, `hkaDeltaCompressedSkeletalAnimation`, …
- Saboteur adds **spline-compressed** animation (`hkaSplineCompressedAnimation`), which Mercs 2 didn't
  emphasize. Spline compression is Havok's dominant format in the 6.x era.
- **Struct offsets and quantization layout changed 5.5 → 6.5.** Our numerically-verified Mercs 2
  wavelet decoder is **not** byte-compatible here. What transfers is the *algorithm* (inverse-Haar
  wavelet lifting, static-mask DOF classification, quantization-format offset/scale/bitwidth), not the
  field layout.

## `AP0L` animation pack (from SaboteurToolset `animpack/anim_extract.cpp`)

`animations.pack` (magic `AP0L`) holds named block types, then one concatenated HKX blob:

| Block | Magic | Content |
|---|---|---|
| `ANIM` | MINA | clip metadata: duration, bone list (hashes), flags, `streamed` flag, `id` |
| `SEQC` | CQES | animation sequences (looping/blend) |
| `TRAN` | NART | state-machine transitions |
| `EDGE` | EGDE | FSM edges (~5030 entries) |
| `BANK` | KNAB | animation banks (parent hierarchy, grouped clips) |
| `SSP0` | 0PSS | streamed-animation offsets/sizes |
| `INTV`/`ALPH`/`ADD1`/`ANMA` | … | interruptions / blend-tree / additive / metadata |

After the metadata: `u32 numAnims; u32 hkSize;` then `hkSize` bytes written as one `animations.hkx`.

## ✅ SOLVED — the validated spline decode

The community blocker (SaboteurToolset: *"no way … to convert extracted hkx files because of separated
metadata"*) is resolved. The whole corpus is `hkaSplineCompressedAnimation` (see the update banner
above), a documented Havok format. It was reverse-engineered by a **double-blind protocol** — two
investigators independently derived and empirically decoded the format (each decoding the entire real
`Animations.pack`, 0 failures), then a third agent adjudicated the two points their validation could not
distinguish, resolving them by **disassembling `Saboteur.exe` directly** (the THREECOMP40 unpacker
`FUN_00f22470` is FPU-heavy and absent from the Ghidra decomp). Reference decoder: `tools/sab_havok65`
(std-only Rust; `cargo run --release -- "…/Animations.pack" all` → 2214/2214 clean).

### AP0L → HKX carve
`u32 numAnims; u32 hkSize;` immediately precede the first Havok packfile magic `57 e0 e0 57`; the blob is
`hkSize` bytes. Retail main blob: magic at file `0xDECE1`, `numAnims=2214`, `hkSize=0x80FB00`; self-check
`0xDECE1 + hkSize` lands exactly on the packfile's declared end. (7,495 further packfiles in the pack are
per-clip *streamed* sub-animations; the class-string count 9,709 = 2,214 + one per streamed packfile.)

### Havok 6.5 packfile (LE, 32-bit)
Header: magic `0x57E0E057 0x10C0C010`, fileVersion 6, layoutRules `04 01 00 01` (4-byte pointers, LE),
3 sections `__classnames__`/`__types__`/`__data__`. Section header = **20-byte tag + 7×u32**
`[absDataStart, localFixups, globalFixups, virtualFixups, exports, imports, end]` (section-relative).
`data_pk = body0 + classnames.end + types.end`; `__data__` absDataStart `0x160`. Local fixups (8-byte
`src,dst`) relocate hkArray pointers; virtual fixups (12-byte `src,sec,classNameOff`) bind objects → class.
Structurally identical to the Mercs 2 (5.5) walker.

### `hkaSplineCompressedAnimation` struct (runtime offsets)
From ctor `FUN_00eb5de0` / dtor `FUN_00eb7740`, confirmed against real bytes:

| Off | Field | | Off | Field |
|---|---|---|---|---|
| 0x08 | type = 5 (spline) | | 0x34 | blockDuration (f32) |
| 0x0C | duration (f32) | | 0x38 | blockInverseDuration (f32) |
| 0x10 | numTransformTracks | | 0x3C | frameDuration (f32) |
| 0x14 | numFloatTracks | | 0x40 | blockOffsets hkArray |
| 0x24 | numFrames | | 0x4C | floatBlockOffsets hkArray |
| 0x28 | numBlocks | | 0x58 | transformOffsets hkArray (empty in corpus) |
| 0x2C | maxFramesPerBlock | | 0x64 | floatOffsets hkArray |
| 0x30 | **maskAndQuantizationSize** | | 0x70 | data hkArray (u8) |

hkArray = `{ptr(local-fixup), i32 size, u32 capFlags}`. Self-consistent for all 2214 clips:
`frameDuration == duration/(numFrames−1)` and `blockDuration == (maxFramesPerBlock−1)·frameDuration`.

### Block + per-track decode
Per block (`data + blockOffsets[b]`): `numTracks` × 4-byte mask `[ctrl, transMask, rotMask, scaleMask]`,
then per-track spline data starting at **`blockStart + maskAndQuantizationSize`** (0x30 — *not* `numTracks·4`;
it is padded for large skeletons). `transformOffsets` is empty in the corpus ⇒ tracks are parsed
**sequentially**. Control byte: `transType = ctrl&3`, `rotType = (ctrl>>2)&0xf`, `scaleType = ctrl>>6`.
Channel decode order and output slots: **translation@0x00, rotation@0x10, scale@0x20**, each 4-byte aligned.
(The corpus is uniformly `ctrl = 0x45` → all type 1.)

- **Translation / scale** (`FUN_00eb73a0`): per component — static bit ⇒ one f32; spline bit ⇒ f32 `min,max`
  + quantized control points (8-bit ÷255 or 16-bit ÷65535), value `= min + q·(max−min)`.
- **Rotation** = **THREECOMP40** (5 bytes/CP): 40-bit LE word; three 12-bit small comps at bits
  `[0:12)/[12:24)/[24:36)`, each `value = (raw − 2047)/(2047·√2)`; **bits 36-37 = index of the omitted
  (largest) component; bit 38 = its sign; bit 39 unused**; `largest = ±√(1 − Σsmall²)`. (The sign bit and
  the exact dequant were the adjudicated corrections — unit-norm alone cannot catch a wrong sign.)
- **NURBS**: `u16 numItems(=numCP−1); u8 degree; u8 knots[numItems+degree+2]` (clamped B-spline, de Boor).

### Sampling at arbitrary time `t` (faithful to `FUN_00eb8120`)
```
t          = clamp(t, 0, duration)
blockIndex = clamp(trunc(t · blockInverseDuration), 0, numBlocks−1)
blockTime  = t − blockIndex · blockDuration                       # block-local SECONDS
frameInBlk = trunc(blockTime · blockInverseDuration · (maxFramesPerBlock−1))  # integer, findSpan only
span       = findSpan(frameInBlk, degree, rawByteKnots)           # INTEGER domain
knots[i]   = rawByteKnots[i] · frameDuration                      # scaled to seconds
value      = deBoor(u = blockTime, degree, knots, controlPoints)  # CONTINUOUS seconds
```

### Verified vs open
- **CONFIRMED** (whole corpus, 2214 clips / 133,531 tracks, 0 failures / 0 non-unit quats): everything above.
- **Open** (corpus is uniform `ctrl=0x45`, single-block): the **multi-block** blend path, rotation quant
  types **0/2/3/4/5** (POLAR32/THREECOMP48/24/STRAIGHT16/UNCOMPRESSED), and the **16-bit** translation/scale
  path — structurally present, decoders identified by table+size, but not exercised by this pack. Close via
  out-of-corpus assets or a live x32dbg capture of `FUN_00eb7e00`. See memory `havok65-spline-decode`.

## Next: previewer/modifier
The decode was the blocker. A previewer is mostly reuse from the Mercs 2 `wad_simulator` workspace:
`mercs2_anim::pose`/`ik` (version-agnostic `hkQsTransform` compose/blend/skin) + the `mercs2_engine`
wgpu renderer + the `mercs2_workshop` egui shell. Pair `sab_havok65` output with the AP0L `ANIM` bone
lists and the MSHA skeleton, apply the sampling formula above, feed the skinning path.
