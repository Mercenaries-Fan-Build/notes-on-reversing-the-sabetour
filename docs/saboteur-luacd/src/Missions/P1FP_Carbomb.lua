if P1FP_Carbomb == nil then
  P1FP_Carbomb = SabTaskObjective:Create()
  P1FP_Carbomb.sPATH = "Missions\\freeplay\\p1\\mis_belle_se_carbomb\\"
  P1FP_Carbomb:Configure({
    TaskCount = 99,
    sSaveMissionNameID = "MissionNames_Text.P1FP_Carbomb",
    tDependencyList = {},
    tUnlockList = {
      "NOTE_Jailbreak",
      "P1FP_Jailbreak"
    },
    sConvFile = "P1FP_Carbomb_Start",
    bFreeplay = true,
    bDelayClean = true,
    sStarter = "santos_ext_hideout",
    tSMEDNodes = {
      P1FP_Carbomb.sPATH .. "task",
      P1FP_Carbomb.sPATH .. "main"
    }
  })
end

function P1FP_Carbomb:STARTER_Setup()
  Zone.SwitchState("WtF_Zones\\global\\P1M1B_SlaughterhouseLiberate", cZONESTATE_HIGHCOLOR_HIGHTAG, cENT_IMMEDIATE)
end

function P1FP_Carbomb:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "FP.CARBOMB"
  self.bDebugMode = false
  self.GENERAL_Setup(self)
  self.SetupCheckpoint(self, 3)
end

function P1FP_Carbomb:GENERAL_Setup()
end

function P1FP_Carbomb:SetupVariables()
  self.hSab = self.hSab or Handle("Saboteur")
  self.sTargetCar = self.sTargetCar or self.sPATH .. "main\\TargetCar"
  self.hTargetCar = self.hTargetCar or Handle(self.sTargetCar)
  self.sSeeLimo = self.sSeeLimo or self.sPATH .. "main\\LOC_SeeLimo"
  self.nDialogRange = self.nDialogRange or 25
  self.bCarInDeliveryArea = self.bCarInDeliveryArea or false
  self.sSantos = self.sSantos or self.sPATH .. "main\\Santos_LaVillette_exterior"
  self.sTrigSantos = self.sTrigSantos or self.sPATH .. "main\\TRIG_HideSantos"
  self.tCourtyardSoldiers = self.tCourtyardSoldiers or {
    self.sPATH .. "main\\Grunt1",
    self.sPATH .. "main\\Grunt2",
    self.sPATH .. "main\\Grunt3",
    self.sPATH .. "main\\Officer"
  }
  self.tAllSoldiers = self.tAllSoldiers or {
    self.sPATH .. "main\\Grunt1",
    self.sPATH .. "main\\Grunt2",
    self.sPATH .. "main\\Grunt3",
    self.sPATH .. "main\\Officer",
    self.sPATH .. "nazis\\GateGuard1",
    self.sPATH .. "nazis\\GateGuard2",
    self.sPATH .. "nazis\\GateGuardWarn"
  }
  self.tGateGuards = self.tGateGuards or {
    self.sPATH .. "nazis\\GateGuard2",
    self.sPATH .. "nazis\\GateGuardWarn"
  }
  self.tGrunts = self.tGrunts or {
    self.sPATH .. "main\\Grunt1",
    self.sPATH .. "main\\Grunt2",
    self.sPATH .. "main\\Grunt3"
  }
  self.tDummyTargets = self.tDummyTargets or {
    self.sPATH .. "main\\Target1",
    self.sPATH .. "main\\Target2",
    self.sPATH .. "main\\Target3"
  }
  self.sTrigger = self.sTrigger or self.sPATH .. "props\\PT_RestrictedArea"
  self.hTrigger = self.hTrigger or Handle(self.sTrigger)
  self.sLimoTrig = self.sLimoTrig or self.sPATH .. "main\\TRIG_DeliverLimo"
  self.sLimoLoc = self.sLimoLoc or self.sPATH .. "main\\LOC_DeliverLimo"
  self.sDummyTrig = self.sDummyTrig or self.sPATH .. "main\\TRIG_DummyTrig"
  self.sCarEndExit = self.sCarEndExit or self.sPATH .. "main\\TRIG_CarEndExit"
  self.sCarEndFirst = self.sCarEndFirst or self.sPATH .. "main\\TRIG_CarEndFirst"
  self.sCarEndSecond = self.sCarEndSecond or self.sPATH .. "main\\TRIG_CarEndSecond"
  self.hOfficer = self.hOfficer or Handle(self.sPATH .. "main\\Officer")
  self.hGrunt1 = self.hGrunt1 or Handle(self.sPATH .. "main\\Grunt1")
  self.hGrunt2 = self.hGrunt2 or Handle(self.sPATH .. "main\\Grunt2")
  self.hGrunt3 = self.hGrunt3 or Handle(self.sPATH .. "main\\Grunt3")
  self.hGateGuard1 = self.hGateGuard1 or Handle(self.sPATH .. "nazis\\GateGuard1")
  self.hGateGuard1 = self.hGateGuard2 or Handle(self.sPATH .. "nazis\\GateGuard2")
  self.tRangeNazis = self.tRangeNazis or {
    self.hOfficer,
    self.hGrunt1,
    self.hGrunt2,
    self.hGrunt3
  }
  self.sRunPath = self.sRunPath or self.sPATH .. "main\\OfficerRun"
  self.sExitStartPath = self.sExitStartPath or self.sPATH .. "main\\ExitStartPath"
  self.sEscapePaths = self.sEscapePaths or {
    self.sPATH .. "main\\CarPath",
    self.sPATH .. "main\\CarPath2"
  }
  self.bPracticeFiring = self.bPracticeFiring or false
  self.bOfficerSentToCar = self.bOfficerSentToCar or false
  self.bLimoHasLeftCourtyard = self.bLimoHasLeftCourtyard or false
  for i, v in ipairs(self.tCourtyardSoldiers) do
    Combat.SetIdleScripted(Handle(v), true)
  end
  Combat.SetIdleScripted(self.hOfficer, true)
  if self.eOfficerDeath then
    Util.KillEvent(self.eOfficerDeath)
    self.eOfficerDeath = nil
  end
  local tDeathEvent = {
    EventType = "DeathEvent",
    ObjectHandle = self.hOfficer
  }
  self.eOfficerDeath = Util.CreateEvent(tDeathEvent, "P1FP_Carbomb.CancelVehicleStuff", self)
  self:RegisterEvent(self.eOfficerDeath)
  if self.eEnteredVehEvent then
    Util.KillEvent(self.eEnteredVehEvent)
    self.eEnteredVehEvent = nil
  end
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      self.sTargetCar
    },
    WaitForGameObject = true
  }
  self:RegisterEvent(Util.CreateEvent(tStreamEvent, "P1FP_Carbomb.OnCarStreams", self))
  if self.eSeanDeathEvent then
    Util.KillEvent(self.eSeanDeathEvent)
    self.eSeanDeathEvent = nil
  end
  tDeathEvent = {
    EventType = "DeathEvent",
    ObjectHandle = self.hSab
  }
  self.eSeanDeathEvent = Util.CreateEvent(tDeathEvent, "P1FP_Carbomb.KillCarDeathEvent", self)
  self:RegisterEvent(self.eSeanDeathEvent)
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\freeplay\\p1\\mis_belle_se_carbomb\\props\\Occ_SecFence_PedGate5m_DoorFrame\\Occ_SecFence_PedGate5m_DoorAnim_L",
      "Missions\\freeplay\\p1\\mis_belle_se_carbomb\\props\\Occ_SecFence_PedGate5m_DoorFrame\\Occ_SecFence_PedGate5m_DoorAnim_R"
    },
    WaitForGameObject = true
  }, "P1FP_Carbomb.GatesStreamedIn", self))
  Object.SetShouldNeverRegisterGameObjectEvents(self.hTargetCar, true)
