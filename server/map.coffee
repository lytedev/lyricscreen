class Map
  constructor: () ->
    @title = "Default Map"
    @verses = [
      "@title"
      "Verse 1"
      "@blank"
    ]

    @currentVerseId = 0

  clampVerseId: (n = @currentVerseId, max = @verses.length - 1) ->
    return -1 if @verses.length < 1
    Math.max(0, Math.min(n, max))

  clampCurrentVerseId: ->
    @currentVerseId = @clampVerseId()

  nextVerse: ->
    @currentVerseId++
    @clampCurrentVerseId()

  previousVerse: ->
    @currentVerseId--
    @clampCurrentVerseId()

module.exports = {
  Map: Map
}

