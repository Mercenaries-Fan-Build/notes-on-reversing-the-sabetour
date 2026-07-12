if Connect_ST_306_BishopMeeting == nil then
  Connect_ST_306_BishopMeeting = SabTaskObjective:Create()
  gsConnectST306Dir = "Missions\\paris_2\\connect_st305_bishopmeeting\\"
  Connect_ST_306_BishopMeeting:Configure({
    TaskCount = 99,
    sStarter = "bishop_st306_ext",
    ProximityStart = 2,
    MCDisplayID = 2,
    sSaveMissionNameID = "MissionNames_Text.ST_306",
    bDisableMissionTitle = true,
    bEscalationDenial = true,
    tUnlockList = {
      "NOTE_308a",
      "SOE_2_Mission_2"
    },
    tSMEDNodes = {}
  })
end

function Connect_ST_306_BishopMeeting:STARTER_Setup()
  Util.SpawnEditNode("Missions\\act_1\\characters\\wilcox_bishopmeeting_ext.wsd")
end

function Connect_ST_306_BishopMeeting:SetStageEvent()
  local hBishop = Util.GetHandleByName("Missions\\paris_2\\connect_st305_bishopmeeting\\bishopandcar\\bishop_st306_ext")
  local tProxiEvent = {
    EventType = "ProximityEvent",
    EventName = "LoadCar",
    ObjectA = hSab,
    ObjectB = hBishop,
    Proximity = 25
  }
  local eEvent = Util.CreateEvent(tProxiEvent, "Connect_ST_306_BishopMeeting.CarStaging", self)
end

function Connect_ST_306_BishopMeeting:CarStaging()
  local hBishop = Util.GetHandleByName("Missions\\paris_2\\connect_st305_bishopmeeting\\bishopandcar\\bishop_st306_ext")
  local hBishopCar = Util.GetHandleByName("Missions\\paris_2\\connect_st305_bishopmeeting\\bishopandcar\\VH_CV_CR_Horch853_01_Bishop")
  Nav.BoardVehicle(hBishop, hBishopCar, "SHOTGUN")
end

function Connect_ST_306_BishopMeeting:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Connect_ST_306_BishopMeeting:GENERAL_Setup()
  print("General Setup")
  self:RegisterCheckpoint("Connect_ST_306_BishopMeeting.Checkpoint1")
end

function Connect_ST_306_BishopMeeting:Checkpoint1()
  print("General Setup")
  if not self:IsMissionTaskActive("Task_FirstObjective") then
    self:Task_FirstObjective()
  end
end

function Connect_ST_306_BishopMeeting:Task_FirstObjective()
  self:CreateTask({
    sName = "Connect_ST_306_BishopMeeting_Task_FirstObjective",
    sTaskType = "SabTaskObjectiveEmpty",
    sTaskSubType = "empty",
    tOnActivate = {
      {
        self.Task_Convo,
        {self}
      }
    },
    tOnComplete = {}
  })
end

function Connect_ST_306_BishopMeeting:Task_Convo()
  self:CreateTask({
    sName = "Connect_ST_306_BishopMeeting_Task_Convo",
    sTaskType = "SabTaskObjectiveInteract",
    sTaskSubType = "TALK",
    sConvFile = "306_Con_CarMeet",
    tTgtInclude = {
      "Missions\\paris_2\\connect_st305_bishopmeeting\\bishopandcar\\bishop_st306_ext"
    },
    bAutofire = true,
    tOnActivate = {},
    tOnComplete = {
      {
        self.BishWilDriveAway,
        {self}
      }
    }
  })
end

function Connect_ST_306_BishopMeeting:CarStaging()
  local hBishop = Util.GetHandleByName("Missions\\paris_2\\connect_st305_bishopmeeting\\bishopandcar\\bishop_st306_ext")
  local hBishopCar = Util.GetHandleByName("Missions\\paris_2\\connect_st305_bishopmeeting\\bishopandcar\\VH_CV_CR_Horch853_01_Bishop")
end

function Connect_ST_306_BishopMeeting:BishWilDriveAway()
  EVENT_Timer("Connect_ST_306_BishopMeeting.ConnectCleanup", self, 30)
  self.sBishop = "Missions\\paris_2\\connect_st305_bishopmeeting\\bishopandcar\\bishop_st306_ext"
  self.sWilcox = "Missions\\act_1\\characters\\wilcox_bishopmeeting_ext\\wilcox_st306_ext"
  self.sBishCar = "Missions\\paris_2\\connect_st305_bishopmeeting\\bishopandcar\\VH_CV_CR_Horch853_01_Bishop"
  local hBishop = Handle("Missions\\paris_2\\connect_st305_bishopmeeting\\bishopandcar\\bishop_st306_ext")
  local hWilcox = Handle("Missions\\act_1\\characters\\wilcox_bishopmeeting_ext\\wilcox_st306_ext")
  local hBishCar = Handle("Missions\\paris_2\\connect_st305_bishopmeeting\\bishopandcar\\VH_CV_CR_Horch853_01_Bishop")
  Vehicle.LockAllSeats(hBishCar, true)
  Actor.CancelAttrPtRequest(hBishop, true)
  Combat.SetIdleScripted(hBishop, true)
  Nav.BoardVehicle(hBishop, hBishCar, "SHOTGUN")
  Combat.SetIdleScripted(hWilcox, true)
  Nav.BoardVehicle(hWilcox, hBishCar, "PILOT")
  EVENT_ActorEntersAnyVehicle("Connect_ST_306_BishopMeeting.OnEntersVehicle", self, hBishop)
end

function Connect_ST_306_BishopMeeting:OnEntersVehicle()
  self.sBishopDriveAwayPath = "Missions\\paris_2\\connect_st305_bishopmeeting\\bishopandcar\\BishWilPath"
  local hBishCar = Handle("Missions\\paris_2\\connect_st305_bishopmeeting\\bishopandcar\\VH_CV_CR_Horch853_01_Bishop")
  Nav.SetScriptedPath(hBishCar, self.sBishopDriveAwayPath, false)
  Nav.SetScriptedPathSpeed(hBishCar, 35)
end

function Connect_ST_306_BishopMeeting:ConnectCleanup()
  Util.UnloadEditNode("Missions\\act_1\\characters\\wilcox_bishopmeeting_ext.wsd", false, true)
  Connect_ST_306_BishopMeeting.CompleteThisMission(self)
end
