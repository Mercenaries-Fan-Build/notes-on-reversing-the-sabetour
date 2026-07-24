# sab_sbla

Parse, rebuild and **splice** the internal directory of a Saboteur (2009) `SBLA`/`ALBS` sub-pack —
the hash→offset table the streaming loader walks. A megapack entry is one sub-pack, and a sub-pack
usually bundles several assets (mesh LODs, textures, blobs). This is the layer you need when the
asset you want to replace isn't the only thing in its entry.

Format spec: [`docs/formats/sbla_subpack.md`](../../docs/formats/sbla_subpack.md).
Reverse-engineered from the loader `FUN_00658870`, and verified by a **byte-identical
parse→rebuild round-trip over 1042 real sub-packs** (`France/Mega0.megapack`, `Start0.kiloPack`,
`BelleStart0.kiloPack`, `Global/Dynamic0.megapack`) — 0 mismatches.

## Commands

```
cargo build --release

sab_sbla list    <sub.albs>
    Parse header + directory; print every record (hash, offset, comp/uncomp size, flags).

sab_sbla rebuild <sub.albs> <out.albs>
    Parse -> rebuild with recomputed offsets; asserts byte-identical output.

sab_sbla replace <sub.albs> <recIdx> <blob.bin> <uncompSz> <out.albs>
    Swap record #recIdx's compressed blob and fix every downstream directory offset.
    <uncompSz> = the new uncompressed size, or '-' to keep the existing value.

sab_sbla scan    <megapack>
    Rebuild EVERY ALBS sub-pack in a .megapack/.kiloPack and report
    identical / mismatch / non-ALBS. This is the batch oracle.
```

## Why `replace` fixes more than the one record

Directory offsets are a **running chain**: `offset[i] = offset[i-1] + compSize[i-1]`. Change one
blob's compressed size and every record after it is wrong, which is exactly how a hand-edited
sub-pack ends up loading garbage. `replace` recomputes the whole chain:

```sh
sab_pack extract Dynamic0.megapack #123 sean.sub    # get the sub-pack
sab_sbla list sean.sub                              # find the record index you want
sab_sbla replace sean.sub 4 new_texture.zlib - out.sub
sab_pack patch Dynamic0.megapack #123 patchdynamic0.megapack out.sub
```

The blob you pass in must be **already zlib-compressed** — this tool moves bytes and fixes the
directory, it does not compress. `sab_dtex pack` produces a blob in the right shape.

## Limits

- Two variants are handled: the "object" layout (`flags == 0x00`) and the "streamblock" layout
  (`flags == 0x3C`), which differ in directory start and offset base.
- Terrain (`HEI1`) and blueprint/Locator sub-packs use a different layout and are **refused**
  rather than mangled.
- Records with `hash == 0` are section-boundary placeholders: they share the next record's offset
  and contribute no bytes. `rebuild` preserves them exactly.
