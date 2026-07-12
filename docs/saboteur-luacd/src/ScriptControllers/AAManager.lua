if not AAManager then
  AAManager = {}
end

function AAManager:OnEnter()
  self.hSab = Handle("Saboteur")
  self.bDebugMode = false
  self.sDebugLabel = "AA"
  self.sGunnerBlueprint = "Human_WM_Grunt_MG"
  self.nMinDryFireDelay = 27
  self.nMaxDryFireDelay = 29
  self.nMinCeaseFireDelay = 5
  self.nMaxCeaseFireDelay = 7
  self.nPostRaidDryFireDelay = 5
  self.nCinematicsDelay = 19
  self.bManualFireMode = false
  self.bReadyToFire = false
  self.nBlipProximity = 35
  AAManager.SetupCannonStreamEvent(self)
end

function AAManager:SetupCannonStreamEvent()
  Tips.Print(self, "Setting up cannon stream event...")
  local tCannonStreamEvent = {
    EventType = "StreamEvent",
    Objects = {
      AAManager.GetCannonName(self)
    }
  }
  self.eCannonStreamEvent = Util.CreateEvent(tCannonStreamEvent, "AAManager.OnCannonStreams", self)
end

function AAManager:OnCannonStreams()
  Tips.Print(self, "Cannon has streamed in!")
  self.eCannonStreamEvent = nil
  AAManager.SpawnGunner(self)
end

function AAManager:SetupPlayerProximityEvent(a_bNegate)
  if a_bNegate == false then
    dprint(self, "Setting up event for player getting into range of cannon.")
    local tProximityEvent = {
      EventType = "ProximityEvent",
      ObjectA = self.hSab,
      ObjectB = self.hController,
      Proximity = self.nBlipProximity
    }
    self.ePlayerEntersProximity = Util.CreateEvent(tProximityEvent, "AAManager.OnPlayerEntersProximity", self)
  else
    dprint(self, "Setting up event for player getting out of range of the cannon.")
    local tProximityEvent = {
      EventType = "ProximityEvent",
      ObjectA = self.hSab,
      ObjectB = self.hController,
      Proximity = self.nBlipProximity + self.nBlipProximity * 0.25,
      Negate = true
    }
    self.ePlayerExitsProximity = Util.CreateEvent(tProximityEvent, "AAManager.OnPlayerExitsProximity", self)
  end
end

function AAManager:OnPlayerEntersProximity()
  dprint(self, "Player has entered AA proximity.")
  Render.PrintMessage("You are near a freeplay objective. Check your minimap.")
  AAManager.SetupPlayerProximityEvent(self, true)
  local hCannon = Handle(AAManager.GetCannonName(self))
  HUD.SetObjectiveMarker(hCannon, cMMI_Objective, cOM_Objective, true, true, false)
  self.hFocusPt = FocusPt.Create(0, 1, 0, self.nBlipProximity + self.nBlipProximity * 0.25, 100, true, true, hCannon)
end

function AAManager:OnPlayerExitsProximity()
  dprint(self, "Player has exited AA proximity.")
  AAManager.SetupPlayerProximityEvent(self, false)
  HUD.RemoveObjectiveMarker(Handle(AAManager.GetCannonName(self)))
  FocusPt.Delete(self.hFocusPt)
end

function AAManager:OnCannonDestroyed()
  if self.ePlayerExitsProximity then
    Util.KillEvent(self.ePlayerExitsProximity)
  end
  if self.ePlayerEntersProximity then
    Util.KillEvent(self.ePlayerEntersProximity)
  end
  HUD.RemoveObjectiveMarker(Handle(AAManager.GetCannonName(self)))
  if self.hFocusPt then
    FocusPt.Delete(self.hFocusPt)
  end
  Tips.Print(self, "Cannon is down.")
  AAManager.DisplayNotification(self)
  AAManager.StartNodeUnloadTimer(self)
end

function AAManager:DisplayNotification()
  local nCannonsDown, nTotalCannons = AAManager.GetCannonStats(self)
  if nCannonsDown < nTotalCannons then
    local sMessage = nCannonsDown .. " of " .. nTotalCannons .. " AA cannons in this area are destroyed!"
    HUD.AddUpdateBoxText(sMessage, 10, 255, 255, 0, true)
  else
    local sMessage = "All AA cannons in this area are destroyed! Viva la Resistance!"
    HUD.AddUpdateBoxText(sMessage, 10, 255, 255, 0, true)
  end
end

function AAManager:StartNodeUnloadTimer()
  AAManager.OnUnloadTimerComplete(self)
end

