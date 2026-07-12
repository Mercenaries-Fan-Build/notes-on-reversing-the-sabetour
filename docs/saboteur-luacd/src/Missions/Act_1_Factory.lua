if Act_1_Factory == nil then
  Act_1_Factory = SabTaskObjective:Create()
  gsA1Factory = "Missions\\act_1\\Factory\\"
  Act_1_Factory:Configure({
    TaskCount = "auto",
    bStarterless = true,
    MCDisplayID = 2,
    sSaveMissionNameID = "MissionNames_Text.A1M4",
    bFastComplete = true,
    tUnlockList = {
      "Act_1_Escape"
    },
    bSLOverrideFade = true,
    tSMEDNodes = {
      gsA1Factory .. "main",
      gsA1Factory .. "sound",
      gsA1Factory .. "ZeppelinWindow",
      gsA1Factory .. "torture_scene",
      gsA1Factory .. "eventnazis"
    },
    tStaticTags = {
      "TEMP_ColbyNode",
      "BalconyKillZone",
      "Dopp_OpenDoor",
      "julesdead_chair"
    }
  })
end

function Act_1_Factory:STARTER_Setup()
  Suspicion.EnableGlobal(false)
  Actor.SetDisguise(hSab, "FBS_RS_Sean_Shirt_Sab_NoHat_NoBag")
  Actor.TurnOnDude(hSab, false)
  Render.SetGlobalWTF(false)
  Sound.LoadSoundBank("M_A1M4_InGame.bnk")
  Render.WTFClearOverrideBlueprint()
  Util.SetTime(21, 0)
  Combat.GlobalAllowGrenades(false)
  Util.UnloadStaticENTag("Dopp_ClosedDoor", true)
  Inventory.RemoveAllWeapons(hSab)
end

function Act_1_Factory:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.PutSeanInStartingSpot(self)
end

function Act_1_Factory:PutSeanInStartingSpot()
  Actor.TurnOnDude(hSab, false)
  local hLoc = Util.GetHandleByName(gsA1Factory .. "main\\LOC_Sean")
  Object.PlayerTeleportToLocator(hLoc, false, "Act_1_Factory.TeleportDone", self)
end

function Act_1_Factory:GENERAL_Setup()
  self.tInfo.tSpawners = {}
  self.tInfo.SeanChairPt = gsA1Factory .. "main\\AttrPt_SitDownSean"
  self.tInfo.SeanMinigamePt = gsA1Factory .. "main\\PlayerInChairMiniGame"
  self.tInfo.KeyNode = gsA1Factory .. "interogationroomkey"
  self.tInfo.IntKey = "Act1_IntKey"
  self.tInfo.Motorcycle = gsA1Factory .. "escape\\Motorcycle"
  self.tInfo.KeyGuard = gsA1Factory .. "eventnazis\\KeyNazi"
  self.tInfo.KeyGuard2 = gsA1Factory .. "eventnazis\\KeyNazi2"
  self.tInfo.StealthGuard = gsA1Factory .. "eventnazis\\StealthNazi"
  self.tInfo.GunGuard = gsA1Factory .. "smokeNazis\\GunNazi"
  self.tInfo.SmokeGuard = gsA1Factory .. "smokeNazis\\SmokeNazi"
  self.tInfo.tSpawnedVehicle = {}
  self.tInfo.CameoNazis = {
    {
      Name = gsA1Factory .. "cameonazis\\Detlef",
      Path = gsA1Factory .. "cameonazis\\PATH_1"
    },
    {
      Name = gsA1Factory .. "cameonazis\\Frannie",
      Path = gsA1Factory .. "cameonazis\\PATH_2"
    },
    {
      Name = gsA1Factory .. "cameonazis\\Scientist",
      Path = gsA1Factory .. "cameonazis\\PATH_3"
    },
    {
      Name = gsA1Factory .. "cameonazis\\Spore_TS1",
      Path = gsA1Factory .. "cameonazis\\PATH_1"
    },
    {
      Name = gsA1Factory .. "cameonazis\\Spore_TS2",
      Path = gsA1Factory .. "cameonazis\\PATH_3"
    }
  }
  self:AddOnCancelCallback(Act_1_Factory.Reset)
  self:AddOnCompleteCallback(Act_1_Factory.Reset)
  Sound.SetMusicLocale("A1M4_Escape")
  Sound.SetMusicLocale("m_A1M4_Escape", "A1M4_start")
  EVENT_PlayerEntersTrigger("Act_1_Factory.LetitRain", self, gsA1Factory .. "main\\REG_LetitRain")
