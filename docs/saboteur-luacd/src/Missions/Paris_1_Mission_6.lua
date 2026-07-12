if Paris_1_Mission_6 == nil then
  Paris_1_Mission_6 = SabTaskObjective:Create()
  gsP1M6Dir = "Missions\\paris_1\\mission_6\\"
  Paris_1_Mission_6:Configure({
    TaskCount = 999,
    bStarterless = true,
    sSaveMissionNameID = "MissionNames_Text.P1M6",
    tUnlockList = {
      "Connect_ST_325_Escape"
    },
    bSLOverrideFade = true,
    bForceUnloadNodes = true,
    sHQNextMissionStartPoint = _cHQe_LAVILLETTE,
    tSMEDNodes = {
      "Missions\\paris_1\\mission_6\\general"
    },
    tStaticTags = {
      "p1m6_fences",
      "p1m6_props"
    },
    tDeleteNodes = {
      "Missions\\paris_1\\mission_6\\DeleteTrigger"
    }
  })
end

function Paris_1_Mission_6:STARTER_Setup()
end

function Paris_1_Mission_6:KillYouDamnNazis()
  local hTrigger = Util.GetHandleByName("Missions\\paris_1\\mission_6\\general\\REG_NaziDeathIsBeautiful")
  local hSurroundingNaziFilter = Filter.New("Nazi")
  local tBastardNazis = {}
  if hTrigger then
    tBastardNazis = Trigger.GetAllWithin(hTrigger, hSurroundingNaziFilter)
  end
  if tBastardNazis and tBastardNazis[1] then
    for i, Nazi in pairs(tBastardNazis) do
      Object.Kill(Nazi)
    end
  end
  Filter.Delete(hSurroundingNaziFilter)
end

function Paris_1_Mission_6:Activated()
  SabTaskObjective.Activated(self)
  Sound.LoadSoundBank("m_P1M6_InGame.bnk")
  self.GENERAL_Setup(self)
  Util.EnableMiniZep(false)
  self:Task_EnterHQ()
  Freeplay.UnloadAmbientFreeplay(true)
  Util.EnableAmbientEvents(false)
  Train.TrainSystemEnable(false)
  Suspicion.EnableEscalation(true)
end

function Paris_1_Mission_6:GENERAL_Setup()
  self.tInfo.Veronique = "Missions\\paris_1\\mission_6\\veronique\\VeronFighter"
  Util.DisableShopKeeperBlip("Missions\\freeplay\\garage\\lavillette_garage\\Spore_RS_Garagekeeper", true)
  RewardsManager.UnloadColby("Garagekeeper_lavillette", true)
  Sound.SetMusicLocale("P1M6_LaVilletteDefend")
  Sound.SetMusicLocale("m_P1M6_LaVilletteDefend", "P1M6_start")
  Suspicion.SetFixedEscalationLevel(4)
  self.tInfo.RearLoc = "Missions\\paris_1\\mission_6\\general\\LOC_HQ_Rear"
  self.tInfo.FrontLoc = "Missions\\paris_1\\mission_6\\general\\LOC_HQ_Front"
  self.tInfo.SideEntrance = "Missions\\paris_1\\mission_6\\general\\LOC_SideEntrance"
  self.tInfo.Side = "Missions\\paris_1\\mission_6\\general\\LOC_Side"
  self.tInfo.Side2 = "Missions\\paris_1\\mission_6\\general\\LOC_Side2"
  self.tInfo.LOC99 = "Missions\\paris_1\\mission_6\\general\\LOC_HQ_LOC99"
  self.tInfo.FrontSpawn1 = "Missions\\paris_1\\mission_6\\general\\LOC_Front_Spawn_1"
  self.tInfo.FrontSpawn2 = "Missions\\paris_1\\mission_6\\general\\LOC_Front_Spawn_2"
  self.tInfo.FrontLoc2 = "Missions\\paris_1\\mission_6\\general\\LOC_HQ_Front2"
  self.tInfo.FrontLoc3 = "Missions\\paris_1\\mission_6\\general\\LOC_HQ_Front3"
  self.tInfo.FrontLoc4 = "Missions\\paris_1\\mission_6\\general\\LOC_HQ_Front4"
  self.tInfo.FrontTurret = "Missions\\paris_1\\mission_6\\general\\LOC_FrontTurret"
  self.tInfo.RearTurret = "Missions\\paris_1\\mission_6\\general\\LOC_RearTurret"
  self.tInfo.TopSideTurret = "Missions\\paris_1\\mission_6\\general\\LOC_TopSideTurret"
  self.tInfo.PathTurnFront = "Missions\\paris_1\\mission_6\\general\\Path_FrontTurnAround"
  self.tInfo.RearLoc1 = "Missions\\paris_1\\mission_6\\general\\LOC_HQ_Rear_1"
  self.tInfo.RearLoc2 = "Missions\\paris_1\\mission_6\\general\\LOC_HQ_Rear_2"
  self.tInfo.RearLoc3 = "Missions\\paris_1\\mission_6\\general\\LOC_HQ_Rear_3"
  self.tInfo.SideSpawn1 = "Missions\\paris_1\\mission_6\\general\\LOC_Spawn_Side"
  self.tInfo.DefendFront = "Missions\\paris_1\\mission_6\\general\\LOC_DefendFront"
  self.tInfo.DefendRear = "Missions\\paris_1\\mission_6\\general\\LOC_DefendRear"
  self.tInfo.DefendTopSide = "Missions\\paris_1\\mission_6\\general\\LOC_DefendTopSide"
  self.tInfo.SideTank = "Missions\\paris_1\\mission_6\\general\\LOC_SideTank"
  self.tInfo.SideTankPath1 = "Missions\\paris_1\\mission_6\\general\\PATH_Tank1"
  self.tInfo.SideTankPath2 = "Missions\\paris_1\\mission_6\\general\\PATH_Tank2"
  self.tInfo.tExplosionLocators = {
    "Missions\\paris_1\\mission_6\\general\\LOC_Exp_01",
    "Missions\\paris_1\\mission_6\\general\\LOC_Exp_02",
    "Missions\\paris_1\\mission_6\\general\\LOC_Exp_03",
    "Missions\\paris_1\\mission_6\\general\\LOC_Exp_04",
    "Missions\\paris_1\\mission_6\\general\\LOC_Exp_05",
    "Missions\\paris_1\\mission_6\\general\\LOC_Exp_06",
    "Missions\\paris_1\\mission_6\\general\\LOC_Exp_07",
    "Missions\\paris_1\\mission_6\\general\\LOC_Exp_BlowHole"
  }
  self.tInfo.ResistenceGoTeamSquad = {
    "Missions\\paris_1\\mission_6\\civilians\\Marielle_Outside",
    "Missions\\paris_1\\mission_6\\civilians\\Luc",
    "Missions\\paris_1\\mission_6\\veronique\\VeronFighter"
  }
  self.tInfo.ResistenceRedShirts = {
    "Missions\\paris_1\\mission_6\\civilians\\SquadBuddy1",
    "Missions\\paris_1\\mission_6\\civilians\\SquadBuddy2"
  }
  self.tInfo.FirstWaveNazis = {
    "Missions\\paris_1\\mission_6\\nazis\\first_wave_soldiers\\Slaughterhouse_Guard_03",
    "Missions\\paris_1\\mission_6\\nazis\\first_wave_soldiers\\Slaughterhouse_Guard_04",
    "Missions\\paris_1\\mission_6\\nazis\\first_wave_soldiers\\Slaughterhouse_Guard_05"
  }
  self.tInfo.SecondWaveNazis = {
    "Missions\\paris_1\\mission_6\\nazis\\second_wave_soldiers\\GateCrasher3",
    "Missions\\paris_1\\mission_6\\nazis\\second_wave_soldiers\\GateCrasher2",
    "Missions\\paris_1\\mission_6\\nazis\\second_wave_soldiers\\GateCrasher1"
  }
  self.tInfo.OpelEngineerConfigs = {
    Pilot = "Human_SS_Heavy_MG",
    Shotgun = "Human_SS_P1M6_Grenadier",
    Passengers = {
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG"
    }
  }
  self.tInfo.OpelEngineer2Configs = {
    Pilot = "Human_SS_Heavy_MG",
    Shotgun = "Human_SS_P1M6_Grenadier",
    Passengers = {
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG"
    }
  }
  self.tInfo.OpelFlameThrowerConfigs = {
    Pilot = "Human_SS_Heavy_MG",
    Shotgun = "Human_SS_P1M6_Grenadier",
    Passengers = {
      "Human_SS_Flame_FT",
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG"
    }
  }
  self.tInfo.OpelRPGConfigs = {
    Pilot = "Human_SS_Heavy_MG",
    Shotgun = "Human_SS_Grenadier_RPG",
    Passengers = {
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG"
    }
  }
  self.tInfo.APCEngineerConfigs = {
    Pilot = "Human_SS_Heavy_MG",
    Shotgun = "Human_SS_P1M6_Grenadier",
    Gunner = "Human_WM_Grunt_MG",
    Passengers = {
      "Human_SS_Heavy_MG",
      "Human_WM_Rifleman_RF",
      "Human_TS_Trooper_MG"
    }
  }
  self.tInfo.APCEngineerFlameConfigs = {
    Pilot = "Human_SS_Heavy_MG",
    Shotgun = "Human_SS_P1M6_Grenadier",
    Gunner = "Human_SS_Heavy_MG",
    Passengers = {
      "Human_TS_Trooper_MG",
      "Human_SS_Flame_FT",
      "Human_SS_Heavy_MG"
    }
  }
  self.tInfo.APCRPGConfigs = {
    Pilot = "Human_SS_Heavy_MG",
    Shotgun = "Human_SS_Grenadier_RPG",
    Gunner = "Human_WM_Grunt_MG",
    Passengers = {
      "Human_TS_Trooper_MG"
    }
  }
  self.tInfo.APCConfigs = {
    Pilot = "Human_SS_Heavy_MG",
    Gunner = "Human_WM_Grunt_MG",
    Shotgun = "Human_WM_Heavy_SH",
    Passengers = {
      "Human_TS_Trooper_MG",
      "Human_SS_Flame_FT",
      "Human_SS_Heavy_MG"
    }
  }
  self.tInfo.KubelEngConfigs = {
    Pilot = "Human_SS_Heavy_MG",
    Shotgun = "Human_SS_P1M6_Grenadier",
    Passengers = {
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG"
    }
  }
  self.tInfo.MountedKubelConfigs = {
    Pilot = "Human_WM_Grunt_MG",
    Gunner = "Human_WM_Grunt_MG",
    Shotgun = "Human_SS_Heavy_MG"
  }
  self.tInfo.MountedKubel2Configs = {
    Pilot = "Human_WM_Rifleman_RF",
    Gunner = "Human_WM_Grunt_MG",
    Shotgun = "Human_WM_Rifleman_RF"
  }
  self.tInfo.MountedKubel3Configs = {
    Pilot = "Human_WM_Rifleman_RF",
    Gunner = "Human_WM_Grunt_MG"
  }
  self.tInfo.MountedEngKubelConfigs = {
    Pilot = "Human_WM_Rifleman_RF",
    Gunner = "Human_WM_Grunt_MG",
    Shotgun = "Human_SS_P1M6_Grenadier"
  }
  self.tInfo.REAR = 1
  self.tInfo.FRONT = 2
  self.tInfo.SIDE = 3
  self.tInfo.VehicleInfo = {
    FrontSpawner = {
      {
        cType = cVEH_KUBELTURRET,
        DropOffPath = "Missions\\paris_1\\mission_6\\general\\PATH_Front_1a",
        Pickup = self.tInfo.FrontSpawn2,
        bDoubleSpawn = true,
        SeatingConfig = self.tInfo.MountedKubel2Configs,
        ID = self.tInfo.FRONT
      },
      {
        cType = cVEH_HALFTRACK,
        DropOffPath = "Missions\\paris_1\\mission_6\\general\\PATH_Front_1",
        Pickup = self.tInfo.FrontSpawn1,
        SeatingConfig = self.tInfo.APCEngineerConfigs,
        ID = self.tInfo.FRONT,
        bEngineer = true
      },
      {
        cType = cVEH_KUBEL,
        DropOffPath = "Missions\\paris_1\\mission_6\\general\\PATH_Front_2",
        Pickup = self.tInfo.FrontSpawn2,
        bDoubleSpawn = true,
        SeatingConfig = self.tInfo.KubelEngConfigs,
        ID = self.tInfo.FRONT,
        bEngineer = true
      },
      {
        cType = cVEH_KUBELTURRET,
        DropOffPath = "Missions\\paris_1\\mission_6\\general\\PATH_Front_3a",
        Pickup = self.tInfo.FrontSpawn2,
        SeatingConfig = self.tInfo.MountedKubel2Configs,
        ID = self.tInfo.FRONT
      },
      {
        cType = cVEH_KUBELTURRET,
        DropOffPath = "Missions\\paris_1\\mission_6\\general\\PATH_Front_3a",
        Pickup = self.tInfo.FrontSpawn2,
        bDoubleSpawn = true,
        SeatingConfig = self.tInfo.MountedKubel2Configs,
        ID = self.tInfo.FRONT
      },
      {
        cType = cVEH_KUBEL,
        DropOffPath = "Missions\\paris_1\\mission_6\\general\\PATH_Front_3",
        Pickup = self.tInfo.FrontSpawn2,
        SeatingConfig = self.tInfo.KubelEngConfigs,
        ID = self.tInfo.FRONT,
        bEngineer = true
      },
      {
        cType = cVEH_HALFTRACK,
        DropOffPath = "Missions\\paris_1\\mission_6\\general\\PATH_Front_4",
        Pickup = self.tInfo.FrontSpawn2,
        SeatingConfig = self.tInfo.APCEngineerFlameConfigs,
        ID = self.tInfo.FRONT,
        bEngineer = true
      }
    },
    RearSpawner = {
      {
        cType = cVEH_KUBEL,
        Pickup = self.tInfo.SideSpawn1,
        ExitTarget = "Missions\\paris_1\\mission_6\\general\\LOC_DespawnTruck(2)",
        DropOffPath = "Missions\\paris_1\\mission_6\\general\\PATH_Rear_1",
        SeatingConfig = self.tInfo.KubelEngConfigs,
        ID = self.tInfo.REAR
      },
      {
        ExitTarget = "Missions\\paris_1\\mission_6\\general\\LOC_DespawnTruck(2)",
        cType = cVEH_HALFTRACK,
        DropOffPath = "Missions\\paris_1\\mission_6\\general\\PATH_Rear_3",
        Pickup = self.tInfo.SideSpawn1,
        SeatingConfig = self.tInfo.APCEngineerConfigs,
        ID = self.tInfo.REAR
      },
      {
        cType = cVEH_HALFTRACK,
        ExitTarget = "Missions\\paris_1\\mission_6\\general\\LOC_DespawnTruck(2)",
        DropOffPath = "Missions\\paris_1\\mission_6\\general\\PATH_Rear_3",
        Pickup = self.tInfo.SideSpawn1,
        SeatingConfig = self.tInfo.APCEngineerConfigs,
        ID = self.tInfo.REAR
      }
    },
    SideSpawner = {
      {
        cType = cVEH_KUBELTURRET,
        DropOffPath = "Missions\\paris_1\\mission_6\\general\\PATH_Side_1",
        Pickup = self.tInfo.SideSpawn1,
        ExitPath = "Missions\\paris_1\\mission_6\\general\\PATH_SideRearExit2",
        SeatingConfig = self.tInfo.MountedKubelConfigs,
        ID = self.tInfo.SIDE
      },
      {
        cType = cVEH_KUBELTURRET,
        bDoubleSpawn = true,
        DropOffPath = "Missions\\paris_1\\mission_6\\general\\PATH_Side_2a",
        Pickup = self.tInfo.SideSpawn1,
        SeatingConfig = self.tInfo.MountedKubel3Configs,
        ID = self.tInfo.SIDE,
        bDumpPilot = true
      },
      {
        cType = cVEH_HALFTRACK,
        DropOffPath = "Missions\\paris_1\\mission_6\\general\\PATH_Side_1",
        Pickup = self.tInfo.SideSpawn1,
        ExitPath = "Missions\\paris_1\\mission_6\\general\\PATH_SideRearExit2",
        SeatingConfig = self.tInfo.APCConfigs,
        ID = self.tInfo.SIDE
      }
    },
    Wave5 = {
      {
        Vehicle = "Missions\\paris_1\\mission_6\\nazis\\fifth_wave_tanks\\VEH_FifthWave_Tank_01",
        DropOff = self.tInfo.Side
      }
    }
  }
  self.tInfo.FifthWaveNazis = {
    "Missions\\paris_1\\mission_6\\nazis\\fifth_wave_tanks\\VEH_FifthWave_Tank_01",
    "Missions\\paris_1\\mission_6\\nazis\\fifth_wave_tanks\\Tank_Nazi_Lft1",
    "Missions\\paris_1\\mission_6\\nazis\\fifth_wave_tanks\\Tank_Nazi_Lft2",
    "Missions\\paris_1\\mission_6\\nazis\\fifth_wave_tanks\\Tank_Nazi_Rgt1",
    "Missions\\paris_1\\mission_6\\nazis\\fifth_wave_tanks\\Tank_Nazi_Rgt2"
  }
  self.tSaveInfo.LucEngineerConv = 1
  self.tSaveInfo.SkylarEngineerConv = 1
  self.tSaveInfo.cFrontEngineersMAX = 4
  self.tSaveInfo.cRearEngineersMAX = 3
  self.tSaveInfo.cFrontTSMAX = 0
  self.tSaveInfo.cRearTSMAX = 0
  self.tSaveInfo.FrontTSDead = 0
  self.tSaveInfo.RearTSDead = 0
  self.tSaveInfo.FrontEngineersDead = 0
  self.tSaveInfo.RearEngineersDead = 0
  self.tSaveInfo.DeadEngineers = 0
  self.tSaveInfo.Detonations = 0
  self.tSaveInfo.PlantAttempts = 0
  self.tInfo.LIVE = 1
  self.tInfo.ATTEMPTING = 2
  self.tInfo.BOOM = 3
  self.tInfo.TankDamage = 0.5
  self.tInfo._KillThisWave = 0
  self.tSaveInfo.BombPoints = {
    {
      sBomb = "Missions\\paris_1\\mission_6\\general\\AIPt_Exp_1Front",
      Piece = "PARIS\\area01\\lavillette\\buildings\\MN_LaVillette_Abattoir\\MN_LaVillette_CNRF01A_Broken",
      STATE = self.tInfo.LIVE,
      Side = self.tInfo.FRONT,
      vCurrentUser = ""
    },
    {
      sBomb = "Missions\\paris_1\\mission_6\\general\\AIPt_Exp_2Front",
      Piece = "PARIS\\area01\\lavillette\\buildings\\MN_LaVillette_Abattoir\\MN_LaVillette_CNRF01B_broken",
      STATE = self.tInfo.LIVE,
      Side = self.tInfo.FRONT,
      vCurrentUser = ""
    },
    {
      sBomb = "Missions\\paris_1\\mission_6\\general\\AIPt_Exp_1Rear",
      Piece = "PARIS\\area01\\lavillette\\buildings\\MN_LaVillette_Abattoir\\MN_LaVillette_CNRF01B_broken(1)",
      STATE = self.tInfo.LIVE,
      Side = self.tInfo.REAR,
      vCurrentUser = ""
    },
    {
      sBomb = "Missions\\paris_1\\mission_6\\general\\AIPt_Exp_2Rear",
      Piece = "PARIS\\area01\\lavillette\\buildings\\MN_LaVillette_Abattoir\\MN_LaVillette_CNRF01A_Broken(1)",
      STATE = self.tInfo.LIVE,
      Side = self.tInfo.REAR,
      vCurrentUser = ""
    }
  }
  self.tInfo.tEngineers = {}
  self.tInfo.tTerrors = {}
  self.tInfo.HQMAXHEALTH = 100
  self.tInfo.HQHALFHEALTH = self.tInfo.HQMAXHEALTH / 2
  self.tSaveInfo.HQHEALTH = self.tInfo.HQMAXHEALTH
  self.tInfo.tTruckNazis = {}
  self.tInfo.EngineerDamage = self.tInfo.HQMAXHEALTH / 4
  self.tSaveInfo.BombSide = self.tInfo.REAR
  self.tSaveInfo.TruckWave = 1
  self.tSaveInfo.bSideEventSet = false
  self.tSaveInfo.bCrashSafteyBelt = false
  self.tSaveInfo.bFireBombBoomCut = false
  self.tSaveInfo.bDriveNDropActive = false
  self.tSaveInfo.bAutoDamager = false
  self.tSaveInfo.bRunNaziOnce = false
  self.tSaveInfo.bHQAlive = true
  self.tSaveInfo.bSetPieceDamageEvents = false
  Util.LoadStaticENTag("p1m6_smokescreen", true)
