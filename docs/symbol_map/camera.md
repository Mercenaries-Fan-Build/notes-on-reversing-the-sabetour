# Camera

The WildStar/Odin ("POV") camera subsystem. It is data-driven: camera behavior is authored as **blueprints** (`WSCameraSettings*`, `WS*CameraTransition*`, `WSSlowMotionCameraBlueprint`) that are instantiated by the generic blueprint factory, then consumed at runtime by **`WSGameCamera`** (per-frame update + settings/transition blend), the **camera-shake** system, the **slow-motion / bullet-time** camera, the **cinematics** camera, and an async **camera collision job**.

RTTI reports ~21 camera classes (grep `Camera|Cam` in `data/ws_engine_classes.txt`).

## Evidence base
- **Blueprint factory** `FUN_00461590` (size 9126) is a giant type-name dispatcher. Lines 56052-56129 branch on `FUN_00db7e10("SlowMotionCamera" | "CameraSettings" | "GroupCameraSettings" | "CameraSettingsMisc")` plus the transition names, each allocating a fixed `sizeof` and calling a distinct constructor. This is the one place every camera blueprint is built, and it pins each ctor by string + size:

  | Type-name string | sizeof | ctor | Class |
  |---|---|---|---|
  | `CameraSettings` | 0x164 | `FUN_0046e9c0` | `WSCameraSettingsBlueprint` |
  | `GroupCameraSettings` | 0x180 | `FUN_0048e000` | `WSGroupCameraSettingsBlueprint` (calls the CameraSettings ctor) |
  | `CameraSettingsMisc` | 0x5c | `FUN_006cdf70` | `WSCameraSettingsMisc` |
  | `SlowMotionCamera` | 0xc4 | `FUN_016314d0` | `WSSlowMotionCameraBlueprint` |
  | `ElasticTransition` | 0x8c | `FUN_00472970` | `WSCameraTransitionBlueprint` (base; also called by the 3 below) |
  | `AnimatedTransition` | 0xa4 | `FUN_00466d50` | `WSAnimatedCameraTransitionBlueprint` |
  | `GroupTransition` | 0x90 | `FUN_00466ed0` | `WSGroupCameraTransitionBlueprint` |
  | `ScopeTransition` | 0xb0 | `FUN_00467020` | scope variant of `WSCameraTransitionBlueprint` |

  The inheritance is visible in the call graph: `FUN_0048e000` (Group) calls `FUN_0046e9c0` (base CameraSettings), and all three transition ctors call the base `FUN_00472970`.

