if not UsePathAction then
  UsePathAction = {}
  if ScriptHelper == nil then
  end
end
setmetatable(UsePathAction, {__index = ScriptHelper})

function UsePathAction:OnEnter()
  UsePathAction.PrintToConsole(self, "UsePathAction setting up StreamEvent for required game objects")
  Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      self.SMEDTable.sTargetActorName
    }
  }, "UsePathAction.ConfigureHelper", self)
end

function UsePathAction:ConfigureHelper()
  UsePathAction.PrintToConsole(self, "UsePathAction objects we're watching for have streamed in")
  self.bEnabled = self.SMEDTable.bIsEnabled
  self.bFiresOnce = self.SMEDTable.bFiresOnce
  self.sPathName = self.SMEDTable.sPathName
  self.sMoveType = ""
  self.bUrgentTraversal = self.SMEDTable.bUrgentTraversal
  self.bOverrideAll = self.SMEDTable.bOverrideAll
  self.hActor = Util.GetHandleByName(self.SMEDTable.sTargetActorName)
  UsePathAction.PrintToConsole(self, "UsePathAction has been configured")
end

function UsePathAction:Activate()
  if self.bEnabled ~= true then
    return
  end
  print("Using path.")
  print(self.hActor)
  Util.BroadcastFunction(self.hActor, "UsePath", {
    self.sPathName,
    cPATHTYPE_BOUNCE,
    self.bUrgentTraversal,
    self.bOverrideAll
  })
  if self.bFiresOnce == true then
    self.bEnabled = false
  end
end

function UsePathAction:Enable()
  self.bEnabled = true
end

function UsePathAction:Disable()
  self.bEnabled = false
end
