if Paris_6_Mission_1 == nil then
  Paris_6_Mission_1 = SabTaskObjective:Create()
  Paris_6_Mission_1:Configure({
    TaskCount = 99,
    sStarter = "gaspard",
    sSaveMissionNameID = "MissionNames_Text.P6M1",
    tUnlockList = {
      "Paris_6_Mission_1_ConnectB"
    },
    sHQNextMissionStartPoint = _cHQe_P6M1b,
    sConvFile = "P6M1_Start",
    tSMEDNodes = {
      "Missions\\paris_6\\mission_1\\DynamicTriggers",
      "Missions\\paris_6\\mission_1\\scriptedsequences\\chinatownplanes",
      "Missions\\paris_6\\mission_1\\conversation_node",
      "Missions\\paris_6\\mission_1\\scripted_attack",
      "Missions\\paris_6\\mission_1\\missionobjective",
      "Missions\\paris_6\\mission_1\\prison_props\\notredamenazi",
      "Missions\\paris_6\\mission_1\\seabase_nazis"
    },
    tStaticTags = {
      "prison",
      "P6M1_contraband"
    }
  })
end

function Paris_6_Mission_1:STARTER_Setup()
end

function Paris_6_Mission_1:SewerMark()
  local hSewerLoc = Handle("Missions\\paris_6\\mission_1\\starter\\Loc_SewerStart")
  HUD.SetObjectiveMarker(hSewerLoc, eOT_GOTO, cOM_Goto, false, true)
  Trigger.WaitFor("Missions\\paris_6\\mission_1\\starter\\PT_SewerShow", hSab, "Paris_6_Mission_1.NoSewerMark", self, nil, cTRIGGEREVENT_ONENTER)
end

function Paris_6_Mission_1:NoSewerMark()
  local hSewerLoc = Handle("Missions\\paris_6\\mission_1\\starter\\Loc_SewerStart")
  HUD.RemoveObjectiveMarker(hSewerLoc)
  if not Actor.IsUsingAttrPt(Handle("Missions\\paris_6\\mission_1\\starter\\gaspard")) then
    Actor.UseAttrPt(Handle("Missions\\paris_6\\mission_1\\starter\\gaspard"), Handle("Missions\\paris_6\\mission_1\\starter\\ATTRPT_P6M1Starter"))
  end
end

function Paris_6_Mission_1:BrymanStand()
  self = Paris_6_Mission_1
  if Actor.IsUsingAttrPt(Handle("Missions\\paris_6\\mission_1\\starter\\gaspard")) then
    Actor.CancelAttrPt(Handle("Missions\\paris_6\\mission_1\\starter\\gaspard"))
  end
  AttractionPt.EnableBroadcast(Handle("Missions\\paris_6\\mission_1\\starter\\ATTRPT_P6M1Starter"), false)
end

function Paris_6_Mission_1:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  Util.SpawnEditNode("Missions\\paris_6\\mission_1\\execution.wsd")
  self.MainTaskName(self)
  self.PrisonOutBreakSetup(self)
  Util.UnloadStaticENTag("seabase_worldpop", true)
  Util.UnloadStaticENTag("PrisonBreakRemove", true)
  Util.UnloadStaticENTag("Chinatown_unload", true)
  Squad.Create("ZergAssalt1")
  Squad.Create("NaziArmy")
  Squad.SetEnemy("ZergAssalt1", "NaziArmy", true)
  Sound.LoadSoundBank("m_P6M1_inGame.bnk")
end

function Paris_6_Mission_1:GENERAL_Setup()
  Util.SetTime(20, 0)
  self.nMarchersLoaded = 0
  self.bMissionFail = false
  self.nZeppelinsRequested = 0
end

function Paris_6_Mission_1:MainTaskName()
  self:CreateTask({
    sName = "EmptyMainTask",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bPersistentParent = true,
    tOnActivate = {
      {
        self.SetupCheckpoint0,
        {self}
      }
    }
  })
end

function Paris_6_Mission_1:HookupExecution()
  self.bDidntUseZep = false
  self.ePartyCrashTrig = Trigger.WaitFor("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_PartyCrasher", hSab, "Paris_6_Mission_1.GetInsidePalace", self, nil, cTRIGGEREVENT_ONENTER)
  self:RegisterTriggerEvent(self.ePartyCrashTrig, "Missions\\paris_6\\mission_1\\dynamictriggers\\PT_PartyCrasher")
  self.eSpawnExeTrigger = Trigger.WaitFor("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_StartExecution", hSab, "Paris_6_Mission_1.SpawnAxeman", self, nil, cTRIGGEREVENT_ONENTER)
  self:RegisterTriggerEvent(self.eSpawnExeTrigger, "Missions\\paris_6\\mission_1\\dynamictriggers\\PT_StartExecution")
  self.AxemanReady = false
  self.ExecutionReady = false
  self.eAxeManDeath = nil
  self.hHurtDudeReal = nil
  self.hHurtDudeEarly = nil
  self.SpeedyAxeman = false
  self.SetupVicAnimate(self)
end

function Paris_6_Mission_1:SetupCheckpoint0()
  self.RegisterCheckpoint(self, "Paris_6_Mission_1.Checkpoint0")
end

function Paris_6_Mission_1:Checkpoint0()
  self.HookupExecution(self)
  self.Task_FindAWayToBase(self)
end

function Paris_6_Mission_1:Task_FindAWayToBase()
  Render.PrintMessage("Eh, did it take the change?")
  self:CreateTask({
    sName = "GetToBase",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "P6M1_Text.EnterFuelingPlatform",
    sTaskSubType = "GOTO",
    tLocators = {
      "Missions\\paris_6\\mission_1\\missionobjective\\LOC_InfiltrateSB"
    },
    tDestRegion = "Missions\\paris_6\\mission_1\\dynamictriggers\\PT_GetToSeabase",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.SetupCheckpoint1,
        {self}
      }
    }
  })
end

function Paris_6_Mission_1:SetupCheckpoint1()
  local hRetrySpawn = Handle("Missions\\paris_6\\mission_1\\missionobjective\\Loc_RetryFindRadio")
  self.RegisterCheckpoint(self, "Paris_6_Mission_1.Checkpoint1_Death", "Paris_6_Mission_1.Checkpoint1_Cont", nil, hRetrySpawn)
end

function Paris_6_Mission_1:Checkpoint1_Death()
  self.HookupExecution(self)
  self.FindRadioTask(self)
end

function Paris_6_Mission_1:Checkpoint1_Cont()
  self.FindRadioTask(self)
end

function Paris_6_Mission_1:FindRadioTask()
  Cin.PlayConversation("P6M1_GetToSeaBase")
  self:CreateTask({
    sName = "FindRadioTask",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "P6M1_Text.FindRadio",
    sTaskSubType = "GOTO",
    tLocators = {
      "Missions\\paris_6\\mission_1\\missionobjective\\LOC_FindRadio"
    },
    tDestRegion = "Missions\\paris_6\\mission_1\\missionobjective\\PT_FindRadio",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Task_CallInZep,
        {self}
      }
    }
  })
end

function Paris_6_Mission_1:RadioKilled()
  self:MissionTaskFail("GenericFail_Text.DESTROYED_Critical_RadioBox")
end

function Paris_6_Mission_1:Task_CallInZep()
  AttractionPt.EnableUse(Handle("Missions\\paris_6\\mission_1\\dynamictriggers\\CallInZep"), true)
  self:CreateTask({
    sName = "CallInZeppy",
    sTaskType = "SabTaskObjectiveInteract",
    sObjectiveTextID = "P6M1_Text.RadioBryman",
    sTaskSubType = "USE",
    tTgtInclude = {
      "Missions\\paris_6\\mission_1\\dynamictriggers\\CallInZep"
    },
    MarkerHeight = 1.5,
    tOnComplete = {
      {
        self.CallBrymanConvo,
        {self}
      }
    }
  })
end

function Paris_6_Mission_1:CallBrymanConvo()
  self.nZeppelinsRequested = self.nZeppelinsRequested + 1
  if self.nZeppelinsRequested == 1 then
    Cin.PlayConversation("P6M1_RadioForZep")
    self.RegisterCheckpoint(self, "Paris_6_Mission_1.Checkpoint2_Death", "Paris_6_Mission_1.Checkpoint2_Cont")
  else
    if self.nZeppelinsRequested == 2 then
      Cin.StopCinematic("CIN_P6M1_MiniZep", true)
    else
      Cin.StopCinematic("CIN_P6M1_MiniZep2", true)
    end
    EVENT_Timer("Paris_6_Mission_1.Checkpoint2_Cont", self, 1)
    if self.nZeppelinsRequested == 2 then
      Convo.AddConvo("P6M1_Zep_RequestAnother_Repeat", 10, {})
    else
      Convo.AddConvo("P6M1_RequestAnother_Repeat", 10, {})
    end
  end
  AttractionPt.EnableUse(Handle("Missions\\paris_6\\mission_1\\dynamictriggers\\CallInZep"), false)
end

function Paris_6_Mission_1:ShowDaZep()
  self = Paris_6_Mission_1
  Cin.PlayCinematic("P6M1_CIN_RadioZep")
end

function Paris_6_Mission_1:Checkpoint2_Death()
  self.HookupExecution(self)
  self.nZeppelinsRequested = 1
  Sound.SetMusicLocale("P6M1_PrisonBreak")
  Sound.SetMusicLocale("m_P6M1_PrisonBreak", "ZepArrive")
  self.hZepDest = nil
  self.ZepLeaves = nil
  self.hEarlyFall = nil
  self.ZepToPrison(self)
end

function Paris_6_Mission_1:Checkpoint2_Cont()
  Sound.SetMusicLocale("P6M1_PrisonBreak")
  Sound.SetMusicLocale("m_P6M1_PrisonBreak", "ZepArrive")
  self.bDidntUseZep = false
  EVENT_Timer("Paris_6_Mission_1.StartTheZepStart", self, 0.5)
end

function Paris_6_Mission_1:StartTheZepStart()
  if self.nZeppelinsRequested == 1 then
    Cin.PlayCinematic("CIN_P6M1_MiniZepPre")
  else
    self.ZepToPrison(self)
  end
end

function Paris_6_Mission_1:ZepToPrison()
  self = Paris_6_Mission_1
  if self.nZeppelinsRequested == 1 then
    Cin.StopCinematic("CIN_P6M1_MiniZepPre")
    Cin.PlayCinematic("CIN_P6M1_MiniZep")
    EVENT_Timer("Paris_6_Mission_1.PauseTheCinematic1", self, 1)
  else
    Cin.PlayCinematic("CIN_P6M1_MiniZep2")
    local tEvent = {EventType = "TimerEvent", Time = 20}
    self.ePauseZep = Util.CreateEvent(tEvent, "Paris_6_Mission_1.PauseTheCinematic1", self)
    self:RegisterEvent(self.ePauseZep)
  end
  EVENT_Timer("Paris_6_Mission_1.TaskBoardZeppy", self, 1)
end

