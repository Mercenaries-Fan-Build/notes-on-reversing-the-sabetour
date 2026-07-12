if not SimpleHumanSpawner then
  SimpleHumanSpawner = {}
end

function SimpleHumanSpawner:OnEnter()
  self.t_AllEvents = {}
  table.insert(self.t_AllEvents, Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = SimpleHumanSpawner.BuildStreamEventTable(self)
  }, "SimpleHumanSpawner.Configure", self))
end

function SimpleHumanSpawner:OnExit()
  if self.t_AllEvents then
    for i, v in ipairs(self.t_AllEvents) do
      if v then
        Util.KillEvent(v)
      end
    end
  end
end

function SimpleHumanSpawner:BuildStreamEventTable()
  local tCollectedStreamEvents = {}
  for i, v in ipairs(self.SMEDTable.lsAISpawners) do
    table.insert(tCollectedStreamEvents, v)
  end
  return tCollectedStreamEvents
end

function SimpleHumanSpawner:Configure()
end
