Map = require('./map').Map

class Song
  constructor: (title) ->
    defaultMapKey = "@default"

    @verses = {
      "@title": "@title"
      "Verse 1": "Verse 1"
      "@blank": ""
    }

    @maps = {}
    @addMap defaultMapKey

    @setTitle title

    @currentMapKey = defaultMapKey

  setTitle: (title = "Default Song") ->
    @title = title.toString()
    @verses["@title"] = @title

  # map navigation
  gotoMap: (k = @currentMapKey) ->
    if not @maps[k]?
      @currentMapKey = k
      @getCurrentMap()
    else
      false

  # map retrieval
  getMap: (k = @currentMapKey) ->
    if not @maps[k]?
      return false
    @maps[k]

  getCurrentMap: ->
    @getMap()

  # map removal
  removeCurrentMap: () ->
    @removeMap()

  removeMap: (k = @currentMapKey) ->
    if not @maps[k]?
      return false
    map = @maps[k]
    delete @maps[k]
    map

  # map adding
  addMap: (k, map = new Map()) ->
    if @maps[k]?
      return false
    @maps[k] = map

  # verse mapping
  getCurrentMappedVerses: ->
    map = @getCurrentMap()
    if map == false
      return false
    a = []
    for v in map.verses
      a.push
        name: v
        content: @verses[v]
    return a

module.exports = {
  Song: Song
}

