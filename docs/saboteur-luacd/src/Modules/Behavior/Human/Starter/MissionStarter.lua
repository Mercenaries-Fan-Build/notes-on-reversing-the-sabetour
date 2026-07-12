if not MissionStarter then
  MissionStarter = {}
end
MissionStarter.nGreetRange = 8
MissionStarter.nExitRange = 10
MissionStarter.nFollowRadius = 1.25
MissionStarter.bGreetWave = true

function MissionStarter:OnEnter()
  self.bDebugMode = false
  self.sDebugLabel = "STARTER"
  if Combat.IsCombatant(self.hController) then
    Suspicion.Enable(self.hController, false)
    Combat.SetRespondToSound(self.hController, false)
    Combat.SetRespondToDeadBodies(self.hController, false)
    Combat.SetRespondToDamage(self.hController, false)
    Combat.SetRespondToEvents(self.hController, false)
    Combat.SetSquadAssist(self.hController, false)
    Combat.SetIdleUseNeeds(self.hController, false)
  end
  Actor.SetPanicEnabled(self.hController, false)
  local _x, _y, _z = Actor.GetPosition(self.hController)
  self.Pos = {
    x = _x,
    y = _y,
    z = _z
  }
  self.nRot = Actor.GetFacingDir(self.hController)
end

function MissionStarter:SetupGreetProximityEvent()
  if not self then
    return
  end
  Tips.Print(self, "Setting up greet proximity event...")
  local tEvent = {
    EventType = "ProximityEvent",
    PosX = self.Pos.x,
    PosY = self.Pos.y,
    PosZ = self.Pos.z,
    Proximity = MissionStarter.nGreetRange,
    ObjectA = Util.GetHandleByName("Saboteur")
  }
  self.eEnterProximity = Util.CreateEvent(tEvent, "MissionStarter.OnPlayerEntersProximity", self)
end

function MissionStarter:OnPlayerEntersProximity()
  if not self then
    return
  end
  Tips.Print(self, "OnPlayerEntersProximity()")
  if Suspicion.GetEscalation() == 0 then
    ScriptSequence.Kill(self.hController)
    if MissionStarter.bGreetWave == true then
      local tSequence = {
        {
          "TURNTOFACE",
          {"Saboteur"}
        },
        {
          "DELAY",
          {0.5}
        },
        {
          "PLAYANIMATION",
          {"Civ_Greet"}
        },
        {
          "DELAY",
          {1}
        }
      }
      ScriptSequence.Run(self.hController, tSequence, MissionStarter.FollowPlayer, {self})
      MissionStarter.SetupExitProximityEvent(self)
    else
      MissionStarter.SetupExitProximityEvent(self)
      MissionStarter.FollowPlayer(self)
    end
  else
    Tips.Print(self, "Escalation is too high. Starter will not greet player.")
    MissionStarter.SetupEscalationEvent(self)
  end
end

function MissionStarter:SetupEscalationEvent()
  if not self then
    return
  end
  local tEvent = {
    EventType = "OnEscalation0",
    Target = Util.GetHandleByName("Saboteur")
  }
  Util.CreateEvent(tEvent, "MissionStarter.SetupGreetProximityEvent", self)
end

function MissionStarter:SetupExitProximityEvent()
  if not self then
    return
  end
  Tips.Print(self, "Setting up exit proximity event...")
  local tEvent = {
    EventType = "ProximityEvent",
    PosX = self.Pos.x,
    PosY = self.Pos.y,
    PosZ = self.Pos.z,
    Proximity = MissionStarter.nExitRange,
    Negate = true,
    ObjectA = Util.GetHandleByName("Saboteur")
  }
  self.eExitProximity = Util.CreateEvent(tEvent, "MissionStarter.OnPlayerExitsProximity", self)
end

function MissionStarter:OnPlayerExitsProximity()
  if not self then
    return
  end
  Tips.Print(self, "OnPlayerExitsProximity()")
  MissionStarter.CancelFollow(self)
  Nav.StopMoving(self.hController)
  MissionStarter.ReturnToPos(self)
  MissionStarter.SetupGreetProximityEvent(self)
end

function MissionStarter:FollowPlayer()
  Tips.Print(self, "MissionStarter is now following the player")
end

function MissionStarter:CancelFollow()
  if not self then
    return
  end
  Nav.CancelFollowObject(self.hController)
end

function MissionStarter:ReturnToPos()
  if not self or not self.Pos then
    return
  end
  local tSequence = {
    {
      "WALKTOPOINT",
      {
        self.Pos.x,
        self.Pos.y,
        self.Pos.z
      }
    },
    {
      "SETFACING",
      {
        self.nRot
      }
    }
  }
  ScriptSequence.Run(self.hController, tSequence)
end

function MissionStarter:OnExit()
  if not self then
    return
  end
  if self.eEnterProximity then
    Util.KillEvent(self.eEnterProximity)
  end
  if self.eExitProximity then
    Util.KillEvent(self.eExitProximity)
  end
end
