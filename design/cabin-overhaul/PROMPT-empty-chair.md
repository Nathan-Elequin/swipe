# Visual prompt — Empty rocking chair

Paste this whole file to the visual-designer agent. They return PNGs this repo can drop in with no follow-up interview.

During the walk-in, the goblin walks left across the main room toward his chair. The sitting goblin sprite (`hero_rock_f0.png` and its rock frames) is the goblin **and** the chair in one drawing, so hiding him also hides the chair. Code now shows `hero_chair_empty.png` in that seat while he walks, and clicking it skips him into the rocking animation. The file in the folder today is a wood-only cut from `hero_rock_f0.png`. Replace it with a real empty chair that matches the rocker he sits in.

## What to return

Folder: `assets/dungeon/home/`

Native sizes below. Also ship each file **4× nearest-neighbor** (no blur, no generated mip). Transparent background.

| File | Native px | 4× px | Notes |
|---|---|---|---|
| `hero_chair_empty.png` | 32×32 | 128×128 | Empty rocking chair. Same registration as `hero_rock_f0.png`. |
| `hero_chair_empty_hover.png` | 34×34 | 136×136 | Optional. 2px larger; register at origin − (1,1) native. |

Also return a one-page size list (filename, native, 4×, transparent).

## How code uses this

- TextureRect at native origin **(10, 205)** on the main room (same slot as `hero_rock_f0.png`).
- Pivot / registration must match `hero_rock_f0.png` so when the goblin pops into the rock animation, the chair does not jump.
- Shown only while he is walking in after a haul. Hidden when he is already rocking or when the idle sitting hotspot is up.
- Clickable. Player clicks the empty chair to skip the walk and appear rocking.
- Do not draw the goblin. Do not draw English.

## What to draw

1. The **same rocking chair** as in `hero_rock_f0.png` / `hero_rock_f1.png`: dark wood back, seat, two rocker rails.
2. Empty. No goblin, no sack, no hat.
3. Seat filled with the same wood as the rest of the chair (not a goblin-shaped hole).
4. Same scale and pixel grid as the rock frames. Nearest-neighbor, not photoreal.

## Palette (from `hero_rock_f0.png`)

- Chair wood: `#744820`, `#a87448`, `#4a3020`
- Outline: `#100e0c`
- Seat highlight: `#d0b07a` (spare)

## Do not

- Do not draw the goblin, Nib, doors, or card art.
- Do not put English on the chair.
- Do not change the rock-with-goblin frames (`hero_rock_f0` … `f3`).
- Do not ship photographs.
- Do not antialias; 4× nearest-neighbor only.
