"""title_still.png for Swipe: composition B "Loot river" + dragon claw from C.
Native 420x260, opaque, no AA, shipped 4x nearest. $0, PIL/numpy only. No lettering."""
import math, random, sys
import numpy as np
from PIL import Image, ImageDraw
sys.path.insert(0, '<TITLE_TEASER>/gen')
from still_sprites import S, PAL

W, H = 420, 260
OUT = '<TITLE_TEASER>/out/'
INK = (16, 14, 12)
C = dict(
 sky0=(12, 14, 22), sky1=(18, 22, 32), sky2=(20, 26, 36),
 far=(26, 30, 42), mtnD=(26, 30, 42), mtn=(34, 39, 54), mtnL=(46, 52, 72), mtnH=(58, 64, 86),
 snowD=(74, 80, 100), snow=(110, 118, 138),
 warm1=(52, 42, 46), warm2=(74, 52, 42), warm3=(100, 64, 40),
 rockD=(28, 24, 22), rock=(42, 36, 32), rockL=(58, 50, 38), rockH=(74, 68, 56),
 grassD=(14, 18, 14), grass=(18, 22, 18), grassM=(24, 29, 24), grassL=(30, 42, 34), grassH=(46, 62, 48),
 gnd=(20, 16, 12), gnd2=(26, 20, 16),
 ghostO=(36, 40, 52), ghost=(48, 52, 66), ghostL=(62, 66, 82),
 void=(11, 7, 6), oak=(59, 38, 24), edge=(122, 78, 43), rivet=(184, 115, 58), torch=(240, 154, 52),
 gold=(255, 216, 74), gold2=(232, 195, 106), cream=(255, 243, 214), lootD=(150, 92, 44),
)
img = np.zeros((H, W, 3), np.uint8)
rng = random.Random(7)

def put(x, y, c):
    if 0 <= x < W and 0 <= y < H: img[y, x] = c

def mask_of(fn):
    m = Image.new('L', (W, H), 0); fn(ImageDraw.Draw(m)); return np.array(m) > 0

def sh(M, dx, dy):
    """value of M at (x-dx, y-dy) -> True where neighbour exists"""
    out = np.zeros_like(M)
    ys = slice(max(dy, 0), H + min(dy, 0)); yd = slice(max(-dy, 0), H + min(-dy, 0))
    xs = slice(max(dx, 0), W + min(dx, 0)); xd = slice(max(-dx, 0), W + min(-dx, 0))
    out[ys, xs] = M[yd, xd]; return out

def blob(M, dark, mid, light, shine=None, outline=INK, hl=1, sd=2):
    """flat 3-4 tone fill lit from upper-left; ink outline outside the mask"""
    img[M] = mid
    lit = M & ~(sh(M, 1, 1) & sh(M, 0, 1) & sh(M, 1, 0))
    if hl > 1: lit |= M & ~(sh(M, 2, 2))
    shad = M & ~(sh(M, -1, -1) & sh(M, 0, -1) & sh(M, -1, 0))
    if sd > 1: shad |= M & ~sh(M, -2, -2)
    img[shad] = dark; img[lit & ~shad] = light
    if shine is not None:
        sp = M & ~sh(M, 3, 3) & sh(M, 1, 1)
        img[sp & ~shad] = shine
    if outline is not None:
        ring = (sh(M, 1, 0) | sh(M, -1, 0) | sh(M, 0, 1) | sh(M, 0, -1)) & ~M
        img[ring] = outline

def stamp(name, x, y, outline=INK, flip=False, pal=None, mul=None):
    rows = [r for r in S[name].strip('\n').split('\n')]
    if flip: rows = [r[::-1] for r in rows]
    h = len(rows); w = max(len(r) for r in rows)
    M = np.zeros((h + 2, w + 2), bool)
    for j, r in enumerate(rows):
        for i, ch in enumerate(r):
            if ch != '.': M[j + 1, i + 1] = True
    if outline is not None:
        ring = np.zeros_like(M)
        ring[1:, :] |= M[:-1, :]; ring[:-1, :] |= M[1:, :]; ring[:, 1:] |= M[:, :-1]; ring[:, :-1] |= M[:, 1:]
        ring &= ~M
        for j, i in zip(*np.nonzero(ring)): put(x + i - 1, y + j - 1, outline)
    p = pal or {}
    for j, r in enumerate(rows):
        for i, ch in enumerate(r):
            if ch == '.': continue
            c = p.get(ch, PAL[ch])
            if mul: c = mul(c)
            put(x + i, y + j, c)
    return w, h

