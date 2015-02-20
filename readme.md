# LyricScreen

A probably-overkill and powerful way of managing lyrics or verse displays for concerts or church services.

## Requirements

* Python >= 3.3
* `asyncio` module (if Python < 3.4) `pip install asyncio`
* `websockets` module `pip install websockets`
* `jsonpickle` module `pip install jsonpickle`

## Basic Usage

Sorry for the barebones stuff here, this whole thing is under heavy development and is highly experimental.

* Run `lyricscreen.py` (`python3 lyricscreen.py`).
* Currently, this will start both the websocket server from the big brain of the application and the HTTP server hosting the default web client.
* Point your browser at `localhost:8000/console` as specified by the httpserver's instructions for a management panel and master controls.
* Point your browser at `localhost:8000/display` for a basic words display.

## Concerns

* There is zero security currently implemented. Anyone could theoretically open up their browser and open a console through your http server and do whatever they want.
* Currently absolutely zero ease-of-use and UX. Eventual goal is run the program and have everything pre configured and managable from one interface without needing to edit configs or restart stuff. See TODO list.

## TODO

* Some sort of config file/system and/or command line arguments?
	* Specifies hosting info (IP, port)
	* Playlist to load on startup
* Authentication info/system for console connections?
  * Idea: on-run, prompt or generate an admin password, require initial auth from "console" connections. Should be fine enough for short term?
* Better UX for default web admin client
* More complex, optional song formatting options for fancier slides (background images? text-align? Google fonts?)
* Playlist creation/saving/modification/loading/listing/viewing
* Song creation/saving/modification/loading/listing/viewing
* Always: prettier, better organized code (conform to Python code standards and have properly formatted docstrings)
