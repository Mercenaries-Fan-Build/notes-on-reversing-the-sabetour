if Paris_5_Mission_3 == nil then
  local DEMOMODE = false
  Paris_5_Mission_3 = SabTaskObjective:Create()
  gsParis5Mission2Dir = "Missions\\Paris_5\\Mission_3\\"
  if DEMOMODE == false then
    Paris_5_Mission_3:Configure({
      TaskCount = 9999,
      sAreaID = "Paris_5",
      sStarter = "Bryman_Boulogne_Exterior",
      sConvFile = "P5M3_Start",
      sSaveMissionNameID = "MissionNames_Text.P5M3",
      tUnlockList = {
        "NOTE_305",
        "Connect_ST_306_BishopMeeting"
      },
      tSMEDNodes = {
        "Missions\\paris_5\\mission_3\\dynamic_trigger",
        "Missions\\paris_5\\mission_3\\conversations",
        "Missions\\paris_5\\mission_3\\starter"
      },
      tStaticTags = {
        "courtyard_combat",
        "BigGun_MainStatic"
      }
    })
  else
    Paris_5_Mission_3:Configure({
      TaskCount = 99,
      sAreaID = "Paris_5",
      sConvFile = "P5M3_Start",
      bStarterless = true,
      sSaveMissionNameID = "MissionNames_Text.P5M3",
      tUnlockList = {
        "P1FP_KillCourtyard01",
        "NOTE_305",
        "Connect_ST_306_BishopMeeting"
      },
      tSMEDNodes = {
        "Missions\\paris_5\\mission_3\\dynamic_trigger",
        "Missions\\paris_5\\mission_3\\conversations",
        "Missions\\paris_5\\mission_3\\starter",
        "Missions\\paris_5\\mission_3\\occupation_geo\\DEMO_CAR"
      },
      tStaticTags = {
        "P5M3_biggun",
        "courtyard_combat",
        "BigGun_MainStatic"
      }
    })
  end
end

function Paris_5_Mission_3:STARTER_Setup()
end

function Paris_5_Mission_3:Activated()
  SabTaskObjective.Activated(self)
  self.Checkpoint0(self)
  Util.LoadStaticENTag("P5M3_biggun", true)
end

function Paris_5_Mission_3:Checkpoint0()
  Util.UnloadStaticENTag("P5M3_biggun_unload", true)
  Inventory.GiveItem(hSab, "WP_SAB_RDX_Charge", false)
  Inventory.GiveItem(hSab, "WP_SAB_RDX_Charge", false)
  Inventory.GiveItem(hSab, "WP_SAB_RDX_Charge", false)
  Saboteur.ShowToolTip("TutorialTip_Text.Sabotage_RDX")
  self:CreateTask({
    sName = "BigGunDestroyTask",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    bPersistentParent = true,
    sObjectiveTextID = "P5M3_Text.DestroyTheCannon",
    tOnActivate = {}
  })
  self.RegisterCheckpoint(self, "Paris_5_Mission_3.ActivatedMission")
end

function Paris_5_Mission_3:ActivatedMission()
  self.StopFiring = true
  self.hackytaskincrement = 0
  Sound.LoadSoundBank("m_P5M3_inGame.bnk")
  self.Checkpoint0a(self)
end

function Paris_5_Mission_3:GetOutOfHQ()
  self:CreateTask({
    sName = "Task_ExitBOULHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sObjectiveTextID = "GenericObjective_Text.HQ_P2_Exit",
    sInteriorName = "Boulogne",
    bInteriorTask = true,
    tLocators = {},
    tOnComplete = {
      {
        self.Checkpoint0a,
        {self}
      }
    }
  })
end

function Paris_5_Mission_3:Checkpoint0a()
  self.RegisterCheckpoint(self, "Paris_5_Mission_3.GPSTarget")
end

function Paris_5_Mission_3:GetOutOfPlaceDifferently()
  self:CompleteTaskByName("Task_ExitBOULHQ")
end

