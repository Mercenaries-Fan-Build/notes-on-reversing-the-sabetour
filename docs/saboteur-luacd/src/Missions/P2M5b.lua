if P2M5b == nil then
  P2M5b = SabTaskObjective:Create()
  gsP2M5b = "Missions\\paris_2\\mission_5b\\"
  P2M5b:Configure({
    TaskCount = 99,
    bStarterless = true,
    bExteriorRestart = true,
    sSaveMissionNameID = "MissionNames_Text.P2M5",
    bDisableMissionTitle = true,
    tUnlockList = {
      "Paris_1_Mission_6"
    },
    sHQStartPoint = _cHQe_HDV,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bSLOverrideFade = true,
    tSMEDNodes = {
      "Missions\\paris_2\\mission_5b\\main",
      "Missions\\hq_dropoff\\P1HQ"
    },
    tStaticTags = {}
  })
end

function P2M5b:STARTER_Setup()
end

function P2M5b:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self:MariaCheck()
end

function P2M5b:Testme()
  print("Vehicle death")
end

function P2M5b:MISSION_ONCANCEL()
  _P2M5b_ONCANCEL = true
  WorldSMEDNodes.UnloadNode("Missions\\paris_2\\mission_5\\exteriormaria", true)
  WorldSMEDNodes.UnloadNode("Missions\\paris_2\\mission_5b\\maria", true)
end

function P2M5b:MISSION_ONCOMPLETE()
  _P2M5b_ONCANCEL = true
  WorldSMEDNodes.UnloadNode("Missions\\paris_2\\mission_5\\exteriormaria", true)
  WorldSMEDNodes.UnloadNode("Missions\\paris_2\\mission_5b\\maria", true)
end

function P2M5b:GENERAL_Setup()
  self.tSaveInfo.bNewMariaLoaded = false
  self:AddOnCancelCallback(P2M5b.Reset)
  self:AddOnCompleteCallback(P2M5b.Reset)
end

function P2M5b:MariaCheck()
  local hMaria
  if _P2M5b_ONCANCEL then
    WorldSMEDNodes.UnloadNode("Missions\\paris_2\\mission_5\\exteriormaria", true)
  end
  if not _gb_P2M5_MariaPlayThrough then
    WorldSMEDNodes.UnloadNode("Missions\\paris_2\\mission_5\\exteriormaria", true)
  else
    hMaria = Handle("Missions\\paris_2\\mission_5\\exteriormaria\\Arena_Maria")
    _gb_P2M5_MariaPlayThrough = nil
  end
  if hMaria and Object.IsAlive(hMaria) and not _P2M5b_ONCANCEL then
    print("found old maria")
    self.tInfo.Maria = "Missions\\paris_2\\mission_5\\exteriormaria\\Arena_Maria"
    self:RegisterCheckpoint("P2M5b.Checkpoint1")
  else
    self.tSaveInfo.bNewMariaLoaded = true
    if WorldSMEDNodes.LoadNode("Missions\\paris_2\\mission_5b\\maria", "P2M5b.NewMariaLoaded", self) then
    else
      local hMaria = Handle("Missions\\paris_2\\mission_5b\\maria\\Maria_Connect")
      if hMaria then
        print("New maria is already loaded")
        self:NewMariaLoaded()
      end
    end
  end
  _P2M5b_ONCANCEL = nil
end

function P2M5b:NewMariaLoaded()
  print("new maria loaded")
  self.tInfo.Maria = "Missions\\paris_2\\mission_5b\\maria\\Maria_Connect"
  self:RegisterCheckpoint("P2M5b.Checkpoint1")
end

function P2M5b:Reset()
  HUD.ClearGPSTarget()
end

function P2M5b:Checkpoint1()
  local hMaria = Handle(self.tInfo.Maria)
  Combat.SetLeader(hMaria, hSab, true)
  self:Task_TaxiMaria()
end

