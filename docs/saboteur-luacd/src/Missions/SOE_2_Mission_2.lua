if SOE_2_Mission_2 == nil then
  SOE_2_Mission_2 = SabTaskObjective:Create()
  SOE_2_Mission_2:Configure({
    TaskCount = 99,
    sStarter = "Spore_RS_Skylar",
    sConvFile = "308_Con_TrainBrief",
    sSaveMissionNameID = "MissionNames_Text.S2M2",
    sHQNextMissionStartPoint = _cHQe_POSTTRAIN,
    tUnlockList = {
      "SOE_2_Mission_2_ConnectB"
    },
    tSMEDNodes = {
      "Missions\\soe_2\\mission_2\\ambientevents",
      "Missions\\soe_2\\mission_2\\resistance",
      "Missions\\soe_2\\mission_2\\naziclimb",
      "Missions\\soe_2\\mission_2\\naziflags",
      "Missions\\soe_2\\mission_2\\rocketscenario",
      "Missions\\soe_2\\mission_2\\triggerbox",
      "Missions\\soe_2\\mission_2\\SkylarLoadHackery",
      "Missions\\soe_2\\mission_2\\ConversationAndmisc\\Triggerbox2",
      "Missions\\soe_2\\mission_2\\nazitotrain",
      "Missions\\soe_2\\mission_2\\speedhack",
      "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols"
    },
    tStaticTags = {
      "ambient_chambord_props",
      "S2M2_platform1",
      "S2M2_platform2",
      "S2M2_platform3",
      "S2M2_platform4",
      "S2M2_stonebridge"
    }
  })
end

function SOE_2_Mission_2:STARTER_Setup()
  Util.LoadStaticENTag("s2m2_SkylarChair", true)
  Util.SetDynamicPriority("VH_CV_CR_Skylar_01", 50000)
  Util.SetDynamicPriority("Human_RS_Wilcox", 50000)
  Util.SpawnEditNode("Missions\\soe_2\\mission_2\\missioncar.wsd")
  Util.UnloadStaticENTag("fp_amb_pc_searchlight_05", true)
  Util.UnloadStaticENTag("fp_amb_cb_general_02", true)
  Util.UnloadStaticENTag("fp_amb_cb_armoredcar_02", true)
  Util.UnloadStaticENTag("fp_amb_pc_armoredcar_08", true)
  Util.UnloadStaticENTag("fp_amb_pc_radar_02", true)
  Util.UnloadStaticENTag("fp_amb_cb_snipernest_06", true)
  Util.UnloadStaticENTag("fp_amb_pc_snipernest_06", true)
  Util.UnloadStaticENTag("fp_amb_pc_snipernest_10", true)
  Util.UnloadStaticENTag("fp_amb_pc_snipernest_11", true)
  Util.UnloadStaticENTag("fp_amb_pc_snipernest_13", true)
  Util.UnloadStaticENTag("ambient_chambord_props_Nazis", true)
  Util.CreateEvent({
    EventType = "StreamEvent",
    EventName = "InitialEventSkylar",
    Objects = {
      "Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar",
      "Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)"
    },
    WaitForGameObject = true
  }, "SOE_2_Mission_2.SetupSkylarMovementEvent", nil, nil)
end

function SOE_2_Mission_2:SkylarCarStreamedOut()
  SOE_2_Mission_2.MissionFail(self, "S2M2_Fail.TooFarFromCar")
end

function SOE_2_Mission_2.SetupSkylarMovementEvent()
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  if SOE_2_Mission_2.bDontDoStarterSetup == nil then
    EVENT_PlayerToActorProximity("SOE_2_Mission_2.MoveSkylarToPosition1", nil, "Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar", 35, nil, false)
    local hATPT = Handle("Missions\\soe_2\\mission_2\\starter\\AttractionPT_SitCafe")
    if hATPT ~= nil and AttractionPt.IsAvailable(hATPT) then
      Actor.UseAttrPt(hSkylar, hATPT)
    end
  end
  Combat.SetGrabbable(hSkylar, false)
  SOE_2_Mission_2.bDontDoStarterSetup = 1
  local hCar = Handle("Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)")
  if hCar then
    Vehicle.LockAllSeats(hCar, true)
    Object.SetInvincible(hCar, true)
  end
end

function SOE_2_Mission_2.MoveSkylarToPosition1()
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  local hLoc = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\LOC_SkylarWalk")
  local hATPT = Handle("Missions\\soe_2\\mission_2\\starter\\AttractionPT_SitCafe")
  Actor.CancelAttrPt(hSkylar)
  Actor.CancelAttrPtRequest(hSkylar)
  Nav.MoveToObject(hSkylar, hLoc, 1)
  Combat.SetIdleScripted(hSkylar, true)
end

function SOE_2_Mission_2:Activated()
  SabTaskObjective.Activated(self)
  SOE_2_Mission_2.Conv308DelayedPlayedTimes = 0
  self.Checkpoint0(self)
end

function SOE_2_Mission_2:Checkpoint0()
  Cin.LoadCinematic("312_313_Merged")
  Util.SetMiniZepSpline("Missions\\soe_2\\mission_2\\ambientevents\\gettobridge")
  local hCar = Handle("Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)")
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  Combat.SetGrabbable(hSkylar, false)
  self.sDebugLabel = "DEMO"
  self.bDebugMode = false
  dprint(self, "OnEnter()")
  self.RegisterCheckpoint(self, "SOE_2_Mission_2.GENERAL_Setup")
end

function SOE_2_Mission_2:GENERAL_Setup()
  self.DelayedConv308bRestart(self)
  self.Conv308DelayedPlayedTimes = 1
  self.eCarStreamOut = Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForStreamOut = true,
    Objects = {
      "Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)"
    }
  }, "SOE_2_Mission_2.SkylarCarStreamedOut", self)
  self:RegisterEvent(self.eCarStreamOut)
  self:AddOnCancelCallback(SOE_2_Mission_2.ResetMission)
  self:AddOnCompleteCallback(SOE_2_Mission_2.ResetMission)
  self.bEnableTimerForTrain = false
  self.tSaveInfo.GetOntheBridgeTaskConvo = false
  self.tSaveInfo.GetToTrainStationTaskConvo = false
  self.tSaveInfo.GetToTrainStationRanOnce = false
  self.bConvoPlayedForBridge = false
  self.tSaveInfo.bSetupGotoTrain = false
  self.tSaveInfo.bFailPlayerForDistance = false
  self.tSaveInfo.bPlayDriveConvo1 = false
  self.tSaveInfo.bConvo309Done = false
  self.bTrainCreatedFirstTime = false
  self.nConvoRandomness = 1
  self.tSaveInfo.bTrainStarted = false
  self.tSaveInfo.bTrainEventsStarted = false
  self.bTruckArrived = false
  self.tSaveInfo.bWarnPlayer10 = false
  self.tSaveInfo.bWarnPlayer20 = false
  self.bNaziJumpFlag1 = false
  self.bNaziJumpFlag2 = false
  self.nPlayerCarriageLocation = -1
  self.bHaveGoneOnTrain = false
  self.bOnRadioCarOnce = false
  self.tSaveInfo.nRealSize = 0
  self.t_hSpawnedEntity = {}
  self.bDoNotActivateAgain = false
  self.bDecouple = false
  self.bDoNotStopTrain = false
  self.nTimerCounterForConvo = 0
  self.bFirstTimeOnCoalCar = false
  self.bHasGoneOneRadioCar = false
  self.bSeeTrainGuy = false
  self.bStillStuffToDoBeforeRescueKesler = true
  self.bSkylarAndPlayerInVehicleConvo = false
  self.bCarDamageFirst = false
  self.bCarDamage25 = false
  self.bCarDamage50 = false
  self.bCarDamage75 = false
  self.bCarDamage100 = false
  self.nCTStation = 0
  self.bConvoTrainStoppedAtStation = false
  self.MaxCarHealth = 5.0E10
  self.bGotToKessler = false
  self.tConvoPlayedTable = {}
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\nazitotrain\\PT_SpawnEnc1", hSab, "SOE_2_Mission_2.Chatarea", self, {3}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\nazitotrain\\PT_SpawnEnc1")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\nazitotrain\\PT_SpawnEnc2", hSab, "SOE_2_Mission_2.BridgeArea1", self, {3}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\nazitotrain\\PT_SpawnEnc2")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\nazitotrain\\PT_SpawnEnc3", hSab, "SOE_2_Mission_2.Bridgearea2", self, {3}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\nazitotrain\\PT_SpawnEnc3")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc4_civilians\\PT_StartEvent_NaziChasing", hSab, "SOE_2_Mission_2.NaziChasing", self, nil, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc4_civilians\\PT_StartEvent_NaziChasing")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\SkylarLoadHackery\\loadunloadstuff", hSab, "SOE_2_Mission_2.LoadUnloadSkylarAndCar", self, nil, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\SkylarLoadHackery\\loadunloadstuff")
  self.tChambordAFirePositions = {
    "Missions\\soe_2\\mission_2\\enc3_chambord\\LOC_FirePosA1",
    "Missions\\soe_2\\mission_2\\enc3_chambord\\LOC_FirePosA2",
    "Missions\\soe_2\\mission_2\\enc3_chambord\\LOC_FirePosA3",
    "Missions\\soe_2\\mission_2\\enc3_chambord\\LOC_FirePosA4"
  }
  self.tChambordBFirePositions = {
    "Missions\\soe_2\\mission_2\\enc3_chambord\\LOC_FirePosB1",
    "Missions\\soe_2\\mission_2\\enc3_chambord\\LOC_FirePosB2",
    "Missions\\soe_2\\mission_2\\enc3_chambord\\LOC_FirePosB3",
    "Missions\\soe_2\\mission_2\\enc3_chambord\\LOC_FirePosB4"
  }
  self.bPressedOnce = false
  self.bDisable = false
  self.bStopTrainButton = 1
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PT_BridgePatrol3A", hSab, "SOE_2_Mission_2.BridgePatrol", self, {
    "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\CH_BridgePatrol3",
    "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PA_BridgePatrol3A"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PT_BridgePatrol3A")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PT_BridgePatrol3B", hSab, "SOE_2_Mission_2.BridgePatrol", self, {
    "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\CH_BridgePatrol3",
    "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PA_BridgePatrol3B"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PT_BridgePatrol3B")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PT_BridgePatrol4B", hSab, "SOE_2_Mission_2.BridgePatrol", self, {
    "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\CH_BridgePatrol4",
    "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PA_BridgePatrol4B"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PT_BridgePatrol4B")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PT_BridgePatrol2A", hSab, "SOE_2_Mission_2.BridgePatrol", self, {
    "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\CH_BridgePatrol2",
    "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PA_BridgePatrol2A"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PT_BridgePatrol2A")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PT_BridgePatrol2B", hSab, "SOE_2_Mission_2.BridgePatrol", self, {
    "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\CH_BridgePatrol2",
    "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PA_BridgePatrol2B"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PT_BridgePatrol2B")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PT_BridgePatrol2C", hSab, "SOE_2_Mission_2.BridgePatrol", self, {
    "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\CH_BridgePatrol2",
    "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PA_BridgePatrol2C"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PT_BridgePatrol2C")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PT_BridgePatrol1A", hSab, "SOE_2_Mission_2.BridgePatrol", self, {
    "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\CH_BridgePatrol1",
    "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PA_BridgePatrol1A"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PT_BridgePatrol1A")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PT_BridgePatrol1B", hSab, "SOE_2_Mission_2.BridgePatrol", self, {
    "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\CH_BridgePatrol1",
    "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PA_BridgePatrol1B"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PT_BridgePatrol1B")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PT_BridgePatrol_top3", hSab, "SOE_2_Mission_2.BridgePatrol", self, {
    "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\CH_BridgePatrol_top3",
    "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PA_BridgePatrol_top3"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PT_BridgePatrol_top3")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc2_bridge\\PT_StartRain", hSab, "SOE_2_Mission_2.StartRain", self, nil, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc2_bridge\\PT_StartRain")
  self.Task_GetToBridge(self)
  self.FirstTaskConvoFinished = false
  self.Task_GetToBridge_(self)
  self.bSkylarMoviePlayed = false
  self.bWilcoxMoviePlayed = false
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\conversationandmisc\\triggerbox2\\KillBox", hSab, "SOE_2_Mission_2.KillBoxCondition", self, nil, cTRIGGEREVENT_ONENTER, true), "Missions\\soe_2\\mission_2\\conversationandmisc\\triggerbox2\\KillBox")
  self:RegisterEvent(Util.CreateEvent({
    EventType = "OnTriggerEnter",
    Target = Util.GetHandleByName("Missions\\soe_2\\mission_2\\conversationandmisc\\triggerbox2\\KillBox")
  }, "SOE_2_Mission_2.KillBoxCondition", self, nil, true))
  Actor.SetLabel(hSab, "UNLOCK_RS_FIGHTERS", true)
  Actor.SetLabel(hSab, "UNLOCK_RS_HEAVY", true)
  Vehicle.SetAsMissionCritical(Handle("Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)"), true)
  Vehicle.RegisterWaterLoggedCallback(Handle("Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)"), "SOE_2_Mission_2.CarDestroyedCallback", self)
  Trigger.WaitFor("Missions\\soe_2\\mission_2\\speedhack\\PT_speedhack", hSab, "SOE_2_Mission_2.HackyHack", self, {3}, cTRIGGEREVENT_ONENTER)
  Trigger.WaitFor("Missions\\soe_2\\mission_2\\speedhack\\PT_speedhack2", hSab, "SOE_2_Mission_2.SpeedHack2", self, {3}, cTRIGGEREVENT_ONENTER)
end

function SOE_2_Mission_2:TurnOnRadioSabotage()
  local hTrainBomb = AttractionPt.FindPtInObject("Missions\\soe_2\\mission_2\\missioncar\\VH_CV_TN_RadioCar", "TrainThrottle")
  AttractionPt.EnableUse(hTrainBomb, true)
end

function SOE_2_Mission_2.Conv_308b_Con_TrainBrief()
  local tEvent = {EventType = "TimerEvent", Time = 0.5}
  Util.CreateEvent(tEvent, "SOE_2_Mission_2.DelayedConv308b", SOE_2_Mission_2)
end

function SOE_2_Mission_2:DelayedConv308b()
  ConvoHelper.InterruptReplay("308b_Con_TrainBrief", "s2m2_Starterconv", "SOE_2_Mission_2.Conv_S2M2_ToBridge_Car_Start", SOE_2_Mission_2)
end

function SOE_2_Mission_2:DelayedConv308bRestart()
  if SOE_2_Mission_2.Conv308DelayedPlayedTimes == 1 then
    Convo.ResetForFail()
    ConvoHelper.InterruptReplay("308b_Con_TrainBrief", "s2m2_Starterconv", "SOE_2_Mission_2.Conv_S2M2_ToBridge_Car_Start", SOE_2_Mission_2)
  end
end

function SOE_2_Mission_2:Conv_S2M2_ToBridge_Car_Start()
  local hSkylar = Handle("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  if Actor.IsInVehicle(hSkylar) == false and Actor.IsInVehicle(hSab) == false then
    Convo.AddConvo("S2M2_ToBridge_Car_Start", 10, {
      sCallback = "SOE_2_Mission_2.UpdateCounterAndPotentiallyPlayConversation"
    })
  else
    SOE_2_Mission_2.UpdateCounterAndPotentiallyPlayConversation(self)
  end
end

function SOE_2_Mission_2:CarDestroyedCallback()
  self:MissionTaskFail("GenericFail_Text.DESTROYED_Car_The")
end

function SOE_2_Mission_2:KillBoxCondition(hwho)
  if Actor.HasLabel(hwho[2], "Nazi") then
    Object.Kill(hwho[2])
  end
end

function SOE_2_Mission_2.Convo_GetToBridge()
  SOE_2_Mission_2.Task_GetToBridge_(SOE_2_Mission_2)
end

function SOE_2_Mission_2:HackyHack()
  self:FailTaskByName("GetToPoint1")
  Inventory.GiveItem(hSab, "WP_SAB_BridgeKiller", false)
  Object.PlayerTeleportToLocator(Handle("Missions\\soe_2\\mission_2\\speedhack\\LOC_speedhack"), true, "SOE_2_Mission_2.HackyCheckpoint3", self)
  self.OldSetup(self)
end

function SOE_2_Mission_2:SpeedHack2()
  local hsky = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  local hcar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)")
  Object.Teleport(hsky, -1035, 48, -1303)
  Object.Teleport(hcar, -1035, 48, -1305)
  Object.PlayerTeleportToLocator(Handle("Missions\\soe_2\\mission_2\\speedhack\\LOC_speedhack2"), true, "SOE_2_Mission_2.HackyCheckpoint2", self)
  Inventory.GiveItem(hSab, "WP_SAB_BridgeKiller", false)
  Inventory.GiveItem(hSab, "WP_SAB_BridgeKiller", false)
  Inventory.GiveItem(hSab, "WP_SAB_BridgeKiller", false)
  Inventory.GiveItem(hSab, "WP_SAB_BridgeKiller", false)
  Inventory.GiveItem(hSab, "WP_SAB_BridgeKiller", false)
  self.Task_GetToBridge(self)
  self.OldSetup(self)
end

function SOE_2_Mission_2:HackyCheckpoint3()
  self.SetupCheckpoint3(self)
end

function SOE_2_Mission_2:MissionFail(sString)
  if sString then
    self:MissionTaskFail(sString)
  else
    self:MissionTaskFail(nil)
  end
end

function SOE_2_Mission_2:PlayConvoUsingQueue(sConvoName, nPriority, tFlags)
  table.insert(self.tConvoPlayedTable, sConvoName)
  Convo.AddConvo(sConvoName, nPriority, tFlags)
end

function SOE_2_Mission_2:SetupHackyWackyStuff()
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\triggerbox\\PT_TeleportToTrain", hSab, "SOE_2_Mission_2.HackyTeleport1Deleteme", self, nil, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\triggerbox\\PT_TeleportToTrain")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\triggerbox\\TeleportToBridge", hSab, "SOE_2_Mission_2.HackyTeleport2Deleteme", self, nil, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\triggerbox\\TeleportToBridge")
end

function SOE_2_Mission_2:HackyTeleport1Deleteme()
  self.HackyHack(self)
  local hLoc = Util.GetHandleByName("Missions\\soe_2\\mission_2\\triggerbox\\LC_TeleportToWilcox")
  local x, y, z = Object.GetPosition(hLoc)
  Object.PlayerTeleportToPos(x, y, z, 0)
end

function SOE_2_Mission_2:HackyTeleport2Deleteme()
  local hsky = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  local hcar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)")
  local hLoc = Util.GetHandleByName("Missions\\soe_2\\mission_2\\triggerbox\\TeleportToBridgeArea")
  Inventory.GiveItem(hSab, "WP_SAB_BridgeKiller", false)
  Inventory.GiveItem(hSab, "WP_SAB_BridgeKiller", false)
  Inventory.GiveItem(hSab, "WP_SAB_BridgeKiller", false)
  Inventory.GiveItem(hSab, "WP_SAB_BridgeKiller", false)
  Inventory.GiveItem(hSab, "WP_SAB_BridgeKiller", false)
  local x, y, z = Object.GetPosition(hLoc)
  Object.PlayerTeleportToPos(x, y, z, 0)
  Object.Teleport(hsky, x - 10, y, z, 0)
  Object.Teleport(hcar, x - 5, y, z, 0)
  self.Task_GetToBridge(self)
end

function SOE_2_Mission_2:LoadUnloadSkylarAndCar()
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar"
    }
  }, "SOE_2_Mission_2.Skylardied", self))
end

function SOE_2_Mission_2:Skylardied()
  local hSkylar = Handle("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
end

function SOE_2_Mission_2:SetupProximityBeckon()
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  EVENT_PlayerToActorProximity("SOE_2_Mission_2.BeckonPlayer", self, hSkylar, 20)
end

function SOE_2_Mission_2:BeckonPlayer()
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  Actor.PlayAnimation(hSkylar, "shrd_M_LH_wave_alert", 1.8, false, 0, "SOE_2_Mission_2.SkylarGetIntoSecondCar", self)
end

function SOE_2_Mission_2:SkylarGetIntoSecondCar()
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  local hCar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\SkylarInPlace\\samemodelcar")
  Nav.BoardVehicle(hSkylar, hCar, "SHOTGUN", true)
end

function SOE_2_Mission_2:SetupHackery()
  Util.SetDisableControls("InventoryChange", true)
  local tControllerEvent = {
    EventType = "OnButtonPress",
    Target = Handle("Saboteur")
  }
  self:RegisterEvent(Util.CreateEvent(tControllerEvent, "SOE_2_Mission_2.OnButtonPress", self, {}, true))
end

function SOE_2_Mission_2:TESTCONVOSTUFFLAWL(tUser, tData)
  local a = 10
  local b = 20
  local c
  c = a + b
end

function SOE_2_Mission_2:OnButtonPress(a_tButtonData)
  local tButtons = a_tButtonData[1]
  if tButtons.DOWN == true and tButtons.B == true and self.HACKYSTUFF == nil then
    self.HACKYSTUFF = 10
    Object.PlayerTeleportToPos(-493, 52, -647, 0)
    Train.TrainCreate("CountrySide\\centre\\AiRails\\AI_Rail_Starter", "Dtrain")
  end
  if tButtons.DOWN == true and tButtons.A == true then
    local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
    Nav.CancelFollowObject(hSkylar)
    Cin.PlayConversation("P6M1_SeePrisonersMistreated", "SOE_2_Mission_2.TESTCONVOSTUFFLAWL", self, {1})
  end
  if tButtons.DOWN == true and tButtons.X == true then
    Train.TrainSetMaxSpeed("CountrySide\\centre\\AiRails\\AI_Rail_Starter", 8)
  end
  if self.bDisable == false then
    local tButtons = a_tButtonData[1]
    local hHandle
    if tButtons.UP == true and tButtons.X == true then
      local hBone = Object.GetBoneHandleFromCarriage(self.tCarriageHandles[self.nPlayerCarriageLocation], true)
      local x, y, z = Object.GetPosition(hBone)
      local x1, y1, z1 = Object.GetPosition(hSab)
    end
    if tButtons.LEFT == true then
      Train.TrainSetMaxSpeed("CountrySide\\centre\\AiRails\\AI_Rail_Starter", "4.5")
    end
    if tButtons.RIGHT == true then
      Train.TrainSetMaxSpeed("CountrySide\\centre\\AiRails\\AI_Rail_Starter", "4")
    end
    if tButtons.UP == true and tButtons.A == true then
      Train.TrainStop("CountrySide\\centre\\AiRails\\AI_Rail_Starter")
    end
    if tButtons.UP == true and tButtons.Y == true then
      SOE_2_Mission_2.HaulAss(self)
    end
    if tButtons.DOWN == true and tButtons.B == true then
      self.KeslerStreamingIn(self)
    elseif tButtons.DOWN == true then
    end
  end
end

function SOE_2_Mission_2:OldSetup()
  Train.TrainCreate("CountrySide\\centre\\AiRails\\AI_Rail_Starter", "Dtrain")
  Train.TrainStop("CountrySide\\centre\\AiRails\\AI_Rail_Starter")
  SOE_2_Mission_2.TrainLoadedCheck(self)
  Train.TrainRegisterStreamoutCallback("CountrySide\\centre\\AiRails\\AI_Rail_Starter", "SOE_2_Mission_2.ReCreateTrainAfterDispawn", self, {1})
  EVENT_Timer("SOE_2_Mission_2.StopTrain", self, 1)
  Train.TrainRegisterTrainNaziCallback("CountrySide\\centre\\AiRails\\AI_Rail_Starter", "SOE_2_Mission_2.GetHandleOfTrainDriver", self, {1})
  self.SetupCarriageHandleTable(self)
end

function SOE_2_Mission_2:GetHandleOfTrainDriver(data1)
  if self.hTrainEngine == data1[2] then
    if Actor.HasLabel(data1[3], "Conductor") then
      self.hTrainGuy = data1[3]
    else
      if self.hTrainNaziWithConductor == nil then
        self.hTrainNaziWithConductor = {}
      end
      table.insert(self.hTrainNaziWithConductor, data1[3])
    end
  end
end

function SOE_2_Mission_2:ReCreateTrainAfterDispawn()
  if self.bCanceled == nil then
    self.tSaveInfo.nRealSize = 0
    self.SetupCarriageHandleTable(self)
    Train.TrainRegisterStreamoutCallback("CountrySide\\centre\\AiRails\\AI_Rail_Starter", "SOE_2_Mission_2.ReCreateTrainAfterDispawn", self, {1})
  end
end

function SOE_2_Mission_2:DecoupleTrainNow()
  self:KillTaskByName("DecoupleCarriages")
  self:CompleteTaskByName("FakeRescueNagel")
  Cin.PlayConversation("S2M2_GotoEngineCar")
  self.Task_GetToEngine(self)
  self.bDoNotActivateAgain = true
  Train.TrainDecoupleCarriage(self.tCarriageHandles[11])
  self.bDecouple = true
  self.ResistanceSpawners(self)
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\resistance\\PT_SpeedUpAfter", hSab, "SOE_2_Mission_2.SpeedupTrainTimer", self, {0}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\resistance\\PT_SpeedUpAfter")
end

function SOE_2_Mission_2:SpeedupTrainTimer()
  Train.TrainSetMaxSpeed("CountrySide\\centre\\AiRails\\AI_Rail_Starter", "8")
end

function SOE_2_Mission_2:ResistanceSpawners()
  self.tDespawnResistance = {}
  for i = 1, 4 do
    local x, y, z = Object.GetPosition(Util.GetHandleByName("Missions\\soe_2\\mission_2\\resistance\\LC_resistance" .. self.nResistanceSpawn .. i))
    Object.Spawn("RndHuman_RS_Fighter_MG", x, y, z, 0, nil, "SOE_2_Mission_2.MoveToCarriage", self, {1}, false)
  end
end

function SOE_2_Mission_2:MoveToCarriage(hwho)
  Nav.MoveToObject(hwho[1], self.tCarriageHandles[13], 10, true, "SOE_2_Mission_2.GetNagelOutAnimation", self, {
    hwho[1]
  }, false)
  self.tDespawnResistance[#self.tDespawnResistance + 1] = hwho[1]
end

function SOE_2_Mission_2:GetNagelOutAnimation(hwho)
  Actor.PlayAnimation(hwho[1], "Civ_point")
end

function SOE_2_Mission_2:DecoupleCheck()
  local hStuff = AttractionPt.FindPtInObject(self.tCarriageHandles[11], "TrainThrottle")
  if hStuff ~= nil then
    self.hDecoupleHandle = hStuff
  end
  self:KillTaskByName("StayBack")
  Cin.PlayConversation("S2M2_DecoupleCars")
  self:CreateTask({
    sName = "DecoupleCarriages",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    tTgtInclude = {
      self.hDecoupleHandle
    },
    sObjectiveTextID = "Decouple the train now!",
    ParentObjectID = self:GetTaskObjectiveID("FakeRescueTask"),
    tOnComplete = {
      {
        self.DecoupleTrainNow,
        {self}
      }
    }
  })
  self:RegisterEvent(Util.CreateEvent({
    EventType = "OnActorComplete",
    Target = self.hDecoupleHandle
  }, "SOE_2_Mission_2.DecoupleTrainNow", self))
end

function SOE_2_Mission_2:DecoupleFailed()
  if self.bDecouple == false then
    self.PlayConvoUsingQueue(self, "S2M2_TrainStop_Fail", 10, {})
    self:MissionTaskFail("S2M2_Fail.naziswerenotified")
  end
end

function SOE_2_Mission_2:BombCount()
  self.nBombPlaced = self.nBombPlaced + 1
  if self.nBombPlaced > 4 then
    self.Task_SurveyArea(self)
  end
end

function SOE_2_Mission_2:SetupCarriageHandleTable()
  self.tCarriageHandles = {}
  Train.TrainRegisterCarriageCallback("CountrySide\\centre\\AiRails\\AI_Rail_Starter", "SOE_2_Mission_2.AddCarriageHandleToTable", self)
  self.hTrainEngine = nil
  Train.TrainRegisterEngineCallback("CountrySide\\centre\\AiRails\\AI_Rail_Starter", "SOE_2_Mission_2.GetEngineHandle", self)
end

function SOE_2_Mission_2:GetEngineHandle(tdata)
  self.hTrainEngine = tdata[2]
end

function SOE_2_Mission_2:StoppingDifferently()
  if self.bDoNotStopTrain == false then
    self.bEnableTimerForTrain = true
    Train.TrainStop("CountrySide\\centre\\AiRails\\AI_Rail_Starter")
    self.SeanVOTrainStop(self)
    if self.bDoNotActivateAgain == false then
      self.Task_GetToEngine(self)
      self.bDoNotActivateAgain = true
    end
  end
end

function SOE_2_Mission_2:FailTimerEventAtCTstation()
  if self.bDoNotStopTrain == false then
    self.hTimerFailForTrain = HUD.AddObjective(eOT_TIMER, self:GetLocalizedText("S2M2_Text.RestartTrain"), 2)
    HUD.SetupProgressBar(self.hTimerFailForTrain, 190, 0, 190)
    HUD.AddProgressBarCallback(self.hTimerFailForTrain, "SOE_2_Mission_2.FailMissionByTimer", 0, self, {})
  end
end

function SOE_2_Mission_2:FailMissionByTimer()
  self:MissionTaskFail("S2M2_Fail.Didnotrestartontime")
end

function SOE_2_Mission_2:FailKesslerTimer()
  self:MissionTaskFail("S2M2_Fail.couldnotsavekessler")
end

function SOE_2_Mission_2:GetHandleEngineLater()
  local wtfpt = AttractionPt.FindPtInObject(self.hTrainEngine, "TrainThrottle")
  self.hATPT2 = wtfpt
  Train.TrainSetStopAtStation("CountrySide\\centre\\AiRails\\AI_Rail_Starter", true)
  self.Task_FullSpeedAhead(self)
end

function SOE_2_Mission_2:AddCarriageHandleToTable(tdata)
  if self.tCarriageHandles == nil then
    self.tCarriageHandles = {}
  end
  local what = tdata
  local whatthe = self
  self.tCarriageHandles[tdata[2] + 1] = tdata[3]
  self.tSaveInfo.nRealSize = self.tSaveInfo.nRealSize + 1
  if self.tSaveInfo.nRealSize > 10 then
    EVENT_Timer("SOE_2_Mission_2.RegisterCallbacks", self, 4)
  end
end

function SOE_2_Mission_2:StayByBack_()
  self:CreateTask({
    sName = "FakeRescueTask",
    sTaskType = "SabTaskObjectiveEmpty",
    Proximity = 5,
    ParentObjectID = self:GetTaskObjectiveID("FakeRescueNagel"),
    sTaskSubType = "None",
    tOnComplete = {},
    tOnActivate = {
      {
        self.StayByBack_,
        {self}
      }
    }
  })
end

function SOE_2_Mission_2:StayByBack()
  self:CreateTask({
    sName = "StayBack",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "Stay back of the train.",
    ParentObjectID = self:GetTaskObjectiveID("FakeRescueNagel"),
    tTgtInclude = {
      self.tCarriageHandles[11]
    }
  })
end

function SOE_2_Mission_2:UpdateLooperSeeTrainGuy()
  if self.bConvoTrainStoppedAtStation == false and self.bSeeTrainGuy == false and Object.IsAlive(self.hTrainGuy) then
    if Sensory.CanSee(hSab, self.hTrainGuy) then
      self.bSeeTrainGuy = true
      Cin.PlayConversation("S2M2_Conductor_SeesSean")
    else
      local tEvent = {EventType = "TimerEvent", Time = 1}
      self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.UpdateLooperSeeTrainGuy", self))
    end
  end
end

function SOE_2_Mission_2:UpdateLooperSeeRadioCar()
  if Object.IsAlive(self.hTrainGuy) then
    if Sensory.CanSee(hSab, self.tCarriageHandles[11]) and Object.GetDistance(hSab, self.tCarriageHandles[11]) < 10 then
      Cin.PlayConversationWith("S2M2_TrainComm_Sees", {
        self.hTrainGuy
      })
    else
      local tEvent = {EventType = "TimerEvent", Time = 1}
      self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.UpdateLooperSeeRadioCar", self))
    end
  end
end

function SOE_2_Mission_2:PlayerDeathSetup()
end

function SOE_2_Mission_2:DeathReset(tData)
  local nPlayerHealth = Object.GetHealth(hSab)
  local nDamage = tData[3]
  local a = 10
  a = 20
  local tEvent = {
    EventType = "DamageEvent",
    ObjectHandle = hSab
  }
  self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.DeathReset", self))
end

function SOE_2_Mission_2:EnterTrainYard()
  SOE_2_Mission_2:CreateTask({
    sName = "EnterTrainYard",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "S2M2_Text.EnterTrainYard",
    tLocators = {
      "Missions\\soe_2\\mission_2\\triggerbox\\LC_EnterTrainYard"
    },
    tDestRegion = "Missions\\soe_2\\mission_2\\triggerbox\\PT_EnterTrainYard",
    MarkerHeight = 7.5,
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        SOE_2_Mission_2.TrainAllLoadedIn,
        {SOE_2_Mission_2}
      }
    }
  })
