HostileZone = HostilenZone or {}
Trigger = Trigger or {}
setmetatable(HostileZone, {__index = Trigger})

function HostileZone:OnEnter(a_hController)
  Trigger.CreateHostileZone(a_hController)
end
