import sys, re

from os import path
from http.server import HTTPServer, SimpleHTTPRequestHandler

local_web_root = "/http"
web_root = path.abspath(path.dirname(__file__) + "/.." + local_web_root)

class WebInterfaceRequestHandler(SimpleHTTPRequestHandler):
    """Simple request handler for our default web interface"""
    def __init__(self, server_address, RequestHandlerClass, b):
        super(WebInterfaceRequestHandler, self).__init__(server_address, RequestHandlerClass, b)

    def do_GET(self):
        """Handle HTTP GET requests"""
        # Force virtual web root to be in the web root (except references to data files)
        if not self.path.startswith("/data/"):
            self.path = local_web_root + self.path

        # Simple redirects for the console page
        if self.path == local_web_root + "/console" or self.path == local_web_root + "/admin":
            self.path = local_web_root + "/console.html"

        # Simple redirects for the display
        if self.path == local_web_root + "/" or self.path == local_web_root + "/display" or self.path == "/":
            self.path = local_web_root + "/display.html"

        # Basic request handler
        super(WebInterfaceRequestHandler, self).do_GET()


class WebInterfaceServerManager(object):
    """Simple HTTP server manager"""
    def __init__(self, address="", port=8000):
        super(WebInterfaceServerManager, self).__init__()
        self.port = port
        self.address = address

    def start(self):
        server_info = (self.address, self.port)
        addr = self.address
        if addr.strip() == "":
            addr = "0.0.0.0"
        self.httpd = HTTPServer(server_info, WebInterfaceRequestHandler)
        print("Started HTTP server on {1}:{0}".format(self.port, addr))
        print("    Visit http://localhost:{0}/console in your browser".format(self.port))
        self.httpd.serve_forever()

def is_valid_hostname(hostname):
    """Validate a hostname"""
    """
        Credit: @tim-pietzcker of Stack Overflow
        http://stackoverflow.com/questions/2532053/validate-a-hostname-string
    """
    if len(hostname) > 255:
        return False
    if hostname[-1] == ".":
        hostname = hostname[:-1]
    allowed = re.compile("(?!-)[A-Z\d-]{1,63}(?<!-)$", re.IGNORECASE)
    return all(allowed.match(x) for x in hostname.split("."))

def usage():
    """Present command line documentation"""
    print("Usage: python httpserver.py [port] [host_address]")
    print("  port            The port to listen on for HTTP requests. Default: 8000")
    print("  host_address    The address to listen on for HTTP requests. Default: 0.0.0.0")

if __name__ == "__main__":
    port = 8000
    addr = ""
    # Check if port was specified
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
        except ValueError:
            print("Error: Could not parse given port value '{0}'.".format(sys.argv[1]))
            usage()
    # Check if host address was specified
    if len(sys.argv) > 2:
        if is_valid_hostname(sys.argv[2]):
            addr = sys.argv[2]
        else:
            print("Error: Invalid hostname '{0}'.".format(sys.argv[2]))
            usage()
    sm = WebInterfaceServerManager(addr, port)
    sm.start()
