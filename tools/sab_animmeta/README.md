# sab_animmeta — AP0L `ANIM` block track→bone binding

Parses the `ANIM` metadata block of *The Saboteur* (2009) `Animations.pack` and emits,
per main-blob clip, the ordered per-track bone binding needed to rig a decoded Havok
spline clip (`tools/sab_havok65`) onto a named skeleton (`tools/sab_skeleton`).

```
sab_animmeta <Animations.pack> [skeleton.json] <out.json>
```

`skeleton.json` is an `sab_skeleton` dump (e.g. `output/skeletons/CH_AL_SeanDevlin.json`).
When supplied, per-track bone **indices** are resolved to bone name-hashes and each clip is
flagged as a subset (preview candidate) of that skeleton.

## Confirmed ANIM layout

The pack is `"AP0L"` then FourCC-tagged blocks. The **first** block is `ANIM` (file bytes
`MINA`). Its body (SaboteurToolset `animpack/anim_extract.cpp::ProcessANIM`, spike
`BinReaderRef`; verified against retail bytes):

```
u32 recordCount                              // 3463 retail
record[recordCount] {
    u32  id                                  // pandemic-hash seed
    u8   unk4 (bool)
    u8   streamed (bool)
    u32  nameLen ; char name[nameLen]        // ReadContainer(std::string) => u32 length
    f32  duration
    if !streamed: u32 boneCount ; u32 bones[boneCount]   // per-track bone list
    f32  unk0[8]
    u8   unk1 (bool)
    u32  n2 ; ANIMStruct0 unk2[n2]           // ANIMStruct0 = u32[10]   (40 B each)
    u32  n3 ; ANIMStruct1 unk3[n3]           // ANIMStruct1 = u32,u8(null),f32[2],u32 (17 B each)
}
u32 numAnims ; u32 hkSize                    // then the concatenated animations.hkx blob
```

Walking `recordCount` records lands the cursor **exactly** on the `numAnims`(=2214)/
`hkSize`(=0x80FB00) pair immediately before the first Havok magic `57 e0 e0 57` at file
`0xDECE1` — a decisive structural self-check. The `streamed==false` records (2214) map 1:1,
in order, to the 2214 `hkaSplineCompressedAnimation` objects in the main blob; streamed
records carry no bone list (their sub-animations live in the `SSP0` block).

## The `bones` field is polymorphic

* **biped clips (2155/2214)** store per-track bone **indices** into the shared biped
  skeleton (values `0..190`; `0xFFFFFFFF` = unbound / no-bone sentinel).
* **exotic-skeleton clips (59/2214: Cow, Chicken, bird)** store per-track bone
  **name-hashes** (`pandemic_hash` of the bone name) directly.

In both cases `len(bones) == numTransformTracks`. Indices resolve to hashes through the
character skeleton's bone-index order; the resulting names form a valid ordered biped
hierarchy (`GlobalSRT, Bone_Root, Bone_Hips, Bone_LThigh, Bone_LShin, ...`), and the
hash-style clips independently reference the same bone hashes (`GlobalSRT`, `Bone_Chest`,
`Bone_Head`), cross-confirming the ordering.

## Ground-truth oracle

`len(bone_ids) == numTransformTracks` (read from each spline anim at `obj+0x10` in the
carved Havok blob). Retail result: **2214/2214** clips match.

## Output (per clip)

```json
{
  "index": 0, "id": "0xFDC86003", "name": "crowd_walk_push_L_02",
  "duration": 0.833333, "num_tracks": 64, "num_transform_tracks": 64,
  "track_count_matches": true, "streamed": false,
  "flags": {"unk4": false, "unk1": true},
  "bone_repr": "index",
  "bone_ids":   [0, 1, 2, ...],                 // raw stored values
  "bone_hashes":[3418483537, 4210013062, ...],  // resolved name-hashes; null = unbound
  "subset_of_skeleton": true
}
```

std-only Rust, no external crates.
