if P3FP_OKCorral == nil then
  P3FP_OKCorral = SabTaskObjective:Create()
  gsP3FPOK = "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\"
  P3FP_OKCorral:Configure({
    TaskCount = 999,
    tDependencyList = {},
    tUnlockList = {},
    bEscalationDenial = true,
    sConvFile = "P3FP_OkCorral_Start",
    sStarter = "Duval_ext_ind",
    bFreeplay = true,
    sSaveMissionNameID = "MissionNames_Text.P3FP_OkCorral",
    sActNameID = "MissionNames_Text.ACT_Duval",
    tSMEDNodes = {
      gsP3FPOK .. "main",
      gsP3FPOK .. "resistance",
      gsP3FPOK .. "nazis"
    },
    tStaticTags = {
      "hotelinvalideseast_kill",
      "p3fp_okcorral_pfx"
    }
  })
end

function P3FP_OKCorral:STARTER_Setup()
end

function P3FP_OKCorral:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self:RegisterCheckpoint("P3FP_OKCorral.Checkpoint1")
end

function P3FP_OKCorral.SetupGamepadListener()
  local self = P3FP_OKCorral
  self.tControllerEvent = {
    EventType = "OnButtonPress",
    Target = Handle("Saboteur")
  }
  local eButtonEvent = Util.CreateEvent(self.tControllerEvent, "P3FP_OKCorral.OnButtonPress", self, {}, true)
  self:RegisterEvent(eButtonEvent)
end

function P3FP_OKCorral:OnButtonPress(a_tButtonData)
  local self = P3FP_OKCorral
  local tButtons = a_tButtonData[1]
  if tButtons.UP == true then
  elseif tButtons.DOWN == true then
  elseif tButtons.X == true then
  elseif tButtons.B == true then
  end
end

function P3FP_OKCorral:GENERAL_Setup()
  self.ResRenault1 = gsP3FPOK .. "resistance\\VH_CV_CR_RenaultvivaGS_01"
  self.ResRenault2 = gsP3FPOK .. "resistance\\VH_CV_CR_RenaultvivaGS_01_2"
  self.ResTruck1 = gsP3FPOK .. "resistance\\VH_CV_TR_Citroentype45_01"
  self.sBurnTruck = gsP3FPOK .. "resistance\\BURN_TR_Citroentype45_01"
  self.tInfo.tVehicles = {
    gsP3FPOK .. "resistance\\VH_CV_CR_RenaultvivaGS_01",
    gsP3FPOK .. "resistance\\VH_CV_CR_RenaultvivaGS_01_2",
    gsP3FPOK .. "resistance\\VH_CV_TR_Citroentype45_01",
    gsP3FPOK .. "resistance\\BURN_TR_Citroentype45_01",
    gsP3FPOK .. "nazis\\VH_NZ_TR_OpelCanvas_01",
    gsP3FPOK .. "nazis\\VH_NZ_TR_OpelCanvas_01(1)",
    gsP3FPOK .. "nazis\\VH_NZ_TR_OpelCanvas_01(2)"
  }
  self.tInfo.Combatants = {
    gsP3FPOK .. "snipers\\SS_Sniper_RF_000",
    gsP3FPOK .. "snipers\\SS_Sniper_RF_00",
    gsP3FPOK .. "snipers\\SS_Sniper_RF_01",
    gsP3FPOK .. "snipers\\SS_Sniper_RF_05",
    gsP3FPOK .. "nazis\\SS_Grunt_MG_01",
    gsP3FPOK .. "nazis\\SS_Grunt_MG_02",
    gsP3FPOK .. "resistance\\RS_Civilian_MG_01",
    gsP3FPOK .. "resistance\\RS_Civilian_MG_02",
    gsP3FPOK .. "resistance\\RS_Civilian_MG_03",
    gsP3FPOK .. "resistance\\RS_Civilian_MG_04",
    gsP3FPOK .. "resistance\\RS_Civilian_MG_05"
  }
  self.tInfo.NaziSquad = {
    gsP3FPOK .. "snipers\\SS_Sniper_RF_000",
    gsP3FPOK .. "snipers\\SS_Sniper_RF_00",
    gsP3FPOK .. "snipers\\SS_Sniper_RF_01",
    gsP3FPOK .. "snipers\\SS_Sniper_RF_05",
    gsP3FPOK .. "nazis\\SS_Grunt_MG_01",
    gsP3FPOK .. "nazis\\SS_Grunt_MG_02",
    gsP3FPOK .. "nazis\\SS_Grunt_MG_03"
  }
  self.tInfo.ResSquad = {
    gsP3FPOK .. "resistance\\RS_Civilian_MG_01",
    gsP3FPOK .. "resistance\\RS_Civilian_MG_02",
    gsP3FPOK .. "resistance\\RS_Civilian_MG_03",
    gsP3FPOK .. "resistance\\RS_Civilian_MG_04",
    gsP3FPOK .. "resistance\\RS_Civilian_MG_05"
  }
  self.tInfo.tKillSnipers = {
    gsP3FPOK .. "snipers\\SS_Sniper_RF_000",
    gsP3FPOK .. "snipers\\SS_Sniper_RF_00",
    gsP3FPOK .. "snipers\\SS_Sniper_RF_01",
    gsP3FPOK .. "snipers\\SS_Sniper_RF_05"
  }
  self.ClownCar = gsP3FPOK .. "clowncar\\RenaultvivaGS_ClownCar"
  self:AddOnCancelCallback(P3FP_OKCorral.My_Cancel)
  self:AddOnCompleteCallback(P3FP_OKCorral.Complete)
