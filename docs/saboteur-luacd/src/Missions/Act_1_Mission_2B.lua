if Act_1_Mission_2B == nil then
  Act_1_Mission_2B = SabTaskObjective:Create()
  Act_1_Mission_2B:Configure({
    TaskCount = 999,
    bStarterless = true,
    MCDisplayID = 2,
    bForceUnloadNodes = true,
    tUnlockList = {
      "Connect_ST_109_SkylarSex"
    },
    sSaveMissionNameID = "MissionNames_Text.A1M2B",
    bSLOverrideFade = true,
    tMissionBPVictims = {
      "VH_CV_CR_AlfaRomera_01",
      "VH_CV_CR_Allard_01"
    },
    tDeleteNodes = {
      "Missions\\act_1\\connecttohotel\\deletenode"
    },
    tSMEDNodes = {}
  })
end

function Act_1_Mission_2B:STARTER_Setup()
  Render.SetGlobalWTF(true)
  Util.SetTime(21, 0)
  Util.EnableSuperSpores(false)
  Render.FadeScreen(true)
  Cin.LoadCinematic("107_CinB_Skylar")
end

function Act_1_Mission_2B:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self:Task_ExitRedOx()
end

function Act_1_Mission_2B:BinkDone()
  self.bBinkDone = true
  if self.bLoadDone == true then
    EVENT_Timer("Act_1_Mission_2B.FadeInAfterCin", self, 2.3)
  end
end

