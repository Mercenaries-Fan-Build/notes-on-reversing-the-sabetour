if P3FP_MadBomber03 == nil then
  P3FP_MadBomber03 = SabTaskObjective:Create()
  P3FP_MadBomber03.sPATH = "Missions\\freeplay\\p3\\mis_luxem_east\\"
  P3FP_MadBomber03:Configure({
    TaskCount = 99,
    sStarter = "drkwong_cat_int",
    sSaveMissionNameID = "MissionNames_Text.P3FP_Madbomber03",
    sActNameID = "MissionNames_Text.ACT_DrKwong",
    tDependencyList = {},
    tUnlockList = {
      "P3FP_FountainSniper"
    },
    sConvFile = "P3FP_MadBomber03_Start",
    bFreeplay = true,
    bEscalationDenial = true,
    bEscalationDenial = true,
    tSMEDNodes = {
      P3FP_MadBomber03.sPATH .. "main",
      P3FP_MadBomber03.sPATH .. "specialnazis",
      P3FP_MadBomber03.sPATH .. "nazis"
    }
  })
end

function P3FP_MadBomber03:STARTER_Setup()
end

function P3FP_MadBomber03:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.SetupCheckpoint(self, 1)
end

function P3FP_MadBomber03:GENERAL_Setup()
end

function P3FP_MadBomber03:SetupVariables()
  self.hSab = self.hSab or Handle("Saboteur")
  self.sBomber = self.sBomber or self.sPATH .. "main\\MadBomber"
  self.sTarget = self.sTarget or self.sPATH .. "target\\Target"
  self.sNaziArrivedTrig = self.sNaziArrivedTrig or self.sPATH .. "main\\PT_NaziArrived"
  self.sDeleteTrig = self.sDeleteTrig or self.sPATH .. "delete_zone\\TRIG_Delete"
  self.sHeilLoc = self.sHeilLoc or self.sPATH .. "main\\LOC_Heil"
  self.nCanceledCinTime = self.nCanceledCinTime or 3
  self.bCinematicSkipped = self.bCinematicSkipped or false
  self.sBomberPath = self.sBomberPath or self.sPATH .. "main\\PA_BomberPath"
  self.sBomberLoc = self.sBomberLoc or self.sPATH .. "main\\LOC_MadBomber"
  self.tNaziDeathSquad = self.tNaziDeathSquad or {
    self.sPATH .. "nazis\\Nazi1",
    self.sPATH .. "nazis\\Nazi2",
    self.sPATH .. "nazis\\Nazi3",
    self.sPATH .. "nazis\\Nazi4",
    self.sPATH .. "nazis\\Nazi5",
    self.sPATH .. "nazis\\Nazi6",
    self.sPATH .. "nazis\\Nazi7",
    self.sPATH .. "nazis\\Nazi8",
    self.sPATH .. "nazis\\Nazi9",
    self.sPATH .. "nazis\\Nazi10",
    self.sPATH .. "nazis\\Nazi11",
    self.sPATH .. "nazis\\Nazi12"
  }
  self.tTargetSquad = self.tTargetSquad or {
    self.sPATH .. "specialnazis\\BG1",
    self.sPATH .. "specialnazis\\BG2",
    self.sPATH .. "specialnazis\\BG3",
    self.sPATH .. "specialnazis\\BG4"
  }
  self.tHappyBoyzSquad = self.tHappyBoyzSquad or {
    self.sPATH .. "nazis\\Tessy",
    self.sPATH .. "nazis\\Gertrude"
  }
  self.eSurpriseDeath = self.eSurpriseDeath or nil
end

function P3FP_MadBomber03:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "P3FP_MadBomber03.DoCheckpoint")
end

function P3FP_MadBomber03:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  self.SetupVariables(self)
  if self.eSurpriseDeath then
    Util.KillEvent(self.eSurpriseDeath)
  end
  self.eSurpriseDeath = EVENT_ActorDeath("P3FP_MadBomber03.SurpriseFail", self, Handle(self.sPATH .. "nazis\\Nazi12"))
  if nCP == 1 then
    self.Task_Exit(self)
  elseif nCP == 2 then
    if not self:IsMissionTaskActive("Task_PickupBomber") then
      self.Task_PickupBomber(self)
    end
    local tDeathEvent = {
      EventType = "DeathEvent",
      ObjectHandle = Handle(self.sBomber),
      EventName = "EVT_BomberDead"
    }
    self:RegisterEvent(Util.CreateEvent(tDeathEvent, "P3FP_MadBomber03.BomberDead", self))
  elseif nCP == 3 then
    if not self:IsMissionTaskActive("TASK_DontEscalate") then
      self.TASK_DontEscalate(self)
    end
    if self.hBomber then
      Actor.SetMissionCriticalNPC(self.hBomber, true)
    else
    end
    self.SetupBomberStream(self)
    self.Task_BomberGo(self)
  end
