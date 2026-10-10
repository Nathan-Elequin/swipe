# Example Paper Fight — “copy an owner’s attack, use it on the one you’re fighting”

Made-up pitch, used to show how the write-up should look. **Do not implement.**

**Pitch (Nathan’s words):** An item that lets you copy the attack of any unit on the board, then use that attack against your current enemy.

**Restate (what the player does):** During a fight, you click this card, then click an owner on the wheel. This card’s number becomes that owner’s ATK. That number hits the owner you spun. The card is used up.

**Where it happens in a round:** Only while you are fighting. The card is used up. You click the card, then click a target — same idea as Throwing Knife and Crossbow; it does not happen by itself. The number is a copy of the source’s ATK at the moment you click, unless Nathan says it should keep updating.

---

**Which existing cards this touches:**

- **Hornet Swarm** — attacks twice; block is spent on the first swing. Copying Hornet: do you copy the **number** or the **two swings**?
- **Spider Queen** — two swings only if a neighbor has less HP; block per swing. Copying Queen: the number, or the whole “swing twice if…” rule? If the whole rule: whose neighbors — hers, or the enemy you’re hitting?
- **Wraith** — already copies the higher neighbor’s ATK, then Commander. Copying Wraith: her printed ATK, or the **already-copied** number sitting on her slice?
- **Commander / Lich** — applied last when numbers are calculated. Copy before or after that +2 ATK / +1 HP?
- **Dragon** — ignores block. Copy the number, or also ignore block?
- **Goblin** — cannot take ATK damage. If the **source** is Goblin, you copy a number you might not be allowed to deal *to* a Goblin later. If the **enemy you are hitting** is Goblin, this item might do nothing and still be used up.
- **Slime** — ATK always equals current HP. Copy the number now, or keep matching HP as you hit?
- **Mimic** — may not have shown a real swing yet; you get an item if it dies first. What number do you copy?
- **Bandit / Wolf / Ogre / Skeleton** — their numbers were stored when the wheel landed. Copy what is on the plate now, or that stored value?
- **Serpent** — ATK drops to 0 if you already used two items this fight. If this copy is the second item, does his ATK hit 0 while you are hitting him with a copied 8?
- **Empty alcove / last owner / copying the one you’re fighting** — Throwing Knife already needs a legal target. Same rules, or can you copy the owner you spun (copy yourself a mirror) vs only *other* slices?

**Generous reading:** You copy the full combat behavior (extra swings, ignore block, “ATK = HP”) and the live formula, and you can point at anyone including the owner you spun.

**Stingy reading:** You copy a single number from the plate, one hit, you still need block to stop it, no extra swings. Empty seats are illegal. Hitting a Goblin still uses the card up for 0 damage. You cannot copy the owner you spun (must pick someone else).

**Ways it can fail:**
- Still waiting for a target after the card is used up (Throwing Knife can hit this if we get it wrong).
- Copying Hornet as two hits while “block spent per swing” does not match Hornet’s own “block on the first swing only.”
- Copying Wraith while Commander’s bonus is applied after — the number on screen is not the number you just copied.
- Tutorial: no second owner to copy; the card looks usable, click does nothing.
- Developer Test / one-owner wheel: the only target is the owner you spun — if that is illegal, the item cannot be used.

**What the player sees:** The plate already shows ATK. If the card copies extra swings and pierce, the number on the item will be wrong (it will look like 3 and then hit twice). If it copies only the number, Hornet and Queen feel misleading (“I copied the swarm and only hit once”). The Ability sentence has to pick a side.

**If we skip this:** You already have Throwing Knife (pick a slice) and Wraith (an owner copies a neighbor’s ATK). This card would not add a new kind of click.

**If we take the strongest reading:** Copy Dragon’s ignore-block, Queen’s two hits, and Slime’s ATK = HP, then point it at the owner you spun. Combat becomes: pick the scariest plate, remove whoever you landed on. The rest of the hotbar matters less.

**Questions for Nathan (answers change the code):**
1. Copy **the number on the plate** or **the owner’s combat behavior** (extra swings / ignore block / ATK=HP)?
2. Who can you copy: **any living owner including the one you spun**, or **only other slices**?
3. If the one you’re hitting is a Goblin: **the card does not fire** (not used up) or **it is used up and deals 0**?

Self-audit: restated as what the player does · named Hornet/Queen/Wraith/Goblin · both readings · three questions that change the code · not implementing.
