# Vehicle & Train

The vehicle subsystem models player/AI/traffic cars via a two-layer simulation — a lightweight *virtual* vehicle (`WSVirVehicle`, ray-cast wheels, transmission) plus a full *physics* vehicle (`WSPhysicsVehicle` over a Havok `hkpVehicleInstance`) — with seats, boarding/exit, skids, and fire/damage. The Train subsystem is a separate, largely DLC-driven, rail-bound system: a `WSRailwayManager` streams `.railway` data and megapacks, `WSTrain`/`WSTrainCarriage`/`WSTrainEngine` build the consist, and the game spawns Nazis, items, weapons and ammo onto carriage rooftops.

Source-path evidence throughout the decomp confirms the WildStar/Odin layout:
`...\wildstar\POV\code\WildStar\Objects\Vehicles\WSVehicle.cpp`, `WSPhysicsVehicleUtils.cpp`, and `...\Script\Interface\Vehicle.cpp`.

## RTTI classes owned

Driving model: `WSVehicle` / `WSVehicleBlueprint`, `WSPhysicsVehicle(Blueprint)`, `WSPhysicsCar`, `WSPhysicsVehicleWheel(Blueprint)`, `WSPhysicsVehicleWheelFXBlueprint`, `WSCar` / `WSCarBlueprint`, `WSVehicleCollision(Blueprint/Listener)`, `WSVehicleSkidManager`, `WSVehicleSpringAction`, `WSVehicleDetectionCallbackShape`, `WSRejectRayChassisListener`, `WSSoundVehicle`, `WSHUDCarDashboard`.

Virtual vehicle: `WSVirVehicle(Blueprint)`, `WSVirVehicleChassis(Blueprint)`, `WSVirVehicleEngineBlueprint`, `WSVirVehicleTransmission(Blueprint)`, `WSVirVehicleWheelBlueprint`, `WSVirVehicleRayCaster`.

AI/traffic drivers (shared with AI subsystem): `WSAIControllerVehicle`, `WSControllerInputVehicleAI`, `WSAIPathFollowerVehicle`, `WSAIScriptedPathFollowerVehicle`, `WSAIVehicleChase`, `WSAIVehicleSpawner`, `WSAIEscalationVehicle`, `WSAICarPoolManager`.

Train: `WSTrain(Blueprint)`, `WSTrainManager`, `WSRailwayManager`, `WSTrainCarriage(Blueprint)`, `WSTrainEngine(Blueprint)`, `WSTrainItem(Blueprint)`, `WSTrainListBlueprint`, `WSTrainCarriagePositionUpdateFunction`, `WSTrainItemConstrainFunction`, `WSTrainWeaponAmmoUpdateFunction`, `WSTrainLuaJob`.

## Lua API surface

Global functions (mangled `?...@@YAX...` — free functions, not class statics): `Vehicle.GetPilot/GetPassengers/GetOccupantList/GetSeat/GetSeatActor/GetActorInSeat/GetNumSeats/GetNumWheelsOnGround/GetSpeed`, `CanBoard/CanPassengerGetOut/ChangeSeat/GetNextExitSeat/GetBoardingPosition`, `BoardVehicle/UnboardVehicle/UnboardAll/NavBoardVehicle/SpawnInVehicle/PullFromVehicle`, `LockSeat/LockAllSeats/EnableInput/ForceKeyframing/SetCrashThrough/SetForceNeverFlip/SetForceSelfRight`, `AddToTraffic/RemoveFromTraffic/IsNaziVehicle`, `StartFireEffect/StartSmokeEffect`, `ShowRaceTimer/StartRaceTimer`, plus `IsInVehicle/GetVehicle/ObjectIsVehicle`, traffic (`TrafficEnable/IsTrafficEnabled/SetVehicleAvoidance`) and escalation (`EnableEscalationVehicles`). A second table `Vehicle.*` of race callbacks is registered from `Vehicle.cpp` (see FUN_00762fa0): `SetRaceLoaded/Start/Finished/WrongWay/OffTrack/CheckPoint/PlaceChange` `Callback`, `SetRacerNearPlayerCallback`, `SetPlayerLapped/PlayerSpeedCallback`.

