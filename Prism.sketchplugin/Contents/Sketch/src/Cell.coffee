class Cell extends Base

  CELL_LAYER_TAG: "cell-layer"
  TEXT_LAYER_TAG: "text-layer"

  colorFormatter: new ColorFormatter()

  constructor: (context, layer = null) ->
    super context, layer
    @layer = @template.getCell() unless @layer
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

  setColor_withName: (color, name) ->
    colorDictionary = ColorFormatter.colorToDictionary(color,name)

    #Set formats for each layer
    for layer in @formatColorLayers
      formattedColor = @colorFormatter.formatColorDictionary_withFormat_commented(colorDictionary, "#{layer.name()}",false)
      layer.stringValue = formattedColor if formattedColor

    #Set the color fill
    @colorLayer.style().fills().firstObject().setColor(color)

    #Assign the final name to the layers name and text.
    @nameLayer.stringValue = name
    @layer.setName(name)

    #Save the color hex value to the layer group and the name text layer
    @setValue_forKey(colorDictionary,@CELL_LAYER_TAG)
    @setValue_forKey_onLayer(colorDictionary.hex,@TEXT_LAYER_TAG,@nameLayer)
