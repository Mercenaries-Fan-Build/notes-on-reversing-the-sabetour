# Animation (Havok 6.5 edge)

WildStar/Odin's animation stack has three layers that meet at this subsystem edge:

1. **Havok 6.5 core** — compressed-animation sampling (`hkaSplineCompressedAnimation`, `hkaWaveletCompressedAnimation`, `hkaDeltaCompressedAnimation`), skeleton mapping/retargeting, root-motion reference frames, and ragdoll instances. The shipped build still carries Havok's `.\Animation\...`, `.\Mapper\...`, `.\Motion\...` assert source paths.
2. **Puckel (`Pcl`) animator** — WildStar's engine-side wrapper (`PclAnimator`, `PclAnimation`, `PclAnimationSequence`, `PclAnimationStreamer`) that owns a Havok animation, advances time, and produces a sampled pose. Source path `...\wildstar\POV\code\Puckel\Animation\PclAnimator.cpp`.
3. **WS gameplay layer** — `WSHumanAnimationManager`, `WSObjectAnimator`, `WSComplexAnim`, `WSHumanStateRagdoll`, writing poses into `WSSkeletonInstance` and handing off to Havok ragdoll. This is the layer the Lua `Actor.*` bindings drive.

This subsystem *feeds the flagship anim-decode target*: `FUN_00eb7e00` is the spline sample-and-decompress inner loop.

## Lua-driven surface

Scripts drive animation through `Actor.*` bindings (names from `lua_bindings.txt`, usage from the Lua corpus):

- `PlayAnimation` / `PlayAnimationToBone` / `PlayAnimationToPoint` — e.g. `Actor.PlayAnimation(hKessler, "sabotage_clippers_mid_idle")` (`Missions/Act_3_Mission_3.lua`), `Actor.PlayAnimationToBone(hwho, "nazi_climb_up_train", …)` (`Missions/SOE_2_Mission_2.lua`).
- `PlayComplexAnim` → **`WSComplexAnim`** (multi-actor cinematic anim).
- `SetAnimPriority` — e.g. `Actor.SetAnimPriority(self.hPriest, 16)` (`Missions/P1FP_NaziParty.lua`).
- `LoadAnimGroup` / `PreloadAnimGroup` / `UnloadAnimGroup` — e.g. `Util.LoadAnimGroup("belle")` (`InteriorLevels/Belle_Interior.lua`) → `PclAnimationStreamer`/MegaFile.
- Ragdoll: `ActorRagdoll`, `RegisterRagdollCallback`, `ClearRagdollCallback`, `SetFallDamageRagdoll`, `IsRagdollInWater`, `SetDropWeaponWhenRagdolled` → **`WSHumanStateRagdoll`** + `hkaRagdollInstance`.

> Note: without an RTTI vtable→VA map, these binding names are not greppable as strings; the mapping below is by assert-string and caller chain.

## Havok 6.5 sampler edge (the decode core)

The compressed-animation module lives at `0x00eb0000–0x00ebc000`. The **spline** path is fully pinned via the `hkaSplineCompressedAnimationCtor.cpp` assert anchor:

| VA | Proposed name | Role |
|----|---------------|------|
| `FUN_00eb7e00` | `hkaSplineCompressedAnimation::sampleAndDecompress` (core) | Per-track loop: reads control byte, splits into R/T/S quant types (`&3`, `>>2 &0xf`, `>>6`), decodes each channel |
| `FUN_00eb73a0` | spline per-component curve eval (`readNURBSCurve`) | Shared evaluator called by the R/T/S decoders `FUN_00eb7880/7930/79e0` |
| `FUN_00eb8120` | block/frame resolver | Reads block header + interpolant before decompression |
| `FUN_00eb5de0` | `hkaSplineCompressedAnimation::ctor` | Sets vtable `PTR_FUN_0109c8ac`, copies 9 header fields |
| `FUN_00eb7740` | `hkaSplineCompressedAnimation::~dtor` | Frees the 5 block arrays (offsets `0x10/0x13/0x16/0x19/0x1c`) |
| `FUN_00eb50a0` | spline block compressor/builder | Tool-time packer; logs "Number of blocks"/"Compression Ratio" |

Supporting Havok utilities:

