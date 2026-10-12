# Swipe — Visual Style Guide · Direction A "Torchlit Burrow"

Status: **chosen by Annie on 2026-10-11** (Direction A + Layout 1 "Side Door"). Wheel position **locked at x 548** (approved 2026-10-11). Nathan's next review: final mockup.
This guide is the source of truth for `themes/swipe_theme.tres`, and every `SCREEN-*.md` assumes these tokens.
Mockups: `design/visual/mockups/` and on the Doop canvas [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX) (row "A · 00–12").

## 1. Canvas and pixel scale
- Window 1680×1040. Art is drawn on a **virtual 420×260 grid at 4×**, so every art edge lands on a multiple of 4 px.
- 16×16 sprites at 4× = 64×64 (wheel seats, hand cards). Hero sizes (loot, inspect, monster portrait) use 8× = 128×128. Nib's portrait is 32×32 at 4×.
- Project settings: `rendering/textures/canvas_textures/default_texture_filter = Nearest`, `rendering/2d/snap/snap_2d_transforms_to_pixel = true`, `snap_2d_vertices_to_pixel = true`. Pixel fonts (Pixelify, Silkscreen, VT323): FontFile antialiasing None, hinting None, subpixel positioning off. Nunito (utility): antialiasing grayscale, hinting light. The AA-off rule applies to pixel fonts only.
- UI text and panel borders can sit on a 2 px grid. Sprites must sit on the 4 px grid.

## 2. Palette (only these)
| Token | Hex | Use |
|---|---|---|
| soot | `#1A120E` | screen ground, button text on gold, outlines |
| hub | `#140D0A` | wheel hub, seat tile fill |
| void | `#0B0706` | portrait wells, door interior, slider track |
| empty | `#120C09` | empty alcove fill |
| oak | `#3B2618` | panels (column, cards, modal) |
| inset | `#4A2F1F` | plate fill, 4 px inner inset line |
| seat-wood | `#5A3A22` | occupied alcove fill |
| edge | `#7A4E2B` | panel borders, wheel rim, facing-alcove fill |
| rivet | `#B8733A` | panel corner rivets; also **Weak** |
| parchment | `#E9D3A1` | body text, Nib talk-box fill |
| dim | `#A88C66` | labels, secondary text |
| **loot gold** | `#FFD84A` | **the only accent**: primary buttons, focus, selection, **Deadly**, victory |
| torch | `#F09A34` | gold-button drop edge, rule text, door glow, slider fill |
| imp green | `#7BC950` | Nib and the player only, plus HEAL values |
| ATK red | `#D5443B` | attack values, hearts, HP chips, damage, defeat title |
| BLK blue | `#4FA3D9` | block values, BLOCKED |
| **KO plum** | `#A866C9` | KO cards and values (**approved by Jam**) |
| silver | `#C9CED6` | **Tough** |

Rule: gold means "you want this" and red means "this hurts". Never use gold for warnings.

## 3. Type (all SIL OFL, from Google Fonts, stored in `assets/ui/fonts/`)

### Typography: utility vs flavor
Utility text is anything the player has to read to play: item names, monster names, the description under them, and stat numbers (ATK / BLK / HEAL / HP, pips, card values). Flavor text is the dungeon voice: titles, screen headers, cue lines (`Take it or leave it?`), Nib's talk, banners (`BLOCKED` / `SLAIN`), and buttons.

| Role | Font | Sizes at 1680×1040 | Contrast |
|---|---|---|---|
| **Utility name** | Nunito SemiBold / Bold | ~24 px. Theme type `UtilityName`. | Parchment `#E9D3A1` on oak / soot. Aim for WCAG AA (4.5:1). |
| **Utility body** | Nunito Regular | ~20 px. Theme type `UtilityBody`. | Same parchment (or dim `#B89A70` for secondary lines). |
| **Utility number** | Nunito Bold / ExtraBold | ~28 px. Theme type `UtilityNumber`. Tags `UtilityTag` at 18 px Bold. | Stat ink: ATK `#E86A62`, BLK `#4FA3D9`, HEAL `#7BC950`, KO `#C080E0` (ATK / KO lightened from the palette red / plum so they pass on oak). If a number still fails, put it on a soot plate `#140D0A` — no outline or glow. |
| **Smallest utility text anywhere** | Nunito | **18 px.** Wheel seat chips stay at 18 ExtraBold; they cannot take 28 without covering the portrait. | Seat chips use a soot plate; HP chips use fill `#C43B34` so white digits pass. |
| Flavor display | Pixelify Sans 700 | logo 170 · end titles 84/72 · modal title 54 · cues 40–42 · buttons 40–56 | loot gold / parchment / ATK red on the existing panels |
| Flavor chips / Weak–Tough–Deadly pills | Silkscreen 700 | 12–16 | soot on the pill colour |
| Flavor body (Nib, cue help, pause labels) | VT323 400 | 26–38 | parchment / dim |

