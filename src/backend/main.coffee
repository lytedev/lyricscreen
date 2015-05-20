require 'coffee-script'

path = require 'path'
srcRoot = path.resolve __dirname + "/.."
console.log srcRoot

app = require 'app'

# Close app completely when all windows are closed
app.on 'window-all-closed', ->
  if process.platform != 'darwin'
    app.quit

# Error reporting
crashReporter = require 'crash-reporter'
crashReporter.start

# Create our main window
controlPanel = require './windows/control-panel'
app.on 'ready', ->
  controlPanel.open srcRoot,
    width: 640
    height: 360

