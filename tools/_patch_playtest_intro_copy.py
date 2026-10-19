import json
from pathlib import Path

p = Path(r"C:\Users\Natha\Documents\boss-rush\data\player-copy.json")
data = json.loads(p.read_text(encoding="utf-8"))
rows = data.get("rows", [])
by = {r.get("key"): r for r in rows if isinstance(r, dict)}
stamp = "2026-10-19"


def upsert(key, text, where, cat="Playtest"):
    if key in by:
        by[key]["text"] = text
        by[key]["author_lock"] = True
        by[key]["locked_at"] = stamp
        by[key]["where"] = where
        by[key]["cat"] = cat
    else:
        row = {
            "cat": cat,
            "key": key,
            "text": text,
            "author_lock": True,
            "locked_at": stamp,
            "where": where,
        }
        rows.append(row)
        by[key] = row


upsert("playtest.brand_new_blurb", "Start from scratch.", "Playtest hub")
upsert("playtest.middle_blurb", "A few dungeons in.", "Playtest hub")
upsert("playtest.continue_blurb", "Last save.", "Playtest hub")
upsert(
    "playtest.play_chip",
    "Right-click a card, or press F2, to send a note.",
    "Playtest bottom-left during play",
)
upsert("playtest.intro.speaker", "Nathan", "Playtest intro talk-box name")
upsert("playtest.intro.back", "Back", "Playtest intro back button")
upsert("playtest.intro.done", "Continue", "Playtest intro last button")

beats = [
    (
        "playtest.intro.01",
        "Hey friends — thanks for playtesting my game, Swipe.\nJust a few notes before you jump in.",
    ),
    (
        "playtest.intro.02",
        "First. This game is in early prototype mode. The things I most want to hear from your feedback are about what is fun, what is boring, what is confusing, and what things you think I should add to the game.",
    ),
    (
        "playtest.intro.03",
        "Second. Be honest and picky! You don't need to consider anyone else's perspective. I just want to hear yours.",
    ),
    (
        "playtest.intro.04",
        "And finally, have fun! Break the game, find cool combos, test the limits. And don't be afraid to dream big with your requests.",
    ),
    ("playtest.intro.05", "This is the menu you'll land on."),
    (
        "playtest.intro.06",
        "Brand New starts from the beginning, as if you had never played.",
    ),
    (
        "playtest.intro.07",
        "Middle Progress puts you a few dungeons in, with some items already unlocked.",
    ),
    ("playtest.intro.08", "Continue picks up your last playtest save."),
    (
        "playtest.intro.09",
        "Feedback opens a note to me. Use it for anything that is not tied to one card.",
    ),
    (
        "playtest.intro.10",
        "You can right-click any item or monster in the game and leave feedback. That is useful for bugs, confusion, or balance issues.",
    ),
    (
        "playtest.intro.11",
        "For general comments while you play, click Feedback in the bottom right, or press F2.",
    ),
    (
        "playtest.intro.12",
        "This is the F2 screen. Type a note, click Send, and it goes to my game development console. Next time I sit down to work, I will see it and can make the fix or the change.",
    ),
    (
        "playtest.intro.13",
        "However — for those who want to give the best kind of feedback, I would love to actually hear YOUR EXPERIENCE.",
    ),
    (
        "playtest.intro.14",
        "Consider taking your phone, setting it to a voice memo or recorder, and just letting it run while you play. Talk out loud about your thought process, your first impressions, your feedback, anything at all. Then send me the entire file when you are done, because I can turn that into a much more detailed look at your player experience. If you are interested in doing that, you can email the files to me at nathan.elequin@gmail.com.",
    ),
    (
        "playtest.intro.15",
        "So thank you again for playtesting. If you have any questions, you can always reach out to me. Now enjoy.",
    ),
]
for i, (key, text) in enumerate(beats, start=1):
    upsert(key, text, f"Playtest intro beat {i:02d}")

data["updated"] = stamp
p.write_text(json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
print("ok", len(rows), "intro", sum(1 for k in by if str(k).startswith("playtest.intro")))
