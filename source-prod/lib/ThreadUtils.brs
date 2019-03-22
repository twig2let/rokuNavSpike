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
'  */
function waitPort(delay = 0, port = invalid)
  return wait(delay, port)
end function

' /**
'  * @member waitForMillisends
'  * @memberof module:ThreadUtils
'  * @instance
'  * @description replacement for
'  * @param {paramType} paramDescription
'  * @returns {returnType} returnDescription
'  */
function waitForMilliseconds(delay)
  port = CreateObject("roMessagePort")
  wait(delay, port)
end function