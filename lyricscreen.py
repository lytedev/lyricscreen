#!/usr/bin/env python

"""

Daniel "lytedev" Flanagan
http://dmf.me

Application entry point.

"""

"""
import sys, os

from song import Song
from settings import Settings

def main():
	s = Song.load("Dance With Me")
	for v in s.verses.values():
		print(""+str(v)+"\n")

# Entry Point
if __name__=='__main__':
	main()
"""

from wsserver import WebSocketServer
from httpserver import WebInterfaceServerManager
from playlist import Playlist

"""

# Print entire playlist and contents
p = Playlist.load()
print(p)
for s in p.songs: 
	print("\t" + str(s))
	for v in s.verses:
		print("\t\t" + str(v))

# Print current verse, move to next verse, repeat.
print(p.getCurrentVerse())
print(p.nextVerse())
print(p.nextVerse())
print(p.nextVerse())

"""

"""

# Print entire playlist and songs' maps
print(p)
for s in p.songs: 
	print("\t" + str(s))
	for v in s.maps:
		print("\t\t" + str(v))

"""

# Start websocket server for web interface connections
s = WebSocketServer()
s.start()

# Start the http server for serving the webapp pages
h = WebInterfaceServerManager()
h.start()
