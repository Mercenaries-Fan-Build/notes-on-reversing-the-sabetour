if not AggroSpawner then
  AggroSpawner = {}
  AggroSpawner.Spawners = {}
end
if AggroSpawner == nil then
  AggroSpawner = {}
end

function AggroSpawner.Create(o)
  self = {}
  setmetatable(self, {__index = o})
  self.tConfig = {}
  local returnself = self
  self = nil
  return returnself
end

function AggroSpawner:CreateSpawner(v_tConfig)
  local tConfig, hSpawner
  local tInstanceTable = {}
  if type(v_tConfig) == "table" then
    tConfig = v_tConfig
  else
    hSpawner = WRAPPER_CheckForHandleNil(v_tConfig)
    if not hSpawner then
      print("ERROR CreateSpawnerSMED:: cant get handle to sSpawner ", sSpawner)
      return
    end
    tInstanceTable = Actor.GetSelf(hSpawner)
    tConfig = tInstanceTable.SMEDTable
    tConfig.sSpawnerName = v_tConfig
  end
  local oSpawner = AggroSpawner:Create()
  for key, value in pairs(tConfig) do
    oSpawner.tConfig[key] = value
  end
  oSpawner.tConfig.tSpawnHandles = {}
  AggroSpawner.Spawners[tConfig.sSpawnerName] = oSpawner
  if oSpawner.tConfig.tLocators then
    oSpawner._NumberLocators = #oSpawner.tConfig.tLocators
    oSpawner._CurrentLocatorIndex = 1
  end
  oSpawner:_SetupCallbacks()
  return oSpawner
end

function AggroSpawner:_SetupCallbacks()
  local tConfig = self.tConfig
  if tConfig.sOnRegion then
    self._eOnEvent = EVENT_PlayerEntersTrigger("AggroSpawner._StartSpawner", nil, tConfig.sOnRegion, false, tConfig.sSpawnerName)
  end
  if tConfig.sOffRegion then
    if type(tConfig.sOffRegion) == "table" then
      for _, sRegion in pairs(tConfig.sOffRegion) do
        self._eOffEvent = EVENT_PlayerEntersTrigger("AggroSpawner._StopSpawner", nil, sRegion, false, tConfig.sSpawnerName)
      end
    else
      self._eOffEvent = EVENT_PlayerEntersTrigger("AggroSpawner._StopSpawner", nil, tConfig.sOffRegion, false, tConfig.sSpawnerName)
    end
  end
end

function AggroSpawner:_StartSpawner(tArgs, sSelfName)
  local self = AggroSpawner.Spawners[sSelfName]
  local tConfig = self.tConfig
  local hSpawner = WRAPPER_CheckForHandleNil(tConfig.sSpawnerName)
  if hSpawner then
    self._eSpawnerEvent = Util.CreateEvent({EventType = "OnSpawn", Target = hSpawner}, "AggroSpawner._CallbackSpawned", nil, {
      tConfig.sSpawnerName
    }, true)
    Object.EnableSpawner(hSpawner, true)
    if tConfig.sSpawnDoor then
      local hDoor = Util.GetHandleByName(tConfig.sSpawnDoor)
      if hDoor and not Object.IsDoorOpen(hDoor) then
        Object.ForceOpen(hDoor)
      end
    end
  end
end

function AggroSpawner:StartSpawner()
  local tConfig = self.tConfig
  local hSpawner = WRAPPER_CheckForHandleNil(tConfig.sSpawnerName)
  if hSpawner then
    self._eSpawnerEvent = Util.CreateEvent({EventType = "OnSpawn", Target = hSpawner}, "AggroSpawner._CallbackSpawned", nil, {
      tConfig.sSpawnerName
    }, true)
    if tConfig.sSpawnDoor then
      local hDoor = Util.GetHandleByName(tConfig.sSpawnDoor)
      if hDoor and not Object.IsDoorOpen(hDoor) then
        Object.ForceOpen(hDoor)
      end
    end
    Object.EnableSpawner(hSpawner, true)
  end
end

function AggroSpawner:_StopSpawner(tArgs, sSelfName)
  local this = AggroSpawner.Spawners[sSelfName]
  if this then
    local tConfig = this.tConfig
    local hSpawner = this:_GetHandle()
    if hSpawner then
      Object.EnableSpawner(hSpawner, false)
    end
  end
end

function AggroSpawner:StopSpawner()
  local tConfig = self.tConfig
  local hSpawner = self:_GetHandle()
  if hSpawner then
    Object.EnableSpawner(hSpawner, false)
  end
end

function AggroSpawner:QueueSpawner(blueprintname)
  local tConfig = self.tConfig
  local hSpawner = self:_GetHandle()
  self._eSpawnerEvent = Util.CreateEvent({EventType = "OnSpawn", Target = hSpawner}, "AggroSpawner._CallbackSpawned", nil, {
    tConfig.sSpawnerName
  })
  Object.SpawnerQueueSpawn(hSpawner, blueprintname)
