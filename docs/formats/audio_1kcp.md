# Audio — the `1KCP` Wwise package

The Saboteur's voice/music/SFX ships as **Wwise file-packages** with a custom **`1KCP`** header (magic
`0x50434B31`), not stock Wwise AKPK. Confirmed genuine Wwise from the clean decomp
(`AK::SoundEngine::*` demangled; loader `FUN_0091aad0` @0x0091aad0 checks `!= 0x50434b31`).
No Mercs 2 analog — this is a from-scratch format for this project (Mercs 2 uses PWS/wavebanks).

## `1KCP` layout (little-endian)

```
+0x00  u32  magic = 0x50434B31 ("1KCP")
+0x04  u32  block align (2048)
+0x08  u32  version (2)
+0x0C  u32  bankCount
+0x10  u32  (unused here)
+0x14  u32  streamCount
+0x18  u32  (unused here)
+0x28  record table: 12-byte entries { u32 id, u32 size, u32 offset(absolute) }
        - first  bankCount   records → .bnk soundbanks (magic BKHD; hold embedded SFX wems in DIDX/DATA)
        - next   streamCount records → loose .wem streams (magic RIFF) = the VO / music lines
```

- Streamed `.wem` codec = **Wwise Vorbis** (`fmt` tag `0xFFFF`, 32 kHz, mono/stereo). ffmpeg can't
  decode this; **vgmstream** can (it rebuilds the Wwise codebooks). wem IDs are unique within a pack.
- Banks additionally contain embedded `.wem` (SFX) inside their `DATA` section, indexed by `DIDX`.

## Pack inventory (retail install)

| Pack | Streamed lines | Banks | Notes |
|---|---|---|---|
| `Sound\English(US).pck` | 20,741 | 205 | VO |
| `Sound\French(Canada).pck` | 20,082 | 205 | VO |
| `Sound\German.pck` | 19,914 | 205 | VO |
| `Sound\Italian.pck` | 20,063 | 205 | VO |
| `Sound\Saboteur.pck` | 529 | 342 | SFX / music / ambience (language-neutral) |
| `DLC\01\sound\*.pck` | 20 each | 1 | DLC VO |

`Sound\WWiseIDTable.bin` is a **7,340-string name table** (bank names + `vo_cht_chr_*` per-character
banks + `wp_*`/`vh_*` wildcards) — the key to human-readable naming (see "Open" below).

## Extraction pipeline (built)

`tools/saboteur_audio` (Rust, std-only) parses the `1KCP` index, carves the streamed `.wem`, and
batch-decodes via vgmstream to WAV, then tidies names and writes a `manifest.csv`.

```
cargo run --release -- \
  --game "C:/GOG Games/The Saboteur" \
  --out output/saboteur_audio \
  --vgmstream tools/vgmstream/vgmstream-cli.exe \
  --langs eng,fra,deu,ita --batch 150
```
Flags: `--keep-wem`, `--no-decode`, `--limit N` (test subset), `--batch N`.

**Result:** all 4 languages VO extracted → **80,872 WAV** (100% of decodable streams; only 8 non-RIFF
placeholders skipped), ~12 GB. Named by Wwise ID (`eng_main_<id>.wav`). Output is gitignored; regenerate
from your own install.

### ⚠️ vgmstream batch gotcha
vgmstream-cli overflows a static argv buffer at ~400 file args (starts reading garbage as options,
`unknown option -a/-4`, and silently drops output). **Keep `--batch ≤ 200`** (150 used). A first run at
400 lost ~92% of files with no error surfaced by the exit code.

## Open / follow-up
- **Human names.** wem IDs are Wwise short-IDs. Map to character/mission/line by parsing each bank's
  `HIRC` event graph and cross-referencing `WWiseIDTable.bin`. This turns `eng_main_03845311.wav` into
  something like `Sean/mission3/line12.wav`.
- `Sound\Saboteur.pck` (SFX/music/ambience) and the bank-embedded SFX wems are not extracted yet.
