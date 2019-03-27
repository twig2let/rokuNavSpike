'@TestSuite [BOT] BaseObservable Tests 

'@Setup
function BOT_SetUp() 
    m.observable = BaseObservable()
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests SetValue
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test SetValue for invalid
function BOT_SetValue_invalid() 
    m.observable.setField("testValue", invalid)
    m.AssertInvalid(m.observable.testValue)
end function

'@Test SetValue for string
function BOT_SetValue_string() 
    m.observable.setField("testValue", "stringValue")
    m.AssertEqual(m.observable.testValue, "stringValue")
end function


'@Test SetValue for int
function BOT_SetValue_int() 
    m.observable.setField("testValue", 33)
    m.AssertEqual(m.observable.testValue, 33)
end function


'@Test SetValue for float
function BOT_SetValue_float() 
    m.observable.setField("testValue", 33.3)
    m.AssertEqual(m.observable.testValue, 33.3)
end function

'@Test SetValue for node
function BOT_SetValue_node() 
    value = createObject("roSGNode", "ContentNode")
    
    m.observable.setField("testValue", value)
    m.AssertEqual(m.observable.testValue, value)
end function

'@Test SetValue for aa
function BOT_SetValue_aa() 
    value = {"test": "#test"}
    m.observable.setField("testValue", value)
    m.AssertEqual(m.observable.testValue, value)
end function
