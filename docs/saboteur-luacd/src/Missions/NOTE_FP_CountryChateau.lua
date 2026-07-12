if NOTE_FP_CountryChateau == nil then
  NOTE_FP_CountryChateau = SabTaskObjective:Create()
  NOTE_FP_CountryChateau:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tDependencyList = {
      "FP_AMB_ChemFactoryStart",
      "SOE_2_Mission_2_ConnectB"
    },
    tUnlockList = {},
    tSMEDNodes = {}
  })
end

function NOTE_FP_CountryChateau:STARTER_Setup()
end

function NOTE_FP_CountryChateau:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_FP_CountryChateau:GENERAL_Setup()
  if AmbientRubberStamp.CheckComplete("CB") then
    self:CompleteThisMission()
  else
    EVENT_Timer("NOTE_FP_CountryChateau.Task_Message", self, 5)
  end
end

function NOTE_FP_CountryChateau:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "NOTE_FP_CountryChateau.NOTE_FP_CountryChateau_NOTE",
    ConvName = "NOTE_FP_CountryChateau",
    MsgType = cMESSAGETYPE_SKYLAR,
    sBlockingSpore = "Missions\\paris_1\\characters\\lavillette\\Skylar_interior",
    Priority = cMESSAGEPRIORITY_LOW,
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Complete,
        {self}
      }
    }
  })
end

function NOTE_FP_CountryChateau:Task_Complete()
end
