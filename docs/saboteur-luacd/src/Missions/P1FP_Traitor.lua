if P1FP_Traitor == nil then
  P1FP_Traitor = SabTaskObjective:Create()
  MISSIONPATH1 = "Missions\\freeplay\\p1\\mis_belle_w_snitch\\"
  P1FP_Traitor.PATH = "Missions\\freeplay\\p1\\mis_belle_w_snitch\\"
  P1FP_Traitor:Configure({
    TaskCount = 999,
    sSaveMissionNameID = "MissionNames_Text.P1FP_Traitor",
    tDependencyList = {},
    tUnlockList = {
      "NOTE_Jailbreak",
      "P1FP_Jailbreak"
    },
    bFreeplay = true,
    sStarter = "vittore_belle_bar",
    sConvFile = "210_Con_Snitch",
    tSMEDNodes = {
      P1FP_Traitor.PATH .. "task",
      P1FP_Traitor.PATH .. "main"
    }
  })
end

function P1FP_Traitor:STARTER_Setup()
  Zone.SwitchState("WtF_Zones\\global\\P1M1B_SlaughterhouseLiberate", cZONESTATE_HIGHCOLOR_HIGHTAG, cENT_IMMEDIATE)
end

function P1FP_Traitor:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "FP.TRAITOR"
  self.bDebugMode = false
  self.GENERAL_Setup(self)
  self.SetupCheckpoint(self, 3)
end

function P1FP_Traitor:GENERAL_Setup()
end

function P1FP_Traitor:SetupVariables()
  self.hSab = self.hSab or Handle("Saboteur")
  self.sNaziGeneral = self.sNaziGeneral or self.PATH .. "main\\General"
  self.hGeneral = self.hGeneral or Handle(self.sNaziGeneral)
  self.sGotoLOC = self.sGotoLOC or self.PATH .. "task\\LOC_GeneralArea"
  self.sGotoTrig = self.sGotoTrig or self.PATH .. "task\\PT_GeneralArea"
  self.sDummyTrig = self.sDummyTrig or self.PATH .. "main\\TRIG_Dummy"
  self.nPathNum = self.nPathNum or 0
  self.nConvoIndex = self.nConvoIndex or 0
  self.bGeneralIsWandering = self.bGeneralIsWandering or false
  self.bPlayingConversation = self.bPlayingConversation or false
  self.bSeanInGeneralDisguise = self.bSeanInGeneralDisguise or false
  self.nProxSubDist = self.nProxSubDist or 30
  self.tGeneralPaths = self.tGeneralPaths or {
    self.PATH .. "main\\PA_NewPath01",
    self.PATH .. "main\\PA_NewPath02",
    self.PATH .. "main\\PA_NewPath03"
  }
  self.sWhore = self.sWhore or self.PATH .. "main\\Whore"
  self.bWhoreSpawned = self.bWhoreSpawned or false
  self.bSnitchSpawned = self.bSnitchSpawned or false
  self.tSpawnLocs = self.tSpawnLocs or {
    self.PATH .. "main\\LOC_SpawnA",
    self.PATH .. "main\\LOC_SpawnB"
  }
  self.tSnitchPaths = self.tSnitchPaths or {
    self.PATH .. "main\\PA_SnitchPath01",
    self.PATH .. "main\\PA_SnitchPath02"
  }
  self.sTraitorBlueprint = "Human_NZ_Snitch_FP"
  self.sSnitchTrig = self.sSnitchTrig or self.PATH .. "main\\TRIG_SpawnSnitch"
  self.sImpersonateLoc = self.sImpersonateLoc or self.PATH .. "main\\LOC_Impersonate"
  self.sImpersonateTrig = self.sImpersonateTrig or self.PATH .. "main\\TRIG_Impersonate"
  self.sSnitchIdentTrig1 = self.sSnitchIdentTrig1 or self.PATH .. "main\\TRIG_SnitchIdentify1"
  self.sSnitchIdentTrig2 = self.sSnitchIdentTrig2 or self.PATH .. "main\\TRIG_SnitchIdentify2"
end

function P1FP_Traitor:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  if a_nCP == 2 then
    self.RegisterCheckpoint(self, "P1FP_Traitor.DoCheckpoint", "P1FP_Traitor.DoImmediateCheck")
  else
    self.RegisterCheckpoint(self, "P1FP_Traitor.DoCheckpoint")
  end
end

function P1FP_Traitor:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  self.SetupVariables(self)
  if nCP == 1 then
    if not self:IsMissionTaskActive("P1FP_Traitor.TASK_GoToGeneral") then
      self.TASK_GoToGeneral(self)
    end
    self.SetupEscalationFail(self)
    self.SetupGeneralDeath(self)
  elseif nCP == 2 then
    Suspicion.ResetEscalation()
    self.RunCheckpointInfo(self)
  elseif nCP == 3 then
    self.TASK_GoToGeneral(self)
    self.ExitHQ(self)
  end
end

function P1FP_Traitor:DoImmediateCheck()
  self.RunCheckpointInfo(self)
end

function P1FP_Traitor:RunCheckpointInfo()
  Sound.SetMusicLocale("fp_P1FP_Traitor")
  Sound.SetMusicLocale("fp_P1FP_Traitor", "tailingTarget")
  self.nPathNum = 0
  self.bSnitchSpawned = false
  self.bSeanInGeneralDisguise = false
  self.bSnitchBeingAttacked = false
  self.SetupProximityMeter(self)
  self.SetupGeneralStream(self)
  self.SetupGeneralDeath(self)
  self.SetupPlayerDeathEvent(self)
  self.TASK_EnterBelle(self)
  self.SetupEscalationFail(self)
  self.DoWhoreStarterConvo(self)
  self.TASK_TailGeneral(self)
end

function P1FP_Traitor:ExitHQ()
  self:CreateTask({
    sName = "ExitHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "Belle",
    bInteriorTask = true,
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 1}
      }
    }
  })
end