def ring_fill(cx, cy, rx, ry, col, clip=None, dither=False):
    for y in range(max(0, cy - ry - 1), min(H, cy + ry + 2)):
        for x in range(max(0, cx - rx - 1), min(W, cx + rx + 2)):
            v = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
            ok = v <= 1.0 or (dither and v <= 1.12 and (x + y) % 2 == 0)
            if ok and (clip is None or clip[y, x]): img[y, x] = col

# ---------------------------------------------------------------- sky
for y in range(H):
    img[y, :] = C['sky0'] if y < 34 else C['sky1'] if y < 92 else C['sky2']
for x in range(W):  # checker transitions between bands
    if x % 2 == 0: img[34, x] = C['sky1']
    if x % 2 == 1: img[92, x] = C['sky2']
LOGO = (85, 20, 335, 60); TAG = (65, 62, 355, 83); HUB = (120, 65, 300, 195); CLICK = (85, 230, 335, 250)
def inr(x, y, r, pad=0): return r[0] - pad <= x < r[2] + pad and r[1] - pad <= y < r[3] + pad
for i in range(70):
    x = (i * 97 + 13) % W; y = (i * 53 + 7) % 120
    if inr(x, y, LOGO, 3) or inr(x, y, TAG, 3): continue
    put(x, y, C['cream'] if i % 5 == 0 else (138, 150, 168) if i % 2 else (74, 80, 100))
    if i % 11 == 0:  # twinkle cross
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)): put(x + dx, y + dy, (74, 80, 100))

# ---------------------------------------------------------------- distant ranges
far = mask_of(lambda d: d.polygon([(0, 120), (30, 104), (58, 112), (80, 100), (110, 116), (110, 260), (0, 260)], fill=1))
far |= mask_of(lambda d: d.polygon([(300, 110), (336, 92), (360, 100), (392, 84), (420, 96), (420, 260), (300, 260)], fill=1))
img[far] = C['far']

# ---------------------------------------------------------------- Mount Grumblegut
PEAK = (210, 27)
mtn = mask_of(lambda d: d.polygon([(0, 150), (40, 132), (78, 104), (118, 76), (150, 52), (178, 38), (198, 29), PEAK, (222, 30),
                                    (244, 40), (272, 54), (302, 74), (334, 94), (372, 112), (420, 126), (420, 260), (0, 260)], fill=1))
img[mtn] = C['mtn']
# lit left face (light from upper-left)
litf = mtn & mask_of(lambda d: d.polygon([PEAK, (204, 62), (170, 96), (128, 132), (60, 170), (0, 176), (0, 150), (40, 132), (78, 104), (118, 76), (150, 52), (178, 38), (198, 29)], fill=1))
img[litf] = C['mtnL']
# ridge highlight line along the upper-left silhouette
for x in range(0, 210):
    col = np.nonzero(mtn[:, x])[0]
    if len(col): put(x, col[0], C['mtnH']); 
    if len(col) and x % 3 != 0: put(x, col[0] + 1, C['mtnH'])
# shadow side right of a long gully
shad = mtn & mask_of(lambda d: d.polygon([(222, 30), (244, 40), (272, 54), (302, 74), (334, 94), (372, 112), (420, 126), (420, 150), (330, 128), (270, 96), (232, 60)], fill=1))
img[shad] = C['mtnD']
# a few quiet gullies (kept out of logo/tagline rects mostly: low contrast)
for pts in [[(150, 92), (138, 112), (126, 130)], [(256, 100), (270, 118), (286, 136)], [(92, 128), (80, 146)], [(330, 140), (348, 160)]]:
    ImageDraw.Draw(Image.fromarray(img))  # noop
    for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
        n = max(abs(x1 - x0), abs(y1 - y0))
        for t in range(n + 1):
            put(round(x0 + (x1 - x0) * t / n), round(y0 + (y1 - y0) * t / n), C['mtnD'])
