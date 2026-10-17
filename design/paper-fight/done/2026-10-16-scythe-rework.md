# Paper Fight — Scythe rework (measuring_tape)

**Pitch (Nathan’s words):** Gold box: REWORK: "Defeat any Monster with exactly double your HP". Player can select any Monster on the wheel (including their current opponent). Otherwise, this functions exactly like The Boot and Sledgehammer in terms of function and animation.

**Restate (what the player does):** During a fight they click Scythe. Then they click a monster on the wheel. If that monster’s current HP is exactly twice the player’s current HP, that monster is Defeated the same way The Boot and Sledgehammer Defeat: the fight with them ends at once, Scythe is used up, there is no Attack number and no Heal. If the HP is not exactly double, Scythe does not Defeat them.

**Where it happens in a round:** Fight. Used up on a successful Defeat. They must click a target on the wheel (Boot and Sledgehammer do not). The check uses live HP, not a number copied earlier.

**Which existing cards this touches:**
- **The Boot / Sledgehammer** — same Defeat, used-up, animation. Boot checks HP < yours on the one you face. Scythe checks HP = 2× yours and lets you pick any seated monster.
- **Crossbow / Longbow / Arrow Head** — already click-then-pick on the wheel. Crossbow can kill a neighbor and leave you in the current fight. Scythe picking someone you are not facing is the same fork.
- **Fangs** — another Defeat. Fangs hits the one you face, then Heals. Scythe does not Heal.
- **Paci-Fist** — Defeat if you hold no Attack items. Scythe is Defeat-colored, so it should not count as an Attack item for that check.
- **Goblin** — Attack would deal 0 and they would live. Defeat still removes Goblin (Boot already does).
- **Gargoyle petrify** — picks the highest Attack item. Scythe has no Attack, so Gargoyle should ignore it the way it ignores Boot.
- **Anvil** — cannot lose more than 1 HP at a time. Defeat is not HP loss, so Anvil still leaves.
- **Wick** — waits to die at 0 HP until Done. Defeat is not 0 HP from Attack.
- **Cowardly King** — first Defeat makes them Flee and Spin. If Scythe Defeats them, that is a Defeat.
- **Quiet Bell** — strips unique; printed HP still used for the double check.
- **Mimic** — Defeat removes them; you do not get the gift that needs them to never swing, if they already would have.
- **Hornet / Queen / Dragon pierce** — no extra swings. Defeat skips the Attack-to-0 path.
- **Slime** — ATK = HP is irrelevant. The check is their HP vs yours.
- **Empty alcove / last owner / tutorial** — no monster in that seat is not a legal click. Tutorial kit does not include Scythe today. Developer Test can.
- **Harpy** — if Scythe Defeats the one you face, Harpy’s extra hit should not fire. If it Defeats someone else, the current Harpy fight is still on.

**Generous reading:** Click Scythe, then click any living monster whose HP is exactly 2× yours. They are Defeated and leave. If that was the one you are fighting, combat ends (Boot). If it was someone else, they vanish and this fight keeps going (Crossbow kill). Scythe is used up. Grey/unplayable only when no seated monster currently matches.

**Stingy reading:** Click Scythe, then click a monster. Only the one you are already fighting can actually be Defeated, and only if their HP is exactly 2× yours. Picking anyone else is a “cannot,” and Scythe stays. Or: Scythe is always clickable, and a wrong pick still spends it.

**Ways it can fail:**
- Still dealing half-HP Attack and Heal (the live `atk_hp_gap` code) while inspect says Defeat.
- Letting them click empty corridors or already-dead seats and getting stuck waiting for a target.
- Spending Scythe on a miss (Boot does not spend on “cannot”).
- Jumping facing when they meant to snipe a neighbor, or sniping a neighbor when they meant to end this fight.
- Goblin treated as “cannot Defeat” even though Boot Defeats Goblin.
- Cowardly King’s Flee interrupting a fight they were not even in.

**What the player sees:** Scythe reads Defeat, not an Attack number. After the click, the wheel should look pickable, including the one they already face. Legal targets are the monsters whose HP is exactly twice theirs.

**If we skip this:** Live Scythe is still Attack equal to half HP, Heal that much, Keep if they live.

**If we take the strongest reading:** One click can remove any matching monster on the wheel, including one you are not fighting, and end or not end the current fight depending on who you picked. That is a targeted Boot.

**Questions for Nathan:**
1. After they click Scythe, they click a monster they are **not** fighting. Does that monster leave while this fight keeps going (like Crossbow killing a neighbor), or do they jump into that monster’s fight and it ends?
2. If nobody on the wheel currently has exactly twice their HP, is Scythe grey like Boot when the enemy is too tough, or can they still click it and then get a “cannot” after they pick?

**Answers (2026-10-16):**
1. They leave the wheel. This fight keeps going (like Crossbow killing a neighbor).
2. Grey / unplayable, like Boot when they have as much HP as you or more.

**Self-audit:** restated as what the player does · named a live collision · both readings · questions would change the code · implemented after answers
