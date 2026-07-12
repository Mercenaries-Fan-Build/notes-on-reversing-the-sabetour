if SeptemberTrailer == nil then
  SeptemberTrailer = SabTaskObjective:Create()
  SeptemberTrailer:Configure({
    TaskCount = "9999",
    bStarterless = true,
    tSMEDNodes = {}
  })
end

function SeptemberTrailer:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function SeptemberTrailer:GENERAL_Setup()
  self.sDebugLabel = "TRAILER"
  self.bDebugMode = false
  self.tUPCounter = 0
  self.tDOWNCounter = 0
  self.tLEFTCounter = 0
  self.bDisable = false
  self.bRainisOn = false
  self.bDisableRun = false
  self.tLockedControls = {InventoryChange = true}
  self.tUnlockedControls = {InventoryChange = false}
  self.tBoomLocs = {
    "Missions\\freeplay\\trailer1\\shot6stuff\\BoomLoc(18)",
    "Missions\\freeplay\\trailer1\\shot6stuff\\BoomLoc(21)",
    "Missions\\freeplay\\trailer1\\shot6stuff\\BoomLoc(22)",
    "Missions\\freeplay\\trailer1\\shot6stuff\\BoomLoc",
    "Missions\\freeplay\\trailer1\\shot6stuff\\BoomLoc(2)",
    "Missions\\freeplay\\trailer1\\shot6stuff\\BoomLoc(4)",
    "Missions\\freeplay\\trailer1\\shot6stuff\\BoomLoc(5)",
    "Missions\\freeplay\\trailer1\\shot6stuff\\BoomLoc(7)",
    "Missions\\freeplay\\trailer1\\shot6stuff\\BoomLoc(9)",
    "Missions\\freeplay\\trailer1\\shot6stuff\\BoomLoc(11)",
    "Missions\\freeplay\\trailer1\\shot6stuff\\BoomLoc(13)",
    "Missions\\freeplay\\trailer1\\shot6stuff\\BoomLoc(15)",
    "Missions\\freeplay\\trailer1\\shot6stuff\\BoomLoc(17)",
    "Missions\\freeplay\\trailer1\\shot6stuff\\BoomLoc(19)",
    "Missions\\freeplay\\trailer1\\shot6stuff\\BoomLoc(20)",
    "Missions\\freeplay\\trailer1\\shot6stuff\\BoomLoc(16)",
    "Missions\\freeplay\\trailer1\\shot6stuff\\BoomLoc(12)"
  }
  self.tNaziCrowd = {
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_SS_Heavy_MG(10)",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_SS_Heavy_MG",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_SS_Heavy_MG(1)",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_SS_Heavy_MG(2)",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_SS_Heavy_MG(3)",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_SS_Heavy_MG(4)",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_SS_Heavy_MG(5)",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_SS_Heavy_MG(6)",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_SS_Heavy_MG(7)",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_SS_Heavy_MG(8)",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_SS_Heavy_MG(9)",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_WM_Grunt_MG",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_WM_Grunt_MG(1)",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_WM_Grunt_MG(2)",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_WM_Grunt_MG(3)",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_WM_Grunt_MG(4)",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_WM_Grunt_MG(5)",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_WM_Grunt_MG(6)",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_WM_Grunt_MG(7)",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_WM_Grunt_MG(8)",
    "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_WM_Grunt_MG(9)"
  }
  self.sNaziSpeaker = "Missions\\freeplay\\trailer1\\shot8stuff\\Spore_GS_General_PS"
  self.nBoom = 1
  self:SelectGamePadListener()
end

function SeptemberTrailer:SilentGPListener()
  local tMenuEvent = {
    EventType = "OnButtonPress",
    EventName = "SilentMenu",
    Target = Handle("Saboteur")
  }
  Util.CreateEvent(tMenuEvent, "SeptemberTrailer.OpenMenu", self, {}, true)
end

function SeptemberTrailer:OpenMenu(a_tButtonData)
  local tButtons = a_tButtonData[1]
end

function SeptemberTrailer:SetupShot1Listener()
  dprint(self, "Shot 1 Activated")
  Util.SpawnEditNode("Missions\\freeplay\\trailer1\\shot1stuff.wsd", "SeptemberTrailer.SetupShot1ControllerConfig", self)
end

