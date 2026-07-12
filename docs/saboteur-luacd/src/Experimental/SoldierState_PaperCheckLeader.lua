if not Soldier then
  Soldier = {}
end

function Soldier:PaperCheckLeaderState_Enter(a_tArgs)
  Soldier.PrintToConsole(self, "Entering PAPERCHECK_LEADER State")
  if Suspicion.GetSuspicionMeterState() == "Red" then
    Soldier.PrintToConsole(self, "Soldier is trying to paper check a player in Red state. Switching to combat!")
    Soldier.EnterState(self, cSTATE_COMBAT)
  end
  local hTarget
  if a_tArgs == nil then
    hTarget = Util.GetHandleByName("Saboteur")
  elseif a_tArgs.hTarget ~= nil then
    hTarget = a_tArgs.hTarget
  else
    hTarget = Util.GetHandleByName("Saboteur")
  end
  if Actor.HasLabel(hTarget, "IsBeingHarassed") == true then
    Soldier.EnterState(self, cSTATE_PAPERCHECK_BACKUP)
    return
  end
  local bBroadcast = a_tArgs.bBroadcast
  if bBroadcast == nil then
    bBroadcast = true
  end
  if a_tArgs == nil then
    if self.SMEDTable.sRequiredPapers ~= nil and self.SMEDTable.sRequiredPapers ~= "NONE" then
      Soldier.StartConfrontation(self, hTarget, self.SMEDTable.sRequiredPapers, bBroadcast)
    else
      Soldier.StartConfrontation(self, hTarget, self.SMEDTable.sRequiredPapers, bBroadcast)
    end
  elseif a_tArgs.sRequiredPapers ~= nil then
    Soldier.StartConfrontation(self, hTarget, a_tArgs.sRequiredPapers, bBroadcast)
  elseif self.SMEDTable.sRequiredPapers ~= nil then
    Soldier.StartConfrontation(self, hTarget, self.SMEDTable.sRequiredPapers, bBroadcast)
  else
    Soldier.StartConfrontation(self, hTarget, "ANTIPAPERS", bBroadcast)
  end
  Suspicion.SetState(self.hController, "FlashingYellow")
  if Sensory.CanSee(hTarget, self.hController) == false then
    local hClosestNazi = Sensory.GetClosestVisibleEnemy(Util.GetHandleByName("Saboteur"))
    if hClosestNazi ~= nil then
      local tConfrontSequence = {
        {
          "PLAYFACINGANIMATION",
          {
            "nazi_halt_1",
            "Saboteur"
          }
        },
        {
          "DELAY",
          {1.5}
        },
        {
          "CANCELANIMATION"
        },
        {
          "DELAY",
          {0.5}
        }
      }
      ScriptSequence.Run(hClosestNazi, tConfrontSequence)
    end
  end
end

function Soldier.ConfrontPlayer(a_vSoldier, a_sRequiredPapers, a_bBroadcast)
  local hSoldier = Tips.CheckForHandle(a_vSoldier)
  local tSoldierSelf = Actor.GetSelf(hSoldier)
  local tArgs = {}
  tArgs.bBroadcast = a_bBroadcast
  tArgs.hTarget = Util.GetHandleByName("Saboteur")
  tArgs.sRequiredPapers = a_sRequiredPapers
  Soldier.EnterState(tSoldierSelf, cSTATE_PAPERCHECK_LEADER, tArgs)
end

function Soldier:StartConfrontation(a_hTarget, a_sRequiredPapers, a_bBroadcast)
  if Actor.HasLabel(a_hTarget, "IsBeingHarassed") == true then
    local tArgs = {}
    tArgs.hTarget = a_hTarget
    Soldier.EnterState(self, cSTATE_PAPERCHECK_BACKUP, tArgs)
    return
  else
    Actor.SetLabel(a_hTarget, "IsBeingHarassed", true)
    self.bIsConfrontationPointMan = true
    self.hConfrontationTarget = a_hTarget
  end
  if a_bBroadcast ~= nil and a_bBroadcast == true then
    local hSurroundingNaziFilter = Filter.New("Human && Nazi")
    Util.BroadcastFunction(self.hController, 12, "SetSuspicion", {
      "FlashingYellow"
    }, hSurroundingNaziFilter)
    Filter.Delete(hSurroundingNaziFilter)
  end
  self.sRequiredPapers = a_sRequiredPapers
  Util.Assert(self.sRequiredPapers ~= nil, "LUA: self.sRequiredPapers is nil. What the hell?")
  Nav.CancelScriptedPath(self.hController)
  Nav.StopMoving(self.hController)
  local targX, targY, targZ = Object.GetPosition(a_hTarget)
  local soldX, soldY, soldZ = Object.GetPosition(self.hController)
  local bTargetIsInVehicle = Actor.IsInVehicle(a_hTarget)
  if bTargetIsInVehicle == true then
    local hVehicle = Actor.GetVehicle(a_hTarget)
    local hWalkTarget = AttractionPt.FindPtInObject(hVehicle, "VehiclePaperCheck")
    local vehX, vehY, vehZ = Object.GetPosition(hWalkTarget)
    Nav.CanPathfind(soldX, soldY + 0.25, soldZ, vehX, vehY + 0.25, vehZ, "Soldier.ConfrontEvaluateTargetPosition", self, {a_hTarget})
  elseif self.SMEDTable.bIsLazyConfronter == false then
    Nav.CanPathfind(soldX, soldY + 0.25, soldZ, targX, targY + 0.25, targZ, "Soldier.ConfrontEvaluateTargetPosition", self, {a_hTarget})
  else
    local tTemp = {false}
    Soldier.ConfrontEvaluateTargetPosition(self, tTemp, a_hTarget)
  end
