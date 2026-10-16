"""Install unique 16x16 (then 4x nearest) item/monster icons. No duplicate hashes."""
from __future__ import annotations

import hashlib
from pathlib import Path

from PIL import Image

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")
ITEMS = ROOT / "assets" / "dungeon" / "items"
EXTRA = ROOT / "assets" / "dungeon" / "extra"
UI = ROOT / "assets" / "dungeon" / "ui"
TINY = ROOT / "tools" / "_art" / "tiny" / "Tiles"
JETREL = ROOT / "tools" / "_art" / "jetrel_tiles"
STONES = ROOT / "tools" / "_art" / "stones" / "Stone_ore_gems" / "Stone_ore_gems_without_grass.png"

# Tiny Dungeon / Jetrel background keyed to transparent.
TINY_BG = (48, 20, 36, 255)
JETREL_BG = (102, 122, 102, 255)

PAL = {
    ".": (0, 0, 0, 0),
    "k": (26, 18, 16, 255),  # outline
    "K": (58, 42, 36, 255),
    "m": (92, 92, 100, 255),  # metal
    "M": (168, 172, 180, 255),
    "w": (220, 224, 228, 255),
    "n": (48, 48, 52, 255),
    "g": (196, 148, 52, 255),  # gold
    "G": (232, 196, 106, 255),
    "o": (140, 88, 28, 255),  # wood
    "O": (184, 124, 48, 255),
    "r": (168, 36, 36, 255),  # red
    "R": (220, 72, 56, 255),
    "s": (216, 176, 140, 255),  # skin
    "S": (240, 208, 176, 255),
    "b": (56, 92, 168, 255),  # blue
    "B": (120, 168, 220, 255),
    "p": (108, 48, 140, 255),  # purple
    "P": (176, 96, 212, 255),
    "e": (40, 120, 56, 255),  # green
    "E": (88, 176, 72, 255),
    "c": (92, 56, 32, 255),  # brown
    "C": (140, 88, 48, 255),
    "y": (232, 196, 64, 255),  # flame
    "Y": (255, 236, 140, 255),
    "u": (72, 72, 76, 255),  # stone
    "U": (132, 128, 120, 255),
    "t": (200, 72, 120, 255),  # pink
    "i": (248, 248, 252, 255),  # ivory
    "d": (36, 80, 44, 255),  # dark green
    "a": (168, 48, 48, 255),
    "h": (80, 140, 72, 255),
    "f": (252, 120, 40, 255),
    "F": (255, 188, 72, 255),
    "x": (20, 16, 14, 255),
    "z": (64, 160, 72, 255),
    "q": (120, 96, 160, 255),
    "Q": (188, 156, 220, 255),
    "v": (88, 28, 28, 255),
    "j": (48, 28, 20, 255),
    "l": (172, 196, 80, 255),
    "L": (212, 228, 120, 255),
}


def draw(rows: list[str]) -> Image.Image:
    w = max(len(r) for r in rows)
    rows = [r.ljust(w, ".") for r in rows]
    h = len(rows)
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = im.load()
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            px[x, y] = PAL[ch]
    return im


def up4(im: Image.Image) -> Image.Image:
    return im.resize((im.size[0] * 4, im.size[1] * 4), Image.Resampling.NEAREST)


def key_bg(im: Image.Image, bg: tuple[int, int, int, int], tol: int = 28) -> Image.Image:
    im = im.convert("RGBA")
    px = im.load()
    w, h = im.size
    br, bgc, bb, _ = bg
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if abs(r - br) <= tol and abs(g - bgc) <= tol and abs(b - bb) <= tol:
                px[x, y] = (0, 0, 0, 0)
    return im