Train statics (mangled `?...@WSTrain@@SAX...`): `WSTrain::TrainCreate/Cull/SuperCull/Start/Stop/DecoupleCarriage`, `TrainSetCurrSpeed/SetMaxSpeed/UseTrackMaxSpeed/SetStopAtStation`, `TrainReleaseToPhysics`, `TrainSpawnNazi(ReachedDestination)`, `TrainSystemEnable`, `TrainIsStreamedIn/GetBoardingPosition`, and a large family of `TrainRegister*Callback` hooks (Carriage/Creation/Death/Engine/FinishRegistration/Location/PlayerCarriageTrigger/PlayerDistance/Streamout/TrainAmmo/TrainDecoupled/TrainItem/TrainNazi/TrainNaziDeath/TrainWeapon). Real usage in `Modules/Libraries/TrainMGR.lua` (e.g. `TrainMGR.CreateTrain` → `Train.TrainCreate` + `TrainRegisterStreamoutCallback`), and `Includes/WRAPPER_Vehicle.lua` wraps the seat/board API.

## Key functions (decomp)

- **FUN_00461590** — Blueprint/RTTI class factory. Interns type tags via `FUN_00db7e10(...)`: `"VehicleCollision"`, `"TrainList"`, `"Train"`, `"TrainCarriage"`, `"TrainEngine"`, `"TrainItem"`, `"VirVehicleWheel/Transmission/Engine/Chassis"`, `"VirVehicleSetup"`, `"VehicleWheelFX"`. Central blueprint-type registry (size 9126).
- **FUN_0046f080** — Train blueprint field reader; interns `"Train"`, `"TrainSpawnID"`, `"TrainID"`, `"CarriageBackwards"`. Reads a train spawn descriptor.
- **FUN_005cd1f0** — `WSVehicle::StartFireEmitter` (string `pcStack_8 = "WSVehicle::StartFireEmitter"`, in WSVehicle.cpp). Attaches the burning-vehicle particle emitter.
- **FUN_0075e8e0** — Lua glue for `Vehicle.StartFireEffect`; resolves the current Lua handle, walks the object vtable and tail-calls `FUN_005cd1f0` (StartFireEmitter). Single caller `0x00764b25` is the binding dispatch table.
- **FUN_005ceed0** — WSVehicle damage/teardown path in WSVehicle.cpp (asserts `WSVehicle::ApplyDamageAIReactions` and the `~WSVehicle` dtor line 0x995). Applies AI reactions to vehicle damage.
- **FUN_005fe5a0** — Vehicle simulation task dispatch; pushes profiler zones `"TtVehicleAction-DoUpdateVirtualVehicle"` and `"TtVehicleAction-DoUpdatePhysicsVehicle"`. Selects virtual vs. physics update for the frame.
- **FUN_006085d0** — Physics-vehicle tick (size 3588); zones `"TtVehicleAction-ShapeRay"`, `"TtVehicleAction-DoPhysicsUpdate"`, `"TtVehicleAction-VehicleSelfRight"`. Wheel ray-casts, Havok step, and auto self-right — the core driving-physics update.
- **FUN_00422e90** — `WSVehicleSkidManager` (builds names via `_sprintf(...,"VehicleSkid")`, size 5730). Manages skid-mark decals/particles per wheel.
- **FUN_006fb2c0** — Vehicle enter/exit event handler; fires script events `"OnVehicleEnter"` / `"OnVehicleExit"` via `FUN_004cc4c0`. Called from three human-state sites.
- **FUN_00711a40** — `"BoardVehicle"` action/event constructor (single caller `0x00716eb5`).
- **FUN_00750110** — Enter/exit input control; interns input action `"EnterExitVehicle"`. Maps the enter/exit button while on-foot / driving.
- **FUN_00762fa0** — `Vehicle.cpp` Lua interface registrar (asserts the `Script\Interface\Vehicle.cpp` path). Registers the race-callback table.
- **FUN_007628e0** — Race-callback binding block; calls `FUN_007627d0(state, id, "Vehicle.SetRace*Callback")` for the full race-event set. Called by the interface registrar chain.
- **FUN_00620dc0** — Train carriage builder; names carriages `_sprintf(...,"Carriage %i")`. Called from `FUN_00621f10` (train assembly).
- **FUN_00625220** — Train per-frame update; opens profiler zone `FUN_00db4580("TrainUpdate")`. Drives carriage position updates along the rail.
- **FUN_0062ce70** — Train troop spawner; names actors `"TrainSpawnedPassenger%d"`. Backs `WSTrain::TrainSpawnNazi`.
- **FUN_0062d1d0** — Train rooftop-object spawner (size 2123); names `"TrainRooftopPassenger%d"`, `"TrainRooftopItem%d"`, `"TrainRooftopWeapon%d"`, `"TrainRooftopAmmo%d"`. Populates carriage roofs with gunners/items.
- **FUN_009906c0** — Railway streaming loader (`WSRailwayManager`); formats `"%s\\%s.railway"` plus `Animations.pack`, `dlc01mega0.megapack`, `dynamic0.megapack`, `palettes0.megapack` under a per-instance base at offset `+0x1b0`. Streams a railway region on demand (train content is DLC01).
- **FUN_00b55a70** — Havok vehicle debug/step wrapper; zone `"TthkpVehicleViewer::step"`, and sibling FUN_00b558e0 instantiates `"hkpVehicleInstance"`. Bridges `WSPhysicsVehicle` to Havok's vehicle SDK.
- **FUN_01625130** — Virtual-wheel blueprint allocator; names `"VirtualWheelBlueprint%d"` from a global counter. Constructs `WSVirVehicleWheelBlueprint` instances.

