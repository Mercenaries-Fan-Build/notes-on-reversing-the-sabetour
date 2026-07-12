if MISSION_MMarzola == nil then
  MISSION_MMarzola = SabTaskObjective:Create()
  MISSION_MMarzola:Configure({
    TaskCount = "auto",
    sAreaID = "MISSION_MMarzola_Area_1",
    WTFValue = 0,
    sStarter = "Starters\\STARTER_MMarzola",
    tDependencyList = {},
    tUnlockList = {
      "MISSION_SGillies"
    },
    tSMEDNodes = {
      "MISSION_CFrench"
    }
  })
end

function MISSION_MMarzola:Activated()
  SabTaskObjective.Activated(self)
  MISSION_MMarzola.InitTask1(self)
end

function MISSION_MMarzola:InitTask1()
  local o = self:CreateTask({
    sName = "MISSION_CFrench_Task_Kill_Nazi",
    sTaskType = "SabTaskObjectiveDestroy",
    sPartialCompleteMsg = "Nazis Killed",
    tTgtInclude = {
      "MISSION_CFrench\\Freedom_Nazi1",
      "MISSION_CFrench\\Freedom_Nazi2",
      "MISSION_CFrench\\Freedom_Nazi3",
      "MISSION_CFrench\\Freedom_Nazi4"
    },
    tOnComplete = {},
    tOnCancel = {},
    tOnActivate = {
      Render.PrintMessage("MarzMission Next mission. same thing har har har!")
    }
  })
end

function MISSION_MMarzola:CompleteThis()
  print("complete test task")
  local tConfig = self:GetConfig()
  for i, v in pairs(tConfig.tTgtInclude) do
    Object.Kill(Util.GetHandleByName(v))
  end
end
