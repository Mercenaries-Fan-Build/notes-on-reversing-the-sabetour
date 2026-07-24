# Replace a texture

The full chain, from a retail archive to an installed override. This is the workflow most mods are
built on — a reskin, a custom icon, a retextured vehicle all follow it.

**Tools:** `sab_pack` → `sab_dtex` → (`sab_sbla`) → `sab_pack` → `sab_validator`
**Time:** minutes. **Reversible:** delete one file.

> **Status:** both paths verified end-to-end against retail, each ending in `sab_validator` with
> 0 fatal. §4a is the single-texture case, §4b the multi-texture one.

---

## 0. Back nothing up, overwrite nothing

You will never modify a file in your game install. The output is a **new** `patch*.megapack` that
mounts *above* the base archive. Uninstalling a mod = deleting it.

## 1. Find the texture

Textures live inside `ALBS` sub-packs, which live inside `.megapack` archives. Two levels down.
UI/icon art is generally in `Palettes0.megapack`; world and character art in `Dynamic0.megapack`.

```sh
GAME="C:/GOG Games/The Saboteur"

# level 1 — which megapack entry?
sab_pack list "$GAME/Global/Palettes0.megapack" | less

# pull that entry's sub-pack out
sab_pack extract "$GAME/Global/Palettes0.megapack" #57 icons.sub

# level 2 — which texture inside it?
sab_dtex list icons.sub
```

Note the entry number (`#57`) — step 4 needs it.

**First, find out which kind of sub-pack you have** — the two cases take different paths in step 4:

```sh
sab_sbla list icons.sub
```

* `empty directory` (exit 1) → **single-texture** sub-pack. `#57` is one of these: it is a 32-byte
  `ALBS` header followed by one DTEX and nothing else. Use §4a.
* a directory listing → **multi-texture**. Use §4b.

> ⚠️ **`sab_dtex list` and `sab_sbla list` do not share an index space.** On a multi-texture pack the
> counts differ by one: the **lead texture is stored in the MIDDLE region and has no directory
> record**. On entry `#100`, `sab_dtex list` shows 8 textures but `sab_sbla list` shows 7 records, and
> directory record `#0` is the *second* texture. Never pass a `sab_dtex` position to `sab_sbla`.
>
> Map by hash instead — a record's `hash` field is `pandemic_hash(textureName)`:
>
> ```sh
> sab_gametemplates hash DET_Medium256_NM     # -> 0xA6DCD477  == record #0's hash
> ```
>
> The lead texture's hash equals the sub-pack's own `name_crc` (shown in the `sab_sbla list` header),
> which is how you identify it.

## 2. Get the texture out, edit it

```sh
sab_dtex carve   icons.sub MyIconName my_icon.dtex   # by name, from the sub-pack
sab_dtex extract my_icon.dtex my_icon.dds            # DTEX -> DDS
```

Edit `my_icon.dds` in Photoshop (with the Intel/NVIDIA DDS plugin), GIMP, or Paint.NET.

**Keep the dimensions, format and mip count the same.** The safest edit is a repaint of the existing
image. Changing the pixel format or dropping mips means changing the DTEX record's shape, which is a
much bigger change than it looks.

## 3. Pack it back into a DTEX

```sh
sab_dtex pack my_icon.dds my_icon.dtex my_icon_new.dtex
```

The third argument is a **template**: the original DTEX, whose header/record shape the new file
inherits. That's what keeps the result engine-loadable without you having to know the format.

> **On byte-identity:** modern zlib cannot reproduce 2009's DEFLATE output, so a repacked texture is
> not byte-identical to retail unless you pass `--preserve`. A recompressed pack is still valid and
> loads fine — the engine consumes the *decompressed* content.

## 4a. Splice it back — single-texture sub-pack

The sub-pack is just the 32-byte `ALBS` header plus the DTEX, so keep the header and append the new
DTEX. No directory exists, so nothing needs rebasing.

