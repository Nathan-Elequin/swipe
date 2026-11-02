# Parked 2026-10-30 — Hydra rework (Devour)

Moved out of CURRENT.md so the Trapper Bear Trap Paper Fight can use that file. Not implemented.

---

# Paper Fight — Hydra rework (Devour)

**Pitch (Nathan’s words):** Tier 3, 7 HP, 2 ATK. Call name Devour. Ability: If any other Monster has its HP reduced to 3 or less, I Defeat them and Gain their ATK. While on the wheel, listen for any HP reduction (player ATK, monster ATK including Pocketwatch / Needleback Spiky, Poison ticks, Ogre Empath, Death Bell on Spin). After the current action finishes (Needleback’s 2 to you first), Slash Portrait, then Defeat them the same way a Defeat item would. Commander may Flee; Lich may only lose 1 HP; Hydra still Gains the Attack they had.

**Restate (what the player does):** Hydra sits on the wheel. The player does not click Hydra to fire this. Whenever another monster’s HP goes down, wait until that whole action is done, then if that monster is at 3 HP or less Hydra’s portrait slashes and that monster is Defeated as if you had used Boot / Hex / Sledgehammer on them. Hydra’s Attack goes up by the Attack that monster had. Hydra stays. The player keeps playing.

**Where it happens in a round:** Passive while a living unsilenced Hydra is on the wheel (not only while you are facing Hydra). Not used up. No target click. The Attack gained is a copy of the victim’s Attack at that moment (whether that copy is the plate or the printed number is a question below). It does not keep tracking the victim after they leave.

---

**Which existing cards this touches:**

- **Needleback / Pocketwatch** — ATK between monsters. Spiky’s 2 to you finishes first; then Devour if Needleback (or the one who got hit) is at 3 or less.
- **Poison / Plague Doctor** — ticks are HP loss. Frozen poison while Plague Doctor lives does not fire Devour.
- **Ogre (Empath)** — your HP loss copies onto Ogre. If that copy drops Ogre to 3 or less, Devour after that action.
- **Death Bell** — Spin −2 HP. Crossing 3 Defeats the Bell (discard overlay) and Hydra Gains 8 Attack.
- **Commander** — first Defeat Flees and random-Spins. Hydra still Gains that Attack. Commander starts at 3 HP, so the first time their HP actually goes down (3→2 or a killing blow), Devour can fire.
- **Lich** — Defeat only chips 1 and Keeps a real Defeat item. Hydra’s Defeat is that same Defeat path, so Lich loses 1 and Hydra still Gains Attack. Lich starts at 2 HP and cannot lose HP to ATK, so the first real reduction is usually another Defeat item (Boot chips 2→1, then Devour may chip again).
- **Wraith** — Defeat sets your HP to Wraith’s last HP. Devour is a Defeat, so eating Wraith heals or bleeds you.
- **Phoenix / Phoenix Egg** — Defeat before they Attack lays an Egg. Egg Defeat Flees and hatches.
- **Cowardly King** — HP loss commands the right-hand monster to Attack you after the item. That command is part of the action (same idea as Spiky), then Devour. Defeat itself does not command.
- **Bodyguard** — the neighbor never lost the HP; Bodyguard did. Devour looks at who actually dropped. Bodyguard starts at 3 HP.
- **Goblin** — ATK does not reduce them. Poison or other HP loss can. They start at 1 HP.
- **Anvil** — each loss is at least 3 HP. One chip can jump Anvil from 4 to 1 (or 0) and trip Devour.
- **Amalgam** — after an item, remaining HP and ATK double. They can dip to 3 during the hit and bounce to 6 before the action ends.
- **Martyr** — any HP loss kills them and gives remaining HP to neighbors. Devour may try to Defeat someone already dead from their own rule.
- **Triclops** — they Defeat themselves at exactly 3 HP. Different card; same number.
- **Hornet / Queen** — extra swings are one action. Check after both swings.
- **Hex / Boot / Sledgehammer / Scythe / Fangs / Paci-Fist** — already Defeat. If that drop is also “to 3 or less,” Devour may fire on top.
- **Quiet Bell** — silenced Hydra does not listen (same as other on-wheel specials). Gained Attack already on Hydra stays.
- **Empty alcove / Hydra itself** — “any other Monster.” Hydra does not Devour itself. Empty seats are not monsters.
- **Tutorial kit** — Hydra is Pool 5. Tutorial does not need this.

**Generous reading:** After every action, Devour every other living-or-just-killed monster who touched 3 HP or less at any point (including a 5→0 kill and a Boot that already Defeated them). Gain the full plate Attack (Commander neighbor +2, Amalgam doubled, displayed number). Eat the whole row if Poison dropped four of them. Lich gets a second chip after Boot.

**Stingy reading:** After the action, only monsters who are still alive at 1–3 HP. A killing blow or a Defeat item that already resolved does not also feed Hydra. Gain only printed Attack. If several qualify, only the first (facing first, then clockwise).

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Infinite loop: Devour Defeats A, Wick or Empath or King reacts, another HP drop, Devour again, forever.
- Two Hydras both listen; each Defeat is another reduction for the other.
- Lich + Boot: inspect says “HP reduced to 3 or less” but the player already used a Defeat item — two chips from one click if we take the generous reading.
- Amalgam / heals: text says “reduced to 3 or less” (the moment) vs “after the action” (the end HP). Those can disagree.
- Combat stuck if Devour eats the facing monster mid-item and loot / next-spin never runs (same path as a Crossbow kill off-facing).
- Slash Portrait on a slice you are not facing; easy to miss who died.

**What the player sees:** Hydra’s portrait slashes. A monster at 3 or less leaves (or Lich chips, or Commander Flees). Hydra’s Attack number goes up. They did not click Hydra.

**If we skip this:** Hydra stays Even Killer (petrify evens, +2 Attack each). Nothing else eats a neighbor for dropping low.

**If we take the strongest reading:** One Poison tick or one Pocketwatch can clear every monster who is at 3 or less and stack their Attack onto a 7 HP Hydra. Combined with Lich/Wraith/Phoenix on-Defeat rules, one drop can rewrite your HP, lay an Egg, and grow Hydra.

**Questions for Nathan:**
1. If the hit already killed them (5→0), does Hydra still Gain that Attack?
2. After the action, do we Devour whoever is still at 3 or less, or anyone who dipped to 3 or less even if they healed or doubled back up (Amalgam)?
3. If a Defeat item already resolved on them this action (Boot on Lich, Boot that already Defeated someone), does Hydra still Devour?
4. Gain the Attack on their plate right then, or only the printed Attack?
5. If several monsters qualify in one action, Devour all of them or only the first?

**Self-audit:** restated as what the player does · named Needleback, Lich, Commander, Wraith, Amalgam, Death Bell · both readings · questions would change the code · not implementing this turn
