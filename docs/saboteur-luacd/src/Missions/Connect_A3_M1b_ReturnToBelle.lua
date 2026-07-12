if Connect_A3_M1b_ReturnToBelle == nil then
  Connect_A3_M1b_ReturnToBelle = SabTaskObjective:Create()
  Connect_A3_M1b_ReturnToBelle.PATH = "Missions\\Act_3\\Mission_1\\"
  Connect_A3_M1b_ReturnToBelle:Configure({
    TaskCount = "auto",
    bStarterless = true,
    MCDisplayID = 2,
    sSaveMissionNameID = "MissionNames_Text.A3M1",
    bDisableMissionTitle = true,
    sHQStartPoint = _cHQe_BELLERETURN,
    sHQNextMissionStartPoint = _cHQ_BELLEP3M1,
    bSLOverrideFade = true,
    tUnlockList = {
      "Paris_3_Mission_1"
    },
    tSMEDNodes = {
      Connect_A3_M1b_ReturnToBelle.PATH .. "connect"
    },
    tStaticTags = {
      "GRANDPRIX_Damage",
      "GrandPrix",
      "GrandPrix_B"
    }
  })
end

function Connect_A3_M1b_ReturnToBelle:STARTER_Setup()
  Suspicion.SetEscalationLevel(4)
  Vehicle.EnableTraffic(false)
  Util.EnableRoadsInRegion(false, Util.GetHandleByName("Hacks\\Missions\\act_3\\mission_1\\connect\\PT_RoadBlock"))
end

function Connect_A3_M1b_ReturnToBelle:Activated()
  SabTaskObjective.Activated(self)
  Util.EnableRoadsInRegion(false, Util.GetHandleByName("Missions\\act_3\\mission_1\\connect\\PT_RoadBlock"))
  self.GENERAL_Setup(self)
  self:RegisterCheckpoint("Connect_A3_M1b_ReturnToBelle.Checkpoint1")
  Sound.SetMusicLocale("A3M1b_ReturnToBelle")
  Sound.SetMusicLocale("m_A3M1b_ReturnToBelle", "Drive")
  Vehicle.EnableTraffic(true)
  Util.SetOverrideLoadScreenFadeIn(false)
  Render.FadeScreen(false)
end

function Connect_A3_M1b_ReturnToBelle:GENERAL_Setup()
  self.sMasterObjective = "A3M1b_Text.ToBelle"
  self.sDestinationLocator = Connect_A3_M1b_ReturnToBelle.PATH .. "connect\\LOC_DaBelle"
  self.sDropOffTrigger = Connect_A3_M1b_ReturnToBelle.PATH .. "connect\\PT_DaBelle"
end

function Connect_A3_M1b_ReturnToBelle:Checkpoint1()
  Util.EnableSuperSpores(false)
  Zone.Enable("WtF_Zones\\global\\Belle_Low", true, cENT_IMMEDIATE)
  Zone.SwitchState("WtF_Zones\\global\\Belle_Low", cZONESTATE_LOWWTF, cENT_IMMEDIATE)
  self.bLostEscalationOnce = false
  Actor.SetDisguise(hSab, "FBS_RS_Sean_Race_Race_NoHat_Bag")
  self:StartConv()
  self:TASK_Escalator()
  Util.UnloadStaticENTag("GrandPrix", false, true)
  Util.UnloadStaticENTag("GrandPrix_B", false, true)
end

function Connect_A3_M1b_ReturnToBelle:GoBoom(a_sSquib)
  Object.Kill(a_sSquib)
end

function Connect_A3_M1b_ReturnToBelle:TASK_ReturnToBelle()
  self:CreateTask({
    sName = "TASK_ReturnToBelle",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "EnterInterior",
    sObjectiveTextID = "A3M1b_Text.ToBelle",
    sInteriorName = "Belle_Destroyed",
    tLocators = {
      self.sDestinationLocator
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_PlayFinishCin,
        {self}
      },
      {
        self.LoadLowWTFThings,
        {self}
      }
    },
    tOnActivate = {
      {
        HUD.SetGPSTarget,
        {
          Util.GetHandleByName(self.sDestinationLocator)
        }
      }
    }
  })
end

