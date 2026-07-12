if P1FP_KillCourtyard01 == nil then
  P1FP_KillCourtyard01 = SabTaskObjective:Create()
  P1FP_KillCourtyard01.sPATH = "Missions\\freeplay\\p1\\mis_sacre_farsouth\\"
  P1FP_KillCourtyard01:Configure({
    TaskCount = 999,
    sSaveMissionNameID = "MissionNames_Text.P1FP_KillCourtyard01",
    sActNameID = "MissionNames_Text.ACT_Margot",
    tDependencyList = {},
    tUnlockList = {
      "P2FP_GrandSniper"
    },
    bFreeplay = true,
    sStarter = "Margot_Boulogne_Interior",
    sConvFile = "P1FP_KillCourtyard_Start",
    bEscalationDenial = true,
    bMissionBonus = true,
    sBonusSuccessID = "You win 11 yummy sammiches!",
    tSMEDNodes = {
      P1FP_KillCourtyard01.sPATH .. "task",
      P1FP_KillCourtyard01.sPATH .. "main"
    },
    tStaticTags = {
      "P1FP_KillCourtyard01"
    }
  })
end

function P1FP_KillCourtyard01:STARTER_Setup()
  Vehicle.EnableTraffic(false, true)
  Util.EnableSuperSpores(false)
end

function P1FP_KillCourtyard01:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.SetupCheckpoint(self, 3)
end

function P1FP_KillCourtyard01:GENERAL_Setup()
  self.sDebugLabel = "BookClub"
  self.bDebugMode = true
  self.nPathNumberRot = 0
  self.sTSLoder = "Missions\\freeplay\\p1\\mis_sacre_farsouth\\tankboss\\Spore_TS_Commander_SH"
  Sound.LoadSoundBank("m_P1FP_KillCourtyard.bnk")
end

