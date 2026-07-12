if Paris_3_Mission_1 == nil then
  Paris_3_Mission_1 = SabTaskObjective:Create()
  gsParis3Mission1Dir = "Missions\\Paris_3\\Mission_1\\"
  Paris_3_Mission_1:Configure({
    TaskCount = 99,
    sAreaID = "Paris_3",
    bStarterless = true,
    MCDisplayID = 2,
    sSaveMissionNameID = "MissionNames_Text.P3M1",
    sHQNextMissionStartPoint = _cHQe_CATACOMBS,
    sHQStartPoint = _cHQ_BELLEP3M1,
    tUnlockList = {
      "Connect_P3_M1b_KesslerAtDoppelsieg"
    },
    tSMEDNodes = {
      "Missions\\paris_3\\mission_1\\start",
      "Missions\\paris_3\\mission_1\\belle2",
      "Missions\\paris_3\\mission_1\\GetToFirstHQ",
      "Missions\\paris_3\\mission_1\\particlefx",
      "Missions\\paris_3\\mission_1\\cheats",
      "Missions\\paris_3\\mission_1\\catacombs_outside",
      "Missions\\paris_3\\mission_1\\hall1\\triggerspawner"
    },
    tStaticTags = {}
  })
end

function Paris_3_Mission_1:STARTER_Setup()
  Util.UnloadStaticENTag("PristineBelle", true)
  Zone.Enable("WtF_Zones\\global\\Belle_Low", true, cENT_IMMEDIATE)
  Zone.SwitchState("WtF_Zones\\global\\Belle_Low", cZONESTATE_LOWWTF, cENT_IMMEDIATE, true)
  Zone.SwitchState("WtF_Zones\\global\\P1M1_FuelDepot", cZONESTATE_LOWWTF, cENT_IMMEDIATE, false)
  Util.UnloadStaticENTag("P3M1_key_freeplay", true)
end

function Paris_3_Mission_1:Activated()
  self:AddOnCancelCallback(Paris_3_Mission_1.Reset)
  self:AddOnCompleteCallback(Paris_3_Mission_1.Reset)
  self.DynamicTable = {}
  self.ColbyTable = {}
  SabTaskObjective.Activated(self)
  Cin.LoadCinematic("401_CinB_Catac")
  Sound.LoadSoundBank("m_P3M1_inGame.bnk")
  Paris_3_Mission_1.StartInBelle(self)
  Paris_3_Mission_1.bNodeLoadedForFinalNazi = false
  self.bLoadInWallBlastGuys = false
  Actor.SetDisguise(hSab, "FBS_RS_Sean_Race_Race_NoHat_NoBag")
  self:CreateTask({
    sName = "Missions\\paris_3\\mission_1\\dynamic",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\paris_3\\mission_1\\dynamic",
      "Missions\\paris_3\\mission_1\\final_encounter_fence",
      "Missions\\paris_3\\mission_1\\convotrigger",
      "Missions\\paris_3\\mission_1\\Messenger",
      "Missions\\paris_3\\mission_1\\conversation"
    }
  })
  table.insert(self.ColbyTable, "P3M1_catacombs_entrance")
  Util.LoadStaticENTag("P3M1_catacombs_entrance", true)
  self.TeleportHack(self)
  Paris_3_Mission_1:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\belle2\\PT_WarnOthers", hSab, "Paris_3_Mission_1.ConvoWarnOthers", Paris_3_Mission_1, {}, cTRIGGEREVENT_ONENTER), "Missions\\paris_3\\mission_1\\belle2\\PT_WarnOthers")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\catacombs_outside\\PT_CatPatrol_Front", hSab, "Paris_3_Mission_1.ExteriorPatrols", self, {
    "Missions\\paris_3\\mission_1\\catacombs_outside\\NZ_CatPatrol_Front",
    "Missions\\paris_3\\mission_1\\catacombs_outside\\PA_CatPatrol_Front"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\catacombs_outside\\PT_CatPatrol_Front")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\catacombs_outside\\PT_CatPatrol_Front2", hSab, "Paris_3_Mission_1.ExteriorPatrols", self, {
    "Missions\\paris_3\\mission_1\\catacombs_outside\\NZ_CatPatrol_Front",
    "Missions\\paris_3\\mission_1\\catacombs_outside\\PA_CatPatrol_Front2"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\catacombs_outside\\PT_CatPatrol_Front2")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\catacombs_outside\\PT_CatPatrol_stairs", hSab, "Paris_3_Mission_1.ExteriorPatrols", self, {
    "Missions\\paris_3\\mission_1\\catacombs_outside\\NZ_CatPatrol_stairs",
    "Missions\\paris_3\\mission_1\\catacombs_outside\\PA_CatPatrol_stairs"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\catacombs_outside\\PT_CatPatrol_stairs")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\catacombs_outside\\PT_CatPatrol_stairs2", hSab, "Paris_3_Mission_1.ExteriorPatrols", self, {
    "Missions\\paris_3\\mission_1\\catacombs_outside\\NZ_CatPatrol_stairs",
    "Missions\\paris_3\\mission_1\\catacombs_outside\\PA_CatPatrol_stairs"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\catacombs_outside\\PT_CatPatrol_stairs2")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\catacombs_outside\\PT_CatPatrol_Right", hSab, "Paris_3_Mission_1.ExteriorPatrols", self, {
    "Missions\\paris_3\\mission_1\\catacombs_outside\\NZ_CatPatrol_Right",
    "Missions\\paris_3\\mission_1\\catacombs_outside\\PA_CatPatrol_Right"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\catacombs_outside\\PT_CatPatrol_Right")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\catacombs_outside\\PT_CatPatrol_Right2", hSab, "Paris_3_Mission_1.ExteriorPatrols", self, {
    "Missions\\paris_3\\mission_1\\catacombs_outside\\NZ_CatPatrol_Right",
    "Missions\\paris_3\\mission_1\\catacombs_outside\\PA_CatPatrol_Right"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\catacombs_outside\\PT_CatPatrol_Right2")
end

function Paris_3_Mission_1:StartInBelle()
  local hUsePoint = Util.GetHandleByName("Missions\\paris_3\\mission_1\\start\\DoorTriggerPoint")
  AttractionPt.EnableUse(hUsePoint, false)
  local h2UsePoint = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\hq_ext\\Belle_ext_teleport")
  AttractionPt.EnableUse(h2UsePoint, false)
  self.SetupCheckpointStart(self)
end

function Paris_3_Mission_1:Reset()
  for i, v in ipairs(self.ColbyTable) do
    Util.UnloadStaticENTag(v)
  end
  HUD.ClearPauseMenuPos()
  if self.bNodeLoadedForFinalNazi ~= nil then
    if self.bNodeLoadedForFinalNazi == true then
      Util.UnloadEditNode("Missions\\paris_3\\mission_1\\final_nazis.wsd", true)
      Util.UnloadEditNode("Missions\\paris_3\\mission_1\\final_encounter2.wsd", true)
    end
    self.bNodeLoadedForFinalNazi = nil
  end
  if self.bLoadInWallBlastGuys ~= nil then
    if self.bLoadInWallBlastGuys == true then
      Util.UnloadEditNode("Missions\\paris_3\\mission_1\\room3\\7_wallblast.wsd", true)
    end
    self.bLoadInWallBlastGuys = nil
  end
  Render.WTFClearOverrideBlueprint()
  Suspicion.EnableEscalationVehicles(true)
  Render.FadeScreen(true)
  Sound.ReleaseSoundBank("m_P3M1_inGame.bnk")
  Render.WTFClearOverrideBlueprint()
  Squad.ClearBehavior("Saboteur")
  Squad.SetEnemy("Saboteur", nil)
  Squad.ClearBehavior("GenericNazi")
  Squad.SetEnemy("GenericNazi", nil)
  Util.LoadStaticENTag("P3M1_key_freeplay", true)
  HUD.SetMinimapZoom(false)
end

function Paris_3_Mission_1:SetupCheckpointStart()
  self.RegisterCheckpoint(self, "Paris_3_Mission_1.GoToOrigHQSetup")
  local hRes1 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\messenger\\Messenger")
  local hRes2 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\messenger\\Messenger_male")
  if hRes1 and hRes2 then
    Actor.SetMissionCriticalNPC(hRes1, true)
    Actor.SetMissionCriticalNPC(hRes2, true)
  end
end

function Paris_3_Mission_1:GoToOrigHQSetup()
  local hUsePoint = Util.GetHandleByName("Missions\\paris_3\\mission_1\\start\\DoorTriggerPoint")
  AttractionPt.EnableUse(hUsePoint, false)
  Render.FadeScreen(false)
  self.bEscalationTaskHappened = false
  self.bDeEscalationTaskHappened = false
  self.GoToOrigHQ(self)
end

function Paris_3_Mission_1:EnableMissionCriticalNPC()
  local hRes1 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\messenger\\Messenger")
  local hRes2 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\messenger\\Messenger_male")
  if hRes1 and hRes2 then
    Actor.SetMissionCriticalNPC(hRes1, true)
    Actor.SetMissionCriticalNPC(hRes2, true)
  end
end

function Paris_3_Mission_1:GoToOrigHQ()
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\paris_3\\mission_1\\messenger\\Messenger",
      "Missions\\paris_3\\mission_1\\messenger\\Messenger_male"
    }
  }, "Paris_3_Mission_1.EnableMissionCriticalNPC", self, {}))
  if self:IsMissionTaskActive("GetToOrigHQ") == false then
    if self.bEscalationTaskHappened == false then
      self:CreateTask({
        sName = "GetToOrigHQ",
        sTaskType = "SabTaskObjectiveDeliver",
        Proximity = 5,
        sObjectiveTextID = "GenericObjective_Text.HQ_P3_GoTo",
        sTaskSubType = "DELIVER",
        tDestProximityObj = {
          "Missions\\paris_3\\mission_1\\gettofirsthq\\CatHQLoc"
        },
        tDeliverObjs = {hSab},
        tLocators = {
          "Missions\\paris_3\\mission_1\\gettofirsthq\\CatHQLoc"
        },
        vGPSTarget = "Missions\\paris_3\\mission_1\\GetToFirstHQ\\GPSTarget",
        tOnComplete = {
          {
            self.SetupCheckpointOldHQ,
            {self}
          }
        }
      })
      self:CreateTask({
        sName = "escalatedbeforetalking",
        sTaskType = "SabTaskObjectiveEscalation",
        sTaskSubType = "None",
        EscalationLevel = 1,
        bGTE = true,
        tOnComplete = {
          {
            self.EscalatedBeforeGettingToHQ,
            {self}
          }
        }
      })
    else
      self:ResetTaskByName("GetToOrigHQ")
      self:ResetTaskByName("escalatedbeforetalking")
    end
  end
end

function Paris_3_Mission_1:EscalatedBeforeGettingToHQ()
  self.bEscalationTaskHappened = true
  self:FailTaskByName("GetToOrigHQ")
  if self.bDeEscalationTaskHappened == false then
    self:CreateTask({
      sName = "cooldownbeforetalking",
      sTaskType = "SabTaskObjectiveEscalation",
      sTaskSubType = "None",
      sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
      EscalationLevel = 0,
      tOnComplete = {
        {
          self.ReEnableTask,
          {self}
        }
      }
    })
  else
    self:ResetTaskByName("cooldownbeforetalking")
  end
end

function Paris_3_Mission_1:ReEnableTask()
  self.bDeEscalationTaskHappened = true
  self.GoToOrigHQ(self)
end

function Paris_3_Mission_1:SetupCheckpointOldHQ()
  self.RegisterCheckpoint(self, "Paris_3_Mission_1.GPSTarget")
end

function Paris_3_Mission_1:GPSTarget()
  local hWatchman = Util.GetHandleByName("Missions\\paris_3\\mission_1\\messenger\\Messenger_male")
  if hWatchman == nil or Object.IsAlive(hWatchman) == false then
    Paris_3_Mission_1.TargetCatacombsAfterConversation()
  else
    Nav.MoveToObject(hWatchman, hSab, 2, false)
    if Suspicion.GetEscalation() == 0 then
      Convo.AddConvo("P3M1_AtHQEntrance_NotEscalated", 1, {})
      Paris_3_Mission_1.TargetCatacombsAfterConversation()
    else
      Convo.AddConvo("P3M1_AtHQEntrance_Escalated", 1, {})
    end
  end
end

function Paris_3_Mission_1.TargetCatacombsAfterConversation()
  local hUsePoint = Util.GetHandleByName("Missions\\paris_3\\mission_1\\start\\DoorTriggerPoint")
  AttractionPt.EnableUse(hUsePoint, true)
  local hRes1 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\messenger\\Messenger")
  local hRes2 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\messenger\\Messenger_male")
  Actor.SetMissionCriticalNPC(hRes1, false)
  Actor.SetMissionCriticalNPC(hRes2, false)
  Paris_3_Mission_1:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\conversation\\PT_P3M1_Entrance_Discovered", hSab, "Paris_3_Mission_1.Entrance_Discovered", Paris_3_Mission_1, {}, cTRIGGEREVENT_ONENTER), "Missions\\paris_3\\mission_1\\conversation\\PT_P3M1_Entrance_Discovered")
  Paris_3_Mission_1:FailTaskByName("escalatedbeforetalking")
  Paris_3_Mission_1:FailTaskByName("cooldownbeforetalking")
  if Paris_3_Mission_1:IsMissionTaskActive("GoToStart") == false then
    Paris_3_Mission_1:CreateTask({
      sName = "GoToStart",
      sTaskType = "SabTaskObjectiveInteract",
      sObjectiveTextID = "P3M1_Text.GetToTheCatacombs",
      vGPSTarget = "Missions\\paris_3\\mission_1\\dynamic\\LOC_GoTo1",
      sTaskSubType = "USE",
      tTgtInclude = {
        "Missions\\paris_3\\mission_1\\start\\DoorTriggerPoint"
      },
      tOnComplete = {
        {
          Paris_3_Mission_1.Catacombs_Setup,
          {Paris_3_Mission_1}
        }
      }
    })
  end
end

function Paris_3_Mission_1:TeleportHack()
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\cheats\\PT_teleport1_outside", hSab, "Paris_3_Mission_1.TeleportHack1Ouside", self, nil, cTRIGGEREVENT_ONENTER), "Missions\\paris_3\\mission_1\\cheats\\PT_teleport1_outside")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\cheats\\PT_teleport2_stairs", hSab, "Paris_3_Mission_1.TeleportHack2Stairs", self, nil, cTRIGGEREVENT_ONENTER), "Missions\\paris_3\\mission_1\\cheats\\PT_teleport2_stairs")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\cheats\\PT_teleport3_chasm", hSab, "Paris_3_Mission_1.TeleportHack3Chasm", self, nil, cTRIGGEREVENT_ONENTER), "Missions\\paris_3\\mission_1\\cheats\\PT_teleport3_chasm")
end

function Paris_3_Mission_1:TeleportHack1Ouside()
  self.TeleportHack(self)
  local hLoc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\cheats\\LC_teleport1_outside")
  local x, y, z = Object.GetPosition(hLoc)
  Object.PlayerTeleportToLocator(Handle("Missions\\paris_3\\mission_1\\cheats\\LC_teleport1_outside"), true)
