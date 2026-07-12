if Paris_6_Mission_1_ConnectB == nil then
  Paris_6_Mission_1_ConnectB = SabTaskObjective:Create()
  Paris_6_Mission_1_ConnectB:Configure({
    TaskCount = "auto",
    bStarterless = true,
    MCDisplayID = 2,
    sSaveMissionNameID = "MissionNames_Text.P6M1",
    bDisableMissionTitle = true,
    sHQStartPoint = _cHQe_P6M1b,
    tUnlockList = {
      "Act_3_Mission_1"
    },
    tSMEDNodes = {
      "Missions\\paris_6\\mission_1\\gobacktohq"
    }
  })
end

function Paris_6_Mission_1_ConnectB:Activated()
  SabTaskObjective.Activated(self)
  if not Util.GetHandleByName("Missions\\paris_6\\mission_1\\VeroniqueCarConnect\\Veronique_P6M1B") then
    Util.SpawnEditNode("Missions\\paris_6\\mission_1\\VeroniqueCarConnect.wsd", "Paris_6_Mission_1_ConnectB.DoCheckpoint0", self)
  else
    self.RegisterCheckpoint(self, "Paris_6_Mission_1_ConnectB.Checkpoint0")
  end
end

function Paris_6_Mission_1_ConnectB:GENERAL_Setup()
  self.sObjectString = "Missions\\paris_6\\mission_1\\VeroniqueCarConnect\\Veronique_P6M1B"
  local sObjCarriedOver = "Missions\\paris_6\\mission_1\\execution\\victim7"
  self.sDestinationLocator = "PARIS\\area03\\catacombs\\catacombshq_ex\\ext_blip_loc\\LOC_Cat_Blip_Ext"
  self.sPickupTrigger = "Missions\\paris_6\\mission_1\\GoBackToHQ\\PT_Pickup"
  self.sDropOffTrigger = "Missions\\paris_6\\mission_1\\GoBackToHQ\\PT_BacktoHQ"
  self.sMasterObjective = "GenericObjective_Text.HQ_P3_GoTo"
  self.sTaxiCarObjective = "P6M1b_Text.EscortVeronique"
  self.sTaxiPickupObjective = "P6M1b_Text.EscortVeronique"
  self.sTaxiDropOffObjective = "P6M1b_Text.EscortVeronique"
  self.hVeron = Util.GetHandleByName(self.sObjectString)
  local nSabVeroDist = Object.GetDistance(hSab, self.hVeron)
  if nSabVeroDist < 3 then
    Paris_6_Mission_1_ConnectB.TASK_TaxiTask(self)
  else
    Paris_6_Mission_1_ConnectB.TASK_CloseTask(self)
  end
end

function Paris_6_Mission_1_ConnectB:MISSION_ONCANCEL()
  RewardsManager.HideStarter("veronique_cat_int")
  RewardsManager.ShowStarter("kessler_cat_int")
  RewardsManager.ShowStarter("maria_cat_int")
end

function Paris_6_Mission_1_ConnectB:MISSION_ONCOMPLETE()
  RewardsManager.ShowStarter("kessler_cat_int")
  RewardsManager.ShowStarter("maria_cat_int")
end

function Paris_6_Mission_1_ConnectB:TASK_CloseTask()
  self:CreateTask({
    sName = "Task_CloseTask",
    sTaskType = "SabTaskObjectiveDeliver",
    Proximity = 2,
    sTaskSubType = "DELIVER",
    tDestProximityObj = {
      self.hVeron
    },
    sObjectiveTextID = "A3M2_Text.TASK_PlayVeronConvo",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.TASK_TaxiTask,
        {self}
      }
    }
  })
end

function Paris_6_Mission_1_ConnectB:TASK_TaxiTask()
  Combat.SetLeader(self.hVeron, hSab, false, 2, 4)
  self:CreateTask({
    sName = "Task_Taxi",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = self.sMasterObjective,
    sPickupTextID = self.sTaxiPickupObjective,
    sDropoffTextID = self.sTaxiDropOffObjective,
    sVehicleFetchID = "GenericObjective_Text.Vehicle_GetIn_A",
    sVehicleReturnID = "GenericObjective_Text.Vehicle_GetInBack_A",
    bGroundBlip = true,
    bEscalationDenial = true,
    vGPSDestTarget = "Missions\\paris_6\\mission_1\\gobacktohq\\LOC_BacktoHQ",
    tDeliverObjs = {
      self.hVeron
    },
    tPickupProxObj = {
      self.sObjectString
    },
    PickupProximity = 2,
    tDestRegion = {
      self.sDropOffTrigger
    },
    tDestLocators = {
      self.sDestinationLocator
    },
    tSMEDNodes = {},
    tOnEarlyExit = {},
    tOnPickup = {
      {
        self.CarTalk,
        {self}
      }
    },
    tOnComplete = {
      {
        self.GetInsideCatacomb,
        {self}
      }
    },
    tOnActivate = {
      {
        self.FeelyConvo,
        {self}
      },
      {
        RewardsManager.ShowStarter,
        {
          "veronique_cat_int"
        }
      },
      {
        RewardsManager.HideStarter,
        {
          "duval_cat_int"
        }
      },
      {
        RewardsManager.HideStarter,
        {
          "drkwong_cat_int"
        }
      },
      {
        RewardsManager.HideStarter,
        {
          "kessler_cat_int"
        }
      },
      {
        RewardsManager.HideStarter,
        {
          "maria_cat_int"
        }
      }
    }
  })
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_6\\mission_1\\gobacktohq\\PT_PlayerThereBK", hSab, "Paris_6_Mission_1_ConnectB.CheckIfAlone", self, nil, cTRIGGEREVENT_ONENTER), "Missions\\paris_6\\mission_1\\gobacktohq\\PT_PlayerThereBK")
end

