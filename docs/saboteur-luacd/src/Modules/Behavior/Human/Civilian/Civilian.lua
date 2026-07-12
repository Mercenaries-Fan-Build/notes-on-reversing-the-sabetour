if not Civilian then
  Civilian = {}
end

function Civilian:OnEnter()
  self.SMEDTable.nPathMoveType = cPATHTYPE_LOOP
  if self.SMEDTable.sPathMoveType == "LOOP" then
    self.SMEDTable.nPathMoveType = cPATHTYPE_LOOP
  elseif self.SMEDTable.sPathMoveType == "BOUNCE" then
    self.SMEDTable.nPathMoveType = cPATHTYPE_BOUNCE
  elseif self.SMEDTable.sPathMoveType == "RANDOM" then
    self.SMEDTable.nPathMoveType = cPATHTYPE_RANDOM
  elseif self.SMEDTable.sPathMoveType == "ONCE" then
    self.SMEDTable.nPathMoveType = cPATHTYPE_ONCE
  elseif self.SMEDTable.sPathMoveType == "None" then
    self.SMEDTable.nPathMoveType = cPATHTYPE_ONCE
  elseif self.SMEDTable.sPathMoveType == nil then
    self.SMEDTable.nPathMoveType = cPATHTYPE_LOOP
  else
    Util.Assert(false, "You've entered a bad patrol type for " .. Util.GetNameFromHandle(self.hController) .. " : Defaulting to LOOP")
  end
  if self.SMEDTable.sPathConditions == "None" or self.SMEDTable.sPathConditions == "OnSpawn" then
  elseif self.SMEDTable.sPathConditions == "PlayerProximity" then
    self.ePathStart = Util.CreateEvent({
      EventType = "ProximityEvent",
      Proximity = self.SMEDTable.sPathCondValue,
      ObjectA = self.hController,
      ObjectB = Util.GetHandleByName("Saboteur")
    }, "Civilian.WalkDefaultPath", self)
  elseif self.SMEDTable.sPathConditions == "PlayerEntersTrigger" then
    self.ePathStart = Util.CreateEvent({
      EventType = "OnTriggerEnter",
      Target = Util.GetHandleByName(self.SMEDTable.sPathCondValue)
    }, "Civilian.OnDefaultPathTriggerEntered", self, {0})
  end
end

function Civilian:WalkDefaultPath()
  self.bDefaultPathTriggered = true
  Civilian.UsePath(self, self.SMEDTable.sPathName, self.SMEDTable.nPathMoveType, false)
end

function Civilian:UsePath(a_sPathName, a_nMoveType, a_bUrgent)
  self.sCurrentPathName = a_sPathName
  self.nCurrentPathMode = a_nMoveType
  Nav.SetScriptedPath(self.hController, a_sPathName, true)
  Nav.SetScriptedPathType(self.hController, a_nMoveType)
  Nav.SetScriptedPathMoveMode(self.hController, a_bUrgent)
end

function Civilian:KillDefaultPathEvent()
  if self.ePathStart ~= nil then
    Util.KillEvent(self.ePathStart)
    self.ePathStart = nil
  end
end

function Civilian:OnDefaultPathTriggerEntered(a_tArgs)
  local hTriggerCrosser = a_tArgs[2]
  local hSab = Util.GetHandleByName("Saboteur")
  if hTriggerCrosser == hSab then
    Civilian.WalkDefaultPath(self)
  end
end

function Civilian:OnDamage(a_hDamageDoer, a_cDamageType)
  if a_hDamageDoer == hSab then
    GameTips.ShowTip("FriendlyFireTip")
  end
  return
end

function Civilian:OnExit()
  ScriptSequence.Kill(self.hController)
end

function Civilian:PrintToConsole(a_sMessageString)
  if self.bDebugMode == true then
    print("::: " .. Tips.GetDebugTime() .. " CIVILIAN (" .. Util.GetNameFromHandle(self.hController) .. "): " .. a_sMessageString)
    Render.PrintMessage(Tips.GetDebugTime() .. " (" .. Util.GetNameFromHandle(self.hController) .. "): " .. a_sMessageString)
  end
end

function Civilian:HarassCivs(hwho)
  Actor.PlayAnimation(self.hController, "civ_harass_stand_idle", 3, true)
end
