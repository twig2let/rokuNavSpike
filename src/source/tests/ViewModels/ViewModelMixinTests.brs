'@TestSuite [VMMT] ViewModelMixin Tests

'@BeforeEach
function VMMT_BeforeEach()
  m.node.delete("focusMap")
  m.node.delete("one")
  m.node.delete("two")
  m.node.delete("three")
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests isVM
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@Test invalid
'@Params[invalid]
'@Params[{}]
'@Params["wrong"]
'@Params[[]]
'@Params[{"prop":invalid}]
'@Params[{"name":""}]
function VVMT_isVM_invalid(vm)
  m.assertFalse(VMM_isVM(vm))
end function

function VVMT_isVM_bogusVM()
  m.assertFalse(VMM_isVM({"__viewModel": true}))
end function

function VVMT_isVM_valid()
  m.assertTrue(VMM_isVM(BVMT_createVM()))
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests createFocusMap
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test invalid
'@Params[invalid]
'@Params[{}]
'@Params["wrong"]
'@Params[[]]
'@Params[{"prop":invalid}]
'@Params[{"name":""}]
function VVMT_createFocusMap_invalid(subClass)
  m.assertFalse(VMM_createFocusMap(subClass))
end function

'@Test valid - no ids
function VVMT_createFocusMap_valid_noIds()
  vm = BVMT_createVM()
  m.assertFalse(VMM_createFocusMap(vm))
  m.assertEmpty(m.node.focusMap)
end function

'@Test valid - empty ids
function VVMT_createFocusMap_valid_emptyIds()
  vm = BVMT_createVM()
  vm.focusIds = []
  m.assertTrue(VMM_createFocusMap(vm))
  m.assertEmpty(m.node.focusMap)
end function

'@Test valid ids - no controls
function VVMT_createFocusMap_valid_ids_noControls()
  vm = BVMT_createVM()
  vm.focusIds = [
    "one"
    "two"
    "three"
  ]
  m.assertTrue(VMM_createFocusMap(vm))
  m.assertEmpty(m.node.focusMap)
end function

'@Test valid
function VVMT_createFocusMap_valid()
  vm = BVMT_createVM()
  m.node.one = createObject("roSGNode", "Node")
  m.node.two = createObject("roSGNode", "Node")
  m.node.three = createObject("roSGNode", "Node")
  vm.focusIds = [
    "one"
    "two"
    "three"
  ]
  m.assertTrue(VMM_createFocusMap(vm))
  m.assertEqual(m.node.focusMap["one"], m.node.one)
  m.assertEqual(m.node.focusMap["two"], m.node.two)
  m.assertEqual(m.node.focusMap["three"], m.node.three)
end function
