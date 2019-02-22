function init() as void
  focusMixinInit()
  keyPressMixinInit()
  m.top.observeField("visible", "_onVisibleChange")
  m.wasShown = false
  m.isKeyPressLocked = false
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ utils
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function findNodes(nodeIds) as void
  if (type(nodeIds) = "roArray")
    for each nodeId in nodeIds
      node = m.top.findNode(nodeId)
      if (node <> invalid)
        m[nodeId] = node
      else
        logWarn("could not find node with id {0}", nodeId)
      end if
    end for
  end if
end function

function getContentItemAtRowIndex(content, index)
  if index.Count() = 2 then
    logInfo("getContentItemAtRowIndex [" + stri(index[0]) + "," + stri(index[1]) + "]")
    'get content node by index from grid
    row = content.getChild(index[0])
    if row <> invalid then
      item = row.getChild(index[1])
      if item <> invalid then
        return item
      end if
    end if
  end if
  return invalid
end function

function getRowAtIndex(content, index)
  if content <> invalid and index.Count() = 2 then
    logInfo("getRowAtIndex [" + stri(index[0]) + "," + stri(index[1]) + "]")
    return content.getChild(index[0])
  end if
  return invalid
end function

function getIndexOfItem(parent, item)
  if item <> invalid
    for index = 0 to parent.getChildCount() -1
      node = parent.getChild(index)
      if node.id = item.id
        return index
      end if
    end for
  end if
  return -1
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'** VISIBILITY
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _onVisibleChange()
  if m.top.visible
    onShow(invalid)
  else
    onHide(invalid)
  end if
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ lifecycle methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function onShow(args)
  oldIsShowing = m.top.isShown
  m.top.isShown = true

  if not m.wasShown
    onFirstShow()
    m.wasShown = true
  end if

  if oldIsShowing <> m.top.isShown
    _onShow()
  end if
end function

function onHide(args)
  m.top.isShown = false
  _onHide()
end function

function initialize(args)
  m.top.isInitialized = true
  _initialize(args)
  if m.top.visible and not m.top.isShown
    onShow(invalid)
  end if
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ abstract lifecycle methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _initialize(args)
end function

function onFirstShow()
end function

function _onShow()
end function

function _onHide()
end function
