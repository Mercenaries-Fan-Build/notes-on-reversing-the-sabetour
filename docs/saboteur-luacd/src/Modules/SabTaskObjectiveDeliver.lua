if SabTaskObjectiveDeliver == nil then
  SabTaskObjectiveDeliver = SabTaskObjective:Create()
  _cTAXIFETCHCAR = 1
  _cTAXIFETCHPICK = 2
  _cTAXIDROPOFF = 3
  _cTAXIWAITFORLOAD = 4
  _cTAXIFAIL = 5
  _cTAXISETUP = 6
  _cTAXIFETCHDROP = 7
  _cTAXIFINISH = 8
  _cTAXISTOPPICK = 9
  _cTAXISTOPDROP = 10
  _cABANDONED = 11
  _cLOSE_ESCALATION = 12
  _cTAXIPICKUP = 13
  _cPASS_WAITING = 1
  _cPASS_LOADING = 2
  _cPASS_LOADED = 3
  _cPASS_UNLOADED = 4
  _cPASS_ABANDONED = 5
  _cPASS_DELIVERED = 6
end

function SabTaskObjectiveDeliver:Activated()
  SabTaskObjective.Activated(self)
  local tConfig = self:GetConfig()
  self._tDeliverEvents = {}
  self._tSuperTaxiPassengers = {}
  self._tPassengersBoarded = {}
  self.__TotalPassengersLoaded = 0
  if tConfig.bFadeOutOnDropOff then
    self:SetQuota(self:GetQuota() + 1)
  end
  if tConfig.sToolTipID then
    self:ShowToolTip(tConfig.sToolTipID)
  end
  if tConfig.sCinFile and not tConfig.bFireForgetCin then
    self:SetQuota(self:GetQuota() + 1)
  end
  if tConfig.tDestRegion then
    self:SetupTriggerRegionDeliver()
  end
  if tConfig.tDestProximityObj then
    self:SetupProximityDeliver()
  end
  if tConfig.sTaskSubType then
    if string.upper(tConfig.sTaskSubType) == "ESCORT" then
      self:StartEscort()
    elseif string.upper(tConfig.sTaskSubType) == "FETCH" then
      self:StartFetch()
    elseif string.upper(tConfig.sTaskSubType) == "INFILTRATION" then
    elseif string.upper(tConfig.sTaskSubType) == "ESCAPE" then
    elseif string.upper(tConfig.sTaskSubType) == "RESCUE" then
    elseif string.upper(tConfig.sTaskSubType) == "FOLLOW" then
      self:StartFollow()
    elseif string.upper(tConfig.sTaskSubType) == "DELIVER" then
      self:StartDeliver()
    elseif string.upper(tConfig.sTaskSubType) == "TAXI" then
      self._bPlayEndConv = false
      self._bTaxiStateActive = true
      self._bRanOnPickupCallbacks = false
      self._TotalNumPassengers = 0
      self._AbandonFailDistance = 100
      self._tAbandonEvents = {}
      self._bTaxiUpdate = false
      self._bTaxiInEscalationState = false
      self.__eTAXIFETCH = nil
      self.__eTaxiEvents = {}
      self.__eTaxiEvents.OnExitVeh = {}
      self.__eTaxiEvents.OnEnterVeh = {}
      self.__tPassengersLoaded = {}
      self._bRePickupPassengers = false
      self:TaxiEnterState(_cTAXISETUP)
    elseif string.upper(tConfig.sTaskSubType) == "TAXIPICKUP" then
    elseif string.upper(tConfig.sTaskSubType) == "TAXIDELIVER" then
      self:StartTaxiDeliver()
    elseif string.upper(tConfig.sTaskSubType) == "TAXIWAIT" then
      self:StartTaxiWait()
    elseif string.upper(tConfig.sTaskSubType) == "EXITINTERIOR" then
      self:StartEnterExitInterior(true)
    elseif string.upper(tConfig.sTaskSubType) == "ENTERINTERIOR" then
      self:StartEnterExitInterior()
    end
  else
    print("WARNING:: ", self:GetName(), " does not have a sTaskSubType")
  end
end

function SabTaskObjectiveDeliver:StartEscort()
  local tConfig = self:GetConfig()
  for _, Object in pairs(tConfig.tDeliverObjs) do
    local Proximity = tConfig.Proximity or 2
    local hObj = WRAPPER_CheckForHandle(Object)
    self:SetFollowerType(hObj, Proximity)
    EVENT_ActorDeath("SabTaskObjectiveDeliver.OnEscortDeath", self, hObj)
  end
end

function SabTaskObjectiveDeliver:StartFollow()
  local tConfig = self:GetConfig()
  self.hLeader = nil
  local NewSquadID = tConfig.sName
  local SquadRadius = 4
  self.FollowSquadID = NewSquadID
  if tConfig.sLeader then
    self.hLeader = WRAPPER_CheckForHandle(tConfig.sLeader)
  end
  Squad.Create(NewSquadID)
  if not self.hLeader then
    local warning = "Error:: sLeader did not return a valid handle for " .. tConfig.sLeader .. " in " .. self:GetName()
    Util.Assert(false, warning)
    return
  end
  Squad.AddMember(NewSquadID, self.hLeader)
  for _, Object in pairs(tConfig.tDeliverObjs) do
    local hObj = WRAPPER_CheckForHandle(Object)
    if hObj ~= self.hLeader then
      Squad.AddMember(NewSquadID, hObj)
      SquadRadius = SquadRadius + 1
    end
  end
  Squad.SetLeader(NewSquadID, self.hLeader)
  SquadRadius = tConfig.SquadRadius or SquadRadius
  Squad.SetRadius(NewSquadID, SquadRadius)
  if tConfig.sFollowPath then
    Squad.SetLeaderPath(NewSquadID, tConfig.sFollowPath)
  end
  Squad.FollowLeader(NewSquadID)
  if tConfig.bSetEnemyNazi then
    Squad.SetEnemy(NewSquadID, "GenericNazi")
  end
end

function SabTaskObjectiveDeliver:StartDeliver()
  local tConfig = self:GetConfig()
  local hPlayerVehicle = Actor.GetVehicle(hSab)
  local bPlayerInDeliveryVeh = false
  if tConfig.tDeliverObjs then
    for _, DeliverObject in pairs(tConfig.tDeliverObjs) do
      local hObject = WRAPPER_CheckForHandle(DeliverObject)
      if hPlayerVehicle == hObject then
        bPlayerInDeliveryVeh = true
      end
      if Object.IsVehicle(hObject) then
        self.bVehicleDeliverTask = true
      end
    end
  else
  end
  if self.bVehicleDeliverTask then
    self:CheckInDeliveryVehicle(bPlayerInDeliveryVeh, hPlayerVehicle)
  end
end

function SabTaskObjectiveDeliver:StartTaxi()
  local tConfig = self:GetConfig()
  for _, Object in pairs(tConfig.tDeliverObjs) do
    local hObj = WRAPPER_CheckForHandle(Object)
    if Object.IsVehicle(hObj) or hObj == hSab then
      return
    end
    self:SetFollowerType(hObj, 2)
    Actor.SetVehicleAvoidance(hObj, false)
    if tConfig.sTaskSubType and string.upper(tConfig.sTaskSubType) == "TAXIPICKUP" then
      EVENT_ActorEntersAnyVehicle("SabTaskObjectiveDeliver.PassengerEnteredTaxiPickup", self, hObj, hObj)
    elseif tConfig.sTaskSubType and string.upper(tConfig.sTaskSubType) == "TAXIDELIVER" then
      EVENT_ActorExitsAnyVehicle("SabTaskObjectiveDeliver.PassengerExitedTaxi", self, hObj, hObj)
    elseif tConfig.sTaskSubType and string.upper(tConfig.sTaskSubType) == "TAXIWAIT" then
    else
      print("++++++++++++++++++++++++++++++++++++++++++")
      EVENT_ActorEntersAnyVehicle("SabTaskObjectiveDeliver.PassengerEnteredTaxi", self, hObj, hObj)
    end
    EVENT_ActorDeath("SabTaskObjectiveDeliver.OnEscortDeath", self, hObj)
  end
end

function SabTaskObjectiveDeliver:StartTaxiDeliver()
  local tConfig = self:GetConfig()
  self:StartTaxi()
  if tConfig.tDeliverObjs then
    for i, DeliverMe in pairs(tConfig.tDeliverObjs) do
      local hDM = WRAPPER_CheckForHandle(DeliverMe)
      if hDM and Actor.IsInVehicle(hDM, true) then
        self:SetUIBlips(hDM, false, true)
      end
    end
  end
end

function SabTaskObjectiveDeliver:CallbackPlayerNotInVehicle()
end

function SabTaskObjectiveDeliver:StartTaxiWait()
  local hTrigRegion = self:GetTriggerRegionHandle()
  local hTriggerID = Trigger.WaitFor(hTrigRegion, hSab, "SabTaskObjectiveDeliver.CallbackPlayerExitedWaitRegion", self, {OnTriggerTable}, cTRIGGEREVENT_ONEXIT, true)
  self:RegisterTriggerEvent(hTriggerID, hTrigRegion)
  if Actor.GetVehicle(hSab) then
    EVENT_PlayerExitsAnyVehicle("SabTaskObjectiveDeliver.CallbackPlayerNotInVehicle", self, {}, true)
  else
    self:CallbackPlayerNotInVehicle()
  end
end

function SabTaskObjectiveDeliver:PassengerEnteredTaxiPickup(tArgs, hPassenger)
  if hPassenger then
    self:SetUIBlips(hPassenger, false, true)
    EVENT_Timer("SabTaskObjectiveDeliver.CallbackPickedUpSuccess", self, 0.3, hPassenger)
  end
end

function SabTaskObjectiveDeliver:PassengerEnteredTaxi(tArgs, hPassenger)
  if hPassenger then
    if not self.__tPassengersLoaded[hPassenger] then
      self.__TotalPassengersLoaded = self.__TotalPassengersLoaded + 1
      self.__tPassengersLoaded[hPassenger] = true
    end
    print("PassengerEnteredTaxi total loaded = ", self.__TotalPassengersLoaded)
    self:SetUIBlips(hPassenger, false, true)
    self:SetupOnExitTaxi(hPassenger)
  end
