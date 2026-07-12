if NOTE_307 == nil then
  NOTE_307 = SabTaskObjective:Create()
  NOTE_307:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tDependencyList = {
      "Connect_ST_302_ParisReturnVittore",
      "P2FP_RadioRescue"
    },
    tUnlockList = {},
    tSMEDNodes = {}
  })
end

function NOTE_307:STARTER_Setup()
end

function NOTE_307:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_307:GENERAL_Setup()
  EVENT_Timer("NOTE_307.Task_Message", self, 5)
end

function NOTE_307:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Note_Luc1_preHanging_307.Note_Luc1_preHanging_307_NOTE",
    ConvName = "Note_Luc1_preHanging_307",
    MsgType = cMESSAGETYPE_LUC,
    sBlockingSpore = "Missions\\paris_2\\characters\\luc_exterior",
    Priority = cMESSAGEPRIORITY_MEDIUM,
    tOnActivate = {},
    tOnComplete = {
      {
        self.Task_Complete,
        {self}
      }
    }
  })
end

function NOTE_307:Task_Complete()
end
