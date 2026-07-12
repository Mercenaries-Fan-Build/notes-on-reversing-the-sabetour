SuspicionZone = SuspicionZone or {}
Trigger = Trigger or {}
setmetatable(SuspicionZone, {__index = Trigger})

function SuspicionZone:OnEnter(a_hController)
  Trigger.CreateSuspicionZone(a_hController)
end