end

function Paris_1_Mission_6:Debug_PrintTruckWaveInfo()
  print("---TRUCK WAVE INITIAL VARS---")
  print("* self.tSaveInfo.BombSide \t\t\t", self.tSaveInfo.BombSide)
  print("* self.tSaveInfo.TruckWave \t\t\t", self.tSaveInfo.TruckWave)
  print("* self.tSaveInfo.bSideEventSet \t\t", self.tSaveInfo.bSideEventSet)
  print("* self.tSaveInfo.bDriveNDropActive \t", self.tSaveInfo.bDriveNDropActive)
  print("* self.tSaveInfo.FrontEngineersDead \t", self.tSaveInfo.FrontEngineersDead)
  print("* self.tSaveInfo.RearEngineersDead \t", self.tSaveInfo.RearEngineersDead)
  print("* self.tSaveInfo.DeadEngineers \t\t", self.tSaveInfo.DeadEngineers)
  print("* self.tSaveInfo.Detonations \t\t", self.tSaveInfo.Detonations)
  print("* self.tSaveInfo.PlantAttempts \t\t", self.tSaveInfo.PlantAttempts)
  print("* self.tSaveInfo.HQHEALTH \t\t\t", self.tSaveInfo.HQHEALTH)
  print("* self.tInfo._KillThisWave \t\t\t", self.tInfo._KillThisWave)
  print("-----END TRUCK WAVE INITIAL VARS-----")
end

function Paris_1_Mission_6:MISSION_ONRESET()
  Sound.ReleaseSoundBank("m_p1m6_inGame.bnk")
  Squad.SetParent("GenericNazi", nil)
  Squad.Delete("P1M6")
  Squad.Delete("P1M6_Nazi")
  Squad.Delete("P1M6_NaziTankSquad")
  Squad.Delete("Rez")
  Freeplay.UnloadAmbientFreeplay(false)
  Util.EnableAmbientEvents(true)
  Util.EnableSuperSpores(true)
  Train.TrainSystemEnable(true)
  Vehicle.EnableTraffic(true)
  self:RemoveHQHealth()
  if self.tInfo.tTruckNazis then
    for i, hNazi in pairs(self.tInfo.tTruckNazis) do
      if Object.IsAlive(hNazi) then
        Vehicle.AddToTraffic(hNazi)
      end
    end
  end
  self.tInfo.tTruckNazis = {}
  Suspicion.SetFixedEscalationLevel(0)
  Suspicion.ResetEscalation()
  Suspicion.EnableEscalation(true)
  Suspicion.EnableEscalationVehicles(true)
  self:LockLavaDoor("PARIS\\area01\\lavillette\\interior\\lavillette_ext\\TeleporterDoorPoint", false)
  Sound.ResetMusicLocale()
  Util.EnableMiniZep(true)
  self.tSaveInfo.bAutoDamager = false
  Util.UnloadStaticENTag("p1m6_smokescreen", true)
  Util.SetDynamicPriority("VH_NZ_CR_Kubelwagen_01", -1)
  Util.SetDynamicPriority("VH_NZ_CR_Kubelwagen_mount", -1)
  Util.SetDynamicPriority("VH_NZ_TK_Maus_01", -1)
  Util.SetDynamicPriority("VH_NZ_TR_HalfTrack_01", -1)
  Util.SetDynamicPriority("Human_SS_P1M6_Grenadier", -1)
  RewardsManager.LoadColby("Garagekeeper_lavillette", true)
  Util.DisableShopKeeperBlip("Missions\\freeplay\\garage\\lavillette_garage\\Spore_RS_Garagekeeper", false)
  Cin.AllowAttackingDuringCinematics(false)
end

function Paris_1_Mission_6:MISSION_ONCANCEL()
  RewardsManager.UnLockHQPoint(_cHQ_LAVILLETTE, true, true)
  self:RemoveHQHealth()
  self.tSaveInfo.bAutoDamager = false
  Zone.SwitchState("WtF_Zones\\global\\P1M1B_SlaughterhouseLiberate", cZONESTATE_HIGHCOLOR_HIGHTAG, cENT_IMMEDIATE)
end

function Paris_1_Mission_6:RemoveHQHealth()
  if self.tSaveInfo.hHQObj then
    print("removing hq health")
    HUD.RemoveObjective(self.tSaveInfo.hHQObj)
    self.tSaveInfo.hHQObj = nil
  end
end

function Paris_1_Mission_6:Task_EnterHQ()
  self:CreateTask({
    sName = "Task_EnterHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "EnterInterior",
    sInteriorName = "LaVillette",
    tOnActivate = {
      {
        InteriorManager.EnterInterior,
        {"LaVillette"}
      }
    },
    tOnComplete = {
      {
        self.StreamChars,
        {self}
      }
    }
  })
end

function Paris_1_Mission_6:SetupSquads()
  Squad.Create("P1M6_Nazi")
  Squad.Create("P1M6_NaziTankSquad")
  Squad.SetParent("GenericNazi", "P1M6_Nazi")
  Squad.SetParent("P1M6_NaziTankSquad", "GenericNazi")
  Squad.Create("P1M6")
  Squad.Create("Rez")
  Squad.SetParent("P1M6", "Rez")
  Squad.AddMember("P1M6", hSab)
  Squad.SetEnemy("Rez", "GenericNazi")
  Squad.SetLethal("Rez", true)
  Squad.SetLeader("P1M6", hSab)
  Squad.SetRadius("P1M6", 8)
  Squad.FollowLeader("P1M6")
end

function Paris_1_Mission_6:LockLavaDoor(sAttrpt, bLocked)
  local hDoor = Handle(sAttrpt)
  if hDoor then
    AttractionPt.EnableUse(hDoor, not bLocked)
  end
end

function Paris_1_Mission_6:StreamChars()
  local tPeeps = {
    "Missions\\paris_1\\characters\\lavillette\\skylar_interior\\Skylar_LaVillette_Interior",
    "Missions\\paris_1\\characters\\lavillette\\kessler_interior\\Kessler_LaVillette_Interior",
    "Missions\\paris_1\\characters\\lavillette\\maria_interior\\Maria_LaVillette_Interior",
    "Missions\\paris_1\\characters\\lavillette\\veronique_interior\\Veronique_LaVillette_Interior",
    "Missions\\paris_1\\characters\\lavillette\\luc_interior\\Luc_LaVillette_Interior"
  }
  EVENT_Stream("Paris_1_Mission_6.Task_OpeningCin", self, tPeeps, true)
end

function Paris_1_Mission_6:Task_OpeningCin()
  self:CreateTask({
    sName = "Task_OpeningCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "324_CinB_Defend",
    tOnActivate = {
      {
        self.RemoveWeapons,
        {self}
      }
    },
    tOnComplete = {
      {
        Util.SetOverrideLoadScreenFadeIn,
        {false}
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "Paris_1_Mission_6.Checkpoint0"
        }
      },
      {
        Sound.SetMusicLocale,
        {
          "P1M6_LaVilletteDefend"
        }
      },
      {
        Sound.SetMusicLocale,
        {
          "m_P1M6_LaVilletteDefend",
          "P1M6_start"
        }
      }
    }
  })
