if StarterManager == nil then
  StarterManager = {}
  StarterManager.MasterList = {}
  StarterManager.tInteractionList = {}
  StarterManager.Save_IsStarterHiddenList = {}
  cSM_NOTLOADED = 1
  cSM_LOADING = 2
  cSM_LOADED = 3
  cSM_UNLOADING = 4
end

function StarterManager.InitList()
  StarterManager.MasterList = {
    {
      sName = "vittore_act1_ext",
      sNode = "Missions\\act_1\\characters\\vittore_exterior",
      bInterior = false
    },
    {
      sName = "jules_act1_ext",
      sNode = "Missions\\act_1\\characters\\jules_exterior",
      bInterior = false
    },
    {
      sName = "groupie1",
      sNode = "Missions\\act_1\\characters\\ro_groupie1",
      bInterior = false
    },
    {
      sName = "skylar_act1_attractionpoint",
      sNode = "Missions\\act_1\\characters\\skylar_attrpt_exterior",
      bInterior = false
    },
    {
      sName = "fp_act1_racing_dude",
      sNode = "Missions\\act_1\\characters\\freeplay\\a1_fp_starter",
      bInterior = false
    },
    {
      sName = "Luc_Hangman_Exterior",
      sNode = "Missions\\paris_2\\characters\\luc_exterior",
      StarterIcon = "mm_MS_Luc"
    },
    {
      sName = "Luc_Belle_Interior",
      sNode = "Missions\\paris_1\\characters\\belle\\luc_interiorp1m1",
      bInterior = true,
      sInterior = "Belle",
      StarterIcon = "mm_MS_Luc"
    },
    {
      sName = "Luc_Belle_Interior_2",
      sNode = "Missions\\paris_1\\characters\\belle\\Luc_Belle_Interior2",
      bInterior = true,
      sInterior = "Belle",
      StarterIcon = "mm_MS_Luc"
    },
    {
      sName = "santos_ext_hideout",
      sNode = "Missions\\paris_1\\characters\\belle\\santos_hideout",
      StarterIcon = "mm_MS_Santos"
    },
    {
      sName = "vittore_garage",
      sNode = "Missions\\paris_1\\characters\\belle\\vit_belle_garage",
      bInterior = false,
      StarterIcon = "mm_MS_Vittore"
    },
    {
      sName = "vittore_belle_bar",
      sNode = "Missions\\paris_1\\characters\\belle\\vit_belle_int",
      bInterior = true,
      sInterior = "Belle",
      StarterIcon = "mm_MS_Vittore"
    },
    {
      sName = "Veronique_Belle_Interior",
      sNode = "Missions\\paris_1\\characters\\belle\\veronique_interior",
      bInterior = true,
      sInterior = "Belle",
      StarterIcon = "mm_MS_Veronique"
    },
    {
      sName = "Ludivine_Belle_Interior",
      sNode = "Missions\\paris_1\\characters\\belle\\ludivine_interior",
      bInterior = true,
      sInterior = "Belle",
      StarterIcon = "mm_MS_Veronique"
    },
    {
      sName = "gaspard_belle",
      sNode = "Missions\\paris_1\\characters\\belle\\gaspard_interior",
      bInterior = true,
      sInterior = "Belle",
      StarterIcon = "mm_MS_Gaspard"
    },
    {
      sName = "Father_Belle_Interior",
      sNode = "Missions\\paris_1\\characters\\belle\\father_denis_belle",
      bInterior = true,
      sInterior = "Belle",
      StarterIcon = "mm_MS_Denis"
    },
    {
      sName = "SkylarBelle",
      sNode = "Missions\\paris_1\\characters\\belle\\skylar_belle_int",
      bInterior = true,
      sInterior = "Belle",
      StarterIcon = "mm_MS_Skylar"
    },
    {
      sName = "bishop_lehavre_interior",
      sNode = "LeHavre\\characters\\HQ\\bishop_interior",
      bInterior = true,
      sInterior = "LeHavre",
      StarterIcon = "mm_MS_Bishop"
    },
    {
      sName = "skylar_lehavre_interior",
      sNode = "LeHavre\\characters\\HQ\\skylar_interior",
      bInterior = true,
      StarterIcon = "mm_MS_Skylar",
      sInterior = "LeHavre"
    },
    {
      sName = "wilcox_lehavre_interior",
      sNode = "LeHavre\\characters\\hq\\wilcox_interior",
      bInterior = true,
      sInterior = "LeHavre",
      StarterIcon = "mm_MS_Wilcox_2"
    },
    {
      sName = "skylar_lehavrehotel_interior",
      sNode = "LeHavre\\characters\\hotel\\skylar_interior",
      bInterior = true,
      StarterIcon = "mm_MS_Skylar",
      sInterior = "LeHavreHotel",
      sParentInterior = "LeHavre"
    },
    {
      sName = "Veronique_LaVillette_Interior",
      sNode = "Missions\\paris_1\\characters\\LaVillette\\veronique_interior",
      bInterior = true,
      StarterIcon = "mm_MS_Veronique",
      sInterior = "LaVillette"
    },
    {
      sName = "Veronique_LaVillette_Front",
      sNode = "Missions\\paris_1\\characters\\lavillette\\veronique_front",
      bInterior = true,
      StarterIcon = "mm_MS_Veronique",
      sInterior = "LaVillette"
    },
    {
      sName = "Skylar_LaVillette_Interior",
      sNode = "Missions\\paris_1\\characters\\lavillette\\Skylar_interior",
      bInterior = true,
      sInterior = "LaVillette",
      StarterIcon = "mm_MS_Skylar"
    },
    {
      sName = "Luc_LaVillette_Interior",
      sNode = "Missions\\paris_1\\characters\\lavillette\\Luc_interior",
      bInterior = true,
      sInterior = "LaVillette",
      StarterIcon = "mm_MS_Luc"
    },
    {
      sName = "Luc_LaVillette_Wounded",
      sNode = "Missions\\paris_1\\characters\\lavillette\\luc_wounded",
      bInterior = true,
      sInterior = "LaVillette",
      StarterIcon = "mm_MS_Luc"
    },
    {
      sName = "Renard_LaVillette_Interior",
      sNode = "Missions\\paris_1\\characters\\lavillette\\Renard_interior",
      bInterior = true,
      sInterior = "LaVillette",
      StarterIcon = "mm_MS_Race"
    },
    {
      sName = "Couteau_LaVillette_Interior",
      sNode = "Missions\\paris_1\\characters\\lavillette\\Couteau_interior",
      bInterior = true,
      StarterIcon = "mm_MS_Crochet",
      sInterior = "LaVillette"
    },
    {
      sName = "Santos_LaVillette_Interior",
      sNode = "Missions\\paris_1\\characters\\lavillette\\Santos_interior",
      bInterior = true,
      sInterior = "LaVillette",
      StarterIcon = "mm_MS_Santos"
    },
    {
      sName = "Vittore_LaVillette_Interior",
      sNode = "Missions\\paris_1\\characters\\lavillette\\Vittore_interior",
      bInterior = true,
      sInterior = "LaVillette",
      StarterIcon = "mm_MS_Vittore"
    },
    {
      sName = "Father_LaVillette_Interior",
      sNode = "Missions\\paris_1\\characters\\lavillette\\father_interior",
      bInterior = true,
      sInterior = "LaVillette",
      StarterIcon = "mm_MS_Denis"
    },
    {
      sName = "Kessler_LaVillette_Interior",
      sNode = "Missions\\paris_1\\characters\\lavillette\\kessler_interior",
      bInterior = true,
      sInterior = "LaVillette",
      StarterIcon = "mm_MS_Vittore"
    },
    {
      sName = "Maria_LaVillette_Interior",
      sNode = "Missions\\paris_1\\characters\\lavillette\\maria_interior",
      bInterior = true,
      sInterior = "LaVillette"
    },
    {
      sName = "Luc_Boulogne_Interior",
      sNode = "Missions\\paris_2\\characters\\boulogne\\luc_interior",
      bInterior = true,
      sInterior = "Boulogne",
      StarterIcon = "mm_MS_Luc"
    },
    {
      sName = "Bryman_Boulogne_Exterior",
      sNode = "Missions\\paris_5\\characters\\bryman_exterior",
      bInterior = false,
      StarterIcon = "mm_MS_Bryman"
    },
    {
      sName = "Bryman_Boulogne_Interior",
      sNode = "Missions\\paris_2\\characters\\boulogne\\bryman_interior",
      bInterior = true,
      sInterior = "Boulogne",
      StarterIcon = "mm_MS_Bryman"
    },
    {
      sName = "Margot_Boulogne_Interior",
      sNode = "Missions\\paris_2\\characters\\boulogne\\margot_interior",
      bInterior = true,
      sInterior = "Boulogne",
      StarterIcon = "mm_MS_Margot_2"
    },
    {
      sName = "Santos_Boulogne_Interior",
      sNode = "Missions\\paris_2\\characters\\boulogne\\santos_interior",
      bInterior = true,
      sInterior = "Boulogne",
      StarterIcon = "mm_MS_Santos"
    },
    {
      sName = "Vittore_Boulogne_Interior",
      sNode = "Missions\\paris_2\\characters\\boulogne\\vittore_interior",
      bInterior = true,
      sInterior = "Boulogne",
      StarterIcon = "mm_MS_Vittore"
    },
    {
      sName = "bryman_cat_int",
      sNode = "Missions\\paris_3\\characters\\hq\\bryman_interior",
      bInterior = false,
      StarterIcon = "mm_MS_Bryman"
    },
    {
      sName = "santos_cat_int",
      sNode = "Missions\\paris_3\\characters\\hq\\santos_interior",
      bInterior = true,
      sInterior = "Catacombs",
      StarterIcon = "mm_MS_Santos"
    },
    {
      sName = "drkwong_cat_int",
      sNode = "Missions\\paris_3\\characters\\hq\\drkwong",
      bInterior = true,
      sInterior = "Catacombs",
      StarterIcon = "mm_MS_Kwong"
    },
    {
      sName = "duval_cat_int",
      sNode = "Missions\\paris_3\\characters\\hq\\duval_interior",
      bInterior = true,
      sInterior = "Catacombs",
      StarterIcon = "mm_MS_Duval"
    },
    {
      sName = "luc_cat_int",
      sNode = "Missions\\paris_3\\characters\\hq\\luc_interior",
      bInterior = true,
      sInterior = "Catacombs",
      StarterIcon = "mm_MS_Luc"
    },
    {
      sName = "vittore_cat_int",
      sNode = "Missions\\paris_3\\characters\\hq\\vittore_interior",
      bInterior = true,
      sInterior = "Catacombs",
      StarterIcon = "mm_MS_Vittore"
    },
    {
      sName = "maria_cat_int",
      sNode = "Missions\\paris_3\\characters\\hq\\maria_interior",
      bInterior = true,
      sInterior = "Catacombs"
    },
    {
      sName = "kessler_cat_int",
      sNode = "Missions\\paris_3\\characters\\hq\\kessler_interior",
      bInterior = true,
      sInterior = "Catacombs"
    },
    {
      sName = "skylar_cat_int",
      sNode = "Missions\\paris_3\\characters\\hq\\skylar_interior",
      bInterior = true,
      sInterior = "Catacombs",
      StarterIcon = "mm_MS_Skylar"
    },
    {
      sName = "veronique_cat_int",
      sNode = "Missions\\paris_3\\characters\\hq\\veronique_interior",
      bInterior = true,
      sInterior = "Catacombs",
      StarterIcon = "mm_MS_Veronique"
    },
    {
      sName = "skylar_cat_ext",
      sNode = "Missions\\paris_3\\characters\\hq\\skylar_exterior",
      bInterior = false,
      StarterIcon = "mm_MS_Skylar"
    },
    {
      sName = "FatherDenis_Eustache_Exterior",
      sNode = "Missions\\freeplay\\p1\\characters\\fatherdenis_eustache",
      bInterior = false,
      StarterIcon = "mm_MS_Denis"
    },
    {
      sName = "Father_Sacre_Interior",
      sNode = "Missions\\paris_1\\characters\\sacrecour\\father_denis_sacrecour",
      bInterior = false,
      StarterIcon = "mm_MS_Denis"
    },
    {
      sName = "Kwong_Ctown",
      sNode = "Missions\\paris_2\\characters\\freeplay\\kwong_chinatown",
      bInterior = false,
      StarterIcon = "mm_MS_Kwong"
    },
    {
      sName = "Duval_ext_ind",
      sNode = "Missions\\paris_2\\characters\\freeplay\\duval_ind_ext",
      bInterior = false,
      StarterIcon = "mm_MS_Duval"
    },
    {
      sName = "Crochet_ext_whouse",
      sNode = "Missions\\paris_2\\characters\\freeplay\\crochet_wherehouse",
      bInterior = false,
      StarterIcon = "mm_MS_Crochet"
    },
    {
      sName = "Bryman_Market_Exterior",
      sNode = "Missions\\freeplay\\p2\\mis_trap\\bryman_market",
      bInterior = false,
      StarterIcon = "mm_MS_Bryman"
    },
    {
      sName = "Couteau_Chaumont_Exterior",
      sNode = "Missions\\freeplay\\p1\\characters\\couteau_chaumont",
      bInterior = false,
      StarterIcon = "mm_MS_Crochet"
    },
    {
      sName = "Spore_RS_Renard",
      sNode = "Missions\\freeplay\\country\\fp_paris_qualifier\\starter",
      bInterior = false,
      StarterIcon = "mm_MS_Race"
    },
    {
      sName = "Race1_Starter",
      sNode = "Missions\\freeplay\\country\\countryrace1\\starter",
      bInterior = false,
      StarterIcon = "mm_MS_Race"
    },
    {
      sName = "Race2_Starter",
      sNode = "Missions\\freeplay\\country\\countryrace3\\starter",
      bInterior = false,
      StarterIcon = "mm_MS_Race"
    },
    {
      sName = "BelleFC_Starter",
      sNode = "Missions\\paris_1\\characters\\belle\\fightclub",
      bInterior = true,
      sInterior = "Belle"
    },
    {
      sName = "Luc_Tobac_Starter",
      sNode = "Missions\\paris_1\\characters\\belle\\luc_tobacco",
      bInterior = false,
      StarterIcon = "mm_MS_Luc"
    },
    {
      sName = "Arc_Starter",
      sNode = "Missions\\paris_2\\characters\\freeplay\\arc",
      bInterior = false
    },
    {
      sName = "P1_Sniper1_Starter",
      sNode = "Missions\\freeplay\\p1\\sniper1\\starter",
      bInterior = false
    },
    {
      sName = "ccover_starter",
      sNode = "Missions\\freeplay\\p2\\mis_parc_clandestinecover\\starter",
      bInterior = false
    },
    {
      sName = "sniper_starter",
      sNode = "Missions\\freeplay\\p2\\mis_madeleine_sniper\\starter",
      bInterior = false
    },
    {
      sName = "Moreau_Exterior",
      sNode = "Missions\\paris_4\\characters\\cemetary\\exterior\\moreau",
      bInterior = false,
      StarterIcon = "mm_MS_Skylar"
    },
    {
      sName = "HDV_Starter",
      sNode = "Missions\\paris_6\\characters\\hdv\\hdv_starter_ext",
      bInterior = false,
      StarterIcon = "mm_MS_Bryman"
    },
    {
      sName = "gaspard",
      sNode = "Missions\\paris_6\\mission_1\\starter",
      StarterIcon = "mm_MS_Bryman",
      bInterior = false
    },
    {
      sName = "Starter_Skylar_Airstrip",
      sNode = "Missions\\act_3\\characters\\skylar_airstrip_starter",
      StarterIcon = "mm_MS_Skylar",
      bInterior = false
    },
    {
      sName = "DonKing",
      sNode = "Missions\\freeplay\\FightClub\\EifelanEye\\starter",
      bInterior = false
    },
    {
      sName = "Spore_RS_Skylar",
      sNode = "Missions\\soe_2\\mission_2\\starter",
      StarterIcon = "mm_MS_Skylar",
      bInterior = false
    },
    {
      sName = "koenig_starter",
      sNode = "Missions\\freeplay\\country\\mis_koenig_destroy\\starter",
      bInterior = false
    },
    {
      sName = "dock_starter",
      sNode = "Missions\\freeplay\\country\\mis_dockdestruction\\starter",
      bInterior = false
    },
    {
      sName = "bishop_st306_ext",
      sNode = "Missions\\paris_2\\connect_st305_bishopmeeting\\bishopandcar",
      bInterior = false,
      StarterIcon = "mm_MS_Bishop"
    }
  }
  StarterManager.CreateStarterHideMasterList()
