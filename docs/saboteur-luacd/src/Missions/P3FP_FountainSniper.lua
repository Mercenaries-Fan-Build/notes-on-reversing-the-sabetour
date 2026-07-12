if P3FP_FountainSniper == nil then
  P3FP_FountainSniper = SabTaskObjective:Create()
  P3FP_FountainSniper.PATH = "Missions\\freeplay\\p3\\mis_sulpice\\"
  P3FP_FountainSniper:Configure({
    TaskCount = 999,
    sStarter = "Kwong_Ctown",
    sConvFile = "P3FP_FountainSniper_Start",
    bFreeplay = true,
    sSaveMissionNameID = "MissionNames_Text.P3FP_FountainSniper",
    sActNameID = "MissionNames_Text.ACT_DrKwong",
    tUnlockList = {
      "P3FP_BiggerGun"
    },
    tSMEDNodes = {
      P3FP_FountainSniper.PATH .. "main"
    }
  })
end

function P3FP_FountainSniper:STARTER_Setup()
end

function P3FP_FountainSniper:Activated()
  SabTaskObjective.Activated(self)
  self.sDebugLabel = "FOUNTAIN_SNIPER"
  self.bDebugMode = false
  dprint(self, "Running Fountain Sniper.")
  Suspicion.SetEscalationCap(2)
  self.GENERAL_Setup(self)
  self:RegisterCheckpoint("P3FP_FountainSniper.Checkpoint1")
end

function P3FP_FountainSniper.SetupGamepadListener()
  local self = P3FP_FountainSniper
  self.tControllerEvent = {
    EventType = "OnButtonPress",
    Target = Handle("Saboteur")
  }
  local eButtonEvent = Util.CreateEvent(self.tControllerEvent, "P3FP_FountainSniper.OnButtonPress", self, {}, true)
  self:RegisterEvent(eButtonEvent)
end

function P3FP_FountainSniper:OnButtonPress(a_tButtonData)
  local self = P3FP_FountainSniper
  local tButtons = a_tButtonData[1]
  if tButtons.UP == true then
  elseif tButtons.DOWN == true then
  elseif tButtons.X == true then
  elseif tButtons.B == true then
  end
end

function P3FP_FountainSniper:ArmSelf()
  Inventory.GiveItem(hSab, "WP_PS_WaltherPPK_Silencer", false)
end

function P3FP_FountainSniper:GENERAL_Setup()
  dprint(self, "General_Setup()")
  self.sKwonSpawnLoc = "Missions\\freeplay\\p3\\mis_sulpice\\main\\KwonSpawn(2)"
  self.sKwonLimoPath = "Missions\\freeplay\\p3\\mis_sulpice\\main\\KwonLimoPath"
  self.sLimoReturnsPath = "Missions\\freeplay\\p3\\mis_sulpice\\main\\PATH_LimoReturns"
  self.sLimoEscapesPath = "Missions\\freeplay\\p3\\mis_sulpice\\main\\PATH_LimoEscapes"
  self.sLimoLeavePath = "Missions\\freeplay\\p3\\mis_sulpice\\main\\LimoLeavePath"
  self.sKwonWalkPath = "Missions\\freeplay\\p3\\mis_sulpice\\main\\KwonWalktoMeeting"
  self.sRadioAttrPt = "Missions\\freeplay\\p3\\mis_sulpice\\main\\Generic_Use"
  self.sStreamPoint = "Missions\\freeplay\\p3\\mis_sulpice\\main\\ObjectStreamPoint"
  self.sInformantPath = "Missions\\freeplay\\p3\\mis_sulpice\\main\\InformantPath"
  self.sInformantVar1 = "Missions\\freeplay\\p3\\mis_sulpice\\crowd\\Informant"
  self.sKillerSpawnLoc1 = "Missions\\freeplay\\p3\\mis_sulpice\\main\\KillerSpawn1"
  self.sKillerSpawnLoc2 = "Missions\\freeplay\\p3\\mis_sulpice\\main\\KillerSpawn2"
  self.sKillerSpawnLoc3 = "Missions\\freeplay\\p3\\mis_sulpice\\main\\KillerSpawn3"
  self.sKillerSpawnLoc4 = "Missions\\freeplay\\p3\\mis_sulpice\\main\\KillerSpawn4"
  self.sKillerSpawnLocG1 = "Missions\\freeplay\\p3\\mis_sulpice\\main\\KillerSpawnG1"
  self.sKillerSpawnLocG2 = "Missions\\freeplay\\p3\\mis_sulpice\\main\\KillerSpawnG2"
  self.sKillerSpawnLocG3 = "Missions\\freeplay\\p3\\mis_sulpice\\main\\KillerSpawnG3"
  self.sAssassinPath = "Missions\\freeplay\\p3\\mis_sulpice\\main\\AssassinPath"
  Util.EnableSuperSpores(true)
  math.randomseed(Util.GetGameTime())
  self:AddOnCancelCallback(P3FP_FountainSniper.Reset)
  self:AddOnCompleteCallback(P3FP_FountainSniper.Reset)
