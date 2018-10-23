function init()  
  m.top.currentView = invalid
end function

function onGainedFocus_()
  if m.top.currentView <> invalid
    setFocus(m.top.currentView)
  end if
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ View management
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function showView_(view)
  children = m.top.getChildren(-1, 0)

  for each child in children
    if not child.isSameNode(view)
      hideView_(child)
    end if
  end for

  if view <> invalid
    view.CallFunc("onShow", {})
    m.top.AppendChild(view)
  end if
end function

function hideView_(view)
  if view <> invalid
    view.CallFunc("onHide", {})
    m.top.RemoveChild(view)
  end if

end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Lifecycle methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function onShow(args = invalid)
  if m.top.currentView <> invalid
    m.top.currentView.CallFunc("onShow", {})
  end if
end function

function onHide(args = invalid)
  if m.top.currentView <> invalid
    mm.top.currentView.CallFunc("onHide", {})
  end if
end function

function onDestroy(args = invalid)
  'TODO
end function