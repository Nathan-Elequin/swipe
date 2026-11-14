import json
import re
from pathlib import Path

src = Path(__file__).resolve().parents[1] / "scripts" / "dungeon_art.gd"
text = src.read_text(encoding="utf-8")
art = {}
for const in ("ITEM_PNG", "MONSTER_PNG"):
    block = re.search(const + r"\s*:=\s*\{(.*?)\n\}", text, re.S)
    if not block:
        continue
    for card_id, path in re.findall(r'"([^"]+)"\s*:\s*"res://([^"]+)"', block.group(1)):
        art[card_id] = "../" + path
out = Path(__file__).with_name("telemetry-art.json")
out.write_text(json.dumps(art, indent=0), encoding="utf-8")
print(len(art), "paths", out)
