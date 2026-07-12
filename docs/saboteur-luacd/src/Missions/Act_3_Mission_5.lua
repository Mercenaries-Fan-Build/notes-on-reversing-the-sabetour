if Act_3_Mission_5 == nil then
  Act_3_Mission_5 = SabTaskObjective:Create()
  gsSMEDNodeDir = "Missions\\act_3\\mission_5\\"
  Act_3_Mission_5:Configure({
    TaskCount = 999,
    bStarterless = true,
    tStarterPlayerLoc = gsSMEDNodeDir .. "starter\\Start",
    sSaveMissionNameID = "MissionNames_Text.A3M5",
    tUnlockList = {
      "Connect_A3_M6b_BackToParis"
    },
    tSMEDNodes = {
      gsSMEDNodeDir .. "obj",
      gsSMEDNodeDir .. "starter",
      gsSMEDNodeDir .. "larrawallhall",
      gsSMEDNodeDir .. "enc1_activity\\spawners",
      gsSMEDNodeDir .. "enc1_controlroom\\spawners",
      gsSMEDNodeDir .. "enc0_gondola\\spawners"
    }
  })
end

function Act_3_Mission_5:STARTER_Setup()
end

function Act_3_Mission_5:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Act_3_Mission_5:GENERAL_Setup()
  print("GeneralSetup!")
  Util.EnableMiniZep(false)
  Util.EnableBirds(false)
  Suspicion.SetEscalationLevel(2)
  self.RegisterCheckpoint(self, "Act_3_Mission_5.SetUpCheckpoint0")
  EVENT_Timer("Act_3_Mission_5.MoveGondola", self, 5)
  self.SetupDoorTriggers(self)
  self.KesslerMoveCheck(self)
  Act_3_Mission_5.MoveAiUnit(self, "Missions\\act_3\\mission_5\\enc1_controlroom\\Spore_SS_Heavy_MG(4)", "Missions\\act_3\\mission_5\\larrawallhall\\LC_AiTest")
  Act_3_Mission_5.SetUpNodeLoading(self)
  self.SetupTimer(self)
  local hKess1 = Handle("Missions\\act_3\\mission_5\\starter\\A3M5_Kessler")
  local hKess2 = Handle("Missions\\act_3\\mission_5\\starter\\Gondola_Kessler")
  local tKessDeathEvent1 = {EventType = "DeathEvent", ObjectHandle = hKess1}
  local tKessDeathEvent2 = {EventType = "DeathEvent", ObjectHandle = hKess2}
  Util.CreateEvent(tKessDeathEvent1, "Act_3_Mission_5.FailureToLaunch", self)
  Util.CreateEvent(tKessDeathEvent2, "Act_3_Mission_5.FailureToLaunch", self)
  self.bConversationsIn = true
end

function Act_3_Mission_5:SetUpCheckpoint0()
  print("SetUpCheckpoint0!")
  self.SetupDoorTriggers(self)
  EVENT_Timer("Act_3_Mission_5.MoveGondola", self, 5)
end

function Act_3_Mission_5:SetUpCheckpoint01()
  self:CompleteTaskByName("Task_GondolaDoor")
end

function Act_3_Mission_5.Cine_Disarm(Act_3_Mission_5)
end

function Act_3_Mission_5:SetUpNodeLoading()
  print("SetUpNodeLoading!")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.LoadZone1", self, "Missions\\act_3\\mission_5\\events\\PT_load_enc2")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.LoadZone2", self, "Missions\\act_3\\mission_5\\events\\PT_load_enc3")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.LoadZone3", self, "Missions\\act_3\\mission_5\\events\\PT_unload_enc2")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.LoadZone4", self, "Missions\\act_3\\mission_5\\events\\PT_load_enc4")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.LoadZone5a", self, "Missions\\act_3\\mission_5\\events\\PT_load_enc5")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.LoadZone5", self, "Missions\\act_3\\mission_5\\events\\PT_unload_enc4")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.LoadZone6", self, "Missions\\act_3\\mission_5\\events\\PT_unload_enc5")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.LoadZone7", self, "Missions\\act_3\\mission_5\\events\\PT_unload_enc5b")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.LoadZone8", self, "Missions\\act_3\\mission_5\\events\\PT_load_enc67")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.LoadZone9", self, "Missions\\act_3\\mission_5\\events\\PT_load_enc8")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.LoadZone10", self, "Missions\\act_3\\mission_5\\events\\PT_load_enc9")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.ScientistsFlee", self, "Missions\\act_3\\mission_5\\enc1_controlroom\\PT_flee")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.KesslerDoor1", self, "Missions\\act_3\\mission_5\\enc9_escape\\PT_ElevatorTop")
end

function Act_3_Mission_5:KesslerDoor1()
  Object.ForceOpen(Util.GetHandleByName("Missions\\act_3\\mission_5\\enc1_controlroom\\WH_Shaft_DoubleDoor_A"), true)
end

function Act_3_Mission_5:LoadZone1()
  print("LoadZone1!")
  self.ConversationPlayer(self, "A3M5_Elevator01_Exit")
  Util.UnloadEditNode("Missions\\act_3\\mission_5\\enc1_controlroom\\spawners.wsd")
  Util.UnloadEditNode("Missions\\act_3\\mission_5\\enc1_activity\\spawners.wsd")
  Util.SpawnEditNode("Missions\\act_3\\mission_5\\enc2_elevator\\spawners.wsd")
  Util.SpawnEditNode("Missions\act_3mission_5enc3_activity.wsd")
end

function Act_3_Mission_5:LoadZone2()
  print("LoadZone2!")
  self.ConversationPlayer(self, "A3M5_ServiceArea_Ambient01")
  Util.SpawnEditNode("Missions\\act_3\\mission_5\\enc3_blastdoors\\scripted.wsd")
  Util.SpawnEditNode("Missions\\act_3\\mission_5\\enc3_blastdoors\\spawners.wsd")
end

function Act_3_Mission_5:LoadZone3()
  print("LoadZone3!")
  Util.UnloadEditNode("Missions\\act_3\\mission_5\\enc2_elevator\\spawners.wsd")
end

function Act_3_Mission_5:LoadZone4()
  print("LoadZone4!")
  Util.UnloadEditNode("Missions\\act_3\\mission_5\\enc3_blastdoors\\scripted.wsd")
  Util.UnloadEditNode("Missions\\act_3\\mission_5\\enc3_blastdoors\\spawners.wsd")
  Util.SpawnEditNode("Missions\\act_3\\mission_5\\enc4_labs\\spawners.wsd")
end

function Act_3_Mission_5:LoadZone5a()
  print("LoadZone5a!")
  Util.SpawnEditNode("Missions\\act_3\\mission_5\\enc5_hangar\\spawners.wsd")
