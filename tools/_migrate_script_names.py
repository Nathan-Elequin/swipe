# One-shot: tokenise proper names in player-copy.json and lore.json.
# Ambiguous leftovers print to stdout. Do not replace lowercase lucky/grumble.
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
NAMES_PATH = ROOT / "data" / "script-names.json"
COPY_PATH = ROOT / "data" / "player-copy.json"
LORE_PATH = ROOT / "data" / "lore.json"

SKIP_STANDALONE = {"lucky"}  # adjective hazard; Lucky Snatchwick and quoted Lucky still convert
NEW_COPY = [
    {"cat": "Combat", "key": "combat.log", "where": "Combat log button, closed", "text": "Log"},
    {"cat": "Combat", "key": "combat.log_hide", "where": "Combat log button, open", "text": "Hide log"},
    {"cat": "Combat", "key": "combat.used", "where": "Spent item overlay on a hand card", "text": "USED"},
    {"cat": "Title", "key": "bucket.title", "where": "New bucket reveal headline", "text": "As you venture deeper, new Loot and Foes reveal themselves."},
    {"cat": "Title", "key": "bucket.sub", "where": "New bucket reveal subtitle", "text": "Hover a shadow to see what it is. From now on, these can show up in every dungeon."},
    {"cat": "Title", "key": "bucket.onward", "where": "New bucket reveal continue", "text": "Onward"},
    {"cat": "Title", "key": "bucket.loot", "where": "New bucket reveal loot heading", "text": "Loot"},
    {"cat": "Title", "key": "bucket.foes", "where": "New bucket reveal foes heading", "text": "Foes"},
    {"cat": "Title", "key": "bucket.hover", "where": "New bucket reveal empty hover", "text": "Hover a shadow."},
    {"cat": "Inspect", "key": "keyword.always", "where": "Keyword tip title for Always", "text": "Always"},
    {"cat": "Inspect", "key": "keyword.always_body", "where": "Keyword tip body for Always", "text": "cannot be changed in any other way"},
    {"cat": "Tutorial", "key": "tutorial.next", "where": "How to Play continue button", "text": "Next"},
    {"cat": "Title", "key": "challenge.pick_hover", "where": "Challenge pick-two hover hint", "text": "Pick one. Hover to read it."},
]


def possessive(display: str) -> str:
    if not display:
        return ""
    if display[-1].lower() == "s":
        return display + "'"
    return display + "'s"


def load_names() -> list[dict]:
    pack = json.loads(NAMES_PATH.read_text(encoding="utf-8"))
    return list(pack.get("names", []))


def pairs_for(names: list[dict]) -> list[tuple[str, str, str]]:
    # (needle, token, id) longest first; poss before base of same length via +2
    out: list[tuple[int, str, str, str]] = []
    for row in names:
        nid = row["id"]
        display = row["display"]
        if nid in SKIP_STANDALONE:
            continue
        poss = possessive(display)
        out.append((len(poss), poss, "{%s|poss}" % nid, nid))
        out.append((len(display), display, "{%s}" % nid, nid))
    # Quoted Lucky
    out.append((len('"Lucky"'), '"Lucky"', '"{lucky}"', "lucky"))
    out.append((len("'Lucky'"), "'Lucky'", "'{lucky}'", "lucky"))
    out.sort(key=lambda x: -x[0])
    return [(n, t, i) for _, n, t, i in out]


def replace_word(text: str, needle: str, token: str) -> tuple[str, int]:
    if not needle or needle in token and token.startswith("{") and needle in text and False:
        pass
    count = 0
    i = 0
    out = []
    nlen = len(needle)
    while i < len(text):
        at = text.find(needle, i)
        if at < 0:
            out.append(text[i:])
            break
        before = text[at - 1] if at > 0 else ""
        after = text[at + nlen] if at + nlen < len(text) else ""
        before_ok = at == 0 or not _word(before)
        after_ok = at + nlen >= len(text) or not _word(after)
        # Do not retokenise inside existing {braces}
        if before_ok and after_ok and not _inside_braces(text, at):
            out.append(text[i:at])
            out.append(token)
            i = at + nlen
            count += 1
        else:
            out.append(text[i : at + 1])
            i = at + 1
    return "".join(out), count


def _word(ch: str) -> bool:
    return ch.isalnum() or ch == "_"


