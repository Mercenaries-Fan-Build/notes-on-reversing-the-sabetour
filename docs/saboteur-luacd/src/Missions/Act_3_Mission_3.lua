if Act_3_Mission_3 == nil then
  Act_3_Mission_3 = SabTaskObjective:Create()
  Act_3_Mission_3:Configure({
    TaskCount = 99,
    MCDisplayID = 2,
    bStarterless = true,
    bSLOverrideFade = true,
    sSaveMissionNameID = "MissionNames_Text.A3M3",
    tUnlockList = {
      "Connect_A3_M6b_BackToParis"
    },
    tSMEDNodes = {
      "Missions\\act_3\\mission_3\\dynamic_triggers",
      "Missions\\act_3\\mission_3\\Dynamic_Vehicle",
      "Missions\\act_3\\mission_3\\MissionObjectiveRelated",
      "Missions\\act_3\\mission_3\\nazi_enc\\enc1",
      "Missions\\act_3\\mission_3\\nazi_enc\\enc2",
      "Missions\\act_3\\mission_3\\nazi_enc\\enc3",
      "Missions\\act_3\\mission_3\\nazi_enc\\enc4",
      "Missions\\act_3\\mission_3\\nazi_enc\\elevatorhunt",
      "Missions\\act_3\\mission_3\\starter",
      "Missions\\act_3\\mission_3\\nazifirstencounter",
      "Missions\\act_3\\mission_3\\dyn_skyler_bomb_05",
      "Missions\\act_3\\mission_3\\nazitowerguards"
    },
    tStaticTags = {
      "A3M3_SpecialCaseNode",
      "A3M3_DriveFactory"
    }
  })
end

function Act_3_Mission_3:STARTER_Setup()
  Util.LoadStaticENTag("a3m3_skylarplane1", true)
  Vehicle.EnableTraffic(false, true)
  Util.UnloadStaticENTag("fp_amb_sb_armoredcar_04", true)
  Util.UnloadStaticENTag("fp_amb_sb_armoredcar_02", true)
  Util.SetTime(12, 0)
end

function Act_3_Mission_3:Activated()
  Object.PlayerTeleportToPos(2577.3, 75.11, -3036.36, -27.44, true, "Act_3_Mission_3.Activated_AfterTeleport", self)
  Sound.LoadSoundBank("M_a3m3_inGame.bnk")
  self:CreateTask({
    sName = "Missions\\act_3\\mission_3\\sound",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\act_3\\mission_3\\sound"
    }
  })
  self.bTowerGlitchLoaded = true
  Util.LoadStaticENTag("A3M3_TowerGlitch", true)
end

function Act_3_Mission_3:SkylarUsesATPT()
  local hSkylar = Handle("Missions\\act_3\\mission_3\\skylarplane1\\Spore_RS_Skylar")
  local hATPT = Handle("Missions\\act_3\\mission_3\\skylarplane1\\AttractionPT_Sitforever")
  if hSkylar and hATPT then
    Actor.UseAttrPt(hSkylar, hATPT)
  end
end

function Act_3_Mission_3:Activated_AfterTeleport()
  Render.FadeScreen(false)
  SabTaskObjective.Activated(self)
  local tEvent = {EventType = "TimerEvent", Time = 3}
  Util.CreateEvent(tEvent, "Act_3_Mission_3.PlayInitialConversation", self)
  self.MainEmpty(self)
  self.Checkpoint0(self)
  Util.UnloadStaticENTag("fp_amb_sb_armoredcar_04", true)
  Util.UnloadStaticENTag("fp_amb_sb_armoredcar_02", true)
end

function Act_3_Mission_3:GENERAL_Setup()
  self:AddOnCancelCallback(Act_3_Mission_3.Reset)
  self:AddOnCompleteCallback(Act_3_Mission_3.Reset)
  Suspicion.SetEscalationLevel(4)
  self.bConversationsIn = true
  self.tSaveInfo.hShieldUpEvent = nil
  self.tSaveInfo.hShieldDownEvent = nil
  self.tSaveInfo.hReTryEvent = nil
  self.VeroniqueHaxor(self)
  self.SkylarInitialEncounterStart(self)
  self.StreamEventsOnPlanes(self)
  self.SetupTriggerPlanes(self)
  self:CreateTask({
    sName = "Missions\\act_3\\mission_3\\factory_shootout\\OfficeAttack",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\act_3\\mission_3\\factory_shootout\\OfficeAttack"
    }
  })
end

function Act_3_Mission_3:Checkpoint0()
  self.RegisterCheckpoint(self, "Act_3_Mission_3.Checkpoint0Setup")
end

function Act_3_Mission_3:Checkpoint0Setup()
  Cin.LoadCinematic("A3M3_Skylar_FirstFly_Cam")
  self.hSkylarATPT = Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\act_3\\mission_3\\skylarplane1\\Spore_RS_Skylar",
      "Missions\\act_3\\mission_3\\skylarplane1\\AttractionPT_Sitforever"
    },
    WaitForGameObject = true
  }, "Act_3_Mission_3.SkylarUsesATPT", self)
  self:RegisterEvent(self.hSkylarATPT)
  Convo.ResetForFail()
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\act_3\\mission_3\\skylarplane1\\PROP_VH_NO_PL_P61Skylar_01"
    },
    WaitForGameObject = true
  }, "Act_3_Mission_3.SetSkylarPlaneInvincible1", self))
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\act_3\\mission_3\\skylarflyshot\\PROP_NO_PL_P61Skylar_spline"
    },
    WaitForGameObject = true
  }, "Act_3_Mission_3.SetSkylarPlaneInvincible2", self))
  self.GENERAL_Setup(self)
  self.EscortVeroniqueToDoppel(self)
end

function Act_3_Mission_3:SetSkylarPlaneInvincible1()
  Object.SetInvincible(Handle("Missions\\act_3\\mission_3\\skylarplane1\\PROP_VH_NO_PL_P61Skylar_01"), true)
end

function Act_3_Mission_3:SetSkylarPlaneInvincible2()
  Object.SetInvincible(Handle("Missions\\act_3\\mission_3\\skylarflyshot\\PROP_NO_PL_P61Skylar_spline"), true)
end

function Act_3_Mission_3:MainEmpty()
  self:CreateTask({
    sName = "MainTask",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bPersistentParent = true
  })
end

function Act_3_Mission_3:EscortVeroniqueToDoppel()
  Sound.SetMusicLocale("A3M3_DoppelsiegReturn")
  Sound.SetMusicLocale("m_A3M3_DoppelsiegReturn", "Drive")
  local sGetToDoppelLoc = "Missions\\act_3\\mission_3\\MissionObjectiveRelated\\LOC_escortveroniquetodoppel"
  local sGetToDoppelPt = "Missions\\act_3\\mission_3\\MissionObjectiveRelated\\PT_escortveroniquetodoppel"
  local hVeronique = Util.GetHandleByName("Missions\\act_3\\mission_3\\starter\\A3M3_Veronique")
  if hVeronique then
    Combat.SetGrabbable(hVeronique, false)
  end
  self.hVeroStreamout = Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\act_3\\mission_3\\starter\\A3M3_Veronique"
    },
    WaitForStreamOut = true
  }, "Act_3_Mission_3.VeroniqueStreamedOutFail", self)
  Combat.SetLeader(hVeronique, hSab, false, 8, 8)
  if Inventory.GetCountOfType(hVeronique, "WP_MG_MP44") <= 0 then
    Inventory.GiveItem(hVeronique, "WP_MG_MP44", true)
  end
  Object.SetHealth(hVeronique, 2000)
  Util.UnloadStaticENTag("Dopp_ClosedDoor", true)
  self.tSaveInfo.Event_A3M3_Veronique_Abandon = Util.CreateEvent({
    EventType = "ProximityEvent",
    ObjectA = hVeronique,
    ObjectB = hSab,
    Proximity = 30,
    Negate = true
  }, "Act_3_Mission_3.AbandonedVero", self, nil)
  self:RegisterEvent(self.tSaveInfo.Event_A3M3_Veronique_Abandon)
  self.tSaveInfo.Event_A3M3_Veronique_Reminder = Util.CreateEvent({EventType = "TimerEvent", Time = 300}, "Act_3_Mission_3.ConversationPlayer", self, {
    "A3M3_Veronique_Reminder"
  })
  self:RegisterEvent(self.tSaveInfo.Event_A3M3_Veronique_Reminder)
  self:CreateTask({
    sName = "TASK_TaxiTask",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "A3M3_Text.EnterDoppelsieg",
    ParentObjectID = self:GetTaskObjectiveID("MainTask"),
    tPickupProxObj = {
      "Missions\\act_3\\mission_3\\starter\\A3M3_Veronique"
    },
    bNoDumping = true,
    bNoCarRequired = true,
    Proximity = 12,
    tDestLocators = {
      "Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_EnterDoppel"
    },
    tDestRegion = {
      "Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_EnterDoppel"
    },
    tDeliverObjs = {
      "Missions\\act_3\\mission_3\\starter\\A3M3_Veronique"
    },
    bSpecialCaseBrakeOverride = true,
    tOnEarlyExit = {},
    tOnWait = {},
    tOnPickup = {},
    tOnComplete = {
      {
        self.GetInsideFactory,
        {self}
      }
    },
    tOnActivate = {},
    tSMEDNodes = {}
  })
end

function Act_3_Mission_3:GetInsideFactory()
  local hVeronique = Util.GetHandleByName("Missions\\act_3\\mission_3\\starter\\A3M3_Veronique")
  local sGetToDoppelLoc = "Missions\\act_3\\mission_3\\MissionObjectiveRelated\\LOC_escortveroniquetodoppel"
  local sGetToDoppelPt = "Missions\\act_3\\mission_3\\MissionObjectiveRelated\\PT_escortveroniquetodoppel"
  self.ConversationPlayer(self, "A3M3_SkylarBomb_Gate")
  self.ConversationPlayer(self, "A3M3_Nazi_Alert")
  Util.KillEvent(self.tSaveInfo.Event_A3M3_Veronique_Reminder)
  Combat.SetLeader(hVeronique, hSab, false, 4, 4)
  self:CreateTask({
    sName = "EscortVeroniqueToDoppelsieg",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "A3M3_Text.Enterthefactory",
    ParentObjectID = self:GetTaskObjectiveID("MainTask"),
    tPickupProxObj = {
      "Missions\\act_3\\mission_3\\starter\\A3M3_Veronique"
    },
    bNoGPS = true,
    bNoDumping = true,
    bNoCarRequired = true,
    Proximity = 12,
    tDestLocators = {sGetToDoppelLoc},
    tDestRegion = {sGetToDoppelPt},
    tDeliverObjs = {hVeronique},
    bSpecialCaseBrakeOverride = true,
    tOnComplete = {
      {
        self.SetupCheckpoint1,
        {self}
      }
    }
  })
  local tEvent = {EventType = "TimerEvent", Time = 0.5}
  Util.CreateEvent(tEvent, "Act_3_Mission_3.ClearGPSHUD", self)
end

function Act_3_Mission_3:ClearGPSHUD()
  HUD.ClearGPSTarget()
end

function Act_3_Mission_3:SetupCheckpoint1()
  self:UnloadTaskNodes("Missions\\act_3\\mission_3\\dyn_skyler_bomb_01", true)
  self.ConversationPlayer(self, "A3M3_Factory_Entered")
  self.RegisterCheckpoint(self, "Act_3_Mission_3.Checkpoint1")
end

function Act_3_Mission_3:Checkpoint1()
  Render.WTFSetOverrideBlueprint("WillToFight_INT_Dopp_Car_low")
  Convo.ResetForFail()
  Suspicion.SetEscalated()
  local hVeronique = Util.GetHandleByName("Missions\\act_3\\mission_3\\starter\\A3M3_Veronique")
  if hVeronique then
    Combat.SetGrabbable(hVeronique, false)
  end
  if self.tSaveInfo.Event_A3M3_Veronique_Died then
    Util.KillEvent(self.tSaveInfo.Event_A3M3_Veronique_Died)
  end
  local hVeronique = Handle("Missions\\act_3\\mission_3\\starter\\A3M3_Veronique")
  if Inventory.GetCountOfType(hVeronique, "WP_MG_MP44") <= 0 then
    Inventory.GiveItem(hVeronique, "WP_MG_MP44", true)
  end
  self.SetupChargers(self)
  self.VeroniqueHaxor(self)
  local sMusicName = "Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_FindKesslerMusic"
  self:RegisterTriggerEvent(Trigger.WaitFor(sMusicName, hSab, "Act_3_Mission_3.FindKesslerMusicChange", self, {i}, cTRIGGEREVENT_ONENTER), sMusicName)
  self.FindMariasCell(self)
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_Checkpoint5", hSab, "Act_3_Mission_3.Setup1point5", self, {i}, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_Checkpoint5")
end

function Act_3_Mission_3:Setup1point5()
  self.RegisterCheckpoint(self, "Act_3_Mission_3.Checkpoint1point5")
end

function Act_3_Mission_3:Checkpoint1point5()
  Render.WTFSetOverrideBlueprint("WillToFight_INT_Dopp_Car_low")
  Convo.ResetForFail()
  Suspicion.SetEscalated()
  Util.UnloadEditNode("Missions\\act_3\\mission_3\\nazi_enc\\enc1.wsd", true, false)
  if self:IsMissionTaskActive("FindMariasCellBlock") == false then
    local hVeronique = Util.GetHandleByName("Missions\\act_3\\mission_3\\starter\\A3M3_Veronique")
    if hVeronique then
      Combat.SetGrabbable(hVeronique, false)
    end
    HUD.SetObjectiveMarker(hVeronique, cMMI_Escort, cOM_Escort, true, true)
    if self.tSaveInfo.Event_A3M3_Veronique_Died then
      Util.KillEvent(self.tSaveInfo.Event_A3M3_Veronique_Died)
    end
    local hVeronique = Handle("Missions\\act_3\\mission_3\\starter\\A3M3_Veronique")
    if hVeronique and Inventory.GetCountOfType(hVeronique, "WP_MG_MP44") <= 0 then
      Inventory.GiveItem(hVeronique, "WP_MG_MP44", true)
    end
    self.SetupChargers(self)
    self.VeroniqueHaxor(self)
    self.FindMariasCell(self)
  end
end

