class Palette extends Base

  ARTBOARD_TAG: "artboard"
  #Spacing between the palette and your artboards.
  PALETTE_SPACING: 26
  CELL_SPACING: 30
  COLORS_PER_ROW: 4

  colorClassifier: new ColorClassifier()

  constructor: (context, layer = null) ->
    log "adasd"
    super context, layer
    #Look for the Palette Layer.
    children = @currentPage.children()
    for i in [0...children.count()]
      layer = children[i]
      if @command.valueForKey_onLayer_forPluginIdentifier(@ARTBOARD_TAG, layer, @pluginID )
        log "FOUND Palette!"
        @artboard = layer

    if @context.document
      documentColorAssets = @context.document.documentData().assets().colorAssets().objectEnumerator()
      colorAssets = NSMutableArray.alloc().init()
      while colorAsset = documentColorAssets.nextObject()
        colorAssets.addObject(colorAsset)
      @colorAssets = colorAssets

  regenerate: ->
    @generate()

  generate: ->
    NSApplication.sharedApplication().displayDialog_withTitle("There are no colors on your Document Colors.", "Feed me colors!") if @colorAssets.count() == 0

    #If it wasn't found, then create it.
    unless @artboard
      log "New palette..."
      @artboard = @template.getArtboard()
      @artboard.setName("Prism Palette")
      @command.setValue_forKey_onLayer_forPluginIdentifier( true, @ARTBOARD_TAG, @artboard, @pluginID )

    @artboard.removeAllLayers()

    # Generate Document Color Name mapping dictionary
    colorAssetRepo = new ColorAssetRepository(@context.document)

    # Palette Generation
    row = 0
    column = 0
    for i in [0...@colorAssets.count()]
      #If in the last column, reset column and increment row...
      (column = 0; row++) if column >= @COLORS_PER_ROW
      #Cell setup
      colorAsset = @colorAssets[i]
      color = colorAsset.color()
      cell = new Cell(@context)
      #If there's named document color then use it, otherwise an alias defined then use it, finally use the color classifier.
      name = @documentColorName(colorAsset) ? @aliasForColor(color) ? @colorClassifier.classify(color.immutableModelObject().hexValue())
      cell.setColor_withName( color, name )
      cell.setX((cell.width + @CELL_SPACING) * column + @CELL_SPACING)
      cell.setY((cell.height + @CELL_SPACING) * row + @CELL_SPACING)

      @artboard.addLayers [cell.layer]
      column++

    @artboard.frame().setHeight((cell.height + @CELL_SPACING) * (row+1) + @CELL_SPACING)
    @artboard.frame().setWidth((cell.width + @CELL_SPACING) * Math.min(@colorAssets.count(),@COLORS_PER_ROW) + @CELL_SPACING)

    #Position Artboard
    @artboard.removeFromParent()
    bounds = @currentPage.contentBounds()

    @artboard.frame().setX(bounds.origin.x - @artboard.frame().width() - @PALETTE_SPACING)
    @artboard.frame().setY(bounds.origin.y)

    @currentPage.addLayers [@artboard]

  getColorsDictionaries: ->
    colors = []
    children = @artboard.children()
    for i in [0...children.count()]
      colorDictionary = @valueForKey_onLayer(Cell::CELL_LAYER_TAG, children[i])
      colors.push colorDictionary if colorDictionary
    return colors

  getColorsDictionariesFromLayers: (layers) ->
    colors = []
    for i in [0...layers.count()]
      colorDictionary = @valueForKey_onLayer(Cell::CELL_LAYER_TAG, layers[i])
      colors.push colorDictionary if colorDictionary
    return colors

  aliasForColor: (color) ->
    @valueForKey_onLayer(color.immutableModelObject().hexValue(),@artboard)
  
  documentColorName: (colorAsset) ->
    name = colorAsset.displayName()
    if name.length() > 0
      return name
