Song = require('./song').Song

class Playlist
  constructor: (title) ->
    @set_title title
    @songs = [
      new Song()
    ]

    @current_song_id = 0

  set_title: (new_title = "Default Playlist") ->
    @title = new_title.toString()

  # song id management
  check_song_id: (n = @current_song_id) ->
    return false if @songs.length < 1
    n < @songs.length and n > -1

  get_current_song_id: ->
    @clamp_current_song_id()

  # clamps
  clamp_song_id: (n = @current_song_id, max = @songs.length - 1) ->
    return @current_song_id = -1 if @songs.length < 1
    Math.max(0, Math.min(n, max))

  clamp_current_song_id: (n = @current_song_id) ->
    @current_song_id = @clamp_song_id n

  # song navigation
  goto_song: (n = @current_song_id) ->
    @clamp_current_song_id n
    @get_current_song()

  next_song: ->
    @goto_song(@current_song_id + 1)
    @get_current_song()

  previous_song: ->
    @goto_song(@current_song_id - 1)
    @get_current_song()

  # song retrieval
  get_song: (n = @current_song_id) ->
    n = @clamp_song_id n
    return false if n == -1
    @songs[n]

  get_current_song: ->
    @get_song @current_song_id

  # song removal
  remove_current_song: () ->
    @remove_song @current_song_id

  remove_song: (n = @current_song_id) ->
    return false if not @check_song_id n
    @current_song_id = -1 if @songs.length == 1
    song = @songs.splice n, 1
    @clamp_current_song_id()
    song

  # song adding
  add_song: (n = @songs.length - 1, song = new Song()) ->
    n = @clamp_song_id n, @songs.length
    @songs.splice n, 0, song
    @clamp_current_song_id()
    song

module.exports = {
  Playlist: Playlist
}

