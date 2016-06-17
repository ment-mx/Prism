#Main...
generatePalette = (context) ->
  log "Generating..."
  palette = new Palette(context)
  palette.generate()

exportSelected = (context) ->
  log "Exporting Colors..."
  selections = context.selection
  #for selection in selections

exportAll = (context) ->
  log "exporting..."
