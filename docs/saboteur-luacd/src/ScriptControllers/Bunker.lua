if not Bunker then
  Bunker = {}
end

function Bunker:OnEnter()
  self.bDebugMode = false
  self.sDebugLabel = "BUNKER"
  self.bIsDestroyed = false
  self.tEvents = {}
  if self and self.SMEDTable and self.SMEDTable.sBunkerPath then
    local tStreamEvent = {
      EventType = "StreamEvent",
      Objects = {
        self.SMEDTable.sBunkerPath .. "SpawnBunker"
      }
    }
    table.insert(self.tEvents, Util.CreateEvent(tStreamEvent, "Bunker.OnStream", self))
  end
end

function Bunker:OnStream()
  if not self or type(self) == "number" then
    return
  end
  if self.SMEDTable and self.SMEDTable.sBunkerPath then
    Tips.Print(self, "All objects have streamed in. Setting up events.")
    self.hBunker = Util.GetHandleByName(self.SMEDTable.sBunkerPath .. "SpawnBunker")
    local tDeathEvent = {
      EventType = "DeathEvent",
      ObjectHandle = self.hBunker
    }
    local e = Util.CreateEvent(tDeathEvent, "Bunker.OnDestroyed", self)
    Tips.Print(self, "DeathEvent hooked up for " .. self.SMEDTable.sBunkerPath .. "SpawnBunker")
    table.insert(self.tEvents, e)
    self.hSpawner = Util.GetHandleByName(self.SMEDTable.sBunkerPath .. "Spawner")
    local tSpawnListener = {
      EventType = "OnSpawn",
      Target = self.hSpawner
    }
    e = Util.CreateEvent(tSpawnListener, "Bunker.OnSpawn", self, {}, true)
    table.insert(self.tEvents, e)
    self.hDoorTrigger = Util.GetHandleByName(self.SMEDTable.sBunkerPath .. "PT_DoorTrigger")
    local tDoorTriggerListener = {
      EventType = "OnTriggerEnter",
      Target = self.hDoorTrigger
    }
    e = Util.CreateEvent(tDoorTriggerListener, "Bunker.OnDoorTriggerEnter", self, {}, true)
    Tips.Print(self, "OnTriggerEnter event hooked up for trigger.")
    table.insert(self.tEvents, e)
    self.tJobData = {}
    self.bIsBaseEscalated = false
    self.bIsWorldEscalated = false
    self.tEscalationEvents = {}
    Bunker.SetupEscalationListeners(self)
  end
  self.SMEDTable.bLargeBunker = self.SMEDTable.bLargeBunker or false
end

function Bunker:SetupEscalationListeners()
  Tips.Print(self, "Setting up escalation listeners")
  local hSaboteur = Handle("Saboteur")
  table.insert(self.tEscalationEvents, Util.CreateEvent({
    Target = hSaboteur,
    EventType = "OnEscalation0"
  }, "Bunker.OnEscalationOver", self, {}, true))
  table.insert(self.tEscalationEvents, Util.CreateEvent({
    Target = hSaboteur,
    EventType = "OnEscalation"
  }, "Bunker.OnEscalation", self, {}, true))
end

function Bunker:KillEscalationListeners()
  if self.tEscalationEvents then
    for i, e in ipairs(self.tEscalationEvents) do
      Util.KillEvent(e)
    end
  end
  self.tEscalationEvents = nil
end

function Bunker:OnEscalation(a_tParams)
  if a_tParams[1] == true then
    Tips.Print(self, "Base escalation callback received!")
    self.bIsBaseEscalated = true
  else
    Tips.Print(self, "World escalation callback received!")
    self.bIsWorldEscalated = true
  end
  Bunker._Activate(self)
end

function Bunker:OnEscalationOver(a_tParams)
  if a_tParams[1] == true then
    Tips.Print(self, "Base escalation is now over!")
    self.bIsBaseEscalated = false
  else
    Tips.Print(self, "World escalation is now over!")
    self.bIsWorldEscalated = false
  end
  Bunker._Deactivate(self)
end

function Bunker.Activate(a_vBunker)
  local tBunkerSelf = Tips.GetSelf(a_vBunker)
  Bunker._Activate(tBunkerSelf)
