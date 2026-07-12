if not TriggerWatcher then
  TriggerWatcher = {}
  if ScriptHelper == nil then
  end
end
setmetatable(TriggerWatcher, {__index = ScriptHelper})

function TriggerWatcher:OnEnter()
  TriggerWatcher.PrintToConsole(self, "TriggerWatcher setting up StreamEvent for required game objects")
  Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      self.SMEDTable.sNameOfActor
    }
  }, "TriggerWatcher.ConfigureHelper", self)
end

function TriggerWatcher:ConfigureHelper()
  TriggerWatcher.PrintToConsole(self, "TriggerWatcher objects we're watching for have streamed in")
  self.bEnabled = self.SMEDTable.bIsEnabled
  self.bFiresOnce = self.SMEDTable.bFiresOnce
  if self.SMEDTable.sTriggerNameToWatch ~= "NONE" then
    self.hPolygonalTrigger = Util.GetHandleByName(self.SMEDTable.sTriggerNameToWatch)
  end
  if self.SMEDTable.sTargetHelperName ~= "NONE" then
    self.hTargetHelper = Util.GetHandleByName(self.SMEDTable.sTargetHelperName)
  end
  if self.SMEDTable.sNameOfActor ~= "NONE" then
    self.hActorToWatchFor = Util.GetHandleByName(self.SMEDTable.sNameOfActor)
  end
  if self.SMEDTable.sNameOfActor ~= "NONE" then
    self.sLabelOfActors = self.SMEDTable.sLabelOfActors
  end
  Util.CreateEvent({
    EventType = "OnTriggerEnter",
    Target = self.hPolygonalTrigger
  }, "TriggerWatcher.Activate", self)
  UsePathAction.PrintToConsole(self, "TriggerWatcher has been configured")
end

function TriggerWatcher:Activate(a_tTriggerData)
  TriggerWatcher.PrintToConsole(self, "TriggerWatcher activation attempt started")
  if a_tTriggerData[2] == self.hActorToWatchFor then
    TriggerWatcher.PrintToConsole(self, "TriggerWatcher has found (" .. Util.GetNameFromHandle(self.hActorToWatchFor) .. ")")
    TriggerWatcher.PrintToConsole(self, "TriggerWatcher is attempting to activate target ScriptHelper (" .. Util.GetNameFromHandle(self.hTargetHelper) .. ")")
    Util.BroadcastFunction(self.hTargetHelper, "Activate", {})
    if self.bFiresOnce == true then
      TriggerWatcher.PrintToConsole(self, "TriggerWatcher is disabling itself (bFiresOnce == true)")
      self.bEnabled = false
    end
  end
end

function TriggerWatcher:Enable()
  self.bEnabled = true
end

function TriggerWatcher:Disable()
  self.bEnabled = false
end
