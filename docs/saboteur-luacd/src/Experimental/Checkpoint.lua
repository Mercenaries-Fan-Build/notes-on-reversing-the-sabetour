if not Checkpoint then
  Checkpoint = {}
end
Checkpoint.cSTATE_LOADING = 0
Checkpoint.cSTATE_CONFIGURE = 1
Checkpoint.cSTATE_IDLE = 2
Checkpoint.cSTATE_CHECKING_NPC = 3
Checkpoint.cSTATE_CHECKING_SAB = 4
Checkpoint.cSTATE_GATEOPEN = 5
Checkpoint.cIDLE = 0
Checkpoint.cCHECKING_NPC = 1
Checkpoint.cCHECKING_SAB = 2

function Checkpoint:OnEnter()
  self.bDebugMode = false
  self.sDebugLabel = "CHECKPOINT"
  Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      self.SMEDTable.sZoneName,
      self.SMEDTable.sFlypaperTriggerName,
      self.SMEDTable.sCheckpointLeader,
      self.SMEDTable.sGateKeeperName,
      self.SMEDTable.sGateSwitchPt,
      self.SMEDTable.sExitZone
    }
  }, "Checkpoint.Configure", self)
end

function Checkpoint:Configure()
  Tips.Print(self, "All objects streamed in...")
  if self.SMEDTable.sFlypaperTriggerName ~= nil then
    Tips.Print(self, "Flypaper trigger is present. Setting up listener.")
    local tFlypaperEvent = {
      EventType = "OnTriggerEnter",
      Target = Util.GetHandleByName(self.SMEDTable.sFlypaperTriggerName)
    }
    self.eFlypaperListener = Util.CreateEvent(tFlypaperEvent, "Checkpoint.OnFlypaperZoneEntered", self, {}, true)
  end
  Tips.Print(self, "Setting up death event for Leader")
  self.hLeader = Util.GetHandleByName(self.SMEDTable.sCheckpointLeader)
  local tLeaderDeathEvent = {
    EventType = "DeathEvent",
    ObjectHandle = self.hLeader
  }
  self.eLeaderDeath = Util.CreateEvent(tLeaderDeathEvent, "Checkpoint.KillCheckpoint", self)
  self.nLeaderX, self.nLeaderY, self.nLeaderZ = Object.GetPosition(self.hLeader)
  self.nLeaderRot = Actor.GetFacingDir(self.hLeader)
  Squad.Create("Checkpoint")
  Squad.AddMember("Checkpoint", self.hLeader)
  Tips.Print(self, "Setting up death event for GateKeeper")
  self.hGateKeeper = Util.GetHandleByName(self.SMEDTable.sGateKeeperName)
  local tGateKeeperDeathEvent = {
    EventType = "DeathEvent",
    ObjectHandle = self.hGateKeeper
  }
  self.eGateKeeperDeath = Util.CreateEvent(tGateKeeperDeathEvent, "Checkpoint.KillCheckpoint", self)
  self.nGateKeeperX, self.nGateKeeperY, self.nGateKeeperZ = Object.GetPosition(self.hGateKeeper)
  self.nGateKeeperRot = Actor.GetFacingDir(self.hGateKeeper)
  Tips.Print(self, "Setting up OnTriggerEnter event for the CheckZone")
  local tCheckZoneEvent = {
    EventType = "OnTriggerEnter",
    Target = Util.GetHandleByName(self.SMEDTable.sZoneName)
  }
  self.eCheckZoneListener = Util.CreateEvent(tCheckZoneEvent, "Checkpoint.OnCheckZoneEntered", self, {}, true)
  Tips.Print(self, "Setting up OnTriggerExit event for the ExitZone")
  local tExitZoneEvent = {
    EventType = "OnTriggerExit",
    Target = Util.GetHandleByName(self.SMEDTable.sExitZone)
  }
  self.eExitZoneEvent = Util.CreateEvent(tExitZoneEvent, "Checkpoint.OnExitZone", self, {}, true)
  self.STATE = Checkpoint.cIDLE
  Combat.SetIdleScripted(self.hGateKeeper, true)
  Combat.SetIdleScripted(self.hLeader, true)
  Actor.SetVehicleAvoidance(self.hGateKeeper, false)
  Actor.SetVehicleAvoidance(self.hLeader, false)
  Suspicion.Enable(self.hGateKeeper, false)
  Suspicion.Enable(self.hLeader, false)
