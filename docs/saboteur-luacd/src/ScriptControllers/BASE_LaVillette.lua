if not BASE_LaVillette then
  BASE_LaVillette = {}
end

function BASE_LaVillette:OnEnter()
  self.sDebugLabel = "LAVILLETTE"
  self.bDebugMode = false
  self.PATH = self.SMEDTable.sPath
  if P1M6Debug then
    return
  end
  self.nMinAirRaidTime = 30
  self.nMaxAirRaidTime = 45
  self.nMinTimeBetweenRaids = 30
  self.nMaxTimeBetweenRaids = 45
  self.tMinAnnouncementTime = 45
  self.tMaxAnnouncementTime = 120
  self.bIsAirRaidActive = false
  self.bWorldIsEscalated = false
  self.bIntruderAnnouncement = false
  self.nBomberCinStartDelay = 5
  self.nBomberCinStopDelay = 30
  self.nMinFlakFireDelay = 5
  self.nMaxFlakFireDelay = 7
  self.nMinAAFireDelay = 5
  self.nMaxAAFireDelay = 7
  self.nPostRaidDryFireDelay = 3
  self.nPostRaidDismountDelay = 10
  self.nMusicReleaseDelay = 13
  self.nPermissionToFireDelay = 58
  self.bPrisonersJoinSquad = true
  BASE_LaVillette.SetupObjectPaths(self)
  BASE_LaVillette.SetupEscalationListeners(self)
  self.tBomberCinematics = {
    "CIN_P1M1B_FlyoverD",
    "CIN_P1M1B_FlyoverJ"
  }
  self.tRepeatingBomberCinematics = {
    "CIN_P1M1B_FlyoverA",
    "CIN_P1M1B_FlyoverB",
    "CIN_P1M1B_FlyoverC",
    "CIN_P1M1B_FlyoverK",
    "CIN_P1M1B_FlyoverL"
  }
  self.tAnnouncements = {
    "vo_mis_P1M1b_AnnounceGeneral_NaziAdministrator_01",
    "vo_mis_P1M1b_AnnounceGeneral_NaziAdministrator_02",
    "vo_mis_P1M1b_AnnounceGeneral_NaziAdministrator_05",
    "vo_mis_P1M1b_AnnounceGeneral_NaziAdministrator_06",
    "vo_mis_P1M1b_AnnounceGeneral_NaziAdministrator_07",
    "vo_mis_P1M1b_AnnounceGeneral_NaziAdministrator_08"
  }
  self.tJobsSuspendedDuringRaid = {"PATROL_X", "PATROL_Y"}
  local tStreamTable = {
    self.tBunkers.West,
    self.tBunkers.East
  }
  Sound.LoadSoundBank("m_P1M1b_inGame.bnk")
  Sound.LoadSoundBank("m_P1M1b_start.bnk")
  self.sQ1NorthCannon = "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunNorth\\Seat"
  self.sQ2SouthCannon = "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunSouth\\Seat"
  self.sQ3WestCannon = "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunWest\\Seat"
  self.sQ4EastCannon = "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunEast\\Seat"
  self.tTargetFlakGuns = {
    self.sQ1NorthCannon,
    self.sQ2SouthCannon,
    self.sQ3WestCannon,
    self.sQ4EastCannon
  }
  self.sCannoneerNorth = "PARIS\\area01\\lavillette\\occupation\\patrols\\SPORE_NorthCannoneer"
  self.sCannoneerSouth = "PARIS\\area01\\lavillette\\occupation\\patrols\\SPORE_SouthCannoneer"
  self.sCannoneerWest = "PARIS\\area01\\lavillette\\occupation\\patrols\\SPORE_WestCannoneer"
  self.sCannoneerEast = "PARIS\\area01\\lavillette\\occupation\\patrols\\SPORE_EastCannoneer"
  self.tCannoneers = {
    self.sCannoneerNorth,
    self.sCannoneerSouth,
    self.sCannoneerWest,
    self.sCannoneerEast
  }
end

function BASE_LaVillette:OnBunkersReady()
  Tips.Print("BunkerManagers have streamed in...")
  BASE_LaVillette.SetupAirRaidJobs(self)
  BASE_LaVillette.SetupPatrolJob(self, "PATROL_TEST_A", "PA_TestA", cPATHTYPE_LOOP, "West", true)
  BASE_LaVillette.SetupPatrolJob(self, "PATROL_TEST_B", "PA_TestB", cPATHTYPE_LOOP, "West", true)
  BASE_LaVillette.StartRaidDowntimeTimer(self)
end

function BASE_LaVillette:OnPrisonersReady()
  if self.tPrisoners then
    for i, sPrisoner in ipairs(self.tPrisoners) do
      local hPrisoner = Handle(sPrisoner)
      Actor.ChangeModule(hPrisoner, "Resistance")
      Actor.EnableNeeds(hPrisoner, false)
    end
  end
end

function BASE_LaVillette:OnFlakCannonFire(a_tData, a_sCannon)
  local x, y, z = Object.GetPosition(Handle(self.tFlakGuns[a_sCannon].Gun))
  Render.CameraShakeExplosion(x, y, z, 15, 10, 60)
  BASE_LaVillette.SpawnDust(self)
end

function BASE_LaVillette:SpawnDust()
  if not self.tDustLocs then
    self.tDustLocs = Tips.GetListFromNames("PARIS\\area01\\lavillette\\occupation\\prison\\LOC_Dust")
  end
  local nMinParticles = 1
  local nMaxParticles = 3
  local nNumParticles = math.random(nMinParticles, nMaxParticles)
  for i = 1, nNumParticles do
    local hLocator = Tips.GetRandomElement(self.tDustLocs)
    Render.StartFX(hLocator, "0FX_Dust01_Ceiling", nil)
  end
end

