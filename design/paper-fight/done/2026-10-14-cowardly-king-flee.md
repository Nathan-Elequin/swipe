# Paper Fight — Cowardly King Flee

**Pitch (Nathan’s words):**

First Save: Slight REWORK: "...when I would be defeated, I Flee." Flee is a Keyword. Flee means the monster survives and triggers a Spin.

Then in chat: rewrite AGAIN. Remove all other aspects of that character. Same tier/bucket. 7 HP and 3 ATK. Ability is Coward: "Whenever I lose HP, I Attack you and Flee." Flee tooltip: "Flee: if you are facing them, Spin." Spin is a keyword too. If he dies from a loss of HP, he cannot Flee. Commander uses the same Flee keyword (survive + Spin, no shuffle was the option picked, then Flee was redefined to only Spin if you are facing them).

**Restate (what the player does):**

The pass-to-the-right is gone. They hit the King like a normal monster. 3 Attack, 7 HP. Whenever the King loses HP and is still alive, he immediately hits them for 3 (Block still applies), then Flee: if they are facing him, the wheel Spins. They do not click Flee. If the same HP loss drops him to 0, he dies and does not Flee. Quiet Bell turns this off.

**Where it happens in a round:** phase / used up or kept / must they click a target? / is the number copied once or does it keep updating?

On the wheel. Automatic, the moment his HP number goes down. No extra click. Not used up. The 3 is his printed Attack, used at that moment. Flee is only a Spin, and only if they are looking at him. Closest live cards: Harpy (hits you in the middle of a fight) plus Commander’s old leave-interrupt, without the shuffle.

**Which existing cards this touches:**
- Crossbow / Longbow / Double Axe — a side hit that does not kill him makes him Attack you. Flee does not Spin, because they are not facing him.
- Poison Flask — spinning onto him deals 5. He goes 7 → 2, Attacks, then Flee Spins because they are facing him. Combat has barely started.
- Da Boot / other Defeat — Defeat is not HP loss, so no panic Attack and no Flee. He leaves.
- Shield / Block — his panic Attack spends Block. If Flee then Spins, Block dumps.
- Anvil — not on him. If a hit is passed onto Anvil, irrelevant; King now takes his own hits.
- Needleback — if King takes Attack damage, Needleback is not involved; King then Attacks the player.
- Hornet — two swings at the player do not touch King’s HP.
- Damsel — if King is a neighbor and attacks as a Damsel swing, that is him Attacking, not him losing HP, so Coward does not fire from that. If Damsel’s neighbor hits the King, it would.
- Commander — same Flee keyword. His trigger is still “first time I would leave,” unless this rewrite also changes that. Death may block Flee.
- Grief Jar / Queen / Cleric / Magnet — a Flee Spin is a real Spin.
- Mimic — a Boot kill is not HP loss, so no panic Attack. A lethal Attack kill: he cannot Flee, so he leaves, and Mimic gift depends on whether he already Attacked.
- Goblin / Bodyguard — pass-right is gone, so they no longer sit behind him.
- Empty / last owner — a non-lethal hit on the last King Spins the same seat again.
- Tutorial kit — he is not in it.
- Developer Test — can seat him.
- Wick / Vampire — HP-loss listeners on the player, not on the King.

**Generous reading:**

One HP-loss event (a 4-damage hit) is one panic Attack, then Flee. A lethal hit just kills him: no Attack, no Spin. Crossbow poke from the side: one Attack at you, he stays, current fight continues. Commander still survives the first leave, then Spins if you are facing him, and no longer shuffles.

**Stingy reading:**

Each heart lost is its own Attack. A 4-damage Crossbow is four hits at you from off-seat. A lethal hit still Attacks you as he dies, then he does not Flee. Commander no longer survives: if the leave is death, Flee does nothing and he dies; if the leave is Block, Flee Spins only when you are facing him.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Poison on Spin: lose 5, Attack, Flee Spin, land on him again, infinite if the flask is still marked.
- Facing him, chip 1 HP, Flee Spin, never get to click Done.
- Lethal 7-damage hit Attacks you and also tries to Spin because Flee was queued before HP hit 0.
- Commander death and King death use different “cannot Flee” rules, but both paint Flee.
- Ability still says the old pass-right line because it is locked, so the card lies.

**What the player sees:**

His call reads Coward. 3 Attack, 7 HP. No pass walk. When his HP drops and he lives: he swings at the hub, then if they are facing him the wheel Spins. Flee and Spin are painted like Attack. Hover Flee shows “if you are facing them, Spin.”

**If we skip this:**

He still passes Attack to the right and stays after Take or Safe. Boot and poison still kill him. No panic Attack.

**If we take the strongest reading:**

Any chip while facing him Spins the fight away. Crossbowing him from the side can dump several 3-Attack hits into you. Poison on Spin can loop. Commander no longer gets a second life.

**Questions for Nathan:**
1. Locked fields on Cowardly King (ability, explainer, call name, flow, notes, Attack, HP) — is this chat the override?
2. A 4-damage hit that does not kill him: one Attack, or one Attack per heart?
3. A killing blow: does he still Attack you as he dies, or does he just die?
4. Commander: still survives the first time he would leave, then Spins if you are facing him (no shuffle)? Or he now panics on HP loss like the King?

**Answers (2026-10-14):**
1. Yes — overwrite those locked King fields with this rewrite.
2. Once. One HP-loss event is one Attack, then Flee.
3. He just dies. No Attack, no Flee.
4. Same as today, minus shuffle: the first time Commander would leave, he survives, then Spins if you are facing him.

**Self-audit:** restated as what the player does · named a live collision · both readings · questions would change the code · implemented after answers

