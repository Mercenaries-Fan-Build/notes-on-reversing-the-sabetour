if P3FP_BiggerGun == nil then
  P3FP_BiggerGun = SabTaskObjective:Create()
  P3FP_BiggerGun.sPATH = "Missions\\freeplay\\p3\\mis_panth_biggergun\\"
  P3FP_BiggerGun:Configure({
    TaskCount = 99,
    sStarter = "Kwong_Ctown",
    bFreeplay = true,
    sSaveMissionNameID = "MissionNames_Text.P3FP_BiggerGun",
    sActNameID = "MissionNames_Text.ACT_DrKwong",
    tUnlockList = {},
    sConvFile = "P3FP_BiggerGun_Start",
    tSMEDNodes = {
      P3FP_BiggerGun.sPATH .. "main",
      P3FP_BiggerGun.sPATH .. "wtf_low\\spores"
    },
    tCinematicNodes = {
      "wtf_fp_pantheon"
    }
  })
end

function P3FP_BiggerGun:STARTER_Setup()
end

function P3FP_BiggerGun:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "BiggerGun"
  self.bDebugMode = false
  Sound.LoadSoundBank("m_fp_P3FP_PantheonGun.bnk")
  dprint(self, "Running BiggerGun.")
  self.SetupCheckpoint(self, 4)
end

function P3FP_BiggerGun:GENERAL_Setup()
end

function P3FP_BiggerGun:SetupVariables()
  self.hSab = self.hSab or Handle("Saboteur")
  self.sPantheonLoc = self.sPantheonLoc or self.sPATH .. "main\\LOC_PantheonLoc"
  self.sPantheonTrig = self.sPantheonTrig or self.sPATH .. "main\\TRIG_PantheonTrig"
  self.sBigGun = self.sBigGun or self.sPATH .. "gun_alive\\MN_Pantheon_Dome_Gun\\MN_Pantheon_Dome_Gun_Mount"
  self.sMedGun = self.sMedGun or self.sPATH .. "wtf_low\\back_extras\\SmallerGun\\OccMed_105mm_Mount"
  self.sBGSee = self.sBGSee or self.sPATH .. "main\\LOC_BGSee"
  self.sGearTrig = self.sGearTrig or self.sPATH .. "pantheon_interior\\TRIG_LookGears"
  self.sWatchExpTrig = self.sWatchExpTrig or self.sPATH .. "main\\TRIG_WatchExplosion"
  self.sStopExpTrig = self.sStopExpTrig or self.sPATH .. "main\\TRIG_StopWatchExplosion"
  self.bPlantedOnGun = self.bPlantedOnGun or false
  self.sEnterPanthLoc = self.sEnterPanthLoc or self.sPATH .. "main\\LOC_EnterPantheon"
  self.sExitPanthLoc = self.sExitPanthLoc or self.sPATH .. "pantheon_interior\\LOC_ExitPantheonTop"
  self.sExtElevator = self.sExtElevator or "PARIS\\area05\\pantheon\\buildings\\MN_Pantheon_Interior_Elevator_B_AO"
  self.sBigGunDestroyLoc = self.sBigGunDestroyLoc or self.sPATH .. "main\\LOC_BigGunDestroy"
  self.sFrontDoor = self.sFrontDoor or "PARIS\\area05\\pantheon\\buildings\\MN_Pantheon_FrontDoor(1)"
  self.sGroundElevator = self.sGroundElevator or self.sPATH .. "pantheon_interior\\MN_Pantheon_Interior\\OccLt_Elevator_4s_4x2z"
  self.sMidElevator = self.sMidElevator or self.sPATH .. "pantheon_interior\\AO_Pantheon_Interior_Elevator_A"
  self.sExtResAreaTrig = self.sExtResAreaTrig or self.sPATH .. "wtf_low\\RestrictedArea"
  self.tGunSabAreas = self.tGunSabAreas or {
    self.sPATH .. "wtf_low\\TRIG_GunSabArea1",
    self.sPATH .. "wtf_low\\TRIG_GunSabArea2"
  }
  self.sExtTrigEntFront = self.sExtTrigEntFront or self.sPATH .. "main\\TRIG_InteriorFront"
  self.sIntTrigEntTop = self.sIntTrigEntTop or self.sPATH .. "pantheon_interior\\TRIG_InteriorTop"
  self.sTeleportInt = self.sTeleportInt or self.sPATH .. "pantheon_interior\\LOC_TeleportInt"
  self.sTeleportExt = self.sTeleportExt or self.sPATH .. "main\\LOC_TeleportExt"
  Trigger.DoNotWaitFor(self.sExtTrigEntFront, self.hSab)
  self:RegisterTriggerEvent(Trigger.WaitFor(self.sExtTrigEntFront, self.hSab, "P3FP_BiggerGun.LoadPanthInterior", self, {}), self.sExtTrigEntFront)
  Trigger.DoNotWaitFor(self.sIntTrigEntTop, self.hSab)
  self:RegisterTriggerEvent(Trigger.WaitFor(self.sIntTrigEntTop, self.hSab, "P3FP_BiggerGun.UnloadPanthInterior", self, {}), self.sIntTrigEntTop)
