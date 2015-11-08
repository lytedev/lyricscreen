express = require 'express'
ws = require 'express-ws'
http = require 'http'
path = require 'path'
yaml = require 'js-yaml'
fs = require 'fs'

app = express()

default_port = 3000

port = default_port
clientSourceDir = "../client/build"

http_server = http.createServer app
websocket = ws app

# allow really hackish friendly urls
app.use (req, res, next) ->
  if req.path.indexOf('.') == -1
    file = clientSourceDir.substring(1) + req.path + '.html'
    fs.exists file, (exists) ->
      if exists
        req.url += '.html'
      next()
  else
    next()
# host the client files
app.use express.static path.normalize path.join __dirname, clientSourceDir

Song = require('./song').Song
Playlist = require('./playlist').Playlist
playlistDir = require('./playlist').playlistDir
state =
  frozen: false
  blank: false
  playlists:
    default: new Playlist()
  currentPlaylistKey: 'default'

defaultPlaylistFile = path.join(playlistDir, "default.txt")
console.log defaultPlaylistFile
if fs.existsSync(defaultPlaylistFile)
  console.log "Loading default playlist..."
  state.playlists.default = new Playlist().loadFromFile(defaultPlaylistFile)
  console.log JSON.stringify state.playlists.default, null, "  "
state.playlists.default.addSong(new Song("Song 2"))

wsSendObject = (ws, type, obj, addedData) ->
  time = new Date()
  if not obj?
    obj = false
  message =
    type: type
    data: obj
    time: time
    timeString: time.toLocaleTimeString()
  for k, n of addedData
    message[k] = n
  return ws.send JSON.stringify message

# websocket endpoints
app.ws '/admin', (ws, req) ->
  ws.on 'message', (msg) ->
    try
      data = JSON.parse msg

      addedData = {}
      if data.message_id?
        addedData.message_id = data.message_id

      if data.type == "get display"
        wsSendObject ws, "display", state.playlists[state.currentPlaylistKey].getCurrentVerseContent()

      if data.type == "get state"
        wsSendObject ws, "state", state

      if data.type == "previous verse"
        state.playlists[state.currentPlaylistKey].previousVerse()
        broadcastState()

      if data.type == "next verse"
        state.playlists[state.currentPlaylistKey].nextVerse()
        broadcastState()

      if data.type == "previous song"
        state.playlists[state.currentPlaylistKey].previousSong()
        broadcastState()

      if data.type == "next song"
        state.playlists[state.currentPlaylistKey].nextSong()
        broadcastState()

      if data.type == "toggle frozen"
        state.frozen = !state.frozen
        broadcastState()

      if data.type == "toggle blank"
        state.blank = !state.blank
        broadcastState()

      if data.type == "jump to verse"
        state.playlists[state.currentPlaylistKey].jumpToVerse(data.verse)
        broadcastState()

    catch e
      console.log "Bad WebSocket Message:", msg, e

  broadcastState = ->
    for c in websocket.getWss('/admin').clients
      wsSendObject c, "state", state
    broadcastDisplay()

  broadcastDisplay = ->
    return false if state.frozen
    if state.blank
      for c in websocket.getWss('/admin').clients
        wsSendObject c, "display", ""
      for c in websocket.getWss('/display').clients
        wsSendObject c, "display", ""
      return ''
    for c in websocket.getWss('/admin').clients
      wsSendObject c, "display", state.playlists[state.currentPlaylistKey].getCurrentVerseContent()
    for c in websocket.getWss('/display').clients
      wsSendObject c, "display", state.playlists[state.currentPlaylistKey].getCurrentVerseContent()

  console.log "Connected Admin Clients:", websocket.getWss('/admin').clients.length

app.ws '/moderator', (ws, req) ->
  ws.on 'message', (msg) ->
    console.log msg

  console.log 'Connection: moderator socket'

app.ws '/display', (ws, req) ->
  ws.on 'message', (msg) ->
    console.log msg

#   console.log 'Connection: display socket'

console.log "Started listening on 0.0.0.0:" + port

# start listening
app.listen port

module.exports = {
  app
  default_port
  port
  clientSourceDir
  http_server
  websocket
}

