if NOTE_P3_Papers == nil then
  NOTE_P3_Papers = SabTaskObjective:Create()
  NOTE_P3_Papers:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tDisabledMissionsList = {
      "Connect_ST_316_VeroDistrustsSkylar"
    },
    tUnlockList = {},
    tSMEDNodes = {}
  })
end

function NOTE_P3_Papers:STARTER_Setup()
end

function NOTE_P3_Papers:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function NOTE_P3_Papers:GENERAL_Setup()
  EVENT_Timer("NOTE_P3_Papers.Task_Message", self, 5)
end

function NOTE_P3_Papers:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Note_Santos2_HeresP3Papers.Note_Santos2_HeresP3Papers_NOTE",
    ConvName = "Note_Santos2_HeresP3Papers",
    MsgType = cMESSAGETYPE_SANTOS,
    sBlockingSpore = "Missions\\paris_1\\characters\\belle\\santos_hideout",
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

function NOTE_P3_Papers:Task_Complete()
end
