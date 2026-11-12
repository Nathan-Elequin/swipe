# Paper Fight — finish nested hits before the next fight

**Pitch (Nathan’s words):** Pocketwatch on Dire Wolf, Dire Wolf Attacks Prism. Prism telegraphs Refract onto both neighbors. One neighbor is the monster you are facing. That first hit kills them, and the game starts the next fight before Prism’s second neighbor takes their hit. Wrong. Resolve the current item and every nested effect inside it entirely first. Then resolve deaths. Only after that, if the seat in front of you is empty, run the next fight.

**Answers:**
1. Leave them at 0 HP until every remaining nested hit of this use has also applied. Then resolve all deaths (Wick, Phoenix, loot, flee). Then, if the seat in front of you is empty, one next fight / draw / Spin.
2. Every item use this turn that hits more than one monster — Double Axe, a chain of Prisms, Needleback thorns during the same Attack.

**Shipped:** `scripts/main.gd` — `_defer_slay`, `_hit_tree_enter` / `_hit_tree_leave`. Prism Refract applies every share before Defeat. `_begin_slay` does not start a new fight while a hit tree is open. Scenario `prism-refract-both-before-slay`.
