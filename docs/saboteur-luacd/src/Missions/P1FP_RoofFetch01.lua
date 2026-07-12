if P1FP_RoofFetch01 == nil then
  P1FP_RoofFetch01 = SabTaskObjective:Create()
  gsP1Fetch01 = "Missions\\freeplay\\p1\\mis_portdenis_east\\"
  P1FP_RoofFetch01:Configure({
    TaskCount = 999,
    sStarter = "Santos_LaVillette_Interior",
    sConvFile = "207_Con_Santos",
    sSaveMissionNameID = "MissionNames_Text.P1FP_RoofFetch",
    bFreeplay = true,
    bEscalationDenial = true,
    tUnlockList = {
      "P1FP_Traitor",
      "Connect_AmbientFP"
    },
    tSMEDNodes = {
      gsP1Fetch01 .. "main"
    },
    tStaticTags = {}
  })
end

function P1FP_RoofFetch01:STARTER_Setup()
  self.hDoorPt = Handle("PARIS\\area01\\lavillette\\interior\\lavillette_int\\TeleporterSwingLeftDoorPoint")
  AttractionPt.EnableUse(self.hDoorPt, false)
end

function P1FP_RoofFetch01:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "GETMEDS"
  self.bDebugMode = false
  self:GENERAL_Setup()
  self:RegisterCheckpoint("P1FP_RoofFetch01.Checkpoint0")
end

function P1FP_RoofFetch01.SetupGamepadListener()
  local self = P1FP_RoofFetch01
  self.tControllerEvent = {
    EventType = "OnButtonPress",
    Target = Handle("Saboteur")
  }
  local eButtonEvent = Util.CreateEvent(self.tControllerEvent, "P1FP_RoofFetch01.OnButtonPress", self, {}, true)
  self:RegisterEvent(eButtonEvent)
end

function P1FP_RoofFetch01:OnButtonPress(a_tButtonData)
  local self = P1FP_RoofFetch01
  local tButtons = a_tButtonData[1]
  if tButtons.UP == true then
  elseif tButtons.DOWN == true then
  elseif tButtons.X == true then
  elseif tButtons.B == true then
  end
end

function P1FP_RoofFetch01:GENERAL_Setup()
  self.tInfo.Papers = {
    "Missions\\freeplay\\p1\\mis_portdenis_east\\target\\WineBottle"
  }
  self.tInfo.bBonusActive = true
  self.sSeatedNazi1 = gsP1Fetch01 .. "party\\WM_Grunt_MG_Seated_01"
  self.sSeatedNazi2 = gsP1Fetch01 .. "party\\WM_Grunt_MG_Seated_10"
  self.sSeatedNazi3 = gsP1Fetch01 .. "party\\WM_Grunt_MG_Seated_14"
  self.sSeatedNazi4 = gsP1Fetch01 .. "party\\WM_Grunt_MG_Seated_21"
  self.sODNazi1 = gsP1Fetch01 .. "party\\Nazi_OffDuty_01"
  self.sODNazi2 = gsP1Fetch01 .. "party\\Nazi_OffDuty_02"
  self.sOfficer = gsP1Fetch01 .. "party\\WM_Officer_PS_Podium"
  self.sGuestF1 = gsP1Fetch01 .. "party\\UpperClass_F_01"
  self.sGuestF2 = gsP1Fetch01 .. "party\\UpperClass_F_02"
  self.sGuestF3 = gsP1Fetch01 .. "party\\UpperClass_F_Hot"
  self.sGuestM1 = gsP1Fetch01 .. "party\\UpperClass_M_01"
  self.sGuestM2 = gsP1Fetch01 .. "party\\UpperClass_M_02"
  self.sWaitress = gsP1Fetch01 .. "party\\Waiter_F"
  self.tInfo.Nazis = {
    gsP1Fetch01 .. "party\\WM_Grunt_MG_Seated_01",
    gsP1Fetch01 .. "party\\WM_Grunt_MG_Seated_10",
    gsP1Fetch01 .. "party\\WM_Grunt_MG_Seated_14",
    gsP1Fetch01 .. "party\\WM_Grunt_MG_Seated_21",
    gsP1Fetch01 .. "party\\WM_Officer_PS_Podium"
  }
  self.tInfo.Civs = {
    gsP1Fetch01 .. "party\\UpperClass_F_01",
    gsP1Fetch01 .. "party\\UpperClass_F_02",
    gsP1Fetch01 .. "party\\UpperClass_F_Hot",
    gsP1Fetch01 .. "party\\UpperClass_M_01",
    gsP1Fetch01 .. "party\\UpperClass_M_02",
    gsP1Fetch01 .. "party\\Nazi_OffDuty_01",
    gsP1Fetch01 .. "party\\Nazi_OffDuty_02",
    gsP1Fetch01 .. "party\\Waiter_F"
  }
  self.sStreetGuard = gsP1Fetch01 .. "main\\NZ_StreetGuard"
  self.sStreetGuard2 = gsP1Fetch01 .. "main\\NZ_StreetGuard_2"
  self:AddOnCancelCallback(P1FP_RoofFetch01.Reset)
  self:AddOnCompleteCallback(P1FP_RoofFetch01.MissionComplete)
  Sound.LoadSoundBank("m_P1FP_GetMeds.bnk")
