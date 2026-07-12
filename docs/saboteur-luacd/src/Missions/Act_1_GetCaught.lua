if Act_1_GetCaught == nil then
  Act_1_GetCaught = SabTaskObjective:Create()
  Act_1_GetCaught.PATH = "Missions\\act_1\\getcaught\\"
  Act_1_GetCaught:Configure({
    TaskCount = 99,
    bSLOverrideFade = true,
    MCDisplayID = 2,
    bStarterless = true,
    tUnlockList = {
      "Connect_ST_121_Questioning"
    },
    sSaveMissionNameID = "MissionNames_Text.A1M3",
    tSMEDNodes = {
      "Missions\\act_1\\getcaught\\raceteleport"
    },
    tStaticTags = {
      "A1M3_ForCinematicAudience"
    }
  })
end

function Act_1_GetCaught:STARTER_Setup()
  Util.SetTime(16, 0)
  Render.SetGlobalWTF(true)
  Util.UnloadStaticENTag("A1M1_GetCaught", true)
end

function Act_1_GetCaught:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "MOTOR"
  self.bDebugMode = false
  Cin.LoadCinematic("116_CinB_FollowD")
  Util.SetDynamicPriority("VH_CV_CR_Bugatti_01_Vittore", 15000)
  self.QuickChange(self)
  self.TASK_FatLoad(self)
  Vehicle.EnableTraffic(false, true)
  self.nTrafficCount = 1
end

function Act_1_GetCaught:QuickChange()
  print("QuickChange ONE")
  if Actor.IsInVehicle(hSab) then
    local hSeanCar = Actor.GetVehicle(hSab)
    Vehicle.HardSetLinVel(hSeanCar, 0)
    Actor.UnboardVehicle(hSab)
    EVENT_PlayerExitsAnyVehicle("Act_1_GetCaught.QuickChange2", self)
  else
    Object.PlayerTeleportToLocator(Util.GetHandleByName("Missions\\act_1\\getcaught\\raceteleport\\LOC_SeanAfterRace"), false, true, "Act_1_GetCaught.StreamStuff", self)
  end
end

function Act_1_GetCaught:QuickChange2()
  print("QuickChange TWO")
  Object.PlayerTeleportToLocator(Util.GetHandleByName("Missions\\act_1\\getcaught\\raceteleport\\LOC_SeanAfterRace"), false, true, "Act_1_GetCaught.StreamStuff", self)
end

function Act_1_GetCaught:Task_PlayFinishCin()
  self:CreateTask({
    sName = "Task_PlayFinishCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "115_CinA_CheatBINK",
    bOverrideFade = true,
    tOnActivate = {},
    tOnComplete = {}
  })
end

function Act_1_GetCaught:TASK_FatLoad()
  self:CreateTask({
    sName = "TASK_FatLoad",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\act_1\\getcaught\\smartpathblock\\triggerloads",
      "Missions\\act_1\\getcaught\\teleportcinematic",
      "Missions\\act_1\\getcaught\\sensoryswitch",
      "Missions\\act_1\\getcaught\\julesjumpcinematic"
    },
    tStaticTags = {
      "a1m3_DoppProps",
      "a1m3_spawner"
    },
    tOnActivate = {}
  })
  self:CreateTask({
    sName = "TASK_FatLoad_NaziPatrol",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\act_1\\getcaught\\NaziPatrol"
    }
  })
  self:CreateTask({
    sName = "TASK_FatLoad_Dierker_car",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      Act_1_GetCaught.PATH .. "silverdart_start"
    }
  })
end

function Act_1_GetCaught:StreamStuff()
  Sound.LoadSoundBank("m_A1M3_inGame.bnk")
  Actor.SetDisguise(hSab, "FBS_RS_Sean_Shirt_Sab_Hat_NoBag")
  Util.UnloadStaticENTag("wpop_doppNazis", true)
  Sound.SetMusicLocale("A1M3_GetCaught")
  self.Task_IntroCin(self)
end

function Act_1_GetCaught:Task_IntroCin()
  self:CreateTask({
    sName = "Task_IntroCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "116_CinB_FollowD",
    bOverrideFade = true,
    sMusicLocale = "A1M3_GetCaught",
    tSMEDNodes = {},
    tOnActivate = {},
    tOnComplete = {
      {
        Util.SetOverrideLoadScreenFadeIn,
        {false}
      },
      {
        self.UnloadTaskNodes,
        {
          self,
          "Task_IntroCin",
          true
        }
      },
      {
        self.CinematicIntroSetup,
        {self}
      }
    },
    tCinematicNodes = {
      "116_cinb_followd"
    }
  })
end

function Act_1_GetCaught:Task_PickupJules()
  self:CreateTask({
    sName = "Missions\\act_1\\getcaught\\doppnazis",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      "Missions\\act_1\\getcaught\\doppnazis"
    }
  })
  self.BlipCarFunction(self)
  self.Spawn1Node(self)
  Util.SetDynamicPriority("Human_RS_Jules_PitWorker", -1)
  Util.SetTime(10, 10)
  Util.BlendTimeOfDay(12, 150)
  FocusPt.Create(0, 0, 0, 150, 1000, true, true, self.hDierker)
  self.nConvoFlag1 = 0
  self:CreateTask({
    sName = "Task_PickupJules",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sVehicleReturnID = "GenericObjective_Text.Vehicle_GetIn_The",
    sObjectiveTextID = "A1M3_Text.Task_TailDierker",
    sPickupTextID = "A1M3_Text.Task_PickupJules_P",
    sDropoffTextID = "A1M3_Text.Task_TailDierker",
    sVehicleFetchID = "GenericObjective_Text.Vehicle_GetIn_The",
    bNoGPS = true,
    bNoFocus = true,
    tPickupRegion = {
      "Missions\\act_1\\getcaught\\main\\PT_PickUp"
    },
    tDestRegion = {
      self.PATH .. "main\\PT_FactoryPark"
    },
    tDeliverObjs = {
      self.PATH .. "main\\Spore_RS_Jules"
    },
    sRequiredVehicle = Handle("Missions\\act_1\\getcaught\\main\\VittoreCar"),
    tStaticTags = {
      "a1m3_bandstand"
    },
    tOnEarlyExit = {
      {
        Cin.PlayConversation,
        {
          "A1M3_Tail_ExitVehicle"
        }
      }
    },
    tOnWait = {
      {
        self.SeeIfConvoMakesSense_JulesGetIn,
        {self}
      },
      {
        HUD.ClearGPSTarget,
        {}
      }
    },
    tOnPickup = {
      {
        Convo.AddConvo,
        {
          "117_InG_TailD-FollowRules",
          10,
          {}
        }
      },
      {
        self.DierkerGo,
        {self}
      },
      {
        self.UnBlipCarFunction,
        {self}
      },
      {
        HUD.ClearGPSTarget,
        {}
      }
    },
    tOnActivate = {
      {
        self.HaysConvo_PickUpJules,
        {self}
      },
      {
        self.DierkerGoTimer,
        {self}
      },
      {
        Nav.BoardVehicle,
        {
          self.hJules,
          self.hJulesCar,
          "SHOTGUN",
          false
        }
      },
      {
        self.DierkerStart,
        {self}
      },
      {
        self.StartScene,
        {self}
      },
      {
        self.SetupAmbientEvents,
        {self}
      },
      {
        self.SetupFinishingDriveTask,
        {self}
      }
    },
    tOnComplete = {
      {
        self.FadeOutToTeleportToStartLocation,
        {nil}
      },
      {
        self.UnBlipParkSpot,
        {self}
      },
      {
        self.EsclationCleanUp,
        {self}
      }
    }
  })
  local tEvent = {EventType = "TimerEvent", Time = 0.3}
  Util.CreateEvent(tEvent, "Act_1_GetCaught.FadeOutSmallDelay", self)
  local hVitCar = Handle("Missions\\act_1\\getcaught\\main\\VittoreCar")
  Vehicle.LockSeat(hVitCar, "SHOTGUN", true)
  self.hCarDeathEventVittore = EVENT_ActorDeath("Act_1_GetCaught.Restart", self, "Missions\\act_1\\getcaught\\main\\VittoreCar", {
    "GenericFail_Text.DESTROYED_Car_The"
  }, false)
  EVENT_PlayerEntersVehicle("Act_1_GetCaught.LockSeat", self, "Missions\\act_1\\getcaught\\main\\VittoreCar", nil, false)
end

function Act_1_GetCaught:LockSeat()
  Actor.SetCannotGetOutOfSeat(hSab, true)
end

function Act_1_GetCaught:CinematicIntroSetup()
  Actor.SetDisguise(hSab, "FBS_RS_Sean_Shirt_Sab_Hat_NoBag")
  Util.SetDynamicPriority("Human_RS_Skylar", -1)
  Util.SetDynamicPriority("Human_RS_Veronique", -1)
  Util.SetDynamicPriority("Human_RS_Vittore", -1)
  Util.SetDynamicPriority("Human_RS_Jules", -1)
  Util.SetDynamicPriority("Human_RS_Jules_PitWorker", -1)
  self:CreateTask({
    sName = Act_1_GetCaught.PATH .. "main",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      Act_1_GetCaught.PATH .. "main"
    }
  })
  Util.LoadStaticENTag("a1m3_StartProps", true)
  Object.PlayerTeleportToPos(2849, 40, -2242, -128, false, "Act_1_GetCaught.UnfadeAndResumeGame", self)
end

function Act_1_GetCaught:TeleportToOrigin()
  Object.PlayerTeleportToPos(2849, 40, -2242, -128, false, "Act_1_GetCaught.UnfadeAndResumeGame", self)
end

function Act_1_GetCaught:UnfadeAndResumeGame()
  Act_1_GetCaught:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\act_1\\getcaught\\startprops\\Spore_RS_Skylar",
      "Missions\\act_1\\getcaught\\startprops\\Spore_RS_Veronique",
      "Missions\\act_1\\getcaught\\main\\Spore_RS_Jules",
      "Missions\\act_1\\getcaught\\silverdart_start\\VH_CV_CR_SilverDart_01",
      "Missions\\act_1\\getcaught\\silverdart_start\\Spore_NZ_Dierker_RaceDriver",
      "Missions\\act_1\\getcaught\\main\\VittoreCar"
    },
    WaitForGameObject = true
  }, "Act_1_GetCaught.FirstSave", self))
end

function Act_1_GetCaught:FadeOutSmallDelay()
  Render.FadeScreen(false)
end

function Act_1_GetCaught:FirstSave()
  local tEvent = {EventType = "TimerEvent", Time = 0.3}
  Util.CreateEvent(tEvent, "Act_1_GetCaught.FadeOutSmallDelay", self)
  self:RegisterCheckpoint("Act_1_GetCaught.Checkpoint1")
end

