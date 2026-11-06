# Wheel seats from facing — v2 notes

Seat size follows **difficulty** (catalog `tier`): Deadly (3) → **32px**, Weak (1) / Tough (2) → **24px**.
Art snapshot: `/workspace/fidelity-tip` (audit tip). v1 outputs kept in `_v1/`.

## Changes from v1

- Refit 64-facing non-Deadly to 24: juggernaut, ogre, hydra, shark, gelatinous_cube (2:1→32, trim content, centre or majority-fit).
- `phoenix_egg` Deadly 48-facing → 32 seat: **48to32_nearest_outline(score=0.792>0.786,fp=775vs437)**. Compared nearest-outline vs half24-centered; picked nearest-outline (fills Deadly 32 seat, keeps flame detail).
- Cleanup pass on: hornet_swarm, wick, dire_wolf, wraith, slime_boss, cultist, shark, death_bell, oligarch, sandbag (+ eyeball harpy, fairy, bear_trap, hollow).
- Produced animated idle frames for all facing frames under `seats/frames/<id>_wheel_idle_fN.png` and breathe-compatible `seats/<id>_wheel_breathe_f0/f1.png`.

## Method summary

Method families: {'mode_outline_half_48to24': 36, 'nearest_half_48to24+gentle_outline': 1, 'nearest_half_64to32': 1, 'half64_majority_fit_30x31to23x24': 1, 'nearest_half_48to24': 2, 'mode_outline_half_64to32': 15, 'half64_majority_fit_22x31to17x24': 1, 'half64_majority_fit_27x31to21x24': 1, 'mode_outline_half_48to24+forced_cleanup': 1, 'half64_majority_fit_30x30to24x24': 1, 'half64_majority_fit_30x27to24x22': 1, '48to32_nearest_outline': 1}
Cleanup applied: 14 monsters.

## Still weak after cleanup

- **hornet_swarm** (Weak, 24n): short h=9
- **wick** (Tough, 24n): thin w=12
- **wraith** (Tough, 24n): source 2x-blocky b2=0.78

## Animation

Today `dungeon_art.wheel_frames_all()` returns a **single** `*_wheel_base.png` per monster (breathe pair exists on disk but is skipped for seats; comment says different crop).
`boss_wheel._wheel_tex` already advances multi-frame arrays at 200ms/frame when `tex_wheel_frames[id]` has >1 frame.
v2 produced half/tier-sized copies of **every facing idle frame** (usually 4; bear_trap has 1) so wiring can pass the full strip without a second art pass.

## Wire

See `SCREEN-wheel-seat-from-facing.md` (target repo path `design/visual/SCREEN-wheel-seat-from-facing.md`).

## Deliverables

- `CONTACT-v2.png`, `CONTACT-wheel-mock-v2.png`
- `seats/<id>_wheel_base.png` (62) + `seats/<id>_wheel_breathe_f0/f1.png` + `seats/frames/*_wheel_idle_fN.png`
- `seats/manifest.json`, `methods-v2.json`, `NOTES.md`, `build_v2.py`
- `_v1/` archive of previous preview