end

function Paris_1_Mission_6:Checkpoint0()
  self:RunInteriorStuff()
  self:TASK_Dust()
  self:Task_ProtectHQ()
  RewardsManager.HideStarter("Spore_RS_Skylar", true)
  RewardsManager.HideStarter("Spore_RS_Renard", true)
  RewardsManager.HideStarter("vittore_garage", true)
  RewardsManager.HideStarter("santos_ext_hideout", true)
end

function Paris_1_Mission_6:Task_ProtectHQ()
  self:CreateTask({
    sName = "Task_ProtectHQ",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "Defend",
    tLocators = {
      "Missions\\paris_1\\mission_6\\general\\LOC_CenterSlaugherHouse"
    },
    bNoFocus = true,
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    tOnComplete = {
      {
        self.RemoveHQHealth,
        {self}
      }
    },
    tOnCancel = {
      {
        self.MissionTaskFail,
        {
          self,
          "P1M6_Text.ProtectHQFailure"
        }
      }
    },
    tOnReset = {},
    tOnActivate = {
      {
        self.CPFunctionActivation,
        {self}
      }
    }
  })
end

function Paris_1_Mission_6:RemoveWeapons()
  local hRes1 = Handle("Missions\\cinematics\\324_cinb_defend\\Spore_WRS_Attack_Random")
  local hRes2 = Handle("Missions\\cinematics\\324_cinb_defend\\Spore_WRS_Attack_Random(1)")
  local hLuc = Handle("Missions\\paris_1\\characters\\lavillette\\luc_interior\\Luc_LaVillette_Interior")
  local hMore = Handle("Missions\\cinematics\\324_cinb_defend\\Spore_WRS_Attack_Random(2)")
  if hMore then
    Inventory.RemoveAllWeapons(hMore)
  end
  local hMore = Handle("Missions\\cinematics\\324_cinb_defend\\Spore_WRS_Attack_Random(3)")
  if hMore then
    Inventory.RemoveAllWeapons(hMore)
  end
  if hRes1 then
    Inventory.RemoveAllWeapons(hRes1)
  end
  if hRes2 then
    Inventory.RemoveAllWeapons(hRes2)
  end
  if hLuc then
    Inventory.RemoveAllWeapons(hLuc)
  end
end

function Paris_1_Mission_6:RunInteriorStuff()
  local hSkylar = Handle("Missions\\paris_1\\characters\\lavillette\\skylar_interior\\Skylar_LaVillette_Interior")
  local hLuc = Handle("Missions\\paris_1\\characters\\lavillette\\luc_interior\\Luc_LaVillette_Interior")
  local hKessler = Handle("Missions\\paris_1\\characters\\lavillette\\kessler_interior\\Kessler_LaVillette_Interior")
  local hMaria = Handle("Missions\\paris_1\\characters\\lavillette\\maria_interior\\Maria_LaVillette_Interior")
  local hVeron = Handle("Missions\\paris_1\\characters\\lavillette\\veronique_interior\\Veronique_LaVillette_Interior")
  local hRes1 = Handle("Missions\\cinematics\\324_cinb_defend\\Spore_WRS_Attack_Random")
  local hRes2 = Handle("Missions\\cinematics\\324_cinb_defend\\Spore_WRS_Attack_Random(1)")
  local hAttVeron = Handle("Missions\\paris_1\\mission_6\\general\\ATTRPT_veron")
  local hAPRight = Handle("Missions\\paris_1\\mission_6\\general\\APCoverHighRight")
  local hAPLeft = Handle("Missions\\paris_1\\mission_6\\general\\APCoverHighLeft")
  local hHunch = Handle("Missions\\paris_1\\mission_6\\general\\ATTRPT_CIV_Thinking_PERM")
  local hSadd = Handle("Missions\\paris_1\\mission_6\\general\\ATTRPT_CIV_Polite_Headnod_PERM")
  local hRunto = Handle("Missions\\paris_1\\mission_6\\general\\LOC_Int_DoorSpot2")
  local hRunto3 = Handle("Missions\\paris_1\\mission_6\\general\\LOC_Int_DoorSpot1")
  if hSkylar and hRunto3 then
    print("skylar move to obj")
    Combat.SetIdleScripted(hSkylar, true)
    Combat.SetIdleHoldWeapon(hSkylar, true)
    Actor.CancelAttrPtRequest(hSkylar)
    Nav.MoveToObject(hSkylar, hRunto3, 1, true)
  end
  if hVeron and hAttVeron then
    Combat.SetIdleScripted(hVeron, true)
    Inventory.GiveItem(hVeron, "WP_PS_Mauser", true)
    Combat.SetIdleHoldWeapon(hVeron, true)
    Actor.CancelAttrPtRequest(hVeron)
    Nav.MoveToObject(hVeron, hAttVeron, 1, true, "Paris_1_Mission_6.UsePoint", self, {hVeron, hAttVeron})
  end
  if hKessler and hSadd then
    Combat.SetIdleScripted(hKessler, true)
    Actor.CancelAttrPtRequest(hKessler)
    Nav.MoveToObject(hKessler, hSadd, 1, false, "Paris_1_Mission_6.UsePoint", self, {hKessler, hSadd})
  end
  if hMaria and hHunch then
    Combat.SetIdleScripted(hMaria, true)
    Actor.CancelAttrPtRequest(hMaria)
    Nav.MoveToObject(hMaria, hHunch, 1, false, "Paris_1_Mission_6.UsePoint", self, {hMaria, hHunch})
  end
  if hLuc and hRunto then
    Combat.SetIdleScripted(hLuc, true)
    Nav.MoveToObject(hLuc, hRunto, 1, true)
    Combat.SetIdleHoldWeapon(hLuc, true)
    Actor.CancelAttrPtRequest(hLuc)
    Inventory.RemoveAllWeapons(hLuc)
  end
  if hRes1 and hAPRight then
    Combat.SetIdleScripted(hRes1, true)
    Actor.CancelAttrPtRequest(hRes1)
    Nav.MoveToObject(hRes1, hAPRight, 1, true, "Paris_1_Mission_6.UsePoint", self, {hRes1, hAPRight})
  end
  if hRes2 and hAPLeft then
    Combat.SetIdleScripted(hRes2, true)
    Actor.CancelAttrPtRequest(hRes2)
    Nav.MoveToObject(hRes2, hAPLeft, 1, true, "Paris_1_Mission_6.UsePoint", self, {hRes2, hAPLeft})
  end
  self.tInfo.bHQBoom = true
  self:HQBoom()
end

function Paris_1_Mission_6:HQBoom()
  if self.tInfo.bHQBoom then
    local hLoc = Handle("Missions\\paris_1\\mission_6\\general\\LOC_Explosion")
    local x, y, z = Object.GetPosition(hLoc)
    Util.CreateExplosion("Explosion_Sab_DynamiteFuse", x, y, z)
    local time = math.random(1, 8)
    EVENT_Timer("Paris_1_Mission_6.CS", self, time)
    EVENT_Timer("Paris_1_Mission_6.HQBoom", self, time)
  end
end

function Paris_1_Mission_6:CS()
  local x, y, z = Object.GetPosition(hSab)
  Render.CameraShakeExplosion(x, y, z, 20, 10, 12)
end

function Paris_1_Mission_6:UsePoint(hActor, hAP)
  if hActor and hAP then
    Actor.RequestAttrPt(hActor, hAP)
  end
end

function Paris_1_Mission_6:TASK_Dust()
  self:CreateTask({
    sName = "TASK_Dust",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "NONE",
    tSMEDNodes = {
      "Missions\\paris_1\\mission_6\\BlastDust"
    },
    tOnComplete = {
      {
        self.UnloadTaskNodes,
        {
          self,
          "TASK_Dust",
          true
        }
      }
    }
  })
end

function Paris_1_Mission_6:TASK_LoadResist()
  self:CreateTask({
    sName = "TASK_LoadResist",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "NONE",
    tSMEDNodes = {
      "Missions\\paris_1\\mission_6\\civilians",
      "Missions\\paris_1\\mission_6\\veronique"
    }
  })
end

function Paris_1_Mission_6:CPFunctionActivation()
  local sCPName = self:GetCheckpointName()
  print("CPFunctionActivation: checkpoint name = ", sCPName)
  if sCPName == "Paris_1_Mission_6.Checkpoint0" then
    self:LockLavaDoor("PARIS\\area01\\lavillette\\interior\\lavillette_ext\\TeleporterDoorPoint", true)
    self:RemoveHQHealth()
    self:SetupHQHealth()
    self:Task_Exit()
    self:TASK_LoadResist()
  elseif sCPName == "Paris_1_Mission_6.Checkpoint_PostEngineerCin" then
    self:RemoveHQHealth()
    self:SetupHQHealth()
  elseif sCPName == "Paris_1_Mission_6.Checkpoint_Tank" then
    self:RemoveHQHealth()
    self:SetupHQHealth()
  elseif sCPName == "Paris_1_Mission_6.Checkpoint_TruckWaves" then
    self:RemoveHQHealth()
    self:SetupHQHealth()
    self:Task_TruckWave2()
  end
end

function Paris_1_Mission_6:Task_Exit()
  self:CreateTask({
    sName = "Task_Exit",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sObjectiveTextID = "GenericObjective_Text.HQ_P1_Exit",
    sInteriorName = "LaVillette",
    bInteriorTask = true,
    tOnActivate = {
      {
        Zone.SwitchState,
        {
          "WtF_Zones\\global\\P1M1B_SlaughterhouseLiberate",
          cZONESTATE_LOWCOLOR_HIGHTAG,
          cENT_REALLYNOCHANGE,
          true
        }
      }
    },
    tOnComplete = {
      {
        self.CompleteTaskByName,
        {self, "TASK_Dust"}
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "Paris_1_Mission_6.Checkpoint_PostEngineerCin"
        }
      }
    }
  })
end

function Paris_1_Mission_6:Task_CinEngineer()
  self:CreateTask({
    sName = "Task_CinEngineer",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    tSMEDNodes = {},
    tOnActivate = {},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Paris_1_Mission_6.Checkpoint_PostEngineerCin"
        }
      }
    }
  })
end

function Paris_1_Mission_6:Checkpoint_PostEngineerCin()
  self:SetupSquads()
  Freeplay.UnloadAmbientFreeplay(true)
  Util.EnableAmbientEvents(false)
  Train.TrainSystemEnable(false)
  self:Debug_PrintTruckWaveInfo()
  self.tInfo.bHQBoom = false
  self.tSaveInfo.bAutoDamager = false
  print("__Checkpoint_PostEngineerCin")
  if not self:IsMissionTaskActive("Task_ProtectHQ") then
    self:Task_ProtectHQ()
    self:SetupSquad()
    self:SetupVeron()
  end
  if Vehicle.IsTrafficEnabled() then
    Vehicle.EnableTraffic(false, true)
  end
  RewardsManager.UnLockHQPoint(_cHQ_LAVILLETTE, false, true)
  Util.EnableSuperSpores(false)
  self:BuildSquad()
  Suspicion.SetEscalated()
  self:Task_GotoMeat()
  self:Task_RunRes()
  if not self:IsMissionTaskActive("WarningZone") then
    self:WarningZone()
  end
  if not self:IsMissionTaskActive("TASK_TooFarAway") then
    self:TASK_TooFarAway()
  end
end

function Paris_1_Mission_6:BlowHole(sPiece, sPart)
  local hPiece = Util.GetHandleByName(sPiece)
  Damage.SetDamageState(hPiece, sPart, 1)
end

function Paris_1_Mission_6:BuildSquad()
  self:SetupSquad()
  self:SetupVeron()
end

function Paris_1_Mission_6:SetupVeron()
  EVENT_Stream("Paris_1_Mission_6.SetupVeronStream", self, self.tInfo.ResistenceGoTeamSquad, true)
end

function Paris_1_Mission_6:SetupSquad()
  EVENT_Stream("Paris_1_Mission_6.SetSquad", self, self.tInfo.ResistenceRedShirts, true)
end

function Paris_1_Mission_6:SetupVeronStream()
  Suspicion.EnableEscalationVehicles(false)
  for i, Res in pairs(self.tInfo.ResistenceGoTeamSquad) do
    local hVeron = Handle(Res)
    Actor.SetDropWeaponWhenRagdolled(hVeron, false)
    Object.SetInvincibleToAI(hVeron, true)
    if self:GetCheckpointName() == "Paris_1_Mission_6.Checkpoint_PostEngineerCin" then
      Combat.SetLeader(hVeron, hSab, false, 6, 12)
    end
    Combat.SetIdleScripted(hVeron, true)
    Combat.AddTargetFlag(hVeron, cTARGET_NAZI)
    Combat.AddTargetFlag(hVeron, cTARGET_ALLENEMIESHOSTILE)
    if i == 2 then
      Inventory.RemoveAllWeapons(hVeron)
      Inventory.GiveItem(hVeron, "WP_SH_12GaugePump", true)
    else
      Inventory.GiveItem(hVeron, "WP_MG_MP40", true)
    end
    Combat.SetIdleHoldWeapon(hVeron, true)
  end
end

function Paris_1_Mission_6:SetSquad()
  for i, v in pairs(self.tInfo.ResistenceRedShirts) do
    local hRes = Util.GetHandleByName(v)
    if hRes then
      Squad.AddMember("Rez", hRes)
      Object.SetHealth(hRes, 150)
      Combat.SetIdleScripted(hRes, true)
      Inventory.GiveItem(hRes, "WP_MG_MP40", true)
      Combat.SetIdleHoldWeapon(hRes, true)
    end
  end
end

