if RewardsManager == nil then
  RewardsManager = {}
  RewardsManager.MasterList = {}
  _gNUMA1MISSIONS = 8
  _gNUMA2MISSIONS = 15
  _gNUMA3MISSIONS = 25
  _gNUMA4MISSIONS = 3
  _gNUMTOTALMISSIONS = _gNUMA1MISSIONS + _gNUMA2MISSIONS + _gNUMA3MISSIONS + _gNUMA4MISSIONS
  RewardsManager.RWDList = {}
  RewardsManager.AmbList = {}
  RewardsManager.Debug_Index = 0
  RewardsManager.Debug_UnlockTree = {}
  RewardsManager.HQPoints = {}
  RewardsManager.Debug_ColbyTree = {}
  RewardsManager.Debug_StarterTree = {}
  if SabTask._tMiscSaveTable then
    SabTask._tMiscSaveTable._HQSetsMissionCompletes = {}
  end
  _cHQe_BRIDGE = "Missions\\global_hqpoints\\act1\\countryside\\HQ_Bridge"
  _cHQe_FARM = "Missions\\global_hqpoints\\act1\\countryside\\HQ_Farm"
  _cHQe_ESCAPE = "Missions\\global_hqpoints\\act1\\germany\\HQ_Escape"
  _cHQe_FACTORY = "Missions\\global_hqpoints\\act1\\germany\\HQ_Factory"
  _cHQe_RACETRACK = "Missions\\global_hqpoints\\act1\\germany\\HQ_RaceTrack"
  _cHQe_RACETRACKPIT = "Missions\\global_hqpoints\\act1\\germany\\HQ_RacePit"
  _cHQe_SAARHOTEL = "Missions\\global_hqpoints\\act1\\germany\\HQSaarHQ"
  _cHQe_REDOX = "Missions\\global_hqpoints\\act1\\germany\\HQ_RedOx"
  _cHQ_CHURCH = "Missions\\global_hqpoints\\lehavre\\church\\HQLOC"
  _cHQe_CHURCH_BLIP = "Missions\\global_hqpoints\\lehavre\\church\\HQLOC_BLIPONLY"
  _cHQe_CHURCH = "Missions\\global_hqpoints\\lehavre\\hotel\\LOC_LHT_HQ_Ext"
  _cHQ_BELLE = "Missions\\global_hqpoints\\p1\\belle\\Locator"
  _cHQ_BELLEP3M1 = "Missions\\global_hqpoints\\p1\\belle\\HQP3M1Start"
  _cHQe_BELLE_BLIP = "Missions\\global_hqpoints\\p1\\belle\\BelleHQ_BLIPONLY"
  _cHQ_LAVILLETTE = "Missions\\global_hqpoints\\p1\\lavillette\\HQLOC"
  _cHQe_LAVILLETTE_BLIP = "Missions\\global_hqpoints\\p1\\lavillette\\HQLOC_BLIPONLY"
  _cHQe_LAVILLETTE = "Missions\\global_hqpoints\\p1\\lavillette\\HQLOCext"
  _cHQ_BOLOUGNE = "Missions\\global_hqpoints\\p2\\bolougne\\boisdeboulogneHQ"
  _cHQe_BOLOUGNE_BLIP = "Missions\\global_hqpoints\\p2\\bolougne\\boisdeboulogneHQ_BLIPONLY"
  _cHQe_HDV = "Missions\\global_hqpoints\\p2\\hdv\\HQ_P2M5b"
  _cHQ_CATACOMBS = "Missions\\global_hqpoints\\p3\\catacombs\\HQLOC"
  _cHQe_CATACOMBS = "Missions\\global_hqpoints\\p3\\catacombs\\HQLOC_ext"
  _cHQe_CATACOMBS_BLIP = "Missions\\global_hqpoints\\p3\\catacombs\\HQLOC_BLIPONLY"
  _cHQe_P6M1b = "Missions\\global_hqpoints\\p3\\p6m1bConnect\\HQ_P6M1b"
  _cHQe_POSTTRAIN = "Missions\\global_hqpoints\\countryside\\HQ_PostTrainConnect"
  _cHQe_AIRSTRIP = "Missions\\global_hqpoints\\act4\\paris\\HQ_KillDierker"
  _cHQe_BELLERETURN = "Missions\\global_hqpoints\\p3\\returntobelle\\HQ_BelleReturn"
  _cHQe_SARRETURN = "Missions\\global_hqpoints\\act4\\germany\\HQ_SarReturn"
  _cHQe_AURORA = "Missions\\global_hqpoints\\countryside\\HQ_S1M7b"
  RewardsManager.nPR_Reward = 0
  RewardsManager.nCB_Reward = 0
  RewardsManager.nOS_Reward = 0
  RewardsManager.nCF_Reward = 0
end

