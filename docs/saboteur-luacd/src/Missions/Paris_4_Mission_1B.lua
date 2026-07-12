if Paris_4_Mission_1B == nil then
  Paris_4_Mission_1B = SabTaskObjective:Create()
  Paris_4_Mission_1B:Configure({
    TaskCount = "auto",
    sStarter = "SkylarBelle",
    sConvFile = "P4M1b_Start",
    sSaveMissionNameID = "MissionNames_Text.P4M1B",
    sHQNextMissionStartPoint = _cHQe_CHURCH,
    tUnlockList = {
      "SOE_Zeppelin"
    },
    tSMEDNodes = {
      "Missions\\paris_4\\mission_1b\\main",
      "Missions\\paris_4\\mission_1b\\skylarstuff",
      "Missions\\paris_4\\mission_1b\\DeliveryCar"
    }
  })
end

function Paris_4_Mission_1B:STARTER_Setup()
  self.sDebugLabel = "P4M1B"
  self.bDebugMode = false
end

function Paris_4_Mission_1B:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.SetupCheckPoint1(self)
end

function Paris_4_Mission_1B:GENERAL_Setup()
  self.tInfo = {}
  self.tInfo.LVSkylar = "Missions\\paris_4\\mission_1B\\SkylarStuff\\Spore_RS_Skylar"
  self.sDeliveryTruck = "Missions\\paris_4\\mission_1b\\DeliveryCar\\VH_CV_CR_Skylar_01_P4M1b"
  self.sSkylarWalkPath = "Missions\\paris_4\\mission_1b\\main\\SkylarWalkPath"
  self.sLeHavreHQDoor = "LeHavre\\dock\\buildings\\TownChurch_Door_L"
  self.sSkyEnterHQPath = "Missions\\paris_4\\mission_1b\\main\\SkylarEnterHQ"
  self.sMissionDoneTrig = "Missions\\paris_4\\mission_1b\\main\\MissionCompleteTrig"
  self.sLaHavreHQDoorPt = "LeHavre\\lehavre_hq_ext\\TeleportDoubleDoorTriggerPoint"
  HUD.SetEnableAllGPSEdgesInTrigger("Missions\\paris_4\\mission_1b\\main\\NearCheckpointTrig", false)
end

function Paris_4_Mission_1B:OnSkylarDead()
  self:MissionTaskFail("Char_Death.RS_Skylar")
end

function Paris_4_Mission_1B:SetupCheckPoint1()
  self.RegisterCheckpoint(self, "Paris_4_Mission_1B.CheckPoint1")
end

function Paris_4_Mission_1B:CheckPoint1()
  self:TASK_ExitLaVillette()
end

function Paris_4_Mission_1B:TASK_ExitLaVillette()
  self:CreateTask({
    sName = "TASK_ExitTheBelle",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sObjectiveTextID = "P4M1B_Text.TASK_ExitLaVillette",
    sInteriorName = "Belle",
    bInteriorTask = true,
    tLocators = {
      "Missions\\paris_4\\mission_1b\\main\\BelleExitLoc"
    },
    tOnComplete = {
      {
        self.SetupCheckPoint2,
        {self}
      }
    },
    tOnActivate = {
      {
        self.SetSkylarInteriorFollower,
        {self}
      }
    }
  })
end

function Paris_4_Mission_1B:SetupCheckPoint2()
  self.RegisterCheckpoint(self, "Paris_4_Mission_1B.CheckPoint2")
end

function Paris_4_Mission_1B:CheckPoint2()
  RewardsManager.HideStarter("SkylarBelle")
  self:SetNearLHListener()
  self:SetupTruckStream()
  self:TASK_MasterDeliver()
end

function Paris_4_Mission_1B:SetSkylarInteriorFollower()
  local hSkyAttrPt = Handle("Missions\\paris_1\\characters\\lavillette\\skylar_interior\\AttractionPT_LaVillette_Skylar")
  local hSkylarLVInt = Handle("Missions\\paris_1\\characters\\belle\\skylar_belle_int\\SkylarBelle")
  Joe.MakeSabFollower(hSkylarLVInt, false)
end

