# Paper Fight — Grappling Hook

**Pitch (Nathan’s words):**

Rework Grappling Hook. Ability: Move to Any Monster, then Draw 1 Item. No grapple animation. The player walks the shortest route the same way the move arrows walk, until the selected monster is the enemy. This does not consume movement actions.

**Rulings (2026-10-28):**

1. Jar O' Grease is ignored. The hook stops on the monster you clicked. Nathan is changing Grease separately.
2. If both ways are the same length, walk Move-right (counter-clockwise, the same direction as Shuriken).
3. If you click the monster you already face, you still draw 1 Item and the hook is used up. No walk.
4. This message overrides the locked Ability, explainer, and Flow.

**What the code does:**

Click during a fight, then click any living monster. Monsters stay in their seats. You walk the shorter way, one living monster at a time, with the move-arrow step and without spending a Move. Dead seats are skipped the same way a move arrow skips them. On-Spin abilities do not fire. Block you already have stays. Then you draw 1 Item the same way the hook drew before. The rope throw and the seat swap are gone.
