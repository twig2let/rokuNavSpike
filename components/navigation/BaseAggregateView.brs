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
    logMethod("view is valid. isShown", m.top.isShown, "view", view.id)

    m.top.AppendChild(view)
    m.top.currentView = view

    if m.top.isShown
      view.visible = true
    end if

  end if
end function

function _hideView(view)
  if view <> invalid
    if view.isSameNode(m.top.currentView)
      m.top.currentView = invalid
    end if
    view.visible = false
    m.top.RemoveChild(view)
  end if

end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Lifecycle methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _onShow()
  logMethod("_onShow")
  if m.top.currentView <> invalid
    m.top.currentView.visible = true
  end if
end function

function _onHide()
  logMethod("_onHide")
  if m.top.currentView <> invalid
    m.top.currentView.visible = false
  end if
end function

function _onGainedFocus(isSelfFocused)
  logMethod("_onGainedFocus")
  if m.top.currentView <> invalid and isSelfFocused
    logDebug("setting focus to view ", m.top.currentView.id)
    setFocus(m.top.currentView)
  else
    logDebug("no current view when gaining focus")
  end if
end function