function Act_3_Mission_3:FindMariasCell()
  local hVeronique = Util.GetHandleByName("Missions\\act_3\\mission_3\\starter\\A3M3_Veronique")
  local sMariaLoc = "Missions\\act_3\\mission_3\\MissionObjectiveRelated\\LOC_MariaLoc"
  local sMariaPT = "Missions\\act_3\\mission_3\\MissionObjectiveRelated\\PT_MariaLoc"
  local sFakeMariaPT = "Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_MariaLoc2"
  if hVeronique then
    Combat.SetLeader(hVeronique, hSab, false, 8, 8)
  end
  Object.SetHealth(hVeronique, 2000)
  self:CreateTask({
    sName = "FindMariasCellBlock",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "A3M3_Text.RescueMaria",
    ParentObjectID = self:GetTaskObjectiveID("MainTask"),
    sTaskSubType = "GOTO",
    tLocators = {sMariaLoc},
    tDestRegion = sFakeMariaPT,
    bNoGPS = true,
    tDeliverObjs = {hSab, hVeronique},
    tOnComplete = {}
  })
  self:CreateTask({
    sName = "FindMariasCellBlock2",
    sTaskType = "SabTaskObjectiveDeliver",
    bNoFocus = true,
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    sTaskSubType = "GOTO",
    bNoGPS = true,
    tLocators = {sMariaLoc},
    tDestRegion = sMariaPT,
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.MARIACINEMATICPLAY,
        {self}
      }
    }
  })
end

function Act_3_Mission_3:MARIACINEMATICPLAY()
  self:CreateTask({
    sName = "LoadKessler",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\act_3\\mission_3\\A3M3_Kessler"
    }
  })
  self:CreateTask({
    sName = "MariaCinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Cinematic",
    sCinFile = "406_CinB_Maria",
    bOverrideFade = true,
    tOnActivate = {
      {
        self.CompleteTaskByName,
        {
          self,
          "FindMariasCellBlock"
        }
      },
      {
        self.TeleportCinematicPeople,
        {self}
      }
    },
    tSMEDNodes = {},
    tCinematicNodes = {
      "Missions\\cinematics\\406_cinb_maria"
    },
    tOnComplete = {
      {
        Util.SetOverrideLoadScreenFadeIn,
        {false}
      },
      {
        self.TeleportSeanToMariasOffice,
        {self}
      }
    }
  })
end

function Act_3_Mission_3:TeleportSeanToMariasOffice()
  local hLocator = Handle("Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_MariaLoc")
  Util.KillEvent(self.hVeroStreamout)
  AttractionPt.EnableUse(Handle("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\2nd_floor\\InterogationRoomDoorPt"), false)
  self:UnloadTaskNodes("MariaCinematic")
  Util.LoadStaticENTag("Dopp_2nd_Door", true)
  Object.PlayerTeleportToLocator(hLocator, true, "Act_3_Mission_3.SetupCheckpoint2", self)
end

function Act_3_Mission_3:SetupCheckpoint2()
  local hLoc = Handle("Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_MariaLoc")
  self.RegisterCheckpoint(self, "Act_3_Mission_3.Checkpoint2")
end

function Act_3_Mission_3:Checkpoint2()
  Render.FadeScreen(false)
  Util.UnloadStaticENTag("Dopp_2nd_Door_Back", true)
  Render.WTFSetOverrideBlueprint("WillToFight_INT_Dopp_Car_low")
  Sound.SetMusicLocale("A3M3_DoppelsiegReturn")
  Sound.SetMusicLocale("m_A3M3_DoppelsiegReturn", "findKessler")
  Convo.ResetForFail()
  if self.TempObjectiveID then
    HUD.RemoveObjective(self.TempObjectiveID)
  end
  Sound.PlayOwnerlessSoundEvent("a3m3_office_fire")
  Suspicion.SetEscalationLevel(4)
  self.FindKesslersCell(self)
end

function Act_3_Mission_3:FindKesslersCell()
  self:CreateTask({
    sName = "LoadGuards",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\act_3\\mission_3\\nazi_enc\\KesslerGuards"
    },
    tStaticTags = {
      "Load_Cyc_props"
    },
    tOnActivate = {
      {
        self.WaitUntilNazisFullyStreamIn,
        {self}
      }
    }
  })
  Util.LoadStaticENTag("A3M3_MariaRoom", true)
  local hInterogationRoomDoor2 = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\admin\\InterogationRoomDoorPt(3)")
  AttractionPt.EnableUse(hInterogationRoomDoor2, false)
  local hDoorATPT = "CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\admin\\InterogationRoomDoorPt(6)"
  local sKesslerLoc = "Missions\\act_3\\mission_3\\MissionObjectiveRelated\\LOC_KesslerLoc"
  local sKesslerPT = "Missions\\act_3\\mission_3\\MissionObjectiveRelated\\PT_KesslerLoc"
  local hDoor = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\2nd_floor\\Interro_Room_Door_Front\\Dopple_Interro_Office_Door_Int")
  local hCyclotron = Handle("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\Dopple_Cyclotron_Middle_Upper")
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  if hKessler then
    Combat.SetGrabbable(hKessler, false)
    Actor.SetNonKnockdownable(hKessler, true)
    Actor.SetLabel(hKessler, "nopush", true)
    Actor.SetUseHitReactions(hKessler, false)
  end
  if self.tSaveInfo.Event_A3M3_Veronique_Died then
    Util.KillEvent(self.tSaveInfo.Event_A3M3_Veronique_Died)
  end
  if self.tSaveInfo.Event_A3M3_Veronique_Abandon then
    Util.KillEvent(self.tSaveInfo.Event_A3M3_Veronique_Abandon)
  end
  Object.SetInvincible(hCyclotron, true)
  Object.ForceClose(hDoor)
  AttractionPt.EnableUse(Handle(hDoorATPT), false)
  Actor.OverrideCombatAI(hKessler, true)
  Actor.SetUseHitReactions(hKessler, false)
  Squad.AddMember("Saboteur", hKessler)
  Object.SetHealth(hKessler, 10000)
  self.ConversationPlayer(self, "A3M3_KesslerFind_Start")
  self:CreateTask({
    sName = "FindKesslersRoom",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "A3M3_Text.FindKessler",
    ParentObjectID = self:GetTaskObjectiveID("MainTask"),
    sTaskSubType = "GOTO",
    vGPSTarget = sKesslerLoc,
    tLocators = {sKesslerLoc},
    tDestRegion = sKesslerPT,
    tDeliverObjs = {hSab},
    tOnCancel = {
      {
        self.FailedSoKillNaziTask,
        {self}
      }
    },
    tOnComplete = {
      {
        self.CanKesslerGetOutOfDoor,
        {self}
      }
    }
  })
end

function Act_3_Mission_3:FailedSoKillNaziTask()
  self:CreateTask({
    sName = "ClearOutGuardingNazis",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "A3M3_Text.TakeoutNazis",
    ParentObjectID = self:GetTaskObjectiveID("MainTask"),
    tTgtInclude = {
      "Missions\\act_3\\mission_3\\nazi_enc\\KesslerGuards\\nazi1",
      "Missions\\act_3\\mission_3\\nazi_enc\\KesslerGuards\\nazi2",
      "Missions\\act_3\\mission_3\\nazi_enc\\KesslerGuards\\nazi3"
    },
    tOnComplete = {
      {
        self.ReEnableFindKesslerOfficeObjective,
        {self}
      }
    }
  })
end

function Act_3_Mission_3:WaitUntilNazisFullyStreamIn()
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\act_3\\mission_3\\nazi_enc\\KesslerGuards\\nazi1",
      "Missions\\act_3\\mission_3\\nazi_enc\\KesslerGuards\\nazi2",
      "Missions\\act_3\\mission_3\\nazi_enc\\KesslerGuards\\nazi3"
    },
    WaitForGameObject = true
  }, "Act_3_Mission_3.LookAtKesslerGuardsEvent", self))
end

function Act_3_Mission_3:LookAtKesslerGuardsEvent()
  self.hSeeNazi1Event = Util.CreateEvent({
    EventType = "SeeLocatorEvent",
    InViewTime = 1,
    Locator = "Missions\\act_3\\mission_3\\nazi_enc\\KesslerGuards\\nazi1",
    Proximity = 35
  }, "Act_3_Mission_3.KillOffGuardingNazis", self)
  self.hSeeNazi2Event = Util.CreateEvent({
    EventType = "SeeLocatorEvent",
    InViewTime = 1,
    Locator = "Missions\\act_3\\mission_3\\nazi_enc\\KesslerGuards\\nazi2",
    Proximity = 35
  }, "Act_3_Mission_3.KillOffGuardingNazis", self)
  self.hSeeNazi3Event = Util.CreateEvent({
    EventType = "SeeLocatorEvent",
    InViewTime = 1,
    Locator = "Missions\\act_3\\mission_3\\nazi_enc\\KesslerGuards\\nazi3",
    Proximity = 35
  }, "Act_3_Mission_3.KillOffGuardingNazis", self)
  self:RegisterEvent(self.hSeeNazi1Event)
  self:RegisterEvent(self.hSeeNazi2Event)
  self:RegisterEvent(self.hSeeNazi3Event)
end

function Act_3_Mission_3:KillOffGuardingNazis()
  Util.KillEvent(self.hSeeNazi1Event)
  Util.KillEvent(self.hSeeNazi2Event)
  Util.KillEvent(self.hSeeNazi3Event)
  local hNazi1 = Handle("Missions\\act_3\\mission_3\\nazi_enc\\KesslerGuards\\nazi1")
  local hNazi2 = Handle("Missions\\act_3\\mission_3\\nazi_enc\\KesslerGuards\\nazi2")
  local hNazi3 = Handle("Missions\\act_3\\mission_3\\nazi_enc\\KesslerGuards\\nazi3")
  if hNazi1 and Object.IsAlive(hNazi1) or hNazi2 and Object.IsAlive(hNazi2) or hNazi3 and Object.IsAlive(hNazi3) then
    self:FailTaskByName("FindKesslersRoom")
  end
end

function Act_3_Mission_3:ReEnableFindKesslerOfficeObjective()
  self:ResetTaskByName("FindKesslersRoom")
end

function Act_3_Mission_3:CanKesslerGetOutOfDoor()
  Sound.SetMusicLocale("A3M3_DoppelsiegReturn")
  Sound.SetMusicLocale("m_A3M3_DoppelsiegReturn", "findLab")
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  Actor.OverrideCombatAI(hKessler, true)
  Actor.SetUseHitReactions(hKessler, false)
  Squad.AddMember("Saboteur", hKessler)
  self:CompleteTaskByName("faketaskgoto1")
  self:CompleteTaskByName("faketaskgoto2")
  Convo.ResetForFail()
  Convo.AddConvo("A3M3_KesslerFind_RightOffice_Start", 10, {
    sCallback = Act_3_Mission_3.AutoFireConversationAndTask
  })
  self.FindCyclotronRoom(self, false)
end

function Act_3_Mission_3:FindCyclotronRoom(bPlayOtherConvo)
  self:CreateTask({
    sName = "Missions\\act_3\\mission_3\\nazi_guardCod",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\act_3\\mission_3\\nazi_guardCod1",
      "Missions\\act_3\\mission_3\\nazi_guardCod2",
      "Missions\\act_3\\mission_3\\nazi_guardCod3",
      "Missions\\act_3\\mission_3\\nazi_guardCod4",
      "Missions\\act_3\\mission_3\\nazi_guardCod5"
    }
  })
  local sFocusLoc = "Missions\\act_3\\mission_3\\MissionObjectiveRelated\\LOC_CyclotronLoc"
  local sFocusPT = "Missions\\act_3\\mission_3\\MissionObjectiveRelated\\PT_CyclotronLoc"
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  local hLocator = Util.GetHandleByName("Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_KesslerRunToCyclotron")
  local t_tTimer = {EventType = "TimerEvent", Time = 4.5}
  self:RegisterEvent(Util.CreateEvent(t_tTimer, "Act_3_Mission_3.OpenDoorForKessler", self))
  local tempself = Actor.GetSelf(Util.GetHandleByName("Missions\\act_3\\mission_3\\missionobjectiverelated\\CC_A3M3_KesslerFind_WrongOffice1"))
  if tempself then
    ComplexConvo.DisableConvo(tempself)
  end
  tempself = Actor.GetSelf(Util.GetHandleByName("Missions\\act_3\\mission_3\\missionobjectiverelated\\CC_A3M3_KesslerFind_WrongOffice2"))
  if tempself then
    ComplexConvo.DisableConvo(tempself)
  end
  Actor.OverrideCombatAI(hKessler, true)
  Actor.SetUseHitReactions(hKessler, false)
  Squad.AddMember("Saboteur", hKessler)
  self.EnableSpinnazzz(self, false)
  Squad.SetEnemy("Saboteur", "GenericNazi", true)
end

function Act_3_Mission_3.AutoFireConversationAndTask()
  Act_3_Mission_3:CreateTask({
    sName = "KesslerRescueHackWOOT",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    bAutofire = true,
    sConvFile = "407_Con_Kessler-KesslerRescue",
    tTgtInclude = {
      "Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler"
    },
    tOnComplete = {
      {
        Act_3_Mission_3.MakeKesslerMoveAfterConvo,
        {Act_3_Mission_3}
      }
    }
  })
end

function Act_3_Mission_3.MoveKesslerOutOfDoor()
  local hLocMove = Handle("Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_KesslerMoveHere")
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  Nav.SetScriptedPath(hKessler, "Missions\\act_3\\mission_3\\missionobjectiverelated\\PATH_KesslerConvo", true)
end

function Act_3_Mission_3.FindCyclotronRoomFromConvo()
  Convo.AddConvo("A3M3_CyclotronGoto_Start", 10, {})
end

function Act_3_Mission_3.MakeKesslerMoveAfterConvo()
  local sFocusLoc = "Missions\\act_3\\mission_3\\MissionObjectiveRelated\\LOC_CyclotronLoc"
  local sFocusPT = "Missions\\act_3\\mission_3\\MissionObjectiveRelated\\PT_CyclotronLoc"
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  local hLocator = Util.GetHandleByName("Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_KesslerRunToCyclotron")
  Act_3_Mission_3:CreateTask({
    sName = "FindCyclotron",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "A3M3_Text.Locatecyclotron",
    ParentObjectID = Act_3_Mission_3:GetTaskObjectiveID("MainTask"),
    sTaskSubType = "GOTO",
    vGPSTarget = sFocusLoc,
    tLocators = {sFocusLoc},
    tDestRegion = sFocusPT,
    tDeliverObjs = {hSab, hKessler},
    tOnComplete = {
      {
        Act_3_Mission_3.SabotageCyclotronWithKessler,
        {Act_3_Mission_3}
      }
    },
    tOnCancel = {
      {
        Act_3_Mission_3.ClearOutNaziTask,
        {Act_3_Mission_3}
      }
    }
  })
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  Nav.SetScriptedPath(hKessler, "Missions\\act_3\\mission_3\\missionobjectiverelated\\PATH_Door", true, "Act_3_Mission_3.KesslerGotToDoor", Act_3_Mission_3, nil)
  Nav.SetScriptedPathMoveMode(hKessler, true)
end

function Act_3_Mission_3:KesslerGotToDoor()
  self:FailTaskByName("FindCyclotron")
  self.ConversationPlayer(self, "A3M3_CyclotronGoto_Blocked")
  self:RegisterEvent(self.hOpenDoorTimerConvo)
end