function Paris_5_Mission_3:SetupInventoryLookupConvo()
  self.hSeeEvent = Util.CreateEvent({
    EventType = "SeeLocatorEvent",
    InViewTime = 3,
    Locator = "Missions\\paris_5\\mission_3\\conversations\\LOC_See_the_Gun"
  }, "Paris_5_Mission_3.NoInventory", self)
end

function Paris_5_Mission_3:NoInventory()
  if Inventory.GetCountOfType(hSab, "WP_SAB_DynamiteFuse") == 0 then
    Cin.PlayConversation("P5M3_BigGun_Discovered_NoBomb")
  end
end

function Paris_5_Mission_3:GPSTarget()
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    EventName = "KillNaziEvent",
    Objects = {
      "Missions\\paris_5\\mission_3\\dynamic_trigger\\cowernazi1"
    },
    WaitForGameObject = true
  }, "Paris_5_Mission_3.CoweringNaziEvents", self, {true}))
  self.tSaveInfo.bScientistDead = false
  self:CreateTask({
    sName = "GoToStart",
    sTaskType = "SabTaskObjectiveDeliver",
    sObjectiveTextID = "P5M3_Text.GetToTheCannonCourtyard",
    sTaskSubType = "GOTO",
    tLocators = {
      "Missions\\paris_5\\mission_3\\starter\\LOC_GoTo"
    },
    tDestRegion = "Missions\\paris_5\\mission_3\\starter\\PT_GoTo",
    tDeliverObjs = {hSab},
    vGPSTarget = "Missions\\paris_5\\mission_3\\starter\\LOC_GoTo",
    tOnComplete = {
      {
        self.SetupCheckpoint1,
        {self}
      },
      {
        Render.Rain,
        {0.8, 0.1}
      },
      {
        Render.EnableLightning,
        {true}
      }
    }
  })
  self.StreamGunEvent(self)
end

