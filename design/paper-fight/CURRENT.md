# Paper Fight — Martyr gold box

**Pitch (Nathan’s words):** rewrite to, "When I lose HP, I die. When I am Defeated. My Neighbors gain HP equal to my remaining HP."

**Restate (what the player does):** Martyr is on the wheel. Something lowers his HP, or he is Defeated, or he Attacks. He dies, and living Neighbors gain HP equal to the HP he still had.

**Where it happens in a round:** During the fight, when his HP changes, when he would be Defeated, or when his turn Attacks. The card is used up (he leaves). The gift is his remaining HP at that moment, copied once. No click.

**Which existing cards this touches:**
- His own Attack (today a 0 Attack swing still kills him)
- Poison / Outbreak ticks (HP loss)
- Defeat items (Boot, Sledgehammer)
- Neighbor HP gain (same as Vampire's max-HP growth)
- Quiet Bell
- Mimic, Wick, Berserker, Victory Flask counting the Defeat

**Generous reading:** He still dies on any HP loss, on Defeat, and when he Attacks (including a 0 Attack swing). The new sentence is the same rule with a period where a comma was meant. Neighbors gain his remaining HP on that death.

**Stingy reading:** Attack is gone. He dies only when he loses HP, and the neighbor gift happens when he is Defeated. A 0 Attack swing no longer kills him. The period after "Defeated" might mean the gift is a separate sentence from the HP-loss death.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Inspect already shows the new sentence. Shift still says "On HP loss or Attack." The code still kills him when he Attacks.
- If Attack no longer kills him, Mimic's "I already Attacked" note and a 0-damage swing change.

**What the player sees:** Ability text is the new sentence. The swing still kills him until this is answered.

**If we skip this:** He keeps dying when he Attacks, and the new sentence is only on the card.

**If we take the strongest reading:** Any HP loss, any Defeat, and any Attack still kill him, and neighbors still gain the HP he had left.

**Questions for Nathan:**
1. Does swinging still kill Martyr when the swing does not change his HP (his Attack is 0)?

**Self-audit:** restated as what the player does · named a live collision · both readings · questions would change the code · not implementing this turn