end

function P3FP_OKCorral:Sound1()
  Sound.SetMusicLocale("fp_P3FP_OKCorral")
  Sound.SetMusicLocale("fp_P3FP_OKCorral", "meetContact")
end

function P3FP_OKCorral:Sound2()
  Sound.SetMusicLocale("fp_P3FP_OKCorral")
  Sound.SetMusicLocale("fp_P3FP_OKCorral", "killTarget")
end

function P3FP_OKCorral:Checkpoint1()
  dprint(self, "Registered: CHECKPOINT 1")
  self.TASK_TalkCommander(self)
  self:Task_ExitHQ()
end

function P3FP_OKCorral:StartCombat()
  self.SetupSquad(self)
  self.Setup_ClownCar(self)
end

function P3FP_OKCorral:Task_ExitHQ()
  self:CreateTask({
    sName = "P3FP_OKCorral.Task_ExitHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "Catacombs",
    bInteriorTask = true,
    bNoGPS = true,
    MarkerHeight = 2.5,
    tLocators = {},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "P3FP_OKCorral.Checkpoint2"
        }
      }
    }
  })
end

function P3FP_OKCorral:Checkpoint2()
  dprint(self, "Registered: CHECKPOINT 2")
  EVENT_Stream("P3FP_OKCorral.StartCombat", self, self.tInfo.Combatants, false)
  EVENT_Stream("P3FP_OKCorral.TruckFire", self, self.sBurnTruck, true)
  EVENT_Stream("P3FP_OKCorral.VehiclesIn", self, self.tInfo.tVehicles, true)
  EVENT_Stream("P3FP_OKCorral.DontFlip", self, "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\resistance\\VH_CV_CR_RenaultvivaGS_01_2(2)", true)
  self.eContactDamaged = EVENT_ActorDamaged("P3FP_OKCorral.PlayerKilledContact", self, "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\resistance\\RS_Commander", {}, true)
  self.eContactDead = EVENT_ActorDeath("P3FP_OKCorral.ResContactDead", self, "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\resistance\\RS_Commander")
  if not self:IsMissionTaskActive("P3FP_OKCorral.TASK_TalkCommander") then
    self.TASK_TalkCommander(self)
  end
  self.tInfo.ContactTotalDamage = 0
end

function P3FP_OKCorral:TruckFire()
end

function P3FP_OKCorral:DontFlip()
end

function P3FP_OKCorral:VehiclesIn()
  Util.SetDynamicPriority("VH_CV_TR_Citroentype45_01", 500)
  Util.SetDynamicPriority("VH_CV_CR_RenaultvivaGS_01", 500)
  Util.SetDynamicPriority("VH_NZ_TR_OpelCanvas_01", 500)
end

