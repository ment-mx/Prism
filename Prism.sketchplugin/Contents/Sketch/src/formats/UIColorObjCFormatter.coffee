
class UIColorObjCFormatter extends FormatterBase
  id: ->
    "UICOLOR_OBJC"
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