function P1FP_Traitor:TASK_GoToGeneral()
  self:CreateTask({
    sName = "P1FP_Traitor.TASK_GoToGeneral",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tLocators = {
      self.sGotoLOC
    },
    tDestRegion = {
      self.sGotoTrig
    },
    tDeliverObjs = {
      self.hSab
    },
    sObjectiveTextID = "P1FP_Traitor_Text.TASK_GoToGeneral",
    bGroundBlip = true,
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 2}
      }
    }
  })
end

function P1FP_Traitor:TASK_TailGeneral()
  self:CreateTask({
    sName = "P1FP_Traitor.TASK_TailGeneral",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tLocators = {
      self.sNaziGeneral
    },
    tDestRegion = {
      self.sDummyTrig
    },
    tDeliverObjs = {
      self.hSab
    },
    sObjectiveTextID = "P1FP_Traitor_Text.TASK_TailGeneral",
    bNoGPS = true,
    tOnActivate = {
      {
        self.SetupEscLiteCheck,
        {self}
      }
    },
    tOnComplete = {
      {
        Util.KillEvent,
        {
          self.eSeanDeath
        }
      }
    }
  })
end

function P1FP_Traitor:TASK_GetGeneralDisguise()
  self:CreateTask({
    sName = "P1FP_Traitor.TASK_GetGeneralDisguise",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tLocators = {
      self.sNaziGeneral
    },
    tDestRegion = {
      "Missions\\freeplay\\p1\\mis_belle_w_snitch\\main\\TRIG_Dummy"
    },
    tDeliverObjs = {
      self.hSab
    },
    sObjectiveTextID = "P1FP_Traitor_Text.TASK_GetGeneralDisguise",
    bNoGPS = true,
    tOnActivate = {},
    tOnComplete = {}
  })
end

function P1FP_Traitor:TASK_ImpersonateGeneral()
  self:CreateTask({
    sName = "P1FP_Traitor.TASK_ImpersonateGeneral",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tLocators = {
      self.sImpersonateLoc
    },
    tDestRegion = {
      self.sImpersonateTrig
    },
    tDeliverObjs = {
      self.hSab
    },
    sObjectiveTextID = "P1FP_Traitor_Text.TASK_ImpersonateGeneral",
    bNoGPS = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.CheckCurrentTask,
        {self}
      }
    }
  })
end

function P1FP_Traitor:TASK_WaitForSnitch()
  self:CreateTask({
    sName = "P1FP_Traitor.TASK_WaitForSnitch",
    sTaskType = "SabTaskObjectiveEmpty",
    sObjectiveTextID = "P1FP_Traitor_Text.TASK_WaitForSnitch",
    sTaskSubType = "NONE",
    tOnActivate = {},
    tOnComplete = {}
  })
end

function P1FP_Traitor:TASK_KillTraitor()
  self:CreateTask({
    sName = "P1FP_Traitor.TASK_KillTraitor",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "KILL",
    tTgtInclude = {
      self.hSnitch
    },
    sObjectiveTextID = "P1FP_Traitor_Text.TASK_KillTraitor",
    bNoGPS = true,
    tOnActivate = {
      {
        self.CancelSnitchDamageEvent,
        {self}
      }
    },
    tOnComplete = {
      {
        self.CleanUpMission,
        {self}
      },
      {
        self.DelayComplete,
        {self}
      }
    }
  })
end

function P1FP_Traitor:TASK_EnterBelle()
  self:CreateTask({
    sName = "P1FP_Traitor.TASK_EnterBelle",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "EnterInterior",
    sInteriorName = "Belle",
    tOnComplete = {
      {
        self.FailMission,
        {
          self,
          "P1FP_Traitor_Text.MissionFail2"
        }
      }
    }
  })
end

function P1FP_Traitor:SetupPlayerDeathEvent()
  local tDeathEvent = {
    EventType = "DeathEvent",
    ObjectHandle = self.hSab
  }
  self.eSeanDeath = Util.CreateEvent(tDeathEvent, "P1FP_Traitor.CleanUpMission", self)
  self:RegisterEvent(self.eSeanDeath)
end

function P1FP_Traitor:SetupGeneralDeath()
  Util.KillEvent("EVT_GeneralDeath")
  local tDeathEvent = {
    EventType = "OnDeath",
    Target = self.hGeneral,
    EventName = "EVT_GeneralDeath"
  }
  self:RegisterEvent(Util.CreateEvent(tDeathEvent, "P1FP_Traitor.CheckLocationAndWitnesses", self))
  Util.KillEvent("EVT_GeneralDamage")
  local tDamageEvent = {
    EventType = "DamageEvent",
    ObjectHandle = self.hGeneral,
    EventName = "EVT_GeneralDamage"
  }
  self:RegisterEvent(Util.CreateEvent(tDamageEvent, "P1FP_Traitor.GeneralDamaged", self))
end

function P1FP_Traitor:SetupGeneralStream()
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      self.sNaziGeneral
    },
    WaitForGameObject = true
  }
  self:RegisterEvent(Util.CreateEvent(tStreamEvent, "P1FP_Traitor.RegisterAsSpawned", self, {
    self.sNaziGeneral
  }))
  tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      self.sWhore
    },
    WaitForGameObject = true
  }
  self:RegisterEvent(Util.CreateEvent(tStreamEvent, "P1FP_Traitor.RegisterAsSpawned", self, {
    self.sWhore
  }))
end

function P1FP_Traitor:RegisterAsSpawned(a_sEntity)
  if a_sEntity == self.sNaziGeneral then
    self.hGeneral = self.hGeneral or Handle(a_sEntity)
  else
    self.hWhore = self.hWhore or Handle(a_sEntity)
  end
end

