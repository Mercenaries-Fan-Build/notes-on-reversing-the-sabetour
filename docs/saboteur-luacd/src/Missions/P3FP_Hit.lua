if P3FP_Hit == nil then
  P3FP_Hit = SabTaskObjective:Create()
  P3FP_Hit.sPATH = "Missions\\freeplay\\p3\\mis_sulpice_hit\\"
  P3FP_Hit:Configure({
    TaskCount = 99,
    sStarter = "duval_cat_int",
    sConvFile = "P3FP_Hit_Start",
    bFreeplay = true,
    sSaveMissionNameID = "MissionNames_Text.P3FP_Hit",
    sActNameID = "MissionNames_Text.ACT_Duval",
    tUnlockList = {
      "Note_Mingo1_OkCorral",
      "P3FP_OKCorral"
    },
    tSMEDNodes = {
      P3FP_Hit.sPATH .. "main",
      P3FP_Hit.sPATH .. "getaway"
    },
    tStaticTags = {
      "p3fp_hit_hideprops"
    }
  })
end

function P3FP_Hit:STARTER_Setup()
end

function P3FP_Hit:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "SULPICE_HIT"
  self.bDebugMode = false
  self.sWTFZone = self.sPATH .. "WTF"
  Tips.Print(self, "Running SulpiceHit.")
  Util.SetTime(21, 0)
  self.GENERAL_Setup(self)
  self:RegisterCheckpoint("P3FP_Hit.Checkpoint0")
end

function P3FP_Hit:Checkpoint0()
  dprint(self, "Registered: CHECKPOINT 0")
  self.Task_GoToMission(self)
  self.Task_ExitCatacombsHQ(self)
end

function P3FP_Hit.SetupGamepadListener()
  local self = P3FP_Hit
  self.tControllerEvent = {
    EventType = "OnButtonPress",
    Target = Handle("Saboteur")
  }
  local eButtonEvent = Util.CreateEvent(self.tControllerEvent, "P3FP_Hit.OnButtonPress", self, {}, true)
  self:RegisterEvent(eButtonEvent)
end

function P3FP_Hit:OnButtonPress(a_tButtonData)
  local self = P3FP_Hit
  local tButtons = a_tButtonData[1]
  if tButtons.UP == true then
  elseif tButtons.DOWN == true then
  elseif tButtons.X == true then
  elseif tButtons.B == true then
  end
end

function P3FP_Hit:DEBUG_ArmSelf()
  Inventory.GiveItem(hSab, "WP_MG_Thompson_ExtMag", true)
  Inventory.GiveItem(hSab, "WP_MG_Thompson_ExtMag", true)
  Inventory.GiveItem(hSab, "WP_RF_Gewehr_Scope", true)
  Inventory.GiveItem(hSab, "WP_RF_Gewehr_Scope", true)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", true)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", true)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", true)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", true)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", true)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", true)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", true)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", true)
end

