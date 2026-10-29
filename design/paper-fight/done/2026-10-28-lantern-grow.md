# Paper Fight — Lantern grows

**Pitch (Nathan’s words):** Heal 1, then increase this number by 1. Keep this if you are still missing HP. At 5 HP it heals 1 and is discarded. At 4 HP it heals 1 and becomes Heal 2. Once the number is high enough, using it always fills you, so it is discarded.

**Restate (what the player does):** During a fight you click Lantern. It heals the number printed on it (starts at 1, never past 6 HP). If you are still below 6 after that heal, the card stays: you cannot click it again this fight, and the next time it says the next number (Heal 2, then 3, and so on). If the heal leaves you at 6, or you were already at 6, the card is discarded and the number does not go up.

**Where it happens in a round:** Fight, your item click, no target. The number lives on this Lantern for the rest of the run. It is not copied once and frozen. Keep matches the other Keep items.

**Which existing cards this touches:**
- Healing Potion and the other heals: same 6 HP cap. Extra heal past 6 is wasted.
- Breastplate and Throwing Knife’s keep: Keep means gone for the rest of this fight, back next fight. You do not click Lantern twice in one fight.
- Echo Bell: after a keep, Echo looks like the Lantern with the new number. Echo’s own click heals that number and is used up. It does not grow the real Lantern.
- Zombie (Keep blocked): the card is discarded, and the number does not go up.
- Bushido, Hornet, Queen, Wraith, Commander, Dragon, Goblin, Mimic, Slime: they do not change this heal. Lantern does not deal Attack.

**Generous reading:** The check is after the heal. 4 HP + Heal 1 = 5, still missing 1, so it stays and becomes Heal 2. 5 HP + Heal 1 = 6, so it is discarded.

**Stingy reading:** Same check. The number only goes up when the card actually stays. A discarded use does not leave a bigger Lantern behind. Echo does not grow it either.

**Ways it can fail:**
- The hotbar still says Heal 1 after a keep.
- A full heal discards the card but the number still goes up on a copy.
- You can click it again the same fight.

**What the player sees:** The heart on the card is the current heal. Inspect says “Heal N, then increase this number by 1. Keep this if you are still missing HP.” Shift shows that N, then +1, and Keep if you are still missing HP.

**If we skip this:** Lantern stays a flat Heal 2 that stays whenever you are still hurt.

**If we take the strongest reading:** One click never ends a fight. The strongest it gets is a heal that fills you from 1 HP and then the card is gone.

**Questions for Nathan:** None. The three examples are the after-heal check against 6 HP.

**Self-audit:** restated as what the player does · Echo and Keep are the live collisions · both readings are the same check · no open question · implemented this turn because the examples closed it
