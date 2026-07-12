if not ConversationTriggers then
  ConversationTriggers = {}
end

function ConversationTriggers:OnEnter()
  local tTable = ConversationTriggers.BuildStreamEventTable(self)
  if 0 < #tTable then
    Util.CreateEvent({
      EventType = "StreamEvent",
      Objects = ConversationTriggers.BuildStreamEventTable(self)
    }, "ConversationTriggers.Configure", self)
  else
    ConversationTriggers.Configure(self)
  end
end

function ConversationTriggers:OnExit()
  ConversationTriggers.CleanUp(self)
end

function ConversationTriggers:BuildStreamEventTable()
  local tCollectedStreamEvents = {}
  if self.SMEDTable.bByProximity then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sHandle1)
    table.insert(tCollectedStreamEvents, self.SMEDTable.sHandle2)
  end
  if self.SMEDTable.bByUsePt then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sUsePt)
  end
  if self.SMEDTable.bByDeath then
    table.insert(tCollectedStreamEvents, self.SMEDTable.sDeathHandle)
  end
  return tCollectedStreamEvents
end

function ConversationTriggers:Configure()
  self.tEventHandles = {}
  if self.SMEDTable.bByTrigger then
    self.hPTEvent = Trigger.WaitFor(self.SMEDTable.sTriggerName, Util.GetHandleByName(self.SMEDTable.sEnteringHandle), "ConversationTriggers.PlayConvo", self, {1}, cTRIGGEREVENT_ONENTER, false)
  end
  if self.SMEDTable.bByProximity then
    local tEventType = {
      EventType = "ProximityEvent",
      ObjectA = Util.GetHandleByName(self.SMEDTable.sHandle1),
      ObjectB = Util.GetHandleByName(self.SMEDTable.sHandle2),
      Proximity = self.SMEDTable.nDistance,
      Negate = false,
      Check3D = true
    }
    table.insert(self.tEventHandles, Util.CreateEvent(tEventType, "ConversationTriggers.PlayConvo", self))
  end
  if self.SMEDTable.bByLookingAtLocator then
    local tEventType = {
      EventType = "SeeLocatorEvent",
      InViewTime = self.SMEDTable.nViewingTime,
      Locator = self.SMEDTable.sViewableLocator
    }
    table.insert(self.tEventHandles, Util.CreateEvent(tEventType, "ConversationTriggers.PlayConvo", self))
  end
  if self.SMEDTable.bByUsePt then
    local tEventType = {
      EventType = "OnActorComplete",
      Target = Util.GetHandleByName(self.SMEDTable.sUsePt)
    }
    table.insert(self.tEventHandles, Util.CreateEvent(tEventType, "ConversationTriggers.PlayConvo", self))
  end
  if self.SMEDTable.bByDeath then
    local tEventType = {
      EventType = "DeathEvent",
      ObjectHandle = Util.GetHandleByName(self.SMEDTable.sDeathHandle)
    }
    table.insert(self.tEventHandles, Util.CreateEvent(tEventType, "ConversationTriggers.PlayConvo", self))
  end
end

function ConversationTriggers:PlayConvo()
  Convo.AddConvo(self.SMEDTable.sConversationName, 10, {})
  ConversationTriggers.CleanUp(self)
end

function ConversationTriggers:CleanUp()
  if self.tEventHandles then
    for i, v in ipairs(self.tEventHandles) do
      Util.KillEvent(v)
    end
  end
  if self.hPTEvent then
    Trigger.ClearCallback(self.SMEDTable.sTriggerName, self.hPTEvent)
  end
end
