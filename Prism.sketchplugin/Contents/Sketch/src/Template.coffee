###
  Template:

  Takes layer data from the Template file to copy it on your document. Cool right?
###
class Template
  #Template strings
  templateFileName: "Template.sketch"
  artboardName: "Prism Palette"
  cellName: "Cell"

  constructor: (@pluginURL) ->
    @app = NSApplication.sharedApplication()
    #Get template URL.
    url = @pluginURL.URLByAppendingPathComponent(@templateFileName)
    #If template doesn't exist, valid = false
    @document = MSDocument.alloc().init()
    unless @document.readFromURL_ofType_error(url , "com.bohemiancoding.sketch.drawing", nil)
      @app.displayDialog_withTitle("There was an error loading the Prism cell template file. Make sure a valid '#{@templateFileName}' file is inside the 'Prism.sketchplugin' folder.", "Oops!")

  openTemplateFile: ->
    workspace = NSWorkspace.sharedWorkspace()
    url = @pluginURL.URLByAppendingPathComponent(@templateFileName)
    workspace.openURL(url)

  getCell: ->
    @getLayerByName(@cellName)

  getArtboard: ->
    @getLayerByName(@artboardName)

  getLayerByName: (name) ->
    layers = @document.currentPage().children()
    for i in [0...layers.count()]
      layer = layers[i]
      if "#{layer.name()}" == name
        return layer.copy()
    @app.displayDialog_withTitle("Couln't find the layer named #{name} in the Template file.", "Cannot generate the palette")
    return null