## Notes

- The two-layer design is explicit in the profiler zone names (FUN_005fe5a0): a `VirtualVehicle` cheap-sim path and a `PhysicsVehicle` Havok path, switched per frame (LOD/traffic vs. player).
- Train content is DLC-gated: FUN_009906c0 loads `dlc01mega0.megapack`, matching `WSTrainLuaJob`/`TrainMGR` being driven from script rather than always-on.
- `FUN_009d3830` is a general hashed FX-name resolver that *includes* `"FX_TrainSteamA"`/`"FX_TrainSmokeA"` (train engine smoke) but is not owned by this subsystem.

---

## Verification (adversarial pass)

**Verdict: solid** — 18/20 key functions confirmed against the decomp.

**Refuted / corrected:**

- `0x00762fa0` — Header exists (size=341) and the Vehicle.cpp assert path IS present at line 473818, but the role is wrong. This is NOT 'Lua_Register_VehicleInterface / registers the Vehicle race-callback table'. The body resolves a single Lua vehicle handle (FUN_006f6ec0/FUN_0067c0a0), reads string args, and dispatches an action asserted as pcStack_8="StartPlayback" at Vehicle.cpp:0xb60 (line 473820-473821). It is a single Lua binding handler for a race/path playback call, not a table/interface registrar.
- `0x007628e0` — Header exists (size=103) but the role is overstated. It does NOT register 'the full race set (lines 473382-473658)'. It registers exactly ONE callback: FUN_007627d0(state,&flag,"Vehicle.SetRaceLoadedCallback") then FUN_008f9850 (line 473382-473384). The other race callbacks are SEPARATE sibling functions of identical shape: FUN_00762950="Vehicle.SetRaceStartCallback" (473411), FUN_007629c0=next, etc. Lines 473382-473658 span multiple distinct functions, not one. Correct label: Lua_Vehicle_SetRaceLoadedCallback (single setter).

**Seams (cross-subsystem):**

- FUN_006fb2c0 (OnVehicleEnter/Exit) is driven by the Human/character-state subsystem: its three callers 0x0043a16d(FUN_00439ff0), 0x0043a681(FUN_0043a280), 0x0043ca78 are human-state handlers, and it fires the events through the generic script-event dispatcher FUN_004cc4c0("OnVehicleEnter"/"OnVehicleExit") at lines 424173/424191 — seam into the script/event bus, not just vehicle code.
- FUN_005ceed0 (ApplyDamageAIReactions) is called from the damage/AI subsystem: callers 0x006659eb(FUN_00665990) and 0x005d3799 — the reaction path is invoked by damage application, not by vehicle sim itself.
- FUN_009906c0 is a general per-region asset streamer, and the actual railway loader it invokes is FUN_0096bc60(path,1,1) at line 824007. The same function co-loads .rndnodes (FUN_004baab0), .waterctrl (FUN_004d2cd0), .waterflow (FUN_004d4360), .freeplay (FUN_00985da0), .ambush (FUN_008b2680) and Sound (FUN_00919bd0) — seams into water/freeplay/ambush/audio region systems that the doc omits.
- FUN_00461590 is the shared blueprint-component instantiator for the whole engine, not vehicle/train-specific: it dispatches the same FUN_00db7e10(tag)/FUN_00db39e0(size,1)/component-ctor pattern for Human, Spore, PlayerCollision, Targetable, Foliage, AIAttractionPt, DamageSphere, Explosion, etc. The vehicle/train tags are one slice — seam into the common blueprint-property/type-interning system (FUN_00db7e10 interner + FUN_00db39e0 allocator).
- FUN_0075e8e0, FUN_00762fa0, FUN_007628e0 all go through the shared Lua<->object bridge helpers (FUN_006f6ec0 get-handle, FUN_0067c0a0 resolve, FUN_006f8470 stack frame, FUN_006f71a0/FUN_006f7160 arg checks) — the Lua binding runtime seam common to every Vehicle.* call.
- Havok bridge: FUN_00b558e0 instantiates "hkpVehicleInstance" (line 1089718) and FUN_00b55a70 runs "TthkpVehicleViewer::step" (line 1089834) — direct seam into the Havok Vehicle SDK, the physics backend behind FUN_006085d0 (PhysicsVehicle_Tick).

