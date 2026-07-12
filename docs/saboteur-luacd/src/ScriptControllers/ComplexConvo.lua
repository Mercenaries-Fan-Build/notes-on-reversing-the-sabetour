if not ComplexConvo then
  ComplexConvo = {}
end

function ComplexConvo:OnEnter()
  self.t_AllEvents = {}
  self.t_TriggerEvents = {}
  table.insert(self.t_AllEvents, Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = ComplexConvo.BuildStreamEventTable(self)
  }, "ComplexConvo.Configure", self))
end

function ComplexConvo:OnExit()
  ComplexConvo.CleanUp(self)
end

function ComplexConvo:BuildStreamEventTable()
  local tCollectedStreamEvents = {}
  if self.SMEDTable.sEnteringHandle1 then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sEnteringHandle1)
  end
  if self.SMEDTable.sEnteringHandle2 then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sEnteringHandle2)
  end
  if self.SMEDTable.sEnteringHandle3 then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sEnteringHandle3)
  end
  if self.SMEDTable.sEnteringHandle4 then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sEnteringHandle4)
  end
  if self.SMEDTable.sEnteringHandle5 then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sEnteringHandle5)
  end
  if self.SMEDTable.sProxHandeA1 and self.SMEDTable.sProxHandeB1 then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sProxHandeA1)
    table.insert(tCollectedStreamEvents, self.SMEDTable.sProxHandeB1)
  end
  if self.SMEDTable.sProxHandeA2 and self.SMEDTable.sProxHandeB2 then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sProxHandeA2)
    table.insert(tCollectedStreamEvents, self.SMEDTable.sProxHandeB2)
  end
  if self.SMEDTable.sProxHandeA3 and self.SMEDTable.sProxHandeB3 then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sProxHandeA3)
    table.insert(tCollectedStreamEvents, self.SMEDTable.sProxHandeB3)
  end
  if self.SMEDTable.sProxHandeA4 and self.SMEDTable.sProxHandeB4 then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sProxHandeA4)
    table.insert(tCollectedStreamEvents, self.SMEDTable.sProxHandeB4)
  end
  if self.SMEDTable.sProxHandeA5 and self.SMEDTable.sProxHandeB5 then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sProxHandeA5)
    table.insert(tCollectedStreamEvents, self.SMEDTable.sProxHandeB5)
  end
  if self.SMEDTable.lsKill1 then
    for i, v in ipairs(self.SMEDTable.lsKill1) do
      table.insert(tCollectedStreamEvents, v)
    end
  end
  return tCollectedStreamEvents
end

function ComplexConvo:EnableConvo()
  ComplexConvo.SetupUsePoints(self)
  ComplexConvo.PT_Event_Setups(self)
  ComplexConvo.CheckConvoConditions(self)
end

function ComplexConvo:SetupUsePoints()
  if #self.SMEDTable.sUsePt1 > 0 then
    self.UsePTSize = 0
    self.Used = 0
    local tempI, tempV
    for tempI, tempV in ipairs(self.SMEDTable.sUsePt1) do
      local hSwitch = Util.GetHandleByName(tempV)
      if hSwitch then
        self.tEventHandles[tempI] = Util.CreateEvent({
          EventType = "OnActorComplete",
          Target = hSwitch
        }, "ComplexConvo.IncrementUse", self, {nil}, false)
      end
      self.UsePTSize = self.UsePTSize + 1
    end
  end
end

function ComplexConvo:IncrementUse()
  self.Used = self.Used + 1
end

function ComplexConvo:DisableConvo()
  if self.hTimerCheck then
    Util.KillEvent(self.hTimerCheck)
  end
  if self.tEventHandles then
    local tempI, tempV
    for tempI, tempV in pairs(self.tEventHandles) do
      if tempV then
        Util.KillEvent(tempV)
      end
    end
  end
  if self.t_AllEvents then
    for i, v in pairs(self.t_AllEvents) do
      if v then
        Util.KillEvent(v)
      end
    end
  end
  if self.t_TriggerEvents then
    for i, v in pairs(self.t_TriggerEvents) do
      if v then
        Trigger.DoNotWaitFor(v[2], hSab)
        Trigger.ClearCallback(v[2], v[1])
      end
    end
  end
