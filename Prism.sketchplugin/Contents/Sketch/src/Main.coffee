#Main...
generatePalette = (context) ->
  log "Generating..."
  palette = new Palette(context)
  palette.generate()

colorNameChanged = (context) ->
  log "Alias..."

  textLayer = context.actionContext.layer
  artboard = textLayer.parentArtboard()
  newText = context.actionContext.new

  pluginID = context.plugin.identifier()

  colorValue = context.command.valueForKey_onLayer_forPluginIdentifier( Cell::TEXT_LAYER_TAG , textLayer, pluginID )
  isArtboard = context.command.valueForKey_onLayer_forPluginIdentifier( Palette::ARTBOARD_TAG , artboard, pluginID )

  return unless colorValue && isArtboard

  finalName = if "#{newText}" != "-"
    #Save alias
    log "Saving alias: #{newText} for color: #{colorValue}."
    log "---> #{artboard} or #{ pluginID}"
    context.command.setValue_forKey_onLayer_forPluginIdentifier(newText, colorValue, artboard, pluginID )
    newText
  else
    #Remove Alias
    log "Removing alias for color: #{colorValue}."
    context.command.setValue_forKey_onLayer_forPluginIdentifier(null, colorValue, artboard, pluginID )
    colorClassifier = new ColorClassifier()
    colorClassifier.classify(colorValue)

  #Affect other layers in the palette
  children = artboard.children()
  for i in [0...children.count()]
    layer = children[i]
    if context.command.valueForKey_onLayer_forPluginIdentifier( Cell::CELL_LAYER_TAG , layer, pluginID ) == colorValue
      layer.setName(finalName)
    if context.command.valueForKey_onLayer_forPluginIdentifier( Cell::TEXT_LAYER_TAG , layer, pluginID ) == colorValue
      layer.stringValue = finalName


exportSelected = (context) ->
  log "Exporting Colors..."
  selectedLayers = context.document.selectedLayers
  log selectedLayers
  #for selection in selections

exportAll = (context) ->
  log "exporting..."
  palette = new Palette(context)
  allColors = palette.getColors()
  log "-->+++++ #{allColors}"

  colorEncoder = new ColorEncoder()
  response = colorEncoder.displayEncodingSelectionDialog()

  colorsString = colorEncoder.nsStringFromColors_withEncoding(allColors, response.encoding)
  log "--> #{colorsString}"
  switch response.code
    when 1000 # Save to file...
      log "Saving..."
      savePanel = NSSavePanel.savePanel();
      savePanel.setNameFieldStringValue("colors.txt");
      #savePanel.setAllowsOtherFileTypes(false);
      savePanel.setExtensionHidden(false);

      if savePanel.runModal()
        filePath = savePanel.URL().path()
        fileString = NSString.stringWithString( colorsString )
        fileString.writeToFile_atomically_encoding_error(filePath, true, NSUTF8StringEncoding, null)
    when 1001 # Copy to clipboard
      log "Copying..."
      pasteboard = NSPasteboard.generalPasteboard()
      pasteboard.declareTypes_owner( [ NSPasteboardTypeString], null )
      pasteboard.setString_forType( colorsString, NSPasteboardTypeString )
