class Palette

  #Tags
  ARTBOARD_TAG: "artboard"
  cellTag: "cell"
  cellIndex: "index"

  spacingBetweenPalette: 26 #The spacing between the palette and your artboards.
  spacingBetweenCells: 30

  colorsPerRow: 4

  constructor: (@context) ->
    #Syntatic sugar
    @document = @context.document
    @command = @context.command
    @currentPage = @context.document.currentPage()
    @colors =  @context.document.documentData().assets().primitiveColors().array()
    @pluginID = @context.plugin.identifier()
    @template = new Template @context.plugin.url()

    children = @currentPage.children()
    for i in [0...children.count()]
      layer = children[i]
      if @command.valueForKey_onLayer_forPluginIdentifier(@ARTBOARD_TAG, layer, @pluginID )
        log "FOUND Palette!"
        @artboard = layer

    #printing testing
    #@document.showMessage "Palette generated!"


  generate: ->

    unless @artboard
      log "New palette..."
      @artboard = @template.getArtboard()
      @artboard.removeAllLayers() if @colors.count() > 0
      @command.setValue_forKey_onLayer_forPluginIdentifier( true, @ARTBOARD_TAG, @artboard, @pluginID )
    else
      log "Old palette..."
      bounds = @artboard.frame()
      @artboard.removeAllLayers()

    row = 0
    column = 0
    for i in [0...@colors.count()]
      #If in the last column, reset column and increment row...
      (column = 0; row++) if column >= @colorsPerRow

      #Cell setup
      color = @colors[i]
      cell = new Cell(@template.getCell(), @context)
      cell.setColor_withAlias(color, @aliasForColor(color) )
      cell.setX((cell.width + @spacingBetweenCells) * column + @spacingBetweenCells)
      cell.setY((cell.height + @spacingBetweenCells) * row + @spacingBetweenCells)


      #This is important!!
      #@command.setValue_forKey_onLayer_forPluginIdentifier( i , @cellIndex, cell.layer , @pluginID)

      @artboard.addLayers [cell.layer]
      column++

    @artboard.frame().setHeight((cell.height + @spacingBetweenCells) * (row+1) + @spacingBetweenCells)
    @artboard.frame().setWidth((cell.width + @spacingBetweenCells) * Math.min(@colors.count(),@colorsPerRow) + @spacingBetweenCells)

    #Position Artboard
    @artboard.removeFromParent()
    bounds = @currentPage.contentBounds()

    @artboard.frame().setX(bounds.origin.x - @artboard.frame().width() - @spacingBetweenPalette)
    @artboard.frame().setY(bounds.origin.y)

    @currentPage.addLayers [@artboard]

  getColors: ->
    colors = []
    children = @artboard.children()
    for i in [0...children.count()]
      layer = children[i]
      colorDictionary = @command.valueForKey_onLayer_forPluginIdentifier(Cell::FULL_COLOR_TAG, layer, @pluginID )
      if colorDictionary
        log "->> PORQUI #{colorDictionary}"
        colr = ColorEncoder.dictionaryToMSColor(colorDictionary)
        log "NCOS...#{colr}"
        colors.push colr
    colors


  aliasForColor: (color) ->
    @command.valueForKey_onLayer_forPluginIdentifier(color.hexValue(), @artboard, @pluginID )
