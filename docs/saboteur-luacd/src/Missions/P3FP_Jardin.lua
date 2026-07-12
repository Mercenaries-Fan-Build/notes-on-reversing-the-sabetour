if P3FP_Jardin == nil then
  P3FP_Jardin = SabTaskObjective:Create()
  P3FP_Jardin.PATH = "Missions\\freeplay\\p3\\mis_jardin\\"
  P3FP_Jardin:Configure({
    TaskCount = 999,
    sStarter = "Luc_LaVillette_Interior",
    bFreeplay = true,
    sConvFile = "P3FP_Jardin_Start",
    sSaveMissionNameID = "MissionNames_Text.P3FP_Jardin",
    tUnlockList = {
      "Connect_ST_318_RaceComing"
    },
    tSMEDNodes = {
      P3FP_Jardin.PATH .. "main",
      P3FP_Jardin.PATH .. "CarNode"
    },
    tStaticTags = {
      "Jardin_Props"
    }
  })
end

function P3FP_Jardin:STARTER_Setup()
  Util.SetDynamicPriority("VH_CV_CR_Peugeot402_01", 1500)
end

function P3FP_Jardin:Activated()
  self.sDebugLabel = "JARDIN"
  self.bDebugMode = true
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.SetupCheckpoint(self, 1)
end

function P3FP_Jardin:GENERAL_Setup()
  self.hLuc = Handle(self.PATH .. "main\\Luc")
  self.hDuval = Handle(self.PATH .. "main\\Duval")
  self.hOtherGuy = Handle(self.PATH .. "main\\OtherGuy")
  self.hCarDestroyedEvent = nil
  self.NaziDeathCount = 0
  self.NazisSpawned = 0
  self.NaziDeathEvent = nil
  self.EscapeTimer = nil
  self.NaziQuota = 6
end

function P3FP_Jardin:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "P3FP_Jardin.DoCheckpoint")
end

function P3FP_Jardin:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  Util.SetDynamicPriority("VH_CV_CR_Peugeot402_01", 1500)
  if nCP == 1 then
    self.TASK_GetLucToMeeting(self)
    self.TASK_ExitLaVillette(self)
  elseif nCP == 2 then
    Inventory.GiveItem(self.hLuc, "WP_MG_MP40", false)
    if not self:IsMissionTaskActive("TASK_GetLucToMeeting") then
      self.TASK_GetLucToMeeting(self)
    end
  elseif nCP == 3 then
    Inventory.GiveItem(self.hLuc, "WP_MG_MP40", false)
    Inventory.GiveItem(self.hDuval, "WP_PS_WaltherPPK", false)
    Inventory.GiveItem(self.hOtherGuy, "WP_PS_WaltherPPK", false)
    self.NaziSpawn(self)
  end
end

function P3FP_Jardin:TASK_ExitLaVillette()
  Nav.FollowObject(Handle("Missions\\paris_1\\characters\\lavillette\\luc_interior\\Luc_LaVillette_Interior"), hSab, 3, true, false, false)
  Sound.LoadSoundBank("m_P3FP_Jardin.bnk")
  self:CreateTask({
    sName = "TASK_ExitLaVillette",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "LaVillette",
    bInteriorTask = true,
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 2}
      },
      {
        EVENT_Timer,
        {
          "P3FP_Jardin.AutoTalk",
          self,
          2
        }
      }
    }
  })
end

function P3FP_Jardin.ClearIntLucAttrPt(_)
  Actor.CancelAttrPtRequest(Handle("Missions\\paris_1\\characters\\lavillette\\luc_interior\\Luc_LaVillette_Interior"))
end

