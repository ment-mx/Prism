helperHex = (val) ->
  hexString = parseInt(val).toString(16).toUpperCase()
  if (val < 16)
    "0#{hexString}"
  else
    hexString