end

function Act_3_Mission_5:LoadZone5()
  print("LoadZone5!")
  Util.UnloadEditNode("Missions\\act_3\\mission_5\\enc4_labs\\spawners.wsd")
end

function Act_3_Mission_5:LoadZone6()
  print("LoadZone6!")
  Util.SpawnEditNode("Missions\\act_3\\mission_5\\enc5_hangar\\spawners.wsd")
end

function Act_3_Mission_5:LoadZone7()
  print("LoadZone7!")
  Util.UnloadEditNode("Missions\\act_3\\mission_5\\enc5_hangar\\spawners.wsd")
end

function Act_3_Mission_5:LoadZone8()
  print("LoadZone8!")
  Util.SpawnEditNode("Missions\\act_3\\mission_5\\enc6_fuel\\spawners.wsd")
  Util.SpawnEditNode("Missions\\act_3\\mission_5\\enc7_scaffold\\spawners.wsd")
end

function Act_3_Mission_5:LoadZone9()
  print("LoadZone9!")
  Util.SpawnEditNode("Missions\\act_3\\mission_5\\enc8_rocket\\spawners.wsd")
end

function Act_3_Mission_5:LoadZone10()
  print("LoadZone9!")
  Util.SpawnEditNode("Missions\\act_3\\mission_5\\enc9_escape\\spawners.wsd")
  Util.UnloadEditNode("Missions\\act_3\\mission_5\\enc6_fuel\\spawners.wsd")
  Util.UnloadEditNode("Missions\\act_3\\mission_5\\enc7_scaffold\\spawners.wsd")
  Util.UnloadEditNode("Missions\\act_3\\mission_5\\enc8_rocket\\spawners.wsd")
end

function Act_3_Mission_5:ScientistsFlee()
  print("ScientistsFlee!")
  local hScientist1 = Handle("Missions\\act_3\\mission_5\\enc1_controlroom\\spawners\\Spore_NZ_Scientist(2)")
  local hScientist2 = Handle("Missions\\act_3\\mission_5\\enc1_controlroom\\spawners\\Spore_NZ_Scientist")
  local hPath = Handle("Missions\\act_3\\mission_5\\enc1_controlroom\\spawners\\PA_flee")
  ACTOR_RunPathOnce(hScientist1, hPath)
  ACTOR_RunPathOnce(hScientist2, hPath)
end

function Act_3_Mission_5:CloseControlDoor()
end

function Act_3_Mission_5:KesslerMoveCheck()
  print("Kessler Move Check!")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.KesslerMoveTo1", self, "Missions\\act_3\\mission_5\\enc1_activity\\PT_Kessler1")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.KesslerMoveTo2", self, "Missions\\act_3\\mission_5\\enc1_activity\\PT_Kessler2")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.KesslerMoveTo3", self, "Missions\\act_3\\mission_5\\enc1_activity\\PT_Kessler3")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.KesslerMoveTo4", self, "Missions\\act_3\\mission_5\\enc1_activity\\PT_Kessler4")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.KesslerMoveTo5", self, "Missions\\act_3\\mission_5\\enc1_activity\\PT_Kessler5")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.KesslerMoveTo6", self, "Missions\\act_3\\mission_5\\enc1_activity\\PT_Kessler6")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.KesslerMoveTo7", self, "Missions\\act_3\\mission_5\\enc1_activity\\PT_Kessler7")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.KesslerMoveTo8", self, "Missions\\act_3\\mission_5\\enc1_activity\\PT_Kessler8")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.KesslerMoveTo9", self, "Missions\\act_3\\mission_5\\enc1_activity\\PT_Kessler9")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.EnterSericeTunnel", self, "Missions\\act_3\\mission_5\\obj\\PT_OBJ24")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.ElevatorTop", self, "Missions\\act_3\\mission_5\\enc9_escape\\PT_ElevatorTop")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.KesslerBreach2", self, "Missions\\act_3\\mission_5\\enc9_escape\\PT_KesslerBreach2")
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.KesslerBreach3", self, "Missions\\act_3\\mission_5\\enc9_escape\\PT_KesslerBreach3")
end

function Act_3_Mission_5:SetupTimer()
  print("SetupTimer!")
  local uCheckTime = self:GetCheckpointName()
  print("uCheckTime = ")
  print(uCheckTime)
  if uCheckTime == "Act_3_Mission_5.SetUpCheckpoint0" then
    self.nTimer = 1440
  elseif uCheckTime == "Act_3_Mission_5.SetUpCheckpoint1" then
    self.nTimer = 1080
  elseif uCheckTime == "Act_3_Mission_5.SetUpCheckpoint2" then
    self.nTimer = 720
  elseif uCheckTime == "Act_3_Mission_5.SetUpCheckpoint3" then
    self.nTimer = 360
  elseif uCheckTime == "Act_3_Mission_5.SetUpCheckpointSupplyRoom" then
    self.nTimer = 360
  elseif uCheckTime == "Act_3_Mission_5.SetUpCheckpointRocket" then
    self.nTimer = 360
  elseif uCheckTime == "Act_3_Mission_5.SetUpCheckpoint4" then
    self.nTimer = 360
  else
    self.nTimer = 1800
  end
  print("self.nTimer = ")
  print(self.nTimer)
  self.TempObjectiveID = HUD.AddObjective(eOT_TIMER, SabTask:GetLocalizedText("GenericObjective_Text.BAR_Time_Remaining"), 2, self:GetTaskObjectiveID("Act_3_Mission_5.Parent_SabotageLaunch"))
  HUD.SetupProgressBar(self.TempObjectiveID, self.nTimer, 0, self.nTimer)
  HUD.AddProgressBarCallback(self.TempObjectiveID, "Act_3_Mission_5.FailureToLaunch", 0, self, {})
end

function Act_3_Mission_5:FailureToLaunch()
  print("FailureToLaunch!")
  self:MissionTaskFail()
end

function Act_3_Mission_5:Task_ExitGondola()
  print("Task_ExitGondola!")
  self:CreateTask({
    sName = "Task_ExitGondola",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
    sObjectiveTextID = "A3M5_Text.Task_ExitGondola",
    tLocators = {
      "Missions\\act_3\\mission_5\\obj\\LC_Task_ExitGondola"
    },
    tDestRegion = "Missions\\act_3\\mission_5\\obj\\PT_Task_ExitGondola",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Task4Move,
        {self}
      }
    }
  })
end