end

function P3FP_BiggerGun:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "P3FP_BiggerGun.DoCheckpoint")
end

function P3FP_BiggerGun:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  self.SetupVariables(self)
  if self.hGunStreamedIn then
    Util.KillEvent(self.hGunStreamedIn)
    self.hGunStreamedIn = nil
  end
  if self.hGunStreamedOut then
    Util.KillEvent(self.hGunStreamedOut)
    self.hGunStreamedOut = nil
  end
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      self.sBigGun
    },
    WaitForGameObject = true,
    WaitForPhysics = true
  }
  self.hGunStreamedIn = Util.CreateEvent(tStreamEvent, "P3FP_BiggerGun.GunStreamedIn", self, {false})
  self:RegisterEvent(self.hGunStreamedIn)
  if nCP == 1 then
    self.OpenFrontDoor(self)
    if not self:IsMissionTaskActive("P3FP_BiggerGun_Task_FindPantheon") then
      self.Task_FindPantheon(self)
    end
    local tSeeLoc = {
      EventType = "SeeLocatorEvent",
      InViewTime = 0.5,
      Locator = self.sBGSee,
      Proximity = 150
    }
    self:RegisterEvent(Util.CreateEvent(tSeeLoc, "P3FP_BiggerGun.SeenBiggerGun", self))
  elseif nCP == 2 then
    self.TASK_EnterPantheon(self)
  elseif nCP == 3 then
    self.Task_DestroyBiggerGun(self)
    Object.SetInvincible(Handle(self.sBigGun), false)
    local hElevatorUsePt = AttractionPt.FindPtInObject(Handle(self.sExtElevator), "DoorTrigger")
    if hElevatorUsePt then
      AttractionPt.EnableUse(hElevatorUsePt, false)
    end
    local tDeathEvent = {
      EventType = "DeathEvent",
      ObjectHandle = Handle(self.sBigGun)
    }
    self:RegisterEvent(Util.CreateEvent(tDeathEvent, "P3FP_BiggerGun.GunDeath", self))
    Trigger.DoNotWaitFor("Missions\\freeplay\\p3\\mis_panth_biggergun\\main\\TRIG_BypassInterior", hSab)
    Trigger.ClearCallback("Missions\\freeplay\\p3\\mis_panth_biggergun\\main\\TRIG_BypassInterior", self.eBypass)
    Trigger.Enable("Missions\\freeplay\\p3\\mis_panth_biggergun\\main\\TRIG_BypassInterior", false)
  elseif nCP == 4 then
    Trigger.Enable("Missions\\freeplay\\p3\\mis_panth_biggergun\\pantheon_interior\\RestrictedArea", false)
    self.ExitHQ(self)
    self.Task_FindPantheon(self)
  elseif nCP == 5 then
    Object.ForceClose(Handle(self.sFrontDoor))
    self.TASK_ExitPantheonTop(self)
    local hUsePt = AttractionPt.FindPtInObject(Handle(self.sGroundElevator), "DoorTrigger")
    local tDoorUseEvent = {
      EventType = "OnActorComplete",
      Target = hUsePt
    }
    self:RegisterEvent(Util.CreateEvent(tDoorUseEvent, "P3FP_BiggerGun.OnElevatorUse", self, {
      self.sGroundElevator,
      6
    }))
    hUsePt = AttractionPt.FindPtInObject(Handle(self.sMidElevator), "DoorTrigger")
    local tDoorUseEvent = {
      EventType = "OnActorComplete",
      Target = hUsePt
    }
    self:RegisterEvent(Util.CreateEvent(tDoorUseEvent, "P3FP_BiggerGun.OnElevatorUse", self, {
      self.sMidElevator,
      5
    }))
  end
