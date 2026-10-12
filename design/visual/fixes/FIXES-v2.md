# FIXES v2: draft gate polish, within Nathan's rulings (2026-10-11)

Replaces the withdrawn 0006 / FIXES.md. Built on `origin/main` at 69f4c0a (it includes the compact gate, 65f4541).

**Before:** [draft-gate-before_build.png](draft-gate-before_build.png) (build, Shift held)
**After:** [draft-gate-fixed_v2.png](draft-gate-fixed_v2.png) (same state, Shift held) · Doop frame `MoxzKceh74` on [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX)
**State:** 6 hearts, 0 BLK. Wheel: Golem (seat 0), Goblin (1), Skeleton (2), Wizard (4), Hornet Swarm (6); 3, 5 and 7 are empty. Gate: Medallion, Weak, 3 passes. Hand: Sai, Helmet, Shield, Smoke Bomb, Net.

## What does not change (Nathan's rulings: style guide §10 and the compact-gate merge)
- Gate column rect **(1086, 28, 560×526)**, a 60/40 item/threat split, **no Take button** (clicking the item takes it), and `door.pass` "Leave it (N passes left)" plus pips.
- No rule line, no THE MONSTER / THE LOOT labels, no guard line and no silhouette.
- The ring keeps name and ability capsules (Nunito). Seat stats are heart (HP) on the left and sword (ATK) on the right. Sprite and icon sizes stay as they are (`SPRITE 56`, current icon size).
- Hub: the knight (run frames), the shield with the Block number, and the arc of six hearts, at `HUB_R 58`. No HP numeral in the hub.
- The event log still opens on Shift or a top-right hover and hides when both stop (§10.7).
- Cards are a fixed size (140×210, compact 124). The face is filled with `card_color`. Shift shows the formula on the card (§10.9).
- The hand's position and wrapping are unchanged (§10.6).
- Copy is read by key from PLAYER_COPY. Nothing under `data/` is edited. The word "Tier" never shows.

Each PR ends with a 1680×1040 shot of this state, both with Shift held and without, saved as `design/visual/qa/fix_v2_<pr>_qa.png` (target left, build right).

---

## PR 1 — Log dock
Files: `scripts/ui/authoring_ui.gd` only.

### L1. The log draws below the gate, not over it
**Respects:** §10.7. The Shift/top-right hover trigger and the hide-on-release behaviour stay exactly as they are; only the place it draws moves.
- In `_sync_authoring_chrome()`, change `log_label.position` from (1180, 28) to **(1190, 570)**, at width 456 and height `min(240, 1012 − 570)`. This is the empty area under the gate column (column bottom y 554), to the right of Nib's slot (fix G4).
- Give `log_label` a backing panel: `#140D0A` at 93 % alpha, a 3 px `#7A4E2B` border and 8/12 padding, so it reads as an overlay.
- Keep a clamp against `face_box` (the fight facing callout), but re-aim it: if `face_box` is visible and intersects the dock rect, shorten the dock to end 8 px above `face_box`. If that leaves less than 72 px, move the dock to (32, 640, 460×220) for that fight.
- Leave the triggers alone: `play_log = phase != "title" and (_shift_held or log_hover) and not callout_up`, with the hover zone still `x > 1500, y < 96`.

**Acceptance:**
- [ ] Holding Shift in the gate shows the log in the rect (1190, 570, 456×240), and no log pixel is inside (1086, 28, 560×526).
- [ ] Hovering the top-right corner shows it in the same place. It hides when the mouse leaves and Shift is up.
- [ ] It never overlaps the hand, including a two-row hand: the hand stays at x ≤ 1078, the log at x ≥ 1190.
- [ ] In a fight with the facing callout up, the log never covers the callout.
- [ ] Devtest log button behaviour is unchanged.

---

## PR 2 — Gate column polish
Files: `scripts/draft_gate.gd` (and its scene, if it has one). The column rect stays the same.

Column layout (inner box x 1112–1620, y 40–542):

| Row | y | Notes |
|---|---|---|
| Cue `cue.ask` | 44–80 | Pixelify 700 30, centred, unchanged |
| **Item side (60 %)** | 88–300 | fix G2 |
| **Threat side (40 %)** | 308–448 | fix G1 |
| Leave `door.pass` | 458–508 | unchanged look |
| Pips | 518–526 | unchanged |