end

function Bunker:_Activate()
  if self.bIsDestroyed == true then
    return
  end
  if Bunker.IsAlive(self) == false then
    return
  end
  Tips.Print(self, "_Activate()")
  Object.EnableSpawner(self.hSpawner, true)
end

function Bunker.Deactivate(a_vBunker)
  local tBunkerSelf = Tips.GetSelf(a_vBunker)
  Bunker._Deactivate(tBunkerSelf)
end

function Bunker:_Deactivate()
  Tips.Print(self, "_Deactivate()")
  Object.EnableSpawner(self.hSpawner, false)
end

function Bunker.DeactivateByHeart(a_vBunker)
  local tBunkerSelf = Tips.GetSelf(a_vBunker)
  Bunker._DeactivateByHeart(tBunkerSelf)
end

function Bunker:_DeactivateByHeart()
  Tips.Print(self, "_DeactivateByHeart()")
  self.bIsDestroyed = true
  Bunker.KillEscalationListeners(self)
  Object.EnableSpawner(self.hSpawner, false)
  Object.SpawnerReset(self.hSpawner)
end

function Bunker.OpenDoor(a_vBunker)
  local tBunkerSelf = Tips.GetSelf(a_vBunker)
  Bunker._OpenDoor(tBunkerSelf)
end

function Bunker:_OpenDoor()
  if self.SMEDTable.bLargeBunker == false then
    local hDoor = Util.GetHandleByName(self.SMEDTable.sBunkerPath .. "Door")
    Object.Actuate(hDoor, true)
    if self.tEvents.eDoorClearanceTimer then
      Util.KillEvent(self.tEvents.eDoorClearanceTimer)
      self.tEvents.eDoorClearanceTimer = nil
    end
    local tEvent = {EventType = "TimerEvent", Time = 2}
    local eDoorEvent = Util.CreateEvent(tEvent, "Bunker.CheckDoorClearance", self)
    self.tEvents.eDoorClearanceTimer = eDoorEvent
  else
    local hDoorLeft = Util.GetHandleByName(self.SMEDTable.sBunkerPath .. "Door_Left")
    local hDoorRight = Util.GetHandleByName(self.SMEDTable.sBunkerPath .. "Door_Right")
    Object.Actuate(hDoorLeft, true)
    Object.Actuate(hDoorRight, true)
    if self.tEvents.eDoorClearanceTimer then
      Util.KillEvent(self.tEvents.eDoorClearanceTimer)
      self.tEvents.eDoorClearanceTimer = nil
    end
    local tEvent = {EventType = "TimerEvent", Time = 2}
    local eDoorEvent = Util.CreateEvent(tEvent, "Bunker.CheckDoorClearance", self)
    self.tEvents.eDoorClearanceTimer = eDoorEvent
  end
end

function Bunker:CheckDoorClearance()
  local hFilter = Filter.New("TripsBunkerDoor")
  local tSoldiersInsideDoorTrigger = Trigger.GetAllWithin(self.hDoorTrigger, hFilter)
  Filter.Delete(hFilter)
  if tSoldiersInsideDoorTrigger ~= nil then
    Tips.Print(self, "Someone is still inside the door trigger. Keeping door alive.")
    Bunker.OpenDoor(self.hController)
  else
    Tips.Print(self, "Door lane is clear. Letting door shut.")
  end
end

function Bunker:SendSoldierToDespawn(a_tArgs, a_hSoldier)
  Tips.Print(self, "SendSoldierToDespawn()")
  local tSoldierSelf = Tips.GetSelf(a_hSoldier)
  if Bunker.IsAlive(self) == true then
    Combat.SetIdleScripted(a_hSoldier, true)
    local x, y, z = Object.GetPosition(self.hSpawner)
    Tips.Print(self, "Adding TripsBunkerDoor to soldier.")
    Actor.SetLabel(a_hSoldier, "TripsBunkerDoor", true)
    local tSequence = {
      {
        "WALKTOPOINT",
        {
          x,
          y,
          z
        }
      },
      {
        "DESPAWN_IMMEDIATE"
      }
    }
    ScriptSequence.Run(a_hSoldier, tSequence)
  else
    Object.Despawn(a_hSoldier, 30, true)
  end
