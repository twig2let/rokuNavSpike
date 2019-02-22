function init()
  registerLogger("TabController")
  logMethod("init")
  m.top.currentItem = invalid
  m.top.menuItems = []
  m.viewsByMenuItemId = {}
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ public api
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function changeCurrentItem(item)
  logInfo("changeCurrentItem", item)

  if m.top.currentItem = invalid or not m.top.currentItem.isSameNode(item)
    m.top.currentItem = item
    _showView(getViewForMenuItemContent(m.top.currentItem))
  end if
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ View management
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function getViewForMenuItemContent(menuItemContent)
  if menuItemContent = invalid
    return invalid
  end if

  view = m.viewsByMenuItemId[menuItemContent.id]

  if view = invalid
    view = createView(menuItemContent)
  end if

  return view
end function

function addExistingView(existingView)
  m.viewsByMenuItemId[existingView.id] = existingView
end function

function createView(menuItemContent)
  if menuItemContent.screenType <> "none"
    view = createObject("roSGNode", menuItemContent.screenType)
    view.menuItemContent = menuItemContent
    view.id = menuItemContent.id
    view.callFunc("initialize", {})
    m.viewsByMenuItemId[menuItemContent.id] = view
    return view
  else
    logError("menu item ", menuItemContent.id, " has no screenType - a call to registerExistingView should've been made first")
    return invalid
  end if
end function