if P2FP_MadeleineSniper == nil then
  P2FP_MadeleineSniper = SabTaskObjective:Create()
  P2FP_MadeleineSniper.sPATH = "Missions\\freeplay\\p2\\mis_madeleine_sniper\\"
  P2FP_MadeleineSniper:Configure({
    TaskCount = 99,
    sStarter = "Crochet_ext_whouse",
    sConvFile = "P2FP_MadeleineSniper_Start",
    bFreeplay = true,
    sSaveMissionNameID = "MissionNames_Text.P2FP_MadeleineSniper",
    sActNameID = "MissionNames_Text.ACT_LeCrochet",
    tUnlockList = {
      "NOTE_Pre_Palais"
    },
    bIntStarter = true,
    tSMEDNodes = {
      P2FP_MadeleineSniper.sPATH .. "main",
      P2FP_MadeleineSniper.sPATH .. "res_contact"
    },
    tStaticTags = {
      "p2fp_madeleine_towers"
    }
  })
end

function P2FP_MadeleineSniper:STARTER_Setup()
end

function P2FP_MadeleineSniper:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "MADELEINESNIPER"
  self.bDebugMode = false
  self.sWTFZone = self.sPATH .. "WTF"
  dprint(self, "Running MadeleineSniper.")
  self.GENERAL_Setup(self)
  self:RegisterCheckpoint("P2FP_MadeleineSniper.Checkpoint0")
end

function P2FP_MadeleineSniper.SetupGamepadListener()
  local self = P2FP_MadeleineSniper
  self.tControllerEvent = {
    EventType = "OnButtonPress",
    Target = Handle("Saboteur")
  }
  local eButtonEvent = Util.CreateEvent(self.tControllerEvent, "P2FP_MadeleineSniper.OnButtonPress", self, {}, true)
  self:RegisterEvent(eButtonEvent)
end

function P2FP_MadeleineSniper:OnButtonPress(a_tButtonData)
  local self = P2FP_MadeleineSniper
  local tButtons = a_tButtonData[1]
  if tButtons.UP == true then
  elseif tButtons.DOWN == true then
  elseif tButtons.X == true then
  elseif tButtons.B == true then
  end
end

function P2FP_MadeleineSniper:ArmSelf()
  Inventory.GiveItem(hSab, "WP_PS_WaltherPPK_Silencer", false)
end

function P2FP_MadeleineSniper:GENERAL_Setup()
  self.hSab = Util.GetHandleByName("Saboteur")
  self.sGeneral = self.sPATH .. "general\\Nazi_General"
  self.sLoseEsc = "GetSniperRifle"
  self.sSniperNestLoc = self.sPATH .. "main\\LOC_SniperNest"
  self.sSniperNestArea = self.sPATH .. "main\\TRIG_SniperNest"
  self.sLimoSpawnLoc = self.sPATH .. "main\\LOC_LimoSpawn"
  self.sLimoPath = "Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\Limo1Path"
  self.sWarlordPath = "Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\WarlordPath"
  self.sAFPilotPath = "Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\PATH_AFPilot"
  self.sAFShotgunPath = "Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\PATH_AFShotgun"
  self.sInsideVosges = "Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\PT_InsideVosges"
  self.tNSquad = {
    self.sPATH .. "ambassador\\Ambassador_N",
    self.sPATH .. "ambassador\\Heavy_MG_N1",
    self.sPATH .. "ambassador\\Heavy_MG_N2"
  }
  self.tSSquad = {
    self.sPATH .. "ambassador\\Ambassador_S",
    self.sPATH .. "ambassador\\Heavy_MG_S1",
    self.sPATH .. "ambassador\\Heavy_MG_S2"
  }
  self.tESquad = {
    self.sPATH .. "ambassador\\Ambassador_E",
    self.sPATH .. "ambassador\\Heavy_MG_E1",
    self.sPATH .. "ambassador\\Heavy_MG_E2"
  }
  self.tWSquad = {
    self.sPATH .. "ambassador\\Ambassador_W",
    self.sPATH .. "ambassador\\Heavy_MG_W1",
    self.sPATH .. "ambassador\\Heavy_MG_W2"
  }
  self.tDecoys = {
    self.sPATH .. "ambassador\\Ambassador_N",
    self.sPATH .. "ambassador\\Ambassador_S",
    self.sPATH .. "ambassador\\Ambassador_E",
    self.sPATH .. "ambassador\\Ambassador_W"
  }
  self.tNazis = {
    self.sPATH .. "ambassador\\Heavy_MG_N1",
    self.sPATH .. "ambassador\\Heavy_MG_N2",
    self.sPATH .. "ambassador\\Heavy_MG_S1",
    self.sPATH .. "ambassador\\Heavy_MG_S2",
    self.sPATH .. "ambassador\\Heavy_MG_E1",
    self.sPATH .. "ambassador\\Heavy_MG_E2",
    self.sPATH .. "ambassador\\Heavy_MG_W1",
    self.sPATH .. "ambassador\\Heavy_MG_W2",
    self.sPATH .. "nazis\\Spore_WNZ_Grunt_RF",
    self.sPATH .. "nazis\\Spore_WNZ_Grunt_RF(1)",
    self.sPATH .. "nazis\\Spore_WNZ_Grunt_RF(2)",
    self.sPATH .. "nazis\\Spore_WNZ_Grunt_RF(3)",
    self.sPATH .. "nazis\\Spore_WNZ_Heavy_SH(2)",
    self.sPATH .. "nazis\\Spore_WNZ_Heavy_SH(3)",
    self.sPATH .. "nazis\\Spore_WNZ_Heavy_SH(4)",
    self.sPATH .. "nazis\\Spore_WNZ_Heavy_SH(5)",
    self.sPATH .. "nazis\\Spore_WNZ_Heavy_SH(6)",
    self.sPATH .. "nazis\\Spore_WNZ_Heavy_SH(7)",
    self.sPATH .. "nazis\\Spore_WNZ_Heavy_SH(8)",
    self.sPATH .. "nazis\\Spore_WNZ_Heavy_SH(9)"
  }
  self.tParkbenches = {
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(2)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(2)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(3)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(3)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(4)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(4)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(5)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(5)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(6)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(6)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(7)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(7)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(8)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(8)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(9)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(9)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(10)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(10)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(11)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(11)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(12)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(12)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(13)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(13)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(14)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(14)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(15)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(15)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(16)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(16)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(17)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(17)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(18)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(18)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(19)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(19)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(20)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(20)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(21)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(21)\\AttractionPT_Sit(1)",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(22)\\AttractionPT_Sit",
    "PARIS\\area04\\placedesvosges\\props\\WPOP_Vosges_Bench(22)\\AttractionPT_Sit(1)"
  }
  self:AddOnCancelCallback(P2FP_MadeleineSniper.OnCancel)
  self:AddOnCompleteCallback(P2FP_MadeleineSniper.OnComplete)