end

function Act_1_Factory:MISSION_ONCANCEL()
  Sound.UnloadSoundBank("M_A1M4_InGame.bnk")
end

function Act_1_Factory:Reset()
  Suspicion.EnableGlobal(true)
  Suspicion.EnableEscalation(true)
  WorldSMEDNodes.UnloadNode(gsA1Factory .. "cameonazis", true)
  WorldSMEDNodes.UnloadNode(gsA1Factory .. "smokeNazis", true)
  self:UnloadTaskNodes("Act_1_Factory.Task_CutsceneIN", true)
  Util.LoadStaticENTag("Dopp_ClosedDoor", false)
  Cin.StopCinematic("A1M4_A_ZeppelinBalcony")
  Cin.StopCinematic("A1M4_Torture_Event")
  Combat.GlobalAllowGrenades(true)
  self:PurgeSpawners()
end

function Act_1_Factory:TeleportDone()
  self:JulesInChair(true)
  EVENT_Timer("Act_1_Factory.Task_CutsceneIN", self, 3)
end

function Act_1_Factory:SeanInChair(bSit)
  local hPt = Util.GetHandleByName(self.tInfo.SeanChairPt)
  if hPt and bSit then
    Actor.UseAttrPt(hSab, hPt)
  elseif hPt then
    Actor.CancelAttrPt(hSab)
  end
end

function Act_1_Factory:JulesInChair(bSit)
  local hPt = Util.GetHandleByName("Missions\\act_1\\factory\\jules\\AttrPt_PrisonerSitforever")
  local hJules = Util.GetHandleByName("Missions\\act_1\\factory\\jules\\Dead_Jules")
  if hPt and hJules and bSit then
    Actor.UseAttrPt(hJules, hPt)
  elseif hPt and hJules then
    Actor.CancelAttrPt(hJules)
  end
end

function Act_1_Factory:Task_CutsceneIN()
  self:CreateTask({
    sName = "Task_CutsceneIN",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "122_CinB_JDead",
    sMusicLocale = "A1M4_Escape",
    tCinematicNodes = {
      "122_cinb_jdead"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.KillJules,
        {self}
      },
      {
        Util.SetOverrideLoadScreenFadeIn,
        {false}
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "Act_1_Factory.Checkpoint1"
        }
      }
    }
  })
end

