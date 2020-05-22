###
  ColorAssetRepository:

###
class ColorAssetRepository
  
  nameBasedMap: {}
  colorBasedMap: {}

  constructor: (document) ->
    if document
      documentColorAssets = document.documentData().assets().colorAssets().objectEnumerator()
      @nameBasedMap = NSMutableDictionary.alloc().init()
      @colorBasedMap = NSMutableDictionary.alloc().init()

      while colorAsset = documentColorAssets.nextObject()
        color = colorAsset.color().immutableModelObject()
        name = colorAsset.name()
        unless @nameBasedMap.objectForKey(name)
           @nameBasedMap.setObject_forKey(colorAsset, name)

        unless @colorBasedMap.objectForKey(color)
           @colorBasedMap.setObject_forKey(colorAsset, color)

  colorAssetByName: (name) -> 
    @nameBasedMap.objectForKey(name)

  colorAssetByColor: (color) -> 
    @colorBasedMap.objectForKey(color)