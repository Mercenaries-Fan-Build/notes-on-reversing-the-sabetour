if not PantheonGun then
  PantheonGun = {}
end

function PantheonGun:OnEnter()
  self.hSab = Handle("Saboteur")
  self.bDebugMode = false
  self.sDebugLabel = "PantheonGun"
  PantheonGun.SetupStreamEvent(self)
end

function PantheonGun:SetupStreamEvent()
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      self.SMEDTable.sTarget
    },
    WaitForGameObject = true
  }
  self.eStreamEvent = Util.CreateEvent(tStreamEvent, "PantheonGun.OnStream", self)
end

function PantheonGun:OnStream()
  self.hTarget = self.hTarget or Handle(self.SMEDTable.sTarget)
  if self.hTarget and Object.IsAlive(self.hTarget) then
    if P3FP_BiggerGun then
      if not P3FP_BiggerGun.bDestroyed then
        Object.SetInvincible(self.hTarget, true)
      end
    else
      Object.SetInvincible(self.hTarget, true)
    end
  end
end

function PantheonGun:OnExit()
  if self.eStreamEvent then
    Util.KillEvent(self.eStreamEvent)
    self.eStreamEvent = nil
  end
  if self.eTimerEvent then
    Util.KillEvent(self.eTimerEvent)
    self.eTimerEvent = nil
  end
end
