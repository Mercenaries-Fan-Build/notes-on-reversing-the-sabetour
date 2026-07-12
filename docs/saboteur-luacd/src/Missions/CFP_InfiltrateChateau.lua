if CFP_InfiltrateChateau == nil then
  CFP_InfiltrateChateau = SabTaskObjective:Create()
  CFP_InfiltrateChateau.sPATH = "Missions\\freeplay\\country\\mis_infiltratechateau"
  CFP_InfiltrateChateau:Configure({
    TaskCount = 999,
    bFreeplay = true,
    sStarter = "wilcox_lehavre_interior",
    tUnlockList = {
      "CFP_DockDestroy"
    },
    tSMEDNodes = {}
  })
end

function CFP_InfiltrateChateau:STARTER_Setup()
end

function CFP_InfiltrateChateau:Activated()
  self.sDebugLabel = "INFILTRATECHATEAU"
  self.bDebugMode = false
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.TASK_FirstTask(self)
end

function CFP_InfiltrateChateau:GENERAL_Setup()
  self.hSab = Handle("Saboteur")
end

function CFP_InfiltrateChateau:TASK_MainTask()
  self:CreateTask({
    sName = "CFP_InfiltrateChateau_TASK_MainTask",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "NONE",
    sObjectiveTextID = "",
    tOnActivate = {
      {
        self.TASK_FirstTask,
        {self}
      }
    },
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end

function CFP_InfiltrateChateau:TASK_FirstTask()
  self:CreateTask({
    sName = "CFP_InfiltrateChateau_TASK_FirstTask",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "CINEMATIC",
    ParentObjectID = self:GetTaskObjectiveID("CFP_InfiltrateChateau_TASK_MainTask"),
    tOnActivate = {
      {
        Cin.PlayBinkMovie,
        {
          "Sab_Placeholder",
          false
        }
      }
    },
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end
