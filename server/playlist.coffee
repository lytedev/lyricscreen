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

  check_song_id: (n = @current_song_id) ->
    return False if @songs.length < 1
    n < @songs.length and n > -1

  clamp_song_id: (n = @current_song_id) ->
    return @current_song_id = -1 if @songs.length < 1
    Math.max(0, Math.min(n, @songs.length - 1))

  clamp_current_song_id: (n = @current_song_id) ->
    @current_song_id = @clamp_song_id n

  goto_song: (n = @current_song_id) ->
    @clamp_current_song_id n
    @get_current_song()

  next_song: ->
    @goto_song(@current_song_id + 1)
    @get_current_song()

  previous_song: ->
    @goto_song(@current_song_id - 1)
    @get_current_song()

  get_song: (n = @current_song_id) ->
    n = @clamp_song_id n
    return False if n == -1
    @songs[n]

  get_current_song: ->
    @get_song @current_song_id

  remove_current_song: () ->
    @remove_song @current_song_id

  remove_song: (n = @current_song_id) ->
    return False if not @check_song_id n
    @current_song_id = -1 if @songs.length == 1
    console.log @current_song_id
    console.log @songs.length
    song = @songs.splice n, 1
    @clamp_current_song_id()
    console.log @songs.length
    console.log @current_song_id
    song

  add_song: (n = @songs.length - 1, song = new Song()) ->
    if @current_song_id == -1
      @current_song_id = 0
    n = @clamp_song_id n
    @songs.splice n, 0, song
    song

module.exports = {
  Playlist: Playlist
}

