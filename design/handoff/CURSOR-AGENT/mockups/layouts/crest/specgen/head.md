# ANIM: Wheel monsters (frameless sprites, compact name tag + top medallion, flanking badges, idles)

**Decision (2026-10-20, Nathan):**
- **Layout B3.** A compact upright name tag sits under each monster.
- The ability **medallion** is notched into the tag's **top** border, centred, and overlaps the feet a little.
- **HP heart left, ATK star right.**
- The full ability text lives on a **card shown on hover or when facing**.
- **Sprites:** 24 native px at 4x (96px).
- **Seat count:** every rule works for **any seat count from 4 to 8** (the wheel may move from 8 seats to 6; not locked).

**Mockups** (in `mockups/layouts/crest/`):

| File | Shows |
|---|---|
| `layout_B3_top_medallion_8.png` | B3 with 8 seats; the upper-left Commander is hovered, so its card is open |
| `layout_B3_top_medallion_6.png` | B3 with 6 seats; the left Commander is hovered |
| `crest_closeup_B1_vs_B3_2x.png` | 2x close-up of one tag: B1 (crest under the tag) vs B3 |
| `crest_B3_contact_sheet.png` | B1, B3 at 8 seats, B3 at 6 seats |
| `_fit_B3_4.png`, `_fit_B3_5.png`, `_fit_B3_7.png` | fit checks at 4, 5 and 7 seats |

The mockups use a DejaVu Bold stand-in. In-engine, use Godot's fallback font (`tokens.json` "font": "fallback").

## Current vs proposed (from `scripts/boss_wheel.gd`)

| Element | Today | Proposed |
|---|---|---|
| Portrait | `_spoke()` (~L1019): `win` 64 (facing 70), −6 when ≥6 slices, capped by `r*span*0.70`. `plate_r = win*0.52`. `_draw_portrait_window` (~L1572) fits the sprite into ≈47–56px at a non-integer scale. | **96px tall**: 24 native at an integer 4x, feet on the bottom row |
| Frame | `_draw_tier_plate` (~L1536) | **None.** The sprite stands on a floor shadow. Rank reads from the slice fill and rim colour only. |
| Name + ability | `_draw_slice_title` (~L1701): dark capsule with name and call text, tilted with the slice | **Compact name tag** (name only, always horizontal) plus an **ability medallion** in its top notch. The full text is on the **hover/facing card**. |
| ATK / HP | `_draw_atk_stat` / `_draw_heart_stat`. Today `hp = port + tan*spread`, so HP's screen side turns with the slice. | **Fixed screen sides:** HP heart left, ATK star right, radius 26 (52px), number 26px |
| Facing monster | portrait with a gold rim; `combat_stage` sine bob | Pop-out at 48 or 64 native, 4x, with a 4–6f idle. The facing slice also opens the ability card. |
| Idle on the wheel | none | 2-frame breathe, staggered by slice |

## Layout rules (seat count N = `slices.size()`, any value from 4 to 8)

All positions are screen pixels at 1680×1040.
- R is the wheel radius (≈406). The hub radius is ≈139.
- Slice `i` has its mid-angle at `-90° + (i + 0.5) * 360/N` (as `_dir_of`), with a half-span of `180°/N`.

### Upright everything
- No element rotates with the slice: sprite, tag, medallion, badges and text.
- No text is vertical or upside down on any seat, top, side or bottom.

### The block
Each seat draws one block, positioned relative to its **feet point** `F` (sprite bottom centre). Layers are listed bottom to top:
1. **Floor shadow:** ellipse at F, 0.9 × sprite width × 16px, `#0a0604` α0.47.
2. **Sprite:** integer 4x, feet on F. 1 native px outline (4px) in `#100e0c`.
3. **Tag + medallion unit** at 3x Nearest:
   - **Tag:** native height 16 (48px), width `max(40, ceil((name_px + 30)/3))` native, rounded to an even number.
     - It is built as a 3-part horizontal stretch: 4px end caps, a fixed 30px centre holding the top notch, and stretched columns between.
     - The tag top sits at `F.y + 33`.
   - **Medallion:** 20×20 native (an 18px coin plus a 1px `#1c1814` separation rim), centred on the tag's top edge.
     - Its centre is 5 native rows above the tag top, so its rim top is at `F.y − 12`. It overlaps the feet and shadow by 12px.
     - It is drawn above the sprite and below the badges.
   - **Name:** text centred on the tag at `tag_top + 28px`, 15px, `ink_on_dark` with a 3px `#100e0c` outline.
     - Keep the duplicate-name and Commander "· used" rules.
     - Silenced: the medallion dims to α0.45 and the card's call line reads `Silenced` (Jam string).
4. **Badges:**
   - HP heart centre at `F + (−(w/2 + 24), −20)`; ATK star centre at `F + (+(w/2 + 24), −20)`, where `w` is the sprite width in px.
   - Size 48px (16 native at 3x); number 26px bold.
   - Drawn last, so they sit above the medallion.