function Paris_6_Mission_1:TaskBoardZeppy()
  self.ZepLeaves = nil
  if self.nZeppelinsRequested == 1 then
    self.hZepHandle = Cin.GetSplineObject("CIN_P6M1_MiniZep", false)
  else
    self.hZepHandle = Cin.GetSplineObject("CIN_P6M1_MiniZep2", false)
  end
  if not self.hZepDest then
    self.hZepDest = Util.CreateEvent({
      EventType = "DeathEvent",
      EventName = "MiniZepDead",
      ObjectHandle = self.hZepHandle
    }, "Paris_6_Mission_1.NeedAnotherZep", self, {}, false)
    self:RegisterEvent(self.hZepDest)
  end
  self:CreateTask({
    sName = "FakeBoardZeppy",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tLocators = {
      self.hZepHandle
    },
    sObjectiveTextID = "P6M1_Text.BoardZeppelin"
  })
  self.bSabOnZep = false
  if self.eCheckIfSab then
    Trigger.ClearCallback("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_CheckIfSabOnZep", self.eCheckIfSab)
    self.eCheckIfSab = nil
  end
  Trigger.Enable("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_CheckIfSabOnZep", true)
  self.eCheckIfSab = Trigger.WaitFor("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_CheckIfSabOnZep", hSab, "Paris_6_Mission_1.SabOnZep", self, nil, cTRIGGEREVENT_ONENTER)
  self:RegisterTriggerEvent(self.eCheckIfSab, "Missions\\paris_6\\mission_1\\dynamictriggers\\PT_CheckIfSabOnZep")
  local nbonustime = math.random(self.nZeppelinsRequested * 7 + 73, self.nZeppelinsRequested * 8 + 82)
  local tEvent = {EventType = "TimerEvent", Time = nbonustime}
  self.MoveZepTimer = Util.CreateEvent(tEvent, "Paris_6_Mission_1.ContinueCinematic1", self)
  self:RegisterEvent(self.MoveZepTimer)
end

function Paris_6_Mission_1:PauseTheCinematic1()
  if self.nZeppelinsRequested == 1 then
    Cin.PauseCinematic("CIN_P6M1_MiniZep")
  else
    Cin.PauseCinematic("CIN_P6M1_MiniZep2")
  end
  Trigger.Enable("Missions\\paris_6\\mission_1\\missionobjective\\PT_ZepLeaves", true)
  local hPlayLabel = Filter.New("Player")
  local tSabNearSpawn = Trigger.GetAllWithin(Handle("Missions\\paris_6\\mission_1\\missionobjective\\PT_ZepLeaves"), hPlayLabel)
  Filter.Delete(hPlayLabel)
  if tSabNearSpawn then
    Paris_6_Mission_1.ContinueCinematic1(self, nil, 5)
  else
    if self.eZepLeaves then
      Trigger.ClearCallback("Missions\\paris_6\\mission_1\\missionobjective\\PT_ZepLeaves", self.eZepLeaves)
      self.eZepLeaves = nil
    end
    self.eZepLeaves = Trigger.WaitFor("Missions\\paris_6\\mission_1\\missionobjective\\PT_ZepLeaves", hSab, "Paris_6_Mission_1.ContinueCinematic1", self, {1}, cTRIGGEREVENT_ONENTER)
    self:RegisterTriggerEvent(self.eZepLeaves, "Missions\\paris_6\\mission_1\\missionobjective\\PT_ZepLeaves")
  end
  if self.nZeppelinsRequested == 1 and not tSabNearSpawn then
    Util.CreateEvent({
      EventType = "StreamEvent",
      Objects = {
        "Missions\\paris_6\\mission_1\\zepnazis\\nazi2",
        "Missions\\paris_6\\mission_1\\zepnazis\\nazi3",
        "Missions\\paris_6\\mission_1\\zepnazis\\nazi4"
      }
    }, "Paris_6_Mission_1.SpaceOutNZ", self)
    Util.SpawnEditNode("Missions\\paris_6\\mission_1\\zepnazis.wsd", "Paris_6_Mission_1.NodeLoadedFlag", self, {"zepnazis"})
  end
end

function Paris_6_Mission_1:ContinueCinematic1(sBlah, nHowdtrigger)
  if self.ZepLeaves then
    Util.KillEvent(self.ZepLeaves)
    self.ZepLeaves = nil
    self.nZepRand = math.random(self.nZeppelinsRequested * 2 + 1, self.nZeppelinsRequested * 3 + 1)
  elseif nHowdtrigger == 1 then
    Util.KillEvent(self.MoveZepTimer)
    self.MoveZepTimer = nil
    self.nZepRand = math.random(self.nZeppelinsRequested * 1 + 2, self.nZeppelinsRequested * 2 + 2)
  elseif nHowdtrigger == 5 then
    Util.KillEvent(self.MoveZepTimer)
    self.MoveZepTimer = nil
    self.nZepRand = math.random(self.nZeppelinsRequested * 1, self.nZeppelinsRequested * 2 + 1)
  else
    self.nZepRand = math.random(self.nZeppelinsRequested * 2 + 4, self.nZeppelinsRequested * 3 + 5)
    EVENT_Timer("Paris_6_Mission_1.ShiteTakingOffVO", self, self.nZepRand + 2)
  end
  local tEvent = {
    EventType = "TimerEvent",
    Time = self.nZepRand
  }
  self.ZepLeaves = Util.CreateEvent(tEvent, "Paris_6_Mission_1.NowTheZepLeaves", self)
  self:RegisterEvent(self.ZepLeaves)
end

function Paris_6_Mission_1:ShiteTakingOffVO()
  Convo.AddConvo("P6M1_Zep_LeavingWithoutSean", 10, {})
end

function Paris_6_Mission_1:NowTheZepLeaves()
  if self.nZeppelinsRequested == 1 then
    Cin.PlayCinematic("CIN_P6M1_MiniZep")
  else
    Cin.PlayCinematic("CIN_P6M1_MiniZep2")
  end
  local tEvent = {EventType = "TimerEvent", Time = 12}
  self.CheckOnZep = Util.CreateEvent(tEvent, "Paris_6_Mission_1.CheckIfSabOnZep", self)
  self:RegisterEvent(self.CheckOnZep)
end

function Paris_6_Mission_1:SpaceOutNZ()
  for i = 2, 4 do
    local hNazi = Handle("Missions\\paris_6\\mission_1\\zepnazis\\nazi" .. i)
    if hNazi then
      Actor.OverrideCombatAI(hNazi, true)
      Combat.SetIdleScripted(hNazi, true)
      if i == 2 then
        local tEvent = {EventType = "TimerEvent", Time = 0.5}
        Util.CreateEvent(tEvent, "Paris_6_Mission_1.GetDownLadder", self, {hNazi, i})
      elseif i == 3 then
        local tEvent = {EventType = "TimerEvent", Time = 3}
        Util.CreateEvent(tEvent, "Paris_6_Mission_1.GetDownLadder", self, {hNazi, i})
      else
        local tEvent = {EventType = "TimerEvent", Time = 4}
        Util.CreateEvent(tEvent, "Paris_6_Mission_1.GetDownLadder", self, {hNazi, i})
      end
    end
  end
end

function Paris_6_Mission_1:GetDownLadder(hNazi, a_nLoc)
  if Handle("Missions\\paris_6\\mission_1\\zepnazis\\nazi" .. a_nLoc) then
    Nav.MoveToObject(hNazi, Handle("Missions\\paris_6\\mission_1\\zepnazis\\LOC" .. a_nLoc .. "b"), 1, true, "Paris_6_Mission_1.TurnOnAI", self, {hNazi, a_nLoc})
  end
end

function Paris_6_Mission_1:TurnOnAI(hNazi, a_nLoc)
  if a_nLoc == 4 then
    local x, y, z = Object.GetPosition(Handle("Missions\\paris_6\\mission_1\\zepnazis\\LOC1"))
    Combat.SetTether(hNazi, x, y, z, 1.5, 0)
    Actor.OverrideCombatAI(hNazi, false)
  elseif Handle("Missions\\paris_6\\mission_1\\zepnazis\\nazi" .. a_nLoc) then
    Actor.OverrideCombatAI(hNazi, false)
  end
end

function Paris_6_Mission_1:SabOnZep()
  self.bSabOnZep = true
end

function Paris_6_Mission_1:CheckIfSabOnZep()
  local nSabZepDist = Object.GetDistance(hSab, self.hZepHandle)
  if self.bSabOnZep == true then
    if 13 < nSabZepDist then
      self.NeedAnotherZep(self)
    else
      self:CompleteTaskByName("FakeBoardZeppy")
      EVENT_Timer("Paris_6_Mission_1.Task_GetOnTower", self, 1)
    end
  else
    self.NeedAnotherZep(self)
  end
end

function Paris_6_Mission_1:NoZepsFail()
  self:MissionTaskFail("P6M1_Text.Fail_NoMoreZeps")
end

function Paris_6_Mission_1:NeedAnotherZep()
  if self.nZeppelinsRequested == 3 then
    EVENT_Timer("Paris_6_Mission_1.NoZepsFail", self, 4, {})
  else
    Convo.AddConvo("P6M1_Zep_Missed", 10, {})
    Trigger.ClearCallback("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_CheckIfSabOnZep", self.eCheckIfSab)
    self.eCheckIfSab = nil
    Trigger.DoNotWaitFor("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_CheckIfSabOnZep", hSab)
    Trigger.ClearCallback("Missions\\paris_6\\mission_1\\missionobjective\\PT_ZepLeaves", self.eZepLeaves)
    self.eZepLeaves = nil
    Trigger.DoNotWaitFor("Missions\\paris_6\\mission_1\\missionobjective\\PT_ZepLeaves", hSab)
    Trigger.Enable("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_CheckIfSabOnZep", false)
    Trigger.Enable("Missions\\paris_6\\mission_1\\missionobjective\\PT_ZepLeaves", false)
    if self.MoveZepTimer then
      Util.KillEvent(self.MoveZepTimer)
      self.MoveZepTimer = nil
    end
    if self.CheckOnZep then
      Util.KillEvent(self.CheckOnZep)
      self.CheckOnZep = nil
    end
    if self.ZepLeaves then
      Util.KillEvent(self.ZepLeaves)
      self.ZepLeaves = nil
    end
    if self.ePauseZep then
      Util.KillEvent(self.ePauseZep)
      self.ePauseZep = nil
    end
    if self.hZepDest then
      Util.KillEvent(self.hZepDest)
      self.hZepDest = nil
    end
    if self.hEarlyFall then
      Util.KillEvent("ZepEarlyProxEvent")
      self.hEarlyFall = nil
    end
    if self:IsMissionTaskActive("GetOnTower") then
      self:ResetTaskByName("GetOnTower", true)
    end
    self:KillTaskByName("FakeBoardZeppy")
    self:ResetTaskByName("CallInZeppy", true)
    self:ResetTaskByName("FakeBoardZeppy", true)
    Paris_6_Mission_1.Task_CallInZep(self)
  end
end

function Paris_6_Mission_1:Task_GetOnTower()
  self:CreateTask({
    sName = "GetOnTower",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "P6M1_Text.RideToNotreDame",
    tLocators = {
      "Missions\\paris_6\\mission_1\\dynamictriggers\\Zeppyend"
    },
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\paris_6\\mission_1\\dynamictriggers\\PT_GetOnTower",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.SetupCheckpointNotre,
        {self}
      }
    }
  })
  if not self.hEarlyFall then
    self.hEarlyFall = Util.CreateEvent({
      EventType = "ProximityEvent",
      EventName = "ZepEarlyProxEvent",
      ObjectA = hSab,
      ObjectB = self.hZepHandle,
      Proximity = 14,
      Negate = true
    }, "Paris_6_Mission_1.FellOffZep", self, {})
    self:RegisterEvent(self.hEarlyFall)
  end
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_6\\mission_1\\missionobjective\\PT_RodeZepEnough", hSab, "Paris_6_Mission_1.RodeZep", self, {}, cTRIGGEREVENT_ONENTER), "Missions\\paris_6\\mission_1\\missionobjective\\PT_RodeZepEnough")
end

function Paris_6_Mission_1:FellOffZep()
  EVENT_Timer("Paris_6_Mission_1.NeedAnotherZep", self, 2, {})
end

function Paris_6_Mission_1:RodeZep()
  Util.KillEvent("ZepEarlyProxEvent")
  Util.KillEvent(self.hZepDest)
  self.hZepDest = nil
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_Sean_Drops_To_Notra", hSab, "Paris_6_Mission_1.ZepReachedNotre", self, nil, cTRIGGEREVENT_ONENTER), "Missions\\paris_6\\mission_1\\dynamictriggers\\PT_Sean_Drops_To_Notra")
end