end

function P3FP_MadBomber03:Task_Exit()
  self:CreateTask({
    sName = "Task_Exit",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sObjectiveTextID = "P3FP_MadBomber03_Text.Task_Exit",
    sInteriorName = "Catacombs",
    bInteriorTask = true,
    MarkerHeight = 0.5,
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 2}
      }
    }
  })
end

function P3FP_MadBomber03:Task_PickupBomber()
  self:CreateTask({
    sName = "Task_PickupBomber",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sPickupTextID = "P3FP_MadBomber03_Text.Task_PickupBomber_sPickupTextID",
    sDropoffTextID = "P3FP_MadBomber03_Text.Task_PickupBomber_sDropoffTextID",
    sVehicleFetchID = "GenericObjective_Text.Vehicle_GetIn_A",
    sVehicleReturnID = "GenericObjective_Text.Vehicle_GetInBack_A",
    tDestLocators = {
      self.sPATH .. "main\\LOC_Dropoff"
    },
    tDestRegion = {
      self.sPATH .. "main\\REG_Dropoff"
    },
    vGPSTarget = {
      self.sBomberLoc
    },
    tDeliverObjs = {
      self.sBomber
    },
    bEscalationDenial = true,
    bVehicleIsRequired = true,
    tPickupProxObj = {
      self.sBomber
    },
    Proximity = 10,
    sDropOffConv = "P3FP_MadBomber03_Arrival",
    tOnActivate = {},
    tOnEarlyExit = {},
    tOnPickup = {
      {
        self.SetupSquad,
        {self}
      },
      {
        Cin.PlayConversation,
        {
          "P3FP_MadBomber03_Banter"
        }
      }
    },
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 3}
      }
    },
    tDeleteNodes = {
      self.sPATH .. "delete_zone"
    }
  })
end

function P3FP_MadBomber03:Task_BomberGo()
  self:CreateTask({
    sName = "Task_BomberGo",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    sObjectiveTextID = "P3FP_MadBomber03_Text.Task_BomberGo",
    tTgtInclude = {
      self.sBomber
    },
    tLocators = {},
    tOnActivate = {
      {
        self.BomberPathToArea,
        {self}
      },
      {
        self.DistanceFailEvent,
        {self}
      }
    },
    tOnComplete = {},
    tDeleteNodes = {
      self.sPATH .. "delete_zone"
    }
  })
end

function P3FP_MadBomber03:DistanceFailEvent()
  self.eFailEvent = EVENT_PlayerToActorProximityNegated("P3FP_MadBomber03.FailOnBomberAbandon", self, Handle(self.sBomber), 80)
end

function P3FP_MadBomber03:FailOnBomberAbandon()
  self:MissionTaskFail("GenericFail_Text.ABANDON_GEN_Follower")
end

function P3FP_MadBomber03:Task_Kill()
  self:CreateTask({
    sName = "Task_Kill",
    sTaskType = "SabTaskObjectiveDestroy",
    sObjectiveTextID = "P3FP_MadBomber03_Text.Task_Kill",
    sTaskSubType = "Kill",
    tTgtInclude = {
      self.sTarget
    },
    tOnActivate = {
      {
        Cin.PlayConversation,
        {
          "P3FP_MadBomber03_Missed"
        }
      }
    },
    tOnComplete = {
      {
        self.TASK_Escape,
        {self}
      }
    }
  })
end

function P3FP_MadBomber03:TASK_Escape()
  self:CreateTask({
    sName = "TASK_Escape",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    EscalationLevel = 0,
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function P3FP_MadBomber03:TASK_DontEscalate()
  self:CreateTask({
    sName = "TASK_DontEscalate",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.MissionTaskFail,
        {
          self,
          "P3FP_MadBomber03_Text.FAIL_Escalation"
        }
      }
    }
  })
end

