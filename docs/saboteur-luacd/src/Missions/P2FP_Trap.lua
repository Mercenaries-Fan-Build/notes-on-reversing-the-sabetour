if P2FP_Trap == nil then
  P2FP_Trap = SabTaskObjective:Create()
  P2FP_Trap.PATH = "Missions\\freeplay\\p2\\mis_trap\\"
  P2FP_Trap:Configure({
    TaskCount = "auto",
    sSaveMissionNameID = "MissionNames_Text.P2FP_Trap",
    tDependencyList = {},
    tUnlockList = {
      "NOTE_P6M1",
      "Paris_6_Mission_1"
    },
    bFreeplay = true,
    bRepeatable = false,
    sStarter = "Bryman_Market_Exterior",
    sConvFile = "P2FP_Trap_VeroConv",
    tSMEDNodes = {
      P2FP_Trap.PATH .. "main"
    }
  })
end

function P2FP_Trap:STARTER_Setup()
end

function P2FP_Trap:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "P2FP.TRAP"
  self.bDebugMode = true
  self.GENERAL_Setup(self)
  self.SetupCheckpoint(self, 1)
end

function P2FP_Trap:GENERAL_Setup()
  self.sBryman = self.PATH .. "Bryman_Market\\Bryman_Market_Exterior"
  self.NodesLoaded = 0
  self.hAlleyLoc = Util.GetHandleByName(self.PATH .. "main\\LOC_AlleyDest")
  self.hAlleyTrig = Util.GetHandleByName(self.PATH .. "main\\PT_AlleyCenter")
  self.hTruckASpawn = Util.GetHandleByName(self.PATH .. "main\\LOC_TruckA_Spawn")
  self.hTruckADest = Util.GetHandleByName(self.PATH .. "main\\LOC_TruckA_Dest")
  self.hTruckBSpawn = Util.GetHandleByName(self.PATH .. "main\\LOC_TruckB_Spawn")
  self.hTruckBDest = Util.GetHandleByName(self.PATH .. "main\\LOC_TruckB_Dest")
  self.hTruckCSpawn = Util.GetHandleByName(self.PATH .. "main\\LOC_TruckC_Spawn")
  self.hTruckCDest = Util.GetHandleByName(self.PATH .. "main\\LOC_TruckC_Dest")
  self.tHitSquad = {
    "Missions\\freeplay\\p2\\mis_trap\\bryman_ambush\\Spore_SS_Heavy_MG",
    "Missions\\freeplay\\p2\\mis_trap\\bryman_ambush\\Spore_SS_Heavy_MG(1)",
    "Missions\\freeplay\\p2\\mis_trap\\bryman_ambush\\Spore_SS_Heavy_MG",
    "Missions\\freeplay\\p2\\mis_trap\\gestapo\\Gestapo_Officer_PS"
  }
  self:AddOnCancelCallback(P2FP_Trap.Reset)
  self:AddOnCompleteCallback(P2FP_Trap.Reset)
end

function P2FP_Trap:ArmSelf()
  Inventory.GiveItem(hSab, "WP_SH_12GaugePump", false)
  Inventory.GiveItem(hSab, "WP_MG_Thompson_ExtMag", false)
  Inventory.GiveItem(hSab, "WP_SAB_DynamiteFuse", false)
  Inventory.GiveItem(hSab, "WP_SAB_DynamiteFuse", false)
  Inventory.GiveItem(hSab, "WP_SAB_DynamiteFuse", false)
  Inventory.GiveItem(hSab, "WP_SAB_DynamiteFuse", false)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", false)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", false)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", false)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", false)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", false)
  Inventory.GiveItem(hSab, "WP_GR_StickGrenade", false)
end

function P2FP_Trap:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "P2FP_Trap.DoCheckpoint")
end

function P2FP_Trap:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  if nCP == 1 then
    self.hBryman = Handle(self.sBryman)
    Combat.SetIdleScripted(self.hBryman, true)
    Actor.OverrideCombatAI(self.hBryman, true)
    Actor.SetUseHitReactions(self.hBryman, false)
    self:CueGestapo()
    self:SetupFails()
    self:CueMusic()
  elseif nCP == 3 then
  end
end

function P2FP_Trap:SetupFails()
  self.hAbandonEvent = EVENT_PlayerExitsTrigger("P2FP_Trap.FailAbandon", self, "Missions\\freeplay\\p2\\mis_trap\\main\\PT_Abandon")
end

