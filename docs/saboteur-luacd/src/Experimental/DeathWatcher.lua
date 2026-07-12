if not DeathWatcher then
  DeathWatcher = {}
  if ScriptHelper == nil then
  end
end
setmetatable(DeathWatcher, {__index = ScriptHelper})

function DeathWatcher:OnEnter()
  self.bEnabled = true
  self.sTargetName = ""
  self.sTargetHelperName = ""
  Util.CreateEvent({
    EventType = "StreamEvent",
    Object = self.sTargetName
  }, "DeathWatcher.SetupDeathEvent", self)
end

function DeathWatcher:SetupDeathEvent()
  local hTarget = Util.GetHandleByName(self.sTargetName)
  Util.CreateEvent({EventType = "DeathEvent", ObjectHandle = hTarget}, "DeathWatcher.Activate", self)
end

function DeathWatcher:Activate()
  if self.bEnabled ~= true then
    return
  end
  local hTargetHelper = Util.GetHandleByName(self.sTargetHelperName)
  Util.BroadcastFunction(hTargetHelper, "Activate", {})
end

function DeathWatcher:Enable()
  self.bEnabled = true
end

function DeathWatcher:Disable()
  self.bEnabled = false
end