function BASE_LaVillette:SetupParadeStreamEvent()
  self.sParadeOfficer = "PARIS\\area01\\lavillette\\occupation\\patrols\\Spore_WM_Officer_PS"
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      self.sParadeOfficer
    }
  }
  Util.CreateEvent(tStreamEvent, "BASE_LaVillette.OnParadeOfficerSpawns", self)
end

function BASE_LaVillette:OnParadeOfficerSpawns()
  local N = "Human_WM_Grunt_MG"
  local L = "LEADER"
  local _ = " "
  local tFormationData = {
    {
      _,
      L,
      _
    },
    {
      N,
      _,
      N
    }
  }
  Formation.Spawn(self.sParadeOfficer, tFormationData, 1.25)
end

function BASE_LaVillette:SetupEscalationListeners()
  BASE_LaVillette.AddEvent(self, Util.CreateEvent({
    Target = Handle("Saboteur"),
    EventType = "OnBaseEscalation0"
  }, "BASE_LaVillette.OnEscalationEnd", self, {}, true))
  BASE_LaVillette.AddEvent(self, Util.CreateEvent({
    Target = Handle("Saboteur"),
    EventType = "OnBaseEscalation1"
  }, "BASE_LaVillette.OnEscalationStart", self, {}, true))
  BASE_LaVillette.AddEvent(self, Util.CreateEvent({
    Target = Handle("Saboteur"),
    EventType = "OnEscalation0"
  }, "BASE_LaVillette.OnEscalationEnd", self, {}, true))
  BASE_LaVillette.AddEvent(self, Util.CreateEvent({
    Target = Handle("Saboteur"),
    EventType = "OnEscalation1"
  }, "BASE_LaVillette.OnEscalationStart", self, {}, true))
end

function BASE_LaVillette:OnEscalationStart()
  self.bWorldIsEscalated = true
  if self.bIntruderAnnouncement == false then
    BASE_LaVillette.PlaySound("vo_mis_P1M1b_IntruderAlert_Nazi_Administrator_01")
    self.bIntruderAnnouncement = true
  end
end

function BASE_LaVillette:OnEscalationEnd()
  self.bWorldIsEscalated = false
end

function BASE_LaVillette:StartRaidDowntimeTimer()
  local nTimerVal = math.random(self.nMinTimeBetweenRaids, self.nMaxTimeBetweenRaids)
end

function BASE_LaVillette:StartRaidUptimeTimer()
  local nTimerUpVal = math.random(self.nMinAirRaidTime, self.nMaxAirRaidTime)
  local tAirRaidEvent = {
    EventType = "TimerEvent",
    Time = nTimerUpVal,
    EventName = "LaVilletteAirRaidTimer"
  }
  Util.CreateEvent(tAirRaidEvent, "BASE_LaVillette.StopAirRaid", self, {true})
  Paris_1_Mission_1B.CountUpTimer(Paris_1_Mission_1B, nTimerUpVal)
end

function BASE_LaVillette:SetupAirRaidJobs()
end

function BASE_LaVillette:SetupPatrolJob(a_sJobName, a_sPathName, a_cMoveMode, a_sBunkerIdent, a_bStartJob)
  local tCombatFlags = {
    EnableSuspicion = false,
    RespondsToDeadBodies = false,
    RespondsToDamage = false,
    RespondsToEvents = false,
    SetIdleScripted = true
  }
  local tJob = {}
  tJob.Blueprint = "Human_WM_Grunt_MG"
  tJob.JobSequence = {
    {
      "WALKPATH",
      {
        self.PATH .. "patrols\\" .. a_sPathName,
        a_cMoveMode
      }
    }
  }
  tJob.CancelSequence = {
    {
      "SETCOMBATFLAGS",
      {tCombatFlags}
    }
  }
  Bunker.AddJob(self.tBunkers[a_sBunkerIdent], a_sJobName, tJob, a_bStartJob)
end

function BASE_LaVillette:SetupAAJob(a_sJobName, a_sAAIdent, a_sBunkerIdent)
  local tCombatFlags = {
    EnableSuspicion = false,
    RespondsToDeadBodies = false,
    RespondsToDamage = false,
    RespondsToEvents = false,
    NoAutoResponse = true,
    SetIdleScripted = true
  }
  local tJob = {}
  tJob.Blueprint = "Human_WM_Grunt_MG"
  tJob.JobSequence = {
    {
      "SETCOMBATFLAGS",
      {tCombatFlags}
    },
    {
      "SETCOMBAT",
      {false}
    },
    {"STOPMOVING"},
    {
      "SETSTATIONARY",
      {true}
    },
    {
      "SETBROADCAST_WEAPONFIRE",
      {false}
    },
    {
      "SETBROADCAST_ENTEREDCOMBAT",
      {false}
    },
    {
      "ENTERSEAT",
      {
        self.tAAGuns[a_sAAIdent].Gun,
        "PILOT"
      }
    },
    {
      "SETHAX",
      {true}
    },
    {
      "SETDRYFIRE",
      {true}
    },
    {
      "ATTACKTARGET_NOWAIT",
      {
        self.tAAGuns[a_sAAIdent].Targets[1]
      },
      "A"
    },
    {
      "DELAY",
      {2.5}
    },
    {
      "JUMPTORANDOM",
      {
        "B",
        "C",
        "D"
      }
    },
    {
      "ATTACKTARGET_NOWAIT",
      {
        self.tAAGuns[a_sAAIdent].Targets[2]
      },
      "B"
    },
    {
      "DELAY",
      {2.5}
    },
    {
      "JUMPTORANDOM",
      {
        "A",
        "C",
        "D"
      }
    },
    {
      "ATTACKTARGET_NOWAIT",
      {
        self.tAAGuns[a_sAAIdent].Targets[3]
      },
      "C"
    },
    {
      "DELAY",
      {2.5}
    },
    {
      "JUMPTORANDOM",
      {
        "A",
        "B",
        "D"
      }
    },
    {
      "ATTACKTARGET_NOWAIT",
      {
        self.tAAGuns[a_sAAIdent].Targets[4]
      },
      "D"
    },
    {
      "DELAY",
      {2.5}
    },
    {
      "JUMPTORANDOM",
      {
        "A",
        "B",
        "C"
      }
    }
  }
  tJob.CancelSequence = {
    {
      "SETHAX",
      {false}
    },
    {
      "SETCOMBAT",
      {false}
    },
    {
      "UNBOARDVEHICLE"
    },
    {"STOPMOVING"},
    {
      "SETBROADCAST_WEAPONFIRE",
      {true}
    },
    {
      "SETBROADCAST_ENTEREDCOMBAT",
      {true}
    },
    {
      "CLEARCOMBATFLAGS"
    },
    {
      "DELAY",
      {2}
    },
    {
      "WALKTOOBJECT",
      {
        self.tBunkers[a_sBunkerIdent .. "FrontStep"]
      }
    }
  }
  Bunker.AddJob(self.tBunkers[a_sBunkerIdent], a_sJobName, tJob, false)
