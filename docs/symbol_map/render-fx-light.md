# Render, Particle, Light & Fx

The WildStar/Odin visual-effects layer of *The Saboteur*. This document pins the **object-management** half of the subsystem — how explosions, decals, particles and lights are pooled, spawned and torn down — because that half leaves string and structural anchors in the decomp. The **draw/submit** half (Odin shaders, materials, DTEX textures, the render-task job graph) is Odin-layer code with no assert strings, so it needs the RTTI vtable→VA map — which ✅ now exists ([`pc_vtables.tsv`](../../data/symbol_map/pc_vtables.tsv)) but has not yet been applied here (see Gaps).

## RTTI classes owned

Explosions: `WSExplosion`, `WSExplosionBlueprint`, `WSExplosionApplyImpulseFunction`.
Decals: `WSDecal`, `WSDecalSystem`, `WSDecalBlueprint`, `WSDecalAttachObject`, `WSAOEDecal`, `WSStrikeDecal`.
Particles: `WSParticleInfoData`, `WSParticleCluster`(+`Blueprint`), `WSParticleEmitter`, `WSParticleObject`, `WSParticleEffectBlueprint`, `WSParticleEffectSpawner`, `WSParticleRender` (PblSingleton), `WSPhysicsParticle`, `WSPhysicsParticleEffect`, `WSPhysicsParticleBlueprint`.
Lights: `WSLight`, `WSAttachableLight`, `WSLightHalo`, `WSAttachableLightHalo`, `WSLightVolume`, `WSLightVolumeManager`.
Renderables/gfx: `WSSimpleRenderObject`, `WSSceneRenderable`, `WSModelRenderableBlueprint`, `WSFoliageFxBlueprint`, `WSGfxSubsystem`.

## Lua API surface

`Util.CreateExplosion(sBlueprint,x,y,z)` and the `Render.*` namespace drive this subsystem from script. Observed in the Lua corpus: `Render.StartFX(hLocator,"0FX_Dust01_Ceiling",nil)` (BASE_LaVillette.lua:115), `Render.CameraShakeExplosion(x,y,z,15,10,60)` (BASE_LaVillette.lua:102), `Render.FadeTo` / `Render.FadeScreen` (WRAPPER_Event.lua). Additional bindings (names only, backends not yet pinned): `EndFX`, `SetFXTime`, `VehicleStartFireEffect`, `VehicleStartSmokeEffect`, `StartHighlight`/`StopHighlight`, `ToggleLights`, `TurnHeadlightsOn/Off`, `EnableLightning`/`EnableLightningFlash`/`SetLightningFlashParams`, `SearchlightEnableLights`/`SearchlightSetTarget`, `HUDAddGroundDecal`/`HUDRemoveGroundDecal`, `FocusPtSetTexture`.

## The explosion pipeline (high confidence)

A fully cross-linked chain, anchored by the only two `WSExplosion` assert strings in the dump:

| VA | Role | Evidence |
|----|------|----------|
| `FUN_0160f160` | **deferred queue flush** (per-frame) | callers=[] trampoline; drains queue `DAT_01210810` (count `DAT_012107dc`, cap 0x20, stride 0xe dwords) into `FUN_004886b0`, then zeroes the count |
| `FUN_004886b0` | **spawn** (CreateExplosion backend) | allocs via `FUN_0160f480`, writes pos `param_2[0..2]`→+0x24/+0x28/+0x2c, blueprint→+0x34, tail-calls SetupExplosion |
| `FUN_0160f480` | **pool alloc** | free-list of **64 slots × 0xea4 bytes**; pops slot, calls ctor `FUN_00486fc0(1)` |
| `FUN_00486fc0` | **WSExplosion::ctor** | size 267, sole caller is `0x0160f4d5` inside the pool allocator |
| `FUN_00487510` | **WSExplosion::SetupExplosion** | loads assert strings `...\WildStar\Objects\WSExplosion.cpp` and `"WSExplosion::SetupExplosion"` (decomp lines 76711-76712); size 4498 |

The Lua-facing `CreateExplosion` almost certainly appends to the `FUN_0160f160` queue rather than calling `FUN_004886b0` directly (deferred so spawns are batched once per frame).

## Pooled-object systems and the pool registry (high confidence)