# muted snow cap (dim so the logo stays calm)
snow = mask_of(lambda d: d.polygon([(196, 34), PEAK, (224, 35), (218, 38), (214, 36), (209, 41), (204, 37), (200, 39)], fill=1))
img[snow] = C['snowD']
snowl = snow & mask_of(lambda d: d.polygon([(196, 34), PEAK, (210, 38), (204, 37), (200, 39)], fill=1))
img[snowl] = C['snow']

# ---------------------------------------------------------------- warm spill around the belly mouth
MX, MY = 210, 138
for rx, ry, col in [(78, 62, C['warm1']), (62, 50, C['warm2']), (52, 42, C['warm3'])]:
    ring_fill(MX, MY + 4, rx, ry, col, clip=mtn, dither=True)
# belly bulge rim: rock lip around the mouth
lip = mask_of(lambda d: d.ellipse([MX - 48, MY - 34, MX + 48, MY + 34], fill=1))
blob(lip, C['rockL'], (120, 82, 52), (156, 108, 66), outline=INK)
mouth = mask_of(lambda d: d.ellipse([MX - 40, MY - 27, MX + 40, MY + 30], fill=1))
img[mouth] = C['void']
# interior glow (stepped rings, hot core low in the mouth where the hoard sits)
for rx, ry, col in [(36, 24, C['oak']), (30, 19, C['edge']), (24, 15, C['rivet']), (18, 11, C['torch']), (12, 8, C['gold']), (6, 4, C['cream'])]:
    ring_fill(MX, MY + 12, rx, ry, col, clip=mouth, dither=True)
# hoard silhouette inside: heaped coins
for i in range(160):
    a = rng.uniform(math.pi * 0.05, math.pi * 0.95); r = rng.uniform(0, 1)
    x = int(MX + math.cos(a) * 34 * r * (1 if rng.random() < .5 else -1)); y = int(MY + 26 - math.sin(a) * 14 * r)
    if mouth[y, x]:
        put(x, y, C['gold'] if rng.random() < .5 else C['gold2'])
        if rng.random() < .3: put(x + 1, y, C['cream'])
# teeth: stalactites on the upper lip, stalagmites at the lower corners
for tx, tl in [(178, 7), (188, 10), (199, 8), (210, 12), (221, 8), (232, 10), (242, 7)]:
    top = np.nonzero(mouth[:, tx])[0][0]
    tooth = mask_of(lambda d: d.polygon([(tx - 3, top - 1), (tx + 3, top - 1), (tx, top + tl)], fill=1)) & mouth
    blob(tooth, (150, 140, 120), C['cream'] if False else (220, 208, 180), (246, 238, 214), outline=INK, sd=1)
for tx, tl in [(176, 8), (186, 6), (234, 6), (244, 8)]:
    bot = np.nonzero(mouth[:, tx])[0][-1]
    tooth = mask_of(lambda d: d.polygon([(tx - 3, bot + 1), (tx + 3, bot + 1), (tx, bot - tl)], fill=1)) & mouth
    blob(tooth, (150, 140, 120), (220, 208, 180), (246, 238, 214), outline=INK, sd=1)

# ---------------------------------------------------------------- ground band (calm under the Click rect)
gnd = mask_of(lambda d: d.polygon([(0, 226), (170, 222), (260, 218), (300, 214), (420, 206), (420, 260), (0, 260)], fill=1))
blob(gnd, C['gnd'], C['gnd2'], C['rock'], outline=INK, sd=1)
for i in range(40):  # sparse pebbles, never inside CLICK
    x = rng.randrange(96, 420); y = rng.randrange(222, 260)
    if gnd[y, x] and not inr(x, y, CLICK, 3): put(x, y, C['rock'])

# ---------------------------------------------------------------- Kettle Hill (lower-left) + ghost cabin + Nib
hill = mask_of(lambda d: d.polygon([(0, 178), (18, 172), (40, 171), (60, 177), (78, 188), (96, 206), (112, 226), (0, 236)], fill=1))
blob(hill, C['grass'], C['grassM'], C['grassL'], outline=INK, hl=2, sd=1)
for x in range(2, 90, 5):  # grass tufts on the crest
    col = np.nonzero(hill[:, x])[0]
    if len(col): put(x, col[0] - 1, C['grassH']); put(x + 1, col[0] - 2, C['grassH'])