end

function SabTaskObjectiveDeliver:PassengerExitedTaxi(tArgs, hPassenger)
  local tConfig = self:GetConfig()
  if hPassenger then
    if self.__eTaxiEvents.OnExitVeh[hPassenger] then
      print("PassengerExitedTaxi nil self.__eTaxiEvents.OnExitVeh[ hPassenger ], ", hPassenger)
      self.__eTaxiEvents.OnExitVeh[hPassenger] = nil
    end
    self._tSuperTaxiPassengers[hPassenger] = _cPASS_UNLOADED
    if self.__tPassengersLoaded[hPassenger] then
      self.__TotalPassengersLoaded = self.__TotalPassengersLoaded - 1
      self.__tPassengersLoaded[hPassenger] = nil
    end
    print("PassengerExitedTaxi total loaded = ", self.__TotalPassengersLoaded)
    self:SetupOnEnterTaxi(hPassenger)
    if not tConfig.bBlipLocatorsOnly then
      self:SetUIBlips(hPassenger, true, true)
    end
  end
end

function SabTaskObjectiveDeliver:SetupOnEnterTaxi(hPassenger)
  if hPassenger and self:IsActive() then
    print("setting up enter vehicle ", hPassenger, "STATE ", self.TaxiDeliverState)
    EVENT_ActorEntersAnyVehicle("SabTaskObjectiveDeliver.PassengerEnteredTaxi", self, hPassenger, hPassenger)
  end
end

function SabTaskObjectiveDeliver:SetupOnExitTaxi(hPassenger)
  if hPassenger and self:IsActive() then
    print("SetupOnExitTaxi ", hPassenger, "STATE ", self.TaxiDeliverState)
    if self.__eTaxiEvents.OnExitVeh[hPassenger] then
      print("SetupOnExitTaxi clearing self.__eTaxiEvents.OnExitVeh[ hPassenger ], ", hPassenger)
      Util.KillEvent(self.__eTaxiEvents.OnExitVeh[hPassenger])
    end
    self.__eTaxiEvents.OnExitVeh[hPassenger] = EVENT_ActorExitsAnyVehicle("SabTaskObjectiveDeliver.PassengerExitedTaxi", self, hPassenger, hPassenger)
  end
end

function SabTaskObjectiveDeliver:StartInfiltration()
  local tConfig = self:GetConfig()
end

function SabTaskObjectiveDeliver:StartEscape()
  local tConfig = self:GetConfig()
end

function SabTaskObjectiveDeliver:StartRescue()
  local tConfig = self:GetConfig()
end

function SabTaskObjectiveDeliver:StartFetch()
  local tConfig = self:GetConfig()
  self.TotalFetchVehicles = 0
  self.TotalVehiclesDestroyed = 0
  if self.tInfo then
    self.tInfo.tWantThisObject = {}
  else
    self.tInfo = {}
    self.tInfo.tWantThisObject = {}
  end
  if tConfig.bAnyVehicle then
    EVENT_PlayerEntersAnyVehicle("SabTaskObjectiveDeliver.CallbackPlayerEnteredAnyVehicle", self)
  end
  if tConfig.tDeliverObjs then
    for i, FetchObject in pairs(tConfig.tDeliverObjs) do
      local hObject
      if not tConfig.bBlueprintFetch then
        hObject = Util.GetHandleByName(FetchObject)
      end
      if hObject and Object.IsVehicle(hObject) then
        local eEvent = EVENT_PlayerEntersVehicle("SabTaskObjectiveDeliver.CallbackPlayerEnteredVehicle", self, hObject, hObject)
        table.insert(self._tDeliverEvents, eEvent)
        self.TotalFetchVehicles = self.TotalFetchVehicles + 1
        if tConfig.tOnVehicleDeath then
          EVENT_ActorDeath("SabTaskObjectiveDeliver.OnFetchVehicleDeath", self, hObject)
        end
      elseif tConfig.bBlueprintFetch then
        if not self.tInfo.bCreateFetchListener then
          self:RegisterEvent(Util.CreateEvent({
            EventType = "OnItemPickup",
            Target = hSab
          }, "SabTaskObjectiveDeliver.OnItemPickup", self, {FetchObject}, true))
          self.tInfo.bCreateFetchListener = true
        end
      elseif hObject and not Object.IsVehicle(hObject) then
        self.tInfo.tWantThisObject[i] = hObject
        if not self.tInfo.bCreateFetchListener then
          self:RegisterEvent(Util.CreateEvent({
            EventType = "OnItemPickup",
            Target = hSab
          }, "SabTaskObjectiveDeliver.OnItemPickup", self, {nil}, true))
          self.tInfo.bCreateFetchListener = true
        end
      end
    end
  end
end

function SabTaskObjectiveDeliver:OnItemPickup(tCallbackArgs, WantThisObject)
  local tConfig = self:GetConfig()
  local bIsBlueprint = false
  if tConfig.bBlueprintFetch then
    bIsBlueprint = true
  end
  local GotThisObjectBlueprint = tCallbackArgs[2]
  local GotThisObjectHandle = tCallbackArgs[3]
  if tConfig.bOnAnyPickup then
    SabTaskObjective.SubObjectiveCompleted(self)
    return
  end
  if GotThisObjectBlueprint then
    if bIsBlueprint then
      if GotThisObjectBlueprint == Util.GetCRC(WantThisObject) then
        SabTaskObjective.SubObjectiveCompleted(self)
      end
    else
      for i, WantThis in pairs(self.tInfo.tWantThisObject) do
        if GotThisObjectHandle == WantThis then
          self:SetUIBlips(GotThisObjectHandle, false)
          self.tInfo.tWantThisObject[i] = nil
          SabTaskObjective.SubObjectiveCompleted(self)
        end
      end
    end
  else
    print("Didn't get enough data to test pickup item")
  end
end

function SabTaskObjectiveDeliver:CallbackPlayerExitedWaitRegion()
  local hTrigRegion = self:GetTriggerRegionHandle()
  local hTriggerID = Trigger.WaitFor(hTrigRegion, hSab, "SabTaskObjectiveDeliver.CallbackPlayerReEnteredWaitRegion", self, {OnTriggerTable}, cTRIGGEREVENT_ONENTER_SMART, false)
  self:RegisterTriggerEvent(hTriggerID, hTrigRegion)
end

function SabTaskObjectiveDeliver:OnFetchVehicleDeath(hObject)
  local tConfig = self:GetConfig()
  local tCallbacks = tConfig.tOnVehicleDeath
  self.TotalVehiclesDestroyed = self.TotalVehiclesDestroyed + 1
  if type(tCallbacks) == "table" then
    for _, tCallback in ipairs(tCallbacks) do
      __UtilFunctions.CallWithOptionalArgs(tCallback[1], tCallback[2])
    end
  end
  if tConfig.bFailMissionOnFail then
    local parent = self:GetParent()
    parent:Cancel()
  end
  if tConfig.bKillTaskOnFail and self.TotalVehiclesDestroyed >= self.TotalFetchVehicles then
    self.TotalFetchVehicles = nil
    self.TotalVehiclesDestroyed = nil
    self:KillTaskByName(self:GetName())
  end
end

function SabTaskObjectiveDeliver:CheckInDeliveryVehicle(bPlayerInDeliveryVeh, hPlayerVehicle)
  local tConfig = self:GetConfig()
  local bBlipDestinations = false
  for _, DeliverObject in pairs(tConfig.tDeliverObjs) do
    local hObject = WRAPPER_CheckForHandle(DeliverObject)
    if Object.IsVehicle(hObject) then
      local eEvent = EVENT_PlayerEntersVehicle("SabTaskObjectiveDeliver.CallbackPlayerEnteredVehicle", self, hObject, hObject)
      table.insert(self._tDeliverEvents, eEvent)
      if not tConfig.bBlipLocatorsOnly then
        HUD.ClearGPSTarget()
        self._bGPSTarget = true
        self._hGPSTarget = Handle(hObject)
        HUD.SetGPSTarget(Handle(hObject))
        self:SetUIBlips(hObject, true)
      end
    end
  end
  for _, DeliverObject in pairs(tConfig.tDeliverObjs) do
    local hObject = WRAPPER_CheckForHandle(DeliverObject)
    if Object.IsVehicle(hObject) and hObject == hPlayerVehicle and bPlayerInDeliveryVeh then
      self:SetUIBlips(hObject, false, true)
      bBlipDestinations = true
    end
  end
  self:BlipDestinations(bBlipDestinations)
  if bPlayerInDeliveryVeh and hPlayerVehicle then
    self:CallbackPlayerEnteredVehicle(hPlayerVehicle)
  end
end

function SabTaskObjectiveDeliver:CallbackPlayerEnteredAnyVehicle()
  local tConfig = self:GetConfig()
  if self:IsActive() then
    SabTaskObjective.SubObjectiveCompleted(self)
  end
end

function SabTaskObjectiveDeliver:CallbackPlayerEnteredVehicle(hVehicle)
  local tConfig = self:GetConfig()
  if string.upper(tConfig.sTaskSubType) == "DELIVER" then
    for _, hDeliverObj in pairs(tConfig.tDeliverObjs) do
      hDeliverObj = WRAPPER_CheckForHandle(hDeliverObj)
      self:SetUIBlips(hDeliverObj, false, true)
    end
    self:_CleanDeliveryEvents()
    local eEvent = EVENT_PlayerExitsAnyVehicle("SabTaskObjectiveDeliver.CallbackPlayerExitedVehicle", self)
    table.insert(self._tDeliverEvents, eEvent)
    self:BlipDestinations(true)
  elseif string.upper(tConfig.sTaskSubType) == "FETCH" then
    SabTaskObjective.SubObjectiveCompleted(self)
  end
end

