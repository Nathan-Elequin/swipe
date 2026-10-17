#!/usr/bin/env python3
"""Verify the cabin-overhaul package (art sizes, cue ids, copy keys, lore ids).

Repo use (from the repo root, after unzipping):   python3 tools/cabin/verify_cabin_package.py
Before merge it checks the *.additions.json files; after merge it also checks the merged data files.
Exit code 1 if any ERROR. Needs Pillow (pip install pillow)."""
import argparse, glob, json, os, re, sys
from PIL import Image

ap = argparse.ArgumentParser()
ap.add_argument('--root', default='.', help='repo root (or the package out/ dir)')
ap.add_argument('--catalog', default=None); ap.add_argument('--runtime', default=None)
ap.add_argument('--copy', default=None, help='existing data/player-copy.json')
ap.add_argument('--sfx', default=None, help='existing data/sfx-map.json')
ap.add_argument('--existing-home', default=None, help='folder with the pre-overhaul cabin PNGs (default <root>/assets/dungeon/home)')
ap.add_argument('--audit', default=None, help='optional cabin-overhaul-audit.md: Appendix A ids are used as a second id reference')
ap.add_argument('--extras', default=None, help='optional _pixel_extras dir (checks 1x copies + review refs)')
a = ap.parse_args()
R = a.root
J = lambda p: json.load(open(p, encoding='utf-8'))
HOME = os.path.join(R, 'assets/dungeon/home'); EXIST = a.existing_home or HOME
errs, warns, infos = [], [], []
def E(m): errs.append(m)
def W(m): warns.append(m)
def I(m): infos.append(m)

# ---------- data
copy_add = J(os.path.join(R, 'data/player-copy.additions.json'))['rows']
sfx_add = J(os.path.join(R, 'data/sfx-map.additions.json'))
lore = J(os.path.join(R, 'data/lore.json'))
layout = J(os.path.join(R, 'data/cabin-layout.json'))
add_keys = {r['key'] for r in copy_add}
p = a.copy or os.path.join(R, 'data/player-copy.json')
exist_copy = {r['key']: r['text'] for r in J(p)['rows']} if os.path.exists(p) else {}
if not exist_copy: W(f'no existing copy file at {p}; reused keys only checked against the additions')
p = a.sfx or os.path.join(R, 'data/sfx-map.json')
exist_sfx = J(p) if os.path.exists(p) else {'cues': {}, 'music': {'beds': {}}}
if not exist_sfx['cues']: W(f'no existing sfx-map at {p}')
cue_add = set(sfx_add['cues']); cue_all = cue_add | set(exist_sfx['cues'])
copy_all = add_keys | set(exist_copy)
audit_keys = set()
if a.audit and os.path.exists(a.audit):   # keys the audit saw in the live repo (the local copy file may be an older snapshot)
    audit_keys = {k for k in re.findall(r'`((?:title|pause|tutorial|tier|cue|combat|challenge|adventure|door|inspect|warn)\.[a-z0-9_.]+)`', open(a.audit, encoding='utf-8').read())}
    for k in sorted(audit_keys - copy_all): I(f'copy key {k}: listed by the audit, not in the local copy file (accepted)')
    copy_all |= audit_keys

# ---------- 1. every shipped PNG: 4x of an integer native size; 1x copy matches
n_png = 0
for f in sorted(glob.glob(os.path.join(HOME, '**/*.png'), recursive=True)):
    rel = os.path.relpath(f, HOME); w, h = Image.open(f).size; n_png += 1
    if w % 4 or h % 4: E(f'{rel}: {w}x{h} is not a 4x multiple')
    if a.extras:
        one = os.path.join(a.extras, '1x', rel)
        if os.path.exists(one):
            ow, oh = Image.open(one).size
            if (ow * 4, oh * 4) != (w, h): E(f'{rel}: 1x copy {ow}x{oh} does not match 4x {w}x{h}')
        elif '/' in rel: W(f'{rel}: no 1x copy in extras')
