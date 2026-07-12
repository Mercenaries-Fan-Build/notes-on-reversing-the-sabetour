if NOTE_AmbientFP == nil then
  NOTE_AmbientFP = SabTaskObjective:Create()
  NOTE_AmbientFP:Configure({
    bWorldEvent = true,
    bCourier = true,
    bFastComplete = true,
    MCDisplayID = cNOMISSIONCOMPLETE,
    bFinishRebuild = true,
    tUnlockList = {},
    tSMEDNodes = {}
  })
end

function NOTE_AmbientFP:STARTER_Setup()
end

function NOTE_AmbientFP:Activated()
  SabTaskObjective.Activated(self)
  self.bDebugMode = true
  self.GENERAL_Setup(self)
end

function NOTE_AmbientFP:GENERAL_Setup()
  EVENT_Timer("NOTE_AmbientFP.ContrabandLoop", self, 20)
end

function NOTE_AmbientFP:ContrabandLoop()
  local nContraband = Inventory.GetMoney()
  if nContraband < 300 then
    self:Task_MessageNeedMore()
    dprint(self, ">>>>>> Player has less than 300 Contraband. Contraband = " .. nContraband)
  elseif 300 <= nContraband then
    if Object.GetDistance(hSab, Handle("Missions\\paris_1\\characters\\belle\\santos_hideout\\LOC_santos_ext_hideout")) > 10 then
      self:Task_MessageReady()
      dprint(self, ">>>>>> WOOHOOO!!! Player has more than 300 Contraband - Send the Note!!!")
    else
      self:CompleteThisMission()
    end
  else
    dprint(self, "ERROR: Contraband is " .. nContraband)
  end
end

function NOTE_AmbientFP:Task_MessageNeedMore()
  if Suspicion.GetEscalation() == 0 then
    Cin.PlayConversation("Connect_P2_Papers_GetBusy")
    self:GENERAL_Setup()
    dprint(self, ">>>>>> PLAYER NEEDS MORE CONTRABAND")
  else
    self:GENERAL_Setup()
    dprint(self, ">>>>>> World Escalated, wait to deliver the message")
  end
end

function NOTE_AmbientFP:Task_MessageReady()
  Cin.PlayConversation("Connect_P2_Papers_Earned", "NOTE_AmbientFP.CompleteNote", self)
  dprint(self, ">>>>>> PLAYER HAS ENOUGH CONTRABAND")
end

function NOTE_AmbientFP:CompleteNote()
  self:CompleteThisMission(self)
end
