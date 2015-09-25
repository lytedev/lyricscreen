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

  jumpToVerse: (n) ->
    @currentVerseId = n
    @clampCurrentVerseId()

  previousVerse: ->
    @currentVerseId--
    @clampCurrentVerseId()

  getCurrentVerse: ->
    return false if @verses.length < 1
    @clampCurrentVerseId()
    return @verses[@currentVerseId]

module.exports = {
  Map: Map
}

