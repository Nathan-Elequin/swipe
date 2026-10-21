"""Higher-fidelity redraw base for in-game sprites: native -> EPX 2x/3x -> 1px ink outline rebuilt
-> fresh upper-left bevel ramp. Hand detail is painted on top per sprite (see sprites3.py)."""
import numpy as np
from PIL import Image
REPO = '<TITLE_TEASER>/repo_ref/assets/'
INK = np.array([16, 14, 12, 255], np.uint8)

def load_native(rel, s=4):
    im = Image.open(REPO + rel).convert('RGBA')
    a = np.array(im)[::s, ::s].copy()
    a[a[:, :, 3] < 128] = 0; a[a[:, :, 3] >= 128, 3] = 255
    return a

def _eq(a, b): return (a == b).all(-1)

def scale2x(a):
    h, w = a.shape[:2]
    p = np.pad(a, ((1, 1), (1, 1), (0, 0)), mode='edge')
    E = p[1:-1, 1:-1]; B = p[:-2, 1:-1]; D = p[1:-1, :-2]; F = p[1:-1, 2:]; Hh = p[2:, 1:-1]
    o = np.zeros((h * 2, w * 2, 4), np.uint8)
    c = ~_eq(B, Hh) & ~_eq(D, F)
    e0 = np.where((c & _eq(D, B))[..., None], D, E)
    e1 = np.where((c & _eq(B, F))[..., None], F, E)
    e2 = np.where((c & _eq(D, Hh))[..., None], D, E)
    e3 = np.where((c & _eq(Hh, F))[..., None], F, E)
    o[0::2, 0::2] = e0; o[0::2, 1::2] = e1; o[1::2, 0::2] = e2; o[1::2, 1::2] = e3
    return o

def scale3x(a):
    h, w = a.shape[:2]
    p = np.pad(a, ((1, 1), (1, 1), (0, 0)), mode='edge')
    A = p[:-2, :-2]; B = p[:-2, 1:-1]; C = p[:-2, 2:]
    D = p[1:-1, :-2]; E = p[1:-1, 1:-1]; F = p[1:-1, 2:]
    G = p[2:, :-2]; Hh = p[2:, 1:-1]; I = p[2:, 2:]
    c = ~_eq(B, Hh) & ~_eq(D, F)
    def W(cond, X): return np.where((c & cond)[..., None], X, E)
    o = np.zeros((h * 3, w * 3, 4), np.uint8)
    o[0::3, 0::3] = W(_eq(D, B), D)
    o[0::3, 1::3] = W((_eq(D, B) & ~_eq(E, C)) | (_eq(B, F) & ~_eq(E, A)), B)
    o[0::3, 2::3] = W(_eq(B, F), F)
    o[1::3, 0::3] = W((_eq(D, B) & ~_eq(E, G)) | (_eq(D, Hh) & ~_eq(E, A)), D)
    o[1::3, 1::3] = E
    o[1::3, 2::3] = W((_eq(B, F) & ~_eq(E, I)) | (_eq(Hh, F) & ~_eq(E, C)), F)
    o[2::3, 0::3] = W(_eq(D, Hh), D)
    o[2::3, 1::3] = W((_eq(D, Hh) & ~_eq(E, I)) | (_eq(Hh, F) & ~_eq(E, G)), Hh)
    o[2::3, 2::3] = W(_eq(Hh, F), F)
    return o

def is_ink(a, tol=40):
    d = np.abs(a[:, :, :3].astype(int) - INK[:3].astype(int)).sum(-1)
    return (d < tol) & (a[:, :, 3] > 0)

def shift(M, dx, dy):
    """value of M at (x-dx, y-dy)"""
    H, W = M.shape[:2]; o = np.zeros_like(M)
    o[max(dy, 0):H + min(dy, 0), max(dx, 0):W + min(dx, 0)] = M[max(-dy, 0):H + min(-dy, 0), max(-dx, 0):W + min(-dx, 0)]
    return o

def n4(M): return shift(M, 1, 0) | shift(M, -1, 0) | shift(M, 0, 1) | shift(M, 0, -1)

