# sab_dtex

Read/write The Saboteur (2009) **DTEX** textures (DTEX ⇄ DDS), with byte-faithful repack.
Full byte-level spec + validation: [`docs/formats/dtex_texture.md`](../../docs/formats/dtex_texture.md).

```
cargo build --release

sab_dtex info    <in.dtex>
sab_dtex extract <in.dtex> <out.dds>
sab_dtex pack    <in.dds> <template.dtex> <out.dtex> [--preserve]
sab_dtex list    <in.sub>                 # ALBS sub-pack from `sab_pack extract`
sab_dtex carve   <in.sub> <name> <out.dtex>
sab_dtex roundtrip <in.dtex>              # 3-oracle byte-identity self-test
```

Modding flow: `sab_pack extract` a sub-pack → `sab_dtex carve`/`extract` → edit the DDS →
`sab_dtex pack` → splice back → rebuild a `patchpalettes0.megapack` with `sab_pack`.

Validated on **12,559** real textures (Palettes0 + Dynamic0): 100% decode; 228/228 pass all
three round-trip oracles. Note: modern zlib cannot reproduce the 2009 DEFLATE bytes, so full
byte-identity needs `--preserve`; recompressed packs are valid and engine-loadable. std + `flate2`.
