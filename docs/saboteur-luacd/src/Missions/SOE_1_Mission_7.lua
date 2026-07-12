if SOE_1_Mission_7 == nil then
  SOE_1_Mission_7 = SabTaskObjective:Create()
  SOE_1_Mission_7.PATH = "Missions\\soe_1\\mission_7\\"
  SOE_1_Mission_7:Configure({
    TaskCount = 999,
    sConvFile = "319_Con_Aurora",
    sStarter = "vittore_garage",
    sHQStartPoint = _cHQ_BELLE,
    sHQNextMissionStartPoint = _cHQe_AURORA,
    sSaveMissionNameID = "MissionNames_Text.S1M7",
    tUnlockList = {
      "SOE_1_Mission_7b"
    },
    tSMEDNodes = {
      SOE_1_Mission_7.PATH .. "main"
    },
    tStaticTags = {
      "soe1m7_props",
      "soe1m7_Outside_Nazi_LWTF",
      "SOE1M7_Contraband",
      "soe1m7_explosives"
    }
  })
end

function SOE_1_Mission_7:STARTER_Setup()
end

function SOE_1_Mission_7:Activated()
  SabTaskObjective.Activated(self)
  self.bDebugMode = false
  self.sDebugLabel = "SOE.1.7"
  self.GENERAL_Setup(self)
  self:RegisterCheckpoint("SOE_1_Mission_7.Checkpoint1")
end

