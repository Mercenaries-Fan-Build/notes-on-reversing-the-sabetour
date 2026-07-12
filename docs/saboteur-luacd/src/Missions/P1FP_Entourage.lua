if P1FP_Entourage == nil then
  P1FP_Entourage = SabTaskObjective:Create()
  P1FP_Entourage.sPATH = "Missions\\Freeplay\\p1\\mis_belle_se_entourage\\"
  P1FP_Entourage:Configure({
    TaskCount = 99,
    tDependencyList = {},
    sSaveMissionNameID = "MissionNames_Text.P1FP_Entourage",
    sActNameID = "MissionNames_Text.ACT_LeCrochet",
    tUnlockList = {
      "P2FP_MadeleineSniper"
    },
    bFreeplay = true,
    sStarter = "Couteau_LaVillette_Interior",
    sConvFile = "P1FP_Entourage_Start",
    sMissionStartTime = cNIGHT,
    bFreezeTimeScale = bFREEZE,
    tSMEDNodes = {
      P1FP_Entourage.sPATH .. "task",
      P1FP_Entourage.sPATH .. "main",
      P1FP_Entourage.sPATH .. "paths"
    }
  })
end

function P1FP_Entourage:STARTER_Setup()
end

function P1FP_Entourage:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "FP.ENTOURAGE"
  self.bDebugMode = false
  self.GENERAL_Setup(self)
  self.SetupCheckpoint(self, 3)
end

function P1FP_Entourage:GENERAL_Setup()
  self.bStreamEventDone = false
  self.bDeliveredMessage = false
end