end

function Bunker.DespawnActor(a_vBunker, a_hActor, a_bUrgent)
  Tips.Print(self, "SendSoldierToDespawn()")
  local tBunkerSelf = Tips.GetSelf(a_vBunker)
  if Bunker.IsAlive(tBunkerSelf) == true then
    Combat.SetIdleScripted(a_hActor, true)
    local x, y, z = Object.GetPosition(tBunkerSelf.hSpawner)
    Tips.Print(self, "Adding TripsBunkerDoor to soldier.")
    Actor.SetLabel(a_hActor, "TripsBunkerDoor", true)
    local sMoveCommand = "WALKTOPOINT"
    if a_bUrgent and a_bUrgent == true then
      sMoveCommand = "RUNTOPOINT"
    end
    local tSequence = {
      {
        sMoveCommand,
        {
          x,
          y,
          z
        }
      },
      {
        "DESPAWN_IMMEDIATE"
      }
    }
    ScriptSequence.Run(a_hActor, tSequence)
  else
    Object.Despawn(a_hActor, 30, true)
  end
end

function Bunker:OnReinforcementOnExit(a_eEntersIdleEvent)
  Util.KillEvent(a_eEntersIdleEvent)
end

function Bunker:KillPendingEvents()
  Tips.Print(self, "Killing all pending events!")
  if self.tEvents then
    for i, e in pairs(self.tEvents) do
      Util.KillEvent(e)
    end
  end
  self.tEvents = nil
  self.tEvents = {}
end

function Bunker:OnSpawn(a_tArgs)
  Tips.Print(self, "OnSpawn()")
  local hSoldier = a_tArgs[2]
  if self.bIsWorldEscalated == true and self.bIsBaseEscalated == false then
    local sChosenHuntPoint = Tips.GetRandomElement(self.SMEDTable.lsHuntPoints)
    local x, y, z = Object.GetPosition(Util.GetHandleByName(sChosenHuntPoint))
    local tSequence = {
      {
        "ADDLABEL",
        {
          "TripsBunkerDoor"
        }
      },
      {
        "RUNTOOBJECT",
        {
          self.SMEDTable.sBunkerPath .. "LOC_FrontStep",
          0
        }
      },
      {
        "REMOVELABEL",
        {
          "TripsBunkerDoor"
        }
      },
      {
        "HUNTLOCATION",
        {
          x,
          y,
          z,
          true,
          false
        }
      }
    }
    ScriptSequence.Run(hSoldier, tSequence)
  elseif self.bIsBaseEscalated == true then
    local x, y, z = Object.GetPosition(self.hController)
    local tSequence = {
      {
        "ADDLABEL",
        {
          "TripsBunkerDoor"
        }
      },
      {
        "RUNTOOBJECT",
        {
          self.SMEDTable.sBunkerPath .. "LOC_FrontStep",
          0
        }
      },
      {
        "REMOVELABEL",
        {
          "TripsBunkerDoor"
        }
      },
      {
        "HUNTLOCATION",
        {
          x,
          y,
          z,
          true,
          false
        }
      }
    }
    ScriptSequence.Run(hSoldier, tSequence)
  end
  local tClearEvent = {EventType = "OnHuntFail", Target = hSoldier}
  local eSoldierEntersIdle = Util.CreateEvent(tClearEvent, "Bunker.SendSoldierToDespawn", self, {hSoldier}, true)
  local tOnExitEvent = {EventType = "OnExit", Target = hSoldier}
  table.insert(self.tEvents, Util.CreateEvent(tOnExitEvent, "Bunker.OnReinforcementOnExit", self, {eSoldierEntersIdle}))
  Actor.SetLabel(hSoldier, "BunkerSoldier", true)
  Bunker.OpenDoor(self.hController)
end

function Bunker:OnDoorTriggerEnter(a_tTriggerData)
  local hActor = a_tTriggerData[2]
  Tips.Print(self, "OnDoorTriggerEnter()")
  if Actor.HasLabel(hActor, "TripsBunkerDoor") == true then
    Tips.Print(self, "Actor has proper flag -- opening the door!")
    Bunker.OpenDoor(self.hController)
  end