end

function Paris_3_Mission_1:TeleportHack2Stairs()
  self.TeleportHack(self)
  local hLoc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\cheats\\LC_teleport2_stairs")
  local x, y, z = Object.GetPosition(hLoc)
  self:FailTaskByName("GetToOrigHQ")
  self.Catacombs_Setup(self)
end

function Paris_3_Mission_1:TeleportHack3Chasm()
  self.tSaveInfo.nCurrent = 6
  local hLoc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\cheats\\LC_teleport3_chasm")
  local x, y, z = Object.GetPosition(hLoc)
  Object.PlayerTeleportToLocator(Handle("Missions\\paris_3\\mission_1\\cheats\\LC_teleport3_chasm"), true)
  Paris_3_Mission_1.CheckpointEnteredCatacombs(self)
  self.SetupConvoTriggers(self)
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\final_encounter_fence\\PT_checkpoint7", hSab, "Paris_3_Mission_1.Checkpoint7", self, {1}, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\final_encounter_fence\\PT_checkpoint7")
  Paris_3_Mission_1.Checkpoint7(self)
end

function Paris_3_Mission_1:ExteriorPatrols(tTable, sNaziName, sPathName)
  local hNazi = Handle(sNaziName)
  local sPath = sPathName
  Nav.SetScriptedPath(hNazi, sPath, false)
  Nav.SetScriptedPathType(hNazi, cPATHTYPE_LOOP)
end

function Paris_3_Mission_1:ExteriorPatrolsOnce(tTable, sNaziName, sPathName)
  local hNazi = Handle(sNaziName)
  local sPath = sPathName
  Nav.SetScriptedPath(hNazi, sPath, false)
  Nav.SetScriptedPathType(hNazi, cPATHTYPE_ONCE)
end

function Paris_3_Mission_1:ExteriorPatrols2(tTable, sNaziName, sPathName)
  local hNazi = Handle(sNaziName)
  local sPath = sPathName
  Nav.SetScriptedPath(hNazi, sPath, false)
  Nav.SetScriptedPathType(hNazi, cPATHTYPE_LOOP)
end

function Paris_3_Mission_1:ExteriorPatrolsD1(tTable, sNaziName, sPathName)
  EVENT_Timer("Paris_3_Mission_1.ExteriorPatrols", self, 2.3, {
    tTable,
    sNaziName,
    sPathName
  })
end

function Paris_3_Mission_1:ExteriorPatrolsD2(tTable, sNaziName, sPathName)
  EVENT_Timer("Paris_3_Mission_1.ExteriorPatrols2", self, 3, {
    tTable,
    sNaziName,
    sPathName
  })
end

function Paris_3_Mission_1:OnButtonPress(a_tButtonData)
  local tButtons = a_tButtonData[1]
  local hHandle
  if tButtons.DOWN == true and self.hackywacky == nil then
    self:CompleteTaskByName("GetToOrigHQ")
    Object.PlayerTeleportToPos(-665, 62, 609, 0)
    self.GPSTarget(self)
    self.hackywacky = "done"
  end
end

function Paris_3_Mission_1:Catacombs_Setup()
  self.tSaveInfo.collapseA = true
  self.tSaveInfo.collapseB = true
  self.tSaveInfo.collapseC = true
  self.tSaveInfo.DestroRig1A = true
  self.tSaveInfo.DestroRig2A = true
  self.tSaveInfo.DestroRig3A = true
  self.nCheckPoint = 3
  self.bDisable = false
  self.bRoomDoorOpened = {}
  self.bRoomDoorOpened[1] = false
  self.bRoomDoorOpened[2] = false
  self.nLastDestroLines = 0
  self.bSurpriseEntry = false
  Suspicion.EnableEscalationVehicles(false)
  Util.FreezeMiniZep(true)
  Util.EnableBirds(false)
  self.SetupConvoTriggers(self)
  self.SetupCatacombs(self)
  self.tSaveInfo.nCurrent = 2
  Zone.SwitchState("Missions\\paris_3\\mission_1\\WTF_Changes\\ResistanceZones", cZONESTATE_HIGHWTF, cENT_IMMEDIATE)
  self.ParticleFXSetup(self)
  HUD.SetPauseMenuPos(-684.3644, 55.297977, 607.72186)
end

function Paris_3_Mission_1:SetupCatacombs()
  local hLoc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\start\\Loc_Catacomb")
  Object.PlayerTeleportToLocator(hLoc, true, "Paris_3_Mission_1.SetupGameEvents", self, nil)
end

function Paris_3_Mission_1:SetupGameEvents()
  Util.SetTime(12, 0)
  Render.WTFSetOverrideBlueprint("WillToFight_INT_Catacomb")
  Render.EnableAmbientRain(false)
  self.SetupCheckpointEnteredCatacombs(self)
end

function Paris_3_Mission_1:PatrolTriggers()
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\hall1\\patrol_12\\PT_hall1_patrol_12A", hSab, "Paris_3_Mission_1.ExteriorPatrolsOnce", self, {
    "Missions\\paris_3\\mission_1\\hall1\\patrol_12\\NZ_hall1_patrol1",
    "Missions\\paris_3\\mission_1\\hall1\\patrol_12\\PA_hall1_patrol1A"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\hall1\\patrol_12\\PT_hall1_patrol_12A")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\hall1\\patrol_12\\PT_hall1_patrol_12B", hSab, "Paris_3_Mission_1.ExteriorPatrolsD1", self, {
    "Missions\\paris_3\\mission_1\\hall1\\patrol_12\\NZ_hall1_patrol1",
    "Missions\\paris_3\\mission_1\\hall1\\patrol_12\\PA_hall1_patrol1B"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\hall1\\patrol_12\\PT_hall1_patrol_12B")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\hall1\\patrol_12\\PT_hall1_patrol_12C", hSab, "Paris_3_Mission_1.ExteriorPatrols", self, {
    "Missions\\paris_3\\mission_1\\hall1\\patrol_12\\NZ_hall1_patrol1",
    "Missions\\paris_3\\mission_1\\hall1\\patrol_12\\PA_hall1_patrol1A"
  }, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\hall1\\patrol_12\\PT_hall1_patrol_12C")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\hall1\\PT_Hall1_Patrol_34B", hSab, "Paris_3_Mission_1.NaziGoOnPath", self, {
    {
      "Missions\\paris_3\\mission_1\\hall1\\patrol_34\\NZ_hall1_patrol3",
      "Missions\\paris_3\\mission_1\\hall1\\patrol_34\\NZ_hall1_patrol4"
    },
    {
      "Missions\\paris_3\\mission_1\\hall1\\patrol_34\\PA_hall1_patrol3B",
      "Missions\\paris_3\\mission_1\\hall1\\patrol_34\\PA_hall1_patrol4B"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\paris_3\\mission_1\\hall1\\PT_Hall1_Patrol_34B")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\hall1\\PT_Hall1_Patrol_56B", hSab, "Paris_3_Mission_1.NaziGoOnPath", self, {
    {
      "Missions\\paris_3\\mission_1\\hall1\\patrol_56\\NZ_hall1_patrol5",
      "Missions\\paris_3\\mission_1\\hall1\\patrol_56\\NZ_hall1_patrol6"
    },
    {
      "Missions\\paris_3\\mission_1\\hall1\\patrol_56\\PA_Grunt_hall1_patrol5A",
      "Missions\\paris_3\\mission_1\\hall1\\patrol_56\\PA_Grunt_hall1_patrol6A"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\paris_3\\mission_1\\hall1\\PT_Hall1_Patrol_56B")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\hall1\\triggerspawner3\\PT_Grunt_hall1_patrol3", hSab, "Paris_3_Mission_1.NaziGoOnPath", self, {
    {
      "Missions\\paris_3\\mission_1\\hall1\\triggerspawner3\\NZ_Grunt_hall1_patrol3A",
      "Missions\\paris_3\\mission_1\\hall1\\triggerspawner3\\NZ_Grunt_hall1_patrol3B"
    },
    {
      "Missions\\paris_3\\mission_1\\hall1\\triggerspawner3\\PA_Grunt_hall1_patrol3A",
      "Missions\\paris_3\\mission_1\\hall1\\triggerspawner3\\PA_Grunt_hall1_patrol3B"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\paris_3\\mission_1\\hall1\\triggerspawner3\\PT_Grunt_hall1_patrol3")
  self.P3M1_Hall1_SeesNaziShadows_Setup(self)
end

function Paris_3_Mission_1:SetupCheckpointEnteredCatacombs()
  self.RegisterCheckpoint(self, "Paris_3_Mission_1.CheckpointEnteredCatacombs")
  self.SetupDoorTriggers(self)
end

function Paris_3_Mission_1:CheckpointEnteredCatacombs()
  Sound.SetMusicLocale("P3M1_Catacombs")
  Sound.SetMusicLocale("m_P3M1_Catacombs", "enterCatacombs")
  self.WalkLayout(self)
  self.TriggerEvents1(self)
  Paris_3_Mission_1.FindTheResistance(self)
  Paris_3_Mission_1.PatrolTriggers(self)
  Util.LoadStaticENTag("Wall_Blast_Pri", true)
end

function Paris_3_Mission_1:LoadTheEditNode(tWho, sName)
  self:CreateTask({
    sName = sName,
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {sName}
  })
end

function Paris_3_Mission_1:UnloadAllNaziEditNodes()
end

function Paris_3_Mission_1:UnloadAllNaziEditNodes()
end

function Paris_3_Mission_1:TriggerEvents1()
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\room3\\4_bridge\\PT_load_6_destruction", hSab, "Paris_3_Mission_1.Load6destruction", self, {1}, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\room3\\4_bridge\\PT_load_6_destruction")
  self.hDestructionRigH1a = Util.CreateEvent({
    EventType = "DamageEvent",
    EventName = "H1Damage_a",
    ObjectName = "PARIS\\area03\\catacombs\\inteior\\hall_1\\destroom1\\Catacomb_ FloorRoof_12M_DAM",
    MinDamage = 20
  }, "Paris_3_Mission_1.DestructionRigH1", self, {}, false)
  self:RegisterEvent(self.hDestructionRigH1a)
  self.hDestructionRigH1b = Util.CreateEvent({
    EventType = "DamageEvent",
    EventName = "H1Damage_b",
    ObjectName = "PARIS\\area03\\catacombs\\inteior\\hall_1\\destroom1\\Catacomb_ FloorRoof_12M_DAM(1)",
    MinDamage = 20
  }, "Paris_3_Mission_1.DestructionRigH1", self, {}, false)
  self:RegisterEvent(self.hDestructionRigH1b)
  self.hDestructionRigH3a = Util.CreateEvent({
    EventType = "DamageEvent",
    EventName = "H3Damage_a",
    ObjectName = "PARIS\\area03\\catacombs\\inteior\\hall_3\\Catacomb_ FloorRoof_12M_DAM(1)",
    MinDamage = 20
  }, "Paris_3_Mission_1.DestructionRigH3", self, {}, false)
  self:RegisterEvent(self.hDestructionRigH3a)
  self.hDestructionRigH3b = Util.CreateEvent({
    EventType = "DamageEvent",
    EventName = "H3Damage_b",
    ObjectName = "PARIS\\area03\\catacombs\\inteior\\hall_3\\Catacomb_ FloorRoof_12M_DAM(3)",
    MinDamage = 20
  }, "Paris_3_Mission_1.DestructionRigH3", self, {}, false)
  self:RegisterEvent(self.hDestructionRigH3b)
  self.hDestructionRigR3a = Util.CreateEvent({
    EventType = "DamageEvent",
    EventName = "R3Damage_a",
    ObjectName = "PARIS\\area03\\catacombs\\inteior\\room_3\\Catacomb_ FloorRoof_12M_DAM(2)",
    MinDamage = 20
  }, "Paris_3_Mission_1.DestructionRigR3", self, {}, false)
  self:RegisterEvent(self.hDestructionRigR3a)
  self.hDestructionRigR3b = Util.CreateEvent({
    EventType = "DamageEvent",
    EventName = "R3Damage_b",
    ObjectName = "PARIS\\area03\\catacombs\\inteior\\room_3\\Catacomb_ FloorRoof_12M_DAM(3)",
    MinDamage = 20
  }, "Paris_3_Mission_1.DestructionRigR3", self, {}, false)
  self:RegisterEvent(self.hDestructionRigR3b)
  if self.nCheckPoint == 3 then
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\hall1\\PT_Hall1_Patrol_34_load", hSab, "Paris_3_Mission_1.LoadTheEditNode", self, {
      "Missions\\paris_3\\mission_1\\hall1\\patrol_34"
    }, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\hall1\\PT_Hall1_Patrol_34_load")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\hall1\\PT_Hall1_Patrol_56_load", hSab, "Paris_3_Mission_1.LoadTheEditNode", self, {
      "Missions\\paris_3\\mission_1\\hall1\\patrol_56"
    }, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\hall1\\PT_Hall1_Patrol_56_load")
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\dynamic\\PT_Checkpoint_H1", hSab, "Paris_3_Mission_1.SetupCheckpoint4", self, {
      "Catacomb_collapse_H1"
    }, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\dynamic\\PT_Checkpoint_H1")
  end
  if self.nCheckPoint == 4 then
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\dynamic\\PT_CollapseR1", hSab, "Paris_3_Mission_1.SetupCheckpoint5", self, {
      "Catacomb_collapse_R1"
    }, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\dynamic\\PT_CollapseR1")
  end
  if self.nCheckPoint == 5 then
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\convotrigger\\PT_CollapseEntrance2", hSab, "Paris_3_Mission_1.SetupCheckpoint6", self, {
      "Catacomb_collapse_H3"
    }, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\convotrigger\\PT_CollapseEntrance2")
  end
  if self.nCheckPoint == 6 then
    self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\final_encounter_fence\\PT_checkpoint7", hSab, "Paris_3_Mission_1.Checkpoint7", self, {1}, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\final_encounter_fence\\PT_checkpoint7")
  end
end

function Paris_3_Mission_1:SetupConvoTriggers()
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\dynamic\\PT_DestroyRoom1", hSab, "Paris_3_Mission_1.SetupRoom1ConvoEvents", self, {1, 1}, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\dynamic\\PT_DestroyRoom1")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\conversation\\PT_P3M1_Room2_UpstairsSuprise", hSab, "Paris_3_Mission_1.SuprisedEntry", self, {1}, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\conversation\\PT_P3M1_Room2_UpstairsSuprise")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\conversation\\PT_P3M1_Room2_DownstairsBad_First", hSab, "Paris_3_Mission_1.BadEntry1", self, {1}, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\conversation\\PT_P3M1_Room2_DownstairsBad_First")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\conversation\\PT_P3M1_Room2_DownstairsBad_Second", hSab, "Paris_3_Mission_1.BadEntry2", self, {1}, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\conversation\\PT_P3M1_Room2_DownstairsBad_Second")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\conversation\\PT_NewConvoRoom3", hSab, "Paris_3_Mission_1.PotentialConvoRoom3", self, {1}, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\conversation\\PT_NewConvoRoom3")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\convotrigger\\PT_HearBattle", hSab, "Paris_3_Mission_1.HearBattle", self, {1}, cTRIGGEREVENT_ONENTER), "Missions\\paris_3\\mission_1\\convotrigger\\PT_HearBattle")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\convotrigger\\PT_SeeChasm", hSab, "Paris_3_Mission_1.SeeChasm", self, {1}, cTRIGGEREVENT_ONENTER), "Missions\\paris_3\\mission_1\\convotrigger\\PT_SeeChasm")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\conversation\\PT_SpawnRoonDiscovered4", hSab, "Paris_3_Mission_1.P3M1_SpawnRoon_Discovered_Spawn4A", self, {1}, cTRIGGEREVENT_ONENTER), "Missions\\paris_3\\mission_1\\conversation\\PT_SpawnRoonDiscovered4")
end

