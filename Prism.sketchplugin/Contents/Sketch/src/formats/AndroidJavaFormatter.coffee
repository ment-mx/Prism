
class AndroidJavaFormatter extends FormatterBase
  id: ->
    "ANDROID"
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

