if InteriorManager == nil then
  InteriorManager = {}
  InteriorManager.InteriorList = {}
  InteriorManager.CallbackLoadedList = {}
  _ICONSTATE_REQUESTED = 1
  _ICONSTATE_ACTIVE = 2
end
require("Includes\\__UtilFunctions")

function InteriorManager.InitList()
  InteriorManager.InteriorList = {
    {
      sName = "RedOx",
      sScript = "RedOx_Interior",
      GlobalObjFrameID = 0,
      sExteriorLoc = "CountrySide\\alsace\\town\\interior\\redox_ext\\ext_blip_loc\\LOC_RO_Blip_Ext",
      sExtLocNode = "CountrySide\\alsace\\town\\interior\\redox_ext\\ext_blip_loc",
      sInteriorLoc = "",
      sIntLocNode = "",
      sIntTeleLoc = "CountrySide\\alsace\\town\\interior\\redox_int\\LOC_RO_Int",
      sExtTeleLoc = "CountrySide\\alsace\\town\\interior\\redox_ext\\LOC_RO_Ext",
      TotalEnabledExt = 0,
      TotalEnabledInt = 0,
      bExtLocLoaded = false,
      bIntLocLoaded = false,
      sWTFBP = "WillToFight_INT_RedOx",
      bHide = false,
      bUnlocked = true,
      tFloors = {
        {
          fRangeLow = 0,
          fRangeHi = 204.08,
          fAreaSize = 64,
          fPosX = 2621.03,
          fPosZ = -2504.08
        },
        {
          fRangeLow = 204.08,
          fRangeHi = 1000,
          fAreaSize = 64,
          fPosX = 2621.03,
          fPosZ = -2504.08
        }
      }
    },
    {
      sName = "Belle",
      sScript = "Belle_Interior",
      GlobalObjFrameID = 0,
      sExteriorLoc = "PARIS\\area01\\belledenuit\\interior\\hq_ext\\ext_blip_loc\\LOC_Belle_ext",
      sExtLocNode = "PARIS\\area01\\belledenuit\\interior\\hq_ext\\ext_blip_loc",
      sInteriorLoc = "",
      sIntLocNode = "",
      sIntTeleLoc = "PARIS\\area01\\belledenuit\\interior\\hq_int\\LOC_Belle_int",
      sIntTeleLoc2 = "PARIS\\area01\\belledenuit\\interior\\hq_int\\LOC_Belle_int_Two",
      sExtTeleLoc = "PARIS\\area01\\belledenuit\\interior\\hq_ext\\LOC_Teleport_Ext",
      sExtTeleLoc2 = "PARIS\\area01\\belledenuit\\interior\\hq_ext\\LOC_Teleport_Ext_Two",
      TotalEnabledExt = 0,
      TotalEnabledInt = 0,
      bExtLocLoaded = false,
      bIntLocLoaded = false,
      bHide = false,
      bUnlocked = true,
      bHQ = true,
      StarterIcons = {},
      sHQPoint = _cHQ_BELLE,
      tFloors = {
        {
          fRangeLow = 0,
          fRangeHi = 262.25,
          fAreaSize = 96,
          fPosX = -68.49,
          fPosZ = -776.38
        },
        {
          fRangeLow = 262.25,
          fRangeHi = 1000,
          fAreaSize = 96,
          fPosX = -68.49,
          fPosZ = -776.38
        }
      }
    },
    {
      sName = "Belle_Destroyed",
      sScript = "Belle_Interior_Destroyed",
      GlobalObjFrameID = 0,
      sExteriorLoc = "PARIS\\area01\\belledenuit\\interior\\hq_ext\\ext_blip_loc\\LOC_Belle_ext",
      sExtLocNode = "PARIS\\area01\\belledenuit\\interior\\hq_ext\\ext_blip_loc",
      sInteriorLoc = "",
      sIntLocNode = "",
      sIntTeleLoc = "PARIS\\area01\\belledenuit\\interior\\int_belledestoyed\\LOC_Int_Tele1",
      sExtTeleLoc = "PARIS\\area01\\belledenuit\\interior\\hq_ext\\LOC_Teleport_Ext",
      TotalEnabledExt = 0,
      TotalEnabledInt = 0,
      bExtLocLoaded = false,
      bIntLocLoaded = false,
      bHide = false,
      bUnlocked = true,
      bHQ = true,
      StarterIcons = {},
      tFloors = {
        {
          fRangeLow = 0,
          fRangeHi = 262.25,
          fAreaSize = 96,
          fPosX = -68.49,
          fPosZ = -776.38
        },
        {
          fRangeLow = 262.25,
          fRangeHi = 1000,
          fAreaSize = 96,
          fPosX = -68.49,
          fPosZ = -776.38
        }
      }
    },
    {
      sName = "LaVillette",
      sScript = "LaVillette_Interior",
      GlobalObjFrameID = "",
      sInteriorLoc = "",
      sIntLocNode = "",
      sExteriorLoc = "PARIS\\area01\\lavillette\\interior\\lavillette_ext\\ext_blip_loc\\LOC_LV_Blip_Ext",
      sExtLocNode = "PARIS\\area01\\lavillette\\interior\\lavillette_ext\\ext_blip_loc",
      sIntTeleLoc = "PARIS\\area01\\lavillette\\interior\\lavillette_int\\LOC_LV_Int",
      sExtTeleLoc = "PARIS\\area01\\lavillette\\interior\\lavillette_ext\\LOC_LV_Ext",
      TotalEnabledExt = 0,
      TotalEnabledInt = 0,
      bExtLocLoaded = false,
      bIntLocLoaded = false,
      sWTFBP = "WillToFight_HQ_LaVillette",
      bHide = false,
      bUnlocked = false,
      bHQ = true,
      StarterIcons = {},
      sHQPoint = _cHQ_LAVILLETTE,
      tFloors = {
        {
          fRangeLow = 0,
          fRangeHi = 300,
          fAreaSize = 64,
          fPosX = 762.62,
          fPosZ = -729.32
        }
      }
    },
    {
      sName = "HDV",
      sScript = "Hotel_Interior",
      GlobalObjFrameID = "",
      sExteriorLoc = "PARIS\\area06\\hoteldeville\\interior\\hdv_ext\\ext_blip_loc\\LOC_Hotel_Ext",
      sExtLocNode = "PARIS\\area06\\hoteldeville\\interior\\hdv_ext\\ext_blip_loc",
      sIntTeleLoc = "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\LOC_LV_Int",
      TotalEnabledExt = 0,
      TotalEnabledInt = 0,
      bExtLocLoaded = false,
      bIntLocLoaded = false,
      bHide = false,
      bUnlocked = false,
      tFloors = {
        {
          fRangeLow = 248.15,
          fRangeHi = 1000,
          fAreaSize = 96,
          fPosX = 109.58,
          fPosZ = 113.61
        },
        {
          fRangeLow = 242.12,
          fRangeHi = 248.18,
          fAreaSize = 96,
          fPosX = 109.58,
          fPosZ = 113.61
        },
        {
          fRangeLow = 234,
          fRangeHi = 242.14,
          fAreaSize = 96,
          fPosX = 109.58,
          fPosZ = 113.61,
          fDimension = 40
        },
        {
          fRangeLow = 234,
          fRangeHi = 242.14,
          fAreaSize = 96,
          fPosX = 128.03,
          fPosZ = 63.01,
          fDimension = 60
        },
        {
          fRangeLow = 234,
          fRangeHi = 242.14,
          fAreaSize = 96,
          fPosX = 168.1,
          fPosZ = 40.62,
          fDimension = 60
        },
        {
          fRangeLow = 0,
          fRangeHi = 234.1,
          fAreaSize = 96,
          fPosX = 91.22,
          fPosZ = 85.26,
          fDimension = 60
        },
        {
          fRangeLow = 0,
          fRangeHi = 234.1,
          fAreaSize = 96,
          fPosX = 104.59,
          fPosZ = 58.57,
          fDimension = 60
        }
      }
    },
    {
      sName = "Boulogne",
      sScript = "Boulogne_Interior",
      GlobalObjFrameID = "",
      sExteriorLoc = "PARIS\\area02\\boisdeboulogne\\hq\\boulogne_ext\\ext_blip_loc\\LOC_BOL_Blip_Ext",
      sExtLocNode = "PARIS\\area02\\boisdeboulogne\\hq\\boulogne_ext\\ext_blip_loc",
      sIntTeleLoc = "PARIS\\area02\\boisdeboulogne\\hq\\boulogne_int\\LOC_BOL_Int",
      sExtTeleLoc = "PARIS\\area02\\boisdeboulogne\\hq\\boulogne_ext\\LOC_BOL_Ext",
      sWTFBP = "WillToFight_HQ_BoisDeBouglone",
      TotalEnabledExt = 0,
      TotalEnabledInt = 0,
      bExtLocLoaded = false,
      bIntLocLoaded = false,
      bHide = false,
      bUnlocked = false,
      sHQPoint = _cHQ_BOLOUGNE,
      bHQ = true,
      StarterIcons = {},
      tFloors = {
        {
          fRangeLow = 0,
          fRangeHi = 300,
          fAreaSize = 90,
          fPosX = -1358.07,
          fPosZ = -553.5
        }
      }
    },
    {
      sName = "Catacombs",
      sScript = "Catacombs_Interior",
      GlobalObjFrameID = "",
      sExteriorLoc = "PARIS\\area03\\catacombs\\catacombshq_ex\\ext_blip_loc\\LOC_Cat_Blip_Ext",
      sExtLocNode = "PARIS\\area03\\catacombs\\catacombshq_ex\\ext_blip_loc",
      sIntTeleLoc = "PARIS\\area03\\catacombs\\hq\\LOC_Cat_Int",
      sExtTeleLoc = "PARIS\\area03\\catacombs\\catacombshq_ex\\LOC_Cat_Ext",
      TotalEnabledExt = 0,
      TotalEnabledInt = 0,
      bExtLocLoaded = false,
      bIntLocLoaded = false,
      bHide = false,
      bUnlocked = false,
      bHQ = true,
      StarterIcons = {},
      sHQPoint = _cHQ_CATACOMBS,
      tFloors = {
        {
          fRangeLow = 0,
          fRangeHi = 1000,
          fAreaSize = 128,
          fPosX = -688.07,
          fPosZ = 548
        }
      }
    },
    {
      sName = "LeHavre",
      sScript = "LeHavreHQ_Interior",
      sExteriorLoc = "LeHavre\\lehavre_hq_ext\\ext_blip_loc\\LOC_LH_Blip_Ext",
      sExtLocNode = "LeHavre\\lehavre_hq_ext\\ext_blip_loc",
      sIntTeleLoc = "LeHavre\\lehavre_hq\\LOC_LV_Int",
      sExtTeleLoc = "LeHavre\\lehavre_hq_ext\\LOC_LH_Ext",
      TotalEnabledExt = 0,
      TotalEnabledInt = 0,
      bExtLocLoaded = false,
      bIntLocLoaded = false,
      sWTFBP = "WillToFight_HQ_Church",
      bHide = false,
      sHQPoint = _cHQ_CHURCH,
      bUnlocked = false,
      bHQ = true,
      StarterIcons = {},
      tFloors = {
        {
          fRangeLow = 0,
          fRangeHi = 1000,
          fAreaSize = 96,
          fPosX = -1019.85,
          fPosZ = -2130.13
        }
      }
    },
    {
      sName = "LeHavreHotel",
      sScript = "LeHavreHotel_Interior",
      sExteriorLoc = "LeHavre\\lehavre_hotel_ext\\ext_blip_loc\\LOC_LHT_Blip_Ext",
      sExtLocNode = "LeHavre\\lehavre_hotel_ext\\ext_blip_loc",
      sIntTeleLoc = "LeHavre\\int_hotel_skylar\\LOC_LH_Int",
      sExtTeleLoc = "LeHavre\\lehavre_hotel_ext\\LOC_LHT_Ext",
      TotalEnabledExt = 0,
      TotalEnabledInt = 0,
      bExtLocLoaded = false,
      bIntLocLoaded = false,
      sWTFBP = "WillToFight_HQ_Church",
      bHide = false,
      bUnlocked = false,
      StarterIcons = {},
      tFloors = {
        {
          fRangeLow = 0,
          fRangeHi = 1000,
          fAreaSize = 32,
          fPosX = -1087.9,
          fPosZ = -2112.84
        }
      }
    },
    {
      sName = "Zeppelin",
      sScript = "Zeppelin_Int",
      sInteriorLoc = "",
      sIntLocNode = "",
      sIntTeleLoc = "Missions\\soe_1\\zeppelin\\main_zep\\LOC_IntZepTele",
      sExtTeleLoc = "Missions\\soe_1\\zeppelin\\main_citadel\\LOC_DumpSeanExit",
      TotalEnabledExt = 0,
      TotalEnabledInt = 0,
      bExtLocLoaded = false,
      bIntLocLoaded = false,
      sWTFBP = "WillToFight_INT_Zepplin_Interior",
      bHide = false,
      bUnlocked = false,
      tFloors = {
        {
          fRangeLow = 0,
          fRangeHi = 1000,
          fAreaSize = 210,
          fPosX = -1588.82,
          fPosZ = -2298.8
        }
      }
    },
    {
      sName = "Pantheon",
      sScript = "Pantheon_Interior",
      TotalEnabledExt = 0,
      TotalEnabledInt = 0,
      bExtLocLoaded = false,
      bIntLocLoaded = false,
      bHide = false,
      bUnlocked = false,
      tFloors = {
        {
          fRangeLow = 0,
          fRangeHi = 496.86,
          fAreaSize = 224,
          fPosX = -207.36,
          fPosZ = 508.37
        },
        {
          fRangeLow = 496.86,
          fRangeHi = 510,
          fAreaSize = 160,
          fPosX = -189.1,
          fPosZ = 528.21
        },
        {
          fRangeLow = 510,
          fRangeHi = 1000,
          fAreaSize = 96,
          fPosX = -186.34,
          fPosZ = 527.67
        }
      }
    },
    {
      sName = "SaarHQ",
      sScript = "SaarHQ_Interior",
      sExteriorLoc = "CountrySide\\alsace\\town\\interior\\int_saar_hotel_ext\\ext_blip_loc\\LOC_Saar_Blip_Ext",
      sExtLocNode = "CountrySide\\alsace\\town\\interior\\int_saar_hotel_ext\\ext_blip_loc",
      sIntTeleLoc = "CountrySide\\alsace\\town\\interior\\int_saar_hotel\\LOC_SaarHQ_Int",
      sExtTeleLoc = "CountrySide\\alsace\\town\\interior\\int_saar_hotel_ext\\LOC_SaarHQ_Ext",
      TotalEnabledExt = 0,
      TotalEnabledInt = 0,
      bExtLocLoaded = false,
      bIntLocLoaded = false,
      sWTFBP = "WillToFight_INT_Hotel_Saarbruken",
      bHide = false,
      bUnlocked = false,
      bHQ = true,
      StarterIcons = {},
      tFloors = {}
    }
  }