function RewardsManager.InitList()
  Util.SetNumMissions(_gNUMTOTALMISSIONS)
  RewardsManager.HQPoints = {
    [_cHQe_FARM] = {Unlocked = false},
    [_cHQe_BRIDGE] = {Unlocked = false},
    [_cHQe_ESCAPE] = {Unlocked = false},
    [_cHQe_FACTORY] = {Unlocked = false},
    [_cHQe_RACETRACK] = {Unlocked = false},
    [_cHQe_RACETRACKPIT] = {Unlocked = false},
    [_cHQe_REDOX] = {Unlocked = false},
    [_cHQe_SAARHOTEL] = {Unlocked = false},
    [_cHQ_CHURCH] = {Unlocked = false, HQBlip = _cHQe_CHURCH_BLIP},
    [_cHQe_CHURCH_BLIP] = {Unlocked = false},
    [_cHQe_CHURCH] = {Unlocked = false},
    [_cHQ_BELLE] = {Unlocked = false, HQBlip = _cHQe_BELLE_BLIP},
    [_cHQe_BELLE_BLIP] = {Unlocked = false},
    [_cHQ_LAVILLETTE] = {Unlocked = false, HQBlip = _cHQe_LAVILLETTE_BLIP},
    [_cHQe_LAVILLETTE_BLIP] = {Unlocked = false},
    [_cHQe_LAVILLETTE] = {Unlocked = false},
    [_cHQ_BOLOUGNE] = {Unlocked = false, HQBlip = _cHQe_BOLOUGNE_BLIP},
    [_cHQe_BOLOUGNE_BLIP] = {Unlocked = false},
    [_cHQe_HDV] = {Unlocked = false},
    [_cHQ_CATACOMBS] = {Unlocked = false, HQBlip = _cHQe_CATACOMBS_BLIP},
    [_cHQe_CATACOMBS_BLIP] = {Unlocked = false},
    [_cHQe_CATACOMBS] = {Unlocked = false},
    [_cHQe_POSTTRAIN] = {Unlocked = false},
    [_cHQe_AIRSTRIP] = {Unlocked = false},
    [_cHQe_SARRETURN] = {Unlocked = false},
    [_cHQe_P6M1b] = {Unlocked = false},
    [_cHQe_AURORA] = {Unlocked = false},
    [_cHQe_BELLERETURN] = {Unlocked = false},
    [_cHQ_BELLEP3M1] = {Unlocked = false}
  }
  RewardsManager.AmbList = {
    Amb_Reward01 = {
      "RndContraband_NZ_Dollar"
    },
    Amb_Reward02 = {
      "RndContraband_NZ_HalfDollar",
      "RndContraband_NZ_Quarter"
    },
    Amb_Reward03 = {
      "RndContraband_NZ_Quarter"
    },
    FreeplayMission_Reward01 = {
      "RndContraband_NZ_Dollar"
    },
    FreeplayMission_WTFReward01 = {
      "RndContraband_NZ_Dollar"
    },
    FreeplayMission_Reward_Mini = {
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar"
    },
    FreeplayMission_Reward_Small = {
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar"
    },
    FreeplayMission_Reward_Mid = {
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar"
    },
    FreeplayMission_Reward_Large = {
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar"
    },
    FreeplayMission_Reward_Huge = {
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_HalfDollar"
    },
    FreeplayMission_Reward_Giant = {
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar",
      "RndContraband_NZ_Dollar"
    },
    AAGun = {60},
    Armored = {60},
    ChemicalTank = {50},
    CoastalGun = {60},
    Converter = {50},
    Dierker = {100},
    FuelStation = {50},
    General = {30},
    PostCard = {30},
    PropSpeaker = {20},
    Radar = {50},
    RadioControl = {50},
    RadioTower = {50},
    Rocket = {60},
    Searchlight = {50},
    SniperNest = {50},
    SupplyDrop = {0},
    SweetJump = {40},
    TopSpot = {50},
    Tower = {50},
    Zeppelin = {50},
    BridgeKiller = {500}
  }
  RewardsManager.RWDList = {
    PRE_Paris_1_Mission_1 = {
      HQUnlock = {_cHQ_BELLE},
      Label = {"ACT_1"},
      Functions = {
        {
          Util.SetPlayerCurrentAct,
          {1}
        },
        {
          RewardsManager.SetMAXEscalation,
          {4}
        },
        {
          RewardsManager.GlobalEnableHighWTFCivMelee,
          {true}
        },
        {
          RewardsManager.DisableDisguising,
          {true}
        },
        {
          RewardsManager.DisableStealthKill,
          {true}
        },
        {
          RewardsManager.IncreaseWallet,
          {9999}
        },
        {
          RewardsManager.LoadColby,
          {
            "HQ_CComb_Ext_Pre",
            true
          }
        },
        {
          RewardsManager.SetEnablePerkFriendlyFire,
          {false}
        },
        {
          RewardsManager.SetEnablePerkNotoriousTitle,
          {false}
        },
        {
          RewardsManager.SetEnablePerkDoubleAgentTitle,
          {false}
        },
        {
          RewardsManager.EnableEspritDeCorps,
          {false}
        },
        {
          RewardsManager.EnableHidePts,
          {false}
        },
        {
          RewardsManager.EnableResistanceEscalation,
          {false}
        },
        {
          RewardsManager.SetupLoadTips,
          {0}
        },
        {
          RewardsManager.SetGlobalAllowCombatHijacking,
          {false}
        },
        {
          RewardsManager.LoadColby,
          {"Burnt_Farm"}
        }
      }
    },
    Paris_1_Mission_1 = {
      Label = {
        "WP_SAB_DynamiteFuse"
      },
      HQLock = {_cHQ_BELLE},
      HQUnlock = {_cHQe_FARM},
      Functions = {
        {
          RewardsManager.WeaponUnlock,
          {
            "WP_SAB_DynamiteFuse"
          }
        },
        {
          RewardsManager.SetLastMissionChatter,
          {
            "cht_Pro_CivGE4a"
          }
        },
        {
          RewardsManager.RemoveAllWeapons,
          {}
        },
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        },
        {
          Sound.DisableLoudSpeakers,
          {}
        },
        {
          RewardsManager.SetGlobalAllowCombatHijacking,
          {true}
        },
        {
          RewardsManager.UnloadColby,
          {"Burnt_Farm", true}
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      WTFZone = {
        "WtF_Zones\\global\\P1M1_FuelDepot"
      }
    },
    PRE_Act_1_ToGermany = {
      Label = {
        "ACT_1",
        "CRATES_EX_EMPTY",
        "CRATES_AM_EMPTY",
        "CRATES_WP_EMPTY",
        "DISABLE_Wep_GR"
      },
      HQLock = {},
      RemoveLabel = {
        "WP_SAB_DynamiteFuse"
      },
      HQUnlock = {_cHQe_FARM},
      Functions = {
        {
          RewardsManager.SetMAXEscalation,
          {4}
        },
        {
          RewardsManager.EnableEscalationVehicles,
          {false}
        },
        {
          RewardsManager.GlobalEnableHighWTFCivMelee,
          {false}
        },
        {
          RewardsManager.SetEscalationBPSet,
          {
            "EscalationSaar"
          }
        }
      }
    },
    Act_1_ToGermany = {
      HQLock = {_cHQe_FARM},
      HQUnlock = {_cHQe_RACETRACK, _cHQe_REDOX},
      Functions = {
        {
          RewardsManager.AchievementGrant,
          {"ROADTRIP"}
        },
        {
          Util.HQSetAllowedOverride,
          {_cHQe_REDOX, true}
        },
        {
          RewardsManager.LoadColby,
          {
            "Act1_OutOfBounds",
            true
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "Paris_1_Mission_1"
      }
    },
    Act_1_BarFight = {
      HQLock = {_cHQe_RACETRACK},
      Functions = {
        {
          RewardsManager.AchievementGrant,
          {"BAR_FIGHT"}
        },
        {
          RewardsManager.EnableEscalationVehicles,
          {true}
        },
        {
          Util.HQSetAllowedOverride,
          {_cHQe_REDOX, false}
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "Act_1_ToGermany"
      }
    },
    Act_1_Mission_2B = {
      HQUnlock = {_cHQe_SAARHOTEL},
      HQLock = {_cHQe_REDOX},
      Functions = {
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      Label = {},
      UnlockedBy = {
        "Act_1_BarFight"
      }
    },
    Connect_ST_109_SkylarSex = {
      Functions = {
        {
          RewardsManager.AchievementGrant,
          {"SKYLAR_SEX"}
        }
      },
      Label = {
        "WPOP_RACE_TIME"
      },
      UnlockedBy = {
        "Act_1_Mission_2B"
      }
    },
    Connect_A1_M2c_JulesToTrack = {
      HQUnlock = {_cHQe_RACETRACK},
      HQLock = {_cHQe_SAARHOTEL},
      Functions = {},
      UnlockedBy = {
        "Connect_ST_109_SkylarSex"
      }
    },
    Act_1_Race = {
      HQLock = {_cHQe_RACETRACK},
      HQUnlock = {_cHQe_RACETRACKPIT},
      RemoveLabel = {
        "WPOP_RACE_TIME"
      },
      Functions = {
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "Connect_A1_M2c_JulesToTrack"
      }
    },
    Act_1_GetCaught = {
      HQUnlock = {_cHQe_FACTORY},
      HQLock = {_cHQe_RACETRACKPIT},
      Functions = {
        {
          RewardsManager.AchievementGrant,
          {
            "DIERKER_CRASH"
          }
        },
        {
          RewardsManager.SetEscalationBPSet,
          {}
        },
        {
          RewardsManager.DisableStealthKill,
          {false}
        },
        {
          RewardsManager.SetupLoadTips,
          {0.5}
        },
        {
          RewardsManager.SetupLoadTips,
          {1}
        },
        {
          RewardsManager.SetupLoadTips,
          {1.5}
        },
        {
          RewardsManager.SetupLoadTips,
          {2}
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {"Act_1_Race"}
    },
    PRE_Act_1_Factory = {
      RemoveLabel = {
        "CRATES_EX_EMPTY",
        "CRATES_AM_EMPTY",
        "CRATES_WP_EMPTY",
        "DISABLE_Wep_GR"
      }
    },
    Act_1_Factory = {
      HQUnlock = {_cHQe_ESCAPE},
      HQLock = {_cHQe_FACTORY},
      Functions = {
        {
          RewardsManager.UnloadColby,
          {
            "Act1_OutOfBounds",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Act1_OutOfBoundsParis",
            true
          }
        }
      },
      UnlockedBy = {
        "Act_1_GetCaught"
      }
    },
    Act_1_Factory = {
      HQUnlock = {_cHQe_ESCAPE},
      HQLock = {_cHQe_FACTORY},
      Functions = {
        {
          RewardsManager.UnloadColby,
          {
            "Act1_OutOfBounds",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Act1_OutOfBoundsParis",
            true
          }
        }
      },
      UnlockedBy = {
        "Act_1_GetCaught"
      }
    },
    Act_1_Escape = {
      HQUnlock = {_cHQe_BRIDGE},
      HQLock = {_cHQe_ESCAPE},
      Functions = {
        {
          RewardsManager.AchievementGrant,
          {"ESCAPE"}
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "Act_1_Factory"
      }
    },
    Act_1_Farm = {
      HQLock = {_cHQe_BRIDGE},
      HQUnlock = {_cHQ_BELLE},
      RemoveLabel = {},
      Functions = {
        {
          Util.SetPlayerCurrentAct,
          {2}
        },
        {
          RewardsManager.SetLastMissionChatter,
          {
            "cht_Pro_CivGE3"
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "Act1_OutOfBoundsParis",
            true
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      WTFZone = {
        "WtF_Zones\\global\\A1M5_TheFarm",
        "WtF_Zones\\global\\A1M4_Champange_Ardeness"
      },
      WTFHighZone = {
        "WtF_Zones\\global\\A1M4_Champange_Ardeness"
      },
      UnlockedBy = {
        "Act_1_Escape"
      }
    },
    Connect_JulesisDeadCin = {
      Functions = {
        {
          RewardsManager.AchievementGrant,
          {
            "REACH_PARIS"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Veronique_Belle_Interior",
            true
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Luc_Belle_Interior_2",
            true
          }
        }
      },
      UnlockedBy = {"Act_1_Farm"}
    },
    Connect_A1_M5b_BellAnd3Months = {
      Label = {
        "WP_SAB_DynamiteFuse",
        "WM_Heavy",
        "ACT_2"
      },
      Functions = {
        {
          RewardsManager.LoadColby,
          {
            "000_German_Border"
          }
        },
        {
          Sound.EnableLoudSpeakers,
          {}
        },
        {
          AmbientRubberStamp.UnlockAmbientAllInZone,
          {
            {
              "SB",
              "LN",
              "PC",
              "NM",
              "CT",
              "BG",
              "CA"
            }
          }
        }
      },
      UnlockedBy = {
        "Connect_JulesisDeadCin"
      }
    },
    PRE_Paris_1_Mission_1B = {
      HQUnlock = {},
      Label = {
        "DisableHQReturn"
      },
      Functions = {
        {
          RewardsManager.SetMAXEscalation,
          {4}
        },
        {
          RewardsManager.GlobalEnableHighWTFCivMelee,
          {true}
        },
        {
          RewardsManager.LoadColby,
          {"Burnt_Farm"}
        },
        {
          RewardsManager.RemoveAllWeapons,
          {}
        },
        {
          RewardsManager.ShowStarter,
          {
            "Veronique_LaVillette_Interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Luc_LaVillette_Interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Santos_LaVillette_Interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Vittore_LaVillette_Interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Father_LaVillette_Interior"
          }
        },
        {
          RewardsManager.EnableHidePts,
          {true}
        }
      }
    },
    Paris_1_Mission_1B = {
      HQUnlock = {_cHQ_LAVILLETTE},
      RemoveLabel = {
        "DisableHQReturn"
      },
      Functions = {
        {
          RewardsManager.ShowStarter,
          {
            "Ludivine_Belle_Interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Luc_Belle_Interior_2"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Veronique_Belle_Interior"
          }
        },
        {
          RewardsManager.DisableDisguising,
          {false}
        },
        {
          RewardsManager.SetLastMissionChatter,
          {
            "cht_Pro_CivGE4b"
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "000_SANTOS_HIDEOUT"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        },
        {
          RewardsManager.ShowStarter,
          {
            "vittore_belle_bar"
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "lavillette_occupation",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {"middle", true}
        },
        {
          RewardsManager.HQMissionCompletes,
          {
            "Paris_1_Mission_1B"
          }
        },
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        }
      },
      WTFZone = {
        "WtF_Zones\\global\\P1M1B_SlaughterhouseLiberate"
      },
      UnlockedBy = {
        "Connect_A1_M5b_BellAnd3Months"
      }
    },
    Paris_1_Mission_1B_Connect = {
      Functions = {
        {
          RewardsManager.ShowStarter,
          {
            "Veronique_LaVillette_Front"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Veronique_LaVillette_Interior"
          }
        }
      },
      UnlockedBy = {
        "Paris_1_Mission_1B"
      }
    },
    PRE_P1FP_RoofFetch01 = {
      Functions = {
        {
          RewardsManager.LoadColby,
          {
            "Perks_Parked_Vehicles_Alpha_Rom12c",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Perks_Parked_Vehicles_Alpha_Romera",
            true
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Vittore_LaVillette_Interior"
          }
        }
      }
    },
    P1FP_RoofFetch01 = {
      Label = {
        "Shop_DynamiteUnlocked"
      },
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "Father_LaVillette_Interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Santos_LaVillette_Interior"
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "000_SHOP_SANTOS",
            true
          }
        },
        {
          Util.UnlockShopLabel,
          {
            "Shop_Santos"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "santos_ext_hideout"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Luc_LaVillette_Wounded"
          }
        },
        {
          RewardsManager.UnloadColby,
          {"middle", true}
        },
        {
          RewardsManager.LoadColby,
          {
            "lavillette_resistance",
            true
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "Paris_1_Mission_1B_Connect"
      }
    },
    PRE_Connect_AmbientFP = {
      Functions = {
        {
          RewardsManager.Debug_AddToMissionCompletedList,
          {
            "P1FP_Traitor"
          }
        }
      }
    },
    Connect_AmbientFP = {
      Label = {"CB_Lvl_1"},
      Functions = {
        {
          Util.UnlockShopLabel,
          {
            "Shop_Santos",
            false
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "000_SHOP_SANTOS",
            true
          }
        },
        {
          Util.UnlockShopLabel,
          {"Shop_Tier1"}
        },
        {
          Util.SetShopDisplayLockedByPerks,
          {true}
        },
        {
          Util.SetShopEnable,
          {true}
        },
        {
          RewardsManager.HideStarter,
          {
            "Veronique_LaVillette_Front"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Veronique_LaVillette_Interior"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "P1FP_RoofFetch01"
      }
    },
    PRE_P1FP_Carbomb = {
      Functions = {
        {
          RewardsManager.Debug_AddToMissionCompletedList,
          {
            "P1FP_Traitor"
          }
        }
      }
    },
    P1FP_Carbomb = {
      ContrabandType = {100},
      Functions = {
        {
          RewardsManager.LoadColby,
          {
            "Perks_Parked_Vehicles_Alpha_Rom12c",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Perks_Parked_Vehicles_Alpha_Romera",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Perks_Parked_Vehicles_Mater_Tipo",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Garagekeeper_Belle",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Garagekeeper_lavillette",
            true
          }
        },
        {
          Util.UnlockShopLabel,
          {
            "Shop_garage"
          }
        },
        {
          Util.SetGarageEnable,
          {true}
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        },
        {
          HUD.AddLoadScreenTutorials,
          {
            {
              "Tutorials_Load_Screen.Strike_Getaway",
              4
            }
          }
        }
      },
      UnlockedBy = {
        "Connect_AmbientFP"
      }
    },
    PRE_NOTE_Santos01 = {
      Functions = {
        {
          RewardsManager.Debug_AddToMissionCompletedList,
          {
            "NOTE_Vittore2Belle"
          }
        }
      }
    },
    NOTE_Santos01 = {
      Functions = {},
      UnlockedBy = {
        "Connect_ST_209_DeliverLucMeds"
      }
    },
    PRE_P1FP_Traitor = {
      Functions = {
        {
          RewardsManager.Debug_AddToMissionCompletedList,
          {
            "Connect_AmbientFP"
          }
        },
        {
          RewardsManager.Debug_AddToMissionCompletedList,
          {
            "P1FP_Carbomb"
          }
        }
      }
    },
    P1FP_Traitor = {
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "vittore_belle_bar"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "vittore_garage"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Father_Belle_Interior"
          }
        },
        {
          RewardsManager.HQMissionCompletes,
          {
            "P1FP_Traitor"
          }
        },
        {
          RewardsManager.DEBUG_UnlockShops,
          {}
        },
        {
          Util.SendPerkMessage,
          {
            "StealthKillGeneral"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "P1FP_RoofFetch01"
      }
    },
    PRE_NOTE_Vittore2Belle = {
      Functions = {
        {
          RewardsManager.Debug_AddToMissionCompletedList,
          {
            "Connect_AmbientFP"
          }
        },
        {
          RewardsManager.Debug_AddToMissionCompletedList,
          {
            "P1FP_Traitor"
          }
        }
      }
    },
    NOTE_Vittore2Belle = {
      UnlockedBy = {
        "P1FP_Traitor"
      }
    },
    NOTE_Jailbreak = {
      UnlockedBy = {
        "NOTE_Vittore2Belle"
      }
    },
    PRE_P1FP_Jailbreak = {
      Label = {"SS_Sniper"},
      Functions = {
        {
          RewardsManager.Debug_AddToMissionCompletedList,
          {
            "P1FP_Carbomb"
          }
        },
        {
          RewardsManager.Debug_AddToMissionCompletedList,
          {
            "P1FP_Traitor"
          }
        },
        {
          RewardsManager.KillNote,
          {
            "NOTE_Jailbreak"
          }
        }
      }
    },
    P1FP_Jailbreak = {
      ContrabandType = {100},
      Functions = {
        {
          RewardsManager.ShowStarter,
          {
            "Couteau_LaVillette_Interior"
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "p1_mis_jailbreak_low",
            false
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Veronique_LaVillette_Interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Veronique_LaVillette_Front"
          }
        },
        {
          RewardsManager.SetLastMissionChatter,
          {
            "cht_Pro_CivGE5b"
          }
        },
        {
          RewardsManager.EnableResistanceEscalation,
          {true}
        },
        {
          HUD.AddLoadScreenTutorials,
          {
            {
              "Tutorials_Load_Screen.Civs_Infamy",
              4
            }
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        },
        {
          RewardsManager.DEBUG_UnlockShops,
          {}
        },
        {
          HUD.AddLoadScreenTutorials,
          {
            {
              "Tutorials_Load_Screen.Strike_Backup",
              4
            }
          }
        }
      },
      Label = {
        "RS_Fighter_Lvl0",
        "CB_Lvl_1"
      },
      UnlockedBy = {
        "P1FP_Traitor"
      }
    },
    Connect_ST_212_ResistanceBackup = {
      Functions = {
        {
          RewardsManager.UnlockStrike,
          {cBACKUP}
        },
        {
          RewardsManager.UnlockGenerals,
          {}
        },
        {
          Util.UnlockShopLabel,
          {
            "Shop_Resistance"
          }
        },
        {
          RewardsManager.SetEnablePerkFriendlyFire,
          {true}
        },
        {
          RewardsManager.SetEnablePerkNotoriousTitle,
          {true}
        },
        {
          RewardsManager.SetEnablePerkDoubleAgentTitle,
          {true}
        },
        {
          Util.CreateEvent,
          {
            {EventType = "TimerEvent", Time = 20},
            "RewardsManager.QueueShopTutorial_resistance",
            self
          }
        }
      },
      UnlockedBy = {
        "P1FP_Jailbreak"
      }
    },
    NOTE_Generals = {
      Functions = {},
      UnlockedBy = {
        "Connect_ST_212_ResistanceBackup"
      }
    },
    P1FP_Entourage = {
      ContrabandType = {100},
      Functions = {
        {
          RewardsManager.ShowStarter,
          {
            "Crochet_ext_whouse"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Couteau_LaVillette_Interior"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "Connect_ST_212_ResistanceBackup"
      }
    },
    P2FP_MadeleineSniper = {
      ContrabandType = {200},
      UnlockedBy = {
        "P1FP_Entourage"
      }
    },
    NOTE_Pre_Palais = {
      ContrabandType = {},
      UnlockedBy = {
        "P2FP_MadeleineSniper"
      }
    },
    PRE_P1FP_PalaisBombe = {
      Functions = {
        {
          RewardsManager.ClearGlobalAMBReward,
          {}
        },
        {
          RewardsManager.KillNote,
          {
            "NOTE_Pre_Palais"
          }
        }
      }
    },
    P1FP_PalaisBombe = {
      ContrabandType = {300},
      UnlockedBy = {
        "NOTE_Pre_Palais"
      },
      Functions = {
        {
          RewardsManager.GiveDelayAMBReward,
          {"PR"}
        },
        {
          RewardsManager.ClearGlobalAMBReward,
          {}
        },
        {
          RewardsManager.CheckForLiberateFranceAchievement,
          {}
        },
        {
          RewardsManager.CheckForP1WTFAchievement,
          {}
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      }
    },
    NOTE_AMB_Finish = {
      UnlockedBy = {
        "P1FP_PalaisBombe"
      },
      Functions = {}
    },
    P1FP_EustacheSniper = {
      ContrabandType = {100},
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "Father_Belle_Interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Father_Sacre_Interior"
          }
        },
        {
          RewardsManager.KillNote,
          {
            "NOTE_FatherDenis"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "Connect_ST_212_ResistanceBackup"
      }
    },
    PRE_P4FP_MadBomber02 = {
      Functions = {}
    },
    P4FP_MadBomber02 = {
      ContrabandType = {200},
      Functions = {
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "P1FP_EustacheSniper"
      }
    },
    NOTE_NaziWedding = {
      Functions = {},
      UnlockedBy = {
        "P4FP_MadBomber02"
      }
    },
    PRE_P1FP_NaziParty = {
      Functions = {
        {
          RewardsManager.KillNote,
          {
            "NOTE_NaziWedding"
          }
        }
      }
    },
    P1FP_NaziParty = {
      ContrabandType = {300},
      UnlockedBy = {
        "NOTE_NaziWedding"
      },
      Functions = {
        {
          RewardsManager.RecordMissionComplete,
          {}
        },
        {
          RewardsManager.HideStarter,
          {
            "Father_Sacre_Interior"
          }
        },
        {
          RewardsManager.CheckForP1WTFAchievement,
          {}
        },
        {
          RewardsManager.CheckForLiberateFranceAchievement,
          {}
        },
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        }
      }
    },
    PRE_P1FP_MadBomber01 = {
      Functions = {
        {
          RewardsManager.Debug_AddToMissionCompletedList,
          {
            "NOTE_Vittore2Belle"
          }
        }
      }
    },
    P1FP_MadBomber01 = {
      HQUnlock = {_cHQe_CHURCH},
      Label = {
        "RS_Luc_Hero",
        "CB_Lvl_2"
      },
      ItemType = {},
      ContrabandType = {100},
      Functions = {
        {
          RewardsManager.ShowStarter,
          {
            "vittore_garage"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "skylar_lehavrehotel_interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Skylar_LaVillette_Interior"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        },
        {
          RewardsManager.HideStarter,
          {
            "skylar_lehavre_interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "bishop_lehavre_interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "wilcox_lehavre_interior"
          }
        }
      },
      UnlockedBy = {
        "Connect_ST_212_ResistanceBackup"
      }
    },
    PRE_NOTE_215a = {
      Functions = {}
    },
    NOTE_215a = {
      UnlockedBy = {
        "P1FP_MadBomber01"
      }
    },
    PRE_Connect_ST_215b_SkylarRendevous = {
      Functions = {
        {
          RewardsManager.KillNote,
          {"NOTE_215a"}
        }
      }
    },
    Connect_ST_215b_SkylarRendevous = {
      HQUnlock = {},
      HQLock = {},
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "skylar_lehavrehotel_interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Moreau_Exterior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "wilcox_lehavre_interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "bishop_lehavre_interior"
          }
        },
        {
          Util.UnlockShopLabel,
          {"Shop_Tier1"}
        },
        {
          Util.UnlockShopLabel,
          {"Shop_Tier2"}
        },
        {
          Util.UnlockShopLabel,
          {"Maps_LH"}
        }
      },
      UnlockedBy = {
        "P1FP_MadBomber01"
      }
    },
    Note_P4M1 = {
      UnlockedBy = {
        "Connect_ST_215b_SkylarRendevous"
      }
    },
    PRE_Paris_4_Mission_1 = {
      Label = {"SS_Flame"},
      Functions = {
        {
          RewardsManager.SetMAXEscalation,
          {4}
        },
        {
          RewardsManager.KillNote,
          {"Note_P4M1"}
        }
      }
    },
    Paris_4_Mission_1 = {
      HQLock = {},
      ContrabandType = {200},
      Functions = {
        {
          RewardsManager.RecordMissionComplete,
          {}
        },
        {
          RewardsManager.ShowStarter,
          {
            "SkylarBelle"
          }
        },
        {
          RewardsManager.SetLastMissionChatter,
          {
            "cht_Pro_CivGE5a"
          }
        },
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        },
        {
          RewardsManager.EnableEspritDeCorps,
          {true}
        },
        {
          HUD.AddLoadScreenTutorials,
          {
            {
              "Tutorials_Load_Screen.Escalation_Escape",
              4
            }
          }
        },
        {
          RewardsManager.CheckForP1WTFAchievement,
          {}
        }
      },
      WTFZone = {
        "WtF_Zones\\global\\P4M1_Cemetary"
      },
      UnlockedBy = {
        "Connect_ST_215b_SkylarRendevous"
      }
    },
    PRE_Paris_4_Mission_1B = {
      HQUnLock = {},
      Label = {
        "DisableHQReturn"
      },
      Functions = {
        {
          Util.HQSetAllowedOverride,
          {_cHQ_CHURCH, true}
        }
      }
    },
    Paris_4_Mission_1B = {
      RemoveLabel = {
        "DisableHQReturn"
      },
      Label = {"SS_Heavy"},
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "Moreau_Exterior"
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Garagekeeper_lehavre",
            true
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "skylar_lehavre_interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "bishop_lehavre_interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "SkylarBelle"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "Paris_4_Mission_1"
      }
    },
    SOE_Zeppelin = {
      HQUnlock = {_cHQ_CHURCH},
      HQLock = {_cHQe_CHURCH},
      Label = {},
      ContrabandType = {200},
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "skylar_lehavre_interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "bishop_lehavre_interior"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        },
        {
          RewardsManager.SetMAXEscalation,
          {5}
        },
        {
          RewardsManager.AchievementGrant,
          {"ZEPPELIN"}
        },
        {
          RewardsManager.LoadColby,
          {
            "HDV_Occupation"
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "props_occ_off"
          }
        },
        {
          RewardsManager.SetLastMissionChatter,
          {
            "cht_Pro_CivGE6a"
          }
        },
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        },
        {
          Util.HQSetAllowedOverride,
          {_cHQ_CHURCH, true}
        },
        {
          RewardsManager.LoadColby,
          {
            "morini_hide_point",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "bar_hide_point",
            true
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "morini_hide_point_cover",
            true
          }
        }
      },
      WTFZone = {
        "WtF_Zones\\global\\S1M6_Zeppelin"
      },
      UnlockedBy = {
        "Paris_4_Mission_1B"
      }
    },
    Connect_S1_M6b_LaHavreWrapup = {
      HQLock = {},
      Functions = {
        {
          RewardsManager.ShowStarter,
          {
            "Veronique_LaVillette_Front"
          }
        }
      },
      UnlockedBy = {
        "SOE_Zeppelin"
      }
    },
    NOTE_P_Qualifier = {
      UnlockedBy = {
        "P2FP_RadioRescue"
      }
    },
    PRE_FP_Paris_Qualifier = {
      Functions = {
        {
          RewardsManager.KillNote,
          {
            "NOTE_P_Qualifier"
          }
        }
      }
    },
    FP_Paris_Qualifier = {
      Functions = {
        {
          RewardsManager.ShowStarter,
          {
            "Race1_Starter"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Spore_RS_Renard"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "NOTE_P_Qualifier"
      }
    },
    PRE_P2FP_InfiltrateAbbey = {
      Functions = {
        {
          RewardsManager.ClearGlobalAMBReward,
          {}
        }
      }
    },
    P2FP_InfiltrateAbbey = {
      ContrabandType = {300},
      Functions = {
        {
          RewardsManager.RecordMissionComplete,
          {}
        },
        {
          RewardsManager.GiveDelayAMBReward,
          {"OS"}
        },
        {
          RewardsManager.ClearGlobalAMBReward,
          {}
        }
      },
      WTFZone = {
        "WtF_Zones\\global\\FP_Ossuaire"
      },
      UnlockedBy = {
        "Connect_S1_M6b_LaHavreWrapup"
      }
    },
    PRE_FP_AMB_ChemFactoryStart = {
      Functions = {
        {
          RewardsManager.ClearGlobalAMBReward,
          {}
        }
      }
    },
    FP_AMB_ChemFactoryStart = {
      Functions = {
        {
          RewardsManager.GiveDelayAMBReward,
          {"CF"}
        },
        {
          RewardsManager.ClearGlobalAMBReward,
          {}
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      ContrabandType = {300},
      UnlockedBy = {
        "P2FP_InfiltrateAbbey"
      }
    },
    NOTE_FP_C_Race = {
      UnlockedBy = {
        "Connect_S1_M6b_LaHavreWrapup"
      }
    },
    PRE_FP_CountryRace_1 = {
      Functions = {
        {
          RewardsManager.KillNote,
          {
            "NOTE_FP_C_Race"
          }
        }
      }
    },
    FP_CountryRace_1 = {
      ContrabandType = {200},
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "Race1_Starter"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "FP_Paris_Qualifier"
      }
    },
    PRE_FP_CountryRace_2 = {
      Functions = {}
    },
    FP_CountryRace_2 = {
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "Race2_Starter"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      ContrabandType = {300},
      UnlockedBy = {
        "FP_CountryRace_1"
      }
    },
    PRE_Connect_Cin_301_Act3 = {
      RemoveLabel = {},
      Label = {"ACT_3"},
      Functions = {
        {
          Util.SetPlayerCurrentAct,
          {3}
        }
      }
    },
    Connect_Cin_301_Act3 = {
      UnlockedBy = {
        "Connect_S1_M6b_LaHavreWrapup"
      },
      Functions = {
        {
          RewardsManager.ShowStarter,
          {
            "Veronique_LaVillette_Front",
            true
          }
        }
      }
    },
    PRE_P1FP_DestroyConvoy = {
      Functions = {
        {
          RewardsManager.Debug_AddToMissionCompletedList,
          {
            "Connect_ST_302_ParisReturnVittore"
          }
        }
      }
    },
    Connect_301_Luc_Con = {
      UnlockedBy = {
        "Connect_Cin_301_Act3"
      }
    },
    P1FP_DestroyConvoy = {
      ContrabandType = {200},
      Functions = {
        {
          RewardsManager.SetLastMissionChatter,
          {
            "cht_Pro_CivGE6b"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "Connect_301_Luc_Con"
      }
    },
    Connect_ConvoyPapers = {
      Functions = {},
      UnlockedBy = {
        "P1FP_DestroyConvoy"
      }
    },
    PRE_NOTE_302 = {
      Functions = {}
    },
    NOTE_302 = {
      Functions = {
        {
          RewardsManager.Debug_AddToMissionCompletedList,
          {
            "P2FP_RadioRescue"
          }
        }
      },
      UnlockedBy = {
        "Connect_301_Luc_Con"
      }
    },
    NOTE_P2_Papers = {
      Functions = {},
      UnlockedBy = {
        "Connect_ConvoyPapers"
      }
    },
    PRE_Connect_P2Papers = {
      Functions = {
        {
          RewardsManager.Debug_AddToMissionCompletedList,
          {
            "Connect_ST_302_ParisReturnVittore"
          }
        }
      }
    },
    Connect_P2Papers = {
      Functions = {
        {
          RewardsManager.ShowStarter,
          {
            "Margot_Boulogne_Interior"
          }
        },
        {
          RewardsManager.Debug_AddToMissionCompletedList,
          {
            "Connect_ST_302_ParisReturnVittore"
          }
        },
        {
          Util.UnlockShopLabel,
          {"Shop_Tier1"}
        },
        {
          Util.UnlockShopLabel,
          {"Shop_Tier2"}
        },
        {
          Util.UnlockShopLabel,
          {"Shop_Tier3"}
        },
        {
          Util.UnlockShopLabel,
          {"Maps_Tier2"}
        },
        {
          RewardsManager.LoadColby,
          {
            "Garagekeeper_boisdeboulogne",
            true
          }
        }
      },
      HQUnlock = {_cHQ_BOLOUGNE},
      ItemType = {"Papers_P2"},
      Label = {"Papers_P2"},
      WTFZone = {
        "WtF_Zones\\global\\P2HQ_WTF"
      },
      UnlockedBy = {
        "Connect_ConvoyPapers"
      }
    },
    PRE_Connect_ST_302_ParisReturnVittore = {
      Functions = {
        {
          RewardsManager.KillNote,
          {"NOTE_302"}
        },
        {
          RewardsManager.Debug_AddToMissionCompletedList,
          {
            "P2FP_RadioRescue"
          }
        }
      }
    },
    Connect_ST_302_ParisReturnVittore = {
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "Luc_LaVillette_Interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Luc_Hangman_Exterior"
          }
        }
      },
      UnlockedBy = {"NOTE_302"}
    },
    PRE_P2FP_RadioRescue = {
      Functions = {
        {
          RewardsManager.Debug_AddToMissionCompletedList,
          {
            "Connect_ST_302_ParisReturnVittore"
          }
        }
      }
    },
    P2FP_RadioRescue = {
      ContrabandType = {200},
      Functions = {
        {
          RewardsManager.ShowStarter,
          {
            "Bryman_Boulogne_Exterior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Luc_LaVillette_Interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Luc_Hangman_Exterior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Spore_RS_Renard"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "Connect_P2Papers"
      }
    },
    NOTE_307 = {
      Functions = {},
      UnlockedBy = {
        "P2FP_RadioRescue"
      }
    },
    PRE_Connect_ST_307_ParkHangingBigGun = {
      Functions = {
        {
          RewardsManager.KillNote,
          {"NOTE_307"}
        }
      }
    },
    Connect_ST_307_ParkHangingBigGun = {
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "Luc_Hangman_Exterior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Luc_LaVillette_Interior"
          }
        }
      },
      UnlockedBy = {
        "P2FP_RadioRescue"
      }
    },
    PRE_Paris_5_Mission_3 = {
      Label = {
        "SS_Grenadier"
      },
      Functions = {}
    },
    Paris_5_Mission_3 = {
      Label = {
        "WP_SAB_RDX_Charge"
      },
      ContrabandType = {200},
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "Bryman_Boulogne_Exterior",
            true
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "wilcox_lehavre_interior",
            true
          }
        },
        {
          RewardsManager.WeaponUnlock,
          {
            "WP_SAB_RDX_Charge"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "bishop_st306_ext"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        },
        {
          RewardsManager.SetLastMissionChatter,
          {
            "cht_Pro_CivGE7a"
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "BigGun_BrokenBuilding",
            true
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "P5M3_biggun_unload",
            true
          }
        },
        {
          RewardsManager.CheckForP2WTFAchievement,
          {}
        },
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        }
      },
      WTFZone = {
        "WtF_Zones\\global\\P5M3_BigGun"
      },
      UnlockedBy = {
        "Connect_ST_307_ParkHangingBigGun"
      }
    },
    P1FP_KillCourtyard01 = {
      ContrabandType = {200},
      UnlockedBy = {
        "Paris_5_Mission_3"
      },
      Functions = {
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      }
    },
    P2FP_GrandSniper = {
      ContrabandType = {200},
      Functions = {
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      WTFZone = {},
      UnlockedBy = {
        "P1FP_KillCourtyard01"
      }
    },
    P2FP_RadioSwap = {
      ContrabandType = {300},
      WTFZone = {
        "WtF_Zones\\global\\FP_GrandSnipe",
        "WtF_Zones\\global\\FP_FinalFreeplay"
      },
      Functions = {
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        },
        {
          Util.SendPerkMessage,
          {
            "LouvreLiberated"
          }
        },
        {
          RewardsManager.CheckForP2WTFAchievement,
          {}
        },
        {
          RewardsManager.CheckForLiberateFranceAchievement,
          {}
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "P2FP_GrandSniper"
      }
    },
    NOTE_305 = {
      UnlockedBy = {
        "Paris_5_Mission_3"
      }
    },
    PRE_Connect_ST_306_BishopMeeting = {
      Functions = {
        {
          RewardsManager.KillNote,
          {"NOTE_305"}
        }
      }
    },
    Connect_ST_306_BishopMeeting = {
      Functions = {
        {
          RewardsManager.ShowStarter,
          {
            "Spore_RS_Skylar"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "bishop_st306_ext",
            true
          }
        }
      },
      UnlockedBy = {
        "Paris_5_Mission_3"
      }
    },
    NOTE_308a = {
      UnlockedBy = {
        "Connect_ST_306_BishopMeeting"
      }
    },
    PRE_SOE_2_Mission_2 = {
      Functions = {
        {
          RewardsManager.KillNote,
          {"NOTE_308a"}
        }
      }
    },
    SOE_2_Mission_2 = {
      HQUnlock = {_cHQe_POSTTRAIN},
      ContrabandType = {300},
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "Spore_RS_Skylar",
            true
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "wilcox_lehavre_interior"
          }
        },
        {
          RewardsManager.WeaponUnlock,
          {
            "WP_SAB_BridgeKiller"
          }
        },
        {
          RewardsManager.AchievementGrant,
          {"TRAIN"}
        },
        {
          RewardsManager.SetLastMissionChatter,
          {
            "cht_Pro_CivGE7b"
          }
        },
        {
          Util.UnlockShopLabel,
          {
            "WP_SAB_BridgeKiller"
          }
        },
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        },
        {
          Util.SetPlayerLastHQ,
          {_cHQe_POSTTRAIN}
        },
        {
          RewardsManager.UnloadColby,
          {
            "soe2m2trainbridge",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Trainbridge_Destroyed",
            true
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        },
        {
          Util.EnableBridgeKillers,
          {true}
        }
      },
      WTFZone = {
        "WtF_Zones\\global\\S2M2_Train",
        "WtF_Zones\\global\\S2M2_Train_2"
      },
      UnlockedBy = {
        "Connect_ST_306_BishopMeeting"
      }
    },
    PRE_SOE_2_Mission_2_ConnectB = {
      Label = {
        "DisableHQReturn"
      },
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "Veronique_LaVillette_Interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Veronique_LaVillette_Front"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Skylar_LaVillette_Interior"
          }
        }
      }
    },
    SOE_2_Mission_2_ConnectB = {
      RemoveLabel = {
        "DisableHQReturn"
      },
      HQLock = {_cHQe_POSTTRAIN},
      Functions = {
        {
          RewardsManager.ShowStarter,
          {
            "Kessler_LaVillette_Interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Luc_LaVillette_Interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Veronique_LaVillette_Interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Veronique_LaVillette_Front"
          }
        },
        {
          Util.SetPlayerLastHQ,
          {-1}
        }
      },
      UnlockedBy = {
        "SOE_2_Mission_2"
      }
    },
    Connect_ST_P3_Need = {
      Functions = {},
      UnlockedBy = {
        "SOE_2_Mission_2_ConnectB"
      }
    },
    Connect_P3PapersIntro = {
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "Skylar_LaVillette_Interior"
          }
        }
      },
      UnlockedBy = {
        "Connect_ST_P3_Need"
      }
    },
    Connect_ST_316_VeroDistrustsSkylar = {
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "Veronique_LaVillette_Interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Veronique_LaVillette_Front"
          }
        }
      },
      UnlockedBy = {
        "SOE_2_Mission_2_ConnectB"
      }
    },
    Connect_P3Papers = {
      ItemType = {"Papers_P3"},
      Label = {"Papers_P3"},
      Functions = {
        {
          RewardsManager.LoadColby,
          {
            "HQ_CComb_Ext_Open",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "HQ_CComb_Ext_Door",
            true
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "HQ_CComb_Ext_Pre",
            true
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Veronique_LaVillette_Interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Veronique_LaVillette_Front"
          }
        },
        {
          Util.UnlockShopLabel,
          {"Maps_Tier3"}
        }
      },
      WTFHighZone = {
        "WtF_Zones\\global\\P3HQ_WTF"
      },
      WTFZone = {
        "WtF_Zones\\global\\P3HQ_WTF"
      },
      UnlockedBy = {
        "Connect_P3PapersIntro"
      }
    },
    NOTE_FP_CountryChateau = {
      UnlockedBy = {
        "Connect_ST_P3_Need"
      }
    },
    PRE_FP_AMB_ChambordStart = {
      Functions = {
        {
          RewardsManager.ClearGlobalAMBReward,
          {}
        },
        {
          RewardsManager.KillNote,
          {
            "NOTE_FP_CountryChateau"
          }
        }
      }
    },
    FP_AMB_ChambordStart = {
      ContrabandType = {400},
      Functions = {
        {
          RewardsManager.GiveDelayAMBReward,
          {"CB"}
        },
        {
          RewardsManager.ClearGlobalAMBReward,
          {}
        },
        {
          RewardsManager.CheckForLiberateFranceAchievement,
          {}
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "SOE_2_Mission_2_ConnectB"
      }
    },
    P3FP_Jardin = {
      Label = {"CB_Lvl_3"},
      ContrabandType = {300},
      HQUnlock = {_cHQ_CATACOMBS},
      Functions = {
        {
          RewardsManager.ShowStarter,
          {
            "drkwong_cat_int"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Luc_LaVillette_Interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "luc_cat_int"
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Garagekeeper_catacombs",
            true
          }
        },
        {
          Util.UnlockShopLabel,
          {"Shop_Tier1"}
        },
        {
          Util.UnlockShopLabel,
          {"Shop_Tier2"}
        },
        {
          Util.UnlockShopLabel,
          {"Shop_Tier3"}
        },
        {
          Util.UnlockShopLabel,
          {"Shop_Tier4"}
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        },
        {
          RewardsManager.LoadColby,
          {
            "HQ_CComb_Ext_Door",
            true
          }
        }
      },
      UnlockedBy = {
        "Connect_P3Papers"
      }
    },
    Connect_ST_318_RaceComing = {
      Functions = {
        {
          RewardsManager.ShowStarter,
          {
            "duval_cat_int"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Luc_LaVillette_Interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "luc_cat_int"
          }
        }
      },
      UnlockedBy = {
        "P3FP_Jardin"
      }
    },
    P3FP_MadBomber03 = {
      ContrabandType = {300},
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "drkwong_cat_int"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Kwong_Ctown"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "Connect_ST_318_RaceComing"
      }
    },
    PRE_P3FP_FountainSniper = {
      Functions = {}
    },
    P3FP_FountainSniper = {
      ContrabandType = {300},
      Functions = {
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {
        "P3FP_MadBomber03"
      }
    },
    PRE_P3FP_BiggerGun = {
      Functions = {}
    },
    P3FP_BiggerGun = {
      Functions = {
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        },
        {
          Util.SendPerkMessage,
          {
            "PantheonLiberated"
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "p3fp_biggergun_gun_alive",
            true
          }
        },
        {
          RewardsManager.CheckForP3WTFAchievement,
          {}
        },
        {
          RewardsManager.CheckForLiberateFranceAchievement,
          {}
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      ContrabandType = {400},
      UnlockedBy = {
        "P3FP_FountainSniper"
      }
    },
    P3FP_Hit = {
      ContrabandType = {300},
      UnlockedBy = {
        "Connect_ST_318_RaceComing"
      },
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "duval_cat_int"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Duval_ext_ind"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      }
    },
    Note_Mingo1_OkCorral = {
      ContrabandType = {},
      Functions = {},
      UnlockedBy = {"P3FP_Hit"}
    },
    PRE_P3FP_OKCorral = {
      Functions = {
        {
          RewardsManager.KillNote,
          {
            "Note_Mingo1_OkCorral"
          }
        }
      }
    },
    P3FP_OKCorral = {
      ContrabandType = {400},
      Functions = {
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        },
        {
          RewardsManager.CheckForP3WTFAchievement,
          {}
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        },
        {
          RewardsManager.CheckForLiberateFranceAchievement,
          {}
        }
      },
      WTFZone = {
        "WtF_Zones\\global\\FP_OKCoral"
      },
      UnlockedBy = {"P3FP_Hit"}
    },
    SOE_1_Mission_7 = {
      ContrabandType = {300},
      HQLock = {
        _cHQ_BELLE,
        _cHQ_LAVILLETTE,
        _cHQ_BOLOUGNE,
        _cHQ_CATACOMBS,
        _cHQ_CHURCH
      },
      HQUnlock = {_cHQe_AURORA},
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "Bryman_Boulogne_Exterior",
            true
          }
        },
        {
          RewardsManager.AchievementGrant,
          {
            "RECOVER_AURORA"
          }
        },
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      WTFZone = {
        "WtF_Zones\\global\\S1M7_GetAurora"
      },
      UnlockedBy = {
        "P3FP_OKCorral"
      }
    },
    PRE_SOE_1_Mission_7b = {
      Label = {
        "VH_CV_CR_Aurora_01",
        "DisableHQReturn"
      }
    },
    SOE_1_Mission_7b = {
      HQLock = {_cHQe_AURORA},
      HQUnlock = {
        _cHQ_BELLE,
        _cHQ_LAVILLETTE,
        _cHQ_BOLOUGNE,
        _cHQ_CATACOMBS,
        _cHQ_CHURCH
      },
      Functions = {
        {
          RewardsManager.ShowStarter,
          {
            "HDV_Starter"
          }
        },
        {
          Util.UnlockShopLabel,
          {
            "AuroraUnlock"
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Belle_Garage_Phoenix",
            true
          }
        }
      },
      Label = {
        "VH_CV_CR_Aurora_01"
      },
      RemoveLabel = {
        "DisableHQReturn"
      },
      UnlockedBy = {
        "SOE_1_Mission_7"
      }
    },
    Note_Bryman1a_FoundMaria = {
      UnlockedBy = {
        "SOE_1_Mission_7b"
      }
    },
    PRE_Paris_2_Mission_5 = {
      Label = {
        "TS_Commander",
        "TS_Trooper"
      },
      Functions = {
        {
          RewardsManager.KillNote,
          {
            "Note_Bryman1a_FoundMaria"
          }
        }
      }
    },
    Paris_2_Mission_5 = {
      Label = {
        "WP_PS_DierkerGun"
      },
      HQUnlock = {_cHQe_HDV},
      ItemType = {},
      ContrabandType = {300},
      Functions = {
        {
          RewardsManager.WeaponUnlock,
          {
            "WP_PS_DierkerGun"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "HDV_Starter",
            true,
            true
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "HDV_Occupation"
          }
        },
        {
          RewardsManager.SetLastMissionChatter,
          {
            "cht_Pro_CivGE8a"
          }
        },
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        },
        {
          Util.UnlockShopLabel,
          {"Shop_Tier5"}
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        },
        {
          RewardsManager.CheckForP1WTFAchievement,
          {}
        }
      },
      WTFZone = {
        "WtF_Zones\\global\\P2M5_BoilingPoint"
      },
      UnlockedBy = {
        "SOE_1_Mission_7b"
      }
    },
    PRE_P2M5b = {
      Label = {
        "DisableHQReturn"
      }
    },
    P2M5b = {
      RemoveLabel = {
        "DisableHQReturn"
      },
      HQLock = {_cHQe_HDV},
      Functions = {
        {
          RewardsManager.ShowStarter,
          {
            "Maria_LaVillette_Interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Renard_LaVillette_Interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Crochet_ext_whouse"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Skylar_LaVillette_Interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Luc_LaVillette_Interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Kessler_LaVillette_Interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Veronique_LaVillette_Interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Veronique_LaVillette_Front"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Spore_RS_Renard"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "vittore_garage"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "santos_ext_hideout"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Couteau_LaVillette_Interior"
          }
        }
      },
      UnlockedBy = {
        "Paris_2_Mission_5"
      }
    },
    PRE_Paris_1_Mission_6 = {
      Label = {
        "DisableHQReturn"
      },
      Functions = {}
    },
    Paris_1_Mission_6 = {
      RemoveLabel = {
        "DisableHQReturn"
      },
      HQLock = {_cHQ_LAVILLETTE},
      HQUnlock = {_cHQe_LAVILLETTE},
      ContrabandType = {500},
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "Kessler_LaVillette_Interior",
            true
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Maria_LaVillette_Interior",
            true
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Veronique_LaVillette_Interior",
            true
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Skylar_LaVillette_Interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Luc_LaVillette_Interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Kessler_LaVillette_Interior"
          }
        },
        {
          RewardsManager.SetLastMissionChatter,
          {
            "cht_Pro_CivGE8b"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Crochet_ext_whouse"
          }
        },
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        },
        {
          RewardsManager.LoadColby,
          {
            "props_occ_off"
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "PARIS\\area01\\lavillette\\interior\\lavillette_int\\Spore_RS_Shopkeeper_HQ",
            true
          }
        }
      },
      UnlockedBy = {"P2M5b"}
    },
    Connect_ST_325_Escape = {
      UnlockedBy = {
        "Paris_1_Mission_6"
      }
    },
    PRE_P1M6b = {
      Label = {
        "DisableHQReturn"
      }
    },
    P1M6b = {
      RemoveLabel = {
        "DisableHQReturn"
      },
      Functions = {
        {
          RewardsManager.ShowStarter,
          {
            "luc_cat_int"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "skylar_cat_int"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "kessler_cat_int"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "maria_cat_int"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "bryman_cat_int"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Spore_RS_Renard"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "vittore_garage"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "santos_ext_hideout"
          }
        }
      },
      HQLock = {_cHQe_LAVILLETTE},
      UnlockedBy = {
        "Connect_ST_325_Escape"
      }
    },
    NOTE_BrymanRadioSabotage = {
      Functions = {},
      UnlockedBy = {"P1M6b"}
    },
    PRE_P3FP_RadioSabotage = {
      Functions = {
        {
          RewardsManager.KillNote,
          {
            "NOTE_BrymanRadioSabotage"
          }
        }
      }
    },
    P3FP_RadioSabotage = {
      ContrabandType = {500},
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "bryman_cat_int",
            true
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Bryman_Boulogne_Exterior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "santos_ext_hideout"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "skylar_cat_int",
            true
          }
        },
        {
          RewardsManager.ShowStarter,
          {"gaspard"}
        },
        {
          RewardsManager.HideStarter,
          {
            "Bryman_Market_Exterior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "vittore_garage"
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Posters_ParisRace"
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "Belle_Garage_Phoenix"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      UnlockedBy = {"P1M6b"}
    },
    NOTE_P6M1 = {
      Functions = {},
      UnlockedBy = {
        "P3FP_RadioSabotage"
      }
    },
    PRE_Paris_6_Mission_1 = {
      Functions = {
        {
          RewardsManager.KillNote,
          {"NOTE_P6M1"}
        }
      }
    },
    Paris_6_Mission_1 = {
      HQUnlock = {_cHQe_P6M1b},
      ContrabandType = {750},
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "vittore_garage",
            true,
            true
          }
        },
        {
          RewardsManager.HideStarter,
          {"gaspard"}
        },
        {
          RewardsManager.ShowStarter,
          {
            "vittore_cat_int"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Crochet_ext_whouse"
          }
        },
        {
          RewardsManager.AchievementGrant,
          {
            "PRISON_BREAK"
          }
        },
        {
          RewardsManager.SetLastMissionChatter,
          {
            "cht_Pro_CivGE8c"
          }
        },
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      WTFZone = {
        "WtF_Zones\\global\\P6M1_PrisonBreak"
      },
      ItemType = {
        "Papers_Island"
      },
      Label = {
        "Papers_Island"
      },
      UnlockedBy = {
        "P3FP_RadioSabotage"
      }
    },
    PRE_Paris_6_Mission_1_ConnectB = {
      Label = {
        "DisableHQReturn"
      }
    },
    Paris_6_Mission_1_ConnectB = {
      HQLock = {_cHQe_P6M1b},
      Label = {
        "RS_Veronique_Hero"
      },
      RemoveLabel = {
        "DisableHQReturn"
      },
      Functions = {
        {
          RewardsManager.ShowStarter,
          {
            "vittore_cat_int"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "veronique_cat_int"
          }
        },
        {
          RewardsManager.SetLastMissionChatter,
          {
            "cht_Pro_CivGE7c"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Duval_ext_ind"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Kwong_Ctown"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "kessler_cat_int"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "maria_cat_int"
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "Garagekeeper_catacombs",
            true
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\garage\\catacombs_garage\\Spore_RS_Garagekeeper",
            true
          }
        }
      },
      UnlockedBy = {
        "Paris_6_Mission_1"
      }
    },
    PRE_Act_3_Mission_1 = {
      Label = {
        "DisableHQReturn"
      }
    },
    Act_3_Mission_1 = {
      Label = {
        "NZ_Dierker_Burnt"
      },
      RemoveLabel = {
        "DisableHQReturn"
      },
      ContrabandType = {1000},
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "vittore_cat_int",
            true
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "vittore_garage"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "drkwong_cat_int"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "duval_cat_int"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Ludivine_Belle_Interior",
            true
          }
        },
        {
          RewardsManager.AchievementGrant,
          {"RACE_PARIS"}
        },
        {
          RewardsManager.SetLastMissionChatter,
          {
            "cht_Pro_CivGE9a"
          }
        },
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "kessler_cat_int"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "maria_cat_int"
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Perks_Parked_Vehicles_Dierker"
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "Garagekeeper_Belle",
            true
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "PARIS\\area03\\catacombs\\hq\\Spore_RS_Shopkeeper",
            true
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\garage\\catacombs_garage\\Spore_RS_Garagekeeper",
            true
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\garage\\belle_garage\\Spore_RS_Garagekeeper",
            true
          }
        },
        {
          RewardsManager.CheckForP3WTFAchievement,
          {}
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        }
      },
      WTFZone = {
        "WtF_Zones\\global\\A3M1_ParisRace",
        "WtF_Zones\\global\\A3M2_DierkerShowdown"
      },
      WTFHighZone = {
        "WtF_Zones\\global\\A3M1_ParisRace"
      },
      UnlockedBy = {
        "Paris_6_Mission_1_ConnectB"
      }
    },
    Act_3_Mission_1_E3 = {
      Label = {
        "NZ_Dierker_Burnt"
      },
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "vittore_cat_int",
            true
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "vittore_garage"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Ludivine_Belle_Interior",
            true
          }
        },
        {
          RewardsManager.AchievementGrant,
          {"RACE_PARIS"}
        },
        {
          RewardsManager.SetLastMissionChatter,
          {
            "cht_Pro_CivGE9a"
          }
        },
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Duval_ext_ind"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Kwong_Ctown"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "kessler_cat_int"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "maria_cat_int"
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Perks_Parked_Vehicles_Dierker"
          }
        }
      },
      WTFZone = {
        "WtF_Zones\\global\\A3M1_ParisRace",
        "WtF_Zones\\global\\A3M2_DierkerShowdown"
      },
      UnlockedBy = {
        "Paris_6_Mission_1_ConnectB"
      }
    },
    PRE_Connect_A3_M1b_ReturnToBelle = {
      Label = {
        "DisableHQReturn"
      },
      Functions = {}
    },
    Connect_A3_M1b_ReturnToBelle = {
      RemoveLabel = {
        "DisableHQReturn"
      },
      Label = {"ACT_4"},
      HQUnlock = {_cHQ_BELLEP3M1},
      HQLock = {_cHQ_CATACOMBS, _cHQ_BELLE},
      Functions = {
        {
          Util.SetPlayerCurrentAct,
          {4}
        },
        {
          RewardsManager.HideStarter,
          {
            "vittore_garage",
            true
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "kessler_cat_int"
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "HQ_CComb_Ext_Open",
            true
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "HQ_CComb_Ext_Door",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "HQ_CComb_Ext_Closed",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "HQ_CComb_Ext_Pre",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "belle_ext_closed",
            true
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "PristineBelle",
            true
          }
        }
      },
      UnlockedBy = {
        "Act_3_Mission_1"
      }
    },
    PRE_Paris_3_Mission_1 = {
      Label = {
        "DisableHQReturn"
      }
    },
    Paris_3_Mission_1 = {
      RemoveLabel = {
        "DisableHQReturn"
      },
      ContrabandType = {1500},
      HQLock = {_cHQ_BELLEP3M1},
      HQUnlock = {_cHQe_CATACOMBS},
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "luc_cat_int",
            true
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Duval_ext_ind"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Kwong_Ctown"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "skylar_cat_int"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Father_Belle_Interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Father_Sacre_Interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "maria_cat_int"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "bryman_cat_int"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Luc_Belle_Interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Luc_Belle_Interior_2"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Luc_LaVillette_Interior"
          }
        },
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "HQ_CComb_Ext_Open",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "HQ_CComb_Ext_Door",
            true
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "HQ_CComb_Ext_Closed",
            true
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "HQ_CComb_Ext_Pre",
            true
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        },
        {
          RewardsManager.ShowStarter,
          {
            "Race2_Starter"
          }
        }
      },
      WTFZone = {
        "WtF_Zones\\global\\P3M1_Catacombs"
      },
      UnlockedBy = {
        "Connect_A3_M1b_ReturnToBelle"
      }
    },
    PRE_Connect_P3_M1b_KesslerAtDoppelsieg = {
      Label = {
        "DisableHQReturn"
      },
      Functions = {
        {
          RewardsManager.UnloadColby,
          {
            "HQ_CComb_Ext_Door",
            true
          }
        }
      }
    },
    Connect_P3_M1b_KesslerAtDoppelsieg = {
      HQLock = {_cHQe_CATACOMBS},
      RemoveLabel = {
        "DisableHQReturn"
      },
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "wilcox_lehavre_interior",
            true
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Starter_Skylar_Airstrip"
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "HQ_CComb_Ext_Door",
            true
          }
        },
        {
          Util.UnlockShopLabel,
          {
            "TerrorSquad_FT"
          }
        }
      },
      UnlockedBy = {
        "Paris_3_Mission_1"
      }
    },
    NOTE_405 = {
      Functions = {},
      UnlockedBy = {
        "Connect_P3_M1b_KesslerAtDoppelsieg"
      }
    },
    PRE_Connect_ST_405_BackToSaarbruken = {
      RemoveLabel = {},
      Functions = {
        {
          RewardsManager.KillNote,
          {"NOTE_405"}
        }
      }
    },
    Connect_ST_405_BackToSaarbruken = {
      HQLock = {
        _cHQ_BELLE,
        _cHQ_LAVILLETTE,
        _cHQ_BOLOUGNE,
        _cHQ_CATACOMBS,
        _cHQ_CHURCH
      },
      HQUnlock = {_cHQe_SARRETURN},
      Functions = {
        {
          RewardsManager.HideStarter,
          {
            "Starter_Skylar_Airstrip",
            true
          }
        },
        {
          Util.SetPlayerLastHQ,
          {_cHQe_SARRETURN}
        },
        {
          RewardsManager.HideStarter,
          {
            "Race2_Starter"
          }
        }
      },
      UnlockedBy = {"NOTE_405"}
    },
    PRE_Act_3_Mission_3 = {
      Label = {
        "DisableHQReturn"
      }
    },
    Act_3_Mission_3 = {
      RemoveLabel = {
        "DisableHQReturn"
      },
      WTFZone = {
        "WtF_Zones\\global\\A3M3_DoppelseigReturn"
      },
      ContrabandType = {2000},
      Functions = {
        {
          RewardsManager.AchievementGrant,
          {"DOPPELSEIG"}
        },
        {
          RewardsManager.SetLastMissionChatter,
          {
            "cht_Pro_CivGE9b"
          }
        },
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        },
        {
          Util.SetPlayerLastHQ,
          {_cHQe_SARRETURN}
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\dop_return\\ShopKeeper_HQ_LH_RubArm\\Spore_RS_Shopkeeper_HQ_LeHavre",
            true
          }
        }
      },
      UnlockedBy = {
        "Connect_ST_405_BackToSaarbruken"
      }
    },
    PRE_Connect_A3_M6b_BackToParis = {
      Label = {
        "DisableHQReturn"
      }
    },
    Connect_A3_M6b_BackToParis = {
      HQLock = {_cHQe_SARRETURN},
      HQUnlock = {_cHQe_AIRSTRIP},
      RemoveLabel = {
        "DisableHQReturn"
      },
      Functions = {
        {
          Util.SetPlayerLastHQ,
          {_cHQe_AIRSTRIP}
        }
      },
      UnlockedBy = {
        "Act_3_Mission_3"
      }
    },
    PRE_Act_3_Mission_2 = {
      Label = {
        "DisableHQReturn"
      },
      Functions = {}
    },
    Act_3_Mission_2 = {
      RemoveLabel = {
        "DisableHQReturn"
      },
      Label = {"ACT_5"},
      HQLock = {_cHQe_AIRSTRIP},
      HQUnlock = {
        _cHQ_BELLE,
        _cHQ_LAVILLETTE,
        _cHQ_BOLOUGNE,
        _cHQ_CATACOMBS,
        _cHQ_CHURCH
      },
      ContrabandType = {2500},
      Functions = {
        {
          RewardsManager.AchievementGrant,
          {"DIERKER"}
        },
        {
          RewardsManager.SetLastMissionChatter,
          {
            "cht_Pro_CivGE10b"
          }
        },
        {
          Util.SendPerkMessage,
          {
            "NeighborhoodLiberated"
          }
        },
        {
          Util.SetPlayerLastHQ,
          {_cHQ_BELLE}
        },
        {
          Util.UnlockShopLabel,
          {"Dierker"}
        },
        {
          RewardsManager.ShowStarterKwong,
          {}
        },
        {
          RewardsManager.ShowStarterDuval,
          {}
        },
        {
          RewardsManager.ShowStarterCrochet,
          {}
        },
        {
          RewardsManager.ShowStarterFatherDenis,
          {}
        },
        {
          RewardsManager.RecordMissionComplete,
          {}
        },
        {
          Util.SetPlayerCurrentAct,
          {5}
        },
        {
          RewardsManager.ShowStarter,
          {
            "wilcox_lehavre_interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "skylar_lehavre_interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Bryman_Boulogne_Exterior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Veronique_Belle_Interior"
          }
        },
        {
          RewardsManager.ShowStarter,
          {
            "Race2_Starter"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Luc_Belle_Interior"
          }
        },
        {
          RewardsManager.HideStarter,
          {
            "Luc_Belle_Interior_2"
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "belle_ext_closed",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "PristineBelle",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "HQ_CComb_Ext_Open",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "HQ_CComb_Ext_Door",
            true
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "HQ_CComb_Ext_Closed",
            true
          }
        },
        {
          RewardsManager.UnloadColby,
          {
            "HQ_CComb_Ext_Pre",
            true
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Garagekeeper_Belle",
            true
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\garage\\belle_garage\\Spore_RS_Garagekeeper",
            false
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Garagekeeper_lavillette",
            true
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\garage\\lavillette_garage\\Spore_RS_Garagekeeper",
            false
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Garagekeeper_catacombs",
            true
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\garage\\catacombs_garage\\Spore_RS_Garagekeeper",
            false
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Garagekeeper_lehavre",
            true
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\garage\\lehavre_garage\\Spore_RS_Garagekeeper",
            false
          }
        },
        {
          RewardsManager.LoadColby,
          {
            "Garagekeeper_boisdeboulogne",
            true
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\garage\\boisdeboulogne_garage\\Spore_RS_Garagekeeper",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\lha\\ShopKeeper_Headnod\\Spore_RS_Shopkeeper_Paris(0)",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\lna\\ShopKeeper_Headnod(0)\\Spore_RS_Shopkeeper_Paris(0)",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\p1a\\ShopKeeper_Smoke_A(0)\\Spore_RS_Shopkeeper_Paris(0)",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\p1b\\ShopKeeper_WallLean(0)\\Spore_RS_Shopkeeper_Paris(0)",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\p1e\\ShopKeeper_Smoke_A\\Spore_RS_Shopkeeper_Paris",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\p1h\\ShopKeeper_Smoke_B\\Spore_RS_Shopkeeper_Paris",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\p1j\\ShopKeeper_Smoke_B\\Spore_RS_Shopkeeper_Paris",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\p1l\\ShopKeeper_Headnod(3)\\Spore_RS_Shopkeeper_Paris(0)",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\p2b\\ShopKeeper_Smoke_A\\Spore_RS_Shopkeeper_Paris",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\p2e\\ShopKeeper_WallLean\\Spore_RS_Shopkeeper_Paris",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\p2h\\ShopKeeper_WallLean\\Spore_RS_Shopkeeper_Paris",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\p2i\\ShopKeeper_Smoke_B\\Spore_RS_Shopkeeper_Paris",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\p3b\\ShopKeeper_Smoke_A\\Spore_RS_Shopkeeper_Paris",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\p3c\\ShopKeeper_Headnod(0)\\Spore_RS_Shopkeeper_Paris(0)",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\p3e\\ShopKeeper_Smoke_B\\Spore_RS_Shopkeeper_Paris",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\p3f\\ShopKeeper_Headnod(3)\\Spore_RS_Shopkeeper_Paris(0)",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\p3g\\ShopKeeper_WallLean\\Spore_RS_Shopkeeper_Paris(0)",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "Missions\\freeplay\\shopkeepers\\p3i\\ShopKeeper_Headnod(3)\\Spore_RS_Shopkeeper_Paris(0)",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "PARIS\\area01\\lavillette\\interior\\lavillette_int\\Spore_RS_Shopkeeper_HQ",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "PARIS\\area02\\boisdeboulogne\\hq\\boulogne_int\\Spore_RS_Shopkeeper_HQ_BdN",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "PARIS\\area03\\catacombs\\hq\\Spore_RS_Shopkeeper",
            false
          }
        },
        {
          Util.DisableShopKeeperBlip,
          {
            "LeHavre\\lehavre_hq\\ShopKeeper_HQ_LH_RubArm\\Spore_RS_Shopkeeper_HQ_LeHavre",
            false
          }
        },
        {
          Util.SetGarageEnable,
          {true}
        },
        {
          RewardsManager.CheckForLiberateFranceAchievement,
          {}
        }
      },
      WTFHighZone = {
        "WtF_Zones\\global\\P1M1_FuelDepot",
        "WtF_Zones\\global\\Belle_Low",
        "WtF_Zones\\global\\P1M1B_SlaughterhouseLiberate"
      },
      UnlockedBy = {
        "Connect_A3_M6b_BackToParis"
      }
    },
    NOTE_VeroniqueBelle = {
      Functions = {},
      UnlockedBy = {
        "Act_3_Mission_2"
      }
    }
  }
  RewardsManager.RandomRewardList = {
    AmmoType = {},
    ItemType = {},
    Label = {},
    RemoveLabel = {},
    Functions = {}
  }
