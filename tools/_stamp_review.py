import json
from pathlib import Path

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")
ROUGH = {
    "lantern",
    "mirror_shard",
    "caltrops",
    "echo_bell",
    "quiet_bell",
    "gelatinous_cube",
    "gargoyle",
    "harpy",
    "kobold_trapper",
    "clockwork_knight",
}


def stamp(card: dict) -> None:
    cid = str(card.get("id", ""))
    if cid in ROUGH:
        card["review"] = "rough"
    else:
        card["review"] = "polish"
    if "review_note" not in card:
        card["review_note"] = ""


def run(path: Path, keys: list[str]) -> None:
    data = json.loads(path.read_text(encoding="utf-8"))
    for key in keys:
        for card in data.get(key, []):
            if isinstance(card, dict):
                stamp(card)
    path.write_text(json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
    print("stamped", path.name)


run(ROOT / "data" / "content-board.json", ["items", "monsters"])
run(ROOT / "data" / "catalog.json", ["items", "monsters"])
