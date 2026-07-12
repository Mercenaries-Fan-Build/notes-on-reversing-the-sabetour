if Act_1_ConnectToBar == nil then
  Act_1_ConnectToBar = SabTaskObjective:Create()
  gsA1ConBar = "Missions\\act_1\\connecttobar\\"
  Act_1_ConnectToBar:Configure({
    TaskCount = "auto",
    bWorldEvent = true,
    MCDisplayID = 2,
    bFastComplete = true,
    tSMEDNodes = {
      gsA1ConBar .. "main"
    }
  })
end

function Act_1_ConnectToBar:STARTER_Setup()
  Render.SetGlobalWTF(true)
  Sound.LoadSoundBank("m_A3M1_inGame.bnk")
end

function Act_1_ConnectToBar:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
  self.QuickChange(self)
  Util.UnloadStaticENTag("wpop", true)
end

function Act_1_ConnectToBar:GENERAL_Setup()
  self.hGroupieMobile = Util.GetHandleByName("Missions\\act_1\\connecttobar\\main\\VH_Groupiemobile")
  self:AddOnCancelCallback(Act_1_ConnectToBar.Reset)
  self:AddOnCompleteCallback(Act_1_ConnectToBar.Reset)
end

function Act_1_ConnectToBar:Reset()
  Sound.ReleaseSoundBank("m_A3M1_inGame.bnk")
  InteriorManager.FinishedWithExteriorBlip("RedOx")
end

