if Connect_ST_405_BackToSaarbruken == nil then
  Connect_ST_405_BackToSaarbruken = SabTaskObjective:Create()
  Connect_ST_405_BackToSaarbruken:Configure({
    TaskCount = 999,
    sStarter = "Starter_Skylar_Airstrip",
    sSaveMissionNameID = "MissionNames_Text.A3M3",
    bDisableMissionTitle = true,
    ProximityStart = 50,
    MCDisplayID = 2,
    tUnlockList = {
      "Act_3_Mission_3"
    },
    tSMEDNodes = {
      "Missions\\act_3\\mission_3\\teleportconnect"
    }
  })
end

function Connect_ST_405_BackToSaarbruken:STARTER_Setup()
  local hSkyPlane = Util.GetHandleByName("Missions\\act_3\\characters\\skylar_airstrip_starter\\PROP_VH_NO_PL_P61Skylar_01")
  local tSkyPlaned = {EventType = "DeathEvent", ObjectHandle = hSkyPlane}
  Util.CreateEvent(tSkyPlaned, "Connect_ST_405_BackToSaarbruken.FailThis", self)
end

function Connect_ST_405_BackToSaarbruken:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Connect_ST_405_BackToSaarbruken:GENERAL_Setup()
  self:RegisterCheckpoint("Connect_ST_405_BackToSaarbruken.Checkpoint1")
end

function Connect_ST_405_BackToSaarbruken:Checkpoint1()
  if Suspicion.GetEscalation() > 0 then
    self.tSaveInfo.nLoopedEscalated = 1
    self.tSaveInfo.nLoopedDeescalated = 1
    self.DeescalationLoop(self)
  else
    self:Task_FirstObjective()
  end
end

function Connect_ST_405_BackToSaarbruken:DeescalationLoop()
  if self.tSaveInfo.nLoopedEscalated == 1 then
    self.tSaveInfo.nLoopedEscalated = 2
    self:CreateTask({
      sName = "cooldownbeforetalking",
      sTaskType = "SabTaskObjectiveEscalation",
      sTaskSubType = "None",
      sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
      EscalationLevel = 0,
      tOnComplete = {
        {
          self.RendezvousSkylar,
          {self}
        }
      }
    })
  else
    self:ResetTaskByName("cooldownbeforetalking")
  end
end

function Connect_ST_405_BackToSaarbruken:RendezvousSkylar()
  if self.tSaveInfo.nLoopedDeescalated == 1 then
    self.tSaveInfo.nLoopedDeescalated = 2
    self:CreateTask({
      sName = "escalatedbeforetalking",
      sTaskType = "SabTaskObjectiveEscalation",
      sTaskSubType = "None",
      EscalationLevel = 1,
      bGTE = true,
      tOnComplete = {
        {
          self.KillTaskByName,
          {self, "GotoSkylar"}
        },
        {
          self.DeescalationLoop,
          {self}
        }
      }
    })
    local sLocator = "Missions\\act_3\\mission_3\\teleportconnect\\LOC_Point1"
    local sPT = "Missions\\act_3\\characters\\skylar_airstrip_starter\\PT_SkyPlaneProxCheck"
    self:CreateTask({
      sName = "GotoSkylar",
      sTaskType = "SabTaskObjectiveDeliver",
      sObjectiveTextID = "S2M2_Text.RendezvousWithSkylar",
      sTaskSubType = "GOTO",
      tLocators = {sLocator},
      tDestRegion = sPT,
      tDeliverObjs = {hSab},
      tOnComplete = {
        {
          self.Task_FirstObjective,
          {self}
        }
      }
    })
  else
    self:ResetTaskByName("escalatedbeforetalking")
    self:ResetTaskByName("GotoSkylar")
  end
end

function Connect_ST_405_BackToSaarbruken:Task_FirstObjective()
  Render.FadeScreen(true)
  local tEvent = {EventType = "TimerEvent", Time = 1.5}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Connect_ST_405_BackToSaarbruken.Task_FirstObjectiveHackyDelay", self))
end

function Connect_ST_405_BackToSaarbruken:FailThis()
  self:MissionTaskFail("GenericFail_Text.Destroyed_SkylarPlane")
end

function Connect_ST_405_BackToSaarbruken:Task_FirstObjectiveHackyDelay()
  self:CreateTask({
    sName = "Connect_ST_405_BackToSaarbruken_Task_FirstObjective",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    bCompleteOnActivate = true,
    tOnActivate = {
      {
        self.UnloadNode,
        {self}
      },
      {
        self.Task_ShowCinematic,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Connect_ST_405_BackToSaarbruken:DelayedUnFade()
end

function Connect_ST_405_BackToSaarbruken:Task_ShowCinematic()
  local tEvent = {EventType = "TimerEvent", Time = 1.5}
  Util.CreateEvent(tEvent, "Connect_ST_405_BackToSaarbruken.DelayedUnFade", self)
  self:CreateTask({
    sName = "Connect_ST_405_BackToSaarbruken_Task_ShowCinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "405_CinA_Flight-ToDoppelsieg",
    bOverrideFade = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    },
    tCinematicNodes = {
      "405_cina_flight"
    }
  })
end

function Connect_ST_405_BackToSaarbruken:UnloadNode()
  Util.UnloadEditNode("Missions\\act_3\\characters\\skylar_airstrip_starter.wsd", true, false)
end

function Connect_ST_405_BackToSaarbruken:UnloadCinNode()
  Util.UnloadCinematicNode("405_cina_flight")
end

function Connect_ST_405_BackToSaarbruken:CompleteWithTeleport()
  Util.UnloadCinematicNode("405_cina_flight")
  self:CompleteThisMission()
end
