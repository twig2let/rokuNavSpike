'@Namespace BO BaseObservable
'@Import rLogMixin
'@Import Utils

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Base observer class
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ MIXIN METHODS
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function BO_ObserveField(observable, field, functionPointer)
  if not BO_registerObservable(observable)
    return false
  end if
  if not m._observableFunctionPointers.doesExist(functionName)
    m._observableFunctionPointers[functionName] = functionPointer
  end if
  observable.observeField("field", functionName, true)
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
function BO_bindNodeField(targetNode, fieldName, observable, targetField) as boolean
  if not BO_registerObservable(observable)
    return false
  end if

  if not observable.checkValidInputs(fieldName, targetNode, targetField)
    return false
  end if

  nodeKey = targetNode.id + "_" + fieldName
  nodeBindings = m._observableNodeBindings[nodeKey]

  if nodeBindings = invalid
    targetNode.observeFieldScoped(fieldName, "BO_BindingCallback")
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
function BO_unbindNodeField(targetNode, fieldName, observable, targetField) as boolean
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
    node.unobserveFieldScoped(fieldName, "BO_BindingCallback")
  end if

  m._observableNodeBindings[nodeKey] = nodeBindings
  return true
end function

' /**
'  * @member registerObservable
'  * @memberof module:BaseObservable
'  * @instance
'  * @description registers the observer with this node (i.e code benhind)
'  *              which wires up all the context info required to ensure
'  *              scope preservation
'  * @param {observable} instance of an observable
'  */
function BO_registerObservable(observable) as boolean
  if not isAACompatible(observable)
    logError("invalid observable passed in")
    return false
  end if

  if not observable.doesContain("contextId")
    logInfo("this observable has never been registered - setting it's context id")
    if m._observableContextId = invalid
      m["_observableContextId"] = -1
    end if
    m._observableContextId++
    observable.contextId = str(m._observableContextId).trim()
  end if

  if m._observables = invalid
    m._observables = {}
    m._observableFunctionPointers = {}
    m._observableNodeBindings = {}
    m._observableContext = createObject("roSGNode", "ContentNode")
    m._observableContext.addField("bindingMessage", "associativeArray", true)
    m._observableContext.observeFieldScoped("bindingMessage", "BO_BindingCallback")
  end if

  registeredObservable = m._observables[observable.contextId]
  if registerObservable = invalid
    logInfo("this observable was not registered - registering it now with context id ", observable.contextId)
    m._observables[observable.contextId] = observable
    observable.contextNode = m._observableContext
  end if
  return true
end function

function BO_unregisterObservable(observable) as boolean
  if not observable.doesContain("contextId")
    logError("passed in node did not contain a context Id")
  end if

  if m._observables = invalid
    m._observables = {}
  end if
  m._observables.delete(observable.contextId)
  if m._observables.count() = 0
    m._observableContext.unobserveFieldScoped("bindingMessage")
  end if
  observable.contextNode = invalid
  observable.contextId = invalid
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Two way binding convenience
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function BO_bindFieldTwoWay(observable, fieldName, targetNode, targetField, setInitialValue = true) as void
  registerObservable(observable)
  observable.bindField(fieldName, targetNode, targetField, setInitialValue)
  BO_bindNodeField(targetNode, fieldName, observable, targetField)
end function

function BO_unbindFieldTwoWay(observable, fieldName, targetNode, targetField) as void
  registerObservable(observable)
  observable.unbindField(fieldName, targetNode, targetField)
  BO_unbindNodeField(targetNode, fieldName, observable, targetField)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Binding and observer callbacks
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'The following methods are mixed in as conveniences