function Paris_1_Mission_6:Task_GotoMeat()
  self:CreateTask({
    sName = "Task_GotoMeat",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "goto",
    Proximity = 5,
    tDestProximityObj = {
      "Missions\\paris_1\\mission_6\\general\\LOC_Rez1"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        self.Task_FirstWave,
        {self}
      },
      {
        self.Task_GotoMoreMeat,
        {self}
      },
      {
        self.BuildingEngineerPiecesDE,
        {self}
      }
    },
    tOnComplete = {
      {
        self.Task_SecondWave,
        {self}
      }
    }
  })
end

function Paris_1_Mission_6:DEBUGTANK()
  self:RegisterCheckpoint("Paris_1_Mission_6.Checkpoint_Tank")
end

function Paris_1_Mission_6:Task_GotoMoreMeat()
  self:CreateTask({
    sName = "Task_GotoMoreMeat",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "goto",
    Proximity = 5,
    tDestProximityObj = {
      "Missions\\paris_1\\mission_6\\general\\LOC_MoreMeat"
    },
    bNoBlips = true,
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteTaskByName,
        {
          self,
          "Task_GotoMeat"
        }
      }
    }
  })
end

function Paris_1_Mission_6:Task_RunRes()
  self:CreateTask({
    sName = "Task_RunRes",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "goto",
    tDestRegion = {
      "Missions\\paris_1\\mission_6\\general\\REG_Run"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.RunToLoc,
        {
          self,
          "Missions\\paris_1\\mission_6\\civilians\\SquadBuddy1",
          "Missions\\paris_1\\mission_6\\general\\LOC_Rez1",
          true
        }
      },
      {
        self.RunToLoc,
        {
          self,
          "Missions\\paris_1\\mission_6\\civilians\\SquadBuddy2",
          "Missions\\paris_1\\mission_6\\general\\LOC_Rez12",
          true
        }
      }
    }
  })
end

function Paris_1_Mission_6:SetupHQHealth()
  print("setting up hq health, current health = ", self.tSaveInfo.HQHEALTH, self:GetTaskObjectiveID("Task_ProtectHQ"))
  self.tSaveInfo.hHQObj = HUD.AddObjective(eOT_HEART, "P1M6_Text.HQ", 2, self:GetTaskObjectiveID("Task_ProtectHQ"))
  if self.tInfo.HQHALFHEALTH > self.tSaveInfo.HQHEALTH then
    self.tSaveInfo.HQHEALTH = self.tInfo.HQHALFHEALTH
  end
  HUD.SetupProgressBar(self.tSaveInfo.hHQObj, 0, self.tInfo.HQMAXHEALTH, self.tInfo.HQMAXHEALTH)
  HUD.SetProgressBarValue(self.tSaveInfo.hHQObj, self.tSaveInfo.HQHEALTH)
end

function Paris_1_Mission_6:HQFORCEUPATE()
  if self.tSaveInfo.hHQObj then
    print("hq health ", self.tSaveInfo.HQHEALTH)
    HUD.SetProgressBarValue(self.tSaveInfo.hHQObj, self.tSaveInfo.HQHEALTH)
  else
    print("HQFORCEUPATE oh these times are bad times")
  end
end

function Paris_1_Mission_6:HQDead()
  print("hq DEATH!!!!")
  self.tSaveInfo.bHQAlive = false
  self:FailTaskByName("Task_ProtectHQ")
end

function Paris_1_Mission_6:DamageHQ(Damager)
  local Damager = Damager or 1
  self.tSaveInfo.HQHEALTH = self.tSaveInfo.HQHEALTH - Damager
  if self.tSaveInfo.hHQObj and self.tSaveInfo.HQHEALTH >= 0 then
    HUD.SetProgressBarValue(self.tSaveInfo.hHQObj, self.tSaveInfo.HQHEALTH)
  else
    print("DamageHQ oh these times are bad times")
  end
  print("hq health ", self.tSaveInfo.HQHEALTH)
  if self.tSaveInfo.HQHEALTH <= 0 and self.tSaveInfo.bHQAlive then
    self.tSaveInfo.bAutoDamager = false
    self:HQDead()
  end
end

function Paris_1_Mission_6:Task_FirstWave()
  self:CreateTask({
    sName = "Task_FirstWave",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "Kill",
    sObjectiveTextID = "P1M6_Text.GetToFight",
    bNoFocus = true,
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    tSMEDNodes = {
      "Missions\\paris_1\\mission_6\\nazis\\first_wave_soldiers"
    },
    tOnComplete = {},
    tOnActivate = {}
  })
end

function Paris_1_Mission_6:SetupFirstWaveHunt()
  for _, Nazi in pairs(self.tInfo.FirstWaveNazis) do
    local hNazi = WRAPPER_CheckForHandle(Nazi)
    if hNazi then
    end
  end
end

function Paris_1_Mission_6:Task_SecondWave()
  self:CreateTask({
    sName = "Task_SecondWave",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "Kill",
    tSMEDNodes = {
      "Missions\\paris_1\\mission_6\\nazis\\second_wave_soldiers"
    },
    tOnComplete = {},
    tOnActivate = {
      {
        self.SetupDudes,
        {self}
      },
      {
        EVENT_Timer,
        {
          "Paris_1_Mission_6.TASK_LoadRearFight",
          self,
          1.5
        }
      },
      {
        EVENT_Timer,
        {
          "Paris_1_Mission_6.Task_TruckCrash",
          self,
          1
        }
      }
    }
  })
end

function Paris_1_Mission_6:SetupDudes()
  for i, dude in pairs(Paris_1_Mission_6.tInfo.SecondWaveNazis) do
    local hDude = Handle(dude)
    if hDude then
      Combat.SetIdleScripted(hDude, true)
      Actor.OverrideCombatAI(hDude, true)
    end
  end
end

function Paris_1_Mission_6:Task_TruckCrash()
  if not hTruck then
  end
  self:CreateTask({
    sName = "Task_TruckCrash",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "CIN_P1M6_TruckCrash",
    tOnActivate = {},
    tOnSkipped = {
      {
        self.TruckCrashSkipped,
        {self}
      }
    },
    tOnComplete = {
      {
        self.Task_KillTruckCrashNazis,
        {self}
      },
      {
        self.RunToLoc,
        {
          self,
          "Missions\\paris_1\\mission_6\\civilians\\SquadBuddy1",
          "Missions\\paris_1\\mission_6\\general\\LOC_Rez6",
          true
        }
      },
      {
        self.RunToLoc,
        {
          self,
          "Missions\\paris_1\\mission_6\\civilians\\SquadBuddy2",
          "Missions\\paris_1\\mission_6\\general\\LOC_Rez62",
          true
        }
      }
    }
  })
end

function Paris_1_Mission_6:TruckCrashSkipped()
  print(" !!! TruckCrashSkipped")
end

function Paris_1_Mission_6:SetCrashPassengers()
  if self.tSaveInfo.bCrashSafteyBelt then
    return
  end
  if not self.tSaveInfo.bCrashSafteyBelt then
    self.tSaveInfo.bCrashSafteyBelt = true
    self.tSaveInfo.eCrashSafteyBelt = EVENT_Timer("Paris_1_Mission_6.Checkpoint_TruckWaves", self, 12)
  end
  self:Task_KillTruckCrashNazis()
  do return end
  if not self.tInfo.tTruckCrashPassengers then
    EVENT_Timer("Paris_1_Mission_6.SetCrashPassengers", self, 1)
  else
    if self.tSaveInfo.eCrashSafteyBelt then
      Util.KillEvent(self.tSaveInfo.eCrashSafteyBelt)
    end
    self:Task_KillTruckCrashNazis()
  end
end

function Paris_1_Mission_6:CallbackCinematicUnloadNazis()
  local self = Paris_1_Mission_6
  for i, dude in pairs(Paris_1_Mission_6.tInfo.SecondWaveNazis) do
    local hDude = Handle(dude)
    if hDude then
      Combat.SetIdleScripted(hDude, true)
      Actor.OverrideCombatAI(hDude, false)
      Combat.SetTarget(hDude, hSab)
    end
  end
  for i, dude in pairs(self.tInfo.FirstWaveNazis) do
  end
  local hCinRes = Handle("Missions\\paris_1\\mission_6\\nazis\\second_wave_soldiers\\Spore_RS_Fighter_RF_Cutscene")
  if hCinRes then
    Object.Kill(hCinRes)
  end
  EVENT_Timer("Paris_1_Mission_6.SetGateCrasherAI", Paris_1_Mission_6, 3)
end

function Paris_1_Mission_6:SetGateCrasherAI()
  for i, dude in pairs(Paris_1_Mission_6.tInfo.SecondWaveNazis) do
    local hDude = Handle(dude)
    if hDude then
      Combat.SetIdleScripted(hDude, true)
      Actor.OverrideCombatAI(hDude, false)
      Combat.SetTarget(hDude, hSab)
      Combat.SetObjective(hDude, hSab, true, 3)
    end
  end
end

function Paris_1_Mission_6.CallbackCinematicExplosion()
  print("==== cine splosion")
  local hLoc = Handle("Missions\\paris_1\\mission_6\\general\\LOC_CinDoorSploder")
  local x, y, z = Object.GetPosition(hLoc)
  Util.CreateExplosion("Explosion_Medium_NoDmg", x, y, z)
  Damage.SetDamageState(Util.GetHandleByName("PARIS\\area01\\lavillette\\buildings\\MN_LaVillette_Abattoir\\MN_LaVillette_Broken_BackWall01A"), "MN_LaVillette_Broken_BackWall01A", 1)
  Object.Kill(Util.GetHandleByName("PARIS\\area01\\lavillette\\buildings\\MN_LaVillette_Abattoir\\MN_LaVillette_Broken_BackWall01A"))
  Util.UnloadStaticENTag("hqbackgatefence", true)
end

function Paris_1_Mission_6:Task_KillTruckCrashNazis()
  self:CreateTask({
    sName = "Task_KillTruckCrashNazis",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "Kill",
    sObjectiveTextID = "P1M6_Text.DefendInterior",
    tTgtInclude = self.tInfo.FirstWaveNazis,
    bNoFocus = true,
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    tOnActivate = {
      {
        self.CompleteTaskByName,
        {
          self,
          "Task_FirstWave"
        }
      }
    },
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Paris_1_Mission_6.Checkpoint_TruckWaves"
        }
      }
    }
  })
end

function Paris_1_Mission_6:Checkpoint_TruckWaves()
  self:Debug_PrintTruckWaveInfo()
  print("__Checkpoint_TruckWaves")
  self.tSaveInfo.bAutoDamager = false
  if Vehicle.IsTrafficEnabled() then
    Vehicle.EnableTraffic(false, true)
  end
  Util.EnableSuperSpores(false)
  self.tInfo._KillThisWave = 0
  if not self:IsMissionTaskActive("Task_ProtectHQ") then
    self.tSaveInfo.bSetPieceDamageEvents = false
    self:Task_ProtectHQ()
    self:SetupSquad()
    self:SetupVeron()
    self:UnloadTaskNodes("Task_SecondWave", true)
  else
    self:Task_TruckWave2()
  end
  Suspicion.SetEscalated()
  if not self:IsMissionTaskActive("WarningZone") then
    self:WarningZone()
  end
  if not self:IsMissionTaskActive("TASK_TooFarAway") then
    self:TASK_TooFarAway()
  end
  self.tInfo.tEngineers = {}
  self.tInfo.tTerrors = {}
  Util.SetDynamicPriority("VH_NZ_TR_HalfTrack_01", 1000)
  Util.SetDynamicPriority("VH_NZ_CR_Kubelwagen_01", 1000)
  Util.SetDynamicPriority("VH_NZ_CR_Kubelwagen_mount", 1000)
  Util.SetDynamicPriority("Human_SS_P1M6_Grenadier", 1000)
end

function Paris_1_Mission_6:RunLucAndSkylar()
  for i, Res in pairs(self.tInfo.ResistenceGoTeamSquad) do
    local hRes = Handle(Res)
    if hRes then
      Combat.ClearLeader(hRes)
    end
  end
  EVENT_Timer("Paris_1_Mission_6.RunLucAndSkylarAfterClear", self, 1)
end

function Paris_1_Mission_6:RunLucAndSkylarAfterClear()
  self:RunVeroniqueToLocator()
  for i, Res in pairs(self.tInfo.ResistenceGoTeamSquad) do
    local hRes = Handle(Res)
    if hRes then
      if i == 1 then
        local hLoc = Handle("Missions\\paris_1\\mission_6\\general\\LOC_Res1Runto")
        print("run skylar to front ", hRes, hLoc)
        Combat.SetObjective(hRes, hLoc, true, 3, false)
      elseif i == 2 then
        local hLoc = Handle("Missions\\paris_1\\mission_6\\general\\LOC_Res2Runto")
        print("run luc to rear ", hRes, hLoc)
        Combat.SetObjective(hRes, hLoc, true, 3, false)
      end
    end
  end
end

function Paris_1_Mission_6:RunVeroniqueToLocator()
  local hVeron = Handle(self.tInfo.Veronique)
  if hVeron then
    Combat.ClearObjective(hVeron)
    if self.tSaveInfo.BombSide == self.tInfo.FRONT then
      print("VERONIQUE RUN TO FRONTTOP")
      local hLoc = Handle("Missions\\paris_1\\mission_6\\veronique\\LOC_FrontTop")
      Combat.SetObjective(hVeron, hLoc, true, 3, false)
    elseif self.tSaveInfo.BombSide == self.tInfo.SIDE then
      print("VERONIQUE RUN TO SIDETOP")
      local hLoc = Handle("Missions\\paris_1\\mission_6\\veronique\\LOC_SideTop")
      Combat.SetObjective(hVeron, hLoc, true, 3, false)
    else
      print("VERONIQUE RUN TO REARTOP")
      local hLoc = Handle("Missions\\paris_1\\mission_6\\veronique\\LOC_RearTop")
      Combat.SetObjective(hVeron, hLoc, true, 3, false)
    end
  end
end

