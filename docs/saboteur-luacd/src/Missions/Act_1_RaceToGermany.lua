if Act_1_RaceToGermany == nil then
  Act_1_RaceToGermany = SabTaskObjective:Create()
  gsA12Germ = "Missions\\act_1\\racetogermany\\"
  Act_1_RaceToGermany:Configure({
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
    }
  })
end

function Act_1_RaceToGermany:STARTER_Setup()
  Zone.SwitchState("WtF_Zones\\global\\A1M4_Champange_Ardeness", cZONESTATE_HIGHWTF, cENT_NOCHANGE)
  Render.SetGlobalWTF(true)
  Sound.LoadSoundBank("m_A1M0_inGame.bnk")
  Actor.SetDisguise(hSab, "FBS_RS_Sean_Shirt_Sab_Hat_NoBag")
  Suspicion.ResetEscalation()
  Suspicion.EnableEscalation(true)
  Vehicle.EnableTraffic(false)
  Util.SetTime(9, 0)
end

function Act_1_RaceToGermany:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.TASK_FatLoad2(self)
  self.TASK_FatLoad3(self)
  Util.SpawnEditNode("Missions\\act_1\\characters\\farm_jules.wsd")
  self:TeleportToFarm()
end

function Act_1_RaceToGermany:TeleportToFarm()
  if Actor.IsInVehicle(hSab) then
    Actor.UnboardVehicle(hSab)
    EVENT_PlayerExitsAnyVehicle("Paris_1_Mission_1.TeleportToFarm2", self)
  else
    Object.PlayerTeleportToLocator(Util.GetHandleByName("Missions\\act_1\\togermany\\farmtransition\\LOC_SeanTeleportTo"), false, true, "Act_1_RaceToGermany.SetupStreamStart", self)
  end
end

function Act_1_RaceToGermany:TeleportToFarm2()
  Object.PlayerTeleportToLocator(Util.GetHandleByName("Missions\\act_1\\togermany\\farmtransition\\LOC_SeanTeleportTo"), false, true, "Act_1_RaceToGermany.SetupStreamStart", self)
end

function Act_1_RaceToGermany:GENERAL_Setup()
  self.tInfo.CPGateSwitch = "CountrySide\\borders\\saarbrucken\\country\\saarbrucken\\AttrPt_DoorSwitch"
  self.tInfo.CPGate = "CountrySide\\alsace\\german_border\\PSBridge_HydroStation\\PSBridge_HS_Gate_L"
  self.tInfo.Gate = "CountrySide\\champagneardennes\\morinifarm\\roads\\MN_MoriniFarm_MainGate(2)\\MN_MoriniFarm_MainGate_GateR"
  Util.EnableMiniZep(false)
  self:AddOnCancelCallback(Act_1_RaceToGermany.Reset)
  self:AddOnCompleteCallback(Act_1_RaceToGermany.Reset)
  self.tSaveInfo.bCarfail = false
  self.tInfo.JulesLoc = "Missions\\act_1\\racetogermany\\main\\LOC_Jules"
  self.tInfo.Truck = "Missions\\act_1\\racetogermany\\truckaurora\\TruckAurora"
  self.tInfo.Jules = "Missions\\act_1\\characters\\farm_jules\\jules"
  self.tInfo.Veronique = "Missions\\act_1\\racetogermany\\verovitt_togermany\\veronique_togermany"
  self.tInfo.Vittore = "Missions\\act_1\\racetogermany\\verovitt_togermany\\vittore_togermany"
  self.tInfo.Bugatti = "Missions\\act_1\\racetogermany\\bugatti\\Bugatti"
  self.tInfo.RaceOverCar = "Missions\\act_1\\racetogermany\\raceoverjavier\\VH_CV_CR_Allard_01_Javier"
  self.tInfo.JavierRaceOver = "Missions\\act_1\\racetogermany\\raceoverjavier\\javier_raceover"
  self.tInfo.StartPath = "Missions\\act_1\\racetogermany\\main\\PATH_StartRace"
  self.tInfo.Javier = "Missions\\act_1\\racetogermany\\javier\\javier_race"
  self.tInfo.RaceCar = "Missions\\act_1\\racetogermany\\javier\\VH_CV_CR_Allard_01_Javier"
  self.tInfo.RaceCarBP = "VH_CV_CR_Allard_01"
  self.tInfo.JavierBP = "Spore_RS_Javier"
  self.tInfo.LocRacer = "Missions\\act_1\\racetogermany\\main\\LOC_JavierRacer"
  self.tStreamObjs = {
    "Missions\\act_1\\racetogermany\\main\\LOC_Jules",
    "Missions\\act_1\\racetogermany\\truckaurora\\TruckAurora",
    "Missions\\act_1\\characters\\farm_jules\\jules",
    "Missions\\act_1\\racetogermany\\verovitt_togermany\\veronique_togermany",
    "Missions\\act_1\\racetogermany\\verovitt_togermany\\vittore_togermany",
    "Missions\\act_1\\racetogermany\\bugatti\\Bugatti"
  }
  self.tSaveInfo.bGotPastCP = false
  self.tSaveInfo.bGateOpen = false
  self.tSaveInfo.bGetGoing = false
  self.tInfo.c_PaperCheckPass = 1
  self.tInfo.c_GateDead = 2
  self.tInfo.c_GateOpen = 3
  Object.SetInvincible(hSab, true)
  Suspicion.EnableEscalationVehicles(false)
  Object.SetInvincible(hSab, true)
  self.tSaveInfo.bLoadBugatti = false
  self.tSaveInfo.FirstPlace = false
  self.tSaveInfo.bStartPreRace = false
  self.tSaveInfo.RACESTATE = 0
  self.tSaveInfo.bEastDust = false
  self.tSaveInfo.bClampSpeed = false
end

function Act_1_RaceToGermany:Reset()
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
  Vehicle.EnableTraffic(true)
end

function Act_1_RaceToGermany:PostIntro()
  self:TASK_FatLoad2(self)
  self:TASK_FatLoad3(self)
  Util.SpawnEditNode("Missions\\act_1\\characters\\farm_jules.wsd")
end

