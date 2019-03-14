function init() as void
  m.modelLocator = m.global.modelLocator
  focusMixinInit()
  keyPressMixinInit()
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

' /**
'  * @member intializeView
'  * @memberof module:BaseView
'  * @instance
'  * @description initializes the passed in View
'  * @param {BaseView} the view to initialize
'  */
function initializeView(view, args = invalid) as void
  view.callFunc("initialize", args)
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'** VISIBILITY
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _onVisibleChange()
  'TODO - does the nav controller handle this in future?
  logInfo(m.top.id, "_onVisibleChange visible ", m.top.visible)
  if m.top.visible
    onShow(invalid)
  else
    onHide(invalid)
  end if
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ Lifecycle methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function applyStyle()
  styles = m.modelLocator.styles
  localizations = m.modelLocator.localizations
  assets = m.modelLocator.assets
  _applyStyle(styles, localizations, assets)
end function

function onShow(args) as void
  ' ? ">> base VIEW ONSHOW " ; m.top.id ; " isShown " ; m.top.isShown
  oldIsShowing = m.top.isShown
  if not m.top.isInitialized
    return
  end if
  m.top.isShown = true
  
  if not m.wasShown
    _onFirstShow()
    m.wasShown = true
  end if

  if oldIsShowing <> m.top.isShown
    _baseScreenOnShow()
    _onShow()
  end if
end function

function onHide(args)
  if m.wasShown
    m.top.isShown = false
    _onHide()
  else
    logWarn("onHide called before show: ignoring")
  end if
end function

function initialize(args = invalid)
  logMethod("initialize")
  if not m.top.isInitialized
    m.top.isInitialized = true
    _initialize(args)
    applyStyle()
    m.top.observeField("visible", "_onVisibleChange")
    if m.top.visible and not m.top.isShown
      onShow(invalid)
    end if
  else
    logWarn("View was already initialized. Ignoring subsequent call ", m.top)
  end if
end function

'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'++ abstract lifecycle methods
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function _initialize(args)
end function

function _applyStyle(styles, localizations, assets)
  'override me ; but this function should appear at the top of the script file, 
  ' with the init method, for readability
end function

function _onFirstShow()
end function

'SG has a limit to how many times you can override a method
'this function allows us to wire in extra show driven behavior in screens.
'It's a hack; but it's better than having to duplicate behavior
function _baseScreenOnShow()
end function

function _onShow()
end function

function _onHide()
end function
