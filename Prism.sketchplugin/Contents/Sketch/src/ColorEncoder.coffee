class ColorEncoder
  ENCODINGS: ["HEX", "RGBA_CSS"]

  displayEncodingSelectionDialog: ->
    selectedItemIndex = selectedItemIndex || 0

    accessory = NSComboBox.alloc().initWithFrame(NSMakeRect(0,0,400,25))
    accessory.addItemsWithObjectValues(@ENCODINGS)
    accessory.selectItemAtIndex(selectedItemIndex)

    alert = NSAlert.alloc().init()
    alert.setMessageText("Export colors")
    alert.setInformativeText("Select the color format:")
    alert.addButtonWithTitle('Save to file...')
    alert.addButtonWithTitle('Copy to clipboard')
    alert.addButtonWithTitle('Cancel')
    alert.setAccessoryView(accessory)

    responseCode = alert.runModal()
    sel = accessory.indexOfSelectedItem()

    response =
      code: responseCode
      encoding: @ENCODINGS[sel]

    return response

  encodeColorWithEncoding: (color, encoding) ->
    if encoding in @ENCODINGS
      return eval "this.encode#{encoding}(color);"
    else
      log "'#{encoding}' encoding not implemented."
      return null

  @msColorToDictionary: (color) ->
    dictionary =
      red: color.red()
      blue: color.blue()
      green: color.green()
      alpha: color.alpha()

  @dictionaryToMSColor: (dic) ->
    colr = MSColor.colorWithRed_green_blue_alpha(dic.red, dic.green, dic.blue, dic.alpha)

  nsStringFromColors_withEncoding: (colors, encoding) ->
    lines = []
    for c in colors
      lines.push @encodeColorWithEncoding(c,encoding)
    lines.join("\n")

  encodeHEX: (color) ->
    '#' + color.hexValue()

  encodeRGBA_CSS: (color) ->
    alpha = if color.alpha() < 1
      color.alpha().toFixed(2)
    else
      color.alpha()
    "rgba(#{Math.round(color.red() * 255)},#{Math.round(color.green() * 255)},#{Math.round(color.blue() * 255)},#{alpha})"

  encodeUIColorRGBASwift: (r,g,b,a) ->
    "UIColor(red:#{r/255}, green:#{g/255}, blue:#{b/255}, alpha:#{a/255})"
