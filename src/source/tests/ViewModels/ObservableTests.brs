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

'@Test no observer
function OT_ObserverCallback_noObserver()
  event = {}
  m.expectNone(event, "getData")

  OM_observerCallback(event)

  m.assertInvalid(m.node._observerCallbackValue1)
  m.assertInvalid(m.node._observerCallbackValue2)
end function

'@Test observer is set
function OT_ObserverCallback_registered()
  o1 = BaseObservable()
  o1.id = "o1"

  OM_observeField(o1, "f1", OT_callbackTarget1)

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

  m.assertInvalid(m.node._observerCallbackValue1)
  m.assertInvalid(m.node._observerCallbackValue2)

  OM_observeField(o1, "f1", OT_callbackTarget1)
  OM_observeField(o1, "f2", OT_callbackTarget2)

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

'@Test observer inverse boolean
function OT_ObserverCallback_inverseBoolean()
  properties = OM_createBindingProperties(true, OM_transform_invertBoolean)
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = false

  OM_observeField(o1, "f1", OT_callbackTarget1, properties)

  m.assertTrue(m.node._observerCallbackValue1)
  o1.setField("f1", true)

  m.assertFalse(m.node._observerCallbackValue1)
  m.assertInvalid(m.node._observerCallbackValue2)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests OM_bindingCallback
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test not registered
function OT_BindingCallback_notRegistered()
  event = {}
  m.expectNone(event, "getData")

  OM_bindingCallback(event)
end function

'@Test no bound observable fields
function OT_BindingCallback_noBoundFields_registerd()
  o1 = BaseObservable()
  o1.id = "o1"
  OM_registerObservable(o1)

  event = {}
  m.expectOnce(event, "getData")
  m.expectOnce(event, "getNode", invalid, "n1")
  m.expectOnce(event, "getField", invalid, "title")

  OM_bindingCallback(event)
end function

'@Test one field
function OT_BindingCallback_oneField()
  o1 = BaseObservable()
  o1.id = "o1"
  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"

  OM_bindNodeField(n1, "title", o1, "f1")

  n1.title = "changed"

  m.assertEqual(o1.f1, "changed")
end function

'@Test multiple different fields
function OT_BindingCallback_multipleFields()
  o1 = BaseObservable()
  o1.id = "o1"
  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"

  n1.title = "title"
  n1.description = "description"
  n1.SDPosterUrl = "SDPosterUrl"

  OM_bindNodeField(n1, "title", o1, "f1")
  OM_bindNodeField(n1, "description", o1, "f2")

  m.assertEqual(o1.f1, "title")
  m.assertEqual(o1.f2, "description")
  m.assertInvalid(o1.f3)

  n1.title = "titleChanged"
  n1.description = "descriptionChanged"
  n1.SDPosterUrl = "SDPosterUrlChanged"

  m.assertEqual(o1.f1, "titleChanged")
  m.assertEqual(o1.f2, "descriptionChanged")

  OM_bindNodeField(n1, "SDPosterUrl", o1, "f3")
  m.assertEqual(o1.f3, "SDPosterUrlChanged")

  n1.SDPosterUrl = "SDPosterUrlChanged2"
  m.assertEqual(o1.f3, "SDPosterUrlChanged2")

  n1.title = "titleChanged2"
  n1.title = "titleChanged3"
  m.assertEqual(o1.f1, "titleChanged3")
end function

'@Test multiple nodes
function OT_BindingCallback_multipleNodes()
  o1 = BaseObservable()
  o1.id = "o1"
  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"

  n1.title = "title"
  n1.description = "description"
  n1.SDPosterUrl = "SDPosterUrl"

  n2 = createObject("roSGNode", "ContentNode")
  n2.id = "n2"

  n2.title = "title"
  n2.description = "description"
  n2.SDPosterUrl = "SDPosterUrl"

  OM_bindNodeField(n1, "title", o1, "f1")
  OM_bindNodeField(n1, "description", o1, "f2")
  OM_bindNodeField(n1, "SDPosterUrl", o1, "f3")
  OM_bindNodeField(n2, "title", o1, "f1")
  OM_bindNodeField(n2, "description", o1, "f2")
  OM_bindNodeField(n2, "SDPosterUrl", o1, "f3")

  m.assertEqual(o1.f1, "title")
  m.assertEqual(o1.f2, "description")
  m.assertEqual(o1.f3, "SDPosterUrl")

  n1.title = "titleChanged_n1"
  n1.description = "descriptionChanged_n1"
  n1.SDPosterUrl = "SDPosterUrlChanged_n1"

  m.assertEqual(o1.f1, "titleChanged_n1")
  m.assertEqual(o1.f2, "descriptionChanged_n1")
  m.assertEqual(o1.f3, "SDPosterUrlChanged_n1")

  n2.title = "titleChanged_n2"
  n2.description = "descriptionChanged_n2"
  n2.SDPosterUrl = "SDPosterUrlChanged_n2"

  m.assertEqual(o1.f1, "titleChanged_n2")
  m.assertEqual(o1.f2, "descriptionChanged_n2")
  m.assertEqual(o1.f3, "SDPosterUrlChanged_n2")
