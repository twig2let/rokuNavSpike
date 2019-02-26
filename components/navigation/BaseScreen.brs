function Init()
  'get a reference to your model locator/central message bus/DIP here.
  ' m.modelLocator = m.global.modelLocator

  'Track whatever constitutes a reload here, so any visible views can get reloaded
  ' m.modelLocator.user.observeField("isLoggedIn", "onUserChange")
end function

function onUserChange()
  if m.top.isShown
    m.top.isUserChangePending = false
    _onUserChange()
  else
    logInfo("user is change; but screen is not showing - marked as pending")
    m.top.isUserChangePending = true
  end if
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Overridden methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _baseScreenOnShow()
  logMethod("_baseScreenOnShow")
  if m.top.isUserChangePending
    logInfo("a user change was pending, and the screen is now shown")
    m.top.isUserChangePending = false
    _onUserChange()
  end if
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ abstract methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


function _onUserChange()
  'override me
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ nav support
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function push(view)
  if (m.top.navController <> invalid)
    m.top.navController.callFunc("push", view)
  else
    logError("Push failed - there is no navcontroller on ", m.top)
  end if
end function

function pop() as object
  if (m.top.navController <> invalid)
    return m.top.navController.callFunc("pop", invalid)
  else
    logError("Pop failed - there is no navcontroller on ", m.top)
  end if
end function

function resetNavControllerToRoot()
  logMethod("resetNavControllerToRoot." + m.top.id)
  if (m.top.navController <> invalid)
    m.top.navController.callFunc("resetToIndex", 0)
  else
    logError("Pop failed - there is no navcontroller on ", m.top)
  end if
end function

function resetNavController(newFirstScreen = invalid)
  logMethod("resetNavController." + m.top.id)
  if (m.top.navController <> invalid)
    m.top.navController.callFunc("reset", newFirstScreen)
  else
    logError("Pop failed - there is no navcontroller on ", m.top)
  end if
end function

function onAddedToAggregateView(navController)
  logMethod("onAddedToAggregateView", m.top.id)
  toggleLoadingIndicator(true, "screen was in loading state when added to nav controller")

  _onAddedToAggregateView(navController)
end function

function onRemovedFromAggregateView(navController)
  logMethod("onRemovedFromAggregateView", m.top.id)
  _onRemovedFromAggregateView(navController)
end function

function _onAddedToAggregateView(navController)
end function

function _onRemovedFromAggregateView(navController)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Global app services
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

' Note:
' The functions here are considered fundamental application-level service functions
' much as one might consider localization/tab navigation/accessing device sensors/DOM/file system/etc

' This will vary app to app - here's some examples
function playSelection(selection, isResuming = false, originScreen = "details")
end function

function createSelectionFromContent(currentItem, collection = invalid)
end function

function showOptionsMenu()
end function

function hideOptionsMenu()
end function

function showDialog(title = "", message = "", buttons = invalid, focusTargetAfterClosing = invalid)
end function

function closeDialog(dialog = invalid)
end function

function postAnalyticsEvent(event)
end function

function toggleTabBarFocus(isFocused)
end function

function toggleLoadingIndicator(isActive, reason = "")
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Screen helpers
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

' /**
'  * @member getTopScreen
'  * @memberof module:BaseScreen
'  * @instance
'  * @description gets the screen at the top of this screen's sceneGraph.
'  * @returns {BaseScreen} a screen considered as the top of this graph
'  */
function getTopScreen(args = invalid)
  logMethod("getTopScreen")
  topScreen = _getTopScreen()
  if topScreen = invalid
    if m.top.navController <> invalid and m.top.navController.numberOfViews > 0
      topScreen = m.top.navController.currentView
    else
      topScreen = m.top
    end if
  end if
  return topScreen
end function

' /**
'  * @member _getTopScreen
'  * @memberof module:BaseScreen
'  * @instance
'  * @description override point, for a screen to provide it's own means
'  * of looking up a screen at the top of it's stack
'  * @param {paramType} paramDescription
'  * @returns {returnType} returnDescription
'  */
function _getTopScreen()
  return invalid
end function

function getScreenForContent(content)
  return invalid
end function
