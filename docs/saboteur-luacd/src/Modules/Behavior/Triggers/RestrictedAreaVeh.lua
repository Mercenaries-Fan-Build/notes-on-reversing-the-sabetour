RestrictedAreaVeh = RestrictedAreaVeh or {}
RestrictedArea = RestrictedArea or {}
setmetatable(RestrictedAreaVeh, {__index = RestrictedArea})

function RestrictedAreaVeh:OnEnter(a_hController)
  Trigger.CreateRestrictedArea(a_hController, 0, false, true)
end
