if not IdleCiv then
  IdleCiv = {}
end

function IdleCiv:OnEnter()
  Actor.EnableSchedule(self.hController, true)
end

function IdleCiv:OnFirstEnemy()
end

function IdleCiv:OnLastEnemy()
end

function IdleCiv:OnExit()
end
