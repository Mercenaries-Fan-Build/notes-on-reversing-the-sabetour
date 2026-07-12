if FP_AMB_ChemFactoryStart == nil then
  FP_AMB_ChemFactoryStart = SabTaskObjective:Create()
  FP_AMB_ChemFactoryStart.sPATH = "Missions\\freeplay\\ambient\\cf\\"
  FP_AMB_ChemFactoryStart:Configure({
    TaskCount = 99,
    sStarter = "wilcox_lehavre_interior",
    sSaveMissionNameID = "MissionNames_Text.AMB_ChemicalFactory",
    sActNameID = "MissionNames_Text.ACT_Wilcox",
    tDependencyList = {},
    sConvFile = "Chemical_Factory_Start",
    tUnlockList = {
      "FP_AMB_ChambordStart"
    },
    tSMEDNodes = {
      FP_AMB_ChemFactoryStart.sPATH .. "mission"
    },
    tStaticTags = {
      "fp_amb_cf_props_mission"
    }
  })
end

function FP_AMB_ChemFactoryStart:STARTER_Setup()
end

function FP_AMB_ChemFactoryStart:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  Sound.LoadSoundBank("m_fp_ChemicalFactory.bnk")
  self.SetupCheckpoint(self, 1)
end

function FP_AMB_ChemFactoryStart:GENERAL_Setup()
  AmbientRubberStamp.UnlockAmbientAllInZone("CF")
  Freeplay.BlockZoneForSave("CF", true)
end

function FP_AMB_ChemFactoryStart:SetupVariables()
  self.hSab = Handle("Saboteur")
  self.sGotoTrig = self.sGotoTrig or self.sPATH .. "PT_ChemCompTrig"
  self.sGotoLoc = self.sGotoLoc or self.sPATH .. "mission\\LOC_ChemFacGoto"
  self.nAmbientIndex = self.nAmbientIndex or 3
end

function FP_AMB_ChemFactoryStart:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "FP_AMB_ChemFactoryStart.DoCheckpoint")
end

function FP_AMB_ChemFactoryStart:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  self.SetupVariables(self)
  if nCP == 1 then
    self.ExitHQ(self)
    self.TASK_GotoChemFactory(self)
  elseif nCP == 2 then
    if not self:IsMissionTaskActive("FP_AMB_ChemFactoryStart.TASK_GotoChemFactory") then
      self.TASK_GotoChemFactory(self)
    end
  elseif nCP == 3 then
    local tempself = Actor.GetSelf(AmbientRubberStamp.hController)
    local nMax = AmbientRubberStamp.GetProgressBarValue(tempself, 1, 14)
    local nCur = AmbientRubberStamp.GetProgressBarValue(tempself, 2, 14)
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
      self.eDeathEvent = Util.CreateEvent(tDeathEvent, "FP_AMB_ChemFactoryStart.SabDied", self)
    end
  end
end

function FP_AMB_ChemFactoryStart:ExitHQ()
  self:CreateTask({
    sName = "FP_AMB_ChemFactoryStart.ExitHQ",
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

function FP_AMB_ChemFactoryStart:TASK_GotoChemFactory()
  self:CreateTask({
    sName = "FP_AMB_ChemFactoryStart.TASK_GotoChemFactory",
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
    sObjectiveTextID = "FP_AMB_ChemFactoryStart_Text.TASK_GotoChemFactory",
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 3}
      }
    }
  })
end

function FP_AMB_ChemFactoryStart:TASK_DestroyAllTargets()
  self:CreateTask({
    sName = "FP_AMB_ChemFactoryStart.TASK_DestroyAllTargets",
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

function FP_AMB_ChemFactoryStart:Task_CutsceneOUT()
  if Cin.IsPlayerCloseToCinematic("Missions\\freeplay\\ambient\\cf\\mission\\LOC_ChemFac_WTFDist") then
    self:CreateTask({
      sName = "Task_CutsceneOUT",
      sTaskType = "SabTaskObjectiveInteract",
      sTaskSubType = "cinematic",
      sCinFile = "WTF_AMB_ChemicalFactory",
      tCinematicNodes = {
        "wtf_amb_chemicalfactory"
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
            "Task_CutsceneOUT",
            true
          }
        }
      }
    })
  else
    self:CreateTask({
      sName = "Task_CutsceneOUT",
      sTaskType = "SabTaskObjectiveInteract",
      sTaskSubType = "cinematic",
      sCinFile = "WTF_AMB_ChemicalFactory_NOCAM",
      tCinematicNodes = {
        "wtf_amb_chemicalfactory"
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
            "Task_CutsceneOUT",
            true
          }
        }
      }
    })
  end
end

function FP_AMB_ChemFactoryStart:SetupAmbientTargets()
  AmbientRubberStamp.UpdateProgressMeter(self.sGotoTrig, self.nAmbientIndex)
end

function FP_AMB_ChemFactoryStart:DoCleanup()
  AmbientRubberStamp.UnlockAmbientAllInZone("CA")
  self:CompleteThisMission()
  Sound.ReleaseSoundBank("m_fp_ChemicalFactory.bnk")
  if self.eDeathEvent then
    Util.KillEvent(self.eDeathEvent)
    self.eDeathEvent = nil
  end
end

function FP_AMB_ChemFactoryStart:SabDied()
  AmbientRubberStamp.SetPlayerDied(true)
end

function FP_AMB_ChemFactoryStart:MISSION_ONCANCEL()
  AmbientRubberStamp.RemoveMissionCountsFromTotals(self.nAmbientIndex)
  AmbientRubberStamp.UnloadMissionNodes("CF")
  Freeplay.BlockZoneForSave("CF", false)
end

function FP_AMB_ChemFactoryStart:MISSION_ONRESET()
  Freeplay.BlockZoneForSave("CF", false)
  Sound.ReleaseSoundBank("m_fp_ChemicalFactory.bnk")
end
