if Act_3_TimeTrial == nil then
  Act_3_TimeTrial = SabTaskObjective:Create()
  gsAct3Mission1Dir = "Missions\\Act_3\\Mission_1\\"
  Act_3_TimeTrial:Configure({
    TaskCount = 50,
    sAreaID = "ACT_3",
    bStarterless = true,
    sSaveMissionNameID = "MissionNames_Text.A3M1",
    tSMEDNodes = {
      gsAct3Mission1Dir .. "main",
      gsAct3Mission1Dir .. "roadnodereplace"
    },
    WTFZoneHigh = "WtF_Zones\\global\\A3M2_DierkerShowdown"
  })
end

function Act_3_TimeTrial:STARTER_Setup()
  self.bDebugPreserveMission = true
  Suspicion.EnableEscalation(false)
end

function Act_3_TimeTrial:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.RaceSetup(self)
end

function Act_3_TimeTrial:GENERAL_Setup()
  self.DEBUGMODE = true
  self.iLap = 1
  self.iSabPlace = 30
end

function Act_3_TimeTrial:RaceSetup()
  Util.UnloadStaticENTag("GrandPrixRemove", true)
  Vehicle.SetupRace("ParisGrandPrix", "FinishLine", 2, -1, 32)
  self:StartRace()
end

function Act_3_TimeTrial:LapCheck()
  if self.iLap == 1 then
    self.Task_Checkpoint1(self)
    self.iLap = self.iLap + 1
  else
    self.TASK_FinishLine(self)
  end
end

function Act_3_TimeTrial:LapIncrement()
  if self.iLap == 1 then
  end
end

function Act_3_TimeTrial:TASK_FinishLine()
  self:CreateTask({
    sName = "FinishLine",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint1,
    tDeliverObjs = {hSab},
    bNoWorldBlip = true,
    WTFZoneHigh = "WtF_Zones\\global\\A3M1_ParisRace",
    tOnActivate = {},
    tOnComplete = {
      {
        self.WinIT,
        {self}
      }
    }
  })
end

function Act_3_TimeTrial:Task_PlayFinishCin()
  self:CreateTask({
    sName = "Task_PlayFinishCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "333_CinA_RaceBoom",
    tOnActivate = {},
    tOnComplete = {
      {
        self.MissionComplete,
        {self}
      }
    }
  })
end

function Act_3_TimeTrial:WinIT()
end

function Act_3_TimeTrial:StartRace()
  Vehicle.SetRacing(true, true, cRH_None)
  Act_3_TimeTrial.Task_Checkpoint2(self)
end

function Act_3_TimeTrial:MissionComplete()
  CompleteCurrentMission()
end

function Act_3_TimeTrial:Cleanup()
  Sound.ResetMusicLocale()
  Util.UnloadStaticENTag("GrandPrix", false)
  Util.UnloadStaticENTag("GrandPrix_B", false)
  Util.LoadStaticENTag("GrandPrixRemove", false)
  Util.LoadStaticENTag("PrisonBreakRemove", false)
  Util.LoadStaticENTag("IslandRestrictedArea", false)
  Util.LoadStaticENTag("fp_amb_p1_snipernest_51", false)
  SetDisableControl("EnterExitVehicle", false)
  Vehicle.SetRacing(false)
  Suspicion.EnableEscalation(true)
  Util.EnableGooseSteppers(true)
  Vehicle.EnableTraffic(true)
  Util.EnableSuperSpores(true)
  Freeplay.DisableAmbientFreeplay(false)
end

function Act_3_TimeTrial:Delay(a_sCallback, a_Delay, a_tArgs)
  self:PrintDebug(a_sCallback)
  local e = Util.CreateEvent({EventType = "TimerEvent", Time = a_Delay}, a_sCallback, self, {a_tArgs})
  self:AddEvent(e)
end

function Act_3_TimeTrial:ConvPlayer(a_sConvFile, a_Delay)
  self:PrintDebug(a_sConvFile)
  local e = Util.CreateEvent({EventType = "TimerEvent", Time = a_Delay}, "Act_3_TimeTrial.ConvPlayerDelay", self, {a_sConvFile})
end

