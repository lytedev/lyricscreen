"""

Daniel "lytedev" Flanagan
http://dmf.me

Application user settings manager.

"""

import json
from pprint import pprint

class Settings(object):
	default_settings_file = "settings.py"

	def __init__(self):
		self.defaults()

	def defaults(self):
		pass

	def save(self):
		print(json.dumps(self, cls=SettingsEncoder))

class SettingsEncoder(json.JSONEncoder):
	def default(self, obj):
		if not isinstance(obj, Settings):
			return super(SettingsEncoder, self).default(obj)
		return obj.__dict__
