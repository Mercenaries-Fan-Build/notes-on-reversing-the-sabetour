if not ProximityExplosionTrigger then
  ProximityExplosionTrigger = {}
end

function ProximityExplosionTrigger:OnEnter()
  self.t_AllEvents = {}
  table.insert(self.t_AllEvents, Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = ProximityExplosionTrigger.BuildStreamEventTable(self)
  }, "ProximityExplosionTrigger.Configure", self))
end

function ProximityExplosionTrigger:OnExit()
  if self.t_AllEvents then
    for i, v in ipairs(self.t_AllEvents) do
      if v then
        Util.KillEvent(v)
      end
    end
  end
  if self.hTimerEvent then
    Util.KillEvent(self.hTimerEvent)
  end
end

function ProximityExplosionTrigger:BuildStreamEventTable()
  local tCollectedStreamEvents = {}
  table.insert(tCollectedStreamEvents, self.SMEDTable.sProximityLocator)
  return tCollectedStreamEvents
end

function ProximityExplosionTrigger:Configure()
  self.nNumber = 1
  EVENT_PlayerToActorProximity("ProximityExplosionTrigger.ExplosionSequence", self, self.SMEDTable.sProximityLocator, self.SMEDTable.nProximityDistance)
end

function ProximityExplosionTrigger:ExplosionSequence()
  if self.nNumber < self.SMEDTable.nExplosionRange then
    local bNotDone = true
    while bNotDone and self.nNumber < self.SMEDTable.nExplosionRange do
      local hTempHandle = Util.GetHandleByName(self.SMEDTable.sExplosionStringName .. "(" .. self.nNumber .. ")")
      if hTempHandle then
        local x, y, z = Object.GetPosition(hTempHandle)
        local sBluePrintName = self.SMEDTable.lsExplosionBlueprints[math.random(#self.SMEDTable.lsExplosionBlueprints)]
        Util.CreateExplosion(sBluePrintName, x, y, z)
        bNotDone = false
        local tEvent = {
          EventType = "TimerEvent",
          Time = self.SMEDTable.nExplosionDelays
        }
        self.hTimerEvent = Util.CreateEvent(tEvent, "ProximityExplosionTrigger.ExplosionSequence", self)
      end
      self.nNumber = self.nNumber + 1
    end
  end
end
