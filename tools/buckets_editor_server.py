"""Serve design/pools.html and write saves into data/*.json (repo root).

Run: py -3 tools/buckets_editor_server.py
Open: http://127.0.0.1:8767/pools.html
"""
from __future__ import annotations

import json
import re
import sys
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DESIGN = ROOT / "design"
DATA = ROOT / "data"
HOST = "127.0.0.1"
PORT = 8767
_art_cache: dict = {"mtime": None, "body": b""}


def live_art_bytes() -> bytes:
    """Build the sprite map from dungeon_art.gd so new cards are not stuck on an old snapshot."""
    gd = ROOT / "scripts" / "dungeon_art.gd"
    mtime = gd.stat().st_mtime
    if _art_cache["mtime"] == mtime and _art_cache["body"]:
        return _art_cache["body"]
    text = gd.read_text(encoding="utf-8")

    def extract(name: str) -> dict:
        m = re.search(rf"const {name} := \{{", text)
        if not m:
            return {}
        start = m.end()
        depth = 1
        i = start
        while i < len(text) and depth:
            if text[i] == "{":
                depth += 1
            elif text[i] == "}":
                depth -= 1
            i += 1
        out = {}
        for line in text[start : i - 1].splitlines():
            mm = re.match(r'\s*"([^"]+)":\s*"res://([^"]+)"', line)
            if not mm:
                continue
            rel = mm.group(2).replace("\\", "/").lstrip("/")
            if rel.startswith("assets/"):
                rel = rel[len("assets/") :]
            out[mm.group(1)] = "/assets/" + rel
        return out

    body = (json.dumps({"items": extract("ITEM_PNG"), "monsters": extract("MONSTER_PNG")}) + "\n").encode("utf-8")
    _art_cache["mtime"] = mtime
    _art_cache["body"] = body
    return body


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(DESIGN), **kwargs)

    def log_message(self, fmt, *args):
        sys.stderr.write("%s - %s\n" % (self.address_string(), fmt % args))

    def _send_json(self, code: int, payload: dict) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body)

    def _read_json_body(self) -> dict | None:
        length = int(self.headers.get("Content-Length", "0"))
        if length <= 0:
            return None
        raw = self.rfile.read(length)
        try:
            data = json.loads(raw.decode("utf-8"))
        except json.JSONDecodeError:
            return None
        return data if isinstance(data, dict) else None

    def _write_json_file(self, path: Path, data: dict) -> None:
        text = json.dumps(data, indent="\t", ensure_ascii=False) + "\n"
        tmp = path.with_suffix(path.suffix + ".tmp")
        tmp.write_text(text, encoding="utf-8")
        tmp.replace(path)

    def do_OPTIONS(self) -> None:
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_GET(self) -> None:
        if self.path == "/api/health":
            self._send_json(200, {"ok": True, "repo": str(ROOT)})
            return
        if self.path.startswith("/assets/"):
            rel = self.path[len("/assets/") :].split("?", 1)[0]
            fp = (ROOT / "assets" / rel).resolve()
            if not str(fp).startswith(str((ROOT / "assets").resolve())):
                self.send_error(403)
                return
            if fp.is_file():
                self._serve_binary_file(fp)
                return
            self.send_error(404)
            return
        if self.path == "/data/content-board.json":
            self._serve_data_file(DATA / "content-board.json")
            return
        if self.path == "/data/catalog.json":
            self._serve_data_file(DATA / "catalog.json")
            return
        if self.path == "/data/buckets-art.json":
            body = live_art_bytes()
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            self.wfile.write(body)
            return
        super().do_GET()

    def _serve_binary_file(self, path: Path) -> None:
        data = path.read_bytes()
        ctype = "application/octet-stream"
        if path.suffix.lower() == ".png":
            ctype = "image/png"
        elif path.suffix.lower() in (".jpg", ".jpeg"):
            ctype = "image/jpeg"
        self.send_response(200)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Cache-Control", "public, max-age=3600")
        self.end_headers()
        self.wfile.write(data)

    def _serve_data_file(self, path: Path) -> None:
        if not path.is_file():
            self.send_error(404, "Not found")
            return
        data = path.read_bytes()
        self.send_response(200)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(data)

    def do_POST(self) -> None:
        if self.path == "/api/save-board":
            data = self._read_json_body()
            if not data:
                self._send_json(400, {"ok": False, "error": "bad json"})
                return
            try:
                self._write_json_file(DATA / "content-board.json", data)
            except OSError as e:
                self._send_json(500, {"ok": False, "error": str(e)})
                return
            self._send_json(200, {"ok": True, "path": "data/content-board.json"})
            return
        if self.path == "/api/save-catalog":
            data = self._read_json_body()
            if not data:
                self._send_json(400, {"ok": False, "error": "bad json"})
                return
            try:
                self._write_json_file(DATA / "catalog.json", data)
            except OSError as e:
                self._send_json(500, {"ok": False, "error": str(e)})
                return
            self._send_json(200, {"ok": True, "path": "data/catalog.json"})
            return
        if self.path == "/api/save-both":
            data = self._read_json_body()
            if not data or "board" not in data or "catalog" not in data:
                self._send_json(400, {"ok": False, "error": "need board and catalog keys"})
                return
            try:
                self._write_json_file(DATA / "content-board.json", data["board"])
                self._write_json_file(DATA / "catalog.json", data["catalog"])
            except OSError as e:
                self._send_json(500, {"ok": False, "error": str(e)})
                return
            self._send_json(200, {"ok": True})
            return
        self.send_error(404)


def main() -> None:
    httpd = ThreadingHTTPServer((HOST, PORT), Handler)
    url = f"http://{HOST}:{PORT}/buckets.html"
    print(f"Bucket editor — {url}")
    print(f"Writes saves to {DATA}")
    print("Ctrl+C to stop.")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")


if __name__ == "__main__":
    main()
