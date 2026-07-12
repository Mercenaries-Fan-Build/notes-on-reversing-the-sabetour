if FuelDepot_E3 == nil then
  FuelDepot_E3 = SabTaskObjective:Create()
  gsParis1Mission1Dir = "Missions\\Paris_1\\Mission_1\\"
  FuelDepot_E3:Configure({
    TaskCount = 999,
    bStarterless = true,
    MCDisplayID = 2,
    tUnlockList = {},
    tSMEDNodes = {
      "Missions\\paris_1\\mission_1_E3\\main",
      "Missions\\paris_1\\mission_1_E3\\depotnazis"
    },
    tStaticTags = {
      "fueldepot_e3_vehcoll"
    }
  })
end

function FuelDepot_E3:STARTER_Setup()
  Util.SetTime(24, 0)
end

function FuelDepot_E3:Activated()
  self.sDebugLabel = "FuelDepot_E3"
  self.bDebugMode = false
  SabTaskObjective.Activated(self)
  Util.DisableDisguising(false)
  Util.SetDisableControls("StealthKill", false)
  self.GENERAL_Setup(self)
end

function FuelDepot_E3:GENERAL_Setup()
  self.sSaboTarget = "PARIS\\area01\\garedelest\\nazifueldepot\\wtf_l\\OccMed_OilTank_H\\OccMed_OilTank_H"
  self.sSmokerNazi = "Missions\\paris_1\\mission_1_e3\\depotnazis\\Spore_WM_Smoker"
  Sound.LoadSoundBank("m_P1M1_inGame.bnk")
  self:Go()
end

function FuelDepot_E3:ArmSelf()
  Inventory.GiveItem(hSab, "WP_MG_MP44", false)
  Inventory.GiveItem(hSab, "WP_SH_12GaugePump", false)
  Inventory.GiveItem(hSab, "WP_SAB_DynamiteFuse", false)
  Inventory.GiveItem(hSab, "WP_SAB_DynamiteFuse", false)
  Inventory.GiveItem(hSab, "WP_SAB_DynamiteFuse", false)
  Inventory.GiveItem(hSab, "WP_SAB_DynamiteFuse", false)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", false)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", false)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", false)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", false)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", false)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", false)
end

function FuelDepot_E3:Go()
  EVENT_Timer("FuelDepot_E3.ArmSelf", self, 15)
  EVENT_Stream("FuelDepot_E3.SetTargetInvincible", self, self.sSaboTarget, false)
  EVENT_PlayerEntersTrigger("FuelDepot_E3.PlayerInDepot", self, "Missions\\paris_1\\mission_1_e3\\main\\PT_EnterFD", false)
  EVENT_PlayerEntersTrigger("FuelDepot_E3.RainOn", self, "Missions\\paris_1\\mission_1_e3\\main\\PT_RainOn", false)
  EVENT_PlayerEntersTrigger("FuelDepot_E3.PlayerClambors", self, "Missions\\paris_1\\mission_1_e3\\main\\PT_Clamboring", false)
  Sound.SetMusicLocale("E3_2009_P1M1_FuelDepot")
  Sound.SetMusicLocale("m_P1M1_FuelDepot", "P1M1_exitBelle")
  local tOnSabPlantEvent = {EventType = "OnSabotage", Target = hSab}
  self.eOops = Util.CreateEvent(tOnSabPlantEvent, "FuelDepot_E3.TurnOffInvincible", self)
  self:RegisterEvent(self.eOops)
  self:SetSabSabListener()
  dprint(self, ">>>>>> STARTING FUEL DEPOT E3 <<<<<<<<<<<<")
end

function FuelDepot_E3:PlayerClambors()
  self:InitLightning()
  Sound.SetMusicLocale("E3_2009_P1M1_FuelDepot")
  Sound.SetMusicLocale("m_P1M1_FuelDepot", "P1M1_clambor")
  Util.LoadStaticENTag("fueldepot_e3_props", true)
end

function FuelDepot_E3:PlayerInDepot()
  local hPatrolNazi1 = Handle("Missions\\paris_1\\mission_1_e3\\depotnazis\\WM_Grunt_MG_Patrol1")
  local hPatrolPath1 = "Missions\\paris_1\\mission_1_e3\\depotnazis\\PATH_Patrol1"
  Nav.SetScriptedPath(hPatrolNazi1, hPatrolPath1, true)
  Nav.SetScriptedPathType(hPatrolNazi1, cPATHTYPE_BOUNCE)
  local hPatrolNazi2 = Handle("Missions\\paris_1\\mission_1_e3\\depotnazis\\WM_Grunt_MG_Patrol2")
  local hPatrolPath2 = "Missions\\paris_1\\mission_1_e3\\depotnazis\\PATH_Patrol2"
  Nav.SetScriptedPath(hPatrolNazi2, hPatrolPath2, true)
  Nav.SetScriptedPathType(hPatrolNazi2, cPATHTYPE_ONCE)
  Util.SetDisguiseCallback("FuelDepot_E3.GotDisguise", self)
end

function FuelDepot_E3:GotDisguise()
  local hWalkByNazi = Handle("Missions\\paris_1\\mission_1_e3\\depotnazis\\WM_Grunt_MG_WalkBy")
  local hWalkByPath = "Missions\\paris_1\\mission_1_e3\\depotnazis\\PATH_WalkBy"
  Nav.SetScriptedPath(hWalkByNazi, hWalkByPath, true)
