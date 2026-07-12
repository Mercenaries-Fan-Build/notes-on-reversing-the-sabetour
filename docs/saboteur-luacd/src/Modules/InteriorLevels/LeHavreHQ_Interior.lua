require("Includes\\WRAPPER_Event")
require("Includes\\__UtilFunctions")
require("Managers\\InteriorManager")
if not LeHavreHQ_Interior then
  LeHavreHQ_Interior = {}
end
LeHavreHQ_Interior.sInteriorTableName = "LeHavre"
LeHavreHQ_Interior.sInterior = "lehavre_hq"
LeHavreHQ_Interior.Nodes = {}
setmetatable(LeHavreHQ_Interior, {__index = InteriorManager})

function LeHavreHQ_Interior:OnEnter()
end

function LeHavreHQ_Interior.OnEnterInterior(sLocator)
  Util.LoadAnimGroup("le_havre_hq")
  InteriorManager.OnEnterInterior(LeHavreHQ_Interior.sInteriorTableName)
  local bDisableFadeIn = false
  Suspicion.EnableGlobal(false)
  Suspicion.ResetEscalation()
  LeHavreHQ_Interior:LoadInteriorNode()
  if IsMissionOpen("SOE_Zeppelin") or IsMissionOpen("Connect_ST_215b_SkylarRendevous") then
  else
    LeHavreHQ_Interior:LoadDynamicNode("LeHavre\\characters\\hq\\interior_resistance")
  end
  LeHavreHQ_Interior:LoadMinimapImages("MM_LeHavre")
  LeHavreHQ_Interior:LoadWaitingInteriorStarters()
  DisableBelleHQAbilities(true)
  if IsMissionOpen("Connect_ST_215b_SkylarRendevous") and not oGameMaster.oActiveGameplayMission then
    print("Connect_ST_215b_SkylarRendevous is open loading hotel")
    bDisableFadeIn = true
    Util.RequestNode("int_hotel_skylar", "LeHavre", _NODE_INTERIOR, false, false, false)
  end
  if IsMissionOpen("SOE_Zeppelin") then
    bDisableFadeIn = true
  end
  Util.EnterInterior("LeHavre", sLocator, bDisableFadeIn)
end

function LeHavreHQ_Interior.OnExitInterior(sLocator)
  DisableBelleHQAbilities(false)
  InteriorManager.OnExitInterior()
  Suspicion.EnableGlobal(true)
  LeHavreHQ_Interior:UnloadWaitingInteriorStarters()
  Util.ExitInterior("LeHavre", sLocator)
  Util.UnloadAnimGroup("le_havre_hq")
end
