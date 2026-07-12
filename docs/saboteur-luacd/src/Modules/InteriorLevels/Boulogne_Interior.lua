require("Includes\\WRAPPER_Event")
require("Includes\\__UtilFunctions")
require("Managers\\InteriorManager")
if not Boulogne_Interior then
  Boulogne_Interior = {}
end
Boulogne_Interior.sInteriorTableName = "Boulogne"
Boulogne_Interior.sInterior = "Boulogne_int"
Boulogne_Interior.Nodes = {}
setmetatable(Boulogne_Interior, {__index = InteriorManager})

function Boulogne_Interior:OnEnter()
end

function Boulogne_Interior.OnEnterInterior(sLocator)
  InteriorManager.OnEnterInterior(Boulogne_Interior.sInteriorTableName)
  Suspicion.EnableGlobal(false)
  Boulogne_Interior:LoadInteriorNode()
  Boulogne_Interior:LoadWaitingInteriorStarters()
  DisableBelleHQAbilities(true)
  Boulogne_Interior:LoadMinimapImages("MM_Boulogne")
  Util.EnterInterior("Boulogne", sLocator)
end

function Boulogne_Interior.OnExitInterior(sLocator)
  DisableBelleHQAbilities(false)
  InteriorManager.OnExitInterior()
  Suspicion.EnableGlobal(true)
  Boulogne_Interior:UnloadWaitingInteriorStarters()
  Util.ExitInterior("Boulogne", sLocator)
end
