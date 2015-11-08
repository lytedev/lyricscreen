path = require 'path'
fs = require 'fs'
Song = require('./song').Song
songDir = require('./song').songDir

playlistDir = "./data/playlists/"

class Playlist
  constructor: (title) ->
    @setTitle title
    @songs = [
      new Song()
    ]

    @currentSongId = 0

  setTitle: (newTitle = "Default Playlist") ->
    @title = newTitle.toString()

  # song id management
  checkSongId: (n = @currentSongId) ->
    return false if @songs.length < 1
    n < @songs.length and n > -1

  getCurrentSongId: ->
    @clampCurrentSongId()

  # clamps
  clampSongId: (n = @currentSongId, max = @songs.length - 1) ->
    return @currentSongId = -1 if @songs.length < 1
    Math.max(0, Math.min(n, max))

  clampCurrentSongId: (n = @currentSongId) ->
    @currentSongId = @clampSongId n

  # song navigation
  gotoSong: (n = @currentSongId) ->
    @clampCurrentSongId n
    @getCurrentSong()

  nextSong: ->
    @gotoSong(@currentSongId + 1)
    @getCurrentSong()

  previousSong: ->
    @gotoSong(@currentSongId - 1)
    @getCurrentSong()

  # song retrieval
  getSong: (n = @currentSongId) ->
    n = @clampSongId n
    return false if n == -1
    @songs[n]

  getCurrentSong: ->
    @getSong @currentSongId

  # verse retrieval
  getCurrentVerseContent: ->
    s = @getSong()
    return '' if not s? or !s
    m = s.getCurrentMap()
    return '' if not m? or !m
    cv = m.getCurrentVerse()
    return '' if not cv? or !cv
    if cv of s.verses
      return s.verses[cv]
    return ''

  # song removal
  removeCurrentSong: () ->
    @removeSong @currentSongId

  removeSong: (n = @currentSongId) ->
    return false if not @checkSongId n
    @currentSongId = -1 if @songs.length == 1
    song = @songs.splice n, 1
    @clampCurrentSongId()
    song

  # song adding
  addSong: (song = new Song(), n = @songs.length) ->
    n = @clampSongId n, @songs.length
    @songs.splice n, 0, song
    @clampCurrentSongId()
    song

  # navigation
  nextVerse: ->
    song = @getCurrentSong()
    if not song
      return false
    map = song.getCurrentMap()
    if not map
      return false

    if map.currentVerseId >= (map.verses.length - 1)
      @nextSong()
    else
      map.nextVerse()

  jumpToVerse: (n) ->
    song = @getCurrentSong()
    if not song
      return false
    map = song.getCurrentMap()
    if not map
      return false
    map.jumpToVerse(n)

  previousVerse: ->
    song = @getCurrentSong()
    if not song
      return false
    map = song.getCurrentMap()
    if not map
      return false

    if map.currentVerseId <= 0
      @previousSong()
    else
      map.previousVerse()

  loadFromFile: (f) ->
    @songs = []

    # load file, split off header
    contents = fs.readFileSync f, 'utf8'
    contents = contents.replace(/\#.*/g, '').trim()
    data = contents.split /\r?\n\r?\r?\n\r?/

    # make sure we have content and a header
    if data.length < 2
      console.log "Failed to load playlist file " + f + " (could not parse header/contents)"
      return false

    # parse header
    header = data[0]
    headerData = header.split /\n/

    # make sure header contains data
    if headerData.length < 1
      console.log "Failed to load playlist file " + f + " (could not parse playlist title from header)"

    # set title
    @setTitle headerData[0].trim()

    # parse contents for songs
    data.splice 0, 1
    data = data.join("\n").trim().split("\n")
    for l in data
      if l.trim() != ""
        @addSong new Song().loadFromFile(path.join(songDir, l + ".txt"))

    this



module.exports = {
  Playlist: Playlist
  playlistDir: playlistDir
}