end

function StarterManager.LoadAllExteriorStarters()
  for i, tStarterTable in pairs(StarterManager.MasterList) do
    if not tStarterTable.bInterior and not StarterManager.Save_IsStarterHiddenList[tStarterTable.sName].bHidden then
      StarterManager.LoadStarterNode(tStarterTable.sName, nil, false)
    end
  end
end

function StarterManager.CleanStarterList()
  for key, value in pairs(StarterManager.Save_IsStarterHiddenList) do
    local hStarter = Handle(StarterManager.GetFullPath(key))
    if hStarter then
      StarterManager.Save_IsStarterHiddenList[key].bLoadingState = cSM_LOADED
    end
    if StarterManager.Save_IsStarterHiddenList[key].bLoadingState == cSM_NOTLOADING then
      StarterManager.Save_IsStarterHiddenList[key].bLoadingState = cSM_NOTLOADED
    end
  end
end

function StarterManager.LoadStarterNode(sStarter, oInteraction, bBuildFoundation, fCallback, self)
  local tStarter = StarterManager.GetStarterTable(sStarter)
  print("StarterManager.LoadStarterNode ", sStarter)
  if not tStarter then
    print("StarterManager.LoadStarterNode attempting to load a starter not listed instartermanager ", sStarter)
    return
  end
  if StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState == cSM_LOADED or StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState == cSM_LOADING then
  end
  local tInterior = InteriorManager.GetInteriorTable(tStarter.sInterior)
  if oInteraction and bBuildFoundation then
    StarterManager.AddInteractionTaskToList(sStarter, oInteraction)
  end
  if StarterManager.Save_IsStarterHiddenList[sStarter].bHidden then
    print("WARNING:: Activating a mission that has a hidden starter", sStarter)
    return
  end
  if StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState == cSM_LOADED then
    local hSanityCheck = Handle(StarterManager.GetFullPath(sStarter))
    if not hSanityCheck then
      print("ERROR: StarterManager:LoadStarterNode ", sStarter, " appears ready but is returning not loaded!")
      StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState = cSM_NOTLOADED
      return false
    end
  end
  if bBuildFoundation then
    if WorldSMEDNodes.LoadNode(tStarter.sNode, "StarterManager.CallbackStarterLoaded", nil, {sStarter}) then
      print("StarterManager.LoadStarterNode:: loading generic starter from StarterManager ", tStarter.sNode, " ", sStarter)
      StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState = cSM_LOADING
    elseif StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState == cSM_LOADED then
      print("StarterManager.LoadStarterNode:: This requested starter is already loaded ", sStarter)
      local hSanityCheck = Handle(StarterManager.GetFullPath(sStarter))
      if not hSanityCheck then
        print("ERROR: StarterManager:LoadStarterNode ", sStarter, " appears ready but is returning not loaded!")
        StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState = cSM_NOTLOADED
        return false
      else
        StarterManager.CallbackStarterLoaded(nil, sStarter)
        return true
      end
    elseif StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState == cSM_LOADING then
      print("StarterManager.LoadStarterNode:: This requested starter is in the process of being loaded ", tStarter.sName)
      return false
    else
      print("starter must be loaded already ?", sStarter, Handle(StarterManger.GetStarter(sStarter)))
    end
  else
    local fC, sTable
    if fCallback and self then
      fC = fCallback
      sTable = self
    else
      fC = "StarterManager.CallbackStarterLoaded"
      sTable = nil
      fCallback = fC
    end
    local hStarter = Util.GetHandleByName(StarterManager.GetFullPath(sStarter))
    if hStarter then
      StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState = cSM_LOADED
    elseif sStarter and StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState == cSM_LOADED and not hStarter then
      local sFail = "CFRENCH StarterManager.LoadStarterNode " .. sStarter .. " bLoadingState == cSM_LOADED but has a nil handle, croiky"
      Util.Assert(false, sFail)
    end
    if StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState ~= cSM_LOADED and StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState ~= cSM_LOADING then
      if WorldSMEDNodes.LoadNode(tStarter.sNode, fC, sTable, {sStarter}) then
        StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState = cSM_LOADING
      end
    elseif StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState == cSM_LOADED then
      StarterManager.CallbackStarterLoaded(nil, sStarter)
      return true
    elseif StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState == cSM_LOADING then
      print("StarterManager.LoadStarterNode::This requested starter is in the process of being loaded :", tStarter.sName)
      if sTable == nil then
        EVENT_Timer("StarterManager.LoadStarterNodeEventRetry", nil, 0.6, {sStarter})
      end
      return false
    end
  end
  return true