function Act_1_ConnectToBar:Task_GotoBar()
  self:CreateTask({
    sName = "Task_GotoBar",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "goto",
    sObjectiveTextID = "Meet up with Jules",
    sUpdateTextID = "Make your way to the Red Ox Bar and meet up with Jules",
    tDeliverObjs = {hSab},
    tDestRegion = {
      gsA1ConBar .. "main\\REG_RedOxEntry"
    },
    tOnActivate = {
      {
        self.QuickChange,
        {self}
      },
      {
        InteriorManager.RequestExteriorBlip,
        {"RedOx"}
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

function Act_1_ConnectToBar:TASK_GarageCrowd()
  self:CreateTask({
    sName = "TASK_GarageCrowd",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      gsA1ConBar .. "crowd"
    },
    tOnActivate = {
      {
        self.GarageCrowd,
        {self}
      }
    }
  })
end

function Act_1_ConnectToBar:TASK_StadiumCrowd()
  self:CreateTask({
    sName = "TASK_StadiumCrowd",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      gsA1ConBar .. "stadiumcrowd"
    },
    tOnActivate = {
      {
        self.StadiumCrowd,
        {self}
      }
    }
  })
end

function Act_1_ConnectToBar:TASK_BarCrowd()
  self:CreateTask({
    sName = "TASK_BarCrowd",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "None",
    tSMEDNodes = {
      gsA1ConBar .. "barcrowd"
    },
    tOnActivate = {}
  })
end

function Act_1_ConnectToBar:QuickChange()
  if Actor.IsInVehicle(hSab) then
    Actor.UnboardVehicle(hSab)
    EVENT_PlayerExitsAnyVehicle("Act_1_ConnectToBar.QuickChange2", self)
  else
    Object.PlayerTeleportToLocator(Util.GetHandleByName("Missions\\act_1\\connecttobar\\main\\LOC_SeanAfterRace"), "Act_1_ConnectToBar.TASK_GarageCrowd", self)
  end
end

function Act_1_ConnectToBar:QuickChange2()
  Object.PlayerTeleportToLocator(Util.GetHandleByName("Missions\\act_1\\connecttobar\\main\\LOC_SeanAfterRace"), "Act_1_ConnectToBar.TASK_GarageCrowd", self)
end

function Act_1_ConnectToBar:ObjectiveTut()
  self.JulesCatchup(self)
end

function Act_1_ConnectToBar:TutorialDelay()
end

function Act_1_ConnectToBar:GroupieMobile()
  Nav.SetScriptedPath(self.hGroupieMobile, "Missions\\act_1\\connecttobar\\main\\PATH_GroupieMobile", true)
  Nav.SetScriptedPathSpeed(self.hGroupieMobile, 150)
end

function Act_1_ConnectToBar:JulesCatchup()
  Cin.PlayConversation("A1M2_JulesCatchup", "Act_1_ConnectToBar.TutorialDelay", self)
  Nav.FollowObject(self.hJules, hSab, 3, true)
  local tGroupieSequence = {
    {
      "DELAY",
      {2}
    },
    {
      "BOARDVEHICLE",
      {
        self.hGroupieMobile,
        "SHOTGUN"
      }
    }
  }
  ScriptSequence.Run(self.thGroupies[2], tGroupieSequence, self.GroupieMobile, {self})
end

function Act_1_ConnectToBar:JulesBails()
  Cin.PlayConversation("A1M2_JulesBails")
  Nav.MoveToObject(self.hJules, Util.GetHandleByName("Missions\\act_1\\connecttobar\\main\\LOC_Jules2Bar"), 2, true)
end

function Act_1_ConnectToBar:GarageCrowd()
  self.hJules = Util.GetHandleByName("Missions\\act_1\\connecttobar\\main\\Spore_RS_Jules")
  self.thGroupies = {
    Util.GetHandleByName("Missions\\act_1\\connecttobar\\main\\Spore_CG_Groupie"),
    Util.GetHandleByName("Missions\\act_1\\connecttobar\\main\\Spore_CG_Groupie")
  }
  Actor.BoardVehicle(self.thGroupies[1], self.hGroupieMobile, "PILOT")
  self.tCrowdWalkaway = Tips.GetListFromNames("Missions\\act_1\\connecttobar\\crowd\\Spore_CV_WalkAway_")
  self.tCrowdStumbleaway = Tips.GetListFromNames("Missions\\act_1\\connecttobar\\crowd\\Spore_CV_StumbleAway_")
  self.tCrowdWalknow = Tips.GetListFromNames("Missions\\act_1\\connecttobar\\crowd\\Spore_CV_WalkNow_")
  self.tCrowdStumblenow = Tips.GetListFromNames("Missions\\act_1\\connecttobar\\crowd\\Spore_CV_StumbleNow_")
  Sound.ActivateSoundEmitter(Util.GetHandleByName("Missions\\act_1\\connecttobar\\crowd\\Sound_CrowdCheer"))
  for i, v in ipairs(self.tCrowdWalknow) do
    self:CrowdWalkaway(v, "Missions\\act_1\\connecttobar\\main\\PATH_Walkaway_1")
  end
  for i, v in ipairs(self.tCrowdStumblenow) do
    self:CrowdWalkaway(v, "Missions\\act_1\\connecttobar\\main\\PATH_StumbleAway")
  end
  for i, v in ipairs(self.tCrowdWalkaway) do
    local aFacing = Actor.CalcFacingTo(v, hSab)
    local tCheerAnims = {
      "shrd_M_crowd_06",
      "shrd_M_crowd_05"
    }
    local iCoin = math.random(1, 2)
    Actor.PlayAnimation(v, tCheerAnims[iCoin], math.random(3, 10), false, aFacing)
  end
  for i, v in ipairs(self.tCrowdStumbleaway) do
    local aFacing = Actor.CalcFacingTo(v, hSab)
    local tCheerAnims = {
      "shrd_M_crowd_06",
      "shrd_M_crowd_05"
    }
    local iCoin = math.random(1, 2)
    Actor.PlayAnimation(v, tCheerAnims[iCoin], math.random(3, 10), false, aFacing)
  end
  self.CrowdWait(self, self.tCrowdWalkaway, "Missions\\act_1\\connecttobar\\main\\PATH_Walkaway_1", 1, 25)
  self.CrowdWait(self, self.tCrowdStumbleaway, "Missions\\act_1\\connecttobar\\main\\PATH_StumbleAway", 10, 25)
  EVENT_ActorEntersTrigger("Act_1_ConnectToBar.TASK_StadiumCrowd", self, hSab, "Missions\\act_1\\connecttobar\\main\\PT_StadiumCrowd")
  EVENT_Timer("Act_1_ConnectToBar.GarageCrowdCheerStop", self, 7)
  EVENT_Timer("Act_1_ConnectToBar.ObjectiveTut", self, 3)
end

function Act_1_ConnectToBar:GarageCrowdCheerStop()
  Sound.DeactivateSoundEmitter(Util.GetHandleByName("Missions\\act_1\\connecttobar\\crowd\\Sound_CrowdCheer"))
end

function Act_1_ConnectToBar:StadiumCrowd()
  self.tStadiumWalkaway = Tips.GetListFromNames("Missions\\act_1\\connecttobar\\stadiumcrowd\\Spore_CV_WalkAway_")
  self.tStadiumStumbleaway = Tips.GetListFromNames("Missions\\act_1\\connecttobar\\stadiumcrowd\\Spore_CV_StumbleAway_")
  self.CrowdWait(self, self.tStadiumWalkaway, "Missions\\act_1\\connecttobar\\main\\PATH_Walkaway_1", 1, 10)
  self.CrowdWait(self, self.tStadiumStumbleaway, "Missions\\act_1\\connecttobar\\main\\PATH_StumbleAway", 1, 10)
  EVENT_ActorEntersTrigger("Act_1_ConnectToBar.Flyover", self, hSab, "Missions\\act_1\\connecttobar\\main\\PT_BarFlyover")
  EVENT_ActorEntersTrigger("Act_1_ConnectToBar.TASK_BarCrowd", self, hSab, "Missions\\act_1\\connecttobar\\main\\PT_BarCrowd")
end

function Act_1_ConnectToBar:BarCrowd()
end

function Act_1_ConnectToBar:BarCrowdCheer()
  Sound.ActivateSoundEmitter(Util.GetHandleByName("Missions\\act_1\\connecttobar\\barcrowd\\Sound_CrowdCheer"))
  Sound.ActivateSoundEmitter(Util.GetHandleByName("Missions\\act_1\\connecttobar\\barcrowd\\Sound_CrowdCheer2"))
  Sound.ActivateSoundEmitter(Util.GetHandleByName("Missions\\act_1\\connecttobar\\barcrowd\\Sound_CrowdCheer3"))
  Sound.ActivateSoundEmitter(Util.GetHandleByName("Missions\\act_1\\connecttobar\\barcrowd\\Sound_CrowdCheer4"))
  EVENT_Timer("Act_1_ConnectToBar.BarCrowdCheerStop", self, 10)
end

function Act_1_ConnectToBar:BarCrowdCheerStop()
  Sound.DeactivateSoundEmitter(Util.GetHandleByName("Missions\\act_1\\connecttobar\\barcrowd\\Sound_CrowdCheer"))
  Sound.DeactivateSoundEmitter(Util.GetHandleByName("Missions\\act_1\\connecttobar\\barcrowd\\Sound_CrowdCheer2"))
  Sound.DeactivateSoundEmitter(Util.GetHandleByName("Missions\\act_1\\connecttobar\\barcrowd\\Sound_CrowdCheer3"))
  Sound.DeactivateSoundEmitter(Util.GetHandleByName("Missions\\act_1\\connecttobar\\barcrowd\\Sound_CrowdCheer4"))
  self.CompleteThisMission(self)
end

function Act_1_ConnectToBar:CrowdWait(a_tCrowd, a_sPath, a_fMin, a_fMax, a_bCheer)
  for i, v in ipairs(a_tCrowd) do
    local a_hDude = v
    EVENT_Timer("Act_1_ConnectToBar.CrowdWalkaway", self, math.random(a_fMin, a_fMax), {a_hDude, a_sPath})
  end
end

function Act_1_ConnectToBar:CrowdWalkaway(a_hDude, a_sPath)
  Actor.EnableNeeds(a_hDude, false)
  Nav.SetScriptedPath(a_hDude, a_sPath, true, "Act_1_ConnectToBar.Disperse", self, {a_hDude})
end

function Act_1_ConnectToBar:Disperse(a_hDude, a_TEST2, a_TEST3)
  local a = a_hDude
  local b = a_TEST2
  local c = a_TEST3
  Actor.EnableNeeds(a_hDude, true)
end

function Act_1_ConnectToBar:Flyover()
  Cin.PlayCinematic("A1M1_Barflyby")
  EVENT_Timer("Act_1_ConnectToBar.BarCrowdCheer", self, 8)
end

function Act_1_ConnectToBar:Cleanup()
  Sound.ReleaseSoundBank("m_A3M1_inGame.bnk")
end