function P3FP_Jardin:TASK_GetLucToMeeting()
  Combat.SetLeader(Handle("Missions\\freeplay\\p3\\mis_jardin\\main\\Luc"), hSab, false, 5, 20)
  Combat.AddTargetFlag(self.hOtherGuy, cTARGET_NOAUTORESPONSE)
  Combat.AddTargetFlag(self.hDuval, cTARGET_NOAUTORESPONSE)
  hSecurityEnterTrigger = Handle("Missions\\freeplay\\p3\\mis_jardin\\main\\PT_SecurityPoint")
  hSecurityExitTrigger = Handle("Missions\\freeplay\\p3\\mis_jardin\\main\\PT_SecurityPointExit")
  EVENT_PlayerEntersTrigger("P3FP_Jardin.Security_VO", self, hSecurityEnterTrigger)
  EVENT_PlayerEntersTrigger("P3FP_Jardin.Post_Security_VO", self, hSecurityExitTrigger)
  self:CreateTask({
    sName = "TASK_GetLucToMeeting",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    tDeliverObjs = {
      self.PATH .. "main\\Luc"
    },
    bEscalationDenial = true,
    sPickupTextID = "P3FP_Jardin_Text.TASK_GetLucToMeeting_sPickupTextID",
    sDropoffTextID = "P3FP_Jardin_Text.TASK_GetLucToMeeting_sDropoffTextID",
    sVehicleFetchID = "GenericObjective_Text.Vehicle_GetIn_A",
    sVehicleReturnID = "GenericObjective_Text.Vehicle_GetInBack_A",
    tPickupProxObj = {
      self.PATH .. "main\\Luc"
    },
    PickupProximity = 7,
    bGroundBlip = true,
    tDestRegion = {
      self.PATH .. "main\\PT_DuvalTrig"
    },
    tDestLocators = {
      self.PATH .. "main\\LOC_DuvalDest"
    },
    sDropOffConv = "P3FP_Jardin_Arrived",
    tOnArrive = {
      {
        Cin.StopConversation,
        {
          "P3FP_Jardin_Wrap_Up"
        }
      },
      {
        Inventory.GiveItem,
        {
          self.hLuc,
          "WP_MG_MP40",
          false
        }
      },
      {
        Inventory.GiveItem,
        {
          self.hDuval,
          "WP_PS_WaltherPPK",
          false
        }
      },
      {
        Inventory.GiveItem,
        {
          self.hOtherGuy,
          "WP_PS_WaltherPPK",
          false
        }
      }
    },
    tOnWait = {},
    tOnPickup = {
      {
        Inventory.GiveItem,
        {
          self.hLuc,
          "WP_MG_MP40",
          false
        }
      },
      {
        self.SetupDelayInCarConvo,
        {self}
      }
    },
    tOnActivate = {
      {
        self.SetupMeetingEscalation,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TASK_FollowLuc,
        {self}
      }
    }
  })
end

function P3FP_Jardin:AutoTalk()
  Cin.PlayConversation("P3FP_Jardin_On_Way")
end

function P3FP_Jardin:SetupMeetingEscalation()
  self.uMeetingEscalationEvent1 = EVENT_OnEscalation("P3FP_Jardin.MeetingEscalationTriggered", self)
  self.uMeetingEscalationEvent2 = EVENT_PlayerEntersTrigger("P3FP_Jardin.MeetingPTTriggered", self, Handle("Missions\\freeplay\\p3\\mis_jardin\\main\\PT_Escalation_Meeting"))
end

function P3FP_Jardin:MeetingEscalationTriggered()
  self.uTempTrigger = EVENT_PlayerEntersTrigger("P3FP_Jardin.EscalationFail", self, "Missions\\freeplay\\p3\\mis_jardin\\main\\PT_Escalation_Meeting")
  EVENT_Timer("P3FP_Jardin.KillTempEvent", self, 0.5)
  self.uMeetingEscalationEvent3 = EVENT_EscalationFree("P3FP_Jardin.MeetingEscalationReTriggered", self)
end

function P3FP_Jardin:MeetingEscalationReTriggered()
  Trigger.ClearCallback(Handle("Missions\\freeplay\\p3\\mis_jardin\\main\\PT_Escalation_Meeting"), self.uTempTrigger)
  self.uMeetingEscalationEvent4 = EVENT_OnEscalation("P3FP_Jardin.MeetingEscalationTriggered", self)
end