function P3FP_OKCorral:TASK_TalkCommander()
  self:CreateTask({
    sName = "TASK_TalkCommander",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sObjectiveTextID = "P3FP_OKCorral_Text.TASK_TalkCommander",
    bWorldBlip = true,
    bHUDBlip = true,
    Proximity = 12,
    tTgtInclude = {
      "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\resistance\\RS_Commander"
    },
    vGPSTarget = "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\LOC_ResContact",
    sConvFile = "P3FP_OkCorral_Meetup",
    tSMEDNodes = {},
    tOnActivate = {
      {
        HUD.SetEnableAllGPSEdgesInTrigger,
        {
          "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\PT_NoGPS",
          false
        }
      }
    },
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "P3FP_OKCorral.Checkpoint3"
        }
      },
      {
        Object.Kill,
        {
          Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\resistance\\VH_CV_CR_RenaultvivaGS_01_2(2)")
        }
      },
      {
        EVENT_Timer,
        {
          "P3FP_OKCorral.StopGateBurnTruck",
          self,
          10
        }
      }
    }
  })
end

function P3FP_OKCorral:Checkpoint3()
  self:GoCoDSpawner()
  Util.KillEvent(self.eContactDead)
  self.hResOfficer = Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\resistance\\RS_Commander")
  local hObjective = Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\LOC_Goto")
  Combat.SetObjective(self.hResOfficer, hObjective, true, 15, false)
  self.UnloadSidewalks(self)
  Suspicion.SetEscalationLevel(2)
  Vehicle.EnableTraffic(false, true)
  local tSeeLoc = {
    EventType = "SeeLocatorEvent",
    InViewTime = 1,
    Locator = "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\LOC_SeeBurnTruck",
    Proximity = 30
  }
  self:RegisterEvent(Util.CreateEvent(tSeeLoc, "P3FP_OKCorral.SeeBurnTruck", self))
  EVENT_PlayerToActorProximity("P3FP_OKCorral.VOResChatter", self, "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\LOC_VO_ResChatter", 10)
  EVENT_PlayerToActorProximity("P3FP_OKCorral.VONaziTip", self, "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\LOC_VO_NaziTip", 10)
  WorldSMEDNodes.LoadNode("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\snipers", "P3FP_OKCorral.TASK_KillSnipers", self, {})
end

function P3FP_OKCorral:SeeBurnTruck()
  Object.Kill(Handle(self.sBurnTruck))
  EVENT_Timer("P3FP_OKCorral.StopBurnTruck", self, 10)
end

function P3FP_OKCorral:StopBurnTruck()
  Util.UnloadStaticENTag("p3fp_okcorral_pfx", true)
end

function P3FP_OKCorral:StopGateBurnTruck()
  Util.UnloadStaticENTag("p3fp_okcorral_pfx_gate", true)
end

function P3FP_OKCorral:VOResDies()
  Cin.PlayConversationWith("P3FP_OkCorral_ResistanceDies", {
    Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\LOC_VO_ResDies")
  })
end

function P3FP_OKCorral:VONaziReinforce()
  Cin.PlayConversationWith("P3FP_OkCorral_NaziReinforments", {
    Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\LOC_VO_NaziReinforce")
  })
end

function P3FP_OKCorral:VOResChatter()
  Cin.PlayConversationWith("P3FP_OkCorral_ResistanceChatter", {
    Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\LOC_VO_ResChatter")
  })
end

function P3FP_OKCorral:VONaziTip()
  Cin.PlayConversationWith("P3FP_OkCorral_TargetTip", {
    Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\LOC_VO_NaziTip")
  })
end

function P3FP_OKCorral:UnloadSidewalks()
  Util.UnloadStaticENTag("p3fp_okcorral_sidewalks", true)
  Util.EnableSidewalksInRegion(false, "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\PT_KillSidewalks")
end

function P3FP_OKCorral:LoadTraffic()
  Vehicle.EnableTraffic(true)
  Util.LoadStaticENTag("p3fp_okcorral_sidewalks", true)
  Util.EnableSidewalksInRegion(true, "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\PT_KillSidewalks")
  Suspicion.EnableEscalationVehicles(true)
end

function P3FP_OKCorral:TASK_KillSnipers()
  self:CreateTask({
    sName = "P3FP_OKCorral.TASK_KillSnipers",
    sTaskType = "SabTaskObjectiveDestroy",
    sObjectiveTextID = "P3FP_OKCorral_Text.TASK_KillSnipers",
    sTaskSubType = "KILL",
    tTgtInclude = self.tInfo.tKillSnipers,
    tOnActivate = {
      {
        self.NaziBackup,
        {self}
      }
    },
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "P3FP_OKCorral.Checkpoint4"
        }
      }
    }
  })
