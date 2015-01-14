"""

Daniel "lytedev" Flanagan
http://dmf.me

Simple websocket server implementation.

"""

import sys

import jsonpickle
import asyncio
import websockets
import pprint

from playlist import Playlist

class WebSocketServer(object):
	def __init__(self, host = "0.0.0.0", port = 8417):
		"""Initialization for a Playlist-managing websocket server."""
		# Hosting information
		self.host = host
		self.port = port

		# Sockets to keep track of		
		self.displays = []
		self.consoles = []

		# Load default playlist
		self.loadPlaylist()
		
	def loadPlaylist(self, p = "Default"):
		"""Load the given Playlist."""
		self.playlist = Playlist.load(p)

		if self.playlist == False:
			print("Error: Could not load {0} playlist".format(p))
			return False

		# Print a quick summary of the playlist
		if len(self.playlist.songsToLoad) != len(self.playlist.songs):
			print("Loaded Playlist \"{0}\" with errors ({1} Song(s) - {2} Song(s) failed to load)".format(self.playlist.name, len(self.playlist.songs), len(self.playlist.songsToLoad) - len(self.playlist.songs)))
		else:
			print("Loaded Playlist {0} ({1} Song(s))".format(self.playlist.name, len(self.playlist.songs)))
		i = 1
		for s in self.playlist.songs:
			m = s.getCurrentMap()
			print("  {0}. {1} ({2} Verse(s) in {3} Map, {4} Map(s))".format(i, s.title, len(m.verses), m.name, len(s.maps)))
			i += 1

	def start(self):
		"""Start the server listening and connection-accepting loop."""
		print("Server Starting...")
		self.sock = websockets.serve(self.connection, self.host, self.port)
		self.loop = asyncio.get_event_loop()
		self.loop.run_until_complete(self.sock)
		print("Ready for connections at {0}:{1}".format(self.host, self.port))
		try:
			self.loop.run_forever()
		finally:
			self.loop.close()

	@asyncio.coroutine
	def connection(self, sock, path): 
		"""Handle a socket connection."""
		# Identify ourselves (not required, just nice, I guess?)
		yield from sock.send("lyricscreen server 0.2.0")

		# Handle our connection paths
		if path.startswith("/display"): 
			yield from self.displayConnection(sock, path)

		if path.startswith("/console"): 
			yield from self.consoleConnection(sock, path)
				
	def sendToConsoles(self, message): 
		"""Send the given string to all Console sockets."""
		bad_consoles = []
		for sock in self.consoles:
			if not sock.open:
				bad_consoles.append(sock)
				continue
			yield from sock.send(message)
		for d in bad_consoles:
			self.consoles.remove(d)

	def sendToDisplays(self, message):
		"""Send the given string to all Display sockets."""
		bad_displays = []
		for sock in self.displays:
			if not sock.open:
				bad_displays.append(sock)
				continue
			yield from sock.send(message)
		for d in bad_displays:
			self.displays.remove(d)

	def sendToAll(self, message): 
		"""Send string all sockets."""
		yield from self.sendToConsoles(message)
		yield from self.sendToDisplays(message)

	def output(self, s):
		"""Print the string to the console and send the message to all 
		sockets."""
		print(s)
		yield from self.sendToAll("console: {0}".format(s))

	def displayConnection(self, sock, path):
		"""Handle a display connection and initialize the socket loop."""
		self.displays.append(sock)
		yield from self.output("Display connected.")

		check = self.checkAll()
		if check[0] == False: 
			self.output("No playlist loaded.")
		else:
			# Update out displays (including this one)
			yield from self.updateDisplays()

		# Enter message loop and handle messages
		while True:
			# Displays don't get to do very much
			msg = yield from sock.recv()
			if msg is None or msg == "disconnect": 
				break

		# Close the connection and remove the display
		self.displays.remove(sock)
		yield from self.output("Display disconnected.")

	def consoleConnection(self, sock, path):
		"""Handle a console connection and initialize the socket loop."""
		self.consoles.append(sock)
		yield from self.output("Console connected.")

		if self.playlist == False: 
			self.output("No playlist loaded.")
		else:
		# And the current slide
			v = self.playlist.getCurrentVerse()
			if v != False:
				yield from sock.send("slide: " + v.content)

		# Enter message loop and handle messages
		while True:
			msg = yield from sock.recv()
			if msg is not None:
				msg = msg.strip()
			if msg is None or msg == "disconnect": 
				break

			elif msg == "state": 
				"""A message requesting the current Playlist state."""
				yield from sock.send("state: " + jsonpickle.encode(self.playlist))

			elif msg == "next" or msg == "next verse": 
				"""Go to the next Verse."""
				check = self.checkVerse()
				if check[0] == True:
					self.playlist.nextVerse()
				yield from self.updateAll()

			elif msg == "previous" or msg == "prev" or \
				msg == "previous verse" or msg == "prev verse": 
				"""Go to the previous Verse."""
				check = self.checkVerse()
				if check[0] == True:
					self.playlist.previousVerse()
				yield from self.updateAll()

			elif msg == "next song": 
				"""Go to the next Song."""
				check = self.checkSong()
				if check[0] == True:
					self.playlist.nextSong().restart()
				yield from self.updateAll()

			elif msg == "prev song" or msg == "previous song": 
				"""Go to the previous Song."""
				check = self.checkSong()
				if check[0] == True:
					self.playlist.previousSong().restart()
				yield from self.updateAll()

			elif msg == "blank": 
				"""Flip the Playlist's blank flag."""
				self.playlist.isBlank = not self.playlist.isBlank
				yield from self.updateAll()

			elif msg == "freeze": 
				"""Flip the Playlist's freeze flag."""
				self.playlist.isFrozen = not self.playlist.isFrozen
				yield from self.updateAll()

			elif msg == "restart playlist" or msg == "restart": 
				"""Jump to the very beginning of the Playlist."""
				yield from self.output("Restarting Playlist.")
				if self.checkPlaylist()[0]:
					self.playlist.restart()
				yield from self.updateAll()

			elif msg == "finish playlist" or msg == "finish": 
				"""Jump to the very beginning of the Playlist."""
				yield from self.output("Restarting Playlist.")
				if self.checkPlaylist()[0]:
					self.playlist.finish()
				yield from self.updateAll()

			elif msg == "reload" or msg == "reload all" or msg == "reload playlist": 
				"""Reload the current Playlist but try to remember our current 
				Song, Map, Verse, etc."""
				yield from self.output("Reloading Playlist...")
				if self.checkAll()[0]:
					curSong = self.playlist.currentSong
					curMap = self.playlist.getCurrentSong().currentMap
					curVerse = self.playlist.getCurrentSong().getCurrentMap().currentVerse
					isBlank = self.playlist.isBlank
					isFrozen = self.playlist.isFrozen
				self.loadPlaylist(self.playlist.file)
				if self.checkAll()[0]:
					self.playlist.isBlank = isBlank
					self.playlist.isFrozen = isFrozen
					s = self.playlist.goToSong(curSong)
					if self.checkSong()[0]:
						m = s.goToMap(curMap)
						if self.checkVerse()[0]:
							m.goToVerse(curVerse)
				yield from self.updateAll()

			elif msg.startswith("load") or msg.startswith("load playlist"): 
				"""Load the specified Playlist."""
				playlist = msg.replace("load playlist", "", 1).replace("load", "", 1).strip()
				self.loadPlaylist(playlist)
				yield from self.updateDisplays()

			elif msg.startswith("goto verse"): 
				"""Jump to the specified Verse in the current Song."""
				vid = msg[10:].strip()
				try: 
					vid = int(vid)
				except ValueError:
					continue
				self.playlist.goToVerse(vid)
				yield from self.updateAll()

			elif msg.startswith("goto song"): 
				"""Jump to the specified Song in the current Playlist."""
				sid = msg[9:].strip()
				try: 
					sid = int(sid)
				except ValueError:
					continue
				self.playlist.goToSong(sid)
				yield from self.updateAll()

			elif msg == "kill" or msg == "quit" or msg == "exit": 
				"""Force the server to stop excecution."""
				sys.exit(0)

		self.consoles.remove(sock)
		yield from self.output("Console disconnected.")

	# Update Group Functions
	# Send the needed data to the appropriate sockets

	def updateDisplays(self, v = False):
		"""Tell every display what to display."""
		if self.playlist.isBlank: 
			# If the Playlist is blank, tell the slides to display nothing. 
			yield from self.sendToDisplays("slide: " + " ")
		if v == False: # No verse specified...
			check = self.checkPlaylist()
			if check[0] == False: 
				# No current valid Playlist
				yield from self.sendToDisplays("slide: " + " ")
				return 
			v = self.playlist.getCurrentVerse()
		if v != False: # Given a proper verse (or we loaded the current one)
			displayState = "slide: " + v.content
			if self.playlist.isFrozen or self.playlist.isBlank: 
				# Frozen or blank, we don't tell the displays to change
				yield from self.sendToConsoles(displayState)
			else:
				# Tell every socket what verse we're showing
				yield from self.sendToAll(displayState)
		else:
			# We got crazy errors up in this thang
			yield from self.output("Could not switch to specified verse (not found?)")

	def updateConsoles(self):
		"""Send the entire Playlist state to the consoles."""
		state = jsonpickle.encode(self.playlist)
		for sock in self.consoles:
			yield from sock.send("state: " + state)

	def updateAll(self):
		yield from self.updateDisplays()
		yield from self.updateConsoles()

	# Checking Functions
	# Verify that we have certain bits of data for sanity reasons

	def checkAll(self):
		"""Verifies we have a valid Playlist with a current valid Song and 
		a current valid Verse. Returns the Playlist as data if all's well.""" 
		if self.playlist == False: 
			return False, "no playlist", "No Playlist loaded."
		elif self.playlist.getCurrentSong() == False:
			return False, "no song in playlist", "No Songs in Playlist."
		elif self.playlist.getCurrentVerse() == False:
			return False, "no verse in song", "No Verses in Song."
		else:
			return True, self.playlist, "Check passed."

	def checkVerse(self):
		"""Verifies we have a valid Playlist with a current valid Song and 
		a current valid Verse. Returns the Verse as data if all's well.""" 
		if self.playlist == False: 
			return False, "no playlist", "No Playlist loaded."
		elif self.playlist.getCurrentSong() == False:
			return False, "no song in playlist", "No Songs in Playlist."

		verse = self.playlist.getCurrentVerse()

		if verse == False:
			return False, "no verse in song", "No Verses in Song."
		else:
			return True, verse, "Check passed."

	def checkSong(self):
		"""Verifies we have a valid Playlist with a current valid Song. 
		Returns the Song as data if all's well.""" 
		if self.playlist == False: 
			return False, "no playlist", "No Playlist loaded."

		song = self.playlist.getCurrentSong()
		
		if song == False:
			return False, "no song in playlist", "No Songs in Playlist."
		else:
			return True, song, "Check passed."

	def checkPlaylist(self):
		"""Verifies we have a valid Playlist. Returns the Playlist as data if 
		all's well.""" 
		if self.playlist == False: 
			return False, "no playlist", "No Playlist loaded."
		else:
			return True, self.playlist, "Check passed."