function Act_1_RaceToGermany:Part1Ready()
  EVENT_Timer("Act_1_RaceToGermany.ReadyGo", self, 2)
  Combat.SetGrabbable(Handle(self.tInfo.Vittore), false)
  Actor.SetUseHitReactions(Handle(self.tInfo.Vittore), false)
end

function Act_1_RaceToGermany:ReadyGo()
  self:RegisterCheckpoint("Act_1_RaceToGermany.Checkpoint1")
end

function Act_1_RaceToGermany:TASK_FatLoad()
  self:CreateTask({
    sName = "TASK_FatLoad",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      gsA12Germ .. "main",
      gsA12Germ .. "farm_population",
      gsA12Germ .. "bugatti",
      gsA12Germ .. "raceline"
    },
    tStaticTags = {
      "PristineBarn_Props2",
      "PristineBarn_Building2",
      "Drive2GermanyProps_Race",
      "A1M0_German_Border_Race",
      "a1germ_raceprops"
    },
    tOnActivate = {}
  })
end

function Act_1_RaceToGermany:TASK_FatLoad2()
  self:CreateTask({
    sName = "TASK_FatLoad2",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      gsA12Germ .. "verovitt_togermany",
      gsA12Germ .. "truckaurora"
    },
    tOnActivate = {}
  })
end

function Act_1_RaceToGermany:TASK_FatLoad3()
  self:CreateTask({
    sName = "TASK_FatLoad3",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      gsA12Germ .. "javier"
    },
    tOnActivate = {
      {
        self.TASK_FatLoad,
        {self}
      }
    }
  })
end

function Act_1_RaceToGermany:SetupStreamStart()
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = self.tStreamObjs,
    WaitForGameObject = true
  }
  Util.CreateEvent(tStreamEvent, "Act_1_RaceToGermany.Part1Ready", self)
  EVENT_Stream("Act_1_RaceToGermany.OpenFarmGate", self, {
    self.tInfo.Gate
  })
end

function Act_1_RaceToGermany:OpenFarmGate()
  print("gate streamed in opening")
  Object.ForceOpen(Handle(self.tInfo.Gate))
end

function Act_1_RaceToGermany:Checkpoint1()
  Render.FadeScreen(false, 0)
  Object.ForceOpen(Util.GetHandleByName("CountrySide\\champagneardennes\\morinifarm\\roads\\MN_MoriniFarm_MainGate(2)\\MN_MoriniFarm_MainGate_GateR"))
  OffWalkingConversationDisables()
  Vehicle.SetRacing(false)
  self.tSaveInfo.bRacing = false
  self.tSaveInfo.bTestedSpeed = false
  self.tSaveInfo.bStartPreRace = false
  self.tSaveInfo.bEastDust = false
  self.tSaveInfo.RACESTATE = 0
  if not self:IsMissionTaskActive("Task_GoTo") then
    self:Task_GoTo()
    self:SetupConvosPart1()
    self:TASK_Checkpoint2()
  end
end

function Act_1_RaceToGermany:Task_GoTo()
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

function Act_1_RaceToGermany:CPFunctionActivation()
  Vehicle.LockAllSeats(Handle("CountrySide\\champagneardennes\\morinifarm\\props\\VH_CV_CR_Citroen15_01(3)"), true)
  Vehicle.LockAllSeats(Handle(self.tInfo.Truck), true)
  Vehicle.LockAllSeats(Handle(self.tInfo.RaceCar), true)
  Vehicle.LockAllSeats(Handle("Missions\\act_1\\racetogermany\\farm_population\\TruckWheelFix\\VH_CV_TR_Citroentype45_01"), true)
  local sCPName = self:GetCheckpointName()
  if sCPName == "Act_1_RaceToGermany.Checkpoint1" then
    self:TASK_StartConvo()
    self:FailEvent()
  elseif sCPName == "Act_1_RaceToGermany.Checkpoint2" then
    self:FailEvent()
  end
end

function Act_1_RaceToGermany:TASK_StartConvo()
  self:CreateTask({
    sName = "TASK_StartConvo",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    tOnActivate = {
      {
        self.VittoreLeavesConvo,
        {self}
      }
    }
  })
end

function Act_1_RaceToGermany:VittoreLeavesConvo()
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
  EVENT_Timer("Act_1_RaceToGermany.CallbackConvVittore", self, 1.3)
end

function Act_1_RaceToGermany:CallbackConvVittore()
  Cin.PlayConversation("103_InG_Truck-VittoreLeaves_b", "Act_1_RaceToGermany.LoadBugatti", self)
end

function Act_1_RaceToGermany:LoadBugatti()
  print("load up in the bugatti!")
  if not Act_1_RaceToGermany.tSaveInfo.bLoadBugatti then
    print("load up in the just this once")
    Act_1_RaceToGermany.tSaveInfo.bLoadBugatti = true
    local self = Act_1_RaceToGermany
    local hBugatti = Handle(Act_1_RaceToGermany.tInfo.Truck)
    Nav.BoardVehicle(Handle(Act_1_RaceToGermany.tInfo.Vittore), hBugatti, "PILOT", false)
    Nav.BoardVehicle(Handle(Act_1_RaceToGermany.tInfo.Veronique), hBugatti, "SHOTGUN", false)
    EVENT_Timer("Act_1_RaceToGermany.BugattiAway", Act_1_RaceToGermany, 5)
  end
end

function Act_1_RaceToGermany:ForceLoadBugatti()
  local hBugatti = Handle(self.tInfo.Truck)
end

function Act_1_RaceToGermany:BugattiAway()
  print("bugatti away")
  self:ForceLoadBugatti()
  local hBugatti = Util.GetHandleByName(self.tInfo.Truck)
  Vehicle.StartPlayback(hBugatti, "A1M0_Vittore_DriveAway.vcr", "Act_1_RaceToGermany.UnloadBugatti")
  EVENT_Timer("Act_1_RaceToGermany.UnloadVeroVitt", self, 13)
  self:Task_GetFakeyCar()
end

function Act_1_RaceToGermany:UnloadBugatti()
  Act_1_RaceToGermany:UnloadTaskNodes("TASK_FatLoad2", true)
end