function P1FP_KillCourtyard01:SetupVariables()
  self.hSab = Handle("Saboteur")
  self.bVariablesSet = true
  self.tInfo.sNaziOfficer = self.sPATH .. "main\\Officer_1"
  self.nOfficerPath = 1
  self.tOfficerPaths = {
    self.sPATH .. "main\\PA_OfficerPath01",
    self.sPATH .. "main\\PA_OfficerPath02",
    self.sPATH .. "main\\PA_OfficerPath03"
  }
  self.tNaziPathers = {
    self.sPATH .. "main\\Pather01",
    self.sPATH .. "main\\Pather02"
  }
  self.tNaziPaths = {
    {
      self.sPATH .. "main\\PA_ArcInt02",
      cPATHTYPE_BOUNCE
    },
    {
      self.sPATH .. "main\\PA_ArcInt01",
      cPATHTYPE_BOUNCE
    }
  }
  self.tSaluters01 = {
    {
      self.sPATH .. "main\\Fem_1",
      self.sPATH .. "main\\LOC_Fem_1",
      "nazi_chat2"
    },
    {
      self.sPATH .. "main\\Fem_2",
      self.sPATH .. "main\\LOC_Fem_2",
      "nazi_chat1"
    },
    {
      self.sPATH .. "main\\Grunt_2",
      self.sPATH .. "main\\LOC_Grunt_2",
      "nazi_chat2"
    },
    {
      self.sPATH .. "main\\Grunt_3",
      self.sPATH .. "main\\LOC_Grunt_3",
      "nazi_chat1"
    },
    {
      self.sPATH .. "main\\Spore_WM_Grunt(7)",
      self.sPATH .. "main\\LOC_Spore_WM_Grunt(7)",
      "Shrd_M_cheering_loop"
    },
    {
      self.sPATH .. "main\\Spore_WM_Grunt(9)",
      self.sPATH .. "main\\LOC_Spore_WM_Grunt(9)",
      "Shrd_M_cheering_loop"
    }
  }
  self.tSaluters02 = {
    {
      self.sPATH .. "main\\Fem_3",
      self.sPATH .. "main\\LOC_Fem_3",
      "nazi_chat2"
    },
    {
      self.sPATH .. "main\\Fem_4",
      self.sPATH .. "main\\LOC_Fem_4",
      "nazi_chat2"
    },
    {
      self.sPATH .. "main\\Grunt_1",
      self.sPATH .. "main\\LOC_Grunt_1",
      "nazi_chat2"
    },
    {
      self.sPATH .. "main\\Grunt_4",
      self.sPATH .. "main\\LOC_Grunt_4",
      "nazi_chat1"
    },
    {
      self.sPATH .. "main\\Spore_WM_Grunt(3)",
      self.sPATH .. "main\\LOC_Spore_WM_Grunt(3)",
      "Shrd_M_cheering_loop"
    },
    {
      self.sPATH .. "main\\Spore_WM_Grunt(4)",
      self.sPATH .. "main\\LOC_Spore_WM_Grunt(4)",
      "nazi_chat2"
    },
    {
      self.sPATH .. "main\\Spore_WM_Grunt(5)",
      self.sPATH .. "main\\LOC_Spore_WM_Grunt(5)",
      "nazi_chat1"
    }
  }
  self.tSaluters03 = {
    {
      self.sPATH .. "main\\Fem_6",
      self.sPATH .. "main\\LOC_Fem_6",
      "nazi_chat2"
    },
    {
      self.sPATH .. "main\\Fem_7",
      self.sPATH .. "main\\LOC_Fem_7",
      "nazi_chat1"
    },
    {
      self.sPATH .. "main\\Grunt_2(2)",
      self.sPATH .. "main\\LOC_Grunt_2(2)",
      "nazi_chat2"
    },
    {
      self.sPATH .. "main\\Grunt_3(2)",
      self.sPATH .. "main\\LOC_Grunt_3(2)",
      "nazi_chat1"
    },
    {
      self.sPATH .. "main\\Spore_WM_Grunt(11)",
      self.sPATH .. "main\\LOC_Spore_WM_Grunt(11)",
      "Shrd_M_cheering_loop"
    },
    {
      self.sPATH .. "main\\Spore_WM_Grunt(12)",
      self.sPATH .. "main\\LOC_Spore_WM_Grunt(12)",
      "Shrd_M_cheering_loop"
    }
  }
  self.tSaveInfo.bSetPanicCivs = false
  self.sKubelRounder1 = "Missions\\freeplay\\p1\\mis_sacre_farsouth\\props\\VH_NZ_CR_Kubelwagen_01"
  self.sRounderPath1 = "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\PA_Parade01"
  self.sRounderPathConnect1 = "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\PA_PathConnect"
  self.sKubelRounder2 = "Missions\\freeplay\\p1\\mis_sacre_farsouth\\props\\VH_NZ_CR_Kubelwagen_01(2)"
  self.sRounderPath2 = "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\PA_Parade02"
  self.sRounderPathConnect2 = "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\CCWPATConnect"
  self.sPT_Zone_Books = "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Zone_BookBurning"
  self.sKillTank = "Missions\\freeplay\\p1\\mis_sacre_farsouth\\TankBoss\\VH_NZ_TK_Flammwagen_01"
  self.sReinforcement1 = "Missions\\freeplay\\p1\\mis_sacre_farsouth\\ReinforcementWave1"
  if not Util.IsCustomTagLoaded("P1FP_KillCourtyard01_fx") then
    Util.LoadStaticENTag("P1FP_KillCourtyard01_fx", true)
  end
  self.tSteppers = {
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_WM_Heavy_SH(18)",
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_WM_Heavy_SH(10)",
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_WM_Heavy_SH(12)",
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_WM_Heavy_SH(14)",
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_WM_Heavy_SH(17)",
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_WM_Heavy_SH(28)",
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_WM_Heavy_SH(24)",
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_WM_Heavy_SH(25)",
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_WM_Heavy_SH(26)",
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_WM_Heavy_SH(30)",
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_WM_Heavy_SH(9)",
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_WM_Heavy_SH(7)"
  }
  self.sSeeGenConvo = "P1FP_KillCourtyard_SeeOfficer"
end

function P1FP_KillCourtyard01:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "P1FP_KillCourtyard01.DoCheckpoint")
end

