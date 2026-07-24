# Task graph, Managers & Streaming

The engine skeleton of Pandemic's WildStar/Odin build of *The Saboteur*. The runtime is
organised as a fixed **ring of ~22 `*Task` objects** (Game / Rendering / Physics / Sound /
HUD / Streaming / WillToFight / AIPathfinder …) ticked every frame, plus **~77 singleton
`*Manager` objects** that hold subsystem state, all stood up by a small set of boot
**`*Context`** objects. The streaming pipeline (districts → streamblocks → meshes) hangs off
the `WSStreamingManager` singleton and is poked from Lua through the Interior/Load bindings.

> Confidence: **medium**. The Task ring itself is dispatched through vtables and carries no
> source-assert strings, so individual `Task::Run` methods are **not** pinned (see Gaps). The
> streaming/loadsave functions below are anchored by embedded `.cpp` + method-name assert
> strings and are high confidence.

## How it is driven

### From Lua (script surface)
Scripts never touch the Task ring; they drive the **managers** through global bindings:

| Binding | Manager | Corpus evidence |
|---|---|---|
| `LoadStaticENTag`, `IsBlockLoaded`, `IsCustomTagLoaded` | Streaming | `Includes/__UtilFunctions.lua:90,120`; `Managers/RewardsManager.lua:4795` |
| `LoadDynamicNode` | InteriorManager | `Managers/InteriorManager.lua:783`; `Modules/InteriorLevels/*_Interior.lua` |
| `AddInteriorLoadCallback` / `CancelInteriorLoadCallback` / `ClearAllInteriorLoadCallbacks` | InteriorManager | `Managers/StarterManager.lua:622`; `Modules/InteriorLevels/LaVillette_Interior.lua:41` |
| `InteriorLoadSetDisableTeleport` | InteriorManager | `Managers/InteriorManager.lua:931,958` |
| `LoadAnimGroup`, `LoadSoundBank`, `LoadCinematic`, `SetCinematicStreaming` | anim/sound/cinema streaming | `Modules/InteriorLevels/RedOx_Interior.lua:16` |
| `SaveLoad*` family (`SaveLoadSaveCheckpoint`, `SaveLoadLoadCheckpoint`, `SaveLoadCreateAutoSave`, …) | SaveLoadManager | `data/lua_bindings.txt` |

### From the engine (boot → frame)
`FUN_005b8800` (**game bootstrap**, `callers=[]`, called via a Task/Context vtable) installs
the streaming-manager singleton `DAT_01240328 = *DAT_0124061c` and constructs the top module
`"Main_Saboteur_Game"`, then lazily allocates the ~0x15c90-byte world object `DAT_0142d324`.
`WSLoadDisplayManager::Update_Flow` (`FUN_009ccb50`) is the per-frame load-screen state
machine; in one state it calls `WSStreamingManager::SetStartCameraPos` (`FUN_009f7790`) with a
district name literal (`"Paris_1_Mission_1"`) to begin streaming the level.

## Streaming / Load pipeline (pinned)

| VA | Proposed name | Anchor |
|---|---|---|
| `FUN_009f7790` | `WSStreamingManager::SetStartCameraPos` | `WSStreamingManager.cpp` assert string; called from Update_Flow with a district name |
| `FUN_0162e2e0` | `WSStreamBlock::UnloadMeshes` | `WSStreamBlock.cpp` / `UnloadMeshes`,0x4a4; frees a mesh table |
| `FUN_0065fd6c` | `WSStreamBlockUncompressor::CheckForSkipAndSkip` | `WSSTreamBlockUncompressor.cpp` / `CheckForSkipAndSkip`,0xcb |
| `FUN_0070b700` | `WSStreamEvent::LoadEventList` | parses `"Objects"` node, alloc-tagged `WSStreamEvent.cpp`,0xb9 |
| `DAT_01240328` | `WSStreamingManager` singleton (global) | installed at `FUN_005b8800:249442`; deleted at decomp line 24830–24832 (`(**vtable)(1); =0`) |

## Managers (pinned)