function P1FP_Traitor:DoWhoreStarterConvo()
  if self.hWhore and Object.IsAlive(self.hWhore) and self.hGeneral and Object.IsAlive(self.hGeneral) then
    self.CheckSubtitleDist(self, self.hWhore)
    Cin.PlayConversation("P1FP_Traitor_Whore1", "P1FP_Traitor.DoConvoWithWhore", self)
  elseif self.hWhore and Object.IsAlive(self.hWhore) == false then
    self.SetupGeneralToMove(self)
  else
    local tTimerEvent = {EventType = "TimerEvent", Time = 0.25}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Traitor.DoWhoreStarterConvo", self))
  end
end

function P1FP_Traitor:DoConvoWithWhore()
  self.RevertSubtitles(self)
  if self.hWhore and Object.IsAlive(self.hWhore) then
    self.CheckSubtitleDist(self, self.hWhore)
    Cin.PlayConversation("P1FP_Traitor_Whore2", "P1FP_Traitor.SetupGeneralToMove", self)
  else
    Suspicion.SetEscalationLevel(1)
    self.SetupGeneralToMove(self)
  end
end

function P1FP_Traitor:SetupGeneralToMove()
  self.SetupFailEvents(self)
  self.RevertSubtitles(self)
  Object.SetInvincibleToAI(self.hGeneral, true)
  Actor.SetVehicleAvoidance(self.hGeneral, false)
  Combat.SetIdleScripted(self.hGeneral, true)
  Actor.OverrideCombatAI(self.hGeneral, true)
  self.SetGeneralOnPath(self)
end

function P1FP_Traitor:SetGeneralOnPath()
  self.nPathNum = self.nPathNum + 1
  Nav.SetScriptedPath(self.hGeneral, self.tGeneralPaths[self.nPathNum], true, "P1FP_Traitor.GeneralFinishedPath", self)
  Nav.SetScriptedPathMoveMode(self.hGeneral, false)
end

function P1FP_Traitor:GeneralFinishedPath()
  if self.nPathNum == 1 or self.nPathNum == 2 then
    local tTurnToEvent = {EventType = "TimerEvent", Time = 0.25}
    self:RegisterEvent(Util.CreateEvent(tTurnToEvent, "P1FP_Traitor.EntityFaceEntity", self, {
      self.hGeneral,
      self.hSab,
      false
    }))
    local tUpdateEvent = {EventType = "TimerEvent", Time = 7}
    self:RegisterEvent(Util.CreateEvent(tUpdateEvent, "P1FP_Traitor.UpdateAnimAndMovement", self, {99, false}))
    if self.nPathNum == 2 then
      self.RegisterSnitchTrigger(self)
    end
  end
end

function P1FP_Traitor:EntityFaceEntity(a_vEntity, a_vTarget)
  if type(a_vEntity) == "string" then
    a_vEntity = Handle(a_vEntity)
  end
  if type(a_vTarget) == "string" then
    a_vTarget = Handle(a_vTarget)
  end
  Actor.SetFacingDir(a_vEntity, a_vTarget)
end

function P1FP_Traitor:UpdateAnimAndMovement(a_nIndex, a_bCancelAnim)
  if a_nIndex == 99 then
    if a_bCancelAnim then
      Actor.CancelAnimation(self.hGeneral)
    end
    self.SetGeneralOnPath(self)
  end
end

function P1FP_Traitor:RegisterSnitchTrigger()
  self:RegisterTriggerEvent(Trigger.WaitFor(self.sSnitchTrig, self.hGeneral, "P1FP_Traitor.OnFoundSnitchSpawn", self, nil), self.sSnitchTrig)
end

function P1FP_Traitor:OnFoundSnitchSpawn()
  local hFarthest = Handle(self.tSpawnLocs[1])
  local nWhich = 1
  for i, sLoc in ipairs(self.tSpawnLocs) do
    local hLoc = Handle(sLoc)
    if Object.GetDistance(self.hSab, hLoc) > Object.GetDistance(self.hSab, hFarthest) then
      hFarthest = hLoc
      nWhich = i
    end
  end
  if not self.bSnitchSpawned then
    Tips.SpawnAtLoc(self.sTraitorBlueprint, hFarthest, "P1FP_Traitor.OnTraitorSpawns", self, {nWhich})
  end
end

function P1FP_Traitor:OnTraitorSpawns(a_tSpawnData, a_nWhich)
  self.bCanDoSnitchDamageEvent = true
  self.bSnitchSpawned = true
  self.hSnitch = a_tSpawnData[1]
  local tDeathEvent = {
    EventType = "DeathEvent",
    ObjectHandle = self.hSnitch
  }
  self:RegisterEvent(Util.CreateEvent(tDeathEvent, "P1FP_Traitor.SnitchDead", self))
  tStreamEvent = {
    EventType = "StreamEvent",
    EventName = "SnitchStreamEvent",
    Objects = {
      self.hSnitch
    },
    WaitForStreamOut = true
  }
  self.SnitchStreamEvent = Util.CreateEvent(tStreamEvent, "P1FP_Traitor.FailMission", self, {
    "P1FP_Traitor_Text.MissionFail7"
  })
  self:RegisterEvent(self.SnitchStreamEvent)
  Combat.SetIdleScripted(self.hSnitch, true)
  Actor.OverrideCombatAI(self.hSnitch, true)
  Actor.SetVehicleAvoidance(self.hSnitch, false)
  Suspicion.Enable(self.hSnitch, false)
  Actor.SetPanicEnabled(self.hSnitch, false)
  Actor.EnableNeeds(self.hSnitch, false)
  Nav.SetScriptedPath(self.hSnitch, self.tSnitchPaths[a_nWhich], true, "P1FP_Traitor.OnTraitorReachesGeneral", self)
  Nav.SetScriptedPathMoveMode(self.hSnitch, false)
  if a_nWhich == 1 then
    self:RegisterTriggerEvent(Trigger.WaitFor(self.sSnitchIdentTrig1, self.hSnitch, "P1FP_Traitor.SetupProxEvent", self, nil), self.sSnitchIdentTrig1)
  else
    self:RegisterTriggerEvent(Trigger.WaitFor(self.sSnitchIdentTrig2, self.hSnitch, "P1FP_Traitor.SetupProxEvent", self, nil), self.sSnitchIdentTrig2)
  end
