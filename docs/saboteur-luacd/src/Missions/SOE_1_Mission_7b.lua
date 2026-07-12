if SOE_1_Mission_7b == nil then
  SOE_1_Mission_7b = SabTaskObjective:Create()
  SOE_1_Mission_7b.PATH = "Missions\\soe_1\\mission_7b\\"
  SOE_1_Mission_7b:Configure({
    TaskCount = "auto",
    sSaveMissionNameID = "MissionNames_Text.S1M7",
    bDisableMissionTitle = true,
    sHQStartPoint = _cHQe_AURORA,
    MCDisplayID = 2,
    bStarterless = true,
    tUnlockList = {
      "Paris_2_Mission_5",
      "Note_Bryman1a_FoundMaria"
    },
    tCinematicNodes = {
      "320_cinb_carback"
    },
    tSMEDNodes = {
      SOE_1_Mission_7b.PATH .. "main"
    },
    tStaticTags = {}
  })
end

function SOE_1_Mission_7b:STARTER_Setup()
  if not IsMissionCompleted("SOE_1_Mission_7") then
  end
end

function SOE_1_Mission_7b:Activated()
  SabTaskObjective.Activated(self)
  self.bDebugMode = false
  self.sDebugLabel = "SOE.1.7"
  self.GENERAL_Setup(self)
end

function SOE_1_Mission_7b.SetupGamepadListener()
  local tControllerEvent = {
    EventType = "OnButtonPress",
    Target = Handle("Saboteur")
  }
  local eButtonPress = Util.CreateEvent(tControllerEvent, "SOE_1_Mission_7b.OnButtonPress", nil, {}, true)
  self:RegisterEvent(eButtonPress)
end

function SOE_1_Mission_7b.OnButtonPress(a_NIL, a_tButtonData)
  local tButtons = a_tButtonData[1]
  if tButtons.UP == true then
  elseif tButtons.DOWN == true then
  elseif tButtons.RIGHT == true then
  elseif tButtons.LEFT == true then
  end
end

function SOE_1_Mission_7b:GENERAL_Setup()
  self.sDestRegion = self.PATH .. "main\\PT_DestRegion"
  self.sDestLoc = self.PATH .. "main\\LOC_DestLoc"
  Cin.LoadCinematic("320_CinB_Carback")
  Cin.LoadCinematic("320_CinB_Carback_alt")
  if not _g_SOE_1_Mission_7_Playthrough and Util.IsBlockLoaded("CountrySide\\centre\\chateaudeisenbourg\\aurora.wsd") then
    Util.UnloadEditNode("CountrySide\\centre\\chateaudeisenbourg\\aurora.wsd", true)
  end
  if _g_SOE_1_Mission_7_Playthrough and Util.GetHandleByName("CountrySide\\centre\\chateaudeisenbourg\\aurora\\VH_CV_CR_Aurora_01") then
    self.tInfo.sAurora = "CountrySide\\centre\\chateaudeisenbourg\\aurora\\VH_CV_CR_Aurora_01"
    self.tInfo.bIsWorldAurora = true
    self:RegisterCheckpoint("SOE_1_Mission_7b.Checkpoint1")
  else
    Util.SpawnEditNode(self.PATH .. "starter.wsd", "SOE_1_Mission_7b.SpawnAurora", self)
    self.tInfo.bIsWorldAurora = false
  end
  _g_SOE_1_Mission_7_Playthrough = nil
  self:AddOnCancelCallback(SOE_1_Mission_7b.Reset)
  self:AddOnCompleteCallback(SOE_1_Mission_7b.Reset)
end

function SOE_1_Mission_7b:SpawnAurora()
  self.tInfo.sAurora = "Missions\\soe_1\\mission_7b\\starter\\VH_CV_CR_Aurora_01"
  self:RegisterCheckpoint("SOE_1_Mission_7b.Checkpoint1")
end

function SOE_1_Mission_7b:Checkpoint1()
  self.SetupCarDeath(self)
  Vehicle.SetAsMissionCritical(Handle(self.tInfo.sAurora), true)
  if Suspicion.GetEscalation() ~= 0 then
    self.TASK_ShedEscalation(self)
  else
    self.TASK_DriveToMillHQ(self)
  end
end

