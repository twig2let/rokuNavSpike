function Init()
  registerLogger("MainView")
  'get nav items from our tab controller
  findNodes(["tabMenu", "tabController"])
  findNodes(["homeView", "gridView", "optionsView"])
  m.tabController.callFunc("initialize",{})

  m.tabMenu.observeField("currentItem", "onTabMenuCurrentItemChange")  
  items = createMenuItems()
  m.tabMenu.callFunc("setItems", items)
end function

function createMenuItems()
  items = []
  items.push(createNavItem(m.homeView, "HOME"))
  items.push(createNavItem(m.gridView, "GRID"))
  items.push(createNavItem(m.optionsView, "OPTIONS"))
  return items
end function

function createNavItem(screen, name, isOptionsMenu = false)
  navItem = createObject("roSGNode", "NavItem")
  navItem.id = screen.id
  navItem.name = name
  navItem.isOptionsItem = true
  return navItem
end function

function onTabMenuCurrentItemChange(event)
  logInfo("tab menu item changed", m.tabMenu.currentItem)
  m.tabController.callFunc("changeCurrentItem", m.tabMenu.currentItem)
end function

function onOptionsMenuIsFocusedChange(event)
  logInfo("optionsMenu isFocused changed", m.optionsMenu.isFocused)
end function

function onIsFocusedOnContentChange(event)
  logInfo("onIsFocusedOnContentChange {0}", m.top.isFocusedOnContent)
  if m.top.isFocusedOnContent
    setFocus(m.tabController)
  else
    setFocus(m.tabMenu)
  end if

end function

function _onKeyPressUp() as boolean
  m.top.isFocusedOnContent = false
  return true
end function

function _onKeyPressOption() as boolean
  m.global.mainView.isFocusedOnContent = false
  m.tabMenu.currentItem = m.optionsView.navItem
  return true
end function

function _onGainedFocus(isSelfFocused) as void
  onIsFocusedOnContentChange(invalid)
end function
