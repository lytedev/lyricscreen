angular.module "LyricScreen", [
  "LyricScreen.controllers",
  "LyricScreen.services"
]


angular.module "LyricScreen.controllers", []
angular.module "LyricScreen.services", []


angular.module("LyricScreen.controllers").controller "LyricScreenCtrl", ($scope, LyricScreenService) ->
  $scope.state = {}

  $scope.getCurrentSongId = ->
    s = $scope.state
    if not s.playlists?
      return
    p = s.playlists[s.currentPlaylistKey]
    p.currentSongId

  $scope.getCurrentVerseId = ->
    s = $scope.state
    if not s.playlists?
      return
    p = s.playlists[s.currentPlaylistKey]
    sg = p.songs[p.currentSongId]
    m = sg.maps[sg.currentMapKey]
    return m.currentVerseId

  $scope.setState = (state) ->
    $scope.state = state

    s = $scope.state
    if not s.playlists?
      return

    p = s.playlists[s.currentPlaylistKey]
    sg = p.songs[p.currentSongId]
    m = sg.maps[sg.currentMapKey]
    $scope.currentVerseId = m.currentVerseId

  $scope.nextVerse = ->
    LyricScreenService.send type: "next verse"

  $scope.previousVerse = ->
    LyricScreenService.send type: "previous verse"

  LyricScreenService.receive().then null, null, (res) ->

    if not res?
      return

    if res.message.type == "state"
      $scope.setState res.message.data


angular.module("LyricScreen.services").service "LyricScreenService", ($q) ->
  service = {}
  listener = $q.defer()
  messageIds = []
  lastMessageId = 0

  generateMessageId = ->
    mid = lastMessageId++
    if lastMessageId > 1000000
      lastMessageId = 0
    return mid

  socket = {}

  service.receive = ->
    listener.promise

  service.send = (msg) ->
    msg.message_id = generateMessageId()
    socket.send JSON.stringify msg
    messageIds.push messageId

  getMessage = (data) ->
    try
      message = JSON.parse data
    catch e
      console.log "Failed to parse incoming WebSocket message", e, data
      return
    out =
      message: message
      time: new Date(message.time)
    if message.message_id?
      if message.message_id in messageIds
        out.self = true
        messageIds.splice messageIds.indexOf message.message_id, 1
    return out

  startListener = ->
    socket = new WebSocket "ws://" + window.location.host + "/admin"
    socket.addEventListener "open", (e) ->
      service.send type: "get state"

    socket.addEventListener "message", (msg) ->
      listener.notify getMessage msg.data

  startListener()

  return service