function P2FP_Trap:CueMusic()
  Sound.SetMusicLocale("fp_P2FP_Trap")
  Sound.SetMusicLocale("fp_P2FP_Trap", "meetBryman")
end

function P2FP_Trap:CueGestapo()
  WorldSMEDNodes.LoadNode("Missions\\freeplay\\p2\\mis_trap\\gestapo")
  WorldSMEDNodes.LoadNode("Missions\\freeplay\\p2\\mis_trap\\apc")
  self.sGestapo = "Missions\\freeplay\\p2\\mis_trap\\gestapo\\Gestapo_Officer_PS"
  self.sAPC = "Missions\\freeplay\\p2\\mis_trap\\apc\\VH_NZ_TR_HalfTrack_01"
  EVENT_Stream("P2FP_Trap.InitGestapo", self, self.sGestapo, false)
  EVENT_Stream("P2FP_Trap.APCArrives", self, self.sAPC, false)
end

function P2FP_Trap:InitGestapo()
  self.hGestapo = Handle(self.sGestapo)
  Actor.OverrideCombatAI(self.hGestapo, true)
  local tExitSequence = {
    {
      "SETIDLESCRIPTED",
      {true}
    },
    {
      "RUNTOOBJECT",
      {
        "Missions\\freeplay\\p2\\mis_trap\\main\\LOC_GestapoRunsHere",
        0
      }
    },
    {
      "PLAYANIMATION",
      {
        "alarm_whistle"
      }
    }
  }
  ScriptSequence.Run(self.hGestapo, tExitSequence, P2FP_Trap.GestapoFights, {self})
  Suspicion.EnableEscalationVehicles(false)
  Suspicion.SetEscalated()
  self:BrymanDefends()
  self:TASK_DefendBryman()
end

function P2FP_Trap:GestapoFights()
  Combat.SetIdleScripted(self.hGestapo, false)
  Actor.OverrideCombatAI(self.hGestapo, false)
  Combat.SetObjective(self.hGestapo, self.hBryman, true, 10, false)
  Combat.AddTargetFlag(self.hGestapo, cTARGET_ENEMYLIST, {
    {
      self.hBryman,
      1
    },
    {hSab, 10000}
  })
end

function P2FP_Trap:BrymanDefends()
  Combat.SetIdleScripted(self.hBryman, false)
  Actor.OverrideCombatAI(self.hBryman, false)
  Combat.SetObjective(self.hBryman, Handle("Missions\\freeplay\\p2\\mis_trap\\main\\LOC_BrymanCowers"), true, 3, false)
end

function P2FP_Trap:BlipBryman()
  HUD.SetObjectiveMarker(self.hBryman, cMMI_MissionGiver, cOM_MissionGiver, true, true, true)
end

function P2FP_Trap:APCArrives()
  self.hAPC = Handle("Missions\\freeplay\\p2\\mis_trap\\apc\\VH_NZ_TR_HalfTrack_01")
  self:GoFirstTS()
  Nav.SetScriptedPath(self.hAPC, "Missions\\freeplay\\p2\\mis_trap\\main\\PATH_APCarrives", true, "P2FP_Trap.UnloadAPC", self)
  Nav.SetScriptedPathSpeed(self.hAPC, 40)
end

function P2FP_Trap:UnloadAPC()
  Vehicle.UnboardAll(self.hAPC, false, "P2FP_Trap.APCUnloaded", self, {}, nil, nil, nil)
end

function P2FP_Trap:APCUnloaded(a_hAPCguy)
  local hGuy = a_hAPCguy[1]
  table.insert(self.tHitSquad, hGuy)
  Combat.SetObjective(hGuy, self.hBryman, true, 10, false)
  Combat.AddTargetFlag(hGuy, cTARGET_ENEMYLIST, {
    {
      self.hBryman,
      1
    },
    {hSab, 10000}
  })
end

function P2FP_Trap:GoFirstTS()
  self.tHandleTS1 = {}
  self.tHandleTS1[1] = Handle("Missions\\freeplay\\p2\\mis_trap\\apc\\Spore_SS_Heavy_MG")
  self.tHandleTS1[2] = Handle("Missions\\freeplay\\p2\\mis_trap\\apc\\Spore_SS_Heavy_MG_1")
  self.tHandleTS1[3] = Handle("Missions\\freeplay\\p2\\mis_trap\\apc\\Spore_SS_Heavy_MG_2")
  self.tHandleTS1[4] = Handle("Missions\\freeplay\\p2\\mis_trap\\apc\\Spore_SS_Heavy_MG_3")
  for i, v in ipairs(self.tHandleTS1) do
    local hGuy = self.tHandleTS1[i]
    Combat.SetObjective(hGuy, self.hBryman, true, 10, false)
    Combat.AddTargetFlag(hGuy, cTARGET_ENEMYLIST, {
      {
        self.hBryman,
        1
      },
      {hSab, 10000}
    })
  end
