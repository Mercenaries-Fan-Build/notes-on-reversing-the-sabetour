if Connect_ST_212_ResistanceBackup == nil then
  Connect_ST_212_ResistanceBackup = SabTaskObjective:Create()
  Connect_ST_212_ResistanceBackup:Configure({
    TaskCount = 999,
    sStarter = "Luc_LaVillette_Interior",
    MCDisplayID = 2,
    sSaveMissionNameID = "MissionNames_Text.P1FP_JailBreak",
    bDisableMissionTitle = true,
    tUnlockList = {
      "P1FP_MadBomber01",
      "NOTE_FatherDenis",
      "P1FP_Entourage",
      "P1FP_EustacheSniper"
    },
    tSMEDNodes = {}
  })
end

function Connect_ST_212_ResistanceBackup:STARTER_Setup()
  Cin.PlayConversation("ST_212_OMW")
end

function Connect_ST_212_ResistanceBackup:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Connect_ST_212_ResistanceBackup:GENERAL_Setup()
  self:RegisterCheckpoint("Connect_ST_212_ResistanceBackup.Checkpoint1")
end

function Connect_ST_212_ResistanceBackup:Checkpoint1()
  if not self:IsMissionTaskActive("Task_FirstObjective") then
    self:Task_FirstObjective()
  end
end

function Connect_ST_212_ResistanceBackup:Task_FirstObjective()
  self:CreateTask({
    sName = "Connect_ST_212_ResistanceBackup_Task_FirstObjective",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    bCompleteOnActivate = true,
    tOnActivate = {
      {
        self.Task_Convo,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Connect_ST_212_ResistanceBackup:Task_Convo()
  print("$$$$$$$$$$$$$$$$$$$$$Connect_ST_212_ResistanceBackup.Task_Convo")
  self:CreateTask({
    sName = "Connect_ST_212_ResistanceBackup.Task_Convo",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sConvFile = "212_Con_BackupDone",
    tTgtInclude = {
      "Missions\\paris_1\\characters\\lavillette\\luc_interior\\Luc_LaVillette_Interior"
    },
    bAutofire = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    },
    tOnConversationComplete = {
      {
        self.ShowTutorial,
        {self}
      }
    }
  })
end

function Connect_ST_212_ResistanceBackup:Task_ShowCinematic()
  self:CreateTask({
    sName = "Connect_ST_212_ResistanceBackup_Task_ShowCinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "Sab_Placeholder",
    tOnActivate = {},
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end

function Connect_ST_212_ResistanceBackup:ShowTutorial()
  Saboteur.ShowToolTip("TutorialTip_Text.Strike_Backup")
end
