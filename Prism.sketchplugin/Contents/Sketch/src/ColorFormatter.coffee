###
  ColorFormatter:
  Used to transform a color into different color formats
  it also has the logic to display the color formatter dialog and some class methods to transform a MSColor
  to a color Dictionary that can be saved in a layer
###
class ColorFormatter

  # This is were formats are registred, the ID must be unique, the name is a human readable mini description, the format is used to use a custom file extension when saving colors to a file
  FORMATS: []

  colorClassifier: new ColorClassifier()

  constructor: () ->
    ###
    **************** FORMATS ****************
      HERE is when you have to do the implementation of the new format you want to add.

      all these methods must be prefixed with "format_" and then the format ID specified in he FORMATS constant
    ###

    @FORMATS.push new HexFormatter()
    @FORMATS.push new RGBACSSFormatter()
    @FORMATS.push new SASSFormatter()
    @FORMATS.push new CLRFormatter()
    @FORMATS.push new UIColorSwiftFormatter()
    @FORMATS.push new UIColorObjCFormatter()
    @FORMATS.push new AndroidJavaFormatter()
    @FORMATS.push new AndroidXMLFormatter()

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

  formatTextFromColorDictionary: (format, colorDictionaries) ->
    lines = []
    for colorDictionary in colorDictionaries
      lines.push @formatColorDictionary_withFormat_commented(colorDictionary,format,true)
    allColorsString = lines.join("\n")

  writeStringToFile: (filePath, string) ->
    fileString = NSString.stringWithString( string )
    fileString.writeToFile_atomically_encoding_error(filePath, true, NSUTF8StringEncoding, null)

  ###
    Takes a color dictionary and a format and returns a formatted string
    The commented flag is used to add comments (like when we export colors)
    or removing them (like when we are populating the cell layers with color data)
  ###
  formatColorDictionary_withFormat_commented: (colorDictionary, format, commented, url) ->
    formatIDs = @FORMATS.map (enc) -> enc.id
    if format in formatIDs
      eval "this.format_#{format}(colorDictionary, commented, url);"
    else
      log "'#{format}' format not implemented."


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




###
**************** FORMATS ****************
  HERE is when you have to do the implementation of the new format you want to add.
###

###
 FormatterBase

 Base class for each type of formatters. Template Pattern.
###
class FormatterBase
  EXPORT_TYPE_FILE: "file"
  EXPORT_TYPE_FILES: "files"

  ###
   name

   Uses format name on modal panel. Override this at Subclass.
  ###
  name: ->

  ###
   format

   Uses default file name when its saved. Override this at Subclass.
  ###
  format: ->

  ###
   type

   `EXPORT_TYPE_FILE` or `EXPORT_TYPE_FILES`. Override this at Subclass.
  ###
  type: ->
    @constructor.EXPORT_TYPE_FILE

  ###
   supportClipboard

   If format supports clipboard then returns `true`.
  ###
  supportClipboard: ->
    true

  ###
   formatText

   Converts a Color Dictionary to String. Override this at Subclass.
  ###
  formatText: (color, commented) ->

  ###
   formatTextFromColorDictionaries

   Converts Color Dictionaries to String. Override this at Subclass if needs.
  ###
  formatTextFromColorDictionaries: (colorDictionaries) ->
    lines = []
    for colorDictionary in colorDictionaries
      lines.push @formatText(colorDictionary,true)
    allColorsString = lines.join("\n")

  ###
   writeStringToFile

   Writes String type format as file. Override this at Subclass if needs.
  ###
  writeStringToFile: (filePath, string) ->
    fileString = NSString.stringWithString( string )
    fileString.writeToFile_atomically_encoding_error(filePath, true, NSUTF8StringEncoding, null)

  ###
   exportAsFile

   Writes format as file. Override this at Subclass if needs.
  ###
  exportAsFile: (colorDictionaries, url) ->
    text = @exportAsString(colorDictionaries)
    @writeStringToFile(url.path(), text)

  ###
   exportAsString

   Converts Color Dictionaries to String. Override this at Subclass if needs.
  ###
  exportAsString: (colorDictionaries) ->
    text = @formatTextFromColorDictionaries(colorDictionaries)

