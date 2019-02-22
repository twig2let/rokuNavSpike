function keyPressMixinInit()
  m.isKeyPressLocked = false
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ KEY HANDLING
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function OnKeyEvent(key as string, press as boolean) as boolean
  result = false
  if press
    if (_isAnyKeyPressLocked())
      return true
    end if
    ' ? Substitute("[{0}.OnKeyEvent] {1}", m.top.id, key)
    if key = "down"
      result = _onKeyPressDown()
    else if key = "up"
      result = _onKeyPressUp()
    else if key = "left"
      result = _onKeyPressLeft()
    else if key = "right"
      result = _onKeyPressRight()
    else if key = "OK"
      result = _onKeyPressOK()
    else if key = "back"
      result = _onKeyPressBack()
    else if key = "options"
      result = _onKeyPressOption()
    end if
  end if

  if (result = invalid)
    result = false
  end if

  if (result = false)
    result = _isCapturingAnyKeyPress(key, press)
  end if

  return result
end function

function _isAnyKeyPressLocked() as boolean
  if m.isKeyPressLocked
    logWarn("All key presses are locked, due to isKeyPressLocked flag on ", m.top.id)
  end if
  return m.isKeyPressLocked
end function

function _isCapturingAnyKeyPress(key, press) as boolean
  return false
end function

function _onKeyPressDown() as boolean
  return false
end function

function _onKeyPressUp() as boolean
  return false
end function

function _onKeyPressLeft() as boolean
  return false
end function

function _onKeyPressRight() as boolean
  return false
end function

function _onKeyPressBack() as boolean
  return false
end function

function _onKeyPressOption() as boolean
  return false
end function

function _onKeyPressOK() as boolean
  return false
end function