function Paris_5_Mission_3:EscalationMusicSetupLevel0()
  self:CreateTask({
    sName = "MusicChangeEscalation0",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 1,
    bGTE = true,
    bRepeatable = true,
    tOnComplete = {
      {
        self.EscalationMusicSetupLevel1,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Paris_5_Mission_3:EscalationMusicSetupLevel1()
  self:CreateTask({
    sName = "MusicChangeEscalation1",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    EscalationLevel = 0,
    bLTE = true,
    bRepeatable = true,
    tOnComplete = {
      {
        self.EscalationMusicSetupLevel0,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function Paris_5_Mission_3:MISSION_ONCANCEL()
  if self.TempObjectiveID then
    HUD.RemoveObjective(self.TempObjectiveID)
  end
end

function Paris_5_Mission_3:GENERAL_Setup()
  self.bMusicOn = true
  if self.bMusicOn == true then
    Sound.SetMusicLocale("P5M3_BigGun")
    Sound.SetMusicLocale("m_P5M3_BigGun", "P5M3_courtyard")
  end
  self:AddOnCancelCallback(Paris_5_Mission_3.Reset)
  self:AddOnCompleteCallback(Paris_5_Mission_3.Reset)
  self.SabotageBigGun(self)
  if self.tSaveInfo.bScientistDead == false then
    self.GunTimerEvent = EVENT_Timer("Paris_5_Mission_3.MissionFail", self, 610)
    self.nTimer = 610
    self.TempObjectiveID = HUD.AddObjective(eOT_HEART, SabTask:GetLocalizedText("P5M3_Text.HUDCOUNT"), 2, self:GetTaskObjectiveID("BigGunDestroyTask"))
    HUD.SetupProgressBar(self.TempObjectiveID, 0, self.nTimer, 610)
    self.nSelfCounter = EVENT_Timer("Paris_5_Mission_3.UpdateTimerInScript", self, 0)
  end
  self.tSaveInfo.bP5M3_Workers_Stopped = false
  self.tSaveInfo.bP5M3_BigGun_DamagedLight = false
  self.tSaveInfo.bP5M3_BigGun_DamagedNearDeath = false
  self.tSaveInfo.bP5M3_Loudspeaker_Resume = false
  self.tSaveInfo.bP5M3_Loudspeaker_OneMinute = false
  self.tSaveInfo.bP5M3_Loudspeaker_TwoMinute = false
  self.tSaveInfo.bP5M3_Loudspeaker_ThreeMinute = false
  self.tSaveInfo.bP5M3_Loudspeaker_FourMinute = false
  self.tSaveInfo.bP5M3_Loudspeaker_FiveMinute = false
  self.tSaveInfo.bP5M3_Loudspeaker_SixMinute = false
  self.tSaveInfo.bP5M3_Loudspeaker_SevenMinute = false
  self.tSaveInfo.bP5M3_Loudspeaker_EightMinute = false
  self.tSaveInfo.bP5M3_Loudspeaker_NineMinute = false
  self.tSaveInfo.bP5M3_Loudspeaker_TenMinute = false
  self.tSaveInfo.bP5M3_Loudspeaker_FifteenMinute = false
  self.tSaveInfo.bP5M3_Loudspeaker_HalfMinute = false
  self:RegisterTriggerEvent(Trigger.WaitFor("Missions\\paris_5\\mission_3\\dynamic_trigger\\PT_EscalationLV4", hSab, "Paris_5_Mission_3.EscalationLV4", self, nil, cTRIGGEREVENT_ONENTER, true), "Missions\\paris_5\\mission_3\\dynamic_trigger\\PT_EscalationLV4")
end

function Paris_5_Mission_3:EscalationLV4()
  Sound.SetMusicLocale("P5M3_BigGun")
  Sound.SetMusicLocale("m_P5M3_BigGun", "P5M3_DestroyGun")
end

function Paris_5_Mission_3:UpdateTimerInScript()
  self.nTimer = self.nTimer - 10
  if self.tSaveInfo.bScientistDead == false then
    if self.nTimer == 590 then
      self.bP5M3_Loudspeaker_TenMinute = true
      Cin.PlayConversation("P5M3_Loudspeaker_10_Minutes")
    elseif self.nTimer == 540 then
      self.bP5M3_Loudspeaker_NineMinute = true
      Cin.PlayConversation("P5M3_Loudspeaker_9_Minutes")
    elseif self.nTimer == 480 then
      self.bP5M3_Loudspeaker_EightMinute = true
      Cin.PlayConversation("P5M3_Loudspeaker_8_Minutes")
    elseif self.nTimer == 420 then
      self.bP5M3_Loudspeaker_SevenMinute = true
      Cin.PlayConversation("P5M3_Loudspeaker_7_Minutes")
    elseif self.nTimer == 360 then
      self.bP5M3_Loudspeaker_SixMinute = true
      Cin.PlayConversation("P5M3_Loudspeaker_6_Minutes")
    elseif self.nTimer == 300 then
      self.bP5M3_Loudspeaker_FiveMinute = true
      Cin.PlayConversation("P5M3_Loudspeaker_5_Minutes")
    elseif self.nTimer == 240 then
      self.bP5M3_Loudspeaker_FourMinute = true
      Cin.PlayConversation("P5M3_Loudspeaker_4_Minutes")
    elseif self.nTimer == 180 then
      self.bP5M3_Loudspeaker_ThreeMinute = true
      Cin.PlayConversation("P5M3_Loudspeaker_3_Minutes")
    elseif self.nTimer == 120 then
      self.bP5M3_Loudspeaker_TwoMinute = true
      Cin.PlayConversation("P5M3_Loudspeaker_1_Minutes")
    elseif self.nTimer == 30 and self.bP5M3_Loudspeaker_HalfMinute == false then
      self.bP5M3_Loudspeaker_HalfMinute = true
      Cin.PlayConversation("P5M3_Loudspeaker_half_Minutes")
    end
    HUD.SetProgressBarValue(self.TempObjectiveID, self.nTimer)
    self.nSelfCounter = EVENT_Timer("Paris_5_Mission_3.UpdateTimerInScript", self, 10)
  end
end

function Paris_5_Mission_3:SabotageBigGunStreamedIn()
  self:CreateTask({
    sName = "PlantExplosives",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    bNoHUDBlip = true,
    bNoWorldBlip = true,
    tTgtInclude = {
      "Missions\\paris_5\\mission_3\\big_gun\\OccMed_Rail_Cannon\\OccMed_Rail_Cannon"
    },
    tOnComplete = {},
    tOnFailure = {
      {
        self.MissionFail,
        {self}
      }
    }
  })
  local hGun = Util.GetHandleByName("Missions\\paris_5\\mission_3\\big_gun\\OccMed_Rail_Cannon\\OccMed_Rail_Cannon")
  local hcurrenthealth = 100000000
  if hGun then
    Object.SetHealth(hGun, 5010)
  end
  self.nTier1Health = 5000
  self.nTier2Health = 4500
  self.nTier3Health = 3500
  self.bLoadParticle1 = false
  self.bLoadParticle2 = false
  self.ParticleLoopyDoop(self)
end

function Paris_5_Mission_3:DescalateRunFromZep()
  self:CreateTask({
    sName = "DescalateRunFromZep",
    sTaskType = "SabTaskObjectiveEscalation",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    sTaskSubType = "NONE",
    EscalationLevel = 0,
    tOnComplete = {}
  })
  Sound.SetMusicLocale("P5M3_BigGun")
  Sound.SetMusicLocale("m_P5M3_BigGun", "P5M3_DestroyGun")
end

function Paris_5_Mission_3:StreamGunEvent()
  self.hGunStream = Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\paris_5\\mission_3\\big_gun\\OccMed_Rail_Cannon\\OccMed_Rail_Cannon"
    },
    WaitForGameObject = true,
    WaitForPhysics = true
  }, "Paris_5_Mission_3.SabotageBigGunStreamedIn", self)
  self:RegisterEvent(self.hGunStream)
end

function Paris_5_Mission_3:SabotageBigGun()
  if self.hGunStream then
    Util.KillEvent(self.hGunStream)
  end
  self.hGunStream = Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\paris_5\\mission_3\\big_gun\\OccMed_Rail_Cannon\\OccMed_Rail_Cannon"
    },
    WaitForGameObject = true,
    WaitForPhysics = true
  }, "Paris_5_Mission_3.SabotageBigGunStreamedIn", self)
  self:RegisterEvent(self.hGunStream)
  if self.hParticleLoopyEvent then
    Util.KillEvent(self.hParticleLoopyEvent)
  end
  self:CreateTask({
    sName = "BigGunObjectiveFake",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    tTgtInclude = {
      "Missions\\paris_5\\mission_3\\dynamic_trigger\\LC_BigGunLocation"
    },
    sObjectiveTextID = "P5M3_Text.SabotageTheCannon",
    tDeliverObjs = {hSab}
  })
  local hGun = Util.GetHandleByName("Missions\\paris_5\\mission_3\\big_gun\\OccMed_Rail_Cannon\\OccMed_Rail_Cannon")
  local hcurrenthealth = 100000000
  if hGun then
    Object.SetHealth(hGun, 5010)
  end
  self.nTier1Health = 5000
  self.nTier2Health = 4500
  self.nTier3Health = 3500
  self.bLoadParticle1 = false
  self.bLoadParticle2 = false
end

function Paris_5_Mission_3:ParticleLoopyDoop()
  local hGun = Util.GetHandleByName("Missions\\paris_5\\mission_3\\big_gun\\OccMed_Rail_Cannon\\OccMed_Rail_Cannon")
  local nWhichConvoPlay = -1
  self.bP5M3_BigGun_DamagedLight = false
  self.bP5M3_BigGun_DamagedNearDeath = false
  if hGun then
    local hcurrenthealth = Object.GetHealth(hGun)
    if hcurrenthealth < self.nTier1Health and self.bLoadParticle1 == false then
      self.bLoadParticle1 = true
      nWhichConvoPlay = 1
    end
    if hcurrenthealth < self.nTier2Health and self.bLoadParticle2 == false then
      self.bLoadParticle2 = true
      nWhichConvoPlay = 2
    end
    if hcurrenthealth < self.nTier3Health then
      for i = 1, 9 do
        local fireloc = Handle("Missions\\paris_5\\mission_3\\big_gun\\fire" .. i)
        if fireloc then
          Render.StartFX(fireloc, "0FX_Fire01_Medium", nil)
        end
      end
      self.MissionCompleteA(self)
      return 1
    end
    if nWhichConvoPlay == 1 then
      self.bP5M3_BigGun_DamagedLight = true
      Cin.PlayConversation("P5M3_BigGun_DamagedLight")
    elseif nWhichConvoPlay == 2 then
      self.bP5M3_BigGun_DamagedNearDeath = true
      Cin.PlayConversation("P5M3_BigGun_DamagedNearDeath")
    end
  end
  self.hParticleLoopyEvent = EVENT_Timer("Paris_5_Mission_3.ParticleLoopyDoop", self, 1)
end

function Paris_5_Mission_3:VictoryDelayed()
  EVENT_Timer("Paris_5_Mission_3.MissionCompleteA", self, 4)
end

function Paris_5_Mission_3:ReEnableNaziEvent()
  local tNaziHandles = {
    Util.GetHandleByName("Missions\\paris_5\\mission_3\\dynamic_trigger\\cowernazi1")
  }
  if tNaziHandles[1] then
    for i, v in ipairs(self.tCowerEvents) do
      Util.KillEvent(v)
    end
    self:FailTaskByName("Kill_Guarding_Nazi" .. self.hackytaskincrement - 1)
  end
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    Objects = {
      "Missions\\paris_5\\mission_3\\dynamic_trigger\\cowernazi1"
    },
    WaitForGameObject = true
  }, "Paris_5_Mission_3.CoweringNaziEvents", self, {true}))