end

function AggroSpawner:Delete()
  if not self then
    return
  end
  local tConfig = self.tConfig
  local sName = tConfig.sSpawnerName
  self:StopSpawner()
  if self._eOnEvent then
    Util.KillEvent(self._eOnEvent)
  end
  if self._eOffEvent then
    Util.KillEvent(self._eOffEvent)
  end
  if self._eSpawnerEvent then
    Util.KillEvent(self._eSpawnerEvent)
  end
  self:KillAllProxEvent(sName)
  if tConfig then
    for i, v in pairs(tConfig) do
      tConfig[i] = nil
    end
  end
  self._eProximityEvents = nil
  if AggroSpawner.Spawners and AggroSpawner.Spawners[sName] then
    AggroSpawner.Spawners[sName] = nil
  end
end

function AggroSpawner:Purge()
  if not self then
    return
  end
  local tConfig = self.tConfig
  self:StopSpawner()
  Object.SpawnerPurge(self:_GetHandle(), true)
end

function AggroSpawner:_GetHandle()
  local tConfig = self.tConfig
  local hSpawner = WRAPPER_CheckForHandleNil(tConfig.sSpawnerName)
  return hSpawner
end

function AggroSpawner:_CallbackSpawned(tUserData, sSelfName)
  local this = AggroSpawner.Spawners[sSelfName]
  local tConfig = this.tConfig
  this._eProximityEvents = {}
  local hLoc = Util.GetHandleByName(tConfig.tLocators[this._CurrentLocatorIndex])
  if not hLoc then
    print("ERROR: AggroSpawner:_CallbackSpawned: Did not get handle to locator", tConfig.tLocators[this._CurrentLocatorIndex])
  end
  this._CurrentLocatorIndex = this._CurrentLocatorIndex + 1
  if this._CurrentLocatorIndex > this._NumberLocators then
    this._CurrentLocatorIndex = 1
  end
  local hNazi = tUserData[2]
  if tConfig.sSpawnDoor then
    local hDoor = Util.GetHandleByName(tConfig.sSpawnDoor)
    if hDoor then
      Object.ForceOpen(hDoor)
    end
  end
  if hNazi and hLoc then
    table.insert(tConfig.tSpawnHandles, hNazi)
    Combat.SetHunt(hNazi, hLoc, true, false)
    if tConfig.fSpawnCallback then
      tConfig.fSpawnCallback(tConfig.tSelf, hNazi)
    end
    local tetherradius = tConfig.TetherRadius or -1
    if tConfig.bTether then
      tetherradius = tConfig.TetherRadius or self.SMEDTable.fTetherRadius or 5
    end
    Combat.SetObjective(hNazi, hLoc, true, tetherradius, false)
  end
end

function AggroSpawner:ReachedLoc(hNazi, hLoc, sSelfName, bOverride)
  local this = AggroSpawner.Spawners[sSelfName]
  local tConfig = this.tConfig
  if bOverride then
  end
  if hNazi and hLoc and Actor.IsAlive(hNazi) then
    if Object.GetDistance(hNazi, hLoc) > 3 and not bOverride then
      Nav.MoveToObject(hNazi, hLoc, 2, true, "AggroSpawner.ReachedLoc", nil, {
        hNazi,
        hLoc,
        sSelfName
      })
    else
      if this._eProximityEvents then
        AggroSpawner:KillProxEvent(hNazi, sSelfName)
      end
      if tConfig.bSuperSoldier then
        Combat.SetIdleHoldWeapon(hNazi, true)
        Combat.SetReactImmediately(hNazi, true)
        Combat.AlwaysSeeTarget(hNazi, true)
      end
      Combat.SetCombat(hNazi)
      Combat.SetTarget(hNazi, hSab)
    end
  elseif hNazi and this._eProximityEvents then
    AggroSpawner:KillProxEvent(hNazi, sSelfName)
  end
end

function AggroSpawner:KillProxEvent(hThisNazi, sSelfName)
  local this = AggroSpawner.Spawners[sSelfName]
  local tableindex = -1
  if this and this._eProximityEvents then
    for i, tEvent in pairs(this._eProximityEvents) do
      if tEvent.MyHandle == hThisNazi then
        Util.KillEvent(this._eProximityEvents[i].EventID)
      end
      tableindex = i
      break
    end
  end
  if 0 < tableindex then
    table.remove(this._eProximityEvents, i)
  end
end

function AggroSpawner:KillAllProxEvent(sSelfName)
  local this = AggroSpawner.Spawners[sSelfName]
  if this and this._eProximityEvents then
    for i, tEvent in pairs(this._eProximityEvents) do
      Util.KillEvent(this._eProximityEvents[i].EventID)
    end
  end
end