end

function RewardsManager.__GiveMissionReward(sMissionName)
  if not sMissionName then
    print("ERROR RewardsManager.__GiveMissionReward:: fail - you did not pass a mission name")
    return
  end
  if RewardsManager.RWDList[sMissionName] then
    if RewardsManager.RWDList[sMissionName].ContrabandType and RewardsManager.RWDList[sMissionName].ContrabandType[1] then
      Inventory.GiveMoney(RewardsManager.RWDList[sMissionName].ContrabandType[1])
    end
    if RewardsManager.RWDList[sMissionName].AmmoType then
      for i, BP in pairs(RewardsManager.RWDList[sMissionName].AmmoType) do
        Inventory.GiveAmmo(hSab, BP, 5)
      end
    end
    if RewardsManager.RWDList[sMissionName].ItemType then
      for i, BP in pairs(RewardsManager.RWDList[sMissionName].ItemType) do
        Inventory.GiveItem(hSab, BP, false)
      end
    end
    if RewardsManager.RWDList[sMissionName].Label then
      for i, sLabel in pairs(RewardsManager.RWDList[sMissionName].Label) do
        if not Actor.HasLabel(hSab, sLabel) then
          Actor.SetLabel(hSab, sLabel, true)
        end
      end
    end
    if RewardsManager.RWDList[sMissionName].RemoveLabel then
      for i, sRemoveLabel in pairs(RewardsManager.RWDList[sMissionName].RemoveLabel) do
        if Actor.HasLabel(hSab, sRemoveLabel) then
          Actor.SetLabel(hSab, sRemoveLabel, false)
        end
      end
    end
    if RewardsManager.RWDList[sMissionName].HQUnlock then
      for i, sHQUnlock in pairs(RewardsManager.RWDList[sMissionName].HQUnlock) do
        RewardsManager.UnLockHQPoint(sHQUnlock, true)
      end
    end
    if RewardsManager.RWDList[sMissionName].HQLock then
      for i, sHQLock in pairs(RewardsManager.RWDList[sMissionName].HQLock) do
        RewardsManager.UnLockHQPoint(sHQLock, false)
      end
    end
    if RewardsManager.RWDList[sMissionName].WTFHighZone then
      for i, v in ipairs(RewardsManager.RWDList[sMissionName].WTFHighZone) do
        print("RewardsManager: setting high wtf zone ", v)
        Zone.SwitchState(v, cZONESTATE_HIGHCOLOR_HIGHTAG, cENT_IMMEDIATE)
      end
    end
    if RewardsManager.RWDList[sMissionName].Functions then
      local tCallbacks = RewardsManager.RWDList[sMissionName].Functions
      if type(tCallbacks) == "table" then
        for _, tCallback in ipairs(tCallbacks) do
          __UtilFunctions.CallWithOptionalArgs(tCallback[1], tCallback[2])
        end
      end
    end
    RewardsManager.UpdateHQPoints()
  else
    print("RewardsManager.GiveMissionReward no reward exists for ", sMissionName)
  end