end

function SOE_2_Mission_2:DisableTrainAP()
  if Train.TrainIsStreamedIn("CountrySide\\centre\\AiRails\\AI_Rail_Starter") then
    self.bTrainCreatedFirstTime = true
    local hTrainBomb = AttractionPt.FindPtInObject(self.tCarriageHandles[11], "TrainThrottle")
    AttractionPt.EnableUse(hTrainBomb, false)
    local hKesslerDoor = AttractionPt.FindPtInObject(self.tCarriageHandles[3], "TrainThrottle")
    AttractionPt.EnableUse(hKesslerDoor, false)
    local hUsePoint = AttractionPt.FindPtInObject(self.hTrainEngine, "TrainThrottle")
    AttractionPt.EnableUse(hUsePoint, false)
  else
    local tEvent = {EventType = "TimerEvent", Time = 2}
    self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.DisableTrainAP", self))
  end
end

function SOE_2_Mission_2:TrainAllLoadedIn()
  SOE_2_Mission_2.DisableTrainAP(self)
  if Train.TrainIsStreamedIn("CountrySide\\centre\\AiRails\\AI_Rail_Starter") then
    self.bTrainCreatedFirstTime = true
    self:CreateTask({
      sName = "MusicChangeEscalation3",
      sTaskType = "SabTaskObjectiveEscalation",
      sTaskSubType = "None",
      EscalationLevel = 1,
      bGTE = true,
      tOnComplete = {
        {
          self.ChangeMusic1,
          {self}
        }
      },
      tOnActivate = {}
    })
    self:CreateTask({
      sName = "Get_on_train_",
      sTaskType = "SabTaskObjectiveDeliver",
      Proximity = 0,
      sObjectiveTextID = "S2M2_Text.GoToTrain",
      sTaskSubType = "DELIVER",
      tDestProximityObj = {
        self.tCarriageHandles[12]
      },
      MarkerHeight = 7.5,
      tDeliverObjs = {hSab},
      tOnComplete = {
        {
          self.StartTrain,
          {self}
        },
        {
          self.Task_NearingEnd,
          {self}
        }
      }
    })
    self.nPlayerCarriageLocation = -1
    Inventory.GiveItem(hSab, "WP_SAB_BridgeKiller", false)
    local tEvent = {EventType = "TimerEvent", Time = 120}
    self.hTwoMinTimer = Util.CreateEvent(tEvent, "SOE_2_Mission_2.ChangeGetOnTrainName", self, {false})
    local hStuff = AttractionPt.FindPtInObject(self.tCarriageHandles[11], "TrainThrottle")
    if hStuff ~= nil then
      self.hDecoupleHandle = hStuff
    end
  else
    local tEvent = {EventType = "TimerEvent", Time = 1}
    self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.TrainAllLoadedIn", self))
  end
end

function SOE_2_Mission_2:DisableRadioProximity()
  Util.KillEvent(self.hTwoMinTimer)
  if self:IsMissionTaskActive("Get_on_train_") then
    self:CompleteTaskByName("Get_on_train_")
  end
end

function SOE_2_Mission_2:StartStreamedInTrain()
  Sound.SetMusicLocale("S2M2_Train")
  Sound.SetMusicLocale("m_S2M2_Train", "trainShootOut")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\ambientevents\\PT_RainOn", hSab, "SOE_2_Mission_2.RainOn", self, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\ambientevents\\PT_RainOn")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\ambientevents\\PT_RainOff", hSab, "SOE_2_Mission_2.RainOff", self, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\ambientevents\\PT_RainOff")
  if self.tSaveInfo.bTrainEventsStarted == false then
    self.tSaveInfo.bTrainEventsStarted = true
    self.UpdateLooperSeeTrainGuy(self)
    Train.TrainStart("CountrySide\\centre\\AiRails\\AI_Rail_Starter")
    self.tSaveInfo.bFailPlayerForDistance = true
    Train.TrainRegisterPlayerDistanceCallback("CountrySide\\centre\\AiRails\\AI_Rail_Starter", "SOE_2_Mission_2.TenMeterTip", 30, self)
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\triggerbox\\PT_starttrain", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {2}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\triggerbox\\PT_starttrain")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc2_bridge\\PT_StartSpeed", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {3}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc2_bridge\\PT_StartSpeed")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc2_bridge\\PT_TrainYard1", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {4}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc2_bridge\\PT_TrainYard1")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc2_bridge\\PT_TrainYard2", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {5}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc2_bridge\\PT_TrainYard2")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc2_bridge\\PT_TunnelEntrance", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {5}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc2_bridge\\PT_TunnelEntrance")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc3_chambord\\PT_TunnelEntrance2", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {7}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc3_chambord\\PT_TunnelEntrance2")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc2_bridge\\PT_TunnelExit", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {6}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc2_bridge\\PT_TunnelExit")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc3_chambord\\PT_TunnelExit2", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {5}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc3_chambord\\PT_TunnelExit2")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc2_bridge\\PT_BridgeSlow", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {4}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc2_bridge\\PT_BridgeSlow")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc2_bridge\\PT_BridgeFast1", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {6}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc2_bridge\\PT_BridgeFast1")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc2_bridge\\PT_BridgeFast2", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {8}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc2_bridge\\PT_BridgeFast2")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\triggerbox\\PT_ChateauxSlow1", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {4}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\triggerbox\\PT_ChateauxSlow1")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\triggerbox\\PT_ChateauxSlow2", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {3}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\triggerbox\\PT_ChateauxSlow2")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\triggerbox\\PT_ChateauxFast1", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {6}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\triggerbox\\PT_ChateauxFast1")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\triggerbox\\PT_ChateauxFast2", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {8}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\triggerbox\\PT_ChateauxFast2")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc4_station\\PT_StationSlow1", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {6}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc4_station\\PT_StationSlow1")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc4_station\\PT_StationSlow2", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {4}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc4_station\\PT_StationSlow2")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc4_station\\PT_StationSlow3", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {3}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc4_station\\PT_StationSlow3")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc4_station\\PT_StationFast", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {4}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc4_station\\PT_StationFast")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc4_station\\PT_BridgeSpeed1", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {6}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc4_station\\PT_BridgeSpeed1")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc4_station\\PT_BridgeSpeed2", hSab, "SOE_2_Mission_2.ChangeSpeed", self, {8}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc4_station\\PT_BridgeSpeed2")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\triggerbox\\PT_ChambordSpawner", hSab, "SOE_2_Mission_2.ActivateSpawners", self, {1}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\triggerbox\\PT_ChambordSpawner")
    if Handle("Missions\\soe_2\\mission_2\\enc4_station\\station\\PT_BunkerSpawner1") then
      self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc4_station\\station\\PT_BunkerSpawner1", hSab, "SOE_2_Mission_2.ActivateSpawners", self, {2}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc4_station\\station\\PT_BunkerSpawner1")
    end
    if Handle("Missions\\soe_2\\mission_2\\enc3_chambord\\PT_BunkerSpawner2") then
      self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc3_chambord\\PT_BunkerSpawner2", hSab, "SOE_2_Mission_2.ActivateSpawners", self, {3}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc3_chambord\\PT_BunkerSpawner2")
    end
    if Handle("Missions\\soe_2\\mission_2\\enc4_station\\station\\PT_BunkerSpawner3") then
      self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc4_station\\station\\PT_BunkerSpawner3", hSab, "SOE_2_Mission_2.ActivateSpawners", self, {4}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc4_station\\station\\PT_BunkerSpawner3")
    end
    if Handle("Missions\\soe_2\\mission_2\\enc4_station\\station\\PT_BunkerSpawner4") then
      self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc4_station\\station\\PT_BunkerSpawner4", hSab, "SOE_2_Mission_2.ActivateSpawners", self, {5}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc4_station\\station\\PT_BunkerSpawner4")
    end
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc3_chambord\\PT_BunkerSpawner2", hSab, "SOE_2_Mission_2.ActivateSpawners", self, {6}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc3_chambord\\PT_BunkerSpawner2")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc2_bridge\\PT_Decouple1_end", self.tCarriageHandles[11], "SOE_2_Mission_2.DecoupleFailed", self, {0}, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc2_bridge\\PT_Decouple1_end")
    self.nResistanceSpawn = 1
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\nazitotrain\\PT_TrainStopVO", hSab, "SOE_2_Mission_2.SeanVOTrainStop", self, {1}, cTRIGGEREVENT_ONENTER))
    self:RegisterEvent(Util.CreateEvent({
      EventType = "OnTriggerEnter",
      Target = Util.GetHandleByName("missions\\soe_2\\mission_2\\triggerbox\\PT_stopspawn")
    }, "SOE_2_Mission_2.StopSpawn", self))
    self:RegisterEvent(Util.CreateEvent({
      EventType = "OnTriggerEnter",
      Target = Util.GetHandleByName("missions\\soe_2\\mission_2\\triggerbox\\PT_speedresume")
    }, "SOE_2_Mission_2.ResumeNormalSpeed", self, nil, true))
    self:RegisterEvent(Util.CreateEvent({
      EventType = "OnTriggerEnter",
      Target = Util.GetHandleByName("missions\\soe_2\\mission_2\\triggerbox\\PT_speeddecrease")
    }, "SOE_2_Mission_2.SlowDownTrain", self))
    self:RegisterEvent(Util.CreateEvent({
      EventType = "OnTriggerEnter",
      Target = Util.GetHandleByName("missions\\soe_2\\mission_2\\triggerbox\\PT_speedincrease")
    }, "SOE_2_Mission_2.HyperSpeed", self))
    if Handle("Missions\\soe_2\\mission_2\\enc4_station\\station\\PT_BunkerSpawner1") then
      self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc4_station\\station\\PT_BunkerSpawner1", hSab, "SOE_2_Mission_2.SpawnTruckAndGo2", self, {
        {
          "Missions\\soe_2\\mission_2\\enc4_station\\LC_truck1"
        },
        {
          "Missions\\soe_2\\mission_2\\enc4_station\\PA_truck1"
        },
        {20},
        "blah",
        {1}
      }, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc4_station\\station\\PT_BunkerSpawner1")
    end
    self:RegisterEvent(Util.CreateEvent({
      EventType = "StreamEvent",
      Objects = {
        "Missions\\soe_2\\mission_2\\enc3_chambord\\Chambord_SpawnerB",
        "Missions\\soe_2\\mission_2\\enc3_chambord\\Chambord_SpawnerA"
      }
    }, "SOE_2_Mission_2.EnableSpawners", self, {1}))
    self:RegisterEvent(Util.CreateEvent({
      EventType = "StreamEvent",
      Objects = {
        "Missions\\soe_2\\mission_2\\enc4_station\\station\\BunkerSpawner1A",
        "Missions\\soe_2\\mission_2\\enc4_station\\station\\BunkerSpawner1B",
        "Missions\\soe_2\\mission_2\\enc4_station\\station\\BunkerSpawner1C"
      }
    }, "SOE_2_Mission_2.EnableSpawners", self, {2}))
    self:RegisterEvent(Util.CreateEvent({
      EventType = "StreamEvent",
      Objects = {
        "Missions\\soe_2\\mission_2\\enc4_station\\station\\BunkerSpawner2A"
      }
    }, "SOE_2_Mission_2.EnableSpawners", self, {3}))
    self.tBunkerSpawner2A = {
      "Missions\\soe_2\\mission_2\\enc4_station\\station\\PA_BunkerSpawner2A",
      "Missions\\soe_2\\mission_2\\enc4_station\\station\\PA_BunkerSpawner2B",
      "Missions\\soe_2\\mission_2\\enc4_station\\station\\PA_BunkerSpawner2C"
    }
    self:RegisterEvent(Util.CreateEvent({
      EventType = "StreamEvent",
      Objects = {
        "Missions\\soe_2\\mission_2\\enc4_station\\station\\BunkerSpawner3A"
      }
    }, "SOE_2_Mission_2.EnableSpawners", self, {4}))
    self:RegisterEvent(Util.CreateEvent({
      EventType = "StreamEvent",
      Objects = {
        "Missions\\soe_2\\mission_2\\enc4_station\\station\\BunkerSpawner4A"
      }
    }, "SOE_2_Mission_2.EnableSpawners", self, {5}))
    self.tBunkerSpawner4A = {
      "Missions\\soe_2\\mission_2\\enc4_station\\station\\PA_BunkerSpawner4A",
      "Missions\\soe_2\\mission_2\\enc4_station\\station\\PA_BunkerSpawner4B",
      "Missions\\soe_2\\mission_2\\enc4_station\\station\\PA_BunkerSpawner4C"
    }
    self:RegisterEvent(Util.CreateEvent({
      EventType = "StreamEvent",
      Objects = {
        "Missions\\soe_2\\mission_2\\enc3_chambord\\BunkerSpawner2"
      }
    }, "SOE_2_Mission_2.EnableSpawners", self, {6}))
    self.tBunkerSpawner5A = {
      "Missions\\soe_2\\mission_2\\enc3_chambord\\PA_BunkerSpawner2A",
      "Missions\\soe_2\\mission_2\\enc3_chambord\\PA_BunkerSpawner2B",
      "Missions\\soe_2\\mission_2\\enc3_chambord\\PA_BunkerSpawner2C",
      "Missions\\soe_2\\mission_2\\enc3_chambord\\PA_BunkerSpawner2D"
    }
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\naziclimb\\PT_chatchatter", hSab, "SOE_2_Mission_2.ChateuConvo", self, {
      "S2M2_ChateauNazis"
    }, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\naziclimb\\PT_chatchatter")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\naziclimb\\PT_Floorit", self.hTrainEngine, "SOE_2_Mission_2.CouldNotGetToKessler", self, nil, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\naziclimb\\PT_Floorit")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\triggerbox\\PT_derailtrain", self.hTrainEngine, "SOE_2_Mission_2.GetToKesslerWarning", self, nil, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\triggerbox\\PT_derailtrain")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\triggerbox\\PT_Checkpoint4", self.hTrainEngine, "SOE_2_Mission_2.SetupCheckpoint4", self, nil, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\triggerbox\\PT_Checkpoint4")
  end
