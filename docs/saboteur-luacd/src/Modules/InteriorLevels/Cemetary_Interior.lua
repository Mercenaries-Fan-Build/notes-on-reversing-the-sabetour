require("Includes\\WRAPPER_Event")
require("Includes\\__UtilFunctions")
require("Managers\\InteriorManager")
if not Cemetary_Interior then
  Cemetary_Interior = {}
end
Cemetary_Interior.sInteriorTableName = "Cemetary"
Cemetary_Interior.sInterior = "Cemetary_int"
Cemetary_Interior.Nodes = {}
setmetatable(Cemetary_Interior, {__index = InteriorManager})

function Cemetary_Interior:OnEnter()
end

function Cemetary_Interior.OnEnterInterior(sLocator)
  InteriorManager.OnEnterInterior(Cemetary_Interior.sInteriorTableName)
  Render.WTFSetOverrideBlueprint("WillToFight_Crypt")
  Suspicion.EnableGlobal(false)
  Cemetary_Interior:LoadInteriorNode()
  Cemetary_Interior:LoadWaitingInteriorStarters()
  Util.EnterInterior("Cemetary")
end

function Cemetary_Interior.OnExitInterior(sLocator)
  InteriorManager.OnExitInterior()
  Suspicion.EnableGlobal(true)
  InteriorManager.ClearOverrideBluePrint()
  Util.ExitInterior("Cemetary", sLocator)
end