function SOE_1_Mission_7:GENERAL_Setup()
  Sound.LoadSoundBank("m_S1M7_inGame.bnk")
  self:AddOnCompleteCallback(SOE_1_Mission_7.Reset)
  self.sAurora = "CountrySide\\centre\\chateaudeisenbourg\\aurora\\VH_CV_CR_Aurora_01"
  self.sEscapeRegion = self.PATH .. "main\\PT_EscapeRegion"
  self.sLabEntranceLoc = self.PATH .. "main\\LC_LabEntrance"
  self.sLabAlarmRegion = self.PATH .. "nazis\\PT_AlarmRegionCave"
  self.sCarSpawnLoc = self.PATH .. "aurora\\LOC_CarSpawn"
  self.sLabEntranceTrig = self.PATH .. "main\\PT_LabEntrance"
  self.sFortressRegion = self.PATH .. "main\\PT_S1M7_AtopCliff_FindCave"
  self.sInsideFortress = self.PATH .. "main\\LOC_InsideFortress"
  self.sLab = self.PATH .. "main\\LOC_Lab"
  self.sCarDude = self.PATH .. "angry\\Spore_SS_Officer_CarDude"
  self.sExitTrigger = self.PATH .. "main\\PT_TriggerOpenExitDoor"
  self.sWTFTrigger = self.PATH .. "main\\PT_WTFchange"
  self.sCloseGarageTrig = self.PATH .. "main\\PT_CloseGarageTrig"
  self.sActivateLab = self.PATH .. "main\\PT_ActivateGuysInLab"
  self.DoorToLab01 = "CountrySide\\centre\\chateaudeisenbourg\\bunker\\Isn_Bunker_ENT_Trapdoor_B(1)"
  self.DoorToLab02 = "CountrySide\\centre\\chateaudeisenbourg\\bunker\\Isn_Bunker_ENT_Trapdoor_B(2)"
  self.DoorToBunker02 = "CountrySide\\centre\\chateaudeisenbourg\\fences\\OccMed_Bunker_Door_sml(3)"
  self.DoorToBunker01 = "CountrySide\\centre\\chateaudeisenbourg\\fences\\OccMed_Bunker_Door_sml(4)"
  self.sGoodWayIn = self.PATH .. "main\\PT_GoodWayIn"
  self.sAnotherWayIn = self.PATH .. "main\\PT_FindWayAround"
  self.sCompleteMission = self.PATH .. "main\\PT_MissionComplete"
  self.sLocateChateau = self.PATH .. "main\\PT_LocateChateau"
  self.sBestEntrance = self.PATH .. "main\\PT_BestEntrance"
  self.sBestEntBlip = self.PATH .. "main\\LOC_BestEntrance"
  self.sAAGun2 = self.PATH .. "main\\LOC_AAGun2"
  self.sEckhardtOfficeTrig = self.PATH .. "main\\PT_InsideEckhardtOffice"
  self.sEckInvisibleTrig = self.PATH .. "main\\PT_MakeEckhardtOffice"
  self.sEckhardtOfficeLOC = self.PATH .. "main\\LOC_InsideEckhardtOffice"
  self.sEckhardtCar = self.PATH .. "EckFranCave\\Eckhardt_Kubel"
  self.sDoorLocked = "CountrySide\\centre\\chateaudeisenbourg\\fences\\AnimatedObject_DoorToLab"
  self.sEckhardt = self.PATH .. "EckFranCave\\Spore_NZ_Eckhardt"
  self.sFranziska = self.PATH .. "EckFranCave\\Spore_NZ_Franziska"
  self.sWineEntranceTrig = self.PATH .. "main\\PT_LabEntrance3"
  self.sWineEntranceLOC = self.PATH .. "main\\LC_LabEntrance3"
  self.sLabEntranceTrigOut = self.PATH .. "main\\PT_LabEntrance[2]"
  self.sLabEntranceLOCOut = self.PATH .. "main\\LC_LabEntrance(2)"
  self.sFuelTruck = self.PATH .. "fueltruck\\VH_NZ_TR_OpelFuelTruck"
  self.tInfo.vEckOut = true
  self.sSiren = "Missions\\soe_1\\mission_7\\cave\\Siren_AirRaid"
  self.tAngrySquad = {
    self.PATH .. "angry\\AngryGrunt_01",
    self.PATH .. "angry\\AngryGrunt_02",
    self.PATH .. "angry\\AngryGrunt_03"
  }
  self.tAAGuns = {
    "CountrySide\\centre\\chateaudeisenbourg\\wtf_l\\AA_N\\",
    "CountrySide\\centre\\chateaudeisenbourg\\wtf_l\\AA_N2\\"
  }
  self.tAAGunners = {
    "CountrySide\\centre\\chateaudeisenbourg\\wtf_l\\AA_N_Gunner",
    "CountrySide\\centre\\chateaudeisenbourg\\wtf_l\\AA_N2_Gunner"
  }
  self.tAATargets = {
    {
      "CountrySide\\centre\\chateaudeisenbourg\\props\\Target_N_1",
      "CountrySide\\centre\\chateaudeisenbourg\\props\\Target_N_2",
      "CountrySide\\centre\\chateaudeisenbourg\\props\\Target_N_3",
      "CountrySide\\centre\\chateaudeisenbourg\\props\\Target_N_4"
    },
    {
      "CountrySide\\centre\\chateaudeisenbourg\\props\\Target_N2_1",
      "CountrySide\\centre\\chateaudeisenbourg\\props\\Target_N2_2",
      "CountrySide\\centre\\chateaudeisenbourg\\props\\Target_N2_3",
      "CountrySide\\centre\\chateaudeisenbourg\\props\\Target_N2_4"
    }
  }
  self.tCinSplines = {
    "Missions\\soe_1\\mission_7\\main\\bombers\\BomberFormationA\\BomberSpline1",
    "Missions\\soe_1\\mission_7\\main\\bombers\\BomberFormationA\\BomberSpline2",
    "Missions\\soe_1\\mission_7\\main\\bombers\\BomberFormationA\\BomberSpline3",
    "Missions\\soe_1\\mission_7\\main\\bombers\\BomberFormationB\\BomberSpline1",
    "Missions\\soe_1\\mission_7\\main\\bombers\\BomberFormationB\\BomberSpline2",
    "Missions\\soe_1\\mission_7\\main\\bombers\\BomberFormationB\\BomberSpline3",
    "Missions\\soe_1\\mission_7\\main\\bombers\\BomberFormationC\\BomberSpline1",
    "Missions\\soe_1\\mission_7\\main\\bombers\\BomberFormationC\\BomberSpline2",
    "Missions\\soe_1\\mission_7\\main\\bombers\\BomberFormationC\\BomberSpline3"
  }
  self.tAnnouncements = {
    "P1M2_InterrogateSSOfficer"
  }
  self.tCars = {
    self.PATH .. "vehicules\\VH_CV_CR_CarToBlow01",
    self.PATH .. "vehicules\\VH_CV_CR_CarToBlow02",
    self.PATH .. "vehicules\\VH_CV_CR_CarToBlow03"
  }
  self.tCavePeople = {
    self.PATH .. "scientists\\ENEMY_Cave_Lab_Scientist_01",
    self.PATH .. "scientists\\ENEMY_Cave_Lab_Scientist_02",
    self.PATH .. "scientists\\ENEMY_Cave_Lab_Scientist_03",
    self.PATH .. "scientists\\ENEMY_Cave_Lab_Scientist_04",
    self.PATH .. "cave\\ENEMY_Cave_Lab_Guard01",
    self.PATH .. "EckFranCave\\Spore_NZ_Eckhardt",
    self.PATH .. "EckFranCave\\Spore_NZ_Franziska"
  }
  self.tGuardsScientists = {
    self.PATH .. "scientists\\ENEMY_Cave_Lab_Scientist_01",
    self.PATH .. "scientists\\ENEMY_Cave_Lab_Scientist_02",
    self.PATH .. "scientists\\ENEMY_Cave_Lab_Scientist_03",
    self.PATH .. "scientists\\ENEMY_Cave_Lab_Scientist_04",
    self.PATH .. "cave\\ENEMY_Cave_Lab_Guard01"
  }
  self.t1stCin = {
    "Missions\\soe_1\\mission_7\\FranEckOutside\\Ext_Franziska",
    "Missions\\soe_1\\mission_7\\FranEckOutside\\Ext_Eckhardt"
  }
  self.tAAGun1Cin = {
    "CountrySide\\centre\\chateaudeisenbourg\\wtf_l\\AA_N_Gunner",
    "CountrySide\\centre\\chateaudeisenbourg\\wtf_l\\AA_N2_Gunner",
    "Missions\\soe_1\\mission_7\\outside\\ENEMY_Castle_Outside_AAGun1_Officer"
  }
end

function SOE_1_Mission_7:Reset()
  Sound.ReleaseSoundBank("m_S1M7_inGame.bnk")
  Actor.SetDontSpawnDeadGuys(false)
  if self.FranEckOut then
    Util.UnloadEditNode("Missions\\soe_1\\mission_7\\FranEckOutside.wsd")
  end
  if self.EckFranCave then
    Util.UnloadEditNode("Missions\\soe_1\\mission_7\\EckFranCave.wsd")
  end
end

function SOE_1_Mission_7:WhatsLoaded(sWhatWasLoaded)
  if sWhatWasLoaded == "FranEckOutside" then
    self.FranEckOut = true
  end
  if sWhatWasLoaded == "Aurora" then
    self.AuroraLoaded = true
  end
  if sWhatWasLoaded == "EckFranCave" then
    self.EckFranCave = true
  end