function Paris_1_Mission_6:Task_TruckWave1()
  self:CreateTask({
    sName = "Task_TruckWave1",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    sTaskStartConv = "P1M6_ProtectFrontEntrance",
    tOnComplete = {
      {
        self.IncrementTruckWave,
        {self, 2}
      },
      {
        self.CompleteTaskByName,
        {
          self,
          "TASK_KillFrontEngineers"
        }
      },
      {
        self.SetBombSide,
        {
          self,
          self.tInfo.SIDE
        }
      },
      {
        self.Task_TruckWave3,
        {self}
      }
    },
    tOnActivate = {
      {
        SabTaskObjective.CompleteTaskByName,
        {
          self,
          "Task_SecondWave"
        }
      },
      {
        self.Task_GotoFrontTurret,
        {self}
      },
      {
        self.RunLucAndSkylar,
        {self}
      }
    }
  })
end

function Paris_1_Mission_6:TASK_KillFrontEngineers()
  self:CreateTask({
    sName = "TASK_KillFrontEngineers",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    sObjectiveTextID = "P1M6_Text.StopEngineersShort",
    tLocators = {
      "Missions\\paris_1\\mission_6\\general\\LOC_DefendFront"
    },
    bNoWorldBlip = true,
    tOnComplete = {
      {
        self.KillTaskByName,
        {
          self,
          "Task_GotoFrontTurretSilent"
        }
      },
      {
        self.KillTaskByName,
        {
          self,
          "Task_GetBackToFrontTurret"
        }
      },
      {
        self.ClearAllEngineers,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Paris_1_Mission_6:RunToLoc(vDude, vLoc, bClearLastRun)
  local hLoc = WRAPPER_CheckForHandle(vLoc)
  local hDude = WRAPPER_CheckForHandle(vDude)
  if bClearLastRun then
    Nav.CancelScriptedPath(hDude)
    Combat.ClearObjective(hDude)
  end
  if hDude and Object.IsAlive(hDude) and hLoc and Object.GetDistance(hDude, hLoc) > 3 then
    Combat.SetObjective(hDude, hLoc, true, 2, false)
  end
end

function Paris_1_Mission_6:Task_TruckWave2()
  self:CreateTask({
    sName = "Task_TruckWave2",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tOnActivate = {
      {
        self.Task_GotoRearTurret,
        {self}
      },
      {
        self.RunLucAndSkylar,
        {self}
      },
      {
        self.RunToLoc,
        {
          self,
          "Missions\\paris_1\\mission_6\\civilians\\SquadBuddy1",
          "Missions\\paris_1\\mission_6\\general\\LOC_Rez2",
          true
        }
      },
      {
        self.RunToLoc,
        {
          self,
          "Missions\\paris_1\\mission_6\\civilians\\SquadBuddy2",
          "Missions\\paris_1\\mission_6\\general\\LOC_Rez3",
          true
        }
      },
      {
        self.BuildingEngineerPiecesDE,
        {self}
      }
    },
    tOnComplete = {
      {
        self.SetBombSide,
        {
          self,
          self.tInfo.FRONT
        }
      },
      {
        self.IncrementTruckWave,
        {self, 1}
      },
      {
        self.CompleteTaskByName,
        {
          self,
          "TASK_KillRearEngineers"
        }
      },
      {
        self.Task_TruckWave1,
        {self}
      }
    }
  })
end

function Paris_1_Mission_6:TASK_KillRearEngineers()
  self:CreateTask({
    sName = "TASK_KillRearEngineers",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    sObjectiveTextID = "P1M6_Text.StopEngineersShort",
    tLocators = {
      "Missions\\paris_1\\mission_6\\general\\LOC_DefendRear"
    },
    bNoWorldBlip = true,
    tOnComplete = {
      {
        self.KillTaskByName,
        {
          self,
          "Task_GotoRearTurretSilent"
        }
      },
      {
        self.KillTaskByName,
        {
          self,
          "Task_GetBackToRearTurret"
        }
      },
      {
        self.ClearAllEngineers,
        {self}
      }
    }
  })
end

function Paris_1_Mission_6:Task_TruckWave3()
  self:CreateTask({
    sName = "Task_TruckWave3",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    sObjectiveTextID = "P1M6_Text.DefendSide",
    tLocators = {
      "Missions\\paris_1\\mission_6\\general\\LOC_DefendTopSideBlip"
    },
    bNoWorldBlip = true,
    tOnActivate = {
      {
        self.Task_GotoTopSide,
        {self}
      },
      {
        self.TASK_LoadSideFight,
        {self}
      },
      {
        self.RunLucAndSkylar,
        {self}
      }
    },
    tOnComplete = {
      {
        self.IncrementTruckWave,
        {self, 3}
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "Paris_1_Mission_6.Checkpoint_Tank"
        }
      }
    }
  })
end

function Paris_1_Mission_6:Checkpoint_Tank()
  print("_Checkpoint Checkpoint_Tank")
  Object.SetInvincible(hSab, false)
  self.tSaveInfo.bAutoDamager = false
  if not self:IsMissionTaskActive("Task_ProtectHQ") then
    self:Task_ProtectHQ()
    self:SetupSquad()
    self:SetupVeron()
    self:TASK_LoadSideFight_NoCam()
  end
  if Vehicle.IsTrafficEnabled() then
    Vehicle.EnableTraffic(false, true)
  end
  if not self:IsMissionTaskActive("WarningZone") then
    self:WarningZone()
  end
  if not self:IsMissionTaskActive("TASK_TooFarAway") then
    self:TASK_TooFarAway()
  end
  Suspicion.SetFixedEscalationLevel(4)
  Util.SetDynamicPriority("VH_NZ_TR_OpelCanvas_01", -1)
  Util.SetDynamicPriority("VH_NZ_CR_Kubelwagen_01", -1)
  Util.SetDynamicPriority("VH_NZ_CR_Kubelwagen_mount", -1)
  Util.SetDynamicPriority("VH_NZ_TR_HalfTrack_01", -1)
  Util.SetDynamicPriority("VH_NZ_TK_Maus_01", 10000)
  EVENT_Timer("Paris_1_Mission_6.Task_Tank", self, 1)
end

function Paris_1_Mission_6:SetupVehicleSpawn(NumberOfSpawns, tVehicleInfo, RespawnTime, StartSpawnTime, debug_missionname)
  local RespawnTime = RespawnTime or 20
  local StartSpawnTime = StartSpawnTime or 25
  self.tSaveInfo.bDriveNDropActive = true
  self.tInfo.CurrentSpawn = 0
  self.tInfo.SpawnIndex = 0
  self.tInfo.NumberOfSpawns = NumberOfSpawns or 1
  self.__CurrentWaveMasterVehicleInfo = tVehicleInfo
  if not tVehicleInfo then
    Util.Assert(tVehicleInfo, "Paris_1_Mission_6.SetupVehicleSpawn tVehicleInfo is nil?")
    print("Paris_1_Mission_6.SetupVehicleSpawn tVehicleInfo is nil?")
    return
  end
  self._eMasterSpawnTimer = EVENT_Timer("Paris_1_Mission_6.RunVehicleSpawn", self, StartSpawnTime, {tVehicleInfo, RespawnTime})
  if tVehicleInfo[self.tInfo.CurrentSpawn + 1].bDoubleSpawn then
  end
end

function Paris_1_Mission_6:RunVehicleSpawn(tVehicleInfo, RespawnTime)
  self.tInfo.CurrentSpawn = self.tInfo.CurrentSpawn + 1
  self.tInfo.SpawnIndex = self.tInfo.SpawnIndex + 1
  print("RunVehicleSpawn: run vehicle spawn id ", tVehicleInfo[self.tInfo.CurrentSpawn].ID, self.tInfo.NumberOfSpawns, self.tInfo.CurrentSpawn)
  if not tVehicleInfo then
    Util.Assert(tVehicleInfo, "Paris_1_Mission_6.RunVehicleSpawn tVehicleInfo is nil?")
    print("Paris_1_Mission_6.RunVehicleSpawn tVehicleInfo is nil?")
    return
  end
  if self.tInfo._KillThisWave == tVehicleInfo[self.tInfo.CurrentSpawn].ID then
    print("Killing current vehicle spawners early Wave = ", self.tSaveInfo.TruckWave)
    return
  end
  if self.tInfo.CurrentSpawn <= self.tInfo.NumberOfSpawns and tVehicleInfo[self.tInfo.CurrentSpawn].ID == self.tSaveInfo.TruckWave then
    if tVehicleInfo[self.tInfo.CurrentSpawn] then
      print("cType ", tVehicleInfo[self.tInfo.CurrentSpawn].cType)
      self:VehicleSpawner(tVehicleInfo[self.tInfo.CurrentSpawn], tVehicleInfo)
      if tVehicleInfo[self.tInfo.CurrentSpawn].bDoubleSpawn then
        print("this vehicle has a wing man")
        self.tInfo.CurrentSpawn = self.tInfo.CurrentSpawn + 1
      end
    else
      print("no vehicle with this data")
    end
    if self.tInfo.CurrentSpawn < self.tInfo.NumberOfSpawns then
      self._eCurrentSpawnEventTimer = EVENT_Timer("Paris_1_Mission_6.RunVehicleSpawn", self, RespawnTime, {tVehicleInfo, RespawnTime})
    else
      print("truck spawns done?")
      if self.tSaveInfo.TruckWave == 1 then
        self._eCurrentSpawnCompleteTimer = EVENT_Timer("SabTaskObjective.CompleteTaskByName", self, 50, "Task_TruckWave2")
      elseif self.tSaveInfo.TruckWave == 2 then
        self._eCurrentSpawnCompleteTimer = EVENT_Timer("SabTaskObjective.CompleteTaskByName", self, 50, "Task_TruckWave1")
      elseif self.tSaveInfo.TruckWave == 3 then
        self._eCurrentSpawnCompleteTimer = EVENT_Timer("SabTaskObjective.CompleteTaskByName", self, 20, "Task_TruckWave3")
      else
        Util.Assert(false, "Cfrench: RunVehicleSpawn problems, i shouldn't be here")
      end
      print("Setting timer to kill truck wave ", self.tSaveInfo.TruckWave)
    end
  else
    self.tSaveInfo.bDriveNDropActive = false
  end
end

function Paris_1_Mission_6:KillCurrentSideSpawner()
  if self.tInfo._KillThisWave and self.tInfo._KillThisWave >= self.tSaveInfo.TruckWave then
    print("Already killing or killed wave ", self.tSaveInfo.TruckWave)
    return
  end
  print("Paris_1_Mission_6.KillCurrentSideSpawner killing this wave ", self.tSaveInfo.TruckWave)
  self.tInfo._KillThisWave = self.tSaveInfo.TruckWave
  if self._eCurrentSpawnEventTimer then
    Util.KillEvent(self._eCurrentSpawnEventTimer)
    self._eCurrentSpawnEventTimer = nil
  end
  if self._eCurrentSpawnCompleteTimer then
    Util.KillEvent(self._eCurrentSpawnCompleteTimer)
    self._eCurrentSpawnCompleteTimer = nil
  end
  if self._eMasterSpawnTimer then
    Util.KillEvent(self._eMasterSpawnTimer)
    self._eMasterSpawnTimer = nil
  end
  if self.tSaveInfo.TruckWave == 1 then
    if self:IsMissionTaskActive("Task_TruckWave2") then
      self:CompleteTaskByName("Task_TruckWave2")
    else
      print("Task_TruckWave2 was not active , failing to complete")
    end
  elseif self.tSaveInfo.TruckWave == 2 then
    if self:IsMissionTaskActive("Task_TruckWave1") then
      self:CompleteTaskByName("Task_TruckWave1")
    else
      print("Task_TruckWave1 was not active , failing to complete")
    end
  elseif self.tSaveInfo.TruckWave == 3 then
    if self:IsMissionTaskActive("Task_TruckWave3") then
      self:CompleteTaskByName("Task_TruckWave3")
    else
      print("Task_TruckWave3 was not active , failing to complete")
    end
  else
    Util.Assert(false, "Cfrench: KillCurrentSideSpawner problems, i shouldn't be here")
    print("Cfrench: KillCurrentSideSpawner problems, i shouldn't be here")
  end
end

function Paris_1_Mission_6:IncrementTruckWave(MyTruckWave)
  if MyTruckWave == self.tSaveInfo.TruckWave then
    self.tSaveInfo.TruckWave = self.tSaveInfo.TruckWave + 1
  end
end

function Paris_1_Mission_6:VehicleSpawner(tThisVehicleInfo)
  if not tThisVehicleInfo then
    print("ERROR: out of lua memory!")
  end
  if self.tSaveInfo.bDriveNDropActive then
    local unboardtype = cDROPOFF_PASSENGERS_NOGUNNER
    if tThisVehicleInfo.bDumpPilot then
      unboardtype = cDROPOFF_ALL_EXCEPT_GUNNER
    end
    local tConfig = {
      cVehicleType = tThisVehicleInfo.cType,
      tSeatConfig = tThisVehicleInfo.SeatingConfig,
      vSpawnTarget = tThisVehicleInfo.Pickup,
      sDeliveryPath = tThisVehicleInfo.DropOffPath,
      sExitPath = tThisVehicleInfo.ExitPath,
      vExitTarget = tThisVehicleInfo.ExitTarget or "Missions\\paris_1\\mission_6\\general\\LOC_DespawnTruck",
      bForceSpawn = true,
      bUrgentDelivery = true,
      bUrgentExit = true,
      nPathSpeed = tThisVehicleInfo.Speed or 45,
      cUnboardType = unboardtype,
      cDespawnType = cDESPAWN_ONEXIT_LOSCHECK,
      bHuntUnboardLoc = false,
      bAttackPlayer = true,
      tOnSpawn = {
        {
          "Paris_1_Mission_6.SpawnedVehicle",
          {true}
        }
      },
      tOnArrive = {
        {
          "Paris_1_Mission_6.STOPVEHICLE",
          {true}
        }
      },
      tOnUnboard = {
        {
          "Paris_1_Mission_6.MakeNaziMad",
          {
            tThisVehicleInfo.ID
          }
        }
      }
    }
    if not tConfig then
      Util.Assert(tConfig, "Paris_1_Mission_6.VehicleSpawner lua has died?")
      print("tConfig is nil... Paris_1_Mission_6.VehicleSpawner lua has died?")
    end
    Veh.SpawnDelivery(self, tConfig)
  else
    print("Called vehicle spawner but bDriveNDropActive is false")
  end
end

function Paris_1_Mission_6:STOPVEHICLE(hVeh)
  if hVeh then
    Vehicle.BrakeTo(hVeh, 0)
  end
  EVENT_Timer("Paris_1_Mission_6.RELEASEVEHICLE", self, 4, {hVeh})
end

function Paris_1_Mission_6:RELEASEVEHICLE(hVeh)
  if hVeh then
    Vehicle.BrakeTo(hVeh, 200)
    Vehicle.SetSuperHeavy(hVeh, false)
  end
end

function Paris_1_Mission_6:SpawnedVehicle(a_hVehicle)
  local hVehicle = a_hVehicle
  local tVehicleInfo = self.__CurrentWaveMasterVehicleInfo
  print("Vehicle Spawned:", a_hVehicle, " spawn index ", self.tInfo.SpawnIndex)
  if not tVehicleInfo then
    print("SpawnedVehicle:: ERROR tVehicleInfo is nil")
  end
  local bShouldHaveEngineer = false
  if tVehicleInfo and tVehicleInfo[self.tInfo.SpawnIndex] and tVehicleInfo[self.tInfo.SpawnIndex].bDoubleSpawn then
    self.tInfo.SpawnIndex = self.tInfo.SpawnIndex + 1
    EVENT_Timer("Paris_1_Mission_6.VehicleSpawner", self, 6, {
      tVehicleInfo[self.tInfo.SpawnIndex],
      tVehicleInfo
    })
    if tVehicleInfo[self.tInfo.SpawnIndex].bEngineer then
      bShouldHaveEngineer = tVehicleInfo[self.tInfo.SpawnIndex].bEngineer
    end
  end
  if hVehicle then
    Vehicle.SetSuperHeavy(hVehicle, true)
    table.insert(self.tInfo.tTruckNazis, hVehicle)
    local eEvent = Util.CreateEvent({
      EventType = "SeatsFilledEvent",
      Vehicle = hVehicle,
      SeatNames = {"SHOTGUN"}
    }, "Paris_1_Mission_6.CallbackShotgun", self, {hVehicle, bShouldHaveEngineer})
    self:RegisterEvent(eEvent)
  end
end

function Paris_1_Mission_6:CallbackShotgun(hVehicle, bShouldHaveEngineer)
  local hGunner
  local bFoundEngineer = false
  if hVehicle then
    local hNazi = Vehicle.GetActorInSeat(hVehicle, "SHOTGUN")
    local sEngineerLabel = "Engineer"
    if Actor.HasLabel(hNazi, sEngineerLabel) then
      print("------ CallbackShotgun:: Found an engineer ", hNazi)
      Actor.SetAutoSeatTransition(hNazi, false)
      EVENT_ActorDeath("Paris_1_Mission_6.CallbackIncrementEngineerDeath", self, hNazi, {hNazi})
      bFoundEngineer = true
    end
    if not bShouldHaveEngineer or not bFoundEngineer then
    end
  end
end

function Paris_1_Mission_6:CallbackFindingATerror(hVehicle)
  local hGunner
  if hVehicle then
    local hNazi = Vehicle.GetActorInSeat(hVehicle, "REAR_R2")
    local sTerrorLabel = "TerrorSquad"
    if Actor.HasLabel(hNazi, sTerrorLabel) then
      Actor.SetAutoSeatTransition(hNazi, false)
      EVENT_ActorDeath("Paris_1_Mission_6.CallbackIncrementEngineerDeath", self, hNazi, {-1, hNazi})
    end
  end
end

function Paris_1_Mission_6:MakeNaziMad(tNaziInfo, TruckSide)
  if tNaziInfo[1] and Object.IsAlive(tNaziInfo[1]) then
    local hLoc = tNaziInfo[2]
    local sEngineerLabel = "Engineer"
    local tEngineers = Object.GetObjectsWithLabel(hLoc, 4, sEngineerLabel)
    local sTerrorSquadLabel = "TerrorSquad"
    local tTerrors = Object.GetObjectsWithLabel(hLoc, 2, sTerrorSquadLabel)
    if tEngineers then
      for i, Engin in pairs(tEngineers) do
        if tNaziInfo[1] == Engin then
          if self.tSaveInfo.BombSide == TruckSide then
            table.insert(self.tInfo.tEngineers, tNaziInfo[1])
            self:SetUIBlips(tNaziInfo[1], true, false, false, "KILL")
            self:GotoBombLoc(tNaziInfo[1])
          end
          if self.tSaveInfo.BombSide == self.tInfo.REAR then
            if self.tSaveInfo.LucEngineerConv == 1 then
              self.tSaveInfo.LucEngineerConv = self.tSaveInfo.LucEngineerConv + 1
              Cin.PlayConversation("P1M6_Luc_Engineer_First")
            else
              Cin.PlayConversation("P1M6_Luc_Engineer_More")
            end
          end
          if self.tSaveInfo.BombSide == self.tInfo.FRONT then
            if self.tSaveInfo.SkylarEngineerConv == 1 then
              self.tSaveInfo.SkylarEngineerConv = self.tSaveInfo.SkylarEngineerConv + 1
              Cin.PlayConversation("P1M6_Skylar_Engineer_First")
            else
              Cin.PlayConversation("P1M6_Skylar_Engineer_More")
            end
          end
        end
      end
    elseif tTerrors then
      for i, Terror in pairs(tTerrors) do
        if tNaziInfo[1] == Terror then
          Combat.SetTether(tNaziInfo[1], tNaziInfo[1], 12)
          if self.tSaveInfo.BombSide == TruckSide then
            table.insert(self.tInfo.tTerrors, tNaziInfo[1])
          end
        end
      end
    else
      if hLoc then
        Combat.SetTether(tNaziInfo[1], hLoc, 15)
      else
        print("DEBUG::nazi didn't get tethered")
      end
      Combat.SetCombat(tNaziInfo[1])
      Combat.SetTarget(tNaziInfo[1], hSab)
    end
    table.insert(self.tInfo.tTruckNazis, tNaziInfo[1])
  end
end

function Paris_1_Mission_6:ClearAllEngineers()
  for i, vEngineer in pairs(self.tInfo.tEngineers) do
    local hEngineer = WRAPPER_CheckForHandle(vEngineer)
    if hEngineer then
      self:SetEngineerFree(hEngineer)
    end
  end
  for i, vTerror in pairs(self.tInfo.tTerrors) do
    local hTerror = WRAPPER_CheckForHandle(vTerror)
    if hTerror then
      Object.Kill(hTerror)
    end
  end
  self.tInfo.tEngineers = {}
  self.tInfo.tTerrors = {}
end

function Paris_1_Mission_6:AddNazisToSquad(tNazi)
  if tNazi then
    for i, Nazi in pairs(tNazi) do
      local hNazi = Util.GetHandleByName(Nazi)
      if hNazi and Object.IsAlive(hNazi) then
        Squad.AddMember("GenericNazi", hNazi)
      end
    end
  end
end

function Paris_1_Mission_6:Task_Tank()
  self:CreateTask({
    sName = "Paris_1_Mission_6_Task_Tank",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "Kill",
    sObjectiveTextID = "P1M6_Text.DestroyTankShort",
    tSMEDNodes = {
      "Missions\\paris_1\\mission_6\\nazis\\fifth_wave_tanks"
    },
    tTgtInclude = {
      self.tInfo.FifthWaveNazis[1]
    },
    MarkerHeight = 4,
    sTaskStartConv = "P1M6_DefendSide",
    tOnComplete = {
      {
        Combat.BroadcastRetreat,
        {hSab, 150}
      },
      {
        self.KillTaskByName,
        {
          self,
          "WarningZone"
        }
      },
      {
        self.SetAutoDamager,
        {self, false}
      },
      {
        self.CompleteTaskByName,
        {
          self,
          "Task_ProtectHQ"
        }
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "Paris_1_Mission_6.Checkpoint_Epilogue",
          "Paris_1_Mission_6.Checkpoint_Epilogue_Alpha"
        }
      }
    },
    tOnActivate = {
      {
        self.RunLucAndSkylar,
        {self}
      },
      {
        self.SetupStreamTank,
        {self}
      },
      {
        Object.SetInvincible,
        {hSab, true}
      },
      {
        Sound.SetMusicLocale,
        {
          "P1M6_LaVilletteDefend"
        }
      },
      {
        Sound.SetMusicLocale,
        {
          "m_P1M6_LaVilletteDefend",
          "destroyTank"
        }
      },
      {
        EVENT_Timer,
        {
          "Paris_1_Mission_6.Task_CinTank",
          self,
          0.2
        }
      },
      {
        Sound.PlayOwnerlessSoundEvent,
        {
          "defend_slaughterhouse_tank_incoming"
        }
      }
    }
  })
end

function Paris_1_Mission_6:SetupStreamTank()
  EVENT_Stream("Paris_1_Mission_6.TankStreamedIn", self, self.tInfo.FifthWaveNazis, true)
end

function Paris_1_Mission_6:TankStreamedIn()
  self:MoveTank(self.tInfo.SideTankPath1)
  self:MoveTankNazis()
end

function Paris_1_Mission_6:Task_CinTank()
  self:CreateTask({
    sName = "Task_CinTank",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "CIN_P1M6_TankIntro",
    tOnActivate = {
      {
        EVENT_Timer,
        {
          "Paris_1_Mission_6.SetupTankSquad",
          self,
          1
        }
      }
    },
    tOnComplete = {
      {
        Object.SetInvincible,
        {hSab, false}
      }
    }
  })
end

function Paris_1_Mission_6:SetupTankSquad()
  print(" setup tank squad ")
  for i, Nazi in pairs(self.tInfo.FifthWaveNazis) do
    local hNazi = Util.GetHandleByName(Nazi)
    if hNazi and not Object.IsVehicle(hNazi) then
      Squad.AddMember("P1M6_NaziTankSquad", hNazi)
    end
  end
  local hTank = Util.GetHandleByName(self.tInfo.FifthWaveNazis[1])
  local hTankSeat = Vehicle.GetSeatActor(hTank, "PILOT")
  local hTankPilot = Vehicle.GetPilot(hTank)
  Vehicle.SetSuperHeavy(hTank, true)
  if hTankPilot then
    Combat.AddTargetFlag(hTankPilot, cTARGET_NOAUTORESPONSE)
  end
  local eEvent = Util.CreateEvent({
    EventType = "OnWeaponFire",
    Target = hTankPilot
  }, "Paris_1_Mission_6.Splodin", self, {hTankPilot}, true)
  self:RegisterEvent(eEvent)
  if hTankPilot then
    self.tInfo.hTankPilot = hTankPilot
    Squad.AddMember("P1M6_Nazi", hTankPilot)
    Squad.SetLeader("P1M6_Nazi", hTankPilot)
    Squad.SetRadius("P1M6_NaziTankSquad", 10)
    local hTarget = Util.GetHandleByName("Missions\\paris_1\\mission_6\\general\\LOC_Exp_BlowHole")
    Combat.AddTargetFlag(self.tInfo.hTankPilot, cTARGET_ENEMYLIST, {hTarget, 0.1})
    Combat.SetTarget(self.tInfo.hTankPilot, hTarget)
    Combat.SetAlwaysSeeTarget(hTankPilot, true)
    Combat.SetBroadcastWeaponFire(hTankPilot, false)
    Combat.SetStationary(hTankPilot, true)
    self:SkirmishTank("Missions\\paris_1\\mission_6\\sidefight", hTankPilot)
  else
    print("WARNING: tank pilot is nil, probably wont fire weapon!")
  end
end

function Paris_1_Mission_6:MoveTank(sPath)
  local dynomites = Inventory.GetCountOfType(hSab, "WP_SAB_DynamiteFuse")
  if not dynomites or dynomites < 1 then
  else
  end
  local a_hVehicleHandle = Handle("Missions\\paris_1\\mission_6\\nazis\\fifth_wave_tanks\\VEH_FifthWave_Tank_01")
  if a_hVehicleHandle then
    self:DriveToPoint(a_hVehicleHandle, sPath)
  else
    print("no handle for tank")
  end
end

function Paris_1_Mission_6:MoveTankNazis()
  if self:IsMissionTaskComplete("Task_Tank") then
    return
  end
  print("MoveTankNazis")
  local pathleft = "Missions\\paris_1\\mission_6\\general\\PATH_Side_2"
  local pathright = "Missions\\paris_1\\mission_6\\general\\PATH_Side_3"
  for i, Nazi in pairs(self.tInfo.FifthWaveNazis) do
    local hNazi = Handle(Nazi)
    if hNazi and not Object.IsVehicle(hNazi) then
      Combat.SetIdleHoldWeapon(hNazi, true)
      Combat.SetIdleScripted(hNazi, true)
      Actor.SetVehicleAvoidance(hNazi, false)
      if string.find(Nazi, "Lft") then
        print("run tank nazi left ", Nazi)
        Nav.SetScriptedPath(hNazi, pathleft, true)
        Nav.SetScriptedPathMoveMode(hNazi, true)
      else
        print("run tank nazi right ", Nazi)
        Nav.SetScriptedPath(hNazi, pathright, true)
        Nav.SetScriptedPathMoveMode(hNazi, true)
      end
    end
  end
end

function Paris_1_Mission_6:DriveToPoint(a_hVehicleHandle, sPath)
  if Vehicle.IsTrafficEnabled() then
    Vehicle.EnableTraffic(false, true)
  end
  if a_hVehicleHandle then
    if self.tSaveInfo.bBlowHole then
    else
      Cin.PlayConversation("P1M6_DestroyTank")
    end
    if sPath then
      Nav.SetScriptedPath(a_hVehicleHandle, sPath, true, "Paris_1_Mission_6.FireTank", self)
      Nav.SetScriptedPathSpeed(a_hVehicleHandle, 13)
    else
      print("ERROR::Paris_1_Mission_6.DriveToPoint sPath is nil ")
    end
  else
    print("ERROR::Paris_1_Mission_6.DriveToPoint a_hVehicleHandle is nil ")
  end
end

function Paris_1_Mission_6:FireTank()
  local explosions = #self.tInfo.tExplosionLocators - 1
  if not self.tSaveInfo.bZipLine then
    self.tSaveInfo.bZipLine = true
  end
  local explodelocindex = math.random(explosions)
  local hTank = Util.GetHandleByName(self.tInfo.FifthWaveNazis[1])
  if self.tSaveInfo.bBlowHole then
    explodelocindex = #self.tInfo.tExplosionLocators
  end
  if not self.tSaveInfo.bSetupSecondMove then
    self.tSaveInfo.bSetupSecondMove = true
    EVENT_Timer("Paris_1_Mission_6.MoveTankToSecondPosition", self, 35)
  end
  if hTank and self.tInfo.hTankPilot and Object.GetHealth(hTank) > 0 then
    Vehicle.BrakeTo(hTank, 0)
    EVENT_Timer("Paris_1_Mission_6.RELEASEVEHICLE", self, 8, {hTank})
    local hLoc = Util.GetHandleByName(self.tInfo.tExplosionLocators[explodelocindex])
    Combat.SetAlwaysSeeTarget(self.tInfo.hTankPilot, true)
    Combat.AddTargetFlag(self.tInfo.hTankPilot, cTARGET_ENEMYLIST, {hLoc, 0.1})
    Combat.SetTarget(self.tInfo.hTankPilot, hLoc)
    Combat.SetCombat(self.tInfo.hTankPilot)
    EVENT_Timer("Paris_1_Mission_6.FireTank", self, 6)
  end
end

function Paris_1_Mission_6:BlindTank(hTankPilot)
  if hTankPilot then
    Combat.SetAlwaysSeeTarget(hTankPilot, false)
  end
end

function Paris_1_Mission_6:MoveTankToSecondPosition()
  self.tSaveInfo.bBlowHole = true
  if self:IsMissionTaskActive("Task_Tank") then
    Cin.PlayConversation("P1M6_DestroyTankFaster")
    self:MoveTank(self.tInfo.SideTankPath2)
  end
end

function Paris_1_Mission_6:Splodin(tArgs, hTankPilot)
  if hTankPilot then
    Combat.SetAlwaysSeeTarget(hTankPilot, false)
  else
    return
  end
  local Damager = self.tInfo.TankDamage
  if self.tSaveInfo.bBlowHole then
    Damager = Damager * 1.5
  end
  EVENT_Timer("Paris_1_Mission_6.DamageHQ", self, 1, Damager)
  if not self.tSaveInfo.bDoThisOnce and self.tSaveInfo.bBlowHole then
    self.tSaveInfo.bDoThisOnce = true
    self:BlowHole("PARIS\\area01\\lavillette\\buildings\\MN_LaVillette_Abattoir\\MN_LaVillette_Broken2_BaseX4Y4", "MN_LaVillette_Broken2_BaseX4Y4")
  end
end

function Paris_1_Mission_6:WarningZone()
  self:CreateTask({
    sName = "WarningZone",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Goto",
    bNegate = true,
    tDestRegion = {
      "Missions\\paris_1\\mission_6\\general\\REG_Villette"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        self.CheckForGetBackInsideZone,
        {self}
      }
    },
    tOnComplete = {
      {
        self.GetBackInsideZone,
        {self}
      }
    }
  })
end

function Paris_1_Mission_6:CheckForGetBackInsideZone()
  local oTask = self:GetMissionTask("GetBackInsideZone")
  if oTask then
    print("get back inside zone exists , resetting")
    self:ResetTaskByName("GetBackInsideZone", true)
  end
end

function Paris_1_Mission_6:GetBackInsideZone()
  self:CreateTask({
    sName = "GetBackInsideZone",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Goto",
    bOptional = true,
    tDestRegion = {
      "Missions\\paris_1\\mission_6\\general\\REG_SafetyZone"
    },
    tLocators = {
      gsP1M6Dir .. "general\\LOC_CenterSlaugherHouse"
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.SetAutoDamager,
        {self, false}
      },
      {
        self.ResetTaskByName,
        {
          self,
          "WarningZone"
        }
      }
    },
    tOnActivate = {
      {
        self.SetAutoDamager,
        {
          self,
          true,
          true
        }
      }
    },
    tOnReset = {
      {
        self.SetAutoDamager,
        {self, false}
      }
    },
    tOnCancel = {
      {
        self.SetAutoDamager,
        {self, false}
      }
    }
  })
