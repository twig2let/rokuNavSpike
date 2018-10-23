'@Namespace rLogM rLogMixin

'*************************************************************
'** initializeRlog
'** Initializes the applications logger, and stores it on global as global.rLog
'** @return Configured rLog, for futher configuraiton, if required
'*************************************************************
function initializeRlog() as Object
  rLog = CreateObject("roSGNode", "rLog")
  m.global.addFields({"rLog": rLog})
  return rLog
end function

function registerLogger(shortName = "gen", name = "general")
  m.rLogShortName = shortName
  m.rLogName = name
end function

function logDebug(message, value = invalid, value2 = invalid, value3 = invalid, value4 = invalid)
  log(4, message, value, value2, value3, value4)
end function

function logVerbose(message, value = invalid, value2 = invalid, value3 = invalid, value4 = invalid)
  log(3, message, value, value2, value3, value4)
end function

function logInfo(message, value = invalid, value2 = invalid, value3 = invalid, value4 = invalid)
  log(2, message, value, value2, value3, value4)
end function

function logWarn(message, value = invalid, value2 = invalid, value3 = invalid, value4 = invalid)
  log(1, message, value, value2, value3, value4)
end function

function logError(message, value = invalid, value2 = invalid, value3 = invalid, value4 = invalid)
  log(0, message, value, value2, value3, value4)
end function

function log(level, message, value = invalid, value2 = invalid, value3 = invalid, value4 = invalid)
  if type(box(m.rLogName)) = "roString"
    name = m.rLogName
  else
    name = "general"
  end if
  
  args = { 
    "shortName": m.rLogShortName
    "name" : m.rLogName
    "level" : level
    "message" : message
    "value" : value
    "value2" : value2
    "value3" : value3
    "value4" : value4
  }
  m.global.rLog.callFunc("log", args)
end function