end

function SOE_1_Mission_7:NotOpenTunnelExit()
  Cin.PlayConversation("S1M7_NearExit")
end

function SOE_1_Mission_7:SetUp1stCin()
  for i, v in ipairs(self.t1stCin) do
    local hActor = Util.GetHandleByName(v)
    if Actor.IsAlive(hActor) == true then
      Actor.OverrideCombatAI(Handle(hActor), true)
      Combat.SetRespondToSound(Handle(hActor), false)
      Combat.SetRespondToEvents(Handle(hActor), false)
      Combat.SetRespondToDeadBodies(Handle(hActor), false)
      Suspicion.Enable(Handle(hActor), false)
      Combat.SetRespondToDamage(Handle(hActor), false)
      Actor.EnableNeeds(Handle(hActor), false)
      Object.SetInvincible(hActor, true)
    end
  end
end

function SOE_1_Mission_7:Checkpoint1()
  self.SetConvTrigger(self, self.PATH .. "main\\PT_NearChateauConv", "S1M7_Chateau_Near")
  EVENT_Stream("SOE_1_Mission_7.SetUp1stCin", self, {
    "Missions\\soe_1\\mission_7\\FranEckOutside\\Ext_Franziska",
    "Missions\\soe_1\\mission_7\\FranEckOutside\\Ext_Eckhardt"
  }, true)
  self:TASK_EnterFortress()
end

function SOE_1_Mission_7:SetConvTrigger(a_vTrig, a_sConv)
  local eSetConvTrig = Trigger.WaitFor(a_vTrig, Util.GetHandleByName("Saboteur"), "SOE_1_Mission_7.OnConvTrigCrossed", self, {a_sConv})
  self:RegisterTriggerEvent(eSetConvTrig, a_vTrig)
end

function SOE_1_Mission_7:OnConvTrigCrossed(a_tTrigData, a_sConv)
  Cin.PlayConversation(a_sConv)
end

function SOE_1_Mission_7:MakeEveryoneDeaf()
  Object.SetInvincible(Handle("Missions\\soe_1\\mission_7\\EckFranCave\\Spore_NZ_Eckhardt"), true)
  Object.SetInvincible(Handle("Missions\\soe_1\\mission_7\\EckFranCave\\Spore_NZ_Franziska"), true)
  Object.SetInvincible(Handle("Missions\\soe_1\\mission_7\\EckFrancave\\Eckhardt_Kubel"), true)
  Actor.OverrideCombatAI(Handle("Missions\\soe_1\\mission_7\\EckFranCave\\Spore_NZ_Eckhardt"), true)
  Combat.SetRespondToSound(Handle("Missions\\soe_1\\mission_7\\EckFranCave\\Spore_NZ_Eckhardt"), false)
  Combat.SetRespondToEvents(Handle("Missions\\soe_1\\mission_7\\EckFranCave\\Spore_NZ_Eckhardt"), false)
  Combat.SetRespondToDeadBodies(Handle("Missions\\soe_1\\mission_7\\EckFranCave\\Spore_NZ_Eckhardt"), false)
  Actor.OverrideCombatAI(Handle("Missions\\soe_1\\mission_7\\EckFranCave\\Spore_NZ_Franziska"), true)
  Combat.SetRespondToSound(Handle("Missions\\soe_1\\mission_7\\EckFranCave\\Spore_NZ_Franziska"), false)
  Combat.SetRespondToEvents(Handle("Missions\\soe_1\\mission_7\\EckFranCave\\Spore_NZ_Franziska"), false)
  Combat.SetRespondToDeadBodies(Handle("Missions\\soe_1\\mission_7\\EckFranCave\\Spore_NZ_Franziska"), false)
end

function SOE_1_Mission_7:MakeEveryoneHear()
  for i, v in ipairs(self.tGuardsScientists) do
    local hActor = Util.GetHandleByName(v)
    if hActor then
      Combat.SetRespondToSound(hActor, true)
      Combat.SetRespondToEvents(hActor, true)
      Combat.SetRespondToDeadBodies(hActor, true)
      ScriptSequence.Kill(hActor)
      Combat.SetLethalForce(hActor, true)
      Combat.SetTarget(hActor, hSab)
      Combat.LockIntoRanged(hActor)
      Combat.SetCombat(hActor)
    end
  end
end

function SOE_1_Mission_7:TASK_EnterFortress()
  self:CreateTask({
    sName = "SOE_1_Mission_7_TASK_EnterFortress",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "DELIVER",
    tDestRegion = {
      self.sLocateChateau
    },
    tDeliverObjs = {hSab},
    tLocators = {
      self.sInsideFortress
    },
    sObjectiveTextID = "S1M7_Text.TASK_EnterFortress",
    sTaskStartConv = "S1M7_OMW",
    vGPSTarget = "Missions\\soe_1\\mission_7\\main\\LOC_SeeMainGate",
    tSMEDNodes = {
      SOE_1_Mission_7.PATH .. "outside"
    },
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "SOE_1_Mission_7.Checkpoint2"
        }
      }
    }
  })
  Util.SpawnEditNode("Missions\\soe_1\\mission_7\\FranEckOutside.wsd", "SOE_1_Mission_7.WhatsLoaded", self, {
    "FranEckOutside"
  })
end

