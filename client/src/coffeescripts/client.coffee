angular.module "LyricScreen", [
  "LyricScreen.controllers",
  "LyricScreen.services"
]


angular.module "LyricScreen.controllers", []
angular.module "LyricScreen.services", []


angular.module("LyricScreen.controllers").controller "LyricScreenCtrl", ($scope, $timeout, LyricScreenService) ->

  LyricScreenService.addMessageHandler (msg) ->
    if msg.type == "state"
      $scope.setState msg.data

  $scope.nextVerse = ->
    LyricScreenService.send type: "next verse"

  $scope.previousVerse = ->
    LyricScreenService.send type: "previous verse"

  $scope.setState = (data) ->
    return false if not data? or !data
    $scope.state = data
    $scope.slides = $scope.getCurrentSlides()

  # helpers for getting specific state data
  $scope.getCurrentSongId = ->
    p = $scope.getCurrentPlaylist()
    return false if not p? or !p
    p.currentSongId

  $scope.getCurrentSong = ->
    p = $scope.getCurrentPlaylist()
    return false if not p? or not p.songs?
    csid = $scope.getCurrentSongId()
    return false if csid == -1 or p.songs.length < 1
    p.songs[csid]

  $scope.getCurrentVerseId = ->
    s = $scope.getCurrentSong()
    return false if not s? or !s
    s.maps[s.currentMapKey].currentVerseId

  $scope.getCurrentPlaylist = ->
    return false if not $scope.state? or !$scope.state
    $scope.state.playlists[$scope.state.currentPlaylistKey]

  $scope.getCurrentSongMap = ->
    s = $scope.getCurrentSong()
    return false if not s? or !s
    return false if not s.maps? or !s.maps
    s.maps[s.currentMapKey]

  $scope.getCurrentSlides = ->
    s = $scope.getCurrentSong()
    return false if not s? or !s
    m = $scope.getCurrentSongMap()
    return false if not m? or !m
    slides = []
    i = 0
    for v in m.verses
      verseData =
        "title": v
        "contents": ""
        "active": i == m.currentVerseId
      if v in s.verses
        console.log s.verses[v]
        verseData.contents = s.verses[v]
      slides.push verseData
      i++
    return slides

angular.module("LyricScreen.services").service "LyricScreenService", ($q, $rootScope) ->
  Service = {}
  Service.messageHandlers = []
  socket = {}
  deferred = $q.defer()

  Service.send = (msg) ->
    socket.send JSON.stringify msg

  startListener = ->
    socket = new WebSocket "ws://" + window.location.host + "/admin"

    # when we connect, send an initial state request
    socket.addEventListener "open", (e) ->
      Service.send type: "get state"

    socket.addEventListener "message", (msg) ->
      deferred.notify getMessage msg.data

  Service.receive = ->
    deferred.promise

  getMessage = (data) ->
    try
      return JSON.parse data
    catch e
      console.log "Failed to parse incoming WebSocket message", e, data
      return false

  Service.addMessageHandler = (handler) ->
    Service.messageHandlers.push handler

  Service.receive().then null, null, (res) ->
    return false if not res? or !res
    for handler in Service.messageHandlers
      handler res

  startListener()

  Service.state = false

  return Service

