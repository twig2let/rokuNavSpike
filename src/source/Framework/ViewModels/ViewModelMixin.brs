'@Namespace VMM VieWModelMixin
'@Import Utils

function VMM_isVM(vm)
  return OM_isObservable(vm) and vm.__viewModel = true
end function

function VMM_createFocusMap(vm) as boolean
  focusMap = {}
  success = false
  if VMM_isVM(vm)
    if isArray(vm.focusIds)
      for index = 0 to vm.focusIds.count() -1
        key = vm.focusIds[index]
        control = m[key]
        if type(control) = "roSGNode"
          focusMap[key] = control
        else
          logError("createFocusMap : could not find control for id", key)
        end if
      end for
      success = true
    else
      logInfo("no focusMap for vm", vm.name)
    end if
  else
    logError("unknown vm type!")
  end if

  m.focusMap = focusMap
  return success
end function

function VMM_onFocusIdChange(focusId)
  if focusId <> invalid and focusId <> ""
    control = m.focusMap[focusId]
    if control <> invalid
      setFocus(control)
    else
      logError("the focus map contained a focusId that did not exist!", focusId)
    end if
  end if
end function