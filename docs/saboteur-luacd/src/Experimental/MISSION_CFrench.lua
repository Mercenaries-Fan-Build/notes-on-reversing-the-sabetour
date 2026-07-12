if MISSION_CFrench == nil then
  MISSION_CFrench = SabTaskObjective:Create()
  MISSION_CFrench:Configure({
    TaskCount = 2,
    sStarter = "STARTER_MISSION_CFrench\\STARTER_CFrench",
    tUnlockList = {
      "MISSION_DSimmons",
      "MISSION_SGillies"
    },
    sStarterNode = "STARTER_MISSION_CFrench",
    tInteriorNodes = {
      "testteleport"
    },
    tSMEDNodes = {
      "MISSION_CFrench"
    }
  })
end

function MISSION_CFrench:Activated()
  SabTaskObjective.Activated(self)
  self.Task_TestTalk(self)
  self.Limo = "MISSION_CFrench\\madtaxi"
  Frame = -1
  oldFrame = Frame
  framecount = 4
  rowcount = 2
  RowTracker = -1
  ColTracker = 0
  colcount = framecount / rowcount
end

function MISSION_CFrench:GotPapers()
  Render.PrintMessage("YOU FOUND PAPERS")
  print("you found papers")
  Actor.GetSelf(hSab).bHDV_Papers = true
end

function MISSION_CFrench:Task_CancelMission()
  self:CreateTask({
    sName = "blarrrgg",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Use",
    sObjectiveTextID = "Finish Test Use the point",
    tTgtInclude = {
      "MISSION_CFrench\\STARTER_MFindley_Attr"
    },
    tOnComplete = {},
    tOnActivate = {
      {
        DisplayHUDText,
        {
          "Use the use point Mission"
        }
      }
    }
  })
end

function MISSION_CFrench:Task_Use()
  self:CreateTask({
    sName = "blarrrgg2",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Use",
    sPartialCompleteMsg = "tested",
    sObjectiveTextID = "Use Mission Test",
    tTgtInclude = {
      "testcheck\\ramen",
      "testcheck\\ramen2"
    },
    tOnComplete = {
      {
        self.Task_Taxi,
        {self}
      },
      {
        DisplayHUDText,
        {
          " completed "
        }
      }
    },
    tOnActivate = {}
  })
  EVENT_PlayerEntersTrigger("MISSION_CFrench.TestThisOut", self, "MISSION_CFrench\\REG_Escort")
end

function MISSION_CFrench:TestThisOut()
  print("killing blarg")
  self:FailTaskByName("blarrrgg2")
end

function MISSION_CFrench:Task_TestTalk()
  self:CreateTask({
    sName = "MISSION_CFrench_Task_TestTalk",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "Talk",
    sObjectiveTextID = "Talk to escort",
    tTgtInclude = {
      "MISSION_CFrench\\Escort"
    },
    sConvFile = "tempP1M2",
    tOnComplete = {
      {
        self.Task_Use,
        {self}
      }
    },
    tOnActivate = {}
  })
end

function MISSION_CFrench:Task_Taxi()
  self:CreateTask({
    sName = "MISSION_CFrench_Task_Taxi",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Taxi",
    tDestRegion = {
      "MISSION_CFrench\\REG_Escort"
    },
    tDeliverObjs = {
      "MISSION_CFrench\\Escort"
    },
    sObjectiveTextID = "Taxi ride!",
    tOnComplete = {
      {
        self.Task_Use,
        {self}
      }
    },
    tOnActivate = {},
    tOnCancel = {
      {
        print,
        {
          "Failed Task"
        }
      }
    }
  })
end

function MISSION_CFrench:Task_Destroy_Example()
  Render.PrintMessage("Hello Adam", 2)
  Render.PrintMessage("More like Add ....hmmmmmm", 2)
  self:CreateTask({
    sName = "MISSION_CFrench_Task_Kill_Nazi",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "Kill",
    tTgtInclude = {
      "testcheck\\Boiler"
    },
    tOnComplete = {},
    tOnCancel = {},
    tOnFailure = {
      {
        self.DefendFailed,
        {self}
      }
    },
    tOnActivate = {
      Render.PrintMessage("Destroy Boiler")
    }
  })
end