end

function RewardsManager.__GivePreMissionReward(sMissionName)
  if not sMissionName then
    print("ERROR RewardsManager.__GivePreMissionReward:: fail - you did not pass a mission name")
    return
  end
  local sPreMissionName = "PRE_" .. sMissionName
  if RewardsManager.RWDList[sPreMissionName] then
    if RewardsManager.RWDList[sPreMissionName].AmmoType then
      for i, BP in pairs(RewardsManager.RWDList[sPreMissionName].AmmoType) do
        Inventory.GiveAmmo(hSab, BP, 1)
      end
    end
    if RewardsManager.RWDList[sPreMissionName].ItemType then
      for i, BP in pairs(RewardsManager.RWDList[sPreMissionName].ItemType) do
        Inventory.GiveItem(hSab, BP, false)
      end
    end
    if RewardsManager.RWDList[sPreMissionName].Label then
      for i, sLabel in pairs(RewardsManager.RWDList[sPreMissionName].Label) do
        if not Actor.HasLabel(hSab, sLabel) then
          Actor.SetLabel(hSab, sLabel, true)
        end
      end
    end
    if RewardsManager.RWDList[sPreMissionName].RemoveLabel then
      for i, sRemoveLabel in pairs(RewardsManager.RWDList[sPreMissionName].RemoveLabel) do
        if Actor.HasLabel(hSab, sRemoveLabel) then
          Actor.SetLabel(hSab, sRemoveLabel, false)
        end
      end
    end
    if RewardsManager.RWDList[sPreMissionName].Functions then
      local tCallbacks = RewardsManager.RWDList[sPreMissionName].Functions
      if type(tCallbacks) == "table" then
        for _, tCallback in ipairs(tCallbacks) do
          __UtilFunctions.CallWithOptionalArgs(tCallback[1], tCallback[2])
        end
      end
    end
    if RewardsManager.RWDList[sPreMissionName].HQUnlock then
      for i, sHQUnlock in pairs(RewardsManager.RWDList[sPreMissionName].HQUnlock) do
        RewardsManager.UnLockHQPoint(sHQUnlock, true)
      end
    end
    if RewardsManager.RWDList[sPreMissionName].HQLock then
      for i, sHQLock in pairs(RewardsManager.RWDList[sPreMissionName].HQLock) do
        RewardsManager.UnLockHQPoint(sHQLock, false)
      end
    end
    RewardsManager.UpdateHQPoints()
  else
  end
