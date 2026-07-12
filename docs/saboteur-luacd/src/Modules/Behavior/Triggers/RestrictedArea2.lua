RestrictedArea2 = RestrictedArea2 or {}
RestrictedArea = RestrictedArea or {}
setmetatable(RestrictedArea2, {__index = RestrictedArea})

function RestrictedArea2:OnEnter(a_hController)
  Trigger.CreateRestrictedArea(a_hController, 2)
end
