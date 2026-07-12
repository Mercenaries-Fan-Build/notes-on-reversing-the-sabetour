if SOE_2_Mission_2_ConnectB == nil then
  SOE_2_Mission_2_ConnectB = SabTaskObjective:Create()
  SOE_2_Mission_2_ConnectB:Configure({
    TaskCount = 99,
    bStarterless = true,
    MCDisplayID = 2,
    sSaveMissionNameID = "MissionNames_Text.S2M2",
    bDisableMissionTitle = true,
    sHQStartPoint = _cHQe_POSTTRAIN,
    tUnlockList = {
      "Connect_ST_316_VeroDistrustsSkylar",
      "Connect_ST_P3_Need",
      "NOTE_FP_CountryChateau",
      "FP_AMB_ChambordStart"
    },
    tSMEDNodes = {
      "Missions\\paris_6\\mission_1\\GoBackToHQ",
      "Missions\\hq_dropoff\\p1hq"
    }
  })
end

function SOE_2_Mission_2_ConnectB:STARTER_Setup()
  self.sDebugLabel = "s2m2b"
  self.bDebugMode = false
  Util.SetDynamicPriority("VH_CV_CR_Citroen6C_01", 1500)
end

function SOE_2_Mission_2_ConnectB:Activated()
  SabTaskObjective.Activated(self)
  self.bJustPlayedTrainMission = false
  self.bUnloadedKesslerAndSkylar = false
  if Handle("Missions\\soe_2\\mission_2\\kesslerandskylar\\Skylar") ~= nil or Handle("Missions\\soe_2\\mission_2\\kesslerandskylar\\Kessler") ~= nil then
    self.bJustPlayedTrainMission = true
  end
  if self.bJustPlayedTrainMission == false then
    self:CreateTask({
      sName = "Missions\\soe_2\\mission_2\\KesslerAndSkylar",
      sTaskType = "SabTaskObjectiveEmpty",
      sTaskSubType = "None",
      tSMEDNodes = {
        "Missions\\soe_2\\mission_2\\KesslerAndSkylar"
      },
      tOnActivate = {
        {
          self.Checkpoint0,
          {self}
        }
      }
    })
    self:CreateTask({
      sName = "Missions\\soe_2\\mission_2\\kesslerandskylarcar",
      sTaskType = "SabTaskObjectiveEmpty",
      sTaskSubType = "None",
      tSMEDNodes = {
        "Missions\\soe_2\\mission_2\\kesslerandskylarcar"
      }
    })
  else
    self.Checkpoint0(self)
  end
end

function SOE_2_Mission_2_ConnectB:Checkpoint0()
  self.RegisterCheckpoint(self, "SOE_2_Mission_2_ConnectB.GENERAL_Setup")
end

function SOE_2_Mission_2_ConnectB:GENERAL_Setup()
  Convo.ResetForFail()
  Util.UnregisterLuaUpdate("SOE_2_Mission_2_ConnectB.CheckDistanceAndInCarAndEtc")
  local sObjCarriedOver = "Missions\\soe_2\\mission_2\\KesslerAndSkylar\\Kessler"
  self.sSMEDDynamicNode = "Missions\\soe_2\\mission_2\\KesslerAndSkylar"
  self.sDestinationLocator = "Missions\\soe_2\\mission_2\\KesslerAndSkylar\\LOC_HQ"
  self.sDropOffTrigger = "Missions\\soe_2\\mission_2\\KesslerAndSkylar\\PT_HQ"
  self.sMasterObjective = "GenericObjective_Text.HQ_P1_Return"
  self.sTaxiCarObjective = "GenericObjective_Text.Vehicle_Get_A"
  self.sTaxiPickupObjective = "S2M2b_Text.PickupSkylarandKessler"
  self.sTaxiDropOffObjective = "GenericObjective_Text.HQ_P1_GoTo"
  self.hObjectHandle = Util.GetHandleByName(sObjCarriedOver)
  self.sObjectString = sObjCarriedOver
  self.Ready(self)
  local hSkylar = Handle(self.sObjectString)
  local hKessler = Handle("Missions\\soe_2\\mission_2\\KesslerAndSkylar\\Skylar")
  Combat.SetGrabbable(hSkylar, false)
  Combat.SetGrabbable(hKessler, false)
  Actor.SetLabel(hSkylar, "nopush", true)
  Actor.SetUseHitReactions(hSkylar, false)
  Actor.SetLabel(hKessler, "nopush", true)
  Actor.SetUseHitReactions(hKessler, false)
