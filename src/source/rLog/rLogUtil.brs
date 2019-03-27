'@Namespace rLogU rLogUtil  
function rLogU_ToString(value as Dynamic) as String
    valueType = type(value) 
    
    if (valueType = "<uninitialized>" or value = invalid)
        return ""
    else if (GetInterface(value, "ifString") <> invalid)
        return value
    else if (valueType = "roInt" or valueType = "roInteger" or valueType = "Integer")
        return value.tostr()
    else if (GetInterface(value, "ifFloat") <> invalid)
        return Str(value).Trim()
    else if (type(value) = "roSGNode")
        return "Node(" + value.subType() +")"
    else
        return ""
    end If
end function
