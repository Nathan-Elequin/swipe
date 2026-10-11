# SCREEN — defeat · Direction A "Torchlit Burrow"

**Mockup(s):**
- [defeat_v1.png](mockups/defeat_v1.png) · Doop frame `pfDHG19H9j` on [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX)

**Scene:** `scenes/ui/defeat.tscn` · **Theme:** `themes/swipe_theme.tres` · **Tokens:** [style-guide.md](style-guide.md)

## Purpose
Run lost. Quiet, and different from both Victory and the title screen.

## Layout (1680×1040, px)
| Node | Rect / anchor | Theme |
|---|---|---|
| Wheel | full wheel at 22 % alpha, 60 % desaturated (modulate `#5A5048`) | — |
| Hand | empty dashed slots: 140×190, 4 px dashed edge border, 50 % alpha | — |
| Hearts | all empty | — |
| Column | PanelOak, bg `#22160F`, border `#4A2F1F` (darker than usual) | — |
| ↳ Title | `title.lose`, Pixelify 84 ATK red, 90 px from the top | — |
| ↳ Sub | `title.lose_sub`, VT323 34 dim | — |
| ↳ Decoration | 3 empty hearts at 60 px, 60 % alpha | — |
| ↳ Again | `title.again`: outline button, full width × 84, font 44, gold border and text | has focus |

## States
Again has focus. No gold fills anywhere on this screen.

## Motion
Hearts dim one by one from right to left (0.1 s apart). The wheel fades to 22 % over 0.6 s. The title fades in (no pop).

## Text keys (PLAYER_COPY; Jam owns the wording)
`title.lose`, `title.lose_sub`, `title.again`

## Rules
- Never show the word "Tier". The tier word comes from `tier.N.name` (Weak / Tough / Deadly).
- Every player-facing string comes from `data/player-copy.json` via PLAYER_COPY by the keys below. Never hard-code a string, and don't edit anything under `data/`. If a key doesn't exist yet (Jam is adding `pause.master`, `pause.music`, `pause.sound`, `door.seat_hint`), show `TODO(copy):<key>` and list it in the QA notes.
- The wheel stays visible on every in-run screen. Only Pause dims it.
- Wheel centre (548,350) and the hand centred on x 547 are locked.

## Done when
- [ ] Clearly different from Victory at a glance
- [ ] Doesn't reuse the title-screen layout
- [ ] Side-by-side QA saved to `design/visual/qa/defeat_qa_v1.png`, with differences listed

## Cursor prompt (copy-paste)
```text
Read design/visual/style-guide.md and design/visual/SCREEN-defeat.md, and look at the mockup PNG(s) they link.
Build scenes/ui/defeat.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/defeat_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```
