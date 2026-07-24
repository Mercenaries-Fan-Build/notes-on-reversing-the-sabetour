# Sound (Wwise)

> ## ⚠️ Every `WSSound*::` method name in this document is INFERRED
>
> There is **not a single `WSSound*::Method` assertion string anywhere in the 54 MB decomp** — a
> `grep -oE '"WSSound[A-Za-z]*::[A-Za-z_~]+"'` over the whole export returns **0 matches** — and none
> of this doc's 22 VAs appear in `data/symbol_map/pc_symbol_map.tsv`, which carries every
> assert-derived name in the repo. The **VAs are solid** (39/39 exist, and the `AK::*` calls inside
> them are real, demangled middleware symbols); the **names are not**. Each
> `WSSoundManager::X` / `WSSoundEmitter::X` label below is a behavioural proposal derived from the
> Wwise call the function wraps and its call-site topology.
>
> This caveat was missing until 2026-07-24: the doc disclaimed only its binding-thunk and vtable VAs,
> and its adversarial pass reported "22/22 confirmed" — which meant *the VAs exist and plausibly
> match*, not that the identities were proven. `WSSoundManager` has only 3 vtable slots, so the RTTI
> map will not promote these either. **Read the names as hypotheses; cite the VAs, not the labels.**

The audio subsystem is a thin WildStar/Odin ("Odin") glue layer over an **embedded Audiokinetic Wwise 2008.x runtime**. The Ghidra decomp retains demangled Wwise symbols (`AK::SoundEngine::*`, `AK::StreamMgr::*`, `AK::MusicEngine::*`, `CAk*` classes), so the boundary between Pandemic code and the licensed middleware is unusually legible. Game code and Lua never call Wwise directly; everything goes through the `WSSoundManager` / `WSSoundBankManager` / `WSSoundEmitter` wrappers in the `0x00917xxx`–`0x0091bxxx` range, which share a consistent `*(this+0x11dc)` "SoundEngine initialized" gate.

## RTTI classes owned

`WSSoundManager` (PblSingleton), `WSSoundBankManager` (PblSingleton), `WSSoundTriggerManager` (PblSingleton), `WSSoundEmitter` (PblCounted), `WSSoundTrigger` (PblCounted), `WSSoundSource`, `WSSoundSourceRef`, `WSSoundBlueprint`, `WSSoundTask`, `WSSoundVehicle`, and the cinematic set `WSCinemaSound2D` / `WSCinemaSound3D` / `WSCinemaSoundBank` / `WSCinemaMusicState`. (Source: `data/ws_engine_classes.txt`, `data/rtti_classes_all.txt`. The three singletons appear as `PblSingleton<WSSoundManager>` / `PblSingleton<WSSoundBankManager>` / `PblSingleton<WSSoundTriggerManager>`.)

The embedded Wwise runtime contributes a large `CAk*` class set (music: `CAkMusicRenderer`, `CAkMusicSegment`, `CAkMusicSwitchCntr`, `CAkMatrixSequencer`, `CAkContextualMusicSequencer`; DSP: `CAkFDNReverbFX`, `CAkReverbFX`; sources: `CAkSrcBankVorbis`, `CAkSrcFileVorbis`; IO hooks: `CAkDefaultIOHookBlocking`/`Deferred`). These are middleware internals, not Pandemic-authored.

## Lua API surface

The `Sound.*` table is the scripting entry point (see **`data/lua_registration_map.tsv`** — not
`lua_bindings.txt`, which lists C++ symbols rather than Lua names — and usage across
`docs/saboteur-luacd/src`):