end

function InteriorManager.GetInteriorTable(sInterior)
  for _, tInteriorTable in pairs(InteriorManager.InteriorList) do
    if tInteriorTable.sName == sInterior then
      return tInteriorTable
    end
  end
  if DLC_InteriorManager and DLC_InteriorManager.InteriorList then
    for _, tInteriorTable in pairs(DLC_InteriorManager.InteriorList) do
      if tInteriorTable.sName == sInterior then
        return tInteriorTable
      end
    end
  end
  return nil
end

function InteriorManager.GetInteriorTableByScript(sInteriorScript)
  for _, tInteriorTable in pairs(InteriorManager.InteriorList) do
    if tInteriorTable.sScript == sInteriorScript then
      return tInteriorTable
    end
  end
  if DLC_InteriorManager and DLC_InteriorManager.InteriorList then
    for _, tInteriorTable in pairs(DLC_InteriorManager.InteriorList) do
      if tInteriorTable.sScript == sInteriorScript then
        return tInteriorTable
      end
    end
  end
  return nil
end

function InteriorManager.RequestExteriorBlip(sInterior, mmStarterIcon)
  local tInterior = InteriorManager.GetInteriorTable(sInterior)
  tInterior.TotalEnabledExt = tInterior.TotalEnabledExt + 1
  InteriorManager.AddStarterIcon(sInterior, mmStarterIcon, _ICONSTATE_REQUESTED)
  InteriorManager.UpdateExteriorBlips()
