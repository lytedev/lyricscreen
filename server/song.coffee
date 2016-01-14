path = require 'path'
fs = require 'fs'
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
    @file = ""

    @setTitle title

    @currentMapKey = defaultMapKey

  setTitle: (title = "Default Song") ->
    @title = title.toString()
    @verses["@title"] = @title

  # map navigation
  gotoMap: (k = @currentMapKey) ->
    if @maps[k]?
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
    vid = 0
    for v in map.verses
      vcontent = @verses[v] or ""
      nvid = vid
      while map.isRepeatVerseId nvid
        nvid--
        vcontent = @verses[map.verses[nvid]] or ""
      a.push
        name: v
        content: vcontent
      vid++
    return a

  loadFromFile: (f) ->
    @maps = {}
    @verses = {}

    # load file, split off header
    contents = fs.readFileSync f, 'utf8'
    contents = contents.replace(/\r?\n\r?[\r?\n\r?]+/g, "\n\n").trim() # condense extra extra new lines
    data = contents.split /\r?\n\r?\r?\n\r?/

    # parse header
    header = data.splice(0, 1)[0].replace(/\#.*/g, '').trim() # delete all comments
    headerData = header.split /\n/

    # make sure header contains data
    if headerData.length < 1
      console.log "Failed to load song file " + f + " (could not parse song title from header)"

    # set title
    @setTitle headerData.splice(0, 1)[0].trim()

    # parse header for alternate maps
    for m in headerData
      index = m.indexOf ':'
      if index == -1
        continue
      mapKey = m.substring(0, index).trim()
      mapData = m.substring(index + 1).trim().split(/\s*,\s*/g)
      @addMap mapKey, new Map(mapKey, mapData)

    # parse remaining data as verses and default map
    gvid = 1
    defaultMapData = ["@title"]
    for v in data
      verseData = v.trim().replace(/\#.*/g, '').trim().split(/\n/) # delete all comments

      index = verseData[0].indexOf ':'
      index2 = verseData[0].indexOf '('
      index3 = verseData[0].indexOf ')'

      if index != -1
        verseTitle = verseData[0].substring(0, index)
        verseContent = verseData.splice(1).join("\n")
        defaultMapData.push verseTitle
        @verses[verseTitle] = verseContent
      else if index2 != -1 and index3 != -1
        verseTitle = verseData[0].substring(index2 + 1, index3)
        defaultMapData.push verseTitle
      else
        verseTitle = "Generated Verse " + gvid
        defaultMapData.push verseTitle
        @verses[verseTitle] = verseData.join "\n"
        gvid++


    defaultMapData.push "@blank"
    @addMap "@default", new Map("@default", defaultMapData)
    @file = f
    this

  @saveToFile: (f) ->
    content = @title + "\n"
    for map in @maps
      content += map.title + ": "
      for verse in map.verses
        content += verse + ", "
      content = content.substring(0, content.length - 2) + "\n"
    content += "\n"
    for verse of @verses
      content += verse + ":\n"
      content += @verses[verse]
      content += "\n\n"

    @file = f
    console.log content
    # fs.writeFileSync(f, content, 'utf8')

  @save: ->
    if @file == "" then return false
    @saveToFile(@file)

module.exports = {
  Song: Song
  songDir: "./data/songs/"
}

