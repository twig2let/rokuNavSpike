function Init() as void
  CreateObject("roSGNode", "RALETrackerTask")
  m.global.addFields({"isFocusLocked": false})
  createModelLocator()
  m.top.rLog = initializeRlog()
  m.top.rLog.logLevel = 5
  m.top.rLog.excludeFilters = ["TabController"]
  
  m.top.mainView = createObject("roSGNode", "MainView")
  m.global.addFields({"mainView": m.top.mainView})
  m.top.appendChild(m.top.mainView)
  m.top.mainView.setFocus(true)
end function

function createModelLocator()
  modelLocator = createObject("roSGNode", "ModelLocator")
  m.global.addFields({"modelLocator":ModelLocator})
end function