function P3FP_Jardin:MeetingPTTriggered()
  if Suspicion.GetEscalation() > 0 then
    self.MissionTaskFail(self, "P3FP_Jardin_Text.FAIL_Escalation")
  end
  self.uMeetingEscalationEvent5 = EVENT_PlayerExitsTrigger("P3FP_Jardin.MeetingPTReTriggered", self, "Missions\\freeplay\\p3\\mis_jardin\\main\\PT_Escalation_Meeting")
end

function P3FP_Jardin:MeetingPTReTriggered()
  self.uMeetingEscalationEvent6 = EVENT_PlayerEntersTrigger("P3FP_Jardin.MeetingPTTriggered", self, "Missions\\freeplay\\p3\\mis_jardin\\main\\PT_Escalation_Meeting")
end

function P3FP_Jardin:KillTempEvent()
  Trigger.ClearCallback(Handle("Missions\\freeplay\\p3\\mis_jardin\\main\\PT_Escalation_Meeting"), self.uTempTrigger)
end

function P3FP_Jardin:EscalationFail()
  self.MissionTaskFail(self, "P3FP_Jardin_Text.FAIL_Escalation")
end

function P3FP_Jardin:SetupDelayInCarConvo()
  EVENT_Timer("P3FP_Jardin.DelayInCarConvo", self, 10)
end

function P3FP_Jardin:DelayInCarConvo()
  ConvoHelper.InterruptReplay("P3FP_JARDIN_DRIVE_TO_MEET", "P3FP_Jardin-Drive01")
end

function P3FP_Jardin:TASK_StreamLuc()
  EVENT_Stream("P3FP_Jardin.TASK_FollowLuc", self, self.hLuc, true)
end

function P3FP_Jardin:Security_VO()
  Cin.PlayConversation("P3FP_JARDIN_PAPERS")
end

function P3FP_Jardin:Post_Security_VO()
  ConvoHelper.InterruptReplay("P3FP_JARDIN_WRAP_UP", "P3FP_Jardin-Drive02")
end

function P3FP_Jardin:TASK_FollowLuc()
  self:CreateTask({
    sName = "TASK_FollowLuc",
    sTaskType = "SabTaskObjectiveDeliver",
    Proximity = 5,
    sTaskSubType = "DELIVER",
    tDestProximityObj = {
      Handle("Missions\\freeplay\\p3\\mis_jardin\\main\\LOC_Sean_Conv")
    },
    tDeliverObjs = {
      self.hLuc
    },
    sObjectiveTextID = "P3FP_Jardin_Text.Task_Follow_Luc",
    tOnActivate = {
      {
        Util.SetDisableControls,
        {"Gas", false}
      },
      {
        Util.SetDisableControls,
        {"Break", false}
      },
      {
        Util.SetDisableControls,
        {
          "EnterExitVehicle",
          false
        }
      },
      {
        self.CheckIfLucInTaxi,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TASK_WatchForTrouble,
        {self}
      }
    }
  })
  Nav.SetScriptedPath(self.hLuc, self.PATH .. "main\\PA_LucToDuval", true, "P3FP_Jardin.TestLuc", self)
  Nav.SetScriptedPathMoveMode(self.hLuc, true)
  EVENT_ActorEntersTrigger("P3FP_Jardin.SetLucIdle", self, self.hLuc, "Missions\\freeplay\\p3\\mis_jardin\\main\\PT_FollowLuc")
  Nav.FollowObject(self.hDuval, Handle("Missions\\freeplay\\p3\\mis_jardin\\main\\LOC_Duval_Walkto"), 0, true)
  Nav.FollowObject(self.hOtherGuy, Handle("Missions\\freeplay\\p3\\mis_jardin\\main\\LOC_Margot_Walkto"), 0, true)
end

function P3FP_Jardin:CheckIfLucInTaxi()
  if Actor.IsInVehicle(self.hLuc) then
    Actor.UnboardVehicle(self.hLuc)
  end
end

