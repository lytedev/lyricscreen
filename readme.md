# LyricScreen

NOTE: Undergoing a huge refactor - nobody knows how inaccurate this file is
right now.

A probably-overkill and powerful way of managing lyrics or verse displays for concerts or church services.

**NOTE**: This project is under heavy development and is not recommended for mission-critical functions. 

## Requirements

* Python >= 3.3
* `asyncio` module (if Python < 3.4, `pip install asyncio`)
* `websockets` module (`pip install websockets`)
* `jsonpickle` module (`pip install jsonpickle`)

And for development of the web client, you'll want the following: 

* `npm` **N**ode **P**ackage **M*anager (You'll need `node.js` installed)
* `gulp` Streaming build system (`npm install -g gulp`)
* `bower` Front-end package manager (`npm install -g bower`)

## Basic Usage

* Run `lyricscreen.py` (`python3 lyricscreen.py`).
* Currently, this will start both the websocket server from the big brain of the application and the HTTP server hosting the default web client.
* Point your browser at `localhost:8000/console` as specified by the httpserver's instructions for a management panel and master controls.
* Point your browser at `localhost:8000/display` for a basic words display.

## Development

For web client development, your work is primarily done in the `WebInterface` directory. Run `npm install` to fetch the node modules we use before running `gulp` to build our app. 

You can also use `gulp watch` to continually build as changes are made. If you use a LiveReload plugin, this also sends refresh messages on file changes for a reload. 

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