function Act_1_Mission_2B:GENERAL_Setup()
  Vehicle.EnableTraffic(false, true)
  self.tInfo.sSkylar = "Missions\\act_1\\connecttohotel\\107_cinb\\Skylar"
  self.tInfo.sJules = "Missions\\act_1\\connecttohotel\\107_cinb\\Jules"
  self.tInfo.sChaseGrunt2 = "Missions\\act_1\\connecttohotel\\main\\ChaserGrunt2"
  self.tInfo.sChaserCar = "Missions\\act_1\\connecttohotel\\main\\ChaserCar"
  self.tInfo.sSkylarsCar = "Missions\\act_1\\connecttohotel\\107_cinb\\VH_CV_CR_Skylar_01_3Seat(1)"
  self.tInfo.sChaseKubel1 = "Missions\\act_1\\connecttohotel\\107_cinb\\VH_NZ_CR_Kubelwagen_A(1)"
  self.tInfo.sChaseKubel2 = "Missions\\act_1\\connecttohotel\\107_cinb\\VH_NZ_CR_Kubelwagen_B(1)"
  self.tInfo.sHotelLoc = "Missions\\act_1\\connecttohotel\\main\\HotelPointLoc"
  self.tInfo.sHotelTrig = "Missions\\act_1\\connecttohotel\\main\\HotelTrig"
  self.tInfo.sJulesExitPath = "Missions\\act_1\\connecttohotel\\main\\JulesExitPath"
  self.tInfo.SuspicionCircle = "Missions\\act_1\\connecttohotel\\main\\LOC_SusCircle"
  self.tInfo.sStaticKubel = "Missions\\act_1\\connecttohotel\\107_cinb\\VH_NZ_CR_Kubelwagen_Static"
  self.tInfo.sCGMidClassCiv = "Missions\\act_1\\connecttohotel\\107_cinb\\Spore_CG_MiddleClass_M(1)"
  self.tInfo.sLowClassFem1 = "Missions\\act_1\\connecttohotel\\107_cinb\\Spore_CV_LowerClass_F(3)"
  self.tInfo.sLowClassFem2 = "Missions\\act_1\\connecttohotel\\107_cinb\\Spore_CV_LowerClass_F(4)"
  self.tInfo.sLowClassFem3 = "Missions\\act_1\\connecttohotel\\107_cinb\\Spore_CV_LowerClass_F(5)"
  self.tInfo.sLowClassMale1 = "Missions\\act_1\\connecttohotel\\107_cinb\\Spore_CV_LowerClass_M(3)"
  self.tInfo.sLowClassMale2 = "Missions\\act_1\\connecttohotel\\107_cinb\\Spore_CV_LowerClass_M(4)"
  self.tInfo.sLowClassMale3 = "Missions\\act_1\\connecttohotel\\107_cinb\\Spore_CV_LowerClass_M(5)"
  self.tInfo.sNZOfficer1 = "Missions\\act_1\\connecttohotel\\107_cinb\\Spore_WM_Officer_PS(4)"
  self.tInfo.sNZOFficer2 = "Missions\\act_1\\connecttohotel\\107_cinb\\Spore_WM_Officer_PS(5)"
  self.tInfo.sNZOfficer3 = "Missions\\act_1\\connecttohotel\\107_cinb\\Spore_WM_Officer_PS(6)"
  self.tInfo.sNZOfficer4 = "Missions\\act_1\\connecttohotel\\107_cinb\\Spore_WM_Officer_PS(7)"
  self.tInfo.tCineLoadingItems = {
    self.tInfo.sSkylarsCar,
    self.tInfo.sChaseKubel1,
    self.tInfo.sChaseKubel2,
    self.tInfo.sSkylar,
    self.tInfo.sJules,
    self.tInfo.sStaticKubel,
    self.tInfo.sCGMidClassCiv,
    self.tInfo.sLowClassFem1,
    self.tInfo.sLowClassFem2,
    self.tInfo.sLowClassFem3,
    self.tInfo.sLowClassMale1,
    self.tInfo.sLowClassMale2,
    self.tInfo.sLowClassMale3,
    self.tInfo.sNZOfficer1,
    self.tInfo.sNZOFficer2,
    self.tInfo.sNZOfficer3,
    self.tInfo.sNZOfficer4
  }
  self.tInfo.tLoadingItems = {
    self.tInfo.sSkylarsCar,
    self.tInfo.sChaseKubel1,
    self.tInfo.sChaseKubel2,
    self.tInfo.sSkylar,
    self.tInfo.sJules,
    self.tInfo.sStaticKubel,
    self.tInfo.sCGMidClassCiv,
    self.tInfo.sLowClassFem1,
    self.tInfo.sLowClassFem2,
    self.tInfo.sLowClassFem3,
    self.tInfo.sLowClassMale1,
    self.tInfo.sLowClassMale2,
    self.tInfo.sLowClassMale3,
    self.tInfo.sNZOfficer1,
    self.tInfo.sNZOFficer2,
    self.tInfo.sNZOfficer3,
    self.tInfo.sNZOfficer4
  }
  self.tSaveInfo.bRepeater = false
  self.tSaveInfo.bDeEscRepeater = false
  self.tInfo.tStreamUs = {
    self.tInfo.sSkylarsCar,
    self.tInfo.sSkylar,
    self.tInfo.sJules
  }
  self.tSaveInfo.bIsFirstDamage = true
  self.tSaveInfo.Reminder = 1
  self.tSaveInfo.Conversation = {}
end

function Act_1_Mission_2B:MISSION_ONRESET()
  Util.EnableSuperSpores(true)
  Sound.ReleaseSoundBank("m_A1M2b_inGame.bnk")
  Sound.ResetMusicLocale()
  if not Vehicle.IsTrafficEnabled() then
    Vehicle.EnableTraffic(true)
  end
  if self.SusZoneID then
    Suspicion.KillSuspicionRadius(self.SusZoneID)
    self.SusZoneID = nil
  end
  Suspicion.EnableEscalation(true)
  Actor.SetCannotGetOutOfSeat(hSab, false)
end

function Act_1_Mission_2B:Task_ExitRedOx()
  self:CreateTask({
    sName = "Task_ExitRedOx",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "RedOx",
    bInteriorTask = true,
    tOnActivate = {
      {
        self.InteriorCheck,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TASK_LoadMain,
        {self}
      }
    }
  })
end

function Act_1_Mission_2B:DisableTraffic()
  if Vehicle.IsTrafficEnabled() then
    print("traffic is enabled")
    Vehicle.EnableTraffic(false, true)
  end
end

function Act_1_Mission_2B:TASK_SkylarSavesCine()
  self:CreateTask({
    sName = "TASK_SkylarSavesCine",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "107_CinB_Skylar",
    bOverrideFade = true,
    tOnActivate = {
      {
        self.DisableTraffic,
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
          "Act_1_Mission_2B.CheckPoint1",
          "Act_1_Mission_2B.CheckPoint1_Alpha",
          true
        }
      }
    },
    tCinematicNodes = {
      "107_cinb_skylar"
    }
  })
