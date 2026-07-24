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

## Fixed 2026-07-24: `replace` used to place blobs `dir_end` bytes too early

Kept here because the failure was invisible to the tool's own oracle, which is worth knowing.

The directory's `offset` field is **relative to `dir_end`**, not an absolute file offset. The parser
reported `model=Abs`, treated it as absolute, and absorbed the difference into a phantom "trailing"
region whose size was *always exactly* `dir_end = 0x20 + records*24`.

`list`, `rebuild` and `scan` could not detect this: they relay every region verbatim, so an
internally consistent but mis-based split still reproduces the input byte-for-byte. **Only
`replace` places bytes, so only `replace` exposed it** — it wrote each new blob `dir_end` bytes
early, clipping the tail of the preceding asset. On `Palettes0` entry `#100`, replacing a record
with a *byte-identical* blob corrupted 46 372 bytes and produced a `sab_validator` FATAL naming
`MN_Global_Wall_A` — the **preceding** texture, not the one replaced.

The correction (`blob_base = dir_end + first`, `model=Middle`) is evidenced by:

* Over every ALBS sub-pack in `Dynamic0` + `Palettes0` + `Mega0` + `Start0` + `BelleStart0`,
  `dir_end + first + span == fileSize` **exactly** in **1080 of 1137** object sub-packs (zero
  trailing). The other 57 have a genuine small footer, and in all of them
  `newTrailing == oldTrailing - dir_end`. Under the old model, **not one** had a zero trailing.
* A **no-op replace is now byte-identical on 430/430** sampled sub-packs across all four archives —
  a direct test of placement, since feeding a record's own bytes back can only reproduce the file
  if the tool reads and writes them at the same offset. It returned `false` before the fix.
* `scan` byte-identity is unchanged (`Dynamic0` 722, `Mega0` 226, `Start0` 12, `BelleStart0` 82 —
  the documented 1042 — with **0 mismatches**). MIDDLE grows by `dir_end` and TRAILING shrinks by
  the same, so the emitted concatenation is untouched.

**Still unverified:** the `flags=0x3C` streamblock variant keeps its distinct `Tail` placement
(`blob_base = EOF - span`). The evidence above covers the object variant; `replace` now prints a
warning when asked to splice a streamblock. Validate those with `sab_validator`.

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

The blob you pass in must **already be in its stored on-disk form** — this tool moves bytes and fixes
the directory, it does not compress. Note that "stored form" is per asset type and is *not* always a
bare zlib stream: for a texture record the stored blob is the **whole DTEX container** (whose mip
streams are internally zlib'd), which is exactly what `sab_dtex pack` emits. `compSize` is the stored
byte length and `uncompSize` is the DTEX's own declared `uncompressedSize` — pass `-` to keep the
latter unless the image dimensions, format or mip count changed.

## Limits

- Two variants are handled: the "object" layout (`flags == 0x00`) and the "streamblock" layout
  (`flags == 0x3C`), which differ in directory start and offset base.
- Terrain (`HEI1`) and blueprint/Locator sub-packs use a different layout and are **refused**
  rather than mangled.
- Records with `hash == 0` are section-boundary placeholders: they share the next record's offset
  and contribute no bytes. `rebuild` preserves them exactly.