end function

'@Test multiple observables
function OT_BindingCallback_multipleObservables()
  o1 = BaseObservable()
  o1.id = "o1"
  o2 = BaseObservable()
  o2.id = "o2"
  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"

  n1.title = "title"
  n1.description = "description"
  n1.SDPosterUrl = "SDPosterUrl"

  OM_bindNodeField(n1, "title", o1, "f1")
  OM_bindNodeField(n1, "description", o1, "f2")
  OM_bindNodeField(n1, "SDPosterUrl", o1, "f3")
  OM_bindNodeField(n1, "title", o2, "f1")
  OM_bindNodeField(n1, "description", o2, "f2")
  OM_bindNodeField(n1, "SDPosterUrl", o2, "f3")

  m.assertEqual(o1.f1, "title")
  m.assertEqual(o1.f2, "description")
  m.assertEqual(o1.f3, "SDPosterUrl")

  n1.title = "titleChanged_n1"
  n1.description = "descriptionChanged_n1"
  n1.SDPosterUrl = "SDPosterUrlChanged_n1"

  m.assertEqual(o1.f1, "titleChanged_n1")
  m.assertEqual(o1.f2, "descriptionChanged_n1")
  m.assertEqual(o1.f3, "SDPosterUrlChanged_n1")

  m.assertEqual(o2.f1, "titleChanged_n1")
  m.assertEqual(o2.f2, "descriptionChanged_n1")
  m.assertEqual(o2.f3, "SDPosterUrlChanged_n1")
end function

'@Test one function
function OT_BindingCallback_oneFunction()
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = OT_callbackTarget1
  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"
  n1.title = "title"

  OM_bindNodeField(n1, "title", o1, "f1")
  m.assertEqual(o1._observerCallbackValue1, "title")

  n1.title = "changed"

  m.assertEqual(o1._observerCallbackValue1, "changed")
end function

'@Test one function 100 times to time
function OT_BindingCallback_oneFunction_100times()
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = OT_callbackTarget1
  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"

  OM_bindNodeField(n1, "UserStarRating", o1, "f1")

  for i = 0 to 100
    n1.UserStarRating = i
  end for
end function

'@Test one field 100 times
function OT_BindingCallback_oneField_100()
  o1 = BaseObservable()
  o1.id = "o1"
  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"
  n1.UserStarRating = 0

  OM_bindNodeField(n1, "UserStarRating", o1, "f1")

  for i = 0 to 100
    n1.UserStarRating = i
  end for
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests OM_bindObservableField
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test invalid observable
function OT_bindObservableField_invalidObservable()
  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"
  OM_bindObservableField(invalid, "f1", n1, "title")
end function

'@Test valid observable, invalid data
function OT_bindObservableField_invalidFields()
  o1 = BaseObservable()
  o1.id = "o1"
  m.assertFalse(OM_bindObservableField(o1, invalid, invalid, invalid))
end function

'@Test valid observable, one field
function OT_bindObservableField_oneField_oneNode()
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = "title"

  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"


  OM_bindObservableField(o1, "f1", n1, "title")
  m.assertEqual(n1.title, "title")

  o1.setField("f1", "changed")
  m.assertEqual(n1.title, "changed")
end function

'@Test valid observable, one field multi nodes
function OT_bindObservableField_oneField_twoNodes()
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = "title"

  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"

  n2 = createObject("roSGNode", "ContentNode")
  n2.id = "n2"

  OM_bindObservableField(o1, "f1", n1, "title")
  OM_bindObservableField(o1, "f1", n2, "title")
  m.assertEqual(n1.title, "title")
  m.assertEqual(n2.title, "title")

  o1.setField("f1", "changed")
  m.assertEqual(n1.title, "changed")
  m.assertEqual(n2.title, "changed")
end function

