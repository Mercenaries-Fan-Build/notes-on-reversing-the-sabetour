if not Enabler then
  Enabler = {}
  if ScriptHelper == nil then
  end
end
setmetatable(Enabler, {__index = ScriptHelper})

function Enabler:OnEnter()
  self.bEnabled = true
  self.bFiresOnce = true
  self.bEnableTarget = true
  self.bToggleTarget = false
  self.sTargetHelperName = ""
end

function Enabler:Activate()
  if self.bEnabled ~= true then
    return
  end
  local hTargetHelper = Util.GetHandleByName(self.sTargetHelperName)
  if bEnableTarget == true and self.bToggleTarget == false then
    Util.BroadcastFunction(hTargetHelper, "Enable", {})
  else
    Util.BroadcastFunction(hTargetHelper, "Disable", {})
  end
  if self.bToggleTarget == true then
    local tTargetSelf = Actor.GetSelf(hTargetHelper)
    if tTargetSelf.bEnabled == true then
      Util.BroadcastFunction(hTargetHelper, "Disable", {})
    else
      Util.BroadcastFunction(hTargetHelper, "Enable", {})
    end
  end
  if self.bFiresOnce == true then
    self.bEnabled = false
  end
end

function Enabler:Enable()
  self.bEnabled = true
end

function Enabler:Disable()
  self.bEnabled = false
end