function Act_3_Mission_5:Task_GondolaDoor()
  print("Task_GondolaDoor!")
  self.ConversationPlayer(self, "A3M5_GondolaBay_Approach")
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_5\\starter\\Gondola_Kessler")
  local hAttrPt = Util.GetHandleByName("Missions\\act_3\\mission_5\\larrawallhall\\GondolaKessler_ATTRPT")
  self:CreateTask({
    sName = "Task_GondolaDoor",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "none",
    tLocators = {
      "Missions\\act_3\\mission_5\\obj\\LC_Task_DeliverKesslerGondola"
    },
    sObjectiveTextID = "A3M5_Text.Task_GondolaDoor",
    tOnComplete = {
      {
        self.Task_DeliverKessler,
        {self}
      },
      {
        self.Task_OpenGate,
        {self}
      }
    }
  })
  local tProxiEvent = {
    EventType = "ProximityEvent",
    EventName = "KesslerGondola",
    ObjectA = hKessler,
    ObjectB = hAttrPt,
    Proximity = 10
  }
  local eEvent = Util.CreateEvent(tProxiEvent, "Act_3_Mission_5.StartKesslerEvent", self)
  self.ConversationPlayer(self, "A3M5_GondolaBay_OpensDoors")
end

function Act_3_Mission_5:StartKesslerEvent()
  print("$$$$$$$$$$$StartKesslerEvent")
  Nav.StopMoving(Handle("Missions\\act_3\\mission_5\\starter\\Gondola_Kessler"))
  Actor.RequestAttrPt(Handle("Missions\\act_3\\mission_5\\starter\\Gondola_Kessler"), Util.GetHandleByName("Missions\\act_3\\mission_5\\larrawallhall\\GondolaKessler_ATTRPT"))
  EVENT_Timer("Act_3_Mission_5.SetUpCheckpoint01", self, 10)
end

function Act_3_Mission_5:Parent_SabotageLaunch()
  print("Sabotage Launch!")
  self.ConversationPlayer(self, "A3M5_GondolaBay_Start")
  self:CreateTask({
    sName = "Parent_SabotageLaunch",
    sTaskType = "SabTaskObjectiveEmpty",
    sObjectiveTextID = "A3M5_Text.Task_SabotageLaunch",
    tOnActivate = {
      {
        self.Task_ExitGondola,
        {self}
      }
    }
  })
end

function Act_3_Mission_5:Task_DeliverKessler()
  print("Deliver Kessler!")
  Object.PlayerTeleportToLocator(Util.GetHandleByName("Missions\\act_3\\mission_5\\starter\\Start"))
  Sound.LoadSoundBank("m_A3M5_inGame.bnk")
  Render.WTFSetOverrideBlueprint("WillToFight_INT_WallHall_Main")
  self:CreateTask({
    sName = "Task_DelivErKessler",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Escort",
    bWimpy = true,
    tLocators = {
      "Missions\\act_3\\mission_5\\obj\\LC_OBJ13"
    },
    tDestRegion = {
      "Missions\\act_3\\mission_5\\obj\\PT_OBJ13"
    },
    tDeliverObjs = {
      "Missions\\act_3\\mission_5\\starter\\A3M5_Kessler"
    },
    sObjectiveTextID = "A3M5_Text.Task_DeliverKessler",
    tOnFailure = {},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Act_3_Mission_5.SetUpCheckpoint1"
        }
      }
    }
  })
  EVENT_PlayerEntersTrigger("Act_3_Mission_5.KesslerTeleport", self, "Missions\\act_3\\mission_5\\obj\\PT_KesslerControlRoom")
end

function Act_3_Mission_5:KesslerTeleport()
  print("Kessler Teleport$$$$$$$$$$$$")
  Object.Teleport(Handle("Missions\\act_3\\mission_5\\starter\\A3M5_Kessler"), 1685, 104, -3717.0005, 30)
  EVENT_Timer("Act_3_Mission_5.KesslerAttractionPoint", self, 5)
end

function Act_3_Mission_5:KesslerAttractionPoint()
  print("KesslerAttractionPoint$$$$$$$$$$$$")
  Nav.StopMoving(Handle("Missions\\act_3\\mission_5\\starter\\A3M5_Kessler"))
  Actor.RequestAttrPt(Handle("Missions\\act_3\\mission_5\\starter\\A3M5_Kessler"), Util.GetHandleByName("Missions\\act_3\\mission_5\\larrawallhall\\Kessler_ATTRPT"))
end

function Act_3_Mission_5:SetUpCheckpoint1()
  print("SetUpCheckpoint1!")
  self.ConversationPlayer(self, "A3M5_ControlRoomGoTo_Entered")
  self.ConversationPlayer(self, "A3M5_ControlRoom_Secured")
  self.SetupDoorTriggers(self)
  Act_3_Mission_5.Task_EnterElevator(self)
end

function Act_3_Mission_5:Task_OpenGate()
  print("Task_OpenGate")
  self:CreateTask({
    sName = "Task_OpenGate",
    sTaskType = "SabTaskObjectiveInteract",
    sObjectiveTextID = "A3M5_Text.Task_OpenGate",
    sTaskSubType = "USE",
    tTgtInclude = {
      "Missions\\act_3\\mission_5\\obj\\DT_CR_door5A(3)"
    },
    tOnComplete = {}
  })
end

function Act_3_Mission_5:Task_UseConsole()
  print("Task_UseConsole")
  Object.ForceOpen(Util.GetHandleByName("CountrySide\\alsace\\walhal_interiors\\buildings\\WH_CtrlRoom_Blastdoor_A(11)"))
  self.Task_EnterElevator(self)
end

function Act_3_Mission_5:Task_EnterElevator()
  self.ConversationPlayer(self, "A3M5_Elevator01_GoTo")
  if uTask_EnterElevator == 1 then
    print("uTask_EnterElevator entered!")
    self.SetupTimer(self)
  else
    uTask_EnterElevator = 1
  end
  print("uTask_EnterElevator = ")
  print(uTask_EnterElevator)
  self:CreateTask({
    sName = "Task_EnterElevator",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
    sObjectiveTextID = "A3M5_Text.Task_EnterElevator",
    tLocators = {
      "Missions\\act_3\\mission_5\\obj\\LC_Elevator1_Task_EnterElevator"
    },
    tDestRegion = "Missions\\act_3\\mission_5\\obj\\PT_Elevator1_Task_EnterElevator",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Task_EnterSecondaryElevator,
        {self}
      }
    }
  })
end

function Act_3_Mission_5:Task_EnterSecondaryElevator()
  print("Enter access room!")
  Object.ForceClose(Util.GetHandleByName("Missions\\act_3\\mission_5\\enc1_controlroom\\WH_Shaft_DoubleDoor_A(1)"))
  Object.ForceOpen(Util.GetHandleByName("Missions\\act_3\\mission_5\\enc2_elevator\\WH_Elevator_1"))
  self:CreateTask({
    sName = "Task_EnterSecondaryElevator",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
    sObjectiveTextID = "A3M5_Text.Task_EnterSecondaryElevator",
    tLocators = {
      "Missions\\act_3\\mission_5\\obj\\LC_Task_EnterSecondaryElevator"
    },
    tDestRegion = "Missions\\act_3\\mission_5\\enc2_elevator\\PT_Elevator3",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Task_CaveBack,
        {self}
      }
    }
  })