' /**
'  * @member BO_BindingCallback
'  * @memberof module:BaseObservable
'  * @instance
'  * @description event handler for passing node events to the correct observable field or function
'  * @param {event} event
'  */
function BO_BindingCallback(event) as void
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
'  * @member BO_ObserverCallback
'  * @memberof module:BaseObservable
'  * @instance
'  * @description event handler for passing node events to the correct observable field or function
'  * @param {event} event
'  */
function BO_ObserverCallback(event) as void
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

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Class implementation
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Constructor
' /**
'  * @member BaseObservable
'  * @memberof module:BaseObservable
'  * @instance
'  * @description creates a BaseObserver instance, which you can extend,
'  */
function BaseObservable() as object
  return {
    'vars
    isBindingNotificationEnabled: false
    observers: {}
    pendingObservers: {}
    bindings: {}
    pendingBindings: {}

    destroy: BO_destroy
    checkValidInputs: BO_checkValidInputs
    getNodeFieldBindingKey: BO_getNodeFieldBindingKey
    toggleNotifications: BO_toggleNotifications
    firePendingObserverNotifications: BO_firePendingObserverNotifications
    firePendingBindingNotifications: BO_firePendingBindingNotifications
    setField: BO_setField
    observeField: BO_observeFieldImpl
    unobserveField: BO_unobserveField
    unobserveAllFields: BO_unobserveAllFields
    notify: BO_notify
    bindField: BO_bindField
    unbindField: BO_unbindField
    notifyBinding: BO_notifyBinding
    unbindAllFields: BO_unbindAllFields
  }
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Utils
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function BO_getNodeFieldBindingKey(node, field, targetField)
  return this.contextId + "_" + node.id + "_" + field + "_" + targetField
end function

function BO_checkValidInputs(fieldName, targetNode, targetField, setInitialValue = true) as boolean
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

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ lifecycle
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function BO_destroy() as void
  m.unobserveAllFields()
  m.unbindAllFields()
end function

function BO_toggleNotifications(isEnabled) as void
  m.isBindingNotificationEnabled = isEnabled
  if(m.isBindingNotificationEnabled = true)
    '        logDebug("bindings renabled notifying pending observers")
    m.firePendingObserverNotifications()
    m.firePendingBindingNotifications()
  end if
end function

function BO_firePendingObserverNotifications() as void
  for each field in m.pendingObservers
    m.notify(field, m[field])
  end for
  m.pendingObservers = {}
end function

function BO_firePendingBindingNotifications() as void
  for each field in m.pendingBindings
    m.notifyBinding(field, m[field])
  end for
  m.pendingBindings = {}
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ ObserverPattern
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
' /**
'  * @member setField
'  * @memberof module: BaseObserver
'  * @instance
'  * @description sets the field on this object, and notifies all observers
'  * @param {string} fieldName - name of field to set
'  * @param {any} value - new value
'  * @param {boolean} alwaysNotify - if true, will notify on same value being set
'  * @returns {boolean} true if succesful
'  */
function BO_setField(fieldName, value) as boolean
  if not isString(fieldName)
    logError("Tried to setField with illegal field name")
    return false
  end if

  if type(value) = "<uninitialized>"
    logError("Tried to set a value to uninitialized! interpreting as invalid")
    value = invalid
  end if

  m[fieldName] = value
  m.notify(fieldName, value)
  m.notifyBinding(fieldName, value)
  return true
end function

' /**
'  * @member observeField
'  * @memberof module:BaseObservable
'  * @instance
'  * @description will callback a function in the owning node's scope when the field changes value
'  * @param {string} fieldName - field on this observer to observe
'  * @param {string} functionName - name of function to callback, should be visible to the node's code-behind
'  * @param {boolean} setInitialValue - if true, will call the function on initial setting
'  * @returns {boolean} true if successful
'  */
function BO_observeFieldImpl(fieldName, functionName, setInitialValue = true) as boolean
  'TODO - I think we will want a mixin method for this, that provides a prepackaged node, with a context callback we can invoke
  if not isString(fieldName)
    logError("Tried to observe field with illegal field name")
    return false
  end if

  if not isString(functionName)
    logError("Tried to observe field with illegal function")
    return false
  end if

  observers = m.observers[fieldName]
  if observers = invalid
    observers = {}
  end if
  observers[functionName] = 1

  m.observers[fieldName] = observers
  if setInitialValue
    m.notify(fieldName, m[fieldName], functionName)
  end if
end function