function SabTaskObjectiveDeliver:CallbackPlayerExitedVehicle()
  print("&& player exited delivery vehicle")
  self:CheckInDeliveryVehicle()
end

function SabTaskObjectiveDeliver:BlipDestinations(bOn, bClearGPS, GPSThis)
  local tConfig = self:GetConfig()
  if tConfig.tLocators then
    for _, V in pairs(tConfig.tLocators) do
      self:SetUIBlips(V, bOn)
    end
  end
  if tConfig.tDestLocators then
    local bGroundBlip = false
    if tConfig.bGroundBlip then
      bGroundBlip = true
    end
    for _, V in pairs(tConfig.tDestLocators) do
      self:SetUIBlips(V, bOn, false, bGroundBlip)
    end
    if bClearGPS then
      HUD.ClearGPSTarget()
    elseif tConfig.tDestLocators[1] and bOn and not tConfig.vGPSDestTarget then
      local hGPSTarg = WRAPPER_CheckForHandle(tConfig.tDestLocators[1])
      self._bGPSTarget = true
      self._hGPSTarget = hGPSTarg
      HUD.SetGPSTarget(hGPSTarg)
    elseif tConfig.vGPSDestTarget and bOn then
      local hGPSTarg = WRAPPER_CheckForHandle(tConfig.vGPSDestTarget)
      self._bGPSTarget = true
      self._hGPSTarget = hGPSTarg
      HUD.SetGPSTarget(hGPSTarg)
    elseif tConfig.tDestLocators[1] and not bOn and self._bGPSTarget then
      HUD.ClearGPSTarget()
      self:_ClearGPS()
    end
  elseif bOn then
    self:_ClearGPS()
    self:_SetupGPS()
  end
  if tConfig.tDestProximityObj then
    for _, V in pairs(tConfig.tDestProximityObj) do
      self:SetUIBlips(V, bOn)
    end
  end
end

function SabTaskObjectiveDeliver:BlipDeliverObjs(bOn)
  local tConfig = self:GetConfig()
  if tConfig.tDeliverObjs then
    for _, V in pairs(tConfig.tDeliverObjs) do
      print("turning  blip for ", V, " ", bOn)
      self:SetUIBlips(V, bOn)
    end
  end
end

function SabTaskObjectiveDeliver:GetTriggerRegionHandle()
  local hTrigRegion, sTrigger
  local tConfig = self:GetConfig()
  if tConfig.tDestRegion and type(tConfig.tDestRegion) == "table" then
    sTrigger = tConfig.tDestRegion[1]
  else
    sTrigger = tConfig.tDestRegion
  end
  hTrigRegion = WRAPPER_CheckForHandle(sTrigger)
  if tConfig.tDestRegion and not hTrigRegion then
    print("ERROR GetTriggerRegionHandle: could not get handle to trigger region ", sTrigger, " in ", self:GetName())
  end
  return hTrigRegion
end

function SabTaskObjectiveDeliver:GetTriggerPickupRegionHandle()
  local hTrigRegion, sTrigger
  local tConfig = self:GetConfig()
  if tConfig.tPickupRegion and type(tConfig.tPickupRegion) == "table" then
    sTrigger = tConfig.tPickupRegion[1]
  else
    sTrigger = tConfig.tPickupRegion
  end
  if sTrigger then
    hTrigRegion = Handle(sTrigger)
  end
  if tConfig.tPickupRegion and not hTrigRegion then
    print("ERROR GetTriggerPickupRegionHandle: could not get handle to trigger region ", sTrigger, " in ", self:GetName())
  end
  return hTrigRegion
end

function SabTaskObjectiveDeliver:GetProximityPickupHandle()
  local sProxObj, hProxObj
  local tConfig = self:GetConfig()
  if tConfig.tPickupProxObj and type(tConfig.tPickupProxObj) == "table" then
    sProxObj = tConfig.tPickupProxObj[1]
  else
    sProxObj = tConfig.tPickupProxObj
  end
  if sProxObj then
    hProxObj = Handle(sProxObj)
  end
  if tConfig.tPickupProxObj and not hProxObj then
    print("ERROR GetProximityPickupHandle: could not get handle to proximity obj ", sProxObj, " in ", self:GetName())
  end
  return hProxObj
end

function SabTaskObjectiveDeliver:SetProximityPickupEvent(hObj, sCallback, tArgs)
  local tConfig = self:GetConfig()
  local Prox = tConfig.PickupProximity or 6
  if self._bRePickupPassengers then
    Prox = 100
  end
  if hObj then
    local tProxEvent = {
      EventType = "ProximityEvent",
      ObjectA = hSab,
      ObjectB = hObj,
      Proximity = Prox,
      Check3D = true,
      Negate = tConfig.bNegateProxPickup
    }
    self:RegisterEvent(Util.CreateEvent(tProxEvent, sCallback, self, tArgs))
  else
    self:WarningNil("hObj", "SabTaskObjectiveDeliver:GetProximityPickupHandle")
  end
end

function SabTaskObjectiveDeliver:SetupTriggerRegionDeliver()
  local tConfig = self:GetConfig()
  local hTrigRegion, OnTriggerTable
  hTrigRegion = self:GetTriggerRegionHandle()
  Trigger.Enable(hTrigRegion, true)
  local tDeliver
  if tConfig.tDeliverObjs then
    tDeliver = tConfig.tDeliverObjs
  else
    self:WarningNil("tConfig.tDeliverObjs", "SabTaskObjectiveDeliver:Activated")
  end
  for _, Object in pairs(tDeliver) do
    local hDeliverObj = WRAPPER_CheckForHandle(Object)
    if hDeliverObj ~= nil then
      local k_TriggerEventType = cTRIGGEREVENT_ONENTER_SMART
      if tConfig.sTaskSubType and string.upper(tConfig.sTaskSubType) == "TAXI" then
        return
      end
      if tConfig.sTaskSubType and string.upper(tConfig.sTaskSubType) == "TAXIDELIVER" then
      elseif tConfig.sTaskSubType and string.upper(tConfig.sTaskSubType) == "TAXIPICKUP" then
      else
        if tConfig.sTaskSubType and string.upper(tConfig.sTaskSubType) == "ESCAPE" or tConfig.bNegate then
          k_TriggerEventType = cTRIGGEREVENT_ONEXIT
        end
        local hTriggerID = Trigger.WaitFor(hTrigRegion, hDeliverObj, "SabTaskObjectiveDeliver.CallbackDeliveredRegion", self, {OnTriggerTable}, k_TriggerEventType, false)
        self:RegisterTriggerEvent(hTriggerID, hTrigRegion)
      end
    else
      self:WarningNil("hDeliverObj", "SabTaskObjectiveDeliver:Activated")
    end
  end
  if tConfig.sTaskSubType and string.upper(tConfig.sTaskSubType) == "TAXIPICKUP" then
    local hTriggerID = Trigger.WaitFor(hTrigRegion, hSab, "SabTaskObjectiveDeliver.CallbackTaxiPickup", self, {OnTriggerTable}, cTRIGGEREVENT_ONENTER_SMART, true)
    self:RegisterTriggerEvent(hTriggerID, hTrigRegion)
  end
end

function SabTaskObjectiveDeliver:SetupProximityDeliver()
  local tConfig = self:GetConfig()
  if not tConfig.tDestProximityObj then
    print("SetupProximityDeliver:: could not find tDestProximityObj table ERROR")
    return
  end
  if type(tConfig.tDestProximityObj) == "table" and #tConfig.tDestProximityObj > 1 then
    for _, vDest in pairs(tConfig.tDestProximityObj) do
      self:ProximityEvent(hSab, vDest)
    end
  else
    local hDest = WRAPPER_CheckForHandle(tConfig.tDestProximityObj[1])
    if hDest then
      if tConfig.tDeliverObjs and #tConfig.tDeliverObjs > 0 then
        for _, vObject in pairs(tConfig.tDeliverObjs) do
          self:ProximityEvent(vObject, hDest)
        end
      else
        print("SetupProximityDeliver:: you forgot to add a tDeliverObjs for delivery task")
      end
    else
      self:WarningNil("hDest", "SabTaskObjectiveDeliver:Activated")
    end
  end
end

function SabTaskObjectiveDeliver:ProximityEvent(vObject, vDest)
  local tConfig = self:GetConfig()
  local hObj = WRAPPER_CheckForHandle(vObject)
  local hDest = WRAPPER_CheckForHandle(vDest)
  local tProxEvent = {
    EventType = "ProximityEvent",
    ObjectA = hDest,
    ObjectB = hObj,
    Proximity = tConfig.Proximity or 5,
    Check3D = true,
    Negate = tConfig.bNegate
  }
  self:RegisterEvent(Util.CreateEvent(tProxEvent, "SabTaskObjectiveDeliver.CallbackTargetDeliveredProx", self, {hObj, hDest}))
end

function SabTaskObjectiveDeliver:CallbackTargetDeliveredProx(hActivator, hDest)
  SabTaskObjective.SetUIBlips(self, hActivator, false)
  self:CheckDeliverPartialFinish(hActivator)
  self:CheckForCinematic()
  SabTaskObjective.SubObjectiveCompleted(self)
end

function SabTaskObjectiveDeliver:CallbackPickedUpSuccess(hActivator)
  local hTaxi = Actor.GetVehicle(hSab)
  self:ReleaseVehicle(hTaxi)
  self:CheckForCinematic()
  SabTaskObjective.SubObjectiveCompleted(self)
end

function SabTaskObjectiveDeliver:CallbackDeliveredRegion(tTriggerTable, tArgsTable)
  local hTrigger = tTriggerTable[1]
  local hActivator = tTriggerTable[2]
  local tConfig = self:GetConfig()
  self:CheckDeliverPartialFinish(hActivator)
  if not self.KillTriggerCount then
    self.KillTriggerCount = 0
  end
  self.KillTriggerCount = self.KillTriggerCount + 1
  if self.KillTriggerCount == self:GetQuota() then
    local hTrigRegion
    hTrigRegion = self:GetTriggerRegionHandle()
    for _, Object in pairs(tConfig.tDeliverObjs) do
      Object = WRAPPER_CheckForHandle(Object)
    end
  end
  if hActivator then
    SabTaskObjective.SetUIBlips(self, hActivator, false)
  end
  self:CheckForCinematic()
  SabTaskObjective.SubObjectiveCompleted(self)