function Act_3_Mission_3:ClearOutNaziTask()
  Sound.SetMusicLocale("A3M3_DoppelsiegReturn")
  Sound.SetMusicLocale("m_A3M3_DoppelsiegReturn", "coverKessler")
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\a3m3_kessler\\Spore_RS_Kessler")
  local hAtpt1 = Handle("Missions\\act_3\\mission_3\\missionobjectiverelated\\AttractionPT_KesslerControl2")
  if hAtpt1 then
    Actor.RequestAttrPt(hKessler, hAtpt1)
  else
    Actor.PlayAnimation(hKessler, "sabotage_clippers_mid_idle")
  end
  self.nTimer = 0
  self.TempObjectiveID = HUD.AddObjective(eOT_HEART, SabTask:GetLocalizedText("A3M3_Text.UnlockDoor"), 2, self:GetTaskObjectiveID("MainTask"))
  HUD.SetupProgressBar(self.TempObjectiveID, 0, 30, 0)
  self.nSelfCounter = EVENT_Timer("Act_3_Mission_3.UpdateTimerInScript", self, 2)
  Render.ToggleLights(6661, false)
  Render.ToggleLights(6662, false)
  Render.ToggleLights(6663, false)
  Render.ToggleLights(6664, false)
  self:CreateTask({
    sName = "DEFENDKESSLERATDOOR",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "DEFEND",
    ParentObjectID = self:GetTaskObjectiveID("MainTask"),
    sObjectiveTextID = "A3M3_Text.GuardKessler",
    tLocators = {
      "Missions\\act_3\\mission_3\\a3m3_kessler\\Spore_RS_Kessler"
    },
    tTgtInclude = {
      "Missions\\act_3\\mission_3\\a3m3_kessler\\Spore_RS_Kessler"
    },
    tOnComplete = {
      {
        self.ReEnableStuffGoingToCyclotron,
        {self}
      }
    }
  })
end

function Act_3_Mission_3:UpdateTimerInScript()
  if self.nTimer < 30 then
    self.nSelfCounter = EVENT_Timer("Act_3_Mission_3.UpdateTimerInScript", self, 2)
    self.nTimer = self.nTimer + 2
    HUD.SetProgressBarValue(self.TempObjectiveID, self.nTimer)
  else
    self:CompleteTaskByName("DEFENDKESSLERATDOOR")
  end
end

function Act_3_Mission_3:ReEnableStuffGoingToCyclotron()
  Sound.SetMusicLocale("A3M3_DoppelsiegReturn")
  Sound.SetMusicLocale("m_A3M3_DoppelsiegReturn", "findControlRoom")
  local sFocusLoc = "Missions\\act_3\\mission_3\\MissionObjectiveRelated\\LOC_CyclotronLoc"
  local sFocusPT = "Missions\\act_3\\mission_3\\MissionObjectiveRelated\\PT_CyclotronLoc"
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  local hLocator = Util.GetHandleByName("Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_KesslerRunToCyclotron")
  Actor.CancelAnimation(hKessler)
  Actor.CancelAttrPtRequest(hKessler)
  HUD.RemoveObjective(self.TempObjectiveID)
  self.OpenCyclotronRoom(self)
  self:CreateTask({
    sName = "FindCyclotron2",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "A3M3_Text.Locatecyclotron",
    ParentObjectID = self:GetTaskObjectiveID("MainTask"),
    sTaskSubType = "GOTO",
    vGPSTarget = sFocusLoc,
    tLocators = {sFocusLoc},
    tDestRegion = sFocusPT,
    tDeliverObjs = {hSab, hKessler},
    tOnComplete = {
      {
        self.CanKesslerCinematicFire,
        {self}
      }
    }
  })
  HUD.RemoveObjectiveMarker(hKessler)
  HUD.SetObjectiveMarker(hKessler, cMMI_Escort, cOM_Escort, true, true)
end

function Act_3_Mission_3:CanKesslerCinematicFire()
  Object.ForceClose(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_Bay_Door(2)\\AnimatedObject_Dopple_Bay_Door"))
  Sound.PlayOwnerlessSoundEvent("a3m3_door_cyclotron_room_close")
  EVENT_PlayerEntersTrigger("Act_3_Mission_3.OpenDoorToCyclotron", self, "Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_OpenCyclotronDoor", true)
  self.hDoorCloseCyclotronEvent = EVENT_PlayerEntersTrigger("Act_3_Mission_3.CloseDoorToCyclotron", self, "Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_CloseCyclotronRoom", true)
  local hWhoToDamage = Filter.New("Nazi")
  local tWho = Trigger.GetAllWithin(Util.GetHandleByName("Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_KillInsideBefore"), hWhoToDamage)
  if tWho then
    local tEvent = {EventType = "TimerEvent", Time = 1}
    self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.CanKesslerCinematicFire", self))
  else
    self.SabotageCyclotronWithKessler(self)
  end
end

function Act_3_Mission_3:SabotageCyclotronWithKessler()
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  Nav.CancelScriptedPath(hKessler)
  Nav.FollowObject(hKessler, hSab, 0.5, true)
  EVENT_PlayerToActorProximity("Act_3_Mission_3.WhenKesslerIsNear", self, "Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler", 1, nil, false)
end

function Act_3_Mission_3:WhenKesslerIsNear()
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  Nav.CancelFollowObject(hKessler)
  Convo.AddConvo("407_Con_Kessler-AtCyclotron", 10, {
    sCallback = "Act_3_Mission_3.Checkpoint3"
  })
end

function Act_3_Mission_3.Checkpoint3()
  Act_3_Mission_3.RegisterCheckpoint(Act_3_Mission_3, "Act_3_Mission_3.SabotageCyclotronWithKesslerPart2")
end

function Act_3_Mission_3:SabotageCyclotronWithKesslerPart2()
  Render.WTFSetOverrideBlueprint("WillToFight_INT_Dopp_Car_low")
  Convo.ResetForFail()
  Suspicion.SetEscalated()
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  if hKessler then
    Combat.SetGrabbable(hKessler, false)
    Actor.SetNonKnockdownable(hKessler, true)
    Actor.SetLabel(hKessler, "nopush", true)
    Actor.SetUseHitReactions(hKessler, false)
  end
  HUD.RemoveObjectiveMarker(hKessler)
  HUD.SetObjectiveMarker(hKessler, cMMI_Escort, cOM_Escort, true, true)
  local tempself = Actor.GetSelf(Util.GetHandleByName("Missions\\act_3\\mission_3\\missionobjectiverelated\\CC_A3M3_KesslerFind_WrongOffice1"))
  if tempself then
    ComplexConvo.DisableConvo(tempself)
  end
  tempself = Actor.GetSelf(Util.GetHandleByName("Missions\\act_3\\mission_3\\missionobjectiverelated\\CC_A3M3_KesslerFind_WrongOffice2"))
  if tempself then
    ComplexConvo.DisableConvo(tempself)
  end
  Convo.ResetForFail()
  if self.TempObjectiveID then
    HUD.RemoveObjective(self.TempObjectiveID)
  end
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  local hLocator = Util.GetHandleByName("Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_KesslerRunToCyclotron")
  Nav.CancelFollowObject(hKessler)
  Actor.OverrideCombatAI(hKessler, true)
  Actor.SetUseHitReactions(hKessler, false)
  Squad.AddMember("Saboteur", hKessler)
  Combat.SetIdleScripted(hKessler, true)
  Render.ToggleLights(6661, false)
  Render.ToggleLights(6662, false)
  Render.ToggleLights(6663, false)
  Render.ToggleLights(6664, false)
  self.GoInsideCyclotronRoom2(self)
  self.ConversationPlayer(self, "A3M3_CyclotronSab_Start")
  self.tSaveInfo.WhoGotFirst = "Shitballs"
  self.tSaveInfo.bGotThePanel = false
  self.tSaveInfo.bTimeRanOut = false
  self.tSaveInfo.nFailTimes = 0
  self.tSaveInfo.KesserGotThereFirst = Util.CreateEvent({
    EventType = "ProximityEvent",
    ObjectA = hLocator,
    ObjectB = hKessler,
    Proximity = 6,
    Negate = false
  }, "Act_3_Mission_3.WhoGotThereFirst", self, {"Kessler"})
  self:RegisterEvent(self.tSaveInfo.KesserGotThereFirst)
  hLocator = Util.GetHandleByName("Missions\\act_3\\mission_3\\MissionObjectiveRelated\\SabPT1")
  self:RegisterEvent(Util.CreateEvent({
    EventType = "ProximityEvent",
    ObjectA = hLocator,
    ObjectB = hSab,
    Proximity = 1,
    Negate = false
  }, "Act_3_Mission_3.WhoGotThereFirst", self, {"Sean"}))
  AttractionPt.EnableUse(Util.GetHandleByName("Missions\\act_3\\mission_3\\MissionObjectiveRelated\\SabPT1"), false)
  local hFakeLoc = Util.GetHandleByName("Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_FakeUse")
  local hFakePT = Util.GetHandleByName("Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_FakeUse")
  self:CreateTask({
    sName = "FakeUseControlPanelTask",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "A3M3_Text.Triggeroffsequence",
    ParentObjectID = self:GetTaskObjectiveID("MainTask"),
    sTaskSubType = "GOTO",
    MarkerHeight = 0.5,
    tLocators = {hFakeLoc},
    tDestRegion = hFakePT,
    tDeliverObjs = {hSab},
    tOnComplete = {}
  })
end

function Act_3_Mission_3:CountDownTricksie(nCounter)
  if 0 < nCounter then
    if self.hUsePanelOnTime then
      Util.KillEvent(self.hUsePanelOnTime)
    end
    local tEvent = {EventType = "TimerEvent", Time = 0.8}
    self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.CountDownTricksie", self, {
      nCounter - 1
    }))
  elseif nCounter == 0 then
    Render.ToggleLights(6664, true)
    AttractionPt.EnableUse(Util.GetHandleByName("Missions\\act_3\\mission_3\\MissionObjectiveRelated\\SabPT1"), true)
    self.tSaveInfo.bGotThePanel = false
    self.tSaveInfo.bTimeRanOut = false
    if self.hUsePanelOnTime then
      Util.KillEvent(self.hUsePanelOnTime)
    end
    self.hUsePanelOnTime = Util.CreateEvent({
      EventType = "OnActorComplete",
      Target = Util.GetHandleByName("Missions\\act_3\\mission_3\\MissionObjectiveRelated\\SabPT1")
    }, "Act_3_Mission_3.SetupCheckpoint3pointtwo", self)
    self:RegisterEvent(self.hUsePanelOnTime)
    local tEvent = {EventType = "TimerEvent", Time = 4}
    self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.CountDownTricksie", self, {
      nCounter - 1
    }))
  elseif nCounter == -1 then
    Render.ToggleLights(6664, false)
    self.tSaveInfo.bTimeRanOut = true
    AttractionPt.EnableUse(Util.GetHandleByName("Missions\\act_3\\mission_3\\MissionObjectiveRelated\\SabPT1"), false)
    if self.tSaveInfo.bGotThePanel == false then
      if self.tSaveInfo.nFailTimes == 0 then
        Convo.AddConvo("A3M3_CyclotronSab_Switch_Fail_First", 10, {
          sCallback = "Act_3_Mission_3.FinalCountdownStart"
        })
      else
        Convo.AddConvo("A3M3_CyclotronSab_Switch_Fail_Other", 10, {
          sCallback = "Act_3_Mission_3.FinalCountdownStart"
        })
      end
    end
    if self.hUsePanelOnTime then
      Util.KillEvent(self.hUsePanelOnTime)
    end
    self.tSaveInfo.nFailTimes = 1
  end
end

function Act_3_Mission_3:SetupCheckpoint3pointtwo()
  self.RegisterCheckpoint(self, "Act_3_Mission_3.Checkpoint3pointtwo")
end

function Act_3_Mission_3:Checkpoint3pointtwo()
  Render.WTFSetOverrideBlueprint("WillToFight_INT_Dopp_Car_low")
  Sound.SetMusicLocale("A3M3_DoppelsiegReturn")
  Sound.SetMusicLocale("m_A3M3_DoppelsiegReturn", "destroyCoils")
  self.DoorSpawnerLogic(self)
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\a3m3_kessler\\Spore_RS_Kessler")
  Convo.ResetForFail()
  Suspicion.SetEscalated()
  if hKessler then
    Combat.SetGrabbable(hKessler, false)
    Actor.SetNonKnockdownable(hKessler, true)
    Actor.SetLabel(hKessler, "nopush", true)
    Actor.SetUseHitReactions(hKessler, false)
  end
  local hAtpt1 = Handle("Missions\\act_3\\mission_3\\missionobjectiverelated\\AttractionPT_KesslerControl1")
  if hAtpt1 then
    Actor.RequestAttrPt(hKessler, hAtpt1)
  else
    Actor.PlayAnimation(hKessler, "sabotage_clippers_mid_idle")
  end
  self.tSaveInfo.bTimeRanOut = false
  self.GetFourCornerTeslas(self)
end

function Act_3_Mission_3:GetFourCornerTeslas()
  if self.tSaveInfo.bTimeRanOut == false then
    self:CompleteTaskByName("FakeUseControlPanelTask")
    local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\a3m3_kessler\\Spore_RS_Kessler")
    local hAtpt1 = Handle("Missions\\act_3\\mission_3\\missionobjectiverelated\\AttractionPT_KesslerControl1")
    if hAtpt1 then
      Actor.RequestAttrPt(hKessler, hAtpt1)
    else
      Actor.PlayAnimation(hKessler, "sabotage_clippers_mid_idle")
    end
    self.EnableSpinnazzz(self, true)
    self.tSaveInfo.bGotThePanel = true
    self.SetupSpawn2(self)
    self.ConversationPlayer(self, "A3M3_CyclotronSab_Switch_Complete")
    self:CreateTask({
      sName = "FakeDestroyTask",
      sTaskType = "SabTaskObjectiveEmpty",
      sTaskSubType = "None",
      sObjectiveTextID = "A3M3_Text.Destroythecoils",
      ParentObjectID = self:GetTaskObjectiveID("MainTask")
    })
    self:CreateTask({
      sName = "Destroyallcoils",
      sTaskType = "SabTaskObjectiveDestroy",
      sTaskSubType = "KILL",
      MarkerHeight = 7,
      ParentObjectID = self:GetTaskObjectiveID("MainTask"),
      tTgtInclude = {
        "CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\Dopple_Cyclotron_TeslaCoil(3)"
      },
      tOnComplete = {
        {
          self.DestroyTesla2,
          {self}
        }
      }
    })
    self.tSaveInfo.CurrentCoil = 2
    self:RegisterEvent(Util.CreateEvent({
      EventType = "DeathEvent",
      ObjectHandle = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\Dopple_Cyclotron_TeslaCoil(3)")
    }, "Act_3_Mission_3.TeslaDeathCounter", self, {"b"}))
    self:RegisterEvent(Util.CreateEvent({
      EventType = "DeathEvent",
      ObjectHandle = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\Dopple_Cyclotron_TeslaCoil(5)")
    }, "Act_3_Mission_3.TeslaDeathCounter", self, {"d"}))
    self.StartTeslaShieldSequence(self)
  end
