# World, Water, Terrain & Props

The world/streaming layer of the WildStar/Odin engine: it loads the playable map and its per-region data files, runs the water simulation and reflection rendering, generates far-scene terrain, manages interior teleporting, and constructs/animates the props and generic world-objects the game is populated with. Build tree root for all of these is `wildstar\POV\code\WildStar\Objects\` and `...\Managers\`.

Confidence: **medium**. The data-file loaders, render passes, interior manager, and prop classes are pinned by hard `.cpp` source-path/`sprintf` string anchors. The locomotion grapple/climb classes and the Lua-binding native handlers are **not** pinned (see Gaps) because binding names are not inline strings and this doc predates the RTTI vtable→VA map ([`pc_vtables.tsv`](../../data/symbol_map/pc_vtables.tsv)) and the binding map ([`lua_registration_map.tsv`](../../data/lua_registration_map.tsv)), both of which now exist.

## World / level loading

- **`FUN_009906c0` — World_LoadLevelDataFiles.** The master world loader. Sequentially `sprintf`s and loads every per-world file from a base path: `.map`, `EditNodes.pack`, `.hqpoints`, `.trigs`, `.paths`, `.rndnodes`, **`.waterctrl`**, **`.waterflow`**, `.railway`, `.freeplay`, `.ambush`, plus `Sound\` (decomp lines 823980-824017). World name comes from the `s__France_01111227` global (the game's single Paris/France world).
- **`FUN_0042687b` — World_SceneRenderInit.** Ties render-pass construction (`FUN_00422e90`) to water-plane setup (`FUN_0093a660`); the two water/render callees are its only notable edges.

## Water

The water stack is data-driven from three sources: the per-region `.waterctrl`/`.waterflow` binaries (loaded by the world loader) and a global `water_planes.ini`.

- **`FUN_004d2cd0` — WaterController_LoadWaterCtrlFile.** Loads `.waterctrl`; validates file magic `0x57433037` = `"WC07"`. Backs `WSWaterController`/`WSWaterControllerBlueprint`.
- **`FUN_004d4360` — WaterFlow_LoadWaterFlowFile.** Loads `.waterflow`; backs `WSWaterFlowManager`.
- **`FUN_0093a660` — Water_LoadWaterPlanesIni.** Parses `water_planes.ini`, iterating `water_quad` records and reading `vertex_y`/`vertex_xz`, filling up to 30 (`0x1e`) six-vertex quads — the `WSWater` render planes.
- **`FUN_0093a510` — Water_SetupWaterNormals.** Allocates the `WaterNormals%d` / `WaterNormalsTemp%d` render targets (`WSWaterNormals`).
- **`FUN_00939850` — Water_GetWaterReflectionResource.** Resolves the shared `"WaterReflection"` render resource.
- **`FUN_00937c90` — WaterAction.** Tags an object with `"TtWaterAction"` (`WSWaterAction`).

## Terrain / far scene

- **`FUN_007f1d40` — VeryFarSceneTerrain_BuildHeightMap.** Fetches the `"VeryFarSceneHeightMap"` texture and walks a width×height float grid to generate the low-detail distance terrain mesh (`WSVeryFarSceneTerrain`).
- Terrain and water **render passes** are all named inside **`FUN_00422e90` — World_BuildRenderPasses**: `Begin/Render Terrain Screen Pass`, `VeryFarScene`/`VFSTerrain`/`VFSTerrainBegin`, `Water Textures/Pre/Water/Bucket/Post`, and the full `WaterReflection*` chain.

## Interiors

Interiors are a C++ manager (`WSInteriorManager`) driven by the `InteriorManager.lua` script manager, which holds the per-interior tables (names, teleport/exterior locators, floor ranges — see `docs/saboteur-luacd/src/Managers/InteriorManager.lua`).

- **`FUN_009ca1a0` — InteriorManager_TeleporterMain.** Confirmed by `WSInteriorManager.cpp` + `"WSInteriorManager::TeleporterMain"` (line `0x659`). Steps the teleport state machine, dispatching state ids to `FUN_009cb240`.
- **`FUN_00654d30` — InteriorManager_StreamTick_FireLuaEvents.** Enables/streams interiors and calls into Lua via `FUN_00430320(0,"InteriorManager","LoadInteriorNoTeleport"/"UnloadInteriorNoTeleport",...)`.

## Props & generic objects

Props derive from `WSGenericObject`; blueprints are built by the shared component factory.

- **`FUN_00461590` — ComponentBlueprint_FactoryDispatch.** Type-string dispatch that constructs component blueprints: `WaterController`, `WaterTexture`, `WaterParticleFx`, `InteriorImages`, `LeafSpawner`, `FoliageFx`, etc.
- **`FUN_004b5299` — Prop_OnFinishedSettingUp** (`WSProp::OnFinishedSettingUp`).
- **`FUN_00475390` — CivilianProp_InitUNSynched** (`WSCivilianProp::InitUNSynched`).
- **`FUN_00474e90` — CivilianPropBlueprint_SetProperty** (`WSCivilianPropBlueprint::SetProperty`).
- **`FUN_0048c327` — GenericObject_dtor** (`WSGenericObject::~WSGenericObject`), base of the world-object hierarchy.
- **`FUN_004a89e0` — ObjectAnimator_Update** (`WSObjectAnimator::Update` / `SetAnimatedBoneMatrix`), drives animated-prop bones behind the Lua `EnableAnimatedPropPart`.

## Grapple / climb

Only the **combat** grapple is pinned: **`FUN_0053f510` — HumanStateAttack_AttachGrapplePartner** (`WSHumanStateAttack::AttachGrapplePartner`). The locomotion classes `WSGrapple`, `WSHumanStateClimb`, `WSHumanStateGrapple`, `WSHavokStateClimbing` exist in the RTTI list but left no string anchors — unpinned (see Gaps).

## Lua API surface

World/object: `SpawnObject`, `SpawnObjectOnRoad`, `DespawnObject`, `TeleportObject`, `GetObjectsWithLabel`, `ObjectGetDistance`, `ObjectIsHuman/Vehicle`, `TrigCreateWorldBorderZone`, `EnableAnimatedPropPart`.
Water: `SetWaterLevel`, `ResetWaterLevel`, `RegisterWaterCallback`, `RegisterWaterLoggedCallback`, `IsRagdollInWater`.
Interior: `SpawnInterior`, `AddInterior`, `EnterInterior`, `ExitInterior`, `UnloadInterior`, `IsInteriorEnabled`, `IsPlayerInInterior`, `GetPlayersInterior`, `SetInteriorFloorData`, `LockInteriorDoors`, `AddInteriorLoadCallback`.

## Gaps

- Class-to-ctor bindings for `WSWater`, `WSWaterPhysics(Manager)`, `WSTerrainChunk`, `WSDynamicProp`, `WSAnimatedProp`, `WSAIProp` are not pinned beyond the loaders/factory above — ✅ the RTTI vtable→VA map ([`pc_vtables.tsv`](../../data/symbol_map/pc_vtables.tsv)) now exists and would resolve them; not yet applied.
- **Grapple/climb locomotion** (`WSGrapple`, `WSHumanStateClimb`, `WSHumanStateGrapple`, `WSHavokStateClimbing`) has no surviving anchors — needs the vtable map.
- **Lua binding native handlers** (`SetWaterLevel`, `IsRagdollInWater`, `SpawnObject`, `EnterInterior`, `SetInteriorFloorData`, …) are unresolved: binding names are not inline strings and the registration table was not located.
- **Water/ragdoll physics** (`WSRagdollWaterFlagRemover`, `WSWaterPhysics`) behind `IsRagdollInWater`/`RegisterWaterLoggedCallback` not located.
- `FUN_00461590` and `FUN_00422e90` are large multi-subsystem functions; only their water/interior/terrain slices belong here.

---

## Verification (adversarial pass)

**Verdict: solid** — 19/19 key functions confirmed against the decomp.

**Seams (cross-subsystem):**

- World_LoadLevelDataFiles (FUN_009906c0) is a fan-out seam far beyond water: besides .waterctrl (FUN_004d2cd0) and .waterflow (FUN_004d4360) it also loads .map (FUN_009f75f0), EditNodes.pack (FUN_009eea90), .hqpoints (FUN_009ba760), .trigs -> Triggers subsystem (FUN_00a10ba0 @0x00a10ba0), .paths -> AI path graph (FUN_0082e730 @0x0082e730), .rndnodes (FUN_004baab0), .railway (FUN_0096bc60 @0x0096bc60), .freeplay (FUN_00985da0), .ambush (FUN_008b2680 @0x008b2680), and Sound\ (FUN_00919bd0). Doc treats it as the water/world loader but it is the seam tying World init to Triggers, AI paths, Railway, Freeplay, Ambush and Audio.
- C++->Lua event bridge: interior streaming fires Lua via FUN_00430320(0,"InteriorManager",<event>,...). Load event at 329871 inside stream tick FUN_00654d30; Unload events at 93662/93665, and at 849554/849557 which lives in helper FUN_009bae40 (called 3x by the stream tick at 0x006550b1/0x006555d1/0x00655697), plus a further site 869659/869662. This is the seam into the InteriorManager.lua scripting layer.
- Component factory FUN_00461590 constructs the WaterController blueprint via thunk_FUN_01617550, i.e. it dispatches into the 0x0161xxxx overlay/relocated code region (the factory itself is only reached from 0x0162c2ad(FUN_0162bfa0) in that same overlay). Cross-section seam the doc does not flag.
- Interior teleporter FUN_009ca1a0 drives state machine FUN_009cb240; the full observed state-id set is {8,0xc,0xd,0x11,0x12} (859360-859398), not just the doc's {8,0xc,0x11,0x12} - state 0xd is also dispatched.
- FUN_0042687b render/water init seam confirmed via caller-edge metadata: FUN_00422e90 callers=[0x00426a59(FUN_0042687b)] and FUN_0093a660 callers=[0x00426a43(FUN_0042687b)], and FUN_0042687b itself is reached only from FUN_0041ed5e (0x0041ed65) -> world scene init.

**Additional gaps / suspected decomp corruption:**

- FUN_00937c90 (WaterAction) has callers=[] and FUN_00475390 (CivilianProp_InitUNSynched) has callers=[] - no direct xref recovered, so these are reached only via vtable/indirect dispatch; role inference rests on the embedded 'TtWaterAction' / 'WSCivilianProp::InitUNSynched' literals, not on a call graph. Acceptable but unverified by xref.
- FUN_00937c90 stores 'TtWaterAction' into a TlsGetValue-based ring buffer (a profiler/trace scope marker), not a plain object field. Doc's phrase 'stores into an object slot' is slightly imprecise - it is a task/trace-scope push, still consistent with a WSWaterAction task.
- WSRagdollWaterFlagRemover / IsRagdollInWater have RTTI+class-list presence but no string literal or obvious body located in this pass; the water-logged ragdoll path was not bottomed out (no 'WaterLogged' literal in decomp). Chase in a later pass to bind the Lua RegisterWaterLoggedCallback / IsRagdollInWater to concrete C++ functions.
- Minor line drift in the doc: UnloadInteriorNoTeleport cited at 849572 is actually at 849554/849557 (inside FUN_009bae40), and a third unmentioned site exists at 869662. Non-material.
- No decomp corruption or FID_conflict observed in any of the 19 functions; sizes in the doc (9126/5730/628/4652/2074/4034) all match the header size= fields exactly.

**Verifier corrections:**

Interior teleporter FUN_009ca1a0 state-dispatch set is {8,0xc,0xd,0x11,0x12} (add 0xd). WaterAction FUN_00937c90 pushes the literal 'TtWaterAction' onto a TLS trace-scope ring buffer (profiler marker) rather than a persistent object field. The World loader FUN_009906c0 is not water-specific; it is the master per-world data-file loader that also pulls in Triggers (.trigs FUN_00a10ba0), AI paths (.paths FUN_0082e730), Railway (.railway FUN_0096bc60), Freeplay (.freeplay), Ambush (.ambush FUN_008b2680) and Sound - list these sibling loaders as first-class cross-subsystem edges. UnloadInteriorNoTeleport line refs: 93665, 849557 (in helper FUN_009bae40, called by the stream tick), and 869662.
