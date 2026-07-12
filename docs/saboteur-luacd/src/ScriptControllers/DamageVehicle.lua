if not DamageVehicle then
  DamageVehicle = {}
end

function DamageVehicle:OnEnter()
  self.bDebugMode = false
  self.sDebugLabel = "DamageVehicle"
  dprint(self, "OnEnter")
  self.tEvents = {}
  self.sVehicle = self.SMEDTable.sVehiclePath
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      self.sVehicle
    },
    WaitForGameObject = true
  }
  self.eStreamEvent = Util.CreateEvent(tStreamEvent, "DamageVehicle.OnVehicleStreams", self)
end

function DamageVehicle:OnVehicleStreams()
  local hVehicle = Handle(self.sVehicle)
  Object.SetHealth(hVehicle, Vehicle.GetSmokeThreshold(hVehicle) - 1)
  Vehicle.StartSmokeEffect(hVehicle)
end

function DamageVehicle:OnExit()
  if self.eStreamEvent then
    Util.KillEvent(self.eStreamEvent)
    self.eStreamEvent = nil
  end
end
