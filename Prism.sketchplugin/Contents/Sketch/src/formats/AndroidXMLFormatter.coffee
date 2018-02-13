
class AndroidXMLFormatter extends FormatterBase
  id: ->
    "ANDROID_XML"
  name: ->
    "Android ARGB (XML)"
  format: ->
    "colors.xml"

  formatText: (color, commented) ->
    formattedColor = "" + helperHex(color.alpha * 255) + color.hex
    xmlVariable = '<color name="' + color.name.toLowerCase().trim().split(" ").join("_") + '">#' + formattedColor + "</color>"
    xmlVariable