function Act_1_GetCaught:Checkpoint1()
  Suspicion.ResetEscalation()
  Actor.SetCannotGetOutOfSeat(hSab, false)
  Util.UnregisterLuaUpdate("Act_1_GetCaught.EvaluateParanoia")
  Util.UnloadStaticENTag("A1M3_ForCinematicAudience", true)
  Convo.ResetForFail()
  self.CleanUpHudElements(self)
  self.GENERAL_Setup(self)
  self.tInfo.nDierkerAlert = 0
  self.tInfo.bPlayerReady = false
  self.tInfo.bDartWarned = false
  self.dopp_start_playing = false
  self.tSaveInfo.ItHasFailed = false
  local tStreamEvent = {
    EventType = "StreamEvent",
    EventName = "DierkerStreamEvent",
    Objects = {
      self.hDierker
    },
    WaitForGameObject = false,
    WaitForPathfinding = false,
    WaitForPhysics = false,
    WaitForStreamOut = true
  }
  self.DierkerStreamEvent = Util.CreateEvent(tStreamEvent, "Act_1_GetCaught.FarFail", self)
  self:RegisterEvent(self.DierkerStreamEvent)
  local tWeaponEvent = {
    EventType = "InventoryCheckEvent",
    HumanHandle = hSab,
    ItemInHand = true,
    Item = "",
    IsBlueprint = true,
    WeaponOnly = true
  }
  self.WeaponEvent = Util.CreateEvent(tWeaponEvent, "Act_1_GetCaught.PlayerWeaponDrawnSaar", self)
  self:RegisterEvent(self.WeaponEvent)
  local tDNearGateEvent = {
    EventType = "ProximityEvent",
    ObjectA = self.hDierker,
    ObjectB = Handle(self.PATH .. "main\\LOC_DNearGate"),
    Proximity = 20,
    Negate = false
  }
  self.DNearGateEvent = Util.CreateEvent(tDNearGateEvent, "Act_1_GetCaught.DierkerNearGate", self)
  self:RegisterEvent(self.DNearGateEvent)
  local tSabVehEnterEvent = {
    EventType = "OnVehicleEnter",
    Target = hSab
  }
  self.SabVehEnterEvent = Util.CreateEvent(tSabVehEnterEvent, "Act_1_GetCaught.GrabCarHandle", self)
  self:RegisterEvent(self.SabVehEnterEvent)
  local tDCarDamEvent = {
    EventType = "DamageEvent",
    ObjectHandle = self.hDierkersCar
  }
  self.DCarDamEvent = Util.CreateEvent(tDCarDamEvent, "Act_1_GetCaught.DierkerBumpedIn", self)
  self:RegisterEvent(self.DCarDamEvent)
  local tDCarjackEvent = {
    EventType = "EnteredVehicleEvent",
    EventName = "CarjackEvent",
    ObjectHandle = hSab,
    VehicleHandle = self.hDierkersCar
  }
  self.DCarjackEvent = Util.CreateEvent(tDCarjackEvent, "Act_1_GetCaught.CarjackFail", self)
  self:RegisterEvent(self.DCarjackEvent)
  local tDCarDamEvent = {
    EventType = "DamageEvent",
    ObjectHandle = self.hDierker
  }
  self.DDierkerDamEvent = Util.CreateEvent(tDCarDamEvent, "Act_1_GetCaught.CarjackFail", self)
  self:RegisterEvent(self.DDierkerDamEvent)
  local tParkTrigger = Trigger.WaitFor(self.PATH .. "main\\PT_ParkCar", self.hDierkersCar, "Act_1_GetCaught.ParkCar", self, {-1})
  self:RegisterTriggerEvent(tParkTrigger, self.PATH .. "main\\PT_ParkCar")
  local tGroupieTrigger = Trigger.WaitFor(self.PATH .. "main\\PT_GroupieWave", self.hDierker, "Act_1_GetCaught.WaveGirls", self, {-1})
  self:RegisterTriggerEvent(tGroupieTrigger, self.PATH .. "main\\PT_GroupieWave")
  local tFallbackTrigger = Trigger.WaitFor(self.PATH .. "main\\PT_DoppFarFail", Handle("Saboteur"), "Act_1_GetCaught.FallBack", self, {-1})
  self:RegisterTriggerEvent(tFallbackTrigger, self.PATH .. "main\\PT_DoppFarFail")
  local tStashCarTrigger = Trigger.WaitFor(self.PATH .. "main\\PT_VO_StashCar", Handle("Saboteur"), "Act_1_GetCaught.NearMotorworks", self, {-1})
  self:RegisterTriggerEvent(tStashCarTrigger, self.PATH .. "main\\PT_VO_StashCar")
  local tLeavingTrigger = Trigger.WaitFor(Handle("Missions\\act_1\\getcaught\\main\\PT_LeavingTown"), self.hDierker, "Act_1_GetCaught.LeavingTownVO", self, {-1})
  self:RegisterTriggerEvent(tLeavingTrigger, "Missions\\act_1\\getcaught\\main\\PT_LeavingTown")
  EVENT_PlayerEntersVehicle("Act_1_GetCaught.BlipDierker", self, self.hJulesCar)
  Sound.SetMusicLocale("A1M3_GetCaught")
  Sound.SetMusicLocale("m_A1M3_GetCaught", "followDierker")
  Actor.SetAutoSeatTransition(self.hJules, false)
  self.Task_PickupJules(self)
  Object.SetHealth(self.hDierkersCar, 100000)
  if self.hJulesStreamOut then
    Util.KillEvent(self.hJulesStreamOut)
  end
  self.hJulesStreamOut = Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      self.PATH .. "main\\Spore_RS_Jules"
    },
    WaitForStreamOut = true
  }, "Act_1_GetCaught.Restart", self, {
    "GenericFail_Text.ABANDON_Jules"
  })
  self:RegisterEvent(self.hJulesStreamOut)
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      "CountrySide\\alsace\\racetracks\\pitarea\\VH_CV_CR_Allard_01(2)"
    }
  }
  self.CarEntryDenyEvent1 = Util.CreateEvent(tStreamEvent, "Act_1_GetCaught.CarEntryDeny", self, {
    "CountrySide\\alsace\\racetracks\\pitarea\\VH_CV_CR_Allard_01(2)"
  })
  self:RegisterEvent(self.CarEntryDenyEvent1)
  tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      "CountrySide\\alsace\\racetracks\\pitarea\\VH_CV_CR_Allard_01(1)"
    }
  }
  self.CarEntryDenyEvent2 = Util.CreateEvent(tStreamEvent, "Act_1_GetCaught.CarEntryDeny", self, {
    "CountrySide\\alsace\\racetracks\\pitarea\\VH_CV_CR_Allard_01(1)"
  })
  self:RegisterEvent(self.CarEntryDenyEvent2)
  tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      "CountrySide\\alsace\\racetracks\\pitarea\\VH_CV_CR_Allard_01"
    }
  }
  self.CarEntryDenyEvent3 = Util.CreateEvent(tStreamEvent, "Act_1_GetCaught.CarEntryDeny", self, {
    "CountrySide\\alsace\\racetracks\\pitarea\\VH_CV_CR_Allard_01"
  })
  self:RegisterEvent(self.CarEntryDenyEvent3)
  tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      "CountrySide\\alsace\\racetracks\\pitarea\\VH_CV_CR_AlfaRomera_01(5)"
    }
  }
  self.CarEntryDenyEvent4 = Util.CreateEvent(tStreamEvent, "Act_1_GetCaught.CarEntryDeny", self, {
    "CountrySide\\alsace\\racetracks\\pitarea\\VH_CV_CR_AlfaRomera_01(5)"
  })
  self:RegisterEvent(self.CarEntryDenyEvent4)
  local tTrigger = Trigger.WaitFor("Missions\\act_1\\getcaught\\sensoryswitch\\PT_On1", self.hDierkersCar, "Act_1_GetCaught.KURTDIERKERsawSean", self, {-1})
  self:RegisterTriggerEvent(tTrigger, "Missions\\act_1\\getcaught\\sensoryswitch\\PT_On1")
  tTrigger = Trigger.WaitFor("Missions\\act_1\\getcaught\\sensoryswitch\\PT_On2", self.hDierkersCar, "Act_1_GetCaught.KURTDIERKERsawSean", self, {-1})
  self:RegisterTriggerEvent(tTrigger, "Missions\\act_1\\getcaught\\sensoryswitch\\PT_On2")
  tTrigger = Trigger.WaitFor("Missions\\act_1\\getcaught\\sensoryswitch\\PT_On3", self.hDierkersCar, "Act_1_GetCaught.KURTDIERKERsawSean", self, {-1})
  self:RegisterTriggerEvent(tTrigger, "Missions\\act_1\\getcaught\\sensoryswitch\\PT_On3")
  tTrigger = Trigger.WaitFor("Missions\\act_1\\getcaught\\sensoryswitch\\PT_On4", self.hDierkersCar, "Act_1_GetCaught.KURTDIERKERsawSean", self, {-1})
  self:RegisterTriggerEvent(tTrigger, "Missions\\act_1\\getcaught\\sensoryswitch\\PT_On4")
  tTrigger = Trigger.WaitFor("Missions\\act_1\\getcaught\\sensoryswitch\\PT_On5", self.hDierkersCar, "Act_1_GetCaught.KURTDIERKERsawSean", self, {-1})
  self:RegisterTriggerEvent(tTrigger, "Missions\\act_1\\getcaught\\sensoryswitch\\PT_On5")
  tTrigger = Trigger.WaitFor("Missions\\act_1\\getcaught\\sensoryswitch\\PT_Off1", self.hDierkersCar, "Act_1_GetCaught.KillOffSensoryEvent", self, {-1})
  self:RegisterTriggerEvent(tTrigger, "Missions\\act_1\\getcaught\\sensoryswitch\\PT_Off1")
  tTrigger = Trigger.WaitFor("Missions\\act_1\\getcaught\\sensoryswitch\\PT_Off2", self.hDierkersCar, "Act_1_GetCaught.KillOffSensoryEvent", self, {-1})
  self:RegisterTriggerEvent(tTrigger, "Missions\\act_1\\getcaught\\sensoryswitch\\PT_Off2")
  tTrigger = Trigger.WaitFor("Missions\\act_1\\getcaught\\sensoryswitch\\PT_Off3", self.hDierkersCar, "Act_1_GetCaught.KillOffSensoryEvent", self, {-1})
  self:RegisterTriggerEvent(tTrigger, "Missions\\act_1\\getcaught\\sensoryswitch\\PT_Off3")
  Combat.SetGrabbable(self.hJules, false)
end

function Act_1_GetCaught:KURTDIERKERsawSean()
end

function Act_1_GetCaught:KillOffSensoryEvent()
  if self.hDierkerSensory then
    Util.KillEvent(self.hDierkerSensory)
    self.hDierkerSensory = nil
  end
end

function Act_1_GetCaught:CarEntryDeny(sVehicle)
  Vehicle.LockAllSeats(Handle(sVehicle), true)
end

function Act_1_GetCaught.OnConversationDisables()
  DisablePlayersAttack(true)
  DisablePlayersMovement(true)
end

function Act_1_GetCaught.OffConversationDisables()
  DisablePlayersAttack(false)
  DisablePlayersMovement(false)
end

function Act_1_GetCaught.SetupGamepadListener()
  local self = Act_1_GetCaught
  self.tControllerEvent = {
    EventType = "OnButtonPress",
    Target = Handle("Saboteur")
  }
  local eButtonEvent = Util.CreateEvent(self.tControllerEvent, "Act_1_GetCaught.OnButtonPress", self, {}, true)
  self:RegisterEvent(eButtonEvent)
end

function Act_1_GetCaught:OnButtonPress(a_tButtonData)
  local self = Act_1_GetCaught
  local tButtons = a_tButtonData[1]
end

function Act_1_GetCaught:DierkerBumpedIn(tArgs)
  local hAttacker = tArgs[1]
  local damageFlags = tArgs[2]
  local damageAmount = tArgs[3]
  if hAttacker == Handle("Missions\\act_1\\getcaught\\main\\VittoreCar") or hAttacker == hSab then
    Nav.SetScriptedPath(self.hDierker, "Missions\\act_1\\getcaught\\pathblocker\\PATH_OneShot(1)", true)
    Nav.SetScriptedPathSpeed(self.hDierkersCar, 120)
    self.tSaveInfo.ItHasFailed = true
    self.IncreaseParanoia(self, 100)
    local eFailWait = Util.CreateEvent({
      EventType = "TimerEvent",
      EventName = "FailWait2",
      Time = 3
    }, "Act_1_GetCaught.Restart", self, {
      "A1M3_Fail.AgitateDierker"
    })
    self:RegisterEvent(eFailWait)
    if self.hEscalationTimerFail then
      Util.KillEvent(self.hEscalationTimerFail)
    end
    if Cin.IsHumanInConversation(hSab) == false then
      Convo.AddConvo("A1M3_Tail_TooClose_Panic", 10, {})
    end
  end
end

function Act_1_GetCaught:LaunchTest(t_args)
  if self.hCarDeathEvent then
    Util.KillEvent(self.hCarDeathEvent)
  end
  if t_args[2] == Handle("Missions\\act_1\\getcaught\\silverdart_dopp\\VH_CV_CR_SilverDart_01") then
    local hDriver = Vehicle.GetPilot(Handle("Missions\\act_1\\getcaught\\silverdart_dopp\\VH_CV_CR_SilverDart_01"))
    local tObjects = Trigger.GetAllWithin(Handle("Missions\\act_1\\getcaught\\main\\PT_CarOffCliff"))
    if Vehicle.GetPilot(Handle("Missions\\act_1\\getcaught\\silverdart_dopp\\VH_CV_CR_SilverDart_01")) == hSab then
      self.Restart(self, "A1M3_Fail.BailFail")
      Util.KillEvent(self.e_CrashTrig)
      self.tInfo.bWin = 0
    else
      if tObjects then
        for i, hEnt in ipairs(tObjects) do
          if hEnt == hSab then
            self.Restart(self, "A1M3_Fail.BailFail")
            Util.KillEvent(self.e_CrashTrig)
            self.tInfo.bWin = 0
            break
          end
        end
      end
      tObjects = Trigger.GetAllWithin(Handle("Missions\\act_1\\getcaught\\main\\PT_NoSabZone"))
      if tObjects then
        for i, hEnt in ipairs(tObjects) do
          if hEnt == hSab then
            self.Restart(self, "A1M3_Fail.BailFail")
            Util.KillEvent(self.e_CrashTrig)
            self.tInfo.bWin = 0
            break
          end
        end
      end
      local hCar = Handle("Missions\\act_1\\getcaught\\silverdart_dopp\\VH_CV_CR_SilverDart_01")
      if 2 >= Object.GetDistance(hCar, hSab) then
        self.Restart(self, "A1M3_Fail.BailFail")
        Util.KillEvent(self.e_CrashTrig)
        self.tInfo.bWin = 0
      end
    end
    if self.tInfo.bWin == 1 then
      Util.KillEvent(self.e_CrashTrig)
      self.tInfo.bWin = 2
      self.CompleteTaskByName(self, "Task_LaunchDierkerCar")
      self.CompleteTaskByName(self, "Task_TrashCar")
      self.Task_EndCutscene(self)
    end
  elseif t_args[2] == hSab then
    self.Restart(self, "A1M3_Fail.BailFail")
    Util.KillEvent(self.e_CrashTrig)
    self.tInfo.bWin = 0
  end
