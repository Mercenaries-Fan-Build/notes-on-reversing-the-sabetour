if not TimedExplosionTrigger then
  TimedExplosionTrigger = {}
end

function TimedExplosionTrigger:OnEnter()
  Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = TimedExplosionTrigger.BuildStreamEventTable(self)
  }, "TimedExplosionTrigger.Configure", self)
end

function TimedExplosionTrigger:BuildStreamEventTable()
  if not self and not self.SMEDTable then
    return
  end
  local tCollectedStreamEvents = {}
  if self.SMEDTable.sStarterObject then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sStarterObject)
  end
  if self.SMEDTable.sEndObject then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sEndObject)
  end
  return tCollectedStreamEvents
end

function TimedExplosionTrigger:Configure()
  if not self and not self.SMEDTable then
    return
  end
  self.nNumber = 1
  self.bEnded = false
  if self.SMEDTable.sStarterObject and Util.GetHandleByName(self.SMEDTable.sStarterObject) then
    Util.CreateEvent({
      EventType = "DeathEvent",
      ObjectHandle = Util.GetHandleByName(self.SMEDTable.sStarterObject)
    }, "TimedExplosionTrigger.ExplosionSequence", self)
  else
    print("WARNING:TimedExplosionTrigger.Configure sStarterObject was not specified on blueprint properties")
  end
  if self.SMEDTable.sEndObject and Util.GetHandleByName(self.SMEDTable.sEndObject) then
    Util.CreateEvent({
      EventType = "DeathEvent",
      ObjectHandle = Util.GetHandleByName(self.SMEDTable.sEndObject)
    }, "TimedExplosionTrigger.EndExplosionSequence", self)
  else
    print("WARNING:TimedExplosionTrigger.Configure sEndObject was not specified on blueprint properties")
  end
end

function TimedExplosionTrigger:ExplosionSequence()
  if self and self.SMEDTable and self.SMEDTable.nExplosionRange and self.nNumber and self.nNumber <= self.SMEDTable.nExplosionRange and self.bEnded == false then
    local bNotDone = true
    if self.SMEDTable.sExplosionStringName and self.SMEDTable.nExplosionRange then
      while bNotDone and self.nNumber <= self.SMEDTable.nExplosionRange do
        local hTempHandle = Util.GetHandleByName(self.SMEDTable.sExplosionStringName .. "(" .. self.nNumber .. ")")
        if hTempHandle then
          local x, y, z = Object.GetPosition(hTempHandle)
          if self.SMEDTable.sExplosionBPName then
            Util.CreateExplosion(self.SMEDTable.sExplosionBPName, x, y, z)
          else
            Util.CreateExplosion("Explosion_SAB_DynamiteFuse", x, y, z)
          end
          bNotDone = false
          local tEvent = {
            EventType = "TimerEvent",
            Time = self.SMEDTable.nExplosionDelays
          }
          Util.CreateEvent(tEvent, "TimedExplosionTrigger.ExplosionSequence", self)
        end
        self.nNumber = self.nNumber + 1
      end
    end
  end
end

function TimedExplosionTrigger:EndExplosionSequence()
  if self and self.SMEDTable and self.SMEDTable.nExplosionRange and self.nNumber and self.SMEDTable.sExplosionStringName then
    self.bEnded = true
    for i = self.nNumber, self.SMEDTable.nExplosionRange do
      local hTempHandle = Util.GetHandleByName(self.SMEDTable.sExplosionStringName .. "(" .. i .. ")")
      if hTempHandle then
        local x, y, z = Object.GetPosition(hTempHandle)
        if self.SMEDTable.sExplosionBPName then
          Util.CreateExplosion(self.SMEDTable.sExplosionBPName, x, y, z)
        else
          Util.CreateExplosion("Explosion_SAB_DynamiteFuse", x, y, z)
        end
      end
    end
  end
end
