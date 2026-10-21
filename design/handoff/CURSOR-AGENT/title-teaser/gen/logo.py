"""Spinheritance logo: hand-built pixel lettering (own glyphs from rect/rounded-rect primitives, no fonts).
Native <= 210 wide, 40 tall (fits SCREEN logo rect 250x40 native). Transparent. Shipped 4x nearest."""
import numpy as np
from PIL import Image, ImageDraw
OUT = '<TITLE_TEASER>/out/'
H = 40
XT, BASE, ASC, DESC, CAPT = 12, 28, 4, 34, 2      # x-height rows 12..27
INK = (16, 14, 12, 255); CREAM = (255, 243, 214, 255); GOLD = (255, 216, 74, 255)
TORCH = (240, 154, 52, 255); RIVET = (184, 115, 58, 255); EXT = (122, 78, 43, 255); EXT2 = (90, 58, 34, 255)
SHADOW = (26, 18, 14, 255); RED = (213, 68, 59, 255); REDD = (140, 40, 36, 255)

def canvas(w): return Image.new('1', (w, H), 0)
def M(im): return np.array(im, bool)
def rr(d, box, r, v=1): d.rounded_rectangle(box, radius=r, fill=v)

def g_n(tall=False):
    im = canvas(13); d = ImageDraw.Draw(im)
    rr(d, (0, XT, 12, BASE - 1), 6); rr(d, (4, XT + 3, 8, BASE + 4), 2, 0)
    d.rectangle((0, XT + 2, 3, BASE - 1), 1)
    if tall: d.rectangle((0, ASC, 3, BASE - 1), 1); d.rectangle((0, ASC, 4, ASC + 1), 1)
    d.rectangle((9, BASE - 2, 12, BASE - 1), 1)
    return M(im)
def g_p(bowl=True):
    im = canvas(13); d = ImageDraw.Draw(im)
    if bowl:
        rr(d, (0, XT, 12, BASE - 1), 6); rr(d, (4, XT + 3, 8, BASE - 4), 2, 0)
    d.rectangle((0, XT, 3, DESC), 1); d.rectangle((0, DESC - 1, 5, DESC), 1)   # foot serif
    d.rectangle((0, XT, 1, XT), 1)
    return M(im)
def g_i(dot=True):
    im = canvas(5); d = ImageDraw.Draw(im)
    d.rectangle((0, XT, 3, BASE - 1), 1); d.rectangle((0, XT, 4, XT + 1), 1)
    if dot: rr(d, (0, XT - 6, 3, XT - 3), 1)
    return M(im)
def g_e():
    im = canvas(13); d = ImageDraw.Draw(im)
    rr(d, (0, XT, 12, BASE - 1), 6); rr(d, (4, XT + 3, 8, XT + 6), 1, 0)
    d.rectangle((4, XT + 10, 12, XT + 12), 0)
    d.rectangle((10, BASE - 5, 12, BASE - 4), 1)                     # terminal flick
    return M(im)
def g_r():
    im = canvas(10); d = ImageDraw.Draw(im)
    d.rectangle((0, XT, 3, BASE - 1), 1)
    rr(d, (0, XT, 9, XT + 8), 4); rr(d, (4, XT + 3, 10, XT + 9), 1, 0)
    d.rectangle((7, XT + 3, 9, XT + 4), 1)
    return M(im)
def g_t():
    im = canvas(10); d = ImageDraw.Draw(im)
    d.rectangle((2, ASC + 2, 5, BASE - 3), 1)
    d.rectangle((0, XT, 9, XT + 2), 1)
    rr(d, (2, BASE - 7, 9, BASE - 1), 3); rr(d, (6, BASE - 7, 10, BASE - 4), 1, 0)
    return M(im)
def g_a():
    im = canvas(13); d = ImageDraw.Draw(im)
    rr(d, (0, XT + 2, 12, BASE - 1), 6); rr(d, (4, XT + 5, 8, BASE - 4), 2, 0)
    d.rectangle((9, XT, 12, BASE - 1), 1); rr(d, (2, XT, 12, XT + 3), 2)
    d.rectangle((4, XT + 4, 8, XT + 4), 0)
    return M(im)
def g_c():
    im = canvas(12); d = ImageDraw.Draw(im)
    rr(d, (0, XT, 11, BASE - 1), 6); rr(d, (4, XT + 3, 11, BASE - 4), 2, 0)
    d.rectangle((7, XT + 6, 11, BASE - 7), 0)
    d.rectangle((9, XT + 3, 11, XT + 5), 1); d.rectangle((9, BASE - 6, 11, BASE - 4), 1)
    return M(im)