end

function P1FP_RoofFetch01:InitCrowd(a_tArgs1, a_tArgs2)
  local hHuman = Handle(a_tArgs1)
  local hAttrPt = Handle(a_tArgs2)
  local hNaziObj = Handle("Missions\\freeplay\\p1\\mis_portdenis_east\\main\\LOC_NaziObjective")
  local hCivEscape = Handle("Missions\\freeplay\\p1\\mis_portdenis_east\\main\\LOC_CivsEscapeHere")
  if Suspicion.GetEscalation() > 0 then
    local fMatchfilter = Filter.New("Nazi")
    if Filter.Match(fMatchfilter, hHuman) == true then
      Combat.SetObjective(hHuman, hNaziObj, false, 15)
    else
      Nav.MoveToObject(hHuman, hCivEscape, 10, cMOVE_PANIC)
    end
    Filter.Delete(fMatchfilter)
  else
    Actor.RequestAttrPt(hHuman, hAttrPt)
  end
end

function P1FP_RoofFetch01:Checkpoint0()
  dprint(self, "Registered: CHECKPOINT 0")
  AttractionPt.EnableUse(self.hDoorPt, true)
  self.Task_ExitHQ(self)
  self.Task_GoToMission(self)
  self:TASK_Escalator()
end

function P1FP_RoofFetch01:TASK_Escalator()
  self:CreateTask({
    sName = "TASK_Escalator",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = true,
    tOnComplete = {
      {
        self.EscalationEffects,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function P1FP_RoofFetch01:Task_ExitHQ()
  self:CreateTask({
    sName = "P1FP_RoofFetch01_Task_ExitHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "LaVillette",
    bInteriorTask = true,
    bNoGPS = true,
    MarkerHeight = 2.5,
    tLocators = {},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "P1FP_RoofFetch01.Checkpoint1"
        }
      }
    }
  })
end

function P1FP_RoofFetch01:Checkpoint1()
  if not self:IsMissionTaskActive("Task_GoToMission") then
    self:Task_GoToMission()
  end
  if not self:IsMissionTaskActive("TASK_Escalator") then
    self:TASK_Escalator()
  end
  RewardsManager.HideStarter("Santos_LaVillette_Interior")
  EVENT_Stream("P1FP_RoofFetch01.SetupGuardWarns", self, self.sStreetGuard, true)
  EVENT_Stream("P1FP_RoofFetch01.InitCrowd", self, self.sSeatedNazi1, true, {
    self.sSeatedNazi1,
    "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\AttractionPT_Sitforever_01"
  })
  EVENT_Stream("P1FP_RoofFetch01.InitCrowd", self, self.sSeatedNazi2, true, {
    self.sSeatedNazi2,
    "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\AttractionPT_Sitforever_10"
  })
  EVENT_Stream("P1FP_RoofFetch01.InitCrowd", self, self.sSeatedNazi3, true, {
    self.sSeatedNazi3,
    "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\AttractionPT_Sitforever_14"
  })
  EVENT_Stream("P1FP_RoofFetch01.InitCrowd", self, self.sSeatedNazi4, true, {
    self.sSeatedNazi4,
    "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\AttractionPT_Sitforever_21"
  })
  EVENT_Stream("P1FP_RoofFetch01.InitCrowd", self, self.sODNazi1, true, {
    self.sODNazi1,
    "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\AttractionPT_Sitforever_24"
  })
  EVENT_Stream("P1FP_RoofFetch01.InitCrowd", self, self.sODNazi2, true, {
    self.sODNazi2,
    "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\AttractionPT_Sitforever_08"
  })
  EVENT_Stream("P1FP_RoofFetch01.InitCrowd", self, self.sGuestF1, true, {
    self.sGuestF1,
    "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\AttractionPT_Sitforever_05"
  })
  EVENT_Stream("P1FP_RoofFetch01.InitCrowd", self, self.sGuestF2, true, {
    self.sGuestF2,
    "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\AttractionPT_Sitforever_12"
  })
  EVENT_Stream("P1FP_RoofFetch01.InitCrowd", self, self.sGuestF3, true, {
    self.sGuestF3,
    "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\AttractionPT_Sitforever_16"
  })
  EVENT_Stream("P1FP_RoofFetch01.InitCrowd", self, self.sGuestM1, true, {
    self.sGuestM1,
    "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\AttractionPT_Sitforever_18"
  })
  EVENT_Stream("P1FP_RoofFetch01.InitCrowd", self, self.sGuestM2, true, {
    self.sGuestM2,
    "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\AttractionPT_Sitforever_23"
  })
  EVENT_Stream("P1FP_RoofFetch01.InitWaitress", self, self.sWaitress, true, {})
  EVENT_Stream("P1FP_RoofFetch01.InitOfficer", self, self.sOfficer, true, {})
  EVENT_Stream("P1FP_RoofFetch01.CloseExit", self, "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\SwingingDoorRight", true, {})
  EVENT_Stream("P1FP_RoofFetch01.GestapoProx", self, "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\Street_GS_Officer_PS", true, {})
  self.eSkipFirstTask = EVENT_PlayerEntersTrigger("P1FP_RoofFetch01.SkipFirstTask", self, "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\PT_ClamberRoute", false)
  self.tInfo.bCheckpt3Esc = false
end

function P1FP_RoofFetch01:InitOfficer()
  Actor.PlayAnimation(Handle(self.sOfficer), "shrd_M_nazi_speech_conversation1")
end

function P1FP_RoofFetch01:InitWaitress()
  Actor.PlayAnimation(Handle(self.sWaitress), "civ_waiter_takeorder")
end

function P1FP_RoofFetch01:SkipFirstTask()
  self:KillTaskByName("Task_GoToMission")
  WorldSMEDNodes.LoadNode("Missions\\freeplay\\p1\\mis_portdenis_east\\party")
  WorldSMEDNodes.LoadStaticTag("p1fp_rooffetch_target", true)
  self:RegisterCheckpoint("P1FP_RoofFetch01.Checkpoint2")
end

function P1FP_RoofFetch01:GestapoProx()
  EVENT_PlayerToActorProximity("P1FP_RoofFetch01.GestapoTut", self, "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\Street_GS_Officer_PS", 15)
end

function P1FP_RoofFetch01:GestapoTut()
  Saboteur.ShowToolTip("TutorialTip_Text.Gestapo_Suspicion")
end

function P1FP_RoofFetch01:Task_GoToMission()
  self:CreateTask({
    sName = "Task_GoToMission",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "P1FP_RoofFetch01_Text.Task_GoToMission",
    tLocators = {
      "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\LOC_GoToMission"
    },
    tDestRegion = "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\PT_MissionArea",
    sTaskSubType = "DELIVER",
    bGroundBlip = true,
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.ClearGPS,
        {self}
      },
      {
        self.PanoramaCin,
        {self}
      }
    }
  })
