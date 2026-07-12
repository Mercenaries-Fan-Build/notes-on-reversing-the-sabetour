require("Includes\\WRAPPER_Event")
require("Includes\\__UtilFunctions")
require("Managers\\InteriorManager")
if not LeHavreHotel_Interior then
  LeHavreHotel_Interior = {}
end
LeHavreHotel_Interior.sInteriorTableName = "LeHavreHotel"
LeHavreHotel_Interior.sInterior = "int_hotel_skylar"
LeHavreHotel_Interior.Nodes = {}
setmetatable(LeHavreHotel_Interior, {__index = InteriorManager})

function LeHavreHotel_Interior:OnEnter()
end

function LeHavreHotel_Interior.OnEnterInterior(sLocator)
  InteriorManager.OnEnterInterior(LeHavreHotel_Interior.sInteriorTableName)
  Suspicion.EnableGlobal(false)
  LeHavreHotel_Interior:LoadInteriorNode()
  local bDisableFadeIn = false
  if IsMissionOpen("Connect_ST_215b_SkylarRendevous") and not oGameMaster.oActiveGameplayMission then
    bDisableFadeIn = true
  end
  LeHavreHotel_Interior:LoadWaitingInteriorStarters()
  DisableHQAbilities(true)
  LeHavreHotel_Interior:LoadMinimapImages("MM_LeHavreHotel")
  Util.EnterInterior("LeHavreHotel", sLocator, bDisableFadeIn)
end

function LeHavreHotel_Interior.OnExitInterior(sLocator)
  DisableHQAbilities(false)
  InteriorManager.OnExitInterior()
  Suspicion.EnableGlobal(true)
  LeHavreHotel_Interior:UnloadWaitingInteriorStarters()
  if IsMissionOpen("Connect_ST_215b_SkylarRendevous") then
    Util.SetOverrideLoadScreenFadeIn(false)
  end
  Util.ExitInterior("LeHavreHotel", sLocator)
end
