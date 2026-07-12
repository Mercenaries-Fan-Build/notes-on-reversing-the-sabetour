if Connect_JulesisDeadCin == nil then
  Connect_JulesisDeadCin = SabTaskObjective:Create()
  Connect_JulesisDeadCin:Configure({
    TaskCount = "auto",
    MCDisplayID = 2,
    tUnlockList = {
      "Connect_A1_M5b_BellAnd3Months"
    },
    sSaveMissionNameID = "MissionNames_Text.A1_Farm",
    bDisableMissionTitle = true,
    bStarterless = true,
    bForceUnloadNodes = true,
    bSLOverrideFade = true,
    tSMEDNodes = {}
  })
end

function Connect_JulesisDeadCin:STARTER_Setup()
  Render.ClearGlobalWTF()
  Suspicion.ResetEscalation()
  Actor.SetDisguise(hSab, "FBS_RS_Sean_Shirt_Sab_Hat_NoBag")
  EVENT_Timer("Connect_JulesisDeadCin.DelayScreenFadeOverride", self, 0.5)
end

function Connect_JulesisDeadCin:DelayScreenFadeOverride()
  Util.SetOverrideLoadScreenFadeIn(true)
end

function Connect_JulesisDeadCin:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.TASK_EnterBelle(self)
end

function Connect_JulesisDeadCin:GENERAL_Setup()
end

function Connect_JulesisDeadCin:TASK_EnterBelle()
  self:CreateTask({
    sName = "TASK_EnterBelle",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "EnterInterior",
    sInteriorName = "Belle",
    tLocators = {},
    tOnActivate = {
      {
        self.HelperTeleport,
        {self}
      }
    },
    tOnComplete = {
      {
        self.Task_FirstObjective,
        {self}
      }
    }
  })
end

function Connect_JulesisDeadCin:HelperTeleport()
  if InteriorManager.GetPlayersInterior() ~= "Belle" then
    InteriorManager.EnterInterior("Belle", "PARIS\\area01\\belledenuit\\interior\\hq_int\\LOC_Belle_int_Two")
  end
end

function Connect_JulesisDeadCin:Task_FirstObjective()
  self:CreateTask({
    sName = "Connect_JulesisDeadCin_Task_FirstObjective",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    bCompleteOnActivate = true,
    tOnActivate = {
      {
        self.DisableBelleBackDoor,
        {self}
      },
      {
        self.Task_BelleArrivalCinematic,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Connect_JulesisDeadCin:DisableBelleBackDoor()
  local hBelleBackDoor = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\hq_int\\Belle_int_teleport(2)")
  AttractionPt.EnableUse(hBelleBackDoor, false)
  local hSeansDoor = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\hq_int\\MN_INT_BelleDeNuit\\AnimatedObject_SeansRoom")
  self.hSeansDoor = hSeansDoor
  Object.ForceOpen(hSeansDoor, true)
  Object.SetDoorCloseDelay(hSeansDoor, 120)
end

function Connect_JulesisDeadCin:Task_BelleArrivalCinematic()
  self:CreateTask({
    sName = "Task_BelleArrivalCinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "127_CinB_BellArivl",
    bOverrideFade = true,
    tOnActivate = {},
    tOnComplete = {
      {
        Object.ForceClose,
        {
          self.hSeansDoor
        }
      },
      {
        Object.SetDoorCloseDelay,
        {
          self.hSeansDoor,
          0
        }
      },
      {
        self.CompleteThisMission,
        {self}
      }
    },
    tCinematicNodes = {
      "127_cinb_bellarivl"
    }
  })
end

function Connect_JulesisDeadCin:Task_3MonthsCinematic()
  self:CreateTask({
    sName = "Connect_JulesisDeadCin_Task_3MonthsCinematic",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "201_CinA_3Months",
    bOverrideFade = true,
    tOnActivate = {},
    tOnComplete = {
      {
        Util.SetOverrideLoadScreenFadeIn,
        {false}
      },
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end

function Connect_JulesisDeadCin:FinishUp()
  self:CompleteThisMission()
end

function Connect_JulesisDeadCin:OpenBackDoor()
end