### G1. The threat side is a clear tier-coloured plate
**Respects:** the compact gate ("wheel-tier severity", "Deadly reads as a big red-glow block") and §10.4 (Weak/Tough/Deadly, never "Tier"). No label, guard line or silhouette is added.
- Plate 508×140. Fill `UX.metal_wedge(t)`, a 6 px rim in `UX.metal(t)` and a 3 px inner line in oak `#3B2618`.
- The tier word comes from `tier.N.name`: Pixelify 700 52 in `UX.metal_ink(t)` with a 4 px oak drop, centred.
- Under it, **three severity pips** (22×10 with a 2 px soot border, 10 px apart). t of them are filled ATK red `#D5443B`; the rest are oak. These are a shape cue only, not text.
- Deadly keeps the existing red outer glow. Weak and Tough have no glow.

**Acceptance:**
- [ ] Weak, Tough and Deadly each show their own fill and rim (bronze, silver, gold), plus 1, 2 or 3 red pips. Check all three.
- [ ] The empty dark strip with the small floating "WEAK" is gone. The tier word is at least 48 px tall and centred in the plate.
- [ ] The text is only `tier.N.name`, never "Tier".

### G2. Gold glow on the item side; the card fits
**Respects:** click-the-item-to-take (no button added), the 60/40 split and the fixed card size.
- Item cell 508×212: fill `#2C1D10`, a 4 px gold `#FFD84A` border, and `assets/vfx/vfx_glow_gold.png` (720×600) centred on the card and **clipped to the cell**, behind the card. Optional: pulse alpha 0.8 ↔ 1.0 over 1.2 s.
- The item card is centred in the cell with **6 px clear on every side**: 136×192 at (1298, 98). It's the gate's compact card. Show the formula only while Shift is held, using the card rules in fix H1. Add a 2 px gold outline on hover or focus.
- The whole cell stays the click target for take, as it is now.

**Acceptance:**
- [ ] The card never touches or crosses the cell border, and nothing inside it overflows the card.
- [ ] The glow shows only inside the item cell, never over the threat plate, Leave or the cue.
- [ ] Clicking the card or the cell takes the item.

### G4. Nib's deliberate slot (and the dead space under the column)
**Respects:** the column size, which isn't changed. Nib isn't added to the column.
- Remove the stray Nib at the bottom left.
- Nib goes in an 88×88 well at **(1086, 570)**, directly under the gate column and aligned with its left edge: void `#0B0706` fill, 6 px imp green `#7BC950` border, Nib 16×16 drawn at 64 px.
  - Reactions: `nib_smug` while the item is hovered; idle frames otherwise.
  - Show it in the draft gate and placement; hide it in a fight, where the facing callout owns the right side.
- That whole area under the column (x 1086–1646, y 566–1012) is reserved for Nib (left) and the log dock (right, fix L1). Nothing else goes there.

**Acceptance:**
- [ ] Nib appears only in this well (or the How to Play talk box), never stranded by the hand.
- [ ] The well and the log dock don't overlap each other, the column or the hand.

---

