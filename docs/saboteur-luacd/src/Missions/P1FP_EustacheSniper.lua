if P1FP_EustacheSniper == nil then
  P1FP_EustacheSniper = SabTaskObjective:Create()
  P1FP_EustacheSniper.PATH = "Missions\\freeplay\\p1\\mis_eustache_sniper\\"
  P1FP_EustacheSniper:Configure({
    TaskCount = 999,
    sSaveMissionNameID = "MissionNames_Text.P1FP_EustacheSniper",
    sActNameID = "MissionNames_Text.ACT_FatherDenis",
    tUnlockList = {
      "P4FP_MadBomber02"
    },
    bFreeplay = true,
    bRepeatable = false,
    MarkerHeight = 1.75,
    sStarter = "Father_Belle_Interior",
    sConvFile = "P1FP_EustacheSniper_Start",
    tSMEDNodes = {
      P1FP_EustacheSniper.PATH .. "main"
    }
  })
end

function P1FP_EustacheSniper:STARTER_Setup()
end

function P1FP_EustacheSniper:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "EUSTACHE"
  self.bDebugMode = false
  Util.EnableSuperSpores(false)
  self.GENERAL_Setup(self)
  self:RegisterCheckpoint("P1FP_EustacheSniper.Checkpoint0")
end

function P1FP_EustacheSniper.SetupGamepadListener()
  local self = P1FP_EustacheSniper
  self.tControllerEvent = {
    EventType = "OnButtonPress",
    Target = Handle("Saboteur")
  }
  local eButtonEvent = Util.CreateEvent(self.tControllerEvent, "P1FP_EustacheSniper.OnButtonPress", self, {}, true)
  self:RegisterEvent(eButtonEvent)
end

function P1FP_EustacheSniper:OnButtonPress(a_tButtonData)
  local self = P1FP_EustacheSniper
  local tButtons = a_tButtonData[1]
  if tButtons.UP == true then
  elseif tButtons.DOWN == true then
  elseif tButtons.X == true then
  elseif tButtons.B == true then
  end
end

function P1FP_EustacheSniper:GENERAL_Setup()
  Util.SetTime(9, 0)
  self.sLadderTrigger = self.PATH .. "main\\PT_Ladder"
  self.sLadderLocator = self.PATH .. "main\\LOC_Ladder"
  self.sNestLocator = self.PATH .. "main\\LOC_Nest"
  self.sNestTrigger = self.PATH .. "main\\PT_Nest"
  self.hTowerLoc = self.PATH .. "main\\LOC_TowerNest"
  self.sTowerTrigger = self.PATH .. "main\\PT_TowerNest"
  self.tTargets = {}
  self:AddOnCancelCallback(P1FP_EustacheSniper.Reset)
  self:AddOnCompleteCallback(P1FP_EustacheSniper.Reset)
  self.tCrowdLeft = {
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(96)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(124)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(307)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(309)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(317)"
  }
  self.tCrowdRight = {
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(94)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(107)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(122)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(229)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(231)"
  }
  self.tCrowdCenter = {
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(91)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(106)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(119)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(303)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(310)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(313)"
  }
  self.sLeftPath = "Missions\\freeplay\\p1\\mis_eustache_sniper\\main\\PathoftheMonkey"
  self.sRightPath = "Missions\\freeplay\\p1\\mis_eustache_sniper\\main\\PathoftheTiger"
  self.sLExitPath = "Missions\\freeplay\\p1\\mis_eustache_sniper\\main\\PathoftheLion"
  self.sRExitPath = "Missions\\freeplay\\p1\\mis_eustache_sniper\\main\\PathoftheHawk"
  self.hCenterPath = "Missions\\freeplay\\p1\\mis_eustache_sniper\\main\\PathoftheLamb"
  self.sMExitPath = "Missions\\freeplay\\p1\\mis_eustache_sniper\\main\\BailPath"
  self.sBailPath = "Missions\\freeplay\\p1\\mis_eustache_sniper\\main\\BailPath"
  self.sEscapePath = "Missions\\freeplay\\p1\\mis_eustache_sniper\\main\\PATH_TargetEscape"
  self.sLeftPriest = "Missions\\freeplay\\p1\\mis_eustache_sniper\\actors\\Spore_CV_Priest(10)"
  self.sRightPriest = "Missions\\freeplay\\p1\\mis_eustache_sniper\\actors\\Spore_CV_Priest(11)"
  self.sDenis = "Missions\\freeplay\\p1\\mis_eustache_sniper\\actors\\Spore_RS_FatherDenis"
  self.tPotentialTargets = {
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(310)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(303)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(106)"
  }
  self.tPriests = {
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\actors\\Spore_CV_Priest(8)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\actors\\Spore_CV_Priest(9)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\actors\\Spore_CV_Priest(10)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\actors\\Spore_CV_Priest(11)"
  }
  self.tChairs = {
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\chairs\\PGlobalA_Chair_A\\PGlobalA_Chair_A",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\chairs\\PGlobalA_Chair_A(2)\\PGlobalA_Chair_A",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\chairs\\PGlobalA_Chair_A(3)\\PGlobalA_Chair_A",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\chairs\\PGlobalA_Chair_A(4)\\PGlobalA_Chair_A",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\chairs\\PGlobalA_Chair_A(5)\\PGlobalA_Chair_A",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\chairs\\PGlobalA_Chair_A(6)\\PGlobalA_Chair_A",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\chairs\\PGlobalA_Chair_A(7)\\PGlobalA_Chair_A",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\chairs\\PGlobalA_Chair_A(8)\\PGlobalA_Chair_A",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\chairs\\PGlobalA_Chair_A(9)\\PGlobalA_Chair_A",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\chairs\\PGlobalA_Chair_A(10)\\PGlobalA_Chair_A",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\chairs\\PGlobalA_Chair_A(11)\\PGlobalA_Chair_A",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\chairs\\PGlobalA_Chair_A(12)\\PGlobalA_Chair_A",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\chairs\\PGlobalA_Chair_A(13)\\PGlobalA_Chair_A",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\chairs\\PGlobalA_Chair_A(14)\\PGlobalA_Chair_A",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\chairs\\PGlobalA_Chair_A(15)\\PGlobalA_Chair_A",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\chairs\\PGlobalA_Chair_A(16)\\PGlobalA_Chair_A"
  }
  self.tAttendees = {
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(91)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(94)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(96)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(106)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(107)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(119)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(122)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(124)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(229)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(231)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(303)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(307)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(309)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(310)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(313)",
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees\\Spore_CV_UpperClass_M(317)"
  }