end

function Act_1_GetCaught:GENERAL_Setup()
  self:AddOnCancelCallback(Act_1_GetCaught.ResetMissionOnCancel)
  self:AddOnCompleteCallback(Act_1_GetCaught.ResetMission)
  self.hDierkersCar = Util.GetHandleByName(self.PATH .. "silverdart_start\\VH_CV_CR_SilverDart_01")
  self.hDierker = Util.GetHandleByName(self.PATH .. "silverdart_start\\Spore_NZ_Dierker_RaceDriver")
  self.hJulesCar = Util.GetHandleByName(self.PATH .. "main\\VittoreCar")
  self.hJules = Util.GetHandleByName(self.PATH .. "main\\Spore_RS_Jules")
  self.hGateL = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\exteriorarea\\props\\OccMed_DoppWall_Gate_L")
  self.hGateR = Util.GetHandleByName("CountrySide\\alsace\\doppelsieg\\exteriorarea\\props\\OccMed_DoppWall_Gate_R")
  self.hParkSpot = Util.GetHandleByName(self.PATH .. "main\\LOC_ParkHere")
  self.hVeronique = Util.GetHandleByName(self.PATH .. "startprops\\Spore_RS_Veronique")
  self.hSkylar = Util.GetHandleByName(self.PATH .. "startprops\\Spore_RS_Skylar")
  self.hGroupie1 = Util.GetHandleByName(self.PATH .. "startprops\\Spore_CG_Groupie1")
  self.hGroupie2 = Util.GetHandleByName(self.PATH .. "startprops\\Spore_CG_Groupie2")
  self.hGroupie3 = Util.GetHandleByName(self.PATH .. "startprops\\Spore_CG_Groupie3")
  Actor.SetLabel(hSab, " WPOP_RACE_TIME ", true)
  self.tInfo.bFinalCin = 0
  self.tInfo.bWin = 1
  self.tSaveInfo.bDelay = false
end

function Act_1_GetCaught:Restart(sMessage)
  Convo.ResetForFail()
  local hCar = Handle("Missions\\act_1\\getcaught\\silverdart_dopp\\VH_CV_CR_SilverDart_01")
  if hCar then
    Vehicle.ClearDeathCallback(hCar)
  end
  if self:GetMissionTaskFail() == false then
    self.nCurrentParanoia = 100
    if self.hHUDObjective then
      HUD.SetProgressBarValue(self.hHUDObjective, self.nCurrentParanoia)
    end
    Sound.SetMusicLocale("A1M3_GetCaught")
    Suspicion.SetEscalationLevel(0)
    if sMessage then
      self:MissionTaskFail(sMessage)
    else
      self:MissionTaskFail()
    end
  end
end

function Act_1_GetCaught:Reset()
  Actor.SetLabel(hSab, " WPOP_RACE_TIME ", false)
  Sound.ResetMusicLocale()
  Sound.ReleaseSoundBank("m_A1M3_InGame.bnk")
end

function Act_1_GetCaught:PlayerWeaponDrawnSaar()
  Cin.PlayConversation("A1M3_Tail_EquipsGun")
end

function Act_1_GetCaught:CarjackFail()
  self.Restart(self, "A1M3_Fail.CarJackingFail")
end

function Act_1_GetCaught:LeavingTownVO()
  Cin.StopConversation("A1M3_Tail_TooClose_Warning")
  Convo.AddConvo("117_InG_TailD-LeavingTown", 10, {})
end

function Act_1_GetCaught:PT_TalkAboutVero()
  Cin.StopConversation("A1M3_Tail_TooClose_Warning")
  Convo.AddConvo("103_InG_Truck-Drive03", 10, {})
end

function Act_1_GetCaught:JulesSaysJump()
  Convo.ResetForFail()
  Convo.AddConvo("A1M3_TrashCar_BailOut", 10, {})
end

function Act_1_GetCaught:GrabCarHandle()
  self.hPlayerCar = Actor.GetVehicle(hSab)
end

function Act_1_GetCaught:SetupDierkerTrig(a_sTrig, a_nSpeed)
  local eSetupTrig = Trigger.WaitFor(a_sTrig, self.hDierker, "Act_1_GetCaught.CallbackInterface", self, {
    Nav.SetScriptedPathSpeed,
    {
      self.hDierker,
      a_nSpeed
    }
  })
  self:RegisterTriggerEvent(eSetupTrig, a_sTrig)
end

function Act_1_GetCaught:CallbackInterface(a_tTriggerData, a_fCallback, a_tParams)
  if a_fCallback then
    if a_tParams then
      a_fCallback(unpack(a_tParams))
    else
      a_fCallback()
    end
  else
    Util.Assert(false, "Why don't we have any function to run?")
  end
end

function Act_1_GetCaught:WaveGirls()
  local tGroupie1Sequence = {
    {
      "DELAY",
      {2.5}
    },
    {
      "TURNTOFACE",
      {
        self.hDierkersCar
      }
    },
    {
      "DELAY",
      {0.7}
    },
    {
      "PLAYANIMATION",
      {
        "civ_F_flirt_front"
      }
    },
    {
      "DELAY",
      {90}
    },
    {
      "ENDSEQUENCE"
    },
    {
      "FAILSAFE_END"
    }
  }
  self.hGroupie1 = Util.GetHandleByName(self.PATH .. "startprops\\Spore_CG_Groupie1")
  self.hGroupie2 = Util.GetHandleByName(self.PATH .. "startprops\\Spore_CG_Groupie2")
  self.hGroupie3 = Util.GetHandleByName(self.PATH .. "startprops\\Spore_CG_Groupie3")
  local hGroupie = Handle(self.PATH .. "startprops\\Spore_CG_Groupie1")
  if hGroupie then
    ScriptSequence.Run(hGroupie, tGroupie1Sequence)
  end
  local tGroupie2Sequence = {
    {
      "DELAY",
      {2.5}
    },
    {
      "TURNTOFACE",
      {
        self.hDierkersCar
      }
    },
    {
      "DELAY",
      {0.5}
    },
    {
      "PLAYANIMATION",
      {
        "civ_f_doris_flirt01"
      }
    },
    {
      "DELAY",
      {90}
    },
    {
      "ENDSEQUENCE"
    },
    {
      "FAILSAFE_END"
    }
  }
  hGroupie = Handle(self.PATH .. "startprops\\Spore_CG_Groupie2")
  if hGroupie then
    ScriptSequence.Run(hGroupie, tGroupie2Sequence)
  end
  local tGroupie3Sequence = {
    {
      "DELAY",
      {2.5}
    },
    {
      "TURNTOFACE",
      {
        self.hDierkersCar
      }
    },
    {
      "DELAY",
      {0.85}
    },
    {
      "PLAYANIMATION",
      {
        "civ_f_doris_flirt02"
      }
    },
    {
      "DELAY",
      {90}
    },
    {
      "ENDSEQUENCE"
    },
    {
      "FAILSAFE_END"
    }
  }
  hGroupie = Handle(self.PATH .. "startprops\\Spore_CG_Groupie3")
  if hGroupie then
    ScriptSequence.Run(hGroupie, tGroupie3Sequence)
  end
end

function Act_1_GetCaught:KillAllGroupieSequence()
  self.hGroupie1 = Util.GetHandleByName(self.PATH .. "startprops\\Spore_CG_Groupie1")
  self.hGroupie2 = Util.GetHandleByName(self.PATH .. "startprops\\Spore_CG_Groupie2")
  self.hGroupie3 = Util.GetHandleByName(self.PATH .. "startprops\\Spore_CG_Groupie3")
  if self.hGroupie1 then
    Actor.CancelAnimation(self.hGroupie1)
    ScriptSequence.Kill(self.hGroupie1)
  end
  if self.hGroupie2 then
    Actor.CancelAnimation(self.hGroupie2)
    ScriptSequence.Kill(self.hGroupie2)
  end
  if self.hGroupie3 then
    Actor.CancelAnimation(self.hGroupie3)
    ScriptSequence.Kill(self.hGroupie3)
  end
end

function Act_1_GetCaught:TASK_DriveEscalator()
  self:CreateTask({
    sName = "TASK_DriveEscalator",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = true,
    tOnComplete = {
      {
        self.DriveEscalationCB,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Act_1_GetCaught:DriveEscalationCB()
  Convo.AddConvo("A1M3_Tail_Escalation", 10, {})
  self.tSaveInfo.ItHasFailed = true
  self.hEscalationTimerFail = Util.CreateEvent({
    EventType = "TimerEvent",
    EventName = "FailWait",
    Time = 4
  }, "Act_1_GetCaught.Restart", self, {
    "A1M3_Fail.EscalationFail"
  })
  self:RegisterEvent(self.hEscalationTimerFail)
end

function Act_1_GetCaught:TASK_DoppEscalator()
  if Suspicion.GetEscalation() > 0 then
    self.DoppEscalationCB(self)
  else
    self:CreateTask({
      sName = "TASK_DoppEscalator",
      sTaskType = "SabTaskObjectiveEscalation",
      sTaskSubType = "None",
      EscalationLevel = 1,
      bGTE = true,
      tOnComplete = {
        {
          self.DoppEscalationCB,
          {self}
        }
      },
      tOnActivate = {}
    })
  end
end

function Act_1_GetCaught:DoppEscalationCB()
  Convo.AddConvo("A1M3_TrashCar_Escalation_Fail", 10, {})
  local tempself = Actor.GetSelf(Util.GetHandleByName("Missions\\act_1\\getcaught\\spawner\\TriggerSpawner\\HumanSpawner2"))
  HumanSpawner.ActivateALL(tempself)
  self.tSaveInfo.ItHasFailed = true
  local eDoppTimer = Util.CreateEvent({
    EventType = "TimerEvent",
    EventName = "DoppEscTimer",
    Time = 4
  }, "Act_1_GetCaught.DoppEscFail", self)
  self:RegisterEvent(eDoppTimer)
end

function Act_1_GetCaught:DoppEscFail()
  self.Restart(self, "A1M3_Fail.EscalationFail")
end

function Act_1_GetCaught:Spawn1Node()
  self:CreateTask({
    sName = "Spawn1",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\getcaught\\smartpathblock\\triggerloads\\PT_part1",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Spawn2Node,
        {self}
      }
    },
    tOnActivate = {},
    tSMEDNodes = {}
  })
end

function Act_1_GetCaught:Spawn2Node()
  self:CreateTask({
    sName = "Spawn2",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\getcaught\\smartpathblock\\triggerloads\\PT_part2",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Spawn3Node,
        {self}
      }
    },
    tSMEDNodes = {
      "Missions\\act_1\\getcaught\\smartpathblock\\part1"
    }
  })
end

function Act_1_GetCaught:Spawn3Node()
  self:CreateTask({
    sName = "Spawn3",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\getcaught\\smartpathblock\\triggerloads\\PT_part3",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Spawn4Node,
        {self}
      }
    },
    tSMEDNodes = {
      "Missions\\act_1\\getcaught\\smartpathblock\\part2"
    }
  })
end

function Act_1_GetCaught:Spawn4Node()
  self:CreateTask({
    sName = "Spawn4",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\getcaught\\smartpathblock\\triggerloads\\PT_part4",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Spawn5Node,
        {self}
      }
    },
    tSMEDNodes = {
      "Missions\\act_1\\getcaught\\smartpathblock\\part3"
    }
  })
end

function Act_1_GetCaught:Spawn5Node()
  self:CreateTask({
    sName = "Spawn5",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\getcaught\\smartpathblock\\triggerloads\\PT_part5",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.SpawnLastNode,
        {self}
      }
    },
    tSMEDNodes = {
      "Missions\\act_1\\getcaught\\smartpathblock\\part4"
    }
  })
end

function Act_1_GetCaught:SpawnLastNode()
  self:CreateTask({
    sName = "Spawn5",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\getcaught\\smartpathblock\\triggerloads\\PT_UnloadAll",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.UnloadRemainingNodes,
        {self}
      }
    },
    tSMEDNodes = {
      "Missions\\act_1\\getcaught\\smartpathblock\\part5"
    }
  })
end

function Act_1_GetCaught:UnloadRemainingNodes()
end

