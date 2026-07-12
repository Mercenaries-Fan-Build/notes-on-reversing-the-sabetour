if Connect_ST_325_Escape == nil then
  Connect_ST_325_Escape = SabTaskObjective:Create()
  Connect_ST_325_Escape:Configure({
    TaskCount = 99,
    MCDisplayID = 2,
    tUnlockList = {"P1M6b"},
    bStarterless = true,
    sHQStartPoint = _cHQe_LAVILLETTE,
    bSLOverrideFade = true,
    sSaveMissionNameID = "MissionNames_Text.P1M6",
    tCinematicNodes = {
      "325_cinb_escape"
    }
  })
end

function Connect_ST_325_Escape:STARTER_Setup()
end

function Connect_ST_325_Escape:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Connect_ST_325_Escape:GENERAL_Setup()
  local hLoc = Handle("Missions\\cinematics\\325_cinb_escape\\LOC_EndCinTeleport1(1)")
  if not hLoc then
    print("ERROR:: no loc to teleport us with")
  end
  Object.PlayerTeleportToLocator(hLoc, false, false, "Connect_ST_325_Escape.PreCin", self)
end

function Connect_ST_325_Escape:PreCin()
  self:RegisterCheckpoint("Connect_ST_325_Escape.Checkpoint1")
end

function Connect_ST_325_Escape:Checkpoint1()
  local hLuc = Handle("Missions\\cinematics\\325_cinb_escape\\Spore_RS_Luc")
  if hLuc then
    Inventory.RemoveAllWeapons(hLuc)
  end
  self:Task_EndCin()
end

function Connect_ST_325_Escape:Task_EndCin()
  self:CreateTask({
    sName = "Task_EndCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "325_CinB_Escape",
    bOverrideFade = true,
    tOnActivate = {},
    tOnComplete = {
      {
        Util.SetOverrideLoadScreenFadeIn,
        {false}
      },
      {
        self.FinishUpMission,
        {self}
      }
    }
  })
end

function Connect_ST_325_Escape:FinishUpMission()
  local hLoc = Handle("Missions\\cinematics\\325_cinb_escape\\LOC_EndCinTeleport1(1)")
  if not hLoc then
    print("ERROR:: no loc to teleport us with")
    return
  end
  Object.PlayerTeleportToLocator(hLoc, false, false, "Connect_ST_325_Escape.PostTele", self)
end

function Connect_ST_325_Escape:PostTele()
  self:CompleteThisMission()
end
