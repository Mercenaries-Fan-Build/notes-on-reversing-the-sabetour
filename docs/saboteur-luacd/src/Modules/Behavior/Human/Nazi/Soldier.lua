Soldier = Soldier or {}

function Soldier:OnEnter()
  self.bHasEnteredCombat = false
  self.sDebugLabel = "SOLDIER"
  self.bDebugMode = false
  self.nWarnProximity = 5
  self.nWarnTimeout = 10
  Soldier.SetSquad(self)
  Soldier.ConfigureOptions(self)
end

function Soldier:ConfigureOptions()
  Combat.SetRespondToSound(self.hController, true)
  Combat.SetRespondToDeadBodies(self.hController, true)
  Combat.SetRespondToDamage(self.hController, true)
  Combat.SetRespondToEvents(self.hController, true)
  Combat.SetRespondToPaperCheckEvent(self.hController, true)
  Soldier.ConfigurePath(self)
  Combat.SetStationary(self.hController, self.SMEDTable.bIsTurret or false)
  Combat.SetIdleHoldWeapon(self.hController, self.SMEDTable.bHoldWeaponWhenIdle or false)
  Combat.SetWimpyUntilProvoked(self.hController, self.SMEDTable.bWimpyUntilProvoked or false)
  Combat.SetTargetAggressively(self.hController, self.SMEDTable.bTargetAggressively or false)
  Combat.SetWimpy(self.hController, self.SMEDTable.bWimpy or false)
  if self.SMEDTable.TetherRadius and self.SMEDTable.TetherRadius >= 0 then
    if self.SMEDTable.TetherRadius < 3 then
      self.SMEDTable.TetherRadius = 3
    end
    if self.SMEDTable.BreakTetherRadius and 0 > self.SMEDTable.BreakTetherRadius then
      self.SMEDTable.BreakTetherRadius = -1
    end
    local x, y, z = Actor.GetPosition(self.hController)
    Combat.SetTether(self.hController, x, y, z, self.SMEDTable.TetherRadius, self.SMEDTable.BreakTetherRadius)
  end
  Suspicion.Enable(self.hController, true)
  if self.SMEDTable.sAttrPtContainer and string.upper(self.SMEDTable.sAttrPtContainer) ~= "NONE" then
    if not self.SMEDTable.sAttrPtName or string.upper(self.SMEDTable.sAttrPtName) == "NONE" then
      Util.Assert(false, "You need to specify an sAttrPtName for (" .. Util.GetNameFromHandle(self.hController) .. ") to use inside of the object (" .. self.SMEDTable.sAttrPtContainer .. ")")
    end
    Actor.SetAttrPt(self.hController, self.SMEDTable.sAttrPtName)
  elseif (not self.SMEDTable.sAttrPtContainer or string.upper(self.SMEDTable.sAttrPtContainer) == "NONE") and self.SMEDTable.sAttrPtName and string.upper(self.SMEDTable.sAttrPtName) ~= "NONE" then
    Actor.SetAttrPt(self.hController, self.SMEDTable.sAttrPtName)
  end
  if self.SMEDTable.bWarnsPlayer ~= nil and self.SMEDTable.bWarnsPlayer == true then
    Soldier.SetWarnProximityEvent(self, true)
  end
end

function Soldier:OnPlayerEntersWarnProximity()
  Soldier.SetWarnProximityEvent(self, false)
  local sab = Handle("Saboteur")
  if not Sensory.CanSee(self.hController, sab) then
    return
  end
  if Actor.IsInVehicle(sab) then
    return
  end
  if Actor.IsDisguised(sab) then
    return
  end
  local tSeq = {
    {
      "WALKTOOBJECT",
      {"Saboteur", 2.5}
    },
    {"STOPMOVING"},
    {
      "TURNTOFACE",
      {"Saboteur"}
    },
    {
      "PLAYANIMATION",
      {
        "nazi_halt_1"
      }
    }
  }
  ScriptSequence.Run(self.hController, tSeq)
  Cin.PlayConversationWith("cht_com_halt", {
    self.hController
  })
end

function Soldier:OnPlayerExitsWarnProximity()
  ScriptSequence.Kill(self.hController)
  Actor.CancelAnimation(self.hController)
  Combat.ReturnToIdlePos(self.hController)
  Suspicion.Enable(self.hController, true)
  if self.eWarnTimeout then
    Util.KillEvent(self.eWarnTimeout)
  end
  Soldier.SetWarnProximityEvent(self, true)
end

function Soldier:OnWarnTimeout()
  Soldier.KillWarnEvents(self)
  Actor.CancelAnimation(self.hController)
  Combat.SetTarget(self.hController, Handle("Saboteur"))
  Combat.SetCombat(self.hController)
end

function Soldier:KillWarnEvents()
  if self.eProxEnter then
    Util.KillEvent(self.eProxEnter)
  end
  if self.eProxExit then
    Util.KillEvent(self.eProxExit)
  end
  if self.eWarnTimeout then
    Util.KillEvent(self.eWarnTimeout)
  end
end