function Act_1_GetCaught:DierkerGoTimer()
  local tEvent = {EventType = "TimerEvent", Time = 30}
  self.hTimerEvent = Util.CreateEvent(tEvent, "Act_1_GetCaught.DierkerGo", self)
  self:RegisterEvent(self.hTimerEvent)
  self.hDierkerCloseBeginingEvent = EVENT_PlayerToActorProximity("Act_1_GetCaught.DierkerGo", self, self.hDierker, 5, nil, false)
end

function Act_1_GetCaught:SetupFinishingDriveTask()
  self:CreateTask({
    sName = "FinishingDriveTask",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\getcaught\\main\\PT_ParkCinematic",
    tDeliverObjs = {
      hSab,
      self.hJules
    },
    tOnComplete = {
      {
        self.FinishTaskAfterDriveTask,
        {self}
      }
    }
  })
end

function Act_1_GetCaught:FinishTaskAfterDriveTask()
  if self.tSaveInfo.ItHasFailed == false then
    self:CompleteTaskByName("Task_PickupJules")
    HUD.RemoveObjectiveMarker(self.hDierkersCar)
  end
end

function Act_1_GetCaught.FadeOutToTeleportToStartLocation()
  Actor.SetCannotGetOutOfSeat(hSab, false)
  local tEvent = {EventType = "TimerEvent", Time = 0.2}
  Util.CreateEvent(tEvent, "Act_1_GetCaught.TeleportToStartLocation", nil)
end

function Act_1_GetCaught.TeleportToStartLocation()
  local x, y, z, rotate
  if Actor.IsInVehicle(hSab) then
    local hVehicle = Actor.GetVehicle(hSab)
    local hCarLocator = Handle("Missions\\act_1\\getcaught\\main\\LOC_StartParkPath")
    x, y, z = Object.GetPosition(hCarLocator)
    rotate = Object.GetAngle(hCarLocator)
    local tEvent = {EventType = "TimerEvent", Time = 2}
    Util.CreateEvent(tEvent, "Act_1_GetCaught.DriveToPark", nil)
  else
  end
  Act_1_GetCaught.DoppEntryCin(Act_1_GetCaught)
end

function Act_1_GetCaught.FadeBackIn()
  local tEvent = {EventType = "TimerEvent", Time = 1}
  Act_1_GetCaught:RegisterEvent(Util.CreateEvent(tEvent, "Act_1_GetCaught.FadeBackInAfterTimer", Act_1_GetCaught))
end

function Act_1_GetCaught.FadeBackInAfterTimer()
  if Act_1_GetCaught.dopp_start_playing == false then
    Convo.AddConvo("A1M3_ParkCar_Start", 10, {})
  end
end

function Act_1_GetCaught.DriveToPark()
  local hVehicle = Actor.GetVehicle(hSab)
  Vehicle.SetForceAIController(hVehicle, true)
end

function Act_1_GetCaught.TeleportToFinalLocation()
  local hCarLocator = Handle("Missions\\act_1\\getcaught\\main\\LOC_ParkHere")
  local hSabLocator = Handle("Missions\\act_1\\getcaught\\main\\LOC_SabAfterCin")
  local hJulesLocator = Handle("Missions\\act_1\\getcaught\\main\\LOC_JulesAfterCin")
  local x, y, z, rotate
  if Actor.IsInVehicle(hSab) then
    x, y, z = Object.GetPosition(hCarLocator)
    rotate = Object.GetAngle(hCarLocator)
    local hVehicle = Actor.GetVehicle(hSab)
    Object.Teleport(hVehicle, x, y, z, rotate)
    Vehicle.SetForceAIController(hVehicle, false)
    x, y, z = Object.GetPosition(hSabLocator)
    rotate = Object.GetAngle(hSabLocator)
    Object.Teleport(hSab, x, y, z, rotate)
    Object.Teleport(hSab, x, y, z, rotate)
    x, y, z = Object.GetPosition(hJulesLocator)
    rotate = Object.GetAngle(hJulesLocator)
    Object.Teleport(Act_1_GetCaught.hJules, x, y, z, rotate)
    Object.Teleport(Act_1_GetCaught.hJules, x, y, z, rotate)
  end
end

function Act_1_GetCaught.TeleportCinematicHackOne()
  local hCarLocator = Handle("Missions\\act_1\\getcaught\\main\\LOC_ParkHere")
  local hSabLocator = Handle("Missions\\act_1\\getcaught\\main\\LOC_SabAfterCin")
  local hJulesLocator = Handle("Missions\\act_1\\getcaught\\main\\LOC_JulesAfterCin")
  local x, y, z, rotate
  Vehicle.HardSetLinVel(Act_1_GetCaught.hJulesCar, 0)
  x, y, z = Object.GetPosition(hJulesLocator)
  rotate = Object.GetAngle(hJulesLocator)
  if Actor.IsInVehicle(hSab) then
    Cin.PlayCinematic("CIN_A1M3_TeleportSeanJulesCar")
  else
    Actor.UnboardVehicle(hSab)
    Actor.UnboardVehicle(Act_1_GetCaught.hJules)
    x, y, z = Object.GetPosition(hSabLocator)
    rotate = Object.GetAngle(hSabLocator)
    Object.Teleport(hSab, x, y, z, rotate)
    Object.Teleport(hSab, x, y, z, rotate)
  end
end

function Act_1_GetCaught.UnBoardHack()
  Actor.UnboardVehicle(hSab)
  Actor.UnboardVehicle(Act_1_GetCaught.hJules)
end

function Act_1_GetCaught.UnBoardTeleportHack()
  local hCarLocator = Handle("Missions\\act_1\\getcaught\\main\\LOC_ParkHere")
  local hSabLocator = Handle("Missions\\act_1\\getcaught\\main\\LOC_SabAfterCin")
  local hJulesLocator = Handle("Missions\\act_1\\getcaught\\main\\LOC_JulesAfterCin")
  local x, y, z, rotate
  x, y, z = Object.GetPosition(hSabLocator)
  rotate = Object.GetAngle(hSabLocator)
  Object.Teleport(hSab, x, y, z, rotate)
  Object.Teleport(hSab, x, y, z, rotate)
  x, y, z = Object.GetPosition(hJulesLocator)
  rotate = Object.GetAngle(hJulesLocator)
  Object.Teleport(Act_1_GetCaught.hJules, x, y, z, rotate)
  Object.Teleport(Act_1_GetCaught.hJules, x, y, z, rotate)
end

function Act_1_GetCaught:HaysConvo_PickUpJules()
  local tEvent = {EventType = "TimerEvent", Time = 0.75}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_1_GetCaught.HackSmallDelayTalk", self))
end

function Act_1_GetCaught:HackSmallDelayTalk()
  Convo.AddConvo("117_InG_TailD-Start", 10, {})
  local tEvent = {EventType = "TimerEvent", Time = 3}
  Util.CreateEvent(tEvent, "Act_1_GetCaught.SkylarMoveNow", self)
end

function Act_1_GetCaught:SkylarMoveNow()
  Nav.MoveToObject(self.hSkylar, Handle("Missions\\act_1\\getcaught\\main\\LOC_SkyGoesHere"), 0)
end

function Act_1_GetCaught:SeeIfConvoMakesSense_JulesGetIn()
  if Cin.IsHumanInConversation(self.hJules) == false and Cin.IsHumanInConversation(hSab) == false and Actor.IsInVehicle(self.hJules) == false then
    Convo.AddConvo("A1M3_Jules_GetIn", 10, {})
  end
end

function Act_1_GetCaught:EsclationCleanUp()
  if self.tEscalationEvents then
    for i, e in ipairs(self.tEscalationEvents) do
      if e then
        Util.KillEvent(e)
      end
    end
  end
  self.tEscalationEvents = nil
end

function Act_1_GetCaught:BlipCarFunction()
end

function Act_1_GetCaught:UnBlipCarFunction()
end

function Act_1_GetCaught:StartScene()
  local tVeroniqueSequence = {
    {
      "TURNTOFACE",
      {
        self.hJules
      }
    },
    {
      "PLAYANIMATION",
      {
        "conv_Sean_concern"
      }
    }
  }
  ScriptSequence.Run(self.hVeronique, tVeroniqueSequence)
end

function Act_1_GetCaught:BlipDierker()
  HUD.SetObjectiveMarker(self.hDierkersCar, cMMI_Objective, cOM_Objective, true, true, true)
end

function Act_1_GetCaught:ParkCar()
end

function Act_1_GetCaught:UnBlipParkSpot()
  HUD.RemoveObjectiveMarker(self.hParkSpot)
  HUD.RemoveObjective(self.hHUDObjective)
  Util.UnregisterLuaUpdate("Act_1_GetCaught.EvaluateParanoia")
  HUD.ClearGPSTarget()
end

function Act_1_GetCaught:DoppEntryCin()
  Util.UnregisterLuaUpdate("Act_1_GetCaught.EvaluateParanoia")
  Util.KillEvent("EVT_WeaponFire")
  if self.hHUDObjective then
    HUD.RemoveObjective(self.hHUDObjective)
  end
  if Suspicion.GetEscalation() < 1 and Suspicion.IsSomeoneHostileOrHunting() == false and self.tSaveInfo.ItHasFailed == false then
    self:CreateTask({
      sName = "Task_DoppCutscene",
      sTaskType = "SabTaskObjectiveInteract",
      sTaskSubType = "cinematic",
      sCinFile = "CIN_A1M3_DoppIntro",
      tSMEDNodes = {},
      tOnActivate = {
        {
          self.JulesPullOver,
          {self}
        },
        {
          self.KillTaskByName,
          {
            self,
            "TASK_DriveEscalator"
          }
        },
        {
          self.SetupJulesAfterPark,
          {self}
        },
        {
          self.FadeBackIn,
          {}
        }
      },
      tOnComplete = {
        {
          self.DoppCheckpoint,
          {self}
        },
        {
          Actor.UnboardVehicle,
          {hSab}
        }
      }
    })
  end
end

function Act_1_GetCaught:SetupJulesAfterPark()
end

function Act_1_GetCaught:JulesAfterPark()
  Object.Teleport(self.hJules, 2949.7632, 116.97183, -3155.2998, -21.248018)
end

function Act_1_GetCaught:CinTeleport()
  self = Act_1_GetCaught
end

function Act_1_GetCaught:JulesRagdoll()
  self = Act_1_GetCaught
  Actor.Ragdoll(self.hJules)
end

function Act_1_GetCaught:WaitToUnboardVehs()
  local eUnboardTime = Util.CreateEvent({
    EventType = "TimerEvent",
    EventName = "UnboardTimer",
    Time = 2
  }, "Act_1_GetCaught.WaitToTport", self)
  self:RegisterEvent(eUnboardTime)
end

function Act_1_GetCaught:WaitToTport()
  Object.Teleport(self.hPlayerCar, 2947.247, 117.26027, -3155.84, 169.7769)
end

function Act_1_GetCaught:Tport()
end

function Act_1_GetCaught:SetupDoppActivity()
end

function Act_1_GetCaught:DierkerStart()
  Vehicle.SetSuperHeavy(self.hDierkersCar, true)
  Vehicle.SetForceNeverFlip(self.hDierkersCar, true)
  Nav.BoardVehicle(self.hDierker, self.hDierkersCar, Driver, true, "Act_1_GetCaught.DierkerDrives", self)
  self:PullOverClear(self)
  self:JulesIsDead(self)
  self:DierkerIsDead(self)
end

function Act_1_GetCaught:JulesIsDead()
  local tLocProxEvent = {
    EventType = "DeathEvent",
    ObjectHandle = self.hJules
  }
  if self.eJulesDead then
    Util.KillEvent(self.eJulesDead)
  end
end

function Act_1_GetCaught:JulesFail()
  self.Restart(self, "Char_Death.RS_Jules")
  Cin.PlayConversation("A1M3_JulesDied")
end

function Act_1_GetCaught:DartWarnFail(tArgs)
  local hAttacker = tArgs[1]
  local damageFlags = tArgs[2]
  local damageAmount = tArgs[3]
  if hAttacker == hSab or hAttacker == self.hPlayerCar then
    self.tSaveInfo.ItHasFailed = true
    self.Restart(self, "A1M3_Fail.BumpFail")
    self.IncreaseParanoia(self, 100)
    Convo.AddConvo("A1M3_Tail_DamageDierker_Fail", 10, {})
  end
end

function Act_1_GetCaught:ResetDartDamage()
  local tLocDamEvent = {
    EventType = "DamageEvent",
    ObjectHandle = self.hDierkersCar,
    MinDamage = 0.003
  }
  local eDartDamage = Util.CreateEvent(tLocDamEvent, "Act_1_GetCaught.DartWarnFail", self)
  self:RegisterEvent(eDartDamage)
end

