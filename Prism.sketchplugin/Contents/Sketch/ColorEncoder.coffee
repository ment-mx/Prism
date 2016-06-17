class ColorEncoder
  encodings: ["UIColor", "UIColor", "UIColor", "UIColor", "UIColor", "UIColor"]
  #Color in HEX form #FFFFFF
  constructor: (@color) ->

  encodeColorWithEncoding: (color, encoding) ->
    if encoding in encodings
      call encoding
    else
      log "Encoding not implemented."

  encodeUIColorRGBASwift: (r,g,b,a) ->
    "UIColor(red:#{r/255}, green:#{g/255}, blue:#{b/255}, alpha:#{a/255})"

  encodeUIColorRGBAObjectiveC: (r,g,b,a) ->
    "UIColor(red:#{r/255}, green:#{g/255}, blue:#{b/255}, alpha:#{a/255})"
