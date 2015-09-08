import lyricscreen
import unittest


class LyricsScreenModuleTest(unittest.TestCase):

    def test_module_load(self):
        def custom_run_settings(settings, args):
            args.suppress_browser_window = True

        def custom_post_startup(settings, args, websocket_server, http_server, loop):
            print("------------ I uhhh dunno, m8: {}".format(loop))
            websocket_server.stop()
            # websocket_server.sock.close()
            loop.stop()
            loop.close()

        lyricscreen.cli.post_settings_loaded_callbacks.append(custom_run_settings)
        lyricscreen.cli.post_startup_callbacks.append(custom_post_startup)
        lyricscreen.cli.main()