function P1FP_KillCourtyard01:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  if not self.bVariablesSet and nCP < 3 then
    self.SetupVariables(self)
  end
  if nCP == 1 then
    self:SetFlamers()
    if not self:IsMissionTaskActive("P1FP_KillCourtyard01_TASK_GotoCourtyard") then
      self.TASK_GotoCourtyard(self)
    end
  elseif nCP == 2 then
    if Actor.IsInVehicle(self.hTSLoder) == false then
      Actor.BoardVehicle(self.hTSLoder, self.hTSAPC, "GUNNER", true)
    else
    end
    Util.KillEvent(self.eLodPreDeath)
    self.CleanDeathCallback(self)
    self.ClearHUDBar(self)
    self.TASK_MainTask(self)
    self.TASK_ListenForEscalate(self)
    Cin.PlayConversation("P1FP_KillCourtyard_SeeOfficer")
    self.WaitForTankStream(self)
  elseif nCP == 3 then
    self.SetupVariables(self)
    self.ExitHQ(self)
    if not self:IsMissionTaskActive("P1FP_KillCourtyard01_TASK_GotoCourtyard") then
      self.TASK_GotoCourtyard(self)
    end
  end
end

function P1FP_KillCourtyard01:MISSION_ONRESET()
  Vehicle.EnableTraffic(true)
end

function P1FP_KillCourtyard01:ExitHQ()
  self:CreateTask({
    sName = "P1FP_KillCourtyard01_ExitHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "Boulogne",
    bNoWorldBlip = true,
    bNoHUDBlip = true,
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 1}
      }
    }
  })
end

function P1FP_KillCourtyard01:TASK_FakeMainTask()
  self:CreateTask({
    sName = "P1FP_KillCourtyard01_TASK_FakeMainTask",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "NONE",
    sObjectiveTextID = "P1FP_KillCourtyard01_Text.TASK_MainTask",
    bPersistentParent = true,
    tOnActivate = {},
    tOnComplete = {}
  })
end

function P1FP_KillCourtyard01:TASK_MainTask()
  self:CreateTask({
    sName = "P1FP_KillCourtyard01_TASK_MainTask",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P1FP_KillCourtyard01_Text.TASK_MainTask",
    ParentObjectID = -1,
    tTgtInclude = {
      self.sTSLoder
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.CheckForLoder,
        {self}
      }
    },
    tOnDamage = {
      {
        self.OnTankDamage,
        {self}
      }
    },
    tSMEDNodes = {}
  })
end

function P1FP_KillCourtyard01:BridgeToLoop()
  EVENT_Timer("P1FP_KillCourtyard01.StartAnnouncementLoop", self, 5)
end

function P1FP_KillCourtyard01:ClearHUDBar()
  if self.tInfo.hLoderTank then
    HUD.RemoveObjective(self.tInfo.hLoderTank)
    self.tInfo.hLoderTank = nil
  end
end

