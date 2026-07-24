# sab_pack

Read and **write** The Saboteur (2009) `.megapack` containers (magic `00PM`) — the archives under
`Global/` and `France/` that hold every model, texture and streamed asset. This is the tool that
turns an edited asset back into something the game will load, via a **patch-override pack**.

Format spec: [`docs/formats/megapack_write.md`](../../docs/formats/megapack_write.md).
std-only (no dependencies). The writer was reverse-engineered from the engine's mounter
`FUN_00e428c0` and verified byte-for-byte against `Global/Dynamic0.megapack` (759 entries).

## Commands

```
cargo build --release

sab_pack list      <megapack> [name_substr]     list entries: #N crc index size name
sab_pack extract   <megapack> <sel> <out.sub>   dump one entry's SBLA sub-pack bytes
sab_pack pack      <in.sub> <crc_hex> <index_hex> <out.megapack>
                                                write a single-entry megapack from a sub-pack
sab_pack patch     <base.megapack> <sel> <out_patch.megapack> [replacement.sub]
                                                single-entry override keyed by the base asset's crc
sab_pack roundtrip <megapack> <sel>             extract -> pack -> re-read; assert byte-identical

<sel> = #N (file order) | crc:0xHEX          (use `list` to find the entry you want)
```

## The override trick (why `patch` is the important command)

The engine looks an asset up by **`crc`** — a hash of the *resource path* the game requests, stored
in the index. It performs no validation of that key against the data. So a pack that carries the
**same `crc` as the base asset** but different bytes resolves first, as long as it is mounted at a
higher priority:

```sh
# 1. pull the asset out of the base pack
sab_pack list    "C:/GOG Games/The Saboteur/Global/Dynamic0.megapack" SeanDevlin
sab_pack extract "C:/GOG Games/The Saboteur/Global/Dynamic0.megapack" #123 sean.sub

# 2. edit sean.sub  (sab_dtex / sab_mesh / sab_sbla splice it back together)

# 3. build the override — crc/index are copied from the base entry automatically
sab_pack patch "C:/GOG Games/The Saboteur/Global/Dynamic0.megapack" #123 patchdynamic0.megapack sean.sub
```

Deploy the result as `Global/patchdynamic0.megapack`. Patch packs mount at priority `0x18704`,
above the base pack's `100`, so the by-hash lookup lands in yours. **Never overwrite the base
pack** — the override path is non-destructive and reversible by deleting one file.

Run [`sab_validator`](../sab_validator/README.md) on the result before launching the game.

## Notes

- Entry data is copied **verbatim**. The ALBS/MSHA/zlib bytes never pass through a
  decompressor here, so nothing can be lost in translation at this layer.
- Data blocks are 2048-aligned, matching every retail pack. The header pad is zero-filled;
  retail fills it with `0xCB`. The engine reads neither.
- `roundtrip` is the self-test: it extracts an entry, rebuilds a pack around it, re-reads it,
  and asserts both the key fields and the sub-pack bytes come back identical.
