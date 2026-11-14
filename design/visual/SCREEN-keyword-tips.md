# SCREEN — Keyword tips, Direction A (locked)

Owner: Pixel · Status: mockups ready for review · Canvas: https://doop.design/c/ucdMP01o9E
Viewport: 1680×1040 (design reference size). All rects below are in that space; scale with the root viewport like the rest of the HUD.

Scope:
1. Keyword chips in every text surface: hotbar item plate, monster plate, combat log, tutorial talk box, and wheel pips.
2. One parchment **keyword card** that replaces three tips: the gold capsule, the combat-log hint panel, and the Rust/Phoenix mini-plate callouts.
3. First-sighting teach.
4. Pin state.

Copy rule: the card body is `KeywordDefs.def_of(id)`, rendered **verbatim**. The title is `id.capitalize()`, the same as the live `keyword_tip.gd`. No new strings anywhere. The first-sighting cue is animation and icon only.

---

## 1. Chip (inline keyword in RichTextLabel)

**Anatomy:** 24×24 icon (12px native ×2) + 4px gap + word in its keyword ink + 2px underline at 45% alpha.

**BBCode** (built in `UxStyle.with_def_link`, replacing the current paint):

```
[url=kw:<id> underline=never][img=24x24 valign=center,center]res://assets/ui/keyword/kw_<id>.png[/img] [u color=<ink>73][color=<ink>]<Word>[/color][/u][/url]
```

**Inks:**
- Dark surfaces: reuse `_stem_hex`, i.e. gold `#E8C36A`, defeat family `#C9A0FF`, unplayable `#C8C2BA`.
- Talk paper (panel_beige): gold `#6A3C00`, defeat `#4E1C86`, unplayable `#5A564E`. These are the tutorial's existing paper inks.
- Coloured stats (Attack `#E07A7A`, HP `#E8A0A0`) stay plain coloured text. They are **not** chips because they are not `def_of()` ids.

**States:** `meta_hover_started` / `meta_hover_ended` re-render only that run.

| State | Background | Underline | Extra |
|---|---|---|---|
| rest | none | ink @45% | none |
| hover | `[bgcolor=#E8C36A2E]` (18%) | ink @100% | cursor = pointing hand |
| pinned | `[bgcolor=#E8C36A42]` (26%) | ink @100% | none |
| first sighting | `kw_chip_halo_9` NinePatchRect behind the run (margins 6) | ink @100% | 3 gold pulses, §4 |

The first-sighting halo needs a rect. Get it from `RichTextLabel` via a `[hint]`-free approach: tag the run with `[url]` and use `get_character_bounds`. If that is unavailable in the 4.7 build, use the Label's custom `_draw` with the cached glyph rect from `RichTextLabel.get_line_range`/offset helpers. Fallback: pulse the whole line's background.

**Where chips render:** wherever `with_def_link` already runs (item plate, monster plate body, combat log `_link_kws`), plus:
- **Tutorial talk box** (`tutorial_guide.gd`): the body Label becomes a RichTextLabel with `bbcode_enabled`, `fit_content`, the same 20px font, and paper inks. It wires `wire_def_hover` on the label and leaves the `(click …)` hint plain.
- **Wheel poison pips** (and any future drawn pips): add a 28×28 `Control` hit-rect centered on each drawn pip (`mouse_filter = STOP`). On hover, show `kw_pip_ring` (28px) over the pip and open the card on the side rail (§3).

**Nested keywords inside a card body:** bold `#7A4E2B`, **not** hoverable (no chaining in v1).

## 2. Keyword card (one node, replaces the three variants)

Scene: `scenes/ui/keyword_card.tscn`. Script: `keyword_card.gd`, the successor of `keyword_tip.gd`. It keeps the public API `show_def_at(rect)`, `show_def_at_cursor()`, `pin_def(id)`, `hide_def()`.

```
KeywordCard (PanelContainer, top_level=true, z_index=141, mouse_filter=PASS)
  theme_override_styles/panel = StyleBoxTexture
      texture = res://assets/ui/trophy/parchment_tag.png   (reuse; 96×96)
      texture_margin_* = 24, content_margin L20 T16 R20 B22
      axis_stretch = TILE_FIT, filter = Nearest
  Shadow (NinePatchRect, same texture, modulate #000000 @45%, offset +4y, show_behind_parent)
  VBox (separation 10)
    Head (HBox, separation 10)
      Icon (TextureRect 48×48, kw_<id>_card.png, stretch KEEP, Nearest)
      Name (Label, Open Sans Bold 20/26, #4A2F1F)
    Rule (ColorRect h=2, #C9B183)
    Def  (RichTextLabel, Open Sans SemiBold 17/23, #4A2F1F, autowrap word, fit_content)
  Seal (TextureRect kw_card_seal.png 40×40, position (-12,-12) outside top-left, hidden unless pinned)
  Star (TextureRect new_star.png 28×28, position (w-24,-4), hidden unless first-sighting)
```

