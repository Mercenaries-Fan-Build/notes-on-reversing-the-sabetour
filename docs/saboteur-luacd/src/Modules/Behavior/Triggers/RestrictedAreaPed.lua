RestrictedAreaPed = RestrictedAreaPed or {}
RestrictedArea = RestrictedArea or {}
setmetatable(RestrictedAreaPed, {__index = RestrictedArea})

function RestrictedAreaPed:OnEnter(a_hController)
  Trigger.CreateRestrictedArea(a_hController, 0, true, false)
end