**Additional gaps / suspected decomp corruption:**

- The true Vehicle Lua-interface registrar is unnamed by Ghidra: the binding handlers FUN_007628e0/FUN_00762950/.../FUN_00762fa0 are all called from call sites 0x007653b5, 0x007653d5 ... 0x00765515 inside one large unlabelled function (Ghidra left callers as raw VAs with no FUN_ attribution). That function — not FUN_00762fa0 — is the real 'Lua_Register_VehicleInterface'. Worth pinning down and re-labelling.
- FUN_0046f080 (TrainSpawnBlueprint_Read) has callers=[] in the decomp — no xref recorded. It is a blueprint field-descriptor builder (writes tag/type pairs into param_1: Train/4, TrainSpawnID/4, TrainID/4, CarriageBackwards/1) so it is almost certainly reached via a vtable/function-pointer table the static analysis missed. Same callers=[] gap on FUN_005fe5a0, FUN_006085d0, FUN_00625220, FUN_00b55a70, FUN_01625130 — all reached indirectly (sim update vtables / blueprint factory tables), so absence of callers is not evidence of dead code but IS a place the call graph is incomplete.
- Doc scope-creep on two 'Register' labels (FUN_00762fa0, FUN_007628e0) plus FUN_009906c0 ('Railway_StreamLoad' is really a whole-region streamer) and FUN_00461590 ('Blueprint_RegisterVehicleTrainTypes' is really the engine-wide component instantiator). All string/VA evidence cited is correct; only the human-readable role names overreach.

**Verifier corrections:**

## Vehicle & Train — corrections to fold in

- **FUN_00762fa0** — rename from `Lua_Register_VehicleInterface`. It is a single Lua binding handler, asserted `StartPlayback` at `Script\Interface\Vehicle.cpp:0xb60` (decomp 473820). It resolves one vehicle handle and dispatches a race/path playback action. Suggest `Lua_Vehicle_StartRacePlayback`. It does NOT register a table.
- **FUN_007628e0** — rename from `Lua_Register_VehicleRaceCallbacks`. Registers exactly ONE callback: `Vehicle.SetRaceLoadedCallback` (473382). The rest of the race set are sibling functions of identical shape (e.g. FUN_00762950 = `Vehicle.SetRaceStartCallback` @473411, FUN_007629c0, …). Suggest `Lua_Vehicle_SetRaceLoadedCallback`. The aggregate registrar is the unnamed function holding call sites 0x007653b5–0x00765515 — that is the real Vehicle Lua interface installer.
- **FUN_009906c0** — narrow the label. `.railway` (824005) is confirmed, but this is a general per-region streaming loader that also pulls `.rndnodes/.waterctrl/.waterflow/.freeplay/.ambush/Sound`. The railway-specific loader it calls is **FUN_0096bc60** (824007). Suggest `Region_StreamLoadAssets`, and add FUN_0096bc60 as the actual `Railway_StreamLoad`.
- **FUN_00461590** — note scope. All 12 claimed vehicle/train tags are present (VehicleCollision 55800, TrainList 55840, Train 55850, TrainCarriage 56022, TrainEngine 56032, TrainItem 56042, VirVehicleWheel/Transmission/Engine/Chassis 56442-56472, VirVehicleSetup 56482, VehicleWheelFX 56492), but the same function also instantiates Human/Spore/Foliage/Explosion/etc. It is the engine-wide blueprint component factory, not a vehicle/train-only registrar. Keep it but label it as shared.

Everything else verified verbatim: StartFireEmitter string @257036 + tail-call from FUN_0075e8e0 @471395; ApplyDamageAIReactions @258330; sim-select zones @283211/283228; physics-tick zones @288662/288744/288770; VehicleSkid @21895; OnVehicleEnter/Exit @424173/424191; BoardVehicle @438394; EnterExitVehicle @466196; Carriage %i @300259; TrainUpdate @302640; TrainSpawnedPassenger%d @306853; TrainRooftop{Passenger/Item/Weapon/Ammo} @306969-307117; hkpVehicleInstance @1089718; TthkpVehicleViewer::step @1089834; VirtualWheelBlueprint%d @1753150. Sizes match where claimed (9126, 5730, 3588, 1246, 2123, 2187).
