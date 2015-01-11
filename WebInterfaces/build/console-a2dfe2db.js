(function(){

	var state = {};
	window.server_state = state;

	function print(message) {
		console.log(message);

		var debugConsole = document.getElementById("debug-console");
		if (debugConsole) {
			var dt = new Date();
			var h = dt.getHours().toString(); if (h.length < 2) h = "0" + h;
			var m = dt.getMinutes().toString(); if (m.length < 2) m = "0" + m;
			var s = dt.getSeconds().toString(); if (s.length < 2) s = "0" + s;

			var l = document.createElement("li");
			var span = document.createElement("span");
			span.className = "timestamp";
			var timestamp = document.createTextNode(h+":"+m+":"+s+" ");
			span.appendChild(timestamp)
			l.appendChild(span)
			var messageNode = document.createTextNode(message.toString());
			l.appendChild(messageNode)
			debugConsole.insertBefore(l, debugConsole.firstChild);

			while (debugConsole.childNodes.length > 100) {
				debugConsole.removeChild(debugConsole.lastChild);
			}
		}
	}

	function setText(text) {
		var realtimePreviewer = document.getElementById("realtime-preview");
		realtimePreviewer.innerText = text;
	}

	window.dbg_print = print;

	print("Console: Initializing...");
	var connString = window.location.host.split(":")[0] + ":9876/console"
	var sock = new WebSocket("ws://" + connString);
	window.ls_sock = sock; // Gives a silly alias in Chrome's console.
	print("Console: Connecting to ws://" + connString + "...");

	sock.onclose = function(e) {
		switch (e.code) {
			case 1006:
				print("Console: Failed to connect.");
				break;
			case 1000: 
				print("Console: Connection closed.");
				break;
		}
	};

	sock.onerror = function(e) {
	};

	sock.onmessage = function(e) {
		if (e.data.substring(0, 8) == "console:") {
			print("Server: " + e.data.substring(8).trim());
		}
		if (e.data.substring(0, 6) == "slide:") {
			setText(e.data.substring(6).trim());
		}
		if (e.data.substring(0, 6) == "state:") {
			state = JSON.parse(e.data.substring(6).trim());
			reloadWithState(state);
			console.log(state);
		}
	};

	sock.onopen = function(e) {
		print("Console: Connected.");
	};

	window.onbeforeunload = function() {
		if (sock.readyState < 2) {
			sock.close();
		}
	};

	// Interface
	document.getElementById("next-verse").onclick = function() {
		sock.send("next");
	};

	document.getElementById("previous-verse").onclick = function() {
		sock.send("previous");
	};

	document.getElementById("next-song").onclick = function() {
		sock.send("next song");
	};

	document.getElementById("previous-song").onclick = function() {
		sock.send("previous song");
	};

	document.getElementById("freeze").onclick = function() {
		sock.send("freeze");
	};

	document.getElementById("blank").onclick = function() {
		sock.send("blank");
	};

	document.getElementById("restart-playlist").onclick = function() {
		sock.send("restart playlist");
	};

	function reloadWithState(state) {
		window.server_state = state;
		for (var si = 0; si < state.songs.length; si++) {
			// Add song switcher
		}

		var songVerses = document.getElementById("song-verses");
		while (songVerses.firstChild) {
			songVerses.removeChild(songVerses.firstChild);
		}

		var currentSong = state.songs[state.currentSong];
		var currentMap = currentSong.maps[currentSong.currentMap];
		for (var vi = 0; vi < currentMap.verses.length; vi++) {
			var slide = document.createElement("li");
			slide.className = "jump-to-verse";
			slide.setAttribute('data-verse', vi);
			var slideText = document.createTextNode(getSongVerseByName(currentSong, currentMap.verses[vi]).content)
			slide.appendChild(slideText);
			songVerses.appendChild(slide);
		}

		rebindDynamicEvents();
		console.log("State:", state);
	}

	function getSongVerseByName(song, verseName) {
		for (var i = 0; i < song.verses.length; i++) {
			if (song.verses[i].name == verseName) {
				return song.verses[i];
			}
		}
	}

	function rebindDynamicEvents() {
		var elements = document.getElementsByClassName('jump-to-verse');
		for (var i = 0; i < elements.length; i++) {
			elements[i].onclick = function(e) {
				console.log(e);
				console.log(this);
				sock.send("goto verse " + this.getAttribute("data-verse"));
			};
		}
	}

}());
