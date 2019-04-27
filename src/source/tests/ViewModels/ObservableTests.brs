'@SGNode ObservableTests
'@TestSuite [OT] Observable Tests
'Integration testing for our mixin and BaseObservables

function init()
  registerLogger("ObservableTests")
end function

'@BeforeEach
function OT_BeforeEach()
  logInfo("beforeEach")
  m.node.delete("_observerCallbackValue1")
  m.node.delete("_observerCallbackValue2")
  OM_cleanup()
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests OT_ObserverCallback
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test not registered
function OT_ObserverCallback_notRegistered()
  event = {}
  m.expectNone(event, "getData")

  OM_ObserverCallback(event)

  m.assertInvalid(m.node._observerCallbackValue1)
  m.assertInvalid(m.node._observerCallbackValue2)
end function

'@Test observer is registered
function OT_ObserverCallback_registered()
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = false
  OM_registerObservable(o1)
  OM_ObserveField(o1, "f1", OT_callbackTarget1)

  o1.setField("f1", true)

  m.assertTrue(m.node._observerCallbackValue1)
  m.assertInvalid(m.node._observerCallbackValue2)
end function

'@Test multiple fields 
function OT_ObserverCallback_multipleFields()
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = false
  o1.f2 = false
  o1.f3 = false

  OM_registerObservable(o1)
  m.assertInvalid(m.node._observerCallbackValue1)
  m.assertInvalid(m.node._observerCallbackValue2)

  OM_ObserveField(o1, "f1", OT_callbackTarget1)
  OM_ObserveField(o1, "f2", OT_callbackTarget2)
  
  m.assertFalse(m.node._observerCallbackValue1, "observeField should set value by default")
  m.assertFalse(m.node._observerCallbackValue2, "observeField should set value by default")

  o1.setField("f1", true)
  m.assertTrue(m.node._observerCallbackValue1)
  m.assertFalse(m.node._observerCallbackValue2)

  o1.setField("f2", true)
  m.assertTrue(m.node._observerCallbackValue1)
  m.assertTrue(m.node._observerCallbackValue2)

  o1.setField("f2", false)
  m.assertTrue(m.node._observerCallbackValue1)
  m.assertFalse(m.node._observerCallbackValue2)

  o1.setField("f1", false)
  m.assertFalse(m.node._observerCallbackValue1)
  m.assertFalse(m.node._observerCallbackValue2)

  o1.setField("f3", true)

  m.assertFalse(m.node._observerCallbackValue1)
  m.assertFalse(m.node._observerCallbackValue2)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests OM_BindingCallback
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test not registered
function OT_BindingCallback_notRegistered()
  event = {}
  m.expectNone(event, "getData")

  OM_BindingCallback(event)
end function

'@Test no bound observable fields
function OT_BindingCallback_noBoundFields()
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = false
  OM_registerObservable(o1)

  event = {}
  m.expectOnce(event, "getData")
  m.expectOnce(event, "getNode", invalid, "n1")
  m.expectOnce(event, "getField", invalid, "title")

  OM_BindingCallback(event)
end function

'@Test one field
function OT_BindingCallback_oneField()
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = ""
  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"
  OM_registerObservable(o1)
  OM_bindNodeField(n1, "title", o1, "f1")

  n1.title = "changed"

  m.assertEqual(o1.f1, "changed")
end function

'@Test multiple different fields
function OT_BindingCallback_multipleFields()
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = ""
  o1.f2 = ""
  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"
  OM_registerObservable(o1)
  OM_bindNodeField(n1, "title", o1, "f1")

  n1.title = "changed"

  m.assertEqual(o1.f1, "changed")
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ callback functions for observer testing
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function OT_callbackTarget1(value)
  m._observerCallbackValue1 = value
end function

function OT_callbackTarget2(value)
  m._observerCallbackValue2 = value
end function