end

function SOE_2_Mission_2:TrainDelayTimer()
  local tEvent = {EventType = "TimerEvent", Time = 6}
  self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.TrainBStart", self))
end

function SOE_2_Mission_2:BridgePatrolD1(tTable, sNaziName, sPathName)
  local hNazi = Handle(sNaziName)
  local sPath = sPathName
  if hNazi ~= nil then
    Nav.SetScriptedPath(hNazi, sPath, false)
    Nav.SetScriptedPathType(hNazi, cPATHTYPE_LOOP)
  end
end

function SOE_2_Mission_2:BridgePatrol(tTable, sNaziName, sPathName)
  EVENT_Timer("SOE_2_Mission_2.BridgePatrolD1", self, 2, {
    tTable,
    sNaziName,
    sPathName
  })
end

function SOE_2_Mission_2:TrainBStart()
  Train.TrainCreate("Missions\\soe_2\\mission_2\\enc3_chambord\\extra\\AI Rail Chain", "DtrainX")
  Train.TrainSetMaxSpeed("Missions\\soe_2\\mission_2\\enc3_chambord\\extra\\AI Rail Chain", 8)
  Train.TrainSetCurrSpeed("Missions\\soe_2\\mission_2\\enc3_chambord\\extra\\AI Rail Chain", 8)
end

function SOE_2_Mission_2:StartTrain()
  Util.KillEvent(self.hTwoMinTimer)
  Sound.PlayOwnerlessSoundEvent("Fol_train_whistle_S2M2")
  self.StartStreamedInTrain(self)
end

function SOE_2_Mission_2:GetToKesslerWarning()
  if self.bGotToKessler == false then
    self.PlayConvoUsingQueue(self, "S2M2_KesslerRescue_Hurry", 10, {})
  end
end

function SOE_2_Mission_2:CouldNotGetToKessler()
  if self.bGotToKessler == false then
    self.PlayConvoUsingQueue(self, "S2M2_KesslerRescue_Fail", 10, {})
    self.MissionFail(self, "S2M2_Fail.couldnotsavekessler")
  end
end

function SOE_2_Mission_2:ChateuConvo()
  self.PlayConvoUsingQueue(self, "S2M2_Chateau_Sees_Occupied", 10, {})
end

function SOE_2_Mission_2:SeanVOTrainStop()
  if self.bDoNotStopTrain == false then
    self.PlayConvoUsingQueue(self, "S2M2_TrainStop_CountryTrainStatin", 10, {})
    self.bConvoTrainStoppedAtStation = true
    self.bEnableTimerForTrain = true
  end
end

function SOE_2_Mission_2:LoadResFighters()
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\soe_2\\mission_2\\resistance2\\res1",
      "Missions\\soe_2\\mission_2\\resistance2\\res2",
      "Missions\\soe_2\\mission_2\\resistance2\\res3",
      "Missions\\soe_2\\mission_2\\resistance2\\res4",
      "Missions\\soe_2\\mission_2\\resistance2\\res5",
      "Missions\\soe_2\\mission_2\\resistance2\\res6",
      "Missions\\soe_2\\mission_2\\resistance2\\res7",
      "Missions\\soe_2\\mission_2\\resistance2\\res8",
      "Missions\\soe_2\\mission_2\\resistance2\\VH_CV_CR_Citroen6C_01",
      "Missions\\soe_2\\mission_2\\resistance2\\VH_CV_CR_Peugeot402_01",
      "Missions\\soe_2\\mission_2\\resistance2\\tar1",
      "Missions\\soe_2\\mission_2\\resistance2\\tar2"
    }
  }, "SOE_2_Mission_2.ResFightNow", self))
end

function SOE_2_Mission_2:ResFightNow()
  for i = 1, 8 do
    local hHandle = Util.GetHandleByName("Missions\\soe_2\\mission_2\\resistance2\\res" .. i)
    if hHandle then
      local nNum = 1
      if 4 < i then
        nNum = 2
      end
      local hTarget = WRAPPER_CheckForHandle("Missions\\soe_2\\mission_2\\resistance2\\tar" .. nNum)
      Combat.SetReactImmediately(hHandle, true)
      Combat.SetAimAndHitNoMiss(hHandle, true)
      Combat.SetRespondToEvents(hHandle, false)
      Suspicion.Enable(hHandle, false)
      Combat.SetAlwaysSeeTarget(hHandle, true)
      Combat.SetStationary(hHandle, true)
      Combat.SetReactImmediately(hHandle, true)
      Combat.SetTarget(hHandle, hTarget)
      Actor.FireCurrentWeapon(hSoldier)
      Combat.SetLethalForce(hHandle, true)
      Combat.SetCombat(hHandle)
    end
  end
end

function SOE_2_Mission_2:SetResistance(tData, nWhich)
  if self.bDecouple == false then
    self.nResistanceSpawn = nWhich
  end
end

function SOE_2_Mission_2:PlayConvoFile(tData, sConvoName, test)
  Cin.PlayConversation(sConvoName)
end

function SOE_2_Mission_2:PlayConvoFile2(tData, sConvoName, test)
  Cin.PlayConversation(test)
end

function SOE_2_Mission_2:EnableSpawners(nWhich)
  if nWhich == 1 then
    self.hSpawner = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc3_chambord\\Chambord_SpawnerA")
    self.nSpawnCounter1 = 1
    self:RegisterEvent(Util.CreateEvent({
      EventType = "OnSpawn",
      Target = self.hSpawner
    }, "SOE_2_Mission_2.OnSpawn", self, {1}, true))
    self.hSpawner2 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc3_chambord\\Chambord_SpawnerB")
    self.nSpawnCounter2 = 1
    self:RegisterEvent(Util.CreateEvent({
      EventType = "OnSpawn",
      Target = self.hSpawner2
    }, "SOE_2_Mission_2.OnSpawn", self, {2}, true))
  elseif nWhich == 2 then
    self.hSpawner3 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_station\\station\\BunkerSpawner1A")
    self:RegisterEvent(Util.CreateEvent({
      EventType = "OnSpawn",
      Target = self.hSpawner3
    }, "SOE_2_Mission_2.OnSpawn", self, {3}, true))
    self.hSpawner4 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_station\\station\\BunkerSpawner1B")
    self:RegisterEvent(Util.CreateEvent({
      EventType = "OnSpawn",
      Target = self.hSpawner4
    }, "SOE_2_Mission_2.OnSpawn", self, {4}, true))
    self.hSpawner5 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_station\\station\\BunkerSpawner1C")
    self:RegisterEvent(Util.CreateEvent({
      EventType = "OnSpawn",
      Target = self.hSpawner5
    }, "SOE_2_Mission_2.OnSpawn", self, {5}, true))
  elseif nWhich == 3 then
    self.hSpawner6 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_station\\station\\BunkerSpawner2A")
    self:RegisterEvent(Util.CreateEvent({
      EventType = "OnSpawn",
      Target = self.hSpawner6
    }, "SOE_2_Mission_2.OnSpawn", self, {6}, true))
  elseif nWhich == 4 then
    self.hSpawner7 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_station\\station\\BunkerSpawner3A")
    self:RegisterEvent(Util.CreateEvent({
      EventType = "OnSpawn",
      Target = self.hSpawner7
    }, "SOE_2_Mission_2.OnSpawn", self, {7}, true))
  elseif nWhich == 5 then
    self.hSpawner8 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_station\\station\\BunkerSpawner4A")
    self:RegisterEvent(Util.CreateEvent({
      EventType = "OnSpawn",
      Target = self.hSpawner8
    }, "SOE_2_Mission_2.OnSpawn", self, {8}, true))
  elseif nWhich == 6 then
    self.hSpawner9 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc3_chambord\\BunkerSpawner2")
    self:RegisterEvent(Util.CreateEvent({
      EventType = "OnSpawn",
      Target = self.hSpawner9
    }, "SOE_2_Mission_2.OnSpawn", self, {9}, true))
  end
end

function SOE_2_Mission_2:OnSpawn(hwho, tUserData)
  local a, b, c = Object.GetPosition(hwho[2])
  if tUserData == 1 then
    local x, y, z = Object.GetPosition(Util.GetHandleByName(self.tChambordAFirePositions[self.nSpawnCounter1]))
    Nav.MoveToPoint(hwho[2], x, y, z, true)
    Nav.SetScriptedPathMoveMode(hwho[2], true)
    self.nSpawnCounter1 = self.nSpawnCounter1 + 1
    if self.nSpawnCounter1 > 4 then
      self.nSpawnCounter1 = 1
    end
  elseif tUserData == 2 then
    local x, y, z = Object.GetPosition(Util.GetHandleByName(self.tChambordBFirePositions[self.nSpawnCounter2]))
    Nav.MoveToPoint(hwho[2], x, y, z, true)
    Nav.SetScriptedPathMoveMode(hwho[2], true)
    self.nSpawnCounter2 = self.nSpawnCounter2 + 1
    if 4 < self.nSpawnCounter2 then
      self.nSpawnCounter2 = 1
    end
  elseif tUserData == 3 then
    Nav.SetScriptedPath(hwho[2], "Missions\\soe_2\\mission_2\\enc4_station\\station\\PA_BunkerSpawner1A")
    Nav.SetScriptedPathMoveMode(hwho[2], true)
  elseif tUserData == 4 then
    Nav.SetScriptedPath(hwho[2], "Missions\\soe_2\\mission_2\\enc4_station\\station\\PA_BunkerSpawner1B")
    Nav.SetScriptedPathMoveMode(hwho[2], true)
  elseif tUserData == 5 then
    Nav.SetScriptedPath(hwho[2], "Missions\\soe_2\\mission_2\\enc4_station\\station\\PA_BunkerSpawner1C")
    Nav.SetScriptedPathMoveMode(hwho[2], true)
  elseif tUserData == 6 then
    Nav.SetScriptedPath(hwho[2], self.tBunkerSpawner2A[math.random(3)])
    Nav.SetScriptedPathMoveMode(hwho[2], true)
  elseif tUserData == 7 then
    Nav.SetScriptedPath(hwho[2], "Missions\\soe_2\\mission_2\\enc4_station\\station\\PA_BunkerSpawner3A")
    Nav.SetScriptedPathMoveMode(hwho[2], true)
  elseif tUserData == 8 then
    Nav.SetScriptedPath(hwho[2], self.tBunkerSpawner4A[math.random(3)])
    Nav.SetScriptedPathMoveMode(hwho[2], true)
  elseif tUserData == 9 then
    Nav.SetScriptedPath(hwho[2], self.tBunkerSpawner5A[math.random(4)])
    Nav.SetScriptedPathMoveMode(hwho[2], true)
  elseif tUserData == 100 then
    Nav.SetScriptedPath(hwho[2], "Missions\\soe_2\\mission_2\\starter\\lolpath")
    Nav.SetScriptedPathMoveMode(hwho[2], true)
  end
end

function SOE_2_Mission_2:ActivateSpawners(hwho, nWhich)
  if nWhich == 1 then
    Object.EnableSpawner(Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc3_chambord\\Chambord_SpawnerA"), true)
    Object.EnableSpawner(Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc3_chambord\\Chambord_SpawnerB"), true)
  elseif nWhich == 2 then
    Object.EnableSpawner(Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_station\\station\\BunkerSpawner1A"), true)
    Object.EnableSpawner(Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_station\\station\\BunkerSpawner1B"), true)
    Object.EnableSpawner(Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_station\\station\\BunkerSpawner1C"), true)
  elseif nWhich == 3 then
    Object.EnableSpawner(Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_station\\station\\BunkerSpawner2A"), true)
  elseif nWhich == 4 then
    Object.EnableSpawner(Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_station\\station\\BunkerSpawner3A"), true)
  elseif nWhich == 5 then
    Object.EnableSpawner(Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_station\\station\\BunkerSpawner4A"), true)
  elseif nWhich == 6 then
    Object.EnableSpawner(Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc3_chambord\\BunkerSpawner2"), true)
  end
end

function SOE_2_Mission_2:SpawnTruckAndGo(hwho, t_s_loclist, t_s_pathnames, t_n_speed, sCallbackFunction)
  if hwho[2] == hSab then
    local nLocListSize = #t_s_loclist
    for nCounter = 1, nLocListSize do
      local x, y, z = Object.GetPosition(Util.GetHandleByName(t_s_loclist[nCounter]))
      local rot = Object.GetAngle(Util.GetHandleByName(t_s_loclist[nCounter]))
      Object.Spawn("VH_NZ_TR_OpelCanvas_01", x, y, z, rot, nil, "SOE_2_Mission_2.TruckGoesOnPath", self, {
        t_s_pathnames[nCounter],
        t_n_speed,
        sCallbackFunction
      })
    end
  end
end

function SOE_2_Mission_2:SpawnTruckAndGo2(hwho, t_s_loclist, t_s_pathnames, t_n_speed, sCallbackFunction, t_nTimer)
  if hwho[2] == hSab then
    local nLocListSize = #t_s_loclist
    for nCounter = 1, nLocListSize do
      local tEvent = {EventType = "TimerEvent", Time = t_nTimer}
      self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.TruckSpawnEvent", self, {
        hwho,
        t_s_loclist[nCounter],
        t_s_pathnames[nCounter],
        t_n_speed[nCounter]
      }))
    end
  end
end

function SOE_2_Mission_2:TruckSpawnEvent(hwho, sSpawnLoc, sPathName, nSpeed, sCallbackFunction)
  local tVehSpawningStruct = {}
  tVehSpawningStruct[1] = {}
  tVehSpawningStruct[1].vSpawnTarget = sSpawnLoc
  tVehSpawningStruct[1].cVehicleType = cVEH_OPEL
  tVehSpawningStruct[1].tSeatConfig = "Human_WM_Grunt_MG"
  tVehSpawningStruct[1].bForceSpawn = true
  tVehSpawningStruct[1].cDespawnType = cDESPAWN_ONEXIT_LOS
  tVehSpawningStruct[1].sDeliveryPath = sPathName
  tVehSpawningStruct[1].cUnboardType = cDROPOFF_PASSENGERS_ALL
  tVehSpawningStruct[1].nPathSpeed = nSpeed
  Veh.SpawnDelivery(self, tVehSpawningStruct[1])
end

function SOE_2_Mission_2:TruckGoesOnPath2(hwho, sPathName, t_n_speed, sCallbackFunction)
  table.insert(self.t_hSpawnedEntity, hwho[1])
  Object.SpawnInVehicle("Human_WM_Grunt", "PILOT", hwho[1])
  Nav.SetScriptedPath(hwho[1], sPathName, false)
  Nav.SetScriptedPathSpeed(hwho[1], t_n_speed)
end

function SOE_2_Mission_2:TruckGoesOnPath(hwho, sPathName, t_n_speed, sCallbackFunction)
  self.AddEntityToTable(self, hwho)
  Object.SpawnInVehicle("Human_WM_Grunt", "PILOT", hwho[1], "SOE_2_Mission_2.AddEntityToTable", self)
  Nav.SetScriptedPath(hwho[1], sPathName, false, "SOE_2_Mission_2.MoveSoldiersSpecialCase")
  Nav.SetScriptedPathSpeed(hwho[1], t_n_speed)
end

function SOE_2_Mission_2:FullTruckGoesOnPath(hwho, sPathName, t_n_speed, sCallbackFunction)
  Object.SpawnInVehicle("Human_WM_Grunt", "PILOT", hwho[1], "SOE_2_Mission_2.AddEntityToTable", self)
  Object.SpawnInVehicle("Human_WM_Grunt", "SHOTGUN", hwho[1], "SOE_2_Mission_2.AddEntityToTable", self)
  Object.SpawnInVehicle("Human_WM_Grunt", "BACK_LEFT_END", hwho[1], "SOE_2_Mission_2.AddEntityToTable", self)
  Object.SpawnInVehicle("Human_WM_Grunt", "BACK_LEFT_MIDDLE", hwho[1], "SOE_2_Mission_2.AddEntityToTable", self)
  Object.SpawnInVehicle("Human_WM_Grunt", "BACK_RIGHT_END", hwho[1], "SOE_2_Mission_2.AddEntityToTable", self)
  Object.SpawnInVehicle("Human_WM_Grunt", "BACK_RIGHT_MIDDLE", hwho[1], "SOE_2_Mission_2.AddEntityToTable", self)
  Nav.SetScriptedPath(hwho[1], sPathName, false, "SOE_2_Mission_2.UnboardAndHunt", self, {
    hwho[1]
  })
  Nav.SetScriptedPathSpeed(hwho[1], t_n_speed)
end

function SOE_2_Mission_2:AddEntityToTable(hwho)
end

function SOE_2_Mission_2:UnboardAndHunt(tUserData)
  VEHICLE_UnboardAllPassengers(tUserData, "SOE_2_Mission_2.EmptyVehicles", self)
end

function SOE_2_Mission_2:EmptyVehicles(a_tPassengerData)
  local hSoldier = a_tPassengerData[1]
  self.AddEntityToTable(self, {hSoldier})
  Combat.SetTarget(hSoldier, Util.GetHandleByName("Saboteur"))
end

function SOE_2_Mission_2:DespawnList()
  for i, v in ipairs(self.t_hSpawnedEntity) do
    if Util.IsHandleValid(v) == true then
      Object.Despawn(v, 30, true)
    end
  end
end

function SOE_2_Mission_2:MoveSoldiersSpecialCase()
end

function SOE_2_Mission_2:SoldierWalkPath(hwho, t_s_soldierlist, t_s_pathnames)
  if hwho[2] == hSab then
    local nSoldierListSize = #t_s_soldierlist
    for nCounter = 1, nSoldierListSize do
    end
  end
end

function SOE_2_Mission_2:ResumeTrain(hwho)
  if hwho[2] == hSab then
    Train.TrainStart("CountrySide\\centre\\AiRails\\AI_Rail_Starter")
    Trigger.DoNotWaitFor("missions\\soe_2\\mission_2\\triggerbox\\PT_StopAtCheckpoint")
    Trigger.DoNotWaitFor("missions\\soe_2\\mission_2\\triggerbox\\PT_ResumeAtCheckpoint")
  end
end

function SOE_2_Mission_2:SpawnJumpingNazis2(hwho)
  if hwho[2] == hSab then
    self:RegisterEvent(Util.CreateEvent({EventType = "TimerEvent", Time = 0.5}, "SOE_2_Mission_2.TimedNumerousSpawns", self, {
      "Missions\\soe_2\\mission_2\\ambientevents\\spawnloc1"
    }))
    self:RegisterEvent(Util.CreateEvent({EventType = "TimerEvent", Time = 0.5}, "SOE_2_Mission_2.TimedNumerousSpawns", self, {
      "Missions\\soe_2\\mission_2\\ambientevents\\spawnloc2"
    }))
    self:RegisterEvent(Util.CreateEvent({EventType = "TimerEvent", Time = 1.5}, "SOE_2_Mission_2.TimedNumerousSpawns", self, {
      "Missions\\soe_2\\mission_2\\ambientevents\\spawnloc1"
    }))
    self:RegisterEvent(Util.CreateEvent({EventType = "TimerEvent", Time = 1.5}, "SOE_2_Mission_2.TimedNumerousSpawns", self, {
      "Missions\\soe_2\\mission_2\\ambientevents\\spawnloc2"
    }))
  end
end

function SOE_2_Mission_2:SpawnJumpingNazis(hwho)
  if hwho[2] == hSab then
    self:RegisterEvent(Util.CreateEvent({EventType = "TimerEvent", Time = 0.5}, "SOE_2_Mission_2.TimedNumerousSpawns", self, {
      "Missions\\soe_2\\mission_2\\nazispawnloc\\loc1"
    }))
    self:RegisterEvent(Util.CreateEvent({EventType = "TimerEvent", Time = 0.5}, "SOE_2_Mission_2.TimedNumerousSpawns", self, {
      "Missions\\soe_2\\mission_2\\nazispawnloc\\loc2"
    }))
    self:RegisterEvent(Util.CreateEvent({EventType = "TimerEvent", Time = 1.5}, "SOE_2_Mission_2.TimedNumerousSpawns", self, {
      "Missions\\soe_2\\mission_2\\nazispawnloc\\loc1"
    }))
    self:RegisterEvent(Util.CreateEvent({EventType = "TimerEvent", Time = 1.5}, "SOE_2_Mission_2.TimedNumerousSpawns", self, {
      "Missions\\soe_2\\mission_2\\nazispawnloc\\loc2"
    }))
  end
end

function SOE_2_Mission_2:StopSpawn()
  EVENT_KillEvent(self.hSpawnNazis)
end

function SOE_2_Mission_2:MoveToPointTemp(hwho)
end

function SOE_2_Mission_2:ChangeSpeed(hwho, hUserData)
  if self.bDoNotStopTrain == false then
    Train.TrainSetMaxSpeed("CountrySide\\centre\\AiRails\\AI_Rail_Starter", hUserData)
  end
end

function SOE_2_Mission_2:HyperSpeed()
  Train.TrainSetMaxSpeed("CountrySide\\centre\\AiRails\\AI_Rail_Starter", "25")
end

function SOE_2_Mission_2:SlowDownTrain()
  if self.bDoNotStopTrain == false then
    Train.TrainSetMaxSpeed("CountrySide\\centre\\AiRails\\AI_Rail_Starter", "5")
  end
end

function SOE_2_Mission_2:ResumeNormalSpeed()
  if self.bDoNotStopTrain == false then
    Train.TrainUseTrackMaxSpeed("CountrySide\\centre\\AiRails\\AI_Rail_Starter")
  end
end

function SOE_2_Mission_2:StopTrain()
  if self.bDoNotStopTrain == false then
    Train.TrainStop("CountrySide\\centre\\AiRails\\AI_Rail_Starter")
  end
end

function SOE_2_Mission_2:KeslerStreamingIn()
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\soe_2\\mission_2\\keslerescape\\Kesler",
      "Missions\\soe_2\\mission_2\\keslerescape\\res1",
      "Missions\\soe_2\\mission_2\\keslerescape\\res2",
      "Missions\\soe_2\\mission_2\\keslerescape\\res3",
      "Missions\\soe_2\\mission_2\\keslerescape\\escapecar"
    }
  }, "SOE_2_Mission_2.GetInCarAndDrive", self, {nil}, false))
end

function SOE_2_Mission_2:GetInCarAndDrive()
  local hDriver = Util.GetHandleByName("Missions\\soe_2\\mission_2\\keslerescape\\res1")
  local hPassenger1 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\keslerescape\\res2")
  local hPassenger2 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\keslerescape\\res3")
  local hCar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\keslerescape\\escapecar")
  local sPathName = "Missions\\soe_2\\mission_2\\keslerescape\\PA_pickup"
  Actor.BoardVehicle(hDriver, hCar, "PILOT")
  Actor.BoardVehicle(hPassenger1, hCar, "BACKSEAT_R")
  Actor.BoardVehicle(hPassenger2, hCar, "BACKSEAT_L")
  Nav.SetScriptedPath(hCar, sPathName, false, "SOE_2_Mission_2.HonkAndWait", self, {-1})
  Nav.SetScriptedPathSpeed(hCar, 15)
end

function SOE_2_Mission_2:HonkAndWait()
  local hPassenger1 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\keslerescape\\res2")
  local hPassenger2 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\keslerescape\\res3")
  local hTarget1 = WRAPPER_CheckForHandle("Missions\\soe_2\\mission_2\\keslerescape\\target2")
  local hTarget2 = WRAPPER_CheckForHandle("Missions\\soe_2\\mission_2\\keslerescape\\target3")
  Actor.UnboardVehicle(hPassenger1)
  Actor.UnboardVehicle(hPassenger2)
  EVENT_Timer("SOE_2_Mission_2.ResShootNow", self, 1)
  EVENT_Timer("SOE_2_Mission_2.KeslerRun", self, 6)
end

function SOE_2_Mission_2:ResShootNow()
  for i = 2, 3 do
    local hHandle = Util.GetHandleByName("Missions\\soe_2\\mission_2\\keslerescape\\res" .. i)
    local hTarget = WRAPPER_CheckForHandle("Missions\\soe_2\\mission_2\\keslerescape\\target" .. i)
    Combat.SetReactImmediately(hHandle, true)
    Combat.SetAimAndHitNoMiss(hHandle, true)
    Combat.SetRespondToEvents(hHandle, false)
    Combat.SetAlwaysSeeTarget(hHandle, true)
    Combat.SetStationary(hHandle, true)
    Combat.SetTarget(hHandle, hTarget)
    Combat.SetLethalForce(hHandle, true)
    Combat.SetCombat(hHandle)
  end
end

function SOE_2_Mission_2:KeslerRun()
  local hKesler = Util.GetHandleByName("Missions\\soe_2\\mission_2\\keslerescape\\Kesler")
  local hCar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\keslerescape\\escapecar")
  Nav.BoardVehicle(hKesler, hCar, "SHOTGUN", true, "SOE_2_Mission_2.MakeTheEscapeAndActivateTrain", self, {1})
end

function SOE_2_Mission_2:MakeTheEscapeAndActivateTrain()
  local hPassenger1 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\keslerescape\\res2")
  local hPassenger2 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\keslerescape\\res3")
  local hCar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\keslerescape\\escapecar")
  local sPathName = "Missions\\soe_2\\mission_2\\keslerescape\\PA_escape"
  Actor.BoardVehicle(hPassenger1, hCar, "BACKSEAT_R")
  Actor.BoardVehicle(hPassenger2, hCar, "BACKSEAT_L")
  Nav.SetScriptedPath(hCar, sPathName, false)
  Nav.SetScriptedPathSpeed(hCar, 15)
end

function SOE_2_Mission_2:StartUpTrainRecursive()
  if self.nPlayerCarriageLocation == 1 then
    Train.TrainStart("CountrySide\\centre\\AiRails\\AI_Rail_Starter")
    Trigger.DoNotWaitFor("missions\\soe_2\\mission_2\\triggerbox\\PT_StopAtCheckpoint")
  else
    EVENT_Timer("SOE_2_Mission_2.StartUpTrainRecursive", self, 0.5)
  end
end

function SOE_2_Mission_2:FailMissionDistance()
  local tEvent = {EventType = "TimerEvent", Time = 7.5}
  self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.FailMissionDistanceHackedDelay", self))
end

function SOE_2_Mission_2:FailMissionDistanceHackedDelay()
  if SOE_2_Mission_2.tSaveInfo.bFailPlayerForDistance == true and SOE_2_Mission_2:GetMissionTaskFail() == false then
    SOE_2_Mission_2.PlayConvoUsingQueue(SOE_2_Mission_2, "S2M2_TrainTooFar_Fail", 10, {})
    SOE_2_Mission_2:MissionTaskFail("S2M2_Fail.TooFarFromTrain")
  end
end

function SOE_2_Mission_2:OnTrainOnTime(hwho)
  if hwho[2] == hSab then
    EVENT_KillEvent(self.hPlayerOnTrain)
    Train.TrainRegisterPlayerDistanceCallback("CountrySide\\centre\\AiRails\\AI_Rail_Starter", "SOE_2_Mission_2.TenMeterTip", 75, self)
  end
end

function SOE_2_Mission_2:TenMeterTip()
  if self.tSaveInfo.bFailPlayerForDistance == true and self.tSaveInfo.bWarnPlayer10 == false then
    self.tSaveInfo.bWarnPlayer10 = true
    Train.TrainRegisterPlayerDistanceCallback("CountrySide\\centre\\AiRails\\AI_Rail_Starter", "SOE_2_Mission_2.TwentyMeterTip", 100, self)
    self.PlayConvoUsingQueue(self, "S2M2_TrainTooFar_Warning", 10, {})
  end
end

function SOE_2_Mission_2:TwentyMeterTip()
  if self.tSaveInfo.bFailPlayerForDistance == true and self.tSaveInfo.bWarnPlayer20 == false then
    self.tSaveInfo.bWarnPlayer20 = true
    self.PlayConvoUsingQueue(self, "S2M2_TrainTooFar_LastChance", 10, {})
    Train.TrainRegisterStreamoutCallback("CountrySide\\centre\\AiRails\\AI_Rail_Starter", "SOE_2_Mission_2.FailMissionDistance", self, {1})
  end
end

function SOE_2_Mission_2:SetFleetAway(hwho)
  if hwho[2] == hSab then
    Trigger.DoNotWaitFor("Missions\\soe_2\\mission_2\\enc5_bend\\PT_chateaux_truck1", hSab)
    self.SpawnTruckAndGo2(self, {-1, hSab}, {
      "Missions\\soe_2\\mission_2\\ambientevents\\LC_chateaux_truck1)"
    }, {
      "Missions\\soe_2\\mission_2\\ambientevents\\PA_chateaux_truck1"
    }, {35}, "SOE_2_Mission_2.FullTruckGoesOnPath", {1})
  end
end

function SOE_2_Mission_2:RegisterCallbacks()
  self.CreateLadderTable(self)
  local nSize = #self.tCarriageHandles
  for i = 1, #self.tCarriageHandles do
    Train.TrainRegisterPlayerCarriageTriggerCallback(self.tCarriageHandles[i], "SOE_2_Mission_2.UpdatePlayerLocation", self, {i})
  end
end

function SOE_2_Mission_2:UpdatePlayerLocation(tData, nUserData)
  if self.nPlayerCarriageLocation == -1 then
    if self:IsMissionTaskActive("Get_on_train_") then
      self:CompleteTaskByName("Get_on_train_")
    end
    if self.hDisableRadioCarEvent ~= nil then
      Util.KillEvent(self.hDisableRadioCarEvent)
    end
  end
  if self.nPlayerCarriageLocation ~= nUserData and self.nPlayerCarriageLocation ~= -1 then
    self.ReRegisterCallbacks(self, {
      self.nPlayerCarriageLocation
    })
  end
  self.nPlayerCarriageLocation = nUserData
  if self.bHaveGoneOnTrain == false then
    self.bHaveGoneOnTrain = true
    if nUserData ~= 11 then
    end
  end
  if nUserData == 11 and self.bHasGoneOneRadioCar == false then
    self.bHasGoneOneRadioCar = true
  end
  if nUserData == 3 and self.bStillStuffToDoBeforeRescueKesler == true then
    self.bStillStuffToDoBeforeRescueKesler = false
    self.PlayConvoUsingQueue(self, "S2M2_KesslerRescue_OnCar_Early", 10, {})
  end
  if nUserData == 2 and self.bFirstTimeOnCoalCar == false then
    self.bFirstTimeOnCoalCar = true
    if self.bDoNotStopTrain ~= true and self.bConvoTrainStoppedAtStation == false and self.bSeeTrainGuy == false then
      self.bSeeTrainGuy = true
      if self.hTrainGuy ~= nil then
        Cin.PlayConversationWith("S2M2_TrainStop_SpottedNearEngine", {
          self.hTrainGuy,
          self.hTrainNaziWithConductor[1]
        })
      else
        Cin.PlayConversationWith("S2M2_TrainStop_SpottedNearEngine", {
          self.hTrainNaziWithConductor[1],
          self.hTrainNaziWithConductor[2]
        })
      end
    end
  end
  self.bHaveGoneOnTrain = true
end

function SOE_2_Mission_2:ReRegisterCallbacks(nUserData)
  local i = nUserData[1]
  Train.TrainRegisterPlayerCarriageTriggerCallback(self.tCarriageHandles[i], "SOE_2_Mission_2.UpdatePlayerLocation", self, {i})
end

function SOE_2_Mission_2:TimeSpawning1(hwho)
  if self.nPlayerCarriageLocation < 11 and hwho[2] == self.tCarriageHandles[self.nPlayerCarriageLocation + 1] then
    self:RegisterEvent(Util.CreateEvent({EventType = "TimerEvent", Time = 0.1}, "SOE_2_Mission_2.TimedNumerousSpawns", self, {
      "Missions\\soe_2\\mission_2\\nazispawnloc\\loc1"
    }))
    self:RegisterEvent(Util.CreateEvent({EventType = "TimerEvent", Time = 0.2}, "SOE_2_Mission_2.TimedNumerousSpawns", self, {
      "Missions\\soe_2\\mission_2\\nazispawnloc\\loc2"
    }))
    self:RegisterEvent(Util.CreateEvent({EventType = "TimerEvent", Time = 0.4}, "SOE_2_Mission_2.TimedNumerousSpawns", self, {
      "Missions\\soe_2\\mission_2\\nazispawnloc\\loc1"
    }))
    self:RegisterEvent(Util.CreateEvent({EventType = "TimerEvent", Time = 0.5}, "SOE_2_Mission_2.TimedNumerousSpawns", self, {
      "Missions\\soe_2\\mission_2\\nazispawnloc\\loc2"
    }))
  end
end

function SOE_2_Mission_2:TimedNumerousSpawns(loc1)
  local x, y, z, rot
  x, y, z = Object.GetPosition(Util.GetHandleByName(loc1))
  rot = Object.GetAngle(Util.GetHandleByName(loc1))
  Object.Spawn("Human_WM_Grunt", x, y, z, rot, nil, "SOE_2_Mission_2.MoveToPointTemp", self, {-1}, false)
end

function SOE_2_Mission_2:Task_SurveyArea()
  self:CreateTask({
    sName = "GetToPoint2",
    sTaskType = "SabTaskObjectiveDeliver",
    Proximity = 30,
    sTaskSubType = "DELIVER",
    sObjectiveTextID = "Survey the train area.",
    tDestProximityObj = {"point2"},
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Task_BoardTrain,
        {self}
      }
    }
  })
