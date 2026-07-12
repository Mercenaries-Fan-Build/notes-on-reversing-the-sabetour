if Connect_A1_M2c_JulesToTrack == nil then
  Connect_A1_M2c_JulesToTrack = SabTaskObjective:Create()
  gsConnect_A1_M2c_JulesToTrack = "Missions\\act_1\\connecttoracetrack\\"
  Util.SetTime(6, 0)
  Connect_A1_M2c_JulesToTrack:Configure({
    TaskCount = 99,
    bFreezeTimeScale = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    sSaveMissionNameID = "MissionNames_Text.A1M2B",
    bDisableMissionTitle = true,
    tUnlockList = {"Act_1_Race"},
    bStarterless = true,
    bSLOverrideFade = true,
    tSMEDNodes = {
      gsConnect_A1_M2c_JulesToTrack .. "main"
    }
  })
end

function Connect_A1_M2c_JulesToTrack:STARTER_Setup()
  Render.SetGlobalWTF(true)
  Util.SpawnEditNode("Missions\\act_1\\characters\\jules_smashup.wsd")
  Sound.LoadSoundBank("M_A1M1B_inGame.bnk")
end

function Connect_A1_M2c_JulesToTrack:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Connect_A1_M2c_JulesToTrack:TeleReady()
  self.bTeleReady = true
  if self.bCostumeReady == true then
    self:Ready()
  end
end

function Connect_A1_M2c_JulesToTrack:CostumeReady()
  self.bCostumeReady = true
  if self.bTeleReady == true then
    self:Ready()
  end
end

function Connect_A1_M2c_JulesToTrack:Ready()
  EVENT_Timer("Connect_A1_M2c_JulesToTrack.FadeScreenIn", self, 2)
  self:RegisterCheckpoint("Connect_A1_M2c_JulesToTrack.Checkpoint1")
end

function Connect_A1_M2c_JulesToTrack:GENERAL_Setup()
  self.bTeleReady = false
  self.bCostumeReady = false
  self.DEBUGMODE = true
  Util.SetDisguiseCompleteCallback("Connect_A1_M2c_JulesToTrack.CostumeReady", self)
  Actor.SetDisguise(hSab, "FBS_RS_Sean_Race_Race_NoHat_Bag")
  self.tInfo.Jules = "Missions\\act_1\\characters\\jules_smashup\\jules_act1_connectracetrack"
  self:AddOnCancelCallback(Connect_A1_M2c_JulesToTrack.Reset)
  self:AddOnCompleteCallback(Connect_A1_M2c_JulesToTrack.Reset)
  Object.PlayerTeleportToLocator(Util.GetHandleByName("Missions\\act_1\\connecttoracetrack\\main\\LOC_ConnectToTrack"), true, "Connect_A1_M2c_JulesToTrack.TeleReady", self)
  self.bEarlyExit = false
  self.iPickup = 1
  WorldSMEDNodes.PreLoadCinematicNode("113_cina_racego")
end

function Connect_A1_M2c_JulesToTrack:MISSION_ONCANCEL()
  WorldSMEDNodes.UnloadCinematicNode("113_cina_racego", true)
end

function Connect_A1_M2c_JulesToTrack:FadeScreenIn()
  Util.SetOverrideLoadScreenFadeIn(false)
  Render.FadeScreen(false)
end

function Connect_A1_M2c_JulesToTrack:Reset()
end

function Connect_A1_M2c_JulesToTrack:MISSION_ONCANCEL()
  Util.UnloadEditNode("Missions\\act_1\\characters\\jules_smashup.wsd")
end

function Connect_A1_M2c_JulesToTrack:Checkpoint1()
  self.FailEvent(self)
end

function Connect_A1_M2c_JulesToTrack:Task_EscortJules()
  self:CreateTask({
    sName = "Task_EscortJules",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "TAXI",
    sObjectiveTextID = "A1M2c_Text.TASK_GetToRace",
    bNoCarRequired = true,
    sVehicleReturnID = "A1M2c_Text.TASK_EscortJules",
    tDestLocators = {
      gsConnect_A1_M2c_JulesToTrack .. "main\\LOC_ConnectToTrackDropoff"
    },
    tDestRegion = {
      gsConnect_A1_M2c_JulesToTrack .. "main\\REG_ConnectToTrackDropoff"
    },
    tDeliverObjs = {
      self.tInfo.Jules
    },
    tPickupProxObj = {
      self.tInfo.Jules
    },
    PickupProximity = 50,
    bGroundBlip = true,
    bEscalationDenial = true,
    tOnEarlyExit = {
      {
        self.EarlyExit,
        {self}
      }
    },
    tOnPickup = {},
    tOnComplete = {
      {
        Cin.LoadCinematic,
        {
          "113_CinA_RaceGo"
        }
      },
      {
        self.Cleanup,
        {self}
      }
    },
    tOnActivate = {
      {
        Saboteur.ShowToolTip,
        {
          "TutorialTip_Text.Stealing_Cars"
        }
      },
      {
        EVENT_PlayerEntersAnyVehicle,
        {
          "Connect_A1_M2c_JulesToTrack.GetInConv",
          self
        }
      }
    }
  })
