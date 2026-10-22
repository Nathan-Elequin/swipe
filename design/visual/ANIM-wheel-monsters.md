# ANIM: Wheel monsters (frameless sprites, compact name tag + medallion on top, flanking badges, idles)

**Decision (2026-10-20, Nathan):**
- **Layout B4.** A plain compact upright name tag sits under each monster. The tag is not notched or folded; it keeps its full straight top border.
- The ability **medallion** sits **in front of** the tag, centred, overlapping the tag's top edge by about 30% of the medallion's height. Its top also overlaps the feet a little.
- **Z-order:** tag < medallion < HP/ATK badges.
- **HP heart left, ATK star right.**
- The full ability text lives on a **card shown while holding Shift**. It must not cover the facing callout, the monster deck, Take, or hub hearts. Hover and facing no longer open that card.
- **Sprites:** 24 native px displayed at **2x (48px)**. Existing 24px wheel art is not redrawn. (Was 4x/96px in the 2026-10-20 B4 lock; Nathan 2026-10-21: too large on the live wheel.)
- **Seat count:** every rule works for **any seat count from 4 to 8** (the wheel may move from 8 seats to 6; not locked).

**Mockups** (in `mockups/layouts/crest/`):

| File | Shows |
|---|---|
| `layout_B4_8.png` | B4 with 8 seats; the upper-left Commander is hovered, so its card is open |
| `layout_B4_6.png` | B4 with 6 seats; the left Commander is hovered |
| `crest_closeup_B3_vs_B4_2x.png` | 2x close-up: B3 (notched tag, superseded) vs B4 |
| `_fit_B4_4.png`, `_fit_B4_5.png`, `_fit_B4_7.png` | fit checks at 4, 5 and 7 seats |
| `layout_B3_top_medallion_*.png`, `crest_B3_contact_sheet.png` | superseded B3, for history only |

The mockups use a DejaVu Bold stand-in. In-engine, use Godot's fallback font (`tokens.json` "font": "fallback").

## Current vs proposed (from `scripts/boss_wheel.gd`)

