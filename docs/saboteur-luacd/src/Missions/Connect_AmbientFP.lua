if Connect_AmbientFP == nil then
  Connect_AmbientFP = SabTaskObjective:Create()
  Connect_AmbientFP.PATH = "Missions\\freeplay\\p1\\connect_ambient_fp\\"
  Connect_AmbientFP:Configure({
    TaskCount = 999,
    sStarter = "santos_ext_hideout",
    sConvFile = "Connect_AmbientFP_Shops",
    bFreeplay = true,
    sStarterAttrPt = "MissionStarterAttrPtSantos",
    tUnlockList = {
      "P1FP_Carbomb"
    },
    sSaveMissionNameID = "MissionNames_Text.Connect_AmbientFP",
    tSMEDNodes = {
      Connect_AmbientFP.PATH .. "main"
    },
    tStaticTags = {}
  })
end

function Connect_AmbientFP:STARTER_Setup()
end

function Connect_AmbientFP:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "CONNECT_AMBIENTFP"
  self.bDebugMode = false
  AmbientRubberStamp.UnlockAmbientFPMissionNodes()
  self.GENERAL_Setup(self)
  self.SetupCheckpoint(self, 0)
end

function Connect_AmbientFP:GENERAL_Setup()
  self:AddOnCompleteCallback(Connect_AmbientFP.Complete)
  Freeplay.BlockZoneForSave("P1S", true)
end

function Connect_AmbientFP:InitShopkeeper()
  self:CallbackListener()
  local hShopKeeper = Handle("Missions\\freeplay\\shopkeepers\\p1a\\ShopKeeper_Smoke_A(0)\\Spore_RS_Shopkeeper_Paris(0)")
  if hShopKeeper then
    Actor.SetMissionCriticalNPC(hShopKeeper, true)
  end
  self.eShopStreamOut = Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForStreamOut = true,
    Objects = {
      "Missions\\freeplay\\shopkeepers\\p1a\\ShopKeeper_Smoke_A(0)\\Spore_RS_Shopkeeper_Paris(0)"
    }
  }, "Connect_AmbientFP.ShopStreamOut", self)
  self:RegisterEvent(self.eShopStreamOut)
end

function Connect_AmbientFP:ShopStreamOut()
  EVENT_Stream("Connect_AmbientFP.InitShopkeeper", self, "Missions\\freeplay\\shopkeepers\\p1a\\ShopKeeper_Smoke_A(0)\\Spore_RS_Shopkeeper_Paris(0)", false)
end

function Connect_AmbientFP:SetupVariables()
  self.sTower = self.sTower or "Missions\\freeplay\\ambient\\p1\\p1_tower_shop\\FP_AMB_Tower_Short\\Target"
  self.sGeneral = self.sGeneral or "Missions\\freeplay\\ambient\\p1\\p1_general_shop\\FP_AMB_General\\Target"
  self.sArmoredCar = self.sArmoredCar or "Missions\\freeplay\\ambient\\p1\\p1_armoredcar_shop\\FP_AMB_ArmoredCar\\Target"
end

function Connect_AmbientFP:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "Connect_AmbientFP.DoCheckpoint")
end

function Connect_AmbientFP:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  self.SetupVariables(self)
  if nCP == 0 then
    EVENT_Stream("Connect_AmbientFP.InitShopkeeper", self, "Missions\\freeplay\\shopkeepers\\p1a\\ShopKeeper_Smoke_A(0)\\Spore_RS_Shopkeeper_Paris(0)", false)
    self.tInfo.ContactTotalDamage = 0
    self.Task_GoToShop(self)
    Util.SetShopEnable(true)
    Util.LoadStaticENTag("000_SHOP_SANTOS", true)
  elseif nCP == 1 then
    if Object.IsAlive(Handle(self.sTower)) then
      self.Task_FirstObjective(self)
    elseif Object.IsAlive(Handle(self.sGeneral)) then
      self.TASK_SecondTitle(self)
      self.Task_SecondObjective(self)
    elseif Object.IsAlive(Handle(self.sArmoredCar)) then
      self:CompleteTaskByName("TASK_SecondTitle")
      self.TASK_ThirdTitle(self)
      self.Task_ThirdObjective(self)
    else
      self:CompleteTaskByName("TASK_ThirdTitle")
      if 0 < Suspicion.GetEscalation() then
        self:TASK_LoseEscalation()
      else
        self:Task_ReturnToSantos()
      end
    end
  elseif nCP == 2 then
    if Object.IsAlive(Handle(self.sGeneral)) then
      self.TASK_SecondTitle(self)
      self.Task_SecondObjective(self)
    elseif Object.IsAlive(Handle(self.sArmoredCar)) then
      self:CompleteTaskByName("TASK_SecondTitle")
      self.TASK_ThirdTitle(self)
      self.Task_ThirdObjective(self)
    else
      self:CompleteTaskByName("TASK_ThirdTitle")
      if 0 < Suspicion.GetEscalation() then
        self:TASK_LoseEscalation()
      else
        self:Task_ReturnToSantos()
      end
    end
  elseif nCP == 3 then
    Util.KillEvent(self.eGeneralOut)
    Util.KillEvent(self.eGeneralIn)
    if Object.IsAlive(Handle(self.sArmoredCar)) then
      self:CompleteTaskByName("TASK_SecondTitle")
      self.TASK_ThirdTitle(self)
      self.Task_ThirdObjective(self)
    else
      self:CompleteTaskByName("TASK_ThirdTitle")
      if 0 < Suspicion.GetEscalation() then
        self:TASK_LoseEscalation()
      else
        self:Task_ReturnToSantos()
      end
    end
  elseif nCP == 4 then
    self:CompleteTaskByName("TASK_ThirdTitle")
    Util.KillEvent(self.eAPCOut)
    Util.KillEvent(self.eAPCIn)
    if 0 < Suspicion.GetEscalation() then
      self:TASK_LoseEscalation()
    else
      self:Task_ReturnToSantos()
    end
  end