end

function Act_3_Mission_3:DestroyTesla2()
  Sound.PlayOwnerlessSoundEvent("a3m3_tesla_coil_explosion")
  self:CreateTask({
    sName = "Destroyallcoils2",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    MarkerHeight = 7,
    ParentObjectID = self:GetTaskObjectiveID("MainTask"),
    tTgtInclude = {
      "CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\Dopple_Cyclotron_TeslaCoil(5)"
    },
    tOnActivate = {
      {
        self.ActivateElevator,
        {self, 1}
      },
      {
        self.ActivateElevator,
        {self, 2}
      },
      {
        self.ActivateElevator,
        {self, 3}
      }
    },
    tOnComplete = {
      {
        self.SetupCheckpoint3point5,
        {self}
      }
    }
  })
end

function Act_3_Mission_3:DestroyTesla3()
  self:CreateTask({
    sName = "Destroyallcoils3",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    MarkerHeight = 7,
    ParentObjectID = self:GetTaskObjectiveID("MainTask"),
    tTgtInclude = {
      "CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\Dopple_Cyclotron_TeslaCoil(8)"
    },
    tOnActivate = {
      {
        self.ActivateElevator,
        {self, 1}
      },
      {
        self.ActivateElevator,
        {self, 2}
      },
      {
        self.ActivateElevator,
        {self, 3}
      }
    },
    tOnComplete = {
      {
        self.SetupCheckpoint3point5,
        {self}
      }
    }
  })
end

function Act_3_Mission_3:SetupCheckpoint3point5()
  self.RegisterCheckpoint(self, "Act_3_Mission_3.Checkpoint3point5")
end

function Act_3_Mission_3:Checkpoint3point5()
  Render.WTFSetOverrideBlueprint("WillToFight_INT_Dopp_Car_low")
  Sound.SetMusicLocale("A3M3_DoppelsiegReturn")
  Sound.SetMusicLocale("m_A3M3_DoppelsiegReturn", "destroyCore")
  self.DoorSpawnerLogic(self)
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\a3m3_kessler\\Spore_RS_Kessler")
  Convo.ResetForFail()
  Suspicion.SetEscalated()
  if hKessler then
    Combat.SetGrabbable(hKessler, false)
    Actor.SetNonKnockdownable(hKessler, true)
    Actor.SetLabel(hKessler, "nopush", true)
    Actor.SetUseHitReactions(hKessler, false)
  end
  local hAtpt1 = Handle("Missions\\act_3\\mission_3\\missionobjectiverelated\\AttractionPT_KesslerControl1")
  if hAtpt1 then
    Actor.RequestAttrPt(hKessler, hAtpt1)
  else
    Actor.PlayAnimation(hKessler, "sabotage_clippers_mid_idle")
  end
  self.SabotageTheCyclotron(self)
end

function Act_3_Mission_3:DestroyTesla4()
  self:CreateTask({
    sName = "Destroyallcoils4",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    MarkerHeight = 7,
    ParentObjectID = self:GetTaskObjectiveID("MainTask"),
    tTgtInclude = {
      "CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\Dopple_Cyclotron_TeslaCoil(3)"
    },
    tOnComplete = {
      {
        self.SabotageTheCyclotron,
        {self}
      }
    }
  })
end

function Act_3_Mission_3:SabotageTheCyclotron()
  Sound.PlayOwnerlessSoundEvent("a3m3_tesla_coil_explosion")
  Sound.PlayOwnerlessSoundEvent("a3m3_cyclotron_startup")
  local hCyclotron = Handle("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\Dopple_Cyclotron_Middle_Upper")
  Object.SetInvincible(hCyclotron, false)
  self:CompleteTaskByName("FakeDestroyTask")
  Object.ForceOpen(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_Cyclotron_Top"))
  self.ConversationPlayer(self, "A3M3_Core_Start")
  local tEvent = {EventType = "TimerEvent", Time = 3}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ConversationPlayer", self, {
    "A3M3_Core_Exposed"
  }))
  Object.ForceOpen(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_Bay_Door(2)\\AnimatedObject_Dopple_Bay_Door"))
  self.TempObjectiveID = HUD.AddObjective(eOT_HEART, SabTask:GetLocalizedText("A3M3_Text.CyclotronHealth"), 2, self:GetTaskObjectiveID("MainTask"))
  HUD.SetupProgressBar(self.TempObjectiveID, Handle("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\Dopple_Cyclotron_Middle_Upper"))
  Util.KillEvent(self.hDoorCloseCyclotronEvent)
  EVENT_KillEvent(self.hDoorCloseCyclotronEvent)
  Trigger.Enable("Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_CloseCyclotronRoom", false)
  Sound.PlayOwnerlessSoundEvent("a3m3_cyclotron_start_up")
  self:CreateTask({
    sName = "BlowUpCyclotron",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    ParentObjectID = self:GetTaskObjectiveID("MainTask"),
    tTgtInclude = {
      "CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\Dopple_Cyclotron_Middle_Upper"
    },
    tOnActivate = {
      {
        self.ActivateElevator,
        {self, 1}
      },
      {
        self.ActivateElevator,
        {self, 2}
      },
      {
        self.ActivateElevator,
        {self, 3}
      }
    },
    sObjectiveTextID = "A3M3_Text.DestroyCore",
    tSMEDNodes = {
      "Missions\\act_3\\mission_3\\escapesequence"
    },
    tOnComplete = {
      {
        self.Checkpoint4Delay,
        {self}
      }
    }
  })
end

function Act_3_Mission_3:Checkpoint4Delay()
  if Object.IsAlive(hSab) == true then
    local tEvent = {EventType = "TimerEvent", Time = 1}
    self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.SetupCheckpoint4", self))
  end
end

function Act_3_Mission_3:SetupCheckpoint4()
  Sound.PlayOwnerlessSoundEvent("a3m3_cyclotron_explosion")
  self.RegisterCheckpoint(self, "Act_3_Mission_3.Checkpoint4")
end

function Act_3_Mission_3:Checkpoint4()
  Render.WTFSetOverrideBlueprint("WillToFight_INT_Dopp_Car_low")
  Convo.ResetForFail()
  self:UnloadTaskNodes("Missions\\act_3\\mission_3\\sound", true)
  Suspicion.SetEscalated()
  Sound.SetMusicLocale("A3M3_DoppelsiegReturn")
  Sound.SetMusicLocale("m_A3M3_DoppelsiegReturn", "Escape")
  Util.LoadStaticENTag("A3M3_FactoryFX", true)
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  if hKessler then
    Combat.SetGrabbable(hKessler, false)
    Actor.SetNonKnockdownable(hKessler, true)
    Actor.SetLabel(hKessler, "nopush", true)
    Actor.SetUseHitReactions(hKessler, false)
    local x, y, z = Object.GetPosition(Handle("Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_TeleportKesslerTemp"))
    local rot = Object.GetAngle(Handle("Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_TeleportKesslerTemp"))
    Object.Teleport(hKessler, x, y, z, rot)
  end
  HUD.RemoveObjectiveMarker(hKessler)
  HUD.SetObjectiveMarker(hKessler, cMMI_Escort, cOM_Escort, true, true)
  local tempself = Actor.GetSelf(Util.GetHandleByName("Missions\\act_3\\mission_3\\missionobjectiverelated\\CC_A3M3_KesslerFind_WrongOffice1"))
  if tempself then
    ComplexConvo.DisableConvo(tempself)
  end
  tempself = Actor.GetSelf(Util.GetHandleByName("Missions\\act_3\\mission_3\\missionobjectiverelated\\CC_A3M3_KesslerFind_WrongOffice2"))
  if tempself then
    ComplexConvo.DisableConvo(tempself)
  end
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  local hLocator = Util.GetHandleByName("Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_Escape")
  HUD.RemoveObjective(self.TempObjectiveID)
  Object.ForceOpen(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_Bay_Door(2)\\AnimatedObject_Dopple_Bay_Door"))
  Actor.OverrideCombatAI(hKessler, true)
  Actor.SetUseHitReactions(hKessler, false)
  Squad.AddMember("Saboteur", hKessler)
  Combat.SetIdleScripted(hKessler, true)
  HUD.SetObjectiveMarker(hKessler, 1, 10)
  self.SetupEscapeStuff(self)
  self.EscExpLoop(self)
  self.ExplodyCyclotron(self)
  Actor.CancelAnimation(hKessler)
  Actor.CancelAttrPt(hKessler)
  Actor.CancelAttrPtRequest(hKessler)
  self.ConversationPlayer(self, "A3M3_Core_Destroyed")
  self.SetupWhoGotToEscapeDoorFirst(self)
  Actor.OverrideCombatAI(hKessler, true)
  Nav.SetScriptedPath(hKessler, "Missions\\act_3\\mission_3\\missionobjectiverelated\\PATH_Escape", true, "Act_3_Mission_3.EscapeSequence2", self)
  Nav.SetScriptedPathMoveMode(hKessler, true)
  self.EscapeDoppelseigPart2(self)
end

function Act_3_Mission_3:EscapeDoppelseigPart2()
  local sFocusLoc = "Missions\\act_3\\mission_3\\MissionObjectiveRelated\\LOC_Escape"
  local sFocusPT = "Missions\\act_3\\mission_3\\MissionObjectiveRelated\\PT_Escape"
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  local tEvent = {EventType = "TimerEvent", Time = 3}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ConversationPlayer", self, {
    "A3M3_Escape_Follow"
  }))
  self:CreateTask({
    sName = "Escapetotheexit",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "A3M3_Text.Findexit",
    ParentObjectID = self:GetTaskObjectiveID("MainTask"),
    sTaskSubType = "GOTO",
    vGPSTarget = sFocusLoc,
    tLocators = {sFocusLoc},
    tDestRegion = sFocusPT,
    tDeliverObjs = {hSab},
    tSMEDNodes = {
      "Missions\\act_3\\mission_3\\sound_exit",
      "Missions\\act_3\\mission_3\\nazi_escape_factory"
    },
    tOnComplete = {
      {
        self.MissionComplete,
        {self}
      }
    }
  })
  HUD.RemoveObjectiveMarker(hKessler)
  HUD.SetObjectiveMarker(hKessler, cMMI_Escort, cOM_Escort, true, true)
end

function Act_3_Mission_3:Reset()
  if self.bTowerGlitchLoaded == true then
    Util.UnloadStaticENTag("A3M3_TowerGlitch", true)
  end
  Vehicle.EnableTraffic(true, true)
  Render.WTFClearOverrideBlueprint()
  Util.UnloadStaticENTag("A3M3_ElevatorLights", true)
  Util.UnloadStaticENTag("a3m3_skylarplane1", true)
  Util.UnloadStaticENTag("Dopp_2nd_Door", true)
  Util.UnloadStaticENTag("A3M3_FactoryFX", true)
  Util.UnloadStaticENTag("A3M3_MariaRoom", true)
  Util.UnloadStaticENTag("a3m3_planefxdrop1", true)
  Sound.ResetMusicLocale()
  Convo.ResetForFail()
end

function Act_3_Mission_3:MissionComplete()
  Sound.ResetMusicLocale()
  self.CleanUp(self)
  Sound.ResetMusicLocale()
  Sound.ReleaseSoundBank("M_a3m3_inGame.bnk")
  Suspicion.ResetEscalation()
  Util.UnloadEditNode("Missions\\act_3\\mission_3\\factory_shootout\\OfficeAttack.wsd", true, false)
  Util.UnloadStaticENTag("A3M3_FactoryFX", true)
  Util.UnloadStaticENTag("A3M3_MariaRoom", true)
  Util.UnloadStaticENTag("a3m3_planefxdrop1", true)
  self:CompleteThisMission()
end

function Act_3_Mission_3:CleanUp()
  Util.UnloadEditNode("Missions\\act_3\\mission_3\\nazi_escape_factory.wsd", true, true)
end

function Act_3_Mission_3:ExplodyCyclotron()
  local nTimerValue = 0
  for i = 1, 5 do
    local tEvent = {EventType = "TimerEvent", Time = nTimerValue}
    self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ParticleSpawn", self, {
      "Missions\\act_3\\mission_3\\escapesequence\\CExp" .. i,
      {
        "0FX_Explosion01"
      }
    }))
    nTimerValue = nTimerValue + 0.2
  end
end

function Act_3_Mission_3:SetupEscapeStuff()
  for i = 1, 13 do
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\escapesequence\\PT_Deb" .. i, hSab, "Act_3_Mission_3.BlowShitUpDuringEscape", self, {i}, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_3\\escapesequence\\PT_Deb" .. i)
  end
end

function Act_3_Mission_3:BlowShitUpDuringEscape(hWho, tUserData)
  local hDeb = Handle("Missions\\act_3\\mission_3\\escapesequence\\fx" .. tUserData)
  Sound.PlayOwnerlessSoundEvent("exp_dopp_medium")
  if hDeb then
    Render.StartFX(hDeb, "0FX_Explosion01", nil)
    hDeb = Handle("Missions\\act_3\\mission_3\\escapesequence\\fx" .. tUserData .. "(1)")
    Render.StartFX(hDeb, "PHPFX_Concrete_EXP_A_Medium", nil)
    hDeb = Handle("Missions\\act_3\\mission_3\\escapesequence\\fx" .. tUserData .. "(2)")
    Render.StartFX(hDeb, "PHPFX_Metal_EXP_A_Medium", nil)
    local x, y, z = Object.GetPosition(hSab)
    Render.CameraShakeExplosion(x, y, z, 20, 10, 12)
  end
end

function Act_3_Mission_3:OnButtonPress(a_tButtonData)
  local tButtons = a_tButtonData[1]
  if tButtons.UP == true then
  end
end

