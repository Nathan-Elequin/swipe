"""Emit design/buckets-art.json from scripts/dungeon_art.gd for buckets.html."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
text = (ROOT / "scripts" / "dungeon_art.gd").read_text(encoding="utf-8")


def extract(name: str) -> dict[str, str]:
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
    block = text[start : i - 1]
    out: dict[str, str] = {}
    for line in block.splitlines():
        mm = re.match(r'\s*"([^"]+)":\s*"res://([^"]+)"', line)
        if mm:
            rel = mm.group(2).replace("\\", "/").lstrip("/")
            if rel.startswith("assets/"):
                rel = rel[len("assets/") :]
            out[mm.group(1)] = "/assets/" + rel
    return out


def live_monsters(raw: dict[str, str]) -> dict[str, str]:
    out = dict(raw)
    for mid in list(out.keys()):
        face = ROOT / "assets" / "dungeon" / "anim" / "facing" / f"{mid}_facing_idle_f0.png"
        wheel = ROOT / "assets" / "dungeon" / "anim" / "wheel" / f"{mid}_wheel_base.png"
        if face.is_file():
            out[mid] = f"/assets/dungeon/anim/facing/{mid}_facing_idle_f0.png"
        elif wheel.is_file():
            out[mid] = f"/assets/dungeon/anim/wheel/{mid}_wheel_base.png"
    return out


art = {"items": extract("ITEM_PNG"), "monsters": live_monsters(extract("MONSTER_PNG"))}
(ROOT / "design" / "buckets-art.json").write_text(
    json.dumps(art, indent=2) + "\n", encoding="utf-8"
)
print(f"Wrote buckets-art.json ({len(art['items'])} items, {len(art['monsters'])} monsters)")