function Paris_6_Mission_1:ZepReachedNotre()
  self.bZepGotToNotre = true
  EVENT_Timer("Paris_6_Mission_1.DelayNotreZepStop", self, 2, {})
end

function Paris_6_Mission_1:DelayNotreZepStop()
  if self.nZeppelinsRequested == 1 then
    Cin.PauseCinematic("CIN_P6M1_MiniZep")
  else
    Cin.PauseCinematic("CIN_P6M1_MiniZep2")
  end
end

function Paris_6_Mission_1:SetupCheckpointNotre()
  if self.bZepGotToNotre == true then
    if self.nZeppelinsRequested == 1 then
      Cin.PlayCinematic("CIN_P6M1_MiniZep")
    else
      Cin.PlayCinematic("CIN_P6M1_MiniZep2")
    end
    self.bZepGotToNotre = false
  end
  local hRespawnHere = Handle("Missions\\paris_6\\mission_1\\missionobjective\\LOC_Teleport_Sean_Drop")
  self.RegisterCheckpoint(self, "Paris_6_Mission_1.CheckpointNotre_Death", "Paris_6_Mission_1.CheckpointNotre_Cont", nil, hRespawnHere)
end

function Paris_6_Mission_1:CheckpointNotre_Death()
  self.HookupExecution(self)
  self.hVeron = Handle("Missions\\paris_6\\mission_1\\execution\\victim7")
  Sound.SetMusicLocale("P6M1_PrisonBreak")
  Sound.SetMusicLocale("m_P6M1_PrisonBreak", "LeaveZep")
  self.ExitZeppy(self)
end

function Paris_6_Mission_1:CheckpointNotre_Cont()
  self.bDidntUseZep = false
  self.hVeron = Handle("Missions\\paris_6\\mission_1\\execution\\victim7")
  Sound.SetMusicLocale("P6M1_PrisonBreak")
  Sound.SetMusicLocale("m_P6M1_PrisonBreak", "LeaveZep")
  self.ExitZeppy(self)
end

function Paris_6_Mission_1:PlayAnimationOfVictims()
  self.hVeron = Handle("Missions\\paris_6\\mission_1\\execution\\victim7")
  for i = 3, 7 do
    local hvictim = Util.GetHandleByName("Missions\\paris_6\\mission_1\\execution\\victim" .. i)
    if hvictim then
      Actor.OverrideCombatAI(hvictim, true)
      if i == 4 then
        Actor.PlayAnimation(hvictim, "civ_F_line_02")
      elseif i == 7 then
        Actor.PlayAnimation(hvictim, "civ_F_line_02")
      else
        Actor.PlayAnimation(hvictim, "civ_idle1")
      end
    end
  end
end

function Paris_6_Mission_1:SetupVicAnimate()
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForGameObject = true,
    Objects = {
      "Missions\\paris_6\\mission_1\\execution\\victim3",
      "Missions\\paris_6\\mission_1\\execution\\victim4",
      "Missions\\paris_6\\mission_1\\execution\\victim5",
      "Missions\\paris_6\\mission_1\\execution\\victim6",
      "Missions\\paris_6\\mission_1\\execution\\victim7"
    }
  }, "Paris_6_Mission_1.PlayAnimationOfVictims", self))
end

function Paris_6_Mission_1:ExitZeppy()
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_WaydownVO_1", hSab, "Paris_6_Mission_1.DelayVO", self, {
    "Missions\\paris_6\\mission_1\\dynamictriggers\\PT_WaydownVO_1",
    "P6M1_NeedWayDown"
  }, cTRIGGEREVENT_ONENTER), "Missions\\paris_6\\mission_1\\dynamictriggers\\PT_WaydownVO_1")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_WaydownVO_2", hSab, "Paris_6_Mission_1.DelayVO", self, {
    "Missions\\paris_6\\mission_1\\dynamictriggers\\PT_WaydownVO_2",
    "P6M1_NoOtherWayDown_2"
  }, cTRIGGEREVENT_ONENTER), "Missions\\paris_6\\mission_1\\dynamictriggers\\PT_WaydownVO_2")
  self:CreateTask({
    sName = "ExitZeppyNow",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "P6M1_Text.GetToThePalaceOfJustice",
    sTaskSubType = "GOTO",
    tLocators = {
      "Missions\\paris_6\\mission_1\\missionobjective\\LOC_GetOffZep"
    },
    tDestRegion = "Missions\\paris_6\\mission_1\\missionobjective\\PT_GetOffZep",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.SetupCheckpoint3,
        {self}
      }
    }
  })
end

function Paris_6_Mission_1:DelayVO(tTriggerData, sTrigger, sConvo)
  EVENT_Timer("Paris_6_Mission_1.ChecknPlayVO", self, 7, {sTrigger, sConvo})
end

function Paris_6_Mission_1:ChecknPlayVO(sTrigger, sConvo)
  local hTrigger = Util.GetHandleByName(sTrigger)
  if Trigger.GetAllWithin(hTrigger) then
    Convo.AddConvo(sConvo, 10, {})
  end
end

function Paris_6_Mission_1:SetupPartyCrashSave()
  EVENT_Timer("Paris_6_Mission_1.PartyCrashSave", self, 2)
end

function Paris_6_Mission_1:PartyCrashSave()
  local hPlayLabel = Filter.New("Player")
  local tWho = Trigger.GetAllWithin(Util.GetHandleByName("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_FindVeronAlt"), hPlayLabel)
  Filter.Delete(hPlayLabel)
  if not tWho then
    self.RegisterCheckpoint(self, "Paris_6_Mission_1.CheckpointPartyCrash_Death", "Paris_6_Mission_1.CheckpointPartyCrash_Cont")
  end
end

function Paris_6_Mission_1:CheckpointPartyCrash_Cont()
end

function Paris_6_Mission_1:CheckpointPartyCrash_Death()
  if Handle("Missions\\paris_6\\mission_1\\axeman\\executor") then
    Paris_6_Mission_1.MoveAxeman(self)
  else
    self.SpawnAxeman(self)
  end
  self.AxemanReady = false
  self.ExecutionReady = false
  self.SetupVicAnimate(self)
  self.GetInsidePalace(self)
  self.bDidntUseZep = true
end

function Paris_6_Mission_1:GetInsidePalace()
  Trigger.DoNotWaitFor("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_PartyCrasher", hSab)
  Trigger.Enable("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_PartyCrasher", false)
  self.bDidntUseZep = true
  if self:IsMissionTaskActive("GetToBase") then
    self:KillTaskByName("GetToBase")
  end
  if self:IsMissionTaskActive("FindRadioTask") then
    self:KillTaskByName("FindRadioTask")
  end
  if self:IsMissionTaskActive("CallInZeppy") then
    self:KillTaskByName("CallInZeppy")
  end
  if self:IsMissionTaskActive("FakeBoardZeppy") then
    self:KillTaskByName("FakeBoardZeppy")
  end
  if self:IsMissionTaskActive("GetOnTower") then
    self:KillTaskByName("GetOnTower")
  end
  if self:IsMissionTaskActive("ExitZeppyNow") then
    self:KillTaskByName("ExitZeppyNow")
  end
  local hPlayLabel = Filter.New("Player")
  local tWho = Trigger.GetAllWithin(Util.GetHandleByName("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_FindVeronAlt"), hPlayLabel)
  Filter.Delete(hPlayLabel)
  if not tWho then
    self:CreateTask({
      sName = "GetInPalace",
      sTaskType = "SabTaskObjectiveDeliver",
      sObjectiveTextID = "P6M1_Text.GetToThePalaceOfJustice",
      sTaskSubType = "GOTO",
      tLocators = {
        "Missions\\paris_6\\mission_1\\dynamictriggers\\Loc_GetInPalace"
      },
      tDestRegion = "Missions\\paris_6\\mission_1\\dynamictriggers\\PT_FindVeronAlt",
      tDeliverObjs = {hSab},
      tOnComplete = {
        {
          self.SetupCheckpoint3,
          {self}
        }
      }
    })
  else
    self.SetupCheckpoint3(self)
  end
end

function Paris_6_Mission_1:SpawnAxeman()
  Util.SpawnEditNode("Missions\\paris_6\\mission_1\\axeman.wsd")
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForGameObject = true,
    Objects = {
      "Missions\\paris_6\\mission_1\\axeman\\executor"
    }
  }, "Paris_6_Mission_1.MoveAxeman", self))
  Object.Actuate(Handle("Missions\\paris_6\\mission_1\\prison_props\\OccLt_SpawnerBunkerLarge(5)\\Door_Left"))
  Object.Actuate(Handle("Missions\\paris_6\\mission_1\\prison_props\\OccLt_SpawnerBunkerLarge(5)\\Door_Right"))
end

function Paris_6_Mission_1:MoveAxeman()
  local hShooter = Util.GetHandleByName("Missions\\paris_6\\mission_1\\axeman\\executor")
  Actor.OverrideCombatAI(hShooter, true)
  Combat.SetIdleScripted(hShooter, true)
  if not self.hHurtDudeEarly then
    self.hHurtDudeEarly = Util.CreateEvent({
      EventType = "DamageEvent",
      EventName = "HurtExecutioner",
      ObjectName = "Missions\\paris_6\\mission_1\\axeman\\executor"
    }, "Paris_6_Mission_1.StoppedExecution", self, nil, false)
    self:RegisterEvent(self.hHurtDudeEarly)
  end
  local hNearStage = Handle("Missions\\paris_6\\mission_1\\execution\\Loc_ExecuteHere")
  local tAxemanInPlace = {
    EventType = "ProximityEvent",
    ObjectA = hShooter,
    ObjectB = hNearStage,
    Proximity = 2,
    Negate = false,
    Check3D = false
  }
  self.eAxemanAtStage = Util.CreateEvent(tAxemanInPlace, "Paris_6_Mission_1.AxemanMoved", self)
  self:RegisterEvent(self.eAxemanAtStage)
  if not self.eAxeManDeath then
    self.eAxeManDeath = EVENT_ActorDeath("Paris_6_Mission_1.StoppedExecution", self, hShooter)
  end
  Nav.SetScriptedPath(Handle("Missions\\paris_6\\mission_1\\axeman\\executor"), "Missions\\paris_6\\mission_1\\execution\\Pa_AxemanEnter", true)
  if self.SpeedyAxeman then
    Nav.SetScriptedPathMoveMode(Handle("Missions\\paris_6\\mission_1\\axeman\\executor"), true)
  end
end

function Paris_6_Mission_1:AxemanMoved()
  self.AxemanReady = true
  if self.ExecutionReady == true then
    self.ExecutionBegin(self)
  end
end

function Paris_6_Mission_1:SetupCheckpoint3()
  Trigger.DoNotWaitFor("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_PartyCrasher", hSab)
  Trigger.Enable("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_PartyCrasher", false)
  self.ExecutionReady = true
  if self.AxemanReady == true then
    self.ExecutionBegin(self)
  end
  if self.bDidntUseZep == false then
    local hRetrySpawn = Handle("Missions\\paris_6\\mission_1\\missionobjective\\LOC_RespawnCheck3")
    self.RegisterCheckpoint(self, "Paris_6_Mission_1.Checkpoint3_Death", "Paris_6_Mission_1.Checkpoint3_Cont", nil, hRetrySpawn)
  else
    self.Checkpoint3_Cont(self)
  end
end

function Paris_6_Mission_1:Checkpoint3_Cont()
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForGameObject = true,
    Objects = {
      "Missions\\paris_6\\mission_1\\axeman\\executor"
    }
  }, "Paris_6_Mission_1.StopExecution", self))
  self.SpawnerSetup(self)
end

function Paris_6_Mission_1:Checkpoint3_Death()
  self.SetupVicAnimate(self)
  self.eAxeManDeath = nil
  self.hHurtDudeReal = nil
  self.hHurtDudeEarly = nil
  self.SpeedyAxeman = false
  self.MoveAxeman(self)
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForGameObject = true,
    Objects = {
      "Missions\\paris_6\\mission_1\\axeman\\executor"
    }
  }, "Paris_6_Mission_1.StopExecution", self))
  self.SpawnerSetup(self)
