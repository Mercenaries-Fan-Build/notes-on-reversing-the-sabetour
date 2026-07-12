if not HumanSpawner then
  HumanSpawner = {}
end

function HumanSpawner:OnEnter()
  self.t_AllEvents = {}
  self.t_TriggerEvents = {}
  self.bDisabled = false
  table.insert(self.t_AllEvents, Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = HumanSpawner.BuildStreamEventTable(self),
    WaitForGameObject = true
  }, "HumanSpawner.StreamingTheBunkers", self))
end

function HumanSpawner:StreamingTheBunkers()
  local t_bunkers = {}
  for i, v in ipairs(self.SMEDTable.lsAISpawners) do
    local hTempSelf = Actor.GetSelf(Tips.CheckForHandle(v))
    if hTempSelf then
      local nCounter
      for nCounter = 1, #hTempSelf.SMEDTable.lsAISpawners do
        table.insert(t_bunkers, hTempSelf.SMEDTable.lsAISpawners[nCounter])
      end
    end
  end
  table.insert(self.t_AllEvents, Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = t_bunkers,
    WaitForGameObject = true
  }, "HumanSpawner.Configure", self))
end

function HumanSpawner:OnExit()
  for i, v in ipairs(self.SMEDTable.lsAISpawners) do
    local hV = Tips.CheckForHandle(v)
    if hV then
      local hTempSelf = Actor.GetSelf(hV)
      if hTempSelf then
        for nCounter = 1, #hTempSelf.SMEDTable.lsAISpawners do
          local hTempSpawner = Util.GetHandleByName(hTempSelf.SMEDTable.lsAISpawners[nCounter])
          if hTempSpawner and Util.IsHandleValid(hTempSpawner) and Util.IsObjectHandleValid(hTempSpawner) then
            Object.SpawnerPurge(hTempSpawner, true)
          end
        end
      end
    end
  end
  if self.t_AllEvents then
    for i, v in ipairs(self.t_AllEvents) do
      if v then
        Util.KillEvent(v)
      end
    end
  end
  if self.t_TriggerEvents then
    for i, v in ipairs(self.t_TriggerEvents) do
      if v and Handle(v[2]) and v[1] ~= nil then
        Trigger.ClearCallback(v[2], v[1])
      end
    end
  end
end

function HumanSpawner:BuildStreamEventTable()
  local tCollectedStreamEvents = {}
  for i, v in ipairs(self.SMEDTable.lsAISpawners) do
    table.insert(tCollectedStreamEvents, v)
  end
  if self.SMEDTable.sUseName then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sUseName)
  end
  if self.SMEDTable.sDeactivateUseName then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sDeactivateUseName)
  end
  return tCollectedStreamEvents
end

function HumanSpawner:CreateSpawnerTable()
  self.tSpawnerInfo = {}
  for i, v in ipairs(self.SMEDTable.lsAISpawners) do
    local hSimpleSpawner = Tips.CheckForHandle(v)
    if hSimpleSpawner ~= nil then
      local hTempSelf = Actor.GetSelf(hSimpleSpawner)
      if hTempSelf then
      end
    end
  end
end

