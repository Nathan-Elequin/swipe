# SCREEN — Title framed (study B) · Spinheritance · Godot 4.7

Status: **approved by Nathan** (final mockup B). Spec header on the studies note that called this preliminary is **superseded**.
Reference: `design/visual/mockups/study-B-1680x1040.png` (1680×1040). Native art: `assets/ui/title/cabin-vignette-native.png` (340×220).
Doop studies (historical): https://doop.design/c/F9TnhFdZAo — frame B `MuhToXU2IQ`.

This replaces the cluttered centered hub + full-bleed H3p still under the menu. Quiet ground, compact framed cabin on the **left**, live title + menu on the **right**. Only layout B ships; A is the small-window responsive fallback only.

## 1. Viewport & pipeline

- Design baseline **1680×1040** (`project.godot` `window/size`, `stretch/mode=canvas_items`, `aspect=expand`). **Do not** change global stretch/filter for this screen.
- Project default texture filter stays Nearest (`textures/canvas_textures/default_texture_filter=0`). Cabin `TextureRect` also sets `texture_filter = TEXTURE_FILTER_NEAREST`, mipmaps off on import (`compress/mode=0`, `mipmaps/generate=false`).
- Scene owner: `scripts/playtest_hub.gd` (Control/`ColorRect` boot hub). Theme font refs: `themes/title_framed.tres`.
- Triangle helper: `scripts/ui/title_framed_triangle.gd`.
- Music: archived boot still calls `sfx.music_title()` from `main.gd` `_maybe_open_teaser` / `_playtest_teaser_done`. No audio bus changes.

## 2. Palette

| Role | Hex |
|---|---|
| Ground | `#15120f` |
| Title | `#f0e2c6` |
| Action (idle) | `#e1d4bd` |
| Helper / Feedback | `#b6a78e` |
| Selected row fill | `#30261a` |
| Selected action | `#ffe3a5` |
| Selected helper | `#d1b88d` |
| Cursor stripe / triangle | `#efc36e` |
| Frame border | `#685039` |
| Frame inset | `#241c15` |
| Frame shadow | `#100e0b` |
| Focus-visible outline | `#f7d58c` |
| Pressed fill | `#241c15` |
| Disabled | `#8f8575` |

No blur/glass. No giant gold-bordered rectangles. No controls over the cabin image. No extra logo/tagline/fake labels.

## 3. Typography (bundled OFL)

| Role | Face | Weight file | Size (B) |
|---|---|---|---|
| Title wordmark | EB Garamond | `assets/ui/fonts/eb_garamond/EBGaramond-SemiBold.ttf` | 80px / ~1.12 |
| Action | Open Sans | `assets/ui/fonts/open_sans/OpenSans-SemiBold.ttf` | 28px |
| Helper | Open Sans | `assets/ui/fonts/open_sans/OpenSans-Regular.ttf` | 18px |
| Feedback | Open Sans Regular | same | 22px |

Licences: SIL OFL 1.1 — `assets/ui/fonts/eb_garamond/OFL.txt`, `assets/ui/fonts/open_sans/OFL.txt`. Attribution: `assets/ui/fonts/README.md`, `CREDITS.md`.
UI text is native Control resolution (not baked into the pixel surface).

## 4. Baseline coordinates (1680×1040)

| Element | x,y,w,h |
|---|---|
| Framed scene (outer) | 162, 300, 688, 448 |
| Inner image (2×) | 166, 304, 680, 440 |
| Title | 926, 284, 590, ~90 |
| Menu column | 926, 414, 460, 270 |
| Rows | y 414 / 504 / 594, each 460×90 |
| Feedback | 966, 712 (22px), ~ends 758 |

Frame: 2px `#685039` border + 2px inset `#241c15`; 12px solid downward shadow `#100e0b`.
Row padding (idle): top 14 / right 24 / bottom 12 / left 40. Selected: left border 3px gold + left padding 37 (text x stable). Triangle: 8×12 at left 16, top 26.

## 5. Art

- Source composite (exact): `assets/ui/title/cabin-vignette-native.png` — 340×220 RGBA, built from existing cabin / Nib / Bartleby portrait / fire_f0 (see studies note). **No new authored pixels.**
- Display: exact **2× → 680×440**, nearest, no mipmaps, uniform scale only.
- Size list: `design/visual/sizes/title-framed-b.sizes.json`.

## 6. Copy & actions (bindings unchanged)

Exact player-facing strings via `player_copy.gd` / `data/player-copy.json`:

| Control | Keys | Locked text |
|---|---|---|
| Brand New | `playtest.brand_new` / `playtest.brand_new_blurb` | Brand New / Start from scratch. |
| Middle Progress | `playtest.middle` / `playtest.middle_blurb` | Middle Progress / A few dungeons in. |
| Continue | `playtest.continue` / `playtest.continue_blurb` | Continue / Last save. |
| Feedback | `playtest.feedback` | Feedback |

Decorative title word only: **Spinheritance** (not a new copy key; not a tagline).
Signals unchanged: `brand_new`, `middle_progress`, `continue_save`, `feedback_wanted`.
Continue visibility still follows `home_cabin.has_save()` — never force-disabled for visual balance. Hidden when no save; focus loop skips it.

## 7. Focus / input

- Selection = actual focused (or hovered) row: warm fill + left gold stripe + triangle; bright action/helper colours.
- Pressed: fill `#241c15`. Disabled (if ever used): muted `#8f8575`, no triangle/accent.
- Focus-visible outline 2px `#f7d58c` (expand margins; control rect size does not jump).
- Keyboard / controller order: Brand New → Middle Progress → Continue (if visible) → Feedback → wrap.
- Default focus on open: Brand New.

## 8. Responsive

| Viewport | Behaviour |
|---|---|
| 1680×1040 | Exact B coords. |
| 1920×1080 (and other larger) | Keep B sizes; center composition; quiet surround grows. No axis-independent stretch of art. |
| ≤~1280×720 when B cannot fit readable | Deliberate vertical reflow (A-like): cabin **1×** 340×220 centered, title 64, actions 22 / helpers 16, 64px rows, Feedback footer. All actions + focus retained. |

## 9. Integration notes

- Archived teaser path no longer opens full-bleed H3p under the hub; hub paints the framed still. Chase teaser code remains for `TEASER_ARCHIVED := false`.
- Old layered `scenes/ui/title_screen.tscn` (H3p-B) remains in tree for teaser tooling; boot menu no longer depends on it while archived.
- Do not rewrite combat/wheel/gameplay for this screen.

## 10. QA

- Local drain: `playtest/repot/inbox/REQ-20261106-title-framed-B.md` (1680 / 1920×1080 / 1280×720 + focus / Continue / Feedback).
- Asset regression: `tools/qa/check_title_framed.py`.
- Tip smoke / existing hub action routing unchanged at the signal boundary.
