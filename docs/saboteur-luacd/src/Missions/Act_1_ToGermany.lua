if Act_1_ToGermany == nil then
  Act_1_ToGermany = SabTaskObjective:Create()
  gsA12Germ = "Missions\\act_1\\togermany\\"
  Act_1_ToGermany:Configure({
    TaskCount = 999,
    bStarterless = true,
    tUnlockList = {
      "Act_1_BarFight"
    },
    sSaveMissionNameID = "MissionNames_Text.A1M0",
    MCDisplayID = 2,
    bSLOverrideFade = true,
    tSMEDNodes = {
      "Missions\\act_1\\togermany\\farmtransition"
    },
    tStaticTags = {
      "PristineBarn_Props2",
      "PristineBarn_Building2"
    }
  })
end

function Act_1_ToGermany:STARTER_Setup()
  Zone.SwitchState("WtF_Zones\\global\\A1M4_Champange_Ardeness", cZONESTATE_HIGHWTF, cENT_REALLYNOCHANGE)
  Render.SetGlobalWTF(true)
  Cin.LoadCinematic("102_CinB_FarmIntro")
  Sound.LoadSoundBank("m_A1M0_inGame.bnk")
  Suspicion.ResetEscalation()
  Suspicion.EnableEscalation(true)
  Render.FadeScreen(true)
  Util.SetTime(9, 0)
end

function Act_1_ToGermany:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self:Task_Belle()
end

function Act_1_ToGermany:DynamicThingyLoaded()
  self.tInfo.CinematicThingsyLoaded = self.tInfo.CinematicThingsyLoaded + 1
  if self.tInfo.CinematicThingsyLoaded == 2 then
    self:Task_CutsceneIntro()
  end
end

function Act_1_ToGermany:Task_Belle()
  self:CreateTask({
    sName = "Task_Belle",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "Belle",
    bInteriorTask = true,
    tOnActivate = {
      {
        self.TeleportToFarm,
        {self}
      }
    },
    tOnComplete = {
      {
        self.LoadDynamicThingys,
        {self}
      }
    }
  })
end

function Act_1_ToGermany:LoadDynamicThingys()
  Util.LoadDynamicNode("Title_102_3Months", "Act_1_ToGermany.DynamicThingyLoaded", self)
  Util.LoadDynamicNode("Title_102_Photo", "Act_1_ToGermany.DynamicThingyLoaded", self)
end

function Act_1_ToGermany:TeleportToFarm()
  print("teleport to farm")
  if InteriorManager.GetPlayersInterior() == "Belle" then
    print("player is in ", InteriorManager.GetPlayersInterior())
    InteriorManager.ExitInterior("Belle", "Missions\\act_1\\togermany\\farmtransition\\LOC_SeanTeleportTo", true, true)
  else
  end
end

function Act_1_ToGermany:GENERAL_Setup()
  self.tInfo.CPGateSwitch = "CountrySide\\borders\\saarbrucken\\country\\saarbrucken\\AttrPt_DoorSwitch"
  self.tInfo.CPGate = "CountrySide\\alsace\\german_border\\PSBridge_HydroStation\\PSBridge_HS_Gate_L"
  self.tInfo.Gate = "CountrySide\\champagneardennes\\morinifarm\\roads\\MN_MoriniFarm_MainGate(2)\\MN_MoriniFarm_MainGate_GateR"
  Util.EnableMiniZep(false)
  self.tInfo.CinematicThingsyLoaded = 0
  self:AddOnCancelCallback(Act_1_ToGermany.Reset)
  self:AddOnCompleteCallback(Act_1_ToGermany.Reset)
  self.tSaveInfo.bCarfail = false
  self.tInfo.JulesLoc = "Missions\\act_1\\togermany\\main\\LOC_Jules"
  self.tInfo.Car = "Missions\\act_1\\togermany\\truckaurora\\TruckAurora"
  self.tInfo.Jules = "Missions\\act_1\\characters\\farm_jules\\jules"
  self.tInfo.Veronique = "Missions\\act_1\\togermany\\verovitt_togermany\\veronique_togermany"
  self.tInfo.Vittore = "Missions\\act_1\\togermany\\verovitt_togermany\\vittore_togermany"
  self.tInfo.Bugatti = "Missions\\act_1\\togermany\\bugatti\\Bugatti"
  self.tInfo.Javier = "Missions\\act_1\\togermany\\javier\\javier"
  self.tStreamObjs = {
    "Missions\\act_1\\togermany\\main\\LOC_Jules",
    "Missions\\act_1\\togermany\\truckaurora\\TruckAurora",
    "Missions\\act_1\\characters\\farm_jules\\jules",
    "Missions\\act_1\\togermany\\verovitt_togermany\\veronique_togermany",
    "Missions\\act_1\\togermany\\verovitt_togermany\\vittore_togermany",
    "Missions\\act_1\\togermany\\bugatti\\Bugatti"
  }
  self.tSaveInfo.bGotPastCP = false
  self.tSaveInfo.bGateOpen = false
  self.tSaveInfo.bGetGoing = false
  self.tInfo.c_PaperCheckPass = 1
  self.tInfo.c_GateDead = 2
  self.tInfo.c_GateOpen = 3
  Object.SetInvincible(hSab, true)