function Paris_4_Mission_1B:TASK_GoToTheDeliveryTruck()
  self:CreateTask({
    sName = "TASK_GoToTheDeliveryTruck",
    sTaskType = "SabTaskObjectiveDeliver",
    Proximity = 1,
    sTaskSubType = "DELIVER",
    sObjectiveTextID = "P4M1B_Text.TASK_GoToTheDeliveryTruck",
    ParentObjectID = self:GetTaskObjectiveID("TASK_MasterDeliver"),
    tDestProximityObj = {
      self.sDeliveryTruck
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.TASK_TaxiSkyface,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Paris_4_Mission_1B:TASK_RoadTriptoLeHavre()
  self:CreateTask({
    sName = "TASK_RoadTriptoLeHavre",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P4M1B_Text.TASK_RoadTriptoLeHavre",
    bHighPriorityFocus = true,
    tDeliverObjs = {hSab},
    tDestRegion = {
      "Missions\\paris_4\\mission_1B\\Main\\LeHavreTrig"
    },
    tLocators = {
      "Missions\\paris_4\\mission_1B\\Main\\LeHavreBaseLoc"
    },
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    },
    tOnActivate = {
      {
        self.SetupSquads,
        {self}
      }
    }
  })
end

function Paris_4_Mission_1B:SetupSquads()
  Squad.AddMember("Cowboyz", Util.GetHandleByName("Missions\\paris_4\\mission_1b\\skylarstuff\\Spore_RS_Skylar"))
  Squad.FollowLeader("Cowboyz")
end

function Paris_4_Mission_1B:TASK_ProtecttheTruck()
  self:CreateTask({
    sName = "TASK_ProtecttheTruck",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "DEFEND",
    sObjectiveTextID = "GenericObjective_Text.DEFEND_Truck",
    bNoGPS = true,
    ParentObjectID = self:GetTaskObjectiveID("TASK_RoadTriptoLeHavre"),
    tTgtInclude = {
      "Missions\\paris_4\\mission_1b\\DeliveryCar\\VH_CV_CR_Skylar_01_P4M1b"
    },
    tOnComplete = {},
    tOnCancel = {},
    tOnFailure = {
      {
        self.FailTaskByName,
        {
          self,
          "TASK_ProtecttheTruck"
        }
      }
    },
    tOnDamage = {},
    tOnActivate = {}
  })
end

function Paris_4_Mission_1B:TASK_TaxiSkyface()
  self:CreateTask({
    sName = "TASK_TaxiSkyface",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "P4M1B_Text.TASK_MasterDeliver",
    sVehicleReturnID = "GenericObjective_Text.Vehicle_GetInBack_The",
    sVehicleFetchID = "GenericObjective_Text.Vehicle_GetIn_The",
    ParentObjectID = self:GetTaskObjectiveID("TASK_MasterDeliver"),
    tDestLocators = {
      "Missions\\paris_4\\mission_1b\\main\\LeHavreBaseLoc"
    },
    tPickupProxObj = {
      "Missions\\paris_4\\mission_1b\\skylarstuff\\Spore_RS_Skylar"
    },
    tDestRegion = {
      "Missions\\paris_4\\mission_1b\\main\\LeHavreTrig"
    },
    tDeliverObjs = {
      "Missions\\paris_4\\mission_1b\\skylarstuff\\Spore_RS_Skylar"
    },
    sRequiredVehicle = "Missions\\paris_4\\mission_1b\\DeliveryCar\\VH_CV_CR_Skylar_01_P4M1b",
    bGroundBlip = true,
    bVehicleIsRequired = true,
    bNoDumping = true,
    PickupProximity = 30,
    bEscalationDenial = true,
    tOnEarlyExit = {},
    tOnPickup = {
      {
        self.PlayLongDriveConvo,
        {self}
      }
    },
    tOnComplete = {
      {
        self.RunMissionCompleteStuff,
        {self}
      }
    },
    tOnActivate = {
      {
        self.SetStreamSkylarEXT,
        {self}
      }
    },
    tSMEDNodes = {}
  })
end

function Paris_4_Mission_1B:PlayLongDriveConvo()
  Cin.PlayConversation("P4M1B_Escape_Detour", "Paris_4_Mission_1B.PlayExtendedBanter", self)
  Joe.ClearSabFollower(self.hEXTSkylar, true, "P4M1B")
end

function Paris_4_Mission_1B:PlayExtendedBanter()
  Cin.PlayConversation("P4M1b_Escape_LongDriveToLaHavre01")
end

function Paris_4_Mission_1B:TASK_MasterDeliver()
  self:CreateTask({
    sName = "TASK_MasterDeliver",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    tLocators = {},
    tOnActivate = {
      {
        self.TASK_TaxiSkyface,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Paris_4_Mission_1B:SetStreamSkylarEXT()
  local tSkylarStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      self.tInfo.LVSkylar
    }
  }
  Util.CreateEvent(tSkylarStreamEvent, "Paris_4_Mission_1B.SetupEXTSkylar", self)
end

function Paris_4_Mission_1B:SetupEXTSkylar()
  local hEXTSkylar = Handle(self.tInfo.LVSkylar)
  self.hEXTSkylar = hEXTSkylar
  Joe.MakeSabFollower(hEXTSkylar, true, 4, cMOVE_NORMAL, "P4M1B")
end

function Paris_4_Mission_1B:SetupTruckStream()
  dprint(self, "Waiting for Truck to Stream")
  local tTruckStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      self.sDeliveryTruck
    }
  }
  Util.CreateEvent(tTruckStreamEvent, "Paris_4_Mission_1B.SetupTruckDeathListener", self)
end

function Paris_4_Mission_1B:SetupTruckDeathListener()
  dprint(self, "Truck Death Listener Active")
  local hTruck = Util.GetHandleByName(self.sDeliveryTruck)
  self.hTruck = hTruck
  Vehicle.SetAsMissionCritical(self.hTruck, true)
  Object.SetShouldNeverRegisterGameObjectEvents(hTruck, true)
  Vehicle.SetDeathCallback(hTruck, "Paris_4_Mission_1B.OnVehicleDestroyed", self)
  Vehicle.RegisterWaterLoggedCallback(hTruck, "Paris_4_Mission_1B.OnVehicleDestroyed", self)
end

function Paris_4_Mission_1B:FailThisMission()
  self:MissionTaskFail()
end

function Paris_4_Mission_1B:OnVehicleDestroyed()
  self:MissionTaskFail("P4M1B_Text.FAILBYTRUCKDESTROYED")
end

function Paris_4_Mission_1B:OldRunMissionCompleteStuffz()
  self:CompleteTaskByName("TASK_MasterDeliver")
  Inventory.DetachItem(hSab, hArea2Papers, true)
  local hSkylar = Util.GetHandleByName(self.tInfo.LVSkylar)
  self.hSkylar = hSkylar
  Actor.OverrideCombatAI(hSkylar, true)
  local hHQAttrpt = Util.GetHandleByName(self.sLaHavreHQDoorPt)
  self.hHQAttrpt = hHQAttrpt
  Actor.UnboardVehicle(hSab)
  Actor.UnboardVehicle(self.hSkylar)
  self:RegisterTriggerEvent(Trigger.WaitFor(self.sMissio4nDoneTrig, hSab, "Paris_4_Mission_1B.EndThisMissionNow", self, nil, cTRIGGEREVENT_ONEXIT, false), self.sMissionDoneTrig)
  AttractionPt.EnableUse(self.hHQAttrpt, false)
  Vehicle.LockAllSeats(self.hTruck, true)
  Cin.PlayConversation("P4M1b_DroppedOffTruck")
  Nav.SetScriptedPath(hSkylar, self.sSkylarWalkPath, false, "Paris_4_Mission_1B.ActuateHQDoor", self)
  Nav.SetScriptedPathMoveMode(hSkylar, cMOVE_FAST)
end

function Paris_4_Mission_1B:ActuateHQDoor()
  local hHQDoor = Util.GetHandleByName(self.sLeHavreHQDoor)
  Object.Actuate(hHQDoor, false)
  EVENT_Timer("Paris_4_Mission_1B.SkyEntersHQ", self, 1.4)
end

function Paris_4_Mission_1B:EndThisMissionNow()
  AttractionPt.EnableUse(self.hHQAttrpt, true)
  self:CompleteThisMission()
end

function Paris_4_Mission_1B:SkyEntersHQ()
  Util.KillEvent("SkylarDeath")
  Nav.SetScriptedPath(self.hSkylar, self.sSkyEnterHQPath, false, "Paris_4_Mission_1B.EndThisMissionNow", self)
end

function Paris_4_Mission_1B:SetNearLHListener()
  dprint(self, "Near Le Havre Trig Set")
  local sCountryMidpoint = "Missions\\paris_4\\mission_1b\\main\\RomanticConvoTrig"
  local sNearLeHavreTrig = "Missions\\paris_4\\mission_1b\\main\\NearLeHavreTrig"
  self:RegisterTriggerEvent(Trigger.WaitFor(sNearLeHavreTrig, hSab, "Paris_4_Mission_1B.PlayNearLeHavreConvo", self, nil, cTRIGGEREVENT_ONENTER, false), sNearLeHavreTrig)
  self:RegisterTriggerEvent(Trigger.WaitFor(sCountryMidpoint, hSab, "Paris_4_Mission_1B.SetCountryMidPointConvo", self, nil, cTRIGGEREVENT_ONENTER, false), sCountryMidpoint)
end

function Paris_4_Mission_1B:SetCountryMidPointConvo()
  Cin.PlayConversation("P4M1B_Escape_BackRoad")
end

function Paris_4_Mission_1B:PlayNearLeHavreConvo()
  Cin.PlayConversation("P4M1b_GettingClose")
end

function Paris_4_Mission_1B:SetupNearCheckpointTrig()
  dprint(self, "Near Checkpoint Trig set")
  local sNearCheckpoint = "Missions\\paris_4\\mission_1b\\main\\NearCheckpointTrig"
  self:RegisterTriggerEvent(Trigger.WaitFor(sNearCheckpoint, hSab, "Paris_4_Mission_1B.PlayNearCheckpointConvo", self, nil, cTRIGGEREVENT_ONENTER, false), sNearCheckpoint)
end

function Paris_4_Mission_1B:PlayNearCheckpointConvo()
  Cin.PlayConversation("P4M1b_Escape_NearCheckpoint")
end

function Paris_4_Mission_1B:PlaySkylarLeftBehind()
  Cin.PlayConversation("P4M1x_Skylar_Abandoned")
end

function Paris_4_Mission_1B:CheckForSkylar()
  EVENT_Timer("Paris_4_Mission_1B.CheckSkylarSeat", self, 5)
end

function Paris_4_Mission_1B:CheckSkylarSeat()
  if Actor.IsInVehicle(hSab) == true and Actor.IsInVehicle(self.hEXTSkylar) == false then
    self:PlaySkylarLeftBehind()
  else
  end
end

function Paris_4_Mission_1B:RunMissionCompleteStuff()
  Actor.UnboardVehicle(Handle(self.tInfo.LVSkylar))
  Actor.UnboardVehicle(hSab)
  EVENT_PlayerExitsAnyVehicle("Paris_4_Mission_1B.LockDemSeats", self)
  EVENT_Timer("Paris_4_Mission_1B.RunDropOffConvo", self, 2)
end

function Paris_4_Mission_1B:LockDemSeats()
  Vehicle.LockAllSeats(Handle(self.sDeliveryTruck), true)
end

function Paris_4_Mission_1B:RunDropOffConvo()
  Cin.PlayConversation("P4M1b_DroppedOffTruck", "Paris_4_Mission_1B.StartEndSequence", self)
end

function Paris_4_Mission_1B:StartEndSequence()
  Vehicle.SetAsMissionCritical(self.hTruck, false)
  Render.FadeScreen(true, 1)
  if Actor.IsInVehicle(hSab) == true then
    Actor.UnboardVehicle(hSab)
    EVENT_Timer("Paris_4_Mission_1B.StartEndSequence", self, 1)
  else
    EVENT_Timer("Paris_4_Mission_1B.Unloadsomestuff", self, 1)
  end
end

function Paris_4_Mission_1B:Unloadsomestuff()
  Util.UnloadEditNode("Missions\\paris_4\\mission_1b\\DeliveryCar.wsd", true, false)
  Util.UnloadEditNode("Missions\\paris_4\\mission_1b\\skylarstuff.wsd", true, false)
  EVENT_Timer("Paris_4_Mission_1B.DelaytoLoadNoCrateVeh", self, 3)
end

function Paris_4_Mission_1B:DelaytoLoadNoCrateVeh()
  Util.SpawnEditNode("Missions\\paris_4\\mission_1b\\NoBoxCar.wsd", "Paris_4_Mission_1B.DoaLittleFadeyFade", self)
  Util.LoadStaticENTag("Garagekeeper_lehavre", true)
end

function Paris_4_Mission_1B:DoaLittleFadeyFade()
  EVENT_Timer("Paris_4_Mission_1B.NewVehLoaded", self, 1)
end

function Paris_4_Mission_1B:NewVehLoaded()
  Util.UnloadEditNode("Missions\\paris_4\\mission_1b\\NoBoxCar.wsd", false)
  Render.FadeScreen(false, 0)
  EVENT_Timer("Paris_4_Mission_1B.ENDNOWENDNOW", self, 2)
end

function Paris_4_Mission_1B:ENDNOWENDNOW()
  self:CompleteThisMission()
end

function Paris_4_Mission_1B:MISSION_ONCANCEL()
  RewardsManager.ShowStarter("SkylarBelle")
end

function Paris_4_Mission_1B:MISSION_ONRESET()
  HUD.SetEnableAllGPSEdgesInTrigger("Missions\\paris_4\\mission_1b\\main\\NearCheckpointTrig", true)
end