function Act_1_Factory:KillJules()
  Render.WTFSetOverrideBlueprint("WillToFight_INT_Dopp_Car_low")
  local hInterogationRoomDoor = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\2nd_floor\\InterogationRoomDoorPt")
  AttractionPt.EnableUse(hInterogationRoomDoor, false)
  local hInterogationRoomDoor4 = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\admin\\InterogationRoomDoorPt(4)")
  AttractionPt.EnableUse(hInterogationRoomDoor4, false)
  local hInterogationDoor = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\2nd_floor\\Interro_Room_Door_Front\\Dopple_Interro_Office_Door_Int")
  Object.ForceOpen(hInterogationDoor)
  local hInterogationRoomDoor2 = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\admin\\InterogationRoomDoorPt(3)")
  AttractionPt.EnableUse(hInterogationRoomDoor2, false)
  Object.ForceClose(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\2nd_floor\\interro_room_door_back\\Dopple_Interro_Office_Door"))
  local hInterogationRoomDoor3 = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\admin\\InterogationRoomDoorPt(2)")
  AttractionPt.EnableUse(hInterogationRoomDoor3, false)
end

function Act_1_Factory:Task_ParentEscapeFactory()
  self:CreateTask({
    sName = "Task_ParentEscapeFactory",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    sObjectiveTextID = "A1M4_Text.Task_ParentEscapeFactory",
    bPersistentParent = true,
    tOnActivate = {},
    tOnComplete = {}
  })
end

function Act_1_Factory:Checkpoint1()
  Suspicion.EnableGlobal(true)
  local hInterogationDoor = Handle("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\2nd_floor\\Interro_Room_Door_Front\\Dopple_Interro_Office_Door_Int")
  Object.ForceOpen(hInterogationDoor)
  self:Task_Checkpoint2()
  self:Task_GotoBalcony()
  self:Task_GotoStealth()
  self:Task_Torture()
  self:Task_MoveGuard()
  self:Task_Zepp()
  Util.UnloadStaticENTag("wpop_doppNazis", true)
  Util.UnloadStaticENTag("doppel_nazis", true)
  local hInterogationRoomDoor = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\2nd_floor\\InterogationRoomDoorPt")
  AttractionPt.EnableUse(hInterogationRoomDoor, false)
  local hInterogationRoomDoor4 = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\admin\\InterogationRoomDoorPt(4)")
  AttractionPt.EnableUse(hInterogationRoomDoor4, false)
  local hInterogationDoor = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\2nd_floor\\Interro_Room_Door_Front\\Dopple_Interro_Office_Door_Int")
  Object.ForceOpen(hInterogationDoor)
  local hInterogationRoomDoor2 = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\admin\\InterogationRoomDoorPt(3)")
  AttractionPt.EnableUse(hInterogationRoomDoor2, false)
  Object.ForceClose(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\2nd_floor\\interro_room_door_back\\Dopple_Interro_Office_Door"))
  local hInterogationRoomDoor3 = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\admin\\InterogationRoomDoorPt(2)")
  AttractionPt.EnableUse(hInterogationRoomDoor3, false)
  Sound.SetMusicLocale("A1M4_Escape")
  Sound.SetMusicLocale("m_A1M4_Escape", "A1M4_start")
end

function Act_1_Factory:HostileGuards()
  Suspicion.EnableGlobal(true)
  if self.tInfo.bClearRestrictedArea then
  else
  end
end

function Act_1_Factory:Task_GotoBalcony()
  self:CreateTask({
    sName = "Task_GotoBalcony",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "A1M4_Text.Task_GotoBalcony",
    Proximity = 4,
    bNoGroundBlip = true,
    tDestProximityObj = {
      "Missions\\act_1\\factory\\main\\LOC_BalconyDoor"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        self.HostileGuards,
        {self}
      },
      {
        Sound.SetMusicLocale,
        {
          "m_A1M4_Escape",
          "A1M4_start"
        }
      }
    },
    tOnComplete = {}
  })
end

function Act_1_Factory:Task_Torture()
  self:CreateTask({
    sName = "Task_Torture",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsA1Factory .. "main\\REG_TortureScene"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_CutsceneTorture,
        {self}
      },
      {
        self.SetupTortureScene,
        {self}
      }
    }
  })
end

function Act_1_Factory:Task_CutsceneTorture()
  self:CreateTask({
    sName = "Task_CutsceneTorture",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "A1M4_Torture_Event",
    bLoop = true,
    tOnActivate = {
      {
        self.SetupTortureScene,
        {self}
      },
      {
        self.SetupKillTortureCin,
        {self}
      },
      {
        EVENT_PlayerEntersTrigger,
        {
          "Act_1_Factory.KillTortureCin",
          self,
          "Missions\\act_1\\factory\\main\\REG_BalconyNazi"
        }
      }
    },
    tOnComplete = {}
  })
end

function Act_1_Factory:KillTortureCin()
  print("killing torture cin")
  Cin.StopCinematic("A1M4_Torture_Event")
  self:ResetTaskByName("Task_CutsceneTorture", true)
  self:ResetTaskByName("Task_Torture")
end