end

function P3FP_OKCorral:Checkpoint4()
  dprint(self, "Registered: CHECKPOINT 4")
  self:Sound2()
  Suspicion.SetEscalationLevel(2)
  self.hCoDSpawner = Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\CoDSpawner")
  Object.EnableSpawner(self.hCoDSpawner, true)
  EVENT_PlayerToActorProximity("P3FP_OKCorral.VOResDies", self, "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\LOC_VO_ResDies", 10)
  EVENT_PlayerToActorProximity("P3FP_OKCorral.VONaziReinforce", self, "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\LOC_VO_NaziReinforce", 10)
  self:ResCharge()
  Cin.AllowAttackingDuringCinematics(true)
  self.SSOfficerCin(self)
end

function P3FP_OKCorral:GoCoDSpawner()
  self.hCoDSpawner = Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\CoDSpawner")
  Object.EnableSpawner(self.hCoDSpawner, true)
end

function P3FP_OKCorral:ResCharge()
  local hObjective = Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\LOC_ResWave2_Obj")
  for i, v in pairs(self.tInfo.ResSquad) do
    local hDude = Util.GetHandleByName(v)
    if hDude and Object.IsAlive(hDude) then
      Combat.SetObjective(hDude, hObjective, true, 15, false)
    end
  end
  if Object.IsAlive(self.hResOfficer) then
    Combat.SetObjective(self.hResOfficer, hObjective, true, 15, false)
  end
  dprint(self, "...>>>> RESISTANCE CHARGES THE COURTYARD!!!!")
end

function P3FP_OKCorral:SSOfficerCin()
  self:CreateTask({
    sName = "P3FP_OKCorral.SSOfficerCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "CIN_OKCorral_SSOfficer",
    tSMEDNodes = {
      gsP3FPOK .. "target"
    },
    tStaticTags = {},
    tOnActivate = {
      {
        self.BeginSSOfficerCin,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TASK_Assassination,
        {self}
      },
      {
        Util.LoadStaticENTag,
        {
          "p3fp_okcorral_closetfence",
          true
        }
      }
    }
  })
end

function P3FP_OKCorral:BeginSSOfficerCin()
  EVENT_Stream("P3FP_OKCorral.DoorReady", self, "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\target\\Target", true)
  local hChokePoint = Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\LOC_ChokePoint")
  local hGruntMG_1 = Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\nazis\\Spore_SS_Grunt_MG_1")
  local hGruntMG_2 = Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\nazis\\Spore_SS_Grunt_MG_2")
  local hGruntMG_3 = Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\nazis\\Spore_SS_Grunt_MG_3")
  local hGruntMG_4 = Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\nazis\\Spore_SS_Grunt_MG_4")
  Combat.SetObjective(hGruntMG_1, hChokePoint, true, 15, false)
  Combat.SetObjective(hGruntMG_2, hChokePoint, true, 15, false)
  Combat.SetObjective(hGruntMG_3, hChokePoint, true, 15, false)
  Combat.SetObjective(hGruntMG_4, hChokePoint, true, 15, false)
end

function P3FP_OKCorral:DoorReady()
  self.tInfo.Target = Handle(gsP3FPOK .. "target\\Target")
  self.hDoorAP = Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\SwingingDoorRight")
  AttractionPt.EnableUse(self.hDoorAP, true)
  self.hCoverAP = Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\AttractionPT_CowerForever")
  local tExitSequence = {
    {
      "SETIDLESCRIPTED",
      {true}
    },
    {
      "USEATTRPT",
      {
        self.hDoorAP
      }
    },
    {
      "DELAY",
      {0.25}
    },
    {
      "RUNTOOBJECT",
      {
        "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\LOC_SSOfficerExit",
        0
      }
    }
  }
  ScriptSequence.Run(self.tInfo.Target, tExitSequence, P3FP_OKCorral.DummyShoot, {self})
end

