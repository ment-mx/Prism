
class UIColorSwiftFormatter extends FormatterBase
  id: ->
    "UICOLOR_SWIFT"
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
