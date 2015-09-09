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
playlist = new Playlist()

# websocket endpoints
app.ws '/admin', (ws, req) ->
  ws.on 'message', (msg) ->
    console.log msg

  console.log 'socket', req.testing

app.ws '/moderator', (ws, req) ->
  ws.on 'message', (msg) ->
    console.log msg

  console.log 'socket', req.testing

app.ws '/display', (ws, req) ->
  ws.on 'message', (msg) ->
    console.log msg

  console.log 'socket', req.testing

# start listening
app.listen port