end

function Act_3_Mission_5:Task_EnterCave()
  print("Task_EnterCave!")
  self:CreateTask({
    sName = "Task_EnterCave",
    sTaskType = "SabTaskObjectiveInteract",
    sObjectiveTextID = "A3M5_Text.Task_EnterCave",
    sTaskSubType = "USE",
    tTgtInclude = {
      "Missions\\act_3\\mission_5\\obj\\DT_OpenCaveDoor"
    },
    tOnComplete = {
      {
        self.Task_CaveBack,
        {self}
      }
    }
  })
end

function Act_3_Mission_5:Task_CaveBack()
  print("Task_EnterCave!")
  self:CreateTask({
    sName = "Task_CaveBack",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
    sObjectiveTextID = "A3M5_Text.Task_CaveBack",
    tLocators = {
      "Missions\\act_3\\mission_5\\obj\\LC_Task_CaveBack"
    },
    tDestRegion = "Missions\\act_3\\mission_5\\obj\\PT_Task_CaveBack",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Task_EnterServiceTunnel,
        {self}
      }
    }
  })
end

function Act_3_Mission_5:Task_EnterServiceTunnel()
  print("Task_EnterServiceTunnel!")
  self:CreateTask({
    sName = "Task_EnterServiceTunnel",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
    sObjectiveTextID = "A3M5_Text.Task_EnterServiceTunnel",
    tLocators = {
      "Missions\\act_3\\mission_5\\obj\\LC_Task_EnterServiceTunnel"
    },
    tDestRegion = "Missions\\act_3\\mission_5\\obj\\PT_Task_EnterServiceTunnel",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Task_EnterAccessRoom,
        {self}
      }
    }
  })
end

function Act_3_Mission_5:Task_EnterAccessRoom()
  print("Enter access room!")
  self:CreateTask({
    sName = "Task_EnterAccessRoom",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
    sObjectiveTextID = "A3M5_Text.Task_EnterAccessRoom",
    tLocators = {
      "Missions\\act_3\\mission_5\\obj\\LC_TaskEnterAccessRoom"
    },
    tDestRegion = "Missions\\act_3\\mission_5\\obj\\PT_TaskEnterAccessRoom",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Task_OpenBlastDoors,
        {self}
      }
    }
  })
end

function Act_3_Mission_5:Task_OpenBlastDoors()
  print("Open blast doors!")
  self.ConversationPlayer(self, "A3M5_BlastDoor01_Start")
  self:CreateTask({
    sName = "Task_OpenBlastDoors",
    sTaskType = "SabTaskObjectiveInteract",
    sObjectiveTextID = "A3M5_Text.Task_OpenBlastDoors",
    ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
    sTaskSubType = "USE",
    tTgtInclude = {
      "Missions\\act_3\\mission_5\\obj\\DT_Task_OpenBlastDoors"
    },
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Act_3_Mission_5.SetUpCheckpoint2"
        }
      }
    }
  })
  Actor.PlayAnimation(hSab, "shrd_Kick_on_ground")
end

function Act_3_Mission_5:SetUpCheckpoint2()
  print("SetUpCheckpoint2!")
  self.ConversationPlayer(self, "A3M5_BlastDoor01_Opened")
  self.SetupDoorTriggers(self)
  Act_3_Mission_5.Task_SabotageCoolant(self)
end

function Act_3_Mission_5:Task_DestroyPanel()
  print("Destroy panel!")
  if uTask_DestroyPanel == 1 then
    print("uTask_DestroyPanel entered!")
    self.SetupTimer(self)
  else
    uTask_DestroyPanel = 1
  end
  self.ConversationPlayer(self, "A3M5_BlastDoor02_Start")
  self:CreateTask({
    sName = "Task_DestroyPanel",
    sTaskType = "SabTaskObjectiveDestroy",
    ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
    sObjectiveTextID = "A3M5_Text.Task_DestroyPanel",
    sTaskSubType = "KILL",
    tTgtInclude = {
      "Missions\\act_3\\mission_5\\enc3_blastdoors\\WH_Shaft_Switch_C_Console(12)\\WH_Shaft_Switch_C_Console"
    },
    tOnComplete = {
      {
        self.Task_EnterAccessElevator,
        {self}
      }
    }
  })
  local tEvent = {}
  tEvent = {EventType = "TimerEvent", Time = 50}
  Util.CreateEvent(tEvent, "Act_3_Mission_5.StartDoorSequence", self, {
    {
      "Missions\\act_3\\mission_5\\enc3_blastdoors\\flaps\\blastflap01"
    },
    51
  })
end

function Act_3_Mission_5:Task_SabotageCoolant()
  print("Task_SabotageCoolant")
  Inventory.GiveItem(hSab, "WP_SAB_BridgeKiller", false)
  self:CreateTask({
    sName = "Task_SabotageCoolant",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "Sabotage",
    tTgtInclude = {
      "Missions\\act_3\\mission_5\\obj\\Sab_pipe"
    },
    sObjectiveTextID = "A3M5_Text.Task_SabotageCoolant",
    tOnComplete = {
      {
        self.Task_EnterAccessElevator,
        {self}
      }
    }
  })
end

function Act_3_Mission_5:Task_OpenElevatorAccess()
  print("Open elevator access!")
  Object.ForceOpen(Util.GetHandleByName("Missions\\act_3\\mission_5\\enc3_blastdoors\\doors\\Door6"))
  self:CreateTask({
    sName = "Task_OpenElevatorAccess",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
    sObjectiveTextID = "A3M5_Text.Task_OpenElevatorAccess",
    tLocators = {
      "Missions\\act_3\\mission_5\\obj\\LC_Task_OpenElevatorAccess"
    },
    tDestRegion = "Missions\\act_3\\mission_5\\obj\\PT_Task_OpenElevatorAccess",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Task_EnterAccessElevator,
        {self}
      }
    }
  })
end

function Act_3_Mission_5:Task_EnterAccessElevator()
  print("Open blast doors!")
  Object.ForceOpen(Util.GetHandleByName("Missions\\act_3\\mission_5\\enc3_blastdoors\\doors\\Door6"))
  self:CreateTask({
    sName = "Task_EnterAccessElevator",
    sTaskType = "SabTaskObjectiveInteract",
    ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
    sObjectiveTextID = "A3M5_Text.Task_EnterAccessElevator",
    sTaskSubType = "USE",
    tTgtInclude = {
      "Missions\\act_3\\mission_5\\obj\\DT_Task_UseElevator"
    },
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Act_3_Mission_5.SetUpCheckpoint3"
        }
      }
    }
  })
