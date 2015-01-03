from http.server import HTTPServer, SimpleHTTPRequestHandler

class WebInterfaceRequestHandler(SimpleHTTPRequestHandler):
	"""docstring for WebInterfaceRequestHandler"""
	def __init__(self, server_address, RequestHandlerClass, b):
		super(WebInterfaceRequestHandler, self).__init__(server_address, RequestHandlerClass, b)

	def do_GET(self):
		self.path = "/WebInterfaces" + self.path

		if self.path == "/WebInterfaces/" or self.path == "/WebInterfaces/console":
			self.path = "/WebInterfaces/console.html"

		if self.path == "/WebInterfaces/display":
			self.path = "/WebInterfaces/display.html"
		
		super(WebInterfaceRequestHandler, self).do_GET()

class WebInterfaceServerManager(object):
	"""docstring for WebInterfaceServerManager"""
	def __init__(self, port=8000, address=""):
		super(WebInterfaceServerManager, self).__init__()
		self.port = port
		self.address = address

	def start(self):
		server_info = (self.address, self.port)
		self.httpd = HTTPServer(server_info, WebInterfaceRequestHandler)
		print("Started HTTP server on port {0}".format(self.port))
		print("    Visit http://localhost:{0} in your browser".format(self.port))
		self.httpd.serve_forever()

if __name__ == "__main__": 
	sm = WebInterfaceServerManager()
	sm.start()