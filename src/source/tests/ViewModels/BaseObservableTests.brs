'@TestSuite [BOT] BaseObservable Tests

'@BeforeEach
function BOT_BeforeEach()
  m.defaultBindableProperties = OM_createBindingProperties()
  m.observable = BaseObservable()
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests constructor
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function BOT_constructor()
  m.assertTrue(m.observable.__observableObject)
  m.assertTrue(m.observable.isBindingNotificationEnabled)
  m.assertFalse(m.observable.isContextValid)
  m.assertEmpty(m.observable.observers)
  m.assertEmpty(m.observable.bindings)
  m.assertEmpty(m.observable.pendingObservers)
  m.assertEmpty(m.observable.pendingBindings)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests setField
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test primitive types
'@Params["testField", invalid]
'@Params["testField", "stringValue"]
'@Params["testField", 22]
'@Params["testField", 22.5]
'@Params["testField", {}]
'@Params["testField", {"someField":"#value"}]
'@Params["testField2", invalid]
'@Params["testField2", "stringValue"]
'@Params["testField2", 22]
'@Params["testField2", 22.5]
'@Params["testField2", {}]
'@Params["testField2", {"someField":"#value"}]
function BOT_setField(fieldName, value)
  m.expectOnce(m.observable, "notify", [fieldName])
  m.expectOnce(m.observable, "notifyBinding", [fieldName])

  m.observable.setField(fieldName, value)

  m.AssertEqual(m.observable[fieldName], value)
end function

'@Test set multiple times
function BOT_setField_multiple()
  m.expectOnce(m.observable, "notify", ["_fieldName"])
  m.expectOnce(m.observable, "notifyBinding", ["_fieldName"])
  m.expectOnce(m.observable, "notify", ["_fieldName"])
  m.expectOnce(m.observable, "notifyBinding", ["_fieldName"])
  m.expectOnce(m.observable, "notify", ["_fieldName"])
  m.expectOnce(m.observable, "notifyBinding", ["_fieldName"])

  m.observable.setField("_fieldName", 1)
  m.observable.setField("_fieldName", 2)
  m.observable.setField("_fieldName", 3)

  m.AssertEqual(m.observable._fieldName, 3)
end function

'@Test uninitialized value
function BOT_setField_illegalFieldName()
  m.expectOnce(m.observable, "notify", ["testValue"])
  m.expectOnce(m.observable, "notifyBinding", ["testValue"])

  m.observable.setField("testValue", someUndefinedVar)

  m.AssertEqual(m.observable.testValue, invalid)
end function

'@Test setField for node
function BOT_setField_node()
  value = createObject("roSGNode", "ContentNode")

  m.expectOnce(m.observable, "notify", ["testValue"])
  m.expectOnce(m.observable, "notifyBinding", ["testValue"])

  m.observable.setField("testValue", value)

  m.AssertEqual(m.observable.testValue, value)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests destroy
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test
function BOT_destroy()
  m.expectOnce(m.observable, "unobserveAllFields")
  m.expectOnce(m.observable, "unbindAllFields")

  m.observable.destroy()
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests checkValidInputs
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test invalid inputs
'@Params[invalid, invalid, invalid, false]
'@Params["", invalid, "", false]
'@Params["  ", invalid, "  ", false]
'@Params["", {}, "", false]
'@Params["valid", {}, "", false]
'@Params["valid", {}, "valid", false]
function BOT_checkValidInputs(fieldName, targetNode, targetField, expected)
  value = m.observable.checkValidInputs(fieldName, targetNode, targetField)

  m.assertEqual(value, expected)
end function

'@Test invalid node ids
'@Params[""]
'@Params["   "]
function BOT_checkValidInputs_invalid_nodeIds(nodeId)
  targetNode = createObject("roSGNode", "ContentNode")
  targetNode.id = nodeId

  value = m.observable.checkValidInputs("_fieldName", targetNode, "targetField")

  m.assertFalse(value)
end function