def rebuild_outline(a, passes=1):
    """outer silhouette: ink pixels on the edge stay as the 1px outline; the inner layer of the
    doubled outline is refilled with the nearest body colour."""
    a = np.pad(a, ((1, 1), (1, 1), (0, 0)))
    mask = a[:, :, 3] > 0
    edge = mask & n4(~mask)
    ink = is_ink(a)
    body = mask & ~ink
    for _ in range(passes):
        inner = ink & ~edge & n4(edge) & n4(body)
        # refill from a body neighbour (prefer up/left/right/down order)
        new = a.copy()
        for dx, dy in ((0, -1), (-1, 0), (1, 0), (0, 1)):
            src = shift(a, dx, dy); sb = shift(body, dx, dy)
            take = inner & sb
            new[take] = src[take]; inner &= ~take
        a = new; ink = is_ink(a); body = mask & ~ink; edge = mask & n4(~mask)
    # make sure the silhouette edge is solid ink
    a[edge] = INK
    return a

def tone(c, f):
    c = np.array(c[:3], float)
    if f > 1: c = c + (255 - c) * (f - 1) * 0.9 + np.array([6, 4, 0]) * (f - 1) * 4
    else: c = c * f + np.array([0, 0, 6]) * (1 - f)
    return np.clip(c, 0, 255).astype(np.uint8)

def bevel(a, lit=1.22, shade=0.78, warm_rim=None):
    """1px light on body pixels whose upper/left neighbour is ink; 1px dark on lower/right.
    warm_rim: colour for a back-light on the lower-right edge (hoard glow)."""
    mask = a[:, :, 3] > 0; ink = is_ink(a); body = mask & ~ink
    up = shift(ink | ~mask, 0, 1); lf = shift(ink | ~mask, 1, 0)
    dn = shift(ink | ~mask, 0, -1); rt = shift(ink | ~mask, -1, 0)
    o = a.copy()
    L = body & (up | lf) & ~(dn | rt)
    D = body & (dn | rt) & ~(up | lf)
    for y, x in np.argwhere(L): o[y, x, :3] = tone(a[y, x], lit)
    for y, x in np.argwhere(D): o[y, x, :3] = tone(a[y, x], shade)
    if warm_rim is not None:
        sil = mask & n4(~mask)          # outline
        outer_dn = shift(~mask, 0, -1) | shift(~mask, -1, 0)
        R = body & (dn | rt) & shift(sil, 0, -1) | body & shift(sil & outer_dn, -1, 0)
        R &= body & ~L
        for y, x in np.argwhere(R):
            if (x + y) % 2 == 0 or True: o[y, x, :3] = np.array(warm_rim, np.uint8)
    return o

def flip(a): return a[:, ::-1].copy()

def hifi(rel, k=2, flip_h=False, lit=1.22, shade=0.8, rim=None):
    n = load_native(rel)
    if flip_h: n = flip(n)
    up = scale2x(n) if k == 2 else scale3x(n) if k == 3 else scale2x(scale2x(n))
    a = rebuild_outline(up)
    return bevel(a, lit, shade, rim)

def crop(a):
    m = a[:, :, 3] > 0
    ys, xs = np.nonzero(m)
    return a[ys.min():ys.max() + 1, xs.min():xs.max() + 1]

def save(a, path, s=1):
    im = Image.fromarray(a, 'RGBA')
    if s > 1: im = im.resize((im.width * s, im.height * s), Image.NEAREST)
    im.save(path)

def thin_inner(a):
    """2px-thick interior ink lines (from the 2x) -> 1px; isolated 2x2 dots (pupils) stay."""
    mask = a[:, :, 3] > 0; ink = is_ink(a); edge = mask & n4(~mask)
    H, W = mask.shape; o = a.copy()
    def run_h(y, x):
        n = 1; i = x - 1
        while i >= 0 and ink[y, i]: n += 1; i -= 1
        i = x + 1
        while i < W and ink[y, i]: n += 1; i += 1
        return n
    def run_v(y, x):
        n = 1; j = y - 1
        while j >= 0 and ink[j, x]: n += 1; j -= 1
        j = y + 1
        while j < H and ink[j, x]: n += 1; j += 1
        return n
    for y in range(2, H - 1):
        for x in range(2, W - 1):
            if not ink[y, x] or edge[y, x]: continue
            b = mask[y + 1, x] and not ink[y + 1, x]
            if ink[y - 1, x] and not ink[y - 2, x] and b and run_h(y, x) >= 3 and run_h(y - 1, x) >= 3:
                o[y, x] = a[y + 1, x]; continue
            r = mask[y, x + 1] and not ink[y, x + 1]
            if ink[y, x - 1] and not ink[y, x - 2] and r and run_v(y, x) >= 3 and run_v(y, x - 1) >= 3:
                o[y, x] = a[y, x + 1]
    return o