function Act_3_Mission_3:SetupTriggerPlanes()
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\dynamic_triggers\\Planebomb1", hSab, "Act_3_Mission_3.PlayCinematicSkylar", self, {
    "A3M3_Skylar_FirstFly",
    "Task_skylarflyshot"
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_3\\dynamic_triggers\\Planebomb1")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\dynamic_triggers\\Planebomb2", hSab, "Act_3_Mission_3.PlayCinematicSkylar", self, {
    "A3M3_Skyler_Flyby_02",
    nil
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_3\\dynamic_triggers\\Planebomb2")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\dynamic_triggers\\Planebomb3", hSab, "Act_3_Mission_3.PlayCinematicSkylarShooter", self, {
    "A3M3_Skyler_Flyby_03",
    nil
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_3\\dynamic_triggers\\Planebomb3")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\dynamic_triggers\\Planebomb4", hSab, "Act_3_Mission_3.PlayCinematicSkylar", self, {
    "A3M3_Skyler_Flyby_04",
    "Task_Flyby4"
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_3\\dynamic_triggers\\Planebomb4")
end

function Act_3_Mission_3:PlayCinematicSkylar(hwho, sName, sDespawnTask)
  if sName == "A3M3_Skylar_FirstFly" then
    Util.UnloadStaticENTag("a3m3_skylarplane1", true)
    Cin.PlayCinematic("A3M3_Skylar_FirstFly_Cam", false, "Act_3_Mission_3.SetupDestroyedStateOfBombing", self, nil, false, "")
    local tEvent = {EventType = "TimerEvent", Time = 1}
    self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.BrakeCarForCinematic", self))
  else
    Cin.PlayCinematic(sName, false, "Act_3_Mission_3.DespawnTaskNodeForPlanes", self, {sDespawnTask}, false, "")
  end
end

function Act_3_Mission_3.PlayFirstCinematicCustom()
  Convo.AddConvo("A3M3_SkylarBomb_00", 10, {})
  Cin.PlayCinematic("A3M3_Skylar_FirstFly", false, "Act_3_Mission_3.DespawnTaskNodeForPlanes", Act_3_Mission_3, {
    "Task_skylarflyshot"
  }, false, "")
end

function Act_3_Mission_3:DespawnTaskNodeForPlanes(hwhat, sName)
  if sName ~= nil then
    self:UnloadTaskNodes(sName, true)
  end
end

function Act_3_Mission_3:BrakeCarForCinematic()
  local hVehicle = Actor.GetVehicle(hSab)
  if hVehicle then
    Vehicle.HardSetLinVel(hVehicle, 0)
  end
  Actor.TurnOnDude(hSab, false)
  local hVeronique = Util.GetHandleByName("Missions\\act_3\\mission_3\\starter\\A3M3_Veronique")
  Actor.TurnOnDude(hVeronique, false)
end

function Act_3_Mission_3:SetupDestroyedStateOfBombing()
  self.bTowerGlitchLoaded = false
  Util.UnloadStaticENTag("A3M3_TowerGlitch", true)
  local hVehicle = Actor.GetVehicle(hSab)
  if hVehicle then
    Vehicle.HardSetLinVel(hVehicle, 15)
  end
  Actor.TurnOnDude(hSab, true)
  local hVeronique = Util.GetHandleByName("Missions\\act_3\\mission_3\\starter\\A3M3_Veronique")
  Actor.TurnOnDude(hVeronique, true)
  Cin.LoadCinematic("406_CinB_Maria")
  local tKillObjects = {
    "Missions\\act_3\\mission_3\\drive_to_factory\\VH_NZ_TR_OpelCanvas_02",
    "Missions\\act_3\\mission_3\\drive_to_factory\\VH_NZ_TR_OpelCanvas_01(2)",
    "Missions\\act_3\\mission_3\\drive_to_factory\\VH_NZ_TR_OpelCanvas_01(7)",
    "Missions\\act_3\\mission_3\\drive_to_factory\\VH_NZ_TR_OpelCanvas_01(6)",
    "Missions\\act_3\\mission_3\\drive_to_factory\\OccLt_WatchTower_MED_Tower(4)"
  }
  for i, v in ipairs(tKillObjects) do
    self:RegisterEvent(Util.CreateEvent({
      EventType = "StreamEvent",
      Objects = {v},
      WaitForGameObject = true
    }, "Act_3_Mission_3.StreamInAndDestroy", self, {v}))
  end
end

function Act_3_Mission_3:StreamInAndDestroy(sObject)
  local hObject = Handle(sObject)
  if hObject then
    Object.Kill(hObject)
  end
end

function Act_3_Mission_3:PlayCinematicSkylarShooter()
  Util.AddSplinePlaneAttackObject("Missions\\act_3\\mission_3\\dyn_skyler_bomb_03\\new cinsplinenode chain", 100, false, Handle("Missions\\act_3\\mission_3\\dyn_skyler_bomb_03\\VH_OP_HE111_SPLINE"), true, 1, nil, nil, nil, "PROP_NO_PL_P61Skylar_spline")
  Cin.PlayCinematic("A3M3_Skyler_Flyby_03")
end

function Act_3_Mission_3:StreamEventsOnPlanes()
  self:CreateTask({
    sName = "Missions\act_3mission_3dyn_skyler_bomb_01",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\act_3\\mission_3\\dyn_skyler_bomb_01"
    }
  })
  self:CreateTask({
    sName = "Task_skylarflyshot",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\act_3\\mission_3\\skylarflyshot"
    }
  })
  self:CreateTask({
    sName = "Missions\act_3mission_3dyn_skyler_bomb_02",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\act_3\\mission_3\\dyn_skyler_bomb_02"
    }
  })
  self:CreateTask({
    sName = "Missions\act_3mission_3dyn_skyler_bomb_03",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\act_3\\mission_3\\dyn_skyler_bomb_03"
    }
  })
  self:CreateTask({
    sName = "Task_Flyby4",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\act_3\\mission_3\\dyn_skyler_bomb_04"
    }
  })
  local tEvent = {
    EventType = "StreamEvent",
    Objects = {
      "Missions\\act_3\\mission_3\\dyn_skyler_bomb_03\\VH_OP_HE111_SPLINE",
      "Missions\\act_3\\mission_3\\dyn_skyler_bomb_03\\VH_OP_HE111_SPLINE(2)"
    }
  }
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.SetInvuln", self))
end

function Act_3_Mission_3:SetInvuln()
  local hPlane = Handle("Missions\\act_3\\mission_3\\dyn_skyler_bomb_03\\VH_OP_HE111_SPLINE")
  if hPlane then
    Object.SetInvincible(hPlane, true)
  end
  hPlane = Handle("Missions\\act_3\\mission_3\\dyn_skyler_bomb_03\\VH_OP_HE111_SPLINE(2)")
  if hPlane then
    Object.SetInvincible(hPlane, true)
  end
end

function Act_3_Mission_3:PlaySkylarBombingCinematic(sCinName)
  Cin.PlayCinematic(sCinName)
end

function Act_3_Mission_3:SetupChargers()
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\nazi_enc\\enc2\\PT_Charge", hSab, "Act_3_Mission_3.ChargeAndGo", self, {
    "Missions\\act_3\\mission_3\\nazi_enc\\enc2\\spawn",
    2,
    nil
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_3\\nazi_enc\\enc2\\PT_Charge")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\nazi_enc\\enc3\\PT_Charge", hSab, "Act_3_Mission_3.ChargeAndGo", self, {
    "Missions\\act_3\\mission_3\\nazi_enc\\enc3\\spawn",
    2,
    "CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\2nd_floor\\Dopp_2ndFloor\\Dopple_Interro_Office_Door(2)",
    "CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\2nd_floor\\Dopp_2ndFloor\\Dopple_Interro_Office_Door(1)"
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_3\\nazi_enc\\enc3\\PT_Charge")
end

function Act_3_Mission_3:ChargeAndGo(hWho, sString, nMax, sDoor, sDoorCloseIt)
  local nCounter
  for nCounter = 1, nMax do
    local hNazi = Util.GetHandleByName(sString .. nCounter)
    if hNazi then
      Combat.SetAlwaysSeeTarget(hNazi, true)
      Nav.MoveToObject(hNazi, hSab, 5, true)
      Combat.SetObjective(hNazi, hSab, true, 10, false)
      Combat.SetCombat(hNazi)
    end
  end
  if sDoor ~= nil then
    Sound.AttachSoundEvent(Util.GetHandleByName(sDoor), "a3m3_nazi_kick_down_door")
    Object.ForceOpen(Util.GetHandleByName(sDoor))
  end
  if sDoorCloseIt ~= nil then
    Object.ForceClose(Util.GetHandleByName(sDoorCloseIt))
  end
end

function Act_3_Mission_3:SetupSpawn1()
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\act_3\\mission_3\\nazi_spawn_1\\Spawn_1",
      "Missions\\act_3\\mission_3\\nazi_spawn_1\\Spawn_2",
      "Missions\\act_3\\mission_3\\nazi_spawn_1\\Spawn_3",
      "Missions\\act_3\\mission_3\\nazi_spawn_1\\Spawn_4",
      "Missions\\act_3\\mission_3\\nazi_spawn_1\\Spawn_5",
      "Missions\\act_3\\mission_3\\nazi_spawn_1\\Spawn_6",
      "Missions\\act_3\\mission_3\\nazi_spawn_1\\Spawn_7",
      "Missions\\act_3\\mission_3\\nazi_spawn_1\\Spawn_8",
      "Missions\\act_3\\mission_3\\nazi_spawn_1\\Spawn_9",
      "Missions\\act_3\\mission_3\\nazi_spawn_1\\Spawn_10"
    },
    WaitForGameObject = true
  }, "Act_3_Mission_3.GoToPlayerAndKill", self, {
    "Missions\\act_3\\mission_3\\nazi_spawn_1\\Spawn_",
    10
  }))
end

function Act_3_Mission_3:SetupSpawn2()
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\act_3\\mission_3\\nazi_spawn_2\\Spawn_1",
      "Missions\\act_3\\mission_3\\nazi_spawn_2\\Spawn_2",
      "Missions\\act_3\\mission_3\\nazi_spawn_2\\Spawn_3",
      "Missions\\act_3\\mission_3\\nazi_spawn_2\\Spawn_4",
      "Missions\\act_3\\mission_3\\nazi_spawn_2\\Spawn_5",
      "Missions\\act_3\\mission_3\\nazi_spawn_2\\Spawn_6",
      "Missions\\act_3\\mission_3\\nazi_spawn_2\\Spawn_7",
      "Missions\\act_3\\mission_3\\nazi_spawn_2\\Spawn_8",
      "Missions\\act_3\\mission_3\\nazi_spawn_2\\Spawn_9"
    },
    WaitForGameObject = true
  }, "Act_3_Mission_3.GoToPlayerAndKill", self, {
    "Missions\\act_3\\mission_3\\nazi_spawn_2\\Spawn_",
    9
  }))
end

function Act_3_Mission_3:SetupSpawn3()
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\act_3\\mission_3\\nazi_spawn_3\\Spawn_1",
      "Missions\\act_3\\mission_3\\nazi_spawn_3\\Spawn_2",
      "Missions\\act_3\\mission_3\\nazi_spawn_3\\Spawn_3",
      "Missions\\act_3\\mission_3\\nazi_spawn_3\\Spawn_4",
      "Missions\\act_3\\mission_3\\nazi_spawn_3\\Spawn_5",
      "Missions\\act_3\\mission_3\\nazi_spawn_3\\Spawn_6",
      "Missions\\act_3\\mission_3\\nazi_spawn_3\\Spawn_7"
    },
    WaitForGameObject = true
  }, "Act_3_Mission_3.GoToPlayerAndKill", self, {
    "Missions\\act_3\\mission_3\\nazi_spawn_3\\Spawn_",
    7
  }))
end

function Act_3_Mission_3:GoToPlayerAndKill(sPath, nNumber)
  local nCounter
  for nCounter = 1, nNumber do
    local hNazi = Util.GetHandleByName(sPath .. nCounter)
    if hNazi then
      Nav.MoveToPoint(hNazi, 2950, 126, -2955, true)
    end
  end
end

function Act_3_Mission_3:AbandonedVero()
  local hVeronique = Util.GetHandleByName("Missions\\act_3\\mission_3\\starter\\A3M3_Veronique")
  self.ConversationPlayer(self, "A3M3_Veronique_Abandon")
  self.tSaveInfo.Event_A3M3_Veronique_Return = Util.CreateEvent({
    EventType = "ProximityEvent",
    ObjectA = hVeronique,
    ObjectB = hSab,
    Proximity = 5,
    Negate = false
  }, "Act_3_Mission_3.ConversationPlayer", self, {
    "A3M3_Veronique_Return"
  })
  self:RegisterEvent(self.tSaveInfo.Event_A3M3_Veronique_Return)
end

function Act_3_Mission_3:SkylarInitialEncounterStart()
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\nazifirstencounter\\PT_PlayerHarass1", hSab, "Act_3_Mission_3.PlaneHarassers", self, {}, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_3\\nazifirstencounter\\PT_PlayerHarass1")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\nazifirstencounter\\PT_PlayerHarass2", hSab, "Act_3_Mission_3.PlaneHarassers2", self, {}, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_3\\nazifirstencounter\\PT_PlayerHarass2")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\nazifirstencounter\\PT_SkylarFly", hSab, "Act_3_Mission_3.PlaneGoFly", self, {}, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_3\\nazifirstencounter\\PT_SkylarFly")
end

function Act_3_Mission_3:PlaneHarassers()
  Util.AddSplinePlaneAttackObject("Missions\\act_3\\mission_3\\missionobjectiverelated\\planeharass1", 130, false, hSab, false, 1)
  local tEvent = {EventType = "TimerEvent", Time = 0.4}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.PlaneHarassers1b", self))
end

function Act_3_Mission_3:PlaneHarassers1b()
  Util.AddSplinePlaneAttackObject("Missions\\act_3\\mission_3\\missionobjectiverelated\\planeharass2", 130, false, hSab, false, 1)
  local tEvent = {EventType = "TimerEvent", Time = 0.2}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.PlaneHarassers1c", self))
end

function Act_3_Mission_3:PlaneHarassers1c()
  Util.AddSplinePlaneAttackObject("Missions\\act_3\\mission_3\\missionobjectiverelated\\planeharass3", 130, false, hSab, false, 1)
end

function Act_3_Mission_3:PlaneHarassers2()
  Util.AddSplinePlaneAttackObject("Missions\\act_3\\mission_3\\missionobjectiverelated\\planeharass4", 130, false, hSab, false, 1)
  local tEvent = {EventType = "TimerEvent", Time = 0.3}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.PlaneHarassers2b", self))
end

function Act_3_Mission_3:PlaneHarassers2b()
  Util.AddSplinePlaneAttackObject("Missions\\act_3\\mission_3\\missionobjectiverelated\\planeharass5", 130, false, hSab, false, 1)
  local tEvent = {EventType = "TimerEvent", Time = 0.1}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.PlaneHarassers2c", self))
end

function Act_3_Mission_3:PlaneHarassers2c()
  Util.AddSplinePlaneAttackObject("Missions\\act_3\\mission_3\\missionobjectiverelated\\planeharass6", 130, false, hSab, false, 1)
end

function Act_3_Mission_3:PlaneGoFly()
end

function Act_3_Mission_3:TrucksLoadedIn()
  local tEvent = {EventType = "TimerEvent", Time = 2}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.AnotherDelay", self))
  local hTruck = Handle("Missions\\act_3\\mission_3\\nazifirstencounter\\truck1")
  Vehicle.StartPlayback(hTruck, "A3M3_Truck1.vcr", "Act_3_Mission_3.Truck1Out")
end

