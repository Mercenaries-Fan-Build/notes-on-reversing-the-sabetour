gtMissionsFile = {
  Act_1 = {
    "Act_1_ToGermany",
    "Act_1_ConnectToBar",
    "Act_1_BarFight",
    "A1FP_CarSmashup",
    "Act_1_Race",
    "Act_1_GetCaught",
    "Act_1_Factory",
    "Act_1_Escape",
    "Act_1_Farm",
    "Connect_A1_M2c_JulesToTrack"
  },
  Paris_1 = {
    "Paris_1_Mission_1",
    "Paris_1_Mission_1B",
    "Paris_1_Mission_1_ConnectB",
    "Paris_1_Mission_2",
    "Paris_1_Mission_5_Taxi",
    "Paris_1_Mission_5",
    "Paris_1_Mission_6"
  },
  Paris_2 = {
    "Paris_2_Mission_3",
    "Paris_2_Mission_5"
  },
  Paris_3 = {
    "Paris_3_Mission_1"
  },
  Paris_4 = {
    "Paris_4_Mission_1",
    "Paris_4_Mission_1B"
  },
  Paris_5 = {
    "Paris_5_Mission_3"
  },
  Paris_6 = {
    "Paris_6_Mission_1"
  },
  SOE_1 = {
    "SOE_Zeppelin",
    "SOE_1_ConnectToBelle",
    "SOE_1_Mission_7"
  },
  SOE_2 = {
    "SOE_2_Mission_2"
  },
  Act_3 = {
    "Act_3_Mission_1",
    "Act_3_Mission_2",
    "Act_3_Mission_3",
    "DoubleVictory",
    "Act_3_Mission_4",
    "Act_3_Mission_5"
  },
  Freeplay = {
    P1 = {
      "P1FP_Carbomb",
      "P1FP_DestroyConvoy",
      "P1FP_Entourage",
      "P1FP_EustacheSniper",
      "P1FP_Jailbreak",
      "P1FP_KillCourtyard01",
      "P1FP_MadBomber01",
      "Connect_215_Con_Resist",
      "P1FP_NaziParty",
      "P1FP_OnTheAir",
      "P1FP_PalaisBombe",
      "P1FP_RoofFetch01",
      "P1FP_Suicide",
      "P1FP_TrainCarBash",
      "P1FP_Traitor",
      "FP_FightClub_A"
    },
    P2 = {
      "P2FP_GrandSniper",
      "P2FP_MadeleineSniper",
      "P2FP_RadioRescue",
      "P2FP_ShinyBombParts",
      "P2FP_Trap",
      "P2FP_InfiltrateAbbey"
    },
    P3 = {
      "P3FP_FountainSniper",
      "P3FP_GasTrucks",
      "P3FP_Hit",
      "P3FP_Jardin",
      "P3FP_MadBomber03",
      "P3FP_OKCorral",
      "P3FP_RadioSabotage"
    },
    P4 = {
      "P4FP_MadBomber02"
    },
    LaHavre = {
      "CFP_DockDestroy",
      "CFP_KoenigDestroy"
    }
  }
}

function GenerateDebugList(tTable, ParentName)
  for key, value in pairs(tTable) do
    if type(value) == "table" then
      Util.AddMissionFolder(key, ParentName)
      GenerateDebugList(value, key)
    else
      Util.AddMissionToFolder(value, ParentName)
    end
  end
end
