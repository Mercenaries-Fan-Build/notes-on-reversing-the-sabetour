if P1FP_NaziParty == nil then
  P1FP_NaziParty = SabTaskObjective:Create()
  P1FP_NaziParty.PATH = "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\"
  P1FP_NaziParty:Configure({
    TaskCount = 99,
    tDependencyList = {},
    bFreeplay = true,
    bRepeatable = false,
    sSaveMissionNameID = "MissionNames_Text.P1FP_NazyParty",
    sActNameID = "MissionNames_Text.ACT_FatherDenis",
    sStarter = "Father_Sacre_Interior",
    sConvFile = "P1FP_NaziParty_Start",
    tSMEDNodes = {
      P1FP_NaziParty.PATH .. "main"
    },
    tStaticTags = {}
  })
end

function P1FP_NaziParty:STARTER_Setup()
end

function P1FP_NaziParty:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "NAZIPARTY"
  self.bDebugMode = false
  Suspicion.SetEscalationCap(2)
  self.GENERAL_Setup(self)
  self:RegisterCheckpoint("P1FP_NaziParty.Checkpoint1")
end

function P1FP_NaziParty.SetupGamepadListener()
  local self = P1FP_NaziParty
  self.tControllerEvent = {
    EventType = "OnButtonPress",
    Target = Handle("Saboteur")
  }
  local eButtonEvent = Util.CreateEvent(self.tControllerEvent, "P1FP_NaziParty.OnButtonPress", self, {}, true)
  self:RegisterEvent(eButtonEvent)
end

function P1FP_NaziParty:OnButtonPress(a_tButtonData)
  local self = P1FP_NaziParty
  local tButtons = a_tButtonData[1]
  if tButtons.UP == true then
  elseif tButtons.DOWN == true then
  elseif tButtons.X == true then
  elseif tButtons.B == true then
  end
end

function P1FP_NaziParty:ArmSelf()
  Inventory.GiveItem(hSab, "WP_SH_12GaugePump", false)
  Inventory.GiveItem(hSab, "WP_MG_Thompson_ExtMag", false)
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