end

function SabTaskObjectiveDeliver:CallbackCheckTaxiDeliver(tTriggerTable, tArgsTable)
  local hTrigger = tTriggerTable[1]
  local hTaxiPassengerX = tTriggerTable[2]
  local tConfig = self:GetConfig()
  local tAllTriggerPassengers = tArgsTable
  local hTaxi = Actor.GetVehicle(hSab)
  local bDumping = false
  local sDropOffConv = tConfig.sDropOffConv or tConfig.sDropoffConv
  local tPassengers
  if hTaxi then
    tPassengers = Vehicle.GetPassengers(hTaxi)
  end
  if not tAllTriggerPassengers then
    Util.Assert(tAllTriggerPassengers, "Uh oh SabTaskObjectiveDeliver:CallbackCheckTaxiDeliver tAllTriggerPassengers is nil ")
    return
  end
  for x, hTaxiPassenger in pairs(tAllTriggerPassengers) do
    if tConfig.sRequiredVehicle then
      if not hTaxi then
        if hTaxiPassenger ~= Handle(tConfig.sRequiredVehicle) then
          self:SetupEnterVehicleAtDestination(tTriggerTable, tArgsTable)
        end
        return
      else
        if hTaxi ~= Handle(tConfig.sRequiredVehicle) then
          if hTaxiPassenger ~= Handle(tConfig.sRequiredVehicle) then
            self:SetupEnterVehicleAtDestination(tTriggerTable, tArgsTable)
          end
          return
        else
        end
      end
      if hTaxiPassenger == Handle(tConfig.sRequiredVehicle) then
        return
      end
    end
    if tConfig.bVehicleIsRequired and not hTaxi then
      print("vehicle is required and there is no car")
      self:SetupEnterVehicleAtDestination(tTriggerTable, tArgsTable)
      return
    end
    if tPassengers then
      if self._bTaxiStateActive then
        self:BlipDestinations(false)
      end
      if not tConfig.bSpecialCaseBrakeOverride then
        self:StopVehicle(hTaxi)
      end
    end
    print("CallbackCheckTaxiDeliver")
    if sDropOffConv and not self._bPlayEndConv and hTaxi then
      self._bPlayEndConv = true
      self:ClearTaxiFollowers()
      Cin.PlayConversation(sDropOffConv, "SabTaskObjectiveDeliver.DropPassengers", self, {
        hTaxi,
        hTaxiPassenger,
        hTrigger
      })
    elseif hTaxi then
      self:DropPassengers({}, hTaxi, hTaxiPassenger, hTrigger)
    else
      if sDropOffConv and not self._bPlayEndConv then
        self._bPlayEndConv = true
        self:ClearTaxiFollowers()
        Cin.PlayConversation(sDropOffConv)
      end
      self:_TaxiSubObjectiveComplete()
    end
  end
end

function SabTaskObjectiveDeliver:ClearTaxiFollowers()
  local tConfig = self:GetConfig()
  if tConfig.tDeliverObjs then
    for i, v in pairs(tConfig.tDeliverObjs) do
      local hPass = Handle(v)
      if hPass and not tConfig.bNoDumping and not Object.IsVehicle(hPass) and hPass ~= hSab then
        self:ClearFollowerType(hPass)
      end
    end
  end
end

function SabTaskObjectiveDeliver:TestForVehicleInTrigger(vVehicle)
  local hVehicle = Handle(vVehicle)
  if hVehicle then
  end
end

function SabTaskObjectiveDeliver:SetupEnterVehicleAtDestination(tTriggerTable, tArgsTable)
  local hTrigger = tTriggerTable[1]
  local hTaxiPassenger = tTriggerTable[2]
  if hTaxiPassenger then
    if self._eSpecialVehicleListener then
      Util.Assert(false, "SabTaskObjectiveDeliver:SetupEnterVehicleAtDestination already set")
    end
    self._eSpecialVehicleListener = EVENT_ActorEntersAnyVehicle("SabTaskObjectiveDeliver.CallbackRetestAlreadyInTrigger", self, hTaxiPassenger, {tTriggerTable, tArgsTable})
    EVENT_ActorExitsTrigger("SabTaskObjectiveDeliver.ClearSpecialVehicleListener", self, hTaxiPassenger, hTrigger)
  end
end

function SabTaskObjectiveDeliver:ClearSpecialVehicleListener()
  if self._eSpecialVehicleListener then
    Util.KillEvent(self._eSpecialVehicleListener)
    self._eSpecialVehicleListener = nil
  end
end

function SabTaskObjectiveDeliver:CallbackRetestAlreadyInTrigger(tArgs, tTriggerTable, tArgsTable)
  local tConfig = self:GetConfig()
  print("CallbackRetestAlreadyInTrigger ", tArgs, tTriggerTable, tArgsTable)
  local hTrigger = tTriggerTable[1]
  local hTaxiPassenger = tTriggerTable[2]
  local tInTrigger = Trigger.GetAllWithin(hTrigger)
  local bFoundPerson = false
  if tInTrigger then
    for i, hThing in ipairs(tInTrigger) do
      if hThing == hTaxiPassenger then
        print("found a person already in trigger")
        bFoundPerson = true
        break
      end
    end
  end
  if bFoundPerson then
    self:CallbackCheckTaxiDeliver(tTriggerTable, tArgsTable)
  end
end

function SabTaskObjectiveDeliver:DropAllPassengers(tCallbackArgs, hTaxi, hTrigger)
  local tConfig = self:GetConfig()
  local tPassengers = Vehicle.GetPassengers(hTaxi)
  local bDumping = false
  print("Drop All Passengers ", hTaxi, hTrigger)
  if tPassengers and not tConfig.bNoDumping then
    local hTestPilot = Vehicle.GetPilot(hTaxi)
    for i, v in pairs(tPassengers) do
      if not tConfig.bNoDumping then
        bDumping = true
        self:ClearFollowerType(v)
        self:AskPassengerToPleaseLeave(hTrigger, v)
      elseif Config.bNoDumping then
        EVENT_Timer("SabTaskObjectiveDeliver.FinishNoDumping", self, 1, {hTaxi})
        print("no dumping , completing")
      else
        print("Caught in between state of dumping passengers")
        self:FinishNoDumping(hTaxi)
      end
    end
    if not bDumping then
      self:ReleaseVehicle(hTaxi)
      print("no passengers , releasing vehicle")
      self:_TaxiSubObjectiveComplete()
    end
  end
end

function SabTaskObjectiveDeliver:DropPassengers(tCallbackArgs, hTaxi, hTaxiPassenger, hTrigger)
  local tConfig = self:GetConfig()
  local tPassengers = Vehicle.GetPassengers(hTaxi)
  local bDumping = false
  print("DropPassengers ", hTaxi, hTaxiPassenger, hTrigger)
  if tPassengers and not tConfig.bNoDumping then
    local hTestPilot = Vehicle.GetPilot(hTaxi)
    for i, v in pairs(tPassengers) do
      if v == hTaxiPassenger and v ~= hTestPilot then
        bDumping = true
        self:ClearFollowerType(hTaxiPassenger)
        self:AskPassengerToPleaseLeave(hTrigger, hTaxiPassenger)
      end
    end
    if not bDumping then
      self:ReleaseVehicle(hTaxi)
      print("no passengers , releasing vehicle")
      self:_TaxiSubObjectiveComplete()
    end
  elseif tConfig.bNoDumping then
    EVENT_Timer("SabTaskObjectiveDeliver.FinishNoDumping", self, 1, {hTaxi})
    print("no dumping , completing")
  else
    print("Caught in between state of dumping passengers")
    self:FinishNoDumping(hTaxi)
  end
end

function SabTaskObjectiveDeliver:FinishNoDumping(hTaxi)
  local hTaxi = hTaxi
  local tConfig = self:GetConfig()
  hTaxi = hTaxi or Actor.GetVehicle(hSab)
  self:ReleaseVehicle(hTaxi)
  self:_TaxiSubObjectiveComplete()
end

function SabTaskObjectiveDeliver:CallbackTaxiPickup(tTriggerTable, tArgsTable)
  local hTrigger = tTriggerTable[1]
  local hTaxiPassenger = tTriggerTable[2]
  local tConfig = self:GetConfig()
  local hTaxi = Actor.GetVehicle(hSab)
  if hTaxi then
    if 1 < Vehicle.GetNumSeats(hTaxi) then
    end
    self:StartTaxi()
  else
    self:StartTaxi()
    print("SabTaskObjectiveDeliver:CallbackTaxiPickup:vehicle is needed to complete taxi pickup")
  end
end

function SabTaskObjectiveDeliver:StopVehicle(vVehicle, BrakeMultiplier)
  local hVehicle = WRAPPER_CheckForHandleNil(vVehicle)
  local tConfig = self:GetConfig()
  print("disabling vehicle controls", vVehicle)
  if hVehicle then
    Vehicle.BrakeTo(hVehicle, 0)
    Vehicle.OverrideBraking(hVehicle, true, 8)
  end
  SabTaskObjectiveDeliver.DisableVehControls(self, true)
end

function SabTaskObjectiveDeliver:ReleaseVehicle(vVehicle)
  local hVehicle = WRAPPER_CheckForHandleNil(vVehicle)
  print("releasing vehicle ", vVehicle)
  if self.__eStopVehicleCheck then
    Util.KillEvent(self.__eStopVehicleCheck)
    self.__eStopVehicleCheck = nil
  end
  if hVehicle then
    Vehicle.BrakeTo(hVehicle, 200)
    Vehicle.OverrideBraking(hVehicle, false, 1)
  end
  SabTaskObjectiveDeliver.ClearVehControls(self)
end

function SabTaskObjectiveDeliver:ReleaseControls()
  self:ClearVehControls()
end

