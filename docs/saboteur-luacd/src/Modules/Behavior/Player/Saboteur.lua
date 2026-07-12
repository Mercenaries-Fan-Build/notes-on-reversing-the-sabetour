Saboteur = Saboteur or {}

function Saboteur:OnEnter()
  require("Includes\\__SabMissionIncludes")
  require("Includes\\WRAPPER_Event")
  if self.tStatistics == nil then
    self.tStatistics = {}
    self.tStatistics.nNaziKillCount = 0
    self.tStatistics.nComboKill = 0
    self.tStatistics.nCivilianKillCount = 0
    self.tStatistics.nCivilianSaved = 0
    self.tStatistics.nAlarmsCut = 0
    self.tStatistics.nAlarmsFired = 0
    self.tStatistics.nSupplyCrate = 0
    self.tStatistics.nFlagsCut = 0
    self.tStatistics.nNaziAssassCount = 0
    self.tStatistics.bBeChase = false
    self.tStatistics.bAmbientOn = true
  end
  Actor.SetLabel(self.hController, "Human", true)
  Actor.SetLabel(self.hController, "Player", true)
  self.tFollowerList = {}
  hSab = self.hController
  if PlayerInvincible then
    Object.SetInvincible(Util.GetHandleByName("Saboteur"), true)
  end
  Squad.Create("Saboteur")
  Squad.AddMember("Saboteur", self.hController)
  self.sDebugLabel = "SAB"
  self.bDebugMode = false
  self.bInInterior = false
  self.sPlayersCurrentInterior = ""
  self.bUnlockedBackupStrike = false
  self.nTokencount = 65
  self.nMaxTokencount = 65
  self.nMaxTokens = 64
  self.sPlayerState = "normal"
  GameTips.Init()
  self.tZeppelinSplines = {
    "Missions\\freeplay\\p3\\amb_aa_mars_n\\zeppelin\\flightpath1",
    "Missions\\freeplay\\p3\\amb_aa_mars_n\\zeppelin\\flightpath2"
  }
  for i, sSpline in ipairs(self.tZeppelinSplines) do
  end
  self.tPlayerLabels = {}
  Inventory.GiveItem(self.hController, "Papers_P1", false)
end

function Saboteur.AddTriggerLabels(sLabel)
  Actor.SetLabel(hSab, sLabel, true)
  local tempself = Actor.GetSelf(hSab)
  if tempself.tPlayerLabels[sLabel] == nil then
    tempself.tPlayerLabels[sLabel] = 1
  else
    tempself.tPlayerLabels[sLabel] = tempself.tPlayerLabels[sLabel] + 1
  end
end

function Saboteur.RemoveTriggerLabel(sLabel)
  local tempself = Actor.GetSelf(hSab)
  if tempself.tPlayerLabels[sLabel] == nil or tempself.tPlayerLabels[sLabel] == 0 then
    Actor.SetLabel(hSab, sLabel, false)
    tempself.tPlayerLabels[sLabel] = 0
  else
    tempself.tPlayerLabels[sLabel] = tempself.tPlayerLabels[sLabel] - 1
    if tempself.tPlayerLabels[sLabel] <= 0 then
      Actor.SetLabel(hSab, sLabel, false)
      tempself.tPlayerLabels[sLabel] = 0
    end
  end
end

function Saboteur:OnDamage(uDamageDoer, a_cDamageType)
  if a_cDamageType == 1 then
    GameTips.ShowTip("BulletTip")
  elseif a_cDamageType == 2 then
    GameTips.ShowTip("RunIntoTip")
  elseif a_cDamageType == 4 then
    GameTips.ShowTip("BlockTip")
  end
end

function Saboteur:OnWeaponFire(uWeapon)
end

function Saboteur:OnDeath(a_hDamageDoer)
  print("*** Player has died!")
  local vec3DeathLocation = {}
  vec3DeathLocation.x, vec3DeathLocation.y, vec3DeathLocation.z = Object.GetPosition(self.hController)
end

function Saboteur:OnExit()
end

function Saboteur:OnButtonPress(tButtons)
  local tSabSelf = Actor.GetSelf(hSab)
end

function Saboteur:Booyah(a_hSoldier, a_sMessage)
  Render.PrintMessage(tostring(a_hSoldier) .. " : " .. a_sMessage)
end

function Saboteur.DelayedShowDialogue(a_sDialogue, a_sUnlockMovie, a_nTime)
  local tEvent = {EventType = "TimerEvent", Time = a_nTime}
  Util.CreateEvent(tEvent, "Saboteur._DelayedShowDialogue", nil, {a_sDialogue, a_sUnlockMovie})