function P1FP_KillCourtyard01:TASK_ListenForEscalate()
  self:CreateTask({
    sName = "TASK_ListenForEscalate",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = true,
    tOnComplete = {
      {
        self.SetDelaytoReinf,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function P1FP_KillCourtyard01:SetDelaytoReinf()
  Cin.StopConversation("P1FP_KillCourtyard_Speech1")
  Cin.StopConversation("P1FP_KillCourtyard_Speech2")
  Cin.StopConversation("P1FP_KillCourtyard_Speech3")
end

function P1FP_KillCourtyard01:Reinforcements()
end

function P1FP_KillCourtyard01:TASK_GotoCourtyard()
  self:CreateTask({
    sName = "P1FP_KillCourtyard01_TASK_GotoCourtyard",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P1FP_KillCourtyard01_Text.TASK_GotoCourtyard",
    ParentObjectID = -1,
    tDestRegion = {
      self.sPATH .. "task\\REG_Flee"
    },
    tLocators = {
      self.sPATH .. "task\\LOC_Courtyard"
    },
    tDeliverObjs = {
      self.hSab
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 2}
      }
    },
    tSMEDNodes = {
      "Missions\\freeplay\\p1\\mis_sacre_farsouth\\TankBoss"
    }
  })
end

function P1FP_KillCourtyard01:TASK_DontKillThePeeps()
  self:CreateTask({
    sName = "TASK_DontKillThePeeps",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "DEFEND",
    bNoHUDBlip = true,
    bNoFocus = true,
    bNoWorldBlip = true,
    tTgtInclude = self.tInfo.Civs,
    tOnActivate = {},
    tOnComplete = {},
    tOnFailure = {
      {
        Cin.PlayConversation,
        {
          "P1FP_KillCourtyard_KillCiv",
          "P1FP_KillCourtyard01.Fail",
          self
        }
      }
    }
  })
end

function P1FP_KillCourtyard01:TASK_LoseNazis()
  self:CreateTask({
    sName = "TASK_LoseNazis",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "NONE",
    EscalationLevel = 0,
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    ParentObjectID = -1,
    tOnActivate = {},
    tOnComplete = {
      {
        Sound.ResetMusiclocale,
        {}
      },
      {
        Sound.ReleaseSoundBank,
        {
          "m_P1FP_KillCourtyard.bnk"
        }
      },
      {
        self.CompleteThisMission,
        {self}
      }
    }
  })
end

function P1FP_KillCourtyard01:EscalationNow()
  self:CreateTask({
    sName = "EscalationNow",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    bOptional = true,
    bGTE = true,
    EscalationLevel = 1,
    tOnComplete = {
      {
        self.SetDelaytoReinf,
        {self}
      }
    }
  })
end

function P1FP_KillCourtyard01:SetupStreamOutEvent()
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = self.tInfo.Civs,
    WaitForStreamOut = true
  }
  Util.CreateEvent(tStreamEvent, "P1FP_KillCourtyard01.UnloadEffects", self)
end

function P1FP_KillCourtyard01:UnloadEffects()
  Util.UnloadStaticENTag("P1FP_KillCourtyard01_fx", true)
end

function P1FP_KillCourtyard01:StartPanicListeners()
  if Suspicion.GetEscalation() > 0 then
    self:PanicThemCivs()
  else
    EVENT_ActorFiresAnyWeapon("P1FP_KillCourtyard01.PanicThemCivs", self, self.hSab)
    EVENT_ActorDeath("P1FP_KillCourtyard01.PanicThemCivs", self, self.tInfo.sNaziOfficer)
  end
end

function P1FP_KillCourtyard01:PanicThemCivs()
  self:RetreatGeneral()
  if self.tSaveInfo.bSetPanicCivs == false then
    self.tSaveInfo.bSetPanicCivs = true
    for i, Civ in pairs(self.tInfo.Civs) do
      local hCiv = Util.GetHandleByName(Civ)
      if hCiv then
        print("Cancel civ using attr point ", Civ)
        Actor.CancelAttrPt(hCiv)
      end
    end
  end
end

function P1FP_KillCourtyard01:RetreatGeneral()
  local hOfficer = Handle(self.tInfo.sNaziOfficer)
  local hLoc = Handle(self.sPATH .. "main\\LOC_Retreat")
  if not self.tInfo.bRetreating and hOfficer then
    Nav.CancelFollowObject(hOfficer)
    if hLoc then
      print("tethering officer")
      Combat.SetTether(hOfficer, hLoc, 2.5)
    end
    self.tInfo.bRetreating = true
    self:RunGeneral()
  end
end

function P1FP_KillCourtyard01:RunGeneral()
  local hOfficer = Handle(self.tInfo.sNaziOfficer)
  local hLoc = Handle(self.sPATH .. "main\\LOC_Retreat")
  if hOfficer and Object.IsAlive(hOfficer) and hLoc and Object.GetDistance(hOfficer, hLoc) > 3 then
    print("running officer to point")
    Nav.MoveToObject(hOfficer, hLoc, 2, true, "P1FP_KillCourtyard01.RunGeneral", self, {})
  else
  end
end

function P1FP_KillCourtyard01:OfficerSpawned()
  self.hOfficer = Handle(self.tInfo.sNaziOfficer)
  Combat.SetIdleScripted(self.hOfficer, true)
  Nav.SetScriptedPath(self.hOfficer, self.tOfficerPaths[self.nOfficerPath], false, "P1FP_KillCourtyard01.OfficerGetSalute", self)
  Nav.SetScriptedPathType(self.hOfficer, cPATHTYPE_ONCE)
  local tCombatEnter = {
    EventType = "OnCombatEnter",
    Target = self.hOfficer
  }
  self:RegisterEvent(Util.CreateEvent(tCombatEnter, "P1FP_KillCourtyard01.OfficerCombatEnter", self))
end

function P1FP_KillCourtyard01:StartAnnouncementLoop()
  self.nPathNumberRot = self.nPathNumberRot + 1
  if 1 > Suspicion.GetEscalation() then
    if self.nPathNumberRot == 1 then
      Cin.PlayConversation("P1FP_KillCourtyard_Speech1", "P1FP_KillCourtyard01.OfficerGetSalute", self)
    elseif self.nPathNumberRot == 2 then
      Cin.PlayConversation("P1FP_KillCourtyard_Speech2", "P1FP_KillCourtyard01.OfficerGetSalute", self)
    elseif self.nPathNumberRot == 3 then
      Cin.PlayConversation("P1FP_KillCourtyard_Speech3", "P1FP_KillCourtyard01.OfficerGetSalute", self)
    else
      self.nPathNumberRot = 0
      EVENT_Timer("P1FP_KillCourtyard01.StartAnnouncementLoop", self, 1)
    end
  else
  end
end

function P1FP_KillCourtyard01:OfficerGetSalute()
  local hFacingTgt
  local bGotTgt = false
  for i = 1, #self.tSteppers do
    local hEnt = Handle(self.tSteppers[i])
    if hEnt ~= nil and not bGotTgt then
      hFacingTgt = hEnt
      bGotTgt = true
    end
    Actor.CancelAnimation(hEnt)
    self.PlaySalute(self, hEnt)
  end
  EVENT_Timer("P1FP_KillCourtyard01.StartAnnouncementLoop", self, 11)
end

function P1FP_KillCourtyard01:PlaySalute(a_hEntity, a_nOfficerPath, a_nIndex)
  local nHeading = Actor.CalcFacingTo(a_hEntity, self.hOfficer)
  Actor.PlayAnimation(a_hEntity, "nazi_hail", 3.7, false)
end

function P1FP_KillCourtyard01:SaluteBack()
  Actor.PlayAnimation(self.hOfficer, "nazi_hail", 3.7)
end

function P1FP_KillCourtyard01:DoneWithSalute(a_hEntity, a_nOfficerPath, a_nIndex)
  local tGroup = self.tSaluteGroups[a_nOfficerPath]
  local nHeading = Object.GetAngle(Handle(tGroup[a_nIndex][2]))
  Actor.SetFacingDir(a_hEntity, nHeading)
  Actor.PlayAnimation(a_hEntity, tGroup[a_nIndex][3], -1, false, nHeading)
end

function P1FP_KillCourtyard01:OfficerCombatEnter(a_tCallbackData)
  local x, y, z = Object.GetPosition(self.hOfficer)
  self.eWaitEvent = nil
  Actor.CancelAnimation(self.hOfficer)
  Nav.CancelScriptedPath(self.hOfficer)
  Combat.SetTether(self.hOfficer, x, y, z, 20, 15)
  local tCombatExit = {
    EventType = "OnCombatExit",
    Target = self.hOfficer
  }
  self:RegisterEvent(Util.CreateEvent(tCombatExit, "P1FP_KillCourtyard01.OfficerCombatExit", self, {
    x,
    y,
    z
  }))
end

function P1FP_KillCourtyard01:OfficerCombatExit(a_tCallbackData, a_nX, a_nY, a_nZ)
  Combat.SetTether(self.hOfficer, a_nX, a_nY, a_nZ, -1)
  local tCombatEnter = {
    EventType = "OnCombatEnter",
    Target = self.hOfficer
  }
  self:RegisterEvent(Util.CreateEvent(tCombatEnter, "P1FP_KillCourtyard01.OfficerCombatEnter", self))
  self.OfficerPickNewPath(self)
end

function P1FP_KillCourtyard01:OfficerPickNewPath()
  self.nOfficerPath = self.nOfficerPath + 1
  if self.nOfficerPath > 3 then
    self.nOfficerPath = 1
  end
  Nav.SetScriptedPath(self.hOfficer, self.tOfficerPaths[self.nOfficerPath], false, "P1FP_KillCourtyard01.OfficerGetSalute", self)
  Nav.SetScriptedPathType(self.hOfficer, cPATHTYPE_ONCE)
end

function P1FP_KillCourtyard01:PatherSpawned(a_sEntity, a_nTableIndex)
  local hEnt = Handle(a_sEntity)
  local tCombatEnter = {
    EventType = "OnCombatEnter",
    Target = hEnt
  }
  self:RegisterEvent(Util.CreateEvent(tCombatEnter, "P1FP_KillCourtyard01.CombatEnter", self, {hEnt, a_nTableIndex}))
end

function P1FP_KillCourtyard01:CombatEnter(a_tCallbackData, a_hEntity, a_nTableIndex)
  local x, y, z = Object.GetPosition(a_hEntity)
  Nav.CancelScriptedPath(a_hEntity)
  Combat.SetTether(a_hEntity, x, y, z, 20, 15)
  local tCombatExit = {
    EventType = "OnCombatExit",
    Target = a_hEntity
  }
  self:RegisterEvent(Util.CreateEvent(tCombatExit, "P1FP_KillCourtyard01.CombatExit", self, {
    a_hEntity,
    a_nTableIndex,
    x,
    y,
    z
  }))
end

function P1FP_KillCourtyard01:CombatExit(a_tCallbackData, a_hEntity, a_nTableIndex, a_nX, a_nY, a_nZ)
  Combat.SetTether(a_hEntity, a_nX, a_nY, a_nZ, -1)
  Nav.SetScriptedPath(a_hEntity, self.tNaziPaths[a_nTableIndex][1], true)
  Nav.SetScriptedPathType(a_hEntity, self.tNaziPaths[a_nTableIndex][2])
  local tCombatEnter = {
    EventType = "OnCombatEnter",
    Target = a_hEntity
  }
  self:RegisterEvent(Util.CreateEvent(tCombatEnter, "P1FP_KillCourtyard01.CombatEnter", self, {a_hEntity, a_nTableIndex}))
end

function P1FP_KillCourtyard01:SetupProxEvent()
  local hTank = Handle("Missions\\freeplay\\p1\\mis_sacre_farsouth\\TankBoss\\VH_NZ_TK_Flammwagen_01")
  local tProxEvent = {
    EventType = "ProximityEvent",
    ObjectA = self.hSab,
    ObjectB = hTank,
    Proximity = 50,
    Negate = false
  }
  Util.CreateEvent(tProxEvent, "P1FP_KillCourtyard01.CheckSight", self)
end

function P1FP_KillCourtyard01:CheckSight()
  local hTank = Handle("Missions\\freeplay\\p1\\mis_sacre_farsouth\\TankBoss\\VH_NZ_TK_Flammwagen_01")
  if Sensory.CanSee(self.hSab, hTank) then
    Cin.PlayConversation("P1FP_KillCourtyard_SeeOfficer")
  else
    local tTimerEvent = {EventType = "TimerEvent", Time = 1}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_KillCourtyard01.SetupProxEvent", self))
  end
end

function P1FP_KillCourtyard01:Fail()
  self.MissionTaskFail(self, "GenericFail_Text.KILLED_Civilian")
end

function P1FP_KillCourtyard01:FireGroupSpawned(a_sEntity, a_nIndex, a_nSubIndex)
  local hEnt = Handle(a_sEntity)
  local nHeading = Object.GetAngle(Handle(self.tSaluteGroups[a_nIndex][a_nSubIndex][2]))
  Combat.SetIdleScripted(hEnt, true)
  Actor.SetFacingDir(hEnt, nHeading)
  Actor.PlayAnimation(hEnt, self.tSaluteGroups[a_nIndex][a_nSubIndex][3], -1, false, nHeading)
end

function P1FP_KillCourtyard01:StartKubelRounders()
  local hKRounder1 = Handle(self.sKubelRounder1)
  local hKRounder2 = Handle(self.sKubelRounder2)
  self.hKRounder1 = hKRounder1
  self.hKRounder2 = hKRounder2
  Nav.SetScriptedPath(hKRounder1, self.sRounderPath1, false, "P1FP_KillCourtyard01.LoopKubelRounder", self)
  Nav.SetScriptedPathSpeed(hKRounder1, 50)
  Nav.SetScriptedPath(hKRounder2, self.sRounderPath2, false, "P1FP_KillCourtyard01.LoopKubelRounder2", self)
  Nav.SetScriptedPathSpeed(hKRounder2, 50)
end

function P1FP_KillCourtyard01:LoopKubelRounder()
  Nav.SetScriptedPath(self.hKRounder1, self.sRounderPathConnect1, false, "P1FP_KillCourtyard01.LoopKubelRounderConnect", self)
  Nav.SetScriptedPathSpeed(self.hKRounder1, 50)
end

function P1FP_KillCourtyard01:LoopKubelRounderConnect()
  Nav.SetScriptedPath(self.hKRounder1, self.sRounderPath1, false, "P1FP_KillCourtyard01.LoopKubelRounder", self)
  Nav.SetScriptedPathSpeed(self.hKRounder1, 50)
end

function P1FP_KillCourtyard01:LoopKubelRounder2()
  Nav.SetScriptedPath(self.hKRounder2, self.sRounderPathConnect2, false, "P1FP_KillCourtyard01.LoopKubelRounder2Connect", self)
  Nav.SetScriptedPathSpeed(self.hKRounder2, 50)
end

function P1FP_KillCourtyard01:LoopKubelRounder2Connect()
  Nav.SetScriptedPath(self.hKRounder2, self.sRounderPath2, false, "P1FP_KillCourtyard01.LoopKubelRounder2", self)
  Nav.SetScriptedPathSpeed(self.hKRounder2, 50)
end

function P1FP_KillCourtyard01:SpawnTankAndRoll()
  Util.SpawnEditNode("Missions\\freeplay\\p1\\mis_sacre_farsouth\\tankboss.wsd", "P1FP_KillCourtyard01.OnTankSpawns", self)
end

function P1FP_KillCourtyard01:SetTankBar()
  local hTank = Handle("Missions\\freeplay\\p1\\mis_sacre_farsouth\\TankBoss\\VH_NZ_TK_Flammwagen_01")
  self.tInfo.TANKHEALTH = Object.GetHealth(hTank)
  self.tInfo.TANKMAXHEALTH = self.tInfo.TANKHEALTH
  self.tInfo.hLoderTank = HUD.AddObjective(eOT_HEART, self:GetLocalizedText("P1FP_KillCourtyard01_Text.TANKHEALTH"), 2)
  HUD.SetupProgressBar(self.tInfo.hLoderTank, 0, self.tInfo.TANKMAXHEALTH, self.tInfo.TANKHEALTH)
end

function P1FP_KillCourtyard01:OnTankSpawns()
  local hTank = Handle("Missions\\freeplay\\p1\\mis_sacre_farsouth\\TankBoss\\VH_NZ_TK_Flammwagen_01")
  self.hTank = hTank
  local sTankPath = "Missions\\freeplay\\p1\\mis_sacre_farsouth\\TankBoss\\TANKPATH"
  local hTankPilot = Vehicle.GetPilot(hTank)
  self.hTankPilot = hTankPilot
  dprint(self, "TankPilot Handle Set")
  EVENT_ActorExitsAnyVehicle("P1FP_KillCourtyard01.SwitchtoKillGeneral", self, hTankPilot, nil, false)
  EVENT_PlayerEntersVehicleBlueprint("P1FP_KillCourtyard01.SwitchtoKillGeneral", self, "VH_NZ_TK_Flammwagen_01", nil, false)
  self:SetTanktoFight()
end

function P1FP_KillCourtyard01:SwitchtoKillGeneral()
  if self.tInfo.hLoderTank then
    HUD.RemoveObjective(self.tInfo.hLoderTank)
    self.tInfo.hLoderTank = nil
  end
  self:FailTaskByName("P1FP_KillCourtyard01_TASK_MainTask")
  self:TASK_KillGeneral()
end

function P1FP_KillCourtyard01:CheckForLoder()
  if Object.IsAlive(self.hTankPilot) == true then
    self:TASK_KillGeneral()
  else
    self:TASK_LoseNazis()
  end
end

function P1FP_KillCourtyard01:TASK_KillGeneral()
  self:CreateTask({
    sName = "TASK_KillGeneral",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P1FP_KillCourtyard01_Text.TASK_MainTask",
    ParentObjectID = -1,
    tTgtInclude = {
      self.hTankPilot
    },
    tOnActivate = {},
    tOnComplete = {
      {
        Cin.PlayConversation,
        {
          "P1FP_KillCourtyard_KillOfficer"
        }
      },
      {
        self.TASK_LoseNazis,
        {self}
      }
    },
    tOnDamage = {},
    tSMEDNodes = {}
  })
end

function P1FP_KillCourtyard01:CompleteMainTask()
  dprint(self, "General is Dead")
  self:CompleteTaskByName("P1FP_KillCourtyard01_TASK_MainTask")
end

function P1FP_KillCourtyard01:SetTanktoFight()
  Combat.SetTarget(self.hTankPilot, hSab)
end

function P1FP_KillCourtyard01:OnTankDamage()
  self.tInfo.TANKHEALTH = Object.GetHealth(self.hTank)
  HUD.SetProgressBarValue(self.tInfo.hLoderTank, self.tInfo.TANKHEALTH)
end

function P1FP_KillCourtyard01:SetPreTankDeathEvent()
  dprint(self, "Tank Has Streamed")
  local hTank = Handle("Missions\\freeplay\\p1\\mis_sacre_farsouth\\TankBoss\\VH_NZ_TK_Flammwagen_01")
  Vehicle.SetDeathCallback(hTank, "P1FP_KillCourtyard01.OnTankDeath", self)
end

function P1FP_KillCourtyard01:OnTankDeath()
  if self:IsMissionTaskActive("P1FP_KillCourtyard01_TASK_GotoCourtyard") then
    self:FailTaskByName("P1FP_KillCourtyard01_TASK_GotoCourtyard")
  end
  self:ClearHUDBar()
  self:CheckForLoder()
end

function P1FP_KillCourtyard01:CleanDeathCallback()
  dprint(self, "DeathEvent has been cleaned")
  local hTank = Handle("Missions\\freeplay\\p1\\mis_sacre_farsouth\\TankBoss\\VH_NZ_TK_Flammwagen_01")
end

function P1FP_KillCourtyard01:WaitForTankStream()
  local tTankStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      "Missions\\freeplay\\p1\\mis_sacre_farsouth\\TankBoss\\VH_NZ_TK_Flammwagen_01",
      "Missions\\freeplay\\p1\\mis_sacre_farsouth\\tankboss\\Spore_TS_Commander_SH"
    }
  }
  Util.CreateEvent(tTankStreamEvent, "P1FP_KillCourtyard01.SetupTankZStuff", self)
