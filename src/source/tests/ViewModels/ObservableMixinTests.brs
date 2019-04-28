'@TestSuite [OMT] ObservableMixin Tests

'@BeforeEach
function OMT_BeforeEach()
  m.node.delete("_observerCallbackValue1")
  m.node.delete("_observerCallbackValue2")
  OM_cleanup()
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests OM_cleanup
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test
function OMT_cleanup()
  m.node._observableContextId = 0
  m.node._observables = {}
  m.node._observableFunctionPointers = {}
  m.node._observableFunctionPointerCounts = {}
  m.node._observableNodeBindings = {}
  m.node._observableContext = createObject("roSGNode", "ContentNode")
  m.node._observableContext.addField("bindingMessage", "assocarray", true)
  m.node._observableContext.observeFieldScoped("bindingMessage", "OM_BindingCallback")
  OM_cleanup()
  m.assertInvalid(m.node._observableContextId)
  m.assertInvalid(m.node._observables)
  m.assertInvalid(m.node._observableFunctionPointers)
  m.assertInvalid(m.node._observableFunctionPointerCounts)
  m.assertInvalid(m.node._observableNodeBindings)
  m.assertInvalid(m.node._observableContext)
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
function OMT_checkValidInputs(fieldName, targetNode, targetField, expected)
  value = OM_checkValidInputs(fieldName, targetNode, targetField)

  m.assertEqual(value, expected)
end function

'@Test invalid node ids
'@Params[""]
'@Params["   "]
function OMT_checkValidInputs_invalid_nodeIds(nodeId)
  targetNode = createObject("roSGNode", "ContentNode")
  targetNode.id = nodeId

  value = OM_checkValidInputs("fieldName", targetNode, "targetField")

  m.assertFalse(value)
end function

'@Test valid node ids
'@Params["valid1"]
'@Params["valid2"]
function OMT_checkValidInputs_valid_nodeIds(nodeId)
  targetNode = createObject("roSGNode", "ContentNode")
  targetNode.id = nodeId

  value = OM_checkValidInputs("fieldName", targetNode, "targetField")

  m.assertTrue(value)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests OM_registerObservable
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test invalid observables
'@Params[invalid]
'@Params[[]]
'@Params["#RBSNode"]
'@Params[{}]
'@Params["invalid"]
'@Params[25]
function OMT_registerObservable_invalid(observable)
  m.assertFalse(OM_registerObservable(observable))
end function

'@Test register one
function OMT_registerObservable_one()
  o1 = BaseObservable()
  o1.id = "o1"
  setContextMock = m.expectOnce(o1, "setContext", ["0", m.ignoreValue])
  m.assertTrue(OM_registerObservable(o1))
  m.assertEqual(setContextMock.invokedArgs[1], m.node._observableContext)
  m.assertEqual(m.node._observables["0"].id, "o1")
  m.assertEmpty(m.node._observableFunctionPointers)
  m.assertEmpty(m.node._observableNodeBindings)
end function

'@Test register one - multiple times
function OMT_registerObservable_one_multipleTimes()
  o1 = BaseObservable()
  o1.id = "o1"
  m.assertTrue(OM_registerObservable(o1))
  m.assertTrue(OM_registerObservable(o1))
  m.assertTrue(OM_registerObservable(o1))

  m.assertEqual(o1.contextId, "0")
  m.assertEqual(o1.contextNode, m.node._observableContext)
  m.assertEqual(m.node._observables["0"].id, "o1")
  m.assertEmpty(m.node._observableFunctionPointers)
  m.assertEmpty(m.node._observableNodeBindings)
end function

'@Test register multiple
function OMT_registerObservable_multiple()
  o1 = BaseObservable()
  o1.id = "o1"
  setContextMock1 = m.expectOnce(o1, "setContext", ["0", m.ignoreValue])
  o2 = BaseObservable()
  o2.id = "o2"
  setContextMock2 = m.expectOnce(o2, "setContext", ["1", m.ignoreValue])
  o3 = BaseObservable()
  o3.id = "o3"
  setContextMock3 = m.expectOnce(o3, "setContext", ["2", m.ignoreValue])
  m.assertTrue(OM_registerObservable(o1))
  m.assertTrue(OM_registerObservable(o2))
  m.assertTrue(OM_registerObservable(o3))
  m.assertEqual(setContextMock1.invokedArgs[1], m.node._observableContext)
  m.assertEqual(setContextMock2.invokedArgs[1], m.node._observableContext)
  m.assertEqual(setContextMock3.invokedArgs[1], m.node._observableContext)
  m.assertEqual(m.node._observables["0"].id, "o1")
  m.assertEqual(m.node._observables["1"].id, "o2")
  m.assertEqual(m.node._observables["2"].id, "o3")
  m.assertEmpty(m.node._observableFunctionPointers)
  m.assertEmpty(m.node._observableNodeBindings)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests OM_unregisterObservable
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test invalid observables
'@Params[invalid]
'@Params[[]]
'@Params["#RBSNode"]
'@Params[{}]
'@Params["invalid"]
'@Params[25]
function OMT_unregisterObservable(observable)
  m.assertFalse(OM_unregisterObservable(observable))