end

function Saboteur._DelayedShowDialogue(a_NIL, a_sDialogue, a_sUnlockMovie)
  Saboteur.ShowDialogue(a_sDialogue, a_sUnlockMovie)
end

function Saboteur.ShowDialogue(a_sDialogue, a_sUnlockMovie)
  local tSWF = {
    XPos = 0.5,
    YPos = 0.55,
    XScale = 1,
    YScale = 1,
    XAlign = cHUD_ALIGN_XCENTER,
    YAlign = cHUD_ALIGN_YCENTER,
    Duration = 2,
    Loops = 0
  }
  local tSabSelf = Tips.GetSelf("Saboteur")
  tSabSelf.hDialogueObject = HUD.AddObject(a_sDialogue, tSWF)
  tSabSelf.sQueuedUnlockMovie = a_sUnlockMovie
  local tWhooshSequence = {
    {
      "PLAYSOUND2D",
      {
        "punch_whoosh"
      }
    },
    {
      "DELAY",
      {1.75}
    },
    {
      "PLAYSOUND2D",
      {
        "punch_whoosh"
      }
    }
  }
  DestructionSequence.Run(tWhooshSequence)
end

function Saboteur.ShowUnlockMovie(a_sSWF)
  local tSWF = {
    XPos = 0,
    YPos = 0,
    XScale = 1,
    YScale = 1,
    XAlign = cHUD_ALIGN_LEFT,
    YAlign = cHUD_ALIGN_TOP,
    Duration = 2,
    Loops = 0
  }
  local tSabSelf = Tips.GetSelf("Saboteur")
  tSabSelf.hUnlockMovie = HUD.AddObject(a_sSWF, tSWF)
  local tWhooshSequence = {
    {
      "DELAY",
      {0.35}
    },
    {
      "PLAYSOUND2D",
      {
        "punch_whoosh"
      }
    }
  }
  DestructionSequence.Run(tWhooshSequence)
  local tEvent = {EventType = "TimerEvent", Time = 5}
  Util.CreateEvent(tEvent, "Saboteur._ShowUnlockMovie", tSabSelf)
end

function Saboteur:_ShowUnlockMovie()
  HUD.RemoveObject(self.hUnlockMovie)
end

function Saboteur:LoadVehBank()
  Sound.LoadSoundBank("Vehicles.bnk")
end

function Saboteur.ShowCancelTip()
  local tSWF = {
    XPos = 0.34,
    YPos = 0.7475,
    XScale = 1,
    YScale = 1,
    XAlign = cHUD_ALIGN_XCENTER,
    YAlign = cHUD_ALIGN_YCENTER,
    Duration = 1,
    Loops = 0
  }
  local tSabSelf = Tips.GetSelf("Saboteur")
  if tSabSelf.hFlashCancelTip ~= nil then
    HUD.RemoveObject(tSabSelf.hFlashCancelTip)
    tSabSelf.hFlashCancelTip = nil
  end
  tSabSelf.hFlashCancelTip = HUD.AddObject("cancel", tSWF)
end

function Saboteur.ShowToolTip(a_sTextID, a_TimerOverride, s_TopicOverride, b_Override)
  local a_Timer = a_TimerOverride or 20
  local s_Topic = s_TopicOverride or a_sTextID .. "_Title"
  local b_Super = b_Override or false
  Util.QueueTutorial(s_Topic, a_sTextID, a_Timer, b_Super)
end

function Saboteur.ShowMultiTip(a_tPages)
  local tSabSelf = Tips.GetSelf("Saboteur")
  if tSabSelf.bMultiTipOn == true then
    HUD.ClearTutorialText()
    tSabSelf.bMultiTipOn = false
  end
  tSabSelf.tMultiTip = a_tPages
  tSabSelf.nCurrentMultiTipPage = 1
  HUD.SetTutorialText(0, a_tPages[1], cSOLDIER_JUMP)
  tSabSelf.bMultiTipOn = true
  local tWhooshSequence = {
    {
      "DELAY",
      {0.25}
    },
    {
      "PLAYSOUND2D",
      {
        "punch_whoosh"
      }
    }
  }
  DestructionSequence.Run(tWhooshSequence)
end

