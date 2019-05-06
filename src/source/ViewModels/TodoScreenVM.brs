'@Namespace TSVM TodoScreenVM
'@Import BaseViewModel

function TodoScreenVM()
  return BaseViewModel({
    name: "todoScreenVM"
    focusId: "addButton"

    'vars
    focusedIndex: -1
    focusedItem: invalid
    items: createObject("roSGNode", "ContentNode")
    isAutoCreateTimerActive: false
    currentTitle: "none"
    hasItems: false

    'public
    addTodo: TSVM_addTodo
    removeTodo: TSVM_removeTodo
    onTimerFire: TSVM_onTimerFire
    focusItemAtIndex: TSVM_focusItemAtIndex

    'lifecycle
    _initialize: TSVM_init

    'keypresses
    _onKeyPressDown: TSVM_onKeyPressDown
    _onKeyPressUp: TSVM_onKeyPressUp
    _onKeyPressBack: TSVM_onKeyPressBack

    'focusConstants
    focusIds: [
      "addButton",
      "removeButton"
      "itemList"
    ]
  })
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Public api
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function TSVM_addTodo(value)
  m.logMethod("addTodo")
  currentCount = m.items.getChildCount()
  item = createObject("roSGNode", "ContentNode")
  item.title = "item " + stri(currentCount).trim()
  m.items.appendChild(item)
  m.focusItemAtIndex(m.items.getChildCount() -1)
  m.setField("hasItems", true)
end function

function TSVM_removeTodo(value)
  m.logMethod("removeTodo")
  if m.items.getChildCount() > 0
    m.items.removeChildrenIndex(1, m.items.getChildCount() -1)
  else
    m.logWarn("tried to remove todo when items was empty!")
  end if
  m.focusItemAtIndex(m.items.getChildCount() -1)
  m.setField("hasItems", m.items.getChildCount() > 0)
end function

function TSVM_onTimerFire()
  m.logMethod("onTimerFire")
end function

function TSVM_focusItemAtIndex(newIndex)
  m.setField("focusedIndex", newIndex)
  m.setField("focusedItem", m.items.getChild(newIndex))
  if m.focusedItem <> invalid
    m.setField("currentTitle", "focused:" + m.focusedItem.title)
  else
    m.setField("currentTitle", "none")
  end if
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Key Handling
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function TSVM_onKeyPressDown() as boolean
  m.logVerbose("press down focusId", m.focusId)
  if m.focusId = "addButton"
    m.setField("focusId", "removeButton")
  else if m.focusId = "removeButton"
    m.setField("focusId", "itemList")
  end if
  return true
end function

function TSVM_onKeyPressUp() as boolean
  m.logVerbose("press up focusId", m.focusId)
  if m.focusId = "itemList"
    m.setField("focusId", "removeButton")
  else if m.focusId = "removeButton"
    m.setField("focusId", "addButton")
  end if
  return true
end function

function TSVM_onKeyPressBack() as boolean
  m.logVerbose("press back focusId", m.focusId)
  if m.focusId = "itemList"
    m.setField("focusId", "removeButton")
  end if
  return true
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Lifecycle methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function TSVM_init()

end function