- **Banks:** `Sound.LoadSoundBank("m_A1M1_inGame.bnk")`, `Sound.ReleaseSoundBank(...)`, `Sound.UnloadSoundBank` (e.g. `Missions/Act_1_Race.lua:31`, `ScriptControllers/BASE_LaVillette.lua:58`).
- **Events on emitters:** `Sound.AttachSoundEvent(hEmitter, "cue")`, `Sound.PlayOwnerlessSoundEvent("A1M1_Race_Start")`, `Sound.StopSoundEvent`, `Sound.BroadcastSound`, `Sound.ActivateSoundEmitter(Handle(...))` / `Sound.DeactivateSoundEmitter` (e.g. `Act_1_Race.lua:411-412`, `Experimental/Soldier_Internal.lua:33`).
- **Music:** `Sound.SetMusicLocale("A1M1_Race")` (2-arg form `SetMusicLocale("m_A1M1_Race","A1M1_start")`), `Sound.ResetMusicLocale()`, `Sound.PlayMusicStab("Success_Stab")`, `Sound.SetEnterMusicOverride` / `SetExitMusicOverride` (e.g. `Missions/Connect_AmbientFP.lua:490`, `Modules/SabTaskMission.lua:558`).

These bindings are `LuaGlueFunctor` template thunks (`?$LuaGlueFunctor0@...?LoadSoundBank@@...` etc. in `rtti_classes_all.txt`); their concrete VAs need the vtable map, but each maps by behavior onto a manager method below.

## Wwise bring-up and per-frame flow

1. **`FUN_009178e0` — `WSSoundManager::InitSoundEngine`.** Creates the stream manager (`AK::StreamMgr::Create`), installs the file-location resolver (`&DAT_0143eed8`), then `AK::SoundEngine::Init` (@`0x00d0c1c0`) and `AK::MusicEngine::Init`; sets `*(this+0x1194)=1`.
2. **`FUN_009186c0` — `WSSoundManager::LoadWwiseData`.** Loads `"%sWWiseIDTable.bin"` (default dir `"sound\\"`), mounts the localized language pack (`FUN_00917a80` → `English(US).pck` / `French(Canada).pck` / `Italian.pck` / `German.pck`) and `Saboteur.pck`, then reads the bank manifest via `FUN_009153d0` (`"SoundBanks.ini"`). Sets `*(this+0x11dd)=1`.
3. **`FUN_00917b20` — `RenderAudioTick`.** `EnterCriticalSection(&DAT_01442910)` → `AK::SoundEngine::RenderAudio()` → leave. The per-frame audio pump.

## Bank management (`WSSoundBankManager`, singleton `DAT_01442928`)

The bank table caps at **64 banks** (`*(this+0x10) < 0x40`) and is guarded by a critical section at `this+0x3f14`. Bank names are resolved to Wwise IDs with `AK::SoundEngine::GetIDFromString` (@`0x00d0ab00`, wide-char).

- **`FUN_009149e0` — `LoadBankSync`** → `AK::SoundEngine::LoadBank(id, memPtr)`.
- **`FUN_00914b30` — `LoadBankAsync`** → `AK::SoundEngine::LoadBank(id, callback, cookie, memPtr)`; keeps a per-bank refcount (`InterlockedIncrement(entry+0x88)`, id at `entry+0x8c`). Default callback `FUN_00913d20`.
- **`FUN_00913df0` — `UnloadBank`** (sole caller of `AK::SoundEngine::UnloadBank` @`0x00d09d70`).

## Emitters and events

**`FUN_0091ae20` — `WSSoundEmitter::PlayEvent`** is the workhorse (hundreds of callers). It lazily allocates a game-object id, registers it (`FUN_009185f0` → `RegisterGameObj`), binds a listener (`FUN_00918630` → `SetActiveListeners`), then posts the event through **`FUN_00918210` — `PostEvent`** (`AK::SoundEngine::PostEvent` @`0x00d0c980`). This is what `Sound.AttachSoundEvent` / `PlayOwnerlessSoundEvent` reach.

Stopping is **`FUN_009182a0`** (posts, or `ExecuteActionOnEvent` with the stop action `DAT_011bc754`) and **`FUN_00918280` — `StopAll`**.

3D placement: **`FUN_00919240` — `SetEmitterPosition`** and **`FUN_00918f50` — `SetListenerPosition`** both **negate the X axis** to convert the engine's right-handed world into Wwise's coordinate frame before calling `AK::SoundEngine::SetPosition` / `SetListenerPosition`; the listener transform is cached at `this+0x1198`.

## Parameters, switches, states, triggers