'@Test valid node ids
'@Params["valid1"]
'@Params["valid2"]
function BOT_checkValidInputs_valid_nodeIds(nodeId)
  targetNode = createObject("roSGNode", "ContentNode")
  targetNode.id = nodeId

  value = m.observable.checkValidInputs("_fieldName", targetNode, "targetField")

  m.assertTrue(value)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests getNodeFieldBindingKey
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test invalid inputs
'@Params["contextId", "nodeId", "field", "targetField", "contextId_nodeId_field_targetField"]
'@Params["contextId2", "nodeId2", "field2", "targetField2", "contextId2_nodeId2_field2_targetField2"]
function BOT_getNodeFieldBindingKey(contextId, nodeId, field, targetField, expected)
  m.observable.contextId = contextId
  node = createObject("roSGNode", "ContentNode")
  node.id = nodeId

  value = m.observable.getNodeFieldBindingKey(node, field, targetField)

  m.assertEqual(value, expected)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests toggleNotifications
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test on
function BOT_toggleNotifications_on()
  m.expectOnce(m.observable, "firePendingObserverNotifications")
  m.expectOnce(m.observable, "firePendingBindingNotifications")

  m.observable.toggleNotifications(true)

  m.assertTrue(m.observable.isBindingNotificationEnabled)
end function

'@Test off
function BOT_toggleNotifications_off()
  m.expectNone(m.observable, "firePendingObserverNotifications")
  m.expectNone(m.observable, "firePendingBindingNotifications")

  m.observable.toggleNotifications(false)

  m.assertFalse(m.observable.isBindingNotificationEnabled)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests firePendingObserverNotifications
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test no notifications
function BOT_firePendingObserverNotifications_none()
  m.expectNone(m.observable, "notify")

  m.observable.firePendingObserverNotifications()

  m.assertEmpty(m.observable.pendingObservers)
end function

'@Test one notification
'@Params["fieldA", "a"]
'@Params["fieldB", "b"]
function BOT_firePendingObserverNotifications_one(field1Name, value1)
  m.expectOnce(m.observable, "notify", [field1Name])
  m.observable[field1Name] = value1
  m.observable.pendingObservers = {}
  m.observable.pendingObservers[field1Name] = 1
  m.observable.firePendingObserverNotifications()

  m.assertEmpty(m.observable.pendingObservers)
end function

'@Test multiple notification
'@Params["fieldA", "a", "fieldB", "b", "fieldC", "c"]
function BOT_firePendingObserverNotifications_multiple(field1Name, value1, field2Name, value2, field3Name, value3)
  'note these come out in a very specific order
  m.expectOnce(m.observable, "notify", [field3Name])
  m.expectOnce(m.observable, "notify", [field1Name])
  m.expectOnce(m.observable, "notify", [field2Name])
  m.observable[field1Name] = value1
  m.observable[field2Name] = value2
  m.observable[field3Name] = value3
  m.observable.pendingObservers = {}
  m.observable.pendingObservers[field1Name] = 1
  m.observable.pendingObservers[field2Name] = 1
  m.observable.pendingObservers[field3Name] = 1
  m.observable.firePendingObserverNotifications()

  m.assertEmpty(m.observable.pendingObservers)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests firePendingBindingNotifications
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test no notifications
function BOT_firePendingBindingNotifications_none()
  m.expectNone(m.observable, "notifyBinding")

  m.observable.firePendingBindingNotifications()

  m.assertEmpty(m.observable.pendingBindings)
end function

'@Test one notification
'@Params["fieldA", "a"]
'@Params["fieldB", "b"]
function BOT_firePendingBindingNotifications_one(field1Name, value1)
  m.expectOnce(m.observable, "notifyBinding", [field1Name])
  m.observable[field1Name] = value1
  m.observable.pendingBindings = {}
  m.observable.pendingBindings[field1Name] = 1
  m.observable.firePendingBindingNotifications()

  m.assertEmpty(m.observable.pendingBindings)
end function

