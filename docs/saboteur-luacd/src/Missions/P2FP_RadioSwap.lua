if P2FP_RadioSwap == nil then
  P2FP_RadioSwap = SabTaskObjective:Create()
  P2FP_RadioSwap.sPATH = "Missions\\freeplay\\p2\\mis_louvre_radioswap\\"
  P2FP_RadioSwap:Configure({
    TaskCount = 99,
    sStarter = "Margot_Boulogne_Interior",
    bFreeplay = true,
    sSaveMissionNameID = "MissionNames_Text.P2FP_RadioSwap",
    sActNameID = "MissionNames_Text.ACT_Margot",
    tUnlockList = {},
    sConvFile = "P2FP_RadioSwap_Start",
    tSMEDNodes = {
      P2FP_RadioSwap.sPATH .. "task",
      P2FP_RadioSwap.sPATH .. "main"
    },
    tStaticTags = {
      "p2fp_radioswap_mission"
    },
    tCinematicNodes = {
      "wtf_fp_playmymusic"
    }
  })
end

function P2FP_RadioSwap:STARTER_Setup()
end

function P2FP_RadioSwap:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "RadioSwap"
  self.bDebugMode = false
  dprint(self, "Running RadioSwap.")
  self.SetupCheckpoint(self, 0)
  Sound.LoadSoundBank("m_P2FP_RadioSwap")
end

function P2FP_RadioSwap:GENERAL_Setup()
end

function P2FP_RadioSwap:SetupVariables()
  self.hSab = self.hSab or Handle("Saboteur")
  self.eTankEvent = self.eTankEvent or {}
  self.nRadioDead = self.nRadioDead or 0
  self.sLouvreLoc = self.sLouvreLoc or self.sPATH .. "task\\LOC_LouvreLoc"
  self.sLouvreTrig = self.sLouvreTrig or self.sPATH .. "task\\TRIG_LouvreTrig"
  self.sInvulnTrig = self.sInvulnTrig or self.sPATH .. "main\\TRIG_TowerInvuln"
  self.sRadio = self.sRadio or self.sPATH .. "mission\\OccLt_RadioTower_50M\\OccLt_RadioTower_50M"
  self.sRadioLoc = self.sRadioLoc or self.sPATH .. "main\\LOC_Radio"
  self.tTanks = self.tTanks or {
    self.sPATH .. "mission\\Tank01",
    self.sPATH .. "mission\\Tank02"
  }
  self.tTankOnFirstPath = self.tTankOnFirstPath or {true, true}
  self.tTankFinishedPath = self.tTankFinishedPath or {true, true}
  self.sPlayerTank = self.sPlayerTank or self.sPATH .. "mission\\PlayerTank01"
  self.sPlayerTankLoc = self.sPlayerTankLoc or self.sPATH .. "main\\LOC_SeePlayerTank"
  self.tTankPathsFirst = self.tTankPathsFirst or {
    self.sPATH .. "wtf_low\\PA_TankPath01a",
    self.sPATH .. "wtf_low\\PA_TankPath02a"
  }
  self.tTankPathsSecond = self.tTankPathsSecond or {
    self.sPATH .. "wtf_low\\PA_TankPath01b",
    self.sPATH .. "wtf_low\\PA_TankPath02b"
  }
  self.tAmbientSoundEmitLocations = self.tAmbientSoundEmitLocations or {
    "Missions\\freeplay\\ambient\\p2\\p2_tower_25\\FP_AMB_Tower_Short\\Target",
    "Missions\\freeplay\\ambient\\p2\\p2_speaker_01\\FP_AMB_PropSpeaker\\Target",
    "Missions\\freeplay\\ambient\\p2\\p2_speaker_02\\FP_AMB_PropSpeaker\\Target"
  }
  self.tSoundEmitters = self.tSoundEmitters or {
    self.sPATH .. "sound\\Emt_PlayMyMusic_Propaganda",
    self.sPATH .. "sound\\Emt_PlayMyMusic_Propaganda(1)",
    self.sPATH .. "sound\\Emt_PlayMyMusic_Propaganda(2)"
  }
  self.tEmittersEnabled = self.tEmittersEnabled or {
    false,
    false,
    false
  }