function SabTaskObjectiveDeliver:DisableVehControls(bDisable)
  SetDisableControl("EnterExitVehicle", bDisable)
  SetDisableControl("Break", bDisable)
  SetDisableControl("Gas", bDisable)
  SetDisableControl("HandBreak", bDisable)
end

function SabTaskObjectiveDeliver:ClearVehControls()
  ClearDisableControl("EnterExitVehicle")
  ClearDisableControl("Break")
  ClearDisableControl("Gas")
  ClearDisableControl("HandBreak")
end

function SabTaskObjectiveDeliver:AskPassengerToPleaseLeave(hTrigger, hPassenger)
  if self.__eTAXIFETCH then
    Util.KillEvent(self.__eTAXIFETCH)
    self.__eTAXIFETCH = nil
  end
  if self._bTaxiStateActive then
    self:TaxiEnterState(_cTAXIFINISH)
  end
  if self._tPassengersBoarded[hPassenger] then
    self._tPassengersBoarded[hPassenger] = nil
  end
  EVENT_ActorExitsAnyVehicle("SabTaskObjectiveDeliver.PreSubObjectiveComplete", self, hPassenger, hPassenger)
  EVENT_Timer("SabTaskObjectiveDeliver.TaxiDumper", self, 0.3, hPassenger)
  Trigger.DoNotWaitFor(hTrigger, hPassenger)
end

function SabTaskObjectiveDeliver:TaxiDumper(hPassenger)
  local tConfig = self:GetConfig()
  Actor.UnboardVehicle(hPassenger, true)
  self:_ClearAbandon(hPassenger)
  local hTaxi = Actor.GetVehicle(hSab)
  if hTaxi and not tConfig.bFadeOutOnDropOff then
    Util.CreateEvent({EventType = "TimerEvent", Time = 2.5}, "SabTaskObjectiveDeliver.ReleaseVehicle", self, {hTaxi})
    Util.CreateEvent({EventType = "TimerEvent", Time = 0.5}, "SabTaskObjectiveDeliver.ReleaseControls", self, {hTaxi})
  end
end

function SabTaskObjectiveDeliver:PreSubObjectiveComplete(hTarget, hPassenger)
  local tConfig = self:GetConfig()
  if hPassenger then
    SabTaskObjective.SetUIBlips(self, hPassenger, false, true)
  end
  EVENT_Timer("SabTaskObjectiveDeliver._TaxiSubObjectiveComplete", self, 0.4)
end

function SabTaskObjectiveDeliver:CheckDeliverPartialFinish(hActivator)
  local tConfig = self:GetConfig()
  if tConfig.sTaskSubType then
    if string.upper(tConfig.sTaskSubType) == "ESCORT" then
      local hObj = WRAPPER_CheckForHandle(hActivator)
      self:ClearFollowerType(hObj)
    elseif string.upper(tConfig.sTaskSubType) == "TAXI" then
      local hObj = WRAPPER_CheckForHandle(hActivator)
      if not tConfig.bDontClearFollower then
        self:ClearFollowerType(hObj)
      end
    elseif string.upper(tConfig.sTaskSubType) == "TAXIPICKUP" then
      local hObj = WRAPPER_CheckForHandle(hActivator)
      self:ClearFollowerType(hObj)
    elseif string.upper(tConfig.sTaskSubType) == "TAXIDELIVER" then
      local hObj = WRAPPER_CheckForHandle(hActivator)
      self:ClearFollowerType(hObj)
    elseif string.upper(tConfig.sTaskSubType) == "TAXIWAIT" then
      local hObj = WRAPPER_CheckForHandle(hActivator)
      self:ClearFollowerType(hObj)
    elseif string.upper(tConfig.sTaskSubType) == "FOLLOW" then
      local hObj = WRAPPER_CheckForHandle(hActivator)
    elseif string.upper(tConfig.sTaskSubType) == "ESCAPE" then
    elseif string.upper(tConfig.sTaskSubType) == "RESCUE" then
    elseif string.upper(tConfig.sTaskSubType) == "CHASE" then
    end
  else
    print("WARNING:: ", self:GetName(), " does not have a sTaskSubType")
  end
end

function SabTaskObjectiveDeliver:OnEscortDeath()
  local tConfig = self:GetConfig()
  local tCallbacks = tConfig.tOnFailure
  if tCallbacks and type(tCallbacks) == "table" then
    for _, tCallback in ipairs(tCallbacks) do
      __UtilFunctions.CallWithOptionalArgs(tCallback[1], tCallback[2])
    end
  end
  if tConfig.bFailMissionOnFail then
    local parent = self:GetParent()
    if parent:IsActive() then
      parent:Cancel()
    end
  end
end

function SabTaskObjectiveDeliver:_CleanDeliveryEvents()
  if not self._tDeliverEvents then
  end
  if self._tDeliverEvents then
    for _, V in pairs(self._tDeliverEvents) do
      Util.KillEvent(V)
    end
  end
  self._tDeliverEvents = {}
end

function SabTaskObjectiveDeliver:CheckForCinematic()
  tConfig = self:GetConfig()
  if tConfig and tConfig.sCinFile and tConfig.sCinFile ~= "" then
    self:FireEndCinematic()
  end
end

function SabTaskObjectiveDeliver:_CleanEvents()
  self:_ClearAllAbandon()
  self:_CleanDeliveryEvents()
  self:_CleanGeneralEvents()
  self:_CleanTriggerEvents()
  self:_CleanVehicleDeaths()
end

function SabTaskObjectiveDeliver:_TaxiSubObjectiveComplete()
  local tConfig = self:GetConfig()
  self:SubObjectiveCompleted()
  if tConfig.bFadeOutOnDropOff and self:GetQuota() - 1 == self._CompletedCount then
    print(" ****  fade out expected")
    self:TaxiDeliverFadeOut()
  end
end

function SabTaskObjectiveDeliver:_Complete()
  local tConfig = self:GetConfig()
  if tConfig.sTaskSubType and string.upper(tConfig.sTaskSubType) == "TAXI" then
    self:ClearVehControls()
  end
  SabTaskObjective._Complete(self)
end

function SabTaskObjectiveDeliver:_Cleanup(bForceUnload, bSaveLoad)
  local tConfig = self:GetConfig()
  self:_CleanEvents()
  if tConfig.tDeliverObjs then
    for _, Object in pairs(tConfig.tDeliverObjs) do
      local hObj = WRAPPER_CheckForHandleNil(Object)
      if hObj then
        self:CheckDeliverPartialFinish(hObj)
      end
    end
  end
  if self._bTaxiUpdate then
    self:StopTaxiUpdateLoop()
  end
  if self.FollowSquadID then
    Squad.Delete(self.FollowSquadID)
    self.FollowSquadID = nil
  end
  if self._SabSquadDeliverID then
    Squad.Delete(self._SabSquadDeliverID)
    self._SabSquadDeliverID = nil
  end
  if self._bHasInteriorCallbacks and tConfig.sInteriorName then
    Util.CancelInteriorLoadCallback(tConfig.sInteriorName)
  end
  if self._eSpecialVehicleListener then
    Util.KillEvent(self._eSpecialVehicleListener)
    self._eSpecialVehicleListener = nil
  end
  SabTaskObjective._Cleanup(self, bForceUnload, bSaveLoad)
end

function SabTaskObjectiveDeliver:StartTaxiTrigger(bPickup)
  local tConfig = self:GetConfig()
  local hTrigRegion, hProxObj
  if bPickup then
    hTrigRegion = self:GetTriggerPickupRegionHandle()
    hProxObj = self:GetProximityPickupHandle()
  else
    hTrigRegion = self:GetTriggerRegionHandle()
  end
  if not hTrigRegion then
  end
  local sCallbackFunction = "SabTaskObjectiveDeliver.CallbackStateTaxiTrigEnter"
  if bPickup then
    if hTrigRegion and not self._bRePickupPassengers then
      Trigger.Enable(hTrigRegion, true)
      local hTriggerID = Trigger.WaitFor(hTrigRegion, hSab, sCallbackFunction, self, {bPickup}, cTRIGGEREVENT_ONENTER_SMART, true)
      self:RegisterTriggerEvent(hTriggerID, hTrigRegion)
    elseif hProxObj then
      print("StartTaxiTrigger: setting up prox pickup ", hProxObj)
      self:SetProximityPickupEvent(hProxObj, "SabTaskObjectiveDeliver.CallbackStateProxEnter", {bPickup, hProxObj})
    elseif self._bRePickupPassengers then
      print("_bRePickupPassengers StartTaxiTrigger")
      hProxObj = self:FindPickupProxPassenger()
      if hProxObj then
        self:SetProximityPickupEvent(hProxObj, "SabTaskObjectiveDeliver.CallbackStateProxEnter", {bPickup, hProxObj})
      else
        self:TaxiEnterState(_cTAXIFAIL)
      end
    else
      self:TaxiEnterState(_cTAXIFAIL)
    end
    if tConfig.tDeliverObjs and not self._bGPSTarget and not tConfig.vGPSTarget and not tConfig.bVehicleIsRequired then
      tConfig.vGPSTarget = tConfig.tDeliverObjs[1]
      print("setting gps target for taxi pickup")
      self:_SetupGPS()
    else
    end
  else
    sCallbackFunction = "SabTaskObjectiveDeliver.CallbackCheckTaxiDeliver"
    local tDeliver
    if tConfig.tDeliverObjs then
      tDeliver = tConfig.tDeliverObjs
    else
      return self:WarningNil("tConfig.tDeliverObjs", "SabTaskObjectiveDeliver:Activated")
    end
    if not self._bTriggerDeliverSet then
      if tConfig.sRequiredVehicle then
        local bFoundRequiredVehicle = false
        for _, ObjectDropOff in pairs(tDeliver) do
          if Handle(ObjectDropOff) == Handle(tConfig.sRequiredVehicle) then
            bFoundRequiredVehicle = true
          end
        end
        if not bFoundRequiredVehicle then
          table.insert(tConfig.tDeliverObjs, tConfig.sRequiredVehicle)
        end
      end
      local tWaitFors = {}
      for _, ObjectPickup in pairs(tConfig.tDeliverObjs) do
        local hDeliverObj = WRAPPER_CheckForHandle(ObjectPickup)
        if hDeliverObj ~= nil then
          self._tSuperTaxiPassengers[hDeliverObj] = _cPASS_WAITING
          table.insert(tWaitFors, hDeliverObj)
        else
          self:WarningNil("hDeliverObj", "SabTaskObjectiveDeliver:Activated")
        end
      end
      local hTriggerID = Trigger.WaitFor(hTrigRegion, tWaitFors, sCallbackFunction, self, {tWaitFors}, cTRIGGEREVENT_ONENTER_SMART, true)
      self:RegisterTriggerEvent(hTriggerID, hTrigRegion)
      self._bTriggerDeliverSet = true
    end
  end
  local hMessage = self:GetTaskObjectiveID()
  local sString = self:GetLocalizedText(tConfig.sPickupTextID)
  local bDisableObj = false
  if not bPickup then
    sString = self:GetLocalizedText(tConfig.sDropoffTextID)
  end
  sString = sString or self:GetLocalizedText(tConfig.sObjectiveTextID)
  if hMessage and sString and not bDisableObj then
    HUD.SetObjectiveText(hMessage, sString)
  end
  local state = _cTAXIFETCHPICK
  if not bPickup then
    state = _cTAXIFETCHDROP
  end
  if not self.__eTAXIFETCH then
    self.__eTAXIFETCH = EVENT_PlayerExitsAnyVehicle("SabTaskObjectiveDeliver.CallbackStateTaxiExitVehicle", self, {state}, true)
  else
    print("self.__eTAXIFETCH  already set")
  end