`FUN_00dc1700(maxCount, alignment, typeName, objectSize, flag)` is the shared **fixed-block pool registrar** (PblPool-style). Each fx subsystem's constructor builds a small circular free-list and then registers its object pool(s) through it. `FUN_01605580` (a `callers=[]` static-init root) is the **hub** that allocates each manager and stores it in a global singleton:

| Manager ctor | Singleton global | Pools registered (name, size, count) |
|----|----|----|
| `FUN_009d3090` **WSParticleInfoData::ctor** | `DAT_014a9e1c` (0x1058) | `WSParticleInfoData` 0x7c × 1400 |
| `FUN_0098d730` **WSDecalSystem::ctor** | `DAT_0149421c` (0xe0) | `WSDecal` 0x210 × 400 |
| `FUN_009db580` **WSPhysicsParticleEffectSystem::ctor** | `DAT_014aac20` (0xa4) | `WSPhysicsParticleEffect` 0x348 × 64; `WSPhysicsParticle` 0x90 × 1000 |
| `FUN_009f5ea0` **RenderObjectPools::RegisterAll** | (batch static init) | `WSLight` 0x14c×500, `WSAttachableLight` 0x1e8×500, `WSLightHalo` 0x130×200, `WSAttachableLightHalo` 0x150×500, `WSSimpleRenderObject` 0x98×9000 |

These object sizes/counts are directly usable symbol-map facts (e.g. a `WSLight` instance is 0x14c bytes; the engine caps at 500).

## Particle cluster teardown

`FUN_006d8890` = `WSParticleClusterBlueprint::ClusterLOD` release: `InterlockedDecrement` on the refcount at +0x30c, and on reaching zero it walks the primitive array (count at +0x234, stride 0x15 dwords) freeing each through `FUN_0098f250` — proven by the inline assert `...\Particles\WSParticleCluster.cpp` / `"WSParticleClusterBlueprint::ClusterLOD::DestoryPrimitive"` (misspelling is in the shipped binary). `FUN_0098f250` is the engine-wide guarded pool-free helper (30+ callers), the counterpart to `FUN_00dc1700`/pool alloc.

## Gaps / not yet pinned

- **Render/draw path**: `WSParticleRender` (PblSingleton) draw+update, `WSGfxSubsystem`/`WSGfxSubsystemJob`, and the `WSRenderingTask`/`WSShellRenderTask` job graph — resolvable from the vtable→VA map ([`pc_vtables.tsv`](../../data/symbol_map/pc_vtables.tsv)), which now exists; not yet applied here.
- **Shaders/materials**: `OdinShader`, `OdinExMaterialShader`, `Win32VertexShader`/`Win32PixelShader`, `Win32ExShaderBinding` — Odin-layer, no assert strings in this dump.
- **WSAO materials & DTEX textures**: no string/class anchor found in the provided files; likely in an Odin resource module outside this decomp.
- **Lights beyond pool sizes**: `WSLight::Update`, `WSLightVolumeManager`, halo rendering unlocated.
- **Lua binding backends**: only `CreateExplosion` was recovered (by behavior). `StartFX`, `VehicleStartFireEffect`, `EnableLightning`, `Searchlight*`, `HUDAddGroundDecal`, `FocusPtSetTexture` need the binding name→trampoline table.
- `FUN_009f5ea0` is a merged per-module static initializer (also registers non-render pools like `WallPoint`/`WallSegment`); its name is behavioral, not a recovered symbol.
- RTTI-only, unmapped: `WSExplosionApplyImpulseFunction`, `WSStrikeDecal`, `WSAOEDecal`, `WSFoliageFxBlueprint`, the `WSFxHuman*` body-part classes.

---

## Verification (adversarial pass)

**Verdict: solid** — 13/13 key functions confirmed against the decomp.

**Seams (cross-subsystem):**