function Act_1_GetCaught:DierkerIsDead()
  local tLocProxEvent = {
    EventType = "DeathEvent",
    ObjectHandle = self.hDierker
  }
  Actor.SetMissionCriticalNPC(self.hDierker, true)
  self.DierkerDeathDetect = Util.CreateEvent(tLocProxEvent, "Act_1_GetCaught.DierkerFail", self)
  self:RegisterEvent(self.DierkerDeathDetect)
end

function Act_1_GetCaught:DierkerFail()
  Convo.AddConvo("A1M3_DierkerDied", 10, {})
  self.tSaveInfo.ItHasFailed = true
  self.Restart(self, "Char_Death.NZ_Dierker")
end

function Act_1_GetCaught:DelayedAnimationForDierker()
  Actor.OverrideCombatAI(self.hDierker, true)
  Combat.SetIdleScripted(self.hDierker, true)
  Actor.PlayAnimation(self.hDierker, "conv_Sean_proud", -1, true, Actor.GetFacingDir(self.hDierker), "Act_1_GetCaught.DelayedAnimationForDierker2", self, {}, true)
end

function Act_1_GetCaught:DelayedAnimationForDierker2()
  Actor.PlayAnimation(self.hDierker, "civ_M_priest_blessing", -1, true, Actor.GetFacingDir(self.hDierker), "Act_1_GetCaught.DelayedAnimationForDierker3", self, {}, true)
end

function Act_1_GetCaught:DelayedAnimationForDierker3()
  Actor.PlayAnimation(self.hDierker, "conv_Sean_thinking", -1, true)
end

function Act_1_GetCaught:DierkerAtGroupies()
  local tEvent = {EventType = "TimerEvent", Time = 3}
  Util.CreateEvent(tEvent, "Act_1_GetCaught.DelayedAnimationForDierker", self)
  self.DierkerGoTest(self)
end

function Act_1_GetCaught:DierkerGoTest()
  if self.tInfo.bPlayerReady == false then
    self:RegisterEvent(Util.CreateEvent({
      EventType = "TimerEvent",
      EventName = "DStartTimer",
      Time = 2
    }, "Act_1_GetCaught.DierkerGoTest", self))
  else
    self.DierkerContinue(self)
  end
end

function Act_1_GetCaught:DierkerGo()
  if self.hDierkerCloseBeginingEvent ~= nil then
    Util.KillEvent(self.hDierkerCloseBeginingEvent)
  end
  HUD.ClearGPSTarget()
  self.tInfo.bPlayerReady = true
  self.WaveGirls(self)
  if Handle(self.PATH .. "startprops\\Spore_CG_Groupie2") then
    EVENT_PlayerToActorProximity("Act_1_GetCaught.KillAllGroupieSequence", self, self.PATH .. "startprops\\Spore_CG_Groupie2", 10, nil, false)
  end
  if Actor.IsInVehicle(hSab) == false and self.nConvoFlag1 == 0 then
    Convo.AddConvo("A1M3_Jules_Hurry", 10, {})
  end
  self.nConvoFlag1 = 1
  local tEvent = {EventType = "TimerEvent", Time = 1}
  Util.CreateEvent(tEvent, "Act_1_GetCaught.GPS_SET", self)
end

function Act_1_GetCaught:GPS_SET()
end

function Act_1_GetCaught:DierkerDrives()
  Nav.SetScriptedPath(self.hDierkersCar, self.PATH .. "main\\PATH_DierkerExitRace", true, "Act_1_GetCaught.DierkerAtGroupies", self, {})
  Nav.SetScriptedPathSpeed(self.hDierkersCar, 20)
end

function Act_1_GetCaught:SetupVisionConeForDierker()
  if self.hDierkerSensory then
    Util.KillEvent(self.hDierkerSensory)
    self.hDierkerSensory = nil
  end
  local tEvent = {EventType = "TimerEvent", Time = 1}
  self.hDierkerSensory = Util.CreateEvent(tEvent, "Act_1_GetCaught.KURTDIERKERsawSean", self)
  self:RegisterEvent(self.hDierkerSensory)
end

function Act_1_GetCaught:DierkerContinue()
  self.bDContinued = true
  Nav.SetScriptedPath(self.hDierker, "Missions\\act_1\\getcaught\\pathblocker\\PATH_OneShot(1)", true)
  Nav.SetScriptedPathSpeed(self.hDierker, 20)
  local eDelayFailTimer = Util.CreateEvent({
    EventType = "TimerEvent",
    EventName = "DelayFailTimer",
    Time = 4
  }, "Act_1_GetCaught.FailInitDelay", self)
  self:RegisterEvent(eDelayFailTimer)
  self.TASK_DriveEscalator(self)
end

function Act_1_GetCaught:DExitRace1()
  Nav.SetScriptedPath(self.hDierker, self.PATH .. "main\\PATH_DierkerExitRace1", true, "Act_1_GetCaught.DExitRace2", self, {})
  Nav.SetScriptedPathSpeed(self.hDierker, 60)
  local eDelayFailTimer = Util.CreateEvent({
    EventType = "TimerEvent",
    EventName = "DelayFailTimer",
    Time = 4
  }, "Act_1_GetCaught.FailInitDelay", self)
  self:RegisterEvent(eDelayFailTimer)
end

function Act_1_GetCaught:FailInitDelay()
  self.SetupParanoia(self)
  self.SetFar(self)
  self.FarFailDetect(self)
end

function Act_1_GetCaught:SetupParanoia()
  self.nMaxParnoia = 100
  self.nCurrentParanoia = 0
  self.bMusicChaseSet = false
  self.nSecondsPassedWithoutConvo = 0
  self.hHUDObjective = HUD.AddObjective(eOT_HEART, "P1FP_Traitor_Text.ProximityMeter", 2)
  HUD.SetupProgressBar(self.hHUDObjective, 0, self.nMaxParnoia, 0)
  HUD.SetProgressBarValue(self.hHUDObjective, self.nCurrentParanoia)
  HUD.AddProgressBarCallback(self.hHUDObjective, "Act_1_GetCaught.ParanoiaMaxed", self.nMaxParnoia, self, {})
  HUD.KeepObjectivesVisible(true)
  Util.RegisterLuaUpdate("Act_1_GetCaught.EvaluateParanoia", self)
end

function Act_1_GetCaught:ParanoiaMaxed()
  self.CleanUpHudElements(self)
  self.Restart(self, "A1M3_Fail.AgitateDierker")
end

function Act_1_GetCaught:CleanUpHudElements()
  if self.hHUDObjective then
    HUD.RemoveObjective(self.hHUDObjective)
  end
  Util.UnregisterLuaUpdate("Act_1_GetCaught.EvaluateParanoia")
end

function Act_1_GetCaught:EvaluateParanoia(tData)
  local dt = tData[1]
  self.nSecondsPassedWithoutConvo = self.nSecondsPassedWithoutConvo + dt
  if 0.25 <= dt then
    return
  elseif dt == 0 then
    dt = 0.03125
  end
  local near_lv1 = {
    35,
    6 * dt
  }
  local near_lv2 = {
    25,
    12 * dt
  }
  local near_lv3 = {
    20,
    20 * dt
  }
  local near_lv4 = {
    10,
    25 * dt
  }
  local far_lv1 = {
    35,
    3 * dt
  }
  local far_lv2 = {
    45,
    6 * dt
  }
  local far_lv3 = {
    50,
    10 * dt
  }
  local nDistance = 0
  if self.hDierker and Util.IsObjectHandleValid(self.hDierker) then
    nDistance = Object.GetDistance(self.hDierker, hSab)
  end
  if nDistance <= 20 or self.nCurrentParanoia >= 75 then
    if self.bMusicChaseSet == false then
      self.bMusicChaseSet = true
    end
    if self.nSecondsPassedWithoutConvo > 6 and Cin.IsHumanInConversation(hSab) == false then
      Convo.AddConvo("A1M3_Tail_TooClose_Warning", 10, {DontPlayIfInConvo = true})
      self.nSecondsPassedWithoutConvo = 0
    end
  end
  if nDistance <= near_lv4[1] then
    self.IncreaseParanoia(self, near_lv4[2])
  elseif nDistance <= near_lv3[1] then
    self.IncreaseParanoia(self, near_lv3[2])
  elseif nDistance <= near_lv2[1] then
    self.IncreaseParanoia(self, near_lv2[2])
  elseif nDistance <= near_lv1[1] then
    self.IncreaseParanoia(self, near_lv1[2] * 2)
  end
  if Sensory.CanSee(self.hDierker, Handle("Missions\\act_1\\getcaught\\main\\VittoreCar")) == true then
    self.IncreaseParanoia(self, near_lv4[2])
  elseif nDistance >= far_lv3[1] then
    self.DecreaseParanoia(self, far_lv3[2])
  elseif nDistance >= far_lv2[1] then
    self.DecreaseParanoia(self, far_lv2[2])
  elseif nDistance >= far_lv1[1] then
    self.DecreaseParanoia(self, far_lv1[2])
  elseif nDistance > near_lv1[1] then
    self.DecreaseParanoia(self, dt)
  end
end

function Act_1_GetCaught:IncreaseParanoia(nAmount)
  if self.nCurrentParanoia then
    self.nCurrentParanoia = self.nCurrentParanoia + nAmount
    if self.nCurrentParanoia > 100 then
      self.nCurrentParanoia = 100
    end
    HUD.SetProgressBarValue(self.hHUDObjective, self.nCurrentParanoia)
    dprint(self, "Increasing by: " .. nAmount)
  end
end

function Act_1_GetCaught:DecreaseParanoia(nAmount)
  self.nCurrentParanoia = self.nCurrentParanoia - nAmount
  if self.nCurrentParanoia < 0 then
    self.nCurrentParanoia = 0
  end
  HUD.SetProgressBarValue(self.hHUDObjective, self.nCurrentParanoia)
  dprint(self, "Decreasing by: " .. nAmount)
end

function Act_1_GetCaught:SetNearWarn()
  local tLocProxEvent = {
    EventType = "ProximityEvent",
    EventName = "NearWarnEvent",
    ObjectA = self.hDierker,
    ObjectB = Handle("Saboteur"),
    Proximity = 15,
    Negate = false
  }
  if self.eNearWarn then
    Util.KillEvent(self.eNearWarn)
  end
  self.eNearWarn = Util.CreateEvent(tLocProxEvent, "Act_1_GetCaught.NearWarnSetup", self)
  self:RegisterEvent(self.eNearWarn)
end

function Act_1_GetCaught:NearWarnSetup()
  if Cin.IsHumanInConversation(hSab) == false and Sensory.CanSee(self.hDierker, hSab) == false then
    Convo.AddConvo("A1M3_Tail_TooClose_Warning", 10, {DontPlayIfInConvo = true})
  end
  local nProx = Object.GetDistance(hSab, self.hDierkersCar)
  if nProx < 15 then
  else
    local eNearTimer = Util.CreateEvent({EventType = "TimerEvent", Time = 6}, "Act_1_GetCaught.TestNearFail", self)
    self:RegisterEvent(eNearTimer)
  end
end

function Act_1_GetCaught:TestNearFail()
  local nProx = Object.GetDistance(hSab, self.hDierker)
  if nProx <= 15 then
    if self.tInfo.nDierkerAlert == 0 then
      self.tInfo.nDierkerAlert = 1
    elseif Cin.IsHumanInConversation(hSab) == false and Sensory.CanSee(self.hDierker, hSab) == false then
      Convo.AddConvo("A1M3_Tail_TooClose_Panic", 10, {})
    end
  else
    self.SetNearWarn(self)
  end
end

function Act_1_GetCaught:SetNear()
  local tLocProxEvent = {
    EventType = "ProximityEvent",
    EventName = "SetNearEvent",
    ObjectA = self.hDierker,
    ObjectB = Handle("Saboteur"),
    Proximity = 15,
    Negate = false
  }
  if self.eNearFail then
    Util.KillEvent(self.eNearFail)
  end
  self.eNearFail = Util.CreateEvent(tLocProxEvent, "Act_1_GetCaught.NearFailSetup", self)
  self:RegisterEvent(self.eNearFail)
end

function Act_1_GetCaught:SetFar()
  self.tFarFailWarn = {
    EventType = "ProximityEvent",
    EventName = "FarFailWarn",
    ObjectA = self.hDierker,
    ObjectB = Handle("Saboteur"),
    Proximity = 70,
    Negate = true
  }
  if self.eFarWarn then
    Util.KillEvent(self.eFarWarn)
  end
  self.eFarWarn = Util.CreateEvent(self.tFarFailWarn, "Act_1_GetCaught.FarFailWarning", self)
  self:RegisterEvent(self.eFarWarn)
end

function Act_1_GetCaught:FarFailWarning()
  if Actor.IsInVehicle(hSab) and Cin.IsHumanInConversation(hSab) == false then
    Convo.AddConvo("A1M3_Tail_TooFar_Warning", 10, {})
  end
  local eFarWarnTimer = Util.CreateEvent({
    EventType = "TimerEvent",
    EventName = "FarWarnTimer",
    Time = 6
  }, "Act_1_GetCaught.SetFar", self)
  self:RegisterEvent(eFarWarnTimer)