# ghost cabin: faint, cool, low-contrast outline
GO = C['ghostO']
cab = mask_of(lambda d: d.rectangle([10, 157, 38, 176], fill=1))
blob(cab, C['ghostO'], C['ghost'], C['ghostL'], outline=(30, 34, 44), sd=1)
roof = mask_of(lambda d: d.polygon([(5, 158), (24, 145), (43, 158)], fill=1))
blob(roof, (40, 42, 54), (54, 56, 70), C['ghostL'], outline=(30, 34, 44), sd=1)
for y in range(160, 176, 3): 
    for x in range(11, 38): put(x, y, C['ghostO']) if x % 9 else None   # log lines
img[146:152, 33:36] = C['ghostO']  # chimney
for x, y in [(36, 143), (38, 140), (37, 137)]: put(x, y, C['ghostL'])  # smoke wisp
for y in range(163, 169):
    for x in range(14, 20): put(x, y, (120, 84, 50) if (x + y) % 2 else (150, 100, 52))  # window (dim warm)
put(16, 165, (30, 34, 44)); put(17, 165, (30, 34, 44))
for y in range(165, 177):
    for x in range(26, 32): put(x, y, (92, 70, 48))  # open door, faint warm
# Nib at the door, ghosted (cool), lantern stays warm
ghostmap = {'U': (66, 74, 104), 'm': (96, 92, 80), 'w': (150, 150, 140), 'k': (30, 34, 44), 'Y': C['gold']}
stamp('nib_ghost', 30, 165, outline=(30, 34, 44), pal=ghostmap)
for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
    put(39 + dx, 173 + dy, C['torch'])
put(39, 173, C['cream']); put(39, 174, C['gold'])
for dx in range(-4, 5):
    for dy in range(-4, 5):
        r2 = dx * dx + dy * dy
        if 2 < r2 <= 12 and (dx + dy) % 2 == 0 and tuple(img[173 + dy, 39 + dx]) not in [INK]: put(39 + dx, 173 + dy, (150, 100, 52) if r2 <= 5 else (92, 70, 48))
put(39, 173, C['cream']); put(39, 174, C['gold']); put(38, 173, C['torch']); put(40, 173, C['torch']); put(39, 172, C['torch'])

# ---------------------------------------------------------------- the loot river
cl = [(210, 160, 26), (213, 176, 30), (210, 192, 34), (188, 203, 32), (160, 208, 32), (130, 211, 32), (104, 216, 30), (82, 226, 30), (66, 242, 32), (54, 262, 36)]
river = np.zeros((H, W), bool)
pts = []
for (x0, y0, w0), (x1, y1, w1) in zip(cl, cl[1:]):
    for t in range(12):
        f = t / 12; pts.append((x0 + (x1 - x0) * f, y0 + (y1 - y0) * f, w0 + (w1 - w0) * f))
pts.append(cl[-1])
for x, y, w in pts:
    river |= mask_of(lambda d: d.ellipse([x - w / 2, y - w * 0.32, x + w / 2, y + w * 0.32], fill=1))
river &= ~mask_of(lambda d: d.rectangle([CLICK[0] - 1, CLICK[1] - 1, CLICK[2], CLICK[3]], fill=1))  # keep Click calm
river[:MY + 18, :] &= ~mouth[:MY + 18, :]  # pours out from below the hoard
river[:150, :] = False
blob(river, C['lootD'], C['rivet'], C['gold2'], outline=INK, hl=2, sd=2)
# coin-bed texture: lots of tiny coins (bright on top-left), gems sprinkled
RV = np.argwhere(river)
for k in range(1100):
    y, x = RV[rng.randrange(len(RV))]
    if not (river[y, x] and river[min(H - 1, y + 1), x] and river[y, min(W - 1, x + 1)]): continue
    r = rng.random()
    if r < .45: put(x, y, C['gold']); put(x + 1, y, C['gold2']); put(x, y + 1, C['rivet'])
    elif r < .70: put(x, y, C['gold2'])
    elif r < .78: put(x, y, C['cream'])
    elif r < .84: put(x, y, PAL['R']); put(x + 1, y, PAL['r'])
    elif r < .90: put(x, y, PAL['u']); put(x + 1, y, PAL['U'])
    elif r < .94: put(x, y, PAL['v'])
    else: put(x, y, C['edge'])
