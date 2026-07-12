if P1FP_OnTheAir == nil then
  P1FP_OnTheAir = SabTaskObjective:Create()
  P1FP_OnTheAir.sPATH = "Missions\\freeplay\\p1\\mis_palais_s_ontheair\\"
  P1FP_OnTheAir:Configure({
    TaskCount = "auto",
    sStarter = "santos_ext_hideout",
    bFreeplay = true,
    sSaveMissionNameID = "MissionNames_Text.P1FP_OnTheAir",
    sConvFile = "P1FP_OnTheAir_Start",
    tUnlockList = {
      "Connect_P3Papers"
    },
    tSMEDNodes = {
      P1FP_OnTheAir.sPATH .. "main"
    },
    tStaticTags = {
      "p1_mis_palais_s_ontheair_mission"
    }
  })
end

function P1FP_OnTheAir:STARTER_Setup()
end

function P1FP_OnTheAir:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "ONTHEAIR"
  self.bDebugMode = false
  self.SetupCheckpoint(self, 1)
end

function P1FP_OnTheAir:GENERAL_Setup()
end

function P1FP_OnTheAir:SetupVariables()
  self.hSab = self.hSab or Handle("Saboteur")
  self.sMissionAreaLoc = self.sMissionAreaLoc or self.sPATH .. "main\\LOC_ToMissionArea"
  self.sMissionArea = self.sMissionArea or self.sPATH .. "main\\PT_NearMission"
  self.sPaperSwapPt = self.sPaperSwapPt or self.sPATH .. "main\\File1Grab"
  self.sSantos = self.sSantos or "Missions\\paris_1\\characters\\belle\\santos_hideout\\santos_ext_hideout"
  self.sSantosLoc = self.sSantosLoc or self.sPATH .. "main\\LOC_ReturnToSantos"
  self.sRestrictedArea = self.sRestrictedArea or self.sPATH .. "main\\PT_MissionArea"
end

function P1FP_OnTheAir:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "P1FP_OnTheAir.DoCheckpoint")
end

function P1FP_OnTheAir:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  self.SetupVariables(self)
  if nCP == 1 then
    self.ExitHQ(self)
    self.Task_GoToMission(self)
    self.TASK_Escalator(self)
  elseif nCP == 2 then
    if not self:IsMissionTaskActive("P1FP_OnTheAir.Task_GoToMission") then
      self.Task_GoToMission(self)
    end
    if not self:IsMissionTaskActive("P1FP_OnTheAir.TASK_Escalator") then
      self.TASK_Escalator(self)
    end
  elseif nCP == 3 then
    self.PlayEscTip(self)
    self.Task_SwapPapers(self)
  elseif nCP == 4 then
    self.Task_ReturnToHQ(self)
  end
end

function P1FP_OnTheAir:ExitHQ()
  self:CreateTask({
    sName = "P1FP_OnTheAir.ExitHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "Belle",
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 2}
      }
    }
  })
end

function P1FP_OnTheAir:Task_GoToMission()
  self:CreateTask({
    sName = "P1FP_OnTheAir.Task_GoToMission",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "P1FP_OnTheAir_Text.Task_GoToMission",
    tLocators = {
      self.sMissionAreaLoc
    },
    tDestRegion = self.sMissionArea,
    sTaskSubType = "DELIVER",
    tDeliverObjs = {
      self.hSab
    },
    sTaskEndConv = "P1FP_OnTheAir_NoEscalate",
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 3}
      }
    }
  })
end

function P1FP_OnTheAir:TASK_Escalator()
  self:CreateTask({
    sName = "P1FP_OnTheAir.TASK_Escalator",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.EscalationTest,
        {self}
      },
      {
        self.ResetTaskByName,
        {
          self,
          "P1FP_OnTheAir.TASK_Escalator",
          false
        }
      }
    }
  })
end

function P1FP_OnTheAir:Task_SwapPapers()
  self:CreateTask({
    sName = "P1FP_OnTheAir.Task_SwapPapers",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    tTgtInclude = {
      self.sPaperSwapPt
    },
    sObjectiveTextID = "P1FP_OnTheAir_Text.Task_SwapPapers",
    tOnActivate = {},
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 4}
      }
    }
  })
end

function P1FP_OnTheAir:Task_ReturnToHQ()
  self:CreateTask({
    sName = "P1FP_OnTheAir.Task_ReturnToHQ",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    bEscalationDenial = true,
    sObjectiveTextID = "P1FP_OnTheAir_Text.Task_TalkToSantos",
    tTgtInclude = {
      self.sSantos
    },
    vGPSTarget = self.sSantosLoc,
    sConvFile = "P1FP_OnTheAir_GotBook",
    tOnComplete = {
      {
        Inventory.GiveItem,
        {
          hSab,
          "Papers_P3",
          false
        }
      },
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end

function P1FP_OnTheAir:PlayEscTip()
  Saboteur.ShowToolTip("P1FP_OnTheAir_Text.TIP_EscFail")
end

function P1FP_OnTheAir:EscalationTest()
  local tObjects = Trigger.GetAllWithin(Handle(self.sRestrictedArea))
  if tObjects then
    for i, hEnt in ipairs(tObjects) do
      if hEnt == self.hSab then
        self.EscalationFail(self)
        break
      end
    end
  end
end

function P1FP_OnTheAir:EscalationFail()
  local tTimerEvent = {EventType = "TimerEvent", Time = 3}
  self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_OnTheAir.FailMission", self))
end

function P1FP_OnTheAir:FailMission()
  self:MissionTaskFail("P1FP_OnTheAir_Text.Fail_TargetEscaped")
end

function P1FP_OnTheAir:MISSION_ONCANCEL()
end