function Soldier:SetWarnProximityEvent(a_bEnterProx)
  if self.bHasEnteredCombat == false then
    if a_bEnterProx == true then
      local tProximityEvent = {
        EventType = "ProximityEvent",
        ObjectA = Handle("Saboteur"),
        ObjectB = self.hController,
        Proximity = self.nWarnProximity
      }
      self.eProxEnter = Util.CreateEvent(tProximityEvent, "Soldier.OnPlayerEntersWarnProximity", self)
    else
      local tProximityEvent = {
        EventType = "ProximityEvent",
        ObjectA = Handle("Saboteur"),
        ObjectB = self.hController,
        Proximity = self.nWarnProximity + 1,
        Negate = true
      }
      self.eProxExit = Util.CreateEvent(tProximityEvent, "Soldier.OnPlayerExitsWarnProximity", self)
    end
  end
end

function Soldier:SetSquad()
  Squad.Create("GenericNazi")
  Squad.AddMember("GenericNazi", self.hController)
end

function Soldier:ConfigurePath()
  local nMoveType = cPATHTYPE_LOOP
  if not self.SMEDTable.sPatrolPathName then
    return
  end
  if self.SMEDTable.sPatrolType == "LOOP" then
    nMoveType = cPATHTYPE_LOOP
  elseif self.SMEDTable.sPatrolType == "BOUNCE" then
    nMoveType = cPATHTYPE_BOUNCE
  elseif self.SMEDTable.sPatrolType == "RANDOM" then
    nMoveType = cPATHTYPE_RANDOM
  elseif self.SMEDTable.sPatrolType == "ONCE" then
    nMoveType = cPATHTYPE_ONCE
  elseif self.SMEDTable.sPatrolType == "None" then
    nMoveType = cPATHTYPE_LOOP
  elseif self.SMEDTable.sPatrolType == nil then
    nMoveType = cPATHTYPE_ONCE
  else
    Util.Assert(false, "You've entered a bad patrol type for " .. Util.GetNameFromHandle(self.hController) .. " : Defaulting to LOOP")
  end
  if not self.SMEDTable.sPathConditions or self.SMEDTable.sPathConditions == "OnSpawn" then
    Combat.SetIdlePath(self.hController, self.SMEDTable.sPatrolPathName, nMoveType)
  elseif self.SMEDTable.sPathConditions == "PlayerProximity" then
    self.ePathStart = Util.CreateEvent({
      EventType = "ProximityEvent",
      Proximity = self.SMEDTable.sPathCondValue,
      ObjectA = self.hController,
      ObjectB = Util.GetHandleByName("Saboteur")
    }, "Soldier.WalkDefaultPath", self, {-1, nMoveType})
  elseif self.SMEDTable.sPathConditions == "PlayerCrossesTrigger" then
    Trigger.WaitFor(self.SMEDTable.sPathCondValue, Util.GetHandleByName("Saboteur"), "Soldier.WalkDefaultPath", self, {nMoveType})
  end
end

function Soldier:WalkDefaultPath(a_tData, a_nMoveType)
  Combat.SetIdlePath(self.hController, self.SMEDTable.sPatrolPathName, a_nMoveType)
end

function Soldier:OnDeath(a_hDamageDoer)
  ScriptSequence.Kill(self.hController)
end

function Soldier:OnSuspicionEnterGreen()
  dprint(self, "OnSuspicionEnterGreen()")
  if self.tCurrentSequence and self.tCurrentSequence.bIsIdle and self.tCurrentSequence.bIsIdle == true then
    dprint(self, "Found idle sequence!")
    ScriptSequence._Run(self, "NONE", self.tCurrentSequence.nLastCompletedCommand + 1)
  end
end

function Soldier:OnSuspicionEnterYellow()
  dprint(self, "OnSuspicionEnterYellow()")
  if self.tCurrentSequence and self.tCurrentSequence.bIsIdle and self.tCurrentSequence.bIsIdle == true then
    dprint(self, "Current sequence is an idle sequence. Ok to pause!")
    ScriptSequence.Pause(self.hController)
  end
  Actor.CancelAnimation(self.hController)
  GameTips.ShowTip("SuspicionYellowTip")
end

function Soldier:OnIdleScriptedEnter()
  dprint(self, "IdleScriptedEnter()")
end

function Soldier:OnIdleScriptedExit()
  dprint(self, "IdleScriptedExit()")
end

function Soldier:OnSuspicionEnterFlashingYellow(a_hTarget)
  Actor.CancelAnimation(self.hController)
  GameTips.ShowTip("SuspicionYellowFlashTip")
end

function Soldier:OnSuspicionEnterRed(a_hTarget)
  GameTips.ShowTip("SuspicionRedTip")
end

function Soldier:OnDamage(a_hDamageDoer, a_cDamageType)
  if a_hDamageDoer == hSab and a_cDamageType == 4 then
    GameTips.ShowTip("FirstNaziPunch")
  end
end

function Soldier:OnCombatEnter(a_hTarget)
  self.bHasEnteredCombat = true
  Soldier.KillWarnEvents(self)
  GameTips.bSuspicionYellow = true
  GameTips.bSuspicionFlashYellow = true
end

function Soldier:UnsetTurretFlag()
  Combat.SetStationary(self.hController, false)
end

function Soldier:OnExit()
  ScriptSequence.Kill(self.hController)
  Soldier.KillWarnEvents(self)
  if self.SMEDTable.sPathConditions == "PlayerCrossesTrigger" then
    Trigger.DoNotWaitFor(self.SMEDTable.sPathCondValue, Util.GetHandleByName("Saboteur"))
  end
  if self.ePathStart then
    Util.KillEvent(self.ePathStart)
  end
end
