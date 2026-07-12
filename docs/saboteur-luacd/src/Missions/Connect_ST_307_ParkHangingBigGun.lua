if Connect_ST_307_ParkHangingBigGun == nil then
  Connect_ST_307_ParkHangingBigGun = SabTaskObjective:Create()
  Connect_ST_307_ParkHangingBigGun:Configure({
    TaskCount = 99,
    sStarter = "Luc_Hangman_Exterior",
    sConvFile = "307_Con_BigGun",
    tDependencyList = {
      "Connect_ST_302_ParisReturnVittore",
      "P2FP_RadioRescue"
    },
    MCDisplayID = 2,
    tUnlockList = {
      "Paris_5_Mission_3"
    },
    tSMEDNodes = {
      "Missions\\act_3\\connect_st_307_parkhangingbiggun"
    }
  })
end

function Connect_ST_307_ParkHangingBigGun:STARTER_Setup()
  self:TrafficTrigger()
  EVENT_Timer("Connect_ST_307_ParkHangingBigGun.DeathEvents", self, 5)
end

function Connect_ST_307_ParkHangingBigGun:DeathEvents()
end

function Connect_ST_307_ParkHangingBigGun:Activated()
  SabTaskObjective.Activated(self)
  self.GENERAL_Setup(self)
end

function Connect_ST_307_ParkHangingBigGun:GENERAL_Setup()
  self:CompleteThisMission()
  self:AddOnCancelCallback(Connect_ST_307_ParkHangingBigGun.Reset)
  self:AddOnCompleteCallback(Connect_ST_307_ParkHangingBigGun.Reset)
  Actor.SetVehicleAvoidance(Handle(self:GetStarter()), false)
end

function Connect_ST_307_ParkHangingBigGun:Reset()
  Vehicle.EnableTraffic(true)
end

function Connect_ST_307_ParkHangingBigGun:TrafficTrigger()
  EVENT_PlayerEntersTrigger("Connect_ST_307_ParkHangingBigGun.EnableTraffic", self, "Missions\\paris_2\\characters\\luc_exterior\\REG_TrafficFree", true, {false})
  EVENT_PlayerExitsTrigger("Connect_ST_307_ParkHangingBigGun.EnableTraffic", self, "Missions\\paris_2\\characters\\luc_exterior\\REG_TrafficFree", true, {true})
end

function Connect_ST_307_ParkHangingBigGun:EnableTraffic(tUserData, bOn)
  print(" enable traffic ", bOn)
  Vehicle.EnableTraffic(bOn)
end

function Connect_ST_307_ParkHangingBigGun:Failure()
  print("FAILURE: Luc is dead!")
end
