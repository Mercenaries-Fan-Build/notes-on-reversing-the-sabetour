if not ExplosionController then
  ExplosionController = {}
end

function ExplosionController:OnEnter()
  self.t_AllEvents = {}
  self.t_TriggerEvents = {}
  local sTrigger = self.SMEDTable.sTriggerName
  local tEvent = {
    EventType = "StreamEvent",
    Objects = {sTrigger}
  }
  table.insert(self.t_AllEvents, Util.CreateEvent(tEvent, "ExplosionController.Init", self))
end

function ExplosionController:Init()
  local sTrigger = self.SMEDTable.sTriggerName
  self.tExplosions = {}
  self.tBlueprints = {}
  for index, value in ipairs(self.SMEDTable.lsExplosionLocators) do
    table.insert(self.tExplosions, Util.GetHandleByName(value))
  end
  for index, value in ipairs(self.SMEDTable.lsExplosionBlueprints) do
    table.insert(self.tBlueprints, value)
  end
  local hSab = Util.GetHandleByName("Saboteur")
  table.insert(self.t_TriggerEvents, {
    Trigger.WaitFor(sTrigger, hSab, "ExplosionController.Activate", self),
    sTrigger
  })
end

function ExplosionController:Activate()
  if self.SMEDTable.bActivateOnEnter then
    for index, value in ipairs(self.tExplosions) do
      local x, y, z = Object.GetPosition(value)
      local sBlueprint
      sBlueprint = self.tBlueprints[index]
      if not sBlueprint then
        sBlueprint = self.tBlueprints[1]
        if not sBlueprint then
          print("explosion manger couldn't find a valid explosion blueprint")
        end
      end
      if sBlueprint then
        Util.CreateExplosion(sBlueprint, x, y, z)
      end
    end
  else
    for index, value in ipairs(self.tExplosions) do
      local tEvent = {
        EventType = "ProximityEvent",
        ObjectA = value,
        ObjectB = Util.GetHandleByName("Saboteur"),
        Proximity = self.SMEDTable.nProximityToLocator,
        Check3D = true
      }
      table.insert(self.t_AllEvents, Util.CreateEvent(tEvent, "ExplosionController.Exploded", self, {value, index}))
    end
  end
end

function ExplosionController:Exploded(value, index)
  local hLocator = value
  local sBlueprint = self.tBlueprints[index]
  if not sBlueprint then
    sBlueprint = self.tBlueprints[1]
    if not sBlueprint then
      print("explosion manger couldn't find a valid explosion blueprint")
    end
  end
  local x, y, z = Object.GetPosition(hLocator)
  if sBlueprint then
    Util.CreateExplosion(sBlueprint, x, y, z)
  end
end

function ExplosionController:OnExit()
  if self.t_AllEvents then
    for i, v in ipairs(self.t_AllEvents) do
      if v then
        Util.KillEvent(v)
      end
    end
  end
  if self.t_TriggerEvents then
    for i, v in ipairs(self.t_TriggerEvents) do
      if v then
        Trigger.ClearCallback(v[2], v[1])
      end
    end
  end
end