function SeptemberTrailer:SetupShot1ControllerConfig()
  local tControllerEvent = {
    EventType = "OnButtonPress",
    EventName = "MainMenu",
    Target = Handle("Saboteur")
  }
  Util.CreateEvent(tControllerEvent, "SeptemberTrailer.OnButtonPress", self, {}, true)
end

function SeptemberTrailer:OnButtonPress(a_tButtonData)
  local tButtons = a_tButtonData[1]
  if tButtons.UP == true then
    dprint(self, "Lightning is on")
    self.GoGoLightning(self)
  elseif tButtons.DOWN == true then
    dprint(self, "Smoking should be on")
    Actor.ForceSmoking(hSab)
  elseif tButtons.RIGHT == true then
    dprint(self, "GoGoPlanes")
    Cin.PlayCinematic("TrailerPlanes")
  elseif tButtons.LEFT == true then
    dprint(self, "Drinking should be on")
    Actor.ForceLongIdle("idle_drink_from_flask", hSab, nil)
  end
  if tButtons.A == true then
    dprint(self, "you hit a")
  end
  if tButtons.Y == true then
    if self.bDisable == false then
      dprint(self, "Disabling Inventory Input")
      self.bDisable = true
      self.DisableStuff(self)
    elseif self.bDisable == true then
      dprint(self, "Reenabling Inventory Input")
      self.bDisable = false
      self.EnableStuff(self)
    end
  end
  if tButtons.B == true then
    dprint(self, "Resetting Counter, starting selection")
    Actor.EnableAllLongIdles(false, hSab)
  end
end

function SeptemberTrailer:GoGoLightning()
  Render.EnableLightning(true)
end

function SeptemberTrailer:DisableStuff()
  Util.SetDisableControls("InventoryChange", true)
end

function SeptemberTrailer:EnableStuff()
  Util.SetDisableControls("InventoryChange", false)
end

function SeptemberTrailer:SelectGamePadListener()
  dprint(self, "Waiting for Loc Stream, selecting Loc")
  local tNumberOne = {
    EventType = "StreamEvent",
    EventName = "EventOne",
    Objects = {
      "Missions\\freeplay\\trailer1\\Shot1Loc"
    }
  }
  Util.CreateEvent(tNumberOne, "SeptemberTrailer.SetupShot1Listener", self)
  local tNumberSix = {
    EventType = "StreamEvent",
    EventName = "EventSix",
    Objects = {
      "Missions\\freeplay\\trailer1\\Shot6Loc"
    }
  }
  Util.CreateEvent(tNumberSix, "SeptemberTrailer.SetupShot6Listener", self)
  local tNumberEight = {
    EventType = "StreamEvent",
    EventName = "EventEight",
    Objects = {
      "Missions\\freeplay\\trailer1\\Shot8Loc"
    }
  }
  Util.CreateEvent(tNumberEight, "SeptemberTrailer.SetupShot8Listener", self)
end

function SeptemberTrailer:SetupShot6Listener()
  dprint(self, "Shot 6 Activated")
  Util.SpawnEditNode("Missions\\freeplay\\trailer1\\shot6stuff.wsd", "SeptemberTrailer.SetupShot6ControllerConfig", self)
end

function SeptemberTrailer:SetupShot6ControllerConfig()
  dprint(self, "Mapping Shot 6 hotkeys")
  local tShot6Config = {
    EventType = "OnButtonPress",
    EventName = "Shot6Config",
    Target = Handle("Saboteur")
  }
  Util.CreateEvent(tShot6Config, "SeptemberTrailer.Shot6Press", self, {}, true)
end

function SeptemberTrailer:Shot6Press(a_tButtonData)
  local tButtons6 = a_tButtonData[1]
  if tButtons6.UP == true then
  elseif tButtons6.DOWN == true then
    dprint(self, "smoking is on")
    Actor.ForceSmoking(hSab)
  elseif tButtons6.RIGHT == true then
    dprint(self, "BOOM!")
    self:MachineGoBoom()
  elseif tButtons6.LEFT == true then
    dprint(self, "Drinking should be on")
    Actor.ForceLongIdle("idle_drink_from_flask", hSab, nil)
  end
  if tButtons6.A == true then
    dprint(self, "you hit a")
  end
  if tButtons6.Y == true then
    if self.bDisable == false then
      dprint(self, "Disabling Inventory Input")
      self.bDisable = true
      self.DisableStuff(self)
    elseif self.bDisable == true then
      dprint(self, "Reenabling Inventory Input")
      self.bDisable = false
      self.EnableStuff(self)
    end
  end
  if tButtons6.B == true then
    if self.bDisableRun == false then
      dprint(self, "Disabling Run Input")
      self.bDisableRun = true
      Util.SetDisableControls("Sprint", true)
      Util.SetDisableControls("Run", true)
      DisableHQAbilities(true)
    elseif self.bDisableRun == true then
      dprint(self, "Reenabling Run Input")
      self.bDisableRun = false
      DisableHQAbilities(false)
      Util.SetDisableControls("Sprint", true)
      Util.SetDisableControls("Run", true)
    end
  end