end

function Checkpoint:OnCheckZoneEntered(a_tTriggerData)
  local hActor = a_tTriggerData[2]
  if Object.IsVehicle(hActor) == true then
    local hPilot = Vehicle.GetPilot(hActor)
    if hPilot ~= nil then
      if hPilot == Util.GetHandleByName("Saboteur") then
        Checkpoint.EnterState_CheckSab(self)
      else
        Checkpoint.EnterState_CheckNPC(self, hPilot)
      end
      Checkpoint.PaperCheck(self, hPilot)
    else
      Tips.Print(self, "We have a ghost vehicle trying to go through the checkpoint.")
    end
  end
  if hActor == Util.GetHandleByName("Saboteur") and Actor.IsInVehicle(Util.GetHandleByName("Saboteur")) == false then
    Checkpoint.EnterState_CheckSab(self)
  end
  Tips.Print(self, "Actor has entered CheckZone (" .. Util.GetNameFromHandle(hActor) .. ")")
end

function Checkpoint:OnExitZone(a_tTriggerData)
  local hActor = a_tTriggerData[2]
  Tips.Print(self, "Object has exited the checkpoint zone.")
  if hActor == self.hExitTarget then
    Tips.Print(self, "Object is the target we're waiting for so we can reset the checkpoint.")
    self.hExitTarget = nil
    Checkpoint.Reset(self)
  end
end

function Checkpoint:Reset()
  Tips.Print(self, "Checkpoint reset.")
  Checkpoint.CloseGate(self)
end

function Checkpoint:PaperCheck(a_vTarget)
  Combat.SetQuestioning(self.hLeader, Tips.CheckForHandle(a_vTarget))
end

function Checkpoint:EnterState_CheckSab()
  Tips.Print(self, "EnterState_CheckSab()")
  Checkpoint.ExitCurrentState(self)
  self.STATE = Checkpoint.cCHECKING_SAB
  local hSab = Util.GetHandleByName("Saboteur")
  Checkpoint.FocusSearchlights(self, hSab)
  Combat.SetQuestioning(self.hLeader, hSab)
  local tPaperCheckEvent = {
    EventType = "OnPaperCheckComplete",
    Target = Util.GetHandleByName("Saboteur")
  }
  Util.CreateEvent(tPaperCheckEvent, "Checkpoint.OnSabCheckComplete", self)
end

function Checkpoint:EnterState_CheckNPC(a_vTarget)
  Tips.Print(self, "EnterState_CheckNPC()")
  Checkpoint.ExitCurrentState(self)
  Combat.SetQuestioning(self.hLeader, Tips.CheckForHandle(a_vTarget))
  self.hExitTarget = Tips.CheckForHandle(a_vTarget)
end

function Checkpoint:OnSabCheckComplete(a_tData)
  local bHasPassed = a_tData[2]
  if bHasPassed == true then
    Tips.Print(self, "Player has PASSED the paper check. Opening the gates!")
    Checkpoint.BroadcastSuccess(self)
    Checkpoint.OpenGate(self)
    self.hExitTarget = hSab
  else
    Tips.Print(self, "Player has FAILED the paper check. Kill him!")
    Checkpoint.BroadcastFailure(self)
  end
end

function Checkpoint:SetupReset(a_hTarget)
end

function Checkpoint:OnFlypaperZoneEntered(a_tTriggerData)
  local hActor = a_tTriggerData[2]
  Tips.Print(self, "Object has entered Flypaper trigger (" .. Util.GetNameFromHandle(hActor) .. ")")
  if Actor.HasLabel(hActor, "CanUseCheckpoints") == true then
    Tips.Print(self, "Object entering Flypaper trigger can use checkpoints.")
    if self.STATE == Checkpoint.cIDLE then
      Tips.Print(self, "Checkpoint is idle. Accepting new target.")
      Checkpoint.EnterState_CheckNPC(self, hActor)
    end
  end
end

function Checkpoint:EnterState_CheckNPC(a_hNPC)
  Checkpoint.ExitCurrentState(self)
  Checkpoint.FocusSearchlights(self, a_hNPC)
end