| VA | Proposed name | Anchor |
|---|---|---|
| `FUN_009ca1a0` | `WSInteriorManager::TeleporterMain` | `WSInteriorManager.cpp` / `TeleporterMain`,0x659; interior state machine |
| `FUN_009cb240` | `WSInteriorManager::SetInteriorState` | ⚠️ **REFUTED 2026-07-24:** ~~only caller is TeleporterMain~~ — it has **many** callers (7 sites in `FUN_009ca1a0` alone, plus `FUN_009cab40`, `FUN_009cb7c0`, `FUN_009cb3f0`, …). The name remains **inferred**. |
| `FUN_009ccb50` | `WSLoadDisplayManager::Update_Flow` | `WSLoadDisplayManager.cpp` / `Update_Flow`,0x119; drives streaming start |
| `FUN_00654180` | `WSSaveLoadManager::StartReturnToHQ` | `WSSaveLoadManager.cpp` / `StartReturnToHQ`,0x944; restreams world via `DAT_01240328` |
| `FUN_00654d30` | `WSSaveLoadManager::Update` (dispatcher) | size-4652 fan-out over the `WSSaveLoadManager` method cluster (inferred) |
| `FUN_006f96e0` | `WSContext::GetGlobal` (thin accessor) | 7-byte thunk; result stored into world global in bootstrap |

## The Task ring (enumerated, NOT VA-pinned)

From `ws_engine_classes.txt` the fixed task set is: `WSGameTask`, `WSRenderingTask`,
`WSPhysicsTask`, `WSSoundTask`, `WSHUDTask`, `WSStreamingTask`, `WSWillToFightTask`,
`WSSceneManagementTask`, `WSShellRenderTask`, `WSShellSyncedTask`, the AI pathfinder tasks
(`WSAIPathfinderTask` + Static/Dynamic/Stub), and the boot/load tasks (`WSBootupTask`,
`WSMiniBootupTask`, `WSGameSetupTask`, `WSInitLoadTask`, `WSLoadGlobalTask`, `WSPermLoadTask`,
`WSLoadingMonitorTask`, `WSLegalTask`). Boot is sequenced by the Context classes
(`WSApplicationContext`, `WSBootupContext`, `WSMiniBootContext`, `WSLoadingContext`,
`WSIngameContext`). **None of the per-frame `Task::Run` methods could be tied to a VA** — they
are pure vtable dispatch with no assert strings; pinning them requires the RTTI vtable→VA map, which ✅ now exists ([`pc_vtables.tsv`](../../data/symbol_map/pc_vtables.tsv)) but has not been applied here.

## Gaps
- **Task ring unpinned.** No `Task::Run` VA — resolvable from the vtable→VA map ([`pc_vtables.tsv`](../../data/symbol_map/pc_vtables.tsv)), which now exists; not yet applied.
- **Frame tick unnamed.** The loop that ticks the load managers is a caller at raw
  `0x00439094`/`0x0043909f`, inside an un-headered decomp region (no `FUN_` between 0x438864
  and 0x439420).
- **`WSStreamingManager::Update`** (the method `WSStreamingTask` calls each frame) is not
  pinned; only `SetStartCameraPos` and the singleton lifecycle are.
- **Contexts + Bootup/InitLoad/PermLoad/LoadGlobal tasks** carry no assert strings → unpinned.
- **`FUN_0065fd6c`** is decompiled with a broken calling convention; name trusted from the
  string, logic unreliable.
- **Struct layouts** of `DAT_01240328` and `DAT_0142d324` (offsets like +0x1998, +0x2205,
  +0xd11, +0x16e8) are referenced but not field-mapped.

---

## Verification (adversarial pass)

**Verdict: solid** — 11/11 key functions confirmed against the decomp.

**Seams (cross-subsystem):**

- SetStartCameraPos FUN_009f7790 has 4 callers the doc ignores beyond Update_Flow: FUN_007859e0@0x00785ac8, FUN_009ff530@0x009ff5bb, FUN_009ccf30@0x009cd562, and bare 0x004391df (task vtable). Update_Flow also re-enters it itself in case 5: FUN_009f7790(0,&DAT_014a9d38,0,0) at line 861157. So it is a shared streaming-start entry, not seeded solely by the Paris_1_Mission_1 path.
- Interior state machine is bidirectional, not one-way: SetInteriorState FUN_009cb240 case 7 calls BACK into TeleporterMain FUN_009ca1a0 (line 860230). Doc frames only TeleporterMain->SetInteriorState.
- Task-graph seam: the manager Update pumps are driven from bare addresses in the 0x00439-0x0043c task-vtable region -- Update_Flow FUN_009ccb50 caller 0x00439094; SaveLoad Update FUN_00654d30 callers 0x0043a3e0(FUN_0043a280)/0x0043c97b; SetStartCameraPos caller 0x004391df. Ties these managers to WSGameTask/WSStreamingTask task graph. Doc never links the managers to the Task classes it lists.
- Shared world/streaming object seam: BootMainGame FUN_005b8800 (lines 249468-249471) and SetStartCameraPos FUN_009f7790 (lines 888011-888017) run the IDENTICAL lazy construct of DAT_0142d324 (0x15c90-byte alloc via FUN_00db39e0 then pointer via FUN_006f96e0). GetGlobal FUN_006f96e0 is the shared accessor. BootMainGame installs streaming singleton DAT_01240328 = *DAT_0124061c which every other function here dereferences.
- WSSaveLoadManager cluster: FUN_00654d30 (Update) switch-dispatches on this+0x3a4 to sibling methods whose assert strings are visible -- StartLoading (line 329050), StartLoadCheckpoint (329192/329221), ExecutePendingSaveLoad (329718/329831/330105) -- alongside StartReturnToHQ. StartReturnToHQ sets this+0x3a4=2 (line 328893) as its Update re-entry state, confirming the dispatcher/method-cluster relationship the doc only asserts.

