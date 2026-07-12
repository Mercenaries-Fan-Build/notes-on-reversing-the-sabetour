if not Soldier then
  Soldier = {}
end

function Soldier:ConfigureState_Enter()
  Soldier.PrintToConsole(self, "Entering CONFIGURE state.")
  if self.SMEDTable.sDefaultMachineGun ~= nil and self.SMEDTable.sDefaultMachineGun ~= "NONE" then
    Util.CreateEvent({
      EventType = "StreamEvent",
      Objects = {
        Util.GetNameFromHandle(self.hController),
        self.SMEDTable.sDefaultMachineGun
      },
      WaitForGameObject = true
    }, "Soldier.ConfigureState_OnStreamEvent", self)
    Soldier.PrintToConsole(self, "Waiting for soldier and (" .. self.SMEDTable.sDefaultMachineGun .. ") to spawn in")
  else
    Util.CreateEvent({
      EventType = "StreamEvent",
      Objects = {
        Util.GetNameFromHandle(self.hController)
      },
      WaitForGameObject = true
    }, "Soldier.ConfigureState_OnStreamEvent", self)
    Soldier.PrintToConsole(self, "Waiting for soldier to spawn in")
  end
end

function Soldier:ConfigureState_OnStreamEvent()
  Soldier.PrintToConsole(self, "Soldier has successfully spawned in")
  self.SMEDTable.nPatrolMoveType = cPATHTYPE_LOOP
  if self.SMEDTable.sPatrolType == "LOOP" then
    self.SMEDTable.nPatrolMoveType = cPATHTYPE_LOOP
  elseif self.SMEDTable.sPatrolType == "BOUNCE" then
    self.SMEDTable.nPatrolMoveType = cPATHTYPE_BOUNCE
  elseif self.SMEDTable.sPatrolType == "RANDOM" then
    self.SMEDTable.nPatrolMoveType = cPATHTYPE_RANDOM
  elseif self.SMEDTable.sPatrolType == "ONCE" then
    self.SMEDTable.nPatrolMoveType = cPATHTYPE_ONCE
  elseif self.SMEDTable.sPatrolType == "None" then
    self.SMEDTable.nPatrolMoveType = cPATHTYPE_ONCE
  else
    Util.Assert(false, "You've entered a bad patrol type for " .. Util.GetNameFromHandle(self.hController) .. " : Defaulting to LOOP")
  end
  self.bDefaultPathTriggered = false
  if self.SMEDTable.sPathConditions == "None" or self.SMEDTable.sPathConditions == "OnSpawn" then
  elseif self.SMEDTable.sPathConditions == "PlayerProximity" then
    self.ePathStart = Util.CreateEvent({
      EventType = "ProximityEvent",
      Proximity = self.SMEDTable.sPathCondValue,
      ObjectA = self.hController,
      ObjectB = Util.GetHandleByName("Saboteur")
    }, "Soldier.WalkDefaultPath", self)
  elseif self.SMEDTable.sPathConditions == "PlayerCrossesTrigger" then
    self.ePathStart = Util.CreateEvent({
      EventType = "OnTriggerEnter",
      Target = Util.GetHandleByName(self.SMEDTable.sPathCondValue)
    }, "Soldier.OnDefaultPathTriggerEntered", self, {0})
  end
  local nStartingX, nStartingY, nStartingZ = Object.GetPosition(self.hController)
  self.vOriginalPos = {}
  self.vOriginalPos.x = nStartingX
  self.vOriginalPos.y = nStartingY
  self.vOriginalPos.z = nStartingZ
  self.nOriginalFacingDir = Actor.GetFacingDir(self.hController)
  self.nLastSpeakTime = 0
  if self.SMEDTable.TetherRadius and 0 < self.SMEDTable.TetherRadius then
    Combat.SetTether(self.hController, nStartingX, nStartingY, nStartingZ, self.SMEDTable.TetherRadius)
  end
  Squad.Create("GenericNazi")
  Squad.AddMember("GenericNazi", self.hController)
  Util.Assert(nStartingX ~= nil and nStartingY ~= nil and nStartingZ ~= nil, "LUA: Why is this soldier's position nil if this is called after a stream event?")
  if self.bIsReinforcement then
    Soldier.EnterState(self, cSTATE_IDLE)
  else
    Soldier.EnterState(self, cSTATE_IDLE)
  end
end

function Soldier:ConfigureState_Exit()
  Soldier.PrintToConsole(self, "Exiting CONFIGURE state.")
end