end

function P2FP_RadioSwap:SetupEvents()
  for i, sObject in ipairs(self.tTanks) do
    local tStreamEvent = {
      EventType = "StreamEvent",
      Objects = {sObject},
      WaitForGameObject = true
    }
    self:RegisterEvent(Util.CreateEvent(tStreamEvent, "P2FP_RadioSwap.OnTankStream", self, {sObject, i}))
  end
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      self.sRadio
    },
    WaitForGameObject = true
  }
  self:RegisterEvent(Util.CreateEvent(tStreamEvent, "P2FP_RadioSwap.OnRadioStream", self))
end

function P2FP_RadioSwap:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "P2FP_RadioSwap.DoCheckpoint")
end

function P2FP_RadioSwap:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  if nCP < 3 then
    self.SetupVariables(self)
  end
  if nCP == 0 then
    self.ExitHQ(self)
    self.Task_FindLouvre(self)
  elseif nCP == 1 then
    if not self:IsMissionTaskActive("P2FP_RadioSwap_Task_FindLouvre") then
      self.Task_FindLouvre(self)
    end
  elseif nCP == 2 then
    self.SetupProxEvent(self)
    Sound.SetMusicLocale("fp_P2FP_RadioSwap")
    Sound.SetMusicLocale("fp_P2FP_RadioSwap", "enterLouvre")
    self.SetupEvents(self)
    self.Task_DestroyConsole(self)
    self.ActivateSoundEmitters(self)
  elseif nCP == 3 then
    self.Task_LoseEscalation(self)
  end
end

function P2FP_RadioSwap:ExitHQ()
  self:CreateTask({
    sName = "P2FP_RadioSwap_ExitHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "Boulogne",
    bInteriorTask = true,
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 1}
      }
    }
  })
end

function P2FP_RadioSwap:Task_FindLouvre()
  self:CreateTask({
    sName = "P2FP_RadioSwap_Task_FindLouvre",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P2FP_RadioSwap_Text.Task_FindLouvre",
    tDeliverObjs = {
      self.hSab
    },
    tLocators = {
      self.sLouvreLoc
    },
    tDestRegion = {
      self.sLouvreTrig
    },
    bGroundBlip = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.BrakeVehicle,
        {self}
      },
      {
        self.SetupCheckpoint,
        {self, 2}
      }
    }
  })
end

function P2FP_RadioSwap:Task_DestroyConsole()
  self:CreateTask({
    sName = "P2FP_RadioSwap_Task_DestroyConsole",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "NONE",
    tLocators = {
      self.sRadioLoc
    },
    sObjectiveTextID = "P2FP_RadioSwap_Text.Task_DestroyConsole",
    bNoGPS = true,
    tOnActivate = {
      {
        self.CheckInvuln,
        {self}
      }
    },
    tOnComplete = {
      {
        self.DeactivateSoundEmitters,
        {self}
      },
      {
        Util.UnloadStaticENTag,
        {
          "p2fp_radioswap_mission",
          false,
          true
        }
      },
      {
        self.CinTest,
        {self}
      }
    }
  })
end

function P2FP_RadioSwap:CinTest()
  if Cin.IsPlayerCloseToCinematic(self.sPATH .. "main\\LOC_Radio") then
    Cin.PlayCinematic("WTF_FP_PlayMyMusic", false, "P2FP_RadioSwap.DoCleanup", self, {2}, false, "")
  else
    Cin.PlayCinematic("WTF_FP_PlayMyMusic_NOCAM", false, "P2FP_RadioSwap.DoCleanup", self, {2}, false, "")
  end
end

