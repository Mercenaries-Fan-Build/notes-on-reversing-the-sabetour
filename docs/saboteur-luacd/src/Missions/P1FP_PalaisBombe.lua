if P1FP_PalaisBombe == nil then
  P1FP_PalaisBombe = SabTaskObjective:Create()
  P1FP_PalaisBombe.sPATH = "Missions\\freeplay\\ambient\\pr\\"
  P1FP_PalaisBombe:Configure({
    TaskCount = 99,
    sStarter = "Crochet_ext_whouse",
    sConvFile = "P3FP_PalaisBombe_Start",
    sSaveMissionNameID = "MissionNames_Text.AMB_PalaisBombe",
    sActNameID = "MissionNames_Text.ACT_LeCrochet",
    tDependencyList = {},
    tUnlockList = {
      "NOTE_AMB_Finish"
    },
    tSMEDNodes = {
      P1FP_PalaisBombe.sPATH .. "mission",
      "Missions\\cinematics\\wtf\\wtf_amb_palaisbombe"
    },
    tStaticTags = {
      "fp_amb_pr_props_mission"
    }
  })
end

function P1FP_PalaisBombe:STARTER_Setup()
end

function P1FP_PalaisBombe:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  Sound.LoadSoundBank("m_P1FP_PalaisBombe.bnk")
  self.SetupCheckpoint(self, 1)
end

function P1FP_PalaisBombe:GENERAL_Setup()
  AmbientRubberStamp.UnlockAmbientAllInZone("PR")
  Freeplay.BlockZoneForSave("PR", true)
end

function P1FP_PalaisBombe:SetupVariables()
  self.hSab = Handle("Saboteur")
  self.sGotoTrig = self.sGotoTrig or self.sPATH .. "PT_PalaisCompTrig"
  self.sGotoLoc = self.sGotoLoc or self.sPATH .. "mission\\LOC_PalaisGoto"
  self.nAmbientIndex = self.nAmbientIndex or 2
end

function P1FP_PalaisBombe:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "P1FP_PalaisBombe.DoCheckpoint")
end

function P1FP_PalaisBombe:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  self.SetupVariables(self)
  if nCP == 1 then
    self.ExitHQ(self)
    self.TASK_GotoPalais(self)
  elseif nCP == 2 then
    if not self:IsMissionTaskActive("P1FP_PalaisBombe.TASK_GotoPalais") then
      self.TASK_GotoPalais(self)
    end
  elseif nCP == 3 then
    local tempself = Actor.GetSelf(AmbientRubberStamp.hController)
    local nMax = AmbientRubberStamp.GetProgressBarValue(tempself, 1, 13)
    local nCur = AmbientRubberStamp.GetProgressBarValue(tempself, 2, 13)
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
      self.eDeathEvent = Util.CreateEvent(tDeathEvent, "P1FP_PalaisBombe.SabDied", self)
    end
  end
end

function P1FP_PalaisBombe:ExitHQ()
  self:CreateTask({
    sName = "P1FP_PalaisBombe.ExitHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "LaVillette",
    bInteriorTask = true,
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 2}
      }
    }
  })
end

function P1FP_PalaisBombe:TASK_GotoPalais()
  self:CreateTask({
    sName = "P1FP_PalaisBombe.TASK_GotoPalais",
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
    sObjectiveTextID = "P1FP_PalaisBombe_Text.TASK_GotoPalais",
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 3}
      }
    }
  })
end

function P1FP_PalaisBombe:TASK_DestroyAllTargets()
  self:CreateTask({
    sName = "P1FP_PalaisBombe.TASK_DestroyAllTargets",
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

function P1FP_PalaisBombe:Task_CutsceneOUT()
  if Cin.IsPlayerCloseToCinematic("Missions\\freeplay\\ambient\\pr\\mission\\WTF_Shift_DistCheck") then
    Cin.PlayCinematic("WTF_AMB_PalaisBombe", false, "P1FP_PalaisBombe.DoCleanup", self, {})
  else
    Cin.PlayCinematic("WTF_AMB_PalaisBombe_NOCAM", false, "P1FP_PalaisBombe.DoCleanup", self, {})
  end
end

function P1FP_PalaisBombe:SetupAmbientTargets()
  AmbientRubberStamp.UpdateProgressMeter(self.sGotoTrig, self.nAmbientIndex)
end

function P1FP_PalaisBombe:DoCleanup()
  Sound.ReleaseSoundBank("m_P1FP_PalaisBombe.bnk")
  self:CompleteThisMission()
  if self.eDeathEvent then
    Util.KillEvent(self.eDeathEvent)
    self.eDeathEvent = nil
  end
end

function P1FP_PalaisBombe:SabDied()
  AmbientRubberStamp.SetPlayerDied(true)
end

function P1FP_PalaisBombe:MISSION_ONCANCEL()
  AmbientRubberStamp.RemoveMissionCountsFromTotals(self.nAmbientIndex)
  AmbientRubberStamp.UnloadMissionNodes("PR")
  AmbientRubberStamp.LockAmbientAllInZone("PR")
  Freeplay.BlockZoneForSave("PR", false)
end

function P1FP_PalaisBombe:MISSION_ONRESET()
  AmbientRubberStamp.LockAmbientAllInZone("PR")
  Freeplay.BlockZoneForSave("PR", false)
  Sound.ReleaseSoundBank("m_P1FP_PalaisBombe.bnk")
end