end

function P1FP_Traitor:SnitchDead()
  if not self.nConvoIndex or self.nConvoIndex < 1 then
    self.FailMission(self, "P1FP_Traitor_Text.MissionFail5")
  elseif self.nConvoIndex < 2 then
    self.FailMission(self, "P1FP_Traitor_Text.MissionFail6")
  else
    Cin.PlayConversation("P1FP_Traitor_SnitchDead", "P1FP_Traitor.CompleteKillSnitchTask", self)
  end
end

function P1FP_Traitor:CompleteKillSnitchTask()
  if self:IsMissionTaskActive("P1FP_Traitor.TASK_KillTraitor") then
    self:CompleteTaskByName("P1FP_Traitor.TASK_KillTraitor")
  else
    self.CleanUpMission(self)
    self:CompleteThisMission()
  end
end

function P1FP_Traitor:SetupProxEvent()
  local tProxEvent = {
    EventType = "ProximityEvent",
    ObjectA = self.hSab,
    ObjectB = self.hSnitch,
    Proximity = 35,
    Negate = false
  }
  local tDamageEvent = {
    EventType = "DamageEvent",
    ObjectHandle = self.hSnitch,
    EventName = "EVT_SnitchDmgPremat"
  }
  self:RegisterEvent(Util.CreateEvent(tDamageEvent, "P1FP_Traitor.SnitchDamagedPrematurely", self))
  self:RegisterEvent(Util.CreateEvent(tProxEvent, "P1FP_Traitor.CheckSight", self))
end

function P1FP_Traitor:CheckSight()
  if Sensory.CanSee(self.hSab, self.hSnitch) then
    Cin.PlayConversation("P1FP_Traitor_FoundHim")
    Util.KillEvent("EVT_GeneralDeath")
    Util.KillEvent("EVT_FailOnEscalation")
    self.nConvoIndex = 2
    Actor.OverrideCombatAI(self.hGeneral, false)
    Actor.OverrideCombatAI(self.hSnitch, false)
    self.KillParanoiaMeter(self)
    if self:IsMissionTaskActive("P1FP_Traitor.TASK_TailGeneral") then
      self:CompleteTaskByName("P1FP_Traitor.TASK_TailGeneral")
    elseif self:IsMissionTaskActive("P1FP_Traitor.TASK_WaitForSnitch") then
      self:CompleteTaskByName("P1FP_Traitor.TASK_WaitForSnitch")
    elseif self:IsMissionTaskActive("P1FP_Traitor.TASK_ImpersonateGeneral") then
      self:CompleteTaskByName("P1FP_Traitor.TASK_ImpersonateGeneral")
    end
    if not self:IsMissionTaskActive("P1FP_Traitor.TASK_KillTraitor") then
      if self:IsMissionTaskActive("P1FP_Traitor.TASK_WaitForSnitch") then
        self:CompleteTaskByName("P1FP_Traitor.TASK_WaitForSnitch")
      end
      self.TASK_KillTraitor(self)
    end
    if self.bCanDoSnitchDamageEvent == true then
      Util.KillEvent("EVT_SnitchDmgPremat")
      local tDamageEvent = {
        EventType = "DamageEvent",
        ObjectHandle = self.hSnitch,
        EventName = "EVT_SnitchDmg"
      }
      self:RegisterEvent(Util.CreateEvent(tDamageEvent, "P1FP_Traitor.SnitchDamaged", self))
    end
  else
    local tTimerEvent = {EventType = "TimerEvent", Time = 0.25}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Traitor.SetupProxEvent", self))
  end
end

function P1FP_Traitor:OnTraitorReachesGeneral()
  if not self.bSeanInGeneralDisguise then
    Actor.SetFacingDir(self.hGeneral, self.hSnitch)
    Actor.SetFacingDir(self.hSnitch, self.hGeneral)
    if self.nConvoIndex < 2 then
      self.nConvoIndex = 1
    end
    self.bPlayingConversation = true
    self.sCurrentConvo = "P1FP_Traitor_SnitchConvo"
    Cin.PlayConversationWith("P1FP_Traitor_SnitchConvo", {
      self.hSnitch
    }, "P1FP_Traitor.GameChanger", self)
    self.KillParanoiaMeter(self)
    if self:IsMissionTaskActive("P1FP_Traitor.TASK_TailGeneral") then
      self:CompleteTaskByName("P1FP_Traitor.TASK_TailGeneral")
    elseif self:IsMissionTaskActive("P1FP_Traitor.TASK_WaitForSnitch") then
      self:CompleteTaskByName("P1FP_Traitor.TASK_WaitForSnitch")
    end
    if not self:IsMissionTaskActive("P1FP_Traitor.TASK_KillTraitor") then
      self.TASK_KillTraitor(self)
    end
  else
    local nDist = Object.GetDistance(self.hSab, self.hSnitch)
    local nDistToTalk = 10
    if nDist < nDistToTalk then
      Actor.SetFacingDir(self.hSnitch, self.hSab)
      self.bPlayingConversation = true
      self.sCurrentConvo = "P1FP_Traitor_SnitchConvo2"
      Cin.PlayConversationWith("P1FP_Traitor_SnitchConvo2", {
        self.hSnitch
      }, "P1FP_Traitor.GameChanger", self, {true})
      self.nConvoIndex = 2
    else
      local tProxEvent = {
        EventType = "ProximityEvent",
        ObjectA = self.hSnitch,
        ObjectB = self.hSab,
        Proximity = nDistToTalk
      }
      self:RegisterEvent(Util.CreateEvent(tProxEvent, "P1FP_Traitor.OnTraitorReachesGeneral", self))
    end
  end
end