end

function BASE_LaVillette:StartAirRaid(a_bSetTimeout)
  Tips.Print(self, "*** AIR RAID STARTED ***")
  Sound.SetMusicLocale("Silence")
  BASE_LaVillette.PlaySound("vo_mis_P1M1b_AnnounceGeneral_NaziAdministrator_04")
  self.bIsAirRaidActive = true
  Sound.ActivateSoundEmitter(Handle(self.sSiren))
  Sound.PlayOwnerlessSoundEvent("P1M1B_BomberFlyovers")
  if a_bSetTimeout == nil or a_bSetTimeout == true then
  end
  local tBomberStartEvent = {
    EventType = "TimerEvent",
    Time = self.nBomberCinStartDelay
  }
  Util.CreateEvent(tBomberStartEvent, "BASE_LaVillette.StartBomberCinematics", self)
  for sFlakLoc, tFlakData in pairs(self.tFlakGuns) do
    local tTimerEvent = {
      EventType = "TimerEvent",
      Time = math.random(self.nMinFlakFireDelay, self.nMaxFlakFireDelay)
    }
    Util.CreateEvent(tTimerEvent, "BASE_LaVillette.OnPermissionToFireGranted", self, {
      tFlakData.Gun
    })
  end
  for sAA, tAAData in pairs(self.tAAGuns) do
    local tTimerEvent = {
      EventType = "TimerEvent",
      Time = math.random(self.nMinAAFireDelay, self.nMaxAAFireDelay)
    }
    local e = Util.CreateEvent(tTimerEvent, "BASE_LaVillette.OnPermissionToFireGranted", self, {
      tAAData.Gun
    })
    BASE_LaVillette.AddEvent(self, e)
  end
  local tFireDelayEvent = {
    EventType = "TimerEvent",
    Time = self.nPermissionToFireDelay
  }
  local e = Util.CreateEvent(tFireDelayEvent, "BASE_LaVillette.PlaySound", nil, {
    "vo_mis_P1M1b_AnnounceAirRaidFire_NaziAdministrator_03"
  })
  BASE_LaVillette.AddEvent(self, e)
end

function BASE_LaVillette:OnPermissionToFireGranted(a_sTurret)
  local hTurret = Handle(a_sTurret)
  if hTurret then
    local hPilot = Vehicle.GetPilot(hTurret)
    if hPilot then
      Combat.SetDryFire(hPilot, false)
    end
  end
end

function BASE_LaVillette:ForceCannonDryFire()
  for sFlakLoc, tFlakData in pairs(self.tFlakGuns) do
    local hGun = Handle(tFlakData.Gun)
    if hGun then
      local hPilot = Vehicle.GetPilot(hGun)
      if hPilot then
        Combat.SetDryFire(hPilot, true)
      end
    end
  end
  for sAA, tAAData in pairs(self.tAAGuns) do
    local hGun = Handle(tFlakData.Gun)
    if hGun then
      local hPilot = Vehicle.GetPilot(hGun)
      if hPilot then
        Combat.SetDryFire(hPilot, true)
      end
    end
  end
  BASE_LaVillette.PlaySound("vo_mis_P1M1b_AnnounceAirRaidHold_NaziAdministrator_03")
end

function BASE_LaVillette:StartRaidSearchLights()
  Tips.Print(self, "BASE_LaVillette.StartRaidSearchLights()")
  for sLabel, tLightData in pairs(self.tSearchLights) do
    local tSearcherSequence = {
      {
        "DELAYFORRANDOM",
        {5, 8}
      },
      {
        "ENABLE_SEARCHER",
        {
          tLightData.Turret,
          "PILOT",
          true
        }
      },
      {
        "FOCUS_SEARCHER",
        {
          tLightData.Turret,
          "PILOT",
          tLightData.Targets[1]
        },
        "A"
      },
      {
        "DELAY",
        {3}
      },
      {
        "JUMPTORANDOM",
        {
          "B",
          "C",
          "D"
        }
      },
      {
        "FOCUS_SEARCHER",
        {
          tLightData.Turret,
          "PILOT",
          tLightData.Targets[2]
        },
        "B"
      },
      {
        "DELAY",
        {3}
      },
      {
        "JUMPTORANDOM",
        {
          "A",
          "C",
          "D"
        }
      },
      {
        "FOCUS_SEARCHER",
        {
          tLightData.Turret,
          "PILOT",
          tLightData.Targets[3]
        },
        "C"
      },
      {
        "DELAY",
        {3}
      },
      {
        "JUMPTORANDOM",
        {
          "A",
          "B",
          "D"
        }
      },
      {
        "FOCUS_SEARCHER",
        {
          tLightData.Turret,
          "PILOT",
          tLightData.Targets[4]
        },
        "D"
      },
      {
        "DELAY",
        {3}
      },
      {
        "JUMPTORANDOM",
        {
          "A",
          "B",
          "C"
        }
      }
    }
    ScriptSequence.Run(tLightData.SelfDummy, tSearcherSequence)
  end