end

function SeptemberTrailer:MachineGoBoom()
  local sBoomLoc = self.tBoomLocs[self.nBoom]
  if self.nBoom < #self.tBoomLocs then
    local x, y, z = Object.GetPosition(Util.GetHandleByName(sBoomLoc))
    local nTime = math.random(0.5, 1)
    Util.CreateExplosion("Explosion_Medium", x, y, z)
    self.nBoom = self.nBoom + 1
    EVENT_Timer("SeptemberTrailer.MachineGoBoom", self, nTime)
  else
    self.nBoom = 1
  end
end

function SeptemberTrailer:SetupShot8Listener()
  dprint(self, "Shot 8 selected, passing on to listeners")
  Util.SpawnEditNode("Missions\\freeplay\\trailer1\\shot8stuff.wsd", "SeptemberTrailer.SetupShot8ControllerConfig", self)
end

function SeptemberTrailer:SetupShot8ControllerConfig()
  dprint(self, "Mapping Shot 8 hotkeys")
  local tShot8Config = {
    EventType = "OnButtonPress",
    EventName = "Shot6Config",
    Target = Handle("Saboteur")
  }
  Util.CreateEvent(tShot8Config, "SeptemberTrailer.Shot8Press", self, {}, true)
end

function SeptemberTrailer:Shot8Press(a_tButtonData)
  local tButtons8 = a_tButtonData[1]
  if tButtons8.UP == true then
    dprint(self, "Start speaker...!")
    self:RunSpeakerAnims()
  elseif tButtons8.DOWN == true then
    dprint(self, "smoking is on")
    Actor.ForceLongIdle("cross_arms_loop", hSab, nil)
  elseif tButtons8.RIGHT == true then
    dprint(self, "We'll always have Paris...")
    Object.Kill(Util.GetHandleByName(self.sNaziSpeaker))
  elseif tButtons8.LEFT == true then
    dprint(self, "Hail!!")
    self:RunSequences()
  end
  if tButtons8.A == true then
    dprint(self, "you hit a")
  end
  if tButtons8.L1 == true then
    dprint(self, "you hit Lbumper")
  end
  if tButtons8.Y == true then
  end
  if tButtons8.B == true then
    if self.bDisableRun == false then
      dprint(self, "Disabling Run Input")
      self.bDisableRun = true
      DisableHQAbilities(true)
      Util.SetDisableControls("Sprint", true)
      Util.SetDisableControls("Run", true)
    elseif self.bDisableRun == true then
      dprint(self, "Reenabling Run Input")
      self.bDisableRun = false
      DisableHQAbilities(false)
      Util.SetDisableControls("Sprint", false)
      Util.SetDisableControls("Run", false)
    end
  end
end

function SeptemberTrailer:RunSequences()
  local tGroupSequence = {
    {
      "PLAYANIMATION",
      {"nazi_hail"}
    },
    {
      "DELAY",
      {3}
    }
  }
  for i = 1, #self.tNaziCrowd do
    local hNazi = Util.GetHandleByName(self.tNaziCrowd[i])
    ScriptSequence.Run(hNazi, tGroupSequence)
  end
end

function SeptemberTrailer:RunSpeakerAnims()
  local tSpeakerSequence = {
    {
      "PLAYANIMATION",
      {"nazi_point"}
    },
    {
      "DELAY",
      {2}
    },
    {
      "PLAYANIMATION",
      {"nazi_point"}
    },
    {
      "DELAY",
      {3}
    }
  }
  local hSpeaker = Util.GetHandleByName(self.sNaziSpeaker)
  ScriptSequence.Run(hSpeaker, tSpeakerSequence)
end
