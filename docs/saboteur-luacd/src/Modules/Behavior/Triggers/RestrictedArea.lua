if not RestrictedArea then
  RestrictedArea = {}
  if Trigger == nil then
    Trigger = {}
  end
end
setmetatable(RestrictedArea, {__index = Trigger})

function RestrictedArea:OnEnter(a_hController)
  RestrictedArea.PrintToConsole(self, "Configuring...")
  RestrictedArea.PrintToConsole(self, "Configuration complete.")
  Trigger.CreateRestrictedArea(a_hController)
end

function RestrictedArea:OnExit()
end

function RestrictedArea:OnTriggerEnter(handleOfThatWhichEntered)
  local hSaboteur = Util.GetHandleByName("Saboteur")
  if handleOfThatWhichEntered == hSaboteur then
    RestrictedArea.PrintToConsole(self, "Saboteur has entered the area")
  end
end

function RestrictedArea:OnTriggerExit(handleOfThatWhichExited)
  if handleOfThatWhichExited == Util.GetHandleByName("Saboteur") then
    RestrictedArea.PrintToConsole(self, "Saboteur has left the area")
  end
end

function RestrictedArea:PrintToConsole(a_sMessageString)
end