end

function P3FP_FountainSniper:Sound1()
  Sound.SetMusicLocale("fp_P3FP_FountainSniper")
  Sound.SetMusicLocale("fp_P3FP_FountainSniper", "arrives")
end

function P3FP_FountainSniper:Sound2()
  Sound.SetMusicLocale("fp_P3FP_FountainSniper")
  Sound.SetMusicLocale("fp_P3FP_FountainSniper", "allClear")
end

function P3FP_FountainSniper:Sound3()
  Sound.SetMusicLocale("fp_P3FP_FountainSniper")
  Sound.SetMusicLocale("fp_P3FP_FountainSniper", "twoSnipers")
end

function P3FP_FountainSniper:Sound4()
  Sound.SetMusicLocale("fp_P3FP_FountainSniper")
  Sound.SetMusicLocale("fp_P3FP_FountainSniper", "threeSnipers")
end

function P3FP_FountainSniper:Checkpoint1()
  self:TASK_GoToSulpice()
  local nGarbage = math.random(1, 5)
  dprint(self, nGarbage)
end

function P3FP_FountainSniper:TASK_GoToSulpice()
  self:CreateTask({
    sName = "P3FP_FountainSniper.TASK_GoToSulpice",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P3FP_FountainSniper_Text.TASK_GoToSulpice",
    tDeliverObjs = {
      Handle("Saboteur")
    },
    tDestRegion = {
      self.PATH .. "main\\PT_GoHere"
    },
    tLocators = {
      self.PATH .. "main\\LOC_GoHere"
    },
    tOnActivate = {},
    tOnComplete = {
      {
        HUD.ClearGPSTarget,
        {}
      },
      {
        self.TASK_GetToTheNest,
        {self}
      }
    }
  })
end

function P3FP_FountainSniper:TASK_GetToTheNest()
  self:CreateTask({
    sName = "P3FP_FountainSniper.TASK_GetToTheNest",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    sObjectiveTextID = "P3FP_FountainSniper_Text.TASK_GetToTheNest",
    tDeliverObjs = {
      Handle("Saboteur")
    },
    tDestRegion = {
      self.PATH .. "main\\PT_Balcony"
    },
    tLocators = {
      self.PATH .. "main\\LOC_BalconyObjective"
    },
    bNoGPS = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.RegisterCheckpoint,
        {
          self,
          "P3FP_FountainSniper.Checkpoint2"
        }
      }
    }
  })
end

function P3FP_FountainSniper:Checkpoint2()
  dprint(self, "Registered: CHECKPOINT 2")
  self:SetupInformantStream()
  WorldSMEDNodes.LoadNode("Missions\\freeplay\\p3\\mis_sulpice\\crowd")
  self.bIs2ndTimeRound = false
  self.nInEscapeLimo = 0
  self.nGKillerNum = 0
  self.tGKillers = {}
  self.bKwonFled = false
  self.nSniperShots = 0
  self.TASK_UsetheRadio(self)
  self.bKwonAtHideSp = false
end

function P3FP_FountainSniper:KillEscEvent()
  Util.KillEvent(self.eEscDetect)
  self:TASK_UsetheRadio()
end

function P3FP_FountainSniper:KillEscEvent2()
  Util.KillEvent(self.eEscDetect)
end

function P3FP_FountainSniper:EscalationListener()
  dprint(self, "Setting Escalation Listener  - clear Esc to get Fade Up/Down")
  self.eEscDetect = EVENT_OnEscalation("P3FP_FountainSniper.TurnOffRadio", self, nil, false)
end

function P3FP_FountainSniper:TurnOffRadio()
  dprint(self, "Escalated. Switching to LOSE HEAT task")
  if self:IsMissionTaskActive("P3FP_FountainSniper.TASK_UsetheRadio") then
    self:ResetTaskByName("P3FP_FountainSniper.TASK_UsetheRadio", true)
    self:RadioOff()
    self:TASK_LoseEscalation()
  else
    Util.KillEvent(self.eEscDetect)
  end