def _inside_braces(text: str, at: int) -> bool:
    left = text.rfind("{", 0, at)
    if left < 0:
        return False
    close = text.find("}", left)
    return close != -1 and left < at < close


def tokenize(text: str, pairs: list[tuple[str, str, str]], hits: list, loc: str) -> str:
    if not isinstance(text, str) or text == "":
        return text
    out = text
    for needle, token, nid in pairs:
        out, n = replace_word(out, needle, token)
        if n:
            hits.append((loc, nid, n, needle))
    return out


def walk_lore(obj, pairs, hits, path="lore"):
    if isinstance(obj, dict):
        skip_keys = {"glossary", "name_ref", "status", "notes", "instructions", "id"}
        for k, v in obj.items():
            loc = f"{path}.{k}"
            if k in skip_keys:
                continue
            if k in {"journal", "entry", "body", "title", "engraving"} and isinstance(v, str):
                obj[k] = tokenize(v, pairs, hits, loc)
            elif k == "footnotes" and isinstance(v, list):
                for i, fn in enumerate(v):
                    if isinstance(fn, str):
                        v[i] = tokenize(fn, pairs, hits, f"{loc}[{i}]")
            else:
                walk_lore(v, pairs, hits, loc)
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            walk_lore(v, pairs, hits, f"{path}[{i}]")


def leftover_scan(text: str, loc: str, leftovers: list) -> None:
    if not isinstance(text, str):
        return
    for pat, why in [
        (r"\bGrandfather\b", "grandfather capitalised — left as common noun unless you want {grandpa}"),
        (r"\bgrandfather\b", "grandfather (common noun, left alone)"),
        (r"\bgrumble\b", "lowercase grumble (verb/noun, left alone)"),
        (r"\blucky\b", "lowercase lucky (adjective, left alone)"),
        (r"\bLucky\b", "standalone Lucky still in the line after token pass"),
        (r"\bNib\b", "Nib still in the line after token pass"),
        (r"\bSprout\b", "Sprout still in the line after token pass"),
        (r"\bGrumblegut\b", "Grumblegut still in the line after token pass"),
        (r"\bMuddlecombe\b", "Muddlecombe still in the line after token pass"),
    ]:
        if re.search(pat, text) and "{" not in text[max(0, text.find(pat[2:4]) if False else 0) :]:
            if re.search(pat, text):
                # ignore if already a token nearby for the same name
                if "{nib}" in text and "Nib" in pat:
                    continue
                leftovers.append((loc, why, text[:120].replace("\n", " ")))


def main() -> None:
    names = load_names()
    pairs = pairs_for(names)
    hits: list = []
    leftovers: list = []

    copy = json.loads(COPY_PATH.read_text(encoding="utf-8"))
    have = {str(r.get("key", "")) for r in copy.get("rows", [])}
    for row in NEW_COPY:
        if row["key"] not in have:
            copy.setdefault("rows", []).append(row)
            have.add(row["key"])
    for row in copy.get("rows", []):
        if not isinstance(row, dict):
            continue
        key = str(row.get("key", ""))
        raw = str(row.get("text", ""))
        row["text"] = tokenize(raw, pairs, hits, f"copy:{key}")
        leftover_scan(row["text"], f"copy:{key}", leftovers)

    lore = json.loads(LORE_PATH.read_text(encoding="utf-8"))
    walk_lore(lore, pairs, hits, "lore")

    COPY_PATH.write_text(json.dumps(copy, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
    LORE_PATH.write_text(json.dumps(lore, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")

    from collections import Counter

    by_id = Counter(h[1] for h in hits)
    print("Token replacements:")
    for nid, n in by_id.most_common():
        print(f"  {nid}: {n}")
    print("\nAmbiguous leftovers (not auto-changed, or still present):")
    seen = set()
    for loc, why, snippet in leftovers:
        sig = (loc, why)
        if sig in seen:
            continue
        seen.add(sig)
        if "left alone" in why and "{nib}" not in snippet:
            # only print leftover proper names that still appear
            if "still in the line" in why:
                print(f"  {loc}: {why} :: {snippet}")
            continue
        if "still in the line" in why:
            print(f"  {loc}: {why} :: {snippet}")
    print("done")


if __name__ == "__main__":
    main()