end

function P1FP_EustacheSniper:Checkpoint0()
  dprint(self, "Registered: CHECKPOINT 0")
  self.TASK_GetToLadder(self)
  self.Task_ExitLaVilletteHQ(self)
end

function P1FP_EustacheSniper:Task_ExitLaVilletteHQ()
  self:CreateTask({
    sName = "Task_ExitLaVilletteHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "Belle",
    bInteriorTask = true,
    bNoGPS = true,
    MarkerHeight = 2.5,
    tLocators = {},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "P1FP_EustacheSniper.Checkpoint1"
        }
      }
    }
  })
end

function P1FP_EustacheSniper:Checkpoint1()
  dprint(self, "Registered: CHECKPOINT 1")
  if not self:IsMissionTaskActive("P1FP_EustacheSniper.TASK_GetToLadder") then
    self.TASK_GetToLadder(self)
  end
end

function P1FP_EustacheSniper:TASK_GetToLadder()
  self:CreateTask({
    sName = "P1FP_EustacheSniper.TASK_GetToLadder",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P1FP_EustacheSniper_Text.TASK_GetToLadder",
    tDeliverObjs = {
      Handle("Saboteur")
    },
    tDestRegion = {
      self.sLadderTrigger
    },
    tLocators = {
      self.sLadderLocator
    },
    bGroundBlip = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.BrakeCar,
        {self}
      }
    }
  })
end

function P1FP_EustacheSniper:BrakeCar()
  local hSabCar = Actor.GetVehicle(hSab)
  if hSabCar then
    SabTaskObjectiveDeliver.StopVehicle(self, hSabCar)
  end
  EVENT_Timer("P1FP_EustacheSniper.UnBrakeCar", self, 1)
end

function P1FP_EustacheSniper:UnBrakeCar()
  local hSabCar = Actor.GetVehicle(hSab)
  if hSabCar then
    SabTaskObjectiveDeliver.ReleaseVehicle(self, hSabCar)
  end
  self.RegisterCheckpoint(self, "P1FP_EustacheSniper.Checkpoint1b")
end