end

function P1FP_KillCourtyard01:SetupTankZStuff()
  local sTSAPC = "Missions\\freeplay\\p1\\mis_sacre_farsouth\\TankBoss\\VH_NZ_TK_Flammwagen_01"
  self.sTSAPC = sTSAPC
  local hTSLoder = Handle(self.sTSLoder)
  self.hTSLoder = hTSLoder
  local hTSAPC = Handle(sTSAPC)
  self.hTSAPC = hTSAPC
  local bInVehicle = Actor.IsInVehicle(hTSLoder)
  if not bInVehicle then
    Actor.BoardVehicle(hTSLoder, hTSAPC, "GUNNER", true)
  end
  local tLoderPreDeath = {EventType = "DeathEvent", ObjectHandle = hTSLoder}
  self.eLodPreDeath = Util.CreateEvent(tLoderPreDeath, "P1FP_KillCourtyard01.OnLoderPreDeath", self)
  self:RegisterEvent(self.eLodPreDeath)
  self:StartAnnouncementLoop()
end

function P1FP_KillCourtyard01:OnLoderPreDeath()
  self:FailTaskByName("P1FP_KillCourtyard01_TASK_GotoCourtyard")
  if Suspicion.GetEscalation() == 0 then
    self:CompleteThisMission()
  else
    self:TASK_LoseNazis()
  end