end

function Act_3_Mission_5:SetUpCheckpoint3()
  print("SetUpCheckpoint3!")
  self.ConversationPlayer(self, "A3M5_Elevator03_Ride")
  self.SetupDoorTriggers(self)
  Act_3_Mission_5.Task_EnterMaintenanceRoom(self)
end

function Act_3_Mission_5:Task_EnterMaintenanceRoom()
  print("Task_EnterMaintenanceRoom!")
  if uTask_EnterMaintenanceRoom == 1 then
    print("uTask_EnterMaintenanceRoom entered!")
    self.SetupTimer(self)
  else
    uTask_EnterMaintenanceRoom = 1
  end
  self:CreateTask({
    sName = "Task_EnterMaintenanceRoom",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
    sObjectiveTextID = "A3M5_Text.Task_EnterMaintenanceRoom",
    tLocators = {
      "Missions\\act_3\\mission_5\\obj\\LC_Task_EnterMaintenanceRoom"
    },
    tDestRegion = "Missions\\act_3\\mission_5\\obj\\PT_Task_EnterMaintenanceRoom",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.Task_GetToSupplyRoom,
        {self}
      }
    }
  })
end

function Act_3_Mission_5:Task_GetToSupplyRoom()
  print("Task_GetToSupplyRoom!")
  self:CreateTask({
    sName = "Task_GetToSupplyRoom",
    sTaskType = "SabTaskObjectiveInteract",
    ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
    sObjectiveTextID = "A3M5_Text.Task_GetToSupplyRoom",
    sTaskSubType = "USE",
    tTgtInclude = {
      "Missions\\act_3\\mission_5\\obj\\DT_Task_GetToSupplyRoom"
    },
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Act_3_Mission_5.SetUpCheckpointSupplyRoom"
        }
      }
    }
  })
end

function Act_3_Mission_5:SetUpCheckpointSupplyRoom()
  print("SetUpCheckpointSupplyRoom!")
  self.SetupDoorTriggers(self)
  Act_3_Mission_5.Task_RocketElevator1(self)
end

function Act_3_Mission_5:Task_RocketElevator1()
  print("Task_RocketElevator1!")
  self.ConversationPlayer(self, "A3M5_SupplyRoom_DoorsOpened")
  local uElevPt1 = Object.GetAttrPtAttachments(Util.GetHandleByName("Missions\\act_3\\mission_5\\enc6_fuel\\OccLt_Elevator_5s\\OccLt_Elevator_5s_4x2z"))
  print("uElevPt1")
  print(uElevPt1[1])
  if uElevPt1 ~= nil then
    self:CreateTask({
      sName = "Task_RocketElevator1",
      sTaskType = "SabTaskObjectiveInteract",
      ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
      sObjectiveTextID = "A3M5_Text.Task_RocketElevator1",
      sTaskSubType = "USE",
      tTgtInclude = {
        uElevPt1[1]
      },
      tOnComplete = {
        {
          self.Task_RocketElevator2,
          {self}
        }
      }
    })
  end
end

function Act_3_Mission_5:Task_RocketElevator2()
  print("Task_RocketElevator2!")
  self.ConversationPlayer(self, "A3M5_SabotageRocket_SecondPlatform")
  local uElevPt2 = Object.GetAttrPtAttachments(Util.GetHandleByName("Missions\\act_3\\mission_5\\enc6_fuel\\OccLt_Elevator_5s(3)\\OccLt_Elevator_5s_4x2z"))
  print("uElevPt2")
  print(uElevPt2[1])
  if uElevPt2 ~= nil then
    self:CreateTask({
      sName = "Task_RocketElevator2",
      sTaskType = "SabTaskObjectiveInteract",
      ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
      sObjectiveTextID = "A3M5_Text.Task_RocketElevator1",
      sTaskSubType = "USE",
      tTgtInclude = {
        uElevPt2[1]
      },
      tOnComplete = {
        {
          self.Task_SabotageRocket,
          {self}
        }
      }
    })
  end
end

function Act_3_Mission_5:Task_SabotageRocket()
  print("Disarm Warhead!")
  self.ConversationPlayer(self, "A3M5_SabotageRocket_ThirdPlatform")
  self:CreateTask({
    sName = "ACT_3_MISSION_5_Task_SabotageRocket",
    sTaskType = "SabTaskObjectiveDeliver",
    ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
    sTaskSubType = "GOTO",
    sObjectiveTextID = "A3M5_Text.Task_SabotageRocket",
    tLocators = {
      "Missions\\act_3\\mission_5\\obj\\LC_OBJ27_Rocket"
    },
    tDestRegion = "Missions\\act_3\\mission_5\\obj\\PT_OBJ27_Rocket",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.RocketCinematicTest,
        {self}
      }
    }
  })
end

function Act_3_Mission_5:RocketCinematicTest()
  print("RocketCinematicTest$$$$")
  Cin.PlayCinematic("A3M5_DisarmRocket", false, "Act_3_Mission_5.SetUpCheckpointRocket", self)
end

function Act_3_Mission_5:SetUpCheckpointRocket()
  print("SetUpCheckpointRocket!")
  self:RegisterCheckpoint("Act_3_Mission_5.RocketCheckpoint")
end

function Act_3_Mission_5:RocketCheckpoint()
  print("RocketCheckpoint!")
  self.SetupDoorTriggers(self)
  self.SetUpNodeLoading(self)
  Act_3_Mission_5.Task_EnterAirshaft(self)
end

function Act_3_Mission_5:Task_EnterAirshaft()
  print("Task_EnterAirshaft!")
  self:CreateTask({
    sName = "Task_EnterAirshaft",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
    sObjectiveTextID = "A3M5_Text.Task_EnterAirshaft",
    tLocators = {
      "Missions\\act_3\\mission_5\\obj\\LC_Task_EnterAirshaft"
    },
    tDestRegion = "Missions\\act_3\\mission_5\\obj\\PT_Task_EnterAirshaft",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Act_3_Mission_5.SetUpCheckpoint4"
        }
      }
    }
  })
end