function Saboteur.UpdateMultiPageTip()
  local tSabSelf = Tips.GetSelf("Saboteur")
  if tSabSelf.bMultiTipOn == true then
    if tSabSelf.nCurrentMultiTipPage + 1 > #tSabSelf.tMultiTip then
      HUD.ClearTutorialText()
      tSabSelf.bMultiTipOn = true
      tSabSelf.tMultiTip = nil
      tSabSelf.nCurrentMultiTipPage = 1
      Util.Pause(false)
    else
      tSabSelf.nCurrentMultiTipPage = tSabSelf.nCurrentMultiTipPage + 1
      HUD.SetTutorialText(0, tSabSelf.tMultiTip[tSabSelf.nCurrentMultiTipPage], cSOLDIER_JUMP)
    end
  end
end

function Saboteur:PrintStatistics()
  Render.PrintDialogue(self.hController, "I've killed " .. self.tStatistics.nNaziKillCount .. " Nazi pigs.", 2)
end

function Saboteur:OnVehicleExit(a_hVehicle)
end

function Saboteur:OnPaperCheckSuccess()
end

function Saboteur:OnPaperCheckFail()
end

function Saboteur.FillTokens()
  local tSabSelf = Tips.GetSelf("Saboteur")
  local nMaxTokens = tSabSelf.nMaxTokens
  local nCurrentTokens = Inventory.GetAmmoCount(tSabSelf.hController, "WTF_Token")
  local nNeededTokens = nMaxTokens - nCurrentTokens
  if nNeededTokens ~= 0 then
    Inventory.GiveAmmo(tSabSelf.hController, "WTF_Token", nNeededTokens)
    Tips.Print(tSabSelf, "Sab will have " .. nMaxTokens .. " WTF tokens on the next frame")
  end
end

function Saboteur.GetTokens()
  local tSabSelf = Tips.GetSelf("Saboteur")
  return Inventory.GetAmmoCount(tSabSelf.hController, "WTF_Token")
end

function Saboteur.DecrementToken()
  local tSabSelf = Tips.GetSelf("Saboteur")
  if Inventory.GetAmmoCount(tSabSelf.hController, "WTF_Token") > 0 then
    local hToken = Inventory.GiveAmmo(tSabSelf.hController, "WTF_Token", -1)
  end
end

function Saboteur.GetMaxTokens()
  local tSabSelf = Tips.GetSelf("Saboteur")
  return tSabSelf.nMaxTokens
end

function Saboteur.SetMaxTokens(a_nTokens)
  local tSabSelf = Tips.GetSelf("Saboteur")
  tSabSelf.nMaxTokens = a_nTokens
end

function Saboteur.IncrementMaxTokens(a_nTokens)
  local tSabSelf = Tips.GetSelf("Saboteur")
  Saboteur.SetMaxTokens(Saboteur.GetMaxTokens() + a_nTokens)
end

function Saboteur.UseTokens(a_nToken)
  local tSabSelf = Tips.GetSelf("Saboteur")
  if a_nToken > Saboteur.GetTokens() then
    return false
  else
    local nToken = a_nToken * -1
    Inventory.GiveAmmo(tSabSelf.hController, "WTF_Token", nToken)
    return true
  end
end

function Saboteur.DisplayTokens()
  local tSabSelf = Tips.GetSelf("Saboteur")
  local sMessage = "You have " .. Saboteur.GetTokens() .. "/" .. tSabSelf.nMaxTokens .. " WTF Tokens"
  HUD.AddUpdateBoxText(sMessage, 5)
end

function Saboteur.OnCivilianDeath()
  local tSabSelf = Tips.GetSelf("Saboteur")
  if not tSabSelf.nCiviliansKilled then
    tSabSelf.nCiviliansKilled = 1
  else
    tSabSelf.nCiviliansKilled = tSabSelf.nCiviliansKilled + 1
  end
  if tSabSelf.nCiviliansKilled % 2 == 0 then
    Render.PrintMessage("Take a token away. " .. tSabSelf.nCiviliansKilled .. " total civs killed")
    if 0 < Saboteur.GetTokens() then
      Saboteur.DecrementToken(1)
      HUD.AddUpdateBoxText("You've lost 1 WTF token for killing civilians!", 3)
    end
  end
end

Saboteur.cEscalationBackupDistance = 20
Saboteur.cEscalationBackup = {
  "OpelCanvas_MP40_Full",
  "OpelCanvas_MP40_Full",
  "OpelCanvas_MP40_Full"
}

function Saboteur:OnEscalation0()
  GameTips.ShowTip("EscalationClear")
end

function Saboteur:OnEscalation1()
  GameTips.ShowTip("EscalationStart")
end

function Saboteur:OnEscalation2()
end

function Saboteur:OnEscalation3()
end

function Saboteur:OnEscalation4()
end

function Saboteur:OnEscalation5()
end

