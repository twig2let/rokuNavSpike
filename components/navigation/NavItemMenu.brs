function init()  
  findNodes(["container"])
  registerLogger("NavItemMenu", "NavItemMenu")
  m.navItemsById = {}
  
  m.top.currentItem = invalid
  m.currentMenuItem = invalid
  m.preOptionsItem = invalid
  m.optionsItem = invalid
  m.didOptionsKeypressComeFromMenu = false
  m.top.observeField("focusedChild", "OnFocusedChildChange")
end function

function OnCurrentItemChange(event)
  logInfo("item change event {0}", event)
  newValue = m.top.currentItem
  if not newValue.isOptionsItem 
    ? "settign preoptions to " ; newValue.name
    m.preOptionsItem = newValue
  end if

  for each menuItem in m.container.getChildren(-1,0)
    isFocusedItem = menuItem.item.isSameNode(m.top.currentItem)
    if isFocusedItem
      m.currentMenuItem = menuItem
    end if
    menuItem.item.isFocused = isFocusedItem 
  end for

  m.didOptionsKeypressComeFromMenu = false
end function

function OnItemsChange(event)
  logInfo("items CHANGED ")
  'TODO add items to the view
  m.container.removeChildren(m.container.getChildren(-1,0))
  for each item in m.top.items
    menuItem = createObject("roSGNode", "MenuItem")
    menuItem.item = item
    if item.isOptionsItem
      m.optionsItem = item
    end if
    m.container.appendChild(menuItem)
  end for

  if m.top.items.count() > 0
    m.top.currentItem = m.top.items[0]
  else
    m.top.currentItem = invalid
  end if
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Lifecycle methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function onShow(args = invalid)
end function

function onHide(args = invalid)
end function

function onDestroy(args = invalid)
end function

function selectItem(delta)
  if m.top.items.count() = 0
    return invalid
  end if

  currentIndex = getIndexOfItem(m.top.currentItem)
  currentIndex += delta
  
  if currentIndex > m.top.items.count() -1
    currentIndex = m.top.items.count() -1
  else if currentIndex < 0
    currentIndex = 0
  end if
  m.top.currentItem = m.top.items[currentIndex]
end function

function getIndexOfItem(item)
  if item = invalid and  m.top.items.count() > 0
    return 0
  end if

  for index = m.top.items.count() -1 to 0 step -1
    if (m.top.items[index].isSameNode(item))
    return index
      end if
  end for
  return -1
end function

function restorePreOptionFocus()
  if m.preOptionsItem <> invalid
    m.top.currentItem =  m.preOptionsItem
  end if
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ key presses
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function isCapturingAnyKeyPress_(key) as boolean
  return true
end function

function onKeyPressDown_() as boolean
  m.global.mainView.isFocusedOnContent = true
  return true
end function

function onKeyPressLeft_() as boolean
  selectItem(-1)
  return true
end function

function onKeyPressRight_() as boolean
  selectItem(1)
  return true
end function

function onKeyPressBack_() as boolean
  m.global.mainView.isFocusedOnContent = true
  return true
end function

function onKeyPressOption_() as boolean
  if m.top.supportOptionPressWhenFocused
    if m.top.currentItem.isOptionsItem
      restorePreOptionFocus()
      m.global.mainView.isFocusedOnContent = m.didOptionsKeypressComeFromMenu
    else
      m.top.currentItem = m.optionsItem
      m.didOptionsKeypressComeFromMenu = true
    end if
  else if m.top.currentItem.isOptionsItem
    restorePreOptionFocus()
    m.global.mainView.isFocusedOnContent = true
  end if
  return true
end function