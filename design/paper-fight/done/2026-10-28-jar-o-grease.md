# Paper Fight — Jar O' Grease

**Pitch (Nathan’s words):** Rework to “Move 2 in a random direction, and Keep this.” Acts as if the user clicked a move arrow twice. Shows as tapped afterwards, and can be used again after a Spin.

**Restate (what the player does):** During a fight, click Jar O' Grease. The game picks left or right at random and walks you two living monsters in that same direction, with the same step as a move arrow. It does not spend Moves. The jar stays in your hand, shows as used, and is ready again after the next Spin. Heal 2 is gone. Holding the jar does not add a free extra seat to arrow clicks.

**Where it happens in a round:** Fighting, including Challenge and when you have 0 Moves. You click the jar, not a monster. One direction per click. Kept, tapped until Spin.

**Which existing cards this touches:**
- Move arrows: the walk matches two clicks of one arrow, and those clicks do not spend Moves. Arrow clicks themselves are one seat per Move again.
- Two living monsters: two steps in one direction walk to the other monster, then back.
- One living monster: the click is refused. Error sound. The jar stays bright.
- Keep: used overlay until the Spin cleanup that untaps kept cards.

**Answer:** Does not consume Movements. Both steps are the same direction (two left, or two right).

**Written pick:** If two steps are not possible, refuse the whole click. One undo rewinds both steps.

**Self-audit:** implemented after the answer.