end

function P1FP_Carbomb:GatesStreamedIn()
  local hGates = Util.GetHandleByName("Missions\\freeplay\\p1\\mis_belle_se_carbomb\\props\\Occ_SecFence_PedGate5m_DoorFrame\\Occ_SecFence_PedGate5m_DoorAnim_R")
  local tGates = {EventType = "DeathEvent", ObjectHandle = hGates}
  self:RegisterEvent(Util.CreateEvent(tGates, "P1FP_Carbomb.GatesDestroyed", self))
  hGates = Util.GetHandleByName("Missions\\freeplay\\p1\\mis_belle_se_carbomb\\props\\Occ_SecFence_PedGate5m_DoorFrame\\Occ_SecFence_PedGate5m_DoorAnim_L")
  tGates = {EventType = "DeathEvent", ObjectHandle = hGates}
  self:RegisterEvent(Util.CreateEvent(tGates, "P1FP_Carbomb.GatesDestroyed", self))
end

function P1FP_Carbomb:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "P1FP_Carbomb.DoCheckpoint")
end

function P1FP_Carbomb:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  self.SetupVariables(self)
  if nCP == 1 then
    if not self:IsMissionTaskActive("P1FP_Carbomb.TASK_GoToCourtyard") then
      self.TASK_GoToCourtyard(self)
    end
    self.SetupEscalationEvent(self)
    self.SetupGuardEvents(self)
  elseif nCP == 2 then
    Trigger.Enable(self.sTrigger, true)
    Cin.PlayConversation("P1FP_Carbomb_NearLoc", "P1FP_Carbomb.SetupSeeEvent", self)
    self.SetupCombatEvents(self)
    self.TASK_StealLimo(self)
    self.bOfficerSentToCar = false
    self.bLimoHasLeftCourtyard = false
  elseif nCP == 3 then
    self.ExitHQ(self)
    self.TASK_GoToCourtyard(self)
    self.SetupHideSantos(self)
  elseif nCP == 5 then
    self.KickPlayerOut(self)
    self.TASK_TalkToSantos(self)
  end
end

function P1FP_Carbomb:SetupGuardEvents()
  EVENT_Stream("P1FP_Carbomb.SetupGuards", self, self.tGateGuards, true)
end

function P1FP_Carbomb:SetupGuards()
  for i, sSoldier in ipairs(self.tGateGuards) do
    local hSoldier = Handle(sSoldier)
    EVENT_ActorDamaged("P1FP_Carbomb.PrepHostility", self, hSoldier, nil, false)
  end
end

function P1FP_Carbomb:PrepHostility()
  self.SetHostility(self, self.tAllSoldiers, true)
end

function P1FP_Carbomb:ExitHQ()
  self:CreateTask({
    sName = "ExitHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "LaVillette",
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 1}
      }
    }
  })
end

function P1FP_Carbomb:TASK_GoToCourtyard()
  self:CreateTask({
    sName = "P1FP_Carbomb.TASK_GoToCourtyard",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDeliverObjs = {
      self.hSab
    },
    tDestRegion = {
      self.sPATH .. "task\\PT_CourtyardTrig1"
    },
    tLocators = {
      self.sPATH .. "task\\LOC_CourtyardEntrance"
    },
    sConvFile = "P1FP_Carbomb_OMW",
    sObjectiveTextID = "P1FP_Carbomb_Text.TASK_GoToCourtyard",
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 2}
      }
    }
  })
end

function P1FP_Carbomb:GatesDestroyed()
  Suspicion.SetEscalationLevel(1)
