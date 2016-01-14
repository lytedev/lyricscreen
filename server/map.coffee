class Map
  constructor: (title = false, verses = false) ->
    if !title
      @title = "Default Map"
    else
      @title = title

    if !verses
      @verses = [
        "@title"
        "Verse 1"
        "@blank"
      ]
    else
      @verses = verses

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
  gotoVerse: @jumpToVerse

  previousVerse: ->
    @currentVerseId--
    @clampCurrentVerseId()

  isRepeatVerse: (verse) ->
    verse.toString().toLowerCase() == "repeat"

  isRepeatVerseId: (vid) ->
    vid = @clampVerseId vid
    @isRepeatVerse(@verses[vid]) and vid > 0

  getCurrentVerse: ->
    return false if @verses.length < 1
    cvid = @clampCurrentVerseId()
    while @isRepeatVerseId cvid
      cvid--
    return @verses[cvid]

module.exports = {
  Map: Map
}