function P1FP_Entourage:SetupVariables()
  self.hSab = self.hSab or Handle("Saboteur")
  self.bDeliveredMessage = self.bDeliveredMessage or false
  self.sFindLoc = self.sFindLoc or self.sPATH .. "task\\LOC_FindLoc"
  self.sFindTrig = self.sFindTrig or self.sPATH .. "task\\PT_FindTrig"
  self.sDummyTrig = self.sDummyTrig or self.sPATH .. "main\\PT_DummyTrig"
  self.sLeader = self.sLeader or self.sPATH .. "main\\Leader"
  self.sFollowerA = self.sFollowerA or self.sPATH .. "main\\FollowerA"
  self.sFollowerB = self.sFollowerB or self.sPATH .. "main\\FollowerB"
  self.sFollowerC = self.sFollowerC or self.sPATH .. "main\\FollowerC"
  self.tEntourage = self.tEntourage or {
    self.sLeader,
    self.sFollowerA,
    self.sFollowerB,
    self.sFollowerC
  }
  self.nEntStreamed = self.nEntStreamed or 0
  self.bGuardsHelping = self.bGuardsHelping or false
  self.tPaths = self.tPaths or {
    self.sPATH .. "paths\\PA_LeaderPath01",
    self.sPATH .. "paths\\PA_LeaderPath02",
    self.sPATH .. "paths\\PA_LeaderPath03",
    self.sPATH .. "paths\\PA_LeaderPath04",
    self.sPATH .. "paths\\PA_LeaderPath05",
    self.sPATH .. "paths\\PA_LeaderPath06",
    self.sPATH .. "paths\\PA_LeaderPath07",
    self.sPATH .. "paths\\PA_LeaderPath08",
    self.sPATH .. "paths\\PA_LeaderPath09",
    self.sPATH .. "paths\\PA_LeaderPath10",
    self.sPATH .. "paths\\PA_LeaderPath11",
    self.sPATH .. "paths\\PA_LeaderPath12",
    self.sPATH .. "paths\\PA_LeaderPath13",
    self.sPATH .. "paths\\PA_LeaderPath14",
    self.sPATH .. "paths\\PA_LeaderPath15"
  }
  self.tPissSpots = self.tPissSpots or {
    self.sPATH .. "paths\\LOC_PissSpot01",
    self.sPATH .. "paths\\LOC_PissSpot02"
  }
  self.tLeaderFace = self.tLeaderFace or {
    self.sPATH .. "paths\\LOC_LeaderFace01",
    self.sPATH .. "paths\\LOC_LeaderFace02",
    "",
    self.tPissSpots[1],
    "",
    self.sPATH .. "paths\\LOC_LeaderFace03",
    "",
    self.sPATH .. "paths\\LOC_LeaderFace04",
    self.tPissSpots[2],
    "",
    self.sPATH .. "paths\\LOC_LeaderFace05",
    self.sPATH .. "paths\\LOC_LeaderFace06",
    self.sPATH .. "paths\\LOC_LeaderFace07",
    "",
    self.sPATH .. "paths\\LOC_LeaderFace08"
  }
  self.tEntStops = self.tEntStops or {
    {
      self.sPATH .. "paths\\LOC_EntStop01A",
      self.sPATH .. "paths\\LOC_EntStop01B",
      self.sPATH .. "paths\\LOC_EntStop01C"
    },
    {
      self.sPATH .. "paths\\LOC_EntStop02A",
      self.sPATH .. "paths\\LOC_EntStop02B",
      self.sPATH .. "paths\\LOC_EntStop02C"
    },
    {
      self.sPATH .. "paths\\LOC_EntStop03A",
      self.sPATH .. "paths\\LOC_EntStop03B",
      self.sPATH .. "paths\\LOC_EntStop03C"
    },
    {
      self.sPATH .. "paths\\LOC_EntStop04A",
      self.sPATH .. "paths\\LOC_EntStop04B",
      self.sPATH .. "paths\\LOC_EntStop04C"
    },
    {
      self.sPATH .. "paths\\LOC_EntStop05A",
      self.sPATH .. "paths\\LOC_EntStop05B",
      self.sPATH .. "paths\\LOC_EntStop05C"
    },
    {
      self.sPATH .. "paths\\LOC_EntStop06A",
      self.sPATH .. "paths\\LOC_EntStop06B",
      self.sPATH .. "paths\\LOC_EntStop06C"
    },
    {
      self.sPATH .. "paths\\LOC_EntStop07A",
      self.sPATH .. "paths\\LOC_EntStop07B",
      self.sPATH .. "paths\\LOC_EntStop07C"
    },
    {
      self.sPATH .. "paths\\LOC_EntStop08A",
      self.sPATH .. "paths\\LOC_EntStop08B",
      self.sPATH .. "paths\\LOC_EntStop08C"
    },
    {
      self.sPATH .. "paths\\LOC_EntStop09A",
      self.sPATH .. "paths\\LOC_EntStop09B",
      self.sPATH .. "paths\\LOC_EntStop09C"
    }
  }
  self.tSuspZones = self.tSuspZones or {
    self.sPATH .. "main\\PT_Susp01",
    self.sPATH .. "main\\PT_Susp02",
    self.sPATH .. "main\\PT_Susp03",
    self.sPATH .. "main\\PT_Susp04",
    self.sPATH .. "main\\PT_Susp05",
    self.sPATH .. "main\\PT_Susp06",
    self.sPATH .. "main\\PT_Susp07",
    self.sPATH .. "main\\PT_Susp08",
    self.sPATH .. "main\\PT_Susp09"
  }
  self.tFollowers = self.tFollowers or {
    self.sFollowerA,
    self.sFollowerB,
    self.sFollowerC
  }
  self.nCurrentLoc = self.nCurrentLoc or 1
  self.nLastLoc = self.nLastLoc or 1
  self.nEntIndex = self.nEntIndex or 1
  if self.eSeanDeath then
    Util.KillEvent(self.eSeanDeath)
    self.eSeanDeath = nil
  end
  local tDeathEvent = {
    EventType = "DeathEvent",
    ObjectHandle = self.hSab
  }
  self.eSeanDeath = Util.CreateEvent(tDeathEvent, "P1FP_Entourage.MissionCleanup", self)
  for i, sZone in ipairs(self.tSuspZones) do
    Trigger.Enable(sZone, false)
  end
