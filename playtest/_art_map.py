"""Map card ids to the same still the game uses (dungeon_art.monster_idle)."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
src = ROOT / "scripts" / "dungeon_art.gd"
text = src.read_text(encoding="utf-8")
art = {}


def parse_const(name: str) -> dict:
    block = re.search(name + r"\s*:=\s*\{(.*?)\n\}", text, re.S)
    if not block:
        return {}
    return dict(re.findall(r'"([^"]+)"\s*:\s*"res://([^"]+)"', block.group(1)))


def web(rel: str) -> str:
    return "../" + rel.replace("\\", "/")


def first_existing(*rels: str) -> str | None:
    for rel in rels:
        if (ROOT / rel).is_file():
            return web(rel)
    return None


for card_id, path in parse_const("ITEM_PNG").items():
    art[card_id] = web(path)

for card_id, extra in parse_const("MONSTER_PNG").items():
    picked = first_existing(
        f"assets/dungeon/anim/facing/{card_id}_facing_idle_f0.png",
        f"assets/dungeon/anim/wheel/{card_id}_wheel_idle_f0.png",
        extra,
    )
    if picked:
        art[card_id] = picked

out_json = Path(__file__).with_name("telemetry-art.json")
out_js = Path(__file__).with_name("telemetry-art.js")
out_json.write_text(json.dumps(art, indent=0), encoding="utf-8")
out_js.write_text("window.ART=" + json.dumps(art) + ";\n", encoding="utf-8")
print(len(art), "paths", out_js)
