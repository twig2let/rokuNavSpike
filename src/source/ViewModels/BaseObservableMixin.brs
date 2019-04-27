'@Namespace BOM BaseObservableMixin
'@Import rLogMixin
'@Import Utils

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ MIXIN METHODS
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

' /**
'  * @member BOM_ObserveField
'  * @memberof module:BaseObservable
'  * @instance
'  * @description observes the field on observable, calling the passed in function when the value changes
'  * @param {BaseObservable} observable instance of observable
'  * @param {string} field field to observe on the passed in observable
'  * @param {function} functionPointer method to invoke when the value changes
'  * @returns {returnType} returnDescription
'  */
function BOM_ObserveField(observable, field, functionPointer)
  if not BOM_registerObservable(observable)
    logError("could not observe field - the observable failed to regiser")
    return false
  end if
  if not m._observableFunctionPointers.doesExist(functionName)
    m._observableFunctionPointers[functionName] = functionPointer
  end if
  observable.observeField(field, functionName, true)
end function

' /**
'  * @member BOM_unobserveField
'  * @memberof module:BaseObservableMixin
'  * @instance
'  * @description removes the observer for the given field
'  * @param {paramType} paramDescription
'  * @returns {returnType} returnDescription
'  */
function BOM_unobserveField(observable, fieldName, functionPointer) as boolean
  if not BOM_isRegistered(observable)
    logError("could not unobserve fiedl - the observable has not been registered")
    return false
  end if
  if not m._observableFunctionPointers.doesExist(functionName)
    m._observableFunctionPointers[functionName] = functionPointer
  end if
  observable.observeField(field, functionName, true)
end function

' /**
'  * @member bindNodeField
'  * @memberof module:BaseObservable
'  * @instance
'  * @description binds a field on the passed in node to a field on this observer
'  * @param {node} targetNode - the node to notify when the field changes - must have a unique id
'  * @param {string} fieldName - field on the node to observe
'  * @param {string} targetField - field on this observer to update with change values
'  * @returns {boolean} true if successful
'  */
function BOM_bindNodeField(targetNode, fieldName, observable, targetField) as boolean
  if not BOM_registerObservable(observable)
    logError("could not bind node field - the observable failed to register")
    return false
  end if

  if not observable.checkValidInputs(fieldName, targetNode, targetField)
    return false
  end if

  nodeKey = targetNode.id + "_" + fieldName
  nodeBindings = m._observableNodeBindings[nodeKey]

  if nodeBindings = invalid
    targetNode.observeFieldScoped(fieldName, BOM_BindingCallback)
    nodeBindings = {}
  end if

  key = observable.getNodeFieldBindingKey(node, fieldName, targetField)

  if nodeBindings.doesExist(key)
    logWarn("NodeBinding already existed for key")
    binding = nodeBindings[key]
    if binding.node.isSameNode(node)
      logWarn("is same node - ignoring")
      return true
    else
      logError("was a different node - ignoring")
      return false
    end if
  end if

  nodeBindings[key] = {"contextId": observable.contextId, "targetField": targetField}

  m._observableNodeBindings[nodeKey] = nodeBindings
  return true
end function

' /**
'  * @member unbindNodeField
'  * @memberof module:BaseObservable
'  * @instance
'  * @description unbinds a field on the passed in node to a field on this observer
'  * @param {node} targetNode - the node to notify when the field changes - must have a unique id
'  * @param {string} fieldName - field on the node to observe
'  * @param {string} targetField - field on this observer to update with change values
'  * @returns {boolean} true if successful
'  */
function BOM_unbindNodeField(targetNode, fieldName, observable, targetField) as boolean
  if not m.checkValidInputs(fieldName, targetNode, targetField)
    return false
  end if

  nodeKey = targetNode.id + "_" + fieldName
  nodeBindings = m._observableNodeBindings[nodeKey]
  if nodeBindings = invalid
    nodeBindings = {}
  end if

  key = observable.getNodeFieldBindingKey(node, fieldName, targetField)
  bindings = nodeBindings[key]

  if bindings <> invalid
    nodeBindings.delete(key)
  end if

  if nodeBindings.count() = 0
    node.unobserveFieldScoped(fieldName, "BOM_BindingCallback")
  end if

  m._observableNodeBindings[nodeKey] = nodeBindings
  return true
end function