function Act_1_RaceToGermany:UnloadVeroVitt()
  Vehicle.UnboardAll(Handle(self.tInfo.Truck), false)
  self:UnloadTaskNodes("TASK_FatLoad2", true)
end

function Act_1_RaceToGermany:Task_GetFakeyCar()
  self:CreateTask({
    sName = "Task_GetFakeyCar",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\racetogermany\\main\\REG_OhJavier",
    tDeliverObjs = {hSab},
    tLocators = {
      self.tInfo.RaceCar
    },
    sObjectiveTextID = "A1M0_Text.TASK_GetSportsCar",
    tOnActivate = {
      {
        self.SetupJavier,
        {self}
      }
    },
    tOnComplete = {
      {
        self.StartJavierPullOut,
        {self}
      }
    }
  })
end

function Act_1_RaceToGermany:SetupJavier()
  print("setup javier")
  local hJavier = Handle(self.tInfo.Javier)
  Actor.BoardVehicle(hJavier, Handle(self.tInfo.RaceCar), "PILOT")
  Joe.MakeSabFollower(Handle(self.tInfo.Jules), true, 3, cMOVE_FAST)
end

function Act_1_RaceToGermany:StartJavierPullOut()
  print("start javier")
  local hJavier = Handle(self.tInfo.Javier)
  local hRaceCar = Handle(self.tInfo.RaceCar)
  Nav.SetScriptedPath(hRaceCar, "Missions\\act_1\\racetogermany\\main\\PATH_PullOut", true, "Act_1_RaceToGermany.JavierConv", self)
  Nav.SetScriptedPathSpeed(hRaceCar, 90)
end

function Act_1_RaceToGermany:JavierConv()
  print("JavierConv start javier")
  if Actor.GetVehicle(hSab) then
    Actor.UnboardVehicle(hSab)
  end
  if Actor.GetVehicle(Handle(self.tInfo.Jules)) then
    Actor.UnboardVehicle(Handle(self.tInfo.Jules))
  end
  self:TASK_StartRaceCin()
end

function Act_1_RaceToGermany:TASK_StartRaceCin()
  self:CreateTask({
    sName = "TASK_StartRaceCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "A1M0_StartRace",
    tOnActivate = {},
    tOnComplete = {
      {
        self.StartJavier,
        {self}
      }
    }
  })
end

function Act_1_RaceToGermany:StartJavier()
  print("start javier")
  local hJavier = Handle(self.tInfo.Javier)
  local hRaceCar = Handle(self.tInfo.RaceCar)
  Nav.SetScriptedPath(hRaceCar, self.tInfo.StartPath, true, "Act_1_RaceToGermany.PreRace", self)
  Nav.SetScriptedPathSpeed(hRaceCar, 90)
end

function Act_1_RaceToGermany:RunBoys()
  print("run boys")
end

function Act_1_RaceToGermany:PreRace()
  if not self.tSaveInfo.bStartPreRace then
    self.tSaveInfo.bStartPreRace = true
    Joe.ClearSabFollower(Handle(self.tInfo.Jules), true)
    self:Task_TaxiJules()
  end
end

function Act_1_RaceToGermany:SetupRace()
  print("setup race")
  Vehicle.SetRacing(false)
  Vehicle.SetupRace("RaceToGermany", "FinishLine", 1, 0, 2)
  Vehicle.AddRacer(self.tInfo.Javier, Handle(self.tInfo.RaceCar), "RaceToGermany", 0, 90, 100)
  local x, y, z = Object.GetPosition(Handle(self.tInfo.LocRacer))
  EVENT_Timer("Act_1_RaceToGermany.Countdown", self, 0.5)
end

function Act_1_RaceToGermany:Countdown()
  print("get ready")
  Vehicle.SetRacing(true, false, cRH_None)
  Vehicle.SetRaceFinishedCallback("Act_1_RaceToGermany.EndRace", self)
  self:StartRace()
end

function Act_1_RaceToGermany:StartRace()
  print("go !!!!")
  self.tSaveInfo.bRacing = true
  local hJavier = Handle(self.tInfo.Javier)
  local hCar = Handle(self.tInfo.RaceCar)
  self:DistanceCheck()
  Vehicle.EnableTraffic(false)
  Vehicle.SetRacerSpeed(self.tInfo.Javier, 80, 120)
  Vehicle.OverrideHorsepower(hCar, true, 300)
  Vehicle.SetSuperHeavy(hCar, true)
  Vehicle.SetForceSelfRight(hCar, true)
  Vehicle.SetForceNeverFlip(hCar, true)
  Object.SetInvincible(hJavier, true)
  Object.SetInvincible(hCar, true)
  SabTaskObjective.SetUIBlips(self, self.tInfo.RaceCar, true, true, false)
end

function Act_1_RaceToGermany:EndRace()
  print("race over")
  SabTaskObjective.SetUIBlips(self, self.tInfo.RaceCar, false, true, false)
  Vehicle.RemoveRacer(self.tInfo.Javier)
  Vehicle.SetRacing(false)
  self.tSaveInfo.bRacing = false
end

function Act_1_RaceToGermany:DistanceCheck()
  EVENT_ActorEntersTrigger("Act_1_RaceToGermany.TestSpeed", self, hSab, "Missions\\act_1\\racetogermany\\main\\REG_SpeedCheck1", {
    85,
    130,
    1
  })
  EVENT_ActorEntersTrigger("Act_1_RaceToGermany.TestSpeed", self, Handle(self.tInfo.Javier), "Missions\\act_1\\racetogermany\\main\\REG_SpeedCheck2", {
    85,
    95,
    3
  })
  EVENT_ActorEntersTrigger("Act_1_RaceToGermany.SetRaceState", self, hSab, "Missions\\act_1\\racetogermany\\main\\REG_SpeedCheck3", {4})
  EVENT_ActorEntersTrigger("Act_1_RaceToGermany.SetRaceState", self, Handle(self.tInfo.Javier), "Missions\\act_1\\racetogermany\\main\\REG_SpeedCheck3", {4})
  EVENT_ActorEntersTrigger("Act_1_RaceToGermany.SetRaceState", self, hSab, "Missions\\act_1\\racetogermany\\main\\REG_SpeedCheck", {5})
  Vehicle.SetRacerNearPlayerCallback(45, "Act_1_RaceToGermany.CheckDistanceFar", self)
  Vehicle.SetRacerNearPlayerCallback(10, "Act_1_RaceToGermany.CheckDistanceClose", self)
  Vehicle.SetRacerNearPlayerCallback(1, "Act_1_RaceToGermany.CheckDistanceReallyClose", self)
  Vehicle.SetRacerNearPlayerCallback(140, "Act_1_RaceToGermany.CheckDistanceReallyFar", self)
  EVENT_ActorEntersTrigger("Act_1_RaceToGermany.CheckWinner", self, Handle(self.tInfo.Javier), "Missions\\act_1\\racetogermany\\main\\REG_FinishLine", {})
  EVENT_PlayerEntersTrigger("Act_1_RaceToGermany.CheckWinner", self, "Missions\\act_1\\racetogermany\\main\\REG_FinishLine")
