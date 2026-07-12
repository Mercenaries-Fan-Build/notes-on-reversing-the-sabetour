if MISSION_DSimmons == nil then
  MISSION_DSimmons = SabTaskObjective:Create()
  MISSION_DSimmons:Configure({
    TaskCount = "auto",
    sAreaID = "MISSION_DSimmons_Area_1",
    WTFValue = 0,
    sStarterNode = "STARTER_MISSION_CFrench",
    sStarter = "STARTER_MISSION_CFrench\\STARTER_CFrench",
    tDependencyList = {},
    tUnlockList = {},
    sArcID = "MISSION_CFrench",
    bArcFinale = true,
    tSMEDNodes = {
      "MISSION_DSimmons"
    }
  })
end

function MISSION_DSimmons:Activated()
  SabTaskObjective.Activated(self)
  MISSION_DSimmons.InitTask1(self)
end

function MISSION_DSimmons:InitTask1()
  local o = self:CreateTask({
    sName = "MISSION_DSimmons_Task_Kill_Nazi",
    sTaskType = "SabTaskObjectiveDestroy",
    sPartialCompleteMsg = "Nazis Killed",
    sTaskSubType = "Kill",
    tTgtInclude = {
      "MISSION_DSimmons\\Dummy1",
      "MISSION_DSimmons\\Dummy2"
    },
    tOnComplete = {
      {
        DisplayHUDText,
        {
          "Kill Complete"
        }
      }
    },
    tOnCancel = {},
    tOnActivate = {
      {
        DisplayHUDText,
        {
          "Kill 2 dummies"
        }
      }
    }
  })
end

function MISSION_DSimmons:CompleteThis()
  print("complete test task")
  local tConfig = self:GetConfig()
  for i, v in pairs(tConfig.tTgtInclude) do
    Object.Kill(Util.GetHandleByName(v))
  end
end