**Additional gaps / suspected decomp corruption:**

- FUN_009cb240 (SetInteriorState) doc justification is wrong: it claims 'All callers are inside FUN_009ca1a0 (TeleporterMain)'. The header caller list refutes this -- callers include FUN_009cab40 (0x009cab68,0x009cab87), FUN_009cb7c0 (0x009cb800,0x009cb8c0), FUN_009cb3f0 (0x009cb431), plus more (truncated). Name/role (state dispatcher writing this+0x12a74) still holds, but the cited evidence is false.
- FUN_0065fd6c (CheckForSkipAndSkip) description 'decompresses/advances a stream cursor' is unsupported by the visible body. Body dispatches on magic EAX values (-0x5bf28883, -0x1a1c5aa) and refcounts handles via InterlockedIncrement; it is a garbled function (Ghidra invented phantom args in_EAX/in_ZF/in_stack_0000001c etc). Only the name (from the WSSTreamBlockUncompressor.cpp assert string, note original typo 'STream') is reliable; signature and behavior claim are not.
- FUN_006f96e0 (GetGlobal) doc says '7-byte tail-call thunk (jmp FUN_004d2941)', but Ghidra decompiled it as 'call FUN_004d2941; ret' and typed it returning void -- yet callers store its EAX into DAT_0142d324. Return type unresolved; name 'WSContext::GetGlobal' is pure inference (no string, no RTTI). Lowest-confidence item in the doc.
- Streaming-block code is split across two address ranges: WSSTreamBlockUncompressor/StreamBlock asserts at 0x0065xxxx (FUN_0065fd6c) and 0x0162xxxx (UnloadMeshes FUN_0162e2e0, LoadEventList's stream helpers). UnloadMeshes FUN_0162e2e0 and LoadEventList FUN_0070b700 both have callers=[] (only reachable via vtable), so xref navigation into the high module is blind -- likely why the doc could not place their exact call chains.

**Verifier corrections:**

### Corrections to fold in

- **FUN_009cb240 (SetInteriorState):** replace the justification "All callers are inside FUN_009ca1a0 (TeleporterMain)" -- this is false. Callers also include FUN_009cab40, FUN_009cb7c0, FUN_009cb3f0 (see header @0x860192, list truncated). Correct framing: FUN_009cb240 is the central interior **state-transition driver** (writes next state to this+0x12a74, runs a jumptable at switchD_009cb267) and *itself calls back into TeleporterMain* (case 7 -> FUN_009ca1a0, line 860230). TeleporterMain and SetInteriorState form a mutually-recursive state machine.

- **FUN_0065fd6c (CheckForSkipAndSkip):** keep the name (string-confirmed, line 335925-335927, offset 0xcb not otherwise), but drop "decompresses/advances a stream cursor." Body is a magic-value dispatcher (in_EAX == -0x5bf28883 / -0x1a1c5aa) that copies handles and InterlockedIncrements a refcount; decomp is corrupted (phantom register/stack args). Mark behavior as unresolved.

- **FUN_006f96e0 (GetGlobal):** it decompiles as `call FUN_004d2941; ret`, not a `jmp` tail-call, and is typed returning void despite callers consuming its EAX (DAT_0142d324 assignments at lines 249471, 888017). Name is inference-only; downgrade confidence and note return type unresolved.

- **FUN_009f7790 (SetStartCameraPos):** note the assert offset is 0x7e6 (line 888070) and that the "Paris_1_Mission_1" literal is `param_4` (district name, __stricmp'd against "none"), with `param_5=1` the streaming flag. Add the 4 non-Update_Flow callers as alternate streaming entries.

- **FUN_00654d30 (WSSaveLoadManager::Update):** upgrade confidence -- it switch-dispatches on this+0x3a4 and StartReturnToHQ sets this+0x3a4=2 (line 328893) as its own Update re-entry, and sibling methods StartLoading/StartLoadCheckpoint/ExecutePendingSaveLoad are string-confirmed in the same function group (lines 329050-330105).