function P1FP_EustacheSniper:Checkpoint2()
  dprint(self, "Registered: CHECKPOINT 2")
  OffStaticConversationDisables()
  EVENT_Stream("P1FP_EustacheSniper.GrabDenis", self, {
    "Missions\\freeplay\\p1\\mis_eustache_sniper\\actors\\Spore_RS_FatherDenis"
  }, true)
  self.eLeftMissionArea = EVENT_PlayerExitsTrigger("P1FP_EustacheSniper.FailPlayerLeft", self, "Missions\\freeplay\\p1\\mis_eustache_sniper\\main\\PT_ExitMissionFail", false)
  self.SetFlags(self)
  self.tInfo.nCongregation = 0
  self.tInfo.nTriggerCall = 0
  self.tInfo.nIsTarget = 1
  self.tInfo.nTries = 0
  self.tInfo.nLineUp = 0
  self.tInfo.bIsTargetDetermined = false
  EVENT_Stream("P1FP_EustacheSniper.InitCongregation", self, self.tAttendees, true)
  self.SetCivKillListeners(self)
  Util.KillEvent(self.eEscDetect)
  self.TASK_ScanStreets(self)
  self.eEscLiteDetect = Util.CreateEvent({
    EventType = "OnEscalationLite",
    EventName = "EscLiteDetect",
    Target = hSab
  }, "P1FP_EustacheSniper.EscLiteResponse", self)
  self:RegisterEvent(self.eEscLiteDetect)
end

function P1FP_EustacheSniper:InitCongregation()
  for i, v in ipairs(self.tAttendees) do
    local hActor = Util.GetHandleByName(v)
    Actor.SetPanicEnabled(hActor, false)
  end
  self.MovetheCongregation(self)
end

function P1FP_EustacheSniper:EscLiteResponse(a_tCallback)
  local xBomb = a_tCallback[2]
  local zBomb = a_tCallback[4]
  local xDenis = 366.49994
  local zDenis = -245.75003
  local DeltaX = xBomb - xDenis
  local DeltaZ = zBomb - zDenis
  local Sum = DeltaX * DeltaX + DeltaZ * DeltaZ
  local Answer = math.sqrt(Sum)
  if Answer <= 60 then
    self:WaitFirstShot()
  end
end

function P1FP_EustacheSniper:MissionSound()
  Sound.SetMusicLocale("fp_P1FP_EustacheSniper")
  Sound.SetMusicLocale("fp_P1FP_EustacheSniper", "timeLapse")
end

function P1FP_EustacheSniper:GrabDenis()
  self.hDenis = Util.GetHandleByName("Missions\\freeplay\\p1\\mis_eustache_sniper\\actors\\Spore_RS_FatherDenis")
end

function P1FP_EustacheSniper:PriestsSit()
  local hPriestL = Handle("Missions\\freeplay\\p1\\mis_eustache_sniper\\actors\\Spore_CV_Priest(10)")
  local hPriestR = Handle("Missions\\freeplay\\p1\\mis_eustache_sniper\\actors\\Spore_CV_Priest(8)")
  local hAttrPtL = Handle("Missions\\freeplay\\p1\\mis_eustache_sniper\\wtf_low\\props\\PGlobalA_Chair_A\\AttractionPT_Sit")
  local hAttrPtR = Handle("Missions\\freeplay\\p1\\mis_eustache_sniper\\wtf_low\\props\\PGlobalA_Chair_A(9)\\AttractionPT_Sit")
  Actor.UseAttrPt(hPriestR, hAttrPtR)
end

function P1FP_EustacheSniper:TASK_GetToTheNest()
  self:CreateTask({
    sName = "P1FP_EustacheSniper.TASK_GetToTheNest",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P1FP_EustacheSniper_Text.TASK_GetToTheNest",
    bNoGPS = true,
    tDeliverObjs = {
      Handle("Saboteur")
    },
    tDestRegion = {
      self.sNestTrigger
    },
    tLocators = {
      self.sNestLocator
    },
    tStaticTags = {
      "p1fp_eustachesniper_rifle"
    },
    tSMEDNodes = {},
    tOnActivate = {
      {
        self.EscalationListener,
        {self}
      }
    },
    tOnComplete = {
      {
        self.PrepFadeDownUp1,
        {self}
      }
    }
  })
end

function P1FP_EustacheSniper:PrepFadeDownUp1()
  EVENT_Timer("P1FP_EustacheSniper.PrepFadeDownUp2", self, 2)
  OnStaticConversationDisables()
end

