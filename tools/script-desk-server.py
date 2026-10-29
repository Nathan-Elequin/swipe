#!/usr/bin/env python3
"""Local Script desk: serve the HTML editor and write player-facing JSON on Save."""

from __future__ import annotations

import json
import posixpath
import sys
from datetime import date, datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]
DESK = ROOT / "design" / "script-desk"
DATA = ROOT / "data"
HOST = "127.0.0.1"
PORT = 8765
TODAY = date.today().isoformat()

COPY_PATH = DATA / "player-copy.json"
LORE_PATH = DATA / "lore.json"
NAMES_PATH = DATA / "script-names.json"
BOARD_PATH = DATA / "content-board.json"
CATALOG_PATH = DATA / "catalog.json"
LEDGER_PATH = DATA / "author-locks.json"
CSV_PATH = DATA / "player-copy.csv"
STAMP_PATH = DATA / "script-desk-last-save.json"

CARD_FIELDS = [
    "name",
    "ability",
    "explainer",
    "call_name",
    "reminder",
    "log_hint",
]

MIME = {
    ".html": "text/html; charset=utf-8",
    ".js": "text/javascript; charset=utf-8",
    ".css": "text/css; charset=utf-8",
    ".json": "application/json; charset=utf-8",
    ".svg": "image/svg+xml",
    ".png": "image/png",
}


def read_json(path: Path) -> dict:
    if not path.exists():
        return {}
    raw = path.read_text(encoding="utf-8-sig")
    parsed = json.loads(raw)
    return parsed if isinstance(parsed, dict) else {}


def write_json(path: Path, data: dict) -> None:
    text = json.dumps(data, indent="\t", ensure_ascii=False)
    if not text.endswith("\n"):
        text += "\n"
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(text, encoding="utf-8")
    tmp.replace(path)


def is_word_char(ch: str) -> bool:
    return ch.isalnum() or ch == "_"


def replace_word(src: str, needle: str, repl: str) -> str:
    if not needle or not src:
        return src
    bits: list[str] = []
    i = 0
    nlen = len(needle)
    while i < len(src):
        at = src.find(needle, i)
        if at < 0:
            bits.append(src[i:])
            break
        if at > i:
            bits.append(src[i:at])
        before_ok = at == 0 or not is_word_char(src[at - 1])
        after_i = at + nlen
        after_ok = after_i >= len(src) or not is_word_char(src[after_i])
        if before_ok and after_ok:
            bits.append(repl)
            i = after_i
        else:
            bits.append(src[at])
            i = at + 1
        if i <= at:
            i = at + 1
    return "".join(bits)


def possessive(display: str) -> str:
    d = display.strip()
    if not d:
        return ""
    return d + "'" if d[-1].lower() == "s" else d + "'s"


def name_pairs(names: list) -> list[tuple[str, str, int]]:
    pairs: list[tuple[str, str, int]] = []
    for row in names:
        if not isinstance(row, dict):
            continue
        nid = str(row.get("id", "")).strip()
        display = str(row.get("display", ""))
        if not nid or not display:
            continue
        poss = possessive(display)
        pairs.append((poss, "{%s|poss}" % nid, len(display) + 2))
        pairs.append((display, "{%s}" % nid, len(display)))
    pairs.sort(key=lambda p: p[2], reverse=True)
    return pairs


def tokenize(filled: str, pairs: list[tuple[str, str, int]]) -> str:
    out = filled
    for needle, repl, _ in pairs:
        out = replace_word(out, needle, repl)
    return out


def apply_names(text: str, names: list) -> str:
    out = text
    rows = [r for r in names if isinstance(r, dict) and str(r.get("display", ""))]
    rows.sort(key=lambda r: len(str(r.get("id", ""))), reverse=True)
    for row in rows:
        nid = str(row.get("id", ""))
        display = str(row.get("display", ""))
        out = out.replace("{%s|poss}" % nid, possessive(display))
        out = out.replace("{%s}" % nid, display)
    return out


def script_rows(copy: dict) -> list[dict]:
    out = []
    for row in copy.get("rows", []):
        if not isinstance(row, dict):
            continue
        if str(row.get("cat", "")) == "Cards":
            continue
        item = dict(row)
        item["src"] = "copy"
        out.append(item)
    return out