end

function P2FP_Trap:TASK_DefendBryman()
  self:CreateTask({
    sName = "TASK_DefendBryman",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "DEFEND",
    sObjectiveTextID = "P2FP_Trap_Text.TASK_DefendBryman",
    VictoryTimer = 20,
    tTgtInclude = {
      "Missions\\freeplay\\p2\\mis_trap\\bryman_market\\Bryman_Market_Exterior"
    },
    tOnActivate = {
      {
        Cin.PlayConversation,
        {
          "P2FP_Trap_Ambushed"
        }
      },
      {
        EVENT_Timer,
        {
          "P2FP_Trap.PrintHealth",
          self,
          1
        }
      },
      {
        self.SetupHealthBar,
        {self}
      }
    },
    tOnComplete = {
      {
        self.Task_FollowBryman,
        {self}
      }
    },
    tOnCancel = {},
    tOnFailure = {}
  })
end

function P2FP_Trap:PrintHealth()
  dprint(self, "BRYMAN HEALTH: " .. Object.GetHealth(self.hBryman))
  if Object.IsAlive(self.hBryman) then
    EVENT_Timer("P2FP_Trap.PrintHealth", self, 0.5)
  end
end

function P2FP_Trap:Task_FollowBryman()
  self:CreateTask({
    sName = "Task_FollowBryman",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P2FP_Trap_Text.Task_FollowBryman",
    tDestRegion = "Missions\\freeplay\\p2\\mis_trap\\main\\PT_Escape1",
    tDeliverObjs = {
      self.hBryman
    },
    tOnActivate = {
      {
        self.RunBryman,
        {self}
      },
      {
        self.LoadAmbush2,
        {self}
      },
      {
        Cin.PlayConversation,
        {
          "P2FP_Trap_FollowBryman"
        }
      }
    },
    tOnComplete = {
      {
        self.TASK_TalkToBrymanAgain,
        {self}
      }
    }
  })
end

function P2FP_Trap:RunBryman()
  Combat.SetIdleScripted(self.hBryman, true)
  Actor.OverrideCombatAI(self.hBryman, true)
  Nav.SetScriptedPath(self.hBryman, "Missions\\freeplay\\p2\\mis_trap\\main\\PATH_AttemptEscape1", false, "P2FP_Trap.BrymanTurns", self)
  Nav.SetScriptedPathMoveMode(self.hBryman, true)
end

function P2FP_Trap:BrymanTurns()
  dprint(self, "Bryman Turns around now")
  Cin.PlayConversation("P2FP_Trap_DeadEnd")
  Nav.SetScriptedPath(self.hBryman, "Missions\\freeplay\\p2\\mis_trap\\main\\PATH_AttemptEscape2", false, "P2FP_Trap.BrymanStops", self)
  Nav.SetScriptedPathMoveMode(self.hBryman, true)
end

function P2FP_Trap:BrymanStops()
  dprint(self, "Bryman is ready to talk to you")
end

function P2FP_Trap:LoadAmbush2()
  WorldSMEDNodes.LoadNode("Missions\\freeplay\\p2\\mis_trap\\Bryman_Ambush", "P2FP_Trap.GoAmbush2", self)
end

