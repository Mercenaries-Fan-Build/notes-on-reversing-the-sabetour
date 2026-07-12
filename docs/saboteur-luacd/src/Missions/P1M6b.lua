if P1M6b == nil then
  P1M6b = SabTaskObjective:Create()
  gsP1M6b = "Missions\\paris_1\\mission_6b\\"
  P1M6b:Configure({
    TaskCount = 999,
    bStarterless = true,
    tUnlockList = {
      "NOTE_BrymanRadioSabotage",
      "P3FP_RadioSabotage"
    },
    MCDisplayID = cNOMISSIONCOMPLETE,
    sSaveMissionNameID = "MissionNames_Text.P1M6",
    bDisableMissionTitle = true,
    sHQStartPoint = _cHQe_LAVILLETTE,
    bSLOverrideFade = true,
    tMissionBPWinners = {
      "VH_CV_CR_Citroen15_01",
      "Human_RS_Kessler",
      "Human_RS_Maria",
      "Human_RS_Skylar"
    },
    tDeleteNodes = {
      "Missions\\paris_1\\mission_6b\\deletenode"
    },
    tSMEDNodes = {
      gsP1M6b .. "main"
    },
    tStaticTags = {}
  })
end

function P1M6b:STARTER_Setup()
  self:DisableTraffic()
end

function P1M6b:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self:Task_LoadResistance()
end

function P1M6b:Task_LoadResistance()
  self:CreateTask({
    sName = "Task_LoadResistance",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      gsP1M6b .. "characters"
    },
    tOnActivate = {
      {
        Util.SetOverrideLoadScreenFadeIn,
        {false}
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "P1M6b.Checkpoint1"
        }
      }
    }
  })
end

function P1M6b:GENERAL_Setup()
  self.tInfo.Maria = gsP1M6b .. "characters\\Maria_Connect"
  self.tInfo.Kessler = gsP1M6b .. "characters\\Kessler_Connect"
  self.tInfo.Skylar = gsP1M6b .. "characters\\Skylar_Connect"
  self.tInfo.Car = "Missions\\paris_1\\mission_6b\\prop\\car"
  Suspicion.ResetEscalation()
  WorldSMEDNodes.LoadNode("Missions\\paris_1\\mission_6b\\prop")
end

function P1M6b:MISSION_ONCOMPLETE()
  print("MISSION_ONCOMPLETE ", self:GetName())
end

function P1M6b:MISSION_ONCANCEL()
  print("MISSION_ONCANCEL ", self:GetName())
  RewardsManager.HideStarter("skylar_cat_int", true)
  RewardsManager.HideStarter("kessler_cat_int", true)
  RewardsManager.HideStarter("maria_cat_int", true)
  RewardsManager.HideStarter("luc_cat_int", true)
end

function P1M6b:MISSION_ONRESET()
  Train.TrainSystemEnable(true)
  self:EnableTraffic()
  print("MISSION_ONRESET ", self:GetName())
  if not IsMissionCompleted("P3FP_MadBomber03") then
    RewardsManager.ShowStarter("drkwong_cat_int", true)
  end
  Util.HQSetUnlocked(_cHQ_CATACOMBS, true)
  WorldSMEDNodes.UnloadNode("Missions\\paris_1\\mission_6b\\prop", true)
end

function P1M6b:Checkpoint1()
  self.tInfo.bFailHasOccured = false
  Render.FadeScreen(false)
  self:DisableTraffic()
  EVENT_Timer("P1M6b.EnableTraffic", self, 4)
  self:Task_GotoResistance()
end

function P1M6b:Task_GotoResistance()
  self:CreateTask({
    sName = "Task_GotoResistance",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "goto",
    Proximity = 8,
    sObjectiveTextID = "P1M6b_Text.GetToResist",
    tDestProximityObj = {
      gsP1M6b .. "main\\LOC_Pickup"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        P1M6b.RunSkylar,
        {self}
      },
      {
        P1M6b.SetupEarlyFailProx,
        {self}
      }
    },
    tOnComplete = {
      {
        Combat.SetIdleScripted,
        {
          Handle(self.tInfo.Skylar),
          false
        }
      },
      {
        self.Task_TaxiMaria,
        {self}
      }
    },
    tOnReset = {
      {
        self.DisableTraffic,
        {}
      }
    }
  })
end