end

function P2FP_MadeleineSniper:Sound2()
  Sound.SetMusicLocale("fp_P2FP_MadeleineSniper")
  Sound.SetMusicLocale("fp_P2FP_MadeleineSniper", "postCin")
end

function P2FP_MadeleineSniper:Checkpoint0()
  dprint(self, "Registered: CHECKPOINT 0")
  self:Task_GetSniperRifle()
  self.Task_ExitLaVilletteHQ(self)
end

function P2FP_MadeleineSniper:Task_ExitLaVilletteHQ()
  self:CreateTask({
    sName = "Task_ExitLaVilletteHQ",
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
          "P2FP_MadeleineSniper.CheckPoint1"
        }
      }
    }
  })
end

function P2FP_MadeleineSniper:CheckPoint1()
  if not self:IsMissionTaskActive("P2FP_MadeleineSniper_Task_GetSniperRifle") then
    self:Task_GetSniperRifle()
  end
  self.eContactDeath = EVENT_ActorDeath("P2FP_MadeleineSniper.PlayerKilledContact", self, "Missions\\freeplay\\p2\\mis_madeleine_sniper\\res_contact\\ResContact")
end

function P2FP_MadeleineSniper:Task_GetSniperRifle()
  self:CreateTask({
    sName = "P2FP_MadeleineSniper_Task_GetSniperRifle",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Talk",
    bEscalationDenial = true,
    sObjectiveTextID = "P2FP_MadeleineSniper_Text.Task_GetSniperRifle",
    bWorldBlip = true,
    bHUDBlip = true,
    MarkerHeight = 2.5,
    Proximity = 12,
    vGPSTarget = "Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\LOC_TempGPStarget",
    tTgtInclude = {
      "Missions\\freeplay\\p2\\mis_madeleine_sniper\\res_contact\\ResContact"
    },
    sConvFile = "P2FP_MadeleineSniper_Rifle1",
    tStaticTags = {
      "p2fp_madeleine_res"
    },
    tOnActivate = {
      {
        self.EscalationListener,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TestForRifle,
        {self}
      }
    }
  })
end

function P2FP_MadeleineSniper:TestForRifle()
  local nKarbsInInventory = Inventory.GetCountOfType(hSab, "WP_RF_Karbine_Scope")
  if 1 <= nKarbsInInventory then
    self.RegisterCheckpoint(self, "P2FP_MadeleineSniper.Checkpoint2")
  elseif nKarbsInInventory == 0 then
    self:Task_TakeRifle()
  end
end