end

function Paris_5_Mission_3:CoweringNaziEvents(UserData)
  local tNaziHandles = {
    Util.GetHandleByName("Missions\\paris_5\\mission_3\\dynamic_trigger\\cowernazi1")
  }
  if self.tSaveInfo.bSeeTech == nil then
    Cin.PlayConversation("P5M3_Kill_Technician")
    self.tSaveInfo.bSeeTech = true
  end
  if tNaziHandles[1] and Util.IsHandleValid(tNaziHandles[1]) and Object.IsAlive(tNaziHandles[1]) then
    Actor.OverrideCombatAI(tNaziHandles[1], true)
    local tElements = {"stomp", "kick"}
    local tAnimateSequence = {
      {
        "JUMPTORANDOM",
        tElements
      },
      {
        "PLAYANIMATION",
        {
          "sabotage_clippers_mid_idle"
        },
        "stomp"
      },
      {
        "DELAY",
        {1.4}
      },
      {"STARTOVER"},
      {
        "PLAYANIMATION",
        {
          "shrd_M_customer_long"
        },
        "kick"
      },
      {
        "DELAY",
        {5}
      },
      {"STARTOVER"}
    }
    if UserData == true then
      self:CreateTask({
        sName = "Kill_Guarding_Nazi" .. self.hackytaskincrement,
        sTaskType = "SabTaskObjectiveDestroy",
        sTaskSubType = "KILL",
        bNoFocus = true,
        tTgtInclude = {
          "Missions\\paris_5\\mission_3\\dynamic_trigger\\cowernazi1"
        },
        tOnComplete = {
          {
            self.StopTimerGun,
            {self}
          },
          {
            self.KilledScientist,
            {self}
          }
        }
      })
      self.hackytaskincrement = self.hackytaskincrement + 1
    end
    if tNaziHandles[1] ~= nil and Util.IsHandleValid(tNaziHandles[1]) and Object.IsAlive(tNaziHandles[1]) then
      ScriptSequence.Run(tNaziHandles[1], tAnimateSequence)
      self.tCowerEvents = {}
      local tREvent = {
        EventType = "OnDamage",
        Target = tNaziHandles[1]
      }
      table.insert(self.tCowerEvents, Util.CreateEvent(tREvent, "Paris_5_Mission_3.NazisCower", self))
      tREvent = {
        EventType = "ProximityEvent",
        ObjectA = tNaziHandles[1],
        ObjectB = hSab,
        Proximity = 7,
        Negate = false
      }
      table.insert(self.tCowerEvents, Util.CreateEvent(tREvent, "Paris_5_Mission_3.NazisCower", self))
    end
    self:RegisterEvent(Util.CreateEvent({
      EventType = "StreamEvent",
      Objects = {
        "Missions\\paris_5\\mission_3\\dynamic_trigger\\cowernazi1"
      },
      WaitForStreamOut = true
    }, "Paris_5_Mission_3.ReEnableNaziEvent", self))
  end