def g_S(w=20):
    im = canvas(w); d = ImageDraw.Draw(im)
    rr(d, (0, CAPT, w - 2, CAPT + 15), 7); rr(d, (4, CAPT + 4, w - 6, CAPT + 11), 3, 0)
    d.rectangle((w - 6, CAPT + 7, w - 2, CAPT + 15), 0)                  # open upper bowl to the right
    rr(d, (1, CAPT + 12, w - 1, BASE - 1), 7); rr(d, (5, CAPT + 16, w - 5, BASE - 5), 3, 0)
    d.rectangle((1, CAPT + 12, 5, CAPT + 19), 0)                          # open lower bowl to the left
    d.rectangle((4, CAPT + 12, w - 5, CAPT + 15), 1)                      # spine
    d.rectangle((w - 5, CAPT + 4, w - 2, CAPT + 8), 1)                    # top terminal
    d.rectangle((1, BASE - 9, 4, BASE - 5), 1)                            # bottom terminal
    return M(im)

def wheel_layer(r, roulette=True):
    """returns RGBA array (2r+5 square) of a spoked wheel with ink outline, light upper-left"""
    n = 2 * r + 5; c = n // 2
    a = np.zeros((n, n, 4), np.uint8)
    for y in range(n):
        for x in range(n):
            dx, dy = x - c, y - c; dd = (dx * dx + dy * dy) ** .5
            ang = np.degrees(np.arctan2(dy, dx)) % 360
            if dd <= r + 0.5:
                if dd > r - 2.0:   # rim
                    if roulette and r >= 6:
                        seg = int(ang // 30) % 2
                        col = (RED if seg else GOLD) if dd > r - 1.0 else (REDD if seg else TORCH)
                        if not seg and dx + dy < -2 and dd > r - 1: col = CREAM
                    else:
                        col = GOLD if dd > r - 1.0 else TORCH
                        if dx + dy < -2 and dd > r - 1: col = CREAM
                    a[y, x] = col
                else:
                    a[y, x] = (59, 38, 24, 255)   # dark wheel bed
                    k = 8 if r >= 6 else 4
                    near = min(abs(((ang + 360 / k / 2) % (360 / k)) - 360 / k / 2), 99)
                    if near * np.pi / 180 * max(dd, 1) < 0.75: a[y, x] = GOLD if dx + dy <= 0 else TORCH
                if dd <= (1.5 if r >= 7 else 1.0): a[y, x] = RED if r >= 7 else CREAM
                if r >= 7 and dd <= 0.6: a[y, x] = CREAM
            elif dd <= r + 1.5: a[y, x] = INK
    return a

def render(glyphs, gap=2, bounce=(0, -1, 0, 1), extras=()):
    """glyphs: list of (mask or None, width). extras: list of (fn(img_rgba, offsets)) drawn on top."""
    W = sum(m.shape[1] for m in glyphs) + gap * (len(glyphs) - 1) + 6
    face = np.zeros((H, W), bool); offs = []
    x = 1
    for i, m in enumerate(glyphs):
        dy = bounce[i % len(bounce)]
        h, w = m.shape
        src = m[max(0, -dy):H - max(0, dy)]
        face[max(0, dy):max(0, dy) + src.shape[0], x:x + w] |= src
        offs.append((x, dy, w)); x += w + gap
    return face, offs, W

def shade(face, W):
    out = np.zeros((H, W, 4), np.uint8)
    def sh(Mk, dx, dy):
        o = np.zeros_like(Mk); o[max(dy, 0):H + min(dy, 0), max(dx, 0):W + min(dx, 0)] = Mk[max(-dy, 0):H + min(-dy, 0), max(-dx, 0):W + min(-dx, 0)]; return o
    ext = (sh(face, 0, 1) | sh(face, 0, 2)) & ~face
    body = face | ext
    outl = np.zeros_like(body)
    for dx in (-1, 0, 1):
        for dy in (-1, 0, 1): outl |= sh(body, dx, dy)
    outl &= ~body
    drop = sh(body | outl, 1, 2) & ~(body | outl)
    out[drop] = SHADOW
    out[outl] = INK
    out[ext] = EXT; out[ext & ~sh(ext, 0, 1)] = EXT2
    # face ramp: per-row bands + edge light/dark (light from upper-left)
    for y in range(H):
        for x in range(W):
            if not face[y, x]: continue
            col = GOLD if y < BASE - 6 else TORCH
            if y >= BASE - 2: col = TORCH
            out[y, x] = col
    hi = face & ~(sh(face, 1, 0) & sh(face, 0, 1) & sh(face, 1, 1))
    lo = face & ~(sh(face, -1, 0) & sh(face, 0, -1) & sh(face, -1, -1))
    out[lo] = RIVET
    out[hi & ~lo] = CREAM
    return out

def paste(out, layer, x, y):
    h, w = layer.shape[:2]
    for j in range(h):
        for i in range(w):
            if layer[j, i, 3] and 0 <= y + j < out.shape[0] and 0 <= x + i < out.shape[1]: out[y + j, x + i] = layer[j, i]

def spin_ticks(out, cx, cy, r):
    for dx, dy, c in [(-r - 2, -2, CREAM), (-r - 2, -1, GOLD), (-r - 1, -r + 1, GOLD), (r + 2, 2, GOLD), (r + 2, 1, TORCH), (r + 1, r - 1, TORCH)]:
        x, y = cx + dx, cy + dy
        if 0 <= y < out.shape[0] and 0 <= x < out.shape[1] and out[y, x, 3] == 0: out[y, x] = c

COIN = [".kkk.", "kwYYk", "kYYOk", "kYOOk", ".kkk."]
def coin(out, x, y):
    cm = {'k': INK, 'w': CREAM, 'Y': GOLD, 'O': TORCH}
    for j, row in enumerate(COIN):
        for i, ch in enumerate(row):
            if ch != '.' and 0 <= y + j < out.shape[0] and 0 <= x + i < out.shape[1]: out[y + j, x + i] = cm[ch]

def build(variant):
    if variant == 'A':   # dot of the first i is a spinning roulette wheel
        gl = [g_S(), g_p(), g_i(dot=False), g_n(), g_n(True), g_e(), g_r(), g_i(), g_t(), g_a(), g_n(), g_c(), g_e()]
    elif variant == 'B': # the S wraps a big wheel
        gl = [np.zeros((H, 26), bool), g_p(), g_i(), g_n(), g_n(True), g_e(), g_r(), g_i(), g_t(), g_a(), g_n(), g_c(), g_e()]
    else:                # C: the p's bowl is a wheel, i-dot wheel too
        gl = [g_S(), g_p(bowl=False), g_i(dot=False), g_n(), g_n(True), g_e(), g_r(), g_i(), g_t(), g_a(), g_n(), g_c(), g_e()]
    face, offs, W = render(gl)
    out = shade(face, W)
    if variant == 'A':
        x, dy, w = offs[2]; r = 6; cx = x + 2; cy = XT - 7 + dy
        paste(out, wheel_layer(r, roulette=True), cx - (2 * r + 5) // 2, cy - (2 * r + 5) // 2)
        spin_ticks(out, cx, cy, r)
    if variant == 'B':
        x, dy, w = offs[0]; r = 13; cx = x + 12; cy = 16
        paste(out, wheel_layer(r, roulette=True), cx - (2 * r + 5) // 2, cy - (2 * r + 5) // 2)
        s = g_S(16); sm = np.zeros((H, W), bool); sm[:, x + 5:x + 21] = s
        sl = shade(sm, W)
        m = sl[:, :, 3] > 0; out[m] = sl[m]
        spin_ticks(out, cx, cy, r)
    if variant == 'C':
        x, dy, w = offs[1]; r = 7; cx = x + 9; cy = XT + 8 + dy
        paste(out, wheel_layer(r, roulette=True), cx - (2 * r + 5) // 2, cy - (2 * r + 5) // 2)
        x2, dy2, _ = offs[2]
        paste(out, wheel_layer(3, roulette=False), x2 + 2 - 5, XT - 5 + dy2 - 5)
    # tiny coin accents tumbling off the final e
    coin(out, W - 8, 4); coin(out, W - 14, 0)
    # trim columns
    cols = np.nonzero(out[:, :, 3].any(0))[0]; rows = np.nonzero(out[:, :, 3].any(1))[0]
    out = out[:, cols[0]:cols[-1] + 1]
    return Image.fromarray(out, 'RGBA')

if __name__ == '__main__':
    for v in 'ABC':
        im = build(v); im.save(OUT + f'_logo_{v}_native.png')
        print(v, im.size, len(im.getcolors(999)))
