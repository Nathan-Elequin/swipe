from common import *

PAL_A = dict(
    ceil='#1a1612', ceil_lit='#2a2420', void='#0b0706',
    mortar='#1c1814', blk_d='#2a2420', blk='#3a3632', blk_l='#4a4640',          # wall ramp (dark->lit)
    warm_d='#3a3026', warm='#4a3e30', warm_l='#5e4e3a',                         # same blocks inside torchlight
    pil_d='#3a3632', pil='#5c564e', pil_l='#7a7268',
    arch='#14100c', arch_l='#221d15',
    floor_l='#5a5040', floor='#4a4438', floor_d='#3a3226', floor_j='#2a2420',
    front='#221d15', front_d='#1a1410', front_dd='#120e0a',
    beam='#3a2414', beam_l='#5a3a24',
    iron='#2a2a30', iron_l='#5c5a60',
)
PAL_B = dict(   # deeper belly of the Grumble: wetter, redder, fewer torches
    ceil='#140c10', ceil_lit='#24141a', void='#08040a',
    mortar='#140c10', blk_d='#24161c', blk='#33202a', blk_l='#442a36',
    warm_d='#3a1e1e', warm='#4e2a24', warm_l='#663a2c',
    pil_d='#5a4632', pil='#8a7050', pil_l='#c4a574',       # pillars become ribs (old bone)
    arch='#0e070a', arch_l='#1c0e14',
    floor_l='#4e3a36', floor='#3e2c2c', floor_d='#2e2022', floor_j='#1e1216',
    front='#1c1014', front_d='#140a0e', front_dd='#0c0608',
    beam='#2c1a10', beam_l='#4a2c1c',
    iron='#26222a', iron_l='#5a5060',
)
CEIL_Y, WALL_Y1, FLOOR_TOP, FLOOR_BOT = 30, 146, 147, 178