end

function BASE_LaVillette:StopRaidSearchLights()
  Tips.Print(self, "BASE_LaVillette.StopRaidSearchLights()")
  for sLabel, tLightData in pairs(self.tSearchLights) do
    local tSearcherSequence = {
      {
        "DELAYFORRANDOM",
        {1, 3}
      },
      {
        "ENABLE_SEARCHER",
        {
          tLightData.Turret,
          "PILOT",
          false
        }
      },
      {
        "FOCUS_SEARCHER",
        {
          tLightData.Turret,
          "PILOT",
          tLightData.OffTarget
        }
      }
    }
    ScriptSequence.Run(tLightData.SelfDummy, tSearcherSequence)
  end
end

function BASE_LaVillette:StartBomberCinematics()
  Tips.Print(self, "* BOMBER CINEMATICS STARTED  *")
  if Joe.IsCurrentMission("Paris_1_Mission_1B") == true then
    for i, sCin in ipairs(self.tBomberCinematics) do
      Cin.PlayCinematic(sCin, false)
    end
  else
  end
  if Joe.IsCurrentMission("Paris_1_Mission_1B") == true then
    for i, sCin in ipairs(self.tRepeatingBomberCinematics) do
      Cin.PlayCinematic(sCin, true)
    end
  else
  end
end

function BASE_LaVillette:BombALLQs()
  EVENT_Timer("BASE_LaVillette.BombQ1", self, 3)
  EVENT_Timer("BASE_LaVillette.BombQ1B", self, 4)
  EVENT_Timer("BASE_LaVillette.BombQ1C", self, 5)
  EVENT_Timer("BASE_LaVillette.BombQ1D", self, 8)
  EVENT_Timer("BASE_LaVillette.BombQ1E", self, 10)
  EVENT_Timer("BASE_LaVillette.BombQ1", self, 13)
  EVENT_Timer("BASE_LaVillette.BombQ1B", self, 14)
  EVENT_Timer("BASE_LaVillette.BombQ1C", self, 15)
  EVENT_Timer("BASE_LaVillette.BombQ1D", self, 18)
  EVENT_Timer("BASE_LaVillette.BombQ1E", self, 20)
  EVENT_Timer("BASE_LaVillette.BombQ2", self, 2)
  EVENT_Timer("BASE_LaVillette.BombQ2B", self, 6)
  EVENT_Timer("BASE_LaVillette.BombQ2C", self, 7)
  EVENT_Timer("BASE_LaVillette.BombQ2D", self, 9)
  EVENT_Timer("BASE_LaVillette.BombQ2", self, 12)
  EVENT_Timer("BASE_LaVillette.BombQ2B", self, 16)
  EVENT_Timer("BASE_LaVillette.BombQ2C", self, 17)
  EVENT_Timer("BASE_LaVillette.BombQ2D", self, 19)
  EVENT_Timer("BASE_LaVillette.BombQ3", self, 2.5)
  EVENT_Timer("BASE_LaVillette.BombQ3B", self, 4.5)
  EVENT_Timer("BASE_LaVillette.BombQ3C", self, 7.5)
  EVENT_Timer("BASE_LaVillette.BombQ3D", self, 8.5)
  EVENT_Timer("BASE_LaVillette.BombQ3", self, 12.5)
  EVENT_Timer("BASE_LaVillette.BombQ3B", self, 14.5)
  EVENT_Timer("BASE_LaVillette.BombQ3C", self, 17.5)
  EVENT_Timer("BASE_LaVillette.BombQ3D", self, 18.5)
  EVENT_Timer("BASE_LaVillette.BombQ4", self, 1.5)
  EVENT_Timer("BASE_LaVillette.BombQ4B", self, 3.5)
  EVENT_Timer("BASE_LaVillette.BombQ4C", self, 6.5)
  EVENT_Timer("BASE_LaVillette.BombQ4D", self, 9.5)
  EVENT_Timer("BASE_LaVillette.BombQ4", self, 11.5)
  EVENT_Timer("BASE_LaVillette.BombQ4B", self, 13.5)
  EVENT_Timer("BASE_LaVillette.BombQ4C", self, 16.5)
  EVENT_Timer("BASE_LaVillette.BombQ4D", self, 19.5)
  BASE_LaVillette.BombNoQ(self)
end

function BASE_LaVillette:BombQ1()
  Paris_1_Mission_1B.BombQuarter1(Paris_1_Mission_1B)
end

function BASE_LaVillette:BombQ1B()
  Paris_1_Mission_1B.BombQuarter1B(Paris_1_Mission_1B)
end

function BASE_LaVillette:BombQ1C()
  Paris_1_Mission_1B.BombQuarter1C(Paris_1_Mission_1B)
end

function BASE_LaVillette:BombQ1D()
  Paris_1_Mission_1B.BombQuarter1D(Paris_1_Mission_1B)
end

function BASE_LaVillette:BombQ1E()
  Paris_1_Mission_1B.BombQuarter1E(Paris_1_Mission_1B)
end

function BASE_LaVillette:BombQ2()
  Paris_1_Mission_1B.BombQuarter2(Paris_1_Mission_1B)
end

function BASE_LaVillette:BombQ2B()
  Paris_1_Mission_1B.BombQuarter2B(Paris_1_Mission_1B)
end

function BASE_LaVillette:BombQ2C()
  Paris_1_Mission_1B.BombQuarter2C(Paris_1_Mission_1B)
end

function BASE_LaVillette:BombQ2D()
  Paris_1_Mission_1B.BombQuarter2D(Paris_1_Mission_1B)
end

function BASE_LaVillette:BombQ3()
  Paris_1_Mission_1B.BombQuarter3(Paris_1_Mission_1B)