end

function StarterManager:LoadStarterNodeEventRetry(sStarter)
  print("StarterManager.LoadStarterNodeEventRetry ", sStarter)
  if sStarter then
    StarterManager.LoadStarterNode(sStarter)
  end
end

function StarterManager.LoadInteriorStarterNode(sStarter, oInteraction, bBuildFoundation, fCallback, self)
  local tStarter = StarterManager.GetStarterTable(sStarter)
  if not tStarter then
    print("ERROR::StarterManager.LoadInteriorStarterNode couldn't get table to starter", sStarter)
    return
  end
  local sStarterInterior = tStarter.sInterior
  local sPlayersInterior = Util.GetPlayersInterior()
  local tInteriorTable = InteriorManager.GetInteriorTable(sStarterInterior)
  local oInteriorname = __UtilFunctions.GetTableFromNameSpace(tInteriorTable.sScript)
  if not oInteriorname then
    print("error LoadInteriorStarterNode")
    return
  end
  if tStarter then
    if not StarterManager.Save_IsStarterHiddenList[sStarter].bHidden then
      local hStarter = Handle(StarterManager.GetFullPath(sStarter))
      if StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState == cSM_LOADED and not hStarter then
        local sMessage = sStarter .. " is marked as loaded but is not really LoadInteriorStarterNode"
        print(sMessage)
        StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState = cSM_NOTLOADED
      end
      local oInteraction = StarterManager.GetInteractionTaskFromList(sStarter)
      local tStarter = StarterManager.GetStarterTable(sStarter)
      if tStarter and tStarter.sNode then
        oInteriorname:LoadDynamicNode(tStarter.sNode)
        if StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState == nil or StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState == cSM_NOTLOADED then
          if oInteraction then
          end
          if sPlayersInterior ~= sStarterInterior then
            Util.AddInteriorLoadCallback(oInteriorname.sInteriorTableName, "StarterManager.CallbackStarterLoaded", nil, {sStarter}, true)
          else
            EVENT_Stream("StarterManager.CallbackStarterLoaded", nil, {
              StarterManager.GetStarterWithPath(sStarter)
            }, false, {sStarter})
          end
          StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState = cSM_LOADING
        elseif StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState == cSM_LOADED then
          print("StarterManager.LoadInteriorStarterNode", sStarter, " is loaded already")
          StarterManager.CallbackStarterLoaded(nil, sStarter)
        end
      end
    elseif StarterManager.tInteractionList and StarterManager.tInteractionList[tStarter.sName] then
      print("ERROR::cfrench  InteriorManager.LoadWaitingInteriorStarters error" .. tStarter.sName)
    end
  end
