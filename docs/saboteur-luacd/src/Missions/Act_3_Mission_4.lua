if Act_3_Mission_4 == nil then
  Act_3_Mission_4 = SabTaskObjective:Create()
  gsSMEDNodeDir = "Missions\\act_3\\mission_4\\"
  Act_3_Mission_4.PREFIX = "Act_3_Mission_4"
  Act_3_Mission_4.PATH = "Missions\\act_3\\mission_4\\"
  Act_3_Mission_4:Configure({
    TaskCount = 5,
    bStarterless = true,
    tUnlockList = {},
    tSMEDNodes = {
      gsSMEDNodeDir .. "main"
    }
  })
end

function Act_3_Mission_4:STARTER_Setup()
end

function Act_3_Mission_4:Activated()
  SabTaskObjective.Activated(self)
  self.bDebugMode = true
  self.sDebugLabel = "PAIN.TRAIN"
  self.GENERAL_Setup(self)
  Train.TrainRegisterEngineCallback(self.sMainTrain, self.PREFIX .. ".OnEngineCreated", self)
  Train.TrainCreate(self.sMainTrain, "Act3_M4_MainTrain")
  Train.TrainStop(self.sMainTrain)
  Train.TrainRegisterEngineCallback(self.sSeanTrain, self.PREFIX .. ".OnEngineCreated", self)
  Train.TrainCreate(self.sSeanTrain, "Act3_M4_SeanTrain")
  Train.TrainStop(self.sSeanTrain)
end

function Act_3_Mission_4:GENERAL_Setup()
  self.sMainTrain = self.PATH .. "train\\Rail_MainTrain"
  self.sSeanTrain = self.PATH .. "train\\Rail_SeanTrain"
  self.nSeanTrainStartDelay = 1
  self.nSeanTrainStartSpeed = 14
  self.nMainTrainStartDelay = 1
  self.nMainTrainStartSpeed = 12
  self.sWTFZoneName = "WtF_Zones\\act3\\mission_4\\ZT_Act3_Mission4"
  local tEvent = {
    EventType = "OnTriggerEnter",
    Target = Handle(self.PATH .. "main\\PT_Trigger_MissionFailed")
  }
  Util.CreateEvent(tEvent, "Act_3_Mission_4.OnFailure", self)
  Trigger.WaitFor(self.PATH .. "main\\PT_TriggerWillToFight", Util.GetHandleByName("Saboteur"), "Act_3_Mission_4.ChangeWTF", self, {1})
end

function Act_3_Mission_4:OnEngineCreated(a_tData)
  Tips.Print(self, "OnEngineCreated() a_tData: " .. a_tData[1])
  if a_tData[1] == self.sSeanTrain then
    self.hSeanTrainEngine = a_tData[2]
    self:OnTrainReady()
  elseif a_tData[1] == self.sMainTrain then
    self.hMainTrainEngine = a_tData[2]
    self:OnTrainReady()
  end
end

function Act_3_Mission_4:OnTrainReady()
  if not self.bBothTrainsReady then
    if not self.bOneTrainReady then
      Tips.Print(self, "One train ready to roll...")
      self.bOneTrainReady = true
    else
      Tips.Print(self, "Both trains now ready to roll...")
      self:OnBothTrainsReady()
      self.bBothTrainsReady = true
    end
  end
end

function Act_3_Mission_4:OnBothTrainsReady()
  Tips.Print(self, "OnBothTrainsReady()")
  Tips.Print(self, self.PATH .. "main\\PT_BoardTrigger")
  local tEvent = {
    EventType = "OnTriggerEnter",
    Target = Handle(self.PATH .. "main\\PT_BoardTrigger")
  }
  Util.CreateEvent(tEvent, "Act_3_Mission_4.StartTrains", self)
  self:TASK_GetOnTheTrain()
end

function Act_3_Mission_4:StartTrains()
  Tips.Print(self, "StartTrains()")
  self.SebTrainSetup(self)
  local tSeanTrainEvent = {
    EventType = "TimerEvent",
    Time = self.nSeanTrainStartDelay
  }
  Util.CreateEvent(tSeanTrainEvent, "Act_3_Mission_4.OnStartDelayFinished", self, {
    self.hSeanTrainEngine
  })
  local tMainTrainEvent = {
    EventType = "TimerEvent",
    Time = self.nMainTrainStartDelay
  }
  Util.CreateEvent(tMainTrainEvent, "Act_3_Mission_4.OnStartDelayFinished", self, {
    self.hMainTrainEngine
  })
end