function P3FP_OKCorral:DummyShoot()
  local hTarget = Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\DummyTarget")
  Combat.SetReactImmediately(self.tInfo.Target, true)
  Combat.SetAimAndHitNoMiss(self.tInfo.Target, true)
  Combat.SetRespondToEvents(self.tInfo.Target, false)
  Combat.SetAlwaysSeeTarget(self.tInfo.Target, true)
  Combat.SetStationary(self.tInfo.Target, true)
  Combat.LockIntoRanged(self.tInfo.Target)
  Combat.SetTarget(self.tInfo.Target, hTarget)
  Combat.SetLethalForce(self.tInfo.Target, true)
  Combat.SetCombat(self.tInfo.Target)
  EVENT_Timer("P3FP_OKCorral.ReleaseTarget", self, 10)
  Object.Actuate(Handle("PARIS\\area05\\hoteldesinvalides\\freeplay-ok_corral\\SS_Club_Ped_Door"))
end

function P3FP_OKCorral:ReleaseTarget()
  Combat.SetReactImmediately(self.tInfo.Target, false)
  Combat.SetAimAndHitNoMiss(self.tInfo.Target, false)
  Combat.SetRespondToEvents(self.tInfo.Target, true)
  Combat.SetAlwaysSeeTarget(self.tInfo.Target, false)
  Combat.ClearTargetFlags(self.tInfo.Target)
  Combat.SetIdleScripted(self.tInfo.Target, false)
end

function P3FP_OKCorral:TASK_Assassination()
  self:CreateTask({
    sName = "P3FP_OKCorral_TASK_Assassination",
    sTaskType = "SabTaskObjectiveDestroy",
    sObjectiveTextID = "P3FP_OKCorral_Text.TASK_Assassination",
    sTaskSubType = "Kill",
    bWorldBlip = true,
    tTgtInclude = {
      self.tInfo.Target
    },
    tOnActivate = {},
    tOnComplete = {
      {
        self.WTF_Test,
        {self}
      }
    }
  })
end

function P3FP_OKCorral:WTF_Test()
  if Cin.IsPlayerCloseToCinematic("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\LOC_SSOfficerExit") then
    self:WTFswitch()
  else
    self:WTFswitchFar()
  end
end

function P3FP_OKCorral:WTFswitch()
  self:CreateTask({
    sName = "Task_WTFCutscene",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "WTF_FP_OKCoral",
    tCinematicNodes = {
      "wtf_fp_okcoral"
    },
    tOnComplete = {
      {
        self.TASK_EscapeEscalation,
        {self}
      }
    }
  })
end

function P3FP_OKCorral:WTFswitchFar()
  self:CreateTask({
    sName = "Task_WTFCutscene",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "WTF_FP_OKCoral_NOCAM",
    tCinematicNodes = {
      "wtf_fp_okcoral"
    },
    tOnComplete = {
      {
        self.TASK_EscapeEscalation,
        {self}
      }
    }
  })
end

