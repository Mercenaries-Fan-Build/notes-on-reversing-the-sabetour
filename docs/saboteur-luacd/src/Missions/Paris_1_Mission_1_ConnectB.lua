if Paris_1_Mission_1_ConnectB == nil then
  Paris_1_Mission_1_ConnectB = SabTaskObjective:Create()
  Paris_1_Mission_1_ConnectB:Configure({
    TaskCount = "auto",
    bStarterless = true,
    MCDisplayID = 2,
    tUnlockList = {
      "Paris_1_Mission_1B"
    },
    tSMEDNodes = {
      "Missions\\paris_1\\mission_1_to_1b\\main"
    }
  })
end

function Paris_1_Mission_1_ConnectB:STARTER_Setup()
  self.sDebugLabel = "P1M1_ConnectB"
  self.bDebugMode = false
end

function Paris_1_Mission_1_ConnectB:Activated()
  SabTaskObjective.Activated(self)
  self.SetupCheckPoint1(self)
end

function Paris_1_Mission_1_ConnectB:GENERAL_Setup()
  dprint(self, "P1M1_ConnectB:Active")
  Squad.Create("P1M1c")
  local sLucP1M1C = "Missions\\paris_1\\mission_1_to_1b\\backtobelleluc\\Spore_RS_Luc_P1M1"
  local hLucP1M1C = Util.GetHandleByName(sLucP1M1C)
  self.sLucP1M1C = sLucP1M1C
  self.tInfo.hLucDeLuc = Util.GetHandleByName(sLucP1M1C)
  local tDeadLucEvent = {
    EventType = "DeathEvent",
    EventName = "LucP1M1CisDead",
    ObjectHandle = self.tInfo.hLucDeLuc
  }
  self:RegisterEvent(Util.CreateEvent(tDeadLucEvent, "Paris_1_Mission_1_ConnectB.PlayLucDeathFailConvo", self))
  Inventory.GiveItem(hLucP1M1C, "WP_PS_WaltherPPK", true)
  Object.SetHealth(hLucP1M1C, 12000)
  self.sLucIntoBelle = "Missions\\paris_1\\mission_1_to_1b\\main\\LucIntoBelleLoc"
  self:SetVehicleEnterConvoListener()
  self:TASK_GoToTheBelle()
end

function Paris_1_Mission_1_ConnectB:PlayLucDeathFailConvo()
  Cin.PlayConversation("P1M1x_Luc_Dead", "Paris_1_Mission_1_ConnectB.FailMissionByLucDeath", self)
end

function Paris_1_Mission_1_ConnectB:FailMissionByLucDeath()
  self:MissionTaskFail("Char_Death.RS_Luc_P1M1")
end

function Paris_1_Mission_1_ConnectB:SetupCheckPoint1()
  self.RegisterCheckpoint(self, "Paris_1_Mission_1_ConnectB.CheckPoint1")
end

function Paris_1_Mission_1_ConnectB:CheckPoint1()
  Util.SpawnEditNode("Missions\\paris_1\\mission_1_to_1b\\backtobelleluc.wsd", "Paris_1_Mission_1_ConnectB.GENERAL_Setup", self)
end

function Paris_1_Mission_1_ConnectB:TASK_GoToTheBelle()
  self:CreateTask({
    sName = "TASK_GoToTheBelle",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "P1M1C_Text.TASK_GoToTheBelle",
    bNoCarRequired = true,
    tDestLocators = {
      "Missions\\paris_1\\mission_1_to_1b\\main\\TaxiDeliverPointer"
    },
    PickupProximity = 12,
    tPickupProxObj = {
      self.sLucP1M1C
    },
    tDestRegion = {
      "Missions\\paris_1\\mission_1_to_1b\\main\\TaxiDropTrig"
    },
    tDeliverObjs = {
      self.sLucP1M1C
    },
    bEscalationDenial = true,
    tOnEarlyExit = {},
    tOnPickup = {
      {
        self.PlayPickupConvo,
        {self}
      },
      {
        self.SetupNearBelleTrig,
        {self}
      }
    },
    tOnComplete = {
      {
        self.GoGoReleaseLuc,
        {self}
      },
      {
        self.MoveLucToDoor,
        {self}
      }
    },
    tOnActivate = {
      {
        self.MakePuppetLucAgain,
        {self}
      },
      {
        self.StartEscalation,
        {self}
      }
    },
    tSMEDNodes = {}
  })
end

function Paris_1_Mission_1_ConnectB:GoGoReleaseLuc()
  Squad.ClearBehavior("P1M1c")
  Squad.RemoveMember("P1M1c", self.tInfo.hLucDeLuc)
  Combat.SetIdleScripted(self.tInfo.hLucDeLuc, true)
  Actor.OverrideCombatAI(self.tInfo.hLucDeLuc, true)
