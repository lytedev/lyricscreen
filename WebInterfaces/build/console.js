(function(){

	/* Utility Functions */

	// String startsWith stupidity until ECMAScript 6 saves us all
	var stringStartsWith = function(str, substr) {
		return str.substring(0, substr.length) == substr;
	};

	/* Classes */

	/**
	 * Manages and manipulates the state as sent by the server.
	 */
	var AdminState = function() {
		this.data = false;
		this.stateJSON = JSON.stringify(this.state);
	}; // Prototype methods follow

	AdminState.prototype.fromJSON = function(json) {
		if (typeof json !== "string") return;
		this.setState(JSON.parse(json));
	};

	AdminState.prototype.setState = function(state) {
		this.data = state;
	};

	AdminState.prototype.getCurrentSong = function() {
		return this.data.songs[this.data.currentSong];
	};

	AdminState.prototype.getCurrentMap = function(song) {
		return song.maps[song.currentMap];
	};

	AdminState.prototype.getCurrentSongVerses = function() {
		var verses = [];
		var song = this.getCurrentSong();
		var map = this.getCurrentMap(song);
		for (var i = 0; i < map.verses.length; i++) {
			verses.push(this.getVerseByName(song, map.verses[i]));
		}
		return verses;
	};

	AdminState.prototype.getVerseByName = function(song, verseName) {
		for (var i = 0; i < song.verses.length; i++) {
			if (song.verses[i].name == verseName) {
				return song.verses[i];
			}
		}
	};

	/**
	 * The websocket client class for managing an administrator connection.
	 * @param [callback] A logging callback.
	 */
	var AdminWebSocketClient = function() {
		this.log = console.log.bind(console);
		this.defaultPort = 8417;
		this.expectedServerVersion = "0.2.0";
		this.socket = false;
		this.state = new AdminState();

		if (arguments.length >= 1) {
			this.log = arguments[0];
		}

		/**
		 * Disconnect the current socket if connected.
		 * @return {void}
		 */
		this.disconnect = function() {
			if (this.socket != false) {
				if (this.socket.readyState < 2) {
					this.socket.close();
				}
			}
		}

		/**
		 * Initializes the websocket and attempts to connect to the server.
		 * @return {void}
		 */
		this.connect = function() {
			var host = window.location.host.split(":")[0];
			var port = this.defaultPort;
			if (arguments.length >= 1) {
				host = arguments[0];
			}
			if (arguments.length >= 2) {
				port = arguments[1];
			}
			var connString = host + ":" + port.toString() + "/console";
			this.log("Client: Connecting to ws://" + connString + "...");
			this.socket = new WebSocket("ws://" + connString);
			this.addSocketHandlers();
		};

		/**
		 * Add the event listeners for the socket events and our custom message events.
		 *
		 * Changes to this should/will break compatibility.
		 * Cross-reference with socketMessage().
		 */
		this.addSocketHandlers = function() {
			var that = this;

			// Default websocket event handlers
			this.socket.addEventListener('open', function(e) { that.socketOpen(e); });
			this.socket.addEventListener('error', function(e) { that.socketError(e); });
			this.socket.addEventListener('message', function(e) { that.socketMessage(e); });
			this.socket.addEventListener('close', function(e) { that.socketClose(e); });

			// Message-type handlers
			// See socketMessage() for notes on how these are mapped.
			this.socket.addEventListener('consoleMessage', function(e) { that.socketConsoleMessage(e); });
			this.socket.addEventListener('displayMessage', function(e) { that.socketDisplayMessage(e); });
			this.socket.addEventListener('stateMessage', function(e) { that.socketStateMessage(e); });
			this.socket.addEventListener('handshakeMessage', function(e) { that.socketHandshakeMessage(e); });
			this.socket.addEventListener('unknownMessage', function(e) { that.socketUnknownMessage(e); });
		};

		/**
		 * The event handler for socket message events.
		 *
		 * This also re-dispatches predefined events with custom handlers.
		 *
		 * Changes to this should/will break compatibility.
		 * Cross-reference with addSocketHandlers().
		 * @param  {WebSocket.MessageEvent} e The websocket message event object. `e.data` contains the message string.
		 * @return {void}
		 */
		this.socketMessage = function(e) {
			var msg = e.data;

			// See addSocketHandlers() for notes on how these are added as listeners.
			var messageBindMap = [
				["console:", "consoleMessage"],
				["slide:", "displayMessage"],
				["state:", "stateMessage"],
				["lyricscreen server", "handshakeMessage"],
			];

			// Iterate the map
			for (var i = 0; i < messageBindMap.length; i++) {
				var bmi = messageBindMap[i];
				// Matches map "key"
				if (stringStartsWith(msg, bmi[0])) {
					// Dispatch event as described in map
					var args = msg.substring(bmi[0].length).trim();
					var messageEvent = new MessageEvent(bmi[1], {'data': {'original_event': e, 'message': msg, 'args': args}});
					this.socket.dispatchEvent(messageEvent);
					return;
				}
			}

			// All else fails, we dispatch as an unknown message type
			var unknownMessageEvent = new MessageEvent('unknownMessage', {'data': {'original_event': e, 'message': msg}});
			this.socket.dispatchEvent(unknownMessageEvent);
		};

		this.socketConsoleMessage = function(e) {
			// Console messages just get logged
			this.log("Server: " + e.data.args);
		};

		this.socketDisplayMessage = function(e) {
			// TODO: Show the current text
			// setText(e.data.substring(6).trim());
			if (this.onDisplayMessage) {
				this.onDisplayMessage(e);
			}
		};

		this.socketStateMessage = function(e) {
			this.state.fromJSON(e.data.args);
			if (this.onStateChange) {
				this.onStateChange(this.state);
			}
		};

		this.socketHandshakeMessage = function(e) {
			if (e.data.args !== this.expectedServerVersion) {
				this.log("Invalid server version.");
				this.disconnect();
			} else {
				this.sendStateRequest();
			}
		};

		this.socketUnknownMessage = function(e) {
			this.log("Unknown message received: " + e.data.message);
		};

		this.socketOpen = function(e) {
			this.log("Client: Connected.");
		};

		this.sendStateRequest = function() {
			this.send("state");
		};

		this.socketError = function(e) {
			// TODO: Error handling for websocket connections
		};

		this.socketClose = function(e) {
			switch (e.code) {
				case 1006:
					this.log("Client: Failed to connect.");
					break;
				case 1000:
					this.log("Client: Connection closed.");
					break;
			}
		};

		this.send = function(message) {
			if (this.onBeforeSend) {
				this.onBeforeSend(message);
			}
			this.socket.send(message);
		};
	};

	/**
	 * Handles the front-end <-> state synchronization and management.
	 */
	var AdminInterface = function() {
		this.debugConsole = false;
		this.songVerses = false;
		this.freezeButton = false;
		this.blankButton = false;
		this.client = false;

		/**
		 * Prepares the interface for use.
		 * @return {void}
		 */
		this.setup = function() {
			this.client = new AdminWebSocketClient();
			this.client.log = this.print.bind(this);
			this.client.onStateChange = this.onStateChange.bind(this);

			this.debugConsole = document.getElementById("debug-console");
			this.songVerses = document.getElementById("song-verses");
			this.freezeButton = document.getElementById("freeze-button");
			this.blankButton = document.getElementById("blank-button");

			window.onbeforeunload = function() {
				this.client.disconnect();
			};

			this.client.connect();
		};

		/**
		 * Prints the specified message to our debug console and the development
		 * console.
		 * @param  {string} message Our message string.
		 * @return {void}
		 */
		this.print = function(message) {
			console.log(message);

			var dt = new Date();
			var h = dt.getHours().toString(); if (h.length < 2) h = "0" + h;
			var m = dt.getMinutes().toString(); if (m.length < 2) m = "0" + m;
			var s = dt.getSeconds().toString(); if (s.length < 2) s = "0" + s;
			var timestamp = document.createTextNode(h+":"+m+":"+s+" ");

			var l = document.createElement("li");
				var span = document.createElement("span");
				span.className = "timestamp";
				span.appendChild(timestamp)
			l.appendChild(span)
				var messageNode = document.createTextNode(message.toString());
			l.appendChild(messageNode)

			this.debugConsole.insertBefore(l, this.debugConsole.firstChild);

			while (this.debugConsole.childNodes.length > 100) {
				this.debugConsole.removeChild(this.debugConsole.lastChild);
			}
		};

		this.onStateChange = function(state) {
			var song = state.getCurrentSong();
			for (var si = 0; si < state.data.songs.length; si++) {
				// TODO: Add song switcher
			}

			while (this.songVerses.firstChild) {
				this.songVerses.removeChild(this.songVerses.firstChild);
			}

			if (state.data.currentSong > 0) {
				var slide = document.createElement("li");
				slide.className = "basic message-button";
				slide.setAttribute('data-message', "goto song " + (state.data.currentSong - 1));
				var slideText = "Go to Previous Song";
				slide.innerHTML = slideText;
				this.songVerses.appendChild(slide);
			}

			var map = state.getCurrentMap(song);
			var verses = state.getCurrentSongVerses();
			for (var vi = 0; vi < verses.length; vi++) {
				var slide = document.createElement("li");
				slide.className = "basic jump-to-verse";
				if (vi == map.currentVerse) {
					slide.className += " active";
				}
				slide.setAttribute('data-verse', vi);
				var slideText = "";
				slideText += "<span class=\"verse-name\">" + verses[vi].name + "</span>";
				slideText += verses[vi].content.replace(/\n/g, "<br />")
				slide.innerHTML = slideText;
				this.songVerses.appendChild(slide);
			}

			if (state.data.currentSong < state.data.songs.length - 1) {
				var slide = document.createElement("li");
				slide.className = "basic message-button";
				slide.setAttribute('data-message', "next song");
				var slideText = "Go to Next Song";
				slide.innerHTML = slideText;
				this.songVerses.appendChild(slide);
			}

			this.updateBlankButton(state);
			this.updateFreezeButton(state);

			this.rebindInterfaceEvents();
		};

		this.updateFreezeButton = function(state) {
			if (state.data.isFrozen) {
				this.freezeButton.innerHTML = "<i class=\"fa fa-play\"></i>";
			} else {
				this.freezeButton.innerHTML = "<i class=\"fa fa-pause\"></i>";
			}
		};

		this.updateBlankButton = function(state) {
			if (state.data.isBlank) {
				this.blankButton.innerHTML = "<i class=\"fa fa-toggle-off\"></i>";
			} else {
				this.blankButton.innerHTML = "<i class=\"fa fa-toggle-on\"></i>";
			}
		};

		this.rebindInterfaceEvents = function() {
			var that = this;
			var verseJumpers = document.getElementsByClassName('jump-to-verse');
			for (var i = 0; i < verseJumpers.length; i++) {
				verseJumpers[i].onclick = function(e) { that.jumpToVerseCallback(e, this); };
			}

			var messageButtons = document.getElementsByClassName('message-button');
			for (var i = 0; i < messageButtons.length; i++) {
				messageButtons[i].onclick = function(e) { that.messageButtonCallback(e, this); };
			}
		};

		/* Interface Element Callbacks */

		this.jumpToVerseCallback = function(e, that) {
			console.log(e, that);
			this.client.send("goto verse " + that.dataset.verse);
			e.preventDefault();
			return false;
		};

		this.messageButtonCallback = function(e, that) {
			console.log(e, that);
			this.client.send(that.dataset.message);
			e.preventDefault();
			return false;
		};

		return this;

	};

	var a = new AdminInterface();
	a.setup();

}());
