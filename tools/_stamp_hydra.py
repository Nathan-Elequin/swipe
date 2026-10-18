"""Unique 16x16×4 Hydra — three heads, not basilisk / serpent / dragon."""
from __future__ import annotations

import hashlib
import importlib.util
from pathlib import Path

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")
spec = importlib.util.spec_from_file_location("art", ROOT / "tools" / "_install_unique_art.py")
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

HYDRA = [
    "...kk.kk.kk.....",
    "..kEEkEEkEEk....",
    "..kYdkYdkYdk....",
    "..kEEkEEkEEk....",
    "...kEkkEkkEk....",
    "...kEEEEhEEk....",
    "....kEEEEhkk....",
    "....kkhEEEhk....",
    "...khhEEEEhk....",
    "...khEEEEEEk....",
    "....kEEEEEk.....",
    "....khEEEhk.....",
    ".....khEhk......",
    "......kkk.......",
    ".......k.kk.....",
    ".........kEk....",
]


def main() -> None:
    bad = [i for i, r in enumerate(HYDRA) if len(r) != 16]
    if len(HYDRA) != 16 or bad:
        raise SystemExit(f"hydra not 16x16 {[len(r) for r in HYDRA]}")
    dest = mod.EXTRA / "hydra.png"
    mod.save(mod.draw(HYDRA), dest)
    all_pngs = list(mod.ITEMS.glob("*.png")) + list(mod.EXTRA.glob("*.png"))
    by: dict[str, list[str]] = {}
    for p in all_pngs:
        by.setdefault(hashlib.md5(p.read_bytes()).hexdigest(), []).append(p.name)
    dups = {h: n for h, n in by.items() if len(n) > 1}
    print("hydra", dest.stat().st_size, hashlib.md5(dest.read_bytes()).hexdigest()[:10])
    print("DUPLICATES", dups if dups else "none")


if __name__ == "__main__":
    main()
