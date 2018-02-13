###
  ColorFormatter:
  Used to transform a color into different color formats
  it also has the logic to display the color formatter dialog and some class methods to transform a MSColor
  to a color Dictionary that can be saved in a layer
###
class ColorFormatter
  # This is were formats are registred,
  FORMATS: []

  FORMATS_BY_ID: []

  colorClassifier: new ColorClassifier()

  constructor: () ->
    ###
    **************** FORMATS ****************
      HERE is when you have to do the implementation of the new format you want to add.
    ###

    @FORMATS.push new HexFormatter()
    @FORMATS.push new RGBACSSFormatter()
    @FORMATS.push new SASSFormatter()
    @FORMATS.push new CLRFormatter()
    @FORMATS.push new UIColorSwiftFormatter()
    @FORMATS.push new UIColorObjCFormatter()
    @FORMATS.push new AndroidJavaFormatter()
    @FORMATS.push new AndroidXMLFormatter()

    for format in @FORMATS
      @FORMATS_BY_ID[format.id()] = format

  ###
    Shows the dialog to export the color dictionaries you provide
    returns a response code to know which button the user clicked.
  ###
  showDialogWithColorDictionaries: (colorDictionaries) ->
    #All format names as array
    names = @FORMATS.map (enc) -> enc.name()
    #All format types as array
    types = @FORMATS.map (enc) -> enc.type()

    accessory = NSPopUpButton.alloc().initWithFrame_pullsDown(NSMakeRect(0,0,400,25),false)
    accessory.addItemsWithTitles(names)
    accessory.selectItemAtIndex(0)

    alert = NSAlert.alloc().init()
    alert.setMessageText("Export colors")
    alert.setInformativeText("Select the color format:")
    alert.addButtonWithTitle('Save to file...')
    copyButton = alert.addButtonWithTitle('Copy to clipboard')
    alert.addButtonWithTitle('Cancel')
    alert.setAccessoryView(accessory)

    # add handler for enabling/disabling "Copy to clipboard" button
    accessory.setCOSJSTargetFunction((sender) =>
      selection = accessory.indexOfSelectedItem()
      obj = @FORMATS[selection]
      copyButton.setEnabled(obj.supportClipboard())
    )

    responseCode = alert.runModal()
    selection = accessory.indexOfSelectedItem()
    formatObj = @FORMATS[selection]

    switch responseCode
      when 1000 # Save to file...
        log "Saving..."
        switch formatObj.type()
          when FormatterBase.EXPORT_TYPE_FILE
            savePanel = NSSavePanel.savePanel()
            savePanel.setNameFieldStringValue(formatObj.format())
            savePanel.setAllowsOtherFileTypes(true)
            savePanel.setExtensionHidden(false)

            if savePanel.runModal()
              formatObj.exportAsFile(colorDictionaries, savePanel.URL())

          else
            log "Not implemented CLR"

      when 1001 # Copy to clipboard
        log "Copying..."
        allColorsString = formatObj.exportAsString(colorDictionaries)

        pasteboard = NSPasteboard.generalPasteboard()
        pasteboard.declareTypes_owner( [ NSPasteboardTypeString], null )
        pasteboard.setString_forType( allColorsString, NSPasteboardTypeString )

    return responseCode

  formatColorDictionary_withFormat_commented: (colorDictionary, format, commented) ->
    formatter = @FORMATS_BY_ID[format]
    formatter.formatText(colorDictionary, commented)

  ###
    Takes a MSColor and a name or alias and packs it on a dictionary representation that can be then saved on a layer using the PluginCommand
  ###
  @colorToDictionary: (color, name) ->
    dictionary =
      name: name
      hex: color.immutableModelObject().hexValue()
      red: color.red()
      blue: color.blue()
      green: color.green()
      alpha: color.alpha()

  ###
    Takes a the dictionary representation from above and returns a new MSColor instance
  ###
  @dictionaryToColor: (dictionary) ->
    color = MSColor.colorWithRed_green_blue_alpha(dictionary.red, dictionary.green, dictionary.blue, dictionary.alpha)