end

function Act_1_RaceToGermany:TestSpeed(tArgs, SpeedMin, SpeedMax, RACESTATE)
  local hJavier = Handle(self.tInfo.Javier)
  local Maxspeed = SpeedMax or 90
  local Minspeed = SpeedMin or 65
  if self.tSaveInfo.bRacing then
    print("setting min speed ", Minspeed, " Max speed ", Maxspeed)
    if tArgs and tArgs[1] and not self.tSaveInfo.bTestedSpeed then
      self.tSaveInfo.bTestedSpeed = true
      if tArgs[1] == hSab then
        Vehicle.SetRacerSpeed(self.tInfo.Javier, Minspeed, Maxspeed)
      else
        Vehicle.SetRacerSpeed(self.tInfo.Javier, Minspeed, Maxspeed)
      end
    else
      Vehicle.SetRacerSpeed(self.tInfo.Javier, Minspeed, Maxspeed)
    end
  end
  if RACESTATE then
    self:SetRaceState({}, RACESTATE)
  end
end

function Act_1_RaceToGermany:SetRaceState(tArgs, RACESTATE)
  if RACESTATE and type(RACESTATE) == "number" and RACESTATE > self.tSaveInfo.RACESTATE then
    print("------ Racestate = ", RACESTATE)
    self.tSaveInfo.RACESTATE = RACESTATE
  end
end

function Act_1_RaceToGermany:CheckDistanceFar(tArgs)
  if self.tSaveInfo.RACESTATE <= 3 then
    return
  end
  print(" *** CheckDistanceFar ", tArgs)
  local PlayersSpeed
  local hSabCar = Actor.GetVehicle(hSab)
  if hSabCar then
    PlayersSpeed = Vehicle.GetSpeed(hSabCar)
    print("Players speed ", PlayersSpeed)
  end
  if tArgs then
    if tArgs[3] == true then
      print(" Javier is ahead")
      if tArgs[2] == true then
        print(" entered distance slowing javier down")
        print(" setting min speed ", 80, " Max speed ", 85)
        Vehicle.SetRacerSpeed(tArgs[1], 80, 85)
      elseif not tArgs[2] then
        print(" exited distance slowing javier down")
        print(" setting min speed ", 80, " Max speed ", 85)
        Vehicle.SetRacerSpeed(tArgs[1], 80, 85)
      end
    else
      print("Javier is behind")
      if tArgs[2] then
        print(" entered distance speeding javier up")
        print(" setting min speed ", 90, " Max speed ", 110)
        Vehicle.SetRacerSpeed(tArgs[1], 90, 110)
      elseif not tArgs[2] then
        print(" exited distance speeding javier up")
        print(" setting min speed ", 115, " Max speed ", 130)
        Vehicle.SetRacerSpeed(tArgs[1], 115, 130)
      end
    end
  end
  print(" *** END CheckDistanceFar *** ")
end

function Act_1_RaceToGermany:CheckDistanceClose(tArgs)
  if self.tSaveInfo.RACESTATE <= 3 then
    return
  end
  print(" ***CheckDistanceClose ", tArgs)
  local PlayersSpeed
  local hSabCar = Actor.GetVehicle(hSab)
  if hSabCar then
    PlayersSpeed = Vehicle.GetSpeed(hSabCar)
    print("Players speed ", PlayersSpeed)
  end
  if not PlayersSpeed then
    print("ERROR:coulnt get players speed")
    PlayersSpeed = 70
  elseif PlayersSpeed < 70 then
    PlayersSpeed = 75
  end
  if tArgs then
    if tArgs[3] == true then
      print(" Javier is ahead")
      if tArgs[2] == true then
        print(" entered distance slowing javier down")
        if not self.tSaveInfo.bClampSpeed then
          print(" setting min speed ", PlayersSpeed - 5, " Max speed ", PlayersSpeed - 5)
          Vehicle.SetRacerSpeed(tArgs[1], PlayersSpeed - 5, PlayersSpeed - 5)
        else
          print(" setting min speed ", 75, " Max speed ", 80)
          Vehicle.SetRacerSpeed(tArgs[1], 75, 80)
        end
      elseif not tArgs[2] then
        print(" exited distance slowing javier down")
        print(" setting min speed ", PlayersSpeed - 10, " Max speed ", PlayersSpeed - 10)
        Vehicle.SetRacerSpeed(tArgs[1], PlayersSpeed - 10, PlayersSpeed - 10)
      end
    else
      print(" Javier is behind")
      if tArgs[2] then
        print(" entered distance speeding javier up")
        print(" setting min speed ", PlayersSpeed - 5, " Max speed ", PlayersSpeed)
        Vehicle.SetRacerSpeed(tArgs[1], PlayersSpeed - 5, PlayersSpeed)
      elseif not tArgs[2] then
        print(" exited distance speeding javier up")
        print(" setting min speed ", 80, " Max speed ", 90)
        Vehicle.SetRacerSpeed(tArgs[1], 80, 90)
      end
    end
  end
  print(" *** END CheckDistanceClose *** ")
end

