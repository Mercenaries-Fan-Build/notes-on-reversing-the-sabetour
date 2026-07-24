# sab_gametemplates

Read, edit and write The Saboteur (2009) **`GameTemplates.wsd`** (magic `AULB`) — the game's
object-definition layer. Every disguise point, car, weapon, prop, light setting and particle effect
is a named *template* carrying a bag of `{property-hash → data}` pairs. It is where most
gameplay-tuning mods happen.

Format spec: [`docs/formats/gametemplates.md`](../../docs/formats/gametemplates.md).
std-only (no dependencies). Verified against both ground-truth files — the loose
`DLC/01/GameTemplates.wsd` and the 8.2 MB main-game table embedded in
`France/loosefiles_BinPC.pack` @ `0x2732C50` (11072 entries) — each parsing with **exact byte
consumption** and re-emitting **byte-identical** (SHA-256 match).

## Commands

```
cargo build --release

sab_gametemplates list <file>
    List templates: entry index, name, type, pair count (+ marker count).

sab_gametemplates dump <file> [--template N]
    Dump pairs (hash + decoded data). N is the ENTRY index shown by `list`.

sab_gametemplates set-pair <in> <out> --template N (--key NAME | --hash 0xHHHHHHHH) --data HEX
    Replace the data bytes of one pair and re-emit the file.

sab_gametemplates roundtrip <in> <out>
    Parse and re-emit; verifies exact-consume + byte-identical output.

sab_gametemplates hash <string>
    pandemic_hash of a string (little-endian u32, as stored).
```

## Editing a property

Properties are keyed by `pandemic_hash(property_name)`, so you can address one by name:

```sh
sab_gametemplates list GameTemplates.wsd | grep -i jeep
sab_gametemplates dump GameTemplates.wsd --template 4021
# --data is the raw little-endian bytes as stored: 0ad7233c = f32 0.01, 01 = u8 1
sab_gametemplates set-pair GameTemplates.wsd out.wsd --template 4021 --key MaxSpeed --data 0000c842
```

`set-pair` replaces an existing pair's data; it does not add new pairs or resize the template
record beyond what the pair length allows.

## The texture reference

A template references a texture **by `pandemic_hash(textureName)`** — the same key the `ALBS`/`WSTX`
tables use. That is the whole mechanism behind custom icons: pack a DTEX under a name, hash the
name, write the hash into the template's texture property. See
[replace-a-texture](../../docs/tools/workflows/replace-a-texture.md).

## Endianness gotcha

The community "GameTemplates-Helper" displays the pair hash **big-endian**. The engine — and
`pandemic_hash` — use the little-endian value, which is what this tool prints and accepts. If a
hash from another tool doesn't match, byte-swap it.

The GUI equivalent of this tool is the **Templates** page in
[`sab_workshop`](../sab_workshop/README.md).
