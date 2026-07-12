require("Includes\\WRAPPER_Event")
require("Includes\\__UtilFunctions")
require("Managers\\InteriorManager")
if not Pantheon_Interior then
  Pantheon_Interior = {}
end
Pantheon_Interior.sInteriorTableName = "Pantheon"
Pantheon_Interior.sInterior = "pantheon_interior"
Pantheon_Interior.Nodes = {}
setmetatable(Pantheon_Interior, {__index = InteriorManager})

function Pantheon_Interior:OnEnter()
end

function Pantheon_Interior.OnEnterInterior(a_sLocator)
  InteriorManager.OnEnterInterior(Pantheon_Interior.sInteriorTableName)
  Pantheon_Interior:LoadInteriorNode()
  Render.WTFExitActivePortal()
  Render.WTFSetOverrideBlueprint("WillToFight_INT_Pantheon")
  Pantheon_Interior:LoadMinimapImages("MM_Pantheon")
  Trigger.Enable("Missions\\freeplay\\p3\\mis_panth_biggergun\\wtf_low\\RestrictedArea", false)
  Trigger.Enable("Missions\\freeplay\\p3\\mis_panth_biggergun\\pantheon_interior\\RestrictedArea", true)
  Util.EnterInterior("Pantheon", a_sLocator)
end

function Pantheon_Interior.OnExitInterior(a_sLocator)
  InteriorManager.OnExitInterior()
  Trigger.Enable("Missions\\freeplay\\p3\\mis_panth_biggergun\\wtf_low\\RestrictedArea", true)
  Trigger.Enable("Missions\\freeplay\\p3\\mis_panth_biggergun\\pantheon_interior\\RestrictedArea", false)
  Util.ExitInterior("Pantheon", a_sLocator)
  Render.WTFClearOverrideBlueprint()
end