'@Test valid observable, multi fields multi nodes
function OT_bindObservableField_multiField_twoNodes()
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = "title"
  o1.f2 = "description"

  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"

  n2 = createObject("roSGNode", "ContentNode")
  n2.id = "n2"

  OM_bindObservableField(o1, "f1", n1, "title")
  OM_bindObservableField(o1, "f1", n2, "title")
  OM_bindObservableField(o1, "f2", n1, "description")
  OM_bindObservableField(o1, "f2", n2, "description")
  m.assertEqual(n1.title, "title")
  m.assertEqual(n2.title, "title")
  m.assertEqual(n1.description, "description")
  m.assertEqual(n2.description, "description")

  o1.setField("f1", "changed")
  m.assertEqual(n1.title, "changed")
  m.assertEqual(n2.title, "changed")

  o1.setField("f2", "descriptionChanged")
  m.assertEqual(n1.description, "descriptionChanged")
  m.assertEqual(n2.description, "descriptionChanged")
end function

'@Test multi node multi field - measure timing only - no asserts
function OT_bindObservableField_multiField_twoNodes_measure()
  o1 = BaseObservable()
  o1.id = "o1"

  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"

  n2 = createObject("roSGNode", "ContentNode")
  n2.id = "n2"

  OM_bindObservableField(o1, "f1", n1, "title")
  OM_bindObservableField(o1, "f1", n2, "title")
  OM_bindObservableField(o1, "f2", n1, "description")
  OM_bindObservableField(o1, "f2", n2, "description")

  o1.setField("f1", "changed")
  o1.setField("f2", "descriptionChanged")
end function

'@Test multi node multi field 100 times - to measure
function OT_bindObservableField_multiField_twoNodes_measure_100times()
  o1 = BaseObservable()
  o1.id = "o1"

  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"

  n2 = createObject("roSGNode", "ContentNode")
  n2.id = "n2"

  OM_bindObservableField(o1, "f1", n1, "NumEpisodes")
  OM_bindObservableField(o1, "f1", n2, "NumEpisodes")
  OM_bindObservableField(o1, "f2", n1, "UserStarRating")
  OM_bindObservableField(o1, "f2", n2, "UserStarRating")

  for i = 0 to 100
    o1.setField("f1", i)
    o1.setField("f2", i)
  end for
end function

'@Test compare with setField observed 100 times -
function OT_bindObservableField_multiField_twoNodes_measure_100times_compareWithSetField()
  o1 = BaseObservable()
  o1.id = "o1"

  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"

  n2 = createObject("roSGNode", "ContentNode")
  n2.id = "n2"

  OM_bindObservableField(o1, "f1", n1, "NumEpisodes")
  OM_bindObservableField(o1, "f1", n2, "NumEpisodes")
  OM_bindObservableField(o1, "f2", n1, "UserStarRating")
  OM_bindObservableField(o1, "f2", n2, "UserStarRating")
  n1.observeField("UserStarRating", "OT_callbackTarget1")
  n2.observeField("UserStarRating", "OT_callbackTarget1")

  for i = 0 to 100
    n1.UserStarRating = i
    n2.UserStarRating = i
  end for
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests OM_bindFieldTwoWay
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test valid observable, multiple fields
function OT_bindFieldTwoWay_multipleFields_oneNode()
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = "title"
  o1.f2 = "title"

  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"

  OM_bindFieldTwoWay(o1, "f1", n1, "title")
  OM_bindFieldTwoWay(o1, "f2", n1, "title")

  m.assertEqual(n1.title, "title")
  n1.title = "changed"
  m.assertEqual(o1.f1, "changed")
  m.assertEqual(o1.f2, "changed")
  o1.setField("f1", "changed2")
  m.assertEqual(o1.f2, "changed2")
  m.assertEqual(n1.title, "changed2")
  n1.title = "changed3"
  m.assertEqual(o1.f1, "changed3")
  m.assertEqual(o1.f2, "changed3")
  o1.setField("f1", "changed4")
  m.assertEqual(n1.title, "changed4")
  m.assertEqual(o1.f2, "changed4")
end function

'@Test valid observable, one field
function OT_bindFieldTwoWay_oneField_oneNode()
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = "title"

  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"

  OM_bindFieldTwoWay(o1, "f1", n1, "title")
  m.assertEqual(n1.title, "title")
  n1.title = "changed"
  m.assertEqual(o1.f1, "changed")
  o1.setField("f1", "changed2")
  m.assertEqual(n1.title, "changed2")
  n1.title = "changed3"
  m.assertEqual(o1.f1, "changed3")
  o1.setField("f1", "changed4")
  m.assertEqual(n1.title, "changed4")
end function