function P3FP_Jardin:TestLuc()
  self:CheckIfLucInTaxi()
  local hTestLoc = Handle("Missions\\freeplay\\p3\\mis_jardin\\main\\LOC_Duval_Walkto")
  if hTestLoc and self.hLuc and Object.GetDistance(self.hLuc, hTestLoc) > 10 then
    Nav.SetScriptedPath(self.hLuc, self.PATH .. "main\\PA_LucToDuval", true, "P3FP_Jardin.TestLuc", self)
    Nav.SetScriptedPathMoveMode(self.hLuc, true)
  end
end

function P3FP_Jardin:SetLucIdle()
  Combat.SetIdleScripted(self.hLuc, true)
  Nav.FollowObject(self.hLuc, Handle("Missions\\freeplay\\p3\\mis_jardin\\main\\LOC_Luc_Walkto"), 0, true)
end

function P3FP_Jardin:TASK_WatchForTrouble()
  self:CreateTask({
    sName = "TASK_WatchForTrouble",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sConvFile = "P3FP_Jardin_Meeting",
    tTgtInclude = {
      self.PATH .. "main\\Duval"
    },
    sObjectiveTextID = "P3FP_Jardin_Text.TASK_TalkDuval",
    tOnActivate = {
      {
        Sound.SetMusicLocale,
        {
          "fp_P3FP_Jardin"
        }
      },
      {
        Sound.SetMusicLocale,
        {
          "fp_P3FP_Jardin",
          "convoStart"
        }
      }
    },
    tOnComplete = {
      {
        Nav.CancelScriptedPath,
        {
          self.hLuc
        }
      },
      {
        Combat.ClearTargetFlags,
        {
          self.hOtherGuy
        }
      },
      {
        Combat.ClearTargetFlags,
        {
          self.hDuval
        }
      },
      {
        self.SetupCheckpoint,
        {self, 3}
      }
    }
  })
end

function P3FP_Jardin:NaziSpawn()
  if self.uMeetingEscalationEvent6 then
    Trigger.ClearCallback(Handle("Missions\\freeplay\\p3\\mis_jardin\\main\\PT_Escalation_Meeting"), self.uMeetingEscalationEvent6)
  end
  if self.uMeetingEscalationEvent5 then
    Trigger.ClearCallback(Handle("Missions\\freeplay\\p3\\mis_jardin\\main\\PT_Escalation_Meeting"), self.uMeetingEscalationEvent5)
  end
  if self.uMeetingEscalationEvent4 then
    Util.KillEvent(self.uMeetingEscalationEvent4)
  end
  if self.uMeetingEscalationEvent3 then
    Util.KillEvent(self.uMeetingEscalationEvent3)
  end
  if self.uMeetingEscalationEvent2 then
    Trigger.ClearCallback(Handle("Missions\\freeplay\\p3\\mis_jardin\\main\\PT_Escalation_Meeting"), self.uMeetingEscalationEvent2)
  end
  if self.uMeetingEscalationEvent1 then
    Util.KillEvent(self.uMeetingEscalationEvent1)
  end
  Suspicion.EnableEscalationVehicles(false)
  EVENT_Timer("P3FP_Jardin.AmbushVODelay", self, 0.3)
  Util.SpawnEditNode("Missions\\freeplay\\p3\\mis_jardin\\Spawners.wsd")
  self.NaziDeathEvent = Util.CreateEvent({
    EventType = "Soldier.OnDeath"
  }, "P3FP_Jardin.NaziDied", self, {}, true)
  self:RegisterEvent(self.NaziDeathEvent)
  Squad.Create("Squad_Luc")
  Squad.AddMember("Squad_Luc", self.hLuc)
  Squad.AddMember("Squad_Luc", self.hDuval)
  Squad.AddMember("Squad_Luc", self.hOtherGuy)
  Squad.AddMember("Squad_Luc", hSab)
  Squad.SetLeader("Squad_Luc", hSab)
  Squad.SetRadius("Squad_Luc", 15)
  Combat.SetSquadAssist(self.hLuc, true)
  Combat.SetSquadAssist(self.hDuval, true)
  Combat.SetSquadAssist(self.hOtherGuy, true)
  Squad.SetLethal("Squad_Luc", true)
  Combat.SetLeader(self.hLuc, hSab, false, 5, 15)
  Combat.SetLeader(self.hDuval, hSab, false, 5, 15)
  Combat.SetLeader(self.hOtherGuy, hSab, false, 5, 15)
  P3FP_Jardin.KillTaskByName(P3FP_Jardin, "TASK_WatchForTrouble")
  P3FP_Jardin:CreateTask({
    sName = "FakeyDefend",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "DEFEND",
    tTgtInclude = {
      P3FP_Jardin.hDuval,
      P3FP_Jardin.hLuc,
      P3FP_Jardin.hOtherGuy
    },
    sObjectiveTextID = "P3FP_Jardin_Text.Task_Fend_Ambush",
    tOnActivate = {
      {
        Inventory.GiveItem,
        {
          self.hDuval,
          "WP_PS_WaltherPPK",
          false
        }
      },
      {
        Inventory.GiveItem,
        {
          self.hOtherGuy,
          "WP_PS_WaltherPPK",
          false
        }
      },
      {
        Suspicion.SetEscalationLevel,
        {3}
      },
      {
        Suspicion.SetEscalated
      }
    },
    tOnComplete = {}
  })
  P3FP_Jardin.EscapeTimer = EVENT_Timer("P3FP_Jardin.TASK_DeliverLeadersToCatacombs", P3FP_Jardin, 30)
  self.eKillSomeone = EVENT_ActorToActorProximityNegated("P3FP_Jardin.KillSomeone", self, hSab, self.hDuval, 80)
