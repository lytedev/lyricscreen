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
	def __init__(self, host = "0.0.0.0", port = 9876):
		# Hosting information
		self.host = host
		self.port = port

		# Sockets to keep track of		
		self.displays = []
		self.consoles = []

		# Load default playlist
		self.loadPlaylist()
		
	def loadPlaylist(self, p = "Default"):
		self.playlist = Playlist.load(p)

		if self.playlist == False:
			print("Could not load {0} playlist".format(p))
			return False

		# Print a quick summary of the playlist
		print("Loaded Playlist {0} ({1} Songs)".format(self.playlist.name, len(self.playlist.songs)))
		i = 1
		for s in self.playlist.songs:
			m = s.getCurrentMap()
			print("  {0}. {1} ({2} Verses in {3} Map)".format(i, s.title, len(m.verses), m.name))
			i += 1

	def start(self):
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
		# Identify ourselves (not required, just nice, I guess?)
		yield from sock.send("lyricscreen server 0.1.0")

		# Handle our connection paths
		if path.startswith("/display"): 
			yield from self.displayConnection(sock, path)

		if path.startswith("/console"): 
			yield from self.consoleConnection(sock, path)
				
	def sendToConsoles(self, message): 
		# Send to all sockets
		bad_consoles = []
		for sock in self.consoles:
			if not sock.open:
				bad_consoles.append(sock)
				continue
			yield from sock.send(message)
		for d in bad_consoles:
			self.consoles.remove(d)

	def sendToDisplays(self, message):
		bad_displays = []
		for sock in self.displays:
			if not sock.open:
				bad_displays.append(sock)
				continue
			yield from sock.send(message)
		for d in bad_displays:
			self.displays.remove(d)

	def sendToAll(self, message): 
		# Send to all sockets
		yield from self.sendToConsoles(message)
		yield from self.sendToDisplays(message)

	def output(self, s):
		print(s)
		yield from self.sendToAll("console: {0}".format(s))

	def updateDisplays(self, v = False):
		if self.playlist.isBlank: 
			yield from self.sendToDisplays("slide: " + " ")
		if v == False:
			v = self.playlist.getCurrentVerse()
		if v != False:
			displayState = "slide: " + v.content
			if self.playlist.isFrozen or self.playlist.isBlank: 
				yield from self.sendToConsoles(displayState)
			else:
				yield from self.sendToAll(displayState)
			s = self.playlist.getCurrentSong()
			vmi = s.getCurrentMap().currentVerse
			yield from self.output("Verse ([{2}] {0}: {1})".format(v.name, v.getExcerpt(), vmi))
		else:
			yield from self.output("Could not switch to specified verse (not found?)")

	def updateConsoles(self):
		for sock in self.consoles:
			yield from sock.send("state: " + jsonpickle.encode(self.playlist))

	def displayConnection(self, sock, path):
		self.displays.append(sock)
		yield from self.output("Display connected.")

		# Tell the new Display what to show
		v = self.playlist.getCurrentVerse()
		if v != False:
			yield from sock.send("slide: " + v.content)

		# Enter message loop and handle messages
		while True:
			msg = yield from sock.recv()
			if msg is None or msg == "disconnect": 
				break

		# Close the connection and remove the display
		self.displays.remove(sock)
		yield from self.output("Display disconnected.")

	def consoleConnection(self, sock, path):
		self.consoles.append(sock)
		yield from self.output("Console connected.")

		# Send the current state
		yield from sock.send("state: " + jsonpickle.encode(self.playlist))

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
				v = self.playlist.nextVerse()
				yield from sock.send("state: " + jsonpickle.encode(self.playlist))

			elif msg == "next" or msg == "next verse": 
				v = self.playlist.nextVerse()
				yield from self.updateDisplays()

			elif msg == "previous" or msg == "prev" or \
				msg == "previous verse" or msg == "prev verse": 
				v = self.playlist.previousVerse()
				yield from self.updateDisplays()

			elif msg == "next song": 
				s = self.playlist.nextSong()
				s.restart()
				yield from self.updateDisplays()

			elif msg == "prev song" or msg == "previous song": 
				s = self.playlist.previousSong()
				s.restart()
				yield from self.updateDisplays()

			elif msg == "blank": 
				self.playlist.isBlank = not self.playlist.isBlank
				yield from self.updateDisplays()

			elif msg == "freeze": 
				self.playlist.isFrozen = not self.playlist.isFrozen
				yield from self.updateDisplays()

			elif msg == "restart playlist": 
				self.loadPlaylist("Default")
				yield from self.updateDisplays()

			elif msg.startswith("goto verse"): 
				vid = msg[10:].strip()
				try: 
					vid = int(vid)
				except ValueError:
					continue
				self.playlist.goToVerse(vid)
				yield from self.updateDisplays()

			elif msg.startswith("goto song"): 
				sid = msg[9:].strip()
				try: 
					sid = int(sid)
				except ValueError:
					continue
				self.playlist.goToSong(sid)
				yield from self.updateDisplays()

			elif msg == "kill": 
				sys.exit(1)

		self.consoles.remove(sock)
		yield from self.output("Console disconnected.")