' /**
'  * @member registerObservable
'  * @memberof module:BaseObservable
'  * @instance
'  * @description registers the observer with this node (i.e code behind for component/task)
'  *              which wires up all the context info required to ensure
'  *              scope preservation
'  * @param {observable} instance of an observable
'  * @returns {boolean} true if successfully registered
'  */
function BOM_registerObservable(observable) as boolean
  if not isAACompatible(observable)
    logError("non aa object passed in")
    return false
  end if

  if not observable.doesExist("__observableObject")
    logError("the passed in object is not an Observable subclass")
    return false
  end if

  if observable.doesExist("contextId")
    contextId = observable.contextId
  else
    logInfo("this observable has never been registered - setting it's context id")
    if m._observableContextId = invalid
      m["_observableContextId"] = -1
    end if
    m._observableContextId++
    contextId = str(m._observableContextId).trim()
  end if

  if m._observables = invalid
    m._observables = {}
    m._observableFunctionPointers = {}
    m._observableNodeBindings = {}
    m._observableContext = createObject("roSGNode", "ContentNode")
    m._observableContext.addField("bindingMessage", "assocarray", true)
    m._observableContext.observeFieldScoped("bindingMessage", BOM_ObserverCallback)
  end if

  registeredObservable = m._observables[contextId]
  if registeredObservable = invalid
    logInfo("this observable was not registered - registering it now with context id ", contextId)
    m._observables[contextId] = observable
    observable.setContext(contextId, m._observableContext)
  end if
  return true
end function

' /**
'  * @member BOM_unregisterObservable
'  * @memberof module:BaseObservable
'  * @instance
'  * @description unregisters the passed in observable
'  * @param {BaseObservable} instance of an observable
'  * @returns {boolean} true if successfully removed
'  */
function BOM_unregisterObservable(observable) as boolean
  if not isAACompatible(observable)
    logError("non aa object passed in")
    return false
  end if

  if not observable.doesExist("__observableObject")
    logError("the passed in object is not an Observable subclass")
    return false
  end if

  if not observable.doesExist("contextId")
    logError("passed in node did not contain a context Id")
  end if

  if m._observables = invalid
    m._observables = {}
  end if
  m._observables.delete(observable.contextId)
  if m._observables.count() = 0
    m._observableContext.unobserveFieldScoped("bindingMessage")
  end if
  observable.setContext(invalid, invalid)
end function

' /**
'  * @member BOM_bindObservableField
'  * @memberof module:BaseObservableMixin
'  * @instance
'  * @description binds the field from observable, to the target node's field
'  * @param {observable} observable - instance of observable
'  * @param {string} fieldName - name of field to bind
'  * @param {node} targetNode - node to set bound field value on
'  * @param {string} targetField - name of field to set on node
'  * @param {boolean} setInitialValue - whether value should be set straight away
'  * @returns {boolean} true if successful
'  */
function BOM_bindObservableField(observable, fieldName, targetNode, targetField, setInitialValue = true) as boolean
  return observable.bindField(fieldName, targetNode, targetField, setInitialValue)
end function 
' /**
' /**
'  * @member BOM_unbindObservableField
'  * @memberof module:BaseObservableMixin
'  * @instance
'  * @description removes binding for the field from observable, to the target node's field
'  * @param {observable} observable - instance of observable
'  * @param {string} fieldName - name of field to bind
'  * @param {node} targetNode - node to set bound field value on
'  * @param {string} targetField - name of field to set on node
'  * @returns {boolean} true if successful
'  */
function BOM_unbindObservableField(observable, fieldName, targetNode, targetField) as boolean
  return observable.bindField(fieldName, targetNode, targetField)
end function 
' /**
'  * @member BOM_cleanup
'  * @memberof module:BaseObservableMixin
'  * @instance
'  * @description cleans up all vars associated with binding support
'  */
function BOM_cleanup()
  if m._observableContext <> invalid
    m._observableContext.unobserveFieldScoped("bindingMessage")
  end if
  'TODO - remove all bindings!
  m.delete("_observables")
  m.delete("_observableContextId")
  m.delete("_observableFunctionPointers")
  m.delete("_observableNodeBindings")
  m.delete("_observableContext")
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Two way binding convenience
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