end

function InteriorManager.RequestInteriorBlip(sInterior)
  local tInterior = InteriorManager.GetInteriorTable(sInterior)
  tInterior.TotalEnabledInt = tInterior.TotalEnabledInt + 1
  InteriorManager.UpdateInteriorBlips()
end

function InteriorManager.FinishedWithExteriorBlip(sInterior, sStarterIcon)
  local tInterior = InteriorManager.GetInteriorTable(sInterior)
  if tInterior.TotalEnabledExt > 0 then
    tInterior.TotalEnabledExt = tInterior.TotalEnabledExt - 1
    InteriorManager.UpdateExteriorBlips()
  end
  if sStarterIcon then
    InteriorManager.RemoveStarterIcon(sInterior, sStarterIcon)
  end
end

function InteriorManager.FinishedWithInteriorBlip(sInterior)
  local tInterior = InteriorManager.GetInteriorTable(sInterior)
  if tInterior.TotalEnabledInt > 0 then
    tInterior.TotalEnabledINt = tInterior.TotalEnabledInt - 1
    InteriorManager.UpdateInteriorBlips()
  end
end

function InteriorManager._CallbackStarterEscOnEscalation()
  SabTask:ToggleHQBlipMarkers(false)
  if InteriorManager._eGlobalEscalationFreeEvent then
    Util.KillEvent(InteriorManager._eGlobalEscalationFreeEvent)
  end
  InteriorManager._eGlobalEscalationFreeEvent = EVENT_EscalationFree("InteriorManager._CallbackStarterEscOnEscalationFree", nil, {}, false)
