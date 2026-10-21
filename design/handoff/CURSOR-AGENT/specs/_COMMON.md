# Shared conventions for all ANIM specs (read first)

These specs live on the box. Their in-repo home is `design/visual/ANIM-<name>.md`. Nothing has been written to the repo yet.

- **Viewport:** 1680×1040, measured from `design/cli-runs/05-playtest-pass/40_itch_midfight.png`. Approximate rects (always read live rects from nodes at runtime):

  | Element | Rect / position |
  |---|---|
  | Wheel | centre ≈ (840, 377), outer radius ≈ 295 |
  | Hub disc | radius ≈ 100 |
  | Hearts | top-left, x 25–225, y 15–40 |
  | Take / Undo / Redo | y 754–815; Take at x 678–815 |
  | Hotbar row | y 838–1010; cards 128×172 on screen, 8px gap; first card at x 572 with 4 cards |
  | Inspect panel | x 251–503, y 505–677 |
  | Log panel | x 1414–1653, y 49–738 |
  | Ability slash (today) | left gutter, sized and placed in `main.gd` ~L15003 |

- **Live anchors:** `wheel_view.slice_portrait_global(i)`, `hp_global(i)`, `atk_global(i)`, `hub_hearts_global()`, `hub_blk_global()`, `_hub_hp_pos()`, `_hub_blk_pos()`, `combat_stage.global_position/size`, the card `global_position`.
- **Pixel rules:** 16px base art shown at 4x; items in motion are 24px native; monster portraits use free canvases (see slash-portrait). Hotbar icons stay at their current 48×48 on-screen box inside a 118×120 card. Integer scales only.
- **PNG import:** Filter **Nearest**, mipmaps off, compress Lossless, `texture_filter = TEXTURE_FILTER_NEAREST` on the node. Frames are named `<thing>_<action>_f0.png … fN.png`. Folders:
  - `assets/ui/anim/` for UI
  - `assets/dungeon/anim/` for monsters and items
- **Palette:** from `design/visual/tokens.json`.
  - Ink and danger: `gold #e8c36a`, `ink_on_dark #f0e6d8`, `outline #100e0c`, `danger #8b1e1e`, `danger_atk #6a1c14`, `hurt #e07a7a`, `heal #8dcb8d`.
  - Rank shine from `item_card._tier_shine()`: Weak copper `#d4894e`, Tough silver `#f4f7fb`, Deadly gold `#ffe6a8`.
  - Poison purple-green follows the existing `tex_poison` in `boss_wheel.gd`.
  - PixelLab outputs must be palette-matched to these before import.
- **Tags:** every element is marked **[TW]** (Tween or `_draw` only, no art) or **[PL]** (needs PixelLab frames).
- **Words:**
  - Players never see "Tier". Rank words are only Weak / Tough / Deadly (`tier.1/2/3.name`).
  - Jam strings (final): status `Silenced`; Sling armed `Loaded` with tooltip "Loaded: your next Attack can hit any monster."; Triclops call name `Cut And Run`.
  - All new strings go through `PLAYER_COPY.text(key, fallback)`.
- **Fast-forward:** every Tween and timer here must respect `Engine.time_scale`. Do not use `process_always` timers or `ignore_time_scale`, so holding **Shift** speeds them up (see ANIM-spin-cascade-ticker). Space keeps its current behaviour: don't block it and don't add a Spin shortcut.
- **QA (godot-mcp):**
  - Run the project at 1680×1040 in the editor so `OS.has_feature("editor")` is true.
  - Force a target with `set_meta("qa_spin_idx", i)` on Main before Spin (`_on_spin` honours it).
  - Seat content with dev-test placement (`cue.devtest`), or use the existing harness `scripts/dev/shot_harness.gd` / `scripts/shot_cli.gd`.
  - Take screenshots at the listed ms marks, save under `design/visual/anim-qa/<spec>/NN_<what>.png`, and run `scripts/dev/text_audit.gd` after any text change.