function Checkpoint:ExitCurrentState()
  Tips.Print(self, "ExitCurrentState()")
  if self.STATE == Checkpoint.cIDLE then
    Tips.Print(self, "Exiting cIDLE state")
    return
  elseif self.STATE == Checkpoint.cCHECKING_NPC then
    Tips.Print(self, "Exiting cCHECKING_NPC state")
    return
  end
end

function Checkpoint:FocusSearchlights(a_hTarget)
  Tips.Print(self, "FocusSearchlights()")
  for i, v in ipairs(self.SMEDTable.lsSearchlights) do
    local hLight = Util.GetHandleByName(v)
    Searchlight.SetTarget(hLight, "PILOT", a_hTarget)
  end
end

function Checkpoint:ReleaseSearchlights()
  Tips.Print(self, "ReleaseSearchlights()")
  for i, v in ipairs(self.SMEDTable.lsSearchlights) do
    local hLight = Util.GetHandleByName(v)
    Searchlight.SetTarget(hLight, "PILOT", nil)
  end
end

function Checkpoint:BroadcastSuccess()
  Util.BroadcastFunction(self.hController, "OnCheckpointPass", {})
  Util.BroadcastFunction(self.hController, "OnPlayerPassesCheckpoint", {})
end

function Checkpoint:OnCheckpointPass()
  Tips.Print(self, "OnCheckpointPass()")
end

function Checkpoint:BroadcastFailure()
  Util.BroadcastFunction(self.hController, "OnCheckpointFail", {})
  Util.BroadcastFunction(self.hController, "OnPlayerFailsCheckpoint", {})
end

function Checkpoint:OnCheckpointFail()
  Tips.Print(self, "OnCheckpointFail()")
end

function Checkpoint:OpenGate()
  Tips.Print(self, "OpenGate()")
  Checkpoint.ReleaseSearchlights(self)
  local hGateKeeper = Util.GetHandleByName(self.SMEDTable.sGateKeeperName)
  local tSequence = {
    {
      "USEATTRPT",
      {
        self.SMEDTable.sGateSwitchPt
      }
    },
    {
      "DELAY",
      {1}
    }
  }
  ScriptSequence.Run(hGateKeeper, tSequence)
end

function Checkpoint:CloseGate()
  Tips.Print(self, "CloseGate()")
  local hGateKeeper = Util.GetHandleByName(self.SMEDTable.sGateKeeperName)
  local tSequence = {
    {
      "USEATTRPT",
      {
        self.SMEDTable.sGateSwitchPt
      }
    }
  }
  ScriptSequence.Run(hGateKeeper, tSequence)
end

function Checkpoint:OnCheckpointZoneEnter(a_tArgs)
  local hVictim = a_tArgs[2]
  local hSab = Util.GetHandleByName("Saboteur")
  if self.sState == "NORMAL" then
    if hVictim == hSab then
      if Actor.IsInVehicle(hSab) == true then
        if self.bHasPaperCheckedPlayer == false then
          Checkpoint.EnterState(self, "CONFRONTPLAYER")
          Checkpoint.SetupPaperCheckCallbacks(self)
        end
      elseif self.SMEDTable.bConfrontPlayerOnlyOnce == true then
        if self.bHasPaperCheckedPlayer == false then
          Checkpoint.EnterState(self, "CONFRONTPLAYER")
          Checkpoint.SetupPaperCheckCallbacks(self)
        else
          Tips.Print(self, "Player has already been checked. Doing nothing.")
        end
      else
        Checkpoint.EnterState(self, "CONFRONTPLAYER")
        Checkpoint.SetupPaperCheckCallbacks(self)
      end
    elseif Util.GetGameTime() - self.nLastNPCConfrontTime > self.nCooldownTime and math.random(100) < self.SMEDTable.nChanceToHarass then
      local hFilter = Filter.New("!Nazi")
      local hCivFilter = Filter.New("Civilian")
      if Filter.Match(hFilter, hVictim) == true then
        if Filter.Match(hCivFilter, hVictim) == true then
          self.hCurrentVictim = hVictim
          Checkpoint.EnterState(self, "CONFRONTNPC")
        end
      else
        Render.PrintDialogue(self.hOfficer, "Heil Hitler.", 2)
        Actor.PlayAnimation(self.hOfficer, "nazi_hail_idle", 1.25, true)
        Render.PrintDialogue(hVictim, "Heil Hitler.", 2)
        Actor.PlayAnimation(hVictim, "nazi_hail_idle", 1.6, true)
      end
      Filter.Delete(hFilter)
      Filter.Delete(hCivFilter)
    end
  elseif self.sState == "NORM_TO_NPC" then
  elseif self.sState == "CONFRONTNPC" then
    if hVictim ~= hSab or Actor.IsInVehicle(hSab) == true then
    else
      Checkpoint.EnterState(self, "CONFRONTPLAYER")
    end
  elseif self.sState == "CONFRONTVEHICLE" then
  elseif self.sState == "NPC_TO_NORM" then
  end