end

function Paris_1_Mission_6:SetAutoDamager(bOn, bSmallDamage)
  self.tSaveInfo.bAutoDamager = bOn or false
  EVENT_Timer("Paris_1_Mission_6.UpdateAutoDamager", self, 2, {bSmallDamage})
end

function Paris_1_Mission_6:UpdateAutoDamager(bSmallDamage)
  if not self.tSaveInfo.bAutoDamager then
    return
  end
  local bSD = bSmallDamage or false
  if bSD then
    self:DamageHQ(0.75)
  else
    self:DamageHQ(self.tInfo.EngineerDamage / 4)
  end
  EVENT_Timer("Paris_1_Mission_6.UpdateAutoDamager", self, 1, bSD)
end

function Paris_1_Mission_6:TASK_TooFarAway()
  self:CreateTask({
    sName = "TASK_TooFarAway",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Goto",
    bNegate = true,
    tDestRegion = {
      "Missions\\paris_1\\mission_6\\general\\REG_FailZone"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.MissionTaskFail,
        {
          self,
          "P1M6_Text.ProtectHQFailure"
        }
      }
    }
  })
end

function Paris_1_Mission_6:BuildingEngineerPiecesDE()
  if self.tSaveInfo.bSetPieceDamageEvents then
    print("Damgage pieces events already setup")
    return
  end
  local tPiece = {
    "PARIS\\area01\\lavillette\\buildings\\MN_LaVillette_Abattoir\\MN_LaVillette_CNRF01A_Broken(1)",
    "PARIS\\area01\\lavillette\\buildings\\MN_LaVillette_Abattoir\\MN_LaVillette_CNRF01B_broken(1)",
    "PARIS\\area01\\lavillette\\buildings\\MN_LaVillette_Abattoir\\MN_LaVillette_CNRF01A_Broken",
    "PARIS\\area01\\lavillette\\buildings\\MN_LaVillette_Abattoir\\MN_LaVillette_CNRF01B_broken"
  }
  self.tSaveInfo.bSetPieceDamageEvents = true
  for i, tSabotagePt in pairs(self.tSaveInfo.BombPoints) do
    AttractionPt.EnableUse(Handle(tSabotagePt.sBomb), false)
    EVENT_ActorDeath("Paris_1_Mission_6.CallbackEngineerPieceDead", self, tSabotagePt.Piece, {
      tSabotagePt.Piece
    })
  end
