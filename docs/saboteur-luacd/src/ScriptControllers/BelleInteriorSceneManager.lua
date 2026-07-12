if not BelleInteriorSceneManager then
  BelleInteriorSceneManager = {}
end

function BelleInteriorSceneManager:OnEnter()
  BelleInteriorSceneManager.GENERAL_SETUP(self)
end

function BelleInteriorSceneManager:OnExit()
  for i, e in pairs(self.m_tEvents) do
    Util.KillEvent(e)
  end
end

function BelleInteriorSceneManager:GENERAL_SETUP()
  self.bDebugMode = true
  self.sDebugLabel = "BELLE"
  self.m_tEvents = {}
  self.tWaitresses = {
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Spore_CV_Belle_Waitress_1",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Spore_CV_Belle_Waitress",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Spore_CV_Belle_Waitress(2)"
  }
  self.tWaiterPaths = {}
  self.tNazisServed = {}
  self.tWaiter2Paths = {}
  self.tWaiterStreamObjs = {
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Spore_CV_Belle_Waitress_1",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Spore_CV_Belle_Waitress",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_GeneralTable",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table01",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table02",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table03",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table04",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table05",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table06",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table07",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table08",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table09",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table10",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Pit1",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Pit2",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Pit3",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Pit4",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Pit5"
  }
  self.sBarPoint = "PARIS\\area01\\belledenuit\\interior\\waiters\\AttractionPt_F_Convoidle"
  self.sBouncer = "PARIS\\area01\\belledenuit\\interior\\dlc\\Bruno"
  self.sBouncerAttrPT = "PARIS\\area01\\belledenuit\\interior\\dlc\\AttractionPT_Bouncer_Idle"
  self.sBrunoPath = "PARIS\\area01\\belledenuit\\interior\\dlc\\BrunoPath"
  self.nSecondWaiterPath = 0
  self.nWaiterPathNumber = 0
  self.nNazisServed = 0
  self.nCustomersServed = 0
  self.tWaiter1Paths = {
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Waiter1Path1",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Waiter1Path2",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Waiter1Path3",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Waiter1Path4",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Waiter1Path5",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Waiter1Path6",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Waiter1Path7"
  }
  self.tWaiter1AtPts = {
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Pit3",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Pit2",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Pit1",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_GeneralTable",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Pit5",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Pit4",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AttractionPt_F_Convoidle"
  }
  self.tWaiter2Paths = {
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Waiter2Path1",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Waiter2Path2",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Waiter2Path3",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Waiter2Path4",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Waiter2Path5"
  }
  self.tWaiter2AtPts = {
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table06",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table07",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table08",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table09",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table10"
  }
  self.tWaiter3Paths = {
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Waiter3Path1",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Waiter3Path2",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Waiter3Path3",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Waiter3Path4",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\Waiter3Path5"
  }
  self.tWaiter3AtPts = {
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table01",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table02",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table03",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table04",
    "PARIS\\area01\\belledenuit\\interior\\waiters\\AtPt_Waiter_Table05"
  }
  self.nWait1 = 1
  self.nWait2 = 1
  self.nWait3 = 1
  BelleInteriorSceneManager.SetObjectStreamEvents(self)
end

function BelleInteriorSceneManager:RequestNewTable(a_hWaiter)
  Render.PrintMessage("Actor is requesting a new table")
  local hWaiter = a_hWaiter
  local i = math.random(1, 16)
  local hTableAttractionPt = Handle(self.tWaiterPoints[i])
  Actor.RequestAttrPt(hWaiter, hTableAttractionPt, "BelleInteriorSceneManager.OnTableReached", self, hWaiter)
end

function BelleInteriorSceneManager:ReturntoBar(a_hWaiter)
  local hWaiter = a_hWaiter
end

function BelleInteriorSceneManager:OnTableReached(a_hWaiter)
  Render.PrintMessage("Actor has reached table")
  local hWaiter = a_hWaiter
  EVENT_Timer("BelleInteriorSceneManager.ResetOrders", self, 7, hWaiter)
end

function BelleInteriorSceneManager:ResetOrders(a_hWaiter)
  dprint(self, "Actor's orders are being reset")
  local hWaiter = a_hWaiter
  Actor.CancelAttrPt(hWaiter)
  BelleInteriorSceneManager.RequestNewTable(self, a_hWaiter)
end

