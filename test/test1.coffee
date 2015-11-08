chai = require 'chai'
assert = chai.assert

Playlist = require("../server/playlist").Playlist
Song = require("../server/song").Song

describe 'Default playlist object', ->
  playlist = new Playlist()

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

    assert.ok playlist.addSong(song1, 0), "added song is truthy"
    assert.ok playlist.getCurrentSong(), "newly added song is set as current"
    assert.equal playlist.getCurrentSong().title, "Default Song", "song added first is current"
    assert.ok playlist.addSong(song2, 1), "added song is truthy"
    assert.equal playlist.getCurrentSong().title, "Default Song", "song added first is still current"
    assert.equal playlist.songs.length, 2, "playlist length is 2"

  it 'lets us go to the next song', ->
    assert.equal playlist.getCurrentSong().title, "Default Song", "first song has default title"
    assert.equal playlist.nextSong().title, "Another Title", "next song has different title"
    assert.equal playlist.getCurrentSong().title, "Another Title", "second song has different title"

  it 'lets us add a song in the middle (at the @currentSongId)', ->
    song1 = new Song "Middle Song"
    assert.ok playlist.addSong(song1, 1), "added song is truthy"
    assert.equal playlist.songs.length, 3, "playlist length is 3"
    assert.ok playlist.getCurrentSong(), "newly added song is set as current since it was inserted at the @currentSongId"
    assert.equal playlist.getCurrentSong().title, "Middle Song", "newly added song is current since it was inserted at the @currentSongId"

  it 'lets us add a song to the beginning (which will push all songs down)', ->
    song2 = new Song "New First Song"
    assert.ok playlist.addSong(song2, 0), "added song is truthy"
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

  it 'lets us remove all the songs, becoming an empty playlist', ->
    assert.ok playlist.removeSong(0), "removes the first song"
    assert.ok playlist.removeSong(0), "removes the first song"
    assert.ok playlist.removeSong(0), "removes the first song"
    assert.equal playlist.songs.length, 0, "playlist length is 0"

describe 'Playlist loaded from file', ->
  playlist = new Playlist().loadFromFile "./data/playlists/test.txt"
  song = playlist.getCurrentSong()

  it 'can load header data', ->
    assert.equal playlist.title, "Default Playlist from File"

  it 'has the right number of songs', ->
    assert.equal playlist.songs.length, 3

  it 'loads the correct songs as specified in the playlist file', ->
    assert.equal playlist.getCurrentSong().title, "Default Test Song 1"
    assert.equal Object.keys(playlist.getCurrentSong().verses).length, 4
    playlist.nextSong()
    assert.equal playlist.getCurrentSong().title, "Default Test Song 2"
    playlist.nextSong()
    assert.equal playlist.getCurrentSong().title, "Default Test Song 1"

  it 'loads alternate maps for the songs', ->
    assert.equal Object.keys(playlist.getCurrentSong().maps).length, 2
    playlist.getCurrentSong().gotoMap "Alternate Mapping"
    assert.equal playlist.getCurrentSong().getCurrentMap().title, "Alternate Mapping"

  it 'handles repeat and missing map keys', ->
    song = playlist.getCurrentSong()
    verses = song.getCurrentMappedVerses()
    assert.equal verses[5].name, "Empty because this key doesn't exist"
    assert.equal verses[5].content, ""
    assert.equal verses[0].name, "Second Verse"
    assert.equal verses[0].content, "This is the second test verse\nIn the second test song"
    assert.equal verses[2].name, "Repeat"
    assert.equal verses[2].content, "This is the first test verse\nIn the first test song"

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

