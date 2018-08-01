
class SketchMeasureFormatter extends FormatterBase
  # Sketch Measure - Make it a fun to create spec for developers and teammates http://utom.design/measure/
  id: ->
    "SKETCHMESURE_JSON"
  name: ->
    "Sketch Measure (JSON)"
  format: ->
    "colors.json"

  supportClipboard: ->
    true

  exportAsString: (colorDictionaries) ->
    root = []
    for colorDictionary in colorDictionaries
      log colorDictionary
      obj =
         "name": "#{colorDictionary.name.trim()}"
         "color": @colorToDictionaryToJSON(colorDictionary)
      root.push obj

    JSON.stringify(root, undefined, 4)

  colorToDictionaryToJSON: (colorDictionary) ->
    json =
      r: Math.round(colorDictionary.red * 255)
      g: Math.round(colorDictionary.green * 255)
      b: Math.round(colorDictionary.blue * 255)
      a: (Math.round(colorDictionary.alpha * 100) / 100)
      "color-hex": "\##{colorDictionary.hex} " + "#{Math.round(colorDictionary.alpha * 100)}%",
      "argb-hex": "\##{helperHex(colorDictionary.alpha * 255) + colorDictionary.hex}",
      "css-rgba": "rgba(#{Math.round(colorDictionary.red * 255)},#{Math.round(colorDictionary.green * 255)},#{Math.round(colorDictionary.blue * 255)},#{Math.round(colorDictionary.alpha * 100) / 100})"
      "ui-color": "(r:#{parseFloat(colorDictionary.red).toFixed(3)} g:#{parseFloat(colorDictionary.green).toFixed(3)} b:#{parseFloat(colorDictionary.blue).toFixed(3)} a:#{parseFloat(colorDictionary.alpha).toFixed(3)})"

