# SCREEN: Sack peek (NEW items only; from the rope exit and from pause)

Mock: `_pixel_extras/review/mocks/11_sack_peek.png`.

The script is `scripts/cabin/sack_peek.gd` (Control, full rect). It is shown over RopeExit (z 81) or over pause (z 121, inside `settings_ui`'s layer), with `PROCESS_MODE_ALWAYS` because pause pauses the tree.

There is no mid-run return to the cabin. This screen is read-only.

## Node tree
```
SackPeek
├── Veil      TextureRect ui/overlay_vignette.png (click = close)
├── Bag       TextureRect overlays/sack_peek_bg.png at native (30,25)
├── Title     Label sack.title, centred, y (25-2)*4, 40 px cream
├── Slots     10 x Control 32x32 native at bag-local slot positions
│   ├── Glow  TextureRect overlays/sack_slot_glow.png at slot − (2,2)
│   └── Icon  TextureRect item texture (tex_by_item) scaled to 32x32 native, NEAREST
├── Count     Label sack.new_count ({n} = full NEW count) or sack.none, centred, y (25+180)*4
├── Hint      Label sack.hint, y (25+196)*4, 24 px muted
└── Close     choice tag sack.close at native (170,240) 80x16
```
- `overlays/sack_peek_bg.png` at native (30,25,360,210) = 4x (120,100,1440,840)
- Slots (bag-local top-left): [[78, 70], [122, 70], [166, 70], [210, 70], [254, 70], [78, 118], [122, 118], [166, 118], [210, 118], [254, 118]].
- Items: hotbar `card_id`s where `not home_cabin.is_swiped(id)` and not a token; de-duplicated, hand order, at most 10 drawn. The count shows the full number.
- Hover an icon = `fly_tip.show_rule` with the normal combat rule (no journal; the journal is the reward for bringing it home).
- Open: Bag scale 0.9→1.0, 0.18 s BACK OUT, cue `cabin.sack_shake` (short, −6 dB via `play_event` volume). Icons pop in one by one at 50 ms with scale 0→1. Close: cue `cabin.click`.
- Escape closes it (handled first, `set_input_as_handled()`).

**Copy:** `sack.title`, `sack.new_count`, `sack.none`, `sack.hint`, `sack.close`

**Cues:** `cabin.sack_shake`, `cabin.click`, `cabin.hover`

**Code hooks:** `hotbar` (Main), `home_cabin.is_swiped`, `fly_tip.show_rule`, `_item_rule` (9654), `_place_fly` (10086).
