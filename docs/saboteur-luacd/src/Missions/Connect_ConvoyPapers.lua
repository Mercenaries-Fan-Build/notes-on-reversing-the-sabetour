if Connect_ConvoyPapers == nil then
  Connect_ConvoyPapers = SabTaskObjective:Create()
  Connect_ConvoyPapers:Configure({
    TaskCount = 999,
    sStarter = "santos_ext_hideout",
    MCDisplayID = 2,
    sSaveMissionNameID = "MissionNames_Text.Connect_P2Papers",
    bDisableMissionTitle = true,
    tUnlockList = {
      "Connect_P2Papers"
    },
    tSMEDNodes = {}
  })
end

function Connect_ConvoyPapers:STARTER_Setup()
end

function Connect_ConvoyPapers:Activated()
  self.sDebugLabel = "Connect_ConvoyPapers"
  self.bDebugMode = false
  SabTaskObjective.Activated(self)
  self.Task_FirstObjective(self)
end

function Connect_ConvoyPapers:GENERAL_Setup()
end

function Connect_ConvoyPapers:Task_FirstObjective()
  self:CreateTask({
    sName = "Connect_ConvoyPapers_Task_FirstObjective",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sConvFile = "303_Con_GetPapers_Return",
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
          "Connect_P2Papers_Text.TIP_GetContraband"
        }
      },
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end
