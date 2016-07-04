class Base

  constructor: (@context, @layer = null) ->
    @command = @context.command
    @pluginID = @context.plugin.identifier()
    @template = new Template @context.plugin.url()

    @currentPage = if @layer
      log "SJAHDKAJSHD"
      @layer.parentPage()
    else
      @context.document.currentPage() if @context.document

  #Set and Get shurtcuts
  setValue_forKey: (value, key) ->
    @setValue_forKey_onLayer(value, key, @layer)

  valueForKey: (key) ->
    @valueForKey_onLayer(key, @layer)

  setValue_forKey_onLayer: (value, key ,layer) ->
    @command.setValue_forKey_onLayer_forPluginIdentifier(value,key,layer, @pluginID )

  valueForKey_onLayer: (key,layer) ->
    @command.valueForKey_onLayer_forPluginIdentifier(key, layer, @pluginID )


# Ale y Cass
