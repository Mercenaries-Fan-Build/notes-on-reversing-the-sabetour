# `sab_poc` — Saboteur modding proof-of-concept bundle

A single crate that holds the in-flight proof-of-concepts for The Saboteur asset **write** path, as
subcommands. It's a deliberate holding pen: each experiment lands here first, and graduates into a
proper tool under `tools/` once its shape is clear. Std + `flate2` only — no wgpu/heavy deps.

```
cargo run --release -- <command> --game "C:/GOG Games/The Saboteur" [opts]
```

| Command | What it proves | Status |
|---|---|---|
| `repack` | Byte-right **texture** replacement: inject a synthetic checker into a slot → patch megapack, reusing the base entry (no global.map edit). Self-verifies by re-reading its own output. `[--out --tex]` | ✅ PASS |
| `repack-audit` | ALBS bundle null-round-trip coverage across every texture bundle | ✅ **921/923** byte-exact |
| `mesh-roundtrip` | Stage 1: parse a **MESH/MSHA** and re-serialize the decompressed body byte-exact. `[--name, default SeanDevlin]` | ✅ PASS |
| `mesh-audit` | Byte-exact MESH re-serialize across every skinned model in `Dynamic0` | ✅ **6529/6529** (278 non-skinned props skipped) |
| `mesh-encode-test` | Stage 2b: decode a Sean part's geometry, re-encode it, decode again — prove the geometry encoder. `[--name]` | ✅ PASS (HD/LB/FX/FM) |
| `gltf-info` | Parse Mattias glTF + bone hash-remap onto Sean's rig. `[--gltf --skel]` | ✅ **59/57/0** |
| `mesh-import` | Stage 2b payoff: synth Sean skeleton + Mattias geometry (remapped bones) → `pmc_hum_mattias.msha`, verified by decode. `[--name donor --gltf --skel --out]` | ✅ geometry+skin verified (in-game TBD) |
| `retarget` | Stage 3: export Mattias as SMSH for the viewer + headless spatial-coherence check (vertex↔bone distance). `[--gltf --skel --out]` | ✅ 99.5% within 0.40 m (visual gate = user) |
| `tex-import` | Stage 4: Mattias PNGs → mipped DTEX (BC1/BC3 by role), verified by decode. `[--gltf]` | ✅ 24/24 within BC tol (worst 2.3/255) |
| `wsao-resolve` | Parse `France.materials` (WSAO) and resolve a material hash → its texture hashes — the engine's real binding. `[--mat 0x…]` | ✅ validated on Sean (head → d/s/n/wm) |
| `mattias` | **Full port in one shot**: mesh (MSHA+SMSH) + textures (DTEX by hash) + patched `France.materials` (WSMA/WSTX records). Self-verifies the whole SMSH→WSAO→DTEX chain. `[--gltf --skel --out]` | ✅ 13 mats / 29 DTEX; viewer binds **34/34 submeshes** |

**Textured Mattias in the viewer** — after `sab_poc mattias --out <dir>`, the workshop binds his textures
the engine's way (material hash → WSAO → DTEX), 34/34 submeshes:
```
sab_workshop --mesh <dir>/pmc_hum_mattias.smsh --wsao <dir>/France.materials --dtexdir <dir>/dtex
```

Both write paths hold to the byte level on real game data. The one thing neither self-check can prove is
**in-game load** — `PASS` means "structurally valid + reproduces the decompressed bytes / round-trips
through an independent reader," not "the engine accepted it." That confirmation needs the game running
(drop a `repack` patch into `<game>/Global/` and look for the magenta checker).

## Layout

| File | Role |
|---|---|
| `src/main.rs` | subcommand dispatch |
| `src/pack.rs` | megapack reader — copied from `sab_workshop/src/pack.rs` (do not re-derive) |
| `src/dtex.rs` | DTEX decoder (used to verify writes) — copied from `sab_workshop/src/dtex.rs` |
| `src/albs.rs` | global.map + ALBS parse/rebuild + DTEX (checker) encode + patch-megapack writer (incl. the second `(crc,index)` table) |
| `src/mesh.rs` | MESH/MSHA parse + byte-exact re-serialize (field-level writer, not memcpy) |
| `src/repack.rs` | the `repack` / `repack-audit` commands |

Format details for all of the above: [`docs/formats/archive_and_models.md`](../../docs/formats/archive_and_models.md).
Project context for the mesh work: [`docs/mattias_port_plan.md`](../../docs/mattias_port_plan.md).

## Notes on "byte-exact"

The zlib *container* blobs (DTEX streams, MSHA body/.dat) are re-compressed on write and won't match the
vanilla compressed bytes — compression level is free. The correctness gate is always on the **decompressed**
content, which the engine is what actually consumes. `repack-audit` and `mesh-audit` gate on the fully
uncompressed structures (ALBS bundle bytes; MESH body bytes).

## Graduating a command

When a command is real (in-game confirmed, general enough), lift its module into a standalone `tools/` crate
and delete it here. This crate should stay small; it is scaffolding, not a product.