end

function P1FP_RoofFetch01:ClearGPS()
  HUD.ClearWaypoint()
  HUD.ClearGPSTarget()
end

function P1FP_RoofFetch01:Checkpoint2()
  ClearAllDisableControls()
  EVENT_PlayerToActorProximity("P1FP_RoofFetch01.GoGestapo", self, "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\LOC_CamLookAtDoor", 15)
  Cin.PlayConversation("P1FP_RoofFetch_NoEscalate")
  self.Task_FetchCrateObject(self)
  Trigger.ClearCallback("Missions\\freeplay\\p1\\mis_portdenis_east\\main\\PT_ClamberRoute", self.eSkipFirstTask)
  self.tInfo.bPartyOn = true
  self.tInfo.bRetry3 = false
  dprint(self, "Registered: CHECKPOINT 2")
  Suspicion.SetNoTail(Handle(self.sStreetGuard), true)
  Suspicion.SetNoTail(Handle(self.sStreetGuard2), true)
  WorldSMEDNodes.LoadNode("Missions\\freeplay\\p1\\mis_portdenis_east\\Sound")
  EVENT_OnEscalation("P1FP_RoofFetch01.UnloadPartySound", self, nil, false)
end

function P1FP_RoofFetch01:UnloadPartySound()
  WorldSMEDNodes.UnloadNode("Missions\\freeplay\\p1\\mis_portdenis_east\\Sound", true)
  self.tInfo.bPartyOn = false