end

function Paris_6_Mission_1:KillVeron()
  Paris_6_Mission_1.NowFailz(self)
end

function Paris_6_Mission_1:VeroniqueDeath()
  Cin.PlayConversation("P6M1_VeroniqueDead")
end

function Paris_6_Mission_1:NowFailz()
  self:MissionTaskFail("Char_Death.RS_Veronique")
end

function Paris_6_Mission_1:ExecutionBegin()
  self.hVeron = Handle("Missions\\paris_6\\mission_1\\execution\\victim7")
  self.hVeronDeathEvent = EVENT_ActorDeath("Paris_6_Mission_1.VeroniqueDeath", self, self.hVeron)
  local hShooter = Util.GetHandleByName("Missions\\paris_6\\mission_1\\axeman\\executor")
  Nav.CancelScriptedPath(hShooter)
  Actor.OverrideCombatAI(hShooter, true)
  Combat.SetRespondToSound(hShooter, false)
  Combat.SetRespondToDeadBodies(hShooter, false)
  Combat.SetRespondToDamage(hShooter, false)
  Combat.SetBroadcastEnteredCombat(hShooter, false)
  Combat.SetBroadcastWeaponFire(hShooter, false)
  Combat.SetIdleHoldWeapon(hShooter, true)
  Cin.PlayConversation("P6M1_Execute_1")
  EVENT_Timer("Paris_6_Mission_1.StartExecutions", self, 3)
end

function Paris_6_Mission_1:StartExecutions()
  self.eCloseToExecutioner = Trigger.WaitFor("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_CloseToExecution", hSab, "Paris_6_Mission_1.StoppedExecution", self, true, cTRIGGEREVENT_ONENTER)
  self:RegisterTriggerEvent(self.eCloseToExecutioner, "Missions\\paris_6\\mission_1\\dynamictriggers\\PT_CloseToExecution")
  self.nMax = 7
  self.Executions(self, "Missions\\paris_6\\mission_1\\execution\\loc", "Missions\\paris_6\\mission_1\\execution\\victim", "Missions\\paris_6\\mission_1\\axeman\\executor", 3)
  Cin.PlayCinematic("P6M1_Show_Exicutioner")
end

function Paris_6_Mission_1:Executions(sStringLoc, sStringVictim, sStringNazi, nCur)
  if nCur <= self.nMax then
    self.nCurWOdaDead = nCur - 2
    if nCur == 3 then
    elseif not self.SpeedyAxeman then
      Cin.PlayConversation("P6M1_Execute_" .. self.nCurWOdaDead)
    end
    local hVictim = Handle(sStringVictim .. nCur)
    if hVictim then
      local hLoc = Util.GetHandleByName(sStringLoc .. nCur)
      local hNazi = Util.GetHandleByName(sStringNazi)
      local x, y, z = Object.GetPosition(hLoc)
      if self.SpeedyAxeman and not nCur == 3 then
        Nav.MoveToPoint(hNazi, x, y, z, true, "Paris_6_Mission_1.ExecutionDelay", self, {
          sStringLoc,
          sStringVictim,
          sStringNazi,
          nCur
        }, 5)
      else
        Nav.MoveToPoint(hNazi, x, y, z, false, "Paris_6_Mission_1.ExecutionDelay", self, {
          sStringLoc,
          sStringVictim,
          sStringNazi,
          nCur
        }, 5)
      end
    else
      nCur = nCur + 1
      self.Executions(self, sStringLoc, sStringVictim, sStringNazi, nCur)
    end
  end
end

function Paris_6_Mission_1:ExecutionDelay(sStringLoc, sStringVictim, sStringNazi, nCur)
  if nCur <= self.nMax then
    local hVictim = Handle(sStringVictim .. nCur)
    if hVictim then
      if nCur == 3 then
        EVENT_Timer("Paris_6_Mission_1.ExecutionFire", self, 6, {
          sStringLoc,
          sStringVictim,
          sStringNazi,
          nCur
        })
        EVENT_Timer("Paris_6_Mission_1.PrisonerKneel", self, 1, {sStringVictim, nCur})
      elseif self.SpeedyAxeman then
        EVENT_Timer("Paris_6_Mission_1.ExecutionFire", self, 1, {
          sStringLoc,
          sStringVictim,
          sStringNazi,
          nCur
        })
      elseif nCur == 7 then
        EVENT_Timer("Paris_6_Mission_1.ExecutionFire", self, 19, {
          sStringLoc,
          sStringVictim,
          sStringNazi,
          nCur
        })
        EVENT_Timer("Paris_6_Mission_1.PrisonerKneel", self, 5, {sStringVictim, nCur})
      else
        EVENT_Timer("Paris_6_Mission_1.ExecutionFire", self, 13, {
          sStringLoc,
          sStringVictim,
          sStringNazi,
          nCur
        })
        EVENT_Timer("Paris_6_Mission_1.PrisonerKneel", self, 6, {sStringVictim, nCur})
      end
    else
      nCur = nCur + 1
      self.Executions(self, sStringLoc, sStringVictim, sStringNazi, nCur)
    end
  end
end

function Paris_6_Mission_1:PrisonerKneel(sStringVictim, nCur)
  if nCur <= self.nMax then
    local hRSVic = Handle(sStringVictim .. nCur)
    Actor.PlayAnimation(hRSVic, "civ_M_HR_knee_idle")
  end
end

function Paris_6_Mission_1:ExecutionFire(sStringLoc, sStringVictim, sStringNazi, nCur)
  if nCur <= self.nMax then
    local hVictim = Handle(sStringVictim .. nCur)
    if hVictim then
      local hNazi = Util.GetHandleByName(sStringNazi)
      local hVictim = Util.GetHandleByName(sStringVictim .. nCur)
      Actor.SetFacingDir(hNazi, hVictim)
      Util.CreateExecutionScene(hNazi, {hVictim}, cEXECUTION_ONEBYONE_STANDING, "Paris_6_Mission_1.WeirdDelayhack", self, {
        sStringLoc,
        sStringVictim,
        sStringNazi,
        nCur + 1
      })
    else
      nCur = nCur + 1
      self.Executions(self, sStringLoc, sStringVictim, sStringNazi, nCur)
    end
  end
end

function Paris_6_Mission_1:WeirdDelayhack(sStringLoc, sStringVictim, sStringNazi, nCur)
  if nCur <= self.nMax then
    if self.SpeedyAxeman then
      EVENT_Timer("Paris_6_Mission_1.Executions", self, 1, {
        sStringLoc,
        sStringVictim,
        sStringNazi,
        nCur
      })
    else
      EVENT_Timer("Paris_6_Mission_1.Executions", self, 5, {
        sStringLoc,
        sStringVictim,
        sStringNazi,
        nCur
      })
    end
  end
end

function Paris_6_Mission_1:SpawnerSetup()
  local hSpawner = Util.GetHandleByName("Missions\\paris_6\\mission_1\\execution\\ResistanceSpawner")
  self:RegisterEvent(Util.CreateEvent({EventType = "OnSpawn", Target = hSpawner}, "Paris_6_Mission_1.OnSpawn", self, {1}, true))
end

function Paris_6_Mission_1:OnSpawn(hwho)
  Squad.AddMember("Saboteur", hwho[2])
end

function Paris_6_Mission_1:StopExecution()
  local hShooter = Util.GetHandleByName("Missions\\paris_6\\mission_1\\axeman\\executor")
  if self.hHurtDudeEarly then
    Util.KillEvent(self.hHurtDudeEarly)
    self.hHurtDudeEarly = nil
  end
  if not self.eAxeManDeath then
    self.eAxeManDeath = EVENT_ActorDeath("Paris_6_Mission_1.StoppedExecution", self, hShooter)
  end
  if not self.hHurtDudeReal then
    self.hHurtDudeReal = Util.CreateEvent({
      EventType = "DamageEvent",
      EventName = "HurtExecutioner",
      ObjectName = "Missions\\paris_6\\mission_1\\axeman\\executor"
    }, "Paris_6_Mission_1.CheckAxemanDamage", self, nil, false)
    self:RegisterEvent(self.hHurtDudeReal)
  end
  self.eLeftVeron = Trigger.WaitFor("Missions\\paris_6\\mission_1\\missionobjective\\PT_LeftVeronTaDie", hSab, "Paris_6_Mission_1.KillVeron", self, nil, cTRIGGEREVENT_ONEXIT)
  self:RegisterTriggerEvent(self.eLeftVeron, "Missions\\paris_6\\mission_1\\missionobjective\\PT_LeftVeronTaDie")
  if not self:IsMissionTaskActive("GrenadeNazi") then
    self:CreateTask({
      sName = "GrenadeNazi",
      sTaskType = "SabTaskObjectiveDestroy",
      sTaskSubType = "KILL",
      tTgtInclude = {
        "Missions\\paris_6\\mission_1\\axeman\\executor"
      },
      sObjectiveTextID = "P6M1_Text.StopExecution",
      tOnComplete = {}
    })
  end
  self.nSpeedHimUp = 0
  for i = 1, 6 do
    local hWatcher = Handle("Missions\\paris_6\\mission_1\\prison_props\\notredamenazi\\WatchNazi_" .. i)
    EVENT_ActorEntersCombat("Paris_6_Mission_1.SpeedUpAxeman", self, hWatcher, nil, false)
  end
end

function Paris_6_Mission_1:CheckAxemanDamage()
  local hAxeHealth = Object.GetHealth(Handle("Missions\\paris_6\\mission_1\\axeman\\executor"))
  if 60 <= hAxeHealth then
    self.SpeedyAxeman = true
    self.hHurtAxeExtra = Util.CreateEvent({
      EventType = "DamageEvent",
      EventName = "HurtExecutionerAgain",
      ObjectName = "Missions\\paris_6\\mission_1\\axeman\\executor"
    }, "Paris_6_Mission_1.CheckAxemanDamage", self, nil, false)
    self:RegisterEvent(self.hHurtAxeExtra)
  else
    self.StoppedExecution(self)
  end
end

function Paris_6_Mission_1:SpeedUpAxeman()
  self.nSpeedHimUp = self.nSpeedHimUp + 1
  if self.nSpeedHimUp > 3 then
    self.SpeedyAxeman = true
  end
end

function Paris_6_Mission_1:StoppedExecution()
  if self:IsMissionTaskActive("ExitZeppyNow") then
    self:KillTaskByName("ExitZeppyNow")
  end
  if self.hHurtDudeReal then
    Util.KillEvent(self.hHurtDudeReal)
    self.hHurtDudeReal = nil
  end
  if self.eAxeManDeath then
    Util.KillEvent(self.eAxeManDeath)
    self.eAxeManDeath = nil
  end
  if self.hHurtAxeExtra then
    Util.KillEvent(self.hHurtAxeExtra)
    self.hHurtAxeExtra = nil
  end
  if self.eAxemanAtStage then
    Util.KillEvent(self.eAxemanAtStage)
    self.eAxemanAtStage = nil
  end
  self:CompleteTaskByName("GrenadeNazi")
  self.KilledAxeman(self)
  self.nMax = 0
  if self.nCurWOdaDead then
    Cin.StopConversation("P6M1_Execute_" .. self.nCurWOdaDead)
  end
  Trigger.DoNotWaitFor("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_PartyCrasher", hSab)
  Trigger.Enable("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_PartyCrasher", false)
  Trigger.DoNotWaitFor("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_CloseToExecution", hSab)
  Trigger.Enable("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_CloseToExecution", false)
  local hShooter = Util.GetHandleByName("Missions\\paris_6\\mission_1\\axeman\\executor")
  if hShooter then
    Actor.OverrideCombatAI(hShooter, false)
    Combat.SetTarget(hShooter, hSab)
  else
    Convo.AddConvo("P6M1_KillExicutioner", 10, {})
  end
