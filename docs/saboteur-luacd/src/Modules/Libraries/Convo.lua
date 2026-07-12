if Convo == nil then
  Convo = {}
  Convo.bPlaying = false
  Convo.CONVOLIST = {}
end

function Convo.ResetForFail()
  Convo.EmptyQueue()
  if Convo.bPlaying == true then
    Cin.StopConversation(Convo.sLastPlayed)
  end
  Convo.bPlaying = false
end

function Convo.AddConvo(sConvoName, nPriority, tFlags)
  if tFlags then
    if tFlags.ClearOutList then
      if Convo.bPlaying == true then
        Cin.StopConversation(Convo.sLastPlayed)
      end
      Convo.EmptyQueue()
    end
    if tFlags.DontPlayIfInConvo and Cin.IsHumanInConversation(hSab) == true then
      return false
    end
  end
  if #Convo.CONVOLIST == 0 then
    table.insert(Convo.CONVOLIST, {
      ConvoName = sConvoName,
      Priority = nPriority,
      Flags = tFlags
    })
    if Convo.bPlaying == false then
      Convo.PlayQueue()
    end
  else
    local nQueueSize = #Convo.CONVOLIST
    local nCounter
    for nCounter = 1, nQueueSize do
      if nPriority < Convo.CONVOLIST[nCounter].Priority then
        table.insert(Convo.CONVOLIST, nCounter, {
          ConvoName = sConvoName,
          Priority = nPriority,
          Flags = tFlags
        })
        return 1
      end
    end
    table.insert(Convo.CONVOLIST, {
      ConvoName = sConvoName,
      Priority = nPriority,
      Flags = tFlags
    })
    return 1
  end
end

function Convo.PlayQueueHackyDelay()
  if #Convo.CONVOLIST > 0 then
    local ConvoElement = Convo.CONVOLIST[1]
    Convo.sLastPlayed = ConvoElement.ConvoName
    table.remove(Convo.CONVOLIST, 1)
    Convo.bPlaying = true
    if ConvoElement.Flags then
      local sCallback = ConvoElement.Flags.sCallback
      if ConvoElement.Flags.Speakers then
        Cin.PlayConversationWith(Convo.sLastPlayed, ConvoElement.Flags.Speakers, "Convo.PlayQueue", nil, {sCallback})
      else
        Cin.PlayConversation(Convo.sLastPlayed, "Convo.PlayQueue", nil, {sCallback})
      end
    else
      Cin.PlayConversation(Convo.sLastPlayed, "Convo.PlayQueue", nil, {sCallback})
    end
  else
    Convo.bPlaying = false
  end
end

function Convo.PlayQueue(anil, convopassbacktable, t_callbackinfo)
  local bCanceled = true
  if convopassbacktable ~= nil and (convopassbacktable[1] == 3 or convopassbacktable[1] == -1) or convopassbacktable == nil then
    bCanceled = false
  end
  if bCanceled == false then
    if t_callbackinfo then
      local fFunction = Tips.StringToFunction(t_callbackinfo)
      if fFunction then
        fFunction()
      end
    end
    local tEvent = {EventType = "TimerEvent", Time = 0.3}
    Util.CreateEvent(tEvent, "Convo.PlayQueueHackyDelay", nil, nil)
  end
end

function Convo.EmptyQueue()
  Convo.CONVOLIST = {}
end
