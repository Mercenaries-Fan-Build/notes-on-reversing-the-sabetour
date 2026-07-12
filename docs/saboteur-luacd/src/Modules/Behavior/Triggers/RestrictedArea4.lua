RestrictedArea4 = RestrictedArea4 or {}
RestrictedArea = RestrictedArea or {}
setmetatable(RestrictedArea4, {__index = RestrictedArea})

function RestrictedArea4:OnEnter(a_hController)
  Trigger.CreateRestrictedArea(a_hController, 4)
end
