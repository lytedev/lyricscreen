express = require 'express'
ws = require 'express-ws'
http = require 'http'
path = require 'path'

app = express()

default_port = 3000

port = default_port

http_server = http.createServer app
websocket = ws app


# host the client files
app.use express.static path.normalize path.join __dirname, "../client/build"

Playlist = require('./playlist').Playlist
state =
  playlists:
    default: new Playlist()
  currentPlaylistKey: 'default'

state.playlists.default.addSong()

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

      if data.type == "get state"
        return wsSendObject ws, "state", state, addedData

      if data.type == "previous verse"
        state.playlists[state.currentPlaylistKey].previousVerse()
        return wsSendObject ws, "state", state, addedData

      if data.type == "next verse"
        state.playlists[state.currentPlaylistKey].nextVerse()
        return wsSendObject ws, "state", state, addedData

    catch e
      console.log "Bad WebSocket Message:", msg, e

  console.log "Connected Admin Clients:", websocket.getWss('/admin').clients.length

app.ws '/moderator', (ws, req) ->
  ws.on 'message', (msg) ->
    console.log msg

  console.log 'Connection: moderator socket'

app.ws '/display', (ws, req) ->
  ws.on 'message', (msg) ->
    console.log msg

  console.log 'Connection: display socket'

console.log "Started listening on 0.0.0.0:" + port

# start listening
app.listen port