end

function InteriorManager._CallbackStarterEscOnEscalationFree()
  SabTask:ToggleHQBlipMarkers(true)
  InteriorManager:_SetupEscalationDenial()
end

function InteriorManager._SetupEscalationDenial()
  local CurrentEscalation = Suspicion.GetEscalation()
  if 0 < CurrentEscalation then
    self:_CallbackStarterEscOnEscalation()
  else
    if InteriorManager._eGlobalEscalationEvent then
      Util.KillEvent(InteriorManager._eGlobalEscalationEvent)
    end
    InteriorManager._eGlobalEscalationEvent = EVENT_OnEscalation("InteriorManager._CallbackStarterEscOnEscalation", nil, {})
  end
end

function InteriorManager._CleanInteriorEscalationEvents()
  if InteriorManager._eGlobalEscalationEvent then
    Util.KillEvent(InteriorManager._eGlobalEscalationEvent)
    InteriorManager._eGlobalEscalationEvent = nil
  end
  if InteriorManager._eGlobalEscalationFreeEvent then
    Util.KillEvent(InteriorManager._eGlobalEscalationFreeEvent)
    InteriorManager._eGlobalEscalationFreeEvent = nil
  end
end

function InteriorManager.AddStarterIcon(sInterior, mmStarterIcon, state)
  if not mmStarterIcon then
    return
  end
  for i, tInteriorTable in pairs(InteriorManager.InteriorList) do
    if tInteriorTable.sName == sInterior and tInteriorTable.StarterIcons and mmStarterIcon then
      if tInteriorTable.StarterIcons[mmStarterIcon] and state < tInteriorTable.StarterIcons[mmStarterIcon] then
        return
      end
      tInteriorTable.StarterIcons[mmStarterIcon] = state
      print("adding starter icon ", mmStarterIcon, state)
    end
  end
end

function InteriorManager.RemoveStarterIcon(sInterior, mmStarterIcon)
  for i, tInteriorTable in pairs(InteriorManager.InteriorList) do
    if tInteriorTable.sName == sInterior and tInteriorTable.StarterIcons and mmStarterIcon and tInteriorTable.StarterIcons[mmStarterIcon] then
      print("clear starter icon ", mmStarterIcon)
      tInteriorTable.StarterIcons[mmStarterIcon] = nil
    end
  end
end

function InteriorManager.IsStarterIconActive(sInterior, mmStarterIcon)
  if not mmStarterIcon then
    return
  end
  for i, tInteriorTable in pairs(InteriorManager.InteriorList) do
    if tInteriorTable.sName == sInterior and tInteriorTable.StarterIcons and mmStarterIcon and tInteriorTable.StarterIcons[mmStarterIcon] == _ICONSTATE_ACTIVE then
      return true
    end
  end
  return false