# bright current line down the river core (brightest band)
core = [(210, 166), (212, 182), (204, 196), (180, 204), (150, 207), (120, 211), (96, 219), (78, 232), (66, 248), (60, 259)]
for (x0, y0), (x1, y1) in zip(core, core[1:]):
    n = max(abs(x1 - x0), abs(y1 - y0))
    for t in range(n + 1):
        x = round(x0 + (x1 - x0) * t / n); y = round(y0 + (y1 - y0) * t / n)
        if river[y, x] and t % 3 != 2: put(x, y, C['gold'])
        if river[y - 1, x] and t % 4 == 0: put(x, y - 1, C['cream'])
# pour over the lip: a short bright cascade
for y in range(150, 168):
    for x in range(198, 224):
        if (x - 211) ** 2 / 140 + (y - 159) ** 2 / 110 < 1 and (x * 3 + y) % 4: put(x, y, C['gold'] if (x + y) % 3 else C['cream'])

# items in the river: (name, x, y, flip). far (near mouth) -> near (lower-left), drawn back to front
RIVER_ITEMS = [
 ('gold_bar', 202, 154, False), ('ruby', 218, 160, False), ('grandpa_sack', 186, 160, False),
 ('death_bell', 223, 168, False), ('pocketwatch', 207, 170, False), ('sapphire', 196, 176, False),
 ('medallion', 214, 182, False), ('lucky_nickel', 226, 184, False), ('chakram', 196, 186, False),
 ('grimoire', 172, 193, False), ('emerald', 188, 197, False), ('jar_o_grease', 200, 194, False),
 ('healing_potion', 160, 198, False), ('shuriken', 148, 202, False), ('amethyst', 182, 206, False),
 ('crossbow', 132, 199, False), ('blood_chalice', 120, 206, False), ('phoenix_egg', 142, 210, False),
 ('helmet', 104, 205, False), ('prism', 160, 209, False), ('iron_chain', 170, 214, True),
 ('lantern', 92, 210, False), ('bag_of_marbles', 114, 215, False), ('cursed_scroll', 128, 218, False),
 ('sledgehammer', 76, 220, False), ('grandpa_hat', 98, 222, False), ('mirror_shard', 68, 232, False),
 ('ale_flagon', 52, 238, False), ('boot', 72, 240, False), ('throwing_knife', 40, 248, False),
 ('anvil', 58, 250, False), ('ruby', 78, 250, False), ('poison_flask', 30, 252, False),
 ('measuring_tape', 66, 254, True),
]
# gem/coin sparkles drawn after items
for name, x, y, fl in RIVER_ITEMS:
    stamp(name, x, y, flip=fl)

# ---------------------------------------------------------------- bank peekers (faces toward the loot)
stamp('grandpa_portrait', 84, 196)                 # Grandpa's portrait, propped on the bank (never alive)
stamp('mimic', 98, 192)                            # mimic chest gulping coins on the upper bank (x<120 so outside hub)
stamp('zombie_hand', 148, 214)                     # hand clawing out of the coins
stamp('slime', 136, 221)                           # slime oozing at the lower bank
stamp('poison_frog', 178, 216)                     # frog on the lower bank, eyes on the loot
stamp('mouse', 114, 224, flip=True)                # mouse dragging off a coin
put(112, 228, C['gold']); put(113, 228, C['gold2'])
stamp('magicat', 76, 180, flip=False)              # magicat peeking over the hill crest at the river