function Act_1_Factory:SetupTortureScene()
  local hTorture1 = Util.GetHandleByName("Missions\\act_1\\factory\\torture_scene\\Spore_NZ_T_Assist")
  local hTorture2 = Util.GetHandleByName("Missions\\act_1\\factory\\torture_scene\\Spore_NZ_T_Weill")
  local hTorture3 = Util.GetHandleByName("Missions\\act_1\\factory\\torture_scene\\Spore_CV_Worker_M")
  if hTorture1 then
    Suspicion.Enable(hTorture1, false)
  end
  if hTorture2 then
    Suspicion.Enable(hTorture2, false)
  end
  if hTorture3 then
    Suspicion.Enable(hTorture3, false)
    Actor.SetPanicEnabled(hTorture3, false)
  end
end

function Act_1_Factory:Task_GotoStealth()
  self:CreateTask({
    sName = "Task_GotoStealth",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsA1Factory .. "main\\REG_Stealth"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_StealthTutorial,
        {self}
      },
      {
        Cin.PlayCinematic,
        {
          "A1M4_A_Stealth"
        }
      }
    }
  })
end

function Act_1_Factory:Task_Zepp()
  self:CreateTask({
    sName = "Task_Zepp",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsA1Factory .. "main\\REG_CIN_StartBlimp01"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_CinStartZep01,
        {self}
      }
    }
  })
end

function Act_1_Factory:Task_CinStartZep01()
  self:CreateTask({
    sName = "Task_CinStartZep01",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "A1M4_A_ZeppelinWindow",
    bLoop = false,
    tOnActivate = {
      {
        Render.EnableLightning(true)
      }
    },
    tOnComplete = {}
  })
end

function Act_1_Factory:Task_StealthTutorial()
  self:CreateTask({
    sName = "Task_StealthTutorial",
    sTaskType = "SabTaskObjectiveDestroy",
    sObjectiveTextID = "A1M4_Text.Task_StealthTutorial",
    sTaskSubType = "Kill",
    tTgtInclude = {
      self.tInfo.StealthGuard
    },
    tOnActivate = {
      {
        Saboteur.ShowToolTip,
        {
          "TutorialTip_Text.Stealth_Kills",
          20
        }
      },
      {
        Render.Rain,
        {0.8, 1}
      },
      {
        self.Task_SnapNeck,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Act_1_Factory:Task_SnapNeck()
  self:CreateTask({
    sName = "Task_SnapNeck",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsA1Factory .. "main\\REG_SnapNeck"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {}
  })
end

function Act_1_Factory:Task_LadderTutorial()
  self:CreateTask({
    sName = "Task_LadderTutorial",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsA1Factory .. "main\\REG_Ladder"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.KillTaskByName,
        {
          self,
          "Task_StealthTutorial"
        }
      }
    }
  })
end

function Act_1_Factory:Task_MoveGuard()
  self:CreateTask({
    sName = "Task_MoveGuard",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsA1Factory .. "main\\REG_BalconyNazi"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.MoveGuard,
        {self}
      }
    }
  })
end

function Act_1_Factory:MoveGuard()
  local hNazi = Util.GetHandleByName("Missions\\act_1\\factory\\eventnazis\\ThrowNazi")
  if hNazi then
    Combat.SetIdleScripted(hNazi, true)
    Nav.SetScriptedPath(hNazi, "Missions\\act_1\\factory\\eventnazis\\PTH_BalconyNazi", false)
    Nav.SetScriptedPathType(hNazi, cPATHTYPE_ONCE)
    Combat.SetIdleScripted(hNazi, true)
  end
end

function Act_1_Factory:MoveGuard2()
  local hNazi = Util.GetHandleByName("Missions\\act_1\\factory\\main\\ThrowNazi(2)")
  if hNazi then
    Combat.SetIdleScripted(hNazi, true)
    Nav.SetScriptedPath(hNazi, "Missions\\act_1\\factory\\main\\PTH_RooftopNazi01", false)
    Nav.SetScriptedPathType(hNazi, cPATHTYPE_BOUNCE)
  end
end

function Act_1_Factory:Task_ThrowGuard()
  self:CreateTask({
    sName = "Task_ThrowGuard",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsA1Factory .. "main\\REG_Throw"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {}
  })
end

function Act_1_Factory:Task_Planes()
  self:CreateTask({
    sName = "Task_Planes",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "A1M4_A_ZeppelinBalcony",
    bLoop = true,
    tOnActivate = {},
    tOnComplete = {}
  })