function P2FP_MadeleineSniper:Task_TakeRifle()
  self:CreateTask({
    sName = "P2FP_MadeleineSniper_Task_TakeRifle",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Fetch",
    sObjectiveTextID = "P2FP_MadeleineSniper_Text.Task_TakeRifle",
    bBlipLocatorsOnly = true,
    tLocators = {
      "Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\LOC_SniperRifle"
    },
    tDeliverObjs = {
      "Missions\\freeplay\\p2\\mis_madeleine_sniper\\res_props\\WP_RF_Karbine_Scope"
    },
    MarkerHeight = 0.5,
    {},
    tOnActivate = {
      {
        self.CheckForRifle,
        {self}
      },
      {
        self.UpdateCurrentMission0,
        {self}
      }
    },
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "P2FP_MadeleineSniper.Checkpoint2"
        }
      }
    }
  })
end

function P2FP_MadeleineSniper:CheckForRifle()
  if Inventory.HasItem(hSab, Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\res_props\\WP_RF_Karbine_Scope")) then
    self:CompleteTaskByName("P2FP_MadeleineSniper_Task_TakeRifle")
  end
end

function P2FP_MadeleineSniper:Checkpoint2()
  dprint(self, "Registered: CHECKPOINT 2")
  Util.KillEvent(self.eContactDeath)
  self.eContactDeath = EVENT_ActorDeath("P2FP_MadeleineSniper.PlayerKilledContact", self, "Missions\\freeplay\\p2\\mis_madeleine_sniper\\res_contact\\ResContact")
  self:Task_GetToSniperNest()
  self:SniperZoomTut()
end

function P2FP_MadeleineSniper:SniperZoomTut()
  Saboteur.ShowToolTip("TutorialTip_Text.Weapon_Sniper_Zoom")
end

function P2FP_MadeleineSniper:KillEscEvent()
  Util.KillEvent(self.eEscDetect)
  if self.sLoseEsc == "GetSniperRifle" then
    self:Task_GetSniperRifle()
  elseif self.sLoseEsc == "TakeSniperRifle" then
    self:Task_TakeRifle()
  elseif self.sLoseEsc == "GetToSniperNest" then
    self:Task_GetToSniperNest()
  elseif self.sLoseEsc == "FindVantagePoint" then
    self:Task_FindVantagePoint()
  end
end

function P2FP_MadeleineSniper:EscalationListener()
  dprint(self, "Setting Escalation Listener  - clear Esc to get Fade Up/Down")
  if self.eEscDetect then
    Util.KillEvent(self.eEscDetect)
  end
  self.eEscDetect = EVENT_OnEscalation("P2FP_MadeleineSniper.EscSwitchTasks", self, nil, false)
end

function P2FP_MadeleineSniper:EscSwitchTasks()
  if self.sLoseEsc == "GetSniperRifle" then
    dprint(self, "Escalated. Switching to LOSE HEAT task")
    self:ResetTaskByName("P2FP_MadeleineSniper_Task_GetSniperRifle", true)
    self:TASK_LoseEscalation()
  elseif self.sLoseEsc == "TakeSniperRifle" then
    dprint(self, "Escalated. Switching to LOSE HEAT task")
    self:ResetTaskByName("P2FP_MadeleineSniper_Task_TakeRifle", true)
    self:TASK_LoseEscalation()
  elseif self.sLoseEsc == "GetToSniperNest" then
    dprint(self, "Escalated. Switching to LOSE HEAT task")
    self:ResetTaskByName("P2FP_MadeleineSniper_Task_GetToSniperNest", true)
    self:TASK_LoseEscalation()
  elseif self.sLoseEsc == "FindVantagePoint" then
    dprint(self, "Escalated. General has been alerted, fail in 8 seconds")
    self:WaitFirstShot()
    EVENT_Timer("P2FP_MadeleineSniper.FailGeneralRan", self, 8)
  elseif self.sLoseEsc == "KillDecoys" then
    dprint(self, "Escalated. General has been alerted, fail in 8 seconds")
    self:WaitFirstShot()
  elseif self.sLoseEsc == "KillAmbassador" then
    dprint(self, "Escalated. Ambassador is dead, player must escape")
    self:TASK_DEscalate()
    self:WaitFirstShot()
  end
end

function P2FP_MadeleineSniper:TASK_LoseEscalation()
  self:CreateTask({
    sName = "P2FP_MadeleineSniper.TASK_LoseEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    EscalationLevel = 0,
    bRepeatable = true,
    bNoGPS = true,
    bNoRepeatAutoRebuild = true,
    tOnComplete = {
      {
        self.KillEscEvent,
        {self}
      }
    },
    tOnActivate = {
      {
        HUD.ClearGPSTarget,
        {}
      }
    }
  })
end

function P2FP_MadeleineSniper:Task_GetToSniperNest()
  self:CreateTask({
    sName = "P2FP_MadeleineSniper_Task_GetToSniperNest",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tLocators = {
      "Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\LOC_GetToNest"
    },
    tDeliverObjs = {
      self.hSab
    },
    tDestRegion = {
      "Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\PT_GetToNest"
    },
    sObjectiveTextID = "P2FP_MadeleineSniper_Text.Task_GetToSniperNest",
    bGroundBlip = true,
    tSMEDNodes = {
      self.sPATH .. "nazis"
    },
    tStaticTags = {},
    tOnActivate = {
      {
        HUD.SetWaypoint,
        {587.0051, -22.650309}
      },
      {
        self.KillBenchAPsStream,
        {self}
      },
      {
        self.UpdateCurrentMission1,
        {self}
      },
      {
        self.EscalationListener,
        {self}
      },
      {
        self.InitCocktailParty,
        {self}
      }
    },
    tOnCancel = {
      {
        HUD.ClearWaypoint,
        {}
      }
    },
    tOnReset = {
      {
        HUD.ClearWaypoint,
        {}
      }
    },
    tOnComplete = {
      {
        HUD.ClearWaypoint,
        {}
      },
      {
        self.BrakeCar,
        {self}
      },
      {
        self.ClearGPS,
        {self}
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "P2FP_MadeleineSniper.CheckPoint3"
        }
      }
    }
  })