def hifi2(rel, k=2, flip_h=False, lit=1.22, shade=0.8, rim=None, thin=True):
    n = load_native(rel)
    if flip_h: n = flip(n)
    up = scale2x(n) if k == 2 else scale3x(n)
    a = rebuild_outline(up)
    if thin: a = thin_inner(a)
    return bevel(a, lit, shade, rim)

class P:
    """pixel patcher on an RGBA array; coords in the sprite's own grid"""
    def __init__(self, a): self.a = a
    def px(self, x, y, c):
        if 0 <= y < self.a.shape[0] and 0 <= x < self.a.shape[1]:
            c = hexc(c); self.a[y, x] = (*c, 255)
    def pts(self, lst, c):
        for x, y in lst: self.px(x, y, c)
    def row(self, x0, x1, y, c):
        for x in range(x0, x1 + 1): self.px(x, y, c)
    def col(self, x, y0, y1, c):
        for y in range(y0, y1 + 1): self.px(x, y, c)
    def rect(self, x0, y0, x1, y1, c):
        for y in range(y0, y1 + 1): self.row(x0, x1, y, c)
    def clear(self, x, y): self.a[y, x] = 0
    def get(self, x, y): return tuple(self.a[y, x])
    def grid(self, x, y, rows, pal):
        for j, r in enumerate(rows):
            for i, ch in enumerate(r):
                if ch == '.' or ch == ' ': continue
                if ch == '_': self.a[y + j, x + i] = 0; continue
                self.px(x + i, y + j, pal[ch])

def hexc(c):
    if isinstance(c, str):
        c = c.lstrip('#'); return tuple(int(c[i:i + 2], 16) for i in (0, 2, 4))
    return tuple(c[:3])

def reoutline(a):
    """after patches that grow the shape: ensure a 1px ink ring around alpha"""
    a = np.pad(a, ((1, 1), (1, 1), (0, 0)))
    mask = a[:, :, 3] > 0
    ring = n4(mask) & ~mask
    a[ring] = INK
    return crop(a)

def rim_light(a, col=(240, 154, 52), side='right', amt=0.45, lowfrac=0.3):
    """warm back-light: body pixels just inside the silhouette on one side get tinted toward col"""
    mask = a[:, :, 3] > 0; ink = is_ink(a); body = mask & ~ink
    out = ~mask
    if side == 'right': edge = body & shift(out, -2, 0) & shift(ink, -1, 0)
    elif side == 'bottom': edge = body & shift(out, 0, -2) & shift(ink, 0, -1)
    else: edge = body & (shift(out, -2, 0) & shift(ink, -1, 0) | shift(out, 0, -2) & shift(ink, 0, -1))
    o = a.copy(); c = np.array(col, float)
    ys = np.nonzero(mask.any(1))[0]; ymin = ys.min() + int((ys.max() - ys.min()) * lowfrac)
    edge[:ymin] = False
    for y, x in np.argwhere(edge):
        o[y, x, :3] = np.clip(a[y, x, :3] * (1 - amt) + c * amt + 10, 0, 255).astype(np.uint8)
    return o

def blobs(a, col, tol=30):
    """bounding boxes (x0,y0,x1,y1) of 8-connected regions near colour col"""
    c = np.array(hexc(col)); d = np.abs(a[:, :, :3].astype(int) - c).sum(-1)
    M = (d <= tol) & (a[:, :, 3] > 0)
    seen = np.zeros_like(M); out = []
    for y, x in np.argwhere(M):
        if seen[y, x]: continue
        st = [(y, x)]; seen[y, x] = True; pts = []
        while st:
            j, i = st.pop(); pts.append((i, j))
            for dj in (-1, 0, 1):
                for di in (-1, 0, 1):
                    jj, ii = j + dj, i + di
                    if 0 <= jj < M.shape[0] and 0 <= ii < M.shape[1] and M[jj, ii] and not seen[jj, ii]:
                        seen[jj, ii] = True; st.append((jj, ii))
        xs = [p[0] for p in pts]; ys = [p[1] for p in pts]
        out.append((min(xs), min(ys), max(xs), max(ys), len(pts)))
    return sorted(out)

def palette(a, top=40):
    from collections import Counter
    m = a[:, :, 3] > 0
    cnt = Counter(tuple(int(v) for v in p[:3]) for p in a[m])
    return ['#%02x%02x%02x:%d' % (k + (v,)) for k, v in cnt.most_common(top)]
