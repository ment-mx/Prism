
class SASSFormatter extends FormatterBase
  id: ->
    "SASS"
  name: ->
    "SASS variables"
  format: ->
    "_colors.scss"

  formatText: (color, commented) ->
    formattedColor = '#' + color.hex
    sassVariableName = '$' + color.name.toLowerCase().trim().split(" ").join("-").replace("'", "").replace(".", "")
    "#{sassVariableName}: #{formattedColor};"