- `FUN_00a66dc0` — **`hkaSkeletonMapperUtils::createMapping`** (profile scope + `.\Mapper\hkaSkeletonMapperUtils.cpp` asserts); builds bone correspondence for retarget/ragdoll.
- `FUN_00ebcdc0` — **`hkaTrackAnalysis`** (`.\Animation\Util\hkaTrackAnalysis.cpp`).
- `FUN_00ebb9d0` — **`hkaDefaultAnimatedReferenceFrame`** (`.\Motion\Default\...`); root-motion delta.

## Puckel animator (WS ↔ Havok bridge)

- `FUN_00e3b400` — **`PclAnimator::~PclAnimator`** (confirmed by embedded strings `PclAnimator.cpp` + `"PclAnimator::~PclAnimator"`).
- `FUN_00e3c290` — **`PclAnimator::Advance/Sample`** — per-instance tick; called by `WSHumanAnimationManager::UpdateSharedAnimations` (`0x009c4c71`) and object/vehicle animators.
- `FUN_00e3c070` — **`PclAnimator::SetTime/Apply`** — paired with the above, called immediately before it from the same caller set.

## WS gameplay layer

- `FUN_009c4bb0` — **`WSHumanAnimationManager::UpdateSharedAnimations`** (`.cpp` line `0x393`); walks the shared skeleton, copies bone transforms, calls the PclAnimator methods. The human/crowd pose-sharing update.
- `FUN_004a89e0` — **`WSObjectAnimator::SetAnimatedBoneMatrix`** (asserts `WSObjectAnimator.cpp`); object-side bone-matrix apply.
- `FUN_00953d90` — **`WSComplexAnim::Stop`** (asserts `WSComplexAnim.cpp` line `0x1ae`); backs `PlayComplexAnim`.
- `FUN_00577490` — **`WSHumanStateRagdoll`** (asserts `WSHumanStateRagdoll::TestCollisionWithOthers`, line `0x466`); ragdoll FSM state, the animation→physics handoff.
- `FUN_0162b760` — **`WSSkeletonInstance::~WSSkeletonInstance`** (string-confirmed); the runtime skeleton poses are written into.

## Cross-references

- **Physics/Havok** — ragdoll (`WSHumanStateRagdoll` → `hkaRagdollInstance`, `WSHavokManager`).
- **Scene/Skeleton** — `WSSkeletonInstance`, `WSHumanSkeletonScale`.
- **Cinematics** — `WSComplexAnim` / `PlayComplexAnim`.
- **Streaming** — `PclAnimationStreamer` / MegaFile anim-group load.

## Gaps / open items

- **No vtable→VA map**: Lua-glue entry functions for `PlayAnimation`, `ActorRagdoll`, etc. are not individually pinned; mappings here are by assert-string + caller chain.
- **Wavelet & delta samplers not uniquely pinned**: only SplineCompressed carries a source-path assert. Wavelet/delta decoders are in the same module but need the vtable map; unlabelled large candidates: `FUN_00eb2180`, `FUN_00eb90c0`, `FUN_00eb8590`, `FUN_00ebe0a0`.
- **PclAnimator method names** (`FUN_00e3c290`/`FUN_00e3c070`) are inferred from caller pairing, not in-body strings; which Havok call they wrap (`sampleAndCombine` vs `sampleTracks`) is unconfirmed.
- `FUN_00eb7e00` shows `callers=[]` (vtable-dispatched only); its call site is inferred from structure.
- `hkaInterleavedUncompressedAnimation`, `hkaChunkCache`/`hkaDefaultChunkCache` have RTTI classes but no pinned functions.

---

## Verification (adversarial pass)

**Verdict: solid** — 17/17 key functions confirmed against the decomp.

**Seams (cross-subsystem):**

