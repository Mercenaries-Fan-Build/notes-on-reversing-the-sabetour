if MISSION_ZRosencrantz == nil then
  MISSION_ZRosencrantz = SabTaskObjective:Create()
  MISSION_ZRosencrantz:Configure({
    TaskCount = 1,
    sAreaID = "MISSION_ZRosencrantz_Area_1",
    WTFValue = 0,
    sStarter = "Starters\\STARTER_ZRosencrantz",
    tDependencyList = {}
  })
end

function MISSION_ZRosencrantz:Activated()
  SabTaskObjective.Activated(self)
  MISSION_ZRosencrantz.InitTask1(self)
end

function MISSION_ZRosencrantz:InitTask1()
  self:CreateTask({
    sName = "MISSION_ZRosencrantz_Task1",
    sTaskType = "SabTaskObjectiveDestroy",
    sPartialCompleteMsg = "",
    vTgtInclude = {},
    tOnComplete = {},
    tOnCancel = {},
    tOnActivate = {}
  })
end
