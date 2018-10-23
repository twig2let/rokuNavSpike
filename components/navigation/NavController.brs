function init()  
  registerLogger("NAV", "NavController")
  m.viewStack = []
  m.top.topView = invalid
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ public api
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function push(view)
  prev = m.viewStack.Peek()
  m.viewStack.Push(view)
  m.top.numberOfViews = m.viewStack.count()  
  
  view.navController = m.top
  showView_(view)
  view.callFunc("_onAddedToNavController", m.top)
  logInfo("NavController.push {0}  #views in stack {1}", view.getsubtype(), m.top.numberOfViews) 
end function

function reset(newFirstScreen = invalid)
  logInfo("NavController.reset #view on stack: {0}", m.top.numberOfViews)
  for i = 0 to  m.viewStack.count() -1
    view = m.viewStack.Pop()
    if view <> invalid
      hideView_(view)
      view.navController = invalid
      view.callFunc("_onRemovedFromNavController", m.top)
    else
      logInfo("NavController.reset found invalid child")
    end if
  end for
  
  children = m.top.GetChildren(-1, 0)
  m.top.removeChildren(children)
  
  m.viewStack = []
  m.top.numberOfViews  = 0
  
  if newFirstScreen <> invalid
    logInfo("new first screen ", newFirstScreen.getSubtype())
    push(newFirstScreen)
  end if
end function

function pop(args) as Object
  logInfo("NavController.pop #view on stack: {0}", m.top.numberOfViews)
  previousView = m.top.currentView 
  if (previousView <> invalid) 
    m.viewStack.Pop()
      'I've found in some situations, last can be invalid!
    hideView_(previousView)
    previousView.callFunc("_onRemovedFromNavController", m.top)
    previousView.navController = invalid
    
    previousView = m.viewStack.Peek()
    if previousView <> invalid
      showView_(previousView)
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

function onShow(args = invalid)
  if m.top.topView <> invalid
    m.top.topView.CallFunc("onShow", {})
  end if
end function

function onHide(args = invalid)
  if m.top.topView <> invalid
    m.top.topView.CallFunc("onHide", {})
  end if
end function
