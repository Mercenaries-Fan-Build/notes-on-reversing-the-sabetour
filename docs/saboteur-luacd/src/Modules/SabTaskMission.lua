if SabTaskMission == nil then
  SabTaskMission = SabTask:Create()
end

function SabTaskMission:Activated()
  SabTask.Activated(self)
  table.insert(SabTask._tMASTERSELFIDLISTOFLISTS, {
    Name = self:GetID(),
    IDLIST = {},
    APID = self._SELFTABLE_ID
  })
  self.tCompletedTasksList = {}
  self.tMissionNodeList = {
    {
      NodeType = "dynamic",
      {}
    },
    {
      NodeType = "static",
      {}
    },
    {
      NodeType = "cinematic",
      {}
    }
  }
  self.bUnloadNodes = false
  self._bMissionFail = false
  self._bMissionTaskFail = false
  local tConfig = self:GetConfig()
  local oStarterInteraction, tStarterTable, tInteriorTable
  if __gDEBUG_REWARDS then
    __gDEBUG_SETOPEN = true
    RewardsManager.Debug_UnlockPreviousRewards(self:GetID())
    __gDEBUG_REWARDS = false
    __gDEBUG_SETCOMPLETES = true
  end
  if self:GetConfig().tBriefingConfig.tTgtInclude[1] and self:GetConfig().tBriefingConfig.tTgtInclude[1] ~= "" then
    self.sStarterActor = tConfig.sStarter
    oStarterInteraction = SabTaskObjectiveInteract:Create()
    tStarterTable = StarterManager.GetStarterTable(self.sStarterActor)
    if tStarterTable then
      self.sStarter = tStarterTable.sName
      self:GetConfig().tBriefingConfig.tTgtInclude = {
        StarterManager.GetStarterWithPath(tStarterTable.sName)
      }
      if tStarterTable.sInterior and tStarterTable.sInterior ~= "" then
        tInteriorTable = InteriorManager.GetInteriorTable(tStarterTable.sInterior)
      end
    elseif self.sStarterActor then
      Util.Assert(false, "SabTaskMission:Activated starter does not exist in startermanger, tell CFrench " .. self.sStarterActor)
      print("ERROR:: SabTaskMission:Activated starter does not exist in startermanger, tell CFrench " .. self.sStarterActor)
    end
    local fullstarter = self.sStarterActor
    if tStarterTable then
      fullstarter = self:GetStarter()
    end
    self.eStarterStream = EVENT_Stream("SabTaskMission.SetMissionStarterInvincible", self, fullstarter, true, {fullstarter})
  end
  local gameplaymodule = self:GetConfig().tGameplayConfig.sTaskType
  local oGameplay = __UtilFunctions.GetTableFromNameSpace(gameplaymodule)
  local oConversation
  local MCDisplayID = tConfig.MCDisplayID or cMISSIONCOMPLETESTANDARD
  local sInteraction = gameplaymodule .. "_StarterInteraction"
  local sBriefing = gameplaymodule .. "_Briefing"
  if oStarterInteraction then
    local tStarterNode = {}
    if tStarterTable then
      if tStarterTable.bInterior then
        tConfig.bIntStarter = true
      end
      tSetupActivate = {
        {
          SabTaskGameMaster.CheckForReset,
          {oGameMaster, self}
        }
      }
    else
      tSetupActivate = {
        {
          SabTaskGameMaster.CheckForReset,
          {oGameMaster, self}
        }
      }
    end
    if tInteriorTable and tStarterTable then
      InteriorManager.RequestExteriorBlip(tInteriorTable.sName, self:GetStarterIcon())
    end
    local bAF = false
    local Prox = 10
    if self:GetConfig().tBriefingConfig.ProximityStart then
      print("proximity start ", self:GetConfig().tBriefingConfig.ProximityStart)
      Prox = self:GetConfig().tBriefingConfig.ProximityStart
      bAF = true
    end
    oStarterInteraction:Configure({
      sName = sInteraction,
      oParent = self,
      sTaskType = "SabTaskObjectiveInteract",
      sTaskSubType = "TALK",
      bInteriorTask = tConfig.bIntStarter,
      bHelpMode = false,
      bAutofire = bAF,
      Proximity = Prox,
      bUseOldAutofire = self:GetConfig().tBriefingConfig.bUseOldAutofire,
      FocusRadius = 50,
      bAutofireInterior = self:GetConfig().tBriefingConfig.bAutofireInterior,
      MarkerHeight = self:GetConfig().tBriefingConfig.MarkerHeight,
      bHighPriorityFocus = true,
      bStarterFlag = true,
      bNoGPS = true,
      bEscalationDenial = self:GetConfig().tBriefingConfig.bEscalationDenial,
      tSMEDNodes = tStarterNode,
      sStarter = self.sStarter,
      tOnCancel = {
        {
          self.BriefingCancelled,
          {self}
        }
      },
      tOnComplete = self:GetBriefingOnComplete(oConversation, oGameplay),
      tOnActivate = {}
    })
    oStarterInteraction:Configure(self:GetConfig().tBriefingConfig)
  end
  if oGameplay:IsCompleted() then
    print("DEBUG:: original gameplay was completed ", self:GetName())
    oGameplay:ResetState()
  end
  oGameplay:Configure({
    sName = gameplaymodule .. "_Gameplay",
    oParent = self,
    sTaskType = gameplaymodule,
    tOnActivate = self:GetOnGameplayActivate(oGameplay),
    tOnComplete = {
      {
        self.PreMissionComplete,
        {self}
      }
    },
    tOnCancel = {
      {
        self.PreGameplayCancelled,
        {self}
      }
    }
  })
  oGameplay:Configure(self:GetConfig().tGameplayConfig)
  oGameplay._bGameplayTask = true
  if oStarterInteraction and not tStarterTable then
    oStarterInteraction:BuildFoundation()
  elseif oStarterInteraction and tStarterTable then
    self.__oStarterInteraction = oStarterInteraction
    if self:GetConfig().tBriefingConfig.bAutofireInterior then
      print("setting up autfire interior task")
      oStarterInteraction:BuildFoundation()
    elseif not tConfig.bIntStarter then
      self:LoadStarter(tStarterTable.sName, true)
    else
      if self.sStarter then
        StarterManager.AddInteractionTaskToList(self.sStarter, oStarterInteraction)
      else
        Util.Assert(self.sStarter, "ERROR:: Incorrect starter for this?")
      end
      if InteriorManager.GetPlayersInterior() == tStarterTable.sInterior then
        print("SabTaskMission:: player is in interior where this starter is ", tStarterTable.sInterior, tStarterTable.sName)
        StarterManager.LoadInteriorStarterNode(tStarterTable.sName)
      end
    end
  elseif tConfig.bWorldEvent or tConfig.bStarterless then
    if tConfig.bStarterless then
      SaveLoad.SetupSpecialLuaTimerCallback(self, "SabTaskMission.ActivateStarterlessMission", 0.15)
    else
      Util.CreateEvent({EventType = "TimerEvent", Time = 0.15}, "SabTaskMission.ActivateStarterlessMission", self)
    end
    print("DEBUG:: About to activate world event or starterless mission ", self:GetName())
    if oGameplay.STARTER_Setup then
      oGameplay:STARTER_Setup()
    end
    local tConfig = self:GetConfig()
    if tConfig and tConfig.bSLOverrideFade then
      Util.SetOverrideLoadScreenFadeIn(true)
    end
    SabTaskMission._bStarterlessMissionActive = true
    self:MissionSetState(_ACTIVE)
  else
    Util.CreateEvent({EventType = "TimerEvent", Time = 2.5}, "SabTaskMission.BeginStarterlessMission", self)
  end