function P1FP_EustacheSniper:PrepFadeDownUp2()
  Render.FadeTo(0, 0, 0, 255, 3)
  EVENT_Timer("P1FP_EustacheSniper.FadeDownUp", self, 3.5)
end

function P1FP_EustacheSniper:KillEscEvent()
  Util.KillEvent(self.eEscDetect)
  self:TASK_GetToTheNest()
end

function P1FP_EustacheSniper:EscalationListener()
  dprint(self, "Setting Escalation Listener  - clear Esc to get Fade Up/Down")
  self.eEscDetect = EVENT_OnEscalation("P1FP_EustacheSniper.TurnOffRadio", self, nil, false)
end

function P1FP_EustacheSniper:TurnOffRadio()
  if self:IsMissionTaskActive("P1FP_EustacheSniper.TASK_GetToTheNest") then
    self:ResetTaskByName("P1FP_EustacheSniper.TASK_GetToTheNest", true)
    self:TASK_LoseEscalation()
    dprint(self, "Escalated. Switching to LOSE HEAT task")
  elseif self:IsMissionTaskActive("P1FP_EustacheSniper.TASK_ScanStreets") then
    dprint(self, "Escalated. Fail in 5 seconds")
    EVENT_Timer("P1FP_EustacheSniper.FailTargetEsc", self, 5)
  elseif self:IsMissionTaskActive("P1FP_EustacheSniper.TASK_KillGeneral") then
    dprint(self, "Escalated. Target should be running now")
  end
end

function P1FP_EustacheSniper:Checkpoint1b()
  dprint(self, "Registered: CHECKPOINT 1b")
  OffStaticConversationDisables()
  self.TASK_GetToTheNest(self)
  EVENT_Stream("P1FP_EustacheSniper.InitPriests", self, self.tPriests, true)
  self:ArrivalSound()
end

function P1FP_EustacheSniper:InitPriests()
  Util.SetDynamicPriority("Human_CV_Priest", 500)
end

function P1FP_EustacheSniper:ArrivalSound()
  Sound.SetMusicLocale("fp_P1FP_EustacheSniper")
  Sound.SetMusicLocale("fp_P1FP_EustacheSniper", "arriveAtEustache")
end

