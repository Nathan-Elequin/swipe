# SCREEN — victory · Direction A "Torchlit Burrow"

**Mockup(s):**
- [victory_v1.png](mockups/victory_v1.png) · Doop frame `7MyA7Ur1DR` on [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX)

**Scene:** `scenes/ui/victory.tscn` · **Theme:** `themes/swipe_theme.tres` · **Tokens:** [style-guide.md](style-guide.md)

## Purpose
Run won. Its own screen instead of reusing the title card (Cursor note 7).

## Layout (1680×1040, px)
| Node | Rect / anchor | Theme |
|---|---|---|
| Wheel | empty wheel at 50 % alpha (no seats, no hub numbers) | — |
| Loot glow | radial gold 25 % → 0, 840×600, centred at (548,390) | `assets/vfx/vfx_glow_gold.png` |
| Loot pile | this run's loot sprites at **6×** (96×96), heaped around the hub | — |
| Hearts | as they were at the end | — |
| Column | PanelOak with a **gold** 8 px border | — |
| ↳ Title | `title.win`, Pixelify 72 gold with a 6 px torch drop, 70 px from the top | — |
| ↳ Sub | `title.win_sub`, VT323 34 parchment, 30 px below | — |
| ↳ Nib | 16×16 at 10× (160×160), smug frame (frame 2), 50 px below | — |
| ↳ Again | `title.again`, ButtonGold, full width × 88, font 48, at the bottom | has focus |

## States
Again has focus by default.

## Motion
Loot items drop into the pile one by one (0.08 s apart) from y −60, each with a 4 px bounce. The title pops in after the last item, with 16 gold square particles.

## Text keys (PLAYER_COPY; Jam owns the wording)
`title.win`, `title.win_sub`, `title.again`

## Rules
- Never show the word "Tier". The tier word comes from `tier.N.name` (Weak / Tough / Deadly).
- Every player-facing string comes from `data/player-copy.json` via PLAYER_COPY by the keys below. Never hard-code a string, and don't edit anything under `data/`. If a key doesn't exist yet (Jam is adding `pause.master`, `pause.music`, `pause.sound`, `door.seat_hint`), show `TODO(copy):<key>` and list it in the QA notes.
- The wheel stays visible on every in-run screen. Only Pause dims it.
- Wheel centre (548,350) and the hand centred on x 547 are locked.

## Done when
- [ ] Doesn't reuse the title-screen layout
- [ ] The pile shows this run's actual loot
- [ ] Again is the only button and has focus
- [ ] Side-by-side QA saved to `design/visual/qa/victory_qa_v1.png`, with differences listed

## Cursor prompt (copy-paste)
```text
Read design/visual/style-guide.md and design/visual/SCREEN-victory.md, and look at the mockup PNG(s) they link.
Build scenes/ui/victory.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/victory_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```
