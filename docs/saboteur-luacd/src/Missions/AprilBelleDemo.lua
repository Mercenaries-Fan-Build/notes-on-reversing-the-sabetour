if AprilBelleDemo == nil then
  AprilBelleDemo = SabTaskObjective:Create()
  gsABD = "Missions\\paris_1\\aprildemo"
  AprilBelleDemo:Configure({
    TaskCount = 99,
    bStarterless = true,
    tUnlockList = {
      "SOE_2_Mission_2"
    },
    MCDisplayID = 2,
    tSMEDNodes = {
      "Missions\\paris_1\\aprildemo\\specialcivs"
    }
  })
end

function AprilBelleDemo:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  Saboteur.CreateDemoManager(self)
end

function AprilBelleDemo:GENERAL_Setup()
  Util.UnloadStaticENTag("CivPop", true)
  Util.UnloadStaticENTag("XPoint", true)
  Util.LoadStaticENTag("BelleTestPop", true)
  self:CreateTask({
    sName = "EMPTYPLACEHOLDERTASK",
    sTaskType = "SabTaskObjectiveEmpty",
    tOnActivate = {
      {
        self.ReactivateSean2,
        {self}
      }
    },
    tOnComplete = {},
    tSMEDNodes = {
      "PARIS\\area01\\belledenuit\\interior\\cin_demo08"
    }
  })
end

function AprilBelleDemo:LoadDynamicNodes()
  Render.FadeTo(0, 0, 0, 255, 0)
  Util.SpawnEditNode("PARIS\\area01\\belledenuit\\interior\\civs.wsd")
  Util.SpawnEditNode("PARIS\\area01\\belledenuit\\interior\\noncinematic.wsd", "AprilBelleDemo.ReactivateSean", self)
end

function AprilBelleDemo:StartCinematic()
  Render.FadeTo(0, 0, 0, 255, 0)
  local tTempEvent = {EventType = "TimerEvent", Time = 5}
  Util.CreateEvent(tTempEvent, "AprilBelleDemo.LoadDynamicNodes", self)
end

function AprilBelleDemo:ReactivateSean()
  Render.FadeTo(0, 0, 0, 255, 0)
  local tDemoEvent3 = {EventType = "TimerEvent", Time = 3}
  Util.CreateEvent(tDemoEvent3, "AprilBelleDemo.ReactivateSean2", self)
end

function AprilBelleDemo:ReactivateSean2()
  EVENT_Stream("AprilBelleDemo.TASK_DEMOCINE", self, "PARIS\\area01\\belledenuit\\interior\\cin_demo08\\Spore_CV_DorissGirl", true)
end

function AprilBelleDemo:TASK_DEMOCINE()
  Actor.TurnOnDude(Util.GetHandleByName("Saboteur"), true)
  self:CreateTask({
    sName = "TASK_DEMOCINE",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "CIN_Demo08_Bell",
    tOnActivate = {
      {
        Sound.LoadSoundBank,
        {
          "Demo2008_BDN.bnk"
        }
      }
    },
    tOnComplete = {
      {
        self.TASK_OUTSIDECALLBACK,
        {self}
      },
      {
        self.SetupEvents,
        {self}
      },
      {
        self.GetGirlToRoom,
        {self}
      },
      {
        Render.FadeTo,
        {
          0,
          0,
          0,
          255,
          0
        }
      },
      {
        Sound.ReleaseSoundBank,
        {
          "Demo2008_BDN"
        }
      },
      {
        Sound.LoadSoundBank,
        {
          "Demo2008.bnk"
        }
      }
    },
    tSMEDNodes = {}
  })
end

function AprilBelleDemo:GetGirlToRoom()
  Object.Teleport(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\cin_demo08\\Spore_CV_DorissGirl"), -80.12338, 259.10208, -797.7639, 69.01103)
  local tGirlEvent = {EventType = "TimerEvent", Time = 0.51}
  Util.CreateEvent(tGirlEvent, "AprilBelleDemo.GetGirlMoving", self)
end

function AprilBelleDemo:GetGirlMoving()
  Render.FadeTo(0, 0, 0, 0, 1.5)
  Actor.UseAttrPt(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\cin_demo08\\Spore_CV_DorissGirl"), Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\AttractionPT_Doris_SexyStand(5)"))
end

function AprilBelleDemo:SetupEvents()
  local hFlirtyDoriss = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\Spore_CV_DorissGirl(2)")
  Actor.UseAttrPt(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\Spore_CV_DorissGirl(2)"), Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\AttractionPt_DorissHairLoop"))
  local tDorissTimer = {
    EventType = "ProximityEvent",
    ObjectA = Util.GetHandleByName("Saboteur"),
    ObjectB = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\Spore_CV_DorissGirl(2)"),
    Proximity = 8
  }
  Util.CreateEvent(tDorissTimer, "AprilBelleDemo.DorissFlirtEvent", self)
  local tDorissTimer2 = {
    EventType = "ProximityEvent",
    ObjectA = Util.GetHandleByName("Saboteur"),
    ObjectB = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\Spore_CV_M_Patron_17(5)"),
    Proximity = 6.5
  }
  Util.CreateEvent(tDorissTimer2, "AprilBelleDemo.DorissFlirtEvent3", self)
  local tDorissTimer3 = {
    EventType = "ProximityEvent",
    ObjectA = Util.GetHandleByName("Saboteur"),
    ObjectB = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_DorissGirl(4)"),
    Proximity = 6
  }
  Util.CreateEvent(tDorissTimer3, "AprilBelleDemo.DorissFlirtEvent4", self)