end

function P2FP_MadeleineSniper:ClearGPS()
  HUD.ClearWaypoint()
  HUD.ClearGPSTarget()
end

function P2FP_MadeleineSniper:BrakeCar()
  local hSabCar = Actor.GetVehicle(hSab)
  if hSabCar then
    SabTaskObjectiveDeliver.StopVehicle(self, hSabCar)
  end
end

function P2FP_MadeleineSniper:UnBrakeCar()
  local hSabCar = Actor.GetVehicle(hSab)
  if hSabCar then
    SabTaskObjectiveDeliver.ReleaseVehicle(self, hSabCar)
  end
end

function P2FP_MadeleineSniper:InitCocktailParty()
  EVENT_Stream("P2FP_MadeleineSniper.GoNorthAmbassador", self, self.tNSquad, true)
  EVENT_Stream("P2FP_MadeleineSniper.GoSouthAmbassador", self, self.tSSquad, true)
  EVENT_Stream("P2FP_MadeleineSniper.GoEastAmbassador", self, self.tESquad, true)
  EVENT_Stream("P2FP_MadeleineSniper.GoWestAmbassador", self, self.tWSquad, true)
end

function P2FP_MadeleineSniper:GeneralHit()
  Suspicion.SetEscalated()
  local x, y, z = Actor.GetPosition(self.hGeneral)
  for i, Nazi in pairs(self.tNazis) do
    local hNazi = Handle(Nazi)
    Combat.SetHunt(hNazi, x, y, z, true, false)
  end
  self:EscSwitchTasks()
end

function P2FP_MadeleineSniper:UpdateCurrentMission0()
  self.sLoseEsc = "TakeSniperRifle"
end

function P2FP_MadeleineSniper:UpdateCurrentMission1()
  self.sLoseEsc = "GetToSniperNest"
end

function P2FP_MadeleineSniper:UpdateCurrentMission2()
  self.sLoseEsc = "FindVantagePoint"
end

function P2FP_MadeleineSniper:UpdateCurrentMission3()
  self.sLoseEsc = "KillDecoys"
end

function P2FP_MadeleineSniper:Task_FindVantagePoint()
  self:CreateTask({
    sName = "P2FP_MadeleineSniper_Task_FindVantagePoint",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tLocators = {
      self.sSniperNestLoc
    },
    tDeliverObjs = {
      self.hSab
    },
    tDestRegion = {
      self.sSniperNestArea
    },
    bNoGPS = true,
    sObjectiveTextID = "P2FP_MadeleineSniper_Text.Task_FindVantagePoint",
    tSMEDNodes = {
      self.sPATH .. "ambassador"
    },
    tOnActivate = {
      {
        self.UpdateCurrentMission2,
        {self}
      },
      {
        self.RemoveCivs,
        {self}
      },
      {
        self.EscalationListener,
        {self}
      },
      {
        EVENT_PlayerEntersTrigger,
        {
          "P2FP_MadeleineSniper.DetectInsideVosges",
          self,
          self.sInsideVosges,
          false
        }
      }
    },
    tOnComplete = {
      {
        self.TASK_WaitForMeeting,
        {self}
      }
    }
  })
end

function P2FP_MadeleineSniper:DetectInsideVosges()
  self:CompleteTaskByName("P2FP_MadeleineSniper_Task_FindVantagePoint")
end

function P2FP_MadeleineSniper:RemoveCivs()
  local hTrigger = Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\PT_KillSidewalks")
  local hHumanFilter = Filter.New("!Nazi")
  local tHumans = {}
  if hTrigger then
    tHumans = Trigger.GetAllWithin(hTrigger, hHumanFilter)
  end
  if tHumans and tHumans[1] then
    for i, Civ in pairs(tHumans) do
      local hCiv = Handle(Civ)
      Object.Despawn(hCiv)
    end
  end
  Filter.Delete(hHumanFilter)