function AAManager:OnUnloadTimerComplete()
  Util.UnloadStaticENTag(self.SMEDTable.sTag, true)
  AAManager.RunPostDestructionChecks(self)
end

function AAManager:RunPostDestructionChecks()
  local nCannonsDown, nTotalCannons = AAManager.GetCannonStats(self)
  if nCannonsDown == nTotalCannons then
    AAManager.OnAllCannonsDown(self)
  end
end

function AAManager:GetCannonStats()
  local nCannonsDown = 0
  local nTotalCannons = #self.SMEDTable.lsOtherTags + 1
  for i, sCannonTag in ipairs(self.SMEDTable.lsOtherTags) do
    if Util.IsCustomTagLoaded(sCannonTag) == false then
      nCannonsDown = nCannonsDown + 1
    end
  end
  return nCannonsDown + 1, nTotalCannons
end

function AAManager:OnAllCannonsDown()
  Zone.SwitchState(self.SMEDTable.sWTFZone, cZONESTATE_HIGHWTF, cENT_IMMEDIATE)
end

function AAManager:GetCannonName()
  return AAManager.GetCannonPath(self) .. "Target"
end

function AAManager:GetCannonPath()
  return self.SMEDTable.sPath
end

function AAManager:SpawnGunner()
  local hSpawnPos = Handle(AAManager.GetCannonPath(self) .. "LOC_Board")
  local x, y, z = Object.GetPosition(hSpawnPos)
  local nRot = Object.GetAngle(hSpawnPos)
  Object.Spawn(self.sGunnerBlueprint, x, y, z, nRot, nil, "AAManager.OnGunnerSpawned", self, {}, false)
end

function AAManager:OnGunnerSpawned(a_tSpawnData)
  Tips.Print(self, "Gunner has spawned!")
  self.hGunner = a_tSpawnData[1]
  AAManager.SetupRaidEvents(self)
  self.bReadyToFire = true
end

function AAManager:CollectDummyTargets()
  self.tTargets = Tips.GetListFromName(AAManager.GetCannonPath(self) .. "Target")
end

function AAManager:DespawnGunner()
  if self.hGunner then
    Object.Despawn(self.hGunner, 30, true)
  end
end

function AAManager.Get(a_vInstance)
  local tManagerSelf = -1
  if type(a_vInstance) == "table" then
    tManagerSelf = a_vInstance
  elseif type(a_vInstance) == "userdata" then
    tManagerSelf = Actor.GetSelf(a_vInstance)
  elseif type(a_vInstance) == "string" then
    tManagerSelf = Tips.GetSelf(a_vInstance)
  end
  if tManagerSelf == -1 then
    return nil
  else
    return tManagerSelf
  end
end

function AAManager:KillEvents()
  if self.eRaidTimeEvent then
    Util.KillEvent(self.eRaidTimeEvent)
  end
  if self.eUnboardDelayEvent then
    Util.KillEvent(self.eUnboardDelayEvent)
  end
  if self.eCannonStreamEvent then
    Util.KillEvent(self.eCannonStreamEvent)
  end
end

function AAManager:OnExit()
  Tips.Print(self, "Streaming cannon out...")
  AAManager.DespawnGunner(self)
  AAManager.KillEvents(self)
end