end

function Act_1_ToGermany:Reset()
  if self.tInfo.eFailDistance then
    Util.KillEvent(self.tInfo.eFailDistance)
  end
  if self.tInfo.eDeath then
    Util.KillEvent(self.tInfo.eDeath)
  end
  if self.tInfo.eFailJulesTooFar then
    Util.KillEvent(self.tInfo.eFailJulesTooFar)
  end
  if self.tInfo.eCarDeath then
    Util.KillEvent(self.tInfo.eCarDeath)
  end
  if self.tInfo.eOffPath then
    Util.KillEvent(self.tInfo.eOffPath)
  end
  HUD.ClearWaypoint()
  Sound.ReleaseSoundBank("m_A1M0_inGame.bnk")
  Suspicion.EnableEscalationVehicles(true)
  OffWalkingConversationDisables()
  ClearAllDisableControls()
end

function Act_1_ToGermany:MISSION_ONCANCEL()
  WorldSMEDNodes.UnloadNode("Missions\\act_1\\togermany\\truckaurora", true)
  WorldSMEDNodes.UnloadNode("Missions\\act_1\\togermany\\javier", true)
end

function Act_1_ToGermany:Task_CutsceneIntro()
  self:CreateTask({
    sName = "Task_CutsceneIntro",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "102_CinB_FarmIntro",
    tCinematicNodes = {
      "102_cinb_farmintro"
    },
    bOverrideFade = true,
    tOnActivate = {
      {
        self.SetSeanCostume,
        {self}
      },
      {
        self.TASK_FatLoad,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TASK_FatLoad2,
        {self}
      },
      {
        Util.SpawnEditNode,
        {
          "Missions\\act_1\\characters\\farm_jules.wsd"
        }
      },
      {
        self.UnloadTaskNodes,
        {
          self,
          "Task_CutsceneIntro",
          true
        }
      },
      {
        self.TeleportToConv,
        {self}
      },
      {
        Object.SetInvincible,
        {hSab, false}
      },
      {
        HUD.UnloadObject,
        {cTTitleScreen}
      },
      {
        Util.UnloadDynamicNode,
        {
          "Title_102_3Months"
        }
      },
      {
        Util.UnloadDynamicNode,
        {
          "Title_102_Photo"
        }
      },
      {
        Util.SetOverrideLoadScreenFadeIn,
        {false}
      }
    }
  })
end

function Act_1_ToGermany:SetSeanCostume()
  Actor.SetDisguise(hSab, "FBS_RS_Sean_Shirt_Sab_Hat_NoBag")
end

function Act_1_ToGermany:TeleportToConv()
  print("teleport to conv")
  Object.PlayerTeleportToLocator(Handle("Missions\\act_1\\togermany\\farmtransition\\LOC_SeanTeleportTo"), true, false, "Act_1_ToGermany.SetupStreamStart", self)
end

function Act_1_ToGermany:OnPart1Load()
  local sObjLoaded = "Truck"
  if Util.GetHandleByName(sObjLoaded) then
    self.hObjectHandle = Util.GetHandleByName(sObjLoaded)
    self.sObjectString = sObjLoaded
  end
end

function Act_1_ToGermany:Part1Ready()
  EVENT_Timer("Act_1_ToGermany.ReadyGo", self, 0.1)
end

function Act_1_ToGermany:ReadyGo()
  self:RegisterCheckpoint("Act_1_ToGermany.Checkpoint1")
