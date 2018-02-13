
###
 FormatterBase

 Base class for each type of formatters. Template Pattern.
 the ID must be unique, the name is a human readable mini description, the format is used to use a custom file extension when saving colors to a file
###
class FormatterBase
  @EXPORT_TYPE_FILE: "file"
  @EXPORT_TYPE_FILES: "files"

  ###
   id

   Override this at Subclass.
  ###
  id: ->

  ###
   name

   Uses format name on modal panel. Override this at Subclass.
  ###
  name: ->

  ###
   format

   Uses default file name when its saved. Override this at Subclass.
  ###
  format: ->

  ###
   type

   `EXPORT_TYPE_FILE` or `EXPORT_TYPE_FILES`. Override this at Subclass.
  ###
  type: ->
    @constructor.EXPORT_TYPE_FILE

  ###
   supportClipboard

   If format supports clipboard then returns `true`.
  ###
  supportClipboard: ->
    true

  ###
   formatText

   Converts a Color Dictionary to String. Override this at Subclass.
   The commented flag is used to add comments (like when we export colors)
   or removing them (like when we are populating the cell layers with color data)
  ###
  formatText: (color, commented) ->

  ###
   formatTextFromColorDictionaries

   Converts Color Dictionaries to String. Override this at Subclass if needs.
  ###
  formatTextFromColorDictionaries: (colorDictionaries) ->
    lines = []
    for colorDictionary in colorDictionaries
      lines.push @formatText(colorDictionary,true)
    allColorsString = lines.join("\n")

  ###
   writeStringToFile

   Writes String type format as file. Override this at Subclass if needs.
  ###
  writeStringToFile: (filePath, string) ->
    fileString = NSString.stringWithString( string )
    fileString.writeToFile_atomically_encoding_error(filePath, true, NSUTF8StringEncoding, null)

  ###
   exportAsFile

   Writes format as file. Override this at Subclass if needs.
  ###
  exportAsFile: (colorDictionaries, url) ->
    text = @exportAsString(colorDictionaries)
    @writeStringToFile(url.path(), text)

  ###
   exportAsString

   Converts Color Dictionaries to String. Override this at Subclass if needs.
  ###
  exportAsString: (colorDictionaries) ->
    text = @formatTextFromColorDictionaries(colorDictionaries)

