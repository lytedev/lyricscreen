"""

Daniel "lytedev" Flanagan
http://dmf.me

Application user settings manager.

"""

import json, os
from pprint import pprint

default_settings_file = "lyricscreen_config.json"

class Settings(dict):
    def __init__(self, file=None):
        self.defaults()
        if file:
            self.file = file
        else:
            self.file = default_settings_file
        self.load()

    def defaults(self):
        self.cfg = {
            "websocket_port": 8417,
            "websocket_host": "0.0.0.0",
            "http_port": 8000,
            "http_host": "0.0.0.0",
        }

    def __getattr__(self, a):
        if a in self:
            return self[a]
        return self.cfg[a]

    def save(self):
        print(json.dumps(self, cls=SettingsEncoder))

    def load(self, file=None):
        print("--- Loading " + self.file)
        if file:
            self.file = file
        if os.path.isfile(self.file):
            json.loads(open(self.file, 'r').read(), cls=SettingsDecoder)

class SettingsEncoder(json.JSONEncoder):
    def default(self, obj):
        if not isinstance(obj, Settings):
            return super(SettingsEncoder, self).default(obj)
        return obj.cfg

class SettingsDecoder(json.JSONDecoder):
    def default(self, s):
        return super(SettingsDecoder, self).default(s)