end

function Bunker:OnDestroyed()
  Tips.Print(self, "Bunker has been destroyed.")
  Bunker.Deactivate(self.hController)
  Bunker.KillPendingEvents(self)
  Bunker.KillEscalationListeners(self)
  self.bIsDestroyed = true
end

function Bunker.Destroy(a_vBunker)
  local tBunkerSelf = Tips.GetSelf(a_vBunker)
  Bunker._Destroy(tBunkerSelf)
end

function Bunker:_Destroy()
  local PATH = self.SMEDTable.sBunkerPath
  if self.SMEDTable.bLargeBunker == false then
    Tips.Print(self, "Using small bunker destruction sequence.")
    local tFrontDoor = {
      PATH .. "EXPL_Front_01",
      PATH .. "EXPL_Front_02",
      PATH .. "EXPL_Front_03"
    }
    local tLeftWindow = {
      PATH .. "EXPL_Left_01",
      PATH .. "EXPL_Left_02",
      PATH .. "EXPL_Left_03"
    }
    local tRightWindow = {
      PATH .. "EXPL_Right_01",
      PATH .. "EXPL_Right_02",
      PATH .. "EXPL_Right_03"
    }
    local tTop = {
      PATH .. "EXPL_Top_01",
      PATH .. "EXPL_Top_02",
      PATH .. "EXPL_Top_03",
      PATH .. "EXPL_Top_04"
    }
    local tExplosionSequence = {
      {
        "SPAWNEXPLOSION",
        {
          "Explosion_Small",
          PATH .. "EXPL_FrontVent_01"
        }
      },
      {
        "SPAWNEXPLOSION",
        {
          "Explosion_Small",
          PATH .. "EXPL_Back_01"
        }
      },
      {
        "CHAINEXPLOSIONS",
        {
          "Explosion_Small",
          tFrontDoor,
          0.3
        }
      },
      {
        "CHAINEXPLOSIONS",
        {
          "Explosion_Small",
          tLeftWindow,
          0.3
        }
      },
      {
        "CHAINEXPLOSIONS",
        {
          "Explosion_Small",
          tRightWindow,
          0.3
        }
      },
      {
        "CHAINEXPLOSIONS",
        {
          "Explosion_Small",
          tTop,
          0.75
        }
      }
    }
  else
    Tips.Print(self, "Using large bunker destruction sequence.")
    local tFrontDoor = {
      PATH .. "EXPL_Front_01",
      PATH .. "EXPL_Front_02",
      PATH .. "EXPL_Front_03"
    }
    local tLeftWindowA = {
      PATH .. "EXPL_Left_A_01",
      PATH .. "EXPL_Left_A_02"
    }
    local tLeftWindowB = {
      PATH .. "EXPL_Left_B_01",
      PATH .. "EXPL_Left_B_02"
    }
    local tRightWindowA = {
      PATH .. "EXPL_Right_A_01",
      PATH .. "EXPL_Right_A_02"
    }
    local tRightWindowB = {
      PATH .. "EXPL_Right_B_01",
      PATH .. "EXPL_Right_B_02"
    }
    local tTop = {
      PATH .. "EXPL_Top_01",
      PATH .. "EXPL_Top_02",
      PATH .. "EXPL_Top_03",
      PATH .. "EXPL_Top_04"
    }
    local tExplosionSequence = {
      {
        "SPAWNEXPLOSION",
        {
          "Explosion_Small",
          PATH .. "EXPL_FrontVent_01"
        }
      },
      {
        "SPAWNEXPLOSION",
        {
          "Explosion_Small",
          PATH .. "EXPL_Back_01"
        }
      },
      {
        "CHAINEXPLOSIONS",
        {
          "Explosion_Small",
          tFrontDoor,
          0.3
        }
      },
      {
        "CHAINEXPLOSIONS",
        {
          "Explosion_Small",
          tLeftWindowA,
          0.3
        }
      },
      {
        "CHAINEXPLOSIONS",
        {
          "Explosion_Small",
          tLeftWindowB,
          0.3
        }
      },
      {
        "CHAINEXPLOSIONS",
        {
          "Explosion_Small",
          tRightWindowA,
          0.3
        }
      },
      {
        "CHAINEXPLOSIONS",
        {
          "Explosion_Small",
          tRightWindowB,
          0.3
        }
      },
      {
        "CHAINEXPLOSIONS",
        {
          "Explosion_Small",
          tTop,
          0.75
        }
      }
    }
  end