end

function Checkpoint:EnterState(a_sNewState)
  local hSab = Util.GetHandleByName("Saboteur")
  Tips.Print(self, "Entering state (" .. a_sNewState .. ")")
  Checkpoint.ExitState(self, a_sNewState)
  self.sState = a_sNewState
  if a_sNewState == "CONFRONTPLAYER" then
    Combat.SetQuestioning(self.hOfficer, Util.GetHandleByName("Saboteur"))
    self.ePaperCheckSuccess = Util.CreateEvent({
      EventType = "OnPaperCheckSuccess",
      Target = Util.GetHandleByName("Saboteur")
    }, "Checkpoint.OnPlayerPassesPaperCheck", self, {-1})
  elseif a_sNewState == "CONFRONTNPC" then
    if Actor.IsUsingAttrPt(self.hController) then
      Actor.CancelAttrPt(self.hController)
    end
    local tHarasserSequence = {
      {
        "PRINTDIALOGUE",
        {"HALT!"}
      },
      {
        "PLAYANIMATION",
        {
          "nazi_halt_1"
        }
      },
      {
        "DELAY",
        {2.5}
      },
      {
        "CANCELANIMATION"
      },
      {
        "DELAY",
        {0.5}
      },
      {
        "WALKTOOBJECT",
        {
          self.hHarassPos,
          0.1
        }
      },
      {
        "USEATTRPT_NOCALL",
        {
          self.hHarassPos
        }
      }
    }
    ScriptSequence.Run(self.hOfficer, tHarasserSequence)
    Checkpoint.StoreVictimSequence(self)
    local tVictimSequence = {
      {
        "DISABLESCHEDULE"
      },
      {"STOPMOVING"},
      {
        "DELAY",
        {1.5}
      },
      {
        "WALKTOOBJECT",
        {
          self.hVictimPos,
          0.1
        }
      },
      {
        "USEATTRPT_NOCALL",
        {
          self.hVictimPos
        }
      }
    }
    ScriptSequence.Run(self.hCurrentVictim, tVictimSequence)
    self.hHarassTimeoutID = Util.CreateEvent({
      EventType = "TimerEvent",
      Time = math.random(self.SMEDTable.nHarassTimeMin, self.SMEDTable.nHarassTimeMax)
    }, "Checkpoint.EnterState", self, {"NORMAL"})
  elseif a_sNewState == "CONFRONTNPCVEHICLE" then
    local hVehicle
    local nBoardPosX, nBoardPosY, nBoardPosZ = Object.GetBoardingPosition(hVehicle, cSEAT_PILOT)
    local hPilot = Object.GetPilot(hVehicle)
    local tHarasserSequence = {
      {
        "PRINTDIALOGUE",
        {"HALT!"}
      },
      {
        "PLAYANIMATION",
        {
          "nazi_halt_1"
        }
      },
      {
        "DELAY",
        {2.5}
      },
      {
        "CANCELANIMATION"
      },
      {
        "DELAY",
        {0.5}
      },
      {
        "WALKTOPOINT",
        {
          nBoardPosX,
          nBoardPosY,
          nBoardPosZ
        }
      },
      {
        "TURNTOFACE",
        {hPilot}
      },
      {
        "PLAYANIMATION",
        {
          "nazi_checkpapers_1"
        }
      },
      {
        "DELAY",
        {3}
      }
    }
    ScriptSequence.Run(self.hOfficer, tHarasserSequence)
  elseif a_sNewState == "NORMAL" then
    local tHarasserBackToNormal = {
      {
        "WALKTOOBJECT",
        {
          self.hObservePos,
          0.1
        }
      },
      {
        "USEATTRPT",
        {
          self.hObservePos
        }
      }
    }
    ScriptSequence.Run(self.hOfficer, tHarasserBackToNormal)
  end
