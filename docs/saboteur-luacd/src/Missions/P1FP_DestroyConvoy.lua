if P1FP_DestroyConvoy == nil then
  P1FP_DestroyConvoy = SabTaskObjective:Create()
  P1FP_DestroyConvoy.PATH = "Missions\\freeplay\\p1\\mis_placerepub_convoy\\"
  P1FP_DestroyConvoy:Configure({
    TaskCount = 999,
    sSaveMissionNameID = "MissionNames_Text.P1FP_DestroyConvoy",
    tDependencyList = {},
    tUnlockList = {
      "Connect_ConvoyPapers"
    },
    bFreeplay = true,
    bRepeatable = false,
    sStarter = "santos_ext_hideout",
    sConvFile = "303_Con_GetPapers",
    tSMEDNodes = {
      P1FP_DestroyConvoy.PATH .. "task",
      P1FP_DestroyConvoy.PATH .. "main"
    },
    tStaticTags = {
      "P1FP_DestroyConvoy_AAGun",
      "P1FP_DestroyConvoy_FuelStation"
    }
  })
end

function P1FP_DestroyConvoy:STARTER_Setup()
end

function P1FP_DestroyConvoy:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "CONVOY"
  self.bDebugMode = false
  self.GENERAL_Setup(self)
  self.SetupCheckpoint(self, 1)
end

function P1FP_DestroyConvoy:GENERAL_Setup()
  self.hSab = Handle("Saboteur")
  self.sConvoyLOC = self.PATH .. "task\\LOC_ConvoyLoc"
  self.sConvoyTrig = self.PATH .. "task\\PT_ConvoyTrig"
  self:AddOnCancelCallback(P1FP_DestroyConvoy.Reset)
  self:AddOnCompleteCallback(P1FP_DestroyConvoy.Reset)
  self.tSaveInfo.Targets = {
    self.PATH .. "main\\Truck1",
    self.PATH .. "main\\Truck2",
    self.PATH .. "main\\Truck3"
  }
end

function P1FP_DestroyConvoy:Reset()
  Sound.ResetMusicLocale()
end

function P1FP_DestroyConvoy:Sound1()
  Sound.SetMusicLocale("fp_P1FP_DestroyConvoy")
  Sound.SetMusicLocale("fp_P1FP_DestroyConvoy", "arriveAtTrucks")
end

function P1FP_DestroyConvoy:Sound2()
  Sound.SetMusicLocale("fp_P1FP_DestroyConvoy")
  Sound.SetMusicLocale("fp_P1FP_DestroyConvoy", "truckDestroyed")
end

function P1FP_DestroyConvoy:SetupVariables()
  self.bVariablesSet = true
  self.nKubelLoaded = 0
  self.nTruck1Loaded = 0
  self.nTruck2Loaded = 0
  self.nTruck3Loaded = 0
  self.nAPCGuy = 1
  self.bSpawnTanks = true
  self.sActiveTask = "INIT"
  self.bRunningVOPlayed = false
  Util.SetDynamicPriority("VH_NZ_TR_OpelCanvas_01", 50000)
  self.sSmoker = self.PATH .. "main\\NZ_Smoker"
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      self.sSmoker
    },
    WaitForGameObject = true
  }
  self:RegisterEvent(Util.CreateEvent(tStreamEvent, "P1FP_DestroyConvoy.SmokerStreamed", self))
  dprint(self, "Setting up wavers!")
  self.tWaveGrunt = {
    Handle(self.PATH .. "main\\NZ_WaveGrunt"),
    Handle(self.PATH .. "main\\NZ_WaveGrunt2")
  }
  self.tWaveTrig = {
    Handle(self.PATH .. "main\\PT_RearWave"),
    Handle(self.PATH .. "main\\PT_RearWave2")
  }
  for i, hEnt in ipairs(self.tWaveGrunt) do
    Combat.SetIdleHoldWeapon(hEnt, true)
    Combat.SetIdleScripted(hEnt, true)
    local tWaveIdleExit = {
      EventType = "OnIdleScriptedExit",
      Target = hEnt,
      EventName = "WaveGrunt_Trigger"
    }
    local eWaveExitIdle = Util.CreateEvent(tWaveIdleExit, "P1FP_DestroyConvoy.OnWaveGruntExitsIdle", self, {hEnt})
    self:RegisterEvent(eWaveExitIdle)
  end
  for i, hTrig in ipairs(self.tWaveTrig) do
    local tTriggerEnter = {
      EventType = "OnTriggerEnter",
      Target = hTrig
    }
    local eWaveTrig = Util.CreateEvent(tTriggerEnter, "P1FP_DestroyConvoy.OnWaveTrigEnter", self, {i}, true)
    self:RegisterEvent(eWaveTrig)
  end
  Actor.SetVehicleAvoidance(Handle(self.PATH .. "main\\NZ_KubelOfficer"), false)
  dprint(self, "Setting up mechanic!")
  self.hMechanic = Handle(self.PATH .. "main\\NZ_Mechanic")
  local tStream = {
    EventType = "StreamEvent",
    Objects = {
      self.PATH .. "main\\NZ_Mechanic"
    },
    WaitForGameObject = true
  }
  if self.eMechStream then
    Util.KillEvent(self.eMechStream)
  end
  self.eMechStream = Util.CreateEvent(tStream, "P1FP_DestroyConvoy.OnMechanicStreams", self)
  local tMechIdleExit = {
    EventType = "OnIdleScriptedExit",
    Target = self.hMechanic,
    EventName = "MechanicExitIdle"
  }
  if self.eWaveExitIdle then
    Util.KillEvent(self.eWaveExitIdle)
  end
  self.eWaveExitIdle = Util.CreateEvent(tMechIdleExit, "P1FP_DestroyConvoy.OnMechanicExitsIdle", self)
  self:RegisterEvent(self.eMechStream)
  self:RegisterEvent(self.eWaveExitIdle)
  dprint(self, "Starting smoke effect!")
  Render.StartFX(Handle(self.tSaveInfo.Targets[2]), "0FX_Smoke02_Medium", nil)
  local tDeathEvent = {
    EventType = "DeathEvent",
    ObjectHandle = Handle(self.tSaveInfo.Targets[2])
  }
  if self.eDeathEvent then
    Util.KillEvent(self.eDeathEvent)
  end
  self.eDeathEvent = Util.CreateEvent(tDeathEvent, "P1FP_DestroyConvoy.TurnOffEffects", self)
  self:RegisterEvent(self.eDeathEvent)
  if self.eLockTrucks then
    Util.KillEvent(self.eLockTrucks)
  end
  self.eLockTrucks = EVENT_Stream("P1FP_DestroyConvoy.LockTrucks", self, self.tSaveInfo.Targets, false)
  self.SetupProxEvent(self)
