'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ FOCUS
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function focusMixinInit()
  m.top.observeField("focusedChild", "onFocusedChildChange")
  m.global.addFields({
    "isFocusLocked":false
    "focusLockReason":""
  })

  m.global.addField("focusedNode", "node", false)
  logVerbose(" focusMixinInit ", m.top.subType())
  m.currentFocusedControl = invalid
  m.isInFocusChain = false
end function

function saveFocus()
  m.savedFocus = m.currentFocusedControl
  if (m.savedFocus <> invalid)
    logVerbose("focusMixin. saving focus as ",  m.savedFocus.id)
  end if
end function

function clearSavedFocus()
  m.savedFocus = invalid
end function
'*************************************************************
'** restoreFocus
'** gives focus to the saved focus target; or if not possible, to the provided defaultFocusTarget
'** @param defaultFocusTarget as roSGNode, target for receiving focus if non saved
'** @return boolean , true if focus was assigned to savedFocus, or false if assigned to defaultFocusTarget
'*************************************************************
function restoreFocus(defaultFocusTarget) as boolean
  if (m.savedFocus <> invalid)
    logVerbose("focusMixin.restoreFocus - restoring focus to ", m.savedFocus.id)
    setFocus(m.savedFocus)
    return true
  else
    if (defaultFocusTarget <> invalid)
      logWarn("focusMixin.restoreFocus -  no node to restore too, selecting default node", defaultFocusTarget.id)
      setFocus(defaultFocusTarget)
    else
      logError("focusMixin.restoreFocus - focus is assigned to nothing!")
    end if
    return false
  end if
end function

'*************************************************************
'** setFocus
'** abstracts focus setting to make it easier to debug
'** @param node as roSGNode - to set focus to
'** @param isSaving as boolean - whether to save the focus so it later can be restored
'** @param forceSet as boolean - this will override situations where the focus is locked, like when showing a dialog
'*************************************************************
function setFocus(node, isSaving = true, forceSet = false)
  if (type(node) = "roSGNode")
    logVerbose("setFocus ", node.subType(), " id ", node.id)

    if (m.global.isFocusLocked and not forceSet)
      logWarn("Can't set focus because it's locked! reason ", m.global.focusLockReason)
    else
      node.setFocus(false)
      node.setFocus(true)
      m.global.focusedNode = node
      m.savedFocus = node
    end if
  else
    logError("setFocus called for invalid node!")
  end if
end function

'*************************************************************
'** unsetFocus
'** abstracts focus un setting to make it easier to debug
'** @param node as roSGNode - to set focus to
'*************************************************************
function unsetFocus(node)
  if (type(node) = "roSGNode")
    logVerbose("unsetFocus ", node.subType(), " id ", node.id)
    node.setFocus(false)

    if node.isSameNode(m.savedFocus)
      m.savedFocus = invalid
    end if
  else
    logError("setFocus called for invalid node!")
  end if
  m.global.focusedNode = invalid
end function

'*************************************************************
'** setFocusLocked
'** Toggles if the focus is locked to a particular control. If so, only calls to setFocus
'** with an override flag will set the focus
'** @param isLocked as boolean toggles locked mode on or off
'** @param focusLockReason as string helps identify what locked the focus for debugging purposes
'*************************************************************
function setFocusLocked(isLocked, focusLockReason ="")
  if (isLocked)
    m.global.setField("focusLockReason",focusLockReason)
  else
    m.global.setField("focusLockReason","unlocked " + focusLockReason)
  end if
  m.global.setField("isFocusLocked",isLocked)
end function

function onFocusedChildChange(evt)
  newNode = evt.getData()

  if (newNode = invalid)
    logVerbose("onFocusedChildChange newNode is invalid")
    updateIsFocused(false, false, invalid)
  else
    updateIsFocused(m.top.isInFocusChain(), m.top.hasFocus(), newNode)
  end if
end function

function updateIsFocused(isInFocusChain, isFocused, newNode)
  wasInFocusChain = m.isInFocusChain
  m.isInFocusChain = isInFocusChain

  if (wasInFocusChain and not m.isInFocusChain)
    _onLostFocus()
  else if (m.isInFocusChain and not wasInFocusChain)
    _onGainedFocus(isFocused)
  end if
end function


'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ abstract focus methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _onGainedFocus(isSelfFocused)
end function


function _onLostFocus()
end function