end

function RewardsManager.UnLockHQPoint(sHQUnlock, bUnlocked, bUpdateImmed)
  if not sHQUnlock then
    print("ERROR:5409412 RewardsManager.LockHQPoint")
  end
  if RewardsManager.HQPoints[sHQUnlock] then
    RewardsManager.HQPoints[sHQUnlock].Unlocked = bUnlocked
  else
    print("Cfrench:Error code 7890091:", sHQUnlock, " does not exist in HQPoint table")
  end
  if bUpdateImmed and RewardsManager.HQPoints[sHQUnlock] then
    RewardsManager.UpdateHQPoint(sHQUnlock, RewardsManager.HQPoints[sHQUnlock])
  end
end

function RewardsManager.UpdateHQPoints()
  for HQ, tUnlocked in pairs(RewardsManager.HQPoints) do
    Util.HQSetUnlocked(HQ, tUnlocked.Unlocked)
    if tUnlocked.HQBlip then
      if tUnlocked.Unlocked then
      end
      Util.HQSetOnMiniMap(tUnlocked.HQBlip, tUnlocked.Unlocked)
    end
  end
end

function RewardsManager.UpdateHQPoint(HQ, tHQInfo)
  Util.HQSetUnlocked(HQ, tHQInfo.Unlocked)
  if tHQInfo.HQBlip then
    if tHQInfo.Unlocked then
    end
    Util.HQSetOnMiniMap(tHQInfo.HQBlip, tHQInfo.Unlocked)
  end