'@Test multiple notification
'@Params["fieldA", "a", "fieldB", "b", "fieldC", "c"]
function BOT_firePendingBindingNotifications_multiple(field1Name, value1, field2Name, value2, field3Name, value3)
  'note these come out in a very specific order
  m.expectOnce(m.observable, "notifyBinding", [field3Name])
  m.expectOnce(m.observable, "notifyBinding", [field1Name])
  m.expectOnce(m.observable, "notifyBinding", [field2Name])
  m.observable[field1Name] = value1
  m.observable[field2Name] = value2
  m.observable[field3Name] = value3
  m.observable.pendingBindings = {}
  m.observable.pendingBindings[field1Name] = 1
  m.observable.pendingBindings[field2Name] = 1
  m.observable.pendingBindings[field3Name] = 1
  m.observable.firePendingBindingNotifications()

  m.assertEmpty(m.observable.pendingBindings)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests observeField
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test invalid values
'@Params[invalid, invalid]
'@Params["", invalid]
'@Params["", ""]
'@Params[invalid, ""]
'@Params["   ", "   "]
'@Params["_fieldName", ""]
'@Params["", "functionName"]
function BOT_observeField(fieldName, functionName)
  m.expectNone(m.observable, "notify")

  m.observable.observeField(fieldName, functionName)

  m.assertEmpty(m.observable.observers)
end function

'@Test valud default initial value
'@Params["field1", "function1", "#value1"]
function BOT_observeField_valid_defaultisSettingInitialValue(fieldName, functionName, value)
  m.expectOnce(m.observable, "notify", [fieldName])
  m.observable[fieldName] = value
  m.observable.observeField(fieldName, functionName)

  m.assertArrayCount(m.observable.observers, 1)
  m.assertEqual(m.observable.observers[fieldName][functionName], m.defaultBindableProperties)
end function

'@Test valid
'@Params["field1", "function1", "#value1", true, 1]
'@Params["field1", "function1", "#value1", false, 0]
function BOT_observeField_valid(fieldName, functionName, value, isSettingInitialValue, expectedNotifyCount)
  properties = OM_createBindingProperties(isSettingInitialValue)
  m.expect(m.observable, "notify", expectedNotifyCount, [fieldName])
  m.observable[fieldName] = value
  m.observable.observeField(fieldName, functionName, properties)

  m.assertArrayCount(m.observable.observers, 1)
  m.assertAAHasKey(m.observable.observers[fieldName], functionName)

end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests unobserveField
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test valid - one observer one field - no initial set value
'@Params["field1", "function1", "#value1"]
'@Params["field1", "function1", "#value1"]
function BOT_unobserveField_valid_oneObserver_oneField(fieldName, functionName, value)
  m.observable[fieldName] = value
  m.observable.observeField(fieldName, functionName, {isSettingInitialValue:false})

  m.assertArrayCount(m.observable.observers, 1)
  m.assertAAHasKey(m.observable.observers[fieldName], functionName)

  m.observable.unobserveField(fieldName, functionName)

  m.assertEmpty(m.observable.observers)
end function

'@Test valid - multiple observer one field
function BOT_unobserveField_valid_multipleObservers_oneField()
  m.observable["field1"] = 1
  m.observable["field2"] = 2
  m.observable.observeField("field1", "func1", {isSettingInitialValue:false})
  m.observable.observeField("field1", "func2", {isSettingInitialValue:false})

  m.assertArrayCount(m.observable.observers, 1)
  m.assertAAHasKey(m.observable.observers["field1"], "func1")
  m.assertAAHasKey(m.observable.observers["field1"], "func2")

  m.observable.unobserveField("field1", "func1")

  m.assertArrayCount(m.observable.observers, 1)
  m.assertAANotHasKey(m.observable.observers["field1"], "func1")
  m.assertAAHasKey(m.observable.observers["field1"], "func2")

  m.observable.unobserveField("field1", "func2")
  m.assertEmpty(m.observable.observers)
end function