function P2M5b:Task_TaxiMaria()
  self:CreateTask({
    sName = "Task_TaxiMaria",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "P2M5b_Text.PickupMaria",
    sVehicleReturnID = "P2M5b_Text.GetBackInCar",
    bGroundBlip = true,
    Proximity = 3,
    bEscalationDenial = true,
    bNoCarRequired = true,
    bWimpy = true,
    tDestLocators = {
      "Missions\\hq_dropoff\\P1HQ\\P1HQ_LC"
    },
    tDestRegion = {
      "Missions\\hq_dropoff\\P1HQ\\P1HQ_PT"
    },
    tDeliverObjs = {
      self.tInfo.Maria
    },
    tPickupProxObj = {
      self.tInfo.Maria
    },
    tSMEDNodes = {},
    tReadyForUnload = {},
    tOnEarlyExit = {},
    tOnPickup = {
      {
        self.SetupEvents,
        {self}
      },
      {
        EVENT_PlayConversationDelayed,
        {
          "P2M5b_Start",
          10,
          self
        }
      },
      {
        Cin.PlayConversation,
        {
          "P2M5b_Taxi_LetsGo"
        }
      }
    },
    tOnComplete = {
      {
        EVENT_Timer,
        {
          "P2M5b.FadeOutFinish",
          self,
          1.5
        }
      }
    },
    tOnActivate = {
      {
        Util.SetOverrideLoadScreenFadeIn,
        {false}
      },
      {
        Render.FadeScreen,
        {false}
      }
    }
  })
end

function P2M5b:CleanupEvents()
  if self.tInfo.eAbanddon then
    Util.KillEvent(self.tInfo.eAbanddon)
    self.tInfo.eAbanddon = nil
  end
  if self.tInfo.eTakingLong then
    Util.KillEvent(self.tInfo.eTakingLong)
    self.tInfo.eTakingLong = nil
  end
end

function P2M5b:SetupEvents()
  self.tInfo.eAbanddon = EVENT_PlayerToActorProximityNegated("P2M5b.AbanddonClose", self, self.tInfo.Maria, 75)
  EVENT_PlayerToActorProximity("P2M5b.NearHQ", self, "Missions\\hq_dropoff\\P1HQ\\P1HQ_LC", 130)
  self.tInfo.eTakingLong = EVENT_Timer("P2M5b.Reminder", self, 500)
  self.tInfo.eCheckVehicle = EVENT_PlayerEntersAnyVehicle("P2M5b.CheckForVehicle", self)
end

function P2M5b:AbanddonClose()
  Cin.PlayConversation("P2M5b_Taxi_Abandoned")
end

function P2M5b:TaxiReturn()
  Cin.PlayConversation("P2M5b_Taxi_Return")
end

function P2M5b:CheckForVehicle()
  Cin.PlayConversation("P2M5b_Taxi_GetInAny")
end

function P2M5b:WaitFor()
  Cin.PlayConversation("P2M5b_Taxi_WaitFor")
end

function P2M5b:Reminder()
  Cin.PlayConversation("P2M5b_Taxi_Reminder")
end

function P2M5b:NearHQ()
  Cin.PlayConversation("P2M5b_Taxi_NearDestruction")
end

function P2M5b:RunMaria()
  Suspicion.ResetEscalation()
  print("run maria run")
  local hLoc = Handle(gsP2M5b .. "main\\LOC_Runto")
  local hMaria = Handle(self.tInfo.Maria)
  Actor.OverrideCombatAI(hMaria, false)
  if hMaria then
    Nav.MoveToObject(hMaria, hLoc, 1.5, true)
  end
end

function P2M5b:FadeOut()
  Render.FadeScreen(false)
  Actor.UnboardVehicle(hSab)
end

function P2M5b:MariaDone()
  print("unload old maria")
  WorldSMEDNodes.UnloadNode("Missions\\paris_2\\mission_5\\exteriormaria", true)
  print("unload new maria")
  WorldSMEDNodes.UnloadNode("Missions\\paris_2\\mission_5b\\maria", true)
  EVENT_Timer("P2M5b.FadeOutFinish", self, 3)
end

function P2M5b:FadeOutFinish()
  Render.FadeScreen(true)
  self:CompleteThisMission()
end