end

function SOE_2_Mission_2_ConnectB:ItHasEscalatedBeforeMeeting()
  self:FailTaskByName("MeetUpWithSkylar")
  if self.tSaveInfo.nReset == 0 then
    self:CreateTask({
      sName = "cooldownbeforetalking",
      sTaskType = "SabTaskObjectiveEscalation",
      sTaskSubType = "None",
      sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
      EscalationLevel = 0,
      tOnComplete = {
        {
          self.ReEnableTasks,
          {self}
        }
      }
    })
  else
    self:ResetTaskByName("cooldownbeforetalking")
  end
  self.tSaveInfo.nReset = 1
end

function SOE_2_Mission_2_ConnectB:ReEnableTasks()
  self:ResetTaskByName("MeetUpWithSkylar")
  self:ResetTaskByName("escalatedbeforemeeting")
end

function SOE_2_Mission_2_ConnectB:MeetUpWithSkylar()
  self:CreateTask({
    sName = "MeetUpWithSkylar",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "S2M2b_Text.MeetupwithSkylar",
    Proximity = 0.5,
    sTaskSubType = "DELIVER",
    tDestProximityObj = {
      "Missions\\soe_2\\mission_2\\KesslerAndSkylar\\Skylar"
    },
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.TASK_TaxiTask,
        {self}
      }
    }
  })
  self:CreateTask({
    sName = "escalatedbeforemeeting",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = true,
    tOnComplete = {
      {
        self.ItHasEscalatedBeforeMeeting,
        {self}
      }
    }
  })
  Util.RegisterLuaUpdate("SOE_2_Mission_2_ConnectB.CheckDistanceAndInCarAndEtc", self)
end

function SOE_2_Mission_2_ConnectB:CheckDistanceAndInCarAndEtc()
  if Object.GetDistance(hSab, Handle("Missions\\soe_2\\mission_2\\KesslerAndSkylar\\Skylar")) < 3 and Actor.IsInVehicle(hSab) == false and Suspicion.GetEscalation() == 0 then
    self:CompleteTaskByName("MeetUpWithSkylar")
    Util.UnregisterLuaUpdate("SOE_2_Mission_2_ConnectB.CheckDistanceAndInCarAndEtc")
  end
end

function SOE_2_Mission_2_ConnectB:FailForStreamingOut()
  self:MissionTaskFail("GenericFail_Text.ABANDON_GEN_Followers")
end

function SOE_2_Mission_2_ConnectB:OnObjectLoad()
  local sObjLoaded = "Missions\\soe_2\\mission_2\\KesslerAndSkylar\\Kessler"
  if Util.GetHandleByName(sObjLoaded) then
    self.hObjectHandle = Util.GetHandleByName(sObjLoaded)
    self.sObjectString = sObjLoaded
  else
  end
  SOE_2_Mission_2_ConnectB:Ready()
end

function SOE_2_Mission_2_ConnectB:Ready()
  self.tTaxiDeliverObjs = {
    self.sObjectString,
    "Missions\\soe_2\\mission_2\\KesslerAndSkylar\\Skylar"
  }
  self:TASK_FirstTask()
end

