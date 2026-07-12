RestrictedArea5 = RestrictedArea5 or {}
RestrictedArea = RestrictedArea or {}
setmetatable(RestrictedArea5, {__index = RestrictedArea})

function RestrictedArea5:OnEnter(a_hController)
  Trigger.CreateRestrictedArea(a_hController, 5)
end
