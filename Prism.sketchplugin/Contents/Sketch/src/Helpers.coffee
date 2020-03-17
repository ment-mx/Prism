helperHex = (val) ->
  hexString = parseInt(val).toString(16).toUpperCase()
  if (val < 16)
    "0#{hexString}"
  else
    hexString

documentColorMap = (document) ->
  if document
    documentColorAssets = document.documentData().assets().colorAssets().objectEnumerator()
    colorInfoMap = NSMutableDictionary.alloc().init()
    while colorAsset = documentColorAssets.nextObject()
      hex = colorAsset.color().immutableModelObject().hexValue()
      unless colorInfoMap.objectForKey(hex)
        colorInfoMap.setObject_forKey(colorAsset, hex)
    return colorInfoMap