from common import *

# palette (intro_p4 night + cabin oak + Torchlit accents)
SKY = ['#121620', '#141a24', '#18202c', '#1e2838']
STAR, STAR_D = '#eef2f7', '#8a96a8'
RIDGE, RIDGE_D = '#222736', '#1a1e2a'
PINE = '#141820'
M_LIT, M_MID, M_SH, M_DEEP = '#2e3448', '#222736', '#1a1e2a', '#141820'
SNOW, SNOW_M, SNOW_S = '#eef2f7', '#c5cdd8', '#8a96a8'
HILL_LIT, HILL, HILL_D, HILL_DD = '#2e3e30', '#1e2a22', '#181d18', '#121612'
PATH_LIT, PATH, PATH_D = '#4a4438', '#3a3226', '#2a2420'
ROCK_LIT, ROCK, ROCK_SH, ROCK_D = '#5c564e', '#4a4640', '#3a3632', '#2a2420'
LOG_LIT, LOG, LOG_D, LOG_DD = '#74502e', '#5a3a24', '#3a2416', '#2c1a10'
ROOF_LIT, ROOF, ROOF_D = '#4a3020', '#3e2a20', '#2a1a12'
STONE_LIT, STONE, STONE_D = '#8a8478', '#5c564e', '#3a3632'
SMOKE, SMOKE_D = '#3a3e4a', '#2c303c'
WIN_IN, CURTAIN, CURTAIN_D = '#f0b040', '#9a3428', '#6a2418'
VOID = '#0b0706'
IRON, IRON_LIT = '#2a2a30', '#5c5a60'
SPILL = '#3a4430'   # warm-lit grass where door/window light lands
SPILL_P = '#5a5040' # warm-lit path