function P1M6b:SetupEarlyFailProx()
  self:ClearEarlyFail()
  local hLoc = Handle(gsP1M6b .. "main\\LOC_Pickup")
  self.tInfo.eEarlyFail = EVENT_PlayerToActorProximityNegated("P1M6b.EarlyFail", self, hLoc, 250)
end

function P1M6b:EarlyFail()
  self:MissionTaskFail("GenericFail_Text.ABANDON_GEN_Resistance")
end

function P1M6b:ClearEarlyFail()
  if self.tInfo.eEarlyFail then
    Util.KillEvent(self.tInfo.eEarlyFail)
  end
end

function P1M6b:RunSkylar()
  Nav.MoveToObject(Handle(self.tInfo.Skylar), Handle("Missions\\paris_1\\mission_6b\\main\\LOC_RunTo"), 1.5, true)
  Combat.SetIdleScripted(Handle(self.tInfo.Skylar), true)
end

function P1M6b:DisableTraffic()
  if InteriorManager.GetPlayersInterior() ~= "" then
    return
  end
  if Vehicle.IsTrafficEnabled() then
    print("Disabling traffic")
    Vehicle.EnableTraffic(false, true)
    Train.TrainSystemEnable(false)
  end
end

function P1M6b:EnableTraffic()
  if InteriorManager.GetPlayersInterior() ~= "" then
    return
  end
  if not Vehicle.IsTrafficEnabled() then
    print("enabling traffic")
    Vehicle.EnableTraffic(true)
    Train.TrainSystemEnable(true)
  end
end

function P1M6b:Task_TaxiMaria()
  self:CreateTask({
    sName = "Task_TaxiMaria",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "GenericObjective_Text.HQ_P3_GoTo",
    sPickupTextID = "P1M6b_Text.PickupDudes",
    sVehicleReturnID = "P1M6b_Text.GetBackInCar",
    sVehicleFetchID = "P1M6b_Text.PickupDudes",
    sDropoffTextID = "GenericObjective_Text.HQ_P3_GoTo",
    bGroundBlip = true,
    tDestLocators = {
      gsP1M6b .. "main\\LOC_Dropoff"
    },
    tPickupRegion = {
      gsP1M6b .. "main\\REG_Pickup"
    },
    tDestRegion = {
      gsP1M6b .. "main\\REG_Dropoff"
    },
    tDeliverObjs = {
      self.tInfo.Maria,
      self.tInfo.Kessler,
      self.tInfo.Skylar
    },
    bEscalationDenial = true,
    tReadyForUnload = {},
    tSMEDNodes = {},
    tOnEarlyExit = {},
    tOnPickup = {
      {
        self.ClearEarlyFail,
        {self}
      },
      {
        EVENT_PlayConversationDelayed,
        {
          "P1M6b_Taxi_Drive01",
          13,
          self
        }
      }
    },
    tOnComplete = {
      {
        self.Task_EnterCatHQ,
        {self}
      }
    },
    tOnActivate = {
      {
        Util.HQSetUnlocked,
        {_cHQ_CATACOMBS, false}
      }
    }
  })
end

function P1M6b:UnloadMembers()
  self:UnloadTaskNodes("Task_LoadResistance", true)
end

function P1M6b:SetupFailSafeEnter()
  EVENT_PlayerToActorProximity("P1M6b.FailSafeEnter", self, "Missions\\paris_1\\mission_6b\\main\\LOC_GO1", 5)
end

function P1M6b:FailSafeEnter()
  if self:IsMissionTaskActive("Task_TaxiMaria") then
    self:CompleteTaskByName("Task_TaxiMaria")
  end
end

