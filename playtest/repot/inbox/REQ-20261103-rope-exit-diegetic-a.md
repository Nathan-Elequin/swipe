---
id: REQ-20261103-rope-exit-diegetic-a
status: open
priority: high
branch: cursor/rope-exit-diegetic-a-7281
tip_sha: 2cefe274
created: 2026-11-03T22:30:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New (or Middle Progress) → clear a dungeon / reach rest so Rope Exit opens
---

# Rope Exit diegetic option A (hatch climb / gate delve)

Nathan lock 2026-11-03 option A + measured plant from F5/Pixel annot: remove Climb/Delve chrome plank buttons. Climb = hatch/shaft + rope coil hotspots; Delve = floor-planted gate hotspot. Left sign stays flavor-only. Title band / cleared headline may stay. Climb exit anim goes UP the shaft; Delve walks RIGHT into the gate (no jump-through-floor). Crypt Classic plates unchanged; painterly chains/gate_open stay hidden.

## Measured plant (1680×1040)

- Hatch `rope_exit_hatch.png` 256×256 at **(693, -40)** — clips into ceiling; caps green shaft (tip’s 712,16 left green above hatch).
- Gate `rope_exit_gate_frame.png` 384×512 at **Rect2(1180, 379, 384, 512)** — posts on floor, bottom ≈ 891 (tip’s 1168,180 bottoms at 692 and floats).
- Climb hits: Hatch.Hit `Rect2(693, 0, 287, 320)` + RopeCoil.Hit `Rect2(620, 820, 160, 140)`.
- Delve hit: Gate.Hit = gate rect.

## What to verify

- No Climb home / Delve deeper plank buttons (or their consequence lines) on challenge Rope Exit.
- Campaign Push/Bank plank chrome is also gone; hatch + rope coil + gate hotspots still drive Climb / Deeper.
- Hatch plate clips into ceiling (no green light above the hatch wood).
- Gate frame posts sit on the floor (bottom ≈ y 891); not floating mid-air.
- Hover + click hatch/shaft or rope coil → climb; hover + click gate → deeper.
- Climb anim: hero goes UP the shaft into the hatch.
- Delve anim: hero walks RIGHT into the gate and fades (no scale-down / drop through floor).
- Left "Grandpa's Emergency Exit" sign is not clickable.
- Title band + "Dungeon N cleared" / sub remain.
- Lifetime tallies + Crypt Classic BG unchanged.
- No new player-facing copy strings; no Tier shown.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | rope exit | clear → rest; idle | no Climb/Delve planks; title chrome OK; hatch caps ceiling (no green above); gate posts on floor | 01-idle-planted.png |
| 02 | rope exit | hover hatch or rope coil | hatch brightens / hand cursor; Climb fires on click | 02-climb-hover.png |
| 03 | rope exit | hover gate | gate brightens / hand cursor; posts still floor-planted | 03-gate-hover.png |
| 04 | rope exit | click hatch (mid-anim if possible) | hero climbing UP shaft toward hatch | 04-climb-up.png |
| 05 | rope exit | click gate (mid-anim if possible) | hero walking RIGHT into gate; not jumping through floor | 05-delve-right.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261103-rope-exit-diegetic-a/`