end

function P1FP_Entourage:ExitHQ()
  self:CreateTask({
    sName = "ExitHQ",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "ExitInterior",
    sInteriorName = "LaVillette",
    bInteriorTask = true,
    tOnComplete = {
      {
        self.SetupCheckpoint,
        {self, 1}
      }
    }
  })
end

function P1FP_Entourage:SetupCheckpoint(a_nCP)
  self.tSaveInfo.nCheckpointNum = a_nCP
  self.RegisterCheckpoint(self, "P1FP_Entourage.DoCheckpoint")
end

function P1FP_Entourage:DoCheckpoint()
  local nCP = self.tSaveInfo.nCheckpointNum
  self.SetupVariables(self)
  self.CheckStreamStatus(self)
  if nCP == 1 then
    if not self:IsMissionTaskActive("P1FP_Carbomb.TASK_GotoEntourage") then
      self.TASK_GotoEntourage(self)
    end
  elseif nCP == 3 then
    self.ExitHQ(self)
    self.TASK_GotoEntourage(self)
  elseif nCP == 4 then
    Sound.SetMusicLocale("fp_P1FP_Entourage")
    Sound.SetMusicLocale("fp_P1FP_Entourage", "arriveAtTarget")
    self.TASK_DeliverMessage(self)
  end
end

function P1FP_Entourage:CheckStreamStatus()
  self.bStreamEventDone = true
  self.SetupStreamEvent(self)
end

function P1FP_Entourage:TASK_GotoEntourage()
  self:CreateTask({
    sName = "P1FP_Entourage.TASK_GotoEntourage",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tDeliverObjs = {
      self.hSab
    },
    tDestRegion = {
      self.sFindTrig
    },
    tLocators = {
      self.sFindLoc
    },
    sObjectiveTextID = "P1FP_Entourage_Text.TASK_GotoEntourage",
    tOnActivate = {},
    tOnComplete = {
      {
        Cin.PlayConversation,
        {
          "P1FP_Entourage_Arrived"
        }
      },
      {
        self.SetupCheckpoint,
        {self, 4}
      }
    }
  })
end

function P1FP_Entourage:TASK_DeliverMessage()
  self:CreateTask({
    sName = "P1FP_Entourage_TASK_DeliverMessage",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P1FP_Entourage_Text.TASK_DeliverMessage",
    tLocators = {
      self.sLeader
    },
    tDestRegion = {
      self.sDummyTrig
    },
    tDeliverObjs = {
      self.hSab
    },
    bNoGPS = true,
    tOnActivate = {
      {
        self.SetupDeliverMsgProx,
        {self}
      }
    },
    tOnComplete = {
      {
        self.TASK_KillOfficer,
        {self}
      },
      {
        self.UpdateMsgVar,
        {self}
      }
    }
  })
end

function P1FP_Entourage:TASK_KillOfficer()
  self:CreateTask({
    sName = "P1FP_Entourage_TASK_KillOfficer",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P1FP_Entourage_Text.TASK_KillOfficer",
    tTgtInclude = {
      self.hLeader
    },
    bNoGPS = true,
    tOnComplete = {
      {
        self.CheckEscalation,
        {self}
      }
    }
  })
end

function P1FP_Entourage:TASK_LoseTheHeat()
  self:CreateTask({
    sName = "P1FP_Entourage.TASK_LoseTheHeat",
    sTaskType = "SabTaskObjectiveEscalation",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    sTaskSubType = "NONE",
    EscalationLevel = 0,
    tOnComplete = {
      {
        self.CheckEscalation,
        {self}
      }
    }
  })
end