end

function AprilBelleDemo:DorissFlirtEvent()
  local hFlirtyDoriss = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\Spore_CV_DorissGirl(2)")
  local hFlirtyDoriss2 = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\Spore_CV_DorissGirl(5)")
  AttractionPt.FinishNow(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\AttractionPT_Doris_SexyStand2"), Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\Spore_CV_DorissGirl(5)"))
  Actor.EnableNeeds(hFlirtyDoriss, false)
  Actor.EnableNeeds(hFlirtyDoriss2, false)
  Actor.SetPanicEnabled(hFlirtyDoriss, false)
  Actor.SetPanicEnabled(hFlirtyDoriss2, false)
  Actor.SetFacingDir(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\Spore_CV_DorissGirl(5)"), Util.GetHandleByName("Saboteur"))
  Cin.PlayConversation("Demo2008_DressingRoomConvo", "AprilBelleDemo.DorissFlirtEvent2", self)
  local tFlirtySequence = {
    {
      "PLAYANIMATION",
      {
        "demo_dressing_room_convo_hair"
      }
    },
    {
      "DELAY",
      {4.2}
    },
    {
      "PLAYANIMATION",
      {
        "demo_dressing_room_convo_idle"
      }
    },
    {
      "DELAY",
      {1}
    },
    {
      "TURNTOFACE",
      {"Saboteur"}
    },
    {
      "DELAY",
      {1}
    },
    {
      "CANCELANIMATION"
    }
  }
  ScriptSequence.Run(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\Spore_CV_DorissGirl(2)"), tFlirtySequence)
end

function AprilBelleDemo:DorissFlirtEvent2()
  Actor.RequestAttrPt(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\Spore_CV_DorissGirl(5)"), Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\AttractionPT_Doris_SexyStand2"))
  Actor.UseAttrPt(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\Spore_CV_DorissGirl(2)"), Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\AttractionPt_DorissHairLoop"))
  Actor.UseAttrPt(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\Spore_CV_DorissGirl(15)"), Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\AttractionPt_DorissGrooming1"))
end

function AprilBelleDemo:DorissFlirtEvent3()
  local hBouncer = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\Spore_CV_M_Patron_17(5)")
  Cin.PlayConversation("Demo2008_BelleConvo")
end

function AprilBelleDemo:DorissFlirtEvent4()
  AttractionPt.FinishNow(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\AttractionPT_Doris_Flirt"), Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_DorissGirl(4)"))
  local hHussyDoriss = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_DorissGirl(4)")
  Cin.PlayConversation("Demo2008_DressingRoomConvo_B", "AprilBelleDemo.DorissFlirtEvent5", self)
end

function AprilBelleDemo:DorissFlirtEvent5()
  Actor.UseAttrPt(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_DorissGirl(4)"), Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\AttractionPT_Doris_Flirt"))
end

function AprilBelleDemo:TASK_DEMOTOWER()
  self:CreateTask({
    sName = "TASK_DEMOTOWER",
    sTaskType = "SabTaskObjectiveDestroy",
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      },
      {
        Sound.ReleaseSoundBank,
        {
          "Demo2008.bnk"
        }
      }
    },
    tTgtInclude = {
      "Missions\\paris_1\\aprildemo\\radiotower\\Tower\\TowerProp"
    },
    tSMEDNodes = {}
  })
end

function AprilBelleDemo:TASK_TALKTOSKYLAR()
  self:CreateTask({
    sName = "TASK_TALKTOSKYLAR",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "DELIVER",
    Proximity = 20,
    sObjectiveTextID = "Meet with Skylar near the Train Station",
    tOnActivate = {},
    tDestProximityObj = {
      "Missions\\soe_2\\mission_2\\starter\\Spore_RS_Skylar"
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    },
    tSMEDNodes = {
      "Missions\\paris_1\\aprildemo\\encounter3\\manager"
    }
  })
end

function AprilBelleDemo:TASK_OUTSIDECALLBACK()
  self:CreateTask({
    sName = "TASK_OUTSIDECALLBACK",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tOnActivate = {
      {
        StarterManager.LoadStarterNode,
        {
          "Spore_RS_Skylar"
        }
      }
    },
    tDestRegion = {
      "Missions\\paris_1\\aprildemo\\specialcivs\\EXTERIORTELEPORTCALLBACK"
    },
    tOnComplete = {
      {
        self.TASK_TALKTOSKYLAR,
        {self}
      },
      {
        Sound.ReleaseSoundBank,
        {
          "Demo2008.bnk"
        }
      }
    },
    tDeliverObjs = {hSab},
    tSMEDNodes = {}
  })
end