end

function Paris_6_Mission_1:KilledAxeman()
  self.GetNearVeronique(self)
  local tEvent = {EventType = "TimerEvent", Time = 3}
  self.eBreakMad = Util.CreateEvent(tEvent, "Paris_6_Mission_1.PrisonOutBreakMaddness", self)
  self:RegisterEvent(self.eBreakMad)
  Paris_6_Mission_1.NowBreakOut(self)
  local tEvent = {EventType = "TimerEvent", Time = 3}
  self.eChangeDaWillTF = Util.CreateEvent(tEvent, "Paris_6_Mission_1.ChangeWTF", self)
  self:RegisterEvent(self.eChangeDaWillTF)
  self.eVeronAtCrates = Trigger.WaitFor("Missions\\paris_6\\mission_1\\dynamictriggers\\PT_VeronInPlace", self.hVeron, "Paris_6_Mission_1.VeronAtCrates", self, {}, cTRIGGEREVENT_ONENTER)
  self:RegisterTriggerEvent(eVeronAtCrates, "Missions\\paris_6\\mission_1\\dynamictriggers\\PT_VeronInPlace")
  Sound.SetMusicLocale("P6M1_PrisonBreak")
  Sound.SetMusicLocale("m_P6M1_PrisonBreak", "P6M1_LightAction")
end

function Paris_6_Mission_1:VeronAtCrates()
  local hSpawner1 = Util.GetHandleByName("Missions\\paris_6\\mission_1\\execution\\ResistanceSpawner")
  Object.EnableSpawner(hSpawner1, true)
  Actor.OverrideCombatAI(self.hVeron, false)
  Squad.AddMember("Saboteur", self.hVeron)
  Combat.SetCombat(self.hVeron)
  local x, y, z = Object.GetPosition(Handle("Missions\\paris_6\\mission_1\\zerglocs\\Loc20"))
  Combat.SetTether(self.hVeron, x, y, z, 3, 0)
end

function Paris_6_Mission_1:ChangeWTF()
  Cin.StopCinematic("P6M1_Show_Exicutioner")
  Cin.PlayCinematic("WTF_P6M1_PrisonBreak")
end

function Paris_6_Mission_1:PrisonOutBreakSetup()
  Util.SpawnEditNode("Missions\\paris_6\\mission_1\\PrisonOutbreak.wsd")
  self.eCagedFight = Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\paris_6\\mission_1\\PrisonOutbreak\\Fighter1",
      "Missions\\paris_6\\mission_1\\PrisonOutbreak\\Fighter2",
      "Missions\\paris_6\\mission_1\\PrisonOutbreak\\Fighter3",
      "Missions\\paris_6\\mission_1\\PrisonOutbreak\\Fighter4",
      "Missions\\paris_6\\mission_1\\PrisonOutbreak\\Fighter5",
      "Missions\\paris_6\\mission_1\\PrisonOutbreak\\Fighter6"
    }
  }, "Paris_6_Mission_1.PrisonOutBreakHumanNull", self)
  self:RegisterEvent(self.eCagedFight)
end

function Paris_6_Mission_1:PrisonOutBreakHumanNull()
  local tGuys = {
    "Missions\\paris_6\\mission_1\\PrisonOutbreak\\Fighter1",
    "Missions\\paris_6\\mission_1\\PrisonOutbreak\\Fighter2",
    "Missions\\paris_6\\mission_1\\PrisonOutbreak\\Fighter3",
    "Missions\\paris_6\\mission_1\\PrisonOutbreak\\Fighter4",
    "Missions\\paris_6\\mission_1\\PrisonOutbreak\\Fighter5",
    "Missions\\paris_6\\mission_1\\PrisonOutbreak\\Fighter6"
  }
  for i, v in ipairs(tGuys) do
    local hPrisoner = Util.GetHandleByName(v)
    if hPrisoner then
      Actor.OverrideCombatAI(hPrisoner, true)
    end
  end
end

function Paris_6_Mission_1:MoveVeronAgain()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Missions\\paris_6\\mission_1\\zerglocs\\Loc20"))
  Nav.MoveToPoint(self.hVeron, x, y, z, cMOVE_PANIC)
end

function Paris_6_Mission_1:PrisonOutBreakMaddness()
  Actor.CancelAnimation(self.hVeron)
  Nav.SetScriptedPath(self.hVeron, "Missions\\paris_6\\mission_1\\execution\\Pa_VeronExitStageRt", true, "Paris_6_Mission_1.MoveVeronAgain", self)
  Nav.SetScriptedPathMoveMode(self.hVeron, true)
  Combat.SetIdleScripted(self.hVeron, true)
  Squad.SetEnemy("GenericNazi", "Saboteur", true)
  local tFighters = {
    "Missions\\paris_6\\mission_1\\execution\\victim3",
    "Missions\\paris_6\\mission_1\\execution\\victim4",
    "Missions\\paris_6\\mission_1\\execution\\victim5",
    "Missions\\paris_6\\mission_1\\execution\\victim6"
  }
  for i, v in ipairs(tFighters) do
    local hPrisoner = Util.GetHandleByName(v)
    if hPrisoner then
      Actor.CancelAnimation(hPrisoner)
      Actor.OverrideCombatAI(hPrisoner, false)
      Squad.AddMember("Saboteur", hPrisoner)
      Combat.SetCombat(hPrisoner)
      self.RandomPoints(self, hPrisoner, "Missions\\paris_6\\mission_1\\zerglocs\\Loc", 19)
    end
  end
end

function Paris_6_Mission_1:NowBreakOut()
  Squad.SetEnemy("GenericNazi", "Saboteur", true)
  local tFighters = {
    "Missions\\paris_6\\mission_1\\PrisonOutbreak\\Fighter1",
    "Missions\\paris_6\\mission_1\\PrisonOutbreak\\Fighter2",
    "Missions\\paris_6\\mission_1\\PrisonOutbreak\\Fighter3",
    "Missions\\paris_6\\mission_1\\PrisonOutbreak\\Fighter4",
    "Missions\\paris_6\\mission_1\\PrisonOutbreak\\Fighter5",
    "Missions\\paris_6\\mission_1\\PrisonOutbreak\\Fighter6"
  }
  for i, v in ipairs(tFighters) do
    local hPrisoner = Util.GetHandleByName(v)
    if hPrisoner and Object.IsAlive(hPrisoner) then
      Actor.OverrideCombatAI(hPrisoner, false)
      Squad.AddMember("Saboteur", hPrisoner)
      Combat.SetCombat(hPrisoner)
      self.RandomPoints(self, hPrisoner, "Missions\\paris_6\\mission_1\\zerglocs\\Loc", 19)
    end
  end
  Object.Actuate(Handle("Missions\\paris_6\\mission_1\\prison_props\\Occ_SecFence_PedGate5m_DoorFrame(5)\\Occ_SecFence_PedGate5m_DoorAnim_R"))
  Object.Actuate(Handle("Missions\\paris_6\\mission_1\\prison_props\\Occ_SecFence_PedGate5m_DoorFrame(5)\\Occ_SecFence_PedGate5m_DoorAnim_L"))
end

function Paris_6_Mission_1:RandomPoints(hwho, sLocname, nRange)
  if hwho ~= nil then
    local hLoc = Util.GetHandleByName(sLocname .. math.random(nRange))
    Combat.SetObjective(hwho, hLoc, false, 0, false)
  end
end

function Paris_6_Mission_1:GetNearVeronique()
  self:CreateTask({
    sName = "ProtectHer",
    sTaskType = "SabTaskObjectiveDestroy",
    sDestroyType = "DEFEND",
    sTaskSubType = "DEFEND",
    sObjectiveTextID = "P6M1_Text.ProtectVeronique",
    tTgtInclude = {
      "Missions\\paris_6\\mission_1\\execution\\victim7"
    },
    tSMEDNodes = {},
    tOnComplete = {},
    tOnFailure = {}
  })
  self.VerProtectID = HUD.AddObjective(eOT_HEART, SabTask:GetLocalizedText("P6M1_Text.VeronHealth"), 2, nil)
  HUD.SetupProgressBar(self.VerProtectID, Handle("Missions\\paris_6\\mission_1\\execution\\victim7"))
  local tEvent = {EventType = "TimerEvent", Time = 17}
  self.GateCrashTimer = Util.CreateEvent(tEvent, "Paris_6_Mission_1.CheckVeronProx", self)
  self:RegisterEvent(self.GateCrashTimer)
end

function Paris_6_Mission_1:PutBrymanInTruck()
  self.hTrucky = Util.GetHandleByName("Missions\\paris_6\\mission_1\\carsnbombs\\VH_NZ_TR_OpelCanvas_01")
  self.hBryman = Handle("Missions\\paris_6\\mission_1\\carsnbombs\\BrymanDrives")
  Actor.BoardVehicle(Handle("Missions\\paris_6\\mission_1\\carsnbombs\\BrymanDrives"), self.hTrucky, "PILOT", true)
  EVENT_Timer("Paris_6_Mission_1.VitCrash", self, 0.35)
end

function Paris_6_Mission_1:CheckVeronProx()
  local tNearVeron = {
    EventType = "ProximityEvent",
    ObjectA = self.hVeron,
    ObjectB = hSab,
    Proximity = 4,
    Negate = false,
    Check3D = true
  }
  self.VeronProx = Util.CreateEvent(tNearVeron, "Paris_6_Mission_1.ProtectedVeron", self)
  self:RegisterEvent(self.VeronProx)
end

function Paris_6_Mission_1:ProtectedVeron()
  if self.VFollow then
    Util.KillEvent(self.VFollow)
    self.VFollow = nil
  end
  if self.GateCrashTimer then
    Util.KillEvent(self.GateCrashTimer)
    self.GateCrashTimer = nil
  end
  Nav.FollowObject(self.hVeron, hSab, 2.75, true, true)
  local tEvent = {EventType = "TimerEvent", Time = 1.5}
  self.VeronFound = Util.CreateEvent(tEvent, "Paris_6_Mission_1.FoundVeron", self)
  self:RegisterEvent(self.VeronFound)
end

function Paris_6_Mission_1:FoundVeron()
  if self.VeronProx then
    Util.KillEvent(self.VeronProx)
    self.VeronProx = nil
  end
  Cin.PlayConversation("328a_Con_Vmeet")
  EVENT_Timer("Paris_6_Mission_1.PreVitCrash", self, 6, {})
  local hSpawner2 = Util.GetHandleByName("Missions\\paris_6\\mission_1\\execution\\NaziSpawner")
  local hSpawner3 = Util.GetHandleByName("Missions\\paris_6\\mission_1\\execution\\NaziSpawner2")
  Object.EnableSpawner(hSpawner2, true)
  Object.EnableSpawner(hSpawner3, true)
end

function Paris_6_Mission_1:VeronFollow()
  Nav.FollowObject(self.hVeron, hSab, 2.75, true, true)
end

function Paris_6_Mission_1:KillGate(a_hGate1, a_hGate2, bShakeTruck, bSputter)
  if a_hGate1 then
    Object.Kill(a_hGate1)
  end
  if a_hGate2 then
    Object.Kill(a_hGate2)
  end
  if bShakeTruck then
    local x, y, z = Object.GetPosition(self.hTrucky)
    Render.CameraShakeExplosion(x, y, z, 25, 30, 100)
  end
  if bSputter then
    self.hSoundSputter = Sound.AttachSoundEvent(self.hTrucky, "VEH_P3M1_Engine_01_Sputter_loop")
  end
end

function Paris_6_Mission_1:PreVitCrash()
  Util.SpawnEditNode("Missions\\paris_6\\mission_1\\carsnbombs.wsd")
  Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\paris_6\\mission_1\\carsnbombs\\BrymanDrives",
      "Missions\\paris_6\\mission_1\\carsnbombs\\VH_NZ_TR_OpelCanvas_01"
    }
  }, "Paris_6_Mission_1.PutBrymanInTruck", self)
