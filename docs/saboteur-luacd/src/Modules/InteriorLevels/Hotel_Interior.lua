require("Includes\\WRAPPER_Event")
require("Includes\\__UtilFunctions")
require("Managers\\InteriorManager")
if not Hotel_Interior then
  Hotel_Interior = {}
end
Hotel_Interior.sInteriorTableName = "HDV"
Hotel_Interior.sInterior = "HDV_int"
Hotel_Interior.Nodes = {}
setmetatable(Hotel_Interior, {__index = InteriorManager})

function Hotel_Interior:OnEnter()
end

function Hotel_Interior.OnEnterInterior(sLocator)
  InteriorManager.OnEnterInterior(Hotel_Interior.sInteriorTableName)
  local sMainNode = "Missions\\paris_2\\mission_5\\main"
  local sInsideNode = "Missions\\paris_2\\mission_5\\hotel_inside"
  local sAmbientNaziNode = "missions\\paris_2\\mission_5\\hdv_nazi_patrol"
  Hotel_Interior:LoadInteriorNode()
  Hotel_Interior:LoadDynamicNode(sMainNode)
  Hotel_Interior:LoadDynamicNode(sInsideNode)
  Hotel_Interior:LoadDynamicNode(sAmbientNaziNode)
  Render.WTFSetOverrideBlueprint("WillToFight_INT_Hotel")
  if not g_bP2M5_escalated then
    Suspicion.ResetEscalation()
  end
  g_bP2M5_escalated = nil
  Combat.GlobalAllowGrenades(false)
  Hotel_Interior:LoadMinimapImages("MM_Hotel")
  __UtilFunctions.LoadStaticTag("hdv_special", true)
  Util.EnterInterior("HDV", sLocator)
  HUD.SetMinimapZoom(true, 1.1)
end

function Hotel_Interior.OnExitInterior(sLocator)
  Render.HeatShimmerFilter(0, 0, 0, 0)
  InteriorManager.OnExitInterior()
  __UtilFunctions.UnloadStaticTag("hdv_special", true)
  Util.ExitInterior("HDV", sLocator)
  Combat.GlobalAllowGrenades(true)
  WorldSMEDNodes.UnloadStaticTag("hdvsmoke", true)
  InteriorManager.ClearOverrideBluePrint()
  Render.WTFExitActivePortal()
  HUD.SetMinimapZoom(false)
end
