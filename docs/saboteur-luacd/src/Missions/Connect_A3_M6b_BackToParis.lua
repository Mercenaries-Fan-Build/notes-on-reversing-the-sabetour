if Connect_A3_M6b_BackToParis == nil then
  Connect_A3_M6b_BackToParis = SabTaskObjective:Create()
  Connect_A3_M6b_BackToParis:Configure({
    TaskCount = 9999,
    sSaveMissionNameID = "MissionNames_Text.A3M3",
    bDisableMissionTitle = true,
    sHQNextMissionStartPoint = _cHQe_AIRSTRIP,
    MCDisplayID = 2,
    tUnlockList = {
      "Act_3_Mission_2"
    },
    bStarterless = true,
    bSLOverrideFade = true,
    tSMEDNodes = {
      "Missions\\act_3\\connect_a3_m6b_backtoparis"
    }
  })
end

function Connect_A3_M6b_BackToParis:STARTER_Setup()
end

function Connect_A3_M6b_BackToParis:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.Task_FirstObjective(self)
end

function Connect_A3_M6b_BackToParis:GENERAL_Setup()
  print("**************GENERAL SETUP")
end

function Connect_A3_M6b_BackToParis:Task_FirstObjective()
  print("Connect_A3_M6b_BackToParis.Task_FirstObjective!")
  self:CreateTask({
    sName = "Connect_A3_M6b_BackToParis_Task_FirstObjective",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    bCompleteOnActivate = true,
    tOnActivate = {
      {
        Render.WTFClearOverrideBlueprint,
        {}
      },
      {
        self.Task_ShowCinematic,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Connect_A3_M6b_BackToParis:Task_ShowCinematic()
  print("Connect_A3_M6b_BackToParis.Task_ShowCinematic!")
  self.bCinematicEnded = false
  self.bTeleportedEnded = false
  Cin.LoadCinematic("410_CinA_VallaBoom-FlightTime")
  self:CreateTask({
    sName = "Connect_A3_M6b_BackToParis_Task_ShowCinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "408_CinB_DoppBoom",
    bOverrideFade = true,
    tOnActivate = {
      {
        self.TeleportToParis,
        {self}
      }
    },
    tOnComplete = {
      {
        self.CinematicEnded,
        {self}
      }
    }
  })
end

function Connect_A3_M6b_BackToParis:CinematicEnded()
  self.bCinematicEnded = true
  self.BackToParisFlight(self)
end

function Connect_A3_M6b_BackToParis:TeleportedEnded()
  self.bTeleportedEnded = true
  if self.bCinematicEnded == true then
  end
end

function Connect_A3_M6b_BackToParis:TeleportToParis()
  print("Connect_A3_M6b_BackToParis.TeleportToParis!")
  Util.SetTime(21, 0)
  Object.PlayerTeleportToLocator(Util.GetHandleByName("Missions\\act_3\\connect_a3_m6b_backtoparis\\Connect_A3_M6b_BackToParis_Teleport"), false, "Connect_A3_M6b_BackToParis.TeleportedEnded", self)
end

function Connect_A3_M6b_BackToParis:BackToParisFlight()
  print("Connect_A3_M6b_BackToParis.Task_ShowCinematic!")
  self:CreateTask({
    sName = "Connect_A3_M6b_BackToParis_BackToParisFlight",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "410_CinA_VallaBoom-FlightTime",
    bOverrideFade = true,
    tOnActivate = {},
    tCinematicNodes = {
      "Missions\\cinematics\\410_flightback"
    },
    tOnComplete = {
      {
        self.CompleteConnect,
        {self}
      }
    }
  })
end

function Connect_A3_M6b_BackToParis:CompleteConnect()
  self:CompleteThisMission()
end
