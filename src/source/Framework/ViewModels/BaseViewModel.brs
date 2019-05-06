'@Namespace BVM BaseViewModel
'@Import rLogMixin
'@Import Utils
'@Import BaseObservable

function BaseViewModel(subClass)
  this = BaseObservable()
  this.append({
    __viewModel: true
    state: "none"
    initialize: BVM_initialize
    destroy: BVM_destroy
    onShow: BVM_onShow
    onHide: BVM_onHide
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
