fs = require 'fs'

# setup data directories
dirs = [
  "./data"
  "./data/songs"
  "./data/playlists"
  "./data/backgrounds"
  "./data/config"
]

for d in dirs
  if !fs.existsSync d
    fs.mkdirSync d

# run the server
server = require './server'

