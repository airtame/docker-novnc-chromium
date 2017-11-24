import SimpleHTTPServer
import SocketServer
import os
import json

def settings():
    return {
      'settingsReloadIntervalMinutes': 5,
      'fullscreen': True,
      'autoStart': True if ENABLED else False,
      'websites' : [{'url': url,
                     'duration': ROTATE_DELAY_SECS,
                     'tabReloadIntervalSeconds': ROTATE_DELAY_SECS} for url in URLs.split(' ')]}

def main():
    Handler = SimpleHTTPServer.SimpleHTTPRequestHandler
    httpd = SocketServer.TCPServer(('', HTTP_PORT), Handler)

    with open('{}/{}'.format(HOME_DIR, SETTINGS_FILE), 'w') as outfile:
        json.dump(settings(), outfile, indent=2)


    print 'Serving at port', HTTP_PORT
    httpd.serve_forever()

if __name__ == '__main__':
    HOME_DIR = os.environ.get("HOME", '.').strip()
    HTTP_PORT = int(os.environ.get("HTTP_PORT", 8000))
    SETTINGS_FILE = os.environ.get("SETTINGS_FILE", "tab_rotate.json").strip()
    URLs = os.environ.get("URL", "").strip()
    ROTATE_DELAY_SECS = int(os.environ.get("ROTATE_DELAY_SECS", 60))

    ENABLED = os.environ.get("ENABLE_TAB_ROTATE", "0").strip()
    ENABLED = ENABLED == "1" or ENABLED == "true"

    os.chdir(HOME_DIR)

    main()
