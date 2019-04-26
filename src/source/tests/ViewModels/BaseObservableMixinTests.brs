'@TestSuite [BOTM] BaseObservableMixin Tests

'@BeforeEach
function BOTM_BeforeEach()
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