function Act_1_RaceToGermany:CheckDistanceReallyClose(tArgs)
  if self.tSaveInfo.RACESTATE <= 2 then
    return
  end
  print(" ***CheckDistanceReallyClose ", tArgs)
  local PlayersSpeed
  local hSabCar = Actor.GetVehicle(hSab)
  if hSabCar then
    PlayersSpeed = Vehicle.GetSpeed(hSabCar)
  end
  if not PlayersSpeed then
    print("ERROR:coulnt get players speed")
    PlayersSpeed = 70
  elseif PlayersSpeed < 70 then
    PlayersSpeed = 75
  end
  if tArgs then
    if tArgs[3] == true then
      print(" Javier is ahead")
      if tArgs[2] == true then
        print(" entered distance slowing javier down")
        if not self.tSaveInfo.bClampSpeed then
          print(" setting min speed ", PlayersSpeed, " Max speed ", PlayersSpeed)
          Vehicle.SetRacerSpeed(tArgs[1], PlayersSpeed, PlayersSpeed)
        else
          print(" setting min speed ", 75, " Max speed ", 80)
          Vehicle.SetRacerSpeed(tArgs[1], 75, 80)
        end
      elseif not tArgs[2] then
        print(" exited distance slowing javier down")
        if not self.tSaveInfo.bClampSpeed then
          print(" setting min speed ", PlayersSpeed - 5, " Max speed ", PlayersSpeed - 5)
          Vehicle.SetRacerSpeed(tArgs[1], PlayersSpeed - 5, PlayersSpeed - 5)
        else
          print(" setting min speed ", 70, " Max speed ", 80)
          Vehicle.SetRacerSpeed(tArgs[1], 70, 80)
        end
      end
    else
      print(" Javier is behind")
      if tArgs[2] then
        print(" entered distance speeding javier up")
        print(" setting min speed ", PlayersSpeed, " Max speed ", PlayersSpeed)
        Vehicle.SetRacerSpeed(tArgs[1], PlayersSpeed, PlayersSpeed)
        if not self.tSaveInfo.bEastDust then
          self.tSaveInfo.bEastDust = true
          Cin.PlayConversation("A1M0_Race_To_Saar_Passing")
        end
      elseif not tArgs[2] then
        print(" exited distance speeding javier up")
        print(" setting min speed ", PlayersSpeed + 10, " Max speed ", PlayersSpeed + 10)
        if not self.tSaveInfo.bEastDust then
          self.tSaveInfo.bEastDust = true
          Cin.PlayConversation("A1M0_Race_To_Saar_Passing")
        end
        Vehicle.SetRacerSpeed(tArgs[1], PlayersSpeed + 10, PlayersSpeed + 10)
      end
    end
  end
  print(" *** END CheckDistanceReallyClose *** ")
end

function Act_1_RaceToGermany:CheckDistanceReallyFar(tArgs)
  if self.tSaveInfo.RACESTATE <= 2 then
    return
  end
  print(" *** CheckDistanceFar ", tArgs)
  local PlayersSpeed
  local hSabCar = Actor.GetVehicle(hSab)
  if hSabCar then
    PlayersSpeed = Vehicle.GetSpeed(hSabCar)
    print("Players speed ", PlayersSpeed)
  end
  if tArgs then
    if tArgs[3] == true then
      print(" Javier is really far ahead")
      if tArgs[2] == true then
        print(" entered distance slowing javier down")
        print(" setting min speed ", 40, " Max speed ", 40)
        Vehicle.SetRacerSpeed(tArgs[1], 40, 40)
      elseif not tArgs[2] then
        print(" exited distance slowing javier down")
        print(" setting min speed ", 15, " Max speed ", 15)
        Vehicle.SetRacerSpeed(tArgs[1], 15, 15)
      end
    else
      print("Javier is really behind")
      print(" setting min speed ", 110, " Max speed ", 150)
      Vehicle.SetRacerSpeed(tArgs[1], 110, 150)
    end
  end
  print(" *** END CheckDistanceReallyFar *** ")
end

function Act_1_RaceToGermany:CheckWinner(tArgs)
  print("CheckWinner ", tArgs, hSab, Handle(self.tInfo.Javier), Handle(self.tInfo.RaceCar))
  if not self.tSaveInfo.FirstPlace and tArgs and tArgs[2] then
    self.tSaveInfo.FirstPlace = tArgs[2]
  end
  if self.tSaveInfo.FirstPlace then
    if self.tSaveInfo.FirstPlace ~= hSab then
      print("Javier wins...booooo")
      self:EndRace()
    else
      print("player won!!!")
    end
  end
end

