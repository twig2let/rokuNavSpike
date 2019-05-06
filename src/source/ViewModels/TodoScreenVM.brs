'@Namespace TSVM TodoScreenVM
'@Import BaseViewModel

function TodoScreenVM()
  return BaseViewModel({
    name: "todoScreenVM"

    'vars
    focusedIndex: -1
    focusedItem: invalid
    items: createObject("roSGNode", "ContentNode")
    isAutoCreateTimerActive: false

    'public
    addTodo: TSVM_addTodo
    removeTodo: TSVM_removeTodo

    'lifecycle
    _initialize: TSVM_init
  })
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Public api
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function addTodo()
  m.logMethod("addTodo")
  currentCount = m.items.count()
  item = createObject("roSGNode", "ContentNode")
  item.title = "item " + currentCount.trim()
  m.items.appendChild(item)
end function

function TSVM_removeTodo()
  m.logMethod("removeTodo")
  if m.items.count() -1 > 0
    m.items.removeChild(m.items.count() -1)
  else
    m.logger.warn("tried to remove todo when items was empty!")
  end if
end function

function TSVM_onTimerFire()
  
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Lifecycle methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function TSVM_init()

end function