end

function SabTaskObjectiveDeliver:CallbackStateTaxiExitVehicle(tArgs, state)
  local tConfig = self:GetConfig()
  local state = state
  if self._bTaxiInEscalationState then
    state = _cLOSE_ESCALATION
  end
  local tConfig = self:GetConfig()
  self:RunCallbacksTable(tConfig.tOnEarlyExit)
  if tConfig.bVehicleIsRequired then
    print("i have been ordered to break the game")
    self._bGPSTarget = false
    self._bRePickupPassengers = true
    state = _cTAXIFETCHPICK
  end
  if not self._bTaxiInEscalationState then
    self:TaxiEnterState(state)
  end
end

function SabTaskObjectiveDeliver:RunCallbacksTable(tCallbackTable)
  local tConfig = self:GetConfig()
  if tCallbackTable and type(tCallbackTable) == "table" then
    for _, tCallback in ipairs(tCallbackTable) do
      __UtilFunctions.CallWithOptionalArgs(tCallback[1], tCallback[2])
    end
  end
end

function SabTaskObjectiveDeliver:__FetchVehicle(bPickup)
  local tConfig = self:GetConfig()
  self._TotalNumPassengers = 0
  local hPlayerVehicle = Actor.GetVehicle(hSab)
  local hRequiredVehicle = Handle(tConfig.sRequiredVehicle)
  local bReqVeh
  if hRequiredVehicle then
    bReqVeh = true
  end
  if tConfig.tDeliverObjs and 0 < #tConfig.tDeliverObjs then
    self._TotalNumPassengers = self._TotalNumPassengers + #tConfig.tDeliverObjs + 1
    print("Total number of passengers for this taxi task ", self._TotalNumPassengers)
  end
  local bHasEnoughSeats = true
  if hPlayerVehicle then
    bHasEnoughSeats = self:HaveEnoughSeats(hPlayerVehicle)
  end
  if tConfig.bNoCarRequired and not bReqVeh then
    if tConfig.bNoCarRequired then
      print("this Taxi task does not require a vehicle has vehicle?:", hPlayerVehicle)
    end
    if bPickup then
      self:TaxiEnterState(_cTAXIPICKUP)
    else
      self:TaxiEnterState(_cTAXIDROPOFF)
    end
  else
    if bPickup then
      self._bTriggerDeliverSet = false
      self:_CleanTriggerEvents()
    end
    if hRequiredVehicle then
      if hPlayerVehicle == hRequiredVehicle then
        self:CallbackPlayerEnteredAnyVehicleTaxi(bPickup)
        return
      else
        print("__FetchVehicle: waiting for player to enter required vehicle")
        self:BlipDestinations(false)
        self:SetUIBlips(tConfig.sRequiredVehicle, true)
        self._bGPSTarget = true
        self._hGPSTarget = hRequiredVehicle
        HUD.SetGPSTarget(hRequiredVehicle)
        EVENT_PlayerEntersVehicle("SabTaskObjectiveDeliver.CallbackPlayerEnteredAnyVehicleTaxi", self, hRequiredVehicle, bPickup)
      end
    elseif tConfig.tRequiredVehicleBP then
      local bBlueprint = true
      for i, BP in pairs(tConfig.tRequiredVehicleBP) do
      end
      return
    elseif tConfig.bNoCarRequired then
      print("this Taxi task does not require a vehicle")
      self:TaxiEnterState(_cTAXIPICKUP)
      return
    elseif hPlayerVehicle then
      print("__FetchVehicle: player is in a vehicle testing seat numbers")
      self:CallbackPlayerEnteredAnyVehicleTaxi_TestNumSeats({}, bPickup)
      return
    else
      print("__FetchVehicle: waiting for player to enter a vehicle")
      self:SetTaxiObjectiveTextID()
      if tConfig.bVehicleIsRequired then
        self:BlipDestinations(false)
      end
      EVENT_PlayerEntersAnyVehicle("SabTaskObjectiveDeliver.CallbackPlayerEnteredAnyVehicleTaxi_TestNumSeats", self, bPickup)
    end
    self:SetPickupVehicleTextID(bHasEnoughSeats)
  end
end

function SabTaskObjectiveDeliver:HaveEnoughSeats(hVehicle)
  local CurrentVehicleNumSeats = Vehicle.GetNumSeats(hVehicle)
  if CurrentVehicleNumSeats < self._TotalNumPassengers then
    return true
  else
    return false
  end
end

function SabTaskObjectiveDeliver:SetTaxiObjectiveTextID(bPickup)
  local hMessage = self:GetTaskObjectiveID()
  local tConfig = self:GetConfig()
  print("SetTaxiObjectiveTextID")
  local sNewString = ""
  local hMessage = self:GetTaskObjectiveID()
  local sString = self:GetLocalizedText(tConfig.sPickupTextID)
  local bDisableObj = false
  if not bPickup then
    sString = self:GetLocalizedText(tConfig.sDropoffTextID)
  end
  sString = sString or self:GetLocalizedText(tConfig.sObjectiveTextID)
  if hMessage and sString and not bDisableObj then
    HUD.SetObjectiveText(hMessage, sString)
  end
end

function SabTaskObjectiveDeliver:SetPickupVehicleTextID(bHasEnoughSeats)
  local hMessage = self:GetTaskObjectiveID()
  local tConfig = self:GetConfig()
  print("SetPickupVehicleTextID")
  local sNewString = ""
  if tConfig.sVehicleFetchID and not self._bFirstFetchString then
    sNewString = self:GetLocalizedText(tConfig.sVehicleFetchID)
    self._bFirstFetchString = true
  elseif tConfig.sVehicleReturnID and tConfig.sVehicleFetchID then
    sNewString = self:GetLocalizedText(tConfig.sVehicleReturnID)
  end
  if hMessage and sNewString and sNewString ~= "" then
    HUD.SetObjectiveText(hMessage, sNewString)
  end
end

function SabTaskObjectiveDeliver:CallbackPlayerEnteredAnyVehicleTaxi_TestNumSeats(tArgs, bPickup)
  local state = _cTAXIPICKUP
  local tConfig = self:GetConfig()
  local bPickup = bPickup
  print("CallbackPlayerEnteredAnyVehicleTaxi_TestNumSeats")
  local hVehicle = Actor.GetVehicle(hSab)
  local bRealVehicle = false
  if hVehicle then
    bRealVehicle = Actor.IsInVehicle(hSab, true)
    if bRealVehicle then
      local CurrentVehicleNumSeats = Vehicle.GetNumSeats(hVehicle)
      if CurrentVehicleNumSeats < self._TotalNumPassengers then
        print("Player got in a vehicle that doesn't have enough seats for all passengers Vehicle seats:", Vehicle.GetNumSeats(hVehicle), " - Passengers:", self._TotalNumPassengers)
        if tConfig.sNotEnoughSeatsConv then
          Cin.PlayConversation(tConfig.sNotEnoughSeatsConv)
        elseif CurrentVehicleNumSeats == 2 then
          Cin.PlayConversation("Generic_Car_Too_Small_2")
        else
          Cin.PlayConversation("Generic_Car_Too_Small_1")
        end
        EVENT_PlayerEntersAnyVehicle("SabTaskObjectiveDeliver.CallbackPlayerEnteredAnyVehicleTaxi_TestNumSeats", self, bPickup)
        return
      end
    else
      print("player is not in a real vehicle, probably a turret or something")
      EVENT_PlayerEntersAnyVehicle("SabTaskObjectiveDeliver.CallbackPlayerEnteredAnyVehicleTaxi_TestNumSeats", self, bPickup)
      return
    end
  end
  self:CallbackPlayerEnteredAnyVehicleTaxi(bPickup)
end

function SabTaskObjectiveDeliver:CallbackPlayerEnteredAnyVehicleTaxi(bPickup)
  local state = _cTAXIPICKUP
  local tConfig = self:GetConfig()
  if tConfig.sRequiredVehicle and tConfig.sRequiredVehicle ~= "" then
    self:SetUIBlips(tConfig.sRequiredVehicle, false, true)
  end
  if not bPickup then
    state = _cTAXIDROPOFF
  end
  self:TaxiEnterState(state)
end

function SabTaskObjectiveDeliver:StartTaxiUpdateLoop()
  print("==START TAXI UPDATE")
  self._bTaxiUpdate = true
  Util.RegisterLuaUpdate("SabTaskObjectiveDeliver.TaxiUpdateLoop", self)