function Act_3_Mission_4:OnStartDelayFinished(a_hTrain)
  if a_hTrain == self.hSeanTrainEngine then
    Tips.Print(self, "SeanTrain speed now set to " .. self.nSeanTrainStartSpeed)
    Train.TrainStart(self.sSeanTrain)
    Train.TrainSetMaxSpeed(self.sSeanTrain, self.nSeanTrainStartSpeed)
  elseif a_hTrain == self.hMainTrainEngine then
    Tips.Print(self, "MainTrain speed now set to " .. self.nMainTrainStartSpeed)
    Train.TrainStart(self.sMainTrain)
    Train.TrainSetMaxSpeed(self.sMainTrain, self.nMainTrainStartSpeed)
  end
end

function Act_3_Mission_4:SetSeanTrainSpeed(a_sTrigger, a_nSpeed)
  Tips.Print(self, "Queuing SeanTrain speed to " .. a_nSpeed .. " when following trigger is tripped: " .. a_sTrigger)
  Trigger.WaitFor(a_sTrigger, self.hSeanTrainEngine, "Act_3_Mission_4._SetSeanTrainSpeed", self, {a_nSpeed}, cTRIGGEREVENT_ONENTER)
end

function Act_3_Mission_4:_SetSeanTrainSpeed(a_tTriggerData, a_nSpeed)
  Tips.Print(self, "Now setting SeanTrain speed to " .. a_nSpeed)
  Train.TrainSetMaxSpeed(self.sSeanTrain, a_nSpeed)
end

function Act_3_Mission_4:SetMainTrainSpeed(a_sTrigger, a_nSpeed)
  Tips.Print(self, "Queuing MainTrain speed to " .. a_nSpeed .. " when following trigger is tripped: " .. a_sTrigger)
  Trigger.WaitFor(a_sTrigger, self.hMainTrainEngine, "Act_3_Mission_4._SetMainTrainSpeed", self, {a_nSpeed}, cTRIGGEREVENT_ONENTER)
end

function Act_3_Mission_4:_SetMainTrainSpeed(a_tTriggerData, a_nSpeed)
  Tips.Print(self, "Now setting MainTrain speed to " .. a_nSpeed)
  Train.TrainSetMaxSpeed(self.sMainTrain, a_nSpeed)
end

function Act_3_Mission_4:TriggerWTF()
  if self.sWTFZoneName ~= nil then
    Zone.SwitchState(self.sWTFZoneName, cZONESTATE_HIGHWTF, cENT_IMMEDIATE)
  end
end

function Act_3_Mission_4:ChangeWTF()
  Tips.Print(self, "Changing WTF zone")
  Zone.SwitchState("WtF_Zones\\act3\\mission_4\\ZT_Act3_Mission4", cZONESTATE_HIGHWTF, cENT_IMMEDIATE)
end