function P1FP_EustacheSniper:TASK_LoseEscalation()
  self:CreateTask({
    sName = "P1FP_EustacheSniper.TASK_LoseEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    EscalationLevel = 0,
    bRepeatable = true,
    bNoRepeatAutoRebuild = true,
    tOnComplete = {
      {
        self.KillEscEvent,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function P1FP_EustacheSniper:FadeDownUp()
  self:CreateTask({
    sName = "P1FP_EustacheSniper.FadeDownUp",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "CIN_EustacheSniper_Fade",
    tSMEDNodes = {
      P1FP_EustacheSniper.PATH .. "actors",
      P1FP_EustacheSniper.PATH .. "nazis",
      P1FP_EustacheSniper.PATH .. "getaway"
    },
    tStaticTags = {
      "p1fp_eustache_chairs"
    },
    tOnActivate = {
      {
        self.SeatAttendees,
        {self}
      },
      {
        self.MissionSound,
        {self}
      },
      {
        EVENT_Stream,
        {
          "P1FP_EustacheSniper.LockGetawayCar",
          self,
          "Missions\\freeplay\\p1\\mis_eustache_sniper\\getaway\\VH_CV_CR_CeltaQuatre_01",
          true
        }
      }
    },
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "P1FP_EustacheSniper.Checkpoint2"
        }
      }
    }
  })
end

function P1FP_EustacheSniper:SeatAttendees()
  EVENT_Stream("P1FP_EustacheSniper.SitDown", self, self.tChairs, false)
end

function P1FP_EustacheSniper:SitDown()
  Util.SetDynamicPriority("Human_CV_UpperClass_M", 400)
  Util.SpawnEditNode("Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees.wsd")
end

function P1FP_EustacheSniper:TASK_ScanStreets()
  self:CreateTask({
    sName = "P1FP_EustacheSniper.TASK_ScanStreets",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "NONE",
    sObjectiveTextID = "P1FP_EustacheSniper_Text.TASK_ScanStreets",
    tLocators = {
      self.PATH .. "main\\LOC_SeePriest"
    },
    bNoWorldBlip = true,
    bNoHUDBlip = true,
    tOnActivate = {
      {
        self.ShootListener,
        {self}
      },
      {
        self.EscalationListener,
        {self}
      },
      {
        self.SniperZoomTut,
        {self}
      }
    }
  })
end

function P1FP_EustacheSniper:SniperZoomTut()
  Saboteur.ShowToolTip("TutorialTip_Text.Weapon_Sniper_Zoom")
end

function P1FP_EustacheSniper:TASK_KillGeneral()
  self:CreateTask({
    sName = "P1FP_EustacheSniper.TASK_KillGeneral",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P1FP_EustacheSniper_Text.TASK_KillGeneral",
    tTgtInclude = {
      self.hTargetCollaborator
    },
    tSMEDNodes = {},
    tOnActivate = {
      {
        self.TogglePhase,
        {self}
      },
      {
        EVENT_OnEscalation,
        {
          "P1FP_EustacheSniper.EscRunTarget",
          self,
          nil,
          false
        }
      },
      {
        self.CompleteTaskByName,
        {
          self,
          "P1FP_EustacheSniper.TASK_ScanStreets"
        }
      },
      {
        self.RedTarget,
        {self}
      }
    },
    tOnComplete = {
      {
        self.KillStreamOutEvent,
        {self}
      },
      {
        self.TASK_EscapeRetribution,
        {self}
      },
      {
        Cin.PlayConversation,
        {
          "P1FP_EustacheSniper_HitTarget"
        }
      }
    }
  })
end

function P1FP_EustacheSniper:RedTarget()
  Actor.SetForceRedInReticule(self.hTargetCollaborator, true)
end

function P1FP_EustacheSniper:KillStreamOutEvent()
  Util.KillEvent(self.eTargetStream)
  if self.tCountDown then
    Util.KillEvent(self.tCountDown)
  end
  Trigger.ClearCallback("Missions\\freeplay\\p1\\mis_eustache_sniper\\main\\PT_ExitMissionFail", self.eLeftMissionArea)
end

function P1FP_EustacheSniper:EscRunTarget()
  ScriptSequence.Kill(self.hTargetCollaborator)
  Nav.CancelScriptedPath(self.hTargetCollaborator)
  Nav.SetScriptedPath(self.hTargetCollaborator, self.sBailPath, true, "P1FP_EustacheSniper.TargetGetsAway", self)
  Nav.SetScriptedPathMoveMode(self.hTargetCollaborator, cMOVE_PANIC)
  ScriptSequence.Kill(self.hDenis)
  Actor.OverrideCombatAI(self.hDenis, true)
  Combat.SetIdleScripted(self.hDenis, true)
  Actor.EnableNeeds(self.hDenis, false)
  Nav.SetScriptedPath(self.hDenis, self.sLExitPath)
  Nav.SetScriptedPathMoveMode(self.hDenis, cMOVE_PANIC)
  for i = 1, #self.tAttendees do
    Actor.CancelAttrPt(Handle(self.tAttendees[i]))
  end
end

function P1FP_EustacheSniper:TASK_EscapeRetribution()
  self:CreateTask({
    sName = "TASK_EscapeRetribution",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "P1FP_EustacheSniper_Text.TASK_EscapeRetribution",
    EscalationLevel = 0,
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function P1FP_EustacheSniper:TogglePhase()
  self.tInfo.bIsTargetDetermined = true
end

function P1FP_EustacheSniper:OnComplete()
  Zone.SwitchState(self.PATH .. "WTF_Bourse", cZONESTATE_HIGHWTF, cENT_IMMEDIATE)
end

function P1FP_EustacheSniper:MovetheCongregation()
  dprint(self, "The Lion walks with the Lamb")
  local hRCongMember = Util.GetHandleByName(self.tCrowdRight[1 + self.tInfo.nCongregation])
  local hLCongMember = Util.GetHandleByName(self.tCrowdLeft[1 + self.tInfo.nCongregation])
  local hMCongMember = Util.GetHandleByName(self.tCrowdCenter[1 + self.tInfo.nCongregation])
  self.tInfo.nTries = self.tInfo.nTries + 1
  self.hLCongo = hLCongMember
  self.hRCongo = hRCongMember
  self.hMCongo = hMCongMember
  local nRandomizer = math.random(1, 12)
  dprint(self, nRandomizer)
  if self.tInfo.nTries == 3 then
    self.tInfo.nIsTarget = 2
    self.hTargetCollaborator = hMCongMember
    EVENT_ActorDamaged("P1FP_EustacheSniper.WaitFirstShot", self, self.hTargetCollaborator)
    self.eTargetStream = EVENT_StreamOut("P1FP_EustacheSniper.FailTargetEsc2", self, self.hTargetCollaborator, nil)
    self.nTargetMaxHealth = Object.GetMaxHealth(self.hTargetCollaborator)
    Actor.SetPanicEnabled(self.hTargetCollaborator, false)
    Actor.EnableNeeds(self.hTargetCollaborator, false)
  end
  if hLCongMember then
    Nav.SetScriptedPath(hLCongMember, self.sLeftPath, true, "P1FP_EustacheSniper.TestLineUp", self)
    Actor.CancelAttrPtRequest(hLCongMember)
  end
  if hMCongMember then
    Nav.SetScriptedPath(hMCongMember, self.hCenterPath, true, "P1FP_EustacheSniper.TestLineUp", self)
    Actor.CancelAttrPtRequest(hMCongMember)
  end
  if hRCongMember then
    Nav.SetScriptedPath(hRCongMember, self.sRightPath, true, "P1FP_EustacheSniper.TestLineUp", self)
    Actor.CancelAttrPtRequest(hRCongMember)
  end
end

function P1FP_EustacheSniper:TestLineUp()
  self.tInfo.nLineUp = self.tInfo.nLineUp + 1
  if self.tInfo.nLineUp == 3 then
    self.RunPenitentSequence(self)
    self.tInfo.nLineUp = 0
  end
end

function P1FP_EustacheSniper:DelaytoRun()
  Nav.SetScriptedPath(hRCongMember, self.sRightPath, false, "P1FP_EustacheSniper.RunPenitentSequence", self)
end

function P1FP_EustacheSniper:RunPenitentSequence()
  dprint(self, "My Child You Are Blessed")
  local tScriptedPrayer = {
    {
      "PLAYANIMATION",
      {
        "civ_kneel_harass_idle"
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
  local tScriptedBlessing = {
    {
      "PLAYANIMATION",
      {"nazi_point"}
    },
    {
      "DELAY",
      {3}
    },
    {
      "CANCELANIMATION"
    }
  }
  local tScriptedPrayer2 = {
    {
      "PLAYANIMATION",
      {
        "civ_kneel_harass_idle"
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
  local tScriptedBlessing2 = {
    {
      "PLAYANIMATION",
      {"nazi_point"}
    },
    {
      "DELAY",
      {3}
    },
    {
      "CANCELANIMATION"
    }
  }
  local tScriptedPrayer3 = {
    {
      "PLAYANIMATION",
      {
        "civ_kneel_harass_idle"
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
  local tScriptedBlessing3 = {
    {
      "PLAYANIMATION",
      {
        "civ_M_priest_blessing"
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
  local tKillThisDude = {
    {
      "PLAYANIMATION",
      {
        "civ_M_priest_look_up"
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
  dprint(self, "Left Side")
  local hRightPriest = Util.GetHandleByName(self.sRightPriest)
  local hLeftPriest = Util.GetHandleByName(self.sLeftPriest)
  self.hLeftPriest = hLeftPriest
  self.hRightPriest = hRightPriest
  if self.hLCongo then
    ScriptSequence.Run(self.hLCongo, tScriptedPrayer)
  end
  if self.tInfo.nIsTarget == 1 or self.tInfo.nIsTarget == 3 then
    ScriptSequence.Run(self.hMCongo, tScriptedPrayer3, P1FP_EustacheSniper.ExitCongMember, {self})
    Actor.PlayAnimation(self.hDenis, "civ_M_priest_blessing", 2)
    Cin.PlayConversation("P1FP_EustacheSniper_Blessing")
  elseif self.tInfo.nIsTarget == 2 then
    ScriptSequence.Run(self.hMCongo, tScriptedPrayer3, P1FP_EustacheSniper.ExitCongMemberKilla, {self})
    Actor.PlayAnimation(self.hDenis, "civ_M_priest_look_up", 2)
    Cin.PlayConversation("P1FP_EustacheSniper_Blessing_02", "P1FP_EustacheSniper.SeeTargetVO", self)
    self.tInfo.nIsTarget = 3
  end
  if self.hRCongo then
    ScriptSequence.Run(self.hRCongo, tScriptedPrayer2)
    ScriptSequence.Run(hRightPriest, tScriptedBlessing2)
  end
end

function P1FP_EustacheSniper:SeeTargetVO()
  if Object.IsAlive(self.hTargetCollaborator) then
    Cin.PlayConversation("P1FP_EustacheSniper_SeeTarget", "P1FP_EustacheSniper.TASK_KillGeneral", self)
  end
end

function P1FP_EustacheSniper:ExitCongMember()
  self.tInfo.nTriggerCall = self.tInfo.nTriggerCall + 1
  if self.hLCongo then
    Nav.SetScriptedPath(self.hLCongo, self.sLExitPath)
  end
  if self.hRCongo then
    Nav.SetScriptedPath(self.hRCongo, self.sRExitPath)
  end
  if self.hMCongo then
    Nav.SetScriptedPath(self.hMCongo, self.sMExitPath)
  end
  if self.tInfo.nTriggerCall == 1 then
    self.tInfo.nTriggerCall = 0
    self.tInfo.nCongregation = self.tInfo.nCongregation + 1
    self:MovetheCongregation()
  end
end

function P1FP_EustacheSniper:SetFlags()
  for i = 1, #self.tCrowdLeft do
    local hCon = Util.GetHandleByName(self.tCrowdLeft[i])
    Actor.EnableNeeds(hCon, false)
  end
  for i = 1, #self.tCrowdRight do
    local hRCon = Util.GetHandleByName(self.tCrowdRight[i])
    Actor.EnableNeeds(hRCon, false)
  end
  for i = 1, #self.tCrowdCenter do
    local hMCon = Util.GetHandleByName(self.tCrowdCenter[i])
    Actor.EnableNeeds(hMCon, false)
  end
end

function P1FP_EustacheSniper:ExitCongMemberKilla()
  if self.hLCongo then
    Nav.SetScriptedPath(self.hLCongo, self.sLExitPath)
  end
  if self.hRCongo then
    Nav.SetScriptedPath(self.hRCongo, self.sRExitPath)
  end
  if self.hMCongo then
    EVENT_Timer("P1FP_EustacheSniper.TargetLeaves", self, 8)
  end
  if self.tInfo.nTriggerCall == 1 then
    self.tInfo.nTriggerCall = 0
    self.tInfo.nCongregation = self.tInfo.nCongregation + 1
    self:MovetheCongregation()
  end
end

function P1FP_EustacheSniper:TargetLeaves()
  Nav.SetScriptedPath(self.hTargetCollaborator, self.sMExitPath, false, "P1FP_EustacheSniper.TargetGetsAway", self)
end

function P1FP_EustacheSniper:TargetGetsAway()
  Nav.BoardVehicle(self.hTargetCollaborator, self.hTargetCar, "BACKSEAT_R", cMOVE_PANIC, "P1FP_EustacheSniper.LimoEscapes", self)
end

function P1FP_EustacheSniper:LimoEscapes()
  Nav.SetScriptedPath(self.hTargetCar, self.sEscapePath, false, "P1FP_EustacheSniper.FailTargetEsc", self)
  Nav.SetScriptedPathSpeed(self.hTargetCar, 90)
end

function P1FP_EustacheSniper:LockGetawayCar()
  self.hTargetCar = Handle("Missions\\freeplay\\p1\\mis_eustache_sniper\\getaway\\VH_CV_CR_CeltaQuatre_01")
  Vehicle.LockAllSeats(self.hTargetCar, true)
end

function P1FP_EustacheSniper:ShootListener()
  self.hDenis = Util.GetHandleByName("Missions\\freeplay\\p1\\mis_eustache_sniper\\actors\\Spore_RS_FatherDenis")
  EVENT_ActorDamaged("P1FP_EustacheSniper.DenisDamaged", self, self.hDenis)
end

function P1FP_EustacheSniper:WaitFirstShot()
  EVENT_Timer("P1FP_EustacheSniper.CheckFirstShot", self, 0.5)
end

function P1FP_EustacheSniper:DenisDamaged(a_tCallbackData)
  dprint(self, "Denis down!")
  if a_tCallbackData[2] == Handle("Saboteur") then
    EVENT_Timer("P1FP_EustacheSniper.FailDenisDead", self, 1)
  end
end

function P1FP_EustacheSniper:CheckFirstShot()
  if self:IsMissionTaskActive("P1FP_EustacheSniper.TASK_ScanStreets") then
    EVENT_Timer("P1FP_EustacheSniper.FailShotFired", self, 3)
  end
  if Util.IsHandleValid(self.hTargetCollaborator) == true then
    local targetHealth = Object.GetHealth(self.hTargetCollaborator)
    if targetHealth == self.nTargetMaxHealth then
      Cin.PlayConversation("P1FP_EustacheSniper_MissTarget")
    elseif targetHealth < self.nTargetMaxHealth then
    end
  elseif Util.IsHandleValid(self.hTargetCollaborator) == false then
  end
  ScriptSequence.Kill(self.hTargetCollaborator)
  Nav.CancelScriptedPath(self.hTargetCollaborator)
  Nav.SetScriptedPath(self.hTargetCollaborator, self.sBailPath, true, "P1FP_EustacheSniper.TargetGetsAway", self)
  Nav.SetScriptedPathMoveMode(self.hTargetCollaborator, cMOVE_PANIC)
  ScriptSequence.Kill(self.hDenis)
  Actor.OverrideCombatAI(self.hDenis, true)
  Combat.SetIdleScripted(self.hDenis, true)
  Actor.EnableNeeds(self.hDenis, false)
  Nav.SetScriptedPath(self.hDenis, self.sLExitPath)
  Nav.SetScriptedPathMoveMode(self.hDenis, cMOVE_PANIC)
  for i = 1, #self.tAttendees do
    Actor.CancelAttrPt(Handle(self.tAttendees[i]))
  end
end

function P1FP_EustacheSniper:SetCivKillListeners()
  for i = 1, #self.tCrowdLeft do
    local hCivTarget = Util.GetHandleByName(self.tCrowdLeft[i])
    local tLeftKillEvent = {EventType = "DeathEvent", ObjectHandle = hCivTarget}
    Util.CreateEvent(tLeftKillEvent, "P1FP_EustacheSniper.OnCivDeath", self)
  end
  for i = 1, #self.tCrowdRight do
    local hCivRightTarget = Util.GetHandleByName(self.tCrowdRight[i])
    local tRightKillEvent = {EventType = "DeathEvent", ObjectHandle = hCivRightTarget}
    Util.CreateEvent(tRightKillEvent, "P1FP_EustacheSniper.OnCivDeath", self)
  end
  for i = 1, #self.tCrowdCenter do
    local hCivCenterTarget = Util.GetHandleByName(self.tCrowdCenter[i])
    local tCenterKillEvent = {EventType = "DeathEvent", ObjectHandle = hCivCenterTarget}
    Util.CreateEvent(tCenterKillEvent, "P1FP_EustacheSniper.OnCivDeath", self)
  end
end

function P1FP_EustacheSniper:OnCivDeath()
  if self.tInfo.bIsTargetDetermined == false then
    dprint(self, "CountdownEventStarted")
    self.tCountdown = {
      EventType = "TimerEvent",
      EventName = "Countdown",
      Time = 5
    }
    Util.CreateEvent(self.tCountdown, "P1FP_EustacheSniper.FailCivDeath", self)
  elseif self.tInfo.bIsTargetDetermined == true then
    dprint(self, "Dude On the Run")
  end
end

function P1FP_EustacheSniper:Reset()
  Sound.ResetMusicLocale()
  if Util.IsBlockLoaded("Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees.wsd") then
    Util.UnloadEditNode("Missions\\freeplay\\p1\\mis_eustache_sniper\\attendees.wsd", true)
  end
end

function P1FP_EustacheSniper:FailCivDeath()
  self:MissionTaskFail("P1FP_EustacheSniper_Text.Fail_CivKilled")
end

function P1FP_EustacheSniper:FailTargetEsc()
  self:MissionTaskFail("P1FP_EustacheSniper_Text.Fail_TargetEscaped")
end

function P1FP_EustacheSniper:FailTargetEsc2()
  self:MissionTaskFail("P1FP_EustacheSniper_Text.Fail_TargetEscaped")
end

function P1FP_EustacheSniper:FailShotFired()
  self:MissionTaskFail("P1FP_EustacheSniper_Text.Fail_ShotFired")
end

function P1FP_EustacheSniper:FailDenisDead()
  self:MissionTaskFail("Char_Death.RS_FatherDenis")
end

function P1FP_EustacheSniper:FailPlayerLeft()
  if not self:IsMissionTaskActive("TASK_EscapeRetribution") then
    self:MissionTaskFail("P1FP_EustacheSniper_Text.Fail_PlayerLeft")
  end
end
