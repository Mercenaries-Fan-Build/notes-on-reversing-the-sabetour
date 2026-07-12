if Connect_PaySantos == nil then
  Connect_PaySantos = SabTaskObjective:Create()
  Connect_PaySantos:Configure({
    TaskCount = 999,
    sStarter = "santos_ext_hideout",
    MCDisplayID = 2,
    tUnlockList = {
      "P1FP_Carbomb"
    },
    bEscalationDenial = true,
    tSMEDNodes = {}
  })
end

function Connect_PaySantos:STARTER_Setup()
end

function Connect_PaySantos:Activated()
  self.sDebugLabel = "CONNECT_PAYSANTOS"
  self.bDebugMode = false
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.TestContraband(self)
end

function Connect_PaySantos:GENERAL_Setup()
  self:AddOnCompleteCallback(Connect_PaySantos.MissionComplete)
end

function Connect_PaySantos:TestContraband()
  local nContraband = Inventory.GetMoney()
  if nContraband < 300 then
    self:Task_NoMoney()
    dprint(self, ">>>>>> Sorry:  Player has less than 1000 Contraband.  Contraband = " .. nContraband)
  elseif 300 <= nContraband then
    self:Task_HasMoney()
    dprint(self, ">>>>>> WOOHOOO!!! Player has more than 1000 Contraband - Open Shops!!!")
  else
    dprint(self, "ERROR: Contraband is " .. nContraband)
  end
end

function Connect_PaySantos:Task_NoMoney()
  self:CreateTask({
    sName = "Connect_PaySantos_Task_NoMoney",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sConvFile = "Connect_PaySantos_NoMoney",
    bAutoFire = true,
    Proximity = 3,
    tTgtInclude = {
      self:GetStarter()
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.CancelThisMission,
        {self, true}
      }
    }
  })
end

function Connect_PaySantos:Task_HasMoney()
  self:CreateTask({
    sName = "Connect_PaySantos_Task_HasMoney",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sConvFile = "Connect_PaySantos_HasMoney",
    bAutoFire = true,
    Proximity = 3,
    tTgtInclude = {
      self:GetStarter()
    },
    tOnActivate = {},
    tOnComplete = {
      {
        Inventory.GiveMoney,
        {-300}
      },
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end

function Connect_PaySantos:MissionComplete()
  EVENT_Timer("Connect_PaySantos.PlayWeaponTip", self, 10)
end

function Connect_PaySantos:PlayWeaponTip()
  Saboteur.ShowToolTip("TutorialTip_Text.Weapon_Switch")
end