'@Test valid - multiple observers multiple fields
function BOT_unobserveField_valid_multipleObservers_multipleFields()
  m.observable["field1"] = 1
  m.observable["field2"] = 2
  m.observable.observeField("field1", "func1", {isSettingInitialValue:false})
  m.observable.observeField("field1", "func2", {isSettingInitialValue:false})
  m.observable.observeField("field2", "func1", {isSettingInitialValue:false})

  m.assertArrayCount(m.observable.observers, 2)

  m.assertAAHasKey(m.observable.observers["field1"], "func1")
  m.assertAAHasKey(m.observable.observers["field1"], "func2")
  m.assertAAHasKey(m.observable.observers["field2"], "func1")

  m.observable.unobserveField("field1", "func1")

  m.assertArrayCount(m.observable.observers, 2)
  m.assertAANotHasKey(m.observable.observers["field1"], "func1")
  m.assertAAHasKey(m.observable.observers["field1"], "func2")
  m.assertAAHasKey(m.observable.observers["field2"], "func1")

  m.observable.unobserveField("field1", "func2")

  m.assertArrayCount(m.observable.observers, 1)
  m.assertAANotHasKey(m.observable.observers, "field1")
  m.assertAAHasKey(m.observable.observers["field2"], "func1")

  m.observable.unobserveField("field2", "func1")
  m.assertEmpty(m.observable.observers)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests setContext
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test invalid
'@Params[invalid, invalid]
'@Params[22, invalid]
function BOT_setContext_invalid(contextId, contextNode)
  m.observable.setContext(contextId, contextNode)

  m.assertFalse(m.observable.isContextValid)
end function

'@Test valid node
'@Params[invalid]
'@Params[22]
function BOT_setContext_valid_node_invalidContextId(contextId)
  contextNode = BOT_createContextNode()

  m.observable.setContext(contextId, contextNode)

  m.assertFalse(m.observable.isContextValid)
end function

'@Test valid no pending bindings
function BOT_setContext_valid_noPendingBindings()
  m.expectOnce(m.observable, "firePendingObserverNotifications")
  m.expectOnce(m.observable, "firePendingBindingNotifications")
  contextNode = BOT_createContextNode()

  m.observable.setContext("1", contextNode)

  m.assertTrue(m.observable.isContextValid)
end function

'@Test valid pending bindings, but binding notifications off
function BOT_setContext_valid_pendingBindings_observerOff()
  m.expectNone(m.observable, "firePendingObserverNotifications")
  m.expectNone(m.observable, "firePendingBindingNotifications")
  m.observable.isBindingNotificationEnabled = false
  m.observable["field1Name"] = "#value1"
  m.observable.pendingObservers = {}
  m.observable.pendingObservers["field1Name"] = 1
  contextNode = BOT_createContextNode()

  m.observable.setContext("1", contextNode)

  m.assertTrue(m.observable.isContextValid)
end function

'@Test valid pending bindings, binding notifications on
function BOT_setContext_valid_pendingBindings()
  m.expectOnce(m.observable, "firePendingObserverNotifications")
  m.expectOnce(m.observable, "firePendingBindingNotifications")
  m.observable.isBindingNotificationEnabled = true
  m.observable["field1Name"] = "#value1"
  m.observable.pendingObservers = {}
  m.observable.pendingObservers["field1Name"] = 1
  contextNode = BOT_createContextNode()

  m.observable.setContext("1", contextNode)

  m.assertTrue(m.observable.isContextValid)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests unobserveAllFields
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test valid - one observer one field
'@Params["field1", "function1", "#value1"]
'@Params["field1", "function1", "#value1"]
function BOT_unobserveAllFields_valid_oneObserver_oneField(fieldName, functionName, value)
  m.observable[fieldName] = value
  m.observable.observeField(fieldName, functionName, {isSettingInitialValue:false})
  m.assertArrayCount(m.observable.observers, 1)

  m.assertAAHasKey(m.observable.observers[fieldName], functionName)

  m.observable.unobserveAllFields()

  m.assertEmpty(m.observable.observers)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests notify
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test 1 field, 1 observer, notifications, no context
function BOT_notify_oneObserver_oneField_notificationsEnabled_noContext()
  m.observable["_fieldName"] = "#value"
  m.observable.isBindingNotificationEnabled = true
  m.observable.observeField("_fieldName", "testFunction", {isSettingInitialValue:false})

  m.assertArrayCount(m.observable.observers, 1)
  m.assertAAHasKey(m.observable.observers._fieldName, "testFunction")

  m.observable.notify.("_fieldName")

  m.assertEqual(m.observable.pendingObservers._fieldName, 1)
