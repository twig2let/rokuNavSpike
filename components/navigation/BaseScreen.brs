'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ nav support
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


function resetNavController(newFirstScreen = invalid)
  if (m.top.navController <> invalid)
    m.top.navController.callFunc("reset", newFirstScreen)
  else
    print "Pop failed - there is no navcontroller on " ; m.top
  end if
end function

function pop() as Object
  if (m.top.navController <> invalid)
    return m.top.navController.callFunc("pop", invalid)
  else
    print "Pop failed - there is no navcontroller on " ; m.top
  end if
  
end function

function push(view)
  if (m.top.navController <> invalid)
    m.top.navController.callFunc("push", view)
  else
    print "Push failed - there is no navcontroller on " ; m.top
  end if
  
end function

function _onAddedToNavController(navController)
end function

function _onRemovedFromNavController(navController)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Application level services
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

' Put appliaction specific app services in here
' I like to include code here which does things like access an important view/service
' on my modelLocator and construct the args node it requires to be set/passed to callfunc
' meaning I can have well encapsulated code and a clean api in my apps 