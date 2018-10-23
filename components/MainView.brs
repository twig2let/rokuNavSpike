function Init()
  registerLogger("MV", "MainView")
  'get nav items from our tab controller
  findNodes(["tabMenu", "tabController", "optionsView"])
  m.tabController.callFunc("initialize",{})

  m.tabMenu.observeField("currentItem", "onTabMenuCurrentItemChange")  
  m.tabMenu.items = m.tabController.navItems
end function


function onTabMenuCurrentItemChange(event)
  logInfo("tab menu item changed", m.tabMenu.currentItem)
  m.tabController.currentItem = m.tabMenu.currentItem
end function

function onOptionsMenuIsFocusedChange(event)
  logInfo("optonsMenu isFocused changed", m.optionsMenu.isFocused)
end function

function onIsFocusedOnContentChange(event)
  logInfo("onIsFocusedOnContentChange {0}", m.top.isFocusedOnContent)
  if m.top.isFocusedOnContent
    setFocus(m.tabController)
  else
    setFocus(m.tabMenu)
  end if

end function

function onKeyPressUp_() as boolean
  m.top.isFocusedOnContent = false
  return true
end function

function onKeyPressOption_() as boolean
  m.global.mainView.isFocusedOnContent = false
  m.tabMenu.currentItem = m.optionsView.navItem
  return true
end function

function _OnGainedFocus() as void
  onIsFocusedOnContentChange(invalid)
end function