function SOE_1_Mission_7:Checkpoint2()
  self:CreateTask({
    sName = "SOE_1_Mission_7_TASK_InfiltrateChateau",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "DELIVER",
    tDestRegion = {
      self.sFortressRegion
    },
    tDeliverObjs = {hSab},
    tLocators = {
      self.sAAGun2
    },
    bNoGPS = true,
    sObjectiveTextID = "S1M7_Text.TASK_FindBetterEntrance",
    tSMEDNodes = {
      self.PATH .. "aurora"
    },
    tOnComplete = {
      {
        self.FirstCin,
        {self}
      },
      {
        self.RemoveExtTrigs,
        {self}
      }
    }
  })
  Sound.SetMusicLocale("S1M7_GetAurora")
  Sound.SetMusicLocale("m_S1M7_GetAurora", "arriveChateau")
  local hNotGetIn = Handle("Missions\\soe_1\\mission_7\\outside\\PT_Convo_notgettingIn")
  local hNoGetInTrig = Trigger.WaitFor(hNotGetIn, hSab, "SOE_1_Mission_7.NotOpenTunnelExit", self, {})
  self:RegisterTriggerEvent(hNoGetInTrig, hNotGetIn)
end

function SOE_1_Mission_7:RemoveExtTrigs()
  Trigger.DoNotWaitFor(self.sGoodWayIn, Util.GetHandleByName("Saboteur"))
  Trigger.DoNotWaitFor(self.PATH .. "main\\PT_HardWayConv", Util.GetHandleByName("Saboteur"))
end

function SOE_1_Mission_7:FirstCin()
  EVENT_Timer("SOE_1_Mission_7.Start1stCin", self, 4)
  EVENT_Timer("SOE_1_Mission_7.Go1stCin", self, 2)
end

function SOE_1_Mission_7:Start1stCin()
  Cin.PlayCinematic("MINICIN_SOE1M7_01", "SOE_1_Mission_7.SetChPnt2andAHalf", self)
end

function SOE_1_Mission_7:Go1stCin()
  local hDoor01 = Util.GetHandleByName(self.DoorToLab01)
  local hDoor02 = Util.GetHandleByName(self.DoorToLab02)
  if hDoor01 then
    Object.Actuate(hDoor01)
  end
  if hDoor02 then
    Object.Actuate(hDoor02)
  end
  Nav.SetScriptedPath(Handle("Missions\\soe_1\\mission_7\\FranEckOutside\\Ext_Eckhardt"), "Missions\\soe_1\\mission_7\\outside\\PATH_1stCinEck", true, "SOE_1_Mission_7.UndergroundDoors", self)
  Nav.SetScriptedPath(Handle("Missions\\soe_1\\mission_7\\FranEckOutside\\Ext_Franziska"), "Missions\\soe_1\\mission_7\\outside\\PATH_1stCin", true)
end

function SOE_1_Mission_7:NowMoveFran()
  Nav.SetScriptedPathMoveMode(Handle("Missions\\soe_1\\mission_7\\FranEckOutside\\Ext_Franziska"), true)
  Nav.SetScriptedPathMoveMode(Handle("Missions\\soe_1\\mission_7\\FranEckOutside\\Ext_Eckhardt"), true)
end

function SOE_1_Mission_7:UndergroundDoors()
  if self.tInfo.vEckOut then
    SOE_1_Mission_7.EckGoesDown(self)
    self.tInfo.vEckOut = false
  elseif not self.tInfo.vEckOut then
  end
end

function SOE_1_Mission_7:EckGoesDown()
  Nav.SetScriptedPath(Handle("Missions\\soe_1\\mission_7\\FranEckOutside\\Ext_Eckhardt"), "Missions\\soe_1\\mission_7\\outside\\PATH_1stCinBEck", true)
  Nav.SetScriptedPath(Handle("Missions\\soe_1\\mission_7\\FranEckOutside\\Ext_Franziska"), "Missions\\soe_1\\mission_7\\outside\\PATH_1stCinB", true)
  if Suspicion.GetEscalation() ~= 0 then
    Nav.SetScriptedPathMoveMode(Handle("Missions\\soe_1\\mission_7\\FranEckOutside\\Ext_Eckhardt"), true)
    Nav.SetScriptedPathMoveMode(Handle("Missions\\soe_1\\mission_7\\FranEckOutside\\Ext_Franziska"), true)
  end
end

function SOE_1_Mission_7:SetChPnt2andAHalf()
  Util.UnloadEditNode("Missions\\soe_1\\mission_7\\FranEckOutside.wsd", true)
  self.FranEckOut = false
  local hDoor01 = Util.GetHandleByName(self.DoorToLab01)
  local hDoor02 = Util.GetHandleByName(self.DoorToLab02)
  if hDoor01 then
    Object.Actuate(hDoor01)
  end
  if hDoor02 then
    Object.Actuate(hDoor02)
  end
  self:RegisterCheckpoint("SOE_1_Mission_7.Checkpoint2andAHalf")
end