end

function InteriorManager.OnEnterInterior(sInterior)
  local tSabSelf = Actor.GetSelf(hSab)
  tSabSelf.bInInterior = true
  tSabSelf.sPlayersCurrentInterior = sInterior
  InteriorManager.SetHUDInfo()
  EVENT_Timer("SabTask.ToggleMarkers", nil, 0.3)
  Util.EnableGooseSteppers(false)
  Util.EnableSuperSpores(false)
  Train.TrainSystemEnable(false)
  if sInterior then
    local tInterior = InteriorManager.GetInteriorTable(sInterior)
    if tInterior and tInterior.bHQ then
      Util.SetPlayerAtHQ(true)
      Util.AddInteriorLoadCallback(sInterior, "InteriorManager.CallbackCreateDoorFocusPt", nil)
    end
  end
end

function InteriorManager.OnExitInterior(bDisableSuperSpores)
  InteriorManager.ClearDoorFocusPt(InteriorManager.GetPlayersInterior())
  local tSabSelf = Actor.GetSelf(hSab)
  tSabSelf.bInInterior = false
  tSabSelf.sPlayersCurrentInterior = ""
  Suspicion.EnableEscalation(true)
  InteriorManager.SetHUDInfo()
  EVENT_Timer("SabTask.ToggleMarkers", nil, 0.3)
  Util.EnableGooseSteppers(true)
  Util.EnableSuperSpores(not bDisableSuperSpores)
  Util.SetPlayerAtHQ(false)
  Train.TrainSystemEnable(true)
end

function InteriorManager.CallbackCreateDoorFocusPt()
  local tInterior = InteriorManager.GetInteriorTable(InteriorManager.GetPlayersInterior())
  if tInterior and tInterior.sIntTeleLoc then
    local hLoc = Handle(tInterior.sIntTeleLoc)
    if hLoc then
      tInterior.IntFocusPointID = FocusPt.Create(0, 0, 0, 50, 10, true, false, hLoc)
    end
  end
end

function InteriorManager.ClearDoorFocusPt(sInterior)
  local tInterior = InteriorManager.GetInteriorTable(sInterior)
  if tInterior and tInterior.IntFocusPointID then
    FocusPt.Delete(tInterior.IntFocusPointID)
  end
end

function InteriorManager.UpdateExteriorBlips()
  local tSabSelf = Actor.GetSelf(hSab)
  for i, tInterior in pairs(InteriorManager.InteriorList) do
    if tInterior.TotalEnabledExt > 0 and not tInterior.bExtLocLoaded then
    elseif tInterior.TotalEnabledExt > 0 and tInterior.bExtLocLoaded then
      InteriorManager.SetHUDInfo()
    elseif tInterior.TotalEnabledExt <= 0 and tInterior.bExtLocLoaded then
      tInterior.TotalEnabledExt = 0
      InteriorManager.CleanupLocator(tInterior.sName)
    end
  end
end

function InteriorManager.UpdateInteriorBlips()
  local tSabSelf = Actor.GetSelf(hSab)
  for i, tInterior in pairs(InteriorManager.InteriorList) do
    if tInterior.TotalEnabledInt > 0 and not tInterior.bIntLocLoaded then
      if WorldSMEDNodes.LoadNode(tInterior.sIntLocNode, "InteriorManager.LocatorLoaded", nil, {
        tInterior.sName
      }) then
      end
    elseif tInterior.TotalEnabledInt <= 0 and tInterior.bIntLocLoaded then
      tInterior.bIntLocLoaded = false
      tInterior.TotalEnabledInt = 0
      if WorldSMEDNodes.UnloadNode(tInterior.sIntLocNode) then
        InteriorManager.CleanupLocator(tInterior.sName)
      end
    end
  end
end

function InteriorManager:LocatorLoaded(sInterior)
  local tInterior = InteriorManager.GetInteriorTable(sInterior)
  if not tInterior then
    return
  end
  tInterior.bExtLocLoaded = true
  InteriorManager.SetHUDInfo()
end

function InteriorManager.FocusLocator(sInterior, bHide)
  local tInterior = InteriorManager.GetInteriorTable(sInterior)
  local bOn = not bHide
  local hLoc = Util.GetHandleByName(tInterior.sExteriorLoc)
  if hLoc and tInterior.bHQ then
    local bExteriorFocusPt = true
    if not tInterior.bHasFocusPt then
      local tSabSelf = Actor.GetSelf(hSab)
      local bStartActive = true
      if tSabSelf.bInInterior then
        bStartActive = false
      end
      tInterior.FocusPointID = FocusPt.Create(0, 0, 0, 50, 50, bStartActive, bExteriorFocusPt, hLoc)
      tInterior.bHasFocusPt = true
      if not tInterior.GlobalObjFrameID or tInterior.GlobalObjFrameID == "" or tInterior.FocusPointID then
      end
      InteriorManager.ToggleFocus()
    end
  elseif not hLoc then
    print("WARNING:: hLoc is nil in InteriorManager.FocusLocator, could not create focus point for ", tInterior.sExteriorLoc)
  end
end