function SOE_1_Mission_7b:TASK_DriveToMillHQ()
  self:CreateTask({
    sName = "TASK_DriveToMillHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "DELIVER",
    tDestRegion = self.sDestRegion,
    tDeliverObjs = {
      self.tInfo.sAurora,
      hSab
    },
    tLocators = {
      self.sDestLoc
    },
    sObjectiveTextID = "S1M7b_Text.TASK_DriveToMillHQ",
    bEscalationDenial = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.PickEndCutscene,
        {self}
      },
      {
        self.SlowTheCar,
        {self}
      }
    }
  })
  local tEscEvent = {
    EventType = "OnEscalation1",
    Target = Util.GetHandleByName("Saboteur")
  }
  self.EscEvent = Util.CreateEvent(tEscEvent, "SOE_1_Mission_7b.OnEscalation", self, {})
  self:RegisterEvent(self.EscEvent)
end

function SOE_1_Mission_7b:OnEscalation()
  self:ResetTaskByName("TASK_DriveToMillHQ", true)
  self.TASK_ShedEscalation(self)
end

function SOE_1_Mission_7b:TASK_ShedEscalation()
  self:CreateTask({
    sName = "TASK_ShedEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    tLocators = {
      self.sDestLoc
    },
    bNoGPS = true,
    sTaskSubType = "NONE",
    EscalationLevel = 0,
    tOnComplete = {
      {
        self.TASK_DriveToMillHQ,
        {self}
      },
      {
        self.ResetTaskByName,
        {
          self,
          "TASK_ShedEscalation",
          true
        }
      }
    }
  })
end

function SOE_1_Mission_7b:WaitOnVit()
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForGameObject = true,
    Objects = {
      "Missions\\paris_1\\characters\\belle\\vit_belle_garage\\vittore_garage"
    }
  }, "Paris_6_Mission_1.PickEndCutscene", self))
end

function SOE_1_Mission_7b:PickEndCutscene()
  Actor.HolsterWeaponImmediate(hSab)
  if self.tInfo.bIsWorldAurora then
    SOE_1_Mission_7b.PlayProgressCin(self)
  else
    SOE_1_Mission_7b.PlayLoadedConnectCin(self)
  end
end

function SOE_1_Mission_7b:PlayProgressCin()
  self:CreateTask({
    sName = "Task_EndCutscene",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "320_CinB_CarBack",
    tDeleteNodes = {
      "Missions\\soe_1\\mission_7b\\ClearGarage"
    },
    tOnActivate = {
      {
        self.UnboardVeh,
        {self}
      }
    },
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end

function SOE_1_Mission_7b:UnboardVeh()
  Actor.UnboardVehicle(hSab)
end

function SOE_1_Mission_7b:PlayLoadedConnectCin()
  self:CreateTask({
    sName = "Task_EndCutscene",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "320_CinB_CarBack_alt",
    tDeleteNodes = {
      "Missions\\soe_1\\mission_7b\\ClearGarage"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end

function SOE_1_Mission_7b:SetupCarDeath()
  EVENT_ActorDeath("SOE_1_Mission_7b.CarDeath", self, Util.GetHandleByName(self.tInfo.sAurora))
end

function SOE_1_Mission_7b:CarDeath()
  Cin.PlayConversation("S1M7_Aurora_Destroyed", "SOE_1_Mission_7b.NowFailz", self)
end

function SOE_1_Mission_7b:NowFailz()
  self:MissionTaskFail("S1M7b_Text.Fail_LostAurora")
end

function SOE_1_Mission_7b:SlowTheCar()
  Vehicle.BrakeTo(Handle(self.tInfo.sAurora), 1)
end

function SOE_1_Mission_7b:UnloadWorldAurora()
  self = SOE_1_Mission_7b
  local hAurora = Handle(self.tInfo.sAurora)
  if hAurora then
    Vehicle.SetAsMissionCritical(hAurora, false)
  end
  if self.tInfo.bIsWorldAurora then
    if Handle("CountrySide\\centre\\chateaudeisenbourg\\aurora\\VH_CV_CR_Aurora_01") then
      Util.UnloadEditNode("CountrySide\\centre\\chateaudeisenbourg\\aurora.wsd", true, false)
    end
  elseif Handle("Missions\\soe_1\\mission_7b\\starter\\VH_CV_CR_Aurora_01") then
    Util.UnloadEditNode("Missions\\soe_1\\mission_7b\\starter.wsd", true, false)
  end
end

function SOE_1_Mission_7b:Reset()
  Sound.ResetMusicLocale()
  local hAurora = Handle(self.tInfo.sAurora)
  if hAurora then
    Vehicle.SetAsMissionCritical(hAurora, false)
  end
  Cin.StopCinematic("320_CinB_Carback")
  Cin.StopCinematic("320_CinB_Carback_alt")
end
