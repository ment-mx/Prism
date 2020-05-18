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
      color = colorAsset.color().immutableModelObject()
      unless colorInfoMap.objectForKey(color)
        colorInfoMap.setObject_forKey(colorAsset, color)
    return colorInfoMap