function SOE_1_Mission_7:Checkpoint2andAHalf()
  local hDoor01 = Util.GetHandleByName(self.DoorToLab01)
  local hDoor02 = Util.GetHandleByName(self.DoorToLab02)
  if hDoor01 and hDoor02 then
    self.hMiddoorLoc = Handle("Missions\\soe_1\\mission_7\\main\\LOC_Gazebo")
    HUD.SetObjectiveMarker(self.hMiddoorLoc, eOT_KILL, cOM_Kill, true, true, true)
    self:CreateTask({
      sName = "TASK_DestroyCars",
      sTaskType = "SabTaskObjectiveDestroy",
      sTaskSubType = "KILL",
      sObjectiveTextID = "S1M7_Text.TASK_DestroyDoors",
      sTaskStartConv = "S1M7_DestroyEntrance",
      tTgtInclude = {
        self.DoorToLab01,
        self.DoorToLab02
      },
      TaskCount = 1,
      bNoGPS = true,
      bNoHUDBlip = true,
      bNoWorldBlip = true,
      tSMEDNodes = {},
      tOnActivate = {},
      tOnComplete = {
        {
          self.TASK_FindTheCar,
          {self}
        },
        {
          HUD.RemoveObjectiveMarker,
          {
            self.hMiddoorLoc
          }
        }
      }
    })
  else
    self.TASK_FindTheCar(self)
  end
  local hCheck3Trig = Trigger.WaitFor("Missions\\soe_1\\mission_7\\main\\PT_LabEntrance3", hSab, "SOE_1_Mission_7.SetCheckpoint3", self, {})
  self:RegisterTriggerEvent(hNoGetInTrig, "Missions\\soe_1\\mission_7\\main\\PT_LabEntrance3")
end

function SOE_1_Mission_7:SetCheckpoint3()
  Trigger.Enable("Missions\\soe_1\\mission_7\\outside\\PT_Convo_notgettingIn", false)
  Object.Actuate(Handle("CountrySide\\centre\\chateaudeisenbourg\\fences\\OccMed_Bunker_Door_sml(4)"))
  Util.SpawnEditNode("CountrySide\\centre\\chateaudeisenbourg\\aurora.wsd", "SOE_1_Mission_7.WhatsLoaded", self, {"Aurora"})
  self:RegisterCheckpoint("SOE_1_Mission_7.Checkpoint3_Death", "SOE_1_Mission_7.Checkpoint3_Cont")
end

function SOE_1_Mission_7:Checkpoint3_Death()
  self.TASK_FindTheCar(self)
  Sound.SetMusicLocale("S1M7_GetAurora")
  Sound.SetMusicLocale("m_S1M7_GetAurora", "enterUnderground")
  Util.SpawnEditNode("Missions\\soe_1\\mission_7\\EckFranCave.wsd", "SOE_1_Mission_7.WhatsLoaded", self, {
    "EckFranCave"
  })
  SOE_1_Mission_7.AuroraHasSpawned(self)
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      self.sFranziska,
      self.sEckhardt,
      "Missions\\soe_1\\mission_7\\EckFrancave\\Eckhardt_Kubel"
    },
    WaitForGameObject = true
  }, "SOE_1_Mission_7.MakeEveryoneDeaf", self))
end

function SOE_1_Mission_7:Checkpoint3_Cont()
  Util.SpawnEditNode("Missions\\soe_1\\mission_7\\EckFranCave.wsd")
  Sound.SetMusicLocale("S1M7_GetAurora")
  Sound.SetMusicLocale("m_S1M7_GetAurora", "enterUnderground")
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      self.sAurora
    },
    WaitForGameObject = true
  }, "SOE_1_Mission_7.AuroraHasSpawned", self))
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      self.sFranziska,
      self.sEckhardt,
      "Missions\\soe_1\\mission_7\\EckFrancave\\Eckhardt_Kubel"
    },
    WaitForGameObject = true
  }, "SOE_1_Mission_7.MakeEveryoneDeaf", self))
end

function SOE_1_Mission_7:TASK_FindTheCar()
  self:CreateTask({
    sName = "SOE_1_Mission_7_TASK_FindTheCar",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "DELIVER",
    bNoWorldBlip = true,
    tDestRegion = {
      self.sEckhardtOfficeTrig
    },
    tLocators = {
      self.sCarSpawnLoc
    },
    tDeliverObjs = {hSab},
    sObjectiveTextID = "S1M7_Text.TASK_FindTheCar",
    tOnActivate = {},
    tOnComplete = {
      {
        self.StartCinematicEckhardt,
        {self}
      }
    },
    tStaticTags = {
      "S1M7_SecretDoorFence"
    },
    tSMEDNodes = {
      "Missions\\soe_1\\mission_7\\angry",
      self.PATH .. "cave",
      self.PATH .. "scientists"
    }
  })
  Sound.AttachSoundEvent(Handle("CountrySide\\centre\\chateaudeisenbourg\\sound\\S1M7_AlarmStop"), "S1M7_Alarm_Start")
end

function SOE_1_Mission_7:KillYouDamnNazis(a_sKillTrigger)
  local hTrigger = Util.GetHandleByName(a_sKillTrigger)
  local hSurroundingNaziFilter = Filter.New("Nazi")
  local tBastardNazis = {}
  if hTrigger then
    tBastardNazis = Trigger.GetAllWithin(hTrigger, hSurroundingNaziFilter)
  end
  if tBastardNazis and tBastardNazis[1] then
    for i, Nazi in pairs(tBastardNazis) do
      Object.Kill(Nazi)
      print("killing nazi ", Nazi)
    end
  end
  Filter.Delete(hSurroundingNaziFilter)
end

function SOE_1_Mission_7:GoMoto1()
  Nav.SetScriptedPath(Handle("Missions\\soe_1\\mission_7\\tunnel\\Moto1"), self.PATH .. "main\\PATH_Moto1", true)
  Nav.SetScriptedPathSpeed(Handle("Missions\\soe_1\\mission_7\\tunnel\\Moto1"), 160)
  local tLocProxEvent = {
    EventType = "ProximityEvent",
    ObjectA = hSab,
    ObjectB = Handle("Missions\\soe_1\\mission_7\\tunnel\\Moto1"),
    Proximity = 10,
    Negate = false
  }
  local eMoto1Attack = Util.CreateEvent(tLocProxEvent, "SOE_1_Mission_7.Moto1Attack", self)
  self:RegisterEvent(eMoto1Attack)
