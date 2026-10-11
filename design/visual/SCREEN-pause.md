# SCREEN — pause · Direction A "Torchlit Burrow"

**Mockup(s):**
- [pause_v1.png](mockups/pause_v1.png) · Doop frame `XqlAE4FFKS` on [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX)

**Scene:** `scenes/ui/pause_menu.tscn` · **Theme:** `themes/swipe_theme.tres` · **Tokens:** [style-guide.md](style-guide.md)

## Purpose
Settings / pause. A strong dim (fixes Cursor note 5, weak dim). Opening it closes Inspect, so only one is ever open.

## Layout (1680×1040, px)
| Node | Rect / anchor | Theme |
|---|---|---|
| Dim | ColorRect full rect, soot at **72 %**, mouse_filter STOP | — |
| Modal | PanelOak 640×800 at (520,120), padding 34/44 | — |
| ↳ Title | `pause.settings`, Pixelify 54 gold | — |
| ↳ 3 sliders | labels **`pause.master` / `pause.music` / `pause.sound`** ("Master", "Music", "Sound"; **new keys Jam is adding**), VT323 28 dim, title case as written. HSlider: 16 px void track with a 3 px edge border, torch fill, 24×30 gold grabber with a 3 px soot border. 18 px apart | LabelSmallBody; `assets/ui/buttons/ui_slider_{track,fill,grabber}.png` |
| ↳ Row (gap 16, 34 px below) | `pause.resume` ButtonGold, fills the row, 72 high, font 38 · `pause.quit` ButtonOak 180×72 | Resume has focus |
| ↳ Label | `pause.start_over` | LabelSmall |
| ↳ 2×2 grid (gap 12) | `title.how_to_play`, `title.dive_in`, `title.begin`, `title.adventure` — ButtonOak, 56 high, font 28 | — |

## States
Esc toggles. Opening calls `inspect.close()` first, then shows the modal. While it's open, the hand, wheel and column ignore input.

## Motion
Dim `modulate:a` 0 → 1 over 0.12 s, modal pops in. Closing reverses in 0.1 s.

## Text keys (PLAYER_COPY; Jam owns the wording)
`pause.settings`, `pause.master (new)`, `pause.music (new)`, `pause.sound (new)`, `pause.resume`, `pause.quit`, `pause.start_over`, `title.how_to_play`, `title.dive_in`, `title.begin`, `title.adventure`

## Rules
- Never show the word "Tier". The tier word comes from `tier.N.name` (Weak / Tough / Deadly).
- Every player-facing string comes from `data/player-copy.json` via PLAYER_COPY by the keys below. Never hard-code a string, and don't edit anything under `data/`. If a key doesn't exist yet (Jam is adding `pause.master`, `pause.music`, `pause.sound`, `door.seat_hint`), show `TODO(copy):<key>` and list it in the QA notes.
- The wheel stays visible on every in-run screen. Only Pause dims it.
- Wheel centre (548,350) and the hand centred on x 547 are locked.

## Done when
- [ ] The dim clearly reads as paused (72 %)
- [ ] Inspect can never be open behind it
- [ ] Resume is gold and has focus
- [ ] Slider labels come from pause.master/music/sound and aren't hard-coded
- [ ] Side-by-side QA saved to `design/visual/qa/pause_menu_qa_v1.png`, with differences listed

## Cursor prompt (copy-paste)
```text
Read design/visual/style-guide.md and design/visual/SCREEN-pause.md, and look at the mockup PNG(s) they link.
Build scenes/ui/pause_menu.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible. Opening pause must close inspect first.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/pause_menu_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```