function P3FP_Hit:GENERAL_Setup()
  self.sOfficer = self.sPATH .. "singer\\Singer"
  self.tGuards = {
    self.sPATH .. "main\\Guard01",
    self.sPATH .. "main\\Guard02",
    self.sPATH .. "main\\Guard03",
    self.sPATH .. "main\\Guard04",
    self.sPATH .. "main\\Guard05",
    self.sPATH .. "main\\Guard06",
    self.sPATH .. "main\\Guard07",
    self.sPATH .. "main\\Guard08",
    self.sPATH .. "main\\Guard09"
  }
  self.tFormations = {
    {
      self.sPATH .. "main\\Nazi01",
      self.sPATH .. "audience\\Nazi02",
      self.sPATH .. "audience\\Nazi03",
      self.sPATH .. "audience\\Nazi04",
      self.sPATH .. "main\\Nazi05",
      self.sPATH .. "audience\\Nazi06"
    },
    {
      self.sPATH .. "audience\\Nazi07",
      self.sPATH .. "audience\\Nazi08",
      self.sPATH .. "main\\Nazi09",
      self.sPATH .. "main\\Nazi10",
      self.sPATH .. "audience\\Nazi11",
      self.sPATH .. "audience\\Nazi12"
    },
    {
      self.sPATH .. "audience\\Nazi13",
      self.sPATH .. "main\\Nazi14",
      self.sPATH .. "main\\Nazi15",
      self.sPATH .. "audience\\Nazi16",
      self.sPATH .. "audience\\Nazi17",
      self.sPATH .. "audience\\Nazi18"
    }
  }
  self.tInfo.Nazis = {
    self.sPATH .. "audience\\Nazi02",
    self.sPATH .. "audience\\Nazi03",
    self.sPATH .. "audience\\Nazi04",
    self.sPATH .. "audience\\Nazi06",
    self.sPATH .. "audience\\Nazi07",
    self.sPATH .. "audience\\Nazi08",
    self.sPATH .. "audience\\Nazi11",
    self.sPATH .. "audience\\Nazi12",
    self.sPATH .. "audience\\Nazi13",
    self.sPATH .. "audience\\Nazi16",
    self.sPATH .. "audience\\Nazi17",
    self.sPATH .. "audience\\Nazi18"
  }
  self.sStreetGuardN = self.sPATH .. "main\\Guard08"
  self.sStreetGuardE1 = self.sPATH .. "main\\Guard04"
  self.sStreetGuardE2 = self.sPATH .. "main\\Guard05"
  self.sStreetGuardE3 = self.sPATH .. "main\\Guard02"
  self.sFranInDoor = self.sPATH .. "main\\SwingingDoorRight"
  self.sFranOutDoor = self.sPATH .. "main\\SwingingDoorRight(2)"
  self.FarEscalateEvent = nil
  self:AddOnCancelCallback(P3FP_Hit.Reset)
  self:AddOnCompleteCallback(P3FP_Hit.Reset)
  Sound.LoadSoundBank("m_fp_P3FP_Hit.bnk")
  bDidWeRunPickupTaskYet = false
  self.hEscalationLiteEvent = nil
  self.CinEscalationEvent = nil
  self.PlayerFrozen = 0
  self.tSaveInfo.bLoadedSingerByHand = false
end

function P3FP_Hit:Task_ExitCatacombsHQ()
  self:CreateTask({
    sName = "Task_ExitCatacombsHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "Catacombs",
    bInteriorTask = true,
    bNoGPS = true,
    MarkerHeight = 2.5,
    tLocators = {},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "P3FP_Hit.Checkpoint1"
        }
      }
    }
  })
end

function P3FP_Hit:Checkpoint1()
  dprint(self, "Registered: CHECKPOINT 1")
  bDidWeRunPickupTaskYet = false
  EVENT_Stream("P3FP_Hit.SetupGuardWarns", self, self.sStreetGuardN, true, {
    self.sStreetGuardN,
    self.sPATH .. "main\\PT_EntranceN"
  })
  EVENT_Stream("P3FP_Hit.SetupGuardWarns", self, self.sStreetGuardE1, true, {
    self.sStreetGuardE1,
    self.sPATH .. "main\\PT_EntranceE1"
  })
  EVENT_Stream("P3FP_Hit.SetupGuardWarns", self, self.sStreetGuardE2, true, {
    self.sStreetGuardE2,
    self.sPATH .. "main\\PT_EntranceE2"
  })
  EVENT_Stream("P3FP_Hit.SetupGuardWarns", self, self.sStreetGuardE3, true, {
    self.sStreetGuardE3,
    self.sPATH .. "main\\PT_EntranceE3"
  })
  self.bCheckpt2Esc = false
  self.sMissionB4Esc = "INIT"
  if not self:IsMissionTaskActive("P3FP_Hit.Task_GoToMission") then
    self.Task_GoToMission(self)
  end
  self.EscalationListener(self)
end

