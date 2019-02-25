function init() as void
  m.currentView = invalid
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ view management
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _showView(view)
  logMethod("_showView")
  children = m.top.getChildren(-1, 0)

  for each child in children
    if not child.isSameNode(view)
      _hideView(child)
    end if
  end for

  if view <> invalid
    if m.top.isShown
      view.callFunc("onShow", {})
    end if
    m.top.AppendChild(view)
    m.top.currentView = view
  end if
end function

function _hideView(view)
  if view <> invalid
    if view.isSameNode(m.top.currentView)
      m.top.currentView = invalid
    end if
    view.CallFunc("onHide", {})
    m.top.RemoveChild(view)
  end if

end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Lifecycle methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _onShow()
  logMethod("_onShow")
  if m.top.currentView <> invalid
    m.top.currentView.CallFunc("onShow", {})
  end if
end function

function _onHide()
  logMethod("_onHide")
  if m.top.currentView <> invalid
    m.top.currentView.CallFunc("onHide", {})
  end if
end function

function _onGainedFocus(isSelfFocused)
  logMethod("_onGainedFocus")
  if m.top.currentView <> invalid and m.top.hasFocus()
    setFocus(m.top.currentView)
  end if
end function

