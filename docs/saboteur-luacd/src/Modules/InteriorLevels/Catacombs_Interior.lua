require("Includes\\WRAPPER_Event")
require("Includes\\__UtilFunctions")
require("Managers\\InteriorManager")
if not Catacombs_Interior then
  Catacombs_Interior = {}
end
Catacombs_Interior.sInteriorTableName = "Catacombs"
Catacombs_Interior.sInterior = "hq"
Catacombs_Interior.Nodes = {}
setmetatable(Catacombs_Interior, {__index = InteriorManager})

function Catacombs_Interior:OnEnter()
end

function Catacombs_Interior.OnEnterInterior(sLocator)
  InteriorManager.OnEnterInterior(Catacombs_Interior.sInteriorTableName)
  local bDisableFadeIn = false
  Render.WTFSetOverrideBlueprint("WillToFight_INT_Catacomb_HQ")
  Suspicion.EnableGlobal(false)
  Catacombs_Interior:LoadInteriorNode()
  local sResist = "Missions\\paris_3\\characters\\hq\\resistance_interior"
  if IsMissionActive("P1M6b") or IsMissionOpen("Connect_ST_318_RaceComing") then
  else
    Catacombs_Interior:LoadDynamicNode(sResist)
  end
  if IsMissionActive("Act_3_Mission_1") or IsMissionOpen("Act_3_Mission_1") then
    bDisableFadeIn = true
  end
  if IsMissionActive("P1M6b") then
    print("P1M6b active")
    Catacombs_Interior:LoadCinematicNode("326_cinb_vgone")
    bDisableFadeIn = true
  end
  Catacombs_Interior:LoadWaitingInteriorStarters()
  DisableBelleHQAbilities(true)
  if IsMissionActive("Paris_6_Mission_1_ConnectB") then
    bDisableFadeIn = true
  end
  Catacombs_Interior:LoadMinimapImages("MM_Catacombs")
  Util.EnterInterior("Catacombs", sLocator, bDisableFadeIn)
end

function Catacombs_Interior.OnExitInterior(sLocator)
  DisableBelleHQAbilities(false)
  local bDisableSuperSpores = false
  local bDisableFadeIn = false
  if IsMissionActive("Act_3_Mission_1") then
    bDisableFadeIn = true
  end
  InteriorManager.OnExitInterior(bDisableSuperSpores)
  Suspicion.EnableGlobal(true)
  Catacombs_Interior:UnloadWaitingInteriorStarters()
  Util.ExitInterior("Catacombs", sLocator, bDisableFadeIn)
  InteriorManager.ClearOverrideBluePrint()
end