end

function SabTaskObjectiveDeliver:StopTaxiUpdateLoop()
  print("==STOP TAXI UPDATE")
  self._bTaxiUpdate = false
  Util.UnregisterLuaUpdate("SabTaskObjectiveDeliver.TaxiUpdateLoop")
end

function SabTaskObjectiveDeliver:TaxiUpdateLoop()
  if not self._bTaxiUpdate then
    return
  end
  if self.TaxiDeliverState == _cTAXISETUP then
  elseif self.TaxiDeliverState == _cTAXIPICKUP then
    self:CheckForPickupGPS()
  elseif self.TaxiDeliverState == _cTAXIFETCHPICK then
  elseif self.TaxiDeliverState == _cTAXIWAITFORLOAD then
    self:CheckForPickupGPS()
  elseif self.TaxiDeliverState == _cTAXIDROPOFF then
  elseif self.TaxiDeliverState == _cTAXIWAIT then
  elseif self.TaxiDeliverState == _cABANDONED then
  elseif self.TaxiDeliverState == _cLOSE_ESCALATION then
  elseif self.TaxiDeliverState == _cTAXIFETCHDROP then
  elseif self.TaxiDeliverState == _cTAXISTOPPICK then
  elseif self.TaxiDeliverState == _cTAXISTOPDROP then
  elseif self.TaxiDeliverState == _cTAXIFINISH then
  else
    if self.TaxiDeliverState == _cTAXIFAIL then
    else
    end
  end
end

function SabTaskObjectiveDeliver:CheckForPickupGPS()
  local tConfig = self:GetConfig()
  local bHasGps = false
  if not tConfig.bVehicleIsRequired then
    return
  end
  if self._vPickupGPS then
    return
  end
  for _, Obj in pairs(tConfig.tDeliverObjs) do
    local hObj = WRAPPER_CheckForHandle(Obj)
    if Object.IsVehicle(hObj) or hObj == hSab then
    elseif not Actor.IsInVehicle(hObj, true) then
      self._vPickupGPS = hObj
      print("--Setting gps to passenger ", hObj)
      break
    end
  end
  if self._vPickupGPS then
    tConfig.vGPSTarget = self._vPickupGPS
    print("--- setting gps target for taxi pickup in CheckForPickupGPS")
    self:_SetupGPS()
  end
end

function SabTaskObjectiveDeliver:FindPickupProxPassenger()
  local tConfig = self:GetConfig()
  for _, Obj in pairs(tConfig.tDeliverObjs) do
    local hObj = WRAPPER_CheckForHandle(Obj)
    if Object.IsVehicle(hObj) or hObj == hSab then
    else
      return hObj
    end
  end
end

function SabTaskObjectiveDeliver:TaxiEnterState(newstate)
  if self.TaxiDeliverState == newstate then
    return
  end
  local tConfig = self:GetConfig()
  self.TaxiDeliverState = newstate
  if newstate == _cTAXISETUP then
    self._bTriggerDeliverSet = false
    self:StartTaxiUpdateLoop()
    self:TaxiEnterState(_cTAXIFETCHPICK)
  elseif newstate == _cTAXIPICKUP then
    print("STATE: _cTAXIPICKUP")
    self:StartTaxiTrigger(true)
  elseif newstate == _cTAXIFETCHPICK then
    print("STATE: _cTAXIFETCHPICK")
    self:__FetchVehicle(true)
  elseif newstate == _cTAXIWAITFORLOAD then
    print("start _cTAXIWAITFORLOAD")
    self:StartTaxiAbandon()
    self:TaxiRouter(true)
  elseif newstate == _cTAXIDROPOFF then
    print("state _cTAXIDROPOFF")
    self:TaxiRouter(false)
    self:StartTaxiTrigger(false)
    if tConfig.bEscalationDenial then
      self:StartTaxiEscalationListener()
    end
  elseif newstate == _cTAXIWAIT then
  elseif newstate == _cABANDONED then
  elseif newstate == _cLOSE_ESCALATION then
    print("STATE: _cLOSE_ESCALATION")
    self:SetupTaxiEscalationFree()
  elseif newstate == _cTAXIFETCHDROP then
    print("STATE: _cTAXIFETCHDROP")
    self:__FetchVehicle(false)
  elseif newstate == _cTAXISTOPPICK then
    local hTaxi = Actor.GetVehicle(hSab)
    self:TaxiEnterState(_cTAXIWAITFORLOAD)
  elseif newstate == _cTAXISTOPDROP then
    local hTaxi = Actor.GetVehicle(hSab)
  elseif newstate == _cTAXIFINISH then
    self:StopTaxiUpdateLoop()
  elseif newstate == _cTAXIFAIL then
    Util.Assert(false, "CFRENCH taxi state has failed the plebs are revolting")
    print("ERROR:taxi fail")
  else
    self:TaxiEnterState(_cTAXIFAIL)
  end
end

function SabTaskObjectiveDeliver:CallbackStateTaxiTrigEnter(tTriggerTable, bPickup, tWaitFors)
  local hTrigger = tTriggerTable[1]
  local hTaxiPassenger = tTriggerTable[2]
  local tConfig = self:GetConfig()
  local tPassengers = tWaitFors
  local hTaxi = Actor.GetVehicle(hSab)
  if hTaxi then
    if bPickup then
      self:TaxiEnterState(_cTAXISTOPPICK)
    else
      self:TaxiEnterState(_cTAXISTOPDROP)
    end
  elseif not hTaxi and tConfig.bNoCarRequired then
    print("CallbackStateTaxiTrigEnter: no player car found and no car required")
    if bPickup then
      self:TaxiEnterState(_cTAXISTOPPICK)
    else
      self:TaxiEnterState(_cTAXISTOPDROP)
    end
  elseif bPickup then
    self:TaxiEnterState(_cTAXIFETCHPICK)
  else
    self:TaxiEnterState(_cTAXIFETCHDROP)
  end
end

function SabTaskObjectiveDeliver:CallbackStateProxEnter(bPickup, hPass)
  print("CallbackStateProxEnter: ", bPickup)
  local tConfig = self:GetConfig()
  local hTaxi = Actor.GetVehicle(hSab)
  if hTaxi then
    if bPickup then
      self:TaxiEnterState(_cTAXISTOPPICK)
    else
      self:TaxiEnterState(_cTAXISTOPDROP)
    end
  elseif not hTaxi and tConfig.bNoCarRequired then
    print("CallbackStateProxEnter: no player car found and no car required")
    if bPickup then
      self:TaxiEnterState(_cTAXISTOPPICK)
    else
      self:TaxiEnterState(_cTAXISTOPDROP)
    end
  elseif bPickup then
    self:TaxiEnterState(_cTAXIFETCHPICK)
  else
    self:TaxiEnterState(_cTAXIFETCHDROP)
  end
end

function SabTaskObjectiveDeliver:StartTaxiEscalationListener()
  local CurrentEscalation = Suspicion.GetEscalation()
  if 0 < CurrentEscalation then
    self:TaxiEnterState(_cLOSE_ESCALATION)
  else
    EVENT_OnEscalation("SabTaskObjectiveDeliver.CallbackTaxiOnEscalation", self, {})
  end
end

function SabTaskObjectiveDeliver:CallbackTaxiOnEscalation(tArgs)
  self:TaxiEnterState(_cLOSE_ESCALATION)
end

function SabTaskObjectiveDeliver:SetupTaxiEscalationFree()
  local tConfig = self:GetConfig()
  print("SetupTaxiEscalationFree")
  self._bTriggerDeliverSet = false
  self:_CleanTriggerEvents()
  self._bTaxiInEscalationState = true
  local hMessage = self:GetTaskObjectiveID()
  local sNewString = self:GetLocalizedText("GenericObjective_Text.Escalation_Lose")
  HUD.KeepObjectivesVisible(true)
  if not _g_b_ImInChargeOfObjectiveVisiblity then
    HUD.KeepObjectivesVisible(true)
  end
  if tConfig.sEscalationID and tConfig.sEscalationID ~= "" then
    sNewString = self:GetLocalizedText(tConfig.sEscalationID)
  end
  local bClearGPS = false
  self:_ClearGPS()
  self:BlipDestinations(false)
  if hMessage and sNewString and sNewString ~= "" then
    HUD.SetObjectiveText(hMessage, sNewString)
  end
  EVENT_EscalationFree("SabTaskObjectiveDeliver.TaxiEscalationFree", self, {}, false)
end

function SabTaskObjectiveDeliver:TaxiEscalationFree()
  print("taxi lost escalation")
  local tConfig = self:GetConfig()
  if not _g_b_ImInChargeOfObjectiveVisiblity then
    HUD.KeepObjectivesVisible(false)
  end
  self._bTaxiInEscalationState = false
  if tConfig.bVehicleIsRequired then
    self._bGPSTarget = false
    self:TaxiEnterState(_cTAXIFETCHPICK)
  else
    self:TaxiEnterState(_cTAXIFETCHDROP)
  end
end