function Paris_3_Mission_1:BlowUpRoomConvo2PT2()
  local hDam = Util.GetHandleByName("PARIS\\area03\\catacombs\\inteior\\hall_3\\Catacomb_ FloorRoof_12M_DAM(1)")
  if hDam then
    local tEvent = {EventType = "DeathEvent", ObjectHandle = hDam}
    self:RegisterEvent(Util.CreateEvent(tEvent, "Paris_3_Mission_1.BlowUpRoomConvo2PT3", self, {1}))
  end
end

function Paris_3_Mission_1:BlowUpRoomConvo2PT3()
  Cin.PlayConversation("P3M1_CollapseEntrance2")
end

function Paris_3_Mission_1:RemoveConvo_Spawn5()
  local hSpawn5 = Handle("Missions\\paris_3\\mission_1\\conversation\\P3M1_SpawnRoom_Discovered_Spawn5")
  if hSpawn5 then
    local tConvoSelf = Actor.GetSelf(hSpawn5)
    if tConvoSelf then
      ConversationTriggers.CleanUp(tConvoSelf)
    end
  end
end

function Paris_3_Mission_1:RemoveConvo_Spawn1()
  local hSpawn1 = Handle("Missions\\paris_3\\mission_1\\conversation\\P3M1_SpawnRoom_Discovered_Spawn1")
  if hSpawn1 then
    local tConvoSelf = Actor.GetSelf(hSpawn1)
    if tConvoSelf then
      ConversationTriggers.CleanUp(tConvoSelf)
    end
  end
end

function Paris_3_Mission_1:DestructionRigH1()
  if self.hDestructionRigH1a then
    Util.KillEvent(self.hDestructionRigH1a)
  end
  if self.hDestructionRigH1b then
    Util.KillEvent(self.hDestructionRigH1b)
  end
  self.uPlayerInTime = 0
  local hTrigger = Handle("Missions\\paris_3\\mission_1\\dynamic\\PT_DestructionRoom1_dupe")
  if Trigger.GetAllWithin(hTrigger) then
    self.uPlayerInTime = 4
  end
  local nRigHealth, hRig
  hRig = Handle("PARIS\\area03\\catacombs\\inteior\\hall_1\\destroom1\\Catacomb_ FloorRoof_12M_DAM(1)")
  hRigB = Handle("PARIS\\area03\\catacombs\\inteior\\hall_1\\destroom1\\Catacomb_ FloorRoof_12M_DAM")
  if hRig then
    Paris_3_Mission_1.RemoveConvo_Spawn1(self)
    Paris_3_Mission_1.RemoveConvo_Spawn5(self)
    EVENT_Timer("Paris_3_Mission_1.FxSpawnerFunction", self, 0.25, {
      "Missions\\paris_3\\mission_1\\particlefx\\DestroRig1A",
      8,
      2,
      "DestroRig1A",
      {
        "0FX_Dust01_Ceiling",
        "0FX_Cinematics_402_Dust"
      },
      1
    })
    EVENT_Timer("Paris_3_Mission_1.FxSpawnerFunction", self, 2 + self.uPlayerInTime, {
      "Missions\\paris_3\\mission_1\\particlefx\\DestroRig1A",
      8,
      3,
      "DestroRig1A",
      {
        "0FX_Dust01_Ceiling",
        "PHPFX_Wood_Lrg_A"
      },
      0.25
    })
    EVENT_Timer("Paris_3_Mission_1.FxSpawnerFunction", self, 4 + self.uPlayerInTime, {
      "Missions\\paris_3\\mission_1\\particlefx\\DestroRig1A",
      8,
      5,
      "DestroRig1A",
      {
        "0FX_Dust01_Ceiling",
        "PHPFX_Wood_Lrg_A"
      },
      0.25
    })
    EVENT_Timer("Paris_3_Mission_1.CameraShakeage", self, 0.5, {
      hRig,
      20,
      30,
      30
    })
    EVENT_Timer("Paris_3_Mission_1.PlaySoundFXCeiling", self, 0.5, {nil})
    EVENT_Timer("Paris_3_Mission_1.PlaySoundFXCeiling2", self, 2, {nil})
    EVENT_Timer("Paris_3_Mission_1.PlaySoundFXCeiling3", self, 5.5, {nil})
    EVENT_Timer("Paris_3_Mission_1.CameraShakeage", self, 2 + self.uPlayerInTime, {
      hRig,
      30,
      40,
      40
    })
    EVENT_Timer("Paris_3_Mission_1.CameraShakeage", self, 5 + self.uPlayerInTime, {
      hRig,
      50,
      60,
      60
    })
    EVENT_Timer("Paris_3_Mission_1.StopFXOnStuff", self, 5 + self.uPlayerInTime, {
      hRig,
      "DestroRig1A"
    })
    EVENT_Timer("Paris_3_Mission_1.KillThis", self, 5.5 + self.uPlayerInTime, {hRig})
    EVENT_Timer("Paris_3_Mission_1.KillThis", self, 4 + self.uPlayerInTime, {hRigB})
    EVENT_Timer("Paris_3_Mission_1.LoadDestroom1", self, 5.5, {nil})
    EVENT_Timer("Paris_3_Mission_1.KillEveryone", self, 6 + self.uPlayerInTime, {
      "Missions\\paris_3\\mission_1\\dynamic\\PT_DestructionRoom1",
      {
        "Missions\\paris_3\\mission_1\\hall1\\triggerspawner4\\BunkerSpawner2",
        "Missions\\paris_3\\mission_1\\hall1\\triggerspawner4\\BunkerSpawner3"
      },
      {
        "Missions\\paris_3\\mission_1\\hall1\\LC_collapse_explosion1",
        "Missions\\paris_3\\mission_1\\hall1\\LC_collapse_explosion2"
      }
    })
  end
end

function Paris_3_Mission_1:LoadDestroom1()
  self:CreateTask({
    sName = "LoadDestroom1Task",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bRepeatable = true,
    tStaticTags = {
      "DestructionRoom1"
    }
  })
end

function Paris_3_Mission_1:LoadDestroom2()
  self:CreateTask({
    sName = "LoadDestroom2Task",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bRepeatable = true,
    tStaticTags = {
      "DestructionRoom2"
    }
  })
end

function Paris_3_Mission_1:LoadDestroom3()
  self:CreateTask({
    sName = "LoadDestroom3Task",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bRepeatable = true,
    tStaticTags = {
      "DestructionRoom3"
    }
  })
end

function Paris_3_Mission_1:DestructionRigH3()
  if self.hDestructionRigH3a then
    Util.KillEvent(self.hDestructionRigH3a)
  end
  if self.hDestructionRigH3b then
    Util.KillEvent(self.hDestructionRigH3b)
  end
  self.uPlayerInTime = 0
  local hTrigger = Handle("Missions\\paris_3\\mission_1\\dynamic\\PT_DestructionRoom2_dupe")
  if Trigger.GetAllWithin(hTrigger) then
    self.uPlayerInTime = 4
  end
  local nRigHealth
  local hRig2 = Handle("PARIS\\area03\\catacombs\\inteior\\hall_3\\Catacomb_ FloorRoof_12M_DAM(1)")
  local hRig2b = Handle("PARIS\\area03\\catacombs\\inteior\\hall_3\\Catacomb_ FloorRoof_12M_DAM(3)")
  if hRig2 then
    EVENT_Timer("Paris_3_Mission_1.FxSpawnerFunction", self, 0.25, {
      "Missions\\paris_3\\mission_1\\particlefx\\DestroRig2A",
      8,
      2,
      "DestroRig2A",
      {
        "0FX_Dust01_Ceiling",
        "0FX_Cinematics_402_Dust"
      },
      1
    })
    EVENT_Timer("Paris_3_Mission_1.FxSpawnerFunction", self, 2 + self.uPlayerInTime, {
      "Missions\\paris_3\\mission_1\\particlefx\\DestroRig2A",
      8,
      3,
      "DestroRig2A",
      {
        "0FX_Dust01_Ceiling",
        "PHPFX_Wood_Lrg_A"
      },
      0.25
    })
    EVENT_Timer("Paris_3_Mission_1.FxSpawnerFunction", self, 4 + self.uPlayerInTime, {
      "Missions\\paris_3\\mission_1\\particlefx\\DestroRig2A",
      8,
      5,
      "DestroRig2A",
      {
        "0FX_Dust01_Ceiling",
        "PHPFX_Wood_Lrg_A"
      },
      0.25
    })
    EVENT_Timer("Paris_3_Mission_1.CameraShakeage", self, 0.5, {
      hRig2,
      20,
      30,
      30
    })
    EVENT_Timer("Paris_3_Mission_1.PlaySoundFXCeiling", self, 0.5, {nil})
    EVENT_Timer("Paris_3_Mission_1.PlaySoundFXCeiling2", self, 2, {nil})
    EVENT_Timer("Paris_3_Mission_1.PlaySoundFXCeiling3", self, 5.5, {nil})
    EVENT_Timer("Paris_3_Mission_1.CameraShakeage", self, 2 + self.uPlayerInTime, {
      hRig2,
      30,
      40,
      40
    })
    EVENT_Timer("Paris_3_Mission_1.CameraShakeage", self, 5 + self.uPlayerInTime, {
      hRig2,
      50,
      60,
      60
    })
    EVENT_Timer("Paris_3_Mission_1.StopFXOnStuff", self, 5 + self.uPlayerInTime, {
      hRig2,
      "DestroRig2A"
    })
    EVENT_Timer("Paris_3_Mission_1.KillThis", self, 5.5 + self.uPlayerInTime, {hRig2})
    EVENT_Timer("Paris_3_Mission_1.KillThis", self, 4 + self.uPlayerInTime, {hRig2b})
    EVENT_Timer("Paris_3_Mission_1.LoadDestroom2", self, 5.5, {nil})
    EVENT_Timer("Paris_3_Mission_1.KillEveryone2", self, 6 + self.uPlayerInTime, {
      "Missions\\paris_3\\mission_1\\dynamic\\PT_DestructionRoom2",
      {
        "Missions\\paris_3\\mission_1\\room2\\nazi_encounters2\\BunkerSpawner1",
        "Missions\\paris_3\\mission_1\\room2\\nazi_encounters2\\BunkerSpawner2"
      },
      {
        "Missions\\paris_3\\mission_1\\room2\\LC_collapse_explosion1",
        "Missions\\paris_3\\mission_1\\room2\\LC_collapse_explosion2"
      }
    })
  end
end

function Paris_3_Mission_1:DestructionRigR3()
  if self.hDestructionRigR3a then
    Util.KillEvent(self.hDestructionRigR3a)
  end
  if self.hDestructionRigR3b then
    Util.KillEvent(self.hDestructionRigR3b)
  end
  self.uPlayerInTime = 0
  local hTrigger = Handle("Missions\\paris_3\\mission_1\\dynamic\\PT_DestructionRoom3")
  if Trigger.GetAllWithin(hTrigger) then
    self.uPlayerInTime = 4
  end
  local nRigHealth
  local hRig3 = Handle("PARIS\\area03\\catacombs\\inteior\\room_3\\Catacomb_ FloorRoof_12M_DAM(2)")
  local hRig3b = Handle("PARIS\\area03\\catacombs\\inteior\\room_3\\Catacomb_ FloorRoof_12M_DAM(3)")
  if hRig3 then
    EVENT_Timer("Paris_3_Mission_1.FxSpawnerFunction", self, 0.25, {
      "Missions\\paris_3\\mission_1\\particlefx\\DestroRig3A",
      8,
      2,
      "DestroRig3A",
      {
        "0FX_Dust01_Ceiling",
        "0FX_Cinematics_402_Dust"
      },
      1
    })
    EVENT_Timer("Paris_3_Mission_1.FxSpawnerFunction", self, 2 + self.uPlayerInTime, {
      "Missions\\paris_3\\mission_1\\particlefx\\DestroRig3A",
      8,
      3,
      "DestroRig3A",
      {
        "0FX_Dust01_Ceiling",
        "PHPFX_Wood_Lrg_A"
      },
      0.25
    })
    EVENT_Timer("Paris_3_Mission_1.FxSpawnerFunction", self, 4 + self.uPlayerInTime, {
      "Missions\\paris_3\\mission_1\\particlefx\\DestroRig3A",
      8,
      5,
      "DestroRig3A",
      {
        "0FX_Dust01_Ceiling",
        "PHPFX_Wood_Lrg_A"
      },
      0.25
    })
    EVENT_Timer("Paris_3_Mission_1.CameraShakeage", self, 0.5, {
      hRig3,
      20,
      30,
      30
    })
    EVENT_Timer("Paris_3_Mission_1.PlaySoundFXCeiling", self, 0.5, {nil})
    EVENT_Timer("Paris_3_Mission_1.PlaySoundFXCeiling2", self, 2, {nil})
    EVENT_Timer("Paris_3_Mission_1.PlaySoundFXCeiling3", self, 5.5, {nil})
    EVENT_Timer("Paris_3_Mission_1.CameraShakeage", self, 2 + self.uPlayerInTime, {
      hRig3,
      30,
      40,
      40
    })
    EVENT_Timer("Paris_3_Mission_1.CameraShakeage", self, 5 + self.uPlayerInTime, {
      hRig3,
      50,
      60,
      60
    })
    EVENT_Timer("Paris_3_Mission_1.StopFXOnStuff", self, 5 + self.uPlayerInTime, {
      hRig3,
      "DestroRig3A"
    })
    EVENT_Timer("Paris_3_Mission_1.KillThis", self, 5.5 + self.uPlayerInTime, {hRig3})
    EVENT_Timer("Paris_3_Mission_1.KillThis", self, 4 + self.uPlayerInTime, {hRig3b})
    EVENT_Timer("Paris_3_Mission_1.LoadDestroom3", self, 5.5, {nil})
    EVENT_Timer("Paris_3_Mission_1.KillEveryone2", self, 6 + self.uPlayerInTime, {
      "Missions\\paris_3\\mission_1\\dynamic\\PT_DestructionRoom3",
      {
        "Missions\\paris_3\\mission_1\\room3\\triggerspawner2\\BunkerSpawnerB1"
      },
      {
        "Missions\\paris_3\\mission_1\\room3\\LC_collapse_explosion1",
        "Missions\\paris_3\\mission_1\\room3\\LC_collapse_explosion2"
      }
    })
  end
end

function Paris_3_Mission_1:PlaySoundFXCeiling()
  Sound.PlayOwnerlessSoundEvent("Emt_P1M3_CeilingCollapse")
