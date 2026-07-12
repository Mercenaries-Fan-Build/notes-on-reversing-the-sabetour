if Connect_P3Papers == nil then
  Connect_P3Papers = SabTaskObjective:Create()
  Connect_P3Papers:Configure({
    TaskCount = 999,
    sStarter = "santos_ext_hideout",
    sSaveMissionNameID = "MissionNames_Text.Connect_P3Papers",
    bDisableMissionTitle = true,
    MCDisplayID = 2,
    tUnlockList = {
      "P3FP_Jardin"
    },
    tSMEDNodes = {}
  })
end

function Connect_P3Papers:STARTER_Setup()
end

function Connect_P3Papers:Activated()
  self.sDebugLabel = "CONNECT_P3PAPERS"
  self.bDebugMode = false
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Connect_P3Papers:GENERAL_Setup()
  self:TestContraband()
end

function Connect_P3Papers:TestContraband()
  local nContraband = Inventory.GetMoney()
  if nContraband < 500 then
    self:Task_NoMoney()
    dprint(self, ">>>>>> Sorry:  Player has less than 1000 Contraband")
  elseif 500 <= nContraband then
    self:Task_HasMoney()
    dprint(self, ">>>>>> WOOHOOO!!! Player has more than 1000 Contraband")
  else
    dprint(self, "ERROR: Contraband is " .. nContraband)
  end
end

function Connect_P3Papers:Task_NoMoney()
  self:CreateTask({
    sName = "Connect_P3Papers_Task_NoMoney",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sConvFile = "Connect_P3Papers_NoMoney",
    bAutoFire = true,
    Proximity = 3,
    tTgtInclude = {
      self:GetStarter()
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.CancelThisMission,
        {self}
      }
    }
  })
end

function Connect_P3Papers:Task_HasMoney()
  self:CreateTask({
    sName = "Connect_P3Papers_Task_HasMoney",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sConvFile = "Connect_P3Papers_HasMoney",
    bAutoFire = true,
    Proximity = 3,
    tTgtInclude = {
      self:GetStarter()
    },
    tOnActivate = {
      {
        Inventory.GiveMoney,
        {-500}
      },
      {
        Inventory.GiveItem,
        {
          hSab,
          "Papers_P2",
          false
        }
      }
    },
    tOnComplete = {
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end
