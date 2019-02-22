function init()
  logInfo("init")
  m.viewStack = []
  m.currentView = invalid
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ public api
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function push(view) as void
  logMethod("push")
  if view = invalid
    logWarn(" push invalid view passed in : ignoring")
    return
  end if
  logInfo("pushing ", view.subType())
  prev = m.viewStack.Peek()
  m.viewStack.Push(view)
  m.top.numberOfViews = m.viewStack.count()

  view.navController = m.top
  _showView(view)
  view.callFunc("onAddedToNavController", m.top)
  if m.top.isAutoFocusEnabled
    setFocus(view)
  end if
  logInfo(view.subType(), " #views in stack", m.top.numberOfViews)
end function

function resetToIndex(index)
  _reset(invalid, index + 1)
end function

function reset(newFirstScreen = invalid)
  _reset(newFirstScreen)
end function

function _reset(newFirstScreen = invalid, indexOffset = 1)
  logInfo(" reset ", m.top.numberOfViews)
  for i = 0 to  m.viewStack.count() - indexOffset
    view = m.viewStack.Pop()
    if view <> invalid
      _hideView(view)
      view.navController = invalid
      view.callFunc("onRemovedFromNavController", m.top)
    else
      logInfo(" reset found invalid child")
    end if
  end for

  'to be safe remove any other children
  children = m.top.GetChildren(-1, 0)
  m.top.removeChildren(children)

  m.viewStack = []
  m.top.numberOfViews  = 0

  if newFirstScreen <> invalid
    logInfo("new first screen ",  newFirstScreen.subType())
    push(newFirstScreen)
  end if
end function

function pop(args) as object
  logMethod("pop ", m.top.numberOfViews)
  previousView = m.top.currentView
  if (previousView <> invalid)
    m.viewStack.Pop()
    'I've found in some situations, last can be invalid!
    _hideView(previousView)
    previousView.callFunc("onRemovedFromNavController", m.top)
    previousView.navController = invalid

    previousView = m.viewStack.Peek()
    if previousView <> invalid
      _showView(previousView)
      if m.top.isAutoFocusEnabled
        setFocus(previousView)
      end if
    end if
  end if

  m.top.numberOfViews = m.viewStack.count()

  if m.top.numberOfViews = 0
    m.top.isLastViewPopped = true
  end if
  return previousView
end function



'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Lifecycle methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _initialize(args)
  logMethod("_initialize(args)")
  registerLogger("NC.(" + m.top.getParent().subType() + ")")
end function