end

function BASE_LaVillette:BombQ3B()
  Paris_1_Mission_1B.BombQuarter3B(Paris_1_Mission_1B)
end

function BASE_LaVillette:BombQ3C()
  Paris_1_Mission_1B.BombQuarter3C(Paris_1_Mission_1B)
end

function BASE_LaVillette:BombQ3D()
  Paris_1_Mission_1B.BombQuarter3D(Paris_1_Mission_1B)
end

function BASE_LaVillette:BombQ4()
  Paris_1_Mission_1B.BombQuarter4(Paris_1_Mission_1B)
end

function BASE_LaVillette:BombQ4B()
  Paris_1_Mission_1B.BombQuarter4B(Paris_1_Mission_1B)
end

function BASE_LaVillette:BombQ4C()
  Paris_1_Mission_1B.BombQuarter4C(Paris_1_Mission_1B)
end

function BASE_LaVillette:BombQ4D()
  Paris_1_Mission_1B.BombQuarter4D(Paris_1_Mission_1B)
end

function BASE_LaVillette:BombNoQ()
  Paris_1_Mission_1B.BombNoQuarter(Paris_1_Mission_1B)
end

function BASE_LaVillette:StopBomberCinematics()
  Tips.Print(self, "* BOMBER CINEMATICS STOPPED  *")
  for i, sCin in ipairs(self.tRepeatingBomberCinematics) do
    Cin.StopCinematic(sCin, false)
  end
end

function BASE_LaVillette:StopAirRaid(a_bSetTimeout)
  Tips.Print(self, "*** AIR RAID COMPLETE ***")
  self.bIsAirRaidActive = false
  Sound.DeactivateSoundEmitter(Handle(self.sSiren))
  local tDryFireDelay = {
    EventType = "TimerEvent",
    Time = self.nPostRaidDryFireDelay
  }
  BASE_LaVillette.AddEvent(self, Util.CreateEvent(tDryFireDelay, "BASE_LaVillette.ForceCannonDryFire", self))
  local tJobChangeDelay = {
    EventType = "TimerEvent",
    Time = self.nPostRaidDismountDelay
  }
  BASE_LaVillette.AddEvent(self, Util.CreateEvent(tJobChangeDelay, "BASE_LaVillette.CancelAirRaidJobs", self))
  local tMusicReleaseDelay = {
    EventType = "TimerEvent",
    Time = self.nMusicReleaseDelay
  }
  Util.CreateEvent(tMusicReleaseDelay, "BASE_LaVillette.ReleaseMusicState", self)
  if a_bSetTimeout ~= nil and a_bSetTimeout == true then
    BASE_LaVillette.StartRaidDowntimeTimer(self)
  end
end

function BASE_LaVillette:ReleaseMusicState()
  Sound.SetMusicLocale("Default")
end

function BASE_LaVillette:CancelAirRaidJobs()
  BASE_LaVillette.PlaySound("vo_mis_P1M1b_AnnounceAirRaidStandDown_NaziAdministrator_01")
  Bunker.CancelJob(self.tBunkers.East, "FLAKCANNON_NORTH")
  Bunker.CancelJob(self.tBunkers.West, "FLAKCANNON_SOUTH")
  Bunker.CancelJob(self.tBunkers.West, "FLAKCANNON_WEST")
  Bunker.CancelJob(self.tBunkers.West, "FLAKCANNON_EAST")
  Bunker.CancelJob(self.tBunkers.West, "AA_SOUTH")
  Bunker.CancelJob(self.tBunkers.West, "AA_WEST")
  Bunker.CancelJob(self.tBunkers.East, "AA_NORTH")
  Bunker.StartJob(self.tBunkers.West, "PATROL_TEST_A")
  Bunker.StartJob(self.tBunkers.West, "PATROL_TEST_B")
end

function BASE_LaVillette:OnExit()
  Util.KillEvent("LaVilletteAirRaidTimer")
  BASE_LaVillette.StopBomberCinematics(self)
  Sound.ReleaseSoundBank("m_P1M1b_inGame.bnk")
  Sound.ReleaseSoundBank("m_P1M1b_start.bnk")
  BASE_LaVillette.ClearEvents(self)
  Tips.Print(self, "OnExit!")
end

function BASE_LaVillette:SetupPrison()
  self.tPrisonDoors = {
    "PARIS\\area01\\lavillette\\occupation\\prison\\PrisonDoorA",
    "PARIS\\area01\\lavillette\\occupation\\prison\\PrisonDoorB",
    "PARIS\\area01\\lavillette\\occupation\\prison\\PrisonDoorC",
    "PARIS\\area01\\lavillette\\occupation\\prison\\PrisonDoorD"
  }
  self.bIsPrisonDoorOpen = false
  self.tPrisonTriggers = {
    "PARIS\\area01\\lavillette\\occupation\\prison\\PT_PrisonDoorA",
    "PARIS\\area01\\lavillette\\occupation\\prison\\PT_PrisonDoorB",
    "PARIS\\area01\\lavillette\\occupation\\prison\\PT_PrisonDoorC",
    "PARIS\\area01\\lavillette\\occupation\\prison\\PT_PrisonDoorD"
  }
  self.tPrisoners = {
    "PARIS\\area01\\lavillette\\occupation\\prison\\Prisoner1",
    "PARIS\\area01\\lavillette\\occupation\\prison\\Prisoner2",
    "PARIS\\area01\\lavillette\\occupation\\prison\\Prisoner3"
  }
  self.tPrisonerMoveLocations = {
    "PARIS\\area01\\lavillette\\occupation\\prison\\LOC_DoorA",
    "PARIS\\area01\\lavillette\\occupation\\prison\\LOC_DoorB",
    "PARIS\\area01\\lavillette\\occupation\\prison\\LOC_DoorC",
    "PARIS\\area01\\lavillette\\occupation\\prison\\LOC_DoorD"
  }
  self.sPrisonerMovePrefix = "PARIS\\area01\\lavillette\\occupation\\prison\\LOC_Door"
  local tDoorA = {
    EventType = "OnTriggerEnter",
    Target = Handle("PARIS\\area01\\lavillette\\occupation\\prison\\PT_PrisonDoorA")
  }
  self.sPrisonLever = "PARIS\\area01\\lavillette\\occupation\\prison\\CellDoorLever"
