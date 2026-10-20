#!/usr/bin/env python3
"""Serve the repo so the logic-QA board can save rulings into design/qa/logic-pass/rulings.json."""

import json
import os
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
STATE_URL = "/design/qa/logic-pass/rulings.json"
STATE_PATH = os.path.join(ROOT, "design", "qa", "logic-pass", "rulings.json")
PORT = 8757


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def do_POST(self):
        path = self.path.split("?", 1)[0]
        if path != STATE_URL:
            self.send_error(404, "Only the QA rulings file can be saved")
            return
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length)
        try:
            data = json.loads(raw.decode("utf-8"))
        except json.JSONDecodeError:
            self.send_error(400, "Not JSON")
            return
        if not isinstance(data, dict):
            self.send_error(400, "Need an object")
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
    server = ThreadingHTTPServer(("127.0.0.1", PORT), Handler)
    print("Logic QA board at http://127.0.0.1:%s/design/qa/logic-pass/board.html" % PORT, flush=True)
    server.serve_forever()