end

function P3FP_BiggerGun:GunStreamedIn(bStreamedOutOnce)
  local hGun = Handle(self.sBigGun)
  Object.SetInvincible(hGun, false)
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      self.sBigGun
    },
    WaitForStreamOut = true
  }
  self.hGunStreamedOut = Util.CreateEvent(tStreamEvent, "P3FP_BiggerGun.GunStreamedOut", self)
  self:RegisterEvent(self.hGunStreamedOut)
  if bStreamedOutOnce == false then
    self.Task_DestroyBiggerGun_Ambient(self)
  else
    self:ResetTaskByName("P3FP_BiggerGun_Task_DestroyBiggerGun_Ambient")
  end
end

function P3FP_BiggerGun:GunStreamedOut()
  self:KillTaskByName("P3FP_BiggerGun_Task_DestroyBiggerGun_Ambient")
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      self.sBigGun
    },
    WaitForGameObject = true,
    WaitForPhysics = true
  }
  self.hGunStreamedIn = Util.CreateEvent(tStreamEvent, "P3FP_BiggerGun.GunStreamedIn", self, {true})
  self:RegisterEvent(self.hGunStreamedIn)
end

function P3FP_BiggerGun:SetGunDestructible()
  Object.SetInvincible(Handle(self.sBigGun), false)
end

function P3FP_BiggerGun:ExitHQ()
  self:CreateTask({
    sName = "ExitHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "Catacombs",
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 1}
      },
      {
        Cin.PlayConversation,
        {
          "P3FP_BiggerGun_OMW"
        }
      }
    }
  })
end

function P3FP_BiggerGun:Task_FindPantheon()
  self:CreateTask({
    sName = "P3FP_BiggerGun_Task_FindPantheon",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P3FP_BiggerGun_Text.Task_FindPantheon",
    tDeliverObjs = {
      self.hSab
    },
    tLocators = {
      self.sPantheonLoc
    },
    tDestRegion = {
      self.sPantheonTrig
    },
    bGroundBlip = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.DoCinematic,
        {
          self,
          nil,
          "P3FP_LookAtGun"
        }
      },
      {
        self.SetupCinTrigger,
        {self}
      },
      {
        self.SetupCheckpoint,
        {self, 2}
      },
      {
        self.SetupMusic,
        {self}
      }
    }
  })
end

function P3FP_BiggerGun:TASK_EnterPantheon()
  self.eBypass = Trigger.WaitFor("Missions\\freeplay\\p3\\mis_panth_biggergun\\main\\TRIG_BypassInterior", hSab, "P3FP_BiggerGun.BypassInterior", self, {}, cTRIGGEREVENT_ONENTER)
  self:RegisterTriggerEvent(self.eBypass, "Missions\\freeplay\\p3\\mis_panth_biggergun\\main\\TRIG_BypassInterior")
  self:CreateTask({
    sName = "P3FP_BiggerGun_TASK_EnterPantheon",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "EnterInterior",
    sInteriorName = "Pantheon",
    sObjectiveTextID = "P3FP_BiggerGun_Text.TASK_EnterPantheon",
    tLocators = {
      self.sEnterPanthLoc
    },
    bNoGPS = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 5}
      }
    }
  })
end

function P3FP_BiggerGun:BypassInterior()
  self:KillTaskByName("P3FP_BiggerGun_TASK_EnterPantheon")
  self.SetupCheckpoint(self, 3)
end

function P3FP_BiggerGun:TASK_ExitPantheonTop()
  self:CreateTask({
    sName = "P3FP_BiggerGun_TASK_ExitPantheonTop",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P3FP_BiggerGun_Text.TASK_ExitPantheonTop",
    tDeliverObjs = {
      self.hSab
    },
    tLocators = {
      "Missions\\freeplay\\p3\\mis_panth_biggergun\\main\\LOC_GunTop"
    },
    tDestRegion = {
      "Missions\\freeplay\\p3\\mis_panth_biggergun\\main\\PT_GunTop"
    },
    bGroundBlip = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.TASK_ExitPantheonTopCriticalCheck,
        {self}
      }
    }
  })