end

function SabTaskMission:LoadStarter(sStarterName, bBuildFoundation)
  local tStarterTable = StarterManager.GetStarterTable(sStarterName)
  if self and type(self) == "number" then
    return
  end
  if not self.__oStarterInteraction then
    print("ERROR:SabTaskMission:LoadStarter no interaction object found for starter")
  end
  print("SabTaskMission:LoadStarter ", sStarterName)
  if not StarterManager.LoadStarterNode(tStarterTable.sName, self.__oStarterInteraction, bBuildFoundation) then
    print("starter not loaded yet trying again ", tStarterTable.sName)
    local hSanityCheck = Handle(StarterManager.GetFullPath(tStarterTable.sName))
    if hSanityCheck then
      print("ERROR: SabTaskMission:LoadStarter ", StarterManager.GetFullPath(tStarterTable.sName), " appears ready but is returning not loaded!")
    end
    EVENT_Timer("SabTaskMission.LoadStarter", self, 0.75, {sStarterName, bBuildFoundation})
    return
  else
  end
  self.__oStarterInteraction = nil
end

function SabTaskMission:BeginStarterlessMission()
  print("BOOG: Begin starterless mission")
  local tConfig = self:GetConfig()
  if oGameMaster.oActiveGameplayMission and not tConfig.bWorldEvent then
    print("WARNING: YOU ARE STARTING A MISSION FROM INSIDE ANOTHER MISSION , IS THIS A WORLD EVENT?")
    local errmsg = "WARNING: YOU ARE STARTING A MISSION FROM INSIDE ANOTHER MISSION "
  end
  Util.CreateEvent({EventType = "TimerEvent", Time = 1.5}, "SabTaskMission.ActivateStarterlessMission", self)