end

function P3FP_Jardin:KillSomeone()
  Object.Kill(self.hDuval)
end

function P3FP_Jardin:NaziDied()
  self.NaziQuota = self.NaziQuota - 1
  if self.NaziQuota == 0 then
    Util.KillEvent(P3FP_Jardin.EscapeTimer)
    self:TASK_DeliverLeadersToCatacombs()
  end
end

function P3FP_Jardin:AmbushVODelay()
  Sound.LoadSoundBank("m_P3FP_Jardin", "P3FP_Jardin.WhistleDelay", self)
  Sound.PlayOwnerlessSoundEvent("Amb_P3FP_Jardin_NaziWhistle")
  Cin.PlayConversation("P3FP_Jardin_Meeting_Ambush")
end

function P3FP_Jardin:WhistleDelay()
  Sound.PlayOwnerlessSoundEvent("Amb_P3FP_Jardin_NaziWhistle")
  EVENT_Timer("P3FP_Jardin.WhistleUnload", self, 3)
end

function P3FP_Jardin:WhistleUnload()
  Sound.ReleaseSoundBank("m_P3FP_Jardin")
end

function P3FP_Jardin:TASK_DeliverLeadersToCatacombs()
  self.NaziDeathCount = -1
  Util.KillEvent(self.NaziDeathEvent)
  EVENT_Timer("P3FP_Jardin.SetUpEscalationVehiclesOn", self, 15)
  self:CreateTask({
    sName = "TASK_DeliverLeadersToCatacombs",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    tDestRegion = {
      self.PATH .. "main\\PT_Cat"
    },
    tDestLocators = {
      self.PATH .. "main\\LOC_CatDest"
    },
    tDeliverObjs = {
      self.hLuc,
      self.hDuval,
      self.hOtherGuy
    },
    tPickupProxObj = {
      self.hLuc,
      self.hDuval,
      self.hOtherGuy
    },
    Proximity = 100,
    sPickupTextID = "P3FP_Jardin_Text.TASK_PickUpLeaders",
    sDropoffTextID = "P3FP_Jardin_Text.TASK_DeliverLeadersToCatacombs",
    sVehicleFetchID = "GenericObjective_Text.Vehicle_GetIn_A",
    bGroundBlip = true,
    bEscalationDenial = true,
    sDropOffConv = "P3FP_Jardin_Complete",
    bNoDumping = true,
    tOnActivate = {
      {
        Cin.StopConversation,
        {
          "P3FP_Jardin_Meeting"
        }
      },
      {
        Cin.PlayConversation,
        {
          "P3FP_Jardin_Ambushed"
        }
      },
      {
        Squad.FollowLeader,
        {"Squad_Luc"}
      }
    },
    tOnPickup = {
      {
        self.KillTaskByName,
        {
          self,
          "FakeyDefend"
        }
      },
      {
        self.SetupEscapeConvos,
        {self}
      }
    },
    tOnComplete = {
      {
        Squad.Delete,
        {"Squad_Luc"}
      },
      {
        Actor.UnboardVehicle,
        {hSab}
      },
      {
        self.EndMissionTimer,
        {self}
      }
    }
  })
