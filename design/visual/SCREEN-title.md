# SCREEN — title · Direction A "Torchlit Burrow"

**Mockup(s):**
- [title_v1.png](mockups/title_v1.png) · Doop frame `pntDhzJhSf` on [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX)

**Scene:** `scenes/ui/title_screen.tscn` · **Theme:** `themes/swipe_theme.tres` · **Tokens:** [style-guide.md](style-guide.md)

## Purpose
The first screen: one unmistakable Play button (fixes Cursor note 1, weak Play).

## Layout (1680×1040, px)
| Node | Rect / anchor | Theme |
|---|---|---|
| Background glow | radial TextureRect centred at (840,470), 1040×760, gold 13 % → 0 | `assets/ui/logo/ui_title_glow.png` |
| Ghost wheel | empty wheel at 35 % alpha, centred at (840,350), r 300 (the title is the one screen where the wheel is centred) | wheel scene, `modulate:a 0.35`, no seats |
| Loot | 16×16 potion at 5× (80×80), top-left at (800,96) in the wheel's top alcove, with a gold glow | `assets/ui/logo/ui_title_bait.png` (file name stays) |
| VBox (anchors full rect, centred) | — | — |
| ↳ Logo | "Swipe" (key below), 170 px, gold, two-step drop (torch 8 px, then `#3A2414` 14 px) | Pixelify Sans 700; a bitmap logo `assets/ui/logo/ui_logo_swipe.png` can replace it later |
| ↳ Subtitle | 34 px below the logo, VT323 38, parchment | BodyLabel |
| ↳ **Play** | 46 px below, **380×96**, font 56 | ButtonGold, initial focus |
| ↳ Secondary HBox (gap 18) | 26 px below Play: three 240×58 buttons, font 30 | ButtonOak |
| Nib | 16×16 at 8× (128×128) at (1380,820), idle loop | `assets/sprites/nib/nib_idle.png` (4 frames) |

## States
Play: hover raises the drop edge 6 → 8 and the gold ring pulses. Keyboard and gamepad focus start on Play. Secondary buttons use the ButtonOak states.

## Motion
Logo pop-in at t=0, Play pop-in at t=0.15 s, loot gold pulse on a loop, Nib idle at 6 fps.

## Text keys (PLAYER_COPY; Jam owns the wording)
`title.overlay`, `title.sub`, `title.begin`, `title.how_to_play`, `title.dive_in`, `title.adventure`

## Rules
- Never show the word "Tier". The tier word comes from `tier.N.name` (Weak / Tough / Deadly).
- Every player-facing string comes from `data/player-copy.json` via PLAYER_COPY by the keys below. Never hard-code a string, and don't edit anything under `data/`. If a key doesn't exist yet (Jam is adding `pause.master`, `pause.music`, `pause.sound`, `door.seat_hint`), show `TODO(copy):<key>` and list it in the QA notes.
- The wheel stays visible on every in-run screen. Only Pause dims it.
- Wheel centre (548,350) and the hand centred on x 547 are locked.

## Done when
- [ ] Play is the largest, brightest control and is focused by default
- [ ] The only gold on screen is the logo, Play and the loot
- [ ] Secondary buttons are outline-only
- [ ] No Kenney panels left
- [ ] Side-by-side QA saved to `design/visual/qa/title_screen_qa_v1.png`, with differences listed

## Cursor prompt (copy-paste)
```text
Read design/visual/style-guide.md and design/visual/SCREEN-title.md, and look at the mockup PNG(s) they link.
Build scenes/ui/title_screen.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/title_screen_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```
