# Amplifying the Saboteur community tooling with our RE knowledge

What the Saboteur modding community already has, what they're blocked on, and where our
Mercenaries 2 / Pandemic-engine work can uniquely help. Grounded in the clean Saboteur.exe
decomp (regenerate via `tools/ghidra/DecompileSaboteur.java`; output is gitignored), our format corpus, and a July 2026 survey of the tools.

## The community landscape (as of 2026-07)

| Tool | Lang | Scope | Status |
|---|---|---|---|
| [**PredatorCZ/SaboteurToolset**](https://github.com/PredatorCZ/SaboteurToolset) | C++ | anim/mesh/material/texture/map/lua/megapack **extract** | research + extract-only |
| [**BoBoBaSs84/SabTool**](https://github.com/BoBoBaSs84/SabTool) (fork of [Blumster/SabTool](https://github.com/Blumster/SabTool)) | C# | content read/extract, some pack handling | "mostly reading and extracting currently" |
| [**gamelaster/LuapExplorer**](https://github.com/gamelaster/LuapExplorer) | C# | `.luap` **extract / import / edit** — auto-decompiles Lua inside the pack | v1.0 (Dec 2017), minimal upkeep |
| [**saboteur-team/sab-lua-api**](https://github.com/saboteur-team/sab-lua-api) | Lua | Lua API **stubs / definitions** (library folder), MIT | reference / defs |
| [**ArcanePlant/FileConvTool**](https://github.com/ArcanePlant/FileConvTool) | Python | "tools for games" — file conversion; README failed to load, exact format scope **unverified** | unverified |
| [**Daniel-McCarthy/Saboteur-GameTemplates-Helper**](https://github.com/Daniel-McCarthy/Saboteur-GameTemplates-Helper) | C++ | parses **`AULB`** game-template files (`.wsd`/`.pack`): template metadata + hash/value pairs, list/search | read-only helper |
| **"Saboteur Toolkit"** (shared 2026-07 by a community member; not ours) | Python | texture **extract + write/repack** (megapack/ALBS/DTEX) + AI-upscale pipeline + patch-megapack builder | **first write-capable tool** (see below) |
| [Saboteur Team wiki](https://saboteur-team.github.io/wiki/) | — | docs/format notes | reference |
| [Nexus](https://www.nexusmods.com/games/thesaboteur) / [ModDB](https://www.moddb.com/games/the-saboteur) mods | — | texture/script tweaks | consumer-level |

The whole scene is **extraction-oriented**. The comparison already established Pandemic write/repack
tooling is the universal gap. Two capabilities are *hard-blocked* for them; several more we can strengthen.

### Research assets & references (received 2026-07 from a community mod maker)

- **Pre-release build: The Saboteur (2008-05-20)** — a [7z archive](https://www.mediafire.com/file/t7mh5jiy7bq2g8m/The_Saboteur_(2008-05-20).7z/file)
  of an early build, ~18 months before the 2009 retail. **High RE value, not yet obtained locally:**
  pre-release Pandemic builds are frequently less-stripped (possible debug data / symbols) and can carry
  older or looser asset formats. A retail-vs-2008 diff is a strong lead — see the queued task below.
- **Mission catalog** — a [community Google Sheet](https://docs.google.com/spreadsheets/d/12oW0kqT4ZXQDrv0Q9z9yCwqTrjSbKcyIbkB-hAwMBlw/edit)
  enumerating the game's missions; a naming reference for when we work through the Lua mission scripts.
- **Lua cross-checks for our cracked `.luap`**: **LuapExplorer** (independent C# `.luap` reader/editor)
  and **sab-lua-api** (Lua API stub set) are useful to validate our format notes and to annotate the
  898 named Lua bindings — we already decompiled all 321 scripts, so these are corroboration, not new capability.
- **`AULB` game-template format** — surfaced by Daniel-McCarthy's helper; a template tag (`.wsd`/`.pack`)
  **not yet documented in this repo**. Worth cataloguing in `docs/formats/` once cross-checked against the decomp.
- A [Google-Drive-hosted text-editor tool](https://drive.google.com/file/d/1qdNvdbsKGyXTN__nMub4mUcosQG1HfzF/view)
  was also shared; scope not yet inspected.
- **"Saboteur Toolkit"** (Python) — shared privately 2026-07 by a community member; **third-party work, not
  authored here**, kept locally (not redistributed). It is the **first tool that can *write* the texture
  format**, not just read it: extract → (AI-)upscale → repack into an additive patch megapack. Its author
  credits PredatorCZ's [SaboteurToolset](https://github.com/PredatorCZ/SaboteurToolset) for the read/DTEX
  groundwork and states the write/repack side was worked out independently. Safety-reviewed on receipt: the
  Python is clean (no `exec`/`eval`/pickle; downloads only from Microsoft + HuggingFace/GitHub over HTTPS),
  the bundled `texconv.exe` carries a valid Microsoft Authenticode signature, and the only game-dir writes
  are additive patch megapacks + a vanilla backup. (Caveat for anyone running it: the bundled `.pth` upscale
  models are pickle files — re-fetch them from the official URLs via its `get_tools.py` rather than trusting
  bundled copies.)

  Format specifics **it documents and byte-verifies** (attributed to the toolkit; consistent with our
  [`archive_and_models.md`](formats/archive_and_models.md), not independently re-derived here):
  - **DTEX per-mip headers are interleaved** — a 24-byte header `{mipIdx,w,h,0,1,mipSize}` precedes *each*
    mip in the concatenated stream, so `uncompressedSize == Σ mipSizes + 24·numMips`. Getting this wrong
    desyncs the engine's mip walk and crashes before the menu (their empirical note — a rule our clean
    decomp's DTEX loader could *explain* engine-side, which theirs cannot: see §4).
  - **Multistream = fixed 1.5 MiB (`0x180000`) uncompressed chunks**, each zlib'd separately;
    `uncompressedSize` is the total.
  - **ALBS bundle** (their `'ALBS'` FourCC = our little-endian **SBLA**, cf. `tools/sab_sbla`): `DynFile`
    offsets are relative to the *end of the tables*, not the bundle start.
  - **Independently confirms the patch-megapack override layer** (`patchdynamic0.megapack`,
    `patchpalettes0.megapack`, `patchmega0..2`) that §4 / [`binary_recon.md`](binary_recon.md) describe —
    they verified the engine opening `patchdynamic0.megapack` with Process Monitor.

  Note their premise — *"Saboteur.exe is SecuROM-packed, so static analysis is useless"* — is true only of
  the **retail/Steam packed** exe they work from; our GOG copy is the SecuROM-**unpacked** twin (non-`.text`
  sections byte-identical), so our decomp reads the engine-side loaders theirs cannot. A concrete thing worth
  sharing back.

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
**Update 2026-07: no longer fully extract-only** — the community-shared "Saboteur Toolkit" (above) now
writes the **texture** path (megapack/ALBS/DTEX) into additive patch megapacks, and independently confirmed
the **built-in override mechanism**: the engine mounts `patchmega0.megapack` / `patchdynamic0.megapack` /
`patchpalettes0.megapack` at ~1000× base priority (hash wins) — a clean, no-surgery mod path (see
[`binary_recon.md`](binary_recon.md)). That closes the texture-writer gap from their side.

Where our clean decomp still uniquely helps: (a) the **engine-side loader semantics** behind the crash-rules
they found empirically (e.g. the interleaved-mip walk that crashes on desync — readable in our unpacked
`.text`, opaque in their SecuROM-packed exe); and (b) **writers for the other asset classes** — mesh, Havok
anim, audio — that remain read-only or unhandled community-wide. Contribution shape shifts from "build a
texture writer" (done) to "explain the format from the binary + extend write support beyond textures."

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
4. **Engine-side loader semantics + non-texture writers** — the texture writer + patch-layer now exist on
   the community side (§4); our unique add is explaining the format from the clean binary and extending
   write support to mesh/anim/audio. Then **hash resolution** and **material semantics** as incremental
   strengthening.

## Sources
- SaboteurToolset — https://github.com/PredatorCZ/SaboteurToolset
- SabTool — https://github.com/BoBoBaSs84/SabTool
- LuapExplorer — https://github.com/gamelaster/LuapExplorer
- sab-lua-api — https://github.com/saboteur-team/sab-lua-api
- FileConvTool — https://github.com/ArcanePlant/FileConvTool
- Saboteur-GameTemplates-Helper — https://github.com/Daniel-McCarthy/Saboteur-GameTemplates-Helper
- Saboteur Team wiki — https://saboteur-team.github.io/wiki/
- Nexus/ModDB Saboteur — https://www.nexusmods.com/games/thesaboteur , https://www.moddb.com/games/the-saboteur
- Pre-release build (2008-05-20) — https://www.mediafire.com/file/t7mh5jiy7bq2g8m/The_Saboteur_(2008-05-20).7z/file
- Mission catalog (community sheet) — https://docs.google.com/spreadsheets/d/12oW0kqT4ZXQDrv0Q9z9yCwqTrjSbKcyIbkB-hAwMBlw/edit
