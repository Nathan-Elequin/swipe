# Paper Fight — tutorial Back

Answered 2026-11-06. Implemented the same turn.

**Pitch:** Back beside Next in the tutorial. It returns to the previous dialog line and restores the tutorial board. Wheel turns are walls. The button says Back. It does not use the Undo effect.

**Nathan’s answers:**

1. After a spin, Back still works on the lines after that spin. It cannot cross the spin.
2. The board matches the earlier line (seats, holes, takes, plays, health). The spin result stays.
3. Every wheel turn is a wall, including automatic spins.
4. The button says Back.

**Built:** `scripts/tutorial_guide.gd`, `scripts/main.gd`, `data/player-copy.json` key `tutorial.back`.