end

function Paris_5_Mission_3:KilledScientist()
  if self.tSaveInfo.bScientistDead == false then
    Cin.PlayConversation("P5M3_Engineer_Killed")
  end
  for i, v in ipairs(self.tCowerEvents) do
    Util.KillEvent(v)
  end
  self.bP5M3_Loudspeaker_Resume = true
  self.tSaveInfo.bScientistDead = true
  if self.TempObjectiveID then
    HUD.RemoveObjective(self.TempObjectiveID)
    self.TempObjectiveID = nil
  end
end

function Paris_5_Mission_3:StopTimerGun()
  if self.GunTimerEvent then
    EVENT_KillEvent(self.GunTimerEvent)
    HUD.RemoveTimer()
  end
  if self.nSelfCounter then
    EVENT_KillEvent(self.nSelfCounter)
  end
end

function Paris_5_Mission_3:ResumeTimerGun()
  if self.bP5M3_Loudspeaker_Resume == false then
    Cin.PlayConversation("P5M3_Loudspeaker_Resume")
  end
  self.bP5M3_Loudspeaker_Resume = true
  local tNaziHandles = {
    Util.GetHandleByName("Missions\\paris_5\\mission_3\\dynamic_trigger\\cowernazi1")
  }
  if tNaziHandles[1] then
    self.CoweringNaziEvents(self, false)
    self.GunTimerEvent = EVENT_Timer("Paris_5_Mission_3.MissionFail", self, self.nTimer)
    self.nSelfCounter = EVENT_Timer("Paris_5_Mission_3.UpdateTimerInScript", self, 0)
  end