end

function SOE_2_Mission_2:Task_BoardTrain()
  self:CreateTask({
    sName = "GetToPoint3",
    sTaskType = "SabTaskObjectiveDeliver",
    Proximity = 30,
    sTaskSubType = "DELIVER",
    sObjectiveTextID = "Board the train",
    tDestProximityObj = {"point3"},
    tDeliverObjs = {hSab},
    tOnComplete = {
      {}
    }
  })
end

function SOE_2_Mission_2:Task_GetToEngine()
  self.bDoNotActivateAgain = true
  self:CreateTask({
    sName = "ENGROOMPART",
    sTaskType = "SabTaskObjectiveDeliver",
    Proximity = 20,
    sTaskSubType = "DELIVER",
    sObjectiveTextID = "S2M2_Text.GetToEngineCar",
    ParentObjectID = self:GetTaskObjectiveID("FakeRescueNagel"),
    tDestProximityObj = {
      self.hTrainEngine
    },
    MarkerHeight = 7.5,
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.CheckConditions,
        {self}
      }
    }
  })
end

function SOE_2_Mission_2:CheckConditions()
  if Object.IsAlive(self.hTrainGuy) then
    self.KillOperator(self)
  else
    self.Task_GetToEngine2(self)
  end
end

function SOE_2_Mission_2:Task_GetToEngine2()
  local hKesslerDoor = AttractionPt.FindPtInObject(self.tCarriageHandles[3], "TrainThrottle")
  AttractionPt.EnableUse(hKesslerDoor, false)
  local hUsePoint = AttractionPt.FindPtInObject(self.hTrainEngine, "TrainThrottle")
  AttractionPt.EnableUse(hUsePoint, false)
  if self.hATPT2 ~= nil then
    local stextid
    if self.bDoNotStopTrain == false then
      stextid = "Lock the engine lever"
    else
      stextid = "Start up the engine"
    end
    stextid = "Jam throttle"
    self:CreateTask({
      sName = "GetToPoint4",
      sTaskType = "SabTaskObjectiveInteract",
      sTaskSubType = "USE",
      tTgtInclude = {
        self.hATPT2
      },
      sObjectiveTextID = "S2M2_Text.JamThrottle",
      MarkerHeight = 2,
      tOnComplete = {
        {
          self.HaulAss,
          {self}
        }
      }
    })
  end
end

function SOE_2_Mission_2:FakeCallbacks()
end

function SOE_2_Mission_2:StopFollowing()
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  Nav.CancelFollowObject(hSkylar)
end

function SOE_2_Mission_2:WilcoxGoIntoCar()
  local hWil = Util.GetHandleByName("Missions\\soe_2\\mission_2\\wilcoxandskylar\\Spore_RS_Wilcox")
  local hVeh = Util.GetHandleByName("Missions\\soe_2\\mission_2\\wilcoxandskylar\\VH_CV_CR_TalbotLago_01")
  Actor.BoardVehicle(hWil, hVeh, "PILOT")
end

function SOE_2_Mission_2:WilcoxSignal()
  EVENT_PlayerEntersVehicle("SOE_2_Mission_2.FinishTalkingWithWilcox", self, "Missions\\soe_2\\mission_2\\wilcoxandskylar\\VH_CV_CR_TalbotLago_01")
  self:CreateTask({
    sName = "FakeGetIntoCar",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sObjectiveTextID = "Get inside Wilcox's car.",
    tTgtInclude = {
      "Missions\\soe_2\\mission_2\\wilcoxandskylar\\Spore_RS_Wilcox"
    }
  })
end

function SOE_2_Mission_2:FinishTalkingWithWilcox()
  EVENT_PlayerExitsAnyVehicle("SOE_2_Mission_2.Task_Setup_Bombs", self)
end

function SOE_2_Mission_2:ChangeMusic1()
end

function SOE_2_Mission_2:ChangeMusic()
end

function SOE_2_Mission_2:PlayS2M2_trainyard()
  Cin.PlayConversation("S2M2_SeeTrain")
end

function SOE_2_Mission_2:TrainYardClimb()
  self.NaziClimbOnTrain(self, {1}, 11, "Missions\\soe_2\\mission_2\\naziclimb\\climb1", "Missions\\soe_2\\mission_2\\naziclimb\\spawn1", 0, false, 10)
  self.NaziClimbOnTrain(self, {1}, 11, "Missions\\soe_2\\mission_2\\naziclimb\\climb1", "Missions\\soe_2\\mission_2\\naziclimb\\spawn1", 0, false, 10)
  self.NaziClimbOnTrain(self, {1}, 11, "Missions\\soe_2\\mission_2\\naziclimb\\climb2", "Missions\\soe_2\\mission_2\\naziclimb\\spawn2", 0, false, 10)
  self.NaziClimbOnTrain(self, {1}, 11, "Missions\\soe_2\\mission_2\\naziclimb\\climb3", "Missions\\soe_2\\mission_2\\naziclimb\\spawn3", 0, false, 10)
  self.NaziClimbOnTrain(self, {1}, 11, "Missions\\soe_2\\mission_2\\naziclimb\\climb3", "Missions\\soe_2\\mission_2\\naziclimb\\spawn3", 0, false, 10)
  self.NaziJumpToTrain(self, {1}, 0, "Missions\\soe_2\\mission_2\\naziclimb\\jump4", "Missions\\soe_2\\mission_2\\naziclimb\\spawn4", 0, true, 12.5)
end

function SOE_2_Mission_2:SpawnTrainNazi()
  Train.TrainSpawnNazi(self.tCarriageHandles[13], "Human_WM_Grunt", false, "Missions\\soe_2\\mission_2\\cinemaspline\\Locator", "SOE_2_Mission_2.JumpToTrainNazi", self)
end

function SOE_2_Mission_2:JumpToTrainNazi(hwho)
  Actor.PlayAnimation(hwho[3], "nazi_jump_to_train")
  local tEvent = {EventType = "TimerEvent", Time = 2}
  self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.ConvertToTrainNazi", self, {
    hwho[3]
  }))
end

function SOE_2_Mission_2:ClimbOnTrainNazi()
end

function SOE_2_Mission_2:ConvertToTrainNazi(hwho)
  Train.TrainSpawnNaziReachedDestination(self.tCarriageHandles[13], hwho)
end

function SOE_2_Mission_2:Task_FullSpeedAhead()
end

function SOE_2_Mission_2:CreateLadderTable()
  if self.tLadderTable == nil then
    self.tLadderTable = {}
  end
  for i = 1, 13 do
    self.tLadderTable[i] = nil
    local hATPT = AttractionPt.FindPtInObject(self.tCarriageHandles[i], "TrainClimb")
    if hATPT ~= nil then
      self.tLadderTable[i] = hATPT
    end
  end
end

function SOE_2_Mission_2:HaulAss()
  local hKesslerDoor = AttractionPt.FindPtInObject(self.tCarriageHandles[3], "TrainThrottle")
  AttractionPt.EnableUse(hKesslerDoor, true)
  local hUsePoint = AttractionPt.FindPtInObject(self.hTrainEngine, "TrainThrottle")
  AttractionPt.EnableUse(hUsePoint, false)
  self.bDoNotStopTrain = true
  Train.TrainSetStopAtStation("CountrySide\\centre\\AiRails\\AI_Rail_Starter", false)
  self.bStillStuffToDoBeforeRescueKesler = false
  self.TalkToKesler(self)
  self.PlayConvoUsingQueue(self, "S2M2_TrainEngine_Complete", 20, {})
  self.PlayConvoUsingQueue(self, "S2M2_KesslerRescue_Start", 10, {})
  self:KillTaskByName("ENGINEFULLSPEED")
  self:KillTaskByName("GetToPoint4")
  self:KillTaskByName("ENGROOMPART")
  self:KillTaskByName("FakeRescueNagel")
  Train.TrainStart("CountrySide\\centre\\AiRails\\AI_Rail_Starter")
  Train.TrainSetMaxSpeed("CountrySide\\centre\\AiRails\\AI_Rail_Starter", "8")
  Sound.LoadSoundBank("cin_S2M2_end.bnk")
end

function SOE_2_Mission_2:CoalCarJumpers()
end

function SOE_2_Mission_2:Chatarea()
end

function SOE_2_Mission_2:BridgeArea1()
end

function SOE_2_Mission_2:Bridgearea2()
end

function SOE_2_Mission_2:NaziJumpToTrain(tTable, nCarriage, sJumpLoc, sSpawnLoc, nDelay, bfront, nDist)
  Train.TrainSpawnNazi(self.tCarriageHandles[math.random(1, 10)], "Human_SS_Heavy_MG", false, sSpawnLoc, "SOE_2_Mission_2.NaziJumpToTrainPT2", self, {
    nCarriage,
    sJumpLoc,
    sSpawnLoc,
    nDelay,
    bfront,
    nDist
  })
end

function SOE_2_Mission_2:NaziJumpToTrainPT2(hwho, nCarriage, sJumpLoc, sSpawnLoc, nDelay, bfront, nDist)
  Actor.OverrideCombatAI(hwho[3], true)
  local tEvent = {EventType = "TimerEvent", Time = nDelay}
  self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2._NaziJumpToTrain", self, {
    hwho[3],
    nCarriage,
    sJumpLoc,
    sSpawnLoc,
    bfront,
    nDist
  }))
end

function SOE_2_Mission_2:_NaziJumpToTrain(hwho, nCarriage, sJumpLoc, sSpawnLoc, bfront, nDist)
  local x, y, z = Object.GetPosition(Util.GetHandleByName(sJumpLoc))
  Nav.MoveToObject(hwho, Util.GetHandleByName(sJumpLoc), 1, true, "SOE_2_Mission_2.__NaziJumpToTrain", self, {
    hwho,
    nCarriage,
    sJumpLoc,
    sSpawnLoc,
    bfront,
    nDist
  })
end

function SOE_2_Mission_2:FakeTeleportNazi(hwho, sJumpLoc, nCarriage)
  local x, y, z = Object.GetPosition(Util.GetHandleByName(sJumpLoc .. "(1)"))
  Object.Teleport(hwho, x, y, z, 0)
  local tEvent = {EventType = "TimerEvent", Time = 0.5}
  self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.ConvertNazitoTrainNazi", self, {hwho, nCarriage}))
end

function SOE_2_Mission_2:PickCorrectLowCarriage()
  if self.nPlayerCarriageLocation > 9 then
    return 9
  elseif self.nPlayerCarriageLocation > 7 then
    return 7
  end
  return 6
end

function SOE_2_Mission_2:PickCorrectCarriage()
  if self.nPlayerCarriageLocation > 10 then
    return 10
  elseif self.nPlayerCarriageLocation > 8 then
    return 8
  elseif self.nPlayerCarriageLocation > 6 then
    return 6
  elseif self.nPlayerCarriageLocation > 5 then
    return 5
  elseif self.nPlayerCarriageLocation > 4 then
    return 4
  end
  return 4
end

function SOE_2_Mission_2:__NaziJumpToTrain(hwho, nCarriage, sJumpLoc, sSpawnLoc, bfront, nDist)
  Combat.SetStationary(hwho, true)
  Combat.LockIntoRanged(hwho)
  Actor.OverrideCombatAI(hwho, false)
  Combat.SetIdleScripted(hwho, false)
  local nWhichCarriage = 1
  if nCarriage == 1 then
    nWhichCarriage = self.PickCorrectCarriage(self)
  elseif nCarriage == -1 then
    nWhichCarriage = self.PickCorrectLowCarriage(self)
  elseif nCarriage == 0 then
    if self.nPlayerCarriageLocation == 10 or self.nPlayerCarriageLocation == 8 or self.nPlayerCarriageLocation == 6 or self.nPlayerCarriageLocation == 5 or self.nPlayerCarriageLocation == 4 then
      nWhichCarriage = self.nPlayerCarriageLocation
    else
      nWhichCarriage = self.PickCorrectCarriage(self)
    end
  end
  local hBone = Object.GetBoneHandleFromCarriage(self.tCarriageHandles[nWhichCarriage], bfront)
  self:RegisterEvent(Util.CreateEvent({
    EventType = "ProximityEventBone",
    ObjectA = hwho,
    ObjectB = self.tCarriageHandles[nWhichCarriage],
    BoneB = hBone,
    Proximity = nDist,
    Negate = false
  }, "SOE_2_Mission_2.___NaziJumpToTrain", self, {
    hwho,
    nWhichCarriage,
    sJumpLoc,
    sSpawnLoc,
    bfront
  }, false))