end

function ComplexConvo:CheckConvoConditions()
  if ComplexConvo.PolygonalCheck(self) and ComplexConvo.ProximityCheck(self) and ComplexConvo.SeeHandleCheck(self) and ComplexConvo.UsedATPTCheck(self) and ComplexConvo.DeathCheck(self) then
    local bAllow = true
    local bInCombat = Suspicion.IsSomeoneHostile()
    if self.SMEDTable.bNotInCombat == true then
      if bInCombat == true then
        bAllow = false
      end
    elseif self.SMEDTable.bInCombat == true and bInCombat == false then
      bAllow = false
    end
    if bAllow == true then
      local tEvent = {
        EventType = "TimerEvent",
        Time = self.SMEDTable.nDelay
      }
      Util.CreateEvent(tEvent, "ComplexConvo.TimedConvo", self)
    elseif self.SMEDTable.bTryUntilPlayed == true then
      local tEvent = {EventType = "TimerEvent", Time = 0.5}
      self.hTimerCheck = Util.CreateEvent(tEvent, "ComplexConvo.CheckConvoConditions", self, nil)
    end
  else
    local tEvent = {EventType = "TimerEvent", Time = 0.5}
    self.hTimerCheck = Util.CreateEvent(tEvent, "ComplexConvo.CheckConvoConditions", self, nil)
  end
end

function ComplexConvo:TimedConvo()
  local tFlags = {}
  if self.SMEDTable.bClearQueue == true then
    tFlags.ClearOutList = true
  end
  if #self.SMEDTable.lsConversationWith > 0 then
    tFlags.Speakers = {}
    local tempI, tempV
    for tempI, tempV in ipairs(self.SMEDTable.lsConversationWith) do
      local hPerson = Util.GetHandleByName(tempV)
      if hPerson then
        table.insert(tFlags.Speakers, hPerson)
      end
    end
  end
  if self.SMEDTable.sGrabFromTriggerForConversation then
    if tFlags.Speakers == nil then
      tFlags.Speakers = {}
    end
    local hFilter
    if self.SMEDTable.TriggerFilter then
      local hFilter = Filter.New(self.SMEDTable.TriggerFilter)
    end
    local th_Inside = {}
    if hFilter ~= nil then
      th_Inside = Trigger.GetAllWithin(Util.GetHandleByName(self.SMEDTable.sGrabFromTriggerForConversation), hFilter)
    else
      th_Inside = Trigger.GetAllWithin(Util.GetHandleByName(self.SMEDTable.sGrabFromTriggerForConversation))
    end
    local tempI, tempV
    for tempI, tempV in ipairs(th_Inside) do
      table.insert(tFlags.Speakers, tempV)
    end
  end
  if self.bNodeCleared == false then
    Convo.AddConvo(self.SMEDTable.sConversationName, self.SMEDTable.nPriority, tFlags)
  end
  if self.SMEDTable.lsDisableConvo then
    local tempI, tempV
    for tempI, tempV in ipairs(self.SMEDTable.lsDisableConvo) do
      local tempself = Actor.GetSelf(Util.GetHandleByName(tempV))
      ComplexConvo.DisableConvo(tempself)
    end
  end
  if self.SMEDTable.lsEnableConvo then
    local tempI, tempV
    for tempI, tempV in ipairs(self.SMEDTable.lsEnableConvo) do
      local tempself = Actor.GetSelf(Util.GetHandleByName(tempV))
      ComplexConvo.EnableConvo(tempself)
    end
  end
  if self.SMEDTable.nReEnableTimer > -1 then
    local tEvent = {
      EventType = "TimerEvent",
      Time = self.SMEDTable.nReEnableTimer
    }
    self.hTimerCheck = Util.CreateEvent(tEvent, "ComplexConvo.CheckConvoConditions", self, nil)
  end