end

function P1FP_Carbomb:TASK_StealLimo()
  self:CreateTask({
    sName = "P1FP_Carbomb_TASK_StealLimo",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P1FP_Carbomb_Text.TASK_StealLimo",
    tLocators = {
      self.hTargetCar
    },
    tDestRegion = {
      self.sDummyTrig
    },
    tDeliverObjs = {
      self.hSab
    },
    MarkerHeight = 3,
    bNoGPS = true,
    tOnActivate = {
      {
        self.SetupCarEntry,
        {self}
      }
    },
    tOnComplete = {
      {
        self.SetupNextTask,
        {self}
      },
      {
        RewardsManager.LoadColby,
        {
          "Garagekeeper_lavillette",
          true
        }
      }
    }
  })
end

function P1FP_Carbomb:TASK_DeliverLimo()
  self:CreateTask({
    sName = "P1FP_Carbomb_TASK_DeliverLimo",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "DELIVER",
    sObjectiveTextID = "P1FP_Carbomb_Text.TASK_DeliverLimo",
    tLocators = {
      self.sLimoLoc
    },
    tDestRegion = {
      self.sLimoTrig
    },
    tDeliverObjs = {
      self.hSab,
      self.hTargetCar
    },
    bGroundBlip = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.KillExitVehEvent,
        {self}
      },
      {
        self.ResetLimoHealth,
        {self}
      },
      {
        self.SetupCheckpoint,
        {self, 5}
      }
    }
  })
end

function P1FP_Carbomb:TASK_ReturnToLimo()
  self:CreateTask({
    sName = "P1FP_Carbomb_TASK_ReturnToLimo",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "GenericObjective_Text.Vehicle_GetInBack_The",
    tLocators = {
      self.sTargetCar
    },
    tDestRegion = {
      self.sDummyTrig
    },
    tDeliverObjs = {
      self.hSab
    },
    tOnActivate = {},
    tOnComplete = {}
  })
end

function P1FP_Carbomb:TASK_TalkToSantos()
  self:CreateTask({
    sName = "P1FP_Carbomb_TASK_TalkToSantos",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    bAutoFire = true,
    Proximity = 5,
    sObjectiveTextID = "P1FP_Carbomb_Text.TASK_TalkToSantos",
    tTgtInclude = {
      self.sSantos
    },
    sConvFile = "P1FP_Carbomb_MissionComplete",
    tOnActivate = {},
    tOnComplete = {
      {
        Util.SetGarageEnable,
        {true}
      },
      {
        self.DoVictory,
        {self}
      }
    },
    tOnConversationComplete = {
      {
        self.DoFadeToBlack,
        {self}
      }
    }
  })
end

function P1FP_Carbomb:TASK_LoseTheHeat()
  self:CreateTask({
    sName = "P1FP_Carbomb.TASK_LoseTheHeat",
    sTaskType = "SabTaskObjectiveEmpty",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    sTaskSubType = "NONE",
    tOnComplete = {}
  })
end

function P1FP_Carbomb:OnCarStreams()
  self.hTargetCar = self.hTargetCar or Handle(self.sTargetCar)
  if self.eCarDeathEvent then
    Util.KillEvent(self.eCarDeathEvent)
  end
  if self.hTargetCar and Object.IsAlive(self.hTargetCar) then
    self.eCarDeathEvent = EVENT_ActorDeath("P1FP_Carbomb.Fail", self, self.sTargetCar, {
      "GenericFail_Text.DESTROYED_Car_Your"
    })
    self:RegisterEvent(self.eCarDeathEvent)
  end
  Trigger.DoNotWaitFor(self.sTrigger, self.hTargetCar)
  self:RegisterTriggerEvent(Trigger.WaitFor(self.sTrigger, self.hTargetCar, "P1FP_Carbomb.OnLimoLeavesCourtyard", self, {}, cTRIGGEREVENT_ONEXIT), self.sTrigger)
end

function P1FP_Carbomb:SetupNextTask()
  self.CheckEscalation(self)
  self:RegisterTriggerEvent(Trigger.WaitFor(self.sLimoTrig, self.hTargetCar, "P1FP_Carbomb.RegisterCarInDeliveryTrig", self, {}), self.sLimoTrig)
  if not self.eEscalationEvent then
    self.SetupEscalationEvent(self)
  end
end

function P1FP_Carbomb:RegisterCarInDeliveryTrig()
  self.bCarInDeliveryArea = true
end

function P1FP_Carbomb:SetupCarEntry()
  local tEnterCarEvent = {
    EventType = "EnteredVehicleEvent",
    ObjectHandle = self.hSab,
    VehicleHandle = Handle(self.sTargetCar)
  }
  self:RegisterEvent(Util.CreateEvent(tEnterCarEvent, "P1FP_Carbomb.EnteredLimo", self))
end

function P1FP_Carbomb:EnteredLimo()
  if self:IsMissionTaskActive("P1FP_Carbomb_TASK_StealLimo") then
    if self.bOfficerSentToCar then
      Nav.StopMoving(self.hOfficer)
      Actor.OverrideCombatAI(self.hOfficer, false)
    else
      self.bOfficerSentToCar = true
    end
    self:CompleteTaskByName("P1FP_Carbomb_TASK_StealLimo")
  elseif self:IsMissionTaskActive("P1FP_Carbomb_TASK_ReturnToLimo") then
    self:KillTaskByName("P1FP_Carbomb_TASK_ReturnToLimo")
    self:ResetTaskByName("P1FP_Carbomb_TASK_ReturnToLimo", true)
    self.TASK_DeliverLimo(self)
  elseif self:IsMissionTaskActive("P1FP_Carbomb.TASK_LoseTheHeat") then
    self.sLastActiveTask = "P1FP_Carbomb_TASK_DeliverLimo"
  end
  local tExitVehEvent = {
    EventType = "SeatEmptyEvent",
    Vehicle = Handle(self.sTargetCar),
    SeatName = "PILOT"
  }
  self.eExitVehEvent = Util.CreateEvent(tExitVehEvent, "P1FP_Carbomb.ExitedLimo", self)
  self:RegisterEvent(self.eExitVehEvent)
