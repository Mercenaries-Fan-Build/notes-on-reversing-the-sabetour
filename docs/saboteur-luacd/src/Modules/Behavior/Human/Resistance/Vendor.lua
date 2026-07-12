MissionStarter = MissionStarter or {}
Vendor = Vendor or {}
setmetatable(Vendor, {__index = MissionStarter})

function Vendor:OnEnter()
  MissionStarter.OnEnter(self)
  self.bDebugMode = false
  self.sDebugLabel = "VENDOR"
end

function Vendor:OnActorUsed()
  Util.Pause(true)
end

function Vendor:OnExit()
end
