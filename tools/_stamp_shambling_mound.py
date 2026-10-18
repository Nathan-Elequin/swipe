"""Unique 16x16×4 Shambling Mound — walking moss heap, not slime/golem/ogre."""
from __future__ import annotations

import hashlib
import importlib.util
from pathlib import Path

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")
spec = importlib.util.spec_from_file_location("art", ROOT / "tools" / "_install_unique_art.py")
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

MOUND = [
    "................",
    "......kkk.......",
    "....kkEEEkk.....",
    "...kEEhEhEEk....",
    "..kEEn.n.nEEk...",
    "..kEEn.i.nEEk...",
    ".kEEEEhhhEEEk...",
    ".kEEEEdEdEEEk...",
    ".kEEEEd.dEEEk...",
    "..kEEEdddEEk....",
    "...kEEkkkEEk....",
    "..kedd...dek....",
    ".keek.....keek..",
    ".ek........ke...",
    "..kk......kk....",
    "................",
]


def main() -> None:
    bad = [i for i, r in enumerate(MOUND) if len(r) != 16]
    if len(MOUND) != 16 or bad:
        raise SystemExit(f"shambling_mound not 16x16 {[len(r) for r in MOUND]}")
    dest = mod.EXTRA / "shambling_mound.png"
    mod.save(mod.draw(MOUND), dest)
    all_pngs = list(mod.ITEMS.glob("*.png")) + list(mod.EXTRA.glob("*.png"))
    by: dict[str, list[str]] = {}
    for p in all_pngs:
        by.setdefault(hashlib.md5(p.read_bytes()).hexdigest(), []).append(p.name)
    dups = {h: n for h, n in by.items() if len(n) > 1}
    print("shambling_mound", dest.stat().st_size, hashlib.md5(dest.read_bytes()).hexdigest()[:10])
    print("DUPLICATES", dups if dups else "none")


if __name__ == "__main__":
    main()
