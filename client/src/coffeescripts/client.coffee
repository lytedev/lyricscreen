angular.module "LyricScreen", [
  "LyricScreen.controllers",
  "LyricScreen.services"
]


angular.module "LyricScreen.controllers", []
angular.module "LyricScreen.services", []


angular.module("LyricScreen.controllers").controller "LyricScreenCtrl", ($scope, $timeout, LyricScreenService) ->
  $scope.display = ''

  LyricScreenService.addMessageHandler (msg) ->
    if msg.type == "state"
      $scope.setState msg.data

    if msg.type == "close"
      $scope.setState {}

    if msg.type == "display"
      $scope.display = msg.data

  $scope.nextSong = ->
    LyricScreenService.send type: "next song"

  $scope.previousSong = ->
    LyricScreenService.send type: "previous song"

  $scope.nextVerse = ->
    LyricScreenService.send type: "next verse"

  $scope.jumpToVerse = (n) ->
    LyricScreenService.send type: "jump to verse", verse: n

  $scope.previousVerse = ->
    LyricScreenService.send type: "previous verse"

  $scope.toggleFrozen = ->
    LyricScreenService.send type: "toggle frozen"

  $scope.toggleBlank = ->
    LyricScreenService.send type: "toggle blank"

  $scope.setState = (data) ->
    return false if not data? or !data
    if Object.keys(data).length == 0
      # handle the state update when we lose connection
      $scope.state = false
      $scope.slides = false
      $scope.display = ''
      $scope.$apply()
    else
      $scope.state = data
      $scope.slides = $scope.getCurrentSlides()

  # helpers for getting specific state data
  $scope.getCurrentSongId = ->
    p = $scope.getCurrentPlaylist()
    return false if not p? or !p
    p.currentSongId

  $scope.getLastSongId = ->
    p = $scope.getCurrentPlaylist()
    return false if not p? or !p
    p.songs.length - 1

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
    return false if not $scope.state.playlists?
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
        "mapVerseId": i
        "active": i == m.currentVerseId
      if v of s.verses
        verseData.contents = s.verses[v]
      else
      slides.push verseData
      i++
    return slides


angular.module("LyricScreen.services").service "LyricScreenService", ($q, $rootScope) ->
  Service = {}
  Service.messageHandlers = []
  socket = {}
  deferred = $q.defer()

  Service.send = (msg) ->
    if socket.readyState != 1
      console.log "Tried to send message while WebSocket wasn't ready.", msg
    else
      socket.send JSON.stringify msg

  startListener = ->
    socket = new WebSocket "ws://" + window.location.host + "/admin"

    # when we connect, send an initial state request
    socket.addEventListener "open", (e) ->
      console.log "Connected to WebSocket server. Requesting initial state..."
      Service.send type: "get state"
      Service.send type: "get display"

    socket.addEventListener "message", (msg) ->
      deferred.notify getMessage msg.data

    socket.addEventListener "error", (e) ->
      console.log "WebSocket error encountered."

    socket.addEventListener "close", (e) ->
      for handler in Service.messageHandlers
        handler type: "close"
      console.log "WebSocket closed. Reconnecting in 5 seconds... (Code/Reason: " +
        e.code + if e.reason != "" then " - " + e.reason else "" + ")"
      setTimeout startListener, 5000

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

