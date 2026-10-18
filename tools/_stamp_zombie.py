"""Unique 16x16×4 Zombie — not basilisk.png, hollow, skeleton, or golem."""
from __future__ import annotations

import hashlib
import importlib.util
from pathlib import Path

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")
spec = importlib.util.spec_from_file_location("art", ROOT / "tools" / "_install_unique_art.py")
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

ZOMBIE = [
    "................",
    "....kkkkkk......",
    "...kEEhEEhk.....",
    "..kEhiiiihEk....",
    "..kE.n..n.Ek....",
    "..kE......Ek....",
    "..kE..ii..Ek....",
    "...kEiiiiEk.....",
    "...kE....Ek.....",
    "..kUUkEEEk......",
    ".kUUUkk.kEkk....",
    ".kUUkk...kEEk...",
    "..kk......kUk...",
    "...........kk...",
    "................",
    "................",
]


def main() -> None:
    bad = [i for i, r in enumerate(ZOMBIE) if len(r) != 16]
    if len(ZOMBIE) != 16 or bad:
        raise SystemExit(f"zombie not 16x16 {[len(r) for r in ZOMBIE]}")
    dest = mod.EXTRA / "zombie.png"
    mod.save(mod.draw(ZOMBIE), dest)
    all_pngs = list(mod.ITEMS.glob("*.png")) + list(mod.EXTRA.glob("*.png"))
    by: dict[str, list[str]] = {}
    for p in all_pngs:
        by.setdefault(hashlib.md5(p.read_bytes()).hexdigest(), []).append(p.name)
    dups = {h: n for h, n in by.items() if len(n) > 1}
    print("zombie", dest.stat().st_size, hashlib.md5(dest.read_bytes()).hexdigest()[:10])
    print("DUPLICATES", dups if dups else "none")


if __name__ == "__main__":
    main()
