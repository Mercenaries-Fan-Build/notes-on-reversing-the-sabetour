if not ProximityDeathExplosion then
  ProximityDeathExplosion = {}
end

function ProximityDeathExplosion:OnEnter()
  self.t_AllEvents = {}
  table.insert(self.t_AllEvents, Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = ProximityDeathExplosion.BuildStreamEventTable(self)
  }, "ProximityDeathExplosion.Configure", self))
end

function ProximityDeathExplosion:OnExit()
  if self.t_AllEvents then
    for i, v in ipairs(self.t_AllEvents) do
      if v and type(v) == "number" then
        Util.KillEvent(v)
      end
    end
  end
  if self.t_AllEvents then
    for i, v in ipairs(self.t_AllEvents) do
      if v and type(v) == "table" and v[2] ~= nil and v[1] ~= nil then
        Trigger.ClearCallback(v[2], v[1])
      end
    end
  end
end

function ProximityDeathExplosion:BuildStreamEventTable()
  local tCollectedStreamEvents = {}
  table.insert(tCollectedStreamEvents, self.SMEDTable.sProximityObject)
  return tCollectedStreamEvents
end

function ProximityDeathExplosion:Configure()
  EVENT_PlayerToActorProximity("ProximityDeathExplosion.ExplodeIt", self, self.SMEDTable.sProximityObject, self.SMEDTable.nProximityDistance)
end

function ProximityDeathExplosion:ExplodeIt()
  for i = 1, #self.SMEDTable.lsExplosionLocators do
    local hTempHandle = Util.GetHandleByName(self.SMEDTable.lsExplosionLocators[i])
    if hTempHandle then
      local x, y, z = Object.GetPosition(hTempHandle)
      Util.CreateExplosion("Explosion_SAB_DynamiteFuse", x, y, z)
    end
  end
  Object.Kill(Util.GetHandleByName(self.SMEDTable.sProximityObject))
end
