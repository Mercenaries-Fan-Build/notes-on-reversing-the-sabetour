# Cinematics

The **Cinematics** subsystem is *The Saboteur*'s cutscene / scripted-sequence driver. A single `WSCinematicsManager` singleton (pointer at `DAT_0147db40`) streams the game's cinematic data packs, resolves a cinematic by name, and plays it as a timeline of ~41 typed **CinemaElement** tracks (camera moves, character animation, FaceFX/lip-sync, subtitles, explosions, fades, teleports, sound/music, post-FX). The mission/controller Lua scripts drive it entirely through the `Cin.*` API.

## Architecture

```
Lua  Cin.PlayCinematic / LoadCinematic / StopCinematic ...
        |  (FUN_0071dbc0, FUN_0071c3b0, FUN_0071dd80, ...  lua_to* marshalling)
        v
WSCinematicsManager  (singleton = DAT_0147db40)
   +0x238  active cinematic instance      +0x312  state/flags
   ctor  FUN_0094ef40 ── loads 4 data packs at boot
   Update FUN_009501d0 ── per-frame: camera + advance active cinematic
   PlayByName FUN_0094f710 ── CRC-hash name, look up in blueprint tree, start or stream-load
        |
        v
WSCinematic instance ── FUN_00945320 fans timeline out to per-element executors
        |
        v
WSCinemaElement subclasses (WSCinemaAnimation, WSCinemaTeleport, WSCinemaFaceFX,
   WSCinemaMotionBlur, WSCinemaExplosion, WSCinemaFade, WSCinemaConversation, ...)
```

The `WSCinematicsManager` singleton is constructed once by `FUN_01609130` (which calls the ctor `FUN_0094ef40`). Every reference to `DAT_0147db40 + 0x238` across the binary is a "is a cinematic currently playing?" gate; `+0x312` holds the render/gameplay-suppression flag bits.

## Data packs (loaded in the ctor `FUN_0094ef40`)

| Loader | Asset | Backing classes |
|---|---|---|
| `FUN_0094af60` | `Cinematics\ComplexAnimations\ComplexAnims.cxa` | `WSComplexAnim`, `WSCinemaAnimation` |
| `FUN_0094c100` | `Cinematics\Conversations\Conversations.cnvpack` | `WSConversation`, `WSCinemaConversation`, `WSCinemaConvLine` |
| `FUN_0094c790` | `Cinematics\Cinematics.cinpack` | `WSCinematic` / `WSCinematicBlueprint` tree |
| `FUN_0094dde0` | `<district>.cinsplines` | `WSCinemaSpline`, `WSCinemaSplineCamera` |