end

function P1FP_RoofFetch01:SetupGuardWarns()
  self.eGuardWarns = EVENT_PlayerEntersTrigger("P1FP_RoofFetch01.StreetGuardWarns", self, "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\PT_WarnPlayer", false)
end

function P1FP_RoofFetch01:StreetGuardWarns()
  if not Actor.IsDisguised(hSab) then
    if Object.IsAlive(Handle(self.sStreetGuard)) then
      Actor.SetFacingDir(Handle(self.sStreetGuard), hSab)
      Actor.PlayAnimation(Handle(self.sStreetGuard), "nazi_halt_1")
      Cin.PlayConversationWith("P2FP_GrandSniper_NaziGuard", {
        Handle(self.sStreetGuard)
      })
    end
    if Object.IsAlive(Handle(self.sStreetGuard2)) then
      Actor.PlayAnimation(Handle(self.sStreetGuard2), "nazi_halt_1")
    end
  end
end

function P1FP_RoofFetch01:CloseExit()
  self.hDoorAP = Handle("Missions\\freeplay\\p1\\mis_portdenis_east\\main\\SwingingDoorRight")
  AttractionPt.EnableUse(self.hDoorAP, false)
end

function P1FP_RoofFetch01:PanoramaCin()
  self:CreateTask({
    sName = "P1FP_RoofFetch01.PanoramaCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "CIN_GetMeds_Pan",
    tSMEDNodes = {
      gsP1Fetch01 .. "party"
    },
    tStaticTags = {},
    tOnActivate = {
      {
        self.BrakeCar,
        {self}
      },
      {
        self.PlaySound,
        {self}
      },
      {
        WorldSMEDNodes.LoadStaticTag,
        {
          "p1fp_rooffetch_target",
          true
        }
      }
    },
    tOnComplete = {
      {
        self.UnBrakeCar,
        {self}
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "P1FP_RoofFetch01.Checkpoint2"
        }
      }
    }
  })
end

function P1FP_RoofFetch01:PlaySound()
  Sound.PlayOwnerlessSoundEvent("FP_GetMeds_cameracut_laughter")
end

function P1FP_RoofFetch01:BrakeCar()
  self.hSabCar = Actor.GetVehicle(hSab)
  if self.hSabCar then
    SabTaskObjectiveDeliver.StopVehicle(self, self.hSabCar)
  end
end

function P1FP_RoofFetch01:UnBrakeCar()
  if self.hSabCar then
    SabTaskObjectiveDeliver.ReleaseVehicle(self, self.hSabCar)
  else
    SabTaskObjectiveDeliver.ClearVehControls(self)
  end
  ClearAllDisableControls()
end

function P1FP_RoofFetch01:Task_FetchCrateObject()
  self:CreateTask({
    sName = "P1FP_RoofFetch01_Task_FetchCrateObject",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Fetch",
    sObjectiveTextID = "P1FP_RoofFetch01_Text.Task_FetchCrateObject",
    tDeliverObjs = {
      gsP1Fetch01 .. "target\\WineBottle"
    },
    bBlipLocatorsOnly = true,
    tLocators = {
      "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\LOC_WineBottle"
    },
    tStaticTags = {},
    tSMEDNodes = {
      gsP1Fetch01 .. "SantosLavaHQ"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.SoundChange,
        {self}
      },
      {
        self.GestapoCinTest,
        {self}
      },
      {
        Actor.SetLabel,
        {
          hSab,
          "WineBottleMeds",
          true
        }
      }
    }
  })
end

function P1FP_RoofFetch01:SoundChange()
  if Suspicion.GetEscalation() > 0 then
    Sound.SetMusicLocale("fp_P1FP_GetMeds")
    Sound.SetMusicLocale("fp_P1FP_GetMeds", "grabBottle")
  end
