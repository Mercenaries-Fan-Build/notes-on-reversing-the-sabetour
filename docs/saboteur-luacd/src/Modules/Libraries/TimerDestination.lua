if TimerDestination == nil then
  TimerDestination = {}
  TimerDestination.bRunning = false
  TimerDestination.nDistance = 1000
  TimerDestination.nLastShortestDistance = 1000
  TimerDestination.nMaxMinutePerSec = 1
  TimerDestination.nHour = 0
  TimerDestination.nMinute = 0
  TimerDestination.nTotalTime = 0
  TimerDestination.nTotalTimeElapsed = 0
  TimerDestination.fCallback = nil
  TimerDestination.tSelf = nil
  TimerDestination.tArgs = nil
  TimerDestination.hEvent = nil
end

function TimerDestination.DestinationByHandle(hHandle, nRange, nDestHour, nDestMinute, nMaxMinutePerSec, nUpdateTimer, fCallback, tSelf, tArgs)
  if hHandle then
    TimerDestination.nDistance = Object.GetDistance(hSab, hHandle) - nRange
    TimerDestination.nLastShortestDistance = TimerDestination.nDistance
    TimerDestination.nMaxMinutePerSec = nMaxMinutePerSec
    TimerDestination.fCallback = fCallback
    TimerDestination.tSelf = tSelf
    TimerDestination.tArgs = tArgs
    local tinfo = Util.GetTime()
    local nCurrentHour = tonumber(tinfo.Hour)
    local nCurrentMinute = tonumber(tinfo.Minute)
    TimerDestination.nHour = nCurrentHour
    TimerDestination.nMinute = nCurrentMinute
    local nHour = 0
    local blooponce = false
    if nCurrentHour == nDestHour and nDestMinute < nCurrentMinute then
      blooponce = true
    end
    while nCurrentHour ~= nDestHour or blooponce do
      nHour = nHour + 1
      nCurrentHour = nCurrentHour + 1
      if 24 <= nCurrentHour then
        blooponce = false
        nCurrentHour = 0
      end
    end
    local nMinute
    if nDestMinute > nCurrentMinute then
      nMinute = nCurrentMinute - nDestMinute
    else
      nMinute = 60 - (nCurrentMinute - nDestMinute)
    end
    TimerDestination.nTotalTime = nHour * 60 - nMinute
    TimerDestination.nTotalTimeElapsed = 0
    Util.SetDayTimeScale(0)
    TimerDestination.UpdateTime(nil, hHandle, nRange, nDestHour, nDestMinute, nMaxMinutePerSec, nUpdateTimer)
  else
  end
end

function TimerDestination.UpdateTime(anil, hHandle, nRange, nDestHour, nDestMinute, nMaxMinutePerSec, nUpdateTimer)
  local nCurrentDistance = Object.GetDistance(hSab, hHandle) - nRange
  if nCurrentDistance <= TimerDestination.nLastShortestDistance then
    TimerDestination.nLastShortestDistance = nCurrentDistance
    local fFraction = 1 - nCurrentDistance / TimerDestination.nDistance
    local nTimeElapsed = math.ceil(fFraction * TimerDestination.nTotalTime) - TimerDestination.nTotalTimeElapsed
    local hHoursPassed, hMinutesPassed
    if nMaxMinutePerSec > nTimeElapsed then
      TimerDestination.nTotalTimeElapsed = TimerDestination.nTotalTimeElapsed + nTimeElapsed
      hHoursPassed = math.floor(nTimeElapsed / 60)
      hMinutesPassed = math.fmod(nTimeElapsed, 60)
    else
      TimerDestination.nTotalTimeElapsed = TimerDestination.nTotalTimeElapsed + nMaxMinutePerSec
      hHoursPassed = math.floor(nMaxMinutePerSec / 60)
      hMinutesPassed = math.fmod(nMaxMinutePerSec, 60)
    end
    TimerDestination.nMinute = TimerDestination.nMinute + hMinutesPassed
    if 60 <= TimerDestination.nMinute then
      hHoursPassed = hHoursPassed + 1
      TimerDestination.nMinute = TimerDestination.nMinute - 60
    end
    TimerDestination.nHour = TimerDestination.nHour + hHoursPassed
    if TimerDestination.nHour >= 24 then
      TimerDestination.nHour = TimerDestination.nHour - 24
    end
    Util.SetTime(TimerDestination.nHour, TimerDestination.nMinute)
  end
  if TimerDestination.nTotalTimeElapsed >= TimerDestination.nTotalTime then
    TimerDestination.CallTheCallback()
  else
    local tEvent = {EventType = "TimerEvent", Time = nUpdateTimer}
    TimerDestination.hEvent = Util.CreateEvent(tEvent, "TimerDestination.UpdateTime", nil, {
      hHandle,
      nRange,
      nDestHour,
      nDestMinute,
      nMaxMinutePerSec,
      nUpdateTimer
    })
  end
end

function TimerDestination.CleanUp()
  Util.KillEvent(TimerDestination.hEvent)
  Util.ResetDayTimeScale()
end

function TimerDestination.CallTheCallback()
  if TimerDestination.fCallback then
    if TimerDestination.tArgs then
      table.insert(TimerDestination.tArgs, 1, TimerDestination.tSelf)
      TimerDestination.fCallback(unpack(TimerDestination.tArgs))
    else
      TimerDestination.fCallback(TimerDestination.tSelf)
    end
  end
end
