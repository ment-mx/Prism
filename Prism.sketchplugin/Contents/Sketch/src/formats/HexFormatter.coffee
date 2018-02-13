class HexFormatter extends FormatterBase
  id: ->
    "HEX"
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