end

function Act_1_Factory:Task_Zepp2()
  self:CreateTask({
    sName = "Task_Zepp2",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "A1M4_A_ZeppelinBalcony2",
    tOnActivate = {},
    tOnComplete = {}
  })
end

function Act_1_Factory:Task_Checkpoint2()
  self:CreateTask({
    sName = "Task_Checkpoint2",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsA1Factory .. "main\\REG_LetitRain"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Act_1_Factory.Checkpoint2"
        }
      }
    }
  })
end

function Act_1_Factory:Checkpoint2()
  Suspicion.EnableGlobal(true)
  Suspicion.EnableEscalation(true)
  if not self:IsMissionTaskActive("Task_Torture") then
    self:Task_Torture()
  end
  Sound.SetMusicLocale("A1M4_Escape")
  Sound.SetMusicLocale("m_A1M4_Escape", "A1M4_start")
  self:Task_ClamberCutscene()
  self:Task_StartCameoWalkers()
  self:Task_SwitchStates()
  self:Task_LadderTutorial()
  self:Task_Hatch()
  local hInterogationRoomDoor = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\2nd_floor\\InterogationRoomDoorPt")
  AttractionPt.EnableUse(hInterogationRoomDoor, false)
  local hInterogationRoomDoor4 = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\admin\\InterogationRoomDoorPt(4)")
  AttractionPt.EnableUse(hInterogationRoomDoor4, false)
  local hInterogationDoor = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\2nd_floor\\Interro_Room_Door_Front\\Dopple_Interro_Office_Door_Int")
  Object.ForceOpen(hInterogationDoor)
  local hInterogationRoomDoor2 = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\admin\\InterogationRoomDoorPt(3)")
  AttractionPt.EnableUse(hInterogationRoomDoor2, false)
  Object.ForceClose(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\2nd_floor\\interro_room_door_back\\Dopple_Interro_Office_Door"))
  local hInterogationRoomDoor3 = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\admin\\InterogationRoomDoorPt(2)")
  AttractionPt.EnableUse(hInterogationRoomDoor3, false)
end

function Act_1_Factory:Task_ClamberCutscene()
  self:CreateTask({
    sName = "Task_ClamberCutscene",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "A1M4_DoppleClimb",
    tOnActivate = {
      {
        self.Task_Planes,
        {self}
      },
      {
        self.Task_Zepp2,
        {self}
      },
      {
        Sound.SetMusicLocale,
        {
          "A1M4_Escape"
        }
      },
      {
        Sound.SetMusicLocale,
        {
          "m_A1M4_Escape",
          "A1M4_clamber"
        }
      }
    },
    tOnComplete = {
      {
        self.Task_ClamberTutorial,
        {self}
      },
      {
        self.Task_Clamber,
        {self}
      }
    }
  })
end

function Act_1_Factory:Task_ClamberTutorial()
  self:CreateTask({
    sName = "Task_ClamberTutorial",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsA1Factory .. "main\\REG_Clamber"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {}
  })
end

function Act_1_Factory:Task_Clamber()
  self:CreateTask({
    sName = "Task_Clamber",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "A1M4_Text.Task_Clamber",
    tDestRegion = {
      gsA1Factory .. "main\\REG_ClimbTo"
    },
    bNoGroundBlip = true,
    tDeliverObjs = {hSab},
    tLocators = {
      "Missions\\act_1\\factory\\main\\LOC_ClamberTo"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_GotoLadder1,
        {self}
      }
    }
  })
end

function Act_1_Factory:Task_GotoLadder1()
  self:CreateTask({
    sName = "Task_GotoLadder1",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "A1M4_Text.Task_GotoLadder1",
    Proximity = 4.5,
    bBlipLocatorsOnly = true,
    bNoGroundBlip = true,
    tLocators = {
      "Missions\\act_1\\factory\\main\\LOC_LadderDown"
    },
    tDestProximityObj = {
      "Missions\\act_1\\factory\\main\\LOC_LadderDownProx"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_GotoLadder2,
        {self}
      },
      {
        WorldSMEDNodes.LoadNode,
        {
          gsA1Factory .. "smokeNazis"
        }
      },
      {
        Suspicion.ResetEscalation,
        {}
      }
    }
  })
