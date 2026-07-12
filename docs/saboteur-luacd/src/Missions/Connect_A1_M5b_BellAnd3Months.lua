if Connect_A1_M5b_BellAnd3Months == nil then
  Connect_A1_M5b_BellAnd3Months = SabTaskObjective:Create()
  Connect_A1_M5b_BellAnd3Months:Configure({
    TaskCount = "auto",
    MCDisplayID = 2,
    tUnlockList = {
      "Paris_1_Mission_1B"
    },
    sSaveMissionNameID = "MissionNames_Text.A1M5b",
    bDisableMissionTitle = true,
    bStarterless = true,
    bSLOverrideFade = true,
    tSMEDNodes = {}
  })
end

function Connect_A1_M5b_BellAnd3Months:STARTER_Setup()
  Render.ClearGlobalWTF()
  Suspicion.ResetEscalation()
  Actor.SetDisguise(hSab, "FBS_RS_Sean_Shirt_Sab_Hat_NoBag")
  Util.SetOverrideLoadScreenFadeIn(true)
end

function Connect_A1_M5b_BellAnd3Months:DelayScreenFadeOverride()
  Util.SetOverrideLoadScreenFadeIn(true)
end

function Connect_A1_M5b_BellAnd3Months:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.TASK_EnterBelle(self)
end

function Connect_A1_M5b_BellAnd3Months:GENERAL_Setup()
end

function Connect_A1_M5b_BellAnd3Months:TASK_EnterBelle()
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

function Connect_A1_M5b_BellAnd3Months:HelperTeleport()
  InteriorManager.EnterInterior("Belle", "PARIS\\area01\\belledenuit\\interior\\hq_int\\LOC_Belle_int_Two")
  if InteriorManager.GetPlayersInterior() ~= "Belle" then
    InteriorManager.EnterInterior("Belle", "PARIS\\area01\\belledenuit\\interior\\hq_int\\LOC_Belle_int_Two")
  end
end

function Connect_A1_M5b_BellAnd3Months:Task_FirstObjective()
  self:CreateTask({
    sName = "Connect_A1_M5b_BellAnd3Months_Task_FirstObjective",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    bCompleteOnActivate = true,
    tOnActivate = {
      {
        self.DisableBelleBackDoor,
        {self}
      },
      {
        self.Task_3MonthsCinematic,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Connect_A1_M5b_BellAnd3Months:DisableBelleBackDoor()
  local hBelleBackDoor = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\hq_int\\Belle_int_teleport(2)")
  AttractionPt.EnableUse(hBelleBackDoor, false)
end

function Connect_A1_M5b_BellAnd3Months:Task_3MonthsCinematic()
  self:CreateTask({
    sName = "Connect_A1_M5b_BellAnd3Months_Task_3MonthsCinematic",
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
        self.SetForTransitionFade,
        {self}
      },
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end

function Connect_A1_M5b_BellAnd3Months:SetForTransitionFade()
  _g_bConnectBelle3Months = true
end