function P1FP_Traitor:GameChanger(...)
  self.KillParanoiaMeter(self)
  self.nConvoIndex = 2
  Util.KillEvent("EVT_OnGeneralDespawns")
  Util.KillEvent("EVT_GeneralDespawnFail")
  Util.KillEvent("EVT_GeneralDeath")
  Util.KillEvent("EVT_GeneralDamage")
  Util.KillEvent("EVT_FailOnEscalation")
  Util.KillEvent("EVT_EscLite")
  Actor.SetPanicEnabled(self.hSnitch, true)
  Actor.EnableNeeds(self.hSnitch, true)
  if self.bCanDoSnitchDamageEvent == true then
    Util.KillEvent("EVT_SnitchDmg")
    local tDamageEvent = {
      EventType = "DamageEvent",
      ObjectHandle = self.hSnitch,
      EventName = "EVT_SnitchDmg"
    }
    self:RegisterEvent(Util.CreateEvent(tDamageEvent, "P1FP_Traitor.SnitchDamaged", self))
  end
  if self:IsMissionTaskActive("P1FP_Traitor.TASK_TailGeneral") then
    self:CompleteTaskByName("P1FP_Traitor.TASK_TailGeneral")
  elseif self:IsMissionTaskActive("P1FP_Traitor.TASK_WaitForSnitch") then
    self:CompleteTaskByName("P1FP_Traitor.TASK_WaitForSnitch")
  end
  if not self:IsMissionTaskActive("P1FP_Traitor.TASK_KillTraitor") then
    self.TASK_KillTraitor(self)
  end
  if arg.n == 2 then
    local tCallbackData, bTalkingWithSean = unpack(arg)
    if bTalkingWithSean == true then
      self.SnitchDamaged(self, {
        self.hSab,
        cDAMAGE_CHARACTERS,
        1
      })
    end
  end
  P1FP_Traitor.GeneralWander(self)
  P1FP_Traitor.SnitchWander(self)
end

