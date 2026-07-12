if Paris_1_Mission_1 == nil then
  Paris_1_Mission_1 = SabTaskObjective:Create()
  gsParis1Mission1Dir = "Missions\\Paris_1\\Mission_1\\"
  Paris_1_Mission_1:Configure({
    TaskCount = 9999,
    bStarterless = true,
    MCDisplayID = 2,
    sSaveMissionNameID = "MissionNames_Text.P1M1",
    tUnlockList = {
      "Act_1_ToGermany"
    },
    sHQNextMissionStartPoint = _cHQe_FARM,
    bSLOverrideFade = true,
    tSMEDNodes = {
      "Missions\\paris_1\\mission_1\\depot"
    }
  })
end

function Paris_1_Mission_1:STARTER_Setup()
  Actor.SetDisguise(hSab, "FBS_RS_Sean")
end

function Paris_1_Mission_1:Activated()
  SabTaskObjective.Activated(self)
  Render.FadeScreen(true, 0)
  _g_b_ImInChargeOfObjectiveVisiblity = true
  self.GENERAL_Setup(self)
  self.Task_Belle(self)
  self.TASK_LucLoad(self)
end

function Paris_1_Mission_1:Reset()
  _g_b_ImInChargeOfObjectiveVisiblity = nil
  Sound.StopSoundEvent(self.tInfo.hAlarmAttpt, self.tInfo.AlarmSound)
end

function Paris_1_Mission_1:GENERAL_Setup()
  self.sDebugLabel = "P1M1"
  self.bDebugMode = false
  HUD.KeepObjectivesVisible(true)
  self.tSaveInfo.bAssaultGo = false
  self.tSaveInfo.bBoombed = false
  self.tSaveInfo.bDoppleLuc = false
  self.bFrenzy = false
  self.bBack2BelleCheck = false
  self.bStart = true
  self.tInfo.OutDoorBernie = "Missions\\paris_1\\characters\\belle\\luc_tobacco\\Luc_Tobac_Starter"
  self.tSaveInfo.bBriefing = false
  Util.SetTime(24, 0)
  Util.LoadDynamicNode("TitleScreen")
  self.sLucWalktoLoc = "Missions\\paris_1\\mission_1_to_1b\\main\\ByeByeSpot"
  self.tLargeProps = {}
  self.tInfo.Guard1 = "Missions\\paris_1\\mission_1\\depotnazis\\Spore_WM_Grunt_MG_3"
  self.tInfo.Guard2 = "Missions\\paris_1\\mission_1\\depotnazis\\Spore_WM_Officer"
  self.sBarStoolAttrpt = "PARIS\\area01\\belledenuit\\interior\\hq_int\\AttractionPT_SitCafe_BarStool"
  self.sGaspard = "Missions\\paris_1\\characters\\belle\\gaspard_interior\\gaspard_belle"
  self.sDebugProxyLoc = "Missions\\paris_1\\mission_1\\depot\\Locator"
  self.sTruckPath = "Missions\\paris_1\\mission_1\\depot\\TruckPath"
  self.sTruckPath2 = "Missions\\paris_1\\mission_1\\depot\\TruckPath2"
  self.sTruckSpawnLoc = "Missions\\paris_1\\mission_1\\depot\\TruckSpawnLoc"
  self.sFDGate = "PARIS\\area01\\garedelest\\nazifueldepot\\wtf_l\\OccMed_Checkpoint_Gate_A\\OccMed_Checkpoint_Gate_A(1)"
  self.sLucStarterPath = "Missions\\paris_1\\mission_1\\outdooractors\\LucStarterPath"
  self.sLucIntPath = "PARIS\\area01\\belledenuit\\interior\\civs\\LucIntPath"
  self.sLucApproachPath = "PARIS\\area01\\belledenuit\\interior\\civs\\LucApproach"
  self.sSaboTarget = "PARIS\\area01\\garedelest\\nazifueldepot\\wtf_l\\OccMed_OilTank_H\\OccMed_OilTank_H"
  self.nBoomNo = 0
  self.bRepeater = false
  self.sSaboTruck = "Missions\\paris_1\\mission_1\\depottruck\\VH_NZ_TR_OpelFuelTruck_01(3)"
  self.sTutorialTrigger = "Missions\\paris_1\\mission_1\\depot\\TutorialTrigger"
  Sound.LoadSoundBank("m_P1M1_inGame.bnk")
  self.bIsFirstTime = true
  self.sMissionCancelTrig = "Missions\\paris_1\\mission_1\\depot\\EscalationListenerTrig"
  self.bIs75PercentDamage = true
  self.bIs50PercentDamage = true
  self.bIsAbouttoDie = true
  self.tCarDamageConvos = {
    "P1M1_Car_Damage_First",
    "P1M1_Car_Damage_25",
    "P1M1_Car_Damage_50",
    "P1M1_Car_Damage_75",
    "P1M1_Car_Damage_Destroyed"
  }
  self.tCarFlags = {bInCar = true}
  self.sInterruptTrig = "Missions\\paris_1\\mission_1\\depot\\BigInterruptTrig"
  self.bIsStartFirst = true
  self.tSaveInfo.bIsFirstConvoPass = true
end