function MISSION_CFrench.goboat()
  hBoat = Util.GetHandleByName("testcheck\\motormeboat")
  local tBoatGOGO = {
    {
      "DRIVEPATHONCE",
      {
        "testcheck\\PATH_Boat"
      },
      5
    },
    {"STARTOVER"}
  }
  ScriptSequence.Run(hBoat, tBoatGOGO)
  hTestDriver = Util.GetHandleByName("testcheck\\TestDriver")
  local tTestBoat = {
    {
      "DRIVEPATHONCE",
      {
        "testcheck\\PATH_Start1"
      },
      5
    },
    {
      "JUMPTORANDOM",
      {"DeadPath", "SafePath"}
    },
    {
      "PRINTMESSAGE",
      {"DEAD PATH"},
      "DeadPath"
    },
    {
      "DRIVEPATHONCE",
      {
        "testcheck\\PATH_Dead1"
      },
      5
    },
    {
      "JUMPTOELEMENT",
      {"end"}
    },
    {
      "PRINTMESSAGE",
      {"SAFE PATH"},
      "SafePath"
    },
    {
      "DRIVEPATHONCE",
      {
        "testcheck\\PATH_Safe1"
      },
      5
    },
    {
      "JUMPTOELEMENT",
      {"end"}
    },
    {"STARTOVER", "end"}
  }
  ScriptSequence.Run(hTestDriver, tTestBoat)
end

function MISSION_CFrench:BoilerConfig()
  local hdoodle = Util.GetHandleByName("testcheck\\Boiler")
  local x, y, z = Object.GetPosition(hdoodle)
  print("ddoodle ", x, y, z)
  AttractionPt.Create("AttractionPt_Boiler", 0, 0, 0, 180, hdoodle)
end

function MISSION_CFrench:DefendFailed()
  Render.PrintMessage("FAILED TO PROTECT TRUCK!!!")
end

function MISSION_CFrench:Task_DefendTruck()
  self:CreateTask({
    sName = "MISSION_CFrench_Task_DefendTruck",
    sTaskType = "SabTaskObjectiveDestroy",
    sTaskSubType = "Defend",
    bFailMissionOnFail = true,
    VictoryTimer = 10,
    tTgtInclude = {
      "testbuild\\popel",
      "testbuild\\popel2"
    },
    tOnComplete = {
      {
        self.Task_Proximity_Example,
        {self}
      }
    },
    tOnActivate = {
      {
        Render.PrintMessage,
        {
          "Objective: Deliver Truck to Trigger Box"
        }
      }
    },
    tOnCancel = {}
  })
end

function MISSION_CFrench:Task_Escort()
  self:CreateTask({
    sName = "MISSION_CFrench_Task_Escort",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "Escort",
    tDestRegion = {
      "MISSION_CFrench\\REG_Escort"
    },
    tDeliverObjs = {
      "MISSION_CFrench\\Escort",
      "MISSION_CFrench\\Escort2"
    },
    TaskCount = 2,
    bFailMissionOnFail = true,
    tOnFailure = {
      {
        self.EscortDied,
        {self}
      }
    },
    tOnComplete = {
      {
        self.Escort_Delivered,
        {self}
      },
      {
        self.Task_Proximity_Example,
        {self}
      }
    },
    tOnActivate = {
      {
        Render.PrintMessage,
        {
          "Objective: Escort these women"
        }
      }
    },
    tOnCancel = {
      {
        self.Cancel,
        {self}
      }
    }
  })
end

function MISSION_CFrench:Task_Proximity_Example()
  self:CreateTask({
    sName = "MISSION_CFrench_Task_Proximity_Example",
    sTaskType = "SabTaskObjectiveDeliver",
    sTaskSubType = "GOTO",
    tLocators = {},
    tDestProximityObj = {
      "MISSION_CFrench\\Graf_Node\\Test_Graf"
    },
    tDeliverObjs = {hSab},
    tDependencyList = {
      "MISSION_CFrench_Task_Escort",
      "MISSION_CFrench_Task_DefendTruck"
    },
    tOnComplete = {
      {
        Render.PrintMessage,
        {
          "MISSION COMPLETE"
        }
      }
    },
    tOnActivate = {
      {
        Render.PrintMessage,
        {
          "Objective:Get to Graf"
        }
      }
    }
  })
end

function MISSION_CFrench:CompleteThis()
  print("complete test task")
  local tConfig = self:GetConfig()
  for i, v in pairs(tConfig.tTgtInclude) do
    Object.Kill(Util.GetHandleByName(v))
  end
end

function MISSION_CFrench:TestKill()
  print("killing escort ", self:GetName())
  Object.Kill(Util.GetHandleByName("MISSION_CFrench\\Escort"))
end

function MISSION_CFrench:EscortDied()
  print("MISSION FAILED", self:GetName())
  Util.CreateEvent({
    EventType = "TimerEvent",
    EventName = "TestOverPlease",
    Time = 2
  }, "MISSION_CFrench.TestOver", self)
end

function MISSION_CFrench:TestOver()
  print("canceling gameplay ", self:GetName())
  self:Cancel()
end

