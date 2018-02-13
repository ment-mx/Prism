
class RGBACSSFormatter extends FormatterBase
  id: ->
    "RGBA_CSS"
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

