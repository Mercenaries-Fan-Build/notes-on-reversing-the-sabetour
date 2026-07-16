# World / startup megapack key (`France\Mega*`, `Start0.kiloPack`) — status

**Question:** what is the `path_crc` (megapack bsearch key) for the world/startup packs, so a modder can
register a *new* world asset the way `sab_megapack_key` does for `Global\Dynamic0`
(`pandemic_hash("global\<name>.dynpack")`)?

**Answer: the preimage string is NOT in `Saboteur.exe` and is NOT reproducible from pack data.** It is a
**stored key baked by the offline cooker.** Overriding an *existing* world asset still works (copy its
`path_crc`); registering a genuinely *new* one needs the cooker's string, recoverable only at runtime
(x32dbg) or from the retail map TOC.

## What IS confirmed (decomp VAs)
- **`pandemic_hash` = `FUN_00dc1e20`** @0x00dc1e20 (null-term) / **`FUN_00dc1e60`** @0x00dc1e60 (len-limited).
  Verified byte-for-byte (`hash("ANY")==0xED057225`).
- **Mount** = `FUN_00e34f70` @0x00e34f70; `France\Mega0.megapack` built by `sprintf("%s\%s0.megapack",
  worldDir, "France")` in `FUN_009f4320` (~decomp 886090). Index entry `{u32 crc, u32 index, u32 size,
  u64 offset}`, qsort'd + **bsearch on `crc` only** (`FUN_00e42740` @0x00e42740).
- **`FUN_009ef620` @0x009ef620 receives an ALREADY-computed 32-bit crc** and only dispatches it to the
  right mounted pack — it does NOT build the pre-hash string.
- **The index field 2 (`index`) is NOT `pandemic_hash(name)` for world packs** — it is the streamblock
  numeric **ID** (e.g. `France_Streamblock_1177344` → `index=0x0011F700=1177344`) or a small **ordinal**
  for assets. `pandemic_hash(name)` lives instead at **`ALBS+0x08`** inside each sub-pack (verified:
  `pandemic_hash("VH_OP_Aurora_racer")==0x9C14F36C`).

## Why `path_crc` isn't a string hash (the structural finding)
The streamblock loader **`FUN_009f2df0` @0x009f2df0** reads a `MAP6` (magic `0x4D415036`) container; the
block's identity is a **`PblCRC` read straight out of the map TOC**, not built from a string at load
time. Confirmed by the 360 prototype symbol **`WSStreamTOC(PblCRC, u32,u32,u32, AddonsType)`** — the key
is **stored data**. The `sprintf("%s%d",…)`/`FUN_006586c0(…,"%s\\%s",…)` calls near decomp 885042 build
entity **display-name** strings on objects, NOT the megapack key. So the pre-hash string only ever
existed in the offline cooker/bake tool, which is not in this executable.

## Disproven (rigorously — meet-in-the-middle hash inversion, not just brute force)
FNV-1a is invertible (`0x1000193` odd), so a *definitive negative* is possible:
- **`path_crc = pandemic_hash("<name>.pack")` — DISPROVEN.** `ph("France\0.pack")==0x57130F49` matches
  the ID=0 crc **by coincidence** (short decimal strings have ~5-digit preimages for any target), but
  `ph("France\1024.pack")==0xF7DE2F5A ≠ 0x98D576ED` (the real ID=1024 crc). Self-verified.
  (An earlier draft of this doc reported the `.pack` form as confirmed — that was wrong; corrected here.)
- **Streamblocks:** name forms (`France_Streamblock_{ID}_baked_{K}`, `France_Chunk{ID}_{K}`, zero-pads),
  folders (`Cache\Meshes\<PLAT>\`, `France\`, `global\`, PLAT ∈ {PC,Win32,PCDX9,Xenon,X360,PS3,…}),
  extensions (`.cachedMesh/.mesh/.wsd/.baked/.pack/.megapack/none`), ID as dec/hex/zero-pad/raw-LE/BE and
  `ID/256` — **0 matches** over all combinations.
- **Objects:** the Aurora triple (same name, 3 different `path_crc`) proves `path_crc` is a *per-instance*
  path, not a function of the name; field1 is an index/handle, provably **not embedded** in the hash
  (no `(encoding, tail)` peels the 3 targets to a shared FNV state; prefix/seed/arithmetic-combine all ruled out).

## To recover the preimage (next step)
1. **x32dbg runtime capture (recommended):** hw-breakpoint `0x00dc1e20` (+`0x00dc1e60`), let France stream,
   filter by the routine's return == a target crc (e.g. `0x98D576ED`), read arg1 = the string buffer.
2. **Retail map TOC:** the retail `France.map`/WSD stream-TOC pairs block name → `PblCRC` directly (a
   modder can READ the mapping there; the megapacks themselves are hash-only, no strings).

Both point at the same close as the in-engine load validation — see the x32dbg plan in
`memory/operating-model-and-modding`.