def save(im: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    up4(im).save(path)


def tiny(n: int) -> Image.Image:
    im = Image.open(TINY / f"tile_{n:04d}.png")
    return key_bg(im, TINY_BG, 40)


def jet(n: int) -> Image.Image:
    im = Image.open(JETREL / f"{n:02d}.png")
    # already 64 from earlier slice; re-open original 16 from sheet
    sheet = Image.open(ROOT / "tools" / "_art" / "jetrel.png").convert("RGBA")
    y, x = divmod(n, 8)
    t = sheet.crop((x * 16, y * 16, x * 16 + 16, y * 16 + 16))
    return key_bg(t, JETREL_BG, 36)


def gold_tint(im: Image.Image) -> Image.Image:
    im = im.convert("RGBA")
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            px[x, y] = (
                min(255, int(r * 0.55 + 140)),
                min(255, int(g * 0.55 + 110)),
                min(255, int(b * 0.35 + 20)),
                a,
            )
    return im


def composite_twins() -> Image.Image:
    a = tiny(85)
    b = tiny(99)
    out = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    out.paste(a, (0, 8), a)
    out.paste(b, (16, 8), b)
    return out.resize((16, 16), Image.Resampling.NEAREST)


# --- hand-drawn 16x16 maps (unique objects) ---
SPRITES: dict[str, list[str]] = {
    "iron_chain": [
        "..kk..........",
        ".kMMk.........",
        ".kMMk.........",
        "..kMkk........",
        "...kMMk.......",
        "...kMMk.......",
        "....kMkk......",
        ".....kMMk.....",
        ".....kMMk.....",
        "......kMkk....",
        ".......kMMk...",
        ".......kMMk...",
        "........kMkk..",
        ".........kMM.",
        ".........kMM.",
        "..........kk.",
    ],
    "grappling_hook": [
        "......kMMk....",
        ".....kMwMk....",
        "....kMkkMk....",
        "...kMk..kMk...",
        "..kMk....kMk..",
        ".kMk......kk..",
        "kMk.....kk....",
        "kk.....kOOk...",
        "......kOook...",
        ".....kOook....",
        "....kOook.....",
        "...kOook......",
        "..kOokk.......",
        ".kOok.........",
        "kOok..........",
        "kk............",
    ],
    "net": [
        "k.k.k.k.k.k.k.",
        ".M.M.M.M.M.M.k",
        "k.k.k.k.k.k.k.",
        ".M.M.M.M.M.M.k",
        "k.k.k.k.k.k.k.",
        ".M.M.M.M.M.M.k",
        "k.k.k.k.k.k.k.",
        ".M.M.M.M.M.M.k",
        "k.k.k.k.k.k.k.",
        ".M.M.M.M.M.M.k",
        "k.k.k.k.k.k.k.",
        ".M.M.M.M.M.M.k",
        "k.k.k.k.k.k.k.",
        ".M.M.M.M.M.M.k",
        "k.k.k.k.k.k.k.",
        "..k.k.k.k.k...",
    ],
    "counting_beads": [
        "..............",
        "..Rr..Ee..Bb..",
        ".RaaR.EzzE.BbB",
        ".RaaR.EzzE.BbB",
        "..Rr..Ee..Bb..",
        "....kkkkkk....",
        "..Gg......Pp..",
        ".GGGG....PPPP.",
        ".GggG....PppP.",
        "..Gg......Pp..",
        "..............",
        "....kkkk......",
        "...kGGkk......",
        "...kGGk.......",
        "....kk........",
        "..............",
    ],
    "measuring_tape": [  # Scythe
        ".........wwwk.",
        ".......wwMMmk.",
        "......wMMMm.k.",
        ".....wMMm...k.",
        "....wMm.....k.",
        "...kMk......k.",
        "..kOOk........",
        ".kOook........",
        "kOook.........",
        "kook..........",
        "kOk...........",
        "kOk...........",
        "kOk...........",
        "kOk...........",
        ".kk...........",
        "..............",
    ],
    "last_match": [  # open palm
        "....kkkk......",
        "...kSSSsk.....",
        "..kSiiSsk.kk..",
        ".kSiiisk.kSsk.",
        ".kSiiiskkSssk.",
        "kSSiiissssssk.",
        "kSSssssssssk..",
        "kSssssssssk...",
        ".kSssssssk....",
        ".kssssssk.....",
        "..kssssk......",
        "...kssk.......",
        "....kk........",
        "..............",
        "..............",
        "..............",
    ],
    "grief_jar": [
        ".....kkkk.....",
        "....kUUUUk....",
        ".....kUUk.....",
        "....kcccck....",
        "...kCvvvCk....",
        "..kCvvvvvCk...",
        "..kCvvvvvCk...",
        "..kCvaaaCk....",
        "..kCvaaaCk....",
        "..kCvvvvvCk...",
        "..kCvvvvvCk...",
        "...kCvvvCk....",
        "....kcccck....",
        ".....kkkk.....",
        "..............",
        "..............",
    ],
    "spiked_shield": [
        "......k.......",
        ".....kMk......",
        "..k.kMMMk.k...",
        ".kMkMMMMMkMk..",
        "..kMMMMMMMk...",
        ".kMMMwMwMMMk..",
        "kMMMMMMMMkMk..",
        ".kMMwMMwMMk...",
        "..kMMMMMMMk...",
        ".kMkMMMMMkMk..",
        "..k.kMMMk.k...",
        ".....kMk......",
        "......k.......",
        "..............",
        "..............",
        "..............",
    ],
    "sai": [
        "k.....k.....k.",
        "Mk...kMk...kM.",
        "Mk...kMk...kM.",
        "Mk...kMk...kM.",
        "Mk..kMMMk..kM.",
        "Mk.kMMMMMk.kM.",
        ".kkkMMMMMkkk..",
        "...kMMMMMk....",
        "....kMMMk.....",
        ".....kOk......",
        ".....kOk......",
        ".....kOk......",
        ".....kOk......",
        ".....kOk......",
        "......kk......",
        "..............",
    ],
    "fangs": [
        "..............",
        "..iik....kii..",
        ".iwwik..kiwwi.",
        ".iwwik..kiwwi.",
        ".iwwik..kiwwi.",
        "..iwik..kiwi..",
        "..iwik..kiwi..",
        "...ikk..kki...",
        "...ik....ki...",
        "....k....k....",
        "..............",
        "..............",
        "..............",
        "..............",
        "..............",
        "..............",
    ],
    "knucklers": [
        "..............",
        "..kkkkkkkk....",
        ".kMMMMMMMMk...",
        ".kMwMwMwMwk...",
        ".kMMMMMMMMk...",
        ".kMkkkkkkMk...",
        ".kMk....kMk...",
        ".kMk....kMk...",
        ".kMkkkkkkMk...",
        ".kMMMMMMMMk...",
        "..kkkkkkkk....",
        "..............",
        "..............",
        "..............",
        "..............",
        "..............",
    ],
    "crossbow": [
        "kk..........kk",
        "kMk........kMk",
        ".kMk......kMk.",
        "..kMkkkkkkMk..",
        "...kOOOOOOk...",
        "....kOook.....",
        ".....kOk......",
        ".....kOk......",
        "....kOOOk.....",
        "...kOyyyOk....",
        "....kOOOk.....",
        ".....kOk......",
        ".....kkk......",
        "..............",
        "..............",
        "..............",
    ],
    "anvil": [
        "..............",
        ".kkkkkkkkkkk..",
        "kUUUUUUUUUUnk.",
        "kUUUUUUUUUUnk.",
        ".kkkkUnkkkkk..",
        "....kUnkk.....",
        "....kUnnk.....",
        "....kUnnk.....",
        "....kUnnk.....",
        "...kUUUUnk....",
        "..kUUUUUUnk...",
        ".kUUUUUUUUnk..",
        "kkkkkkkkkkkkkk",
        "..............",
        "..............",
        "..............",
    ],
    "wick": [
        "......Y.......",
        ".....YyY......",
        ".....YfY......",
        ".....kfk......",
        "....kiiik.....",
        "...kiiiSik....",
        "...kiiiSik....",
        "...kSiiSik....",
        "...kSssSsk....",
        "...kSssssk....",
        "....ksssk.....",
        "....ksssk.....",
        ".....kkk......",
        "..............",
        "..............",
        "..............",
    ],
    "basilisk": [
        "..........kk..",
        ".....kk..kEEk.",
        "....kEEk.kEdk.",
        "...kEzzEk.kk..",
        "...kEzzEk.....",
        "....kEEkkkk...",
        ".....kEEzzEk..",
        "......kkEzzEk.",
        "....kk.kEzzEk.",
        "...kEEkkEEkk..",
        "..kEzzEEEk....",
        ".kEzzzzEk.....",
        ".kEzzEk.......",
        "..kEEk........",
        "...kk.........",
        "..............",
    ],
    "two_headed_serpent": [
        ".kk......kk...",
        "kEEk....kEEk..",
        "kzYk....kzYk..",
        "kEEk.kk.kEEk..",
        ".kEEkkEEkEk...",
        "..kEEEEEEEk...",
        "...kEEEEEEk...",
        "....kEEEEk....",
        "....kEEEEk....",
        "...kEEEEEEk...",
        "..kEEE..EEEk..",
        ".kEEk....kEEk.",
        ".kEk......kEk.",
        "..kk......kk..",
        "..............",
        "..............",
    ],
    "hornet_swarm": [
        "..............",
        "..Yk....kY....",
        ".kYYk..kYYk...",
        ".kxYkkkkYxk...",
        "..kkkYYkkk....",
        ".kggkYYkggk...",
        "kgggkxxkgggk..",
        "kggk.kk.kggk..",
        ".kk......kk...",
        "..kYk..kYk....",
        ".kYYk.kYYk....",
        ".kxYk.kYxk....",
        "..kk...kk.....",
        "..............",
        "..............",
        "..............",
    ],
    "dire_wolf": [
        "..............",
        ".kk......kk...",
        "kUUk....kUUk..",
        "kUwUk..kUwUk..",
        "kUUUUkkUUUUk..",
        ".kUYkUUkYUk...",
        "..kUUUUUUk....",
        "...kUiiUk.....",
        "...kUUUUk.....",
        "....kUUk......",
        "....kkkk......",
        "..............",
        "..............",
        "..............",
        "..............",
        "..............",
    ],
    "leech_league": [
        "..............",
        ".....kkkk.....",
        "....kavaaak...",
        "...kavvvvaa...",
        "..kavvvvvak...",
        ".kavvvvvaak...",
        "kavvvvvaak....",
        "kavvvvaak.....",
        ".kavvaak......",
        "..kvaak.......",
        "...kak........",
        "....kk........",
        "..............",
        "..............",
        "..............",
        "..............",
    ],
    "needleback": [
        "......k.k.k...",
        "...k.kUkUkUk..",
        "..kUkUkUkUkUk.",
        ".kUcUcUcUcUck.",
        "kUcCccccCcUck.",
        "kUcCcsssCcUk..",
        ".kCcCYYCcUk...",
        "..kCccccCk....",
        "...kCccCk.....",
        "....kCCk......",
        ".....kk.......",
        "..............",
        "..............",
        "..............",
        "..............",
        "..............",
    ],
    "mute_stone": [
        "......kk......",
        ".....kPPk.....",
        "....kPQQPk....",
        "...kPQYYQPk...",
        "..kPQQYYQQPk..",
        "..kPQQQQQPk...",
        "...kPQQQPk....",
        "....kPPPk.....",
        ".....kEEk.....",
        "....kEzEk.....",
        ".....kEk......",
        "......kk......",
        "..............",
        "..............",
        "..............",
        "..............",
    ],
    "victory_flask": [
        "....kGGGGGGk..",
        "...kGyyyyyGk..",
        "...kGyyyyyGk..",
        "...kGGGGGGGk..",
        "....kGGGGGk...",
        ".....kGGk.....",
        ".....kOOk.....",
        ".....kOOk.....",
        ".....kOOk.....",
        "....kGGGGk....",
        "...kGGGGGGk...",
        "...kkkkkkkk...",
        "..............",
        "..............",
        "..............",
        "..............",
    ],
    "cursed_scroll": [
        "..kkkkkkkkkk..",
        ".kiiiiiiiiik..",
        ".kiRRiiiiRik..",
        ".kiiiiiiiiik..",
        ".kiiiiRRiiik..",
        ".kiiiiiiiiik..",
        ".kiRiiiiiiik..",
        ".kiiiiiiiiik..",
        ".kkkkkkkkkkk..",
        "..kcccccck....",
        "...kcccck.....",
        "..............",
        "..............",
        "..............",
        "..............",
        "..............",
    ],
    "bodyguard": [
        "......kkkk......",
        ".....kmwwmk.....",
        ".....kmnnmk.....",
        ".....kmmmmk.....",
        "....kkssssk.....",
        "...kMmmmmMmk....",
        "..kUUUkkkkMMk...",
        ".kUUUUUk.kMMk...",
        "kUUUUUUk.kMMk...",
        "kUUUUUUkkmMmk...",
        ".kUUUUk.kmmk....",
        "..kUUk..kmmk....",
        "...kk...kMMk....",
        "........kmmk....",
        "........k..k....",
        ".......kk..kk...",
    ],
    "cowardly_king": [
        "....G.G.G.G.....",
        "...gGgGgGgGg....",
        "....gGGGGGGg....",
        ".....kkkkkk.....",
        "....kSssssSk....",
        "....ks.ss.sk....",
        "....kssssssk....",
        ".....kssssk.....",
        "...kkppppppkk...",
        "..kPPkppppkPPk..",
        "..kPkkppppkkPk..",
        "...kkppppppkk...",
        "....kppppppk....",
        "....kppkkppk....",
        "....kpkkkkpk....",
        ".....kk..kk.....",
    ],
    "petrify_stone": [
        "uUuUuUuUuUuUuU",
        "UuUUkUUuUUkUuU",
        "uUuUuUuUuUuUuU",
        "UuUuUuUUkUuUuU",
        "uUUkUuUuUuUuUu",
        "UuUuUuUuUuUUkU",
        "uUuUuUUkUuUuUu",
        "UUkUuUuUuUuUuU",
        "uUuUuUuUuUUkUu",
        "UuUuUUkUuUuUuU",
        "uUuUuUuUuUuUuU",
        "UuUUkUuUuUuUkU",
        "uUuUuUuUUkUuUu",
        "UuUuUuUuUuUuUu",
        "uUUkUuUuUuUUkU",
        "UuUuUuUuUuUuUu",
    ],
}


def slice_chaos_stone() -> Image.Image:
    # Senmou gems sheet — pick a distinct clustered gem crop.
    p = STONES
    if not p.exists():
        return draw(
            [
                "......kk......",
                ".....kPPk.....",
                "....kPQPpk....",
                "...kPQQQPk....",
                "...kPQYQPk....",
                "...kPQQQPk....",
                "....kPQPk.....",
                ".....kPPk.....",
                "....kEEek.....",
                "...kEzzEk.....",
                "....kEEk......",
                ".....kk.......",
                "..............",
                "..............",
                "..............",
                "..............",
            ]
        )
    sheet = Image.open(p).convert("RGBA")
    # sheet is a grid of stones; crop a colorful gem cluster (row 0-ish)
    w, h = sheet.size
    # try a 16x16 from a gem-looking region
    crop = sheet.crop((16, 0, 32, 16))
    # key near-white / grass
    px = crop.load()
    for y in range(16):
        for x in range(16):
            r, g, b, a = px[x, y]
            if r > 220 and g > 220 and b > 200:
                px[x, y] = (0, 0, 0, 0)
            elif g > r + 30 and g > 140:
                px[x, y] = (0, 0, 0, 0)
    return crop


def main() -> None:
    ITEM_MAP = {
        "iron_chain": "draw",
        "grappling_hook": "draw",
        "net": "draw",
        "counting_beads": "draw",
        "measuring_tape": "draw",
        "last_match": "draw",
        "grief_jar": "draw",
        "spiked_shield": "draw",
        "sai": "draw",
        "fangs": "draw",
        "knucklers": "draw",
        "crossbow": "draw",
        "mute_stone": "draw",
        "victory_flask": "draw",
        "cursed_scroll": "draw",
    }
    EXTRA_MAP = {
        "hollow": "twins",
        "beggar": "tiny85",
        "wick": "draw",
        "anvil": "draw",
        "basilisk": "draw",
        "two_headed_serpent": "draw",
        "wraith": "tiny121",
        "hornet_swarm": "draw",
        "dire_wolf": "draw",
        "leech_league": "draw",
        "needleback": "draw",
        "bodyguard": "draw",
        "cowardly_king": "draw",
    }

    hashes: dict[str, str] = {}

    def stamp(im: Image.Image, dest: Path) -> None:
        save(im, dest)
        h = hashlib.md5(dest.read_bytes()).hexdigest()
        hashes[str(dest.relative_to(ROOT))] = h
        print(dest.name, h[:10], im.size)

    for name, kind in ITEM_MAP.items():
        dest = ITEMS / f"{name}.png"
        if kind == "draw":
            stamp(draw(SPRITES[name]), dest)
        elif kind == "chaos":
            stamp(slice_chaos_stone(), dest)
        elif kind == "tiny_gold":
            stamp(gold_tint(tiny(125)), dest)
        elif kind == "jetrel":
            stamp(jet(25), dest)

    for name, kind in EXTRA_MAP.items():
        dest = EXTRA / f"{name}.png"
        if kind == "draw":
            stamp(draw(SPRITES[name]), dest)
        elif kind == "twins":
            stamp(composite_twins(), dest)
        elif kind == "tiny85":
            stamp(tiny(85), dest)
        elif kind == "tiny121":
            stamp(tiny(121), dest)

    stamp(draw(SPRITES["petrify_stone"]), UI / "petrify_stone.png")

    # uniqueness vs ALL dungeon item/extra pngs
    all_pngs = list(ITEMS.glob("*.png")) + list(EXTRA.glob("*.png"))
    by_hash: dict[str, list[str]] = {}
    for p in all_pngs:
        h = hashlib.md5(p.read_bytes()).hexdigest()
        by_hash.setdefault(h, []).append(p.name)
    dups = {h: n for h, n in by_hash.items() if len(n) > 1}
    print("DUPLICATES", dups if dups else "none")


if __name__ == "__main__":
    main()
