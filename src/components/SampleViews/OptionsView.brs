function Init()
  registerLogger("OptionsView")
end function

function OnKeyEvent(key as String, press as Boolean) as Boolean
  if press
    logDebug("keypress {0} {1}", m.top.id, key)
  end if
  return false
end function