end

function Connect_AmbientFP:Task_GoToShop()
  self:CreateTask({
    sName = "Connect_AmbientFP.Task_GoToShop",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "NONE",
    sObjectiveTextID = "Connect_AmbientFP_Text.Task_GoToShop",
    tLocators = {
      "Missions\\freeplay\\p1\\connect_ambient_fp\\main\\LOC_Shopkeeper"
    },
    tSMEDNodes = {},
    tOnActivate = {},
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 1}
      }
    }
  })
end

function Connect_AmbientFP:RunSpecialCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  local hLoc = Handle("Missions\\freeplay\\p1\\connect_ambient_fp\\main\\LOC_TowerRestart")
  self.RegisterCheckpoint(self, "Connect_AmbientFP.DoCheckpoint", nil, false, hLoc)
end

function Connect_AmbientFP:CallbackListener()
  if self.ShopExitEvent then
    Util.KillEvent(self.ShopExitEvent)
  end
  tCallbackEvent = {
    EventType = "OnShopExit",
    EventName = "ShopExit",
    Target = Handle("Missions\\freeplay\\shopkeepers\\p1a\\ShopKeeper_Smoke_A(0)\\Spore_RS_Shopkeeper_Paris(0)")
  }
  self.ShopExitEvent = Util.CreateEvent(tCallbackEvent, "Connect_AmbientFP.CompleteShopTask", self)
  self:RegisterEvent(self.ShopExitEvent)
end

function Connect_AmbientFP:CompleteShopTask()
  self:CompleteTaskByName("Connect_AmbientFP.Task_GoToShop")
end

function Connect_AmbientFP:Task_FirstObjective()
  self:CreateTask({
    sName = "Connect_AmbientFP.Task_FirstObjective",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "Connect_AmbientFP_Text.Task_FirstObjective",
    bObjCounter = true,
    bNoGPS = true,
    ParentObjectID = -1,
    MarkerHeight = 2,
    tTgtInclude = {
      self.sTower
    },
    bBlipLocatorsOnly = true,
    tLocators = {
      self.PATH .. "main\\LOC_Tower"
    },
    tOnActivate = {
      {
        self.SetupSabotageTip,
        {self}
      },
      {
        self.DisableMissionCritical,
        {self}
      }
    },
    tOnComplete = {
      {
        self.RunSpecialCheckpoint,
        {self, 2}
      }
    }
  })
end

function Connect_AmbientFP:DisableMissionCritical()
  local hShopKeeper = Handle("Missions\\freeplay\\shopkeepers\\p1a\\ShopKeeper_Smoke_A(0)\\Spore_RS_Shopkeeper_Paris(0)")
  if hShopKeeper then
    Actor.SetMissionCriticalNPC(hShopKeeper, false)
  end
end

function Connect_AmbientFP:SetupSabotageTip()
  EVENT_PlayerToActorProximity("Connect_AmbientFP.SabotageTip", self, "Missions\\freeplay\\p1\\connect_ambient_fp\\main\\LOC_Tower", 3)
end

function Connect_AmbientFP:SabotageTip()
  Util.QueueTutorial("TutorialTip_Text.Sabotage_Inventory_Title", "TutorialTip_Text.Sabotage_Inventory", -1, true)
  Util.EnableTutorial("TutorialTip_Text.Sabotage_Dynamite", true, -1, true)