function Act_1_RaceToGermany:Task_TaxiJules()
  local self = Act_1_RaceToGermany
  self:CreateTask({
    sName = "Task_TaxiJules",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "A1M0_Text.TASK_RaceToCheckpoint",
    sPickupTextID = "A1M0_Text.TASK_TaxiJules_Race",
    sVehicleReturnID = "GenericObjective_Text.Vehicle_GetInBack_A",
    sVehicleFetchID = "GenericObjective_Text.Vehicle_GetIn_The",
    sDropoffTextID = "A1M0_Text.TASK_RaceJavier",
    tDestLocators = {
      gsA12Germ .. "main\\LOC_FinishLine"
    },
    tPickupProxObj = {
      self.tInfo.Jules
    },
    PickupProximity = 60,
    tDestRegion = {
      gsA12Germ .. "main\\REG_FinishLine"
    },
    tDeliverObjs = {
      self.tInfo.Jules
    },
    bNoDumping = true,
    bGroundBlip = true,
    sRequiredVehicle = self.tInfo.Bugatti,
    tOnEarlyExit = {},
    tOnPickup = {
      {
        self.SetupRace,
        {self}
      }
    },
    tOnComplete = {
      {
        HUD.ClearWaypoint,
        {}
      },
      {
        self.CompleteRace,
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
        HUD.SetWaypoint,
        {
          1320,
          -2089,
          20
        }
      },
      {
        Nav.BoardVehicle,
        {
          Handle(self.tInfo.Jules),
          Handle(self.tInfo.Bugatti),
          "SHOTGUN",
          true
        }
      },
      {
        EVENT_ActorEntersAnyVehicle,
        {
          "Act_1_RaceToGermany.UnblipHim",
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

function Act_1_RaceToGermany:CompleteRace()
  print("race is over?")
  self:EndRace()
  self:SetupEndCin()
end

function Act_1_RaceToGermany:Task_TaxiJulesPostRace()
  local self = Act_1_RaceToGermany
  self:CreateTask({
    sName = "Task_TaxiJulesPostRace",
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
    tOnEarlyExit = {},
    tOnPickup = {},
    tOnComplete = {
      {
        self.TASK_GetPastCheckpoint,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Act_1_RaceToGermany:SetupEndCin()
  Render.FadeScreen(true)
  print("setupendcin")
  EVENT_Timer("Act_1_RaceToGermany.TeleportForCin", self, 1.5)
end

function Act_1_RaceToGermany:StreamJavierBody()
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      self.tInfo.JavierRaceOver
    },
    WaitForGameObject = true
  }
  Util.CreateEvent(tStreamEvent, "Act_1_RaceToGermany.SetupJavierForEndCin", self)
end

function Act_1_RaceToGermany:SetupJavierForEndCin()
  local hJavier = Handle(self.tInfo.JavierRaceOver)
  print("setup javier ", hJavier)
  Actor.BoardVehicle(hJavier, Handle(self.tInfo.RaceOverCar), "PILOT")
  Vehicle.LockAllSeats(Handle(self.tInfo.RaceOverCar), true)
end

function Act_1_RaceToGermany:TeleportForCin()
  print("TeleportForCin")
  self:UnloadTaskNodes("TASK_FatLoad3", true)
  local hLoc = Handle("Missions\\act_1\\racetogermany\\main\\LOC_TeleportSpot")
  local hCar = Actor.GetVehicle(hSab)
  if hLoc then
    if hCar then
      print("player is in a car")
      local x, y, z = Object.GetPosition(hLoc)
      local rot = Object.GetAngle(hLoc)
      Object.Teleport(hCar, x, y, z, rot)
      self:TASK_FatLoad4()
    else
      print("player is on foot")
      Object.PlayerTeleportToLocator(hLoc, false, "Act_1_RaceToGermany.TASK_FatLoad4", self)
    end
  else
    Util.Assert(false, "CFrench couldn't find loc to teleport to in Act_1_RaceToGermany.TeleportForCin ")
    print("CFrench couldn't find loc to teleport to in Act_1_RaceToGermany.TeleportForCin ", "Missions\\act_1\\racetogermany\\main\\LOC_TeleportSpot")
    self:TASK_FatLoad4()
  end
end

function Act_1_RaceToGermany:TASK_FatLoad4()
  self:CreateTask({
    sName = "TASK_FatLoad4",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      gsA12Germ .. "raceoverjavier"
    },
    tOnActivate = {
      {
        self.StreamJavierBody,
        {self}
      },
      {
        EVENT_Timer,
        {
          "Act_1_RaceToGermany.TASK_EndRaceCin",
          self,
          1.5
        }
      }
    },
    tOnComplete = {}
  })
end

function Act_1_RaceToGermany:TASK_EndRaceCin()
  self:CreateTask({
    sName = "TASK_EndRaceCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "A1M0_EndRace",
    tOnActivate = {
      {
        self.RaceOverDrivePaths,
        {self}
      }
    },
    tOnComplete = {
      {
        self.CleanupRaceOverDrive,
        {self}
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "Act_1_RaceToGermany.Checkpoint2"
        }
      }
    }
  })
end

function Act_1_RaceToGermany:TASK_EndRace()
  self:CreateTask({
    sName = "TASK_EndRace",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    tOnActivate = {
      {
        self.RaceOverDrivePaths,
        {self}
      }
    },
    tOnComplete = {
      {
        self.CleanupRaceOverDrive,
        {self}
      },
      {
        self.Task_TaxiJulesPostRace,
        {self}
      }
    }
  })
end

function Act_1_RaceToGermany:RaceOverDrivePaths()
  print("run paths")
  local hRaceCar = Handle(self.tInfo.RaceOverCar)
  local hJavier = Vehicle.GetPilot(hRaceCar)
  local hPlayerCar = Actor.GetVehicle(hSab)
  Nav.SetScriptedPath(hRaceCar, "Missions\\act_1\\racetogermany\\main\\PATH_Javier", true)
  Nav.SetScriptedPathSpeed(hRaceCar, 30)
  if hPlayerCar then
    Vehicle.SetForceAIController(hPlayerCar, true)
    Nav.SetScriptedPath(hPlayerCar, "Missions\\act_1\\racetogermany\\main\\PATH_Sean", true)
    Nav.SetScriptedPathSpeed(hPlayerCar, 33)
  end
end

function Act_1_RaceToGermany:CleanupRaceOverDrive()
  print("clean up ")
  local hRaceCar = Handle(self.tInfo.RaceOverCar)
  local hJavier = Vehicle.GetPilot(hRaceCar)
  local hPlayerCar = Actor.GetVehicle(hSab)
  if hPlayerCar then
    Vehicle.SetForceAIController(hPlayerCar, false)
  end
end

function Act_1_RaceToGermany:RaceFinishedConv()
  local self = Act_1_RaceToGermany
  print("RaceFinishedConv")
  if Act_1_RaceToGermany.tSaveInfo.FirstPlace == hSab then
    Cin.PlayConversation("A1M0_Race_To_Saar_End_Win")
  else
    Cin.PlayConversation("A1M0_Race_To_Saar_End_Lose")
  end
end

function Act_1_RaceToGermany:TASK_GetPastCheckpoint()
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

function Act_1_RaceToGermany:UnblipHim()
  SabTaskObjective.SetUIBlips(self, self.tInfo.Jules, false, true)
end

function Act_1_RaceToGermany:Task_TaxiJules2()
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
        Vehicle.EnableTraffic,
        {true}
      }
    }
  })
end

function Act_1_RaceToGermany:ReleaseTruck()
  self:FinishUp()
end

function Act_1_RaceToGermany:DumpHim()
  if Actor.IsInVehicle(hSab) then
    Actor.UnboardVehicle(hSab)
  end
end

function Act_1_RaceToGermany:FinishUp()
  self:CompleteThisMission()
end

function Act_1_RaceToGermany:Checkpoint2()
  print("__Checkpoint2")
  if self.tInfo.eFailCarTooFar then
    Util.KillEvent(self.tInfo.eFailCarTooFar)
    self.tInfo.eFailCarTooFar = nil
  end
  if not self:IsMissionTaskActive("Task_GoTo") then
    self:Task_GoTo()
  end
  self:Task_TaxiJulesPostRace()
  self:SetupPaperCheckpoint()
  Saboteur.ShowToolTip("TutorialTip_Text.World_Checkpoint_with_Papers")
  self:SetupConvosPart2()
  Suspicion.EnableEscalationVehicles(true)
  self.tSaveInfo.bRacing = false
end

function Act_1_RaceToGermany:TASK_Checkpoint2()
  self:CreateTask({
    sName = "TASK_Checkpoint2",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\racetogermany\\main\\REG_Checkpoint2",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Act_1_RaceToGermany.Checkpoint2"
        }
      }
    }
  })