end

function Paris_6_Mission_1:VitCrash()
  local hGate1 = Handle("PARIS\\borders\\area01toisland\\b\\OccLt_Border_VEHGate_LRG(10)\\OccLt_Border_VEHGate_Lrg_L")
  local hGate2 = Handle("PARIS\\borders\\area01toisland\\b\\OccLt_Border_VEHGate_LRG(10)\\OccLt_Border_VEHGate_Lrg_R")
  local tKillGateA = {
    EventType = "ProximityEvent",
    ObjectA = self.hTrucky,
    ObjectB = hGate1,
    Proximity = 10,
    Negate = false,
    Check3D = false
  }
  self.eKillGateA = Util.CreateEvent(tKillGateA, "Paris_6_Mission_1.KillGate", self, {hGate1, hGate2})
  self:RegisterEvent(self.eKillGateA)
  local hGateB1 = Handle("Missions\\paris_6\\mission_1\\prison_props\\Occ_SecFence_PedGate5m_DoorFrame(2)\\Occ_SecFence_PedGate5m_DoorAnim_L")
  local hGateB2 = Handle("Missions\\paris_6\\mission_1\\prison_props\\Occ_SecFence_PedGate5m_DoorFrame(2)\\Occ_SecFence_PedGate5m_DoorAnim_R")
  local tKillGateB = {
    EventType = "ProximityEvent",
    ObjectA = self.hTrucky,
    ObjectB = hGateB1,
    Proximity = 10,
    Negate = false,
    Check3D = false
  }
  self.eKillGateB = Util.CreateEvent(tKillGateB, "Paris_6_Mission_1.KillGate", self, {hGateB1, hGateB2})
  self:RegisterEvent(self.eKillGateB)
  Actor.OverrideCombatAI(self.hBryman, true)
  Combat.SetIgnoreCombatInVehicle(self.hBryman, true)
  Vehicle.LockSeat(self.hTrucky, "PILOT", true)
  Vehicle.LockSeat(self.hTrucky, "SHOTGUN", true)
  Actor.SetFacingDir(self.hVeron, hSab)
  Cin.PlayCinematic("P6M1_CIN_Enter_Vittorie", "Paris_6_Mission_1.TruckIsThere", self)
  EVENT_Timer("Paris_6_Mission_1.BrymanCrash", self, 1.5, {})
  Vehicle.ClearDeathCallback(self.hTrucky)
  Vehicle.SetDeathCallback(self.hTrucky, "Paris_6_Mission_1.TruckDeathVO", self)
  Paris_6_Mission_1.NodeLoadedFlag(self, "carsnbombs")
end

function Paris_6_Mission_1:BrymanCrash()
  Vehicle.StartPlayback(self.hTrucky, "P6M1_TruckEnter_14.vcr")
  Sound.PlayOwnerlessSoundEvent("prison_break_gate_crash_cameracut")
end

function Paris_6_Mission_1:CallbackTest()
end

function Paris_6_Mission_1:TruckIsThere()
  Cin.PlayConversation("P6M1_EnterVattorie", "Paris_6_Mission_1.ResistanceBoardCar", self)
end

function Paris_6_Mission_1:ResistanceBoardCar()
  local hVehicle = Util.GetHandleByName("Missions\\paris_6\\mission_1\\carsnbombs\\VH_NZ_TR_OpelCanvas_01")
  Actor.CancelAnimation(self.hVeron)
  Actor.OverrideCombatAI(self.hVeron, true)
  Nav.BoardVehicle(self.hVeron, hVehicle, "SHOTGUN", true, "Paris_6_Mission_1.FinalDash", self, nil)
end

function Paris_6_Mission_1:FinalDash()
  local hSpawner1, hSpawner2
  hSpawner1 = Util.GetHandleByName("Missions\\paris_6\\mission_1\\execution\\ResistanceSpawner")
  hSpawner2 = Util.GetHandleByName("Missions\\paris_6\\mission_1\\execution\\NaziSpawner")
  Object.EnableSpawner(hSpawner1, false)
  Object.EnableSpawner(hSpawner2, false)
  self:CompleteTaskByName("ProtectHer")
  self.IsInGunnerSeat(self)
  self.ManTheGunLol(self)
end

function Paris_6_Mission_1:ManTheGunLol()
  if self.VerProtectID then
    HUD.RemoveObjective(self.VerProtectID)
    self.VerProtectID = nil
  end
  local hTruckGun = Handle("Missions\\paris_6\\mission_1\\missionobjective\\Loc_TruckGun")
  self:CreateTask({
    sName = "FakeManGun",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tLocators = {hTruckGun},
    sObjectiveTextID = "P6M1_Text.ManTheGun"
  })
end

function Paris_6_Mission_1:IsInGunnerSeat()
  if Actor.GetVehicle(hSab) == Actor.GetVehicle(self.hBryman) then
    Paris_6_Mission_1.DoubleCheckGunner(self)
  else
    local hTruck = Util.GetHandleByName("Missions\\paris_6\\mission_1\\carsnbombs\\VH_NZ_TR_OpelCanvas_01")
    local tSeanGunnerEvent = {
      EventType = "EnteredVehicleEvent",
      EventName = "SeanGunnerEvent",
      ObjectHandle = hSab,
      VehicleHandle = hTruck
    }
    self.SeanGunnerEvent = Util.CreateEvent(tSeanGunnerEvent, "Paris_6_Mission_1.DoubleCheckGunner", self)
    self:RegisterEvent(self.SeanGunnerEvent)
  end
end

function Paris_6_Mission_1:DoubleCheckGunner()
  if Actor.GetVehicle(hSab) == Actor.GetVehicle(self.hBryman) then
    EVENT_Timer("Paris_6_Mission_1.TripleCheckGunner", self, 3, {})
  else
    EVENT_Timer("Paris_6_Mission_1.IsInGunnerSeat", self, 1, {})
  end
end

function Paris_6_Mission_1:TripleCheckGunner()
  if Actor.GetVehicle(hSab) == Actor.GetVehicle(self.hVeron) then
    Paris_6_Mission_1.SetRailCheckpoint(self)
  else
    EVENT_Timer("Paris_6_Mission_1.IsInGunnerSeat", self, 1, {})
  end
end

function Paris_6_Mission_1:SetRailCheckpoint()
  Suspicion.EnableEspritDeCorps(false)
  Util.SpawnEditNode("Missions\\paris_6\\mission_1\\nazi_pursuit_dynamic.wsd")
  Actor.SetCannotGetOutOfSeat(hSab, true)
  if self.SeanGunnerEvent then
    Util.KillEvent(self.SeanGunnerEvent)
    self.SeanGunnerEvent = nil
  end
  Trigger.DoNotWaitFor("Missions\\paris_6\\mission_1\\missionobjective\\PT_LeftVeronTaDie", hSab)
  Trigger.Enable("Missions\\paris_6\\mission_1\\missionobjective\\PT_LeftVeronTaDie", false)
  Vehicle.ClearDeathCallback(self.hTrucky)
  self:CompleteTaskByName("FakeManGun")
  self.RegisterCheckpoint(self, "Paris_6_Mission_1.RailCheckpoint")
end

function Paris_6_Mission_1:RailCheckpoint()
  Sound.SetMusicLocale("P6M1_PrisonBreak")
  Sound.SetMusicLocale("m_P6M1_PrisonBreak", "P6M1_HighAction")
  self.hBryman = Handle("Missions\\paris_6\\mission_1\\carsnbombs\\BrymanDrives")
  self.hVeron = Handle("Missions\\paris_6\\mission_1\\execution\\victim7")
  Object.SetInvincible(self.hBryman, true)
  Object.SetInvincible(self.hVeron, true)
  self.eVO15Min = Trigger.WaitFor("Missions\\paris_6\\mission_1\\conversation_node\\PT_VO1_5_min", hSab, "Paris_6_Mission_1.VO15MinIn", self, {}, cTRIGGEREVENT_ONENTER)
  self:RegisterTriggerEvent(self.eVO15Min, "Missions\\paris_6\\mission_1\\conversation_node\\PT_VO1_5_min")
  Actor.SetCannotGetOutOfSeat(self.hBryman, true)
  Actor.SetCannotGetOutOfSeat(hSab, true)
  Actor.SetCannotGetOutOfSeat(self.hVeron, true)
  Vehicle.EnableTraffic(false, true)
  local hVehicle = Util.GetHandleByName("Missions\\paris_6\\mission_1\\carsnbombs\\VH_NZ_TR_OpelCanvas_01")
  if not Actor.GetVehicle(hSab) == Actor.GetVehicle(self.hBryman) then
    Actor.BoardVehicle(hSab, hVehicle, "GUNNER")
  end
  Object.SetHealth(hVehicle, 7700)
  Util.SpawnEditNode("Missions\\paris_6\\mission_1\\scriptedsequences\\tankevent.wsd")
  Vehicle.SetTakeDamageInCinematic(hVehicle, true)
  local hGateC1 = Handle("Missions\\paris_6\\mission_1\\prison_props\\Occ_SecFence_PedGate5m_DoorFrame(4)\\Occ_SecFence_PedGate5m_DoorAnim_L")
  local hGateC2 = Handle("Missions\\paris_6\\mission_1\\prison_props\\Occ_SecFence_PedGate5m_DoorFrame(4)\\Occ_SecFence_PedGate5m_DoorAnim_R")
  local tKillGateC = {
    EventType = "ProximityEvent",
    ObjectA = self.hTrucky,
    ObjectB = hGateC1,
    Proximity = 8,
    Negate = false,
    Check3D = false
  }
  self.eKillGateC = Util.CreateEvent(tKillGateC, "Paris_6_Mission_1.KillGate", self, {
    hGateC1,
    hGateC2,
    true
  })
  self:RegisterEvent(self.eKillGateC)
  local hGateD1 = Handle("PARIS\\borders\\area03toisland\\b\\OccLt_Border_VEHGate_LRG(10)\\OccLt_Border_VEHGate_Lrg_L")
  local hGateD2 = Handle("PARIS\\borders\\area03toisland\\b\\OccLt_Border_VEHGate_LRG(10)\\OccLt_Border_VEHGate_Lrg_R")
  local tKillGateD = {
    EventType = "ProximityEvent",
    ObjectA = self.hTrucky,
    ObjectB = hGateD1,
    Proximity = 10,
    Negate = false,
    Check3D = false
  }
  self.eKillGateD = Util.CreateEvent(tKillGateD, "Paris_6_Mission_1.KillGate", self, {
    hGateD1,
    hGateD2,
    true
  })
  self:RegisterEvent(self.eKillGateD)
  local hGateE1 = Handle("PARIS\\borders\\area03toisland\\b\\OccLt_Border_VEHGate_LRG(11)\\OccLt_Border_VEHGate_Lrg_L")
  local hGateE2 = Handle("PARIS\\borders\\area03toisland\\b\\OccLt_Border_VEHGate_LRG(11)\\OccLt_Border_VEHGate_Lrg_R")
  local tKillGateE = {
    EventType = "ProximityEvent",
    ObjectA = self.hTrucky,
    ObjectB = hGateE1,
    Proximity = 10,
    Negate = false,
    Check3D = false
  }
  self.eKillGateE = Util.CreateEvent(tKillGateE, "Paris_6_Mission_1.KillGate", self, {
    hGateE1,
    hGateE2,
    true
  })
  self:RegisterEvent(self.eKillGateE)
  Combat.GlobalAllowGrenades(false)
  self.Task_GetToSafety(self)
  self.Escape(self)
end

