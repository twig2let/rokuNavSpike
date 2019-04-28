'@Namespace BOM ObservableMixin
'@Import rLogMixin
'@Import Utils

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ MIXIN METHODS
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

' /**
'  * @member OM_ObserveField
'  * @memberof module:ObservableMixin
'  *
'  * @description observes the field on observable, calling the passed in function when the value changes
'  * @param {BaseObservable} observable instance of observable
'  * @param {string} field field to observe on the passed in observable
'  * @param {function} functionPointer method to invoke when the value changes
'  * @returns {returnType} returnDescription
'  */
function OM_ObserveField(observable, field, functionPointer) as boolean
  if not OM_registerObservable(observable)
    logError("could not observe field - the observable failed to register")
    return false
  end if

  if not isFunction(functionPointer)
    logError("the function pointer MUST be a function")
    return false
  end if

  functionName = functionPointer.toStr().mid(10)

  if not m._observableFunctionPointers.doesExist(functionName)
    m._observableFunctionPointerCounts[functionName] = 0
    m._observableFunctionPointers[functionName] = functionPointer
  end if
  m._observableFunctionPointerCounts[functionName] = m._observableFunctionPointerCounts[functionName] +1
  return observable.observeField(field, functionName, true)
end function

' /**
'  * @member OM_unobserveField
'  * @memberof module:ObservableMixin
'  *
'  * @description removes the observer for the given field
'  * @param {paramType} paramDescription
'  * @returns {returnType} returnDescription
'  */
function OM_unobserveField(observable, fieldName, functionPointer) as boolean
  if not OM_isRegistered(observable)
    logError("could not unobserve field - the observable has not been registered")
    return false
  end if

  if not isFunction(functionPointer)
    logError("the function pointer MUST be a function")
    return false
  end if
  functionName = functionPointer.toStr().mid(10)
  if m._observableFunctionPointerCounts.doesExist(functionName)
    m._observableFunctionPointerCounts[functionName] = m._observableFunctionPointerCounts[functionName] - 1

    if m._observableFunctionPointerCounts[functionName] = 0
      m._observableFunctionPointers.delete(functionName)
      m._observableFunctionPointerCounts.delete(functionName)
    end if
  end if
  return observable.unobserveField(fieldName, functionName)
end function

' /**
'  * @member bindNodeField
'  * @memberof module:ObservableMixin
'  *
'  * @description binds a field on the passed in node to a field on the passed in observer
'  * @param {node} targetNode - the node to notify when the field changes - must have a unique id
'  * @param {string} fieldName - field on the node to observe
'  * @param {BaseObservable} observable - observable instance
'  * @param {string} targetField - field on the observable to update with change values
'  * @param {boolean} setInitialValue - if true, then the initial value is populated
'  * @returns {boolean} true if successful
'  */
function OM_bindNodeField(targetNode, fieldName, observable, targetField, setInitialValue = true) as boolean
  if not OM_registerObservable(observable)
    logError("could not bind node field - the observable failed to register")
    return false
  end if

  if not observable.checkValidInputs(fieldName, targetNode, targetField)
    return false
  end if

  nodeKey = targetNode.id + "_" + fieldName
  nodeBindings = m._observableNodeBindings[nodeKey]

  if nodeBindings = invalid
    targetNode.observeFieldScoped(fieldName, "OM_BindingCallback")
    nodeBindings = {}
  end if

  key = observable.getNodeFieldBindingKey(targetNode, fieldName, targetField)

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
  if setInitialValue
    if isFunction(observable[targetField])
      observable[targetField](targetNode[fieldName])
    else
      if not observable.doesExist(targetField)
        logWarn(targetField, "was not present on observable when setting initial value for node key", nodeKey)
      end if
      observable.setField(targetField, targetNode[fieldName])
    end if
  end if
  return true
end function

' /**
'  * @member unbindNodeField
'  * @memberof module:ObservableMixin
'  *
'  * @description unbinds a field on the passed in node to a field on the passed in observable
'  * @param {node} targetNode - the node to notify when the field changes - must have a unique id
'  * @param {string} nodeField - field on the node to observe
'  * @param {string} observableField - field on this observer to update with change values
'  * @returns {boolean} true if successful
'  */
function OM_unbindNodeField(targetNode, nodeField, observable, observableField) as boolean
  if not OM_checkValidInputs(observableField, targetNode, nodeField)
    return false
  end if

  nodeKey = targetNode.id + "_" + nodeField
  nodeBindings = m._observableNodeBindings[nodeKey]
  if nodeBindings = invalid
    nodeBindings = {}
  end if

  key = observable.getNodeFieldBindingKey(targetNode, nodeField, observableField)
  bindings = nodeBindings[key]

  if bindings <> invalid
    nodeBindings.delete(key)
  end if

  if nodeBindings.count() = 0
    targetNode.unobserveFieldScoped(nodeField)
    m._observableNodeBindings.delete(nodeKey)
  else
    m._observableNodeBindings[nodeKey] = nodeBindings

  end if

  return true