end

function Bunker.AddJob(a_vBunker, a_sJobName, a_tJobTable, a_bStartJob)
  local tBunkerSelf = Tips.GetSelf(a_vBunker)
  if not tBunkerSelf.tJobData then
    Util.Assert(false, "How is the JobData table not initialized yet? Has the bunker not run its OnEnter?")
    tBunkerSelf.tJobData = {}
  end
  local tJobData = tBunkerSelf.tJobData
  tJobData[a_sJobName] = a_tJobTable
  Tips.Print(tBunkerSelf, "Successfully added job (" .. a_sJobName .. ")")
  if a_bStartJob and a_bStartJob == true then
    Bunker.StartJob(a_vBunker, a_sJobName)
  end
end

function Bunker.StartJob(a_vBunker, a_sJobName, a_bUrgentDespawn)
  local tBunkerSelf = Tips.GetSelf(a_vBunker)
  if Bunker.IsAlive(tBunkerSelf) == false then
    return
  end
  local tJobData = tBunkerSelf.tJobData
  Tips.Print(self, "Attempting to start job (" .. a_sJobName .. ")")
  local tJob = tJobData[a_sJobName]
  if not tJob then
    Util.Assert(false, "Trying to start a job that doesn't exist in the Bunker's job table!")
    return
  end
  if tJob.JobHolder and Actor.IsAlive(tJob.JobHolder) then
    ScriptSequence.Run(tJob.JobHolder, tJob.JobSequence)
  else
    Bunker.SpawnActor(a_vBunker, tJob.Blueprint, "Bunker.OnJobHolderSpawns", tBunkerSelf, {a_sJobName, a_bUrgentDespawn})
  end
end

function Bunker.RecycleJob(a_vBunker, a_sJobName, a_bUrgentDespawn)
  local tBunkerSelf = Tips.GetSelf(a_vBunker)
  if Bunker.IsAlive(tBunkerSelf) == false then
    return
  end
  Tips.Print(tBunkerSelf, "Attempting to recycle job (" .. a_sJobName .. ")")
  local tJob = tBunkerSelf.tJobData[a_sJobName]
  if not tJob then
    Util.Assert(false, "Cannot recycle a job that does not exist! Create a job first!")
  end
  if not tJob.JobHolder or Object.IsAlive(tJob.JobHolder) == false then
    Bunker.StartJob(a_vBunker, a_sJobName, a_bUrgentDespawn)
  else
    Bunker.StartJob(a_vBunker, a_sJobName, a_bUrgentDespawn)
  end
end

function Bunker.RestartAllJobs(a_vBunker)
  local tBunkerSelf = Tips.GetSelf(a_vBunker)
  Tips.Print(tBunkerSelf, "Attempting to recycle ALL jobs...")
  for sJobName, tJobTable in pairs(tBunkerSelf.tJobData) do
    Bunker.RecycleJob(a_vBunker, sJobName)
  end
end

function Bunker.SuspendJob(a_vBunker, a_sJobName, a_bUrgentDespawn)
  local tBunkerSelf = Tips.GetSelf(a_vBunker)
  local bUrgentDespawn = false
  if a_bUrgentDespawn then
    bUrgentDespawn = a_bUrgentDespawn
  end
  Tips.Print(tBunkerSelf, "Attempting to suspend job (" .. a_sJobName .. ")")
  local tJob = tBunkerSelf.tJobData[a_sJobName]
  if not tJob then
    Util.Assert(false, "Cannot suspend a job that does not exist! Get a job first, you deadbeat!")
    return
  end
  if tJob.JobHolder and Object.IsAlive(tJob.JobHolder) == true then
    Bunker.DespawnActor(self.hController, tJob.JobHolder, bUrgentDespawn)
  end