end

function P1FP_Carbomb:ExitedLimo()
  if not self.bCarInDeliveryArea then
    self.sLastActiveTask = "P1FP_Carbomb_TASK_ReturnToLimo"
  else
    self.sLastActiveTask = "P1FP_Carbomb_TASK_DeliverLimo"
  end
  if self:IsMissionTaskActive("P1FP_Carbomb_TASK_DeliverLimo") then
    self:KillTaskByName("P1FP_Carbomb_TASK_DeliverLimo")
    self:ResetTaskByName("P1FP_Carbomb_TASK_DeliverLimo", true)
    self.TASK_ReturnToLimo(self)
  end
  self.SetupCarEntry(self)
end

function P1FP_Carbomb:KickPlayerOut()
  SabTaskObjectiveDeliver.StopVehicle(self, self.hTargetCar)
  self.bVehicleManuallyStopped = true
  local tTimerEvent = {EventType = "TimerEvent", Time = 3}
  self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Carbomb.UnloadVehicle", self))
end

function P1FP_Carbomb:UnloadVehicle()
  Vehicle.UnboardAll(self.hTargetCar, false, nil, self, {}, "P1FP_Carbomb.VehicleUnloaded", self)
end

function P1FP_Carbomb:VehicleUnloaded()
  Vehicle.LockAllSeats(self.hTargetCar, true)
  self.hSantos = self.hSantos or Handle(self.sSantos)
  Actor.OverrideCombatAI(self.hSantos, true)
  Nav.MoveToObject(self.hSantos, self.hSab, 1, true, "P1FP_Carbomb.SantosReachedSean", self, {10}, false)
end

function P1FP_Carbomb:SantosReachedSean(...)
  local a_tCallbackData, nTime
  if arg.n == 1 then
    nTime = unpack(arg)
  else
    a_tCallbackData, nTime = unpack(arg)
  end
  local tTimerEvent = {EventType = "TimerEvent", Time = nTime}
  self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Carbomb.SantosReset", self))
end

function P1FP_Carbomb:SantosReset()
  if not Cin.IsHumanInConversation(self.hSantos) then
    Actor.OverrideCombatAI(self.hSantos, false)
  else
    self.SantosReachedSean(self, 3)
  end
end

function P1FP_Carbomb:SetupSeeEvent()
  local tSeeEvent = {
    EventType = "SeeLocatorEvent",
    InViewTime = 0.5,
    Locator = self.sSeeLimo,
    Proximity = 40
  }
  self:RegisterEvent(Util.CreateEvent(tSeeEvent, "P1FP_Carbomb.PlaySeeConv", self))
end

function P1FP_Carbomb:PlaySeeConv()
  Cin.PlayConversation("P1FP_Carbomb_Limo_Seen")
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = self.tRangeNazis,
    WaitForGameObject = true
  }
  self:RegisterEvent(Util.CreateEvent(tStreamEvent, "P1FP_Carbomb.StartRangeSequence", self))
end

function P1FP_Carbomb:StartRangeSequence()
  if Suspicion.GetEscalation() == 0 then
    for i, sGrunt in ipairs(self.tGrunts) do
      local tSeq = {
        {
          "DELAY",
          {
            math.random()
          }
        },
        {
          "WALKTOOBJECT",
          {
            self.sPATH .. "main\\LOC_Table_Grunt" .. i,
            0.2
          }
        },
        {
          "MATCHFACING",
          {
            self.sPATH .. "main\\LOC_Table_Grunt" .. i
          }
        },
        {
          "DELAY",
          {1}
        },
        {
          "SETSTATIONARY",
          {true}
        },
        {
          "SETREACTIMMEDIATELY",
          {true}
        },
        {
          "SETBROADCAST_WEAPONFIRE",
          {false}
        },
        {
          "SETBROADCAST_ENTEREDCOMBAT",
          {false}
        },
        {
          "SETHAX",
          {true}
        },
        {
          "SETDRYFIRE",
          {true}
        },
        {
          "SETVAR",
          {
            "P1FP_Carbomb.bPracticeFiring",
            true
          }
        },
        {
          "ATTACKTARGET_NOWAIT",
          {
            self.tDummyTargets[i]
          }
        }
      }
      ScriptSequence.Run(sGrunt, tSeq)
    end
    local tOfficerSequence = {
      {
        "WALKTOOBJECT",
        {
          self.sPATH .. "main\\LOC_Table_Officer",
          0.25
        }
      },
      {
        "MATCHFACING",
        {
          self.sPATH .. "main\\LOC_Table_Officer"
        }
      },
      {
        "DELAY",
        {1}
      },
      {
        "PLAYANIMATION",
        {
          "Nazi_PaperCheck"
        }
      },
      {
        "SELFFUNC",
        {
          self.RunConvoCheck,
          {
            GetTableID(self),
            "P1FP_Carbomb_Amb01_Ready"
          }
        }
      },
      {
        "DELAY",
        {10}
      },
      {
        "SELFFUNC",
        {
          self.RunConvoCheck,
          {
            GetTableID(self),
            "P1FP_Carbomb_Amb01_Fire"
          }
        }
      },
      {
        "SELFFUNC",
        {
          self.GrantPermissionToFire,
          {
            GetTableID(self)
          }
        }
      },
      {
        "DELAYFORRANDOM",
        {30, 35}
      },
      {
        "SELFFUNC",
        {
          self.RunConvoCheck,
          {
            GetTableID(self),
            "P1FP_Carbomb_Amb01_Stop"
          }
        }
      },
      {
        "DELAY",
        {1}
      },
      {
        "SELFFUNC",
        {
          self.CeaseFire,
          {
            GetTableID(self)
          }
        }
      },
      {
        "SETVAR",
        {
          "P1FP_Carbomb.bPracticeFiring",
          false
        }
      },
      {
        "DELAY",
        {2}
      },
      {
        "CANCELANIMATION"
      },
      {
        "DELAY",
        {1.5}
      }
    }
    if math.random() < 0.5 then
      ScriptSequence.Run(self.hOfficer, tOfficerSequence, self.StartCarSequence, {self})
    else
      ScriptSequence.Run(self.hOfficer, tOfficerSequence, self.StartRangeSequence, {self})
    end
  end
