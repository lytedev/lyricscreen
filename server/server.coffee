express = require 'express'
ws = require 'express-ws'
path = require 'path'
fs = require 'fs'

app = express()

default_port = 3000

port = default_port
clientSourceDir = "../client/build"

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
  frozenIndex: ["", -1, "", -1]
  blank: false
  playlists:
    default: new Playlist()
    secondary: new Playlist()
  currentPlaylistKey: 'default'

state.playlists.default.addSong(new Song("Song 2"))

defaultPlaylistFile = path.join(playlistDir, "default.txt")
if fs.existsSync(defaultPlaylistFile)
  console.log "Loading default playlist..."
  state.playlists.default = new Playlist().loadFromFile(defaultPlaylistFile)

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
        if state.frozen
          state.frozenIndex = [
            state.currentPlaylistKey
            state.playlists[state.currentPlaylistKey].currentSongId
            state.playlists[state.currentPlaylistKey].getCurrentSong().currentMapKey
            state.playlists[state.currentPlaylistKey].getCurrentSong().getCurrentMap().currentVerseId
          ]
        else
          state.frozenIndex = -1
        broadcastState()

      if data.type == "toggle blank"
        state.blank = !state.blank
        broadcastState()

      if data.type == "jump to verse"
        state.playlists[state.currentPlaylistKey].jumpToVerse(data.verse)
        broadcastState()

      if data.type == "reload current playlist"
        p = state.playlists[state.currentPlaylistKey]
        curSong = p.currentSongId
        curMap = p.getCurrentSong().currentMapKey
        m = p.getCurrentSong().getCurrentMap()
        curVerse = m.currentVerseId
        state.playlists.default = new Playlist().loadFromFile(defaultPlaylistFile)
        p = state.playlists[state.currentPlaylistKey]
        p.gotoSong curSong
        p.getCurrentSong().gotoMap curMap
        p.getCurrentSong().getCurrentMap().jumpToVerse curVerse
        broadcastState()

      if data.type == "clear playlist"
        p = state.playlists[state.currentPlaylistKey]
        while p.getCurrentSong() != false
          p.removeCurrentSong()
        broadcastState()

      if data.type == "goto song"
        p = state.playlists[state.currentPlaylistKey]
        if not data.songId?
          wsSendObject ws, "goto song error",
            message: "No songId provided"
        if data.songId < 0 or data.songId >= p.songs.length
          wsSendObject ws, "goto song error",
            message: "Invalid songId"
        else
          p.gotoSong data.songId
          broadcastState()

      if data.type == "save song"
        p = state.playlists[state.currentPlaylistKey]
        if data.songId?
          # wait to check for invalid songId
        else # use the current songId
          data.songId = p.currentSongId
        if data.songId < 0 or data.songId >= p.songs.length
          wsSendObject ws, "save song error",
            message: "Invalid songId"
        else
          s = p.songs[data.songId]
          if data.filename?
            if not data.filename.match(/[A-Za-z1-90-_]+/)
              wsSendObject ws, "save song error",
                message: "Invalid filename"
            else
              file = path.join(songDir, data.filename)
              s.saveToFile(file)
              wsSendObject ws, "save song success",
                message: "Song saved as " + file
          else
            wsSendObject ws, "save song success",
              message: "Song saved to " + s.file
            s.save()

      if data.type == "save playlist"
        p = state.playlists[state.currentPlaylistKey]
        if data.filename?
          if not data.filename.match(/[A-Za-z1-90-_]+/)
            wsSendObject ws, "save playlist error",
              message: "Invalid filename"
          else
            file = path.join(playlistDir, data.filename)
            p.saveToFile(file)
            wsSendObject ws, "save playlist success",
              message: "Playlist saved as " + file
        else
          p.save()
          wsSendObject ws, "save playlist success",
            message: "Playlist saved to " + p.file

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
    console.log "Moderator Message:", msg

  console.log 'Connection: moderator socket'

app.ws '/display', (ws, req) ->
  ws.on 'message', (msg) ->
    console.log "Display Message:", msg

#   console.log 'Connection: display socket'

console.log "Started listening on 0.0.0.0:" + port

# start listening
app.listen port

module.exports = {
  app
  default_port
  port
  clientSourceDir
  websocket
}