- **`FUN_00918460` / `FUN_00918420` — `SetRTPCValue`** (by name / by id). Callers at `0x0042cfd0` and `0x005a9f40` look like engine/vehicle RPM feeds → `WSSoundVehicle`.
- **`FUN_009183c0` — `SetSwitch`**, **`FUN_00918540` — `SetState`** (music/global state; backs the `SetMusicLocale` family via `AK::MusicEngine`), **`FUN_00918370` — `PostTrigger`**.
- **`FUN_00918880` — `UpdateAmbientMusicState`**: a small state machine that posts hard-coded Wwise event-id hashes (`0xedeb0f33`, `0xa70fedd4`, `0x89e2f5bb`, `0xb76690fc`) via `FUN_0091ae20` as ambient/music context (`*(this+0xc)`) transitions.

## Object-layout notes (inferred)

`WSSoundManager`: `+0x1178` gameobj-id counter, `+0x1194` engine-init flag, `+0x1198` listener position/orientation, `+0x11dc` "SoundEngine ready" gate, `+0x11dd` "bank data loaded" gate, `+0x13b8` language enum. `WSSoundBankManager`: bank list at `+0x4`, count at `+0x10` (max 64), locks at `+0x3f14` / `+0x3f80`; bank entries carry refcount `+0x88` and Wwise id `+0x8c`. These come from access patterns, not confirmed vtables.

## Gaps

- ✅ **Resolved 2026-07-24:** the Lua glue thunk VAs (`LoadSoundBank`, `AttachSoundEvent`, `SetMusicLocale`, `PlayMusicStab`, …) are in [`lua_registration_map.tsv`](../../data/lua_registration_map.tsv) with `impl_va`/`thunk_va`. In this doc they are still matched to manager methods by behavior rather than by a call edge — and note the manager method *names* remain inferred regardless (see the banner at the top); `WSSoundManager` has only 3 vtable slots, so the vtable map cannot pin them.
- Vtable VAs and confirmed field names for the three managers / emitter / trigger classes are inferred.
- Music-locale name→AK State/Switch table and `WSCinemaMusicState` logic not fully traced.
- Event-id hashes (e.g. `0xedeb0f33`) are Wwise IDs; human names need a `WWiseIDTable.bin` dump.
- `WSSoundTrigger` / `WSSoundTriggerManager` proximity-broadcast functions (behind `BroadcastSound` / `SetRespondToSound`) enumerated but not individually pinned.

---

## Verification (adversarial pass)

**Verdict: solid** — 22/22 key functions confirmed against the decomp.

**Seams (cross-subsystem):**

- Shutdown/teardown counterpart is undocumented: FUN_00919470 @0x00919470 (caller of the init orchestrator FUN_00919bf0/0x00429950) is WSSoundManager::TermSoundEngine - guarded by *(this+0x11dc) it calls AK::MusicEngine::Term (749297), AK::SoundEngine::Term (749298), FUN_00921380, tears down the stream mgr via IAkStreamMgr::m_pStreamMgr vtable+4 (Destroy, 749301), and AK::MemoryMgr::Term (749303). This is the direct inverse of InitSoundEngine and is entirely missing from the doc.
- Wwise plugin/codec registration is missing: FUN_00918180 @0x00918180 calls AK::SoundEngine::RegisterPlugin twice (plugin ids 0x67, 0x73) and RegisterCodec (id 4) at 748466-748474; called from the init orchestrator FUN_00919570 (0x009195a5). This runs during bring-up alongside InitSoundEngine.
- The init orchestrator FUN_00919570 is the shared parent that sequences the whole bring-up: it calls InitSoundEngine (FUN_009178e0 @0x00919599), RegisterPlugins (FUN_00918180), the CollisionMaterials loader (FUN_00917b40 @0x009196f9), and LoadWwiseData (FUN_009186c0 @0x009195b7). The doc lists these leaves but never names their common caller.
- Per-frame sound tick FUN_009197b0 is the shared parent binding three documented leaves together: SetListenerPosition (FUN_00918f50, caller 0x00919985), UpdateAmbientMusicState (FUN_00918880, caller 0x0091986f), and four SetRTPCValueByName calls (FUN_00918460 callers 0x009198db/ff/923/947). The doc documents the leaves but not this update driver.
- Physics<->Sound seam missed: FUN_00917b40 @0x00917b40 loads 'sound\\CollisionMaterials_v1.txt' (748349) into a 32x32 collision-material->sound matrix on param_1; read back by FUN_00918080 @0x00918080 (indexed [material_a*0x20+material_b]). This maps physics collision material pairs to Wwise, and is not mentioned.
- The global singleton pointer DAT_01442928 IS the WSSoundManager instance (used as *(DAT_01442928+0x11dc) engine-ready gate in LoadBankAsync at 746327 and in ~dozens of gameplay call sites e.g. 333838, 459441, 459997). The doc references the per-instance flags but never identifies the singleton global that most subsystems reach the sound manager through.
- The WSSoundEmitter method cluster is broader than the single documented PlayEvent: siblings FUN_0091aef0 (posts via PostEventOrStop path), FUN_0091afc0 (SetSwitch), FUN_0091af60 (PostTrigger), FUN_0091b020 (SetRTPC), FUN_0091b130 (SetPosition->FUN_00919240), FUN_0091ade0/ad40/ad20/adb0/b080/b0e0/b440 all share the same lazy-register pattern (FUN_009185d0 id-mint + FUN_009185f0 RegisterGameObj + FUN_00918630 SetActiveListeners) and forward to the manager leaf wrappers. Only FUN_0091ae20 is documented.
- Emitter game-object id allocator FUN_009185d0 @0x009185d0 (InterlockedIncrement on *(this+0x1178), returns -1 if engine not ready) is the shared id minter used by the entire emitter cluster, not just PlayEvent; the doc mentions it only inline under PlayEvent.