end

function Paris_5_Mission_3:NazisCower()
  if self.bP5M3_Workers_Stopped == false then
    Cin.PlayConversation("P5M3_Workers_Stopped")
  end
  self.bP5M3_Workers_Stopped = true
  self.StopTimerGun(self)
  self.StopFiring = true
  local tAnimateSequence = {
    {
      "PLAYANIMATION",
      {
        "civ_cower_idle"
      }
    },
    {
      "DELAY",
      {1.4}
    },
    {"STARTOVER"}
  }
  local tNaziHandles = {
    Util.GetHandleByName("Missions\\paris_5\\mission_3\\dynamic_trigger\\cowernazi1")
  }
  Actor.OverrideCombatAI(tNaziHandles[1], false)
  for i, v in ipairs(self.tCowerEvents) do
    Util.KillEvent(v)
  end
  ScriptSequence.Kill(Util.GetHandleByName("Missions\\paris_5\\mission_3\\dynamic_trigger\\cowernazi1"))
end

function Paris_5_Mission_3:MissionCompleteA()
  if self.TempObjectiveID then
    HUD.RemoveObjective(self.TempObjectiveID)
  end
  Object.SetInvincible(hSab, true)
  HUD.ClearAllObjectives()
  self:KillTaskByName("BigGunObjectiveFake")
  self:KillTaskByName("Final_Defneding")
  self:KillTaskByName("Kill_Incomming_Tanks")
  if self.tCowerEvents then
    for i, v in ipairs(self.tCowerEvents) do
      Util.KillEvent(v)
    end
  end
  HUD.RemoveObjectiveMarker(Handle("Missions\\paris_5\\mission_3\\dynamic_trigger\\LC_BigGunLocation"))
  EVENT_Timer("Paris_5_Mission_3.DelayedExplosionCannon", self, 2.5)
  EVENT_Timer("Paris_5_Mission_3.SetVulnerable", self, 2)
  EVENT_Timer("Paris_5_Mission_3.MissionComplete2", self, 17)
  Render.Rain(0, 0.8)
  Render.EnableLightning(false)
  if Cin.IsPlayerCloseToCinematic("Missions\\paris_5\\mission_3\\big_gun\\FX_Explosion1") then
    self.Task_CutsceneExit1(self)
  else
    self.Task_CutsceneExit2(self)
  end
