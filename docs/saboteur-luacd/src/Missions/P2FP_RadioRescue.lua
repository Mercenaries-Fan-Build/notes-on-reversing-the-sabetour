if P2FP_RadioRescue == nil then
  require("Includes\\WRAPPER_Vehicle")
  P2FP_RadioRescue = SabTaskObjective:Create()
  P2FP_RadioRescue.PATH = "Missions\\freeplay\\p2\\mis_rescue_radioguy\\"
  P2FP_RadioRescue:Configure({
    TaskCount = "auto",
    sSaveMissionNameID = "MissionNames_Text.P2FP_RadioRescue",
    tDependencyList = {},
    tUnlockList = {
      "NOTE_307",
      "Connect_ST_307_ParkHangingBigGun",
      "P1FP_KillCourtyard01",
      "NOTE_P_Qualifier"
    },
    bFreeplay = true,
    bRepeatable = false,
    StarterIcon = "mm_MS_Margot_1",
    sConvFile = "P2FP_RadioRescue_Start",
    sStarter = "Margot_Boulogne_Interior",
    tSMEDNodes = {
      P2FP_RadioRescue.PATH .. "main",
      P2FP_RadioRescue.PATH .. "ss"
    }
  })
end

function P2FP_RadioRescue:STARTER_Setup()
end

function P2FP_RadioRescue:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "RADIORESCUE"
  self.bDebugMode = false
  self.GENERAL_Setup(self)
  self.SetupCheckpoint(self, 1)
end

function P2FP_RadioRescue:GENERAL_Setup()
  self.sNaziOfficer = "Missions\\freeplay\\p2\\mis_rescue_radioguy\\main\\Spore_WNZ_Officer_PS"
  self.sStreetGuard = "Missions\\freeplay\\p2\\mis_rescue_radioguy\\ss\\Spore_SS_Heavy_MG(11)"
  self.sStreetGuard2 = "Missions\\freeplay\\p2\\mis_rescue_radioguy\\ss\\Spore_SS_Heavy_MG(12)"
  self.sStreetGuard3 = "Missions\\freeplay\\p2\\mis_rescue_radioguy\\ss\\Spore_SS_Heavy_MG(11)"
  self.sStreetGuard4 = "Missions\\freeplay\\p2\\mis_rescue_radioguy\\ss\\Spore_SS_Heavy_MG(12)"
  self.tNaziGuards = {}
end

function P2FP_RadioRescue:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "P2FP_RadioRescue.DoCheckpoint")
end

function P2FP_RadioRescue:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  EVENT_Stream("P2FP_RadioRescue.GrabBryman", self, {
    self.PATH .. "radioguy\\Bryman"
  }, true)
  if nCP == 1 then
    self.TASK_LocateBryman(self)
    self.Task_Exit(self)
    self.sActiveTask = "INIT"
  elseif nCP == 2 then
    if not self:IsMissionTaskActive("P2FP_RadioRescue.TASK_LocateBryman") then
      self.TASK_LocateBryman(self)
    end
  elseif nCP == 3 then
    WorldSMEDNodes.LoadNode("Missions\\freeplay\\p2\\mis_rescue_radioguy\\radioguy")
    Util.KillEvent(self.eEscDetect)
    EVENT_Timer("P2FP_RadioRescue.UnBrakeCar", self, 1)
    self.TASK_FreePrisoner(self)
  end
end

function P2FP_RadioRescue:GrabBryman()
  self.hPrisoner = Handle(self.PATH .. "radioguy\\Bryman")
end

function P2FP_RadioRescue:Task_Exit()
  dprint(self, "Inside Task_Exit.")
  self:CreateTask({
    sName = "Task_Exit",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "Boulogne",
    bInteriorTask = true,
    MarkerHeight = 2.5,
    tLocators = {},
    tOnComplete = {
      {
        dprint,
        {
          self,
          "Finished Task Exit."
        }
      },
      {
        self.SetupCheckpoint,
        {self, 2}
      }
    }
  })
end

function P2FP_RadioRescue:TASK_LocateBryman()
  self:CreateTask({
    sName = "TASK_LocateBryman",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "DELIVER",
    tLocators = {
      "Missions\\freeplay\\p2\\mis_rescue_radioguy\\main\\LOC_GoTo"
    },
    tDestRegion = "Missions\\freeplay\\p2\\mis_rescue_radioguy\\main\\PT_LocateBryman",
    bGroundBlip = true,
    tDeliverObjs = {hSab},
    sObjectiveTextID = "P2FP_RadioRescue_Text.TASK_LocateBryman",
    tOnActivate = {
      {
        self.EscalationListener,
        {self}
      }
    },
    tOnComplete = {
      {
        self.BrakeCar,
        {self}
      },
      {
        self.ClearGPS,
        {self}
      },
      {
        self.SetupCheckpoint,
        {self, 3}
      }
    }
  })
