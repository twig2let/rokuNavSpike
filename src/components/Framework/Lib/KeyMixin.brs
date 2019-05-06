function keyPressMixinInit()
  m.isKeyPressLocked = false
  m.longPressTimer = invalid
  m.longPressKey = ""
  m.isLongPressStarted = false
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
    else if key = "play"
      result = _onKeyPressPlay()
    end if
  else if m.longPressKey <> ""
    toggleLongPressTimer(0)
    result = true
  end if

  if (result = invalid)
    result = false
  end if

  if result and press
    longPressInterval = _getLongPressIntervalForKey(key)
    if longPressInterval > 0
      logInfo("entering long press for key ", key)
      m.longPressKey = key
      toggleLongPressTimer(longPressInterval)
    end if
  else
    result = _isCapturingAnyKeyPress(key, press)
  end if

  if result = false and m.vm <> invalid
    result = m.vm.onKeyEvent(key, press)
  end if

  return result
end function

function toggleLongPressTimer(interval)
  if m.longPressTimer <> invalid
    m.longPressTimer.unobserveField("fire")
    m.longPressTimer = invalid
  end if

  if interval > 0
    m.longPressTimer = createObject("roSGNode", "Timer")
    m.longPressTimer.duration = interval
    m.longPressTimer.repeat = true
    m.longPressTimer.observeField("fire", "onLongPressTimerFire")
    m.longPressTimer.control = "start"
  else if m.longPressKey <> ""
    logInfo("finishing longPress on key ", key)
    if m.isLongPressStarted
      _onLongPressFinish(m.longPressKey)
    end if
    m.longPressKey = ""
    m.isLongPressStarted = false
  end if
end function

function onLongPressTimerFire()
  if m.isLongPressStarted
    if not _onLongPressUpdate(m.longPressKey)
      logInfo("long press was cancelled by the _onLongPressUpdate call")
      toggleLongPressTimer(0)
    end if
  else
    if not _onLongPressStart(m.longPressKey)
      logInfo("long press was rejected by _onLongPressStart call")
      toggleLongPressTimer(0)
    else
      logInfo("long press is accepted : starting for key ", m.longPressKey )
      m.isLongPressStarted = true
    end if
  end if
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

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Long press callbacks
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _getLongPressIntervalForKey(key) as float
  return 0
end function

function _onLongPressStart(key) as boolean
  return true
end function

function _onLongPressUpdate(key) as boolean
  return true
end function

function _onLongPressFinish(key) as boolean
  return true
end function