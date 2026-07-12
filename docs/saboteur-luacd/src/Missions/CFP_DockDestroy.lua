if CFP_DockDestroy == nil then
  CFP_DockDestroy = SabTaskObjective:Create()
  CFP_DockDestroy.sPATH = "Missions\\freeplay\\country\\mis_dockdestruction\\"
  CFP_DockDestroy:Configure({
    TaskCount = 99,
    bFreeplay = true,
    sStarter = "wilcox_lehavre_interior",
    sConvFile = "CFP_DockDestroy_Start",
    sSaveMissionNameID = "MissionNames_Text.CFP_DockDestroy",
    tUnlockList = {
      "CFP_KoenigDestroy"
    },
    WTFZoneHigh = "WtF_Zones\\global\\FP_LeHavre",
    sToolTipID = "The Nazis have brought one of their U-boats into the docks at Le Havre. You need to set up a bomb near the sub to sink it in to the harbor, and make sure you're not seen.",
    tSMEDNodes = {
      CFP_DockDestroy.sPATH .. "main"
    },
    tStaticTags = {
      "cfp_dockdestroy_hoes",
      "cfp_dockdestroy_explosives"
    }
  })
end

function CFP_DockDestroy:STARTER_Setup()
  Zone.Enable("WtF_Zones\\global\\FP_LeHavre", true, cENT_IMMEDIATE)
end

function CFP_DockDestroy:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "DOCKDESTRUCTION"
  self.bDebugMode = false
  Suspicion.SetEscalationCap(2)
  self.GENERAL_Setup(self)
  self:RegisterCheckpoint("CFP_DockDestroy.Checkpoint1")
end

function CFP_DockDestroy.SetupGamepadListener()
  local self = CFP_DockDestroy
  self.tControllerEvent = {
    EventType = "OnButtonPress",
    Target = Handle("Saboteur")
  }
  local eButtonEvent = Util.CreateEvent(self.tControllerEvent, "CFP_DockDestroy.OnButtonPress", self, {}, true)
  self:RegisterEvent(eButtonEvent)
end

function CFP_DockDestroy:OnButtonPress(a_tButtonData)
  local self = CFP_DockDestroy
  local tButtons = a_tButtonData[1]
  if tButtons.UP == true then
    dprint(self, "-===testing====---")
  elseif tButtons.DOWN == true then
  elseif tButtons.X == true then
  elseif tButtons.B == true then
    Render.PrintMessage("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
    local hSub = Handle("Missions\\freeplay\\country\\mis_dockdestruction\\targets\\Submarine")
    dprint(self, "SUBMARINE HEALTH = " .. Object.GetHealth(hSub))
    Render.PrintMessage("SUBMARINE HEALTH = " .. Object.GetHealth(hSub))
  end
end

function CFP_DockDestroy:GENERAL_Setup()
  self.hSab = Handle("Saboteur")
  self.sLHSniper1 = self.sPATH .. "targets\\Lighthouse1_Grunt_RF"
  self.sLHSniper2 = self.sPATH .. "targets\\Lighthouse2_Grunt_RF"
  self.sSub = self.sPATH .. "targets\\Submarine"
  self.hSub = Handle(self.sSub)
  self.sBombLoc = self.sPATH .. "main\\LOC_PlantLoc"
  self.sBombArea = self.sPATH .. "main\\TRIG_PlantArea"
  self.sDockLoc = self.sPATH .. "main\\LOC_DockLoc"
  self.sDockArea = self.sPATH .. "main\\TRIG_DockArea"
end

function CFP_DockDestroy:SeeLighthouse()
  Cin.PlayConversation("CFP_DockDestroy_LighthouseSnipers")
end

function CFP_DockDestroy:Checkpoint1()
  self.Task_FindDocks(self)
  self.Task_ExitHQ(self)
end

function CFP_DockDestroy:Task_ExitHQ()
  self:CreateTask({
    sName = "CFP_DockDestroy.Task_ExitHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "LeHavre",
    bInteriorTask = true,
    bNoGPS = true,
    MarkerHeight = 2.5,
    tLocators = {},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "CFP_DockDestroy.Checkpoint2"
        }
      }
    }
  })
end

function CFP_DockDestroy:Checkpoint2()
  dprint(self, "Registered: CHECKPOINT 2")
  if not self:IsMissionTaskActive("CFP_DockDestroy.Task_FindDocks") then
    self.Task_FindDocks(self)
  end