end

function RewardsManager.GiveRandomReward(number)
  local sBlueprint = "RndContraband_NZ_Nickel"
  if number == 10 then
    sBlueprint = "RndContraband_NZ_Dime"
  elseif number == 25 then
    sBlueprint = "RndContraband_NZ_Quarter"
  elseif number == 50 then
    sBlueprint = "RndContraband_NZ_HalfDollar"
  elseif number == 100 then
    sBlueprint = "RndContraband_NZ_Dollar"
  end
  Inventory.GiveAmmo(hSab, sBlueprint, 1)
end

function RewardsManager.GetAmbReward(sAmbientType, a_sZone)
  local nModifier = 1
  local nRetVal = 0
  if a_sZone == "P2" then
    nModifier = 10
  elseif a_sZone == "P3" then
    nModifier = 20
  end
  if RewardsManager.AmbList[sAmbientType] then
    if a_sZone == "P2" or a_sZone == "P3" then
      nRetVal = RewardsManager.AmbList[sAmbientType][1] + nModifier
    else
      nRetVal = RewardsManager.AmbList[sAmbientType][1] * nModifier
    end
  end
  if a_sZone == "OS" then
    if IsMissionActive("P2FP_InfiltrateAbbey") then
      RewardsManager.nOS_Reward = RewardsManager.nOS_Reward + nRetVal
      return 0
    end
  elseif a_sZone == "CF" then
    if IsMissionActive("FP_AMB_ChemFactoryStart") then
      RewardsManager.nCF_Reward = RewardsManager.nCF_Reward + nRetVal
      return 0
    end
  elseif a_sZone == "CB" then
    if IsMissionActive("FP_AMB_ChambordStart") then
      RewardsManager.nCB_Reward = RewardsManager.nCB_Reward + nRetVal
      return 0
    end
  elseif a_sZone == "PR" and IsMissionActive("P1FP_PalaisBombe") then
    RewardsManager.nPR_Reward = RewardsManager.nPR_Reward + nRetVal
    return 0
  end
  return nRetVal
end

