function Init()
  registerLogger("HomeView")
  findNodes(["titleLabel", "itemList", "addButton", "removeButton"])
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Lifecycle methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _initialize(args)
  m.vm = TodoScreenVM()
  m.vm.initialize()
  VMM_createFocusMap(m.vm)
  noInitialValueProps = OM_createBindingProperties(false)
  OM_bindObservableField(m.vm, "items", m.itemList, "content")
  OM_bindObservableField(m.vm, "focusedIndex", m.itemList, "jumpToItem")
  OM_bindObservableField(m.vm, "currentTitle", m.titleLabel, "text")
  OM_bindNodeField(m.itemList, "itemFocused", m.vm, "focusItemAtIndex", noInitialValueProps)
  OM_bindNodeField(m.addButton, "buttonSelected", m.vm, "addTodo", noInitialValueProps)
  OM_bindNodeField(m.removeButton, "buttonSelected", m.vm, "removeTodo", noInitialValueProps)
  OM_observeField(m.vm, "focusId", VMM_onFocusIdChange)
end function