end

function P1FP_Carbomb:StartCarSequence()
  self.ResetCombatFlags(self, self.tAllSoldiers)
  if Suspicion.GetEscalation() == 0 then
    self.RunConvoCheck(self, "P1FP_Carbomb_Amb01_GoToCar")
    for i, sGrunt in ipairs(self.tGrunts) do
      local hGrunt = Handle(sGrunt)
      if hGrunt and Object.IsAlive(hGrunt) == true then
        local tSeq = {
          {
            "DELAY",
            {
              math.random()
            }
          },
          {
            "WALKTOOBJECT",
            {
              self.sPATH .. "main\\LOC_Car_Grunt" .. i,
              0.25
            }
          },
          {
            "DELAY",
            {
              math.random() + 0.5
            }
          },
          {
            "MATCHFACING",
            {
              self.sPATH .. "main\\LOC_Car_Grunt" .. i
            }
          }
        }
        ScriptSequence.Run(hGrunt, tSeq)
      end
    end
    local tOfficerSeq = {
      {
        "WALKTOOBJECT",
        {
          self.sPATH .. "main\\LOC_Car_Officer",
          0.25
        }
      },
      {
        "MATCHFACING",
        {
          self.sPATH .. "main\\LOC_Car_Officer"
        }
      },
      {
        "DELAY",
        {1}
      },
      {
        "PLAYANIMATION",
        {"Civ_point"}
      },
      {
        "DELAY",
        {2}
      },
      {
        "SELFFUNC",
        {
          self.RunConvoCheck,
          {
            GetTableID(self),
            "P1FP_Carbomb_Amb01_Looking"
          }
        }
      },
      {
        "DELAY",
        {3}
      },
      {
        "CANCELANIMATION"
      },
      {
        "PLAYANIMATION",
        {
          "Nazi_PaperCheck"
        }
      },
      {
        "DELAYFORRANDOM",
        {8, 13}
      },
      {
        "CANCELANIMATION"
      },
      {
        "SELFFUNC",
        {
          self.RunConvoCheck,
          {
            GetTableID(self),
            "P1FP_Carbomb_Amb01_Complete"
          }
        }
      }
    }
    ScriptSequence.Run(self.hOfficer, tOfficerSeq, self.StartRangeSequence, {self})
  end
end

function P1FP_Carbomb:GrantPermissionToFire()
  self.SetNaziSoundResponse(self, self.tAllSoldiers, false)
  for i, sGrunt in ipairs(self.tGrunts) do
    dprint(self, sGrunt .. " opening fire!")
    local tTimer = {
      EventType = "TimerEvent",
      Time = math.random()
    }
    self:RegisterEvent(Util.CreateEvent(tTimer, "P1FP_Carbomb.OnRandomFireDelayComplete", self, {sGrunt}))
  end
end

function P1FP_Carbomb:OnRandomFireDelayComplete(a_sGrunt)
  local hGrunt = Handle(a_sGrunt)
  if hGrunt and Object.IsAlive(hGrunt) then
    Combat.SetDryFire(hGrunt, false)
  end
end

function P1FP_Carbomb:CeaseFire()
  for i, sGrunt in ipairs(self.tGrunts) do
    local hGrunt = Handle(sGrunt)
    if hGrunt and Object.IsAlive(hGrunt) == true then
      Combat.Exit(hGrunt)
    end
  end
  self.SetNaziSoundResponse(self, self.tAllSoldiers, true)
end

function P1FP_Carbomb:ResetCombatFlags(a_tSoldiers)
  for i, vNazi in ipairs(a_tSoldiers) do
    local hNazi = Handle(vNazi)
    if hNazi and Object.IsAlive(hNazi) == true then
      Combat.SetDryFire(hNazi, false)
      Combat.SetBroadcastEnteredCombat(hNazi, true)
      Combat.SetBroadcastWeaponFire(hNazi, true)
      Combat.SetAlwaysSeeTarget(hNazi, false)
      Combat.SetReactImmediately(hNazi, false)
      Combat.SetStationary(hNazi, false)
    end
  end
end

function P1FP_Carbomb:SetNaziSoundResponse(a_tSoldiers, a_bRespondsToSound)
end

function P1FP_Carbomb:SetupCombatEvents()
  self.tCombatEvents = {}
  self.tCourtyardDamageEvents = {}
  for i, sActor in ipairs(self.tCourtyardSoldiers) do
    local hActor = Handle(sActor)
    local tDamageEvent = {
      EventType = "OnDamage",
      Target = hActor,
      EventName = HandleToString(hActor) .. "_OnDamage"
    }
    local eDamage = Util.CreateEvent(tDamageEvent, "P1FP_Carbomb.OnCourtyardSoldiersDamaged", self)
    table.insert(self.tCourtyardDamageEvents, eDamage)
    self:RegisterEvent(eDamage)
    local tDeathEvent = {
      EventType = "DeathEvent",
      ObjectHandle = hActor,
      EventName = HandleToString(hActor) .. "_OnDeath"
    }
    local eDeath = Util.CreateEvent(tDeathEvent, "P1FP_Carbomb.OnCourtyardSoldiersDamaged", self)
    table.insert(self.tCourtyardDamageEvents, eDeath)
    self:RegisterEvent(eDeath)
  end
  self.SetupEscalationEvent(self)