end

function Act_1_GetCaught:FarFailDetect()
  self.tFarFailEvent = {
    EventType = "ProximityEvent",
    EventName = "FarFailEvent",
    ObjectA = self.hDierker,
    ObjectB = Handle("Saboteur"),
    Proximity = 130,
    Negate = true
  }
  local eFarFail = Util.CreateEvent(self.tFarFailEvent, "Act_1_GetCaught.FarFail", self)
  self:RegisterEvent(eFarFail)
end

function Act_1_GetCaught:FarFail()
  self.Restart(self, "A1M3_Fail.DierkerFar")
  Convo.AddConvo("A1M3_Tail_TooFar_Fail", 10, {})
end

function Act_1_GetCaught:NearFailSetup()
  if self.tInfo.nDierkerAlert == 0 then
    self.tInfo.nDierkerAlert = 1
  elseif Cin.IsHumanInConversation(hSab) == false and Sensory.CanSee(self.hDierker, hSab) == false then
    Convo.AddConvo("A1M3_Tail_TooClose_Panic", 10, {})
  end
end

function Act_1_GetCaught:NearFail()
  if Cin.IsHumanInConversation(hSab) == false and Sensory.CanSee(self.hDierker, hSab) == false then
    Convo.AddConvo("A1M3_Tail_TooClose_Panic", 10, {})
  end
end

function Act_1_GetCaught:DExitRace2()
  Nav.SetScriptedPath(self.hDierker, self.PATH .. "main\\PATH_DierkerExitRace2", false, "Act_1_GetCaught.DExitRace5", self, {})
  Nav.SetScriptedPathSpeed(self.hDierkersCar, 70)
end

function Act_1_GetCaught:DExitRace5()
  Nav.SetScriptedPath(self.hDierker, self.PATH .. "main\\PATH_DierkerExitRace5", false, "Act_1_GetCaught.DExitRace8", self, {})
  Nav.SetScriptedPathSpeed(self.hDierkersCar, 70)
end

function Act_1_GetCaught:DExitRace7()
  Nav.SetScriptedPath(self.hDierker, self.PATH .. "main\\PATH_DierkerExitRace7", false, "Act_1_GetCaught.DExitRace8", self, {})
  Nav.SetScriptedPathSpeed(self.hDierkersCar, 70)
end

function Act_1_GetCaught:DExitRace8()
  Nav.SetScriptedPath(self.hDierker, self.PATH .. "main\\PATH_DierkerExitRace8", false, "Act_1_GetCaught.PATH_toFactory", self, {})
  Nav.SetScriptedPathSpeed(self.hDierkersCar, 80)
end

function Act_1_GetCaught:PATH_toFactory()
  Nav.SetScriptedPath(self.hDierker, self.PATH .. "main\\PATH_toFactory", false)
  Nav.SetScriptedPathSpeed(self.hDierkersCar, 80)
end

function Act_1_GetCaught:DierkerNearGate()
  Nav.SetScriptedPathSpeed(self.hDierker, 35)
  local tLocProxEvent = {
    EventType = "ProximityEvent",
    ObjectA = self.hDierker,
    ObjectB = Handle(self.PATH .. "main\\LOC_DatGate"),
    Proximity = 16,
    Negate = false
  }
  local eDatGate = Util.CreateEvent(tLocProxEvent, "Act_1_GetCaught.DierkerAtGateWait", self)
  self:RegisterEvent(eDatGate)
end

function Act_1_GetCaught:DierkerAtGateWait()
  Util.CreateEvent({EventType = "TimerEvent", Time = 2}, "Act_1_GetCaught.DierkerAtGate", self)
end

function Act_1_GetCaught:DierkerAtGate()
  local tNaziGuardSequence = {
    {
      "PLAYANIMATION",
      {
        "nazi_halt_1"
      }
    },
    {
      "DELAY",
      {1}
    },
    {
      "WALKTOOBJECT",
      {
        Handle("Missions\\act_1\\getcaught\\main\\LOC_DatGate"),
        1
      }
    },
    {
      "DELAY",
      {2}
    },
    {
      "TURNTOFACE",
      {
        self.hDierkersCar
      }
    },
    {
      "PLAYANIMATION",
      {
        "nazi_wave_vehicle_1"
      }
    },
    {
      "DELAY",
      {1}
    },
    {
      "WALKTOOBJECT",
      {
        Handle("Missions\\act_1\\getcaught\\main\\LOC_GuardLook"),
        1
      }
    }
  }
  if Handle("Missions\\act_1\\getcaught\\doppnazis\\WM_Grunt_RF_GateKeeper") then
    ScriptSequence.Run(Handle("Missions\\act_1\\getcaught\\doppnazis\\WM_Grunt_RF_GateKeeper"), tNaziGuardSequence)
  end
  Nav.StopMoving(self.hDierker)
  local eDEntersTimer = Util.CreateEvent({EventType = "TimerEvent", Time = 3}, "Act_1_GetCaught.DierkerEntersGate", self)
  self:RegisterEvent(eDEntersTimer)
end

function Act_1_GetCaught:DierkerEntersGate()
  Object.ForceOpen(Handle("CountrySide\\alsace\\doppelsieg\\exteriorarea\\props\\DPAdmin_Gate_Ent(2)\\DPAdmin_Gate_Ent_GateB"))
  Object.ForceOpen(Handle("CountrySide\\alsace\\doppelsieg\\exteriorarea\\props\\DPAdmin_Gate_Ent(2)\\DPAdmin_Gate_Ent_GateA"))
  Nav.SetScriptedPath(self.hDierker, self.PATH .. "main\\PATH_thruGate", true, "Act_1_GetCaught.DExitsCar", self)
  Nav.SetScriptedPathSpeed(self.hDierker, 10)
  local eDClosesGate = Util.CreateEvent({EventType = "TimerEvent", Time = 10}, "Act_1_GetCaught.CloseGate", self)
  self:RegisterEvent(eDClosesGate)
end

function Act_1_GetCaught:CloseGate()
  Object.ForceClose(Handle("CountrySide\\alsace\\doppelsieg\\exteriorarea\\props\\DPAdmin_Gate_Ent(2)\\DPAdmin_Gate_Ent_GateB"))
  Object.ForceClose(Handle("CountrySide\\alsace\\doppelsieg\\exteriorarea\\props\\DPAdmin_Gate_Ent(2)\\DPAdmin_Gate_Ent_GateA"))
end

function Act_1_GetCaught:DExitsCar()
  Actor.UnboardVehicle(self.hDierker)
  local tEvent = {EventType = "TimerEvent", Time = 1.5}
  Util.CreateEvent(tEvent, "Act_1_GetCaught.FaceSean", self)
end

function Act_1_GetCaught:FaceSean()
  Actor.SetFacingDir(self.hDierker, -139.12)
end

function Act_1_GetCaught:DespawnD()
end

function Act_1_GetCaught:NearMotorworks()
  Convo.AddConvo("117_InG_TailD-NearMotorworks", 10, {})
end

function Act_1_GetCaught:FallBack()
  Util.KillEvent("FarFailEvent")
  Util.KillEvent("FarFailWarn")
end

function Act_1_GetCaught:PullOver()
  local tLocProxEvent = {
    EventType = "ProximityEvent",
    ObjectA = Handle("Missions\\act_1\\getcaught\\main\\LOC_PullOver"),
    ObjectB = Handle("Saboteur"),
    Proximity = 10,
    Negate = false
  }
  local ePullOver = Util.CreateEvent(tLocProxEvent, "Act_1_GetCaught.JulesPullOver", self)
  self:RegisterEvent(ePullOver)
end

function Act_1_GetCaught:PullOverClear()
  local tLocProxEvent = {
    EventType = "ProximityEvent",
    ObjectA = Handle("Missions\\act_1\\getcaught\\main\\LOC_ParkHere"),
    ObjectB = Handle("Saboteur"),
    Proximity = 10,
    Negate = false
  }
  local ePullOverClear = Util.CreateEvent(tLocProxEvent, "Act_1_GetCaught.ParkingDone", self)
  self:RegisterEvent(ePullOverClear)
end

function Act_1_GetCaught:StopVehicleDuringCinematic()
  if Actor.IsInVehicle(hSab) then
    local hVehicle = Actor.GetVehicle(hSab)
    Vehicle.HardSetLinVel(hVehicle, 0)
    Vehicle.SetForceAIController(hVehicle, true)
  end
end

function Act_1_GetCaught:JulesPullOver()
  if self.eNearWarn then
    Util.KillEvent(self.eNearWarn)
  end
  if self.eNearFail then
    Util.KillEvent(self.eNearFail)
  end
  Util.KillEvent(self.eFarWarn)
  Util.KillEvent("SetNearEvent")
  Util.KillEvent("FarFailWarn")
  Util.KillEvent("FarFailEvent")
  Util.KillEvent("NearWarnEvent")
  Util.KillEvent("NearFailEvent")
  Util.KillEvent("FarWarnTimer")
  Util.KillEvent("NearWarnTimer")
  Util.KillEvent("DierkerStreamEvent")
end

function Act_1_GetCaught:ParkingDone()
  self:KillTaskByName("Act_1_GetCaught.OPTIONAL_ParkHere")
end

function Act_1_GetCaught:OPTIONAL_ParkHere()
  self:CreateTask({
    sName = "Act_1_GetCaught.OPTIONAL_ParkHere",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "DELIVER",
    Proximity = 5,
    tDestProximityObj = {
      "Missions\\act_1\\getcaught\\main\\LOC_ParkHere"
    },
    tDeliverObjs = {hSab},
    bOptional = true,
    tOnComplete = {}
  })
end

function Act_1_GetCaught:DoppCheckpoint()
  Act_1_GetCaught.DoppCheckpointReg(self)
end

function Act_1_GetCaught:DoppCheckpointReg()
  self.nFailedNumAtCheckpoint2 = 0
  self:RegisterCheckpoint("Act_1_GetCaught.Checkpoint2")
end

function Act_1_GetCaught:Checkpoint2()
  Suspicion.ResetEscalation()
  Actor.SetCannotGetOutOfSeat(hSab, false)
  Combat.SetGrabbable(self.hJules, false)
  if self.hCarDeathEventVittore then
    Util.KillEvent(self.hCarDeathEventVittore)
    self.hCarDeathEventVittore = nil
  end
  Convo.ResetForFail()
  if not self:IsMissionTaskActive("TASK_DoppEscalator") then
    self.TASK_DoppEscalator(self)
  end
  HUD.ClearGPSTarget()
  HUD.RemoveObjectiveMarker(self.hDierker)
  if self.hJulesStreamOut then
    Util.KillEvent(self.hJulesStreamOut)
  end
  self.hJulesStreamOut = Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      self.PATH .. "main\\Spore_RS_Jules"
    },
    WaitForStreamOut = true
  }, "Act_1_GetCaught.Restart", self, {
    "GenericFail_Text.ABANDON_Jules"
  })
  self:RegisterEvent(self.hJulesStreamOut)
  if self.nFailedNumAtCheckpoint2 > 0 then
    if Handle("Missions\\act_1\\getcaught\\silverdart_start\\VH_CV_CR_SilverDart_01") ~= nil then
      self:UnloadTaskNodes("TASK_FatLoad_Dierker_car", true)
    end
    Object.ForceClose(Handle("CountrySide\\alsace\\doppelsieg\\exteriorarea\\props\\DPAdmin_Gate_Ent(2)\\DPAdmin_Gate_Ent_GateB"))
    Object.ForceClose(Handle("CountrySide\\alsace\\doppelsieg\\exteriorarea\\props\\DPAdmin_Gate_Ent(2)\\DPAdmin_Gate_Ent_GateA"))
  end
  self.JulesIsDead(self)
  self.nFailedNumAtCheckpoint2 = 1
  if not self.WeaponEvent then
    local tWeaponEvent = {
      EventType = "InventoryCheckEvent",
      HumanHandle = hSab,
      ItemInHand = true,
      Item = "",
      IsBlueprint = true,
      WeaponOnly = true
    }
    self.WeaponEvent = Util.CreateEvent(tWeaponEvent, "Act_1_GetCaught.PlayerWeaponDrawnDopp", self)
    self:RegisterEvent(self.WeaponEvent)
  end
  Sound.SetMusicLocale("A1M3_GetCaught")
  Sound.SetMusicLocale("m_A1M3_GetCaught", "parkCar")
  local tRATut = Trigger.WaitFor(Handle("Missions\\act_1\\getcaught\\main\\PT_RATut"), hSab, "Act_1_GetCaught.FireRATut", self, {-1})
  self:RegisterTriggerEvent(tRATut, "Missions\\act_1\\getcaught\\main\\PT_RATut")
  local tConvostuff = Trigger.WaitFor(Handle("Missions\\act_1\\getcaught\\main\\PT_RATut"), self.hJules, "Act_1_GetCaught.FireBoostConvo", self, {-1})
  self:RegisterTriggerEvent(tConvostuff, "Missions\\act_1\\getcaught\\main\\PT_RATut")
  self.Task_ToTheWall(self)
  self.OPTIONAL_BlipWall(self)