end function

'@Test multiple
function OMT_unregisterObservable_multiple()
  o1 = BaseObservable()
  o1.id = "o1"
  o2 = BaseObservable()
  o2.id = "o2"
  o3 = BaseObservable()
  o3.id = "o3"
  m.assertTrue(OM_registerObservable(o1))
  m.assertTrue(OM_registerObservable(o2))
  m.assertTrue(OM_registerObservable(o3))
  m.assertEqual(m.node._observables["0"].id, "o1")
  m.assertEqual(m.node._observables["1"].id, "o2")
  m.assertEqual(m.node._observables["2"].id, "o3")
  m.assertEmpty(m.node._observableFunctionPointers)
  m.assertEmpty(m.node._observableNodeBindings)

  m.expectOnce(o1, "setContext", [invalid, invalid])
  m.expectOnce(o2, "setContext", [invalid, invalid])
  m.expectOnce(o3, "setContext", [invalid, invalid])

  m.assertTrue(OM_unregisterObservable(o1))
  m.assertInvalid(m.node._observables["0"])
  m.assertEqual(m.node._observables["1"].id, "o2")
  m.assertEqual(m.node._observables["2"].id, "o3")

  m.assertTrue(OM_unregisterObservable(o2))
  m.assertInvalid(m.node._observables["0"])
  m.assertInvalid(m.node._observables["1"])
  m.assertEqual(m.node._observables["2"].id, "o3")

  m.assertTrue(OM_unregisterObservable(o3))

  m.assertInvalid(m.node._observableContextId)
  m.assertInvalid(m.node._observables)
  m.assertInvalid(m.node._observableFunctionPointers)
  m.assertInvalid(m.node._observableNodeBindings)
  m.assertInvalid(m.node._observableContext)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests OM_isRegistered
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test invalid observables
'@Params[invalid]
'@Params[[]]
'@Params["#RBSNode"]
'@Params[{}]
'@Params["invalid"]
'@Params[25]
function OMT_isRegistered_invalid(observable)
  m.assertFalse(OM_isRegistered(observable))
end function

'@Test unregistered observable
function OMT_isRegistered_unregistered()
  o1 = BaseObservable()
  o1.id = "o1"
  m.assertFalse(OM_isRegistered(observable))
end function

'@Test registered observable
function OMT_isRegistered_registered()
  o1 = BaseObservable()
  o1.id = "o1"
  m.assertTrue(OM_registerObservable(o1))
  m.assertTrue(OM_isRegistered(o1))
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests OM_ObserverCallback
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test not registered
function OMT_ObserverCallback_notRegistered()
  event = {}
  m.expectNone(event, "getData")

  OM_ObserverCallback(event)

  m.assertInvalid(m.node._observerCallbackValue1)
  m.assertInvalid(m.node._observerCallbackValue2)
end function

'@Test observer is registered
function OMT_ObserverCallback_registered()

  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = true
  m.assertTrue(OM_registerObservable(o1))
  OM_ObserveField(o1, "f1", OMT_callbackTarget1)

  'we need to manually call the OM_ObserverCallback - this test is not in a node scope, so
  'the observer callback will not fire
  event = {}
  m.expectOnce(event, "getData", invalid, {"contextId":o1.contextId, "fieldName":"f1"})
  OM_ObserverCallback(event)
  m.assertTrue(m.node._observerCallbackValue1)
  m.assertInvalid(m.node._observerCallbackValue2)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests OM_BindingCallback
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test not registered
function OMT_BindingCallback_notRegistered()
  event = {}
  m.expectNone(event, "getData")

  m.assertInvalid(m.node._observerCallbackValue1)
  m.assertInvalid(m.node._observerCallbackValue2)
end function

function OMT_BindingCallback_registered()
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = true
  m.assertTrue(OM_registerObservable(o1))
  OM_ObserveField(o1, "f1", OMT_callbackTarget1)

  'we need to manually call the OM_ObserverCallback - this test is not in a node scope, so
  'the observer callback will not fire
  event = {}
  m.expectOnce(event, "getData", invalid, {"contextId":o1.contextId, "fieldName":"f1"})
  OM_BindingCallback(event)
  m.assertTrue(m.node._observerCallbackValue1)
  m.assertInvalid(m.node._observerCallbackValue2)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests OM_observeField
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test registered observable
function OMT_observeField_unregistered()
  o1 = BaseObservable()
  o1.id = "o1"
  m.expectNone(o1, "unobserveField")
  
  m.assertFalse(OM_observeField(invalid, "fieldName", OMT_callbackTarget1))