```sh
head -c 32 icons.sub > out.sub          # keep the ALBS header
cat my_icon_new.dtex >> out.sub         # append the new DTEX

# build a single-entry override keyed by the base entry's crc
sab_pack patch "$GAME/Global/Palettes0.megapack" #57 patchpalettes0.megapack out.sub
```

`patch` copies the base entry's `crc` automatically. That hash is what the engine looks assets up
by, so your pack answers the same request the base pack would have.

Verified end-to-end on entry `#57` (`TP_BD_Grid01`): repacked DTEX 1489 → 1586 B, resulting override
passes `sab_validator` with **0 fatal**.

## 4b. Splice it back — multi-texture sub-pack

The directory offsets are a running chain — change one blob's size and every record after it moves —
so use [`sab_sbla`](../../../tools/sab_sbla/README.md), which recomputes the whole chain:

```sh
sab_sbla list e100.sub                                     # pick the record (map by hash, see §1)
sab_sbla replace e100.sub 0 my_tex_new.dtex - out.sub      # fixes every downstream offset

sab_pack patch "$GAME/Global/Palettes0.megapack" #100 patchpalettes0.megapack out.sub
```

Pass `-` for `uncompSz` to keep the existing value; it only changes if the image's dimensions,
format or mip count changed.

Verified on entry `#100` replacing `DET_Medium256_NM` (46 562 → 47 114 B, delta +552): passes
`sab_validator` with **0 fatal**.

> **If you used `sab_sbla replace` before 2026-07-24, re-make your mod.** It placed every blob
> `dir_end` bytes too early, clipping the preceding asset — the give-away being a validator FATAL
> naming a texture you never touched. Fixed; see the tool README for the evidence. Streamblock
> (`flags=0x3C`) sub-packs are still unverified for splicing and now warn.

## 5. Validate, then install

```sh
sab_validator patchpalettes0.megapack
```

Exit code 0 and no FATAL findings means the mount path will accept it. **Do this before every
launch** — the validator is calibrated to 0 false positives on the `Global/` packs, so for a texture
mod a FATAL is a real defect, not noise. (That calibration does *not* extend to every retail archive:
`France/BelleStart0.kiloPack` yields 96 known false positives. See the
[validator README](../../../tools/sab_validator/README.md).)

Then copy it into `<game>/Global/`:

```
C:\GOG Games\The Saboteur\Global\patchpalettes0.megapack
```

Patch packs mount at priority `0x18704`, above the base pack's `100`.

---

## Variant: wiring a brand-new icon

A new icon isn't referenced by anything yet. Templates reference a texture **by
`pandemic_hash(textureName)`**, so you connect the two by hash:

```sh
sab_dtex list icons.sub                       # confirm the name you packed under
sab_gametemplates hash MyIconName             # -> 0xXXXXXXXX
sab_gametemplates dump GameTemplates.wsd --template 4021
sab_gametemplates set-pair GameTemplates.wsd out.wsd --template 4021 --key Texture --data <hash LE>
```

The GUI does this end-to-end on the **Icons** and **Templates** pages of
[`sab_workshop`](../../../tools/sab_workshop/README.md) — it hashes the name for you and writes the
value as a texture reference.

## When it doesn't load

| symptom | likely cause |
|---|---|
| Game loads, texture unchanged | `crc` mismatch — the override isn't answering the same lookup. Re-run `sab_pack patch` against the *correct* base entry rather than hand-picking keys. |
| Crash at load | Run `sab_validator`. A truncated archive or an overrun blob range is the usual cause. |
| Texture is garbage/noise | Sub-pack directory chain is wrong — you spliced without `sab_sbla replace`. |
| Validator FATAL names a texture you didn't touch | You built the mod with a pre-2026-07-24 `sab_sbla`, which placed blobs `dir_end` bytes early and clipped the previous asset. Rebuild with a current binary (§4b). |
| Texture is black or wrong size | The DDS's format or mip count doesn't match the template DTEX. |