end

function Paris_3_Mission_1:PlaySoundFXCeiling2()
  Sound.PlayOwnerlessSoundEvent("Emt_P1M3_CeilingCollapse_part2")
end

function Paris_3_Mission_1:PlaySoundFXCeiling3()
  Sound.PlayOwnerlessSoundEvent("Emt_P1M3_CeilingCollapse_part3")
end

function Paris_3_Mission_1:KillThis(hWhat)
  Object.Kill(hWhat)
end

function Paris_3_Mission_1:CameraShakeage(hRig, nNum1, nNum2, nNum3)
  local x, y, z = Object.GetPosition(hRig)
  Render.CameraShakeExplosion(x, y, z, nNum1, nNum2, nNum3)
end

function Paris_3_Mission_1:StopFXOnStuff(hRig, sWhichone)
  local x, y, z = Object.GetPosition(hRig)
  Render.CameraShakeExplosion(x, y, z, 105, 90, 90)
  self.tSaveInfo[sWhichone] = false
end

function Paris_3_Mission_1:ParticleFXSetup()
  self.FxSpawnerFunction(self, "Missions\\paris_3\\mission_1\\particlefx\\collapseA", 3, 1, "collapseA", {
    "0FX_Dust01_Ceiling"
  }, 1)
  self.FxSpawnerFunction(self, "Missions\\paris_3\\mission_1\\particlefx\\collapseB", 3, 1, "collapseB", {
    "0FX_Dust01_Ceiling"
  }, 1)
  self.FxSpawnerFunction(self, "Missions\\paris_3\\mission_1\\particlefx\\collapseC", 3, 1, "collapseC", {
    "0FX_Dust01_Ceiling"
  }, 1)
  self.FxSpawnerFunction(self, "Missions\\paris_3\\mission_1\\particlefx\\DestroRig1A", 8, 3, "DestroRig1A", {
    "0FX_Dust01_Ceiling"
  }, 1)
  self.FxSpawnerFunction(self, "Missions\\paris_3\\mission_1\\particlefx\\DestroRig2A", 9, 3, "DestroRig2A", {
    "0FX_Dust01_Ceiling"
  }, 1)
  self.FxSpawnerFunction(self, "Missions\\paris_3\\mission_1\\particlefx\\DestroRig3A", 7, 3, "DestroRig3A", {
    "0FX_Dust01_Ceiling"
  }, 1)
end

function Paris_3_Mission_1:KillEveryone(sTrigger, tSpawners, tParticleLocs)
  EVENT_Timer("Paris_3_Mission_1.DelaytheKill", self, 1.5, {sTrigger})
  for i, v in ipairs(tSpawners) do
    local spawnerhandle = Util.GetHandleByName(v)
    if spawnerhandle then
      Object.EnableSpawner(spawnerhandle, false)
    end
  end
  for i, v in ipairs(tParticleLocs) do
    local lochandle = Util.GetHandleByName(v)
    if lochandle then
      Render.StartFX(lochandle, "0FX_Cinematics_402_Dust", nil)
      Render.SetFXTime(lochandle, 6)
    end
  end
  if self.nLastDestroLines == 0 then
    Paris_3_Mission_1.DEBUGPlayConversation(self, "P3M1_SpawnRoom_Destroyed_General")
  else
  end
end

function Paris_3_Mission_1:KillEveryone2(sTrigger, tSpawners, tParticleLocs)
  EVENT_Timer("Paris_3_Mission_1.DelaytheKill", self, 1.5, {sTrigger})
  for i, v in ipairs(tSpawners) do
    local spawnerhandle = Util.GetHandleByName(v)
    if spawnerhandle then
      Object.EnableSpawner(spawnerhandle, false)
    end
  end
  for i, v in ipairs(tParticleLocs) do
    local lochandle = Util.GetHandleByName(v)
    if lochandle then
      Render.StartFX(lochandle, "0FX_Cinematics_402_Dust", nil)
      Render.SetFXTime(lochandle, 6)
    end
  end
end

function Paris_3_Mission_1:DelaytheKill(sTrigger)
  local hTrigger = Util.GetHandleByName(sTrigger)
  local tHandles = Trigger.GetAllWithin(hTrigger)
  if tHandles then
    for i, v in ipairs(tHandles) do
      Object.Kill(v)
    end
  end
end

function Paris_3_Mission_1:P3M1_Hall1_SeesNaziShadows_Setup()
  local sLocatorName = "Missions\\paris_3\\mission_1\\conversation\\LC_Hall1_SeesNaziShadows2"
  local tSeeRigEvent = {
    EventType = "SeeLocatorEvent",
    Locator = sLocatorName,
    Proximity = 10
  }
  self:RegisterEvent(Util.CreateEvent(tSeeRigEvent, "Paris_3_Mission_1.P3M1_Hall1_SeesNaziShadows", self, {
    "Missions\\paris_3\\mission_1\\conversation\\PT_Hall1_SeesNaziShadows2"
  }))
  sLocatorName = "Missions\\paris_3\\mission_1\\conversation\\LC_Hall1_SeesShadow3"
  local tSeeRigEvent = {
    EventType = "SeeLocatorEvent",
    Locator = sLocatorName,
    Proximity = 4
  }
  self:RegisterEvent(Util.CreateEvent(tSeeRigEvent, "Paris_3_Mission_1.P3M1_Hall1_SeesNaziShadows", self, {
    "Missions\\paris_3\\mission_1\\conversation\\PT_Hall1_SeesShadow3"
  }))
  sLocatorName = "Missions\\paris_3\\mission_1\\conversation\\LC_SeeShadows1"
  tSeeRigEvent = {
    EventType = "SeeLocatorEvent",
    Locator = sLocatorName,
    Proximity = 5
  }
  self:RegisterEvent(Util.CreateEvent(tSeeRigEvent, "Paris_3_Mission_1.P3M1_Hall1_SeesNaziShadows", self, {
    "Missions\\paris_3\\mission_1\\conversation\\PT_SeeShadow1"
  }))
  local tEvent = {EventType = "TimerEvent", Time = 1.5}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Paris_3_Mission_1.ChangeMinimap", self))
end

function Paris_3_Mission_1:ChangeMinimap()
  HUD.SetMinimapZoom(true, 0.7)
end

function Paris_3_Mission_1:FindTheResistance()
  self:CreateTask({
    sName = "FindResistance",
    sTaskType = "SabTaskObjectiveDeliver",
    Proximity = 5,
    sObjectiveTextID = "P3M1_Text.FindTheResistance",
    sTaskSubType = "DELIVER",
    tDestProximityObj = {
      "Missions\\paris_3\\mission_1\\dynamic\\LOC_FoundResist"
    },
    tDeliverObjs = {hSab},
    bNoHUDBlip = true,
    tOnComplete = {
      {
        self.CinematicLucExp,
        {self}
      }
    }
  })
end

function Paris_3_Mission_1:Rendezvous()
  self:ChangeObjTextByName("FindResistance", "P3M1_Text.Rendezvous")
  self:CreateTask({
    sName = "Rendezvous",
    sTaskType = "SabTaskObjectiveDeliver",
    Proximity = 5,
    sTaskSubType = "DELIVER",
    tDestProximityObj = {
      "Missions\\paris_3\\mission_1\\dynamic\\LC_rendezvous"
    },
    tDeliverObjs = {hSab},
    vGPSTarget = "Missions\\paris_3\\mission_1\\dynamic\\LC_rendezvous",
    bNoHUDBlip = true
  })
end

function Paris_3_Mission_1:FAKEMAIN_SaveLuc()
  self:CreateTask({
    sName = "Parent_SaveLuc",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tOnActivate = {
      {
        self.WalkLayout,
        {
          self,
          2,
          22
        }
      }
    }
  })
end

function Paris_3_Mission_1:WalkLayout()
  if not self:IsMissionTaskActive("GetToPoint") and self.tSaveInfo.nCurrent <= 5 then
    self:CreateTask({
      sName = "GetToPoint",
      sTaskType = "SabTaskObjectiveDeliver",
      bNoWorldBlip = true,
      sTaskSubType = "GOTO",
      tLocators = {
        "Missions\\paris_3\\mission_1\\dynamic\\LOC_GoTo" .. self.tSaveInfo.nCurrent
      },
      tDestRegion = "Missions\\paris_3\\mission_1\\dynamic\\PT_GoTo" .. self.tSaveInfo.nCurrent,
      tDeliverObjs = {hSab},
      tOnComplete = {
        {
          self.WalkLayoutDone,
          {self}
        }
      }
    })
  end
end

function Paris_3_Mission_1:WalkLayoutDone()
  self:ResetTaskByName("GetToPoint", true)
  self.tSaveInfo.nCurrent = self.tSaveInfo.nCurrent + 1
  Paris_3_Mission_1.WalkLayout(self)
end

function Paris_3_Mission_1:Entrance_Discovered()
  Cin.PlayConversation("P3M1_CatacombsEnterance_Discovered")
end

function Paris_3_Mission_1:P3M1_Hall1_SeesNaziShadows(tData)
  local hTrigger = Util.GetHandleByName(tData)
  if hTrigger then
    local hLabel = Filter.New("Nazi")
    local tWho = Trigger.GetAllWithin(hTrigger, hLabel)
    if tWho then
    end
    Filter.Delete(hLabel)
  end
end

function Paris_3_Mission_1:P3M1_Hall2_SeesNaziShadows_SETUP()
  local sLocatorName = "hi!"
  local tSeeRigEvent = {
    EventType = "SeeLocatorEvent",
    Locator = sLocatorName,
    Proximity = 4
  }
  Util.CreateEvent(tSeeRigEvent, "Paris_3_Mission_1.P3M1_Hall2_SeesNaziShadows", self, {"hi!"})
  sLocatorName = "hi!2"
  local tSeeRigEvent = {
    EventType = "SeeLocatorEvent",
    Locator = sLocatorName,
    Proximity = 4
  }
  Util.CreateEvent(tSeeRigEvent, "Paris_3_Mission_1.P3M1_Hall2_SeesNaziShadows", self, {"hi!2"})
end

function Paris_3_Mission_1:P3M1_Hall2_SeesNaziShadows(tData)
  local sTriggerName = "hi!"
  local hTrigger = Util.GetHandleByName(tDatad)
  if hTrigger then
    local hLabel = Filter.New("Nazi")
    local tWho = Trigger.GetAllWithin(hTrigger, hLabel)
    if tWho then
      Paris_3_Mission_1.DEBUGPlayConversation(self, "P3M1_Hall2_SeesNaziShadows")
    end
    Filter.Delete(hLabel)
  end
end

function Paris_3_Mission_1:SetupRoom1ConvoEvents()
  local tempspeakers = self.ReturnSpeakers(self, "Missions\\paris_3\\mission_1\\conversation\\PT_P3M1_Room1_Escape_Hurry", "Nazi", 1)
  self.SetupRoom1EncounterChange(self)
end

function Paris_3_Mission_1:SetupRoom1EncounterChange()
  local tTargets = {}
  tTargets = {
    "Missions\\paris_3\\mission_1\\room1\\target1\\OccMed_Generator_D",
    "Missions\\paris_3\\mission_1\\room1\\target2\\OccMed_Generator_B",
    "Missions\\paris_3\\mission_1\\room1\\target3\\OccMed_Generator_F",
    "Missions\\paris_3\\mission_1\\room1\\target5\\OccMed_Generator_C",
    "Missions\\paris_3\\mission_1\\room1\\target6\\Crate",
    "Missions\\paris_3\\mission_1\\room1\\target7\\OccMed_GasCannister_Cluster_A(2)",
    "Missions\\paris_3\\mission_1\\room1\\target8\\OccMed_GasCannister_Cluster_A(2)",
    "PARIS\\area03\\catacombs\\inteior\\room_1\\P_Global_A_Crate_ComboA_DAM(2)\\Crate",
    "Missions\\paris_3\\mission_1\\room1\\Spore_SS_Officer_PS_1",
    "Missions\\paris_3\\mission_1\\room1\\Spore_SS_Heavy_MG",
    "Missions\\paris_3\\mission_1\\room1\\Spore_SS_Grunt_MG_3(2)"
  }
  for i = #tTargets, 1, -1 do
    local hValid = Util.GetHandleByName(tTargets[i])
    if hValid == nil then
      table.remove(tTargets, i)
    end
  end
  if 0 < #tTargets then
    self:CreateTask({
      sName = "DestroyStuff1",
      sTaskType = "SabTaskObjectiveDestroy",
      sTaskSubType = "KILL",
      bNoFocus = true,
      bNoHUDBlip = true,
      bNoWorldBlip = true,
      TaskCount = 2,
      tTgtInclude = tTargets,
      tOnComplete = {
        {
          self.ChangeWTFRoom1,
          {self}
        }
      }
    })
  end
end

function Paris_3_Mission_1:ChangeWTFRoom1()
end

function Paris_3_Mission_1:SpawnBridgeGuy()
  self:CreateTask({
    sName = "Missions\\paris_3\\mission_1\\bridgeexp",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\paris_3\\mission_1\\bridgeexp"
    }
  })
end

function Paris_3_Mission_1:BridgeDeath()
  local sLoc = "Missions\\paris_3\\mission_1\\bridgeexp\\explosion"
  local x, y, z = Object.GetPosition(Util.GetHandleByName(sLoc))
  Util.CreateExplosion("Explosion_SAB_DynamiteFuse", x, y, z)
  local hBridge = Util.GetHandleByName("PARIS\\area03\\catacombs\\inteior\\room_3\\Catacomb_Planks(1)")
  Object.Kill(hBridge)
  local hRes = Util.GetHandleByName("Missions\\paris_3\\mission_1\\bridgeexp\\Spore_RS_Fighter_MG")
  local hRunTo = Util.GetHandleByName("Missions\\paris_3\\mission_1\\bridgeexp\\goto")
  if hRes then
    Nav.MoveToObject(hRes, hRunTo, 1, true)
  end
end

function Paris_3_Mission_1:SetupExplosionFight1()
  Paris_3_Mission_1.UbermanInvincible(self)
  local tEvent = {}
  tEvent = {EventType = "TimerEvent", Time = 0.2}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Paris_3_Mission_1.SpawnExplosionAtLocation", self, {
    "Missions\\paris_3\\mission_1\\conversation\\exp0A"
  }))
  tEvent = {EventType = "TimerEvent", Time = 1}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Paris_3_Mission_1.SpawnExplosionAtLocation", self, {
    "Missions\\paris_3\\mission_1\\conversation\\exp0B"
  }))
  tEvent = {EventType = "TimerEvent", Time = 1.2}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Paris_3_Mission_1.SpawnExplosionAtLocation", self, {
    "Missions\\paris_3\\mission_1\\conversation\\exp0C"
  }))
  tEvent = {EventType = "TimerEvent", Time = 2.8}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Paris_3_Mission_1.SpawnExplosionAtLocation", self, {
    "Missions\\paris_3\\mission_1\\conversation\\exp0D"
  }))
end

