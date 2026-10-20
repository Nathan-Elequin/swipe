# ART-REQUEST — wheel hub + squircles (2026-10-20)

Pixel owns PNG bytes. Cursor does not draw or replace these files. This is the doorbell spec.

Combat layout is already moving in engine (bigger wheel, hearts on an inner arc, Block under the hero). These PNGs replace the code stand-ins.

## Locked player choices (Nathan, 2026-10-20)

- Grow the wheel until it almost fills the brick: cue bar, inspect plate, hotbar. Not a 30% formula.
- Hero sprite stays **96×96**. Do not stretch him.
- Six heart slots on an arc over his head, hugging the **inner rim** of the hub hole. Empty hearts for missing HP.
- Delete the top-left heart row and the numbered HP badge at his feet.
- Block shield **centered under** him. Empty shield art when Block is 0. Number stays on the shield.
- Hex / star / circle plates become **squircles** (rounded squares). You draw three PNG frames. You pick fill and the exact brown / blue / deep red. Gold is not required on Tier 3.
- Same squircle family on: wheel portraits, inspect portrait (Dragon plate), draft-gate plates.
- Dungeon Deck gets its **own** playing-card treatment (not a reused wheel squircle).
- Call names stay visible on every slice, including 6-monster wheels.

## 1. Squircle frames (three PNGs)

Replace every hex / star / circle monster plate.

| id | path | tier | outline family |
|---|---|---|---|
| `ui_squircle_t1` | `assets/ui/wheel/squircle_t1.png` | 1 / Weak | saturated **brown** |
| `ui_squircle_t2` | `assets/ui/wheel/squircle_t2.png` | 2 / Tough | saturated **blue** |
| `ui_squircle_t3` | `assets/ui/wheel/squircle_t3.png` | 3 / Deadly | saturated **deep red** |

- Native: **32×32**. Shipped: 4× nearest (**128×128**).
- Frames / loop: still. One image per tier.
- Pivot: centre.
- 9-slice optional. If you 9-slice, put margins in a note next to the PNG. Engine will scale the whole texture to the plate if you do not.
- Must read as a **rounded square**, not a circle, not a hex, not a star.
- You choose fill vs outline-only, and the exact hexes. Do not keep today’s gold T3 rim unless you want a tiny hint.
- Same three files are wired to inspect and the draft gate. Inspect is a larger plate (~192×160). If that stretch looks cheap, add matching inspect files at `assets/ui/inspect/squircle_t1.png` (and t2 / t3), same rules, native sized to that plate.

## 2. Hub hearts (individual tiles, not a baked arc)

Cursor places six of these on an arc that follows the inner hub rim. A single 6-heart strip would break when the hole grows with the wheel, or if max HP ever leaves 6.

| id | path | state |
|---|---|---|
| `ui_hub_heart` | `assets/ui/hub/heart_full.png` | live HP |
| `ui_hub_heart_empty` | `assets/ui/hub/heart_empty.png` | missing HP |

- Native: **16×16**. Shipped: 4× nearest (**64×64**).
- Frames / loop: still.
- Must read as a heart at hub scale, clear against the dark hub well and the 96×96 hero.
- Empty must still read as a heart (slot), not a blank.
- Engine already tints: white (live), red (incoming hit), green (poison about to tick), dim (empty). Keep the art readable under those tints.

Until these land, engine uses the existing `ui_heart_full` / `ui_heart_empty` tiles on that arc.

## 3. Dungeon Deck — playing card

The face-down Challenge deck to the right of the wheel. Nathan: it may need its own custom design so it looks like a playing card, not a wheel plate.

| id | path |
|---|---|
| `ui_dungeon_deck_card` | `assets/ui/deck/playing_card.png` |

- Native: about **32×44** (card ratio). Shipped: 4× nearest.
- Frames / loop: still. Extra frames OK for a small stack if you want (f0 back, f1 top).
- Must read as a **playing-card back**, dungeon palette, not a crate and not a wheel squircle.
- Leave room on the lower third for the next-monster name caption the engine already draws.
- Screenshot: Adventure combat, deck on the right of the wheel.

Do not copy the wheel squircle here.

## 4. Block shield

Existing hub badges stay:

- `assets/dungeon/hero_run/badge_blk.png`
- `badge_blk_empty.png`
- `badge_blk_up.png`
- `badge_blk_pierced.png`

Engine now draws the shield **under** the hero, centred. Number still sits on it. If the heater shape looks off-centre in that new seat, nudge the PNG (keep 44×48 shipped) rather than asking Cursor to invent a new shield.

## 5. What Cursor will not draw

- No new PNG bytes.
- Code stand-in: rounded-square plates in today’s bronze / silver / gold metals until your files exist at the paths above. Engine swaps to your PNG the moment the `.import` is valid.
- Hero stays the current 96×96 run sprite.

## Wiring (after you drop files)

1. Put PNGs at the paths in this file. Nearest, lossless, no mipmaps.
2. Ping Cursor / commit. Cursor wires `ITEM`/`UI` loads, does not redraw.
3. Do not reuse another card’s pixels.

## Screenshot of the current problem

Playtest combat: small 640-capped wheel, six hearts in the top-left, hex/star/circle plates, inspect Dragon on the right. Nathan’s shot from 2026-10-20.
