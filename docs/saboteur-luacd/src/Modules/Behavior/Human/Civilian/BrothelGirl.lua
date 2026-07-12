BrothelGirl = BrothelGirl or {}

function BrothelGirl:OnEnter()
  Actor.SetPanicEnabled(self.hController, false)
  Actor.EnableNeeds(self.hController, false)
  Actor.SetNonKnockdownable(self.hController, true)
  Actor.SetReactorEnabled(self.hController, false)
  Object.SetInvincible(self.hController, true)
end

function BrothelGirl:OnExit()
end