- **`WSGameCamera` runtime** clusters at `0x0067xxxx`:
  - `FUN_00671ae0` — per-frame **Tick**; runs update `FUN_006732c0`. ⚠️ **REFUTED 2026-07-24:** ~~then apply `FUN_00671b90`~~ — `FUN_00671b90` is **never called here** (it is not referenced anywhere in `FUN_00671ae0`'s body, and its own header lists `callers=[]`). `FUN_00671ae0` is a 5-case switch on `*(this+0x2c)`.
  - `FUN_00671b90` (2835) — **ApplySettings**; constructs a `WSCameraSettings` (`FUN_0046e9c0`) and blends transitions (`FUN_0067aee0`).
  - `FUN_006732c0` (4359) — **Update** leaf.
  - `FUN_0067aee0` (428) — shared **transition/settings blend**, also used by the slow-mo runtime.

- **Camera shake**: `FUN_0067a5c0` plays `FUN_00db7e10("Sound_Camera_Shake")` (line 351243). `FUN_00678e20` computes a distance-attenuated magnitude `((_DAT_00f7bf80 - dist)/_DAT_00f7bf80)` into camera field `+0x1448` then fires the shake — matching Lua `Render.CameraShakeExplosion(x,y,z,radius,...)`, which is called all over the mission scripts (e.g. `BASE_LaVillette.lua:102`, `Act_3_Mission_3.lua:1335`). `FUN_00677c69` is the per-frame shake integrator.

- **Slow-motion (bullet-time) camera**: `FUN_01631380` loads the `SlowMotionCamera_Default` blueprint (line 1760304) and applies it via `FUN_0067aee0`. Gameplay driver `FUN_0050c010` selects `SlowMotionCamera_Default` vs `SlowMotionCamera_Melee` (lines 152849/152852) for the kill-cam. Fronted by Lua `StartSlowMotionCamera`.

- **Cinematics camera**: `FUN_0094cc50` / `FUN_0094cd80` carry the string anchors `WSCinematicsManager::StartCinematicsCamera` / `StopCinematicsCamera` (lines 782096/782142). ⚠️ **REFUTED 2026-07-24:** they do not ~~toggle~~ the camera-active bit at `+0x312` — **Start only *tests* it** (`& 0x20`), while **Stop clears it** (`& 0xdf`). Nothing here sets it; the setter is elsewhere.

- **Camera collision job**: `FUN_009a57e0` registers the async job named `"CameraColJob"` (line 837622) with vtable `&PTR_PTR_011c58f8` into the job scheduler — RTTI `WSCameraCollisionJob` (camera-vs-world ray collision; see also `WSCameraRayCastCollector`).

## Lua API surface
From `data/lua_bindings.txt`: `CameraShakeExplosion` (exposed as `Render.CameraShakeExplosion`), `StartSlowMotionCamera`, `FocusPtSetForceCameraFocus`, `FocusPtGetForceCameraFocus`, `GetPointInViewOnRoad`. In the corpus, `Render.CameraShakeExplosion(x,y,z, mag, a, b)` is the dominant call (mission/destruction scripts); the focus-point and slow-mo bindings are declared but rarely scripted.

## Cross-references
Blueprint/`WSFactory` construction (`FUN_00461590`, `FUN_00db7e10` type interning); Cinematics (`WSCinematicsManager`, `WSCinemaElement`); the job scheduler (`CameraColJob` alongside `HavokStepJob`); audio (`Sound_Camera_Shake` -> `FUN_0091ae20`); player/combat (kill-cam slow-mo).

## Gaps
- ✅ **The RTTI vtable→VA map now exists** ([`pc_vtables.tsv`](../../data/symbol_map/pc_vtables.tsv); `WSGameCamera` has 181 slots), but this doc predates it: the `WSGameCamera`/`WSCameraSettings` identities below are still inferred from the `0x0067xxxx` cluster + the `Sound_Camera_Shake` string + the CameraSettings-ctor call, not from a vtable. Re-deriving them from the map is the open task.
- Lua binding **thunks** (`CameraShakeExplosion`, `StartSlowMotionCamera`, `FocusPt*`, `GetPointInViewOnRoad`) are `LuaGlueFunctor` wrappers and are **not** inline strings — only their downstream implementations are pinned, not the binding entry VAs.
- Runtime (non-blueprint) classes are unpinned: `WSCameraSet`, `WSCameraRayCastCollector`, `WSSeatCameraSettings`, `WSShootingCameraSettings`, `WSCinemaCamera`, `WSCinemaCameraShake`, `WSCinemaSplineCamera`, `WSCinemaXSICamera`.
- The `ScopeTransition` ctor (`FUN_00467020`) has no exact matching RTTI class name.
- The ApplySettings-vs-Update split of the two large `WSGameCamera` functions is inferred from the call graph, not confirmed via vtable method slots.

---

## Verification (adversarial pass)

**Verdict: solid** — 21/21 key functions confirmed against the decomp.

**Seams (cross-subsystem):**

- FUN_0067a5c0 (PlayCameraShake) calls FUN_0091ae20 at line 351244 right after FUN_00db7e10("Sound_Camera_Shake") — a direct camera->audio subsystem seam the doc omits (it only mentions the sound-name lookup, not the actual playback call).
- FUN_006778b0 (the ApplySettings helper at +0x0067231c) is ALSO called by the slow-mo runtime FUN_01631230 (0x0163123c) and by FUN_005b5840 (0x005b60d2) — so it is shared between the game-camera and slow-mo clusters, not exclusive to WSGameCamera.
- FUN_0094cc50 StartCinematicsCamera reaches into the render subsystem: under a critical section on field +0x238 it calls FUN_00a12440(0)/FUN_00a126d0 (render/device), plus FUN_0099ac20 (the file/line-tagged assert/log helper). Doc only cites FUN_009bbb20(0x13).
- FUN_00678e20 (explosion shake) is gated on the global check *(DAT_0147db40 + 0x238) == 0 and its callers FUN_0059654a / FUN_005416a0 are weapon-impact/explosion code — a damage/weapons -> camera seam the doc references only as 'impact/explosion code'.
- WSCameraCollisionJob::Register (FUN_009a57e0) callers are FUN_004f8840 and FUN_009b6340 (physics/subsystem init) and it registers via the generic job scheduler FUN_00db86b0 alongside HavokStepJob (FUN_009a58a0, same shape) — camera collision is one job among the physics job set.
- FUN_00422a90 (a small shared math/vector helper) is called repeatedly from FUN_00671b90 (0x672397, 0x672433), FUN_006778b0, FUN_00675ba0 and FUN_00679640 — a common camera-math primitive across the runtime cluster, unmentioned.

**Additional gaps / suspected decomp corruption:**

- FUN_0046e9c0 and FUN_00472970 are size=7 jump-thunks (FUN_0046e9c0 -> FUN_004f8e22 -> ... ; FUN_00472970 -> FUN_0049f091); real ctor bodies are downstream, not at the labeled VAs.
- FUN_00671b90 / FUN_01631380 / FUN_016314d0 all have callers=[] (vtable/thunk-reached); the specific vtable slots are asserted but not shown.
- FUN_0067aee0 is a memberwise struct copy, not a blend/lerp; 'ApplyBlend' label is speculative.
- Factory FUN_00461590 (size 9126) has exactly one caller (0x0162c2ad, overlay region); 'single construction site' is true but reachability hinges on that one entry.

**Verifier corrections:**

FUN_00671ae0 (Tick): CORRECTION — the doc claims it 'calls WSGameCamera::Update FUN_006732c0 (0x00671b50) AND WSGameCamera::ApplySettings FUN_00671b90'. Only the Update call is real. The body is a switch on state field *(this+0x2c): case0->FUN_00672780, case1->FUN_006792e0, case2->FUN_00679470, case3->FUN_00679640, case4->FUN_006732c0 (Update), then FUN_00677820 if state!=0. It does NOT call FUN_00671b90 — and FUN_00671b90 has callers=[] (nothing static calls ApplySettings). Rewrite as: 'Tick is a state-machine dispatcher on field +0x2c selecting one of five per-state handlers (Update FUN_006732c0 is the case-4 handler); ApplySettings FUN_00671b90 is reached via vtable, not from Tick.'

FUN_0094cc50 (StartCinematicsCamera): minor CORRECTION — it does not 'set' the 0x312 camera-active bit; it TESTS bit 0x20 (& 0x20 == 0) and, when bit 0x1 is set, CLEARS a bit at (subsys+0xc8d). It is the Stop function FUN_0094cd80 that clears the 0x312 bit (& 0xdf). String anchor (line 782096), cpp path (782094) and FUN_009bbb20(0x13) are all confirmed.

FUN_01631380 (SlowMotionCamera::Apply): the 'state=4 field' it sets is at offset +0x2c (line 1760320), the same state field the Tick switch (FUN_00671ae0) reads — so entering slow-mo (state 4) routes Tick into the Update path. Worth linking these two explicitly. Confirmed: loads 'SlowMotionCamera_Default' (line 1760304) and applies via FUN_0067aee0 (line 1760317).
