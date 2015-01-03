# LyricScreen

A probably-overkill and powerful way of managing lyrics or verse displays for concerts or church services. 

# Requirements

* Python >= 3.3
* `asyncio` module (if Python < 3.4) `pip install asyncio`
* `websockets` module `pip install websockets`
* `jsonpickle` module `pip install jsonpickle`

# Basic Usage

Sorry for the barebones stuff here, this whole thing is under heavy development and is highly experimental. 

* Add a song file. (Documentation on Song file format needed)
Add the default playlist (`Playlists/Default.txt`). (Documentation on Playlist file format * needed)
* Run the `lyricscreen.py` file to start the websocket server.
* Run the `httpserver.py` file to serve the basic, included web client.
* Point your browser at `localhost:8000` as specified by the httpserver's instructions. 
Add and setup your necessary displays.

# Concerns

* There is zero security currently implemented. Anyone could theoretically open up their browser and open a console through your http server and do whatever. 
* Currently absolutely zero ease-of-use and UX. Eventual goal is run the program and have everything pre configured and managable from one interface without needing to edit configs or restart stuff. 
