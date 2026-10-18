"""Unique 16x16×4 Cultist (hooded robe) and Blood Pact (black tablet)."""
from __future__ import annotations

import hashlib
import importlib.util
from pathlib import Path

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")
spec = importlib.util.spec_from_file_location("art", ROOT / "tools" / "_install_unique_art.py")
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

CULTIST = [
    "................",
    "......kkkk......",
    ".....kxnnxk.....",
    ".....kxsixk.....",
    ".....kxxxxk.....",
    "....kkvvvvkk....",
    "...kvvrrrvvk....",
    "...kvvvrvvvk....",
    "....kvvvvvk.....",
    "....kkkvkkk.....",
    ".....kv.vk......",
    ".....kk.kk......",
    "......k.k.......",
    "................",
    "................",
    "................",
]

PACT = [
    "................",
    "...kkkkkkkkk....",
    "..kxxxxxxxxk....",
    "..kxnnnnnnxk....",
    "..kxn.rr.nxk....",
    "..kxn.RR.nxk....",
    "..kxn.rr.nxk....",
    "..kxn..r.nxk....",
    "..kxnnnnnnxk....",
    "..kxxxxxxxxk....",
    "...kkkkkkkkk....",
    "................",
    "................",
    "................",
    "................",
    "................",
]


def _save(rows: list[str], dest: Path, name: str) -> None:
    bad = [i for i, r in enumerate(rows) if len(r) != 16]
    if len(rows) != 16 or bad:
        raise SystemExit(f"{name} not 16x16 {[len(r) for r in rows]}")
    dest.parent.mkdir(parents=True, exist_ok=True)
    mod.save(mod.draw(rows), dest)
    print(name, dest.stat().st_size, hashlib.md5(dest.read_bytes()).hexdigest()[:10])


def main() -> None:
    _save(CULTIST, mod.EXTRA / "cultist.png", "cultist")
    _save(PACT, mod.ITEMS / "blood_pact.png", "blood_pact")
    all_pngs = list(mod.ITEMS.glob("*.png")) + list(mod.EXTRA.glob("*.png"))
    by: dict[str, list[str]] = {}
    for p in all_pngs:
        by.setdefault(hashlib.md5(p.read_bytes()).hexdigest(), []).append(p.name)
    dups = {h: n for h, n in by.items() if len(n) > 1}
    print("DUPLICATES", dups if dups else "none")


if __name__ == "__main__":
    main()