end

function ComplexConvo:PT_Event_Setups()
  local tTable = {}
  tTable[1] = {
    sEnter = self.SMEDTable.sEnteringHandle1,
    sTrig = self.SMEDTable.sTriggerName1
  }
  tTable[2] = {
    sEnter = self.SMEDTable.sEnteringHandle2,
    sTrig = self.SMEDTable.sTriggerName2
  }
  tTable[3] = {
    sEnter = self.SMEDTable.sEnteringHandle3,
    sTrig = self.SMEDTable.sTriggerName3
  }
  tTable[4] = {
    sEnter = self.SMEDTable.sEnteringHandle4,
    sTrig = self.SMEDTable.sTriggerName4
  }
  tTable[5] = {
    sEnter = self.SMEDTable.sEnteringHandle5,
    sTrig = self.SMEDTable.sTriggerName5
  }
  local iCounter = 1
  self.PT_flags = {}
  for iCounter = 1, 5 do
    if tTable[iCounter].sEnter then
      self.PT_flags[iCounter] = {
        sEnter = tTable[iCounter].sEnter,
        sTrig = tTable[iCounter].sTrig,
        bIn = false
      }
      table.insert(self.t_TriggerEvents, {
        Trigger.WaitFor(tTable[iCounter].sTrig, Handle(tTable[iCounter].sEnter), "ComplexConvo.PT_Event_EnteredTrigger", self, {iCounter}, cTRIGGEREVENT_ONENTER),
        tTable[iCounter].sTrig
      })
    end
  end
end

function ComplexConvo:PT_Event_EnteredTrigger(hwho, tUser)
  table.insert(self.t_TriggerEvents, {
    Trigger.WaitFor(self.PT_flags[tUser].sTrig, Handle(self.PT_flags[tUser].sEnter), "ComplexConvo.PT_Event_ExitedTrigger", self, {tUser}, cTRIGGEREVENT_ONEXIT),
    self.PT_flags[tUser].sTrig
  })
  self.PT_flags[tUser].bIn = true
end

function ComplexConvo:PT_Event_ExitedTrigger(hwho, tUser)
  table.insert(self.t_TriggerEvents, {
    Trigger.WaitFor(self.PT_flags[tUser].sTrig, Handle(self.PT_flags[tUser].sEnter), "ComplexConvo.PT_Event_EnteredTrigger", self, {tUser}, cTRIGGEREVENT_ONENTER),
    self.PT_flags[tUser].sTrig
  })
  self.PT_flags[tUser].bIn = false
end

function ComplexConvo:PolygonalCheck()
  local bAllIn = true
  for i, v in ipairs(self.PT_flags) do
    local bIn = v.bIn
    if bIn == false then
      bAllIn = false
    end
  end
  return bAllIn
end