end

function BASE_LaVillette:OnPrisonLeverStreamsIn()
  local tPullEvent = {
    EventType = "OnActorComplete",
    Target = Handle(self.sPrisonLever)
  }
  Util.CreateEvent(tPullEvent, "BASE_LaVillette.OnPrisonLeverPulled", self)
end

function BASE_LaVillette:OnPrisonLeverPulled()
  Tips.Print(self, "OnPrisonLeverPulled()")
  self.bIsPrisonDoorOpen = true
end

function BASE_LaVillette.FreePrisoners(a_vBaseManagerHandle)
  if IsMissionActive("Paris_1_Mission_1B") == false then
    Tips.Print(self, "FreePrisoners()")
    local tBaseSelf = Tips.GetSelf(a_vBaseManagerHandle)
    local tRandomThanks = {
      "Thank you!",
      "We're with you now!",
      "Well done!",
      "Let's give them hell!"
    }
  end
end

function BASE_LaVillette:StartPrisonDoorSequence()
  Tips.Print(self, "StartPrisonDoorSequence()")
  local tPrisonDoorSequence = {
    {
      "ACTUATE",
      {
        self.tPrisonDoors[3]
      }
    }
  }
  DestructionSequence.Run(tPrisonDoorSequence, "BASE_LaVillette.FreePrisoners", {
    self.hController
  })
end

function BASE_LaVillette:OnPlayerEntersPrisonTrigger(a_tCallbackData, a_sDoorID)
  if self.bIsPrisonDoorOpen == false then
    BASE_LaVillette.MovePrisonerGroup(self, a_sDoorID)
  end
end

function BASE_LaVillette:MovePrisonerGroup(a_sDoor)
  for i, sPrisoner in ipairs(self.tPrisoners) do
    local hPrisoner = Handle(sPrisoner)
    local hDestination = Handle(self.sPrisonerMovePrefix .. a_sDoor .. tostring(i))
    local tSequence = {
      {
        "SETIDLESCRIPTED",
        {true}
      },
      {
        "RUNTOOBJECT",
        {hDestination}
      },
      {
        "DELAY",
        {1}
      },
      {
        "MATCHFACING",
        {hDestination}
      }
    }
    ScriptSequence.Run(hPrisoner, tSequence)
  end
end

function BASE_LaVillette:SetupObjectPaths()
  self.tBunkers = {}
  self.tBunkers.West = "PARIS\\area01\\lavillette\\occupation\\Bunker_West\\BunkerManager"
  self.tBunkers.WestFrontStep = "PARIS\\area01\\lavillette\\occupation\\Bunker_West\\LOC_FrontStep"
  self.tBunkers.East = "PARIS\\area01\\lavillette\\occupation\\Bunker_East\\BunkerManager"
  self.tBunkers.EastFrontStep = "PARIS\\area01\\lavillette\\occupation\\Bunker_East\\LOC_FrontStep"
  self.tFlakGuns = {}
  self.tFlakGuns.North = {
    Gun = "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunNorth\\Seat",
    Targets = {
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_North1",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_North2",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_North3",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_North4"
    },
    BoardPoint = "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunNorth\\LOC_Board"
  }
  self.tFlakGuns.South = {
    Gun = "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunSouth\\Seat",
    Targets = {
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_South1",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_South2",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_South3",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_South4"
    },
    BoardPoint = "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunSouth\\LOC_Board"
  }
  self.tFlakGuns.West = {
    Gun = "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunWest\\Seat",
    Targets = {
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_West1",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_West2",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_West3",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_West4"
    },
    BoardPoint = "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunWest\\LOC_Board"
  }
  self.tFlakGuns.East = {
    Gun = "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunEast\\Seat",
    Targets = {
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_North1",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_North2",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_North3",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_North4"
    },
    BoardPoint = "PARIS\\area01\\lavillette\\occupation\\defense\\FlakGunEast\\LOC_Board"
  }
  self.tAAGuns = {}
  self.tAAGuns.South = {
    Gun = "PARIS\\area01\\lavillette\\occupation\\defense\\AAGun_South\\Seat",
    Targets = {
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_South1",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_South2",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_South3",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_South4"
    },
    BoardPoint = "PARIS\\area01\\lavillette\\occupation\\LOC_SouthAABoardPoint"
  }
  self.tAAGuns.North = {
    Gun = "PARIS\\area01\\lavillette\\occupation\\defense\\AAGun_North\\Seat",
    Targets = {
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_Rear1",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_Rear2",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_Rear3",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_Rear4"
    },
    BoardPoint = "PARIS\\area01\\lavillette\\occupation\\LOC_NorthAABoardPoint"
  }
  self.tAAGuns.West = {
    Gun = "PARIS\\area01\\lavillette\\occupation\\defense\\AAGun_West\\Seat",
    Targets = {
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_West1",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_West2",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_West3",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_West4"
    },
    BoardPoint = "PARIS\\area01\\lavillette\\occupation\\LOC_WestAABoardPoint"
  }
  self.sSiren = "PARIS\\area01\\lavillette\\occupation\\Siren_AirRaid"
  self.tSearchLights = {}
  self.tSearchLights.WestA = {
    Turret = "PARIS\\area01\\lavillette\\occupation\\defense\\LIGHT_WestA\\Turret",
    SelfDummy = "PARIS\\area01\\lavillette\\occupation\\defense\\SELF_West_SpotlightA",
    Targets = {
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_West1",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_West2",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_West3",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_West4"
    },
    OffTarget = "PARIS\\area01\\lavillette\\occupation\\defense\\OFFTARGET_WestA"
  }
  self.tSearchLights.WestB = {
    Turret = "PARIS\\area01\\lavillette\\occupation\\defense\\LIGHT_WestB\\Turret",
    SelfDummy = "PARIS\\area01\\lavillette\\occupation\\defense\\SELF_West_SpotlightB",
    Targets = {
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_South1",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_South2",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_South3",
      "PARIS\\area01\\lavillette\\occupation\\defense\\TARGET_South4"
    },
    OffTarget = "PARIS\\area01\\lavillette\\occupation\\defense\\OFFTARGET_WestB"
  }
