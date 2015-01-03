(function(){

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

	document.getElementById("restart-playlist").onclick = function() {
		sock.send("restart playlist");
	};

}());
