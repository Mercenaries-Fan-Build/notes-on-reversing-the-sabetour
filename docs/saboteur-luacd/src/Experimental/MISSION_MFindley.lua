if MISSION_MFindley == nil then
  MISSION_MFindley = SabTaskObjective:Create()
  MISSION_MFindley:Configure({
    TaskCount = "auto",
    sAreaID = "DesignTest_Area_1",
    WTFValue = 0,
    sStarter = "STARTER_MISSION_MFindley\\STARTER_MFindley",
    tDependencyList = {},
    tUnlockList = {},
    tSMEDNodes = {
      "MISSION_MFindley"
    }
  })
end

function MISSION_MFindley:Activated()
  SabTaskObjective.Activated(self)
  MISSION_MFindley.InitTask1(self)
end

function MISSION_MFindley:InitTask1()
  local o = self:CreateTask({
    sName = "MISSION_MFindley_Task_Kill_Nazi",
    sTaskType = "SabTaskObjectiveDestroy",
    sPartialCompleteMsg = "Nazis Killed",
    sTaskSubType = "Kill",
    tTgtInclude = {
      "MISSION_MFindley\\Dummy3",
      "MISSION_MFindley\\Dummy4"
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
