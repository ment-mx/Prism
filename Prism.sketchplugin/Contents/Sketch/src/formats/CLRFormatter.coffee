
class CLRFormatter extends FormatterBase
  # https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/DrawColor/Concepts/AboutColorLists.html
  id: ->
    "CLR"
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

