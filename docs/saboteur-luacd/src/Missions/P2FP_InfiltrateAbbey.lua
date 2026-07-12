if P2FP_InfiltrateAbbey == nil then
  P2FP_InfiltrateAbbey = SabTaskObjective:Create()
  P2FP_InfiltrateAbbey.sPATH = "Missions\\freeplay\\ambient\\os\\"
  P2FP_InfiltrateAbbey:Configure({
    TaskCount = 99,
    sStarter = "wilcox_lehavre_interior",
    sConvFile = "P2FP_InfiltrateAbbey_Start",
    sSaveMissionNameID = "MissionNames_Text.AMB_AbbeyChateau",
    sActNameID = "MissionNames_Text.ACT_Wilcox",
    tUnlockList = {
      "FP_AMB_ChemFactoryStart"
    },
    tSMEDNodes = {
      P2FP_InfiltrateAbbey.sPATH .. "mission"
    },
    tStaticTags = {
      "fp_amb_os_props_mission"
    }
  })
end

function P2FP_InfiltrateAbbey:STARTER_Setup()
end

function P2FP_InfiltrateAbbey:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  Sound.LoadSoundBank("m_fp_L_ossuaire.bnk")
  self.SetupCheckpoint(self, 1)
end

function P2FP_InfiltrateAbbey:GENERAL_Setup()
  AmbientRubberStamp.UnlockAmbientAllInZone("OS")
  Freeplay.BlockZoneForSave("OS", true)
end

function P2FP_InfiltrateAbbey:SetupVariables()
  self.hSab = Handle("Saboteur")
  self.sGotoTrig = self.sGotoTrig or self.sPATH .. "PT_LossCompTrig"
  self.sGotoLoc = self.sGotoLoc or self.sPATH .. "mission\\LOC_LOssuaireGoto"
  self.nAmbientIndex = self.nAmbientIndex or 4
  self.tTowerTargets = {
    self.sPATH .. "os_radiotower_01\\OccLt_RadioTower_50M_OS",
    self.sPATH .. "os_radiotower_02\\OccLt_RadioTower_50M_OS",
    self.sPATH .. "os_radiotower_03\\OccLt_RadioTower_50M_OS",
    self.sPATH .. "os_radiotower_04\\OccLt_RadioTower_50M_OS",
    self.sPATH .. "os_radiotower_05\\OccLt_RadioTower_50M_OS",
    self.sPATH .. "os_radiotower_06\\OccLt_RadioTower_50M_OS"
  }
  self.tTowerSounds = {
    self.sPATH .. "sound\\Emt_L'ossuaire_TowerExp_01",
    self.sPATH .. "sound\\Emt_L'ossuaire_TowerExp_02",
    self.sPATH .. "sound\\Emt_L'ossuaire_TowerExp_03",
    self.sPATH .. "sound\\Emt_L'ossuaire_TowerExp_04",
    self.sPATH .. "sound\\Emt_L'ossuaire_TowerExp_05",
    self.sPATH .. "sound\\Emt_L'ossuaire_TowerExp_06"
  }
end

function P2FP_InfiltrateAbbey:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "P2FP_InfiltrateAbbey.DoCheckpoint")
end

function P2FP_InfiltrateAbbey:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  self.SetupVariables(self)
  if nCP == 1 then
    self.ExitHQ(self)
    self.TASK_GotoLOssuaire(self)
  elseif nCP == 2 then
    if not self:IsMissionTaskActive("P2FP_InfiltrateAbbey.TASK_GotoLOssuaire") then
      self.TASK_GotoLOssuaire(self)
    end
  elseif nCP == 3 then
    local tempself = Actor.GetSelf(AmbientRubberStamp.hController)
    local nMax = AmbientRubberStamp.GetProgressBarValue(tempself, 1, 15)
    local nCur = AmbientRubberStamp.GetProgressBarValue(tempself, 2, 15)
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
      self.eDeathEvent = Util.CreateEvent(tDeathEvent, "P2FP_InfiltrateAbbey.SabDied", self)
    end
  end
end