end

function Act_1_Factory:Task_GotoLadder2()
  self:CreateTask({
    sName = "Task_GotoLadder2",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "A1M4_Text.Task_GotoLadder2",
    Proximity = 2.5,
    bBlipLocatorsOnly = true,
    bNoGroundBlip = true,
    tDestProximityObj = {
      "Missions\\act_1\\factory\\main\\LOC_HatchLadderProx"
    },
    tLocators = {
      "Missions\\act_1\\factory\\main\\LOC_HatchLadder"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_EscapeFactory,
        {self}
      },
      {
        Util.EnableTutorial,
        {
          "TutorialTip_Text.Weapon_Switch",
          true
        }
      }
    }
  })
end

function Act_1_Factory:Task_StartCameoWalkers()
  self:CreateTask({
    sName = "Task_StartCameoWalkers",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsA1Factory .. "main\\REG_CameoWalk"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.StartWalkers,
        {self}
      },
      {
        self.Task_ClearCameoWalkers,
        {self}
      },
      {
        Sound.SetMusicLocale,
        {
          "A1M4_Escape"
        }
      },
      {
        Sound.SetMusicLocale,
        {
          "m_A1M4_Escape",
          "A1M4_sneak"
        }
      },
      {
        Render.Rain,
        {0, 1}
      },
      {
        Suspicion.EnableGlobal,
        {false}
      }
    }
  })
end

function Act_1_Factory:Task_Hatch()
  self:CreateTask({
    sName = "Task_Hatch",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsA1Factory .. "main\\REG_OpenHatch"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        WorldSMEDNodes.LoadNode,
        {
          gsA1Factory .. "cameonazis"
        }
      }
    },
    tOnReset = {
      {
        WorldSMEDNodes.UnloadNode,
        {
          gsA1Factory .. "cameonazis",
          true
        }
      }
    },
    tOnComplete = {}
  })
end

function Act_1_Factory:Task_OpenHatch()
  self:CreateTask({
    sName = "Task_OpenHatch",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Use",
    sObjectiveTextID = "A1M4_Text.Task_OpenHatch",
    tTgtInclude = {
      "Missions\\act_1\\factory\\main\\DoorTriggerPoint"
    },
    tOnComplete = {},
    tOnActivate = {}
  })
end

function Act_1_Factory:StartWalkers()
  for i, tWalker in pairs(self.tInfo.CameoNazis) do
    local hWalker = Util.GetHandleByName(tWalker.Name)
    if hWalker then
      Nav.SetScriptedPath(hWalker, tWalker.Path, false)
      Nav.SetScriptedPathType(hWalker, cPATHTYPE_ONCE)
      Combat.SetIdleScripted(hWalker, true)
    else
      print("No handle found for ", tWalker.Name)
    end
  end
  Cin.PlayConversation("A1M4_OverhearFranziska")
end

function Act_1_Factory:Task_ClearCameoWalkers()
  self:CreateTask({
    sName = "Task_ClearCameoWalkers",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsA1Factory .. "main\\REG_Despawn"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        WorldSMEDNodes.UnloadNode,
        {
          gsA1Factory .. "cameonazis",
          true
        }
      }
    }
  })
end

function Act_1_Factory:Task_SwitchStates()
  self:CreateTask({
    sName = "Task_SwitchStates",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsA1Factory .. "main\\REG_SwitchStates"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Act_1_Factory.Checkpoint3",
          nil,
          nil,
          Util.GetHandleByName("Missions\\act_1\\factory\\main\\FIREFIGHT_TEST")
        }
      }
    }
  })
end

function Act_1_Factory:SuspicionSwitch()
  Suspicion.EnableGlobal(true)
end

function Act_1_Factory:SmokerSequenceConversation()
  Cin.PlayConversation("A1M4_StealthKillGuard")
  EVENT_Timer("Act_1_Factory.SmokerWalkDelay", self, 5)
  EVENT_Timer("Act_1_Factory.SmokerWalkDelay2", self, 7)