# ---------------------------------------------------------------- monster crowd lower-right + thrown Boot
# ogre (facing left, roaring at the incoming boot), club on his shoulder
OG = ((92, 62, 46), (138, 98, 68), (180, 136, 96))
club = mask_of(lambda d: d.polygon([(404, 204), (410, 168), (414, 156), (420, 152), (420, 206)], fill=1))
blob(club, C['oak'], (90, 58, 34), C['edge'], outline=INK)
for x, y in [(413, 160), (416, 166), (412, 172)]: put(x, y, (201, 206, 214))  # nails in the club
ogre_body = mask_of(lambda d: d.polygon([(370, 212), (382, 200), (404, 196), (420, 200), (420, 260), (360, 260)], fill=1))
blob(ogre_body, *OG, outline=INK, hl=2)
loin = mask_of(lambda d: d.polygon([(362, 242), (420, 238), (420, 254), (364, 256)], fill=1))
blob(loin, C['oak'], (90, 58, 34), C['edge'], outline=INK, sd=1)
for x in range(366, 420, 6): put(x, 248, C['oak'])
ogre_arm = mask_of(lambda d: d.polygon([(376, 206), (364, 216), (356, 226), (352, 236), (360, 240), (368, 228), (382, 216)], fill=1))
blob(ogre_arm, *OG, outline=INK)
fist = mask_of(lambda d: d.ellipse([348, 232, 360, 243], fill=1)); blob(fist, *OG, outline=INK)
ogre_head = mask_of(lambda d: d.polygon([(370, 178), (380, 170), (394, 170), (402, 178), (402, 194), (394, 202), (378, 202), (368, 194)], fill=1))
blob(ogre_head, *OG, outline=INK, hl=2)
ear = mask_of(lambda d: d.polygon([(400, 180), (408, 176), (404, 188)], fill=1)); blob(ear, *OG, outline=INK, sd=1)
for x in range(370, 388): put(x, 179, OG[0])        # heavy brow
put(370, 180, INK); put(371, 180, OG[0])
for x, y in [(373, 182), (374, 182), (380, 182), (381, 182)]: put(x, y, PAL['w'])
put(373, 182, INK); put(380, 182, INK)              # pupils looking left
put(367, 186, OG[1]); put(366, 187, OG[1]); put(366, 188, INK); put(368, 188, OG[0])   # big nose
mouthO = mask_of(lambda d: d.polygon([(370, 192), (386, 191), (384, 199), (373, 199)], fill=1))
img[mouthO] = (70, 20, 28)
for x in range(371, 386): put(x, 191, INK)
put(372, 193, PAL['w']); put(373, 194, PAL['w']); put(383, 193, PAL['w']); put(383, 194, PAL['w'])   # tusks
put(377, 197, PAL['R']); put(378, 197, PAL['R'])
# impact star on the ogre's brow where the Boot lands
for dx, dy in [(0, 0), (0, -1), (0, 1), (1, 0), (2, -2), (2, 2), (0, -3), (0, 3), (3, 0)]:
    put(366 + dx, 180 + dy, C['cream'] if abs(dx) + abs(dy) < 2 else C['gold'])
