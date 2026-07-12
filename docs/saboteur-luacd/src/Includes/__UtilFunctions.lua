if not __UTILFUNCTIONS then
  __UTILFUNCTIONS = 1
  if __UtilFunctions == nil then
    __UtilFunctions = {}
    Common = {}
    ConvManager = {}
    ConvManager.tConvManagers = {}
  end
  _DRYUP = 1
  _ACTIVE = 2
  _POTENTIAL = 3
  _LATENT = 3
  _LOCKED = 4
  _COMPLETE = 5
  _DISABLED = 6
  _CANCELLED = 7
  _SUPPRESSED = 8
  sOrToken = " or "
  _NODE_DYNAMIC = 1
  _NODE_STATIC = 2
  _NODE_COLBY = 2
  _NODE_CINEMATIC = 3
  _NODE_DELETETRIGGERS = 4
  _NODE_INTERIOR = 5
  _NODE_MM = 6
  cOBJECTIVE_TEXT = 5
  cTOOLTIP_TEXT = 6
  cUPDATE_TEXT = 7
  cSUBTITLE_TEXT = 8
  cMISSIONCOMPLETESTANDARD = 0
  cMISSIONCOMPLETETIMEDRACE = 1
  cNOMISSIONCOMPLETE = 2
  _tDisabledControls = {
    Fire = 0,
    Fire2 = 0,
    Grenade = 0,
    WeakAttack = 0,
    GrabAttack = 0,
    GrabClamber = 0,
    ReleaseClamber = 0,
    Jump = 0,
    Action = 0,
    WeaponButton = 0,
    AutoTarget = 0,
    Zoom = 0,
    HandBreak = 0,
    EnterExitVehicle = 0,
    Gas = 0,
    Break = 0,
    Honk = 0,
    Sprint = 0,
    Sabotage = 0,
    Sneak = 0,
    FocusPressed = 0,
    InventoryChange = 0,
    Running = 0,
    Walking = 0,
    StealthKill = 0
  }
  __UtilFunctions._FollowerInvinEnabled = {}
  __UtilFunctions.UsefulAnimCatcher = {
    "nazi_halt_1",
    "nazi_checkpapers_1",
    "nazi_point",
    "civ_cower_idle",
    "civ_frustrated",
    "mel_v_kiss_idle",
    "mel_kiss_idle",
    "nazi_hail",
    "nazi_chat1"
  }
  
  function __UtilFunctions.LoadNode(sNode, a_sCallbackFunction, self, tData)
    if sNode and sNode ~= "" then
      local sFullNode = sNode .. ".wsd"
      if a_sCallbackFunction then
        Util.SpawnEditNode(sFullNode, a_sCallbackFunction, self, tData)
      else
        Util.SpawnEditNode(sFullNode)
      end
    end
  end
  
  function __UtilFunctions.UnloadNode(sNode, bForceUnload)
    if sNode and sNode ~= "" then
      local sFullNode = sNode .. ".wsd"
      if bForceUnload == nil then
        bForceUnload = false
      end
      if Util.IsBlockLoaded(sFullNode) then
        Util.UnloadEditNode(sFullNode, bForceUnload)
      end
    end
  end
  
  function __UtilFunctions.LoadInteriorNode(sNode, a_sCallbackFunction, self, tData)
    if sNode and sNode ~= "" then
      if a_sCallbackFunction then
        Util.SpawnInterior(sNode, a_sCallbackFunction, self, tData)
      else
        Util.SpawnInterior(sNode)
      end
    end
  end
  
  function __UtilFunctions.UnloadInteriorNode(sNode, a_sCallbackFunction, self, tData)
    if sNode and sNode ~= "" then
      Util.UnloadInterior(sNode)
    end
  end
  
  function __UtilFunctions.ReleaseInteriorNode(sNode, a_sCallbackFunction, self, tData)
    if sNode and sNode ~= "" then
      Util.ReleaseInterior(sNode)
    end
  end
  
  function __UtilFunctions.LoadStaticTag(sTag, bForceLoad)
    if sTag and sTag ~= "" then
      Util.LoadStaticENTag(sTag, bForceLoad)
    end
  end
  
  function __UtilFunctions.UnloadStaticTag(sTag, bForceUnload)
    if sTag and sTag ~= "" then
      Util.UnloadStaticENTag(sTag, bForceUnload)
    end
  end
  
  function __UtilFunctions.CallWithOptionalArgs(fFunction, tArgs)
    if type(fFunction) == "function" then
      if type(tArgs) == "table" then
        return fFunction(unpack(tArgs))
      else
        return fFunction()
      end
    end
  end
  
  function __UtilFunctions.CopyTable(tSrc)
    local tDest = {}
    if not type(tSrc) == "table" or not tSrc then
      print("Warning: Did not pass a table to CopyTable")
      return nil
    end
    for k, v in pairs(tSrc) do
      if type(v) == "table" then
        tDest[k] = __UtilFunctions.CopyTable(v)
      else
        tDest[k] = v
      end
    end
    return tDest
  end
  
  function __UtilFunctions.SetDefault(vVar, vDefaultValue)
    if vVar == nil then
      vVar = vDefaultValue
    end
    return vVar
  end
  
  function __UtilFunctions.GetTableFromNameSpace(sTableName)
    return _G[sTableName]
  end
  
  function __UtilFunctions:CallbackFadeInOutHelper(a_nSeconds)
    Render.FadeTo(0, 0, 0, 0, a_nSeconds)
  end
  
  function __UtilFunctions.SetAmbient(bOn)
    if not bAmbientLock then
      local tSabSelf = Actor.GetSelf(hSab)
      tSabSelf.tStatistics.bAmbientOn = bOn
    end
  end
  
  function __UtilFunctions.SetAmbientLock(bOn)
    bAmbientLock = bOn
  end
  
  function __UtilFunctions.SetVar(vVar, vValue)
    vVar = vValue
  end
  
  function Common.SetVar(vVar, vValue)
    vVar = vValue
  end
  
  function Common.ClearVar(vVar)
  end
  
  function __UtilFunctions.SetTurret(hHandle, bOn)
    local hHandle = WRAPPER_CheckForHandle(hHandle)
    local tSelf = Actor.GetSelf(hHandle)
    tSelf.bIsTurret = bOn
  end
  
  function Common.SetTurret(hHandle, bOn)
    local hHandle = WRAPPER_CheckForHandle(hHandle)
    local tSelf = Actor.GetSelf(hHandle)
    tSelf.bIsTurret = bOn
  end
  
  function DisplayHUDText(sText, nTime, nPosX, nPosY, scale, r, g, b, a)
    Render.PrintMessage(sText)
  end
  
  function __UtilFunctions.AddLoadNode(tTable, sNodePath, STATE)
    if sNodePath and sNodePath ~= "" then
      table.insert(tTable, {sNode = sNodePath, state = STATE})
    end
  end
  
  function Common.RemoveTableItem(tTable, sThing)
    if tTable then
      for i, v in pairs(tTable) do
        if tTable[i] == sThing then
          table.remove(tTable, i)
        end
      end
    end
  end
  
  function Common.InsertTableItem(tTable, sThing, bCheckIfExists)
    local bCheck = false
    if bCheckIfExists then
      bCheck = Common.IsAlreadyInTable(tTable, sThing)
    end
    if tTable and sThing and sThing ~= "" and not bCheck then
      table.insert(tTable, sThing)
    end
  end
  
  function Common.IsAlreadyInTable(tTable, sThing)
    local bIn = false
    if tTable then
      for i, v in pairs(tTable) do
        if tTable[i] == sThing then
          bIn = true
          break
        end
      end
    end
    return bIn
  end
  
  function __UtilFunctions.RemoveLoadNode(tTable, sNodePath)
    for i, v in pairs(tTable) do
      if string.upper(tTable[i].sNode) == string.upper(sNodePath) then
        table.remove(tTable, i)
      end
    end
  end
  
  function Common.IsNodeLoaded(tTable, sNodePath)
    if tTable == nil then
      Util.Assert(tTable, "CFRENCH: Common.IsNodeLoaded was passed a nil (uninitialized) table")
      print("CFRENCH: Common.IsNodeLoaded was passed a nil table")
      return false
    end
    for i, v in pairs(tTable) do
      if string.upper(tTable[i].sNode) == string.upper(sNodePath) then
        if tTable[i].state ~= nil and tTable[i].state == cSM_LOADED then
          return true
        end
        if not tTable[i].state then
          return true
        end
      end
    end
    return false
  end
  
  function Common.IsNotEmptyTable(tTable)
    if tTable and tTable ~= {""} and tTable ~= {} and #tTable ~= 0 then
      return true
    else
      return false
    end
  end
  
  function Common.VehicleRunDrop(Stop, bAggro, hVehicle)
    local hStop
    if Stop then
      hStop = Util.GetHandleByName(Stop)
    end
    if hStop and hVehicle and Object.GetHealth(hVehicle) > 0 then
      Nav.MoveToObject(hVehicle, hStop, 2, true, "Common.PreCallbackDumpNazis", nil, {hVehicle, bAggro})
    else
      print("ERROR: in Common.VehicleRunDropAgro ")
    end
  end
  
  function Common:PreCallbackDumpNazis(hVehicle, bAggro)
    EVENT_Timer("Common.CallbackDumpNazis", self, 3, {hVehicle, bAggro})
  end
  
  function Common:CallbackDumpNazis(hVehicle, bAggro)
    if hVehicle then
      if bAggro then
        VEHICLE_UnboardAllPassengers(hVehicle, "Common.CallbackAgroNazis")
      else
        VEHICLE_UnboardAllPassengers(hVehicle)
      end
    else
      print("ERROR: in Common.CallbackDumpNazis ")
    end
  end
  
  function Common:CallbackAgroNazis(tNazi)
    if tNazi[1] and Object.IsAlive(tNazi[1]) then
      Combat.SetTarget(tNazi[1], hSab)
      Combat.SetCombat(tNazi[1])
    end
  end
  
  function GodMode()
    PlayerInvincible = not PlayerInvincible
    Object.SetInvincible(Util.GetHandleByName("Saboteur"), PlayerInvincible)
  end
  
  function GetAPByName(sMissionName)
    local oMission
    if not sMissionName then
      Util.Assert(false, "you failed me for the last time")
      return
    end
    local sap
    if not string.find(sMissionName, "_ActionPackage") then
      sap = sMissionName .. "_ActionPackage"
    else
      sap = sMissionName
    end
    local oAPs = oGameMaster:GetChildren()
    for k, v in pairs(oAPs) do
      if v:GetName() == sap then
        oMission = v
      end
    end
    return oMission
  end
  
  function GetMissionByName(sMissionName)
    local oMission = GetAPByName(sMissionName)
    local oGameplay
    if oMission then
      oGameplay = SabTask.GetGameplayTask(oMission)
    end
    return oGameplay
  end
  
  function GetActiveMissionByName(sMissionName)
    local oMission = GetAPByName(sMissionName)
    local oGameplay
    if oMission then
      oGameplay = SabTask.GetGameplayTask(oMission)
    end
    if oGameplay and oGameplay:IsActive() then
      return oGameplay
    else
      return false
    end
  end
  
  function IsMissionCompleted(sMission, ConversationID)
    local bCompleted = SabTask:IsCompletedMission(sMission)
    if ConversationID then
      Cin.ConversationConditionPassed(ConversationID, bCompleted)
    end
    return bCompleted
  end
  
  function IsMissionOpen(sMission)
    if not sMission then
      return false
    end
    if (SabTask:IsInOpenList(sMission) or SabTask:IsInPotentialList(sMission)) and not SabTask:IsInActiveMissionList(sMission) then
      return true
    end
    return false
  end
  
  function IsMissionActive(sMission)
    if not sMission then
      return false
    end
    if SabTask:IsInActiveMissionList(sMission) then
      return true
    end
    return false
  end
  
  function AddSabFollower(self, hObj)
    local tSabSelf = Actor.GetSelf(hSab)
    local bFound = false
    if hObj and tSabSelf.tFollowerList then
      if self and not self:GetConfig().bBlipLocatorsOnly then
        self:SetUIBlips(hObj, true, false)
      end
      if not Object.IsInvincibleToAI(hObj) then
      end
      Actor.SetAutoSeatTransition(hObj, false)
      for i, hExistingFollower in pairs(tSabSelf.tFollowerList) do
        if hObj == hExistingFollower then
          bFound = true
        end
      end
      if not bFound then
        table.insert(tSabSelf.tFollowerList, hObj)
      end
    end
  end
  
  function RemoveSabFollower(self, hObj)
    local tSabSelf = Actor.GetSelf(hSab)
    if hObj and tSabSelf.tFollowerList then
      for i, v in pairs(tSabSelf.tFollowerList) do
        if tSabSelf.tFollowerList[i] == hObj then
          if __UtilFunctions._FollowerInvinEnabled[hObj] then
            __UtilFunctions._FollowerInvinEnabled[hObj] = nil
            Object.SetInvincibleToAI(hObj, false)
          end
          table.remove(tSabSelf.tFollowerList, i)
          if self then
            SabTaskObjective.SetUIBlips(self, hObj, false)
          end
          break
        end
      end
    end
  end
  
  function IsEscalationFree()
    if Suspicion.GetEscalation() == 0 then
      return true
    else
      return false
    end
  end
  
  function CompareTables(tTable1, tTable2)
    if tTable1 and tTable2 then
      if #tTable1 == 0 and #tTable2 == 0 then
        return true
      elseif #tTable1 ~= #tTable2 then
        return false
      else
        for i, thing in pairs(tTable1) do
          if tTable1[i] ~= tTable2[i] then
            return false
          end
        end
        print("CompareTables are the same ", tTable1, tTable2)
        return true
      end
    else
      return false
    end
  end
  
  function StringToFileFunction(sString)
    if not sString or type(sString) ~= "string" then
      Util.Assert(false, "StringToFileFunction( sString ), sString is either nil, or not a string")
      return
    end
    local dotIndex = string.find(sString, "%.")
    local sFile, sFunction, fFile, fFunction
    if dotIndex then
      sFile = string.sub(sString, 1, dotIndex - 1)
      sFunction = string.sub(sString, dotIndex + 1, string.len(sString))
      fFile = _G[sFile]
      fFunction = fFile[sFunction]
    else
      fFunction = _G[sString]
    end
    return fFunction
  end
  
  function OnConversationDisables()
    DisablePlayersAttack(true)
    DisablePlayersMovement(true)
    SetDisableControl("EnterExitVehicle", true)
    SetDisableControl("FocusPressed", true)
    SetDisableControl("InventoryChange", true)
  end
  
  function OffConversationDisables()
    DisablePlayersAttack(false)
    DisablePlayersMovement(false)
    SetDisableControl("EnterExitVehicle", false)
    SetDisableControl("FocusPressed", false)
    SetDisableControl("InventoryChange", false)
  end
  
  function OnDisables()
    DisablePlayersAttack(true)
    DisablePlayersMovement(true)
    SetDisableControl("EnterExitVehicle", true)
    SetDisableControl("FocusPressed", true)
    SetDisableControl("InventoryChange", true)
    SetDisableControl("Walking", true)
  end
  
  function OffDisables()
    DisablePlayersAttack(false)
    DisablePlayersMovement(false)
    SetDisableControl("EnterExitVehicle", false)
    SetDisableControl("FocusPressed", false)
    SetDisableControl("InventoryChange", false)
    SetDisableControl("Walking", false)
  end
  
  function OnWalkingConversationDisables()
    DisablePlayersAttack(true)
    SetDisableControl("EnterExitVehicle", true)
    SetDisableControl("Jump", true)
    SetDisableControl("Sprint", true)
    SetDisableControl("Running", true)
    SetDisableControl("InventoryChange", true)
    SetDisableControl("FocusPressed", true)
  end
  
  function OffWalkingConversationDisables()
    DisablePlayersAttack(false)
    SetDisableControl("EnterExitVehicle", false)
    SetDisableControl("Jump", false)
    SetDisableControl("Sprint", false)
    SetDisableControl("Running", false)
    SetDisableControl("InventoryChange", false)
    SetDisableControl("FocusPressed", false)
  end
  
  function OnStaticConversationDisables()
    DisablePlayersAttack(true)
    DisablePlayersMovement(true)
    SetDisableControl("Walking", true)
    SetDisableControl("EnterExitVehicle", true)
    SetDisableControl("FocusPressed", true)
    SetDisableControl("InventoryChange", true)
  end
  
  function OffStaticConversationDisables()
    DisablePlayersAttack(false)
    DisablePlayersMovement(false)
    SetDisableControl("Walking", false)
    SetDisableControl("EnterExitVehicle", false)
    SetDisableControl("FocusPressed", false)
    SetDisableControl("InventoryChange", false)
  end
  
  function OnConversationDisables_HQDefault()
  end
  
  function OffConversationDisables_HQDefault()
  end
  
  function DisablePlayersAttack(bDisable)
    SetDisableControl("Fire", bDisable)
    SetDisableControl("Fire2", bDisable)
    SetDisableControl("Grenade", bDisable)
    SetDisableControl("WeakAttack", bDisable)
    SetDisableControl("GrabAttack", bDisable)
    SetDisableControl("Sabotage", bDisable)
  end
  
  function DisablePlayersMovement(bDisable)
    SetDisableControl("Jump", bDisable)
    SetDisableControl("Action", bDisable)
    SetDisableControl("Sprint", bDisable)
    SetDisableControl("Sneak", bDisable)
    SetDisableControl("Running", bDisable)
  end
  
  function DisableHQAbilities(bDisable)
    Actor.HolsterWeaponImmediate(hSab)
    DisablePlayersAttack(bDisable)
    SetDisableControl("Jump", bDisable)
    SetDisableControl("Sprint", bDisable)
    SetDisableControl("Sneak", bDisable)
    SetDisableControl("Zoom", bDisable)
    SetDisableControl("StealthKill", bDisable)
  end
  
  function DisableBelleHQAbilities(bDisable)
    Actor.HolsterWeaponImmediate(hSab)
    DisablePlayersAttack(bDisable)
    SetDisableControl("Jump", bDisable)
    SetDisableControl("Sprint", bDisable)
    SetDisableControl("Sneak", bDisable)
    SetDisableControl("WeaponButton", bDisable)
    SetDisableControl("Zoom", bDisable)
    SetDisableControl("InventoryChange", bDisable)
    SetDisableControl("StealthKill", bDisable)
  end
  
  function SetDisableControl(sType, bDisable)
    if not sType then
      return
    end
    if _tDisabledControls[sType] then
      if bDisable then
        _tDisabledControls[sType] = _tDisabledControls[sType] + 1
      else
        _tDisabledControls[sType] = _tDisabledControls[sType] - 1
      end
      if _tDisabledControls[sType] > 0 then
        Util.SetDisableControls(sType, true)
      else
        _tDisabledControls[sType] = 0
        Util.SetDisableControls(sType, false)
      end
    end
  end
  
  function ClearDisableControl(sType)
    if not sType then
      return
    end
    if _tDisabledControls[sType] then
      _tDisabledControls[sType] = 0
      Util.SetDisableControls(sType, false)
    end
  end
  
  function ClearAllDisableControls()
    for sType, v in pairs(_tDisabledControls) do
      ClearDisableControl(sType)
    end
  end
  
  function Debug_CinAwesome()
    Util.EnableSuperSpores(false)
    Vehicle.EnableTraffic(false, true)
    Suspicion.EnableGlobal(false)
    Util.EnableGooseSteppers(false)
  end
  
  function Debug_CinAwesome_Off()
    Util.EnableSuperSpores(true)
    Vehicle.EnableTraffic(true)
    Suspicion.EnableGlobal(true)
    Util.EnableGooseSteppers(true)
  end
  
  function Common.StopVehicle(vVehicle, bControl)
    if bControl then
      Common.DisableVehControls(true)
    end
    local hVehicle = WRAPPER_CheckForHandle(vVehicle)
    if not hVehicle and not hVehicle then
      print("ERROR:Common.StopVehicle vVehicle is nil")
    end
    if hVehicle then
      Vehicle.BrakeTo(hVehicle, 0)
      Vehicle.OverrideBraking(hVehicle, true, 3.5)
    end
  end
  
  function Common.ReleaseVehicle(vVehicle)
    Common.DisableVehControls(false)
    local hVehicle = WRAPPER_CheckForHandle(vVehicle)
    if not hVehicle and not hVehicle then
      print("ERROR:Common.StopVehicle vVehicle is nil")
    end
    if hVehicle then
      Vehicle.BrakeTo(hVehicle, 200)
      Vehicle.OverrideBraking(hVehicle, false, 1)
    end
  end
  
  function Common.DisableVehControls(bDisable)
    SetDisableControl("EnterExitVehicle", bDisable)
    SetDisableControl("Break", bDisable)
    SetDisableControl("Gas", bDisable)
    SetDisableControl("HandBreak", bDisable)
  end
  
  function ConvManager.Create(o)
    self = {}
    setmetatable(self, {__index = o})
    local returnself = self
    table.insert(ConvManager.tConvManagers, self)
    self = nil
    return returnself
  end
  
  function ConvManager.CreateNewManager()
    local oConvManager = ConvManager:Create()
    oConvManager.Conversations = {}
    oConvManager.Queue = {}
    return oConvManager
  end
  
  function ConvManager:AddConv(tConfig)
    if self.Conversations[tConfig.sConvName] then
      Util.Assert("ConvManager:AddConv conv already exists ", tConfig.sConvName)
    else
      self.Conversations[tConfig.sConvName] = {}
    end
    self.Conversations[tConfig.sConvName].tConfig = {}
    for key, value in pairs(tConfig) do
      self.Conversations[tConfig.sConvName].tConfig[key] = value
    end
  end
  
  function ConvManager:RemoveConv(sConvName)
    if self.Conversations[sConvName] then
      self.Conversations[sConvName] = nil
    end
  end
  
  function ConvManager:PlayConv(sConvName)
    self:_PlayConversationQueue(sConvName)
  end
  
  function ConvManager:StopConv(sConvName, bReval)
    Cin.StopConversation(sConvName)
    print("Stopping Conversation: ", sConvName)
    self.SetConvDone(nil, {}, self, sConvName, bReval)
  end
  
  function ConvManager:_PlayConversationQueue(sConvName)
    table.insert(self.Queue, sConvName)
    self:_EvaluateQueue()
  end
  
  function ConvManager:_RemoveFromQueue(sConvName)
    local i = 1
    while i <= #self.Queue do
      if self.Queue[i] and self.Queue[i] == sConvName then
        table.remove(self.Queue, i)
      else
        i = i + 1
      end
    end
  end
  
  function ConvManager:_CleanQueue()
    self.Queue = {}
  end
  
  function ConvManager:_EvaluateQueue()
    local sBestConv = ConvManager.GetBestConversationToPlay(self)
    if sBestConv then
      print("playing best conv ", sBestConv)
      self.Conversations[sBestConv].tConfig.bPlaying = true
      ConvManager._RemoveFromQueue(self, sBestConv)
      if self.Conversations[sBestConv].tConfig.bBrute then
        ConvManager._CleanQueue(self)
      end
      Cin.PlayConversation(sBestConv, "ConvManager.SetConvDone", nil, {
        self,
        sBestConv,
        true
      })
    end
  end
  
  function ConvManager:GetBestConversationToPlay()
    local sBestConv
    local BestPriority = 0
    local EscalationLevel = Suspicion.GetEscalation()
    local ThisPriority
    local bSetContinue = false
    for i, sConvName in pairs(self.Queue) do
      print("testing conv ", sConvName)
      bSetContinue = false
      local tConfig = self.Conversations[sConvName].tConfig
      if not tConfig then
        Util.Assert("No tConfig for conv ", sConvName)
        bSetContinue = true
      elseif self:GetConvPlaying() and not tConfig.bBrute and not tConfig.bPlayOverOther then
        print("Conv already playing and this one doesn't override")
        bSetContinue = true
      end
      if not bSetContinue then
        ThisPriority = tConfig.Priority or 1
        if not sBestConv then
          sBestConv = sConvName
          BestPriority = ThisPriority
        end
        local tConfig = self.Conversations[sConvName].tConfig
        if tConfig.bBrute then
          sBestConv = sConvName
          if self:GetConvPlaying() then
            self:StopConv(self:GetConvPlaying(), false)
          end
          break
        end
        if BestPriority < tConfig.Priority then
          sBestConv = sConvName
          BestPriority = ThisPriority
        end
      end
    end
    return sBestConv
  end
  
  function ConvManager:GetConvPlaying()
    for sConvName, tConfig in pairs(self.Conversations) do
      if tConfig.bPlaying then
        print("GetConvPlaying ", sConvName)
        return sConvName
      end
    end
    return nil
  end
  
  function ConvManager:GetConvSelf(sConvName)
    for sConvName, tConfig in pairs(self.Conversations) do
      if tConfig.bPlaying then
        print("GetConvPlaying ", sConvName)
        return sConvName
      end
    end
    return nil
  end
  
  function ConvManager.SetConvDone(nilself, tArgs, myself, sConvName, bReval)
    local self = myself
    print("Conv Finished ", sConvName)
    if sConvName and self.Conversations[sConvName] then
      self.Conversations[sConvName].bPlaying = false
      self.Conversations[sConvName].bPlayed = true
      if not self.Conversations[sConvName].bRepeatable then
        self.Conversations[sConvName].bLocked = true
      end
    end
    if bReval then
      ConvManager._EvaluateQueue(self)
    end
  end
  
  function ConvManager:ResetAllConv(sConvName)
    for sConvName, tConfig in pairs(self.Conversations) do
      self:ResetConv(sConvName)
    end
  end
  
  function ConvManager:ResetConv(sConvName)
    print("ResetConv ", sConvName)
    if sConvName and self.Conversations[sConvName] then
      self.Conversations[sConvName].bPlaying = false
      self.Conversations[sConvName].bPlayed = false
      self.Conversations[sConvName].bLocked = false
    end
  end
  
  function ConvManager:Delete()
    if not self then
      return
    end
    if self._eOnEvent then
      Util.KillEvent(self._eOnEvent)
    end
    if self._eOffEvent then
      Util.KillEvent(self._eOffEvent)
    end
    if self._eSpawnerEvent then
      Util.KillEvent(self._eSpawnerEvent)
    end
    if self.tConfig then
      for i, v in pairs(self.tConfig) do
        self.tConfig[i] = nil
      end
    end
    if self.Conversations then
      self.Conversations = nil
    end
  end
  
  function DisableMissionFail(bDisable)
    if bDisable then
      __g_DisableMissionFail = true
    else
      __g_DisableMissionFail = nil
    end
  end
end