end

function FuelDepot_E3:SetTargetInvincible()
  Object.SetInvincible(Handle(self.sSaboTarget), true)
end

function FuelDepot_E3:TurnOffInvincible(tVars)
  Object.SetInvincible(Util.GetHandleByName(self.sSaboTarget), false)
end

function FuelDepot_E3:SetSabSabListener()
  local tOnSabExplodeEvent = {
    EventType = "OnSabotageExplode",
    EventName = "SabEventExplode",
    Target = hSab
  }
  Util.CreateEvent(tOnSabExplodeEvent, "FuelDepot_E3.OnSabExplodes", self)
end

function FuelDepot_E3:OnSabExplodes(tVars)
  dprint("I did it again")
  self:SwitchWTF()
  Sound.SetMusicLocale("E3_2009_P1M1_FuelDepot")
  Sound.SetMusicLocale("m_P1M1_FuelDepot", "P1M1_blowDepot")
  EVENT_PlayerEntersTrigger("FuelDepot_E3.GoChasers", self, "Missions\\paris_1\\mission_1_e3\\main\\PT_PlayerExitsFD", false)
end

function FuelDepot_E3:SwitchWTF()
  Cin.PlayCinematic("CIN_P1M1E3_OhShitCam", false)
  Suspicion.SetEscalationCap(3)
  Suspicion.SetEscalationLevel(3)
  Util.SpawnEditNode("Missions\\paris_1\\mission_1_e3\\chasers.wsd")
  Util.SpawnEditNode("Missions\\paris_1\\mission_1_e3\\roadblock_1.wsd")
end

function FuelDepot_E3:GoChasers()
  if Actor.IsInVehicle(hSab) then
    local hChaser1 = Handle("Missions\\paris_1\\mission_1_e3\\chasers\\Kubelwagen_mount_Rear")
    local hChaser2 = Handle("Missions\\paris_1\\mission_1_e3\\chasers\\Kubelwagen_mount_Fork")
    local hChaserLoc = Handle("Missions\\paris_1\\mission_1_e3\\main\\LOC_ChasersGoHere")
    Nav.MoveToObject(hChaser1, hChaserLoc, 1, true)
    Nav.SetScriptedPathSpeed(hChaser1, 70)
    Nav.MoveToObject(hChaser2, hChaserLoc, 1, true)
    Nav.SetScriptedPathSpeed(hChaser2, 70)
    self:GoRoadblock1()
    self:HideSpt()
    Vehicle.EnableTraffic(false, true)
  else
    EVENT_PlayerEntersTrigger("FuelDepot_E3.GoChasers", self, "Missions\\paris_1\\mission_1_e3\\main\\PT_PlayerExitsFD", false)
  end
end

function FuelDepot_E3:GoRoadblock1()
  EVENT_Timer("FuelDepot_E3.UnloadRB1Kubel", self, 0.5)
end

function FuelDepot_E3:UnloadRB1Kubel()
  self.hRB1Kubel = Handle("Missions\\paris_1\\mission_1_e3\\roadblock_1\\VH_NZ_CR_Kubelwagen_01")
  Vehicle.UnboardAll(self.hRB1Kubel, false)
end

function FuelDepot_E3:HideSpt()
  EVENT_EscalationFree("FuelDepot_E3.TestFinalBink", self)
end

function FuelDepot_E3:TestFinalBink()
  local hAlertTrigger = Handle("Missions\\paris_1\\mission_1_e3\\main\\PT_ReadyToEnd")
  local hSeanFilter = Filter.New("Player")
  local tSeanInside = {}
  tSeanInside = Trigger.GetAllWithin(hAlertTrigger, hSeanFilter)
  if tSeanInside[1] == hSab then
    EVENT_Timer("FuelDepot_E3.PlayFinalBink", self, 13)
    Zone.SwitchState("WtF_Zones\\global\\P1M1_FuelDepot", cZONESTATE_HIGHWTF, cENT_IMMEDIATE)
    Render.EnableLightning(false)
    Render.Rain(0, 0.5)
  end
end

function FuelDepot_E3:PlayFinalBink()
  Cin.PlayCinematic("Sab_logoTreatment01", false, "FuelDepot_E3.FadeOut", self)
end

function FuelDepot_E3:FadeOut()
  Render.FadeTo(0, 0, 0, 255, 1)
end

function FuelDepot_E3:HideSptNazi1()
  local hHSNazi1 = Handle("Missions\\paris_1\\mission_1_e3\\hidespot_nazis\\Spore_WM_Grunt_MG")
  local hGoHere = Handle("Missions\\paris_1\\mission_1_e3\\main\\LOC_HideSptNaziObj")
  Combat.SetObjective(hHSNazi1, hGoHere, true, 2, false)
end

function FuelDepot_E3:HideSptNazi2()
  local hHSNazi2 = Handle("Missions\\paris_1\\mission_1_e3\\hidespot_nazis\\Spore_WM_Grunt_MG(2)")
  local hGoHere = Handle("Missions\\paris_1\\mission_1_e3\\main\\LOC_HideSptNaziObj")
  Combat.SetObjective(hHSNazi2, hGoHere, true, 2, false)
end

function FuelDepot_E3:RainOn()
  Render.Rain(1, 0.5)
end

function FuelDepot_E3:InitLightning()
  Render.EnableLightning(true)
end
