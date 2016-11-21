helperHex = (val) ->
  hexString = parseInt(val).toString(16).toUpperCase()
  if (val < 16)
    "0#{hexString}"
  else
    hexString

hexValue = (dictionary) ->
  return "" + helperHex(dictionary.r * 255) + helperHex(dictionary.g * 255) + helperHex(dictionary.b * 255)