function Act_3_Mission_4:TASK_DecouplePassengerCar()
  local hSabPoint1 = AttractionPt.FindPtInObject(self.hMainTrainEngine, "DoorTriggerPoint")
  self:CreateTask({
    sName = "Act_3_Mission_4.TASK_DecouplePassengerCar",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    sTaskStartConv = "A3M4_MONO_Liberate",
    sUpdateTextID = "Decouple passenger car",
    sObjectiveTextID = "Decouple passenger car",
    tTgtInclude = {hSabPoint1},
    tOnComplete = {
      {
        self.TASK_DestroyDoors,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Act_3_Mission_4:TASK_SabotageEngineFake()
  local hSabPoint = AttractionPt.FindPtInObject(self.hMainTrainEngine, "UsePt")
  self:CreateTask({
    sName = "Act_3_Mission_4.TASK_SabotageEngineFake",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    sTaskStartConv = "A3M4_MONO_SabEng",
    sUpdateTextID = "Sabotage the engine",
    sObjectiveTextID = "Sabotage the engine",
    tTgtInclude = {hSabPoint},
    tOnComplete = {
      {
        self.TASK_DestroyDoors,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Act_3_Mission_4:TASK_SabotageEngine()
  local hSabPoint = AttractionPt.FindPtInObject(self.hMainTrainEngine, "SabotagePt_Dynamite01")
  self:CreateTask({
    sName = "Act_3_Mission_4.TASK_SabotageEngine",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "Sabotage",
    sTaskStartConv = "A3M4_MONO_SabEng",
    tTgtInclude = {hSabPoint},
    sObjectiveTextID = "Sabotage the engine",
    sUpdateTextID = "Sabotage the engine",
    tOnActivate = {},
    tOnComplete = {
      {
        self.TASK_DestroyDoors,
        {self}
      }
    }
  })
end

function Act_3_Mission_4:TASK_JumpOnTrain()
  self:CreateTask({
    sName = "Act_3_Mission_4.TASK_JumpOnTrain",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sTaskStartConv = "A3M4_MONO_Start",
    tDestRegion = {
      self.PATH .. "main\\PT_TriggerWillToFight"
    },
    tLocators = {
      self.PATH .. "main\\LOC_OnMainTrain"
    },
    tDeliverObjs = {hSab},
    sObjectiveTextID = "Jump on the Nazi train",
    sUpdateTextID = "Jump on the Nazi train",
    tOnActivate = {},
    tOnComplete = {
      {
        self.TASK_ReachEngine,
        {self}
      }
    }
  })
end

function Act_3_Mission_4:TASK_GetCloserToTrain()
  self:CreateTask({
    sName = "Act_3_Mission_4.TASK_GetCloserToTrain",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "deliver",
    sTaskStartConv = "A3M4_MONO_CatchUp",
    tDestRegion = {
      self.PATH .. "main\\PT_CloserToTrain"
    },
    tLocators = {
      self.PATH .. "main\\LOC_CloseToTrain"
    },
    tDeliverObjs = {
      hSab,
      self.hSeanTrainEngine
    },
    sObjectiveTextID = "Get closer to Nazi train",
    sUpdateTextID = "Fight nazis while you get closer to their train",
    tOnActivate = {},
    tOnComplete = {
      {
        self.TASK_JumpOnTrain,
        {self}
      }
    }
  })
end

function Act_3_Mission_4:TASK_GetOnTheTrain()
  self:CreateTask({
    sName = "Act_3_Mission_4.TASK_GetOnTheTrain",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sTaskStartConv = "A3M4_MONO_Jump",
    tDestRegion = {
      self.PATH .. "main\\PT_BoardTrigger"
    },
    tLocators = {
      self.PATH .. "main\\LOC_OnTrain"
    },
    tDeliverObjs = {hSab},
    sObjectiveTextID = "Get on the train",
    sUpdateTextID = "Get on the train",
    tOnActivate = {},
    tOnComplete = {
      {
        self.TASK_GetCloserToTrain,
        {self}
      }
    }
  })
end

function Act_3_Mission_4:TASK_DestroyDoors()
  self:CreateTask({
    sName = "Ac3_4_Mission_4_TASK_DestroyDoors",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sTaskStartConv = "A3M4_MONO_BlowDoors",
    tDestRegion = {
      self.PATH .. "main\\PT_Trigger_MissionCompleted"
    },
    tLocators = {
      self.PATH .. "main\\LOC_End"
    },
    tDeliverObjs = {
      hSab,
      self.hMainTrainEngine
    },
    sObjectiveTextID = "Crash the train into the doors",
    sUpdateTextID = "Crash the train into the doors",
    tOnActivate = {},
    tOnComplete = {}
  })
end

function Act_3_Mission_4:TASK_ReachEngine()
  self:CreateTask({
    sName = "Ac3_4_Mission_4_TASK_ReachEngine",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "DELIVER",
    sTaskStartConv = "A3M4_MONO_GetToEngine",
    Proximity = 15,
    tDestProximityObj = {
      self.hMainTrainEngine
    },
    tDeliverObjs = {hSab},
    sObjectiveTextID = "Reach the engine car",
    sUpdateTextID = "Reach the engine car",
    tOnActivate = {},
    tOnComplete = {
      {
        self.TASK_DestroyDoors,
        {self}
      }
    }
  })
end

function Act_3_Mission_4:OnFailure()
  self:CancelThisMission()
end

function Act_3_Mission_4:SebTrainSetup()
  Tips.Print(self, "SebTrainSetup()")
  self.SetSeanTrainSpeed(self, "Missions\\act_3\\mission_4\\mission_stuff\\PT_SeanTrain_CloserMainT01", 19)
  self.SetMainTrainSpeed(self, self.PATH .. "mission_stuff\\PT_MainTrain_CloserMainT01", 18)
  self.SetSeanTrainSpeed(self, "Missions\\act_3\\mission_4\\mission_stuff\\PT_SeanTrain_RegSp01", 20)
  self.SetMainTrainSpeed(self, self.PATH .. "mission_stuff\\PT_SeanTrain_RegSp01", 20)
  self.SetSeanTrainSpeed(self, "Missions\\act_3\\mission_4\\mission_stuff\\PT_SeanTrain_AccSp01", 21)
  self.SetMainTrainSpeed(self, self.PATH .. "mission_stuff\\PT_MainTrain_AccSp01", 21)
  self.SetMainTrainSpeed(self, self.PATH .. "mission_stuff\\PT_MainTrain_DecrSp01", 15)
  self.SetMainTrainSpeed(self, self.PATH .. "mission_stuff\\PT_MainTrain_AccSp03", 12)
  self.SetMainTrainSpeed(self, self.PATH .. "mission_stuff\\PT_MainTrain_AccSp04", 10)
end
