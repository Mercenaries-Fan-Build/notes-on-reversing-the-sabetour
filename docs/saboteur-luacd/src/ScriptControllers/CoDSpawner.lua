CoDSpawner = CoDSpawner or {}
Spawner = Spawner or {}
setmetatable(CoDSpawner, {__index = Spawner})

function CoDSpawner:OnEnter()
  Object.EnableSpawner(self.hController, false)
  self.m_tEvents = {}
  self.m_tWaitFors = {}
  local tTriggers = {}
  if self.SMEDTable.sOnRegion then
    table.insert(tTriggers, self.SMEDTable.sOnRegion)
  end
  if self.SMEDTable.sOffRegion then
    table.insert(tTriggers, self.SMEDTable.sOffRegion)
  end
  if 0 < #tTriggers then
    local e = {
      EventType = "StreamEvent",
      Objects = tTriggers
    }
    self.m_tEvents.m_eTrigStream = Util.CreateEvent(e, "CoDSpawner.OnTriggersStreamedIn", self)
  end
end

function CoDSpawner:OnTriggersStreamedIn()
  CoDSpawner.ClearEvent(self, "m_eTrigStream")
  CoDSpawner.SetUpOnTrigEvent(self)
  CoDSpawner.SetUpOffTrigEvent(self)
end

function CoDSpawner:SetUpOnTrigEvent()
  if self.SMEDTable.sOnRegion then
    local hTrigger = Util.GetHandleByName(self.SMEDTable.sOnRegion)
    if not hTrigger then
      return
    end
    self.m_tWaitFors.m_eOnTrigEntered = {
      hTrigger,
      Trigger.WaitFor(hTrigger, hSab, "CoDSpawner.OnOnTriggerEntered", self, nil, cTRIGGEREVENT_ONENTER_SMART)
    }
  end
end

function CoDSpawner:SetUpOffTrigEvent()
  if self.SMEDTable.sOffRegion then
    local hTrigger = Util.GetHandleByName(self.SMEDTable.sOffRegion)
    if not hTrigger then
      return
    end
    self.m_tWaitFors.m_eOffTrigEntered = {
      hTrigger,
      Trigger.WaitFor(hTrigger, hSab, "CoDSpawner.OnOffTriggerEntered", self, nil, cTRIGGEREVENT_ONENTER_SMART)
    }
  end
end

function CoDSpawner:OnOnTriggerEntered(a_tArgs)
  CoDSpawner.ClearWaitFor(self, "m_eOnTrigEntered")
  if self.SMEDTable.bOnlyEscalation and Suspicion.GetEscalation() == 0 then
    return
  end
  if self.SMEDTable.fActivationDelay and 0 < self.SMEDTable.fActivationDelay then
    local e = {
      EventType = "TimerEvent",
      Time = self.SMEDTable.fActivationDelay
    }
    self.m_tEvents.m_eDelayedActivation = Util.CreateEvent(e, "CoDSpawner.ActivateSpawner", self)
    return
  end
  CoDSpawner.ActivateSpawner(self)
end

function CoDSpawner:OnOffTriggerEntered(a_tArgs)
  CoDSpawner.ClearWaitFor(self, "m_eOffTrigEntered")
  CoDSpawner.KillWaitFor(self, "m_eOnTrigEntered")
  CoDSpawner.KillEvent(self, "m_eDelayedActivation")
  Object.EnableSpawner(self.hController, false)
end

function CoDSpawner:ActivateSpawner()
  Object.EnableSpawner(self.hController, true)
  CoDSpawner.ClearEvent(self, "m_eDelayedActivation")
end

