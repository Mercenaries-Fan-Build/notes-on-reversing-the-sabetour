SuspicionZonePed = SuspicionZonePed or {}
SuspicionZone = SuspicionZone or {}
setmetatable(SuspicionZonePed, {__index = SuspicionZone})

function SuspicionZonePed:OnEnter(a_hController)
  Trigger.CreateSuspicionZone(a_hController, true, false)
end