end

function Paris_1_Mission_1_ConnectB:StartEscalation()
  Suspicion.SetEscalated()
end

function Paris_1_Mission_1_ConnectB:MoveLucToDoor()
  local hLucToBelleDoor = Util.GetHandleByName(self.sLucIntoBelle)
  Cin.PlayConversation("P1M1c_Complete")
  Nav.MoveToObject(self.tInfo.hLucDeLuc, hLucToBelleDoor, 3, cMOVE_NORMAL, "Paris_1_Mission_1_ConnectB.OpenBelleDoor", self, nil, false, true, cDESTINATION_GO_NO_MATTER_WHAT)
end

function Paris_1_Mission_1_ConnectB:OpenBelleDoor()
  local hBelleFrontDoor = Util.GetHandleByName("PARIS\\area01\\belledenuit\\buildings\\MN_Belle_De_Nuit(2)\\MN_Nuit_Door")
  local hMoveLucInFurther = Util.GetHandleByName("Missions\\paris_1\\mission_1_to_1b\\main\\LucIntoBelleLoc(2)")
  Object.Actuate(hBelleFrontDoor, false)
  Nav.MoveToObject(self.tInfo.hLucDeLuc, hMoveLucInFurther, 1, cMOVE_NORMAL, "Paris_1_Mission_1_ConnectB.FinishThisMissionNow", self, nil, false, true, cDESTINATION_GO_NO_MATTER_WHAT)
end

function Paris_1_Mission_1_ConnectB:PlayCompleteConv()
  Cin.PlayConversation("P1M1c_Complete", "Paris_1_Mission_1_ConnectB.FinishThisMissionNow", self)
end

function Paris_1_Mission_1_ConnectB:FinishThisMissionNow()
  self:KillEnterVehConvoEvent()
  local hBelleOutsideTele = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\hq_ext\\Belle_ext_teleport")
  AttractionPt.EnableUse(hBelleOutsideTele, true)
  Util.UnloadEditNode("Missions\\paris_1\\mission_1_to_1b\\backtobelleluc.wsd", true, false)
  self:CompleteThisMission()
end

function Paris_1_Mission_1_ConnectB:MakePuppetLucAgain()
  Actor.OverrideCombatAI(self.tInfo.hLucDeLuc, false)
  Squad.AddMember("P1M1c", hSab)
  Squad.AddMember("P1M1c", self.tInfo.hLucDeLuc)
  Squad.SetEnemy("P1M1c", "GenericNazi", false)
  Combat.SetCombat(self.tInfo.hLucDeLuc)
  Squad.SetLeader("P1M1c", hSab)
  Squad.SetRadius("P1M1c", 7)
  Squad.FollowLeader("P1M1c")
  Combat.SetSquadAssist(self.tInfo.hLucDeLuc, true)
end

function Paris_1_Mission_1_ConnectB:PlayLetsGoConv()
  Cin.PlayConversation("P1M1c_Ready")
  self:SetupDistanceConvos()
end

function Paris_1_Mission_1_ConnectB:TASK_TaxiBackToBelle()
  self:CreateTask({
    sName = "TASK_TaxiBackToBelle",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    ParentObjectID = self:GetTaskObjectiveID("TASK_GoToTheBelle"),
    sObjectiveTextID = "P1M1C_Text.TASK_GoToTheBelle",
    tDestLocators = {
      "Missions\\paris_1\\mission_1_to_1b\\main\\TaxiDeliverPointer"
    },
    PickupProximity = 12,
    tPickupProxObj = {
      "Missions\\paris_1\\characters\\belle\\luc_tobacco\\Luc_Tobac_Starter"
    },
    tDestRegion = {
      "Missions\\paris_1\\mission_1_to_1b\\main\\TaxiDropTrig"
    },
    tDeliverObjs = {
      "Missions\\paris_1\\characters\\belle\\luc_tobacco\\Luc_Tobac_Starter"
    },
    tOnEarlyExit = {},
    tOnPickup = {
      {
        self.PlayPickupConvo,
        {self}
      },
      {
        self.SetupNearBelleTrig,
        {self}
      }
    },
    tOnComplete = {
      {
        self.FireOffConvosToEnd,
        {self}
      }
    },
    tOnActivate = {},
    tSMEDNodes = {}
  })
end

function Paris_1_Mission_1_ConnectB:PlayPickupConvo()
  Cin.PlayConversation("P1M1c_Ready")
  self:SetupDistanceConvos()
end