| Element | Today | Proposed |
|---|---|---|
| Portrait | `_spoke()` (~L1019): `win` 64 (facing 70), −6 when ≥6 slices, capped by `r*span*0.70`. `plate_r = win*0.52`. `_draw_portrait_window` (~L1572) fits the sprite into ≈47–56px at a non-integer scale. | **96px tall**: 24 native at an integer 4x, feet on the bottom row |
| Frame | `_draw_tier_plate` (~L1536) | **None.** The sprite stands on a floor shadow. Rank reads from the slice fill and rim colour only. |
| Name + ability | `_draw_slice_title` (~L1701): dark capsule with name and call text on the rim (screen-upright today) | **Compact name tag** (name only, always horizontal) plus an **ability medallion** layered in front of its top edge. The full text is on the **hover/facing card**. |
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
3. **Tag** (3x Nearest): the plain compact tag, a 9-slice of `name_tag.png` with 5px native corners.
   - No notch; the full straight top border is kept.
   - 16 native tall (48px). Width `max(36, ceil((name_px + 40)/3))` native (≥108px).
   - Top at `F.y + 30`.
   - **Name:** centred at `F.y + 60` (12px below the medallion's bottom edge, so the medallion never covers it). 15px, `ink_on_dark` with a 3px `#100e0c` outline.
     - Keep the duplicate-name and Commander "· used" rules.
4. **Medallion** (3x Nearest), drawn **after the tag**, so it is in front:
   - 20×20 native (60px): an 18px coin plus a 1px `#1c1814` separation rim.
   - Centred horizontally on F. Rim top at `F.y − 12`, bottom at `F.y + 48`.
   - It overlaps the tag's top edge by 18px (30% of its height) and the feet and shadow by 12px.
     - Silenced: the medallion dims to α0.45 and the card's call line reads `Silenced` (Jam string).
5. **Badges:**
   - HP heart centre at `F + (−(w/2 + 24), −20)`; ATK star centre at `F + (+(w/2 + 24), −20)`, where `w` is the sprite width in px.
   - Size 48px (16 native at 3x); number 26px bold.
   - Drawn last, so they sit above the medallion.
6. **Multi-hit tag:** `×2` / `↻` / `∞` at the ATK badge's lower-right, `atk + (20, 22)`, using the pass 1 shared helper.

Block extents relative to F, used by the fit search:
- sprite rect `(−w/2, −h, w/2, 0)`
- badge row `(−(w/2 + 48), −44, w/2 + 48, 4)`
- tag `(−tag_w/2, 30, tag_w/2, 78)`

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
| 7 | 18.3px |
| 6 | 26.2px |
| 5 | 26.7px |
| 4 | 30.4px |

  No overlaps at any seat count.
- If any seat's clearance goes negative (for example a 28-native-tall sprite at 8 seats), shrink only that seat's tag font to 13px and retry. If it is still negative, log a warning; never scale the art.

### Ability card (Shift only)
- **Trigger:** holding Shift. Not hover. Not automatically for the faced seat (the right-hand callout covers facing).
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
| `medal` | the medallion centre, `(feet.x, feet.y + 18)` |
| `sprite_rect` | the sprite rect |

- Drop `_clamp_to_rim` and the `name_tilt` / outer-band nameplate maths entirely.
- Keep `plate_r` = 48 for old callers (glow rings, the kill X).
- New helper `_fit_table(n) -> Array[Vector2]`, cached in `_fit_cache[n]` and cleared in `set_slices` when the size changes.

**Drawing (`_draw_slice_contents`, ~L1450):**
- Remove the `_draw_tier_plate` call.
- Replace `_draw_portrait_window` with `_draw_wheel_sprite(i, sp, s, dim)`: shadow, outline, frame.
- Then `_draw_name_tag(i, sp, s)`: tag, then name, then the medallion on top. Then the badges. Per-seat z-order: shadow < sprite < tag < medallion < HP/ATK badges.
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

**Frames and timing:**
- `set_portraits(d)` (~L492) stays for stills. Add `set_wheel_frames(d: Dictionary)` = `{id: [f0, f1]}`, loaded by `dungeon_art.gd` (new `monster_wheel_frames(id)`).
- Breathe in `_process` (~L865, `_glow_t`): `frame = int(_glow_t / 0.6 + i * 0.37) % 2`, so 600ms per frame and slices never sync.
- If a monster has no breathe frames, fall back to a 1-native-px (4px) bob on the same clock.
- Hit areas: `slice_avoid_global(i)` (~L1065) must include `sprite_rect`, the badges and the plate, so tooltips don't cover them.

**Facing pop-out (`scripts/combat_stage.gd`):**
- `show_monster(id, tier)` (~L73) loads `art.monster_facing_idle(id)` (new; falls back to `monster_idle`).
- `_place_sprite` (~L307): integer 4x of the 48 or 64 canvas.
- Idle at 4–6 frames @ 140ms. The bob stays off when real frames exist.

## Assets (per monster; PNG, Nearest, no mipmaps, Lossless; palette per the monster's existing sprite)

| File | Native | Frames | Type |
|---|---|---|---|
| `assets/dungeon/anim/wheel/<id>_wheel_base.png` | 24×24 (tall monsters ≤24×28; feet on the bottom row) | 1 | [PL] new base |
| `assets/dungeon/anim/wheel/<id>_wheel_breathe_f0.png`, `_f1.png` | same as base | 2 | [PL] |
| `assets/dungeon/anim/facing/<id>_facing_idle_f0..f3.png` (or `..f5`) | 48×48 (Weak/Tough) or 64×64 (Deadly / big bodies) | 4–6 | [PL]; base = the slash-portrait base (`dungeon/anim/slash/<id>_slash_base.png`) where the canvas matches, so no extra base gen |

**Roster:** 58 live monsters (`catalog.json` has 59; minus the retired 3-Seeker; includes the Phoenix token; Wizard and Golem included because they still need wheel art).

**Gens:** about 3 per monster (wheel base 1 + breathe 1 + facing idle 1) → **≈174 gens** (≈190 with 10% re-rolls). This is on top of the slash-portrait budget in `ASSETS.md`. The facing idle reuses the slash base, so it saves about 58 base gens versus generating separate bases.

**Placeholders:**
- Today's art is stored at 4x of ~16px natives (e.g. `assets/dungeon/extra/commander.png` is 64×112 = 16×28 native; merchant, eel and vampire ≈ 10–14×15–16).
- Generate each placeholder by downscaling the current still ÷4 to native, then nearest-re-pixelling to 24px tall into the exact final filename, with two identical breathe frames.
- Facing placeholders: the same still re-pixelled to 48px.
- List every placeholder in `assets/dungeon/anim/wheel/PLACEHOLDERS.md`.

**UI pieces (made with PixelLab for the mockups; ship as-is or re-roll). Import at 3x Nearest:**

| File | Native | Notes |
|---|---|---|
| `assets/ui/wheel/name_tag.png` | 32×32 | The plain B tag plate: a 9-slice with 5px corners and no notch, drawn 16 native tall. Mockup source: the PixelLab plate `mockups/layouts/pl/clean/plate9.png`. |
| `assets/ui/wheel/medallion_<icon>.png` | 20×20 | 18px coin, 1px `#1c1814` rim, glyph ≤10 native baked in at 1:1. Mockup sources: `clean/med18_{horn,scales,bolt,fang}.png`. |

**Medallion glyphs:**
- **Phase 1:** one medallion per existing ability-icon key. `main.gd` maps every monster to one of 20 SVG icons (sparkles, link, users, swords, layers, heart, droplet, ban, rotate, mountain, footprints, trending, shield, skull, copy, plus, wand, hammer, sword, palm).
  - That's 20 medallions at 4 per 64×64 PixelLab sheet: ≈5 gens, about 8 with re-rolls.
  - Placeholder: the current SVG rasterised to 10px, centred in a blank medallion.
- **Phase 2 (optional):** bespoke per-ability glyphs, like the mockups' horn, scales, bolt and fang.

## Compatibility with passes 1–5
- **Intent plate (pass 1):** anchor it to the `combat_stage` pop-out. If the stage is hidden, put it on the hub edge facing the slice (`centre + dir * (hub_r + 40)`). This spec supersedes the fallback line in `ANIM-intent-plate.md`. It doesn't depend on which side the ATK badge is on.
- **Aura threads (pass 4):** attach to `sp.feet`, and bow toward the hub (`r ≈ 0.40R`). On 6 or fewer seats the bow can stay at 0.40R.
- **Poison / petrify / hook / hover preview:**
  - Poison badges go at the sprite's top-right.
  - The hook's arc swap moves whole blocks.
  - `set_preview` deltas draw on the 52px badges.
  - The pass 5 hover preview must not open at the same time as the ability card. The item hover wins while an item is held.
- Everything uses the live `hp_global(i)` / `atk_global(i)` anchors, so nothing else depends on badge sides.

## QA (godot-mcp, 1680×1040)
1. **8 seats** (`02_full8.png`) and **6 seats** (`02b_full6.png`): crop each slice boundary. Check:
   - no overlap between neighbouring sprites, tags, medallions or badges
   - no text tilted or upside down on any seat
   - HP heart left and ATK star right everywhere
   - each medallion is in front of its tag's top edge (the tag border stays straight, with no notch) and below the badges
2. **4, 5 and 7 seats** (`02c_n4.png` … `02e_n7.png`): the same checks. Print the fit-table clearances to the log; all must be ≥ 0.
3. **Hover a medallion** (`03_hover.png`): the card opens on the outward side and is clamped. Spin onto a seat: its card shows while facing.
4. **Breathe:** two shots 300ms apart show different frames on different slices.
5. **Spin onto Vampire:** the pop-out is 4x of 48 or 64 with a 4–6f idle. The intent plate is on the pop-out.
6. **Draft reveal** (`bucket_reveal`): the detail line reads call, then `HP N`, then `Attack N`, with the same words and separator.
7. **`text_audit`:** no "Tier"; Silenced shows the exact Jam string.
