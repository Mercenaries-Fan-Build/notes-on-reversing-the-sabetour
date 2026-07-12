if not AICombatGroup then
  AICombatGroup = {}
end

function AICombatGroup:OnEnter()
  AICombatGroup.GENERAL_SETUP(self)
end

function AICombatGroup:OnExit()
  for i, e in pairs(self.m_tEvents) do
    Util.KillEvent(e)
  end
end

function AICombatGroup:GENERAL_SETUP()
  Render.PrintMessage("<<AICG IS ACTIVE>>")
  self.tCombatGroup1 = self.SMEDTable.ResistanceGroup
  self.tCombatGroup2 = self.SMEDTable.NaziGroup
  self.nDeadGuys = 0
  self.nDeadNazis = 0
  self.m_tEvents = {}
  AICombatGroup.RunStreamEvents(self)
end

function AICombatGroup:RunStreamEvents()
  local tStreamObjs = AICombatGroup.BuildStreamEventTable(self)
  local tStreamCombatants = {
    EventType = "StreamEvent",
    Objects = tStreamObjs
  }
  Util.CreateEvent(tStreamCombatants, "AICombatGroup.OnCombatantsStream", self)
end

function AICombatGroup:BuildStreamEventTable()
  Render.PrintMessage("Building Stream Table")
  local tCollectedStreamEvents = {}
  for i, v in ipairs(self.SMEDTable.ResistanceGroup) do
    Render.PrintMessage(v)
    table.insert(tCollectedStreamEvents, v)
  end
  for i, v in ipairs(self.SMEDTable.NaziGroup) do
    Render.PrintMessage(v)
    table.insert(tCollectedStreamEvents, v)
  end
  return tCollectedStreamEvents
end

function AICombatGroup:OnCombatantsStream()
  Render.PrintMessage("Combatants Streamed Running Combat Wrapper")
  Joe.SetFireGroupAtGroup(self.tCombatGroup1, "TEMP1", self.tCombatGroup2, "TEMP2")
  for i = 1, #self.tCombatGroup1 do
    local hCombatant = Handle(self.tCombatGroup1[i])
    local tCombatantDeath = {EventType = "DeathEvent", ObjectHandle = hCombatant}
    self.m_tEvents.eDeath1 = Util.CreateEvent(tCombatantDeath, "AICombatGroup.OnSoldierDead", self)
  end
  for i = 1, #self.tCombatGroup2 do
    local hCombatantG2 = Handle(self.tCombatGroup2[i])
    local tCombatant2Death = {EventType = "DeathEvent", ObjectHandle = hCombatantG2}
    self.m_tEvents.eDeath2 = Util.CreateEvent(tCombatant2Death, "AICombatGroup.OnSoldierDead", self)
  end
end

function AICombatGroup:OnSoldierDead()
  for i = 1, #self.tCombatGroup1 do
    local hG1Dude = Handle(self.tCombatGroup1[i])
    if Object.IsAlive(hG1Dude) == false then
      self.nDeadGuys = self.nDeadGuys + 1
    else
    end
  end
  for j = 1, #self.tCombatGroup2 do
    local hG2Dude = Handle(self.tCombatGroup2[j])
    if Object.IsAlive(hG2Dude) == false then
      self.nDeadNazis = self.nDeadNazis + 1
    else
    end
  end
  if self.nDeadNazis < #self.tCombatGroup2 and self.nDeadGuys < #self.tCombatGroup1 then
    Render.PrintMessage("Both CombatantGroups Are Alive")
  elseif self.nDeadNazis < #self.tCombatGroup2 and self.nDeadGuys == #self.tCombatGroup1 then
    Render.PrintMessage("Resistance are Dead")
  elseif self.nDeadNazis == #self.tCombatGroup2 and self.nDeadGuys < #self.tCombatGroup1 then
    Render.PrintMessage("Nazis are Dead")
  end
end

function AICombatGroup:SetActorAdjustOnDeath(tActors, tTargets)
  Render.PrintMessage("Actor Has Died")
  local tActorHandles = {}
  local tTargetHandles = {}
  for i = 1, #tActors do
    if Object.IsAlive(Handle(tActors[i])) == true then
      local hAliveActor = Handle(tActors[i])
      table.insert(tActorHandles, hAliveActor)
    else
    end
  end
  for i = 1, #tTargetHandles do
    if Object.IsAlive(Handle(tTargets[i])) == true then
      local tAliveTarget = Handle(tTargets[i])
      table.insert(tTargetHandles, tAliveTarget)
    else
    end
  end
  if 1 < #tActorHandles and 1 < #tTargetHandles then
    Render.PrintMessage("Combatants are Still Alive")
  elseif 1 < #tActorHandles and #tTargetHandles == 0 then
    Render.PrintMessage("Actors are Still Alive")
  elseif 1 < #tTargetHandles and #tActorHandles == 0 then
    Render.PrintMessage("Targets are Still Alive")
  end
end
