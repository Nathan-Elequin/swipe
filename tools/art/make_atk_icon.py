"""Write the ATK burst icons.

Keeps the original 18 and 36 files, and writes single/double/triple/loop
at S=18 and S=24, each also at 2x nearest, under assets/ui/icons/.
"""
from pathlib import Path

from PIL import Image

PALETTE = {
    "#": (0x10, 0x0E, 0x0C, 255),
    "f": (0xF6, 0x9C, 0x2C, 255),
    "h": (0xFF, 0xF0, 0xC0, 255),
    "m": (0xDC, 0x70, 0x1C, 255),
    "s": (0x9C, 0x44, 0x10, 255),
    ".": (0, 0, 0, 0),
}

BACK = {
    "f": "m",
    "h": "f",
    "m": "s",
    "s": "s",
    "#": "#",
    ".": ".",
}

SINGLE_18 = [
    "........##........",
    ".##....#ff#....##.",
    ".#h#..#ffff#..#s#.",
    ".#ff##ffffff##ms#.",
    "..#ffhfffffffms#..",
    "..#fhffffffffms#..",
    ".##fhffffffffms##.",
    "##ffffffffffffms##",
    "#ffffffffffffffms#",
    "#ffffffffffffffms#",
    "##ffffffffffffms##",
    ".##ffffffffffms##.",
    "..#fmmffffffmms#..",
    "..#mssmffffmsss#..",
    ".#ms##smffms##ss#.",
    ".#s#..#smms#..#s#.",
    ".##....#ss#....##.",
    "........##........",
]

LOOP_18 = [
    "........######....",
    ".##....#f#hhh####.",
    ".#h#..#ff##hhh###.",
    ".#ff##ffff###hh##.",
    "..#ffhffffff##hh##",
    "..#fhffffffff##hh#",
    ".##fhffffffffm#hh#",
    "##ffffffffffff##h#",
    "#ffffffffffffff#h#",
    "#ffffffffffffff#h#",
    "##ffffffffffff##h#",
    ".##ffffffffffm#hf#",
    "..#fmm###fffm##hf#",
    "..#m###h#ffm##hf##",
    ".####hhh#f###hh##.",
    ".##hhhh####hhf###.",
    ".###hhhhhhhff####.",
    "...##hh#######....",
]

LOOP_24 = [
    "...........######.......",
    ".###.....##ff#hh###.###.",
    ".###.....##ff#hhhh#####.",
    ".##h#...#ffff##hhhh####.",
    ".##ff###ffffff###hhh###.",
    "...#fffhffffffff##hhh##.",
    "...#fffhfffffffff##hhh#.",
    "...#fhhffffffffffm##hh##",
    ".###fhhffffffffffmm#hhh#",
    "###ffffffffffffffff##hh#",
    "###ffffffffffffffffm#hh#",
    "#fffffffffffffffffff#hh#",
    "#fffffffffffffffffff#hf#",
    "###ffffffffffffffffm#hf#",
    "###ffffffffffffffff##hf#",
    ".###fffffffffffffmm#hhf#",
    "...#fmmmffffffffmm##hf##",
    "...#mss####ffffms##hhf#.",
    "...#m###hh#ffffm##hhf##.",
    ".#####hhhh#ffm###hhf###.",
    ".###hhhhhh#####hhhf####.",
    ".####hhhhhhhhhhhff#####.",
    ".#####hhhfffffff###.###.",
    ".....#hhh########.......",
]


def _from_rows(rows):
    h = len(rows)
    w = len(rows[0])
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for y, row in enumerate(rows):
        if len(row) != w:
            raise SystemExit("row %s length %s, want %s" % (y, len(row), w))
        for x, ch in enumerate(row):
            if ch not in PALETTE:
                raise SystemExit("bad char %r at %s,%s" % (ch, x, y))
            px[x, y] = PALETTE[ch]
    return img


def _remap_back(src):
    inv = {PALETTE[k]: k for k in PALETTE}
    out = Image.new("RGBA", src.size, (0, 0, 0, 0))
    sp = src.load()
    dp = out.load()
    for y in range(src.size[1]):
        for x in range(src.size[0]):
            p = sp[x, y]
            if p[3] == 0:
                continue
            ch = inv.get(p)
            if ch is None:
                raise SystemExit("color not in palette at %s,%s %s" % (x, y, p))
            dp[x, y] = PALETTE[BACK[ch]]
    return out


def _paste(dst, src, ox, oy):
    sp = src.load()
    dp = dst.load()
    for y in range(src.size[1]):
        for x in range(src.size[0]):
            p = sp[x, y]
            if p[3] == 0:
                continue
            dp[ox + x, oy + y] = p


def _stack(single, copies):
    s = single.size[0]
    off = s // 3
    dy = off // 2
    if copies == 2:
        canvas = Image.new("RGBA", (s + off, s + dy), (0, 0, 0, 0))
        _paste(canvas, _remap_back(single), off, 0)
        _paste(canvas, single, 0, dy)
        return canvas
    canvas = Image.new("RGBA", (s + 2 * off, s + 2 * dy), (0, 0, 0, 0))
    back = _remap_back(single)
    _paste(canvas, back, 2 * off, 0)
    _paste(canvas, back, off, dy)
    _paste(canvas, single, 0, 2 * dy)
    return canvas


def _save_pair(out_dir, kind, s, img):
    path = out_dir / ("atk_burst_%s_s%s.png" % (kind, s))
    path2 = out_dir / ("atk_burst_%s_s%s_2x.png" % (kind, s))
    img.save(path)
    img.resize((img.size[0] * 2, img.size[1] * 2), Image.Resampling.NEAREST).save(path2)
    print("%s %s  2x %s" % (path.name, img.size, path2.name))


def main():
    root = Path(__file__).resolve().parents[2]
    out_dir = root / "assets" / "ui" / "icons"
    out_dir.mkdir(parents=True, exist_ok=True)
    single18 = _from_rows(SINGLE_18)
    if single18.size != (18, 18):
        raise SystemExit(single18.size)
    loop18 = _from_rows(LOOP_18)
    loop24 = _from_rows(LOOP_24)
    if loop18.size != (18, 18) or loop24.size != (24, 24):
        raise SystemExit((loop18.size, loop24.size))
    single24 = single18.resize((24, 24), Image.Resampling.NEAREST)
    kinds = {
        18: {
            "single": single18,
            "double": _stack(single18, 2),
            "triple": _stack(single18, 3),
            "loop": loop18,
        },
        24: {
            "single": single24,
            "double": _stack(single24, 2),
            "triple": _stack(single24, 3),
            "loop": loop24,
        },
    }
    expect = {
        (18, "double"): (24, 21),
        (18, "triple"): (30, 24),
        (24, "double"): (32, 28),
        (24, "triple"): (40, 32),
        (18, "single"): (18, 18),
        (18, "loop"): (18, 18),
        (24, "single"): (24, 24),
        (24, "loop"): (24, 24),
    }
    for s, group in kinds.items():
        for kind, img in group.items():
            want = expect[(s, kind)]
            if img.size != want:
                raise SystemExit("%s s%s is %s want %s" % (kind, s, img.size, want))
            _save_pair(out_dir, kind, s, img)
    single18.save(out_dir / "atk_burst_18.png")
    single18.resize((36, 36), Image.Resampling.NEAREST).save(out_dir / "atk_burst.png")
    print("atk_burst_18.png (18, 18)")
    print("atk_burst.png (36, 36)")


if __name__ == "__main__":
    main()