function P3FP_Hit:DisableAPs()
  local hInAtrrPt = Handle(self.sFranInDoor)
  AttractionPt.EnableUse(hInAtrrPt, false)
  local hOutAtrrPt = Handle(self.sFranOutDoor)
  AttractionPt.EnableUse(hOutAtrrPt, false)
end

function P3FP_Hit:SetupGuardWarns(a_sGuard, a_sTrigger)
  EVENT_PlayerEntersTrigger("P3FP_Hit.StreetGuardWarns", self, a_sTrigger, true, {a_sGuard})
end

function P3FP_Hit:StreetGuardWarns(a_tCallbackData, a_sGuard)
  if not Actor.IsDisguised(hSab) then
    Actor.SetFacingDir(Handle(a_sGuard), hSab)
    Actor.PlayAnimation(Handle(a_sGuard), "nazi_halt_1")
    Cin.PlayConversationWith("P2FP_GrandSniper_NaziGuard", {
      Handle(a_sGuard)
    })
  end
end

function P3FP_Hit:Task_GoToMission()
  self.hEscalationLiteEvent = EVENT_OnEscalationLite("P3FP_Hit.FindEscalationLite", self, nil, true)
  self:CreateTask({
    sName = "P3FP_Hit.Task_GoToMission",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "P3FP_Hit_Text.Task_GoToMission",
    tLocators = {
      "Missions\\freeplay\\p3\\mis_sulpice_hit\\main\\LOC_MissionArea"
    },
    tDestRegion = self.sPATH .. "main\\PT_MissionArea",
    sTaskSubType = "DELIVER",
    tDeliverObjs = {hSab},
    tOnActivate = {},
    tOnComplete = {
      {
        HUD.ClearGPSTarget,
        {}
      },
      {
        self.Checkpoint2,
        {self}
      }
    }
  })
end

function P3FP_Hit:WholeHouseFreeze()
  if self.PlayerFrozen == 0 then
    self.PlayerFrozen = 1
    OnStaticConversationDisables()
  end
end

function P3FP_Hit:TestArrivalCin()
  if Suspicion.GetEscalation() > 0 then
    self:EscalatedEarly()
  else
    Render.FadeTo(0, 0, 0, 255, 0.5)
    P3FP_Hit.WholeHouseFreeze(self)
    Object.SetInvincible(hSab, true)
    EVENT_Timer("P3FP_Hit.LoadAudience", self, 0.5)
    self.BlackScreenEsc = EVENT_OnEscalation("P3FP_Hit.EscalatedEarly", self, nil, false)
  end
end

function P3FP_Hit:LoadAudience()
  WorldSMEDNodes.LoadNode("Missions\\freeplay\\p3\\mis_sulpice_hit\\audience", "P3FP_Hit.ArrivalCin", self)
end

function P3FP_Hit:FindEscalationLite(tLocTable)
  local x = tLocTable[2]
  local y = tLocTable[3]
  local z = tLocTable[4]
  local hTrig = Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\main\\PT_MissionArea")
  bWithinArea = Trigger.IsPointWithin(hTrig, x, y, z)
  if bWithinArea then
    self:EscalatedEarly()
  end
end

function P3FP_Hit:EscalatedEarly()
  Render.FadeTo(0, 0, 0, 0, 0.5)
  ClearAllDisableControls()
  self.tSaveInfo.bLoadedSingerByHand = true
  Util.SpawnEditNode("Missions\\freeplay\\p3\\mis_sulpice_hit\\singer.wsd", "P3FP_Hit.EscalatedEarlySpawned", self)
end

function P3FP_Hit:EscalatedEarlySpawned()
  self:KillTaskByName("P3FP_Hit.Task_GoToMission")
  ClearAllDisableControls()
  self.hFran = Handle(self.sOfficer)
  Combat.SetIdleScripted(Handle(self.sOfficer), false)
  Actor.SetPanicEnabled(Handle(self.sOfficer), false)
  Actor.OverrideCombatAI(self.hFran, true)
  Combat.SetWimpy(Handle(self.sOfficer), true)
  self.Task_EliminateOfficer(self)
  EVENT_ActorDeath("P3FP_Hit.OnOfficerDead", self, self.hFran)
  self.EscalationEffects(self)
