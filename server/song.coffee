Map = require('./map').Map

class Song
  constructor: (title) ->
    @verses = {
      "@title": "@title"
      "Verse 1": "Verse 1"
      "@blank": ""
    }
    @maps = [
      new Map()
    ]

    @set_title title

    @current_map = @maps.length - 1

  set_title: (title = "Default Song") ->
    @title = title.toString()
    @verses["@title"] = @title

  check_verse_id: (n) ->
    return False if @verses.length < 1
    n < @verses.length and n > -1

  clamp_verse_id: (n) ->
    return @current_verse_id = -1 if @verses.length < 1
    Math.max(0, Math.min(n, @verses.length))

  clamp_current_verse_id: (n) ->
    @current_verse_id = @clamp_verse_id n

  goto_verse: (n) ->
    @clamp_current_verse_id n
    @get_current_verse()

  next_verse: ->
    @goto_verse(@current_verse_id + 1)
    @get_current_verse()

  previous_verse: ->
    @goto_verse(@current_verse_id - 1)
    @get_current_verse()

  get_verse: (n) ->
    n = @clamp_verse_id n
    return False if n == -1
    @verses[n]

  get_current_verse: ->
    @get_verse @current_verse_id

  remove_current_verse: () ->
    @remove_verse @current_verse_id

  remove_verse: (n) ->
    @current_verse_id = -1 if @verses.length == 1
    @verses.splice n, 1 if @check_verse_id n

  add_verse: (n = @verses.length - 1, verse = new verse()) ->
    @current_verse_id = 0 if @current_verse_id = -1
    n = @clamp_verse_id n
    @verses.splice n, 0, verse
    verse


module.exports = {
  Song: Song
}