end

function SOE_1_Mission_7:Moto1Attack()
  Nav.FollowObject(Handle("Missions\\soe_1\\mission_7\\tunnel\\Moto1"), hSab, 3, true)
end

function SOE_1_Mission_7:GoMoto2()
  Nav.SetScriptedPath(Handle("Missions\\soe_1\\mission_7\\tunnel\\Moto2"), self.PATH .. "main\\PATH_Moto2", true)
  Nav.SetScriptedPathSpeed(Handle("Missions\\soe_1\\mission_7\\tunnel\\Moto2"), 70)
  Nav.SetScriptedPath(Handle("Missions\\soe_1\\mission_7\\tunnel\\Moto3"), self.PATH .. "main\\PATH_Moto3", true)
  Nav.SetScriptedPathSpeed(Handle("Missions\\soe_1\\mission_7\\tunnel\\Moto3"), 50)
  local tLocProxEvent = {
    EventType = "ProximityEvent",
    ObjectA = hSab,
    ObjectB = Handle("Missions\\soe_1\\mission_7\\tunnel\\Moto2"),
    Proximity = 10,
    Negate = false
  }
  local eMoto2Attack = Util.CreateEvent(tLocProxEvent, "SOE_1_Mission_7.Moto2Attack", self)
  self:RegisterEvent(eMoto2Attack)
  local tLocProxEvent = {
    EventType = "ProximityEvent",
    ObjectA = hSab,
    ObjectB = Handle("Missions\\soe_1\\mission_7\\tunnel\\Moto3"),
    Proximity = 10,
    Negate = false
  }
  local eMoto3Attack = Util.CreateEvent(tLocProxEvent, "SOE_1_Mission_7.Moto3Attack", self)
  self:RegisterEvent(eMoto3Attack)
end

function SOE_1_Mission_7:Moto2Attack()
  Nav.FollowObject(Handle("Missions\\soe_1\\mission_7\\tunnel\\Moto2"), hSab, 3, true)
end

function SOE_1_Mission_7:Moto3Attack()
  Nav.FollowObject(Handle("Missions\\soe_1\\mission_7\\tunnel\\Moto3"), hSab, 3, true)
end

function SOE_1_Mission_7:StartCinematicEckhardt()
  Sound.DeactivateSoundEmitter(Handle(self.sSiren))
  Actor.SetAutoSeatTransition(Handle(self.sEckhardt), false)
  self.Cin2Conv(self)
  Cin.PlayCinematic("S1M7_EckhardtFranziska_Window", "SOE_1_Mission_7.TASK_LowerCar", self)
  local tCombatFlags = {
    EnableSuspicion = false,
    RespondsToDeadBodies = false,
    RespondsToDamage = false,
    RespondsToEvents = false,
    RespondsToSound = false,
    SetIdleScripted = true
  }
  local tFranAlertSeq = {
    {
      "SETCOMBATFLAGS",
      {tCombatFlags}
    },
    {
      "SETCOMBAT",
      {false}
    },
    {"STOPMOVING"},
    {
      "DELAY",
      {2}
    },
    {
      "BOARDVEHICLE",
      {
        Handle(self.sEckhardtCar),
        "PILOT",
        false
      }
    },
    {
      "DRIVEPATHONCE",
      {
        "Missions\\soe_1\\mission_7\\cave\\PATH_Eckhardt_Kubel"
      }
    }
  }
  ScriptSequence.Run(Handle(self.sFranziska), tFranAlertSeq)
  ScriptSequence.Run(Handle(self.sFranziska), tFranAlertSeq, SOE_1_Mission_7.FranBoardVeh, {self})
  local tEckAlertSeq = {
    {
      "SETCOMBATFLAGS",
      {tCombatFlags}
    },
    {
      "SETCOMBAT",
      {false}
    },
    {"STOPMOVING"},
    {
      "DELAY",
      {2.3}
    },
    {
      "BOARDVEHICLE",
      {
        Handle(self.sEckhardtCar),
        "SHOTGUN",
        false
      }
    }
  }
  ScriptSequence.Run(Handle(self.sEckhardt), tEckAlertSeq)
  local eHearing = Util.CreateEvent({EventType = "TimerEvent", Time = 10}, "SOE_1_Mission_7.MakeEveryoneHear", self)
  self:RegisterEvent(eHearing)
end

function SOE_1_Mission_7:Cin2Conv()
end

function SOE_1_Mission_7:AuroraHasSpawned()
  self.eGoMoto1 = Trigger.WaitFor(self.PATH .. "main\\PT_InitMoto1", Handle(self.sAurora), "SOE_1_Mission_7.SetCheckpoint4", self, {-1})
  self:RegisterTriggerEvent(self.eGoMoto1, self.PATH .. "main\\PT_InitMoto1")
  Vehicle.LockSeat(Handle(self.sAurora), "PILOT", true)
  Vehicle.LockSeat(Handle(self.sAurora), "SHOTGUN", true)
  SOE_1_Mission_7.SetupCarDeath(self)
  Vehicle.SetPinned(Handle(self.sAurora), true)
  Vehicle.SetFullWheelRayScheduling(Handle(self.sAurora), true)
end

function SOE_1_Mission_7:SetupCarDeath()
  self.eAuroraDeath = EVENT_ActorDeath("SOE_1_Mission_7.CarDeath", self, Util.GetHandleByName(self.sAurora))
