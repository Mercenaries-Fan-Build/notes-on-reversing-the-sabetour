if Paris_1_Mission_1B == nil then
  Paris_1_Mission_1B = SabTaskObjective:Create()
  Paris_1_Mission_1B.PATH = "Missions\\Paris_1\\Mission_1B\\"
  Paris_1_Mission_1B.WORLDPATH = "PARIS\\area01\\lavillette\\"
  Paris_1_Mission_1B:Configure({
    TaskCount = 999,
    sSaveMissionNameID = "MissionNames_Text.P1M1b",
    bStarterless = true,
    tUnlockList = {
      "Paris_1_Mission_1B_Connect"
    },
    bSLOverrideFade = true,
    bForceUnloadNodes = true,
    tSMEDNodes = {
      Paris_1_Mission_1B.PATH .. "main"
    },
    tStaticTags = {
      "P1M1BAirRaid"
    }
  })
end

function Paris_1_Mission_1B:STARTER_Setup()
  EVENT_PlayerToActorProximity("Paris_1_Mission_1B.HelperCancelAttrPt", self, "Missions\\paris_1\\characters\\belle\\luc_belle_interior2\\Luc_Belle_Interior_2", 20)
  Util.EnableTutorial("TutorialTip_Text.Mission_Starter_Title", true)
  Actor.SetDisguise(hSab, "FBS_RS_Sean")
  Util.EnableMiniZep(true)
  local hBelleDoor = Handle("PARIS\\area01\\belledenuit\\interior\\hq_int\\Belle_int_teleport")
  local hBelleDoor2 = Handle("PARIS\\area01\\belledenuit\\interior\\hq_int\\Belle_int_teleport(2)")
  AttractionPt.EnableUse(hBelleDoor, false)
  AttractionPt.EnableUse(hBelleDoor2, false)
  WorldSMEDNodes.LoadNode("PARIS\\area01\\belledenuit\\interior\\DorissBackRoom")
end

function Paris_1_Mission_1B:SetOpeningSeanWakey()
  local hWakeAttrpt = Handle("PARIS\\area01\\belledenuit\\interior\\hq_int\\ATTRPT_P1M1B_GetouttaBed")
  self.hWakeAttrpt = hWakeAttrpt
  Actor.UseAttrPt(hSab, hWakeAttrpt)
  EVENT_Timer("Paris_1_Mission_1B.OpenTheCurtains", self, 2)
end

function Paris_1_Mission_1B:OpenTheCurtains()
  self:SetupBelleGirlsScene()
  Render.FadeScreen(false)
  Util.SetOverrideLoadScreenFadeIn(false)
  self:CheckpointAlpha()
end

function Paris_1_Mission_1B:SetupAlphaCheck()
  self:RegisterCheckpoint("Paris_1_Mission_1B.CheckpointAlpha")
end

function Paris_1_Mission_1B:HelperCancelAttrPt()
  Cin.PlayConversation("P1M1b_InBelle_OverHere", "Paris_1_Mission_1B.TurnLucAround", self)
end

function Paris_1_Mission_1B:TurnLucAround()
  local hLucBelle2 = Handle("Missions\\paris_1\\characters\\belle\\luc_belle_interior2\\Luc_Belle_Interior_2")
  local hTurnToLoc = Handle("Missions\\paris_1\\characters\\belle\\luc_belle_interior2\\Locator")
  Actor.SetFacingDir(hLucBelle2, hTurnToLoc)
end

function Paris_1_Mission_1B:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self:SetOpeningSeanWakey()
end

function Paris_1_Mission_1B:GENERAL_Setup()
  self.sDebugLabel = "P1M1B"
  self.bDebugMode = true
  self.nDropoffTimerMin = 30
  self.nDropoffTimerMax = 30
  Util.SetTime(21, 0)
  self.nTimerMax = 600
  self.nInitial = 600
  self.tInfo.sLuc = "Missions\\paris_1\\mission_1b\\main\\P1M1BLuc"
  self.tPrisonDoors = {
    "PARIS\\area01\\lavillette\\occupation\\prison\\PrisonDoorC"
  }
  self.sCellDoor = "PARIS\\area01\\lavillette\\occupation\\prison\\PrisonDoorC"
  self.sPrisonDoors = "Missions\\paris_1\\mission_1b\\main\\CellDoorLever"
  self.tPrisoners = {
    "Missions\\paris_1\\mission_1b\\importantprisoners\\Prisoner3",
    "Missions\\paris_1\\mission_1b\\importantprisoners\\Vittore",
    "Missions\\paris_1\\mission_1b\\importantprisoners\\Prisoner5"
  }
  self.tPrisonerMoveLocations = {
    "PARIS\\area01\\lavillette\\occupation\\prison\\LOC_DoorA",
    "PARIS\\area01\\lavillette\\occupation\\prison\\LOC_DoorB",
    "PARIS\\area01\\lavillette\\occupation\\prison\\LOC_DoorC",
    "PARIS\\area01\\lavillette\\occupation\\prison\\LOC_DoorD"
  }
  self.tInfo.NumBoomLocs = 20
  self.sNorthCannon = "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunNorth\\OccMed_FlakGun_Base"
  self.sSouthCannon = "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunSouth\\OccMed_FlakGun_Base"
  self.tInfo.tFlakGuns = {
    "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunWest\\OccMed_FlakGun_Base",
    "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunEast\\OccMed_FlakGun_Base"
  }
  self.tInfo.Guard = "Missions\\paris_1\\mission_1b\\main\\Guard"
  self.sNorthCannonSeat = "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunNorth\\Seat"
  self.sSouthCannonSeat = "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunSouth\\Seat"
  self.sWestCannonSeat = "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunWest\\Seat"
  self.sEastCannonSeat = "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunEast\\Seat"
  self.tInfo.Vittore = "Missions\\paris_1\\mission_1b\\importantprisoners\\Vittore"
  self.sWestAA = "PARIS\\area01\\lavillette\\occupation\\defense\\AAGun_West\\OccMed_37mm_Mount"
  self.sSouthAA = "PARIS\\area01\\lavillette\\occupation\\defense\\AAGun_South\\OccMed_37mm_Mount"
  self.tInfo.sArmoryDoorLever = "PARIS\\area01\\lavillette\\occupation\\prison\\ArmoryDoorLever"
  self.bPrisonersAreFree = false
  self.tSaveInfo.hCar = nil
  self.tSaveInfo.bAllowCarpetBomb = false
  self.sStairsTop = "Missions\\paris_1\\mission_1b\\main\\LOC_StairsTop"
  self.sStairsBottom = "Missions\\paris_1\\mission_1b\\main\\LOC_StairsBottom"
  self.tInfo.LavaLuc = "Missions\\paris_1\\mission_1b\\cine2stuff\\Spore_RS_Luc"
  self.tInfo.sPrisonerExitSpot = "Missions\\paris_1\\mission_1b\\main\\LOC_PrisonerExit"
  self.tSaveInfo.ShotsOfFury = 0
  self.tInfo.KillMeNazi = "Missions\\paris_1\\mission_1b\\StealthTutGuy\\SPORE_Dock1(2)"
  self.nFinalTimerMax = 25
  self.tInfo.MAXSHOTS = 5
  self.tSaveInfo.TotalGunsDestroyed = 0
  self.tInfo.hFuryObj = false
  self.tInfo.hAirRaidFailTimer = false
  self.tSaveInfo.bDriveConv = false
  self.tInfo.sCellDoorLever = "Missions\\paris_1\\mission_1b\\main\\CellDoorLever"
  self.tSaveInfo.bBombingMusic = false
  self.tSaveInfo.eTooFarAway = false
  self.tSaveInfo.bAirRaidTimer = true
  self.tSaveInfo.eSafety = false
  self.tSaveInfo.bSafetyCheck = false
  self.bIsCannonDead = false
  self.tSaveInfo.bJuggernaught = false
  self.bAreCannonsDestroyed = false
  self.tSaveInfo.bFireVehConvo = false
  self.bWaitForFirstRun = true
  self.tSaveInfo.bDisguiseTutComplete = false
  self.tSaveInfo.bHarrassConv = false
  self.tSaveInfo.bWestGunDestroyed = false
  self.tSaveInfo.bEastGunDestroyed = false
  self.tSaveInfo.bSetUpdateLoop = false
  self.bRepeater = false
  self.tSaveInfo.eLuc1Fail = false
  self.tSaveInfo.eLuc2Fail = false
  self.tSaveInfo.eVitt1Fail = false
  self.tSaveInfo.bCalledFreePrisoners = false
  self.tInfo.sPrisoner3 = "Missions\\paris_1\\mission_1b\\importantprisoners\\Prisoner3"
  self.tInfo.sPrisoner5 = "Missions\\paris_1\\mission_1b\\importantprisoners\\Prisoner5"
  self.tInfo.sPrisoner1Path = "PARIS\\area01\\lavillette\\occupation\\prison\\Prisoner1Path"
  self.tInfo.sPrisoner2Path = "PARIS\\area01\\lavillette\\occupation\\prison\\Prisoner2Path"
  self.tInfo.sPrisoner3Path = "PARIS\\area01\\lavillette\\occupation\\prison\\Prisoner3Path"
  self.tInfo.WarningShots = {
    "PARIS\\area01\\lavillette\\airraidstuff\\LOC_Boom(7)",
    "PARIS\\area01\\lavillette\\airraidstuff\\LOC_Warning1",
    "PARIS\\area01\\lavillette\\airraidstuff\\LOC_Warning2",
    "PARIS\\area01\\lavillette\\airraidstuff\\LOC_Warning3",
    "PARIS\\area01\\lavillette\\airraidstuff\\LOC_Warning4",
    "PARIS\\area01\\lavillette\\airraidstuff\\LOC_Warning5",
    "PARIS\\area01\\lavillette\\airraidstuff\\LOC_Warning6",
    "PARIS\\area01\\lavillette\\airraidstuff\\LOC_Warning7",
    "PARIS\\area01\\lavillette\\airraidstuff\\LOC_Warning8",
    "PARIS\\area01\\lavillette\\airraidstuff\\LOC_Warning9",
    "PARIS\\area01\\lavillette\\airraidstuff\\LOC_Warning10",
    "PARIS\\area01\\lavillette\\airraidstuff\\LOC_Warning11"
  }
  self.sBritBomberTrig = "Missions\\paris_1\\mission_1b\\main\\FireBritBombers"
  self.bDoorEscalated = false
  self.bHasKEY = false
  self.bHasGot = false
  self.sCanalRestartLoc = "Missions\\paris_1\\mission_1b\\main\\Locator(5)"
  self:SetPrisonerStreamEvent()
end

function Paris_1_Mission_1B:MISSION_ONRESET()
  self:SetLavaDoor(true)
  self:ClearUpdateLoop()
  self:RemoveFuryMeter()
  Sound.ResetMusicLocale()
  Util.ClearDisguiseCallback()
  Paris_1_Mission_1B.PATH = nil
  Paris_1_Mission_1B.WORLDPATH = nil
  if Util.IsBlockLoaded("Missions\\paris_1\\mission_1b\\StealthTutGuy.wsd") then
    Util.UnloadEditNode("Missions\\paris_1\\mission_1b\\StealthTutGuy.wsd", true)
  end
end

function Paris_1_Mission_1B:MISSION_ONCOMPLETE()
end

function Paris_1_Mission_1B:CheckpointAlpha()
  EVENT_Timer("Paris_1_Mission_1B.GetOuttaBedSean", self, 3)
  EVENT_Timer("Paris_1_Mission_1B.TASK_FindLucInBelle", self, 5)
end

function Paris_1_Mission_1B:GetOuttaBedSean()
  AttractionPt.FinishNow(self.hWakeAttrpt)
end

function Paris_1_Mission_1B:TASK_FindLucInBelle()
  self:CreateTask({
    sName = "TASK_FindLucInBelle",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sObjectiveTextID = "P1M1B_Text.TASK_FindLucInBelle",
    bInteriorTask = true,
    sConvFile = "205_Con_ViletteBrief",
    tTgtInclude = {
      "Missions\\paris_1\\characters\\belle\\luc_belle_interior2\\Luc_Belle_Interior_2"
    },
    Proximity = 3,
    tOnFailure = {},
    tOnActivate = {
      {
        self.CheckForDLC,
        {self}
      }
    },
    tOnComplete = {
      {
        self.CancelDLCCallback,
        {self}
      },
      {
        self.ReEnableBelleDoor,
        {self}
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "Paris_1_Mission_1B.Checkpoint0"
        }
      }
    }
  })
end

function Paris_1_Mission_1B:CheckForDLC()
  if _g_bHasMidnightShowDLC then
    local hBelleDoor = Handle("PARIS\\area01\\belledenuit\\interior\\hq_int\\Belle_int_teleport")
    local hBelleDoor2 = Handle("PARIS\\area01\\belledenuit\\interior\\hq_int\\Belle_int_teleport(2)")
    AttractionPt.EnableUse(hBelleDoor, false)
    AttractionPt.EnableUse(hBelleDoor2, false)
    EVENT_Timer("Paris_1_Mission_1B.ListenForDLC", self, 0.5)
  end