end

function SOE_2_Mission_2:___NaziJumpToTrain(hwho, nCarriage, sJumpLoc, sSpawnLoc, bfront)
  Combat.SetStationary(hwho, false)
  Actor.OverrideCombatAI(hwho, true)
  Actor.SetSlowCollision(hwho, true)
  local hBone = Object.GetBoneHandleFromCarriage(self.tCarriageHandles[nCarriage], bfront)
  Actor.PlayAnimationToBone(hwho, "nazi_jump_to_train", self.tCarriageHandles[nCarriage], hBone, "SOE_2_Mission_2.ConvertNazitoTrainNazi", self, {hwho, nCarriage})
end

function SOE_2_Mission_2:TESTYTESTY(nwhat, nlol)
end

function SOE_2_Mission_2:NaziClimbOnTrain(tTable, nCarriage, sJumpLoc, sSpawnLoc, nDelay, bfront, nDist)
  Train.TrainSpawnNazi(self.tCarriageHandles[math.random(1, 13)], "Human_SS_Heavy_MG", false, sSpawnLoc, "SOE_2_Mission_2.NaziClimbOnTrainPT2", self, {
    nCarriage,
    sJumpLoc,
    sSpawnLoc,
    nDelay,
    bfront,
    nDist
  })
end

function SOE_2_Mission_2:NaziClimbOnTrainPT2(hwho, nCarriage, sJumpLoc, sSpawnLoc, nDelay, bfront, nDist)
  Actor.OverrideCombatAI(hwho[3], true)
  local tEvent = {EventType = "TimerEvent", Time = nDelay}
  self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2._NaziClimbOnTrain", self, {
    hwho[3],
    nCarriage,
    sJumpLoc,
    sSpawnLoc,
    bfront,
    nDist
  }))
end

function SOE_2_Mission_2:_NaziClimbOnTrain(hwho, nCarriage, sJumpLoc, sSpawnLoc, bfront, nDist)
  local x, y, z = Object.GetPosition(Util.GetHandleByName(sJumpLoc))
  Nav.MoveToPoint(hwho, x, y, z, true, "SOE_2_Mission_2.__NaziClimbOnTrain", self, {
    hwho,
    nCarriage,
    sJumpLoc,
    sSpawnLoc,
    bfront,
    nDist
  })
end

function SOE_2_Mission_2:__NaziClimbOnTrain(hwho, nCarriage, sJumpLoc, sSpawnLoc, bfront, nDist)
  Combat.SetStationary(hwho, true)
  Combat.LockIntoRanged(hwho)
  Actor.OverrideCombatAI(hwho, false)
  local hBone
  if nCarriage == 11 then
    if bfront == true then
      hBone = Util.GetCRC("hp_Ladder_B_Start")
    else
      hBone = Util.GetCRC("hp_Ladder_C_Start")
    end
  else
    hBone = Util.GetCRC("hp_Ladder_A_Start")
  end
  self:RegisterEvent(Util.CreateEvent({
    EventType = "ProximityEventBone",
    ObjectA = hwho,
    ObjectB = self.tCarriageHandles[nCarriage],
    BoneB = hBone,
    Proximity = nDist,
    Negate = false
  }, "SOE_2_Mission_2.___NaziClimbOnTrain", self, {
    hwho,
    nCarriage,
    sJumpLoc,
    sSpawnLoc,
    bfront
  }, false))
end

function SOE_2_Mission_2:___NaziClimbOnTrain(hwho, nCarriage, sJumpLoc, sSpawnLoc, bfront)
  Combat.SetStationary(hwho, false)
  Actor.OverrideCombatAI(hwho, true)
  Actor.SetSlowCollision(hwho, true)
  local hBone
  if nCarriage == 11 then
    if bfront == true then
      hBone = Util.GetCRC("hp_Ladder_B_End")
    else
      hBone = Util.GetCRC("hp_Ladder_C_End")
    end
  else
    hBone = Util.GetCRC("hp_Ladder_A_End")
  end
  Actor.PlayAnimationToBone(hwho, "nazi_climb_up_train", self.tCarriageHandles[nCarriage], hBone, "SOE_2_Mission_2.ConvertNazitoTrainNazi", self, {hwho, nCarriage})
end

function SOE_2_Mission_2:ConvertNazitoTrainNazi(hwho, nCarriage)
  Train.TrainSpawnNaziReachedDestination(self.tCarriageHandles[nCarriage], hwho)
  Actor.OverrideCombatAI(hwho, false)
end

function SOE_2_Mission_2:SpawnAndClimbNazi(tTable, sSpawnLoc)
  for i = 1, 13 do
    if self.tLadderTable[i] ~= nil then
      self.NaziClimbOnTrain(self, i, sSpawnLoc)
    end
  end
end

function SOE_2_Mission_2:SetupWTFEvents()
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\soe_2\\mission_2\\enc5_bend\\OccMed_OilTank_C(5)\\OccMed_OilTank_C",
      "Missions\\soe_2\\mission_2\\enc5_bend\\OccMed_OilTank_C(6)\\OccMed_OilTank_C",
      "Missions\\soe_2\\mission_2\\enc5_bend\\OccMed_OilTank_E(3)\\OccMed_OilTank_E",
      "Missions\\soe_2\\mission_2\\enc4_station\\Barrel_of_boom_smrad(8)"
    }
  }, "SOE_2_Mission_2.WTFSparklemotion2", self))
  local tPossibleStuff = {}
  tPossibleStuff[1] = "Missions\\soe_2\\mission_2\\enc5_bend\\OccMed_OilTank_E\\OccMed_OilTank_E"
  tPossibleStuff[2] = "Missions\\soe_2\\mission_2\\enc3_chambord\\OccMed_OilTank_E\\OccMed_OilTank_E"
  tPossibleStuff[3] = "Missions\\soe_2\\mission_2\\enc5_bend\\OccMed_OilTank_C(2)\\OccMed_OilTank_C"
  tPossibleStuff[4] = "Missions\\soe_2\\mission_2\\enc5_bend\\OccMed_OilTank_C\\OccMed_OilTank_C"
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = tPossibleStuff
  }, "SOE_2_Mission_2.WTFSparklemotion3", self))
  tPossibleStuff[1] = "Missions\\soe_2\\mission_2\\enc4_station\\Barrel_of_boom_smrad(65)"
  tPossibleStuff[2] = "Missions\\soe_2\\mission_2\\enc4_station\\Barrel_of_boom_smrad(58)"
  tPossibleStuff[3] = "Missions\\soe_2\\mission_2\\enc4_station\\Barrel_of_boom_smrad"
  tPossibleStuff[4] = "Missions\\soe_2\\mission_2\\enc4_station\\Barrel_of_boom_smrad(62)"
  tPossibleStuff[5] = "Missions\\soe_2\\mission_2\\enc4_station\\Barrel_of_boom_smrad(64)"
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = tPossibleStuff
  }, "SOE_2_Mission_2.WTFSparklemotion4", self))
end