end

function P1FP_Carbomb:SetupEscalationEvent()
  local tEscalationEvent = {
    EventType = "OnEscalation1",
    Target = self.hSab,
    EventName = "SabEscalation1"
  }
  self.eEscalationEvent = Util.CreateEvent(tEscalationEvent, "P1FP_Carbomb.OnEscalation", self)
  self:RegisterEvent(self.eEscalationEvent)
end

function P1FP_Carbomb:KillCombatEvents()
  Tips.KillEventTable(self.tCourtyardDamageEvents)
end

function P1FP_Carbomb:OnLimoLeavesCourtyard()
  self.bLimoHasLeftCourtyard = true
  self.SetHostility(self, self.tAllSoldiers, true)
  Suspicion.SetEscalatedWithWhistle()
  if Vehicle.GetPilot(self.hTargetCar) ~= self.hSab then
    Cin.PlayConversation("P1FP_Carbomb_Escape_Losing")
  else
  end
end

function P1FP_Carbomb:OnCourtyardSoldiersDamaged(a_hActor, a_sEventType)
  self.KillCombatEvents(self)
  dprint(self, "OnDamage! Setting all soldiers to hostile!")
  self.SetHostility(self, self.tAllSoldiers, true)
end

function P1FP_Carbomb:OnDelayedHostilityTimeout(a_tSoldiers, a_bRespondsToSound)
end

function P1FP_Carbomb:OnDelayedSoundResponseTimeout(a_tSoldiers, a_bRespondsToSound)
  dprint(self, "Delayed sound response being reenabled!")
  self.SetNaziSoundResponse(self, a_tSoldiers, a_bRespondsToSound)
end

function P1FP_Carbomb:OnEscalation()
  self.SetHostility(self, self.tAllSoldiers, true)
  if self.eRestartSeqEvent then
    Util.KillEvent(self.eRestartSeqEvent)
  end
  dprint(self, "Mission script knows about escalation!")
  local tEsc = {
    EventType = "OnEscalation0",
    Target = self.hSab,
    EventName = "OnDeescalation"
  }
  self:RegisterEvent(Util.CreateEvent(tEsc, "P1FP_Carbomb.OnEscalationComplete", self))
  if self:IsMissionTaskActive("P1FP_Carbomb_TASK_DeliverLimo") then
    self.sLastActiveTask = "P1FP_Carbomb_TASK_DeliverLimo"
    self:KillTaskByName("P1FP_Carbomb_TASK_DeliverLimo")
    self:ResetTaskByName("P1FP_Carbomb_TASK_DeliverLimo", true)
    self.TASK_LoseTheHeat(self)
  elseif self:IsMissionTaskActive("P1FP_Carbomb_TASK_ReturnToLimo") then
    self.sLastActiveTask = "P1FP_Carbomb_TASK_ReturnToLimo"
    self:KillTaskByName("P1FP_Carbomb_TASK_ReturnToLimo")
    self:ResetTaskByName("P1FP_Carbomb_TASK_ReturnToLimo", true)
    self.TASK_LoseTheHeat(self)
  elseif self:IsMissionTaskActive("P1FP_Carbomb_TASK_TalkToSantos") then
    self.sLastActiveTask = "P1FP_Carbomb_TASK_TalkToSantos"
    self:KillTaskByName("P1FP_Carbomb_TASK_TalkToSantos")
    self:ResetTaskByName("P1FP_Carbomb_TASK_TalkToSantos", true)
    self.TASK_LoseTheHeat(self)
  end
end

function P1FP_Carbomb:OnEscalationComplete()
  self.SetupEscalationEvent(self)
  if self:IsMissionTaskActive("P1FP_Carbomb.TASK_LoseTheHeat") then
    self:KillTaskByName("P1FP_Carbomb.TASK_LoseTheHeat")
    self:ResetTaskByName("P1FP_Carbomb.TASK_LoseTheHeat", true)
    if self.sLastActiveTask == "P1FP_Carbomb_TASK_DeliverLimo" then
      self.TASK_DeliverLimo(self)
    elseif self.sLastActiveTask == "P1FP_Carbomb_TASK_ReturnToLimo" then
      self.TASK_ReturnToLimo(self)
    elseif self.sLastActiveTask == "P1FP_Carbomb_TASK_TalkToSantos" then
      self.TASK_TalkToSantos(self)
    end
  end
  for i, sSoldier in ipairs(self.tAllSoldiers) do
    local hSoldier = Handle(sSoldier)
    if hSoldier and Object.IsAlive(hSoldier) == true and hSoldier ~= self.hOfficer then
      Combat.ReturnToIdlePos(hSoldier)
    end
  end
  if self.bOfficerSentToCar == true then
    return
  end
  self.bOfficerSentToCar = true
  if self.bLimoHasLeftCourtyard == true then
    return
  end
  if Object.IsAlive(self.hOfficer) and not Actor.IsInVehicle(self.hOfficer) and not self.bOfficerSentToCar then
    local tTimerEvent = {
      EventType = "TimerEvent",
      Time = 15 + math.random(0, 5)
    }
    self.eRestartSeqEvent = Util.CreateEvent(tTimerEvent, "P1FP_Carbomb.StartRangeSequence", self)
  end
end