function P1FP_Traitor:SnitchDamaged(a_tCallbackData)
  local hAttacker = a_tCallbackData[1]
  local nDamageFlag = a_tCallbackData[2]
  local nDamageAmt = a_tCallbackData[3]
  self.bCanDoSnitchDamageEvent = false
  Combat.Exit(self.hSnitch)
  Actor.AddSafetyNeed(self.hSnitch, 100, self.hSab)
  self.bSnitchBeingAttacked = true
  self.KillParanoiaMeter(self)
  if self.bPlayingConversation then
    Cin.StopConversation(self.sCurrentConvo)
    self.bPlayingConversation = false
  end
  local tHelpFiles = {
    "P1FP_Traitor_RunForIt1",
    "P1FP_Traitor_RunForIt2",
    "P1FP_Traitor_RunForIt3"
  }
  Cin.PlayConversationWith(tHelpFiles[math.random(#tHelpFiles)], {
    self.hSnitch
  })
  if not self.bGeneralIsWandering and Object.IsAlive(self.hGeneral) then
    self.GeneralWander(self)
  end
  if self:IsMissionTaskActive("P1FP_Traitor.TASK_TailGeneral") then
    self:CompleteTaskByName("P1FP_Traitor.TASK_TailGeneral")
  elseif self:IsMissionTaskActive("P1FP_Traitor.TASK_WaitForSnitch") then
    self:CompleteTaskByName("P1FP_Traitor.TASK_WaitForSnitch")
    self.TASK_KillTraitor(self)
  end
end

function P1FP_Traitor:SnitchDamagedPrematurely()
  local tTimerEvent = {EventType = "TimerEvent", Time = 2}
  Util.CreateEvent(tTimerEvent, "P1FP_Traitor.FailMission", self, {
    "P1FP_Traitor_Text.MissionFail5"
  })
end

function P1FP_Traitor:CancelSnitchDamageEvent()
  Util.KillEvent("EVT_SnitchDmgPremat")
end

function P1FP_Traitor:GeneralDamaged(a_tCallbackData)
  local hAttacker = a_tCallbackData[1]
  local nDamageFlag = a_tCallbackData[2]
  local nDamageAmt = a_tCallbackData[3]
  if nDamageFlag ~= cDAMAGE_CHARACTERS then
    if hAttacker == self.hSab then
      if self:IsMissionTaskActive("TASK_KillTraitor") then
      else
        self.FailMission(self, "P1FP_Traitor_Text.MissionFail13")
      end
    else
      local tDamageEvent = {
        EventType = "DamageEvent",
        ObjectHandle = self.hGeneral,
        EventName = "EVT_GeneralDamage"
      }
      self:RegisterEvent(Util.CreateEvent(tDamageEvent, "P1FP_Traitor.GeneralDamaged", self))
    end
  elseif hAttacker == self.hSab then
    self.CheckLocationAndWitnesses(self, {
      self.hGeneral,
      hAttacker,
      false,
      nDamageFlag
    }, true)
  end
end

function P1FP_Traitor:SnitchWander()
  local hDoorAP = Handle("Missions\\freeplay\\p1\\mis_belle_w_snitch\\main\\SwingingDoorRight(3)")
  local tSnitchSequence = {
    {
      "WALKPATHONCE",
      {
        self.PATH .. "main\\PA_TraitorExit"
      }
    },
    {
      "REQUESTATTRPT",
      {hDoorAP}
    },
    {
      "RUNTOOBJECT",
      {
        "Missions\\freeplay\\p1\\mis_belle_w_snitch\\main\\LOC_SnitchHide",
        0
      }
    },
    {
      "DELAY",
      {3}
    }
  }
  local tSnitchSequenceRun = {
    {
      "RUNPATHONCE",
      {
        self.PATH .. "main\\PA_TraitorExit"
      }
    },
    {
      "REQUESTATTRPT",
      {hDoorAP}
    },
    {
      "RUNTOOBJECT",
      {
        "Missions\\freeplay\\p1\\mis_belle_w_snitch\\main\\LOC_SnitchHide",
        0
      }
    },
    {
      "DELAY",
      {3}
    }
  }
  if Object.IsAlive(self.hSnitch) and not self.bSnitchBeingAttacked then
    ScriptSequence.Run(self.hSnitch, tSnitchSequence, P1FP_Traitor.SnitchEscaped, {self})
  elseif Object.IsAlive(self.hSnitch) and self.bSnitchBeingAttacked then
    ScriptSequence.Run(self.hSnitch, tSnitchSequenceRun, P1FP_Traitor.SnitchEscaped, {self})
  end
end

function P1FP_Traitor:SnitchEscaped()
  self.FailMission(self, "P1FP_Traitor_Text.MissionFail7")
end

function P1FP_Traitor:GeneralWander()
  local sExitPath = self.PATH .. "main\\PA_GeneralExit"
  Actor.SetVehicleAvoidance(self.hGeneral, true)
  Actor.OverrideCombatAI(self.hGeneral, false)
  self.bGeneralIsWandering = true
  if Object.IsAlive(self.hGeneral) then
    Combat.SetIdleDisperse(self.hGeneral, true)
    Nav.SetScriptedPath(self.hGeneral, sExitPath, true)
    Nav.SetScriptedPathMoveMode(self.hGeneral, false)
  end
end

function P1FP_Traitor:FailMission(...)
  local tCallbackData, sMessage
  if arg.n == 1 then
    sMessage = unpack(arg)
  else
    tCallbackData, sMessage = unpack(arg)
  end
  Util.KillEvent("EVT_OnGeneralDespawns")
  Util.KillEvent("EVT_GeneralDespawnFail")
  Util.KillEvent("EVT_GeneralDeath")
  Util.KillEvent("EVT_FailOnEscalation")
  Util.KillEvent("EVT_GeneralDamage")
  Util.KillEvent("EVT_EscLite")
  self.CleanUpMission(self)
  if sMessage then
    self:MissionTaskFail(sMessage)
  else
    self:MissionTaskFail("")
  end
end

function P1FP_Traitor:CheckLocationAndWitnesses(a_tCallbackData, a_bCalledFromDamage)
  local hVictim = a_tCallbackData[1]
  local hAttacker = a_tCallbackData[2]
  local bStealthKill = a_tCallbackData[3]
  local nDamageFlag = a_tCallbackData[4]
  if not Actor.HasUseableDisguise(hVictim) then
    self.FailMission(self, "P1FP_Traitor_Text.MissionFail9")
    return
  end
  if not a_bCalledFromDamage then
    Util.KillEvent("EVT_GeneralDamage")
    if Suspicion.IsSomeoneHostileOrHunting() == true then
      self.FailMission(self, "P1FP_Traitor_Text.MissionFail15")
      return 0
    end
    if self.eProximityFail then
      Util.KillEvent(self.eProximityFail)
      self.eProximityFail = nil
    end
    Actor.SetNeverBloodyDisguise(hVictim, true)
    Util.SetDisguiseStartedCallback("P1FP_Traitor.SeanGetsDisguised", self)
    Util.KillEvent("EVT_FailOnEscalation")
    self:KillTaskByName("P1FP_Traitor.TASK_TailGeneral")
    self.TASK_GetGeneralDisguise(self)
    self.KillParanoiaMeter(self)
  else
    Actor.SetVehicleAvoidance(self.hGeneral, true)
    Actor.OverrideCombatAI(self.hGeneral, false)
    Combat.SetTarget(self.hGeneral, self.hSab)
    local tDamageEvent = {
      EventType = "DamageEvent",
      ObjectHandle = self.hGeneral,
      EventName = "EVT_GeneralDamage"
    }
    self:RegisterEvent(Util.CreateEvent(tDamageEvent, "P1FP_Traitor.GeneralDamaged", self))
  end
end

function P1FP_Traitor:SeanGetsDisguised(a_tCallbackData)
  local hVictim = a_tCallbackData[1]
  local hVictimBP = a_tCallbackData[2]
  local hBodySetup = a_tCallbackData[3]
  if hVictim == self.hGeneral then
    self.bSeanInGeneralDisguise = true
    Util.SetLostDisguiseCallback("P1FP_Traitor.LostDisguise", self)
    self.ShowNote(self)
    Util.ClearDisguiseStartedCallback()
    Sound.SetMusicLocale("fp_P1FP_Traitor")
    Sound.SetMusicLocale("fp_P1FP_Traitor", "disguised")
    if self:IsMissionTaskActive("P1FP_Traitor.TASK_EnterBelle") then
      self:KillTaskByName("P1FP_Traitor.TASK_EnterBelle")
    end
    Util.SetDisguiseStartedCallback("P1FP_Traitor.LostDisguise", self)
  end
end

function P1FP_Traitor:ShowNote()
  Util.DisplayMissionMessage("P1FP_Traitor_Text.NoteSnitch", cMESSAGETYPE_PAPER, "Note_Snitch_1", "P1FP_Traitor.EnableNewObjective", self)
end

function P1FP_Traitor:LostDisguise()
  if self.nConvoIndex < 2 then
    self.FailMission(self, "P1FP_Traitor_Text.MissionFail11")
  end
  Util.ClearLostDisguiseCallback()
end

function P1FP_Traitor:EnableNewObjective()
  Util.KillEvent("EVT_OnGeneralDespawns")
  Util.KillEvent("EVT_GeneralDespawnFail")
  Util.KillEvent("EVT_GeneralDeath")
  Util.KillEvent("EVT_EscLite")
  Tips.OnEscalation(self.FailMission, self, {
    "P1FP_Traitor_Text.MissionFail11"
  }, "EVT_FailOnEscalation", false)
  self:KillTaskByName("P1FP_Traitor.TASK_GetGeneralDisguise")
  self.TASK_ImpersonateGeneral(self)
  self:RegisterTriggerEvent(Trigger.WaitFor(self.sImpersonateTrig, self.hSab, "P1FP_Traitor.ReachedMeetingSpot", self, nil), self.sImpersonateTrig)
end

function P1FP_Traitor:ReachedMeetingSpot()
  if self:IsMissionTaskActive("P1FP_Traitor.TASK_ImpersonateGeneral") then
    self:CompleteTaskByName("P1FP_Traitor.TASK_ImpersonateGeneral")
  end
end

function P1FP_Traitor:CheckCurrentTask()
  if not self:IsMissionTaskActive("P1FP_Traitor.TASK_KillTraitor") then
    self.OnFoundSnitchSpawn(self)
    self.TASK_WaitForSnitch(self)
  end
end

function P1FP_Traitor:CleanUpMission()
  Sound.ResetMusicLocale()
  self.KillParanoiaMeter(self)
  HUD.KeepObjectivesVisible(false)
  Util.ClearDisguiseStartedCallback()
  Util.ClearLostDisguiseCallback()
  Cin.SubtitlesOn(true)
end

function P1FP_Traitor:DelayComplete()
  EVENT_Timer("P1FP_Traitor.FireDelayComplete", self, 2)
end

function P1FP_Traitor:FireDelayComplete()
  self.CompleteThisMission(self)
end

function P1FP_Traitor:SetupProximityMeter()
  self.nMeterMax = 100
  self.nMeterDecayPerSecond = 2
  self.nMeterSpikePerSecond = 80
  self.nMinDistance = 5
  self.nCurrentAwareness = 0
  self.nLastAwareness = 0
  self.nSpikeLimit = 66.6
  self.nSpikeTime = 0.5
  self.bSpikeEnabled = false
  self.nQuarterAwareness = self.nMeterMax / 4
  self.nHalfAwareness = self.nQuarterAwareness * 2
  self.nTwoThirdsAwareness = self.nMeterMax / 3 * 2
  self.nThreeQuartersAwareness = self.nQuarterAwareness * 3
  self.nRangeForWeaponFireCheck = 50
  self.nBaseWeaponFireIncrement = 30
  self.nSuspRingIncrement = 300
  self.hHUDObjective = HUD.AddObjective(eOT_HEART, "P1FP_Traitor_Text.ProximityMeter", 2)
  HUD.SetupProgressBar(self.hHUDObjective, 0, self.nMeterMax, 0)
  HUD.AddProgressBarCallback(self.hHUDObjective, "P1FP_Traitor.OnParanoiaMax", self.nMeterMax, self, {})
  HUD.KeepObjectivesVisible(true)
  Util.RegisterLuaUpdate("P1FP_Traitor.MeterUpdate", self)
  local tWeaponFireEvent = {
    EventType = "OnWeaponFire",
    Target = self.hSab,
    EventName = "EVT_WeaponFire"
  }
  self:RegisterEvent(Util.CreateEvent(tWeaponFireEvent, "P1FP_Traitor.WeaponFired", self, {}, true))
end

function P1FP_Traitor:OnParanoiaMax()
  Cin.PlayConversation("P1FP_Traitor_FailedClose", "P1FP_Traitor.FailMission", self, {
    "P1FP_Traitor_Text.MissionFail1"
  })
end

function P1FP_Traitor:MeterUpdate(a_tTime)
  local dt = a_tTime[1]
  local nDistToGeneral
  if Object.IsAlive(self.hGeneral) then
    nDistToGeneral = Object.GetDistance(self.hGeneral, self.hSab)
  else
    return
  end
  if 0.25 <= dt then
    return
  elseif dt == 0 then
    dt = 0.03125
  end
  if self.bSpikeEnabled == true then
    self.nSpikeTime = self.nSpikeTime - dt
    if 0 >= self.nSpikeTime then
      self.bSpikeEnabled = false
      self.nSpikeTime = dt
    end
    if self.nCurrentAwareness < self.nSpikeLimit then
      local nTempAware = self.nCurrentAwareness + (self.nSpikeLimit - self.nCurrentAwareness) / (self.nSpikeTime / dt)
      if nTempAware > self.nSpikeLimit then
        nTempAware = self.nSpikeLimit
      end
      self.nCurrentAwareness = nTempAware
    end
  end
  self.nLastAwareness = self.nCurrentAwareness
  if Sensory.CanSee(self.hGeneral, self.hSab) and not Actor.IsDisguised(self.hSab) then
    self.nCurrentAwareness = self.nCurrentAwareness + dt * self.nMeterSpikePerSecond / nDistToGeneral
    if self.nCurrentAwareness > self.nMeterMax then
      self.nCurrentAwareness = self.nMeterMax
    end
  else
    self.nCurrentAwareness = self.nCurrentAwareness - dt * self.nMeterDecayPerSecond
    if 0 > self.nCurrentAwareness then
      self.nCurrentAwareness = 0
    end
  end
  HUD.SetProgressBarValue(self.hHUDObjective, self.nCurrentAwareness)
end

function P1FP_Traitor:KillParanoiaMeter()
  if self.hHUDObjective then
    HUD.RemoveObjective(self.hHUDObjective)
  end
  Util.UnregisterLuaUpdate("P1FP_Traitor.MeterUpdate")
  Util.KillEvent("EVT_WeaponFire")
end

function P1FP_Traitor:SetupEscalationFail()
  Util.KillEvent("EVT_FailOnEscalation")
  local tEscEvent = {
    EventType = "OnEscalation1",
    Target = self.hSab,
    EventName = "EVT_FailOnEscalation"
  }
  Util.CreateEvent(tEscEvent, "P1FP_Traitor.FailDelay", self)
end

function P1FP_Traitor:SetupFailEvents()
  local tProxEvent = {
    EventType = "ProximityEvent",
    ObjectA = self.hSab,
    ObjectB = self.hGeneral,
    Proximity = 40,
    Negate = true,
    EventName = "EVT_OnGeneralDespawns"
  }
  self.eProximityFail = Util.CreateEvent(tProxEvent, "P1FP_Traitor.SetupDistanceFailWarning", self, {true})
  self:RegisterEvent(self.eProximityFail)
end

function P1FP_Traitor:FailDelay()
  local tTimerEvent
  if self.hGeneral and Object.IsAlive(self.hGeneral) then
    Nav.CancelScriptedPath(self.hGeneral)
    Actor.CancelAnimation(self.hGeneral)
    Combat.SetIdleScripted(self.hGeneral, false)
    Actor.SetPanicEnabled(self.hGeneral, true)
    Actor.SetPanicMode(self.hGeneral, cMOVE_PANIC)
    Actor.AddSafetyNeed(self.hGeneral, 100, self.hSab)
    tTimerEvent = {EventType = "TimerEvent", Time = 3}
  else
    tTimerEvent = {EventType = "TimerEvent", Time = 1}
  end
  self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Traitor.FailMission", self, {
    "P1FP_Traitor_Text.MissionFail12"
  }))