function P1M6b:Task_EnterCatHQ()
  self:CreateTask({
    sName = "Task_EnterCatHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "EnterInterior",
    sInteriorName = "Catacombs",
    MarkerHeight = 0.8,
    tLocators = {},
    tOnActivate = {
      {
        Cin.LoadCinematic,
        {
          "326_CinB_Vgone"
        }
      },
      {
        Render.FadeScreen,
        {true}
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
          "luc_cat_int"
        }
      },
      {
        RewardsManager.HideStarter,
        {
          "drkwong_cat_int"
        }
      },
      {
        InteriorManager.EnterInterior,
        {"Catacombs"}
      },
      {
        P1M6b.UnloadMembers,
        {self}
      },
      {
        EVENT_Timer,
        {
          "P1M6b.UnloadMembers",
          self,
          1
        }
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

function P1M6b:StreamChars()
  local tPeeps = {
    StarterManager.GetFullPath("skylar_cat_int"),
    StarterManager.GetFullPath("kessler_cat_int"),
    StarterManager.GetFullPath("maria_cat_int"),
    StarterManager.GetFullPath("luc_cat_int")
  }
  EVENT_Stream("P1M6b.Task_CinVGone", self, tPeeps, true)
end

function P1M6b:RunPeeps()
  print("running peeps")
  local hLoc1 = Handle("Missions\\paris_1\\mission_6b\\main\\LOC_GO1")
  local hLoc2 = Handle("Missions\\paris_1\\mission_6b\\main\\LOC_GO2")
  local hLoc3 = Handle("Missions\\paris_1\\mission_6b\\main\\LOC_GO3")
  local hMaria = Handle(self.tInfo.Maria)
  local hKessler = Handle(self.tInfo.Kessler)
  local hSkylar = Handle(self.tInfo.Skylar)
  if hLoc1 and hMaria then
    print(" move maria to loc")
    Nav.MoveToObject(hMaria, hLoc1, 2, true, "P1M6b.SetFacing", self, {hMaria, hSab})
  end
  if hLoc2 and hKessler then
    print(" move kessler to loc")
    Nav.MoveToObject(hKessler, hLoc2, 2, true, "P1M6b.SetFacing", self, {hKessler, hSab})
  end
  if hLoc3 and hSkylar then
    print(" move skylar to loc")
    Nav.MoveToObject(hSkylar, hLoc3, 2, true, "P1M6b.SetFacing", self, {hSkylar, hSab})
  end
end

function P1M6b:SetFacing(vChar, vLoc)
  local hChar = Handle(vChar)
  local hLoc = Handle(vLoc)
  if not hChar and not hLoc then
    Util.Assert(false, "Paris_1_Mission_1B.SetFacing:: hChar or hLoc are nil")
    return
  end
  Actor.SetFacingDir(hChar, hLoc)
end

function P1M6b:Task_TalkToLuc()
  self:CreateTask({
    sName = "Task_TalkToLuc",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Talk",
    sObjectiveTextID = "P1M6b_Text.TalkToLuc",
    bAutoFire = true,
    bInteriorTask = true,
    tTgtInclude = {
      "Missions\\cinematics\\326_cinb_vgone\\Spore_RS_Fighter_SH"
    },
    tOnComplete = {
      {
        self.Task_CinVGone,
        {self}
      }
    }
  })
end

function P1M6b:Task_CinVGone()
  self:CreateTask({
    sName = "Task_CinVGone",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "326_CinB_Vgone",
    bOverrideFade = true,
    tOnActivate = {
      {
        self.RemoveWeapons,
        {self}
      }
    },
    tOnComplete = {
      {
        self.GetOutOfInterior,
        {self}
      }
    }
  })
end

function P1M6b:GetOutOfInterior()
  self:CreateTask({
    sName = "Task_ExitHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "Catacombs",
    bInteriorTask = true,
    tLocators = {},
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
  InteriorManager.ExitInterior("Catacombs", nil, false, false)
end

function P1M6b:CompleteMission()
  Render.FadeScreen(false)
  self.CompleteThisMission(self)
end

function P1M6b:RemoveWeapons()
  local hSkylar = Handle(self.tInfo.Skylar)
  local hLuc = Handle(StarterManager.GetFullPath("luc_cat_int"))
  local h1 = Handle("Missions\\cinematics\\326_cinb_vgone\\Spore_RS_Fighter_SH1")
  local h2 = Handle("Missions\\cinematics\\326_cinb_vgone\\Spore_RS_Fighter_SH2")
  local h3 = Handle("Missions\\cinematics\\326_cinb_vgone\\Spore_RS_Fighter_SH3")
  local h4 = Handle("Missions\\cinematics\\326_cinb_vgone\\Spore_RS_Fighter_SH4")
  local h5 = Handle("Missions\\cinematics\\326_cinb_vgone\\Spore_RS_Fighter_SH5")
  if hSkylar then
    Inventory.RemoveAllWeapons(hSkylar)
  end
  if hLuc then
    Inventory.RemoveAllWeapons(hLuc)
  end
  if h1 then
    Inventory.RemoveAllWeapons(h1)
  end
  if h2 then
    Inventory.RemoveAllWeapons(h2)
  end
  if h3 then
    Inventory.RemoveAllWeapons(h3)
  end
  if h4 then
    Inventory.RemoveAllWeapons(h4)
  end
  if h5 then
    Inventory.RemoveAllWeapons(h5)
  end
end