end

function Bunker.SuspendAllJobs(a_vBunker, a_bUrgentDespawn)
  local tBunkerSelf = Tips.GetSelf(a_vBunker)
  local bUrgentDespawn = false
  if a_bUrgentDespawn then
    bUrgentDespawn = a_bUrgentDespawn
  end
  Tips.Print(tBunkerSelf, "Suspending all jobs now...")
  for sJobName, tJob in pairs(tBunkerSelf.tJobData) do
    Bunker.SuspendJob(a_vBunker, sJobName, a_bUrgentDespawn)
  end
end

function Bunker.ResumeJob(a_vBunker, a_sJobName)
  local tBunkerSelf = Tips.GetSelf(a_vBunker)
  local tJob = tBunkerSelf.tJobData[a_sJobName]
  if not tJob then
    return
  end
  if tJob.JobHolder ~= nil and Actor.IsAlive(tJob.JobHolder) then
    ScriptSequence.Kill(tJob.JobHolder)
    ScriptSequence.Run(tJob.JobHolder, tJob.JobSequence)
  end
end

function Bunker.OverrideJob(a_vBunker, a_sJobName, a_tSequenceData)
  local tBunkerSelf = Tips.GetSelf(a_vBunker)
  local tJob = tBunkerSelf.tJobData[a_sJobName]
  if not tJob then
    return
  end
  if tJob.JobHolder ~= nil and Actor.IsAlive(tJob.JobHolder) then
    ScriptSequence.Kill(tJob.JobHolder)
    ScriptSequence.Run(tJob.JobHolder, a_tSequenceData)
  end
end

function Bunker.CancelJob(a_vBunker, a_sJobName, a_bUrgent)
  local tBunkerSelf = Tips.GetSelf(a_vBunker)
  if Bunker.IsAlive(tBunkerSelf) == false then
    return
  end
  local tJob = tBunkerSelf.tJobData[a_sJobName]
  local bUrgent = false
  Tips.Print(tBunkerSelf, "Attempting to cancel job (" .. a_sJobName .. ")")
  if a_bUrgent then
    bUrgent = a_bUrgent
  end
  if not tJob then
    Util.Assert(false, "Cannot cancel a job that does not exist! Get a job first, you deadbeat!")
    return
  end
  if tJob.JobHolder and Actor.IsAlive(tJob.JobHolder) == true then
    if tJob.CancelSequence == nil then
      Bunker.DespawnActor(tBunkerSelf.hController, tJob.JobHolder, bUrgent)
    else
      ScriptSequence.Run(tJob.JobHolder, tJob.CancelSequence, Bunker.OnCancelSequenceComplete, {
        a_vBunker,
        a_sJobName,
        tJob.JobHolder,
        a_bUrgent
      })
    end
  end
end

function Bunker.GetJobHolder(a_vBunker, a_sJobName)
  local tBunkerSelf = Tips.GetSelf(a_vBunker)
  local tJob = tBunkerSelf.tJobData[a_sJobName]
  if tJob then
    return tJob.JobHolder
  else
    return nil
  end
end

function Bunker:DespawnAllJobHolders()
  if not self then
    return
  end
  if self and self.tJobData then
    for sJobName, tJob in pairs(self.tJobData) do
      if tJob.JobHolder and Actor.IsAlive(tJob.JobHolder) then
        Object.Despawn(tJob.JobHolder, 50, true)
      end
    end
  end
end

function Bunker.GetJobTable(a_vBunker)
  local tBunkerSelf = Tips.GetSelf(a_vBunker)
  return tBunkerSelf.tJobData
end

function Bunker:OnShiftChange(a_sJobName, a_bUrgentDespawn, a_hNewJobholder, a_hOldJobHolder)
  Tips.Print(self, "Sending old jobholder(" .. tostring(a_hOldJobHolder) .. ") home. New jobholder(" .. tostring(a_hNewJobHolder) .. ") starting tasks.")
  local tJob = self.tJobData[a_sJobName]
  local bUrgentDespawn = false
  if a_bUrgentDespawn then
    bUrgentDespawn = a_bUrgentDespawn
  end
  ScriptSequence.Run(a_hNewJobholder, tJob.JobSequence)
  Bunker.DespawnActor(self.hController, a_hOldJobHolder, bUrgentDespawn)
