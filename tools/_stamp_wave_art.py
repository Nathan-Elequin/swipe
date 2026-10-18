"""Stamp unique 16x16×4 art for the 2026-10-17 content drop."""
from __future__ import annotations

import hashlib
import importlib.util
from pathlib import Path

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")
spec = importlib.util.spec_from_file_location("art", ROOT / "tools" / "_install_unique_art.py")
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

SPRITES = {
    "martyr": [  # nun, black habit, white wimple, gold cross
        "......iiii......",
        ".....iwwwwi.....",
        "....iwwsswwi....",
        "....iwsssswi....",
        "....ksskkssk....",
        ".....ssssss.....",
        "....kkkkkkkk....",
        "...kxxxxxxxxk...",
        "..kxxxxxgxxxxk..",
        "..kxxxxxGxxxxk..",
        "..kxxxxxxxxxxk..",
        "...kxxxxxxxxk...",
        "....kkkkkkkk....",
        "....k......k....",
        "....k......k....",
        "................",
    ],
    "shuriken": [
        ".......k........",
        "......kMk.......",
        "k....kMMMk....k.",
        ".k..kMwMwMk..k..",
        "..kkMMwwwMMkk...",
        "...kMwwwwwMk....",
        "..kMMwwwwwMMk...",
        "kMMMwwwkwwwMMMk.",
        "..kMMwwwwwMMk...",
        "...kMwwwwwMk....",
        "..kkMMwwwMMkk...",
        ".k..kMwMwMk..k..",
        "k....kMMMk....k.",
        "......kMk.......",
        ".......k........",
        "................",
    ],
    "prism": [  # floating crystal with a glint-eye
        "................",
        "......kBk.......",
        ".....kBBBk......",
        "....kBiiBBk.....",
        "...kBiwwiBBk....",
        "..kBBwiikiBBk...",
        "..kBBBiiBBBBk...",
        "...kBBBBBBBk....",
        "....kBBBBBk.....",
        ".....kBBBk......",
        "......kBk.......",
        ".......k........",
        "......k.k.......",
        "................",
        "................",
        "................",
    ],
    "miasma": [  # poison cloud + skull
        "....eeEEee......",
        "...eEEzzEEe.....",
        "..eEzwwwwzEe....",
        ".eEzwsssswzEe...",
        ".eEws.kk.swEe...",
        "eEzwsskksswzEe..",
        "eEzwwsSSswwzEe..",
        ".eEzwsssswzEe...",
        "..eEEzzzzEEe....",
        "...eeEEEEee.....",
        "....eEkkEe......",
        ".....ekke.......",
        "......kk........",
        "................",
        "................",
        "................",
    ],
    "plague_doctor": [  # beaked mask, hat
        "....kkkkkk......",
        "...kxxxxxxk.....",
        "..kxxxxxxxxk....",
        "..kxxxkkxxxk....",
        "...kxxkkxxk.....",
        "....kxssxk......",
        "...kkxssxkk.....",
        "..kMkxssxkMk....",
        ".kMMkxxxxkMMk...",
        ".kMMkkkkkkMMk...",
        "..kMMMkkMMMk....",
        "...kkkkkMMk.....",
        "....k..kMk......",
        "....k...k.......",
        "................",
        "................",
    ],
    "bag_of_marbles": [
        "......kk........",
        ".....kOOk.......",
        "....kOooOk......",
        "...kOooooOk.....",
        "..kOooooooOk....",
        ".kOoRrEeBbOk....",
        ".kORrrEeeBbOk...",
        ".kORrGggBbOk....",
        ".kOooooooooOk...",
        "..kOooooooOk....",
        "...kOooooOk.....",
        "....kkkkkk......",
        "................",
        "................",
        "................",
        "................",
    ],
    "marble": [  # split red / blue sphere, both marks
        "................",
        ".....kkkk.......",
        "...kkRRbbkk.....",
        "..kRRRRbbbbk....",
        ".kRRRwRwbbbBk...",
        ".kRRwRRwbbBBk...",
        ".kRRRRRRbbbBk...",
        ".kRRRRRbbbbk....",
        "..kRRRRbbbbk....",
        "...kkRRbbkk.....",
        ".....kkkk.......",
        "................",
        "................",
        "................",
        "................",
        "................",
    ],
    "hex": [
        "......kk........",
        "....kkPPkk......",
        "...kPPPPPPK.....",
        "..kPPwwwwPPk....",
        ".kPPwsssswPPk...",
        ".kPwsskksswPk...",
        "kPPwsskksswPPk..",
        "kPPwwsSSswwPPk..",
        ".kPPwsssswPPk...",
        ".kPPPwwwwPPPk...",
        "..kPPPPPPPPk....",
        "...kkPPPkk......",
        ".....kkkk.......",
        "................",
        "................",
        "................",
    ],
}


def main() -> None:
    items = ["shuriken", "miasma", "bag_of_marbles", "marble", "hex"]
    extras = ["martyr", "prism", "plague_doctor"]
    hashes: dict[str, list[str]] = {}
    for name, rows in SPRITES.items():
        bad = [i for i, r in enumerate(rows) if len(r) != 16]
        if len(rows) != 16 or bad:
            raise SystemExit(f"{name} not 16x16 rows={len(rows)} bad={bad} lens={[len(r) for r in rows]}")
    for name in items:
        dest = mod.ITEMS / f"{name}.png"
        mod.save(mod.draw(SPRITES[name]), dest)
        h = hashlib.md5(dest.read_bytes()).hexdigest()
        hashes.setdefault(h, []).append(dest.name)
        print("item", dest.name, dest.stat().st_size, h[:10])
    for name in extras:
        dest = mod.EXTRA / f"{name}.png"
        mod.save(mod.draw(SPRITES[name]), dest)
        h = hashlib.md5(dest.read_bytes()).hexdigest()
        hashes.setdefault(h, []).append(dest.name)
        print("extra", dest.name, dest.stat().st_size, h[:10])
    all_pngs = list(mod.ITEMS.glob("*.png")) + list(mod.EXTRA.glob("*.png"))
    by: dict[str, list[str]] = {}
    for p in all_pngs:
        by.setdefault(hashlib.md5(p.read_bytes()).hexdigest(), []).append(p.name)
    dups = {h: n for h, n in by.items() if len(n) > 1}
    print("DUPLICATES", dups if dups else "none")


if __name__ == "__main__":
    main()