end

function Paris_1_Mission_1B:CancelTalkToLuc()
  self:ResetTaskByName("TASK_FindLucInBelle", true)
  EVENT_Timer("Paris_1_Mission_1B.ListenForReEntry", self, 0.5)
end

function Paris_1_Mission_1B:CancelDLCCallback()
  if _g_bHasMidnightShowDLC then
    Util.CancelInteriorLoadCallback("Belle", true)
    Util.CancelInteriorLoadCallback("BelleDLC", true)
  end
end

function Paris_1_Mission_1B:ListenForDLC()
  Util.AddInteriorLoadCallback("BelleDLC", "Paris_1_Mission_1B.CancelTalkToLuc", self, {}, true)
end

function Paris_1_Mission_1B:ListenForReEntry()
  Util.AddInteriorLoadCallback("Belle", "Paris_1_Mission_1B.TASK_FindLucInBelle", self, {}, true)
end

function Paris_1_Mission_1B:ReEnableBelleDoor()
  local hBelleDoor = Handle("PARIS\\area01\\belledenuit\\interior\\hq_int\\Belle_int_teleport")
  AttractionPt.EnableUse(hBelleDoor, true)
end

function Paris_1_Mission_1B:SetupBelleGirlsScene()
  EVENT_PlayerToActorProximity("Paris_1_Mission_1B.CallbackBelleConv", self, "PARIS\\area01\\belledenuit\\interior\\hq_int\\LOC_BelleGirlsConv", 2)
end

function Paris_1_Mission_1B:CallbackBelleConv()
  EVENT_PlayerToActorProximity("Paris_1_Mission_1B.CallbackKillBelleConv", self, "PARIS\\area01\\belledenuit\\interior\\hq_int\\LOC_BelleGirlsConvOff", 1)
  EVENT_PlayerToActorProximity("Paris_1_Mission_1B.CallbackKillBelleConv", self, "PARIS\\area01\\belledenuit\\interior\\hq_int\\LOC_BelleGirlsConvOff2", 1)
  Cin.PlayConversation("P1M1_Belle_TaskStart")
end

function Paris_1_Mission_1B:CallbackKillBelleConv()
  Cin.InterruptConversation("P1M1_Belle_TaskStart")
end

function Paris_1_Mission_1B:CallbackVeronWalk()
  local self = Paris_1_Mission_1B
  local hVeronique = Handle("Missions\\paris_1\\characters\\belle\\veronique_interior\\Veronique_Belle_Interior")
  Combat.SetIdleScripted(hVeronique, true)
  local sVerPath = "Missions\\paris_1\\characters\\belle\\veronique_interior\\VeroniqueEntryPath"
  Nav.SetScriptedPath(hVeronique, sVerPath, false)
end

function Paris_1_Mission_1B:Checkpoint0()
  local hInteriorLuc = Handle("Missions\\paris_1\\characters\\belle\\luc_belle_interior2\\Luc_Belle_Interior_2")
  if hInteriorLuc then
    Actor.EnableNeeds(hInteriorLuc, false)
    Combat.SetIdleScripted(hInteriorLuc, true)
    Actor.OverrideCombatAI(hInteriorLuc, true)
    Joe.MakeSabFollower(hInteriorLuc, false, 2.5, cMOVE_FAST)
  end
  EVENT_PlayerEntersTrigger("Paris_1_Mission_1B.StopFollow", self, "Missions\\paris_1\\mission_1b\\main\\REG_Exit")
  self:TASK_ExitTheBelle()
  local hVeron = Handle("Missions\\paris_1\\characters\\belle\\veronique_interior\\Veronique_Belle_Interior")
  local hAttrPt = Handle("Missions\\paris_1\\characters\\belle\\luc_belle_interior2\\AttractionPT_Balcony2")
  if hVeron and hAttrPt then
    print("Veronique all leaning and shit")
    Actor.RequestAttrPt(hVeron, hAttrPt)
  end
end

function Paris_1_Mission_1B:StopFollow()
  local hInteriorLuc = Handle("Missions\\paris_1\\characters\\belle\\luc_belle_interior2\\Luc_Belle_Interior_2")
  if hInteriorLuc then
    Joe.ClearSabFollower(hInteriorLuc, false)
  end
end

function Paris_1_Mission_1B:TASK_ExitTheBelle()
  self:CreateTask({
    sName = "TASK_ExitTheBelle",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sObjectiveTextID = "P1M1_Text.TASK_ExitTheBelle",
    sInteriorName = "Belle",
    bInteriorTask = true,
    tLocators = {},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Paris_1_Mission_1B.Checkpoint1"
        }
      }
    },
    tOnActivate = {
      {
        self.LockBelleExt,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1B:LockBelleExt()
  local hBelleExtPT = Handle("PARIS\\area01\\belledenuit\\interior\\hq_ext\\Belle_ext_teleport")
  AttractionPt.EnableUse(hBelleExtPT, false)
end

function Paris_1_Mission_1B:UnlockBelleExt()
  local hBelleExtPT = Handle("PARIS\\area01\\belledenuit\\interior\\hq_ext\\Belle_ext_teleport")
  AttractionPt.EnableUse(hBelleExtPT, true)
end

function Paris_1_Mission_1B:Checkpoint1()
  self.tSaveInfo.eLuc1Fail = false
  self.tSaveInfo.eLuc2Fail = false
  Sound.LoadSoundBank("m_p1m1b_ingame.bnk")
  Train.TrainSystemEnable(false)
  self:SuspicionTutGo()
end

function Paris_1_Mission_1B:SuspicionTutSetup()
  self:UnlockBelleExt()
  Sound.ResetMusicLocale()
  Inventory.GiveItem(hSab, "WP_PS_Luger", true)
  Cin.PlayConversation("P1M1b_outside_Belle", "Paris_1_Mission_1B.PlayWeaponHideTutorial", self)
  Suspicion.SetSpecialCaseFillMultiplier(0.25)
  EVENT_Timer("Paris_1_Mission_1B.ResetSuspFillMult", self, 10)
end

function Paris_1_Mission_1B:ResetSuspFillMult()
  Suspicion.ClearSpecialCaseFillMultiplier()
end

function Paris_1_Mission_1B:PlayWeaponHideTutorial()
  EVENT_Timer("Paris_1_Mission_1B.NormalTime", self, 2)
  Saboteur.ShowToolTip("TutorialTip_Text.Weapon_Stow")
  self:TASK_TaxiLucToLV()
end

function Paris_1_Mission_1B:NormalTime()
end

function Paris_1_Mission_1B:SuspicionTutGo()
  Sound.SetMusicLocale("P1M1b_LaVilletteLiberate")
  Sound.SetMusicLocale("m_P1M1b_LaVilletteLiberate", "tutorial")
  Actor.SetLabel(hSab, "SuspicionTut", true)
  HUD.PlayAdvancedTutorial(cHTM_Tutorial_Suspicion, "Paris_1_Mission_1B.SuspicionTutSetup", self)
  EVENT_Timer("Paris_1_Mission_1B.CallbackPlayConv", self, 45, {
    {},
    "P1M1b_ToLaVillette_OMW"
  })
end

function Paris_1_Mission_1B:SuspTutDone()
  EVENT_Stream("Paris_1_Mission_1B.SuspicionTutSetup", self, self.tInfo.sLuc, true, {})
end

function Paris_1_Mission_1B:CallbackPlayConv(tArgs, sConvFile)
  local bPlayConv = true
  if sConvFile == "P1M1b_ToLaVillette_NearDrop" then
    if not Actor.IsInVehicle(hSab) then
      return
    end
  elseif sConvFile == "P1M1b_ToLaVillette_OMW" and Actor.IsInVehicle(hSab) then
    return
  end
  print("Playing conv ", sConvFile)
  Cin.PlayConversation(sConvFile)
end

function Paris_1_Mission_1B:SetupKillMeNazi()
  local hNazi = Handle(self.tInfo.KillMeNazi)
  if hNazi then
    Actor.OverrideCombatAI(hNazi, true)
  end
  local hRes = Handle("Missions\\paris_1\\mission_1b\\main\\ResBuddy")
  if hRes then
    Actor.OverrideCombatAI(hRes, true)
    Combat.SetIdleHoldWeapon(hRes, true)
  end
end

function Paris_1_Mission_1B:TASK_TaxiLucToLV()
  self:CreateTask({
    sName = "TASK_TaxiLucToLV",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "P1M1B_Text.TASK_TaxiLucToLV",
    tDestLocators = {
      "Missions\\paris_1\\mission_1b\\main\\TaxiDropOffLuc"
    },
    tPickupProxObj = {
      self.tInfo.sLuc
    },
    Proximity = 30,
    tDestRegion = {
      "Missions\\paris_1\\mission_1b\\main\\TaxiDropLuc"
    },
    tDeliverObjs = {
      self.tInfo.sLuc
    },
    bNoCarRequired = true,
    bGroundBlip = true,
    bEscalationDenial = true,
    tOnEarlyExit = {},
    tOnPickup = {
      {
        EVENT_ActorEntersAnyVehicle,
        {
          "Paris_1_Mission_1B.FireInCarConvo",
          self,
          self.tInfo.sLuc
        }
      }
    },
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Paris_1_Mission_1B.Checkpoint2"
        }
      }
    },
    tOnActivate = {
      {
        EVENT_PlayConversationDelayed,
        {
          "P1M1b_ToLaVillette_ExitBelle",
          5,
          self
        }
      },
      {
        self.SetupBritBombersTrig,
        {self}
      },
      {
        self.SetupLucFail,
        {
          self,
          self.tInfo.sLuc
        }
      },
      {
        self.SetupLucP1M1B,
        {self}
      },
      {
        self.TASK_YouFail,
        {self}
      },
      {
        self.SetupCallbackPlayConv,
        {self}
      }
    },
    tSMEDNodes = {}
  })
end

function Paris_1_Mission_1B:SetupCallbackPlayConv()
  EVENT_ActorEntersTrigger("Paris_1_Mission_1B.CallbackPlayConv", self, self.tInfo.sLuc, "Missions\\paris_1\\mission_1b\\main\\TaxiGetCarHandle", {
    "P1M1b_ToLaVillette_NearDrop"
  })
end

function Paris_1_Mission_1B:SetupLucFail(thisLuc)
  if not self.tSaveInfo.eLuc1Fail then
  end
end

function Paris_1_Mission_1B:SetupLucFail2(thisLuc)
  if not self.tSaveInfo.eLuc2Fail then
  end
end

function Paris_1_Mission_1B:SetupVittoreFail()
  if not self.tSaveInfo.eVitt1Fail then
  end
end

function Paris_1_Mission_1B:TASK_BombFailZFirst()
  self:CreateTask({
    sName = "TASK_BombFailZFirst",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "P1M1B_CinFinalBomb_Fail",
    bOverrideFade = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.StopBombers,
        {self}
      }
    },
    tSMEDNodes = {},
    tCinematicNodes = {"cine3stuff"}
  })
end

function Paris_1_Mission_1B:StopBombers()
  local bSCHandle = Util.GetHandleByName("Missions\\paris_1\\mission_1b\\main\\BASE_LaVillette")
  BASE_LaVillette.StopBomberCinematics(Actor.GetSelf(bSCHandle))
  self:VittoreDied()
end

function Paris_1_Mission_1B:TASK_BombFail()
  self:CreateTask({
    sName = "TASK_BombFail",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "P1M1B_CinFinalBomb_Fail",
    bOverrideFade = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.VittoreDied,
        {self}
      }
    },
    tSMEDNodes = {},
    tCinematicNodes = {"cine3stuff"}
  })
end

function Paris_1_Mission_1B:VittoreDied()
  if self.tSaveInfo.eVitt1Fail then
    self.tSaveInfo.eVitt1Fail = false
  end
  if self.tInfo.hAirRaidFailTimer then
    HUD.RemoveObjective(self.tInfo.hAirRaidFailTimer)
    self.tInfo.hAirRaidFailTimer = nil
  end
  self:MissionTaskFail("P1M1B_Text.FAIL_VittoreDied")
end

function Paris_1_Mission_1B:LucDied()
  if self.tSaveInfo.eLuc1Fail then
    self.tSaveInfo.eLuc1Fail = false
  end
  if self.tSaveInfo.eLuc2Fail then
    self.tSaveInfo.eLuc2Fail = false
  end
  self:MissionTaskFail("Char_Death.RS_Luc")
end

function Paris_1_Mission_1B:PlayAnnouncementConv()
  if not self.nExecutionAnnouncements then
    self.nExecutionAnnouncements = 1
  end
  if self.nExecutionAnnouncements == 1 then
    self.PlaySound("vo_mis_P1M1b_AnnounceKillPrisoners_NaziAdministrator_01")
  end
  if self.nExecutionAnnouncements == 2 then
    self.PlaySound("vo_mis_P1M1b_AnnounceDead2_NaziAdministrator_02")
  end
  if self.nExecutionAnnouncements == 3 then
    self.PlaySound("vo_mis_P1M1b_AnnounceDead3_NaziAdministrator_02")
  end
  if self.nExecutionAnnouncements == 4 then
    self.PlaySound("vo_mis_P1M1b_AnnounceDeadAll_NaziAdminstrator_02")
  end
  self.nExecutionAnnouncements = self.nExecutionAnnouncements + 1
