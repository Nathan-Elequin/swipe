# SCREEN: wheel seat from facing

Status: preview approved path (Nathan 2026-11-05). Seat size follows difficulty — Deadly 32px native, Weak and Tough 24px native. Art is exact-half (or refit) of fight facing frame 0, with idle frames produced for animation.

## Art files

- Install seat PNGs to `assets/dungeon/anim/wheel/<id>_wheel_base.png`.
- Import filter: **Nearest** (no filter / no mipmaps that blur).
- Also install idle frames produced in the preview batch:
  - `assets/dungeon/anim/wheel/<id>_wheel_idle_f0.png` … `fN` (N = facing idle count, usually 3 → 4 frames), **or**
  - reuse breathe names: `*_wheel_breathe_f0.png` / `*_wheel_breathe_f1.png` from facing f0/f1 if you only want a 2-frame loop for now.
- Preview batch also keeps a full strip under the batch `seats/frames/` folder for easy copy.

## Archive (do not delete)

Move the previous wheel PNGs (base + breathe) to:

`design/archive/pass-wheel-pre-facing/`

Keep paths mirrored (`<id>_wheel_base.png`, etc.) so a revert is a copy back. Do not delete in place.

## Code

### `scripts/boss_wheel.gd`

- Seat display size is **per seat by difficulty**: native 24 (Weak/Tough) or 32 (Deadly), drawn at `WHEEL_SPRITE_SCALE` (today 2.0 → 48px or 64px on-screen).
- Update constants / `_seat_sprite_size()` so a 32 native Deadly seat is first-class (not an accidental fit of a larger texture).
- Re-check together:
  - `_radius()`
  - seat spacing / wedge chord (`_sprite_slot`)
  - pass-6 `_fit_table` / `fit_clearances`
  - `_spoke` offsets for name tag, HP/ATK badges, medallion
  - hit areas (angle + radius band vs larger sprite rects)
- Stress case: biome mixes with several Deadlies (e.g. B5).

### `scripts/dungeon_art.gd`

- `wheel_frames_all()` / `monster_wheel_frames()` must pick up the new base files (same paths as today).
- **Animation today:** `wheel_frames_all()` returns a **single-frame** list from `*_wheel_base.png`. Breathe files exist on disk but are intentionally skipped for seats (comment: different crop). `boss_wheel._wheel_tex` already loops multi-frame arrays at 200ms/frame when given more than one texture.
- **This pass:** preview produced tier-sized versions of **all facing idle frames** (61 of 62 monsters have 4 frames; bear_trap has 1). Prefer wiring the full idle strip into `tex_wheel_frames` so seats animate like the fight portrait. If that is deferred, shipping single-frame bases alone is acceptable; breathe can stay archived until replaced.

### Difficulty source

`data/catalog.json` → monster `tier` int: 1 Weak, 2 Tough, 3 Deadly (`player_copy.tier_name`). Seat pixel size keys off that value only.

## Acceptance

1. Every live monster id has `assets/dungeon/anim/wheel/<id>_wheel_base.png` at 24×24 (Weak/Tough) or 32×32 (Deadly), Nearest, hard alpha 0/255.
2. Old wheel art lives under `design/archive/pass-wheel-pre-facing/` (not deleted).
3. Wheel seats match fight facing silhouette (same pose/palette family); Deadly seats read larger than Weak/Tough on the ring.
4. Screenshot check: one fight / wheel with a **mixed** set — at least one Weak, one Tough, one Deadly on the ring together — confirm spacing, chrome (name/HP/ATK), and taps still work; no overlap crashes or clearance warnings in log.
5. If idle frames wired: seats idle-animate while not spinning / not held; freeze mid-spin unchanged.
6. **No player-facing text changes.** Do not surface the word "Tier" on screen; keep Weak / Tough / Deadly labels as they are.

## Out of scope

- Redrawing fight facing art
- Player copy / localization
- Title-teaser separate files