end

function Act_1_Factory:SmokerWalkDelay()
  local hSmoke = Util.GetHandleByName(self.tInfo.SmokeGuard)
  print("run little path smoke nazi, run", hSmoke)
  Combat.SetIdleScripted(hSmoke, true)
  Nav.SetScriptedPath(hSmoke, "Missions\\act_1\\factory\\smokeNazis\\SmokePath", false)
  Nav.SetScriptedPathMoveMode(hSmoke, false)
end

function Act_1_Factory:SmokerWalkDelay2()
  local hOfficer = Util.GetHandleByName(self.tInfo.GunGuard)
  Nav.SetScriptedPath(hOfficer, "Missions\\act_1\\factory\\smokeNazis\\PTH_SmokerTalker_01", false)
  Combat.SetIdleScripted(hOfficer, true)
  Nav.SetScriptedPathMoveMode(hOfficer, false)
end

function Act_1_Factory:SmokerSequence()
end

function Act_1_Factory:SmokerSequence2()
  local hSmoke = Util.GetHandleByName(self.tInfo.SmokeGuard)
  if not self.tInfo.bSmokerSequence2 then
    Nav.SetScriptedPath(hSmoke, "Missions\\act_1\\factory\\main\\SmokePathReturn", true, "Act_1_Factory.Fightitup", self, {hSmoke})
    Nav.SetScriptedPathMoveMode(hSmoke, false)
    Combat.SetIdleScripted(hSmoke, true)
    self.tInfo.bSmokerSequence2 = true
    self:GoFightWin()
  end
end

function Act_1_Factory:CornerCoverTut()
  Saboteur.ShowToolTip("TutorialTip_Text.Using_Corner_Cover")
end

function Act_1_Factory:LowCoverTut()
  Sound.SetMusicLocale("A1M4_Escape")
  Sound.SetMusicLocale("m_A1M4_Escape", "A1M4_lobbyfight")
end

function Act_1_Factory:SightingTut()
  Saboteur.ShowToolTip("TutorialTip_Text.Weapon_Sight")
end

function Act_1_Factory:GrenadeTut()
  Util.EnableTutorial("TutorialTip_Text.Weapon_Grenade", true)
end

function Act_1_Factory:Fightitup(hSmoke)
  Combat.SetCombat(hSmoke)
  Combat.SetTarget(hSmoke, hSab)
  Combat.SetLethalForce(hSmoke, true)
end

function Act_1_Factory:Task_KillGunGuard()
  self:CreateTask({
    sName = "Task_KillGunGuard",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "Kill",
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    tTgtInclude = {
      self.tInfo.GunGuard
    },
    tOnActivate = {
      {
        self.SetupMP40,
        {self}
      }
    },
    tOnComplete = {
      {
        Suspicion.EnableGlobal,
        {true}
      },
      {
        self.KillTaskByName,
        {
          self,
          "Task_Failsafe"
        }
      }
    }
  })
end

function Act_1_Factory:SetupMP40()
end

function Act_1_Factory:Task_GunTutorial()
  self:CreateTask({
    sName = "Task_GunTutorial",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Fetch",
    bBlueprintFetch = true,
    TaskCount = 1,
    bOnAnyPickup = true,
    tDeliverObjs = {
      "WP_SH_12GaugePump",
      "WP_MG_MP40",
      "WP_PS_WaltherPPK",
      "WP_MG_MP44"
    },
    tOnActivate = {
      {
        EVENT_PlayerEntersTrigger,
        {
          "Act_1_Factory.CornerCoverTut",
          self,
          "Missions\\act_1\\factory\\main\\REG_GlassWalk_1"
        }
      },
      {
        EVENT_PlayerEntersTrigger,
        {
          "Act_1_Factory.LowCoverTut",
          self,
          "Missions\\act_1\\factory\\main\\REG_CoverTutorial"
        }
      },
      {
        EVENT_PlayerEntersTrigger,
        {
          "Act_1_Factory.SightingTut",
          self,
          "Missions\\act_1\\factory\\main\\REG_NShowRoom_1"
        }
      },
      {
        EVENT_PlayerEntersTrigger,
        {
          "Act_1_Factory.GrenadeTut",
          self,
          "Missions\\act_1\\factory\\main\\REG_NShowRoom_2"
        }
      }
    },
    tOnComplete = {
      {
        Util.QueueTutorial,
        {
          "TutorialTip_Text.Weapon_Fire_Title",
          "TutorialTip_Text.Weapon_Fire",
          10,
          true
        }
      }
    }
  })