end

function P3FP_BiggerGun:TASK_ExitPantheonTopCriticalCheck()
  self:CreateTask({
    sName = "TASK_ExitPantheonTopCriticalCheck",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "Pantheon",
    tOnActivate = {},
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 3}
      }
    }
  })
end

function P3FP_BiggerGun:Task_DestroyBiggerGun()
  self:CreateTask({
    sName = "P3FP_BiggerGun_Task_DestroyBiggerGun",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P3FP_BiggerGun_Text.Task_DestroyBiggerGun",
    tTgtInclude = {
      self.sBigGun
    },
    tLocators = {
      self.sBigGunDestroyLoc
    },
    tOnActivate = {},
    tOnComplete = {}
  })
end

function P3FP_BiggerGun:Task_DestroyBiggerGun_Ambient()
  self:CreateTask({
    sName = "P3FP_BiggerGun_Task_DestroyBiggerGun_Ambient",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    tTgtInclude = {
      self.sBigGun
    },
    bNoFocus = true,
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.DoWTFSwap,
        {self}
      }
    }
  })
end

function P3FP_BiggerGun:SeenBiggerGun()
  Cin.PlayConversation("P3FP_BiggerGun_SeeGun")
end

function P3FP_BiggerGun:DoWTFSwap()
  self.bDestroyed = true
  if Cin.IsPlayerCloseToCinematic("Missions\\cinematics\\wtf\\wtf_fp_pantheon\\FX_Explosion") then
    Cin.PlayCinematic("WTF_FP_Pantheon", false, "P3FP_BiggerGun.PlayFinalConvo", self)
  else
    Cin.PlayCinematic("WTF_FP_Pantheon_NOCAM", false, "P3FP_BiggerGun.PlayFinalConvo", self)
  end
end

function P3FP_BiggerGun:PlayFinalConvo()
  Cin.PlayConversation("P3FP_BiggerGun_DestroyBigGun", "P3FP_BiggerGun.DoCleanup", self)
end

function P3FP_BiggerGun:DoCleanup()
  Sound.ResetMusicLocale()
  Util.UnloadStaticENTag("p3fp_biggergun_gun_alive", true)
  Util.LoadStaticENTag("Destroyed_PanthGun", true)
  self:CompleteThisMission()
end

function P3FP_BiggerGun:DoCinematic(a_tCallbackData, a_sCinematic)
  local hVeh
  if Actor.IsInVehicle(self.hSab) then
    hVeh = Actor.GetVehicle(self.hSab)
    Vehicle.BrakeTo(hVeh, 0)
  end
  local hGun = Handle(self.sBigGun)
  if hGun and Object.IsAlive(hGun) then
    Object.SetInvincible(hGun, true)
  end
  Cin.PlayCinematic(a_sCinematic, "P3FP_BiggerGun.PostCinematic", self, {hVeh})
end

function P3FP_BiggerGun:PostCinematic(...)
  local a_tCallbackData, a_hVeh
  if arg.n == 2 then
    a_tCallbackData, a_hVeh = unpack(arg)
  end
  if a_hVeh then
    Vehicle.BrakeTo(a_hVeh, 200)
  end
  local hGun = Handle(self.sBigGun)
  if hGun and Object.IsAlive(hGun) then
    Object.SetInvincible(hGun, false)
  end
end

function P3FP_BiggerGun:SetupCinTrigger()
  self:RegisterTriggerEvent(Trigger.WaitFor(self.sGearTrig, self.hSab, "P3FP_BiggerGun.DoCinematic", self, {
    "P3FP_LookAtGears"
  }), self.sGearTrig)
end

function P3FP_BiggerGun:CheckSabotage(a_tCallbackData, a_hObject)
  if not self.bPlantedOnGun then
    for i, sTrig in ipairs(self.tGunSabAreas) do
      local hTrig = Handle(sTrig)
      local tList = Trigger.GetAllWithin(hTrig)
      if tList then
        for j, hEntity in ipairs(tList) do
          if hEntity == self.hSab then
            self.bPlantedOnGun = true
            self:RegisterTriggerEvent(Trigger.WaitFor(self.sWatchExpTrig, self.hSab, "P3FP_BiggerGun.DoCinematic", self, {
              "P3FP_WatchExplosion"
            }), self.sWatchExpTrig)
            return
          end
        end
      end
    end
    local tSabotageEvent = {
      EventType = "OnSabotage",
      Target = self.hSab
    }
    self:RegisterEvent(Util.CreateEvent(tSabotageEvent, "P3FP_BiggerGun.CheckSabotage", self))
  end
