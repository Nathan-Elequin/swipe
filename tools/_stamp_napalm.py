"""Unique 16x16×4 Napalm — fire storm, not a flask or lantern."""
from __future__ import annotations

import hashlib
import importlib.util
from pathlib import Path

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")
spec = importlib.util.spec_from_file_location("art", ROOT / "tools" / "_install_unique_art.py")
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

NAPALM = [
    "......n.n.......",
    ".....nunu.......",
    "....kYfYk.n.....",
    "...kYfFfYk......",
    "...kfFFFfk.n....",
    "..kYfFFFfYk.....",
    "..kfFFFFFfk.....",
    ".kYfFYYFFfYk....",
    ".kfFFYfYFFfk....",
    "kYfFFFFFFFYk....",
    "kfFrFFFFFrfk....",
    ".krrFFFFFrrk....",
    "..kcrFFFrck.....",
    "...kkccckk......",
    "....kccck.......",
    "................",
]


def main() -> None:
    bad = [i for i, r in enumerate(NAPALM) if len(r) != 16]
    if len(NAPALM) != 16 or bad:
        raise SystemExit(f"napalm not 16x16 {[len(r) for r in NAPALM]}")
    dest = mod.ITEMS / "napalm.png"
    mod.save(mod.draw(NAPALM), dest)
    all_pngs = list(mod.ITEMS.glob("*.png")) + list(mod.EXTRA.glob("*.png"))
    by: dict[str, list[str]] = {}
    for p in all_pngs:
        by.setdefault(hashlib.md5(p.read_bytes()).hexdigest(), []).append(p.name)
    dups = {h: n for h, n in by.items() if len(n) > 1}
    print("napalm", dest.stat().st_size, hashlib.md5(dest.read_bytes()).hexdigest()[:10])
    print("DUPLICATES", dups if dups else "none")


if __name__ == "__main__":
    main()