function Connect_A3_M1b_ReturnToBelle:TASK_Escalator()
  self:CreateTask({
    sName = "TASK_Escalator",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = true,
    tOnComplete = {
      {
        self.OnEscalation,
        {self}
      },
      {
        self.TASK_LostEscalation,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Connect_A3_M1b_ReturnToBelle:TASK_LostEscalation()
  self:CreateTask({
    sName = "TASK_LostEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 0,
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    tOnComplete = {
      {
        self.OnEscalationClear,
        {self}
      },
      {
        self.ResetTaskByName,
        {
          self,
          "TASK_LostEscalation",
          true
        }
      },
      {
        self.ResetTaskByName,
        {
          self,
          "TASK_Escalator"
        }
      }
    },
    tOnActivate = {}
  })
end

function Connect_A3_M1b_ReturnToBelle:OnEscalation()
  if self:IsMissionTaskActive("TASK_ReturnToBelle") then
    self:KillTaskByName("TASK_ReturnToBelle")
    self:TASK_LostEscalation()
  end
end

function Connect_A3_M1b_ReturnToBelle:OnEscalationClear()
  if self.bLostEscalationOnce == false then
    self.bLostEscalationOnce = true
    self:TASK_ReturnToBelle()
  else
    self.ResetTaskByName(self, "TASK_ReturnToBelle")
  end
end

function Connect_A3_M1b_ReturnToBelle:Task_PlayFinishCin()
  self:CreateTask({
    sName = "Task_PlayFinishCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "335_CinA_Betrayed",
    tCinematicNodes = {
      "335_cina_betrayed"
    },
    bOverrideFade = true,
    tStaticTags = {},
    tOnActivate = {
      {
        Util.LoadStaticENTag,
        {
          "belle_ext_closed",
          true
        }
      }
    },
    tOnComplete = {
      {
        RewardsManager.UnloadColby,
        {
          "PristineBelle",
          true
        }
      },
      {
        self.Task_ExitBelle,
        {self}
      },
      {
        InteriorManager.ExitInterior,
        {
          "Belle_Destroyed",
          "PARIS\\area01\\belledenuit\\interior\\hq_ext\\LOC_Teleport_Ext",
          false
        }
      }
    }
  })
end

function Connect_A3_M1b_ReturnToBelle:Task_ExitBelle()
  self:CreateTask({
    sName = "Task_ExitBelle",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "Belle_Destroyed",
    bInteriorTask = true,
    bOverrideFade = true,
    tOnComplete = {
      {
        self.Cleanup,
        {self}
      },
      {
        self.CompleteThisMission,
        {self}
      },
      {
        Sound.ResetMusicLocale()
      }
    }
  })
end

function Connect_A3_M1b_ReturnToBelle:LoadLowWTFThings()
  Zone.SwitchState("WtF_Zones\\global\\Belle_Low", cZONESTATE_LOWWTF, cENT_IMMEDIATE, true)
  Zone.SwitchState("WtF_Zones\\global\\P1M1_FuelDepot", cZONESTATE_LOWWTF, cENT_IMMEDIATE, false)
  Util.EnableRoadsInRegion(true, Util.GetHandleByName("Missions\\act_3\\mission_1\\connect\\PT_RoadBlock"))
  Util.EnableRoadsInRegion(true, Util.GetHandleByName("Hacks\\Missions\\act_3\\mission_1\\connect\\PT_RoadBlock"))
end

function Connect_A3_M1b_ReturnToBelle:StartConv()
  Cin.PlayConversation("A3M1b_Start")
  EVENT_PlayerEntersTrigger("Connect_A3_M1b_ReturnToBelle.Close2Belle", self, "Missions\\act_3\\mission_1\\connect\\PT_NearBelle", false)
  EVENT_PlayerExitsTrigger("Connect_A3_M1b_ReturnToBelle.ReSpore", self, "Missions\\act_3\\mission_1\\connect\\PT_LeftTower")
end

function Connect_A3_M1b_ReturnToBelle:Close2Belle()
  Cin.PlayConversation("A3M1b_NearBelle")
  self:DoorStreamIn()
end

function Connect_A3_M1b_ReturnToBelle:ReSpore()
  Util.EnableSuperSpores(true)
end

function Connect_A3_M1b_ReturnToBelle:DoorStreamIn()
  local e = Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForGameObject = true,
    Objects = {
      "PARIS\\area01\\belledenuit\\interior\\hq_ext\\Belle_ext_teleport_two"
    }
  }, "Connect_A3_M1b_ReturnToBelle.DoorLock", self)
  self:RegisterEvent(e)
end

function Connect_A3_M1b_ReturnToBelle:DoorLock()
  AttractionPt.EnableUse(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\hq_ext\\Belle_ext_teleport_two"), false)
  local e = Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForStreamOut = true,
    Objects = {
      "PARIS\\area01\\belledenuit\\interior\\hq_ext\\Belle_ext_teleport_two"
    }
  }, "Connect_A3_M1b_ReturnToBelle.DoorStreamIn", self)
  self:RegisterEvent(e)
end

function Connect_A3_M1b_ReturnToBelle:DramaticPause(a_nTime, a_sCallbackFunction)
  EVENT_Timer(a_sCallbackFunction, self, a_nTime)
end

function Connect_A3_M1b_ReturnToBelle:MissionFailed()
  Cin.PlayConversation("A3M1b_Fail")
end

function Connect_A3_M1b_ReturnToBelle:Cleanup()
end
