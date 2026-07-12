if Connect_P3_M1b_KesslerAtDoppelsieg == nil then
  Connect_P3_M1b_KesslerAtDoppelsieg = SabTaskObjective:Create()
  Connect_P3_M1b_KesslerAtDoppelsieg:Configure({
    TaskCount = 999,
    sSaveMissionNameID = "MissionNames_Text.P3M1",
    sHQStartPoint = _cHQe_CATACOMBS,
    bDisableMissionTitle = true,
    tUnlockList = {
      "NOTE_405",
      "FP_CountryRace_2"
    },
    bSLOverrideFade = true,
    bStarterless = true,
    tSMEDNodes = {
      "Missions\\paris_3\\connect_kessatdopp_p3m1b\\verobishwilc"
    },
    tDeleteNodes = {
      "Missions\\paris_3\\connect_kessatdopp_p3m1b\\CarKiller"
    }
  })
end

function Connect_P3_M1b_KesslerAtDoppelsieg:STARTER_Setup()
  Actor.SetDisguise(hSab, "FBS_RS_Sean")
  Sound.DisableAllChatter()
end

function Connect_P3_M1b_KesslerAtDoppelsieg:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  Inventory.HolsterWeapons(hSab)
end

function Connect_P3_M1b_KesslerAtDoppelsieg:GENERAL_Setup()
  self:RegisterCheckpoint("Connect_P3_M1b_KesslerAtDoppelsieg.Checkpoint1")
end

function Connect_P3_M1b_KesslerAtDoppelsieg:Checkpoint1()
  if not self:IsMissionTaskActive("Task_FirstObjective") then
    self:Task_ShowCinematic()
  end
end

function Connect_P3_M1b_KesslerAtDoppelsieg:Task_FirstObjective()
  self:CreateTask({
    sName = "exitcatacomb",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "Catacombs",
    tOnComplete = {
      {
        self.OutOfCatacomb,
        {self}
      }
    }
  })
end

function Connect_P3_M1b_KesslerAtDoppelsieg:OutOfCatacomb()
  self:CreateTask({
    sName = "Connect_P3_M1b_KesslerAtDoppelsieg_Task_FirstObjective",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    tOnActivate = {
      {
        self.Task_ShowCinematic,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Connect_P3_M1b_KesslerAtDoppelsieg:Task_ShowCinematic()
  print("Task_ShowCinematic")
  self:CreateTask({
    sName = "Connect_P3_M1b_KesslerAtDoppelsieg_Task_ShowCinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "404_CineB_CataOut",
    bOverrideFade = true,
    tOnActivate = {},
    tOnComplete = {
      {
        Util.SetOverrideLoadScreenFadeIn,
        {false}
      },
      {
        self.UnloadTaskNodes,
        {
          self,
          "Connect_P3_M1b_KesslerAtDoppelsieg_Task_ShowCinematic",
          true
        }
      },
      {
        self.ConnectConversationDelay,
        {self}
      }
    },
    tCinematicNodes = {
      "404_cinb_cataout"
    }
  })
end

function Connect_P3_M1b_KesslerAtDoppelsieg:ConnectConversationDelay()
  local hSkylar = Handle("Missions\\paris_3\\connect_kessatdopp_p3m1b\\verobishwilc\\skylar_p3m1b")
  if Inventory.GetCountOfType(hSkylar, "WP_MG_MP44") <= 0 then
    Inventory.GiveItem(hSkylar, "WP_MG_MP44", true)
  end
  local hWilcox = Handle("Missions\\paris_3\\connect_kessatdopp_p3m1b\\verobishwilc\\wilcox_p3m1b")
  if Inventory.GetCountOfType(hWilcox, "WP_MG_MP44") <= 0 then
    Inventory.GiveItem(hWilcox, "WP_MG_MP44", true)
  end
  EVENT_Timer("Connect_P3_M1b_KesslerAtDoppelsieg.ConnectConversation", self, 1.5)
end

function Connect_P3_M1b_KesslerAtDoppelsieg:ConnectConversation()
  Util.LoadStaticENTag("HQ_CComb_Ext_Door", true)
  Render.FadeScreen(false)
  Cin.PlayConversation("404_CinB_CataOut", "Connect_P3_M1b_KesslerAtDoppelsieg.ConversationFinished", self)
end

function Connect_P3_M1b_KesslerAtDoppelsieg:TeleportToExit()
  Object.PlayerTeleportToLocator(Util.GetHandleByName("Missions\\paris_3\\connect_kessatdopp_p3m1b\\verobishwilc\\hq_exit"), true, "Connect_P3_M1b_KesslerAtDoppelsieg.GENERAL_Setup", self)
end

function Connect_P3_M1b_KesslerAtDoppelsieg:SkyWilDriveAway()
  self.sSkylar = "Missions\\paris_3\\connect_kessatdopp_p3m1b\\verobishwilc\\skylar_p3m1b"
  self.sWilcox = "Missions\\paris_3\\connect_kessatdopp_p3m1b\\verobishwilc\\wilcox_p3m1b"
  self.sSkyCar = "Missions\\paris_3\\connect_kessatdopp_p3m1b\\verobishwilc\\VH_CV_CR_Skylar_01_3Seat\\Car"
  local hSklyar = Handle("Missions\\paris_3\\connect_kessatdopp_p3m1b\\verobishwilc\\skylar_p3m1b")
  local hWilcox = Handle("Missions\\paris_3\\connect_kessatdopp_p3m1b\\verobishwilc\\wilcox_p3m1b")
  local hSkyCar = Handle("Missions\\paris_3\\connect_kessatdopp_p3m1b\\verobishwilc\\VH_CV_CR_Skylar_01_3Seat\\Car")
  Nav.BoardVehicle(hSklyar, hSkyCar, "PILOT", false)
  Nav.BoardVehicle(hWilcox, hSkyCar, "SHOTGUN", false)
  EVENT_ActorEntersAnyVehicle("Connect_P3_M1b_KesslerAtDoppelsieg.OnEntersVehicle", self, hWilcox)
end

function Connect_P3_M1b_KesslerAtDoppelsieg:OnEntersVehicle()
  self.sSkylarDriveAwayPath = "Missions\\paris_3\\connect_kessatdopp_p3m1b\\verobishwilc\\SkylarDrivePath"
  local hSkyCar = Handle("Missions\\paris_3\\connect_kessatdopp_p3m1b\\verobishwilc\\VH_CV_CR_Skylar_01_3Seat\\Car")
  Nav.SetScriptedPath(hSkyCar, self.sSkylarDriveAwayPath, false)
  Nav.SetScriptedPathSpeed(hSkyCar, 35)
end

function Connect_P3_M1b_KesslerAtDoppelsieg:ConversationFinished()
  local hVeronique = Handle("Missions\\paris_3\\connect_kessatdopp_p3m1b\\verobishwilc\\veronique_p3m1b")
  self.sVeroPath = "Missions\\paris_3\\connect_kessatdopp_p3m1b\\verobishwilc\\VeroPath"
  Nav.SetScriptedPath(hVeronique, self.sVeroPath, false)
  EVENT_Timer("Connect_P3_M1b_KesslerAtDoppelsieg.ConnectCleanup", self, 15)
end

function Connect_P3_M1b_KesslerAtDoppelsieg:ConnectCleanup()
  HUD.SetMinimapZoom(false)
  Vehicle.AddToTraffic(self.sSkyCar)
  Sound.EnableAllChatter()
  Connect_P3_M1b_KesslerAtDoppelsieg.CompleteThisMission(self)
end