function Paris_1_Mission_1:Task_Belle()
  self:CreateTask({
    sName = "Task_Belle",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "EnterInterior",
    sInteriorName = "Belle",
    tOnActivate = {
      InteriorManager.EnterInterior("Belle", "Missions\\paris_1\\mission_1\\depot\\LOC_P1M1_StartINT")
    },
    tOnComplete = {
      {
        self.TASK_BelleOpenOnTCinematic,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:TASK_BelleOpenOnTCinematic()
  self:CreateTask({
    sName = "TASK_BelleOpenOnTCinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "101202",
    tCinematicNodes = {
      "202_cinb_depbrief"
    },
    tSMEDNodes = {},
    tOnActivate = {},
    tOnComplete = {
      {
        Util.SetOverrideLoadScreenFadeIn,
        {false}
      },
      {
        self.LucHitsDoor,
        {self}
      },
      {
        self.UnloadTaskNodes,
        {
          self,
          "Task_Belle",
          true
        }
      },
      {
        self.TASK_ExitTheBelle,
        {self}
      },
      {
        HUD.UnloadObject,
        {cTTitleScreen}
      },
      {
        Util.UnloadDynamicNode,
        {
          "TitleScreen"
        }
      }
    }
  })
end

function Paris_1_Mission_1:ReadyBand()
  WorldSMEDNodes.PreLoadCinematicNode("BelleInstruments")
end

function Paris_1_Mission_1:UnloadBand()
  WorldSMEDNodes.UnloadCinematicNode("BelleInstruments", true)
end

function Paris_1_Mission_1:TASK_LucLoad()
  self:CreateTask({
    sName = "TASK_LucLoad",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\paris_1\\characters\\belle\\luc_tobacco"
    },
    tOnComplete = {}
  })
end

function Paris_1_Mission_1:TASK_ExitTheBelle()
  self:CreateTask({
    sName = "TASK_ExitTheBelle",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sObjectiveTextID = "P1M1_Text.TASK_ExitTheBelle",
    sInteriorName = "Belle",
    bInteriorTask = true,
    tSMEDNodes = {
      "PARIS\\area01\\belledenuit\\interior\\band",
      "PARIS\\area01\\belledenuit\\interior\\barflys",
      "PARIS\\area01\\belledenuit\\interior\\nazis"
    },
    tLocators = {},
    tOnComplete = {
      {
        self.SetupCheckPoint1,
        {self}
      }
    },
    tOnActivate = {
      {
        self.SeanExitAttrPt,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:SeanExitAttrPt()
  self.bStart = false
  EVENT_Timer("Paris_1_Mission_1.PlayTutGPSonFoot", self, 4)
  local hBelleFrontDoor = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\hq_int\\Belle_int_teleport")
  AttractionPt.EnableUse(hBelleFrontDoor, true)
end

function Paris_1_Mission_1:PlayTutGPSonFoot()
  Util.QueueTutorial("TutorialTip_Text.GPS_On_Foot_Title", "TutorialTip_Text.GPS_On_Foot", -1, true)
end

function Paris_1_Mission_1:SetupCheckPoint1()
  self.RegisterCheckpoint(self, "Paris_1_Mission_1.CheckPoint1")
  Util.ClearAllPendingTutorials()
end

function Paris_1_Mission_1:CheckPoint1()
  HUD.KeepObjectivesVisible(true)
  if self.eGarageClosed then
    Trigger.DoNotWaitFor(Util.GetHandleByName("Missions\\paris_1\\mission_1\\depot\\PT_GarageDoorLock"), hSab)
  end
  self.eGarageClosed = EVENT_ActorEntersTrigger("Paris_1_Mission_1.GarageClosed", self, hSab, "Missions\\paris_1\\mission_1\\depot\\PT_GarageDoorLock", true)
  self:RegisterEvent(self.eGarageClosed)
  Suspicion.EnableEscalationVehicles(false)
  local hLucTobacc = Util.GetHandleByName(self.tInfo.OutDoorBernie)
  self.hLucTobacc = hLucTobacc
  local hLucsCar = Util.GetHandleByName("Missions\\paris_1\\mission_1\\outdooractors\\VH_CV_CR_Peugeot402_01")
  self.hLucsCar = hLucsCar
  Combat.SetIdleScripted(hLucTobacc, true)
  local tLucSmoke = {
    {
      "ISIDLESEQUENCE",
      {true}
    },
    {
      "WALKPATHONCE",
      {
        self.sLucStarterPath
      }
    },
    {
      "REQUESTATTRPT",
      {
        "Missions\\paris_1\\mission_1\\outdooractors\\ATTRPT_LucSmoke"
      }
    }
  }
  ScriptSequence.Run(self.hLucTobacc, tLucSmoke)
  self:TASK_OutdoorLoad()
  self:SetupEscalation()
  self:StreamHub()
  Util.UnloadStaticENTag("fp_amb_p1_radar_07", true)
  Freeplay.UnlockAmbientTag("fp_amb_p1_radar_07", false, true)
  Util.UnloadStaticENTag("fp_amb_p1_snipernest_03", true)
  Freeplay.UnlockAmbientTag("fp_amb_p1_snipernest_03", false, true)
  Util.UnloadStaticENTag("fp_amb_p1_searchlight_15", true)
  Freeplay.UnlockAmbientTag("fp_amb_p1_searchlight_15", false, true)
end

function Paris_1_Mission_1:TASK_OutdoorLoad()
  self:CreateTask({
    sName = "TASK_OutdoorLoad",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\paris_1\\mission_1\\depotnazis",
      "Missions\\paris_1\\mission_1\\outdooractors"
    },
    bCompleteOnActivate = true,
    tOnComplete = {
      {
        self.TASK_LucTalkieTime,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:TASK_LucTalkieTime()
  self:CreateTask({
    sName = "TASK_LucTalkieTime",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sObjectiveTextID = "P1M1_Text.TASK_LucTalkieTime",
    sConvFile = "203_Con_Depot",
    bAutofire = false,
    tTgtInclude = {
      self.tInfo.OutDoorBernie
    },
    tOnActivate = {
      {
        EVENT_Timer,
        {
          "Paris_1_Mission_1.PlayTutObjective_Focus",
          self,
          4
        }
      }
    },
    tOnComplete = {
      {
        self.DelayGetInConvo,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:PlayTutObjective_Focus()
  Util.QueueTutorial("TutorialTip_Text.Objective_Focus_Title", "TutorialTip_Text.Objective_Focus", -1, true, "FOB", true)
  HUD.FlashObjectiveMarker()
end

function Paris_1_Mission_1:PlayLucDeathConvo()
  Cin.PlayConversation("P1M1x_Luc_Dead", "Paris_1_Mission_1.FailMissionByLucDeath", self)
end

function Paris_1_Mission_1:FailMissionByLucDeath()
  self:MissionTaskFail("Char_Death.RS_Luc_P1M1")
end

function Paris_1_Mission_1.FireCarGetInConvo()
  local self = Paris_1_Mission_1
  Util.ClearAllPendingTutorials()
  Actor.CancelAttrPt(self.hLucTobacc)
  Nav.StopMoving(self.hLucTobacc)
  Combat.SetIdleScripted(self.hLucTobacc, true)
  Nav.CancelScriptedPath(self.hLucTobacc)
end

function Paris_1_Mission_1:DelayGetInConvo()
  EVENT_Timer("Paris_1_Mission_1.CarGetInConvo", self, 2)
end

function Paris_1_Mission_1:CarGetInConvo()
  if self.bIsFirstTime == true then
    self.bIsFirstTime = false
    Cin.PlayConversation("P1M1_Car_GetIn", "Paris_1_Mission_1.SetupCheckPoint2", self)
  elseif self.bIsFirstTime == false then
  end
end

function Paris_1_Mission_1:SetupCheckPoint2()
  self.RegisterCheckpoint(self, "Paris_1_Mission_1.CheckPoint2")
end

function Paris_1_Mission_1:CheckPoint2()
  HUD.KeepObjectivesVisible(true)
  self:SetupOutdoorBrawl()
  Suspicion.EnableEscalationVehicles(false)
  AttractionPt.EnableUse(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\hq_ext\\Belle_ext_teleport_two"), false)
  self.bCacheConvoDone = false
  self.bCacheDriveDone = false
  self.bCheck3aGo = false
  self:EventSetup()
  self:SetupEscalation()
end

function Paris_1_Mission_1:SetupEscalation()
  if not self:IsMissionTaskActive("TASK_Escalator") then
    self:TASK_Escalator()
  end
  if not self:IsMissionTaskActive("TASK_LostEscalation") then
    self:TASK_LostEscalation()
  end
  if not self:IsMissionTaskActive("TASK_DoubleEscalation") then
    self:TASK_DoubleEscalation()
  end
end

function Paris_1_Mission_1:SetupOutdoorBrawl()
  Combat.SetLeader(self.hLucTobacc, hSab, false, 5, 5)
  self:TASK_LucTaxi()
end

function Paris_1_Mission_1:DelayPickupConvo()
  EVENT_Timer("Paris_1_Mission_1.PickupConvo", self, 3)
end

function Paris_1_Mission_1:PickupConvo()
  Actor.CancelAttrPt(self.hLucTobacc)
  if self.bRepeater == false then
    Cin.StopConversation("P1M1_Car_GetIn")
    Cin.PlayConversation("P1M1_Car_Get_Bombs", "Paris_1_Mission_1.GetBombsDelay", self)
  else
  end
end

function Paris_1_Mission_1:GetBombsDelay()
  EVENT_Timer("Paris_1_Mission_1.See_Nazis_Conv", self, 3)
end

function Paris_1_Mission_1:See_Nazis_Conv()
  Cin.PlayConversation("P1M1_Car_See_Nazis", "Paris_1_Mission_1.CacheConvoCheck", self)
end

function Paris_1_Mission_1:GarageClosed()
  AttractionPt.EnableUse(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\hq_ext\\Belle_ext_teleport_two"), false)
end

function Paris_1_Mission_1:DynoEventSetup()
  if self.eGarageClosed then
    Trigger.DoNotWaitFor(Util.GetHandleByName("Missions\\paris_1\\mission_1\\depot\\PT_GarageDoorLock"), hSab)
  end
  self.eGarageClosed = EVENT_ActorEntersTrigger("Paris_1_Mission_1.GarageClosed", self, hSab, "Missions\\paris_1\\mission_1\\depot\\PT_GarageDoorLock", true)
  self:RegisterEvent(self.eGarageClosed)
  if self.eDynoEarly then
    Trigger.DoNotWaitFor(Util.GetHandleByName("Missions\\paris_1\\mission_1\\dynodepot\\PT_DynoRestricted_Early"), hSab)
  end
  self.eDynoEarly = EVENT_ActorEntersTrigger("Paris_1_Mission_1.LookoutSkip", self, hSab, "Missions\\paris_1\\mission_1\\dynodepot\\PT_DynoRestricted_Early")
  self:RegisterEvent(self.eDynoEarly)
end

function Paris_1_Mission_1:ClimbTutSkip()
  if self:IsMissionTaskActive("TASK_LucTaxi") then
    self:KillTaskByName("TASK_LucTaxi")
  end
  if self:IsMissionTaskActive("TASK_StopHarrass") then
    self:KillTaskByName("TASK_StopHarrass")
  end
  if self:IsMissionTaskActive("LucAlleyRendevous") then
    self:KillTaskByName("LucAlleyRendevous")
  end
  if self:IsMissionTaskActive("TASK_Climb2Lookout") then
    self:KillTaskByName("TASK_Climb2Lookout")
  end
  self:TASK_KillLookout()
  local hLOC_LucChill = Util.GetHandleByName("Missions\\paris_1\\mission_1\\dynodepot\\LOC_LucChill")
  Nav.MoveToObject(self.hLucTobacc, hLOC_LucChill, 1, true)
end

function Paris_1_Mission_1:LookoutSkip()
  if self.eClimbTutSkip then
    Util.KillEvent(self.eClimbTutSkip)
  end
  if self:IsMissionTaskActive("TASK_LucTaxi") then
    self:KillTaskByName("TASK_LucTaxi")
  end
  if self:IsMissionTaskActive("TASK_StopHarrass") then
    self:KillTaskByName("TASK_StopHarrass")
  end
  if self:IsMissionTaskActive("LucAlleyRendevous") then
    self:KillTaskByName("LucAlleyRendevous")
  end
  if self:IsMissionTaskActive("TASK_Climb2Lookout") then
    self:KillTaskByName("TASK_Climb2Lookout")
  end
  if self:IsMissionTaskActive("TASK_KillLookout") then
    self:KillTaskByName("TASK_KillLookout")
  end
  if self:IsMissionTaskActive("TASK_DropDown") then
    self:KillTaskByName("TASK_DropDown")
  end
  self:LucAttackPos()
  self:OpenGate()
  self:TASK_KillGuards()
end

function Paris_1_Mission_1:EventSetup()
  if self.eDepotEarly then
    Trigger.DoNotWaitFor(Util.GetHandleByName("Missions\\paris_1\\mission_1\\depot\\PT_DepotEarly"), hSab)
  end
  if self.eOops then
    Util.KillEvent(self.eOops)
  end
  local tOnSabPlantEvent = {EventType = "OnSabotage", Target = hSab}
  self.eOops = Util.CreateEvent(tOnSabPlantEvent, "Paris_1_Mission_1.Oops", self)
  self:RegisterEvent(self.eOops)
  self.eDepotEarly = EVENT_ActorEntersTrigger("Paris_1_Mission_1.GoodStuff", self, hSab, "Missions\\paris_1\\mission_1\\depot\\PT_DepotEarly")
  self:RegisterEvent(self.eDepotEarly)
  if self.eGarageClosed then
    Trigger.DoNotWaitFor(Util.GetHandleByName("Missions\\paris_1\\mission_1\\depot\\PT_GarageDoorLock"), hSab)
  end
  self.eGarageClosed = EVENT_ActorEntersTrigger("Paris_1_Mission_1.GarageClosed", self, hSab, "Missions\\paris_1\\mission_1\\depot\\PT_GarageDoorLock", true)
  self:RegisterEvent(self.eGarageClosed)
  self:StreamHub()
end

function Paris_1_Mission_1:Oops(tVars)
  dprint("I did it again")
  local hObject = tVars[3]
  local hGrenade = tVars[4]
  if hObject == Util.GetHandleByName(self.sSaboTarget) then
    Util.ClearAllPendingTutorials()
  else
    if hObject == Util.GetHandleByName(self.sSaboTruck) then
      Object.Actuate(Util.GetHandleByName("PARIS\\area01\\garedelest\\nazifueldepot\\wtf_l\\Checkpoint3.0 (Occupation 5m Gate)\\Occ_SecFence_PedGate5m_DoorAnim_R(2)"), true)
      if self.tSaveInfo.bDoppleLuc == false then
        Actor.CancelAttrPt(self.hLucTobacc)
        ScriptSequence.Kill(self.hLucTobacc)
        Nav.CancelScriptedPath(self.hLucTobacc)
        Combat.SetLeader(self.hLucTobacc, hSab, false, 5, 5)
      end
      if self.eFailSafe then
        Util.KillEvent(self.eFailSafe)
      end
      self.eFailSafe = EVENT_Timer("Paris_1_Mission_1.GoodStuff", self, 10)
    end
    if self.eOops then
      Util.KillEvent(self.eOops)
    end
    local tOnSabPlantEvent = {EventType = "OnSabotage", Target = hSab}
    self.eOops = Util.CreateEvent(tOnSabPlantEvent, "Paris_1_Mission_1.Oops", self)
    self:RegisterEvent(self.eOops)
  end
end

function Paris_1_Mission_1:LoadFire1()
  Util.SpawnEditNode("Missions\\paris_1\\mission_1\\fdparticles\\1stquarter.wsd")
end

function Paris_1_Mission_1:LoadFire2()
  Util.SpawnEditNode("Missions\\paris_1\\mission_1\\fdparticles\\2ndquarter.wsd")
end

function Paris_1_Mission_1:LoadFire3()
  Util.SpawnEditNode("Missions\\paris_1\\mission_1\\fdparticles\\3rdquarter.wsd")
end

function Paris_1_Mission_1:LucCheck()
  Cin.AllowHumanDamage(false)
  self:ChangeWTFStateStuff()
  if self.tSaveInfo.bDoppleLuc == true then
    self:UnloadTaskNodes("TASK_LucLoad")
    self:TASK_LucBack2Belle()
  else
    self:TASK_LucBack2Belle2()
  end
  if Actor.IsInVehicle(hSab) then
  else
    self:CarDepotCheck()
  end
  local tSecondaries = {
    "Missions\\paris_1\\mission_1\\fdparticles\\1stquarter\\Squib_A",
    "Missions\\paris_1\\mission_1\\fdparticles\\1stquarter\\Squib_B",
    "Missions\\paris_1\\mission_1\\fdparticles\\1stquarter\\Squib_C"
  }
  for i, v in ipairs(tSecondaries) do
    local hBoom = Util.GetHandleByName(v)
    if v ~= nil then
      EVENT_Timer("Paris_1_Mission_1.Secondary", self, 2 + 2 * i, {hBoom})
    end
  end
end

function Paris_1_Mission_1:Secondary(a_hBoom)
  if a_hBoom ~= nil then
    Object.Kill(a_hBoom)
  end
end

function Paris_1_Mission_1:OhShit()
  local hOhShitPoint
  local hSeanFilter = Filter.New("Player")
  local tSeanInside = {}
  local hSeanTrigger = Util.GetHandleByName("Missions\\paris_1\\mission_1\\depot\\PT_BlowCam1")
  tSeanInside = Trigger.GetAllWithin(hSeanTrigger, hSeanFilter)
  if tSeanInside[1] == hSab then
    hOhShitPoint = Util.GetHandleByName("Missions\\paris_1\\mission_1\\depot\\LOC_BlowCam1")
  else
    hOhShitPoint = Util.GetHandleByName("Missions\\paris_1\\mission_1\\depot\\LOC_BlowCam2")
  end
  dprint(hOhShitPoint)
  Nav.TreysMoveSeanToPointDangerous(hOhShitPoint, 1, true)
end

function Paris_1_Mission_1:GiveWeapons()
  if Inventory.GetCountOfType(hSab, "WP_PS_WaltherPPK") < 1 then
    Inventory.GiveItem(hSab, "WP_PS_WaltherPPK", false)
  else
  end
  if 1 > Inventory.GetCountOfType(hSab, "WP_SAB_DynamiteFuse") then
    Inventory.GiveItem(hSab, "WP_SAB_DynamiteFuse", false)
  else
  end
end

function Paris_1_Mission_1:FireoffDynamiteWarning()
  HUD.AddSubtitle("P1M1_Text.Message_ReceivedDynamite", 10)
end

function Paris_1_Mission_1:Task_AssaultDepot()
  self:CreateTask({
    sName = "Task_AssaultDepot",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P1M1_Text.Task_MasterAssault",
    bNoGPS = true,
    tLocators = {
      "Missions\\paris_1\\mission_1\\depot\\KillHubLoc"
    },
    tOnComplete = {
      {
        Render.Rain,
        {0, 1}
      }
    },
    tOnCancel = {},
    tOnActivate = {
      {
        self.KillCarListeners,
        {self}
      },
      {
        self.SetupTutorialListener,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:StreamHub()
  if self.eHubStream then
    Util.KillEvent(self.eHubStream)
  end
  self.eHubStream = Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForGameObject = true,
    Objects = {
      self.sSaboTarget
    }
  }, "Paris_1_Mission_1.ListenForHubDeath", self)
  self:RegisterEvent(self.eHubStream)
end

function Paris_1_Mission_1:ListenForHubDeath()
  if self.eHubDeath then
    Util.KillEvent(self.eHubDeath)
  end
  local hBigHub = Util.GetHandleByName(self.sSaboTarget)
  local tBigHubDeath = {EventType = "DeathEvent", ObjectHandle = hBigHub}
  self.eHubDeath = Util.CreateEvent(tBigHubDeath, "Paris_1_Mission_1.KillHubTask", self)
  self:RegisterEvent(self.eHubDeath)
  self.eHubStreamOut = Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForStreamOut = true,
    Objects = {
      self.sSaboTarget
    }
  }, "Paris_1_Mission_1.StreamHub", self)
  self:RegisterEvent(self.eHubStreamOut)
end

function Paris_1_Mission_1:KillHubTaskDelay()
  EVENT_Timer("Paris_1_Mission_1.KillHubTask", self, 0.3)
end

function Paris_1_Mission_1:KillHubTask()
  self.tSaveInfo.bBoombed = true
  if self.eDynoCount then
    Util.KillEvent(self.eDynoCount)
  end
  if self.eDynoDelete then
    Util.KillEvent(self.eDynoDelete)
  end
  self:CompleteTaskByName("Task_AssaultDepot")
  Sound.SetMusicLocale("P1M1_FuelDepot")
  Sound.SetMusicLocale("m_P1M1_FuelDepot", "blowDepot")
  if self:IsMissionTaskActive("TASK_DeEscalate") then
    self:KillTaskByName("TASK_DeEscalate")
    if self.sDeferedTask == "TASK_LucTalkieTime" then
      self.tSaveInfo.bDoppleLuc = true
    end
  end
  if self:IsMissionTaskActive("TASK_LucTalkieTime") then
    self:KillTaskByName("TASK_LucTalkieTime")
    self.tSaveInfo.bDoppleLuc = true
  end
  if self:IsMissionTaskActive("TASK_LucFuelTaxi") then
    self:KillTaskByName("TASK_LucFuelTaxi")
  end
  if self:IsMissionTaskActive("TASK_LucTaxi") then
    self:KillTaskByName("TASK_LucTaxi")
  end
  if self:IsMissionTaskActive("TASK_Vista") then
    self:KillTaskByName("TASK_Vista")
  end
  if self:IsMissionTaskActive("TASK_InPosition") then
    self:KillTaskByName("TASK_InPosition")
  end
  if self:IsMissionTaskActive("TASK_Zipline") then
    self:KillTaskByName("TASK_Zipline")
  end
  if self:IsMissionTaskActive("TASK_LucTaxi") then
    self:KillTaskByName("TASK_LucTaxi")
  end
  if self:IsMissionTaskActive("TASK_StopHarrass") then
    self:KillTaskByName("TASK_StopHarrass")
    self.tSaveInfo.bDoppleLuc = true
  end
  if self:IsMissionTaskActive("LucAlleyRendevous") then
    self:KillTaskByName("LucAlleyRendevous")
    self.tSaveInfo.bDoppleLuc = true
  end
  if self:IsMissionTaskActive("TASK_Climb2Lookout") then
    self:KillTaskByName("TASK_Climb2Lookout")
    self.tSaveInfo.bDoppleLuc = true
  end
  if self:IsMissionTaskActive("TASK_KillLookout") then
    self:KillTaskByName("TASK_KillLookout")
    self.tSaveInfo.bDoppleLuc = true
  end
  if self:IsMissionTaskActive("TASK_DropDown") then
    self:KillTaskByName("TASK_DropDown")
    self.tSaveInfo.bDoppleLuc = true
  end
  if self:IsMissionTaskActive("TASK_KillGuards") then
    self:KillTaskByName("TASK_KillGuards")
  end
  if self:IsMissionTaskActive("TASK_Smash") then
    self:KillTaskByName("TASK_Smash")
  end
  if self:IsMissionTaskActive("TASK_GetDyno") then
    self:KillTaskByName("TASK_GetDyno")
  end
  Cin.AllowHumanDamage(true)
  if Cin.IsPlayerCloseToCinematic("Missions\\paris_1\\mission_1\\CineLoc1(11)") then
    self:TASK_FuelDepotBoom()
  else
    self:TASK_FuelDepotBoomFar()
  end
end

function Paris_1_Mission_1:TASK_FuelDepotBoom()
  self:CreateTask({
    sName = "TASK_FuelDepotBoom",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "WTF_P1M1_FuelDepotBoom",
    tSMEDNodes = {
      "Missions\\cinematics\\wtf\\wtf_p1m1_fueldepot"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.LucCheck,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:TASK_FuelDepotBoomFar()
  self:CreateTask({
    sName = "TASK_FuelDepotBoomFar",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "WTF_P1M1_FuelDepotBoom_NOCAM",
    tSMEDNodes = {
      "Missions\\cinematics\\wtf\\wtf_p1m1_fueldepot"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.LucCheck,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:ChangeWTFStateStuff()
  Suspicion.SetEscalationLiteInfinitely(false)
  AchievementsManager.AchievementGrant("FUEL_DEPOT")
  local hSoundOrigin = Util.GetHandleByName("Missions\\paris_1\\mission_1\\depot\\LOC_ExplosionSound")
  Combat.BroadcastSound(hSoundOrigin, 75, 100, false)
end

function Paris_1_Mission_1:MissionCleanup()
  Util.LoadStaticENTag("BelleAreaNazis", false)
  Util.EnableGooseSteppers(true)
end

function Paris_1_Mission_1:TASK_LucTaxi()
  self:CreateTask({
    sName = "TASK_LucTaxi",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "P1M1_Text.TASK_LucTaxi_FindCar",
    sPickupTextID = "P1M1_Text.TASK_LucTaxi_Pickup",
    sDropoffTextID = "P1M1_Text.TASK_LucTaxi_Dyno",
    sVehicleFetchID = "GenericObjective_Text.Vehicle_GetIn_A",
    tPickupProxObj = {
      "Missions\\paris_1\\characters\\belle\\luc_tobacco\\Luc_Tobac_Starter"
    },
    PickupProximity = 50,
    tDestLocators = {
      "Missions\\paris_1\\mission_1\\dynodepot\\LOC_DynoDepot"
    },
    bGroundBlip = true,
    bNoDumping = true,
    tDestRegion = {
      "Missions\\paris_1\\mission_1\\dynodepot\\PT_DynoDepot"
    },
    tDeliverObjs = {
      "Missions\\paris_1\\characters\\belle\\luc_tobacco\\Luc_Tobac_Starter"
    },
    bEscalationDenial = true,
    tSMEDNodes = {
      "Missions\\paris_1\\mission_1\\dynodepot"
    },
    tStaticTags = {
      "P1M1_DynoDepot"
    },
    tOnEarlyExit = {},
    tOnPickup = {
      {
        self.DelayPickupConvo,
        {self}
      },
      {
        self.PlayTutDrivingBasic,
        {self}
      },
      {
        Cin.LoadCinematic,
        {
          "CIN_P1M1_HarrassCam_b"
        }
      },
      {
        Cin.LoadCinematic,
        {
          "CIN_P1M1_HarrassCam"
        }
      }
    },
    tOnComplete = {
      {
        self.CacheDriveCheck,
        {self}
      },
      {
        self.CarCacheGet,
        {self}
      }
    },
    tOnActivate = {
      {
        self.DynoEventSetup,
        {self}
      },
      {
        self.DynoStreamCheck,
        {self}
      },
      {
        self.CrateStreamCheck,
        {self}
      },
      {
        self.LookoutSetup,
        {self}
      },
      {
        self.SetupAnyCar2,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:SetupAnyCar2()
  if Actor.IsInVehicle(hSab) then
  elseif Object.IsAlive(Util.GetHandleByName("Missions\\paris_1\\mission_1\\outdooractors\\VH_CV_CR_Peugeot402_01")) then
    self:AnyCar2Cache()
  end
end

function Paris_1_Mission_1:AnyCar2Cache()
  self:CreateTask({
    sName = "AnyCar2Cache",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "GOTO",
    tTgtInclude = {
      "Missions\\paris_1\\mission_1\\outdooractors\\VH_CV_CR_Peugeot402_01"
    },
    bHighPriorityFocus = true,
    bNoGPS = true,
    tOnActivate = {
      {
        EVENT_PlayerEntersAnyVehicle,
        {
          "Paris_1_Mission_1.KillAnyCarEvent",
          self,
          "AnyCar2Cache"
        }
      },
      {
        EVENT_ActorDeath,
        {
          "Paris_1_Mission_1.KillAnyCarEvent",
          self,
          "Missions\\paris_1\\mission_1\\outdooractors\\VH_CV_CR_Peugeot402_01",
          {
            "crap",
            "AnyCar2Cache"
          }
        }
      }
    }
  })
end

function Paris_1_Mission_1:KillAnyCarEvent(junk, a_sAnyCarTask)
  if self:IsMissionTaskActive(a_sAnyCarTask) then
    self.KillTaskByName(self, a_sAnyCarTask)
  end
end

function Paris_1_Mission_1:CarCacheGet()
  self.hCacheCar = Actor.GetVehicle(hSab)
end

function Paris_1_Mission_1:CarCacheCheck()
  if self.hCacheCar then
    self:AnyCar2Depot()
  end
end

function Paris_1_Mission_1:AnyCar2Depot()
  self:CreateTask({
    sName = "AnyCar2Depot",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "GOTO",
    tTgtInclude = {
      self.hCacheCar
    },
    bNoGPS = true,
    bHighPriorityFocus = true,
    tOnActivate = {
      {
        EVENT_PlayerEntersAnyVehicle,
        {
          "Paris_1_Mission_1.KillAnyCarEvent",
          self,
          "AnyCar2Depot"
        }
      },
      {
        EVENT_ActorDeath,
        {
          "Paris_1_Mission_1.KillAnyCarEvent",
          self,
          self.hCacheCar,
          {
            "crap",
            "AnyCar2Depot"
          }
        }
      }
    }
  })
end

function Paris_1_Mission_1:CarDepotGet()
  self.hDepotCar = Actor.GetVehicle(hSab)
end

function Paris_1_Mission_1:CarDepotCheck()
  if self.hDepotCar then
    self:AnyCar2Belle()
  end
end

function Paris_1_Mission_1:AnyCar2Belle()
  self:CreateTask({
    sName = "AnyCar2Belle",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "GOTO",
    tTgtInclude = {
      self.hDepotCar
    },
    bNoGPS = true,
    bHighPriorityFocus = true,
    tOnActivate = {
      {
        EVENT_PlayerEntersAnyVehicle,
        {
          "Paris_1_Mission_1.KillAnyCarEvent",
          self,
          "AnyCar2Belle"
        }
      },
      {
        EVENT_ActorDeath,
        {
          "Paris_1_Mission_1.KillAnyCarEvent",
          self,
          self.hDepotCar,
          {
            "crap",
            "AnyCar2Belle"
          }
        }
      }
    }
  })
end

function Paris_1_Mission_1:DynoSetup()
  self:CreateTask({
    sName = "DynoSetup",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\paris_1\\mission_1\\dynoharass"
    },
    bCompleteOnActivate = true,
    tOnComplete = {
      {
        self.DynoHarrass,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:DynoStreamCheck()
  if self.eCrateStream then
    Util.KillEvent(self.eCrateStream)
  end
  local e = Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForGameObject = true,
    Objects = {
      "Missions\\paris_1\\mission_1\\dynocolby\\LOC_DynoStreamCheck"
    }
  }, "Paris_1_Mission_1.DynoStreamIn", self)
  self:RegisterEvent(e)
end

function Paris_1_Mission_1:DynoStreamIn()
  Util.EnableSidewalksInRegion(false, "Missions\\paris_1\\mission_1\\dynodepot\\PT_CivsOff")
  self.eHarrassStreamOut = Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForStreamOut = true,
    Objects = {
      "Missions\\paris_1\\mission_1\\dynocolby\\LOC_DynoStreamCheck"
    }
  }, "Paris_1_Mission_1.DynoStreamCheck", self)
  self:RegisterEvent(self.eHarrassStreamOut)
end

function Paris_1_Mission_1:CrateStreamCheck()
  if self.eCrateStream then
    Util.KillEvent(self.eCrateStream)
  end
  local e = Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForGameObject = true,
    Objects = {
      "Missions\\paris_1\\mission_1\\dynocolby\\Crate_Dynamite_1\\Crate"
    }
  }, "Paris_1_Mission_1.CrateBreak", self)
  self:RegisterEvent(e)
end

function Paris_1_Mission_1:LookoutSetup()
  self.hLookout = Util.GetHandleByName("Missions\\paris_1\\mission_1\\dynodepot\\Spore_Dyno_Lookout")
  local e2 = Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForGameObject = true,
    Objects = {
      self.hLookout
    }
  }, "Paris_1_Mission_1.LookoutStream", self)
  self:RegisterEvent(e2)
end

function Paris_1_Mission_1:LookoutStream()
  if self.eClimbTutSkip then
    Util.KillEvent(self.eClimbTutSkip)
  end
  self.eClimbTutSkip = EVENT_ActorDamaged("Paris_1_Mission_1.ClimbTutSkip", self, self.hLookout)
  self.eLookoutStreamOut = Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForStreamOut = true,
    Objects = {
      self.hLookout
    }
  }, "Paris_1_Mission_1.LookoutSetup", self)
  self:RegisterEvent(self.eLookoutStreamOut)
end

function Paris_1_Mission_1:ClearLookoutStream()
  if self.eLookoutStreamOut then
    Util.KillEvent(self.eLookoutStreamOut)
  end
end

function Paris_1_Mission_1:DynoHarrass()
  self.hHarrass1 = Util.GetHandleByName("Missions\\paris_1\\mission_1\\dynoharass\\Spore_Dyno_Harass1")
  self.hHarrass2 = Util.GetHandleByName("Missions\\paris_1\\mission_1\\dynoharass\\Spore_Dyno_Harass2")
  self.hOldWoman = Util.GetHandleByName("Missions\\paris_1\\mission_1\\dynoharass\\Spore_OldWoman")
  RewardsManager.SetGlobalAllowCombatHijacking(true)
  Suspicion.SetWhistleEscalationEnabled(self.hHarrass1, false)
  Suspicion.SetWhistleEscalationEnabled(self.hHarrass2, false)
  Object.SetInvincibleToAI(self.hOldWoman, true)
  Object.SetInvincibleToAI(self.hHarrass1, true)
  Object.SetInvincibleToAI(self.hHarrass2, true)
  Cin.AllowAttackingDuringCinematics(true)
  local hAlertTrigger = Util.GetHandleByName("Missions\\paris_1\\mission_1\\dynodepot\\PT_DynoDepotSabCheck")
  local hSeanFilter = Filter.New("Player")
  local tSeanInside = {}
  tSeanInside = Trigger.GetAllWithin(hAlertTrigger, hSeanFilter)
  if tSeanInside ~= nil then
    Cin.PlayCinematic("CIN_P1M1_HarrassCam_b", false, "Paris_1_Mission_1.FrenzyCheck", self)
  else
    Cin.PlayCinematic("CIN_P1M1_HarrassCam", false, "Paris_1_Mission_1.FrenzyCheck", self)
  end
end

function Paris_1_Mission_1.HitHer()
  local self = Paris_1_Mission_1
  Combat.DoMeleeMove(self.hHarrass1, "nazi_group_harrass_slap", self.hOldWoman, true)
  EVENT_Timer("Paris_1_Mission_1.YouBetterRun", self, 17)
  self.bQuitHarass = false
  EVENT_ActorDamaged("Paris_1_Mission_1.QuitHarass", self, self.hHarrass1)
  EVENT_ActorDamaged("Paris_1_Mission_1.QuitHarass", self, self.hOldWoman)
  self:BroadcastHarass()
end

function Paris_1_Mission_1:QuitHarass()
  if self.bQuitHarass == false then
    self.bQuitHarass = true
    Actor.CancelAnimation(self.hOldWoman)
    Actor.CancelAnimation(self.hHarrass1)
  end
end

function Paris_1_Mission_1:YouBetterRun()
  if self.eBroadTimer then
    Util.KillEvent(self.eBroadTimer)
  end
  local hOldWomanRun = Util.GetHandleByName("Missions\\paris_1\\mission_1\\dynodepot\\LOC_OldWomanRun")
  Nav.MoveToObject(self.hOldWoman, hOldWomanRun, 1, true)
end

function Paris_1_Mission_1:BroadcastHarass()
  Util.BroadcastHarassmentEventAtActor(self.hOldWoman)
  self.eBroadTimer = Util.CreateEvent({
    EventType = "TimerEvent",
    EventName = "BroadTime",
    Time = 3
  }, "Paris_1_Mission_1.BroadcastHarass", self)
end

function Paris_1_Mission_1:FightBack()
  Combat.SetReactImmediately(self.hHarrass1, true)
  Combat.SetReactImmediately(self.hHarrass2, true)
  Combat.SetCombat(self.hHarrass1, true)
  Combat.SetCombat(self.hHarrass2, true)
  Combat.SetTarget(self.hHarrass1, hSab)
  Combat.SetTarget(self.hHarrass2, self.hLucTobacc)
end

function Paris_1_Mission_1:TASK_LucFuelTaxi()
  self:CreateTask({
    sName = "TASK_LucFuelTaxi",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "P1M1_Text.TASK_LucTaxi_FindCar",
    sPickupTextID = "P1M1_Text.TASK_LucTaxi_Pickup",
    sDropoffTextID = "P1M1_Text.TASK_LucTaxi_DropOff",
    sVehicleFetchID = "GenericObjective_Text.Vehicle_GetInBack_The",
    tPickupProxObj = {
      "Missions\\paris_1\\characters\\belle\\luc_tobacco\\Luc_Tobac_Starter"
    },
    PickupProximity = 50,
    tDestLocators = {
      "Missions\\paris_1\\mission_1\\depot\\LucDropoffLoc"
    },
    bGroundBlip = true,
    bNoDumping = true,
    tDestRegion = {
      "Missions\\paris_1\\mission_1\\depot\\LucDropoff"
    },
    tDeliverObjs = {
      "Missions\\paris_1\\characters\\belle\\luc_tobacco\\Luc_Tobac_Starter"
    },
    bEscalationDenial = true,
    tSMEDNodes = {
      "Missions\\paris_1\\mission_1\\depottruck"
    },
    tOnEarlyExit = {},
    tOnPickup = {
      {
        self.DelayConvoFuel,
        {self}
      }
    },
    tOnComplete = {
      {
        self.SetupDropOffCnv,
        {self}
      },
      {
        self.CarDepotGet,
        {self}
      }
    },
    tOnActivate = {
      {
        self.StreamSaboTruck,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:TASK_LucBack2Belle()
  self:CreateTask({
    sName = "TASK_LucBack2Belle",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "P1M1_Text.TASK_LucTaxi_FindCar",
    sPickupTextID = "P1M1_Text.TASK_LucTaxi_Pickup",
    sDropoffTextID = "P1M1_Text.TASK_LucTaxi_Belle",
    sVehicleFetchID = "GenericObjective_Text.Vehicle_GetInBack_The",
    tPickupProxObj = {
      "Missions\\paris_1\\mission_1\\Luc2\\Spore_RS_Luc2"
    },
    PickupProximity = 20,
    tDestLocators = {
      "Missions\\paris_1\\mission_1\\depot\\LOC_Back2Belle"
    },
    bGroundBlip = true,
    vGPSTarget = "Missions\\paris_1\\mission_1\\Luc2\\Spore_RS_Luc2",
    tDestRegion = {
      "Missions\\paris_1\\mission_1\\outdooractors\\PT_Back2Belle"
    },
    tDeliverObjs = {
      "Missions\\paris_1\\mission_1\\Luc2\\Spore_RS_Luc2"
    },
    bEscalationDenial = true,
    sDropOffConv = "P1M1_arrive_at_Belle",
    bFadeOutOnDropOff = true,
    tReadyForUnload = {
      {
        self.WestLeftBankFadeAway,
        {self}
      }
    },
    tSMEDNodes = {
      "Missions\\paris_1\\mission_1\\Luc2"
    },
    tOnEarlyExit = {},
    tOnPickup = {
      {
        self.BackBelleDelay,
        {self}
      }
    },
    tOnComplete = {
      {
        self.ArriveConv,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Paris_1_Mission_1:TASK_LucBack2Belle2()
  self:CreateTask({
    sName = "TASK_LucBack2Belle2",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "P1M1_Text.TASK_LucTaxi_FindCar",
    sPickupTextID = "P1M1_Text.TASK_LucTaxi_Pickup",
    sDropoffTextID = "P1M1_Text.TASK_LucTaxi_Belle",
    sVehicleFetchID = "GenericObjective_Text.Vehicle_GetInBack_The",
    tPickupProxObj = {
      "Missions\\paris_1\\characters\\belle\\luc_tobacco\\Luc_Tobac_Starter"
    },
    PickupProximity = 20,
    tDestLocators = {
      "Missions\\paris_1\\mission_1\\depot\\LOC_Back2Belle"
    },
    bGroundBlip = true,
    vGPSTarget = "Missions\\paris_1\\characters\\belle\\luc_tobacco\\Luc_Tobac_Starter",
    bNoDumping = true,
    tDestRegion = {
      "Missions\\paris_1\\mission_1\\outdooractors\\PT_Back2Belle"
    },
    tDeliverObjs = {
      "Missions\\paris_1\\characters\\belle\\luc_tobacco\\Luc_Tobac_Starter"
    },
    bEscalationDenial = true,
    sDropOffConv = "P1M1_arrive_at_Belle2",
    bFadeOutOnDropOff = true,
    tReadyForUnload = {
      {
        self.WestLeftBankFadeAway,
        {self}
      }
    },
    tSMEDNodes = {},
    tOnEarlyExit = {},
    tOnPickup = {
      {
        self.KillTaskByName,
        {
          self,
          "AnyCar2Belle"
        }
      },
      {
        self.BackBelleDelay,
        {self}
      }
    },
    tOnComplete = {
      {
        self.ArriveConv,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Paris_1_Mission_1:NewLuc(a_sLuc)
  self.hNewLuc = Util.GetHandleByName(a_sLuc)
  Combat.SetCombat(self.hNewLuc, true)
  Combat.SetLeader(self.hNewLuc, hSab, false, 5, 5)
end

function Paris_1_Mission_1:TASK_EnterBelle2()
  self:CreateTask({
    sName = "TASK_EnterBelle2",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "EnterInterior",
    sInteriorName = "Belle",
    sObjectiveTextID = "P1M1_Text.TASK_EnterBelleInterior",
    tLocators = {
      "Missions\\paris_1\\mission_1\\depot\\LOC_EnterBelle2"
    },
    tOnActivate = {
      {
        self.DelayToClearMusic,
        {self}
      }
    },
    tOnComplete = {
      {
        self.Task_GotoYourRoom,
        {self}
      },
      {
        Util.AddInteriorLoadCallback,
        {
          "Belle",
          "Paris_1_Mission_1.ExitCheck",
          self
        }
      }
    }
  })
end

function Paris_1_Mission_1:ExitCheck()
  self.ResetTaskByName(self, "TASK_EnterBelle2")
  self.ResetTaskByName(self, "Task_GotoYourRoom", true)
  self.ResetTaskByName(self, "TASK_TakeANap", true)
end

function Paris_1_Mission_1:Task_GotoYourRoom()
  self:CreateTask({
    sName = "Task_GotoYourRoom",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    bInteriorTask = true,
    sObjectiveTextID = "P1M1_Text.Task_GotoYourRoom",
    tTgtInclude = {
      "PARIS\\area01\\belledenuit\\interior\\hq_int\\MN_INT_BelleDeNuit\\SlidingDoorReverse"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        Paris_1_Mission_1.TASK_TakeANap,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:DelayToClearMusic()
  if self.bBack2BelleCheck == false then
    EVENT_Timer("Paris_1_Mission_1.ClearMusic4Belle", self, 60)
  end
end

function Paris_1_Mission_1:ClearMusic4Belle()
  Sound.ResetMusicLocale()
end

function Paris_1_Mission_1:TASK_TakeANap()
  self:CreateTask({
    sName = "TASK_TakeANap",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\paris_1\\mission_1\\depot\\PT_TakeANap",
    tLocators = {
      "Missions\\paris_1\\mission_1\\depot\\LOC_TakeANap"
    },
    tDeliverObjs = {hSab},
    bInteriorTask = true,
    sObjectiveTextID = "P1M1_Text.TASK_TakeANap",
    tOnActivate = {},
    tOnComplete = {
      {
        self.FinishThisNow,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:BackBelleDelay()
  EVENT_Timer("Paris_1_Mission_1.BackBelleConvo", self, 2)
end

function Paris_1_Mission_1:BackBelleConvo()
  if self.tSaveInfo.bDoppleLuc == true then
    Cin.PlayConversation("P1M1_After_Depot")
  else
    Cin.PlayConversation("P1M1_After_Depot2")
  end
end

function Paris_1_Mission_1:DepConvoCheck()
  self.bDepConvoDone = true
  if self.bDepDriveDone == true and self.bCheck3Go == false then
    self.bCheck3Go = true
    self:SetupCheckPoint3c()
  end
end

function Paris_1_Mission_1:DepDriveCheck()
  self.bDepDriveDone = true
  if self.bDepConvoDone == true and self.bCheck3Go == false then
    self.bCheck3Go = true
    self:SetupCheckPoint3c()
  end
end

function Paris_1_Mission_1:CacheConvoCheck()
  self.bCacheConvoDone = true
  if self.bCacheDriveDone == true and self.bCheck3aGo == false then
    self.bCheck3aGo = true
    self:SetupCheckPoint3a()
  end
end

function Paris_1_Mission_1:CacheDriveCheck()
  self.bCacheDriveDone = true
  SabTaskObjectiveDeliver.DisableVehControls(self, true)
  if self.bCacheConvoDone == true and self.bCheck3aGo == false then
    self.bCheck3aGo = true
    self:SetupCheckPoint3a()
  end
end

function Paris_1_Mission_1:TASK_DynoDelete()
  self:CreateTask({
    sName = "TASK_DynoDelete",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tDeleteNodes = {
      "Missions\\paris_1\\mission_1\\dynodelete"
    },
    tOnComplete = {}
  })
end

function Paris_1_Mission_1:WestLeftBankFadeAway()
  Util.UnloadEditNode("Missions\\paris_1\\mission_1\\fdparticles\\1stquarter.wsd", false)
  Util.UnloadEditNode("Missions\\paris_1\\mission_1\\fdparticles\\2ndquarter.wsd", false)
  Util.UnloadEditNode("Missions\\paris_1\\mission_1\\fdparticles\\3rdquarter.wsd", false)
  if self.tSaveInfo.bDoppleLuc == true then
    self:UnloadTaskNodes("TASK_LucBack2Belle", true)
  else
    self:UnloadTaskNodes("TASK_LucLoad", true)
  end
  self:TASK_EnterBelle2()
end

function Paris_1_Mission_1:ArriveConv()
  if self.tSaveInfo.bDoppleLuc == true then
    Cin.StopConversation("P1M1_After_Depot")
  else
    Cin.StopConversation("P1M1_After_Depot2")
  end
  Cin.LoadCinematic("102_CinB_FarmIntro")
  WorldSMEDNodes.PreLoadCinematicNode("102_cinb_farmintro")
end

function Paris_1_Mission_1:SetConvMusic()
  self = Paris_1_Mission_1
  Sound.SetMusicLocale("P1M1_FuelDepot")
  Sound.SetMusicLocale("m_P1M1_FuelDepot", "belleReturn")
end

function Paris_1_Mission_1:DelayConvoFuel()
  Util.ClearAllPendingTutorials()
  EVENT_Timer("Paris_1_Mission_1.PickupConvoFuel", self, 4)
end

function Paris_1_Mission_1:PickupConvoFuel()
  Cin.PlayConversation("P1M1_Fuel_Drive", "Paris_1_Mission_1.DepConvoCheck", self)
end

function Paris_1_Mission_1:OnEscalationClear()
  if self.eEscalationTutTimer then
    Util.KillEvent(self.eEscalationTutTimer)
  end
  Util.ClearAllPendingTutorials()
  if self.bIsFirstTime == true then
    local tLucSmoke = {
      {
        "ISIDLESEQUENCE",
        {true}
      },
      {
        "REQUESTATTRPT",
        {
          "Missions\\paris_1\\mission_1\\outdooractors\\ATTRPT_LucSmoke"
        }
      }
    }
    ScriptSequence.Run(self.hLucTobacc, tLucSmoke)
  end
end

function Paris_1_Mission_1:OnEscalation()
  if self:IsMissionTaskActive("TASK_InPosition") or self:IsMissionTaskActive("TASK_Vista") then
    self:GoodStuff()
  end
  if self:IsMissionTaskActive("LucAlleyRendevous") then
    self:LookoutSkip()
  end
  self.eEscalationTutTimer = Util.CreateEvent({
    EventType = "TimerEvent",
    EventName = "EscalationTutTimer",
    Time = 10
  }, "Paris_1_Mission_1.PlayEscalationTimer", self)
  if self:IsMissionTaskActive("TASK_EnterBelle2") then
    self:ResetTaskByName("TASK_EnterBelle2", true)
    self.sDeferedTask = "TASK_EnterBelle2"
    self:TASK_DeEscalate("TASK_EnterBelle2")
  elseif self:IsMissionTaskActive("TASK_LucTalkieTime") then
    self:ResetTaskByName("TASK_LucTalkieTime", true)
    self.sDeferedTask = "TASK_LucTalkieTime"
    Paris_1_Mission_1.TASK_DeEscalate(self, "TASK_LucTalkieTime")
  end
end

function Paris_1_Mission_1:TASK_DeEscalate(a_sTaskName)
  self:CreateTask({
    sName = "TASK_DeEscalate",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 0,
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    tOnComplete = {
      {
        self.ResetTaskByName,
        {self, a_sTaskName}
      },
      {
        self.ResetTaskByName,
        {
          self,
          "TASK_DeEscalate",
          true
        }
      }
    },
    tOnActivate = {}
  })
end

function Paris_1_Mission_1:PlayEscalationTimer()
  Util.QueueTutorial("TutorialTip_Text.Escalation_Escape_Title", "TutorialTip_Text.Escalation_Escape", -1)
end

function Paris_1_Mission_1:OnEscalation2()
  Suspicion.EnableEscalationVehicles(true)
end

function Paris_1_Mission_1:TASK_Escalator()
  self:CreateTask({
    sName = "TASK_Escalator",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = false,
    tOnComplete = {
      {
        self.OnEscalation,
        {self}
      },
      {
        self.TASK_LostEscalation,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Paris_1_Mission_1:TASK_LostEscalation()
  self:CreateTask({
    sName = "TASK_LostEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 0,
    tOnComplete = {
      {
        self.OnEscalationClear,
        {self}
      },
      {
        self.ResetTaskByName,
        {
          self,
          "TASK_LostEscalation",
          true
        }
      },
      {
        self.ResetTaskByName,
        {
          self,
          "TASK_Escalator"
        }
      },
      {
        self.ResetTaskByName,
        {
          self,
          "TASK_DoubleEscalation"
        }
      }
    },
    tOnActivate = {}
  })
end

function Paris_1_Mission_1:TASK_DoubleEscalation()
  self:CreateTask({
    sName = "TASK_DoubleEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 2,
    bGTE = true,
    tOnComplete = {
      {
        self.OnEscalation2,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Paris_1_Mission_1:TASK_Vista()
  self:CreateTask({
    sName = "TASK_Vista",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\paris_1\\mission_1\\depot\\PT_Vista",
    tLocators = {
      "Missions\\paris_1\\mission_1\\depot\\LOC_Vista"
    },
    tDeliverObjs = {hSab},
    sObjectiveTextID = "P1M1_Text.TASK_Vista",
    tOnActivate = {},
    tOnComplete = {
      {
        self.TASK_InPosition,
        {self}
      },
      {
        Render.Rain,
        {0.3, 7}
      }
    }
  })
end

function Paris_1_Mission_1:TASK_InPosition()
  self:CreateTask({
    sName = "TASK_InPosition",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\paris_1\\mission_1\\depot\\PT_InPosition",
    tLocators = {
      "Missions\\paris_1\\mission_1\\depot\\LOC_InPosition"
    },
    tDeliverObjs = {hSab},
    sObjectiveTextID = "P1M1_Text.TASK_InPosition",
    bGroundBlip = false,
    tOnActivate = {},
    tOnComplete = {
      {
        self.LucGo,
        {self}
      },
      {
        self.TASK_WaitHere,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:TASK_WaitHere()
  self:CreateTask({
    sName = "TASK_WaitHere",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tDeleteNodes = {
      "Missions\\paris_1\\mission_1\\TruckClear"
    },
    tOnComplete = {}
  })
end

function Paris_1_Mission_1:TASK_ZipLine()
  self:CreateTask({
    sName = "TASK_ZipLine",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\paris_1\\mission_1\\depot\\PT_DepotEarly",
    tLocators = {
      "Missions\\paris_1\\mission_1\\depot\\LOC_ZipLine"
    },
    tDeliverObjs = {hSab},
    sObjectiveTextID = "P1M1_Text.TASK_ZipLine",
    tOnActivate = {
      {
        self.ZipSetup,
        {self}
      }
    },
    tOnComplete = {
      {
        self.PlayTutHealthBasic,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:ClamberTutBasic()
  if self.eClamberTutBasic then
    Util.KillEvent(self.eClamberTutBasic)
  end
  if self.eDynoMusicGo then
    Util.KillEvent(self.eDynoMusicGo)
  end
  if self.eClimbTutSkip then
    Util.KillEvent(self.eClimbTutSkip)
  end
  self.eClamberTutBasic = EVENT_ActorEntersTrigger("Paris_1_Mission_1.PlayClamberTutBasic", self, hSab, "Missions\\paris_1\\mission_1\\dynodepot\\PT_DynoClamberingTut")
  self:RegisterEvent(self.eClamberTutBasic)
  self.hLookout = Util.GetHandleByName("Missions\\paris_1\\mission_1\\dynodepot\\Spore_Dyno_Lookout")
  self.eDynoMusicGo = EVENT_ActorDamaged("Paris_1_Mission_1.PlayDynoMusic", self, self.hLookout)
  self:RegisterEvent(self.eDynoMusicGo)
end

function Paris_1_Mission_1:PlayDynoMusic()
  Sound.SetMusicLocale("P1M1_FuelDepot")
  Sound.SetMusicLocale("m_P1M1_FuelDepot", "killGuards")
end

function Paris_1_Mission_1:PlayClamberTutBasic()
  Util.QueueTutorial("TutorialTip_Text.Clambering_Basic_Title", "TutorialTip_Text.Clambering_Basic", -1, true)
  self:ClamberTutAdv()
end

function Paris_1_Mission_1:ClamberTutAdv()
  self.eClamberTutAdv = EVENT_ActorEntersTrigger("Paris_1_Mission_1.PlayClamberTutAdv", self, hSab, "Missions\\paris_1\\mission_1\\dynodepot\\PT_ClamberTutAdvanced")
  self:RegisterEvent(self.eClamberTutAdv)
end

function Paris_1_Mission_1:PlayClamberTutAdv()
  Util.QueueTutorial("TutorialTip_Text.Clambering_Advanced_Title", "TutorialTip_Text.Clambering_Advanced", -1, true)
end

function Paris_1_Mission_1:CrateTut()
  Util.QueueTutorial("TutorialTip_Text.Supply_Crates_Title", "TutorialTip_Text.Supply_Crates", -1, true)
end

function Paris_1_Mission_1:PlayTutDrivingBasic()
  Util.QueueTutorial("TutorialTip_Text.Vehicle_Driving_Basic_Title", "TutorialTip_Text.Vehicle_Driving_Basic", 20, true)
end

function Paris_1_Mission_1:PlayTutZip()
  Saboteur.ShowToolTip("TutorialTip_Text.Zip_Line_Grab", 60, nil, nil, true)
  self.eZipTutOff = EVENT_ActorExitsTrigger("Paris_1_Mission_1.ZipTutOff", self, hSab, "Missions\\paris_1\\mission_1\\depot\\PT_ZipTutOff")
  self:RegisterEvent(self.eZipTutOff)
end

function Paris_1_Mission_1:ZipTutOff()
  Util.ClearAllPendingTutorials()
end

function Paris_1_Mission_1:PlayTutResArea()
  Util.QueueTutorial("TutorialTip_Text.Restricted_Areas_Title", "TutorialTip_Text.Restricted_Areas", 60, true)
  HUD.FlashRestrictedAreas()
end

function Paris_1_Mission_1:PlayTutHealthBasic()
end

function Paris_1_Mission_1:PreDepotEvents()
  Actor.OverrideCombatAI(self.hLucTobacc, false)
end

function Paris_1_Mission_1:GoodStuff()
  if self.eFailSafe then
    Util.KillEvent(self.eFailSafe)
  end
  if self:IsMissionTaskActive("TASK_LucFuelTaxi") then
    self:KillTaskByName("TASK_LucFuelTaxi")
  end
  if self:IsMissionTaskActive("TASK_LucTaxi") then
    self:KillTaskByName("TASK_LucTaxi")
  end
  if self:IsMissionTaskActive("TASK_Vista") then
    self:KillTaskByName("TASK_Vista")
  end
  if self:IsMissionTaskActive("TASK_InPosition") then
    self:KillTaskByName("TASK_InPosition")
  end
  if self:IsMissionTaskActive("TASK_Zipline") then
    self:KillTaskByName("TASK_Zipline")
  end
  if self.tSaveInfo.bAssaultGo == false then
    self.tSaveInfo.bAssaultGo = true
    self:Task_AssaultDepot()
  end
  if Actor.IsInVehicle(self.hLucTobacc) then
    Combat.SetLeader(self.hLucTobacc, hSab, false, 5, 5)
  end
end

function Paris_1_Mission_1:DropOffTasks()
  Actor.SetCannotGetOutOfSeat(hSab, false)
  SabTaskObjectiveDeliver.DisableVehControls(self, false)
  local hSaboTruck = Util.GetHandleByName(self.sSaboTruck)
  if self.tSaveInfo.bIsFirstConvoPass == true and Object.IsAlive(hSaboTruck) then
    Combat.ClearLeader(self.hLucTobacc)
    Cin.StopCinematic("CIN_P1M1_ClimbCam")
    self.tSaveInfo.bIsFirstConvoPass = false
    Util.UnloadStaticENTag("fueldepot_sidewalks_off", true)
    Util.EnableSidewalksInRegion(false, "Missions\\paris_1\\mission_1\\depot\\PT_SidewalkDisable")
    if Actor.IsInVehicle(hSab) then
      Actor.UnboardVehicle(hSab)
    end
    Combat.SetIdleScripted(self.hLucTobacc, true)
    if Actor.IsInVehicle(self.hLucTobacc) then
      Actor.UnboardVehicle(self.hLucTobacc)
      EVENT_ActorExitsAnyVehicle("Paris_1_Mission_1.LucStroll", self, self.hLucTobacc)
    else
      self:LucStroll()
    end
    self:TASK_Vista()
  else
  end
end

function Paris_1_Mission_1:SetupDropOffCnv()
  Actor.SetCannotGetOutOfSeat(hSab, true)
  self.hDropOffVeh = Actor.GetVehicle(hSab)
  SabTaskObjectiveDeliver.DisableVehControls(self, true)
  self:DepDriveCheck()
end

function Paris_1_Mission_1:DropOffConv()
  EVENT_Timer("Paris_1_Mission_1.DeferThatShit", self, 1)
end

function Paris_1_Mission_1:DeferThatShit()
  Cin.PlayCinematic("CIN_P1M1_ClimbCam", false, "Paris_1_Mission_1.DropOffTasks", self)
end

function Paris_1_Mission_1:ClimbCam()
  Cin.PlayCinematic("CIN_P1M1_ClimbCam", false, "Paris_1_Mission_1.DropOffTasks", self)
end

function Paris_1_Mission_1:LucStroll()
  local tLucSmoke = {
    {
      "ISIDLESEQUENCE",
      {true}
    },
    {
      "RUNPATHONCE",
      {
        "Missions\\paris_1\\mission_1\\depot\\PATH_LucStroll"
      }
    },
    {
      "REQUESTATTRPT",
      {
        "Missions\\paris_1\\mission_1\\depot\\ATTRPT_LucSmoke"
      }
    }
  }
  ScriptSequence.Run(self.hLucTobacc, tLucSmoke)
end

function Paris_1_Mission_1:LucGo()
  Util.ClearAllPendingTutorials()
  Object.SetInvincible(self.hLucTobacc, true)
  ScriptSequence.Kill(self.hLucTobacc)
  Nav.CancelScriptedPath(self.hLucTobacc)
  local tOnSabLitEvent = {
    EventType = "OnSabotageLight",
    Target = self.hLucTobacc
  }
  Util.CreateEvent(tOnSabLitEvent, "Paris_1_Mission_1.LucMoveBack", self)
  EVENT_Timer("Paris_1_Mission_1.BombtheBomb", self, 0.2)
  if self.eFailSafe then
    Util.KillEvent(self.eFailSafe)
  end
  self.eFailSafe = EVENT_Timer("Paris_1_Mission_1.GoodStuff", self, 30)
end

function Paris_1_Mission_1:BombtheBomb()
  local hLucBombLoc = Util.GetHandleByName("Missions\\paris_1\\mission_1\\depot\\LucMoveTo")
  Nav.MoveToObject(self.hLucTobacc, hLucBombLoc, 1, cMOVE_FAST, "Paris_1_Mission_1.LucSabotage", self, nil, false, true, 2)
  Paris_1_Mission_1.LucCam(self)
end

function Paris_1_Mission_1:LucSabotage()
  Inventory.GiveItem(self.hLucTobacc, "WP_SAB_DynamiteFuse", true)
  local tSaboPt = Object.GetAttrPtAttachments(Util.GetHandleByName(self.sSaboTruck))
  local hSaboPoint = tSaboPt[1]
  Actor.RequestAttrPt(self.hLucTobacc, hSaboPoint)
end

function Paris_1_Mission_1:SetBomb()
  local tSaboPt = Object.GetAttrPtAttachments(Util.GetHandleByName(self.sSaboTruck))
  local hSaboPoint = tSaboPt[1]
  Actor.RequestAttrPt(self.hLucTobacc, hSaboPoint, "Paris_1_Mission_1.LucCam", self)
end

function Paris_1_Mission_1:LucCam()
  Cin.PlayCinematic("CIN_P1M1LucCam")
end

function Paris_1_Mission_1:LucMoveBack()
  local hLucMoveBackLoc = Util.GetHandleByName("Missions\\paris_1\\mission_1\\depot\\LucMoveTo(2)")
  Nav.MoveToObject(self.hLucTobacc, hLucMoveBackLoc, 3, cMOVE_FAST, "Paris_1_Mission_1.GoKabloom", self, nil, false, true, 2)
  self.tSaveInfo.bBriefing = true
  Object.Actuate(Util.GetHandleByName("PARIS\\area01\\garedelest\\nazifueldepot\\wtf_l\\Checkpoint3.0 (Occupation 5m Gate)\\Occ_SecFence_PedGate5m_DoorAnim_R(2)"), true)
  Suspicion.SetEscalationLiteInfinitely(true)
end

function Paris_1_Mission_1:GoKabloom()
end

function Paris_1_Mission_1:ZipSetup()
  self.eZipTut = EVENT_ActorEntersTrigger("Paris_1_Mission_1.PlayTutZip", self, hSab, "Missions\\paris_1\\mission_1\\depot\\PT_PlayZipTut")
  self:RegisterEvent(self.eZipTut)
end

function Paris_1_Mission_1:KillCarListeners()
  if self.eClamberTutBasic then
    Util.KillEvent(self.eClamberTutBasic)
  end
  if self.eDepotEarly then
    Util.KillEvent(self.eDepotEarly)
  end
end

function Paris_1_Mission_1:CallFailureConvo()
  Cin.PlayConversation("P1M1_Car_Damage_Destroyed")
end

function Paris_1_Mission_1:SetupCheckPoint3a()
  self.RegisterCheckpoint(self, "Paris_1_Mission_1.CheckPoint3a")
end

function Paris_1_Mission_1:CheckPoint3a()
  HUD.KeepObjectivesVisible(true)
  Suspicion.EnableEscalationVehicles(false)
  Sound.SetMusicLocale("P1M1_FuelDepot")
  Sound.SetMusicLocale("m_P1M1_FuelDepot", "Silent")
  self:DynoSetup()
  Suspicion.EnableEscalationVehicles(false)
  self:LookoutStream()
  self:DynoEventSetup()
  self:EventSetup()
  self:SetupEscalation()
  self:DynoStreamCheck()
  if Suspicion.GetEscalation() > 0 then
    self:LookoutSkip()
  else
  end
end

function Paris_1_Mission_1:FrenzyCheck()
  self:LucFrenzy()
  Cin.StopCinematic("CIN_P1M1_HarrassCam")
  Cin.AllowAttackingDuringCinematics(false)
  SabTaskObjectiveDeliver.DisableVehControls(self, false)
  self:TASK_StopHarrass()
end

function Paris_1_Mission_1:TASK_StopHarrass()
  self:CreateTask({
    sName = "TASK_StopHarrass",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P1M1_Text.TASK_StopHarrass",
    tTgtInclude = {
      "Missions\\paris_1\\mission_1\\dynoharass\\Spore_Dyno_Harass1",
      "Missions\\paris_1\\mission_1\\dynoharass\\Spore_Dyno_Harass2"
    },
    tOnActivate = {
      {
        Util.QueueTutorial,
        {
          "TutorialTip_Text.Melee_Punch_Title",
          "TutorialTip_Text.Melee_Punch",
          -1,
          true
        }
      },
      {
        self.HarassMusic,
        {self}
      },
      {
        self.FightBack,
        {self}
      }
    },
    tOnComplete = {
      {
        self.EndHarrassMusic,
        {self}
      },
      {
        Util.ClearAllPendingTutorials,
        {}
      },
      {
        Combat.SetCombat,
        {
          self.hLucTobacc,
          false
        }
      },
      {
        self.ResDelay,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:EndHarrassMusic()
  Sound.SetMusicLocale("P1M1_FuelDepot")
  Sound.SetMusicLocale("m_P1M1_FuelDepot", "clambor")
end

function Paris_1_Mission_1:LucAlleyRendevous()
  self:CreateTask({
    sName = "LucAlleyRendevous",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P1M1_Text.TASK_LucTalkieTime",
    tLocators = {
      "Missions\\paris_1\\mission_1\\dynodepot\\LOC_EnterCourtyard"
    },
    tDestRegion = {
      "Missions\\paris_1\\mission_1\\dynodepot\\PT_EnterCourtyard"
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.DynoResCarCheck,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:HarassMusic()
  Sound.SetMusicLocale("P1M1_FuelDepot")
  Sound.SetMusicLocale("m_P1M1_FuelDepot", "stopHarass")
end

function Paris_1_Mission_1:ClearStreamOut()
  if self.eCrateStream then
    Util.KillEvent(self.eCrateStream)
  end
  if self.eHarrassStreamOut then
    Util.KillEvent(self.eHarrassStreamOut)
  end
end

function Paris_1_Mission_1.LucFrenzy()
  local self = Paris_1_Mission_1
  if Actor.IsInVehicle(self.hLucTobacc) then
    Actor.UnboardVehicle(self.hLucTobacc)
    EVENT_ActorExitsAnyVehicle("Paris_1_Mission_1.LucFrenzy2", self, self.hLucTobacc)
  else
    self:LucFrenzy2()
  end
end

function Paris_1_Mission_1:LucFrenzy2()
  Combat.SetReactImmediately(self.hLucTobacc, true)
  Combat.ClearLeader(self.hLucTobacc)
  Combat.SetCombat(self.hLucTobacc, true)
  local tTargetList = {
    self.hHarrass1,
    self.hHarrass2
  }
  Combat.AddTargetFlag(self.hLucTobacc, cTARGET_ENEMYLIST, tTargetList)
end

function Paris_1_Mission_1:LucChill()
  Cin.StopCinematic("CIN_P1M1_DynoClimb")
  self:TASK_Climb2Lookout()
  local hLOC_LucChill = Util.GetHandleByName("Missions\\paris_1\\mission_1\\dynodepot\\LOC_LucChill")
  Nav.MoveToObject(self.hLucTobacc, hLOC_LucChill, 1, true)
end

function Paris_1_Mission_1:ResDelay()
  RewardsManager.SetGlobalAllowCombatHijacking(false)
  Combat.SetIdleScripted(self.hLucTobacc, true)
  local hLucRunTo = Util.GetHandleByName("Missions\\paris_1\\mission_1\\dynodepot\\LOC_LucWait")
  Nav.MoveToObject(self.hLucTobacc, hLucRunTo, 1, true)
  self:YouBetterRun()
  Cin.PlayConversation("P1M1_Civ_Thanks_02")
  if Suspicion.GetEscalation() == 0 then
    self:LucAlleyRendevous()
  else
    self:LookoutSkip()
  end
end

function Paris_1_Mission_1:DynoResCarCheck()
  if Actor.IsInVehicle(hSab) then
    Actor.UnboardVehicle(hSab)
    EVENT_PlayerExitsAnyVehicle("Paris_1_Mission_1.DynoRes", self)
  else
    self:DynoRes()
  end
end

function Paris_1_Mission_1:DynoRes()
  self.PlayTutResArea(self)
  Cin.PlayCinematic("CIN_P1M1_DynoRes", false, "Paris_1_Mission_1.LucChill", self)
  if Actor.IsInVehicle(hSab) then
    Actor.UnboardVehicle(hSab)
  end
end

function Paris_1_Mission_1:ClimbDelay()
  Cin.StopCinematic("CIN_P1M1_DynoRes")
  EVENT_Timer("Paris_1_Mission_1.DynoClimb", self, 2)
end

function Paris_1_Mission_1:DynoClimb()
  Cin.PlayCinematic("CIN_P1M1_DynoClimb", false, "Paris_1_Mission_1.LucChill", self)
end

function Paris_1_Mission_1:TASK_Climb2Lookout()
  self:CreateTask({
    sName = "TASK_Climb2Lookout",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\paris_1\\mission_1\\dynodepot\\PT_ClimbDyno",
    tLocators = {
      "Missions\\paris_1\\mission_1\\dynodepot\\LOC_ClimbDyno"
    },
    tDeliverObjs = {hSab},
    sObjectiveTextID = "P1M1_Text.TASK_Climb2Lookout",
    tOnActivate = {
      {
        self.ClamberTutBasic,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TASK_KillLookout,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:TASK_KillLookout()
  self:CreateTask({
    sName = "TASK_KillLookout",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P1M1_Text.TASK_KillLookout",
    tTgtInclude = {
      self.hLookout
    },
    tOnActivate = {
      {
        Util.QueueTutorial,
        {
          "TutorialTip_Text.Melee_Grab_Title",
          "TutorialTip_Text.Melee_Grab",
          -1,
          true
        }
      },
      {
        self.ClearLookoutStream,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TASK_DropDown,
        {self}
      },
      {
        self.LucAttackPos,
        {self}
      },
      {
        self.OpenGate,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:OpenGate()
  print("Open Gate")
  local hGate = Handle("PARIS\\area01\\portdenismartin\\courtyards\\OccLt_Cage_Door_Z4_Trigger(2)\\CageDoor")
  if hGate then
    Object.ForceOpen(hGate)
  else
    print("ERROR: Failed to get courtyard gate handle")
  end
end

function Paris_1_Mission_1:TASK_DropDown()
  self:CreateTask({
    sName = "TASK_DropDown",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tLocators = {
      "Missions\\paris_1\\mission_1\\dynodepot\\LOC_DropDown"
    },
    tDestRegion = {
      "Missions\\paris_1\\mission_1\\dynodepot\\PT_DynoDropDown"
    },
    tDeliverObjs = {hSab},
    sObjectiveTextID = "P1M1_Text.TASK_DropDown",
    tOnActivate = {
      {
        self.PlayEdgegrabTut,
        {self}
      },
      {
        EVENT_ActorExitsTrigger,
        {
          "Paris_1_Mission_1.DropComplete",
          self,
          hSab,
          "Missions\\paris_1\\mission_1\\dynodepot\\PT_DropSkip"
        }
      }
    },
    tOnComplete = {
      {
        self.TASK_KillGuards,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:DropComplete()
  self:CompleteTaskByName("TASK_DropDown")
end

function Paris_1_Mission_1:PlayEdgegrabTut()
  Util.QueueTutorial("TutorialTip_Text.Edge_Grab_Title", "TutorialTip_Text.Edge_Grab", -1, true)
  Util.EnableTutorial("TutorialTip_Text.Clambering_Drop", true, -1, true)
end

function Paris_1_Mission_1:PlayDropTut()
  Util.QueueTutorial("TutorialTip_Text.Clambering_Drop_Title", "TutorialTip_Text.Clambering_Drop", 15, true)
end

function Paris_1_Mission_1:LucAttackPos()
  if self.eDynoEarly then
    Trigger.DoNotWaitFor(Util.GetHandleByName("Missions\\paris_1\\mission_1\\dynodepot\\PT_DynoRestricted_Early"), hSab)
  end
  Util.ClearAllPendingTutorials()
  self.hDynoGuard1 = Util.GetHandleByName("Missions\\paris_1\\mission_1\\dynodepot\\Spore_Dyno_Guard1")
  self.hDynoGuard2 = Util.GetHandleByName("Missions\\paris_1\\mission_1\\dynodepot\\Spore_Dyno_Guard2")
  Object.SetInvincibleToAI(self.hDynoGuard1, true)
  Object.SetInvincibleToAI(self.hDynoGuard2, true)
  Suspicion.SetWhistleEscalationEnabled(self.hDynoGuard1, false)
  Suspicion.SetWhistleEscalationEnabled(self.hDynoGuard2, false)
  Combat.SetReactImmediately(self.hDynoGuard1, true)
  Combat.SetReactImmediately(self.hDynoGuard2, true)
  local tTargetList = {
    hSab,
    self.hLucTobacc
  }
  Combat.SetCombat(self.hDynoGuard1, true)
  Combat.SetCombat(self.hDynoGuard2, true)
  Combat.AddTargetFlag(self.hDynoGuard1, cTARGET_ENEMYLIST, tTargetList)
  Combat.AddTargetFlag(self.hDynoGuard2, cTARGET_ENEMYLIST, tTargetList)
  local hLocAttack = Util.GetHandleByName("Missions\\paris_1\\mission_1\\dynodepot\\LOC_LucAttack")
  Nav.MoveToObject(self.hLucTobacc, hLocAttack, 1, true, "Paris_1_Mission_1.LucAttack", self)
  if Suspicion.GetEscalation() == 0 then
    Cin.PlayConversation("P1M1_Cache_Fight")
  end
  if self.hHarrass1 then
    Suspicion.SetWhistleEscalationEnabled(self.hHarrass1, true)
  end
  if self.hHarrass2 then
    Suspicion.SetWhistleEscalationEnabled(self.hHarrass2, true)
  end
end

function Paris_1_Mission_1:LucAttack()
  Combat.SetIdleScripted(self.hLucTobacc, false)
  Combat.SetCombat(self.hLucTobacc, true)
  local tTargetList = {
    Util.GetHandleByName("Missions\\paris_1\\mission_1\\dynodepot\\Spore_Dyno_Guard1"),
    Util.GetHandleByName("Missions\\paris_1\\mission_1\\dynodepot\\Spore_Dyno_Guard2")
  }
  Combat.AddTargetFlag(self.hLucTobacc, cTARGET_ENEMYLIST, tTargetList)
end

function Paris_1_Mission_1:TASK_KillGuards()
  self:CreateTask({
    sName = "TASK_KillGuards",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P1M1_Text.TASK_KillGuards",
    tTgtInclude = {
      "Missions\\paris_1\\mission_1\\dynodepot\\Spore_Dyno_Guard1",
      "Missions\\paris_1\\mission_1\\dynodepot\\Spore_Dyno_Guard2"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.SmashCheck,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:SmashCheck()
  Combat.SetLeader(self.hLucTobacc, hSab, false, 5, 5)
  Sound.ResetMusicLocale()
  if Inventory.GetCountOfType(hSab, "WP_SAB_DynamiteFuse") < 1 then
    Cin.PlayConversation("P1M1_Break_Crates")
    self.TASK_Smash(self)
  else
    self.PostDyno(self)
  end
end

function Paris_1_Mission_1:TASK_Smash()
  self:CreateTask({
    sName = "TASK_Smash",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P1M1_Text.TASK_Smash",
    TaskCount = 1,
    tTgtInclude = {
      "Missions\\paris_1\\mission_1\\dynocolby\\Crate_Dynamite_1\\Crate",
      "Missions\\paris_1\\mission_1\\dynocolby\\Crate_Dynamite_2\\Crate"
    },
    tOnActivate = {
      {
        self.CrateTut,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TASK_GetDyno,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:CrateBreak()
  self.eCrateStreamOut = Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForStreamOut = true,
    Objects = {
      "Missions\\paris_1\\mission_1\\dynodepot\\LOC_Dyno"
    }
  }, "Paris_1_Mission_1.CrateStreamCheck", self)
  self:RegisterEvent(self.eCrateStreamOut)
  EVENT_ActorDeath("Paris_1_Mission_1.CrateStream", self, "Missions\\paris_1\\mission_1\\dynocolby\\Crate_Dynamite_1\\Crate")
  EVENT_ActorDeath("Paris_1_Mission_1.CrateStream", self, "Missions\\paris_1\\mission_1\\dynocolby\\Crate_Dynamite_2\\Crate")
end

function Paris_1_Mission_1:CrateStream()
  if self.eCrateStream then
    Util.KillEvent(self.eCrateStream)
  end
  if self.eCrateStreamOut then
    Util.KillEvent(self.eCrateStreamOut)
  end
  self.eCrateStream = EVENT_PlayerToActorProximityNegated("Paris_1_Mission_1.OnSabExplodes", self, "Missions\\paris_1\\mission_1\\dynodepot\\LOC_Dyno", 150)
end

function Paris_1_Mission_1:TASK_GetDyno()
  self:CreateTask({
    sName = "TASK_GetDyno",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Fetch",
    bBlueprintFetch = true,
    sObjectiveTextID = "P1M1_Text.TASK_Smash",
    tDeliverObjs = {
      "WP_SAB_DynamiteFuse"
    },
    tOnComplete = {
      {
        self.PostDyno,
        {self}
      },
      {
        self.ClearStreamOut,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1:PostDyno()
  self.RegisterCheckpoint(self, "Paris_1_Mission_1.CheckPoint3b")
end

function Paris_1_Mission_1:CheckPoint3b()
  Util.EnableRoadsInRegion(false, Util.GetHandleByName("PARIS\\area01\\garedelest\\nazifueldepot\\foliage\\PT_CheckpointRoads"))
  self:SetSabSabListener()
  self.tSaveInfo.bWasted = false
  HUD.KeepObjectivesVisible(true)
  Combat.SetLeader(self.hLucTobacc, hSab, false, 5, 5)
  Util.EnableSidewalksInRegion(false, "Missions\\paris_1\\mission_1\\dynodepot\\PT_CivsOff")
  if Actor.IsInVehicle(hSab) then
  else
    self:CarCacheCheck()
  end
  Util.ClearAllPendingTutorials()
  self.TASK_LucFuelTaxi(self)
  self:EventSetup()
  EVENT_Timer("Paris_1_Mission_1.DynoReminder", self, 5)
  self.bDepConvoDone = false
  self.bDepDriveDone = false
  self.bCheck3Go = false
  self:SetupEscalation()
end

function Paris_1_Mission_1:DynoReminder()
  Cin.PlayConversation("P1M1_Got_Bombs")
  Saboteur.ShowToolTip("TutorialTip_Text.Sprinting", 10)
end

function Paris_1_Mission_1:SetupCheckPoint3c()
  self.RegisterCheckpoint(self, "Paris_1_Mission_1.CheckPoint3c")
end

function Paris_1_Mission_1:CheckPoint3c()
  HUD.KeepObjectivesVisible(true)
  Sound.SetMusicLocale("P1M1_FuelDepot")
  Sound.SetMusicLocale("m_P1M1_FuelDepot", "fuelDepotArrive")
  self:SetSabSabListener()
  self:StreamSaboTruck()
  self:EventSetup()
  self:DropOffConv()
  self:SetupEscalation()
end

function Paris_1_Mission_1:RunListenerCleanup()
  Util.KillEvent(self.hEnterEventID)
end

function Paris_1_Mission_1:LucHitsDoor()
  self:UnloadTaskNodes("TASK_BelleOpenOnTCinematic", true)
  AttractionPt.EnableUse(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\hq_int\\Belle_int_teleport(2)"), false)
end

function Paris_1_Mission_1:MoveLucTowardsBar()
  self = Paris_1_Mission_1
  Nav.SetScriptedPath(self.hLucInt, self.sLucApproachPath, true, "Paris_1_Mission_1.StopLucMoving", self)
end

function Paris_1_Mission_1:StopLucMoving()
  Combat.SetIdleScripted(self.hLucTobacc, true)
end

function Paris_1_Mission_1:TeleportLucIntoPos()
  local hLucTeleLoc = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\LucTeleToLoc")
  local x, y, z = Object.GetPosition(hLucTeleLoc)
  Object.Teleport(self.hLucInt, x, y, z, 0)
end

function Paris_1_Mission_1:SetOffBoom()
  P1M1TransitionMonitor.GoBoom(Actor.GetSelf(hBoomController))
end

function Paris_1_Mission_1:SetupTutorialListener()
  Trigger.WaitFor(self.sTutorialTrigger, hSab, "Paris_1_Mission_1.FireTutorial", self, nil, cTRIGGEREVENT_ONENTER, false)
end

function Paris_1_Mission_1:FireTutorial()
  Util.QueueTutorial("TutorialTip_Text.Sabotage_Inventory_Title", "TutorialTip_Text.Sabotage_Inventory", -1, true)
  Util.EnableTutorial("TutorialTip_Text.Sabotage_Dynamite", true, -1, true)
end

function Paris_1_Mission_1:FinishThisNow()
  Util.EnableRoadsInRegion(true, Util.GetHandleByName("PARIS\\area01\\garedelest\\nazifueldepot\\foliage\\PT_CheckpointRoads"))
  Trigger.Enable("Missions\\paris_1\\mission_1\\depot\\MissionAbandonTrig", false)
  Trigger.Enable(self.sMissionCancelTrig, false)
  Sound.ResetMusicLocale()
  Zone.SwitchState("WtF_Zones\\global\\P1M1_FuelDepot", cZONESTATE_HIGHWTF, cENT_IMMEDIATE)
  Object.SetInvincible(hSab, false)
  Sound.ReleaseSoundBank("m_P1M1_inGame.bnk")
  Util.LoadStaticENTag("fp_amb_p1_radar_07", true)
  Util.LoadStaticENTag("fp_amb_p1_snipernest_03", true)
  Util.LoadStaticENTag("fp_amb_p1_searchlight_15", true)
  Freeplay.UnlockAmbientTag("fp_amb_p1_radar_07", false, false)
  Freeplay.UnlockAmbientTag("fp_amb_p1_snipernest_03", false, false)
  Freeplay.UnlockAmbientTag("fp_amb_p1_searchlight_15", false, false)
  Util.LoadStaticENTag("fueldepot_sidewalks_off", true)
  Util.EnableSidewalksInRegion(true, "Missions\\paris_1\\mission_1\\depot\\PT_SidewalkDisable")
  Util.EnableSidewalksInRegion(true, "Missions\\paris_1\\mission_1\\dynodepot\\PT_CivsOff")
  Util.CancelInteriorLoadCallback("Belle")
  Suspicion.ResetEscalation()
  Cin.StopCinematic("CIN_P1M1_HarrassCam")
  Cin.StopCinematic("CIN_P1M1_HarrassCam_b")
  AttractionPt.EnableUse(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\hq_ext\\Belle_ext_teleport_two"), true)
  AttractionPt.EnableUse(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\hq_int\\Belle_int_teleport(2)"), true)
  HUD.KeepObjectivesVisible(false)
  self:CompleteThisMission()
end

function Paris_1_Mission_1:StreamSaboTruck()
  if self.eTruckStream then
    Util.KillEvent(self.eTruckStream)
  end
  self.eTruckStream = Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForGameObject = true,
    Objects = {
      self.sSaboTruck
    }
  }, "Paris_1_Mission_1.ListenforSaboTruckDeath", self)
  self:RegisterEvent(self.eTruckStream)
end

function Paris_1_Mission_1:ListenforSaboTruckDeath()
  if self.eTruckDeath then
    Util.KillEvent(self.eTruckDeath)
  end
  local hSaboTruck = Util.GetHandleByName(self.sSaboTruck)
  self.eTruckDeath = EVENT_ActorDeath("Paris_1_Mission_1.CueDepotCue", self, hSaboTruck)
  Vehicle.LockAllSeats(hSaboTruck, true)
  Vehicle.SetPinned(hSaboTruck)
  self.eTruckStreamOut = Util.CreateEvent({
    EventType = "StreamEvent",
    WaitForStreamOut = true,
    Objects = {
      self.sSaboTruck
    }
  }, "Paris_1_Mission_1.StreamSaboTruck", self)
  self:RegisterEvent(self.eTruckStreamOut)
end

function Paris_1_Mission_1:CueDepotCue()
  if self.eTruckStreamOut then
    Util.KillEvent(self.eTruckStreamOut)
  end
  EVENT_Timer("Paris_1_Mission_1.PlayDepotCue", self, 1)
end

function Paris_1_Mission_1:PlayDepotCue()
  if self.eFailSafe then
    Util.KillEvent(self.eFailSafe)
  end
  Cin.PlayConversation("P1M1_Depot_Escape")
  Cin.StopCinematic("CIN_P1M1_ClimbCam")
  Cin.StopCinematic("CIN_P1M1LucCam")
  if self.tSaveInfo.bBriefing == false then
    self:GoodStuff()
  elseif self.tSaveInfo.bAssaultGo == false then
    self:TASK_ZipLine()
  end
end

function Paris_1_Mission_1:SetSabSabListener()
  if self.eDynoCount then
    Util.KillEvent(self.eDynoCount)
  end
  if self.eDynoDelete then
    Util.KillEvent(self.eDynoDelete)
  end
  local tOnSabExplodeEvent = {
    EventType = "OnSabotageExplode",
    EventName = "SabEventExplode",
    Target = hSab
  }
  self.eDynoCount = Util.CreateEvent(tOnSabExplodeEvent, "Paris_1_Mission_1.DlayToSabCheck", self)
  self:RegisterEvent(self.eDynoCount)
  local tOnSabDeletedEvent = {
    EventType = "OnSabotageDeleted",
    EventName = "SabDeleted",
    Target = hSab
  }
  self.eDynoDelete = Util.CreateEvent(tOnSabDeletedEvent, "Paris_1_Mission_1.DlayToSabCheck", self)
  self:RegisterEvent(self.eDynoDelete)
end

function Paris_1_Mission_1:DlayToSabCheck()
  EVENT_Timer("Paris_1_Mission_1.OnSabExplodes", self, 1)
end

function Paris_1_Mission_1:OnSabExplodes()
  if self.tSaveInfo.bWasted == false then
    if Inventory.GetCountOfType(hSab, "WP_SAB_DynamiteFuse") < 1 and self.tSaveInfo.bBoombed == false then
      self.tSaveInfo.bWasted = true
      self:MissionTaskFail("P1M1_Text.FailByWastingDynamite")
    elseif self.tSaveInfo.bBoombed == false then
      self:SetSabSabListener()
    end
  end
end
