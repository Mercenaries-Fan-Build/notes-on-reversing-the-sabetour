if not DestructionSequence then
  DestructionSequence = {}
end

function DestructionSequence.Run(a_tSequenceData, a_sCallback, a_tCallbackParams)
  local tPhantomSelf = {}
  tPhantomSelf.tSequenceData = {}
  tPhantomSelf.tSequenceData = a_tSequenceData
  tPhantomSelf.sCallback = a_sCallback
  tPhantomSelf.tCallbackParams = a_tCallbackParams
  DestructionSequence._Run(nil, tPhantomSelf, "NONE", -1)
end

function DestructionSequence._Run(a_NIL, a_tPhantomSelf, a_sStartingElementName, a_nCurrentElement)
  if a_nCurrentElement ~= nil and a_nCurrentElement > #a_tPhantomSelf.tSequenceData then
    if a_tPhantomSelf.sCallback == nil or a_tPhantomSelf.tCallbackParams == nil then
      return
    end
    local fCallback = Tips.StringToFunction(a_tPhantomSelf.sCallback)
    if a_tPhantomSelf.tCallbackParams then
      fCallback(unpack(a_tPhantomSelf.tCallbackParams))
    else
      fCallback()
    end
    return
  end
  local nCurrentElement = 1
  if a_nCurrentElement ~= nil and a_nCurrentElement ~= -1 then
    nCurrentElement = a_nCurrentElement
  end
  if a_sStartingElementName ~= nil and a_sStartingElementName ~= "NONE" then
    local nSearchedIndex = DestructionSequence.FindSequenceElementByName(a_tPhantomSelf.tSequenceData, a_sStartingElementName)
    if nSearchedIndex ~= nil then
      nCurrentElement = nSearchedIndex
    else
      Util.Assert(false, "DestructionSequence couldn't find element labeled \"" .. a_sStartingElementName .. "\"")
    end
  end
  local tCurrentCommand = a_tPhantomSelf.tSequenceData[nCurrentElement]
  local sCommandName = string.upper(tCurrentCommand[1])
  local tCommandParameters = tCurrentCommand[2]
  local sElementName = tCurrentCommand[3]
  if sCommandName == "ENDSEQUENCE" then
    return
  elseif sCommandName == "TOGGLELIGHTS" then
    Render.ToggleLights(tCommandParameters[1], tCommandParameters[2])
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "LIGHT_ON" then
    Render.ToggleLights(tCommandParameters[1], true)
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "LIGHT_OFF" then
    Render.ToggleLights(tCommandParameters[1], false)
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "FOCUS_SEARCHER" then
    Searchlight.SetTarget(Handle(tCommandParameters[1]), tCommandParameters[2], Handle(tCommandParameters[3]))
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "ENABLE_SEARCHER" then
    Searchlight.EnableLights(Handle(tCommandParameters[1]), tCommandParameters[2], tCommandParameters[3])
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "ACTUATE" then
    Object.Actuate(Handle(tCommandParameters[1]))
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SPAWNEXPLOSION" then
    local sExplosionName = tCommandParameters[1]
    local nExplosionX = 0
    local nExplosionY = 0
    local nExplosionZ = 0
    local sType = type(tCommandParameters[2])
    if sType == "string" then
      local hObject = ScriptSequence.CheckForHandle(tCommandParameters[2])
      if hObject ~= nil then
        nExplosionX, nExplosionY, nExplosionZ = Object.GetPosition(hObject)
      else
        Util.Assert(false, "Second SPAWNEXPLOSION parameter is a string, but is not a valid object name!")
      end
    elseif sType == "userdata" then
      nExplosionX, nExplosionY, nExplosionZ = Object.GetPosition(tCommandParameters[2])
    elseif sType == "number" then
      nExplosionX = tCommandParameters[2]
      nExplosionX = tCommandParameters[3]
      nExplosionX = tCommandParameters[4]
    end
    Util.CreateExplosion(sExplosionName, nExplosionX, nExplosionY, nExplosionZ)
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "CHAINEXPLOSIONS" then
    local sExplosionName = tCommandParameters[1]
    local tExplosionLocations = tCommandParameters[2]
    local nTotalChainTime = tCommandParameters[3]
    local nIndividualChainTime = nTotalChainTime / #tCommandParameters[2]
    for i, v in ipairs(tExplosionLocations) do
      if i == 1 then
        local hFirstExplosion = DestructionSequence.CheckForHandle(v)
        local firstX, firstY, firstZ = Object.GetPosition(hFirstExplosion)
        Util.CreateExplosion(sExplosionName, firstX, firstY, firstZ)
      else
        local hExplosionLoc = DestructionSequence.CheckForHandle(v)
        local explX, explY, explZ = Object.GetPosition(hExplosionLoc)
        Util.CreateEvent({
          EventType = "TimerEvent",
          Time = nIndividualChainTime * (i - 1)
        }, "DestructionSequence.SpawnExplosion", nil, {
          sExplosionName,
          explX,
          explY,
          explZ
        })
      end
    end
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "STARTFX" then
    if tCommandParameters[3] then
      Render.StartFX(DestructionSequence.CheckForHandle(tCommandParameters[1]), tCommandParameters[2], tCommandParameters[3])
      DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
      return
    else
      Render.StartFX(DestructionSequence.CheckForHandle(tCommandParameters[1]), tCommandParameters[2], nil)
      DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
      return
    end
  elseif sCommandName == "STOPFX" then
    if tCommandParameters[3] then
      Render.EndFX(DestructionSequence.CheckForHandle(tCommandParameters[1]), tCommandParameters[2], tCommandParameters[3])
      DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
      return
    else
      Render.EndFX(DestructionSequence.CheckForHandle(tCommandParameters[1]), tCommandParameters[2], nil)
      DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
      return
    end
  elseif sCommandName == "STARTATTACHEDFX" then
    return
  elseif sCommandName == "STOPATTACHEDFX" then
    return
  elseif sCommandName == "OBJ_SETFXTIME" then
    Render.SetFXTime(DestructionSequence.CheckForHandle(tCommandParameters[1]), tCommandParameters[2])
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SHAKECAMERA" then
    local _x, _y, _z = Object.GetPosition(DestructionSequence.CheckForHandle(tCommandParameters[1]))
    Render.CameraShakeExplosion(_x, _y, _z, tCommandParameters[2], tCommandParameters[3], tCommandParameters[4])
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "ATTACHSOUND" then
    Sound.AttachSoundEvent(DestructionSequence.CheckForHandle(tCommandParameters[1]), tCommandParameters[2])
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "PLAYSOUND2D" then
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "FADETO" then
    Render.FadeTo(tCommandParameters[1], tCommandParameters[2], tCommandParameters[3], tCommandParameters[4], tCommandParameters[5])
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "FADETOBLACK" then
    Render.FadeTo(0, 0, 0, 255, tCommandParameters[1])
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "FADETOWHITE" then
    Render.FadeTo(255, 255, 255, 255, tCommandParameters[1])
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "FADETORED" then
    Render.FadeTo(255, 0, 0, 255, tCommandParameters[1])
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "FADETOCLEAR" then
    Render.FadeTo(0, 0, 0, 0, tCommandParameters[1])
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "SETDAMAGESTATE" then
    Damage.SetDamageState(DestructionSequence.CheckForHandle(tCommandParameters[1]), tCommandParameters[2], tCommandParameters[3])
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "STARTOVER" then
    DestructionSequence._Run(a_tPhantomSelf, "NONE", -1)
    return
  elseif sCommandName == "DELAY" then
    local hEvent = Util.CreateEvent({
      EventType = "TimerEvent",
      Time = tCommandParameters[1]
    }, "DestructionSequence._Run", nil, {
      a_tPhantomSelf,
      "NONE",
      nCurrentElement + 1
    })
    return
  elseif sCommandName == "DELAYFORRANDOM" then
    local hEvent = Util.CreateEvent({
      EventType = "TimerEvent",
      Time = math.random(tCommandParameters[1], tCommandParameters[2])
    }, "DestructionSequence._Run", a_tPhantomSelf, {
      "NONE",
      nCurrentElement + 1
    })
    return
  elseif sCommandName == "PRINTDIALOGUE" then
    local hActor = DestructionSequence.CheckForHandle(tCommandParameters[1])
    local nTime = 4
    if tCommandParameters[3] then
      nTime = tCommandParameters[3]
    end
    Render.PrintDialogue(hActor, tCommandParameters[2], nTime)
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "PRINTMESSAGE" then
    Render.PrintMessage(tCommandParameters[1])
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "JUMPTOELEMENT" then
    ScriptSequence._Run(a_tPhantomSelf, tCommandParameters[1], -1)
    return
  elseif sCommandName == "JUMPTORANDOM" then
    local sChosenRandomElement = tCommandParameters[math.random(#tCommandParameters)]
    DestructionSequence._Run(a_tPhantomSelf, sChosenRandomElement, -1)
    return
  elseif sCommandName == "STARTSEQUENCE" then
    DestructionSequence.Run(tCommandParameters[1], tCommandParameters[2], tCommandParameters[3])
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  elseif sCommandName == "KILLOBJECT" then
    Object.Kill(DestructionSequence.CheckForHandle(tCommandParameters[1]))
    DestructionSequence._Run(nil, a_tPhantomSelf, "NONE", nCurrentElement + 1)
    return
  else
    Util.Assert(false, "\"" .. sCommandName .. "\" is an unrecognized DestructionSequence command!")
  end
end

function DestructionSequence.FindSequenceElementByName(a_tSequence, a_sDesiredElementName)
  local i = 1
  while i <= #a_tSequence do
    local tCommand = a_tSequence[i]
    if tCommand[3] == a_sDesiredElementName then
      return i
    else
      i = i + 1
    end
  end
  return nil
end

function DestructionSequence.CheckForHandle(a_vVariable)
  local sType = type(a_vVariable)
  if sType == "userdata" then
    return a_vVariable
  elseif sType == "string" then
    return Util.GetHandleByName(a_vVariable)
  else
    Util.Assert(false, "Passed variable is neither a HANDLE nor STRING!")
  end
end

function DestructionSequence.SpawnExplosion(a_tPhantomSelf, a_sExplosionName, a_x, a_y, a_z)
  Util.CreateExplosion(a_sExplosionName, a_x, a_y, a_z)
end