def lore_rows(lore: dict) -> list[dict]:
    out: list[dict] = []
    out.append(
        {
            "src": "lore",
            "cat": "Journal",
            "key": "lore.engraving",
            "where": "Trophy hall engraving",
            "text": str(lore.get("engraving", "")),
            "author_lock": bool(lore.get("engraving_lock", False)),
        }
    )
    items = lore.get("items", {}) if isinstance(lore.get("items", {}), dict) else {}
    for iid, entry in items.items():
        ent = entry if isinstance(entry, dict) else {}
        st = str(ent.get("status", ""))
        name_ref = str(ent.get("name_ref", iid))
        out.append(
            {
                "src": "lore",
                "cat": "Journal",
                "key": "lore.item.%s.journal" % iid,
                "where": "Curiosities · %s (%s)" % (name_ref, st),
                "text": str(ent.get("journal", "")),
            }
        )
        fns = ent.get("footnotes", []) if isinstance(ent.get("footnotes", []), list) else []
        for i, fn in enumerate(fns):
            out.append(
                {
                    "src": "lore",
                    "cat": "Journal",
                    "key": "lore.item.%s.fn.%d" % (iid, i),
                    "where": "Curiosities · %s footnote %d" % (name_ref, i + 1),
                    "text": str(fn),
                }
            )
    monsters = lore.get("monsters", {}) if isinstance(lore.get("monsters", {}), dict) else {}
    for mid, ment in monsters.items():
        m = ment if isinstance(ment, dict) else {}
        out.append(
            {
                "src": "lore",
                "cat": "Journal",
                "key": "lore.monster.%s.entry" % mid,
                "where": "Bestiary · %s (%s)" % (str(m.get("name_ref", mid)), str(m.get("status", ""))),
                "text": str(m.get("entry", "")),
            }
        )
    for letter in lore.get("letters", []) if isinstance(lore.get("letters", []), list) else []:
        if not isinstance(letter, dict):
            continue
        lid = str(letter.get("id", ""))
        out.append(
            {
                "src": "lore",
                "cat": "Journal",
                "key": "lore.letter.%s.title" % lid,
                "where": "Trunk letter · %s title (unlock %s%%)"
                % (lid, str(letter.get("unlock_pct", ""))),
                "text": str(letter.get("title", "")),
            }
        )
        out.append(
            {
                "src": "lore",
                "cat": "Journal",
                "key": "lore.letter.%s.body" % lid,
                "where": "Trunk letter · %s body" % lid,
                "text": str(letter.get("body", "")),
            }
        )
    note = lore.get("drawer_note", {}) if isinstance(lore.get("drawer_note", {}), dict) else {}
    if note:
        out.append(
            {
                "src": "lore",
                "cat": "Drawer",
                "key": "lore.drawer.title",
                "where": "Left-hand drawer note title",
                "text": str(note.get("title", "")),
            }
        )
        out.append(
            {
                "src": "lore",
                "cat": "Drawer",
                "key": "lore.drawer.body",
                "where": "Left-hand drawer note body",
                "text": str(note.get("body", "")),
            }
        )
    return out