5. **Multi-hit tag:** `×2` / `↻` / `∞` at the ATK badge's lower-right, `atk + (20, 22)`, using the pass 1 shared helper.

Block extents relative to F, used by the fit search:
- sprite rect `(−w/2, −h, w/2, 0)`
- badge row `(−(w/2 + 48), −44, w/2 + 48, 4)`
- tag `(−tag_w/2, 30, tag_w/2, 81)`

### Placement: fit search, cached per N
For each seat, search for the feet point F:
- Search range:
  - along the mid-angle at `r = 0.40R … 0.86R` (3px steps)
  - with a vertical nudge `dy = −24 … +24` (4px steps)
- **Clearance** for a candidate is the minimum, over the corners and edge midpoints of the three extents above, of:
  - the distance inside the slice's two edge rays
  - `dist − (hub_r + 6)`
  - `(R − 6) − dist`
- Pick the candidate with the largest clearance, rounded to 4px. Break ties by closeness to `0.60R` and the smallest `|dy|`.
- Cache the result per `(N, sprite size)`. Recompute when N changes or a sprite of a different size is seated. Do not search per frame.
- Results in the mockups (worst seat):

| Seats | Worst-seat clearance |
|---|---|
| 8 | 6.4px (lower-left Commander, the tall 26-native placeholder) |
| 7 | 19px |
| 6 | 26px |
| 5 | 27px |
| 4 | 27.5px |

  No overlaps at any seat count.
- If any seat's clearance goes negative (for example a 28-native-tall sprite at 8 seats), shrink only that seat's tag font to 13px and retry. If it is still negative, log a warning; never scale the art.

### Ability card (hover or facing)
- **Trigger:** hovering the medallion or tag, or the seat becoming `facing_index`.
- **Card:**
  - 9-slice plate, 72px tall, width `max(text) + 40`.
  - Line 1: 2x icon plus call name, 16px in `_ability_icon_color`.
  - Line 2: the existing Shift-explainer text (reminder or ability via PLAYER_COPY), 13px, wrapping to 2 lines at 300px.
- **Placement:** on the outward side of the tag, with the card edge 12px from the tag. On top and bottom seats, use the side away from the screen centre.
  - Clamp to the viewport.
  - It must not cover the right panel (x > 1260 at 1680 wide). If it would, flip to the inward side.
- **Highlight:** the hovered medallion gets a 3px gold ring.
- The card replaces the old Shift explainer plate. Holding Shift shows every seat's card when they fit without overlapping; otherwise only the hovered seat's.

## Code hooks (`scripts/boss_wheel.gd` unless noted)

**`_spoke(i)` (~L1019).** Replace the `win` / `plate_r` maths with the cached fit table. Keep `port` as the **sprite centre**, so passes 1–5 keep working. Return:

| Key | Value |
|---|---|
| `feet` | F from the fit table |
| `port` | `feet − (0, h/2)` (sprite centre) |
| `hp` | `feet + (−(w/2 + 24), −20)` (LEFT) |
| `atk` | `feet + (w/2 + 24, −20)` (RIGHT) |
| `tag_rect` | the tag rect |
| `medal` | the medallion centre, `(feet.x, feet.y + 33 − 15)` |
| `sprite_rect` | the sprite rect |

- Drop `_clamp_to_rim` and the `name_tilt` / outer-band nameplate maths entirely.
- Keep `plate_r` = 48 for old callers (glow rings, the kill X).
- New helper `_fit_table(n) -> Array[Vector2]`, cached in `_fit_cache[n]` and cleared in `set_slices` when the size changes.

**Drawing (`_draw_slice_contents`, ~L1450):**
- Remove the `_draw_tier_plate` call.
- Replace `_draw_portrait_window` with `_draw_wheel_sprite(i, sp, s, dim)`: shadow, outline, frame.
- Then `_draw_name_tag(i, sp, s)`: tag, medallion, name. Then the badges.
- Rage fire, fled dust, aura glow and the kill X re-centre on `sprite_rect`.
- The poison badge (`_draw_poison_badge` ~L2033) goes at the sprite's top-right.

**Text and stats:**
- `_draw_slice_title` / `_title_metrics` become `_draw_name_tag`. Name only, never tilted, no `draw_set_transform`.
- `_draw_atk_stat` / `_draw_heart_stat`: radius 26 (punch +4); number 26px.
- `_atk_pos(i)` / `_hp_pos(i)` follow the new keys.
- `slice_avoid_global(i)` includes `sprite_rect`, `tag_rect`, the medallion and both badges.
- New `scripts/ui/ability_card.gd` draws the card. Feed it from `facing_index` changes and the medallion/tag hover.

**Monster detail text (`scripts/bucket_reveal.gd` ~L384–388):**
- Show HP before Attack, as an **order change only**: move the `if str(entry.get("hp", ""))…bits.append("HP %s" …)` block above the `atk` block.
- Keep the exact words (`"Attack %s"`, `"HP %s"`), the call line first, and the existing separator string untouched.