end

function P3FP_BiggerGun:GunDeath()
  Trigger.DoNotWaitFor(self.sWatchExpTrig, self.hSab)
end

function P3FP_BiggerGun:LoadPanthInterior()
  InteriorManager.EnterInterior("Pantheon", self.sTeleportInt)
end

function P3FP_BiggerGun:UnloadPanthInterior()
  InteriorManager.ExitInterior("Pantheon", self.sTeleportExt)
end

function P3FP_BiggerGun:OpenFrontDoor()
  local hDoor = Handle(self.sFrontDoor)
  if not hDoor then
    local tTimerEvent = {EventType = "TimerEvent", Time = 0.25}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P3FP_BiggerGun.OpenFrontDoor", self))
  else
    Object.ForceOpen(hDoor)
  end
end

function P3FP_BiggerGun:OnElevatorUse(...)
  local a_tCallbackData, a_sElevator, a_nAnimTime
  if arg.n == 2 then
    a_sElevator, a_nAnimTime = unpack(arg)
  elseif arg.n == 3 then
    a_tCallbackData, a_sElevator, a_nAnimTime = unpack(arg)
  end
  local tTimerEvent = {
    EventType = "TimerEvent",
    Time = a_nAnimTime + 5
  }
  self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P3FP_BiggerGun.CheckElevatorStatus", self, {a_sElevator}))
end

function P3FP_BiggerGun:CheckElevatorStatus(a_sElevator)
  local hElevator = Handle(a_sElevator)
  if hElevator and Object.IsDoorOpen(hElevator) then
    Object.ForceClose(hElevator)
  else
    local tTimerEvent = {EventType = "TimerEvent", Time = 1}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P3FP_BiggerGun.CheckElevatorStatus", self, {a_sElevator}))
  end
end

function P3FP_BiggerGun:SetupMusic()
  Sound.SetMusicLocale("fp_P3FP_BiggerGun")
  Sound.SetMusicLocale("fp_P3FP_BiggerGun", "enterBuilding")
  self:RegisterTriggerEvent(Trigger.WaitFor(self.sExtResAreaTrig, self.hSab, "P3FP_BiggerGun.SetupMusicExitTrig", self, {}), self.sExtResAreaTrig)
end

function P3FP_BiggerGun:SetupMusicExitTrig()
  self:RegisterTriggerEvent(Trigger.WaitFor(self.sExtResAreaTrig, self.hSab, "P3FP_BiggerGun.SetupMusicEnterTrig", self, {}, cTRIGGEREVENT_ONEXIT), self.sExtResAreaTrig)
end

function P3FP_BiggerGun:SetupMusicEnterTrig()
  Sound.ResetMusicLocale()
  self:RegisterTriggerEvent(Trigger.WaitFor(self.sExtResAreaTrig, self.hSab, "P3FP_BiggerGun.SetupMusicAgain", self, {}), self.sExtResAreaTrig)
end

function P3FP_BiggerGun:SetupMusicAgain()
  Sound.SetMusicLocale("fp_P3FP_BiggerGun")
  Sound.SetMusicLocale("fp_P3FP_BiggerGun", "enterBuilding")
  self:RegisterTriggerEvent(Trigger.WaitFor(self.sExtResAreaTrig, self.hSab, "P3FP_BiggerGun.SetupMusicEnterTrig", self, {}, cTRIGGEREVENT_ONEXIT), self.sExtResAreaTrig)
end

function P3FP_BiggerGun:MISSION_ONCANCEL()
  self.bDestroyed = false
  local hGun = Handle(self.sBigGun)
  if hGun and Object.IsAlive(hGun) then
    Object.SetInvincible(hGun, true)
  end
  Sound.ResetMusicLocale()
  Vehicle.EnableTraffic(true)
end

function P3FP_BiggerGun:MISSION_ONRESET()
  Vehicle.EnableTraffic(true)
  Sound.UnloadSoundBank("m_fp_P3FP_PantheonGun.bnk")
end