- FUN_00eb7e00 (sampleAndDecompress) has ZERO direct callers - it is dispatched virtually through vtable PTR_FUN_0109c8ac (set by ctor 5de0 / dtor 7740; also returned at decomp line 1661658). The doc's claim that PclAnimator is 'the WS wrapper around the Havok sampler' has NO direct call-path evidence: nothing in the e3xxxx PclAnimator cluster directly calls the eb7xxx spline sampler. The bridge is inferential (Havok virtual dispatch), not a verified xref.
- FUN_00f227c0 (size 62) is the real seam into block/chunk storage: shared block-data resolver called by BOTH samplers (7e00 at 0x00eb7e7c/0x00eb7e96, 7f70 at 0x00eb7fde/0x00eb7ff7) plus the 0x00eb7c.. cluster. Doc mentions it but never ties it to the claimed hkaChunkCache/hkaDefaultChunkCache classes.
- FUN_00e3c290 (PclAnimator sample) is called by MORE managers than the 4 the doc names: also FUN_009c52d0 (0x009c5995), FUN_00526190 (0x00526441/0x00526493), FUN_0052fd00 (0x00531291) - i.e. additional cinematic/object update paths beyond WSHumanAnimationManager + the three animators listed.
- FUN_004a89e0 (WSObjectAnimator::SetAnimatedBoneMatrix) has a single caller FUN_0099bd00 (0x0099dc8d) - the object-update path feeding it; doc leaves this unnamed.
- FUN_00a66dc0 (createMapping) sole caller is FUN_0058fa80 (0x0058fdda) - the retargeting/mapper entry point; doc names no caller.
- FUN_00eb8120 (getBlockAndFrame) resolves the block index via FUN_00e47360, a generic x87 float-truncation (ftol) helper shared binary-wide (callers include SetHSV/GetHSI) - NOT a time source; the frame-time input arrives on the FPU stack (extraout_ST0), invisible in the signature.

**Additional gaps / suspected decomp corruption:**

- Two distinct translation decode paths that the doc conflates: in FUN_00eb7e00 the R/T/S decoders are 7880(&3)/7830(>>2&0xf)/7930(>>6), and 7830 does NOT call readNURBS 73a0 (it calls FUN_00eb72c0). readNURBS 73a0's translation caller is 79e0, which is used ONLY by the OTHER sampler FUN_00eb7f70 (the translation-only path, mask *pbVar2 & 0xf9 / >>1&3). So 73a0's three callers 7880/7930/79e0 span two different sample loops, not one.
- FUN_00eb8120 and FUN_00eb7f70 decomp are lossy about the frame-time float (x87 extraout_ST0, 'Globals overlap smaller symbols' warning) - not corruption but the block-index math reads a value absent from the C signature; worth a caveat in the doc.
- PclAnimator method names FUN_00e3c290 'Advance/Sample' and FUN_00e3c070 'SetTime/Apply' are inferential (cluster-adjacency to the string-proven dtor e3b400 + caller-order in 9c4bb0), NOT string-proven; body of e3c290 is actually a weighted linked-list interval walk calling FUN_00e3b800 per node.
- FUN_00577490 is only string-proven as the ragdoll routine WSHumanStateRagdoll::TestCollisionWithOthers (line 0x466); the doc's broader 'FSM state update' label is a mild overreach - the assert covers only the collision-test sub-op.

**Verifier corrections:**

- FUN_00eb5de0 (ctor): copies SEVEN header fields, not nine — param_1[2..8] from param_2+8..+0x20 (offsets +8,+0xc,+0x10,+0x14,+0x18,+0x1c,+0x20). It also sets a base vtable &PTR_LAB_0109c2f4 first, then overwrites with the spline vtable &PTR_FUN_0109c8ac.
- FUN_00eb7e00 (sampler) has no direct callers; it is a virtual (vtable PTR_FUN_0109c8ac). The empty caller lists on 7e00 / 7f70 / 5de0 / 9c4bb0 / ebb9d0 / 0162b760 are all virtual/factory dispatch, NOT decomp corruption.
- Downgrade the "PclAnimator is the WS wrapper around the Havok sampler" claim to an inference: no direct e3xxxx→eb7e00 call exists in the decomp.
- FUN_00e3c290 caller set is broader than stated (add FUN_009c52d0, FUN_00526190, FUN_0052fd00).
- FUN_00577490 label should read "WSHumanStateRagdoll::TestCollisionWithOthers" (the only proven method), not a generic "FSM state update".
- FUN_00eb8120: the "frame" input comes via the x87 FPU (ftol helper FUN_00e47360), not a params-visible value; FUN_00e47360 is a generic float-truncate, not animation-specific.