class HexFormatter extends FormatterBase
  name: ->
    "HEX CSS"
  format: ->
    "colors.css"

  formatText: (color, commented) ->
    formattedColor = '#' + color.hex
    if commented
      "#{formattedColor}; /* #{color.name} */"
    else
      formattedColor

class RGBACSSFormatter extends FormatterBase
  name: ->
    "RGBA CSS"
  format: ->
    "colors.css"

  formatText: (color, commented) ->
    alpha = if color.alpha < 1
      color.alpha.toFixed(2)
    else
      color.alpha
    formattedColor = "rgba(#{Math.round(color.red * 255)},#{Math.round(color.green * 255)},#{Math.round(color.blue * 255)},#{alpha});"
    if commented
      "#{formattedColor} /* #{color.name} */"
    else
      formattedColor

class SASSFormatter extends FormatterBase

  name: ->
    "SASS variables"
  format: ->
    "_colors.scss"

  formatText: (color, commented) ->
    formattedColor = '#' + color.hex
    sassVariableName = '$' + color.name.toLowerCase().trim().split(" ").join("-").replace("'", "")
    "#{sassVariableName}: #{formattedColor};"

class UIColorSwiftFormatter extends FormatterBase

  name: ->
    "UIColor (Swift)"
  format: ->
    "colors.m"

  formatText: (color, commented) ->
    red = Math.round(color.red * 100) / 100
    green = Math.round(color.green * 100) / 100
    blue = Math.round(color.blue * 100) / 100
    alpha = Math.round(color.alpha * 100) / 100
    formattedColor = "UIColor(red:#{red}, green:#{green}, blue:#{blue}, alpha:#{alpha})"
    if commented
      "#{formattedColor} // #{color.name}"
    else
      formattedColor

class UIColorObjCFormatter extends FormatterBase

  name: ->
    "UIColor (Objective-C)"
  format: ->
    "colors.m"

  formatText: (color, commented) ->
    red = Math.round(color.red * 100) / 100
    green = Math.round(color.green * 100) / 100
    blue = Math.round(color.blue * 100) / 100
    alpha = Math.round(color.alpha * 100) / 100
    formattedColor = "[UIColor colorWithRed:#{red} green:#{green} blue:#{blue} alpha:#{alpha}];"
    if commented
      "#{formattedColor} // #{color.name}"
    else
      formattedColor

class AndroidJavaFormatter extends FormatterBase

  name: ->
    "Android ARGB (Java code)"
  format: ->
    "colors.java"

  formatText: (color, commented) ->
    formattedColor = "Color.argb(#{Math.round(color.alpha * 255)},#{Math.round(color.red * 255)},#{Math.round(color.green * 255)},#{Math.round(color.blue * 255)});"
    if commented
      "#{formattedColor} // #{color.name}"
    else
      formattedColor

class AndroidXMLFormatter extends FormatterBase

  name: ->
    "Android ARGB (XML)"
  format: ->
    "colors.xml"

  formatText: (color, commented) ->
    formattedColor = "" + helperHex(color.alpha * 255) + color.hex
    xmlVariable = '<color name="' + color.name.toLowerCase().trim().split(" ").join("_") + '">#' + formattedColor + "</color>"
    xmlVariable

class CLRFormatter extends FormatterBase
  # https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/DrawColor/Concepts/AboutColorLists.html

  name: ->
    "CLR (Color Lists)"
  format: ->
    "colors.clr"

  supportClipboard: ->
    false

  exportAsFile: (colorDictionaries, url) ->
    colorList = NSColorList.alloc().initWithName("colors")
    for colorDictionary in colorDictionaries
      red = Math.round(colorDictionary.red * 100) / 100
      green = Math.round(colorDictionary.green * 100) / 100
      blue = Math.round(colorDictionary.blue * 100) / 100
      alpha = Math.round(colorDictionary.alpha * 100) / 100
      color = NSColor.colorWithSRGBRed_green_blue_alpha(red, green, blue, alpha)
      colorList.setColor_forKey(color, colorDictionary.name)

    colorList.writeToFile(url.path())