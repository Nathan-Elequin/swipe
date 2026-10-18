"""Unique 16x16×4 Almighty Worm — sand worm, not slug/serpent/hydra."""
from __future__ import annotations

import hashlib
import importlib.util
from pathlib import Path

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")
spec = importlib.util.spec_from_file_location("art", ROOT / "tools" / "_install_unique_art.py")
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

WORM = [
    "................",
    "......kkkk......",
    "....kkPQPPkk....",
    "...kPQnnnQPk....",
    "...kQn.i.nQk....",
    "..kPQnnnnQPpk...",
    "..kPPQQQQPpk....",
    ".kPPPppPPPpk....",
    ".kPPpoooopPk....",
    "..kPooooooPk....",
    "...kpookkk......",
    "...kook.........",
    "..koo...........",
    ".kko............",
    "................",
    "................",
]


def main() -> None:
    bad = [i for i, r in enumerate(WORM) if len(r) != 16]
    if len(WORM) != 16 or bad:
        raise SystemExit(f"almighty_worm not 16x16 {[len(r) for r in WORM]}")
    dest = mod.EXTRA / "almighty_worm.png"
    mod.save(mod.draw(WORM), dest)
    all_pngs = list(mod.ITEMS.glob("*.png")) + list(mod.EXTRA.glob("*.png"))
    by: dict[str, list[str]] = {}
    for p in all_pngs:
        by.setdefault(hashlib.md5(p.read_bytes()).hexdigest(), []).append(p.name)
    dups = {h: n for h, n in by.items() if len(n) > 1}
    print("almighty_worm", dest.stat().st_size, hashlib.md5(dest.read_bytes()).hexdigest()[:10])
    print("DUPLICATES", dups if dups else "none")


if __name__ == "__main__":
    main()
