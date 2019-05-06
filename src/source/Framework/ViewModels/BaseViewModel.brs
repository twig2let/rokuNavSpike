'@Namespace BVM BaseViewModel
'@Import rLogMixin
'@Import Utils
'@Import BaseObservable

function BaseViewModel(subClass)
  this = BaseObservable()
  this.append({
    __viewModel: true
    state: "none"
    focusId: invalid

    'public
    initialize: BVM_initialize
    destroy: BVM_destroy
    onShow: BVM_onShow
    onHide: BVM_onHide
    onKeyEvent: BVM_onKeyEvent

    'private
    _states: {
      "none": "none",
      "invalid": "invalid",
      "initialized": "initialized"
      "destroyed": "destroyed"
    }
  })
  if isAACompatible(subClass) and subClass.name <> invalid and subClass.name <> ""
    this.append(subClass)
    registerlogger(subClass.name, true, this)
  else
    this.state = "invalid"
  end if
  return this
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ public API
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function BVM_initialize()
  m.logMethod("initialize")
  if isFunction(m._initialize)
    m._initialize()
  end if
  m.state = m._states.initialized
end function

function BVM_destroy()
  m.logMethod("destroy")
  if isFunction(m._destroy)
    m._destroy()
  end if
  m.state = m._states.destroyed
end function

function BVM_onShow()
  m.logMethod("onShow")
  if isFunction(m._onShow)
    m._onShow()
  end if
end function

function BVM_onHide()
  m.logMethod("onHide")
  if isFunction(m._onHide)
    m._onHide()
  end if
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ KEY HANDLING
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function BVM_onKeyEvent(key as string, press as boolean) as boolean
  result = false
  if press
    if isFunction(m._isAnyKeyPressLocked) and m._isAnyKeyPressLocked()
      return true
    end if
    if key = "down" and isFunction(m._onKeyPressDown())
      result = _onKeyPressDown()
    else if key = "up" and isFunction(m._onKeyPressUp)
      result = m._onKeyPressUp()
    else if key = "left" and isFunction(m._onKeyPressLeft)
      result = m._onKeyPressLeft()
    else if key = "right" and isFunction(m._onKeyPressRight)
      result = m._onKeyPressRight()
    else if key = "OK" and isFunction(m._onKeyPressOK)
      result = m._onKeyPressOK()
    else if key = "back" and isFunction(m._onKeyPressBack)
      result = m._onKeyPressBack()
    else if key = "options" and isFunction(m._onKeyPressOption)
      result = m._onKeyPressOption()
    else if key = "play" and isFunction(m._onKeyPressPlay)
      result = m._onKeyPressPlay()
    end if
  else
    result = false
  end if

  if (result = invalid)
    result = false
  end if

  if result = false and isFunction(m._isCapturingAnyKeyPress)
    result = m._isCapturingAnyKeyPress(key, press)
  end if

  return result
end function
