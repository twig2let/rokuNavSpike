'@TestSuite [BOT] BaseObservable Tests

'@Setup
function BOT_SetUp()
  m.observable = BaseObservable()
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
'@Params["testField", {"someField":"value"}]
'@Params["testField2", invalid]
'@Params["testField2", "stringValue"]
'@Params["testField2", 22]
'@Params["testField2", 22.5]
'@Params["testField2", {}]
'@Params["testField2", {"someField":"value"}]
function BOT_setField(fieldName, value)
  m.expectOnce(m.observable, "notify", [fieldName, value])
  m.expectOnce(m.observable, "notifyBinding", [fieldName, value])

  m.observable.setField(fieldName, value)

  m.AssertEqual(m.observable[fieldName], value)
end function

'@Test set multiple times
function BOT_setField_multiple()
  m.expectOnce(m.observable, "notify", ["fieldName", 1])
  m.expectOnce(m.observable, "notifyBinding", ["fieldName", 1])
  m.expectOnce(m.observable, "notify", ["fieldName", 2])
  m.expectOnce(m.observable, "notifyBinding", ["fieldName", 2])
  m.expectOnce(m.observable, "notify", ["fieldName", 3])
  m.expectOnce(m.observable, "notifyBinding", ["fieldName", 3])

  m.observable.setField("fieldName", 1)
  m.observable.setField("fieldName", 2)
  m.observable.setField("fieldName", 3)

  m.AssertEqual(m.observable.fieldName, 3)
end function

'@Test uninitialized value
function BOT_setField_illegalFieldName()
  m.expectOnce(m.observable, "notify", ["testValue", invalid])
  m.expectOnce(m.observable, "notifyBinding", ["testValue", invalid])

  m.observable.setField("testValue", someUndefinedVar)

  m.AssertEqual(m.observable.testValue, invalid)
end function

'@Test setField for node
function BOT_setField_node()
  value = createObject("roSGNode", "ContentNode")

  m.expectOnce(m.observable, "notify", ["testValue", value])
  m.expectOnce(m.observable, "notifyBinding", ["testValue", value])

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

  value = m.observable.checkValidInputs("fieldName", targetNode, "targetField")

  m.assertFalse(value)
end function

'@Test valid node ids
'@Params["valid1"]
'@Params["valid2"]
function BOT_checkValidInputs_valid_nodeIds(nodeId)
  targetNode = createObject("roSGNode", "ContentNode")
  targetNode.id = nodeId

  value = m.observable.checkValidInputs("fieldName", targetNode, "targetField")

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
  m.expectOnce(m.observable, "notify", [field1Name, value1])
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
  m.expectOnce(m.observable, "notify", [field3Name, value3])
  m.expectOnce(m.observable, "notify", [field1Name, value1])
  m.expectOnce(m.observable, "notify", [field2Name, value2])
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
  m.expectOnce(m.observable, "notifyBinding", [field1Name, value1])
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
  m.expectOnce(m.observable, "notifyBinding", [field3Name, value3])
  m.expectOnce(m.observable, "notifyBinding", [field1Name, value1])
  m.expectOnce(m.observable, "notifyBinding", [field2Name, value2])
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
