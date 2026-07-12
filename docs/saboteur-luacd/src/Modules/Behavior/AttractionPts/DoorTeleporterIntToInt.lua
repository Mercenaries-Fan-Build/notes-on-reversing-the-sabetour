if not DoorTeleporterIntToInt then
  DoorTeleporterIntToInt = {}
end
setmetatable(DoorTeleporterIntToInt, {__index = AttractionPt})
require("Includes\\WRAPPER_Event")

function DoorTeleporterIntToInt:OnEnter()
end

function DoorTeleporterIntToInt:SabLoaded()
end

function DoorTeleporterIntToInt:OnExit()
end

function DoorTeleporterIntToInt:OnActorEnter(actorHandle, nState)
  local fadeout = self.SMEDTable.FadeOutTime or 0
  local sScript = self.SMEDTable.EnteringScript
  if not sScript then
    return
  end
  local sLoadInScript = self.SMEDTable.EnteringScript
  local sLoadOutScript = self.SMEDTable.ExitingScript
  print("sLoadInScript ", sLoadInScript, " sLoadOutScript ", sLoadOutScript)
  if sLoadInScript and sLoadOutScript then
    print("load out script . going  ", sLoadOutScript, self.SMEDTable.DoorLocator)
    local sDoorLocator = self.SMEDTable.DoorLocator
    local tInteriorTable = InteriorManager.GetInteriorTableByScript(sLoadOutScript)
    if tInteriorTable and tInteriorTable.sName then
      Util.AddInteriorLoadCallback(tInteriorTable.sName, "DoorTeleporterIntToInt.ContinueEnterIntToInt", self, {sLoadInScript, sDoorLocator})
    else
      Util.Assert(false, "CFrench fails you, fail inside interior to interior teleport, tInteriorTable.sName not found :(")
    end
    InteriorManager.InteriorScriptExit(sLoadOutScript, self.SMEDTable.DoorLocator, true)
    Render.FadeScreen(true)
    EVENT_Timer("DoorTeleporterIntToInt.FreezePlayer", nil, 0.75)
    return
  else
    print("ERROR::\tDoorTeleporterIntToInt.OnActorEnter : bp did not specify into and outof interior scripts")
  end
end

function DoorTeleporterIntToInt:ContinueEnterIntToInt(sLoadInScript, sDoorLocator)
  print("Entering interior from another interior ", sLoadInScript, sDoorLocator)
  InteriorManager.InteriorScriptEnter(sLoadInScript, sDoorLocator)
end

function DoorTeleporterIntToInt:FreezePlayer()
  Actor.TurnOnDude(hSab, false)
end