function P2FP_RadioSwap:Task_LoseEscalation()
  self:CreateTask({
    sName = "P2FP_RadioSwap_Task_LoseEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "NONE",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    EscalationLevel = 0,
    tOnActivate = {},
    tOnComplete = {
      {
        self.DoCleanup,
        {self, 1}
      }
    }
  })
end

function P2FP_RadioSwap:DoCleanup(...)
  local a_tCallbackData, a_nOption
  if arg.n == 1 then
    a_nOption = unpack(arg)
  else
    a_tCallbackData, a_nOption = unpack(arg)
  end
  if a_nOption == 1 then
    Util.UnloadStaticENTag("p2fp_radioswap_wtf_low", false)
    Util.UnloadStaticENTag("p3fp_radioswap_props", false)
    Util.LoadStaticENTag("Louvre_Foliage_Return", false)
    Sound.ResetMusicLocale()
    self:CompleteThisMission()
  elseif a_nOption == 2 then
    self.CheckEscalation(self)
  end
end

function P2FP_RadioSwap:OnTankStream(a_sObject, a_nIndex)
  local hObj = Handle(a_sObject)
  local sPath = self.tTankPathsFirst[a_nIndex]
  self.MoveOnPath(self, hObj, a_nIndex)
  local hPilot = Vehicle.GetPilot(hObj)
  if hPilot then
    self.SetupCombatEnter(self, hObj, a_nIndex, hPilot)
  else
    local tTimerEvent = {EventType = "TimerEvent", Time = 0.5}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P2FP_RadioSwap.SetupCombatEnter", self, {hObj, a_nIndex}))
  end
  self:RegisterEvent(EVENT_ActorDeath("P2FP_RadioSwap.TankDied", self, hObj, {hObj, a_nIndex}))
end

function P2FP_RadioSwap:SetupCombatEnter(a_hVehicle, a_nIndex, a_hPilot)
  local hPilot = a_hPilot
  hPilot = hPilot or Vehicle.GetPilot(a_hVehicle)
  if not hPilot then
    local tTimerEvent = {EventType = "TimerEvent", Time = 0.5}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P2FP_RadioSwap.SetupCombatEnter", self, {a_hVehicle, a_nIndex}))
    return
  end
  local tCombatEnter = {
    EventType = "OnCombatEnter",
    Target = hPilot
  }
  self.eTankEvent[a_nIndex] = Util.CreateEvent(tCombatEnter, "P2FP_RadioSwap.TankEnteredCombat", self, {
    a_hVehicle,
    a_nIndex,
    hPilot
  })
  self:RegisterEvent(self.eTankEvent[a_nIndex])
end

function P2FP_RadioSwap:OnRadioStream()
  self.hRadio = Handle(self.sRadio)
  local tDeathEvent = {
    EventType = "DeathEvent",
    ObjectHandle = self.hRadio
  }
  self:RegisterEvent(Util.CreateEvent(tDeathEvent, "P2FP_RadioSwap.RadioDead", self))
end

function P2FP_RadioSwap:SeanAffectingInvulnTrig(...)
  local a_tCallbackData, a_bSetInvuln
  if arg.n == 1 then
    a_bSetInvuln = unpack(arg)
  else
    a_tCallbackData, a_bSetInvuln = unpack(arg)
  end
  local bTaskActive = self:IsMissionTaskActive("P2FP_RadioSwap_Task_DestroyConsole")
  if self.hRadio and Object.IsAlive(self.hRadio) and bTaskActive then
    Object.SetInvincible(self.hRadio, a_bSetInvuln)
  end
end

function P2FP_RadioSwap:CheckInvuln()
  local tEntities = Trigger.GetAllWithin(Handle(self.sInvulnTrig))
  if tEntities then
    for i, hEnt in ipairs(tEntities) do
      if hEnt == self.hSab then
        if self.hRadio and Object.IsAlive(self.hRadio) then
          Object.SetInvincible(self.hRadio, false)
        end
        break
      end
    end
  end
end

