###
  ColorFormatter:
  Used to transform a color into different color formats
  it also has the logic to display the color formatter dialog and some class methods to transform a MSColor
  to a color Dictionary that can be saved in a layer
###
class ColorFormatter

  # This is were formats are registred, the ID must be unique, the name is a human readable mini description, the format is used to use a custom file extension when saving colors to a file
  FORMATS: [
    { id: "HEX", name: "HEX CSS", format: "colors.css" }
    { id: "RGBA_CSS", name: "RGBA CSS", format: "colors.css" }
    { id: "SASS", name: "SASS variables", format: "_colors.scss" }
    { id: "UICOLOR_SWIFT", name: "UIColor (Swift)", format: "colors.swift" }
    { id: "UICOLOR_OBJC", name: "UIColor (Objective-C)", format: "colors.m" }
    { id: "ANDROID", name: "Android ARGB Color", format: "colors.java" }
  ]

  colorClassifier: new ColorClassifier()

  ###
    Shows the dialog to export the color dictionaries you provide
    returns a response code to know which button the user clicked.
  ###
  showDialogWithColorDictionaries: (colorDictionaries) ->
    #All format names as array
    names = @FORMATS.map (enc) -> enc.name

    accessory = NSPopUpButton.alloc().initWithFrame_pullsDown(NSMakeRect(0,0,400,25),false)
    accessory.addItemsWithTitles(names)
    accessory.selectItemAtIndex(0)

    alert = NSAlert.alloc().init()
    alert.setMessageText("Export colors")
    alert.setInformativeText("Select the color format:")
    alert.addButtonWithTitle('Save to file...')
    alert.addButtonWithTitle('Copy to clipboard')
    alert.addButtonWithTitle('Cancel')
    alert.setAccessoryView(accessory)

    responseCode = alert.runModal()
    selection = accessory.indexOfSelectedItem()

    lines = []
    for colorDictionary in colorDictionaries
      format = @FORMATS[selection].id
      lines.push @formatColorDictionary_withFormat_commented(colorDictionary,format,true)
    allColorsString = lines.join("\n")

    switch responseCode
      when 1000 # Save to file...
        log "Saving..."
        savePanel = NSSavePanel.savePanel()
        savePanel.setNameFieldStringValue(@FORMATS[selection].format)
        savePanel.setAllowsOtherFileTypes(true)
        savePanel.setExtensionHidden(false)

        if savePanel.runModal()
          filePath = savePanel.URL().path()
          fileString = NSString.stringWithString( allColorsString )
          fileString.writeToFile_atomically_encoding_error(filePath, true, NSUTF8StringEncoding, null)

      when 1001 # Copy to clipboard
        log "Copying..."
        pasteboard = NSPasteboard.generalPasteboard()
        pasteboard.declareTypes_owner( [ NSPasteboardTypeString], null )
        pasteboard.setString_forType( allColorsString, NSPasteboardTypeString )

    return responseCode


  ###
    Takes a color dictionary and a format and returns a formatted string
    The commented flag is used to add comments (like when we export colors)
    or removing them (like when we are populating the cell layers with color data)
  ###
  formatColorDictionary_withFormat_commented: (colorDictionary, format, commented) ->
    formatIDs = @FORMATS.map (enc) -> enc.id
    if format in formatIDs
      eval "this.format_#{format}(colorDictionary, commented);"
    else
      log "'#{format}' format not implemented."


  ###
    Takes a MSColor and a name or alias and packs it on a dictionary representation that can be then saved on a layer using the PluginCommand
  ###
  @colorToDictionary: (color, name) ->
    dictionary =
      name: name
      hex: color.hexValue()
      red: color.red()
      blue: color.blue()
      green: color.green()
      alpha: color.alpha()

  ###
    Takes a the dictionary representation from above and returns a new MSColor instance
  ###
  @dictionaryToColor: (dictionary) ->
    color = MSColor.colorWithRed_green_blue_alpha(dictionary.red, dictionary.green, dictionary.blue, dictionary.alpha)

  ###
  **************** FORMATS ****************
    HERE is when you have to do the implementation of the new format you want to add.

    all these methods must be prefixed with "format_" and then the format ID specified in he FORMATS constant
  ###

  format_HEX: (color, commented) ->
    formattedColor = '#' + color.hex
    if commented
      "#{formattedColor}; /* #{color.name} */"
    else
      formattedColor

  format_RGBA_CSS: (color, commented) ->
    alpha = if color.alpha < 1
      color.alpha.toFixed(2)
    else
      color.alpha
    formattedColor = "rgba(#{Math.round(color.red * 255)},#{Math.round(color.green * 255)},#{Math.round(color.blue * 255)},#{alpha});"
    if commented
      "#{formattedColor} /* #{color.name} */"
    else
      formattedColor

  format_ANDROID: (color, commented) ->
    formattedColor = "Color.argb(#{Math.round(color.alpha * 255)},#{Math.round(color.red * 255)},#{Math.round(color.green * 255)},#{Math.round(color.blue * 255)});"
    if commented
      "#{formattedColor} // #{color.name}"
    else
      formattedColor

  format_SASS: (color, commented) ->
    formattedColor = '#' + color.hex
    sassVariableName = '$' + color.name.toLowerCase().trim().split(" ").join("-")
    "#{sassVariableName}: #{formattedColor};"

  format_UICOLOR_SWIFT: (color, commented) ->
    red = Math.round(color.red * 100) / 100
    green = Math.round(color.green * 100) / 100
    blue = Math.round(color.blue * 100) / 100
    alpha = Math.round(color.alpha * 100) / 100
    formattedColor = "UIColor(red:#{red}, green:#{green}, blue:#{blue}, alpha:#{alpha})"
    if commented
      "#{formattedColor} // #{color.name}"
    else
      formattedColor


  format_UICOLOR_OBJC: (color, commented) ->
    red = Math.round(color.red * 100) / 100
    green = Math.round(color.green * 100) / 100
    blue = Math.round(color.blue * 100) / 100
    alpha = Math.round(color.alpha * 100) / 100
    formattedColor = "[UIColor colorWithRed:#{red} green:#{green} blue:#{blue} alpha:#{alpha}];"
    if commented
      "#{formattedColor} // #{color.name}"
    else
      formattedColor
