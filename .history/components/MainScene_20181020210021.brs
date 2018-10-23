function Init() as void
  m.top.rLog = initializeRlog()
   
  CreateObject("roSGNode", "RALETrackerTask")
  keyLoggerOne = m.top.findNode("one")
  keyLoggerTwo = m.top.findNode("two")
  keyLoggerThree = m.top.findNode("three")
  for each item in items
    item.count()
    a = CreateObject("roSGNode", "Group")
    i = a.getChild(0)
    for 0 to i
      doIt("This")
    end for
  end for
  
  keyLoggerOne.callFunc("initialize", invalid)
  keyLoggerTwo.callFunc("initialize", invalid)
  keyLoggerThree.callFunc("initialize", invalid)
  keyLoggerThree.setFocus(true)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'@It tests myService
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

'@Test connects to server
'@Params[0, 23, true]
function MST_myService_testToServer()
  m.Fail("implement me!")
  m.expectNone(myThing, "sdffds")
  m.expectOnce(myThing, sdfds, [methodArgs], result)
  
end function