function InteriorManager.BlipLocator(a_nil, sInterior, mmStarterIcon, bHide, attempts)
  local tInterior = InteriorManager.GetInteriorTable(sInterior)
  local hLoc = Util.GetHandleByName(tInterior.sExteriorLoc)
  local bOn = not bHide
  local bSuccess = false
  if hLoc then
    if tInterior and bOn and tInterior.TotalEnabledExt > 0 and not InteriorManager.IsStarterIconActive(sInterior, mmStarterIcon) then
      local bExtHQBlip = true
      if mmStarterIcon then
        print("starter icon ", mmStarterIcon)
        bSuccess = HUD.SetObjectiveMarker(hLoc, cMMI_MissionGiver, cOM_MissionGiver, false, false, true, 2.5, mmStarterIcon)
      else
        bExtHQBlip = false
        bSuccess = HUD.SetObjectiveMarker(hLoc, cMMI_Objective, cOM_Goto, false, false, true)
      end
      if bSuccess then
        SabTask:AddMarker(hLoc, tInterior.sExteriorLoc, true, false, bOn, bExtHQBlip, sInterior)
      elseif attempts then
        attempts = attempts + 1
        if attempts < 11 then
          EVENT_Timer("InteriorManager.BlipLocator", self, 0.5, {
            sInterior,
            mmStarterIcon,
            bHide,
            attempts
          })
        else
          Util.Assert(false, "CFrench:InteriorManager.BlipLocator failed to creat a blip after " .. attempts .. " attempts")
          print("CFrench:InteriorManager.BlipLocator failed to creat a blip after " .. attempts .. " attempts")
        end
      end
      if mmStarterIcon then
        InteriorManager.AddStarterIcon(sInterior, mmStarterIcon, _ICONSTATE_ACTIVE)
      end
    end
    if InteriorManager.IsStarterIconActive(sInterior, mmStarterIcon) then
      SabTask.UpdateMarkerTable(nil, hLoc, bOn)
      EVENT_Timer("SabTask.ToggleMarkers", nil, 0.3)
    end
  else
    print("WARNING:: hLoc is nil in InteriorManager.BlipLocator, could not create focus point for ", tInterior.sExteriorLoc)
  end
end

function InteriorManager.CleanupLocator(sInterior, bInterior)
  local tInterior = InteriorManager.GetInteriorTable(sInterior)
  local hLoc
  if bInterior then
    hLoc = Util.GetHandleByName(tInterior.sInteriorLoc)
  else
    hLoc = Util.GetHandleByName(tInterior.sExteriorLoc)
  end
  if tInterior.FocusPointID then
    FocusPt.Delete(tInterior.FocusPointID)
    tInterior.bHasFocusPt = false
    tInterior.FocusPointID = nil
  end
  if hLoc then
    tInterior.bHasMarker = false
    SabTask:RemoveMarker(hLoc)
    HUD.RemoveObjectiveMarker(hLoc)
  end
end

function InteriorManager.LoadAllExteriorBlips()
  for i, tInterior in pairs(InteriorManager.InteriorList) do
    if not tInterior.sExtLocNode or WorldSMEDNodes.LoadNode(tInterior.sExtLocNode, "InteriorManager.LocatorLoaded", nil, {
      tInterior.sName
    }) then
    end
  end
  if not InteriorManager._eGlobalEscalationEvent then
    InteriorManager:_SetupEscalationDenial()
  end
end

function InteriorManager.SetHUDInfo()
  local tSabSelf = Actor.GetSelf(hSab)
  local bHide
  if tSabSelf.bInInterior then
    bHide = true
  else
    bHide = false
  end
  for i, tInterior in pairs(InteriorManager.InteriorList) do
    if tInterior.bExtLocLoaded then
      tInterior.bHide = false
      if tInterior.StarterIcons then
        for mmStarterIcon, state in pairs(tInterior.StarterIcons) do
          InteriorManager.BlipLocator(nil, tInterior.sName, mmStarterIcon, tInterior.bHide, 0)
        end
      end
      InteriorManager.FocusLocator(tInterior.sName, tInterior.bHide)
    end
  end
  InteriorManager.ToggleFocus()
end

function InteriorManager.ToggleFocus()
  local tSabSelf = Actor.GetSelf(hSab)
  if tSabSelf.bInInterior then
    FocusPt.SetExteriorPts(false)
    FocusPt.SetInteriorPts(true)
  else
    FocusPt.SetExteriorPts(true)
    FocusPt.SetInteriorPts(false)
  end
end

function InteriorManager.LoadWaitingInteriorStarters(tInteriorScript)
  for i, tStarter in pairs(StarterManager.MasterList) do
    local sStarter = tStarter.sName
    if tStarter.sInterior == tInteriorScript.sInteriorTableName and not StarterManager.Save_IsStarterHiddenList[sStarter].bHidden then
      StarterManager.LoadInteriorStarterNode(tStarter.sName)
    end
  end
end

function InteriorManager.UnloadWaitingInteriorStarters(tInteriorScript)
  for i, tStarter in pairs(StarterManager.MasterList) do
    if tStarter.sInterior == tInteriorScript.sInteriorTableName and StarterManager.Save_IsStarterHiddenList[tStarter.sName].bLoadingState == cSM_LOADED then
      local oInteraction = StarterManager.GetInteractionTaskFromList(tStarter.sName)
      if oInteraction and oInteraction:IsActive() then
        print("reseting starter interaction ", oInteraction:GetName())
        oInteraction:ResetThisTask(true, false, false)
      end
      StarterManager.Save_IsStarterHiddenList[tStarter.sName].bLoadingState = cSM_UNLOADED
    end
  end