function Paris_3_Mission_1:SetupExplosionFight()
  local tEvent = {}
  tEvent = {EventType = "TimerEvent", Time = 0.2}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Paris_3_Mission_1.SpawnExplosionAtLocation", self, {
    "Missions\\paris_3\\mission_1\\conversation\\exp1"
  }))
  tEvent = {EventType = "TimerEvent", Time = 3.2}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Paris_3_Mission_1.SpawnExplosionAtLocation", self, {
    "Missions\\paris_3\\mission_1\\conversation\\exp3"
  }))
end

function Paris_3_Mission_1:SetupExplosionFight2()
  local tEvent = {}
  tEvent = {EventType = "TimerEvent", Time = 0.4}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Paris_3_Mission_1.SpawnExplosionAtLocation", self, {
    "Missions\\paris_3\\mission_1\\conversation\\exp2"
  }))
  tEvent = {EventType = "TimerEvent", Time = 2.2}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Paris_3_Mission_1.SpawnExplosionAtLocation", self, {
    "Missions\\paris_3\\mission_1\\conversation\\exp4"
  }))
end

function Paris_3_Mission_1:LoadFinalNazis()
  Paris_3_Mission_1.bNodeLoadedForFinalNazi = true
  if Handle("Missions\\paris_3\\mission_1\\final_nazis\\nazi1") == nil then
    Util.SpawnEditNode("Missions\\paris_3\\mission_1\\final_nazis.wsd")
  end
  if Handle("Missions\\paris_3\\mission_1\\final_encounter2\\res1") == nil then
    Util.SpawnEditNode("Missions\\paris_3\\mission_1\\final_encounter2.wsd")
  end
end

function Paris_3_Mission_1:BadEntry1()
  Cin.PlayConversation("P3M1_Room2_DownstairsBad_First")
end

function Paris_3_Mission_1:BadEntry2()
  Cin.PlayConversation("P3M1_Room2_DownstairsBad_Second")
end

function Paris_3_Mission_1:SuprisedEntry()
  self.bSurpriseEntry = true
  if Suspicion.IsSomeoneHostile() == false then
    local hTrigger = Util.GetHandleByName("Missions\\paris_3\\mission_1\\conversation\\PT_TalkBottomGuys")
    if hTrigger then
      local hLabel = Filter.New("Nazi")
      local tWho = Trigger.GetAllWithin(hTrigger, hLabel)
      if tWho then
        Cin.PlayConversationWith("P3M1_Room2_UpstairsSuprise", {
          tWho[1]
        })
      end
    end
  end
end

function Paris_3_Mission_1:PlayerStillInRoom1()
  local playerlabel = Filter.New("Player")
  local tWho = Trigger.GetAllWithin(Util.GetHandleByName("Missions\\paris_3\\mission_1\\conversation\\PT_P3M1_Room1_Escape_Hurry"), playerlabel)
  if tWho then
    for i, v in ipairs(tWho) do
      if v == hSab then
        Paris_3_Mission_1.DEBUGPlayConversation(self, "P3M1_Room1_Escape_Hurry")
      end
    end
  end
  Filter.Delete(playerlabel)
end

function Paris_3_Mission_1:PlayerStillInRoom2()
  local playerlabel = Filter.New("Player")
  local tWho = Trigger.GetAllWithin(Util.GetHandleByName("Missions\\paris_3\\mission_1\\conversation\\PT_P3M1_Room1_Escape_Hurry"), playerlabel)
  if tWho then
    for i, v in ipairs(tWho) do
      if v == hSab then
        Paris_3_Mission_1.DEBUGPlayConversation(self, "P3M1_Room2_Escape_Hurry")
      end
    end
  end
  Filter.Delete(playerlabel)
end

function Paris_3_Mission_1:SetupCheckpoint4()
  self.RegisterCheckpoint(self, "Paris_3_Mission_1.Checkpoint4")
  self.SetupDoorTriggers(self)
end

function Paris_3_Mission_1:Checkpoint4()
  self.nCheckPoint = 4
  self.WalkLayout(self)
  self.TriggerEvents1(self)
  Paris_3_Mission_1.FindTheResistance(self)
end

function Paris_3_Mission_1:ExecutionFind(sExeNazi, sRSVic, sRSVic2, sFindTrig)
  local hExeNazi = Handle(sExeNazi)
  local hRSVic = Handle(sRSVic)
  local hRSVic2 = Handle(sRSVic2)
  Actor.PlayAnimation(hRSVic, "civ_harass_stand_idle", -1, true)
  if hRSVic2 then
    Actor.PlayAnimation(hRSVic2, "civ_harass_stand_idle", -1, true)
    Actor.OverrideCombatAI(hRSVic2, true)
  end
  Actor.OverrideCombatAI(hExeNazi, true)
  Actor.OverrideCombatAI(hRSVic, true)
  Trigger.WaitFor(sFindTrig, hSab, "Paris_3_Mission_1.ExecuteRS", self, {
    hExeNazi,
    hRSVic,
    hRSVic2
  }, cTRIGGEREVENT_ONENTER)
end

function Paris_3_Mission_1:ExecuteRS(hWhateverThisIs, hExeNazi, hRSVic, hRSVic2)
  local tSequence = {
    {
      "PLAYANIMATION",
      {
        "civ_harass_stand_idle"
      }
    },
    {
      "DELAY",
      {1}
    },
    {
      "PLAYANIMATION",
      {
        "civ_kneel_harass_into"
      }
    },
    {
      "DELAY",
      {0.6}
    },
    {
      "PLAYANIMATION",
      {
        "civ_kneel_harass_idle"
      }
    }
  }
  ScriptSequence.Run(hRSVic, tSequence)
  if hRSVic2 then
    local tSequence = {
      {
        "PLAYANIMATION",
        {
          "civ_harass_stand_idle"
        }
      },
      {
        "DELAY",
        {1.5}
      },
      {
        "PLAYANIMATION",
        {
          "civ_kneel_harass_into"
        }
      },
      {
        "DELAY",
        {0.6}
      },
      {
        "PLAYANIMATION",
        {
          "civ_kneel_harass_idle"
        }
      }
    }
    ScriptSequence.Run(hRSVic2, tSequence)
  end
  EVENT_Timer("Paris_3_Mission_1.PulldaTrigger", self, 2, {
    hExeNazi,
    hRSVic,
    hRSVic2
  })
  EVENT_Timer("Paris_3_Mission_1.RSgetUp", self, 5, {
    hExeNazi,
    hRSVic,
    hRSVic2
  })
end

function Paris_3_Mission_1:PulldaTrigger(hExeNazi, hRSVic, hRSVic2)
  Util.CreateExecutionScene(hExeNazi, {hRSVic, hRSVic2}, cEXECUTION_ONEBYONE_STANDING, "Paris_3_Mission_1.ExecutionEnd", self, {
    hExeNazi,
    hRSVic,
    hRSVic2
  })
end

function Paris_3_Mission_1:ExecutionEnd(hExeNazi, hRSVic, hRSVic2)
  Actor.OverrideCombatAI(hExeNazi, false)
end

function Paris_3_Mission_1:RSgetUp(hExeNazi, hRSVic, hRSVic2)
  Squad.SetEnemy("GenericNazi", "Saboteur", true)
  if Actor.IsAlive(hRSVic) then
    local tSequence = {
      {
        "PLAYANIMATION",
        {
          "civ_harass_kneel_outof"
        }
      }
    }
    ScriptSequence.Run(hRSVic, tSequence)
    Actor.OverrideCombatAI(hRSVic, false)
    Squad.AddMember("Saboteur", hRSVic)
    Combat.SetCombat(hRSVic)
    Nav.FollowObject(hRSVic, hSab, 3.5, true, true)
    Render.PrintMessage("VO request 16987")
  end
  if Actor.IsAlive(hRSVic2) then
    if not Actor.IsAlive(hRSVic) then
      Render.PrintMessage("VO request 16987 b")
    end
    local tSequence = {
      {
        "PLAYANIMATION",
        {
          "civ_harass_kneel_outof"
        }
      }
    }
    ScriptSequence.Run(hRSVic2, tSequence)
    Actor.OverrideCombatAI(hRSVic2, false)
    Squad.AddMember("Saboteur", hRSVic2)
    Combat.SetCombat(hRSVic2)
    Nav.FollowObject(hRSVic2, hSab, 3.5, true, true)
  end
end

function Paris_3_Mission_1:SetupCheckpoint5()
  self.RegisterCheckpoint(self, "Paris_3_Mission_1.Checkpoint5")
  self.SetupDoorTriggers(self)
end

function Paris_3_Mission_1:Checkpoint5()
  self.nCheckPoint = 5
  self.WalkLayout(self)
  self.TriggerEvents1(self)
  Trigger.WaitFor("Missions\\paris_3\\mission_1\\dynamic\\PT_CloseRoom2", hSab, "Paris_3_Mission_1.SetupHall3Find", self, {}, cTRIGGEREVENT_ONENTER)
  Paris_3_Mission_1.FindTheResistance(self)
end

function Paris_3_Mission_1:SetupHall3Find()
  local sRSVic = "Missions\\paris_3\\mission_1\\hall3\\RS_Killed"
  local sRSVic = "Missions\\paris_3\\mission_1\\hall3\\RS_Killed2"
  local sExeNazi = "Missions\\paris_3\\mission_1\\hall3\\RS_Killa"
  local sFindTrig = "Missions\\paris_3\\mission_1\\dynamic\\PT_Execution2"
  Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\paris_3\\mission_1\\hall3\\RS_Killed",
      "Missions\\paris_3\\mission_1\\hall3\\RS_Killed2",
      "Missions\\paris_3\\mission_1\\hall3\\RS_Killa"
    }
  }, "Paris_3_Mission_1.ExecutionFind", self, {
    sExeNazi,
    sRSVic,
    false,
    sFindTrig
  })
end

function Paris_3_Mission_1:SetupCheckpoint6()
  self.RegisterCheckpoint(self, "Paris_3_Mission_1.Checkpoint6")
  self.SetupDoorTriggers(self)
end

function Paris_3_Mission_1:Checkpoint6()
  self.nCheckPoint = 6
  self.WalkLayout(self)
  self.TriggerEvents1(self)
  Paris_3_Mission_1.FindTheResistance(self)
end

function Paris_3_Mission_1:Checkpoint7()
  self.RegisterCheckpoint(self, "Paris_3_Mission_1.WaitForFight")
end

function Paris_3_Mission_1:WaitForFight()
  Suspicion.SetEscalationLevel(3)
  self.nCheckPoint = 7
  self.WalkLayout(self)
  self.TriggerEvents1(self)
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\room3\\PT_Rendezvous", hSab, "Paris_3_Mission_1.Rendezvous", self, {1}, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\room3\\PT_Rendezvous")
  Paris_3_Mission_1.FindTheResistance(self)
  self:CreateTask({
    sName = "Missions\\paris_3\\mission_1\\final_encounter",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\paris_3\\mission_1\\final_encounter"
    }
  })
  self:CreateTask({
    sName = "Missions\\paris_3\\mission_1\\final_encounter2",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\paris_3\\mission_1\\final_encounter2"
    }
  })
  Sound.SetMusicLocale("P3M1_Catacombs")
  Sound.SetMusicLocale("m_P3M1_Catacombs", "Chasm")
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\paris_3\\mission_1\\final_encounter2\\res1",
      "Missions\\paris_3\\mission_1\\final_encounter2\\res2",
      "Missions\\paris_3\\mission_1\\final_encounter2\\res3",
      "Missions\\paris_3\\mission_1\\final_encounter2\\res4",
      "Missions\\paris_3\\mission_1\\final_encounter2\\res5",
      "Missions\\paris_3\\mission_1\\final_encounter\\luc",
      "Missions\\paris_3\\mission_1\\final_encounter\\Veron"
    }
  }, "Paris_3_Mission_1.StartFight", self))
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\conversation\\PT_NaziFall1", hSab, "Paris_3_Mission_1.NaziPotentialFall1", self, {1}, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\conversation\\PT_NaziFall1")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\conversation\\PT_NaziFall2", hSab, "Paris_3_Mission_1.NaziPotentialFall2", self, {1}, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\conversation\\PT_NaziFall2")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\conversation\\PT_Fightexplosions", hSab, "Paris_3_Mission_1.SetupExplosionFight", self, {1}, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\conversation\\PT_Fightexplosions")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\conversation\\PT_Fightexplosions2", hSab, "Paris_3_Mission_1.SetupExplosionFight2", self, {1}, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\conversation\\PT_Fightexplosions2")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\convotrigger\\PT_Escalation", hSab, "Paris_3_Mission_1.SetChasmEscalation", self, {1}, cTRIGGEREVENT_ONENTER), "Missions\\paris_3\\mission_1\\convotrigger\\PT_Escalation")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\conversation\\PT_BridgeGuy", hSab, "Paris_3_Mission_1.SpawnBridgeGuy", self, {1}, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\conversation\\PT_BridgeGuy")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\convotrigger\\PT_BattleSounds", hSab, "Paris_3_Mission_1.SetupExplosionFight1", self, {1}, cTRIGGEREVENT_ONENTER), "Missions\\paris_3\\mission_1\\convotrigger\\PT_BattleSounds")
end

function Paris_3_Mission_1:StartFight()
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\conversation\\PT_IdiotResStart", hSab, "Paris_3_Mission_1.IdiotFire1", self, {1}, cTRIGGEREVENT_ONENTER), "Missions\\paris_3\\mission_1\\conversation\\PT_IdiotResStart")
  Squad.SetLethal("Saboteur", true)
  Squad.SetLethal("GenericNazi", true)
  Squad.SetEnemy("Saboteur", "GenericNazi", true)
  local hLuc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\luc")
  Object.SetInvincibleToAI(hLuc, true)
  if not Inventory.GetItemOfType(hLuc, "WP_MG_Sten") then
    Inventory.GiveItem(hLuc, "WP_MG_Sten", true)
  end
  Squad.AddMember("Saboteur", hLuc)
  Combat.LockIntoRanged(hLuc)
  Combat.SetStationary(hLuc, true)
  local hVeronique = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\Veron")
  Object.SetInvincibleToAI(hVeronique, true)
  if not Inventory.GetItemOfType(hVeronique, "WP_MG_Sten") then
    Inventory.GiveItem(hVeronique, "WP_MG_Sten", true)
  end
  Squad.AddMember("Saboteur", hVeronique)
  Combat.LockIntoRanged(hVeronique)
  Combat.SetStationary(hVeronique, true)
  for i = 1, 5 do
    local hHandle = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter2\\res" .. i)
    if hHandle then
      Squad.AddMember("Saboteur", hHandle)
      Combat.LockIntoRanged(hHandle)
    end
  end
end

function Paris_3_Mission_1:HearBattle()
  Cin.PlayConversation("P3M1_HearBattle")
  Suspicion.SetEscalationLevel(3)
  Combat.SetPlayerTargetPriority(0)
end

function Paris_3_Mission_1:SeeChasm()
  Cin.PlayConversation("P3M1_SeeChasm")
end

function Paris_3_Mission_1:SetChasmEscalation()
  Suspicion.SetEscalationLevel(3)
end

function P3M1_SpawnRoon_Discovered_Spawn4A(self)
  Cin.PlayConversation("P3M1_SpawnRoom_Discovered_Spawn4")
end

