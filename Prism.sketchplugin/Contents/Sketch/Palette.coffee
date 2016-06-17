class Palette

  #Tags
  paletteTag: "palette"

  spacingBetweenPalette: 16 #The spacing between the palette and your artboards.
  spacingBetweenCells: 35

  colorsPerRow: 4

  constructor: (@context) ->
    #Syntatic sugar
    @document = @context.document
    @command = @context.command
    @currentPage = @context.document.currentPage()
    @colors =  @context.document.documentData().assets().primitiveColors()
    @pluginID = @context.plugin.identifier()

    @paletteArtboard = null

    layers = @currentPage.children()
    for i in [0...layers.count()]
      layer = layers[i]
      if @command.valueForKey_onLayer_forPluginIdentifier(@paletteTag, layer, @pluginID )
        log "FOUND Palette!"
        @paletteArtboard = layer

    #printing testing
    @document.showMessage("Palette generated!")


  generate: ->
    template = new Template(@context.plugin.url())

    unless @paletteArtboard
      log "New palette..."
      @paletteArtboard = template.getArtboard()
      @paletteArtboard.setName('Prism Palette')
      @currentPage.addLayers([@paletteArtboard])
      @command.setValue_forKey_onLayer_forPluginIdentifier(true, @paletteTag, @paletteArtboard, @pluginID )

    #Sizing Arboard
    rows = Math.ceil(@colors.count()/@colorsPerRow) #Number of rows

    cell = new Cell( template.getCell() )

    height = rows * (@spacingBetweenCells + cell.height())
    height += @spacingBetweenCells

    width = Math.min(@colorsPerRow,@colors.count()) * (@spacingBetweenCells + cell.width())
    width += @spacingBetweenCells

    @paletteArtboard.frame().setHeight(height)
    @paletteArtboard.frame().setWidth(width)

    for i in [0..rows]
      color = @colors[i]
      cell = new Cell( template.getCell() )
      cell.setColor(color)
      cell.setColorName("Ment")
      #width += cell.layer.frame().width()




  getCells: ->
    layers = (new Cell(layer) for layer in layers)

  aliasForColor: (color) ->
    @command.valueForKey_onLayer_forPluginIdentifier(color, @paletteArtboard, @pluginID )

  setColorAlias: (color, alias) ->
    @command.setValue_forKey_onLayer_forPluginIdentifier(alias, color, @paletteArtboard, @pluginID )

  removeColorAlias: (color) ->
    @command.setValue_forKey_onLayer_forPluginIdentifier(null, color, @paletteArtboard, @pluginID )