function Paris_6_Mission_1:Escape()
  local hTest = Util.GetHandleByName("Missions\\paris_6\\mission_1\\scripted_attack\\PT_SpawnBlockers")
  if hTest then
  end
  self.eSpawnBlock = Trigger.WaitFor("Missions\\paris_6\\mission_1\\scripted_attack\\PT_SpawnBlockers", hSab, "Paris_6_Mission_1.SpawnRoadblockers", self, nil, cTRIGGEREVENT_ONENTER)
  self:RegisterTriggerEvent(self.eSpawnBlock, "Missions\\paris_6\\mission_1\\scripted_attack\\PT_SpawnBlockers")
  self.eCTPlanes = Trigger.WaitFor("Missions\\paris_6\\mission_1\\scriptedsequences\\chinatownplanes\\PT_ChinaTownPlanes", hSab, "Paris_6_Mission_1.HearCTownPlane", self, nil, cTRIGGEREVENT_ONENTER)
  self:RegisterTriggerEvent(self.eCTPlanes, "Missions\\paris_6\\mission_1\\scriptedsequences\\chinatownplanes\\PT_ChinaTownPlanes")
  self.eStallSound = Trigger.WaitFor("Missions\\paris_6\\mission_1\\scriptedsequences\\chinatownplanes\\PT_StartStallSound", hSab, "Paris_6_Mission_1.TruckStalls", self, nil, cTRIGGEREVENT_ONENTER)
  self:RegisterTriggerEvent(self.eStallSound, "Missions\\paris_6\\mission_1\\scriptedsequences\\chinatownplanes\\PT_StartStallSound")
  self.eVORoadblock = Trigger.WaitFor("Missions\\paris_6\\mission_1\\scripted_attack\\PT_EndCNtown", hSab, "Paris_6_Mission_1.RoadblockVO", self, nil, cTRIGGEREVENT_ONENTER)
  self:RegisterTriggerEvent(self.eVORoadblock, "Missions\\paris_6\\mission_1\\scripted_attack\\PT_EndCNtown")
  self.e30SecInVO = Trigger.WaitFor("Missions\\paris_6\\mission_1\\conversation_node\\PT_VO30secIn", hSab, "Paris_6_Mission_1.Play30secondsVO", self, nil, cTRIGGEREVENT_ONENTER)
  self:RegisterTriggerEvent(self.e30SecInVO, "Missions\\paris_6\\mission_1\\conversation_node\\PT_VO30secIn")
  EVENT_Timer("Paris_6_Mission_1.DriveAwayVO", self, 1, {})
  Cin.PlayCinematic("P6M1_RailShoot_1", "Paris_6_Mission_1.RailCNtown", self)
end

function Paris_6_Mission_1:DriveAwayVO()
  Cin.PlayConversation("P6M1_DriveAway")
end

function Paris_6_Mission_1:RoadblockVO()
  Cin.PlayConversation("P6M1_TrafficJam_Start")
end

function Paris_6_Mission_1:OnIt()
  Cin.PlayConversation("P6M1_TrafficJam_OnIt")
end

function Paris_6_Mission_1:SpawnRoadblockers()
  Util.SpawnEditNode("Missions\\paris_6\\mission_1\\scriptedsequences\\truckcollision.wsd", "Paris_6_Mission_1.NodeLoadedFlag", self, {
    "truckcollision"
  })
end

function Paris_6_Mission_1:RoadBlockKiller()
  local hSpawner = Util.GetHandleByName("Missions\\paris_6\\mission_1\\scriptedsequences\\truckcollision\\NaziSpawner_RoadBlock_K")
  Object.EnableSpawner(hSpawner, true)
end

function Paris_6_Mission_1:RailCNtown()
  Cin.PlayConversation("P6M1_TrafficJam_OnIt")
  EVENT_Timer("Paris_6_Mission_1.RoadBlockKiller", self, 40, {})
  local tRoadblockers = {
    Handle("Missions\\paris_6\\mission_1\\scriptedsequences\\truckcollision\\Roadblock1"),
    Handle("Missions\\paris_6\\mission_1\\scriptedsequences\\truckcollision\\Roadblock2"),
    Handle("Missions\\paris_6\\mission_1\\scriptedsequences\\truckcollision\\Roadblock3")
  }
  if 0 < #tRoadblockers then
    self:CreateTask({
      sName = "ShootRoadblock",
      sTaskType = "SabTaskObjectiveDestroy",
      sTaskSubType = "KILL",
      tTgtInclude = tRoadblockers,
      sObjectiveTextID = "P6M1_Text.DestroyRoadblock",
      tOnComplete = {
        {
          self.DriveToPlanes,
          {self}
        }
      }
    })
  else
    self.DriveToPlanes(self)
  end
end

function Paris_6_Mission_1:Play30secondsVO()
  Cin.PlayConversation("P6M1_30SecondsIntoDrive")
  Freeplay.UnloadAmbientFreeplay(true)
end

function Paris_6_Mission_1:VO15MinIn()
  Cin.PlayConversation("P6M1_1_5_MinuteIntoDrive")
end

function Paris_6_Mission_1:DriveToPlanes()
  self.eRailsEnd = Trigger.WaitFor("Missions\\paris_6\\mission_1\\scriptedsequences\\truckcollision\\PT_NearRailsEnd", hSab, "Paris_6_Mission_1.RailsEndEquip", self, nil, cTRIGGEREVENT_ONENTER)
  self:RegisterTriggerEvent(self.eRailsEnd, "Missions\\paris_6\\mission_1\\scriptedsequences\\truckcollision\\PT_NearRailsEnd")
  local hSpawner1 = Util.GetHandleByName("Missions\\paris_6\\mission_1\\scriptedsequences\\truckcollision\\NaziSpawner_RoadBlock_L")
  local hSpawner2 = Util.GetHandleByName("Missions\\paris_6\\mission_1\\scriptedsequences\\truckcollision\\NaziSpawner_RoadBlock_R")
  local hSpawner3 = Util.GetHandleByName("Missions\\paris_6\\mission_1\\scriptedsequences\\truckcollision\\NaziSpawner_RoadBlock_K")
  Object.EnableSpawner(hSpawner1, false)
  Object.EnableSpawner(hSpawner2, false)
  Object.EnableSpawner(hSpawner3, false)
  EVENT_Timer("Paris_6_Mission_1.DriveThroughVO", self, 2)
  EVENT_Timer("Paris_6_Mission_1.DriveReverse", self, 2)
  self.eBombers = Trigger.WaitFor("Missions\\paris_6\\mission_1\\scriptedsequences\\chinatownplanes\\PT_StartBombers", hSab, "Paris_6_Mission_1.OutskirtBombing", self, nil, cTRIGGEREVENT_ONENTER)
  self:RegisterTriggerEvent(self.eBombers, "Missions\\paris_6\\mission_1\\scriptedsequences\\chinatownplanes\\PT_StartBombers")
end

function Paris_6_Mission_1:DriveThroughVO()
  Cin.PlayConversation("P6M1_TrafficJam_Complete")
end

function Paris_6_Mission_1:DriveReverse()
  Cin.PlayCinematic("P6M1_RailShoot_2", "Paris_6_Mission_1.DriveToStall", self)
end

function Paris_6_Mission_1:DriveToStall()
  Cin.PlayCinematic("P6M1_RailShoot_3", "Paris_6_Mission_1.StopStallSound", self)
end

function Paris_6_Mission_1:Task_GetToSafety()
  Suspicion.SetEscalationLevel(3)
  Suspicion.SetEscalationCap(4)
  self:CreateTask({
    sName = "GetToSafety",
    sTaskType = "SabTaskObjectiveDestroy",
    sDestroyType = "DEFEND",
    sTaskSubType = "DEFEND",
    sObjectiveTextID = "GenericObjective_Text.DEFEND_Truck",
    tTgtInclude = {
      "Missions\\paris_6\\mission_1\\carsnbombs\\VH_NZ_TR_OpelCanvas_01"
    },
    tSMEDNodes = {
      "Missions\\paris_6\\mission_1\\rail_shooter_nazisonstreet"
    },
    tOnComplete = {},
    tOnFailure = {
      {
        self.TruckDeathVO,
        {self}
      }
    }
  })
  self.TempObjectiveID = HUD.AddObjective(eOT_HEART, SabTask:GetLocalizedText("GenericObjective_Text.BAR_Health_Truck"), 2, nil)
  HUD.SetupProgressBar(self.TempObjectiveID, Handle("missions\\paris_6\\mission_1\\carsnbombs\\VH_NZ_TR_OpelCanvas_01"))
end

function Paris_6_Mission_1:RailsEndEquip()
  local hNaziLabel = Filter.New("Human && Nazi")
  local tWho = Trigger.GetAllWithin(Util.GetHandleByName("Missions\\paris_6\\mission_1\\scriptedsequences\\truckcollision\\PT_StopNZ4RailEnd"), hNaziLabel)
  if tWho then
    for i, v in ipairs(tWho) do
      Object.Kill(v)
    end
  end
  Filter.Delete(hNaziLabel)
end

function Paris_6_Mission_1:RemoveEscalation()
  Suspicion.SetEscalationLevel(0)
  Suspicion.SetEscalationCap(-1)
end

function Paris_6_Mission_1:TruckDeathVO()
  Cin.PlayConversation("P6M1_TruckDamage_Destroyed", "Paris_6_Mission_1.Failure", self)
end

function Paris_6_Mission_1.ExplodyTankShots()
  local hTruck1 = Util.GetHandleByName("Missions\\paris_6\\mission_1\\scriptedsequences\\tankevent\\truck")
  local hTruck2 = Util.GetHandleByName("Missions\\paris_6\\mission_1\\scriptedsequences\\tankevent\\truck2")
  local hExpLoc = Util.GetHandleByName("Missions\\paris_6\\mission_1\\scriptedsequences\\tankevent\\Locator")
  Render.StartFX(hTruck1, "0FX_Zep_Fire01_Trail", nil)
  Render.StartFX(hTruck2, "0FX_Zep_Fire01_Trail", nil)
  local x, y, z
  x, y, z = Object.GetPosition(hExpLoc)
  Util.CreateExplosion("Explosion_Large_Truck", x, y, z)
end

function Paris_6_Mission_1.TankRocketShot()
  local sStart = Util.GetHandleByName("Missions\\paris_6\\mission_1\\scriptedsequences\\tankevent\\rocketspawn")
  local sEnd = Util.GetHandleByName("Missions\\paris_6\\mission_1\\scriptedsequences\\tankevent\\rockettarget")
  local x, y, z = Object.GetPosition(sStart)
  local X, Y, Z = Object.GetPosition(sEnd)
  Util.SpawnRocket("SmallRocket", x, y, z, X, Y, Z)
end

function Paris_6_Mission_1:HearCTownPlane()
  Util.AddSplinePlaneAttackObject("Missions\\paris_6\\mission_1\\scriptedsequences\\chinatownplanes\\plane1spline", 9, false, hSab)
  EVENT_Timer("Paris_6_Mission_1.PlaneAttackSpline", self, 6, {})
end

function Paris_6_Mission_1:PlaneAttackSpline()
  Util.AddSplinePlaneAttackObject("Missions\\paris_6\\mission_1\\scriptedsequences\\chinatownplanes\\plane3attackspline", 90, false, hSab)
end

function Paris_6_Mission_1:TruckStalls()
  local hGateF1 = Handle("PARIS\\borders\\area03tocountry\\CheckpointCountry(b)\\Gate_1")
  local hGateF2 = Handle("PARIS\\borders\\area03tocountry\\CheckpointCountry(b)\\Gate_2")
  local tKillGateF = {
    EventType = "ProximityEvent",
    ObjectA = self.hTrucky,
    ObjectB = hGateF1,
    Proximity = 8,
    Negate = false,
    Check3D = false
  }
  self.eKillGateF = Util.CreateEvent(tKillGateF, "Paris_6_Mission_1.KillGate", self, {
    hGateF1,
    hGateF2,
    true,
    true
  })
  self:RegisterEvent(self.eKillGateF)
end