function P3FP_MadBomber03:SetupBomberStream()
  self.hBomber = self.hBomber or Handle(self.sBomber)
  Combat.SetGrabbable(self.hBomber, false)
  Combat.SetIdleScripted(self.hBomber, true)
  Actor.SetVehicleAvoidance(self.hBomber, false)
end

function P3FP_MadBomber03:BomberDead()
  self.MissionTaskFail(self, "P3FP_MadBomber03_Text.FAIL_Bomber_Died", self)
end

function P3FP_MadBomber03:SurpriseFail()
  if self.eSurpriseDeath then
    Util.KillEvent(self.eSurpriseDeath)
    self.eSurpriseDeath = nil
  end
  self.MissionTaskFail(self, "P3FP_MadBomber03_Text.FAIL_Surprise")
end

function P3FP_MadBomber03:SetupSquad()
  self.hBomber = self.hBomber or Handle(self.sBomber)
  if self.hBomber and Object.IsAlive(self.hBomber) then
    Combat.SetLeader(self.hBomber, self.hSab, false, 10, 20)
  end
end

function P3FP_MadBomber03:NaziExplode()
  if self:IsMissionTaskActive("TASK_DontEscalate") then
    self:KillTaskByName("TASK_DontEscalate")
  end
  Suspicion.SetFixedEscalationLevel(1)
  Suspicion.SetEscalated()
  if self.eNaziExplodeEvent then
    self.eNaziExplodeEvent = nil
  end
  if self.eSurpriseDeath then
    Util.KillEvent(self.eSurpriseDeath)
    self.eSurpriseDeath = nil
  end
  x = -263.6022
  y = 52.62975
  z = 801.83417
  Util.CreateExplosion("Explosion_Large", x, y, z)
  self:MoverRetreaters()
  for i, sNazi in ipairs(self.tNaziDeathSquad) do
    local hNazi = Handle(sNazi)
    if Object.IsAlive(hNazi) then
      Object.Kill(hNazi)
    end
  end
end

function P3FP_MadBomber03:ActivateEscalation(a_tCallbackData)
  local nState = a_tCallbackData[1]
  if nState == cCINEMATIC_SKIPPED then
    self.bCinematicSkipped = true
    self.CinematicSkipped(self)
  end
  self:CompleteTaskByName("Task_BomberGo")
  if self.bCinematicSkipped then
    local tTimerEvent = {
      EventType = "TimerEvent",
      Time = self.nCanceledCinTime + 0.5
    }
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P3FP_MadBomber03.StartKillTask", self))
  else
    self.StartKillTask(self)
  end
end

function P3FP_MadBomber03:StartKillTask()
  Util.SpawnEditNode(self.sPATH .. "Target.wsd", "P3FP_MadBomber03.Task_Kill", self)
end

function P3FP_MadBomber03:MoverRetreaters()
  local hLoc = Handle(self.sPATH .. "specialnazis\\LOC_Target_Runto")
  self.hTarget = self.hTarget or Handle(self.sTarget)
  if hLoc and self.hTarget then
    Actor.OverrideCombatAI(self.hTarget, true)
    Combat.SetIdleScripted(self.hTarget, true)
    Nav.MoveToObject(self.hTarget, hLoc, 1.5, true, "P3FP_MadBomber03.ReachedRetreat", self, {
      self.hTarget,
      hLoc
    })
  end
  for i, sNazi in pairs(self.tTargetSquad) do
    local hNazi = Handle(sNazi)
    local sLoc = self.sPATH .. "specialnazis\\LOC_BG" .. i
    local hLoc = Handle(sLoc)
    if hNazi and hLoc then
      Actor.OverrideCombatAI(hNazi, true)
      Combat.SetIdleScripted(hNazi, true)
      Nav.MoveToObject(hNazi, hLoc, 1.5, true, "P3FP_MadBomber03.ReachedRetreat", self, {hNazi, hLoc})
    end
  end
end

function P3FP_MadBomber03:ReachedRetreat(a_hNazi, a_hLoc)
  if a_hNazi and Object.IsAlive(a_hNazi) then
    Actor.OverrideCombatAI(a_hNazi, false)
    if hLoc then
      Combat.SetTether(a_hNazi, a_hLoc, 2)
    end
    Combat.SetTarget(a_hNazi, self.hSab)
  end
end