function P1FP_Carbomb:CheckEscalation()
  if Suspicion.GetEscalation() > 0 then
    if self:IsMissionTaskActive("P1FP_Carbomb_TASK_DeliverLimo") then
      self:KillTaskByName("P1FP_Carbomb_TASK_DeliverLimo")
      self:ResetTaskByName("P1FP_Carbomb_TASK_DeliverLimo", true)
    end
    self.sLastActiveTask = "P1FP_Carbomb_TASK_DeliverLimo"
    self.TASK_LoseTheHeat(self)
  else
    self.TASK_DeliverLimo(self)
  end
end

function P1FP_Carbomb:DoVictory()
  if self.bVehicleManuallyStopped == true then
    SabTaskObjectiveDeliver.ReleaseVehicle(self, self.hTargetCar)
    self.bVehicleManuallyStopped = false
  end
  if self.eEscalationEvent then
    Util.KillEvent(self.eEscalationEvent)
  end
  self.HideSantos(self, false)
end

function P1FP_Carbomb:SetHostility(a_tSoldiers, a_bRespondsToSound)
  if self:IsMissionTaskActive("P1FP_Carbomb.TASK_GoToCourtyard") then
    self:CompleteTaskByName("P1FP_Carbomb.TASK_GoToCourtyard")
  end
  local hSomeoneWhoEnteredCombat
  local hOfficer = Handle(self.hOfficer)
  for i, vNazi in ipairs(a_tSoldiers) do
    local hNazi = Handle(vNazi)
    if hNazi and Object.IsAlive(hNazi) == true then
      if hNazi == hOfficer then
        if self.bOfficerSentToCar == false then
          ScriptSequence.Kill(hNazi)
          self.SendOfficerToCar(self)
        end
      else
        ScriptSequence.Kill(hNazi)
        if Suspicion.IsEscalated() == false then
          Combat.ClearTarget(hNazi)
          Combat.SetHunt(hNazi, nil, true, false)
        end
      end
      hSomeoneWhoEnteredCombat = hNazi
    end
  end
  self.ResetCombatFlags(self, a_tSoldiers)
  if a_bRespondsToSound ~= nil and a_bRespondsToSound == true then
    P1FP_Carbomb.SetNaziSoundResponse(self, a_tSoldiers, true)
  end
end

function P1FP_Carbomb:SendOfficerToCar()
  if self.bOfficerSentToCar == true then
    return
  end
  self.bOfficerSentToCar = true
  if self.bLimoHasLeftCourtyard == true then
    return
  end
  local tEscapeSeq = {
    {
      "SELFFUNC",
      {
        self.SetupProximityFail,
        {
          GetTableID(self)
        }
      }
    },
    {
      "SELFFUNC",
      {
        self.OfficerBoardCar,
        {
          GetTableID(self)
        }
      }
    }
  }
  local hPilot = Vehicle.GetPilot(self.hTargetCar)
  if Object.IsAlive(self.hTargetCar) and (not hPilot or hPilot ~= self.hSab) then
    Combat.Exit(self.hOfficer)
    Actor.OverrideCombatAI(self.hOfficer, true)
    Actor.EnableNeeds(self.hOfficer, false)
    Vehicle.SetCrashThrough(self.hTargetCar, true)
    Cin.PlayConversation("P1FP_Carbomb_Escape_Start")
    ScriptSequence.Run(self.hOfficer, tEscapeSeq)
  end
end

function P1FP_Carbomb:OfficerBoardCar()
  if not Vehicle.GetPilot(self.hTargetCar) then
    Nav.BoardVehicle(self.hOfficer, self.hTargetCar, "PILOT", true, "P1FP_Carbomb.ExitStartingPosition", self)
  else
    Suspicion.Enable(self.hOfficer, true)
    Actor.OverrideCombatAI(self.hOfficer, false)
    Combat.SetRespondToSound(self.hOfficer, true)
    Combat.SetRespondToDeadBodies(self.hOfficer, true)
    Combat.SetRespondToDamage(self.hOfficer, true)
    Combat.SetRespondToEvents(self.hOfficer, true)
    Combat.SetSquadAssist(self.hOfficer, true)
    Combat.SetIdleScripted(self.hOfficer, false)
    Vehicle.SetCrashThrough(self.hTargetCar, false)
    Combat.SetTarget(self.hOfficer, Vehicle.GetPilot(self.hTargetCar))
  end
end

function P1FP_Carbomb:ExitStartingPosition()
  Nav.SetScriptedPath(self.hOfficer, self.sExitStartPath, false, "P1FP_Carbomb.DriveEscapePath", self, {1})
  Nav.SetScriptedPathSpeed(self.hOfficer, 75, false)
  self:RegisterTriggerEvent(Trigger.WaitFor(self.sCarEndExit, self.hTargetCar, "P1FP_Carbomb.CheckVehDriver", self, {1}), self.sCarEndExit)
  self:RegisterTriggerEvent(Trigger.WaitFor(self.sCarEndFirst, self.hTargetCar, "P1FP_Carbomb.CheckVehDriver", self, {2}, cTRIGGEREVENT_ONENTER, true), self.sCarEndFirst)
  self:RegisterTriggerEvent(Trigger.WaitFor(self.sCarEndSecond, self.hTargetCar, "P1FP_Carbomb.CheckVehDriver", self, {1}, cTRIGGEREVENT_ONENTER, true), self.sCarEndSecond)
end

function P1FP_Carbomb:CheckVehDriver(...)
  local a_tCallbackData, a_nIndex
  if arg.n == 1 then
    a_nIndex = unpack(arg)
  else
    a_tCallbackData, a_nIndex = unpack(arg)
  end
  local hDriver = Vehicle.GetPilot(self.hTargetCar)
  if hDriver and hDriver == self.hOfficer then
    self.DriveEscapePath(self, a_nIndex)
  end