- Width is fixed at **296**. Height is auto (min 96). Poison (the longest def) measures about 296×256.
- Title is `id.capitalize()`, e.g. `Bear Trap`. Never "Tier"/"ATK" labels; plate rank words stay Weak/Tough/Deadly.

**Remove:**
- the `keyword_tip.gd` gold capsule StyleBoxFlat and its 280×80 min size
- the `combat_log.gd` private hint panel (z130), which now calls the shared card
- `show_callout` mini-plate callouts (Rust/Phoenix), which now open the shared card with the same id
- `keyword.always_body`, so the card uses `def_of(always)` verbatim (see copy flags)

## 3. Dock rules: the card never covers the wheel

**Computed every open** from live rects (`Wheel.get_global_rect()`, plate rect, hotbar rect):

- `KEEP_OUT = wheel circle bounding rect grown by 16`.
- `RAIL_X = max(KEEP_OUT.end.x, hotbar.end.x) + 24`. The right rail is `x ∈ [RAIL_X, 1656]`, `y ∈ [24, 1016]`.
- `LOG_RAIL = Rect2(24, 24, 296, 992)`, for log hint cards only.
- The card rect is clamped to `Rect2(24,24,1632,992)`. Assert in debug builds that it does not intersect `KEEP_OUT`.

| Source | Placement (first fit wins) |
|---|---|
| Monster plate chip | (a) below the plate: `x = plate.end.x - 296`, `y = plate.end.y + 8`. (b) above the plate: `y = plate.y - 8 - h`. (c) rail top `y = 24`. |
| Hotbar item plate chip | (a) right of the plate: `x = plate.end.x + 12`, `y = plate.y`. (b) left: `x = plate.x - 12 - 296`. The card may overlap other hotbar cards but never the wheel. |
| Wheel pip | Monster plate suppressed while the pip is hovered. Card on the rail: `x = RAIL_X`, `y = clamp(pip.y - 40, 24, 1016 - h)`. Dotted leader from the pip's right edge to the card's left edge mid-head (Line2D, `kw_leader_dot.png`, texture_mode TILE, width 2, `#E8C36A`). |
| Combat log chip | `x = 24`, `y = line.end.y + 6` (the line's global rect bottom). If that overflows, `y = line.y - 6 - h`. |
| Tutorial talk box chip | Card added to a CanvasLayer **21** (talk box is layer 20 / z190). `x = talk.x + 124`, `y = talk.end.y + 12`. If that overflows the bottom, go above the talk box. |

**Reference rects (1680×1040):**

| Layout | Wheel center / r | KEEP_OUT | Right rail | Example card |
|---|---|---|---|---|
| 4 monsters (F4, F6, F8, F9) | (848,407) / 364 | (468,27)–(1228,787) | x 1252–1656 | Poison pip card (1252, 368, 296×256) |
| 8 monsters (F2, F5) | (840,469) / 456 | (368,-3)–(1312,941) | x 1336–1656 | Poison card (1336, 352) |
| Busy, compact wheel (F7) | (840,316) / 290 | (534,10)–(1146,622) | x 1225–1656 (hotbar ends 1201) | Phantom plate (1316,140,340w), Shroud card (1360, plate.end.y+8) |

Mock coordinates in the frames are hand placed. Where they differ by a few px from the formulas, the formulas win.

## 4. First-sighting teach

**Persistence:** `SaveData.seen_keywords: Array[String]`, per save slot, default `[]`. Keep it in the meta save so it survives runs.

**Trigger:** the first time a chip or pip for `id ∉ seen_keywords` becomes visible on screen. At most one teach at a time; queue the rest in order of appearance.

**Sequence (Tween):**
1. The chip halo and the pip's `pulse_ring` (AnimatedSprite2D, `pulse_ring_sheet.png`, 4 frames, 160px scaled to 64) play **3 pulses × 0.45 s**. Each pulse is halo modulate.a 0→1→0 and ring scale 0.6→1.0 with alpha 1→0.
2. At the end of pulse 1 (t = 0.45 s), the card auto-opens: fade 0→1 and slide 6px over 0.18 s, `TRANS_QUAD`/`EASE_OUT`, at its dock position from §3.
3. The `new_star` pops: scale 0→1.2→1.0 over 0.25 s, then stays.
4. **Dismiss on the next player action:** any Spin/Use/Take/Move input, or any click outside the card. Close is 0.08 s. Append `id` to `seen_keywords` **on dismiss**, not on show, so a teach that gets interrupted retries.
5. After that the keyword is hover-only: no halo, no star, no auto-open.

The teach does not block input; the action that dismisses it still goes through.

## 5. Hover and pin

- **Hover open:** 0.15 s delay, then 0.12 s fade plus a 6px slide from the dock direction. Close 0.08 s after the pointer leaves **both** the chip and the card (the card is hover-safe so you can move into it).
- **Pin:** click the chip (existing `_on_def_click` → `pin_def`). The seal appears with a 0.12 s scale-in (0→1.15→1), the chip takes the pinned tint, and the card stays while the pointer roams.
- **Unpin:** click the chip again, click the seal, press Esc, or close the owning plate. Only one card exists: pinning B while A is pinned replaces A.
- While a card is pinned, hovering another chip shows nothing (no stacking). Open question 3 proposes otherwise.

## 6. Z-order

| Layer | z |
|---|---|
| combat log panel | 130 (unchanged) |
| plates | existing |
| KeywordCard | 141 top_level (same slot as the old capsule) |
| tutorial talk box | CanvasLayer 20 / z190 |
| KeywordCard spawned from talk box | CanvasLayer 21 |
| pip hit-rects | child of wheel, z above pips, mouse STOP |

---

## 7. Asset list / export spec

**Common to all assets:**
- PNG RGBA, import `filter = Nearest`, `mipmaps off`, `compress lossless`.
- Native art is drawn at 1× in `/workspace/kw-tips/native/ui/keyword/` and baked with integer Nearest upscales into `assets/ui/keyword/`.
- 1px outline `#100e0c`, no anti-aliasing, WIRING palette.

| Path | Size | Scale | Use | Status |
|---|---|---|---|---|
| `assets/ui/keyword/kw_<id>.png` ×23 | 24×24 | 12 native ×2 | chip icon `[img=24x24]` | 22 new, `kw_decay` from `aura/decay_pip.png` (padded 10→12) |
| `assets/ui/keyword/kw_<id>_card.png` ×23 | 48×48 | 12 native ×4 | card head icon | baked from the same native |
| `assets/ui/keyword/kw_card_seal.png` | 40×40 | 10 native ×4 | pinned wax seal | new |
| `assets/ui/keyword/kw_chip_halo_9.png` | 16×16 | 8 native ×2 | first-sighting chip halo, NinePatch margins **6** | new |
| `assets/ui/keyword/kw_pip_ring.png` | 28×28 | 14 native ×2 | pip hover ring | new |
| `assets/ui/keyword/kw_leader_dot.png` | 4×2 | 2×1 native ×2 | Line2D TILE leader | new |
| `assets/ui/trophy/parchment_tag.png` | 96×96 | n/a | card StyleBoxTexture, 9-slice margins **24** | reused |
| `assets/ui/hud/new_star.png` | 28×28 | n/a | first-sighting corner | reused |
| `assets/ui/trophy/pulse_ring_sheet.png` | 640×160 (4×160) | n/a | pip pulse, AnimatedSprite2D | reused |
| `assets/dungeon/ui/panel_beige.png` | n/a | n/a | talk box (unchanged) | reused |

**The 23 ids:** any, eject, across, bear_trap, move, flee, defeated, marked, poison, spin, always, swap, loaded, unplayable, rust, decay, gaze, petrify, curse, shroud, toll, hex, beggar.

**Box paths:**
- Deliverables: `/workspace/kw-tips/assets/ui/keyword/`.
- Native sources: `/workspace/kw-tips/native/ui/keyword/`.
- Reused copies, for reference only and not to be re-imported: `/workspace/kw-tips/assets/_reused/`.
- Generators: `/workspace/kw-tips/src/icons.py`, `/workspace/kw-tips/src/assets.py`.

## 8. Frames

F1 style sheet · F2 hotbar item hover · F3 monster plate + Flee · F4 poison pip → rail · F5 first sighting · F6 tutorial talk box · F7 busy fight / keep-out proof · F8 combat log · F9 hover vs pinned.

Exports are in `/workspace/kw-tips/frames/F1..F9.png`. The contact sheet is `/workspace/kw-tips/contact.png`.

F7 uses the existing 8-monster capture, not 6: no clean 6-monster shot was available, and 8 is the harder case.