end

function P2FP_RadioRescue:ClearGPS()
  HUD.ClearWaypoint()
  HUD.ClearGPSTarget()
end

function P2FP_RadioRescue:BrakeCar()
  local hSabCar = Actor.GetVehicle(hSab)
  if hSabCar then
    SabTaskObjectiveDeliver.StopVehicle(self, hSabCar)
  end
end

function P2FP_RadioRescue:UnBrakeCar()
  local hSabCar = Actor.GetVehicle(hSab)
  if hSabCar then
    SabTaskObjectiveDeliver.ReleaseVehicle(self, hSabCar)
  end
end

function P2FP_RadioRescue:KillEscEvent()
  Util.KillEvent(self.eEscDetect)
  if self.sActiveTask == "TASK_LocateBryman" then
    self:TASK_LocateBryman()
  else
    self:TASK_FreePrisoner()
  end
end

function P2FP_RadioRescue:EscalationListener()
  dprint(self, "Setting Escalation Listener")
  self.eEscDetect = EVENT_OnEscalation("P2FP_RadioRescue.EscSwitchTasks", self, nil, false)
end

function P2FP_RadioRescue:EscSwitchTasks()
  dprint(self, "Escalated. Switching to LOSE HEAT task")
  if self:IsMissionTaskActive("TASK_LocateBryman") then
    self:ResetTaskByName("TASK_LocateBryman", true)
    self.sActiveTask = "TASK_LocateBryman"
    self:TASK_LoseEscalation()
  end
end

