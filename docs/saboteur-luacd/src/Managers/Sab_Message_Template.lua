if Sab_Message_Template == nil then
  Sab_Message_Template = SabTaskObjective:Create()
  Sab_Message_Template:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tUnlockList = {},
    tSMEDNodes = {}
  })
end

function Sab_Message_Template:STARTER_Setup()
end

function Sab_Message_Template:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.Task_Message(self)
end

function Sab_Message_Template:GENERAL_Setup()
end

function Sab_Message_Template:Task_Message()
  self:CreateTask({
    sName = "Task_Message",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CourierMessage",
    MessageID = "Meet me in my room",
    ConvName = "Note_Skylar1_215a",
    MsgType = cMESSAGETYPE_PAPER,
    Priority = cMESSAGEPRIORITY_MEDIUM,
    tOnActivate = {},
    tOnComplete = {}
  })
end