end

function SOE_1_Mission_7:CarDeath()
  Cin.PlayConversation("S1M7_Aurora_Destroyed", "SOE_1_Mission_7.NowFailz", self)
end

function SOE_1_Mission_7:NowFailz()
  self:MissionTaskFail("S1M7b_Text.Fail_LostAurora")
end

function SOE_1_Mission_7:TASK_LowerCar()
  local eLoweredTrig = Trigger.WaitFor("Missions\\soe_1\\mission_7\\main\\PT_AuroraLowered", Util.GetHandleByName(self.sAurora), "SOE_1_Mission_7.OnCarTrigHit", self, {})
  self:RegisterTriggerEvent(eLoweredTrig, "Missions\\soe_1\\mission_7\\main\\PT_AuroraLowered")
  self:CreateTask({
    sName = "TASK_LowerCar",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    tLocators = {
      "Missions\\soe_1\\mission_7\\main\\LC_GetCarDown"
    },
    bBlipLocatorsOnly = true,
    sObjectiveTextID = "S1M7_Text.TASK_LowerCar",
    tTgtInclude = {
      "Missions\\soe_1\\mission_7\\main\\UsePt_Lever_Floor_A"
    },
    tOnComplete = {
      {
        self.OnSwitchHit,
        {
          self,
          "TASK_LowerCar"
        }
      }
    }
  })
  Util.UnloadEditNode("Missions\\soe_1\\mission_7\\EckFranCave.wsd", true, false)
  self.EckFranCave = false
end

function SOE_1_Mission_7:OnCarTrigHit()
  if self:IsMissionTaskActive("TASK_LowerCar") then
    self:CompleteTaskByName("TASK_LowerCar")
  end
  AttractionPt.EnableUse(Handle("Missions\\soe_1\\mission_7\\main\\UsePt_Lever_Floor_A"), false)
end

function SOE_1_Mission_7:OnSwitchHit(a_sTaskName)
  Trigger.Enable("Missions\\soe_1\\mission_7\\main\\PT_AuroraLowered", false)
  if not self:IsMissionTaskActive("TASK_LeaveWithAurora") then
    self.TASK_LeaveWithAurora(self)
  end
  Object.Actuate(Handle("CountrySide\\centre\\chateaudeisenbourg\\carlab\\Chateau_de_Isenbourg_carlab\\AnimatedObject_OccMed_Carlift"))
  Vehicle.SetPinned(Handle(self.sAurora), false)
  AttractionPt.EnableUse(Handle("Missions\\soe_1\\mission_7\\main\\UsePt_Lever_Floor_A"), false)
  EVENT_Timer("SOE_1_Mission_7.UnlockAurora", self, 2)
end

function SOE_1_Mission_7:UnlockAurora()
  Vehicle.LockSeat(Handle(self.sAurora), "PILOT", false)
  Vehicle.LockSeat(Handle(self.sAurora), "SHOTGUN", false)
end

function SOE_1_Mission_7:SetCheckpoint4()
  Actor.SetDontSpawnDeadGuys(true)
  self.RegisterCheckpoint(self, "SOE_1_Mission_7.Checkpoint4Death", "SOE_1_Mission_7.Checkpoint4Cont")
end

function SOE_1_Mission_7:Checkpoint4Cont()
  local eCheck4Trig = Trigger.WaitFor(self.sExitTrigger, Util.GetHandleByName(self.sAurora), "SOE_1_Mission_7.OnActorEntersStartTriggerExit", self, {-1})
  self:RegisterTriggerEvent(eCheck4Trig, self.sExitTrigger)
  SOE_1_Mission_7.GoMoto1(self)
  local eGoMoto2 = Trigger.WaitFor(self.PATH .. "main\\PT_InitMoto2", Handle("Saboteur"), "SOE_1_Mission_7.GoMoto2", self, {-1})
  self:RegisterTriggerEvent(eGoMoto2, self.PATH .. "main\\PT_InitMoto2")
end

function SOE_1_Mission_7:Checkpoint4Death()
  SOE_1_Mission_7.SetupCarDeath(self)
  if not self:IsMissionTaskActive("TASK_LeaveWithAurora") then
    self.TASK_LeaveWithAurora(self)
  end
  local eCheck4Trig = Trigger.WaitFor(self.sExitTrigger, Util.GetHandleByName(self.sAurora), "SOE_1_Mission_7.OnActorEntersStartTriggerExit", self, {-1})
  self:RegisterTriggerEvent(eCheck4Trig, self.sExitTrigger)
  SOE_1_Mission_7.GoMoto1(self)
  local eGoMoto2 = Trigger.WaitFor(self.PATH .. "main\\PT_InitMoto2", Handle("Saboteur"), "SOE_1_Mission_7.GoMoto2", self, {-1})
  self:RegisterTriggerEvent(eGoMoto2, self.PATH .. "main\\PT_InitMoto2")
end

function SOE_1_Mission_7:OnActorEntersStartTriggerExit()
  local hBunker02 = Util.GetHandleByName(self.DoorToBunker02)
  Object.Actuate(hBunker02)
  Nav.MoveToObject(Handle("Missions\\soe_1\\mission_7\\tunnel\\ENEMY_Tunnel_Nazi07"), Handle("Missions\\soe_1\\mission_7\\main\\LOC_ExtNazisRunIn"), 1, true)
  Nav.MoveToObject(Handle("Missions\\soe_1\\mission_7\\tunnel\\ENEMY_Tunnel_Nazi08"), Handle("Missions\\soe_1\\mission_7\\main\\LOC_ExtNazisRunIn"), 1, true)
  Cin.PlayConversation("S1M7_Escape_ExitOpened")