end

function InteriorManager.LoadDynamicNode(tInteriorScript, sNodeName, bFullStream)
  local bFullStream = bFullStream or false
  local bForce = false
  print("Code Loading: ", sNodeName .. ".wsd", tInteriorScript.sInteriorTableName)
  local sCurrentInterior = InteriorManager.GetPlayersInterior()
  if sCurrentInterior and sCurrentInterior ~= "" then
    local sPlayerInterior = Util.GetPlayersInterior()
    if sPlayerInterior == sCurrentInterior then
      bForce = true
      print("** FORCE:: we are in the interior that we want to load a node ", sNodeName)
    end
  end
  Util.RequestNode(sNodeName .. ".wsd", tInteriorScript.sInteriorTableName, _NODE_DYNAMIC, bFullStream, bForce, false)
end

function InteriorManager.LoadCinematicNode(tInteriorScript, sNodeName, bFullStream)
  local bFullStream = bFullStream or false
  local bForce = false
  print("Code Loading Cin Node: ", sNodeName, tInteriorScript.sInteriorTableName)
  local sCurrentInterior = InteriorManager.GetPlayersInterior()
  if sCurrentInterior and sCurrentInterior ~= "" then
    local sPlayerInterior = Util.GetPlayersInterior()
    if sPlayerInterior == sCurrentInterior then
      bForce = true
      print("** FORCE:: we are in the interior that we want to load a node ", sNodeName)
    end
  end
  Util.RequestNode(sNodeName, tInteriorScript.sInteriorTableName, _NODE_CINEMATIC, bFullStream, bForce, false)
end

function InteriorManager.LoadMinimapImages(tInteriorScript, sNodeName)
  print("Code Loading: ", sNodeName, tInteriorScript.sInteriorTableName)
  Util.RequestNode(sNodeName, tInteriorScript.sInteriorTableName, _NODE_MM, false, false, false)
end

function InteriorManager.ForceUnloadDynamicNode(tInteriorScript, sNodeName)
  local sPlayerInterior = Util.GetPlayersInterior()
  if tInteriorScript.sInteriorTableName == sPlayerInterior then
    print("** ForceUnloadDynamicNode:: we are in the interior that we want to load a node ", sNodeName)
    Util.RequestNode(sNodeName .. ".wsd", tInteriorScript.sInteriorTableName, _NODE_DYNAMIC, false, false, true)
  else
    Util.Assert(false, "ForceUnloadDynamicNode:: trying to unload a node in interior we are not it")
  end
end

function InteriorManager.ReleaseDynamicNode(tInteriorScript, sNodeName)
  local sPlayerInterior = Util.GetPlayersInterior()
  if tInteriorScript.sInteriorTableName ~= "" or tInteriorScript.sInteriorTableName ~= nil then
    print("** ReleaseDynamicNode:: we are in the interior that we want to load a node ", sNodeName)
    Util.RequestNode(sNodeName .. ".wsd", tInteriorScript.sInteriorTableName, _NODE_DYNAMIC, false, false, false, true)
  else
  end
end

function InteriorManager.ForceUnloadCinematicNode(tInteriorScript, sNode)
  local sPlayerInterior = Util.GetPlayersInterior()
  if tInteriorScript.sInteriorTableName == sPlayerInterior then
    print("** ForceUnloadCinematicNode:: we are in the interior that we want to load a node ", sNodeName)
    Util.RequestNode(sNodeName, tInteriorScript.sInteriorTableName, _NODE_CINEMATIC, false, false, true)
  else
    Util.Assert(false, "ForceUnloadCinematicNode:: trying to unload a node in interior we are not it")
  end
end

function InteriorManager.LoadInteriorNode(tInteriorScript, sOverrideTableName)
  print("request interior load ", tInteriorScript.sInteriorTableName)
  local sIntTableName = tInteriorScript.sInteriorTableName
  if sOverrideTableName then
    sIntTableName = sOverrideTableName
    print("InteriorManager.LoadInteriorNode: overriding interior table name", sIntTableName)
  end
  Util.RequestNode(tInteriorScript.sInterior, sIntTableName, _NODE_INTERIOR, false, false, false)
end

function InteriorManager.UnloadInteriorNode(tInteriorScript)
  Util.Assert(false, "CFRENCH InteriorManager.UnloadInteriorNode::INTERIOR NODES ARE NOW HANDLED BY WSINTERIORMANAGER , please don't use this function anymore")
  return
end

function InteriorManager:_CallbackPlayerExitsVehicleHelper(tArgs, sInterior, sLocator)
  InteriorManager.EnterInterior(sInterior, sLocator)
end