end

function P1FP_Traitor:SetupDistanceFailWarning(a_bShowMessage)
  if a_bShowMessage then
    Cin.PlayConversation("P1FP_Traitor_Follow")
  end
  local tProxEvent = {
    EventType = "ProximityEvent",
    ObjectA = self.hSab,
    ObjectB = self.hGeneral,
    Proximity = 55,
    Negate = true,
    EventName = "EVT_GeneralDespawnFail"
  }
  self.eProximityFail = Util.CreateEvent(tProxEvent, "P1FP_Traitor.TooFarAway", self)
  self:RegisterEvent(self.eProximityFail)
end

function P1FP_Traitor:TooFarAway()
  if not Sensory.HaveLOS(self.hSab, self.hGeneral) then
    self.FailMission(self, "P1FP_Traitor_Text.MissionFail4")
  else
    local tTimerEvent = {EventType = "TimerEvent", Time = 0.5}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Traitor.SetupDistanceFailWarning", self, {false}))
  end
end

function P1FP_Traitor:OnGeneralDespawns()
  self.FailMission(self, "P1FP_Traitor_Text.MissionFail2")
end

function P1FP_Traitor:WeaponFired()
  local nDist = Object.GetDistance(self.hSab, self.hGeneral)
  self.GetDistAndUpdateAwareness(self, nDist, true, 1)