function P2FP_RadioSwap:RadioDead()
  self:CompleteTaskByName("P2FP_RadioSwap_Task_DestroyConsole")
  Trigger.DoNotWaitFor(self.sInvulnTrig, self.hSab)
end

function P2FP_RadioSwap:MoveOnPath(a_hObject, a_nIndex)
  if not self.tTankFinishedPath[a_nIndex] then
    self.tTankFinishedPath[a_nIndex] = true
    self.tTankOnFirstPath[a_nIndex] = not self.tTankOnFirstPath[a_nIndex]
  end
  if self.tTankOnFirstPath[a_nIndex] == true then
    Nav.SetScriptedPath(a_hObject, self.tTankPathsFirst[a_nIndex], true, "P2FP_RadioSwap.MoveOnPath", self, {a_hObject, a_nIndex})
  else
    Nav.SetScriptedPath(a_hObject, self.tTankPathsSecond[a_nIndex], true, "P2FP_RadioSwap.MoveOnPath", self, {a_hObject, a_nIndex})
  end
  self.tTankOnFirstPath[a_nIndex] = not self.tTankOnFirstPath[a_nIndex]
  Nav.SetScriptedPathSpeed(a_hObject, 10)
end

function P2FP_RadioSwap:TankEnteredCombat(a_tCallbackData, a_hObject, a_nIndex, a_hPilot)
  Nav.CancelScriptedPath(a_hObject)
  self.tTankFinishedPath[a_nIndex] = false
  local tCombatExit = {
    EventType = "OnCombatExit",
    Target = a_hPilot
  }
  self.eTankEvent[a_nIndex] = Util.CreateEvent(tCombatExit, "P2FP_RadioSwap.TankExitedCombat", self, {
    a_hObject,
    a_nIndex,
    a_hPilot
  })
end

function P2FP_RadioSwap:TankExitedCombat(a_tCallbackData, a_hObject, a_nIndex, a_hPilot)
  local tCombatEnter = {
    EventType = "OnCombatEnter",
    Target = a_hPilot
  }
  self.eTankEvent[a_nIndex] = Util.CreateEvent(tCombatEnter, "P2FP_RadioSwap.TankEnteredCombat", self, {
    a_hObject,
    a_nIndex,
    a_hPilot
  })
  self.MoveOnPath(self, a_hObject, a_nIndex)
end

function P2FP_RadioSwap:TankDied(a_hObject, a_nIndex)
  Nav.CancelScriptedPath(a_hObject)
  Util.KillEvent(self.eTankEvent[a_nIndex])
  self.eTankEvent[a_nIndex] = nil
end

function P2FP_RadioSwap:SetupProxEvent()
  local tSightEvent = {
    EventType = "SeeLocatorEvent",
    InViewTime = 1,
    Locator = self.sPlayerTankLoc,
    Proximity = 35
  }
  self:RegisterEvent(Util.CreateEvent(tSightEvent, "P2FP_RadioSwap.DoSightCheck", self))
end

function P2FP_RadioSwap:DoSightCheck()
  Cin.PlayConversation("P2FP_RadioSwap_SeeTank", "P2FP_RadioSwap.PlayTutorial", self)
end

function P2FP_RadioSwap:PlayTutorial()
  Saboteur.ShowToolTip("TutorialTip_Text.Boarding_Tanks")
  if self.eEnteredVehicle then
    Util.KillEvent(self.eEnteredVehicle)
    self.eEnteredVehicle = nil
  end
end

function P2FP_RadioSwap:CheckEscalation()
  if Suspicion.GetEscalation() > 0 or Suspicion.IsSomeoneHostileOrHunting() then
    self.SetupCheckpoint(self, 3)
  else
    self.DoCleanup(self, 1)
  end
end

function P2FP_RadioSwap:BrakeVehicle()
  local hVeh
  if Actor.IsInVehicle(self.hSab) then
    hVeh = Actor.GetVehicle(self.hSab)
  end
  if hVeh then
    Vehicle.BrakeTo(hVeh, 0)
    self.SetupBrakeCheck(self, hVeh)
  end
