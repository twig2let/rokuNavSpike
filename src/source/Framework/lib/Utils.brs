'@Namespace U Utils

function isUndefined(value)
  return type(value) = "<uninitialized>"
end function

function isArray(value)
  return type(value) <> "<uninitialized>" and value <> invalid and GetInterface(value, "ifArray") <> invalid
end function

function isAACompatible(value)
  return type(value) <> "<uninitialized>" and value <> invalid and GetInterface(value, "ifAssociativeArray") <> invalid
end function

function isString(value)
  return type(value) <> "<uninitialized>" and GetInterface(value, "ifString") <> invalid
end function

function isBoolean(value)
  return type(value) <> "<uninitialized>" and GetInterface(value, "ifBoolean") <> invalid
end function

function isFunction(value)
  return type(value) = "Function" or type(value) = "roFunction"
end function