# SCREEN — how-to-play · Direction A "Torchlit Burrow"

**Mockup(s):**
- [how-to-play_v1.png](mockups/how-to-play_v1.png) · Doop frame `wqYkvDRTfI` on [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX)

**Scene:** `scenes/ui/talk_box.tscn` · **Theme:** `themes/swipe_theme.tres` · **Tokens:** [style-guide.md](style-guide.md)

## Purpose
Tutorial / How to Play. Nib talks from the right column so the wheel is never covered (Cursor note 6), and he uses his own sprite, not the Goblin.

## Layout (1680×1040, px)
| Node | Rect / anchor | Theme |
|---|---|---|
| Wheel, hearts, hand, Spin | global layout; Spin disabled while Nib talks | — |
| Spotlight ring | dashed gold ring, r 328 (6 px, dash 10/8) around the wheel, or r 48 around one seat when the beat points at it | `_draw()` arc or `assets/ui/panels/ui_spotlight_ring.png` |
| Column | PanelOak (1086,28) 560×952 | — |
| ↳ Small label | `title.how_to_play`, top-left | LabelSmallBody |
| ↳ Portrait well | 150×150, void fill, 6 px **imp green** border, Nib 32×32 at 4× | PlateInset |
| ↳ Speaker | `tutorial.speaker`, Pixelify 42, imp green | — |
| ↳ Talk box | full width, parchment fill, 6 px edge border, padding 22, VT323 32 soot, line-height 1.12, 16 px tail pointing up at the portrait | `assets/ui/panels/ui_talkbox.png` 9-slice |
| ↳ Buttons (bottom, HBox gap 14) | Skip 150×64 ButtonOak · the beat's go button fills the rest, 76 high, ButtonGold | — |
| ↳ Progress ticks | 22×8 each, gap 8; gold = done, edge = still to go | — |

## States
Text types on at 60 chars/s. The first click finishes the line; the next click presses the gold button. Skip is always active.

## Motion
Talk box pop-in on each beat, gold pulse on the spotlight ring, Nib portrait alternating frames 0/1 at 8 fps while talking.

## Text keys (PLAYER_COPY; Jam owns the wording)
`tutorial.speaker`, `tutorial.skip`, `tutorial.beat.NN.body`, `tutorial.beat.NN.go`, `title.how_to_play`

## Rules
- Never show the word "Tier". The tier word comes from `tier.N.name` (Weak / Tough / Deadly).
- Every player-facing string comes from `data/player-copy.json` via PLAYER_COPY by the keys below. Never hard-code a string, and don't edit anything under `data/`. If a key doesn't exist yet (Jam is adding `pause.master`, `pause.music`, `pause.sound`, `door.seat_hint`), show `TODO(copy):<key>` and list it in the QA notes.
- The wheel stays visible on every in-run screen. Only Pause dims it.
- Wheel centre (548,350) and the hand centred on x 547 are locked.

## Done when
- [ ] The talk box is inside the column and overlaps neither the wheel nor the hand
- [ ] Nib uses the Nib sprite, never the Goblin
- [ ] The spotlight points at what the beat is talking about
- [ ] Skip and the advance button show on every beat
- [ ] Side-by-side QA saved to `design/visual/qa/talk_box_qa_v1.png`, with differences listed

## Cursor prompt (copy-paste)
```text
Read design/visual/style-guide.md and design/visual/SCREEN-how-to-play.md, and look at the mockup PNG(s) they link.
Build scenes/ui/talk_box.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/talk_box_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```
