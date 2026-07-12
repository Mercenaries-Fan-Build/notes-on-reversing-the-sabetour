# Animation — Havok 6.5 + the `AP0L` pack

Animation is the flagship open problem: the whole community can *extract* Saboteur animation but nobody
can *decode* it into keyframes. This doc records the ground truth and why we're well-positioned to crack
it — with an honest note on why our Mercs 2 decoder does **not** just drop in.

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

## The community blocker (verbatim)

SaboteurToolset docs: *"There is no way as in current version to convert extracted hkx files because of
separated metadata."* Two coupled problems:
1. **Metadata is separated** from the HKX blob (bones/duration live in `ANIM`, samples in the blob) —
   they must be re-paired.
2. Even paired, the **compressed HKX still needs a Havok 6.5 decompressor** (wavelet/spline/delta).

## Why we can crack it

- **Clean, unpacked `Saboteur.exe`** → the actual Havok 6.5 sampling/decompression code is readable in
  the decomp (`hkaWaveletCompressedAnimation::sampleTracks` and friends), so we can re-derive the 6.5
  struct offsets from the binary that runs them — easier than we had it for Mercs 2's SecuROM-walled build.
- We already understand the wavelet algorithm end-to-end from the Mercs 2 work (use it as scaffold).
- PredatorCZ's HavokLib covers 6.5 packfile structure for cross-checking; SaboteurToolset already does
  the `ANIM`↔blob half — coordinate rather than duplicate.

## Plan
1. Locate the 6.5 decompressor entry points in the decomp (grep `hka*Compressed*`, `sampleTracks`,
   `hkQsTransform`).
2. Re-derive the wavelet quantization struct for 6.5 from those bodies; validate against a known clip.
3. Build a Rust `hkx6.5 → glTF animation` converter that pairs `AP0L` metadata with the blob.
4. Contribute upstream so SaboteurToolset's extract feeds our decode.

Status: **not started** — highest-value target. See [`../community_tooling.md`](../community_tooling.md).
