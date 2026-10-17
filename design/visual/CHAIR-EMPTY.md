# Empty rocking chair (cabin main room)

Replaces the placeholder `hero_chair_empty.png`, which had the wrong art and scale and a goblin-ish blob in the seat.

## Files

| file | native | shipped | notes |
|---|---|---|---|
| `assets/dungeon/home/chair_empty.png` | 32x32 | 128x128 | the empty chair at rest. Transparent background. |
| `assets/dungeon/home/chair_settle_f0..f3.png` | 32x32 | 128x128 | optional settle rock: f0 tipped forward, f1 rest, f2 tipped back, f3 rest (pixel-identical to `chair_empty`). |

- Every PNG is the native art scaled up by exactly 4x with Nearest. Import with **Filter = Nearest**, no mipmaps, no compression artifacts (Lossless).
- **Canvas and pivot are the same as `hero_rock_f*` / `hero_sit_f*`**: 32x32, top-left origin (`centered = false` / TextureRect). Rockers rest on frame row 28, the soft shadow is on row 31 (x 4..26, #100e0c @ alpha 115), and the seat top is row 20.
- Pixel match: this is the chair from `home_hero.CHAIR` + `rocker()`, run through the same outline and shadow pass as `rock_frame()`, without the goblin. Outside the goblin and his 1px outline ring, `chair_empty` matches `hero_rock_f0`, `hero_sit_f0` and `hero_sit_f1` exactly (0 px different). The settle frames match `hero_rock_f1` and `hero_rock_f3` (same tilt) in the same way.

## Placement

- Main room, native **(10, 205)**, which is **(40, 820)** shipped px. This is the same position the `hero_rock` AnimatedSprite2D and the `hero_sit` frames use, so swapping between them causes no jump.
- Not flipped. z: under the walking goblin (`_chair_empty.z_index = 3`, hero 4, rock 5, as now).

## State logic

`chair_empty` is visible **whenever the goblin is not sitting in the chair**:

| state | chair node |
|---|---|
| cabin load / `show_menu()` idle (goblin standing elsewhere) | `chair_empty` **visible** |
| arrival `int_walk`, `drop`, `to_chair` (walking toward it) | `chair_empty` visible (goblin passes in front, z 4 over z 3) |
| arrival `sit` (he reaches (10,205)) | hide `chair_empty` **in the same frame** that `hero_sit_f0` is shown, then play sit f0-f4 and the `hero_rock` loop |
| `rock` loop / `_settle_arrive_chair()` / `_on_door()` straight to rock | `chair_empty` hidden, `_rock` visible |
| goblin leaves the chair (rock stops, he is shown standing elsewhere) | hide `_rock` and show `chair_empty` in the same frame. Optional: play `chair_settle_f0..f3` (120 / 160 / 200 / 240 ms, one-shot), then hold `chair_empty` |
| exterior / run (`hide_for_run`, `_show_exterior`) | does not matter (interior hidden) |

Never show `chair_empty` and a `hero_rock`/`hero_sit` frame together. Their chair pixels are identical, but showing both means double draws and two click targets.

## Code changes (home_cabin.gd)

1. Load the new stem: `_home("hero_chair_empty")` becomes `_home("chair_empty")` (2 places: `_apply_textures` ~l.762 and `_show_empty_chair` ~l.1238).
2. `show_menu()` currently calls `_show_empty_chair(false)` and hides `_rock` while the idle goblin stands elsewhere. Then the room has **no chair at all**. Change it to `_show_empty_chair(true)`.
3. Leave the current arrival calls as they are (`_show_empty_chair(true)` before `int_walk`, `_show_empty_chair(false)` in `_settle_arrive_chair()`). Also hide it at the start of `_play_sit()` (before `hero_sit_f0`), not only after the sit, so it never doubles under the sit frames. Where the rock is shown directly (`_on_door()`), call `_show_empty_chair(false)` too.
4. **Remove the placeholder**: delete `assets/dungeon/home/hero_chair_empty.png` (and its `.import`) from the repo, and remove its row from SIZES.md if it has one.
5. Optional settle: add an `AnimatedSprite2D` or `SpriteFrames` anim `settle` = `chair_settle_f0..f3`, not looping, at (40,820). Play it when the goblin gets out of the chair, then show `chair_empty`.

## Palette

The chair wood ramp is #c8925a / #a87448 / #74502e / #4a3020, plus #4e4028 under the seat. The cushion is #8a2e2a with #5c2626 at its front end. The outline is #100e0c. All of these come from the hero/chair generator palette (`home_hero.HP`). #5c2626 never shows in the shipped hero frames, because the goblin always covers the cushion end. It is the cabin rug's dark red (`home_bg` rug fill, `cab_rooms.rug`).