end function

' /**
'  * @member registerObservable
'  * @memberof module:ObservableMixin
'  *
'  * @description registers the observer with this node (i.e code behind for component/task)
'  *              which wires up all the context info required to ensure
'  *              scope preservation.
'  *              if this observable is already registered, then this method returns true
'  *              This method is called whenever we try to bindObservable, observe, bindNode
'  * @param {observable} instance of an observable
'  * @returns {boolean} true if successfully registered, or was already registered
'  */
function OM_registerObservable(observable) as boolean
  if not OM_isObservable(observable)
    logError("the passed in object is not an Observable subclass")
    return false
  end if

  if observable.doesExist("contextId") and m._observables <> invalid and m._observables.doesExist(observable.contextId)
    'we don't need to reregister this observable
    'TODO - check if it's the same observable; but that will require
    'enforcing ids or internal guids..
    return true
  end if

  logVerbose("this observable has never been registered - creating a new context id")
  if m._observableContextId = invalid
    m["_observableContextId"] = -1
  end if
  m._observableContextId++
  contextId = str(m._observableContextId).trim()

  if m._observables = invalid
    m._observables = {}
    m._observableFunctionPointers = {}
    m._observableFunctionPointerCounts = {}
    m._observableNodeBindings = {}
    m._observableContext = createObject("roSGNode", "ContentNode")
    m._observableContext.addField("bindingMessage", "assocarray", true)
    m._observableContext.observeField("bindingMessage", "OM_ObserverCallback")
  end if

  registeredObservable = m._observables[contextId]
  if registeredObservable = invalid
    m._observables[contextId] = observable
    observable.setContext(contextId, m._observableContext)
  else
    logError("this context id was registered before - node binding context is corrupt!! This should not happen - this needs investigation! - contextId: ", contextId)
  end if
  return true
end function

' /**
'  * @member OM_unregisterObservable
'  * @memberof module:ObservableMixin
'  *
'  * @description unregisters the passed in observable
'  * @param {BaseObservable} instance of an observable
'  * @returns {boolean} true if successfully removed
'  */
function OM_unregisterObservable(observable) as boolean
  if not OM_isRegistered(observable)
    logError("passed in node did not contain a context Id")
    return false
  end if

  if m._observables = invalid
    m._observables = {}
  end if
  m._observables.delete(observable.contextId)
  if m._observables.count() = 0
    logInfo("unregistered last observable, cleaning up")
    OM_cleanup()
  end if
  observable.setContext(invalid, invalid)
  return true
end function

' /**
'  * @member OM_bindObservableField
'  * @memberof module:ObservableMixin
'  *
'  * @description binds the field from observable, to the target node's field
'  * @param {observable} observable - instance of observable
'  * @param {string} fieldName - name of field to bind
'  * @param {node} targetNode - node to set bound field value on
'  * @param {string} targetField - name of field to set on node
'  * @param {boolean} setInitialValue - whether value should be set straight away
'  * @returns {boolean} true if successful
'  */
function OM_bindObservableField(observable, fieldName, targetNode, targetField, setInitialValue = true) as boolean
  if OM_registerObservable(observable)
    return observable.bindField(fieldName, targetNode, targetField, setInitialValue)
  end if
  return false
end function

' /**
'  * @member OM_unbindObservableField
'  * @memberof module:ObservableMixin
'  *
'  * @description removes binding for the field from observable, to the target node's field
'  * @param {observable} observable - instance of observable
'  * @param {string} fieldName - name of field to bind
'  * @param {node} targetNode - node to set bound field value on
'  * @param {string} targetField - name of field to set on node
'  * @returns {boolean} true if successful
'  */
function OM_unbindObservableField(observable, fieldName, targetNode, targetField) as boolean
  if OM_isObservable(observable)
    return observable.unbindField(fieldName, targetNode, targetField)
  end if
  return false
end function
' /**
'  * @member OM_cleanup
'  * @memberof module:ObservableMixin
'  *
'  * @description cleans up all vars associated with binding support
'  */
function OM_cleanup()
  if m._observableContext <> invalid
    m._observableContext.unobserveField("bindingMessage")
  end if
  'TODO - remove all bindings!
  m.delete("_observables")
  m.delete("_observableContextId")
  m.delete("_observableFunctionPointers")
  m.delete("_observableNodeBindings")
  m.delete("_observableContext")
  m.delete("_observableFunctionPointerCounts")
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Two way binding convenience
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