function BO_unobserveField(fieldName, functionName) as boolean
  if not isString(fieldName)
    logError("Tried to unobserve field with illegal field name")
    return false
  end if

  if not isString(functionName)
    logError("Tried to unobserve field with illegal functionName")
    return false
  end if

  observers = m.observers[fieldName]
  if observers = invalid
    observers = {}
  end if
  observers.delete(functionName)
  m.observers[fieldName] = observers
end function

function BO_unobserveAllFields() as void
  m.observers = {}
end function

function BO_notify(fieldName, value) as void
  observers = m.observers[fieldName]
  if observers = invalid
    observers = {}
  end if

  if isUndefined(value)
    logError("Tried notify about uninitialized value! interpreting as invalid")
    value = invalid
  end if

  if m.isBindingNotificationEnabled
    m.contextNode.bindingMessage = {"contextId":m.contextId, "fieldName":fieldName}
  else
    m.pendingObservers[fieldName] = 1
    '        logDebug("notifications disabled - adding to pending observers")
  end if
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Bindings
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

' /**
'  * @member bindField
'  * @memberof module:BaseObservable
'  * @instance
'  * @description binds a field on this observer to the target node's field
'  * @param {string} fieldName - field on this observer to observe
'  * @param {node} targetNode - the node to notify when the field changes - must have a unique id
'  * @param {string} targetField - field on node to update with change values
'  * @param {boolean} setInitialValue - if true, will set the value instantly
'  * @returns {boolean} true if successful
'  */
function BO_bindField(fieldName, targetNode, targetField, setInitialValue = true) as boolean
  if not m.checkValidInputs(fieldName, targetNode, targetField)
    return false
  end if

  bindings = m.bindings[fieldName]
  if bindings = invalid
    bindings = {}
  end if

  key = m.getNodeFieldBindingKey(node, fieldName, targetField)

  if bindings.doesExist(key)
    logWarn("Binding already existed for key")
    binding = bindings[key]
    if binding.node.isSameNode(node)
      logWarn("is same node - ignoring")
      return true
    else
      logError("was a different node - ignoring")
      return false
    end if
  end if

  bindings[key] = {"node": node, "fieldName": fieldName, "targetField": targetField}
  m.bindings[fieldName] = bindings

  if setInitialValue
    m.notifyBinding(fieldName, m[fieldName], key)
  end if

  return true
end function

' /**
'  * @member unbindField
'  * @memberof module:BaseObservable
'  * @instance
'  * @description binds a field on this observer to the target node's field
'  * @param {string} fieldName - field on this observer to observe
'  * @param {node} targetNode - the node to notify when the field changes
'  * @param {string} targetField - field on node to update with change values
'  * @param {boolean} setInitialValue - if true, will set the value instantly
'  * @returns {boolean} true if successful
'  */
function BO_unbindField(fieldName, targetNode, targetField) as boolean
  if not m.checkValidInputs(fieldName, targetNode, targetField)
    return false
  end if

  bindings = m.bindings[fieldName]
  if bindings = invalid
    bindings = {}
  end if

  key = m.getNodeFieldBindingKey(node, fieldName, targetField)

  bindings.delete(key)
  m.bindings[fieldName] = bindings
  return true
end function

' /**
'  * @member notifyBinding
'  * @memberof module:BaseObservable
'  * @instance
'  * @description Will notify observers of fieldName, of it's valie
'  * @param {string} fieldName - field to update
'  * @param {any} value - field to update
'  * @param {string} specificKey - if present, will specify a particular binding key
'  */
function BO_notifyBinding(fieldName, value, specificKey = invalid) as boolean
  bindings = m.bindings[fieldName]
  if bindings = invalid
    logDebug("No bindings for field ", fieldName)
    return false
  end if

  if m.isBindingNotificationEnabled
    for each key in bindings
      if specificKey = invalid or specificKey = key
        binding = bindings[key]
        if type(binding.node) = "roSGNode"
          binding.node.setField(binding.targetField, value)
        else
          logError("Skipping illegal node for field binding: " + key)
        end if
      end if
    end for
  else
    m.pendingBindings[fieldName] = 1
  end if
  return true
end function

function BO_unbindAllFields() as void
  m.bindings = {}
end function

