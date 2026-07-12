Checkpoint_v2 = {}

function Checkpoint_v2.Create(tParams)
  local self = {}
  self.sGuard = tParams.sGuard
  self.sGlaringGuy = tParams.sGlaringGuy
  self.sRailCrossing = tParams.sRailCrossing
  self.sPapers = tParams.sPapers
  self.sTrigger = tParams.sTrigger
  for i, v in pairs(tParams) do
    print("tParams i, v", i, v)
  end
  for i, v in pairs(self) do
    print("self i, v", i, v)
  end
  local hTrigger = Util.GetHandleByName(self.sTrigger)
  local e = {
    EventType = "OnTriggerEnter",
    Target = hTrigger
  }
  Util.CreateEvent(e, "Checkpoint_v2.OnCheckpointTriggered", self)
  return self
end

function Checkpoint_v2:OnCheckpointTriggered(userTable)
  self.uTrigger = userTable[1]
  self.uTriggerer = userTable[2]
  self.uGuard = Util.GetHandleByName(self.sGuard)
  self.uGlaringGuy = Util.GetHandleByName(self.sGlaringGuy)
  Render.PrintMessage("Gate Guard has been triggered!")
  local uPlayerChar = Util.GetHandleByName("Saboteur")
  if self.uTriggerer == uPlayerChar then
    self.uAttrPt = Object.AttractionPtCreate("AttractionPT_PersonCheck", 0, 0, 0, 0, uPlayerChar)
    local targetPos = Object.AttractionPtGetTargetPos(self.uAttrPt)
    Nav.MoveToPoint(self.uGuard, targetPos.x, targetPos.y + 0.2, targetPos.z, false, "Checkpoint_v2.CheckPapers", self)
    Nav.MoveToPoint(self.uGlaringGuy, targetPos.x + 4, targetPos.y + 0.2, targetPos.z)
    Util.EnableTrigger(self.sTrigger, false)
  end
end

function Checkpoint_v2:CheckPapers()
  Render.PrintMessage("Checking for " .. self.sPapers .. " papers!")
  Actor.UseAttrPt(self.uGuard, self.uAttrPt)
  Render.PrintDialogue(self.uGlaringGuy, "*glare*", 5)
  local bHasPapers = true
  local e = {
    EventType = "OnActorComplete",
    Target = self.uAttrPt
  }
  if bHasPapers then
    Object.AttractionPtSetAnimation(self.uAttrPt, cATTRPT_OUTOF, "nazi_wave_vehicle_1")
    Util.CreateEvent(e, "Checkpoint_v2.HasPapers", self)
  else
    Util.CreateEvent(e, "Checkpoint_v2.HasNoPapers", self)
  end
end

function Checkpoint_v2:HasNoPapers()
  Render.PrintMessage("Player does not have " .. self.sPapers .. " papers!")
  Render.PrintDialogue(self.uGuard, "Hey, you're no Nazi!", 3)
  Actor.ChangeModule(self.uGuard, "CombatNaziGrunt_Melee")
  Actor.ChangeModule(self.uGlaringGuy, "CombatNaziGrunt_Melee")
  Actor.SetModuleInputs(self.uGuard, "CombatNaziGrunt_Melee", {
    uTarget = self.uTriggerer
  })
  Actor.SetModuleInputs(self.uGlaringGuy, "CombatNaziGrunt_Melee", {
    uTarget = self.uTriggerer
  })
  Checkpoint_v2.Cleanup(self)
end

function Checkpoint_v2:HasPapers()
  Render.PrintMessage("Player has " .. self.sPapers .. " papers!")
  local uRailCrossing = Util.GetHandleByName(self.sRailCrossing)
  local uRailAttrPt = Object.AttractionPtFindPtInObject(uRailCrossing, "OpenLocAttr")
  local pos = Object.AttractionPtGetTargetPos(uRailAttrPt)
  Render.PrintDialogue(self.uGuard, "Your papers look fine!", 2)
  self.uRailAttrPt = uRailAttrPt
  Nav.MoveToPoint(self.uGuard, pos.x, pos.y, pos.z, false, "Checkpoint_v2.OpenGate", self)
end

function Checkpoint_v2:OpenGate()
  Render.PrintMessage("Opening " .. self.sRailCrossing .. "...")
  Actor.UseAttrPt(self.uGuard, self.uRailAttrPt)
  local e = {
    EventType = "OnActorComplete",
    Target = self.uRailAttrPt
  }
  local id = Util.CreateEvent(e, "Checkpoint_v2.GateOpened", self)
  self.eRailOnActorComplete = id
end

function Checkpoint_v2:GateOpened()
  Render.PrintMessage("Open Sesame!")
  Object.OpenDoor(self.sRailCrossing, "pow_vo_bar")
  Checkpoint_v2.Cleanup(self)
  Checkpoint_v2.Reset(self)
end

function Checkpoint_v2:Cleanup()
  Object.AttractionPtDelete(self.uAttrPt)
  if self.eRailOnActorComplete then
    Util.KillEvent(self.eRailOnActorComplete)
    self.eRailOnActorComplete = nil
  end
end

function Checkpoint_v2:Reset()
  Util.EnableTrigger(self.sTrigger, true)
end