end

function P1FP_Traitor:GetDistAndUpdateAwareness(a_nDist, a_bCheckLOS, a_nWeaponType)
  local nAmt
  if a_nDist < self.nRangeForWeaponFireCheck then
    if a_bCheckLOS and not Sensory.HaveLOS(self.hSab, self.hGeneral) then
      return
    end
    if a_nWeaponType == 1 then
      nAmt = self.nBaseWeaponFireIncrement / a_nDist
    else
      nAmt = self.nSuspRingIncrement / a_nDist
    end
    if nAmt < 1 then
      nAmt = 1
    end
    self.nCurrentAwareness = self.nCurrentAwareness + nAmt
    if self.nCurrentAwareness > 100 then
      self.nCurrentAwareness = 100
    end
  end
end

function P1FP_Traitor:CheckSubtitleDist(a_hEntity)
  local nDistFromSab = Object.GetDistance(self.hSab, a_hEntity)
  if nDistFromSab > self.nProxSubDist then
    Cin.SubtitlesOn(false)
    local tProxEvent = {
      EventType = "ProximityEvent",
      ObjectA = a_hEntity,
      ObjectB = self.hSab,
      Proximity = self.nProxSubDist,
      Negate = false
    }
    self.eConvoProxSubsEvent = Util.CreateEvent(tProxEvent, "P1FP_Traitor.SetupSubtitleKillEvent", self, {a_hEntity})
    self:RegisterEvent(self.eConvoProxSubsEvent)
  end
end

function P1FP_Traitor:SetupSubtitleKillEvent(a_hEntity)
  self.RevertSubtitles(self)
  local tProxEvent = {
    EventType = "ProximityEvent",
    ObjectA = a_hEntity,
    ObjectB = self.hSab,
    Proximity = self.nProxSubDist,
    Negate = true
  }
  self.eConvoProxSubsEvent = Util.CreateEvent(tProxEvent, "P1FP_Traitor.TurnSubsOff", self, {a_hEntity})
  self:RegisterEvent(self.eConvoProxSubsEvent)
end

function P1FP_Traitor:RevertSubtitles()
  Cin.SubtitlesOn(true)
  if self.eConvoProxSubsEvent then
    Util.KillEvent(self.eConvoProxSubsEvent)
    self.eConvoProxSubsEvent = nil
  end
end

function P1FP_Traitor:TurnSubsOff(a_hEntity)
  Cin.SubtitlesOn(false)
  local tProxEvent = {
    EventType = "ProximityEvent",
    ObjectA = a_hEntity,
    ObjectB = self.hSab,
    Proximity = self.nProxSubDist,
    Negate = false
  }
  self.eConvoProxSubsEvent = Util.CreateEvent(tProxEvent, "P1FP_Traitor.SetupSubtitleKillEvent", self, {a_hEntity})
  self:RegisterEvent(self.eConvoProxSubsEvent)
end

function P1FP_Traitor:SetupEscLiteCheck()
  local tEscLiteSusp = {
    EventType = "OnEscLiteSuspRadius",
    Target = self.hSab
  }
  self:RegisterEvent(Util.CreateEvent(tEscLiteSusp, "P1FP_Traitor.CircleDropped", self))
end

function P1FP_Traitor:CircleDropped(a_tData)
  local hEntity, x, y, z = unpack(a_tData)
  local nDist = Object.GetDistance(self.hGeneral, x, y, z)
  self.GetDistAndUpdateAwareness(self, nDist, false, 2)
  self.SetupEscLiteCheck(self)
end

function P1FP_Traitor:MISSION_ONCANCEL()
  self.RevertSubtitles(self)
  self.bSeanInGeneralDisguise = false
  Sound.ResetMusicLocale()
  HUD.KeepObjectivesVisible(false)
end