- FUN_01605580 (fx singleton root) is NOT fx-isolated: the same static-init function also brings up many non-fx managers before/after the fx ones — FUN_00dbe240(40000,1), FUN_006892b0(1), thunk_FUN_004e5e10(0x100000), FUN_009ae5d0, FUN_00988070 (+ _atexit LAB_00f69a20), FUN_009874e0, and FUN_00996350(1)->DAT_01494368 plus a final 0x48-byte free-list at DAT_014943b0. The fx managers are just three of many co-initialized singletons.
- FUN_00486fc0 (WSExplosion ctor) chains into base-object ctor FUN_0068f490(0) and installs multiple vtables (&PTR_FUN_00f8a640, &PTR_LAB_00f8a638, &PTR_LAB_00f7d0cc) — seam into the shared WSObject/base hierarchy the doc doesn't mention.
- FUN_0098f250 (guarded pool-free) is an engine-wide deferred-destroy shared far beyond fx: callers span streaming (FUN_0162add0/FUN_0162b760/FUN_01614da0), physics/AI (0x005cdb3b, 0x0063e49e), and others (0x007f8cdc, 0x004bc80e, 0x00514f46). Fx teardown rides the same recycler as the rest of the engine.
- FUN_00dc1700 (pool registrar) is shared with non-fx pools too: callers FUN_00dbe240, FUN_00dc1940, and FUN_00989660 register non-fx block types — not an fx-only registrar.
- FUN_004886b0 is reached ONLY via the deferred-spawn drain FUN_0160f160 (its sole caller); the Lua Util.CreateExplosion path must enqueue into DAT_01210810/DAT_012107dc rather than calling the spawn backend directly — the queue producer (Lua binding) is the missing half of this seam.

**Additional gaps / suspected decomp corruption:**

- Two DISTINCT pool-registration mechanisms are conflated under generic 'pool' language. (a) FUN_00dc1700 = descriptor + immediate alloc, used by WSDecal(0x210)/WSPhysicsParticleEffect(0x348)/WSPhysicsParticle(0x90). (b) lazy global-descriptor blocks filled by inline _strncpy into DAT_0132xxxx (guarded by 'if DAT==0'), used by WSParticleInfoData (FUN_009d3090 -> DAT_0132b3cc) AND all the FUN_009f5ea0 light/render types (WSLight/WSAttachableLight/WSLightHalo/WSAttachableLightHalo/WSSimpleRenderObject). So FUN_009f5ea0 and FUN_009d3090 do NOT call FUN_00dc1700 — they only populate descriptor structs; actual allocation is deferred to first use elsewhere.
- FUN_009f5ea0 is heavily under-sampled: size=4379 and it registers many more types than the 5 lights listed, interleaved with them — e.g. WSStreamBlockEntityCommand(0x18,0x12c0) and WallPoint(0x38,0x32). The 'light pool table' label is only a slice of what it does.
- Class-name label 'WSPhysicsParticleEffectSystem' (FUN_009db580) is inferred; RTTI only evidences WSPhysicsParticleEffect / WSPhysicsParticle (the pool strings), not the '...System' manager type. Same soft-inference for 'WSDecalSystem::ctor' though WSDecalSystem does appear in RTTI.
- FUN_00dc1700's param gloss is actually correct once the hidden __thiscall ECX (descriptor 'this') is accounted for: the 5 visible call args map to (count, alignment, typeName, objectSize, flag) exactly — worth noting since the decompiled 6-arg signature looks off at first glance.

**Verifier corrections:**

Clarify FUN_004886b0: it is the DEFERRED-spawn backend, reached only through the per-frame drain FUN_0160f160; the Lua Util.CreateExplosion binding enqueues into DAT_01210810 (count DAT_012107dc) rather than calling FUN_004886b0 directly. FUN_004886b0 also writes flag/impulse fields at +0xe80..+0xe8c (param_3/4/8/9), not just position+blueprint.

Distinguish the two pool paths: FUN_00dc1700 = immediate descriptor+alloc (WSDecal/WSPhysicsParticle/WSPhysicsParticleEffect). FUN_009f5ea0 and FUN_009d3090 use the LAZY global-descriptor pattern (inline _strncpy into DAT_0132xxxx guarded by 'if DAT==0') and do NOT call FUN_00dc1700 — so 'RegisterAll' for lights only fills descriptor tables; allocation is deferred. Note FUN_009f5ea0 registers many non-light types beyond the 5 sampled (WSStreamBlockEntityCommand, WallPoint, ...).

Note FUN_01605580 is a shared engine static-init root, not an fx-only initializer; the three fx singletons (DAT_014a9e1c/DAT_014aac20/DAT_0149421c) are co-initialized with several non-fx managers.