end

function StarterManager:CallbackStarterLoaded(sStarter)
  local tConfig
  if not sStarter then
    print("ERROR:: StarterManager.CallbackStarterLoaded sStarter is nil")
    return
  end
  print("StarterManager.CallbackStarterLoaded:: starter loaded ", sStarter)
  local tStarter = StarterManager.GetStarterTable(sStarter)
  if not tStarter then
    print("ERROR:: StarterManager.CallbackStarterLoaded tStarter is nil")
    return
  end
  if not StarterManager.Save_IsStarterHiddenList[sStarter] then
    print("ERROR:: StarterManager.CallbackStarterLoaded Save_IsStarterHiddenList[ sStarter ] is nil")
    return
  end
  StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState = cSM_LOADED
  local oInteraction = StarterManager.GetInteractionTaskFromList(sStarter)
  if oInteraction and not oInteraction:IsActive() and not oInteraction:IsCompleted() then
    print("CallbackStarterLoaded : Building foundation ", sStarter)
    if oGameMaster.oActiveGameplayMission then
      print("ERROR: STARTING A MISSION WHILE ANOTHER MISSION IS ACTIVE , StarterManager.CallbackStarterLoaded")
      return
    end
    oInteraction:BuildFoundation()
  elseif oInteraction and oInteraction:IsActive() then
    print("CallbackStarterLoaded: oInteraction is already active, ignoring", sStarter)
  elseif oInteraction and oInteraction:IsCompleted() then
    print("CallbackStarterLoaded: oInteraction is already completed, ignoring", sStarter)
  end