' /**
'  * @member OM_bindFieldTwoWay
'  * @memberof module:ObservableMixin
'  *
'  * @description wires the field on the observable to the target field on the targetNode, and will update it in a 2 way relationship
'  * @param {BaseObservable} observable - instance to bind
'  * @param {string} fieldName - field on observable to bind
'  * @param {roSGNode} targetNode - node to bind to
'  * @param {string} targetField - field on target node to bind to
'  * @param {boolean} setInitialValue, if true, then the binding is invoked with the current value
'  */
function OM_bindFieldTwoWay(observable, fieldName, targetNode, targetField, setInitialValue = true) as void
  OM_bindObservableField(observable, fieldName, targetNode, targetField, setInitialValue)
  OM_bindNodeField(targetNode, targetField, observable, fieldName, false)
end function

' /**
'  * @member OM_unbindFieldTwoWay
'  * @memberof module:ObservableMixin
'  *
'  * @description unwires the field on the observable to the target field on the targetNode
'  * @param {BaseObservable} observable - instance to bind
'  * @param {string} observableField - field on observable to bind
'  * @param {roSGNode} targetNode - node to bind to
'  * @param {string} nodeField - field on target node to bind to
'  */
function OM_unbindFieldTwoWay(observable, observableField, targetNode, nodeField) as void
  if OM_isRegistered(observable)
    OM_unbindObservableField(observable, observableField, targetNode, nodeField)
    OM_unbindNodeField(targetNode, nodeField, observable, observableField)
  else
    logError("could not unbind two way - the observable has not yet been registered")
  end if
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Binding and observer callbacks
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'The following methods are mixed in as conveniences

' /**
'  * @member OM_BindingCallback
'  * @memberof module:ObservableMixin
'  *
'  * @description event handler for processing node events to set the value on
'  *              the correct observable field or invoke the correct observable function
'  * @param {event} event
'  */
function OM_BindingCallback(event) as void
  if m._observableNodeBindings = invalid
    logError("Binding callback invoked when no node bindings were registered")
    return
  end if

  if m._observables = invalid
    logError("Observer callback invoked when no node observables were registered")
    return
  end if

  nodeKey = event.getNode() + "_" + event.getField()
  nodeBindings = m._observableNodeBindings[nodeKey]
  value = event.getData()
  for each key in nodeBindings
    bindingData = nodeBindings[key]
    observable = m._observables[bindingData.contextId]
    if isAACompatible(observable)
      if isFunction(observable[bindingData.targetField])
        observable[bindingData.targetField](value)
      else
        if not observable.doesExist(bindingData.targetField)
          logWarn(bindingData.targetField, "was not present on observable when setting value for nodeKey", nodeKey)
        end if
        observable.setField(bindingData.targetField, value, key)
      end if
    else
      logError("could not find observable with context id ", contextId)
    end if
  end for
end function

' /**
'  * @member OM_ObserverCallback
'  * @memberof module:ObservableMixin
'  *
'  * @description event handler for handling observable events, which then get
'  *              passed onto the correct function
'  * @param {event} event
'  */
function OM_ObserverCallback(event) as void
  if m._observables = invalid
    logError("Observer callback invoked when no node observables were registered")
    return
  end if

  data =  event.getData()
  observable = m._observables[data.contextId]
  observers = observable.observers[data.fieldName]
  if observers <> invalid
    value = observable[data.fieldName]
    for each functionName in observers
      functionPointer = m._observableFunctionPointers[functionName]
      if functionPointer <> invalid
        functionPointer(value)
      else
        logError("could not find functoin pointer for function ", functionName)
      end if
    end for
  end if
end function

' /**
'  * @member checkValidInputs
'  * @memberof module:ObservableMixin
'  *
'  * @description checks the given inputs are valid for binding uses, such as
'  *              generating binding keys
'  * @param {string} fieldName - name of source field
'  * @param {node} targetNode - the target node - must have an id!
'  * @param {string} targetField  - name of target field
'  * @returns {boolean} true if valid
'  */
function OM_checkValidInputs(fieldName, targetNode, targetField) as boolean
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

function OM_isObservable(observable) as boolean
  if not isAACompatible(observable)
    logError("non aa object passed in")
    return false
  end if

  if not observable.doesExist("__observableObject")
    logError("the passed in object is not an Observable subclass")
    return false
  end if

  return true
end function

function OM_isRegistered(observable) as boolean
  return OM_isObservable(observable) and observable.doesExist("contextId")
end function