###
 Generate Palette

 Called when the user wants to generate a palette from its Document Colors
###
generatePalette = (context) ->
  log "Generating..."
  palette = new Palette(context)
  palette.generate()

###
 Color Name Changed

 Called when the user makes a change in any text layer. Used to add or remove new alias for colors.
###
colorNameChanged = (context) ->
  log "Color Name Changed..."
  textLayer = context.actionContext.layer
  artboard = textLayer.parentArtboard()
  newText = context.actionContext.new # The new value for the changed text layer
  pluginID = context.plugin.identifier() # Plugin ID for saving data

  #Be sure that text layer has a colorValue and its parent artboard is in fact the Prism Palette.
  colorValue = context.command.valueForKey_onLayer_forPluginIdentifier( Cell::TEXT_LAYER_TAG , textLayer, pluginID )
  inPalette = context.command.valueForKey_onLayer_forPluginIdentifier( Palette::ARTBOARD_TAG , artboard, pluginID )
  return unless colorValue && inPalette

  #If the new text is empty, remove the alias for that color value, otherwise save the alias
  if "#{newText}".trim() != ""
    #Save alias
    context.command.setValue_forKey_onLayer_forPluginIdentifier(newText, colorValue, artboard, pluginID )
  else
    #Remove Alias
    context.command.setValue_forKey_onLayer_forPluginIdentifier(null, colorValue, artboard, pluginID )

  #Load Palette and regenerate
  palette = new Palette(context,textLayer)
  palette.regenerate()

###
 Export All

 Called when the user wants to export all the colors in the palette (not in the Document Colors)
###
exportAll = (context) ->
  log "Export All..."
  palette = new Palette(context)
  colorDictionaries = palette.getColorsDictionaries()
  colorFormatter = new ColorFormatter()
  responseCode = colorFormatter.showDialogWithColorDictionaries(colorDictionaries)
  #Confirmation messages ;)
  switch responseCode
    when 1000 # Save to file...
      context.document.showMessage "Your colors were successfully saved!"
    when 1001 #Export
      context.document.showMessage "Copied to clipboard!"
###
 Export Selected

 Called when the user wants to export only the selected Cell Groups.
###
exportSelected = (context) ->
  log "Export Selected..."
  selectedLayers = context.selection

  #Alert if no layers were selected
  if selectedLayers.count() == 0
    NSApplication.sharedApplication().displayDialog_withTitle("No color cells were selected for export!", "Nothing selected")
    return

  #Get color data from selected layers
  palette = new Palette(context)
  colorDictionaries = palette.getColorsDictionariesFromLayers(selectedLayers)
  colorFormatter = new ColorFormatter()
  responseCode = colorFormatter.showDialogWithColorDictionaries(colorDictionaries)
  #Confirmation messages ;)
  switch responseCode
    when 1000 # Save to file...
      context.document.showMessage "Your colors were successfully saved!"
    when 1001 #Export
      context.document.showMessage "Copied to clipboard!"

###
 Open Template

 Called when the users wants to open the template file that all the cells are generated from.
###
openTemplate = (context) ->
  log "Open Template..."
  template = new Template( context.plugin.url() )
  template.openTemplateFile()
