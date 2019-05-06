'@TestSuite [BVMT] BaseViewModel Tests

'@BeforeEach
function BVMT_BeforeEach()
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests simple constructor
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test invalid
'@Params[invalid]
'@Params[{}]
'@Params["wrong"]
'@Params[[]]
'@Params[{"prop":invalid}]
'@Params[{"name":""}]
function BVMT_constructor_invalid(subClass)
  vm = BaseViewModel(subClass)
  m.assertEqual(vm.state, "invalid")
end function

'@Test valid
function BVMT_constructor_valid()
  subClass = {
    name: "testVM"
  }
  vm = BaseViewModel(subClass)
  m.assertEqual(vm.state, "none")
  m.assertEqual(vm.name, "testVM")
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests vm class functions correctly, with scoped methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test valid
function BVMT_testVM()
  vm = createVM()
  m.assertEqual(vm.state, "none")
  m.assertEqual(vm.name, "testVM")

  vm.initialize()
  m.assertEqual(vm.state, "initialized")

  vm.setAge(23)
  m.assertEqual(vm.getAge(), 23)
end function

'@Test calls abstract methods
function BVMT_testVM_abstractMethods()
  vm = createVM()
  m.assertEqual(vm.state, "none")
  m.assertEqual(vm.name, "testVM")

  vm.initialize()
  m.assertEqual(vm.state, "initialized")
  m.assertTrue(vm.isInitCalled)

  vm.onShow()
  m.assertTrue(vm.isOnShowCalled)

  vm.onHide()
  m.assertTrue(vm.isOnHideCalled)

  vm.destroy()
  m.assertTrue(vm.isDestroyCalled)
end function

'@Test timeConstructor
function BVMT_timeConstructor()
  vm = createVM()
end function

'@Test time method calls
function BVMT_testVM_time()
  vm = createVM()
  vm.initialize()
  vm.onShow()
  vm.onHide()
  vm.destroy()
end function

function BVMT_getAge()
  return m.age
end function

function BVMT_setAge(age)
  return m.setField("age", age)
end function

function BVMT_customInitialize()
  m.isInitCalled = true
end function

function BVMT_customOnShow()
  m.isOnShowCalled = true
end function

function BVMT_customOnHide()
  m.isOnHideCalled = true
end function

function BVMT_customDestroy()
  m.isDestroyCalled = true
end function

function createVM()
  subClass = {
    name: "testVM"
    getAge: BVMT_getAge
    setAge: BVMT_setAge
    _initialize: BVMT_customInitialize
    _destroy: BVMT_customDestroy
    _onShow: BVMT_customOnShow
    _onHide: BVMT_customOnHide
  }
  return BaseViewModel(subClass)
end function