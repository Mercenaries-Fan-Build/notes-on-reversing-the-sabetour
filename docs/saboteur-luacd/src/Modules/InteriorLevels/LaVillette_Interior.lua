require("Includes\\WRAPPER_Event")
require("Includes\\__UtilFunctions")
require("Managers\\InteriorManager")
if not LaVillette_Interior then
  LaVillette_Interior = {}
end
LaVillette_Interior.sInteriorTableName = "LaVillette"
LaVillette_Interior.sInterior = "LaVillette_int"
LaVillette_Interior.Nodes = {}
setmetatable(LaVillette_Interior, {__index = InteriorManager})

function LaVillette_Interior:OnEnter()
end

function LaVillette_Interior.OnEnterInterior(sLocator)
  Util.LoadAnimGroup("la_villette")
  InteriorManager.OnEnterInterior(LaVillette_Interior.sInteriorTableName)
  LaVillette_Interior.Nodes = {}
  local sHQPop = "PARIS\\area01\\lavillette\\interior\\lavillette_int\\HQPop"
  local bDisableFadeIn = false
  Suspicion.EnableGlobal(false)
  LaVillette_Interior:LoadInteriorNode()
  LaVillette_Interior:LoadWaitingInteriorStarters()
  if IsMissionOpen("Paris_1_Mission_6") or IsMissionActive("Paris_1_Mission_6") then
    LaVillette_Interior:LoadCinematicNode("324_cinb_defend")
  elseif IsMissionActive("Paris_1_Mission_1B") or IsMissionActive("Paris_1_Mission_1B_Connect") or IsMissionOpen("Paris_1_Mission_1B_Connect") then
  elseif IsMissionCompleted("P1FP_RoofFetch01") and not IsMissionActive("Connect_Cin_301_Act3") and not IsMissionOpen("Connect_Cin_301_Act3") then
    LaVillette_Interior:LoadDynamicNode("PARIS\\area01\\lavillette\\interior\\lavilette_pop")
  end
  if IsMissionActive("Paris_1_Mission_1B") then
    bDisableFadeIn = true
    SetDisableControl("Action", true)
    DisablePlayersMovement(true)
    SetDisableControl("Walking", true)
    LaVillette_Interior:LoadCinematicNode("HQ_Pre_DynamicBoxes")
    WorldSMEDNodes.LoadStaticTag("lavilette_int_pre", true)
  end
  if IsMissionOpen("Paris_1_Mission_1B_Connect") or IsMissionActive("Paris_1_Mission_1B_Connect") then
    LaVillette_Interior:LoadCinematicNode("HQ_Pre_DynamicBoxes")
    WorldSMEDNodes.LoadStaticTag("lavilette_int_pre", true)
    Util.AddInteriorLoadCallback("LaVillette", "LaVillette_Interior.CallbackSetLucInFront", nil)
    Util.AddInteriorLoadCallback("LaVillette", "LaVillette_Interior.CallbackVeroniqueByLuc", nil)
  end
  if IsMissionOpen("P1FP_RoofFetch01") then
    LaVillette_Interior:LoadCinematicNode("HQ_Pre_DynamicBoxes")
    LaVillette_Interior:LoadDynamicNode("Missions\\paris_1\\sound")
    WorldSMEDNodes.LoadStaticTag("lavilette_int_pre", true)
  end
  if IsMissionActive("P1FP_RoofFetch01") then
    if not Actor.HasLabel(hSab, "WineBottleMeds") then
      LaVillette_Interior:LoadCinematicNode("HQ_Pre_DynamicBoxes")
      WorldSMEDNodes.LoadStaticTag("lavilette_int_pre", true)
      Util.AddInteriorLoadCallback("LaVillette", "LaVillette_Interior.CallbackSetLucWounded", nil)
    else
      Util.AddInteriorLoadCallback("LaVillette", "LaVillette_Interior.CallbackSetLucWounded", nil)
      LaVillette_Interior:LoadDynamicNode("PARIS\\area01\\lavillette\\interior\\lavilette_pop")
    end
  end
  if IsMissionOpen("P1FP_Jailbreak") or IsMissionOpen("Connect_ST_212_ResistanceBackup") then
    Util.AddInteriorLoadCallback("LaVillette", "LaVillette_Interior.CallbackSetLucStanding", nil)
  end
  if IsMissionActive("SOE_2_Mission_2_ConnectB") then
    bDisableFadeIn = true
    LaVillette_Interior:LoadDynamicNode("Missions\\paris_1\\characters\\lavillette\\kessler_interior")
    Util.AddInteriorLoadCallback("LaVillette", "LaVillette_Interior.CallbackSet_305_Con_Allied", nil)
  end
  if IsMissionOpen("Connect_Cin_301_Act3") then
    bDisableFadeIn = true
  end
  if IsMissionCompleted("Paris_1_Mission_1B") or SabTask._tMiscSaveTable._HQSetsMissionCompletes and SabTask._tMiscSaveTable._HQSetsMissionCompletes.Paris_1_Mission_1B then
    print("p1m1b is completed")
    WorldSMEDNodes.LoadStaticTag("lavilette_int_hq", true)
    if not IsMissionOpen("Paris_1_Mission_6") then
    end
  end
  if IsMissionActive("Paris_1_Mission_6") or IsMissionOpen("Paris_1_Mission_6") then
    print("disabling interior loadin")
    bDisableFadeIn = true
  end
  LaVillette_Interior:LoadMinimapImages("MM_LaVillette")
  DisableBelleHQAbilities(true)
  Util.EnterInterior("LaVillette", sLocator, bDisableFadeIn)