end

function P1FP_DestroyConvoy:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "P1FP_DestroyConvoy.DoCheckpoint")
end

function P1FP_DestroyConvoy:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  self.SetupVariables(self)
  if nCP == 1 then
    if not self:IsMissionTaskActive("P1FP_DestroyConvoy_TASK_FindConvoy") then
      self.TASK_FindConvoy(self)
    end
  elseif nCP == 2 then
    if not self:IsMissionTaskActive("P1FP_DestroyConvoy.TASK_DestroyTrucks") then
      EVENT_Timer("P1FP_DestroyConvoy.CheckTrucksAlive", self, 1)
    end
    ClearAllDisableControls()
  end
end

function P1FP_DestroyConvoy:LockTrucks()
  for i, hTruck in ipairs(self.tSaveInfo.Targets) do
    Vehicle.LockAllSeats(Handle(hTruck), true)
  end
  self:TruckDamageEvents()
end

function P1FP_DestroyConvoy:CheckTrucksAlive()
  for i, hTruck in ipairs(self.tSaveInfo.Targets) do
    if not Object.IsAlive(Handle(hTruck)) then
      table.remove(self.tSaveInfo.Targets, i)
    end
  end
  if Suspicion.GetEscalation() > 0 or Suspicion.IsEscalatedLite() then
    self.TrucksRun(self)
  else
    self.EscalationListener(self)
  end
  self.TASK_DestroyTrucks(self)
end

function P1FP_DestroyConvoy:BoomVO()
  Cin.PlayConversation("P1FP_DestroyConvoy_Boom")
end

function P1FP_DestroyConvoy:TruckDamageEvents()
  local tSkyCarDam1 = {
    EventType = "DamageEvent",
    ObjectHandle = Handle(self.PATH .. "main\\Truck1"),
    MinDamage = 1
  }
  self.eSkipTest1 = Util.CreateEvent(tSkyCarDam1, "P1FP_DestroyConvoy.SkipToDTTest", self, true)
  self:RegisterEvent(self.eSkipTest1)
  local tSkyCarDam2 = {
    EventType = "DamageEvent",
    ObjectHandle = Handle(self.PATH .. "main\\Truck2"),
    MinDamage = 1
  }
  self.eSkipTest2 = Util.CreateEvent(tSkyCarDam2, "P1FP_DestroyConvoy.SkipToDTTest", self, true)
  self:RegisterEvent(self.eSkipTest2)
  local tSkyCarDam3 = {
    EventType = "DamageEvent",
    ObjectHandle = Handle(self.PATH .. "main\\Truck3"),
    MinDamage = 1
  }
  self.eSkipTest3 = Util.CreateEvent(tSkyCarDam3, "P1FP_DestroyConvoy.SkipToDTTest", self, true)
  self:RegisterEvent(self.eSkipTest3)
end

