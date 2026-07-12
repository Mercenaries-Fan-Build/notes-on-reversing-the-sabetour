if not P1M1TransitionMonitor then
  P1M1TransitionMonitor = {}
end

function P1M1TransitionMonitor:OnEnter()
  P1M1TransitionMonitor.General_Setup(P1M1TransitionMonitor)
end

function P1M1TransitionMonitor:General_Setup()
  self.sDebugLabel = "P1M1TransitionMonitor"
  self.bDebugMode = false
  self.nBoomNo = 0
  self.tLargeTanks = {
    "PARIS\\area01\\garedelest\\nazifueldepot\\wtf_l\\OccMed_OilTank_F_Support(5)\\OccMed_OilTank_F_Tank",
    "PARIS\\area01\\garedelest\\nazifueldepot\\wtf_l\\OccMed_OilTank_F_Support(4)\\OccMed_OilTank_F_Tank",
    "PARIS\\area01\\garedelest\\nazifueldepot\\wtf_l\\OccMed_OilTank_F_Support(3)\\OccMed_OilTank_F_Tank",
    "PARIS\\area01\\garedelest\\nazifueldepot\\wtf_l\\OccMed_OilTank_F_Support\\OccMed_OilTank_F_Tank",
    "PARIS\\area01\\garedelest\\nazifueldepot\\wtf_l\\OccMed_OilTank_E(6)\\OccMed_OilTank_E",
    "PARIS\\area01\\garedelest\\nazifueldepot\\wtf_l\\OccMed_OilTank_E(3)\\OccMed_OilTank_E",
    "PARIS\\area01\\garedelest\\nazifueldepot\\wtf_l\\OccMed_OilTank_E(4)\\OccMed_OilTank_E",
    "PARIS\\area01\\garedelest\\nazifueldepot\\wtf_l\\OccMed_OilTank_E(2)\\OccMed_OilTank_E",
    "PARIS\\area01\\garedelest\\nazifueldepot\\wtf_l\\OccMed_OilTank_C(13)\\OccMed_OilTank_C",
    "PARIS\\area01\\garedelest\\nazifueldepot\\wtf_l\\OccMed_OilTank_C(9)\\OccMed_OilTank_C",
    "PARIS\\area01\\garedelest\\nazifueldepot\\wtf_l\\OccMed_OilTank_Combo_A_X6Z3(4)\\OccMed_OilTank_Combo_A_X6Z3",
    "PARIS\\area01\\garedelest\\nazifueldepot\\wtf_l\\OccMed_OilTank_E(7)\\OccMed_OilTank_E"
  }
end

function P1M1TransitionMonitor:GoBoom()
  self = P1M1TransitionMonitor
  self.nBoomNo = self.nBoomNo + 1
  local sBoomObject = self.tLargeTanks[self.nBoomNo]
  local hBoomObject = Util.GetHandleByName(sBoomObject)
  if self.nBoomNo <= 12 then
    if Object.IsAlive(hBoomObject) == true then
      Object.Kill(hBoomObject)
      P1M1TransitionMonitor.SetDelayOnBoomers(P1M1TransitionMonitor)
    elseif Object.IsAlive(hBoomObject) == false then
      P1M1TransitionMonitor.SetDelayOnBoomers(P1M1TransitionMonitor)
    end
  else
    if self.nBoomNo == 13 then
    else
    end
  end
end

function P1M1TransitionMonitor:SetDelayOnBoomers()
  local nTimerDelayValue = math.random(1, 3)
  EVENT_Timer("P1M1TransitionMonitor.GoBoom", self, nTimerDelayValue)
end
