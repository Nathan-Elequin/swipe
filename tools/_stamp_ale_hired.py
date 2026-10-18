"""Unique 16x16×4 art for Ale Flagon and Hired Hand."""
from __future__ import annotations

import hashlib
import importlib.util
from pathlib import Path

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")
spec = importlib.util.spec_from_file_location("art", ROOT / "tools" / "_install_unique_art.py")
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

SPRITES = {
    "ale_flagon": [  # wooden tankard, foam, handle — not a potion flask
        "................",
        "....iiiiii......",
        "...iwwYYwwi.....",
        "...iYYYYYYi.....",
        "....oooooo......",
        "...koooooook....",
        "...koooooook.kk.",
        "...kOoooooOk.kOk",
        "...kOoooooOkkOk.",
        "...kOOOOOOk.kO..",
        "...kOOOOOOk.k...",
        "....kOOOOOk.....",
        ".....kkkkkk.....",
        "................",
        "................",
        "................",
    ],
    "hired_hand": [  # thug, vest, club
        "......kkkk......",
        ".....kssssk.....",
        "....kssssssk....",
        "....ks.kk.sk....",
        "....kssssssk....",
        ".....kssssk.....",
        "....kkcccckk....",
        "...kccckkcckk...",
        "...kccckkccck...",
        "...ksccckcck....",
        "....kccccck.....",
        "....kkkkkkk.....",
        "....ko...oOkk...",
        "....ko...oOOOk..",
        "....kk...k.kOk..",
        "................",
    ],
}


def main() -> None:
    for name, rows in SPRITES.items():
        bad = [i for i, r in enumerate(rows) if len(r) != 16]
        if len(rows) != 16 or bad:
            raise SystemExit(f"{name} not 16x16 { [len(r) for r in rows] }")
    dest_i = mod.ITEMS / "ale_flagon.png"
    dest_m = mod.EXTRA / "hired_hand.png"
    mod.save(mod.draw(SPRITES["ale_flagon"]), dest_i)
    mod.save(mod.draw(SPRITES["hired_hand"]), dest_m)
    all_pngs = list(mod.ITEMS.glob("*.png")) + list(mod.EXTRA.glob("*.png"))
    by: dict[str, list[str]] = {}
    for p in all_pngs:
        by.setdefault(hashlib.md5(p.read_bytes()).hexdigest(), []).append(p.name)
    dups = {h: n for h, n in by.items() if len(n) > 1}
    print("ale_flagon", dest_i.stat().st_size, hashlib.md5(dest_i.read_bytes()).hexdigest()[:10])
    print("hired_hand", dest_m.stat().st_size, hashlib.md5(dest_m.read_bytes()).hexdigest()[:10])
    print("DUPLICATES", dups if dups else "none")


if __name__ == "__main__":
    main()
