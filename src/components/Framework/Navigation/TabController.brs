function init()
  registerLogger("TabController")
  logMethod("init")
  m.top.currentItem = invalid
  m.viewsByMenuItemId = {}
end function

function addChildViews()
  children = m.top.getChildren(-1, 0)
  for each child in children
    addExistingView(child)
  end for
  m.top.removeChildren(children)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ public api
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function changeCurrentItem(item)
  logInfo("changeCurrentItem", item)

  if m.top.currentItem = invalid or not m.top.currentItem.isSameNode(item)
    m.top.currentItem = item
    view = getViewForMenuItemContent(m.top.currentItem)
    if view <> invalid
      'we want to clear out the view's vis, so the initialize
      'won't trigger show callbacks prematurely
      view.visible = false
      view.isShown = false

      if not view.isInitialized
        initializeView(view)
      end if
      _showView(view)
    else
      logError("no view for item", m.top.currentItem)
    end if
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

function getViews()
  views = []
  for each id in m.viewsByMenuItemId
    views.push(m.viewsByMenuItemId[id])
  end for
  return views
end function

function addExistingView(existingView)
  m.viewsByMenuItemId[existingView.id] = existingView
  existingView.visible = false
end function

function createView(menuItemContent)
  logMethod("createView menuItemContent.screenType", menuItemContent.screenType)
  if menuItemContent.screenType <> "none"
    view = createObject("roSGNode", menuItemContent.screenType)
    view.menuItemContent = menuItemContent
    view.id = menuItemContent.id
    'we want to clear out the view's vis, so the initialize
    'won't trigger show callbacks prematurely
    view.visible = false
    view.isShown = false

    initializeView(view)
    view.visible = false
    m.viewsByMenuItemId[menuItemContent.id] = view
    return view
  else
    logError("menu item ", menuItemContent.id, " has no screenType - a call to registerExistingView should've been made first")
    return invalid
  end if
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Lifecycle
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _initialize(args)
  addChildViews()
end function