end

function SOE_1_Mission_7:TASK_LeaveWithAurora()
  local hAurora = Handle(self.sAurora)
  self:CreateTask({
    sName = "TASK_LeaveWithAurora",
    sTaskType = "SabTaskObjectiveDeliver",
    tDestProximityObj = {
      "Missions\\soe_1\\mission_7\\main\\Loc_EscapeBatCave"
    },
    Proximity = 13,
    sTaskSubType = "DELIVER",
    tDeliverObjs = {hAurora},
    sObjectiveTextID = "S1M7_Text.TASK_LeaveWithAurora",
    bNoGPS = true,
    tSMEDNodes = {
      "Missions\\soe_1\\mission_7\\tunnel"
    },
    tOnComplete = {
      {
        self.ChangeWTFTime,
        {self}
      }
    },
    tOnActivate = {
      {
        Trigger.WaitFor,
        {
          self.sCloseGarageTrig,
          Util.GetHandleByName(self.sAurora),
          "SOE_1_Mission_7.CloseGarageDoor",
          self,
          {-1}
        }
      },
      {
        self.RunTunnelNazi,
        {self}
      }
    }
  })
  Vehicle.SetAsMissionCritical(hAurora, true)
end

function SOE_1_Mission_7:ChangeWTFTime()
  Vehicle.BrakeTo(Handle(self.sAurora), 2)
  Util.SetTimeScale(0.07)
  SOE_1_Mission_7.ChangeWTF(self)
end

function SOE_1_Mission_7:ChangeWTF()
  self:CreateTask({
    sName = "Task_WTFCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "WTF_S1M7_GetAurora",
    tCinematicNodes = {
      "wtf_s1m7_getaurora"
    },
    tOnComplete = {
      {
        self.MusicChange,
        {self}
      }
    }
  })
end

function SOE_1_Mission_7:NormalTime()
  self = SOE_1_Mission_7
  Util.SetTimeScale(1)
end

function SOE_1_Mission_7:MusicChange()
  Vehicle.BrakeTo(Handle(self.sAurora), 200)
  Sound.SetMusicLocale("S1M7_GetAurora")
  Sound.SetMusicLocale("m_S1M7_GetAurora", "Escape")
  self.CheckForComplete(self)
end

function SOE_1_Mission_7:CheckForComplete()
  if Suspicion.GetEscalation() ~= 0 then
    self.TASK_ShedEscalation(self)
  else
    _g_SOE_1_Mission_7_Playthrough = true
    self.CompleteThisMission(self)
  end
end

function SOE_1_Mission_7:TASK_ShedEscalation()
  self:CreateTask({
    sName = "TASK_ShedEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    sTaskSubType = "NONE",
    tLocators = {
      self.sDestLoc
    },
    bNoGPS = true,
    EscalationLevel = 0,
    tOnComplete = {
      {
        self.WaitForConvoToComp,
        {self}
      }
    }
  })
end

function SOE_1_Mission_7:WaitForConvoToComp()
  Cin.PlayConversation("S1M7_Complete", "SOE_1_Mission_7.NowCompleteIt", self)
end

function SOE_1_Mission_7:NowCompleteIt()
  _g_SOE_1_Mission_7_Playthrough = true
  self:CompleteThisMission()
end

function SOE_1_Mission_7:CloseGarageDoor()
  Object.Actuate(Handle("CountrySide\\centre\\chateaudeisenbourg\\fences\\OccMed_Bunker_Door_sml(4)"))
end

function SOE_1_Mission_7:RunTunnelNazi()
  EVENT_PlayerEntersVehicle("SOE_1_Mission_7.EnteredAurora", self, Handle(self.sAurora))
  Nav.SetScriptedPath(Handle("Missions\\soe_1\\mission_7\\tunnel\\ENEMY_Tunnel_Nazi02"), self.PATH .. "main\\PATH_TunnelNazi03", true)
  Nav.SetScriptedPathMoveMode(Handle("Missions\\soe_1\\mission_7\\tunnel\\ENEMY_Tunnel_Nazi02"), true)
  Nav.SetScriptedPath(Handle("Missions\\soe_1\\mission_7\\tunnel\\ENEMY_Tunnel_Nazi01"), self.PATH .. "main\\PATH_TunnelNazi02", true)
  Nav.SetScriptedPathMoveMode(Handle("Missions\\soe_1\\mission_7\\tunnel\\ENEMY_Tunnel_Nazi01"), true)
  Nav.SetScriptedPath(Handle("Missions\\soe_1\\mission_7\\tunnel\\ENEMY_Tunnel_Nazi02(2)"), self.PATH .. "main\\PATH_TunnelNazi01", true)
  Nav.SetScriptedPathMoveMode(Handle("Missions\\soe_1\\mission_7\\tunnel\\ENEMY_Tunnel_Nazi02(2)"), true)
end

function SOE_1_Mission_7:MISSION_ONCANCEL()
  Zone.SwitchState("WtF_Zones\\global\\S1M7_GetAurora", cZONESTATE_LOWWTF, cENT_IMMEDIATE)
  SOE_1_Mission_7.Reset(self)
  if self.AuroraLoaded then
    Util.UnloadEditNode("CountrySide\\centre\\chateaudeisenbourg\\aurora.wsd")
  end
end

function SOE_1_Mission_7:EnteredAurora()
  Cin.PlayConversation("S1M7_Escape_Start")
end
