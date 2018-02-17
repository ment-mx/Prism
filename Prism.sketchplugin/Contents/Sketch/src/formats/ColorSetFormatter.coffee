
class ColorSetFormatter extends FormatterBase
  # Asset Catalog Format Reference: Named Color Type https://developer.apple.com/library/content/documentation/Xcode/Reference/xcode_ref-Asset_Catalog_Format/Named_Color.html
  # Asset catalog colors on Xcode 9 – Zeplin Gazette https://blog.zeplin.io/asset-catalog-colors-on-xcode-9-c4fdccc0381a
  id: ->
    "COLORSET"
  name: ->
    "Color set (Xcode named color)"

  type: ->
    @constructor.EXPORT_TYPE_FILES

  supportClipboard: ->
    false

  exportAsFile: (colorDictionaries, url) ->
    manager = NSFileManager.defaultManager()
    for colorDictionary in colorDictionaries
      obj = @contentsJSON(colorDictionary)
      name = colorDictionary.name.toLowerCase().trim().split(" ").join("_")
      fileName = "#{name}.colorset"
      colorsetURL = url.URLByAppendingPathComponent(fileName)
      manager.createDirectoryAtPath_withIntermediateDirectories_attributes_error(
        colorsetURL.path(),
        true,
        null,
        null
      )
      path = colorsetURL.path()
      fileString = NSString.stringWithString(JSON.stringify(obj, null, 4))
      fileString.writeToFile_atomically_encoding_error(
        "#{path}/Contents.json",
        true,
        NSUTF8StringEncoding,
        null
      )

  contentsJSON: (colorDictionary) ->
    c = @colorObject(colorDictionary)
    obj =
      info:
        version: 1
        author: "com.ment.sketch.prism"
      colors: [c]

  colorObject: (colorDictionary) ->
    color =
      "color-space": "display-p3"
      components: @colorComponents(colorDictionary)

    obj =
      idiom: "universal"
      color: color

  colorComponents: (colorDictionary) ->
    obj =
      red: parseFloat(colorDictionary.red).toFixed(3)
      green: parseFloat(colorDictionary.green).toFixed(3)
      blue: parseFloat(colorDictionary.blue).toFixed(3)
      alpha: parseFloat(colorDictionary.alpha).toFixed(3)