import unittest

class LyricsScreenModuleTest(unittest.TestCase):

    def test_module_load(self):
        import ../lyricscreen

        lyricscreen.cli.main()