function CoDSpawner:OnSpawn(a_hSpawned)
  CoDSpawner.OpenDoor(self)
  Combat.SetReactImmediately(a_hSpawned, true)
  local nLocators = #self.SMEDTable.tLocators
  if 0 < nLocators then
    local hLocator = CoDSpawner.GetRandomLocator(self)
    if hLocator then
      Combat.SetObjective(a_hSpawned, hLocator, self.SMEDTable.bForceMove or false, self.SMEDTable.fTetherRadius, self.SMEDTable.bUseAttrPt)
    end
    if Suspicion.IsEscalated() or Suspicion.IsEscalatedLite() then
      Combat.SetHunt(a_hSpawned, hLocator, self.SMEDTable.bForceRun or false, false)
    end
  else
    local nPaths = #self.SMEDTable.tPaths
    if 0 < nPaths then
      local hPath = CoDSpawner.GetRandomPath(self)
      Combat.SetObjectivePath(a_hSpawned, Util.GetCRC(hPath), self.SMEDTable.bForceMove or false, self.SMEDTable.fTetherRadius)
    end
    if Suspicion.IsEscalated() or Suspicion.IsEscalatedLite() then
      Combat.SetHunt(a_hSpawned, nil, self.SMEDTable.bForceRun or false, false)
    end
  end
end

function CoDSpawner:InitRandomLocatorTable()
  self.m_tRandomLocatorIndices = {}
  local nLocators = #self.SMEDTable.tLocators
  for i = 1, nLocators do
    table.insert(self.m_tRandomLocatorIndices, i)
  end
end

function CoDSpawner:GetRandomLocator()
  if not self.m_tRandomLocatorIndices or #self.m_tRandomLocatorIndices == 0 then
    CoDSpawner.InitRandomLocatorTable(self)
  end
  local hLocator
  while not hLocator do
    local nLocatorsLeft = #self.m_tRandomLocatorIndices
    if nLocatorsLeft == 0 then
      return nil
    end
    local iRandLocator = math.random(nLocatorsLeft)
    hLocator = Util.GetHandleByName(self.SMEDTable.tLocators[self.m_tRandomLocatorIndices[iRandLocator]])
    table.remove(self.m_tRandomLocatorIndices, iRandLocator)
  end
  return hLocator
end

function CoDSpawner:InitRandomPathTable()
  self.m_tRandomPathIndices = {}
  local nPaths = #self.SMEDTable.tPaths
  for i = 1, nPaths do
    table.insert(self.m_tRandomPathIndices, i)
  end
end

function CoDSpawner:GetRandomPath()
  if not self.m_tRandomPathIndices or #self.m_tRandomPathIndices == 0 then
    CoDSpawner.InitRandomPathTable(self)
  end
  local szPath
  while not szPath do
    local nPathsLeft = #self.m_tRandomPathIndices
    if nPathsLeft == 0 then
      return nil
    end
    local iRandPath = math.random(nPathsLeft)
    szPath = self.SMEDTable.tPaths[self.m_tRandomPathIndices[iRandPath]]
    table.remove(self.m_tRandomPathIndices, iRandPath)
  end
  return szPath
end

function CoDSpawner:OpenDoor()
  if not self.SMEDTable.sSpawnDoor then
    return
  end
  local hDoor = Util.GetHandleByName(self.SMEDTable.sSpawnDoor)
  if not hDoor then
    return
  end
  Object.ForceOpen(hDoor)
end

function CoDSpawner:ClearEvent(a_szEvent)
  self.m_tEvents[a_szEvent] = nil
end

function CoDSpawner:ClearWaitFor(a_szEvent)
  self.m_tWaitFors[a_szEvent] = nil
end

function CoDSpawner:KillEvent(a_szEvent)
  if self.m_tEvents[a_szEvent] then
    Util.KillEvent(self.m_tEvents[a_szEvent])
    self.m_tEvents[a_szEvent] = nil
  end
end

function CoDSpawner:KillWaitFor(a_szEvent)
  local tWaitFor = self.m_tWaitFors[a_szEvent]
  if tWaitFor then
    Trigger.ClearCallback(tWaitFor[1], tWaitFor[2])
    self.m_tWaitFors[a_szEvent] = nil
  end
end

function CoDSpawner:OnExit()
  for e, h in pairs(self.m_tEvents) do
    Util.KillEvent(h)
  end
  for e, h in pairs(self.m_tWaitFors) do
    if Util.IsHandleValid(h[1]) then
      Trigger.ClearCallback(h[1], h[2])
    end
  end
end