function Act_3_Mission_3.Truck1Out()
  local hVehicle = Handle("Missions\\act_3\\mission_3\\nazifirstencounter\\truck1")
  Vehicle.UnboardAll(hVehicle, false, "Act_3_Mission_3.ShootDummy", self, nil)
end

function Act_3_Mission_3:AnotherDelay()
  local hTruck = Handle("Missions\\act_3\\mission_3\\nazifirstencounter\\truck2")
  Nav.SetScriptedPath(hTruck, "Missions\\act_3\\mission_3\\nazifirstencounter\\path2", true, "Act_3_Mission_3.TempUnboard", self, {hTruck})
  Nav.SetScriptedPathSpeed(hTruck, 25)
  hTruck = Handle("Missions\\act_3\\mission_3\\nazifirstencounter\\truck3")
  Nav.SetScriptedPath(hTruck, "Missions\\act_3\\mission_3\\nazifirstencounter\\path3", true, "Act_3_Mission_3.TempUnboard", self, {hTruck})
  Nav.SetScriptedPathSpeed(hTruck, 50)
  local tEvent = {EventType = "TimerEvent", Time = 2}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.PlaneGoFly", self))
  tEvent = {EventType = "TimerEvent", Time = 7.5}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.KillTrucks", self))
  tEvent = {EventType = "TimerEvent", Time = 7.5}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.PlaneChasers1", self))
end

function Act_3_Mission_3:PlaneChasers1()
  Util.AddSplinePlaneAttackObject("Missions\\act_3\\mission_3\\missionobjectiverelated\\plane1", 1, false, hSab, true, 1, nil, nil, nil, "PROP_NO_PL_P61Skylar_spline")
  Util.AddSplinePlaneAttackObject("Missions\\act_3\\mission_3\\missionobjectiverelated\\plane2", 1, false, hSab, true, 1, nil, nil, nil, "PROP_NO_PL_P61Skylar_spline")
  Util.AddSplinePlaneAttackObject("Missions\\act_3\\mission_3\\missionobjectiverelated\\plane3", 1, false, hSab, true, 1, nil, nil, nil, "PROP_NO_PL_P61Skylar_spline")
end

function Act_3_Mission_3:KillTrucks()
  local hHandle1 = Handle("Missions\\act_3\\mission_3\\nazifirstencounter\\truck1")
  if hHandle1 then
    local x, y, z = Object.GetPosition(hHandle1)
    Object.Kill(hHandle1)
  end
  local tEvent = {EventType = "TimerEvent", Time = 0.5}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.KillTruck2", self))
end

function Act_3_Mission_3:KillTruck2()
  local hHandle3 = Handle("Missions\\act_3\\mission_3\\nazifirstencounter\\truck3")
  if hHandle3 then
    local x, y, z = Object.GetPosition(hHandle3)
    Object.Kill(hHandle3)
  end
end

function Act_3_Mission_3:UnboardAndSHOOT(hWhat)
  Vehicle.UnboardAll(hWhat, false, "Act_3_Mission_3.ShootDummy", self, nil)
end

function Act_3_Mission_3:TempUnboard(hWhat)
  Vehicle.UnboardAll(hWhat, false, "Act_3_Mission_3.GoHostile", self, nil)
end

function Act_3_Mission_3:GoHostile(tArgs)
  Combat.SetHunt(tArgs[1], hSab, true, false)
  Combat.SetReactImmediately(tArgs[1], true)
  Combat.SetRespondToEvents(tArgs[1], false)
  Combat.SetAlwaysSeeTarget(tArgs[1], true)
  Combat.LockIntoRanged(tArgs[1])
  Combat.SetTarget(tArgs[1], hSab)
  Combat.SetLethalForce(tArgs[1], true)
  Combat.SetCombat(tArgs[1])
end

function Act_3_Mission_3:ShootDummy(tArgs)
  local hHandle = tArgs[1]
  local hTarget = WRAPPER_CheckForHandle("Missions\\act_3\\mission_3\\nazifirstencounter\\target" .. math.random(1, 3))
  Combat.SetReactImmediately(hHandle, true)
  Combat.SetAimAndHitNoMiss(hHandle, true)
  Combat.SetRespondToEvents(hHandle, false)
  Combat.SetAlwaysSeeTarget(hHandle, true)
  Combat.LockIntoRanged(hHandle)
  Combat.SetTarget(hHandle, hTarget)
  Combat.SetLethalForce(hHandle, true)
  Combat.SetCombat(hHandle)
  local tEvent = {EventType = "TimerEvent", Time = 6}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.SetNormalCombat", self, {hWho}))
end

function Act_3_Mission_3:SetNormalCombat(hHandle)
  Combat.SetReactImmediately(hHandle, true)
  Combat.SetAimAndHitNoMiss(hHandle, false)
  Combat.SetRespondToEvents(hHandle, false)
  Combat.SetAlwaysSeeTarget(hHandle, true)
  Combat.LockIntoRanged(hHandle)
  Combat.SetTarget(hHandle, hSab)
  Combat.SetLethalForce(hHandle, true)
  Combat.SetCombat(hHandle)
end

function Act_3_Mission_3.SkylarBomb1()
  Sound.PlayOwnerlessSoundEvent("a3m3_bombs_incoming")
  local tEvent = {}
  tEvent = {EventType = "TimerEvent", Time = 0}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\skylarflyshot\\flyby1_1")
  }))
  tEvent = {EventType = "TimerEvent", Time = 0.6}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\skylarflyshot\\flyby1_2")
  }))
  tEvent = {EventType = "TimerEvent", Time = 1.2}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\skylarflyshot\\flyby1_3")
  }))
  tEvent = {EventType = "TimerEvent", Time = 1.8}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\skylarflyshot\\flyby1_4")
  }))
  tEvent = {EventType = "TimerEvent", Time = 2.4}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\skylarflyshot\\flyby1_5")
  }))
  tEvent = {EventType = "TimerEvent", Time = 3}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\skylarflyshot\\flyby1_6")
  }))
end

function Act_3_Mission_3.SkylarBomb2()
  Sound.PlayOwnerlessSoundEvent("a3m3_bombs_incoming")
  local tEvent = {}
  tEvent = {EventType = "TimerEvent", Time = 0}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby2_1")
  }))
  tEvent = {EventType = "TimerEvent", Time = 0.15}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby2_2")
  }))
  tEvent = {EventType = "TimerEvent", Time = 0.3}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby2_3")
  }))
  tEvent = {EventType = "TimerEvent", Time = 0.45}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby2_4")
  }))
  tEvent = {EventType = "TimerEvent", Time = 0.6}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby2_5")
  }))
  tEvent = {EventType = "TimerEvent", Time = 0.75}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby2_6")
  }))
  tEvent = {EventType = "TimerEvent", Time = 0.9}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby2_7")
  }))
  tEvent = {EventType = "TimerEvent", Time = 1}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby2_8")
  }))
end

function Act_3_Mission_3.SkylarBomb4()
  Sound.PlayOwnerlessSoundEvent("a3m3_bombs_incoming")
  local tEvent = {}
  tEvent = {EventType = "TimerEvent", Time = 0}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby4_1")
  }))
  tEvent = {EventType = "TimerEvent", Time = 0.25}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby4_2")
  }))
  tEvent = {EventType = "TimerEvent", Time = 0.5}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby4_3")
  }))
  tEvent = {EventType = "TimerEvent", Time = 0.75}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby4_4")
  }))
  tEvent = {EventType = "TimerEvent", Time = 1}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby4_5")
  }))
  tEvent = {EventType = "TimerEvent", Time = 1.25}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby4_6")
  }))
  tEvent = {EventType = "TimerEvent", Time = 1.5}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby4_7")
  }))
  tEvent = {EventType = "TimerEvent", Time = 1.5}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator2", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby4_7")
  }))
  tEvent = {EventType = "TimerEvent", Time = 1.75}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby4_8")
  }))
  tEvent = {EventType = "TimerEvent", Time = 2}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby4_9")
  }))
  tEvent = {EventType = "TimerEvent", Time = 2.25}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby4_10")
  }))
  tEvent = {EventType = "TimerEvent", Time = 2.5}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby4_11")
  }))
  tEvent = {EventType = "TimerEvent", Time = 2.75}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby4_12")
  }))
  tEvent = {EventType = "TimerEvent", Time = 3}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ExplosionCreator", nil, {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\flyby4_13")
  }))
  tEvent = {EventType = "TimerEvent", Time = 1.25}
  Act_3_Mission_3:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.KillGate", nil))
end

function Act_3_Mission_3.KillGate()
  local hGate1 = Handle("CountrySide\\alsace\\doppelsieg\\exteriorarea\\props\\DPAdmin_Gate_Ent(2)\\DPAdmin_Gate_Ent_GateA")
  local hGate2 = Handle("CountrySide\\alsace\\doppelsieg\\exteriorarea\\props\\DPAdmin_Gate_Ent(2)\\DPAdmin_Gate_Ent_GateB")
  Object.ForceOpen(hGate1)
  Object.ForceOpen(hGate2)
end