function ComplexConvo:ProximityCheck()
  local tTable = {}
  tTable[1] = {
    sHandle1 = self.SMEDTable.sProxHandeA1,
    sHandle2 = self.SMEDTable.sProxHandeB1,
    nDist = self.SMEDTable.nProxDist1,
    bNeg = self.SMEDTable.bProxNegate1
  }
  tTable[2] = {
    sHandle1 = self.SMEDTable.sProxHandeA2,
    sHandle2 = self.SMEDTable.sProxHandeB2,
    nDist = self.SMEDTable.nProxDist2,
    bNeg = self.SMEDTable.bProxNegate2
  }
  tTable[3] = {
    sHandle1 = self.SMEDTable.sProxHandeA3,
    sHandle2 = self.SMEDTable.sProxHandeB3,
    nDist = self.SMEDTable.nProxDist3,
    bNeg = self.SMEDTable.bProxNegate3
  }
  tTable[4] = {
    sHandle1 = self.SMEDTable.sProxHandeA4,
    sHandle2 = self.SMEDTable.sProxHandeB4,
    nDist = self.SMEDTable.nProxDist4,
    bNeg = self.SMEDTable.bProxNegate4
  }
  tTable[5] = {
    sHandle1 = self.SMEDTable.sProxHandeA5,
    sHandle2 = self.SMEDTable.sProxHandeB5,
    nDist = self.SMEDTable.nProxDist5,
    bNeg = self.SMEDTable.bProxNegate5
  }
  local iCounter = 1
  for iCounter = 1, 5 do
    if tTable[iCounter].sHandle1 then
      local hObject1 = Util.GetHandleByName(tTable[iCounter].sHandle1)
      local hObject2 = Util.GetHandleByName(tTable[iCounter].sHandle2)
      if hObject1 and hObject2 then
        local nTotalDist = Object.GetDistance(hObject1, hObject2)
        if tTable[iCounter].bNeg == true then
          if nTotalDist < tTable[iCounter].nDist then
            return false
          end
        elseif nTotalDist > tTable[iCounter].nDist then
          return false
        end
      else
        return false
      end
    end
  end
  return true
end

function ComplexConvo:SeeHandleCheck()
  local tTable = {}
  tTable[1] = {
    hWatcher = self.SMEDTable.sLooker1,
    hObject = self.SMEDTable.sViewableObject1,
    nTime = self.SMEDTable.nViewingTime1
  }
  tTable[2] = {
    hWatcher = self.SMEDTable.sLooker2,
    hObject = self.SMEDTable.sViewableObject2,
    nTime = self.SMEDTable.nViewingTime2
  }
  tTable[3] = {
    hWatcher = self.SMEDTable.sLooker3,
    hObject = self.SMEDTable.sViewableObject3,
    nTime = self.SMEDTable.nViewingTime3
  }
  tTable[4] = {
    hWatcher = self.SMEDTable.sLooker4,
    hObject = self.SMEDTable.sViewableObject4,
    nTime = self.SMEDTable.nViewingTime4
  }
  tTable[5] = {
    hWatcher = self.SMEDTable.sLooker5,
    hObject = self.SMEDTable.sViewableObject5,
    nTime = self.SMEDTable.nViewingTime5
  }
  local iCounter = 1
  for iCounter = 1, 5 do
    if tTable[iCounter].hWatcher then
      local hObject1 = Util.GetHandleByName(tTable[iCounter].hWatcher)
      local hObject2 = Util.GetHandleByName(tTable[iCounter].hObject)
      if hObject1 and hObject2 then
        local bCanSee = Sensory.CanSee(hObject1, hObject2)
        if bCanSee == false then
          return false
        end
      else
        return false
      end
    end
  end
  return true
end

function ComplexConvo:UsedATPTCheck()
  if self.UsePTSize == nil then
    return true
  elseif self.UsePTSize == self.Used then
    return true
  end
  return false
end

function ComplexConvo:DeathCheck()
  local nDeadCount = 0
  local nDeadGoal = self.SMEDTable.nPartialKill
  local tempI, tempV
  if self.SMEDTable.lsKill1 then
    for tempI, tempV in ipairs(self.SMEDTable.lsKill1) do
      local hHandle = Util.GetHandleByName(tempV)
      if hHandle then
        if Object.IsAlive(hHandle) then
          if nDeadGoal < 0 then
            return false
          end
        else
          nDeadCount = nDeadCount + 1
        end
      else
        return false
      end
    end
  end
  if nDeadGoal < 0 or nDeadGoal <= nDeadCount then
    return true
  else
    return false
  end
end

function ComplexConvo:Configure()
  self.tEventHandles = {}
  self.bNodeCleared = false
  if self.SMEDTable.bStartDisabled ~= true then
    ComplexConvo.EnableConvo(self)
  end
end

function ComplexConvo:CleanUp()
  ComplexConvo.DisableConvo(self)
  self.bNodeCleared = true
end