function P2FP_RadioRescue:TASK_LoseEscalation()
  self:CreateTask({
    sName = "TASK_LoseEscalation",
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

function P2FP_RadioRescue:TASK_FreePrisoner()
  Sound.SetMusicLocale("fp_P2FP_RadioRescue")
  Sound.SetMusicLocale("fp_P2FP_RadioRescue", "arriveAtJail")
  self:CreateTask({
    sName = "TASK_FreePrisoner",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    bPlayerOnly = true,
    sObjectiveTextID = "P2FP_RadioRescue_Text.TASK_FreePrisoner",
    bNoGPS = true,
    tTgtInclude = {
      "Missions\\freeplay\\p2\\mis_rescue_radioguy\\main\\TP_JailDoor"
    },
    tOnActivate = {
      {
        EVENT_Stream,
        {
          "P2FP_RadioRescue.SetupGuardWarns",
          self,
          self.sStreetGuard,
          true
        }
      },
      {
        self.SetUpNextTask,
        {self}
      },
      {
        self.SetupCageFail,
        {self}
      },
      {
        EVENT_ActorDeath,
        {
          "P2FP_RadioRescue.DoorBlownOpen",
          self,
          "Missions\\freeplay\\p2\\mis_rescue_radioguy\\rescue_props\\OccLt_Cage_Prison_Door\\Cage1"
        }
      }
    },
    tOnComplete = {
      {
        self.LockDoorOpen,
        {self}
      },
      {
        self.EscapeVO,
        {self}
      },
      {
        self.TASK_DeliverPrisoner,
        {self}
      },
      {
        self.KillCageEvent,
        {self}
      }
    }
  })
  hSeeBrymanEvent = Util.CreateEvent({
    EventType = "SeeLocatorEvent",
    EventName = "SeeBryman",
    InViewTime = 0.1,
    Locator = "Missions\\freeplay\\p2\\mis_rescue_radioguy\\main\\LOC_BrymanSee",
    Proximity = 50
  }, "P2FP_RadioRescue.SpottedVO", self)
end

function P2FP_RadioRescue:DoorBlownOpen()
  self:CompleteTaskByName("TASK_FreePrisoner")
end

function P2FP_RadioRescue:SetUpNextTask()
  self.hDeliverLoc = Handle(self.PATH .. "main\\LOC_Dest")
  self.hDeliverDest = Handle(self.PATH .. "main\\PT_Dest")
end

function P2FP_RadioRescue:SetupCageFail()
  self.eCageFail = EVENT_ActorEntersTrigger("P2FP_RadioRescue.TestCageFail", self, hSab, "Missions\\freeplay\\p2\\mis_rescue_radioguy\\main\\PT_InsideCage")
end

function P2FP_RadioRescue:KillCageEvent()
  Trigger.DoNotWaitFor(Util.GetHandleByName("Missions\\freeplay\\p2\\mis_rescue_radioguy\\main\\PT_InsideCage"), hSab)
  Util.KillEvent(self.eCageFail)
end

function P2FP_RadioRescue:TestCageFail()
  if Inventory.GetCountOfType(hSab, "WP_SAB_DynamiteFuse") > 0 or 0 < Inventory.GetCountOfType(hSab, "WP_GR_StickGrenade") or 0 < Inventory.GetCountOfType(hSab, "WP_SAB_RDX_Charge") then
    dprint(self, ">>>>>> Everything is cool, player has dynamite or explosives to escape the Cage")
  else
    dprint(self, ">>>>>> Player is trapped in Cage, fail him")
    self:CageFail()
  end
end

function P2FP_RadioRescue:CageFail()
  self:MissionTaskFail("P2FP_RadioRescue_Text.Fail_CageStuck")
end

function P2FP_RadioRescue:TASK_DeliverPrisoner()
  dprint(self, "TASK_DeliverPrisoner()")
  Nav.MoveToObject(Handle(self.hPrisoner), hSab, 1, true)
  Combat.SetLeader(Handle(self.hPrisoner), hSab, true, 1, 2)
  self:CreateTask({
    sName = "TASK_DeliverPrisoner",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sPickupTextID = "P2FP_RadioRescue_Text.TASK_DeliverPrisoner",
    sDropoffTextID = "P2FP_RadioRescue_Text.TASK_DeliverPrisoner",
    sVehicleFetchID = "P2FP_RadioRescue_Text.TASK_Vehicle",
    sVehicleReturnID = "P2FP_RadioRescue_Text.TASK_Vehicle",
    tPickupProxObj = {
      self.hPrisoner
    },
    PickupProximity = 12,
    bWimpy = true,
    bNoCarRequired = true,
    tDestRegion = {
      "Missions\\freeplay\\p2\\mis_rescue_radioguy\\main\\PT_Dest"
    },
    tDestLocators = {
      self.hDeliverLoc
    },
    bEscalationDenial = true,
    tDeliverObjs = {
      self.hPrisoner
    },
    bFadeOutOnDropOff = true,
    tReadyForUnload = {
      {
        self.OnPrisonerReachesHQ,
        {self}
      }
    },
    tOnEarlyExit = {
      {
        print,
        {
          "Hey little buddy get back into the vehicle!"
        }
      }
    },
    tOnWait = {},
    tOnPickup = {},
    tOnComplete = {},
    tOnActivate = {
      {
        EVENT_ActorEntersAnyVehicle,
        {
          "P2FP_RadioRescue.PlayEscapeVO",
          self,
          self.hPrisoner
        }
      }
    }
  })
end

function P2FP_RadioRescue:PlayEscapeVO()
  Cin.PlayConversation("P2FP_RadioRescue_Escape")
end

function P2FP_RadioRescue:SetupGuardWarns()
  EVENT_PlayerEntersTrigger("P2FP_RadioRescue.StreetGuardWarnsRear", self, "Missions\\freeplay\\p2\\mis_rescue_radioguy\\main\\PT_HaltRear", false)
  EVENT_PlayerEntersTrigger("P2FP_RadioRescue.StreetGuardWarnsFront", self, "Missions\\freeplay\\p2\\mis_rescue_radioguy\\main\\PT_HaltFront", false)
end

function P2FP_RadioRescue:StreetGuardWarnsRear()
  if not Actor.IsDisguised(hSab) then
    Actor.SetFacingDir(Handle(self.sStreetGuard), hSab)
    Actor.SetFacingDir(Handle(self.sStreetGuard2), hSab)
    Actor.PlayAnimation(Handle(self.sStreetGuard2), "nazi_halt_1")
    Actor.PlayAnimation(Handle(self.sStreetGuard), "nazi_halt_1")
    Cin.PlayConversationWith("P2FP_GrandSniper_NaziGuard", {
      Handle(self.sStreetGuard)
    })
  end
end

function P2FP_RadioRescue:StreetGuardWarnsFront()
  if not Actor.IsDisguised(hSab) then
    Actor.SetFacingDir(Handle(self.sStreetGuard3), hSab)
    Actor.SetFacingDir(Handle(self.sStreetGuard4), hSab)
    Actor.PlayAnimation(Handle(self.sStreetGuard3), "nazi_halt_1")
    Actor.PlayAnimation(Handle(self.sStreetGuard4), "nazi_halt_1")
    Cin.PlayConversationWith("P2FP_GrandSniper_NaziGuard", {
      Handle(self.sStreetGuard3)
    })
  end
end

function P2FP_RadioRescue:LockDoorOpen()
  AttractionPt.EnableUse(Handle("Missions\\freeplay\\p2\\mis_rescue_radioguy\\main\\TP_JailDoor"), false)
end

function P2FP_RadioRescue:SpottedVO()
  Cin.PlayConversation("P2FP_RadioRescue_Spotted")
end

function P2FP_RadioRescue:SetUpWatch()
  self.sPrisonArea = "Missions\\freeplay\\p2\\mis_rescue_radioguy\\main\\PT_PrisonArea"
  self.hEnterEvent = EVENT_ActorEntersTrigger("P2FP_RadioRescue.CheckEscalation", self, hSab, self.sPrisonArea, {}, true)
  self.hEscalationEvent = EVENT_OnEscalation("P2FP_RadioRescue.CheckTrigger", self, {}, true)
end

function P2FP_RadioRescue:DoSightCheckPrisoner()
  local hAlertTrigger = Handle("Missions\\freeplay\\p2\\mis_rescue_radioguy\\main\\PT_Alert")
  local hSeanFilter = Filter.New("Player")
  local tSeanInside = {}
  tSeanInside = Trigger.GetAllWithin(hAlertTrigger, hSeanFilter)
  if tSeanInside[1] ~= hSab then
    EVENT_PlayerEntersTrigger("P2FP_RadioRescue.DoSightCheckPrisoner", self, "Missions\\freeplay\\p2\\mis_rescue_radioguy\\main\\PT_Alert")
    return
  end
  bDisguised = Actor.IsDisguised(hSab)
  if not bDisguised then
    for i, sEnt in ipairs(self.tNaziGuards) do
      if Object.IsAlive(Handle(sEnt)) and Sensory.CanSee(Handle(sEnt), self.hPrisoner) then
        Suspicion.SetEscalated()
      end
    end
  end
  local tTimerEvent = {EventType = "TimerEvent", Time = 1.5}
  self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P2FP_RadioRescue.DoSightCheckPrisoner", self))
end

function P2FP_RadioRescue:CheckEscalation()
  nEscalationLevel = Suspicion.GetEscalation()
  if nEscalationLevel > 0 then
    Util.KillEvent(self.hEscalationEvent)
    if Object.IsAlive(Handle(self.sNaziOfficer)) then
      tOpenCageSequence = {
        {
          "RUNTOOBJECT",
          {
            "Missions\\freeplay\\p2\\mis_rescue_radioguy\\main\\TP_JailDoor"
          }
        },
        {
          "USEATTRPT",
          {
            "Missions\\freeplay\\p2\\mis_rescue_radioguy\\main\\TP_JailDoor"
          }
        }
      }
      ScriptSequence.Run(Handle(self.sNaziOfficer), tOpenCageSequence, "P2FP_RadioRescue.ExecuteBryman")
    end
  end
end

function P2FP_RadioRescue:CheckTrigger()
  tWithinTrigger = Trigger.GetAllWithin(Handle(self.sPrisonArea))
  if tWithinTrigger[1] == hSab then
    Util.KillEvent(self.hEnterEvent)
    if Object.IsAlive(Handle(self.sNaziOfficer)) then
      tOpenCageSequence = {
        {
          "RUNTOOBJECT",
          {
            "Missions\\freeplay\\p2\\mis_rescue_radioguy\\main\\TP_JailDoor"
          }
        },
        {
          "USEATTRPT",
          {
            "Missions\\freeplay\\p2\\mis_rescue_radioguy\\main\\TP_JailDoor"
          }
        }
      }
      ScriptSequence.Run(Handle(self.sNaziOfficer), tOpenCageSequence, "P2FP_RadioRescue.ExecuteBryman")
    end
  end
end

function P2FP_RadioRescue:ExecuteBryman()
  Util.CreateExecutionScene(Handle(self.sNaziOfficer), {
    Handle(self.hPrisoner)
  }, 1)
end

function P2FP_RadioRescue:EscapeVO()
  if Suspicion.GetEscalation() > 0 then
    Cin.PlayConversation("P2FP_RadioRescue_Escalated")
  else
    Cin.PlayConversation("P2FP_RadioRescue_Disguised")
  end
end

function P2FP_RadioRescue:OnPrisonerReachesHQ()
  Util.UnloadEditNode("Missions\\freeplay\\p2\\mis_rescue_radioguy\\radioguy.wsd")
  EVENT_Timer("P2FP_RadioRescue.FadeOutFinish", self, 3)
end

function P2FP_RadioRescue:FadeOutFinish()
  self:CompleteThisMission()
end

function P2FP_RadioRescue:MISSION_ONRESET()
  Sound.ResetMusicLocale()
end