end

function SabTaskMission:ActivateStarterlessMission()
  print("DEBUG: Activating starterless mission ", self:GetName())
  local tConfig = self:GetConfig()
  self:StartGameplay()
end

function SabTaskMission:GetBriefingOnComplete(oConversation, oGameplay)
  local tOnComplete = {}
  if oConversation then
    tOnComplete = {
      {
        oConversation.BuildFoundation,
        {oConversation}
      }
    }
  else
    tOnComplete = {
      {
        self.InteractionComplete,
        {self}
      }
    }
  end
  return tOnComplete
end

function SabTaskMission:GetOnGameplayActivate(oGameplay)
  local tConfig = self:GetConfig()
  local tOnActivate = {}
  if not oGameplay then
    print("ERROR:: oGameplay is nil in GetOnGameplayActivate")
    return {}
  end
  if tConfig.bWorldEvent then
    tOnActivate = {
      {
        SabTaskMission.GameplaySetup,
        {self, oGameplay}
      }
    }
  else
    tOnActivate = {
      {
        SabTaskMission.GameplaySetup,
        {self, oGameplay}
      },
      {
        oGameplay._SetupPlayerDeath,
        {oGameplay}
      }
    }
  end
  return tOnActivate
end

function SabTaskMission:PreGameplayCancelled()
  SaveLoad.ClearCheckpoint()
  local tConfig = self:GetConfig()
  if self.bSaveLoad then
    self:GameplayCancelled()
    self.bSaveLoad = nil
  else
    EVENT_Timer("SabTaskMission.GameplayCancelled", self, 1)
  end
end

function SabTaskMission:GameplaySetup(oGameplay)
  local tConfig = self:GetConfig()
  print("gameplay loaded ", self:GetName())
  oGameplay._StartLoadGameplayState = false
  if tConfig.sArcID ~= nil and tConfig.sArcID ~= "" then
    oGameMaster.sActiveArc = tConfig.sArcID
  else
    oGameMaster.sActiveArc = ""
  end
  if oGameMaster.oActiveGameplayMission and not tConfig.bWorldEvent then
    print("WARNING: YOU ARE STARTING A MISSION FROM INSIDE ANOTHER MISSION , IS THIS A WORLD EVENT?")
    local errmsg = "WARNING: YOU ARE STARTING A MISSION FROM INSIDE ANOTHER MISSION "
    return
  end
  self:SetActiveMission(oGameplay)
  if tConfig.sSaveMissionNameID then
    Util.SetPlayerCurrentMission(tConfig.sSaveMissionNameID)
  end
  local tStarterTable = StarterManager.GetStarterTable(self.sStarterActor)
  if tStarterTable and tStarterTable.sInterior then
    InteriorManager.FinishedWithExteriorBlip(tStarterTable.sInterior, self:GetStarterIcon())
  end
end

function SabTaskMission:SetActiveMission(oSetGameplay)
  local tConfig = self:GetConfig()
  local bActive = false
  if oSetGameplay then
    bActive = true
  else
    print("clearing active mission")
  end
  if not tConfig.bWorldEvent then
    oGameMaster.oActiveGameplayMission = oSetGameplay
    local bMissionNoWitnessEligible = false
    if bActive and (tConfig.MCDisplayID == cMISSIONCOMPLETESTANDARD or tConfig.MCDisplayID == nil) then
      bMissionNoWitnessEligible = true
      print("STORY MISSION")
    end
    if self:GetID() == "Paris_3_Mission_1" then
      bMissionNoWitnessEligible = true
      print("STORY MISSION")
    end
    if self:GetID() == "Connect_P3_M1b_KesslerAtDoppelsieg" then
      bMissionNoWitnessEligible = false
    end
    Object.SetOnActiveMission(hSab, bActive, bMissionNoWitnessEligible)
  end
end