function BelleInteriorSceneManager:GENERAL_WAITER_SETUP()
  self.bDebugMode = true
  self.sDebugLabel = "BELLE"
  self.m_tEvents.eStreamWaiters = nil
  self.tWaiterPaths = {
    "PARIS\\area01\\belledenuit\\interior\\civs\\WaiterPath1",
    "PARIS\\area01\\belledenuit\\interior\\civs\\WaiterPath2",
    "PARIS\\area01\\belledenuit\\interior\\civs\\WaiterPath3",
    "PARIS\\area01\\belledenuit\\interior\\civs\\WaiterPath4",
    "PARIS\\area01\\belledenuit\\interior\\civs\\WaiterPath5",
    "PARIS\\area01\\belledenuit\\interior\\civs\\WaiterPath6",
    "PARIS\\area01\\belledenuit\\interior\\civs\\WaiterPath7",
    "PARIS\\area01\\belledenuit\\interior\\civs\\WaiterPath8",
    "PARIS\\area01\\belledenuit\\interior\\civs\\WaiterPath9"
  }
  self.tNazisServed = {
    "PARIS\\area01\\belledenuit\\interior\\civs\\Spore_WM_Grunt(19)",
    "PARIS\\area01\\belledenuit\\interior\\civs\\Spore_WM_Grunt(18)",
    "PARIS\\area01\\belledenuit\\interior\\civs\\Spore_WM_Grunt(16)",
    "PARIS\\area01\\belledenuit\\interior\\civs\\Spore_WM_Grunt(2)",
    "PARIS\\area01\\belledenuit\\interior\\civs\\Spore_WM_Officer",
    "PARIS\\area01\\belledenuit\\interior\\civs\\Spore_GS_General",
    "PARIS\\area01\\belledenuit\\interior\\civs\\Spore_WM_Grunt(10)",
    "PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_Waiter_M(2)"
  }
  self.tWaiter2Paths = {
    "PARIS\\area01\\belledenuit\\interior\\civs\\Waiter2Path1",
    "PARIS\\area01\\belledenuit\\interior\\civs\\Waiter2Path2",
    "PARIS\\area01\\belledenuit\\interior\\civs\\Waiter2Path3",
    "PARIS\\area01\\belledenuit\\interior\\civs\\Waiter2Path4",
    "PARIS\\area01\\belledenuit\\interior\\civs\\Waiter2Path5"
  }
  self.tCustomers = {
    "PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_M_Patron_1(2)",
    "PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_WPop_MiddleClass(12)",
    "PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_M_Patron_9(2)",
    "PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_M_Patron_9(6)",
    "PARIS\\area01\\belledenuit\\interior\\civs\\Spore_CV_M_Patron_9(14)"
  }
  self.nSecondWaiterPath = 0
  self.nWaiterPathNumber = 0
  self.nNazisServed = 0
  self.nCustomersServed = 0
  BelleInteriorSceneManager.OnReady(self)
  BelleInteriorSceneManager.ActChooser(self)
end

function BelleInteriorSceneManager:GENERAL_OTHER_SETUP()
  self.sNadine = "PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_Doris_100(5)"
  self.nMinStageActs = 1
  self.nMaxStageActs = 5
  BelleInteriorSceneManager.OnReady(self)
  BelleInteriorSceneManager.ActChooser(self)
end

function BelleInteriorSceneManager:OnReady()
  self.m_tEvents.eStreamWaiters = nil
  self.hWaiter = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_Spore_CV_Waiter")
  self.hPierre = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_Spore_CV_Waiter(3)")
  local tEventWaiter1 = {
    EventType = "TimerEvent",
    EventName = "WaiterTimer",
    Time = 2.02
  }
  self.m_tEvents.eWaiterReady = Util.CreateEvent(tEventWaiter1, "BelleInteriorSceneManager.WaiterReady", self)
  local tEventWaiter2 = {
    EventType = "TimerEvent",
    EventName = "WaiterTimer2",
    Time = 3.03
  }
  self.m_tEvents.eWaiter2Ready = Util.CreateEvent(tEventWaiter2, "BelleInteriorSceneManager.Waiter2Ready", self)
end

function BelleInteriorSceneManager:WaiterReady()
  self.m_tEvents.eWaiterReady = nil
  Actor.EnableNeeds(self.hWaiter, false)
  Nav.SetScriptedPath(self.hWaiter, "PARIS\\area01\\belledenuit\\interior\\civs\\WaiterPath9", true, "BelleInteriorSceneManager.WaiterLoopNew", self)
end

function BelleInteriorSceneManager:Waiter2Ready()
  self.m_tEvents.eWaiter2Ready = nil
  Actor.EnableNeeds(self.hPierre, false)
  Actor.SetPanicEnabled(self.hPierre, false)
  Actor.ChangeModule(self.hPierre, "Human_Null")
  EVENT_Timer("BelleInteriorSceneManager.SecondWaiterLoop", self, 1)
end

function BelleInteriorSceneManager:OnDorissReady()
  self.hDoriss1 = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_DorissGirl(3)")
  self.hDoriss2 = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_DorissGirl")
  self.hDoriss3 = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleDeNuitCafe2ndFloor\\Spore_CV_DorissGirl(2)")
  local tEventalpha = {EventType = "TimerEvent", Time = 1}
  self.m_tEvents.eDorrisPoint1 = Util.CreateEvent(tEventalpha, "BelleInteriorSceneManager.DorrisPoint1", self)
  local tEventHussy1 = {EventType = "TimerEvent", Time = 1.5}
  self.m_tEvents.eDorris2Point1 = Util.CreateEvent(tEventHussy1, "BelleInteriorSceneManager.Dorris2Point1", self)
  local tEventHussie1 = {EventType = "TimerEvent", Time = 2.5}
  self.m_tEvents.eDorris3Point1 = Util.CreateEvent(tEventHussie1, "BelleInteriorSceneManager.Dorris3Point1", self)