function P3FP_OKCorral:TASK_EscapeEscalation()
  self:CreateTask({
    sName = "P3FP_OKCorral.TASK_EscapeEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    EscalationLevel = 0,
    tOnActivate = {
      {
        Suspicion.SetEscalationLevel,
        {3}
      },
      {
        self.LoadTraffic,
        {self}
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

function P3FP_OKCorral:SetupSquad()
  Render.StartFX(Handle(self.ResTruck1), "0FX_Smoke06_RingBurst", nil)
  Object.SetHealth(Handle(self.ResRenault1), 5000)
  Object.SetHealth(Handle(self.ResRenault2), 5000)
  Object.SetHealth(Handle(self.ResTruck1), 10000)
  Suspicion.EnableEscalationVehicles(false)
  Combat.SetGlobalHostileToResistance(true)
end

function P3FP_OKCorral:Setup_ClownCar()
  local tSeatConfig = {
    Pilot = "RndHuman_RS_Fighter_Random",
    Shotgun = "RndHuman_RS_Fighter_Random",
    Passengers = {
      "RndHuman_RS_Fighter_Random",
      "RndHuman_RS_Fighter_Random"
    }
  }
  Veh.SafeSpawnAtObj(cVEH_RENAULTVIVA, "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\LOC_SpawnCCar", tSeatConfig, true, self.OnCarSpawns, self, nil)
end

function P3FP_OKCorral:OnCarSpawns(a_hCar)
  self.hCCar = a_hCar
  Object.SetHealth(self.hCCar, 10000)
  self.hCCShotgun = Vehicle.GetActorInSeat(a_hCar, "SHOTGUN")
  self.hCCPilot = Vehicle.GetActorInSeat(a_hCar, "PILOT")
  self.hCCPassL = Vehicle.GetActorInSeat(a_hCar, "BACKSEAT_L")
  self.hCCPassR = Vehicle.GetActorInSeat(a_hCar, "BACKSEAT_R")
  Inventory.GiveItem(self.hCCShotgun, "WP_MG_MP40", false)
  Inventory.GiveItem(self.hCCPilot, "WP_MG_MP40", false)
  Inventory.GiveItem(self.hCCPassL, "WP_MG_MP40", false)
  Inventory.GiveItem(self.hCCPassR, "WP_MG_MP40", false)
  Nav.SetScriptedPath(a_hCar, "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\PATH_ClownCar", false, "P3FP_OKCorral.ClownCarExit", self)
  Nav.SetScriptedPathSpeed(a_hCar, 100)
end

function P3FP_OKCorral:ClownCarExit()
  Vehicle.UnboardAll(Handle(self.hCCar), false)
end

function P3FP_OKCorral:NaziBackup()
  local tSeatConfig = {
    Pilot = "Human_SS_Heavy_MG",
    Shotgun = "Human_SS_Heavy_MG",
    Passengers = {
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG",
      "Human_SS_Heavy_MG"
    }
  }
  Veh.SafeSpawnAtObj(cVEH_OPEL, "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\LOC_SpawnOpel", tSeatConfig, true, self.OnOpelSpawns, self, nil)
end

function P3FP_OKCorral:OnOpelSpawns(a_hCar)
  self.hOpel = a_hCar
  Object.SetHealth(self.hOpel, 10000)
  self.hOpelShotgun = Vehicle.GetActorInSeat(a_hCar, "SHOTGUN")
  self.hOpelPilot = Vehicle.GetActorInSeat(a_hCar, "PILOT")
  self.hOpelBLE = Vehicle.GetActorInSeat(a_hCar, "BACK_LEFT_END")
  self.hOpelBLM = Vehicle.GetActorInSeat(a_hCar, "BACK_LEFT_MIDDLE")
  self.hOpelBRE = Vehicle.GetActorInSeat(a_hCar, "BACK_RIGHT_END")
  self.hOpelBRM = Vehicle.GetActorInSeat(a_hCar, "BACK_RIGHT_MIDDLE")
  Nav.SetScriptedPath(a_hCar, "Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\PATH_Opel", false, "P3FP_OKCorral.OpelExit", self)
  Nav.SetScriptedPathSpeed(a_hCar, 100)
end

function P3FP_OKCorral:OpelExit()
  Vehicle.UnboardAll(Handle(self.hOpel), false)
end

function P3FP_OKCorral:My_Cancel()
  Sound.ResetMusicLocale()
  Zone.SwitchState("WtF_Zones\\global\\FP_OKCoral", cZONESTATE_LOWWTF, cENT_IMMEDIATE)
  HUD.SetEnableAllGPSEdgesInTrigger("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\PT_NoGPS", true)
  Combat.SetGlobalHostileToResistance(false)
  WorldSMEDNodes.UnloadNode("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\snipers", true)
  Vehicle.EnableTraffic(true)
end

function P3FP_OKCorral:Complete()
  Sound.ResetMusicLocale()
  HUD.SetEnableAllGPSEdgesInTrigger("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\main\\PT_NoGPS", true)
  Combat.SetGlobalHostileToResistance(false)
  WorldSMEDNodes.UnloadNode("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\snipers", true)
  Vehicle.EnableTraffic(true)
end

function P3FP_OKCorral:PlayerKilledContact(tArgs)
  local hContact = Handle("Missions\\freeplay\\p3\\mis_hotelinvalideseast_kill\\resistance\\RS_Commander")
  if tArgs[2] == hSab and tArgs[3] == cDAMAGE_BULLETS then
    self.tInfo.ContactTotalDamage = self.tInfo.ContactTotalDamage + tArgs[4]
  end
  if hContact and not Object.IsAlive(hContact) and self.tInfo.ContactTotalDamage >= 100 then
    self:MissionTaskFail("P3FP_OKCorral_Text.Fail_KilledContact")
  end
end

function P3FP_OKCorral:ResContactDead()
  self:MissionTaskFail("P3FP_OKCorral_Text.Fail_ContactDied")
end

function P3FP_OKCorral:MISSION_ONRESET()
  Vehicle.EnableTraffic(true)
end