function P1FP_Entourage:SetupStreamEvent()
  self.tEntourage = {
    self.sLeader,
    self.sFollowerA,
    self.sFollowerB,
    self.sFollowerC
  }
  for i, vEntity in ipairs(self.tEntourage) do
    if type(vEntity) == "string" or Util.IsObjectHandleValid(vEntity) == false then
      local eventName = "P1FP_Entourage_StreamEvent_" .. i
      local tStreamEvent = {
        EventType = "StreamEvent",
        Objects = {vEntity},
        WaitForGameObject = true
      }
      self:RegisterEvent(Util.CreateEvent(tStreamEvent, "P1FP_Entourage.EntityStreamed", self, {vEntity}))
    elseif Util.IsObjectHandleValid(vEntity) == true then
      self.EntityStreamed(self, vEntity)
    end
  end
end

function P1FP_Entourage:EntityStreamed(a_vEntity)
  self.nEntStreamed = self.nEntStreamed + 1
  local hEnt = Handle(a_vEntity)
  Combat.SetIdleScripted(hEnt, true)
  local tIdleExitEvent = {
    EventType = "OnIdleScriptedExit",
    Target = hEnt
  }
  if a_vEntity == self.sLeader or a_vEntity == Handle(self.sLeader) then
    self.eExitIdleEvent = Util.CreateEvent(tIdleExitEvent, "P1FP_Entourage.SoldierExitedIdle", self)
    self:RegisterEvent(self.eExitIdleEvent)
  else
    self:RegisterEvent(Util.CreateEvent(tIdleExitEvent, "P1FP_Entourage.SoldierExitedIdle", self))
  end
  if a_vEntity == self.sLeader or a_vEntity == Handle(self.sLeader) then
    self.hLeader = self.hLeader or hEnt
    self.tEntourage[1] = hEnt
    Object.SetInvincibleToAI(self.hLeader, true)
    local tDeathEvent = {
      EventType = "OnDeath",
      Target = self.hLeader
    }
    self:RegisterEvent(Util.CreateEvent(tDeathEvent, "P1FP_Entourage.LeaderDead", self))
  elseif a_vEntity == self.sFollowerA or a_vEntity == Handle(self.sFollowerA) then
    self.hFollowerA = self.hFollowerA or hEnt
    self.tEntourage[2] = hEnt
  elseif a_vEntity == self.sFollowerB or a_vEntity == Handle(self.sFollowerB) then
    self.hFollowerB = self.hFollowerB or hEnt
    self.tEntourage[3] = hEnt
  elseif a_vEntity == self.sFollowerC or a_vEntity == Handle(self.sFollowerC) then
    self.hFollowerC = self.hFollowerC or hEnt
    self.tEntourage[4] = hEnt
  end
  if self.nEntStreamed % 4 == 0 then
    self.nEntStreamed = 0
    self.JoinFormation(self, true)
    self.MoveEntourage(self)
  end
end

function P1FP_Entourage:JoinFormation(a_bOverrideDefaults)
  local x = {
    0,
    1,
    -1,
    0
  }
  local y = {
    0,
    0,
    0,
    0
  }
  local z = {
    0,
    -1,
    -1,
    -2
  }
  if a_bOverrideDefaults then
    x = {
      0,
      0,
      0,
      0
    }
    z = {
      0,
      -1,
      -2,
      -3
    }
  end
  for i = 2, 4 do
    if Object.IsAlive(self.tEntourage[i]) then
      Nav.EnterFormation(self.tEntourage[i], self.tEntourage[1], x[i], y[i], z[i])
    end
  end
end

function P1FP_Entourage:MoveEntourage()
  Nav.SetScriptedPath(self.hLeader, self.tPaths[self.nCurrentLoc], true, "P1FP_Entourage.UpdatePositions", self)
  Nav.SetScriptedPathMoveMode(self.hLeader, false)
  local nRandChance = math.random()
  self.nRollCompare = self.nRollCompare or 0.75
  if nRandChance > self.nRollCompare then
    self.nLastRoll = self.nRollCompare
    self.nRollCompare = 0.75
    local tTimerEvent = {
      EventType = "TimerEvent",
      Time = math.random(3, 5)
    }
    self.eStranskyTalkEvent = Util.CreateEvent(tTimerEvent, "P1FP_Entourage.StranskyRandomDialog", self)
    self:RegisterEvent(self.eStranskyTalkEvent)
  elseif self.nRollCompare - 0.1 < 0 then
    self.nRollCompare = 0
  else
    self.nRollCompare = self.nRollCompare - 0.1
  end