end

function BASE_LaVillette:SetupPlayerVehicleEnterEvent()
  local tEnteredVehicleEvent = {
    Target = Handle("Saboteur"),
    EventType = "OnVehicleEnter"
  }
  local eEnterVehicle = Util.CreateEvent(tEnteredVehicleEvent, "BASE_LaVillette.OnPlayerEntersVehicle", self, {}, true)
  BASE_LaVillette.AddEvent(self, eEnterVehicle)
end

function BASE_LaVillette:OnPlayerEntersVehicle(a_tData)
  local hSeat = a_tData[2]
  local sAA_South = "PARIS\\area01\\lavillette\\occupation\\defense\\AAGun_South\\Seat"
  local hAA_South = Vehicle.GetSeatActor(Handle(sAA_South), "PILOT")
  local sAA_West = "PARIS\\area01\\lavillette\\occupation\\defense\\AAGun_West\\Seat"
  local hAA_West = Vehicle.GetSeatActor(Handle(sAA_West), "PILOT")
  local sThisSpawnTarget = " "
  local sThisDeliveryPath = " "
  local sThisExitPath = " "
  if hSeat == hAA_South then
    sThisSpawnTarget = "PARIS\\area01\\lavillette\\occupation\\LOC_Spawn_TruckSouthGate"
    sThisDeliveryPath = "PARIS\\area01\\lavillette\\occupation\\PA_TruckSouthGate_Enter"
    sThisExitPath = "PARIS\\area01\\lavillette\\occupation\\PA_TruckSouthGate_Exit"
  elseif hSeat == hAA_West then
    sThisSpawnTarget = "PARIS\\area01\\lavillette\\occupation\\LOC_Spawn_TruckWestGate"
    sThisDeliveryPath = "PARIS\\area01\\lavillette\\occupation\\PA_TruckWestGate_Enter"
    sThisExitPath = "PARIS\\area01\\lavillette\\occupation\\PA_TruckWestGate_Exit"
  end
  if self.bWorldIsEscalated == true and (hSeat == hAA_South or hSeat == hAA_West) then
    local tConfig = {
      cVehicleType = cVEH_OPEL,
      tSeatConfig = "Human_SS_Heavy_MG",
      vSpawnTarget = sThisSpawnTarget,
      sDeliveryPath = sThisDeliveryPath,
      sExitPath = sThisExitPath,
      bForceSpawn = true,
      bUrgentDelivery = true,
      cUnboardType = cDROPOFF_PASSENGERS_ALL,
      cDespawnType = cDESPAWN_ONEXIT_NOLOSCHECK,
      nPathSpeed = 35,
      tOnUnboard = {}
    }
    Veh.SpawnDelivery(self, tConfig)
  end
end

function BASE_LaVillette:StartAnnouncementTimer()
  if self and self.tMinAnnouncementTime and self.tMaxAnnouncementTime then
    local nChosenTime = math.random(self.tMinAnnouncementTime, self.tMaxAnnouncementTime)
    local tTimerEvent = {EventType = "TimerEvent", Time = nChosenTime}
    local eAnnounce = Util.CreateEvent(tTimerEvent, "BASE_LaVillette.AttemptAnnouncement", self)
    BASE_LaVillette.AddEvent(self, eAnnounce)
    Tips.Print(self, "New announcement attempt in " .. nChosenTime .. " seconds.")
  end
end

function BASE_LaVillette:AttemptAnnouncement()
  if self and self.bIsAirRaidActive == false and self.bWorldIsEscalated == false then
    local hSoundEmitter = Handle("PARIS\\area01\\lavillette\\occupation\\Siren_AirRaid")
    local sAnnouncementName = Tips.GetRandomElement(self.tAnnouncements)
    Tips.Print(self, "Attempting to play random announcement)")
    Sound.AttachSoundEvent(hSoundEmitter, sAnnouncementName)
  end
  BASE_LaVillette.StartAnnouncementTimer(self)
end

function BASE_LaVillette:SetupCombatTriggers()
  self.tTetherLocs = {}
  self.tTetherLocs.WestAA = {
    Locator = "PARIS\\area01\\lavillette\\occupation\\ai\\TETHER_WestAA",
    Distance = 12
  }
  self.tTetherLocs.NorthAA = {
    Locator = "PARIS\\area01\\lavillette\\occupation\\ai\\TETHER_NorthAA",
    Distance = 12
  }
  self.tTetherLocs.NorthCatwalkA = {
    Locator = "PARIS\\area01\\lavillette\\occupation\\ai\\TETHER_NorthCatwalkA",
    Distance = 6
  }
  self.tTetherLocs.NorthCatwalkB = {
    Locator = "PARIS\\area01\\lavillette\\occupation\\ai\\TETHER_NorthCatwalkB",
    Distance = 6
  }
  self.tTetherLocs.NorthCatwalkC = {
    Locator = "PARIS\\area01\\lavillette\\occupation\\ai\\TETHER_NorthCatwalkC",
    Distance = 6
  }
  self.tCombatAreas = {}
  self.tCombatAreas.NorthCatwalk = "PARIS\\area01\\lavillette\\occupation\\ai\\CT_NorthCatwalk"
  self.tCombatAreas.WestAA = "PARIS\\area01\\lavillette\\occupation\\ai\\CT_AAWest"
  self.tCombatAreas.NorthAA = "PARIS\\area01\\lavillette\\occupation\\ai\\CT_AANorth"
  self.tTetherableJobs = {
    "PATROL_TEST_A",
    "PATROL_TEST_B"
  }
  BASE_LaVillette.CreateCombatLink(self, "NorthCatwalk", {"NorthAA", "WestAA"})
  BASE_LaVillette.CreateCombatLink(self, "WestAA", {
    "NorthCatwalkA",
    "NorthCatwalkB",
    "NorthCatwalkC"
  })
  BASE_LaVillette.CreateCombatLink(self, "NorthAA", {
    "NorthCatwalkA",
    "NorthCatwalkB",
    "NorthCatwalkC"
  })
