if IdleNaziGrunt == nil then
  IdleNaziGrunt = {}
end

function IdleNaziGrunt.CallbackArrivedHome(thisHandle)
  Nav.MoveToSchedulePoint(thisHandle, "ungrouped objects/Nazi_Work", true, "CallbackArrivedWork")
  Util.CreateEvent({
    EventType = "ProximityEvent",
    EventName = "Goo",
    ObjectA = thisHandle,
    ObjectB = Util.FindObjectHandle("Saboteur"),
    Proximity = 5,
    Negate = false
  }, "OnReachedWaveSpot", thisHandle)
end

function IdleNaziGrunt.CallbackArrivedWork(thisHandle)
  Actor.EnableSchedule(thisHandle, true)
end

function IdleNaziGrunt.OnEnter(thisHandle)
  IdleNaziGrunt.CallbackArrivedWork(thisHandle)
end

function IdleNaziGrunt.OnExit(thisHandle)
end

function IdleNaziGrunt.OnFirstEnemy(thisHandle, enemyHandle)
end

function IdleNaziGrunt.OnLastEnemy(thisHandle)
end

function IdleNaziGrunt.OnReachedWaveSpot(userHandle)
end

function IdleNaziGrunt.OnWaveToTheNicePeople(tableData)
  print(tableData.Goo)
  print(tableData.Foo)
  print(tableData.Bar)
end