end

function Checkpoint:ExitState(a_sNextState)
  if self.sState == "NORMAL" then
    if Actor.IsUsingAttrPt(self.hOfficer) then
      Actor.CancelAttrPt(self.hOfficer)
    end
  elseif self.sState == "CONFRONTPLAYER" then
    Util.KillEvent(self.ePaperCheckSuccess)
  elseif self.sState == "CONFRONTNPC" then
    Util.KillEvent(self.hHarassTimeoutID)
    self.nLastNPCConfrontTime = Util.GetGameTime()
    local tVictimSelf = Actor.GetSelf(self.hCurrentVictim)
    local sPathName = tVictimSelf.SMEDTable.sPathName
    local tVictimSequence = {
      {
        "CANCELATTRPT"
      },
      {
        "DELAY",
        {1.5}
      },
      {
        "PRINTDIALOGUE",
        {"Merci."}
      },
      {
        "ENABLESCHEDULE"
      }
    }
    ScriptSequence.Run(self.hCurrentVictim, tVictimSequence, Checkpoint.ResumeVictimSequence, {self})
    local tHarasserSequence = {
      {
        "CANCELATTRPT"
      },
      {
        "PRINTDIALOGUE",
        {
          "You're free to go."
        }
      }
    }
    ScriptSequence.Run(self.hOfficer, tHarasserSequence)
  end
end

function Checkpoint:SetupPaperCheckCallbacks()
  self.ePlayerSuccess = Util.CreateEvent({
    EventType = "OnPaperCheckSuccess",
    Target = Util.GetHandleByName("Saboteur")
  }, "Checkpoint.OnPlayerSuccess", self)
  self.ePlayerFail = Util.CreateEvent({
    EventType = "OnPaperCheckFail",
    Target = Util.GetHandleByName("Saboteur")
  }, "Checkpoint.OnPlayerFail", self)
end

function Checkpoint:OnPlayerSuccess()
  Util.BroadcastFunction(self.hController, "OnPlayerPassesCheckpoint", {})
  if self.ePlayerFail then
    Util.KillEvent(self.ePlayerFail)
  end
end

function Checkpoint:OnPlayerPassesCheckpoint()
  Tips.Print(self, "OnPlayerClearsCheckpoint()")
end

function Checkpoint:OnPlayerFail()
  Util.BroadcastFunction(self.hController, "OnPlayerFailsCheckpoint", {})
  if self.ePlayerSuccess then
    Util.KillEvent(self.ePlayerSuccess)
  end
end

function Checkpoint:OnPlayerFailsCheckpoint()
  Tips.Print(self, "OnPlayerFailsCheckpoint()")
end

function Checkpoint:StoreVictimSequence()
  local tVictimSelf = Actor.GetSelf(self.hCurrentVictim)
  if tVictimSelf.tCurrentSequence ~= nil then
    self.tVictimCurrentSequence = nil
    self.tVictimCurrentSequence = tVictimSelf.tCurrentSequence
  end
end

function Checkpoint:ClearVictimSequence()
  self.tVictimCurrentSequence = nil
end

function Checkpoint:ResumeVictimSequence()
  if self.tVictimCurrentSequence == nil then
    return false
  else
    local tSequenceData = self.tVictimCurrentSequence.tSequenceData
    local nLastCompletedElement = self.tVictimCurrentSequence.nLastCompletedCommand
    local fCallback = self.tVictimCurrentSequence.fCallback
    local tCallbackParams = self.tVictimCurrentSequence.tCallbackParams
    ScriptSequence.AdvancedRun(self.hCurrentVictim, tSequenceData, nLastCompletedElement + 1, fCallback, tCallbackParams)
    self.tVictimCurrentSequence = nil
    return true
  end
end

function Checkpoint:OnPlayerPassesPaperCheck()
  Checkpoint.EnterState(self, "NORMAL")
  self.bHasPaperCheckedPlayer = true
end

function Checkpoint:KillCheckpoint()
  Util.KillEvent(self.hZoneEnterID)
  Util.KillEvent(self.ePaperCheckSuccess)
end
