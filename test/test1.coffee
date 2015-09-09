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

  it 'has a valid @current_song_id', ->
    assert.ok playlist.get_current_song(), "current song is truthy"

  it 'lets us remove a song, emptying the playlist and properly setting @current_song_id', ->
    assert.ok playlist.remove_current_song(), "Removes a song"
    assert.isArray playlist.songs
    assert.equal playlist.songs.length, 0, "0 songs in playlist"
    assert.equal playlist.current_song_id, -1, "@current_song_id is -1"

  it 'lets us add two songs', ->
    song1 = new Song
    song2 = new Song "Another Title"

    assert.ok playlist.add_song(0, song1), "added song is truthy"
    assert.ok playlist.get_current_song(), "newly added song is set as current"
    assert.equal playlist.get_current_song().title, "Default Song", "song added first is current"
    assert.ok playlist.add_song(1, song2), "added song is truthy"
    assert.equal playlist.get_current_song().title, "Default Song", "song added first is still current"
    assert.equal playlist.songs.length, 2, "playlist length is 2"

  it 'lets us go to the next song', ->
    assert.equal playlist.get_current_song().title, "Default Song", "first song has default title"
    assert.equal playlist.next_song().title, "Another Title", "next song has different title"
    assert.equal playlist.get_current_song().title, "Another Title", "second song has different title"

  it 'lets us add a song in the middle (at the @current_song_id)', ->
    song1 = new Song "Middle Song"
    assert.ok playlist.add_song(1, song1), "added song is truthy"
    assert.equal playlist.songs.length, 3, "playlist length is 3"
    assert.ok playlist.get_current_song(), "newly added song is set as current since it was inserted at the @current_song_id"
    assert.equal playlist.get_current_song().title, "Middle Song", "newly added song is current since it was inserted at the @current_song_id"

  it 'lets us add a song to the beginning (which will push all songs down)', ->
    song2 = new Song "New First Song"
    assert.ok playlist.add_song(0, song2), "added song is truthy"
    assert.equal playlist.songs.length, 4, "playlist length is 4"
    assert.equal playlist.get_current_song().title, "Default Song", "current song is now the very first song since the newly added song pushed the rest down"

  it 'lets us go to the previous song', ->
    assert.equal playlist.previous_song().title, "New First Song", "previous song is the new first song"
    assert.equal playlist.get_current_song().title, "New First Song", "current song is now the new first song"

  it 'lets us jump to the last song', ->
    assert.equal playlist.goto_song(3).title, "Another Title", "jump to the fourth song"
    assert.equal playlist.get_current_song().title, "Another Title", "current song is now the second added song (last in playlist)"

  it 'lets us remove the first song, fixing our @current_song_id back 1', ->
    assert.equal playlist.get_current_song_id(), 3
    assert.ok playlist.remove_song(0), "removes the first song"
    assert.equal playlist.get_current_song_id(), 2
    assert.equal playlist.songs.length, 3, "playlist length is 3"
    assert.equal playlist.get_current_song().title, "Another Title", "current song is now the second added song (last in playlist)"

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