function Paris_6_Mission_1:StopStallSound()
  Sound.StopSoundEvent(self.hTrucky, self.hSoundSputter)
  EVENT_Timer("Paris_6_Mission_1.StartGrindSound", self, 1, {})
  EVENT_Timer("Paris_6_Mission_1.StopGrindSound", self, 5, {})
  EVENT_Timer("Paris_6_Mission_1.StartFixSound", self, 10, {})
  EVENT_Timer("Paris_6_Mission_1.StartRunningSound", self, 14, {})
  EVENT_Timer("Paris_6_Mission_1.DriveToEnd", self, 15, {})
end

function Paris_6_Mission_1:OutskirtBombing()
  EVENT_Timer("Paris_6_Mission_1.WarningBomb", self, 10, {})
  EVENT_Timer("Paris_6_Mission_1.UTurnBomb", self, 4, {})
end

function Paris_6_Mission_1:StartGrindSound()
  self.hSoundGrind = Sound.AttachSoundEvent(self.hTrucky, "VEH_P3M1_Engine_03_Grinding")
end

function Paris_6_Mission_1:StopGrindSound()
  Sound.StopSoundEvent(self.hTrucky, self.hSoundGrind)
end

function Paris_6_Mission_1:StartFixSound()
  Sound.AttachSoundEvent(self.hTrucky, "VEH_P3M1_Engine_02_Fixing")
end

function Paris_6_Mission_1:StartRunningSound()
  Sound.AttachSoundEvent(self.hTrucky, "VEH_P3M1_Engine_04_Startup")
end

function Paris_6_Mission_1.PlaneBombingRunFirstPlane()
  Util.AddSplinePlaneAttackObject("Missions\\paris_6\\mission_1\\scripted_attack\\BOMBING_Plane_Chinatown", 70, true, hSab)
end

function Paris_6_Mission_1.PlaneBombingRunSecondPlane()
  Util.AddSplinePlaneAttackObject("Missions\\paris_6\\mission_1\\scriptedsequences\\chinatownplanes\\plane3attackspline", 70, false, hSab)
end

function Paris_6_Mission_1.PlaneBombingRunThirdPlane()
  Util.AddSplinePlaneAttackObject("Missions\\paris_6\\mission_1\\scriptedsequences\\chinatownplanes\\plane3attackspline", 70, false, hSab)
end

function Paris_6_Mission_1.TruckCollideExplosion()
  local hExpLoc = Util.GetHandleByName("Missions\\paris_6\\mission_1\\scriptedsequences\\Truckcollision\\Locator")
  local x, y, z = Object.GetPosition(hExpLoc)
  Util.CreateExplosion("Explosion_Sab_DynamiteFuse", x, y, z)
  Render.StartFX(hTruck1, "0FX_Zep_Fire01_Trail", nil)
  Render.StartFX(hTruck2, "0FX_Zep_Fire01_Trail", nil)
end

function Paris_6_Mission_1:WarningBomb()
  Util.AddSplinePlaneAttackObject("Missions\\paris_6\\mission_1\\scriptedsequences\\chinatownplanes\\Spline_WarnBomb", 90, false, hSab)
  EVENT_Timer("Paris_6_Mission_1.SpaceOutPlane2", self, 11, {})
end

function Paris_6_Mission_1:SpaceOutPlane2()
  Util.AddSplinePlaneAttackObject("Missions\\paris_6\\mission_1\\scriptedsequences\\chinatownplanes\\Spline_WarnBomb_2", 90, false, hSab)
end

function Paris_6_Mission_1:SpaceOutPlane4()
  Util.AddSplinePlaneAttackObject("Missions\\paris_6\\mission_1\\scriptedsequences\\chinatownplanes\\Spline_UturnBomb_2", 70, false, hSab)
end

function Paris_6_Mission_1:UTurnBomb()
  Cin.PlayConversation("P6M1_2_MinuteIntoDrive")
  EVENT_Timer("Paris_6_Mission_1.SpaceOutPlane4", self, 9, {})
  Util.AddSplinePlaneAttackObject("Missions\\paris_6\\mission_1\\scriptedsequences\\chinatownplanes\\Spline_UturnBomb", 70, false, hSab)
end

function Paris_6_Mission_1:DriveToEnd()
  local hTrucky = Util.GetHandleByName("Missions\\paris_6\\mission_1\\carsnbombs\\VH_NZ_TR_OpelCanvas_01")
  Cin.PlayCinematic("P6M1_RailShoot_4", "Paris_6_Mission_1.MissionComplete", self)
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_6\\mission_1\\scriptedsequences\\chinatownplanes\\PT_FerrisPlane", hSab, "Paris_6_Mission_1.FerrisPlane", self, nil, cTRIGGEREVENT_ONENTER), "Missions\\paris_6\\mission_1\\scriptedsequences\\chinatownplanes\\PT_FerrisPlane")
  local tEvent = {EventType = "TimerEvent", Time = 20}
  self.eShutItVO = Util.CreateEvent(tEvent, "Paris_6_Mission_1.ShutUpNDriveVo", self)
  self:RegisterEvent(self.eShutItVO)
end

function Paris_6_Mission_1:ShutUpNDriveVo()
  Cin.PlayConversation("P6M1_TruckDamage_Medium")
end

function Paris_6_Mission_1:FerrisPlane()
  Util.AddSplinePlaneAttackObject("Missions\\paris_6\\mission_1\\scriptedsequences\\chinatownplanes\\Spline_FerrisPlane", 80, false, hSab)
end

function Paris_6_Mission_1.Truck_Ramp_Explode()
  local hTruck1 = Util.GetHandleByName("Missions\\paris_6\\mission_1\\scripted_attack\\truck_Ramp")
  local x, y, z = Object.GetPosition(hTruck1)
  Util.CreateExplosion("Explosion_Large_Shell", x, y, z)
end

function Paris_6_Mission_1.Truck_Ramp_CatchFire()
  local hTruck1 = Util.GetHandleByName("Missions\\paris_6\\mission_1\\scripted_attack\\truck_Ramp")
  Render.StartFX(hTruck1, "0FX_Zep_Fire01_Trail", nil)
end

function Paris_6_Mission_1:MissionComplete()
  if self.TempObjectiveID then
    HUD.RemoveObjective(self.TempObjectiveID)
    self.TempObjectiveID = nil
  end
  self:CompleteTaskByName("GetToSafety")
  Actor.SetCannotGetOutOfSeat(hSab, false)
  Actor.UnboardVehicle(self.hVeron)
  Actor.UnboardVehicle(hSab)
  Sound.ReleaseSoundBank("m_P6M1_inGame.bnk")
  Suspicion.EnableEscalation(true)
  Suspicion.ResetEscalation()
  EVENT_Timer("Paris_6_Mission_1.FadeOut", self, 2, {})
end

function Paris_6_Mission_1:FadeOut()
  Util.UnloadEditNode("Missions\\paris_6\\mission_1\\execution.wsd", true, false)
  Util.SpawnEditNode("Missions\\paris_6\\mission_1\\VeroniqueCarConnect.wsd", "Paris_6_Mission_1.NowSayThanks", self)
end

function Paris_6_Mission_1:NowSayThanks()
  Object.PlayerTeleportToLocator(Util.GetHandleByName("Missions\\paris_6\\mission_1\\dynamictriggers\\Loc_BrymanThxzVero"), "Paris_6_Mission_1.SeanPorted", self)
end

function Paris_6_Mission_1:SeanPorted()
  local hVeron = Handle("Missions\\paris_6\\mission_1\\VeroniqueCarConnect\\Veronique_P6M1B")
  Cin.PlayConversation("P6M1_Arrive_HidingSpot", "Paris_6_Mission_1.WaitComplete", self, {})
end

function Paris_6_Mission_1:BrymanDrivesAway()
  Cin.PlayCinematic("P6M1_RailShoot_over")
end

function Paris_6_Mission_1:WaitComplete()
  Paris_6_Mission_1.BrymanDrivesAway(self)
  self.P6M1Cleanup(self)
  self:CompleteThisMission()
end

function Paris_6_Mission_1:NodeLoadedFlag(sNodeLoaded)
  if sNodeLoaded == "carsnbombs" then
    self.bCarsnbombsLoaded = true
  elseif sNodeLoaded == "truckcollision" then
    self.bTruckcollisionLoaded = true
    local hSpawner1 = Util.GetHandleByName("Missions\\paris_6\\mission_1\\scriptedsequences\\truckcollision\\NaziSpawner_RoadBlock_L")
    local hSpawner2 = Util.GetHandleByName("Missions\\paris_6\\mission_1\\scriptedsequences\\truckcollision\\NaziSpawner_RoadBlock_R")
    Object.EnableSpawner(hSpawner1, true)
    Object.EnableSpawner(hSpawner2, true)
  elseif sNodeLoaded == "zepnazis" then
    self.bZepnazisLoaded = true
  elseif sNodeLoaded == "execution" then
    self.bExecutionLoaded = true
  end
end

function Paris_6_Mission_1:P6M1Cleanup()
  Actor.SetCannotGetOutOfSeat(hSab, false)
  local hBryman = Handle("Missions\\paris_6\\mission_1\\carsnbombs\\BrymanDrives")
  local hVeron = Handle("Missions\\paris_6\\mission_1\\execution\\victim7")
  if hBryman then
    Object.SetInvincible(self.hBryman, false)
  end
  if hVeron then
    Object.SetInvincible(self.hVeron, false)
  end
  if self.hTrucky then
    Vehicle.ClearDeathCallback(self.hTrucky)
  end
  if self.TempObjectiveID then
    HUD.RemoveObjective(self.TempObjectiveID)
    self.TempObjectiveID = nil
  end
  Util.UnloadEditNode("Missions\\paris_6\\mission_1\\PrisonOutbreak.wsd", true, false)
  Util.UnloadEditNode("Missions\\paris_6\\mission_1\\scriptedsequences\\tankevent.wsd", true, false)
  if self.bCarsnbombsLoaded == true then
    Util.UnloadEditNode("Missions\\paris_6\\mission_1\\carsnbombs.wsd", false, false)
    self.bCarsnbombsLoaded = nil
  end
  if self.bTruckcollisionLoaded == true then
    Util.UnloadEditNode("Missions\\paris_6\\mission_1\\scriptedsequences\\truckcollision.wsd", false, false)
    self.bTruckcollisionLoaded = nil
  end
  Util.UnloadEditNode("Missions\\paris_6\\mission_1\\nazi_pursuit_dynamic.wsd", true, false)
  if self.bZepnazisLoaded == true then
    Util.UnloadEditNode("Missions\\paris_6\\mission_1\\zepnazis.wsd", true, false)
    self.bZepnazisLoaded = nil
  end
  Util.UnloadEditNode("Missions\\paris_6\\mission_1\\axeman.wsd", true, false)
  Freeplay.UnloadAmbientFreeplay(false)
  Suspicion.SetEscalationLevel(0)
  Suspicion.SetEscalationCap(-1)
  Combat.GlobalAllowGrenades(true)
  Sound.ResetMusicLocale()
  Suspicion.EnableEspritDeCorps(true)
  Vehicle.EnableTraffic(true, false)
end

function Paris_6_Mission_1:MISSION_ONCANCEL()
  if self.bExecutionLoaded then
    Util.UnloadEditNode("Missions\\paris_6\\mission_1\\execution.wsd", true, false)
  end
  Zone.SwitchState("WtF_Zones\\global\\P6M1_PrisonBreak", cZONESTATE_LOWWTF, cENT_IMMEDIATE)
  Paris_6_Mission_1.P6M1Cleanup(self)
end

function Paris_6_Mission_1:Failure()
  if self.TempObjectiveID then
    HUD.RemoveObjective(self.TempObjectiveID)
    self.TempObjectiveID = nil
  end
  EVENT_Timer("Paris_6_Mission_1.WaitOneSecFail", self, 1)
end

function Paris_6_Mission_1:WaitOneSecFail()
  self:MissionTaskFail("GenericFail_Text.DESTROYED_Truck_The")
end
