if Act_3_Mission_3_ConnectB == nil then
  Act_3_Mission_3_ConnectB = SabTaskObjective:Create()
  Act_3_Mission_3_ConnectB:Configure({
    TaskCount = "auto",
    bStarterless = true,
    MCDisplayID = 2,
    tUnlockList = {
      "Act_3_Mission_2"
    },
    tSMEDNodes = {
      "Missions\\act_3\\mission_3\\connectB_CameraSweep"
    }
  })
end

function Act_3_Mission_3_ConnectB:STARTER_Setup()
end

function Act_3_Mission_3_ConnectB:Activated()
  SabTaskObjective.Activated(self)
  self.Checkpoint0(self)
end

function Act_3_Mission_3_ConnectB:Checkpoint0()
  self.RegisterCheckpoint(self, "Act_3_Mission_3_ConnectB.Checkpoint0Setup")
end

function Act_3_Mission_3_ConnectB:Checkpoint0Setup()
  self.GENERAL_Setup(self)
  Object.PlayerTeleportToPos(3231, 127, -3029, 77, "Act_3_Mission_3_ConnectB.Task_FirstObjective", self)
end

function Act_3_Mission_3_ConnectB:GENERAL_Setup()
end

function Act_3_Mission_3_ConnectB:Task_FirstObjective()
  Cin.PlayCinematic("408_CinB_DoppBoom", false, "Act_3_Mission_3_ConnectB.PlayCinematicGondola", self)
end

function Act_3_Mission_3_ConnectB:TeleportFirst()
  local hLoc = Handle("Missions\\act_3\\mission_3\\connectb_camerasweep\\A3M3_connectstart")
  Object.PlayerTeleportToLocator(hLoc, "Act_3_Mission_3_ConnectB.PlayCinematicGondola", self)
end

function Act_3_Mission_3_ConnectB:PlayCinematicGondola()
  Cin.PlayCinematic("A3M3b_LookatGondola", false, "Act_3_Mission_3_ConnectB.TeleportPlayer", self)
end

function Act_3_Mission_3_ConnectB:TeleportPlayer()
  Object.PlayerTeleportToPos(3426, 245, -3021, 90, "Act_3_Mission_3_ConnectB.MissionDone", self)
end

function Act_3_Mission_3_ConnectB:MissionDone()
  Object.PlayerTeleportToPos(3426, 245, -3021, 90)
  self:CompleteThisMission()
end
