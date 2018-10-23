function FocusMixinInit() as void
    m.top.observeField("focusedChild", "OnFocusedChildChange")
    m.currentFocusedControl = invalid
    m.isFocused = false
end function

function SaveFocus() as void
    m.savedFocus = m.currentFocusedControl
    if (m.savedFocus <> invalid)
        logDebug(" saving focus as ", m.savedFocus.id)
    end if
end function 

function ClearSavedFocus() as void
    m.savedFocus = invalid
end function

'*************************************************************
'** RestoreFocus
'** gives focus to the saved focus target; or if not possible, to the provided defaultFocusTarget
'** @param defaultFocusTarget as roSGNode, target for receiving focus if non saved
'** @return boolean , true if focus was assigned to savedFocus, or false if assigned to defaultFocusTarget
'*************************************************************
function RestoreFocus(defaultFocusTarget) as boolean
    if (m.savedFocus <> invalid)
        logDebug("RestoreFocus - restoring focus to ", m.savedFocus.id)
        SetFocus(m.savedFocus)
        return true
    else
        if (defaultFocusTarget <> invalid)
            logDebug("RestoreFocus -  no node to restore too, selecting default node", defaultFocusTarget.id)
            SetFocus(defaultFocusTarget)
        else
            logError("RestoreFocus - focus is assigned to nothing!")
        end if
        return false
    end if
end function

'*************************************************************
'** SetFocus
'** abstracts focus setting to make it easier to debug
'** @param node as roSGNode - to set focus to
'** @param isSaving as boolean - whether to save the focus so it later can be restored
'** @param forceSet as boolean - this will override situations where the focus is locked, like when showing a dialog
'** @return ObjectR retdesc
'*************************************************************
function SetFocus(node, isSaving = true, forceSet = false) as void
    ? " setting focus to " ; node.id
    if (type(node) = "roSGNode")
        if (m.global.isFocusLocked and not forceSet)
            ? "Can't set focus because it's locked! reason " ; m.global.focusLockReason
        else
            node.SetFocus(true)
            m.savedFocus = node
        end if
    end if
end function

'*************************************************************
'** SetfocusLocked
'** Toggles if the focus is locked to a particular control. If so, only calls to SetFocus
'** with an override flag will set the focus
'** @param isLocked as boolean toggles locked mode on or off
'** @param focusLockReason as string helps identify what locked the focus for debugging purposes
'*************************************************************
function SetFocusLocked(isLocked, focusLockReason) as void
    if (not m.global.hasField("isFocusLocked"))
        m.global.addFields({"isFocusLocked":isLocked})
        m.global.addFields({"focusLockReason":focusLockReason})
    else
        if (isLocked)
            m.global.setField("focusLockReason",focusLockReason)
        else
            m.global.setField("focusLockReason","unlocked " + focusLockReason)
        end if
        m.global.setField("isFocusLocked",isLocked)
    end if    
end function

function OnFocusedChildChange(evt) as void
    newNode = evt.getData()
    
    if (newNode = invalid)
        updateIsInFocusChain(false)
    else
        updateIsInFocusChain(m.top.isInFocusChain())
    end if
    
    if (m.isFocused)
        _OnChildGainedFocus(m.currentFocusedControl)
    else
        _OnChildLostFocus(m.currentFocusedControl)
    end if
    
    return
end function

function updateIsInFocusChain(isInChain as boolean ) as void
    wasInChain = m.isFocused
    m.isFocused = isInChain

    if (wasInChain and not isInChain) then
        _OnLostFocus()
    else if (isInChain and not wasInChain) then 
        ? " SETTING GAINED FOCUS " ; m.top.id
        _OnGainedFocus()
    end if
end function

function _OnChildGainedFocus(node as object) as void
end function


function _OnChildLostFocus(node as object) as void
end function
 
function _OnGainedFocus() as void
  ? "_OnGainedFocus " ; m.top.id
end function


function _OnLostFocus() as void
  ? "_OnLostFocus " ; m.top.id
end function