end

function StarterManager.UnloadStarterNode(sStarter, bForceUnload)
  local tStarter = StarterManager.GetStarterTable(sStarter)
  if WorldSMEDNodes.UnloadNode(tStarter.sNode, bForceUnload) then
    if tStarter.oInteraction and tStarter.oInteraction:IsActive() then
      tStarter.oInteraction:ResetThisTask(true, false, false)
    end
    tStarter.oInteraction = nil
    StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState = cSM_UNLOADED
    return true
  end
  return false
end

function StarterManager.ReleaseInteriorStarterNode(sStarter)
  print("releasing interior starter ", sStarter)
  local tStarter = StarterManager.GetStarterTable(sStarter)
  if tStarter and tStarter.bInterior then
    local tInteriorTable = InteriorManager.GetInteriorTable(tStarter.sInterior)
    if tInteriorTable and tInteriorTable.sScript then
      local oModule = __UtilFunctions.GetTableFromNameSpace(tInteriorTable.sScript)
      if oModule and oModule.OnEnterInterior and tStarter.sNode then
        oModule:ReleaseDynamicNode(tStarter.sNode)
        StarterManager.Save_IsStarterHiddenList[sStarter].bLoadingState = cSM_UNLOADED
      end
    end
  end
end

function StarterManager.GetFullPath(sStarter)
  local tStarterTable = StarterManager.GetStarterTable(sStarter)
  if tStarterTable then
    return tStarterTable.sNode .. "\\" .. tStarterTable.sName
  end
  return nil