end

function Paris_5_Mission_3:Task_CutsceneExit1()
  self:CreateTask({
    sName = "Task_CutsceneExit1",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "Big_Gun_Camera",
    bOverrideFade = false,
    tSMEDNodes = {},
    tOnActivate = {},
    tOnComplete = {
      {
        Suspicion.SetEscalationLevel,
        {4}
      },
      {
        Util.UnloadStaticENTag,
        {
          "P5M3_biggun",
          true
        }
      }
    }
  })
end

function Paris_5_Mission_3:Task_CutsceneExit2()
  self:CreateTask({
    sName = "Task_CutsceneExit2",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "WTF_P5M3_BigGun_NOCAM",
    bOverrideFade = false,
    tSMEDNodes = {},
    tOnActivate = {},
    tOnComplete = {
      {
        Suspicion.SetEscalationLevel,
        {4}
      },
      {
        Util.UnloadStaticENTag,
        {
          "P5M3_biggun",
          true
        }
      }
    }
  })
end

function Paris_5_Mission_3:SetVulnerable()
  Object.SetHealth(Util.GetHandleByName("PARIS\\area02\\trocadero\\buildings\\OccMed_Rail_Cannon_Platform(2)"), 10)
  if Handle("PARIS\\area02\\trocadero\\buildings\\NAZIGUN_Corner\\City1_RoofCNR30_End_DAM") then
    Object.SetHealth(Util.GetHandleByName("PARIS\\area02\\trocadero\\buildings\\NAZIGUN_Corner\\City1_RoofCNR30_End_DAM"), 10)
  end
  if Handle("PARIS\\area02\\trocadero\\buildings\\NAZIGUN_Corner\\City1_CNR30_4Level_DAM(1)") then
    Object.SetHealth(Util.GetHandleByName("PARIS\\area02\\trocadero\\buildings\\NAZIGUN_Corner\\City1_CNR30_4Level_DAM(1)"), 10)
  end
  if Handle("PARIS\\area02\\trocadero\\buildings\\NAZIGUN_Corner\\City1_RoofCNR30_End_DAM") then
    Object.SetHealth(Util.GetHandleByName("PARIS\\area02\\trocadero\\buildings\\NAZIGUN_Corner\\City1_RoofCNR30_End_DAM"), 10)
  end
  Object.SetInvincible(Util.GetHandleByName("Missions\\paris_5\\mission_3\\big_gun\\OccMed_Rail_Cannon\\OccMed_Rail_Cannon"), false)
  Object.SetHealth(Util.GetHandleByName("Missions\\paris_5\\mission_3\\big_gun\\OccMed_Rail_Cannon\\OccMed_Rail_Cannon"), 10)
end

function Paris_5_Mission_3:UnloadFireParticles()
  for i = 1, 9 do
    local fireloc = Handle("Missions\\paris_5\\mission_3\\big_gun\\fire" .. i)
    if fireloc then
      Render.EndFX(fireloc, "0FX_Fire01_Medium", nil)
    end
  end
end

function Paris_5_Mission_3:MissionComplete2()
  self:CompleteThisMission()
end