end

function P3FP_Hit:ArrivalCin()
  self.BrakeCar(self)
  Util.KillEvent(self.hEscalationLiteEvent)
  self.FarEscalateEvent = EVENT_PlayerEntersTrigger("P3FP_Hit.CheckForEscalation", self, "Missions\\freeplay\\p3\\mis_sulpice_hit\\main\\PT_MissionArea", true)
  self:CreateTask({
    sName = "P3FP_Hit.ArrivalCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "CIN_ConfirmedKill_Arrival",
    tSMEDNodes = {
      self.sPATH .. "singer"
    },
    tStaticTags = {},
    tOnActivate = {
      {
        Sound.ActivateSoundEmitter,
        {
          Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\sound\\Amb_P3FP_Audience_Boos")
        }
      },
      {
        self.GoFran,
        {self}
      },
      {
        Render.FadeTo,
        {
          0,
          0,
          0,
          0,
          0.5
        }
      },
      {
        OffStaticConversationDisables,
        {}
      },
      {
        Object.SetInvincible,
        {hSab, false}
      }
    },
    tOnComplete = {
      {
        Util.KillEvent,
        {
          self.CinEscalationEvent
        }
      },
      {
        self.ReleaseCar,
        {self}
      },
      {
        self.RegisterCheckpoint,
        {
          self,
          "P3FP_Hit.Task_EliminateOfficer"
        }
      }
    }
  })
end

function P3FP_Hit:GoFran()
  EVENT_Stream("P3FP_Hit.InitFran", self, self.sOfficer, false)
end