**Additional gaps / suspected decomp corruption:**

- Language/region selector FUN_00918650 @0x00918650 (the input that produces the index passed to GetLanguagePckName; called from LoadWwiseData at 0x009187cc, result stored to *(this+0x13b8)) decompiles garbled: Ghidra emits 'return (bool)2;' / 'return (bool)3;' from a switch on DAT_01111430 reading *DAT_0147db78. It is really returning a 0-3 language enum, not a bool - bool-cast corruption. The doc silently treats the language index as originating in GetLanguagePckName but the actual selection logic lives here and is mangled.
- Three distinct manager flags are easy to conflate and the doc lists them separately without cross-warning: *(this+0x1194) = InitSoundEngine-success flag (set at 748275, also transiently reused/cleared inside SetListenerPosition at 749152/749181 as a 'first-frame' latch); *(this+0x11dc) = engine-ready gate guarding ALL post/set/register wrappers (set to 1 at line 749374, NOT in InitSoundEngine); *(this+0x11dd) = bank-data-loaded flag set by LoadWwiseData (748805). Note 0x1194 is dual-purposed by SetListenerPosition, which is a decomp-reading hazard.
- Minor attribution error to fold in: FUN_009149e0 (LoadBankSync) is documented as 'Matches Lua Sound.LoadSoundBank', but its ONLY caller is FUN_009153d0 (the SoundBanks.ini parser, via _strtok loop at 746692). It is the synchronous startup bank loader, not a Lua entry point. Sound.LoadSoundBank almost certainly maps to FUN_00914b30 (LoadBankAsync), which has many game-wide callers. The Lua attribution should move off the sync variant.
- ~~lua_bindings.txt is a flat name list with NO namespace - the 'Sound.' table prefix in the doc is inferred grouping, not attested in the data. All 16 claimed binding names are present, but the 'Sound.' qualification is an assumption.~~ **❌ RETRACTED 2026-07-24.** `lua_bindings.txt` is prefix-less because it lists **C++ symbols, not Lua names** (256 of 898 differ). `Sound` is a genuine registered Lua table in `data/lua_registration_map.tsv`, so the `Sound.` qualification is attested, not assumed. (This is the same mistake retracted in [`ai-behavior.md`](ai-behavior.md); there it would have inverted two live bindings.)
- AK::SoundEngine::StopPlayingID @0x01374880 and AK::SoundEngine::ClearBanks @0x01375295 exist in the binary but no WSSoundManager wrapper for them is documented; worth a pass to see if StopSoundEvent/bank-reset paths route through them (StopPlayingID would be the natural per-instance stop, vs the documented ExecuteActionOnEvent stop in PostEventOrStop).