function SOE_2_Mission_2_ConnectB:TASK_FirstTask()
  self.tSaveInfo.nReset = 0
  self:CreateTask({
    sName = "TASK_FirstTask",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    tLocators = {},
    tOnActivate = {
      {
        self.MeetUpWithSkylar,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function SOE_2_Mission_2_ConnectB:FarAway()
  Convo.AddConvo("S2M2b_Group_Abandoned", 10, {})
  local tEvent = {
    EventType = "ProximityEvent",
    ObjectA = hSab,
    ObjectB = self.hObjectHandle,
    Proximity = 10,
    Negate = false
  }
  self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2_ConnectB.GotBack", self))
end

function SOE_2_Mission_2_ConnectB:GotBack()
  Convo.AddConvo("S2M2b_Group_Return", 10, {})
end

function SOE_2_Mission_2_ConnectB:WaitforSin()
  local hSkylar = Handle(self.sObjectString)
  local hKessler = Handle("Missions\\soe_2\\mission_2\\KesslerAndSkylar\\Skylar")
  if Cin.IsHumanInConversation(hSkylar) ~= false or Cin.IsHumanInConversation(hSab) ~= false or Cin.IsHumanInConversation(hKessler) == false then
  end
end

function SOE_2_Mission_2_ConnectB:CloseToHQ()
  Render.FadeScreen(false)
  Convo.AddConvo("S2M2b_NearHQ", 10, {})
end

function SOE_2_Mission_2_ConnectB:Maria2convo()
  local tEvent = {EventType = "TimerEvent", Time = 13}
  self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2_ConnectB.PlayMariaConvo", self))
end

function SOE_2_Mission_2_ConnectB:PlayMariaConvo()
  ConvoHelper.InterruptReplay("314_Con_Maria_02", "maria2", nil, nil, nil)
end

function SOE_2_Mission_2_ConnectB:TimerCheckConvo()
  local hSkylar = Handle(self.sObjectString)
  local hKessler = Handle("Missions\\soe_2\\mission_2\\KesslerAndSkylar\\Skylar")
  if Actor.IsInVehicle(hSab) and self.hObjectHandle ~= nil and Actor.IsInVehicle(self.hObjectHandle) then
    if Cin.IsHumanInConversation(hSkylar) == false and Cin.IsHumanInConversation(hSab) == false and Cin.IsHumanInConversation(hKessler) == false then
      self.tSaveInfo.nCounter = self.tSaveInfo.nCounter + 1
    end
    if self.tSaveInfo.nCounter >= 15 and self.tSaveInfo.bConvMaria == nil then
      self.tSaveInfo.bConvMaria = true
      Convo.AddConvo("314_Con_Maria", 10, {})
      ConvoHelper.InterruptReplay("314_Con_Maria", "maria1", "SOE_2_Mission_2_ConnectB.Maria2convo", self, {10})
      local tTimerEvent = {EventType = "TimerEvent", Time = 1}
      self:RegisterEvent(Util.CreateEvent(tTimerEvent, "SOE_2_Mission_2_ConnectB.TimerCheckConvo", self))
    elseif self.tSaveInfo.nCounter >= 30 and self.tSaveInfo.bConvMaria2 == nil then
      self.tSaveInfo.bConvMaria2 = true
    else
      local tTimerEvent = {EventType = "TimerEvent", Time = 1}
      self:RegisterEvent(Util.CreateEvent(tTimerEvent, "SOE_2_Mission_2_ConnectB.TimerCheckConvo", self))
    end
  else
    local tTimerEvent = {EventType = "TimerEvent", Time = 1}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "SOE_2_Mission_2_ConnectB.TimerCheckConvo", self))
  end
end

function SOE_2_Mission_2_ConnectB:TimeConvoDuringDrive()
  local tTimerEvent = {EventType = "TimerEvent", Time = 1}
  self:RegisterEvent(Util.CreateEvent(tTimerEvent, "SOE_2_Mission_2_ConnectB.TimerCheckConvo", self))
end

function SOE_2_Mission_2_ConnectB:HACKY_ConvoDelay()
  Convo.AddConvo("313_CinA_TrainBoom-ReturnStart", 10, {})
end

function SOE_2_Mission_2_ConnectB:UnloadKesslerSkylar()
  if self.bJustPlayedTrainMission == false then
    self:UnloadTaskNodes("Missions\\soe_2\\mission_2\\KesslerAndSkylar", true)
  else
    self.bUnloadedKesslerAndSkylar = true
    Util.UnloadEditNode("Missions\\soe_2\\mission_2\\KesslerAndSkylar.wsd", true, false)
  end
end

function SOE_2_Mission_2_ConnectB:TASK_TaxiTask()
  Convo.AddConvo("313_CinA_TrainBoom-ReturnStart", 10, {})
  self.tSaveInfo.nCounter = 0
  self:FailTaskByName("escalatedbeforemeeting")
  local tEvent = {
    EventType = "ProximityEvent",
    ObjectA = hSab,
    ObjectB = self.hObjectHandle,
    Proximity = 60,
    Negate = true
  }
  self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2_ConnectB.FarAway", self))
  tEvent = {
    EventType = "ProximityEvent",
    ObjectA = hSab,
    ObjectB = Handle("Missions\\soe_2\\mission_2\\kesslerandskylar\\LOC_HQ"),
    Proximity = 200,
    Negate = false
  }
  self:RegisterEvent(Util.CreateEvent(tEvent, "SOE_2_Mission_2_ConnectB.CloseToHQ", self))
  self:CreateTask({
    sName = "TASK_TaxiTask",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "GenericObjective_Text.Vehicle_Get_A",
    ParentObjectID = self:GetTaskObjectiveID("TASK_FirstTask"),
    sVehicleFetchID = self.sTaxiCarObjective,
    sPickupTextID = self.sTaxiPickupObjective,
    sDropoffTextID = self.sTaxiDropOffObjective,
    tDestLocators = {
      "Missions\\hq_dropoff\\p1hq\\P1HQ_LC"
    },
    tPickupProxObj = {
      self.sObjectString
    },
    PickupProximity = 12,
    tDestRegion = {
      "Missions\\hq_dropoff\\p1hq\\P1HQ_PT"
    },
    tDeliverObjs = self.tTaxiDeliverObjs,
    bNoCarRequired = true,
    bEscalationDenial = true,
    bGroundBlip = true,
    bFadeOutOnDropOff = true,
    tReadyForUnload = {
      {
        self.UnloadKesslerSkylar,
        {self}
      }
    },
    tOnEarlyExit = {},
    tOnWait = {
      {
        self.WaitforSin,
        {self}
      }
    },
    tOnPickup = {
      {
        self.TimeConvoDuringDrive,
        {self}
      }
    },
    tOnComplete = {
      {
        self.GoInsideHQ,
        {self}
      }
    },
    tOnActivate = {
      {
        self.TurnOffDudeHackery,
        {self}
      }
    },
    tSMEDNodes = {}
  })
  self.tSaveInfo.bEscalatedHQ = false
end

function SOE_2_Mission_2_ConnectB:GoInsideHQ()
  local hSkylar = Handle(self.sObjectString)
  local hKessler = Handle("Missions\\soe_2\\mission_2\\KesslerAndSkylar\\Skylar")
  if hSkylar then
    Combat.SetGrabbable(hSkylar, false)
  end
  if hKessler then
    Combat.SetGrabbable(hKessler, false)
  end
  if self.tSaveInfo.bEscalatedHQ == false then
    self:CreateTask({
      sName = "EnterTheHQ",
      sTaskType = "SabTaskObjectiveDeliver",
      sTaskSubType = "EnterInterior",
      sObjectiveTextID = "GenericObjective_Text.HQ_P1_Enter",
      sInteriorName = "LaVillette",
      tLocators = {
        "Missions\\soe_2\\mission_2\\kesslerandskylarcar\\S2M2B_Int"
      },
      tOnComplete = {
        {
          self.PlayCinAndEnd,
          {self}
        }
      }
    })
    self:CreateTask({
      sName = "escalatedbeforetalking",
      sTaskType = "SabTaskObjectiveEscalation",
      sTaskSubType = "None",
      EscalationLevel = 1,
      bGTE = true,
      tOnComplete = {
        {
          self.ItHasEscalatedBeforeHQ,
          {self}
        }
      }
    })
  else
    self:ResetTaskByName("EnterTheHQ")
    self:ResetTaskByName("escalatedbeforetalking")
  end
end

function SOE_2_Mission_2_ConnectB:ItHasEscalatedBeforeHQ()
  self:KillTaskByName("EnterTheHQ")
  if self.tSaveInfo.bEscalatedHQ == false then
    self.tSaveInfo.bEscalatedHQ = true
    self:CreateTask({
      sName = "cooldownbeforeentering",
      sTaskType = "SabTaskObjectiveEscalation",
      sTaskSubType = "None",
      sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
      EscalationLevel = 0,
      tOnComplete = {
        {
          self.GoInsideHQ,
          {self}
        }
      }
    })
  else
    self:ResetTaskByName("cooldownbeforeentering")
  end
end

function SOE_2_Mission_2_ConnectB:PlayCinAndEnd()
  local hLoc = Handle("Missions\\soe_2\\mission_2\\kesslerandskylarcar\\LOC_HQ_ConvoLoc")
  Object.PlayerTeleportToLocator(hLoc, true, "SOE_2_Mission_2_ConnectB.FadedInAndPlayConvo", self)
end

function SOE_2_Mission_2_ConnectB:FadedInAndPlayConvo()
  Render.FadeScreen(false)
  Cin.PlayConversation("315_Con_Allies", "SOE_2_Mission_2_ConnectB.PlayInternalDialouge", self, true)
end

function SOE_2_Mission_2_ConnectB.VeroniqueMoveToLocation()
  local hVeronique = Handle("Missions\\paris_1\\characters\\lavillette\\veronique_front\\Veronique_LaVillette_Front")
  if hVeronique then
    AttractionPt.FinishNow(Handle("Missions\\paris_1\\characters\\lavillette\\veronique_front\\AIAttractionPt_S2M2b"))
  end
  local tEvent = {EventType = "TimerEvent", Time = 0.75}
  Util.CreateEvent(tEvent, "SOE_2_Mission_2_ConnectB.VeroniqueDelayAttrpt", nil)
end

function SOE_2_Mission_2_ConnectB.VeroniqueDelayAttrpt()
  local hVeronique = Handle("Missions\\paris_1\\characters\\lavillette\\veronique_front\\Veronique_LaVillette_Front")
  local hVeroniqueATPT = Handle("Missions\\paris_1\\characters\\lavillette\\veronique_front\\AIAttractionPt_S2M2b2")
  if hVeronique then
    Actor.RequestAttrPt(hVeronique, hVeroniqueATPT)
  end
end

function SOE_2_Mission_2_ConnectB:PlayInternalDialouge()
  Cin.PlayConversation("ST_316_OMW", "SOE_2_Mission_2_ConnectB.Cleanup", self, true)
end

function SOE_2_Mission_2_ConnectB:TalkToVeronique()
  SOE_2_Mission_2_ConnectB:CreateTask({
    sName = "TalkToVeroTask",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sObjectiveTextID = "S2M2b_Text.TalkToVeronique",
    sConvFile = "316_Con_GoRadio",
    tTgtInclude = {
      "Missions\\paris_1\\characters\\lavillette\\veronique_interior\\Veronique_LaVillette_Interior"
    },
    tOnComplete = {
      {
        SOE_2_Mission_2_ConnectB.Cleanup,
        {SOE_2_Mission_2_ConnectB}
      }
    }
  })
  HUD.SetObjectiveMarker(Handle("Missions\\paris_1\\characters\\lavillette\\veronique_interior\\LOC_Vero_Talk"), cMMI_Objective, cOM_Objective)
  SOE_2_Mission_2_ConnectB.hFocusID = FocusPt.Create(0, 0, 0, 150, 1000, true, false, Handle("Missions\\paris_1\\characters\\lavillette\\veronique_interior\\Veronique_LaVillette_Interior"))
  Actor.CancelAttrPt(Handle("Missions\\paris_1\\characters\\lavillette\\veronique_interior\\Veronique_LaVillette_Interior"))
  Actor.CancelAttrPtRequest(Handle("Missions\\paris_1\\characters\\lavillette\\veronique_interior\\Veronique_LaVillette_Interior"))
end

function SOE_2_Mission_2_ConnectB:MissionFailz()
end

function SOE_2_Mission_2_ConnectB:TurnOffDudeHackery()
  local hSkylar = Util.GetHandleByName("Missions\\soe_2\\mission_2\\KesslerAndSkylar\\Skylar")
end

function SOE_2_Mission_2_ConnectB:MISSION_ONCANCEL()
  if self.bJustPlayedTrainMission == true then
    if self.bUnloadedKesslerAndSkylar ~= true then
      Util.UnloadEditNode("Missions\\soe_2\\mission_2\\KesslerAndSkylar.wsd", true, false)
    end
    Util.UnloadEditNode("Missions\\soe_2\\mission_2\\kesslerandskylarcar.wsd", true, false)
  end
end

function SOE_2_Mission_2_ConnectB:Cleanup()
  local hVeronique = Handle("Missions\\paris_1\\characters\\lavillette\\veronique_front\\Veronique_LaVillette_Front")
  local hVeroniqueATPT = Handle("Missions\\paris_1\\characters\\lavillette\\veronique_front\\AIAttractionPt_S2M2b2")
  if hVeronique then
    AttractionPt.FinishNow(Handle("Missions\\paris_1\\characters\\lavillette\\veronique_front\\AIAttractionPt_S2M2b"))
    Actor.RequestAttrPt(hVeronique, hVeroniqueATPT)
  end
  if self.bJustPlayedTrainMission == true then
    Util.UnloadEditNode("Missions\\soe_2\\mission_2\\kesslerandskylarcar.wsd", true, false)
  end
  Util.SetDynamicPriority("VH_CV_CR_Peugeot402_01", 50)
  Squad.AddMember("Saboteur", hSab)
  if self.hFocusID then
    FocusPt.Delete(self.hFocusID)
  end
  self:CompleteThisMission()
end