function Paris_5_Mission_3:DelayedExplosionCannon()
  Object.SetInvincible(hSab, false)
  if Handle("PARIS\\area02\\trocadero\\buildings\\NAZIGUN_Corner\\OccLt_Large_Cannon_DAM") then
    Object.SetHealth(Util.GetHandleByName("PARIS\\area02\\trocadero\\buildings\\NAZIGUN_Corner\\OccLt_Large_Cannon_DAM"), 1)
  end
  if Util.GetHandleByName("PARIS\\area02\\trocadero\\buildings\\NAZIGUN_Corner\\OccLt_Large_Cannon_Platform_DAM") then
    Object.SetHealth(Util.GetHandleByName("PARIS\\area02\\trocadero\\buildings\\NAZIGUN_Corner\\OccLt_Large_Cannon_Platform_DAM"), 1)
  end
  if Util.GetHandleByName("PARIS\\area02\\trocadero\\buildings\\NAZIGUN_Corner\\OccLt_Large_Cannon_DAM") then
    Object.SetInvincible(Util.GetHandleByName("PARIS\\area02\\trocadero\\buildings\\NAZIGUN_Corner\\OccLt_Large_Cannon_DAM"), false)
  end
  if Util.GetHandleByName("PARIS\\area02\\trocadero\\buildings\\NAZIGUN_Corner\\OccLt_Large_Cannon_Platform_DAM") then
    Object.SetInvincible(Util.GetHandleByName("PARIS\\area02\\trocadero\\buildings\\NAZIGUN_Corner\\OccLt_Large_Cannon_Platform_DAM"), false)
  end
  if Util.GetHandleByName("Missions\\paris_5\\mission_3\\big_gun\\OccMed_Rail_Cannon\\OccMed_Rail_Cannon") then
    Object.Kill(Util.GetHandleByName("Missions\\paris_5\\mission_3\\big_gun\\OccMed_Rail_Cannon\\OccMed_Rail_Cannon"))
  end
  if Handle("PARIS\\area02\\trocadero\\buildings\\OccMed_Rail_Cannon_Platform(2)") then
    Object.Kill(Handle("PARIS\\area02\\trocadero\\buildings\\OccMed_Rail_Cannon_Platform(2)"))
  end
  if Handle("Missions\\paris_5\\mission_3\\big_gun\\City1_CNR30_4Level_DAM(1)") then
    Object.Kill(Handle("Missions\\paris_5\\mission_3\\big_gun\\City1_CNR30_4Level_DAM(1)"))
  end
  if Handle("Missions\\paris_5\\mission_3\\big_gun\\City1_RoofCNR30_End_DAM") then
    Object.Kill(Handle("Missions\\paris_5\\mission_3\\big_gun\\City1_RoofCNR30_End_DAM"))
  end
  Util.CreateExplosion("Explosion_SAB_DynamiteFuse", -1365, 69, 335)
end

function Paris_5_Mission_3:MissionFail()
  self:MissionTaskFail("P5M3_Text.TimerFail")
end

function Paris_5_Mission_3:SetupCheckpoint1()
  self.RegisterCheckpoint(self, "Paris_5_Mission_3.Checkpoint1")
end

function Paris_5_Mission_3:Checkpoint1()
  Util.KillEvent("KillNaziEvent")
  self:RegisterEvent(Util.CreateEvent({
    EventType = "StreamEvent",
    EventName = "KillNaziEvent2",
    Objects = {
      "Missions\\paris_5\\mission_3\\dynamic_trigger\\cowernazi1"
    },
    WaitForGameObject = true
  }, "Paris_5_Mission_3.CoweringNaziEvents", self, {true}))
  self.GENERAL_Setup(self)
  Vehicle.EnableTraffic(false)
  Render.Rain(0.8, 0.1)
  Render.EnableLightning(true)
end

function Paris_5_Mission_3:Reset()
  Vehicle.EnableTraffic(true)
  Sound.ResetMusicLocale()
  Sound.ReleaseSoundBank("m_P5M3_inGame.bnk")
end

function Paris_5_Mission_3:MISSION_ONRESET()
  Vehicle.EnableTraffic(true)
end