# the thrown Boot (streaking right, under the dragon's forearm, into the ogre's face)
for k, (x0, y0, x1, y1, c) in enumerate([(300, 196, 354, 185, C['gold']), (306, 201, 352, 190, C['cream']), (312, 191, 352, 181, C['gold2'])]):
    n = x1 - x0
    for t in range(n):
        if (t // 3) % 2 == 0 or t > n * 0.6:
            put(x0 + t, round(y0 + (y1 - y0) * t / n), c if t > n * 0.35 else C['torch'])
stamp('boot', 355, 180, flip=True)
# skeleton: shield-less, reaching left toward the loot
stamp('skeleton', 318, 204)
# dire wolf: low, snarling left toward the loot, bottom right (clear of the Click rect)
WF = ((40, 44, 58), (72, 78, 96), (116, 124, 140))
tail = mask_of(lambda d: d.polygon([(380, 244), (392, 236), (396, 240), (384, 250)], fill=1)); blob(tail, *WF, outline=INK, sd=1)
wolf = mask_of(lambda d: d.polygon([(348, 242), (356, 236), (370, 236), (382, 240), (384, 252), (378, 258), (350, 258)], fill=1))
blob(wolf, *WF, outline=INK, hl=2)
mane = wolf & mask_of(lambda d: d.polygon([(348, 236), (360, 234), (362, 258), (348, 258)], fill=1))
img[mane & ~sh(wolf, -1, -1)] = WF[0]
for y in range(238, 256, 3): put(358, y, WF[2]); put(359, y + 1, WF[0])
whead = mask_of(lambda d: d.polygon([(336, 244), (342, 238), (350, 236), (356, 240), (356, 248), (348, 252), (338, 250)], fill=1))
blob(whead, *WF, outline=INK, hl=1, sd=1)
for pts in [[(346, 238), (348, 229), (352, 237)], [(351, 238), (355, 230), (356, 240)]]:
    em = mask_of(lambda d: d.polygon(pts, fill=1)); blob(em, *WF, outline=INK, sd=1)
put(344, 241, C['gold']); put(345, 241, C['gold']); put(344, 242, INK)    # eye on the loot
for x in range(336, 347): put(x, 247, INK)
put(337, 248, PAL['w']); put(340, 248, PAL['w']); put(343, 248, PAL['w']); put(338, 246, PAL['w']); put(342, 246, PAL['w'])
put(335, 244, INK)  # nose
# spider queen dangling from the mountain on her thread, eyeing the river (x>300, below the upper 45%)
for y in range(122, 140): put(318, y, (138, 150, 168) if y % 2 else (74, 80, 100))
sq = mask_of(lambda d: d.ellipse([311, 140, 326, 154], fill=1))
for lx, ly, ex, ey in [(312, 144, 304, 138), (312, 148, 303, 150), (313, 151, 306, 158), (325, 144, 333, 138), (325, 148, 334, 150), (324, 151, 331, 158)]:
    n = max(abs(ex - lx), abs(ey - ly))
    for t in range(n + 1): put(round(lx + (ex - lx) * t / n), round(ly + (ey - ly) * t / n), INK)
blob(sq, (40, 26, 44), (70, 46, 76), (110, 76, 116), outline=INK)
put(314, 146, PAL['R']); put(316, 146, PAL['R']); put(315, 148, PAL['R'])  # eyes looking down-left
put(318, 151, PAL['R']); put(319, 152, PAL['r'])  # hourglass
for x, y in [(314, 139), (316, 138), (318, 139), (320, 138), (322, 139)]: put(x, y, C['gold'])  # crown points
for x in range(314, 323): put(x, 140, C['gold2'])

# ---------------------------------------------------------------- dragon (upper-right) + claw into the river (from C)
DR = dict(D=(70, 20, 28), C=(130, 36, 40), R=(190, 58, 52), L=(226, 98, 70))
# arm: shoulder off the right edge under the neck, elbow bend, forearm down-left into the river bend
upper = mask_of(lambda d: d.polygon([(420, 116), (420, 146), (396, 152), (360, 160), (346, 150), (370, 136), (400, 122)], fill=1))
fore = mask_of(lambda d: d.polygon([(350, 144), (364, 160), (336, 176), (300, 190), (270, 203), (262, 194), (292, 180), (318, 162)], fill=1))
wrist = mask_of(lambda d: d.polygon([(272, 196), (276, 192), (280, 200), (276, 204)], fill=1))
blob(upper, DR['D'], DR['C'], DR['R'], shine=DR['L'], outline=INK, hl=2)
blob(fore, DR['D'], DR['C'], DR['R'], shine=DR['L'], outline=INK, hl=2)
for y, x in np.argwhere(wrist & fore): put(x, y, DR['D']) if (x + y) % 2 else None
for M in (upper, fore):  # belly scales on the underside
    lo = M & ~sh(M, 0, -3) & sh(M, 0, 3)
    for y, x in np.argwhere(lo):
        if x % 4 < 2: put(x, y, (196, 150, 52))
for x, y in [(352, 150), (356, 147)]:  # elbow spur
    put(x, y, (220, 208, 180))
put(351, 144, (246, 238, 214)); put(350, 143, INK)
palm = mask_of(lambda d: d.ellipse([248, 190, 268, 206], fill=1))
blob(palm, DR['D'], DR['C'], DR['R'], outline=INK)
for tx, ty, ex, ey in [(251, 193, 240, 188), (249, 198, 237, 199), (250, 203, 240, 210), (256, 205, 251, 216), (263, 205, 262, 215)]:
    tal = mask_of(lambda d: d.polygon([(tx, ty - 2), (tx + 1, ty + 2), (ex, ey)], fill=1))
    blob(tal, (150, 140, 120), (220, 208, 180), (246, 238, 214), outline=INK, sd=1)
# a gem snatched in the claw
put(244, 196, PAL['R']); put(245, 196, PAL['P']); put(244, 197, PAL['r'])
# dragon head: facing left/down toward the loot and Sprout, neck off the right edge
neck = mask_of(lambda d: d.polygon([(420, 30), (420, 120), (400, 112), (392, 84), (396, 56)], fill=1))
blob(neck, DR['D'], DR['C'], DR['R'], outline=INK, hl=2)
belly = mask_of(lambda d: d.polygon([(402, 112), (396, 86), (400, 66), (408, 64), (406, 90), (414, 118)], fill=1)) & neck
img[belly] = (196, 150, 52)
for y in range(70, 118, 5):
    for x in range(396, 416):
        if belly[y, x]: put(x, y, (140, 100, 40))
head = mask_of(lambda d: d.polygon([(358, 58), (364, 48), (380, 40), (398, 34), (412, 38), (418, 50), (416, 66), (404, 76), (386, 78), (370, 76), (360, 70)], fill=1))
blob(head, DR['D'], DR['C'], DR['R'], shine=DR['L'], outline=INK, hl=2)
jaw = mask_of(lambda d: d.polygon([(362, 72), (372, 78), (392, 82), (404, 78), (398, 88), (380, 88), (366, 82)], fill=1))
blob(jaw, DR['D'], DR['C'], DR['R'], outline=INK)
# teeth along the mouth line
for x in range(364, 398, 4): put(x, 77, PAL['w']); put(x + 1, 78, (220, 208, 180))
for x in range(368, 396, 5): put(x, 80, PAL['w'])
# horns sweeping back (bone)
for pts in [[(396, 36), (404, 22), (414, 12), (418, 14), (410, 26), (404, 38)], [(408, 40), (416, 30), (420, 26), (420, 40), (414, 46)]]:
    hm = mask_of(lambda d: d.polygon(pts, fill=1))
    blob(hm, (150, 140, 120), (220, 208, 180), (246, 238, 214), outline=INK, sd=1)
# brow ridge + glowing eye looking down-left
for x in range(376, 392): put(x, 51 + (x - 376) // 6, DR['D'])
eye = [(380, 54), (381, 54), (382, 54), (383, 54), (380, 55), (381, 55), (382, 55), (383, 55), (384, 55)]
for x, y in eye: put(x, y, C['gold'])
put(381, 55, INK); put(381, 54, INK); put(384, 54, C['cream'])
# nostril + ember wisps (warm threat, small)
put(364, 60, INK); put(365, 60, INK)
for x, y, c in [(358, 54, C['torch']), (356, 51, C['rivet']), (359, 49, C['edge'])]: put(x, y, c)
# back spines
for x, y in [(398, 32), (404, 30), (420, 52), (419, 70), (418, 88)]:
    sp = mask_of(lambda d: d.polygon([(x - 3, y + 2), (x + 3, y + 2), (x, y - 4)], fill=1))
    img[sp & ~head & ~neck] = DR['D']
# minion: a goblin grunt under the dragon's chin, pointing his spear at the loot
stamp('goblin_minion', 368, 92)
# hornet swarm buzzing top-right
for hx, hy in [(372, 6), (384, 12), (396, 4), (406, 14), (362, 16)]:
    stamp('hornet', hx, hy)

# ---------------------------------------------------------------- Sprout's ledge + Sprout (upper-left, facing the mountain)
# a cool rock shoulder of the mountain's left flank, rising to the right toward the peak
RK = ((40, 44, 58), (62, 66, 84), (88, 94, 114))
ledge = mask_of(lambda d: d.polygon([(0, 124), (10, 123), (16, 121), (28, 122), (40, 121), (52, 121), (60, 119), (68, 117), (74, 114), (82, 111), (88, 112), (94, 108), (98, 112), (92, 120), (84, 126), (78, 132), (68, 136), (56, 137), (48, 141), (36, 140), (24, 142), (12, 141), (0, 143)], fill=1))
blob(ledge, *RK, outline=INK, hl=2, sd=2)
for x, y in [(12, 129), (34, 128), (58, 126), (80, 120), (22, 135), (46, 133), (66, 130)]: put(x, y, RK[0]); put(x + 1, y + 1, RK[0])
for x in range(4, 70, 2): put(x, 138 + (x % 3 == 0), RK[0]) if ledge[138, x] else None
for x in range(0, 104, 9):  # a few dark tufts on the shoulder
    col = np.nonzero(ledge[:, x])[0]
    if len(col): put(x, col[0] - 1, C['grassL'])
stamp('sprout', 26, 88)

final = Image.fromarray(img, 'RGB')
final.save(OUT + 'title_still_native.png', optimize=True)
final.resize((W * 4, H * 4), Image.NEAREST).save(OUT + 'title_still.png', optimize=True)
print('colours', len(final.getcolors(4096)))