end

function P1FP_RoofFetch01:GestapoCinTest()
  if Suspicion.GetEscalation() > 0 then
    self:GestapoCin()
    self:PlayEscTip()
  else
    Util.EnableTutorial("TutorialTip_Text.Escalation_Hide")
    self.RegisterCheckpoint(self, "P1FP_RoofFetch01.Checkpoint3")
  end
end

function P1FP_RoofFetch01:GestapoCin()
  self:CreateTask({
    sName = "P1FP_RoofFetch01.GestapoCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "CIN_GetMeds_Gestapo",
    tSMEDNodes = {},
    tStaticTags = {},
    tOnActivate = {},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "P1FP_RoofFetch01.Checkpoint3"
        }
      },
      {
        self.TASK_UseHideSpot,
        {self}
      },
      {
        self.KillGuardEvent,
        {self}
      }
    }
  })
end

function P1FP_RoofFetch01:KillGuardEvent()
  Util.KillEvent(self.eGuardWarns)
end

function P1FP_RoofFetch01:GoGestapo()
  WorldSMEDNodes.LoadNode("Missions\\freeplay\\p1\\mis_portdenis_east\\gestapo")
  self.sGestapo = "Missions\\freeplay\\p1\\mis_portdenis_east\\gestapo\\Spore_GS_Heavy_PS"
  EVENT_Stream("P1FP_RoofFetch01.InitGestapo", self, self.sGestapo, false)
end

function P1FP_RoofFetch01:InitGestapo()
  self.hGestapo = Handle(self.sGestapo)
  Actor.OverrideCombatAI(self.hGestapo, true)
  AttractionPt.EnableUse(self.hDoorAP, true)
  local tExitSequence = {
    {
      "SETIDLESCRIPTED",
      {true}
    },
    {
      "RUNTOOBJECT",
      {
        self.hDoorAP
      }
    },
    {
      "USEATTRPT",
      {
        self.hDoorAP
      }
    },
    {
      "DELAY",
      {0.25}
    },
    {
      "RUNTOOBJECT",
      {
        "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\LOC_GestapoRuns",
        0
      }
    }
  }
  ScriptSequence.Run(self.hGestapo, tExitSequence, P1FP_RoofFetch01.GestapoPostCin, {self})
end

function P1FP_RoofFetch01:GestapoPostCin()
  Combat.SetIdleScripted(self.hGestapo, false)
  Actor.OverrideCombatAI(self.hGestapo, false)
  AttractionPt.EnableUse(self.hDoorAP, false)
end

function P1FP_RoofFetch01:Checkpoint3()
  dprint(self, "Registered: CHECKPOINT 3")
  self.Task_ReturnObject(self)
  if self.tInfo.bPartyOn == true then
    WorldSMEDNodes.UnloadNode("Missions\\freeplay\\p1\\mis_portdenis_east\\Sound", true)
  end
  self.tInfo.bRetry3 = true
end

function P1FP_RoofFetch01:TASK_UseHideSpot()
  self.hHideSpotUse = Util.GetHandleByName("PARIS\\hidingpoints\\p1\\hatches\\PGA_Hide_Roof_Hatch(2)\\UsePt_Hatch")
  self:CreateTask({
    sName = "P1FP_RoofFetch01.TASK_UseHideSpot",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    sObjectiveTextID = "P1FP_RoofFetch01_Text.TASK_UseHideSpot",
    bBlipLocatorsOnly = true,
    tLocators = {
      "PARIS\\hidingpoints\\p1\\hatches\\PGA_Hide_Roof_Hatch(2)\\CamLookAt"
    },
    tTgtInclude = {
      self.hHideSpotUse
    },
    tSMEDNodes = {},
    tOnActivate = {
      {
        self.DetectEscLow,
        {self}
      }
    },
    tOnComplete = {
      {
        self.ResetMusic,
        {self}
      },
      {
        self.CheckAndKillComp,
        {self}
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "P1FP_RoofFetch01.Checkpoint3"
        }
      }
    }
  })
end

function P1FP_RoofFetch01:CheckAndKillComp()
  if self.eEscComplete then
    Util.KillEvent(self.eEscComplete)
  else
  end
end

function P1FP_RoofFetch01:ResetMusic()
  Sound.ResetMusicLocale()
end

