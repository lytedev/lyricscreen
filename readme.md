# LyricScreen

A probably-overkill and powerful way of managing lyrics or verse displays for concerts or church services.

## Requirements

* Python >= 3.3
* `asyncio` module (if Python < 3.4) `pip install asyncio`
* `websockets` module `pip install websockets`
* `jsonpickle` module `pip install jsonpickle`

## Basic Usage

Sorry for the barebones stuff here, this whole thing is under heavy development and is highly experimental.

* Add a song file. (Documentation on Song file format needed)
* Add the default playlist (`Playlists/Default.txt`). (Documentation on Playlist file format needed)
* Run the `lyricscreen.py` file to start the server (websocket server AND default web client HTTP server).
* Point your browser at `localhost:8000/console` as specified by the httpserver's instructions.
* Add and setup your necessary displays.

## Concerns

* There is zero security currently implemented. Anyone could theoretically open up their browser and open a console through your http server and do whatever.
* Currently absolutely zero ease-of-use and UX. Eventual goal is run the program and have everything pre configured and managable from one interface without needing to edit configs or restart stuff.

## TODO

* Some sort of config file/system and command line arguments?
	* Specifies hosting info (IP, port)
	* Playlist to load on startup
* Authentication info/system for console connections?
* Better UI/UX for default web admin client
* More complex, optional song formatting options for fancier slides (background images?)
* More of a goal than a TODO, but I would like for everything to be managed from either a default web client (including total control and management of songs and playlist files) or Sublime Text or custom clients.
* I'm sure the code is terribly organized and can be better modularized. In truth, I'm not a Python expert (obviously) and I know all the node people are laughing at me for writing this in Python. <3