function Act_3_TimeTrial:ConvPlayerHack(JUNK, a_sConvFile, a_Delay)
  self:PrintDebug(a_sConvFile)
  local e = Util.CreateEvent({EventType = "TimerEvent", Time = a_Delay}, "Act_3_TimeTrial.ConvPlayerDelay", self, {a_sConvFile})
end

function Act_3_TimeTrial:ConvPlayerDelay(a_sConvFile)
  self:PrintDebug(a_sConvFile)
  Cin.PlayConversation(a_sConvFile)
end

function Act_3_TimeTrial:CueConvPlayer(JUNK, a_sConvFile, a_sConvFile2, a_Delay)
  self:PrintDebug(a_sConvFile)
  self:PrintDebug(a_sConvFile2)
  Cin.PlayConversation(a_sConvFile, "Act_3_TimeTrial.ConvPlayerHack", self, {a_sConvFile2, a_Delay})
end

function Act_3_TimeTrial:HACKCueConvPlayer3(a_sConvFile, a_sConvFile2, a_sConvFile3, a_Delay)
  self:PrintDebug(a_sConvFile)
  self:PrintDebug(a_sConvFile2)
  self:PrintDebug(a_sConvFile3)
  Cin.PlayConversation(a_sConvFile, "Act_3_TimeTrial.CueConvPlayer", self, {
    a_sConvFile2,
    a_sConvFile3,
    a_Delay
  })
end

function Act_3_TimeTrial:AddEvent(a_eEvent)
  if not self.tEvents then
    self.tEvents = {}
  end
  table.insert(self.tEvents, a_eEvent)
end

function Act_3_TimeTrial:PrintDebug(a_sMessage)
  if self.DEBUGMODE == true then
    Render.PrintMessage(a_sMessage)
  end
end

function Act_3_TimeTrial:WtFHack()
  for i, v in ipairs(self.tWtFHack) do
    Zone.SwitchState(v, cZONESTATE_HIGHWTF, cENT_NOCHANGE)
  end
end

function Act_3_TimeTrial:Task_Checkpoint1()
  self:CreateTask({
    sName = "Checkpoint1.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint1,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint2,
        {self}
      }
    }
  })
end

function Act_3_TimeTrial:Task_Checkpoint2()
  self:CreateTask({
    sName = "Checkpoint2.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint2,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint3,
        {self}
      }
    }
  })
end

function Act_3_TimeTrial:Task_Checkpoint3()
  self:CreateTask({
    sName = "Checkpoint3.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint3,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint4,
        {self}
      }
    }
  })
end

function Act_3_TimeTrial:Task_Checkpoint4()
  self:CreateTask({
    sName = "Checkpoint4.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint4,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint5,
        {self}
      }
    }
  })
end

function Act_3_TimeTrial:Task_Checkpoint5()
  self:CreateTask({
    sName = "Checkpoint5.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint5,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint6,
        {self}
      }
    }
  })
end

function Act_3_TimeTrial:Task_Checkpoint6()
  self:CreateTask({
    sName = "Checkpoint6.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint6,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint7,
        {self}
      }
    }
  })
end

function Act_3_TimeTrial:Task_Checkpoint7()
  self:CreateTask({
    sName = "Checkpoint7.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint7,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint8,
        {self}
      }
    }
  })
end

function Act_3_TimeTrial:Task_Checkpoint8()
  self:CreateTask({
    sName = "Checkpoint8.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint8,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint9,
        {self}
      }
    }
  })
end

function Act_3_TimeTrial:Task_Checkpoint9()
  self:CreateTask({
    sName = "Checkpoint9.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint9,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    WTFZoneHigh = "WtF_Zones\\act3\\mission_1\\ZT_WTFArc",
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint10,
        {self}
      }
    }
  })
end

function Act_3_TimeTrial:Task_Checkpoint10()
  self:CreateTask({
    sName = "Checkpoint10.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint10,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint11,
        {self}
      }
    }
  })
end

function Act_3_TimeTrial:Task_Checkpoint11()
  self:CreateTask({
    sName = "Checkpoint11.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint11,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Checkpoint12,
        {self}
      }
    }
  })
end

function Act_3_TimeTrial:Task_Checkpoint12()
  self:CreateTask({
    sName = "Checkpoint12.Lap" .. self.iLap,
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = self.sTrigCheckpoint12,
    bNoWorldBlip = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.LapCheck,
        {self}
      }
    }
  })
end