function P3FP_MadBomber03:BomberPathToArea()
  Nav.SetScriptedPath(self.hBomber, self.sBomberPath, true, "P3FP_MadBomber03.HeilBomber", self)
  Nav.SetScriptedPathMoveMode(self.hBomber, true)
end

function P3FP_MadBomber03:HeilBomber()
  local tRunSequence = {
    {
      "MATCHFACING",
      {
        self.sHeilLoc
      }
    },
    {
      "DELAY",
      {0.25}
    },
    {
      "PLAYANIMATION",
      {"nazi_hail"}
    },
    {
      "DELAY",
      {3.7}
    },
    {
      "RUNTOOBJECT",
      {
        self.sPATH .. "main\\LOC_BombIt",
        2
      }
    }
  }
  ScriptSequence.Run(self.hBomber, tRunSequence, P3FP_MadBomber03.Task_Cut_GoodbyeHappyWorld, {self})
end

function P3FP_MadBomber03:ItsATrap()
  if self.eNaziMoveEvent then
    self.eNaziMoveEvent = nil
  end
  self.tNaziMovers = {
    self.sPATH .. "nazis\\Nazi1",
    self.sPATH .. "nazis\\Nazi4"
  }
  for i, sNazi in pairs(self.tNaziMovers) do
    local hNazi = Handle(sNazi)
    if hNazi and Object.IsAlive(hNazi) then
      Combat.SetIdleHoldWeapon(hNazi, true)
      Combat.SetIdleScripted(hNazi, true)
      local tTimerEvent = {
        EventType = "TimerEvent",
        Time = math.random(1, 10) / 10
      }
      self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P3FP_MadBomber03.GotoObj", self, {
        hNazi,
        self.hBomber
      }))
    end
  end
  for i, sNazi in pairs(self.tHappyBoyzSquad) do
    local hNazi = Handle(sNazi)
    if hNazi and Object.IsAlive(hNazi) then
      Combat.SetIdleHoldWeapon(hNazi, true)
      Combat.SetIdleScripted(hNazi, true)
      self:GotoObj(hNazi, self.hSab)
    end
  end
end

function P3FP_MadBomber03:Task_Cut_GoodbyeHappyWorld()
  Util.KillEvent(self.eFailEvent)
  Util.KillEvent("EVT_BomberDead")
  Actor.SetMissionCriticalNPC(self.hBomber, false)
  Cin.PlayCinematic("CIN_P3FPMB03_1", false, "P3FP_MadBomber03.ActivateEscalation", self)
  Cin.PlayConversation("P3FP_MadBomber03_CoverBlown")
  local tTimerEvent = {EventType = "TimerEvent", Time = 20.5}
  self.eNaziExplodeEvent = Util.CreateEvent(tTimerEvent, "P3FP_MadBomber03.NaziExplode", self)
  self:RegisterEvent(self.eNaziExplodeEvent)
  tTimerEvent = {EventType = "TimerEvent", Time = 17}
  self.eNaziMoveEvent = Util.CreateEvent(tTimerEvent, "P3FP_MadBomber03.ItsATrap", self)
  self:RegisterEvent(self.eNaziMoveEvent)
end

function P3FP_MadBomber03:CinematicSkipped()
  self:KillTaskByName("TASK_DontEscalate")
  if self.eNaziExplodeEvent then
    Util.KillEvent(self.eNaziExplodeEvent)
    self.eNaziExplodeEvent = nil
  end
  if self.eNaziMoveEvent then
    Util.KillEvent(self.eNaziMoveEvent)
    self.eNaziMoveEvent = nil
  end
  self.ItsATrap(self)
  local tTimerEvent = {
    EventType = "TimerEvent",
    Time = self.nCanceledCinTime
  }
  self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P3FP_MadBomber03.NaziExplode", self))
end

function P3FP_MadBomber03:GotoObj(a_hDude, a_hTarget)
  if Object.GetDistance(a_hDude, a_hTarget) > 3.7 then
    Nav.MoveToObject(a_hDude, a_hTarget, 3.5, cMOVE_STALK, "P3FP_MadBomber03.GotoObj", self, {a_hDude, a_hTarget}, false, true)
  end
end

function P3FP_MadBomber03:MISSION_ONRESET()
  self.eSurpriseDeath = nil
  Suspicion.EnableGlobal(true)
  Suspicion.EnableEscalation(true)
  Sound.ResetMusicLocale()
  Suspicion.SetFixedEscalationLevel(-1)
end
