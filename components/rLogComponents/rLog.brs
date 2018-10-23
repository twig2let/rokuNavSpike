function Init() as void
  m.transportImpls = []
  m.top.filters = []
  m.top.transports = ["printTransport"]
end function

function log(args)
  if m.top.logLevel >= args.level and matchesFilter(args) and not isExcluded(args)
    for each transport in m.transportImpls
      transport.log(args)
    end for
  end if
end function

function matchesFilter(args) as boolean
  if m.top.filters.count() = 0
    return true
  else
    for each filter in m.top.filters
      if type(box(filter)) = "roString" and filter = args.name
        return true
      end if
    end for
  end if
  
  return false
end function

function isExcluded(args) as boolean
  if m.top.excludeFilters.count() = 0
    return false
  else
    for each filter in m.top.excludeFilters
      if type(box(filter)) = "roString" and filter = args.name
        return true
      end if
    end for
  end if
  
  return false
end function

function onTransportsChange(event)
  m.transportImpls = []
  for each transportType in m.top.transports
    transport = getTransport(transportType)
    if transport <> invalid
      m.transportImpls.push(transport)
    else
      ? "found illegal transportType " ; transportType
    end if
  end for
end function

function getTransport(transportType)
  if transportType = "printTransport"
    return PrintTransport(m.top)
  end if
end function