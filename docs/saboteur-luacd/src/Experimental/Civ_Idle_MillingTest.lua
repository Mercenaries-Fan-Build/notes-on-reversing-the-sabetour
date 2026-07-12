if not Civ_Idle_MillingTest then
  Civ_Idle_MillingTest = {}
end

function Civ_Idle_MillingTest.OnEnter(thisHandle)
  Render.PrintMessage("Civ_Idle_MillingTest.OnEnter() for " .. Util.GetNameFromHandle(thisHandle))
  Nav.MoveToPoint(thisHandle, 2.25, 0.5, 40.75, false, "Civ_Idle_MillingTest.OnReachedPt1", {Civ = thisHandle})
end

function Civ_Idle_MillingTest.OnFirstEnemy(thisHandle)
end

function Civ_Idle_MillingTest.OnLastEnemy(thisHandle)
end

function Civ_Idle_MillingTest.OnExit(thisHandle)
end

function Civ_Idle_MillingTest.OnReachedPt1(tArgs)
  Nav.MoveToPoint(tArgs.Civ, 24, 0.5, 40.75, false, "Civ_Idle_MillingTest.OnReachedPt2", tArgs)
end

function Civ_Idle_MillingTest.OnReachedPt2(tArgs)
  Nav.MoveToPoint(tArgs.Civ, 2.25, 0.5, 40.75, false, "Civ_Idle_MillingTest.OnReachedPt1", tArgs)
end
