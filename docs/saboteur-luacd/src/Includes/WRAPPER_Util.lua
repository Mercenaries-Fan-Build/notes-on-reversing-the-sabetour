function WRAPPER_CheckForHandle(a_vVariable)
  local sType = type(a_vVariable)
  
  if sType == "userdata" then
    return a_vVariable
  elseif sType == "string" then
    local hObject = Util.GetHandleByName(a_vVariable)
    if hObject == nil then
      Util.Assert(false, "Wrapper cannot get handle for (" .. a_vVariable .. ")!")
      return
    else
      return hObject
    end
  else
    Util.Assert(false, "Passed variable is neither a HANDLE nor STRING!")
  end
end

function WRAPPER_CheckForHandleNil(a_vVariable)
  local sType = type(a_vVariable)
  if sType == "userdata" then
    return a_vVariable
  else
    if sType == "string" then
      local hObject = Util.GetHandleByName(a_vVariable)
      if hObject == nil then
        return nil
      else
        return hObject
      end
    else
    end
  end
end

function WRAPPER_SanityCheck(a_hObject, a_sAssertString)
  if a_hObject == nil then
    Util.Assert(false, a_sAssertString)
  end
end
