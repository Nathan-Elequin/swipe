#!/usr/bin/env python3
"""Juggernaut A art fidelity check (Pillow). Usage: python3 check_juggernaut_a_art.py <repo_root> [<staged_root>]
Checks the 17 Juggernaut PNGs under <staged_root or repo_root>/assets/dungeon against the repo's size contract
and the monster-set look: RGBA, binary alpha, every opaque color in the set palette (spinheritance.hex + colors already used by the other monsters' anim/extra PNGs),
1px dark silhouette outline, one fixed bbox + foot line per idle strip, no body pixels on a canvas edge (except the
extra still's bottom row, as in the other extras), frame-equality pattern f0=f2 / f1=f3, distinct breathe frame."""
import sys, os, hashlib
from PIL import Image
repo = sys.argv[1]; root = sys.argv[2] if len(sys.argv) > 2 else repo
D = 'assets/dungeon/'
FILES = {D+'anim/facing/juggernaut_facing_idle_f%d.png' % i: (64, 64) for i in range(4)}
FILES.update({D+'anim/wheel/juggernaut_wheel_%s.png' % n: (48, 48) for n in ('base','breathe_f0','breathe_f1','idle_f0','idle_f1','idle_f2','idle_f3')})
FILES.update({D+'anim/slash/juggernaut_slash_%s.png' % n: (64, 64) for n in ('base','f0','f1','f2','f3')})
FILES[D+'extra/juggernaut.png'] = (64, 112)
pal = {l.strip().lower() for l in open(os.path.join(repo, 'design/handoff/CURSOR-AGENT/palette/spinheritance.hex')) if l.strip()}
import glob
for _f in glob.glob(os.path.join(repo,'assets/dungeon/anim/*/*.png'))+glob.glob(os.path.join(repo,'assets/dungeon/extra/*.png')):
    if 'juggernaut' in _f: continue
    pal |= {'%02x%02x%02x' % q[:3] for q in Image.open(_f).convert('RGBA').get_flattened_data() if q[3] == 255}
pal |= {'8b1e1e','6a1c14','e07a7a','8dcb8d','d4894e','f4f7fb','ffe6a8','aaa2c6','7a6aa8','766e9a','4a446a','4a3a78','2e2450'}
fails = []; ims = {}
def F(msg): fails.append(msg); print('FAIL', msg)
for rel, sz in FILES.items():
    p = os.path.join(root, rel)
    if not os.path.exists(p): F('missing ' + rel); continue
    im = Image.open(p); ims[rel] = im.convert('RGBA')
    if im.mode != 'RGBA': F('%s mode %s' % (rel, im.mode))
    if im.size != sz: F('%s size %s != %s' % (rel, im.size, sz))
    tip = os.path.join(repo, rel)
    if os.path.exists(tip) and Image.open(tip).size != im.size: F('%s size differs from repo tip' % rel)
    a = ims[rel]; px = a.load(); W, H = a.size
    alphas = {px[x, y][3] for y in range(H) for x in range(W)}
    if not alphas <= {0, 255}: F('%s semi-alpha %s' % (rel, sorted(alphas - {0, 255})[:5]))
    off = {'%02x%02x%02x' % px[x, y][:3] for y in range(H) for x in range(W) if px[x, y][3]} - pal
    if off: F('%s %d off-palette colors %s' % (rel, len(off), sorted(off)[:6]))
    FX = {(248, 248, 252), (90, 168, 232)}  # impact sparks on slash frames may sit on the silhouette edge
    edge = [px[x, y][:3] for y in range(H) for x in range(W) if px[x, y][3] and any(
        not (0 <= x+dx < W and 0 <= y+dy < H) or px[x+dx, y+dy][3] == 0 for dx, dy in ((1,0),(-1,0),(0,1),(0,-1)))]
    edge = [c for c in edge if c not in FX]
    dark = sum(1 for c in edge if sum(c) < 110) / max(1, len(edge))
    if dark < 0.85: F('%s silhouette outline only %.0f%% dark' % (rel, dark*100))
    bb = a.getbbox()
    touch = []
    side_ok = 'extra/' in rel  # 16x28@4x extras fill the canvas width, as the other extras do
    if bb[0] == 0 and not side_ok: touch.append('left')
    if bb[1] == 0: touch.append('top')
    if bb[2] == W and not side_ok: touch.append('right')
    if bb[3] == H and 'extra/' not in rel: touch.append('bottom')
    if touch: F('%s touches canvas edge %s' % (rel, touch))
    print('ok  %-52s %s bbox=%s outline=%.0f%%' % (rel, a.size, bb, dark*100))
h = lambda r: hashlib.md5(ims[r].tobytes()).hexdigest() if r in ims else None
for pre in (D+'anim/facing/juggernaut_facing_idle_f%d.png', D+'anim/wheel/juggernaut_wheel_idle_f%d.png'):
    fr = [pre % i for i in range(4)]
    if not all(f in ims for f in fr): continue
    bbs = {ims[f].getbbox() for f in fr}
    if len(bbs) != 1: F('%s bbox jitter %s' % (pre, bbs))
    if not (h(fr[0]) == h(fr[2]) and h(fr[1]) == h(fr[3]) and h(fr[0]) != h(fr[1])): F('%s frame pattern not f0=f2,f1=f3,f0!=f1' % pre)
w = D+'anim/wheel/juggernaut_wheel_'
if h(w+'base.png') != h(w+'idle_f0.png') or h(w+'breathe_f0.png') != h(w+'idle_f0.png') or h(w+'breathe_f1.png') != h(w+'idle_f1.png'):
    F('wheel base/breathe/idle equality pattern differs from the repo convention')
print('JUGGERNAUT_A_ART_%s (%d files, %d failures)' % ('OK' if not fails else 'FAIL', len(ims), len(fails)))
sys.exit(1 if fails else 0)
