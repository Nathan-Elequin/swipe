#!/usr/bin/env python3
"""Serve the repo so the Trait Matrix page can save drags into design/trait-matrix-state.json."""

import json
import os
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STATE_URL = "/design/trait-matrix-state.json"
STATE_PATH = os.path.join(ROOT, "design", "trait-matrix-state.json")


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def do_POST(self):
        path = self.path.split("?", 1)[0]
        if path != STATE_URL:
            self.send_error(404, "Only the trait matrix state can be saved")
            return
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length)
        try:
            data = json.loads(raw.decode("utf-8"))
        except json.JSONDecodeError:
            self.send_error(400, "Not JSON")
            return
        if not isinstance(data, dict) or not isinstance(data.get("monsters"), list) or not isinstance(data.get("items"), list):
            self.send_error(400, "Need monsters and items lists")
            return
        text = json.dumps(data, indent=2, ensure_ascii=False) + "\n"
        tmp = STATE_PATH + ".tmp"
        with open(tmp, "w", encoding="utf-8") as handle:
            handle.write(text)
        os.replace(tmp, STATE_PATH)
        body = b'{"ok":true}'
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        return


if __name__ == "__main__":
    os.chdir(ROOT)
    server = ThreadingHTTPServer(("127.0.0.1", 8756), Handler)
    print("Trait Matrix at http://127.0.0.1:8756/design/trait-matrix.html", flush=True)
    server.serve_forever()
