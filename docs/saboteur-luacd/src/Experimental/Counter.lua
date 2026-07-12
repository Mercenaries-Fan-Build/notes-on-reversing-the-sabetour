if not Counter then
  Counter = {}
  if ScriptHelper == nil then
  end
end
setmetatable(Counter, {__index = ScriptHelper})

function Counter:OnEnter()
  self.bEnabled = true
  self.nCount = 0
  self.nTargetCount = nil
  self.nModulo = 2
  self.sTargetHelperName = "Alarms\\MoveHelper1"
end

function Counter:Activate()
  if self.bEnabled ~= true then
    return
  end
  self.nCount = self.nCount + 1
  print(Util.GetNameFromHandle(self.hController) .. " :: Current Count: " .. self.nCount)
  if self.nTargetCount ~= nil and self.nCount == self.nTargetCount then
    Render.PrintMessage("COUNTER HAS FIRED")
    Util.BroadcastFunction(Util.GetHandleByName(self.sTargetHelperName), "Activate", {})
    self.bEnabled = false
  end
  if self.nModulo ~= nil and self.nCount % self.nModulo == 0 then
    Render.PrintMessage("COUNTER HAS FIRED")
    Util.BroadcastFunction(Util.GetHandleByName(self.sTargetHelperName), "Activate", {})
  end
end

function Counter:Enable()
  self.bEnabled = true
end

function Counter:Disable()
  self.bEnabled = false
end