end function

'@Test invalid observables
'@Params[invalid]
'@Params[[]]
'@Params["#RBSNode"]
'@Params[{}]
'@Params["invalid"]
'@Params[25]
function OMT_observeField_noFunction(funcValue)
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = true
  m.expectNone(o1, "unobserveField")
  OM_registerObservable(o1)
  m.assertFalse(OM_observeField(o1, "f1", funcValue))
end function

'@Test valid observable
function OMT_observeField_valid()
  o1 = BaseObservable()
  o1.id = "o1"
  m.expectOnce(o1, "observeField", ["fieldName", "omt_callbacktarget1", true], true)
  
  m.assertTrue(OM_observeField(o1, "fieldName", OMT_callbackTarget1))

  m.assertEqual(m.node._observableFunctionPointerCounts["OMT_callbackTarget1"], 1)
  m.assertEqual(m.node._observableFunctionPointers["OMT_callbackTarget1"], OMT_callbackTarget1)
end function

'@Test multiple function different fields
function OMT_observeField_valid_sameFunctionMultipleFields()
  o1 = BaseObservable()
  o1.id = "o1"
  m.expectOnce(o1, "observeField", ["f1", "omt_callbacktarget1", true], true)
  m.expectOnce(o1, "observeField", ["f2", "omt_callbacktarget1", true], true)
  m.expectOnce(o1, "observeField", ["f3", "omt_callbacktarget1", true], true)
  
  m.assertTrue(OM_observeField(o1, "f1", OMT_callbackTarget1))
  m.assertTrue(OM_observeField(o1, "f2", OMT_callbackTarget1))
  m.assertTrue(OM_observeField(o1, "f3", OMT_callbackTarget1))

  m.assertEqual(m.node._observableFunctionPointerCounts["OMT_callbackTarget1"], 3)
  m.assertEqual(m.node._observableFunctionPointers["OMT_callbackTarget1"], OMT_callbackTarget1)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests OM_unobserveField
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test unregistered observable
function OMT_unobserveField_unregistered()
  o1 = BaseObservable()
  o1.id = "o1"
  m.expectNone(o1, "unobserveField")
  
  m.assertFalse(OM_unobserveField(o1, "fieldName", OMT_callbackTarget1))
end function

'@Test invalid observables
'@Params[invalid]
'@Params[[]]
'@Params["#RBSNode"]
'@Params[{}]
'@Params["invalid"]
'@Params[25]
function OMT_unobserveField_noFunction(funcValue)
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = true
  m.expectNone(o1, "unobserveField")
  OM_registerObservable(o1)
  OM_unobserveField(o1, "f1", funcValue)
end function

'@Test valid observable
function OMT_unobserveField_valid()
  o1 = BaseObservable()
  o1.id = "o1"
  m.expectOnce(o1, "unobserveField", ["fieldName", "omt_callbacktarget1"], true)
  
  m.assertTrue(OM_observeField(o1, "fieldName", OMT_callbackTarget1))

  m.assertEqual(m.node._observableFunctionPointerCounts["OMT_callbackTarget1"], 1)
  m.assertEqual(m.node._observableFunctionPointers["OMT_callbackTarget1"], OMT_callbackTarget1)
  
  m.assertTrue(OM_unobserveField(o1, "fieldName", OMT_callbackTarget1))

  m.assertInvalid(m.node._observableFunctionPointerCounts["OMT_callbackTarget1"])
  m.assertInvalid(m.node._observableFunctionPointers["OMT_callbackTarget1"])
end function

'@Test multiple function different fields
function OMT_unobserveField_valid_sameFunctionMultipleFields()
  o1 = BaseObservable()
  o1.id = "o1"
  m.expectOnce(o1, "unobserveField", ["f1", "omt_callbacktarget1"], true)
  m.expectOnce(o1, "unobserveField", ["f2", "omt_callbacktarget1"], true)
  m.expectOnce(o1, "unobserveField", ["f3", "omt_callbacktarget1"], true)
  
  m.assertTrue(OM_observeField(o1, "f1", OMT_callbackTarget1))
  m.assertTrue(OM_observeField(o1, "f2", OMT_callbackTarget1))
  m.assertTrue(OM_observeField(o1, "f3", OMT_callbackTarget1))

  m.assertEqual(m.node._observableFunctionPointerCounts["OMT_callbackTarget1"], 3)
  m.assertEqual(m.node._observableFunctionPointers["OMT_callbackTarget1"], OMT_callbackTarget1)
  
  m.assertTrue(OM_unobserveField(o1, "f1", OMT_callbackTarget1))
  m.assertEqual(m.node._observableFunctionPointerCounts["OMT_callbackTarget1"], 2)
  m.assertEqual(m.node._observableFunctionPointers["OMT_callbackTarget1"], OMT_callbackTarget1)

  m.assertTrue(OM_unobserveField(o1, "f2", OMT_callbackTarget1))
  m.assertEqual(m.node._observableFunctionPointerCounts["OMT_callbackTarget1"], 1)
  m.assertEqual(m.node._observableFunctionPointers["OMT_callbackTarget1"], OMT_callbackTarget1)

  m.assertTrue(OM_unobserveField(o1, "f3", OMT_callbackTarget1))
  m.assertInvalid(m.node._observableFunctionPointerCounts["OMT_callbackTarget1"])
  m.assertInvalid(m.node._observableFunctionPointers["OMT_callbackTarget1"])