The same four loaders are re-invoked per streamed district by `FUN_0094f3c0`. Localized dialogue is loaded from `Cinematics\Dialog\<English|German|French|Spanish|Italian|Polish|Russian>\` (decomp lines 795722-795743).

## Playback path

`Cin.PlayCinematic` → Lua glue **`FUN_0071dbc0`** marshals `(name, bLoop, sCallback, self, params, bOverrideFade, sMusicLocale)` and calls **`FUN_0094f710(name, 2, callback, 0, loop, fade, &musicCRC)`**. `FUN_0094f710` CRC-hashes the name (`FUN_00db7e10`), searches the manager's blueprint tree under crit-section `+0x80`; if the cinematic is not resident it takes the streaming-load branch `FUN_00950ef0`, otherwise it starts the instance. Each frame `WSCinematicsManager::Update` (`FUN_009501d0`) calls `StartCinematicsCamera`/`StopCinematicsCamera` (`FUN_0094cc50`/`FUN_0094cd80`) and advances the running `WSCinematic`, whose `FUN_00945320` dispatches each due element to its type-specific executor.

## Key functions

| VA | Proposed name | Evidence |
|---|---|---|
| `FUN_0094ef40` | `WSCinematicsManager::ctor` (+ boot asset load) | loads the 4 packs by literal path; only caller = singleton init `FUN_01609130` |
| `FUN_009501d0` | `WSCinematicsManager::Update` | assert string `WSCinematicsManager::Update`; per-frame, callers=[] (vtable) |
| `FUN_0094cc50` | `WSCinematicsManager::StartCinematicsCamera` | assert string (WSCinematicsManager.cpp:0xb07) |
| `FUN_0094cd80` | `WSCinematicsManager::StopCinematicsCamera` | assert string (WSCinematicsManager.cpp:0xb27) |
| `FUN_0094f710` | `WSCinematicsManager::PlayCinematicByName` | CRC lookup + start/stream-load; target of Lua Play/Load glue |
| `FUN_00950ef0` | `WSCinematicsManager::LoadAndPlayCinematic` | not-resident branch of `FUN_0094f710` |
| `FUN_00945110` | `WSCinematic::Stop` | assert string `WSCinematic::Stop` (0x8f7) |
| `FUN_00947860` | `WSCinematic::SetHumansInCinematicAnimation` | assert string |
| `FUN_00945320` | `WSCinematic::Update` (element dispatcher) | 9519 bytes; formats `CinemaSplineObject%d%d`; fans to element handlers |
| `FUN_0094af60` | `WSComplexAnim::LoadPack` (.cxa) | loaded with `ComplexAnims.cxa` |
| `FUN_0094c100` | `WSConversation::LoadPack` (.cnvpack) | loaded with `Conversations.cnvpack` |
| `FUN_0094c790` | `WSCinematic::LoadCinPack` (.cinpack) | loaded with `Cinematics.cinpack` |
| `FUN_0094dde0` | `WSCinemaSpline::LoadSplines` (.cinsplines) | loaded with `%s.cinsplines` |
| `FUN_009582e0` | `WSConversation::Stop` | assert string; high fan-in from teardown |
| `FUN_0071dbc0` | `lua_Cin_PlayCinematic` | arg shape matches `Cin.PlayCinematic(sCin,bLoop,sCb,self,params,bFade,sMusic)` |
| `FUN_0071c3b0` | `lua_Cin_LoadCinematic/PrePlay` | name-only, `FUN_0094f710(name,1,...)` |
| `FUN_0093e720` | `WSCinemaTeleport::Teleport` | assert string (WSCinemaElement.cpp) |
| `FUN_00941440` | `WSCinemaAnimation::StartAnimation` | assert string |
| `FUN_00940e20` | `WSCinemaAnimateObject::StartAnimation` | assert string |
| `FUN_0093ed80` | `WSCinemaFaceFX::SkipToEnd` | assert string |
| `FUN_0093e900` | `WSCinemaMotionBlur::Stop` | assert string |

Additional string-anchored element methods in the `WSCinemaElement.cpp` cluster (0x0093df50-0x00942xxx): `WSCinemaAnimation::SkipToEnd` (`FUN_0093df50`), `WSCinemaObjectMotionBlur::Stop` (`FUN_0093e970`), `WSCinemaAttachObject::CleanupObject` (`FUN_00940f90`).

## Lua API surface

`Cin.PlayCinematic`, `Cin.LoadCinematic`, `Cin.PrePlayCinematic`, `Cin.StopCinematic`, `Cin.PauseCinematic`, plus `SpawnCinematicNode` / `UnloadCinematicNode` / `SetCinematicStreaming` / `IsPlayerCloseToCinematic` / `AllowAttackingDuringCinematics` / `SetTakeDamageInCinematic` (from `lua_bindings.txt`). Real usage lives in `ScriptControllers/CinematicSpawner.lua`, `Modules/SabTaskObjective*.lua`, and the mission scripts (e.g. `Act_3_Mission_3.lua`, `Act_3_Mission_1_E3.lua`). The related **scripted-path / scripted-sequence** space (`Modules/Libraries/ScriptSequence.lua`, `WSAIScriptedPathFollower`, `SetScriptedPath*`) is a sibling driver that shares the "actors locked into a scripted performance" concept but is owned by the AI subsystem.

## Element class inventory (~41, from RTTI)

Camera: `WSCinemaCamera`, `WSCinemaSplineCamera`, `WSCinemaXSICamera`, `WSCinemaCameraShake`. Actors/anim: `WSCinemaAnimation`, `WSCinemaAnimateObject`, `WSCinemaAttachObject`, `WSCinemaObjectUpdateFunction`, `WSCinemaFaceFX`. Dialogue: `WSCinemaConversation`, `WSCinemaConvLine`, `WSCinemaSubtitle`. Post-FX/visual: `WSCinemaFade`, `WSCinemaMotionBlur`, `WSCinemaObjectMotionBlur`, `WSCinemaFX`, `WSCinemaLight`, `WSCinemaBloodSplatter`, `WSCinemaLODDistance`, `WSCinemaShadowQuality`. Movies: `WSCinemaBinkMovie`, `WSCinemaFlashMovie`. Audio: `WSCinemaSound2D`, `WSCinemaSound3D`, `WSCinemaSoundBank`, `WSCinemaMusicState`, `WSCinemaRumble`. World: `WSCinemaExplosion`, `WSCinemaTeleport`, `WSCinemaTimeScale`, `WSCinemaDamageState`, `WSCinemaAttractionPt`, `WSCinemaStreaming`, `WSCinemaLoadBlock`, `WSCinemaUnloadBlock`. Base/mgmt: `WSCinemaElement`, `WSCinemaObject`, `WSCinematic`, `WSCinematicBlueprint`, `WSCinematicDoneEvent`, `WSCinematicsManager`.

## Gaps / caveats

- ✅ **The RTTI vtable→VA map now exists** ([`pc_vtables.tsv`](../../data/symbol_map/pc_vtables.tsv)) — this doc predates it. Element classes below are pinned only where a `WSCinemaElement.cpp` assertion string names the method; the vtable slot each executor occupies is still unverified **here**, but is now resolvable from the map.
- **Binding→VA for the non-Play glue is ambiguous.** `FUN_0071c3b0 / FUN_0071dd80 / FUN_0071de80 / FUN_0071dfe0` are clearly the `Cin.*` family, but the name-registration table sits in a decomp gap (0x0071e70e-0x0071f580) so Load vs PrePlay vs Spawn/UnloadNode can't be split apart. Only `PlayCinematic` (`FUN_0071dbc0`) is high-confidence via argument structure.
- **`FUN_009501d0` (Update) decompiles as raw stack-machine code** (Ghidra lost the locals); only the string-anchored camera/advance calls are cleanly readable.
- `IsPlayerCloseToCinematic`, `AllowAttackingDuringCinematics`, `SetTakeDamageInCinematic`, `SetCinematicStreaming`, `PauseCinematic` exist as bindings but were not individually pinned in this pass.
- `FUN_007082a0` builds an object from a `"CinematicName"` data field (vtable `PTR_LAB_00fdc510`) — probably `WSCinematicDoneEvent` or a blueprint trigger event, owner unconfirmed without the vtable map.

---

## Verification (adversarial pass)

**Verdict: solid** — 22/22 key functions confirmed against the decomp.

**Seams (cross-subsystem):**

- ⚠️ **REFUTED (identity) 2026-07-24 — the seam is real, the name is not.** `FUN_009ccf30` (size=6012, caller `0x0043909f`) **is not** `WSMissionMessengerManager::AttemptDeliveryWithCurrentMessenger`. That string occurs exactly twice in the decomp (lines 863575 and 863582) and **both are inside `FUN_009d0100`** (size=650) — which is what [`mission-objective.md`](mission-objective.md) and `data/symbol_map/pc_symbol_map.tsv` (`0x9d0100 → …AttemptDeliveryWithCurrentMessenger [assert]`) already say. The cited "assertion string at ~861237" is the *header line of `FUN_009ccf30` itself*, not a string; `FUN_009ccf30`'s only quoted string is `"%sdata01.bin"` and it carries no `.cpp` path. Read this bullet as: **an unnamed, save/streaming-adjacent function** directly drives cinematics — it does call `FUN_0094f710(name,2,…)` to PLAY and `FUN_0094cc50()` to start the cinematic camera, which is a genuine seam the doc otherwise omits.
- FUN_0046aee0 (size=3325, callers=[] => vtable-driven) plays a cinematic by a name field at param_1+0x17 via TWO FUN_0094f710(...,2,...) call sites (mode 2 = play). A second non-Lua cinematic trigger the doc's FUN_0094f710 caller narrative ignores; its full caller set is [0x0046b665,0x0046b6ec (FUN_0046aee0), 0x009cd8de (FUN_009ccf30), 0x0071c425 (Lua Load), 0x0071dd66 (Lua Play), 0x00951166 (self/LoadAndPlay)].
- FUN_0094cc50 StartCinematicsCamera is also entered outside Update via FUN_0094cf00 (caller FUN_0048fc50 @0x0048fd71) and FUN_0094cf70 -- a separate 'begin cinematic camera' path (sets flag +0x312|0x20, stores params at +0x2ec/+0x2f0) not covered by the Update-centric description.
- WSCinematic::Stop (FUN_00945110) reads/writes the render/streaming globals of other subsystems: DAT_0143cf14 (+0xc0/+0xc1), DAT_01321b74/78 render context (+0x1200/+0x1204/+0x22c), and calls FUN_0091aef0(0x88c03a16,...) and FUN_00910f80/FUN_00911400 -- audio/FX teardown seams the doc reduces to 'tears down via FUN_0094dd00'.
- WSConversation::Stop (FUN_009582e0) fan-in is dominated by the Conversation subsystem itself (FUN_0095a240, FUN_00959bc0 x2, FUN_009584f0, FUN_009585d0, FUN_009588f0, FUN_00959750, FUN_00959e00, ...), not only cinematic teardown; doc frames it as mainly cinematic-driven.

**Additional gaps / suspected decomp corruption:**

- Undocumented Cin.* Lua glue in the same contiguous registration block: FUN_0071c430 (@0x0071ec55) calls FUN_0094cab0(name) -- almost certainly the Cin.StopCinematic binding (listed in lua_bindings.txt as StopCinematic) but not spot-checked as a key function; FUN_0071de80 (@0x0071efb5) and FUN_0071c490 (@0x0071ec75) are further Cin.* bindings left unmapped.
- FUN_00951270 (the PrePlay/preload target fed by FUN_0071dd80 and calling FUN_00950ef0) is referenced but never given its own header/role verification; the exact Load-vs-PrePlay-vs-node distinction among FUN_0071c3b0 / FUN_0071dd80 / FUN_0071de80 remains unresolved without the binding-name table (doc admits this for one case only).
- Minor path imprecision: the ctor's cinsplines load is _sprintf(...,"%s.cinsplines", s__France_01111227 + 1) -- a district/region-name-prefixed path, not a literal Cinematics\...\*.cinsplines; the per-district reload FUN_0094f3c0 uses "%s%s.cinsplines". Doc's "...cinsplines" glosses this.
- No decomp corruption, garbled bodies, or FID_conflict observed in any of the 22 functions; xrefs (caller lists) are internally consistent with the call sites found in the bodies.

**Verifier corrections:**

FUN_0094f710 is __thiscall: param_1 = WSCinematicsManager `this`, and the cinematic NAME is param_2 (CRC-hashed via FUN_00db7e10(param_2,1) then looked up in the PblTree<WSCinematicBlueprint,PblCRC> via thunk_FUN_0058edd0 under crit-section +0x80); the play/preload MODE is param_3 (checked as (char)param_3=='\x02' for play). The doc's "PlayCinematic(name,2,...)" view is the 7-stack-arg Lua-call perspective (this in ECX); accurate but note name!=param_1 in the true signature. Blueprint container names per RTTI: the "pool" is WSFactory<WSCinematicBlueprint> and the CRC tree is PblTree<WSCinematicBlueprint,PblCRC,PblCriticalSection>; the manager is PblSingleton<WSCinematicsManager> (confirms the single FUN_01609130 init caller). Add the unnamed `FUN_009ccf30` (⚠️ **not** `WSMissionMessengerManager::AttemptDeliveryWithCurrentMessenger` — that is `FUN_009d0100`; see the Seams section) and the vtable-driven FUN_0046aee0 as the two non-Lua entry points that trigger PlayCinematic + StartCinematicsCamera.
