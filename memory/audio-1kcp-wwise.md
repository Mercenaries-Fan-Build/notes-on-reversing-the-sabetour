---
name: audio-1kcp-wwise
description: Saboteur audio = Wwise "1KCP" .pck; tools/saboteur_audio extracted all 80,872 VO lines to WAV (vgmstream batch <=200!)
metadata:
  type: reference
---

Voice/audio = **Wwise file-packages, custom `1KCP` header** (magic 0x50434B31, NOT stock AKPK). Genuine Wwise confirmed in decomp (`AK::SoundEngine::*`; loader FUN_0091aad0 @0x0091aad0).

**Layout (LE):** +0x00 magic; +0x04 block-align(2048); +0x08 ver(2); +0x0C bankCount; +0x14 streamCount; +0x28 = 12-byte records `{id,size,offset(abs)}` — first bankCount = `.bnk` (BKHD, embedded SFX), next streamCount = loose `.wem` (RIFF) = VO/music lines. Codec = **Wwise Vorbis** (fmt 0xFFFF, 32kHz) → needs vgmstream (ffmpeg can't). wem ids unique per pack.

**Counts:** Sound/{English(US),French,German,Italian}.pck ≈ 20k lines each; Sound/Saboteur.pck = 529 streams+342 banks (SFX/music/ambience); DLC = 20 each. WWiseIDTable.bin = 7340 name strings (bank + vo_cht_chr_* per character).

**Tool `tools/saboteur_audio`** (Rust): parse 1KCP → carve wem → vgmstream → WAV → strip `.wem.wav`→`.wav` → manifest.csv. `--langs eng,fra,deu,ita --batch 150`. DONE: all 4 langs = **80,872 WAV** (100% of decodable; 8 non-RIFF skipped), ~12GB, gitignored, named by id.

**★GOTCHA:** vgmstream-cli overflows static argv at ~400 file args (garbage `-a/-4` options, silently drops output) — keep **batch ≤200**. First run at 400 lost 92%. OPEN: human names via HIRC event graph + WWiseIDTable. docs/formats/audio_1kcp.md.
