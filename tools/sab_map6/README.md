# sab_map6

Reader for The Saboteur (2009) **`MAP6`** files — the world/asset registries the boot path and the
world streamer load. Read-only; it prints what a file contains and how many bytes it could account
for.

Format spec: [`docs/formats/map6.md`](../../docs/formats/map6.md). std-only (no dependencies).

## Usage

```
cargo build --release

sab_map6 <global.map | region.map>
```

There are no subcommands — one file in, a decoded dump out. The variant is detected automatically
(a region file carries an ASCII region name right after the magic; `global.map` carries a count).

```sh
sab_map6 "C:/GOG Games/The Saboteur/DLC/01/Global.map"
sab_map6 "C:/GOG Games/The Saboteur/France/FRANCE.map"
```

## Two variants, two confidence levels

| file | loader | state |
|---|---|---|
| `global.map` — the boot-time asset/template registry | `FUN_009f3370` | ✅ **fully decoded**, validated byte-exact (parse cursor lands on EOF, 0 leftover) |
| `<region>.map` (e.g. `FRANCE.map`) — world placement | `FUN_009f75f0` | 📓 **partial** — shares the record core, adds conditional variable-length sub-lists that are only partly decoded |

Every run ends with a validation block reporting bytes consumed vs file size. `EXACT ✓` means the
parse accounted for the whole file; on a region file expect leftover bytes, and the count tells you
how much of the format is still unknown. That number is the honest measure of this reader — treat a
non-zero leftover as "don't trust the tail", not as an error.

Record names are stored as plain strings and are keyed by `pandemic_hash(name)` — confirmed against
the on-disk hashes (`MM_Belle_VIP`, `KnifeThrow`). Sub-entry hashes reference asset/animation names
that are *not* stored in the file, so the tool resolves those against a small built-in dictionary
and prints the raw hash otherwise.

No writer: nothing here modifies a `.map`.