function P1FP_DestroyConvoy:SkipToDTTest(a_tCallbackData)
  if a_tCallbackData[1] == Handle("Saboteur") and not self:IsMissionTaskActive("P1FP_DestroyConvoy.TASK_DestroyTrucks") then
    self:KillTaskByName("P1FP_DestroyConvoy_TASK_FindConvoy")
    self.SetupCheckpoint(self, 2)
    self:KillSkipTests()
  end
end

function P1FP_DestroyConvoy:KillSkipTests()
  Util.KillEvent(self.eSkipTest1)
  Util.KillEvent(self.eSkipTest2)
  Util.KillEvent(self.eSkipTest3)
end

function P1FP_DestroyConvoy:TASK_FindConvoy()
  self:CreateTask({
    sName = "P1FP_DestroyConvoy_TASK_FindConvoy",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tLocators = {
      self.sConvoyLOC
    },
    tDestRegion = {
      self.sConvoyTrig
    },
    tDeliverObjs = {
      self.hSab
    },
    sObjectiveTextID = "P1FP_DestroyConvoy_Text.TASK_FindConvoy",
    ParentObjectID = -1,
    tOnActivate = {
      {
        self.EscalationListener,
        {self}
      }
    },
    tOnComplete = {
      {
        self.PanoramaCin,
        {self}
      },
      {
        self.BrakeCar,
        {self}
      },
      {
        self.ClearGPS,
        {self}
      }
    }
  })
end

function P1FP_DestroyConvoy:ClearGPS()
  HUD.ClearWaypoint()
  HUD.ClearGPSTarget()
end

function P1FP_DestroyConvoy:BrakeCar()
  local hSabCar = Actor.GetVehicle(hSab)
  if hSabCar then
    SabTaskObjectiveDeliver.StopVehicle(self, hSabCar)
  end
end

function P1FP_DestroyConvoy:UnBrakeCar()
  local hSabCar = Actor.GetVehicle(hSab)
  if hSabCar then
    SabTaskObjectiveDeliver.ReleaseVehicle(self, hSabCar)
  end
  ClearAllDisableControls()
end

function P1FP_DestroyConvoy:PanoramaCin()
  self:CreateTask({
    sName = "P1FP_DestroyConvoy.PanoramaCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "CIN_DestroyConvoy_Pan",
    tSMEDNodes = {},
    tStaticTags = {},
    tOnActivate = {
      {
        self.EscalatedOnArrival,
        {self}
      },
      {
        self.Sound1,
        {self}
      }
    },
    tOnComplete = {
      {
        self.UnBrakeCar,
        {self}
      },
      {
        self.SetupCheckpoint,
        {self, 2}
      }
    }
  })
end

function P1FP_DestroyConvoy:EscalatedOnArrival()
  if Suspicion.GetEscalation() > 0 or Suspicion.IsEscalatedLite() then
    self.TrucksRun(self)
  end
end

function P1FP_DestroyConvoy:TASK_DestroyTrucks()
  self:CreateTask({
    sName = "P1FP_DestroyConvoy.TASK_DestroyTrucks",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P1FP_DestroyConvoy_Text.TASK_DestroyTrucks",
    bObjCounter = true,
    bNoGPS = true,
    ParentObjectID = -1,
    MarkerHeight = 4,
    tTgtInclude = self.tSaveInfo.Targets,
    tOnActivate = {
      {
        self.SetupTruckDamageCallbacks,
        {self}
      },
      {
        self.KillSkipTests,
        {self}
      },
      {
        self.SetupChain1,
        {self}
      },
      {
        self.SetupChain2,
        {self}
      }
    },
    tOnComplete = {
      {
        self.DoEscalationCheck,
        {self}
      }
    }
  })
end

function P1FP_DestroyConvoy:TASK_LoseTheHeat()
  self:CreateTask({
    sName = "P1FP_DestroyConvoy.TASK_LoseTheHeat",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    EscalationLevel = 0,
    ParentObjectID = -1,
    tOnActivate = {},
    tOnComplete = {
      {
        self.DoEscalationCheck,
        {self}
      }
    }
  })
end

function P1FP_DestroyConvoy:DoEscalationCheck()
  self:ResetTaskByName("P1FP_DestroyConvoy.TASK_LoseTheHeat", true)
  if Suspicion.GetEscalation() > 0 then
    self.TASK_LoseTheHeat(self)
  else
    self:CompleteThisMission()
  end
end

function P1FP_DestroyConvoy:KillEscEvent()
  Util.KillEvent(self.eEscDetect)
  if self.sActiveTask == "P1FP_DestroyConvoy_TASK_FindConvoy" then
    Trigger.DoNotWaitFor("Missions\\freeplay\\p1\\mis_placerepub_convoy\\task\\PT_ConvoyTrig", hSab)
    self:TASK_FindConvoy()
  else
    self:CompleteThisMission()
  end
end