end

function Connect_AmbientFP:TASK_SecondTitle()
  self:CreateTask({
    sName = "TASK_SecondTitle",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    sObjectiveTextID = "Connect_AmbientFP_Text.Task_SecondObjective",
    tOnActivate = {}
  })
end

function Connect_AmbientFP:Task_SecondObjective()
  self:CreateTask({
    sName = "Connect_AmbientFP.Task_SecondObjective",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    bObjCounter = true,
    bNoGPS = true,
    ParentObjectID = -1,
    MarkerHeight = 2,
    tTgtInclude = {
      self.sGeneral
    },
    tOnActivate = {
      {
        self.GeneralStreamsOutEvent,
        {self}
      },
      {
        self.TASK_SecondTitle,
        {self}
      }
    },
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 3}
      }
    }
  })
end

function Connect_AmbientFP:GeneralStreamsOutEvent()
  self.eGeneralOut = EVENT_StreamOut("Connect_AmbientFP.GeneralStreamsOut", self, self.sGeneral)
end

function Connect_AmbientFP:GeneralStreamsOut()
  self:ResetTaskByName("Connect_AmbientFP.Task_SecondObjective", true)
  self.Task_ReturnToMission2(self)
end

function Connect_AmbientFP:GeneralStreamsIn()
  self:ResetTaskByName("Connect_AmbientFP.Task_ReturnToMission2", true)
  self.Task_SecondObjective(self)
end