end

function P1FP_Carbomb:DriveEscapePath(a_nIndex)
  if 2 < a_nIndex then
    a_nIndex = 1
  end
  Nav.SetScriptedPath(self.hOfficer, self.sEscapePaths[a_nIndex], false, "P1FP_Carbomb.DriveEscapePath", self, {
    a_nIndex + 1
  })
  Nav.SetScriptedPathSpeed(self.hOfficer, 75)
end

function P1FP_Carbomb:SetupProximityFail()
  local tProxEvent = {
    EventType = "ProximityEvent",
    ObjectA = self.hSab,
    ObjectB = self.hTargetCar,
    Proximity = 80,
    Negate = true
  }
  if not self:IsMissionTaskActive("P1FP_Carbomb.TASK_GoToCourtyard") and Object.IsAlive(self.hTargetCar) then
    self.eCarProx = Util.CreateEvent(tProxEvent, "P1FP_Carbomb.Fail", self, {
      "P1FP_Carbomb_Text.MissionFail2"
    })
    self:RegisterEvent(self.eCarProx)
  end
end

function P1FP_Carbomb:Fail(...)
  local a_tCallbackData, a_sFailText
  if arg.n == 1 then
    a_sFailText = unpack(arg)
  else
    a_tCallbackData, a_sFailText = unpack(arg)
  end
  if a_sFailText == "P1FP_Carbomb_Text.MissionFail2" then
    Cin.PlayConversation("P1FP_Carbomb_Escape_Fail", "P1FP_Carbomb._Fail", self, {a_sFailText})
  else
    self._Fail(self, a_sFailText)
  end
  if self.eCarDeathEvent then
    Util.KillEvent(self.eCarDeathEvent)
    self.eCarDeathEvent = nil
  end
  if self.eSeanDeathEvent then
    Util.KillEvent(self.eSeanDeathEvent)
    self.eSeanDeathEvent = nil
  end
  if self.eExitVehEvent then
    Util.KillEvent(self.eExitVehEvent)
    self.eExitVehEvent = nil
  end
  if self.bVehicleManuallyStopped == true then
    SabTaskObjectiveDeliver.ReleaseVehicle(self, self.hTargetCar)
    self.bVehicleManuallyStopped = false
  end
end

function P1FP_Carbomb:_Fail(...)
  local a_tCallbackData, a_sFailText
  if arg.n == 1 then
    a_sFailText = unpack(arg)
  else
    a_tCallbackData, a_sFailText = unpack(arg)
  end
  self:MissionTaskFail(a_sFailText)
end

function P1FP_Carbomb:CancelVehicleStuff()
  Trigger.Enable(self.sTrigger, false)
  if self.eCarProx then
    Util.KillEvent(self.eCarProx)
  end
end

function P1FP_Carbomb:RunConvoCheck(a_sString)
  if Object.GetDistance(self.hSab, self.hOfficer) <= self.nDialogRange then
    Cin.PlayConversation(a_sString)
  end
end

function P1FP_Carbomb:SetupHideSantos()
  self:RegisterTriggerEvent(Trigger.WaitFor(self.sTrigSantos, self.hSab, "P1FP_Carbomb.HideSantos", self, {true}, cTRIGGEREVENT_ONEXIT), self.sTrigSantos)
end

function P1FP_Carbomb:HideSantos(...)
  local a_tCallbackData, a_bHide
  if arg.n == 1 then
    a_bHide = unpack(arg)
  else
    a_tCallbackData, a_bHide = unpack(arg)
  end
  if a_bHide then
    RewardsManager.HideStarter("santos_ext_hideout", true)
  else
    RewardsManager.ShowStarter("santos_ext_hideout", true)
  end
end

function P1FP_Carbomb:KillExitVehEvent()
  if self.eExitVehEvent then
    Util.KillEvent(self.eExitVehEvent)
  end
end

function P1FP_Carbomb:ShowTutorial()
  Saboteur.ShowToolTip("TutorialTip_Text.Shop_Vehicle")
end

function P1FP_Carbomb:DoFadeToBlack()
  Render.FadeTo(0, 0, 0, 255, 1)
  local tTimerEvent = {EventType = "TimerEvent", Time = 1}
  Util.CreateEvent(tTimerEvent, "P1FP_Carbomb.RemoveCar", self)
end

function P1FP_Carbomb:RemoveCar()
  Object.Despawn(self.hTargetCar, -1, false)
  Render.FadeTo(0, 0, 0, 0, 1)
  local tTimerEvent = {EventType = "TimerEvent", Time = 1}
  Util.CreateEvent(tTimerEvent, "P1FP_Carbomb.DoComplete", self)
end

function P1FP_Carbomb:KillCarDeathEvent()
  if self.eCarDeathEvent then
    Util.KillEvent(self.eCarDeathEvent)
    self.eCarDeathEvent = nil
  end
end

function P1FP_Carbomb:ResetLimoHealth()
  local nHealth = Object.GetHealth(self.hTargetCar)
  local nFireThreshold = Vehicle.GetFireThreshold(self.hTargetCar)
  if nHealth <= nFireThreshold then
    Object.SetHealth(self.hTargetCar, nFireThreshold + 5)
  end
end

function P1FP_Carbomb:DoComplete()
  self:CompleteThisMission()
end

function P1FP_Carbomb:MISSION_ONCOMPLETE()
  local tTimerEvent = {EventType = "TimerEvent", Time = 10}
  Util.CreateEvent(tTimerEvent, "P1FP_Carbomb.ShowTutorial", self)
end

function P1FP_Carbomb:MISSION_ONCANCEL()
  self.HideSantos(self, false)
end