end

function Act_1_ToGermany:TASK_FatLoad()
  self:CreateTask({
    sName = "TASK_FatLoad",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      gsA12Germ .. "main",
      gsA12Germ .. "farm_population"
    },
    tStaticTags = {
      "Drive2GermanyProps",
      "A1M0_German_Border"
    },
    tOnActivate = {
      {
        self.LoadTransportation,
        {self}
      }
    }
  })
end

function Act_1_ToGermany:LoadTransportation()
  WorldSMEDNodes.LoadNode("Missions\\act_1\\togermany\\truckaurora")
  WorldSMEDNodes.LoadNode("Missions\\act_1\\togermany\\javier")
end

function Act_1_ToGermany:TASK_FatLoad2()
  self:CreateTask({
    sName = "TASK_FatLoad2",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      gsA12Germ .. "verovitt_togermany",
      gsA12Germ .. "bugatti"
    },
    tOnActivate = {}
  })
end

function Act_1_ToGermany:SetupStreamStart()
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = self.tStreamObjs,
    WaitForGameObject = true
  }
  Util.CreateEvent(tStreamEvent, "Act_1_ToGermany.Part1Ready", self)
  EVENT_Stream("Act_1_ToGermany.OpenFarmGate", self, {
    self.tInfo.Gate
  })
end

function Act_1_ToGermany:OpenFarmGate()
  print("gate streamed in opening")
  Object.ForceOpen(Handle(self.tInfo.Gate))
end

function Act_1_ToGermany:Checkpoint1()
  Render.FadeScreen(false, 0)
  Object.ForceOpen(Util.GetHandleByName("CountrySide\\champagneardennes\\morinifarm\\roads\\MN_MoriniFarm_MainGate(2)\\MN_MoriniFarm_MainGate_GateR"))
  ClearAllDisableControls()
  OnDisables()
  if not self:IsMissionTaskActive("Task_GoTo") then
    self:Task_GoTo()
    self:SetupConvosPart1()
    self:TASK_Checkpoint2()
  end
end

function Act_1_ToGermany:AllowWalking()
  ClearAllDisableControls()
  OnWalkingConversationDisables()
end

function Act_1_ToGermany:ClearDisables()
  ClearAllDisableControls()
end

function Act_1_ToGermany:Task_GoTo()
  self:CreateTask({
    sName = "Task_GoTo",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tOnActivate = {
      {
        self.CPFunctionActivation,
        {self}
      }
    }
  })
end

function Act_1_ToGermany:CPFunctionActivation()
  local hCar = Handle("CountrySide\\champagneardennes\\morinifarm\\props\\VH_CV_CR_Citroen15_01(3)")
  local hBug = Handle("Missions\\act_1\\togermany\\bugatti\\Bugatti")
  if hCar then
    Vehicle.LockAllSeats(hCar, true)
  end
  if hBug then
    Vehicle.LockAllSeats(hBug, true)
  end
  local sCPName = self:GetCheckpointName()
  if sCPName == "Act_1_ToGermany.Checkpoint1" then
    self:TASK_StartConvo()
    self:FailEvent()
  elseif sCPName == "Act_1_ToGermany.Checkpoint2" then
    self:Task_TaxiJules()
    self:FailEvent()
  end
end

