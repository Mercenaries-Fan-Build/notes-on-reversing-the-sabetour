KissingGirl = KissingGirl or {}

function KissingGirl:OnEnter()
  Actor.SetPanicFleeingEnabled(self.hController, false)
  Actor.EnableNeeds(self.hController, false)
end

function KissingGirl:OnExit()
end
