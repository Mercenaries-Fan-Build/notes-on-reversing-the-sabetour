if not CinematicSpawner then
  CinematicSpawner = {}
end

function CinematicSpawner:OnEnter()
  self.bDebugMode = false
  self.sDebugLabel = "CinematicSpawner"
  self.bPlayerInVehicle = false
  self.bDoNotRespawn = false
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {"Saboteur"},
    WaitForGameObject = true
  }
  self.eSabStream = Util.CreateEvent(tStreamEvent, "CinematicSpawner.CreateEnterRadiusEvent", self)
end

function CinematicSpawner:CreateEnterRadiusEvent()
  self.eSabStream = nil
  local bCheck3D = false
  if self.eEnterRadius then
    return
  end
  local bSabInVeh = Actor.IsInVehicle(hSab)
  if self.SMEDTable.bIsTopSpot or self.SMEDTable.sTarget ~= "NONE" and bSabInVeh then
    bCheck3D = true
  end
  local tEvent = {
    EventType = "ProximityEvent",
    ObjectA = self.hController,
    ObjectB = Handle("Saboteur"),
    Proximity = self.SMEDTable.nSpawnDistance,
    Check3D = bCheck3D
  }
  self.eEnterRadius = Util.CreateEvent(tEvent, "CinematicSpawner.OnPlayerEntersRadius", self)
end

function CinematicSpawner:OnPlayerEntersRadius()
  Tips.Print(self, "OnPlayerEntersRadius()")
  local bRaceSkip = false
  if IsMissionActive("Act_1_Race") and Act_1_Race.bOver == true then
    bRaceSkip = true
  end
  self.eEnterRadius = nil
  CinematicSpawner.CreateExitRadiusEvent(self)
  CinematicSpawner.hController = self.hController
  if self.SMEDTable.sCinematic and self.SMEDTable.sCinematic ~= string.upper("NONE") then
    local bSabInVeh = Actor.IsInVehicle(hSab)
    local hVeh, nNumWheelsOnGround, nSpeed
    if bSabInVeh then
      hVeh = Actor.GetVehicle(hSab)
      nNumWheelsOnGround = Vehicle.GetNumWheelsOnGround(hVeh)
      nSpeed = Vehicle.GetSpeed(hVeh)
    end
    if not (self.SMEDTable.sTarget ~= "NONE" and self.SMEDTable.sTarget) or self.SMEDTable.bIsTopSpot or self.SMEDTable.sTarget ~= "NONE" and bSabInVeh then
      if bSabInVeh and (not nNumWheelsOnGround or nNumWheelsOnGround ~= 0 or nSpeed < 25 or bRaceSkip == true) then
        CinematicSpawner.CreateEnterRadiusEvent(self)
        return
      end
      Cin.PlayCinematic(self.SMEDTable.sCinematic, self.SMEDTable.bLoopCinematic)
      if self.SMEDTable.sTarget ~= "NONE" then
        self.bDoNotRespawn = true
      end
    else
      CinematicSpawner.CreateEnterRadiusEvent(self)
    end
  end
end

function CinematicSpawner:CreateExitRadiusEvent()
  if self.eExitRadius then
    return
  end
  Tips.Print(self, "Creating negated proximity event at " .. self.SMEDTable.nDespawnDistance .. " meters.")
  local tEvent = {
    EventType = "ProximityEvent",
    ObjectA = self.hController,
    ObjectB = Handle("Saboteur"),
    Proximity = self.SMEDTable.nDespawnDistance,
    Negate = true
  }
  self.eExitRadius = Util.CreateEvent(tEvent, "CinematicSpawner.OnPlayerExitsRadius", self)
end

function CinematicSpawner:OnPlayerExitsRadius()
  Tips.Print(self, "OnPlayerExitsRadius()")
  self.eExitRadius = nil
  if self.bDoNotRespawn == false then
    CinematicSpawner.CreateEnterRadiusEvent(self)
  end
  Cin.StopCinematic(self.SMEDTable.sCinematic, self.SMEDTable.bImmediateDespawn)
end

function CinematicSpawner:OnStream()
end

function CinematicSpawner.StuntJumpSlow()
  local self = Actor.GetSelf(CinematicSpawner.hController)
  if Actor.IsInVehicle(hSab) then
    Sound.PlayOwnerlessSoundEvent("SweetJumpStart")
    Util.SetTimeScale(0.185)
    self.bPlayerInVehicle = true
  end
end

function CinematicSpawner.StuntJumpReturn()
  local self = Actor.GetSelf(CinematicSpawner.hController)
  if self.bPlayerInVehicle == true then
    Sound.PlayOwnerlessSoundEvent("SweetJumpStop")
    Util.SetTimeScale(1)
  end
end

function CinematicSpawner.StuntJumpKill()
  local self = Actor.GetSelf(CinematicSpawner.hController)
  if self.bPlayerInVehicle == true then
    self.bPlayerInVehicle = false
    local tTimerEvent = {EventType = "TimerEvent", Time = 0.25}
    Util.CreateEvent(tTimerEvent, "CinematicSpawner.KillJumpTarget", self)
  end
end

function CinematicSpawner.SpotTrigger()
  local self = Actor.GetSelf(CinematicSpawner.hController)
  local tTimerEvent = {EventType = "TimerEvent", Time = 0.25}
  Util.CreateEvent(tTimerEvent, "CinematicSpawner.KillJumpTarget", self)
end

function CinematicSpawner:KillJumpTarget()
  Object.Kill(Handle(self.SMEDTable.sTarget))
end

function CinematicSpawner:OnExit()
  if self.eExitRadius then
    Util.KillEvent(self.eExitRadius)
    self.eExitRadius = nil
  end
  if self.eEnterRadius then
    Util.KillEvent(self.eEnterRadius)
    self.eEnterRadius = nil
  end
  if self.eSabStream then
    Util.KillEvent(self.eSabStream)
    self.eSabSteam = nil
  end
end