function SabTaskMission:StartGameplay()
  local oGameplay = self:GetGameplayTask()
  local tConfig = self:GetConfig()
  print("start load gameplay")
  if not oGameplay then
    Util.Assert(false, "SabTaskMission:StartGameplay oGameplay is nil, bad times")
    print("ERROR:SabTaskMission:StartGameplay oGameplay is nil this is really really bad", self:GetName())
  end
  if not oGameplay then
    print("ERROR:: SabTaskMission : No Gameplay task found ", self:GetName())
    print("ABORTING ACTIVATION")
    return
  end
  oGameplay._StartLoadGameplayState = true
  local tGPConfig = oGameplay:GetConfig()
  if tConfig.sObjTextFile and tConfig.sObjTextFile ~= "" then
    FocusPt.LoadMissionPictures(tConfig.sObjTextFile)
  end
  if not tConfig.bWorldEvent then
    oGameMaster:SuppressPotentialMissions(self)
  elseif tConfig.bWorldEvent then
    oGameMaster:UnregisterPotentialMission(self)
  end
  if tGPConfig.sMissionStartTime then
    oGameplay._bTimeOfDayChange = true
  end
  Common.InsertTableItem(self._tActiveMissionList, tConfig.sID, true)
  RewardsManager.__GivePreMissionReward(self:GetID())
  __gDEBUG_SETCOMPLETES = false
  __gDEBUG_SETOPEN = false
  if not tConfig.bWorldEvent then
    if tConfig.sHQStartPoint then
      print("Debug:Setting player's last hq point to ", tConfig.sHQStartPoint)
      Util.SetPlayerLastHQ(tConfig.sHQStartPoint)
    elseif InteriorManager.GetPlayersInterior() ~= "" or InteriorManager.GetPlayersInterior() ~= nil then
      local tInteriorTable = InteriorManager.GetInteriorTable(InteriorManager.GetPlayersInterior())
      if tInteriorTable and tInteriorTable.sHQPoint then
        print("Debug:Setting player's last hq point to ", InteriorManager.GetPlayersInterior(), tInteriorTable.sHQPoint)
        Util.SetPlayerLastHQ(tInteriorTable.sHQPoint)
      end
    end
  end
  if not tConfig.bWorldEvent then
    SaveLoad.CreateSnapshot(self, "SabTaskMission._CallbackPreGameplayAutosave")
  else
    self:_CallbackPreGameplayAutosave()
  end
end

function SabTaskMission:_CallbackPreGameplayAutosave()
  local oGameplay = self:GetGameplayTask()
  local tConfig = self:GetConfig()
  if not tConfig.bWorldEvent then
    Render.Rain(0, 1)
    print("SabTaskMission:_CallbackPreGameplayAutosave - Post gameplay start autosave")
  end
  if not oGameplay then
    Util.Assert(false, "SabTaskMission:_CallbackPreGameplayAutosave oGameplay is nil, bad times")
    print("ERROR:SabTaskMission:_CallbackPreGameplayAutosave oGameplay is nil this is really really bad", self:GetName())
  end
  if tConfig.sSaveMissionNameID and tConfig.sSaveMissionNameID ~= "" and not tConfig.bDisableMissionTitle then
    HUD.ShowMissionTitle(tConfig.sSaveMissionNameID, tConfig.sActNameID)
  end
  print("_CallbackPreGameplayAutosave")
  oGameplay:BuildFoundation()
end

function SabTaskMission:_Cleanup(bForceUnload, bSaveLoad)
  local tConfig = self:GetConfig()
  if tConfig.sStarter then
    StarterManager.RemoveInteractionTask(tConfig.sStarter)
  end
  HUD.ClearWaypoint()
  FocusPt.UnloadMissionPictures()
  if self.eStarterStream then
    Util.KillEvent(self.eStarterStream)
    self.eStarterStream = nil
  end
  if tConfig.bArcFinale and self:MissionGetState() == _COMPLETE then
    oGameMaster.sActiveArc = ""
  end
  if tConfig.bArcBegin and self:MissionGetState() == _CANCELLED then
    oGameMaster.sActiveArc = ""
  end
  if oGameMaster.oActiveGameplayMission and oGameMaster.oActiveGameplayMission == self:GetGameplayTask() then
    self:SetActiveMission()
    Util.SetPlayerCurrentMission("")
    SabTaskMission._bStarterlessMissionActive = false
  end
  local tStarterTable = StarterManager.GetStarterTable(tConfig.sStarter)
  if tStarterTable and tStarterTable.sInterior then
    print("done with exterior blip ", self:GetStarterIcon())
    InteriorManager.FinishedWithExteriorBlip(tStarterTable.sInterior, self:GetStarterIcon())
  end
  SabTask._Cleanup(self, bForceUnload, bSaveLoad)