def build():
    s = Strip(SKY[0])
    # --- sky bands (straight, stepped like intro_p4)
    for y0, y1, c in [(0, 58, SKY[0]), (58, 96, SKY[1]), (96, 124, SKY[2]), (124, 160, SKY[3])]:
        s.rect(0, y0, W - 1, y1, c)
    rnd = random.Random(7)
    for i in range(46):
        x, y = rnd.randrange(W), rnd.randrange(2, 104)
        s.px(x, y, STAR if i % 3 else STAR_D)
    for x, y in [(36, 14), (154, 30), (232, 9), (398, 40), (118, 66)]:   # a few cross stars
        s.px(x, y, STAR)
        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            s.px(x + dx, y + dy, STAR_D)
    # --- far ridge (periodic)
    for x in range(W):
        top = int(126 + wave(x, [(5, 2, 0.4), (3, 5, 1.7), (1.5, 11, 0.2)]))
        s.vline(x, top, 160, RIDGE)
        s.vline(x, top + 9, 160, RIDGE_D)
    # far pines on the ridge (left and right of the mountain)
    for x, h in [(6, 9), (14, 6), (150, 7), (160, 11), (171, 6), (392, 8), (404, 12), (413, 7)]:
        top = int(126 + wave(x, [(5, 2, 0.4), (3, 5, 1.7), (1.5, 11, 0.2)]))
        for k in range(h):
            w = k // 2
            s.hline(x - w, x + w, top - h + k, PINE)
    # --- Mount Grumblegut (peak right of centre, right flank wraps behind the left edge)
    pk, py = 322, 20
    body = [(176, 152), (226, 96), (252, 62), (268, 52), (288, 38), (pk, py), (338, 32), (352, 42),
            (372, 58), (398, 74), (428, 96), (462, 120), (490, 152)]
    s.poly(body, M_MID)
    # lit (left) faces: upper-left light
    s.poly([(176, 152), (226, 96), (252, 62), (268, 52), (288, 38), (pk, py), (300, 60), (284, 84), (262, 104), (236, 130), (214, 152)], M_LIT)
    # shadow side (right of the ridge line from the peak)
    s.poly([(pk, py), (338, 32), (352, 42), (372, 58), (398, 74), (428, 96), (462, 120), (490, 152), (410, 152), (380, 120), (356, 84), (336, 52)], M_SH)
    # gullies
    s.poly([(300, 60), (306, 58), (296, 100), (288, 104)], M_SH)
    s.poly([(262, 104), (268, 102), (258, 130), (250, 132)], M_SH)
    s.poly([(356, 84), (362, 86), (374, 120), (366, 118)], M_DEEP)
    # snow cap
    s.poly([(306, 34), (pk, py), (338, 32), (332, 38), (326, 34), (320, 42), (314, 36), (310, 40)], SNOW_M)
    s.poly([(306, 34), (pk, py), (318, 32), (313, 34), (310, 40)], SNOW)
    s.poly([(pk, py), (338, 32), (332, 38), (326, 34), (322, 30)], SNOW_S)
    # second small cap on the left shoulder
    s.poly([(282, 44), (288, 38), (294, 44), (290, 46), (287, 43), (284, 47)], SNOW_M)
    # --- hill: back swell (cabin crest on the left, dips, rises into the mountain foot)
    for x in range(W):
        top = int(156 + wave(x, [(-5, 1, 0.9), (1.5, 3, 0.3)]))
        top = min(top, 160)
        s.vline(x, top, H - 1, HILL)
        s.px(x, top, HILL_LIT)
    # --- Mountain foot outcrop + the run door (Sprout's way in)
    crag = [(234, 162), (240, 146), (246, 138), (249, 128), (256, 124), (262, 114), (270, 112), (276, 102),
            (284, 106), (294, 98), (302, 104), (312, 102), (320, 112), (330, 114), (336, 126), (344, 130),
            (348, 144), (356, 162)]
    s.poly(crag, ROCK, INK)
    s.poly([(236, 161), (240, 146), (246, 138), (249, 128), (256, 124), (262, 114), (270, 112), (276, 102), (284, 106), (294, 98), (290, 108), (280, 110), (270, 118), (258, 130), (250, 144), (246, 161)], ROCK_LIT)
    s.poly([(312, 102), (320, 112), (330, 114), (336, 126), (344, 130), (348, 144), (355, 161), (338, 161), (334, 140), (322, 122)], ROCK_SH)
    s.poly([(302, 104), (312, 102), (316, 110), (306, 110)], ROCK_SH)
    # rock seams
    for a, b in [((256, 150), (264, 138)), ((330, 150), (336, 136)), ((268, 124), (280, 118))]:
        s.d.line([(a[0] + W, a[1]), (b[0] + W, b[1])], fill=ROCK_D)
    # mouth (dark belly) with stone teeth
    mouth = [(276, 161), (276, 126), (312, 126), (312, 161)]
    s.poly(mouth, VOID, INK)
    for tx, tl in [(281, 5), (287, 4), (294, 6), (301, 4), (307, 5)]:
        top = 127
        tl = tl - 1
        s.poly([(tx - 2, top), (tx + 2, top), (tx, top + tl)], ROCK_SH, None)
        s.px(tx - 1, top, ROCK_LIT)
    # two glints in the dark: the mountain wants it back
    s.px(296, 140, '#d5443b'); s.px(299, 140, '#d5443b')
    # timber run-door frame
    s.rect(272, 126, 275, 161, LOG, INK)
    s.rect(313, 126, 316, 161, LOG_D, INK)
    s.vline(273, 127, 160, LOG_LIT)
    s.rect(270, 122, 318, 126, LOG, INK)
    s.hline(271, 317, 123, LOG_LIT)
    # open door leaf, swung out to the right against the rock
    leaf = [(317, 128), (326, 131), (326, 161), (317, 161)]
    s.poly(leaf, LOG_D, INK)
    s.vline(320, 131, 160, LOG_DD); s.vline(323, 132, 160, LOG_DD)
    s.hline(318, 325, 136, IRON); s.hline(318, 325, 154, IRON)
    s.px(318, 136, IRON_LIT); s.px(318, 154, IRON_LIT)
    # torch on the frame (Torchlit accent)
    s.rect(266, 132, 268, 140, IRON, INK)
    s.poly([(264, 132), (270, 132), (269, 134), (265, 134)], IRON)
    s.poly([(265, 131), (267, 124), (269, 131)], TORCH)
    s.poly([(266, 131), (267, 127), (268, 131)], GOLD)
    s.px(267, 125, CREAM)
    # torchlight on the outcrop face (stepped, only over rock pixels)
    for (cx, cy, r, src, dst) in [(267, 130, 13, ROCK_LIT, '#6e665a'), (267, 130, 13, ROCK, ROCK_LIT), (267, 130, 7, LOG, LOG_LIT)]:
        for y in range(cy - r, cy + r + 1):
            for x in range(cx - r, cx + r + 1):
                if (x - cx) ** 2 + (y - cy) ** 2 <= r * r and s.get(x, y) == Image.new('RGB', (1, 1), src).getpixel((0, 0)):
                    s.px(x, y, dst)
    # --- Grandpa's cabin on the crest (left; Nib stands at its open door)
    cx0, cx1, base = 26, 118, 158
    # chimney (stone, behind roof)
    s.rect(96, 92, 106, 130, STONE, INK)
    for y in range(94, 128, 4):
        off = 0 if (y // 4) % 2 else 2
        for x in range(97 + off, 106, 4):
            s.px(x, y, STONE_D)
        s.hline(97, 105, y + 3, STONE_D)
    s.vline(97, 93, 128, STONE_LIT)
    s.rect(94, 90, 108, 93, STONE_D, INK)
    s.hline(95, 107, 91, STONE_LIT)
    # smoke (static puffs, drifting right with the wind toward the mountain)
    for (x, y, r, c) in [(104, 82, 4, SMOKE), (110, 72, 5, SMOKE), (119, 61, 6, SMOKE_D), (131, 52, 6, SMOKE_D)]:
        s.ellipse(x - r, y - r, x + r, y + r, c)
    s.px(102, 80, '#4a4e5a'); s.px(107, 69, '#4a4e5a')
    # walls (horizontal logs)
    s.rect(cx0, 122, cx1, base, LOG_D, INK)
    for i, y in enumerate(range(123, base, 5)):
        s.hline(cx0 + 1, cx1 - 1, y, LOG)
        s.hline(cx0 + 1, cx1 - 1, y + 3, LOG_DD)
        s.px(cx0 + 2 + (i * 13) % 80, y + 1, LOG)  # grain
    # round log ends on both corners
    for y in range(123, base - 1, 5):
        for xe in (cx0 - 1, cx1 - 1):
            s.rect(xe, y, xe + 2, y + 3, LOG, INK)
            s.px(xe + 1, y + 1, LOG_LIT)
    # roof
    roof = [(cx0 - 10, 123), (52, 98), (cx1 - 22, 98), (cx1 + 10, 123)]
    s.poly(roof, ROOF, INK)
    for y in range(101, 123, 4):
        xl = int(cx0 - 10 + (52 - (cx0 - 10)) * (123 - y) / 25.0)
        xr = int(cx1 + 10 - ((cx1 + 10) - (cx1 - 22)) * (123 - y) / 25.0)
        s.hline(xl + 1, xr - 1, y, ROOF_D)
        for x in range(xl + 3 + (y % 8), xr - 2, 9):
            s.px(x, y - 1, ROOF_D)
    s.d.line([(cx0 - 10 + W, 122), (52 + W, 98)], fill=ROOF_LIT)
    s.hline(53, cx1 - 23, 99, ROOF_LIT)
    s.rect(cx0 - 11, 122, cx1 + 11, 124, ROOF_D, INK)
    # open front door, warm light (Nib's spot)
    s.rect(42, 128, 58, base, LOG_DD, INK)
    s.rect(43, 129, 57, base - 1, WIN_IN)
    s.rect(46, 131, 57, base - 1, GOLD)
    s.poly([(43, 129), (47, 131), (47, base - 1), (43, base - 1)], LOG)   # door leaf swung inward
    s.vline(44, 130, base - 1, LOG_LIT)
    s.rect(40, 125, 60, 127, LOG, INK)       # lintel
    s.hline(41, 59, 126, LOG_LIT)
    # window with red curtains (matches intro_p5)
    s.rect(76, 130, 92, 144, LOG_DD, INK)
    s.rect(77, 131, 91, 143, WIN_IN)
    s.rect(80, 132, 88, 142, GOLD)
    s.vline(84, 131, 143, LOG_DD); s.hline(77, 91, 137, LOG_DD)
    s.rect(77, 131, 78, 143, CURTAIN); s.rect(90, 131, 91, 143, CURTAIN_D)
    s.rect(74, 145, 94, 146, LOG, INK)
    # porch step
    s.rect(38, base - 1, 64, base + 2, STONE, INK)
    s.hline(39, 63, base, STONE_LIT)
    # Grandpa's things by the cabin: woodpile, stump with his axe, his old pick leaning by the door
    for i, (x, y) in enumerate([(100, 154), (105, 154), (110, 154), (102, 150), (107, 150), (104, 146)]):
        s.ellipse(x - 2, y - 2, x + 2, y + 2, LOG, INK)
        s.px(x - 1, y - 1, LOG_LIT); s.px(x, y, LOG_DD)
    s.rect(126, 152, 134, 161, LOG_D, INK); s.hline(127, 133, 153, LOG_LIT); s.hline(127, 133, 152, LOG)
    s.d.line([(130 + W, 152), (134 + W, 144)], fill=LOG_LIT)     # axe handle
    s.poly([(133, 142), (137, 144), (135, 147), (132, 145)], '#9aa0aa', INK)
    s.d.line([(64 + W, 157), (68 + W, 138)], fill=LOG)            # pick haft
    s.poly([(62, 139), (68, 136), (74, 139), (68, 138)], '#9aa0aa', INK)
    # --- floor: the path along y=161 (clean, feet line), grass below
    for x in range(W):
        s.vline(x, 159, 166, PATH)
        s.px(x, 159, PATH_LIT)
        s.px(x, 166, PATH_D)
    rp = random.Random(3)
    for i in range(18):                                   # sparse path stones below the feet line
        x = rp.randrange(W); y = rp.choice([163, 164, 165])
        s.hline(x, x + 2, y, PATH_D); s.px(x, y - 1, PATH_LIT)
    for x in range(W):                                    # grass bands to the bottom
        b1 = int(196 + wave(x, [(3, 2, 0.1), (2, 7, 1.0)]))
        b2 = int(228 + wave(x, [(3, 3, 2.0), (2, 9, 0.3)]))
        s.vline(x, 167, H - 1, HILL)
        s.vline(x, b1, H - 1, HILL_D)
        s.vline(x, b2, H - 1, HILL_DD)
    rg = random.Random(11)
    for i in range(40):                                   # grass tufts (2 tone)
        x = rg.randrange(W); y = rg.randrange(170, 250)
        c = HILL_LIT if y < 200 else HILL
        s.px(x, y, c); s.px(x - 1, y + 1, c); s.px(x + 1, y + 1, c)
    for (x, y, w) in [(20, 214, 9), (148, 236, 12), (212, 204, 7), (366, 222, 10), (300, 246, 8)]:  # stones
        s.ellipse(x, y, x + w, y + w // 2 + 1, ROCK_SH, INK)
        s.hline(x + 2, x + w - 3, y + 1, ROCK)
    # warm spill from the door and window onto path/grass
    for x in range(36, 72):
        for y in range(160, 172):
            if abs(x - 52) + (y - 160) * 3 < 18 and y <= 166:
                c = s.get(x, y)
                s.px(x, y, SPILL_P if c in ((0x3a, 0x32, 0x26), (0x4a, 0x44, 0x38)) else SPILL if y > 166 else c)
    # bushes hugging the low edge of the path (dark rounds like intro_p5)
    for (x, r) in [(14, 6), (24, 5), (150, 5), (160, 7), (171, 4), (222, 5), (368, 6), (380, 5), (392, 7)]:
        s.ellipse(x - r, 166 - r // 2, x + r, 166 + r, '#1a2a1e', INK)
        s.px(x - r // 2, 166 - r // 2 + 2, '#2e4030'); s.px(x - r // 2 + 1, 166 - r // 2 + 2, '#2e4030')
    # dry-stone field wall lower on the hill (periodic, low contrast, not a walk line)
    for x in range(W):
        y = int(206 + wave(x, [(4, 1, 1.2), (2, 3, 0.4)]))
        s.vline(x, y, y + 6, ROCK_D)
        if x % 7 in (0,):
            s.vline(x, y, y + 6, INK)
        elif x % 7 in (1, 2, 3):
            s.px(x, y, ROCK_SH)
        if (x // 7) % 2:
            s.px(x, y + 3, INK)
    # foreground grass silhouettes at the very bottom (frames, never in the lane)
    for x in range(W):
        h = int(6 + wave(x, [(4, 6, 0.5), (3, 17, 1.1)]))
        s.vline(x, H - 1 - max(h, 0), H - 1, '#0e120e')
    return s.tile()

if __name__ == '__main__':
    img = build()
    ship(img, '<TITLE_TEASER>/out/hill_strip_native.png', '<TITLE_TEASER>/out/hill_strip.png')
    print(img.size, len(set(img.getdata())))