function Act_3_Mission_3.Plane3CrashAndFire()
  local x, y, z
  x, y, z = Object.GetPosition(Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\Plane3explosion"))
  Util.CreateExplosion("Explosion_Sab_DynamiteFuse", x, y, z)
  Render.StartFX(Util.GetHandleByName("Missions\\act_3\\mission_3\\dyn_skyler_bomb_03\\VH_OP_HE111_SPLINE"), "0FX_Zep_Fire01_Trail", nil)
end

function Act_3_Mission_3.Plane3CrashAndFirePart2()
  local hLoc1 = Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\planeExp2")
  local x, y, z = Object.GetPosition(hLoc1)
  Sound.PlayOwnerlessSoundEvent("a3m3_plane_crash")
  Util.CreateExplosion("Explosion_Sab_DynamiteFuse", x, y, z)
end

function Act_3_Mission_3.Plane3CrashAndFirePart3()
  local hLoc1 = Util.GetHandleByName("Missions\\act_3\\mission_3\\drive_to_factory\\PlaneExp3")
  local x, y, z = Object.GetPosition(hLoc1)
  local hNazi1 = Handle("Missions\\act_3\\mission_3\\drive_to_factory\\Spore_WNZ_Grunt_MG(15)")
  local hNazi2 = Handle("Missions\\act_3\\mission_3\\drive_to_factory\\Spore_WNZ_Grunt_MG(14)")
  local hNazi3 = Handle("Missions\\act_3\\mission_3\\drive_to_factory\\Spore_WNZ_Grunt_MG(13)")
  if hNazi1 then
    Object.Kill(hNazi1)
  end
  if hNazi2 then
    Object.Kill(hNazi2)
  end
  if hNaz3 then
    Object.Kill(hNazi3)
  end
  Render.StartFX(hLoc1, "0FX_Explosions_Large_Effect", nil)
  Render.StartFX(hLoc1, "0FX_Explosion05_MAX", nil)
end

function Act_3_Mission_3.ExplosionCreator(anil, hLocator)
  local x, y, z
  if hLocator then
    x, y, z = Object.GetPosition(hLocator)
    Util.CreateExplosion("Explosion_SAB_BridgeKiller", x, y, z)
  end
end

function Act_3_Mission_3.ExplosionCreator2(anil, hLocator)
  local x, y, z
  x, y, z = Object.GetPosition(hLocator)
  Util.CreateExplosion("Explosion_RPG_Panzerfaust", x, y, z)
end

function Act_3_Mission_3.OpenSesame()
  local hDoor1 = Handle("CountrySide\\alsace\\doppelsieg\\exteriorarea\\props\\OccMed_DoppWall_Gate_L")
  local hDoor2 = Handle("CountrySide\\alsace\\doppelsieg\\exteriorarea\\props\\OccMed_DoppWall_Gate_R")
end

function Act_3_Mission_3:ConversationTriggers()
end

function Act_3_Mission_3:ConversationPlayer(sConvoName)
  if self.bConversationsIn == false then
    if self.tLol == nil then
      self.tLol = {}
      table.insert(self.tLol, sConvoName)
    else
      table.insert(self.tLol, sConvoName)
    end
  else
    Convo.AddConvo(sConvoName, 10, {})
  end
end

function Act_3_Mission_3:OpenCyclotronRoom()
  Sound.PlayOwnerlessSoundEvent("a3m3_door_cyclotron_room_open")
  Object.ForceOpen(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_Bay_Door(2)\\AnimatedObject_Dopple_Bay_Door"))
  self.ConversationPlayer(self, "A3M3_CyclotronGoto_DoorOpening")
  local tEvent = {EventType = "TimerEvent", Time = 2.5}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.GoInsideCyclotronRoom", self))
end

function Act_3_Mission_3:OpenDoorToCyclotron()
  Object.ForceOpen(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_Bay_Door(2)\\AnimatedObject_Dopple_Bay_Door"))
end

function Act_3_Mission_3:CloseDoorToCyclotron()
  Object.ForceClose(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_Bay_Door(2)\\AnimatedObject_Dopple_Bay_Door"))
end

function Act_3_Mission_3:GoInsideCyclotronRoom()
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  Nav.SetScriptedPath(hKessler, "Missions\\act_3\\mission_3\\missionobjectiverelated\\PATH_KesslerBreather", true)
  Nav.SetScriptedPathMoveMode(hKessler, true)
end

function Act_3_Mission_3:GoInsideCyclotronRoom2()
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  Nav.SetScriptedPath(hKessler, "Missions\\act_3\\mission_3\\missionobjectiverelated\\PATH_Cyclotron", true)
  Nav.SetScriptedPathMoveMode(hKessler, true)
end

function Act_3_Mission_3:WhoGotThereFirst(sName)
  if self.tSaveInfo.WhoGotFirst == "Shitballs" then
    self.tSaveInfo.WhoGotFirst = sName
    if sName == "Sean" then
      self.ConversationPlayer(self, "A3M3_CyclotronSab_SeanAtSwitch")
    else
      self.ConversationPlayer(self, "A3M3_CyclotronSab_KesslerAtSwitch")
    end
  elseif self.tSaveInfo.WhoGotFirst == "Sean" then
    self.BothOnTime(self)
  else
    Convo.AddConvo("A3M3_CyclotronSab_SeanAtSwitch", 10, {
      sCallback = "Act_3_Mission_3.BothOnTime"
    })
  end
end

function Act_3_Mission_3.BothOnTime()
  Convo.AddConvo("A3M3_CyclotronSab_BothAtSwitch", 10, {
    sCallback = "Act_3_Mission_3.FinalCountdownStart"
  })
end

function Act_3_Mission_3.FinalCountdownStart()
  Act_3_Mission_3.ConversationPlayer(Act_3_Mission_3, "A3M3_CyclotronSab_Switch_Count")
  Act_3_Mission_3.CountDownTricksie(Act_3_Mission_3, 3)
end

function Act_3_Mission_3:DisableUsePt()
  AttractionPt.EnableUse(Util.GetHandleByName("Missions\\act_3\\mission_3\\MissionObjectiveRelated\\SabPT1"), false)
end

function Act_3_Mission_3:TeslaDeathCounter(tUser)
  self.tSaveInfo.CurrentCoil = self.tSaveInfo.CurrentCoil + 2
  self.KillAllTeslaEvents(self)
  if self.tSaveInfo.CurrentCoil <= 4 then
    self.ConversationPlayer(self, "A3M3_Coil_Destroyed_Single")
  end
  local tEvent = {EventType = "TimerEvent", Time = 4}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.LowerCurrentShield", self))
end

function Act_3_Mission_3:StartTeslaShieldSequence()
  self.tSaveInfo.bTesla1LowerFirstTime = true
  self.tSaveInfo.bTesla2LowerFirstTime = true
  self.tSaveInfo.bTesla3LowerFirstTime = true
  self.tSaveInfo.bTesla4LowerFirstTime = true
  self.LowerCurrentShield(self)
end

function Act_3_Mission_3:LowerCurrentShield()
  if self.tSaveInfo.CurrentCoil == 1 then
    if self.tSaveInfo.bTesla1LowerFirstTime == true then
      self.tSaveInfo.bTesla1LowerFirstTime = false
    end
    Object.ForceOpen(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_TeslaCoil_Sheild(6)"))
    Object.ForceOpen(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_TeslaCoil_Sheild"))
    Sound.PlayOwnerlessSoundEvent("a3m3_tesla_coils_lp")
    local tEvent = {EventType = "TimerEvent", Time = 3}
    self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.StopTeslaSound", self))
  elseif self.tSaveInfo.CurrentCoil == 2 then
    if self.tSaveInfo.bTesla2LowerFirstTime == true then
      self.tSaveInfo.bTesla2LowerFirstTime = false
    end
    Object.ForceOpen(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_TeslaCoil_Sheild(1)"))
    Object.ForceOpen(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_TeslaCoil_Sheild(5)"))
    Sound.PlayOwnerlessSoundEvent("a3m3_tesla_coils_lp")
    local tEvent = {EventType = "TimerEvent", Time = 3}
    self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.StopTeslaSound", self))
  elseif self.tSaveInfo.CurrentCoil == 3 then
    if self.tSaveInfo.bTesla3LowerFirstTime == true then
      self.tSaveInfo.bTesla3LowerFirstTime = false
      self.ConversationPlayer(self, "A3M3_Coil_LowerShield03_First")
    end
    Object.ForceOpen(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_TeslaCoil_Sheild(2)"))
    Object.ForceOpen(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_TeslaCoil_Sheild(4)"))
    Sound.PlayOwnerlessSoundEvent("a3m3_tesla_coils_lp")
    local tEvent = {EventType = "TimerEvent", Time = 3}
    self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.StopTeslaSound", self))
  elseif self.tSaveInfo.CurrentCoil == 4 then
    if self.tSaveInfo.bTesla4LowerFirstTime == true then
      self.tSaveInfo.bTesla4LowerFirstTime = false
    end
    self.ConversationPlayer(self, "A3M3_Coil_LowerShield02_First")
    Object.ForceOpen(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_TeslaCoil_Sheild(3)"))
    Object.ForceOpen(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_TeslaCoil_Sheild(7)"))
    Sound.PlayOwnerlessSoundEvent("a3m3_tesla_coils_lp")
    local tEvent = {EventType = "TimerEvent", Time = 3}
    self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.StopTeslaSound", self))
  else
    self.KillAllTeslaEvents(self)
  end
end

function Act_3_Mission_3:StopTeslaSound()
  Sound.StopSoundEvent("a3m3_tesla_coils_lp")
end

function Act_3_Mission_3:ShieldUpCurrentTesla()
  self.ConversationPlayer(self, "A3M3_Coil_ShieldRaising")
  if self.tSaveInfo.CurrentCoil == 1 then
    Object.ForceClose(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_TeslaCoil_Sheild(2)"))
    Object.ForceClose(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_TeslaCoil_Sheild(4)"))
  elseif self.tSaveInfo.CurrentCoil == 2 then
    Object.ForceClose(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_TeslaCoil_Sheild(1)"))
    Object.ForceClose(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_TeslaCoil_Sheild(5)"))
  elseif self.tSaveInfo.CurrentCoil == 3 then
    Object.ForceClose(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_TeslaCoil_Sheild(6)"))
    Object.ForceClose(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_TeslaCoil_Sheild"))
  else
    if self.tSaveInfo.CurrentCoil == 4 then
      Object.ForceClose(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_TeslaCoil_Sheild(3)"))
      Object.ForceClose(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_TeslaCoil_Sheild(7)"))
    else
    end
  end
  if self.tSaveInfo.hShieldDownEvent then
    Util.KillEvent(self.tSaveInfo.hShieldDownEvent)
  end
  local tEvent = {EventType = "TimerEvent", Time = 4}
  self.tSaveInfo.hShieldDownEvent = Util.CreateEvent(tEvent, "Act_3_Mission_3.BriefTimeToReSync", self)
  self:RegisterEvent(self.tSaveInfo.hShieldDownEvent)
end

function Act_3_Mission_3:BriefTimeToReSync()
  if self.tSaveInfo.hReTryEvent then
    Util.KillEvent(self.tSaveInfo.hReTryEvent)
  end
  local tEvent = {EventType = "TimerEvent", Time = 4}
  self.tSaveInfo.hReTryEvent = Util.CreateEvent(tEvent, "Act_3_Mission_3.LowerCurrentShield", self)
  self:RegisterEvent(self.tSaveInfo.hReTryEvent)
end

function Act_3_Mission_3:KillAllTeslaEvents()
  if self.tSaveInfo.hShieldUpEvent then
    Util.KillEvent(self.tSaveInfo.hShieldUpEvent)
  end
  if self.tSaveInfo.hShieldDownEvent then
    Util.KillEvent(self.tSaveInfo.hShieldDownEvent)
  end
  if self.tSaveInfo.hReTryEvent then
    Util.KillEvent(self.tSaveInfo.hReTryEvent)
  end
end

function Act_3_Mission_3:SetupWhoGotToEscapeDoorFirst()
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  local hLocator = Util.GetHandleByName("Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_DoorOpenLocation")
  self.tSaveInfo.KesslerGotToEndFirst = Util.CreateEvent({
    EventType = "ProximityEvent",
    ObjectA = hLocator,
    ObjectB = hKessler,
    Proximity = 10,
    Negate = false
  }, "Act_3_Mission_3.WhoGotToEndOfDoorFirst", self, {"Kessler"})
  self.tSaveInfo.SeanGoToEndFirst = Util.CreateEvent({
    EventType = "ProximityEvent",
    ObjectA = hLocator,
    ObjectB = hSab,
    Proximity = 10,
    Negate = false
  }, "Act_3_Mission_3.WhoGotToEndOfDoorFirst", self, {"Sean"})
  self:RegisterEvent(self.tSaveInfo.KesslerGotToEndFirst)
  self:RegisterEvent(self.tSaveInfo.SeanGoToEndFirst)
end

function Act_3_Mission_3:WhoGotToEndOfDoorFirst(sWho)
  Util.KillEvent(self.tSaveInfo.KesslerGotToEndFirst)
  Util.KillEvent(self.tSaveInfo.SeanGoToEndFirst)
  if sWho == "Sean" then
    self.ConversationPlayer(self, "A3M3_FinalDoor_Sean")
  else
    self.ConversationPlayer(self, "A3M3_Escape_Situation04")
  end
end

function Act_3_Mission_3:EnableSpinnazzz(hBool)
  local tObject = {
    Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\Dopple_Cyclotron_Middle_Upper"),
    Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\Dopple_Cyclotron_Middle_Lower"),
    Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\Dopple_Cyclotron_Giant_Gear"),
    Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\Dopple_Cyclotron_Giant_Gear(1)"),
    Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\Dopple_Cyclotron_Giant_Gear(2)"),
    Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\Dopple_Cyclotron_Giant_Gear(3)")
  }
  local tempIndex, tempV
  for tempIndex, tempv in ipairs(tObject) do
    if tempv then
      Object.EnableAnimatedPropPart(tempv, hBool)
    end
  end
end

function Act_3_Mission_3:EscapeSequence2()
  self.ConversationPlayer(self, "A3M3_Escape_Situation01")
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  Nav.SetScriptedPath(hKessler, "Missions\\act_3\\mission_3\\missionobjectiverelated\\PATH_Escape2", false, "Act_3_Mission_3.EscapeSequence2Enable", self)
  Nav.SetScriptedPathMoveMode(hKessler, true)
end

function Act_3_Mission_3:EscapeSequence2Enable()
  self:ChangeObjTextByName("Escapetotheexit", "A3M3_Text.ClearPathForKessler")
  self:CreateTask({
    sName = "ClearPath1",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    ParentObjectID = self:GetTaskObjectiveID("MainTask"),
    tTgtInclude = {
      "Missions\\act_3\\mission_3\\nazi_escape_factory\\Target_A_1",
      "Missions\\act_3\\mission_3\\nazi_escape_factory\\Target_A_2",
      "Missions\\act_3\\mission_3\\nazi_escape_factory\\Target_A_3"
    },
    tOnComplete = {
      {
        self.EscapeSequence3,
        {self}
      }
    }
  })
end

function Act_3_Mission_3:EscapeSequence3()
  self:ChangeObjTextByName("Escapetotheexit", "A3M3_Text.Findexit")
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  Nav.SetScriptedPath(hKessler, "Missions\\act_3\\mission_3\\missionobjectiverelated\\PATH_Escape3", true, "Act_3_Mission_3.EscapeSequence3Enable", self)
  Nav.SetScriptedPathMoveMode(hKessler, true)
end

function Act_3_Mission_3:EscapeSequence3Enable()
  self:ChangeObjTextByName("Escapetotheexit", "A3M3_Text.ClearPathForKessler")
  self:CreateTask({
    sName = "ClearPath2",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    ParentObjectID = self:GetTaskObjectiveID("MainTask"),
    tTgtInclude = {
      "Missions\\act_3\\mission_3\\nazi_escape_factory\\Target_B_1",
      "Missions\\act_3\\mission_3\\nazi_escape_factory\\Target_B_2"
    },
    tOnComplete = {
      {
        self.EscapeSequence4,
        {self}
      }
    }
  })
end

function Act_3_Mission_3:EscapeSequence4()
  self:ChangeObjTextByName("Escapetotheexit", "A3M3_Text.Findexit")
  self.ConversationPlayer(self, "A3M3_Escape_Situation02")
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  Nav.SetScriptedPath(hKessler, "Missions\\act_3\\mission_3\\missionobjectiverelated\\PATH_Escape4", true, "Act_3_Mission_3.EscapeSequence4Enable", self)
  Nav.SetScriptedPathMoveMode(hKessler, true)
end

function Act_3_Mission_3:EscapeSequence4Enable()
  self:ChangeObjTextByName("Escapetotheexit", "A3M3_Text.ClearPathForKessler")
  self:CreateTask({
    sName = "ClearPath3",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    ParentObjectID = self:GetTaskObjectiveID("MainTask"),
    tTgtInclude = {
      "Missions\\act_3\\mission_3\\nazi_escape_factory\\Target_C_1",
      "Missions\\act_3\\mission_3\\nazi_escape_factory\\Target_C_2"
    },
    tOnComplete = {
      {
        self.EscapeSequence5,
        {self}
      }
    }
  })
end

function Act_3_Mission_3:EscapeSequence5()
  self:ChangeObjTextByName("Escapetotheexit", "A3M3_Text.Findexit")
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  Nav.SetScriptedPath(hKessler, "Missions\\act_3\\mission_3\\missionobjectiverelated\\PATH_Escape5", true, "Act_3_Mission_3.EscapeSequence5Enable", self)
  Nav.SetScriptedPathMoveMode(hKessler, true)
end

function Act_3_Mission_3:EscapeSequence5Enable()
  self:ChangeObjTextByName("Escapetotheexit", "A3M3_Text.ClearPathForKessler")
  self:CreateTask({
    sName = "ClearPath4",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    ParentObjectID = self:GetTaskObjectiveID("MainTask"),
    tTgtInclude = {
      "Missions\\act_3\\mission_3\\nazi_escape_factory\\Target_D_1",
      "Missions\\act_3\\mission_3\\nazi_escape_factory\\Target_D_2",
      "Missions\\act_3\\mission_3\\nazi_escape_factory\\Target_D_3",
      "Missions\\act_3\\mission_3\\nazi_escape_factory\\Target_D_4"
    },
    tOnComplete = {
      {
        self.EscapeSequence6,
        {self}
      }
    }
  })
end

function Act_3_Mission_3:EscapeSequence6()
  self:ChangeObjTextByName("Escapetotheexit", "A3M3_Text.Findexit")
  self.ConversationPlayer(self, "A3M3_Escape_Situation03")
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  Nav.SetScriptedPath(hKessler, "Missions\\act_3\\mission_3\\missionobjectiverelated\\PATH_Escape6", true, "Act_3_Mission_3.EscapeSequence7", self)
  Nav.SetScriptedPathMoveMode(hKessler, true)
end

function Act_3_Mission_3:EscapeSequence7()
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\a3m3_kessler\\Spore_RS_Kessler")
  Actor.PlayAnimation(hKessler, "sabotage_clippers_mid_idle")
  local tEvent = {EventType = "TimerEvent", Time = 4}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.EscapeSequence8", self))
  Object.ForceOpen(Util.GetHandleByName("Missions\\act_3\\mission_3\\factory_shootout\\AnimatedObject_Dopple_Bay_Door\\AnimatedObject_Dopple_Bay_Door"))
  local hKlaxon = Handle("Missions\\act_3\\mission_3\\sound_exit\\A3m3_exit_klaxon")
  if hKlaxon then
    Sound.ActivateSoundEmitter(hKlaxon)
  end
end

function Act_3_Mission_3:EscapeSequence8()
  self.ConversationPlayer(self, "A3M3_FinalDoor_Opened")
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  Actor.CancelAnimation(hKessler)
  Nav.SetScriptedPath(hKessler, "Missions\\act_3\\mission_3\\missionobjectiverelated\\PATH_Escape7", true, "Act_3_Mission_3.BeckonPlayer", self)
  Nav.SetScriptedPathMoveMode(hKessler, true)
end

function Act_3_Mission_3:BeckonPlayer()
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\a3m3_kessler\\Spore_RS_Kessler")
  Actor.PlayAnimation(hKessler, "shrd_M_LH_wave_alert", 10000)
end

function Act_3_Mission_3:ProximityEscape1()
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  local tEvent = {EventType = "TimerEvent", Time = 6}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.EscapeSequence2", self))
end

function Act_3_Mission_3:ProximityEscape2()
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_3\\A3M3_Kessler\\Spore_RS_Kessler")
  local tEvent = {EventType = "TimerEvent", Time = 6}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.EscapeSequence3", self))
end

function Act_3_Mission_3:DoorSpawnInSequence(tUserData)
end

function Act_3_Mission_3:DoorSpawnerLogic()
  local hTempSpawn
  local tPoints = {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\elevatorhunt\\loc7"),
    Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\elevatorhunt\\loc8"),
    Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\elevatorhunt\\loc9")
  }
  local nCounter
  if self.tSaveInfo.SpawnerEventHandles == nil then
    self.tSaveInfo.SpawnerEventHandles = {}
  end
  self.tSaveInfo.SpawnerEventHandles = {}
  for nCounter = 1, 2 do
    hTempSpawn = Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\nazielevator2\\spawner" .. nCounter)
    local hEventHandle = Util.CreateEvent({EventType = "OnSpawn", Target = hTempSpawn}, "Act_3_Mission_3.SpawnedIn", self, {
      tPoints,
      "CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_Bay_Door_B",
      hTempSpawn
    }, true)
    self:RegisterEvent(hEventHandle)
    table.insert(self.tSaveInfo.SpawnerEventHandles, hEventHandle)
  end
  tPoints = {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\elevatorhunt\\loc4"),
    Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\elevatorhunt\\loc5"),
    Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\elevatorhunt\\loc6")
  }
  for nCounter = 1, 2 do
    hTempSpawn = Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\nazielevator3\\spawner" .. nCounter)
    local hEventHandle = Util.CreateEvent({EventType = "OnSpawn", Target = hTempSpawn}, "Act_3_Mission_3.SpawnedIn", self, {
      tPoints,
      "CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_Bay_Door_B(1)",
      hTempSpawn
    }, true)
    self:RegisterEvent(hEventHandle)
    table.insert(self.tSaveInfo.SpawnerEventHandles, hEventHandle)
  end
  tPoints = {
    Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\elevatorhunt\\loc1"),
    Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\elevatorhunt\\loc2"),
    Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\elevatorhunt\\loc3")
  }
  for nCounter = 1, 2 do
    hTempSpawn = Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\nazielevator1\\spawner" .. nCounter)
    local hEventHandle = Util.CreateEvent({EventType = "OnSpawn", Target = hTempSpawn}, "Act_3_Mission_3.SpawnedIn", self, {
      tPoints,
      "CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_Bay_Door_B(2)",
      hTempSpawn
    }, true)
    self:RegisterEvent(hEventHandle)
    table.insert(self.tSaveInfo.SpawnerEventHandles, hEventHandle)
  end
end

function Act_3_Mission_3:ActivateElevator(nWhich)
  if nWhich == 1 then
    local nCounter
    for nCounter = 1, 1 do
      local hSpawner = Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\nazielevator1\\spawner" .. nCounter)
      Object.EnableSpawner(hSpawner, true)
    end
  elseif nWhich == 2 then
    local nCounter
    for nCounter = 1, 1 do
      local hSpawner = Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\nazielevator2\\spawner" .. nCounter)
      Object.EnableSpawner(hSpawner, true)
    end
  else
    if nWhich == 3 then
      local nCounter
      for nCounter = 1, 1 do
        local hSpawner = Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\nazielevator3\\spawner" .. nCounter)
        Object.EnableSpawner(hSpawner, true)
      end
    else
    end
  end
end

function Act_3_Mission_3:PurgeAllSpawners()
  local hSpawner = Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\nazielevator1\\spawner1")
  Object.SpawnerPurge(hSpawner, true)
  hSpawner = Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\nazielevator1\\spawner2")
  Object.SpawnerPurge(hSpawner, true)
  hSpawner = Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\nazielevator2\\spawner1")
  Object.SpawnerPurge(hSpawner, true)
  hSpawner = Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\nazielevator2\\spawner2")
  Object.SpawnerPurge(hSpawner, true)
  hSpawner = Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\nazielevator3\\spawner1")
  Object.SpawnerPurge(hSpawner, true)
  hSpawner = Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_enc\\nazielevator3\\spawner2")
  Object.SpawnerPurge(hSpawner, true)
  hSpawner = Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_guardcod1\\CoDSpawner")
  Object.SpawnerPurge(hSpawner, true)
  hSpawner = Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_guardcod2\\CoDSpawner")
  Object.SpawnerPurge(hSpawner, true)
  hSpawner = Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_guardcod3\\CoDSpawner")
  Object.SpawnerPurge(hSpawner, true)
  hSpawner = Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_guardcod4\\CoDSpawner")
  Object.SpawnerPurge(hSpawner, true)
  hSpawner = Util.GetHandleByName("Missions\\act_3\\mission_3\\nazi_guardcod5\\CoDSpawner")
  Object.SpawnerPurge(hSpawner, true)
end

function Act_3_Mission_3:SpawnedIn(hWho, tUserData, sDoor, hSpawner)
  if hWho[2] then
    Combat.SetTarget(hWho[2], hSab)
    Combat.SetCombat(hWho[2])
    Combat.SetAlwaysSeeTarget(hWho[2], true)
    Combat.SetReactImmediately(hWho[2], true)
    local tEvent = {EventType = "TimerEvent", Time = 2}
    self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.NaziActivate", self, {
      hWho[2],
      tUserData[math.random(1, #tUserData)]
    }))
  end
  local nlightid = 6661
  if sDoor == "CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_Bay_Door_B(1)" then
    nlightid = 6663
  elseif sDoor == "CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_Bay_Door_B" then
    nlightid = 6662
  else
    nlightid = 6661
  end
  Render.ToggleLights(nlightid, true)
  local tEvent = {EventType = "TimerEvent", Time = 0.3}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.OpenThisDoor", self, {sDoor, true}))
  Object.EnableSpawner(hSpawner, false)
  Object.SpawnerReset(hSpawner)
  Util.LoadStaticENTag("A3M3_ElevatorLights", true)
end

function Act_3_Mission_3:NaziActivate(hWho, hPoint)
  if hWho and hPoint then
    local x, y, z = Object.GetPosition(hPoint)
    Combat.SetObjective(hWho, hPoint, true, 0, false)
  end
end

function Act_3_Mission_3:OverRideStuff(hWho)
  Actor.OverrideCombatAI(hWho, false)
end

function Act_3_Mission_3:OpenThisDoor(sDoor, bOpen)
  local hDoor = Util.GetHandleByName(sDoor)
  if hDoor then
    if bOpen == true then
      Object.ForceOpen(hDoor)
      local tEvent = {EventType = "TimerEvent", Time = 6}
      self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.OpenThisDoor", self, {sDoor, false}))
    else
      Object.ForceClose(hDoor)
      local nlightid = 6661
      if sDoor == "CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_Bay_Door_B(1)" then
        nlightid = 6663
      elseif sDoor == "CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\cyclotron_int\\AnimatedObject_Dopple_Bay_Door_B" then
        nlightid = 6662
      else
        nlightid = 6661
      end
      Util.UnloadStaticENTag("A3M3_ElevatorLights", true)
      Render.ToggleLights(nlightid, false)
    end
  end
end

function Act_3_Mission_3:VeroniqueHaxor()
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_VeroHack1", hSab, "Act_3_Mission_3.TeleportVeroMagic", self, {
    "Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_VeroHack1"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_VeroHack1")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_VeroHack2", hSab, "Act_3_Mission_3.TeleportVeroMagic", self, {
    "Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_VeroHack2"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_VeroHack2")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_VeroHack3", hSab, "Act_3_Mission_3.TeleportVeroMagic", self, {
    "Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_VeroHack3"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_VeroHack3")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_VeroHack4", hSab, "Act_3_Mission_3.TeleportVeroMagic", self, {
    "Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_VeroHack4"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_VeroHack4")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_VeroHack5", hSab, "Act_3_Mission_3.TeleportVeroMagic", self, {
    "Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_VeroHack5"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_VeroHack5")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_VeroHack6", hSab, "Act_3_Mission_3.TeleportVeroMagic", self, {
    "Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_VeroHack6"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_VeroHack6")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_VeroHack7", hSab, "Act_3_Mission_3.TeleportVeroMagic", self, {
    "Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_VeroHack7"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_VeroHack7")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_VeroHack8", hSab, "Act_3_Mission_3.TeleportVeroMagic", self, {
    "Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_VeroHack8"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\act_3\\mission_3\\missionobjectiverelated\\PT_VeroHack8")
end

function Act_3_Mission_3:TeleportVeroMagic(hWho, UserData)
  local hVeronique = Util.GetHandleByName("Missions\\act_3\\mission_3\\starter\\A3M3_Veronique")
  if Object.GetDistance(hSab, hVeronique) > 10 then
    local x, y, z = Object.GetPosition(Util.GetHandleByName(UserData))
    Object.Teleport(hVeronique, x, y, z, 0)
  end
end

function Act_3_Mission_3:ParticleSpawn(sLocator, tBluePrints)
  local tempcounter
  local hLoc = Handle(sLocator)
  if hLoc then
    for i, v in ipairs(tBluePrints) do
      Render.StartFX(hLoc, v, nil)
    end
  end
end

function Act_3_Mission_3:EscExpLoop()
  local tEvent = {
    EventType = "TimerEvent",
    Time = math.random(1, 10) / 3
  }
  self.tSaveInfo.hExplody = Util.CreateEvent(tEvent, "Act_3_Mission_3.EscExpLoop", self)
  self:RegisterEvent(self.tSaveInfo.hExplody)
  local nRandy = math.random(1, 12)
  Sound.PlayOwnerlessSoundEvent("a3m3_factory_explosions")
  Sound.PlayOwnerlessSoundEvent("exp_dopp_medium")
  if nRandy < 5 then
    self.EscExpSeqs(self)
  else
    self.EscExps(self)
  end
end

function Act_3_Mission_3:EscExpSeqs()
  local nTimer = 0
  local tEvent
  local nWhich = math.random(1, 4)
  local tExplosions = {
    "0FX_Explosion01",
    "0FX_Explosions_Huge_Effect",
    "0FX_Explosions_Large_Effect",
    "0FX_Explosions_Medium_Effect",
    "0FX_Explosion02"
  }
  for i = 1, 4 do
    tEvent = {EventType = "TimerEvent", Time = nTimer}
    self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ParticleSpawn", self, {
      "Missions\\act_3\\mission_3\\escapesequence\\seq" .. nWhich .. "(" .. i .. ")",
      {
        "PHPFX_Metal_EXP_A_Medium",
        tExplosions[math.random(1, 1)],
        "PHPFX_Concrete_EXP_A_All"
      }
    }))
    nTimer = nTimer + 0.15
  end
end

function Act_3_Mission_3:EscExps()
  local nTimer = 0
  local tEvent
  local nWhich = math.random(5, 12)
  local tExplosions = {
    "0FX_Explosion01",
    "0FX_Explosions_Huge_Effect",
    "0FX_Explosions_Large_Effect",
    "0FX_Explosions_Medium_Effect",
    "0FX_Explosion02"
  }
  tEvent = {EventType = "TimerEvent", Time = nTimer}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_3.ParticleSpawn", self, {
    "Missions\\act_3\\mission_3\\escapesequence\\seq" .. nWhich,
    {
      "PHPFX_Metal_EXP_A_Medium",
      tExplosions[math.random(1, 1)],
      "PHPFX_Concrete_EXP_A_All"
    }
  }))
end

function Act_3_Mission_3:PolishDetail1()
end

function Act_3_Mission_3:PlaySkylar5Plane()
  local hLoc = Handle("Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_hallwayexp1")
  local x, y, z = Object.GetPosition(hLoc)
  Util.CreateExplosion("Explosion_Sab_DynamiteFuse", x, y, z)
  hLoc = Handle("Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_hallwayexp2")
  x, y, z = Object.GetPosition(hLoc)
  Util.CreateExplosion("Explosion_Sab_DynamiteFuse", x, y, z)
  hLoc = Handle("Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_hallwayexp3")
  x, y, z = Object.GetPosition(hLoc)
  Util.CreateExplosion("Explosion_Sab_DynamiteFuse", x, y, z)
end

function Act_3_Mission_3:PlaySkylar5Plane2()
  Util.AddSplinePlaneAttackObject("Missions\\act_3\\mission_3\\dyn_skyler_bomb_05\\enemyplane1spline", 100, false, hSab, false)
end

function Act_3_Mission_3:PlaySkylar5Plane3()
  Cin.PlayCinematic("A3M3_Skyler_Flyby_05")
end

function Act_3_Mission_3.PlaySkylar5PlaneCinCrash1()
  local hLoc = Handle("Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_hallwaycrash1")
  Render.StartFX(hLoc, "0FX_Explosion01", nil)
  local x, y, z = Object.GetPosition(hSab)
  Render.CameraShakeExplosion(x, y, z, 70, 70, 70)
  local hLoc = Handle("Missions\\act_3\\mission_3\\dyn_skyler_bomb_05\\enemyplane2")
  Render.StartFX(hLoc, "0FX_Zep_Fire01_Trail", nil)
end

function Act_3_Mission_3:PlaySkylar5PlaneCinCrash2()
  local hLoc = Handle("Missions\\act_3\\mission_3\\missionobjectiverelated\\LOC_hallwaycrash2")
  Render.StartFX(hLoc, "0FX_Explosion05_MAX", nil)
end

function Act_3_Mission_3:BeginingPlayerEntersVehicle()
end

function Act_3_Mission_3:VeroEntersVehicle()
end

function Act_3_Mission_3:TeleportCinematicPeople()
  Util.UnloadEditNode("Missions\\act_3\\mission_3\\starter.wsd", true, false)
  local tEvent = {EventType = "TimerEvent", Time = 1}
  Util.CreateEvent(tEvent, "Act_3_Mission_3.UnloadDoppDoor", self)
end

function Act_3_Mission_3:UnloadDoppDoor()
  Util.UnloadStaticENTag("Dopp_2nd_Door", true)
  Util.UnloadStaticENTag("Dopp_2nd_Door_Back", true)
end

function Act_3_Mission_3:OpenDoorForKessler()
  local hDoor = Handle("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\car_factory_int\\Dopple_Interro_Office_Door")
  Object.ForceOpen(hDoor)
end

function Act_3_Mission_3:FindKesslerMusicChange()
end

function Act_3_Mission_3:PlayInitialConversation()
  self.ConversationPlayer(self, "A3M3_OMW", {})
end

function Act_3_Mission_3:VeroniqueStreamedOutFail()
end

function Act_3_Mission_3.TruckGoAndExplosion()
  local hSc = Handle("Missions\\act_3\\mission_3\\drive_to_factory\\VehicleSpawnCondition(3)")
  if hSc then
    local hSelf = Actor.GetSelf(hSc)
    if hSelf then
      VehicleSpawnCondition.ActivateAllVehicles(hSelf)
    end
  end
end

function Act_3_Mission_3.PlaneAttackSkylarFlyby()
  Util.AddSplinePlaneAttackObject("Missions\\act_3\\mission_3\\skylarflyshot\\skylarattacker1", 100, false, Handle("Missions\\act_3\\mission_3\\skylarflyshot\\PROP_NO_PL_P61Skylar_spline"), true)
end