end

function Act_1_Factory:Checkpoint3()
  print("CHECKPOINT 3")
  if not self:IsMissionTaskActive("Task_EscapeFactory") then
    self:Task_EscapeFactory()
  end
  Sound.SetMusicLocale("A1M4_Escape")
  Sound.SetMusicLocale("m_A1M4_Escape", "A1M4_start")
  Saboteur.ShowToolTip("TutorialTip_Text.Weapon_Pick_Up")
  Util.EnableTutorial("TutorialTip_Text.Weapon_Switch", true)
  self:PurgeSpawners()
  self:SmokerSequenceConversation()
  self:Task_KillGunGuard()
  self:SuspicionSwitch()
  local hInterogationRoomDoor = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\2nd_floor\\InterogationRoomDoorPt")
  AttractionPt.EnableUse(hInterogationRoomDoor, false)
  local hInterogationRoomDoor4 = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\admin\\InterogationRoomDoorPt(4)")
  AttractionPt.EnableUse(hInterogationRoomDoor4, false)
  local hInterogationDoor = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\2nd_floor\\Interro_Room_Door_Front\\Dopple_Interro_Office_Door_Int")
  Object.ForceOpen(hInterogationDoor)
  local hInterogationRoomDoor2 = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\admin\\InterogationRoomDoorPt(3)")
  AttractionPt.EnableUse(hInterogationRoomDoor2, false)
  Object.ForceClose(Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\2nd_floor\\interro_room_door_back\\Dopple_Interro_Office_Door"))
  local hInterogationRoomDoor3 = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\doppelsieg_factory\\admin\\InterogationRoomDoorPt(2)")
  AttractionPt.EnableUse(hInterogationRoomDoor3, false)
  self:Task_Failsafe()
  self:Task_UseCover()
  self:NaziSpawners()
  self:Task_GunTutorial()
  self:RegisterEvent(hEvent)
end

function Act_1_Factory:Task_EscapeFactory()
  self:CreateTask({
    sName = "Task_EscapeFactory",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "A1M4_Text.Task_EscapeFactory",
    tDestRegion = {
      gsA1Factory .. "main\\REG_Escape"
    },
    bNoGroundBlip = true,
    tLocators = {
      gsA1Factory .. "main\\LOC_Escape"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end

function Act_1_Factory:GoFightWin()
  Suspicion.EnableEscalation(true)
end

function Act_1_Factory:Task_Failsafe()
  self:CreateTask({
    sName = "Task_Failsafe",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsA1Factory .. "main\\REG_TriggerAlarm"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        Suspicion.EnableGlobal,
        {true}
      },
      {
        Suspicion.EnableEscalation,
        {true}
      }
    }
  })
end

function Act_1_Factory:FailSafeCheck()
  self.tInfo.hMP40 = nil
  self:Task_GunTutorial()
end

function Act_1_Factory:TestSMEDNaziSpawners()
  local MySpawner = AggroSpawner:CreateSpawner("Missions\\act_1\\factory\\main\\CoDSpawner")
  table.insert(self.tInfo.tSpawners, MySpawner)
end

function Act_1_Factory:NaziSpawners()
end

function Act_1_Factory:PurgeSpawners()
  for _, oSpawner in pairs(self.tInfo.tSpawners) do
  end
  for _, oSpawner in pairs(self.tInfo.tSpawners) do
  end
  self.tInfo.tSpawners = {}
end

function Act_1_Factory:Task_UseCover()
  self:CreateTask({
    sName = "Task_UseCover",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsA1Factory .. "main\\REG_CoverTutorial"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {}
  })
end

function Act_1_Factory:LetitRain()
  Render.Rain(0.8, 1)
end
