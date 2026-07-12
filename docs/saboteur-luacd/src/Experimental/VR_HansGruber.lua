if VR_HansGruber == nil then
  VR_HansGruber = SabTaskObjective:Create()
  self:Configure({
    TaskCount = 1,
    sAreaID = "SOE_1",
    WTFValue = 0,
    sStarter = "Garden\\Starter",
    tDependencyList = {}
  })
end

function VR_HansGruber:Activated()
  SabTaskObjective.Activated(self)
  VR_HansGruber.Task_KillHans(self)
end

function VR_HansGruber:Task_KillHans()
  self:CreateTask({
    sName = "Kill Hans!",
    sTaskType = "SabTaskObjectiveDestroy",
    vTgtInclude = {
      "Garden\\MissionTarget"
    },
    tOnComplete = {},
    tOnCancel = {},
    tOnActivate = {
      Render.PrintMessage("Objective: Kill Hans")
    }
  })
end
