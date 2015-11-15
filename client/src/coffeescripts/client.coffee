

# should match the number in layout.styl for display.switching and #next-display.switching transition
slideSwitchTime = 1000

# this array is for properly displaying shortcuts in user-readable strings
keyCodeNames = ["[NUL]", "???", "???", "[Cancel]", "???", "???", "[Help]", "???",
		"Backspace", "Tab", "???", "???", "[CLR]", "Enter", "Return", "???",
		"Shift", "Control", "Alt", "Pause", "Caps Lock",
		"KANA", "EISU", "JUNJA", "FINAL", "HANJA", "???",
		"Escape", "[CNV]", "[NCNV]", "[ACPT]", "[MDCH]", "Space", "Page Up",
		"Page Down", "End", "Home", "Left", "Up", "Right", "Down", "Select",
		"Print", "Execute", "Print Screen", "Insert", "Delete", "???",
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
		":", ";", "<", "=", ">", "?", "@",
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N",
		"O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"Windows", "???", "Menu", "???", "Sleep",
		"Numpad 0", "Numpad 1", "Numpad 2", "Numpad 3", "Numpad 4",
		"Numpad 5", "Numpad 6", "Numpad 7", "Numpad 8", "Numpad 9",
		"Numpad *", "Numpad +", "???", "Numpad -", "Numpad .", "Numpad /",
		"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10",
		"F11", "F12", "F13", "F14", "F15", "F16", "F17", "F18", "F19",
		"F20", "F21", "F22", "F23", "F24",
		"???", "???", "???", "???", "???", "???", "???", "???",
		"Num Lock", "Scroll Lock",
		"WIN_OEM_FJ_JISHO", "WIN_OEM_FJ_MASSHOU", "WIN_OEM_FJ_TOUROKU",
		"WIN_OEM_FJ_LOYA", "WIN_OEM_FJ_ROYA",
		"???", "???", "???", "???", "???", "???", "???", "???", "???",
		"^", "!", "\"", "#", "$", "%", "&", "_", "(", ")", "*", "+", "|",
		"-", "{", "}", "~",
		"???", "???", "???", "???",
		"Volume Mute", "Volume Down", "Volume Up",
		"???", "???",
		";", "=", ",", "-", ".", "/", "\\",
		"???", "???", "???", "???", "???", "???", "???", "???", "???", "???",
		"???", "???", "???", "???", "???", "???", "???", "???", "???", "???",
		"???", "???", "???", "???", "???", "???",
		"[", "\\", "]", "'", "???", "Meta", "AltGrave", "???", "Windows Help",
		"WIN_ICO_00", "???", "WIN_ICO_CLEAR", "???", "???", "WIN_OEM_RESET",
		"WIN_OEM_JUMP", "WIN_OEM_PA1", "WIN_OEM_PA2", "WIN_OEM_PA3",
		"WIN_OEM_WSCTRL", "WIN_OEM_CUSEL", "WIN_OEM_ATTN", "WIN_OEM_FINISH",
		"WIN_OEM_COPY", "WIN_OEM_AUTO", "WIN_OEM_ENLW", "WIN_OEM_BACKTAB",
		"ATTN", "CRSEL", "EXSEL", "EREOF", "Play", "Zoom", "???", "PA1",
		"WIN_OEM_CLEAR", ""]

# angular modules
angular.module "LyricScreen", [
  "LyricScreen.controllers",
  "LyricScreen.services"
]

angular.module "LyricScreen.controllers", []
angular.module "LyricScreen.services", []


# controller
angular.module("LyricScreen.controllers").controller "LyricScreenCtrl", ($scope, $timeout, LyricScreenService) ->
  $scope.display = ''
  $scope.nextDisplay = ''

  # handle slide transitions on display text changes
  $scope.$watch 'nextDisplay', ->
    $timeout ->
      $scope.display = $scope.nextDisplay
    , slideSwitchTime

  # message received handler
  LyricScreenService.addMessageHandler (msg) ->
    if msg.type == "state"
      $scope.setState msg.data

    if msg.type == "close"
      $scope.setState {}

    if msg.type == "display"
      $scope.nextDisplay = msg.data

  # callbacks for controls
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

  $scope.reloadPlaylist = ->
    LyricScreenService.send type: "reload current playlist"

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
    console.log s
    return false if not s? or !s
    m = $scope.getCurrentSongMap()
    console.log m
    return false if not m? or !m
    slides = []
    i = 0
    for v in m.verses
      console.log v
      verseData =
        "title": v
        "contents": ""
        "mapVerseId": i
        "active": i == m.currentVerseId
      if v of s.verses
        verseData.contents = s.verses[v]
      slides.push verseData
      i++
    return slides

  # keyboard shortcuts
  keyboardShortcuts = {}
  do ->
    shortcutElements = document.querySelectorAll '[data-click-keyboard-shortcut]'
    for el in shortcutElements
      shortcutData = el.dataset.clickKeyboardShortcut
      if shortcutData.trim() == "" then continue
      shortcuts = shortcutData.split ","

      for s in shortcuts
        keyboardShortcuts["key-" + s.trim().toString()] = el

      # TODO: Display keyboard shortcuts
      # el.title += " ["

  keydown = (e) ->
    key = "" + e.keyCode
    # console.log e, e.keyCode
    if e.metaKey then key = "m" + key
    if e.shiftKey then key = "s" + key
    if e.altKey then key = "a" + key
    if e.ctrlKey then key = "c" + key
    key = "key-" + key
    if key of keyboardShortcuts
      el = keyboardShortcuts[key]
      click = new MouseEvent 'click', {
        'view': window,
        'bubbles': true,
        'cancelable': true,
      }
      r = el.dispatchEvent click
      e.preventDefault()
      return false

  window.addEventListener "keydown", keydown, true


# service
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