function Paris_6_Mission_1_ConnectB:FeelyConvo()
  Cin.PlayConversation("328b_Con_Breakout")
end

function Paris_6_Mission_1_ConnectB:HopIn()
  Cin.PlayConversation("P6M1b_WaitFor")
end

function Paris_6_Mission_1_ConnectB:CheckIfAlone()
  if not self.bAlreadyThere and self:IsMissionTaskActive("Task_Taxi") then
    self:CompleteTaskByName("Task_Taxi")
  end
end

function Paris_6_Mission_1_ConnectB:GetInsideCatacomb()
  self.bAlreadyThere = true
  local hHQEnt = Handle("Missions\\paris_6\\mission_1\\gobacktohq\\LOC_VeronEnt")
  local hVeron = Util.GetHandleByName(self.sObjectString)
  Nav.MoveToObject(hVeron, hHQEnt, 1)
  self:CreateTask({
    sName = "EnterCatacomb",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "EnterInterior",
    sObjectiveTextID = "GenericObjective_Text.HQ_P3_GoTo",
    vGPSTarget = "Missions\\paris_6\\mission_1\\gobacktohq\\LOC_BacktoHQ",
    sInteriorName = "Catacombs",
    tLocators = {
      "PARIS\\area03\\catacombs\\catacombshq_ex\\ext_blip_loc\\LOC_Cat_Blip_Ext"
    },
    tOnComplete = {
      {
        self.Cleanup,
        {self}
      },
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end

function Paris_6_Mission_1_ConnectB:CarTalk()
  EVENT_Timer("Paris_6_Mission_1_ConnectB.NowCarTalk", self, 0.5)
end

function Paris_6_Mission_1_ConnectB:NowCarTalk()
  ConvoHelper.InterruptReplay("329_InG_CarTalk", "P6M1b_CarTalking")
end

function Paris_6_Mission_1_ConnectB:AbandonedVero()
  Convo.AddConvo("P6M1b_Abandon", 10, {})
  self.hReturnEvent = Util.CreateEvent({
    EventType = "ProximityEvent",
    ObjectA = Util.GetHandleByName(self.sObjectString),
    ObjectB = hSab,
    Proximity = 5,
    Negate = false
  }, "Paris_6_Mission_1_ConnectB.PossibleReEnableAbandonConvo", self, nil)
end

function Paris_6_Mission_1_ConnectB:PossibleReEnableAbandonConvo()
  Convo.AddConvo("P6M1b_Return", 10, {})
end

function Paris_6_Mission_1_ConnectB:Cleanup()
  Util.UnloadEditNode("Missions\\paris_6\\mission_1\\VeroniqueCarConnect.wsd")
end

function Paris_6_Mission_1_ConnectB:DoCheckpoint0()
  Paris_6_Mission_1_ConnectB.FeelyConvo(self)
  self.RegisterCheckpoint(self, "Paris_6_Mission_1_ConnectB.Checkpoint0")
end

function Paris_6_Mission_1_ConnectB:Checkpoint0()
  self.GENERAL_Setup(self)
  self.bAlreadyThere = false
end

function Paris_6_Mission_1_ConnectB:OnEscalation()
  self:ResetTaskByName("TASK_TaxiTask", true)
  self.TASK_ShedEscalation(self)
end

function Paris_6_Mission_1_ConnectB:TASK_ShedEscalation()
  self:CreateTask({
    sName = "TASK_ShedEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    sTaskSubType = "NONE",
    EscalationLevel = 0,
    tOnComplete = {
      {
        self.TASK_TaxiTask,
        {self}
      },
      {
        self.ResetTaskByName,
        {
          self,
          "TASK_ShedEscalation",
          true
        }
      }
    }
  })
end
