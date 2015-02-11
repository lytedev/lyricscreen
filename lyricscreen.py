#!/usr/bin/env python

"""

Daniel "lytedev" Flanagan
http://dmf.me

Application entry point.

"""

import optparse, sys, os, threading, signal, asyncio

from queue import Queue
from wsserver import WebSocketServer
from httpserver import WebInterfaceServerManager
from playlist import Playlist

if __name__ == "__main__":
	# Get event loop for websocket server
	loop = asyncio.get_event_loop()

	# Create server objects
	websocket_server = WebSocketServer(loop=loop)
	http_server = WebInterfaceServerManager()

	# Create server threads
	websocket_server_thread = threading.Thread(target=websocket_server.start)
	http_server_thread = threading.Thread(target=http_server.start)
	websocket_server_thread.daemon = True
	http_server_thread.daemon = True

	# Start threads
	websocket_server_thread.start()
	http_server_thread.start()

	# Create thread queue
	q = Queue()

	# Put threads in queue
	q.put(websocket_server_thread)
	q.put(http_server_thread)

	# Run async event loop
	loop.run_until_complete(websocket_server.sock)
	loop.run_forever()

	# Halt program until threads have run
	q.join()