end

function P3FP_Jardin:CallUnboardVeh()
  local hVeh1 = Actor.GetVehicle(hSab)
  Vehicle.UnboardAll(hVeh1, false, nil, nil, nil, self, nil, "P3FP_Jardin.EndMissionTimer", self)
end

function P3FP_Jardin:EndMissionTimer()
  EVENT_Timer("P3FP_Jardin.FadeOut", self, 3)
end

function P3FP_Jardin:FadeOut()
  Render.FadeTo(0, 0, 0, 255, 0.5)
  EVENT_Timer("P3FP_Jardin.FadeIn", self, 2)
  EVENT_Timer("P3FP_Jardin.UnloadNodes", self, 0.5)
end

function P3FP_Jardin:FadeIn()
  Render.FadeTo(0, 0, 0, 0, 0.5)
  EVENT_Timer("P3FP_Jardin.EndMission", self, 0.25)
end

function P3FP_Jardin:EndMission()
  self:CompleteThisMission()
end

function P3FP_Jardin:SetUpEscalationVehiclesOn()
  Suspicion.EnableEscalationVehicles(true)
end

function P3FP_Jardin:SetupEscapeConvos()
  Cin.PlayConversation("P3FP_Jardin_InCar", "P3FP_Jardin.PlayEscapeConvos1", self)
  if self.eKillSomeone then
    Util.KillEvent(self.eKillSomeone)
  end
end

function P3FP_Jardin:PlayEscapeConvos1()
  EVENT_Timer("P3FP_Jardin.PlayEscapeConvos1Delayed", self, 5)
end

function P3FP_Jardin:PlayEscapeConvos1Delayed()
  Cin.PlayConversation("P3FP_Jardin_Betrayed", "P3FP_Jardin.PlayEscapeConvos2", self)
end

function P3FP_Jardin:PlayEscapeConvos2()
  EVENT_EscalationFree("P3FP_Jardin.PlayEscapeConvos3", self)
end

function P3FP_Jardin:PlayEscapeConvos3()
  Cin.StopConversation("P3FP_Jardin_Betrayed")
  Sound.ResetMusicLocale()
  EVENT_Timer("P3FP_Jardin.PlayEscapeConvos3Delayed", self, 3)
end

function P3FP_Jardin:PlayEscapeConvos3Delayed()
  Cin.StopConversation("P3FP_Jardin_Betrayed")
  ConvoHelper.InterruptReplay("P3FP_Jardin_EscalationEnds", "P3FP_Jardin-EscalationEnds")
end

function P3FP_Jardin:UnloadNodes()
  Util.UnloadEditNode(P3FP_Jardin.PATH .. "main.wsd", true)
  Util.UnloadEditNode(P3FP_Jardin.PATH .. "Spawners.wsd", true)
end

function P3FP_Jardin:EscapeVO()
  EVENT_Timer("Cin.PlayConversation", self, 5, {
    "P3FP_Jardin_Betrayed"
  })
end

function P3FP_Jardin:MISSION_ONRESET()
  Util.SetDynamicPriority("VH_CV_CR_Peugeot402_01", -1)
  Sound.ReleaseSoundBank("m_P3FP_Jardin.bnk")
  self:UnloadNodes()
  Sound.ResetMusicLocale()
end
