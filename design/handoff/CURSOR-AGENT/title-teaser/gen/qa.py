import numpy as np, glob, os, json
from PIL import Image
OUT = '<TITLE_TEASER>/out/'; QA = '<TITLE_TEASER>/qa/'
names = ['hill_strip', 'hall_strip', 'hall_strip_b']
rep = {}
# live card sprites -> native (detect integer scale), RGBA
live = []
for f in sorted(glob.glob('<TITLE_TEASER>/src/live_cards/*.png')):
    im = np.array(Image.open(f).convert('RGBA'))
    for s in (4, 2, 1):
        if im.shape[0] % s == 0 and im.shape[1] % s == 0 and (im[::s, ::s].repeat(s, 0).repeat(s, 1) == im).all():
            break
    live.append((os.path.basename(f), im[::s, ::s]))
for n in names:
    nat = Image.open(OUT + n + '_native.png'); shp = Image.open(OUT + n + '.png')
    a = np.array(nat.convert('RGB')).astype(int); b = np.array(shp.convert('RGB')).astype(int)
    r = {'native': nat.size, 'shipped': shp.size, 'mode_native': nat.mode, 'mode_shipped': shp.mode,
         'opaque': nat.mode == 'RGB' and shp.mode == 'RGB'}
    r['x4_nearest_exact'] = bool((a.repeat(4, 0).repeat(4, 1) == b).all())
    # seam: colour change across the wrap vs typical adjacent-column change
    def coldiff(x0, x1): return float((np.abs(a[:, x0] - a[:, x1]).sum(1) > 0).mean())
    inner = [coldiff(x, x + 1) for x in range(419)]
    r['seam_changed_rows_frac'] = round(coldiff(419, 0), 3)
    r['interior_median_frac'] = round(float(np.median(inner)), 3)
    r['interior_p90_frac'] = round(float(np.percentile(inner, 90)), 3)
    r['seam_le_p90'] = r['seam_changed_rows_frac'] <= r['interior_p90_frac']
    cols = sorted(set(map(tuple, a.reshape(-1, 3))))
    r['palette_count'] = len(cols)
    r['palette'] = ['#%02x%02x%02x' % c for c in cols]
    r['floor_row_161_colours'] = sorted(set('#%02x%02x%02x' % tuple(c) for c in a[161]))
    # uniqueness: slide every live sprite over the strip, best fraction of opaque pixels matching exactly
    best = (0.0, None, None)
    for nm, sp in live:
        al = sp[:, :, 3] > 0
        if al.sum() < 12: continue
        rgb = sp[:, :, :3].astype(int); h, w = al.shape
        for y in range(0, 260 - h + 1):
            win = np.lib.stride_tricks.sliding_window_view(a[y:y + h], (h, w, 3))[0, :, 0]  # (W-w+1,h,w,3)
            eq = (win == rgb[None]).all(-1) & al[None]
            frac = eq.sum((1, 2)) / al.sum()
            i = int(frac.argmax())
            if frac[i] > best[0]: best = (float(frac[i]), nm, (i, y))
    r['live_sprite_best_match'] = {'frac_opaque_px_identical': round(best[0], 3), 'sprite': best[1], 'at': best[2]}
    rep[n] = r
    # 3x tiled seam test (2x scale) + marked copy
    t = Image.new('RGB', (1260, 260)); [t.paste(nat, (420 * k, 0)) for k in range(3)]
    t.resize((2520, 520), Image.NEAREST).save(QA + f'{n}_seam_3x.png')
    m = t.copy(); px = m.load()
    for x in (420, 840):
        for y in list(range(0, 6)) + list(range(254, 260)): px[x, y] = (255, 0, 255)
    m.resize((2520, 520), Image.NEAREST).save(QA + f'{n}_seam_3x_marked.png')
json.dump(rep, open(QA + 'qa_report.json', 'w'), indent=1)
for n, r in rep.items():
    print(n, {k: v for k, v in r.items() if k != 'palette'})
print('live sprites checked:', len(live))
