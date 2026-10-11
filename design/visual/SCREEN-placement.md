# SCREEN — placement · Direction A "Torchlit Burrow"

**Mockup(s):**
- [placement_v1.png](mockups/placement_v1.png) · Doop frame `TekbnkmyD9` on [Swipe Art Refresh — Prep](https://doop.design/c/Evbwm-9bMX)

**Scene:** `scenes/ui/placement.tscn` · **Theme:** `themes/swipe_theme.tres` · **Tokens:** [style-guide.md](style-guide.md)

## Purpose
After Take it: the monster is revealed in the column and the player picks its alcove.

## Layout (1680×1040, px)
| Node | Rect / anchor | Theme |
|---|---|---|
| Wheel | global layout. **Empty** alcoves get fill `#2A1C10` and a gold "+" (Silkscreen 30) at the seat point; taken alcoves look normal and refuse clicks | — |
| Hovered empty alcove | fill `#4A3416`, 4 px gold stroke | — |
| Torch line | dashed torch-orange quadratic curve, 5 px, dash 12/8, from the door mouth (1236,190) to the hovered seat | Line2D with a dashed texture, or `_draw()` |
| Column ↳ cue | `cue.seat` | CueLabel |
| Column ↳ Door | arch 300×200, void fill, 8 px edge border with no bottom edge, torch radial glow at the bottom. **No label on the door** (DOOR OPEN dropped) | `assets/ui/panels/ui_door_open.png` |
| Column ↳ Monster plate | PlateInset 480 wide, border in the **rank colour**; 140×140 void well with the sprite at 8×; name Pixelify 36; TierPill (text from `tier.N.name`, Weak / Tough / Deadly); ATK (gold) and HP (red) in Pixelify 34 with Silkscreen tags; ability text in VT323 28 | owner_plate.tscn (shared with Fight and Inspect; file name stays) |
| Column ↳ Hint | `door.seat_hint` ("Pick an empty spot.", **new key Jam is adding**), VT323 28 dim, centred, 24 px below the plate | LabelSmallBody |
| Hand | unchanged; the new loot card is appended with a pop-in | — |

## States
Clicking a taken alcove gives that seat a 6 px horizontal shake for 0.12 s and nothing else.

## Motion
Empty alcoves pulse gold (0.9 s). The torch line's dashes scroll at 40 px/s. Monster plate pops in. On drop, the monster sprite flies from the door to the seat (0.35 s EASE_IN_OUT) and lands with a 4 px bounce.

## Text keys (PLAYER_COPY; Jam owns the wording)
`cue.seat`, `door.seat`, `door.seat_hint (new)`, `tier.N.name`

## Rules
- Never show the word "Tier". The tier word comes from `tier.N.name` (Weak / Tough / Deadly).
- Every player-facing string comes from `data/player-copy.json` via PLAYER_COPY by the keys below. Never hard-code a string, and don't edit anything under `data/`. If a key doesn't exist yet (Jam is adding `pause.master`, `pause.music`, `pause.sound`, `door.seat_hint`), show `TODO(copy):<key>` and list it in the QA notes.
- The wheel stays visible on every in-run screen. Only Pause dims it.
- Wheel centre (548,350) and the hand centred on x 547 are locked.

## Done when
- [ ] Every empty alcove clearly reads as clickable, and taken ones clearly don't
- [ ] The monster's rank shows as Weak/Tough/Deadly from tier.N.name
- [ ] No label on the door
- [ ] The hint comes from door.seat_hint and isn't hard-coded
- [ ] The whole wheel stays visible
- [ ] Side-by-side QA saved to `design/visual/qa/placement_qa_v1.png`, with differences listed

## Cursor prompt (copy-paste)
```text
Read design/visual/style-guide.md and design/visual/SCREEN-placement.md, and look at the mockup PNG(s) they link.
Build scenes/ui/placement.tscn as its own Control scene using themes/swipe_theme.tres (create or extend the theme per style-guide.md section 4 if it doesn't exist yet). Wire it into main.gd in place of the current code-drawn version. Keep all game logic and signals the same: this is a visual change only.
Rules: no edits under data/. Every string comes from PLAYER_COPY by the keys in the spec. Never hard-code text; for a missing key show TODO(copy):<key> and list it. Never display the word "Tier" (tier names come from tier.N.name). Nearest filtering, snap 2D to pixel, fonts with antialiasing off. No blur, glass or full-screen colour washes. The wheel stays at centre (548,350) and stays visible. Reuse owner_plate.tscn and hand_card.tscn if they exist; otherwise build them per SCREEN-placement.md and SCREEN-hand-card.md.
Then run the game with godot-mcp, get to this state, take a 1680x1040 screenshot, save a side-by-side (mockup left, build right) to design/visual/qa/placement_qa_v1.png, and list every spec item you couldn't match and why. Max 2 tweak rounds.
```