function Act_1_ToGermany:TASK_StartConvo()
  self:CreateTask({
    sName = "TASK_StartConvo",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    tOnActivate = {
      {
        self.VittoreLeavesConvo,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Act_1_ToGermany:VittoreLeavesConvo()
  if Actor.IsInVehicle(hSab) then
    Actor.UnboardVehicle(hSab)
  end
  local hVit = Handle(self.tInfo.Vittore)
  local hVeron = Handle(self.tInfo.Veronique)
  if hVit then
    Object.SetInvincible(hVit, true)
  end
  if hVeron then
    Object.SetInvincible(hVeron, true)
  end
  Object.SetInvincible(hSab, false)
  Cin.PlayConversation("103_InG_Truck-VittoreLeaves")
end

function Act_1_ToGermany:LoadBugatti()
  local self = Act_1_ToGermany
  local hBugatti = Handle(self.tInfo.Bugatti)
  Nav.BoardVehicle(Handle(self.tInfo.Vittore), hBugatti, "PILOT", false, "Act_1_ToGermany.BugattiAway", self)
  Nav.BoardVehicle(Handle(self.tInfo.Veronique), hBugatti, "SHOTGUN", false)
  Actor.SetAutoSeatTransition(Handle(self.tInfo.Veronique), false)
  EVENT_Timer("Act_1_ToGermany.AllowWalking", self, 1.5)
end

function Act_1_ToGermany:BugattiAway()
  print("bugatti away")
  local hBugatti = Util.GetHandleByName(self.tInfo.Bugatti)
  Vehicle.StartPlayback(hBugatti, "A1M0_Vittore_DriveAway.vcr", "Act_1_ToGermany.UnloadBugatti")
  EVENT_Timer("Act_1_ToGermany.UnloadVeroVitt", self, 13)
  OffWalkingConversationDisables()
end

function Act_1_ToGermany:UnloadBugatti()
  Act_1_ToGermany:UnloadTaskNodes("TASK_FatLoad2", true)
end

function Act_1_ToGermany:UnloadVeroVitt()
  Vehicle.UnboardAll(Handle("Missions\\act_1\\togermany\\bugatti\\Bugatti"), false)
  self:UnloadTaskNodes("TASK_FatLoad2", true)
end

function Act_1_ToGermany:FailEvent()
  self.tInfo.eFailCarTooFar = EVENT_PlayerToActorProximityNegated("Act_1_ToGermany.FailCarTooFar", self, Util.GetHandleByName(self.tInfo.Car), 120, {
    "A1M0_Text.FAIL_OutofTime"
  })
  self.tInfo.eCarDeath = EVENT_ActorDeath("Act_1_ToGermany.FailCarDead", self, Util.GetHandleByName(self.tInfo.Car), {
    "GenericFail_Text.DESTROYED_Aurora"
  })
  self.tInfo.eOffPath = EVENT_PlayerExitsTrigger("Act_1_ToGermany.FailCarOffPath", self, "Missions\\act_1\\togermany\\main\\REG_OffPath", true)
  EVENT_PlayerExitsTrigger("Act_1_ToGermany.FailWarning", self, "Missions\\act_1\\togermany\\main\\REG_OffPathWarning")
  self.i0 = 0
  self.i1 = 0
  self.i2 = 0
  self.i3 = 0
  self.i4 = 0
  self.tInfo.eTruckDamage = Util.CreateEvent({
    EventType = "DamageEvent",
    ObjectName = self.tInfo.Car
  }, "Act_1_ToGermany.PlayDamageVO", self, {}, true)
  self:RegisterEvent(self.tInfo.eTruckDamage)
  TruckMaxHealth = Object.GetHealth(Handle(self.tInfo.Car))
end

function Act_1_ToGermany:PlayDamageVO()
  local truckhealth = Object.GetHealth(Handle(self.tInfo.Car))
  local health95percent = TruckMaxHealth * 0.95
  local health75percent = TruckMaxHealth * 0.75
  local health50percent = TruckMaxHealth * 0.6
  local health25percent = TruckMaxHealth * 0.4
  local health12percent = TruckMaxHealth * 0.25
  if truckhealth < health95percent and self.i0 == 0 then
    Cin.PlayConversation("A1M0_VehicleDamage_First")
    self.i0 = 1
  end
  if truckhealth < health75percent and self.i1 == 0 then
    Cin.PlayConversation("A1M0_VehicleDamage_25")
    self.i1 = 1
  end
  if truckhealth < health50percent and self.i2 == 0 then
    Cin.PlayConversation("A1M0_VehicleDamage_50")
    self.i2 = 1
  end
  if truckhealth < health25percent and self.i3 == 0 then
    Cin.PlayConversation("A1M0_VehicleDamage_75")
    self.i3 = 1
  end
  if truckhealth < health12percent and self.i4 == 0 then
    Cin.PlayConversation("A1M0_VehicleDamage_Burning")
    self.i4 = 1
  end
end

function Act_1_ToGermany:FailJulesTooFar(sFailString)
  Cin.PlayConversation("A1M0_Taxi_Abandoned", "Act_1_ToGermany.Fail", self, {sFailString})
end

function Act_1_ToGermany:FailCarTooFar(sFailString)
  Cin.PlayConversation("A1M0_Taxi_AbandonedVehicle", "Act_1_ToGermany.Fail", self, {sFailString})
end

function Act_1_ToGermany:FailJulesDead(sFailString)
  Cin.PlayConversation("A1M0_Taxi_JulesDeath", "Act_1_ToGermany.Fail", self, {sFailString})
end

function Act_1_ToGermany:FailCarDead(sFailString)
  if not self.tSaveInfo.bCarfail then
    self.tSaveInfo.bCarfail = true
    Cin.PlayConversation("A1M0_VehicleDamage_Destroyed", "Act_1_ToGermany.Fail", self, {sFailString})
  end
end

function Act_1_ToGermany:FailWarning()
  Cin.PlayConversation("A1M0_TooFar_Warning")
end

function Act_1_ToGermany:FailCarOffPath()
  Cin.PlayConversation("A1M0_TooFar_Fail", "Act_1_ToGermany.Fail", self, {
    "A1M0_Text.FAIL_WrongWay"
  })
end

function Act_1_ToGermany:Fail(tArgs, sFailString)
  print("fail events fire off ", sFailString)
  local sFS = sFailString or "A1M0_Text.FAIL_OutofTime"
  self:MissionTaskFail(sFS)
end

function Act_1_ToGermany:Task_TaxiJules()
  local self = Act_1_ToGermany
  self:CreateTask({
    sName = "Task_TaxiJules",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "A1M0_Text.TASK_TaxiJules_Drive",
    sPickupTextID = "A1M0_Text.TASK_TaxiJules_Drive",
    sVehicleReturnID = "A1M0_Text.TASK_Main_GetBackTruck",
    sVehicleFetchID = "A1M0_Text.TASK_TaxiJules_Enter",
    sDropoffTextID = "A1M0_Text.TASK_TaxiJules_Drive",
    tDestLocators = {
      gsA12Germ .. "main\\LOC_Dropoff1"
    },
    tPickupProxObj = {
      self.tInfo.Jules
    },
    PickupProximity = 60,
    tDestRegion = {
      gsA12Germ .. "main\\REG_Dropoff1"
    },
    tDeliverObjs = {
      self.tInfo.Jules
    },
    bNoDumping = true,
    bGroundBlip = true,
    bDontClearFollower = true,
    sRequiredVehicle = self.tInfo.Car,
    tOnEarlyExit = {},
    tOnPickup = {
      {
        self.ClearEarlyFail,
        {self}
      },
      {
        self.ClearDisables,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TASK_GetPastCheckpoint,
        {self}
      }
    },
    tOnActivate = {
      {
        self.SetupGateSwitch,
        {self}
      },
      {
        self.SetupGateDoor,
        {self}
      },
      {
        self.TASK_ConvGetGoing,
        {self}
      },
      {
        self.VehicleEnterTut,
        {self}
      },
      {
        self.SetupEarlyFailProx,
        {self}
      },
      {
        Nav.BoardVehicle,
        {
          Handle(self.tInfo.Jules),
          Handle(self.tInfo.Car),
          "SHOTGUN",
          true
        }
      },
      {
        EVENT_ActorEntersAnyVehicle,
        {
          "Act_1_ToGermany.UnblipHim",
          self,
          self.tInfo.Jules
        }
      },
      {
        Actor.SetAutoSeatTransition,
        {
          Handle(self.tInfo.Jules),
          false
        }
      }
    }
  })
end

function Act_1_ToGermany:SetupEarlyFailProx()
  self:ClearEarlyFail()
  local hLoc = Handle(self.tInfo.Jules)
  self.tInfo.eEarlyFail = EVENT_PlayerToActorProximityNegated("Act_1_ToGermany.EarlyFail", self, hLoc, 100)
end

function Act_1_ToGermany:EarlyFail()
  self:MissionTaskFail("GenericFail_Text.ABANDON_Jules")
end

function Act_1_ToGermany:ClearEarlyFail()
  if self.tInfo.eEarlyFail then
    Util.KillEvent(self.tInfo.eEarlyFail)
  end
  self.tInfo.eEarlyFail = nil
end

function Act_1_ToGermany:TASK_GetPastCheckpoint()
  self:CreateTask({
    sName = "TASK_GetPastCheckpoint",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    sObjectiveTextID = "A1M0_Text.TASK_GetPastCheckpoint",
    tOnComplete = {
      {
        self.Task_TaxiJules2,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Act_1_ToGermany:UnblipHim()
  SabTaskObjective.SetUIBlips(self, self.tInfo.Jules, false, true)
  self:Convo_GetIn()
end

function Act_1_ToGermany:Task_TaxiJules2()
  Util.LoadStaticENTag("A1M1_RACE_PIT", true)
  if self.tInfo.ePaperCheck then
    Util.KillEvent(self.tInfo.ePaperCheck)
  end
  if self.tInfo.eGateDeath then
    Util.KillEvent(self.tInfo.eGateDeath)
  end
  self.tSaveInfo.bGotPastCP = true
  self:CreateTask({
    sName = "Task_TaxiJules2",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "A1M0_Text.TASK_Main_GotoBar",
    sPickupTextID = "A1M0_Text.TASK_Main_GotoBar",
    sVehicleReturnID = "A1M0_Text.TASK_Main_GetBackTruck",
    sVehicleFetchID = "A1M0_Text.TASK_TaxiJules_Enter",
    sDropoffTextID = "A1M0_Text.TASK_Main_GotoBar",
    tDestLocators = {
      gsA12Germ .. "main\\LOC_Dropoff"
    },
    tPickupProxObj = {
      self.tInfo.Jules
    },
    PickupProximity = 80,
    tDestRegion = {
      gsA12Germ .. "main\\REG_Dropoff"
    },
    tDeliverObjs = {
      self.tInfo.Jules
    },
    bEscalationDenial = true,
    bGroundBlip = true,
    sRequiredVehicle = self.tInfo.Car,
    tOnEarlyExit = {},
    tOnPickup = {},
    tOnComplete = {
      {
        self.ReleaseTruck,
        {self}
      },
      {
        HUD.ClearWaypoint,
        {}
      }
    },
    tOnActivate = {
      {
        HUD.SetWaypoint,
        {
          2575,
          -2385,
          20
        }
      }
    }
  })
end

function Act_1_ToGermany:ReleaseTruck()
  SabTaskObjectiveDeliver.StopVehicle(self, Handle(self.tInfo.Car))
  EVENT_Timer("Act_1_ToGermany.DumpHim", self, 0.3)
  local hCar = Handle(self.tInfo.Car)
  if hCar then
  end
  self:Convo_Pits()
end

function Act_1_ToGermany:DumpHim()
  if Actor.IsInVehicle(hSab) then
    Actor.UnboardVehicle(hSab)
    EVENT_ActorExitsAnyVehicle("Act_1_ToGermany.FinishUp", self, hSab)
  else
    self:FinishUp()
  end
  self.tSaveInfo.eSafety = EVENT_Timer("Act_1_ToGermany.DumpHim", self, 5)
end

function Act_1_ToGermany:FinishUp()
  if self.tSaveInfo.eSafety then
    Util.KillEvent(self.tSaveInfo.eSafety)
    self.tSaveInfo.eSafety = nil
  end
  SabTaskObjectiveDeliver.ReleaseVehicle(self, Handle(self.tInfo.Car))
  local hCar = Handle(self.tInfo.Car)
  if hCar then
    Vehicle.LockAllSeats(hCar)
  end
  self:CompleteThisMission()
end

function Act_1_ToGermany:Checkpoint2_Alpha()
  if not self:IsMissionTaskActive("Task_GoTo") then
    self:Task_GoTo()
  end
  self:SetupPaperCheckpoint()
  Saboteur.ShowToolTip("TutorialTip_Text.World_Checkpoint_with_Papers")
  self:TASK_GPSSwitch()
  self:SetupConvosPart2()
end

function Act_1_ToGermany:Checkpoint2()
  if not self:IsMissionTaskActive("Task_GoTo") then
    self:Task_GoTo()
  end
  self:SetupPaperCheckpoint()
  Saboteur.ShowToolTip("TutorialTip_Text.World_Checkpoint_with_Papers")
  self:TASK_GPSSwitch()
  self:SetupConvosPart2()
end

function Act_1_ToGermany:RegisterCheckpoint2()
  local hCurrentVehicle = Actor.GetVehicle(hSab)
  local hTruck = Handle(self.tInfo.Car)
  if hCurrentVehicle and hCurrentVehicle == hTruck then
    self:RegisterCheckpoint("Act_1_ToGermany.Checkpoint2", "Act_1_ToGermany.Checkpoint2_Alpha")
  else
    self:FailCarTooFar("A1M0_Text.FAIL_OutofTime")
  end
end

function Act_1_ToGermany:TASK_Checkpoint2()
  self:CreateTask({
    sName = "TASK_Checkpoint2",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\togermany\\main\\REG_Checkpoint2",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.RegisterCheckpoint2,
        {self}
      }
    }
  })
end

function Act_1_ToGermany:SetupPaperCheckpoint()
  local tPaperEvent = {
    EventType = "OnPaperCheckPass",
    Target = hSab
  }
  self.tInfo.ePaperCheck = Util.CreateEvent(tPaperEvent, "Act_1_ToGermany.MyMindIsMush", self, {true})
  self:RegisterEvent(self.tInfo.ePaperCheck)
end

function Act_1_ToGermany:SetupGateSwitch()
  if self.tSaveInfo.bGotPastCP then
    return
  end
  if self:IsMissionTaskActive("Task_OpenGate") then
    self:ResetTaskByName("Task_OpenGate", true)
  end
  EVENT_Stream("Act_1_ToGermany.GateSwitchStreamed", self, {
    self.tInfo.CPGateSwitch
  })
end

function Act_1_ToGermany:SetupGateDoor()
  if self.tSaveInfo.bGotPastCP then
    return
  end
  EVENT_Stream("Act_1_ToGermany.GateDoorStreamed", self, {
    self.tInfo.CPGate
  })
end

function Act_1_ToGermany:GateSwitchStreamed()
  if self.tSaveInfo.bGotPastCP then
    return
  end
  EVENT_StreamOut("Act_1_ToGermany.SetupGateSwitch", self, {
    self.tInfo.CPGateSwitch
  })
  self:Task_OpenGate()
end

function Act_1_ToGermany:GateDoorStreamed()
  if self.tInfo.eGateDeath then
    Util.KillEvent(self.tInfo.eGateDeath)
  end
  if self.tSaveInfo.bGotPastCP then
    return
  end
  self.tInfo.eGateDeath = EVENT_ActorDeath("Act_1_ToGermany.GateDestroyed", self, self.tInfo.CPGate)
  EVENT_StreamOut("Act_1_ToGermany.SetupGateDoor", self, {
    self.tInfo.CPGate
  })
end

function Act_1_ToGermany:GateDestroyed()
  self:MyMindIsMush({}, true)
end

function Act_1_ToGermany:Task_OpenGate()
  if self.tSaveInfo.bGotPastCP then
    return
  end
  self:CreateTask({
    sName = "Task_OpenGate",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    tTgtInclude = {
      self.tInfo.CPGateSwitch
    },
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    bNoFocus = true,
    bNoGPS = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.MyMindIsMush,
        {
          self,
          {},
          true
        }
      }
    }
  })
end

function Act_1_ToGermany:SetGateStatus()
  self.tSaveInfo.bGateOpen = true
end

function Act_1_ToGermany:MyMindIsMush(tArgs, bGateOpen)
  print("wthf ", bGateOpen, sadtimes)
  if (self.tSaveInfo.bGateOpen or bGateOpen) and self:IsMissionTaskActive("Task_TaxiJules") then
    self:CompleteTaskByName("Task_TaxiJules")
    self:CompleteTaskByName("TASK_GetPastCheckpoint")
  elseif self:IsMissionTaskActive("TASK_GetPastCheckpoint") then
    self:CompleteTaskByName("TASK_GetPastCheckpoint")
  elseif self:IsMissionTaskActive("Task_TaxiJules") then
    self:CompleteTaskByName("Task_TaxiJules")
  end
end

function Act_1_ToGermany:SwitchObjective(task, bUpdate)
  local otask = self:GetMissionTask(task)
  if otask then
    local tConfig = otask:GetConfig()
    tConfig.sObjectiveTextID = "A1M0_Text.TASK_GetPastCheckpoint"
    tConfig.sDropoffTextID = "A1M0_Text.TASK_GetPastCheckpoint"
  end
  if bUpdate then
    self:ChangeObjTextByName(task, "A1M0_Text.TASK_GetPastCheckpoint")
  end
end

function Act_1_ToGermany:SetupConvosPart1()
  self:TASK_Convo_Truck_Drive01()
  self:TASK_Convo_Truck_Border()
end

function Act_1_ToGermany:SetupConvosPart2()
  self:TASK_Convo_Truck_Drive02()
end

function Act_1_ToGermany:TASK_Convo_Truck_Drive01()
  self:CreateTask({
    sName = "TASK_Convo_Truck_Drive01",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\togermany\\main\\REG_Convo_Truck_Drive01",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Convo_Truck_Drive01,
        {self}
      }
    }
  })
end

function Act_1_ToGermany:TASK_Convo_Truck_Border()
  self:CreateTask({
    sName = "TASK_Convo_Truck_Border",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\togermany\\main\\REG_Convo_Truck_Border",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Convo_Truck_Border,
        {self}
      }
    }
  })