end

function Act_1_Mission_2B:InteriorCheck()
  if InteriorManager.GetPlayersInterior() == "RedOx" then
    print("player is in ", InteriorManager.GetPlayersInterior())
    InteriorManager.ExitInterior("RedOx", "CountrySide\\alsace\\town\\interior\\redox_ext\\LOC_RO_Ext(2)")
  end
end

function Act_1_Mission_2B:WaitForStream()
  local tStreamKickoff = {
    EventType = "StreamEvent",
    EventName = "InitialLoad",
    Objects = self.tInfo.tStreamUs,
    WaitForGameObject = true,
    WaitForPhysics = true
  }
  local eEvent = Util.CreateEvent(tStreamKickoff, "Act_1_Mission_2B.TASK_SkylarSavesCine", self)
  self:RegisterEvent(eEvent)
end

function Act_1_Mission_2B:PrepThePlayers()
  Object.SetInvincible(Handle(self.tInfo.sSkylar), true)
  Object.SetInvincible(Handle(self.tInfo.sJules), true)
  Actor.BoardVehicle(Handle(self.tInfo.sSkylar), Handle(self.tInfo.sSkylarsCar), "MIDDLE", true)
  Actor.BoardVehicle(hSab, Handle(self.tInfo.sSkylarsCar), "PILOT", true)
  Actor.BoardVehicle(Handle(self.tInfo.sJules), Handle(self.tInfo.sSkylarsCar), "SHOTGUN", true)
  EVENT_Timer("Act_1_Mission_2B.LoadGestapoInCars", self, 1.5)
  self.bLoadDone = true
  EVENT_Timer("Act_1_Mission_2B.FadeInAfterCin", self, 2.3)
end

function Act_1_Mission_2B:LoadGestapoInCars()
  local hNazi1 = Handle("Missions\\act_1\\connecttohotel\\107_cinb\\Spore_WM_Officer_PS(4)")
  local hNazi2 = Handle("Missions\\act_1\\connecttohotel\\107_cinb\\Spore_WM_Officer_PS(5)")
  local hNazi3 = Handle("Missions\\act_1\\connecttohotel\\107_cinb\\Spore_WM_Officer_PS(6)")
  local hNazi4 = Handle("Missions\\act_1\\connecttohotel\\107_cinb\\Spore_WM_Officer_PS(7)")
  Actor.BoardVehicle(hNazi1, Handle(self.tInfo.sChaseKubel1), "PILOT", true)
  Actor.BoardVehicle(hNazi2, Handle(self.tInfo.sChaseKubel2), "PILOT", true)
  Actor.BoardVehicle(hNazi3, Handle(self.tInfo.sChaseKubel1), "SHOTGUN", true)
  Actor.BoardVehicle(hNazi4, Handle(self.tInfo.sChaseKubel2), "SHOTGUN", true)
end

function Act_1_Mission_2B:FadeInAfterCin()
  Util.EnableSuperSpores(true)
  self:FadeScreen(false)
  Actor.SetCannotGetOutOfSeat(hSab, true)
  self:SetupPostCinNazis()
  self:SetupCarFail()
  self:TASK_Taxi()
  local hGWB = Handle("Missions\\act_1\\connecttohotel\\107_cinb\\VH_NZ_CR_Kubelwagen_Static(1)")
  if hGWB then
    Vehicle.UnboardAll(hGWB, false, "Act_1_Mission_2B.CallbackAggroPassenger", self, nil, nil)
  end
end

function Act_1_Mission_2B:CallbackAggroPassenger(tNazi)
  if tNazi and tNazi[1] and Object.IsAlive(tNazi[1]) then
    print("aggro gestapo ", tNazi[1])
    Combat.SetIdleScripted(tNazi[1], true)
    Combat.SetTarget(tNazi[1], hSab)
    Combat.SetCombat(tNazi[1])
  end
end

function Act_1_Mission_2B:FadeScreen(bFadeOut)
  Render.FadeScreen(bFadeOut)
end

