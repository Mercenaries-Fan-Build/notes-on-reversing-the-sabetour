if FP_AMB_ChambordStart == nil then
  FP_AMB_ChambordStart = SabTaskObjective:Create()
  FP_AMB_ChambordStart.sPATH = "Missions\\freeplay\\ambient\\cb\\"
  FP_AMB_ChambordStart:Configure({
    TaskCount = 99,
    sStarter = "wilcox_lehavre_interior",
    sSaveMissionNameID = "MissionNames_Text.AMB_ChambordChateau",
    sActNameID = "MissionNames_Text.ACT_Wilcox",
    tDependencyList = {
      "FP_AMB_ChemFactoryStart",
      "SOE_2_Mission_2_ConnectB"
    },
    sConvFile = "Chateau_Start",
    tUnlockList = {},
    tSMEDNodes = {
      FP_AMB_ChambordStart.sPATH .. "mission"
    },
    tStaticTags = {
      "fp_amb_cb_props_mission"
    }
  })
end

function FP_AMB_ChambordStart:STARTER_Setup()
end

function FP_AMB_ChambordStart:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.SetupCheckpoint(self, 1)
end

function FP_AMB_ChambordStart:GENERAL_Setup()
  AmbientRubberStamp.UnlockAmbientAllInZone("CB")
  Freeplay.BlockZoneForSave("CB", true)
end

function FP_AMB_ChambordStart:SetupVariables()
  self.hSab = Handle("Saboteur")
  self.sGotoTrig = self.sGotoTrig or self.sPATH .. "PT_ChamCompTrig"
  self.sGotoLoc = self.sGotoLoc or self.sPATH .. "mission\\LOC_ChambordGoto"
  self.nAmbientIndex = self.nAmbientIndex or 1
end

function FP_AMB_ChambordStart:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "FP_AMB_ChambordStart.DoCheckpoint")
end

function FP_AMB_ChambordStart:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  self.SetupVariables(self)
  if nCP == 1 then
    self.ExitHQ(self)
    self.TASK_GotoChambord(self)
  elseif nCP == 2 then
    if not self:IsMissionTaskActive("FP_AMB_ChambordStart.TASK_GotoChambord") then
      self.TASK_GotoChambord(self)
    end
  elseif nCP == 3 then
    local tempself = Actor.GetSelf(AmbientRubberStamp.hController)
    local nMax = AmbientRubberStamp.GetProgressBarValue(tempself, 1, 12)
    local nCur = AmbientRubberStamp.GetProgressBarValue(tempself, 2, 12)
    if nMax == nCur then
      self:CompleteThisMission()
    else
      Trigger.Enable(self.sGotoTrig, true)
      AmbientRubberStamp.SetPlayerDied(false)
      AmbientRubberStamp.RemoveBlips(self.nAmbientIndex)
      self.TASK_DestroyAllTargets(self)
      if self.eDeathEvent then
        Util.KillEvent(self.eDeathEvent)
        self.eDeathEvent = nil
      end
      local tDeathEvent = {
        EventType = "DeathEvent",
        ObjectHandle = self.hSab
      }
      self.eDeathEvent = Util.CreateEvent(tDeathEvent, "FP_AMB_ChambordStart.SabDied", self)
    end
  end
end

function FP_AMB_ChambordStart:ExitHQ()
  self:CreateTask({
    sName = "FP_AMB_ChambordStart.ExitHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "LeHavre",
    bInteriorTask = true,
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 2}
      }
    }
  })
end

function FP_AMB_ChambordStart:TASK_GotoChambord()
  self:CreateTask({
    sName = "FP_AMB_ChambordStart.TASK_GotoChambord",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tLocators = {
      self.sGotoLoc
    },
    tDestRegion = {
      self.sGotoTrig
    },
    tDeliverObjs = {
      self.hSab
    },
    sObjectiveTextID = "FP_AMB_ChambordStart_Text.TASK_GotoChambord",
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 3}
      }
    }
  })
end

function FP_AMB_ChambordStart:TASK_DestroyAllTargets()
  self:CreateTask({
    sName = "FP_AMB_ChambordStart.TASK_DestroyAllTargets",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "NONE",
    tOnActivate = {
      {
        self.SetupAmbientTargets,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function FP_AMB_ChambordStart:Task_CutsceneOUT()
  if Cin.IsPlayerCloseToCinematic("Missions\\freeplay\\ambient\\cb\\mission\\LOC_WTF_CloseCheck") then
    self:Task_CutsceneNear()
  else
    self:Task_CutsceneFar()
  end
end

function FP_AMB_ChambordStart:Task_CutsceneNear()
  self:CreateTask({
    sName = "Task_CutsceneNear",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "WTF_FP_Chambord",
    tCinematicNodes = {
      "wtf_fp_chambord"
    },
    tOnComplete = {
      {
        self.DoCleanup,
        {self}
      },
      {
        self.UnloadTaskNodes,
        {
          self,
          "Task_CutsceneNear",
          true
        }
      }
    }
  })
end

function FP_AMB_ChambordStart:Task_CutsceneFar()
  self:CreateTask({
    sName = "Task_CutsceneFar",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "WTF_FP_Chambord_NOCAM",
    tCinematicNodes = {
      "wtf_fp_chambord"
    },
    tOnComplete = {
      {
        self.DoCleanup,
        {self}
      },
      {
        self.UnloadTaskNodes,
        {
          self,
          "Task_CutsceneFar",
          true
        }
      }
    }
  })
end

function FP_AMB_ChambordStart:SetupAmbientTargets()
  AmbientRubberStamp.UpdateProgressMeter(self.sGotoTrig, self.nAmbientIndex)
end

function FP_AMB_ChambordStart:DoCleanup()
  self:CompleteThisMission()
  if self.eDeathEvent then
    Util.KillEvent(self.eDeathEvent)
    self.eDeathEvent = nil
  end
end

function FP_AMB_ChambordStart:SabDied()
  AmbientRubberStamp.SetPlayerDied(true)
end

function FP_AMB_ChambordStart:MISSION_ONCANCEL()
  AmbientRubberStamp.RemoveMissionCountsFromTotals(self.nAmbientIndex)
  AmbientRubberStamp.UnloadMissionNodes("CB")
  AmbientRubberStamp.LockAmbientAllInZone("CB")
  Freeplay.BlockZoneForSave("CB", false)
end

function FP_AMB_ChambordStart:MISSION_ONRESET()
  AmbientRubberStamp.LockAmbientAllInZone("CB")
  Freeplay.BlockZoneForSave("CB", false)
end