end

function Act_1_ToGermany:TASK_Convo_Truck_Drive02()
  self:CreateTask({
    sName = "TASK_Convo_Truck_Drive02",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\togermany\\main\\REG_Convo_Truck_Drive02",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Convo_Truck_Drive02,
        {self}
      }
    }
  })
end

function Act_1_ToGermany:TASK_Convo_Truck_Drive03()
  self:CreateTask({
    sName = "TASK_Convo_Truck_Drive03",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\togermany\\main\\REG_Convo_Truck_Drive03",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Convo_Truck_Drive03,
        {self}
      }
    }
  })
end

function Act_1_ToGermany:TASK_ConvGetGoing()
  self:CreateTask({
    sName = "TASK_ConvGetGoing",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\togermany\\farm_population\\REG_GetGoing",
    bNegate = true,
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        self.SetupGetGoingConv,
        {self}
      }
    },
    tOnComplete = {
      {
        self.ClearGetGoing,
        {self}
      }
    }
  })
end

function Act_1_ToGermany:SetupGetGoingConv()
  self.tInfo.eGetGoing = EVENT_Timer("Act_1_ToGermany.GetGoingConv", self, 30)
  self.tSaveInfo.bGetGoing = true
end

function Act_1_ToGermany:GetGoingConv()
  if self.tSaveInfo.bGetGoing then
    Cin.PlayConversation("A1M0_GetToTrack_Reminder")
    self.tInfo.eGetGoing = EVENT_Timer("Act_1_ToGermany.GetGoingConv", self, 45)
  end