end

function P2FP_MadeleineSniper:KillBenchAPsStream()
  EVENT_Stream("P2FP_MadeleineSniper.KillBenchAPs", self, self.tParkbenches, false)
end

function P2FP_MadeleineSniper:KillBenchAPs()
  for i, v in ipairs(self.tParkbenches) do
    local hAttrPt = Util.GetHandleByName(v)
    AttractionPt.EnableBroadcast(hAttrPt, false)
    AttractionPt.EnableUse(hAttrPt, false)
  end
end

function P2FP_MadeleineSniper:CheckPoint3()
  Util.SetDynamicPriority("Human_WM_Grunt_MG", 500)
  Util.EnableSidewalksInRegion(false, "Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\PT_KillSidewalks")
  Util.KillEvent(self.eEscDetect)
  EVENT_Timer("P2FP_MadeleineSniper.UnBrakeCar", self, 1)
  self:Task_FindVantagePoint()
  self.PlayEscTip(self)
  self.bOfficerAlive = true
end

function P2FP_MadeleineSniper:PlayEscTip()
  Saboteur.ShowToolTip("P2FP_MadeleineSniper_Text.TIP_EscFail")
end

function P2FP_MadeleineSniper:TASK_WaitForMeeting()
  self:CreateTask({
    sName = "TASK_WaitForMeeting",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "CIN_MadSniper_Arrive",
    tSMEDNodes = {
      self.sPATH .. "general"
    },
    tStaticTags = {},
    tOnActivate = {
      {
        self.Sound2,
        {self}
      }
    },
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "P2FP_MadeleineSniper.CheckPoint4"
        }
      }
    }
  })
end

function P2FP_MadeleineSniper:CheckPoint4()
  self.HitDetectors(self)
  self.KillEscEvent(self)
  self.GoGeneral(self)
  self.SetupWarlords(self)
  self.nAmbArrived = 0
  self.bFirstShot = true
  self.bOfficerAlive = true
  self.Task_KillDecoys(self)
end

function P2FP_MadeleineSniper:GoGeneral()
  EVENT_Stream("P2FP_MadeleineSniper.InitGeneral", self, self.sGeneral, true)
end

function P2FP_MadeleineSniper:Task_KillDecoys()
  self:CreateTask({
    sName = "P2FP_MadeleineSniper_Task_KillDecoys",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    tTgtInclude = self.tDecoys,
    sObjectiveTextID = "P2FP_MadeleineSniper_Text.Task_KillDecoys",
    tOnActivate = {
      {
        self.UpdateCurrentMission3,
        {self}
      },
      {
        self.EscalationListener,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TASK_DEscalate,
        {self}
      }
    }
  })
end

function P2FP_MadeleineSniper:Task_KillOfficer()
  self:KillTaskByName("P2FP_MadeleineSniper_Task_KillDecoys")
  self:CreateTask({
    sName = "P2FP_MadeleineSniper_Task_KillOfficer",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    tTgtInclude = self.tDecoys,
    sObjectiveTextID = "P2FP_MadeleineSniper_Text.Task_KillOfficer",
    tOnActivate = {
      {
        Cin.PlayConversation,
        {
          "P2FP_MadeleineSniper_Decoys3"
        }
      }
    },
    tOnComplete = {
      {
        Cin.PlayConversation,
        {
          "P2FP_MadeleineSniper_Killed"
        }
      },
      {
        self.TASK_DEscalate,
        {self}
      }
    }
  })
end

function P2FP_MadeleineSniper:OfficerIsDead()
  self.bOfficerAlive = false
end