function RewardsManager.GiveAmbReward(sAmbientType, a_sZone)
  local nReward = RewardsManager.GetAmbReward(sAmbientType, a_sZone)
  if 0 < nReward then
    Inventory.GiveMoney(nReward)
  end
end

function RewardsManager.GiveAmmoTypeReward(sAmmoBluePrintName, Amount)
  local Amount = Amount or 1
  if not sAmmoBluePrintName then
    return
  end
  Inventory.GiveAmmo(hSab, sAmmoBluePrintName, Ammount)
end

function RewardsManager.GiveItemTypeReward(sItemBluePrintName)
  if not sItemBluePrintName then
    return
  end
  Inventory.GiveItem(hSab, sItemBluePrintName, false)
end

function RewardsManager.IncreaseWallet(size)
end

function RewardsManager.UnlockGenerals()
  AmbientRubberStamp.UnlockAmbientGenerals()
end

function RewardsManager.UnlockStrike(c_Strike)
  Util.UnlockStrike(c_Strike, true)
end

function RewardsManager.LoadColby(sTag, bForce, bFadeinout)
  if g_bDEBUG_DISABLE_NEXT_MISSION then
    print("g_bDEBUG_DISABLE_NEXT_MISSION is set not loading any colbys from rewards manager")
    return
  end
  if __gDEBUG_REWARDS then
    bForce = true
  end
  if __gDEBUG_REWARDS then
    RewardsManager.Debug_ColbyTree[sTag] = {Load = true}
  else
    print("Rewards manager loading colby ", sTag, " Forced = ", bForce)
    if bFadeinout then
      EVENT_FadeInOut(2)
      EVENT_Timer("RewardsManager._FadeInLoadColby", nil, 1, {sTag, bForce})
    else
      Util.LoadStaticENTag(sTag, bForce)
    end
  end
end

function RewardsManager:_FadeInLoadColby(sTag, bForce)
  Util.LoadStaticENTag(sTag, bForce)
end

function RewardsManager.UnloadColby(sTag, bForce)
  if __gDEBUG_REWARDS then
    bForce = true
  end
  if __gDEBUG_REWARDS then
    RewardsManager.Debug_ColbyTree[sTag] = {Load = false}
  else
    print("Rewards manager unloading colby ", sTag, " Forced = ", bForce)
    Util.UnloadStaticENTag(sTag, bForce)
  end
end

function RewardsManager.Debug_EvaluteColbyTree()
  print("evaluating colby tree ...")
  if RewardsManager.Debug_ColbyTree then
    for sTag, tLoadTable in pairs(RewardsManager.Debug_ColbyTree) do
      if RewardsManager.Debug_ColbyTree[sTag].Load then
        print("Rewards manager loading colby ", sTag, " Forced = ", true)
        Util.LoadStaticENTag(sTag, true)
      else
        print("Rewards manager unloading colby ", sTag, " Forced = ", true)
        Util.UnloadStaticENTag(sTag, true)
      end
    end
  end
  RewardsManager.Debug_ColbyTree = nil
end

function RewardsManager.Debug_EvaluteStarterTree()
  print("evaluating starter tree ...")
  if RewardsManager.Debug_StarterTree then
    for sStarter, tLoadTable in pairs(RewardsManager.Debug_StarterTree) do
      local tStarter = StarterManager.GetStarterTable(sStarter)
      if tStarter then
        if RewardsManager.Debug_StarterTree[sStarter].Load then
          StarterManager.Save_IsStarterHiddenList[sStarter].bHidden = false
        else
          StarterManager.Save_IsStarterHiddenList[sStarter].bHidden = true
        end
      else
        print("ERROR::RewardsManager.Debug_EvaluteStarterTree starter is not in starter table ", sStarter)
      end
    end
  end
  RewardsManager.Debug_EvaluteStarterTree = nil
end

function RewardsManager.HideStarter(sStarter, bForceUnload)
  if __gDEBUG_REWARDS then
    RewardsManager.Debug_StarterTree[sStarter] = {Load = false}
  else
    StarterManager.HideStarter(sStarter, true, bForceUnload)
  end
end

function RewardsManager.ShowStarter(sStarter, bForceLoadIfAlreadyInInterior)
  local bDebugDelayLoad = false
  if __gDEBUG_REWARDS then
    RewardsManager.Debug_StarterTree[sStarter] = {Load = true}
  else
    StarterManager.HideStarter(sStarter, false, false, bDebugDelayLoad)
    if bForceLoadIfAlreadyInInterior then
      local sCodePlayersInterior = Util.GetPlayersInterior()
      local tStarterTable = StarterManager.GetStarterTable(sStarter)
      if tStarterTable and tStarterTable.bInterior and tStarterTable.sInterior and sCodePlayersInterior == tStarterTable.sInterior then
        print("this person is in the interior we are already in , lets force load him", sStarter)
        StarterManager.LoadInteriorStarterNode(tStarterTable.sName, nil, nil)
      end
    end
  end
end

function RewardsManager.MarkShowStarter(sStarter)
  if StarterManager.Save_IsStarterHiddenList[sStarter] then
    StarterManager.Save_IsStarterHiddenList[sStarter].bHidden = false
  end
end

function RewardsManager.MarkHideStarter(sStarter)
  if StarterManager.Save_IsStarterHiddenList[sStarter] then
    StarterManager.Save_IsStarterHiddenList[sStarter].bHidden = true
  end
end

function RewardsManager.ShowStarterKwong(bForceLoadIfAlreadyInInterior)
  local sStarter = "drkwong_cat_int"
  if IsMissionCompleted("P3FP_MadBomber03") then
    sStarter = "Kwong_Ctown"
  end
  if not IsMissionCompleted("P3FP_BiggerGun") then
    RewardsManager.ShowStarter(sStarter, bForceLoadIfAlreadyInInterior)
  else
    print("kwong line complete not showing starter")
  end
end

function RewardsManager.ShowStarterDuval(bForceLoadIfAlreadyInInterior)
  local sStarter = "duval_cat_int"
  if IsMissionCompleted("P3FP_Hit") then
    sStarter = "Duval_ext_ind"
  end
  if not IsMissionCompleted("P3FP_OKCorral") then
    RewardsManager.ShowStarter(sStarter, bForceLoadIfAlreadyInInterior)
  else
    print("duval line complete not showing starter")
  end
end

function RewardsManager.ShowStarterCrochet(bForceLoadIfAlreadyInInterior)
  local sStarter = "Couteau_LaVillette_Interior"
  if IsMissionCompleted("P1FP_Entourage") then
    sStarter = "Crochet_ext_whouse"
  end
  if not IsMissionCompleted("P1FP_PalaisBombe") then
    RewardsManager.ShowStarter(sStarter, bForceLoadIfAlreadyInInterior)
  else
    print("Crochet line complete not showing starter")
  end
end

function RewardsManager.ShowStarterFatherDenis(bForceLoadIfAlreadyInInterior)
  local sStarter = "Father_Belle_Interior"
  if IsMissionCompleted("P1FP_EustacheSniper") then
    sStarter = "Father_Sacre_Interior"
  end
  if not IsMissionCompleted("P1FP_NaziParty") then
    RewardsManager.ShowStarter(sStarter, bForceLoadIfAlreadyInInterior)
  else
    print("FatherDenis line complete not showing starter")
  end
end

function RewardsManager._OKCheckForSpecialCaseStarter(sStarter)
  local bOk = true
  if sStarter == "drkwong_cat_int" then
    if IsMissionCompleted("P3FP_MadBomber03") then
      bOk = false
    end
  elseif sStarter == "Kwong_Ctown" then
    if not IsMissionCompleted("P3FP_MadBomber03") then
      bOk = false
    elseif IsMissionCompleted("P3FP_BiggerGun") then
      bOk = false
    end
  elseif sStarter == "Father_Belle_Interior" then
    if IsMissionCompleted("P1FP_EustacheSniper") then
      bOk = false
    end
  elseif sStarter == "Father_Sacre_Interior" then
    if not IsMissionCompleted("P1FP_EustacheSniper") then
      bOk = false
    elseif IsMissionCompleted("P1FP_NaziParty") then
      bOk = false
    end
  end
  return bOk
end

function RewardsManager.Debug_AddToMissionCompletedList(sMissionName)
  if __gDEBUG_SETCOMPLETES then
    print("***** adding mission got completedmission list ", sMissionName)
    table.insert(SabTask.tCompletedMissionList, sMissionName .. "_ActionPackage")
  end
end

function RewardsManager.Debug_AddToMissionUnlockedList(sMissionName)
  if __gDEBUG_SETOPEN then
    print("!!! adding mission got unlock list ", sMissionName)
    SabTaskGameMaster.AddToMissionPool(sMissionName)
  end
end

function RewardsManager.WeaponUnlock(sWeapon)
end

function RewardsManager.SetMAXEBaseEscalation(a_nEscLevel)
end

function RewardsManager.AchievementGrant(a_HANDLE)
  if not __gDEBUG_REWARDS then
    AchievementsManager.AchievementGrant(a_HANDLE)
  end
end

function RewardsManager.Debug_UnlockPreviousRewards(sMissionName)
  RewardsManager.Debug_Index = 0
  RewardsManager.Debug_BuildRewardTree(sMissionName)
  RewardsManager.Debug_GiveRewardTree()
  RewardsManager.Debug_EvaluteColbyTree()
  RewardsManager.Debug_EvaluteStarterTree()
  StarterManager.LoadAllExteriorStarters()
  RewardsManager.UpdateHQPoints()
end

function RewardsManager.Debug_BuildRewardTree(sMissionName)
  if not sMissionName then
    Util.Assert(false, "why is sMissionName nil in RewardsManager.Debug_BuildRewardTree")
    print("why is sMissionName nil in RewardsManager.Debug_BuildRewardTree")
    return
  end
  local sPreMissionName = "PRE_" .. sMissionName
  if not RewardsManager.RWDList[sPreMissionName] or RewardsManager.RWDList[sMissionName].UnlockedBy then
  end
  if RewardsManager.RWDList[sMissionName] and RewardsManager.RWDList[sMissionName].UnlockedBy then
    RewardsManager.Debug_Index = RewardsManager.Debug_Index + 1
    local sUnlockedBy = RewardsManager.RWDList[sMissionName].UnlockedBy[1]
    RewardsManager.Debug_UnlockTree[RewardsManager.Debug_Index] = sUnlockedBy
    RewardsManager.Debug_BuildRewardTree(sUnlockedBy)
  end
end

function RewardsManager.Debug_GiveRewardTree()
  while RewardsManager.Debug_Index > 0 do
    local sName = RewardsManager.Debug_UnlockTree[RewardsManager.Debug_Index]
    if sName then
      RewardsManager.__GivePreMissionReward(sName)
      RewardsManager.__GiveMissionReward(sName)
    end
    if RewardsManager.RWDList[sName] and RewardsManager.RWDList[sName].WTFZone then
      for i, v in ipairs(RewardsManager.RWDList[sName].WTFZone) do
        print("RewardsManager: setting high wtf zone ", v)
        Zone.SwitchState(v, cZONESTATE_HIGHCOLOR_HIGHTAG, cENT_IMMEDIATE)
      end
    end
    RewardsManager.Debug_Index = RewardsManager.Debug_Index - 1
  end
end

function RewardsManager.GetMissionUnlockList(sMissionName)
  if RewardsManager.RWDList[sMissionName] and RewardsManager.RWDList[sMissionName].UnlockNextList then
    return RewardsManager.RWDList[sMissionName].UnlockNextList
  end
  return nil
end

function RewardsManager.HQMissionCompletes(sMission)
  if SabTask._tMiscSaveTable._HQSetsMissionCompletes then
    SabTask._tMiscSaveTable._HQSetsMissionCompletes[sMission] = true
  end
end

function RewardsManager.DEBUG_UnlockShops()
  if __gDEBUG_REWARDS then
    Util.SetShopEnable(true)
    RewardsManager.LoadColby("000_SHOP_WEAPONS", true)
    RewardsManager.LoadColby("000_SHOP_SANTOS", true)
    Util.UnlockShopLabel("Shop_Tier1")
    Util.UnlockShopLabel("Shop_Unlocked")
    Util.UnlockShopLabel("Shop_Santos", false)
    Util.UnlockShopLabel("Shop_garage")
    Util.SetGarageEnable(true)
    RewardsManager.LoadColby("Garagekeeper_Belle", true)
    RewardsManager.LoadColby("Garagekeeper_lavillette", true)
  end
end

function RewardsManager.RemoveAllWeapons()
  if __gDEBUG_REWARDS then
    if not __gDEBUG_REMOVEWEAPONSONCE then
      __gDEBUG_REMOVEWEAPONSONCE = true
      Inventory.RemoveAllWeapons(hSab)
    end
  else
    Inventory.RemoveAllWeapons(hSab)
  end
end

