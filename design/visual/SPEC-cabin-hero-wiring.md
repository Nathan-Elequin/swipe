# SPEC: cabin hero wiring (sad walk, sack dump, sack shake, rock loop, gear overlays)

The art already exists in `assets/dungeon/home/hero/`. This spec covers the code, which is Cursor's job. Coordinates are native cabin px; shipped = x4 (`_pt()` does that). Hero canvas = 32x32 [128x128], feet on row 30, unless noted.

Rules: no player-facing text changes, and no renaming of existing keys or identifiers.

## 0. Replace the gear overlays first

Copy `assets/dungeon/home/hero/gear/**` from this drop over the repo. That is 176 files with the same names and sizes.

The shipped overlays had two problems:
- 160 overlays had body pixels palette-swapped into them, because the gear glyphs collided with hero glyphs in `cab_props.WORN_PAL`.
- `hero_sit_f0..f4` overlays were empty.

The fixed overlays hold only gear pixels. Verified: base + overlay == the worn render on all 44 base frames (`out/cabin-overlays-fixed/verify.json`).

## 1. Composite the overlays (bug in `_set_hero_frame`, home_cabin.gd:3247)

Today the function sets `_hero.texture = overlay`, which **replaces** the hero with a floating hat. It is also never called; every animation sets `_hero.texture` directly.

- Add 4 child `Sprite2D`s under `_hero`, in `_hero_layers` (the var exists at line 92, unused):
  - order `rope`, `goggles`, `cap`, `helm`;
  - `centered`, `offset` and `flip_h` the same as `_hero`;
  - `texture_filter` NEAREST;
  - position (0,0).
- `_set_hero_frame(family, i)`:
  - Set `_hero.texture` = base: `hero/<family>_f<i>.png`, falling back to top-level `<family>_f<i>`.
  - For each piece: layer.texture = `hero/gear/<piece>/<family>_f<i>.png` if worn, else null.
  - Copy `_hero.flip_h` onto each layer, and also copy `offset` (needed for the 48x40 families, see section 3).
- Route **every** frame change through `_set_hero_frame`. These sites set `_hero.texture` today:
  - lines 838, 858, 892, 1001, 1019 (walk / walk_loot / idle_blink);
  - 1041-1046 (drop_sack);
  - 1057-1062 and 1487-1492 (sit / stand-up);
  - 2145 and 2256 (debug / test paths);
  - 2800-2802 (cheer).
- Gear slot rule: cap and helm both use `gear_worn.head`, so only one draws.
- `rope` is `belt` and `goggles` is `eyes`. Keep the `extra.gear_slots` lookup as is.

## 2. Rock loop with gear (chair hotspot)

- `_rock` is an AnimatedSprite2D at `_pt(10,205)`, playing `hero_rock_f1, f2, f3, f0` at 4 fps on a loop. It has no gear layers.
- Pick one fix:
  - **(a)** Keep `_rock`. Add 4 child Sprite2Ds and update them on `frame_changed`, using the frame-to-file map `[1,2,3,0]` → `hero/gear/<piece>/hero_rock_f<n>.png`.
  - **(b)** Drop `_rock`. Drive `_hero` at (10,205) with a 250 ms timer through `_set_hero_frame("hero_rock", n)`. (b) is simpler and shares the layers.
- `hero_sit_f4` == `hero_rock_f0`, so sit → rock continues from rock f1, as now. The sit overlays are no longer empty, so the hat no longer pops in on that transition.
- Click hotspot unchanged: (10,205,32,32).

## 3. New families to hook up

| family | canvas | place at | timing | when |
|---|---|---|---|---|
| hero_walk_sad f0-3 | 32x32 | same as hero_walk (path / floor y - 30) | 8 fps loop (125 ms) | LOSS homecoming: replaces walk_loot outside and inside; no sack |
| hero_idle_loot f0-1 | 32x32 | hero origin | 2 frames, slow breathe (~500 ms) | WIN homecoming idle holding the sack (rope exit, before the dump) |
| hero_sack_dump f0-4 | **48x40** | **hero origin - (8,8)** | 120,200,260,260,300 ms | WIN: f0 grab, f1 hug, f2 tip (spawn the item pops from the sack mouth on f2), f3 shake, f4 done |
| hero_sack_shake f0-5 | **48x40** | **hero origin - (8,8)** | 120,160,160,160,400,500 ms | LOSS: f0 grab, f1-f3 shake upside-down (one moth on f2), f4 peer in, f5 slump |
| hero_sack_empty_limp | 6x7 [24x28] | bottom-left at hero origin + (14,24) | static | left on the floor after the shake |
| hero_cheer f0-1 | 32x32 | hero origin | 140 / 260 ms, Tween y -4px on f1 | new item burst / full cabinet |
| hero_climb f0-1 | 32x32 | hero origin | 2 frames @ 160 ms + Tween position.y up | rope-ladder climb |

- **48x40 families:**
  - Either move `_hero.position` by (-8,-8) native [(-32,-32) shipped] for the duration, or set `offset` by the same amount. Restore it afterwards.
  - With `flip_h`, mirror the x: the canvas grows 8 px each side, so (-8) stays (-8).
  - The overlays use the same canvas, so they need the same offset. That is why section 1 copies `offset`.
- Suggested beat order:
  - **Win:** walk_loot → idle_loot → sack_dump → (items fly to the shelf) → cheer → walk → sit → rock.
  - **Loss:** walk_sad → sack_shake → spawn hero_sack_empty_limp → walk_sad to the chair → sit → rock.
- Screen bump: 4 shipped px down for one frame. It already happens on drop_sack f2 and sit f3; add it on sack_dump f2 (the tip).

## 4. Test checklist

- Wear helm + goggles + rope, then play each family. The gear stays on the head and belt in every frame, including sit and rock.
- With nothing worn, all layers are null and the hero looks identical to now.
- Flip: walk_loot and drop_sack inside (flip_h) mirror the layers too.
- Swap helm ↔ cap while rocking: only one head piece is visible.
