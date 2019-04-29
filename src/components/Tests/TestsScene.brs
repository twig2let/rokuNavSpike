function Init() as void
  m.global.addFields({"isFocusLocked": false})
  m.top.rLog = initializeRlog()
  m.top.rLog.logLevel = 5
end function

