> **Supersedes (2026-11-16):** this file replaces the H3p-B layered title doc, which has moved to `SCREEN-title-h3pB.md` (it's still in git history too), and the boot hub in `SCREEN-title-framed.md`. Nathan picked Direction 1 "Living trophy room" with the thin top ticker (a) and solid metal goal rings (option A: green / silver / gold). It ships **Sat Nov 21, 2026**.

# SCREEN: Title · Living trophy room · Spinheritance · Godot 4.7

Doop reference: https://doop.design/c/LnXehIxW_R. Frames: 12 title, 13 New Game picker, 14 Settings, 15 intro preview, 20 assets. The mock frames still show the old 3-segment goal ring. **This doc wins**: the segment ring is dropped everywhere.

**Rules**
- The only title word is **Spinheritance**.
- Players never see "Tier" or "ATK". Internal names like `TIER_QUICK` stay in code only.
- Every player string is a `[copy: Spin] key` placeholder. Spin owns the text. Where an existing key may fit it is listed as a *candidate*, but Spin confirms or replaces it. Don't hard-code fallback text that isn't already in `data/player-copy.json`.
- Effects: StyleBox, NinePatch/9-slice, Tween, AnimatedSprite2D, and GradientTexture2D. **No shaders.**
- Viewport is **1680x1040** (`stretch/mode=canvas_items`, `aspect=expand`). All coordinates are in viewport px from the top-left, unless they say *native*. Every texture is imported as 2D Pixel: Filter off, Mipmaps off, Lossless. `TitleScreen.texture_filter = NEAREST`.

---

## 0. Menu rules (Spin's flow PR owns the logic; listed here only so the visual layer can be checked against it)

| state | rows shown, top → bottom | extras |
|---|---|---|
| no save | New Game · Settings · Feedback | no corner goal icon, no Start over |
| save | Continue · Settings · Feedback | Start over link; corner goal icon if a goal has been chosen |

- New Game is **hidden** when a save exists, and Start over is **hidden** when there's no save. There are always 3 rows, so the layout never reflows.
- Biomes the player hasn't entered show **dimmed, with their names**.

---

## 1. Title screen: `scenes/ui/title_screen.tscn` (rebuild)

### 1.1 Node tree (z back → front)

```
TitleScreen (Control, full rect, script title_screen.gd)
├─ Backdrop (TextureRect)        res://assets/ui/biome_splash/bg_verdant.png  pos (0,0) size 1680x832, stretch KEEP
├─ BackdropFloor (ColorRect)     pos (0,832) size 1680x208, #0b0908
├─ Dim (ColorRect)               full rect, Color(0.043,0.035,0.031,0.52), mouse IGNORE
├─ TitleBoard (Control)          pos (90,196) size 332x194, scale (2,2)  → covers 664x388
│  ├─ Window_0..4 (Control, clip_contents) native pos (12+63*i, 22) size 56x154
│  │   └─ Face (TextureRect) trophy_board/face_bg_{slug}.png, expand IGNORE_SIZE, size 308x154, pos (-126,0)
│  ├─ Cap_i (TextureRect)        title/board_window_cap_gold.png native (12+63*i, 22) - cleared windows only
│  ├─ Windows (TextureRect)      title/board_windows_5.png native (12,22) 308x154
│  ├─ Frame (TextureRect)        trophy_board/board_frame.png  (x4 file) size 332x194, expand IGNORE_SIZE, stretch SCALE
│  ├─ Trim (TextureRect)         trophy_board/board_trim_gold.png same as Frame
│  └─ Icon_0..4 (TextureRect)    title/progress/biome_{slug_full}_{state}.png native (22+63*i, 130) 36x36
├─ BoardLabels (Control, NOT scaled, full rect, mouse IGNORE)
│  ├─ Pct_i (Label)              rect (150+126*i, 502) 40x14 - % in the icon's label well
│  └─ Name_i (Label)             rect (110+126*i, 592) 120x22 - biome name under the board
├─ TitleWord (Label)             pos (930,150) size 700x100
├─ Menu (Control)                 pos (1000,300) size 560x328
│  └─ Row_0..2 (Control)         pos (0, 124*i) size 560x80
│      ├─ Presenter (AnimatedSprite2D)  centre (40,40) scale 2  (goblin/gargoyle 96px, lich 128px)
│      └─ Tag (Button)           pos (110,0) size 440x80 (choice_tag, native 110x20)
├─ StartOver (Button, flat)      rect (1210,700) 240x26 - save only
├─ Nib (TextureRect)             title/title_nib_lantern.png pos (560,624) size 274x274 (548 file, 0.5)
└─ (corner goal icon + ticker live on the global CanvasLayer 220, §6)
```

Why do the TitleBoard children use native coordinates? `board_frame` / `board_trim_gold` / `face_bg_*` ship at x4. Showing them at size 332x194 inside a parent scaled 2x samples exactly 1 of every 4 pixels, which gives the native art back pixel-for-pixel. The new title art is native-sized, so it drops straight in. Text **never** goes inside the scaled node: scaled Labels get blurry. That's why `BoardLabels` sits in screen space.

### 1.2 Per-window state (data from the progress provider, §8)

| state | Face modulate | Cap | Icon file | Pct label | Name colour |
|---|---|---|---|---|---|
| gray (not entered) | `Color(0.36,0.36,0.40)` | - | `_gray` | hidden | muted `#8a7f70` |
| entered | `Color(1,1,1)` | - | `_entered` | `{n}%` gold `#e8c36a` | cream `#f4ede3` |
| cleared | `Color(1,1,1)` | shown | `_cleared` | hidden (the check badge carries it) | cream |

- **Pct label:** Open Sans 600, 13 px, centred H/V, outline 0. At 3 digits it drops to 11 px; `FitLabelBox` or a manual size step both work.
- **Name label:** Open Sans 600, 16 px, centred. Text is `[copy: Spin] biome.name.{slug}`; the candidate source is whatever the trophy board plaques use today.
- **Cleared extras:** `trophy_board/twinkle_f0..f3.png` (AnimatedSprite2D, 12 fps) at the icon's top-left and top-right sparkle pixels (native icon-local (1,4) and (33,2)), looping with a 2.4 s idle gap.

### 1.3 Title word and tags

- **TitleWord:** `[copy: Spin] title.overlay` (candidate: existing `title.overlay` = `{game_title}`). EB Garamond 600, 86 px, `#f4ede3`, shadow `#100e0c` offset (0,5) with `shadow_outline_size 0`.
- **Tag:** use `KIT.choice_tag(key, Vector2(110,20))`, i.e. `_choice_sb` StyleBoxTexture with **texture margins L/R 32, T/B 16** (8/4 native x PX 4). States are `choice_tag_idle/hover/press.png` from `assets/dungeon/home/ui/`. Font is the kit's ink, 22-28 px (FitButton, min 16 / max 28).
  - Row keys: `[copy: Spin] title.menu.continue` · `title.menu.new_game` · `title.menu.settings` · `title.menu.feedback`. Candidates: `title.continue` ("Delve Deeper") and `pause.settings`. Spin decides.
- **StartOver:** flat Button with StyleBoxEmpty in all states. Open Sans 400, 17 px. Muted `#9c8f7d`; on hover it turns cream and a 1 px ColorRect underline shows at y+22. Key: `[copy: Spin] title.menu.start_over` (candidate `pause.start_over`).
- **Focus:** `focus_mode = FOCUS_ALL` on the three Tags + StartOver. Order is top→bottom, then StartOver. Default focus is Row_0. Keyboard/gamepad focus = the hover visuals.

### 1.4 Presenters (AnimatedSprite2D, centre-anchored, nearest)

| row | monster (catalog biome) | idle frames (existing) | present frames (new, §9) |
|---|---|---|---|
| Continue / New Game | goblin (b1 Verdant) | `assets/dungeon/anim/facing/goblin_facing_idle_f0..f3.png` 48px | `assets/ui/title/presenters/goblin_present_f0..f3.png` |
| Settings | gargoyle (b2 Crystal) | `gargoyle_facing_idle_f0..f3.png` 48px | `gargoyle_present_f0..f3.png` |
| Feedback | lich (b5 Abyss) | `lich_facing_idle_f0..f3.png` 64px | `lich_present_f0..f3.png` |

- **At rest:** frame `idle_f0`, not playing.
- **Focused row:** `idle` loops at 4 fps.
- **On select:** `present` plays once at 10 fps, then holds the last frame until confirm finishes.
- **No present frames shipped** (if the PixelLab output is rejected): select plays `idle` at 8 fps instead.

---

## 2. Motion (Tween timings), all screens

| event | what | time | trans/ease |
|---|---|---|---|
| hover/focus in | Tag stylebox swap (instant) + Presenter idle starts; focused window's Face modulate ×1.15 (clamp 1) | 0.18 s | SINE / OUT |
| hover out | reverse | 0.12 s | SINE / IN |
| select (press) | Tag `position.y += 4` then back; Presenter `position.x += 8` toward Tag | 0.08 s down + 0.08 s up | QUAD / OUT |
| confirm (title) | TitleBoard `position.y += 12` + `modulate.a 1→0` in parallel; Menu `modulate.a 1→0` | 0.18 s | QUAD / IN |
| picker card hover | card `position.y -= 8`, border StyleBox swap to gold | 0.12 s | QUAD / OUT |
| picker confirm | hold 0.16 s, then curtains (`trophy_board/curtain_drape_9s.png`, NinePatch 2 halves) close `x` | 0.16 + 0.20 s | QUAD / IN_OUT |
| ticker open | Ticker `modulate.a 0→1`, `position.y 8→14` | 0.12 s | QUAD / OUT |
| ticker close | `modulate.a →0` after 0.12 s grace (no flicker crossing the gap) | 0.10 s | linear |
| confirm modal open | Dim `a 0→0.6`; Panel `scale 0.96→1` (pivot centre) + `a 0→1` | 0.14 s | BACK / OUT (overshoot 1.2) |
| settings Nib | Nib `modulate` 1→1.12 while any row is focused | 0.12 s | SINE / OUT |

- **Reduced motion** (`settings.reduce_motion`, the same flag Esc toggles): every Tween above is replaced by its end state applied instantly. AnimatedSprite2D stays on f0 (no idle, no present). Twinkles are hidden. Stylebox swaps are kept, so hover feedback still exists.
- **No screen shake**, no scale bounces on text.
- **Kill rule:** every Tween is created with `create_tween().bind_node(self)` and killed before a new one starts on the same property. Rapid hovering must never stack.

---

## 3. New Game picker (shown after New Game; Spin's flow decides the entry)

Node: `PickerScreen` (Control, full rect). It replaces the visuals in `scripts/playtest_commitment_picker.gd`; that script keeps its logic and keys.

```
PickerScreen
├─ Backdrop  bg_verdant.png (0,0) 1680x832 + Dim a 0.68 + Floor #0b0908 (0,832,1680,208)
├─ Header (Label)   pos (80,46)  EB Garamond 600 64px cream   [copy: Spin] playtest.tier.choose_title (candidate existing)
├─ Card_0..2 (PanelContainer)  pos (124+500*i, 206) size 440x586
│  ├─ Art (TextureRect, clip)  biome_splash/bg_{verdant|crystal|shadow}.png size 840x416 pos (-204,0), stretch SCALE (0.5 of 1680x832)
│  ├─ Fade (TextureRect)       GradientTexture2D vertical, transparent→#100e0c at 24%, rect (0,240) 432x346
│  ├─ Presenter (AnimatedSprite2D) centre (220,166); goblin/gargoyle scale 5 (240px), lich scale 4 (256px)
│  ├─ GoalMark (TextureRect)   title/goal/goal_ring_{quick|deeper|big}.png pos (181,290) 78x78 (3x)
│  ├─ Title (Label)            rect (30,386) 380x40  EB Garamond 600 32 gold   [copy: Spin] playtest.tier.{t}.title
│  ├─ Biome (Label)            rect (30,432) 380x28  Open Sans 600 21 cream    [copy: Spin] biome.name.{slug}
│  ├─ Line (Label)             rect (30,470) 380x40  Open Sans 400 18 muted, autowrap, max 2 lines   [copy: Spin] playtest.tier.{t}.time
│  └─ Pick (Button)            rect (44,518) 352x56  choice_tag native 88x14   [copy: Spin] picker.pick.{t}
└─ Back (Button, flat)  rect (56,830) 250x32 Open Sans 400 18 muted   [copy: Spin] picker.back
```

- **Card StyleBoxFlat:**
  - `bg #100e0c`, border 4 `#6b5235`, `corner_radius 0`.
  - `shadow_color #080706`, `shadow_size 0`, `shadow_offset (0,10)`.
  - Content margins 0, because the children are positioned absolutely.
  - Hover/focus: border `#e8c36a`. Pressed: border `#ffe0a1` and `position.y +4`.
- **Rings** map Quick → **green**, Deeper → **silver**, Big → **gold**, around the Verdant sprout / Crystal shard / Abyss moon. The colour is a goal marker, not a power ranking: all three cards are the same size and frame.
- **Presenter:** the card's monster plays idle at 4 fps only on its own card's hover. Select plays `present`.
- **Copy room:** the card has room for title + biome + one 2-line string. `playtest.tier.{t}.line` (long) is offered on hover as a tooltip, or Spin trims it. Spin decides which strings appear (open question).
- **Focus:** left/right between cards, down to Back. Default focus is Card_0.

---

## 4. Settings (from the title; mirrors Esc → Settings)

Extract the Esc settings page out of `scripts/settings_menu.gd` into a reusable `scenes/ui/settings_panel.tscn` (script `scripts/ui/settings_panel.gd`). Both Esc and the title instance it, so there is **one** implementation.

```
SettingsScreen (Control, full rect)  backdrop = title Backdrop + Dim 0.62
├─ Board (TextureRect)   dungeon/home/overlays/pause_board.png  pos (440,60) 800x720 (PX 4)
├─ Plaque (Label)        board-local (240,2) 324x54 → screen (680,62); ink #2a1c10 EB Garamond 600 32   [copy: Spin] pause.settings
├─ Rows (VBoxContainer)  screen pos (584,148) width 512, separation 8   (content band: board y 88..664)
│  ├─ Toggle_sparkles   choice_tag 512x64 (native 128x16)   [copy: Spin] settings.sparkles.{on,off}
│  ├─ Toggle_invert     choice_tag 512x64                   [copy: Spin] settings.invert_scroll.{on,off}
│  ├─ Toggle_reduce     choice_tag 512x64                   [copy: Spin] settings.reduce_motion.{on,off}
│  └─ VolumeSlider x5   512x64 (ROW_W/ROW_H), keys pause.master · pause.music · pause.ambience · pause.sound · pause.ui
├─ Back (Button)         choice_tag 352x64 (native 88x16) at (664,796)   [copy: Spin] settings.back
└─ Nib (TextureRect)     title_nib_lantern.png (110,560) 274x274
```

- **Layout:** 8 rows × 64 + 7 × 8 = 568 px, which fits the 576 px content band. Back sits **below** the board (the board ends at y 780).
- **Sliders:** VolumeSlider NinePatch plate margins are 32/16/32/16 (existing). The track uses `slider_track_9.png`, the fill uses `slider_fill_9.png` (9-slice, margins 8 native → 32 px L/R, 0 T/B), and the grabber is `slider_grabber.png` 48x56 (existing VolumeSlider internals, unchanged).
- **Shared values:** the sliders call the same `_audio.set_master/_music/_ambience/_sfx/_ui` as `settings_menu._on_slider`. The radio/jukebox knobs (`radio_overlay.gd` KNOB_KEYS) read the same AudioServer bus values. **No second storage.** If a jukebox knob changes, the Settings screen reads the live bus value when it opens.
- **Toggle copy:** today the Esc toggle labels are **hard-coded** in `settings_menu.gd` ("Item sparkles: on", etc.) under a borrowed `pause.resume` key. Spin's copy PR keys them; the shared panel reads those keys for both Esc and the title. No Developer Mode row in player menus.
- Esc closes Settings and goes back to the title with focus on the Settings row.

---

## 5. Intro preview still (inside Nathan's intro, before the title)

- **Frame** (Panel StyleBoxFlat): `bg #0b0908`, border 4 `#8a693e`, shadow offset (0,12) `#080706`. Rect (252,72) 1176x736.
- **Preview** (SubViewportContainer at (256,76), size 1168x728, `stretch false`):
  - Inside it, a SubViewport 1680x1040 holds a `TitleScreen` instance with `preview_mode = true` and `scale 0.6952` (1168/1680).
  - `texture_filter = LINEAR` on the container: this is the **one documented exception**, because a 0.7 nearest downscale shimmers.
  - Preview shows the **no-save** state (New Game first, no corner goal icon, no Start over). All windows are gray except Verdant entered 0%.
  - `preview_mode` disables input, presenter animation, twinkles and Tweens.
- **Caption** (Label): rect (330,824) 1020x60, Open Sans 400 22 cream, centred. `[copy: Spin] intro.preview.caption` (Nathan narration plus the shortened feedback tutorial; Spin writes it).
- **Controls:** the existing intro controls (`intro.next`, `intro.skip`) are unchanged. Continue fades 0.18 s to the live title, which is the same state as the still.

---

## 6. Corner goal icon and hover ticker (global, CanvasLayer 220)

`scripts/playtest_goal_icon.gd` keeps its logic, signals (`victory_code_wanted`), tip text keys (`playtest.goal.*`), and layer. Only the visuals change:

- **GoalRing** (TextureRect): replaces the `_panel` StyleBox + `GLYPH`. Texture is `assets/ui/title/goal/goal_ring_{quick|deeper|big}.png` at **3x = 78x78**, offset (16,16). `SIZE` becomes `Vector2(78,78)`.
  - When the goal is done: `twinkle_f0..f3` (12 fps) at the ring's 1 o'clock (native (20,3)), and `modulate` pulses 1↔1.15 over 1.6 s (reduced motion: no pulse, no twinkle).
  - The `_hint` Label ("✓"/"·") is **removed**; the ticker carries progress.
  - **Hidden** while no goal is chosen.
- **ProgressTicker** (PanelContainer): a sibling on the same CanvasLayer, `top_level`. Rect **(100,14) 436x100**.
  - StyleBoxFlat `bg #1a1410f5`, border 2 `#e8c36a`, `corner_radius 8`, content margins **L/R 18, T/B 14**. This matches the current goal tip.
  - Contents: an HBox, separation 10, holding 5 × `ProgressIcon` (TextureRect 72x72 = 2x the icon, `expand IGNORE_SIZE`). Each has a screen-space Pct Label at icon-local (16,46) 40x14, Open Sans 600 13. 5·72 + 4·10 = 400 = 436 − 36.
  - Shown on GoalRing **mouse hover or focus**, **everywhere**: title, hub, map, dialogue, combat, pause. Hidden on exit after a 0.12 s grace.
  - The existing goal tip (`_tip`) moves to **under** the ticker: `(100,122)`, width 436, autowrap.
  - Click behaviour is unchanged (done-Big → victory code).
- **Safe zones** (checked on the combat shot `REQ-20261116-hotbar-fx-cleanup/03-new-star-fight.png`):
  - Ticker x 100–536, y 14–114. Wheel circle centre (837,317) r 296 → rim x ≈ 623 at y 114, a **≥ 87 px** clearance.
  - Clear of the left arrow (451,328 +160x312), the Spin button (708,628), the hand (382,700 +916x310), the enemy card (1150,20 +140x165), the counter (486,490), and Feedback (1478,972).
  - It covers only the F2 hint, only while hovered.
  - The goal tip under it (y 122 → ~190) also stays left of x 536 and above the arrow's top (y 328).
  - **Rule:** the ticker must stay inside **x ≤ 560, y ≤ 120**. If later combat HUD changes need that space, move the ticker, not the HUD.

---

## 7. Start-over confirm (title, save only)

```
ConfirmLayer (Control, full rect, top)
├─ Dim (ColorRect) full rect #0b0908 a 0.6, mouse STOP (click = cancel)
└─ Panel (PanelContainer) centre (840,520), min size 560x220
   StyleBoxFlat bg #100e0ce8, border 2 #e8c36a, radius 8, content margins L/R 16, T/B 12   (same as settings_menu confirm)
   ├─ Ask (Label)  Open Sans 600 22 cream, autowrap, centred   [copy: Spin] title.start_over.ask
   ├─ Body (Label) Open Sans 400 17 muted, autowrap            [copy: Spin] title.start_over.body
   └─ Buttons (HBox, sep 24, centred)
      ├─ Keep (choice_tag 224x64, native 56x16) DEFAULT FOCUS   [copy: Spin] title.start_over.no   (candidate pause.give_up_no)
      └─ Wipe (choice_tag 224x64)                                 [copy: Spin] title.start_over.yes
```

- Esc or a Dim click means Keep.
- Wipe is the second button and never the default, so a double-click on Start over can't wipe.
- What happens next (the actual wipe, then the picker) is Spin's flow PR.

---

## 8. Integration seams (who owns what)

| piece | owner |
|---|---|
| intro sequence, menu option rules (§0), save detection, New Game → picker → run start, Start over wipe, Feedback destination, all copy keys/text | **Spin**: flow-wiring + copy PRs |
| TitleBoard, windows, ProgressIcon, GoalRing, ProgressTicker, presenters, tag styling, picker/settings/confirm visuals, settings_panel extraction, art install | **Pixel**: visual PR |

The visual layer exposes:

```gdscript
# title_screen.gd
signal option_focused(id: StringName)      # &"continue", &"new_game", &"settings", &"feedback", &"start_over"
signal option_activated(id: StringName)
func set_options(ids: Array[StringName]) -> void      # flow decides; visuals lay out rows 0..2 + StartOver
func set_progress(p: Dictionary) -> void              # {slug: {state: &"gray"|&"entered"|&"cleared", pct: int}}
var preview_mode: bool = false
# progress provider (one source for title + ticker)
# scripts/ui/biome_progress.gd: static func snapshot() -> Dictionary
```

The visual PR ships a **stub provider** (all gray except Verdant entered, 0%) and stub `set_options` defaults, so it merges on its own. Spin's PR replaces the stubs with real save reads.

---

## 9. Assets

**New** (this batch, `assets/ui/title/`, native size, nearest; displayed via scale):

| file | native | shown | notes |
|---|---|---|---|
| `progress/biome_{verdant_hollow,crystal_cavern,ashen_crypt,cinder_forge,shadow_abyss}_{gray,entered,cleared}.png` | 36x36 | 2x (72) on board and ticker | 15 files. Label well native x8..27 y23..29 (Godot Label). Sparkle pixels (1,4),(33,2). Check badge native (25..35). Verdant + Crystal emblems are PixelLab (bitforge, cleaned); Ashen/Cinder/Abyss are hand-pixeled. |
| `goal/goal_ring_{quick,deeper,big}.png` | 26x26 | 3x (78) corner + picker | Solid metal ring r 10–12: green / silver / gold, lit from the top-left; emblem = Verdant sprout / Crystal shard / Abyss moon. |
| `board_windows_5.png` | 308x154 | 2x inside TitleBoard at native (12,22) | 5 panes 56 wide at 63 pitch, 7 px bevelled mullions, 8 px sill, transparent panes with a 1-2 px inner shadow. Crypt Classic wood ramp sampled from board_frame. |
| `board_window_cap_gold.png` | 56x4 | 2x on cleared windows | |
| `presenters/{goblin,gargoyle,lich}_present_f0..f3.png` | 48 / 48 / 64 | 2x title, 5x/4x picker | PixelLab animate-with-text-v3 from facing idle f0. **Optional**: ship only if Nathan approves (see the contact sheet). |

**Reused** (no changes):
- `assets/ui/biome_splash/bg_{verdant,crystal,shadow}.png`
- `assets/ui/trophy_board/{board_frame,board_trim_gold,face_bg_*,twinkle_f0..f3,curtain_drape_9s}.png`
- `assets/dungeon/home/ui/{choice_tag_idle,choice_tag_hover,choice_tag_press,slider_track_9,slider_fill_9,slider_grabber}.png`
- `assets/dungeon/home/overlays/pause_board.png`
- `assets/ui/title/title_nib_lantern.png`
- `assets/dungeon/anim/facing/{goblin,gargoyle,lich}_facing_idle_f0..f3.png`
- Fonts: `assets/ui/fonts/eb_garamond/`, `assets/ui/fonts/open_sans/`

**Retired:** `scripts/commitment_tier_glyph.gd` drawing in the goal icon (keep the file if other callers use it); the 3-segment ring concept.

---

## 10. SFX hooks (all **Reel**: names proposed; Reel supplies the files/bus)

| hook | when | status |
|---|---|---|
| `ui.hover_title` | title row focus/hover | exists |
| `ui.title_select` | Tag press (wood tap + small creature chirp per presenter) | **Reel** new |
| `ui.title_confirm` | confirm fade starts (warm latch) | **Reel** new |
| `ui.picker_hover` | card hover; payload `{goal: quick/deeper/big}` (leaf / glass / bell flavour, equal loudness) | **Reel** new |
| `ui.picker_confirm` | curtains start (cabinet latch) | **Reel** new |
| `ui.hover_menu` | Settings rows | exists |
| `ui.slider_tick` | slider 10 % detents | exists |
| `ui.menu_open` / `ui.resume` | Settings open / close | exists |
| `ui.ticker_open` | ticker shows (very soft paper tick; rate-limit 1 per 0.5 s) | **Reel** new |
| `ui.confirm_open` | Start-over modal opens | **Reel** new |
| `ui.start_over_confirm` | Wipe pressed (low, final; not celebratory) | **Reel** new |

Missing events must be a silent no-op. `audio_fx.play_event` -> `_play_event_inner`: the CA verifies that an unknown id doesn't error, and guards with a registry check if it does.

---

## 11. Copy keys (all `[copy: Spin]`; no text here on purpose)

`title.overlay` · `title.menu.{continue,new_game,settings,feedback,start_over}` · `biome.name.{verdant,crystal,ashen,cinder,shadow}` · `playtest.tier.choose_title` · `playtest.tier.{quick,deeper,big}.{title,line,time}` · `picker.pick.{quick,deeper,big}` · `picker.back` · `pause.settings` · `settings.{sparkles,invert_scroll,reduce_motion}.{on,off}` · `settings.back` · `pause.{master,music,ambience,sound,ui}` · `intro.preview.caption` · `intro.next` · `intro.skip` · `title.start_over.{ask,body,no,yes}` · `playtest.goal.{quick,deeper,big,done,done_big}` (unchanged).

Keys marked *candidate existing* already have text in `data/player-copy.json`. New keys get a **dev-only** fallback of the key name itself, so missing copy is obvious in a build and never looks like invented text.
