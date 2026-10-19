# Paper Fight — bucket size, tier mix, and item types

Shipped 2026-10-19 from Nathan’s answers.

**Pitch (Nathan’s words):** Bucket 0 is 10 items and 10 monsters, 5 tier 1 / 3 tier 2 / 2 tier 3, no tokens. Later buckets shrink: 5 and 5. Items roughly 30% attack, 30% defense (block + heal), 20% cheese, 20% other utility. Monsters get more words and tracking as buckets go up. Fill from 0 onwards. Demote to fill tier 1.

**Answers:**
- Smoke Bomb stays extra (forced opening card, not one of the 10).
- Fill every bucket fully before the next. Last used bucket may be short. Do not Hold leftovers.
- Start by demoting (new simple T1 cards later).
- Heal counts as Defense with Block.
- Defeat widens to Cheese (skip / trivialize a fight with planning): Boot, Fangs, Sledgehammer, Paci-Fist, Scythe, Hex, Polymorph, Catapult, Napalm, Poison Flask, Pocketwatch.
- Later 5-card type mix: 2–1–1–1 rotating extra ATK or Defense, until the leftover cards run out of Utility.
- Mode-only cards are a side pool (do not count toward 10/5). Pair them in the same bucket so Challenge and Adventure extras cancel: Harpy + Lich in 2, Catapult + Danger Magnet in 4, Spider Queen in 6, Clockwork Knight in 7.
- Phoenix is Token (not drafted). Phoenix Egg is a mill monster.
- Goblin in Bucket 0 with Boot and Net.
- Unlock: one bucket per dungeon ending (clear or death) in Challenge Mode. That path already incremented; left as-is.
- 3-Seeker stays Hold.

**Later tier mix:** 3 + 2 + 1 is six cards. A 5-card bucket cannot be 3/2/1. Shipped later buckets as 2 / 2 / 1 (the 50/30/20 split of Bucket 0, rounded to five cards). New T1 cards later can bump this.

**Shipped mill (mode `all` only; Smoke / Phoenix / mode-only extras sit on top):**
- Bucket 0 items: Shield, Sai, Throwing Knife, The Boot, Net / Crossbow, Victory Flask, Quiet Bell / Healing Potion, Sledgehammer
- Bucket 0 monsters: Wizard, Golem, Hornet Swarm, Goblin, Bandit / Dire Wolf, Mimic, Needleback / Dragon, Slime Boss
- Buckets 1–8: 5 items each. Monsters 5 each through 7; bucket 8 is four leftover T3 (Worm, Basilisk, Damsel, Death Bell).
- Demotions (tier only, no number changes): Bandit, Wick, Juggernaut; Cursed Scroll, Knucklers, Jar O' Grease, both Bracers, Blood Chalice, Spiked Shield; Lantern, Paci-Fist, Bag of Marbles, Breastplate, Phoenix Egg (T3→T2).

**Code:** `BucketRules` WANT_ZERO 10, WANT_LATER 5, MAX_BUCKET 8. Mode-only and Smoke skipped in the count. Last used bucket may be short.
