if Connect_P2Papers == nil then
  Connect_P2Papers = SabTaskObjective:Create()
  Connect_P2Papers:Configure({
    TaskCount = 999,
    sStarter = "santos_ext_hideout",
    MCDisplayID = 2,
    tUnlockList = {
      "P2FP_RadioRescue"
    },
    sSaveMissionNameID = "MissionNames_Text.Connect_P2Papers",
    bDisableMissionTitle = true,
    tSMEDNodes = {}
  })
end

function Connect_P2Papers:STARTER_Setup()
end

function Connect_P2Papers:Activated()
  self.sDebugLabel = "Connect_P2Papers"
  self.bDebugMode = false
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.TestContraband(self)
end

function Connect_P2Papers:GENERAL_Setup()
  Zone.SwitchState("WtF_Zones\\global\\P2HQ_WTF", cZONESTATE_HIGHWTF, cENT_IMMEDIATE)
end

function Connect_P2Papers:TestContraband()
  local nContraband = Inventory.GetMoney()
  if nContraband < 250 then
    self:Task_NoMoney()
    dprint(self, ">>>>>> Sorry:  Player has less than 1000 Contraband")
    EVENT_Timer("Saboteur.ShowToolTip", self, 5, {
      "Connect_P2Papers_Text.TIP_GetContraband"
    })
  elseif 250 <= nContraband then
    self:Task_HasMoney()
    dprint(self, ">>>>>> WOOHOOO!!! Player has more than 1000 Contraband")
  else
    dprint(self, "ERROR: Contraband is " .. nContraband)
  end
end

function Connect_P2Papers:Task_NoMoney()
  self:CreateTask({
    sName = "Connect_P2Papers_Task_NoMoney",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sConvFile = "Connect_P2Papers_NoMoney",
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

function Connect_P2Papers:Task_HasMoney()
  self:CreateTask({
    sName = "Connect_P2Papers_Task_HasMoney",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sConvFile = "Connect_P2Papers_HasMoney",
    bAutoFire = true,
    Proximity = 3,
    tTgtInclude = {
      self:GetStarter()
    },
    tOnActivate = {
      {
        Inventory.GiveMoney,
        {-250}
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
