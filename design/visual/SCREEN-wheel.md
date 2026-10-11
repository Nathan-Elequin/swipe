# SCREEN — wheel · Direction A "Torchlit Burrow"

**Mockup(s):**
- [wheel-ready_v1.png](mockups/wheel-ready_v1.png) · Doop frame `eNckh5XnDR` on [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX)
- [wheel-spinning_v1.png](mockups/wheel-spinning_v1.png) · Doop frame `jmdlHkFA6W` on [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX)

**Scene:** `scenes/ui/wheel_hud.tscn` · **Theme:** `themes/swipe_theme.tres` · **Tokens:** [style-guide.md](style-guide.md)

## Purpose
The in-run base screen (wheel, hearts, hand, Spin, column). Every other in-run screen builds on it. Fixes the colliding name chips (Cursor note 4): names move to Inspect, and seats show only the sprite plus ATK and HP chips.

## Layout (1680×1040, px)
| Node | Rect / anchor | Theme |
|---|---|---|
| Hearts | (32,28) | style guide §5 |
| Wheel root (Node2D) | centre (548,350) | 8 alcove polygons drawn in `_draw()`, or TextureRects `assets/ui/wheel/ui_wheel_alcove_{full,empty,facing,hover}.png` |
| Seats | 76×76 at radius 200, 64×64 sprite; ATK chip (28 high) offset −14/−12 bottom-left, HP chip bottom-right | Silkscreen 15 700 |
| Hub | r 96 disc, hub fill, 6 px edge; VBox with HP (Pixelify 44, ATK red, plus "HP" in Silkscreen 14 dim) and BLK (blue, plus "BLK") | — |
| Pointer | gold triangle below the wheel | — |
| Spin | ButtonGold 260×68 at (418,700), font 40 | — |
| Hand | HBox at top 790, centred on x 547; 140×190 cards, or 124×190 with 8 cards | hand_card.tscn |
| Column | cue (CueLabel), then the Inspect idle box: 4 px dashed edge border, padding 26, `inspect.title` (Pixelify 34) + `inspect.idle` (VT323 30 dim) | — |

**No name chips on the ring.** Names appear only in Inspect.

## States
Ready: Spin enabled with a gold pulse. Spinning: Spin, the hand cards and inspect hover are disabled, and the cue goes dim. (The note on the spinning mockup is a designer annotation and doesn't ship.) Seat hover (ready only): alcove fill `#4A3416` with a gold stroke, and the column shows that monster in Inspect.

## Motion
Spin: wheel rotation TRANS_QUART EASE_OUT over 1.6–2.4 s, landing on a multiple of 45°. During the spin, 4 dashed gold streak arcs (r 324, 6 px, 70 % alpha) turn with the wheel and fade out over the last 0.4 s. On landing, the facing seat alone shakes 6 px for 0.12 s.

## Text keys (PLAYER_COPY; Jam owns the wording)
`cue.ready`, `combat.spin`, `inspect.title`, `inspect.idle`

## Rules
- Never show the word "Tier". The tier word comes from `tier.N.name` (Weak / Tough / Deadly).
- Every player-facing string comes from `data/player-copy.json` via PLAYER_COPY by the keys below. Never hard-code a string, and don't edit anything under `data/`. If a key doesn't exist yet (Jam is adding `pause.master`, `pause.music`, `pause.sound`, `door.seat_hint`), show `TODO(copy):<key>` and list it in the QA notes.
- The wheel stays visible on every in-run screen. Only Pause dims it.
- Wheel centre (548,350) and the hand centred on x 547 are locked.

## Done when
- [ ] The wheel, hand and column never overlap with 6, 7 or 8 cards
- [ ] No monster names on the ring
- [ ] The hub shows HP and BLK in their colours
- [ ] Spin is the only gold button and disables while spinning
- [ ] Side-by-side QA saved to `design/visual/qa/wheel_hud_qa_v1.png`, with differences listed

## Cursor prompt (copy-paste)
```text
Read design/visual/style-guide.md and design/visual/SCREEN-wheel.md, and look at the mockup PNG(s) they link.
Build scenes/ui/wheel_hud.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible. Reuse owner_plate.tscn and hand_card.tscn if they exist; otherwise build them per SCREEN-placement.md and SCREEN-hand-card.md.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/wheel_hud_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```
