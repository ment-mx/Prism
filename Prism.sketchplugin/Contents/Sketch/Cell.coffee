class Cell

  constructor: (@layer) ->

  height: ->
    @layer.frame().height()

  width: ->
    @layer.frame().width()

  setColor: (newColor) ->
    log "sda"

  setColorName: (newColorName) ->
    log "--A #{newTitle}"
    #find name layer
    # set text to newColorName