def build(variant='a'):
    P = PAL_A if variant == 'a' else PAL_B
    s = Strip(P['blk'])
    torches = [0, 140, 280] if variant == 'a' else [122, 332]
    pillars = [0, 140, 280] if variant == 'a' else [0, 105, 210, 315]

    # --- back wall: big quiet blocks (28x14), staggered
    for y in range(CEIL_Y, WALL_Y1 + 1):
        row = (y - CEIL_Y) // 14
        ry = (y - CEIL_Y) % 14
        for x in range(W):
            rx = (x + (14 if row % 2 else 0)) % 28
            if ry == 13 or rx == 27:
                c = 'mortar'
            elif ry == 0 or rx == 0:
                c = 'blk_l'              # upper-left lit edge
            elif ry == 12 or rx == 26:
                c = 'blk_d'
            else:
                c = 'blk'
            # darker toward the ceiling (two flat steps)
            if y < CEIL_Y + 28 and c == 'blk':
                c = 'blk_d'
            s.px(x, y, P[c])
    # sparse wall wear (cracks), deterministic
    r = random.Random(5 if variant == 'a' else 9)
    for i in range(10 if variant == 'a' else 22):
        x, y = r.randrange(W), r.randrange(CEIL_Y + 30, WALL_Y1 - 6)
        for k in range(r.randrange(3, 7)):
            s.px(x + k // 2, y + k, P['mortar'])

    # --- arched recesses between pillars: same blocks one ramp darker (reads as depth, not a hole)
    rec = {P['blk']: P['arch_l'], P['blk_l']: P['blk_d'], P['blk_d']: P['arch'], P['mortar']: P['arch']}
    rec = {Image.new('RGB', (1, 1), k).getpixel((0, 0)): v for k, v in rec.items()}
    shrink = 8 if variant == 'a' else 14
    for i in range(len(pillars)):
        a = pillars[i] + 14
        b = (pillars[i + 1] if i + 1 < len(pillars) else W + pillars[0]) - 14
        cx = (a + b) // 2
        hw = (b - a) // 2 - shrink
        top = 62 if variant == 'a' else 56
        for y in range(top, WALL_Y1 - 1):
            dy = max(0, (top + hw) - y)
            half = int(math.sqrt(max(0, hw * hw - dy * dy))) if dy else hw
            if half <= 0:
                continue
            for x in range(cx - half, cx + half + 1):
                c = s.get(x, y)
                if c in rec:
                    s.px(x, y, rec[c])
            s.px(cx - half - 1, y, P['blk_l'])     # lit jamb on the left (upper-left light)
            s.px(cx + half + 1, y, P['mortar'])
    # --- plinth course under the wall
    s.rect(0, 138, W - 1, WALL_Y1, P['blk_d'])
    s.hline(0, W - 1, 138, P['blk_l'])
    s.hline(0, W - 1, WALL_Y1, P['mortar'])

    # --- pillars (or ribs in B)
    for px0 in pillars:
        if variant == 'a':
            s.rect(px0 - 9, CEIL_Y, px0 + 9, WALL_Y1, P['pil'], INK)
            s.rect(px0 - 8, CEIL_Y + 1, px0 - 6, WALL_Y1 - 1, P['pil_l'])
            s.rect(px0 + 5, CEIL_Y + 1, px0 + 8, WALL_Y1 - 1, P['pil_d'])
            for y in range(CEIL_Y + 18, WALL_Y1, 18):
                s.hline(px0 - 8, px0 + 8, y, P['pil_d'])
                s.hline(px0 - 8, px0 + 8, y + 1, P['pil_l'])
            # capital + base
            s.rect(px0 - 12, CEIL_Y + 6, px0 + 12, CEIL_Y + 11, P['pil'], INK)
            s.hline(px0 - 11, px0 + 11, CEIL_Y + 7, P['pil_l'])
            s.rect(px0 - 12, 134, px0 + 12, WALL_Y1, P['pil'], INK)
            s.hline(px0 - 11, px0 + 11, 135, P['pil_l'])
        else:
            # curved rib: thick bone arc from floor up into the ceiling, bending right
            for y in range(CEIL_Y - 10, WALL_Y1 + 1):
                t = (WALL_Y1 - y) / (WALL_Y1 - CEIL_Y + 10)
                off = int(10 * t * t)
                w = 6 if y > CEIL_Y + 10 else 5
                x0 = px0 - w + off
                s.hline(x0, x0 + 2 * w, y, P['pil'])
                s.px(x0 - 1, y, INK); s.px(x0 + 2 * w + 1, y, INK)
                s.hline(x0, x0 + 2, y, P['pil_l'])
                s.hline(x0 + 2 * w - 3, x0 + 2 * w, y, P['pil_d'])
            for y in range(CEIL_Y + 14, WALL_Y1 - 4, 22):    # knuckle bands
                t = (WALL_Y1 - y) / (WALL_Y1 - CEIL_Y + 10)
                off = int(10 * t * t)
                s.hline(px0 - 7 + off, px0 + 7 + off, y, INK)

    # --- torches with stepped light: inner ring one step warmer+lighter, outer ring warmer only
    def rgb(h): return Image.new('RGB', (1, 1), h).getpixel((0, 0))
    inner = {rgb(P['blk']): P['warm'], rgb(P['blk_d']): P['warm'], rgb(P['blk_l']): P['warm_l'],
             rgb(P['arch_l']): P['warm'], rgb(P['arch']): P['warm_d'], rgb(P['mortar']): P['warm_d'],
             rgb(P['pil']): P['pil_l'], rgb(P['pil_d']): P['pil']}
    outer = {rgb(P['blk']): P['warm_d'], rgb(P['blk_d']): P['warm_d'], rgb(P['blk_l']): P['warm'],
             rgb(P['arch_l']): P['warm_d'], rgb(P['arch']): P['arch_l']}
    for tx in torches:
        ty = 92
        R1, R2 = (36, 20) if variant == 'a' else (26, 14)
        for y in range(max(CEIL_Y, ty - R1), min(WALL_Y1 - 1, ty + R1) + 1):
            for x in range(tx - R1, tx + R1 + 1):
                d2 = (x - tx) ** 2 + ((y - ty) * 1.3) ** 2
                if d2 > R1 * R1:
                    continue
                c = s.get(x, y)
                m = inner if d2 <= R2 * R2 else outer
                if c in m:
                    s.px(x, y, m[c])
        # sconce
        s.rect(tx - 2, ty, tx + 2, ty + 8, P['iron'], INK)
        s.px(tx - 1, ty + 1, P['iron_l'])
        s.rect(tx - 4, ty - 1, tx + 4, ty + 1, P['iron'], INK)
        s.hline(tx - 3, tx + 3, ty - 1, P['iron_l'])
        s.vline(tx, ty + 9, ty + 12, P['iron'])
        # flame (B: lower, redder)
        if variant == 'a':
            s.poly([(tx - 3, ty - 2), (tx, ty - 12), (tx + 3, ty - 2)], EMBER)
            s.poly([(tx - 2, ty - 2), (tx, ty - 10), (tx + 2, ty - 2)], TORCH)
            s.poly([(tx - 1, ty - 2), (tx, ty - 7), (tx + 1, ty - 2)], GOLD)
            s.px(tx, ty - 11, CREAM)
        else:
            s.poly([(tx - 3, ty - 2), (tx - 1, ty - 9), (tx + 3, ty - 2)], '#9a3428')
            s.poly([(tx - 2, ty - 2), (tx, ty - 7), (tx + 2, ty - 2)], EMBER)
            s.poly([(tx - 1, ty - 2), (tx, ty - 4), (tx + 1, ty - 2)], TORCH)

    # --- ceiling rock with stalactites (B: tooth rows)
    for x in range(W):
        bot = int(CEIL_Y + 2 + wave(x, [(2, 3, 0.2), (1.5, 8, 1.3)]))
        s.vline(x, 0, bot, P['ceil'])
        s.px(x, bot, P['ceil_lit'])
        s.px(x, bot + 1, INK)
    rs = random.Random(21 if variant == 'a' else 23)
    nst = 9 if variant == 'a' else 20
    for i in range(nst):
        x = rs.randrange(W)
        L = rs.randrange(5, 12) if variant == 'a' else rs.randrange(8, 20)
        for k in range(L):
            w = max(0, (L - k) // 4)
            s.hline(x - w, x + w, CEIL_Y + 2 + k, P['ceil'])
            s.px(x - w - 1, CEIL_Y + 2 + k, INK); s.px(x + w + 1, CEIL_Y + 2 + k, INK)
            s.px(x - w, CEIL_Y + 2 + k, P['ceil_lit'])
        s.px(x, CEIL_Y + 2 + L, INK)
    # a timber beam spanning the ceiling (mine-shaft read)
    s.rect(0, CEIL_Y - 6, W - 1, CEIL_Y - 2, P['beam'])
    s.hline(0, W - 1, CEIL_Y - 6, P['beam_l'])
    s.hline(0, W - 1, CEIL_Y - 1, INK)
    for px0 in pillars:
        s.rect(px0 - 3, CEIL_Y - 7, px0 + 3, CEIL_Y - 1, P['iron'], INK)   # brackets over pillars

    # --- floor plane: clean walking band, feet at y=161 in the middle
    s.rect(0, FLOOR_TOP, W - 1, FLOOR_BOT, P['floor'])
    s.hline(0, W - 1, FLOOR_TOP, P['floor_l'])
    s.hline(0, W - 1, FLOOR_TOP + 1, P['floor_l'])
    s.rect(0, FLOOR_BOT - 5, W - 1, FLOOR_BOT, P['floor_d'])          # far->near shade step
    for x in range(0, W, 35):                                         # slab joints, slanted, few
        for y in range(FLOOR_TOP + 2, FLOOR_BOT + 1):
            s.px(x + (y - FLOOR_TOP) // 4, y, P['floor_j'])
    s.hline(0, W - 1, 154, P['floor_j'])       # one long joint behind the feet line (not at 161)
    # torchlight pools on the floor under each torch
    for tx in torches:
        for y in range(FLOOR_TOP + 2, 156):
            hw = 22 - (y - FLOOR_TOP) if variant == 'a' else 16 - (y - FLOOR_TOP)
            for x in range(tx - hw, tx + hw + 1):
                if s.get(x, y) == Image.new('RGB', (1, 1), P['floor']).getpixel((0, 0)):
                    s.px(x, y, P['floor_l'])
    # --- front edge + foreground below the lane
    s.hline(0, W - 1, FLOOR_BOT + 1, INK)
    for y in range(FLOOR_BOT + 2, H):
        c = P['front'] if y < 205 else P['front_d'] if y < 236 else P['front_dd']
        s.hline(0, W - 1, y, c)
    for y in range(FLOOR_BOT + 2, 236, 12):                            # big foundation blocks
        row = (y - FLOOR_BOT) // 12
        s.hline(0, W - 1, y + 11, P['front_dd'])
        for x in range((row % 2) * 21, W, 42):
            s.vline(x, y, y + 11, P['front_dd'])
            s.hline(x + 1, x + 6, y, P['front'] if y >= 205 else P['floor_j'])
    # foreground silhouettes (frame only, low contrast)
    if variant == 'a':
        for x0, w0, h0 in [(60, 24, 14), (250, 30, 10), (380, 18, 18)]:      # rubble humps
            s.ellipse(x0 - w0 // 2, H - h0, x0 + w0 // 2, H + h0, P['front_dd'])
            s.hline(x0 - w0 // 4, x0, H - h0, P['front'])
    else:
        # bones and a dropped helm-less skull pile in the foreground (old delvers), plus webs and drips
        for x0, y0 in [(40, 232), (190, 244), (318, 228)]:
            s.ellipse(x0, y0, x0 + 8, y0 + 7, '#8a7050', INK)
            s.px(x0 + 2, y0 + 3, INK); s.px(x0 + 5, y0 + 3, INK)
            s.hline(x0 + 2, x0 + 6, y0 + 1, '#c4a574')
            s.rect(x0 + 10, y0 + 4, x0 + 22, y0 + 5, '#8a7050', INK)
            s.px(x0 + 9, y0 + 3, '#c4a574'); s.px(x0 + 23, y0 + 3, '#c4a574')
        for wx in (0, 210):                                            # corner webs under the beam
            for k in range(12):
                s.px(wx + k, CEIL_Y + k, '#5a4a52'); s.px(wx + k * 2 // 3, CEIL_Y + 2, '#5a4a52')
                s.px(wx + 1, CEIL_Y + k, '#5a4a52')
        for dx in (48, 176, 262, 396):                                 # drips running down the wall
            for y in range(CEIL_Y + 4, CEIL_Y + 30, 1):
                if (y * 7 + dx) % 9 < 6:
                    s.px(dx, y, '#4a2c36')
        for ex in (62, 300):                                           # eyes in two recesses
            s.px(ex, 118, '#d5443b'); s.px(ex + 3, 118, '#d5443b')
    return s.tile()

if __name__ == '__main__':
    import sys
    for v, name in [('a', 'hall_strip'), ('b', 'hall_strip_b')]:
        img = build(v)
        ship(img, f'<TITLE_TEASER>/out/{name}_native.png', f'<TITLE_TEASER>/out/{name}.png')
        img.resize((840, 520), Image.NEAREST).save(f'<TITLE_TEASER>/out/_review_{name}_2x.png')
        print(name, len(set(img.getdata())))