end

function Act_1_GetCaught:DierkerCarDeathFail()
  if self.hCarDeathEvent then
    Util.KillEvent(self.hCarDeathEvent)
  end
  local tCarDeathFail = {
    EventType = "DeathEvent",
    ObjectHandle = Handle("Missions\\act_1\\getcaught\\silverdart_dopp\\VH_CV_CR_SilverDart_01")
  }
  self.hCarDeathEvent = Util.CreateEvent(tCarDeathFail, "Act_1_GetCaught.CarDestroyedFail", self)
  self:RegisterEvent(self.hCarDeathEvent)
end

function Act_1_GetCaught:JulesAbandonEndFail()
  self.Restart(self, "GenericFail_Text.ABANDON_Jules")
end

function Act_1_GetCaught:CarDestroyedFail()
  if self.tInfo.bWin ~= 2 then
    self.Restart(self, "A1M3_Fail.SilverDartDestroyed")
  end
end

function Act_1_GetCaught:FireRATut()
  Saboteur.ShowToolTip("TutorialTip_Text.Restricted_Areas", 7, nil, true)
  HUD.FlashRestrictedAreas()
end

function Act_1_GetCaught:FireBoostConvo()
  Convo.AddConvo("A1M3_NearDopp_NearClimbSpot", 10, {})
  local tEvent = {EventType = "TimerEvent", Time = 10}
  self.hDoopBoostPlay = Util.CreateEvent(tEvent, "Act_1_GetCaught.PlayDoopBoost", self)
  self:RegisterEvent(self.hDoopBoostPlay)
end

function Act_1_GetCaught:Task_ToTheWall()
  Saboteur.ShowToolTip("TutorialTip_Text.Sprinting", 7, nil, true)
  if self.hChangeDierkerSpeedEvent then
    Util.KillEvent(self.hChangeDierkerSpeedEvent)
  end
  self:CreateTask({
    sName = "Task_ToTheWall",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "A1M3_Text.Task_ToTheWall",
    tLocators = {
      self.PATH .. "main\\Teleport_J_From"
    },
    tDestRegion = self.PATH .. "main\\PT_JulesOverWall",
    tDeliverObjs = {
      self.hJules,
      hSab
    },
    bNoWorldBlip = true,
    bNoHUDBlip = true,
    bNoGroundBlip = true,
    tOnActivate = {
      {
        HUD.SetObjectiveMarker,
        {
          Handle(self.PATH .. "main\\Teleport_J_From"),
          cMMI_Objective,
          cOM_Objective,
          true,
          true,
          false
        }
      },
      {
        self.SetupWaitForJ,
        {self}
      },
      {
        self.CanWePlayConvoHere1,
        {self}
      },
      {
        Util.KillEvent,
        {
          self.DCarjackEvent
        }
      },
      {
        Util.KillEvent,
        {
          self.DierkerDeathDetect
        }
      },
      {
        self.GoJules,
        {self}
      },
      {
        HUD.ClearGPSTarget,
        {}
      }
    },
    tOnComplete = {
      {
        self.Task_BoostJules,
        {self}
      },
      {
        HUD.RemoveObjectiveMarker,
        {
          Handle("Missions\\act_1\\getcaught\\main\\LOC_HackBlipAtWall")
        }
      }
    }
  })
  HUD.SetObjectiveMarker(Handle("Missions\\act_1\\getcaught\\main\\LOC_HackBlipAtWall"), cMMI_Objective, cOM_Objective, true, true, true)
end

function Act_1_GetCaught:PlayDoopBoost()
  Convo.AddConvo("118_Con_Dopp-Boost", 10, {})
end

function Act_1_GetCaught:CanWePlayConvoHere1()
  if self:GetMissionTaskFail() == false and Suspicion.GetEscalation() == 0 then
    Convo.ResetForFail()
    self.dopp_start_playing = true
    Convo.AddConvo("118_Con_Dopp-Start", 10, {})
  end
end

function Act_1_GetCaught.MakeJulesRun()
  Nav.SetScriptedPath(Act_1_GetCaught.hJules, Act_1_GetCaught.PATH .. "main\\PATH_JulesAtSalvage", true, "Act_1_GetCaught.JulesAtSalvage", Act_1_GetCaught, {})
  Nav.SetScriptedPathMoveMode(Act_1_GetCaught.hJules, true)
  Combat.SetRespondToEvents(Act_1_GetCaught.hJules, false)
  Combat.SetIdleScripted(Act_1_GetCaught.hJules, true)
end

function Act_1_GetCaught:WaitForJules()
  local oTask = self:GetMissionTask("Task_ToTheWall")
  local messageid = oTask:GetTaskObjectiveID()
  HUD.SetObjectiveText(messageid, "A1M3_Text.WaitForJules")
end

function Act_1_GetCaught:OPTIONAL_BlipWall()
  self:CreateTask({
    sName = "Act_1_GetCaught.OPTIONAL_BlipWall",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "DELIVER",
    Proximity = 5,
    tDestProximityObj = {
      self.PATH .. "main\\Teleport_J_From"
    },
    tDeliverObjs = {hSab},
    bOptional = true,
    tOnComplete = {}
  })
end

function Act_1_GetCaught:WaitGoJules()
  local eWaitGoJ = Util.CreateEvent({
    EventType = "TimerEvent",
    EventName = "WaitGoJulesTimer",
    Time = 6
  }, "Act_1_GetCaught.GoJules", self)
  self:RegisterEvent(eWaitGoJ)
end

function Act_1_GetCaught:GoJules()
  Nav.SetScriptedPath(self.hJules, self.PATH .. "main\\PATH_JulesAtSalvage", true, "Act_1_GetCaught.JulesAtSalvage", self, {})
  Nav.SetScriptedPathMoveMode(self.hJules, true)
  Combat.SetRespondToEvents(self.hJules, false)
  Combat.SetIdleScripted(self.hJules, true)
  HUD.SetObjectiveMarker(self.hJules, cMMI_Escort, cOM_Escort, true, false, true)
end

function Act_1_GetCaught:SetupWaitForJ()
  local tWaitForJ = Trigger.WaitFor(Handle("Missions\\act_1\\getcaught\\main\\PT_WaitForJules"), hSab, "Act_1_GetCaught.ComeBackPlayer", self, {}, cTRIGGEREVENT_ONEXIT, false)
  self:RegisterTriggerEvent(tWaitForJ, "Missions\\act_1\\getcaught\\main\\PT_WaitForJules")
end

function Act_1_GetCaught:ComeBackPlayer()
  Convo.AddConvo("A1M3_NearDopp_Abandon", 10, {})
end

function Act_1_GetCaught:JulesAtSalvage()
end

function Act_1_GetCaught:Task_BoostJules()
  self:CreateTask({
    sName = "Task_BoostJules",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "A1M3_Text.Task_BoostJules",
    tLocators = {
      self.PATH .. "main\\Teleport_J_To"
    },
    tDestRegion = self.PATH .. "main\\PT_JulesOverWall",
    tDeliverObjs = {hSab},
    bNoWorldBlip = true,
    tSMEDNodes = {},
    tOnActivate = {
      {
        self.TempFixSilverDart,
        {self}
      }
    },
    tOnComplete = {
      {
        self.Task_JulesCutscene,
        {self}
      },
      {
        Trigger.DoNotWaitFor,
        {
          Handle("Missions\\act_1\\getcaught\\main\\PT_WaitForJules"),
          hSab
        }
      }
    }
  })
end

function Act_1_GetCaught:TempFixSilverDart()
  if Handle("Missions\\act_1\\getcaught\\silverdart_start\\VH_CV_CR_SilverDart_01") ~= nil then
    self:UnloadTaskNodes("TASK_FatLoad_Dierker_car", true)
  end
end

function Act_1_GetCaught:DoNotRegisterCar()
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\act_1\\getcaught\\silverdart_dopp\\VH_CV_CR_SilverDart_01"
    }
  }, "Act_1_GetCaught.OnceCarStreamedIn", self))
end

function Act_1_GetCaught:OnceCarStreamedIn()
  local hCar = Handle("Missions\\act_1\\getcaught\\silverdart_dopp\\VH_CV_CR_SilverDart_01")
  Object.SetShouldNeverRegisterGameObjectEvents(hCar, true)
end

function Act_1_GetCaught:Task_JulesCutscene()
  self:UnloadTaskNodes("TASK_FatLoad_NaziPatrol", true)
  Util.KillEvent(self.hDoopBoostPlay)
  self:CreateTask({
    sName = "Task_JulesCutscene",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "118_Cin_Dopp_Intro",
    tOnActivate = {
      {
        Act_1_GetCaught.DoNotRegisterCar,
        {self}
      }
    },
    tOnComplete = {
      {
        self.Task_ClamborOverWall,
        {self}
      },
      {
        Nav.StopMoving,
        {
          self.hJules
        }
      },
      {
        self.KillTaskByName,
        {
          self,
          "TASK_DriveEscalator"
        }
      }
    },
    tSMEDNodes = {
      Act_1_GetCaught.PATH .. "silverdart_dopp"
    }
  })
end

function Act_1_GetCaught.DelayedConvoInCinematic()
  Convo.AddConvo("A1M3_BoostingJules_Complete", 10, {})
end

function Act_1_GetCaught:DelayedTutorial()
end

function Act_1_GetCaught:Task_ClamborOverWall()
  local tEvent = {EventType = "TimerEvent", Time = 0.5}
  Util.CreateEvent(tEvent, "Act_1_GetCaught.DelayedTutorial", self)
  if not self:IsMissionTaskActive("TASK_DoppEscalator") then
    self.TASK_DoppEscalator(self)
  end
  self.DierkerCarDeathFail(self)
  self:CreateTask({
    sName = "Task_ClamborOverWall",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "A1M3_Text.Task_ClamborOverWall",
    tLocators = {
      self.PATH .. "main\\Teleport_J_To"
    },
    tDestRegion = self.PATH .. "main\\PT_MeetJules",
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        Saboteur.ShowToolTip,
        {
          "TutorialTip_Text.Clambering_Drop",
          12,
          nil,
          true
        }
      },
      {
        Nav.FollowObject,
        {
          self.hJules,
          Handle("Saboteur"),
          12,
          true,
          false,
          true
        }
      },
      {
        self.CompleteTaskByName,
        {
          self,
          "Task_FollowDierker"
        }
      },
      {
        self.Task_GoToDierkerCar,
        {self}
      }
    }
  })
end

function Act_1_GetCaught:DropDownTutorialSetup()
  local sTrigger = "Missions\\act_1\\getcaught\\main\\PT_DropDownTutorial"
  local eSetupTrig = Trigger.WaitFor(sTrigger, hSab, "Act_1_GetCaught.PlayDropDownTutorial", self, {})
  self:RegisterTriggerEvent(eSetupTrig, sTrigger)
end

function Act_1_GetCaught:PlayDropDownTutorial()
end

function Act_1_GetCaught.KeepQuietSean()
  local tEvent = {EventType = "TimerEvent", Time = 2}
  Util.CreateEvent(tEvent, "Act_1_GetCaught.PlayConvoInsideDopp", Act_1_GetCaught)
end

function Act_1_GetCaught:PlayConvoInsideDopp()
  if Actor.IsInVehicle(hSab) == false then
    Convo.AddConvo("118_Con_Dopp-Inside_Quiet", 10, {})
  end
end

function Act_1_GetCaught:Task_GoToDierkerCar()
  local sTrigger = "Missions\\act_1\\getcaught\\main\\PT_JulesAbandonAtEnd"
  local eSetupTrig = Trigger.WaitFor(sTrigger, hSab, "Act_1_GetCaught.JulesAbandonEndFail", self, {
    "GenericFail_Text.ABANDON_Jules"
  })
  self:RegisterTriggerEvent(eSetupTrig, sTrigger)
  Convo.AddConvo("118_Con_Dopp-Inside", 10, {})
  Convo.AddConvo("A1M3_Trashcar_SpotCliff", 10, {})
  Convo.AddConvo("A1M3_TrashCar_NearCar_Jules", 10, {
    sCallback = Act_1_GetCaught.KeepQuietSean
  })
  self.BlipDierkerCarFunction(self)
  self.nEndFail = 0
  self:CreateTask({
    sName = "Task_GoToDierkerCar",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "DELIVER",
    sObjectiveTextID = "A1M3_Text.Task_GoToDierkerCar",
    tDestProximityObj = {
      Handle("Missions\\act_1\\getcaught\\silverdart_dopp\\VH_CV_CR_SilverDart_01")
    },
    Proximity = 0,
    tDeliverObjs = {hSab},
    tOnActivate = {
      {
        self.DoppMusic,
        {self}
      }
    },
    tOnComplete = {
      {
        self.SafeToSave,
        {self}
      }
    }
  })
  EVENT_PlayerEntersVehicle("Act_1_GetCaught.UnBlipDierkerCarFunction", self, "Missions\\act_1\\getcaught\\silverdart_dopp\\VH_CV_CR_SilverDart_01", nil, true)
  EVENT_PlayerExitsAnyVehicle("Act_1_GetCaught.BlipDierkerCarFunction", self, nil, true)