function SOE_2_Mission_2:WTFSparklemotion1()
  local tPossibleStuff = {}
  tPossibleStuff[1] = "Missions\\soe_2\\mission_2\\enc1_start\\OccMed_OilTank_C(1)\\OccMed_OilTank_C"
  tPossibleStuff[2] = "Missions\\soe_2\\mission_2\\enc1_start\\OccMed_OilTank_C(2)\\OccMed_OilTank_C"
  tPossibleStuff[3] = "Missions\\soe_2\\mission_2\\enc1_start\\OccMed_OilTank_C(3)\\OccMed_OilTank_C"
  tPossibleStuff[4] = "Missions\\soe_2\\mission_2\\enc1_start\\OccMed_OilTank_C(4)\\OccMed_OilTank_C"
  tPossibleStuff[5] = "Missions\\soe_2\\mission_2\\enc1_start\\OccMed_OilTank_C(5)\\OccMed_OilTank_C"
  tPossibleStuff[6] = "Missions\\soe_2\\mission_2\\enc1_start\\OccMed_OilTank_C(6)\\OccMed_OilTank_C"
  tPossibleStuff[7] = "Missions\\soe_2\\mission_2\\enc1_start\\OccMed_OilTank_C(7)\\OccMed_OilTank_C"
  tPossibleStuff[8] = "Missions\\soe_2\\mission_2\\enc1_start\\OccMed_OilTank_C(8)\\OccMed_OilTank_C"
  tPossibleStuff[9] = "Missions\\soe_2\\mission_2\\enc1_start\\OccMed_OilTank_C(9)\\OccMed_OilTank_C"
  tPossibleStuff[10] = "Missions\\soe_2\\mission_2\\enc1_start\\OccMed_OilTank_C(10)\\OccMed_OilTank_C"
  tPossibleStuff[11] = "Missions\\soe_2\\mission_2\\enc1_start\\OccMed_OilTank_E\\OccMed_OilTank_E"
  tPossibleStuff[12] = "Missions\\soe_2\\mission_2\\enc1_start\\OccMed_OilTank_E(1)\\OccMed_OilTank_E"
  tPossibleStuff[13] = "Missions\\soe_2\\mission_2\\enc1_start\\OccMed_OilTank_E(2)\\OccMed_OilTank_E"
  tPossibleStuff[14] = "Missions\\soe_2\\mission_2\\enc1_start\\OccMed_OilTank_E(3)\\OccMed_OilTank_E"
  tPossibleStuff[15] = "Missions\\soe_2\\mission_2\\enc1_start\\OccMed_OilTank_D\\OccMed_OilTank_D"
  tPossibleStuff[16] = "Missions\\soe_2\\mission_2\\enc1_start\\OccMed_OilTank_D(1)\\OccMed_OilTank_D"
  tPossibleStuff[17] = "Missions\\soe_2\\mission_2\\enc1_start\\OccMed_OilTank_D(2)\\OccMed_OilTank_D"
  tPossibleStuff[18] = "Missions\\soe_2\\mission_2\\enc1_start\\OccMed_OilTank_D(3)\\OccMed_OilTank_D"
  local tKillTargets = {}
  for i = 1, 18 do
    local hKill = Util.GetHandleByName(tPossibleStuff[i])
    if hKill then
      tKillTargets[#tKillTargets + 1] = tPossibleStuff[i]
    end
  end
  if 2 < #tKillTargets then
    self:CreateTask({
      sName = "wtfzone1",
      sTaskType = "SabTaskObjectiveDestroy",
      sTaskSubType = "KILL",
      TaskCount = 2,
      tTgtInclude = tKillTargets,
      bNoFocus = true,
      WTFZoneHigh = "WtF_Zones\\s2\\m2_train\\ZT_1_trainyard"
    })
  else
    Zone.SwitchState("WtF_Zones\\s2\\m2_train\\ZT_1_trainyard", cZONESTATE_HIGHWTF, cENT_IMMEDIATE)
  end
end

function SOE_2_Mission_2:WTFSparklemotion2()
  local tPossibleStuff = {}
  tPossibleStuff[1] = "Missions\\soe_2\\mission_2\\enc3_chambord\\OccMed_OilTank_C(5)\\OccMed_OilTank_C"
  tPossibleStuff[2] = "Missions\\soe_2\\mission_2\\enc3_chambord\\OccMed_OilTank_C(6)\\OccMed_OilTank_C"
  tPossibleStuff[3] = "CountrySide\\centre\\chambord\\buildings\\OccMed_OilTank_E(2)\\OccMed_OilTank_E"
  tPossibleStuff[4] = "CountrySide\\centre\\chambord\\buildings\\OccMed_OilTank_E(3)\\OccMed_OilTank_E"
  local tKillTargets = {}
  for i = 1, 4 do
    local hKill = Util.GetHandleByName(tPossibleStuff[i])
    if hKill then
      tKillTargets[#tKillTargets + 1] = tPossibleStuff[i]
    end
  end
  if 2 < #tKillTargets then
    self:CreateTask({
      sName = "wtfzone2",
      sTaskType = "SabTaskObjectiveDestroy",
      sTaskSubType = "KILL",
      TaskCount = 2,
      tTgtInclude = tKillTargets,
      bNoFocus = true,
      WTFZoneHigh = "WtF_Zones\\s2\\m2_train\\ZT_3_Chateaux",
      tOnComplete = {}
    })
  else
    Zone.SwitchState("WtF_Zones\\s2\\m2_train\\ZT_3_Chateaux", cZONESTATE_HIGHWTF, cENT_IMMEDIATE)
  end
end

function SOE_2_Mission_2:PrintTest()
end

function SOE_2_Mission_2:WTFSparklemotion3()
  local tPossibleStuff = {}
  tPossibleStuff[1] = "Missions\\soe_2\\mission_2\\enc3_chambord\\OccMed_OilTank_C(10)\\OccMed_OilTank_C"
  tPossibleStuff[2] = "Missions\\soe_2\\mission_2\\enc3_chambord\\OccMed_OilTank_C(4)\\OccMed_OilTank_C"
  tPossibleStuff[3] = "Missions\\soe_2\\mission_2\\enc3_chambord\\OccMed_OilTank_E(6)\\OccMed_OilTank_E"
  tPossibleStuff[4] = "Missions\\soe_2\\mission_2\\enc3_chambord\\OccMed_OilTank_C(7)\\OccMed_OilTank_C"
  local tKillTargets = {}
  for i = 1, 4 do
    local hKill = Util.GetHandleByName(tPossibleStuff[i])
    if hKill then
      tKillTargets[#tKillTargets + 1] = tPossibleStuff[i]
    end
  end
  if 2 < #tKillTargets then
    self:CreateTask({
      sName = "wtfzone3",
      sTaskType = "SabTaskObjectiveDestroy",
      sTaskSubType = "KILL",
      TaskCount = 2,
      tTgtInclude = tKillTargets,
      bNoFocus = true,
      WTFZoneHigh = "WtF_Zones\\s2\\m2_train\\ZT_New[1]",
      tOnComplete = {}
    })
  else
    Zone.SwitchState("WtF_Zones\\s2\\m2_train\\ZT_New[1]", cZONESTATE_HIGHWTF, cENT_IMMEDIATE)
  end
end

function SOE_2_Mission_2:WTFSparklemotion4()
  local tPossibleStuff = {}
  tPossibleStuff[1] = "Missions\\soe_2\\mission_2\\enc4_station\\OccMed_OilTank_D(2)\\OccMed_OilTank_D"
  tPossibleStuff[2] = "Missions\\soe_2\\mission_2\\enc4_station\\OccMed_OilTank_D(4)\\OccMed_OilTank_D"
  tPossibleStuff[3] = "Missions\\soe_2\\mission_2\\enc4_station\\OccMed_OilTank_D(5)\\OccMed_OilTank_D"
  tPossibleStuff[4] = "Missions\\soe_2\\mission_2\\enc4_station\\OccMed_OilTank_D(7)\\OccMed_OilTank_D"
  tPossibleStuff[5] = "Missions\\soe_2\\mission_2\\enc4_station\\OccMed_OilTank_E(4)\\OccMed_OilTank_E"
  tPossibleStuff[6] = "Missions\\soe_2\\mission_2\\enc4_station\\OccMed_OilTank_D(3)\\OccMed_OilTank_D"
  tPossibleStuff[7] = "Missions\\soe_2\\mission_2\\enc4_station\\Barrel_Explosive(60)"
  tPossibleStuff[8] = "Missions\\soe_2\\mission_2\\enc4_station\\OccMed_OilTank_D(6)\\OccMed_OilTank_D"
  local tKillTargets = {}
  for i = 1, 8 do
    local hKill = Util.GetHandleByName(tPossibleStuff[i])
    if hKill then
      tKillTargets[#tKillTargets + 1] = tPossibleStuff[i]
    end
  end
  if 2 < #tKillTargets then
    self:CreateTask({
      sName = "wtfzone4",
      sTaskType = "SabTaskObjectiveDestroy",
      sTaskSubType = "KILL",
      TaskCount = 2,
      tTgtInclude = tKillTargets,
      bNoFocus = true,
      WTFZoneHigh = "WtF_Zones\\s2\\m2_train\\ZT_4_Station",
      tOnComplete = {}
    })
  else
    Zone.SwitchState("WtF_Zones\\s2\\m2_train\\ZT_4_Station", cZONESTATE_HIGHWTF, cENT_IMMEDIATE)
  end
end

function SOE_2_Mission_2:ShootRocket(tData, nNum, nNumRockets, nDelay)
  local bShootRockets = false
  local bNaziAlive = false
  local bDC = false
  local sNameHandle, sNazi1, sNazi2
  if nNum == 1 then
    sNameHandle = "Missions\\soe_2\\mission_2\\enc3_chambord\\OccLt_WatchTower_16M_DAM(5)\\OccLt_WatchTower_16M_DAM"
    sNazi1 = "Missions\\soe_2\\mission_2\\enc3_chambord\\S1_NZ_Grunt_tower(7)"
    sNazi2 = "Missions\\soe_2\\mission_2\\enc3_chambord\\S1_NZ_Grunt_tower(9)"
  elseif nNum == 2 then
    sNameHandle = "Missions\\soe_2\\mission_2\\enc3_chambord\\OccLt_WatchTower_16M_DAM(5)\\OccLt_WatchTower_16M_DAM"
    sNazi1 = "Missions\\soe_2\\mission_2\\enc3_chambord\\S1_NZ_Grunt_tower(7)"
    sNazi2 = "Missions\\soe_2\\mission_2\\enc3_chambord\\S1_NZ_Grunt_tower(9)"
  elseif nNum == 3 then
    sNameHandle = "Missions\\soe_2\\mission_2\\enc3_chambord\\OccLt_WatchTower_16M_DAM(7)\\OccLt_WatchTower_16M_DAM"
    sNazi1 = "Missions\\soe_2\\mission_2\\enc3_chambord\\S1_NZ_Grunt_tower(13)"
    sNazi2 = "Missions\\soe_2\\mission_2\\enc3_chambord\\S1_NZ_Grunt_tower(11)"
  elseif nNum == 4 then
    sNameHandle = "Missions\\soe_2\\mission_2\\enc3_chambord\\OccLt_WatchTower_16M_DAM(7)\\OccLt_WatchTower_16M_DAM"
    sNazi1 = "Missions\\soe_2\\mission_2\\enc3_chambord\\S1_NZ_Grunt_tower(13)"
    sNazi2 = "Missions\\soe_2\\mission_2\\enc3_chambord\\S1_NZ_Grunt_tower(11)"
  elseif nNum == 5 then
    bDC = true
    sNameHandle = "Missions\\soe_2\\mission_2\\enc3_chambord\\OccLt_WatchTower_16M_DAM(8\\OccLt_WatchTower_16M_DAM)"
    sNazi1 = "Missions\\soe_2\\mission_2\\enc3_chambord\\S1_NZ_Grunt_tower(16)"
    sNazi2 = "Missions\\soe_2\\mission_2\\enc3_chambord\\S1_NZ_Grunt_tower(15)"
  elseif nNum == 6 then
    bDC = true
    sNameHandle = "Missions\\soe_2\\mission_2\\enc3_chambord\\OccLt_WatchTower_16M_DAM(8)\\OccLt_WatchTower_16M_DAM"
    sNazi1 = "Missions\\soe_2\\mission_2\\enc3_chambord\\S1_NZ_Grunt_tower(16)"
    sNazi2 = "Missions\\soe_2\\mission_2\\enc3_chambord\\S1_NZ_Grunt_tower(15)"
  end
  local hObject = Util.GetHandleByName(sNameHandle)
  if hObject and Object.GetHealth(hObject) > 0 then
    bShootRockets = true
  end
  local hNazi1 = Util.GetHandleByName(sNazi1)
  local hNazi2 = Util.GetHandleByName(sNazi2)
  if hNazi1 ~= nil and hNazi2 ~= nil and Object.GetHealth(hNazi1) > 0 and Object.GetHealth(hNazi2) > 0 then
    bNaziAlive = true
  end
  if bShootRockets == true and bNaziAlive == true then
    local nIncrement = 0
    for i = 1, nNumRockets do
      local sSpawnString = "Missions\\soe_2\\mission_2\\rocketscenario\\firepos" .. nNum .. "(" .. i .. ")"
      local sEndString = "Missions\\soe_2\\mission_2\\rocketscenario\\firehit" .. nNum .. "(" .. i .. ")"
      local tEvent = {EventType = "TimerEvent", Time = nIncrement}
      self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.ShootRocket_", self, {sSpawnString, sEndString}))
      nIncrement = nIncrement + nDelay
    end
  end
  if bDC == true then
    local tEvent = {EventType = "TimerEvent", Time = 3}
    self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.DecoupleThisCarriage", self, {
      self.nPlayerCarriageLocation
    }))
  end
end

function SOE_2_Mission_2:DecoupleThisCarriage(nWhich)
  if 9 < nWhich then
    Train.TrainDecoupleCarriage(self.tCarriageHandles[nWhich])
  end
end

function SOE_2_Mission_2:ShootRocket_(sStart, sEnd)
  local x, y, z = Object.GetPosition(Util.GetHandleByName(sStart))
  local X, Y, Z = Object.GetPosition(Util.GetHandleByName(sEnd))
end

function SOE_2_Mission_2:DecoupleWhich(nNum)
  Train.TrainDecoupleCarriage(self.tCarriageHandles[nNum])
end

function SOE_2_Mission_2:NaziChasing()
  local hNazi = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_civilians\\Spore_WM_RunAfterCiv")
  local hCiv = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_civilians\\Spore_CV_Worker_RunFromNazi")
  local hStopLocator = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_civilians\\LOC_CivRunHere")
  local hStopLocatorNazi = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_civilians\\LOC_NaziRunHere")
  local hCiv2 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_civilians\\Spore_CV_Worker_RunFromNazi(2)")
  local hStopLocator2 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_civilians\\LOC_CivRunHere(2)")
  local hCiv3 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_civilians\\Spore_CV_Worker_RunFromNazi(4)")
  local hStopLocator3 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_civilians\\LOC_CivRunHere(4)")
  Actor.EnableNeeds(hNazi, false)
  if Actor.IsAlive(hNazi) == true then
    Actor.SetPanicEnabled(hNazi, false)
  end
  Actor.EnableNeeds(hCiv, false)
  if Actor.IsAlive(hCiv) == true then
    Actor.SetPanicEnabled(hCiv, true)
  end
  Actor.EnableNeeds(hCiv2, false)
  if Actor.IsAlive(hCiv2) == true then
    Actor.SetPanicEnabled(hCiv2, true)
  end
  Actor.EnableNeeds(hCiv3, false)
  if Actor.IsAlive(hCiv3) == true then
    Actor.SetPanicEnabled(hCiv3, true)
  end
  Actor.OverrideCombatAI(hCiv, true)
  Actor.OverrideCombatAI(hCiv2, true)
  Actor.OverrideCombatAI(hCiv3, true)
  Actor.OverrideCombatAI(hNazi, true)
  Nav.MoveToObject(hCiv, hStopLocator, 0, cMOVE_PANIC, "SOE_2_Mission_2.CivBeCoward", self)
  Nav.MoveToObject(hCiv2, hStopLocator2, 0, cMOVE_PANIC)
  Nav.MoveToObject(hCiv3, hStopLocator3, 0, cMOVE_PANIC)
  Nav.MoveToObject(hNazi, hStopLocatorNazi, 0, cMOVE_FAST, "SOE_2_Mission_2.NaziShooting", self)
  Combat.SetTether(hNazi, hStopLocatorNazi, 1)
end

function SOE_2_Mission_2:NaziShooting()
  local hNazi = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_civilians\\Spore_WM_RunAfterCiv")
  local hCiv = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_civilians\\Spore_CV_Worker_RunFromNazi")
  local hCiv2 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_civilians\\Spore_CV_Worker_RunFromNazi(2)")
  local hCiv3 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_civilians\\Spore_CV_Worker_RunFromNazi(4)")
  local hStopLocatorNazi = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_civilians\\LOC_NaziRunHere")
  Combat.SetBroadcastEnteredCombat(hNazi, false)
  Combat.SetBroadcastWeaponFire(hNazi, false)
  Combat.SetStationary(hNazi, true)
  Actor.SetFacingDir(hNazi, hCiv)
  Actor.SetFacingDir(hCiv, hNazi)
  Squad.Create("NaziDude")
  Squad.Create("CivsToKill")
  Squad.AddMember("NaziDude", hNazi)
  Squad.AddMember("CivsToKill", hCiv)
  Squad.AddMember("CivsToKill", hCiv2)
  Squad.AddMember("CivsToKill", hCiv3)
  Squad.SetEnemy("NaziDude", "CivsToKill")
  Squad.SetLethal("NaziDude", true)
  Squad.SetLeader("NaziDude", hNazi)
  Squad.SetLeader("CivsToKill", hCiv)
  Squad.SetRadius("NaziDude", 8)
  Combat.SetAlwaysSeeTarget(hNazi, true)
  Combat.LockIntoCombat(hNazi)
  Combat.SetCombat(hNazi)
end

function SOE_2_Mission_2:CivBeCoward()
  local hCiv = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_civilians\\Spore_CV_Worker_RunFromNazi")
  local hCiv2 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_civilians\\Spore_CV_Worker_RunFromNazi(2)")
  local hCiv3 = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc4_civilians\\Spore_CV_Worker_RunFromNazi(4)")
  Actor.PlayAnimation(hCiv, "civ_cower_idle")
  Actor.PlayAnimation(hCiv2, "civ_cower_idle")
  Actor.PlayAnimation(hCiv3, "civ_cower_idle")
end

function SOE_2_Mission_2.FadeCinematicCall()
  Render.FadeTo(0, 0, 0, 255, 0)
end

function SOE_2_Mission_2:PlayerEnteredTheVehicle()
  self.hTempEvent1 = EVENT_PlayerExitsAnyVehicle("SOE_2_Mission_2.PlayerExitedTheVehicle", self)
  local tEvent = {EventType = "TimerEvent", Time = 1}
  self.hEventHowLongInCarTimer = Util.CreateEvent(tEvent, "SOE_2_Mission_2.UpdateCounterAndPotentiallyPlayConversation", self)
end

function SOE_2_Mission_2:UpdateCounterAndPotentiallyPlayConversation()
  local hPlayerLabel = Filter.New("Player")
  local htrigger = Handle("Missions\\soe_2\\mission_2\\triggerbox\\PT_CheckPointNazi")
  local bNotInTrigger = true
  if htrigger then
    local tWho = Trigger.GetAllWithin(htrigger, hPlayerLabel)
    if tWho and tWho[1] == hSab then
      bNotInTrigger = false
    end
  end
  Filter.Delete(hPlayerLabel)
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  if SOE_2_Mission_2.nTimerCounterForConvo >= 2 and SOE_2_Mission_2.tSaveInfo.bPlayDriveConvo1 == false and bNotInTrigger == true and Cin.IsHumanInConversation(hSab) == false and Cin.IsHumanInConversation(hSkylar) == false then
    Convo.ResetForFail()
    ConvoHelper.InterruptReplay("309_Con_BridgeTalk", "s2m2stuff", "SOE_2_Mission_2.TestyTestyTesty", SOE_2_Mission_2, {10})
    local tEvent = {
      EventType = "OnCheckpointEntered",
      Target = hSab
    }
    SOE_2_Mission_2:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.InterruptConvo", SOE_2_Mission_2))
    SOE_2_Mission_2.tSaveInfo.bPlayDriveConvo1 = true
    if SOE_2_Mission_2.hTempEvent2 ~= nil then
      Util.KillEvent(SOE_2_Mission_2.hTempEvent2)
    end
    if SOE_2_Mission_2.hTempEvent1 ~= nil then
      Util.KillEvent(SOE_2_Mission_2.hTempEvent1)
    end
  else
    local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
    if Actor.IsInVehicle(hSkylar) then
      if SOE_2_Mission_2.bSkylarAndPlayerInVehicleConvo == false then
        SOE_2_Mission_2.SkylarAndPlayerInVehicleConvo(SOE_2_Mission_2)
      end
      SOE_2_Mission_2.bSkylarAndPlayerInVehicleConvo = true
      SOE_2_Mission_2.nTimerCounterForConvo = SOE_2_Mission_2.nTimerCounterForConvo + 1
    end
    local tEvent = {EventType = "TimerEvent", Time = 1}
    SOE_2_Mission_2.hEventHowLongInCarTimer = Util.CreateEvent(tEvent, "SOE_2_Mission_2.UpdateCounterAndPotentiallyPlayConversation", SOE_2_Mission_2)
  end
end

function SOE_2_Mission_2:TestyTestyTesty(lolwha)
  self.bConvoPlayedForBridge = true
end

function SOE_2_Mission_2:InterruptConvo()
  Cin.InterruptConversation("309_Con_BridgeTalk")
end

function SOE_2_Mission_2:CheckpointLocationConvoPause(tData, tuser)
  if tData then
    if tData[1] == 3 then
      self.tSaveInfo.bConvo309Done = true
    elseif Suspicion.GetEscalation() > 0 then
      local tEvent = {
        EventType = "OnEscalation0",
        Target = hSab
      }
      Util.CreateEvent(tEvent, "SOE_2_Mission_2.ConvoResume309", self)
    else
      local tEvent = {
        EventType = "OnPaperCheckPass",
        Target = hSab
      }
      Util.CreateEvent(tEvent, "SOE_2_Mission_2.PaperCheckPointDone", self)
    end
  end
end

function SOE_2_Mission_2:PaperCheckPointDone()
  local tEvent = {EventType = "TimerEvent", Time = 3}
  Util.CreateEvent(tEvent, "SOE_2_Mission_2.ConvoResume309", self)
end

function SOE_2_Mission_2:ConvoResume309()
  if self.tSaveInfo.bConvo309Done == false then
    Cin.PlayConversation("309_Con_BridgeTalk", "SOE_2_Mission_2.CheckpointLocationConvoPause", self)
  end
end

function SOE_2_Mission_2:PlayerExitedTheVehicle()
  self.hTempEvent2 = EVENT_PlayerEntersVehicle("SOE_2_Mission_2.PlayerEnteredTheVehicle", self, "Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)")
  self.hTempEvent3 = EVENT_PlayerToActorProximityNegated("SOE_2_Mission_2.SkylarTellsPlayerToGetInCar", self, "Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)", 15)
end

function SOE_2_Mission_2:SkylarTellsPlayerToGetInCar()
  self.PlayConvoUsingQueue(self, "S2M2_ToBridge_Car_Far", 10, {})
end

function SOE_2_Mission_2:SkylarSeanNearCarLoop()
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  local hVehicle = Util.GetHandleByName("Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)")
  if Object.GetDistance(hSkylar, hVehicle) < 5 and 5 > Object.GetDistance(hSab, hVehicle) then
    if Actor.IsInVehicle(hSkylar) == false and Actor.IsInVehicle(hSab) == false then
      self.PlayConvoUsingQueue(self, "S2M2_ToBridge_Car_Near", 10, {})
    end
  else
    local tEvent = {EventType = "TimerEvent", Time = 1}
    self.hEventConvoBothNearCar = Util.CreateEvent(tEvent, "SOE_2_Mission_2.SkylarSeanNearCarLoop", self)
  end
end

function SOE_2_Mission_2:SkylarAndPlayerInVehicleConvo()
end

function SOE_2_Mission_2:PlayerTooFarFromSkylarPart1a()
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  self.PlayConvoUsingQueue(self, "S2M2_ToBridge_SkylarTooFar", 10, {})
  EVENT_PlayerToActorProximity("SOE_2_Mission_2.PlayerNearSkylarAgainPart1a", self, hSkylar, 5)
end

function SOE_2_Mission_2:PlayerNearSkylarAgainPart1a()
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  self.PlayConvoUsingQueue(self, "S2M2_ToBridge_SkylarReturn", 10, {})
  self.hTempEvent4 = EVENT_ActorToActorProximityNegated("SOE_2_Mission_2.PlayerTooFarFromSkylarPart1a", self, hSkylar, hSab, 20)
end

function SOE_2_Mission_2:PlayerExitsNearBridge()
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  EVENT_ActorExitsAnyVehicle("SOE_2_Mission_2.SkylarDoesSomethingOrStuff", self, hSkylar)
end

function SOE_2_Mission_2:SkylarDoesSomethingOrStuff()
end

function SOE_2_Mission_2:IsInCarAgainForTheSecondTime()
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  if Actor.IsInVehicle(hSab) and Actor.IsInVehicle(hSkylar) then
    self.nTimerCounterForConvo = self.nTimerCounterForConvo + 1
    if self.nTimerCounterForConvo == 4 then
      ConvoHelper.InterruptReplay("310_InG_BridgeDone-Drive01", "soe2m2_310", nil, nil, nil)
    else
      local tEvent = {EventType = "TimerEvent", Time = 1}
      self.hEventHowLongInCarTimer = Util.CreateEvent(tEvent, "SOE_2_Mission_2.IsInCarAgainForTheSecondTime", self)
    end
  else
    local tEvent = {EventType = "TimerEvent", Time = 1}
    self.hEventHowLongInCarTimer = Util.CreateEvent(tEvent, "SOE_2_Mission_2.IsInCarAgainForTheSecondTime", self)
  end
end

function SOE_2_Mission_2:DriveBackInterruptionThingy(tData)
end

function SOE_2_Mission_2:RemoveBlip(hSkylar, hVehicle)
  self.SkylarExitsVehicle = EVENT_ActorExitsAnyVehicle("SOE_2_Mission_2.AddBlip", self, hSkylar, {hSkylar, hVehicle})
end

function SOE_2_Mission_2:AddBlip(tData, hSkylar, hVehicle)
  self.SkylarEntersVehicle = Util.CreateEvent({
    EventType = "EnteredVehicleEvent",
    ObjectHandle = hSkylar,
    VehicleHandle = hVehicle
  }, "SOE_2_Mission_2.RemoveBlip", self, {hSkylar, hVehicle})
end

function SOE_2_Mission_2:Task_GetToBridge()
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  local hVehicle = Util.GetHandleByName("Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)")
  Actor.SetAutoSeatTransition(hSkylar, false)
  Actor.CancelAttrPt(hSkylar)
  Nav.BoardVehicle(hSkylar, hVehicle, "SHOTGUN")
  self.SkylarEntersVehicle = Util.CreateEvent({
    EventType = "EnteredVehicleEvent",
    ObjectHandle = hSkylar,
    VehicleHandle = hVehicle
  }, "SOE_2_Mission_2.RemoveBlip", self, {hSkylar, hVehicle})
  self.hTempEvent4 = EVENT_ActorToActorProximityNegated("SOE_2_Mission_2.PlayerTooFarFromSkylarPart1a", self, hSkylar, hSab, 20)
  local tEvent = {EventType = "TimerEvent", Time = 0.5}
  self.hEventConvoBothNearCar = Util.CreateEvent(tEvent, "SOE_2_Mission_2.SkylarSeanNearCarLoop", self)
end

function SOE_2_Mission_2:PlayerEnteredAVehicle()
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  local hVehicle = Util.GetHandleByName("Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)")
  local sConvoLine = ""
  local nPriority = 10
  local tFlags = {}
  EVENT_ActorEntersAnyVehicle("SOE_2_Mission_2.PlayConvoUsingQueue", self, hSkylar, {
    sConvoLine,
    nPriority,
    tFlags
  }, false)
  EVENT_ActorEntersAnyVehicle("SOE_2_Mission_2.StopFollowing", self, hSkylar)
  Nav.BoardVehicle(hSkylar, hVehicle, "SHOTGUN")
end

function SOE_2_Mission_2:HavePathNaziStreamedIn()
  EVENT_PlayerToActorProximity("SOE_2_Mission_2.NaziGoOnPath", self, "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\CH_BridgePatrol1B", 15)
end

function SOE_2_Mission_2:NaziGoOnPath()
  local hNazi = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\CH_BridgePatrol1")
  Nav.SetScriptedPath(hNazi, "Missions\\soe_2\\mission_2\\enc6_bridge\\patrols\\PA_BridgePatrol1B", false)
end

function SOE_2_Mission_2:CarHealthCheck()
  local hVehicle = Util.GetHandleByName("Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)")
  local fraction = Object.GetHealth(hVehicle) / self.MaxCarHealth
  local bRun = true
  if self.bConvoPlayedForBridge == true then
    if fraction < 1 and self.bCarDamageFirst == false then
      self.bCarDamageFirst = true
      self.PlayConvoUsingQueue(self, "S2M2_ToBridge_Car_DamagedFirst", 0, {})
    elseif fraction < 0.75 and self.bCarDamage25 == false then
      self.bCarDamage25 = true
      self.PlayConvoUsingQueue(self, "S2M2_ToBridge_Car_Damaged25", 0, {})
    elseif fraction < 0.5 and self.bCarDamage50 == false then
      self.bCarDamage50 = true
      self.PlayConvoUsingQueue(self, "S2M2_ToBridge_Car_Damaged50", 0, {})
    elseif fraction < 0.25 and self.bCarDamage75 == false then
      self.bCarDamage75 = true
      self.PlayConvoUsingQueue(self, "S2M2_ToBridge_Car_Damaged75", 0, {})
    elseif fraction <= 0 and self.bCarDamage100 == false then
      self.bCarDamage100 = true
      self.PlayConvoUsingQueue(self, "S2M2_ToBridge_Car_Destroyed", 0, {})
      bRun = false
    end
  end
  if bRun then
    local tEvent = {EventType = "TimerEvent", Timer = 1}
    self.hCarHealthCheck = Util.CreateEvent(tEvent, "SOE_2_Mission_2.CarHealthCheck", self)
    self:RegisterEvent(self.hCarHealthCheck)
  end
end

function SOE_2_Mission_2:CarDeathNotWorkingSoHereIsAHack()
  self.bCarDamage100 = true
  self.PlayConvoUsingQueue(self, "S2M2_ToBridge_Car_Destroyed", 0, {})
  self:MissionTaskFail("GenericFail_Text.DESTROYED_Car_The")
end

function SOE_2_Mission_2:PlayerTookTooLongToGetToBridge()
  if Actor.IsInVehicle(hSab) then
    self.PlayConvoUsingQueue(self, "S2M2_ToBridge_AreWeThere", nPriority, tFlags)
  else
    local tEvent = {EventType = "TimerEvent", Time = 10}
    self.TooLongToGetToBridge = Util.CreateEvent(tEvent, "SOE_2_Mission_2.PlayerTookTooLongToGetToBridge", self)
  end
end

function SOE_2_Mission_2:Task_GetToBridge_()
  self.nCheckpoint1Count = 0
  if self.FirstTaskConvoFinished == false then
    self.FirstTaskConvoFinished = true
    local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
    local hVehicle = Util.GetHandleByName("Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)")
    self.MaxCarHealth = Object.GetHealth(hVehicle)
    self.hCarDeathEventSkylar = EVENT_ActorDeath("SOE_2_Mission_2.CarDeathNotWorkingSoHereIsAHack", self, "Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)", {}, false)
    self.CarHealthCheck(self)
    Vehicle.SetDeathCallback(hVehicle, "SOE_2_Mission_2.MissionTaskFail", self, {
      "GenericFail_Text.DESTROYED_Car_The"
    })
    Sound.LoadSoundBank("m_S2M2_inGame.bnk")
    local tEvent = {EventType = "TimerEvent", Time = 120}
    self.TooLongToGetToBridge = Util.CreateEvent(tEvent, "SOE_2_Mission_2.PlayerTookTooLongToGetToBridge", self)
    self:CreateTask({
      sName = "Missions\\soe_2\\mission_2\\ConversationAndmisc\\conversation1",
      sTaskType = "SabTaskObjectiveEmpty",
      sTaskSubType = "None",
      tSMEDNodes = {
        "Missions\\soe_2\\mission_2\\ConversationAndmisc\\conversation1"
      }
    })
    self:RegisterEvent(Util.CreateEvent({
      EventType = "StreamEvent",
      Objects = {
        "Missions\\soe_2\\mission_2\\enc6_bridge\\CH_BridgePatrol1"
      },
      WaitForGameObject = true
    }, "SOE_2_Mission_2.HavePathNaziStreamedIn", self))
    self:CreateTask({
      sName = "GetToPoint1",
      sTaskType = "SabTaskObjectiveDeliver",
      sTaskSubType = "TAXI",
      sPickupTextID = "S2M2_Text.DriveWithSkylar",
      sDropoffTextID = "S2M2_Text.DriveWithSkylar",
      sVehicleFetchID = "S2M2_Text.DriveWithSkylar",
      sVehicleReturnID = "S2M2_Text.DriveWithSkylar",
      tDestLocators = {
        "Missions\\soe_2\\mission_2\\ambientevents\\Loc_GoToBridge"
      },
      tPickupProxObj = {hSkylar},
      PickupProximity = 12,
      bEscalationDenial = true,
      bGroundBlip = true,
      tDestRegion = {
        "Missions\\soe_2\\mission_2\\ambientevents\\GoToBridge"
      },
      tDeliverObjs = {hSkylar},
      sRequiredVehicle = hVehicle,
      bNoDumping = true,
      tOnEarlyExit = {},
      tOnWait = {},
      tOnPickup = {},
      tOnComplete = {
        {
          self.SetupCheckpoint1,
          {self}
        }
      },
      tOnActivate = {}
    })
    if hVehicle then
      Vehicle.LockAllSeats(hVehicle, false)
      Object.SetInvincible(hVehicle, false)
    end
    HUD.SetEnableAllGPSEdgesInTrigger("Missions\\soe_2\\mission_2\\triggerbox\\PT_CheckPointNazi", true)
  end
end

function SOE_2_Mission_2:S2M2_BridgeSabotage_Start_Convo_Task()
  Util.KillEvent(SOE_2_Mission_2.hCarHealthCheck)
  Util.KillEvent(SOE_2_Mission_2.TooLongToGetToBridge)
  Util.KillEvent(SOE_2_Mission_2.SkylarEntersVehicle)
  EVENT_KillEvent(SOE_2_Mission_2.SkylarExitsVehicle)
  Train.TrainSuperCull("Missions\\soe_2\\mission_2\\enc6_bridge\\train\\Dtrain4")
  Train.TrainCreate("Missions\\soe_2\\mission_2\\enc6_bridge\\train\\Dtrain4", "Dtrain2")
  self:UnloadTaskNodes("Missions\\soe_2\\mission_2\\ConversationAndmisc\\conversation1", true)
  SOE_2_Mission_2.nBombPlaced = 0
  Inventory.GiveItem(hSab, "WP_SAB_BridgeKiller", false)
  Inventory.GiveItem(hSab, "WP_SAB_BridgeKiller", false)
  Inventory.GiveItem(hSab, "WP_SAB_BridgeKiller", false)
  Inventory.GiveItem(hSab, "WP_SAB_BridgeKiller", false)
  Inventory.GiveItem(hSab, "WP_SAB_BridgeKiller", false)
  local hVehicle = Util.GetHandleByName("Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)")
  Vehicle.ClearDeathCallback(hVehicle)
  if SOE_2_Mission_2.hTempEvent1 then
    EVENT_KillEvent(SOE_2_Mission_2.hTempEvent1)
  end
  if SOE_2_Mission_2.hTempEvent2 then
    EVENT_KillEvent(SOE_2_Mission_2.hTempEvent2)
  end
  if SOE_2_Mission_2.hTempEvent3 then
    EVENT_KillEvent(SOE_2_Mission_2.hTempEvent3)
  end
  if SOE_2_Mission_2.hTempEvent4 then
    EVENT_KillEvent(SOE_2_Mission_2.hTempEvent4)
  end
  if self.nCheckpoint1Count == 0 then
    Cin.PlayConversation("S2M2_BridgeSabotage_Start", "SOE_2_Mission_2.GetOntheBridge", nil)
  else
    SOE_2_Mission_2.GetOntheBridge()
  end
  self.nCheckpoint1Count = 10
end

function SOE_2_Mission_2.GetOntheBridge()
  if SOE_2_Mission_2.tSaveInfo.GetOntheBridgeTaskConvo == false then
    SOE_2_Mission_2.tSaveInfo.GetOntheBridgeTaskConvo = true
    Actor.UnboardVehicle(hSab)
    local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
    Combat.SetGrabbable(hSkylar, false)
    Actor.UnboardVehicle(hSkylar)
    SOE_2_Mission_2:CreateTask({
      sName = "GetInsideBridgeTask",
      sTaskType = "SabTaskObjectiveDeliver",
      sTaskSubType = "GOTO",
      sObjectiveTextID = "S2M2_Text.GetToBridge",
      tLocators = {
        "Missions\\soe_2\\mission_2\\ConversationAndmisc\\Triggerbox2\\Loc_GoToBridge"
      },
      tDestRegion = "Missions\\soe_2\\mission_2\\ConversationAndmisc\\Triggerbox2\\gotobridge1",
      tDeliverObjs = {hSab},
      tOnComplete = {
        {
          SOE_2_Mission_2.Task_Setup_Bombs,
          {SOE_2_Mission_2}
        }
      }
    })
  end
end

function SOE_2_Mission_2:Task_Setup_Bombs()
  AttractionPt.EnableUse(Util.GetHandleByName("Missions\\soe_2\\mission_2\\naziflags\\SabotagePT5"), false)
  self.PlayConvoUsingQueue(self, "S2M2_BridgeSabotage_AtBridge", 10, {})
  Train.TrainSetMaxSpeed("Missions\\soe_2\\mission_2\\enc6_bridge\\train\\Dtrain4", 6)
  self:CreateTask({
    sName = "Plant_bomb",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    bUseOnce = true,
    TaskCount = 4,
    sObjectiveTextID = "S2M2_Text.PlantExplosivesOnStruts",
    bObjCounter = true,
    MarkerHeight = 0.5,
    tTgtInclude = {
      "Missions\\soe_2\\mission_2\\naziflags\\SabotagePT1",
      "Missions\\soe_2\\mission_2\\naziflags\\SabotagePT2",
      "Missions\\soe_2\\mission_2\\naziflags\\SabotagePT3",
      "Missions\\soe_2\\mission_2\\naziflags\\SabotagePT4"
    },
    tOnComplete = {
      {
        self.Task_Plant_TriggerCKPT,
        {self}
      }
    }
  })
  local sTutorialText = "TutorialTip_Text.Sabotage_Bridge"
  Saboteur.ShowToolTip(sTutorialText)
  EVENT_PlayerToActorProximity("SOE_2_Mission_2.NearSabPt", self, "Missions\\soe_2\\mission_2\\naziflags\\SabotagePT1", 5)
  EVENT_PlayerToActorProximity("SOE_2_Mission_2.NearSabPt", self, "Missions\\soe_2\\mission_2\\naziflags\\SabotagePT2", 5)
  EVENT_PlayerToActorProximity("SOE_2_Mission_2.NearSabPt", self, "Missions\\soe_2\\mission_2\\naziflags\\SabotagePT3", 5)
  EVENT_PlayerToActorProximity("SOE_2_Mission_2.NearSabPt", self, "Missions\\soe_2\\mission_2\\naziflags\\SabotagePT4", 1)
end

function SOE_2_Mission_2:StartRain()
  Render.Rain(1, 10)
end

function SOE_2_Mission_2:NearSabPt()
  self.PlayConvoUsingQueue(self, "S2M2_BridgeSabotage_AtLoc", 10, {})
end

function SOE_2_Mission_2:Task_Plant_TriggerCKPT()
  self.RegisterCheckpoint(self, "SOE_2_Mission_2.Checkpoint44")
  Convo.ResetForFail()
  self.PlayConvoUsingQueue(self, "S2M2_BridgeSabotage_StrutComplete", 10, {})
end

function SOE_2_Mission_2:Checkpoint44()
  SOE_2_Mission_2.Task_Plant_Trigger(self)
end

function SOE_2_Mission_2:Task_Plant_Trigger()
  AttractionPt.EnableUse(Util.GetHandleByName("Missions\\soe_2\\mission_2\\naziflags\\SabotagePT5"), true)
  self:CreateTask({
    sName = "Plant_Trigger",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    bUseOnce = true,
    TaskCount = 1,
    sObjectiveTextID = "S2M2_Text.PlantTriggerOnTracks",
    MarkerHeight = 0.5,
    tTgtInclude = {
      "Missions\\soe_2\\mission_2\\naziflags\\SabotagePT5"
    },
    tOnComplete = {
      {
        self.MeetSkylarAgain,
        {self}
      }
    }
  })
  Sound.SetMusicLocale("S2M2_Train")
  Sound.SetMusicLocale("m_S2M2_Train", "BridgeSabotage_done")
end

function SOE_2_Mission_2:MeetSkylarAgain()
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc2_bridge\\PT_StopRain", hSab, "SOE_2_Mission_2.RainOff", self, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc2_bridge\\PT_StopRain")
  local hSpawner = Util.GetHandleByName("Missions\\soe_2\\mission_2\\enc6_bridge\\spawn2\\BunkerSpawnerTrap")
  Object.EnableSpawner(hSpawner, true)
  self.PlayConvoUsingQueue(self, "S2M2_BridgeSabotage_TrackComplete", 10, {})
  local hVeron = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  local hVehicle = Util.GetHandleByName("Missions\\soe_2\\mission_2\\SkylarInPlace\\samemodelcar")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\enc4_civilians\\PT_StartEvent_NaziChasing", hSab, "SOE_2_Mission_2.RainOff", self, nil, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\enc4_civilians\\PT_StartEvent_NaziChasing")
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar"
    },
    WaitForGameObject = true
  }, "SOE_2_Mission_2.TurnToSean", self))
  self:CreateTask({
    sName = "Fake_Meetup_Skylar",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "DELIVER",
    Proximity = 8,
    sObjectiveTextID = "S2M2_Text.RendezvousWithSkylar",
    tLocators = {
      "Missions\\soe_2\\mission_2\\resistance\\Wilcox_End"
    },
    tDestProximityObj = {
      "Missions\\soe_2\\mission_2\\resistance\\Wilcox_End"
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.SetupCheckpoint2,
        {self}
      }
    }
  })
