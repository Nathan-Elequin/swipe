# SCREEN — inspect · Direction A "Torchlit Burrow"

**Mockup(s):**
- [inspect_v1.png](mockups/inspect_v1.png) · Doop frame `aawVUQrO53` on [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX)

**Scene:** `scenes/ui/inspect_plate.tscn` · **Theme:** `themes/swipe_theme.tres` · **Tokens:** [style-guide.md](style-guide.md)

## Purpose
Inspect lives in the column's plate slot, so it can't stack with other overlays (Cursor note 5).

## Layout (1680×1040, px)
| Node | Rect / anchor | Theme |
|---|---|---|
| Hovered card | lifts 18 px with a 4 px gold ring | hand_card hover state |
| Column ↳ cue | stays (the current phase's cue) | — |
| Column ↳ Inspect plate | PlateInset 480 wide, 34 px below the cue, border in the **tier colour**, padding 20, gap 10. Contents: `inspect.title` (LabelSmall) · 150×150 well with the sprite at 8× · name Pixelify 40 · TierPill from `tier.N.name` · big value Pixelify 56 in its type colour · ability text VT323 30, centred | inspect_plate.tscn |
| Seat inspect | the same slot, filled by owner_plate.tscn (monster plate; file name stays) | — |

## States
One plate at a time: hovering something new swaps the plate. Mouse-out returns to the phase's own plate (gate / fight monster / idle box). Holding Shift (`inspect.shift`) adds the longer explanation under the ability. Disabled while spinning and while Pause is open.

## Motion
Plate swap: 0.10 s fade, then a 0.18 s pop-in. Cards don't move except for the hover lift.

## Text keys (PLAYER_COPY; Jam owns the wording)
`inspect.title`, `inspect.idle`, `inspect.shift`, `tier.N.name`

## Rules
- Never show the word "Tier". The tier word comes from `tier.N.name` (Weak / Tough / Deadly).
- Every player-facing string comes from `data/player-copy.json` via PLAYER_COPY by the keys below. Never hard-code a string, and don't edit anything under `data/`. If a key doesn't exist yet (Jam is adding `pause.master`, `pause.music`, `pause.sound`, `door.seat_hint`), show `TODO(copy):<key>` and list it in the QA notes.
- The wheel stays visible on every in-run screen. Only Pause dims it.
- Wheel centre (548,350) and the hand centred on x 547 are locked.

## Done when
- [ ] Never two inspect panels at once, and never Inspect plus Pause
- [ ] The plate shows the same value and tag as the card
- [ ] The tier shows as Weak/Tough/Deadly
- [ ] Side-by-side QA saved to `design/visual/qa/inspect_plate_qa_v1.png`, with differences listed

## Cursor prompt (copy-paste)
```text
Read design/visual/style-guide.md and design/visual/SCREEN-inspect.md, and look at the mockup PNG(s) they link.
Build scenes/ui/inspect_plate.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible. Reuse owner_plate.tscn and hand_card.tscn if they exist; otherwise build them per SCREEN-placement.md and SCREEN-hand-card.md.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/inspect_plate_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```