function Saboteur:OnEscalationNoOneRed()
  GameTips.ShowTip("EscalationNoOneRed")
end

function Saboteur.CallEscalation(a_nLevel)
  if bEscalationSuspended == true then
    return
  end
  local tSabSelf = Tips.GetSelf("Saboteur")
  local tEvent = {EventType = "TimerEvent", Time = 5}
  Util.CreateEvent(tEvent, "Saboteur._CallEscalation", tSabSelf, {a_nLevel})
  Tips.Print(tSabSelf, "CallEscalation() -- Delaying for 5 seconds...")
end

function Saboteur:_CallEscalation(a_nLevel)
  Tips.Print(self, "_CallEscalation() -- Attempting to spawn vehicle using Object.SpawnOnRoad()")
  local x, y, z = Object.GetPosition(self.hController)
  local tKubelSeats1 = {
    Pilot = "SS_Light01",
    Shotgun = "SS_Light01",
    Passengers = {"SS_Light01", "SS_Light01"}
  }
  local tOpelSeats2 = {
    Pilot = "SS_Light01",
    Shotgun = "SS_Light01",
    Passengers = {"SS_Heavy01", "SS_Heavy01"}
  }
  local tOpelSeats3 = {
    Pilot = "SS_Light01",
    Shotgun = "SS_Terror01",
    Passengers = {
      "SS_Heavy01",
      "SS_Heavy01",
      "SS_Heavy01",
      "SS_Heavy01"
    }
  }
  local tOpelSeats4 = {
    Pilot = "SS_Terror01",
    Shotgun = "SS_Terror01",
    Passengers = {
      "SS_Terror01",
      "SS_Terror01",
      "SS_Terror01"
    }
  }
  local tOpelSeats5 = {
    Pilot = "SS_Terror01",
    Shotgun = "SS_Terror01",
    Passengers = {
      "SS_Terror01",
      "SS_Terror01",
      "SS_Terror01",
      "SS_Terror01"
    }
  }
  if a_nLevel == 1 then
    Veh.SpawnOnRoad(cVEH_KUBEL, tKubelSeats1, x, y, z, 20, false, Saboteur.OnEscalationVehicleSpawns, {a_nLevel, false})
  elseif a_nLevel == 2 then
    Veh.SpawnOnRoad(cVEH_OPEL, tOpelSeats2, x, y, z, 20, false, Saboteur.OnEscalationVehicleSpawns, {a_nLevel, false})
  elseif a_nLevel == 3 then
    Veh.SpawnOnRoad(cVEH_OPEL, tOpelSeats3, x, y, z, 30, false, Saboteur.OnEscalationVehicleSpawns, {a_nLevel, false})
  elseif a_nLevel == 4 then
    Veh.SpawnOnRoad(cVEH_HALFTRACK, "SS_Terror01", x, y, z, 20, false, Saboteur.OnEscalationVehicleSpawns, {
      a_nLevel,
      true,
      false
    })
  elseif a_nLevel == 5 then
    Veh.SpawnOnRoad(cVEH_PANZER, "SS_Heavy01", x, y, z, 30, false, Saboteur.OnEscalationVehicleSpawns, {
      a_nLevel,
      true,
      true
    })
    Veh.SpawnOnRoad(cVEH_HALFTRACK, "SS_Terror01", x, y, z, 20, false, Saboteur.OnEscalationVehicleSpawns, {
      a_nLevel,
      true,
      false
    })
  end
end

function Saboteur.OnEscalationVehicleSpawns(a_hEscalationVehicle, a_nLevel, a_bHostileVehicle, a_bAttackOnly)
  if not a_bAttackOnly or a_bAttackOnly == false then
    local tSabSelf = Tips.GetSelf("Saboteur")
    Tips.Print(tSabSelf, "OnEscalationVehicleSpawns() -- Populating the vehicle and sending it to player's location")
    Vehicle.SetCrashThrough(a_hEscalationVehicle, true)
    local x, y, z = Object.GetPosition(Util.GetHandleByName("Saboteur"))
    Nav.MoveToPoint(a_hEscalationVehicle, x, y, z, false, "Saboteur.OnEscalationVehicleArrives", tSabSelf, {a_hEscalationVehicle, a_bHostileVehicle})
    Nav.SetScriptedPathSpeed(a_hEscalationVehicle, 60)
    local tFailsafe = {EventType = "TimerEvent", Time = 10}
  elseif a_bAttackOnly and a_bAttackOnly == true then
    Saboteur.CheckEscalationPilot(tSabSelf, a_hEscalationVehicle)
  end