end

function SOE_2_Mission_2:TrainLoadedCheck()
  if Train.TrainIsStreamedIn("CountrySide\\centre\\AiRails\\AI_Rail_Starter") then
    SOE_2_Mission_2.DisableTrainAP(self)
  else
    local tEvent = {EventType = "TimerEvent", Time = 1}
    self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.TrainLoadedCheck", self))
  end
end

function SOE_2_Mission_2:TurnToSean()
  local hSkylar = Handle("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  Actor.SetFacingDir(hSab, hSkylar)
end

function SOE_2_Mission_2:RainOff()
  Render.Rain(0, 10)
end

function SOE_2_Mission_2:RainOn()
  Render.Rain(1, 10)
end

function SOE_2_Mission_2:FakeRendezvousWilcoxTask()
  self.OldSetup(self)
  Sound.ResetMusicLocale()
  local tEvent = {EventType = "TimerEvent", Time = 1}
  self.hEventHowLongInCarTimer = Util.CreateEvent(tEvent, "SOE_2_Mission_2.IsInCarAgainForTheSecondTime", self)
  self.nTimerCounterForConvo = 0
  self.PlayConvoUsingQueue(self, "310_InG_BridgeDone-Start", 10, {})
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  Nav.FollowObject(hSkylar, hSab, 2.75, true, true)
  if hSkylar then
    Combat.SetGrabbable(hSkylar, false)
  end
  Actor.SetAutoSeatTransition(hSkylar, false)
  self.LoadSkylerAndWil(self)
  self:CreateTask({
    sName = "Missions\\soe_2\\mission_2\\ConversationAndmisc\\conversation2",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\soe_2\\mission_2\\ConversationAndmisc\\conversation2"
    }
  })
  local tTimerEvent = {EventType = "TimerEvent", Time = 4}
  self:RegisterEvent(Util.CreateEvent(tTimerEvent, "SOE_2_Mission_2.MusicChangeAfterTimer", self))
end

function SOE_2_Mission_2:FollowSeanWhileMeetingUpWithWilcox()
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  Actor.UnboardVehicle(hSkylar)
  Nav.FollowObject(hSkylar, hSab, 2.75, true, true)
  Combat.SetLeader(hSkylar, hSab)
end

function SOE_2_Mission_2:MusicChangeAfterTimer()
  Sound.ResetMusicLocale()
end

