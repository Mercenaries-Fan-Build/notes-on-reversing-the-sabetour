if not MoveToObjectAction then
  MoveToObjectAction = {}
  if ScriptHelper == nil then
  end
end
setmetatable(MoveToObjectAction, {__index = ScriptHelper})

function MoveToObjectAction:OnEnter()
  self.bEnabled = true
  self.bFiresOnce = false
  self.sMoverName = "Enemies\\Enemy_Mover"
  self.sMoverTargetName = "Enemies\\Loc_MoverDest"
  self.bUrgent = false
  self.nRadius = 1
  self.bOverrideAll = false
end

function MoveToObjectAction:Activate()
  if self.bEnabled ~= true then
    return
  end
  local hMover = Util.GetHandleByName(self.sMoverName)
  local hMoverTarget = Util.GetHandleByName(self.sMoverTargetName)
  Util.BroadcastFunction(hMover, "MoveToObject", {
    hMoverTarget,
    self.nRadius,
    self.bUrgent,
    self.bOverrideAll
  })
  Render.PrintDialogue(hMover, "I'm moving to a new destination!", 2)
  if self.bFiresOnce == true then
    self.bEnabled = false
  end
end

function MoveToObjectAction:Enable()
  self.bEnabled = true
end

function MoveToObjectAction:Disable()
  self.bEnabled = false
end
