# Amplifying the Saboteur community tooling with our RE knowledge

What the Saboteur modding community already has, what they're blocked on, and where our
Mercenaries 2 / Pandemic-engine work can uniquely help. Grounded in the clean Saboteur.exe
decomp (regenerate via `tools/ghidra/DecompileSaboteur.java`; output is gitignored), our format corpus, and a July 2026 survey of the tools.

## The community landscape (as of 2026-07)

| Tool | Lang | Scope | Status |
|---|---|---|---|
| [**PredatorCZ/SaboteurToolset**](https://github.com/PredatorCZ/SaboteurToolset) | C++ | anim/mesh/material/texture/map/lua/megapack **extract** | research + extract-only |
| [**BoBoBaSs84/SabTool**](https://github.com/BoBoBaSs84/SabTool) (fork of [Blumster/SabTool](https://github.com/Blumster/SabTool)) | C# | content read/extract, some pack handling | "mostly reading and extracting currently" |
| [Saboteur Team wiki](https://saboteur-team.github.io/wiki/) | — | docs/format notes | reference |
| [Nexus](https://www.nexusmods.com/games/thesaboteur) / [ModDB](https://www.moddb.com/games/the-saboteur) mods | — | texture/script tweaks | consumer-level |

The whole scene is **extraction-oriented**. The comparison already established Pandemic write/repack
tooling is the universal gap. Two capabilities are *hard-blocked* for them; several more we can strengthen.

## What they explicitly CANNOT do (our biggest openings)

### 1. Decode Havok animations → keyframes  ★ highest value, real work
[SaboteurToolset](https://github.com/PredatorCZ/SaboteurToolset)'s own docs: *"There is no way as in current version to convert extracted hkx
files because of separated metadata."* They extract the raw HKX blob + FSM JSON from `animations.pack`
(AP0L), but the **compressed animation is never decoded into keyframes/glTF**. Every Saboteur
character/vehicle animation is currently un-viewable and un-editable.

We solved exactly this class of problem for Mercs 2: a **numerically-verified inverse-Haar wavelet
decoder** (static-mask + quantization-format + per-block bitstream), plus interleaved, plus delta
headers (`tools/hk_anim/`, `docs/modernization/wavelet_decode_verification.md`).

**HONEST CAVEAT — version mismatch.** Saboteur ships **Havok 6.5.0** (`Havok-6.5.0-r1`, build path
`d:\Projects\WildStar\Main\code\Havok_65\`), whereas our decoder targets **Havok 5.5 (HK550)**. The
class names differ (`hkaWaveletCompressedAnimation` / `hkaSplineCompressedAnimation` /
`hkaDeltaCompressedAnimation` in 6.5 vs `hkaWaveletSkeletalAnimation` etc. in 5.5), and Saboteur adds
**spline-compressed** animation, which Mercs 2 didn't emphasize. So the decoder does **not** transfer
byte-for-byte — struct offsets and quantization layout changed 5.5→6.5.

What DOES transfer, and why we're still the best-positioned to crack it:
- The **algorithm** (inverse-Haar wavelet lifting, static-DOF rest pose, dynamic-DOF quantization)
  is fundamentally the same across Havok versions — we already understand it end-to-end.
- We have the **clean, unpacked Saboteur.exe decomp** with the actual Havok 6.5 sampling/decompress
  code readable (no SecuROM wall) — we can re-derive the 6.5 offsets directly from the binary that
  runs them, which is *easier* than how we got 5.5.
- PredatorCZ's [HavokLib](https://github.com/PredatorCZ/HavokLib) covers 6.5 packfile structure — we cross-check against it.
- Contribution shape: a `hkx6.5 → glTF animation` converter (Rust) that pairs the AP0L metadata with
  the blob and runs the 6.5 decompressors. This is the single most-wanted missing capability.

### 2. Audio / voice extraction  ★ ship-ready NOW
No Saboteur tool extracts audio. We already **reverse-engineered the custom `1KCP` Wwise package and
built a working extractor** (`tools/saboteur_audio`), and have produced **80,872 voice-line WAVs**
across all four languages. This is a drop-in contribution with zero remaining blockers — the community
has *nothing* here. Follow-up (HIRC/event-graph → human names) makes it best-in-class.

### 3. A shared, symbol-named decompilation  ★ enables everyone
We produced a **36,935-function clean decomp of Saboteur.exe** with 2,765 RTTI class names and 898
named Lua bindings recovered. The community works from format notes, not a symbol map. Publishing a
curated symbol map / function catalog (megapack loader, mesh loader, Havok samplers, material parser)
would let every other tool author work from ground truth instead of guessing.

## What we can strengthen (they have partial coverage)

### 4. Repack / write + the built-in patch layer
Community is extract-only. We have WAD-write experience and, from the decomp, the **built-in override
mechanism**: the engine mounts `patchmega0.megapack` / `patchdynamic0.megapack` /
`patchpalettes0.megapack` at ~1000× base priority (hash wins) — a clean, no-surgery mod path (see
[`binary_recon.md`](binary_recon.md)). Contribution: a megapack *writer* + documentation of the patch layer so
modders can ship overrides without touching base archives.

### 5. Hash → name resolution
`pandemic_hash` is byte-identical between the games. We have a **733k-entry rainbow table** + a large
Pandemic string corpus. Running these against Saboteur's unnamed asset hashes (and its 7,340-string
`WWiseIDTable.bin`) resolves mystery names the community currently leaves as raw hashes.

### 6. Material / shader semantics
[SaboteurToolset](https://github.com/PredatorCZ/SaboteurToolset) dumps `WSAO` materials to JSON but treats shader params as opaque. Our rendering RE
(what diffuse/spec/normal slots, emissive, and shader property blocks *mean*) can annotate those JSON
fields with real semantics.

## Recommended sequencing

1. **Audio extractor** — contribute now; it's done and unique. Fastest goodwill + immediate utility.
2. **Publish the decomp symbol map** — low effort, high multiplier for other authors.
3. **Havok 6.5 anim decoder** — the crown jewel; scope as a real project, re-derive 6.5 offsets from
   our clean decomp using the 5.5 algorithm as scaffold. Coordinate with PredatorCZ (owns the AP0L
   metadata pairing) so their extractor feeds our decoder.
4. **Megapack writer + patch-layer docs**, then **hash resolution** and **material semantics** as
   incremental strengthening.

## Sources
- SaboteurToolset — https://github.com/PredatorCZ/SaboteurToolset
- SabTool — https://github.com/BoBoBaSs84/SabTool
- Saboteur Team wiki — https://saboteur-team.github.io/wiki/
- Nexus/ModDB Saboteur — https://www.nexusmods.com/games/thesaboteur , https://www.moddb.com/games/the-saboteur