function Paris_3_Mission_1:NaziPotentialFall1()
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\paris_3\\mission_1\\fallingnazis\\fall1\\nazifall1",
      "Missions\\paris_3\\mission_1\\fallingnazis\\fall1\\nazifall2",
      "Missions\\paris_3\\mission_1\\fallingnazis\\fall1\\nazifall3"
    }
  }, "Paris_3_Mission_1.KillNaziAndFall1", self))
  self:CreateTask({
    sName = "Missions\\paris_3\\mission_1\\fallingnazis\\fall1",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\paris_3\\mission_1\\fallingnazis\\fall1"
    }
  })
end

function Paris_3_Mission_1:NaziPotentialFall2()
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\paris_3\\mission_1\\fallingnazis\\fall2\\nazifall2A",
      "Missions\\paris_3\\mission_1\\fallingnazis\\fall2\\nazifall2B"
    }
  }, "Paris_3_Mission_1.KillNaziAndFall2", self))
  self:CreateTask({
    sName = "Missions\\paris_3\\mission_1\\fallingnazis\\fall2",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\paris_3\\mission_1\\fallingnazis\\fall2"
    }
  })
end

function Paris_3_Mission_1:KillNaziAndFall1()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Missions\\paris_3\\mission_1\\fallingnazis\\fall1\\exp1"))
  Util.CreateExplosion("Explosion_Large", x, y, z)
  Object.SetHealth(Util.GetHandleByName("Missions\\paris_3\\mission_1\\fallingnazis\\fall1\\nazifall2"), 100)
  Actor.OverrideCombatAI(Util.GetHandleByName("Missions\\paris_3\\mission_1\\fallingnazis\\fall1\\nazifall2"), true)
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\conversation\\PT_NaziKill1", hSab, "Paris_3_Mission_1.KillNazi2guylolz1", self, {1}, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\conversation\\PT_NaziKill1")
end

function Paris_3_Mission_1:KillNaziAndFall2()
  local x, y, z = Object.GetPosition(Util.GetHandleByName("Missions\\paris_3\\mission_1\\fallingnazis\\fall2\\exp2"))
  Util.CreateExplosion("Explosion_Large", x, y, z)
  Object.SetHealth(Util.GetHandleByName("Missions\\paris_3\\mission_1\\fallingnazis\\fall2\\nazifall2A"), 100)
  Actor.OverrideCombatAI(Util.GetHandleByName("Missions\\paris_3\\mission_1\\fallingnazis\\fall2\\nazifall2A"), true)
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\conversation\\PT_NaziKill2", hSab, "Paris_3_Mission_1.KillNazi2guylolz2", self, {1}, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\conversation\\PT_NaziKill2")
end

function Paris_3_Mission_1:KillNazi2guylolz1()
  local hNazi2 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\fallingnazis\\fall1\\nazifall2")
  Object.Kill(hNazi2)
end

function Paris_3_Mission_1:KillNazi2guylolz2()
  local hNazi2 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\fallingnazis\\fall2\\nazifall2B")
  Object.Kill(hNazi2)
end

function Paris_3_Mission_1:SpawnExplosionAtLocation(sLoc)
  local x, y, z = Object.GetPosition(Util.GetHandleByName(sLoc))
  Render.StartFX(Handle(sLoc), "0FX_Explosions_Large_Effect", nil)
end

function Paris_3_Mission_1:SpawnExplosionAtLocation2(sLoc)
  local x, y, z = Object.GetPosition(Util.GetHandleByName(sLoc))
  Render.StartFX(Handle(sLoc), "0FX_A1M5_Explosion_Large", nil)
end

function Paris_3_Mission_1:PotentialConvoRoom3()
  local hDestro = Util.GetHandleByName("PARIS\\area03\\catacombs\\inteior\\room_3\\Catacomb_ FloorRoof_12M_DAM")
  Paris_3_Mission_1.DEBUGPlayConversation(self, "P3M1_ShowdownSpawner_02_SeesNazis", nil)
end

function Paris_3_Mission_1:KillOffPlayer()
  Object.Kill(hSab)
end

function Paris_3_Mission_1:SetFXBullet(nCur, nMax)
  if nCur < nMax then
    local hbulletloc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3convo\\ric" .. math.random(1, 14))
    if hbulletloc then
      Render.StartFX(hbulletloc, "0FX_Rico_Brick_SML_A", nil)
    end
    local fRandTimer = math.random(20) / 100
    local tEvent = {EventType = "TimerEvent", Time = fRandTimer}
    self:RegisterEvent(Util.CreateEvent(tEvent, "Paris_3_Mission_1.SetFXBullet", self, {
      nCur + 1,
      nMax
    }))
  end
end

function Paris_3_Mission_1:IdiotFire1()
  self:CreateTask({
    sName = "Missions\\paris_3\\mission_1\\room3convo",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\paris_3\\mission_1\\room3convo"
    }
  })
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\paris_3\\mission_1\\room3convo\\idiotresistance"
    },
    WaitForGameObject = true
  }, "Paris_3_Mission_1.IdiotFire2", self, {true}))
end

function Paris_3_Mission_1:IdiotFire2()
  local hHandle = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3convo\\idiotresistance")
  local hTarget = WRAPPER_CheckForHandle("Missions\\paris_3\\mission_1\\room3convo\\DummyTarget")
  Object.SetHealth(hHandle, 500000)
  Combat.SetReactImmediately(hHandle, true)
  Combat.SetAimAndHitNoMiss(hHandle, true)
  Combat.SetRespondToEvents(hHandle, false)
  Combat.SetAlwaysSeeTarget(hHandle, true)
  Combat.SetStationary(hHandle, true)
  Combat.LockIntoRanged(hHandle)
  Combat.SetTarget(hHandle, hTarget)
  Combat.SetLethalForce(hHandle, true)
  Combat.SetCombat(hHandle)
  EVENT_Timer("Paris_3_Mission_1.IdiotFire3", self, 1.5)
  self.SetFXBullet(self, 1, 15)
  self.SetFXBullet(self, 1, 20)
end

function Paris_3_Mission_1:IdiotFire3()
  Paris_3_Mission_1.DEBUGPlayConversation(self, "P3M1_Showdown_NearMiss")
  local hHandle = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3convo\\idiotresistance")
  Combat.ClearStateLock(hHandle)
  Combat.RemoveTargetFlag(hHandle, cTARGET_ALLENEMIES)
  Combat.ClearTargetFlags(hHandle)
  Combat.Exit(hHandle)
  Combat.SetStationary(hHandle, false)
end

function Paris_3_Mission_1:Checkpoint8()
  self.nCheckPoint = 8
  self.RegisterCheckpoint(self, "Paris_3_Mission_1.WaitForLucToDie")
end

function Paris_3_Mission_1:ArmLuc()
  local hLuc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\luc")
  if not Inventory.GetItemOfType(hLuc, "WP_MG_Sten") then
    Inventory.GiveItem(hLuc, "WP_MG_Sten", true)
  end
end

function Paris_3_Mission_1:ArmVeron()
  local hVeronique = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\Veron")
  if not Inventory.GetItemOfType(hVeronique, "WP_PS_Luger") then
    Inventory.GiveItem(hVeronique, "WP_PS_Luger", true)
  end
end

function Paris_3_Mission_1:DisarmLuc()
  local hLuc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\luc")
  Inventory.RemoveAllWeapons(hLuc)
end

function Paris_3_Mission_1:DisarmVeron()
  local hVeronique = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\Veron")
  Inventory.RemoveAllWeapons(hVeronique)
end

function Paris_3_Mission_1:DisarmSantos()
  local hSant = Handle("Missions\\paris_3\\mission_1\\Santos\\Santos")
  Inventory.RemoveAllWeapons(hSant)
  Actor.OverrideCombatAI(hSant, true)
end

function Paris_3_Mission_1:LoadFinalNazis_StreamedIn()
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\paris_3\\mission_1\\final_nazis\\nazi1",
      "Missions\\paris_3\\mission_1\\final_nazis\\nazi2",
      "Missions\\paris_3\\mission_1\\final_nazis\\nazi3",
      "Missions\\paris_3\\mission_1\\final_nazis\\nazi4",
      "Missions\\paris_3\\mission_1\\final_nazis\\nazi5"
    },
    WaitForGameObject = true
  }, "Paris_3_Mission_1.FendOffNZ", self, {true}))
end

function Paris_3_Mission_1:WaitForLucToDie()
  Cin.LoadCinematic("402_CinB_LucDown")
  Paris_3_Mission_1.ArmLuc(self)
  Paris_3_Mission_1.ArmVeron(self)
  self:CreateTask({
    sName = "Missions\\paris_3\\mission_1\\wallexplosioncin",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\paris_3\\mission_1\\wallexplosioncin"
    }
  })
  Paris_3_Mission_1.LoadFinalNazis(self)
  Paris_3_Mission_1.LoadFinalNazis_StreamedIn(self)
  self.PauseBeforeSituation2(self)
  Combat.ClearStateLock(hLuc)
  Combat.SetStationary(hLuc, false)
  Combat.SetObjective(hLuc, hLucGoHere, true, -1, true)
  Trigger.WaitFor("Missions\\paris_3\\mission_1\\dynamic\\PT_KillLuc", hLuc, "Paris_3_Mission_1.LucAtWall", self, {hLuc}, cTRIGGEREVENT_ONENTER, false)
  self:UnloadTaskNodes("SantosCinematic", true)
  local hNaziLabel = Filter.New("Nazi")
  local tEvent = {EventType = "TimerEvent", Time = 100}
  self.LucWallExplodeTimer = Util.CreateEvent(tEvent, "Paris_3_Mission_1.LucDownCin", self)
  self:RegisterEvent(self.LucWallExplodeTimer)
  local hFightLoc = Handle("Missions\\paris_3\\mission_1\\final_encounter\\FendNZ")
  HUD.SetObjectiveMarker(hFightLoc, cMMI_Destroy, cOM_Destroy, true, false)
end

function Paris_3_Mission_1:CinematicLucExp()
  EVENT_Timer("Paris_3_Mission_1.SantosCin", self, 2)
  local hHandle = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3convo\\idiotresistance")
  Object.SetHealth(hHandle, 50)
  for i = 1, 4 do
    local hHandle = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter2\\res" .. i)
    if hHandle then
      Object.SetHealth(hHandle, 50)
    end
  end
end

function Paris_3_Mission_1:SantosCin()
  EVENT_Timer("Paris_3_Mission_1.PurgeSpawners", self, 2)
  local hSant = Handle("Missions\\paris_3\\mission_1\\Santos\\Santos")
  Object.SetInvincible(hSant, true)
  Actor.OverrideCombatAI(hSant, true)
  EVENT_Timer("Paris_3_Mission_1.DisarmLuc", self, 2)
  EVENT_Timer("Paris_3_Mission_1.DisarmVeron", self, 2)
  self:CreateTask({
    sName = "SantosCinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Cinematic",
    sCinFile = "401_CinB_Catac",
    tSMEDNodes = {
      "Missions\\paris_3\\mission_1\\Santos"
    },
    tOnComplete = {
      {
        self.Checkpoint8,
        {self}
      }
    },
    tCinematicNodes = {
      "Missions\\cinematics\\401_cinb_catac"
    }
  })
end

function Paris_3_Mission_1.Cin401_Unload_AI_ResNazi()
  Paris_3_Mission_1:UnloadTaskNodes("Missions\\paris_3\\mission_1\\final_encounter2", true)
end

function Paris_3_Mission_1.Cin401_Load_AI_ResNazi()
  Paris_3_Mission_1.bNodeLoadedForFinalNazi = true
  Util.SpawnEditNode("Missions\\paris_3\\mission_1\\final_nazis.wsd")
  Util.SpawnEditNode("Missions\\paris_3\\mission_1\\final_encounter2.wsd")
end

function Paris_3_Mission_1:PurgeSpawners()
  local hSpawner1 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\2_mainledge\\CoDs_mainledge1")
  local hSpawner2 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\1_window\\CoDs_window")
  local hSpawner3 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\3_fendoff\\CoDs_fendoff1")
  Object.SpawnerPurge(hSpawner1, true)
  Object.SpawnerPurge(hSpawner2, true)
  Object.SpawnerPurge(hSpawner3, true)
  local hNazi1 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\2_mainledge\\MainLedge_TS_1")
  local hNazi2 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\2_mainledge\\MainLedge_TS_2")
  Object.Kill(hNazi1)
  Object.Kill(hNazi2)
end

function Paris_3_Mission_1:Final_Nazis_Streamedin()
  local hNazi
  for i = 1, 5 do
    hNazi = Handle("Missions\\paris_3\\mission_1\\final_nazis\\nazi" .. i)
    if hNazi and Object.IsAlive(hNazi) then
      Object.SetInvincibleToAI(hNazi, true)
      local tEvent = {
        EventType = "TimerEvent",
        Time = 20 * i
      }
      self:RegisterEvent(Util.CreateEvent(tEvent, "Paris_3_Mission_1.Turn_On_Damage", self, {
        "Missions\\paris_3\\mission_1\\final_nazis\\nazi" .. i
      }))
    end
  end
end

function Paris_3_Mission_1:Turn_On_Damage(tUserData)
  local hNazi = Handle(tUserData)
  if hNazi and Object.IsAlive(hNazi) then
    Object.SetInvincibleToAI(hNazi, false)
  end
end

function Paris_3_Mission_1:ResetPlayerPriority()
  Combat.ResetPlayerTargetPriority()
end

function Paris_3_Mission_1:PlayerPriorityHigh()
  Combat.SetPlayerTargetPriority(0)
end

function Paris_3_Mission_1:PlayerPriorityLow()
  Combat.SetPlayerTargetPriority(5)
end

