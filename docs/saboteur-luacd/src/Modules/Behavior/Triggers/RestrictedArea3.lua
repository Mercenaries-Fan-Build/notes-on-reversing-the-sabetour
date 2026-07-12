RestrictedArea3 = RestrictedArea3 or {}
RestrictedArea = RestrictedArea or {}
setmetatable(RestrictedArea3, {__index = RestrictedArea})

function RestrictedArea3:OnEnter(a_hController)
  Trigger.CreateRestrictedArea(a_hController, 3)
end
