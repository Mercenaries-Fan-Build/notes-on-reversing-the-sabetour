SuspicionZoneVeh = SuspicionZoneVeh or {}
SuspicionZone = SuspicionZone or {}
setmetatable(SuspicionZoneVeh, {__index = SuspicionZone})

function SuspicionZoneVeh:OnEnter(a_hController)
  Trigger.CreateSuspicionZone(a_hController, false, true)
end