function RewardsManager.SetupLoadTips(iPartNum)
  if iPartNum == 0 then
    local tPart1Table = {
      "Tutorials_Load_Screen.Civ_Rats",
      3,
      "Tutorials_Load_Screen.Cover_Button",
      5,
      "Tutorials_Load_Screen.Melee_Whistle",
      5,
      "Tutorials_Load_Screen.Perks",
      5,
      "Tutorials_Load_Screen.Grab_Punch",
      4,
      "Tutorials_Load_Screen.Nazi_Eye",
      5,
      "Tutorials_Load_Screen.Climb_Anything",
      5,
      "Tutorials_Load_Screen.Journal",
      5,
      "Tutorials_Load_Screen.Melee_BlockAttack",
      3,
      "Tutorials_Load_Screen.No_Smoking",
      3,
      "Tutorials_Load_Screen.Objective_Focus",
      5,
      "Tutorials_Load_Screen.Save_Load",
      3,
      "Tutorials_Load_Screen.WTF_Objective",
      4,
      "Tutorials_Load_Screen.Sprint",
      4
    }
    HUD.AddLoadScreenTutorials(tPart1Table)
  end
  if iPartNum == 1 then
    local tPart2Table = {
      "Tutorials_Load_Screen.Shoot_Sab",
      3,
      "Tutorials_Load_Screen.Sab_Distraction",
      5,
      "Tutorials_Load_Screen.Nazi_Whistle",
      5,
      "Tutorials_Load_Screen.Suspicion_Body",
      4,
      "Tutorials_Load_Screen.Alarm_Box",
      5,
      "Tutorials_Load_Screen.Pursuit_Stun",
      4,
      "Tutorials_Load_Screen.Sprint_Shot",
      3,
      "Tutorials_Load_Screen.Melee_Big",
      3,
      "Tutorials_Load_Screen.Weapons_Zoom",
      3,
      "Tutorials_Load_Screen.Alarm_Talk",
      3,
      "Tutorials_Load_Screen.Cover_TakeIt",
      4,
      "Tutorials_Load_Screen.Escalation_Hiding",
      5,
      "Tutorials_Load_Screen.Hiding_Follower",
      3,
      "Tutorials_Load_Screen.Cover_PopOut",
      3
    }
    HUD.AddLoadScreenTutorials(tPart2Table)
    local tPart2Table = {
      "Tutorials_Load_Screen.Nazi_Halo",
      4,
      "Tutorials_Load_Screen.Postcards",
      3,
      "Tutorials_Load_Screen.Suspicious_Activities",
      4,
      "Tutorials_Load_Screen.Sweet_Jumps",
      4,
      "Tutorials_Load_Screen.Top_Spot",
      4,
      "Tutorials_Load_Screen.Weapon_Stow",
      5,
      "Tutorials_Load_Screen.Resistance_Crates",
      5,
      "Tutorials_Load_Screen.Disguise_Gestapo",
      5,
      "Tutorials_Load_Screen.Disguise_Bloody",
      5,
      "Tutorials_Load_Screen.Disguise_Sneak",
      3,
      "Tutorials_Load_Screen.Disguise_Stealth_Kill",
      4,
      "Tutorials_Load_Screen.Starter_Border",
      4
    }
    HUD.AddLoadScreenTutorials(tPart2Table)
  end
  if iPartNum == 1.5 then
    local tPart3Table = {
      "Tutorials_Load_Screen.Disguise_Armed",
      5,
      "Tutorials_Load_Screen.Alarm_Disguise",
      5,
      "Tutorials_Load_Screen.Remove_Disguise",
      4,
      "Tutorials_Load_Screen.Tower_Permanent",
      5,
      "Tutorials_Load_Screen.Shopkeepers",
      5,
      "Tutorials_Load_Screen.Rewards",
      5,
      "Tutorials_Load_Screen.Getaway_Upgrade",
      3,
      "Tutorials_Load_Screen.Disguise_Reset",
      3,
      "Tutorials_Load_Screen.WTF_High",
      4,
      "Tutorials_Load_Screen.Destroy_Bullets",
      4,
      "Tutorials_Load_Screen.Weapon_Unlock",
      5,
      "Tutorials_Load_Screen.Grenades_Distraction",
      4,
      "Tutorials_Load_Screen.Suspicion_Roof",
      5,
      "Tutorials_Load_Screen.Weapons_Loadout",
      3,
      "Tutorials_Load_Screen.Destroy_Escalation",
      4,
      "Tutorials_Load_Screen.Shops_Ammo",
      5
    }
    HUD.AddLoadScreenTutorials(tPart3Table)
  end
  if iPartNum == 2 then
    local tPart4Table = {
      "Tutorials_Load_Screen.Sniper_Zoom",
      4,
      "Tutorials_Load_Screen.Sab_TrapCar",
      5,
      "Tutorials_Load_Screen.Weapons_Unlock",
      4,
      "Tutorials_Load_Screen.Resistance_Upgrade",
      3,
      "Tutorials_Load_Screen.Panzerfauts",
      4,
      "Tutorials_Load_Screen.Tanks",
      4,
      "Tutorials_Load_Screen.Perks_Upgrade",
      5,
      "Tutorials_Load_Screen.RDX_Trap",
      3,
      "Tutorials_Load_Screen.Zepplin_Defense",
      3
    }
    HUD.AddLoadScreenTutorials(tPart4Table)
  end
end

function RewardsManager:QueueShopTutorial()
  Util.QueueTutorial("TutorialTip_Text.Shop_Items_Unlocked_Title", "TutorialTip_Text.Shop_Items_Unlocked", 20, true)
end

function RewardsManager:QueueShopTutorial_resistance()
  Util.QueueTutorial("TutorialTip_Text.Shop_Items_Unlocked_Title", "TutorialTip_Text.Shop_Resistance_Unlocked", 20, true)
end

function RewardsManager.RecordMissionComplete()
  Util.RecordMissionComplete()
end

function RewardsManager.SetMAXEscalation(a_nEscLevel)
  Suspicion.SetEscalationCap(a_nEscLevel)
  SabTask._tMiscSaveTable.MAXEscalation = a_nEscLevel
end

function RewardsManager.DisableStealthKill(bDisable)
  Util.SetDisableControls("StealthKill", bDisable)
  SabTask._tMiscSaveTable.bDisableStealthKill = bDisable
end

function RewardsManager.DisableDisguising(bDisable)
  Util.DisableDisguising(bDisable)
  SabTask._tMiscSaveTable.bDisableDisguising = bDisable
end

function RewardsManager.EnableHidePts(bEnable)
  Suspicion.EnableHidePts(bEnable)
  SabTask._tMiscSaveTable.bEnableHidePts = bEnable
end

function RewardsManager.EnableResistanceEscalation(bEnable)
  Suspicion.EnableResistanceEscalation(bEnable)
  SabTask._tMiscSaveTable.bEnableResistanceEscalation = bEnable
end

function RewardsManager.GlobalEnableHighWTFCivMelee(bEnable)
  Actor.GlobalEnableHighWTFCivMelee(bEnable)
  SabTask._tMiscSaveTable.bGlobalEnableHighWTFCivMelee = bEnable
end

function RewardsManager.EnableEspritDeCorps(bEnable)
  Suspicion.EnableEspritDeCorps(bEnable)
  SabTask._tMiscSaveTable.bEnableEspritDeCorps = bEnable
end

function RewardsManager.SetGlobalAllowCombatHijacking(bEnable)
  Combat.SetGlobalAllowCombatHijacking(bEnable)
  SabTask._tMiscSaveTable.bGlobalAllowCombatHijacking = bEnable
end

function RewardsManager.SetLastMissionChatter(sChatter)
  Util.SetLastMissionChatter(sChatter)
  SabTask._tMiscSaveTable.LastMissionChatter = sChatter
end

function RewardsManager.EnableEscalationVehicles(bEnable)
  Suspicion.EnableEscalationVehicles(bEnable)
  SabTask._tMiscSaveTable.bEnableEscalationVehicles = bEnable
end

function RewardsManager.SetEscalationBPSet(sBP)
  if sBP then
    Suspicion.SetEscalationBPSet(sBP)
    SabTask._tMiscSaveTable.EscalationBPSet = sBP
  else
    Suspicion.ResetEscalationBPSet()
    SabTask._tMiscSaveTable.EscalationBPSet = nil
  end
end

function RewardsManager.SetEnablePerkFriendlyFire(bEnable)
  Util.SetPerkAvailable("Perksv3.FriendlyFireTitle", bEnable)
  SabTask._tMiscSaveTable.bEnablePerkFriendlyFire = bEnable
end

function RewardsManager.SetEnablePerkNotoriousTitle(bEnable)
  Util.SetPerkAvailable("Perksv3.NotoriousTitle", bEnable)
  SabTask._tMiscSaveTable.bEnablePerkNotoriousTitle = bEnable
end

function RewardsManager.SetEnablePerkDoubleAgentTitle(bEnable)
  Util.SetPerkAvailable("Perksv3.DoubleAgentTitle", bEnable)
  SabTask._tMiscSaveTable.bEnablePerkDoubleAgentTitle = bEnable
end

function RewardsManager.RestoreStates()
  if SabTask._tMiscSaveTable then
    if SabTask._tMiscSaveTable.bDisableDisguising ~= nil then
      Util.DisableDisguising(SabTask._tMiscSaveTable.bDisableDisguising)
    end
    if SabTask._tMiscSaveTable.bDisableStealthKill ~= nil then
      Util.SetDisableControls("StealthKill", SabTask._tMiscSaveTable.bDisableStealthKill)
    end
    if SabTask._tMiscSaveTable.bEnableHidePts ~= nil then
      Suspicion.EnableHidePts(SabTask._tMiscSaveTable.bEnableHidePts)
    end
    if SabTask._tMiscSaveTable.MAXEscalation ~= nil then
      Suspicion.SetEscalationCap(SabTask._tMiscSaveTable.MAXEscalation)
    end
    if SabTask._tMiscSaveTable.bEnableResistanceEscalation ~= nil then
      Suspicion.EnableResistanceEscalation(SabTask._tMiscSaveTable.bEnableResistanceEscalation)
    end
    if SabTask._tMiscSaveTable.bGlobalEnableHighWTFCivMelee ~= nil then
      Actor.GlobalEnableHighWTFCivMelee(SabTask._tMiscSaveTable.bGlobalEnableHighWTFCivMelee)
    end
    if SabTask._tMiscSaveTable.bEnableEspritDeCorps ~= nil then
      Suspicion.EnableEspritDeCorps(SabTask._tMiscSaveTable.bEnableEspritDeCorps)
    end
    if SabTask._tMiscSaveTable.bGlobalAllowCombatHijacking ~= nil then
      Combat.SetGlobalAllowCombatHijacking(SabTask._tMiscSaveTable.bGlobalAllowCombatHijacking)
    end
    if SabTask._tMiscSaveTable.LastMissionChatter ~= nil then
      Util.SetLastMissionChatter(SabTask._tMiscSaveTable.LastMissionChatter)
    end
    if SabTask._tMiscSaveTable.bEnableEscalationVehicles ~= nil then
      Suspicion.EnableEscalationVehicles(SabTask._tMiscSaveTable.bEnableEscalationVehicles)
    end
    if SabTask._tMiscSaveTable.EscalationBPSet ~= nil then
      Suspicion.SetEscalationBPSet(SabTask._tMiscSaveTable.EscalationBPSet)
    else
      Suspicion.ResetEscalationBPSet()
    end
    if SabTask._tMiscSaveTable.bEnablePerkFriendlyFire ~= nil then
      Util.SetPerkAvailable("Perksv3.FriendlyFireTitle", SabTask._tMiscSaveTable.bEnablePerkFriendlyFire)
    end
    if SabTask._tMiscSaveTable.bEnablePerkNotoriousTitle ~= nil then
      Util.SetPerkAvailable("Perksv3.NotoriousTitle", SabTask._tMiscSaveTable.bEnablePerkNotoriousTitle)
    end
    if SabTask._tMiscSaveTable.bEnablePerkDoubleAgentTitle ~= nil then
      Util.SetPerkAvailable("Perksv3.DoubleAgentTitle", SabTask._tMiscSaveTable.bEnablePerkDoubleAgentTitle)
    end
  else
    Util.Assert(false, "CFRENCH SabTask._tMiscSaveTable is nil, oh noes!")
  end
end

function RewardsManager.KillNote(sNote)
  if sNote then
    local oNote = GetAPByName(sNote)
    if oNote and oNote:IsActive() then
      local tConfig = oNote:GetConfig()
      Util.RemoveAvailableMissionMessage(sNote)
      tConfig.bFinishRebuild = false
      CompleteMissionByName(sNote)
    end
  end
end

function RewardsManager.CheckForLiberateFranceAchievement()
  if IsMissionCompleted("Act_3_Mission_2") and IsMissionCompleted("P1FP_PalaisBombe") and IsMissionCompleted("P3FP_OKCorral") and IsMissionCompleted("P3FP_BiggerGun") and IsMissionCompleted("P2FP_RadioSwap") and IsMissionCompleted("P1FP_NaziParty") and IsMissionCompleted("FP_AMB_ChambordStart") then
    RewardsManager.AchievementGrant("LIBERATE_ALL_WTF")
  end
end

function RewardsManager.CheckForP1WTFAchievement()
  if IsMissionCompleted("Paris_4_Mission_1") and IsMissionCompleted("Paris_2_Mission_5") and IsMissionCompleted("P1FP_PalaisBombe") and IsMissionCompleted("P1FP_NaziParty") then
    RewardsManager.AchievementGrant("P1_WTF")
  end
end

function RewardsManager.CheckForP2WTFAchievement()
  if IsMissionCompleted("Paris_5_Mission_3") and IsMissionCompleted("P2FP_RadioSwap") then
    RewardsManager.AchievementGrant("P2_WTF")
  end
end

function RewardsManager.CheckForP3WTFAchievement()
  if IsMissionCompleted("Act_3_Mission_1") and IsMissionCompleted("P3FP_BiggerGun") and IsMissionCompleted("P3FP_OKCorral") then
    RewardsManager.AchievementGrant("P3_WTF")
  end
end

function RewardsManager:PlayJournalTip(sTextID)
  if not sTextID then
    return
  end
  Saboteur.ShowToolTip(sTextID)
end

function RewardsManager.PlayTutorialTip()
end

function RewardsManager.ClearGlobalAMBReward()
  RewardsManager.nPR_Reward = 0
  RewardsManager.nCB_Reward = 0
  RewardsManager.nOS_Reward = 0
  RewardsManager.nCF_Reward = 0
end

function RewardsManager.GiveDelayAMBReward(sZone)
  local nReward = 0
  if sZone == "PR" then
    nReward = RewardsManager.nPR_Reward
  elseif sZone == "CB" then
    nReward = RewardsManager.nCB_Reward
  elseif sZone == "OS" then
    nReward = RewardsManager.nOS_Reward
  elseif sZone == "CF" then
    nReward = RewardsManager.nCF_Reward
  end
  if nReward and type(nReward) == "number" then
    Inventory.GiveMoney(nReward)
  end
end
