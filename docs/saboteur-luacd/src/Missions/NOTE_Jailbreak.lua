if NOTE_Jailbreak == nil then
  NOTE_Jailbreak = SabTaskObjective:Create()
  NOTE_Jailbreak:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tDependencyList = {
      "P1FP_Traitor",
      "P1FP_Carbomb"
    },
    tUnlockList = {},
    tSMEDNodes = {}
  })
end

function NOTE_Jailbreak:STARTER_Setup()
end

function NOTE_Jailbreak:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_Jailbreak:GENERAL_Setup()
  EVENT_Timer("NOTE_Jailbreak.Task_Message", self, 5)
end

function NOTE_Jailbreak:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    ConvName = "Note_Luc_General",
    MessageID = "Note_Luc_General.Note_Luc_General_NOTE",
    MsgType = cMESSAGETYPE_LUC,
    sBlockingSpore = "Missions\\paris_1\\characters\\lavillette\\Luc_interior",
    Priority = cMESSAGEPRIORITY_LOW,
    DelayTimer = 5,
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Complete,
        {self}
      }
    }
  })
end

function NOTE_Jailbreak:Task_Complete()
end