end

function BelleInteriorSceneManager:DorrisPoint1()
  self.m_tEvents.eDorrisPoint1 = nil
  Actor.EnableNeeds(self.hDoriss1, false)
  Actor.SetPanicEnabled(self.hDoriss1, false)
  Actor.ChangeModule(self.hDoriss1, "Human_Null")
  Nav.SetScriptedPath(self.hDoriss1, "PARIS\\area01\\belledenuit\\interior\\civs\\DorissPath1", true, "BelleInteriorSceneManager.DorissFlirt1", self)
end

function BelleInteriorSceneManager:DorissFlirt1()
  local tDSequence1 = {
    {
      "TURNTOFACE",
      {
        "PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_M_Patron_17(2)"
      }
    },
    {
      "DELAY",
      {2}
    },
    {
      "PLAYANIMATION",
      {
        "civ_f_doris_flirt01"
      }
    },
    {
      "DELAY",
      {9}
    },
    {
      "CANCELANIMATION"
    }
  }
  ScriptSequence.Run(self.hDoriss1, tDSequence1)
  local tEventbeta = {EventType = "TimerEvent", Time = 13}
  self.m_tEvents.eDorrisPoint2 = Util.CreateEvent(tEventbeta, "BelleInteriorSceneManager.DorrisPoint2", self)
end

function BelleInteriorSceneManager:DorrisPoint2()
  self.m_tEvents.eDorrisPoint2 = nil
  Nav.SetScriptedPath(self.hDoriss1, "PARIS\\area01\\belledenuit\\interior\\civs\\DorissPath2", true, "BelleInteriorSceneManager.DorissFlirt2", self)
end

function BelleInteriorSceneManager:DorissFlirt2()
  local tDSequence2 = {
    {
      "TURNTOFACE",
      {
        "PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_M_Patron_19"
      }
    },
    {
      "DELAY",
      {2}
    },
    {
      "PLAYANIMATION",
      {
        "civ_f_doris_flirt01"
      }
    },
    {
      "DELAY",
      {9}
    },
    {
      "CANCELANIMATION"
    }
  }
  ScriptSequence.Run(self.hDoriss1, tDSequence2)
  local tEventgamma = {EventType = "TimerEvent", Time = 12}
  self.m_tEvents.eDorrisPoint3 = Util.CreateEvent(tEventgamma, "BelleInteriorSceneManager.DorrisPoint3", self)
end

function BelleInteriorSceneManager:DorrisPoint3()
  self.m_tEvents.eDorrisPoint3 = nil
  Nav.SetScriptedPath(self.hDoriss1, "PARIS\\area01\\belledenuit\\interior\\civs\\DorissPath3", true, "BelleInteriorSceneManager.DorissFlirt3", self)
end

function BelleInteriorSceneManager:DorissFlirt3()
  local tDSequence3 = {
    {
      "TURNTOFACE",
      {
        "PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_M_Patron_7"
      }
    },
    {
      "DELAY",
      {2}
    },
    {
      "PLAYANIMATION",
      {
        "civ_f_doris_flirt01"
      }
    },
    {
      "DELAY",
      {9}
    },
    {
      "CANCELANIMATION"
    }
  }
  ScriptSequence.Run(self.hDoriss1, tDSequence3)
  local tEventdelta = {EventType = "TimerEvent", Time = 12}
  self.m_tEvents.eDorrisPoint4 = Util.CreateEvent(tEventdelta, "BelleInteriorSceneManager.DorrisPoint4", self)
end

function BelleInteriorSceneManager:DorrisPoint4()
  self.m_tEvents.eDorrisPoint4 = nil
  Nav.SetScriptedPath(self.hDoriss1, "PARIS\\area01\\belledenuit\\interior\\civs\\DorissPath4", true, "BelleInteriorSceneManager.DorissFlirt4", self)
end

function BelleInteriorSceneManager:DorissFlirt4()
  local tDSequence4 = {
    {
      "TURNTOFACE",
      {
        "PARIS\\area01\\belledenuit\\interior\\civs\\Spore_WM_Grunt(11)"
      }
    },
    {
      "DELAY",
      {2}
    },
    {
      "PLAYANIMATION",
      {
        "civ_f_doris_flirt01"
      }
    },
    {
      "DELAY",
      {9}
    },
    {
      "CANCELANIMATION"
    }
  }
  ScriptSequence.Run(self.hDoriss1, tDSequence4)
  local tEventepsilon = {EventType = "TimerEvent", Time = 12}
  self.m_tEvents.eDorrisPoint1 = Util.CreateEvent(tEventepsilon, "BelleInteriorSceneManager.DorrisPoint1", self)
end

function BelleInteriorSceneManager:Dorris2Point1()
  self.m_tEvents.eDorris2Point1 = nil
  Actor.EnableNeeds(self.hDoriss2, false)
  Actor.SetPanicEnabled(self.hDoriss2, false)
  Actor.ChangeModule(self.hDoriss2, "Human_Null")
  Nav.SetScriptedPath(self.hDoriss2, "PARIS\\area01\\belledenuit\\interior\\civs\\Doriss2Path1", true, "BelleInteriorSceneManager.Doriss2Flirt1", self)
