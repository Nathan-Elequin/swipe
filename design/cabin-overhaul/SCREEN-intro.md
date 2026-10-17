# SCREEN: Intro cutscene (≈30 s, 5 panels, skippable)

Mocks: `_pixel_extras/review/mocks/13_cut_intro_p1.png`, `13_cut_intro_p3.png`, `13_cut_intro_p5.png`; GIF `_pixel_extras/review/intro_p1_rain.gif`.

Plays on boot when `intro_seen == false`, before the first `show_menu()`.
- `_ready` (480) sets `phase = "title"` as today. `_sync_overlay` sees `home_cabin.intro_pending()` and calls `home_cabin.play_intro()` instead of `show_menu()`.
- **Replay (Nathan decision 5):** the journal's Will tab has a "Read it again" tag (`journal.will.replay`). A replay uses the same panels and player with `replay = true`: always skippable, no web click wait, no `nib.first.*`, `intro_seen` untouched, and it ends back in the study (SYSTEMS §7.2, SCREEN-study).

## Shared cutscene player: `scripts/cabin/cutscene_player.gd`
```
_cutscene (Control, full rect, z 8 in CabinRoot, mouse STOP)
├── Black      ColorRect #100e0c full rect
├── Frame      TextureRect cutscenes/panel_frame.png at native (42,32) = 4x (168,128)
├── PanelA     TextureRect (current panel) at native (50,40) = 4x (200,160), 320x180 → 1280x720
├── PanelB     TextureRect (next panel, cross-fade)
├── FxLayer    Control clipped to the panel rect (rain etc.)
├── Caption    Label centred, x 840, y 232*4 = 928, width 1400 px, 34 px font, cream #f0e6d8, autowrap
├── NibLine    Label (same slot as Caption, used for *_nib keys) + small nib/nib_bust_f0..f2 at native (60,222) 32x32 talking
├── Skip       Label-button tutorial.skip-styled, uses intro.skip, top-right native (392,8) [1568,32], muted #a8946c
└── NextHint   Label intro.next, bottom-right, 24 px, shown after the caption has finished typing
```
- Panel data is an Array of `{tex, caption_key, nib_key, hold, fx}`. Captions type at 40 chars/s with `sfx.speak(&"nib", text)` for Nib lines only. Narration lines have no blips.
- Advance: click / `ui_accept`. If the caption is still typing, the first click completes it; the second goes to the next panel. With no input, a panel auto-advances after `hold`.
- Panel change: PanelB modulate.a 0→1 over 0.35 s, then swap; cue `cabin.panel`.
- Skip (button or Escape): fade Black to 1 over 0.3 s, then finish.

## Panels
| # | Panel | Hold | Caption | Nib line | FX / motion |
|---|---|---|---|---|---|
| 1 | `cutscenes/intro_p1.png` (tannery attic, Sprout alone) | 6 s | `intro.p1` | — | Rain `cutscenes/rain_f0..f2` @ 90 ms, clipped to the window rect [210, 30, 64, 52]. A drip falls along [186, 22, 186, 110] every 1.4 s (2px ColorRect #8cbc48 Tween y). Slow push-in: PanelA scale 1.0→1.03 over the hold. |
| 2 | `cutscenes/intro_p2.png` (Nib at the door in the rain) | 6 s | `intro.p2` | `intro.p2_nib` | Full-panel rain `rain_f0..f2`. Knock: cue `cabin.door` ×2 at 0.3 s. |
| 3 | `cutscenes/intro_p3.png` (the will and the portrait) | 7 s | `intro.p3` | `intro.p3_nib` | `sting.intro` at panel start. PanelA nudges up 4 native px over the hold. |
| 4 | `cutscenes/intro_p4.png` (up Kettle Hill, the Grumble behind) | 5 s | `intro.p4` | — | Pan: PanelA position.x −6 native over the hold. |
| 5 | `cutscenes/intro_p5.png` (the cabin door, night) | 6 s | — | `intro.p5_nib` | Ends by cross-fading straight into the main room interior (Black → RoomMain), then Nib's `nib.first.1..3`. |

Total ≈ 30 s without clicks.

## Audio
- On click 1 (web: this is the unlock gesture; desktop: immediately), cue `cabin.intro_start`, which starts the `music_intro` bed (music box 3).
- `sting.intro` on panel 3.
- On finish, `music_to` the saved radio station bed.

## Web rule
On web, panel 1 is shown with `intro.next` visible and **does not** auto-advance until the first click. That click unlocks audio (`AudioFx._input` 911).

## Save
`intro_seen = true` on finish or skip.

## Copy and cues
**Copy:** `intro.p1`, `intro.p2`, `intro.p2_nib`, `intro.p3`, `intro.p3_nib`, `intro.p4`, `intro.p5_nib`, `intro.skip`, `intro.next`, `tutorial.speaker`

**Cues:** `cabin.intro_start`, `sting.intro`, `cabin.panel`, `cabin.door`, `speech.nib`