end

function Act_1_GetCaught:SafeToSave()
  if Suspicion.IsSomeoneHostileOrHunting() == false then
    self.ShowCliffCinematic(self)
  end
end

function Act_1_GetCaught:ShowCliffCinematic()
  Sound.SetMusicLocale("A1M3_GetCaught")
  Sound.SetMusicLocale("m_A1M3_GetCaught", "trashCar")
  self:CreateTask({
    sName = "CliffShower",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "CIN_A1M3_CliffShow",
    tOnComplete = {
      {
        self.SetupCheckpoint3,
        {self}
      }
    }
  })
end

function Act_1_GetCaught:BlipDierkerCarFunction()
  HUD.SetObjectiveMarker(Handle("Missions\\act_1\\getcaught\\silverdart_dopp\\VH_CV_CR_SilverDart_01"), eOT_GOTO, cOM_Goto, true, true, true)
end

function Act_1_GetCaught:UnBlipDierkerCarFunction()
  self:CompleteTaskByName("Task_GoToDierkerCar")
  HUD.RemoveObjectiveMarker(Handle("Missions\\act_1\\getcaught\\silverdart_dopp\\VH_CV_CR_SilverDart_01"))
end

function Act_1_GetCaught:DoppMusic()
end

function Act_1_GetCaught:SetupCheckpoint3()
  self:RegisterCheckpoint("Act_1_GetCaught.Checkpoint3")
end

function Act_1_GetCaught:DierkerCarCheck()
  local hCar = Handle("Missions\\act_1\\getcaught\\silverdart_dopp\\VH_CV_CR_SilverDart_01")
  local nSpeed = Vehicle.GetSpeed(hCar)
  if 0 < nSpeed then
    local tObjects = Trigger.GetAllWithin(Handle("Missions\\act_1\\getcaught\\main\\PT_TrashCarTryAgain"))
    local hEnt
    if tObjects then
      for i, hEnt in ipairs(tObjects) do
        if hEnt == hCar then
          local tEvent = {EventType = "TimerEvent", Time = 0.5}
          self.hCheckSpeedForever = Util.CreateEvent(tEvent, "Act_1_GetCaught.CheckSpeedForever", self)
          self:RegisterEvent(self.hCheckSpeedForever)
          break
        end
      end
    end
  end
end

function Act_1_GetCaught:CheckSpeedForever()
  local hCar = Handle("Missions\\act_1\\getcaught\\silverdart_dopp\\VH_CV_CR_SilverDart_01")
  local nSpeed = Vehicle.GetSpeed(hCar)
  if nSpeed <= 1 then
    Convo.AddConvo("A1M3_TrashCar_TryAgain", 10, {})
  else
    local tEvent = {EventType = "TimerEvent", Time = 0.5}
    self.hCheckSpeedForever = Util.CreateEvent(tEvent, "Act_1_GetCaught.CheckSpeedForever", self)
    self:RegisterEvent(self.hCheckSpeedForever)
  end
end

function Act_1_GetCaught:MoveJulesToFinalLocation()
end

function Act_1_GetCaught:Checkpoint3()
  Suspicion.ResetEscalation()
  local sTrigger = "Missions\\act_1\\getcaught\\main\\PT_JulesAbandonAtEnd"
  local eSetupTrig = Trigger.WaitFor(sTrigger, hSab, "Act_1_GetCaught.JulesAbandonEndFail", self, {
    "GenericFail_Text.ABANDON_Jules"
  })
  self:RegisterTriggerEvent(eSetupTrig, sTrigger)
  Convo.ResetForFail()
  Combat.SetGrabbable(self.hJules, false)
  local tTimerEvent = {EventType = "TimerEvent", Time = 5}
  Util.CreateEvent(tTimerEvent, "Act_1_GetCaught.MoveJulesToFinalLocation", self)
  EVENT_PlayerExitsAnyVehicle("Act_1_GetCaught.DierkerCarCheck", self, nil, true)
  Util.KillEvent(self.hJulesStreamOut)
  self.JulesIsDead(self)
  self.e_CrashTrig = Util.CreateEvent({
    EventType = "OnTriggerEnter",
    Target = Util.GetHandleByName(self.PATH .. "main\\PT_Crash")
  }, "Act_1_GetCaught.LaunchTest", self, nil, true)
  self:RegisterEvent(self.e_CrashTrig)
  self.tInfo.bWin = 1
  if self.nEndFail > 0 then
    Suspicion.SetEscalationLevel(0)
  end
  if not self:IsMissionTaskActive("TASK_DoppEscalator") then
    self.TASK_DoppEscalator(self)
  end
  self.nEndFail = 1
  self.DierkerCarDeathFail(self)
  self.Task_LaunchDierkerCar(self)
  EVENT_PlayerExitsAnyVehicle("Act_1_GetCaught.BlipDierkerCarFunction", self, nil, true)
end

function Act_1_GetCaught:Task_LaunchDierkerCar()
  HUD.SetWaypoint(3233, -3174)
  Sound.DisableSeanChatter()
  self:CreateTask({
    sName = "Task_LaunchDierkerCar",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "A1M3_Text.Task_LaunchDierkerCar",
    Proximity = 1,
    sTaskSubType = "DELIVER",
    tDestProximityObj = {
      "Missions\\act_1\\getcaught\\main\\LOC_Launch"
    },
    tDeliverObjs = {
      "Missions\\act_1\\getcaught\\silverdart_dopp\\VH_CV_CR_SilverDart_01"
    },
    tOnActivate = {
      {
        self.JumpTrigger,
        {self}
      },
      {
        Saboteur.ShowToolTip,
        {
          "TutorialTip_Text.Vehicle_Bail",
          20,
          nil,
          true
        }
      }
    },
    tOnComplete = {}
  })
  self.GotInCarMusicTrigger(self)
end

function Act_1_GetCaught:GotInCarMusicTrigger()
end

function Act_1_GetCaught:JumpTrigger()
  local tExitCarTrig = Trigger.WaitFor(Handle(self.PATH .. "main\\PT_ExitCarVO"), Handle("Missions\\act_1\\getcaught\\silverdart_dopp\\VH_CV_CR_SilverDart_01"), "Act_1_GetCaught.JulesSaysJump", self, {-1})
  self:RegisterTriggerEvent(tExitCarTrig, self.PATH .. "main\\PT_ExitCarVO")
end

function Act_1_GetCaught:JulesToLaunch()
  Nav.CancelFollowObject(self.hJules)
  Nav.MoveToObject(self.hJules, Handle("Missions\\act_1\\getcaught\\main\\LOC_JulesAtLaunch"), 2, true)
  Convo.AddConvo("A1M3_TrashCar_NearCar_Jules", 10, {})
end

function Act_1_GetCaught:Task_EndCutscene()
  self.FinalCinematicFade(self)
end

function Act_1_GetCaught:FinalCinematicFade()
  self.FinalCinematicStream(self)
end

function Act_1_GetCaught:FinalCinematicStream()
  Util.UnloadEditNode("Missions\\act_1\\getcaught\\main.wsd", true, false)
  Object.SetHealth(hSab, 600)
  Object.SetInvincible(hSab, true)
  self.TransitionCutScene(self)
end

function Act_1_GetCaught:TransitionCutScene()
  Util.KillEvent(self.hCheckSpeedForever)
  Sound.SetMusicLocale("A1M3_GetCaught")
  Sound.SetMusicLocale("m_A1M3_GetCaught", "cin122_in")
  HUD.ClearTutorialText()
  self:CreateTask({
    sName = "Task_EndCutscene",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "120_CinB_Busted",
    bOverrideFade = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.CleanUp,
        {self}
      }
    },
    tCinematicNodes = {
      "Missions\\cinematics\\120_cinb_busted"
    }
  })
end

function Act_1_GetCaught:CleanUp()
  Util.UnloadStaticENTag("a1m3_StartProps", true)
  Util.UnloadEditNode("Missions\\act_1\\getcaught\\doppnazis.wsd")
  Util.UnloadEditNode("Missions\\act_1\\getcaught\\silverdart_dopp.wsd", true, false)
  Util.SetDynamicPriority("VH_CV_CR_Bugatti_01_Vittore", -1)
  Util.KillEvent(self.eJulesDead)
  self:CompleteThisMission()
end

function Act_1_GetCaught:ResetMusic()
  Sound.ResetMusicLocale()
  Sound.ReleaseSoundBank("m_A1M3_inGame.bnk")
end

function Act_1_GetCaught:SetupAmbientEvents()
  self.ChangeDierkerSpeed(self)
end

function Act_1_GetCaught:ChangeDierkerSpeed()
  local hDierker = Handle("Missions\\act_1\\getcaught\\silverdart_start\\Spore_NZ_Dierker_RaceDriver")
  if hDierker then
    local tEvent = {EventType = "TimerEvent", Time = 0.5}
    self.hChangeDierkerSpeedEvent = Util.CreateEvent(tEvent, "Act_1_GetCaught.ChangeDierkerSpeed", self)
    self:RegisterEvent(self.hChangeDierkerSpeedEvent)
    if Actor.IsInVehicle(hDierker) then
      local nDist = Actor.GetActorDist(hSab, Handle("Missions\\act_1\\getcaught\\silverdart_start\\Spore_NZ_Dierker_RaceDriver"))
      if 100 < nDist then
        Nav.SetScriptedPathSpeed(hDierker, 20)
      elseif 80 < nDist then
        Nav.SetScriptedPathSpeed(hDierker, 40)
      elseif 60 < nDist then
        Nav.SetScriptedPathSpeed(hDierker, 55)
      elseif 40 < nDist then
        Nav.SetScriptedPathSpeed(hDierker, 60)
      elseif 20 < nDist then
        Nav.SetScriptedPathSpeed(hDierker, 70)
      elseif 0 < nDist then
        Nav.SetScriptedPathSpeed(hDierker, 75)
      end
    end
  end
end

function Act_1_GetCaught:CarOffCliffSound()
  local hCar = Handle("Missions\\act_1\\getcaught\\silverdart_dopp\\VH_CV_CR_SilverDart_01")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_1\\getcaught\\main\\PT_CarOffCliff", hCar, "Act_1_GetCaught.PlayCarOffCliffSound", self, {}, cTRIGGEREVENT_ONENTER), "Missions\\act_1\\getcaught\\main\\PT_CarOffCliff")
end

function Act_1_GetCaught:PlayCarOffCliffSound()
  local hCar = Handle("Missions\\act_1\\getcaught\\silverdart_dopp\\VH_CV_CR_SilverDart_01")
  if Vehicle.GetSpeed(hCar) > 10 then
    self.tSaveInfo.bDelay = true
  end
end

function Act_1_GetCaught:DelayedComplete()
end

function Act_1_GetCaught:ResetMission()
  HUD.ClearWaypoint()
  Object.SetInvincible(hSab, false)
  if self.nTrafficCount == 1 then
    Vehicle.EnableTraffic(true, true)
  end
  self.nTrafficCount = 0
  Util.ResetDayTimeScale()
  Actor.SetCannotGetOutOfSeat(hSab, false)
  Sound.EnableSeanChatter()
  Util.UnloadStaticENTag("a1m3_StartProps", true)
  Util.UnregisterLuaUpdate("Act_1_GetCaught.EvaluateParanoia")
  Sound.ReleaseSoundBank("m_A1M3_InGame.bnk")
  Convo.ResetForFail()
end

function Act_1_GetCaught:ResetMissionOnCancel()
  HUD.ClearWaypoint()
  Object.SetInvincible(hSab, false)
  if self.nTrafficCount == 1 then
    Vehicle.EnableTraffic(true, true)
  end
  self.nTrafficCount = 0
  Util.ResetDayTimeScale()
  Actor.SetCannotGetOutOfSeat(hSab, false)
  Sound.EnableSeanChatter()
  Util.UnloadStaticENTag("a1m3_StartProps", true)
  Util.UnregisterLuaUpdate("Act_1_GetCaught.EvaluateParanoia")
  Sound.ResetMusicLocale()
  Sound.ReleaseSoundBank("m_A1M3_InGame.bnk")
  Convo.ResetForFail()
end