end

function StarterManager.GetStarterTable(sStarter)
  for _, tStarterTable in pairs(StarterManager.MasterList) do
    if tStarterTable.sName == sStarter then
      return tStarterTable
    end
  end
  return nil
end

function StarterManager.GetStarterWithPath(sStarter)
  local tSTable = StarterManager.GetStarterTable(sStarter)
  local fullpath = tSTable.sNode .. "\\" .. tSTable.sName
  return fullpath
end

function StarterManager.GetStarterIcon(sStarter)
  local tSTable = StarterManager.GetStarterTable(sStarter)
  if not tSTable.StarterIcon then
    return "mm_Luke"
  end
  return tSTable.StarterIcon
end

function StarterManager.GetPathFromObject(sFullNodeName)
  local path, thing
  print("sFUllnode ", sFullNodeName)
  local index = string.find(sFullNodeName, "[\"\\\"$]", -1)
  print("index ", index)
  path = string.sub(sFullNodeName, 1, index - 1)
  thing = string.sub(sFullNodeName, index)
  print("path ", path, "thing ", thing)
  return path
end

function StarterManager.RequestStarter(sStarter)
  local tStarter = StarterManager.GetStarterTable(sInterior)
  tStarter.TotalEnabled = tStarter.TotalEnabled + 1
