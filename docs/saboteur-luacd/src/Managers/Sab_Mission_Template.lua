if Sab_Mission_Template == nil then
  Sab_Mission_Template = SabTaskObjective:Create()
  Sab_Mission_Template:Configure({
    TaskCount = "auto",
    tUnlockList = {},
    tSMEDNodes = {}
  })
end

function Sab_Mission_Template:STARTER_Setup()
end

function Sab_Mission_Template:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.Task_FirstObjective(self)
end

function Sab_Mission_Template:GENERAL_Setup()
end

function Sab_Mission_Template:Task_FirstObjective()
  self:CreateTask({
    sName = "Sab_Mission_Template_Task_FirstObjective",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    tOnActivate = {
      {
        self.FirstObjectiveFunctionA,
        {self}
      }
    },
    tOnComplete = {
      {
        self.Task_SecondObjective,
        {self}
      }
    }
  })
end

function Sab_Mission_Template:FirstObjectiveFunctionA()
end

function Sab_Mission_Template:FirstObjectiveFunctionB()
end