function P2FP_InfiltrateAbbey:ExitHQ()
  self:CreateTask({
    sName = "P2FP_InfiltrateAbbey.ExitHQ",
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

function P2FP_InfiltrateAbbey:TASK_GotoLOssuaire()
  self:CreateTask({
    sName = "P2FP_InfiltrateAbbey.TASK_GotoLOssuaire",
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
    sObjectiveTextID = "P2FP_InfiltrateAbbey_Text.TASK_GotoLOssuaire",
    bGroundBlip = true,
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 3}
      }
    }
  })
end

function P2FP_InfiltrateAbbey:TASK_DestroyAllTargets()
  self:CreateTask({
    sName = "P2FP_InfiltrateAbbey.TASK_DestroyAllTargets",
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

function P2FP_InfiltrateAbbey:Task_CutsceneOUT()
  if Cin.IsPlayerCloseToCinematic("Missions\\freeplay\\ambient\\os\\mission\\Locator(7)") then
    self:Task_CutsceneNear()
  else
    self:Task_CutsceneFar()
  end
end

function P2FP_InfiltrateAbbey:Task_CutsceneNear()
  self:CreateTask({
    sName = "Task_CutsceneNear",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "WTF_FP_Ossuaire",
    tCinematicNodes = {
      "wtf_fp_ossuaire"
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

function P2FP_InfiltrateAbbey:Task_CutsceneFar()
  self:CreateTask({
    sName = "Task_CutsceneFar",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "WTF_FP_Ossuaire_NOCAM",
    tCinematicNodes = {
      "wtf_fp_ossuaire"
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

function P2FP_InfiltrateAbbey:CleanupStuff()
  Render.FadeScreen(false)
  self.DoCleanup(self)
  self.UnloadTaskNodes(self, "Task_CutsceneOUT", true)
end

function P2FP_InfiltrateAbbey:SetupAmbientTargets()
  AmbientRubberStamp.UpdateProgressMeter(self.sGotoTrig, self.nAmbientIndex)
  for i, sTower in ipairs(self.tTowerTargets) do
    local hTower = Handle(sTower)
    local tDeathEvent = {EventType = "DeathEvent", ObjectHandle = hTower}
    self:RegisterEvent(Util.CreateEvent(tDeathEvent, "P2FP_InfiltrateAbbey.EntityDied", self, {i}))
  end
end

function P2FP_InfiltrateAbbey:EntityDied(...)
  local a_tCallbackData, a_nIndex
  if arg.n == 1 then
    a_nIndex = unpack(arg)
  else
    a_tCallbackData, a_nIndex = unpack(arg)
  end
  local hEmitter = Handle(self.tTowerSounds[a_nIndex])
  Sound.ActivateSoundEmitter(hEmitter)
  local tTimerEvent = {EventType = "TimerEvent", Time = 11.76}
  self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P2FP_InfiltrateAbbey.TurnOffEmitter", self, {hEmitter}))
end

function P2FP_InfiltrateAbbey:TurnOffEmitter(a_hEmitter)
  Sound.DeactivateSoundEmitter(a_hEmitter)
end

function P2FP_InfiltrateAbbey:DoCleanup()
  self:CompleteThisMission()
  if self.eDeathEvent then
    Util.KillEvent(self.eDeathEvent)
    self.eDeathEvent = nil
  end
end

function P2FP_InfiltrateAbbey:SabDied()
  AmbientRubberStamp.SetPlayerDied(true)
end

function P2FP_InfiltrateAbbey:MISSION_ONCANCEL()
  AmbientRubberStamp.RemoveMissionCountsFromTotals(self.nAmbientIndex)
  AmbientRubberStamp.UnloadMissionNodes("OS")
  AmbientRubberStamp.LockAmbientAllInZone("OS")
  Freeplay.BlockZoneForSave("OS", false)
end

function P2FP_InfiltrateAbbey:MISSION_ONRESET()
  AmbientRubberStamp.UnloadMissionNodes("OS")
  AmbientRubberStamp.LockAmbientAllInZone("OS")
  Freeplay.BlockZoneForSave("OS", false)
  Sound.ReleaseSoundBank("m_fp_L_ossuaire.bnk")
end
