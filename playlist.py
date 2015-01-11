"""

Daniel "lytedev" Flanagan
http://dmf.me

The song class containing all Song data and the logic for parsing a song from a text file.

"""

import sys
from song import Song
from os import path
from map import Map

playlists_dir = path.abspath(path.dirname(sys.argv[0]) + "/Playlists/")

class Playlist(object):
	def __init__(self):
		self.name = "Playlist"
		self.songs = []
		self.currentSong = -1 
		self.file = ""

		# Display modifiers
		self.isFrozen = False
		self.isBlank = False

	def addSong(s):
		if isinstance(s, Song):
			self.songs.append(s)
		else:
			pass # possibly load song.fromFile(s)

	@staticmethod
	def load(f = "Default"):
		p = Playlist()
		raw_path = path.abspath(playlists_dir + "/" + f + ".txt")
		print(raw_path)
		if path.exists(raw_path):
			p.file = f
		else:
			print("File doesn't exist {0}".format(path.abspath(raw_path)))
			return False
		return p.reload()

	def reload(self): 
		filePath = playlists_dir + "/" + self.file + ".txt"
		if not path.exists(path.abspath(filePath)):
			print("File doesn't exist {0}".format(path.abspath(filePath)))
			return False
		f = open(path.abspath(filePath))
		if not f: 
			print("Failed to open file {0}".format(self.file))
			return False
		self.loadSongs(self.loadHeader(f))
		return self

	def loadHeader(self, f):
		self.name = ""
		for line in f:
			l = line.strip()
			if self.name == "" and l == "":
				pass
			elif self.name != "" and l == "":
				break
			elif l[0] == "#" or (len(l) > 1 and l[0:2] == "//"):
				pass
			elif l != "" and self.name == "":
				self.name = l
		return f

	def loadSongs(self, f):
		self.songs = []
		for line in f:
			l = line.strip()
			if l == "":
				pass
			elif l[0] == "#" or l[0:2] == "//":
				pass
			elif l != "":
				s = Song.load(l)
				if s != False: 
					self.songs.append(s)

	def getCurrentSong(self):
		numSongs = len(self.songs)
		if numSongs == 0: return False
		self.currentSong = max(0, min(self.currentSong, numSongs - 1))
		return self.songs[self.currentSong]

	def getCurrentVerse(self):
		s = self.getCurrentSong()
		if not s: return False
		return s.getCurrentVerse()

	def goToSong(self, song_id): 
		self.currentSong = song_id
		return self.getCurrentSong()

	def nextSong(self): 
		self.currentSong += 1
		return self.getCurrentSong()

	def previousSong(self): 
		self.currentSong -= 1
		return self.getCurrentSong()

	def isAtStart(self):
		return self.currentSong == 0

	def isAtEnd(self):
		return self.currentSong == (len(self.songs) - 1)

	def goToVerse(self, verse_id):
		s = self.getCurrentSong()
		return self.getCurrentSong().goToVerse(verse_id)

	def nextVerse(self):
		s = self.getCurrentSong()
		if s.isAtEnd():
			if not self.isAtEnd(): 
				s = self.nextSong()
				s.restart()
				return self.getCurrentVerse()
			else:
				return False
		return self.getCurrentSong().nextVerse()

	def previousVerse(self):
		s = self.getCurrentSong()
		if s.isAtStart():
			if not self.isAtStart(): 
				s = self.previousSong()
				s.restart()
				return self.getCurrentVerse()
			else:
				return False
		return self.getCurrentSong().previousVerse()

	def isAtSongStart(self):
		return self.currentSong == 0

	def isAtSongEnd(self):
		return self.currentSong == (len(self.songs) - 1)

	def __str__(self):
		return '<Playlist Object {Name: '+self.name+'}>'
