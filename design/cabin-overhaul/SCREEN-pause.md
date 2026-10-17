# SCREEN: Pause (simple overlay, diegetic skin)

Mock: `_pixel_extras/review/mocks/12_pause_overlay.png`.

This keeps `scripts/settings_menu.gd` (`open_menu` 235, z 120, pauses the tree) and its slider setters. **Only the skin and the button set change.** It stays a plain overlay, as Nathan asked.

## Node tree (settings_ui, restyled)
```
settings_ui (ColorRect z 120, now transparent; Veil child below)
├── Veil       TextureRect ui/overlay_vignette.png (full rect). Click outside Board = Resume (fixes the dead _on_dim_input 318)
├── Board      TextureRect overlays/pause_board.png at native (110,40)
├── _title     Label pause.settings on the board header, centred (board-local x 100, y 2)
├── Buttons    VBox of choice tags (ui/choice_tag_idle/hover/press 9-slice, 128x16 native) at board-local
│   ├── _btn_resume  pause.resume
│   ├── _btn_peek    pause.peek        (in-run only; opens SackPeek)
│   ├── _btn_give_up pause.give_up     (in-run only)
│   └── _btn_quit    pause.quit        (desktop only; hidden on web as today, line 96)
├── _master    HSlider with ui/slider_track_9.png / ui/slider_fill_9.png / ui/slider_grabber(.png|_hover.png) at board-local (24,150) width 152
├── MasterLabel Label pause.master (above the slider)
└── Confirm    (hidden) small dialog_box 9-slice: pause.give_up_ask + pause.give_up_yes / pause.give_up_no
```
- `overlays/pause_board.png` at native (110,40,200,180) = 4x (440,160,800,720)
- Button tops (board-local): [[36, 46], [36, 72], [36, 98], [36, 124]]. Slider row (x, y, width): [24, 150, 152].
- **Removed** from pause: the `_play` start-over row and `_btn_how`, `_btn_dive`, `_btn_begin`, `_btn_adventure`, `_btn_home` (SYSTEMS §8). The editor-only buttons stay (`_authoring()`), appended under Quit.
- **Master only (Nathan decision 4, final).** Music/Ambience/SFX/UI sliders are not on the board, because the radio has them. The nodes `_music`, `_ambience`, `_sfx` and `_ui_vol` stay in code but hidden (`visible = false`) so nothing else breaks.
- **In the cabin** (Escape from the idle main room, SYSTEMS §9): Resume, the Master slider and Quit (desktop). Peek and Give up are hidden.
- **Give up flow:** `_btn_give_up` → Confirm (`pause.give_up_ask`). Yes (`pause.give_up_yes`) → close pause, `paused = false`, then `Main._give_up()` = `_reset_run()`, `phase = "title"`, loss homecoming (SYSTEMS §3.2). No (`pause.give_up_no`) → back.
- Board open: position.y from −180 native to 40 over 0.22 s, BACK OUT, cue existing `ui.menu_open`. Close: existing `ui.resume`. Slider steps: existing `ui.slider_tick`.

**Copy:** `pause.settings`, `pause.resume`, `pause.peek`, `pause.give_up`, `pause.give_up_ask`, `pause.give_up_yes`, `pause.give_up_no`, `pause.quit`, `pause.master`

**Cues:** `ui.menu_open`, `ui.resume`, `ui.slider_tick`, `cabin.hover`, `cabin.click`

**Code hooks:** `open_menu` (235), `_on_dim_input` (318), `_unhandled_input` (324), `_btn_quit` (line 96 web check), `_on_pause_mode` (4017): remove the mode branches it no longer needs and keep `latest`/`dev` for the editor.
