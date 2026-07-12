if not testCrossingGuard then
  testCrossingGuard = {}
end
setmetatable(testCrossingGuard, {__index = IdleCiv})

function testCrossingGuard.OnCheckpointTriggered(userTable)
  userTable.uTrigger = userTable["1"]
  userTable.uTriggerer = userTable["2"]
  userTable.uGuard = userTable.thisHandle
  Render.PrintMessage("Gate Guard has been triggered!")
  local uPlayerChar = Util.FindObjectHandle("Saboteur")
  if userTable.uTriggerer == uPlayerChar then
    userTable.uAttrPt = Object.AttractionPtCreate("AttractionPT_PersonCheck", 0, 0, 0, 0, uPlayerChar)
    local targetPos = Object.AttractionPtGetTargetPos(userTable.uAttrPt)
    Nav.MoveToPoint(userTable.uGuard, targetPos.x, targetPos.y + 0.2, targetPos.z, false, "testCrossingGuard.CheckPapers", userTable)
  end
end

function testCrossingGuard.CheckPapers(userTable)
  Render.PrintMessage("Checking for " .. userTable.sPapers .. " papers!")
  Actor.UseAttrPt(userTable.uGuard, userTable.uAttrPt)
  local bHasPapers = true
  if bHasPapers then
    Object.AttractionPtSetAnimation(userTable.uAttrPt, cATTRPT_OUTOF, "nazi_wave_vehicle_1")
    Util.RegisterListener(userTable.uAttrPt, "OnActorComplete", "testCrossingGuard.HasPapers", userTable)
  else
    Util.RegisterListener(userTable.uAttrPt, "OnActorComplete", "testCrossingGuard.HasNoPapers", userTable)
  end
end

function testCrossingGuard.HasNoPapers(userTable)
  Render.PrintMessage("Player does not have " .. userTable.sPapers .. " papers!")
  Render.PrintDialogue(userTable.uGuard, "Hey, you're no Nazi!", 3)
  Actor.ChangeModule(userTable.uGuard, "CombatNaziGrunt_Melee")
  Actor.SetModuleInputs(userTable.uGuard, "CombatNaziGrunt_Melee", {uTarget = "Saboteur"})
  testCrossingGuard.Cleanup(userTable)
end

function testCrossingGuard.HasPapers(userTable)
  Render.PrintMessage("Player has " .. userTable.sPapers .. " papers!")
  local uRailCrossing = Util.FindObjectHandle(userTable.sRailCrossing)
  local uRailAttrPt = Object.AttractionPtFindPtInObject(uRailCrossing, "OpenLocAttr")
  local pos = Object.AttractionPtGetTargetPos(uRailAttrPt)
  Render.PrintDialogue(userTable.uGuard, "Your papers look fine!", 2)
  userTable.uRailAttrPt = uRailAttrPt
  Nav.MoveToPoint(userTable.uGuard, pos.x, pos.y, pos.z, false, "testCrossingGuard.OpenGate", userTable)
end

function testCrossingGuard.OpenGate(userTable)
  Render.PrintMessage("Opening " .. userTable.sRailCrossing .. "...")
  Actor.UseAttrPt(userTable.uGuard, userTable.uRailAttrPt)
  Util.RegisterListener(userTable.uRailAttrPt, "OnActorComplete", "testCrossingGuard.GateOpened", userTable)
end

function testCrossingGuard.GateOpened(userTable)
  Render.PrintMessage("Open Sesame!")
  Object.OpenDoor(userTable.sRailCrossing, "pow_vo_bar")
  testCrossingGuard.Cleanup(userTable)
end

function testCrossingGuard.Cleanup(userTable)
  Object.AttractionPtDelete(userTable.uAttrPt)
  Util.UnregisterListener(userTable.uRailAttrPt, "OnActorComplete")
end
