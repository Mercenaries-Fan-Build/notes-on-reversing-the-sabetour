if MISSION_SGillies == nil then
  MISSION_SGillies = SabTaskObjective:Create()
  MISSION_SGillies:Configure({
    TaskCount = "auto",
    sAreaID = "MISSION_SGilles_Area_1",
    WTFValue = 0,
    sStarter = "Starters\\STARTER_SGillies",
    tDependencyList = {},
    tUnlockList = {
      "MISSION_CFrench",
      "MISSION_DSimmons"
    },
    sArcID = "MISSION_CFrench",
    tSMEDNodes = {
      "MISSION_SGillies"
    }
  })
end

function MISSION_SGillies:Activated()
  SabTaskObjective.Activated(self)
  MISSION_SGillies.InitTask1(self)
end

function MISSION_SGillies:InitTask1()
  local o = self:CreateTask({
    sName = "MISSION_SGillies_Task_Kill_Nazi",
    sTaskType = "SabTaskObjectiveDestroy",
    sPartialCompleteMsg = "Nazis Killed",
    sTaskSubType = "Kill",
    tTgtInclude = {
      "MISSION_SGillies\\SGNazi1",
      "MISSION_SGillies\\SGNazi2"
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

function MISSION_SGillies:CompleteThis()
  print("complete test task")
  local tConfig = self:GetConfig()
  for i, v in pairs(tConfig.tTgtInclude) do
    Object.Kill(Util.GetHandleByName(v))
  end
end
