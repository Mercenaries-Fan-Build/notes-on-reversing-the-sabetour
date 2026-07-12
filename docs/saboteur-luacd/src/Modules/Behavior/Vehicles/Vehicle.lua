if not Vehicle then
  Vehicle = {}
end

function Vehicle:OnEnter()
end

function Vehicle:OnExit()
end

function Vehicle:OnVehicleEnter(a_hPassenger)
end

function Vehicle:OnVehicleExit(a_hPassenger)
end

function Vehicle:OnDamage(a_DamageDoer, a_flags)
  print("vehicle.ondamage!", self, a_DamageDoer, a_flags)
end