end

function Soldier:ConfrontEvaluateTargetPosition(a_tOutcome, a_hTarget)
  if a_tOutcome[1] == true then
    Soldier.PrintToConsole(self, "Setting up delayed proximity check, waiting as long as cSUSPICION_DELAYBEFOREPROXCHECK says.")
    Util.CreateEvent({
      EventType = "TimerEvent",
      Time = cSUSPICION_DELAYBEFOREPROXCHECK,
      EventName = "DelayBeforeProxCheck"
    }, "Soldier.SetupConfrontProximityEvent", self, {a_hTarget})
    local hWalkTarget = a_hTarget
    local nStoppageDistange = 2
    if Actor.IsInVehicle(a_hTarget) then
      local hVehicle = Actor.GetVehicle(a_hTarget)
      hWalkTarget = AttractionPt.FindPtInObject(hVehicle, "VehiclePaperCheck")
      nStoppageDistance = 0.25
    end
    if 2 < Object.GetDistance(hWalkTarget, self.hController) then
      local tConfrontSequence = {
        {
          "ATTACHSOUND",
          {
            "vo_nazi1_chatter_halt_02"
          }
        },
        {
          "PLAYANIMATION",
          {
            "nazi_halt_1"
          }
        },
        {
          "DELAY",
          {1.5}
        },
        {
          "CANCELANIMATION"
        },
        {
          "ATTACHSOUND",
          {
            "vo_nazi1_chatter_staythereonway_01"
          }
        },
        {
          "PLAYANIMATION",
          {"nazi_point"}
        },
        {
          "DELAY",
          {0.9}
        },
        {
          "WALKTOOBJECT",
          {hWalkTarget, nStoppageDistance}
        },
        {
          "TURNTOFACE",
          {a_hTarget}
        },
        {
          "DELAY",
          {1}
        }
      }
      ScriptSequence.Run(self.hController, tConfrontSequence, Soldier.BeginQuestioning, {self, a_hTarget})
    else
      local tConfrontSequence = {
        {
          "ATTACHSOUND",
          {
            "vo_nazi1_chatter_halt_02"
          }
        },
        {
          "PLAYANIMATION",
          {
            "nazi_halt_1"
          }
        },
        {
          "DELAY",
          {1.5}
        },
        {
          "CANCELANIMATION"
        }
      }
      ScriptSequence.Run(self.hController, tConfrontSequence, Soldier.BeginQuestioning, {self, a_hTarget})
    end
  else
    Util.CreateEvent({
      EventType = "ProximityEvent",
      EventName = "ConfrontProximityEvent",
      ObjectA = self.hController,
      ObjectB = a_hTarget,
      Proximity = 2,
      Negate = false
    }, "Soldier.ConfrontTargetComplies", self, {a_hTarget})
    Util.CreateEvent({
      EventType = "TimerEvent",
      EventName = "ComplianceTimeout",
      Time = cSUSPICION_COMPLIANCETIMER
    }, "Soldier.ConfrontTargetResists", self, {a_hTarget})
    local tConfrontSequence = {
      {
        "ATTACHSOUND",
        {
          "vo_nazi1_chatter_halt_02"
        }
      },
      {
        "PLAYANIMATION",
        {"nazi_point"}
      },
      {
        "DELAY",
        {0.9}
      },
      {
        "PLAYANIMATION",
        {
          "nazi_halt_1"
        }
      },
      {
        "DELAY",
        {1.5}
      },
      {
        "CANCELANIMATION"
      }
    }
    ScriptSequence.Run(self.hController, tConfrontSequence)
  end
end

function Soldier:SetupConfrontProximityEvent(a_hTarget)
  Soldier.PrintToConsole(self, "Delayed compliance event created. We are now restricting the player to an area.")
  local targX, targY, targZ = Object.GetPosition(a_hTarget)
  Util.CreateEvent({
    EventType = "ProximityEvent",
    EventName = "ConfrontProximityEvent",
    ObjectA = a_hTarget,
    PosX = targX,
    PosY = targY,
    PosZ = targZ,
    Proximity = cSUSPICION_HALTDISTANCE,
    Negate = true
  }, "Soldier.ConfrontTargetResists", self, {a_hTarget})
end

function Soldier:ToggleConfrontTargetFlag(a_hTarget, a_bOverride)
  if a_bOverride == nil then
    if Actor.HasLabel(a_hTarget, "IsBeingHarassed") == true then
      Actor.SetLabel(a_hTarget, "IsBeingHarassed", false)
      return false
    else
      Actor.SetLabel(a_hTarget, "IsBeingHarassed", true)
      return true
    end
  else
    Actor.SetLabel(a_hTarget, "IsBeingHarassed", a_bOverride)
    return a_bOverride
  end
