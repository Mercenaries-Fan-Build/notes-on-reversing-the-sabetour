if Paris_2_Mission_5 == nil then
  Paris_2_Mission_5 = SabTaskObjective:Create()
  gsP2M5Dir = "Missions\\paris_2\\mission_5\\"
  Paris_2_Mission_5:Configure({
    TaskCount = "auto",
    sStarter = "HDV_Starter",
    tUnlockList = {"P2M5b"},
    sConvFile = "P2M5_Start",
    sSaveMissionNameID = "MissionNames_Text.P2M5",
    bEscalationDenial = true,
    sHQNextMissionStartPoint = _cHQe_HDV,
    tSMEDNodes = {
      gsP2M5Dir .. "hotel_entrance",
      gsP2M5Dir .. "sound"
    },
    tDisabledMissionsList = {},
    tStaticTags = {
      "HDV_Mission"
    }
  })
end

function Paris_2_Mission_5:STARTER_Setup()
end

function Paris_2_Mission_5:Activated()
  SabTaskObjective.Activated(self)
  self:GENERAL_Setup()
  self:RegisterCheckpoint("Paris_2_Mission_5.Checkpoint0")
  Sound.ActivateSoundEmitter(Handle("Missions\\paris_2\\mission_5\\sound\\P2M5_boilerGood_01"))
  Sound.ActivateSoundEmitter(Handle("Missions\\paris_2\\mission_5\\sound\\P2M5_boilerGood_02"))
end

function Paris_2_Mission_5:GENERAL_Setup()
  self._tSpawners = {}
  self.tInfo.sFrannie = gsP2M5Dir .. "frannie\\Franziska"
  self.tInfo.InteriorFrannie = gsP2M5Dir .. "interiorfrannie\\frannie_int"
  self.tInfo.sPrisoner = gsP2M5Dir .. "interiorfrannie\\prisoner_int"
  self.tInfo.sArenaPrisoner = gsP2M5Dir .. "exteriormaria\\Arena_Maria"
  self.tInfo.TerrorA = gsP2M5Dir .. "terrortrap\\TerrorA"
  self.tInfo.TerrorAAA = gsP2M5Dir .. "terrortrap\\TerrorAAA"
  self.tInfo.TerrorB = gsP2M5Dir .. "terrortrap\\TerrorB"
  self.tInfo.TerrorC = gsP2M5Dir .. "terrortrap\\TerrorC"
  self.tInfo.NoteOfficer = gsP2M5Dir .. "main\\NoteOfficer"
  self.tInfo.DoorNazi = gsP2M5Dir .. "boilerdoornazi\\doornazi"
  self.tInfo.SecretBook = "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\SecretBook"
  self.tInfo.SecretNazi = gsP2M5Dir .. "hdv_nazi_patrol\\SecretDoorNazi"
  self.tInfo.sCollapseLoc1 = gsP2M5Dir .. "main\\LOC_Collapse1"
  self.tInfo.sCollapseLoc11 = gsP2M5Dir .. "main\\LOC_Collapse11"
  self.tInfo.sCollapseLoc2 = gsP2M5Dir .. "main\\LOC_Collapse2"
  self.tInfo.sCollapseLoc3 = gsP2M5Dir .. "main\\LOC_Collapse3"
  self.tInfo.sCollapseLoc4 = gsP2M5Dir .. "main\\LOC_Collapse4"
  self.tInfo.sCollapseLoc44 = gsP2M5Dir .. "main\\LOC_Collapse44"
  self.tInfo.sCollapseLoc444 = gsP2M5Dir .. "main\\LOC_Collapse444"
  self.tInfo.sCollapseLoc5 = gsP2M5Dir .. "main\\LOC_Collapse5"
  self.tInfo.sCollapseLoc55 = gsP2M5Dir .. "main\\LOC_Collapse55"
  self.tInfo.sCollapseLocElevator = gsP2M5Dir .. "main\\LOC_CollapseElevator"
  self.tInfo.sSeanRescuesAnneke = __UtilFunctions.UsefulAnimCatcher[6]
  self.tInfo.sSeanRescuesAnneke2 = __UtilFunctions.UsefulAnimCatcher[7]
  self.tInfo.Boiler_Left = "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\OccMed_Boiler_A\\OccMed_Boiler_A"
  self.tInfo.Boiler_Right = "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\OccMed_Boiler_Open\\OccMed_Boiler_A"
  self.tInfo.BoilerBoxSwitch = gsP2M5Dir .. "special\\BoilerRoomBox\\Switch"
  self.tInfo.LobbyBoxSwitch = gsP2M5Dir .. "special\\LobbyBox\\Switch"
  self.tInfo.ElevatorBoxSwitch = gsP2M5Dir .. "special\\ElevatorBox\\Switch"
  self.tInfo.FireElevator = "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_Elevator(2)\\GHotel_Elevator_Door\\DoorTriggerPoint"
  self.tInfo.EscapeElevatorDoor = "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_Elevator\\GHotel_Elevator_Door\\AnimatedObject_GHotel_Elevator_Panel(1)"
  self.tInfo.ExteriorElevatorReg = gsP2M5Dir .. "frannie\\PT_InElevator"
  self.tInfo.ExteriorElevatorDoor = "PARIS\\area06\\hoteldeville\\buildings\\MN_HotelDeVille(2)\\AO MN_HDVille_Prop_Elevator_Door(1)"
  self.tInfo.HicksDoor = "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\CellDoorSpecial\\CellDoor"
  self.tInfo.Hicks = gsP2M5Dir .. "main\\Hicks"
  self.tInfo.CellGates = {
    self.tInfo.HicksDoor,
    "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\Bunker_SlideDoor_Single_A(4)\\Bunker_SlideDoor_Single_A",
    "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\Bunker_SlideDoor_Single_A(3)\\Bunker_SlideDoor_Single_A",
    "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\Bunker_SlideDoor_Single_A\\Bunker_SlideDoor_Single_A",
    "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\Bunker_SlideDoor_Single_A(2)\\Bunker_SlideDoor_Single_A",
    "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\Bunker_SlideDoor_Single_A(6)\\Bunker_SlideDoor_Single_A",
    "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\Bunker_SlideDoor_Single_A\\Bunker_SlideDoor_Single_A"
  }
  self.tInfo.tFranEvents = {}
  self.tSaveInfo.MyMidMissionLoadedNodes = {}
  self.tInfo.Terrors = {
    self.tInfo.TerrorA,
    self.tInfo.TerrorAAA,
    self.tInfo.TerrorC
  }
  self.tInfo.TerrorsSquadA = {
    self.tInfo.TerrorA,
    self.tInfo.TerrorAAA
  }
  self.tInfo.TerrorsSquadB = {
    self.tInfo.TerrorC
  }
  self.tSaveInfo.BoilerSplode = 0
  self.tInfo.FireNazis = {
    gsP2M5Dir .. "inferno_nazis\\ImmolateMe1",
    gsP2M5Dir .. "inferno_nazis\\ImmolateMe2",
    gsP2M5Dir .. "inferno_nazis\\ImmolateMe3"
  }
  self.tInfo.ElevatorNazis = {
    gsP2M5Dir .. "inferno_nazis\\ElevatorNazi1",
    gsP2M5Dir .. "inferno_nazis\\ElevatorNazi2"
  }
  self.tInfo.WTFComplete = "WtF_Zones\\global\\P2M5_BoilingPoint"
  self:AddOnCancelCallback(Paris_2_Mission_5.Reset)
  self:AddOnCompleteCallback(Paris_2_Mission_5.Reset)
  self.tSaveInfo.bBoilerDoorSplode = false
  self.tSaveInfo.bFineSummon = true
  self.tSaveInfo.bSummonDelay = true
  self.tSaveInfo.bUpdateLock = false
  self.tSaveInfo.bPlayerInElevator = false
  self.tSaveInfo.bElevatorDead = false
  self.tSaveInfo.bCloseFrannieElevator = false
  self.tSaveInfo.ElevatorSpawnTotalTimes = 0
  self.tSaveInfo.SpawnNaziTotal = 0
  self.tInfo.MAXLiveSpawnNazis = 2
  self.tSaveInfo.NaziExit = 0
  self.tSaveInfo.bABoilerDeath = false
  self.tSaveInfo.bWireLine = false
  self.tSaveInfo.bMeanSean = false
  self.tSaveInfo.bHicksSeq = false
  self.tInfo.Statue = "PARIS\\area06\\hoteldeville\\buildings\\Dierker_Statue\\AO MN_HDVille_Prop_Statue"
  self.tInfo.AreaDAM = "PARIS\\area06\\hoteldeville\\buildings\\l_wtf\\MN_HDVille_PTH_Floor_Dam"
  self.DT = 0
  self.tSaveInfo.bRamboEntrance = false
  self.tInfo.EscapeElevator = "PARIS\\area06\\hoteldeville\\buildings\\l_wtf\\OccLt_Elevator_6s\\OccLt_Elevator_6s_4x2z"
  Util.EnableSuperSpores(false)
  self.tSaveInfo.bGotOnWire = false
  self.tSaveInfo.bInteriorEscalated = false
  self.ConvManager = ConvManager.CreateNewManager()
  self:AddConvs()
end

function Paris_2_Mission_5:AddConvs()
  local AConv = {
    sConvName = "P2M5_HDV_Entered",
    Priority = 30
  }
  self.ConvManager:AddConv(AConv)
  local AConv = {
    sConvName = "P2M5_IntruderAlert_Loudspeaker",
    Priority = 88,
    bKillOtherConv = true,
    bPlayOverOther = true,
    bBrute = true
  }
  self.ConvManager:AddConv(AConv)
  local AConv = {
    sConvName = "P2M5_IntruderAlert_TopFloorNazi",
    Priority = 88,
    bKillOtherConv = true,
    bPlayNoMatterWhat = true
  }
  self.ConvManager:AddConv(AConv)
  local AConv = {
    sConvName = "P2M5_amb_NazisinLibrary",
    Priority = 10,
    bEscalationDenial = true
  }
  self.ConvManager:AddConv(AConv)
  local AConv = {
    sConvName = "P2M5_amb_NazisinHallway",
    Priority = 10,
    bEscalationDenial = true
  }
  self.ConvManager:AddConv(AConv)
  local AConv = {
    sConvName = "P2M5_SeesTelephoneWire",
    Priority = 10
  }
  self.ConvManager:AddConv(AConv)
  local AConv = {
    sConvName = "P2M5_TopFloorNaziYelling",
    Priority = 20
  }
  self.ConvManager:AddConv(AConv)
end

function Paris_2_Mission_5:HeartBeat(DT)
end

function Paris_2_Mission_5:Reset()
  Sound.ReleaseSoundBank("m_P2M5_inGame.bnk")
  Sound.ReleaseSoundBank("m_P2M5_inGame_02.bnk")
  EVENT_Timer("Saboteur.LoadVehBank", nil, 1)
  Sound.ResetMusicLocale()
  self:PurgeSpawners()
  Sound.ResetMusicLocale()
  Suspicion.EnableEscalation(true)
  self:ReleaseChewZeppelin()
  self:DeleteWireFocus()
  Sound.EnableAllChatter()
  if not Vehicle.IsTrafficEnabled() then
    Vehicle.EnableTraffic(true)
  end
  Sound.DeactivateSoundEmitter(Handle("Missions\\paris_2\\mission_5\\sound\\P2M5_BoilerExplo"))
  Sound.DeactivateSoundEmitter(Handle("Missions\\paris_2\\mission_5\\sound\\P2M5_lobbyFirePoints_boilerRoom"))
  Util.EnableSuperSpores(true)
  Util.SetDynamicPriority("Human_RS_Maria", -1)
  Util.SetDynamicPriority("Human_NZ_Franziska", -1)
  self.ConvManager:Delete()
  self.ConvManager = nil
end

function Paris_2_Mission_5:MISSION_ONCANCEL()
  print("resetting lwf")
  Zone.SwitchState(self.tInfo.WTFComplete, cZONESTATE_LOWWTF, cENT_IMMEDIATE)
  WorldSMEDNodes.UnloadNode(gsP2M5Dir .. "exteriormaria", true)
end

function Paris_2_Mission_5:MISSION_ONCOMPLETE()
  _gb_P2M5_MariaPlayThrough = true
end

function Paris_2_Mission_5:PurgeSpawners()
  if self._tSpawners then
    for _, oSpawner in pairs(self._tSpawners) do
    end
    for _, oSpawner in pairs(self._tSpawners) do
    end
    self._tSpawners = {}
  end
  if self._FranSpawners then
    for _, oSpawner in pairs(self._FranSpawners) do
      print("p2m5 purge spawners")
      oSpawner:Purge()
    end
    for _, oSpawner in pairs(self._FranSpawners) do
      print("p2m5 delete spawners")
      oSpawner:Delete()
    end
    self._FranSpawners = {}
  end
  local hSpawner = Handle("Missions\\paris_2\\mission_5\\hdv_nazi_patrol\\BasementSpawner2")
  if hSpawner then
    Object.SpawnerPurge(hSpawner, true)
  end
  local hSpawner = Handle("Missions\\paris_2\\mission_5\\hdv_nazi_patrol\\BasementSpawner1")
  if hSpawner then
    Object.SpawnerPurge(hSpawner, true)
  end
end

function Paris_2_Mission_5:StopSpawners()
  if self._tSpawners then
    for _, oSpawner in pairs(self._tSpawners) do
      oSpawner:StopSpawner()
    end
  end
  if self._FranSpawners then
    for _, oSpawner in pairs(self._FranSpawners) do
      oSpawner:StopSpawner()
    end
  end
end

function Paris_2_Mission_5:Checkpoint0()
  print("------Checkpoint 0")
  self.tSaveInfo.bWireConv = false
  self:Task_ParentFind()
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.WireFocus", self, "Missions\\paris_2\\mission_5\\hotel_entrance\\REG_SeeWire")
end

function Paris_2_Mission_5:Task_ParentFind()
  self:CreateTask({
    sName = "Task_ParentFind",
    sTaskType = "SabTaskObjectiveEmpty",
    tOnActivate = {
      {
        self.CPFunctionActivation,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:Checkpoint1()
  print("------Checkpoint 1")
  if not self:IsMissionTaskActive("Task_ParentFind") then
    self:Task_ParentFind()
  end
  self:TASK_ExteriorEscalator()
  Sound.SetMusicLocale("P2M5_BoilingPoint")
  Sound.SetMusicLocale("m_P2M5_BoilingPoint", "arriveAtHotel")
  self:Task_CinWire()
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.WireFocus", self, "Missions\\paris_2\\mission_5\\hotel_entrance\\REG_SeeWire")
end

function Paris_2_Mission_5:Task_GotoHDV()
  self:CreateTask({
    sName = "Task_GotoHDV",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P2M5_Text.GotoHotel",
    tDestRegion = {
      gsP2M5Dir .. "hotel_entrance\\REG_HDV2"
    },
    MarkerHeight = 0.5,
    tLocators = {
      gsP2M5Dir .. "hotel_entrance\\LOC_HDV"
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Paris_2_Mission_5.Checkpoint1"
        }
      }
    },
    tOnActivate = {},
    tOnCancel = {}
  })
end

function Paris_2_Mission_5:Task_HDVFront()
  self:CreateTask({
    sName = "Task_HDVFront",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsP2M5Dir .. "hotel_entrance\\REG_HDV"
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Paris_2_Mission_5.Checkpoint1"
        }
      }
    },
    tOnActivate = {},
    tOnCancel = {}
  })