function InteriorManager.EnterInterior(sInterior, sLocator)
  local sCodePlayersInterior = Util.GetPlayersInterior()
  if InteriorManager.GetPlayersInterior() == sInterior then
    print("Already in interior that this script is calling, aborting entering interior", sInterior)
    return
  end
  local hVehicle = Actor.GetVehicle(hSab)
  if hVehicle then
    EVENT_PlayerExitsAnyVehicle("InteriorManager._CallbackPlayerExitsVehicleHelper", nil, {sInterior, sLocator})
    Actor.UnboardVehicle(hSab)
    return
  end
  local sScript = Util.GetInteriorScriptByName(sInterior)
  if sScript then
    InteriorManager.InteriorScriptEnter(sScript, sLocator)
  else
    Util.Assert(false, "Interior does not exist in interior manager InteriorManager.EnterInterior", sInterior)
    print("bad interior name or data")
  end
end

function InteriorManager.ExitInterior(sInterior, sLocator, bFadeIn, bFadeOut)
  local sInt = sInterior
  local sLoc = sLocator
  if InteriorManager.GetPlayersInterior() ~= sInterior then
    print("Already outside of Interior, aborting exiting interior", sInterior)
    return
  end
  local sScript = Util.GetInteriorScriptByName(sInterior)
  if sScript then
    InteriorManager.InteriorScriptExit(sScript, sLocator, false, bFadeIn, bFadeOut)
  else
    InteriorManager.InteriorScriptExit(nil, sLocator, false, bFadeIn, bFadeOut)
  end
end

function InteriorManager.LoadInteriorNoTeleport(sInterior)
  local tSabSelf = Actor.GetSelf(hSab)
  if tSabSelf.sPlayersCurrentInterior ~= "" and sInterior ~= tSabSelf.sPlayersCurrentInterior then
    print("*** Unloading (", sInterior, ") to load (", tSabSelf.sPlayersCurrentInterior, ").")
    InteriorManager.UnloadInteriorNoTeleport(tSabSelf.sPlayersCurrentInterior)
  end
  local sScript = Util.GetInteriorScriptByName(sInterior)
  if sScript and tSabSelf.sPlayersCurrentInterior ~= sInterior then
    print("*** setting block Teleport yo")
    if IsMissionOpen("Connect_ST_215b_SkylarRendevous") and sScript == "LeHavreHotel_Interior" then
      print("WARNING: Cfrench is overriding loading into lh hotel with church hotel shenanigans LoadInteriorNoTeleport.lua")
      sScript = "LeHavreHQ_Interior"
    end
    InteriorManager.InteriorScriptEnter(sScript, sLocator, true)
  end
end

function InteriorManager.UnloadInteriorNoTeleport(sInterior)
  local sScript = Util.GetInteriorScriptByName(sInterior)
  if sScript then
    InteriorManager.InteriorScriptExit(sScript, sLocator, true)
  end
end

function InteriorManager.InteriorScriptEnter(sScript, sLocator, bNoTeleport)
  if sScript and sScript ~= "NONE" then
    local oModule = __UtilFunctions.GetTableFromNameSpace(sScript)
    if oModule and oModule.OnEnterInterior then
      if bNoTeleport then
        Util.InteriorLoadSetDisableTeleport()
      end
      oModule.OnEnterInterior(sLocator)
    else
      Util.Assert(false, "InteriorManager.InteriorScriptEnter:: could not find interior oModule ")
      print("InteriorManager.InteriorScriptEnter:: could not find interior oModule ", sScript)
      Render.FadeScreen(false)
    end
  end
end

function InteriorManager.InteriorScriptExit(sScriptOptional, sLocator, bNoTeleport, bFadeIn, bFadeOut)
  local sScript = sScriptOptional
  local sInterior
  if not sScript or sScript == "NONE" then
    sInterior = Util.GetPlayersInterior()
    if sInterior then
      sScript = Util.GetInteriorScriptByName(sInterior)
    end
  end
  if not sScript then
    print("ERROR::InteriorManager.InteriorScriptExit could not find a script for interior unload ")
  end
  local oModule = __UtilFunctions.GetTableFromNameSpace(sScript)
  if oModule and oModule.OnExitInterior then
    if bNoTeleport then
      print("disabling teleport")
      Util.InteriorLoadSetDisableTeleport()
    end
    oModule.OnExitInterior(sLocator, bFadeIn, bFadeOut)
  else
    Render.FadeTo(0, 0, 0, 0, 0)
  end
end

function InteriorManager.RegisterLoadedCallback(sInterior, fCallback, self)
end

function InteriorManager.IsPlayerInInterior()
  local tSabSelf = Actor.GetSelf(hSab)
  if Util.IsPlayerInInterior() then
    return true
  else
    return false
  end
end

function InteriorManager.GetPlayersInterior()
  local tSabSelf = Actor.GetSelf(hSab)
  return tSabSelf.sPlayersCurrentInterior
end

function InteriorManager.ClearOverrideBluePrint()
  local eEvent = Util.CreateEvent({EventType = "TimerEvent", Time = 1.5}, "InteriorManager._ClearOverrideBluePrint", nil, {sBP})
end

function InteriorManager._ClearOverrideBluePrint()
  print("InteriorManager._ClearOverrideBluePrint")
  Render.WTFClearOverrideBlueprint()
end

function InteriorManager.SetHalos(bOn)
  local eEvent = Util.CreateEvent({EventType = "TimerEvent", Time = 2}, "InteriorManager._SetHalos", nil, {bOn})
end

function InteriorManager:_SetHalos(bOn)
  Render.EnableHumanHalos(bOn)
end