function Act_3_Mission_5:Task_GetToHatchControlRoom()
  print("Task_GetToHatchControlRoom!")
  self.ConversationPlayer(self, "A3M5_CloseSilo_Start")
  self:CreateTask({
    sName = "Task_GetToHatchControlRoom",
    sTaskType = "SabTaskObjectiveDeliver",
    ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
    sTaskSubType = "GOTO",
    sObjectiveTextID = "A3M5_Text.Task_GetToHatchControlRoom",
    tLocators = {
      "Missions\\act_3\\mission_5\\obj\\LC_Task_GetToHatchControlRoom"
    },
    tDestRegion = "Missions\\act_3\\mission_5\\obj\\PT_Task_GetToHatchControlRoom",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "Act_3_Mission_5.SetUpCheckpoint4"
        }
      }
    }
  })
end

function Act_3_Mission_5:SetUpCheckpoint4()
  print("SetUpCheckpoint4!")
  self.ConversationPlayer(self, "A3M5_CloseSilo_ControlRoom_Entered")
  self.ConversationPlayer(self, "A3M5_CloseSilo_ControlRoom_Defend")
  self.SetupDoorTriggers(self)
  Act_3_Mission_5.Task_GetToKessler(self)
end

function Act_3_Mission_5:Task_CloseHatch()
  print("Task_CloseHatch!")
  if uTask_CloseHatch == 1 then
    print("uTask_CloseHatch entered!")
    self.SetupTimer(self)
  else
    uTask_CloseHatch = 1
  end
  self:CreateTask({
    sName = "Task_CloseHatch",
    sTaskType = "SabTaskObjectiveInteract",
    ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
    sObjectiveTextID = "A3M5_Text.Task_CloseHatch",
    sTaskSubType = "USE",
    tTgtInclude = {
      "Missions\\act_3\\mission_5\\enc9_escape\\rooftrigger"
    },
    tOnComplete = {
      {
        self.Task_GetToKessler,
        {self}
      }
    }
  })
end

function Act_3_Mission_5:Task_GetToKessler()
  print("Task_GetToKessler!")
  local hDoor = Util.GetHandleByName("CountrySide\alsacewalhal_interiors\buildingsWH_Shaft_Shaft_Door_A(4)")
  Object.ForceOpen(hDoor)
  self.ConversationPlayer(self, "A3M5_Rocket_Ready")
  self.ConversationPlayer(self, "A3M5_Breach_Warning01")
  Object.Teleport(Handle("Missions\\act_3\\mission_5\\starter\\A3M5_Kessler"), 1692.5242, 100.31173, -3709.5535, 121.06365)
  self:CreateTask({
    sName = "Task_GetToKessler",
    sTaskType = "SabTaskObjectiveInteract",
    ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
    sObjectiveTextID = "A3M5_Text.Task_GetToKessler",
    sTaskSubType = "USE",
    tTgtInclude = {
      "Missions\\act_3\\mission_5\\enc1_controlroom\\DT_CR_door4A"
    },
    tOnComplete = {
      {
        self.Task_CutsceneByeKess,
        {self}
      }
    }
  })
end

function Act_3_Mission_5:KessGunpoint()
  Object.Teleport(Handle("Missions\\act_3\\mission_5\\starter\\A3M5_Kessler"), 1692.5242, 100.31173, -3709.5535, 121.06365)
end

function Act_3_Mission_5:Task_CutsceneByeKess()
  Cin.PlayConversation("409_Con _ByeKess", "Act_3_Mission_5.Task_VallaBoom", self)
end

function Act_3_Mission_5:Task_VallaBoom()
  self:CreateTask({
    sName = "Task_CutsceneByeKess",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "410_CinA_VallaBoom-Escaped",
    tOnComplete = {
      {
        self.MissionComplete,
        {self}
      }
    }
  })
end

function Act_3_Mission_5:Task_Escape()
  print("Escape!")
  self:CreateTask({
    sName = "ACT_3_MISSION_5_Task_Escape",
    sTaskType = "SabTaskObjectiveDeliver",
    ParentObjectID = self:GetTaskObjectiveID("Parent_SabotageLaunch"),
    sTaskSubType = "GOTO",
    sObjectiveTextID = "A3M5_Text.Task_Escape",
    tLocators = {
      "Missions\\act_3\\mission_5\\obj\\LC_OBJ10"
    },
    tDestRegion = "Missions\\act_3\\mission_5\\obj\\PT_OBJ10",
    tDeliverObjs = {hSab},
    tOnComplete = {
      {
        self.MissionComplete,
        {self}
      }
    }
  })
end

function Act_3_Mission_5:MissionComplete()
  print("Act_3_Mission_5.MissionComplete!")
  self:Cleanup()
  self:CompleteThisMission()
end

function Act_3_Mission_5:Cleanup()
  print("Cleanup!")
  Util.EnableMiniZep(true)
  if self.TempObjectiveID then
    print("TempObjectiveID!")
    HUD.RemoveObjective(self.TempObjectiveID)
    HUD.ClearGPSTarget()
  end
end