end

function P3FP_FountainSniper:RadioOff()
  AttractionPt.EnableUse(self.hRadiotAttrPt, false)
end

function P3FP_FountainSniper:RadioOn()
  local hRadioAttrPt = Util.GetHandleByName(self.sRadioAttrPt)
  self.hRadiotAttrPt = hRadioAttrPt
  AttractionPt.EnableUse(self.hRadiotAttrPt, true)
end

function P3FP_FountainSniper:CinEscDetector()
  dprint(self, ">>> CINEMATIC Escalation Listener  - fail if Esc occurs during cinematic")
  self.eCinEscDetect = EVENT_OnEscalation("P3FP_FountainSniper.EscFailDelay", self, nil, false)
end

function P3FP_FountainSniper:EscFailDelay()
  EVENT_Timer("P3FP_FountainSniper.EscFail", self, 2)
end

function P3FP_FountainSniper:TASK_LoseEscalation()
  self:CreateTask({
    sName = "P3FP_FountainSniper.TASK_LoseEscalation",
    sTaskType = "SabTaskObjectiveEscalation",
    sTaskSubType = "None",
    sObjectiveTextID = "GenericObjective_Text.Escalation_Lose",
    EscalationLevel = 0,
    bRepeatable = true,
    bNoRepeatAutoRebuild = true,
    tOnComplete = {
      {
        self.KillEscEvent,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function P3FP_FountainSniper:TASK_KillGenerals()
  self:CompleteTaskByName("P3FP_FountainSniper.TASK_WaitforKwon")
  self:KillEscDetector()
  self:CreateTask({
    sName = "P3FP_FountainSniper.TASK_KillGenerals",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P3FP_FountainSniper_Text.TASK_KillGenerals",
    tTgtInclude = {
      self.hKiller
    },
    tOnActivate = {
      {
        EVENT_Timer,
        {
          "P3FP_FountainSniper.TimerToKiller2",
          self,
          20
        }
      },
      {
        Cin.PlayConversation,
        {
          "P3FP_FountainSniper_Found1"
        }
      },
      {
        self.KillEscEvent2,
        {self}
      },
      {
        self.Sound3,
        {self}
      },
      {
        EVENT_ActorDeath,
        {
          "P3FP_FountainSniper.KilledSniper1",
          self,
          self.hKiller,
          nil
        }
      }
    },
    tOnComplete = {
      {
        self.Set2ndRound,
        {self}
      }
    }
  })
end

function P3FP_FountainSniper:KilledSniper1()
  Cin.PlayConversation("P3FP_FountainSniper_Kill1")
  HUD.RemoveObjectiveMarker(self.hKiller)
end

function P3FP_FountainSniper:TimerToKiller2()
  dprint(self, "You've got 10 seconds to kill Sniper1 before Sniper2 arrives")
  if self:IsMissionTaskActive("P3FP_FountainSniper.TASK_KillGenerals") then
    HUD.SetObjectiveMarker(self.hKiller, eOT_KILL, cOM_Kill, true, true, true)
    self:CompleteTaskByName("P3FP_FountainSniper.TASK_KillGenerals")
  end
end

function P3FP_FountainSniper:EscKwonWait()
  Util.KillEvent(self.eCinEscDetect)
  EVENT_Timer("P3FP_FountainSniper.EscKwonFlees", self, 0.5)
end

function P3FP_FountainSniper:EscKwonFlees()
  dprint(self, "Setting Escalation Listener - this time Kwong will flee, mission fail")
  if Suspicion.GetEscalation() > 0 then
    self.KwonFleeFail(self)
  else
    self.eEscKwonRun = EVENT_OnEscalation("P3FP_FountainSniper.KwonFleeFail", self, nil, false)
  end
end

function P3FP_FountainSniper:KillEscDetector()
  Util.KillEvent(self.eEscKwonRun)
end

function P3FP_FountainSniper:KwonFleeFail()
  self:KwonContactPanic()
  EVENT_Timer("P3FP_FountainSniper.EscFail", self, 4)
end

function P3FP_FountainSniper:KwonContactPanic()
  if self.bKwonAtHideSp == false then
    Actor.OverrideCombatAI(self.hInformant, false)
    Combat.SetIdleScripted(self.hInformant, false)
    Actor.CancelAttrPt(self.hInformant)
    Actor.CancelAnimation(self.hInformant)
    Actor.SetPanicEnabled(self.hInformant, true)
    Actor.EnableNeeds(self.hInformant, true)
    Nav.MoveToObject(self.hInformant, Handle("Missions\\freeplay\\p3\\mis_sulpice\\main\\LOC_KwonHides"), 5, cMOVE_PANIC)
    Actor.CancelAttrPt(self.hKwon)
    Actor.SetPanicEnabled(self.hKwon, true)
    Nav.MoveToObject(self.hKwon, Handle("Missions\\freeplay\\p3\\mis_sulpice\\main\\LOC_KwonHides"), 5, cMOVE_PANIC)
  end
end

function P3FP_FountainSniper:Set2ndRound()
  self.bIs2ndTimeRound = true
  self.SpawnAssassin(self)
end

function P3FP_FountainSniper:BlipKwon()
  HUD.SetObjectiveMarker(self.hKwon, cMMI_MissionGiver, cOM_MissionGiver, true, true, true)
end

function P3FP_FountainSniper:CallLimoBack()
  Nav.SetScriptedPath(self.hLimo, self.sLimoReturnsPath, false, "P3FP_FountainSniper.KwonEscapes", self)
  Nav.SetScriptedPathSpeed(self.hLimo, 60)
end

function P3FP_FountainSniper:KwonEscapes()
  Actor.CancelAnimation(self.hKwon)
  Actor.OverrideCombatAI(self.hKwon, true)
  Nav.BoardVehicle(self.hKwon, self.hLimo, "BACKSEAT_R", cMOVE_PANIC, "P3FP_FountainSniper.LimoEscapes", self)
end

function P3FP_FountainSniper:LimoEscapes()
  Nav.SetScriptedPath(self.hLimo, self.sLimoEscapesPath, false)
  Nav.SetScriptedPathSpeed(self.hLimo, 90)
  EVENT_Timer("P3FP_FountainSniper.KwonHasEscaped", self, 4)
end

function P3FP_FountainSniper:KwonHasEscaped()
  Cin.PlayConversation("P3FP_FountainSniper_Complete")
  self:CompleteThisMission()
end

function P3FP_FountainSniper:SpawnGroundKillers()
  EVENT_Timer("P3FP_FountainSniper.GroundKillerVO", self, 8)
  dprint(self, "--=== GROUND Assassins GO!!!!")
  local hKillSpawnLoc = Util.GetHandleByName(self.sKillerSpawnLocG1)
  local x, y, z = Object.GetPosition(hKillSpawnLoc)
  Object.Spawn("Human_NZ_Sniper_PS_FP_Fountain", x, y, z, 0, nil, "P3FP_FountainSniper.GoGroundKillers", self)
  local hKillSpawnLoc = Util.GetHandleByName(self.sKillerSpawnLocG2)
  local x, y, z = Object.GetPosition(hKillSpawnLoc)
  Object.Spawn("Human_NZ_Sniper_PS_FP_Fountain", x, y, z, 0, nil, "P3FP_FountainSniper.GoGroundKillers", self)
  local hKillSpawnLoc = Util.GetHandleByName(self.sKillerSpawnLocG3)
  local x, y, z = Object.GetPosition(hKillSpawnLoc)
  Object.Spawn("Human_NZ_Sniper_PS_FP_Fountain", x, y, z, 0, nil, "P3FP_FountainSniper.GoGroundKillers", self)
end

function P3FP_FountainSniper:GroundKillerVO()
  Cin.PlayConversation("P3FP_FountainSniper_ThreeMore")
end

function P3FP_FountainSniper:GoGroundKillers(a_hWho)
  self.nGKillerNum = self.nGKillerNum + 1
  self.tGKillers[self.nGKillerNum] = a_hWho[1]
  local hKiller = self.tGKillers[self.nGKillerNum]
  Actor.OverrideCombatAI(hKiller, true)
  Combat.SetIdleScripted(hKiller, true)
  Nav.MoveToObject(self.tGKillers[self.nGKillerNum], self.hKwon, 8, cMOVE_FAST, "P3FP_FountainSniper.GroundKillerAttack", self, {
    self.tGKillers[self.nGKillerNum]
  })
  if self.nGKillerNum == 3 then
    self:TASK_KwonEscape()
  end
  if self.bKwonFled == false then
    self:KwonFlees()
  end
end

function P3FP_FountainSniper:GroundKillerAttack(a_hKiller)
  Actor.OverrideCombatAI(a_hKiller, false)
  Combat.SetReactImmediately(a_hKiller, true)
  Combat.LockIntoRanged(a_hKiller)
  Combat.AddTargetFlag(a_hKiller, cTARGET_ENEMYLIST, {
    {
      self.hKwon,
      1
    },
    {hSab, 10000}
  })
  Combat.SetTarget(a_hKiller, self.hKwon)
  Combat.SetCombat(a_hKiller)
end

function P3FP_FountainSniper:KwonFlees()
  self.bKwonFled = true
  Actor.CancelAttrPtRequest(self.hKwon)
  Actor.CancelAttrPtRequest(self.hInformant)
  Actor.CancelAnimation(self.hKwon)
  Actor.CancelAnimation(self.hInformant)
  Nav.MoveToObject(self.hKwon, Handle("Missions\\freeplay\\p3\\mis_sulpice\\main\\LOC_KwonHides"), 1, cMOVE_PANIC, "P3FP_FountainSniper.KwonHides", self, {})
  Nav.SetScriptedPath(self.hInformant, self.sInformantPath, false)
  Nav.SetScriptedPathMoveMode(self.hInformant, cMOVE_PANIC)
end

function P3FP_FountainSniper:KwonHides()
  self.bKwonAtHideSp = true
  Actor.PlayAnimation(self.hKwon, "civ_cower_idle")
end

function P3FP_FountainSniper:TASK_KillGeneralTwo()
  self:CreateTask({
    sName = "P3FP_FountainSniper.TASK_KillGeneralTwo",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P3FP_FountainSniper_Text.TASK_KillGeneralTwo",
    tTgtInclude = {
      self.hKiller
    },
    tOnActivate = {
      {
        Cin.PlayConversation,
        {
          "P3FP_FountainSniper_Found2"
        }
      },
      {
        EVENT_Timer,
        {
          "P3FP_FountainSniper.TimerToGroundAtk",
          self,
          20
        }
      },
      {
        EVENT_ActorDeath,
        {
          "P3FP_FountainSniper.KilledSniper2",
          self,
          self.hKiller,
          nil
        }
      }
    },
    tOnComplete = {
      {
        self.CallLimoBack,
        {self}
      },
      {
        self.SpawnGroundKillers,
        {self}
      }
    }
  })
end

function P3FP_FountainSniper:KilledSniper2()
  Cin.PlayConversation("P3FP_FountainSniper_Kill2")
  HUD.RemoveObjectiveMarker(self.hKiller)
end

function P3FP_FountainSniper:TimerToGroundAtk()
  dprint(self, "You've got 10 seconds to kill Sniper2 before Ground Attackers arrive")
  if self:IsMissionTaskActive("P3FP_FountainSniper.TASK_KillGeneralTwo") then
    HUD.SetObjectiveMarker(self.hKiller, eOT_KILL, cOM_Kill, true, true, true)
    self:CompleteTaskByName("P3FP_FountainSniper.TASK_KillGeneralTwo")
  end
end

function P3FP_FountainSniper:TASK_UsetheRadio()
  local hRadioAttrPt = Util.GetHandleByName(self.sRadioAttrPt)
  self.hRadiotAttrPt = hRadioAttrPt
  AttractionPt.EnableUse(self.hRadiotAttrPt, true)
  self:CreateTask({
    sName = "P3FP_FountainSniper.TASK_UsetheRadio",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "USE",
    sObjectiveTextID = "P3FP_FountainSniper_Text.TASK_GiveConfirmation",
    tTgtInclude = {hRadioAttrPt},
    tSMEDNodes = {},
    tOnActivate = {
      {
        self.EscalationListener,
        {self}
      }
    },
    tOnComplete = {
      {
        self.SpawnKwon,
        {self}
      },
      {
        self.CinEscDetector,
        {self}
      },
      {
        self.RadioOff,
        {self}
      },
      {
        self.Sound2,
        {self}
      },
      {
        self.LeaveMissionFail,
        {self}
      }
    }
  })
end

function P3FP_FountainSniper:LeaveMissionFail()
  EVENT_PlayerExitsTrigger("P3FP_FountainSniper.FailLeftMission", self, "Missions\\freeplay\\p3\\mis_sulpice\\main\\PT_LeaveMissionFail", false)
end

function P3FP_FountainSniper:TASK_WaitforKwon()
  self:CreateTask({
    sName = "P3FP_FountainSniper.TASK_WaitforKwon",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    sObjectiveTextID = "P3FP_FountainSniper_Text.TASK_WaitforKwon",
    tOnActivate = {
      {
        self.BlipKwon,
        {self}
      },
      {
        self.EscKwonWait,
        {self}
      },
      {
        self.SetupHealthBar,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function P3FP_FountainSniper:TASK_KwonEscape()
  self:CreateTask({
    sName = "P3FP_FountainSniper.TASK_KwonEscape",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "KILL",
    sObjectiveTextID = "P3FP_FountainSniper_Text.TASK_KwonEscape",
    tTgtInclude = self.tGKillers,
    tOnActivate = {
      {
        self.Sound4,
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

function P3FP_FountainSniper:SpawnKwon()
  Util.SetDynamicPriority("VH_NZ_CR_6WheelNaziLimo_htop_01", 15001)
  Util.SetDynamicPriority("Human_RS_DrWong", 500)
  WorldSMEDNodes.LoadNode("Missions\\freeplay\\p3\\mis_sulpice\\kwong", "P3FP_FountainSniper.GoKwon", self)
end

function P3FP_FountainSniper:GoKwon()
  self.hKwon = Handle("Missions\\freeplay\\p3\\mis_sulpice\\kwong\\Spore_RS_DrWong")
  self.hLimo = Handle("Missions\\freeplay\\p3\\mis_sulpice\\kwong\\VH_NZ_CR_6WheelNaziLimo_htop_01")
  dprint(self, "KWON HEALTH: " .. Object.GetHealth(self.hKwon))
  EVENT_Timer("P3FP_FountainSniper.PrintKwonHealth", self, 4)
  Nav.BoardVehicle(self.hKwon, self.hLimo, "BACKSEAT_R", bUrgent, "P3FP_FountainSniper.OnKwonSpawns", self)
  Vehicle.LockAllSeats(self.hLimo, true)
  if Suspicion.GetEscalation() > 0 then
    self:EscFail()
  else
    self:ArrivalCin()
  end
end

function P3FP_FountainSniper:OnKwonSpawns()
  Nav.SetScriptedPath(self.hLimo, self.sKwonLimoPath, false, "P3FP_FountainSniper.KwonHitsLanding", self)
  Nav.SetScriptedPathSpeed(self.hLimo, 35)
  self:SetEventsOnKwon()
end

function P3FP_FountainSniper:ArrivalCin()
  Cin.SetCinematicStreaming(true)
  self:CreateTask({
    sName = "P3FP_FountainSniper.ArrivalCin",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "cinematic",
    sCinFile = "CIN_FountainSniper_Arrival",
    tSMEDNodes = {},
    tStaticTags = {},
    tOnActivate = {},
    tOnComplete = {
      {
        self.TASK_WaitforKwon,
        {self}
      }
    }
  })
end

function P3FP_FountainSniper:KwonHitsLanding()
  Actor.OverrideCombatAI(self.hKwon, true)
  Combat.SetIdleScripted(self.hKwon, true)
  Actor.EnableNeeds(self.hKwon, false)
  Actor.UnboardVehicle(self.hKwon)
  EVENT_Timer("P3FP_FountainSniper.KwonToMeetingSpot", self, 3)
end

function P3FP_FountainSniper:KwonToMeetingSpot()
  Nav.SetScriptedPath(self.hLimo, self.sLimoLeavePath, false, "P3FP_FountainSniper.DespawnLimo", self)
  Nav.SetScriptedPath(self.hKwon, self.sKwonWalkPath, false, "P3FP_FountainSniper.KwonHitsMeetingSpot", self)
end

function P3FP_FountainSniper:KwonHitsMeetingSpot()
  local hSitPt = Handle("Missions\\freeplay\\p3\\mis_sulpice\\main\\AttractionPT_SitKwon")
  Actor.RequestAttrPt(self.hKwon, hSitPt)
  dprint(self, "Kwon is at meeting spot")
  EVENT_Timer("P3FP_FountainSniper.KwonReady", self, 5)
end

function P3FP_FountainSniper:KwonReady()
  self:SpawnAssassin()
  self:KwonTalksTo()
end

function P3FP_FountainSniper:StartInformant()
  dprint(self, "informant has streamed in")
  local hInformant = Util.GetHandleByName(self.sInformantVar1)
  self.hInformant = hInformant
  Actor.EnableNeeds(hInformant, false)
  Actor.OverrideCombatAI(hInformant, true)
  Actor.SetPanicEnabled(self.hInformant, false)
  local hInfSitPt = Handle("Missions\\freeplay\\p3\\mis_sulpice\\main\\AttractionPT_SitOnly")
  Actor.RequestAttrPt(hInformant, hInfSitPt)
  self.eContactKill = EVENT_ActorDamaged("P3FP_FountainSniper.ContactDamaged", self, self.hInformant)
end

function P3FP_FountainSniper:KwonTalksTo()
  Actor.PlayAnimation(self.hKwon, "civ_chat2_LOOP", -1, true)
  Actor.PlayAnimation(self.hInformant, "civ_chat2_LOOP", -1, true)
end

function P3FP_FountainSniper:DespawnLimo()
  dprint(self, "Limo should teleport 180 here")
  Object.Teleport(self.hLimo, -702.1564, 45.73041, 519.08044, 126.040276)
end

function P3FP_FountainSniper:RadioStream()
  local tStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      self.sStreamPoint
    }
  }
  Util.CreateEvent(tStreamEvent, "P3FP_FoundtainSniper.OnRadioPropStreams", self)
end

function P3FP_FountainSniper:OnRadioPropStreams()
  self.hRadioAttrPt = Util.GetHandleByName(self.sRadioAttrPt)
end

function P3FP_FountainSniper:SpawnAssassin()
  self.nRandomSpawnLoc = math.random(1, 4)
  dprint(self, self.nRandomSpawnLoc)
  if self.bIs2ndTimeRound == true then
    self.nRandomSpawnLoc = 4
  elseif self.bIs2ndTimeRound == false then
    self.nRandomSpawnLoc = 3
  end
  if self.nRandomSpawnLoc == 1 then
    local hKillSpawnLoc = Util.GetHandleByName(self.sKillerSpawnLoc1)
    local x, y, z = Object.GetPosition(hKillSpawnLoc)
    Object.Spawn("Human_SS_Sniper_RF_cheat", x, y, z, 0, nil, "P3FP_FountainSniper.OnKillerSpawns", self, nil, false)
  elseif self.nRandomSpawnLoc == 2 then
    local hKillSpawnLoc = Util.GetHandleByName(self.sKillerSpawnLoc2)
    local x, y, z = Object.GetPosition(hKillSpawnLoc)
    Object.Spawn("Human_SS_Sniper_RF_cheat", x, y, z, 0, nil, "P3FP_FountainSniper.OnKillerSpawns", self, nil, false)
  elseif self.nRandomSpawnLoc == 3 then
    local hKillSpawnLoc = Util.GetHandleByName(self.sKillerSpawnLoc3)
    local x, y, z = Object.GetPosition(hKillSpawnLoc)
    Object.Spawn("Human_SS_Sniper_RF_cheat", x, y, z, 0, nil, "P3FP_FountainSniper.OnKillerSpawns", self, nil, false)
  elseif self.nRandomSpawnLoc == 4 then
    local hKillSpawnLoc = Util.GetHandleByName(self.sKillerSpawnLoc4)
    local x, y, z = Object.GetPosition(hKillSpawnLoc)
    Object.Spawn("Human_SS_Sniper_RF_cheat", x, y, z, 0, nil, "P3FP_FountainSniper.OnKillerSpawns", self, nil, false)
  end
  self.nFirstAssasin = self.nRandomSpawnLoc
end

function P3FP_FountainSniper:OnKillerSpawns(a_hWho)
  dprint(self, "Killer Has Spawned")
  local hKiller = a_hWho[1]
  self.hKiller = hKiller
  EVENT_Timer("P3FP_FountainSniper.CheckType", self, 2)
  if self.bIs2ndTimeRound == false then
    self:TASK_KillGenerals()
  elseif self.bIs2ndTimeRound == true then
    self:TASK_KillGeneralTwo()
  end
end

function P3FP_FountainSniper:CheckType()
  self:RunSniperBehavior()
end

function P3FP_FountainSniper:PrintKwonHealth()
  dprint(self, "KWON HEALTH: " .. Object.GetHealth(self.hKwon))
  if Object.IsAlive(self.hKwon) then
    EVENT_Timer("P3FP_FountainSniper.PrintKwonHealth", self, 4)
  end
end

function P3FP_FountainSniper:RunSniperBehavior()
  dprint(self, "Sniper Chosen")
  Combat.SetStationary(self.hKiller, true)
  Combat.LockIntoRanged(self.hKiller)
  Combat.SetTarget(self.hKiller, self.hKwon)
  Combat.AddTargetFlag(self.hKiller, cTARGET_ENEMYLIST, {
    {
      self.hKwon,
      1
    },
    {hSab, 10000}
  })
  Combat.SetReactImmediately(self.hKiller, true)
  Combat.SetAlwaysSeeTarget(self.hKiller, true)
  Combat.SetCombat(self.hKiller)
  EVENT_ActorFiresAnyWeapon("P3FP_FountainSniper.WaitKwonFlees", self, self.hKiller)
end

function P3FP_FountainSniper:WaitKwonFlees()
  EVENT_Timer("P3FP_FountainSniper.KwonFlees", self, 5)
end

function P3FP_FountainSniper:SetupInformantStream()
  EVENT_Stream("P3FP_FountainSniper.StartInformant", self, self.sInformantVar1, true)
end

function P3FP_FountainSniper:BenchStream()
  local tSitPt = Object.GetAttrPtAttachments(Util.GetHandleByName("Missions\\freeplay\\p3\\mis_sulpice\\props\\Global_BenchSingle(8)\\P_Global_A_Bench_Sngl_DAM"))
  local hSitPtL = tSitPt[1]
  local hSitPtR = tSitPt[2]
  AttractionPt.EnableBroadcast(hSitPtL, false)
  AttractionPt.EnableBroadcast(hSitPtR, false)
end

function P3FP_FountainSniper:SetEventsOnKwon()
  local tKwonDeath = {
    EventType = "DeathEvent",
    ObjectHandle = self.hKwon
  }
  Util.CreateEvent(tKwonDeath, "P3FP_FountainSniper.FailKwonDied", self)
  EVENT_ActorDeath("P3FP_FountainSniper.FailKwonCarDied", self, self.hLimo, nil)
  EVENT_ActorDamaged("P3FP_FountainSniper.PlayerHitKwon", self, self.hKwon, {}, true)
end

function P3FP_FountainSniper:ContactDamaged(a_tCallbackData)
  if a_tCallbackData[2] == Handle("Saboteur") then
    Cin.PlayConversation("P3FP_FountainSniper_HitKwon", "P3FP_FountainSniper.FailShotContact", self)
  end
  self:KwonContactPanic()
end

function P3FP_FountainSniper:PlayerHitKwon(a_tCallbackData)
  if a_tCallbackData[2] == Handle("Saboteur") then
    Cin.PlayConversation("P3FP_FountainSniper_HitKwon", "P3FP_FountainSniper_HitKwon.FailShotKwon", self)
  end
  self:KwonContactPanic()
end

function P3FP_FountainSniper:SetupHealthBar()
  self.nCurrentHealth = Object.GetHealth(self.hKwon)
  self.TempObjectiveID = HUD.AddObjective(eOT_HEART, SabTask:GetLocalizedText("GenericObjective_Text.BAR_Health"), 2, nil)
  HUD.SetupProgressBar(self.TempObjectiveID, 0, self.nCurrentHealth, self.nCurrentHealth)
  EVENT_ActorDamaged("P3FP_FountainSniper.UpdateHealthBar", self, self.hKwon, {}, true)
end

function P3FP_FountainSniper:UpdateHealthBar()
  self.nCurrentHealth = Object.GetHealth(self.hKwon)
  HUD.SetProgressBarValue(self.TempObjectiveID, self.nCurrentHealth)
  self.nSelfCounter = EVENT_Timer("P3FP_FountainSniper.UpdateHealthBar", self, 2)
end

function P3FP_FountainSniper:FailKwonDied()
  dprint(self, "KWON HEALTH: " .. Object.GetHealth(self.hKwon))
  Cin.PlayConversation("P3FP_FountainSniper_Fail")
end

function P3FP_FountainSniper:FailKwonCarDied()
  self:MissionTaskFail("Char_Death.RS_DrWongCar")
end

function P3FP_FountainSniper:FailShotKwon()
  self:MissionTaskFail("P3FP_FountainSniper_Text.Fail_ShotKwon")
end

function P3FP_FountainSniper:FailShotContact()
  self:MissionTaskFail("P3FP_FountainSniper_Text.Fail_ShotContact")
end

function P3FP_FountainSniper:EscFail()
  self:MissionTaskFail("P3FP_FountainSniper_Text.Fail_PlayerEsc")
end

function P3FP_FountainSniper:FailLeftMission()
  self:MissionTaskFail("P3FP_FountainSniper_Text.Fail_LeftMission")
end

function P3FP_FountainSniper:Reset()
  Sound.ResetMusicLocale()
  HUD.RemoveObjectiveMarker(self.hKwon)
  Suspicion.SetEscalationCap(-1)
  WorldSMEDNodes.UnloadNode("Missions\\freeplay\\p3\\mis_sulpice\\crowd", true)
  WorldSMEDNodes.UnloadNode("Missions\\freeplay\\p3\\mis_sulpice\\kwong", true)
end
