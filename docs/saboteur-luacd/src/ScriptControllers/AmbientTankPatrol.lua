if not AmbientTankPatrol then
  AmbientTankPatrol = {}
end

function AmbientTankPatrol:OnEnter()
  self.bDebugMode = false
  self.sDebugLabel = "AmbTankPatrol"
  dprint(self, "OnEnter")
  self.tEvents = {}
  self.sTank = self.SMEDTable.sTankPath
  self.sScriptedPath = self.SMEDTable.sScriptedPath
  self.nPatrolSpeed = self.SMEDTable.nPatrolSpeed
  self.bRandomizeSpeed = self.SMEDTable.bRandomizeSpeed
  self.nRandomMin = self.SMEDTable.nRandomMin
  self.nRandomMax = self.SMEDTable.nRandomMax
  local tPackedData = {
    self.sScriptedPath,
    self.nPatrolSpeed,
    self.bRandomizeSpeed,
    self.nRandomMin,
    self.nRandomMax
  }
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      self.sTank
    },
    WaitForGameObject = true
  }
  Util.CreateEvent(tStreamEvent, "AmbientTankPatrol.OnTankStreams", nil, {
    self.sTank,
    tPackedData
  })
end

function AmbientTankPatrol:OnTankStreams(a_vTank, a_tPackedData)
  local hTank = Handle(a_vTank)
  local hPilot = Vehicle.GetPilot(hTank)
  local bSpawned = true
  table.insert(a_tPackedData, hTank)
  Suspicion.SetupSuspicionRadius(hTank, 25)
  if not hPilot then
    Object.SpawnInVehicle("Human_WM_Rifleman_RF", "PILOT", hTank, "AmbientTankPatrol.OnPilotSpawned", nil, {a_tPackedData})
    bSpawned = false
  end
  if bSpawned == false then
    return
  end
  table.insert(a_tPackedData, hPilot)
  AmbientTankPatrol.SetupCallbacks(a_tPackedData)
  AmbientTankPatrol.DoMovement(a_tPackedData)
end

function AmbientTankPatrol:OnPilotSpawned(a_tCallbackData, a_tPackedData)
  local hPilot = a_tCallbackData[1]
  table.insert(a_tPackedData, hPilot)
  AmbientTankPatrol.SetupCallbacks(a_tPackedData)
  AmbientTankPatrol.DoMovement(a_tPackedData)
end

function AmbientTankPatrol.SetupCallbacks(a_tPackedData)
  local hTank = a_tPackedData[6]
  local hPilot = a_tPackedData[7]
  local tCombatEnter = {
    EventType = "OnCombatEnter",
    Target = hPilot
  }
  Util.CreateEvent(tCombatEnter, "AmbientTankPatrol.TankEnteredCombat", nil, {a_tPackedData})
  Vehicle.SetDeathCallback(hTank, "AmbientTankPatrol.TankDied", nil, {a_tPackedData})
end

function AmbientTankPatrol.DoMovement(a_tPackedData)
  local sScriptedPath = a_tPackedData[1]
  local nPatrolSpeed = a_tPackedData[2]
  local bRandomizeSpeed = a_tPackedData[3]
  local nRandomMin = a_tPackedData[4]
  local nRandomMax = a_tPackedData[5]
  local hTank = a_tPackedData[6]
  local hPilot = a_tPackedData[7]
  local nRandSpeed
  if #a_tPackedData < 8 or #a_tPackedData == 8 and a_tPackedData[8] == nil then
    nRandSpeed = math.random(nRandomMin, nRandomMax)
    table.insert(a_tPackedData, nRandSpeed)
  else
    nRandSpeed = a_tPackedData[8]
  end
  Nav.SetScriptedPath(hTank, sScriptedPath, true, "AmbientTankPatrol.OnTankFinishedPath", nil, {a_tPackedData})
  if bRandomizeSpeed then
    Nav.SetScriptedPathSpeed(hTank, nRandSpeed)
  else
    Nav.SetScriptedPathSpeed(hTank, nPatrolSpeed)
  end
  return a_tPackedData
end

function AmbientTankPatrol:OnTankFinishedPath(a_tPackedData)
  local nRandomizeSpeed = a_tPackedData[3]
  if bRandomizeSpeed then
    a_tPackedData[8] = nil
  end
  AmbientTankPatrol.DoMovement(a_tPackedData)
end

function AmbientTankPatrol:TankEnteredCombat(a_tCallbackData, a_tPackedData)
  local hTank = a_tPackedData[6]
  local hPilot = a_tPackedData[7]
  Nav.CancelScriptedPath(hTank)
  local tCombatExit = {
    EventType = "OnCombatExit",
    Target = hPilot
  }
  Util.CreateEvent(tCombatExit, "AmbientTankPatrol.TankExitedCombat", nil, {a_tPackedData})
end

function AmbientTankPatrol:TankExitedCombat(a_tCallbackData, a_tPackedData)
  local hTank = a_tPackedData[6]
  local hPilot = a_tPackedData[7]
  if #a_tPackedData < 8 then
    a_tPackedData = AmbientTankPatrol.DoMovement(a_tPackedData)
  else
    AmbientTankPatrol.DoMovement(a_tPackedData)
  end
  local tCombatEnter = {
    EventType = "OnCombatEnter",
    Target = hPilot
  }
  Util.CreateEvent(tCombatEnter, "AmbientTankPatrol.TankEnteredCombat", nil, {a_tPackedData})
end

function AmbientTankPatrol:TankDied(a_tPackedData)
  AmbientTankPatrol.DoKillEvents(a_tPackedData)
end

function AmbientTankPatrol.DoKillEvents(a_tPackedData)
  local hTank = a_tPackedData[6]
  local hPilot = a_tPackedData[7]
  Util.KillAllEvents(hTank)
  Util.KillAllEvents(hPilot)
end

function AmbientTankPatrol:OnExit()
end