def card_snapshot(board: dict) -> list[dict]:
    out: list[dict] = []
    for kind, arr in (("item", board.get("items", [])), ("monster", board.get("monsters", []))):
        if not isinstance(arr, list):
            continue
        for card in arr:
            if not isinstance(card, dict):
                continue
            st = str(card.get("status", ""))
            if st == "retired":
                continue
            cid = str(card.get("id", ""))
            name = str(card.get("name", cid))
            locked = bool(card.get("author_lock", False))
            out.append(
                {
                    "src": "card",
                    "cat": "Cards",
                    "key": "card.%s.%s.name" % (kind, cid),
                    "where": "%s name (%s)" % (kind, st),
                    "text": name,
                    "author_lock": locked,
                }
            )
            out.append(
                {
                    "src": "card",
                    "cat": "Cards",
                    "key": "card.%s.%s.ability" % (kind, cid),
                    "where": "%s Ability (%s)" % (kind, name),
                    "text": str(card.get("ability", "")),
                    "author_lock": locked,
                }
            )
            out.append(
                {
                    "src": "card",
                    "cat": "Cards",
                    "key": "card.%s.%s.explainer" % (kind, cid),
                    "where": "%s Shift Text (%s)" % (kind, name),
                    "text": str(card.get("explainer", "")),
                    "author_lock": locked,
                }
            )
            out.append(
                {
                    "src": "card",
                    "cat": "Cards",
                    "key": "card.%s.%s.log_hint" % (kind, cid),
                    "where": "%s log hover (%s)" % (kind, name),
                    "text": str(card.get("log_hint", "")),
                    "author_lock": locked,
                }
            )
            if kind == "monster":
                out.append(
                    {
                        "src": "card",
                        "cat": "Cards",
                        "key": "card.%s.%s.call_name" % (kind, cid),
                        "where": "%s Call name (%s)" % (kind, name),
                        "text": str(card.get("call_name", "")),
                        "author_lock": locked,
                    }
                )
                out.append(
                    {
                        "src": "card",
                        "cat": "Cards",
                        "key": "card.%s.%s.reminder" % (kind, cid),
                        "where": "%s Shift Text (%s)" % (kind, name),
                        "text": str(card.get("reminder", "")),
                        "author_lock": locked,
                    }
                )
    return out


def differs(a, b) -> bool:
    return json.dumps(a, sort_keys=True, ensure_ascii=False) != json.dumps(
        b, sort_keys=True, ensure_ascii=False
    )


def stamp_script_row(entry: dict, previous: dict) -> None:
    was = bool(entry.get("author_lock", False)) or bool(previous.get("author_lock", False))
    changed = differs(entry.get("text", ""), previous.get("text", ""))
    if not was and not changed:
        return
    entry["author_lock"] = True
    entry["locked_at"] = TODAY


def stamp_card(card: dict, previous: dict, field: str) -> None:
    fields = []
    prev_f = previous.get("locked_fields", [])
    if isinstance(prev_f, list):
        for x in prev_f:
            s = str(x)
            if s and s not in fields:
                fields.append(s)
    if field not in fields:
        fields.append(field)
    card["author_lock"] = True
    card["locked_fields"] = fields
    card["locked_at"] = TODAY


def csv_cell(s: str) -> str:
    if any(ch in s for ch in ',"\n\r'):
        return '"%s"' % s.replace('"', '""')
    return s


def write_csv(rows: list[dict]) -> None:
    lines = ["\ufeffcategory,key,where,text"]
    for row in rows:
        if not isinstance(row, dict):
            continue
        lines.append(
            ",".join(
                csv_cell(str(row.get(k, "")))
                for k in ("cat", "key", "where", "text")
            )
        )
    CSV_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")


