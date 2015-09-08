Map = require('./map').Map

class Song
  constructor: (title) ->
    @verses = {
      "@title": "@title"
      "Verse 1": "Verse 1"
      "@blank": ""
    }

    @maps = {
      "@default": new Map()
    }

    @set_title title

    @current_map_key = @maps.length - 1

  set_title: (title = "Default Song") ->
    @title = title.toString()
    @verses["@title"] = @title

  # map navigation
  goto_map: (k = @current_map_key) ->
    if k in @maps
      @current_map_key = k
      @get_current_map()
    else
      false

  # map retrieval
  get_map: (k = @current_map_key) ->
    return false if k not in @maps
    @maps[k]

  get_current_map: ->
    @get_map()

  # map removal
  remove_current_map: () ->
    @remove_map()

  remove_map: (k = @current_map_key) ->
    return false if k not in @maps
    map = @maps[k]
    delete @maps[k]
    map

  # map adding
  add_map: (k, map = new map()) ->
    return false if k in @maps
    @maps[k] = map

module.exports = {
  Song: Song
}