function P3FP_Hit:InitFran()
  self.hFran = Handle(self.sOfficer)
  Combat.SetIdleScripted(Handle(self.sOfficer), false)
  Actor.SetPanicEnabled(Handle(self.sOfficer), false)
  Actor.OverrideCombatAI(self.hFran, true)
  self.hDoorAP = Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\main\\SwingingDoorRight")
  self.hSingAP = Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\main\\AIAttractionPt_Civ_F_Sing")
  Combat.SetIdleScripted(self.hFran, true)
  Actor.RequestAttrPt(self.hFran, self.hSingAP)
  self:SetupEscalatedInCin()
  Util.KillEvent(self.BlackScreenEsc)
  Sound.ActivateSoundEmitter(Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\main\\P3FP_FrancineSong"))
end

function P3FP_Hit:FranReady()
end

function P3FP_Hit:SetupEscalatedInCin()
  self.CinEscalationEvent = EVENT_OnEscalation("P3FP_Hit.EscalatedInCin", self)
end

function P3FP_Hit:EscalatedInCin()
  ScriptSequence.Kill(self.hFran)
  Cin.StopCinematic("CIN_ConfirmedKill_Arrival")
  Render.FadeTo(0, 0, 0, 0, 0.5)
  ClearAllDisableControls()
  self:EscalationEffects()
end

function P3FP_Hit:Checkpoint2()
  dprint(self, "Registered: CHECKPOINT 2")
  self.PlayerFrozen = 0
  Object.SetInvincible(hSab, false)
  self.TestArrivalCin(self)
end

function P3FP_Hit:Task_EliminateOfficer()
  self.DisableAPs(self)
  self.EscalationListener(self)
  OffStaticConversationDisables()
  self.hFran = Handle(self.sOfficer)
  Combat.SetIdleScripted(Handle(self.sOfficer), false)
  Actor.SetPanicEnabled(Handle(self.sOfficer), false)
  Actor.OverrideCombatAI(self.hFran, true)
  Sound.ActivateSoundEmitter(Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\main\\P3FP_FrancineSong"))
  EVENT_ActorDeath("P3FP_Hit.OnOfficerDead", self, self.hFran)
  hMicAttrPt = Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\main\\AIAttractionPt_Civ_F_Sing")
  if AttractionPt.IsBeingUsedBySomeone(hMicAttrPt) == false and Suspicion.GetEscalation() == 0 then
    Actor.RequestAttrPt(self.hFran, hMicAttrPt)
  end
  Render.FadeTo(0, 0, 0, 0, 0.5)
  Object.SetInvincible(hSab, false)
  bDidWeRunPickupTaskYet = false
  ClearAllDisableControls()
  self:CreateTask({
    sName = "P3FP_Hit.Task_EliminateOfficer",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P3FP_Hit_Text.Task_EliminateOfficer",
    tTgtInclude = {
      self.sOfficer
    },
    tOnActivate = {},
    tOnComplete = {
      {
        Util.KillEvent,
        {
          self.hEscalationLiteEvent
        }
      },
      {
        EVENT_Timer,
        {
          "P3FP_Hit.Task_FindPapers",
          self,
          1
        }
      },
      {
        self.SetupStarters,
        {self}
      },
      {
        Suspicion.SetEscalated,
        {}
      }
    }
  })
end

function P3FP_Hit:Task_FindPapers()
  if bDidWeRunPickupTaskYet == false then
    bDidWeRunPickupTaskYet = true
    local e = {
      EventType = "StreamEvent",
      Objects = {
        self.hLocket
      },
      WaitForStreamOut = true
    }
    self.LocketStreamEvent = Util.CreateEvent(e, "P3FP_Hit.LocketLost", self)
    self:RegisterEvent(self.LocketStreamEvent)
    self:CreateTask({
      sName = "P3FP_Hit_Task_FindPapers",
      sTaskType = "SabTaskObjectiveDeliver",
      sTaskSubType = "Fetch",
      bBlueprintFetch = true,
      sObjectiveTextID = "P3FP_Hit_Text.Task_FindPapers",
      MarkerHeight = 0.5,
      tLocators = {
        self.hLocket
      },
      tDeliverObjs = {
        "P3FP_SulpiceHit_ID"
      },
      tOnActivate = {},
      tOnComplete = {
        {
          Util.KillEvent,
          {
            self.LocketStreamEvent
          }
        },
        {
          self.RegisterCheckpoint,
          {
            self,
            "P3FP_Hit.Checkpoint3"
          }
        }
      }
    })
  end
end

function P3FP_Hit:Checkpoint3()
  dprint(self, "Registered: CHECKPOINT 3")
  self.sMissionB4Esc = "Task_ReturnToMingo"
  self:SetupStarters()
  if Suspicion.GetEscalation() > 0 then
    self.TASK_LoseEscalation(self)
  else
    self.Task_ReturnToMingo(self)
  end
  self.DisableAPs(self)
end

function P3FP_Hit:Task_ReturnToMingo()
  self:CreateTask({
    sName = "P3FP_Hit_Task_ReturnObject",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Talk",
    bEscalationDenial = true,
    sObjectiveTextID = "P3FP_Hit_Text.Task_ReturnObject",
    tTgtInclude = {
      "Missions\\paris_2\\characters\\freeplay\\duval_ind_ext\\Duval_ext_ind"
    },
    vGPSTarget = "Missions\\freeplay\\p3\\mis_sulpice_hit\\main\\LOC_Duval",
    sConvFile = "P3FP_Hit_Complete",
    tOnActivate = {
      {
        self.EscalationListener,
        {self}
      }
    },
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end

function P3FP_Hit:TASK_LoseEscalation()
  self:CreateTask({
    sName = "P3FP_Hit.TASK_LoseEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    EscalationLevel = 0,
    bRepeatable = true,
    bNoRepeatAutoRebuild = true,
    tOnComplete = {
      {
        self.ResetEscEvent,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function P3FP_Hit:ResetEscEvent()
  Util.KillEvent(self.eEscDetect)
  Util.KillEvent(self.eEscLiteDetect)
  if self.sMissionB4Esc == "Task_GoToMission" then
    self:Task_GoToMission()
  elseif self.sMissionB4Esc == "Task_ReturnToMingo" then
    self:Task_ReturnToMingo()
  end
  self.sMissionB4Esc = "CLEARED"
  self:EscalationListener()
end

function P3FP_Hit:EscalationListener()
  if self.eEscDetect then
    Util.KillEvent(self.eEscDetect)
  end
  if self.eEscLiteDetect then
    Util.KillEvent(self.eEscLiteDetect)
  end
  dprint(self, "Setting Escalation Listener  - clear Esc to get Fade Up/Down")
  self.eEscDetect = EVENT_OnEscalation("P3FP_Hit.EscSwitchTasks", self, nil, false)
end

function P3FP_Hit:EscSwitchTasks()
  dprint(self, "Escalated. Switching to LOSE HEAT task")
  Render.FadeTo(0, 0, 0, 0, 0.5)
  ClearAllDisableControls()
  if self:IsMissionTaskActive("P3FP_Hit.Task_GoToMission") then
    self:ResetTaskByName("P3FP_Hit.Task_GoToMission", true)
    self.sMissionB4Esc = "Task_GoToMission"
    self:TASK_LoseEscalation()
  elseif self:IsMissionTaskActive("P3FP_Hit_Task_ReturnObject") then
    self:ResetTaskByName("P3FP_Hit_Task_ReturnObject", true)
    self.sMissionB4Esc = "Task_ReturnToMingo"
    self:TASK_LoseEscalation()
  else
    self:EscalationEffects()
    self.sMissionB4Esc = "Task_EliminateOfficer"
  end
end

function P3FP_Hit:BrakeCar()
  local hSabCar = Actor.GetVehicle(hSab)
  if hSabCar then
    SabTaskObjectiveDeliver.StopVehicle(self, hSabCar)
  end
end

function P3FP_Hit:ReleaseCar()
  local hSabCar = Actor.GetVehicle(hSab)
  if hSabCar then
    SabTaskObjectiveDeliver.ReleaseVehicle(self, hSabCar)
  end
  ClearAllDisableControls()
end

function P3FP_Hit:OnOfficerDead()
  Sound.DeactivateSoundEmitter(Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\sound\\Amb_P3FP_Audience_Boos"))
  local x, y, z = Actor.GetPosition(Handle(self.sOfficer))
  Object.Spawn("P3FP_SulpiceHit_ID", x, y + 3, z, 0, nil, "P3FP_Hit.OnLocketSpawned", self, {}, false)
  EVENT_Timer("P3FP_Hit.Task_FindPapers", self, 1)
end

function P3FP_Hit:OnLocketSpawned(a_tSpawnData)
  dprint(self, "             +++++++  LOCKET SPAWNED +++++++")
  self.hLocket = a_tSpawnData[1]
end

function P3FP_Hit:LocketLost()
  self:MissionTaskFail("P3FP_Hit_Text.Fail_LocketLost")
end

function P3FP_Hit:EscalationEffects()
  Util.KillEvent(self.hEscalationLiteEvent)
  for i, v in ipairs(self.tInfo.Nazis) do
    local hActor = Util.GetHandleByName(v)
    if Actor.IsAlive(hActor) == true then
      Actor.CancelAttrPt(hActor)
      Actor.CancelAttrPtRequest(hActor)
    end
  end
  Combat.SetIdleScripted(self.hFran, true)
  ScriptSequence.Kill(self.hFran)
  Actor.CancelAttrPt(self.hFran)
  Actor.CancelAttrPtRequest(self.hFran)
  Actor.CancelAnimation(self.hFran)
  Actor.SetPanicEnabled(self.hFran, false)
  Actor.OverrideCombatAI(self.hFran, true)
  Nav.CancelScriptedPath(self.hFran)
  Nav.CancelFollowObject(self.hFran)
  Nav.StopMoving(self.hFran)
  self:FranRan()
  Actor.CancelAttrPt(Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\audience\\UpperClass_F_Hot(4)"))
  Actor.CancelAttrPt(Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\audience\\UpperClass_M"))
  Actor.CancelAttrPt(Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\audience\\UpperClass_F_Hot(2)"))
  Actor.CancelAttrPt(Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\audience\\UpperClass_M(2)"))
  Actor.CancelAttrPt(Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\audience\\UpperClass_F_Hot"))
  Actor.CancelAttrPtRequest(Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\audience\\UpperClass_F_Hot(4)"))
  Actor.CancelAttrPtRequest(Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\audience\\UpperClass_M"))
  Actor.CancelAttrPtRequest(Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\audience\\UpperClass_F_Hot(2)"))
  Actor.CancelAttrPtRequest(Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\audience\\UpperClass_M(2)"))
  Actor.CancelAttrPtRequest(Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\audience\\UpperClass_F_Hot"))
end

function P3FP_Hit:CheckForEscalation()
  if Suspicion.GetEscalation() > 0 then
    Trigger.ClearCallback(Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\main\\PT_MissionArea"), self.FarEscalateEvent)
    self:FranRan()
  end
end

function P3FP_Hit:FranRan()
  Sound.DeactivateSoundEmitter(Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\sound\\Amb_P3FP_Audience_Boos"))
  local hDoorAP = Handle("Missions\\freeplay\\p3\\mis_sulpice_hit\\main\\SwingingDoorRight(2)")
  local tExitSequence = {
    {
      "RUNPATHONCE",
      {
        "Missions\\freeplay\\p3\\mis_sulpice_hit\\main\\PATH_FranToStage"
      }
    },
    {
      "USEATTRPT",
      {hDoorAP}
    },
    {
      "RUNTOOBJECT",
      {
        "Missions\\freeplay\\p3\\mis_sulpice_hit\\main\\LOC_FranRunHere(3)",
        0
      }
    },
    {
      "DELAY",
      {5}
    }
  }
  ScriptSequence.Run(self.hFran, tExitSequence)
  EVENT_ActorEntersTrigger("P3FP_Hit.FranRanFail", self, self.hFran, "Missions\\freeplay\\p3\\mis_sulpice_hit\\main\\PT_Escaped")
end

function P3FP_Hit:OpenFranExit()
  local hOutAtrrPt = Handle(self.sFranOutDoor)
  AttractionPt.EnableUse(hOutAtrrPt, true)
end

function P3FP_Hit:CloseFranExit()
  local hOutAtrrPt = Handle(self.sFranOutDoor)
  AttractionPt.EnableUse(hOutAtrrPt, false)
end

function P3FP_Hit:FranRanFail()
  self:MissionTaskFail("P3FP_Hit_Text.Fail_FranRan")
  dprint(self, "---===== FRAN IS SO GONE, YOU LOSE!!!!!!!!!====-----")
end

function P3FP_Hit:Reset()
  self.DisableAPs(self)
  Sound.ResetMusicLocale()
  Object.SetInvincible(hSab, false)
  Sound.ReleaseSoundBank("m_fp_P3FP_Hit.bnk")
  if self.tSaveInfo.bLoadedSingerByHand and Util.IsBlockLoaded("Missions\\freeplay\\p3\\mis_sulpice_hit\\singer.wsd") then
    Util.UnloadEditNode("Missions\\freeplay\\p3\\mis_sulpice_hit\\singer.wsd", true)
  end
  WorldSMEDNodes.UnloadNode("Missions\\freeplay\\p3\\mis_sulpice_hit\\audience", true)
end

function P3FP_Hit:SetupStarters()
  RewardsManager.ShowStarter("Duval_ext_ind")
  RewardsManager.HideStarter("duval_cat_int")
end

function P3FP_Hit:MISSION_ONCANCEL()
  RewardsManager.ShowStarter("duval_cat_int")
  RewardsManager.HideStarter("Duval_ext_ind")
end