end

function Paris_1_Mission_6:CallbackEngineerPieceDead(Piece)
  for i, tSabotagePt in pairs(self.tSaveInfo.BombPoints) do
    if tSabotagePt.Piece == Piece and tSabotagePt.STATE ~= self.tInfo.BOOM and self.tSaveInfo.BombSide < self.tInfo.SIDE then
      self:SetBombPtState(tSabotagePt.sBomb, self.tInfo.BOOM)
      self.tSaveInfo.Detonations = self.tSaveInfo.Detonations + 1
    end
  end
  Cin.PlayConversation("P1M6_GetDemoNaziFaster")
  self:DamageHQ(self.tInfo.EngineerDamage)
end

function Paris_1_Mission_6:GotoBombLoc(hEngineer)
  local hLoc = self:GetAvailableBombPt(hEngineer)
  if hEngineer and not Object.IsAlive(hEngineer) then
    return
  end
  if hLoc == -1 then
    EVENT_Timer("Paris_1_Mission_6.GotoBombLoc", self, 6, hEngineer)
    return
  elseif hLoc == 0 then
    self:SetEngineerFree(hEngineer)
    EVENT_Timer("Paris_1_Mission_6.KillCurrentSideSpawner", self, 15)
    return
  end
  self:SetBombPtState(hLoc, self.tInfo.ATTEMPTING)
  self:SetupEngineerEvents(hEngineer, hLoc)
  Actor.SetVehicleAvoidance(hEngineer, false)
  if hEngineer and 0 < Object.GetHealth(hEngineer) then
    EVENT_Timer("Paris_1_Mission_6.RunToBombPt", self, 0.75, {hEngineer, hLoc})
  end
end

function Paris_1_Mission_6:RunToBombPt(hEngineer, hLoc)
  print("RunToBombPt::run to point", hEngineer, hLoc)
  if hEngineer and Object.GetHealth(hEngineer) > 0 then
    Combat.SetObjective(hEngineer, hLoc, true, -1, true)
  end
end

function Paris_1_Mission_6:GetAvailableBombPt(hEngineer)
  local BombPt = -1
  local destroyedbombs = 0
  for i, bp in pairs(self.tSaveInfo.BombPoints) do
    if bp.STATE == self.tInfo.LIVE and self.tSaveInfo.BombSide == bp.Side and AttractionPt.IsAvailable(Util.GetHandleByName(bp.sBomb)) then
      local tempBomb = Util.GetHandleByName(bp.sBomb)
      if BombPt == -1 then
        BombPt = tempBomb
      elseif tempBomb and BombPt and Object.GetDistance(tempBomb, hEngineer) <= Object.GetDistance(BombPt, hEngineer) then
        BombPt = tempBomb
      end
    end
    if not AttractionPt.IsAvailable(Util.GetHandleByName(bp.sBomb)) then
      print("GetAvailableBombPt:: This attraction point is coming back from code as not available ", bp.sBomb)
      if bp.STATE ~= self.tInfo.LIVE then
        print("GetAvailableBombPt:: This attraction point is not live ", bp.sBomb, " state = ", bp.STATE)
      end
    end
    if bp.STATE == self.tInfo.BOOM and self.tSaveInfo.BombSide == bp.Side then
      destroyedbombs = destroyedbombs + 1
      if destroyedbombs == 2 then
        print("GetAvailableBombPt:: all points on this side are destroyed")
        return 0
      end
    end
  end
  if BombPt == -1 then
    print("GetAvailableBombPt:: didnt find available bomb pt ")
  end
  return BombPt
end

function Paris_1_Mission_6:GetBombPtTable(vBombPt)
  local hBombPt = WRAPPER_CheckForHandle(vBombPt)
  for i, bpt in pairs(self.tSaveInfo.BombPoints) do
    if Util.GetHandleByName(bpt.sBomb) == hBombPt then
      return bpt
    end
  end
end

function Paris_1_Mission_6:SetupEngineerEvents(hEngineer, hBombPt)
  local eEvent
  EVENT_ActorDeath("Paris_1_Mission_6.CallBackEngineerDeath", self, hEngineer, {hEngineer, hBombPt})
  local tSabEvent = {EventType = "OnSabotage", Target = hEngineer}
  self:RegisterEvent(Util.CreateEvent(tSabEvent, "Paris_1_Mission_6.EngineerDynamitePlanted", self, {hEngineer, hBombPt}))
  local tSabEvent = {
    EventType = "OnSabotageLight",
    Target = hEngineer
  }
  self:RegisterEvent(Util.CreateEvent(tSabEvent, "Paris_1_Mission_6.EngineerDynamiteLit", self, {hEngineer, hBombPt}))
end

function Paris_1_Mission_6:EngineerDynamitePlanted(tArgs, hEngineer, hBombPt)
  self.tSaveInfo.PlantAttempts = self.tSaveInfo.PlantAttempts + 1
  if self.tSaveInfo.PlantAttempts == 1 then
    Cin.PlayConversation("P1M6_GetDemoNazi")
  else
    Cin.PlayConversation("P1M6_GetDemoNaziAgain")
  end
end

function Paris_1_Mission_6:EngineerDynamiteLit(tArgs, hEngineer, hBombPt)
  self:SetEngineerFree(hEngineer)
end

function Paris_1_Mission_6:CallBackEngineerDeath(hEngineer, hBombPt)
  local bpt
  if hBombPt then
    bpt = self:GetBombPtTable(hBombPt)
  end
  if bpt and bpt.STATE ~= self.tInfo.BOOM then
    print("---- CallBackEngineerDeath:: Engineer death releasing point back to LIVE ... SUCCESS ", hEngineer)
    self:SetBombPtState(hBombPt, self.tInfo.LIVE)
  end
end

function Paris_1_Mission_6:SetBombSide(SIDE)
  self.tSaveInfo.BombSide = SIDE
end

function Paris_1_Mission_6:CallbackIncrementEngineerDeath(hEngineer, hTerror)
  self.tSaveInfo.DeadEngineers = self.tSaveInfo.DeadEngineers + 1
  if hEngineer and hEngineer ~= -1 then
    self:SetUIBlips(hEngineer, false, true)
  elseif hTerror then
  end
  if self.tSaveInfo.BombSide == self.tInfo.FRONT then
    if hEngineer then
      self.tSaveInfo.FrontEngineersDead = self.tSaveInfo.FrontEngineersDead + 1
    elseif hTerror then
      self.tSaveInfo.FrontTSDead = self.tSaveInfo.FrontTSDead + 1
    end
    if self.tSaveInfo.FrontEngineersDead == 1 then
    end
    if self.tSaveInfo.FrontEngineersDead >= self.tSaveInfo.cFrontEngineersMAX then
      print("front engineers ", self.tSaveInfo.FrontEngineersDead)
      EVENT_Timer("Paris_1_Mission_6.CompleteTaskByName", self, 12, {
        "Task_TruckWave1"
      })
    else
      print("**** dead engineer ", hEngineer, self.tSaveInfo.FrontEngineersDead, " max engin ", self.tSaveInfo.cFrontEngineersMAX)
    end
  else
    if self.tSaveInfo.RearEngineersDead == 1 then
      Cin.PlayConversation("P1M6_GetDemoNazisAgain")
    end
    self.tSaveInfo.RearEngineersDead = self.tSaveInfo.RearEngineersDead + 1
    if self.tSaveInfo.RearEngineersDead >= self.tSaveInfo.cRearEngineersMAX then
      print("rear engineers", self.tSaveInfo.RearEngineersDead)
      EVENT_Timer("Paris_1_Mission_6.CompleteTaskByName", self, 12, {
        "Task_TruckWave2"
      })
    else
      print("**** dead engineer ", self.tSaveInfo.RearEngineersDead, " max engin ", self.tSaveInfo.cRearEngineersMAX)
    end
  end