function P1FP_DestroyConvoy:EscalationListener()
  dprint(self, "Setting Escalation Listener")
  self.eEscDetect = EVENT_OnEscalation("P1FP_DestroyConvoy.EscSwitchTasks", self, nil, false)
end

function P1FP_DestroyConvoy:EscSwitchTasks()
  dprint(self, "Escalated. Switching to LOSE HEAT task")
  if self:IsMissionTaskActive("P1FP_DestroyConvoy_TASK_FindConvoy") then
    self:ResetTaskByName("P1FP_DestroyConvoy_TASK_FindConvoy", true)
    self.sActiveTask = "P1FP_DestroyConvoy_TASK_FindConvoy"
    EVENT_PlayerEntersTrigger("P1FP_DestroyConvoy.EscalatedArrival", self, "Missions\\freeplay\\p1\\mis_placerepub_convoy\\task\\PT_ConvoyTrig", false)
    self:TASK_LoseEscalation()
  elseif self:IsMissionTaskActive("P1FP_DestroyConvoy.TASK_DestroyTrucks") then
    self:TrucksRun()
    self:CheckTrucksAlive()
  end
end

function P1FP_DestroyConvoy:EscalatedArrival()
  dprint(self, "Escalated Arrival. Trucks run during cinematic")
  self:KillTaskByName("P1FP_DestroyConvoy.TASK_LoseEscalation")
  self:TrucksRun()
  self:CheckTrucksAlive()
end

