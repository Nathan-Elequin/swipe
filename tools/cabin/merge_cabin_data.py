#!/usr/bin/env python3
"""Merge the cabin-overhaul additions into the live data files WITHOUT overwriting anything.

Run from the repo root:  python3 tools/cabin/merge_cabin_data.py [--dry-run]
- data/player-copy.additions.json rows -> data/player-copy.json rows (skips keys that already exist)
- data/sfx-map.additions.json cues -> sfx-map.json cues; music_beds -> music.beds; music_states -> music.states;
  radio -> top-level "radio" (skips existing keys)
Prints every skipped key. Writes UTF-8, 2-space indent, keeps the existing key order and appends new keys."""
import json, sys
dry = '--dry-run' in sys.argv
J = lambda p: json.load(open(p, encoding='utf-8'))
def dump(p, d):
    if not dry:
        with open(p, 'w', encoding='utf-8') as f: json.dump(d, f, ensure_ascii=False, indent=2); f.write('\n')

copy = J('data/player-copy.json'); add = J('data/player-copy.additions.json')
have = {r['key'] for r in copy['rows']}; new = skip = 0
for r in add['rows']:
    if r['key'] in have: print('copy SKIP (exists):', r['key']); skip += 1; continue
    copy['rows'].append({k: r[k] for k in ('cat', 'key', 'where', 'text')} | {'draft': True}); new += 1
dump('data/player-copy.json', copy); print(f'copy: +{new} rows, {skip} skipped')

sfx = J('data/sfx-map.json'); sa = J('data/sfx-map.additions.json')
def merge(dst, src, label):
    n = 0
    for k, v in src.items():
        if k in dst: print(f'{label} SKIP (exists):', k); continue
        dst[k] = v; n += 1
    print(f'{label}: +{n}')
merge(sfx['cues'], sa['cues'], 'cues')
merge(sfx.setdefault('music', {}).setdefault('beds', {}), sa.get('music_beds', {}), 'music.beds')
merge(sfx['music'].setdefault('states', {}), sa.get('music_states', {}), 'music.states')
if 'radio' not in sfx: sfx['radio'] = sa.get('radio', {}); print('radio: added')
else: print('radio SKIP (exists)')
dump('data/sfx-map.json', sfx)
print('dry run, nothing written' if dry else 'written')