function P1FP_NaziParty:Teleporter()
  Object.PlayerTeleportToLocator(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_MissionArea"))
end

function P1FP_NaziParty:GENERAL_Setup()
  self:AddOnCancelCallback(P1FP_NaziParty.OnCancel)
  self:AddOnCompleteCallback(P1FP_NaziParty.OnComplete)
  Sound.LoadSoundBank("m_fp_nz_wedding.bnk")
  Util.SetTime(13, 0)
  self.sPriest = self.PATH .. "humans\\Priest"
  self.sBride = self.PATH .. "humans\\Kiddo"
  self.sTarget = self.PATH .. "humans\\Target"
  self.tCeremony = {
    self.PATH .. "humans\\Priest",
    self.PATH .. "humans\\Kiddo",
    self.PATH .. "humans\\Target"
  }
  self.tInfo.tBrideParty = {
    self.PATH .. "humans\\Guest1",
    self.PATH .. "humans\\Guest2",
    self.PATH .. "humans\\Guest3",
    self.PATH .. "humans\\Guest4",
    self.PATH .. "humans\\Guest5",
    self.PATH .. "humans\\Guest6"
  }
  self.tInfo.tCivs = {
    self.PATH .. "humans\\Guest1",
    self.PATH .. "humans\\Guest2",
    self.PATH .. "humans\\Guest3",
    self.PATH .. "humans\\Guest4",
    self.PATH .. "humans\\Guest5",
    self.PATH .. "humans\\Guest6",
    self.PATH .. "humans\\Priest",
    self.PATH .. "humans\\Kiddo"
  }
  self.tInfo.tGroomParty = {
    self.PATH .. "humans\\NaziGuest1",
    self.PATH .. "humans\\NaziGuest2",
    self.PATH .. "humans\\NaziGuest3",
    self.PATH .. "humans\\NaziGuest4",
    self.PATH .. "humans\\NaziGuest5",
    self.PATH .. "humans\\NaziGuest6"
  }
  self.tDisapproveAnims = {
    "Shrd_reaction_b",
    "conv_Angry_pissed",
    "conv_Angry_pissoff",
    "conv_angry_WTF"
  }
  self.tApproveAnims = {}
  self.tHideSpots = {
    "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_HideArea_Old",
    "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_HideArea",
    "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_HideFar"
  }
  self.tInfo.NaziSquad = {
    self.PATH .. "retribution\\SmBridge_Heavy_MG_01",
    self.PATH .. "retribution\\SmBridge_Heavy_MG_02",
    self.PATH .. "retribution\\SmBridge_Grunt_RF_01",
    self.PATH .. "retribution\\SmBridge_Grunt_RF_02",
    self.PATH .. "retribution\\SmBridge_Grunt_RF_03"
  }
  self.tInfo.AllAttrPts = {
    self.PATH .. "humans\\AttractionPT_G01",
    self.PATH .. "humans\\AttractionPT_G01",
    self.PATH .. "humans\\AttractionPT_G02",
    self.PATH .. "humans\\AttractionPT_G03",
    self.PATH .. "humans\\AttractionPT_G04",
    self.PATH .. "humans\\AttractionPT_G05",
    self.PATH .. "humans\\AttractionPT_G06",
    self.PATH .. "humans\\AttractionPT_N01",
    self.PATH .. "humans\\AttractionPT_N02",
    self.PATH .. "humans\\AttractionPT_N03",
    self.PATH .. "humans\\AttractionPT_N04",
    self.PATH .. "humans\\AttractionPT_N05",
    self.PATH .. "humans\\AttractionPT_N06"
  }
end

function P1FP_NaziParty:OnComplete()
  Sound.ReleaseSoundBank("m_fp_nz_wedding.bnk")
  Nav.MoveToObject(self.hPriest, Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_SmBridgeAttack2"), 5)
  Nav.MoveToObject(self.hBride, Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_SmBridgeAttack2"), 5)
  for i = 1, #self.tInfo.tBrideParty do
    local hCiv = Util.GetHandleByName(self.tInfo.tBrideParty[i])
    if Actor.IsAlive(hCiv) == true then
      Nav.MoveToObject(hCiv, Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_SmBridgeAttack2"), 5)
    end
  end
end

function P1FP_NaziParty:OnCancel()
  Sound.ReleaseSoundBank("m_fp_nz_wedding.bnk")
  HUD.RemoveObjectiveMarker(self.hPriest)
  RewardsManager.ShowStarter("Father_Sacre_Interior")
  Zone.SwitchState("WtF_Zones\\global\\FP_NaziParty", cZONESTATE_LOWWTF, cENT_IMMEDIATE)
end

function P1FP_NaziParty:NearMissionVO()
  Cin.PlayConversation("P1FP_NaziParty_EasyRoute")
end

function P1FP_NaziParty:FatherSaysVows()
  Actor.PlayAnimation(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\humans\\Guest1"), "conv_F_concern", -1, true)
  Actor.PlayAnimation(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\humans\\Guest5"), "conv_F_disagree", -1, true)
  Actor.PlayAnimation(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\humans\\Guest2"), "civ_m_sit_face_in_hands", -1, true)
  EVENT_Timer("P1FP_NaziParty.PlayDenisVO3", self, 3)
end

function P1FP_NaziParty:PlayDenisVO3()
  if Suspicion.GetEscalation() == 0 and not Suspicion.IsEscalatedLite() then
    Cin.PlayConversation("P1FP_NaziParty_Wedding_03", "P1FP_NaziParty.WaitForVO4", self)
  end
end

function P1FP_NaziParty:WaitForVO4()
  EVENT_Timer("P1FP_NaziParty.PlayDenisVO4", self, 3)
end

function P1FP_NaziParty:PlayDenisVO4()
  if Suspicion.GetEscalation() == 0 and not Suspicion.IsEscalatedLite() then
    Cin.PlayConversation("P1FP_NaziParty_Wedding_04", "P1FP_NaziParty.MarriageFail", self)
  end
end

function P1FP_NaziParty:InitBrideCrowd()
  if Suspicion.GetEscalation() == 0 then
    for i, v in ipairs(self.tInfo.tBrideParty) do
      Actor.UseAttrPt(Handle(self.tInfo.tBrideParty[i]), Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\humans\\AttractionPT_G0" .. i))
      Actor.SetPanicWalkAwayEnabled(Handle(self.tInfo.tBrideParty[i]), true)
    end
  else
    for i, v in ipairs(self.tInfo.tBrideParty) do
      local hActor = Util.GetHandleByName(v)
      Actor.CancelAttrPt(hActor)
      Actor.CancelAnimation(hActor)
      Combat.SetIdleScripted(hActor, false)
      Actor.SetPanicEnabled(hActor, true)
    end
  end
end

function P1FP_NaziParty:InitGroomCrowd()
  for i, v in ipairs(self.tInfo.tGroomParty) do
    Inventory.GiveItem(Handle(self.tInfo.tGroomParty[i]), "WP_PS_Luger", false)
  end
  if Suspicion.GetEscalation() == 0 then
    for i, v in ipairs(self.tInfo.tGroomParty) do
      Actor.UseAttrPt(Handle(self.tInfo.tGroomParty[i]), Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\humans\\AttractionPT_N0" .. i))
    end
  end
  self.InitBrideCrowd(self)
end

function P1FP_NaziParty:Checkpoint1()
  dprint(self, "Registered: CHECKPOINT 1")
  self:Task_GoToMission()
  self:PrepCheckpt2()
  Render.WTFSetOverrideBlueprint("WillToFight_SacreCoeur_HWTF")
  Util.EnableRoadsInRegion(false, Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\PT_DisableAIRoad"))
end

function P1FP_NaziParty:PrepCheckpt2()
  EVENT_PlayerToActorProximity("P1FP_NaziParty.RegisterCheckpt2", self, "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_ExitSacreCouer", 10)
end

function P1FP_NaziParty:RegisterCheckpt2()
  self:RegisterCheckpoint("P1FP_NaziParty.Checkpoint2")
end

function P1FP_NaziParty:Checkpoint2()
  dprint(self, "Registered: CHECKPOINT 2")
  Util.EnableRoadsInRegion(false, Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\PT_DisableAIRoad"))
  RewardsManager.HideStarter("Father_Sacre_Interior")
  self.bEscalatedOnsite = false
  if not self:IsMissionTaskActive("P1FP_NaziParty.Task_GoToMission") then
    self.Task_GoToMission(self)
  end
end

function P1FP_NaziParty:Task_GoToMission()
  self:CreateTask({
    sName = "Task_GoToMission",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "P1FP_NaziParty_Text.Task_GoToMission",
    tLocators = {
      "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_MissionArea"
    },
    tDestRegion = "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\PT_MissionArea",
    sTaskSubType = "DELIVER",
    tDeliverObjs = {hSab},
    bGroundBlip = true,
    sTaskEndConv = "P1FP_NaziParty_NoCivs",
    tOnComplete = {
      {
        HUD.ClearGPSTarget,
        {}
      },
      {
        self.BrakeCar,
        {self}
      },
      {
        self.Task_GoToGazebo,
        {self}
      }
    }
  })
end

function P1FP_NaziParty:BrakeCar()
  local hSabCar = Actor.GetVehicle(hSab)
  if hSabCar then
    SabTaskObjectiveDeliver.StopVehicle(self, hSabCar)
  end
  EVENT_Timer("P1FP_NaziParty.UnBrakeCar", self, 1)
end

function P1FP_NaziParty:UnBrakeCar()
  local hSabCar = Actor.GetVehicle(hSab)
  if hSabCar then
    SabTaskObjectiveDeliver.ReleaseVehicle(self, hSabCar)
  end
end

function P1FP_NaziParty:Task_GoToGazebo()
  self:CreateTask({
    sName = "Task_GoToGazebo",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "P1FP_NaziParty_Text.Task_GoToGazebo",
    tLocators = {
      "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_GazeboArea"
    },
    tDestRegion = "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\PT_GazeboArea",
    sTaskSubType = "DELIVER",
    tDeliverObjs = {hSab},
    bNoGPS = true,
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "P1FP_NaziParty.Checkpoint3"
        }
      }
    }
  })
end

function P1FP_NaziParty:Checkpoint3()
  dprint(self, "Registered: CHECKPOINT 3")
  Util.EnableRoadsInRegion(false, Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\PT_DisableAIRoad"))
  local tCivDeath = {
    EventType = "Civilian.OnDeath"
  }
  local eStaticCivDeath = Util.CreateEvent(tCivDeath, "P1FP_NaziParty.OnCivDeath", self, {}, true)
  self:RegisterEvent(eStaticCivDeath)
  self.bCutComplete = false
  self.bRetriCutComplete = false
  self:TASK_HideMe()
end

function P1FP_NaziParty:WasCheckpoint3()
  Util.KillEvent(self.eHide1)
  Util.KillEvent(self.eHide2)
  Util.KillEvent(self.eHide3)
  OffStaticConversationDisables()
  self:BlipDenis()
  self:FatherSaysVows()
  self.bCutComplete = true
  self.sTrocGate = "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\wtf_low\\OccMed_Checkpoint_Gate_A\\OccMed_Checkpoint_Gate_A(1)"
  self.TASK_KillGeneral(self)
end

function P1FP_NaziParty:TurnOffRadio()
  dprint(self, "Escalated. Switching to LOSE HEAT task")
  Util.KillEvent(self.eHide1)
  Util.KillEvent(self.eHide2)
  Util.KillEvent(self.eHide3)
  self:ResetTaskByName("P1FP_NaziParty.TASK_HideMe", true)
  self:TASK_LoseEscalation()
end

function P1FP_NaziParty:TASK_LoseEscalation()
  self:CreateTask({
    sName = "P1FP_NaziParty.TASK_LoseEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    EscalationLevel = 0,
    bRepeatable = true,
    bNoRepeatAutoRebuild = true,
    tOnComplete = {
      {
        self.SetupFreezePlayer,
        {self}
      },
      {
        self.KillEscEvent,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function P1FP_NaziParty:KillEscEvent()
  Util.KillEvent(self.eEscDetect)
  self:TASK_HideMe()
end

function P1FP_NaziParty:KillEscEvent2()
  Util.KillEvent(self.eEscDetect)
end

function P1FP_NaziParty:EscalationListener()
  dprint(self, "Setting Escalation Listener  - clear Esc to get Task_HideMe")
  self.eEscDetect = EVENT_OnEscalation("P1FP_NaziParty.TurnOffRadio", self, nil, false)
end

function P1FP_NaziParty:TASK_HideMe()
  self:CreateTask({
    sName = "P1FP_NaziParty.TASK_HideMe",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "deliver",
    sObjectiveTextID = "P1FP_NaziParty_Text.TASK_HideMe",
    tDestProximityObj = {
      "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_HideArea",
      "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_HideFar",
      "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_HideArea_Old"
    },
    Proximity = 1,
    TaskCount = 1,
    MarkerHeight = 3,
    tDeliverObjs = {hSab},
    bNoGPS = true,
    tSMEDNodes = {
      P1FP_NaziParty.PATH .. "sound"
    },
    tOnActivate = {
      {
        self.EscalationListener,
        {self}
      },
      {
        self.SetupFreezePlayer,
        {self}
      },
      {
        self.PlayCivTip,
        {self}
      }
    },
    tOnComplete = {
      {
        self.PrepFadeDownUp1,
        {self}
      },
      {
        self.KillEscEvent2,
        {self}
      }
    }
  })
end

function P1FP_NaziParty:PlayCivTip()
  EVENT_Timer("P1FP_NaziParty.PlayCivTip2", self, 3)
end

function P1FP_NaziParty:PlayCivTip2()
  Saboteur.ShowToolTip("P1FP_NaziParty_Text.TIP_NoKillCivs")
end

function P1FP_NaziParty:SetupFreezePlayer()
  self.eHide1 = EVENT_PlayerToActorProximity("P1FP_NaziParty.FreezePlayer", self, "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_HideArea", 1)
  self.eHide2 = EVENT_PlayerToActorProximity("P1FP_NaziParty.FreezePlayer2", self, "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_HideFar", 1)
  self.eHide3 = EVENT_PlayerToActorProximity("P1FP_NaziParty.FreezePlayer3", self, "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_HideArea_Old", 1)
end

function P1FP_NaziParty:FreezePlayer()
  if Suspicion.GetEscalation() == 0 then
    self.nHideLocation = 1
    OnStaticConversationDisables()
  end
end

function P1FP_NaziParty:FreezePlayer2()
  if Suspicion.GetEscalation() == 0 then
    self.nHideLocation = 2
    OnStaticConversationDisables()
  end
end

function P1FP_NaziParty:FreezePlayer3()
  if Suspicion.GetEscalation() == 0 then
    self.nHideLocation = 3
    OnStaticConversationDisables()
  end
end

function P1FP_NaziParty:ArrivalCinSit()
  self = P1FP_NaziParty
  if self.nHideLocation == 1 then
    Actor.UseAttrPt(hSab, Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\CrouchPt"))
  elseif self.nHideLocation == 2 then
    Actor.UseAttrPt(hSab, Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\CrouchPt_2"))
  elseif self.nHideLocation == 3 then
    Actor.UseAttrPt(hSab, Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\CrouchPt_3"))
  end
end

function P1FP_NaziParty:PrepFadeDownUp1()
  self.ArrivalCinSit(self)
  EVENT_Timer("P1FP_NaziParty.PrepFadeDownUp2", self, 3)
end

function P1FP_NaziParty:PrepFadeDownUp2()
  Render.FadeTo(0, 0, 0, 255, 1)
  self.ArrivalCin(self)
end

function P1FP_NaziParty:ArrivalCin()
  self:CreateTask({
    sName = "P1FP_NaziParty.ArrivalCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "CIN_NaziWedding_Arrival",
    tSMEDNodes = {
      P1FP_NaziParty.PATH .. "humans"
    },
    tStaticTags = {},
    tOnActivate = {
      {
        self.BeginArrivalCin,
        {self}
      },
      {
        self.InitGroomCrowd,
        {self}
      },
      {
        self.LoadBenches,
        {self}
      },
      {
        EVENT_Timer,
        {
          "P1FP_NaziParty.Sound1",
          self,
          5
        }
      }
    },
    tOnComplete = {
      {
        self.WasCheckpoint3,
        {self}
      },
      {
        ClearAllDisableControls,
        {}
      }
    }
  })
end

function P1FP_NaziParty:LoadBenches()
  Util.LoadStaticENTag("p1fp_naziwedding_hidebenches", true)
end

function P1FP_NaziParty:BlipDenis()
  HUD.SetObjectiveMarker(self.hPriest, cMMI_MissionGiver, cOM_MissionGiver, true, false, true)
end

function P1FP_NaziParty:BeginArrivalCin()
  self.hPriest = Handle(self.PATH .. "humans\\Priest")
  self.hTarget = Handle(self.PATH .. "humans\\Target")
  self.hBride = Handle(self.PATH .. "humans\\Kiddo")
  Actor.SetAnimPriority(self.hPriest, 16)
  Actor.SetAnimPriority(self.hTarget, 16)
  Actor.SetAnimPriority(self.hBride, 16)
  Actor.SetStuckBashEnabled(self.hTarget, false)
  Sound.ActivateSoundEmitter(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\sound\\Emt_Nz_Wedding_Gramophone"))
  Sound.ActivateSoundEmitter(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\sound\\Emt_P1FP_Wedding_Audience"))
  Sound.ActivateSoundEmitter(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\sound\\Emt_P1FP_Wedding_Audience(1)"))
  Sound.ActivateSoundEmitter(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\sound\\Emt_P1FP_Wedding_Girl"))
  Sound.ActivateSoundEmitter(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\sound\\Emt_P1FP_Wedding_Girl(1)"))
  self.tInfo.tCivilians = {
    Handle(self.PATH .. "humans\\Guest1"),
    Handle(self.PATH .. "humans\\Guest2"),
    Handle(self.PATH .. "humans\\Guest3"),
    Handle(self.PATH .. "humans\\Guest4"),
    Handle(self.PATH .. "humans\\Guest5"),
    Handle(self.PATH .. "humans\\Guest6"),
    self.hBride,
    self.hPriest
  }
  self.tInfo.tAllNazis = {
    Handle(self.PATH .. "humans\\NaziGuest1"),
    Handle(self.PATH .. "humans\\NaziGuest2"),
    Handle(self.PATH .. "humans\\NaziGuest3"),
    Handle(self.PATH .. "humans\\NaziGuest4"),
    Handle(self.PATH .. "humans\\NaziGuest5"),
    Handle(self.PATH .. "humans\\NaziGuest6"),
    self.hTarget
  }
  Combat.SetIdleScripted(self.hPriest, true)
  Combat.SetIdleScripted(self.hTarget, true)
  self:GoBowAndScare()
end

function P1FP_NaziParty:TASK_KillGeneral()
  self:CreateTask({
    sName = "P1FP_NaziParty.TASK_KillGeneral",
    sTaskType = "SabTaskObjectiveDestroy",
    sObjectiveTextID = "P1FP_NaziParty_Text.TASK_KillGeneral",
    sTaskSubType = "KILL",
    tTgtInclude = self.tInfo.tAllNazis,
    tSMEDNodes = {
      P1FP_NaziParty.PATH .. "retribution"
    },
    tOnActivate = {
      {
        self.VehiclesIn,
        {self}
      },
      {
        EVENT_OnEscalationLite,
        {
          "P1FP_NaziParty.OnEscalation",
          self,
          nil
        }
      },
      {
        EVENT_ActorDamaged,
        {
          "P1FP_NaziParty.OnEscalation",
          self,
          self.hTarget
        }
      },
      {
        EVENT_ActorDeath,
        {
          "P1FP_NaziParty.OnEscalation",
          self,
          self.hTarget
        }
      }
    },
    tOnComplete = {
      {
        self.CompleteVODelay,
        {self}
      },
      {
        self.ResetSound,
        {self}
      }
    }
  })
end

function P1FP_NaziParty:VehiclesIn()
  Util.SetDynamicPriority("VH_NZ_CR_6WheelNaziLimo_01", 500)
  Util.SetDynamicPriority("VH_OP_Citroen_Gestapo", 500)
  Util.SetDynamicPriority("VH_CV_CR_Peugeot402_01", 500)
end

function P1FP_NaziParty:RetributionCin()
  Util.EnableRoadsInRegion(false, Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\PT_DisableAIRoad"))
  self:CreateTask({
    sName = "P1FP_NaziParty.RetributionCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "WTF_FP_NaziWedding",
    tOnActivate = {
      {
        self.OpenGate,
        {self}
      }
    },
    tOnComplete = {
      {
        self.CleanUpRetriCut,
        {self}
      }
    }
  })
end

function P1FP_NaziParty:RetributionCinFar()
  Util.EnableRoadsInRegion(false, Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\PT_DisableAIRoad"))
  self:CreateTask({
    sName = "P1FP_NaziParty.RetributionCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "WTF_FP_NaziWedding_NOCAM",
    tOnActivate = {
      {
        self.OpenGate,
        {self}
      }
    },
    tOnComplete = {
      {
        self.CleanUpRetriCut,
        {self}
      }
    }
  })
end

function P1FP_NaziParty:CleanUpRetriCut()
  if self.bRetriCutComplete == false then
    Nav.CancelScriptedPath(self.hKubel)
    Nav.CancelScriptedPath(self.hTruck)
    Object.Teleport(self.hKubel, 1034.0386, 93.34787, -434.72324, 180)
    Object.Teleport(self.hTruck, 1034.4662, 93.34787, -441.81754, 180)
    self.UnloadTruck(self)
    self.UnloadKubel(self)
  end
  self.AfterRetriCin(self)
end

function P1FP_NaziParty:CompleteVODelay()
  EVENT_Timer("P1FP_NaziParty.CompleteVO", self, 1)
end

function P1FP_NaziParty:CompleteVO()
  local bKilledCiv = false
  for i = 1, #self.tInfo.tCivs do
    local hCiv = Util.GetHandleByName(self.tInfo.tCivs[i])
    if Object.IsAlive(hCiv) ~= true then
      bKilledCiv = true
      break
    end
  end
  if bKilledCiv == false then
    Cin.PlayConversation("P1FP_NaziParty_Complete", "P1FP_NaziParty.SetCheckpoint4", self)
  else
    EVENT_Timer("P1FP_NaziParty.FailCivKilled", self, 1.5)
  end
end

function P1FP_NaziParty:SetCheckpoint4()
  self.RegisterCheckpoint(self, "P1FP_NaziParty.CinTest")
end

function P1FP_NaziParty:CinTest()
  print("__Checkpoint P1FP_NaziParty.CinTest ")
  self.bRetriCutComplete = false
  if Cin.IsPlayerCloseToCinematic("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_HideArea_Old") then
    self:RetributionCin()
  else
    self:RetributionCinFar()
  end
end

function P1FP_NaziParty:OpenGate()
  self.hTrocGate = Handle(self.sTrocGate)
  Object.Actuate(self.hTrocGate)
end

function P1FP_NaziParty:AfterRetriCin()
  dprint(self, "Registered: CHECKPOINT 4")
  self:ReleaseFatherDenis()
  EVENT_PlayerEntersTrigger("P1FP_NaziParty.LgBridgeAtk", self, "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\PT_LgBridgeAtk", false)
  EVENT_PlayerEntersTrigger("P1FP_NaziParty.SmBridgeAtk", self, "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\PT_SmBridgeAtk", false)
  self.TASK_EscapeTheRetribution(self)
end

function P1FP_NaziParty:TASK_EscapeTheRetribution()
  self:CreateTask({
    sName = "P1FP_NaziParty.TASK_EscapeTheRetribution",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "P1FP_NaziParty_Text.TASK_EscapeTheRetribution",
    EscalationLevel = 0,
    tOnComplete = {
      {
        Suspicion.SetEscalationCap,
        {-1}
      },
      {
        self.CompleteThisMission,
        {self}
      }
    },
    tOnActivate = {
      {
        Suspicion.SetEscalationLevel,
        {2}
      }
    }
  })
end

function P1FP_NaziParty:GoRetribution()
  local self = P1FP_NaziParty
  local tOpelGuys = {
    Pilot = "Human_SS_Heavy_MG",
    Shotgun = "Human_SS_Heavy_MG",
    Passengers = {
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG"
    }
  }
  local tKubelGuys = {
    Pilot = "Human_SS_Heavy_MG",
    Shotgun = "Human_SS_Heavy_MG",
    Passengers = {
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG"
    }
  }
  Veh.SafeSpawnAtObj(cVEH_OPEL, self.PATH .. "main\\LOC_SpawnOpel", tOpelGuys, true, self.GoOpel, self, {})
  Veh.SafeSpawnAtObj(cVEH_KUBEL, self.PATH .. "main\\LOC_SpawnKubel", tKubelGuys, true, self.GoKubel, self, {})
  self.tSeatList = {
    "PILOT",
    "SHOTGUN",
    "BACK_LEFT_END",
    "BACK_LEFT_MIDDLE",
    "BACK_RIGHT_END",
    "BACK_RIGHT_MIDDLE"
  }
  self.tKubelSeatList = {
    "PILOT",
    "SHOTGUN",
    "BACKSEAT_L",
    "BACKSEAT_R"
  }
end

function P1FP_NaziParty:GoOpel(a_hTruck)
  self.hTruck = a_hTruck
  Nav.SetScriptedPath(self.hTruck, "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\PATH_TR_FrontGate", false, "P1FP_NaziParty.UnloadTruck", self)
  Nav.SetScriptedPathSpeed(self.hTruck, 70)
end

function P1FP_NaziParty:GoKubel(a_hKubel)
  self.hKubel = a_hKubel
  Nav.SetScriptedPath(self.hKubel, "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\PATH_KubelFG", false, "P1FP_NaziParty.UnloadKubel", self)
  Nav.SetScriptedPathSpeed(self.hKubel, 90)
  self.GoSmBrNazis(self)
end

function P1FP_NaziParty:GoSmBrNazis()
  Combat.SetIdleScripted(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\retribution\\SmBridge_Heavy_MG_01"), true)
  Combat.SetIdleScripted(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\retribution\\SmBridge_Heavy_MG_02"), true)
  Combat.SetIdleScripted(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\retribution\\SmBridge_Grunt_RF_01"), true)
  Combat.SetIdleScripted(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\retribution\\SmBridge_Grunt_RF_02"), true)
  Combat.SetIdleScripted(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\retribution\\SmBridge_Grunt_RF_03"), true)
  Nav.MoveToObject(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\retribution\\SmBridge_Heavy_MG_01"), Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_SmBridgeAttack"), 5, true)
  Nav.MoveToObject(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\retribution\\SmBridge_Heavy_MG_02"), Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_SmBridgeAttack_02"), 5, true)
  Nav.MoveToObject(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\retribution\\SmBridge_Grunt_RF_01"), Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_SmBridgeAttack_03"), 5, true)
  Nav.MoveToObject(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\retribution\\SmBridge_Grunt_RF_02"), Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_SmBridgeAttack_05"), 5, true)
  Nav.MoveToObject(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\retribution\\SmBridge_Grunt_RF_03"), Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_SmBridgeAttack_04"), 5, true, "P1FP_NaziParty.KeepGoingSmBrNs", self, {})
end

function P1FP_NaziParty:KeepGoingSmBrNs()
  Combat.SetObjective(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\retribution\\SmBridge_Heavy_MG_01"), hSab, false, 15, false)
  Combat.SetObjective(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\retribution\\SmBridge_Heavy_MG_02"), hSab, false, 15, false)
  Combat.SetObjective(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\retribution\\SmBridge_Grunt_RF_01"), hSab, false, 15, false)
  Combat.SetObjective(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\retribution\\SmBridge_Grunt_RF_02"), hSab, false, 15, false)
  Combat.SetObjective(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\retribution\\SmBridge_Grunt_RF_03"), hSab, false, 15, false)
end

function P1FP_NaziParty:CollectTrPassengers()
  self.tTruckPassengers = {}
  for i = 1, #self.tSeatList do
    self.tTruckPassengers[i] = Vehicle.GetActorInSeat(self.hTruck, self.tSeatList[i])
    Inventory.GiveItem(self.tTruckPassengers[i], "WP_GR_StickGrenade", false)
  end
end

function P1FP_NaziParty:UnloadTruck()
  self:CollectTrPassengers()
  Vehicle.UnboardAll(self.hTruck, false, nil, nil, nil, "P1FP_NaziParty.TruckUnloaded", self)
end

function P1FP_NaziParty:TruckUnloaded()
  for i = 1, #self.tTruckPassengers do
    Combat.SetTarget(self.tTruckPassengers[i], hSab)
    Combat.SetCombat(self.tTruckPassengers[i])
  end
end

function P1FP_NaziParty:CollectKbPassengers()
  self.tKubelPassengers = {}
  for i = 1, #self.tKubelSeatList do
    self.tKubelPassengers[i] = Vehicle.GetActorInSeat(self.hKubel, self.tKubelSeatList[i])
  end
end

function P1FP_NaziParty:UnloadKubel()
  self:CollectKbPassengers()
  Vehicle.UnboardAll(self.hKubel, false, nil, nil, nil, "P1FP_NaziParty.KubelUnloaded", self)
end

function P1FP_NaziParty:KubelUnloaded()
  for i = 1, #self.tKubelPassengers do
    Combat.SetTarget(self.tKubelPassengers[i], hSab)
    Combat.SetCombat(self.tKubelPassengers[i])
  end
  self.bRetriCutComplete = true
end

function P1FP_NaziParty:LgBridgeAtk()
  self.tAPCConfig = {
    Pilot = "Human_WM_Grunt_MG",
    Shotgun = "Human_WM_Grunt_MG",
    Gunner = "Human_WM_Grunt_MG",
    Passengers = {
      "Human_WM_Grunt_MG",
      "Human_WM_Grunt_MG",
      "Human_WM_Grunt_MG",
      "Human_WM_Grunt_MG",
      "Human_WM_Grunt_MG",
      "Human_WM_Grunt_MG"
    }
  }
  Veh.SafeSpawnAtObj(cVEH_HALFTRACK, "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_SpawnAPC", self.tAPCConfig, true, self.GoAPC, self, {})
end

function P1FP_NaziParty:GoAPC(a_hAPC)
  self.tAPCSeatList = {
    "PILOT",
    "SHOTGUN",
    "REAR_R1",
    "REAR_R2",
    "REAR_R3",
    "REAR_L1",
    "REAR_L2",
    "REAR_L3",
    "GUNNER"
  }
  self.hAPC = a_hAPC
  self:CollectAPCPassengers()
  Nav.SetScriptedPath(self.hAPC, "Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\PATH_GoAPC", false, "P1FP_NaziParty.UnloadAPC", self)
  Nav.SetScriptedPathSpeed(self.hAPC, 40)
end

function P1FP_NaziParty:CollectAPCPassengers()
  self.tAPCPassengers = {}
  for i = 1, #self.tAPCSeatList do
    self.tAPCPassengers[i] = Vehicle.GetActorInSeat(self.hAPC, self.tAPCSeatList[i])
    Inventory.GiveItem(self.tAPCPassengers[i], "WP_GR_StickGrenade", false)
  end
end

function P1FP_NaziParty:UnloadAPC()
  Vehicle.UnboardAll(self.hAPC, false, "P1FP_NaziParty.APCUnloaded", self, {}, nil, nil, nil)
end

function P1FP_NaziParty:APCUnloaded(a_hAPCguy)
  local hGuy = a_hAPCguy[1]
  Combat.SetObjective(hGuy, hSab, false, 20, false)
  EVENT_PlayerToActorProximity("P1FP_NaziParty.GuyThrowGrenade", self, hGuy, 20, {hGuy}, false)
end

function P1FP_NaziParty:GuyThrowGrenade(a_hGuy)
  local hGuy = a_hGuy
  Combat.ThrowGrenade(hGuy)
end

function P1FP_NaziParty:SmBridgeAtk()
  Util.SpawnEditNode("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\wave2_smbr.wsd", "P1FP_NaziParty.SmBridgeAtkGo", self)
end

function P1FP_NaziParty:SmBridgeAtkGo()
  Combat.SetObjective(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\wave2_smbr\\Spore_WNZ_Grunt_RF(3)"), Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_SmBridgeAttack2"), false, 10, false)
  Combat.SetObjective(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\wave2_smbr\\Spore_WNZ_Grunt_RF"), Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_SmBridgeAttack2"), false, 15, false)
  Combat.SetObjective(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\wave2_smbr\\Spore_WNZ_Grunt_RF(1)"), Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_SmBridgeAttack2"), false, 20, false)
  Combat.SetObjective(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\wave2_smbr\\Spore_WNZ_Heavy_MG"), Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_SmBridgeAttack2"), false, 25, false)
  Combat.SetObjective(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\wave2_smbr\\Spore_WNZ_Heavy_MG(1)"), Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_SmBridgeAttack2"), false, 30, false)
end

function P1FP_NaziParty:PlayGroupAnimation(a_tGroup, a_tAnimations)
  for i, hActor in ipairs(a_tGroup) do
    if Object.IsAlive(hActor) == true then
      local nDelay = math.random()
      local tSeq = {
        {
          "DELAY",
          {nDelay}
        },
        {
          "PLAYANIMATION",
          {
            Tips.GetRandomElement(a_tAnimations)
          }
        }
      }
      ScriptSequence.Run(hActor, tSeq)
    end
  end
end

function P1FP_NaziParty:BowAndScare()
  EVENT_Stream("P1FP_NaziParty.GoBowAndScare", self, self.tCeremony, true)
end

function P1FP_NaziParty:GoBowAndScare()
  local tPriestSeq = {
    {
      "PLAYANIMATION",
      {
        "conv_Polite_politegesture"
      }
    },
    {
      "DELAY",
      {2}
    },
    {
      "PLAYANIMATION",
      {
        "conv_Polite_headnod"
      }
    },
    {
      "DELAY",
      {2}
    },
    {
      "PLAYANIMATION",
      {
        "conv_Polite_headnod"
      }
    },
    {
      "DELAY",
      {2}
    },
    {"STARTOVER"}
  }
  ScriptSequence.Run(self.hPriest, tPriestSeq)
  Actor.PlayAnimation(self.hBride, "bride_idle")
  Actor.PlayAnimation(self.hTarget, "groom_idle")
end

function P1FP_NaziParty:PlayResponseSequence()
  self:PlayGroupAnimation(self.tBrideParty, self.tDisapproveAnims)
  self:PlayGroupAnimation(self.tGroomParty, self.tHeilAnims)
end

function P1FP_NaziParty:OnCivDeath(a_tCallbackData)
  dprint(self, "Civilian down!")
  
  local function IsGuest(a_hGuest)
    for i, v in ipairs(self.tInfo.tCivilians) do
      if v == a_hGuest then
        return true
      end
    end
    return false
  end
  
  if IsGuest(a_tCallbackData[1].hController) == true and a_tCallbackData[2] == Handle("Saboteur") then
    EVENT_Timer("P1FP_NaziParty.FailCivKilled", self, 1.5)
  end
end

function P1FP_NaziParty:FailCivKilled()
  self:MissionTaskFail("GenericFail_Text.KILLED_Civilian")
end

function P1FP_NaziParty:OnEscalation()
  dprint(self, "Escalation detected!")
  Suspicion.SetEscalated()
  ScriptSequence.Kill(self.hPriest)
  Combat.SetIdleScripted(self.hPriest, true)
  Combat.SetRespondToEvents(self.hPriest, false)
  Combat.SetRespondToSound(self.hPriest, false)
  Combat.SetRespondToDamage(self.hPriest, false)
  Combat.SetSquadAssist(self.hPriest, false)
  Actor.OverrideCombatAI(self.hPriest, true)
  Inventory.GiveItem(self.hPriest, "WP_MG_Thompson_ExtMag", false)
  if Actor.IsAlive(self.hTarget) then
    Combat.SetTarget(self.hPriest, self.hTarget)
    Combat.SetCombat(self.hPriest)
    local tDeathEvent = {
      EventType = "DeathEvent",
      ObjectHandle = Handle(self.hTarget)
    }
    local eTargetDeath = Util.CreateEvent(tDeathEvent, "P1FP_NaziParty.FatherDenisAttacks", self)
    self:RegisterEvent(eTargetDeath)
  else
    Combat.SetTargetTeam(self.hPriest, cTEAM_NAZI)
    Combat.SetCombat(self.hPriest)
  end
  if Actor.IsAlive(self.hTarget) then
    Combat.SetIdleScripted(self.hTarget, false)
    Combat.SetCombat(self.hTarget)
  end
  for i, v in ipairs(self.tInfo.AllAttrPts) do
    local hAttrPt = Handle(v)
    if AttractionPt.IsBeingUsedBySomeone(hAttrPt) then
      AttractionPt.FinishNow(hAttrPt)
    end
  end
  for i, v in ipairs(self.tInfo.tBrideParty) do
    local hActor = Util.GetHandleByName(v)
    if Object.IsAlive(hActor) == true then
      Actor.CancelAnimation(hActor)
      Actor.SetPanicEnabled(hActor, true)
    end
  end
  Sound.DeactivateSoundEmitter(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\sound\\Emt_Nz_Wedding_Gramophone"))
  Sound.DeactivateSoundEmitter(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\sound\\Emt_P1FP_Wedding_Audience"))
  Sound.DeactivateSoundEmitter(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\sound\\Emt_P1FP_Wedding_Audience(1)"))
  Sound.DeactivateSoundEmitter(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\sound\\Emt_P1FP_Wedding_Girl"))
  Sound.DeactivateSoundEmitter(Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\sound\\Emt_P1FP_Wedding_Girl(1)"))
end

function P1FP_NaziParty:FatherDenisAttacks()
  Combat.SetTargetTeam(self.hPriest, cTEAM_NAZI)
  Combat.SetCombat(self.hPriest)
end

function P1FP_NaziParty:ReleaseFatherDenis()
  Combat.SetIdleScripted(self.hPriest, true)
  Nav.SetScriptedPath(self.hPriest, self.PATH .. "main\\PATH_ReleaseDenis", true, "P1FP_NaziParty.SuicidalDenis", self, {})
  Nav.SetScriptedPathMoveMode(self.hPriest, true)
  Cin.PlayConversation("P1FP_NaziParty_FatherGoodbye")
  Actor.SetMissionCriticalNPC(self.hPriest, false)
  Inventory.GiveItem(self.hPriest, "WP_MG_Thompson_ExtMag", false)
end

function P1FP_NaziParty:RushForwardDenis()
  Nav.MoveToObject(self.hPriest, Handle("Missions\\freeplay\\p1\\mis_chaumont_naziparty\\main\\LOC_FatherAttacks"), 5, true, "P1FP_NaziParty.SuicidalDenis", self)
end

function P1FP_NaziParty:SuicidalDenis()
  Combat.SetIdleScripted(self.hPriest, false)
  Combat.SetRespondToEvents(self.hPriest, true)
  Combat.SetRespondToSound(self.hPriest, true)
  Combat.SetRespondToDamage(self.hPriest, true)
  Combat.SetSquadAssist(self.hPriest, true)
  Actor.OverrideCombatAI(self.hPriest, false)
  Combat.SetTargetTeam(self.hPriest, cTEAM_NAZI)
end

function P1FP_NaziParty:Sound1()
  Sound.SetMusicLocale("fp_P1FP_NaziWedding")
  Sound.SetMusicLocale("fp_P1FP_NaziWedding", "wedding")
end

function P1FP_NaziParty:ResetSound()
  Sound.ResetMusicLocale()
end

function P1FP_NaziParty:MarriageFail()
  self:MissionTaskFail("P1FP_NaziParty_Text.MarriageFail")
end