end

function Act_1_RaceToGermany:SetupPaperCheckpoint()
  local tPaperEvent = {
    EventType = "OnPaperCheckPass",
    Target = hSab
  }
  self.tInfo.ePaperCheck = Util.CreateEvent(tPaperEvent, "Act_1_RaceToGermany.MyMindIsMush", self, {true})
  self:RegisterEvent(self.tInfo.ePaperCheck)
end

function Act_1_RaceToGermany:SetupGateSwitch()
  if self.tSaveInfo.bGotPastCP then
    return
  end
  if self:IsMissionTaskActive("Task_OpenGate") then
    self:ResetTaskByName("Task_OpenGate", true)
  end
  EVENT_Stream("Act_1_RaceToGermany.GateSwitchStreamed", self, {
    self.tInfo.CPGateSwitch
  })
end

function Act_1_RaceToGermany:SetupGateDoor()
  if self.tSaveInfo.bGotPastCP then
    return
  end
  EVENT_Stream("Act_1_RaceToGermany.GateDoorStreamed", self, {
    self.tInfo.CPGate
  })
end

function Act_1_RaceToGermany:GateSwitchStreamed()
  if self.tSaveInfo.bGotPastCP then
    return
  end
  EVENT_StreamOut("Act_1_RaceToGermany.SetupGateSwitch", self, {
    self.tInfo.CPGateSwitch
  })
  self:Task_OpenGate()
end

function Act_1_RaceToGermany:GateDoorStreamed()
  if self.tInfo.eGateDeath then
    Util.KillEvent(self.tInfo.eGateDeath)
  end
  if self.tSaveInfo.bGotPastCP then
    return
  end
  self.tInfo.eGateDeath = EVENT_ActorDeath("Act_1_RaceToGermany.GateDestroyed", self, self.tInfo.CPGate)
  EVENT_StreamOut("Act_1_RaceToGermany.SetupGateDoor", self, {
    self.tInfo.CPGate
  })
end

function Act_1_RaceToGermany:GateDestroyed()
  self:MyMindIsMush({}, true)
end

function Act_1_RaceToGermany:Task_OpenGate()
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

function Act_1_RaceToGermany:SetGateStatus()
  self.tSaveInfo.bGateOpen = true
end

function Act_1_RaceToGermany:MyMindIsMush(tArgs, bGateOpen)
  print("wthf ", bGateOpen, sadtimes)
  if (self.tSaveInfo.bGateOpen or bGateOpen) and self:IsMissionTaskActive("Task_TaxiJulesPostRace") then
    self:CompleteTaskByName("Task_TaxiJulesPostRace")
    self:CompleteTaskByName("TASK_GetPastCheckpoint")
  elseif self:IsMissionTaskActive("TASK_GetPastCheckpoint") then
    self:CompleteTaskByName("TASK_GetPastCheckpoint")
  elseif self:IsMissionTaskActive("Task_TaxiJulesPostRace") then
    self:CompleteTaskByName("Task_TaxiJulesPostRace")
  end
end

function Act_1_RaceToGermany:SwitchObjective(task, bUpdate)
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

function Act_1_RaceToGermany:SetupConvosPart1()
  EVENT_PlayerTriggersConv(self, "Missions\\act_1\\racetogermany\\main\\REG_Cows", "A1M0_Race_To_Saar_Cows")
  EVENT_PlayerTriggersConv(self, "Missions\\act_1\\racetogermany\\main\\REG_HitCows", "A1M0_Race_To_Saar_Hit_Cow")
  EVENT_PlayerTriggersConv(self, "Missions\\act_1\\racetogermany\\main\\REG_PreJump", "A1M0_Race_To_Saar_Jump")
  EVENT_PlayerTriggersConv(self, "Missions\\act_1\\racetogermany\\main\\REG_JumpDone", "A1M0_Race_To_Saar_After_Jump")
  EVENT_PlayerTriggersConv(self, "Missions\\act_1\\racetogermany\\main\\REG_NearFinish", "A1M0_Race_To_Saar_Near_Finish")
  EVENT_PlayerEntersTrigger("Act_1_RaceToGermany.StartTrain01", self, "Missions\\act_1\\racetogermany\\main\\REG_SpawnTrain", false)
  EVENT_PlayerEntersTrigger("Act_1_RaceToGermany.ClampSpeed", self, "Missions\\act_1\\racetogermany\\main\\REG_SpawnTrain", false)
end

function Act_1_RaceToGermany:ClampSpeed()
  print("clamp Speed")
  self.tSaveInfo.bClampSpeed = true
end

function Act_1_RaceToGermany:StartTrain01()
  print("spawn train")
  Train.TrainCreate("Missions\\act_1\\racetogermany\\german_border\\TrainTracker", "Dtrain3")
  Train.TrainSetMaxSpeed("Missions\\act_1\\racetogermany\\german_border\\TrainTracker", "28")
end

function Act_1_RaceToGermany:SetupConvosPart2()
  self:TASK_Convo_Truck_Drive02()
  EVENT_PlayerTriggersConv(self, "Missions\\act_1\\racetogermany\\main\\REG_Convo_Truck_Border", "103_InG_Truck-Border")
  EVENT_PlayerTriggersConv(self, "Missions\\act_1\\racetogermany\\main\\REG_Convo_Truck_Drive01", "103_InG_Truck-Drive01")