function SOE_2_Mission_2:LoadSkylerAndWil()
  self:CreateTask({
    sName = "Missions\\soe_2\\mission_2\\wilcox2",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\soe_2\\mission_2\\wilcox2"
    }
  })
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  self.bWilcoxLoadedIn = false
  self.bTaskGetTOWILCOXYFinished = false
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\soe_2\\mission_2\\wilcox2\\Spore_RS_Wilcox"
    },
    WaitForGameObject = true
  }, "SOE_2_Mission_2.FinishedLoadingIn", self))
  Actor.SetTalkable(hSkylar, false)
  if self.bTrafficEnabled == nil then
    Vehicle.EnableTraffic(false, false)
    self.bTrafficEnabled = true
  end
  self:CreateTask({
    sName = "GetToWILCOXY",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    bNoCarRequired = true,
    sPickupTextID = "S2M2_Text.RendezvousWithWilcox",
    sDropoffTextID = "S2M2_Text.RendezvousWithWilcox",
    sVehicleFetchID = "S2M2_Text.RendezvousWithWilcox",
    sVehicleReturnID = "S2M2_Text.RendezvousWithWilcox",
    tDestLocators = {
      "Missions\\soe_2\\mission_2\\triggerbox\\LC_GetToWilcox"
    },
    bEscalationDenial = true,
    bGroundBlip = true,
    bNoCarRequired = true,
    tPickupProxObj = {
      "Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar"
    },
    PickupProximity = 30,
    tDestRegion = {
      "Missions\\soe_2\\mission_2\\triggerbox\\PT_New"
    },
    tDeliverObjs = {hSkylar},
    tOnPickup = {},
    tOnComplete = {
      {
        self.GetToWILCOXYTASKComplete,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function SOE_2_Mission_2:GetToWILCOXYTASKComplete()
  self.bTaskGetTOWILCOXYFinished = true
  if self.bWilcoxLoadedIn == true then
    self.Task_TalkToBridgeGuy(self)
  end
end

function SOE_2_Mission_2:FinishedLoadingIn()
  self.bWilcoxLoadedIn = true
  if self.bTaskGetTOWILCOXYFinished == true then
    self.Task_TalkToBridgeGuy(self)
  end
end

function SOE_2_Mission_2:DelayedSkylarFollowHack()
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  Combat.SetLeader(hSkylar, hSab)
end

function SOE_2_Mission_2:Task_TalkToBridgeGuy()
  if self.hTooFarEvent ~= nil then
    Util.KillEvent(self.hTooFarEvent)
  end
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  local hWilcox = Handle("Missions\\soe_2\\mission_2\\wilcox2\\Spore_RS_Wilcox")
  Combat.ClearLeader(hSkylar)
  if hSkylar then
    Combat.SetGrabbable(hSkylar, false)
  end
  if hWilcox then
    Combat.SetGrabbable(hWilcox, false)
  end
  Nav.CancelFollowObject(hSkylar)
  Nav.FollowObject(hSkylar, hWilcox, 2.75, true, true)
  Actor.UnboardVehicle(hSab)
  self.bTaskRunOnceGTTS = false
  self.tSaveInfo.bFailPlayerForDistance = false
  self.OldSetup(self)
  self.tSaveInfo.bEscalationTaskHappened = false
  self.tSaveInfo.bDeEscalationTaskHappened = false
  self.SetupTaskForNotEscalated(self)
  EVENT_ActorToActorProximityNegated("SOE_2_Mission_2.FollowWilcoxSkylar", self, "Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar", "Missions\\soe_2\\mission_2\\wilcox2\\Spore_RS_Wilcox", 5)
end

function SOE_2_Mission_2:FollowWilcoxSkylar()
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  local hWilcox = Handle("Missions\\soe_2\\mission_2\\wilcox2\\Spore_RS_Wilcox")
  Nav.FollowObject(hSkylar, hWilcox, 2, true)
end

function SOE_2_Mission_2:SetupTaskForNotEscalated()
  if self.tSaveInfo.bDeEscalationTaskHappened == false then
    self:CreateTask({
      sName = "talktobridge",
      sTaskType = "SabTaskObjectiveDeliver",
      Proximity = 1,
      sTaskSubType = "DELIVER",
      sObjectiveTextID = "S2M2_Text.TalkToWilcox",
      tDestProximityObj = {
        "Missions\\soe_2\\mission_2\\wilcox2\\Spore_RS_Wilcox"
      },
      tDeliverObjs = {hSab, hSkylar},
      tOnActivate = {
        {
          self.FollowWilcoxSkylar,
          {self}
        }
      },
      tOnComplete = {}
    })
    self:CreateTask({
      sName = "escalatedbeforetalking",
      sTaskType = "SabTaskObjectiveEscalation",
      sTaskSubType = "None",
      EscalationLevel = 1,
      bGTE = true,
      tOnComplete = {
        {
          self.ItHasEscalatedBeforeTalkingToWilcox,
          {self}
        }
      }
    })
    local tEvent = {EventType = "TimerEvent", Time = 1}
    self.hIsPlayerOutOfVehicleCheckEvent = Util.CreateEvent(tEvent, "SOE_2_Mission_2.IsPlayerOutOfVehicleCheck", self)
    self:RegisterEvent(self.hIsPlayerOutOfVehicleCheckEvent)
  else
    self:ResetTaskByName("talktobridge")
    self:ResetTaskByName("escalatedbeforetalking")
  end
end

function SOE_2_Mission_2:ItHasEscalatedBeforeTalkingToWilcox()
  self.tSaveInfo.bEscalationTaskHappened = true
  self:KillTaskByName("talktobridge")
  if self.tSaveInfo.bDeEscalationTaskHappened == false then
    self:CreateTask({
      sName = "cooldownbeforetalking",
      sTaskType = "SabTaskObjectiveEscalation",
      sTaskSubType = "None",
      sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
      EscalationLevel = 0,
      tOnComplete = {
        {
          self.SetFlagForTask,
          {self}
        },
        {
          self.SetupTaskForNotEscalated,
          {self}
        }
      }
    })
  else
    self:ResetTaskByName("cooldownbeforetalking")
  end
end

function SOE_2_Mission_2:SetFlagForTask()
  self.tSaveInfo.bDeEscalationTaskHappened = true
end

function SOE_2_Mission_2:IsPlayerOutOfVehicleCheck()
  local hSkylar = Handle("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  local hWilcox = Handle("Missions\\soe_2\\mission_2\\wilcox2\\Spore_RS_Wilcox")
  if hSkylar == nil or hWilcox == nil then
    local tEvent = {EventType = "TimerEvent", Time = 1}
    self.hIsPlayerOutOfVehicleCheckEvent = Util.CreateEvent(tEvent, "SOE_2_Mission_2.IsPlayerOutOfVehicleCheck", self)
    self:RegisterEvent(self.hIsPlayerOutOfVehicleCheckEvent)
  elseif Object.GetDistance(hSab, hWilcox) ~= nil and Object.GetDistance(hSkylar, hWilcox) ~= nil then
    if 1 > Suspicion.GetEscalation() and Actor.IsInVehicle(hSab) == false and Object.GetDistance(hSab, hWilcox) < 2 and Object.GetDistance(hSkylar, hWilcox) < 5 then
      self:KillTaskByName("talktobridge")
      self:KillTaskByName("escalatedbeforetalking")
      self.SetupCheckpoint3(self)
    else
      local tEvent = {EventType = "TimerEvent", Time = 1}
      self.hIsPlayerOutOfVehicleCheckEvent = Util.CreateEvent(tEvent, "SOE_2_Mission_2.IsPlayerOutOfVehicleCheck", self)
      self:RegisterEvent(self.hIsPlayerOutOfVehicleCheckEvent)
    end
  else
    local tEvent = {EventType = "TimerEvent", Time = 1}
    self.hIsPlayerOutOfVehicleCheckEvent = Util.CreateEvent(tEvent, "SOE_2_Mission_2.IsPlayerOutOfVehicleCheck", self)
    self:RegisterEvent(self.hIsPlayerOutOfVehicleCheckEvent)
  end
end

function SOE_2_Mission_2.SkylarWalkTowardsWilcox()
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  Nav.CancelFollowObject(hSkylar)
  local hWilcox = Util.GetHandleByName("Missions\\soe_2\\mission_2\\wilcox2\\Spore_RS_Wilcox")
  Nav.MoveToObject(hSkylar, hWilcox, 2, true)
end

function SOE_2_Mission_2:Con_TrainGo_Task()
  Cin.PlayConversation("311_Con_TrainGo", "SOE_2_Mission_2.Task_GetToTrainStation", nil)
  Train.TrainStart("CountrySide\\centre\\AiRails\\AI_Rail_Dtrain2")
end

function SOE_2_Mission_2.Task_GetToTrainStation()
  SOE_2_Mission_2.DisableTrainAP(SOE_2_Mission_2)
  Sound.SetMusicLocale("S2M2_Train")
  Sound.SetMusicLocale("m_S2M2_Train", "trainStation")
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  local hWilcox = Handle("Missions\\soe_2\\mission_2\\wilcox2\\Spore_RS_Wilcox")
  if hSkylar then
    Combat.SetGrabbable(hSkylar, false)
  end
  if hWilcox then
    Combat.SetGrabbable(hWilcox, false)
  end
  SOE_2_Mission_2.tSaveInfo.bFailPlayerForDistance = false
  if SOE_2_Mission_2.tSaveInfo.GetToTrainStationRanOnce == false then
    SOE_2_Mission_2.tSaveInfo.GetToTrainStationRanOnce = true
    if SOE_2_Mission_2.bTrainCreatedFirstTime == true then
      Train.TrainSuperCull("CountrySide\\centre\\AiRails\\AI_Rail_Starter")
      SOE_2_Mission_2.OldSetup(SOE_2_Mission_2)
    end
    if SOE_2_Mission_2.tSaveInfo.GetToTrainStationTaskConvo == false then
      SOE_2_Mission_2.tSaveInfo.GetToTrainStationTaskConvo = true
      local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
      Nav.CancelFollowObject(hSkylar)
      SOE_2_Mission_2.PlayConvoUsingQueue(SOE_2_Mission_2, "S2M2_Train_Start", 10, {})
      if SOE_2_Mission_2.tSaveInfo.bSetupGotoTrain == false then
        SOE_2_Mission_2.tSaveInfo.bSetupGotoTrain = true
        SOE_2_Mission_2.Task_GetToTrainStation_(SOE_2_Mission_2)
      end
    end
  end
end

function SOE_2_Mission_2:BullshitLoopDtrain2StreamIn()
  if Train.TrainIsStreamedIn("CountrySide\\centre\\airails\\AI_Rail_Dtrain2") then
    local tEvent = {EventType = "TimerEvent", Time = 1}
    self.hBullshitSeeEvent = Util.CreateEvent(tEvent, "SOE_2_Mission_2.BullshitLoopDtrain2StreamInPart2", self)
  else
    local tEvent = {EventType = "TimerEvent", Time = 1}
    self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.BullshitLoopDtrain2StreamIn", self))
  end
end

function SOE_2_Mission_2:BullshitLoopDtrain2StreamInPart2()
end

function SOE_2_Mission_2:SetupBullshitEvents()
  self.tTrainGetOnEvents = {}
  table.insert(self.tTrainGetOnEvents, EVENT_PlayerToActorProximity("SOE_2_Mission_2.FinishedBullshitEvents", self, self.tCarriageHandles[1], 15))
  table.insert(self.tTrainGetOnEvents, EVENT_PlayerToActorProximity("SOE_2_Mission_2.FinishedBullshitEvents", self, self.tCarriageHandles[2], 15))
  table.insert(self.tTrainGetOnEvents, EVENT_PlayerToActorProximity("SOE_2_Mission_2.FinishedBullshitEvents", self, self.tCarriageHandles[3], 15))
  table.insert(self.tTrainGetOnEvents, EVENT_PlayerToActorProximity("SOE_2_Mission_2.FinishedBullshitEvents", self, self.tCarriageHandles[4], 15))
  table.insert(self.tTrainGetOnEvents, EVENT_PlayerToActorProximity("SOE_2_Mission_2.FinishedBullshitEvents", self, self.tCarriageHandles[5], 15))
  table.insert(self.tTrainGetOnEvents, EVENT_PlayerToActorProximity("SOE_2_Mission_2.FinishedBullshitEvents", self, self.tCarriageHandles[6], 15))
  table.insert(self.tTrainGetOnEvents, EVENT_PlayerToActorProximity("SOE_2_Mission_2.FinishedBullshitEvents", self, self.tCarriageHandles[7], 15))
  table.insert(self.tTrainGetOnEvents, EVENT_PlayerToActorProximity("SOE_2_Mission_2.FinishedBullshitEvents", self, self.tCarriageHandles[8], 15))
  table.insert(self.tTrainGetOnEvents, EVENT_PlayerToActorProximity("SOE_2_Mission_2.FinishedBullshitEvents", self, self.tCarriageHandles[9], 15))
  table.insert(self.tTrainGetOnEvents, EVENT_PlayerToActorProximity("SOE_2_Mission_2.FinishedBullshitEvents", self, self.tCarriageHandles[10], 15))
  table.insert(self.tTrainGetOnEvents, EVENT_PlayerToActorProximity("SOE_2_Mission_2.FinishedBullshitEvents", self, self.tCarriageHandles[12], 15))
  table.insert(self.tTrainGetOnEvents, EVENT_PlayerToActorProximity("SOE_2_Mission_2.FinishedBullshitEvents", self, self.tCarriageHandles[13], 25))
end

function SOE_2_Mission_2:KillBullshitEvents()
  if self.tTrainGetOnEvents then
    for i, v in ipairs(self.tTrainGetOnEvents) do
      EVENT_KillEvent(v)
    end
  end
end

function SOE_2_Mission_2:FinishedBullshitEvents()
  self.KillBullshitEvents(self)
end

function SOE_2_Mission_2:Task_GetToTrainStation_()
  self.SetupWTFEvents(self)
  self.EnterTrainYard(self)
  Sound.PlayOwnerlessSoundEvent("Fol_train_whistle_S2M2")
end

function SOE_2_Mission_2:ChangeGetOnTrainName()
  self.StartTrain(self)
  self:ChangeObjTextByName("Get_on_train_", "S2M2_Text.CatchTrain")
  self.PlayConvoUsingQueue(self, "S2M2_Train_Catch", 10, {})
end

function SOE_2_Mission_2:Task_NearingEnd(tUserData)
  self.KillBullshitEvents(self)
  Util.KillEvent(self.hTwoMinTimer)
  if tUserData then
    self:KillTaskByName(tUserData)
  end
  if self.tSaveInfo.bTrainStarted == true then
    return 0
  end
  self.tSaveInfo.bTrainStarted = true
  self.Task_DestroyComCenter(self)
  Trigger.DoNotWaitFor("Missions\\soe_2\\mission_2\\triggerbox\\Wilcox_Cinematic", hSab)
  self.GetHandleEngineLater(self)
end

function SOE_2_Mission_2:Task_DestroyComCenter()
  local hTrainBomb = AttractionPt.FindPtInObject(self.tCarriageHandles[11], "TrainThrottle")
  AttractionPt.EnableUse(hTrainBomb, true)
  local hStuff = AttractionPt.FindPtInObject(self.tCarriageHandles[11], "TrainThrottle")
  if hStuff ~= nil then
    self.hDecoupleHandle = hStuff
  end
  self:CreateTask({
    sName = "DestroyComLine",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    bBlipLocatorsOnly = true,
    tTgtInclude = {
      self.hDecoupleHandle
    },
    sObjectiveTextID = "S2M2_Text.DisableRadioCar",
    MarkerHeight = 0.5,
    tOnComplete = {
      {
        self.DecoupleDelay,
        {self}
      }
    }
  })
  self:CreateTask({
    sName = "Task_AssaultDepot",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "KILL",
    bNoGPS = true,
    tTgtInclude = {
      self.hDecoupleHandle
    },
    MarkerHeight = 0.5
  })
end

function SOE_2_Mission_2:DecoupleDelay()
  self:KillTaskByName("Task_AssaultDepot")
  local tEvent = {EventType = "TimerEvent", Time = 20}
  self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.DestroyedCom", self))
  self.GetOnToTheNextCarriageTask(self)
  self.PlayConvoUsingQueue(self, "S2M2_TrainComm_Complete", 12, {})
end

function SOE_2_Mission_2:CompleteNextCarriageTask()
  if self:IsMissionTaskActive("GetToNextCarriage") == true then
    self:CompleteTaskByName("GetToNextCarriage")
  end
end

function SOE_2_Mission_2:GetOnToTheNextCarriageTask()
  self:CreateTask({
    sName = "GetToNextCarriage",
    sTaskType = "SabTaskObjectiveDeliver",
    Proximity = 15,
    sTaskSubType = "DELIVER",
    MarkerHeight = 8.5,
    sObjectiveTextID = "S2M2_Text.GetOntheNextCarriage",
    tDestProximityObj = {
      self.tCarriageHandles[10]
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Task_GetToEngine,
        {self}
      }
    }
  })
  local tEvent = {EventType = "TimerEvent", Time = 20}
  Util.CreateEvent(tEvent, "SOE_2_Mission_2.CompleteNextCarriageTask", self)
end

function SOE_2_Mission_2:DestroyedCom()
  Train.TrainDecoupleCarriage(self.tCarriageHandles[11])
  self.bDecouple = true
end

function SOE_2_Mission_2:KillOperator()
  local newTrainGuy = self.hTrainGuy
  if newTrainGuy == nil then
    newTrainGuy = self.hTrainNaziWithConductor[1]
  end
  if newTrainGuy then
    if Object.IsAlive(newTrainGuy) then
      self:CreateTask({
        sName = "KillOperatorTask",
        sTaskType = "SabTaskObjectiveDestroy",
        sTaskSubType = "KILL",
        tTgtInclude = {newTrainGuy},
        sObjectiveTextID = "S2M2_Text.KillConductor",
        tOnComplete = {
          {
            self.Task_GetToEngine2,
            {self}
          },
          {
            self.KilledConductorConvo,
            {self}
          }
        }
      })
    else
      self.Task_GetToEngine2(self)
    end
  else
    self.Task_GetToEngine2(self)
  end
end

function SOE_2_Mission_2:KilledConductorConvo()
  self.PlayConvoUsingQueue(self, "S2M2_TrainStop_KilledConductor", 10, {})
  Train.TrainStop("CountrySide\\centre\\AiRails\\AI_Rail_Starter")
end

function SOE_2_Mission_2:TalkToKesler()
  self.bDoNotStopTrain = true
  Train.TrainSetStopAtStation("CountrySide\\centre\\AiRails\\AI_Rail_Starter", false)
  self.GetToKeslerinCarriage(self)
end

function SOE_2_Mission_2:GetToKeslerinCarriage()
  if self.hTimerFailForTrain then
    HUD.RemoveObjective(self.hTimerFailForTrain)
  end
  local hDoorOpen = AttractionPt.FindPtInObject(self.tCarriageHandles[3], "TrainThrottle")
  local nTime
  if self.nCTStation == 1 then
    nTime = 42
  else
    nTime = 49
  end
  self.hTrainGoOffBridge = HUD.AddObjective(eOT_TIMER, self:GetLocalizedText("P1M1B_Text.METER_TimerFail"), 2)
  HUD.SetupProgressBar(self.hTrainGoOffBridge, nTime, 0, nTime)
  HUD.AddProgressBarCallback(self.hTrainGoOffBridge, "SOE_2_Mission_2.FailKesslerTimer", 0, self, {})
  if hDoorOpen then
    self:CreateTask({
      sName = "GetToCarriageKeslerUsePT",
      sTaskType = "SabTaskObjectiveInteract",
      sTaskSubType = "USE",
      MarkerHeight = 4.4,
      tTgtInclude = {hDoorOpen},
      sObjectiveTextID = "S2M2_Text.GetToPrisonCar",
      tOnComplete = {
        {
          self.CinematicLoadingSequence,
          {self}
        }
      }
    })
  else
    Util.Assert(false, "Attraction point not found -get hayato")
    self:CreateTask({
      sName = "GetToCarriageKesler",
      sTaskType = "SabTaskObjectiveDeliver",
      Proximity = 15,
      sTaskSubType = "DELIVER",
      MarkerHeight = 8.5,
      sObjectiveTextID = "S2M2_Text.GetToPrisonCar",
      tDestProximityObj = {
        self.tCarriageHandles[3]
      },
      tDeliverObjs = {hSab},
      tOnComplete = {
        {
          self.CinematicLoadingSequence,
          {self}
        }
      }
    })
  end
end

function SOE_2_Mission_2:CinematicLoadingSequence()
  if self.hTrainGoOffBridge then
    HUD.RemoveObjective(self.hTrainGoOffBridge)
  end
  self.tSaveInfo.bFailPlayerForDistance = false
  self.bGotToKessler = true
  Util.UnloadStaticENTag("soe2m2trainbridge", true)
  Util.UnloadStaticENTag("s2m2_SkylarChair", true)
  Render.FadeScreen(true)
  local tEvent = {EventType = "TimerEvent", Time = 0.6}
  self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.FadeOutForBink", self))
  local tEvent = {EventType = "TimerEvent", Time = 0.5}
  Util.CreateEvent(tEvent, "SOE_2_Mission_2.CullDelay", self, nil)
end

function SOE_2_Mission_2:FadeOutForBink()
  Sound.UnloadSoundBank("cin_S2M2_end.bnk")
  Sound.UnloadSoundBank("m_S2M2_inGame.bnk")
  self.TeleportPlayerToOriginlol(self)
end

function SOE_2_Mission_2:TeleportPlayerToOriginlol()
  Object.PlayerTeleportToPos(-592, 42, -1621, 0, false, "SOE_2_Mission_2.PlayBinkMovieNow", self)
end

function SOE_2_Mission_2:StowSkylarWeapon()
  local hSkylar = Handle("Missions\\cinematics\\312_cinb_defect\\Spore_RS_Skylar")
  if hSkylar then
    Inventory.HolsterWeapons(hSkylar)
  end
end

function SOE_2_Mission_2:PlayBinkMovieNow()
  Render.FadeScreen(true)
  Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\cinematics\\312_cinb_defect\\Spore_RS_Skylar"
    },
    WaitForGameObject = true
  }, "SOE_2_Mission_2.StowSkylarWeapon", self, nil)
  self:CreateTask({
    sName = "TASK_TRAINBOOMCIN",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "312_313_Merged",
    bOverrideFade = true,
    tCinematicNodes = {
      "Missions\\cinematics\\312_cinb_defect"
    },
    tStaticTags = {
      "S2M2_CinematicProp"
    },
    tOnActivate = {
      {
        self.MergedCinematicTimedFadeOut,
        {self}
      }
    },
    tOnComplete = {
      {
        self.CompleteMission,
        {self}
      }
    }
  })
end

function SOE_2_Mission_2:MergedCinematicTimedFadeOut()
  local tEvent = {EventType = TimerEvent, Time = 0.5}
  Util.CreateEvent(tEvent, "SOE_2_Mission_2.MergedCinematicFadeOut", self)
end

function SOE_2_Mission_2:MergedCinematicFadeOut()
  Render.FadeScreen(false)
end

function SOE_2_Mission_2:CullDelay()
  if self.nCTStation <= 1 then
    Train.TrainSuperCull("CountrySide\\centre\\AiRails\\AI_Rail_Starter")
  else
    Train.TrainSuperCull("Missions\\soe_2\\mission_2\\enc5_bend\\AI Rail Chain")
  end
end

function SOE_2_Mission_2:BinkEnded()
  Render.FadeTo(0, 0, 0, 255, 0.2)
  Sound.ResetMusicLocale()
  self:CompleteCurrentMission()
end

function SOE_2_Mission_2:DerailTrain()
  Render.FadeTo(0, 0, 0, 255, 0.4)
  Sound.ResetMusicLocale()
  local tEvent = {EventType = "TimerEvent", Time = 1}
  self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.FadebackInAndPlay", self))
  self.tSaveInfo.bWarnPlayer10 = true
  self.tSaveInfo.bWarnPlayer20 = true
end

function SOE_2_Mission_2:Fadebackin2()
  Render.FadeTo(0, 0, 0, 0, 0.3)
end

function SOE_2_Mission_2:SuperCull()
  self.tSaveInfo.bFailPlayerForDistance = false
  Train.TrainSuperCull("CountrySide\\centre\\AiRails\\AI_Rail_Starter")
end

function SOE_2_Mission_2:FadebackInAndPlay()
  Object.PlayerTeleportToPos(-838, 56, -1539, 0, "SOE_2_Mission_2.PlayTheDestroyCinematic", self)
  self.tSaveInfo.bFailPlayerForDistance = false
  Train.TrainSuperCull("CountrySide\\centre\\AiRails\\AI_Rail_Starter")
end

function SOE_2_Mission_2:PlayTheDestroyCinematic()
  Cin.PlayCinematic("312_313", false, "SOE_2_Mission_2.CompleteMissionDelay", self)
  local tEvent = {EventType = "TimerEvent", Time = 1}
  self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.Fadebackin2", self))
end

function SOE_2_Mission_2:CompleteMissionDelay()
  local tEvent = {EventType = "TimerEvent", Time = 2}
  self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2.CompleteMission", self))
end

function SOE_2_Mission_2:CompleteMission()
  Zone.SwitchState("WtF_Zones\\global\\S2M2_Train", cZONESTATE_HIGHWTF, cENT_IMMEDIATE, true)
  Zone.SwitchState("WtF_Zones\\global\\S2M2_Train_2", cZONESTATE_HIGHWTF, cENT_IMMEDIATE, true)
  Util.SetDynamicPriority("VH_CV_CR_Skylar_01", -1)
  Util.SetDynamicPriority("Human_RS_Wilcox", -1)
  Util.SetDynamicPriority("VH_CV_CR_Peugeot402_01", 1500)
  self:UnloadTaskNodes("TASK_TRAINBOOMCIN")
  self:UnloadTaskNodes("Missions\\soe_2\\mission_2\\wilcox2")
  local hVehicle = Util.GetHandleByName("Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)")
  if hVehicle then
    Object.SetShouldNeverRegisterGameObjectEvents(hVehicle, true)
  end
  Sound.ResetMusicLocale()
  Sound.ReleaseSoundBank("cin_S2M2_end.bnk")
  Vehicle.EnableTraffic(true, false)
  Render.FadeScreen(false)
  Suspicion.ResetEscalation()
  Cin.StopConversation("312_CinB_Defect")
  Util.SpawnEditNode("Missions\\soe_2\\mission_2\\KesslerAndSkylar.wsd")
  Util.SpawnEditNode("Missions\\soe_2\\mission_2\\kesslerandskylarcar.wsd")
  Object.PlayerTeleportToPos(-809.1476, 46.5785, -1447.66, -3.373, true, "SOE_2_Mission_2.FinishTrainMissionAfterTeleport", self)
end

function SOE_2_Mission_2:FinishTrainMissionAfterTeleport()
  Util.SendPerkMessage("BridgeBlowUp")
  self:CompleteThisMission()
end

function SOE_2_Mission_2:MISSION_ONCANCEL()
  if self.bTrafficEnabled ~= nil then
    Vehicle.EnableTraffic(true, false)
  end
  Train.TrainSuperCull("Missions\\soe_2\\mission_2\\enc5_bend\\AI Rail Chain")
  Train.TrainSuperCull("CountrySide\\centre\\AiRails\\AI_Rail_Starter")
  Train.TrainSuperCull("Missions\\soe_2\\mission_2\\enc3_chambord\\extra\\AI Rail Chain")
  Train.TrainSuperCull("Missions\\soe_2\\mission_2\\enc6_bridge\\train\\Dtrain4")
  Util.SetDynamicPriority("VH_CV_CR_Skylar_01", -1)
  Util.SetDynamicPriority("Human_RS_Wilcox", -1)
  self.bCanceled = true
end

function SOE_2_Mission_2.FinalTeleportUnderBridge()
  Object.Teleport(hSab, -1003, 24, -1437, 0)
end

function SOE_2_Mission_2:WilcoxGoInCarAndFlashLights()
  local hWilcox = Util.GetHandleByName("Missions\\soe_2\\mission_2\\wilcox2\\CV_N_Wilcox")
  local hVehicle = Util.GetHandleByName("Missions\\soe_2\\mission_2\\wilcox2\\VH_CV_CR_TalbotLago_01")
  self.bBlinkLights = true
  self.nBlinking = 1
  Actor.BoardVehicle(hWilcox, hVehicle, "PILOT")
  EVENT_PlayerToActorProximity("SOE_2_Mission_2.BlinkLights", self, hVehicle, 25)
  EVENT_PlayerToActorProximity("SOE_2_Mission_2.WilcoxGetOut", self, hWilcox, 5)
end

function SOE_2_Mission_2:WilcoxGetOut()
  local hWilcox = Util.GetHandleByName("Missions\\soe_2\\mission_2\\wilcox2\\CV_N_Wilcox")
  Actor.UnboardVehicle(hWilcox)
end

function SOE_2_Mission_2:BlinkLights()
  local hVehicle = Util.GetHandleByName("Missions\\soe_2\\mission_2\\wilcox2\\VH_CV_CR_TalbotLago_01")
  if self.bBlinkLights == true then
    if self.nBlinking > 0 then
      Vehicle.TurnHeadlightsOn(hVehicle)
    else
      Vehicle.TurnHeadlightsOff(hVehicle)
    end
  end
  self.nBlinking = self.nBlinking * -1
  EVENT_Timer("SOE_2_Mission_2.BlinkLights", self, 1)
end

function SOE_2_Mission_2:SetupCheckpoint1()
  self.RegisterCheckpoint(self, "SOE_2_Mission_2.Checkpoint1")
end

function SOE_2_Mission_2:EscalationMusicSetupLevel0()
  self:CreateTask({
    sName = "MusicChangeEscalation0",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = true,
    bRepeatable = true,
    tOnComplete = {
      {
        self.EscalationMusicSetupLevel1,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function SOE_2_Mission_2:EscalationMusicSetupLevel1()
  self:CreateTask({
    sName = "MusicChangeEscalation1",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 0,
    bRepeatable = true,
    tOnComplete = {
      {
        self.EscalationMusicSetupLevel0,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function SOE_2_Mission_2:Checkpoint1()
  Sound.SetMusicLocale("S2M2_Train")
  Sound.SetMusicLocale("m_S2M2_Train", "BridgeSabotage")
  Util.KillEvent(self.eCarStreamOut)
  Convo.ResetForFail()
  if self.hCarDeathEventSkylar then
    Util.KillEvent(self.hCarDeathEventSkylar)
  end
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar")
  if hSkylar then
    Combat.SetGrabbable(hSkylar, false)
  end
  Util.SetMiniZepSpline("Missions\\soe_2\\mission_2\\ambientevents\\bridgeflight")
  local hVehicle = Util.GetHandleByName("Missions\\soe_2\\mission_2\\missioncar\\VH_CV_CR_Citroen7C_01(3)")
  self.S2M2_BridgeSabotage_Start_Convo_Task(self)
end

function SOE_2_Mission_2:SetupCheckpoint2()
  self.RegisterCheckpoint(self, "SOE_2_Mission_2.Checkpoint2")
end

function SOE_2_Mission_2:Checkpoint2()
  Convo.ResetForFail()
  self.FakeRendezvousWilcoxTask(self)
  self:FailTaskByName("MusicChangeEscalation0")
  self:FailTaskByName("MusicChangeEscalation1")
  Train.TrainCreate("CountrySide\\centre\\AiRails\\AI_Rail_Dtrain2", "Dtrain2")
  Train.TrainStop("CountrySide\\centre\\AiRails\\AI_Rail_Dtrain2")
end

function SOE_2_Mission_2:SetupCheckpoint3()
  self.RegisterCheckpoint(self, "SOE_2_Mission_2.Checkpoint3")
end

function SOE_2_Mission_2:Checkpoint3()
  Convo.ResetForFail()
  self:UnloadTaskNodes("Missions\\soe_2\\mission_2\\ConversationAndmisc\\conversation2", true)
  self:CreateTask({
    sName = "TASK_FatLoad",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\soe_2\\mission_2\\enc2_bridge\\spawners",
      "Missions\\soe_2\\mission_2\\enc3_chambord\\nazis_spawners",
      "Missions\\soe_2\\mission_2\\enc3_chambord\\nazis_back",
      "Missions\\soe_2\\mission_2\\enc4_station\\spawners",
      "Missions\\soe_2\\mission_2\\enc3_drive"
    },
    tOnActivate = {}
  })
  self.PlayerDeathSetup(self)
  self.Con_TrainGo_Task(self)
end

function SOE_2_Mission_2:SetupCheckpoint4()
  local hLoc = Handle("Missions\\soe_2\\mission_2\\triggerbox\\LOC_Checkpoint4")
  self.RegisterCheckpoint(self, "SOE_2_Mission_2.Checkpoint4", nil, true, hLoc)
end

function SOE_2_Mission_2:Checkpoint4()
  Convo.ResetForFail()
  self.tSaveInfo.bWarnPlayer10 = true
  self.tSaveInfo.bWarnPlayer20 = true
  self.PlayerDeathSetup(self)
  if self.nCTStation > 0 then
    self.tSaveInfo.nRealSize = 0
    Suspicion.SetEscalated()
    self.bEnableTimerForTrain = true
    self.tSaveInfo.bFailPlayerForDistance = false
    if self.nCTStation == 1 then
      Train.TrainSuperCull("CountrySide\\centre\\AiRails\\AI_Rail_Starter")
    else
      Train.TrainSuperCull("Missions\\soe_2\\mission_2\\enc5_bend\\AI Rail Chain")
    end
    self.bDoNotStopTrain = false
    self.OldSetup2(self)
    Train.TrainRegisterPlayerDistanceCallback("Missions\\soe_2\\mission_2\\enc4_station\\trainrail2", "SOE_2_Mission_2.TenMeterTip2", 30, self)
  else
    SOE_2_Mission_2.FailTimerEventAtCTstation(self)
  end
  self.nCTStation = self.nCTStation + 1
end

function SOE_2_Mission_2:OldSetup2()
  local sNewRailName = "Missions\\soe_2\\mission_2\\enc5_bend\\AI Rail Chain"
  self.tSaveInfo.bFailPlayerForDistance = true
  self.hTrainEngine = nil
  Train.TrainCreate(sNewRailName, "DtrainB")
  Train.TrainStop(sNewRailName)
  self.tCarriageHandles = {}
  Train.TrainRegisterEngineCallback(sNewRailName, "SOE_2_Mission_2.GetEngineHandle2", self)
  Train.TrainRegisterCarriageCallback(sNewRailName, "SOE_2_Mission_2.AddCarriageHandleToTable", self)
end

function SOE_2_Mission_2:GetEngineHandle2(tdata)
  self.hTrainEngine = tdata[2]
  local tEvent = {EventType = "TimerEvent", Time = 0.5}
  Util.CreateEvent(tEvent, "SOE_2_Mission_2.GetATPTFromCarriage", self)
end

function SOE_2_Mission_2:GetATPTFromCarriage()
  local wtfpt = AttractionPt.FindPtInObject(self.hTrainEngine, "TrainThrottle")
  self.hATPT2 = wtfpt
  if wtfpt ~= nil and Train.TrainIsStreamedIn("Missions\\soe_2\\mission_2\\enc5_bend\\AI Rail Chain") == true then
    Render.FadeScreen(false)
    self.FailTimerEventAtCTstation(self)
    self:CreateTask({
      sName = "GetToPoint5",
      sTaskType = "SabTaskObjectiveInteract",
      sTaskSubType = "USE",
      tTgtInclude = {
        self.hATPT2
      },
      bRepeatable = true,
      sObjectiveTextID = "S2M2_Text.JamThrottle",
      MarkerHeight = 1,
      tOnComplete = {
        {
          self.HaulAss2,
          {self}
        }
      }
    })
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\naziclimb\\PT_Floorit", self.hTrainEngine, "SOE_2_Mission_2.CouldNotGetToKessler", self, nil, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\naziclimb\\PT_Floorit")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\soe_2\\mission_2\\triggerbox\\PT_derailtrain", self.hTrainEngine, "SOE_2_Mission_2.GetToKesslerWarning", self, nil, cTRIGGEREVENT_ONENTER), "Missions\\soe_2\\mission_2\\triggerbox\\PT_derailtrain")
  else
    local tEvent = {EventType = "TimerEvent", Time = 0.5}
    Util.CreateEvent(tEvent, "SOE_2_Mission_2.GetATPTFromCarriage", self)
  end
end

function SOE_2_Mission_2:HaulAss2()
  local hKesslerDoor = AttractionPt.FindPtInObject(self.tCarriageHandles[3], "TrainThrottle")
  AttractionPt.EnableUse(hKesslerDoor, true)
  local hUsePoint = AttractionPt.FindPtInObject(self.hTrainEngine, "TrainThrottle")
  AttractionPt.EnableUse(hUsePoint, false)
  local sNewRailName = "Missions\\soe_2\\mission_2\\enc5_bend\\AI Rail Chain"
  self.bDoNotStopTrain = true
  Train.TrainSetStopAtStation("CountrySide\\centre\\AiRails\\AI_Rail_Starter", false)
  self.bStillStuffToDoBeforeRescueKesler = false
  self.TalkToKesler(self)
  self.PlayConvoUsingQueue(self, "S2M2_TrainEngine_Complete", 2, {})
  self.PlayConvoUsingQueue(self, "S2M2_KesslerRescue_Start", 1, {})
  self:KillTaskByName("ENGINEFULLSPEED")
  self:KillTaskByName("GetToPoint5")
  self:KillTaskByName("ENGROOMPART")
  self:KillTaskByName("FakeRescueNagel")
  Train.TrainStart(sNewRailName)
  Train.TrainSetMaxSpeed(sNewRailName, "8")
  Sound.LoadSoundBank("cin_S2M2_end.bnk")
end

function SOE_2_Mission_2:TenMeterTip2()
  if self.tSaveInfo.bFailPlayerForDistance == true and self.tSaveInfo.bWarnPlayer10 == false then
    self.tSaveInfo.bWarnPlayer10 = true
    Train.TrainRegisterPlayerDistanceCallback("Missions\\soe_2\\mission_2\\enc5_bend\\AI Rail Chain", "SOE_2_Mission_2.TwentyMeterTip2", 100, self)
    self.PlayConvoUsingQueue(self, "S2M2_TrainTooFar_Warning", 10, {})
  end
end

function SOE_2_Mission_2:TwentyMeterTip2()
  if self.tSaveInfo.bFailPlayerForDistance == true and self.tSaveInfo.bWarnPlayer20 == false then
    self.tSaveInfo.bWarnPlayer20 = true
    self.PlayConvoUsingQueue(self, "S2M2_TrainTooFar_LastChance", 10, {})
    Train.TrainRegisterStreamoutCallback("Missions\\soe_2\\mission_2\\enc5_bend\\AI Rail Chain", "SOE_2_Mission_2.FailMissionDistance", self, {1})
  end
end

function SOE_2_Mission_2:ResetMission()
  if self.hTimerFailForTrain then
    HUD.RemoveObjective(self.hTimerFailForTrain)
  end
  if self.hTrainGoOffBridge then
    HUD.RemoveObjective(self.hTrainGoOffBridge)
  end
  self.bDoNotStopTrain = false
  Train.TrainSuperCull("Missions\\soe_2\\mission_2\\enc5_bend\\AI Rail Chain")
  Train.TrainSuperCull("CountrySide\\centre\\AiRails\\AI_Rail_Starter")
  Train.TrainSuperCull("Missions\\soe_2\\mission_2\\enc3_chambord\\extra\\AI Rail Chain")
  Train.TrainSuperCull("Missions\\soe_2\\mission_2\\enc6_bridge\\train\\Dtrain4")
  Util.UnloadEditNode("Missions\\soe_2\\mission_2\\missioncar.wsd", true, false)
  Util.UnloadStaticENTag("s2m2_SkylarChair", true)
  Convo.ResetForFail()
  Sound.ResetMusicLocale()
end