end

function SabTaskMission:GameplayCancelled()
  local tConfig = self:GetConfig()
  if self:IsActive() then
    self:MissionSetState(_CANCELLED)
    if not self.bSaveLoad then
    end
    if not __gb_DontResetEscalation then
      Suspicion.ResetEscalation()
    end
    __gb_DontResetEscalation = nil
    if Actor.GetVehicle(hSab) then
    end
    self:Cancel(self.bSaveLoad)
  else
    print("DEBUG:: in gameplaycancelled : Action Package wasn't even active, WTF!? Fix me freedom")
  end
  Common.RemoveTableItem(self._tActiveMissionList, tConfig.sID)
  SabTaskGameMaster.RegisterPotentialMission(oGameMaster, self)
end

function SabTaskMission:ReActivateInteraction(oInteractionTask)
  local oIT
  if oInteractionTask then
    oIT = oInteractionTask
  else
    oIT = self:GetInteractionTask()
  end
  oIT:ResetState()
  oIT:BuildFoundation()
end

function SabTaskMission:BriefingCancelled()
  if self:IsActive() then
    print("in sabtaskmission briefing cancelled ", self:GetName())
    self:ReActivateInteraction()
  end
end

function SabTaskMission:InteractionComplete()
  if self:IsActive() then
    if self:GetGameplayTask():IsActive() then
    else
      self:StartGameplay()
      self:GetInteractionTask():GetConfig().bHelpMode = true
    end
    self:GetInteractionTask():GetConfig().bNoBlips = true
  end
end

function SabTaskMission:PreMissionComplete()
  self:_MissionComplete()
end

function SabTaskMission:_MissionComplete()
  print("in mission complete, ", self:GetName())
  local tConfig = self:GetConfig()
  local MCDisplayID = tConfig.MCDisplayID or cMISSIONCOMPLETESTANDARD
  Util.MissionComplete()
  if not tConfig.bWorldEvent then
    Render.Rain(0, 1)
    Render.EnableAmbientRain(true)
  end
  EVENT_Timer("SabTaskMission.DisplayMissionCompleteHUD", self, 1, MCDisplayID)
  local tUnlockList = RewardsManager.GetMissionUnlockList(self:GetID())
  if not tConfig.bWorldEvent then
    if tConfig.sHQNextMissionStartPoint then
      print("setting next mission's start point")
      Util.SetPlayerLastHQ(tConfig.sHQNextMissionStartPoint)
    else
      Util.SetPlayerLastHQ(0)
    end
  end
  if not tConfig.bRepeatable then
    self:MissionSetState(_COMPLETE)
    table.insert(self.tCompletedMissionList, self:GetName())
    SabTaskGameMaster.RemoveOpenMission(oGameMaster, tConfig.sID)
    Common.RemoveTableItem(self._tActiveMissionList, tConfig.sID)
  else
    print("DEBUG:: Keeping repeatable mission open ", self:GetName())
    SabTaskGameMaster.RegisterPotentialMission(oGameMaster, self)
  end
  RewardsManager.__GiveMissionReward(self:GetID())
  local tStarterTable = StarterManager.GetStarterTable(self.sStarterActor)
  local tShopTable
  if tStarterTable ~= nil then
    tShopTable = ShopManager.GetShopTable(tStarterTable.sShopName)
  end
  if tShopTable ~= nil then
    local sActorPath = StarterManager.GetFullPath(self.sStarterActor)
    local hActor = Util.GetHandleByName(sActorPath)
    Actor.SetupShop(hActor, tStarterTable.sShopName, tShopTable.tBlueprintList)
  end
  if tConfig.tDisabledMissionsList then
    oGameMaster:DisableMissions(tConfig.tDisabledMissionsList)
  end
  if tConfig.tUnlockList then
    oGameMaster:UnlockPotentialMissions(tConfig.tUnlockList)
  end
  if tUnlockList then
    oGameMaster:UnlockPotentialMissions(tUnlockList)
  end
  if SabTask._tSpecialCaseUnlockedList then
    oGameMaster:UnlockPotentialMissions(SabTask._tSpecialCaseUnlockedList)
    SabTask._tSpecialCaseUnlockedList = {}
  end
  if tConfig.sSaveMissionNameID and tConfig.sSaveMissionNameID ~= "" then
    Util.SetPlayerLastCompletedMission(tConfig.sSaveMissionNameID)
  end
  SabTask._Complete(self)
  SabTaskGameMaster.bFlagAutoSave = true
  Util.ResetDayTimeScale()
  SaveLoad.ClearCheckpoint()
  collectgarbage()