end function

'@Test 1 field, 1 observer, context, no notifications
function BOT_notify_oneObserver_oneField_notificationsDisabled_context()
  m.observable["_fieldName"] = "#value"
  contextNode = BOT_createContextNode()
  m.observable.setContext("1", contextNode)
  m.observable.isBindingNotificationEnabled = false
  m.observable.observeField("_fieldName", "testFunction", {isSettingInitialValue:false})

  m.assertArrayCount(m.observable.observers, 1)
  m.assertAAHasKey(m.observable.observers._fieldName, "testFunction")

  m.observable.notify("_fieldName")

  m.assertEqual(m.observable.pendingObservers._fieldName, 1)
end function

'@Test 1 field, 1 observer, context,  notifications
function BOT_notify_oneObserver_oneField_notificationsEnabled_context()
  m.observable["_fieldName"] = "#value"
  contextNode = BOT_createContextNode()
  m.observable.setContext("1", contextNode)
  m.observable.isBindingNotificationEnabled = true
  m.observable.observeField("_fieldName", "testFunction", {isSettingInitialValue:false})

  m.assertArrayCount(m.observable.observers, 1)
  m.assertAAHasKey(m.observable.observers._fieldName, "testFunction")

  m.observable.notify("_fieldName")
  m.assertEqual(contextNode.bindingMessage.contextId, "1")
  m.assertEqual(contextNode.bindingMessage.fieldName, "_fieldName")
  m.assertArrayCount(m.observable.pendingObservers, 0)
end function

'@Test 2 fields, 1 observer, context, notifications
function BOT_notify_oneObserver_twoFields_notificationsEnabled_context()
  m.observable["_fieldName"] = "#value"
  m.observable["_fieldName2"] = "#value2"
  contextNode = BOT_createContextNode()
  m.observable.setContext("1", contextNode)
  m.observable.isBindingNotificationEnabled = true
  m.observable.observeField("_fieldName", "testFunction", {isSettingInitialValue:false})

  m.assertArrayCount(m.observable.observers, 1)
  m.assertAAHasKey(m.observable.observers._fieldName, "testFunction")

  m.observable.notify("_fieldName")

  m.assertEqual(contextNode.bindingMessage.contextId, "1")
  m.assertEqual(contextNode.bindingMessage.fieldName, "_fieldName")
  m.assertArrayCount(m.observable.pendingObservers, 0)
end function

'@Test 2 fields, 2 observers, context, notifications
function BOT_notify_twoObservers_twoFields_notificationsEnabled_context()
  m.observable["_fieldName"] = "#value"
  m.observable["_fieldName2"] = "#value2"
  contextNode = BOT_createContextNode()
  m.observable.setContext("1", contextNode)
  m.observable.isBindingNotificationEnabled = true
  m.observable.observeField("_fieldName", "testFunction", {isSettingInitialValue:false})
  m.observable.observeField("_fieldName", "testFunction2", {isSettingInitialValue:false})

  m.assertArrayCount(m.observable.observers, 1)
  m.assertAAHasKey(m.observable.observers._fieldName, "testFunction")

  m.observable.notify("_fieldName")

  m.assertEqual(contextNode.bindingMessage.contextId, "1")
  m.assertEqual(contextNode.bindingMessage.fieldName, "_fieldName")
  m.assertArrayCount(m.observable.pendingObservers, 0)
end function

