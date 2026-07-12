if not AttackAction then
  AttackAction = {}
  if ScriptHelper == nil then
  end
end
setmetatable(AttackAction, {__index = ScriptHelper})

function AttackAction:OnEnter()
  self.bEnabled = true
  self.bFiresOnce = true
  self.sActorName = ""
  self.sTargetName = ""
end

function AttackAction:Activate()
  if self.bEnabled ~= true then
    return
  end
  local hActor = Util.GetHandleByName(sActorName)
  local hTarget = Util.GetHandleByName(hTarget)
  Util.BroadcastFunction(hActor, "AttackTarget", {hTarget})
  if self.bFiresOnce == true then
    self.bEnabled = false
  end
end

function AttackAction:Enable()
  self.bEnabled = true
end

function AttackAction:Disable()
  self.bEnabled = false
end