function Act_1_Mission_2B:CheckPoint1_Alpha()
  print("CheckPoint1_Alpha")
  self.bBinkDone = false
  self.bLoadDone = false
  self:PrepThePlayers()
  Vehicle.EnableTraffic(true)
  Sound.LoadSoundBank("m_A1M2b_inGame.bnk")
  self.tSaveInfo.Conversation = {}
  self.SusZoneID = Suspicion.SetupSuspicionRadius(Handle(self.tInfo.SuspicionCircle), 30)
end

function Act_1_Mission_2B:CheckPoint1()
  print("__CheckPoint1")
  self.bBinkDone = false
  self.bLoadDone = false
  Suspicion.EnableEscalation(true)
  self:PrepThePlayers()
  self:FadeScreen(true)
  self.tSaveInfo.Conversation = {}
  self.SusZoneID = Suspicion.SetupSuspicionRadius(Handle(self.tInfo.SuspicionCircle), 30)
end

function Act_1_Mission_2B:TASK_LoadMain()
  self:CreateTask({
    sName = "TASK_LoadMain",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bCompleteOnActivate = true,
    tSMEDNodes = {
      "Missions\\act_1\\connecttohotel\\main",
      "Missions\\act_1\\connecttohotel\\107_cinb"
    },
    tOnActivate = {
      {
        self.WaitForStream,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Act_1_Mission_2B:SetupPostCinNazis()
  self.tInfo.nSkyCarHealth = Object.GetHealth(Handle(self.tInfo.sSkylarsCar))
  Suspicion.SetEscalated()
  Vehicle.SetCanJoinEscalation(Handle(self.tInfo.sChaseKubel1), true)
  Vehicle.SetCanJoinEscalation(Handle(self.tInfo.sChaseKubel2), true)
  Combat.SetIdleDisperse(Handle("Missions\\act_1\\connecttohotel\\107_cinb\\Spore_WM_Officer_PS(9)"), true)
  Combat.SetIdleDisperse(Handle("Missions\\act_1\\connecttohotel\\107_cinb\\Spore_GS_Heavy"), true)
  Combat.SetIdleDisperse(Handle("Missions\\act_1\\connecttohotel\\107_cinb\\Spore_GS_Officer_1"), true)
  Sound.SetMusicLocale("A1M2b_MeetSkylar")
  Sound.SetMusicLocale("m_A1M2b_MeetSkylar", "Drive")
  local hNaziCar = Handle(self.tInfo.sChaserCar)
  if hNaziCar then
    print("nazi chaser joining escalation")
    Vehicle.SetCanJoinEscalation(hNaziCar, true)
  end
end

function Act_1_Mission_2B:TASK_Taxi()
  self:CreateTask({
    sName = "TASK_Taxi",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "A1M2B_Text.TASK_GoToHotel",
    sEscalationID = "A1M2B_Text.TASK_DeEscalateNOW",
    sDropoffTextID = "A1M2B_Text.TASK_GoToHotel",
    Proximity = 3,
    tDestLocators = {
      self.tInfo.sHotelLoc
    },
    bEscalationDenial = true,
    tDestRegion = {
      self.tInfo.sHotelTrig
    },
    tDeliverObjs = {
      Handle(self.tInfo.sSkylar),
      Handle(self.tInfo.sJules)
    },
    tPickupProxObj = {
      Handle(self.tInfo.sSkylar)
    },
    bGroundBlip = true,
    bNoDumping = true,
    sRequiredVehicle = self.tInfo.sSkylarsCar,
    tOnEarlyExit = {},
    tOnPickup = {
      {
        self.FireDriveConvo,
        {self}
      },
      {
        Saboteur.ShowToolTip,
        {
          "TutorialTip_Text.Escalation_Escape"
        }
      }
    },
    tOnComplete = {
      {
        Common.StopVehicle,
        {
          self.tInfo.sSkylarsCar,
          bControl
        }
      },
      {
        self.TimetoGetRidOfThisParty,
        {self}
      }
    },
    tOnEscalationClear = {
      {
        self.OnEscalationClear,
        {self}
      }
    },
    tOnEscalation = {
      {
        self.OnEscalation,
        {self}
      }
    },
    tOnCancel = {}
  })
end

function Act_1_Mission_2B:FireDriveConvo()
  self:PlayConversation("108_InG_Chase-Drive01", true)
  self:CarDamageListener()
end

function Act_1_Mission_2B:OnEscalationClear()
  if self.tSaveInfo.Reminder == 1 then
    EVENT_PlayConversationDelayed("A1M2b_Hotel_Reminder01", 120, self)
    EVENT_PlayConversationDelayed("A1M2b_Hotel_Reminder03", 200, self)
    self.tSaveInfo.Reminder = self.tSaveInfo.Reminder + 1
  elseif self.tSaveInfo.Reminder == 2 then
    EVENT_PlayConversationDelayed("A1M2b_Hotel_Reminder03", 40, self)
  end
  if not self.tSaveInfo.bRepeater then
    self:PlayConversation("108_InG_Chase-Evaded", true)
    self.tSaveInfo.bRepeater = true
  elseif self.tSaveInfo.bRepeater and self:GetConvPlaying() ~= "108_InG_Chase-Drive01" then
    self:PlayConversation("A1M2b_Descalation_Again", true)
  end
end

function Act_1_Mission_2B:ToggleConvoEsc()
  self.tSaveInfo.bIsDeEscalating = false
end

function Act_1_Mission_2B:OnEscalation()
  print("on escalation", self.tSaveInfo.bDeEscRepeater)
  if not self.tSaveInfo.bDeEscRepeater then
    self.tSaveInfo.bDeEscRepeater = true
  elseif self:GetConvPlaying() ~= "108_InG_Chase-Drive01" then
    self:PlayConversation("A1M2b_Escalation_Again", true)
  end
end

function Act_1_Mission_2B:TimetoGetRidOfThisParty()
  if self.tSaveInfo.eExitEarly then
    Util.KillEvent(self.tSaveInfo.eExitEarly)
    self.tSaveInfo.eExitEarly = nil
  end
  if self.tSaveInfo.eExitEarlyJules then
    Util.KillEvent(self.tSaveInfo.eExitEarlyJules)
    self.tSaveInfo.eExitEarlyJules = nil
  end
  Suspicion.EnableEscalation(false)
  EVENT_Timer("Act_1_Mission_2B.FireFinalConvo", self, 1)
  EVENT_Timer("Act_1_Mission_2B.JulesExitsCar", self, 2)
end

function Act_1_Mission_2B:JulesExitsCar()
  Object.SetInvincible(Handle(self.tInfo.sJules), true)
  Actor.UnboardVehicle(Handle(self.tInfo.sJules))
  EVENT_Timer("Act_1_Mission_2B.JulesExitRight", self, 2.5)
end

function Act_1_Mission_2B:JulesExitRight()
  Nav.SetScriptedPath(Handle(self.tInfo.sJules), self.tInfo.sJulesExitPath, false)
end

function Act_1_Mission_2B:JulesWalkAway()
  self = Act_1_Mission_2B
end

function Act_1_Mission_2B:SeanUnboard()
  Actor.SetCannotGetOutOfSeat(hSab, false)
  Actor.UnboardVehicle(hSab)
end

function Act_1_Mission_2B:FireFinalConvo()
  local currentconv = self:GetConvPlaying()
  if currentconv then
    Cin.StopConversation(currentconv)
  end
  Cin.PlayConversation("108_InG_Chase-AtHotel", "Act_1_Mission_2B.EndThisMission", self)
end

function Act_1_Mission_2B:EndThisMission()
  Suspicion.EnableEscalation(true)
  EVENT_Timer("Act_1_Mission_2B.FadeScreen", self, 1.75, true)
  EVENT_Timer("Act_1_Mission_2B.SeanUnboard", self, 2.5)
  EVENT_Timer("SabTaskObjective.CompleteThisMission", self, 3)
end

function Act_1_Mission_2B:CarDamageListener()
  local tSkyCarDam = {
    EventType = "DamageEvent",
    ObjectHandle = Handle(self.tInfo.sSkylarsCar),
    MinDamage = 40
  }
  local eEvent = Util.CreateEvent(tSkyCarDam, "Act_1_Mission_2B.OnCarDamaged", self, true)
  self:RegisterEvent(eEvent)
end

function Act_1_Mission_2B:OnCarDamaged()
  if self.bIsFirstDamage == true then
    if not self:GetConvPlaying() then
      Cin.PlayConversation("A1M2b_VehicleDamage_First")
      print("Conversation: A1M2b_VehicleDamage_First")
    end
    self.tSaveInfo.bIsFirstDamage = false
  elseif self.tSaveInfo.bIsFirstDamage == false then
    local nRandomizer = math.random(1, 3)
    local nCurrentCarHealth = Object.GetHealth(self.SkyCar)
    local nCurrentPercent = nCurrentCarHealth / self.tInfo.nSkyCarHealth * 100
    if nRandomizer == 3 then
      if 75 <= nCurrentPercent and nCurrentPercent < 100 then
        if not self:GetConvPlaying() then
          Cin.PlayConversation("A1M2b_VehicleDamage_75")
          print("Conversation: A1M2b_VehicleDamage_75")
        end
      elseif 50 <= nCurrentPercent and nCurrentPercent < 75 then
        if not self:GetConvPlaying() then
          Cin.PlayConversation("A1M2b_VehicleDamage_50")
          print("Conversation: A1M2b_VehicleDamage_50")
        end
      elseif 25 <= nCurrentPercent and nCurrentPercent < 50 then
        if not self:GetConvPlaying() then
          Cin.PlayConversation("A1M2b_VehicleDamage_25")
          print("Conversation: A1M2b_VehicleDamage_25")
        end
      elseif 10 <= nCurrentPercent and nCurrentPercent < 25 then
        if not self:GetConvPlaying() then
          Cin.PlayConversation("A1M2b_VehicleDamage_Burning")
          print("Conversation: A1M2b_VehicleDamage_Burning")
        end
      elseif 0.5 <= nCurrentPercent and nCurrentPercent < 10 and not self:GetConvPlaying() then
        Cin.PlayConversation("A1M2b_VehicleDamage_Destroyed")
        print("Conversation: A1M2b_VehicleDamage_Destroyed")
      end
    end
  end
end

function Act_1_Mission_2B:SetupCarFail()
  EVENT_ActorDeath("Act_1_Mission_2B.CarDeath", self, Handle(self.tInfo.sSkylarsCar))
  self.tSaveInfo.eExitEarly = EVENT_PlayerExitsAnyVehicle("Act_1_Mission_2B.CallbackPulledFromVehicle", self)
  self.tSaveInfo.eExitEarlyJules = EVENT_ActorExitsAnyVehicle("Act_1_Mission_2B.CallbackPulledFromVehicle", self, self.tInfo.sJules)
end

function Act_1_Mission_2B:CallbackPulledFromVehicle()
  EVENT_Timer("Act_1_Mission_2B.PulledFromVehicle", self, 2)
end

function Act_1_Mission_2B:PulledFromVehicle()
  self:MissionTaskFail("A1M2B_Text.FAIL_Caught")
end

function Act_1_Mission_2B:CarDeath()
  self:MissionTaskFail("A1M2B_Text.FAIL_CarDeath")
end

function Act_1_Mission_2B:GetConvPlaying()
  for conv, bplaying in pairs(self.tSaveInfo.Conversation) do
    if bplaying then
      return conv
    end
  end
end

function Act_1_Mission_2B:PlayConversation(conv, bStopCurrent)
  local currentconv = self:GetConvPlaying()
  if currentconv and bStopCurrent then
    Cin.StopConversation(currentconv)
    print("Stopping Conversation: ", currentconv)
    self:SetConvDone({}, currentconv)
  elseif currentconv then
    print("Cannot play conv: ", conv, " current playing conv is: ", currentconv)
    return
  end
  print("Conversation: ", conv)
  Cin.PlayConversation(conv, "Act_1_Mission_2B.SetConvDone", self, {conv})
  self.tSaveInfo.Conversation[conv] = true
end

function Act_1_Mission_2B:SetConvDone(tArgs, conv)
  print("Conv Finished ", conv)
  if conv and self.tSaveInfo.Conversation[conv] then
    self.tSaveInfo.Conversation[conv] = false
  end
end