function P2FP_Trap:GoAmbush2()
  self.hKubel = Handle("Missions\\freeplay\\p2\\mis_trap\\bryman_ambush\\VH_NZ_CR_Kubelwagen_01")
  local hKubelDest = Handle("Missions\\freeplay\\p2\\mis_trap\\main\\LOC_KubelAmbush")
  Nav.MoveToObject(self.hKubel, hKubelDest, 1, true, "P2FP_Trap.UnloadKubel", self, nil)
  Combat.SetObjective(Handle("Missions\\freeplay\\p2\\mis_trap\\bryman_ambush\\Spore_SS_Heavy_MG"), self.hBryman, true, 10, false)
  Combat.SetObjective(Handle("Missions\\freeplay\\p2\\mis_trap\\bryman_ambush\\Spore_SS_Heavy_MG(1)"), self.hBryman, true, 10, false)
  Combat.SetObjective(Handle("Missions\\freeplay\\p2\\mis_trap\\bryman_ambush\\Spore_SS_Heavy_MG(2)"), self.hBryman, true, 10, false)
  Combat.AddTargetFlag(Handle("Missions\\freeplay\\p2\\mis_trap\\bryman_ambush\\Spore_SS_Heavy_MG"), cTARGET_ENEMYLIST, {
    {
      self.hBryman,
      1
    },
    {hSab, 10000}
  })
  Combat.AddTargetFlag(Handle("Missions\\freeplay\\p2\\mis_trap\\bryman_ambush\\Spore_SS_Heavy_MG(1)"), cTARGET_ENEMYLIST, {
    {
      self.hBryman,
      1
    },
    {hSab, 10000}
  })
  Combat.AddTargetFlag(Handle("Missions\\freeplay\\p2\\mis_trap\\bryman_ambush\\Spore_SS_Heavy_MG(2)"), cTARGET_ENEMYLIST, {
    {
      self.hBryman,
      1
    },
    {hSab, 10000}
  })
end

function P2FP_Trap:UnloadKubel()
  Vehicle.UnboardAll(self.hKubel, false, "P2FP_Trap.KubelUnloaded", self, {}, nil, nil, nil)
end

function P2FP_Trap:KubelUnloaded(a_hAPCguy)
  local hGuy = a_hAPCguy[1]
  table.insert(self.tHitSquad, hGuy)
  Combat.SetObjective(hGuy, self.hBryman, true, 10, false)
  Combat.AddTargetFlag(hGuy, cTARGET_ENEMYLIST, {
    {
      self.hBryman,
      1
    },
    {hSab, 10000}
  })
end

function P2FP_Trap:TASK_TalkToBrymanAgain()
  self:CreateTask({
    sName = "P2FP_Trap.TASK_TalkToBrymanAgain",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    bAutofire = true,
    Proximity = 2,
    sConvFile = "P2FP_Trap_SplitUp",
    sObjectiveTextID = "P2FP_Trap_Text.TASK_TalkToBrymanAgain",
    tTgtInclude = {
      self.sBryman
    },
    tOnActivate = {
      {
        self.ClearBrymanEvents,
        {self}
      }
    },
    tOnConversationComplete = {
      {
        Util.KillEvent,
        {
          self.hAbandonEvent
        }
      },
      {
        self.LoadResEscape,
        {self}
      },
      {
        self.TASK_DefendBryman2,
        {self}
      }
    }
  })
end

function P2FP_Trap:BrymanFollows()
end

function P2FP_Trap:FreezeNazis()
  for i, v in ipairs(self.tHitSquad) do
    local hNazi = Handle(v)
    if hNazi then
      Actor.OverrideCombatAI(hNazi, true)
      Nav.StopMoving(hNazi)
    end
  end
end

function P2FP_Trap:RestartNazis()
  for i, v in ipairs(self.tHitSquad) do
    local hNazi = Handle(v)
    if hNazi then
      Actor.OverrideCombatAI(hNazi, false)
      Combat.SetObjective(hNazi, self.hBryman, true, 10)
      Combat.AddTargetFlag(hNazi, cTARGET_ENEMYLIST, {
        {
          self.hBryman,
          1
        },
        {hSab, 10000}
      })
    end
  end
end

function P2FP_Trap:ClearBrymanEvents()
  Combat.ClearLeader(Handle(self.sBryman))
  Util.KillEvent(self.hAbandonEvent)
end

function P2FP_Trap:LoadResEscape()
  WorldSMEDNodes.LoadNode("Missions\\freeplay\\p2\\mis_trap\\res_getaway")
  EVENT_Stream("P2FP_Trap.GoResGetaway", self, "Missions\\freeplay\\p2\\mis_trap\\res_getaway\\VH_CV_CR_Citroen7C_01", false)
end