' /**
'  * @member BOM_bindFieldTwoWay
'  * @memberof module:BaseObservable
'  * @instance
'  * @description wires the field on the observable to the target field on the targetNode
'  * @param {BaseObservable} observable - instance to bind
'  * @param {string} fieldName - field on observable to bind
'  * @param {roSGNode} targetNode - node to bind to
'  * @param {string} targetField - field on target node to bind to
'  * @param {boolean} setInitialValue, if true, then the binding is invoked with the current value
'  */
function BOM_bindFieldTwoWay(observable, fieldName, targetNode, targetField, setInitialValue = true) as void
  BOM_bindObservableField(observable, fieldName, targetNode, targetField, setInitialValue)
  BOM_bindNodeField(targetNode, fieldName, observable, targetField)
end function

' /**
'  * @member BOM_unbindFieldTwoWay
'  * @memberof module:BaseObservable
'  * @instance
'  * @description unwires the field on the observable to the target field on the targetNode
'  * @param {BaseObservable} observable - instance to bind
'  * @param {string} fieldName - field on observable to bind
'  * @param {roSGNode} targetNode - node to bind to
'  * @param {string} targetField - field on target node to bind to
'  */
function BOM_unbindFieldTwoWay(observable, fieldName, targetNode, targetField) as void
  if BOM_isRegistered(observable)
    BOM_unbindObservableField(observable, targetNode, fieldName, observable, targetField)
    BOM_unbindNodeField(targetNode, fieldName, observable, targetField)
  else
    logError("could not unbind two way - the observable has not yet been registered")
  end if
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Binding and observer callbacks
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'The following methods are mixed in as conveniences

' /**
'  * @member BOM_BindingCallback
'  * @memberof module:BaseObservable
'  * @instance
'  * @description event handler for passing node events to the correct observable field or function
'  * @param {event} event
'  */
function BOM_BindingCallback(event) as void
  data = event.getData()
  if m._observableNodeBindings = invalid
    logError("Binding callback invoked when no node bindings were registered")
    return
  end if

  nodeKey = event.getNode() + "_" + event.getField()
  nodeBindings = m._observableNodeBindings[nodeKey]
  value = event.getData()
  for each key in nodeBindings
    bindingData = nodeBindings[key]
    observable = m._observables[bindingData.contextId]
    if isAACompatible(observable)
      targetField = observable[bindingData.targetField]
      if isFunction(targetField)
        observable[bindingData.targetField](value)
      else if isString(targetField)
        observable.setField(targetField, value)
      else
        logError("could not find the target on the observable for nodKey", nodeKey, "key", key)
      end if
    else
      logError("could not find observable with context id ", contextId)
    end if
  end for
end function

' /**
'  * @member BOM_ObserverCallback
'  * @memberof module:BaseObservable
'  * @instance
'  * @description event handler for handling observable events, which then get
'  *              passed onto the correct function
'  * @param {event} event
'  */
function BOM_ObserverCallback(event) as void
  data =  event.getData()
  if m._observables = invalid
    logError("Observer callback invoked when no node observables were registered")
    return
  end if
  observable = m._observables[data.contextId]
  bindings = observable.bindings[data.fieldName]
  value = observable[fieldName]
  for each functionName in bindings
    functionPointer = m._observableFunctionPointers[functionName]
    if functionPointer <> invalid
      functionPointer(value)
    else
      logError("could not find functoin pointer for function ", functionName)
    end if
  end for
end function

' /**
'  * @member checkValidInputs
'  * @memberof module:BaseObservableMixin
'  * @instance
'  * @description checks the given inputs are valid for binding uses, such as
'  *              generating binding keys
'  * @param {string} fieldName - name of source field
'  * @param {node} targetNode - the target node - must have an id!
'  * @param {string} targetField  - name of target field
'  * @returns {boolean} true if valid
'  */
function BOM_checkValidInputs(fieldName, targetNode, targetField) as boolean
  if not isString(fieldName) or fieldName.trim() = ""
    logError("Tried to bind with illegal fieldName")
    return false
  end if

  if not isString(targetField) or targetField.trim() = ""
    logError("Tried to bind with illegal field")
    return false
  end if

  if type(targetNode) <> "roSGNode"
    logError("Tried to unbind illegal node")
    return false
  end if

  if targetNode.id.trim() = ""
    logError("target node has no id - an id is required for node observing", fieldName, targetField)
    return false
  end if

  return true
end function

function BOM_isRegistered(observable) as boolean
  if not isAACompatible(observable)
    logError("non aa object passed in")
    return false
  end if

  if not observable.doesExist("__observableObject")
    logError("the passed in object is not an Observable subclass")
    return false
  end if

  if observable.doesExist("contextId")
    return true
  end if
  return false
end function