function Act_3_Mission_5:SetupDoorTriggers()
  print("SetUpDoorTriggers!")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc1_controlroom\\PT_CloseDoor1", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc1_controlroom\\WH_Shaft_DoubleDoor_C\\WH_Shaft_DoubleDoor_C"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc1_controlroom\\PT_CloseDoor1")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc1_controlroom\\PT_CloseDoor2", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc1_controlroom\\WH_Shaft_DoubleDoor_C(3)\\WH_Shaft_DoubleDoor_C"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc1_controlroom\\PT_CloseDoor2")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc2_elevator\\PT_Elevator2", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc2_elevator\\WH_Shaft_BlastDoorA1(2)",
      "Missions\\act_3\\mission_5\\enc2_elevator\\WH_Shaft_BlastDoorA1(3)"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc2_elevator\\PT_Elevator2")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc2_elevator\\PT_Elevator3", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc2_elevator\\WH_Shaft_Shaft_Elevator_A",
      "Missions\\act_3\\mission_5\\enc0_exterior\\WH_ElevatorBlastWindow1"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc2_elevator\\PT_Elevator3")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc2_elevator\\PT_Elevator4", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc2_elevator\\WH_Door4"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc2_elevator\\PT_Elevator4")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc1_controlroom\\PT_CloseDoor4", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "CountrySide\\alsace\\walhal_interiors\\buildings\\Door4"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc1_controlroom\\PT_CloseDoor4")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc2_elevator\\PT_Close_ArcDoor1", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc2_elevator\\CaveDoor"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc2_elevator\\PT_Close_ArcDoor1")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc3_blastdoors\\PT_CloseDoor_Gate1", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "CountrySide\\alsace\\walhal_interiors\\buildings\\Gate1",
      "Missions\\act_3\\mission_5\\enc3_blastdoors\\flaps\\D3_LB"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc3_blastdoors\\scripted\\PT_CloseDoor_Gate1")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc5_hangar\\PT_Close_HangarDoor1", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc5_hangar\\HangarDoor1"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc5_hangar\\PT_Close_HangarDoor1")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc5_hangar\\PT_Close_HangarDoor2", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc5_hangar\\HangarDoor2"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc5_hangar\\PT_Close_HangarDoor2")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc6_fuel\\spawners\\PT_openhangardoors", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc5_hangar\\PT_Close_HangarDoor1",
      "Missions\\act_3\\mission_5\\enc5_hangar\\PT_Close_HangarDoor2"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc6_fuel\\spawners\\PT_openhangardoors")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc5_hangar\\PT_Close_HangarDoor2", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc5_hangar\\HangarDoor2"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc5_hangar\\PT_Close_HangarDoor2")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc6_fuel\\PT_opensilodoor_1", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\doors\\silodoor1"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc6_fuel\\PT_opensilodoor_1")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc6_fuel\\PT_opensilodoor_2", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\doors\\silodoor2"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc6_fuel\\PT_opensilodoor_2")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc6_fuel\\PT_opensilodoor_3", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\doors\\silodoor3"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc6_fuel\\PT_opensilodoor_3")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc3_blastdoors\\PT_opendoor_7B", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc3_blastdoors\\doors\\Door7B"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc3_blastdoors\\PT_opendoor_7B")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc9_escape\\PT_elevator_last", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc9_escape\\Elevator_last"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc9_escape\\PT_elevator_last")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc3_blastdoors\\PT_DoubleDoor_labs", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc3_blastdoors\\door_lablift"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc3_blastdoors\\PT_DoubleDoor_labs")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc2_elevator\\PT_close_door2", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc2_elevator\\WH_Door2"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc2_elevator\\PT_close_door2")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc2_elevator\\PT_close_Door4", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc2_elevator\\WH_Door4"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc2_elevator\\PT_close_Door4")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc3_blastdoors\\PT_close_door7b", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc3_blastdoors\\doors\\Door7b"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc3_blastdoors\\PT_close_door7b")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc6_fuel\\PT_opensilodoor_4", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\doors\\silodoor4"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc6_fuel\\PT_opensilodoor_4")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc4_labs\\PT_open_door_labliftB", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc4_labs\\door_labliftB"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc4_labs\\PT_open_door_labliftB")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc4_labs\\PT_close_door_labliftB", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc4_labs\\door_labliftB"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc4_labs\\PT_close_door_labliftB")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc3_blastdoors\\PT_OpenDoor32", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc3_blastdoors\\doors\\Door3"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc3_blastdoors\\PT_OpenDoor32")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc4_labs\\TR_Open_LabWindow1", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc4_labs\\LabWindow1"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc4_labs\\TR_Open_LabWindow1")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc9_escape\\PT_Open_CR_BD_A", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "CountrySide\\alsace\\walhal_interiors\\buildings\\WH_CtrlRoom_Blastdoor_A"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc9_escape\\PT_Open_CR_BD_A")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc3_blastdoors\\PT_CloseBlastPanels", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc3_blastdoors\\flaps\\D1_LB"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc3_blastdoors\\PT_CloseBlastPanels")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc5_hangar\\PT_CloseDoorEnc5A", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc5_hangar\\DoorEnc5A"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc5_hangar\\PT_CloseDoorEnc5A")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc5_hangar\\PT_CloseDoorEnc5B", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc5_hangar\\DoorEnc5B"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc5_hangar\\PT_CloseDoorEnc5B")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc8_rocket\\PT_gantry1", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\art_stuff\\WH_Shaft_Shaft_Gantry_A(1)"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc8_rocket\\PT_gantry1")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc8_rocket\\PT_gantry2", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc6_fuel\\WH_Shaft_Shaft_Gantry_A"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc8_rocket\\PT_gantry2")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc8_rocket\\PT_gantry2B", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc6_fuel\\WH_Shaft_Shaft_Gantry_A(2)"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc8_rocket\\PT_gantry2B")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc8_rocket\\PT_gantry3", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc6_fuel\\WH_Shaft_Shaft_Gantry_A(3)"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc8_rocket\\PT_gantry3")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc8_rocket\\PT_gantry4", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\art_stuff\\WH_Shaft_Shaft_Gantry_A(2)"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc8_rocket\\PT_gantry4")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc9_escape\\spawners\\PT_closedoor1", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc1_controlroom\\WH_Shaft_DoubleDoor_C"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc9_escape\\spawners\\PT_closedoor1")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc9_escape\\PT_OpenKesslerDoor", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc1_controlroom\\WH_Shaft_DoubleDoor_A(1)"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc9_escape\\PT_OpenKesslerDoor")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc8_rocket\\PT_gantry5", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\art_stuff\\WH_Shaft_Shaft_Gantry_A(5)"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc8_rocket\\PT_gantry5")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc8_rocket\\PT_openrooftop", hSab, "Act_3_Mission_5.CloseDoorForced", self, {
    {
      "CountrySide\\alsace\\walhal_interiors\\buildings\\WH_Shaft_Shaft_Door_A(4)"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc8_rocket\\PT_openrooftop")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc8_rocket\\PT_CPBlastDoorA", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "CountrySide\\alsace\\walhal_interiors\\buildings\\WH_CtrlRoom_Blastdoor_A"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc8_rocket\\PT_CPBlastDoorA")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc8_rocket\\PT_CPBlastDoorA5", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "CountrySide\\alsace\\walhal_interiors\\buildings\\WH_CtrlRoom_Blastdoor_A(5)"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc8_rocket\\PT_CPBlastDoorA5")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc9_escape\\PT_CPBlastDoorA6", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "CountrySide\\alsace\\walhal_interiors\\buildings\\WH_CtrlRoom_Blastdoor_A(6)"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc9_escape\\PT_CPBlastDoorA6")
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\act_3\\mission_5\\enc8_rocket\\PT_AccessShaft", hSab, "Act_3_Mission_5.OpenDoorForced", self, {
    {
      "Missions\\act_3\\mission_5\\enc8_rocket\\WH_Shaft_DoubleDoor_A0"
    }
  }, cTRIGGEREVENT_ONENTER), "Missions\\act_3\\mission_5\\enc8_rocket\\PT_AccessShaft")
end

function Act_3_Mission_5:OpenDoorForced(hwho, hUserData)
  local a, b
  for a, b in ipairs(hUserData) do
    local hDoor = Util.GetHandleByName(b)
    if hDoor then
      Object.ForceOpen(hDoor)
    end
  end
end

function Act_3_Mission_5:CloseDoorForced(hwho, hUserData)
  local a, b
  for a, b in ipairs(hUserData) do
    local hDoor = Util.GetHandleByName(b)
    if hDoor then
      Object.ForceClose(hDoor, true)
    end
  end
end