function Paris_3_Mission_1:FendOffNZ()
  self.Cin401Played = false
  Paris_3_Mission_1.ResetPlayerPriority(self)
  EVENT_Timer("Paris_3_Mission_1.PlayerPriorityLow", self, 5)
  EVENT_Timer("Paris_3_Mission_1.PlayerPriorityHigh", self, 10)
  EVENT_Timer("Paris_3_Mission_1.PlayerPriorityLow", self, 15)
  EVENT_Timer("Paris_3_Mission_1.PlayerPriorityHigh", self, 20)
  EVENT_Timer("Paris_3_Mission_1.PlayerPriorityLow", self, 25)
  EVENT_Timer("Paris_3_Mission_1.PlayerPriorityHigh", self, 30)
  EVENT_Timer("Paris_3_Mission_1.PlayerPriorityLow", self, 35)
  EVENT_Timer("Paris_3_Mission_1.PlayerPriorityHigh", self, 40)
  EVENT_Timer("Paris_3_Mission_1.ResetPlayerPriority", self, 45)
  local hRes1 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter2\\res5")
  local hNaz1 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_nazis\\nazi1")
  Combat.SetTarget(hRes1, hNaz1)
  Combat.SetTarget(hNaz1, hRes1)
  local hRes2 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter2\\res1")
  local hNaz2 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_nazis\\nazi5")
  Combat.SetTarget(hRes2, hNaz2)
  Combat.SetTarget(hNaz2, hRes2)
  local hRes3 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter2\\res4")
  local hNaz3 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_nazis\\nazi3")
  Combat.SetTarget(hRes3, hNaz3)
  Combat.SetTarget(hNaz3, hRes3)
  local hRes4 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\luc")
  Combat.SetTarget(hRes4, hNaz2)
  local hHandle = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3convo\\idiotresistance")
  Object.SetHealth(hHandle, 25)
  for i = 1, 4 do
    local hHandle = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter2\\res" .. i)
    if hHandle then
      Object.SetHealth(hHandle, 25)
    end
  end
  self:CreateTask({
    sName = "KillFendOffNazis",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P3M1_Text.FendOffNazis",
    tTgtInclude = {
      "Missions\\paris_3\\mission_1\\final_nazis\\nazi1",
      "Missions\\paris_3\\mission_1\\final_nazis\\nazi2",
      "Missions\\paris_3\\mission_1\\final_nazis\\nazi3",
      "Missions\\paris_3\\mission_1\\final_nazis\\nazi4",
      "Missions\\paris_3\\mission_1\\final_nazis\\nazi5"
    },
    tOnComplete = {
      {
        self.LucDownCin,
        {self}
      }
    }
  })
  self.TriggerEvents1(self)
  local hLuc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\luc")
  local hVeronique = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\Veron")
  Object.SetInvincibleToAI(hVeronique, false)
  Object.SetInvincibleToAI(hLuc, true)
  EVENT_Timer("Paris_3_Mission_1.LucVulnerable", self, 5)
  self.hVeronDeathEvent = EVENT_ActorDeath("Paris_3_Mission_1.VeroniqueDeath", self, "Missions\\paris_3\\mission_1\\final_encounter\\Veron")
  self.hLucDeathEvent = EVENT_ActorDeath("Paris_3_Mission_1.LucEarlyDeath", self, "Missions\\paris_3\\mission_1\\final_encounter\\luc")
  local hLucGoHere = Handle("PARIS\\area03\\catacombs\\inteior\\room_3\\Locator(1)")
  local tHandles = {
    Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\WallBlast_TS_1")
  }
  self:CreateTask({
    sName = "killChasmNazis",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    sObjectiveTextID = "P3M1_Text.FendOffNazis",
    TaskCount = 4,
    tTgtInclude = tHandles,
    tOnComplete = {}
  })
end

function Paris_3_Mission_1:CheckForClearedLedge()
  local tLedgeNZ = {}
  local tLedgeNZ = Trigger.GetAllWithin(Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\PT_LedgeNZ"))
  if tLedgeNZ then
    self.NZRemaining = 0
    for i, v in ipairs(tLedgeNZ) do
      if Object.IsAlive(v) then
        self.NZRemaining = self.NZRemaining + 1
      end
    end
    if self.NZRemaining == 0 then
      Paris_3_Mission_1.LucDownCin(self)
    else
      self.hCheckTimerEvent = EVENT_Timer("Paris_3_Mission_1.CheckForClearedLedge", self, 2)
    end
  else
    Render.PrintMessage("no tLedge NZ table?")
    Paris_3_Mission_1.LucDownCin(self)
  end
end

function Paris_3_Mission_1:LucAtWall(hBlah, a_hLuc)
  Actor.OverrideCombatAI(a_hLuc, true)
  Combat.SetStationary(a_hLuc, true)
end

function Paris_3_Mission_1:PauseBeforeSituation2()
  self.NazisRetreat(self)
  EVENT_Timer("Paris_3_Mission_1.Situation2", self, 4)
end

function Paris_3_Mission_1:IdiotSpeaks()
end

function Paris_3_Mission_1:IdiotSpeaks2()
end

function Paris_3_Mission_1:NazisRetreat()
  local tLocator = {
    "Missions\\paris_3\\mission_1\\dynamic\\LOC_NaziRetreat1",
    "Missions\\paris_3\\mission_1\\dynamic\\LOC_NaziRetreat2",
    "Missions\\paris_3\\mission_1\\dynamic\\LOC_NaziRetreat3",
    "Missions\\paris_3\\mission_1\\dynamic\\LOC_NaziRetreat4",
    "Missions\\paris_3\\mission_1\\dynamic\\LOC_NaziRetreat5"
  }
  local hNaziLabel = Filter.New("Nazi")
  local tWho = Trigger.GetAllWithin(Util.GetHandleByName("Missions\\paris_3\\mission_1\\conversation\\PT_NewConvoRoom3"), hNaziLabel)
  if tWho then
    for i, v in ipairs(tWho) do
      local hLoc = Handle(tLocator[math.random(1, #tLocator)])
      if hLoc and v then
        Nav.MoveToObject(v, hLoc, 5, true)
      end
    end
  end
  Filter.Delete(hNaziLabel)
  local hSpawnerSelf = Actor.GetSelf(Handle("Missions\\paris_3\\mission_1\\room3\\triggerspawner\\HumanSpawner"))
  if hSpawnerSelf then
    HumanSpawner.ActivateALL(hSpawnerSelf)
  end
end

function Paris_3_Mission_1:Situation2()
  local tempSpeakers = self.ReturnSpeakers(self, "Missions\\paris_3\\mission_1\\conversation\\PT_Showdown_resistance", "Resistance", 1)
  Cin.PlayConversationWith("P3M1_Showdown_NaziCrossing", tempSpeakers)
end

function Paris_3_Mission_1:LucDownCin()
  if self.Cin401Played == false then
    self.Cin401Played = true
    Paris_3_Mission_1.LucInvincible(self)
    if self.hCheckTimerEvent then
      Util.KillEvent(self.hCheckTimerEvent)
    end
    local hLuc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\luc")
    Actor.PlayAnimation(hLuc, "nazi_HR_standMG_1")
    if self.LucWallExplodeTimer then
      Util.KillEvent(self.LucWallExplodeTimer)
    end
    local hFightLoc = Handle("Missions\\paris_3\\mission_1\\final_encounter\\FendNZ")
    HUD.RemoveObjectiveMarker(hFightLoc)
    self:CreateTask({
      sName = "402isDoneforcinematic",
      sTaskType = "SabTaskObjectiveInteract",
      sTaskSubType = "Cinematic",
      sCinFile = "402_CinB_LucDown",
      tOnComplete = {
        {
          self.Checkpoint9,
          {self}
        }
      },
      tCinematicNodes = {
        "Missions\\cinematics\\402_cinb_lucdown"
      }
    })
  end
end

function Paris_3_Mission_1:Checkpoint9()
  Paris_3_Mission_1.PlayerPriorityHigh(self)
  self:CompleteTaskByName("killChasmNazis")
  self.RegisterCheckpoint(self, "Paris_3_Mission_1.BlowWallUpKillLuc")
end

function Paris_3_Mission_1:ForceMoveTS4()
  local hTS4 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_4")
  local hPA4 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\3_fendoff\\PA_TS4")
  Combat.SetObjectivePath(hTS4, hPA4, true, 0)
end

function Paris_3_Mission_1:ForceMoveTS3()
  local hTS3 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_3")
  local hPA3 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\3_fendoff\\PA_TS3")
  Combat.SetObjectivePath(hTS3, hPA3, true, 0)
end

function Paris_3_Mission_1:KillTerrorSquad()
  Combat.SetPlayerTargetPriority(0)
  self:CreateTask({
    sName = "killWallNazis",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P3M1_Text.FendOffNazis",
    tTgtInclude = {
      "Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_1",
      "Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_2",
      "Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_3",
      "Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_4",
      "Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_5"
    },
    tSMEDNodes = {
      "Missions\\paris_3\\mission_1\\room3\\7_wallblast"
    },
    tOnComplete = {
      {
        self.SetupCheckpointLucHelp,
        {self}
      }
    }
  })
end

function Paris_3_Mission_1:SwapTerrorSquads()
  Paris_3_Mission_1:UnloadTaskNodes("Missions\\paris_3\\mission_1\\wallexplosioncin", true)
  Util.SpawnEditNode("Missions\\paris_3\\mission_1\\room3\\7_wallblast.wsd")
  Paris_3_Mission_1.bLoadInWallBlastGuys = true
end

function Paris_3_Mission_1:KillOffWallBlastNazi()
  self:CreateTask({
    sName = "killWallNazis",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P3M1_Text.RepelTerrorSquad",
    tTgtInclude = {
      "Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_1",
      "Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_2",
      "Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_3",
      "Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_4",
      "Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_5"
    },
    tOnComplete = {
      {
        self.SetupCheckpointLucHelp,
        {self}
      }
    }
  })
end

function Paris_3_Mission_1:BlowWallUpKillLuc()
  self.nCheckPoint = 9
  Cin.LoadCinematic("403_CinB_LucKill-LucDying")
  Paris_3_Mission_1.PlayerPriorityHigh(self)
  Paris_3_Mission_1.ForceMoveTS4(self)
  Paris_3_Mission_1.ForceMoveTS3(self)
  self.TriggerEvents1(self)
  Util.UnloadStaticENTag("Wall_Blast_Pri", true)
  Util.UnloadStaticENTag("P3M1_CinProps1", true)
  Util.LoadStaticENTag("Wall_Blast_Dam", true)
  self.LucInvincible(self)
  EVENT_Timer("Paris_3_Mission_1.LucVulnerable", self, 7)
  local hLucPanic1 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\luc")
  local hLucPanic2 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\luc2")
  Actor.SetPanicEnabled(hLucPanic1, false)
  Actor.SetPanicEnabled(hLucPanic2, false)
  Paris_3_Mission_1.LucTrappedAnimation(self)
  Paris_3_Mission_1.ArmVeron(self)
  local tHandles = {}
  if (Handle("Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_1") == nil and Handle("Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_2") == nil and Handle("Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_3") == nil and Handle("Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_4") == nil and Handle("Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_5")) == nil then
    Util.SpawnEditNode("Missions\\paris_3\\mission_1\\room3\\7_wallblast.wsd")
    Paris_3_Mission_1.bLoadInWallBlastGuys = true
  end
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_1",
      "Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_2",
      "Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_3",
      "Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_4",
      "Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_5"
    },
    WaitForGameObject = true
  }, "Paris_3_Mission_1.KillOffWallBlastNazi", self))
  hEndDoor = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\blast_wall_proxy")
  Object.ForceOpen(hEndDoor)
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\room3\\4_bridge\\PT_load_5_defensive", hSab, "Paris_3_Mission_1.Load5defensive", self, {1}, cTRIGGEREVENT_ONENTER, false), "Missions\\paris_3\\mission_1\\room3\\4_bridge\\PT_load_5_defensive")
end

function Paris_3_Mission_1:Load7_Wallblast()
  self:CreateTask({
    sName = "Missions\\paris_3\\mission_1\\room3\\7_wallblast",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\paris_3\\mission_1\\room3\\7_wallblast"
    }
  })
  Combat.ResetPlayerTargetPriority()
  local hRes1 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3convo\\idiotresistance")
  local hNaz1 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_4")
  Combat.SetTarget(hRes1, hNaz1)
  Combat.SetTarget(hNaz1, hRes1)
  local hRes2 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter2\\res2")
  local hNaz2 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_2")
  Combat.SetTarget(hRes2, hNaz2)
  Combat.SetTarget(hNaz2, hRes2)
  local hRes3 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter2\\res3")
  local hNaz3 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\7_wallblast\\WallBlast_TS_3")
  Combat.SetTarget(hRes3, hNaz3)
  Combat.SetTarget(hNaz3, hRes3)
  local hRes4 = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter2\\res1")
  Combat.SetTarget(hRes4, hNaz1)
  Combat.SetTarget(hNaz1, hRes4)
end

function Paris_3_Mission_1:Load5defensive()
  table.insert(self.ColbyTable, "catacomb_5_defensive")
  Util.LoadStaticENTag("catacomb_5_defensive", true)
end

function Paris_3_Mission_1:Load6destruction()
  self:CreateTask({
    sName = "Missions\\paris_3\\mission_1\\room3\\6_destruction",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\paris_3\\mission_1\\room3\\6_destruction"
    }
  })
end

function Paris_3_Mission_1:UnloadWall()
  Util.UnloadStaticENTag("Wall_Blast_Pri", true)
  Util.UnloadStaticENTag("P3M1_CinProps1", true)
  Util.LoadStaticENTag("Wall_Blast_Dam", true)
end

function Paris_3_Mission_1:LucWallPose()
  local hLuc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\luc")
  local hAPloop = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\4_bridge\\APt_LookAround")
  Actor.UseAttrPt(hLuc, hAPloop)
  Actor.SetUseHitReactions(hLuc, false)
  Actor.OverrideCombatAI(hLuc, true)
end

function Paris_3_Mission_1:ExplosionSpawn()
  local hLuc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\luc")
  Render.PrintMessage("Function ExplosionSpawn is triggered")
  HUD.RemoveObjectiveMarker("Missions\\paris_3\\mission_1\\final_encounter\\FendNZ")
  local hFightLoc = Handle("Missions\\paris_3\\mission_1\\dynamic\\LOC_OBJ_WallNazis")
  HUD.SetObjectiveMarker(hFightLoc, cMMI_Destroy, cOM_Destroy, true, false)
  local loc1, loc2, loc3, loc4, loc5
  loc1 = Handle("Missions\\paris_3\\mission_1\\particlefx\\LC_LucWallSmoke1")
  loc2 = Handle("Missions\\paris_3\\mission_1\\particlefx\\LC_LucWallSmoke2")
  loc3 = Handle("Missions\\paris_3\\mission_1\\particlefx\\LC_LucWallSmoke3")
  loc4 = Handle("Missions\\paris_3\\mission_1\\particlefx\\LC_LucWallSmoke4")
  loc5 = Handle("Missions\\paris_3\\mission_1\\particlefx\\LC_LucWallSmoke5")
  Sound.PlayOwnerlessSoundEvent("Emt_P1M3_CeilingCollapse")
end

function Paris_3_Mission_1:DelaySmoke()
  local loc1, loc2, loc3, loc4, loc5
  loc1 = Handle("Missions\\paris_3\\mission_1\\particlefx\\LC_LucWallSmoke1")
  loc2 = Handle("Missions\\paris_3\\mission_1\\particlefx\\LC_LucWallSmoke2")
  loc3 = Handle("Missions\\paris_3\\mission_1\\particlefx\\LC_LucWallSmoke3")
  loc4 = Handle("Missions\\paris_3\\mission_1\\particlefx\\LC_LucWallSmoke4")
  loc5 = Handle("Missions\\paris_3\\mission_1\\particlefx\\LC_LucWallSmoke5")
  Render.StartFX(loc3, "0FX_Dust09_Blast_Large", nil)
  Render.StartFX(loc4, "0FX_Dust09_Blast_Large", nil)
end

function Paris_3_Mission_1:LucTrappedAnimation()
  local hLuc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\luc")
  local hAPloop = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\4_bridge\\ATTRPT_P3M1_LucTrapped")
  Actor.UseAttrPt(hLuc, hAPloop)
  Actor.SetUseHitReactions(hLuc, false)
  Actor.OverrideCombatAI(hLuc, true)
  Object.SetHealth(hLuc, 50)
  Actor.SetNonKnockdownable(hLuc, true)
  Paris_3_Mission_1.DisarmLuc(self)
end

