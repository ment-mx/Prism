class Cell

  CELL_LAYER_TAG: "cell-layer"
  FULL_COLOR_TAG: "rgba-color"
  TEXT_LAYER_TAG: "text-layer"

  colorEncoder: new ColorEncoder()
  colorClassifier: new ColorClassifier()

  constructor: (@layer, @context) ->
    @command = @context.command
    @pluginID = @context.plugin.identifier()

    @height = @layer.frame().height()
    @width = @layer.frame().width()

    children = @layer.children()

    @formatColorLayers = []
    for i in [0...children.count()]
      layer = children[i]
      switch "#{layer.name()}"
        when "Color" then @colorLayer = layer
        when "Name" then @nameLayer = layer
        when "Background" then @backgroundLayer = layer
        when "Transparent" then continue
        when "Cell" then continue
        when "Path" then continue
        else @formatColorLayers.push layer

  setX: (x) ->
    @layer.frame().setX(x)

  setY: (y) ->
    @layer.frame().setY(y)

  setColor_withAlias: (color, alias) ->
    #Set encodings for each encoding layer
    for layer in @formatColorLayers
      encodedColor = @colorEncoder.encodeColorWithEncoding(color, "#{layer.name()}")
      layer.stringValue = encodedColor if encodedColor

    #Set the color fill
    @colorLayer.style().fills().firstObject().setColor(color)
    #If there's an alias defined then use it, otherwise use the color classifier.
    finalName = alias ? @colorClassifier.classify(color.hexValue())

    #Assign the final name to the layers name and text.
    @nameLayer.stringValue = finalName
    @layer.setName(finalName)

    #Save the color hex value to the layer group and the name text layer
    @command.setValue_forKey_onLayer_forPluginIdentifier( ColorEncoder.msColorToDictionary(color) , @FULL_COLOR_TAG, @layer, @pluginID )
    @command.setValue_forKey_onLayer_forPluginIdentifier( color.hexValue()  , @CELL_LAYER_TAG, @layer, @pluginID )
    @command.setValue_forKey_onLayer_forPluginIdentifier( color.hexValue() , @TEXT_LAYER_TAG, @nameLayer, @pluginID )