end

function Act_1_RaceToGermany:TASK_Convo_Truck_Drive02()
  self:CreateTask({
    sName = "TASK_Convo_Truck_Drive02",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\racetogermany\\main\\REG_Convo_Truck_Drive02",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Convo_Truck_Drive02,
        {self}
      }
    }
  })
end

function Act_1_RaceToGermany:TASK_Convo_Truck_Drive03()
  self:CreateTask({
    sName = "TASK_Convo_Truck_Drive03",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\racetogermany\\main\\REG_Convo_Truck_Drive03",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.PlayConversation,
        {
          self,
          "103_InG_Truck-Drive03"
        }
      }
    }
  })
end

function Act_1_RaceToGermany:TASK_ConvGetGoing()
  self:CreateTask({
    sName = "TASK_ConvGetGoing",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\racetogermany\\main\\REG_GetGoing",
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

function Act_1_RaceToGermany:SetupGetGoingConv()
  self.tInfo.eGetGoing = EVENT_Timer("Act_1_RaceToGermany.GetGoingConv", self, 30)
  self.tSaveInfo.bGetGoing = true
end

function Act_1_RaceToGermany:GetGoingConv()
  if self.tSaveInfo.bGetGoing then
    Cin.PlayConversation("A1M0_GetToTrack_Reminder")
    self.tInfo.eGetGoing = EVENT_Timer("Act_1_RaceToGermany.GetGoingConv", self, 45)
  end
end

function Act_1_RaceToGermany:ClearGetGoing()
  self.tSaveInfo.bGetGoing = false
  if self.tInfo.eGetGoing then
    Util.KillEvent(self.tInfo.eGetGoing)
    self.tInfo.eGetGoing = nil
  end
end

function Act_1_RaceToGermany:Convo_GetIn()
  Cin.PlayConversation("A1M0_Taxi_GetIn")
end

function Act_1_RaceToGermany:VehicleEnterTut()
  EVENT_ActorToActorProximity("Act_1_RaceToGermany.VehicleEnterTutFIRE", self, self.tInfo.Bugatti, hSab, 6)
end

function Act_1_RaceToGermany:VehicleEnterTutFIRE()
end

function Act_1_RaceToGermany:HandBreakTut()
  EVENT_Timer("Act_1_RaceToGermany.HandBreakTutFire", self, 40)
end

function Act_1_RaceToGermany:HandBreakTutFire()
end

function Act_1_RaceToGermany:PlayConversation(sConvFile)
  Cin.PlayConversation(sConvFile)
end

function Act_1_RaceToGermany:Convo_Truck_Drive02()
  Cin.PlayConversation("103_InG_Truck-Drive02", "Act_1_RaceToGermany.TASK_Convo_Truck_Drive03", self, {})
end

function Act_1_RaceToGermany:TASK_GPSSwitch()
  self:CreateTask({
    sName = "TASK_GPSSwitch",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDestRegion = "Missions\\act_1\\racetogermany\\main\\REG_GPSSwitch",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        HUD.ClearWaypoint,
        {}
      }
    }
  })
end

function Act_1_RaceToGermany:FailEvent()
  self.tInfo.eFailJulesTooFar = EVENT_PlayerToActorProximityNegated("Act_1_RaceToGermany.FailJulesTooFar", self, Util.GetHandleByName(self.tInfo.Jules), 120, {
    "GenericFail_Text.ABANDON_Jules"
  })
  self.tInfo.eFailCarTooFar = EVENT_PlayerToActorProximityNegated("Act_1_RaceToGermany.FailCarTooFar", self, Util.GetHandleByName(self.tInfo.Bugatti), 120, {
    "A1M0_Text.FAIL_OutofTime"
  })
  self.tInfo.eCarDeath = EVENT_ActorDeath("Act_1_RaceToGermany.FailCarDead", self, Util.GetHandleByName(self.tInfo.Bugatti), {
    "GenericFail_Text.DESTROYED_Aurora"
  })
  EVENT_PlayerExitsTrigger("Act_1_RaceToGermany.FailWarning", self, "Missions\\act_1\\racetogermany\\main\\REG_OffPathWarning")
  self.i0 = 0
  self.i1 = 0
  self.i2 = 0
  self.i3 = 0
  self.i4 = 0
end

function Act_1_RaceToGermany:PlayDamageVO()
  local truckhealth = Object.GetHealth(Handle(self.tInfo.Bugatti))
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

function Act_1_RaceToGermany:FailJulesTooFar(sFailString)
  Cin.PlayConversation("A1M0_Taxi_Abandoned", "Act_1_RaceToGermany.Fail", self, {sFailString})
end

function Act_1_RaceToGermany:FailCarTooFar(sFailString)
  Cin.PlayConversation("A1M0_Taxi_AbandonedVehicle", "Act_1_RaceToGermany.Fail", self, {sFailString})
end

function Act_1_RaceToGermany:FailJulesDead(sFailString)
  Cin.PlayConversation("A1M0_Taxi_JulesDeath", "Act_1_RaceToGermany.Fail", self, {sFailString})
end

function Act_1_RaceToGermany:FailCarDead(sFailString)
  if not self.tSaveInfo.bCarfail then
    self.tSaveInfo.bCarfail = true
    Cin.PlayConversation("A1M0_VehicleDamage_Destroyed", "Act_1_RaceToGermany.Fail", self, {sFailString})
  end
end

function Act_1_RaceToGermany:FailWarning()
  Cin.PlayConversation("A1M0_TooFar_Warning")
end

function Act_1_RaceToGermany:FailCarOffPath()
  Cin.PlayConversation("A1M0_TooFar_Fail", "Act_1_RaceToGermany.Fail", self, {
    "A1M0_Text.FAIL_WrongWay"
  })
end

function Act_1_RaceToGermany:Fail(tArgs, sFailString)
  print("fail events fire off ", sFailString)
  local sFS = sFailString or "A1M0_Text.FAIL_OutofTime"
  self:MissionTaskFail(sFS)
end
