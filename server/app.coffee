path = require 'path'
express = require 'express'
http = require 'http'

app = express()

http_server = http.createServer app

http_server.listen 8000

app.use express.static path.normalize path.join __dirname, "../public/build"
