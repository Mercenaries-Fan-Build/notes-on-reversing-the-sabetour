RoadBlockZone = RoadBlockZone or {}
Trigger = Trigger or {}
setmetatable(RoadBlockZone, {__index = Trigger})

function RoadBlockZone.OnEnter(_, a_hTrigger)
  Trigger.AddRoadBlock(a_hTrigger)
end

function RoadBlockZone.OnExit(_, a_hTrigger)
  Trigger.RemoveRoadBlock(a_hTrigger)
end

function RoadBlockZone.OnTriggerEnter(_, a_hObj)
end