end

function StarterManager.FinishedWithStarter(sStarter)
  local tStarter = StarterManager.GetStarterTable(sStarter)
  tStarter.TotalEnabled = tStarter.TotalEnabled - 1
end

function StarterManager.HideStarter(sStarter, bHide, bForceUnload, bDebugDelayLoad)
  local tStarter = StarterManager.GetStarterTable(sStarter)
  if not tStarter then
    Util.Assert(false, "StarterManager.HideStarter attempting to load a starter not listed instartermanager " .. sStarter)
    print("StarterManager.HideStarter attempting to load a starter not listed instartermanager ", sStarter)
    return
  end
  StarterManager.Save_IsStarterHiddenList[sStarter].bHidden = bHide
  if __RETURNTOHQSTART then
    return
  end
  if bHide then
    if not bDebugDelayLoad then
      if tStarter.bInterior and not bForceUnload then
        print("StarterManager: releasing ", sStarter)
        StarterManager.ReleaseInteriorStarterNode(sStarter)
      elseif not tStarter.bInterior then
        StarterManager.UnloadStarterNode(sStarter, bForceUnload)
      elseif tStarter.bInterior then
      end
    end
  elseif not tStarter.bInterior and not bDebugDelayLoad then
    print("StarterManager.HideStarter ****** loading exterior starter ", sStarter)
    StarterManager.LoadStarterNode(sStarter)
  end