## PR 3 — Hand card text fit
Files: `scripts/item_card.gd` (and `hand_card.tscn`, if it's used).

### H1. Text always fits in the fixed card; the formula only on Shift
**Respects:** §10.5 (`card_color` fill), §10.9 (short Nunito 18 titles; Shift shows the formula on the card with space between the number and the words; stat icons stay the same size) and the fixed card size (140×210 / 124×210).
- Fixed vertical budget inside the 6 px rim, from the top:
  - 8 pad
  - title 26 (Nunito 18, one line)
  - 4 gap
  - icon 64
  - 4 gap
  - number row 36
  - **6 gap**
  - **formula box 54**
  - 8 pad
  
  That adds up to exactly 210. The card doesn't grow.
- **Without Shift:** title, icon and number only. The formula box is empty, with no explainer text, fractions or "(4)" leftovers under the number.
- **With Shift:** the number stays in its row and the formula (`_pretty_formula`) goes in the 116×54 formula box below it. Autowrap, centred, max 3 lines. Fit by stepping the font down 13 → 12 → 11. If it still doesn't fit at 11, clip with an ellipsis. Don't put the formula in the number slot any more.
- **Cards with no number** (Smoke Bomb, `card_color: smoke`): the number row and formula box merge into one 96 px box. It shows the ability text, on Shift or always as now, at Nunito 15, max 4 lines, using the same fit rule.

**Acceptance:**
- [ ] With Shift held on Sai, Helmet, Shield, Smoke Bomb, Net and Medallion, no glyph crosses the icon, the number row or the card rim. The Helmet text "(the lower of YOUR HP and ENEMY HP)" fits on 2 lines at ≤ 12 px.
- [ ] Without Shift, the cards show only the title, icon and number.
- [ ] Card size never changes between Shift and no Shift (140×210, compact 124×210). The face is still filled with `card_color`.
- [ ] There's at least 6 px between the number and the formula.

---

## PR 4 — Wheel seats and alcoves
Files: `scripts/boss_wheel.gd`, plus the textures copied into `assets/ui/wheel/`.

### W1. Ring capsules and stats stop colliding with sprites
**Respects:** §10.2 (heart left, sword right, current sizes), §10.3 (name + ability capsules under the monster, in Nunito), §10.4 and "sprites stay shrunk" (`SPRITE 56`).
- Lay each seat out as one **upright stack centred on the seat point** (`port`, r 188), instead of pushing the capsule out along the spoke (the current `nam_r` places it radially, so on side seats it sits on top of the sprite).
  1. Sprite 56×56. Its top is `port.y − stack_h/2`, where stack_h = 56 + 6 + capsule height.
  2. The **HP heart** sits **beside** the sprite on the left (right edge 2 px from the sprite), and the **ATK sword** sits beside it on the right, both 30 px below the sprite top. Their sizes stay the same, and neither overlaps the sprite.
  3. The **capsule** sits 6 px under the sprite, centred on `port.x`: name, plus the call name on a second line if it has one. Nunito, `UI.SIZE_MIN`, max width 112. The current tier fill and rim are kept.
  4. Hornet's "×2" badge sits above the sword icon, not on the sprite.
- `_fit_title_rect` can still clamp to the rim and hub, but it must move the **whole stack** together.
- With 9 or more slices (`crowded`), keep this order and let the capsule use one line (the call name is dropped, as it is now).

**Acceptance:**
- [ ] For every seat in this state, there's no overlap between the sprite, heart, sword, capsule or "×2", or with any other seat. Check that the bounding boxes don't intersect.
- [ ] The heart is left and the sword is right on every seat, including side and diagonal seats.
- [ ] The capsule is always directly under its own sprite and stays inside the alcove.

### W2. Alcove textures that fit the r 58 hub
**Respects:** `HUB_R 58` and §10.4 (Weak/Tough/Deadly as both alcove fill and rim).
- Copy `design/visual/fixes/assets/ui/wheel/*.png` into `assets/ui/wheel/`. They're 232×248, with the wedge running r 58 → 300. See that folder's README.
- In `_build_alcoves()`:
  - Set `tr.size` and `custom_minimum_size` to (232, 248).
  - Remove the `_use_alcove_tex = false` override, and enable textures **only when `slices.size() == 8`**. Otherwise keep the current metal polygons.
- In `_alcove_tex_for()`, a seated monster uses `ui_wheel_alcove_full_{weak,tough,deadly}.png` by `_plate_tier()`. Empty, placement-valid and hover use their own files.
- In `_sync_alcoves()`, stop tinting seated alcoves with `metal_wedge`, because the texture already carries the tier. Keep the alpha (fight dim, placement pulse) and the facing `lightened(0.10)`.

**Acceptance:**
- [ ] On an 8-seat wheel there's no gap between the hub rim and the alcoves, and the seam lines meet the hub.
- [ ] Weak, Tough and Deadly seats show bronze, silver and gold fill and rim.
- [ ] Wheels with any other slice count render exactly as they do now.

---

## Notes (not in scope)
- The hand row in the build is centred on about x 686, not the locked x 547. This pass leaves the hand alone (§10.6). Flagging it in case it isn't intended.
- The knight and the hub are untouched per the rulings. The knight is still the off-palette 0x72 sprite.