end

function Act_1_ToGermany:ClearGetGoing()
  self.tSaveInfo.bGetGoing = false
  if self.tInfo.eGetGoing then
    Util.KillEvent(self.tInfo.eGetGoing)
    self.tInfo.eGetGoing = nil
  end
end

function Act_1_ToGermany:Convo_GetIn()
  Cin.PlayConversation("A1M0_Taxi_GetIn")
end

function Act_1_ToGermany:VehicleEnterTut()
  EVENT_ActorToActorProximity("Act_1_ToGermany.VehicleEnterTutFIRE", self, self.tInfo.Car, hSab, 6)
end

function Act_1_ToGermany:VehicleEnterTutFIRE()
end

function Act_1_ToGermany:HandBreakTut()
  EVENT_Timer("Act_1_ToGermany.HandBreakTutFire", self, 40)
end

function Act_1_ToGermany:HandBreakTutFire()
end

function Act_1_ToGermany:Convo_Truck_Drive01()
  Cin.PlayConversation("103_InG_Truck-Drive01")
end

function Act_1_ToGermany:Convo_Truck_Border()
  Cin.PlayConversation("103_InG_Truck-Border")
end

function Act_1_ToGermany:Convo_Truck_Drive02()
  ConvoHelper.InterruptReplay("103_InG_Truck-Drive02", "Drive2Germany_Convo1", "Act_1_ToGermany.Convo_Truck_Drive03", Act_1_ToGermany)
end

function Act_1_ToGermany:Convo_Truck_Drive03()
  ConvoHelper.InterruptReplay("103_InG_Truck-Drive03", "Drive2Germany_Convo2")
end

function Act_1_ToGermany:Convo_Pits()
  Cin.PlayConversation("105_Con_Pits")
end

function Act_1_ToGermany:TASK_GPSSwitch()
  self:CreateTask({
    sName = "TASK_GPSSwitch",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\togermany\\main\\REG_GPSSwitch",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        HUD.ClearWaypoint,
        {}
      }
    }
  })
end
