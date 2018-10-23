'@Namespace rLogPT rLog PrintTransport  

function PrintTransport(rLog)
  ' levelTexts = ["[DEBUG]","[VERBOSE]","[INFO]","[WARN]","[ERROR]"]
  levelTexts = ["[ERROR]","[WARN]","[INFO]","[VERBOSE]","[DEBUG]"]
  return {
    rLog_ : rLog
    levelTexts_ : levelTexts
    log: rLogPT_log
    tostr: rLogU_ToString 
  }
end function

function rLogPT_log(args)
  levelText = m.levelTexts_[args.level]
  ? levelText ; " " ; args.name ; "." ; Substitute(args.message, m.tostr(args.value), m.tostr(args.value2), m.tostr(args.value3), m.tostr(args.value4))
end function