end

function LaVillette_Interior.OnExitInterior(sLocator)
  local bDisableFadeIn = false
  Util.UnloadAnimGroup("la_villette")
  InteriorManager.OnExitInterior()
  WorldSMEDNodes.UnloadStaticTag("lavilette_int_pre", true)
  WorldSMEDNodes.UnloadStaticTag("lavilette_int_hq", true)
  Suspicion.EnableGlobal(true)
  DisableBelleHQAbilities(false)
  LaVillette_Interior:UnloadWaitingInteriorStarters()
  Util.ExitInterior("LaVillette", sLocator, bDisableFadeIn)
end

function LaVillette_Interior:CallbackSetLucInFront()
  print("LaVillette_Interior.CallbackSetLucInFront")
  local hLuc = Handle("Missions\\paris_1\\characters\\lavillette\\luc_interior\\Luc_LaVillette_Interior")
  if hLuc then
    Actor.CancelAttrPtRequest(hLuc)
    local hAttpt = Handle("Missions\\paris_1\\characters\\lavillette\\luc_interior\\AttractionPt_sit_sick")
    Actor.UseAttrPt(hLuc, hAttpt)
  end
end

function LaVillette_Interior:CallbackSetLucWounded()
  print("LaVillette_Interior.CallbackSetLucWounded")
  local hLuc = Handle("Missions\\paris_1\\characters\\lavillette\\luc_interior\\Luc_LaVillette_Interior")
  if hLuc then
    Actor.CancelAttrPtRequest(hLuc)
    Actor.UseAttrPt(hLuc, Handle("PARIS\\area01\\lavillette\\interior\\lavillette_int\\ATTRPT_CIV_Pain_Stomach"))
  end
end

function LaVillette_Interior:CallbackSetLucStanding()
  print("LaVillette_Interior.CallbackSetLucStanding")
  local hLuc = Handle("Missions\\paris_1\\characters\\lavillette\\luc_interior\\Luc_LaVillette_Interior")
  if hLuc then
    Actor.CancelAttrPtRequest(hLuc)
    Actor.UseAttrPt(hLuc, Handle("Missions\\paris_1\\characters\\lavillette\\luc_interior\\ATTRPT_CIV_Thinking_PERM"))
  end
end

function LaVillette_Interior:CallbackVeroniqueByLuc()
  print("LaVillette_Interior.CallbackVeroniqueByLuc")
  local hVeron = Handle("Missions\\paris_1\\characters\\lavillette\\veronique_interior\\Veronique_LaVillette_Interior")
  if hVeron then
    Actor.CancelAttrPtRequest(hVeron)
    Actor.UseAttrPt(hVeron, Handle("Missions\\paris_1\\characters\\lavillette\\veronique_interior\\AIAttractionPt_Look"))
  end
end

function LaVillette_Interior:CallbackSet_305_Con_Allied()
  local hLuc = Handle("Missions\\paris_1\\characters\\lavillette\\luc_interior\\Luc_LaVillette_Interior")
  local hLucATPT = Handle("Missions\\paris_1\\characters\\lavillette\\luc_interior\\AIAttractionPt_S2M2b")
  local hVeronique = Handle("Missions\\paris_1\\characters\\lavillette\\veronique_front\\Veronique_LaVillette_Front")
  local hVeroniqueATPT = Handle("Missions\\paris_1\\characters\\lavillette\\veronique_front\\AIAttractionPt_S2M2b")
  local hSkylar = Handle("Missions\\paris_1\\characters\\lavillette\\skylar_interior\\Skylar_LaVillette_Interior")
  local hSkylarATPT = Handle("Missions\\paris_1\\characters\\lavillette\\skylar_interior\\AIAttractionPt_S2M2b")
  local hKessler = Handle("Missions\\paris_1\\characters\\lavillette\\kessler_interior\\Kessler_LaVillette_Interior")
  local hKesslerATPT = Handle("Missions\\paris_1\\characters\\lavillette\\kessler_interior\\AIAttractionPt_S2M2b")
  if hLuc then
    Actor.CancelAttrPtRequest(hLuc, true)
    Actor.UseAttrPt(hLuc, hLucATPT)
  end
  if hVeronique then
    Actor.CancelAttrPtRequest(hVeronique, true)
    Actor.UseAttrPt(hVeronique, hVeroniqueATPT)
  end
  if hSkylar then
    Actor.CancelAttrPtRequest(hSkylar, true)
    Actor.UseAttrPt(hSkylar, hSkylarATPT)
  end
  if hKessler then
    Actor.CancelAttrPtRequest(hKessler, true)
    Actor.UseAttrPt(hKessler, hKesslerATPT)
  end
end
