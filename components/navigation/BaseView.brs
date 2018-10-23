function Init()
  FocusMixinInit()
  m.top.observeField("visible", "onVisibleChange_")
  m.wasShown = false
  m.isKeyPressLocked = false
end function

function findNodes(nodeIds) as void
  if (type(nodeIds) = "roArray")
    for each nodeId in nodeIds
      node = m.top.findNode(nodeId)
      if (node <> invalid)
        m[nodeId] = node
      else
        logWarn("could not find node with id {0}", nodeId)
      endif
    end for  
  end if  
end function


'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'** VISIBILITY
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function onVisibleChange_()
  'TODO - does the nav controller handle this in future?
  print m.top.id ; "onVisibleChange_ visible " ; m.top.visible 
  if m.top.visible
    onShow_()
  else
    onHide_()
  end if
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Lifecycle methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function initialize(args = invalid)
end function

function setNavItem(navItem)
  navItem.view = m.top
  navItem.key = navItem.name
  m.top.navItem = navItem
end function

function onShow(args)
  if not m.wasShown
    onFirstShow_()
    m.wasShown = true
  end if
  onShow_()
end function

function onHide(args)
  onHide_()
end function


'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ abstract lifecycle methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function onFirstShow_()
end function

function onShow_()
end function

function onHide_()
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ KEY HANDLING
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function OnKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press
        if (isAnyKeyPressLocked_())
            return true
        end if
        ' ? Substitute("[{0}.OnKeyEvent] {1}", m.top.id, key)
        if key = "down"
            result = onKeyPressDown_()    
        else if key = "up"
            result = onKeyPressUp_()
        else if key = "left"
            result = onKeyPressLeft_()
        else if key = "right"
            result = onKeyPressRight_()
        else if key = "OK"
            result = onKeyPressOK_()
        else if key = "back"
            result = onKeyPressBack_()
        else if key = "options"
            result = onKeyPressOption_()
        end if
    end if
     
    if (result = invalid)
        result = false
    end if

    if (result = false)
        result = isCapturingAnyKeyPress_(key)
    end if
    
    return result 
end function

function isAnyKeyPressLocked_() as boolean
  if m.isKeyPressLocked
    print "all key presses are set to locked on View " ; m.top.subType() ; " with id " ; m.top.id
  end if
  return m.isKeyPressLocked
end function  


function isCapturingAnyKeyPress_(key) as boolean
    return false
end function

function onKeyPressDown_() as boolean
    return false
end function

function onKeyPressUp_() as boolean
    return false
end function

function onKeyPressLeft_() as boolean
    return false
end function

function onKeyPressRight_() as boolean
    return false
end function

function onKeyPressBack_() as boolean
    return false
end function

function onKeyPressOption_() as boolean
    return false
end function

function onKeyPressOK_() as boolean
    return false
end function