function P1FP_RoofFetch01:DetectEscLow()
  self.eEscComplete = EVENT_EscalationFree("P1FP_RoofFetch01.CompleteUseHideSp", self)
end

function P1FP_RoofFetch01:CompleteUseHideSp()
  self:CompleteTaskByName("P1FP_RoofFetch01.TASK_UseHideSpot")
end

function P1FP_RoofFetch01:Task_ReturnObject()
  self:CreateTask({
    sName = "P1FP_RoofFetch01_Task_ReturnObject",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Talk",
    bEscalationDenial = true,
    sObjectiveTextID = "P1FP_RoofFetch01_Text.Task_ReturnObject",
    tTgtInclude = {
      "Missions\\freeplay\\p1\\mis_portdenis_east\\SantosLavaHQ\\Santos"
    },
    vGPSTarget = "Missions\\freeplay\\p1\\mis_portdenis_east\\main\\LOC_SantosHideout",
    sConvFile = "208_Con_SantosDone",
    tOnActivate = {
      {
        self.EscalationListener,
        {self}
      }
    },
    tOnComplete = {
      {
        self.Task_EnterLavaHQ,
        {self}
      }
    }
  })
end

function P1FP_RoofFetch01:CleanUpSantos()
  self:UnloadTaskNodes("P1FP_RoofFetch01_Task_FetchCrateObject", true)
end

function P1FP_RoofFetch01:Task_EnterLavaHQ()
  self:CreateTask({
    sName = "P1FP_RoofFetch01_Task_EnterLavaHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "EnterInterior",
    sObjectiveTextID = "P1FP_RoofFetch01_Text.Task_EnterLavaHQ",
    sInteriorName = "LaVillette",
    bNoGPS = true,
    MarkerHeight = 2.5,
    tLocators = {
      gsP1Fetch01 .. "main\\LOC_Enter"
    },
    tOnComplete = {
      {
        self.CleanUpSantos,
        {self}
      },
      {
        self.Task_TalkToLuc,
        {self}
      },
      {
        Util.AddInteriorLoadCallback,
        {
          "LaVillette",
          "P1FP_RoofFetch01.ExitCheck",
          self
        }
      }
    }
  })
end

