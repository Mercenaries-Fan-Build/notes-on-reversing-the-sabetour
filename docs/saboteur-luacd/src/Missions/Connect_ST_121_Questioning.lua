if Connect_ST_121_Questioning == nil then
  Connect_ST_121_Questioning = SabTaskObjective:Create()
  Connect_ST_121_Questioning:Configure({
    TaskCount = "auto",
    MCDisplayID = 2,
    tUnlockList = {
      "Act_1_Factory"
    },
    bStarterless = true,
    bSLOverrideFade = true,
    tSMEDNodes = {
      "Missions\\act_1\\getcaught\\teleportcinematic"
    }
  })
end

function Connect_ST_121_Questioning:STARTER_Setup()
end

function Connect_ST_121_Questioning:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Connect_ST_121_Questioning:GENERAL_Setup()
  Render.SetGlobalWTF(false)
  self:RegisterCheckpoint("Connect_ST_121_Questioning.Checkpoint1")
end

function Connect_ST_121_Questioning:Checkpoint1()
  if not self:IsMissionTaskActive("Task_FirstObjective") then
    self:Task_FirstObjective()
  end
end

function Connect_ST_121_Questioning:Task_FirstObjective()
  self:CreateTask({
    sName = "Connect_ST_121_Questioning_Task_FirstObjective",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    bCompleteOnActivate = true,
    tOnActivate = {
      {
        self.Task_ShowCinematic,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Connect_ST_121_Questioning:Task_ShowCinematic()
  self:CreateTask({
    sName = "Connect_ST_121_Questioning_Task_ShowCinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "121_CinA_Question",
    bOverrideFade = true,
    tOnActivate = {
      {
        self.TeleportSean,
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

function Connect_ST_121_Questioning:TeleportSean()
  print("TeleportSean")
  Object.PlayerTeleportToLocator(Util.GetHandleByName("Missions\\act_1\\getcaught\\teleportcinematic\\FactoryTeleport"), false)
end