end

function Bunker.OnCancelSequenceComplete(a_vBunker, a_sJobName, a_hJobHolder, a_bUrgent)
  Bunker.DespawnActor(a_vBunker, a_hJobHolder, a_bUrgent)
end

function Bunker.IsAlive(a_vBunker)
  if type(a_vBunker) == "string" or type(a_vBunker) == "userdata" then
    local tBunkerSelf = Tips.GetSelf(a_vBunker)
    return Object.IsAlive(tBunkerSelf.hBunker)
  elseif type(a_vBunker) == "table" then
    if a_vBunker.hBunker then
      return Object.IsAlive(a_vBunker.hBunker)
    else
      Util.Assert(false, "Bunker.IsAlive has received something other than a self table or handle/name!")
      return false
    end
  end
end

function Bunker.SpawnActor(a_vBunker, a_sBlueprint, a_sCallback, a_tSelf, a_tCallbackParams)
  local tBunkerSelf = Tips.GetSelf(a_vBunker)
  if Bunker.IsAlive(tBunkerSelf) == false then
    return
  end
  local hSpawner = Handle(tBunkerSelf.SMEDTable.sBunkerPath .. "Spawner")
  local x, y, z = Object.GetPosition(hSpawner)
  local nRot = Object.GetAngle(hSpawner)
  local tCallbackData = {
    Bunker = a_vBunker,
    Callback = a_sCallback,
    CallbackParams = a_tCallbackParams
  }
  Object.Spawn(a_sBlueprint, x, y, z, nRot, nil, "Bunker.OnActorSpawn", a_tSelf, {tCallbackData})
end

function Bunker:OnActorSpawn(a_tArgs, a_tCallbackData)
  local hSoldier = a_tArgs[1]
  local tBunkerSelf = Tips.GetSelf(a_tCallbackData.Bunker)
  Actor.SetLabel(hSoldier, "TripsBunkerDoor", true)
  Nav.MoveToObject(hSoldier, Handle(tBunkerSelf.SMEDTable.sBunkerPath .. "LOC_FrontStep"), 0.1, true, "Bunker.OnActorExitsBunker", self, {hSoldier, a_tCallbackData})
  Bunker.OpenDoor(tBunkerSelf.hController)
end

function Bunker:OnActorExitsBunker(a_hSoldier, a_tCallbackData)
  Actor.SetLabel(a_hSoldier, "TripsBunkerDoor", false)
  if a_tCallbackData.Callback then
    if a_tCallbackData.CallbackParams then
      local tCallbackParams = {}
      table.insert(tCallbackParams, self)
      table.insert(tCallbackParams, a_hSoldier)
      for i, v in ipairs(a_tCallbackData.CallbackParams) do
        table.insert(tCallbackParams, v)
      end
      Tips.StringToFunction(a_tCallbackData.Callback)(unpack(tCallbackParams))
    else
      Tips.StringToFunction(a_tCallbackData.Callback)(self, a_hSoldier)
    end
  end
end

function Bunker:OnJobHolderSpawns(a_hActor, a_sJobName, a_bUrgentDespawn)
  local tJob = self.tJobData[a_sJobName]
  local bUrgentDespawn = false
  if a_bUrgentDespawn then
    bUrgentDespawn = a_bUrgentDespawn
  end
  if tJob.JobHolder and Object.IsAlive(tJob.JobHolder) == true then
    Nav.MoveToObject(a_hActor, tJob.JobHolder, 3, true, "Bunker.OnShiftChange", self, {
      a_sJobName,
      bUrgentDespawn,
      a_hActor,
      tJob.JobHolder
    })
  else
    ScriptSequence.Run(a_hActor, tJob.JobSequence)
  end
  tJob.JobHolder = a_hActor
end

function Bunker:OnExit()
  Tips.Print(self, "Bunker OnExit")
  Bunker.DespawnAllJobHolders(self)
  Bunker.KillPendingEvents(self)
  Bunker.KillEscalationListeners(self)
end
