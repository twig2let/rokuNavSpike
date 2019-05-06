'@Namespace BO BaseObservable
'@Import rLogMixin
'@Import Utils
'@Import ObservableMixin

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Base observer class
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Constructor
' /**
'  * @member BaseObservable
'  * @memberof module:BaseObservable
'  * @instance
'  * @description creates a BaseObserver instance, which you can extend,
'  *              note - that for correct function you must use the BaseObservableMixin methods to interact with this class for registering, observing and binding
'  */
function BaseObservable() as object
  return {
    'vars
    __observableObject: true 'for framework tracking
    isContextValid: false
    isBindingNotificationEnabled: true
    observers: {}
    pendingObservers: {}
    bindings: {}
    pendingBindings: {}

    setContext: BO_setContext
    destroy: BO_destroy
    checkValidInputs: OM_checkValidInputs
    getNodeFieldBindingKey: BO_getNodeFieldBindingKey
    toggleNotifications: BO_toggleNotifications
    firePendingObserverNotifications: BO_firePendingObserverNotifications
    firePendingBindingNotifications: BO_firePendingBindingNotifications
    setField: BO_setField
    observeField: BO_observeField
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
  return m.contextId + "_" + node.id + "_" + field + "_" + targetField
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ lifecycle
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

' /**
'  * @member setContext
'  * @memberof module:BaseObservable
'  * @instance
'  * @description an observable needs a binding context so it can communicate with it's
'  *              owner's scope (i.e. node/task). This method should be called
'  *              as part of the BaseObservableMixin methods : do not invoke this directly
'  * @param {string} contextId - the id of the context, as per the owner
'  * @param {node} contextNode - the owner's context node, which is used to handle
'  *                             scoped communication for observer/binding callbacks
'  */
function BO_setContext(contextId, contextNode) as void
  m.contextId = contextId
  m.contextNode = contextNode
  m.isContextValid = isString(contextId) and type(contextNode) = "roSGNode"

  if(m.isContextValid and m.isBindingNotificationEnabled = true)
    m.firePendingObserverNotifications()
    m.firePendingBindingNotifications()
  end if
end function

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
    m.notify(field)
  end for
  m.pendingObservers = {}
end function

function BO_firePendingBindingNotifications() as void
  for each field in m.pendingBindings
    m.notifyBinding(field)
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
function BO_setField(fieldName, value, originKey = invalid) as boolean
  if not isString(fieldName) or fieldName.trim() = ""
    logError("Tried to setField with illegal field name")
    return false
  end if

  if type(value) = "<uninitialized>"
    logError("Tried to set a value to uninitialized! interpreting as invalid")
    value = invalid
  end if

  m[fieldName] = value
  m.notify(fieldName)
  m.notifyBinding(fieldName, originKey)
  return true
end function

' /**
'  * @member observeField
'  * @memberof module:BaseObservable
'  * @instance
'  * @description will callback a function in the owning node's scope when the field changes value
'  * @param {string} fieldName - field on this observer to observe
'  * @param {string} functionName - name of function to callback, should be visible to the node's code-behind
'  * @param {assocarray} properties - the properties for the particular binding
'  *                     - can include
'  *                     isSettingInitialValue -(default true) if true,
'  *                          will set the value instantly
'  *                     transformFunction - function pointer to a value that will modify the value before calling the binding.
'  * @returns {boolean} true if successful
'  */
function BO_observeField(fieldName, functionName, properties = invalid) as boolean
  'TODO - I think we will want a mixin method for this, that provides a prepackaged node, with a context callback we can invoke
  if not isString(fieldName) or fieldName.trim() = ""
    logError("Tried to observe field with illegal field name")
    return false
  end if

  if not isString(functionName) or functionName.trim() = ""
    logError("Tried to observe field with illegal function")
    return false
  end if

  if properties = invalid
    properties = OM_createBindingProperties()
  end if

  observers = m.observers[fieldName]
  if observers = invalid
    observers = {}
  end if
  observers[functionName] = properties

  m.observers[fieldName] = observers
  if properties.isSettingInitialValue = true
    m.notify(fieldName)
  end if
  return true
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

  if observers.count() = 0
    m.observers.delete(fieldName)
  else
    m.observers[fieldName] = observers
  end if
  return true
end function

function BO_unobserveAllFields() as void
  m.observers = {}
end function

function BO_notify(fieldName) as void
  observers = m.observers[fieldName]
  if observers = invalid
    observers = {}
  end if

  value = m[fieldName]
  if isUndefined(value)
    logError("Tried notify about uninitialized value! interpreting as invalid")
    value = invalid
  end if

  if m.isBindingNotificationEnabled and m.isContextValid
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
'  * @param {assocarray} properties - the properties for the particular binding
'  *                     - can include
'  *                     isSettingInitialValue -(default true) if true,
'  *                          will set the value instantly
'  *                     transformFunction - function pointer to a value that will modify the value before calling the binding.
'  * @returns {boolean} true if successful
'  */
function BO_bindField(fieldName, targetNode, targetField, properties = invalid) as boolean
  if not m.checkValidInputs(fieldName, targetNode, targetField)
    return false
  end if

  if properties = invalid
    properties = OM_createBindingProperties()
  end if

  if not m.isContextValid
    logError("tried to bind a field when a context was not set. Be sure to use the mixin methods to configure bindings on your observable")
    return false
  end if

  bindings = m.bindings[fieldName]
  if bindings = invalid
    bindings = {}
  end if

  key = m.getNodeFieldBindingKey(targetNode, fieldName, targetField)

  if bindings.doesExist(key)
    logWarn("Binding already existed for key")
    binding = bindings[key]
    if binding.node.isSameNode(targetNode)
      logWarn("is same node - ignoring")
      return true
    else
      logError("was a different node - ignoring")
      return false
    end if
  end if

  bindings[key] = {"node": targetNode, "fieldName": fieldName, "targetField": targetField, "transformFunction": properties.transformFunction}
  m.bindings[fieldName] = bindings

  if properties.isSettingInitialValue = true
    m.notifyBinding(fieldName, key)
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
'  * @returns {boolean} true if successful
'  */
function BO_unbindField(fieldName, targetNode, targetField) as boolean
  if not m.checkValidInputs(fieldName, targetNode, targetField)
    return false
  end if

  if not m.isContextValid
    logError("tried to unbind a field when a context was not set. Be sure to use the mixin methods to configure bindings on your observable")
    return false
  end if

  bindings = m.bindings[fieldName]
  if bindings = invalid
    bindings = {}
  end if

  key = m.getNodeFieldBindingKey(targetNode, fieldName, targetField)
  if not bindings.doesExist(key)
    logError("tried to unbind unknown field/node/target field with id of", key)
  end if
  bindings.delete(key)
  if bindings.count() > 0
    m.bindings[fieldName] = bindings
  else
    m.bindings.delete(fieldName)
  end if
  return true
end function

' /**
'  * @member notifyBinding
'  * @memberof module:BaseObservable
'  * @instance
'  * @description Will notify observers of fieldName, of it's value
'  * @param {string} fieldName - field to update
'  * @param {string} specificKey - if present, will specify a particular binding key
'  * @param {string} excludeKey - if present, will not update this node field - to stop cyclical bindings
'  */
function BO_notifyBinding(fieldName, specificKey = invalid, excludeKey = invalid) as boolean
  bindings = m.bindings[fieldName]
  if bindings = invalid
    ' logVerbose("No bindings for field ", fieldName)
    return false
  end if
  value = m[fieldName]
  value = m[fieldName]
  if isUndefined(value)
    logError("Tried notify about uninitialized value! interpreting as invalid")
    value = invalid
  end if
  if m.isBindingNotificationEnabled
    for each key in bindings
      if (specificKey = invalid or specificKey = key) and (excludeKey = invalid or excludeKey <> key)
        binding = bindings[key]
        if type(binding.node) = "roSGNode"
          if binding.transformFunction <> invalid
            bindingValue = binding.transformFunction(value)
          else
            bindingValue = value
          end if
          binding.node.setField(binding.targetField, bindingValue)
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

