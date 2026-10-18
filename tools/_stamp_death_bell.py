"""Unique 16x16×4 Death Bell (monster) and Toll (token). Not Echo/Quiet Bell."""
from __future__ import annotations

import hashlib
import importlib.util
from pathlib import Path

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")
spec = importlib.util.spec_from_file_location("art", ROOT / "tools" / "_install_unique_art.py")
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

# Giant cracked church bell, one yellow eye, dark purple body.
BELL = [
    ".......kk.......",
    "......kGGk......",
    ".....kPiiPk.....",
    "....kPnnnnPk....",
    "...kPn.y.nPk....",
    "...kPnnnnnPk....",
    "..kPPnnnnnPPk...",
    "..kPPnnnnnPPk...",
    ".kPPPnnnnnPPPk..",
    ".kPPPnnnnnPPPk..",
    "..kPPnnnnnPPk...",
    "...kPPnnnPPk....",
    "....kkPnPkk.....",
    "......kRk.......",
    ".....kRRRk......",
    "......kKk.......",
]

# Black token: small hanging bell, gold crack, not a flask/egg/pact.
TOLL = [
    "................",
    "......kk........",
    ".....kGGk.......",
    "....kxmmxk......",
    "...kxnnnnxk.....",
    "...kxny.nxk.....",
    "...kxnnnnxk.....",
    "...kxxnnxxk.....",
    "....kxxxxk......",
    ".....kxRk.......",
    "......kRk.......",
    "......kkk.......",
    "................",
    "................",
    "................",
    "................",
]


def main() -> None:
    for name, rows, dest in (
        ("death_bell", BELL, mod.EXTRA / "death_bell.png"),
        ("toll", TOLL, mod.ITEMS / "toll.png"),
    ):
        bad = [i for i, r in enumerate(rows) if len(r) != 16]
        if len(rows) != 16 or bad:
            raise SystemExit(f"{name} not 16x16")
        mod.save(mod.draw(rows), dest)
        print(name, dest.stat().st_size, hashlib.md5(dest.read_bytes()).hexdigest()[:10])
    all_pngs = list(mod.ITEMS.glob("*.png")) + list(mod.EXTRA.glob("*.png"))
    by: dict[str, list[str]] = {}
    for p in all_pngs:
        by.setdefault(hashlib.md5(p.read_bytes()).hexdigest(), []).append(p.name)
    dups = {h: n for h, n in by.items() if len(n) > 1}
    print("DUPLICATES", dups if dups else "none")


if __name__ == "__main__":
    main()