function P2FP_MadeleineSniper:TASK_DEscalate()
  self:CreateTask({
    sName = "TASK_DEscalate",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    EscalationLevel = 0,
    tOnComplete = {
      {
        self.DoComplete,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function P2FP_MadeleineSniper:InitGeneral()
  self.hGeneral = Handle(self.sGeneral)
  EVENT_ActorDamaged("P2FP_MadeleineSniper.GeneralHit", self, self.hGeneral)
  Combat.SetIdleScripted(self.hGeneral, true)
  Actor.EnableNeeds(self.hGeneral, false)
  Nav.SetScriptedPath(self.hGeneral, "Missions\\freeplay\\p2\\mis_madeleine_sniper\\general\\PATH_GeneralIn", true)
  EVENT_ActorToActorProximity("P2FP_MadeleineSniper.StartConvoSequence", self, Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\ambassador\\Ambassador_S"), self.hGeneral, 2)
  EVENT_ActorToActorProximity("P2FP_MadeleineSniper.EverybodyMeets", self, Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\ambassador\\Ambassador_S"), self.hGeneral, 20)
end

function P2FP_MadeleineSniper:EverybodyMeets()
  Nav.MoveToObject(self.hNAmbassador, Handle(self.sGeneral), 2)
  Nav.MoveToObject(self.hEAmbassador, Handle(self.sGeneral), 2)
  Nav.MoveToObject(self.hSAmbassador, Handle(self.sGeneral), 2)
  Actor.CancelAttrPt(self.hWAmbassador)
  Nav.MoveToObject(self.hWAmbassador, Handle(self.sGeneral), 2)
end

function P2FP_MadeleineSniper:GoNorthAmbassador()
  Util.SetDynamicPriority("Human_NZ_Ambassador_FP", 500)
  self.hNAmbassador = Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\ambassador\\Ambassador_N")
  self.hNHeavy1 = Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\ambassador\\Heavy_MG_N1")
  self.hNHeavy2 = Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\ambassador\\Heavy_MG_N2")
  Combat.SetIdleScripted(self.hNAmbassador, true)
  Nav.SetScriptedPath(self.hNAmbassador, "Missions\\freeplay\\p2\\mis_madeleine_sniper\\ambassador\\PATH_GeneralPaces")
  Nav.SetScriptedPathType(self.hNAmbassador, cPATHTYPE_LOOP)
  Nav.FollowObject(self.hNHeavy1, self.hNAmbassador, 1, false)
  Nav.FollowObject(self.hNHeavy2, self.hNAmbassador, 2, false)
end

function P2FP_MadeleineSniper:GoSouthAmbassador()
  Util.SetDynamicPriority("Human_NZ_Ambassador_FP", 500)
  self.hSAmbassador = Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\ambassador\\Ambassador_S")
  self.hSHeavy1 = Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\ambassador\\Heavy_MG_S1")
  self.hSHeavy2 = Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\ambassador\\Heavy_MG_S2")
  Combat.SetIdleScripted(self.hSAmbassador, true)
  Actor.PlayAnimation(self.hSAmbassador, "civ_M_Smoke_LoopB", -1, true)
end

function P2FP_MadeleineSniper:GoEastAmbassador()
  Util.SetDynamicPriority("Human_NZ_Ambassador_FP", 500)
  self.hEAmbassador = Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\ambassador\\Ambassador_E")
  self.hEHeavy1 = Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\ambassador\\Heavy_MG_E1")
  self.hEHeavy2 = Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\ambassador\\Heavy_MG_E2")
  Combat.SetIdleScripted(self.hEAmbassador, true)
  Actor.RequestAttrPt(self.hEAmbassador, Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\ambassador\\AttractionPT_drunk_sick"))
  Nav.FollowObject(self.hEHeavy1, self.hEAmbassador, 1, false)
  Nav.FollowObject(self.hEHeavy2, self.hEAmbassador, 2, false)
end

function P2FP_MadeleineSniper:GoWestAmbassador()
  Util.SetDynamicPriority("Human_NZ_Ambassador_FP", 500)
  self.hWAmbassador = Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\ambassador\\Ambassador_W")
  self.hWHeavy1 = Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\ambassador\\Heavy_MG_W1")
  self.hWHeavy2 = Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\ambassador\\Heavy_MG_W2")
  Combat.SetIdleScripted(self.hWAmbassador, true)
  local hAttrPt = Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\ambassador\\AttractionPT_Sitforever")
  AttractionPt.EnableBroadcast(hAttrPt, true)
  AttractionPt.EnableUse(hAttrPt, true)
  Actor.RequestAttrPt(self.hWAmbassador, hAttrPt)
end

function P2FP_MadeleineSniper:SetupWarlords()
  self.hWarlord = self.hSAmbassador
  self.tWarlords = {
    self.hNAmbassador,
    self.hSAmbassador,
    self.hEAmbassador,
    self.hWAmbassador
  }
  EVENT_ActorDeath("P2FP_MadeleineSniper.KilledTarget", self, self.hWarlord)
end

function P2FP_MadeleineSniper:KilledTarget()
  if self:IsMissionTaskActive("P2FP_MadeleineSniper_Task_KillDecoys") then
    self:KillTaskByName("P2FP_MadeleineSniper_Task_KillDecoys")
  elseif self:IsMissionTaskActive("P2FP_MadeleineSniper_Task_KillOfficer") then
    self:KillTaskByName("P2FP_MadeleineSniper_Task_KillOfficer")
  end
  Util.KillEvent(self.eNAmbEscape)
  Util.KillEvent(self.eSAmbEscape)
  Util.KillEvent(self.eEAmbEscape)
  Util.KillEvent(self.eWAmbEscape)
  self.sLoseEsc = "KillAmbassador"
  self.bOfficerAlive = false
  local x, y, z = Actor.GetPosition(self.hWarlord)
  for i, Nazi in pairs(self.tNazis) do
    local hNazi = Handle(Nazi)
    Combat.SetHunt(hNazi, x, y, z, true, false)
  end
  self:TASK_DEscalate()
end

function P2FP_MadeleineSniper:StartConvoSequence()
  local tWarlordSeq = {
    {
      "TURNTOFACE",
      {
        self.hGeneral
      }
    },
    {
      "PLAYANIMATION",
      {"nazi_hail"}
    },
    {
      "TURNTOFACE",
      {
        self.hGeneral
      }
    },
    {
      "DELAY",
      {3}
    },
    {
      "PLAYCONVERSATION",
      {
        "P2FP_MadeleineSniper_SeeGen"
      }
    },
    {
      "PLAYANIMATION",
      {"nazi_hail"}
    },
    {
      "TURNTOFACE",
      {
        self.hGeneral
      }
    },
    {
      "DELAY",
      {9}
    },
    {
      "CANCELANIMATION"
    }
  }
  local tGeneralSeq = {
    {
      "TURNTOFACE",
      {
        self.hSAmbassador
      }
    },
    {
      "PLAYANIMATION",
      {"nazi_hail"}
    },
    {
      "TURNTOFACE",
      {
        self.hSAmbassador
      }
    },
    {
      "DELAY",
      {3}
    },
    {
      "PLAYANIMATION",
      {"nazi_hail"}
    },
    {
      "TURNTOFACE",
      {
        self.hSAmbassador
      }
    },
    {
      "DELAY",
      {3}
    },
    {
      "CANCELANIMATION"
    }
  }
  ScriptSequence.Run(self.hGeneral, tGeneralSeq)
  ScriptSequence.Run(self.hSAmbassador, tWarlordSeq)
  self:Task_KillOfficer()
end

function P2FP_MadeleineSniper:PlayKillConvo()
  Cin.PlayConversation("P2FP_MadeleineSniper_HitGen")
end

function P2FP_MadeleineSniper:HitDetectors()
  EVENT_ActorDamaged("P2FP_MadeleineSniper.WaitFirstShot", self, self.hNAmbassador)
  EVENT_ActorDamaged("P2FP_MadeleineSniper.WaitFirstShot", self, self.hSAmbassador)
  EVENT_ActorDamaged("P2FP_MadeleineSniper.WaitFirstShot", self, self.hEAmbassador)
  EVENT_ActorDamaged("P2FP_MadeleineSniper.WaitFirstShot", self, self.hWAmbassador)
end

function P2FP_MadeleineSniper:WaitFirstShot()
  EVENT_Timer("P2FP_MadeleineSniper.CheckFirstShot", self, 1)
end

function P2FP_MadeleineSniper:CheckFirstShot()
  if self.bFirstShot then
    ScriptSequence.Kill(self.hNAmbassador)
    Nav.CancelScriptedPath(self.hNAmbassador)
    Combat.SetIdleScripted(self.hNAmbassador, true)
    Suspicion.Enable(self.hNAmbassador, false)
    Combat.SetRespondToEvents(self.hNAmbassador, false)
    Combat.SetRespondToSound(self.hNAmbassador, false)
    Combat.SetRespondToDamage(self.hNAmbassador, false)
    Actor.SetPanicEnabled(self.hNAmbassador, false)
    Actor.EnableNeeds(self.hNAmbassador, false)
    Nav.MoveToObject(self.hNAmbassador, Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\LOC_NorthRuns"), 1, cMOVE_PANIC)
    self.eNAmbEscape = EVENT_ActorEntersTrigger("P2FP_MadeleineSniper.NAmbassadorEscaped", self, self.hNAmbassador, "Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\PT_NorthRuns")
    ScriptSequence.Kill(self.hSAmbassador)
    Nav.CancelScriptedPath(self.hSAmbassador)
    Combat.SetIdleScripted(self.hSAmbassador, true)
    Actor.OverrideCombatAI(self.hSAmbassador, true)
    Nav.MoveToObject(self.hSAmbassador, Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\LOC_SouthRuns"), 1, cMOVE_PANIC)
    self.eSAmbEscape = EVENT_ActorEntersTrigger("P2FP_MadeleineSniper.SAmbassadorEscaped", self, self.hSAmbassador, "Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\PT_SouthRuns")
    ScriptSequence.Kill(self.hEAmbassador)
    Nav.CancelScriptedPath(self.hENAmbassador)
    Combat.SetIdleScripted(self.hEAmbassador, true)
    Suspicion.Enable(self.hEAmbassador, false)
    Combat.SetRespondToEvents(self.hEAmbassador, false)
    Combat.SetRespondToSound(self.hEAmbassador, false)
    Combat.SetRespondToDamage(self.hEAmbassador, false)
    Actor.SetPanicEnabled(self.hEAmbassador, false)
    Actor.EnableNeeds(self.hEAmbassador, false)
    Nav.MoveToObject(self.hEAmbassador, Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\LOC_EastRuns"), 1, cMOVE_PANIC)
    self.eEAmbEscape = EVENT_ActorEntersTrigger("P2FP_MadeleineSniper.EAmbassadorEscaped", self, self.hEAmbassador, "Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\PT_EastRuns")
    ScriptSequence.Kill(self.hWAmbassador)
    Nav.CancelScriptedPath(self.hWAmbassador)
    Combat.SetIdleScripted(self.hWAmbassador, true)
    Suspicion.Enable(self.hWAmbassador, false)
    Combat.SetRespondToEvents(self.hWAmbassador, false)
    Combat.SetRespondToSound(self.hWAmbassador, false)
    Combat.SetRespondToDamage(self.hWAmbassador, false)
    Actor.SetPanicEnabled(self.hWAmbassador, false)
    Actor.EnableNeeds(self.hWAmbassador, false)
    Nav.MoveToObject(self.hWAmbassador, Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\LOC_WestRuns"), 1, cMOVE_PANIC)
    self.eWAmbEscape = EVENT_ActorEntersTrigger("P2FP_MadeleineSniper.WAmbassadorEscaped", self, self.hWAmbassador, "Missions\\freeplay\\p2\\mis_madeleine_sniper\\main\\PT_WestRuns")
    ScriptSequence.Kill(self.hGeneral)
    Combat.SetIdleScripted(self.hGeneral, true)
    Actor.EnableNeeds(self.hGeneral, false)
    Nav.SetScriptedPath(self.hGeneral, self.sGeneralExitPath)
    Nav.SetScriptedPathMoveMode(self.hGeneral, cMOVE_PANIC)
    Suspicion.SetEscalated()
    self.bFirstShot = false
  end
end

function P2FP_MadeleineSniper:DoComplete()
  self:CompleteThisMission()
end

function P2FP_MadeleineSniper:SendCrochetAttrpt()
  local hCrochet = Util.GetHandleByName("Missions\\paris_1\\characters\\lavillette\\couteau_interior\\Couteau_LaVillette_Interior")
  local hCrochetAttrpt = Util.GetHandleByName("Missions\\paris_1\\characters\\lavillette\\couteau_interior\\AIAttractionPt_LookatMap")
  Actor.UseAttrPt(hCrochet, hCrochetAttrpt)
end

function P2FP_MadeleineSniper:AbandonAttrPt()
  self = P2FP_MadeleineSniper
  local hCrochetAttrpt = Util.GetHandleByName("Missions\\paris_1\\characters\\lavillette\\couteau_interior\\AIAttractionPt_LookatMap")
  AttractionPt.FinishNow(hCrochetAttrpt)
end

function P2FP_MadeleineSniper:PlayMissConvo()
  Cin.PlayConversation("P2FP_MadeleineSniper_MissGen")
end

function P2FP_MadeleineSniper:NAmbassadorEscaped()
  if self.bOfficerAlive == true and Object.IsAlive(self.hNAmbassador) then
    self:MissionTaskFail("P2FP_MadeleineSniper_Text.Fail_TargetEscaped")
  end
end

function P2FP_MadeleineSniper:SAmbassadorEscaped()
  if self.bOfficerAlive == true and Object.IsAlive(self.hSAmbassador) then
    self:MissionTaskFail("P2FP_MadeleineSniper_Text.Fail_TargetEscaped")
  end
end

function P2FP_MadeleineSniper:EAmbassadorEscaped()
  if self.bOfficerAlive == true and Object.IsAlive(self.hEAmbassador) then
    self:MissionTaskFail("P2FP_MadeleineSniper_Text.Fail_TargetEscaped")
  end
end

function P2FP_MadeleineSniper:WAmbassadorEscaped()
  if self.bOfficerAlive == true and Object.IsAlive(self.hWAmbassador) then
    self:MissionTaskFail("P2FP_MadeleineSniper_Text.Fail_TargetEscaped")
  end
end

function P2FP_MadeleineSniper:PlayerKilledContact()
  self:MissionTaskFail("P2FP_MadeleineSniper_Text.Fail_KilledContact")
end

function P2FP_MadeleineSniper:FailGeneralRan()
  if self.bOfficerAlive == true then
    self:MissionTaskFail("P2FP_MadeleineSniper_Text.Fail_GeneralRan")
  end
end

function P2FP_MadeleineSniper:OnCancel()
  Inventory.DetachItem(hSab, Handle("Missions\\freeplay\\p2\\mis_madeleine_sniper\\res_props\\WP_RF_Karbine_Scope"), true)
  Sound.ResetMusicLocale()
  HUD.ClearWaypoint()
end

function P2FP_MadeleineSniper:OnComplete()
  Sound.ResetMusicLocale()
  HUD.ClearWaypoint()
end