def save_pack(payload: dict) -> dict:
    copy = read_json(COPY_PATH)
    lore = read_json(LORE_PATH)
    names_pack = read_json(NAMES_PATH)
    board = read_json(BOARD_PATH)
    catalog = read_json(CATALOG_PATH)
    incoming_rows = payload.get("rows", [])
    incoming_names = payload.get("names", [])
    if not isinstance(incoming_rows, list) or not isinstance(incoming_names, list):
        raise ValueError("rows and names must be arrays")

    prev_names = {
        str(r.get("id", "")): r
        for r in names_pack.get("names", [])
        if isinstance(r, dict)
    }
    kept_names = []
    for row in incoming_names:
        if not isinstance(row, dict):
            continue
        nid = str(row.get("id", "")).strip()
        if not nid:
            continue
        previous = prev_names.get(nid, {})
        if not isinstance(previous, dict):
            previous = {}
        entry = {
            "id": nid,
            "display": str(row.get("display", "")),
            "note": str(row.get("note", "")),
        }
        if bool(row.get("author_lock", False)) or bool(previous.get("author_lock", False)):
            entry["author_lock"] = True
            entry["locked_at"] = str(row.get("locked_at", previous.get("locked_at", TODAY)))
        if differs(entry.get("display", ""), previous.get("display", "")) or differs(
            entry.get("note", ""), previous.get("note", "")
        ):
            entry["author_lock"] = True
            entry["locked_at"] = TODAY
        kept_names.append(entry)
    if not str(names_pack.get("id", "")):
        names_pack["id"] = "swipe-script-names-v1"
    names_pack["updated"] = TODAY
    names_pack["instructions"] = (
        "Shared proper names. Lines store {id} and {id|poss}. Script desk Save locks a changed display. Chat may not restyle locked names unless Nathan overrides."
    )
    names_pack["names"] = kept_names
    pairs = name_pairs(kept_names)

    prev_copy = {
        str(r.get("key", "")): r for r in copy.get("rows", []) if isinstance(r, dict)
    }
    kept_copy = []
    for row in incoming_rows:
        if not isinstance(row, dict):
            continue
        src = str(row.get("src", "copy"))
        if src != "copy":
            continue
        if str(row.get("cat", "")) == "Cards":
            continue
        key = str(row.get("key", ""))
        if key.startswith("lore.") or key.startswith("card."):
            continue
        previous = prev_copy.get(key, {})
        if not isinstance(previous, dict):
            previous = {}
        entry = dict(previous)
        entry["cat"] = str(row.get("cat", previous.get("cat", "")))
        entry["key"] = key
        entry["where"] = str(row.get("where", previous.get("where", "")))
        entry["text"] = tokenize(str(row.get("text", "")), pairs)
        for extra in (
            "dir",
            "wait",
            "focus",
            "hint",
            "go",
            "branch",
            "force",
            "then_focus",
            "nib",
            "tiny",
        ):
            if extra not in row:
                continue
            val = row[extra]
            if extra == "tiny":
                if isinstance(val, bool):
                    entry[extra] = val
                else:
                    entry[extra] = str(val).strip().lower() in ("1", "true", "yes")
            elif extra == "nib":
                try:
                    entry[extra] = float(val)
                except (TypeError, ValueError):
                    entry[extra] = val
            else:
                entry[extra] = val
        if bool(row.get("draft", False)) or bool(previous.get("draft", False)):
            entry["draft"] = True
        if bool(row.get("author_lock", False)):
            entry["author_lock"] = True
            entry["locked_at"] = str(row.get("locked_at", ""))
        stamp_script_row(entry, previous)
        kept_copy.append(entry)
    if not str(copy.get("id", "")):
        copy["id"] = "swipe-player-copy-v2"
    copy["updated"] = TODAY
    copy["instructions"] = "Player-facing prose: Jam owns data/player-copy.json; keep board in sync on Save."
    copy["rows"] = kept_copy

    for row in incoming_rows:
        if not isinstance(row, dict) or str(row.get("src", "")) != "lore":
            continue
        key = str(row.get("key", ""))
        t = tokenize(str(row.get("text", "")), pairs)
        if key == "lore.engraving":
            lore["engraving"] = t
            continue
        if key == "lore.drawer.title":
            dn = lore.get("drawer_note", {}) if isinstance(lore.get("drawer_note", {}), dict) else {}
            dn["title"] = t
            lore["drawer_note"] = dn
            continue
        if key == "lore.drawer.body":
            dn = lore.get("drawer_note", {}) if isinstance(lore.get("drawer_note", {}), dict) else {}
            dn["body"] = t
            lore["drawer_note"] = dn
            continue
        parts = key.split(".")
        if len(parts) >= 4 and parts[1] == "item":
            iid = parts[2]
            items = lore.get("items", {}) if isinstance(lore.get("items", {}), dict) else {}
            ent = items.get(iid, {}) if isinstance(items.get(iid, {}), dict) else {}
            if parts[3] == "journal":
                ent["journal"] = t
            elif parts[3] == "fn" and len(parts) >= 5:
                fns = ent.get("footnotes", []) if isinstance(ent.get("footnotes", []), list) else []
                idx = int(parts[4])
                while len(fns) <= idx:
                    fns.append("")
                fns[idx] = t
                ent["footnotes"] = fns
            items[iid] = ent
            lore["items"] = items
        elif len(parts) >= 4 and parts[1] == "monster" and parts[3] == "entry":
            monsters = lore.get("monsters", {}) if isinstance(lore.get("monsters", {}), dict) else {}
            ment = monsters.get(parts[2], {}) if isinstance(monsters.get(parts[2], {}), dict) else {}
            ment["entry"] = t
            monsters[parts[2]] = ment
            lore["monsters"] = monsters
        elif len(parts) >= 4 and parts[1] == "letter":
            letters = lore.get("letters", []) if isinstance(lore.get("letters", []), list) else []
            for i, letter in enumerate(letters):
                if not isinstance(letter, dict):
                    continue
                if str(letter.get("id", "")) != parts[2]:
                    continue
                if parts[3] == "title":
                    letter["title"] = t
                elif parts[3] == "body":
                    letter["body"] = t
                letters[i] = letter
            lore["letters"] = letters
    lore["updated"] = TODAY

    by_card = {}
    for kind, arr in (("item", board.get("items", [])), ("monster", board.get("monsters", []))):
        if not isinstance(arr, list):
            continue
        for i, card in enumerate(arr):
            if isinstance(card, dict):
                by_card["%s:%s" % (kind, str(card.get("id", "")))] = {
                    "kind": kind,
                    "idx": i,
                    "prev": dict(card),
                }
    touched_cards = False
    for row in incoming_rows:
        if not isinstance(row, dict):
            continue
        if str(row.get("src", "")) != "card" and str(row.get("cat", "")) != "Cards":
            continue
        key = str(row.get("key", ""))
        bits = key.split(".")
        if len(bits) < 4 or bits[0] != "card":
            continue
        kind2, cid, field = bits[1], bits[2], bits[3]
        slot = by_card.get("%s:%s" % (kind2, cid))
        if not slot:
            continue
        arr2 = board.get("items" if kind2 == "item" else "monsters", [])
        idx = slot["idx"]
        if idx < 0 or idx >= len(arr2):
            continue
        card = arr2[idx]
        previous = slot["prev"]
        new_text = tokenize(str(row.get("text", "")), pairs)
        if not differs(card.get(field, ""), new_text):
            continue
        card[field] = new_text
        stamp_card(card, previous, field)
        arr2[idx] = card
        board["items" if kind2 == "item" else "monsters"] = arr2
        touched_cards = True
    if touched_cards:
        board["updated"] = TODAY

    if touched_cards and catalog:
        for kind, arr in (("item", board.get("items", [])), ("monster", board.get("monsters", []))):
            cat_arr = catalog.get("items" if kind == "item" else "monsters", [])
            if not isinstance(cat_arr, list) or not isinstance(arr, list):
                continue
            by_id = {
                str(c.get("id", "")): c for c in cat_arr if isinstance(c, dict)
            }
            for card in arr:
                if not isinstance(card, dict):
                    continue
                dst = by_id.get(str(card.get("id", "")))
                if not dst:
                    continue
                for f in CARD_FIELDS:
                    if f in card:
                        dst[f] = card.get(f, "")
                dst["author_lock"] = bool(card.get("author_lock", False))
                dst["locked_fields"] = card.get("locked_fields", dst.get("locked_fields", []))
                dst["locked_at"] = str(card.get("locked_at", dst.get("locked_at", "")))

    cards_ledger = {}
    for kind, arr in (("item", board.get("items", [])), ("monster", board.get("monsters", []))):
        if not isinstance(arr, list):
            continue
        for card in arr:
            if not isinstance(card, dict) or not bool(card.get("author_lock", False)):
                continue
            cid = str(card.get("id", ""))
            if not cid:
                continue
            cards_ledger["%s:%s" % (kind, cid)] = {
                "name": str(card.get("name", cid)),
                "fields": card.get("locked_fields", []),
                "locked_at": str(card.get("locked_at", "")),
            }
    script_ledger = {}
    for row in kept_copy:
        if not bool(row.get("author_lock", False)):
            continue
        k = str(row.get("key", ""))
        if not k:
            continue
        script_ledger[k] = {
            "cat": str(row.get("cat", "")),
            "where": str(row.get("where", "")),
            "text": str(row.get("text", "")),
            "locked_at": str(row.get("locked_at", "")),
        }
    name_locks = {}
    for nrow in kept_names:
        if not bool(nrow.get("author_lock", False)):
            continue
        nid = str(nrow.get("id", ""))
        if not nid:
            continue
        name_locks[nid] = {
            "display": str(nrow.get("display", "")),
            "note": str(nrow.get("note", "")),
            "locked_at": str(nrow.get("locked_at", "")),
        }
    ledger = {
        "id": "boss-rush-author-locks",
        "updated": TODAY,
        "instructions": "Nathan locked these by clicking Save in Roster, the card editor, the Script desk, or the HTML board. Do not restyle them. A gold-box note that replaces a field is the overwrite. If chat asks to change a locked field with no gold-box note, stop, name the keys, and wait for a yes.",
        "cards": cards_ledger,
        "script": script_ledger,
        "names": name_locks,
    }

    write_json(NAMES_PATH, names_pack)
    write_json(COPY_PATH, copy)
    write_json(LORE_PATH, lore)
    if touched_cards:
        write_json(BOARD_PATH, board)
        write_json(CATALOG_PATH, catalog)
    write_json(LEDGER_PATH, ledger)
    write_csv(kept_copy + card_snapshot(board))
    stamp = {
        "saved_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "files": [
            "data/player-copy.json",
            "data/lore.json",
            "data/script-names.json",
            "data/author-locks.json",
            "data/player-copy.csv",
        ],
        "cards_touched": touched_cards,
    }
    if touched_cards:
        stamp["files"].extend(["data/content-board.json", "data/catalog.json"])
    write_json(STAMP_PATH, stamp)
    return {
        "ok": True,
        "saved_at": stamp["saved_at"],
        "copy_rows": len(kept_copy),
        "names": len(kept_names),
        "cards_touched": touched_cards,
        "path": str(COPY_PATH),
    }