I(f'{n_png} PNGs under assets/dungeon/home checked for 4x multiples')

def native(rel):
    for base in (HOME, EXIST):
        f = os.path.join(base, rel)
        if os.path.exists(f):
            w, h = Image.open(f).size; return (w // 4, h // 4)
    return None

# ---------- 2. docs: PNG refs + stated sizes, cue ids, copy keys
docs = sorted(glob.glob(os.path.join(R, 'design/cabin-overhaul/*.md'))) + [os.path.join(HOME, 'SIZES.md')]
COPY_PREFIX = re.compile(r'^(intro|will|nib|keyring|rope|sack|ending|map|radio|journal|defeat|pause|tutorial|title|tier)\.|^cabin\.(room|hot|gear|hall|tip|model|dummy|brag|credits|bed|telescope|trunk|cat|locked|new_count)\b')
CUE_PREFIX = re.compile(r'^(cabin|amb|sting|speech|ui|music)\.[a-z0-9_]+$')
def expand(tok):
    m = re.match(r'^(.*?)(\d+)\.\.(\d+)$', tok)
    if m: return [f'{m.group(1)}{k}' for k in range(int(m.group(2)), int(m.group(3)) + 1)]
    m = re.match(r'^(.*\.)([\w]+(?:/[\w]+)+)$', tok)
    if m and '/' not in m.group(1): return [m.group(1) + s for s in m.group(2).split('/')]
    return [tok]
n_png_ref = n_size = n_cue = n_copy = 0
for d in docs:
    name = os.path.basename(d); txt = open(d, encoding='utf-8').read()
    # frame ranges like `props/radio_firefly_f0..f3` or `doors/x_f0..f3.png`
    for m in re.finditer(r'`([\w/]+?)_f(\d+)\.\.f?(\d+)(\.png)?`', txt):
        for k in range(int(m.group(2)), int(m.group(3)) + 1):
            rel = f'{m.group(1)}_f{k}.png'; n_png_ref += 1
            if native(rel) is None and '/' in rel: E(f'{name}: frame {rel} missing')
    for m in re.finditer(r'`([\w/]+\.png)`', txt):
        rel = m.group(1)
        if rel.startswith(('_pixel_extras/', 'design/')) or '_guides' in rel: continue   # review refs: section 7; old SIZES notes
        if re.match(r'^\d\d_', rel):                                                    # bare mock name
            if a.extras and not os.path.exists(os.path.join(a.extras, 'review/mocks', rel)): E(f'{name}: mock {rel} missing')
            continue
        n_png_ref += 1
        if native(rel) is None: E(f'{name}: {rel} not found')
    # stated sizes: table rows "| node | `file` | (x,y,w,h) |", list rows "`file`...: WxH [", overlay "`file` at native (x,y,w,h)"
    for m in re.finditer(r'\| `([\w/]+\.png)` \| \((-?\d+),(-?\d+),(\d+),(\d+)\)', txt):
        s = native(m.group(1)); n_size += 1
        if s and s != (int(m.group(4)), int(m.group(5))): E(f'{name}: {m.group(1)} stated {m.group(4)}x{m.group(5)}, file is {s[0]}x{s[1]}')
    for m in re.finditer(r'`([\w/]+\.png)`(?: \.\. f\d+ \(\d+ frames\))?: (\d+)x(\d+) \[(\d+)x(\d+)\]', txt):
        s = native(m.group(1)); n_size += 1
        if s and s != (int(m.group(2)), int(m.group(3))): E(f'{name}: {m.group(1)} stated {m.group(2)}x{m.group(3)}, file is {s}')
    for m in re.finditer(r'`([\w/]+\.png)` at native \((-?\d+),(-?\d+),(\d+),(\d+)\)', txt):
        s = native(m.group(1)); n_size += 1
        if s and s != (int(m.group(4)), int(m.group(5))): E(f'{name}: {m.group(1)} stated {m.group(4)}x{m.group(5)}, file is {s}')
    # SIZES.md table rows "| file | frames | WxH |"
    for m in re.finditer(r'^\| ([\w/]+?)(_f\*)?\.png \| (\d+) \| (\d+)x(\d+) \|', txt, re.M):
        rel = m.group(1) + ('_f0' if m.group(2) else '') + '.png'; s = native(rel); n_size += 1
        if s is None: E(f'{name}: {rel} not found')
        elif s != (int(m.group(4)), int(m.group(5))): E(f'{name}: {rel} stated {m.group(4)}x{m.group(5)}, file is {s}')
    # explicit Cues: / Copy: lines
    for m in re.finditer(r'^\*\*Cues:\*\* (.*)$', txt, re.M):
        for tok in re.findall(r'`([^`]+)`', m.group(1)):
            for t in expand(tok):
                n_cue += 1
                if t not in cue_all: E(f'{name}: cue {t} not in sfx additions or existing sfx-map')
    for m in re.finditer(r'^\*\*Copy:\*\* (.*)$', txt, re.M):
        for tok in re.findall(r'`([^`]+)`', m.group(1)):
            for t in expand(tok):
                n_copy += 1
                if t not in copy_all: E(f'{name}: copy key {t} not in additions or existing copy')
    # every other backticked dotted token anywhere in the doc
    for tok in set(re.findall(r'`([a-z_]+(?:\.[a-z0-9_]+)+(?:\.\.\d+|(?:/[a-z0-9_]+)+)?)`', txt)):
        if '<' in tok or tok.endswith(('.png', '.json', '.gd', '.md', '.ogg', '.tscn', '.py', '.gif', '.txt')): continue
        for t in expand(tok):
            if t in cue_all or t in copy_all: continue
            if COPY_PREFIX.match(t) or CUE_PREFIX.match(t): E(f'{name}: `{t}` is neither a known cue nor a known copy key')
I(f'docs: {n_png_ref} PNG refs, {n_size} stated sizes, {n_cue} cue refs, {n_copy} copy refs checked over {len(docs)} files')

# ---------- 3. layout.json files and hotspot sizes
for room, items in layout['rooms'].items():
    for p in items:
        for k in ('file', 'hover'):
            if p.get(k) and native(p[k]) is None: E(f'layout {room}.{p["node"]}: {p[k]} missing')
        if p.get('file'):
            s = native(p['file'])
            if s and tuple(p['size']) != s: E(f'layout {room}.{p["node"]}: size {p["size"]} != file {s}')
        hs = p.get('hotspot')
        if hs and ((hs[2] < 12 and hs[3] < 12) or min(hs[2], hs[3]) < 8): W(f'layout {room}.{p["node"]}: hotspot {hs[2]}x{hs[3]} native is small')

# ---------- 4. audio
for cue, c in sfx_add['cues'].items():
    for f in c['files']:
        if not os.path.exists(os.path.join(R, 'assets/audio', f + '.ogg')): E(f'cue {cue}: assets/audio/{f}.ogg missing')
for bed, b in sfx_add.get('music_beds', {}).items():
    if not os.path.exists(os.path.join(R, 'assets/audio', b['file'] + '.ogg')): E(f'music bed {bed}: {b["file"]}.ogg missing')
for st in sfx_add.get('radio', {}).get('stations', []):
    if st not in sfx_add.get('music_beds', {}) and st not in exist_sfx.get('music', {}).get('beds', {}): E(f'radio station bed {st} unknown')
for k in sfx_add.get('radio', {}).get('station_copy_keys', []):
    if k not in copy_all: E(f'radio station copy key {k} missing')
dupe = cue_add & set(exist_sfx['cues'])
if dupe: W(f'sfx additions re-define existing cues (merge will skip them): {sorted(dupe)}')
cred = open(os.path.join(R, 'assets/audio/CREDITS.txt'), encoding='utf-8').read()
for f in sorted({f for c in sfx_add['cues'].values() for f in c['files']} | {b['file'] for b in sfx_add.get('music_beds', {}).values()}):
    if f not in cred: E(f'CREDITS.txt does not mention {f}')

# ---------- 5. copy rules
for r in copy_add:
    if re.search(r'\btier\b', r['text'], re.I): E(f'copy {r["key"]}: says "Tier"')
    if r['key'] in exist_copy and r['text'] != exist_copy[r['key']]: W(f'copy {r["key"]}: exists already with different text; merge will KEEP the existing text')
I(f'copy additions: {len(copy_add)} rows; {len(add_keys & set(exist_copy))} already exist (skipped on merge)')

# ---------- 6. lore ids vs catalog (+ audit appendix)
def ids_from(path, kind):
    if not path or not os.path.exists(path): return None
    d = J(path); xs = d.get(kind, [])
    return {x['id'] if isinstance(x, dict) else x for x in (xs if isinstance(xs, list) else xs.keys())}
cat_items = ids_from(a.catalog or os.path.join(R, 'data/catalog.json'), 'items')
cat_mons = ids_from(a.catalog or os.path.join(R, 'data/catalog.json'), 'monsters')
run_mons = ids_from(a.runtime or os.path.join(R, 'data/runtime.json'), 'monsters')
ref = []
if cat_items is not None: ref.append(('catalog', cat_items, cat_mons))
if a.audit and os.path.exists(a.audit):
    t = open(a.audit, encoding='utf-8').read(); ai = t.index('### Items'); am = t.index('### Monsters', ai)
    rows = lambda s: {m.group(1) for m in re.finditer(r'^\| ([a-z_]+) \|', s, re.M)} - {'id'}
    ref.append(('audit Appendix A', rows(t[ai:am]), rows(t[am:am + 20000].split('\n## ')[0])))
for label, its, ms in ref:
    li, lm = set(lore['items']), set(lore['monsters'])
    for x in sorted(li - its): (E if label == 'catalog' and not a.audit else W)(f'lore item {x} not in {label}')
    for x in sorted(its - li): (E if label != 'catalog' or not a.audit else W)(f'{label} item {x} has no lore entry')
    for x in sorted(lm - ms): (E if label == 'catalog' and not a.audit else W)(f'lore monster {x} not in {label}')
    for x in sorted(ms - lm): (E if label != 'catalog' or not a.audit else W)(f'{label} monster {x} has no bestiary entry')
    I(f'{label}: {len(its)} items / {len(ms)} monsters vs lore {len(li)} / {len(lm)}')
for k, v in lore['items'].items():
    if v['status'] == 'live' and not (40 <= v['words'] <= 80): W(f'lore item {k}: {v["words"]} words (target 40-80)')
    if re.search(r'\btier\b', v['journal'] + ' '.join(v['footnotes']), re.I): E(f'lore item {k} says Tier')
for k, v in lore['monsters'].items():
    if not (25 <= v['words'] <= 50): W(f'lore monster {k}: {v["words"]} words (target 25-50)')
    if re.search(r'\btier\b', v['entry'], re.I): E(f'lore monster {k} says Tier')

# ---------- 7. review refs
if a.extras:
    for d in docs:
        for m in re.finditer(r'_pixel_extras/(review/[\w/]+\.(?:png|gif))', open(d, encoding='utf-8').read()):
            if not os.path.exists(os.path.join(a.extras, m.group(1))): E(f'{os.path.basename(d)}: {m.group(0)} missing')
        for m in re.finditer(r'`([\w]+\.gif)`', open(d, encoding='utf-8').read()):
            if not os.path.exists(os.path.join(a.extras, 'review', m.group(1))): E(f'{os.path.basename(d)}: review GIF {m.group(1)} missing')

print('== cabin package verify ==')
for m in infos: print('INFO ', m)
for m in warns: print('WARN ', m)
for m in errs: print('ERROR', m)
print(f'== {len(errs)} errors, {len(warns)} warnings ==')
sys.exit(1 if errs else 0)
