# Replace a texture

The full chain, from a retail archive to an installed override. This is the workflow most mods are
built on — a reskin, a custom icon, a retextured vehicle all follow it.

**Tools:** `sab_pack` → `sab_dtex` → (`sab_sbla`) → `sab_pack` → `sab_validator`
**Time:** minutes. **Reversible:** delete one file.

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

## 4. Splice it back and build the override

If the sub-pack holds **one** texture, you can pack the DTEX straight back. If it holds several — the
usual case — the directory offsets are a running chain and must be rebuilt, which is
[`sab_sbla`](../../../tools/sab_sbla/README.md)'s job:

```sh
sab_sbla list icons.sub                                    # find the record index
sab_sbla replace icons.sub 4 my_icon_new.dtex - out.sub    # fixes every downstream offset

# build a single-entry override keyed by the base entry's crc
sab_pack patch "$GAME/Global/Palettes0.megapack" #57 patchpalettes0.megapack out.sub
```

`patch` copies the base entry's `crc` automatically. That hash is what the engine looks assets up
by, so your pack answers the same request the base pack would have.

## 5. Validate, then install

```sh
sab_validator patchpalettes0.megapack
```

Exit code 0 and no FATAL findings means the mount path will accept it. **Do this before every
launch** — the validator is calibrated to 0 false positives on retail, so a FATAL is a real defect,
not noise.

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
| Texture is black or wrong size | The DDS's format or mip count doesn't match the template DTEX. |