'@Test 2 fields, 2 observers, context, notifications
function BOT_notify_twoObservers_twoFields_notificationsEnabled_context_otherField()
  m.observable["_fieldName"] = "#value"
  m.observable["_fieldName2"] = "#value2"
  contextNode = BOT_createContextNode()
  m.observable.setContext("1", contextNode)
  m.observable.isBindingNotificationEnabled = true
  m.observable.observeField("_fieldName", "testFunction", {isSettingInitialValue:false})
  m.observable.observeField("_fieldName", "testFunction2", {isSettingInitialValue:false})

  m.assertArrayCount(m.observable.observers, 1)
  m.assertAAHasKey(m.observable.observers._fieldName, "testFunction")

  m.observable.notify("_fieldName")
  m.observable.notify("_fieldName2")

  m.assertEqual(contextNode.bindingMessage.contextId, "1")
  m.assertEqual(contextNode.bindingMessage.fieldName, "_fieldName2")
  m.assertArrayCount(m.observable.pendingObservers, 0)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests bindField
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test invalid inputs
'@Params[invalid, invalid, invalid]
'@Params["", invalid, invalid]
'@Params["", invalid, ""]
'@Params["", "#RBSNode", ""]
'@Params["_fieldName", "#RBSNode", ""]
'@Params["", "#RBSNode", "target_field"]
function BOT_bindField_invalid(fieldName, targetNode, targetField)
  m.assertFalse(m.observable.bindField(fieldName, targetNode, targetField))
  m.assertEmpty(m.observable.bindings)
end function


'@Test - no context set
function BOT_bindField_noContext()
  n1 = createObject("roSGNode", "ContentNode")
  n1.id ="n1"
  m.assertFalse(m.observable.unbindField("fieldName", n1, "targetField"))
end function

'@Test valid inputs - no initial value
'@Params["_fieldName", "#RBSNode", "_targetField"]
function BOT_bindField_valid(fieldName, targetNode, targetField)
  contextNode = BOT_createContextNode()
  m.observable.setContext("1", contextNode)
  m.observable[fieldName] = "value"
  targetNode.id ="nodeId"

  m.assertTrue(m.observable.bindField(fieldName, targetNode, targetField, {isSettingInitialValue:false}))

  bindings = m.observable.bindings[fieldName]
  m.assertAAHasKey(bindings, "1_nodeId__fieldName__targetField")
  fieldBinding = bindings["1_nodeId__fieldName__targetField"]
  m.assertAAContainsSubset(fieldBinding, {
    fieldName: "_fieldName"
    node: targetNode
    targetField: "_targetField"
  })

end function

'@Test 2 fields
function BOT_bindField_valid_2fields()
  contextNode = BOT_createContextNode()
  m.observable.setContext("1", contextNode)
  m.observable["f1"] = "v1"
  n1 = createObject("roSGNode", "ContentNode")
  n1.id ="n1"
  m.observable["f2"] = "v2"
  n2 = createObject("roSGNode", "ContentNode")
  n2.id ="n2"

  m.assertTrue(m.observable.bindField("f1", n1, "t1", {isSettingInitialValue:false}))
  m.assertTrue(m.observable.bindField("f2", n2, "t2", {isSettingInitialValue:false}))

  bindings = m.observable.bindings["f1"]
  m.assertAAHasKey(bindings, "1_n1_f1_t1")
  fieldBinding = bindings["1_n1_f1_t1"]
  m.assertAAContainsSubset(fieldBinding, {
    fieldName: "f1"
    node: n1
    targetField: "t1"
  })

  bindings = m.observable.bindings["f2"]
  m.assertAAHasKey(bindings, "1_n2_f2_t2")
  fieldBinding = bindings["1_n2_f2_t2"]
  m.assertAAContainsSubset(fieldBinding, {
    fieldName: "f2"
    node: n2
    targetField: "t2"
  })

end function

'@Test 1 fields 2 node targets
function BOT_bindField_valid_1fields_2bindings()
  contextNode = BOT_createContextNode()
  m.observable.setContext("1", contextNode)
  m.observable["f1"] = "v1"
  n1 = createObject("roSGNode", "ContentNode")
  n1.id ="n1"
  m.observable["f2"] = "v2"
  n2 = createObject("roSGNode", "ContentNode")
  n2.id ="n2"

  m.assertTrue(m.observable.bindField("f2", n1, "t1", {isSettingInitialValue:false}))
  m.assertTrue(m.observable.bindField("f2", n2, "t2", {isSettingInitialValue:false}))

  m.assertAANotHasKey(m.observable.bindings, "f1")

  bindings = m.observable.bindings["f2"]
  m.assertAAHasKey(bindings, "1_n2_f2_t2")
  fieldBinding = bindings["1_n1_f1_t1"]
  m.assertAAContainsSubset(fieldBinding, {
    fieldName: "f2"
    node: n1
    targetField: "t1"
  })

  fieldBinding = bindings["1_n2_f2_t2"]
  m.assertAAContainsSubset(fieldBinding, {
    fieldName: "f2"
    node: n2
    targetField: "t2"
  })