Sizes and fonts live in `scripts/ui_palette.gd` (`UiPalette`) and `themes/swipe_theme.tres`. New screens should call `UiPalette.apply_name` / `apply_body` / `apply_number` / `apply_tag` (or set the theme type variation) instead of hard-coding a pixel font on utility labels.

Silkscreen draws every letter as a capital. Any **flavor** label that the copy file writes in title case ("The monster", "Master"…) uses **VT323**, so it shows exactly as written. Utility names use Nunito, which already shows title case.

Cards and plates may grow a little so 24 / 20 / 28 px text does not clip. Do not shrink utility text below 18 px to fit.

## 4. Theme types (in `swipe_theme.tres`)
| Type variation | Base | StyleBox | Font / colour |
|---|---|---|---|
| `PanelOak` | PanelContainer | bg oak, 8 px edge border, 4 px inner inset line (NinePatch `assets/ui/panels/ui_panel_oak.png`, 12 px 9-slice), 12×12 rivets 10 px in from each corner | — |
| `PlateInset` | PanelContainer | bg inset, 6 px border (colour set per use: tier colour or edge) | — |
| `ButtonGold` | Button | normal: bg gold, 5 px soot border, 6 px torch drop edge, 3 px gold outer ring · hover: bg `#FFE47A`, drop 8 · pressed: drop 0, content moves down 4 px · disabled: bg `#4A3A20`, text `#8A7550`, drop `#3A2A14` · focus: 4 px parchment outline | Pixelify Sans 700, soot |
| `ButtonOak` | Button | normal: transparent, 3 px edge border · hover: gold border and text · pressed: bg inset · disabled: 40 % alpha · focus: gold border | VT323, parchment |
| `ButtonDanger` | Button | transparent, 5 px ATK-red border | Pixelify Sans 700, ATK red |
| `TierPill` | Label | bg tier colour, 3 px soot border, padding 4/12 | Silkscreen 700 15, soot |
| `CueLabel` | Label | — | Pixelify Sans 700 40, parchment, centred, autowrap |
| `LabelSmall` | Label | — | Silkscreen 14, dim, spacing 2 (only for all-caps flavor text) |
| `LabelSmallBody` | Label | — | VT323 26–28, dim (for title-case flavor labels) |
| `BodyLabel` | Label | — | VT323 30, parchment (Nib / flavor body) |
| `UtilityName` | Label | — | Nunito SemiBold 24, parchment |
| `UtilityBody` | Label | — | Nunito Regular 20, parchment |
| `UtilityNumber` | Label | — | Nunito ExtraBold 28, parchment (override colour per stat) |
| `UtilityTag` | Label | — | Nunito Bold 18, parchment (ATK / BLK / HEAL / HP) |

## 5. Global layout (Layout 1 "Side Door", v2, locked)
| Element | Rect / anchor | Notes |
|---|---|---|
| Hearts | HBox at (32,28), 6 hearts of 35×30 (7×6 px art at 5×), gap 6 | states: full / cracked (losing this hit) / empty |
| Wheel | centre **(548,350)**, outer r 300, hub r 96, rim ring r 306 with an 8 px edge stroke | **locked**. Draft-gate v1 had x 710 |
| Seats | 8 alcoves; seat centres at radius 200, angle −90° + 45°·i (0 = top, clockwise) | seat tile 76×76, hub fill, 4 px edge border, 64×64 sprite; ATK chip bottom-left (gold on `#2A1C14`), HP chip bottom-right (white on ATK red) |
| Pointer | gold triangle, base y 690, tip y 664, 36 px wide, centred on x 548 | marks the facing alcove (bottom) |
| Spin button | ButtonGold 260×68 at (418,700) | |
| Hand row | HBox, top y 790, **centred on x 547**. Cards 140×210 with a 14 px gap; with **8 cards, 124×210 and a 10 px gap** | the hand cap is a game rule and isn't changed here. Shrink cards, never the gap to the column |
| Right column ("plate slot") | PanelOak at (1086,28), 560×952, padding 26/30 | holds the cue at the top, then **exactly one plate**: gate / inspect / fight monster / Nib / victory / defeat |
| Pause | centred 640×800 modal at (520,120) over a full-screen soot dim at 72 % | the only overlay that covers the wheel |