function Connect_AmbientFP:Task_ReturnToMission2()
  self:CreateTask({
    sName = "Connect_AmbientFP.Task_ReturnToMission2",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "DELIVER",
    Proximity = 10,
    tDestProximityObj = {
      self.PATH .. "main\\LOC_General"
    },
    tDeliverObjs = {hSab},
    bNoGPS = true,
    tOnActivate = {
      {
        self.GeneralStreamsInEvent,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Connect_AmbientFP:GeneralStreamsInEvent()
  self.eGeneralIn = EVENT_Stream("Connect_AmbientFP.GeneralStreamsIn", self, self.sGeneral)
end

function Connect_AmbientFP:TASK_ThirdTitle()
  self:CreateTask({
    sName = "TASK_ThirdTitle",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    sObjectiveTextID = "Connect_AmbientFP_Text.Task_ThirdObjective",
    tOnActivate = {}
  })
end

function Connect_AmbientFP:Task_ThirdObjective()
  self:CreateTask({
    sName = "Connect_AmbientFP.Task_ThirdObjective",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    bObjCounter = true,
    bNoGPS = true,
    ParentObjectID = -1,
    MarkerHeight = 3.5,
    tTgtInclude = {
      self.sArmoredCar
    },
    tOnActivate = {
      {
        self.SetupSabotageTip2,
        {self}
      },
      {
        self.APCStreamsOutEvent,
        {self}
      },
      {
        self.TASK_ThirdTitle,
        {self}
      }
    },
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 4}
      }
    }
  })
end

function Connect_AmbientFP:APCStreamsOutEvent()
  self.eAPCOut = EVENT_StreamOut("Connect_AmbientFP.APCStreamsOut", self, self.sArmoredCar)
end

function Connect_AmbientFP:SetupSabotageTip2()
  EVENT_PlayerToActorProximity("Connect_AmbientFP.SabotageTip2", self, "Missions\\freeplay\\ambient\\p1\\p1_armoredcar_shop\\FP_AMB_ArmoredCar\\Target", 3)
end

function Connect_AmbientFP:SabotageTip2()
  Util.QueueTutorial("TutorialTip_Text.Sabotage_Inventory_Title", "TutorialTip_Text.Sabotage_Inventory", -1, true)
  Util.EnableTutorial("TutorialTip_Text.Sabotage_Dynamite", true, -1, true)
end

function Connect_AmbientFP:APCStreamsOut()
  self:ResetTaskByName("Connect_AmbientFP.Task_ThirdObjective", true)
  self.Task_ReturnToMission3(self)
end

function Connect_AmbientFP:APCStreamsIn()
  self:ResetTaskByName("Connect_AmbientFP.Task_ReturnToMission3", true)
  self.Task_ThirdObjective(self)
end

function Connect_AmbientFP:Task_ReturnToMission3()
  self:CreateTask({
    sName = "Connect_AmbientFP.Task_ReturnToMission3",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "DELIVER",
    Proximity = 10,
    tDestProximityObj = {
      self.PATH .. "main\\LOC_APC"
    },
    tDeliverObjs = {hSab},
    bNoGPS = true,
    tOnActivate = {
      {
        self.APCStreamsInEvent,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Connect_AmbientFP:APCStreamsInEvent()
  self.eAPCIn = EVENT_Stream("Connect_AmbientFP.APCStreamsIn", self, self.sArmoredCar, true)
end

function Connect_AmbientFP:Checkpoint3()
  dprint(self, "Registered: CHECKPOINT 3")
  if Suspicion.GetEscalation() > 0 then
    self:TASK_LoseEscalation()
  else
    self:Task_ReturnToSantos()
  end
end

function Connect_AmbientFP:TASK_LoseEscalation()
  self:CreateTask({
    sName = "Connect_AmbientFP.TASK_LoseEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    EscalationLevel = 0,
    bRepeatable = true,
    bNoRepeatAutoRebuild = true,
    tOnActivate = {
      {
        self.EscalationListener,
        {self}
      }
    },
    tOnComplete = {
      {
        self.KillEscEvent,
        {self}
      }
    }
  })
end

function Connect_AmbientFP:KillEscEvent()
  if self.eEscDetect then
    Util.KillEvent(self.eEscDetect)
  end
  self:Task_ReturnToSantos()
end

function Connect_AmbientFP:EscalationListener()
  dprint(self, "Setting Escalation Listener  - clear Esc to get Fade Up/Down")
  self.eEscDetect = EVENT_OnEscalation("Connect_AmbientFP.EscSwitchTasks", self, nil, false)
end

function Connect_AmbientFP:EscSwitchTasks()
  dprint(self, "Escalated. Switching to LOSE HEAT task")
  self:ResetTaskByName("Connect_AmbientFP.Task_ReturnToSantos", true)
  self:TASK_LoseEscalation()
end

function Connect_AmbientFP:Task_ReturnToSantos()
  self:CreateTask({
    sName = "Connect_AmbientFP.Task_ReturnToSantos",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Talk",
    sObjectiveTextID = "Connect_AmbientFP_Text.Task_ReturnToSantos",
    tTgtInclude = {
      "Missions\\paris_1\\characters\\belle\\santos_hideout\\santos_ext_hideout"
    },
    vGPSTarget = "Missions\\freeplay\\p1\\connect_ambient_fp\\main\\LOC_ReturnToSantos",
    sConvFile = "Connect_PaySantos_HasMoney",
    sStarterAttrPt = "MissionStarterAttrPtSantos",
    tOnActivate = {
      {
        self.EscalationListener,
        {self}
      }
    },
    tOnConversationComplete = {
      {
        EVENT_Timer,
        {
          "Connect_AmbientFP.PlayAmbTut",
          self,
          2
        }
      }
    }
  })
end

function Connect_AmbientFP:MissionSound()
  Sound.SetMusicLocale("P1M1b_LaVilletteLiberate")
  Sound.SetMusicLocale("m_P1M1b_LaVilletteLiberate", "tutorial")
end

function Connect_AmbientFP:PlayAmbTut()
  self:MissionSound()
  Actor.SetLabel(hSab, "AmbientTut", true)
  HUD.SetTemplate(cHTM_Tutorial_Ambient)
  EVENT_Timer("Connect_AmbientFP.DelayComplete", self, 0.5)
end

function Connect_AmbientFP:DelayComplete()
  self.CompleteThisMission(self)
end

function Connect_AmbientFP:Fadein()
end

function Connect_AmbientFP:FailShopkeeperDied()
  self:MissionTaskFail("Connect_AmbientFP_Text.Fail_KilledShopkeep")
end

function Connect_AmbientFP:Reset()
  Sound.ResetMusicLocale()
  Util.SetShopEnable(false)
  Util.UnloadStaticENTag("000_SHOP_SANTOS", true)
  AmbientRubberStamp.RemoveAmbientFPCountsFromTotals()
  AmbientRubberStamp.UnloadMissionNodes("P1S")
  Freeplay.BlockZoneForSave("P1S", false)
end

function Connect_AmbientFP:MISSION_ONCANCEL()
  Sound.ResetMusicLocale()
  Util.SetShopEnable(false)
  Util.UnloadStaticENTag("000_SHOP_SANTOS", true)
  AmbientRubberStamp.RemoveAmbientFPCountsFromTotals()
  AmbientRubberStamp.UnloadMissionNodes("P1S")
  Freeplay.BlockZoneForSave("P1S", false)
end

function Connect_AmbientFP:Complete()
  Sound.ResetMusicLocale()
  Util.SetShopEnable(true)
  Freeplay.BlockZoneForSave("P1S", false)
end