end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests unbindField
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test invalid inputs
'@Params[invalid, invalid, invalid]
'@Params["", invalid, invalid]
'@Params["", invalid, ""]
'@Params["", "#RBSNode", ""]
'@Params["_fieldName", "#RBSNode", ""]
'@Params["", "#RBSNode", "target_field"]
function BOT_unbindField_invalid(fieldName, targetNode, targetField)
  m.assertFalse(m.observable.unbindField(fieldName, targetNode, targetField))
end function

'@Test - no context set
function BOT_unbindField_noContext()
  n1 = createObject("roSGNode", "ContentNode")
  n1.id ="n1"
  m.assertFalse(m.observable.unbindField("fieldName", n1, "targetField"))
end function

'@Test 1 fields 2 node targets
function BOT_unbindField_valid_1fields_2bindings()
  'setup 2 bindings
  contextNode = BOT_createContextNode()
  m.observable.setContext("1", contextNode)
  m.observable["f1"] = "v1"
  n1 = createObject("roSGNode", "ContentNode")
  n1.id ="n1"
  m.observable["f2"] = "v2"
  n2 = createObject("roSGNode", "ContentNode")
  n2.id ="n2"

  m.assertTrue(m.observable.bindField("f2", n1, "t1", {isSettingInitialValue:false}))
  m.assertTrue(m.observable.bindField("f2", n2, "t2", {isSettingInitialValue:false}))

  m.assertAANotHasKey(m.observable.bindings, "f1")

  bindings = m.observable.bindings["f2"]
  m.assertAAHasKey(bindings, "1_n1_f2_t1")
  m.assertAAHasKey(bindings, "1_n2_f2_t2")
  fieldBinding = bindings["1_n1_f1_t1"]
  m.assertAAContainsSubset(fieldBinding, {
    fieldName: "f2"
    node: n1
    targetField: "t1"
  })

  fieldBinding = bindings["1_n2_f2_t2"]
  m.assertAAContainsSubset(fieldBinding, {
    fieldName: "f2"
    node: n2
    targetField: "t2"
  })

  'unbind t2
  m.assertTrue(m.observable.unbindField("f2", n2, "t2"))

  m.assertAANotHasKey(m.observable.bindings, "f1")
  m.assertAAHasKey(m.observable.bindings, "f2")

  bindings = m.observable.bindings["f2"]
  m.assertAAHasKey(bindings, "1_n1_f2_t1")
  m.assertAANotHasKey(bindings, "1_n2_f2_t2")
  fieldBinding = bindings["1_n1_f1_t1"]
  m.assertAAContainsSubset(fieldBinding, {
    fieldName: "f2"
    node: n1
    targetField: "t1"
  })

  'unbind t1
  m.assertTrue(m.observable.unbindField("f2", n1, "t1"))
  m.assertAANotHasKey(m.observable.bindings, "f1")
  m.assertAANotHasKey(m.observable.bindings, "f2")
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests notifyBinding
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test no matching field
function BOT_notifyBinding_noField()
  m.assertFalse(m.observable.notifyBinding("noField"))
end function

'@Test not enabled
function BOT_notifyBinding_notEnabled()
  contextNode = BOT_createContextNode()
  m.observable.setContext("1", contextNode)
  m.observable["f1"] = "v1"
  n1 = createObject("roSGNode", "ContentNode")
  n1.id ="n1"
  m.observable.isBindingNotificationEnabled = false
  m.assertEmpty(m.observable.pendingBindings)
  m.assertTrue(m.observable.bindField("f1", n1, "t1", {isSettingInitialValue:false}))

  m.assertTrue(m.observable.notifyBinding("f1"))
  m.assertNotEmpty(m.observable.pendingBindings)
end function

