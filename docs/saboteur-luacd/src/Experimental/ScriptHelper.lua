if not ScriptHelper then
  ScriptHelper = {}
  if AttractionPt == nil then
  end
end
setmetatable(ScriptHelper, {__index = AttractionPt})

function ScriptHelper:OnEnter()
  self.bEnabled = true
end

function ScriptHelper:Activate()
  if self.bEnabled ~= true then
    return
  end
end

function ScriptHelper:Enable()
  self.bEnabled = true
end

function ScriptHelper:Disable()
  self.bEnabled = false
end

function ScriptHelper:PrintToConsole(a_sMessageString)
  print("::: SCRIPTHELPER (" .. Util.GetNameFromHandle(self.hController) .. "): " .. a_sMessageString)
end
