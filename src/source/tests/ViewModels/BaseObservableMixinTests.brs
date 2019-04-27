'@TestSuite [BOTM] OMixin Tests

'@BeforeEach
function BOTM_BeforeEach()
  BOM_cleanup()
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests BOM_cleanup
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test
function BOMT_cleanup()
  m.node._observableContextId = 0
  m.node._observables = {}
  m.node._observableFunctionPointers = {}
  m.node._observableNodeBindings = {}
  m.node._observableContext = createObject("roSGNode", "ContentNode")
  m.node._observableContext.addField("bindingMessage", "assocarray", true)
  m.node._observableContext.observeFieldScoped("bindingMessage", "BOM_BindingCallback")
  BOM_cleanup()
  m.assertInvalid(m.node._observableContextId)
  m.assertInvalid(m.node._observables)
  m.assertInvalid(m.node._observableFunctionPointers)
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
function BOTM_checkValidInputs(fieldName, targetNode, targetField, expected)
  value = BOM_checkValidInputs(fieldName, targetNode, targetField)

  m.assertEqual(value, expected)
end function

'@Test invalid node ids
'@Params[""]
'@Params["   "]
function BOTM_checkValidInputs_invalid_nodeIds(nodeId)
  targetNode = createObject("roSGNode", "ContentNode")
  targetNode.id = nodeId

  value = BOM_checkValidInputs("fieldName", targetNode, "targetField")

  m.assertFalse(value)
end function

'@Test valid node ids
'@Params["valid1"]
'@Params["valid2"]
function BOTM_checkValidInputs_valid_nodeIds(nodeId)
  targetNode = createObject("roSGNode", "ContentNode")
  targetNode.id = nodeId

  value = BOM_checkValidInputs("fieldName", targetNode, "targetField")

  m.assertTrue(value)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests BOM_registerObservable
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test invalid observables
'@Params[invalid]
'@Params[[]]
'@Params["#RBSNode"]
'@Params[{}]
'@Params["invalid"]
'@Params[25]
function BOMT_registerObservable_invalid(observable)
  m.assertFalse(BOM_registerObservable(observable))
end function

'@Test register one
function BOMT_registerObservable_one()
  o1 = BaseObservable()
  o1.id = "o1"
  setContextMock = m.expectOnce(o1, "setContext", ["0", m.ignoreValue])
  m.assertTrue(BOM_registerObservable(o1))
  m.assertEqual(setContextMock.invokedArgs[1], m.node._observableContext)
  m.assertEqual(m.node._observables["0"].id, "o1")
  m.assertEmpty(m.node._observableFunctionPointers)
  m.assertEmpty(m.node._observableNodeBindings)
end function

'@Test register one - multiple times
function BOMT_registerObservable_one_multipleTimes()
  o1 = BaseObservable()
  o1.id = "o1"
  m.assertTrue(BOM_registerObservable(o1))
  m.assertTrue(BOM_registerObservable(o1))
  m.assertTrue(BOM_registerObservable(o1))

  m.assertEqual(o1.contextId, "0")
  m.assertEqual(o1.contextNode, m.node._observableContext)
  m.assertEqual(m.node._observables["0"].id, "o1")
  m.assertEmpty(m.node._observableFunctionPointers)
  m.assertEmpty(m.node._observableNodeBindings)
end function

'@Test register multiple
function BOMT_registerObservable_multiple()
  o1 = BaseObservable()
  o1.id = "o1"
  setContextMock1 = m.expectOnce(o1, "setContext", ["0", m.ignoreValue])
  o2 = BaseObservable()
  o2.id = "o2"
  setContextMock2 = m.expectOnce(o2, "setContext", ["1", m.ignoreValue])
  o3 = BaseObservable()
  o3.id = "o3"
  setContextMock3 = m.expectOnce(o3, "setContext", ["2", m.ignoreValue])
  m.assertTrue(BOM_registerObservable(o1))
  m.assertTrue(BOM_registerObservable(o2))
  m.assertTrue(BOM_registerObservable(o3))
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
'@It tests BOM_unregisterObservable
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test invalid observables
'@Params[invalid]
'@Params[[]]
'@Params["#RBSNode"]
'@Params[{}]
'@Params["invalid"]
'@Params[25]
function BOMT_unregisterObservable(observable)
  m.assertFalse(BOM_unregisterObservable(observable))
end function
