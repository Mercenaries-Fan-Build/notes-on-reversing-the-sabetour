if not PoisonField then
  PoisonField = {}
end

function PoisonField:OnEnter()
  self.t_AllEvents = {}
  table.insert(self.t_AllEvents, Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = PoisonField.BuildStreamEventTable(self)
  }, "PoisonField.Configure", self))
end

function PoisonField:BuildStreamEventTable()
  local tCollectedStreamEvents = {}
  for i, v in ipairs(self.SMEDTable.lsPoisonRegion) do
    table.insert(tCollectedStreamEvents, v)
  end
  return tCollectedStreamEvents
end

function PoisonField:Configure()
  if self.SMEDTable.bActiveFromBegining == true then
    PoisonField.Activate(self)
  end
end

function PoisonField:Activate()
  self.bDisabled = false
  PoisonField.LoopDamage(self)
end

function PoisonField:Deactivate()
  self.bDisabled = true
  PoisonField.Cleanup(self)
end

function PoisonField.ChangeLabels(hThisSelfTable, sTheNewLabel)
  local t_PFself = Actor.GetSelf(hThisSelfTable)
  t_PFself.SMEDTable.sDamageLabels = sTheNewLabel
end

function PoisonField:LoopDamage()
  if self.bDisabled then
    return
  end
  self.eLoopEvent = Util.CreateEvent({
    EventType = "TimerEvent",
    Time = self.SMEDTable.nTickLength
  }, "PoisonField.LoopDamage", self)
  if not self._Filter then
    self._Filter = Filter.New(self.SMEDTable.sDamageLabels)
  end
  for i, sPF in pairs(self.SMEDTable.lsPoisonRegion) do
    local hTrigger = Handle(sPF)
    if not hTrigger then
      PoisonField.Cleanup(self)
      break
    end
    local tWho = Trigger.GetAllWithin(hTrigger, self._Filter)
    if tWho ~= nil then
      for j, hWho in ipairs(tWho) do
        if Object.IsDead(hWho) == false then
          Object.SetHealth(hWho, Object.GetHealth(hWho) - self.SMEDTable.nDamagePerTick)
          if Object.GetHealth(hWho) <= 10 then
            Object.Kill(hWho)
          end
        end
      end
    end
  end
end

function PoisonField:OnExit()
  if self.t_AllEvents then
    for i, v in ipairs(self.t_AllEvents) do
      if v then
        Util.KillEvent(v)
      end
    end
  end
  PoisonField.Cleanup(self)
end

function PoisonField:Cleanup()
  self.bDisabled = true
  if self.eLoopEvent then
    Util.KillEvent(self.eLoopEvent)
  end
  if self._Filter then
    Filter.Delete(self._Filter)
  end
end