end

function BelleInteriorSceneManager:Doriss2Flirt1()
  Actor.UseAttrPt(self.hDoriss2, Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\AttractionPT_Sitforever(7)"))
  local tEventHussy2 = {EventType = "TimerEvent", Time = 12}
  self.m_tEvents.Dorris2Point2 = Util.CreateEvent(tEventHussy2, "BelleInteriorSceneManager.Dorris2Point2", self)
end

function BelleInteriorSceneManager:Dorris2Point2()
  self.m_tEvents.Dorris2Point2 = nil
  Actor.CancelAttrPt(self.hDoriss2)
  Nav.SetScriptedPath(self.hDoriss2, "PARIS\\area01\\belledenuit\\interior\\civs\\Doriss2Path2", true, "BelleInteriorSceneManager.Doriss2Flirt2", self)
end

function BelleInteriorSceneManager:Doriss2Flirt2()
  local tD2Sequence1 = {
    {
      "TURNTOFACE",
      {
        "PARIS\\area01\\belledenuit\\interior\\civs\\Spore_WM_Grunt(7)"
      }
    },
    {
      "DELAY",
      {2}
    },
    {
      "PLAYANIMATION",
      {
        "civ_f_doris_flirt01"
      }
    },
    {
      "DELAY",
      {9}
    },
    {
      "CANCELANIMATION"
    }
  }
  ScriptSequence.Run(self.hDoriss2, tD2Sequence1)
  local tEventHussy3 = {EventType = "TimerEvent", Time = 12}
  self.m_tEvents.Dorris2Point3 = Util.CreateEvent(tEventHussy3, "BelleInteriorSceneManager.Dorris2Point3", self)
end

function BelleInteriorSceneManager:Dorris2Point3()
  self.m_tEvents.Dorris2Point3 = nil
  Nav.SetScriptedPath(self.hDoriss2, "PARIS\\area01\\belledenuit\\interior\\civs\\Doriss2Path3", true, "BelleInteriorSceneManager.Doriss2Flirt3", self)
end

function BelleInteriorSceneManager:Doriss2Flirt3()
  Actor.UseAttrPt(self.hDoriss2, Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\AttractionPT_SitOnly(15)"))
  local tEventHussy4 = {EventType = "TimerEvent", Time = 12}
  self.m_tEvents.Dorris2Point4 = Util.CreateEvent(tEventHussy4, "BelleInteriorSceneManager.Dorris2Point4", self)
end

function BelleInteriorSceneManager:Dorris2Point4()
  self.m_tEvents.Dorris2Point4 = nil
  Actor.CancelAttrPt(self.hDoriss2)
  Nav.SetScriptedPath(self.hDoriss2, "PARIS\\area01\\belledenuit\\interior\\civs\\Doriss2Path4", true, "BelleInteriorSceneManager.Doriss2Flirt4", self)
end

function BelleInteriorSceneManager:Doriss2Flirt4()
  local tD2Sequence2 = {
    {
      "TURNTOFACE",
      {
        "PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_M_Patron_19(2)"
      }
    },
    {
      "DELAY",
      {2}
    },
    {
      "PLAYANIMATION",
      {
        "civ_f_doris_flirt01"
      }
    },
    {
      "DELAY",
      {9}
    },
    {
      "CANCELANIMATION"
    }
  }
  ScriptSequence.Run(self.hDoriss2, tD2Sequence2)
  local tEventHussy5 = {EventType = "TimerEvent", Time = 12}
  self.m_tEvents.Dorris2Point5 = Util.CreateEvent(tEventHussy5, "BelleInteriorSceneManager.Dorris2Point5", self)
end

function BelleInteriorSceneManager:Dorris2Point5()
  self.m_tEvents.Dorris2Point5 = nil
  Nav.SetScriptedPath(self.hDoriss2, "PARIS\\area01\\belledenuit\\interior\\civs\\Doriss2Path5", true, "BelleInteriorSceneManager.Doriss2Flirt1", self)
end

function BelleInteriorSceneManager:Dorris3Point1()
  self.m_tEvents.eDorris3Point1 = nil
  Actor.EnableNeeds(self.hDoriss3, false)
  Actor.SetPanicEnabled(self.hDoriss3, false)
  Actor.ChangeModule(self.hDoriss3, "Human_Null")
  Nav.SetScriptedPath(self.hDoriss3, "PARIS\\area01\\belledenuit\\interior\\civs\\Doriss3Path1", true, "BelleInteriorSceneManager.Doriss3Flirt1", self)
end

function BelleInteriorSceneManager:Doriss3Flirt1()
  Actor.UseAttrPt(self.hDoriss3, Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleDeNuitCafe2ndFloor\\AttractionPT_knock_on_door"))
  local tEventHussie2 = {EventType = "TimerEvent", Time = 10}
  self.m_tEvents.Dorris3Point2 = Util.CreateEvent(tEventHussie2, "BelleInteriorSceneManager.Dorris3Point2", self)
end

function BelleInteriorSceneManager:Dorris3Point2()
  self.m_tEvents.Dorris3Point2 = nil
  Nav.SetScriptedPath(self.hDoriss3, "PARIS\\area01\\belledenuit\\interior\\civs\\Doriss3Path2", true, "BelleInteriorSceneManager.Doriss3Flirt2", self)
end

function BelleInteriorSceneManager:Doriss3Flirt2()
  Actor.UseAttrPt(self.hDoriss3, Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleDeNuitCafe2ndFloor\\AttractionPT_knock_on_door(2)"))
  local tEventHussie3 = {EventType = "TimerEvent", Time = 10}
  self.m_tEvents.Dorris3Point3 = Util.CreateEvent(tEventHussie3, "BelleInteriorSceneManager.Dorris3Point3", self)
end

function BelleInteriorSceneManager:Dorris3Point3()
  self.m_tEvents.Dorris3Point3 = nil
  Nav.SetScriptedPath(self.hDoriss3, "PARIS\\area01\\belledenuit\\interior\\civs\\Doriss3Path3", true, "BelleInteriorSceneManager.Doriss3Flirt3", self)
end

function BelleInteriorSceneManager:Doriss3Flirt3()
  Actor.UseAttrPt(self.hDoriss3, Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleDeNuitCafe2ndFloor\\AttractionPT_knock_on_door(4)"))
  local tEventHussie4 = {EventType = "TimerEvent", Time = 10}
  self.m_tEvents.Dorris3Point4 = Util.CreateEvent(tEventHussie4, "BelleInteriorSceneManager.Dorris3Point4", self)
end

function BelleInteriorSceneManager:Dorris3Point4()
  self.m_tEvents.Dorris3Point4 = nil
  Nav.SetScriptedPath(self.hDoriss3, "PARIS\\area01\\belledenuit\\interior\\civs\\Doriss3Path4", true, "BelleInteriorSceneManager.Doriss3Flirt1", self)
end

function BelleInteriorSceneManager:OnPianoReady()
end

function BelleInteriorSceneManager:OnSpotlightReady()
  Trigger.WaitFor("PARIS\\area01\\belledenuit\\interior\\civs\\DemoEventTrigger", Util.GetHandleByName("Saboteur"), "BelleInteriorSceneManager.TurnLightsOffEvent", self, nil, cTRIGGEREVENT_ONENTER, false)
end

function BelleInteriorSceneManager:TurnLightsOffEvent()
  local hNadine = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_DorissGirl(5)")
  AttractionPt.FinishNow(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\AttractionPT_Doris_Sexy3"), Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_DorissGirl(5)"))
  Nav.SetScriptedPath(Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_DorissGirl(5)"), "PARIS\\area01\\belledenuit\\interior\\civs\\NadinePath", true, "BelleInteriorSceneManager.QueuetheMusic", self)
end

function BelleInteriorSceneManager:QueuetheMusic()
  self.m_tEvents.eStreamPiano = nil
  local hNadineAttrPt = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\civs\\AIAttractionPt_Civ_F_Sing")
  self.hNadineAttrPt = hNadineAttrPt
  local sNadine = "PARIS\\area01\\belledenuit\\interior\\civs\\BelleCrowd1stFloor\\Spore_CV_Doris_100(5)"
  local hNadine = Util.GetHandleByName(sNadine)
  Actor.RequestAttrPt(hNadine, self.hNadineAttrPt)
end

function BelleInteriorSceneManager:WaiterLoopNew()
  self.m_tEvents.eWaiterLoopNew = nil
  local sWaiterPath = self.tWaiterPaths[self.nWaiterPathNumber + 1]
  Nav.SetScriptedPath(self.hWaiter, sWaiterPath, false, "BelleInteriorSceneManager.StopandServe", self)
end

function BelleInteriorSceneManager:StopandServe()
  local sNaziServed = self.tNazisServed[self.nNazisServed + 1]
  if self.nNazisServed < 7 then
    local tSequence = {
      {
        "TURNTOFACE",
        {sNaziServed}
      },
      {
        "DELAY",
        {2}
      },
      {
        "PLAYANIMATION",
        {
          "Civ_waiter_takeorder"
        }
      },
      {
        "DELAY",
        {6}
      },
      {
        "CANCELANIMATION"
      }
    }
    ScriptSequence.Run(self.hWaiter, tSequence)
    self.nNazisServed = self.nNazisServed + 1
    if self.nWaiterPathNumber == 8 then
      self.nWaiterPathNumber = self.nWaiterPathNumber - 8
    else
      self.nWaiterPathNumber = self.nWaiterPathNumber + 1
    end
    self.m_tEvents.eWaiterLoopNew = EVENT_Timer("BelleInteriorSceneManager.WaiterLoopNew", self, 9)
  elseif self.nNazisServed == 7 then
    local tSequenceB = {
      {
        "TURNTOFACE",
        {sNaziServed}
      },
      {
        "DELAY",
        {2}
      },
      {
        "PLAYANIMATION",
        {"civ_chat2"}
      },
      {
        "DELAY",
        {8}
      },
      {
        "CANCELANIMATION"
      }
    }
    ScriptSequence.Run(self.hWaiter, tSequenceB)
    self.nNazisServed = self.nNazisServed + 1
    if self.nWaiterPathNumber == 8 then
      self.nWaiterPathNumber = self.nWaiterPathNumber - 8
    else
      self.nWaiterPathNumber = self.nWaiterPathNumber + 1
    end
    self.m_tEvents.eWaiterLoopNew = EVENT_Timer("BelleInteriorSceneManager.WaiterLoopNew", self, 11)
  elseif self.nNazisServed == 8 then
    self.nNazisServed = self.nNazisServed - 8
    if self.nWaiterPathNumber == 8 then
      self.nWaiterPathNumber = self.nWaiterPathNumber - 8
    else
      self.nWaiterPathNumber = self.nWaiterPathNumber + 1
    end
    self.m_tEvents.eWaiterLoopNew = EVENT_Timer("BelleInteriorSceneManager.WaiterLoopNew", self, 1)
  end
end

function BelleInteriorSceneManager:SecondWaiterLoop()
  self.m_tEvents.eSecondWaiterLoop = nil
  local sSecondWaiterPath = self.tWaiter2Paths[self.nSecondWaiterPath + 1]
  Nav.SetScriptedPath(self.hPierre, sSecondWaiterPath, true, "BelleInteriorSceneManager.TakeOrders", self)
end

function BelleInteriorSceneManager:TakeOrders()
  local sCustomers = self.tCustomers[self.nCustomersServed + 1]
  if self.nCustomersServed < 4 then
    local tSecondSequence = {
      {
        "TURNTOFACE",
        {sCustomers}
      },
      {
        "DELAY",
        {2}
      },
      {
        "PLAYANIMATION",
        {
          "Civ_waiter_takeorder"
        }
      },
      {
        "DELAY",
        {6}
      },
      {
        "CANCELANIMATION"
      }
    }
    ScriptSequence.Run(self.hPierre, tSecondSequence)
    self.nCustomersServed = self.nCustomersServed + 1
    if self.nSecondWaiterPath == 4 then
      self.nSecondWaiterPath = self.nSecondWaiterPath - 4
    else
      self.nSecondWaiterPath = self.nSecondWaiterPath + 1
    end
    self.m_tEvents.eSecondWaiterLoop = EVENT_Timer("BelleInteriorSceneManager.SecondWaiterLoop", self, 9)
  elseif self.nCustomersServed == 4 then
    local tSecondSequenceB = {
      {
        "TURNTOFACE",
        {sCustomers}
      },
      {
        "DELAY",
        {2}
      },
      {
        "PLAYANIMATION",
        {"civ_chat2"}
      },
      {
        "DELAY",
        {8}
      },
      {
        "CANCELANIMATION"
      }
    }
    ScriptSequence.Run(self.hPierre, tSecondSequenceB)
    self.nCustomersServed = self.nCustomersServed + 1
    if self.nSecondWaiterPath == 4 then
      self.nSecondWaiterPath = self.nSecondWaiterPath - 4
    else
      self.nSecondWaiterPath = self.nSecondWaiterPath + 1
    end
    self.m_tEvents.eSecondWaiterLoop = EVENT_Timer("BelleInteriorSceneManager.SecondWaiterLoop", self, 11)
  end
end

function BelleInteriorSceneManager:ActChooser()
  self.nMinStageActs = 1
  self.nMaxStageActs = 5
  self.nCurrentAct = math.random(self.nMinStageActs, self.nMaxStageActs)
  if self.nCurrentAct == 1 then
  elseif self.nCurrentAct == 2 then
  elseif self.nCurrentAct == 3 then
  elseif self.nCurrentAct == 4 then
  elseif self.nCurrentAct == 5 then
  end
end

function BelleInteriorSceneManager:SetupBouncer()
  self.hBouncer = Handle(self.sBouncer)
  self.sBouncerAttrPT = "PARIS\\area01\\belledenuit\\interior\\dlc\\AttractionPT_Bouncer_Idle"
  Actor.RequestAttrPt(Handle(self.hBouncer), Handle(self.sBouncerAttrPT))
  BelleInteriorSceneManager.BouncerProxyListener(self)
end

function BelleInteriorSceneManager:BouncerProxyListener()
  self.m_tEvents.eBouncerProxyListener = nil
  local tBouncerProxy = {
    EventType = "ProximityEvent",
    ObjectA = hSab,
    ObjectB = self.hBouncer,
    Proximity = 8
  }
  self.m_tEvents.eOnBouncerFires = Util.CreateEvent(tBouncerProxy, "BelleInteriorSceneManager.RunWaitSequence", self)
  local hSecretDoor = Util.GetHandleByName("PARIS\\area01\\belledenuit\\interior\\hq_int\\AnimatedObject_DLCDoor")
  Object.ForceClose(hSecretDoor)
end

function BelleInteriorSceneManager:RunWaitSequence()
  dprint(self, "Setting Up Bruno Neg Proxy")
  self.m_tEvents.eBouncerDLCcheck = nil
  local tBouncerProxy = {
    EventType = "ProximityEvent",
    ObjectA = hSab,
    ObjectB = self.hBouncer,
    Proximity = 1.4,
    Check3D = true
  }
  self.m_tEvents.eBouncerDLCcheck = Util.CreateEvent(tBouncerProxy, "BelleInteriorSceneManager.BrunoChecksDLC", self)
end

function BelleInteriorSceneManager:BrunoChecksDLC()
  Actor.CancelAnimation(self.hBouncer)
  ScriptSequence.Kill(self.hBouncer)
  Actor.PlayAnimation(self.hBouncer, "BOUNCER_BRUNO_IDLE")
  if _g_bHasMidnightShowDLC then
    if SabTask._tMiscSaveTable and not SabTask._tMiscSaveTable.bPlayedBouncerVIPYesConv then
      SabTask._tMiscSaveTable.bPlayedBouncerVIPYesConv = true
      Cin.PlayConversation("DLC_VIP_Room_Yes")
    end
    dprint(self, "Bruno checks for DLC ticket")
    Actor.PlayAnimation(self.hBouncer, "BOUNCER_BRUNO_ALLOW")
    Object.ForceOpen(Handle("PARIS\\area01\\belledenuit\\interior\\hq_int\\AnimatedObject_DLCDoor"))
  else
    Cin.PlayConversation("DLC_VIP_Room_No")
    dprint(self, "Bruno says NO TICKET, NO ENTRANCE")
    Actor.PlayAnimation(self.hBouncer, "BOUNCER_BRUNO_DENY")
  end
  BelleInteriorSceneManager.ResetBrunoTalksOnce(self)
end

function BelleInteriorSceneManager:ResetBrunoTalksOnce()
  Trigger.WaitFor("PARIS\\area01\\belledenuit\\interior\\dlc\\PT_ResetBrunoTalks", hSab, "BelleInteriorSceneManager.BouncerProxyListener", self, nil, cTRIGGEREVENT_ONENTER, "PARIS\\area01\\belledenuit\\interior\\dlc\\PT_ResetBrunoTalks")
end

function BelleInteriorSceneManager:CoatCheck_CheckandPlay()
  Render.PrintMessage("CoatCheckGirl is in")
  local sCheckGirlTrig = "PARIS\\area01\\belledenuit\\interior\\events\\CoatCheckGirlTrig"
  Trigger.WaitFor(sCheckGirlTrig, hSab, "BelleInteriorSceneManager.PlayWeaponRemoveConvo", self, nil, cTRIGGEREVENT_ONENTER, false)
end

function BelleInteriorSceneManager:CheckForPlayer()
  repeat
    if not SabTask._tMiscSaveTable.bPlayedBelleWeaponsConv and Belle_Interior.sLocator == "PARIS\\area01\\belledenuit\\interior\\hq_int\\LOC_Belle_int" then
      local hCheckGirl = Handle("PARIS\\area01\\belledenuit\\interior\\coatcheck\\Spore_CV_DorissGirl_WeaponCheck")
      if Inventory.HasAnyGuns(hSab) == true then
        local tProxyPlayer = {
          EventType = "ProximityEvent",
          ObjectA = hSab,
          ObjectB = hCheckGirl,
          Proximity = 6
        }
        self.m_tEvents.eCoatCheckProxyFace = Util.CreateEvent(tProxyPlayer, "BelleInteriorSceneManager.PlayWeaponRemoveConvo", self)
      else
      end
    else
    end
    break -- pseudo-goto
  until true
end

function BelleInteriorSceneManager:PlayWeaponRemoveConvo()
  repeat
    if not SabTask._tMiscSaveTable.bPlayedBelleWeaponsConv then
      local hEntryPoint = Handle("PARIS\\area01\\belledenuit\\interior\\hq_int\\LOC_Belle_int")
      if Object.GetDistance(hSab, hEntryPoint) <= 10 and Inventory.HasAnyGuns(hSab) == true then
        SabTask._tMiscSaveTable.bPlayedBelleWeaponsConv = true
        EVENT_Timer("BelleInteriorSceneManager.PlayBelleConvoNoGuns", self, 1)
      else
      end
      break -- pseudo-goto
    end
  until true
end

function BelleInteriorSceneManager:PlayBelleConvoNoGuns()
  Cin.PlayConversation("000_Belle_WeaponCheck")
end

function BelleInteriorSceneManager:SetObjectStreamEvents()
  self.m_tEvents.eStreamCoatCheck = Util.CreateEvent({
    EventType = "StreamEvent",
    EventName = "StreamCoatCheck",
    Objects = {
      "PARIS\\area01\\belledenuit\\interior\\coatcheck\\Spore_CV_DorissGirl_WeaponCheck"
    }
  }, "BelleInteriorSceneManager.CheckForPlayer", self)
  self.m_tEvents.eStreamWaiters = Util.CreateEvent({
    EventType = "StreamEvent",
    EventName = "StreamWaiters",
    Objects = self.tWaiterStreamObjs
  }, "BelleInteriorSceneManager.OnWaitersSet", self)
  self.m_tEvents.eStreamBruno = Util.CreateEvent({
    EventType = "StreamEvent",
    EventName = "StreamBruno",
    Objects = {
      self.sBouncer
    }
  }, "BelleInteriorSceneManager.SetupBouncer", self)
  BelleInteriorSceneManager.OnBackGirlsSet(self)
end

function BelleInteriorSceneManager:OnWaitersSet()
  Render.PrintMessage("Waiters Streamed")
  local hWaiter1 = Handle(self.tWaitresses[1])
  local hWaiter2 = Handle(self.tWaitresses[2])
  local hWaiter3 = Handle(self.tWaitresses[3])
  self.hWaiter1 = hWaiter1
  self.hWaiter2 = hWaiter2
  self.hWaiter3 = hWaiter3
  table.insert(self.m_tEvents, EVENT_Timer("BelleInteriorSceneManager.ConquerandDivide", self, 5, 1))
  table.insert(self.m_tEvents, EVENT_Timer("BelleInteriorSceneManager.ConquerandDivide", self, 7, 2))
  table.insert(self.m_tEvents, EVENT_Timer("BelleInteriorSceneManager.ConquerandDivide", self, 9, 3))
end

function BelleInteriorSceneManager:ConquerandDivide(a_nWait)
  local nWait = a_nWait
  if nWait == 1 then
    BelleInteriorSceneManager.StartWaiter1IncrementLoop(self)
  elseif nWait == 2 then
    BelleInteriorSceneManager.StartWaiter2IncrementLoop(self)
  elseif nWait == 3 then
    BelleInteriorSceneManager.StartWaiter3IncrementLoop(self)
  end
end

function BelleInteriorSceneManager:StartWaiter1IncrementLoop()
  local nInc = self.nWait1
  self.nInc = nInc
  local sWaiterPath = self.tWaiter1Paths[nInc]
  Nav.SetScriptedPath(self.hWaiter1, sWaiterPath, true, "BelleInteriorSceneManager.SetAttractionPoint1Int", self)
end

function BelleInteriorSceneManager:SetAttractionPoint1Int()
  local hWaitingTable = Handle(self.tWaiter1AtPts[self.nInc])
  Actor.RequestAttrPt(self.hWaiter1, hWaitingTable, "BelleInteriorSceneManager.SetBackTo1Loop", self)
end

function BelleInteriorSceneManager:SetBackTo1Loop()
  if self.nWait1 < 5 then
    self.nWait1 = self.nWait1 + 1
  elseif self.nWait1 == 5 then
    self.nWait1 = 1
  end
  BelleInteriorSceneManager.StartWaiter1IncrementLoop(self)
end

function BelleInteriorSceneManager:StartWaiter2IncrementLoop()
  local nInc2 = self.nWait2
  self.nInc2 = nInc2
  local sWaiterPath2 = self.tWaiter2Paths[nInc2]
  Nav.SetScriptedPath(self.hWaiter2, sWaiterPath2, true, "BelleInteriorSceneManager.SetAttractionPoint2Int", self)
end

function BelleInteriorSceneManager:SetAttractionPoint2Int()
  local hWaitingTable2 = Handle(self.tWaiter2AtPts[self.nInc2])
  Actor.RequestAttrPt(self.hWaiter2, hWaitingTable2, "BelleInteriorSceneManager.SetBackTo2Loop", self)
end

function BelleInteriorSceneManager:SetBackTo2Loop()
  if self.nWait2 < 5 then
    self.nWait2 = self.nWait2 + 1
  elseif self.nWait2 == 5 then
    self.nWait2 = 1
  end
  BelleInteriorSceneManager.StartWaiter2IncrementLoop(self)
end

function BelleInteriorSceneManager:StartWaiter3IncrementLoop()
  local nInc3 = self.nWait3
  self.nInc3 = nInc3
  local sWaiterPath3 = self.tWaiter3Paths[nInc3]
  Nav.SetScriptedPath(self.hWaiter3, sWaiterPath3, true, "BelleInteriorSceneManager.SetAttractionPoint3Int", self)
end

function BelleInteriorSceneManager:SetAttractionPoint3Int()
  local hWaitingTable3 = Handle(self.tWaiter3AtPts[self.nInc3])
  Actor.RequestAttrPt(self.hWaiter3, hWaitingTable3, "BelleInteriorSceneManager.SetBackTo3Loop", self)
end

function BelleInteriorSceneManager:SetBackTo3Loop()
  if self.nWait3 < 5 then
    self.nWait3 = self.nWait3 + 1
  elseif self.nWait3 == 5 then
    self.nWait3 = 1
  end
  BelleInteriorSceneManager.StartWaiter3IncrementLoop(self)
end

function BelleInteriorSceneManager:OnBackGirlsSet()
  if IsMissionCompleted("Paris_1_Mission_1B") and not SabTask._tMiscSaveTable.bDorissChatterConv then
    EVENT_PlayerEntersTrigger("BelleInteriorSceneManager.OnTriggerDoriss", self, "PARIS\\area01\\belledenuit\\interior\\events\\PT_DorissBackRoomConvo", false)
  end
end

function BelleInteriorSceneManager:OnTriggerDoriss()
  SabTask._tMiscSaveTable.bDorissChatterConv = true
  Cin.PlayConversation("P1M1_Belle_TaskStart_02")
end
