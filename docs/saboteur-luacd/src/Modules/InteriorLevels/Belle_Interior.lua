require("Includes\\WRAPPER_Event")
require("Includes\\__UtilFunctions")
require("Managers\\InteriorManager")
if not Belle_Interior then
  Belle_Interior = {}
end
Belle_Interior.sInteriorTableName = "Belle"
Belle_Interior.sInterior = "hq_int"
Belle_Interior.Nodes = {}
setmetatable(Belle_Interior, {__index = InteriorManager})

function Belle_Interior:OnEnter()
end

function Belle_Interior.OnEnterInterior(sLocator)
  Util.LoadAnimGroup("belle")
  local tSabSelf = Actor.GetSelf(hSab)
  if tSabSelf and tSabSelf.bInInterior == false then
    DisableBelleHQAbilities(true)
  end
  InteriorManager.OnEnterInterior(Belle_Interior.sInteriorTableName)
  Belle_Interior.Nodes = {}
  local sCiv = "PARIS\\area01\\belledenuit\\interior\\civs"
  local sCine_Nazi = "Missions\\Paris_1\\Mission_1\\cine_nazis"
  local Cinematic = "PARIS\\area01\\belledenuit\\interior\\cinematic"
  local Noncinematic = "noncinematic"
  local Noncine2 = "PARIS\\area01\\belledenuit\\interior\\noncinematic2"
  local sCiv2 = "PARIS\\area01\\belledenuit\\interior\\civs2"
  local sCoatcheck = "PARIS\\area01\\belledenuit\\interior\\coatcheck"
  local sBelleBackRoom = "PARIS\\area01\\belledenuit\\interior\\DorissBackRoom"
  local sDLC = "PARIS\\area01\\belledenuit\\interior\\dlc"
  local sNazis = "PARIS\\area01\\belledenuit\\interior\\Nazis"
  local sBarFlys = "PARIS\\area01\\belledenuit\\interior\\BarFlys"
  local sWaiters = "PARIS\\area01\\belledenuit\\interior\\Waiters"
  local sEventsNode = "PARIS\\area01\\belledenuit\\interior\\events"
  local sBand = "PARIS\\area01\\belledenuit\\interior\\Band"
  local sBandNoSinger = "PARIS\\area01\\belledenuit\\interior\\bandnosinger"
  if sLocator == "PARIS\\area01\\belledenuit\\interior\\hq_int\\LOC_Belle_int_Two" then
    Render.WTFSetOverrideBlueprint("WillToFight_HQ_Belle2")
    print("belle 2")
    Belle_Interior.sLocator = "PARIS\\area01\\belledenuit\\interior\\hq_int\\LOC_Belle_int_Two"
  elseif sLocator == "PARIS\\area01\\belledenuit\\interior\\hq_int\\LOC_Belle_int" then
    print("belle high")
    Render.WTFSetOverrideBlueprint("WillToFight_BelleDeNuit_High")
    Belle_Interior.sLocator = "PARIS\\area01\\belledenuit\\interior\\hq_int\\LOC_Belle_int"
  elseif sLocator == "DLC\\midnightshowdoor\\LOC_MS_TeleportOUT" then
    print("belle high")
    Render.WTFSetOverrideBlueprint("WillToFight_BelleDeNuit_High")
    Belle_Interior.sLocator = "DLC\\midnightshowdoor\\LOC_MS_TeleportOUT"
  elseif IsMissionActive("Paris_1_Mission_1") or IsMissionOpen("Paris_1_Mission_1") then
    Render.WTFSetOverrideBlueprint("WillToFight_BelleDeNuit_High")
  else
    print("belle 2")
    Render.WTFSetOverrideBlueprint("WillToFight_HQ_Belle2")
  end
  Suspicion.EnableGlobal(false)
  Suspicion.ResetEscalation(false)
  Belle_Interior:LoadInteriorNode()
  if not IsMissionActive("Paris_1_Mission_1") and not IsMissionOpen("Paris_1_Mission_1") then
    Belle_Interior:LoadDynamicNode(sDLC)
    if _g_bHasMidnightShowDLC then
      Belle_Interior:LoadDynamicNode("DLC\\midnightshowdoor")
    end
  end
  local bDisableFadeIn = false
  if IsMissionOpen("Paris_1_Mission_1") and not IsMissionActive("SOE_1_ConnectToBelle") then
    Belle_Interior:LoadDynamicNode(sCiv)
    Belle_Interior:LoadCinematicNode(Noncinematic)
    Belle_Interior:LoadDynamicNode(sCoatcheck)
    Belle_Interior:LoadDynamicNode(sBelleBackRoom)
    Sound.ReleaseSoundBank("Explosions.bnk")
    if IsMissionActive("Paris_1_Mission_1") then
      bDisableFadeIn = true
    else
      bDisableFadeIn = false
    end
    bDisableFadeIn = true
  elseif IsMissionActive("Connect_A1_M5b_BellAnd3Months") or IsMissionOpen("Connect_A1_M5b_BellAnd3Months") then
    Sound.ReleaseSoundBank("Explosions.bnk")
    Belle_Interior:LoadWaitingInteriorStarters()
    local bDisableFadeIn = true
    Belle_Interior:LoadCinematicNode(Noncinematic)
    Belle_Interior:LoadDynamicNode(sCiv)
    Belle_Interior:LoadDynamicNode(sNazis)
    Belle_Interior:LoadDynamicNode(sBarFlys)
    Belle_Interior:LoadDynamicNode(sWaiters)
    Belle_Interior:LoadDynamicNode(sCoatcheck)
  elseif IsMissionActive("FebDemo2009") or IsMissionOpen("FebDemo2009") then
    Belle_Interior:LoadDynamicNode(sCiv)
    Belle_Interior:LoadDynamicNode(sCoatcheck)
    Belle_Interior:LoadCinematicNode(Noncinematic)
    Sound.ReleaseSoundBank("Explosions.bnk")
    local bDisableFadeIn = true
  elseif IsMissionActive("Paris_1_Mission_1") then
    Belle_Interior:LoadDynamicNode(sCiv)
    Belle_Interior:LoadDynamicNode(sCoatcheck)
    Belle_Interior:LoadCinematicNode(Noncinematic)
    Belle_Interior:LoadDynamicNode(sBelleBackRoom)
    Sound.ReleaseSoundBank("Explosions.bnk")
    if Paris_1_Mission_1.bStart == true then
      bDisableFadeIn = true
    else
      bDisableFadeIn = false
    end
  elseif IsMissionActive("SOE_1_ConnectToBelle") then
    Belle_Interior:LoadDynamicNode(Cinematic)
    Sound.ReleaseSoundBank("Explosions.bnk")
  elseif IsMissionOpen("Paris_1_Mission_1B") then
    Belle_Interior:LoadCinematicNode(Noncinematic)
    Belle_Interior:LoadWaitingInteriorStarters()
    Belle_Interior:LoadDynamicNode(sCiv)
    Belle_Interior:LoadDynamicNode(sNazis)
    Belle_Interior:LoadDynamicNode(sBarFlys)
    Belle_Interior:LoadDynamicNode(sWaiters)
    Belle_Interior:LoadDynamicNode(sCoatcheck)
    Sound.ReleaseSoundBank("Explosions.bnk")
  elseif IsMissionOpen("Connect_JulesisDeadCin") or IsMissionActive("Connect_JulesisDeadCin") then
    Sound.ReleaseSoundBank("Explosions.bnk")
    Belle_Interior:LoadWaitingInteriorStarters()
    local bDisableFadeIn = true
    Belle_Interior:LoadCinematicNode(Noncinematic)
    Belle_Interior:LoadDynamicNode(sCiv)
    Belle_Interior:LoadDynamicNode(sNazis)
    Belle_Interior:LoadDynamicNode(sBarFlys)
    Belle_Interior:LoadDynamicNode(sWaiters)
    Belle_Interior:LoadDynamicNode(sCoatcheck)
  elseif IsMissionActive("Connect_A3_M1b_ReturnToBelle") then
  elseif IsMissionCompleted("Act_3_Mission_2") then
    Belle_Interior:LoadDynamicNode(sBarFlys)
    Belle_Interior:LoadDynamicNode(sWaiters)
    Belle_Interior:LoadDynamicNode(sCoatcheck)
    Belle_Interior:LoadCinematicNode(Noncinematic)
    Belle_Interior:LoadWaitingInteriorStarters()
    Belle_Interior:LoadDynamicNode(sBelleBackRoom)
    Belle_Interior:LoadDynamicNode(sCiv)
  else
    Belle_Interior:LoadCinematicNode(Noncinematic)
    Belle_Interior:LoadWaitingInteriorStarters()
    Belle_Interior:LoadDynamicNode(sCiv)
    Belle_Interior:LoadDynamicNode(sCoatcheck)
    Belle_Interior:LoadDynamicNode(sEventsNode)
    Belle_Interior:LoadDynamicNode(sNazis)
    Belle_Interior:LoadDynamicNode(sBarFlys)
    Belle_Interior:LoadDynamicNode(sWaiters)
    Belle_Interior:LoadDynamicNode(sBelleBackRoom)
    Sound.ReleaseSoundBank("Explosions.bnk")
  end
  local nBandomizer = math.random(1, 2)
  if nBandomizer == 1 then
    if not IsMissionCompleted("Paris_1_Mission_1") and (IsMissionActive("Paris_1_Mission_1") or IsMissionOpen("Paris_1_Mission_1") or IsMissionActive("Connect_A3_M1b_ReturnToBelle")) then
    elseif Util.IsBlockLoaded(sBandNoSinger .. ".wsd") then
      Belle_Interior:LoadDynamicNode(sBandNoSinger)
    else
      Belle_Interior:LoadDynamicNode(sBand)
    end
  elseif nBandomizer ~= 2 or IsMissionActive("Paris_1_Mission_1") or IsMissionOpen("Paris_1_Mission_1") or IsMissionActive("Connect_A3_M1b_ReturnToBelle") then
  elseif Util.IsBlockLoaded(sBand .. ".wsd") then
    Belle_Interior:LoadDynamicNode(sBand)
  else
    Belle_Interior:LoadDynamicNode(sBandNoSinger)
  end
  Belle_Interior:LoadMinimapImages("MM_Belle")
  Actor.HolsterWeaponImmediate(hSab)
  Util.EnableSuperSpores(false)
  InteriorManager.SetHalos(false)
  Sound.SetMusicLocale("Belle_De_Nuit")
  Util.EnterInterior("Belle", sLocator, bDisableFadeIn)
  hMidnightShowDoor = Util.GetHandleByName("DLC\\midnightshowdoor\\TeleporterDoorPointI2I")
  if hMidnightShowDoor then
    HUD.SetObjectiveMarker(hMidnightShowDoor, cMMI_DLC, cOM_Objective, true, false, true)
  end
end

function Belle_Interior.OnExitInterior(sLocator, a_bDisableFadeIn)
  if hMidnightShowDoor then
    HUD.RemoveObjectiveMarker(hMidnightShowDoor)
    hMidnightShowDoor = nil
  end
  Util.UnloadAnimGroup("belle")
  InteriorManager.OnExitInterior()
  Suspicion.EnableGlobal(true)
  Util.EnableSuperSpores(true)
  DisableBelleHQAbilities(false)
  Sound.SetMusicLocale("Default")
  InteriorManager.ClearOverrideBluePrint()
  Sound.LoadSoundBank("Explosions.bnk")
  Belle_Interior:UnloadWaitingInteriorStarters()
  InteriorManager.SetHalos(true)
  Actor.SurgeonGeneral(false)
  local bDisableFadeIn = a_bDisableFadeIn or false
  if IsMissionActive("Paris_1_Mission_1") then
  elseif IsMissionActive("Paris_1_Mission_1B") then
  end
  Belle_Interior.sLocator = nil
  WorldSMEDNodes.UnloadNode("PARIS\\area01\\belledenuit\\interior\\DorissBackRoom", true)
  Util.ExitInterior("Belle", sLocator, bDisableFadeIn)
end
