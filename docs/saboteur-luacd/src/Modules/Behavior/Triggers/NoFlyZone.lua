NoFlyZone = NoFlyZone or {}
Trigger = Trigger or {}
setmetatable(NoFlyZone, {__index = Trigger})

function NoFlyZone:OnEnter(a_hController)
  Trigger.CreateNoFlyZone(a_hController)
end
