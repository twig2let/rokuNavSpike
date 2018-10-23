function init()  
  registerLogger("TAB", "TabController")
  
  m.top.currentItem = invalid
  m.top.navItems = []
  m.top.navItemsByKey_ = {}
  m.top.observeField("focusedChild", "OnFocusedChildChange")

end function

function OnCurrentItemChange(event)
  logInfo("tab change event {0}", event)
  showView_(m.top.currentItem.view)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ public api
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function addItem(navItem)
  itemsMap =  m.top.navItemsByKey_
  itemsMap[navItem.key]  = navItem
  m.top.navItemsByKey_ = itemsMap
  
  items = m.top.navItems
  items.push(navItem)
  m.top.navItems = items
end function


'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ view management
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function extractItemsFromChildViews()
  logInfo("extractItemsFromChildViews")
  m.top.items = []
  children = m.top.getChildren(-1, 0)

  for each child in children
    addItem(child.navItem)
    m.top.removeChild(child)
  end for

  logDebug(">>>> items are ", m.top.navItemsByKey_)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Lifecycle methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function initialize(args = invalid)
  extractItemsFromChildViews()
end function