def pack_payload() -> dict:
    copy = read_json(COPY_PATH)
    lore = read_json(LORE_PATH)
    names_pack = read_json(NAMES_PATH)
    board = read_json(BOARD_PATH)
    names = [r for r in names_pack.get("names", []) if isinstance(r, dict)]
    rows = script_rows(copy) + lore_rows(lore) + card_snapshot(board)
    shown = []
    for row in rows:
        item = dict(row)
        item["shown"] = apply_names(str(item.get("text", "")), names)
        shown.append(item)
    return {
        "copy_id": str(copy.get("id", "")),
        "updated": str(copy.get("updated", "")),
        "names": names,
        "rows": shown,
    }


class Server(ThreadingHTTPServer):
    allow_reuse_address = False


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    def log_message(self, fmt: str, *args) -> None:
        sys.stderr.write("%s - %s\n" % (self.address_string(), fmt % args))

    def _cors(self) -> None:
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Cache-Control", "no-store")

    def do_OPTIONS(self) -> None:
        self.send_response(204)
        self._cors()
        self.end_headers()

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path == "/api/pack":
            body = json.dumps(pack_payload(), ensure_ascii=False).encode("utf-8")
            self.send_response(200)
            self._cors()
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Connection", "close")
            self.end_headers()
            self.wfile.write(body)
            return
        rel = parsed.path.lstrip("/")
        if rel == "" or rel == "index.html":
            target = DESK / "index.html"
        else:
            safe = posixpath.normpath(rel).lstrip("/")
            target = DESK / safe
        try:
            target.resolve().relative_to(DESK.resolve())
        except ValueError:
            self.send_error(403)
            return
        if not target.is_file():
            self.send_error(404)
            return
        data = target.read_bytes()
        self.send_response(200)
        self._cors()
        self.send_header("Content-Type", MIME.get(target.suffix.lower(), "application/octet-stream"))
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Connection", "close")
        self.end_headers()
        self.wfile.write(data)

    def do_POST(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path != "/api/save":
            self.send_error(404)
            return
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length)
        try:
            payload = json.loads(raw.decode("utf-8"))
            result = save_pack(payload)
            body = json.dumps(result, ensure_ascii=False).encode("utf-8")
            self.send_response(200)
        except Exception as exc:
            body = json.dumps({"ok": False, "error": str(exc)}).encode("utf-8")
            self.send_response(400)
        self._cors()
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Connection", "close")
        self.end_headers()
        self.wfile.write(body)


def main() -> None:
    try:
        httpd = Server((HOST, PORT), Handler)
    except OSError as exc:
        sys.stderr.write("Could not bind %s:%s (%s). If the desk is already open, use that tab.\n" % (HOST, PORT, exc))
        sys.exit(1)
    print("Script desk http://%s:%s/" % (HOST, PORT), flush=True)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