end function

'@Test multiple functions different fields
function OMT_unobserveField_valid_multiFunctionMultipleFields()
  o1 = BaseObservable()
  o1.id = "o1"
  m.expectOnce(o1, "unobserveField", ["f1", "omt_callbacktarget1"], true)
  m.expectOnce(o1, "unobserveField", ["f2", "omt_callbacktarget1"], true)
  m.expectOnce(o1, "unobserveField", ["f3", "omt_callbacktarget2"], true)
  
  m.assertTrue(OM_observeField(o1, "f1", OMT_callbackTarget1))
  m.assertTrue(OM_observeField(o1, "f2", OMT_callbackTarget1))
  m.assertTrue(OM_observeField(o1, "f3", OMT_callbackTarget2))

  m.assertEqual(m.node._observableFunctionPointerCounts["OMT_callbackTarget1"], 2)
  m.assertEqual(m.node._observableFunctionPointerCounts["OMT_callbackTarget2"], 1)
  m.assertEqual(m.node._observableFunctionPointers["OMT_callbackTarget1"], OMT_callbackTarget1)
  m.assertEqual(m.node._observableFunctionPointers["OMT_callbackTarget2"], OMT_callbackTarget2)
  
  m.assertTrue(OM_unobserveField(o1, "f1", OMT_callbackTarget1))
  m.assertEqual(m.node._observableFunctionPointerCounts["OMT_callbackTarget1"], 1)
  m.assertEqual(m.node._observableFunctionPointerCounts["OMT_callbackTarget2"], 1)
  m.assertEqual(m.node._observableFunctionPointers["OMT_callbackTarget1"], OMT_callbackTarget1)
  m.assertEqual(m.node._observableFunctionPointers["OMT_callbackTarget2"], OMT_callbackTarget2)

  m.assertTrue(OM_unobserveField(o1, "f2", OMT_callbackTarget1))
  m.assertInvalid(m.node._observableFunctionPointerCounts["OMT_callbackTarget1"])
  m.assertInvalid(m.node._observableFunctionPointers["OMT_callbackTarget1"])
  m.assertEqual(m.node._observableFunctionPointerCounts["OMT_callbackTarget2"], 1)
  m.assertEqual(m.node._observableFunctionPointers["OMT_callbackTarget2"], OMT_callbackTarget2)

  m.assertTrue(OM_unobserveField(o1, "f3", OMT_callbackTarget2))
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests OM_bindObservableField
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test unregistered observable
function OMT_bindObservableField_unregistered()
  m.assertFalse(OM_bindObservableField(invalid, "fieldName", invalid, invalid))
end function

'@Test unregistered observable
function OMT_bindObservableField_validObservable()
  o1 = BaseObservable()
  o1.id = "o1"
  n1 = createObject("roSGNode", "ContentNode") 
  n1.id = "n1"
  m.expectOnce(o1, "bindField", ["fieldName", n1, "targetField", true], true)

  m.assertTrue(OM_bindObservableField(o1, "fieldName", n1, "targetField"))
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests OM_unbindObservableField
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test unregistered observable
function OMT_unbindObservableField_unregistered()
  m.assertFalse(OM_unbindObservableField(invalid, "fieldName", invalid, invalid))
end function

'@Test unregistered observable
function OMT_unbindObservableField_validObservable()
  o1 = BaseObservable()
  o1.id = "o1"
  n1 = createObject("roSGNode", "ContentNode") 
  n1.id = "n1"
  m.expectOnce(o1, "unbindField", ["fieldName", n1, "targetField"], true)

  m.assertTrue(OM_unbindObservableField(o1, "fieldName", n1, "targetField"))
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ callback functions for observer testing
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function OMT_callbackTarget1(value)
  m._observerCallbackValue1 = value
end function

function OMT_callbackTarget2(value)
  m._observerCallbackValue2 = value
end function