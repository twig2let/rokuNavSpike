' /**
'  * ThreadUtils
'  *
'  * Wait in SG apps causes the debugger to totally break. it is also _way faster_ to not
'  * use wait.
'  *
'  * This utility class replaces certain methods that relied on wait
'  * We can therefore encapsulate an alternate behavior here, and if Roku dont' like this
'  * for whatever reason, then we can simply introduce compiler directives to switch
'  * out the original wait(0, port) functionality.
'  */


' /**
'  * @member waitPort
'  * @memberof module:ThreadUtils
'  * @instance
'  * @description port.wait is buggy and ruins breakpoint debugging, we therefore use this
'  *              method to get messages from our ports, instead
'  * @param {delay} max ms to wait - if exceeded before message comes, invalid is returned
'  * @param {roMessagePort} port to get message on
'  * @returns {roMessage} message, once retrieved
'  * @param {boolean} forceOriginalImpl - if true will use the standard implementation
'  */
function waitPort(delay = 0, port = invalid, forceOriginalImpl = false)
  if forceOriginalImpl
    '? "waitPort: forcing original implementation"
    return wait(delay, port)
  end if
  if port = invalid
    return invalid
  end if
  if delay = 0
    msg = invalid
    while msg = invalid
      msg = port.getMessage()
    end while
  else
    timespan = CreateObject("roTimespan")
    msg = invalid
    while msg = invalid
      if timespan.TotalMilliseconds() > delay then exit while
      msg = port.getMessage()
    end while
  end if
  return msg
end function

' /**
'  * @member waitForMillisends
'  * @memberof module:ThreadUtils
'  * @instance
'  * @description replacement for
'  * @param {delay} delay in ms
'  * @param {boolean} forceOriginalImpl - if true will use the standard implementation
'  */
function waitForMilliseconds(delay, forceOriginalImpl = false) as void
  if forceOriginalImpl
    '? "waitForMilliseconds: forcing original implementation"
    port = CreateObject("roMessagePort")
    wait(delay, port)
    return
  end if
  timespan = CreateObject("roTimespan")
  while true
    if timespan.TotalMilliseconds() > delay then exit while
  end while
end function
