# Draft gate spec: Direction A, Layout 1 "Side Door" (2026-10-11)

Mockup: `design/visual/mockups/draft-gate-A-torchlit-burrow.png` (1680×1040). The B and C mockups use the same layout so the styles can be compared directly.

Goal: players grasp fast that finer loot means a fiercer monster joins the dungeon. The wheel is always visible. One decision: Take it / Leave it (3 passes). After Take, the monster reveals and the player picks a slot.

## Geometry (1680×1040)
- Wheel: unchanged from the current build (centre ≈ (710, 350), r ≈ 300). Nothing overlaps it during ask/reveal/seat.
- Gate column: x 1086, y 28, 560×952. Fixed in every draft mode. No full-screen dim.
- Hand: under the wheel (x ≈ 390, y ≈ 780), 150×200 cards, 18 px gap.
- Nib (optional peek): bottom-left of the hand, 16×16 @5×.

## Column stack (ask)
| Element | Copy key (verbatim) | Style |
|---|---|---|
| Cue | cue.ask "Take it or leave it?" | Pixelify Sans 46, parchment |
| Rule | door.help "The finer the loot, the fiercer its monster." | VT323 30, torch #F09A34 |
| Door arch 300×230 | door.owner "THE MONSTER" (small label) | monster sprite as a black silhouette, red eyes, rank plate (Weak/Tough/Deadly, metal colour) |
| Loot card 400 w | door.shiny "THE LOOT"; item name; door.guard "Guarded by a {tier} monster" | 8 px loot-gold border, 1.2 s glow pulse, item @8× on a 150 px pedestal |
| Take 470×84 | door.take "Take it" | gold primary |
| Leave 470×60 | `COPY.fill("door.pass", {"n": n})` when n ≥ 2; `door.pass_one` "Leave it (1 pass left)"; `door.pass_none` "No passes left" | outline secondary |
| Pips | none | 3 × 34×12, torch fill / hollow |

## Reveal (after Take)
Slam SFX → 80 ms hit-stop → 6 px column shake → silhouette black→colour 150 ms → loot flies to hand 250 ms → monster plate in the column → cue becomes door.seat "A monster approaches. Select their location."

## Seat
Empty alcoves pulse (0.8 s), "+" shown; hover draws a dotted torch line from the door to the alcove; click seats with a 120 ms pop.

## Implementation
See `CURSOR-PROMPT-DRAFT-GATE.md`.
