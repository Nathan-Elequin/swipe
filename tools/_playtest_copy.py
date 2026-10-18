# One-shot copy patch for the Oct 17 playtest pass.
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COPY = ROOT / "data" / "player-copy.json"
LOCKS = ROOT / "data" / "author-locks.json"

def set_row(rows, key, text, **extra):
    for row in rows:
        if row.get("key") == key:
            row["text"] = text
            row.update(extra)
            return row
    row = {"cat": extra.get("cat", "Playtest"), "key": key, "text": text, "draft": True, "where": extra.get("where", "")}
    rows.append(row)
    return row

def main():
    pack = json.loads(COPY.read_text(encoding="utf-8"))
    rows = pack["rows"]
    by = {r["key"]: r for r in rows if "key" in r}

    body = by["tutorial.beat.01.body"]["text"]
    body = body.replace("Da Boot", "The Boot")
    body = body.replace("You can hold Shift to see any Item's details at a glance.", "Hover any item to see its details at a glance.")
    body = body.replace(
        "Hover over any Monster and hold Shift to learn the details of their ability, just like Items.",
        "Hover any monster to learn their ability, just like items.",
    )
    body = body.replace("(When the user hovers and holds Shift, highlight the details)", "(When the user hovers)")
    body = body.replace("(When the user hovers or holds Shift)", "(When the user hovers)")
    body = body.replace(
        "Alright, that's enough. Let's spin the wheel and learn the rest as we go. Click 'Spin' to randomly choose your first opponent.\n(Click 'Spin' — spins the wheel, forcing it to stop on Wizard)",
        "Alright, that's enough. Let's learn the rest as we go. Click the Wizard on the wheel.\n(Click the Wizard)",
    )
    body = body.replace(
        "Alright, that's enough. Let's spin the wheel and learn the rest as we go. Click 'Spin' to randomly choose your first opponent.\n(Click 'Spin' â€” spins the wheel, forcing it to stop on Wizard)",
        "Alright, that's enough. Let's learn the rest as we go. Click the Wizard on the wheel.\n(Click the Wizard)",
    )
    body = body.replace(
        "There's one final type of item, so let's Spin again and try it out.\n(Click 'Spin' and land on Goblin)",
        "There's one final type of item. Click the Goblin on the wheel.\n(Click the Goblin)",
    )
    body = body.replace(
        "After that you pick who you fight. Click a monster, then click Spin. Knock one down and you pick loot equal to their tier, then a new monster climbs out of the deck into that seat. When the deck's empty, the wheel starts closing for real.",
        "After that you pick who you fight. Click Begin when your loot is ready.\n(Highlights Begin)\n(Click 'next' to continue)\nThen click a monster on the wheel — that click is the spin. Knock one down and you pick loot equal to their tier, then a new monster climbs out of the deck into that seat. When the deck's empty, the wheel starts closing for real.\n(Highlights dungeon wheel)",
    )
    by["tutorial.beat.01.body"]["text"] = body
    by["tutorial.beat.01.body"]["author_lock"] = True
    by["tutorial.beat.01.body"]["locked_at"] = "2026-10-17"

    set_row(rows, "tutorial.nudge_item", "Click the highlighted thing — not that one.", author_lock=True, locked_at="2026-10-17")
    set_row(rows, "challenge.click_target", "Click who you fight.", author_lock=True, locked_at="2026-10-17")
    set_row(rows, "challenge.spin_confirm", "Click a monster on the wheel.", author_lock=True, locked_at="2026-10-17")

    set_row(rows, "map.route.gatehouse.desc", "Dungeon after dungeon. The wheel shrinks. You keep only the items you started with.")
    set_row(rows, "map.route.long_drop.desc", "You pick the spin. A larger dungeon, and an opening monster deck.")
    set_row(rows, "map.deepest", "Deepest: Dungeon {n}")
    set_row(rows, "map.prefer_note", "Which mode did you like more, and why? (test note)")
    set_row(rows, "cabin.hot.door_hall", "Trophy Hall")
    set_row(rows, "cabin.hot.door_study", "Study")
    set_row(rows, "cabin.hot.door_workshop", "Workshop")
    set_row(rows, "cabin.hot.door_loft", "The Loft")
    set_row(rows, "cabin.hot.back", "Cabin")
    set_row(rows, "cabin.hot.back_main", "Cabin")
    set_row(rows, "cabin.hot.back_hall", "Trophy Hall")
    set_row(rows, "cabin.hot.back_study", "Study")
    set_row(rows, "cabin.hot.back_workshop", "Workshop")
    set_row(rows, "cabin.hot.hatch", "Workshop")
    set_row(rows, "cabin.locked.first", "That door stays shut until you bring a haul home. Try the map again?")
    set_row(rows, "cabin.locked.try", "Try again")
    set_row(rows, "cabin.locked.wait", "Not yet")
    set_row(rows, "radio.tip.music", "Music bed")
    set_row(rows, "radio.tip.ambiance", "Room tone")
    set_row(rows, "radio.tip.sfx", "Clicks, hits, and the rest")
    set_row(rows, "rope.cleared", "Dungeon {n} cleared!")
    set_row(rows, "rope.deeper_sub", "Keep your sack. Dungeon {n} is waiting.")
    set_row(rows, "rope.loot_tip", "Go deeper for rarer items and worse foes. Keep what you hold. Die, and none of it comes home.")
    set_row(rows, "journal.unmet", "")
    set_row(rows, "journal.tab.will", "Memories")
    set_row(rows, "journal.tab.memories", "Memories")
    set_row(rows, "journal.will.replay", "Watch the intro again")
    set_row(rows, "cabin.model.deepest", "A light flickers in Dungeon {n}.")

    # Belly → Dungeon in remaining player-facing strings (not flavor "belly-up")
    for row in rows:
        t = str(row.get("text", ""))
        k = str(row.get("key", ""))
        if k in ("cabin.model.none",):
            continue
        if "belly-up" in t.lower() or "belly of the mountain" in t.lower():
            continue
        nt = t.replace("Deepest: Belly", "Deepest: Dungeon")
        nt = nt.replace("Deepest belly", "Deepest dungeon")
        nt = nt.replace("Belly {n}", "Dungeon {n}")
        nt = nt.replace("One belly,", "One dungeon,")
        nt = nt.replace("Belly after belly", "Dungeon after dungeon")
        if nt != t:
            row["text"] = nt

    pack["updated"] = "2026-10-17"
    COPY.write_text(json.dumps(pack, ensure_ascii=False, indent="\t") + "\n", encoding="utf-8")

    locks = json.loads(LOCKS.read_text(encoding="utf-8"))
    script = locks.get("script", {})
    for key, text in {
        "tutorial.beat.01.body": by["tutorial.beat.01.body"]["text"],
        "tutorial.nudge_item": "Click the highlighted thing — not that one.",
        "challenge.click_target": "Click who you fight.",
        "challenge.spin_confirm": "Click a monster on the wheel.",
    }.items():
        if key in script:
            script[key]["text"] = text
            script[key]["locked_at"] = "2026-10-17"
            script[key]["author_lock"] = True
    LOCKS.write_text(json.dumps(locks, ensure_ascii=False, indent="\t") + "\n", encoding="utf-8")
    print("copy patched")

if __name__ == "__main__":
    main()