'@Test valid observable, one field
function OT_bindFieldTwoWay_multipleNodeFields_oneNode()
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = "title"
  o1.f2 = "description"

  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"

  OM_bindFieldTwoWay(o1, "f1", n1, "title")
  OM_bindFieldTwoWay(o1, "f2", n1, "description")
  m.assertEqual(n1.title, "title")
  m.assertEqual(n1.description, "description")
  n1.title = "changed"
  n1.description = "dchanged"
  m.assertEqual(o1.f1, "changed")
  m.assertEqual(o1.f2, "dchanged")
  o1.setField("f1", "changed2")
  o1.setField("f2", "dchanged2")
  m.assertEqual(n1.title, "changed2")
  m.assertEqual(n1.description, "dchanged2")
  n1.title = "changed3"
  n1.description = "dchanged3"
  m.assertEqual(o1.f1, "changed3")
  m.assertEqual(o1.f2, "dchanged3")
  o1.setField("f1", "changed4")
  o1.setField("f2", "dchanged4")
  m.assertEqual(n1.title, "changed4")
  m.assertEqual(n1.description, "dchanged4")
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests OM_unbindFieldTwoWay
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test valid observable, multiple fields
function OT_unbindFieldTwoWay_multipleFields_oneNode()
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = "title"
  o1.f2 = "title"

  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"

  OM_bindFieldTwoWay(o1, "f1", n1, "title")
  OM_bindFieldTwoWay(o1, "f2", n1, "title")

  m.assertEqual(n1.title, "title")
  n1.title = "changed"
  m.assertEqual(o1.f1, "changed")
  m.assertEqual(o1.f2, "changed")
  o1.setField("f1", "changed2")
  m.assertEqual(o1.f2, "changed2")
  m.assertEqual(n1.title, "changed2")
  n1.title = "changed3"
  m.assertEqual(o1.f1, "changed3")
  m.assertEqual(o1.f2, "changed3")
  o1.setField("f1", "changed4")
  m.assertEqual(n1.title, "changed4")
  m.assertEqual(o1.f2, "changed4")
end function

'@Test valid observable, one field
function OT_unbindFieldTwoWay_oneField_oneNode()
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = "title"

  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"

  OM_bindFieldTwoWay(o1, "f1", n1, "title")
  m.assertEqual(n1.title, "title")
  n1.title = "changed"
  m.assertEqual(o1.f1, "changed")
  o1.setField("f1", "changed2")
  m.assertEqual(n1.title, "changed2")
  n1.title = "changed3"
  m.assertEqual(o1.f1, "changed3")
  o1.setField("f1", "changed4")
  m.assertEqual(n1.title, "changed4")

  OM_unbindFieldTwoWay(o1, "f1", n1, "title")

  n1.title = "changed5"
  m.assertEqual(o1.f1, "changed4")
  o1.setField("f1", "changed6")
  m.assertEqual(n1.title, "changed5")
end function

'@Test valid observable, one field
function OT_unbindFieldTwoWay_multipleNodeFields_oneNode()
  o1 = BaseObservable()
  o1.id = "o1"
  o1.f1 = "title"
  o1.f2 = "description"

  n1 = createObject("roSGNode", "ContentNode")
  n1.id = "n1"

  OM_bindFieldTwoWay(o1, "f1", n1, "title")
  OM_bindFieldTwoWay(o1, "f2", n1, "description")
  m.assertEqual(n1.title, "title")
  m.assertEqual(n1.description, "description")
  n1.title = "changed"
  n1.description = "dchanged"
  m.assertEqual(o1.f1, "changed")
  m.assertEqual(o1.f2, "dchanged")
  o1.setField("f1", "changed2")
  o1.setField("f2", "dchanged2")
  m.assertEqual(n1.title, "changed2")
  m.assertEqual(n1.description, "dchanged2")
  n1.title = "changed3"
  n1.description = "dchanged3"
  m.assertEqual(o1.f1, "changed3")
  m.assertEqual(o1.f2, "dchanged3")
  o1.setField("f1", "changed4")
  o1.setField("f2", "dchanged4")
  m.assertEqual(n1.title, "changed4")
  m.assertEqual(n1.description, "dchanged4")

  OM_unbindFieldTwoWay(o1, "f1", n1, "title")
  OM_unbindFieldTwoWay(o1, "f2", n1, "description")

  n1.title = "changed5"
  n1.description = "dchanged5"
  m.assertEqual(o1.f1, "changed4")
  m.assertEqual(o1.f2, "dchanged4")
  o1.setField("f1", "changed6")
  o1.setField("f2", "dchanged6")
  m.assertEqual(n1.title, "changed5")
  m.assertEqual(n1.description, "dchanged5")

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