end

function SabTaskMission:DelayedReregister()
end

function SabTaskMission:DisplayMissionCompleteHUD(id)
  print("Display Mission Complete")
  if id == nil or id ~= cNOMISSIONCOMPLETE then
    Render.ShowMissionComplete(id)
    Sound.PlayMusicStab("Success_Stab")
  elseif id == cNOMISSIONCOMPLETE then
  end
end

function SabTaskMission:MissionSetState(state)
  self.MissionGameplayState = state
end

function SabTaskMission:MissionGetState()
  return self.MissionGameplayState
end

function SabTaskMission:GetGameplayTask()
  local tConfig = self:GetConfig()
  return SabTask.GetGameplayTask(self)
end

function SabTaskMission:GetInteractionTask()
  local oInteraction
  local tConfig = self:GetConfig()
  for _, o in pairs(self:GetChildren()) do
    if string.find(o:GetName(), "_StarterInteraction") then
      oInteraction = o
      break
    end
  end
  return oInteraction
end

function SabTaskMission:DisplayMissionFailure()
  local r, g, b, fontsize
  r = 255
  g = 255
  b = 0
  sTextID = "Global.MissionFail"
  if TestTextR and TestTextG and TestTextB then
    r = TestTextR
    g = TestTextG
    b = TestTextB
  end
  local sString = self:GetLocalizedText(sTextID)
  fontsize = iFontSize or 18
  local oGameplay = self:GetGameplayTask()
  if not oGameplay then
    Util.Assert(false, "There is no gameplay object in DisplayMissionFailure, get Chris French", self:GetName())
    return
  end
  hMessage = HUD.AddUpdateBoxText(sString, 5, r, g, b, true)
  if oGameplay._sFailureID then
    self:ShowToolTip(oGameplay._sFailureID)
  else
  end
  oGameplay._sFailureID = nil
end

function SabTaskMission:SetMissionStarterInvincible(vStarter)
  if self and type(self) == "number" then
    return
  end
  local tConfig = self:GetConfig()
  local hHandle = Handle(vStarter)
  if hHandle then
    Combat.AddTargetFlag(hHandle, cTARGET_NOAUTORESPONSE)
    Combat.SetGrabbable(hHandle, false)
    Actor.SetLabel(hHandle, "nopush", true)
  else
    print("WARNING:: Something didn't stream in correctly in SetMissionStarterInvincible")
  end
end

function SabTaskMission:ClearStarterThings(vStarter)
  local tConfig = self:GetConfig()
  local hHandle = Handle(vStarter)
  if hHandle then
    Combat.SetGrabbable(hHandle, true)
    Actor.SetLabel(hHandle, "nopush", false)
  else
    print("WARNING:: Something didn't stream in correctly in ClearStarterThings")
  end
end

function SabTaskMission:_CallbackMissionStarterDeath(vStarter)
  print("missionfailk for starter death", vStarter)
  Util.MissionFail()
end

function CancelMissionByName(sMissionName)
  local oMission = __UtilFunctions.GetTableFromNameSpace(sMissionName)
  local oGameplay
  if not oMission then
    print("ERROR:: Attempt to cancel mission, but it does not exist in namespace ", sMissionName)
    return
  else
    oGameplay = oMission:GetGameplayTask()
  end
  if oGameplay and oGameplay:IsActive() then
    oGameplay:Cancel()
  else
    print(oGameplay:GetName(), " doesn't exist or isn't active")
  end
end

function CompleteMissionByName(sMissionName)
  local oMission = __UtilFunctions.GetTableFromNameSpace(sMissionName)
  local oGameplay
  if not oMission then
    print("ERROR:: Attempt to complete mission, but it does not exist in namespace ", sMissionName)
    return
  else
    oGameplay = oMission:GetGameplayTask()
  end
  if oGameplay and oGameplay:IsActive() and not oGameplay:GetMissionFail() then
    oGameplay:_Complete()
  else
    print(oGameplay:GetName(), " doesn't exist or isn't active")
  end
end