end

function Paris_1_Mission_6:SetBombPtState(vBombPt, state)
  local hBombPt = WRAPPER_CheckForHandle(vBombPt)
  for i, bp in pairs(self.tSaveInfo.BombPoints) do
    if Util.GetHandleByName(bp.sBomb) == hBombPt then
      bp.STATE = state
    end
  end
end

function Paris_1_Mission_6:SetEngineerFree(hEngineer)
  local hLoc
  if hEngineer and Object.IsAlive(hEngineer) then
    self:SetUIBlips(hEngineer, false, true)
    if self.tSaveInfo.BombSide == self.tInfo.FRONT then
      hLoc = Util.GetHandleByName("Missions\\paris_1\\mission_6\\general\\LOC_EngineerFrontRetreat")
      if hLoc then
        Combat.ClearObjective(hEngineer)
        Combat.SetObjective(hEngineer, hLoc, true, 10, false)
      end
    else
      hLoc = Util.GetHandleByName("Missions\\paris_1\\mission_6\\general\\LOC_EngineerRearRetreat")
      if hLoc then
        Combat.ClearObjective(hEngineer)
        Combat.SetObjective(hEngineer, hLoc, true, 10, false)
      end
    end
  end
end

function Paris_1_Mission_6:BombBoom(hLoc)
  if hLoc then
    local x, y, z = Object.GetPosition(hLoc)
    Util.CreateExplosion("Explosion_Large_Zep", x, y, z)
  end
  if self.tSaveInfo.Detonations == 1 then
  else
    Cin.PlayConversation("P1M6_GetDemoNaziFaster")
  end
  self:DamageHQ(self.tInfo.EngineerDamage)
end

function Paris_1_Mission_6:Task_GotoFrontTurret()
  self:CreateTask({
    sName = "Task_GotoFrontTurret",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "deliver",
    tDestProximityObj = {
      self.tInfo.FrontTurret
    },
    Proximity = 10,
    sObjectiveTextID = "P1M6_Text.DefendFront",
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        EVENT_Timer,
        {
          "Paris_1_Mission_6.Goto_Damager",
          self,
          20,
          {
            "Task_GotoFrontTurret"
          }
        }
      }
    },
    tOnComplete = {
      {
        self.SetAutoDamager,
        {self, false}
      },
      {
        self.TASK_KillFrontEngineers,
        {self}
      },
      {
        self.Task_GetBackToFrontTurret,
        {self}
      },
      {
        self.SetupVehicleSpawn,
        {
          self,
          #self.tInfo.VehicleInfo.FrontSpawner,
          self.tInfo.VehicleInfo.FrontSpawner,
          31,
          1,
          "Task_TruckWave1"
        }
      }
    }
  })
end

function Paris_1_Mission_6:Task_GotoFrontTurretSilent()
  self:CreateTask({
    sName = "Task_GotoFrontTurretSilent",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "deliver",
    tDestProximityObj = {
      self.tInfo.FrontTurret
    },
    Proximity = 10,
    bRepeatable = true,
    bNoRepeatAutoRebuild = true,
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Task_GetBackToFrontTurret,
        {self}
      }
    }
  })
end

function Paris_1_Mission_6:Task_GetBackToFrontTurret()
  self:CreateTask({
    sName = "Task_GetBackToFrontTurret",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "deliver",
    tDestProximityObj = {
      self.tInfo.FrontTurret
    },
    Proximity = 45,
    bNegate = true,
    bRepeatable = true,
    bNoRepeatAutoRebuild = true,
    bNoFocus = true,
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    sTaskEndConv = "P1M6_ProtectFrontReturn",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Task_GotoFrontTurretSilent,
        {self}
      }
    }
  })
end

function Paris_1_Mission_6:Task_GotoRearTurret()
  self:CreateTask({
    sName = "Task_GotoRearTurret",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "deliver",
    sObjectiveTextID = "P1M6_Text.DefendRear",
    tDestProximityObj = {
      self.tInfo.RearTurret
    },
    Proximity = 10,
    sTaskStartConv = "P1M6_ProtectRearEntrance",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.SetupVehicleSpawn,
        {
          self,
          #self.tInfo.VehicleInfo.RearSpawner,
          self.tInfo.VehicleInfo.RearSpawner,
          10,
          1,
          "Task_TruckWave2"
        }
      },
      {
        self.SetAutoDamager,
        {self, false}
      },
      {
        self.TASK_KillRearEngineers,
        {self}
      },
      {
        self.Task_GetBackToRearTurret,
        {self}
      }
    },
    tOnActivate = {
      {
        EVENT_Timer,
        {
          "Paris_1_Mission_6.Goto_Damager",
          self,
          20,
          {
            "Task_GotoRearTurret"
          }
        }
      }
    }
  })
end

function Paris_1_Mission_6:Task_GotoRearTurretSilent()
  self:CreateTask({
    sName = "Task_GotoRearTurretSilent",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "deliver",
    tDestProximityObj = {
      self.tInfo.RearTurret
    },
    Proximity = 10,
    bRepeatable = true,
    bNoRepeatAutoRebuild = true,
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Task_GetBackToRearTurret,
        {self}
      }
    }
  })
end

function Paris_1_Mission_6:Task_GetBackToRearTurret()
  self:CreateTask({
    sName = "Task_GetBackToRearTurret",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "deliver",
    tDestProximityObj = {
      self.tInfo.RearTurret
    },
    Proximity = 45,
    bNegate = true,
    bRepeatable = true,
    bNoRepeatAutoRebuild = true,
    bNoFocus = true,
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    sTaskEndConv = "P1M6_ProtectRearReturn",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Task_GotoRearTurretSilent,
        {self}
      }
    }
  })
end

function Paris_1_Mission_6:Task_GotoTopSide()
  self:CreateTask({
    sName = "Task_GotoTopSide",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "deliver",
    tDestProximityObj = {
      self.tInfo.DefendTopSide
    },
    sTaskStartConv = "P1M6_Luc_Attack_Side_Start",
    Proximity = 7,
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        EVENT_Timer,
        {
          "Paris_1_Mission_6.Goto_Damager",
          self,
          20,
          {
            "Task_GotoTopSide"
          }
        }
      },
      {
        self.SetupSideDefendSpawner,
        {self}
      }
    },
    tOnComplete = {
      {
        self.SetAutoDamager,
        {self, false}
      },
      {
        self.SideDefendEvent,
        {self}
      }
    },
    tOnReset = {}
  })
end

function Paris_1_Mission_6:Goto_Damager(sTask)
  if sTask and not self:IsMissionTaskComplete(sTask) then
    print("Goto_Damager ", sTask)
    self:SetAutoDamager(true, true)
  end
end

function Paris_1_Mission_6:SetupSideDefendSpawner()
  self.tSaveInfo.eSideSafetyEvent = EVENT_Timer("Paris_1_Mission_6.SideDefendEvent", self, 25)
end

function Paris_1_Mission_6:SideDefendEvent()
  if not self.tSaveInfo.bSideEventSet then
    self.tSaveInfo.bSideEventSet = true
    if self.tSaveInfo.eSideSafetyEvent then
      Util.KillEvent(self.tSaveInfo.eSideSafetyEvent)
    end
    print("side spawners ", #self.tInfo.VehicleInfo.SideSpawner)
    self:SetupVehicleSpawn(#self.tInfo.VehicleInfo.SideSpawner, self.tInfo.VehicleInfo.SideSpawner, 15, 0.1, "Wave3")
  end
end

function Paris_1_Mission_6:Task_FetchDynamite()
  self:CreateTask({
    sName = "Task_FetchDynamite",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Fetch",
    tDeliverObjs = {
      "WP_SAB_DynamiteFuse"
    },
    tLocators = {
      "Missions\\paris_1\\mission_6\\general\\LOC_Dynamite"
    },
    bBlueprintFetch = true,
    tOnComplete = {}
  })
end

function Paris_1_Mission_6:Checkpoint_Epilogue_Alpha()
  print("__Checkpoint_Epilogue_Alpha")
  Object.SetInvincible(hSab, true)
  Cin.LoadCinematic("325_CinB_Escape")
  self:UnloadTaskNodes("TASK_LoadResist", true)
  EVENT_Timer("Paris_1_Mission_6.StartEnd", self, 6.5)
  if Vehicle.IsTrafficEnabled() then
    Vehicle.EnableTraffic(false, true)
  end
end

function Paris_1_Mission_6:Checkpoint_Epilogue()
  print("__Checkpoint_Epilogue")
  self:StartEnd()
  if Vehicle.IsTrafficEnabled() then
    Vehicle.EnableTraffic(false, true)
  end
end

function Paris_1_Mission_6:StartEnd()
  Render.FadeScreen(true)
  Object.SetInvincible(hSab, false)
  self:KillYouDamnNazis()
  self:CompleteThisMission()
end

function Paris_1_Mission_6:Task_EndCin()
  self:CreateTask({
    sName = "Task_EndCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "325_CinB_Escape",
    tSMEDNodes = {},
    tCinematicNodes = {
      "325_cinb_escape"
    },
    tOnActivate = {
      {
        self.UnloadTaskNodes,
        {
          self,
          "TASK_LoadResist",
          true
        }
      },
      {
        self.KillYouDamnNazis,
        {self}
      }
    },
    tOnComplete = {
      {
        self.FinishUpMission,
        {self}
      }
    }
  })
end

function Paris_1_Mission_6:FinishUpMission()
  Object.PlayerTeleportToLocator(Handle("Missions\\paris_1\\mission_6\\general\\LOC_EndCinTeleport1"), "Paris_1_Mission_6.PostTele", self)
  self:UnloadTaskNodes("Task_EndCin", true)
end

function Paris_1_Mission_6:PostTele()
  self:CompleteThisMission()
end

function Paris_1_Mission_6:TASK_LoadRearFight()
  self:CreateTask({
    sName = "TASK_LoadRearFight",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "NONE",
    tSMEDNodes = {
      "Missions\\paris_1\\mission_6\\rearfight"
    },
    tOnActivate = {
      {
        self.Skirmish,
        {
          self,
          "Missions\\paris_1\\mission_6\\rearfight"
        }
      }
    }
  })
end

function Paris_1_Mission_6:TASK_LoadSideFight()
  self:CreateTask({
    sName = "TASK_LoadSideFight",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "NONE",
    tSMEDNodes = {
      "Missions\\paris_1\\mission_6\\sidefight"
    },
    tOnActivate = {
      {
        self.Skirmish,
        {
          self,
          "Missions\\paris_1\\mission_6\\sidefight"
        }
      }
    }
  })
end

function Paris_1_Mission_6:TASK_LoadSideFight_NoCam()
  self:CreateTask({
    sName = "TASK_LoadSideFight",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "NONE",
    tSMEDNodes = {
      "Missions\\paris_1\\mission_6\\sidefight"
    },
    tOnActivate = {
      {
        self.Skirmish,
        {
          self,
          "Missions\\paris_1\\mission_6\\sidefight"
        }
      }
    }
  })
end

function Paris_1_Mission_6:Skirmish(sNode)
  local tNazis = {}
  local tResist = {}
  local tNodeContents = {}
  tNodeContents = Util.GetEditNodeContents(sNode)
  if tNodeContents then
    for i, hThing in pairs(tNodeContents) do
      if Object.IsHuman(hThing) then
        Combat.AddTargetFlag(hThing, cTARGET_ALLENEMIES)
        Combat.SetSquadAssist(hThing, true)
        EVENT_Stream("Paris_1_Mission_6.SetGodMode", self, {hThing}, true, {hThing})
        EVENT_Timer("Paris_1_Mission_6.ReleaseStagedFighter", self, 30, {hThing})
        Combat.SetLethalForce(hThing, true)
        Combat.SetStationary(hThing, true)
      end
    end
  end
end

function Paris_1_Mission_6:StartCam(sCin, sCallbackFunction)
  Cin.AllowAttackingDuringCinematics(true)
  Cin.PlayCinematic(sCin)
end

function Paris_1_Mission_6:SetGodMode(hDude)
  if hDude and type(hDude) == "userdata" then
    Object.SetInvincibleToAI(hDude, true)
  end
end

function Paris_1_Mission_6:SkirmishTank(sNode, hTankPilot)
  local tNazis = {}
  local tResist = {}
  local tNodeContents = {}
  tNodeContents = Util.GetEditNodeContents(sNode)
  if tNodeContents then
    for i, hThing in pairs(tNodeContents) do
      if Object.IsHuman(hThing) and Actor.HasLabel(hThing, "Resistence") then
        Combat.AddTargetFlag(hThing, cTARGET_ENEMYLIST, {
          {hTankPilot, 10}
        })
        Combat.SetLethalForce(hThing, true)
        Combat.SetStationary(hThing, true)
      end
    end
  end
end

function Paris_1_Mission_6:ReleaseStagedFighter(hFighter)
  if hFighter then
    Combat.SetAlwaysSeeTarget(hFighter, false)
    Object.SetInvincibleToAI(hFighter, false)
  end
end
