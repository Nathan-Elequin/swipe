# Paper Fight — Lich numbers + Hydra Devour +2 ATK

**Pitch (Nathan’s words):** Lich to Tier 3, 3 HP, 6 ATK, same ability. Hydra to Tier 2, 5 HP, 3 ATK, changed ability — “…I Defeat them and Gain +2 ATK”. It gives Hydra flat scaling instead of gaining their attack when they die.

**Answers (2026-11-02):**
1. Hydra still Gains +2 when Devour runs even if they stay (Lich chip, Flee, Phoenix).
2. +2 stacks each meal (3, then 5, then 7…).

**Mill after implement:** Lich stays Pool 3 Deadly. Hydra stays Pool 5 Tough. Phoenix Egg stayed Deadly — Spider Queen is Adventure extra, so Pool 3 mill Deadly is Damsel, Phoenix Egg, Lich (three). No extra mill drag.

**Shipped:** catalog + board + `hydra_bonus += 2` instead of plate Attack. Ability: `If any other Monster has its HP reduced to 3 or less and survives, I Defeat them and Gain +2 ATK`.
