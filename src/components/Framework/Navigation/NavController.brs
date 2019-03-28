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
  'we want to clear out the view's vis, so the initialize
  'won't trigger show callbacks prematurely
  view.visible = false
  view.isShown = false

  if not view.isInitialized
    initializeView(view)
  end if

  logInfo("pushing ", view.subType())
  prev = m.viewStack.Peek()
  m.viewStack.Push(view)
  updatePublicFields()
  view.navController = m.top
  _showView(view)
  view.callFunc("onAddedToAggregateView", m.top)
  if m.top.isAutoFocusEnabled and m.top.isInFocusChain()
    setFocus(view)
  end if
  logInfo(view.subType(), " #views in stack", m.top.numberOfViews)
end function

function resetToIndex(index)
  _reset(invalid, index)
end function

function reset(newFirstScreen = invalid)
  _reset(newFirstScreen)
end function

function _reset(newFirstScreen = invalid, endIndex = -1)
  logInfo(" reset ", m.top.numberOfViews)
  if endIndex < -1
    endIndex = -1
  end if
  logInfo("endIndex is", endIndex)
  index = m.top.numberOfViews - 1
  while index > endIndex
    logInfo("resetting index ", index)
    view = m.viewStack.Pop()
    if view <> invalid
      _hideView(view)
      view.navController = invalid
      view.callFunc("onRemovedFromAggregateView", m.top)
    else
      logInfo(" reset found invalid child")
    end if
    index--
  end while

  updatePublicFields()

  if newFirstScreen <> invalid
    logInfo("new first screen ",  newFirstScreen.subType())
    push(newFirstScreen)
  else if m.top.numberOfViews > 0
    logInfo("there were views left on the stack after resetting ")
    _showView(m.viewStack[m.top.numberOfViews - 1])
  end if

end function

function pop(args) as object
  logMethod("pop ", m.top.numberOfViews)
  previousView = m.top.currentView
  if (previousView <> invalid)
    m.viewStack.Pop()
    _hideView(previousView)
    previousView.callFunc("onRemovedFromAggregateView", m.top)
    previousView.navController = invalid

    previousView = m.viewStack.Peek()
    if previousView <> invalid
      _showView(previousView)
      if m.top.isAutoFocusEnabled
        setFocus(previousView)
      end if
    end if
  end if

  updatePublicFields()
  if m.top.numberOfViews = 0
    m.top.isLastViewPopped = true
  end if
  return previousView
end function


'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Private impl
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function updatePublicFields()
  m.top.numberOfViews = m.viewStack.count()
  m.top.viewStack = m.viewStack
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Lifecycle methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _initialize(args)
  logMethod("_initialize(args)")
  registerLogger("NC.(" + m.top.getParent().subType() + ")")
end function