end

function CFP_DockDestroy:Task_FindDocks()
  self:CreateTask({
    sName = "CFP_DockDestroy_Task_FindDocks",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "CFP_DockDestroy_Text.Task_FindDocks",
    tLocators = {
      self.sDockLoc
    },
    tDestRegion = {
      self.sDockArea
    },
    tDeliverObjs = {
      self.hSab
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_PanoramaCin,
        {self}
      },
      {
        self.SetupScene,
        {self}
      }
    }
  })
end

function CFP_DockDestroy:Task_PanoramaCin()
  self:CreateTask({
    sName = "Task_PanoramaCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "CIN_CFP_DockDestroy_Intro",
    sTaskStartConv = "CFP_DockDestroy_FeetWet",
    sTaskEndConv = "CFP_DockDestroy_LighthouseSnipers",
    tSMEDNodes = {},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_DestroySub,
        {self}
      }
    }
  })
end

function CFP_DockDestroy:Task_DestroySub()
  self:CreateTask({
    sName = "Task_DestroySub",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "CFP_DockDestroy_Text.Task_DestroySub",
    tTgtInclude = {
      self.sSub
    },
    sTaskEndConv = "CFP_DockDestroy_Complete",
    tOnActivate = {
      {
        self.SetupSabotageCheck,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TASK_EscapeTheRetribution,
        {self}
      }
    }
  })
end

function CFP_DockDestroy:TASK_EscapeTheRetribution()
  self:CreateTask({
    sName = "CFP_DockDestroy.TASK_EscapeTheRetribution",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    EscalationLevel = 0,
    tOnComplete = {
      {
        Suspicion.SetEscalationCap,
        {-1}
      },
      {
        self.CompleteThisMission,
        {self}
      }
    },
    tOnActivate = {
      {
        Suspicion.SetEscalationLevel,
        {2}
      }
    }
  })
end

function CFP_DockDestroy:SetupSabotageCheck()
  local tEscalationEvent = {
    EventType = "OnEscalation1",
    Target = self.hSab
  }
  local eEscSetup = Util.CreateEvent(tEscalationEvent, "CFP_DockDestroy.EscalationSetup", self)
  self:RegisterEvent(eEscSetup)
end

function CFP_DockDestroy:EscalationSetup()
  local tempself = Actor.GetSelf(Util.GetHandleByName("Missions\\freeplay\\country\\mis_dockdestruction\\wtf_low\\TriggerSpawner\\HumanSpawner2"))
  HumanSpawner.ActivateALL(tempself)
  local tempself2 = Actor.GetSelf(Util.GetHandleByName("Missions\\freeplay\\country\\mis_dockdestruction\\wtf_low\\TriggerSpawner(2)\\HumanSpawner2"))
  HumanSpawner.ActivateALL(tempself2)
end

function CFP_DockDestroy:ClearMarkers()
  HUD.RemoveObjectiveMarker(Handle(self.sBombLoc))
end

function CFP_DockDestroy:FailMission()
  self:MissionTaskFail()
  Render.PrintMessage("FAILED MISSION")
end

function CFP_DockDestroy:SetupScene()
  Actor.PlayAnimation(Handle("Missions\\freeplay\\country\\mis_dockdestruction\\hoes\\CV_Prostitute_01"), "shrd_dorris_stand_sexy")
  Actor.PlayAnimation(Handle("Missions\\freeplay\\country\\mis_dockdestruction\\hoes\\CV_Prostitute_02"), "shrd_dorris_stand_sexy2")
  Actor.PlayAnimation(Handle("Missions\\freeplay\\country\\mis_dockdestruction\\hoes\\CV_Prostitute_03"), "shrd_dorris_stand_sexy3")
  Actor.PlayAnimation(Handle("Missions\\freeplay\\country\\mis_dockdestruction\\hoes\\CV_Prostitute_04"), "shrd_dorris_stand_sexy")
  Actor.PlayAnimation(Handle("Missions\\freeplay\\country\\mis_dockdestruction\\hoes\\CV_Prostitute_05"), "shrd_dorris_stand_sexy2")
  Actor.PlayAnimation(Handle("Missions\\freeplay\\country\\mis_dockdestruction\\hoes\\CV_Prostitute_06"), "shrd_dorris_stand_sexy3")
end
