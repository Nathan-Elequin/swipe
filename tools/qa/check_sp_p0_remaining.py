#!/usr/bin/env python3
"""SP-01, SP-09, SP-14, SP-15, SP-16 checks that do not need Godot."""

import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
FAILS = []


def fail(msg: str) -> None:
    FAILS.append(msg)


def load(rel: str):
    return json.loads((ROOT / rel).read_text(encoding="utf-8"))


def text_of(doc: dict, key: str) -> str:
    for row in doc.get("rows", []):
        if row.get("key") == key:
            return str(row.get("text", ""))
    return ""


copy = load("data/player-copy.json")
win = text_of(copy, "title.win")
want_win = "Victory! You made it out - now time to check out Grandpa's trophy collection back at the Cabin."
if win != want_win:
    fail(f"title.win is {win!r}")
intro = text_of(copy, "playtest.intro.01")
if "Swipe" in intro or "Spinheritance" not in intro:
    fail(f"playtest.intro.01 still mentions Swipe: {intro!r}")
if text_of(copy, "combat.escaped") != "Escaped":
    fail("combat.escaped is not Escaped")
if text_of(copy, "combat.slain") != "SLAIN":
    fail("combat.slain changed")
if text_of(copy, "title.overlay") != "{game_title}":
    fail("title.overlay is not {game_title}")

for rel in ("data/player-copy.json", "data/player-copy.csv", "data/player-copy.additions.json"):
    blob = (ROOT / rel).read_text(encoding="utf-8")
    if "Swipe" in blob:
        fail(f"{rel} still contains Swipe")

catalog = load("data/catalog.json")
board = load("data/content-board.json")
ruling_ids = {row.get("id") for row in catalog.get("rulings", [])}
for rid in (
    "sp01_title_spinheritance",
    "sp09_cabin_progress",
    "sp14_escaped_banner",
    "sp15_tier_badges",
    "sp16_card_text",
):
    if rid not in ruling_ids:
        fail(f"missing ruling {rid}")
for row in catalog.get("rulings", []):
    if str(row.get("id", "")).startswith("sp") and row.get("chat") != "2026-10-25":
        fail(f"ruling {row.get('id')} date is {row.get('chat')}")


def card(doc, cid, kind):
    key = "items" if kind == "item" else "monsters"
    rows = doc.get(key, [])
    if kind == "item" and not rows and "cards" in doc:
        rows = [c for c in doc.get("cards", []) if c.get("kind") == "item" or c.get("type") == "I"]
    for row in rows:
        if row.get("id") == cid:
            return row
    return {}


def board_card(cid):
    for key in ("cards", "items", "monsters"):
        for row in board.get(key, []):
            if isinstance(row, dict) and row.get("id") == cid:
                return row
    return {}


cube = card(catalog, "gelatinous_cube", "monster")
boot = card(catalog, "da_boot", "item")
commander = card(catalog, "commander", "monster")
if cube.get("ability") != "When you Spin me, feed me one of two items.":
    fail(f"cube ability {cube.get('ability')!r}")
if boot.get("ability") != "Defeat an enemy with fewer HP than you (not equal).":
    fail(f"boot ability {boot.get('ability')!r}")
if "not equal" not in str(boot.get("explainer", "")):
    fail(f"boot explainer {boot.get('explainer')!r}")
if "Flee and the wheel Spins at random" not in str(commander.get("ability", "")):
    fail(f"commander ability {commander.get('ability')!r}")
for cid, field, want in (
    ("gelatinous_cube", "ability", cube.get("ability")),
    ("da_boot", "ability", boot.get("ability")),
    ("commander", "ability", commander.get("ability")),
):
    got = board_card(cid).get(field)
    if got != want:
        fail(f"board {cid} {field} {got!r} != catalog")

locks = load("data/author-locks.json")
# Ledger is either a dict of keys or {"locks": ...}. Accept both.
lock_root = locks.get("locks", locks) if isinstance(locks, dict) else {}
for key in ("title.win", "playtest.intro.01"):
    row = lock_root.get(key, {})
    if isinstance(row, dict) and row.get("text") and "Swipe" in str(row.get("text")):
        fail(f"author lock {key} still says Swipe")

deck = (ROOT / "scripts/dungeon_deck.gd").read_text(encoding="utf-8")
for banned in ("5a8ac4", "c43a3a", "172636", "3a1014"):
    if banned in deck:
        fail(f"dungeon deck still uses {banned}")
for metal in ("c08050", "c5cdd8", "e8c36a"):
    if metal not in deck:
        fail(f"dungeon deck missing metal {metal}")

gate = (ROOT / "scripts/draft_gate.gd").read_text(encoding="utf-8")
if 'Color("8a96a8")' in gate or "0.12, 0.15, 0.22" in gate:
    fail("draft gate still uses the blue tier-2 wash or silver")
if "UxStyle.metal" not in gate:
    fail("draft gate metal is not UxStyle.metal")

wheel = (ROOT / "scripts/boss_wheel.gd").read_text(encoding="utf-8")
main = (ROOT / "scripts/main.gd").read_text(encoding="utf-8")
if "play_escape" not in wheel or 'combat.escaped' not in wheel:
    fail("escape banner is not drawn")
if "_shake_screen" not in main or "banner = \"escape\"" not in main:
    fail("HP shake or escape banner selection missing")
if "_attach_hand_glint(" in main.split("func _choice_badge_text", 1)[-1]:
    pass
if "func _attach_hand_glint" in main:
    fail("center glimmer function is still attached")
if "_choice_badge_text" not in main:
    fail("choice badge helper missing")

style = (ROOT / "scripts/ux_style.gd").read_text(encoding="utf-8")
if "They are not removed." not in style:
    fail("Flee definition was not clarified")

cabin = (ROOT / "scripts/home_cabin.gd").read_text(encoding="utf-8")
if "func _sync_progress_doors" not in cabin or "invert_scroll" not in cabin:
    fail("cabin progress sync or invert scroll missing")
intro_gd = (ROOT / "scripts/playtest_intro.gd").read_text(encoding="utf-8")
if "Swipe" in intro_gd:
    fail("playtest intro fallback still says Swipe")

knife = card(catalog, "throwing_knife", "item")
net = card(catalog, "net", "item")


def badge(ops):
    if not isinstance(ops, dict) or ops.get("kind") != "choose":
        return ""
    bits = []
    for opt in ops.get("options", []):
        if not isinstance(opt, dict):
            continue
        if "atk" in opt:
            bits.append(str(int(opt["atk"])))
        elif "atk_drop" in opt:
            bits.append(str(int(opt["atk_drop"])))
    return " / ".join(bits) if len(bits) >= 2 else ""


if badge(knife.get("ops")) != "3 / 1":
    fail(f"knife badge {badge(knife.get('ops'))!r}")
if badge(net.get("ops")) != "1 / 2 / 3":
    fail(f"net badge {badge(net.get('ops'))!r}")

if FAILS:
    print("FAIL")
    for row in FAILS:
        print("-", row)
    sys.exit(1)
print("OK sp-p0-remaining")