end

function P1FP_Entourage:UpdatePositions()
  local nLoc = self.nCurrentLoc
  local tGawkSpots = {
    1,
    2,
    6,
    11,
    12,
    13,
    15
  }
  local tPissWalk = {3, 7}
  local tPissSpots = {4, 9}
  local tGawkNoEnt = {8}
  local tSwitchConfig = {14}
  local tAnims = {
    "nazi_long_idle_drink",
    "civ_M_window_shop",
    "civ_M_window_shop2",
    "civ_M_wave_hello",
    "civ_M_look_at_time",
    "civ_M_check_watch"
  }
  local tAnimTimes = {
    14.567,
    5.967,
    6.033,
    1.033,
    5.133,
    3.133
  }
  if self.eStranskyTalkEvent then
    self.nRollCompare = self.nLastCompare
    self.nLastCompare = nil
    Util.KillEvent(self.eStranskyTalkEvent)
    self.eStranskyTalkEvent = nil
  end
  
  local function fSetEntourageToStop()
    for i = 2, 4 do
      Nav.ExitFormation(self.tEntourage[i])
      local hLoc = Handle(self.tEntStops[self.nEntIndex][i - 1])
      Nav.MoveToObject(self.tEntourage[i], hLoc, 0.5, false, "P1FP_Entourage.UpdateFacingDir", self, {
        i,
        self.nEntIndex
      })
    end
    self.nLastEntIndex = self.nEntIndex
    self.nEntIndex = self.nEntIndex + 1
  end
  
  if self.CompareLocs(nLoc, tGawkSpots) == true then
    fSetEntourageToStop()
    local nRoll = math.random(1, 100)
    local tTimerEvent = {EventType = "TimerEvent", Time = 10}
    if nRoll < 40 and nLoc ~= 13 then
      local nIndex = math.random(#tAnims)
      local sAnim = tAnims[nIndex]
      Actor.PlayAnimation(self.hLeader, sAnim, tAnimTimes[nIndex])
      if nIndex == 1 then
        tTimerEvent = {EventType = "TimerEvent", Time = 15}
      end
    end
    self.eInterTimerEvent = Util.CreateEvent(tTimerEvent, "P1FP_Entourage.UpdateVariables", self)
    self:RegisterEvent(self.eInterTimerEvent)
  elseif self.CompareLocs(nLoc, tPissWalk) == true then
    Cin.PlayConversation("P1FP_Entourage_StranskyLeak")
    fSetEntourageToStop()
    local tTimerEvent = {
      EventType = "TimerEvent",
      Time = math.random(5, 7)
    }
    self.eEntTalkEvent = Util.CreateEvent(tTimerEvent, "P1FP_Entourage.EntSayRandomDialog", self)
    self:RegisterEvent(self.eEntTalkEvent)
    self.UpdateVariables(self)
  elseif self.CompareLocs(nLoc, tPissSpots) == true then
    Actor.PlayAnimation(self.hLeader, "male_piss_idle_long", 14.3, false, Object.GetAngle(Handle(self.tPissSpots[1])), "P1FP_Entourage.UpdateVariables", self)
  elseif self.CompareLocs(nLoc, tGawkNoEnt) == true then
    local nRoll = math.random(1, 100)
    local tTimerEvent = {EventType = "TimerEvent", Time = 10}
    if nRoll < 40 then
      local nIndex = math.random(#tAnims)
      local sAnim = tAnims[nIndex]
      Actor.PlayAnimation(self.hLeader, sAnim, tAnimTimes[nIndex])
      if nIndex == 1 then
        tTimerEvent = {EventType = "TimerEvent", Time = 15}
      end
    end
    self.eInterTimerEvent = Util.CreateEvent(tTimerEvent, "P1FP_Entourage.UpdateVariables", self)
    self:RegisterEvent(self.eInterTimerEvent)
  elseif self.CompareLocs(nLoc, tSwitchConfig) == true then
    self.JoinFormation(self, true)
    self.UpdateVariables(self)
  else
    self.UpdateVariables(self)
  end
  if self.tLeaderFace[nLoc] ~= "" then
    local nAngle = Object.GetAngle(Handle(self.tLeaderFace[nLoc]))
    Actor.SetFacingDir(self.hLeader, nAngle)
  end
end

function P1FP_Entourage.CompareLocs(a_nLoc, a_tCompareTable)
  for i, nLoc in ipairs(a_tCompareTable) do
    if a_nLoc == nLoc then
      return true
    end
  end
  return false
end

function P1FP_Entourage:UpdateVariables()
  self.eInterTimerEvent = nil
  self.bUpdateVariablesNeeded = false
  self.nLastLoc = self.nCurrentLoc
  self.nCurrentLoc = self.nCurrentLoc + 1
  if self.nCurrentLoc == 16 then
    self.nCurrentLoc = 1
    self.nEntIndex = 1
  end
  self.CheckRegroup(self, self.nLastLoc)
end

function P1FP_Entourage:CheckRegroup(a_nLoc)
  local tRegroup = {
    1,
    2,
    5,
    6,
    10,
    11,
    12,
    13,
    15
  }
  if self.CompareLocs(a_nLoc, tRegroup) == true then
    if a_nLoc == tRegroup[#tRegroup] then
      self.JoinFormation(self, true)
    else
      self.JoinFormation(self)
    end
  end
  self.MoveEntourage(self)
end

function P1FP_Entourage:UpdateFacingDir(a_nIndex, a_nAltIndex)
  local nAngle = Object.GetAngle(Handle(self.tEntStops[a_nAltIndex][a_nIndex - 1]))
  Actor.SetFacingDir(self.tEntourage[a_nIndex], nAngle)
end

function P1FP_Entourage:CheckEscalation()
  local nCurrentEscalation = Suspicion.GetEscalation()
  if 0 < nCurrentEscalation then
    self:ResetTaskByName("P1FP_Entourage.TASK_LoseTheHeat", true)
    self.TASK_LoseTheHeat(self)
  else
    if self.eSeanDeath then
      Util.KillEvent(self.eSeanDeath)
    end
    Sound.ResetMusicLocale()
    self:CompleteThisMission()
  end
end

function P1FP_Entourage:EntSayRandomDialog()
  Cin.PlayConversation("P1FP_Entourage_HeavyBanter")
end

function P1FP_Entourage:StranskyRandomDialog()
  local nIndex = math.random(1, 2)
  if nIndex == 1 then
    self.tStranskyBanterChoices = self.tStranskyBanterChoices or {
      1,
      2,
      3
    }
    if 1 > #self.tStranskyBanterChoices then
      self.tStranskyBanterChoices = {
        1,
        2,
        3
      }
    end
    local nRand = math.random(#self.tStranskyBanterChoices)
    nIndex = self.tStranskyBanterChoices[nRand]
    table.remove(self.tStranskyBanterChoices, nRand)
    Cin.PlayConversation("P1FP_Entourage_StranskyBanter0" .. nIndex)
  else
    Cin.PlayConversation("P1FP_Entourage_StranskySmackTalk")
  end
end

function P1FP_Entourage:SoldierExitedIdle(a_tCallbackData)
  local hEnt = a_tCallbackData[1]
  local tPissLocs = {
    3,
    4,
    7,
    9
  }
  if hEnt ~= self.hLeader then
    local tIdleEnterEvent = {
      EventType = "OnIdleScriptedEnter",
      Target = hEnt
    }
    self:RegisterEvent(Util.CreateEvent(tIdleEnterEvent, "P1FP_Entourage.SoldierEnteredIdle", self))
  end
  if hEnt == self.hLeader then
    Util.KillEvent(self.eExitIdleEvent)
    self.eExitIdleEvent = nil
    Nav.CancelScriptedPath(hEnt)
    Actor.OverrideCombatAI(hEnt, true)
    Actor.PlayAnimation(self.hLeader, "civ_cower_idle")
    local tEscGreenEvent = {
      EventType = "OnEscalation0",
      Target = self.hSab
    }
    self:RegisterEvent(Util.CreateEvent(tEscGreenEvent, "P1FP_Entourage.ReturnLeaderToNormal", self))
    if Object.IsAlive(self.hLeader) and not self.bGuardsHelping and self.CompareLocs(self.nCurrentLoc, tPissLocs) == true then
      self.bGuardsHelping = true
      Cin.PlayConversationWith("cht_com_Miss", {
        self.hLeader
      }, "P1FP_Entourage.SendGuardsToHelp", self)
    end
  else
    Nav.ExitFormation(hEnt)
  end
  if self.eStranskyTalkEvent then
    Util.KillEvent(self.eStranskyTalkEvent)
    self.eStranskyTalkEvent = nil
    self.nRollCompare = self.nLastCompare
    self.nLastCompare = nil
  end
  if self.eEntTalkEvent then
    Util.KillEvent(self.eEntTalkEvent)
    self.eEntTalkEvent = nil
  end
  if self.eInterTimerEvent and hEnt == self.hLeader then
    Util.KillEvent(self.eInterTimerEvent)
    self.eInterTimerEvent = nil
    self.bUpdateVariablesNeeded = true
  end
end

function P1FP_Entourage:SoldierEnteredIdle(a_tCallbackData)
  local hEnt = a_tCallbackData[1]
  local tIdleExitEvent = {
    EventType = "OnIdleScriptedExit",
    Target = hEnt
  }
  if hEnt == self.hLeader then
    self.eExitIdleEvent = Util.CreateEvent(tIdleExitEvent, "P1FP_Entourage.SoldierExitedIdle", self)
    self:RegisterEvent(self.eExitIdleEvent)
  else
    self:RegisterEvent(Util.CreateEvent(tIdleExitEvent, "P1FP_Entourage.SoldierExitedIdle", self))
  end
  if hEnt == self.hLeader then
    Nav.SetScriptedPathMoveMode(hEnt, false)
    local tAliveList = {}
    for i, hSoldier in ipairs(self.tEntourage) do
      if Object.IsAlive(hSoldier) and hSoldier ~= self.hLeader then
        table.insert(tAliveList, hSoldier)
      end
    end
    local bCanContinue = true
    for i, hSoldier in ipairs(tAliveList) do
      if Actor.IsInCombat(hSoldier) then
        bCanContinue = false
        break
      end
    end
    if not bCanContinue then
      local tTimerEvent = {EventType = "TimerEvent", Time = 0.25}
      self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Entourage.SoldierEnteredIdle", self, {a_tCallbackData}))
    else
      Nav.StopMoving(self.hLeader)
      local tTimerEvent = {EventType = "TimerEvent", Time = 1.5}
      if self.bUpdateVariablesNeeded == true then
        self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Entourage.UpdateVariables", self))
      else
        self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Entourage.MoveEntourage", self))
      end
      self.bGuardsHelping = false
      self.JoinFormation(self)
    end
  end
end

function P1FP_Entourage:SendGuardsToHelp()
  for i, hSoldier in ipairs(self.tEntourage) do
    if Object.IsAlive(hSoldier) and hSoldier ~= self.hLeader then
      Nav.MoveToObject(hSoldier, self.hLeader, 3, true)
    end
  end
end

function P1FP_Entourage:ReturnLeaderToNormal()
  Actor.CancelAnimation(self.hLeader)
  Actor.OverrideCombatAI(self.hLeader, false)
  self.SoldierEnteredIdle(self, {
    self.hLeader
  })
end

function P1FP_Entourage:LeaderDead(a_tCallbackData)
  local hVictim = a_tCallbackData[1]
  local hAttacker = a_tCallbackData[2]
  local bStealthKill = a_tCallbackData[3]
  local nDamageFlag = a_tCallbackData[4]
  if self.bDeliveredMessage then
    self.CompleteDeliverTask(self)
    self.CompleteKillTask(self)
  else
    Cin.PlayConversation("P1FP_Entourage_Distant_Kill", "P1FP_Entourage.DoFailEvent", self)
  end
end

function P1FP_Entourage:UpdateMsgVar()
  self.bDeliveredMessage = true
end

function P1FP_Entourage:CompleteDeliverTask()
  self:CompleteTaskByName("P1FP_Entourage_TASK_DeliverMessage")
end

function P1FP_Entourage:CompleteKillTask()
  self:CompleteTaskByName("P1FP_Entourage_TASK_KillOfficer")
end

function P1FP_Entourage:DoFailEvent()
  self.MissionCleanup(self)
  if self.eSeanDeath then
    Util.KillEvent(self.eSeanDeath)
  end
  self:MissionTaskFail("P1FP_Entourage_Text.MissionFail")
end

function P1FP_Entourage:SetupDeliverMsgProx()
  if not self.hLeader then
    local tTimerEvent = {EventType = "TimerEvent", Time = 0.25}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Entourage.SetupDeliverMsgProx", self))
    return
  end
  local tProxEvent = {
    EventType = "ProximityEvent",
    ObjectA = self.hSab,
    ObjectB = self.hLeader,
    Proximity = 3,
    Check3D = true,
    Negate = false
  }
  self:RegisterEvent(Util.CreateEvent(tProxEvent, "P1FP_Entourage.PlayDialogueAndContinue", self))
end

function P1FP_Entourage:PlayDialogueAndContinue()
  if not Actor.IsInVehicle(self.hSab) then
    Cin.PlayConversation("P1FP_Entourage_StranskyDeath")
    for i, sFollower in ipairs(self.tFollowers) do
      local hEnt = Handle(sFollower)
      if hEnt and Object.IsAlive(hEnt) and Actor.GetActorDist(hEnt, self.hSab) <= 5 then
        Suspicion.SetEscalated()
        break
      end
    end
    self:CompleteTaskByName("P1FP_Entourage_TASK_DeliverMessage")
  else
    local tTimerEvent = {EventType = "TimerEvent", Time = 1}
    self:RegisterEvent(Util.CreateEvent(tTimerEvent, "P1FP_Entourage.SetupDeliverMsgProx", self))
  end
end

function P1FP_Entourage:MissionCleanup()
  self.bStreamEventDone = false
  self.bDeliveredMessage = false
end

function P1FP_Entourage:MISSION_ONCANCEL()
  if self.eSeanDeath then
    Util.KillEvent(self.eSeanDeath)
    self.eSeanDeath = nil
  end
  self.bStreamEventDone = false
  self.bDeliveredMessage = false
  Sound.ResetMusicLocale()
end

function P1FP_Entourage.StarterConvoIntro()
  local hCrochet = Handle("Missions\\paris_1\\characters\\lavillette\\couteau_interior\\Couteau_LaVillette_Interior")
  local hCrochetAttrPt = Handle("Missions\\paris_1\\characters\\lavillette\\couteau_interior\\AIAttractionPt_LookatMap")
  AttractionPt.FinishNow(hCrochetAttrPt, hCrochet)
end

function P1FP_Entourage.StarterConvoOutro()
  local hCrochet = Handle("Missions\\paris_1\\characters\\lavillette\\couteau_interior\\Couteau_LaVillette_Interior")
  local hCrochetAttrPt = Handle("Missions\\paris_1\\characters\\lavillette\\couteau_interior\\AIAttractionPt_LookatMap")
  Actor.UseAttrPt(hCrochet, hCrochetAttrPt)
end
