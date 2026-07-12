WorldBorder = WorldBorder or {}
Trigger = Trigger or {}
setmetatable(WorldBorder, {__index = Trigger})

function WorldBorder.OnEnter(_, a_hTrigger)
  Trigger.CreateWorldBorderZone(a_hTrigger)
end