function MISSION_CFrench:Escort_Delivered()
  Render.PrintMessage("You escorted the escort")
end

function MISSION_CFrench:TeleportIn()
  print("made it into teleport test in")
  local hLocIn = Util.GetHandleByName("testbuild\\LOC_In")
  local hLocOut = Util.GetHandleByName("testbuild\\LOC_Out")
  local Inx, Iny, Inz = Object.GetPosition(hLocIn)
  local Outx, Outy, Outz = Object.GetPosition(hLocOut)
  local sabrot = Actor.GetFacingDir(hSab)
  local sabx, saby, sabz = Object.GetPosition(hSab)
  local dify = saby - Outy
  Object.Teleport(hSab, sabx, Iny + dify, sabz, sabrot)
end

function MISSION_CFrench:TeleportOut()
  local hLocOut = Util.GetHandleByName("testbuild\\LOC_Out")
  local hLocIn = Util.GetHandleByName("testbuild\\LOC_In")
  local Outx, Outy, Outz = Object.GetPosition(hLocOut)
  local Inx, Iny, Inz = Object.GetPosition(hLocIn)
  local sabrot = Actor.GetFacingDir(hSab)
  local sabx, saby, sabz = Object.GetPosition(hSab)
  local dify = saby - Iny
  Object.Teleport(hSab, sabx, Outy + dify, sabz, sabrot)
end

function MISSION_CFrench:Mad_Taxi_Setup()
  self.Fear = 0
  self.AirTime = 0
  EVENT_Stream("MISSION_CFrench.SetupEventOnTaxi", self, {
    self.Limo
  })
end

function MISSION_CFrench:SetupEventOnTaxi()
  self:RegisterEvent(EVENT_PlayerEntersVehicle("MISSION_CFrench.Mad_Taxi_Update", self, self.Limo, self.Limo))
end

function MISSION_CFrench:Mad_Taxi_Update(a_hVehicle)
  local dT = 0.5
  a_hVehicle = WRAPPER_CheckForHandle(a_hVehicle)
  local speed = Vehicle.GetSpeed(a_hVehicle) / 1.75
  if 80 < speed then
    self.Fear = self.Fear + 10
    dT = 1.25
  elseif 70 < speed then
    self.Fear = self.Fear + 8
    dT = 1
  elseif 60 < speed then
    self.Fear = self.Fear + 6
    dT = 0.75
  elseif 50 < speed then
    self.Fear = self.Fear + 4
    dT = 0.75
  elseif 40 < speed then
    self.Fear = self.Fear + 2
  else
    self.Fear = self.Fear - 4
    if self.Fear < 0 then
      self.Fear = 0
    end
  end
  local wheelsOnGround = Vehicle.GetNumWheelsOnGround(a_hVehicle)
  if wheelsOnGround < 2 and 25 < speed then
    dT = 0.5
    self.AirTime = self.AirTime + dT
  else
    self.AirTime = 0
  end
  if 1 < self.AirTime then
    self.Fear = self.Fear + 12
  end
  if 40 < speed or 0 < self.AirTime then
    print("speed: " .. speed, "air (" .. wheelsOnGround .. ") : " .. self.AirTime, "fear: " .. self.Fear)
  end
  EVENT_Timer("MISSION_CFrench.Mad_Taxi_Update", self, dt, a_hVehicle)
end

function MISSION_CFrench:startfr()
  EVENT_Timer("MISSION_CFrench.Update", self, 1)
end

function MISSION_CFrench:Update()
  EVENT_Timer("MISSION_CFrench.Update", self, 1)
  Frame = Frame + 1
  RowTracker = RowTracker + 1
  print("  ", Frame % framecount, " = ", Frame, " % ", framecount)
  print(" ", RowTracker % rowcount, " = ", RowTracker, " % ", rowcount)
  Frame = Frame % framecount
  RowTracker = RowTracker % rowcount
  if oldFrame ~= Frame then
    if Frame == framecount / colcount then
    end
    oldFrame = Frame
  end
  print(" framecount mod colcount")
  print("Frame = ", Frame, " colcount ", colcount)
  MISSION_CFrench.DrawZors(self)
end

function MISSION_CFrench:DrawZors()
  local textwidth = 40
  local textheight = 60
  local framewidth = textwidth / colcount
  local a, b, c, d
  local frameheight = textheight / rowcount
  local FrameCol = Frame % colcount
  a = FrameCol * framewidth
  b = RowTracker * frameheight
  c = framewidth * (FrameCol + 1)
  d = frameheight * (RowTracker + 1)
  print("FrameCol = ", FrameCol)
  print(" a=", a, " b=", b)
  print(" c=", c, " d=", d)
  print("")
end