function P2FP_Trap:GoResGetaway()
  self.hResGetaway = Handle("Missions\\freeplay\\p2\\mis_trap\\res_getaway\\VH_CV_CR_Citroen7C_01")
  Util.UnloadEditNode("Missions\\freeplay\\p2\\mis_trap\\bryman_market.wsd", false, true)
  Util.UnloadEditNode("Missions\\freeplay\\p2\\mis_trap\\res_getaway.wsd", false, true)
  EVENT_Timer("P2FP_Trap.GodDriver", self, 2)
  Vehicle.LockAllSeats(self.hResGetaway, true)
  EVENT_ActorDeath("P2FP_Trap.GetawayCarFail", self, self.hResGetaway)
  Nav.SetScriptedPath(self.hResGetaway, "Missions\\freeplay\\p2\\mis_trap\\main\\PATH_ResEscapeIn", false)
  Nav.SetScriptedPathSpeed(self.hResGetaway, 40)
  Nav.BoardVehicle(self.hBryman, self.hResGetaway, "SHOTGUN", cMOVE_PANIC, "P2FP_Trap.BrymanInCar", self)
end

function P2FP_Trap:GodDriver()
  local hCar = Handle("Missions\\freeplay\\p2\\mis_trap\\res_getaway\\VH_CV_CR_Citroen7C_01")
  local hDriver = Vehicle.GetPilot(hCar)
  Object.SetInvincibleToAI(hDriver, true)
end

function P2FP_Trap:BrymanInCar()
  Nav.SetScriptedPath(self.hResGetaway, "Missions\\freeplay\\p2\\mis_trap\\main\\PATH_ResEscapeOut", false, "P2FP_Trap.BrymanAway", self)
  Nav.SetScriptedPathSpeed(self.hResGetaway, 90)
end

function P2FP_Trap:BrymanAway()
  Object.SetInvincibleToAI(Handle(self.sBryman), true)
  self:CompleteThisMission()
end

function P2FP_Trap:TASK_DefendBryman2()
  Util.SetDynamicPriority("VH_CV_CR_CeltaQuatre_01", 1500)
  self:CreateTask({
    sName = "TASK_DefendBryman2",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "DEFEND",
    sObjectiveTextID = "P2FP_Trap_Text.TASK_DefendBryman2",
    tTgtInclude = {
      "Missions\\freeplay\\p2\\mis_trap\\bryman_market\\Bryman_Market_Exterior"
    },
    tSMEDNodes = {
      P2FP_Trap.PATH .. "reinforcements"
    },
    tOnActivate = {
      {
        EVENT_Timer,
        {
          "P2FP_Trap.DelayActivateTraffic",
          self,
          15
        }
      }
    },
    tOnComplete = {},
    tOnCancel = {},
    tOnFailure = {}
  })
end

function P2FP_Trap:SetupHealthBar()
  self.nCurrentHealth = Object.GetHealth(self.hBryman)
  self.TempObjectiveID = HUD.AddObjective(eOT_HEART, SabTask:GetLocalizedText("GenericObjective_Text.BAR_Health"), 2, nil)
  HUD.SetupProgressBar(self.TempObjectiveID, 0, self.nCurrentHealth, self.nCurrentHealth)
  EVENT_ActorDamaged("P2FP_Trap.UpdateHealthBar", self, self.hBryman, {}, true)
end

function P2FP_Trap:UpdateHealthBar()
  self.nCurrentHealth = Object.GetHealth(self.hBryman)
  HUD.SetProgressBarValue(self.TempObjectiveID, self.nCurrentHealth)
  self.nSelfCounter = EVENT_Timer("P2FP_Trap.UpdateHealthBar", self, 2)
end

function P2FP_Trap:DelayActivateTraffic()
  Suspicion.EnableEscalationVehicles(true)
end

function P2FP_Trap:FailAbandon()
  self:MissionTaskFail("P2FP_Trap_Text.FAIL_Abandon")
end

function P2FP_Trap:GetawayCarFail()
  self:MissionTaskFail("P2FP_Trap_Text.FAIL_Car")
end

function P2FP_Trap:Reset()
  Sound.ResetMusicLocale()
  HUD.RemoveObjectiveMarker(self.hBryman)
  local hGetAwayCar = Handle("Missions\\freeplay\\p2\\mis_trap\\res_getaway\\VH_CV_CR_Citroen7C_01")
  Vehicle.AddToTraffic(hGetAwayCar)
  WorldSMEDNodes.UnloadNode("Missions\\freeplay\\p2\\mis_trap\\Bryman_Ambush", true)
  WorldSMEDNodes.UnloadNode("Missions\\freeplay\\p2\\mis_trap\\gestapo", true)
  WorldSMEDNodes.UnloadNode("Missions\\freeplay\\p2\\mis_trap\\apc", true)
end

function P2FP_Trap:MISSION_ONRESET()
  Util.SetDynamicPriority("VH_CV_CR_CeltaQuatre_01", -1)
end