end

function Paris_2_Mission_5:CPFunctionActivation()
  local sCPName = self:GetCheckpointName()
  print("CPFunctionActivation: checkpoint name = ", sCPName)
  if sCPName == "Paris_2_Mission_5.Checkpoint0" then
    self:Task_GotoHDV()
    self:TASK_EnterSafety()
    self:TASK_GotOnWire()
  elseif sCPName == "Paris_2_Mission_5.Checkpoint1" then
    self:TASK_GotOnWire()
  elseif sCPName == "Paris_2_Mission_5.Checkpoint2" then
    self:TASK_FindLibrary()
  elseif sCPName == "Paris_2_Mission_5.Checkpoint3" then
    self:Task_FindCaptiveCell()
  end
end

function Paris_2_Mission_5:SetupWireFocusPt()
  if self.tSaveInfo.bWireLine then
    print("focus wire event has already fired")
    return
  end
  print("setup wire focus")
  local hLoc = Handle(gsP2M5Dir .. "hotel_entrance\\LOC_WireFocus")
  local x, y, z
  if hLoc then
    x, y, z = Object.GetPosition(hLoc)
    self.tSaveInfo.FID = FocusPt.Create(0, 0, 0, 50, 1000, true, true, hLoc, Cin.GetLocalizedText("P2M5_Text.TelephoneWire"))
    FocusPt.SetOnFocusCallback(self.tSaveInfo.FID, "Paris_2_Mission_5.WireFocus", self)
  end
  EVENT_PlayerExitsTrigger("Paris_2_Mission_5.ExitWireArea", self, gsP2M5Dir .. "hotel_entrance\\REG_HDV2")
end

function Paris_2_Mission_5:WireFocus()
  if not self.tSaveInfo.bWireConv then
    self.tSaveInfo.bWireConv = true
    self.ConvManager:PlayConv("P2M5_SeesTelephoneWire")
  end
end

function Paris_2_Mission_5:ExitWireArea()
  print("player exits wire area")
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.SetupWireFocusPt", self, gsP2M5Dir .. "hotel_entrance\\REG_HDV2")
  self:DeleteWireFocus()
end

function Paris_2_Mission_5:DeleteWireFocus()
  if self.tSaveInfo.FID then
    print("deleting wire focus")
    FocusPt.Delete(self.tSaveInfo.FID)
    self.tSaveInfo.FID = nil
  end
end

function Paris_2_Mission_5:Task_CinWire()
  if not self.tSaveInfo.bGotOnWire then
    self:CreateTask({
      sName = "Task_CinWire",
      sTaskType = "SabTaskObjectiveInteract",
      sTaskSubType = "cinematic",
      sCinFile = "CIN_P2M5Wire",
      tOnActivate = {},
      tOnComplete = {
        {
          self.KillTaskByName,
          {
            self,
            "TASK_EnterSafety"
          }
        },
        {
          self.Task_EnterMainHotel,
          {self}
        }
      }
    })
  else
    self:Task_EnterMainHotel()
  end
end