function AAManager:BeginFiringSequence()
  self.eRaidTimeEvent = nil
  AAManager.SetupRaidEvents(self)
  if Actor.HasLabel(hSab, "Act_2") then
    if self.bReadyToFire == false then
      return
    end
    if self and self.hGunner and Actor.IsAlive(self.hGunner) then
      local tCombatFlags = {
        EnableSuspicion = false,
        RespondsToDeadBodies = false,
        RespondsToDamage = false,
        RespondsToEvents = false,
        SetIdleScripted = true
      }
      local tSequence = {
        {
          "SETCOMBATFLAGS",
          {tCombatFlags}
        },
        {
          "SETCOMBAT",
          {false}
        },
        {"STOPMOVING"},
        {
          "RUNTOOBJECT",
          {
            self.SMEDTable.sPath .. "LOC_Board"
          }
        },
        {
          "SETBROADCAST_WEAPONFIRE",
          {false}
        },
        {
          "SETBROADCAST_ENTEREDCOMBAT",
          {false}
        },
        {
          "ENTERSEAT",
          {
            self.SMEDTable.sPath .. "Target",
            "PILOT"
          }
        },
        {
          "SETHAX",
          {true}
        },
        {
          "SETDRYFIRE",
          {true}
        },
        {
          "ATTACKTARGET_NOWAIT",
          {
            self.SMEDTable.sPath .. "DummyTarget1"
          },
          "A"
        },
        {
          "DELAY",
          {2.5}
        },
        {
          "JUMPTORANDOM",
          {
            "B",
            "C",
            "D"
          }
        },
        {
          "ATTACKTARGET_NOWAIT",
          {
            self.SMEDTable.sPath .. "DummyTarget2"
          },
          "B"
        },
        {
          "DELAY",
          {2.5}
        },
        {
          "JUMPTORANDOM",
          {
            "A",
            "C",
            "D"
          }
        },
        {
          "ATTACKTARGET_NOWAIT",
          {
            self.SMEDTable.sPath .. "DummyTarget3"
          },
          "C"
        },
        {
          "DELAY",
          {2.5}
        },
        {
          "JUMPTORANDOM",
          {
            "A",
            "B",
            "D"
          }
        },
        {
          "ATTACKTARGET_NOWAIT",
          {
            self.SMEDTable.sPath .. "DummyTarget4"
          },
          "D"
        },
        {
          "DELAY",
          {2.5}
        },
        {
          "JUMPTORANDOM",
          {
            "A",
            "B",
            "C"
          }
        }
      }
      ScriptSequence.Run(self.hGunner, tSequence)
      local tDryFireDelayEvent = {
        EventType = "TimerEvent",
        Time = math.random(self.nMinDryFireDelay, self.nMaxDryFireDelay)
      }
      Util.CreateEvent(tDryFireDelayEvent, "AAManager.OnPermissionToFireGranted", self)
      local tCinematicsDelay = {
        EventType = "TimerEvent",
        Time = self.nCinematicsDelay
      }
      Util.CreateEvent(tCinematicsDelay, "AAManager.BeginCinematics", self)
    end
  end
end

function AAManager:OnPermissionToFireGranted()
  Tips.Print(self, "Permission to fire granted!")
  Combat.SetDryFire(self.hGunner, false)
  local tCeaseFireDelay = {
    EventType = "TimerEvent",
    Time = math.random(self.nMinCeaseFireDelay, self.nMaxCeaseFireDelay)
  }
  Util.CreateEvent(tCeaseFireDelay, "AAManager.EndFiringSequence", self)
end

function AAManager:BeginCinematics()
  Tips.Print(self, "Playing cinematics!")
  for i, sSpline in ipairs(self.SMEDTable.lsSplines) do
    Cin.ActivateObjectSpline(sSpline, false, false)
  end
end

function AAManager:EndFiringSequence()
  if Actor.IsAlive(self.hGunner) == true then
    Combat.SetDryFire(self.hGunner, true)
    local tDelayEvent = {
      EventType = "TimerEvent",
      Time = self.nPostRaidDryFireDelay
    }
    self.eUnboardDelayEvent = Util.CreateEvent(tDelayEvent, "AAManager.UnboardGunner", self)
  end
end

function AAManager:UnboardGunner()
  self.eUnboardDelayEvent = nil
  if self and self.hGunner and Actor.IsAlive(self.hGunner) then
    local tSequence = {
      {
        "SETHAX",
        {false}
      },
      {
        "SETCOMBAT",
        {false}
      },
      {
        "UNBOARDVEHICLE"
      },
      {"STOPMOVING"},
      {
        "SETDRYFIRE",
        {false}
      },
      {
        "SETBROADCAST_WEAPONFIRE",
        {true}
      },
      {
        "SETBROADCAST_ENTEREDCOMBAT",
        {true}
      },
      {
        "CLEARCOMBATFLAGS"
      },
      {
        "DELAY",
        {2}
      },
      {
        "TELEPORT_TO_OBJ",
        {
          AAManager.GetCannonPath(self) .. "LOC_Board"
        }
      }
    }
    ScriptSequence.Run(self.hGunner, tSequence)
  end
end

function AAManager:SetupRaidEvents()
  if self.bManualFireMode == true then
    return
  end
  local tCurrentTime = Util.GetTime()
  local nHour = tCurrentTime.Hour
  local nMinute = tCurrentTime.Minute
  for i = nMinute + 1, 60 do
    if i % 15 == 0 then
      nMinute = i
      break
    end
  end
  if nMinute == 60 then
    nMinute = 0
    nHour = nHour + 1
  end
  if nHour == 24 then
    nHour = 0
  end
  local tTimeEvent = {
    EventType = "TimeOfDayEvent",
    Hour = nHour,
    Minute = nMinute,
    Second = 0
  }
  self.eRaidTimeEvent = Util.CreateEvent(tTimeEvent, "AAManager.BeginFiringSequence", self)
end