function Act_3_Mission_5:StartDoorSequence(tsPath, nTimer)
  local a, b
  for a, b in ipairs(tsPath) do
    local hDoor = Util.GetHandleByName(b)
    if hDoor then
      Object.ForceOpen(hDoor, true)
    end
  end
  local tEvent = {EventType = "TimerEvent", Time = nTimer}
  self:RegisterEvent(Util.CreateEvent(tEvent, "Act_3_Mission_5.StartDoorSequence", self, {tsPath, nTimer}))
end

function Act_3_Mission_5:ConversationPlayer(sConvoName)
  Cin.PlayConversation(sConvoName)
end

function Act_3_Mission_5:KesslerMoveTo1()
  print("KesslerMoveTo1!")
  self.ConversationPlayer(self, "A3M5_ControlRoomGoTo_Start")
  self.ConversationPlayer(self, "A3M5_GondolaBay_NearAccess")
  local hKessler = Handle("Missions\\act_3\\mission_5\\starter\\A3M5_Kessler")
  local hLoc = Handle("Missions\\act_3\\mission_5\\enc1_activity\\LC_Kessler1")
  local x, y, z = Object.GetPosition(hKessler)
end

function Act_3_Mission_5:KesslerMoveTo2()
  print("KesslerMoveTo2!")
  local hKessler = Handle("Missions\\act_3\\mission_5\\starter\\A3M5_Kessler")
  local hLoc = Handle("Missions\\act_3\\mission_5\\enc1_activity\\LC_Kessler2")
end

function Act_3_Mission_5:KesslerMoveTo3()
  print("KesslerMoveTo3!")
  local hKessler = Handle("Missions\\act_3\\mif\tssion_5\\starter\\A3M5_Kessler")
  local hLoc = Handle("Missions\\act_3\\mission_5\\enc1_activity\\LC_Kessler3")
end

function Act_3_Mission_5:KesslerMoveTo4()
  print("KesslerMoveTo4!")
  local hKessler = Handle("Missions\\act_3\\mission_5\\starter\\A3M5_Kessler")
  local hLoc = Handle("Missions\\act_3\\mission_5\\enc1_activity\\LC_Kessler4")
end

function Act_3_Mission_5:KesslerMoveTo5()
  print("KesslerMoveTo5!")
  self.ConversationPlayer(self, "A3M5_ControlRoomGoTo_BigDoor")
  self.ConversationPlayer(self, "A3M5_ControlRoomGoTo_LockedDoor01")
  self.ConversationPlayer(self, "A3M5_ControlRoomGoTo_ClosingAccess4")
  local hKessler = Handle("Missions\\act_3\\mission_5\\starter\\A3M5_Kessler")
  local hLoc = Handle("Missions\\act_3\\mission_5\\enc1_activity\\LC_Kessler5")
end

function Act_3_Mission_5:KesslerMoveTo6()
  print("KesslerMoveTo6!")
  self.ConversationPlayer(self, "A3M5_ControlRoomGoTo_ClosingAccess")
  local hKessler = Handle("Missions\\act_3\\mission_5\\starter\\A3M5_Kessler")
  local hLoc = Handle("Missions\\act_3\\mission_5\\enc1_activity\\LC_Kessler6")
end

function Act_3_Mission_5:KesslerMoveTo7()
  print("KesslerMoveTo7!")
  local hKessler = Handle("Missions\\act_3\\mission_5\\starter\\A3M5_Kessler")
  local hLoc = Handle("Missions\\act_3\\mission_5\\enc1_activity\\LC_Kessler7")
end

function Act_3_Mission_5:KesslerMoveTo8()
  print("KesslerMoveTo8!")
  self.ConversationPlayer(self, "A3M5_ControlRoomGoTo_NearControlRoom")
  local hKessler = Handle("Missions\\act_3\\mission_5\\starter\\A3M5_Kessler")
  local hLoc = Handle("Missions\\act_3\\mission_5\\enc1_activity\\LC_Kessler8")
end

function Act_3_Mission_5:KesslerMoveTo9()
  print("KesslerMoveTo9!")
  local hKessler = Handle("Missions\\act_3\\mission_5\\starter\\A3M5_Kessler")
  local hLoc = Handle("Missions\\act_3\\mission_5\\obj\\LC_OBJ13")
end

function Act_3_Mission_5:EnterSericeTunnel()
  print("EnterSericeTunnel!")
  self.ConversationPlayer(self, "A3M5_Caves_Pre")
end

function Act_3_Mission_5:ElevatorTop()
  print("ElevatorTop!")
  self.ConversationPlayer(self, "A3M5_CloseSilo_ShaftTop")
end

function Act_3_Mission_5:KesslerBreach2()
  print("KesslerBreach2!")
  self.ConversationPlayer(self, "A3M5_Breach_Warning02")
end

function Act_3_Mission_5:KesslerBreach3()
  print("KesslerBreach3!")
  self.ConversationPlayer(self, "A3M5_Breach_Warning03")
end

function Act_3_Mission_5:MoveAiUnit(uNazi, hLoc)
  print("Override combat and move AI!")
  print("uNazi = ")
  print(uNazi)
  Actor.OverrideCombatAI(uNazi, true)
  Nav.MoveToObject(uNazi, hLoc, 2, true, "Act_3_Mission_5.AnchorUnits", nil, {
    self,
    uNazi,
    hLoc
  })
end

function Act_3_Mission_5:AnchorUnits(uNazi, hLoc)
  print("AnchorUnits!")
  Combat.SetStationary(uNazi, true)
end

function Act_3_Mission_5:Task4Move()
  self:CreateTask({
    sName = "ActivateGondola",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    sObjectiveTextID = "A3M5_Text.Task_ActivateGondola",
    tTgtInclude = {
      "Missions\\act_3\\mission_5\\enc0_gondola\\Gondola_Lever"
    },
    tOnComplete = {
      {
        self.MoveGondola,
        {self}
      }
    }
  })
end

function Act_3_Mission_5:MoveGondola()
  Cin.PlayCinematic("CIN_A3M5_GondolaRide_02", false, "Act_3_Mission_5.KesslerFollow", self)
end

function Act_3_Mission_5:KesslerFollow()
  print("Act_3_Mission_5.KesslerFollow$$$$$$")
  local hKessler = Util.GetHandleByName("Missions\\act_3\\mission_5\\starter\\Gondola_Kessler")
  Object.Teleport(Handle("Missions\\act_3\\mission_5\\starter\\Gondola_Kessler"), 3464.7002, 262.7597, -3009.0737, 85.46474)
  Squad.AddMember("Saboteur", hKessler)
  Squad.SetLeader("Saboteur", hSab)
  Squad.SetRadius("Saboteur", 0.2)
  Squad.FollowLeader("Saboteur")
  self.Task_GondolaDoor(self)
end