end

function Paris_1_Mission_1B:GetDeadCannonCount()
  local nDeadCannons = 0
  for i, sCannon in ipairs(self.tInfo.tFlakGuns) do
    if Object.IsAlive(Handle(sCannon)) == false then
      nDeadCannons = nDeadCannons + 1
    end
  end
  return nDeadCannons
end

function Paris_1_Mission_1B.PlaySound(a_sSound)
  local hSoundEmitter = Handle("PARIS\\area01\\lavillette\\occupation\\Siren_AirRaid")
  Sound.AttachSounSetupGamepadListenerdEvent(hSoundEmitter, a_sSound)
end

function Paris_1_Mission_1B:TASK_YouFail()
  self:CreateTask({
    sName = "TASK_YouFail",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDeliverObjs = {hSab},
    tDestRegion = {
      "Missions\\paris_1\\mission_1b\\main\\BailTrigVillette"
    },
    tOnComplete = {
      {
        self.FailCheck,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1B:FailCheck()
  if not self:IsMissionTaskComplete("TASK_GetDisguise") then
    self.MissionTaskFail(self, "P1M1B_Text.FAIL_FollowDirections")
  elseif Actor.IsDisguised(hSab) == true then
    self:CompleteTaskByName("TASK_TakeSewer")
    self:CompleteTaskByName("TASK_GoToLaVillette")
  else
    self.MissionTaskFail(self, "P1M1B_Text.FAIL_FollowDirections")
  end
end

function Paris_1_Mission_1B:TASK_GoToLaVillette()
  self:CreateTask({
    sName = "TASK_GoToLaVillette",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDeliverObjs = {hSab},
    sObjectiveTextID = "P1M1B_Text.TASK_GoThroughTunnel",
    tDestRegion = {
      "Missions\\paris_1\\mission_1b\\main\\Deliver_Villette"
    },
    tLocators = {
      "Missions\\paris_1\\mission_1b\\main\\LOC_Lava"
    },
    tSMEDNodes = {},
    tOnComplete = {
      {
        self.DelayedDisguiseUseTutorial,
        {self}
      },
      {
        self.TASK_GoInsideLaVillette,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Paris_1_Mission_1B:TASK_GoInsideLaVillette()
  self:CreateTask({
    sName = "TASK_GoInsideLaVillette",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "P1M1B_Text.TASK_GoToLaVillette",
    sTaskSubType = "GOTO",
    tDeliverObjs = {hSab},
    tSMEDNodes = {},
    tDestRegion = {
      "Missions\\paris_1\\mission_1b\\main\\SaviorTrig"
    },
    tLocators = {
      "Missions\\paris_1\\mission_1b\\main\\LOC_Lava"
    },
    tOnComplete = {
      {
        self.TASK_KillGuard,
        {self}
      }
    },
    tOnActivate = {
      {
        self.OnGSStream,
        {self}
      },
      {
        self.SendKubelOut,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1B:TASK_GoToLaVilletteObj()
  self:CreateTask({
    sName = "TASK_GoToLaVilletteObj",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "GOTO",
    tLocators = {
      "Missions\\paris_1\\mission_1b\\main\\LOC_Lava"
    },
    tOnActivate = {
      {
        self.OnGSStream,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1B:TASK_TakeSewer()
  self:SetupStealthKillTutListener()
  self:CreateTask({
    sName = "TASK_TakeSewer",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P1M1B_Text.OPTIONAL_TakeSewer",
    tDeliverObjs = {hSab},
    tDestRegion = {
      "Missions\\paris_1\\mission_1b\\main\\SewerTrig"
    },
    tLocators = {
      "Missions\\paris_1\\mission_1b\\main\\LOC_Sewer"
    },
    tOnComplete = {
      {
        self.CycleBail,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Paris_1_Mission_1B:LucRunTo(vLoc, fCallback)
  local hLoc = Handle(vLoc)
  Actor.OverrideCombatAI(Util.GetHandleByName(self.tInfo.sLuc), true)
  Nav.MoveToObject(Handle(self.tInfo.sLuc), hLoc, 2, true, "Paris_1_Mission_1B.SetFacing", self, {
    self.tInfo.sLuc,
    "Missions\\paris_1\\mission_1b\\main\\LOC_Sewer"
  })
end

function Paris_1_Mission_1B:TASK_FollowLuc()
  self:CreateTask({
    sName = "TASK_FollowLuc",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sObjectiveTextID = "P1M1B_Text.TASK_FollowLuc",
    bAutofire = true,
    sConvFile = "P1M1b_Vilette_GetDisguise",
    tTgtInclude = {
      self.tInfo.sLuc
    },
    Proximity = 2,
    tOnFailure = {
      {
        Render.PrintMessage,
        {
          "Player is in Escalation"
        }
      }
    },
    tOnComplete = {
      {
        self.SneakMusic,
        {self}
      },
      {
        self.PlayMusica,
        {self}
      },
      {
        self.FailTaskByName,
        {
          self,
          "TASK_MinorEscalator"
        }
      }
    },
    tOnConversationComplete = {
      {
        EVENT_Timer,
        {
          "Paris_1_Mission_1B.PlayDisguiseUseTut",
          self,
          1
        }
      },
      {
        self.RunLucSequence,
        {self}
      },
      {
        self.TASK_DisguiseNazi,
        {self}
      },
      {
        self.SetupTimerBar,
        {self}
      }
    },
    tSMEDNodes = {}
  })
end

function Paris_1_Mission_1B:PlayDisguiseUseTut()
  Actor.SetLabel(hSab, "DisguiseTut", true)
  HUD.SetTemplate(cHTM_Tutorial_Disguise)
end

function Paris_1_Mission_1B:SetupTimerBar()
  self.tInfo.hAirRaidFailTimer = HUD.AddObjective(eOT_TIMER, self:GetLocalizedText("GenericObjective_Text.BAR_Time_Remaining"), 2)
  HUD.SetupProgressBar(self.tInfo.hAirRaidFailTimer, self.nTimerMax, 0, self.nInitial)
  HUD.AddProgressBarCallback(self.tInfo.hAirRaidFailTimer, "Paris_1_Mission_1B.OnFirstBarFail", 0, self, {})
end

function Paris_1_Mission_1B:OnFirstBarFail()
  local bSCHandle = Util.GetHandleByName("Missions\\paris_1\\mission_1b\\main\\BASE_LaVillette")
  BASE_LaVillette.StartAirRaid(Actor.GetSelf(bSCHandle))
  self:TASK_BombFailZFirst()
end

function Paris_1_Mission_1B:SetupFinalTimerBar()
  self.tInfo.hFinalTimer = HUD.AddObjective(eOT_TIMER, self:GetLocalizedText("GenericObjective_Text.BAR_Time_Remaining"), 2)
  HUD.SetupProgressBar(self.tInfo.hFinalTimer, self.nFinalTimerMax, 0, self.nFinalTimerMax)
  HUD.AddProgressBarCallback(self.tInfo.hFinalTimer, "Paris_1_Mission_1B.TASK_BombFail", 0, self, {})
end

function Paris_1_Mission_1B:KillSean()
  Object.Kill(hSab)
end

function Paris_1_Mission_1B:TASK_Escalator()
  self:CreateTask({
    sName = "TASK_Escalator",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = true,
    tOnComplete = {
      {
        self.CallbackEscalation,
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

function Paris_1_Mission_1B:TASK_LostEscalation()
  self:CreateTask({
    sName = "TASK_LostEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "P1M1B_Text.TASK_LostEscalation",
    EscalationLevel = 0,
    tLocators = {
      "Missions\\paris_1\\mission_1b\\main\\Locator(6)",
      "Missions\\paris_1\\mission_1b\\main\\Locator(4)",
      "Missions\\paris_1\\mission_1b\\main\\Locator(7)",
      "PARIS\\area01\\lavillette\\occupation\\defense\\Locator(9)"
    },
    tOnComplete = {
      {
        self.CallbackDeEscalation,
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
      }
    },
    tOnActivate = {
      {
        Saboteur.ShowToolTip,
        {
          "TutorialTip_Text.Escalation_Alarm",
          4000,
          nil,
          true
        }
      }
    }
  })
end

function Paris_1_Mission_1B:CallbackEscalation()
  self:EscalationMusic()
  self:CheckForActiveTasks()
  self.bDoorEscalated = true
  if Handle(self.tInfo.sCellDoorLever) ~= nil then
  else
  end
end

function Paris_1_Mission_1B:CallbackDeEscalation()
  Util.ClearAllPendingTutorials()
  self:ResetCurrentMissionTask()
  self.bDoorEscalated = false
end

function Paris_1_Mission_1B:SneakMusic()
  print("cue sneak music")
end

function Paris_1_Mission_1B:EscalationMusic()
end

function Paris_1_Mission_1B:FreedMusic()
  print("cue freed music")
  Sound.SetMusicLocale("P1M1b_LaVilletteLiberate")
  Sound.SetMusicLocale("m_P1M1b_LaVilletteLiberate", "getToCellar")
end

function Paris_1_Mission_1B:BombingMusic()
  print("cue bombing music")
  self.tSaveInfo.bBombingMusic = true
end

function Paris_1_Mission_1B:RunLucSequence()
  EVENT_Timer("Paris_1_Mission_1B.GetLucAway", self, 2)
end

function Paris_1_Mission_1B:SetupGetCarTrig()
end

function Paris_1_Mission_1B:GetHandleOfCar()
  local hCar = Actor.GetVehicle(hSab)
  self.tSaveInfo.hCar = hCar
end

function Paris_1_Mission_1B:FireInCarConvo()
  if not self.tSaveInfo.bDriveConv then
    self.tSaveInfo.bDriveConv = true
    Cin.PlayConversation("P1M1b_ToLaVillette_InVehicle", "Paris_1_Mission_1B.DelaytoDrivingConvo", self)
  end
end

function Paris_1_Mission_1B:DelaytoDrivingConvo(tArgs)
  if not self.tSaveInfo.bFireVehConvo then
    self.tSaveInfo.bFireVehConvo = true
    EVENT_Timer("Paris_1_Mission_1B.FireDrivingConvo", self, 3)
  end
end

function Paris_1_Mission_1B:FireDrivingConvo()
  if Actor.IsInVehicle(hSab) then
    Cin.PlayConversation("P1M1b_ToLaVillette_Driving01")
  end
end

function Paris_1_Mission_1B:StartAndStopBoat()
end

function Paris_1_Mission_1B:SetupLucP1M1B()
  Object.SetInvincibleToAI(Util.GetHandleByName(self.tInfo.sLuc), true)
end

function Paris_1_Mission_1B:CycleBail()
  if self.tSaveInfo.eBail then
    Util.KillEvent(self.tSaveInfo.eBail)
    self.tSaveInfo.eBail = nil
  end
  if self:IsMissionTaskActive("TASK_MinorEscalator") then
    self:FailTaskByName("TASK_MinorEscalator")
  end
  if Actor.IsDisguised(hSab) == true then
    local hLoc = Handle(self.sCanalRestartLoc)
    self:RegisterCheckpoint("Paris_1_Mission_1B.Checkpoint3", "Paris_1_Mission_1B.Checkpoint3Once", false, hLoc)
  else
    self:Checkpoint3Once()
  end
end

function Paris_1_Mission_1B:EnablePrisonDoor(bEnable)
  AttractionPt.EnableUse(Handle(self.tInfo.sCellDoorLever), bEnable)
end

function Paris_1_Mission_1B:Checkpoint2()
  if self.tInfo.hAirRaidFailTimer then
    HUD.RemoveObjective(self.tInfo.hAirRaidFailTimer)
    self.tInfo.hAirRaidFailTimer = nil
  end
  self:LucRunTo("Missions\\paris_1\\mission_1b\\main\\LucRunPoint")
  EVENT_Timer("Paris_1_Mission_1B.TASK_FollowLuc", self, 3)
  EVENT_Timer("Paris_1_Mission_1B.TASK_MinorEscalator", self, 3)
  if not self:IsMissionTaskActive("TASK_YouFail") and not self:IsMissionTaskComplete("TASK_YouFail") then
    self.TASK_YouFail(self)
  end
end

function Paris_1_Mission_1B:SetupTooFarAwayFail()
  self:ClearTooFarAwayFail()
  if not self.tSaveInfo.eTooFarAway then
    self.tSaveInfo.eTooFarAway = EVENT_PlayerExitsTrigger("Paris_1_Mission_1B.TooFarAwayFail", self, "Missions\\paris_1\\mission_1b\\main\\REG_FailTooFar")
  end
end

function Paris_1_Mission_1B:ClearTooFarAwayFail()
  if self.tSaveInfo.eTooFarAway then
    if Util.IsHandleValid(Util.GetHandleByName("Missions\\paris_1\\mission_1b\\main\\REG_FailTooFar")) then
      print("clear too far away")
      Trigger.ClearCallback(Util.GetHandleByName("Missions\\paris_1\\mission_1b\\main\\REG_FailTooFar"), self.tSaveInfo.eTooFarAway)
    end
    self.tSaveInfo.eTooFarAway = false
  end
end

function Paris_1_Mission_1B:TooFarAwayFail()
  print("fail too far away")
  self:MissionTaskFail("P1M1B_Text.FAIL_TooFarAway")
end

function Paris_1_Mission_1B:TASK_DisguiseNazi()
  if self:IsMissionTaskActive("TASK_MinorEscalator") then
    self:FailTaskByName("TASK_MinorEscalator")
  end
  self:CreateTask({
    sName = "TASK_DisguiseNazi",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "kill",
    tTgtInclude = {
      self.tInfo.KillMeNazi
    },
    tOnActivate = {
      {
        self.TASK_GetDisguise,
        {self}
      }
    },
    tOnComplete = {
      {
        self.CheckLoopDisguise,
        {self}
      },
      {
        self.TASK_CanGetDisguise,
        {self}
      },
      {
        self.PlayDisguiseEquip,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1B:CheckLoopDisguise()
  local hNazi = Handle(self.tInfo.KillMeNazi)
  if hNazi and Actor.IsDisguisable(hNazi) then
    EVENT_Timer("Paris_1_Mission_1B.CheckforWaterFail", self, 4)
    Actor.SetNeverBloodyDisguise(hNazi, true)
    local tStreamOutDisg = {
      EventType = "StreamEvent",
      Objects = {hNazi},
      WaitForStreamOut = true
    }
    self.eRegDisguiseEvent = Util.CreateEvent(tStreamOutDisg, "Paris_1_Mission_1B.YouDidntListen", self)
    self:RegisterEvent(self.eRegDisguiseEvent)
  else
    self:MissionTaskFail("P1M1B_Text.FAIL_BadDisguise")
  end
end

function Paris_1_Mission_1B:YouDidntListen()
  self.MissionTaskFail(self, "P1M1B_Text.FAIL_TooFarAway")
end

function Paris_1_Mission_1B:CheckforWaterFail()
  local hNazi = Handle(self.tInfo.KillMeNazi)
  if Actor.IsRagdollInWater(hNazi) == true then
    self:MissionTaskFail("P1M1B_Text.FAIL_BadDisguise")
  else
  end
end

function Paris_1_Mission_1B:PlayMusica()
  Sound.SetMusicLocale("P1M1b_LaVilletteLiberate")
  Sound.SetMusicLocale("m_P1M1b_LaVilletteLiberate", "freePrisoners")
end

function Paris_1_Mission_1B:TASK_GetDisguise()
  self:CreateTask({
    sName = "TASK_GetDisguise",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    sObjectiveTextID = "P1M1B_Text.TASK_GetDisguise",
    tOnActivate = {
      {
        self.SetListenerforDisguise,
        {self}
      },
      {
        self.SetDisguiseTutListener,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TASK_TakeSewer,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1B:TASK_CanGetDisguise()
  self:CreateTask({
    sName = "TASK_CanGetDisguise",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "FETCH",
    tTgtInclude = {
      self.tInfo.KillMeNazi
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.CancelFailProx,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1B:CancelFailProx()
  Util.KillEvent(self.eRegDisguiseEvent)
end

function Paris_1_Mission_1B:MoreKillMeSetup()
  local hNazi = Handle(self.tInfo.KillMeNazi)
  if hNazi then
    print("setup killme nazi")
    Object.SetHealth(hNazi, 1)
    Actor.SetUseHitReactions(hNazi, false)
    Suspicion.Enable(hNazi, false)
  end
end

function Paris_1_Mission_1B:SetListenerforDisguise()
  Util.DisableDisguising(false)
  Util.SetDisguiseCallback("Paris_1_Mission_1B.CompleteGetDisguise", self)
end

function Paris_1_Mission_1B:CompleteGetDisguise()
  print("got disguise")
  if not self.tSaveInfo.bDisguiseTutComplete then
    EVENT_PlayConversationDelayed("P1M1b_Vilette_DisguiseGood", 4, self)
  end
  Util.ClearDisguiseCallback()
  Util.ClearAllPendingTutorials()
  self.tSaveInfo.bDisguiseTutComplete = true
  if self:IsMissionTaskActive("TASK_CanGetDisguise") then
    self:CompleteTaskByName("TASK_CanGetDisguise")
  end
  self:CompleteTaskByName("TASK_GetDisguise")
end

function Paris_1_Mission_1B:TASK_CrateTutorial()
  self:CreateTask({
    sName = "TASK_CrateTutorial",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDeliverObjs = {hSab},
    tDestRegion = {
      "Missions\\paris_1\\mission_1b\\main\\REG_CrateTut"
    },
    tOnComplete = {
      {
        Saboteur.ShowToolTip,
        {
          "TutorialTip_Text.Supply_Crates",
          20,
          nil,
          true
        }
      }
    }
  })
end

function Paris_1_Mission_1B:Checkpoint3()
  print("__Checkpoint 3")
  self.tSaveInfo.eVitt1Fail = false
  Suspicion.ResetEscalation()
  self:TASK_GoToLaVillette()
  self:StreamDoorUsePt()
  self:SetupTooFarAwayFail()
  self:SetupVittoreFail()
  self:ListenForNearGS()
  if not self:IsMissionTaskActive("TASK_Escalator") and not self:IsMissionTaskComplete("TASK_Escalator") then
    self:TASK_Escalator()
  end
  if self.tInfo.hAirRaidFailTimer then
    HUD.RemoveObjective(self.tInfo.hAirRaidFailTimer)
    self.tInfo.hAirRaidFailTimer = nil
  end
  self.nInitial = 400
  self:SetupTimerBar()
  Render.FadeScreen(false)
  EVENT_ActorEntersTrigger("Paris_1_Mission_1B.PlayNaziAmbientConvo", self, hSab, "Missions\\paris_1\\mission_1b\\main\\PT_NaziGruntConvo")
  Util.SpawnEditNode("Missions\\paris_1\\mission_1b\\importantprisoners.wsd")
end

function Paris_1_Mission_1B:Checkpoint3Once()
  self.tSaveInfo.eVitt1Fail = false
  Suspicion.ResetEscalation()
  self:TASK_GoToLaVillette()
  self:StreamDoorUsePt()
  self:SetupTooFarAwayFail()
  self:SetupVittoreFail()
  self:ListenForNearGS()
  if not self:IsMissionTaskActive("TASK_Escalator") and not self:IsMissionTaskComplete("TASK_Escalator") then
    self:TASK_Escalator()
  end
  Render.FadeScreen(false)
  EVENT_ActorEntersTrigger("Paris_1_Mission_1B.PlayNaziAmbientConvo", self, hSab, "Missions\\paris_1\\mission_1b\\main\\PT_NaziGruntConvo")
  Util.SpawnEditNode("Missions\\paris_1\\mission_1b\\importantprisoners.wsd")
end

function Paris_1_Mission_1B:PlayNaziAmbientConvo()
  if Actor.IsDisguised(hSab) == true then
    Cin.PlayConversation("P1M1b_EnterLaVillette_Ambient01")
  else
  end
end

function Paris_1_Mission_1B:DelayedDisguiseUseTutorial()
  Saboteur.ShowToolTip("TutorialTip_Text.Disguise_Use", 15, nil, true)
  EVENT_Timer("Paris_1_Mission_1B.DelayedDisguiseTipsTutorial", self, 15)
end

function Paris_1_Mission_1B:DelayedDisguiseTipsTutorial()
  Saboteur.ShowToolTip("TutorialTip_Text.Disguise_Tips")
end

function Paris_1_Mission_1B:GetLucAway()
  local sLucDriveAwayPath = "Missions\\paris_1\\mission_1b\\main\\LucDriveAwayPath"
  if true then
    repeat
      do break end -- pseudo-goto
      print("drive away ", self.tSaveInfo.hCar)
      Vehicle.LockAllSeats(self.tSaveInfo.hCar)
      Nav.SetScriptedPath(self.tSaveInfo.hCar, sLucDriveAwayPath, true)
      Nav.SetScriptedPathSpeed(self.tSaveInfo.hCar, 20)
    until true
  else
    print("walk away on foot")
    local hLuc = Handle(self.tInfo.sLuc)
    Inventory.GiveItem(hLuc, "WP_PS_WaltherPPK", true)
    Nav.SetScriptedPath(hLuc, sLucDriveAwayPath, true)
    Nav.SetScriptedPathMoveMode(hLuc, true)
  end
end

function Paris_1_Mission_1B:SetupPlaneCrashTrigger()
  local sPlaneCrashTrig = "Missions\\paris_1\\mission_1b\\main\\PlaneCrashTrig"
  EVENT_PlayerEntersTrigger("Paris_1_Mission_1B.MakePlaneCrash", self, "Missions\\paris_1\\mission_1b\\main\\PlaneCrashTrig")
end

function Paris_1_Mission_1B:MakePlaneCrash()
  Cin.PlayCinematic("P1M1BPlaneCrash")
end

function Paris_1_Mission_1B:MakePlaneBoom()
  self = Paris_1_Mission_1B
  local hCrashyBoomLoc = Util.GetHandleByName("Missions\\paris_1\\mission_1b\\CrashingPlaneCine\\CrashyBoomLoc")
  local x, y, z = Object.GetPosition(hCrashyBoomLoc)
  Util.CreateExplosion("Explosion_Medium", x, y, z)
end

function Paris_1_Mission_1B:TASK_FreePrisonersFromCells()
  self:CreateTask({
    sName = "TASK_FreePrisonersFromCells",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "Blah",
    sObjectiveTextID = "P1M1B_Text.TASK_FreePrisonersFromCells",
    tLocators = {
      self.tInfo.sCellDoorLever
    },
    MarkerHeight = 2,
    tOnActivate = {
      {
        self.DelaytoEscaCheck,
        {self}
      },
      {
        self.EnablePrisonDoor,
        {self, true}
      }
    },
    tOnComplete = {
      {
        self.RemoveTimer,
        {self}
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "Paris_1_Mission_1B.Checkpoint4"
        }
      }
    }
  })
end

function Paris_1_Mission_1B:GoDisgRemovalTut()
  Saboteur.ShowToolTip("TutorialTip_Text.Disguise_Remove", 20, nil, true)
end

function Paris_1_Mission_1B:DelaytoEscaCheck()
  EVENT_Timer("Paris_1_Mission_1B.CheckForCurrentEsc", self, 2)
end

function Paris_1_Mission_1B:CheckForCurrentEsc()
  if Suspicion.GetEscalation() >= 1 then
    self:EnablePrisonDoor(false)
    Saboteur.ShowToolTip("TutorialTip_Text.Escalation_Alarm")
  else
  end
end

function Paris_1_Mission_1B:RemoveTimer()
  OnDisables()
  HUD.RemoveObjective(self.tInfo.hAirRaidFailTimer)
end

function Paris_1_Mission_1B:SetPrisonersFreeFlag(a_bAreFree)
  self.bPrisonersAreFree = a_bAreFree
end

function Paris_1_Mission_1B:TASK_VittoreSaved()
  self:CreateTask({
    sName = "TASK_VittoreSaved",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sObjectiveTextID = "P1M1B_Text.TASK_TalkVittore",
    bAutofire = true,
    Proximity = 20,
    sConvFile = "P1M1b_Rescue_Complete_AAPlan",
    tTgtInclude = {
      self.tInfo.Vittore
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.PrisonerHelperFunction,
        {self}
      },
      {
        self.TASK_GetToSafeHouse,
        {self}
      },
      {
        self.SetupFinalTimerBar,
        {self}
      }
    },
    tSMEDNodes = {}
  })
end

function Paris_1_Mission_1B:SetVittToPoint()
  local hVitt = Handle(self.tInfo.Vittore)
  Combat.SetIdleScripted(hVitt, true)
  Nav.MoveToObject(hVitt, Handle("Missions\\paris_1\\mission_1b\\main\\FreeprisLoc"), 0.3, false, "Paris_1_Mission_1B.TASK_VittoreSaved", self)
  EVENT_Timer("Paris_1_Mission_1B.SafetyDance", self, 7)
end

function Paris_1_Mission_1B:SafetyDance()
  if Cin.IsHumanInConversation(hSab) == false then
    self:TASK_VittoreSaved()
  else
  end
end

function Paris_1_Mission_1B:LoadLucRelatedNodes()
  Util.SpawnEditNode("Missions\\paris_1\\mission_1b\\cine2stuff.wsd")
end

function Paris_1_Mission_1B:LucInjuredSeq()
  local hVitt = Handle(self.tInfo.Vittore)
  local hLuc = Handle(self.tInfo.LavaLuc)
  local hLoc = Handle("Missions\\paris_1\\mission_1b\\main\\LOC_VittTalk")
  if hVitt then
    print("vitt move to luc")
    Combat.SetIdleScripted(hVitt, true)
    Nav.MoveToObject(hVitt, hLoc, 0.5, true, "Paris_1_Mission_1B.VittoreFinishedMove", self, {hVitt, hLuc})
  end
end

function Paris_1_Mission_1B:VittoreFinishedMove(hVitt, hLuc)
  print("vitt finished move", hVitt, hLuc)
  self:SetFacing(hVitt, hLuc)
end

function Paris_1_Mission_1B:LucInjured()
  local hLuc = Handle(self.tInfo.LavaLuc)
  if hLuc then
    Actor.PlayAnimation(hLuc, "civ_m_stand_gutshot")
  end
  self:LucInjuredSeq()
end

function Paris_1_Mission_1B:SendLucIntoTheScene()
  self = Paris_1_Mission_1B
  local sWoundedLucPath = "Missions\\paris_1\\mission_1b\\cine2stuff\\WoundedLucRunPath"
  local hLuc = Util.GetHandleByName(self.tInfo.LavaLuc)
  Actor.SetTalkable(hLuc, false)
  Inventory.GiveItem(hLuc, "WP_PS_WaltherPPK", true)
  local hGuard = Handle(self.tInfo.Guard)
  if hGuard and Object.IsAlive(hGuard) then
    Object.Kill(hGuard)
  end
  Actor.OverrideCombatAI(hLuc, true)
  Combat.SetIdleScripted(hLuc, true)
  Paris_1_Mission_1B.SeriouslyIWantYouStandingHERE(self)
end

function Paris_1_Mission_1B.ConvCallbackLucHurtingBad()
  Paris_1_Mission_1B:LucInjured()
end

function Paris_1_Mission_1B:SeriouslyIWantYouStandingHERE()
  local hLuc = Util.GetHandleByName(self.tInfo.LavaLuc)
  local hLoc = Handle("Missions\\paris_1\\mission_1b\\main\\LOC_LucTalk")
  Nav.MoveToObject(hLuc, hLoc, 0.5, true)
end

function Paris_1_Mission_1B:MakeLucsMouthMove()
  print("MakeLucsMouthMove")
  local hVittore = Util.GetHandleByName(self.tInfo.Vittore)
  if Cin.IsHumanInConversation(hVittore) == false then
    self:TASK_LucTalkHouse()
  else
    EVENT_Timer("Paris_1_Mission_1B.MakeLucsMouthMove", self, 1)
  end
end

function Paris_1_Mission_1B:TASK_LucTalkHouse()
  self:CreateTask({
    sName = "TASK_LucTalkHouse",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sObjectiveTextID = "P1M1B_Text.TASK_TalkLuc",
    bAutofire = true,
    Proximity = 20,
    bNoBlips = true,
    sConvFile = "P1M1b_Vilette_AAPlan",
    tTgtInclude = {
      self.tInfo.LavaLuc
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.PrisonerHelperFunction,
        {self}
      },
      {
        self.TASK_GetToSafeHouse,
        {self}
      },
      {
        self.SetupFinalTimerBar,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1B:PrisonerHelperFunction()
  OffDisables()
  Actor.CancelAnimation(Handle(self.tInfo.LavaLuc))
  EVENT_Timer("Paris_1_Mission_1B.MakeThisPrisonerGo", self, 1.25, {
    self.tInfo.Vittore,
    "Missions\\paris_1\\mission_1b\\main\\PATH_VL",
    cMOVE_FAST,
    true
  })
  EVENT_Timer("Paris_1_Mission_1B.MakeThisPrisonerGo", self, 1, {
    self.tInfo.LavaLuc,
    "Missions\\paris_1\\mission_1b\\main\\PATH_VL",
    cMOVE_FAST,
    true
  })
  self:MakePrisonersGo()
end

function Paris_1_Mission_1B:DontYouFailMeLuc()
  print("dont fail me luc")
  if not self.tSaveInfo.bSafetyCheck then
    if self.tSaveInfo.eSafety then
      Util.KillEvent(self.tSaveInfo.eSafety)
      self.tSaveInfo.eSafety = false
    end
    self.tSaveInfo.bSafetyCheck = true
    self:TASK_FindASeat()
    self:PlayBombersGo()
    self:SetupGunDeaths()
    Actor.CancelAnimation(Handle(self.tInfo.LavaLuc))
    EVENT_Timer("Paris_1_Mission_1B.MakeThisPrisonerGo", self, 1.25, {
      self.tInfo.Vittore,
      "Missions\\paris_1\\mission_1b\\main\\PATH_VL",
      cMOVE_FAST,
      true
    })
    EVENT_Timer("Paris_1_Mission_1B.MakeThisPrisonerGo", self, 1, {
      self.tInfo.LavaLuc,
      "Missions\\paris_1\\mission_1b\\main\\PATH_VL",
      cMOVE_FAST,
      true
    })
    self:MakePrisonersGo()
  end
end

function Paris_1_Mission_1B:LucCineStream()
  EVENT_Stream("Paris_1_Mission_1B.LucCineActions", self, "Missions\\paris_1\\mission_1b\\LucCineStuff\\Spore_RS_Luc")
end

function Paris_1_Mission_1B:PlayBombersGo()
  local bSCHandle = Util.GetHandleByName("Missions\\paris_1\\mission_1b\\main\\BASE_LaVillette")
  BASE_LaVillette.StopBomberCinematics(Actor.GetSelf(bSCHandle))
  BASE_LaVillette.StartAirRaid(Actor.GetSelf(bSCHandle))
end

function Paris_1_Mission_1B:PlayBombsGo()
  local bSCHandle = Util.GetHandleByName("Missions\\paris_1\\mission_1b\\main\\BASE_LaVillette")
end

function Paris_1_Mission_1B:FreePrisoners()
  self.tSaveInfo.bCalledFreePrisoners = true
  local bHandle = Util.GetHandleByName("Missions\\paris_1\\mission_1b\\main\\BASE_LaVillette")
  BASE_LaVillette.OnBunkersReady(Actor.GetSelf(bHandle))
  if self:GetDeadCannonCount() < #self.tInfo.tFlakGuns then
  else
  end
end

function Paris_1_Mission_1B:MakePrisonersGo()
  EVENT_Timer("Paris_1_Mission_1B.MakeThisPrisonerGo", self, 2.5, {
    self.tInfo.sPrisoner3,
    self.tInfo.sPrisoner3Path,
    cMOVE_FAST,
    true
  })
  EVENT_Timer("Paris_1_Mission_1B.MakeThisPrisonerGo", self, 0.5, {
    self.tInfo.sPrisoner5,
    self.tInfo.sPrisoner1Path,
    cMOVE_FAST,
    true
  })
end

function Paris_1_Mission_1B:MakeThisPrisonerGo(sPrisoner, sPath, SPEED, bDespawn)
  local hPrisoner = Handle(sPrisoner)
  if hPrisoner then
    Combat.SetIdleScripted(hPrisoner, true)
    Nav.SetScriptedPath(hPrisoner, sPath, false, "Paris_1_Mission_1B.PrisonerFlags", self, {sPrisoner, true})
    Nav.SetScriptedPathMoveMode(hPrisoner, SPEED)
  end
end

function Paris_1_Mission_1B:PrisonerFlags(sPrisoner, bDespawn)
  local hPrisoner = Handle(sPrisoner)
  if hPrisoner then
    Combat.SetIdleScripted(hPrisoner, true)
    Actor.OverrideCombatAI(hPrisoner, true)
  end
  if bDespawn then
    Object.Despawn(hPrisoner, 0.1, true)
  end
end

function Paris_1_Mission_1B:Checkpoint4()
  print("__Checkpoint4")
  self:EnablePrisonDoor(false)
  self:SetPrisonersFreeFlag(true)
  self.PlayBombersGo(self)
  self.SetVittToPoint(self)
  self:ClearUpdateLoop()
  self:FreedMusic()
  self:SetupTooFarAwayFail()
  self:RemoveFuryMeter()
  self:ClearFinalBar()
  if self.tInfo.hFinalTimer then
    HUD.RemoveObjective(self.tInfo.hFinalTimer)
    self.tInfo.hFinalTimer = nil
  end
  self:KillTaskByName("TASK_Escalator")
  self:KillTaskByName("TASK_LostEscalation")
  EVENT_PlayerEntersTrigger("Paris_1_Mission_1B.MakePlaneCrash", self, "Missions\\paris_1\\mission_1b\\main\\PlaneCrashTrig")
end

function Paris_1_Mission_1B:SetupGunDeaths()
  self:ClearGunDeaths()
  self.tSaveInfo.eWestGun = EVENT_ActorDeath("Paris_1_Mission_1B.FlakCannonDestroyed", self, "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunWest\\OccMed_FlakGun_Base", {
    "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunWest\\OccMed_FlakGun_Base"
  })
  self.tSaveInfo.eEastGun = EVENT_ActorDeath("Paris_1_Mission_1B.FlakCannonDestroyed", self, "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunWest\\OccMed_FlakGun_Base", {
    "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunEast\\OccMed_FlakGun_Base"
  })
end

function Paris_1_Mission_1B:ClearGunDeaths()
  if self.tSaveInfo.eWestGun then
    Util.KillEvent(self.tSaveInfo.eWestGun)
    self.tSaveInfo.eWestGun = false
  end
  if self.tSaveInfo.eEastGun then
    Util.KillEvent(self.tSaveInfo.eEastGun)
    self.tSaveInfo.eEastGun = false
  end
end

function Paris_1_Mission_1B:FlakCannonDestroyed(sGun)
  self.tSaveInfo.TotalGunsDestroyed = self.tSaveInfo.TotalGunsDestroyed + 1
  print("gun destroyed", sGun)
  if sGun == "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunWest\\OccMed_FlakGun_Base" then
    self.tSaveInfo.bWestGunDestroyed = true
  end
  if sGun == "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunEast\\OccMed_FlakGun_Base" then
    self.tSaveInfo.bEastGunDestroyed = true
  end
  if self.tSaveInfo.TotalGunsDestroyed >= 2 then
    print("both guns destroyed")
    self:MissionTaskFail("P1M1B_Text.FAIL_DestroyedAA")
  end
end

function Paris_1_Mission_1B:ClearUpdateLoop()
  if self.tSaveInfo.bSetUpdateLoop then
    Util.UnregisterLuaUpdate("Paris_1_Mission_1B.UpdateListenForWeaponFire")
    self.tSaveInfo.bSetUpdateLoop = false
  end
end

function Paris_1_Mission_1B:TASK_FindASeat()
  self:CreateTask({
    sName = "TASK_FindASeat",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    sObjectiveTextID = "P1M1B_Text.TASK_FindAA",
    tOnActivate = {
      {
        self.ListenForTurretEnter,
        {self}
      },
      {
        self.TASK_DefendASeat,
        {self}
      }
    },
    tOnComplete = {
      {
        self.CompleteTaskByName,
        {
          self,
          "TASK_DefendASeat"
        }
      },
      {
        self.PlayBombersGo,
        {self}
      },
      {
        self.TASK_GetRAFAttention,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1B:TASK_DefendASeat()
  self:CreateTask({
    sName = "TASK_DefendASeat",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "Defend",
    tTgtInclude = self.tInfo.tFlakGuns,
    tOnActivate = {},
    tOnComplete = {}
  })
end

function Paris_1_Mission_1B:ListenForTurretEnter()
  self:CleanTurretListeners()
  self.tSaveInfo.eTurretEnterEvent = EVENT_PlayerEntersVehicle("Paris_1_Mission_1B.PlayerEnteredAA", self, "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunEast\\Seat")
  self.tSaveInfo.eAltTurrentEvent = EVENT_PlayerEntersVehicle("Paris_1_Mission_1B.PlayerEnteredAA", self, "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunWest\\Seat")
end

function Paris_1_Mission_1B:CleanTurretListeners()
  if self.tSaveInfo.eTurretEnterEvent then
    Util.KillEvent(self.tSaveInfo.eTurretEnterEvent)
    self.tSaveInfo.eTurretEnterEvent = nil
  end
  if self.tSaveInfo.eAltTurrentEvent then
    Util.KillEvent(self.tSaveInfo.eAltTurrentEvent)
    self.tSaveInfo.eAltTurrentEvent = nil
  end
end

function Paris_1_Mission_1B:PlayerEnteredAA()
  self:CleanTurretListeners()
  self:CompleteTaskByName("TASK_FindASeat")
end

function Paris_1_Mission_1B:TASK_GetRAFAttention()
  self:CreateTask({
    sName = "TASK_GetRAFAttention",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    sObjectiveTextID = "P1M1B_Text.TASK_FireAA",
    tOnActivate = {
      {
        self.KillTaskByName,
        {
          self,
          "TASK_Escalator"
        }
      },
      {
        self.KillTaskByName,
        {
          self,
          "TASK_LostEscalation"
        }
      },
      {
        self.BombingMusic,
        {self}
      },
      {
        self.ListenforWeaponFire,
        {self}
      },
      {
        self.SetupFuryMeter,
        {self}
      }
    },
    tOnComplete = {
      {
        self.ClearGunDeaths,
        {self}
      },
      {
        self.RemoveFuryMeter,
        {self}
      },
      {
        self.TASK_GetTheHellOuttaThere,
        {self}
      }
    },
    tOnReset = {
      {
        self.RemoveFuryMeter,
        {self}
      }
    },
    tOnCancel = {
      {
        self.RemoveFuryMeter,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1B:ListenforWeaponFire()
  self.tSaveInfo.ePlayerFiresTurret = EVENT_PlayerFiresAnyWeapon("Paris_1_Mission_1B.OnPlayerFiresTurret", self, {}, true)
  self.ePlayerExitsVeh = EVENT_ActorExitsAnyVehicle("Paris_1_Mission_1B.SetTaskCycle", self, hSab)
end

function Paris_1_Mission_1B:UpdateListenForWeaponFire(DT)
  local Pitch = Actor.GetWeaponPitch(hSab)
end

function Paris_1_Mission_1B:SetTaskCycle()
  if self.tSaveInfo.ePlayerFiresTurret then
    Util.KillEvent(self.tSaveInfo.ePlayerFiresTurret)
    self.tSaveInfo.ePlayerFiresTurret = nil
  end
  self:FailTaskByName("TASK_GetRAFAttention")
  self:ResetTaskByName("TASK_DefendASeat", true)
  self:ResetTaskByName("TASK_FindASeat")
end

function Paris_1_Mission_1B:OnPlayerFiresTurret()
  local Pitch = Actor.GetWeaponPitch(hSab)
  if Pitch and 0.35 < Pitch then
    self.tSaveInfo.ShotsOfFury = self.tSaveInfo.ShotsOfFury + 1
    self:UpdateFury(self.tSaveInfo.ShotsOfFury)
  end
  if self.tSaveInfo.ShotsOfFury >= self.tInfo.MAXSHOTS then
    Util.KillEvent(self.ePlayerExitsVeh)
    self:CompleteTaskByName("TASK_GetRAFAttention")
  end
end

function Paris_1_Mission_1B:SetupFuryMeter()
  self.tInfo.hFuryObj = HUD.AddObjective(eOT_DESTROY, "P1M1B_Text.METER_Harrass", 2)
  HUD.SetupProgressBar(self.tInfo.hFuryObj, 0, self.tInfo.MAXSHOTS, self.tSaveInfo.ShotsOfFury)
  if not self.tSaveInfo.bHarrassConv then
    self.tSaveInfo.bHarrassConv = true
    Cin.PlayConversation("P1M1b_Vilette_ShootAA")
  end
end

function Paris_1_Mission_1B:UpdateFury(Value)
  if self.tInfo.hFuryObj then
    HUD.SetProgressBarValue(self.tInfo.hFuryObj, Value)
  end
end

function Paris_1_Mission_1B:RemoveFuryMeter()
  self.tSaveInfo.bHarrassConv = false
  Cin.StopConversation("P1M1b_Vilette_ShootAA")
  if self.tInfo.hFuryObj then
    HUD.RemoveObjective(self.tInfo.hFuryObj)
    self.tInfo.hFuryObj = nil
  end
end

function Paris_1_Mission_1B:TASK_GetTheHellOuttaThere()
  self:CreateTask({
    sName = "TASK_GetTheHellOuttaThere",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P1M1B_Text.TASK_GetTheHellOuttaThere",
    tDeliverObjs = {hSab},
    sTaskStartConv = "P1M1b_Vilette_ShootAA_Done",
    tDestRegion = {
      "Missions\\paris_1\\mission_1b\\main\\SaviorTrig"
    },
    tLocators = {
      "Missions\\paris_1\\mission_1b\\main\\SaviorLoc"
    },
    tOnComplete = {
      {
        self.PlayBombsGo,
        {self}
      },
      {
        self.TASK_GetToSafeHouse,
        {self}
      }
    },
    tOnActivate = {
      {
        self.ClearTooFarAwayFail,
        {self}
      },
      {
        self.StartJuggernaughtBitch,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1B:TASK_GetToSafeHouse()
  self:CreateTask({
    sName = "TASK_GetToSafeHouse",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P1M1B_Text.TASK_GetToSafeHouse",
    tDeliverObjs = {hSab},
    sTaskStartConv = "P1M1b_ToShelter_InBuilding",
    tDestRegion = {
      "Missions\\paris_1\\mission_1b\\main\\REG_Safety"
    },
    tLocators = {
      "Missions\\paris_1\\mission_1b\\main\\LOC_SafeHouse"
    },
    tOnComplete = {
      {
        self.TASK_PlayFinalBomberCine,
        {self}
      }
    },
    tOnActivate = {
      {
        self.ClearTooFarAwayFail,
        {self}
      },
      {
        self.PlayBombsGo,
        {self}
      },
      {
        Combat.BroadcastRetreat,
        {hSab, 100}
      }
    }
  })
end

function Paris_1_Mission_1B:SpecialWTFFlip()
  self.tSaveInfo.bJuggernaught = false
  Zone.SwitchState("WtF_Zones\\global\\P1M1B_SlaughterhouseLiberate", cZONESTATE_HIGHCOLOR_LOWTAG, cENT_REALLYNOCHANGE, false)
end

function Paris_1_Mission_1B:TurnOffJuggernaught()
  self.tSaveInfo.bJuggernaught = false
end

function Paris_1_Mission_1B:StartJuggernaughtBitch()
  self.tSaveInfo.bJuggernaught = true
  self.tSaveInfo.bAllowCarpetBomb = true
  EVENT_Timer("Paris_1_Mission_1B.WarningShots", self, 3)
  EVENT_Timer("Paris_1_Mission_1B.WarningShots", self, 30)
  EVENT_Timer("Paris_1_Mission_1B.WarningShots", self, 50)
  EVENT_Timer("Paris_1_Mission_1B.JuggernaughtBitch", self, 60)
end

function Paris_1_Mission_1B:JuggernaughtBitch()
  if self.tSaveInfo.bJuggernaught then
    self:CarpetBomb(hSab)
    print("I'm the JUGGERNAUGHT!!!")
    EVENT_Timer("Paris_1_Mission_1B.JuggernaughtBitch", self, 10)
  else
    print("apparently i'm not the juggernaught")
  end
end

function Paris_1_Mission_1B:TestForLiveSean()
  if Actor.IsAlive(hSab) then
    self:MissionTaskFail("you are cheating")
  end
end

function Paris_1_Mission_1B:TASK_PlayFinalBomberCine()
  if self.tInfo.hFinalTimer then
    HUD.RemoveObjective(self.tInfo.hFinalTimer)
    self.tInfo.hFinalTimer = nil
  end
  self:CreateTask({
    sName = "TASK_PlayFinalBomberCine",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "P1M1B_CinFinalBomb",
    bOverrideFade = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.SpecialWTFFlip,
        {self}
      },
      {
        self.Task_EnterHQ,
        {self}
      }
    },
    tSMEDNodes = {},
    tCinematicNodes = {"cine3stuff"}
  })
end

function Paris_1_Mission_1B:PlayWTFTut()
  HUD.PlayAdvancedTutorial(cHTM_Tutorial_WTF, "Paris_1_Mission_1B.Reglastcheckpoint", self)
end

function Paris_1_Mission_1B:FinalBombing()
  local self = Paris_1_Mission_1B
  local bSCHandle = Util.GetHandleByName("Missions\\paris_1\\mission_1b\\main\\BASE_LaVillette")
  self:BombQuarter2()
  EVENT_Timer("Paris_1_Mission_1B.BombQuarter3C", self, 8)
  EVENT_Timer("Paris_1_Mission_1B.BombQuarter3D", self, 7)
  EVENT_Timer("Paris_1_Mission_1B.BombQuarter3B", self, 10.5)
  EVENT_Timer("Paris_1_Mission_1B.BombQuarter3C", self, 13.5)
  EVENT_Timer("Paris_1_Mission_1B.BombQuarter3D", self, 12.5)
  EVENT_Timer("Paris_1_Mission_1B.BombQuarter3D", self, 13.5)
  EVENT_Timer("Paris_1_Mission_1B.BombQuarter4", self, 8.5)
  EVENT_Timer("Paris_1_Mission_1B.BombQuarter4B", self, 10.5)
  EVENT_Timer("Paris_1_Mission_1B.BombQuarter4C", self, 9)
  EVENT_Timer("Paris_1_Mission_1B.BombQuarter4D", self, 11.5)
  EVENT_Timer("Paris_1_Mission_1B.BombQuarter4C", self, 13)
  EVENT_Timer("Paris_1_Mission_1B.BombQuarter4D", self, 12.5)
  EVENT_Timer("Paris_1_Mission_1B.BombQuarter4", self, 13)
  EVENT_Timer("Paris_1_Mission_1B.BombQuarter4B", self, 12.5)
  EVENT_Timer("Paris_1_Mission_1B.BombQuarter4C", self, 13.5)
  EVENT_Timer("Paris_1_Mission_1B.BombQuarter4D", self, 14)
  EVENT_Timer("Paris_1_Mission_1B.BombQuarter4", self, 7)
  EVENT_Timer("Paris_1_Mission_1B.BombQuarter4D", self, 7.7)
  EVENT_Timer("Paris_1_Mission_1B.CarpetBombs", self, 12.5)
  EVENT_Timer("Paris_1_Mission_1B.CarpetBombs", self, 10.5)
  EVENT_Timer("Paris_1_Mission_1B.CarpetBombs", self, 6.7)
end

function Paris_1_Mission_1B:CarpetBombs()
  local Boom = 1
  while Boom <= self.tInfo.NumBoomLocs do
    Boom = Boom + 1
    local BombLoc = "PARIS\\area01\\lavillette\\airraidstuff\\LOC_Boom(" .. Boom .. ")"
    local hLoc = Handle(BombLoc)
    local Rand = math.random(0, 4)
    if hLoc then
      EVENT_Timer("Paris_1_Mission_1B.CarpetBomb", self, Rand + 0.1, {hLoc})
    end
  end
end

function Paris_1_Mission_1B:CarpetBomb(hLoc)
  if self.tSaveInfo.bAllowCarpetBomb and hLoc then
    local x, y, z = Object.GetPosition(hLoc)
    Util.CreateExplosion("Explosion_Large", x, y, z + 2)
  end
end

function Paris_1_Mission_1B:Task_EnterHQ()
  self:StreamLVINTAttractionPt()
  self:CreateTask({
    sName = "Task_EnterHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "EnterInterior",
    sInteriorName = "Lavillette",
    tOnActivate = {
      {
        Sound.ResetMusicLocale,
        {}
      },
      {
        self.TeleportintoHQ,
        {self}
      },
      {
        self.UnloadLucNode,
        {self}
      },
      {
        self.KillYouDamnNazis,
        {
          self,
          "Missions\\paris_1\\mission_1b\\main\\Deliver_Villette"
        }
      }
    },
    tOnComplete = {
      {
        self.ClearFinalBar,
        {self}
      },
      {
        self.PlayWTFTut,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1B:Reglastcheckpoint()
  self.RegisterCheckpoint(self, "Paris_1_Mission_1B.Checkpoint5", nil, true)
end

function Paris_1_Mission_1B:UnloadLucNode()
  Util.UnloadEditNode("Missions\\paris_1\\mission_1b\\cine2stuff.wsd", true, false)
end

function Paris_1_Mission_1B:ClearFinalBar()
  if self.tInfo.hFinalTimer then
    HUD.RemoveObjective(self.tInfo.hFinalTimer)
    self.tInfo.hFinalTimer = nil
  end
end

function Paris_1_Mission_1B:KillYouDamnNazis(vTrigger)
  local hTrigger = Handle(vTrigger)
  local hSurroundingNaziFilter = Filter.New("Nazi && !General")
  local tBastardNazis = {}
  if hTrigger then
    tBastardNazis = Trigger.GetAllWithin(hTrigger, hSurroundingNaziFilter)
  end
  if tBastardNazis and tBastardNazis[1] then
    for i, Nazi in pairs(tBastardNazis) do
      local hNazi = Handle(Nazi)
      Object.Kill(hNazi)
    end
  end
  Filter.Delete(hSurroundingNaziFilter)
end

function Paris_1_Mission_1B:TeleportintoHQ()
  self.tSaveInfo.bAirRaidTimer = false
  if self.tInfo.hFinalTimer then
    HUD.RemoveObjective(self.tInfo.hFinalTimer)
    self.tInfo.hFinalTimer = nil
  end
  Util.UnloadEditNode("Missions\\paris_1\\mission_1b\\importantprisoners.wsd", true)
  InteriorManager.EnterInterior("LaVillette", "Missions\\paris_1\\mission_1b\\main\\SeanIntTele")
end

function Paris_1_Mission_1B:Checkpoint5()
  print("__Checkpoint 5")
  self:SetLavaDoor(false)
  Suspicion.ResetEscalation()
  self.tSaveInfo.bAllowCarpetBomb = false
  Saboteur.ShowToolTip("TutorialTip_Text.HQs")
  local bSCHandle = Util.GetHandleByName("Missions\\paris_1\\mission_1b\\main\\BASE_LaVillette")
  BASE_LaVillette.StopBomberCinematics(Actor.GetSelf(bSCHandle))
  local tPeeps = {
    "Missions\\paris_1\\characters\\lavillette\\luc_interior\\Luc_LaVillette_Interior",
    "Missions\\paris_1\\characters\\lavillette\\veronique_interior\\Veronique_LaVillette_Interior"
  }
  EVENT_Stream("Paris_1_Mission_1B.SetCharactersIntoAttrPts", self, tPeeps, true)
  EVENT_Timer("Paris_1_Mission_1B.FadeToFade", self, 2)
  EVENT_Timer("Paris_1_Mission_1B.CompleteNowYo", self, 3)
end

function Paris_1_Mission_1B:FadeToFade()
  Render.FadeScreen(false)
end

function Paris_1_Mission_1B:SetCharactersIntoAttrPts()
  print("Paris_1_Mission_1B.SetCharactersIntoAttrPts")
  local hLuc = Handle("Missions\\paris_1\\characters\\lavillette\\luc_interior\\Luc_LaVillette_Interior")
  local hVeron = Handle("Missions\\paris_1\\characters\\lavillette\\veronique_interior\\Veronique_LaVillette_Interior")
  Actor.CancelAttrPtRequest(hLuc, true)
  Actor.CancelAttrPtRequest(hVeron)
  Combat.SetIdleScripted(hLuc, true)
  Combat.SetIdleScripted(hVeron, true)
  Actor.UseAttrPt(hLuc, Handle("Missions\\paris_1\\characters\\lavillette\\luc_interior\\AttractionPt_sit_sick"))
  Actor.UseAttrPt(hVeron, Handle("Missions\\paris_1\\characters\\lavillette\\veronique_interior\\AIAttractionPt_Look"))
end

function Paris_1_Mission_1B:CompleteNowYo()
  Sound.ReleaseSoundBank("m_p1m1b_ingame.bnk")
  SetDisableControl("Action", false)
  DisablePlayersMovement(false)
  SetDisableControl("Walking", false)
  self:CompleteThisMission()
end

function Paris_1_Mission_1B:Unfade()
  Render.FadeScreen(false)
end

function Paris_1_Mission_1B:SetLavaDoor(bEnable)
  local hDoor = Handle("PARIS\\area01\\lavillette\\interior\\lavillette_int\\TeleporterSwingLeftDoorPoint")
  AttractionPt.EnableUse(hDoor, bEnable)
end

function Paris_1_Mission_1B:SetFacing(vChar, vLoc)
  local hChar = Handle(vChar)
  local hLoc = Handle(vLoc)
  if not hChar and not hLoc then
    Util.Assert(false, "Paris_1_Mission_1B.SetFacing:: hChar or hLoc are nil")
    return
  end
  Actor.SetFacingDir(hChar, hLoc)
end

function Paris_1_Mission_1B:TASK_TalkToInjuredLuc()
  self:CreateTask({
    sName = "TASK_TalkToInjuredLuc",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sObjectiveTextID = "P1M1B_Text.TASK_TalkLuc",
    bAutofire = true,
    Proximity = 2,
    bInteriorTask = true,
    sConvFile = "206_Con_LucHurt",
    tTgtInclude = {
      "Missions\\paris_1\\characters\\lavillette\\luc_interior\\Luc_LaVillette_Interior"
    },
    tOnActivate = {
      {
        Render.FadeScreen,
        {false}
      }
    },
    tOnConversationComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Paris_1_Mission_1B.CallbackTowerExplosion()
  self = Paris_1_Mission_1B
  local hLoc = Handle("Missions\\paris_1\\mission_1b\\cine3stuff\\LOC_Splode")
  local hClock = Util.GetHandleByName("PARIS\\area01\\lavillette\\buildings\\MN_LaVillette_clock(3)\\MN_LaVillette_top_damPiece(1)")
  if hLoc then
    local x, y, z = Object.GetPosition(hLoc)
    Util.CreateExplosion("Explosion_Large", x, y, z)
  end
end

function Paris_1_Mission_1B:NoQuarterBomb1()
  if self.tSaveInfo.bAirRaidTimer == true then
    Util.RequestDynamicBlueprint("SmallRocket")
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\NoQDrop1"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\NoQDropLand1"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\NoQDrop2"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\NoQDropLand2"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
  else
  end
end

function Paris_1_Mission_1B:NoQuarterBomb2()
  Util.RequestDynamicBlueprint("SmallRocket")
  local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\NoQDrop3"))
  local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\NoQDropLand3"))
  Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
  local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\NoQDrop4"))
  local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\NoQDropLand4"))
  Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
end

function Paris_1_Mission_1B:NoQuarterBomb3()
  if self.tSaveInfo.bAirRaidTimer == true then
    Util.RequestDynamicBlueprint("SmallRocket")
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\NoQDrop5"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\NoQDropLand5"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\NoQDrop6"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\NoQDropLand6"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
  else
  end
end

function Paris_1_Mission_1B:NoQuarterBomb4()
  if self.tSaveInfo.bAirRaidTimer == true then
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\NoQDrop1"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\NoQDropLand7"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\NoQDrop2"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\NoQDropLand8"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
  else
  end
end

function Paris_1_Mission_1B:NoQuarterBomb5()
  if self.tSaveInfo.bAirRaidTimer == true then
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\NoQDrop3"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\NoQDropLand9"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
  else
  end
end

function Paris_1_Mission_1B:BombNoQuarter()
  if self.bIsCannonDead == false then
    EVENT_Timer("Paris_1_Mission_1B.NoQuarterBomb1", self, 3)
    EVENT_Timer("Paris_1_Mission_1B.NoQuarterBomb2", self, 4)
    EVENT_Timer("Paris_1_Mission_1B.NoQuarterBomb3", self, 5)
    EVENT_Timer("Paris_1_Mission_1B.NoQuarterBomb4", self, 8)
    EVENT_Timer("Paris_1_Mission_1B.NoQuarterBomb5", self, 10)
  else
  end
end

function Paris_1_Mission_1B:BombQuarter1()
  if self.tSaveInfo.bAirRaidTimer == true then
    Util.RequestDynamicBlueprint("SmallRocket")
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(10)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(2)"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(11)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
  else
  end
end

function Paris_1_Mission_1B:BombQuarter1B()
  if self.tSaveInfo.bAirRaidTimer == true then
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(8)"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(19)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(9)"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(20)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(15)"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(21)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
  else
  end
end

function Paris_1_Mission_1B:BombQuarter1C()
  if self.tSaveInfo.bAirRaidTimer == true then
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(3)"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(12)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(4)"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(13)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(6)"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(14)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
  else
  end
end

function Paris_1_Mission_1B:BombQuarter1D()
  if self.tSaveInfo.bAirRaidTimer == true then
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(22)"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(28)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(23)"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(29)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(24)"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(30)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
  else
  end
end

function Paris_1_Mission_1B:BombQuarter1E()
  if self.tSaveInfo.bAirRaidTimer == true then
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(31)"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(37)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(32)"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(38)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(33)"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Locator(39)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
  else
  end
end

function Paris_1_Mission_1B:BombQuarter2()
  if self.tSaveInfo.bAirRaidTimer == true then
    Util.RequestDynamicBlueprint("SmallRocket")
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop(2)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop2"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop2(2)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop3"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop3(2)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
  else
  end
end

function Paris_1_Mission_1B:BombQuarter2B()
  if self.tSaveInfo.bAirRaidTimer == true then
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop4"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop4(2)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop5"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop5(2)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop6"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop6(2)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
  else
  end
end

function Paris_1_Mission_1B:BombQuarter2C()
  if self.tSaveInfo.bAirRaidTimer == true then
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop4"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop3(4)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop5"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop3(5)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop6"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop3(6)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
  else
  end
end

function Paris_1_Mission_1B:BombQuarter2D()
  if self.tSaveInfo.bAirRaidTimer == true then
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop4"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop3(8)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop5"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop3(9)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop6"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\Q2Drop3(12)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\AirRaidStuff\\Q2Drop2"))
    local x1, y1, z1 = Object.GetPosition(Util.GetHandleByName("PARIS\\area01\\lavillette\\airraidstuff\\Q2Drop3(10)"))
    Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
  else
  end
end

function Paris_1_Mission_1B:BombQuarter3()
  if self.tSaveInfo.bAirRaidTimer == true then
    Util.RequestDynamicBlueprint("SmallRocket")
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop1", "PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop1(2)")
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop2", "PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop2(2)")
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop3", "PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop3(2)")
  else
  end
end

function Paris_1_Mission_1B:BombQuarter3B()
  if self.tSaveInfo.bAirRaidTimer == true then
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop4", "PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop4(2)")
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop5", "PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop5(2)")
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop6", "PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop6(2)")
  else
  end
end

function Paris_1_Mission_1B:BombQuarter3C()
  if self.tSaveInfo.bAirRaidTimer == true then
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop1", "PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop4(4)")
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop2", "PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop4(6)")
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop3", "PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop4(8)")
  else
  end
end

function Paris_1_Mission_1B:BombQuarter3D()
  if self.tSaveInfo.bAirRaidTimer == true then
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop4", "PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop4(10)")
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop5", "PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop4(12)")
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop6", "PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop4(14)")
  else
  end
end

function Paris_1_Mission_1B:BombQuarter4()
  if self.tSaveInfo.bAirRaidTimer == true then
    Util.RequestDynamicBlueprint("SmallRocket")
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop1", "PARIS\\area01\\lavillette\\airraidstuff\\Q4Drop1")
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop2", "PARIS\\area01\\lavillette\\airraidstuff\\Q4Drop2")
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop3", "PARIS\\area01\\lavillette\\airraidstuff\\Q4Drop3")
  else
  end
end

function Paris_1_Mission_1B:BombQuarter4B()
  if self.tSaveInfo.bAirRaidTimer == true then
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop4", "PARIS\\area01\\lavillette\\airraidstuff\\Q4Drop4")
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop5", "PARIS\\area01\\lavillette\\airraidstuff\\Q4Drop5")
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop6", "PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop6")
  else
  end
end

function Paris_1_Mission_1B:BombQuarter4C()
  if self.tSaveInfo.bAirRaidTimer == true then
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop1", "PARIS\\area01\\lavillette\\airraidstuff\\Q4Drop7")
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop2", "PARIS\\area01\\lavillette\\airraidstuff\\Q4Drop8")
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop3", "PARIS\\area01\\lavillette\\airraidstuff\\Q4Drop9")
  else
  end
end

function Paris_1_Mission_1B:BombQuarter4D()
  if self.tSaveInfo.bAirRaidTimer == true then
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop4", "PARIS\\area01\\lavillette\\airraidstuff\\Q4Drop10")
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop5", "PARIS\\area01\\lavillette\\airraidstuff\\Q4Drop11")
    self:LaunchRocket("PARIS\\area01\\lavillette\\airraidstuff\\Q3Drop6", "PARIS\\area01\\lavillette\\airraidstuff\\Q4Drop12")
  else
  end
end

function Paris_1_Mission_1B:LaunchRocket(sLocFrom, sLocTo)
  local hLocFrom = Handle(sLocFrom)
  if not hLocFrom then
    print("LaunchRocket sLocFrom is nil : ", sLocFrom)
    return
  end
  local hLocTo = Handle(sLocTo)
  if not hLocTo then
    print("LaunchRocket sLocTo is nil : ", sLocTo)
    return
  end
  local x, y, z = Object.GetPosition(hLocFrom)
  local x1, y1, z1 = Object.GetPosition(hLocTo)
  Util.SpawnRocket("SmallRocket", x, y, z, x1, y1, z1)
end

function Paris_1_Mission_1B:WarningShots()
  for i, Loc in pairs(self.tInfo.WarningShots) do
    local hLoc = Handle(Loc)
    if hLoc then
      EVENT_Timer("Paris_1_Mission_1B.CarpetBomb", self, i + 2, {hLoc})
      EVENT_Timer("Paris_1_Mission_1B.CarpetBomb", self, i + 10, {hLoc})
    end
  end
end

function Paris_1_Mission_1B:SetupBritBombersTrig()
  Trigger.WaitFor(self.sBritBomberTrig, hSab, "Paris_1_Mission_1B.FireBritBombersConvo", self, nil, cTRIGGEREVENT_ONENTER, false)
end

function Paris_1_Mission_1B:FireBritBombersConvo()
  EVENT_Timer("Paris_1_Mission_1B.FirePlaneFlyOver", self, 3)
  Cin.PlayCinematic("P1M1B_ScoutPlane")
end

function Paris_1_Mission_1B:FirePlaneFlyOver()
  Cin.PlayConversation("P1M1b_Vilette_BritBombers")
end

function Paris_1_Mission_1B:SendKubelOut()
  local hKubelPather = Handle("Missions\\paris_1\\mission_1b\\main\\VH_NZ_CR_Kubelwagen_01(5)")
  local sKubelPath = "PARIS\\area01\\lavillette\\occupation\\props\\KubelPath"
  Nav.SetScriptedPath(hKubelPather, sKubelPath, false)
  Nav.SetScriptedPathSpeed(hKubelPather, 25)
end

function Paris_1_Mission_1B:EscalationListener()
  local tEscaEvent = {
    EventType = "OnEscalation1",
    Target = hSab
  }
  self.eEsca1 = self:RegisterEvent(Util.CreateEvent(tEscaEvent, "Paris_1_Mission_1B.OnEscalateSetup", self))
  local tEscaEvent2 = {
    EventType = "OnEscalation2",
    Target = hSab
  }
  self.eEsca2 = self:RegisterEvent(Util.CreateEvent(tEscaEvent2, "Paris_1_Mission_1B.OnEscalateSetup", self))
  local tEscaEvent3 = {
    EventType = "OnEscalation3",
    Target = hSab
  }
  self.eEsca3 = self:RegisterEvent(Util.CreateEvent(tEscaEvent3, "Paris_1_Mission_1B.OnEscalateSetup", self))
end

function Paris_1_Mission_1B:OnEscalateSetup()
  self:EnablePrisonDoor(false)
  self:SetupDeEscalationListener(self)
end

function Paris_1_Mission_1B:SetupDeEscalationListener()
  local tDeEscaEvent0 = {
    EventType = "OnEscalation0",
    Target = hSab
  }
  self.eDeEsca = self:RegisterEvent(Util.CreateEvent(tEscaEvent3, "Paris_1_Mission_1B.OnDeEscaEnable", self))
end

function Paris_1_Mission_1B:OnDeEscaEnable()
  self:EnablePrisonDoor(true)
  self:EscalationListener(self)
end

function Paris_1_Mission_1B:ClearAllListeners()
  Util.KillEvent(self.eDeEsca)
  Util.KillEvent(self.eEsca1)
  Util.KillEvent(self.eEsca2)
  Util.KillEvent(self.eEsca3)
end

function Paris_1_Mission_1B:SetDisguiseTutListener()
  local sDisguiseTutTrig = "Missions\\paris_1\\mission_1b\\main\\DisguiseTutorialTrig"
  Trigger.WaitFor(sDisguiseTutTrig, hSab, "Paris_1_Mission_1B.PlayDisguiseTutorial", self, nil, cTRIGGEREVENT_ONENTER, false)
end

function Paris_1_Mission_1B:PlayDisguiseTutorial()
  Saboteur.ShowToolTip("TutorialTip_Text.Stealth_Kills", 30, nil, true)
end

function Paris_1_Mission_1B:SetupDoorAttractioPtStream()
end

function Paris_1_Mission_1B:MISSION_ONCANCEL()
  if self.tInfo.hAirRaidFailTimer then
    HUD.RemoveObjective(self.tInfo.hAirRaidFailTimer)
    self.tInfo.hAirRaidFailTimer = nil
  end
  if self.tInfo.hFinalTimer then
    HUD.RemoveObjective(self.tInfo.hFinalTimer)
    self.tInfo.hFinalTimer = nil
  end
  Util.DisableDisguising(true)
  OffDisables()
  self:ClearTooFarAwayFail()
end

function Paris_1_Mission_1B:SetPrisonerStreamEvent()
  dprint(self, "Setting Prisoner Stream Event")
  local tPrisonStream = {
    EventType = "StreamEvent",
    Objects = self.tPrisoners
  }
  Util.CreateEvent(tPrisonStream, "Paris_1_Mission_1B.OnPrisonersStream", self)
end

function Paris_1_Mission_1B:OnPrisonersStream()
  for i = 1, #self.tPrisoners do
    dprint(self, "Prisoner being made dumb")
    local hPrisoner = Handle(self.tPrisoners[i])
    Actor.OverrideCombatAI(hPrisoner, true)
    Combat.SetIdleScripted(hPrisoner, true)
  end
end

function Paris_1_Mission_1B:StreamDoorUsePt()
  Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      self.sPrisonDoors
    }
  }, "Paris_1_Mission_1B.SetupDoorEvent", self)
end

function Paris_1_Mission_1B:SetupDoorEvent()
  self:EnablePrisonDoor(false)
  local tPullEvent = {
    EventType = "OnActorComplete",
    Target = Handle(self.sPrisonDoors)
  }
  Util.CreateEvent(tPullEvent, "Paris_1_Mission_1B.CheckOnDoorUse", self)
end

function Paris_1_Mission_1B:CheckOnDoorUse()
  dprint(self, "door has been used")
  if Suspicion.GetEscalation() == 0 then
    if Object.IsAlive(Handle("Missions\\paris_1\\mission_1b\\main\\SPORE_DockRamp(13)")) == true then
      EVENT_Timer("Paris_1_Mission_1B.NoReallyCheck", self, 2)
    elseif self.bHasKEY == true then
      Object.Actuate(Handle(self.sCellDoor))
      self:TeleLucOut()
      self:CompleteTaskByName("TASK_FreePrisonersFromCells")
    else
      EVENT_Timer("Paris_1_Mission_1B.NoReallyCheck", self, 2)
    end
  else
  end
end

function Paris_1_Mission_1B:NoReallyCheck()
  self:SetupDoorEvent()
end

function Paris_1_Mission_1B:ListenForNearGS()
  EVENT_ActorEntersTrigger("Paris_1_Mission_1B.PlayDisguise_GSTut", self, hSab, "Missions\\paris_1\\mission_1b\\main\\PT_GSTut")
end

function Paris_1_Mission_1B:PlayDisguise_GSTut()
  if Actor.IsDisguised(hSab) == true then
  else
  end
end

function Paris_1_Mission_1B:WaitForGSStream()
  local tGSStream = {
    EventType = "StreamEvent",
    Objects = {
      "Missions\\paris_1\\mission_1b\\main\\SPORE_DockRamp(13)"
    }
  }
  Util.CreateEvent(tGSStream, "Paris_1_Mission_1.OnGSStream", self)
end

function Paris_1_Mission_1B:OnGSStream()
  local hGSDude = Handle("Missions\\paris_1\\mission_1b\\main\\SPORE_DockRamp(13)")
  self.hGSDude = hGSDude
end

function Paris_1_Mission_1B:TASK_KillGuard()
  self:CreateTask({
    sName = "TASK_KillGuard",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "kill",
    sObjectiveTextID = "P1M1B_Text.TASK_KillGuard",
    tTgtInclude = {
      "Missions\\paris_1\\mission_1b\\main\\SPORE_DockRamp(13)"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.SendInTheKey,
        {self}
      },
      {
        self.WaitForNearCell,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1B:SendInTheKey()
  local x, y, z = Object.GetPosition(self.hGSDude)
  Object.Spawn("P1M1B_CellKey", x, y, z, 0, nil, "Paris_1_Mission_1B.GetCellKey", self)
end

function Paris_1_Mission_1B:GetCellKey(a_tSpawnObj)
  self.hCellKey = a_tSpawnObj[1]
  self:LoadLucRelatedNodes()
  self:TASK_GetKey()
end

function Paris_1_Mission_1B:TASK_GetKey()
  self:CreateTask({
    sName = "TASK_GetKey",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Fetch",
    sObjectiveTextID = "P1M1B_Text.TASK_GetKey",
    bBlueprintFetch = true,
    tDeliverObjs = {
      "P1M1B_CellKey"
    },
    tLocators = {
      self.hCellKey
    },
    tStaticTags = {},
    tSMEDNodes = {},
    tOnActivate = {},
    tOnComplete = {
      {
        self.RunGrabbedFlag,
        {self}
      },
      {
        self.TASK_FreePrisonersFromCells,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1B:RunGrabbedFlag()
  self.bHasKEY = true
end

function Paris_1_Mission_1B:PlayDisguiseEquip()
  Saboteur.ShowToolTip("TutorialTip_Text.Disguise_Equip", 20, nil, true)
end

function Paris_1_Mission_1B:LoadKillMeDude()
  self = Paris_1_Mission_1B
  Util.SpawnEditNode("Missions\\paris_1\\mission_1b\\StealthTutGuy.wsd")
end

function Paris_1_Mission_1B:SetupStealthKillTutListener()
  EVENT_ActorEntersTrigger("Paris_1_Mission_1B.RunStealthTut", self, hSab, "Missions\\paris_1\\mission_1b\\main\\PT_StealthKillTut")
end

function Paris_1_Mission_1B:RunStealthTut()
  Saboteur.ShowToolTip("TutorialTip_Text.Disguise_Stealth", 15, nil, true)
end

function Paris_1_Mission_1B:CheckForActiveTasks()
  if self:IsMissionTaskActive("TASK_KillGuard") == true then
    self.sCurrentMission = "TASK_KillGuard"
  elseif self:IsMissionTaskActive("TASK_GetKey") == true then
    self.sCurrentMission = "TASK_GetKey"
  elseif self:IsMissionTaskActive("TASK_GoInsideLaVillette") == true then
    self.sCurrentMission = "TASK_GoInsideLaVillette"
  elseif self:IsMissionTaskActive("TASK_FreePrisonersFromCells") == true then
    self.sCurrentMission = "TASK_FreePrisonersFromCells"
    self.EnablePrisonDoor(self, false)
  elseif self:IsMissionTaskActive("TASK_GoToLaVillette") == true then
    self.sCurrentMission = "TASK_GoToLaVillette"
  end
  self:TackleMissionSwap()
end

function Paris_1_Mission_1B:TackleMissionSwap()
  if self.sCurrentMission == "TASK_GetKey" then
    self:FailTaskByName(self.sCurrentMission)
    self:TASK_SetTempKeyListenTask()
  else
    self:FailTaskByName(self.sCurrentMission)
  end
  if self.sOverTask then
    self:FailTaskByName(self.sOverTask)
  else
  end
end

function Paris_1_Mission_1B:ResetCurrentMissionTask()
  if self.sCurrentMission == "TASK_FreePrisonersFromCells" then
    self:ResetTaskByName(self.sCurrentMission)
    self.EnablePrisonDoor(self, true)
  elseif self.sCurrentMission == "TASK_GetKey" then
    if self.bHasGot == true then
      self:TASK_FreePrisonersFromCells()
    else
      self:FailTaskByName("TASK_SetTempKeyListenTask")
      self:ResetTaskByName(self.sCurrentMission)
    end
  else
    self:ResetTaskByName(self.sCurrentMission)
  end
  if self.sOverTask then
    self:ResetTaskByName(self.sOverTask)
  else
  end
end

function Paris_1_Mission_1B:TASK_SetTempKeyListenTask()
  self:CreateTask({
    sName = "TASK_SetTempKeyListenTask",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Fetch",
    bBlueprintFetch = true,
    tDeliverObjs = {
      "P1M1B_CellKey"
    },
    tStaticTags = {},
    tSMEDNodes = {},
    tOnActivate = {},
    tOnComplete = {
      {
        self.ActivateGotFlag,
        {self}
      }
    }
  })
end

function Paris_1_Mission_1B:ActivateGotFlag()
  self.bHasGot = true
  self.bHasKEY = true
end

function Paris_1_Mission_1B:WaitForNearCell()
  EVENT_PlayerEntersTrigger("Paris_1_Mission_1B.PlayNearCellConvo", self, "PARIS\\area01\\lavillette\\occupation\\prison\\PT_NearCellConv")
end

function Paris_1_Mission_1B:PlayNearCellConvo()
  if Suspicion.GetEscalation() > 0 then
    Cin.PlayConversation("P1M1b_Rescue_NearCell_Escalated")
  else
    Cin.PlayConversation("P1M1b_Rescue_NearCell_NotEscalated")
  end
end

function Paris_1_Mission_1B:TeleLucOut()
  local x, y, z = Object.GetPosition(Handle("Missions\\paris_1\\mission_1b\\main\\LucTeleLoc"))
  Object.Teleport(Handle("Missions\\paris_1\\mission_1b\\cine2stuff\\Spore_RS_Luc"), x, y, z, 0)
end

function Paris_1_Mission_1B:StreamLVINTAttractionPt()
  local tLVINTStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      "PARIS\\area01\\lavillette\\interior\\lavillette_int\\TeleporterSwingLeftDoorPoint"
    }
  }
  Util.CreateEvent(tLVINTStreamEvent, "Paris_1_Mission_1B.TurnOffLVINT", self)
end

function Paris_1_Mission_1B:TurnOffLVINT()
  self:SetLavaDoor(false)
end

function Paris_1_Mission_1B:TASK_MinorEscalator()
  self:CreateTask({
    sName = "TASK_MinorEscalator",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = true,
    tOnComplete = {
      {
        self.CallbackMinorEsc,
        {self}
      },
      {
        self.TASK_MinorDEEscalator,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Paris_1_Mission_1B:CallbackMinorEsc()
  self:FailTaskByName("TASK_FollowLuc")
end

function Paris_1_Mission_1B:TASK_MinorDEEscalator()
  self:CreateTask({
    sName = "TASK_MinorDEEscalator",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "P1M1B_Text.TASK_MinorDEEscalator",
    EscalationLevel = 0,
    tLocators = {},
    tOnComplete = {
      {
        self.CallbackMinorDeEscalation,
        {self}
      },
      {
        self.ResetTaskByName,
        {
          self,
          "TASK_MinorDEEscalator",
          true
        }
      },
      {
        self.ResetTaskByName,
        {
          self,
          "TASK_MinorEscalator"
        }
      }
    },
    tOnActivate = {}
  })
end

function Paris_1_Mission_1B:CallbackMinorDeEscalation()
  self:ResetTaskByName("TASK_FollowLuc")
end
