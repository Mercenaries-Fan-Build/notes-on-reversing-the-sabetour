if Connect_P3PapersIntro == nil then
  Connect_P3PapersIntro = SabTaskObjective:Create()
  Connect_P3PapersIntro:Configure({
    TaskCount = 999,
    sStarter = "santos_ext_hideout",
    sSaveMissionNameID = "MissionNames_Text.Connect_P3Papers",
    bDisableMissionTitle = true,
    MCDisplayID = 2,
    tUnlockList = {
      "Connect_P3Papers"
    },
    tSMEDNodes = {}
  })
end

function Connect_P3PapersIntro:STARTER_Setup()
end

function Connect_P3PapersIntro:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.Task_FirstObjective(self)
end

function Connect_P3PapersIntro:GENERAL_Setup()
end

function Connect_P3PapersIntro:Task_FirstObjective()
  self:CreateTask({
    sName = "Connect_P3PapersIntro_Task_FirstObjective",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sConvFile = "P1FP_OnTheAir_Start",
    bAutoFire = true,
    Proximity = 3,
    tTgtInclude = {
      self:GetStarter()
    },
    tOnActivate = {},
    tOnComplete = {
      {
        Saboteur.ShowToolTip,
        {
          "Connect_P3PapersIntro_Dialog.TIP_GetContraband"
        }
      },
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end