function Paris_3_Mission_1:ShootLucDead()
  local hLuc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\luc")
  local hAPloop = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\4_bridge\\ATTRPT_P3M1_LucDead")
  Actor.UseAttrPt(hLuc, hAPloop)
  Actor.OverrideCombatAI(hLuc, true)
  Actor.SetUseHitReactions(hLuc, false)
  Object.SetInvincibleToAI(hLuc, true)
end

function Paris_3_Mission_1:LucShot()
  local hLuc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\luc")
  Util.KillEvent(self.hLucDeathEvent)
  Object.Kill(hLuc)
end

function Paris_3_Mission_1:UbermanInvincible()
  local hLuc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\2_mainledge\\Uberman")
  if hLuc ~= nil then
    Object.SetInvincibleToAI(hLuc, true)
  end
end

function Paris_3_Mission_1:UbermanVulnerable()
  local hLuc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\room3\\2_mainledge\\Uberman")
  Object.SetInvincibleToAI(hLuc, false)
end

function Paris_3_Mission_1:LucInvincible()
  local hLuc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\luc")
  Object.SetInvincibleToAI(hLuc, true)
  hLuc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\luc2")
  Object.SetInvincibleToAI(hLuc, true)
end

function Paris_3_Mission_1:LucVulnerable()
  local hLuc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\luc")
  Object.SetInvincibleToAI(hLuc, false)
end

function Paris_3_Mission_1:DestroyDestructionRig()
  Paris_3_Mission_1.DEBUGPlayConversation(self, "P3M1_ShowdownSpawner_01_Discovered")
end

function Paris_3_Mission_1:TeleportLucUnderRocks()
  local hLuc = Util.GetHandleByName("Missions\\paris_3\\mission_1\\final_encounter\\luc")
  Object.Teleport(hLuc, 2914.4, 374.824, 1758.7, 0)
  Cin.PlayConversation("P3M1_Showdown_PostBreakthrough")
end

function Paris_3_Mission_1:DestroyBridge()
  Combat.ResetPlayerTargetPriority()
  if Handle("PARIS\\area03\\catacombs\\inteior\\room_3\\Catacomb_Planks(1)") ~= nil and Object.GetHealth(Handle("PARIS\\area03\\catacombs\\inteior\\room_3\\Catacomb_Planks(1)")) ~= nil and Util.IsHandleValid(Handle("PARIS\\area03\\catacombs\\inteior\\room_3\\Catacomb_Planks(1)")) == true then
    self:CreateTask({
      sName = "DestroyBridgeTask",
      sTaskType = "SabTaskObjectiveDestroy",
      sTaskSubType = "KILL",
      sObjectiveTextID = "P3M1_Text.DestroyBridge",
      MarkerHeight = 0.5,
      tTgtInclude = {
        "PARIS\\area03\\catacombs\\inteior\\room_3\\Catacomb_Planks(1)"
      },
      tOnComplete = {
        {
          self.SetupCheckpointLucHelp,
          {self}
        }
      }
    })
  else
    self.SetupCheckpointLucHelp(self)
  end
end

function Paris_3_Mission_1:SetupCheckpointLucHelp()
  Paris_3_Mission_1.LucTrappedAnimation(self)
  EVENT_Timer("Paris_3_Mission_1.FinalTakingTooLong", self, 45)
  self:CreateTask({
    sName = "TempFinalTask",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P3M1_Text.HelpLuc",
    tLocators = {
      "Missions\\paris_3\\mission_1\\dynamic\\LC_KillLuc"
    },
    tDestRegion = "Missions\\paris_3\\mission_1\\dynamic\\PT_KillLuc",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        Paris_3_Mission_1.LucDying,
        {self}
      }
    }
  })
end

function Paris_3_Mission_1:FinalTakingTooLong()
  local playerlabel = Filter.New("Player")
  local tWho = Trigger.GetAllWithin(Util.GetHandleByName("Missions\\paris_3\\mission_1\\conversation\\PT_P3M1_EndingHurry"), playerlabel)
  if tWho then
    for i, v in ipairs(tWho) do
      if v == hSab then
        Paris_3_Mission_1.DEBUGPlayConversation(self, "P3M1_EndingHurry")
      end
    end
  end
  Filter.Delete(playerlabel)
end

function Paris_3_Mission_1:ConvoWarnOthers()
  Cin.PlayConversation("P3M1_OMW")
end

function Paris_3_Mission_1:ConvoEntranceBlocked()
  Cin.PlayConversation("P3M1_CatacombsEnterance_Blocked")
end

function Paris_3_Mission_1:EndingReturnVO()
  Cin.PlayConversation("P3M1_EndingReturn")
end

function Paris_3_Mission_1:RemoveCatEscalation()
  if not Suspicion.IsSomeoneHostile() then
    Suspicion.ResetEscalation()
  else
    EVENT_Timer("Paris_3_Mission_1.RemoveCatEscalation", self, 4)
  end
end

function Paris_3_Mission_1:LucDying()
  self:CreateTask({
    sName = "lucdeadcinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "403_CinB_LucKill-LucDying",
    bOverrideFade = true,
    tOnComplete = {
      {
        self.GetOutOfCatacombs,
        {self}
      }
    },
    tCinematicNodes = {
      "Missions\\cinematics\\403_cinb_luckill"
    }
  })
  Paris_3_Mission_1.DisarmVeron(self)
  Paris_3_Mission_1.DisarmLuc(self)
end

function Paris_3_Mission_1:GetOutOfCatacombs()
  Paris_3_Mission_1.ShootLucDead(self)
  self.tSaveInfo.collapseA = false
  self.tSaveInfo.collapseB = false
  self.tSaveInfo.collapseC = false
  self.tSaveInfo.DestroRig1A = false
  self.tSaveInfo.DestroRig2A = false
  self.tSaveInfo.DestroRig3A = false
  Zone.SwitchState("Missions\\paris_3\\mission_1\\WTF_Changes\\ResistanceZones", cZONESTATE_LOWWTF, cENT_IMMEDIATE)
  Paris_3_Mission_1.MissionComplete(self)
end

function Paris_3_Mission_1:SetupDoorTriggers()
  print("SetUpDoorTriggers!")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\hall1\\PT_closedoor_destroom1", hSab, "Paris_3_Mission_1.CloseDoorForced", self, {
    {
      "PARIS\\area03\\catacombs\\inteior\\hall_1\\destroom1\\Doorblock1(1)"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\paris_3\\mission_1\\hall1\\PT_closedoor_destroom1")
  print("SetUpDoorTriggers!")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_3\\mission_1\\hall2\\PT_closedoor_destroom2", hSab, "Paris_3_Mission_1.CloseDoorForced", self, {
    {
      "Missions\\paris_3\\mission_1\\hall2\\Doorblock1(1)"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\paris_3\\mission_1\\hall2\\PT_closedoor_destroom2")
end

function Paris_3_Mission_1:OpenDoorForced(hwho, hUserData)
  local a, b
  for a, b in ipairs(hUserData) do
    local hDoor = Util.GetHandleByName(b)
    if hDoor then
      Object.ForceOpen(hDoor)
    end
  end
end

function Paris_3_Mission_1:CloseDoorForced(hwho, hUserData)
  local a, b
  for a, b in ipairs(hUserData) do
    local hDoor = Util.GetHandleByName(b)
    if hDoor then
      Object.ForceClose(hDoor, true)
    end
  end
end

function Paris_3_Mission_1:RSPlantBomb()
  local hBombLoc = Handle("Missions\\paris_3\\mission_1\\final_encounter\\RSplant")
  local hPlanter = Handle("Missions\\paris_3\\mission_1\\final_encounter\\EndPlanter")
  Actor.UseAttrPt(hPlanter, hBombLoc, "Paris_3_Mission_1.DefuseEnd", self)
  Cin.PlayConversation("P3M1_HQ_GoTo")
end

function Paris_3_Mission_1:DefuseEnd()
  local tAliveRS = {
    "Missions\\paris_3\\mission_1\\final_encounter\\EndPlanter",
    "Missions\\paris_3\\mission_1\\final_encounter2\\res1",
    "Missions\\paris_3\\mission_1\\final_encounter2\\res2",
    "Missions\\paris_3\\mission_1\\final_encounter2\\res3",
    "Missions\\paris_3\\mission_1\\final_encounter2\\res4",
    "Missions\\paris_3\\mission_1\\final_encounter2\\res5",
    "Missions\\paris_3\\mission_1\\room3convo\\idiotresistance",
    "Missions\\paris_3\\mission_1\\bridgeexp\\Spore_RS_Fighter_MG"
  }
  local hExit = Handle("Missions\\paris_3\\mission_1\\final_encounter\\Loc_CatacExit")
  for i, sDude in ipairs(tAliveRS) do
    local hPerson = Handle(sDude)
    if hPerson then
      Combat.SetObjective(hPerson, hExit, true, 1, false)
    end
  end
end

function Paris_3_Mission_1:VeroniqueDeath()
  Cin.PlayConversation("P6M1_VeroniqueDead", "Paris_3_Mission_1.NowFailz", self)
end

function Paris_3_Mission_1:NowFailz()
  self:MissionTaskFail("Char_Death.RS_Veronique")
end

function Paris_3_Mission_1:LucEarlyDeath()
  Cin.PlayConversation("P3M1_Luc_Dead", "Paris_3_Mission_1.NowFailzLuc", self)
end

function Paris_3_Mission_1:NowFailzLuc()
  self:MissionTaskFail("Char_Death.RS_Luc")
end

function Paris_3_Mission_1:MissionComplete()
  Util.FreezeMiniZep(false)
  Sound.ResetMusicLocale()
  Suspicion.ResetEscalation()
  HUD.SetMinimapZoom(false)
  local tEvent = {EventType = "TimerEvent", Time = 0.7}
  Util.CreateEvent(tEvent, "Paris_3_Mission_1.MissionCompletePart2", self)
  Util.UnloadStaticENTag("P3M1_SewerCover", true)
  table.insert(self.ColbyTable, "CatacombHQCover")
  Util.LoadStaticENTag("CatacombHQCover", true)
  self.UnloadAllNaziEditNodes(self)
  Cin.StopCinematic("401_CinB_Catac")
end

function Paris_3_Mission_1:TeleportPlayerToHQ()
  self:CreateTask({
    sName = "GetToHQCats",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "EnterInterior",
    sInteriorName = "Catacombs",
    tLocators = {},
    tOnComplete = {
      {
        self.MissionCompletePart3,
        {self}
      }
    }
  })
end

function Paris_3_Mission_1:MissionCompletePart2()
  Util.EnableBirds(true)
  Object.PlayerTeleportToLocator(Handle("Missions\\paris_3\\mission_1\\gettofirsthq\\LOC_Cat_Ext"), true, "Paris_3_Mission_1.MissionCompletePart4", self, nil, true)
end

function Paris_3_Mission_1:MissionCompletePart3()
  local tEvent = {EventType = "TimerEvent", Time = 3}
  Util.CreateEvent(tEvent, "Paris_3_Mission_1.HQExplosion", self)
  local tEvent = {EventType = "TimerEvent", Time = 5}
  Util.CreateEvent(tEvent, "Paris_3_Mission_1.MissionCompletePart4", self)
end

function Paris_3_Mission_1:HQExplosion()
  local sLoc = "Missions\\paris_3\\mission_1\\final_encounter\\SealOff"
  local x, y, z = Object.GetPosition(Util.GetHandleByName(sLoc))
  Util.CreateExplosion("Explosion_SAB_DynamiteFuse", x, y, z)
end

function Paris_3_Mission_1:MissionCompletePart4()
  Render.WTFClearOverrideBlueprint()
  Suspicion.EnableEscalationVehicles(true)
  Render.FadeScreen(true)
  Sound.ReleaseSoundBank("m_P3M1_inGame.bnk")
  Render.WTFClearOverrideBlueprint()
  Util.LoadStaticENTag("P3M1_key_freeplay", true)
  HUD.SetMinimapZoom(false)
  Paris_3_Mission_1:CompleteThisMission()
end

function Paris_3_Mission_1:NaziGoOnPathD0(hwho, hNazi, sPath)
  EVENT_Timer("Paris_3_Mission_1.NaziGoOnPath", self, 1.2, {
    self,
    hwho,
    hNazi,
    sPath
  })
end

function Paris_3_Mission_1:NaziGoOnPathD1(hwho, hNazi, sPath)
  EVENT_Timer("Paris_3_Mission_1.NaziGoOnPath", self, 2.4, {
    self,
    hwho,
    hNazi,
    sPath
  })
end

function Paris_3_Mission_1:NaziGoOnPathD2(hwho, hNazi, sPath)
  EVENT_Timer("Paris_3_Mission_1.NaziGoOnPath", self, 3, {
    self,
    hwho,
    hNazi,
    sPath
  })
end

function Paris_3_Mission_1:NaziGoOnPath(hwho, hNazi, sPath)
  for i = 1, #hNazi do
    if Util.GetHandleByName(hNazi[i]) ~= nil then
      Nav.SetScriptedPath(Util.GetHandleByName(hNazi[i]), sPath[i], false, "Paris_3_Mission_1.NaziGoOnPath", self, {
        Util.GetHandleByName(hNazi[i]),
        sPath[i]
      })
    end
  end
end

function Paris_3_Mission_1:NaziGoOnPath2(hwho, hNazi, sPath)
  for i = 1, #hNazi do
    if Util.GetHandleByName(hNazi[i]) ~= nil then
      Nav.SetScriptedPath(Util.GetHandleByName(hNazi[i]), sPath[i], false, "Paris_3_Mission_1.NaziGoOnPath2", self, {
        Util.GetHandleByName(hNazi[i]),
        sPath[i]
      })
    end
  end
end

function Paris_3_Mission_1:DEBUGPlayConversation(sName, sCallback)
  if sCallback then
    Cin.PlayConversation(sName, sCallback, self)
  else
    Convo.AddConvo(sName, 10, {})
  end
end

function Paris_3_Mission_1:ReturnSpeakers(sPolyTrigger, sLabel, nSpeakers)
  local hTrigger = Util.GetHandleByName(sPolyTrigger)
  if hTrigger then
    local hLabel = Filter.New(sLabel)
    local tWho = Trigger.GetAllWithin(hTrigger, hLabel)
    if tWho then
      return tWho
    end
    Filter.Delete(hLabel)
  end
  return nil
end

function Paris_3_Mission_1:FxSpawnerFunction(sPathName, nMax, nSimul, sCheck, t_sFXNames, nRepeatTimer)
  if sPathName and nMax and nSimul and sCheck then
    if self.tSaveInfo[sCheck] == true then
      local nCounter = 1
      for nCounter = 1, nSimul do
        local hRandHandleToLoc = Handle(sPathName .. math.random(1, nMax))
        local sFXName = t_sFXNames[math.random(1, #t_sFXNames)]
        if hRandHandleToLoc then
          Render.StartFX(hRandHandleToLoc, sFXName, nil)
        end
      end
      local tEvent = {EventType = "TimerEvent", Time = nRepeatTimer}
      Util.CreateEvent(tEvent, "Paris_3_Mission_1.FxSpawnerFunction", self, {
        sPathName,
        nMax,
        nSimul,
        sCheck,
        t_sFXNames,
        nRepeatTimer
      })
    end
  else
    return false
  end
end