end

function Soldier:ConfrontTargetComplies(a_hTarget)
  Util.KillEvent("ComplianceTimeout")
  Util.CreateEvent({
    EventType = "ProximityEvent",
    EventName = "ComplianceCheck",
    ObjectA = self.hController,
    ObjectB = a_hTarget,
    Proximity = cSUSPICION_HALTDISTANCE,
    Negate = true
  }, "Soldier.ConfrontTargetResists", self, {a_hTarget})
  Soldier.BeginQuestioning(self, a_hTarget)
end

function Soldier:ConfrontTargetResists(a_hTarget)
  ScriptSequence.Pause(self.hController)
  Actor.CancelAnimation(self.hController)
  Util.KillEvent("ConfrontProximityEvent")
  Util.BroadcastFunction(a_hTarget, "OnPaperCheckFail", {})
  Soldier.AttackTarget(self, a_hTarget)
end

function Soldier:BeginQuestioning(a_hTarget)
  local tSequence = {
    {
      "PLAYANIMATION",
      {
        "nazi_checkpapers_1"
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
      "PLAYANIMATION",
      {
        "nazi_standing_idle_3"
      }
    }
  }
  ScriptSequence.Run(self.hController, tSequence)
  Sound.AttachSoundEvent(self.hController, "vo_nazi1_chatter_papershero_01")
  Soldier.PrintToConsole(self, "Setting up DoPaperCheck() timeout at cSUSPICION_PAPERCHECKTIMEOUT seconds")
  Util.CreateEvent({
    EventType = "TimerEvent",
    EventName = "PaperCheckTimeout",
    Time = cSUSPICION_PAPERCHECKTIMEOUT
  }, "Soldier.DoPaperCheck", self, {a_hTarget})
end

function Soldier:DoPaperCheck(a_hTarget)
  Soldier.PrintToConsole(self, "Soldier is requesting (" .. self.sRequiredPapers .. ") from (" .. Util.GetNameFromHandle(a_hTarget) .. ")")
  if self.sRequiredPapers ~= nil and Actor.HasLabel(a_hTarget, self.sRequiredPapers) == true then
    Util.BroadcastFunction(a_hTarget, "OnPaperCheckSuccess", {})
    Sound.AttachSoundEvent(self.hController, "vo_nazi1_chatter_papercheckciviliansucceedsinorder_01")
    Actor.CancelAnimation(self.hController)
    Actor.PlayAnimation(self.hController, "nazi_wave_vehicle_1", 1, true)
    Suspicion.SetState(self.hController, "Green")
    Suspicion.Suspend(self.hController, 5)
  else
    local tSequence = {
      {
        "CANCELANIMATION"
      },
      {
        "PLAYANIMATION",
        {
          "nazi_harass_idle"
        }
      },
      {
        "PLAYSOUND",
        {
          "vo_nazi1_chatter_papercheckcivilianfailsbeat_01"
        }
      },
      {
        "DELAY",
        {4}
      },
      {
        "CANCELANIMATION"
      },
      {
        "SETSUSPICION",
        {"Red"}
      }
    }
    ScriptSequence.Run(self.hController, tSequence, Util.BroadcastFunction, {
      a_hTarget,
      "OnPaperCheckFail",
      {a_hTarget}
    })
  end
end

function Soldier:ClearConfrontationEvents()
  Util.KillEvent("ConfrontProximityEvent")
  Util.KillEvent("PaperCheckTimeout")
  Util.KillEvent("ComplianceCheck")
end

function Soldier:ClearConfrontSettings()
  Soldier.PrintToConsole(self, "Clearing out confrontation settings")
  self.sRequiredPapers = nil
  self.bIsConfrontationPointMan = false
  if self.hConfrontationTarget ~= nil then
    Actor.SetLabel(self.hConfrontationTarget, "IsBeingHarassed", false)
    self.hConfrontationTarget = nil
  end
end

function Soldier.ConfrontTarget(a_vSoldier, a_hTarget, a_sRequiredPapers)
end

function Soldier:SetLastPlayerHarassTime()
  local tSabSelf = Actor.GetSelf(Util.GetHandleByName("Saboteur"))
  tSabSelf.nLastHarassTime = Util.GetGameTime()
  return
end

function Soldier:GetLastPlayerHarassTime()
  local tSabSelf = Actor.GetSelf(Util.GetHandleByName("Saboteur"))
  if tSabSelf.nLastHarassTime ~= nil then
    return tSabSelf.nLastHarassTime
  end
end

function Soldier:EnterPaperCheckLeaderState()
end

function Soldier:PaperCheckLeaderState_Exit()
  Soldier.PrintToConsole(self, "Exiting PAPERCHECK_LEADER State")
  ScriptSequence.Pause(self.hController)
  Soldier.ClearConfrontSettings(self)
  Soldier.ClearConfrontationEvents(self)
end