end

function P2FP_RadioSwap:SetupBrakeCheck(a_hVeh)
  local tTimerEvent = {EventType = "TimerEvent", Time = 0.25}
  self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P2FP_RadioSwap.CheckSpeed", self, {a_hVeh}))
end

function P2FP_RadioSwap:CheckSpeed(a_hVeh)
  local hVeh
  if Actor.IsInVehicle(self.hSab) then
    hVeh = Actor.GetVehicle(self.hSab)
    if hVeh == a_hVeh then
      if Vehicle.GetSpeed(hVeh) < 1 then
        local tTimerEvent = {EventType = "TimerEvent", Time = 2}
        self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P2FP_RadioSwap.ResetVehSpeed", self, {hVeh}))
      else
        self.SetupBrakeCheck(self, hVeh)
      end
    end
  elseif Object.IsAlive(a_hVeh) then
    self.ResetVehSpeed(self, a_hVeh)
  end
end

function P2FP_RadioSwap:ResetVehSpeed(a_hVeh)
  Vehicle.BrakeTo(a_hVeh, 200)
end

function P2FP_RadioSwap:ActivateSoundEmitters()
  for i, sEmitter in ipairs(self.tSoundEmitters) do
    local hAmbObj = Handle(self.tAmbientSoundEmitLocations[i])
    if hAmbObj and Object.IsAlive(hAmbObj) then
      if sEmitter then
        local hEm = Handle(sEmitter)
        self.tEmittersEnabled[i] = true
        Sound.ActivateSoundEmitter(hEm)
      else
      end
    else
      self.SetupEmitterCheckTimer(self, sEmitter, i)
    end
  end
end

function P2FP_RadioSwap:SetupEmitterCheckTimer(a_sEmitter, a_nIndex)
  local tTimerEvent = {EventType = "TimerEvent", Time = 1}
  self.tEmitterTimers = self.tEmitterTimers or {}
  self.tEmitterTimers[a_nIndex] = Util.CreateEvent(tTimerEvent, "P2FP_RadioSwap.CheckEmitterStatus", self, {a_sEmitter, a_nIndex})
  self:RegisterEvent(self.tEmitterTimers[a_nIndex])
end

function P2FP_RadioSwap:CheckEmitterStatus(a_sEmitter, a_nIndex)
  local hAmbObj = Handle(self.tAmbientSoundEmitLocations[a_nIndex])
  if hAmbObj and Object.IsAlive(hAmbObj) then
    local hEm = Handle(a_sEmitter)
    self.tEmittersEnabled[a_nIndex] = true
    Sound.ActivateSoundEmitter(hEm)
  else
    self.SetupEmitterCheckTimer(self, a_sEmitter, a_nIndex)
  end
end

function P2FP_RadioSwap:DeactivateSoundEmitters()
  if self.tEmitterTimers then
    for i, eTimer in ipairs(self.tEmitterTimers) do
      Util.KillEvent(eTimer)
    end
  end
  self.tEmitterTimers = {}
  for i, sEmitter in ipairs(self.tSoundEmitters) do
    if self.tEmittersEnabled[i] == true then
      local hEm = Handle(sEmitter)
      if hEm then
        Sound.DeactivateSoundEmitter(hEm)
        self.tEmittersEnabled[i] = false
      end
    end
  end
end

function P2FP_RadioSwap:MISSION_ONCANCEL()
  Sound.ResetMusicLocale()
  Zone.SwitchState("WtF_Zones\\global\\FP_FinalFreeplay", cZONESTATE_LOWWTF, cENT_IMMEDIATE, false)
end

function P2FP_RadioSwap:MISSION_ONRESET()
  self.DeactivateSoundEmitters(self)
  Sound.ReleaseSoundBank("m_P2FP_RadioSwap")
end
