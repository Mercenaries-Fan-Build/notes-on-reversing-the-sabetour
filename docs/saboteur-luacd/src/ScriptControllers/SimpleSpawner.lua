if not SimpleSpawner then
  SimpleSpawner = {}
end

function SimpleSpawner:OnEnter()
  self.bDebugMode = false
  self.sDebugLabel = "SIMPLESPAWNER"
  self.tSpawnBuffer = {}
  self.bIsWaitingForObjectToSpawn = false
end

function SimpleSpawner.SpawnBlueprint(a_vSpawner, a_sBlueprintName, a_fCallback, a_tCallbackParams)
  SimpleSpawner.SpawnBlueprintAdvanced(a_vSpawner, a_sBlueprintName, a_fCallback, a_tCallbackParams, nil)
end

function SimpleSpawner.SpawnBlueprintAdvanced(a_vSpawner, a_sBlueprintName, a_fCallback, a_tCallbackParams, a_tConfig)
  local hSpawner = Tips.CheckForHandle(a_vSpawner)
  local x, y, z = Object.GetPosition(hSpawner)
  local nRotation = Object.GetAngle(hSpawner)
  local tSpawnerSelf = Actor.GetSelf(hSpawner)
  local tSpawnCommand = {
    sBlueprintName = a_sBlueprintName,
    fCallback = a_fCallback,
    tCallbackParams = a_tCallbackParams,
    tConfig = a_tConfig
  }
  if #tSpawnerSelf.tSpawnBuffer ~= 0 then
    table.insert(tSpawnerSelf.tSpawnBuffer, tSpawnCommand)
    Tips.Print(tSpawnerSelf, "Added (" .. a_sBlueprintName .. ") to the spawn buffer.")
  else
    table.insert(tSpawnerSelf.tSpawnBuffer, tSpawnCommand)
    Tips.Print(tSpawnerSelf, "Added (" .. a_sBlueprintName .. ") to the spawn buffer. It is the first element.")
    if tSpawnerSelf.bIsWaitingForObjectToSpawn == false then
      SimpleSpawner.SpawnNextObject(tSpawnerSelf)
    end
  end
  Tips.Print(tSpawnerSelf, "There are now (" .. #tSpawnerSelf.tSpawnBuffer .. ") objects in the spawn buffer.")
end

function SimpleSpawner:SpawnNextObject()
  if self.tSpawnBuffer[1] ~= nil then
    local x, y, z = Object.GetPosition(self.hController)
    local nRotation = Object.GetAngle(self.hController)
    local tConfig = {}
    if self.tSpawnBuffer[1].tConfig ~= nil then
      Tips.Print(self, "User has submitted a custom table")
      tConfig = self.tSpawnBuffer[1].tConfig
    end
    tConfig.bIsSpawned = true
    tConfig.vSpawnLoc = {}
    tConfig.vSpawnLoc.x = x
    tConfig.vSpawnLoc.y = y
    tConfig.vSpawnLoc.z = z
    tConfig.State = cSTATE_HUNTING
    Tips.Print(self, "Spawning (" .. self.tSpawnBuffer[1].sBlueprintName .. ")")
    Object.Spawn(self.tSpawnBuffer[1].sBlueprintName, x, y, z, nRotation, tConfig, "SimpleSpawner._SpawnNextObject", self)
  else
    Tips.Print(self, "tSpawnBuffer is empty. Nothing else to spawn.")
  end
  self.bIsWaitingForObjectToSpawn = false
end

function SimpleSpawner:_SpawnNextObject(a_tSpawnInfo)
  local hCharacter = a_tSpawnInfo[1]
  local fSpawnCommandCallback = self.tSpawnBuffer[1].fCallback
  local tRefCallbackParams = self.tSpawnBuffer[1].tCallbackParams
  if tRefCallbackParams then
    local tSpawnCommandCallbackParams = {}
    for i, v in ipairs(tRefCallbackParams) do
      tSpawnCommandCallbackParams[i] = v
    end
  end
  Util.BroadcastFunction(self.hController, "OnSpawn", {hCharacter})
  if tSpawnCommandCallbackParams ~= nil then
    table.insert(tSpawnCommandCallbackParams, hCharacter)
  else
    tSpawnCommandCallbackParams = {}
    tSpawnCommandCallbackParams = {hCharacter}
  end
  if self.SMEDTable.lsPathNames ~= nil and #self.SMEDTable.lsPathNames > 0 then
    if self.SMEDTable.bRunPath == true then
      local sPath = self.SMEDTable.lsPathNames[math.random(#self.SMEDTable.lsPathNames)]
      Nav.SetScriptedPath(hCharacter, sPath, true, "SimpleSpawner.OnObjectFinishesSpawn", self, {fSpawnCommandCallback, tSpawnCommandCallbackParams})
      Nav.SetScriptedPathMoveMode(hCharacter, true)
      Tips.Print(self, "Path mode RUN (" .. sPath .. ")")
    else
      local sPath = self.SMEDTable.lsPathNames[math.random(#self.SMEDTable.lsPathNames)]
      Nav.SetScriptedPath(hCharacter, sPath, true, "SimpleSpawner.OnObjectFinishesSpawn", self, {fSpawnCommandCallback, tSpawnCommandCallbackParams})
      Nav.SetScriptedPathMoveMode(hCharacter, false)
      Tips.Print(self, "Path mode WALK (" .. sPath .. ")")
    end
  elseif fSpawnCommandCallback ~= nil then
    fSpawnCommandCallback(unpack(tSpawnCommandCallbackParams))
  end
  table.remove(self.tSpawnBuffer, 1)
  Tips.Print(self, "Remaining objects in spawn buffer: " .. #self.tSpawnBuffer)
  if 0 < self.SMEDTable.nSpawnDelay then
    self.eNextObjectTimer = Util.CreateEvent({
      EventType = "TimerEvent",
      Time = self.SMEDTable.nSpawnDelay
    }, "SimpleSpawner.SpawnNextObject", self)
    self.bIsWaitingForObjectToSpawn = true
  else
    SimpleSpawner.SpawnNextObject(self)
  end
end

function SimpleSpawner:OnObjectFinishesSpawn(a_fCallback, a_tCallbackParams)
  if a_fCallback then
    a_fCallback(unpack(a_tCallbackParams))
  end
end

function SimpleSpawner.FlushSpawnBuffer(a_vSimpleSpawner)
  if self.eNextObjectTimer ~= nil then
    Util.KillEvent(self.eNextObjectTimer)
  end
end

function SimpleSpawner:OnSpawn(a_hSpawnedCharacter)
end

function SimpleSpawner:OnExit()
end