end

function Saboteur:CheckEscalationPilot(a_vVehicle)
  Tips.Print(self, "Checking hostile escalation vehicle pilot seat.")
  local hVehicle = Handle(a_vVehicle)
  local hPilot = Vehicle.GetPilot(hVehicle)
  if hPilot ~= nil then
    Tips.Print(self, "Pilot is present. Putting them into combat.")
    Nav.FollowObject(hPilot, Handle("Saboteur"), 20, true)
    Combat.SetCombat(hPilot)
    Combat.SetTarget(hPilot, Handle("Saboteur"))
  else
    Tips.Print(self, "Pilot is not present. Recycling in 1 second.")
    Util.CreateEvent({EventType = "TimerEvent", Time = 1}, "Saboteur.CheckEscalationPilot", self, {hVehicle})
  end
end

function Saboteur:OnEscalationVehicleArrives(a_hVehicle, a_bHostileVehicle)
  Tips.Print(self, "OnEscalationVehicleArrives() -- Vehicle has arrived or failsafe has kicked in")
  if not Util.IsHandleValid(a_hVehicle) then
    return
  end
  Nav.StopMoving(a_hVehicle)
  if Object.IsAlive(a_hVehicle) and Vehicle.GetPilot(a_hVehicle) ~= nil then
    if Suspicion.GetEscalation() > 0 then
      Saboteur.RegisterEscalationGuys(self, a_hVehicle)
      VEHICLE_UnboardAllPassengers(a_hVehicle, "Saboteur.OnEscalationVehicleEmpties", self, {a_bHostileVehicle})
    else
      Vehicle.AddToTraffic(a_hVehicle)
    end
  end
  if a_bHostileVehicle == true then
    local tOccupants = Vehicle.GetOccupantList(a_hVehicle)
    if tOccupants and tOccupants.Gunners then
      for i, v in ipairs(tOccupants.Gunners) do
        Tips.Print(self, "Making vehicle gunner hostile to Saboteur.")
        Combat.SetCombat(v)
        Combat.SetTarget(v, Handle("Saboteur"))
      end
    end
  end
end

function Saboteur:RegisterEscalationGuys(a_hVehicle)
  self.tEscalationGuys = self.tEscalationGuys or {}
  local tPassengers = Vehicle.GetPassengers(a_hVehicle)
  if not tPassengers then
    return
  end
  local hPilot = Vehicle.GetPilot(a_hVehicle)
  for _, hPassenger in ipairs(tPassengers) do
    if hPilot ~= hPassenger then
      table.insert(self.tEscalationGuys, hPassenger)
    end
  end
end

function Saboteur:DespawnAllEscalationGuys()
  if not self.tEscalationGuys then
    return
  end
  for _, hGuy in ipairs(self.tEscalationGuys) do
    Object.Despawn(hGuy, 50, true)
  end
  self.tEscalationGuys = {}
end

function Saboteur:OnEscalationVehicleEmpties(a_tPassengerData, a_bHostileVehicle)
  local hSoldier = a_tPassengerData[1]
  local x, y, z = Object.GetPosition(hSoldier)
  Tips.Print(self, "OnEscalationVehicleArrives() - Unloading (" .. Util.GetNameFromHandle(hSoldier) .. ") from vehicle")
  if Suspicion.GetEscalation() > 0 then
    Combat.SetHunt(hSoldier, x, y, z, true, false, nil, nil, nil, false)
    Combat.SetTarget(hSoldier, Util.GetHandleByName("Saboteur"))
  end
  local tOccupants = Vehicle.GetOccupantList(a_tPassengerData[2])
  if tOccupants and not tOccupants.Passengers then
    if a_bHostileVehicle == false then
      Tips.Print(self, "Adding vehicle to traffic.")
      Vehicle.AddToTraffic(a_tPassengerData[2])
    elseif tOccupants.Pilot then
      Tips.Print(self, "Making pilot hostile to Sean")
      Combat.SetCombat(tOccupants.Pilot[1])
      Combat.SetTarget(tOccupants.Pilot[1], Handle("Saboteur"))
    end
  end
end

function Saboteur.Lollerskates()
  local uPlayerChar = Util.GetHandleByName("Saboteur")
  Sound.AttachSoundEvent(uPlayerChar, "vo_sean_lollerskates_cue")
end

function Saboteur:CreateDemoManager()
  if not self.hDemoManager then
    self.hDemoManager = Util.NewMission("AprilDemo", "AprilDemo")
  end
end

function Saboteur:OnSabotage(hSabItemId, hObject)
end