function Paris_2_Mission_5:TASK_GotOnWire()
  self:CreateTask({
    sName = "TASK_GotOnWire",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsP2M5Dir .. "hotel_entrance\\REG_Wire"
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.SetGotOnWire,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Paris_2_Mission_5:SetGotOnWire()
  self.tSaveInfo.bGotOnWire = true
end

function Paris_2_Mission_5:TASK_EnterSafety()
  self:CreateTask({
    sName = "TASK_EnterSafety",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "deliver",
    bInteriorTask = true,
    bNoHUDBlip = true,
    bNoFocus = true,
    tDestRegion = {
      "Missions\\paris_2\\mission_5\\hotel_entrance\\REG_SafetyEntry"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.DeleteWireFocus,
        {self}
      },
      {
        self.KillTaskByName,
        {
          self,
          "Task_GotoHDV"
        }
      },
      {
        self.Task_EnterMainHotel,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:Task_EnterMainHotel()
  self:CreateTask({
    sName = "Task_EnterMainHotel",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "EnterInterior",
    sObjectiveTextID = "P2M5_Text.EnterHQ",
    ParentObjectID = self:GetTaskObjectiveID("Task_ParentFind"),
    sInteriorName = "HDV",
    MarkerHeight = 1.5,
    vGPSTarget = gsP2M5Dir .. "hotel_entrance\\LOC_HDV",
    tLocators = {
      gsP2M5Dir .. "hotel_entrance\\LOC_HotelEntrance",
      gsP2M5Dir .. "hotel_entrance\\LOC_HotelEntrance2"
    },
    tOnComplete = {
      {
        self.DeleteWireFocus,
        {self}
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "Paris_2_Mission_5.Checkpoint2"
        }
      }
    },
    tOnActivate = {}
  })
end

function Paris_2_Mission_5:Checkpoint2()
  print("--Checkpoint 2")
  Sound.ReleaseSoundBank("Vehicles.bnk")
  Sound.LoadSoundBank("m_P2M5_inGame.bnk")
  if not self:IsMissionTaskActive("Task_ParentFind") then
    self:Task_ParentFind()
  else
    self:TASK_FindLibrary()
  end
  Sound.DisableAllChatter()
  Util.SetDynamicPriority("Human_RS_Maria", 800)
  Util.SetDynamicPriority("Human_NZ_Franziska", 800)
  EVENT_ActorEntersCombat("Paris_2_Mission_5.KillConversation", self, self.tInfo.NoteOfficer)
  self:TASK_RamboEntrance()
  self:TASK_OfficerConv()
  self:TASK_MoveWatcher()
  self:PurgeSpawners()
  self:EntranceNaziSpawner()
  Suspicion.EnableEscalation(true)
  self:TASK_Escalator()
  self:TASK_KillNoteGuy()
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.CloseADoor", self, gsP2M5Dir .. "main\\REG_CloseDoor1", true, {
    Handle("PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_OWall_Bookshelf_Door\\GHotel_OWall_F_Bookshelf_Door(1)")
  })
  local hPt = Handle(gsP2M5Dir .. "hotel_inside\\BookUsePt")
  if hPt then
    AttractionPt.EnableUse(hPt, false)
  end
  self:OnSecretNazi(false)
  self.ConvManager:PlayConv("P2M5_HDV_Entered")
  self.tSaveInfo.bKillConv = false
end

function Paris_2_Mission_5:KillConversation()
  self.tSaveInfo.bKillConv = true
  self.ConvManager:StopConv("P2M5_TopFloorNaziYelling")
end

function Paris_2_Mission_5:TASK_RamboEntrance()
  self:CreateTask({
    sName = "TASK_RamboEntrance",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsP2M5Dir .. "hotel_inside\\REG_RamboEntrance"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.RamboEntrance,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:RamboEntrance()
  self.tSaveInfo.bRamboEntrance = true
  print("player is going rambo style")
end

function Paris_2_Mission_5:OnSecretNazi(bOn)
  local hNazi = Handle(self.tInfo.SecretNazi)
  if hNazi then
    print("turning secret nazi ", bOn)
    Combat.SetRespondToSound(hNazi, bOn)
    Combat.SetRespondToEvents(hNazi, bOn)
    Actor.OverrideCombatAI(hNazi, not bOn)
    Combat.SetStationary(hNazi, true)
    Combat.SetRespondToDamage(hNazi, bOn)
    Combat.SetRespondToDeadBodies(hNazi, bOn)
  end
end

function Paris_2_Mission_5:TASK_KillNoteGuy()
  self:CreateTask({
    sName = "TASK_KillNoteGuy",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "Kill",
    bNoFocus = true,
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    bInteriorTask = true,
    tTgtInclude = {
      self.tInfo.NoteOfficer
    },
    tOnComplete = {
      {
        self.NoteDeadCheckEscalation,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:NoteDeadCheckEscalation()
  if Suspicion.GetEscalation() == 0 then
    print("you killed the officer spawn closets turned off")
    self:OffWithTheClosets()
  end
end

function Paris_2_Mission_5:TASK_MoveWatcher()
  self:CreateTask({
    sName = "TASK_MoveWatcher",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsP2M5Dir .. "main\\REG_Watcher"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.MoveWatchGuard,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:EntranceNaziSpawner()
  self.tSaveInfo.MySpawners = {}
  local tSpawnerConfig = {
    sSpawnerName = gsP2M5Dir .. "main\\ClosetSpawner1",
    sOffRegion = {
      gsP2M5Dir .. "main\\REG_Watcher2",
      gsP2M5Dir .. "main\\REG_SpawnRoom1"
    },
    sSpawnDoor = "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\SpawnDoor1",
    tLocators = {
      gsP2M5Dir .. "main\\LOC_SpawnRun1"
    }
  }
  self.tSaveInfo.MySpawners[1] = AggroSpawner:CreateSpawner(tSpawnerConfig)
  table.insert(self._tSpawners, self.tSaveInfo.MySpawners[1])
  local tSpawnerConfig = {
    sSpawnerName = gsP2M5Dir .. "main\\ClosetSpawner2",
    sOffRegion = {
      gsP2M5Dir .. "main\\REG_Watcher3",
      gsP2M5Dir .. "main\\REG_SpawnRoom2"
    },
    sSpawnDoor = "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\SpawnDoor2",
    tLocators = {
      gsP2M5Dir .. "main\\LOC_SpawnRun2"
    }
  }
  self.tSaveInfo.MySpawners[2] = AggroSpawner:CreateSpawner(tSpawnerConfig)
  table.insert(self._tSpawners, self.tSaveInfo.MySpawners[2])
  local tSpawnerConfig = {
    sSpawnerName = gsP2M5Dir .. "main\\ClosetSpawner3",
    sOffRegion = {
      gsP2M5Dir .. "main\\REG_SpawnRoom3"
    },
    sSpawnDoor = "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\SpawnDoor3",
    tLocators = {
      gsP2M5Dir .. "main\\LOC_SpawnRun3"
    }
  }
  self.tSaveInfo.MySpawners[3] = AggroSpawner:CreateSpawner(tSpawnerConfig)
  table.insert(self._tSpawners, self.tSaveInfo.MySpawners[3])
end

function Paris_2_Mission_5:TASK_ExteriorEscalator()
  self:CreateTask({
    sName = "TASK_ExteriorEscalator",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = true,
    tOnComplete = {
      {
        self.CallbackExteriorEscalation,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Paris_2_Mission_5:TASK_Escalator()
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
      }
    },
    tOnActivate = {}
  })
end

function Paris_2_Mission_5:TASK_DeEscalator()
  self:CreateTask({
    sName = "TASK_DeEscalator",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 0,
    tOnComplete = {
      {
        self.CallbackDeEscalation,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Paris_2_Mission_5:CallbackExteriorEscalation()
  g_bP2M5_escalated = true
  self:TASK_DeEscalator()
end

function Paris_2_Mission_5:CallbackDeEscalation()
  g_bP2M5_escalated = false
  self:ResetTaskByName("TASK_ExteriorEscalator")
  self:ResetTaskByName("TASK_DeEscalator", true)
end

function Paris_2_Mission_5:CallbackEscalation()
  print("ESCALATION")
  Cin.StopConversation("P2M5_TopFloorNaziYelling")
  self.ConvManager:StopConv("P2M5_TopFloorNaziYelling")
  for i, Spawner in pairs(self.tSaveInfo.MySpawners) do
    if not self.tSaveInfo.bSpawnersOff then
      print("starting spawner manually")
      Spawner:StartSpawner()
    end
  end
  local hNoteOfficer = Handle(self.tInfo.NoteOfficer)
  if hNoteOfficer and Object.IsAlive(hNoteOfficer) then
    EVENT_Timer("Paris_2_Mission_5.Alert", self, 3)
  end
end

function Paris_2_Mission_5:Alert()
  self.ConvManager:PlayConv("P2M5_IntruderAlert_Loudspeaker")
  self.ConvManager:PlayConv("P2M5_IntruderAlert_TopFloorNazi")
end

function Paris_2_Mission_5:NazisinLibrary()
  if not self.tSaveInfo.bRamboEntrance then
  end
end

function Paris_2_Mission_5:OfficerConv()
  if Suspicion.GetEscalation() == 0 and not self.tSaveInfo.bKillConv then
    self.ConvManager:PlayConv("P2M5_TopFloorNaziYelling")
  end
end

function Paris_2_Mission_5:TASK_OfficerConv()
  self:CreateTask({
    sName = "TASK_OfficerConv",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsP2M5Dir .. "hotel_entrance\\REG_OfficerConv"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.OfficerConv,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:MoveWatchGuard()
  local hWatcher = Handle("Missions\\paris_2\\mission_5\\main\\WatchGuard")
  local hLoc = Handle("Missions\\paris_2\\mission_5\\main\\LOC_WatchGuardWalk")
  if hWatcher and Object.IsAlive(hWatcher) then
    Combat.SetIdleScripted(hWatcher, true)
    Nav.MoveToObject(hWatcher, hLoc, 2, false)
  end
  local hWatcher = Handle("Missions\\paris_2\\mission_5\\hdv_nazi_patrol\\Spore_WM_Grunt_MG(8)")
  local hLoc = Handle("Missions\\paris_2\\mission_5\\main\\LOC_WatchGuardWalk2")
  if hWatcher and Object.IsAlive(hWatcher) then
    Nav.CancelScriptedPath(hWatcher)
    Combat.SetIdleScripted(hWatcher, true)
    Nav.MoveToObject(hWatcher, hLoc, 2, false)
  end
  if Suspicion.GetEscalation() == 0 then
    self:NazisinLibrary()
  end
end

function Paris_2_Mission_5:CloseADoor(a_DataTable, hDoor)
  if Object.IsDoorOpen(hDoor) then
    print("close a door", hDoor)
    Object.ForceClose(hDoor)
    if self:IsMissionTaskActive("TASK_CP3") then
      print("reblipping book")
      if not self:IsMissionTaskActive("TASK_BookCaseObjRE") then
        print("reblipping book2")
        self:ResetTaskByName("Task_BookcaseReblip", true)
        self:TASK_BookCaseObjRE()
      end
    end
  end
end

function Paris_2_Mission_5:TASK_FindLibrary()
  self:CreateTask({
    sName = "TASK_FindLibrary",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "deliver",
    sObjectiveTextID = "P2M5_Text.InvestigateLibrary",
    bInteriorTask = true,
    MarkerHeight = 0.1,
    tLocators = {
      gsP2M5Dir .. "main\\LOC_Library"
    },
    tDestRegion = {
      gsP2M5Dir .. "main\\REG_Library"
    },
    sTaskEndConv = "P2M5_FindBook",
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_InvestigateLibrary,
        {self}
      },
      {
        self.TASK_BookCaseObj,
        {self}
      },
      {
        self.Task_Bookcase,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:Task_InvestigateLibrary()
  self:CreateTask({
    sName = "Task_InvestigateLibrary",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Investigate",
    bInteriorTask = true,
    bNoFocus = true,
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    bNoBlips = true,
    MarkerHeight = 0.1,
    tSuccessLocs = gsP2M5Dir .. "main\\LOC_SeeDoor",
    tFailLocs = {
      gsP2M5Dir .. "main\\LOC_SeeDoorFail1",
      gsP2M5Dir .. "main\\LOC_SeeDoorFail2",
      gsP2M5Dir .. "main\\LOC_SeeDoorFail3"
    },
    InViewTime = 1,
    Proximity = 6,
    sFailConv = "P2M5_BookFail",
    sSuccessConv = "P2M5_BookSuccess",
    tOnActivate = {},
    tOnComplete = {}
  })
end

function Paris_2_Mission_5:TASK_SearchLibrary()
  self:CreateTask({
    sName = "TASK_SearchLibrary",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "GOTO",
    bInteriorTask = true,
    sObjectiveTextID = "P2M5_Text.InvestigateLibrary",
    tLocators = {
      gsP2M5Dir .. "main\\LOC_Library"
    },
    MarkerHeight = 0.1,
    tOnActivate = {}
  })
end

function Paris_2_Mission_5:Task_Bookcase()
  self:CreateTask({
    sName = "Task_Bookcase",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Use",
    bInteriorTask = true,
    bNoFocus = true,
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    bNoBlips = true,
    tTgtInclude = {
      gsP2M5Dir .. "hotel_inside\\BookUsePt"
    },
    tOnComplete = {
      {
        self.Task_BookCaseCin,
        {self}
      },
      {
        Render.StopHighlight,
        {
          Handle(self.tInfo.SecretBook)
        }
      },
      {
        self.KillTaskByName,
        {
          self,
          "TASK_BookCaseObj"
        }
      },
      {
        self.KillTaskByName,
        {
          self,
          "Task_InvestigateLibrary"
        }
      },
      {
        self.KillTaskByName,
        {
          self,
          "TASK_SearchLibrary"
        }
      }
    },
    tOnActivate = {
      {
        self.StartHighlight,
        {
          self,
          self.tInfo.SecretBook,
          "BookFocusHighlight"
        }
      }
    }
  })
end

function Paris_2_Mission_5:StartHighlight(vItem, sBP)
  local hItem = Handle(vItem)
  if hItem then
    Render.StartHighlight(hItem, sBP)
  else
    print("unable to get handle to item for StartHighlight")
  end
end

function Paris_2_Mission_5:Task_BookcaseReblip()
  self:CreateTask({
    sName = "Task_BookcaseReblip",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Use",
    bInteriorTask = true,
    bNoFocus = true,
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    bNoBlips = true,
    tTgtInclude = {
      gsP2M5Dir .. "hotel_inside\\BookUsePt"
    },
    tOnComplete = {
      {
        self.ResetTaskByName,
        {
          self,
          "TASK_BookCaseObjRE",
          true
        }
      }
    },
    tOnActivate = {
      {
        self.StartHighlight,
        {
          self,
          self.tInfo.SecretBook,
          "BookFocusHighlight"
        }
      }
    }
  })
end

function Paris_2_Mission_5:Task_BookCaseCin()
  self:CreateTask({
    sName = "Task_BookCaseCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "CIN_P2M5Bookcase",
    tOnActivate = {},
    tOnComplete = {
      {
        self.SecretDoorConv,
        {self}
      },
      {
        self.TASK_CP3,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:TASK_BookCaseObj()
  self:CreateTask({
    sName = "TASK_BookCaseObj",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "USE",
    bInteriorTask = true,
    sObjectiveTextID = "P2M5_Text.SecretDoor",
    tLocators = {
      gsP2M5Dir .. "main\\LOC_BookSwitch"
    },
    MarkerHeight = 0.5,
    tOnActivate = {}
  })
end

function Paris_2_Mission_5:TASK_BookCaseObjRE()
  self:CreateTask({
    sName = "TASK_BookCaseObjRE",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "USE",
    bInteriorTask = true,
    tLocators = {
      gsP2M5Dir .. "main\\LOC_BookSwitch"
    },
    MarkerHeight = 0.5,
    tOnActivate = {
      {
        self.Task_BookcaseReblip,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Paris_2_Mission_5:SecretDoorConv()
  local hNoteOfficer = Handle(self.tInfo.NoteOfficer)
  local hSecretNazi = Handle(self.tInfo.SecretNazi)
  local sConv = ""
  if hNoteOfficer and Object.IsAlive(hNoteOfficer) then
    sConv = "P2M5_DoorOpenNaziAlive"
  else
    sConv = "P2M5_DoorOpenNaziDead"
  end
  local tRunSequence = {
    {
      "PLAYANIMATION",
      {"nazi_hail"}
    }
  }
  ScriptSequence.Run(hSecretNazi, tRunSequence, Cin.PlayConversation, {
    "P2M5_DoorOpenNaziAlive"
  })
  self:OnSecretNazi(true)
  Sound.SetMusicLocale("P2M5_BoilingPoint")
  Sound.SetMusicLocale("m_P2M5_BoilingPoint", "libraryDoor")
end

function Paris_2_Mission_5:OffWithTheClosets()
  self.tSaveInfo.bSpawnersOff = true
end

function Paris_2_Mission_5:TASK_CP3()
  self:CreateTask({
    sName = "TASK_CP3",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "deliver",
    bInteriorTask = true,
    tDestRegion = {
      gsP2M5Dir .. "main\\REG_CP3"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        self.Task_FindCaptiveCell,
        {self}
      }
    },
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Paris_2_Mission_5.Checkpoint3"
        }
      }
    }
  })
end

function Paris_2_Mission_5:Checkpoint3()
  print("_____checkpoint 3")
  if not self:IsMissionTaskActive("Task_ParentFind") then
    self:Task_ParentFind()
  end
  Sound.EnableAllChatter()
  Suspicion.SetEscalated()
  EVENT_PlayConversationDelayed("P2M5_Franziska_Loudspeaker_1", 3, self)
  self:OffWithTheClosets()
  self:PurgeSpawners()
  self:TASK_LoudSpeaker2()
  self:TASK_LoadBasementSpores()
end

function Paris_2_Mission_5:BasementNaziSpawner()
end

function Paris_2_Mission_5:TASK_LoudSpeaker2()
  self:CreateTask({
    sName = "TASK_LoudSpeaker2",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsP2M5Dir .. "hdv_nazi_patrol\\REG_Basement1"
    },
    tDeliverObjs = {hSab},
    sTaskEndConv = "P2M5_Franziska_Loudspeaker_2"
  })
end

function Paris_2_Mission_5:Task_FindCaptiveCell()
  self:CreateTask({
    sName = "Task_FindCaptiveCell",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P2M5_Text.FindCell",
    bInteriorTask = true,
    tDestRegion = {
      gsP2M5Dir .. "hotel_inside\\REG_CellConv"
    },
    tLocators = {
      gsP2M5Dir .. "hotel_inside\\LOC_CellGate"
    },
    MarkerHeight = 0.5,
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.CompleteTaskByName,
        {
          self,
          "Task_ParentFind"
        }
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "Paris_2_Mission_5.Checkpoint4"
        }
      }
    },
    tOnActivate = {}
  })
end

function Paris_2_Mission_5:TASK_LoadCinBasementSpores()
  self:CreateTask({
    sName = "TASK_LoadCinBasementSpores",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\cinematics\\321a_cinb_boilfranziskaintro_ac"
    }
  })
end

function Paris_2_Mission_5:TASK_LoadBasementSpores()
  self:CreateTask({
    sName = "TASK_LoadBasementSpores",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      gsP2M5Dir .. "terrortrap"
    },
    tOnActivate = {
      {
        self.AddMyLoadedNodes,
        {
          self,
          "TASK_LoadBasementSpores"
        }
      },
      {
        self.SetupTerror,
        {self}
      }
    },
    tOnCancel = {}
  })
end

function Paris_2_Mission_5:Checkpoint4()
  print("_____checkpoint 4")
  self:PurgeSpawners()
  self.tSaveInfo.bSpawnersOff = false
  self:SetupCellSpawners()
  Object.ForceClose(Handle("PARIS\\area06\\hoteldeville\\interior\\hdv_int\\PrisonGateA"))
  self:TASK_CellCutscene()
  self:SetupHicks()
end

function Paris_2_Mission_5:TASK_CellCutscene()
  self:CreateTask({
    sName = "TASK_CellCutscene",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "P2M5_TrapCam",
    tOnActivate = {
      {
        Object.ForceClose,
        {
          Handle("PARIS\\area06\\hoteldeville\\interior\\hdv_int\\PrisonGateA")
        }
      },
      {
        self.StartTerror,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Paris_2_Mission_5:SetupHicks()
  local hHicks = Handle(self.tInfo.Hicks)
  Actor.SetPanicEnabled(hHicks, false)
  Combat.SetIdleScripted(hHicks, true)
  Actor.OverrideCombatAI(hHicks, true)
  EVENT_ActorDeath("Paris_2_Mission_5.BoilerConv", self, hHicks)
  self.tInfo.HicksTotalDamage = 0
  self.tInfo.eHicksDamage = EVENT_ActorDamaged("Paris_2_Mission_5.HicksDamaged", self, self.tInfo.Hicks, {}, true)
  Actor.SetHealthRecoveryPct(hHicks, 0.01)
end

function Paris_2_Mission_5:HicksDamaged(tArgs)
  local hHicks = Handle(self.tInfo.Hicks)
  if tArgs[2] == hSab and tArgs[3] == cDAMAGE_BULLETS then
    self.tInfo.HicksTotalDamage = self.tInfo.HicksTotalDamage + tArgs[4]
  end
  if self.tInfo.HicksTotalDamage >= 100 then
    self.tSaveInfo.bMeanSean = true
  end
  if hHicks and not Object.IsAlive(hHicks) then
    print("hicks is dead")
  end
end

function Paris_2_Mission_5:TASK_LoadTerror()
  self:CreateTask({
    sName = "TASK_LoadTerror",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tOnActivate = {
      {
        self.StartTerror,
        {self}
      }
    },
    tOnCancel = {}
  })
end

function Paris_2_Mission_5:SetupTerror()
  for i, Terror in pairs(self.tInfo.Terrors) do
    local hTerror = Handle(Terror)
    if hTerror then
      Actor.ChangeModule(hTerror, "Human_Null")
    end
  end
end

function Paris_2_Mission_5:StartTerror()
  Suspicion.SetEscalated()
  Object.ForceClose(Handle("PARIS\\area06\\hoteldeville\\interior\\hdv_int\\PrisonGateA"))
  local hPt = Handle(gsP2M5Dir .. "hotel_inside\\DoorSwitch")
  if hPt then
  end
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.Task_KillSquadA", self, gsP2M5Dir .. "terrortrap\\REG_Trap")
end

function Paris_2_Mission_5:NextTerror()
  print("next terror")
  Object.ForceOpen(Handle("PARIS\\area06\\hoteldeville\\interior\\hdv_int\\CellTrapB"))
  hAp = Handle(gsP2M5Dir .. "hotel_inside\\DoorSwitch")
  if hAp then
    AttractionPt.EnableUse(hAp, false)
  end
  self:AggroTerrors(self.tInfo.TerrorsSquadB, gsP2M5Dir .. "terrortrap\\LOC_EndTerror1")
  self:Task_KillSquadB()
end

function Paris_2_Mission_5:AggroTerrors(tTerrors, Locator, Locator2)
  local hStop
  for i, Terror in pairs(tTerrors) do
    local hTerror = Handle(Terror)
    Actor.ChangeModule(hTerror, "Soldier")
    Combat.SetTarget(hTerror, hSab)
    Combat.SetCombat(hTerror)
    local hStop = WRAPPER_CheckForHandleNil(Locator)
    local hStop2 = WRAPPER_CheckForHandleNil(Locator2)
    if hStop or not hStop2 then
    end
    if i == 2 then
      hStop = hStop2
    end
    if hTerror and hStop and Object.IsAlive(hTerror) then
      print("running terror to fight")
      Combat.SetIdleScripted(hTerror, true)
      Combat.SetObjective(hTerror, hStop, true, -1, false)
    end
  end
  Suspicion.SetEscalated()
end

function Paris_2_Mission_5:Task_KillSquadA()
  self:CreateTask({
    sName = "Task_KillSquadA",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "Kill",
    sObjectiveTextID = "P2M5_Text.KillTerrors",
    bInteriorTask = true,
    bObjCounter = true,
    tTgtInclude = self.tInfo.TerrorsSquadA,
    sTaskStartConv = "P2M5_Franziska_Loudspeaker_2",
    tOnActivate = {
      {
        Object.ForceOpen,
        {
          Handle("PARIS\\area06\\hoteldeville\\interior\\hdv_int\\CellTrapA")
        }
      },
      {
        EVENT_Timer,
        {
          "Paris_2_Mission_5.DelayAggro",
          self,
          4
        }
      },
      {
        self.SetTerrorFightConv,
        {self, true}
      },
      {
        EVENT_Timer,
        {
          "Paris_2_Mission_5.StartTerrorFightConv",
          self,
          7
        }
      }
    },
    tOnComplete = {
      {
        self.NextTerror,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:DelayAggro()
  self:AggroTerrors(self.tInfo.TerrorsSquadA, gsP2M5Dir .. "terrortrap\\LOC_EndTerror1", gsP2M5Dir .. "terrortrap\\LOC_EndTerror2")
end

function Paris_2_Mission_5:Task_KillSquadB()
  self:CreateTask({
    sName = "Task_KillSquadB",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "Kill",
    sObjectiveTextID = "P2M5_Text.FinishElite",
    bInteriorTask = true,
    bObjCounter = true,
    tTgtInclude = self.tInfo.TerrorsSquadB,
    sTaskStartConv = "P2M5_TerrorSquadsSuck",
    tOnComplete = {
      {
        self.SetTerrorFightConv,
        {self, false}
      },
      {
        self.Task_FlipGateSwitch,
        {self}
      },
      {
        Sound.SetMusicLocale,
        {
          "P2M5_BoilingPoint"
        }
      },
      {
        Sound.SetMusicLocale,
        {
          "m_P2M5_BoilingPoint",
          "BlowBoiler"
        }
      }
    },
    tOnActivate = {}
  })
end

function Paris_2_Mission_5:Task_TalkToHicks()
  self:CreateTask({
    sName = "Task_TalkToHicks",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Talk",
    bInteriorTask = true,
    MarkerHeight = 0.5,
    bNoWorldBlip = true,
    bAutofire = true,
    bUseOldAutofire = true,
    Proximity = 10,
    sConvFile = "P2M5_Hicks_OpenCells",
    tTgtInclude = {
      self.tInfo.Hicks
    },
    tOnComplete = {
      {
        self.CompleteTaskByName,
        {
          self,
          "Task_EscapeBasement"
        }
      },
      {
        self.Task_FlipGateSwitchObj,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Paris_2_Mission_5:Task_FlipGateSwitch()
  self:CreateTask({
    sName = "Task_FlipGateSwitch",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Use",
    bInteriorTask = true,
    MarkerHeight = 0.5,
    bNoBlips = true,
    tTgtInclude = {
      gsP2M5Dir .. "hotel_inside\\DoorSwitch"
    },
    tOnComplete = {
      {
        self.KillTaskByName,
        {
          self,
          "Task_EscapeBasement"
        }
      },
      {
        self.KillTaskByName,
        {
          self,
          "Task_FlipGateSwitchObj"
        }
      },
      {
        self.KillTaskByName,
        {
          self,
          "Task_TalkToHicks"
        }
      },
      {
        self.Task_EnterBoilerRoom,
        {self}
      },
      {
        self.OpenAllCellGates,
        {self, true}
      },
      {
        Render.StopHighlight,
        {
          Handle(self.tInfo.BoilerBoxSwitch)
        }
      },
      {
        self.HicksSequence,
        {self}
      }
    },
    tOnActivate = {
      {
        self.Task_EscapeBasement,
        {self}
      },
      {
        self.StartHighlight,
        {
          self,
          self.tInfo.BoilerBoxSwitch,
          "BookFocusHighlight"
        }
      },
      {
        self.HicksLifeCheck,
        {self}
      },
      {
        Sound.SetMusicLocale,
        {
          "P2M5_BoilingPoint"
        }
      },
      {
        Sound.SetMusicLocale,
        {
          "m_P2M5_BoilingPoint",
          "BlowBoiler"
        }
      }
    }
  })
end

function Paris_2_Mission_5:HicksLifeCheck()
  local hHicks = Handle(self.tInfo.Hicks)
  if hHicks and Object.IsAlive(hHicks) then
    self:Task_TalkToHicks()
  else
    self:CompleteTaskByName("Task_EscapeBasement")
    self:Task_FlipGateSwitchObj()
  end
end

function Paris_2_Mission_5:Task_FlipGateSwitchObj()
  self:CreateTask({
    sName = "Task_FlipGateSwitchObj",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "USE",
    sObjectiveTextID = "P2M5_Text.OpenCellDoor",
    bInteriorTask = true,
    MarkerHeight = 0.5,
    tTgtInclude = {
      gsP2M5Dir .. "hotel_inside\\DoorSwitch"
    },
    tOnComplete = {},
    tOnActivate = {}
  })
end

function Paris_2_Mission_5:Task_EscapeBasement()
  self:CreateTask({
    sName = "Task_EscapeBasement",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "NONE",
    sObjectiveTextID = "P2M5_Text.FindWay"
  })
end

function Paris_2_Mission_5:OpenAllCellGates(bOpen)
  for i, door in pairs(self.tInfo.CellGates) do
    local hDoor = Handle(door)
    if hDoor then
      if bOpen then
        Object.ForceOpen(hDoor)
      else
        Object.ForceClose(hDoor)
      end
    end
  end
end

function Paris_2_Mission_5:HicksSequence()
  print("hicks sequence")
  EVENT_Timer("Paris_2_Mission_5.HicksThanks", self, 2)
  Nav.SetScriptedPath(Handle(self.tInfo.Hicks), gsP2M5Dir .. "main\\PATH_HicksExit", true, "Paris_2_Mission_5.HicksSequenceFinish", self)
  Nav.SetScriptedPathMoveMode(Handle(self.tInfo.Hicks), true)
end

function Paris_2_Mission_5:HicksThanks()
  Cin.PlayConversation("P2M5_Hicks_Rescued")
end

function Paris_2_Mission_5:HicksSequenceFinish()
  local hHicks = Handle(self.tInfo.Hicks)
  Cin.PlayConversation("P2M5_Hicks_DoorLocked", "Paris_2_Mission_5.HicksGotoCover", self)
  self.tSaveInfo.bFreakOut = false
  Actor.PlayAnimation(hHicks, __UtilFunctions.UsefulAnimCatcher[5])
end

function Paris_2_Mission_5:HicksGotoCover()
  print("hicks freaks out")
  if not self.tSaveInfo.bFreakOut then
    self.tSaveInfo.bFreakOut = true
    local hHicks = Handle(self.tInfo.Hicks)
    local hCoverPt = Handle("Missions\\paris_2\\mission_5\\hotel_inside\\CoverPt")
    if hHicks and hCoverPt then
      print("hicks goto cover?")
      Actor.CancelAnimation(hHicks)
      Actor.OverrideCombatAI(hHicks, false)
      Combat.SetIdleScripted(hHicks, true)
      Inventory.GiveItem(hHicks, "WP_PS_Luger", true)
      Combat.SetIdleHoldWeapon(hHicks, true)
      Nav.MoveToObject(hHicks, hCoverPt, 1, true, "Paris_2_Mission_5.UseCoverPoint", self, {hHicks, hCoverPt})
    end
    self.tSaveInfo.bFreakoutconv = true
    self:StartFreakoutConv()
  end
end

function Paris_2_Mission_5:UseCoverPoint(hHicks, hAP)
  if hHicks and hAP then
    print("requesting attrpt ", hHicks, hAP)
    Actor.RequestAttrPt(hHicks, hAP)
  end
  EVENT_Timer("Paris_2_Mission_5.SetCombatHicks", self, 12)
end

function Paris_2_Mission_5:SetCombatHicks(hHicks)
  local hHicks = Handle(self.tInfo.Hicks)
  print("set combat hicks")
  Actor.CancelAttrPt(hHicks)
  Combat.AddTargetFlag(hHicks, cTARGET_NAZI)
  Combat.AddTargetFlag(hHicks, cTARGET_ALLENEMIESHOSTILE)
end

function Paris_2_Mission_5:StartFreakoutConv()
  local hHicks = Handle(self.tInfo.Hicks)
  if self.tSaveInfo.bFreakoutconv and Actor.IsAlive(hHicks) then
    print("freak out conv")
    Cin.PlayConversation("P2M5_Hicks_NazisPanic")
    EVENT_Timer("Paris_2_Mission_5.StartFreakoutConv", self, 15)
  end
end

function Paris_2_Mission_5:StopFreakoutConv()
  self.tSaveInfo.bFreakoutconv = false
end

function Paris_2_Mission_5:StartTerrorFightConv()
  local hHicks = Handle(self.tInfo.Hicks)
  if self.tSaveInfo.bTerrorFightconv and Actor.IsAlive(hHicks) then
    Cin.PlayConversation("P2M5_Hicks_InCellFight")
    EVENT_Timer("Paris_2_Mission_5.StartTerrorFightConv", self, 10)
  end
end

function Paris_2_Mission_5:SetTerrorFightConv(bOn)
  self.tSaveInfo.bTerrorFightconv = bOn
end

function Paris_2_Mission_5:SetupCellSpawners()
  local MySpawner = Actor.GetSelf(Handle("Missions\\paris_2\\mission_5\\main\\CellSpawner1"))
  table.insert(self._tSpawners, MySpawner)
  local MySpawner = Actor.GetSelf(Handle("Missions\\paris_2\\mission_5\\main\\CellSpawner2"))
  table.insert(self._tSpawners, MySpawner)
end

function Paris_2_Mission_5:CellGateSpawners()
  EVENT_Timer("Paris_2_Mission_5.HicksGotoCover", self, 8)
  Cin.PlayConversation("P2M5_Hicks_NazisStart")
  for i, oSpawner in pairs(self._tSpawners) do
    if not self.tSaveInfo.bSpawnersOff then
      print("starting spawner manually ", oSpawner)
      CoDSpawner.OnOnTriggerEntered(oSpawner)
    end
  end
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.CloseADoor", self, gsP2M5Dir .. "main\\REG_GateSpawner", false, {
    Handle("PARIS\\area06\\hoteldeville\\interior\\hdv_int\\PrisonGateA")
  })
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.OffCellGateSpawners", self, gsP2M5Dir .. "main\\REG_GateSpawner", false, {
    Handle("PARIS\\area06\\hoteldeville\\interior\\hdv_int\\PrisonGateA")
  })
end

function Paris_2_Mission_5:OffCellGateSpawners()
  if self._tSpawners then
    for _, oSpawner in pairs(self._tSpawners) do
      print("stopping spawner ", oSpawner)
      CoDSpawner.OnOffTriggerEntered(oSpawner)
    end
  end
  if not self.tSaveInfo.bSpawnersOff then
    EVENT_PlayerExitsTrigger("Paris_2_Mission_5.CellGateSpawners", self, gsP2M5Dir .. "main\\REG_GateSpawner")
  end
end

function Paris_2_Mission_5:Task_EnterBoilerRoom()
  self:CreateTask({
    sName = "Task_EnterBoilerRoom",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Goto",
    sObjectiveTextID = "P2M5_Text.EnterBoilerRoom",
    tDeliverObjs = {hSab},
    bInteriorTask = true,
    tDestRegion = {
      gsP2M5Dir .. "main\\REG_Boiler"
    },
    tLocators = {
      gsP2M5Dir .. "hotel_inside\\LOC_BoilerEscort"
    },
    MarkerHeight = 0.5,
    tOnActivate = {},
    tOnComplete = {
      {
        EVENT_Timer,
        {
          "Paris_2_Mission_5.Task_CinGate",
          self,
          4
        }
      }
    }
  })
end

function Paris_2_Mission_5:Task_CinGate()
  self:CreateTask({
    sName = "Task_CinGate",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "P2M5_CellGate",
    tOnActivate = {
      {
        self.CellGateSpawners,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TASK_SabotageBoiler,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:BoilerConv()
  print("hicks is dead..right?")
  if self:IsMissionTaskActive("Task_TalkToHicks") then
    self:CompleteTaskByName("Task_TalkToHicks")
  else
  end
end

function Paris_2_Mission_5:TASK_SabotageBoiler()
  self:CreateTask({
    sName = "TASK_SabotageBoiler",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "DESTROY",
    sObjectiveTextID = "P2M5_Text.BlastBoilerRoom",
    bInteriorTask = true,
    MarkerHeight = 1,
    bBlipLocatorsOnly = true,
    tLocators = {
      "Missions\\paris_2\\mission_5\\main\\LOC_BoilDoor"
    },
    tTgtInclude = {
      self.tInfo.Boiler_Left,
      self.tInfo.Boiler_Right
    },
    tOnComplete = {
      {
        Cin.PlayConversation,
        {
          "P2M5_BoilerSettoBlow"
        }
      },
      {
        self.Task_GetToSafety,
        {self}
      },
      {
        Object.ForceClose,
        {
          Handle("PARIS\\area06\\hoteldeville\\interior\\hdv_int\\PrisonGateA")
        }
      }
    },
    tOnPartComplete = {
      {
        self.Shake,
        {self}
      }
    },
    tOnActivate = {
      {
        self.SabotageListener,
        {self}
      },
      {
        self.BoilerDeathListener,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:SabotageListener()
  print("sabotage listenr")
  local tSabEvent = {EventType = "OnSabotage", Target = hSab}
  Util.CreateEvent(tSabEvent, "Paris_2_Mission_5.HicksGameOver", self)
end

function Paris_2_Mission_5:Task_GetToSafety()
  self:CreateTask({
    sName = "Task_GetToSafety",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Goto",
    sObjectiveTextID = "P2M5_Text.GetToSafety",
    tDeliverObjs = {hSab},
    bInteriorTask = true,
    bGroundBlip = true,
    tDestRegion = {
      gsP2M5Dir .. "main\\REG_BoilerCover"
    },
    tLocators = {
      gsP2M5Dir .. "main\\LOC_Safety"
    },
    MarkerHeight = 0.5,
    tOnActivate = {
      {
        self.HicksGameOver,
        {self}
      }
    },
    tOnComplete = {
      {
        self.OffWithTheClosets,
        {self}
      },
      {
        self.Rumble,
        {self}
      },
      {
        self.StopFreakoutConv,
        {self}
      }
    },
    tOnCancel = {}
  })
end

function Paris_2_Mission_5:CompleteSafety()
  print("autocompleting safety task")
  self:CompleteTaskByName("Task_GetToSafety")
end

function Paris_2_Mission_5:HicksGameOver()
  local hHicks = Handle(self.tInfo.Hicks)
  if self.tSaveInfo.bHicksSeq then
    return
  end
  self.tSaveInfo.bHicksSeq = true
  self:StopFreakoutConv()
  if hHicks and Object.IsAlive(hHicks) then
    print("Game over man!")
    Actor.CancelAttrPt(hHicks)
    Combat.SetIdleScripted(hHicks, true)
    Actor.OverrideCombatAI(hHicks, false)
    Combat.AddTargetFlag(hHicks, cTARGET_NAZI)
    Combat.SetTargetAggressively(hHicks, true)
    Object.SetHealth(hHicks, 1)
    Combat.AddTargetFlag(hHicks, cTARGET_ALLENEMIESHOSTILE)
    Nav.CancelScriptedPath(hHicks)
    Combat.SetObjectivePath(hHicks, Util.GetCRC(gsP2M5Dir .. "hotel_inside\\PATH_GameOver"), true, 10)
    EVENT_Timer("Paris_2_Mission_5.KillHicks", self, 15)
  end
end

function Paris_2_Mission_5:KillHicks()
  local hHicks = Handle(self.tInfo.Hicks)
  Object.Kill(hHicks)
end

function Paris_2_Mission_5:BoilerDeathListener()
  print("setup boiler death listen")
  EVENT_ActorDeath("Paris_2_Mission_5.BoilerDeath", self, self.tInfo.Boiler_Left)
  EVENT_ActorDeath("Paris_2_Mission_5.BoilerDeath", self, self.tInfo.Boiler_Right)
end

function Paris_2_Mission_5:BoilerDeath()
  print("boiler death o-matic")
  if not self.tSaveInfo.bABoilerDeath then
    print("complete boiler death")
    self.tSaveInfo.bABoilerDeath = true
    self:CompleteTaskByName("TASK_SabotageBoiler")
  end
end

function Paris_2_Mission_5:TASK_BoilerLoc()
  self:CreateTask({
    sName = "TASK_BoilerLoc",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tLocators = {
      gsP2M5Dir .. "main\\LOC_Boilertage"
    },
    MarkerHeight = 0.5,
    bInteriorTask = true
  })
end

function Paris_2_Mission_5:Rumble()
  self:Shake()
  EVENT_Timer("Paris_2_Mission_5.Shake", self, 5)
  EVENT_Timer("Paris_2_Mission_5.Shake", self, 8)
  EVENT_Timer("Paris_2_Mission_5.Shake", self, 10)
  if Actor.IsAlive(hSab) then
    print("boiler splodin ")
    self:Task_BoilerSplodin()
  else
    print("Aborting boiler sequence, player is dead")
  end
end

function Paris_2_Mission_5:Task_BoilerSplodin()
  self:CreateTask({
    sName = "Task_BoilerSplodin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "P2M5_BoilerSplodin",
    tOnActivate = {
      {
        self.DestoryBoilerTimer,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Paris_2_Mission_5:Shake()
  local x, y, z
  x, y, z = Object.GetPosition(hSab)
  Render.CameraShakeExplosion(x, y, z, 1 + (self.tSaveInfo.BoilerSplode - 1), 20, 30)
  local hBoiler = Handle(self.tInfo.Boiler_Left)
  if hBoiler then
    Sound.AttachSoundEvent(hBoiler, "Imp_Boiler_Breaking")
  end
end

function Paris_2_Mission_5:DestoryBoilerTimer()
  if self.tSaveInfo.BoilerSplode < 4 then
    if self.tSaveInfo.BoilerSplode == 1 then
      self:TASK_LoadSteamA()
    elseif self.tSaveInfo.BoilerSplode == 2 then
      self:TASK_LoadSteamB()
    elseif self.tSaveInfo.BoilerSplode == 3 then
      self:TASK_LoadSteamC()
      self:TASK_LoadDoorNazi()
    end
    EVENT_Timer("Paris_2_Mission_5.DestoryBoiler", self, 1.25)
    self.tSaveInfo.BoilerSplode = self.tSaveInfo.BoilerSplode + 1
  else
    self:TASK_LoadParticles()
    Sound.DeactivateSoundEmitter(Handle(gsP2M5Dir .. "sound\\P2M5_boilerGood_01"))
    Sound.DeactivateSoundEmitter(Handle(gsP2M5Dir .. "sound\\P2M5_boilerGood_02"))
    Sound.SetMusicLocale("P2M5_BoilingPoint")
    Sound.SetMusicLocale("m_P2M5_BoilingPoint", "Escape")
    self:BlowBoilerAndHoles()
  end
end

function Paris_2_Mission_5:BoilerDeathZone()
  print("boiler death zone")
  local hTrigger = Handle("Missions\\paris_2\\mission_5\\main\\REG_BoilerDeathZone")
  local hHumanFilter = Filter.New("Human")
  local tHumans = {}
  if hTrigger then
    tHumans = Trigger.GetAllWithin(hTrigger, hHumanFilter)
  end
  if tHumans and tHumans[1] then
    for i, Nazi in pairs(tHumans) do
      local hNazi = Handle(Nazi)
      Object.Kill(hNazi)
      print("killing humans ", hNazi)
    end
  end
  Filter.Delete(hHumanFilter)
end

function Paris_2_Mission_5:BlowBoilerAndHoles()
  local tSplodeLocs = {
    "Missions\\paris_2\\mission_5\\main\\LOC_BoilerDAMa1",
    "Missions\\paris_2\\mission_5\\main\\LOC_BoilerDAMa2",
    "Missions\\paris_2\\mission_5\\main\\LOC_BoilerDAMb1",
    "Missions\\paris_2\\mission_5\\main\\LOC_BoilerDAMb2"
  }
  for i, Loc in pairs(tSplodeLocs) do
    local hLoc = Handle(Loc)
    if hLoc then
    end
  end
  local tSplodeLocs = {
    "Missions\\paris_2\\mission_5\\main\\LOC_BoilSplode1",
    "Missions\\paris_2\\mission_5\\main\\LOC_BoilSplode2",
    "Missions\\paris_2\\mission_5\\main\\LOC_BoilSplode3",
    "Missions\\paris_2\\mission_5\\main\\LOC_BoilSplode4",
    "Missions\\paris_2\\mission_5\\main\\LOC_BoilSplode5"
  }
  for i, Loc in pairs(tSplodeLocs) do
    local hLoc = Handle(Loc)
    if hLoc then
    end
  end
  Sound.PlayOwnerlessSoundEvent("Explo_P2M5_Boiler")
  self:CollapseProp("PARIS\\area06\\hoteldeville\\interior\\hdv_int\\Bunker_PCeiling_X8Z8_A_DAM(1)")
  self:CollapseProp("PARIS\\area06\\hoteldeville\\interior\\hdv_int\\Bunker_PCeiling_X8Z8_A_DAM")
  self:CollapseProp("PARIS\\area06\\hoteldeville\\interior\\hdv_int\\Bunker_Column_Y4X1_A_DAM")
  self:CollapseProp("PARIS\\area06\\hoteldeville\\interior\\hdv_int\\Bunker_Column_Y4X1_A_DAM(1)")
end

function Paris_2_Mission_5:DestoryBoiler()
  local x, y, z
  x, y, z = Object.GetPosition(hSab)
  Render.CameraShakeExplosion(x, y, z, 8 + 2 * (self.tSaveInfo.BoilerSplode - 1), 20, 30)
  self:DestoryBoilerTimer()
end

function Paris_2_Mission_5:AddMyLoadedNodes(sTaskName)
  table.insert(self.tSaveInfo.MyMidMissionLoadedNodes, sTaskName)
end

function Paris_2_Mission_5:RemoveMyLoadedNodes()
  for i, sTaskName in pairs(self.tSaveInfo.MyMidMissionLoadedNodes) do
    self:UnloadTaskNodes(sTaskName, true)
  end
  self.tSaveInfo.MyMidMissionLoadedNodes = {}
end

function Paris_2_Mission_5:TASK_LoadParticles()
  self:CreateTask({
    sName = "TASK_LoadParticles",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bCompleteOnActivate = true,
    tSMEDNodes = {
      gsP2M5Dir .. "hdv_boom"
    },
    tOnActivate = {
      {
        WorldSMEDNodes.LoadStaticTag,
        {"hdvsmoke", true}
      },
      {
        self.AddMyLoadedNodes,
        {
          self,
          "TASK_LoadParticles"
        }
      }
    },
    tOnCancel = {
      {
        WorldSMEDNodes.UnloadStaticTag,
        {"hdvsmoke", true}
      }
    }
  })
end

function Paris_2_Mission_5:TASK_LoadSteamA()
  self:CreateTask({
    sName = "TASK_LoadSteamA",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bCompleteOnActivate = true,
    tSMEDNodes = {
      gsP2M5Dir .. "hdv_steam1a"
    },
    tOnActivate = {
      {
        self.AddMyLoadedNodes,
        {
          self,
          "TASK_LoadSteamA"
        }
      }
    },
    tOnCancel = {}
  })
end

function Paris_2_Mission_5:TASK_LoadSteamB()
  self:CreateTask({
    sName = "TASK_LoadSteamB",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bCompleteOnActivate = true,
    tSMEDNodes = {
      gsP2M5Dir .. "hdv_steam1b"
    },
    tOnActivate = {
      {
        self.AddMyLoadedNodes,
        {
          self,
          "TASK_LoadSteamB"
        }
      }
    },
    tOnCancel = {}
  })
end

function Paris_2_Mission_5:TASK_LoadSteamC()
  self:CreateTask({
    sName = "TASK_LoadSteamC",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bCompleteOnActivate = true,
    tSMEDNodes = {
      gsP2M5Dir .. "hdv_steam1c"
    },
    tOnActivate = {
      {
        self.AddMyLoadedNodes,
        {
          self,
          "TASK_LoadSteamC"
        }
      }
    },
    tOnCancel = {}
  })
end

function Paris_2_Mission_5:TASK_LoadDoorNazi()
  self:CreateTask({
    sName = "TASK_LoadDoorNazi",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bCompleteOnActivate = true,
    tSMEDNodes = {
      gsP2M5Dir .. "boilerdoornazi"
    },
    tOnActivate = {
      {
        self.AddMyLoadedNodes,
        {
          self,
          "TASK_LoadDoorNazi"
        }
      }
    },
    tOnComplete = {
      {
        self.DoorNaziSequence,
        {self}
      }
    },
    tOnCancel = {}
  })
end

function Paris_2_Mission_5:DoorNaziSequence()
  local hDoorNazi = Handle(self.tInfo.DoorNazi)
  local hLoc = Handle(gsP2M5Dir .. "boilerdoornazi\\LOC_RunTo")
  if hDoorNazi then
    Combat.SetIdleScripted(hDoorNazi, true)
    Actor.OverrideCombatAI(hDoorNazi, true)
    Nav.MoveToObject(hDoorNazi, hLoc, 0.5, true, "Paris_2_Mission_5.OpenBoilerDoor", self)
    EVENT_Timer("Paris_2_Mission_5.OpenBoilerDoor", self, 3.5)
  end
end

function Paris_2_Mission_5:OpenBoilerDoor()
  print("open boiler door")
  local hDoorNazi = Handle(self.tInfo.DoorNazi)
  if hDoorNazi then
    Combat.SetIdleScripted(hDoorNazi, true)
    Actor.OverrideCombatAI(hDoorNazi, false)
    Combat.SetHunt(hDoorNazi, hSab, true, false)
  end
  if not self.tSaveInfo.bBoilerDoorSplode then
    self.tSaveInfo.bBoilerDoorSplode = true
    Object.ForceOpen(Handle("PARIS\\area06\\hoteldeville\\interior\\hdv_int\\BoilerBackDoor"))
    EVENT_Timer("Paris_2_Mission_5.Splodin", self, 1)
  end
end

function Paris_2_Mission_5:Splodin()
  local hLoc = Handle(gsP2M5Dir .. "boilerdoornazi\\LOC_Splosion")
  local hDoorNazi = Handle(self.tInfo.DoorNazi)
  if hDoorNazi then
    Object.SetHealth(hDoorNazi, 5)
  end
  if hLoc then
    local x, y, z = Object.GetPosition(hLoc)
    Util.CreateExplosion("Explosion_SAB_DynamiteFuse", x, y, z)
  end
  Sound.ActivateSoundEmitter(Handle(gsP2M5Dir .. "sound\\P2M5_BoilerExplo"))
  Sound.ActivateSoundEmitter(Handle(gsP2M5Dir .. "sound\\P2M5_lobbyFirePoints_boilerRoom"))
  EVENT_PlayConversationDelayed("P2M5_FireBreaksOut", 4)
  self:Task_FindWayThroughFire()
end

function Paris_2_Mission_5:Task_FindWayThroughFire()
  self:CreateTask({
    sName = "Task_FindWayThroughFire",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Deliver",
    sObjectiveTextID = "P2M5_Text.FindWay",
    bInteriorTask = true,
    MarkerHeight = 0.1,
    tLocators = {
      gsP2M5Dir .. "main\\LOC_StorageRoom"
    },
    tDestRegion = {
      gsP2M5Dir .. "main\\REG_StorageRoom"
    },
    tDeliverObjs = {hSab},
    sTaskEndConv = "P2M5_SeesAlcohol",
    tSMEDNodes = {
      gsP2M5Dir .. "inferno_nazis"
    },
    tOnComplete = {
      {
        self.Task_FireFloorCin,
        {self}
      }
    },
    tOnActivate = {
      {
        self.AddMyLoadedNodes,
        {
          self,
          "Task_FindWayThroughFire"
        }
      },
      {
        EVENT_Timer,
        {
          "Paris_2_Mission_5.UnloadOldBank",
          self,
          8.1
        }
      },
      {
        EVENT_Timer,
        {
          "Paris_2_Mission_5.LoadNewBank",
          self,
          9.1
        }
      },
      {
        WorldSMEDNodes.LoadNode,
        {
          gsP2M5Dir .. "interiorfrannie",
          "Paris_2_Mission_5.InteriorFrannieLoaded",
          self
        }
      }
    },
    tOnReset = {
      {
        self.UnloadFrannie,
        {self}
      }
    },
    tOnCancel = {}
  })
end

function Paris_2_Mission_5:UnloadOldBank()
  Sound.ReleaseSoundBank("m_P2M5_inGame.bnk")
end

function Paris_2_Mission_5:LoadNewBank()
  Sound.LoadSoundBank("m_p2m5_InGame_02.bnk")
end

function Paris_2_Mission_5:Task_FireFloorCin()
  self:CreateTask({
    sName = "Task_FireFloorCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_CP5Region,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:Task_CP5Region()
  self:CreateTask({
    sName = "Task_CP5Region",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsP2M5Dir .. "main\\REG_EnterInferno"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Paris_2_Mission_5.Checkpoint5"
        }
      }
    }
  })
end

function Paris_2_Mission_5:Checkpoint5()
  print("_____checkpoint 5")
  self:TASK_RescueMaria()
  self:Task_BlowBridge()
  Suspicion.SetEscalated()
  self:FireLevelSetup()
  self:Task_FrannieInteriorEscape()
  if not Object.IsDoorOpen(Handle(self.tInfo.EscapeElevatorDoor)) then
    print("elevator door was closed , re-opening")
    self:OpenElevatorDoor(self.tInfo.EscapeElevatorDoor, true)
  end
end

function Paris_2_Mission_5:FireLevelSetup()
  Object.ForceClose(Handle("PARIS\\area06\\hoteldeville\\interior\\hdv_int\\BoilerBackDoor"))
  self:TurnoffFireGuys()
  self:SetupInfernoFight()
  self:Task_ChandelierCrash()
  self:PurgeSpawners()
  self:FireNaziSpawner()
  self:TASK_Collapse1()
  self:TASK_Collapse4()
  self:TASK_Collapse5()
  self:Task_ElevatorCam()
  self:ElevatorCollapse()
  self:HeatIsBad()
  self:SetupMariaInterior()
end

function Paris_2_Mission_5:TASK_RescueMaria()
  self:CreateTask({
    sName = "TASK_RescueMaria",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    sObjectiveTextID = "P2M5_Text.RescuePrisoner",
    tOnActivate = {},
    tOnCancel = {},
    tOnComplete = {
      {
        self.Task_EnterElevator,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:SetupMariaInterior()
  local hMaria = Handle(self.tInfo.sPrisoner)
  if hMaria then
    Object.SetInvincible(hMaria, true)
    Actor.ChangeModule(hMaria, "Human_Null")
    Actor.SetPanicEnabled(hMaria, false)
    Combat.SetIdleScripted(hMaria, true)
    Actor.OverrideCombatAI(hMaria, true)
  end
end

function Paris_2_Mission_5:FireNaziSpawner()
end

function Paris_2_Mission_5:InteriorFrannieLoaded()
  local hFrannie = Handle(self.tInfo.InteriorFrannie)
  if hFrannie then
    Object.SetInvincible(hFrannie, true)
    Actor.ChangeModule(hFrannie, "Human_Null")
    Actor.OverrideCombatAI(hFrannie, true)
    Actor.SetPanicEnabled(hFrannie, false)
    Combat.SetGrabbable(hFrannie, false)
  end
end

function Paris_2_Mission_5:TurnoffFireGuys()
  for i, nazi in pairs(self.tInfo.FireNazis) do
    local hNazi = Handle(nazi)
    if hNazi then
      print("overriding combat ai", nazi)
      Actor.SetPanicEnabled(hNazi, false)
      Actor.OverrideCombatAI(hNazi, true)
      Object.SetHealth(hNazi, 1500)
    end
  end
  for i, nazi in pairs(self.tInfo.ElevatorNazis) do
    local hNazi = Handle(nazi)
    if hNazi then
      print("overriding combat ai", nazi)
      Actor.SetPanicEnabled(hNazi, false)
      Actor.OverrideCombatAI(hNazi, true)
      Combat.SetIdleScripted(hNazi, true)
    end
  end
end

function Paris_2_Mission_5:Task_ChandelierCrash()
  self:CreateTask({
    sName = "Task_ChandelierCrash",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsP2M5Dir .. "main\\REG_Chandelier"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.Chandelier,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:Chandelier()
  local hObject = Handle("PARIS\\area06\\hoteldeville\\interior\\hdv_int\\PHotel_Chandelier_E(2)")
  if hObject then
    Object.SetKeyFramed(hObject, false)
  else
    print("DEBUG::no chandelier handle!")
  end
end

function Paris_2_Mission_5:TeleportFrannie(vPerson, Locator, bRunAway)
  local hLoc = Handle(Locator)
  local hPerson = Handle(vPerson)
  local exx, exy, exz, x, y, z, smokefxloc
  if hPerson then
    Combat.SetIdleScripted(hPerson, true)
  end
  x, y, z = Object.GetPosition(hLoc)
  if bRunAway then
    exx, exy, exz = Object.GetPosition(hPerson)
  else
    exx, exy, exz = Object.GetPosition(hLoc)
  end
  if (x or y or z) and hPerson then
    local rot = Object.GetAngle(hLoc)
    self:Ziiip(hPerson, x, y, z, rot)
  else
    print("DEBUG P2M:: Couldn't get handle for frannie or locator for teleport")
  end
end

function Paris_2_Mission_5:Ziiip(hPerson, x, y, z, rot)
  local rot = rot
  rot = rot or 0
  print("zip away frannie , zip away")
  Object.Teleport(hPerson, x, y, z, rot)
end

function Paris_2_Mission_5:Task_FrannieInteriorEscape()
  self:CreateTask({
    sName = "Task_FrannieInteriorEscape",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "none",
    bCompleteOnActivate = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.TeleportFrannie,
        {
          self,
          self.tInfo.InteriorFrannie,
          gsP2M5Dir .. "interiorfrannie\\LOC_FrannieElevator"
        }
      },
      {
        self.TeleportFrannie,
        {
          self,
          self.tInfo.sPrisoner,
          gsP2M5Dir .. "interiorfrannie\\LOC_PrisonerElevator"
        }
      },
      {
        self.Task_FollowFrannie1,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:UnloadFrannie()
  print("unload hide frannie")
  WorldSMEDNodes.UnloadNode(gsP2M5Dir .. "interiorfrannie", true)
end

function Paris_2_Mission_5:Task_FrannieHallwayShoot()
  self:CreateTask({
    sName = "Task_FrannieHallwayShoot",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsP2M5Dir .. "interiorfrannie\\REG_Frannie2"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.TeleportFrannie,
        {
          self,
          self.tInfo.InteriorFrannie,
          gsP2M5Dir .. "interiorfrannie\\LOC_FrannieElevator"
        }
      },
      {
        self.InteriorFrannieLoaded,
        {self}
      },
      {
        self.SetupMariaInterior,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:TASK_StayAway()
  self:CreateTask({
    sName = "TASK_StayAway",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "deliver",
    bInteriorTask = true,
    bNoFocus = true,
    bNoHudBlip = true,
    tDestProximityObj = {
      self.tInfo.InteriorFrannie
    },
    Proximity = 2.5,
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.TeleportFrannie,
        {
          self,
          self.tInfo.InteriorFrannie,
          gsP2M5Dir .. "interiorfrannie\\LOC_FrannieHide",
          true
        }
      }
    }
  })
end

function Paris_2_Mission_5:Task_FollowFrannie1()
  self:CreateTask({
    sName = "Task_FollowFrannie1",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Goto",
    bInteriorTask = true,
    Proximity = 5,
    MarkerHeight = 0.5,
    tDeliverObjs = {hSab},
    tDestProximityObj = {
      gsP2M5Dir .. "main\\LOC_HallwayLanding"
    },
    tOnComplete = {},
    tOnActivate = {
      {
        self.Task_FrannieHallwayShoot,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:Task_FollowFrannie2()
  self:CreateTask({
    sName = "Task_FollowFrannie2",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Goto",
    bInteriorTask = true,
    Proximity = 10,
    tDeliverObjs = {hSab},
    tDestProximityObj = {
      gsP2M5Dir .. "main\\LOC_ElevatorLobby"
    },
    tOnComplete = {
      {
        self.CompleteTaskByName,
        {
          self,
          "TASK_RescueMaria"
        }
      }
    },
    tOnActivate = {}
  })
end

function Paris_2_Mission_5:Task_ElevatorCam()
  self:CreateTask({
    sName = "Task_ElevatorCam",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsP2M5Dir .. "main\\REG_ElevatorCam"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    sCinFile = "P2M5_FranElevatorZoom",
    tOnComplete = {
      {
        self.CallbackCloseElevator,
        {}
      },
      {
        EVENT_Timer,
        {
          "Paris_2_Mission_5.UnloadFrannie",
          self,
          5
        }
      },
      {
        self.Task_FollowFrannie2,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5.CallbackCloseElevator()
  local self = Paris_2_Mission_5
  print("closing elevator from script")
  if not self.tSaveInfo.bCloseFrannieElevator then
    self.tSaveInfo.bCloseFrannieElevator = true
    if Object.IsDoorOpen(Handle(self.tInfo.EscapeElevatorDoor)) then
      print("elevator door was open , closing")
      self:OpenElevatorDoor(self.tInfo.EscapeElevatorDoor, false)
    end
  end
end

function Paris_2_Mission_5.CallbackPotshot()
  local self = Paris_2_Mission_5
  print("frannie fires from script")
  self:FrannieShoot()
end

function Paris_2_Mission_5:Task_EnterElevator()
  self:CreateTask({
    sName = "Task_EnterElevator",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Use",
    bInteriorTask = true,
    sObjectiveTextID = "P2M5_Text.UseElevator",
    MarkerHeight = 1.5,
    tTgtInclude = {
      gsP2M5Dir .. "main\\ElevatorTeleporter"
    },
    tOnComplete = {
      {
        Sound.PlayOwnerlessSoundEvent,
        {
          "Elevator_P2m5_start"
        }
      },
      {
        Render.StopHighlight,
        {
          Handle(self.tInfo.ElevatorBoxSwitch)
        }
      },
      {
        Util.SetTime,
        {1, 0}
      },
      {
        Object.ForceClose,
        {
          Handle("PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_Elevator\\GHotel_Elevator_Door\\AnimatedObject_GHotel_Elevator_Panel(1)")
        }
      }
    },
    tOnActivate = {
      {
        self.StartHighlight,
        {
          self,
          self.tInfo.ElevatorBoxSwitch,
          "BookFocusHighlight"
        }
      },
      {
        self.Task_ExitHotel,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:TASK_Collapse1()
  self:CreateTask({
    sName = "Collapse1",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsP2M5Dir .. "main\\REG_Collapse1"
    },
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        self.CollapseProp,
        {
          self,
          "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_Balcony_Destruction(14)\\GHotel_Balcony_Destruction",
          self.tInfo.sCollapseLoc1
        }
      }
    }
  })
end

function Paris_2_Mission_5:TASK_Collapse4()
  self:CreateTask({
    sName = "TASK_Collapse4",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsP2M5Dir .. "main\\REG_Collapse4"
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.CollapseProp,
        {
          self,
          "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_GCeiling_O_Side_A_DAM(8)\\GHotel_GCeiling_O_Side_A_DAM"
        }
      },
      {
        EVENT_Timer,
        {
          "Paris_2_Mission_5.CollapseProp",
          self,
          3,
          "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_GCeiling_O_Side_A_DAM(2)\\GHotel_GCeiling_O_Side_A_DAM"
        }
      },
      {
        EVENT_Timer,
        {
          "Paris_2_Mission_5.CollapseProp",
          self,
          6,
          "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_GCeiling_O_Side_A_DAM(10)\\GHotel_GCeiling_O_Side_A_DAM"
        }
      }
    }
  })
end

function Paris_2_Mission_5:TASK_Collapse5()
  self:CreateTask({
    sName = "TASK_Collapse5",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = {
      gsP2M5Dir .. "main\\REG_Collapse5"
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.CollapseProp,
        {
          self,
          "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_GCeiling_O_Side_A_DAM(11)\\GHotel_GCeiling_O_Side_A_DAM"
        }
      },
      {
        EVENT_Timer,
        {
          "Paris_2_Mission_5.CollapseProp",
          self,
          5,
          "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_GCeiling_O_Side_A_DAM(9)\\GHotel_GCeiling_O_Side_A_DAM"
        }
      }
    }
  })
end

function Paris_2_Mission_5:ElevatorCollapse()
  self:CreateTask({
    sName = "ElevatorCollapse",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "Kill",
    bOptional = true,
    bNoFocus = true,
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    tTgtInclude = {
      "Missions\\paris_2\\mission_5\\hotel_inside\\Squib_Melee"
    },
    tOnComplete = {
      {
        self.OpenElevatorDoor,
        {
          self,
          "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_Elevator(2)\\GHotel_Elevator_Door\\AnimatedObject_GHotel_Elevator_Panel(1)",
          true
        }
      },
      {
        self.SeanIsTheHero,
        {self}
      },
      {
        EVENT_Timer,
        {
          "Paris_2_Mission_5.CollapseProp",
          self,
          1.75,
          "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\GHotel_GCeiling_O_Side_A_DAM\\GHotel_GCeiling_O_Side_A_DAM"
        }
      },
      {
        EVENT_Timer,
        {
          "Paris_2_Mission_5.KillYouDamnNazis",
          self,
          2.25,
          gsP2M5Dir .. "inferno_nazis\\REG_OopsDeathElevator"
        }
      }
    }
  })
end

function Paris_2_Mission_5:SeanIsTheHero()
  for i, nazi in pairs(self.tInfo.ElevatorNazis) do
    local hNazi = Handle(nazi)
    if hNazi then
      Actor.SetPanicEnabled(hNazi, true)
      Actor.OverrideCombatAI(hNazi, false)
      Combat.SetIdleScripted(hNazi, false)
      Actor.SetFacingDir(hNazi, hSab)
    end
  end
end

function Paris_2_Mission_5:HeatIsBad()
  self:CreateTask({
    sName = "HeatIsBad",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    bOptional = true,
    bNoFocus = true,
    bNoHUDBlip = true,
    tDestRegion = {
      "Missions\\paris_2\\mission_5\\inferno_nazis\\REG_HeatConv"
    },
    tDeliverObjs = {hSab},
    sTaskEndConv = "P2M5_GoBacktoSecondFloor",
    tOnComplete = {
      {
        EVENT_Timer,
        {
          "Paris_2_Mission_5.HeatIsReallyBad",
          self,
          5
        }
      }
    }
  })
end

function Paris_2_Mission_5:HeatIsReallyBad()
  Cin.PlayConversation("P2M5_GettingHotFirst")
end

function Paris_2_Mission_5:SetupFeelMyHeat()
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.FeelMyHeat", self, "Missions\\paris_2\\mission_5\\main\\REG_HeatShimmerOn", true, {true})
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.FeelMyHeat", self, "Missions\\paris_2\\mission_5\\main\\REG_HeatShimmerOff", true, {false})
end

function Paris_2_Mission_5:SetupFireCollapse()
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.CallbackCollapseProp", self, "Missions\\paris_2\\mission_5\\main\\REG_HeatShimmerOn", false, {
    "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_GCeiling_O_Side_A_DAM\\GHotel_GCeiling_O_Side_A_DAM"
  })
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.CallbackCollapseProp", self, "Missions\\paris_2\\mission_5\\inferno_nazis\\REG_Fire1", false, {
    "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_GCeiling_O_Side_A_DAM(5)\\GHotel_GCeiling_O_Side_A_DAM"
  })
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.CallbackCollapseProp", self, "Missions\\paris_2\\mission_5\\inferno_nazis\\REG_Fire2", false, {
    "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_GCeiling_O_Side_A_DAM(4)\\GHotel_GCeiling_O_Side_A_DAM"
  })
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.CallbackCollapseProp", self, "Missions\\paris_2\\mission_5\\inferno_nazis\\REG_Spawn5_1", false, {
    "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_GCeiling_O_Side_A_DAM(3)\\GHotel_GCeiling_O_Side_A_DAM"
  })
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.CallbackCollapseProp", self, "Missions\\paris_2\\mission_5\\inferno_nazis\\REG_Spawn3", false, {
    "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_GCeiling_O_Side_A_DAM(6)\\GHotel_GCeiling_O_Side_A_DAM"
  })
  EVENT_PlayerToActorProximity("Paris_2_Mission_5.CollapseProp", self, "Missions\\paris_2\\mission_5\\inferno_nazis\\LOC_Spawn5_2", 5, {
    "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_GCeiling_O_Side_A_DAM(13)\\GHotel_GCeiling_O_Side_A_DAM"
  })
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.CallbackCollapseProp", self, gsP2M5Dir .. "main\\REG_ElevatorCam", false, {
    "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_GCeiling_O_Side_A_DAM(12)\\GHotel_GCeiling_O_Side_A_DAM"
  })
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.CallbackCollapseProp", self, gsP2M5Dir .. "main\\REG_Collapse3", false, {
    "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_GCeiling_O_Side_A_DAM(7)\\GHotel_GCeiling_O_Side_A_DAM"
  })
end

function Paris_2_Mission_5:FeelMyHeat(a_tUserData, bOn)
  if bOn then
    Render.HeatShimmerFilter(0.3, 1.3, 1, 0.9)
  else
    Render.HeatShimmerFilter(0, 0, 0, 0)
  end
end

function Paris_2_Mission_5:Collapse(Loc)
  local hLoc = Handle(Loc)
  local x, y, z = Object.GetPosition(hLoc)
  if x or y or z then
    Util.CreateExplosion("Explosion_P2M5_Ceiling", x, y, z)
  end
end

function Paris_2_Mission_5:CallbackCollapseProp(tArgs, sProp)
  self:CollapseProp(sProp)
end

function Paris_2_Mission_5:CollapseProp(sProp, Loc_Explosion)
  local hProp = Util.GetHandleByName(sProp)
  if hProp then
    Object.Kill(hProp)
  end
  if Loc_Explosion then
    self:Collapse(Loc_Explosion)
  end
end

function Paris_2_Mission_5:Task_BlowBridge()
  self:CreateTask({
    sName = "Task_BlowBridge",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "goto",
    tDestRegion = {
      gsP2M5Dir .. "main\\REG_Collapse2"
    },
    tDeliverObjs = {hSab},
    bInteriorTask = true,
    tOnComplete = {
      {
        self.Task_CinematicBlowBridge,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:Task_CinematicBlowBridge()
  self:CreateTask({
    sName = "Task_CinematicBlowBridge",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    tOnActivate = {
      {
        EVENT_Timer,
        {
          "Paris_2_Mission_5.CollapseProp",
          self,
          1,
          {
            "PARIS\\area06\\hoteldeville\\interior\\hdv_int\\INT_Grand_Hotel_Test\\GHotel_Balcony_Destruction\\GHotel_Balcony_Destruction",
            self.tInfo.sCollapseLoc2
          }
        }
      }
    },
    tOnComplete = {}
  })
end

function Paris_2_Mission_5:FrannieRunAway(Loc)
  local hLoc = Handle(Loc)
  local hFrannie = Handle(self.tInfo.InteriorFrannie)
  if hLoc and hFrannie then
    Combat.SetIdleScripted(hFrannie, true)
    Nav.MoveToObject(hFrannie, hLoc, 3, true)
    EVENT_Timer("Paris_2_Mission_5.TeleportFrannie", self, 3, {
      self.tInfo.InteriorFrannie,
      gsP2M5Dir .. "interiorfrannie\\LOC_FrannieHide",
      true
    })
  else
    self:TeleportFrannie(self.tInfo.InteriorFrannie, gsP2M5Dir .. "interiorfrannie\\LOC_FrannieHide", true)
  end
  EVENT_Timer("Paris_2_Mission_5.TeleportFrannie", self, 4.75, {
    self.tInfo.InteriorFrannie,
    gsP2M5Dir .. "interiorfrannie\\LOC_FrannieHide",
    true
  })
end

function Paris_2_Mission_5:FrannieShoot()
  local hFrannie = Handle(self.tInfo.InteriorFrannie)
  Actor.PlayAnimation(hFrannie, "civ_f_frustrated_LOOP", 3, true)
end

function Paris_2_Mission_5:SetupInfernoFight()
  local hNazi3 = Handle(gsP2M5Dir .. "inferno_nazis\\ImmolateMe3")
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.RunNaziRun", self, gsP2M5Dir .. "inferno_nazis\\REG_Scare", false, hNazi3)
  local hNazi2 = Handle(gsP2M5Dir .. "inferno_nazis\\ImmolateMe2")
  local hLoc = Handle(gsP2M5Dir .. "inferno_nazis\\LOC_FireRunto2")
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.RunNaziRun", self, gsP2M5Dir .. "inferno_nazis\\REG_Scare2", false, {hNazi2, hLoc})
  local hNazi = Handle(gsP2M5Dir .. "inferno_nazis\\ImmolateMe1")
  local hLoc = Handle(gsP2M5Dir .. "inferno_nazis\\LOC_FireRunto1")
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.RunNaziRun", self, gsP2M5Dir .. "inferno_nazis\\REG_Fire1", false, {hNazi, hLoc})
  self:SetupFeelMyHeat()
  self:SetupFireCollapse()
end

function Paris_2_Mission_5:RunNaziRun(tArgs, hNazi, hLoc)
  if not hNazi then
    return
  end
  local hStop = hLoc
  hStop = hStop or hSab
  if hNazi and Object.IsAlive(hNazi) and hStop then
    self:Immolate(hNazi)
    Combat.SetIdleScripted(hNazi, true)
    Nav.MoveToObject(hNazi, hStop, 4, true, "Paris_2_Mission_5.KillOnFireNazi", self, {hNazi})
    EVENT_Timer("Paris_2_Mission_5.KillOnFireNazi", self, 6, hNazi)
  end
end

function Paris_2_Mission_5:Immolate(hNazi)
  if hNazi then
    Actor.Immolate(hNazi)
  end
end

function Paris_2_Mission_5:KillOnFireNazi(hNazi)
  if hNazi and Object.IsAlive(hNazi) then
    self:Immolate(hNazi)
    Object.Kill(hNazi)
  end
end

function Paris_2_Mission_5:Task_ExitHotel()
  self:CreateTask({
    sName = "Task_ExitHotel",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "HDV",
    bInteriorTask = true,
    bNoGPS = true,
    tOnComplete = {
      {
        Sound.PlayOwnerlessSoundEvent,
        {
          "Elevator_P2m5_stop"
        }
      },
      {
        self.RemoveMyLoadedNodes,
        {self}
      },
      {
        self.KillYouDamnNazis,
        {
          self,
          gsP2M5Dir .. "hotel_entrance\\REG_KillingNazis"
        }
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "Paris_2_Mission_5.Checkpoint6"
        }
      }
    },
    tOnActivate = {
      {
        self.LoadExteriorMaria,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:LoadExteriorMaria()
  Util.SetDynamicPriority("Human_RS_Maria", 800)
  WorldSMEDNodes.LoadNode(gsP2M5Dir .. "exteriormaria", "Paris_2_Mission_5.ExteriorMariaLoaded", self)
end

function Paris_2_Mission_5:Checkpoint6()
  print("_____checkpoint 6")
  Suspicion.EnableEscalation(true)
  Util.EnableSuperSpores(false)
  Suspicion.SetEscalated()
  self:OpenElevatorDoor(self.tInfo.ExteriorElevatorDoor, false)
  self:Task_CinPreFight()
  self:PurgeSpawners()
  self:TASK_LoadMiniZepp()
  if Vehicle.IsTrafficEnabled() then
    Vehicle.EnableTraffic(false, true)
  end
  self:KillYouDamnNazis(gsP2M5Dir .. "hotel_entrance\\REG_KillingNazis")
  Sound.SetMusicLocale("P2M5_BoilingPoint")
  Sound.SetMusicLocale("m_P2M5_BoilingPoint", "roofFight")
end

function Paris_2_Mission_5:Task_CinPreFight()
  self:CreateTask({
    sName = "Task_CinPreFight",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    tSMEDNodes = {
      gsP2M5Dir .. "frannie",
      gsP2M5Dir .. "hdv_roof_smoke1a"
    },
    tOnActivate = {
      {
        self.OpenElevatorDoor,
        {
          self,
          self.tInfo.ExteriorElevatorDoor,
          true
        }
      }
    },
    tOnComplete = {
      {
        self.TASK_DefeatFrannie,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:KillYouDamnNazis(vTrigger)
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

function Paris_2_Mission_5:OpenElevatorDoor(sDoor, bOpen)
  local hDoor = Handle(sDoor)
  if not hDoor then
    Util.Assert(false, "Cfrench:Paris_2_Mission_5.OpenElevatorDoor failed to get door handle " .. sDoor)
    print("Paris_2_Mission_5.OpenElevatorDoor failed to get door handle ", sDoor)
    return
  end
  if bOpen then
    Object.ForceOpen(hDoor)
  else
    Object.ForceClose(hDoor)
  end
end

function Paris_2_Mission_5:TASK_DefeatFrannie()
  self:CreateTask({
    sName = "TASK_DefeatFrannie",
    sTaskType = "SabTaskObjectiveDestroy",
    sObjectiveTextID = "P2M5_Text.KillTerrorOfficer",
    sTaskSubType = "Kill",
    tTgtInclude = {
      self.tInfo.sFrannie,
      gsP2M5Dir .. "frannie\\TS2",
      gsP2M5Dir .. "frannie\\TS3"
    },
    tOnActivate = {
      {
        EVENT_Timer,
        {
          "Paris_2_Mission_5.SummonUpdate",
          self,
          8
        }
      },
      {
        self.SetupFrannieFight,
        {self}
      },
      {
        self.Task_KillPlayer,
        {self}
      },
      {
        self.ElevatorDeathSetup,
        {self}
      },
      {
        Combat.SetLeader,
        {
          Handle("Missions\\paris_2\\mission_5\\frannie\\TS3"),
          Handle(self.tInfo.sFrannie),
          false,
          4,
          4
        }
      }
    },
    tOnComplete = {
      {
        Combat.BroadcastRetreat,
        {hSab, 75}
      },
      {
        self.Task_WTFChange,
        {self}
      },
      {
        self.AllowSummoning,
        {self, false}
      }
    },
    tOnReset = {},
    tOnCancel = {}
  })
end

function Paris_2_Mission_5:ExteriorMariaLoaded()
  print("Exterior maria loaded")
end

function Paris_2_Mission_5:SetupMaria()
  local hMaria = Handle(self.tInfo.sArenaPrisoner)
  local hAttrpt = Handle(gsP2M5Dir .. "exteriormaria\\AttractionPT_CowerForever")
  if hMaria then
    Object.SetHealth(hMaria, 500)
    Combat.SetIdleScripted(hMaria, true)
    Actor.OverrideCombatAI(hMaria, true)
    Actor.SetUseHitReactions(hMaria, false)
    Combat.SetGrabbable(hMaria, false)
    if hAttrpt then
      Actor.UseAttrPt(hMaria, hAttrpt)
    end
  end
end

function Paris_2_Mission_5:Task_MariaDeathFail()
  EVENT_ActorDeath("Paris_2_Mission_5.MariaDeath", self, self.tInfo.sArenaPrisoner)
end

function Paris_2_Mission_5:MariaDeath()
  self:MissionTaskFail("CFRENCH ADD MARIA DEATH TEXTID")
end

function Paris_2_Mission_5:ReloadCP()
end

function Paris_2_Mission_5:TASK_LoadMiniZepp()
  self:CreateTask({
    sName = "TASK_LoadMiniZepp",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bCompleteOnActivate = true,
    tSMEDNodes = {
      gsP2M5Dir .. "minizepp"
    },
    tOnCancel = {},
    tOnActivate = {
      {
        self.CatchChewZeppelin,
        {self}
      }
    },
    tOnReset = {
      {
        self.ReleaseChewZeppelin,
        {self}
      }
    }
  })
end

function Paris_2_Mission_5:CatchChewZeppelin()
  print("catching the mini zep ")
  Util.SetMiniZepSpline("Missions\\paris_2\\mission_5\\minizepp\\MobySpline")
  self:ZeppShootin(false)
end

function Paris_2_Mission_5:ReleaseChewZeppelin()
  print("releasing the mini zep ")
  self:ZeppShootin(true)
  Util.ClearMiniZepSpline()
end

function Paris_2_Mission_5:CallbackBossZone(tArgs, bInside)
  if bInside then
    EVENT_PlayerExitsTrigger("Paris_2_Mission_5.CallbackBossZone", self, gsP2M5Dir .. "frannie\\REG_BossZone", false, {false})
    self:ZeppShootin(false)
  else
    EVENT_PlayerEntersTrigger("Paris_2_Mission_5.CallbackBossZone", self, gsP2M5Dir .. "frannie\\REG_BossZone", false, {true})
    self:ZeppShootin(true)
  end
end

function Paris_2_Mission_5:ZeppShootin(bOn)
  print("zepp shootin: ", bOn)
  Util.EnableMiniZepShooting(bOn)
end

function Paris_2_Mission_5:TASK_LoadElevatorSmoke()
  self:CreateTask({
    sName = "TASK_LoadElevatorSmoke",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bCompleteOnActivate = true,
    tSMEDNodes = {
      gsP2M5Dir .. "elevatorsmoke"
    }
  })
end

function Paris_2_Mission_5:SetupFrannieFight()
  self:SetupMaria()
  self._FranSpawners = {}
  self.tInfo.tFranNaziSpawns = {}
  local hFran = Handle(self.tInfo.sFrannie)
  Combat.SetCombat(hFran)
  Combat.SetTarget(hFran, hSab)
  self.tFranziskaFight = {
    sNode = gsP2M5Dir .. "frannie\\",
    tSpawners = {
      "Spawn_Support01"
    },
    iSummonMax = 1,
    tSummonIdleTime = {fMin = 1.5, fMax = 1.5},
    fSummonDelay = 30,
    tSummonBlueprints = {
      "Human_WM_Grunt_MG"
    },
    tExplosionDelay = {fMin = 2, fMax = 7},
    tExplosionLocs = {
      "LOC_Explosion_Stage01_01",
      "LOC_Explosion_Stage01_02",
      "LOC_Explosion_Stage01_03",
      "LOC_Explosion_Stage01_04",
      "LOC_Explosion_Stage01_05",
      "LOC_Explosion_Stage01_06",
      "LOC_Explosion_Stage01_07"
    },
    tExplosionFX = {
      "Explosion_Large",
      "Explosion_Small"
    }
  }
  local tSpawnerConfig = {
    sSpawnerName = gsP2M5Dir .. "frannie\\Spawn_Support01",
    tLocators = {
      gsP2M5Dir .. "frannie\\LOC_Spawn1"
    },
    sSpawnDoor = self.tInfo.ExteriorElevatorDoor,
    fSpawnCallback = Paris_2_Mission_5.OnElevatorSpawn,
    tSelf = self,
    bTether = true,
    TetherRadius = 3
  }
  local MySpawner = AggroSpawner:CreateSpawner(tSpawnerConfig)
  table.insert(self._FranSpawners, MySpawner)
  local tSpawnerConfig = {
    sSpawnerName = gsP2M5Dir .. "frannie\\Spawn_Support02",
    tLocators = {
      gsP2M5Dir .. "frannie\\LOC_Spawn2"
    },
    sSpawnDoor = self.tInfo.ExteriorElevatorDoor,
    fSpawnCallback = Paris_2_Mission_5.OnElevatorSpawn,
    tSelf = self,
    bTether = true,
    TetherRadius = 3
  }
  local MySpawner = AggroSpawner:CreateSpawner(tSpawnerConfig)
  table.insert(self._FranSpawners, MySpawner)
  self:AllowSummoning(true)
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.ElevatorWatch", self, self.tInfo.ExteriorElevatorReg, true, {true})
  EVENT_PlayerExitsTrigger("Paris_2_Mission_5.ElevatorWatch", self, self.tInfo.ExteriorElevatorReg, true, {false})
  self:CallbackBossZone({}, true)
  Combat.SetObjective(hFran, Handle("Missions\\paris_2\\mission_5\\frannie\\LOC_HuntSpot03_01"), true, -1, false)
end

function Paris_2_Mission_5:FranFightRandomExplosion()
  if #self.tFranziskaFight.tExplosionLocs == 0 then
    while 0 < #self.tFranziskaFight.tExplosionUsedLocs do
      table.insert(self.tFranziskaFight.tExplosionLocs, self.tFranziskaFight.tExplosionUsedLocs[1])
      table.remove(self.tFranziskaFight.tExplosionUsedLocs, 1)
    end
  end
  local iExplosionLoc = math.random(#self.tFranziskaFight.tExplosionLocs)
  local iExplosionFX = math.random(#self.tFranziskaFight.tExplosionFX)
  if self.tFranziskaFight.sExplosionVO then
    Cin.PlayConversation(self.tFranziskaFight.sExplosionVO)
    iExplosionFX = 1
    iExplosionLoc = 1
    self.tFranziskaFight.sExplosionVO = nil
  end
  local hLoc = Handle(self.tFranziskaFight.sNode .. self.tFranziskaFight.tExplosionLocs[iExplosionLoc])
  local x, y, z = Object.GetPosition(hLoc)
  Util.CreateExplosion(self.tFranziskaFight.tExplosionFX[iExplosionFX], x, y, z)
  table.insert(self.tFranziskaFight.tExplosionUsedLocs, self.tFranziskaFight.tExplosionLocs[iExplosionLoc])
  table.remove(self.tFranziskaFight.tExplosionLocs, iExplosionLoc)
  local fRandTime = self.tFranziskaFight.tExplosionDelay.fMin + (self.tFranziskaFight.tExplosionDelay.fMax - self.tFranziskaFight.tExplosionDelay.fMin) * math.random()
  self.tFranziskaFight.hExplosionEvent = EVENT_Timer("Paris_2_Mission_5.FranFightRandomExplosion", self, fRandTime)
end

function Paris_2_Mission_5:ElevatorWatch(tTriggerData, bInTrigger)
  if bInTrigger then
    self.tSaveInfo.bPlayerInElevator = true
    self:OpenElevatorDoor(self.tInfo.ExteriorElevatorDoor, true)
  else
    self.tSaveInfo.bPlayerInElevator = false
  end
end

function Paris_2_Mission_5:SummonUpdate()
  if self.tSaveInfo.bElevatorDead then
    return
  end
  if not self:IsMissionTaskActive("TASK_DefeatFrannie") then
    return
  end
  if self.tSaveInfo.bFineSummon and self.tSaveInfo.bSummonDelay then
    print("Update:allowing summon")
    self:FranWantsToSummon()
  else
  end
end

function Paris_2_Mission_5:AllowSummoning(bOn)
  print("Allow summoning?", bOn)
  local bOn = bOn or false
  self.tSaveInfo.bFineSummon = bOn
end

function Paris_2_Mission_5:ResetSummonTimerDelay()
  local delay = self.tFranziskaFight.fSummonDelay or 20
  self:SetSummonDelay(false)
  EVENT_Timer("Paris_2_Mission_5.SetSummonDelay", self, delay, {true})
end

function Paris_2_Mission_5:SetSummonDelay(bOn)
  local bOn = bOn or false
  self.tSaveInfo.bSummonDelay = bOn
  self:SummonUpdate()
end

function Paris_2_Mission_5:FranWantsToSummon()
  print("Fran wants to summon")
  if self.tSaveInfo.bElevatorDead then
    return
  end
  if not self.tSaveInfo.bPlayerInElevator then
    self:OpenElevatorDoor(self.tInfo.ExteriorElevatorDoor, false)
  elseif self.tSaveInfo.bPlayerInElevator then
    print("player is in elevator dont spawn yet")
    EVENT_Timer("Paris_2_Mission_5.SummonUpdate", self, 5)
    return
  end
  if Object.IsDoorOpen(Handle(self.tInfo.ExteriorElevatorDoor)) then
    self:OpenElevatorDoor(self.tInfo.ExteriorElevatorDoor, false)
    print("door is opend dont spawn yet")
    EVENT_Timer("Paris_2_Mission_5.SummonUpdate", self, 5)
    return
  end
  if not self.tFranziskaFight.iSummonMax then
    self.tFranziskaFight.iSummonMax = self.tInfo.MAXLiveSpawnNazis
  end
  local MAXSPAWNS = self.tFranziskaFight.iSummonMax
  if self.tSaveInfo.bFineSummon and not self.tSaveInfo.bPlayerInElevator then
    local QueuedSpawned = 0
    local MaybeThisMany = MAXSPAWNS - #self.tInfo.tFranNaziSpawns
    local SpawnThisMany
    if 1 < MaybeThisMany then
      SpawnThisMany = MaybeThisMany
    else
      SpawnThisMany = MaybeThisMany
    end
    self:AllowSummoning(false)
    local sBP
    if self.tFranziskaFight.tSummonBlueprints then
      local randomindex = math.random(#self.tFranziskaFight.tSummonBlueprints)
      sBP = self.tFranziskaFight.tSummonBlueprints[randomindex]
    end
    for _, oSpawner in pairs(self._FranSpawners) do
      if QueuedSpawned < SpawnThisMany then
        QueuedSpawned = QueuedSpawned + 1
        oSpawner:QueueSpawner(sBP)
      end
    end
    self.tSaveInfo.ElevatorSpawnTotalTimes = self.tSaveInfo.ElevatorSpawnTotalTimes + 1
    EVENT_Timer("Paris_2_Mission_5.CheckElevatorSpawns", self, 3)
    EVENT_Timer("Paris_2_Mission_5.ElevatorAction", self, 12)
  end
end

function Paris_2_Mission_5:CheckElevatorSpawns()
  if not self:IsMissionTaskActive("TASK_DefeatFrannie") then
    return
  end
  if self.tSaveInfo.ElevatorSpawnTotalTimes == 3 then
    Cin.PlayConversation("P2M5_ArenaElevator")
  elseif self.tSaveInfo.ElevatorSpawnTotalTimes == 2 then
    Cin.PlayConversation("P2M5_ArenaElevator_Respawn")
  end
end

function Paris_2_Mission_5:ElevatorAction()
  local hDoor = Handle(self.tInfo.ExteriorElevatorDoor)
  if not self.tSaveInfo.bPlayerInElevator and not self:IsNaziInElevator() and not Object.IsDoorOpen(hDoor) then
    EVENT_Timer("Paris_2_Mission_5.ElevatorReset", self, 3)
  elseif not self.tSaveInfo.bPlayerInElevator and not self:IsNaziInElevator() and Object.IsDoorOpen(hDoor) then
    self:OpenElevatorDoor(self.tInfo.ExteriorElevatorDoor, false)
    EVENT_Timer("Paris_2_Mission_5.ElevatorAction", self, 2)
  else
    EVENT_Timer("Paris_2_Mission_5.ElevatorAction", self, 2)
  end
end

function Paris_2_Mission_5:IsNaziInElevator()
  local bIsNaziInElevator = false
  for _, tInfo in pairs(self.tInfo.tFranNaziSpawns) do
    if tInfo.bInElevator then
      bIsNaziInElevator = true
      break
    end
  end
  if not bIsNaziInElevator then
  end
  return bIsNaziInElevator
end

function Paris_2_Mission_5:ElevatorReset()
  local hDoor = Handle(self.tInfo.ExteriorElevatorDoor)
  if not self.tFranziskaFight.iSummonMax then
    self.tFranziskaFight.iSummonMax = self.tInfo.MAXLiveSpawnNazis
  end
  if not self.tSaveInfo.bPlayerInElevator and not Object.IsDoorOpen(hDoor) and #self.tInfo.tFranNaziSpawns < self.tFranziskaFight.iSummonMax then
    self:AllowSummoning(true)
    self:ResetSummonTimerDelay()
  else
    EVENT_Timer("Paris_2_Mission_5.ElevatorReset", self, 2)
  end
end

function Paris_2_Mission_5:OnElevatorSpawn(hNazi)
  if self.tSaveInfo.bElevatorDead then
    local hLoc = Handle("Missions\\paris_2\\mission_5\\hotel_entrance\\LOC_ExteriorElevator")
    if hLoc then
      local x, y, z = Object.GetPosition(hLoc)
      Util.CreateExplosion("Explosion_SAB_DynamiteFuse", x, y, z)
    end
  end
  if hNazi then
    EVENT_ActorDeath("Paris_2_Mission_5.OnSpawnNaziDeath", self, hNazi, hNazi)
    EVENT_ActorExitsTrigger("Paris_2_Mission_5.NaziExitsElevator", self, hNazi, self.tInfo.ExteriorElevatorReg, hNazi)
    local tInfo = {}
    tInfo.hNazi = hNazi
    tInfo.bInElevator = true
    table.insert(self.tInfo.tFranNaziSpawns, tInfo)
  end
end

function Paris_2_Mission_5:NaziExitsElevator(tArgs, hNazi)
  for _, tInfo in pairs(self.tInfo.tFranNaziSpawns) do
    if tInfo.hNazi == hNazi then
      tInfo.bInElevator = false
    end
  end
end

function Paris_2_Mission_5:OnSpawnNaziDeath(hNazi)
  for i, tInfo in pairs(self.tInfo.tFranNaziSpawns) do
    if tInfo.hNazi == hNazi then
      table.remove(self.tInfo.tFranNaziSpawns, i)
      break
    end
  end
end

function Paris_2_Mission_5:ElevatorDeathSetup()
  local hSquib = Handle("Missions\\paris_2\\mission_5\\hdv_ext_nazi\\Squib_DynamiteFuse")
  if hSquib then
    EVENT_ActorDeath("Paris_2_Mission_5.ElevatorDeath", self, hSquib)
  else
    print("Failed to get handle to elevator squib, its colby tag is  HDV_Mission")
  end
end

function Paris_2_Mission_5:ElevatorDeath()
  self:TASK_LoadElevatorSmoke()
  self:OpenElevatorDoor(self.tInfo.ExteriorElevatorDoor, true)
  self.tSaveInfo.bElevatorDead = true
  Cin.PlayConversation("P2M5_SabotagedElevator")
end

function Paris_2_Mission_5:Task_KillPlayer()
  self:CreateTask({
    sName = "Task_KillPlayer",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "goto",
    tDestRegion = {
      gsP2M5Dir .. "frannie\\REG_DeathZone"
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        Object.Kill,
        {hSab}
      }
    }
  })
end

function Paris_2_Mission_5:KillPlayer()
  Object.Kill(hSab)
end

function Paris_2_Mission_5:Task_TalkMaria()
  self:CreateTask({
    sName = "Task_TalkMaria",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Talk",
    sObjectiveTextID = "P2M5_Text.RescuePrisoner",
    sConvFile = "P2M5_Maria_Comfort",
    tTgtInclude = {
      self.tInfo.sArenaPrisoner
    },
    tOnComplete = {
      {
        self.Task_EnterEscapeElevator,
        {self}
      },
      {
        self.Task_BlipMaria,
        {self}
      }
    },
    tOnActivate = {
      {
        Actor.CancelAttrPt,
        {
          Handle(self.tInfo.sArenaPrisoner)
        }
      },
      {
        Actor.CancelAttrPtRequest,
        {
          Handle(self.tInfo.sArenaPrisoner)
        }
      },
      {
        EVENT_Timer,
        {
          "Paris_2_Mission_5.SetMariaFacing",
          self,
          2
        }
      },
      {
        self.KillYouDamnNazis,
        {
          self,
          "Missions\\paris_2\\mission_5\\frannie\\REG_DieNazis"
        }
      }
    }
  })
end

function Paris_2_Mission_5:Task_BlipMaria()
  self:CreateTask({
    sName = "Task_BlipMaria",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "ESCORT",
    tTgtInclude = {
      self.tInfo.sArenaPrisoner
    },
    tOnActivate = {}
  })
end

function Paris_2_Mission_5:SetMariaFacing()
  local hLoc = Handle("Missions\\paris_2\\mission_5\\frannie\\LOC_FrannieCenter")
  local hMaria = Handle(self.tInfo.sArenaPrisoner)
  Actor.SetFacingDir(hMaria, hLoc)
end

function Paris_2_Mission_5:Task_EndScene()
  self:CreateTask({
    sName = "Task_EndScene",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    bOverrideFade = true,
    tOnActivate = {},
    tOnComplete = {}
  })
end

function Paris_2_Mission_5:RegisterCheckpoint7()
  self:RegisterCheckpoint("Paris_2_Mission_5.Checkpoint7")
end

function Paris_2_Mission_5:Checkpoint7()
  print("_____checkpoint 7")
  self:AllowSummoning(false)
  self:PurgeSpawners()
  self:Task_TalkMaria()
end

function Paris_2_Mission_5:Task_EnterEscapeElevator()
  self:CreateTask({
    sName = "Task_EnterEscapeElevator",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P2M5_Text.GetOnElevator",
    tDestRegion = {
      gsP2M5Dir .. "hotel_entrance\\REG_EscapeElevator"
    },
    MarkerHeight = 0.5,
    tLocators = {
      gsP2M5Dir .. "hotel_entrance\\LOC_EscapeElevator"
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.KillTaskByName,
        {
          self,
          "Task_KillPlayer"
        }
      },
      {
        self.TeleportMariaElevator,
        {self}
      }
    },
    tOnActivate = {
      {
        self.RunMaria,
        {self}
      }
    },
    tOnCancel = {}
  })
end

function Paris_2_Mission_5:Task_Escape()
  self:CreateTask({
    sName = "Task_Escape",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P2M5_Text.EscapeHotel",
    tDestRegion = {
      gsP2M5Dir .. "hotel_entrance\\REG_Finish"
    },
    MarkerHeight = 0.5,
    tLocators = {
      gsP2M5Dir .. "hotel_entrance\\LOC_Finish"
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        Sound.ResetMusicLocale,
        {}
      },
      {
        Combat.ClearLeader,
        {
          Handle(self.tInfo.sArenaPrisoner)
        }
      },
      {
        Suspicion.ResetEscalation,
        {}
      },
      {
        self.CompleteThisMission,
        {self}
      }
    },
    tOnActivate = {
      {
        self.OhMariaYouBreakaMyHeart,
        {self}
      }
    },
    tOnCancel = {}
  })
end

function Paris_2_Mission_5:OhMariaYouBreakaMyHeart()
  print("maria breaks heart")
  self:NoReallyIWantYouToTeleport()
  EVENT_Timer("Paris_2_Mission_5.FollowPlayer", self, 1)
end

function Paris_2_Mission_5:FollowPlayer()
  print("follow player")
  local hMaria = Handle(self.tInfo.sArenaPrisoner)
  Combat.SetLeader(hMaria, hSab, true)
end

function Paris_2_Mission_5:Task_WTFChange()
  self:CreateTask({
    sName = "Task_WTFChange",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Cinematic",
    sCinFile = "WTF_P2M5_BoilingPoint",
    tCinematicNodes = {
      "p2m5_boilingpoint"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        Sound.PlayMusicStab,
        {
          "Success_Stab"
        }
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "Paris_2_Mission_5.Checkpoint7"
        }
      }
    }
  })
end

function Paris_2_Mission_5:RunMaria()
  local hLoc = Handle(gsP2M5Dir .. "frannie\\LOC_MariaRunToElevator")
  local hMaria = Handle(self.tInfo.sArenaPrisoner)
  Actor.OverrideCombatAI(hMaria, false)
  if hMaria then
    print("run maria run")
    Actor.SetUseHitReactions(hMaria, true)
    Actor.CancelAttrPt(hMaria)
    Actor.CancelAttrPtRequest(hMaria)
    Combat.SetLeader(hMaria, hSab, true)
  end
end

function Paris_2_Mission_5:GetMariaOnElevator()
  EVENT_FadeInOut(3)
  EVENT_Timer("Paris_2_Mission_5.TeleportMariaElevator", self, 1.5)
  EVENT_Timer("Paris_2_Mission_5.MariaSequenceDone", self, 2.75)
end

function Paris_2_Mission_5:TeleportMariaElevator()
  local hLoc = Handle(gsP2M5Dir .. "hotel_entrance\\LOC_ExtTeleSean")
  local x, y, z = Object.GetPosition(hLoc)
  local rot = Object.GetAngle(hLoc)
  if hLoc then
    Object.PlayerTeleportToLocator(hLoc, "Paris_2_Mission_5.Task_Escape", self)
  elseif not hLoc then
    print("no handle to locator for sab  teleport")
  end
  self:NoReallyIWantYouToTeleport()
end

function Paris_2_Mission_5:NoReallyIWantYouToTeleport()
  local hMaria = Handle(self.tInfo.sArenaPrisoner)
  local hLoc = Handle(gsP2M5Dir .. "hotel_entrance\\LOC_ExtTeleMaria")
  local x, y, z = Object.GetPosition(hLoc)
  local rot = Object.GetAngle(hLoc)
  Actor.CancelAttrPt(hMaria)
  Actor.CancelAttrPtRequest(hMaria)
  if hMaria and hLoc then
    print("teleport maria")
    Combat.ClearLeader(hMaria)
    Actor.SetUseHitReactions(hMaria, true)
    Actor.OverrideCombatAI(hMaria, false)
    Object.Teleport(hMaria, x, y, z, rot)
  elseif not hMaria then
    print("not handle to teleport maria")
  elseif not hLoc then
    print("no handle to locator to teleport")
  end
end

function Paris_2_Mission_5:MariaSequenceDone()
  Actor.TurnOnDude(hSab, true)
  self:OpenElevatorDoor(self.tInfo.EscapeElevator, false)
  EVENT_PlayerEntersTrigger("Paris_2_Mission_5.RunMaria", self, gsP2M5Dir .. "hotel_entrance\\REG_MagicMissle")
end