'@Test enabled
function BOT_notifyBinding_enabled()
  contextNode = BOT_createContextNode()
  m.observable.setContext("1", contextNode)
  m.observable["f1"] = "v1"
  n1 = createObject("roSGNode", "ContentNode")
  n1.id ="n1"
  m.observable.isBindingNotificationEnabled = true
  m.assertEmpty(m.observable.pendingBindings)
  m.assertTrue(m.observable.bindField("f1", n1, "title", {isSettingInitialValue:false}))

  m.assertTrue(m.observable.notifyBinding("f1"))
  m.assertEmpty(m.observable.pendingBindings)
  m.assertEqual(n1.title, "v1")
end function

'@Test enabled mulitple bindings
function BOT_notifyBinding_enabled_multiple()
  contextNode = BOT_createContextNode()
  m.observable.setContext("1", contextNode)
  m.observable["f1"] = "v1"
  n1 = createObject("roSGNode", "ContentNode")
  n1.id ="n1"
  n2 = createObject("roSGNode", "ContentNode")
  n2.id ="n2"
  m.observable.isBindingNotificationEnabled = true
  m.assertEmpty(m.observable.pendingBindings)
  m.assertTrue(m.observable.bindField("f1", n1, "title", {isSettingInitialValue:false}))
  m.assertTrue(m.observable.bindField("f1", n2, "title", {isSettingInitialValue:false}))

  m.assertTrue(m.observable.notifyBinding("f1"))
  m.assertEmpty(m.observable.pendingBindings)
  m.assertEqual(n1.title, "v1")
  m.assertEqual(n2.title, "v1")
end function

'@Test enabled mulitple bindings specfific key
function BOT_notifyBinding_enabled_multiple_specificKey()
  contextNode = BOT_createContextNode()
  m.observable.setContext("1", contextNode)
  m.observable["f1"] = "v1"
  n1 = createObject("roSGNode", "ContentNode")
  n1.id ="n1"
  n2 = createObject("roSGNode", "ContentNode")
  n2.id ="n2"
  m.observable.isBindingNotificationEnabled = true
  m.assertEmpty(m.observable.pendingBindings)
  m.assertTrue(m.observable.bindField("f1", n1, "title", {isSettingInitialValue:false}))
  m.assertTrue(m.observable.bindField("f1", n2, "title", {isSettingInitialValue:false}))

  m.assertTrue(m.observable.notifyBinding("f1", "1_n2_f1_title"))
  m.assertEmpty(m.observable.pendingBindings)
  m.assertEmpty(n1.title)
  m.assertEqual(n2.title, "v1")
end function

'@Test enabled mulitple bindings specfific key - not found
function BOT_notifyBinding_enabled_multiple_specificKey_notThere()
  contextNode = BOT_createContextNode()
  m.observable.setContext("1", contextNode)
  m.observable["f1"] = "v1"
  n1 = createObject("roSGNode", "ContentNode")
  n1.id ="n1"
  n2 = createObject("roSGNode", "ContentNode")
  n2.id ="n2"
  m.observable.isBindingNotificationEnabled = true
  m.assertEmpty(m.observable.pendingBindings)
  m.assertTrue(m.observable.bindField("f1", n1, "title", {isSettingInitialValue:false}))
  m.assertTrue(m.observable.bindField("f1", n2, "title", {isSettingInitialValue:false}))

  m.assertTrue(m.observable.notifyBinding("f1", "1_n3_f1_title"))
  m.assertEmpty(m.observable.pendingBindings)
  m.assertEmpty(n1.title)
  m.assertEmpty(n2.title)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests unbindAllFields
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test
function BOT_unbindAllFields()
  contextNode = BOT_createContextNode()
  m.observable.setContext("1", contextNode)
  'setup 2 bindings
  n1 = createObject("roSGNode", "ContentNode")
  n1.id ="n1"
  m.observable["f2"] = "v2"

  m.assertTrue(m.observable.bindField("f2", n1, "t1", {isSettingInitialValue:false}))

  m.assertNotEmpty(m.observable.bindings)
  m.observable.unbindAllFields()
  m.assertEmpty(m.observable.bindings)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Utils
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function BOT_createContextNode()
  observableContext = createObject("roSGNode", "ContentNode")
  observableContext.addField("bindingMessage", "assocarray", true)
  return observableContext
end function