end

function Connect_A1_M2c_JulesToTrack:EarlyExit()
  if self.bEarlyExit == false then
    self.bEarlyExit = true
    Cin.PlayConversation("A1M2c_Taxi_Return")
  end
end

function Connect_A1_M2c_JulesToTrack:Pickup()
  if self.iPickup == 1 then
    EVENT_PlayerEntersAnyVehicle("Connect_A1_M2c_JulesToTrack.GetInConv", self)
  elseif self.iPickup == 2 then
    Cin.PlayConversation("A1M2c_Taxi_LetsGo")
  end
  self.iPickup = self.iPickup + 1
end

function Connect_A1_M2c_JulesToTrack:Cleanup()
  if Actor.IsInVehicle(hSab) then
    Actor.UnboardVehicle(hSab)
  end
  Render.FadeScreen(true, 0)
  Sound.SetMusicLocale("cin_113_cinA_RaceGo")
  Sound.SetMusicLocale("Cinematic", "In")
  Util.UnloadEditNode("Missions\\act_1\\characters\\jules_smashup.wsd")
  Sound.ReleaseSoundBank("M_A1M1B_inGame.bnk")
  self.CompleteThisMission(self)
end

function Connect_A1_M2c_JulesToTrack:Convo_GetToTrack()
  Actor.CancelAttrPt(Util.GetHandleByName("Missions\\act_1\\characters\\jules_smashup\\jules_act1_connectracetrack"))
  Cin.PlayConversation("110_InG_2Pits", "Connect_A1_M2c_JulesToTrack.Task_EscortJules", self)
end

function Connect_A1_M2c_JulesToTrack:GetInConv()
  Util.ClearAllPendingTutorials()
  Cin.PlayConversation("A1M2c_Taxi_WaitForFollower")
  EVENT_ActorEntersAnyVehicle("Connect_A1_M2c_JulesToTrack.Pickup", self, Util.GetHandleByName(self.tInfo.Jules))
end

function Connect_A1_M2c_JulesToTrack:GotInConv()
  Cin.PlayConversation("A1M2c_Taxi_LetsGo")
end

function Connect_A1_M2c_JulesToTrack:ToCurb()
  ACTOR_WalkToObject("Missions\\act_1\\characters\\jules_smashup\\jules_act1_connectracetrack", "Missions\\act_1\\connecttoracetrack\\main\\LOC_JulesCurb")
end

function Connect_A1_M2c_JulesToTrack:FailEvent()
  self.tInfo.eFailJulesTooFar = EVENT_PlayerToActorProximityNegated("Connect_A1_M2c_JulesToTrack.FailJulesTooFar", self, Util.GetHandleByName(self.tInfo.Jules), 120)
  self.tInfo.eFailJulesTooFar = EVENT_PlayerToActorProximityNegated("Connect_A1_M2c_JulesToTrack.AlmostTooFar", self, Util.GetHandleByName(self.tInfo.Jules), 100)
  Combat.SetIdleScripted(Util.GetHandleByName(self.tInfo.Jules), true)
  EVENT_Timer("Connect_A1_M2c_JulesToTrack.Convo_GetToTrack", self, 3)
end

function Connect_A1_M2c_JulesToTrack:AlmostTooFar()
  Cin.PlayConversation("A1M2c_Taxi_Abandoned")
end

function Connect_A1_M2c_JulesToTrack:FailJulesTooFar()
  self:Fail("GenericFail_Text.ABANDON_Jules")
end

function Connect_A1_M2c_JulesToTrack:Fail(sFailString)
  self:MissionTaskFail(sFailString)
end

function Connect_A1_M2c_JulesToTrack:PrintDebug(a_sMessage)
  if self.DEBUGMODE == true then
    Render.PrintMessage(a_sMessage)
  end
end