end

function StarterManager.CreateStarterHideMasterList()
  local count = 0
  for key, value in pairs(StarterManager.MasterList) do
    StarterManager.Save_IsStarterHiddenList[value.sName] = {bHidden = true, bLoadingState = cSM_NOTLOADED}
    count = count + 1
  end
  print("StarterManager.CreateStarterHideMasterList:: There are ", count, " starters designated")
end

StarterManager.StarterHierarchy = {}

function StarterManager.SetStarterState(sMissionName)
end

function StarterManager.SetInteractionToStarterTable(sStarter, oInteraction)
  local tStarter = StarterManager.GetStarterTable(sStarter)
  if not oInteraction then
    print("ERROR - no interaction given to starter LoadStarterNode")
  end
  tStarter.oInteraction = oInteraction
end

function StarterManager.GetInteractionFromStarterTable(sStarter)
  local tStarter = StarterManager.GetStarterTable(sStarter)
  if not tStarter then
    print("ERROR - no starter table ", sStarter)
    return
  end
  return tStarter.oInteraction
end

function StarterManager.AddInteractionTaskToList(sStarter, oInteractTask)
  if StarterManager.tInteractionList then
    if StarterManager.tInteractionList[sStarter] ~= nil then
      print("StarterManager.AddInteractionTaskToList already has starter interaction set ", sStarter)
    else
      print("StarterManager.AddInteractionTaskToList ", sStarter, oInteractTask)
      StarterManager.tInteractionList[sStarter] = oInteractTask
    end
  end
end

function StarterManager.RemoveInteractionTask(sStarter)
  if StarterManager.tInteractionList and StarterManager.tInteractionList[sStarter] then
    print("StarterManager.RemoveInteractionTask ", sStarter)
    StarterManager.tInteractionList[sStarter] = nil
  end
end

function StarterManager.GetInteractionTaskFromList(sStarter)
  if StarterManager.tInteractionList and StarterManager.tInteractionList[sStarter] then
    print("StarterManager.GetInteractionTaskFromList ", sStarter)
    return StarterManager.tInteractionList[sStarter]
  end
end