function P1FP_DestroyConvoy:TASK_LoseEscalation()
  self:CreateTask({
    sName = "P1FP_DestroyConvoy.TASK_LoseEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    EscalationLevel = 0,
    bRepeatable = true,
    bNoRepeatAutoRebuild = true,
    tOnComplete = {
      {
        self.KillEscEvent,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function P1FP_DestroyConvoy:OnWaveTrigEnter(a_tCallbackData, a_nIndex)
  local hObj = a_tCallbackData[2]
  if hObj ~= hSab then
    Actor.PlayAnimation(self.tWaveGrunt[a_nIndex], "nazi_wave_vehicle_1")
  end
end

function P1FP_DestroyConvoy:OnMechanicStreams()
  dprint(self, "Mechanic has streamed in!")
  local sConfusedA = self.PATH .. "main\\ATTR_Confused1"
  local sConfusedB = self.PATH .. "main\\ATTR_Confused2"
  local sFixFront = self.PATH .. "main\\ATTR_FixFront"
  local sFixRear = self.PATH .. "main\\ATTR_FixRear"
  local sFrustrated = self.PATH .. "main\\ATTR_Frustrated"
  local nDefaultDelay = 6
  local tJumpLabels = {
    "A",
    "B",
    "C",
    "D",
    "E"
  }
  local tMechSequence = {
    {
      "ISIDLESEQUENCE",
      {true}
    },
    {
      "DELAY",
      {3}
    },
    {
      "WALKTOOBJECT",
      {sConfusedA},
      "A"
    },
    {
      "REQUESTATTRPT_NOWAIT",
      {sConfusedA}
    },
    {
      "DELAY",
      {nDefaultDelay}
    },
    {
      "CANCELATTRPT"
    },
    {
      "JUMPTORANDOM",
      tJumpLabels
    },
    {
      "WALKTOOBJECT",
      {sConfusedB},
      "B"
    },
    {
      "REQUESTATTRPT_NOWAIT",
      {sConfusedB}
    },
    {
      "DELAY",
      {nDefaultDelay}
    },
    {
      "CANCELATTRPT"
    },
    {
      "JUMPTORANDOM",
      tJumpLabels
    },
    {
      "WALKTOOBJECT",
      {sFixFront},
      "C"
    },
    {
      "REQUESTATTRPT_NOWAIT",
      {sFixFront}
    },
    {
      "DELAY",
      {nDefaultDelay}
    },
    {
      "CANCELATTRPT"
    },
    {
      "JUMPTORANDOM",
      tJumpLabels
    },
    {
      "WALKTOOBJECT",
      {sFixRear},
      "D"
    },
    {
      "REQUESTATTRPT_NOWAIT",
      {sFixRear}
    },
    {
      "DELAY",
      {nDefaultDelay}
    },
    {
      "CANCELATTRPT"
    },
    {
      "JUMPTORANDOM",
      tJumpLabels
    },
    {
      "WALKTOOBJECT",
      {sFrustrated},
      "E"
    },
    {
      "REQUESTATTRPT_NOWAIT",
      {sFrustrated}
    },
    {
      "DELAY",
      {4}
    },
    {
      "CANCELATTRPT"
    },
    {
      "JUMPTORANDOM",
      tJumpLabels
    }
  }
  Actor.SetVehicleAvoidance(self.hMechanic, false)
  ScriptSequence.Run(self.hMechanic, tMechSequence)
end

function P1FP_DestroyConvoy:OnWaveGruntExitsIdle(a_tCallbackData, a_hEntity, a_nX, a_nY, a_nZ, a_nH)
  local x, y, z, h
  if not a_nX and not a_nY and not a_nZ and not a_nH then
    x, y, z = Actor.GetPosition(a_hEntity)
    h = Object.GetAngle(a_hEntity)
  else
    x, y, z, h = a_nX, a_nY, a_nZ, a_nH
  end
  dprint(self, "WaveGrunt has exited idle!")
  local tWaveIdleEnter = {
    EventType = "OnIdleScriptedEnter",
    Target = a_hEntity
  }
  local eWaveEnterIdle = Util.CreateEvent(tWaveIdleEnter, "P1FP_DestroyConvoy.OnWaveGruntEntersIdle", self, {
    a_hEntity,
    x,
    y,
    z,
    h
  })
  self:RegisterEvent(eWaveEnterIdle)
end

function P1FP_DestroyConvoy:OnWaveGruntEntersIdle(a_tCallbackData, a_hEntity, a_nX, a_nY, a_nZ, a_nH)
  Nav.MoveToPoint(a_hEntity, a_nX, a_nY, a_nZ, false, "P1FP_DestroyConvoy.SetWaveGruntFacingDir", self, {a_hEntity, a_nH})
  local tWaveIdleExit = {
    EventType = "OnIdleScriptedExit",
    Target = a_hEntity
  }
  local eWaveExitIdle = Util.CreateEvent(tWaveIdleExit, "P1FP_DestroyConvoy.OnWaveGruntExitsIdle", self, {
    a_hEntity,
    a_nX,
    a_nY,
    a_nZ,
    a_nH
  })
  self:RegisterEvent(eWaveExitIdle)
end

function P1FP_DestroyConvoy:SetWaveGruntFacingDir(a_hEntity, a_nH)
  Actor.SetFacingDir(a_hEntity, a_nH)
end

function P1FP_DestroyConvoy:OnMechanicExitsIdle()
  dprint(self, "Mechanic has exited idle!")
end

function P1FP_DestroyConvoy:OnTruckMoves(a_nIndex, a_hVehicle)
  dprint(self, "Truck has moved from position!")
  ScriptSequence.Kill(self.hMechanic)
  Util.KillEvent("WaveGrunt_Trigger")
  if Vehicle.GetPilot(a_hVehicle) == Handle("Saboteur") then
    Suspicion.SetEscalationLevel(5)
  end
end

function P1FP_DestroyConvoy:SmokerStreamed()
  self.hSmoker = Handle(self.sSmoker)
  Nav.SetScriptedPath(self.hSmoker, "Missions\\freeplay\\p1\\mis_placerepub_convoy\\main\\PATH_SmokerStrolls", false)
  Nav.SetScriptedPathType(self.hSmoker, cPATHTYPE_BOUNCE)
  self.SmokerIdle(self)
end

function P1FP_DestroyConvoy:SmokerIdle()
  local tCombatEnter = {
    EventType = "OnCombatEnter",
    Target = self.hSmoker
  }
  self:RegisterEvent(Util.CreateEvent(tCombatEnter, "P1FP_DestroyConvoy.SmokerCombatEnter", self))
end

function P1FP_DestroyConvoy:SmokerCombatEnter()
  Actor.CancelAnimation(self.hSmoker)
  local tCombatExit = {
    EventType = "OnCombatExit",
    Target = self.hSmoker
  }
  self:RegisterEvent(Util.CreateEvent(tCombatExit, "P1FP_DestroyConvoy.SmokerIdle", self))
end

function P1FP_DestroyConvoy:SetupProxEvent()
  local tProxEvent = {
    EventType = "ProximityEvent",
    ObjectA = hSab,
    ObjectB = Handle(self.tSaveInfo.Targets[2]),
    Proximity = 75,
    Negate = false
  }
  if self.eProxEvent then
    Util.KillEvent(self.eProxEvent)
  end
  self.eProxEvent = Util.CreateEvent(tProxEvent, "P1FP_DestroyConvoy.DoSightCheck", self)
  self:RegisterEvent(self.eProxEvent)
end

function P1FP_DestroyConvoy:DoSightCheck()
  if Sensory.CanSee(hSab, Handle(self.tSaveInfo.Targets[2])) then
  else
    local tTimerEvent = {EventType = "TimerEvent", Time = 1}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_DestroyConvoy.SetupProxEvent", self))
  end
end

function P1FP_DestroyConvoy:SetupChain1()
  local tBarrelDamEvent = {
    EventType = "DamageEvent",
    ObjectHandle = Handle("Missions\\freeplay\\p1\\mis_placerepub_convoy\\fuelstation\\OccMed_OilTank_A\\OccMed_OilTank_A")
  }
  self.BarrelDamEvent = Util.CreateEvent(tBarrelDamEvent, "P1FP_DestroyConvoy.DestroyTruck", self)
  self:RegisterEvent(self.BarrelDamEvent)
end

function P1FP_DestroyConvoy:SetupChain2()
  local tBarrelDamEvent = {
    EventType = "DamageEvent",
    ObjectHandle = Handle("Missions\\freeplay\\p1\\mis_placerepub_convoy\\fuelstation\\FP_AMB_FuelStation\\OccMed_OilTank_Combo_C_X2Z2(4)\\OccMed_OilTank_Combo_C_X2Z2")
  }
  self.BarrelDamEvent2 = Util.CreateEvent(tBarrelDamEvent, "P1FP_DestroyConvoy.DestroyTruck2", self)
  self:RegisterEvent(self.BarrelDamEvent2)
end

function P1FP_DestroyConvoy:DestroyTruck()
  local hTruck1 = Handle(self.PATH .. "main\\Truck1")
  local hBarrels = Handle("Missions\\freeplay\\p1\\mis_placerepub_convoy\\main\\LOC_Barrels")
  local x, y, z = Object.GetPosition(hTruck1)
  local nTestDist = Object.GetDistance(hTruck1, hBarrels)
  if Object.GetDistance(hTruck1, hBarrels) < 3 then
    dprint(self, "===----Trigger a CHAIN REACTION!!!!!")
    if Object.GetHealth(hTruck1) > 0 then
      Object.SetHealth(hTruck1, 1)
      Object.Kill(hTruck1)
      Util.CreateExplosion("Explosion_Large", x, y, z)
    end
  end
end

function P1FP_DestroyConvoy:DestroyTruck2()
  local hTruck3 = Handle(self.PATH .. "main\\Truck3")
  local hBarrels2 = Handle("Missions\\freeplay\\p1\\mis_placerepub_convoy\\main\\LOC_Barrels2")
  local x, y, z = Object.GetPosition(hTruck3)
  local nTestDist = Object.GetDistance(hTruck3, hBarrels2)
  dprint(self, "Distance = " .. nTestDist)
  if Object.GetDistance(hTruck3, hBarrels2) < 3 and Object.GetHealth(hTruck3) > 0 then
    dprint(self, "===----Trigger a CHAIN REACTION!!!!!")
    Object.SetHealth(hTruck3, 1)
    Object.Kill(hTruck3)
    Util.CreateExplosion("Explosion_Large", x, y, z)
  end
end

function P1FP_DestroyConvoy:TurnOffEffects()
  Render.EndFX(Handle(self.tSaveInfo.Targets[2]), "0FX_Smoke02_Medium", nil)
end

function P1FP_DestroyConvoy:SetupTruckDamageCallbacks()
  for i, hTruck in ipairs(self.tSaveInfo.Targets) do
    local tDamageEvent = {
      EventType = "DamageEvent",
      ObjectHandle = hTruck,
      MinDamage = 50
    }
    self:RegisterEvent(Util.CreateEvent(tDamageEvent, "P1FP_DestroyConvoy.TrucksRun", self, {}))
  end
  EVENT_PlayerEntersTrigger("P1FP_DestroyConvoy.APCAttack", self, "Missions\\freeplay\\p1\\mis_placerepub_convoy\\main\\PT_AAGun", false)
end

function P1FP_DestroyConvoy:TrucksRun()
  self:Sound2()
  local hAAGunPilot = Vehicle.GetPilot(Handle("Missions\\freeplay\\p1\\mis_placerepub_convoy\\aagun\\FP_AMB_AAGun\\Seat"))
  if hAAGunPilot == hSab then
    Object.SetHealth(Handle(self.PATH .. "main\\Truck1"), 3500)
    Object.SetHealth(Handle(self.PATH .. "main\\Truck2"), 3500)
    Object.SetHealth(Handle(self.PATH .. "main\\Truck3"), 3500)
    if self.bSpawnTanks == true then
      self:GoAPC()
      self.bSpawnTanks = false
    end
  end
  Nav.BoardVehicle(Handle(self.PATH .. "main\\NZ_WaveGrunt2"), Handle(self.PATH .. "main\\LeadKubel"), "PILOT", true, "P1FP_DestroyConvoy.RunKubel", self)
  Nav.BoardVehicle(Handle(self.PATH .. "main\\NZ_KubelOfficer"), Handle(self.PATH .. "main\\LeadKubel"), "SHOTGUN", true, "P1FP_DestroyConvoy.RunKubel", self)
  self.RunTruck1(self)
  self.RunTruck2(self)
  Nav.BoardVehicle(Handle(self.PATH .. "main\\NZ_GruntFront1"), Handle(self.PATH .. "main\\Truck3"), "PILOT", true, "P1FP_DestroyConvoy.RunTruck3", self)
  Nav.BoardVehicle(Handle(self.PATH .. "main\\NZ_RearHeavy1"), Handle(self.PATH .. "main\\Truck3"), "SHOTGUN", true, "P1FP_DestroyConvoy.RunTruck3", self)
  self:RunningVO()
  Suspicion.SetEscalated()
end

function P1FP_DestroyConvoy:RunningVO()
  if self.bRunningVOPlayed == false then
    Cin.PlayConversation("P1FP_DestroyConvoy_Running")
  end
  self.bRunningVOPlayed = true
end

function P1FP_DestroyConvoy:APCAttack()
  Util.KillEvent(self.BarrelDamEvent)
  Util.KillEvent(self.BarrelDamEvent2)
end

function P1FP_DestroyConvoy:GrabAPC(a_hAPC)
  self.hAPC = a_hAPC
  self.tAPCSeatList = {
    "PILOT",
    "SHOTGUN",
    "REAR_R1",
    "REAR_R2",
    "REAR_R3",
    "REAR_L1",
    "REAR_L2",
    "REAR_L3",
    "GUNNER"
  }
  self:CollectAPCPassengers()
end

function P1FP_DestroyConvoy:GoAPC(a_hAPC)
  Nav.SetScriptedPath(self.hAPC, "Missions\\freeplay\\p1\\mis_placerepub_convoy\\main\\PATH_APCunloads", true, "P1FP_DestroyConvoy.UnloadAPC", self)
  Nav.SetScriptedPathSpeed(self.hAPC, 100)
end

function P1FP_DestroyConvoy:CollectAPCPassengers()
  self.tAPCPassengers = {}
  for i = 1, #self.tAPCSeatList do
    self.tAPCPassengers[i] = Vehicle.GetActorInSeat(self.hAPC, self.tAPCSeatList[i])
  end
end

function P1FP_DestroyConvoy:UnloadAPC()
  Vehicle.UnboardAll(self.hAPC, false, "P1FP_DestroyConvoy.APCUnloaded", self, {}, nil, nil, nil)
end

function P1FP_DestroyConvoy:APCUnloaded(a_hAPCguy)
  local hGuy = a_hAPCguy[1]
  Nav.MoveToObject(hGuy, Handle("Missions\\freeplay\\p1\\mis_placerepub_convoy\\main\\LOC_APC_" .. self.nAPCGuy), 1, true, "P1FP_DestroyConvoy.APCGuyAttacks", self, {hGuy})
  self.nAPCGuy = self.nAPCGuy + 1
end

function P1FP_DestroyConvoy:APCGuyAttacks(a_hguy)
  local hGuy = a_hguy
  Combat.SetReactImmediately(hGuy, true)
  Combat.SetRespondToEvents(hGuy, false)
  Combat.SetAlwaysSeeTarget(hGuy, true)
  Combat.SetStationary(hGuy, true)
  Combat.LockIntoRanged(hGuy)
  Combat.SetTarget(hGuy, hSab)
  Combat.SetLethalForce(hGuy, true)
  Combat.SetCombat(hGuy)
end

function P1FP_DestroyConvoy:AAGunAttack()
  self.hAAGunner = Handle("Missions\\freeplay\\ambient\\p1\\p1_aagun_19\\FP_AMB_AAGun\\Guard01")
  Combat.SetIdleScripted(self.hAAGunner, true)
  Actor.EnableNeeds(self.hAAGunner, false)
  Nav.BoardVehicle(self.hAAGunner, Handle("Missions\\freeplay\\ambient\\p1\\p1_aagun_19\\FP_AMB_AAGun\\Seat"), "PILOT", true, "P1FP_DestroyConvoy.AAGunFires", self, {})
end

function P1FP_DestroyConvoy:AAGunFires()
  Combat.SetTarget(self.hAAGunner, hSab)
  Combat.SetCombat(self.hAAGunner)
end

function P1FP_DestroyConvoy:RunKubel()
  self.nKubelLoaded = self.nKubelLoaded + 1
  if self.nKubelLoaded == 2 then
    Nav.MoveToObject(Handle(self.PATH .. "main\\LeadKubel"), Handle("Missions\\freeplay\\p1\\mis_placerepub_convoy\\main\\LOC_EscapeToHere"), 10, true)
    Nav.SetScriptedPathSpeed(Handle(self.PATH .. "main\\LeadKubel"), 120)
  end
end

function P1FP_DestroyConvoy:RunTruck1()
  Nav.SetScriptedPath(Handle(self.PATH .. "main\\Truck1"), "Missions\\freeplay\\p1\\mis_placerepub_convoy\\main\\PATH_Truck1Escape", false)
  Nav.SetScriptedPathSpeed(Handle(self.PATH .. "main\\Truck1"), 60)
  EVENT_ActorEntersTrigger("P1FP_DestroyConvoy.FailTruckEscaped1", self, Handle(self.PATH .. "main\\Truck1"), "Missions\\freeplay\\p1\\mis_placerepub_convoy\\main\\PT_Truck1Escape")
end

function P1FP_DestroyConvoy:RunTruck2()
  Nav.SetScriptedPath(Handle(self.PATH .. "main\\Truck2"), "Missions\\freeplay\\p1\\mis_placerepub_convoy\\main\\PATH_Truck2Escape", false)
  Nav.SetScriptedPathSpeed(Handle(self.PATH .. "main\\Truck2"), 60)
  EVENT_ActorEntersTrigger("P1FP_DestroyConvoy.FailTruckEscaped2", self, Handle(self.PATH .. "main\\Truck2"), "Missions\\freeplay\\p1\\mis_placerepub_convoy\\main\\PT_Truck2Escape")
end

function P1FP_DestroyConvoy:RunTruck3()
  self.nTruck3Loaded = self.nTruck3Loaded + 1
  if self.nTruck3Loaded == 2 then
    Nav.SetScriptedPath(Handle(self.PATH .. "main\\Truck3"), "Missions\\freeplay\\p1\\mis_placerepub_convoy\\main\\PATH_Truck3Escape", false)
    Nav.SetScriptedPathSpeed(Handle(self.PATH .. "main\\Truck3"), 60)
    EVENT_ActorEntersTrigger("P1FP_DestroyConvoy.FailTruckEscaped3", self, Handle(self.PATH .. "main\\Truck3"), "Missions\\freeplay\\p1\\mis_placerepub_convoy\\main\\PT_Truck3Escape")
  end
end

function P1FP_DestroyConvoy:SpawnTanks()
  Util.SpawnEditNode("Missions\\freeplay\\p1\\mis_placerepub_convoy\\tanks.wsd", "P1FP_DestroyConvoy.TanksMove", self)
end

function P1FP_DestroyConvoy:TanksMove()
  Nav.SetScriptedPath(Handle(self.PATH .. "tanks\\VH_NZ_TK_Renault_North"), "Missions\\freeplay\\p1\\mis_placerepub_convoy\\main\\PATH_TankN", false, "P1FP_DestroyConvoy.NTankAttacks", self, {})
  Nav.SetScriptedPathSpeed(Handle(self.PATH .. "tanks\\VH_NZ_TK_Renault_North"), 70)
  Nav.SetScriptedPath(Handle(self.PATH .. "tanks\\VH_NZ_TK_Renault_South"), "Missions\\freeplay\\p1\\mis_placerepub_convoy\\main\\PATH_TankS", false, "P1FP_DestroyConvoy.STankAttacks", self, {})
  Nav.SetScriptedPathSpeed(Handle(self.PATH .. "tanks\\VH_NZ_TK_Renault_South"), 70)
  Nav.SetScriptedPath(Handle(self.PATH .. "tanks\\VH_NZ_TK_KingTiger"), "Missions\\freeplay\\p1\\mis_placerepub_convoy\\main\\PATH_KingTiger", false, "P1FP_DestroyConvoy.KingTigerAttacks", self, {})
  Nav.SetScriptedPathSpeed(Handle(self.PATH .. "tanks\\VH_NZ_TK_KingTiger"), 70)
end

function P1FP_DestroyConvoy:NTankAttacks()
  local hTankGunner = Vehicle.GetSeatActor(Handle(self.PATH .. "tanks\\VH_NZ_TK_Renault_North"), "GUNNER")
  Combat.SetTarget(hTankGunner, hSab)
  Combat.SetCombat(hTankGunner)
end

function P1FP_DestroyConvoy:STankAttacks()
  local hTankGunner = Vehicle.GetSeatActor(Handle(self.PATH .. "tanks\\VH_NZ_TK_Renault_South"), "GUNNER")
  Combat.SetTarget(hTankGunner, hSab)
  Combat.SetCombat(hTankGunner)
end

function P1FP_DestroyConvoy:KingTigerAttacks()
  local hTankGunner = Vehicle.GetSeatActor(Handle(self.PATH .. "tanks\\VH_NZ_TK_KingTiger"), "GUNNER")
  Combat.SetTarget(hTankGunner, hSab)
  Combat.SetCombat(hTankGunner)
end

function P1FP_DestroyConvoy:FailTruckEscaped1()
  self:MissionTaskFail("P1FP_DestroyConvoy_Text.Fail_TargetEscaped")
end

function P1FP_DestroyConvoy:FailTruckEscaped2()
  self:MissionTaskFail("P1FP_DestroyConvoy_Text.Fail_TargetEscaped")
end

function P1FP_DestroyConvoy:FailTruckEscaped3()
  self:MissionTaskFail("P1FP_DestroyConvoy_Text.Fail_TargetEscaped")
end

function P1FP_DestroyConvoy:MISSION_ONRESET()
  Util.SetDynamicPriority("VH_NZ_TR_OpelCanvas_01", -1)
end