end

function P1FP_KillCourtyard01:SetFlamers()
  local sStreamFlamers = {
    EventType = "StreamEvent",
    Objects = {
      "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_SS_Flame_FT(4)",
      "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_SS_Flame_FT(6)",
      "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_SS_Flame_FT(2)",
      "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_SS_Flame_FT",
      "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\DummyTarget",
      "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\DummyTarget(2)",
      "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\DummyTarget(4)",
      "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\DummyTarget(8)"
    }
  }
  Util.CreateEvent(sStreamFlamers, "P1FP_KillCourtyard01.OnFlamersStream", self)
end

function P1FP_KillCourtyard01:OnFlamersStream()
  local tFlamers = {
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_SS_Flame_FT(4)",
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_SS_Flame_FT(6)",
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_SS_Flame_FT(2)",
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\Spore_SS_Flame_FT"
  }
  local tBurningPiles = {
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\DummyTarget",
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\DummyTarget(2)",
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\DummyTarget(4)",
    "Missions\\freeplay\\p1\\mis_sacre_farsouth\\main\\DummyTarget(8)"
  }
  for i = 1, #tFlamers do
    local hFlamer = Handle(tFlamers[i])
    local hTarget = Handle(tBurningPiles[i])
    Joe.SetFireAtTarget(hFlamer, hTarget, 10000)
  end
end

function P1FP_KillCourtyard01:MISSION_ONCANCEL()
  if Util.IsCustomTagLoaded("P1FP_KillCourtyard01_fx") then
    Util.UnloadStaticENTag("P1FP_KillCourtyard01_fx", true)
  end
  Vehicle.EnableTraffic(true)
end
