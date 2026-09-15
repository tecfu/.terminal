#!/usr/bin/env python3
"""Local URL-opener listener for pi-over-ssh.

Runs on the machine with the browser. Remote hosts forward a port here
(ssh RemoteForward); their `pi-open` helper POSTs the URL it wants opened.
Opens with xdg-open, replies 204. Binds 127.0.0.1 only.
"""
import http.server
import subprocess
import urllib.parse

PORT = 15147


class Handler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path.startswith("/open"):
            qs = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
            url = (qs.get("url") or [""])[0]
            if url:
                try:
                    subprocess.Popen(["xdg-open", url], stdout=subprocess.DEVNULL,
                                     stderr=subprocess.DEVNULL)
                except OSError:
                    pass
            self.send_response(204)
            self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, *args):
        pass


if __name__ == "__main__":
    http.server.HTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
