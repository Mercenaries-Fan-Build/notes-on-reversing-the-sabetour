require("Includes\\WRAPPER_Event")
require("Includes\\__UtilFunctions")
require("Managers\\InteriorManager")
if not SaarHQ_Interior then
  SaarHQ_Interior = {}
end
SaarHQ_Interior.sInteriorTableName = "SaarHQ"
SaarHQ_Interior.sInterior = "int_saar_hotel"
setmetatable(SaarHQ_Interior, {__index = InteriorManager})

function SaarHQ_Interior:OnEnter()
end

function SaarHQ_Interior.OnEnterInterior(sLocator)
  InteriorManager.OnEnterInterior(SaarHQ_Interior.sInteriorTableName)
  SaarHQ_Interior:LoadCinematicNode("109_skysex")
  SaarHQ_Interior:LoadInteriorNode()
  Util.EnterInterior("SaarHQ", sLocator, true)
  DisableHQAbilities(false)
end

function SaarHQ_Interior.OnExitInterior(sLocator)
  DisableHQAbilities(false)
  InteriorManager.OnExitInterior()
  Suspicion.EnableGlobal(true)
  SaarHQ_Interior:UnloadWaitingInteriorStarters()
  Util.ExitInterior("SaarHQ", sLocator, true)
end