function Paris_1_Mission_1_ConnectB:SetupNearBelleTrig()
  Trigger.WaitFor("Missions\\paris_1\\mission_1_to_1b\\main\\NearBelleTrig", hSab, "Paris_1_Mission_1_ConnectB.PlayNearBelleConvo", self, nil, cTRIGGEREVENT_ONENTER, true)
end

function Paris_1_Mission_1_ConnectB:PlayNearBelleConvo()
  if Suspicion.GetEscalation() == 0 then
    if Actor.IsInVehicle(hSab) == true then
      Cin.PlayConversation("P1M1c_NearBelle_InCar")
    else
      Cin.PlayConversation("P1M1c_NearBelle_OnFoot")
    end
  else
  end
end

function Paris_1_Mission_1_ConnectB:TASK_Cooldown()
  self:CreateTask({
    sName = "TASK_Cooldown",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    EscalationLevel = 0,
    tOnComplete = {
      {
        self.TASK_GoToTheBelle,
        {self}
      }
    },
    tOnActivate = {
      {
        self.ShowToolTip,
        {
          self,
          "Objects with GREEN Indicators allow you to escape escalation when no one is looking!"
        }
      }
    }
  })
end

function Paris_1_Mission_1_ConnectB:FireOffConvosToEnd()
  Cin.PlayConversation("P1M1c_Complete", "Paris_1_Mission_1_ConnectB.FinishThisNow", self)
end

function Paris_1_Mission_1_ConnectB:FinishThisNow()
  self:CompleteThisMission()
end

function Paris_1_Mission_1_ConnectB:SetVehicleEnterConvoListener()
  self.hVehEventID = EVENT_PlayerEntersAnyVehicle("Paris_1_Mission_1_ConnectB.FireCarHijackConvos", self, nil, true)
end

function Paris_1_Mission_1_ConnectB:FireCarHijackConvos(tArgs)
  local hLucSpeaker = Util.GetHandleByName("Missions\\paris_1\\mission_1_to_1b\\backtobelleluc\\Spore_RS_Luc_P1M1")
  local tVehConvoSpeakers = {hLucSpeaker}
  local hVehicle = Util.GetHandleByName("Missions\\paris_1\\mission_1\\outdooractors\\VH_CV_CR_Peugeot402_01")
  if Vehicle.IsNaziVehicle(hVehicle) == true then
    if Cin.IsHumanInConversation(hSab) == true then
    elseif Cin.IsHumanInConversation(hSab) == false then
      Cin.PlayConversationWith("P1M1x_HijackVehicle_Nazi", tVehConvoSpeakers)
    end
  elseif Vehicle.IsNaziVehicle(hVehicle) ~= false or Cin.IsHumanInConversation(hSab) == true then
  elseif Cin.IsHumanInConversation(hSab) ~= false or hVehicle == self.hLucsCar then
  else
    Cin.PlayConversationWith("P1M1x_HijackVehicle_Civilian", tVehConvoSpeakers)
  end
end

function Paris_1_Mission_1_ConnectB:KillEnterVehConvoEvent()
  Util.KillEvent(self.hVehEventID)
  Util.KillEvent(self.eLUCPROX)
  Util.KillEvent(self.eLUCRETURN)
end

function Paris_1_Mission_1_ConnectB:SetupDistanceConvos()
  local tSeanLucDistanceEvent = {
    EventType = "ProximityEvent",
    ObjectA = hSab,
    ObjectB = self.hLucTobacc,
    Proximity = 30,
    Negate = true
  }
  self.eLUCPROX = Util.CreateEvent(tSeanLucDistanceEvent, "Paris_1_Mission_1_ConnectB.PlayAbandonConvo", self, nil, false)
end

function Paris_1_Mission_1_ConnectB:SetupCloseConvos()
  local tSeanLucCloseEvent = {
    EventType = "ProximityEvent",
    ObjectA = hSab,
    ObjectB = self.hLucTobacc,
    Proximity = 15
  }
  self.eLUCRETURN = Util.CreateEvent(tSeanLucCloseEvent, "Paris_1_Mission_1_ConnectB.PlayReturnConvo", self, nil, false)
end

function Paris_1_Mission_1_ConnectB:PlayAbandonConvo()
  if Cin.IsHumanInConversation(hSab) == true then
    Cin.PlayConversation("P1M1x_Luc_Abandoned", "Paris_1_Mission_1_ConnectB.SetupCloseConvos", self)
  else
  end
end

function Paris_1_Mission_1_ConnectB:PlayReturnConvo()
  local tVoices = {
    self.hLucTobacc
  }
  if Cin.IsHumanInConversation(hSab) == true then
    Cin.PlayConversationWith("P1M1x_Luc_Return", tVoices, "Paris_1_Mission_1_ConnectB.SetupDistanceConvos", self)
  else
  end
end
