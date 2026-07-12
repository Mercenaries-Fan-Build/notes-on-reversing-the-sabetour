DeleteZone = DeleteZone or {}
Trigger = Trigger or {}
setmetatable(DeleteZone, {__index = Trigger})

function DeleteZone:OnEnter(a_hController)
  Trigger.CreateDeleteZone(a_hController)
end
