chai = require 'chai'
assert = chai.assert

Playlist = require("../server/playlist").Playlist
Song = require("../server/song").Song

playlist = new Playlist()

describe 'Default playlist object', ->
  it 'has one song', ->
    assert.equal playlist.songs.length, 1, "1 song in playlist"

  it 'has a title', ->
    assert.equal playlist.title, 'Default Playlist', "playlist has default title"

  it 'converts to JSON', ->
    json = JSON.stringify playlist
    assert.isString json, "JSON is a string"
    assert.ok json, "JSON is truthy"

  it 'has a valid @currentSongId', ->
    assert.ok playlist.getCurrentSong(), "current song is truthy"

  it 'lets us remove a song, emptying the playlist and properly setting @currentSongId', ->
    assert.ok playlist.removeCurrentSong(), "Removes a song"
    assert.isArray playlist.songs
    assert.equal playlist.songs.length, 0, "0 songs in playlist"
    assert.equal playlist.currentSongId, -1, "@currentSongId is -1"

  it 'lets us add two songs', ->
    song1 = new Song
    song2 = new Song "Another Title"

    assert.ok playlist.addSong(0, song1), "added song is truthy"
    assert.ok playlist.getCurrentSong(), "newly added song is set as current"
    assert.equal playlist.getCurrentSong().title, "Default Song", "song added first is current"
    assert.ok playlist.addSong(1, song2), "added song is truthy"
    assert.equal playlist.getCurrentSong().title, "Default Song", "song added first is still current"
    assert.equal playlist.songs.length, 2, "playlist length is 2"

  it 'lets us go to the next song', ->
    assert.equal playlist.getCurrentSong().title, "Default Song", "first song has default title"
    assert.equal playlist.nextSong().title, "Another Title", "next song has different title"
    assert.equal playlist.getCurrentSong().title, "Another Title", "second song has different title"

  it 'lets us add a song in the middle (at the @currentSongId)', ->
    song1 = new Song "Middle Song"
    assert.ok playlist.addSong(1, song1), "added song is truthy"
    assert.equal playlist.songs.length, 3, "playlist length is 3"
    assert.ok playlist.getCurrentSong(), "newly added song is set as current since it was inserted at the @currentSongId"
    assert.equal playlist.getCurrentSong().title, "Middle Song", "newly added song is current since it was inserted at the @currentSongId"

  it 'lets us add a song to the beginning (which will push all songs down)', ->
    song2 = new Song "New First Song"
    assert.ok playlist.addSong(0, song2), "added song is truthy"
    assert.equal playlist.songs.length, 4, "playlist length is 4"
    assert.equal playlist.getCurrentSong().title, "Default Song", "current song is now the very first song since the newly added song pushed the rest down"

  it 'lets us go to the previous song', ->
    assert.equal playlist.previousSong().title, "New First Song", "previous song is the new first song"
    assert.equal playlist.getCurrentSong().title, "New First Song", "current song is now the new first song"

  it 'lets us jump to the last song', ->
    assert.equal playlist.gotoSong(3).title, "Another Title", "jump to the fourth song"
    assert.equal playlist.getCurrentSong().title, "Another Title", "current song is now the second added song (last in playlist)"

  it 'lets us remove the first song, fixing our @currentSongId back 1', ->
    assert.equal playlist.getCurrentSongId(), 3
    assert.ok playlist.removeSong(0), "removes the first song"
    assert.equal playlist.getCurrentSongId(), 2
    assert.equal playlist.songs.length, 3, "playlist length is 3"
    assert.equal playlist.getCurrentSong().title, "Another Title", "current song is now the second added song (last in playlist)"

describe 'Default song', ->
  song = new Song()

  it 'has three verses', ->
    assert.equal Object.keys(song.verses).length, 3

    it 'a @title verse with the song\'s title as the content', ->
      assert.equal song.verses["@title"], "Default Song"

    it 'a default verse', ->
      assert.equal song.verses["Verse 1"], "Verse 1"

    it 'a @blank verse with no content', ->
      assert.equal song.verses["@blank"], ""

  it 'has one map', ->
    assert.equal Object.keys(song.maps).length, 1

  it 'has properly mapped verses', ->
    mappedVerses = song.getCurrentMappedVerses()
    assert.equal mappedVerses.length, 3

