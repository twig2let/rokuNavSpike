function Init()
  registerLogger("GV", "GridView")
  SetNavItem(m.top.FindNode("navItem"))

end function

function OnKeyEvent(key as String, press as Boolean) as Boolean
  if press
    logDebug("keypress {0} {1}", m.top.id, key)
  end if
  return false
end function