function HumanSpawner:Configure()
  local t_hAISPAWNERS = {}
  self.t_SpawnerLists = {}
  for i, v in ipairs(self.SMEDTable.lsAISpawners) do
    local hTempSelf = Actor.GetSelf(Tips.CheckForHandle(v))
    if hTempSelf then
      local nCounter
      for nCounter = 1, #hTempSelf.SMEDTable.lsAISpawners do
        local hTempSpawn = Util.GetHandleByName(hTempSelf.SMEDTable.lsAISpawners[nCounter])
        self.t_SpawnerLists[#self.t_SpawnerLists + 1] = hTempSpawn
        table.insert(self.t_AllEvents, Util.CreateEvent({EventType = "OnSpawn", Target = hTempSpawn}, "HumanSpawner.OnSpawn", self, {
          hTempSelf.SMEDTable.lsPaths
        }, true))
      end
    end
  end
  if self.SMEDTable.bTriggers == true then
    if self.SMEDTable.bByPT == true then
      local hEnteringHandle = Util.GetHandleByName(self.SMEDTable.sHandleEnteringPT)
      if hEnteringHandle == nil then
        table.insert(self.t_AllEvents, Util.CreateEvent({
          EventType = "StreamEvent",
          Objects = {
            self.SMEDTable.sHandleEnteringPT
          }
        }, "HumanSpawner.PTEventActivate", self))
      elseif Handle(self.SMEDTable.sPTName) then
        table.insert(self.t_TriggerEvents, {
          Trigger.WaitFor(self.SMEDTable.sPTName, Util.GetHandleByName(self.SMEDTable.sHandleEnteringPT), "HumanSpawner.ActivateByPT", self, {1}, cTRIGGEREVENT_ONENTER, false),
          self.SMEDTable.sPTName
        })
      end
    end
    if self.SMEDTable.bPTDeactivate == true and self.SMEDTable.sHandleDeactivateEnteringPT then
      local hEnteringHandle = Util.GetHandleByName(self.SMEDTable.sHandleDeactivateEnteringPT)
      if hEnteringHandle == nil then
        table.insert(self.t_AllEvents, Util.CreateEvent({
          EventType = "StreamEvent",
          Objects = {
            self.SMEDTable.sHandleDeactivateEnteringPT
          }
        }, "HumanSpawner.PTEventDeactivate", self))
      elseif Handle(self.SMEDTable.sPTDeactivateName) then
        table.insert(self.t_TriggerEvents, {
          Trigger.WaitFor(self.SMEDTable.sPTDeactivateName, Util.GetHandleByName(self.SMEDTable.sHandleDeactivateEnteringPT), "HumanSpawner.DeactivateByPT", self, {1}, cTRIGGEREVENT_ONENTER, false),
          self.SMEDTable.sPTDeactivateName
        })
      end
    end
    if self.SMEDTable.bByProximity == true then
      local hHandle1 = Util.GetHandleByName(self.SMEDTable.sHandle1)
      local hHandle2 = Util.GetHandleByName(self.SMEDTable.sHandle2)
      local tStreamObjects = {}
      if hHandle1 == nil then
        tStreamObjects[#tStreamObjects + 1] = self.SMEDTable.sHandle1
      end
      if hHandle2 == nil then
        tStreamObjects[#tStreamObjects + 1] = self.SMEDTable.sHandle2
      end
      if 0 < #tStreamObjects then
        table.insert(self.t_AllEvents, Util.CreateEvent({
          EventType = "StreamEvent",
          Objects = tStreamObjects
        }, "HumanSpawner.ProximityEventActivate", self))
      else
        self.sProx_EVENT = Util.CreateEvent({
          EventType = "ProximityEvent",
          ObjectA = hHandle1,
          ObjectB = hHandle2,
          Proximity = self.SMEDTable.nDistance,
          Negate = false
        }, "HumanSpawner.ActivateALL", self, {1})
        table.insert(self.t_AllEvents, self.sProx_EVENT)
      end
    end
    if self.SMEDTable.bProximityDeactivate == true then
      local hHandle1 = Util.GetHandleByName(self.SMEDTable.sHandle1Deactivate)
      local hHandle2 = Util.GetHandleByName(self.SMEDTable.sHandle2Deactivate)
      local tStreamObjects = {}
      if hHandle1 == nil then
        tStreamObjects[#tStreamObjects + 1] = self.SMEDTable.sHandle1Deactivate
      end
      if hHandle2 == nil then
        tStreamObjects[#tStreamObjects + 1] = self.SMEDTable.sHandle2Deactivate
      end
      if 0 < #tStreamObjects then
        table.insert(self.t_AllEvents, Util.CreateEvent({
          EventType = "StreamEvent",
          Objects = tStreamObjects
        }, "HumanSpawner.ProximityEventDeactivate", self))
      else
        self.sProx_EVENTDeactivate = Util.CreateEvent({
          EventType = "ProximityEvent",
          ObjectA = hHandle1,
          ObjectB = hHandle2,
          Proximity = self.SMEDTable.nDistanceDeactivate,
          Negate = false
        }, "HumanSpawner.DeactivateALL", self, {1})
        table.insert(self.t_AllEvents, self.sProx_EVENTDeactivate)
      end
    end
    if self.SMEDTable.bByUsePT == true then
      self.sUse_EVENT = Util.CreateEvent({
        EventType = "OnActorComplete",
        Target = Util.GetHandleByName(self.SMEDTable.sUseName)
      }, "HumanSpawner.ActivateALL", self)
      table.insert(self.t_AllEvents, self.sUse_EVENT)
    end
    if self.SMEDTable.bUseDeactivate == true then
      self.sUse_EVENTDeactivate = Util.CreateEvent({
        EventType = "OnActorComplete",
        Target = Util.GetHandleByName(self.SMEDTable.sDeactivateUseName)
      }, "HumanSpawner.DeactivateALL", self)
      table.insert(self.t_AllEvents, self.sUse_EVENTDeactivate)
    end
  end
end

function HumanSpawner:PTEventActivate()
  if Handle(self.SMEDTable.sPTName) then
    table.insert(self.t_TriggerEvents, {
      Trigger.WaitFor(self.SMEDTable.sPTName, Util.GetHandleByName(self.SMEDTable.sHandleEnteringPT), "HumanSpawner.ActivateByPT", self, {1}, cTRIGGEREVENT_ONENTER, false),
      self.SMEDTable.sPTName
    })
  end
end

function HumanSpawner:PTEventDeactivate()
  if Handle(self.SMEDTable.sPTDeactivateName) then
    table.insert(self.t_TriggerEvents, {
      Trigger.WaitFor(self.SMEDTable.sPTDeactivateName, Util.GetHandleByName(self.SMEDTable.sHandleDeactivateEnteringPT), "HumanSpawner.DeactivateByPT", self, {1}, cTRIGGEREVENT_ONENTER, false),
      self.SMEDTable.sPTDeactivateName
    })
  end
end

function HumanSpawner:ProximityEventDeactivate()
  local hHandle1 = Util.GetHandleByName(self.SMEDTable.sHandle1Deactivate)
  local hHandle2 = Util.GetHandleByName(self.SMEDTable.sHandle2Deactivate)
  self.sProx_EVENTDeactivate = Util.CreateEvent({
    EventType = "ProximityEvent",
    ObjectA = hHandle1,
    ObjectB = hHandle2,
    Proximity = self.SMEDTable.nDistanceDeactivate,
    Negate = false
  }, "HumanSpawner.DeactivateALL", self, {1})
  table.insert(self.t_AllEvents, self.sProx_EVENTDeactivate)
end

function HumanSpawner:ProximityEventActivate()
  local hHandle1 = Util.GetHandleByName(self.SMEDTable.sHandle1)
  local hHandle2 = Util.GetHandleByName(self.SMEDTable.sHandle2)
  self.sProx_EVENT = Util.CreateEvent({
    EventType = "ProximityEvent",
    ObjectA = hHandle1,
    ObjectB = hHandle2,
    Proximity = self.SMEDTable.nDistance,
    Negate = false
  }, "HumanSpawner.ActivateALL", self, {1})
  table.insert(self.t_AllEvents, self.sProx_EVENT)
end

function HumanSpawner:OnSpawn(hwho, tUserData)
  Nav.SetScriptedPath(hwho[2], tUserData[math.random(#tUserData)])
  if self.SMEDTable.bRun == true then
    Nav.SetScriptedPathMoveMode(hwho[2], true)
  end
end

function HumanSpawner:ActivateALL()
  if self.bDisabled == false then
    HumanSpawner.KillAllEvents(self)
    for i = 1, #self.t_SpawnerLists do
      Object.EnableSpawner(self.t_SpawnerLists[i], true)
    end
  end
end

function HumanSpawner:DeactivateALL()
  for i = 1, #self.t_SpawnerLists do
    Object.EnableSpawner(self.t_SpawnerLists[i], true)
  end
  self.bDisabled = true
end

function HumanSpawner:KillAllEvents()
  if self.sPT_EVENT then
    Util.KillEvent(self.sPT_EVENT)
    if Handle(self.SMEDTable.sPTName) then
      Trigger.Enable(self.SMEDTable.sPTName, false)
    end
  end
  if self.sProx_EVENT then
    Util.KillEvent(self.sProx_EVENT)
  end
  if self.sUse_EVENT then
    Util.KillEvent(self.sUse_EVENT)
  end
  self.bDisabled = true
end

function HumanSpawner:Disable()
  self.bDisabled = true
end

function HumanSpawner:DeactivateByPT(hwho)
  HumanSpawner.KillAllEvents(self)
  for i = 1, #self.t_SpawnerLists do
    Object.EnableSpawner(self.t_SpawnerLists[i], false)
  end
end

function HumanSpawner:ActivateByPT(hwho)
  if self.bDisabled == false then
    HumanSpawner.KillAllEvents(self)
    for i = 1, #self.t_SpawnerLists do
      Object.EnableSpawner(self.t_SpawnerLists[i], true)
    end
  end
end
