BrowserWindow = require 'browser-window'

controlPanel = null
module.exports =
  open: (srcRoot, properties) ->
    controlPanel = new BrowserWindow properties
    controlPanel.loadUrl 'file://' + srcRoot + '/client/build/index.html'

    controlPanel.on 'close', ->
      controlPanel = null