function SabTaskObjectiveDeliver:TaxiRouter(bPickup)
  local myTaxiState = self.TaxiDeliverState
  local tConfig = self:GetConfig()
  if bPickup then
    self._bTriggerDeliverSet = false
    self:_CleanTriggerEvents()
  end
  local hTaxi = Actor.GetVehicle(hSab)
  for _, Obj in pairs(tConfig.tDeliverObjs) do
    local hObj = WRAPPER_CheckForHandle(Obj)
    if Object.IsVehicle(hObj) or hObj == hSab then
    else
      self:SetFollowerType(hObj, 2)
      Actor.SetVehicleAvoidance(hObj, false)
      if self.TaxiDeliverState == _cTAXIWAITFORLOAD then
        if hObj then
          self._tSuperTaxiPassengers[hObj] = _cPASS_LOADING
        end
        if not hTaxi and tConfig.bNoCarRequired then
          print("Player not in car, no car required")
          self:SetupOnEnterTaxi(hObj)
          self:CallbackStatePickedUpSuccess(hObj)
        elseif Actor.IsInVehicle(hObj, true) and Actor.GetVehicle(hObj) == Actor.GetVehicle(hSab) then
          print("TaxiRouter: passenger is already in the vehicle :continuing ", "STATE ", self.TaxiDeliverState)
          if self.__eTaxiEvents.OnEnterVeh[hObj] then
            Util.KillEvent(self.__eTaxiEvents.OnEnterVeh[hObj])
          end
          self.__eTaxiEvents.OnEnterVeh[hObj] = nil
          self:PassengerEnteredStateTaxiPickup({hObj}, hObj)
        else
          print("TaxiRouter: passenger is not in the vehicle :waiting for pickup ", "STATE ", self.TaxiDeliverState)
          local hTaxi = Actor.GetVehicle(hSab)
          if self.__eTaxiEvents.OnEnterVeh[hObj] then
            Util.KillEvent(self.__eTaxiEvents.OnEnterVeh[hObj])
          end
          self.__eTaxiEvents.OnEnterVeh[hObj] = EVENT_ActorEntersAnyVehicle("SabTaskObjectiveDeliver.PassengerEnteredStateTaxiPickup", self, hObj, hObj)
        end
        self:RunCallbacksTable(tConfig.tOnWait)
      elseif self.TaxiDeliverState == _cTAXIDROPOFF then
        if self.__eTaxiEvents.OnExitVeh[hObj] then
          print("TaxiRouter clearing self.__eTaxiEvents.OnExitVeh[ hPassenger ], ", hObj)
          Util.KillEvent(self.__eTaxiEvents.OnExitVeh[hObj])
        end
        print("TaxiRouter SetupActorExits listener ", "STATE ", self.TaxiDeliverState)
        self.__eTaxiEvents.OnExitVeh[hObj] = EVENT_ActorExitsAnyVehicle("SabTaskObjectiveDeliver.PassengerExitedTaxi", self, hObj, hObj)
        if hObj and Actor.IsInVehicle(hObj, true) then
          self:SetUIBlips(hObj, false, true)
        end
      end
    end
  end
  if myTaxiState and myTaxiState == _cTAXIDROPOFF then
    local tCallbacks = tConfig.tOnPickup
    if not self._bRanOnPickupCallbacks then
      self._bRanOnPickupCallbacks = true
      self:RunCallbacksTable(tConfig.tOnPickup)
    end
    self:_ClearGPS()
    if tConfig.vGPSTarget then
      tConfig.vGPSTarget = nil
    end
    print("-- blipping destination")
    self:BlipDestinations(true)
  end
end

function SabTaskObjectiveDeliver:PassengerEnteredStateTaxiPickup(tArgs, hPassenger)
  if hPassenger then
    self._tSuperTaxiPassengers[hPassenger] = _cPASS_LOADED
    if self.__eTaxiEvents.OnEnterVeh[hPassenger] then
      self.__eTaxiEvents.OnEnterVeh[hPassenger] = nil
    end
    self:SetUIBlips(hPassenger, false, true)
    EVENT_Timer("SabTaskObjectiveDeliver.CallbackStatePickedUpSuccess", self, 0.3, hPassenger)
  end
end

function SabTaskObjectiveDeliver:CallbackStatePickedUpSuccess(hActivator)
  local tConfig = self:GetConfig()
  local hTaxi = Actor.GetVehicle(hSab)
  if self.__eTAXIFETCH then
    print("*** CallbackStatePickedUpSuccess killing player exit car event ** ")
    Util.KillEvent(self.__eTAXIFETCH)
    self.__eTAXIFETCH = nil
  end
  if not self.__tPassengersLoaded[hActivator] then
    self.__TotalPassengersLoaded = self.__TotalPassengersLoaded + 1
    self.__tPassengersLoaded[hActivator] = true
  end
  if self._vPickupGPS and Handle(self._vPickupGPS) == hActivator then
    print("Passenger was gps target.. clearing flag")
    self._vPickupGPS = nil
  end
  local totalpassengers = 0
  for i, obj in pairs(tConfig.tDeliverObjs) do
    if not Object.IsVehicle(Handle(obj)) and Handle(obj) ~= hSab then
      totalpassengers = totalpassengers + 1
    else
    end
  end
  print("total loaded = ", self.__TotalPassengersLoaded)
  if totalpassengers <= self.__TotalPassengersLoaded then
    print("all aboard taxi loaded")
    self:ReleaseVehicle(hTaxi)
    self:TaxiEnterState(_cTAXIDROPOFF)
  end
end

function SabTaskObjectiveDeliver:StartTaxiAbandon()
  local tConfig = self:GetConfig()
  self:_ClearAllAbandon()
  for i, obj in pairs(tConfig.tDeliverObjs) do
    local hObj = Handle(obj)
    if hObj then
      local eFailEvent = EVENT_PlayerToActorProximityNegated("SabTaskObjectiveDeliver._FailTaxiAbandon", self, hObj, self._AbandonFailDistance, hObj, true, true)
      self._tAbandonEvents[hObj] = eFailEvent
    end
  end
end

function SabTaskObjectiveDeliver:_ClearAbandon(vPassenger)
  local hObj = Handle(vPassenger)
  if self._tAbandonEvents[hObj] then
    Util.KillEvent(self._tAbandonEvents[hObj])
  end
end

function SabTaskObjectiveDeliver:_ClearAllAbandon()
  if self._tAbandonEvents then
    for hObj, dDAta in pairs(self._tAbandonEvents) do
      self:_ClearAbandon(hObj)
    end
  end
end

function SabTaskObjectiveDeliver:_FailTaxiAbandon(hObj)
  local sCodePlayersInterior = Util.GetPlayersInterior()
  local sScriptPlayersInterior = InteriorManager.GetPlayersInterior()
  print("+++ code players int ", sCodePlayersInterior, " script int ", sScriptPlayersInterior)
  if sCodePlayersInterior == nil and sScriptPlayersInterior == "" then
    print("PASSENGER ABANDONED!!!! ", hObj)
    local sMessage = "GenericFail_Text.ABANDON_GEN_Follower"
    if Object.IsVehicle(hObj) then
      sMessage = "GenericFail_Text.ABANDON_GEN_ImportantVehicle"
    end
    self:MissionTaskFail(sMessage)
  end
end

function SabTaskObjectiveDeliver:SetFollowerType(hFollower, Proximity)
  local Proximity = Proximity or 2
  local tConfig = self:GetConfig()
  if hFollower then
    Nav.CancelFollowObject(hFollower)
    if hFollower and Combat.IsCombatant(hFollower) then
      Combat.SetIdleScripted(hFollower, true)
      Combat.SetLeader(hFollower, hSab, tConfig.bWimpy)
    elseif hFollower then
      Nav.FollowObject(hFollower, hSab, Proximity, true)
    end
    AddSabFollower(self, hFollower)
  end
end

function SabTaskObjectiveDeliver:ClearFollowerType(hFollower)
  if hFollower then
    if hFollower and Combat.IsCombatant(hFollower) then
      if self._SabSquadDeliverID then
        print("removing combat follower\tfrom squad name: ", self._SabSquadDeliverID, self:GetName())
        Squad.RemoveMember(self._SabSquadDeliverID, hFollower)
      end
      Combat.ClearLeader(hFollower)
    elseif hFollower then
      print("removing civ follower\t", self:GetName())
      Nav.CancelFollowObject(hFollower)
    end
  end
  RemoveSabFollower(self, hFollower)
end

function SabTaskObjectiveDeliver:TaxiDeliverFadeOut()
  print("taxi fade out")
  EVENT_FadeInOut(2.75)
  Util.CreateEvent({EventType = "TimerEvent", Time = 1.65}, "SabTaskObjectiveDeliver.FadeOutDone", self, {})
end

function SabTaskObjectiveDeliver:FadeOutDone()
  print("taxi fade out done")
  local tConfig = self:GetConfig()
  self:RunCallbacksTable(tConfig.tReadyForUnload)
  local hTaxi = Actor.GetVehicle(hSab)
  if hTaxi then
    self:ReleaseVehicle(hTaxi)
  end
  self:ClearVehControls()
  self:SubObjectiveCompleted()
end

function SabTaskObjectiveDeliver:StartEnterExitInterior(bExit)
  local tConfig = self:GetConfig()
  self:SetQuota(self:GetQuota() + 1)
  local sCurrentInterior = InteriorManager.GetPlayersInterior()
  if bExit then
    if sCurrentInterior ~= tConfig.sInteriorName then
      local sPlayerInterior = Util.GetPlayersInterior()
      if sPlayerInterior == tConfig.sInteriorName then
        print("DEBUG:code still thinks we are in the interior ", sPlayerInterior)
      else
        print("DEBUG:player is outside of requested exitable interior already, autocompleteing")
        self:CallbackEnterExitInterior()
        return
      end
    end
    local tInterior
    if sCurrentInterior then
      tInterior = InteriorManager.GetInteriorTable(sCurrentInterior)
      if tInterior and tInterior.bHQ and tInterior.sIntTeleLoc then
        self:SetUIBlips(tInterior.sIntTeleLoc, true)
      end
    end
  elseif sCurrentInterior == tConfig.sInteriorName then
    local sPlayerInterior = Util.GetPlayersInterior()
    if sPlayerInterior ~= tConfig.sInteriorName then
      print("DEBUG:code still thinks we are outside interior ", sPlayerInterior)
    else
      print("DEBUG:player is inside of requested interior already, autocompleteing")
      self:CallbackEnterExitInterior()
      return
    end
  end
  Util.AddInteriorLoadCallback(tConfig.sInteriorName, "SabTaskObjectiveDeliver.CallbackEnterExitInterior", self)
  self._bHasInteriorCallbacks = true
end

function SabTaskObjectiveDeliver:CallbackEnterExitInterior()
  local tConfig = self:GetConfig()
  self._bHasInteriorCallbacks = false
  EVENT_Timer("SabTaskObjective.SubObjectiveCompleted", self, 0.1)
end