The gutter between the wheel's right edge (x 854) and the column (x 1086) stays free for the door-to-seat torch line during placement.

## 6. Hand card (the same everywhere)
- Card 140×210 (124×210 at 8 cards), 6 px border in the **tier colour** (Weak bronze / Tough silver / Deadly gold).
- Name is Nunito SemiBold 24, centred, max 2 lines. Middle: 64×64 sprite. Bottom: **exactly one value and one type tag** in Nunito ExtraBold 28 + Bold 18: `3 ATK` (red), `4 BLK` (blue), `3 HEAL` (green), `KO` (plum, no tag), or `?` plus a tag when the value depends on the fight.
- Never "—", "X", icon-only, or two numbers on one card. Extra detail belongs in Inspect.
- States: hover = lift 18 px + 4 px gold ring · spent = 38 % alpha, stays in the row until the fight resolves · disabled = 60 % alpha, no lift · drag = lift 24 px.

## 7. Motion vocabulary (Tween unless noted)
| Name | Property · from → to · duration · easing |
|---|---|
| press | content `position:y` +0 → +4 · 0.05 s · linear; returns on release |
| pop-in | `scale` 0.85 → 1.0 · 0.18 s · TRANS_BACK EASE_OUT, plus `modulate:a` 0 → 1 · 0.12 s |
| plate swap | old plate `modulate:a` 1 → 0 · 0.10 s, then pop-in for the new plate |
| hit-stop | pause the fight Tween (or `Engine.time_scale` 0.05) for 0.07 s |
| shake | wheel root `position` random ±8 px, 6 steps · 0.18 s · decays linearly to 0 |
| vignette | red edge TextureRect (`assets/vfx/vfx_vignette_red.png`, transparent centre) `modulate:a` 0 → 0.55 → 0 · 0.08 s in / 0.35 s out |
| damage number | Label `position:y` 0 → −40 and `modulate:a` 1 → 0 · 0.6 s · EASE_OUT |
| gold pulse | gold ring alpha 0.4 ↔ 1.0 · 0.9 s loop · TRANS_SINE |
| spin | wheel `rotation` · 1.6–2.4 s · TRANS_QUART EASE_OUT, landing on a multiple of 45° |

No full-screen colour washes and no blur. Particles: CPUParticles2D only, square pixels, at most 24 per burst.

## 8. Copy rule
Every player-facing string comes from `data/player-copy.json` through PLAYER_COPY by key. Nothing is hard-coded and nothing under `data/` is edited. Keys Jam is adding for this pack: `pause.master`, `pause.music`, `pause.sound`, `door.seat_hint`. Until a key exists, show `TODO(copy):<key>` and list it in the QA notes. The tier word always comes from `tier.N.name` (Weak/Tough/Deadly), and the word "Tier" is never shown.

## 9. Assets
Naming: `<area>_<thing>_<state>.png` under `assets/ui/…`, `assets/sprites/monsters/<name>/`, `assets/sprites/items/`, `assets/vfx/`. Sprite bases and recolour notes are in [SPRITE-SOURCING.md](SPRITE-SOURCING.md). The mockups use Kenney Tiny Dungeon (CC0) stand-ins.

## 10. Must-keep fight UX
These are player-facing fight-screen rules. Direction A oak tokens stay. Do not drop these when a later visual pass rearranges the column or hub.

1. **Facing callout** — the owner you are fighting sits beside the wheel (portrait + name + ability), not only as a small seat chip. Idle bob. Shake/flash when they attack.
2. **Seat stats** — heart (HP) on the left of the portrait, sword (ATK) on the right. Sprites and those icons stay about 30% larger than the pre-refresh 64 px seats.
3. **Seat names** — name + ability sit in capsules under the wheel monster. Nunito for that utility text.
4. **Weak / Tough / Deadly** — shown as both alcove fill and alcove rim. Never the word Tier on the wheel.
5. **Item card fill** — the whole card face uses JSON `card_color`. Not a thin strip on oak.
6. **Hand** — shrink the cards first, then wrap to a second row. Cards must not overlap Spin or each other.
7. **Event log** — not a permanent right column in a fight. Show on Shift or a hover in the top-right. Hide it again when the mouse leaves and Shift is up.
8. **Hub knight** — the hub is the knight (run frames), a shield with the Block number, and an arc of six hearts. No HP numeral in the hub. Wheel monsters face the knight.
9. **Card titles** — keep titles short (Nunito 18). Shift shows the formula/ability on the card with space between the number and the words. Stat icons stay the current size.
10. **Action button** — Spin / Take-the-hit stays centred under the facing arrow. Do not put a prompt line above that button.