function P1FP_RoofFetch01:Task_TalkToLuc()
  self:CreateTask({
    sName = "P1FP_RoofFetch01_Task_TalkToLuc",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Talk",
    bAutofire = true,
    Proximity = 2,
    sObjectiveTextID = "P1FP_RoofFetch01_Text.Task_TalkToLuc",
    bInteriorTask = true,
    tTgtInclude = {
      "Missions\\paris_1\\characters\\lavillette\\veronique_front\\Veronique_LaVillette_Front"
    },
    sConvFile = "209_Con_LucDone",
    tOnActivate = {},
    tOnComplete = {
      {
        Util.CancelInteriorLoadCallback,
        {"LaVillette"}
      }
    },
    tOnConversationComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end

function P1FP_RoofFetch01:ExitCheck()
  self.ResetTaskByName(self, "P1FP_RoofFetch01_Task_EnterLavaHQ")
  self.ResetTaskByName(self, "P1FP_RoofFetch01_Task_TalkToLuc", true)
end

function P1FP_RoofFetch01:VConvoStart()
  local hDoor = Handle("PARIS\\area01\\lavillette\\interior\\lavillette_int\\TeleporterSwingLeftDoorPoint")
  AttractionPt.EnableUse(hDoor, false)
end

function P1FP_RoofFetch01:KillEscEvent()
  if self.eEscDetect then
    Util.KillEvent(self.eEscDetect)
  else
  end
  if self.sActiveTask == "P1FP_RoofFetch01_Task_ReturnObject" then
    self:Task_ReturnObject()
    self:EscalationListener()
  elseif self.sActiveTask == "P1FP_RoofFetch01_Task_EnterLavaHQ" then
    self:Task_EnterLavaHQ()
    self:EscalationListener()
  end
end

function P1FP_RoofFetch01:EscalationListener()
  dprint(self, "Setting Escalation Listener  - clear Esc to get Fade Up/Down")
  self.eEscDetect = EVENT_OnEscalation("P1FP_RoofFetch01.EscSwitchTasks", self, nil, false)
end

function P1FP_RoofFetch01:EscSwitchTasks()
  dprint(self, "Escalated. Switching to LOSE HEAT task")
  if self:IsMissionTaskActive("P1FP_RoofFetch01_Task_ReturnObject") then
    self:ResetTaskByName("P1FP_RoofFetch01_Task_ReturnObject", true)
    Cin.PlayConversation("P1FP_RoofFetch_Blocked")
    self:TASK_LoseEscalation()
    self.sActiveTask = "P1FP_RoofFetch01_Task_ReturnObject"
  elseif self:IsMissionTaskActive("P1FP_RoofFetch01_Task_EnterLavaHQ") then
    self:ResetTaskByName("P1FP_RoofFetch01_Task_EnterLavaHQ", true)
    Cin.PlayConversation("P1FP_RoofFetch_Blocked")
    self:TASK_LoseEscalation()
    self.sActiveTask = "P1FP_RoofFetch01_Task_EnterLavaHQ"
  end
end

function P1FP_RoofFetch01:TASK_LoseEscalation()
  self:CreateTask({
    sName = "P1FP_RoofFetch01.TASK_LoseEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    EscalationLevel = 0,
    bRepeatable = true,
    bNoRepeatAutoRebuild = true,
    tOnComplete = {
      {
        self.KillEscEvent,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function P1FP_RoofFetch01:EscalationEffects()
  for i, v in ipairs(self.tInfo.Nazis) do
    local hActor = Util.GetHandleByName(v)
    if Actor.IsAlive(hActor) == true then
      Actor.CancelAttrPt(hActor)
    end
  end
  for i, v in ipairs(self.tInfo.Civs) do
    local hActor = Util.GetHandleByName(v)
    if Actor.IsAlive(hActor) == true then
      Actor.CancelAttrPt(hActor)
    end
  end
  Combat.SetObjective(Handle(gsP1Fetch01 .. "party\\WM_Officer_PS_Podium"), hSab, false, 20, false)
  Sound.PlayOwnerlessSoundEvent("Stop_FP_GetMeds_NaziParty")
end

function P1FP_RoofFetch01:PlayEscTip()
  Saboteur.ShowToolTip("TutorialTip_Text.Escalation_Hide")
end

function P1FP_RoofFetch01:PlayJournalTip()
end

function P1FP_RoofFetch01:MissionComplete()
  EVENT_Timer("RewardsManager.PlayJournalTip", nil, 7, {
    "TutorialTip_Text.Journal"
  })
  Sound.ResetMusicLocale()
  Sound.UnloadSoundBank("m_P1FP_GetMeds.bnk")
  local hDoor = Handle("PARIS\\area01\\lavillette\\interior\\lavillette_int\\TeleporterSwingLeftDoorPoint")
  AttractionPt.EnableUse(hDoor, true)
  WorldSMEDNodes.UnloadNode("Missions\\freeplay\\p1\\mis_portdenis_east\\party", true)
  WorldSMEDNodes.UnloadNode("Missions\\freeplay\\p1\\mis_portdenis_east\\Sound", true)
  WorldSMEDNodes.UnloadStaticTag("p1fp_rooffetch_target", true)
  WorldSMEDNodes.UnloadNode("Missions\\freeplay\\p1\\mis_portdenis_east\\gestapo", true)
  Util.ClearAllPendingTutorials()
end

function P1FP_RoofFetch01:Reset()
  Inventory.DetachItem(hSab, Handle(gsP1Fetch01 .. "target\\WineBottle"), true)
  Sound.ResetMusicLocale()
  Sound.UnloadSoundBank("m_P1FP_GetMeds.bnk")
  Util.CancelInteriorLoadCallback("LaVillette")
  WorldSMEDNodes.UnloadNode("Missions\\freeplay\\p1\\mis_portdenis_east\\party", true)
  WorldSMEDNodes.UnloadNode("Missions\\freeplay\\p1\\mis_portdenis_east\\Sound", true)
  WorldSMEDNodes.UnloadStaticTag("p1fp_rooffetch_target", true)
  WorldSMEDNodes.UnloadNode("Missions\\freeplay\\p1\\mis_portdenis_east\\gestapo", true)
  if not Actor.HasLabel(hSab, "WineBottleMeds") then
    Actor.SetLabel(hSab, "WineBottleMeds", false)
  end
  RewardsManager.ShowStarter("Santos_LaVillette_Interior")
  Util.ClearAllPendingTutorials()
end