end

function BASE_LaVillette:SetCombatLinkable(a_vActor)
  if not self.tCombatLinkableActors then
    self.tCombatLinkableActors = {}
  end
  table.insert(self.tCombatLinkableActors, Handle(a_vActor))
end

function BASE_LaVillette:PruneCombatLinkableActorList()
  for i, hActor in self.tCombatLinkableActors, nil, nil do
    if Util.IsHandleValid(hActor) == false or Actor.IsAlive(hActor) == false then
      table.remove(self.tCombatLinkableActors, i)
    end
  end
end

function BASE_LaVillette:CreateCombatLink(a_sAreaKey, a_tTetherList)
  if self.tCombatAreas[a_sAreaKey] == nil then
    Util.Assert(false, "Trying to create a combat link with a non-existent area key!")
    return
  end
  if not a_tTetherList then
    Util.Assert(false, "Trying to create a combat link without any tether locations!")
  end
  local tOnTriggerEnterEvent = {
    EventType = "OnTriggerEnter",
    Target = Handle(self.tCombatAreas[a_sAreaKey])
  }
  local eOnTriggerEnter = Util.CreateEvent(tOnTriggerEnterEvent, "BASE_LaVillette.OnPlayerEntersCombatTrigger", self, {a_sAreaKey, a_tTetherList}, true)
  BASE_LaVillette.AddEvent(self, eOnTriggerEnter)
  local tOnTriggerExitEvent = {
    EventType = "OnTriggerExit",
    Target = Handle(self.tCombatAreas[a_sAreaKey])
  }
  local eOnTriggerExit = Util.CreateEvent(tOnTriggerExitEvent, "BASE_LaVillette.OnPlayerExitsCombatTrigger", self, {a_sAreaKey}, true)
  BASE_LaVillette.AddEvent(self, eOnTriggerExit)
end

function BASE_LaVillette:OnPlayerEntersCombatTrigger(a_tData, a_sAreaKey, a_tTetherList)
  Tips.Print(self, "Player has ENTERED a combat trigger: " .. a_sAreaKey)
  BASE_LaVillette.SetNewCombatTethers(self, a_tTetherList)
end

function BASE_LaVillette:SetNewCombatTethers(a_tTetherList)
  for i, sJobName in ipairs(self.tTetherableJobs) do
    Tips.Print(self, "Finding Job called " .. sJobName .. " in West bunker.")
    local hWestActor = Bunker.GetJobHolder(self.tBunkers.West, sJobName)
    if hWestActor then
      BASE_LaVillette.MoveToTetherPos(self, hWestActor, a_tTetherList)
    end
    Tips.Print(self, "Finding Job called " .. sJobName .. " in East bunker.")
    local hEastActor = Bunker.GetJobHolder(self.tBunkers.East, sJobName)
    if hEastActor then
      BASE_LaVillette.MoveToTetherPos(self, hEastActor, a_tTetherList)
    end
  end
end

function BASE_LaVillette:OnPlayerExitsCombatTrigger(a_tData, a_sAreaKey)
  Tips.Print(self, "Player has EXITED a combat trigger: " .. a_sAreaKey)
end

function BASE_LaVillette:MoveToTetherPos(a_hActor, a_tTetherList)
  if Actor.IsAlive(a_hActor) == false then
    return
  end
  local sTetherKey = Tips.GetRandomElement(a_tTetherList)
  Tips.Print(self, "Tethering " .. tostring(a_hActor) .. " to " .. sTetherKey)
  Combat.SetTether(a_hActor, x, y, z, self.tTetherLocs[sTetherKey].Distance)
  Nav.MoveToObject(a_hActor, Handle(self.tTetherLocs[sTetherKey].Locator), self.tTetherLocs[sTetherKey].Distance / 2, true)
end

function BASE_LaVillette:OnArriveAtTetherPos(a_hActor, a_tTetherList)
end

function BASE_LaVillette:AddEvent(a_eEvent)
  if not self.tEvents then
    self.tEvents = {}
  end
  table.insert(self.tEvents, a_eEvent)
end

function BASE_LaVillette:ClearEvents()
  if self.tEvents then
    for i, e in ipairs(self.tEvents) do
      Util.KillEvent(e)
    end
    self.tEvents = nil
  end
end

function BASE_LaVillette.PlaySound(a_sSound, a_sSecondSound)
  if a_sSound ~= nil then
    local hSoundEmitter = Handle("PARIS\\area01\\lavillette\\occupation\\Siren_AirRaid")
    Sound.AttachSoundEvent(hSoundEmitter, a_sSound)
  elseif a_sSecondSound ~= nil then
    local hSoundEmitter = Handle("PARIS\\area01\\lavillette\\occupation\\Siren_AirRaid")
    Sound.AttachSoundEvent(hSoundEmitter, a_sSecondSound)
  end
end

function BASE_LaVillette:SetupFlakJob(a_sJobName, a_sFlakIdent, a_sBunkerIdent)
end

function BASE_LaVillette.SetPrisonersJoinSquad(a_bJoin)
end
