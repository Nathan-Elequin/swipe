# Paper Fight — Double-Buckler

**Pitch (Nathan’s words):** Item, Tier 1, Bucket 2, Double-Buckler (image: buckler). Ability: Unplayable. Take half damage the next time you receive Even Atk damage, then Discard this. How it works: works like Healing Potion, but instead of procing on lethal, it always listens for the amount of incoming Atk from the next hit from an enemy, assuming it is even. It reduces that amount by half (before the attack lands, with an item animation mid-swing), and then discards itself. It would halve only the FIRST attack of a multi (like hornet swarm). It would halve only the first attack of a multi-unit attack (like Damsel). It does not proc on taking 0 atk damage.

**Restate (what the player does):** They never click this card. It sits in the hotbar like Healing Potion (grey, Unplayable). The next time an enemy’s Attack actually hits them for an even ATK number, the card plays itself mid-swing, that hit is cut in half, then the card is discarded. Later swings in that same Hornet / Damsel / Kobold / Shambling Mound burst are full. Odd hits and 0-damage hits do not spend it. They do not pick a target. Integer half: 2 becomes 1, 4 becomes 2.

**Where it happens in a round:** During an enemy Attack (Done, Damsel neighbor, Harpy poke, Coward, Needleback), before that swing finishes. Used up when it fires. No click. The even check is on that swing’s ATK (or on leftover HP, if Nathan picks that). It keeps sitting until that eligible hit, including across fights, like Potion waiting for lethal.

---

**Which existing cards this touches:**

- **Healing Potion** — same auto, unclickable, first copy in hand, still listens while petrified. Potion saves after HP hits 0. Buckler changes the hit before HP is lost. If the halved hit still kills, Potion can still save.
- **Hornet Swarm** — two swings. Only the first swing can be halved. Second swing is full, and the card is already gone if the first was eligible.
- **Damsel** — left neighbor then right. Only the first of those Attacks can be halved.
- **Kobold / Shambling Mound** — extra / until-dead swings. Same: first swing of that burst only.
- **Block / Shield** — Ability says take half *damage*. How-it-works says halve incoming *Atk* before the swing lands. Those are different if you have Block.
- **Dragon / Arrow Head pierce** — Block does not apply. Even pierce ATK still halves if the even check is the ATK number.
- **Wraith / Commander / Slime** — the live ATK on that swing. Commander +2 can flip odd to even or even to odd.
- **Goblin** — you are not hitting them. Skip.
- **Mimic** — if they Attack, this can fire. Gift is only if they never Attack.
- **Needleback** — poke is 1 ATK (odd). Never even, never fires. Still an enemy hit.
- **Harpy** — poke is an enemy Attack. If that ATK is even, this is the next hit from an enemy.
- **Spider Egg** — you take Attack from an item, not an enemy. Does not listen.
- **Poison / Bleed / Napalm / Ale Flagon** — not Attack. Does not listen.
- **Hex** — also Unplayable. Hex still does its job. Buckler still listens. Both can sit together.
- **Twins / Hollow** — even-twice is you hitting *them*. Skip.
- **Quiet Bell** — does not turn item passives off.
- **Basilisk petrify** — Potion still saves while petrified. Same here unless we say petrify also muffles passives.
- **Cleric** — can steal this as lowest-tier before it ever fires.
- **Zombie** — no Gain/Keep. Holding this is fine; Discard on fire is not Keep.
- **Empty / last owner / tutorial / Developer Test** — tutorial kit does not seat it. Developer Test can. Last owner Done still Attacks.

**Generous reading:** Even means the enemy’s ATK number on that swing is even, and leftover after Block would be more than 0. Cut that ATK in half, then apply Block. Fully blocked even swings leave the card. If Hornet/Damsel’s first swing is odd or 0 leftover, a later even swing in that same burst can still fire it. Egg never. Harpy even poke can.

**Stingy reading:** Even means leftover HP after Block is even and greater than 0 (so a 5 ATK vs 1 Block is a 4 and fires). Or: first swing of a burst is the only chance; if that one is odd or fully blocked, later swings in the burst cannot fire it. Fully blocked even ATK still consumes the card because the ATK was even. Halve leftover after Block, not the ATK number.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Shift still shows full Hornet 2+2 while the first swing is actually 1.
- Fires on a fully blocked 2 and you already had 2 Block, so you paid the card for 0.
- Fires on Spider Egg 2 even though that is not an enemy.
- Halves Hornet’s second swing because “next even” waited past an odd first.
- 0 ATK (even number) consumes the card.
- Two copies both fire on one swing.
- Clickable in a fight and you spend it for nothing.
- Half of 2 stored as 0 because of integer truncation the wrong direction.

**What the player sees:** Grey Unplayable card, no number to click. Mid-swing the card lifts like Potion, ATK 4 becomes 2 (or leftover 4 becomes 2), then the card is gone. Hornet still lunges twice; only the first lunge is quieter.

**If we skip this:** Potion already auto-saves you. Shield already reduces a hit if you click it first. Nothing sits and halves the next even enemy swing.

**If we take the strongest reading:** You hold this through odd chip damage, then the first even leak (Dragon 6, Hornet 2, Slime even HP) is cut in half and the card leaves. With Block 1 vs ATK 4 you take 1 instead of 3, or 2 instead of 4, depending on order. Two copies cover two even leaks.

**Questions for Nathan:**
1. What gets halved, and what has to be even?
2. If Hornet/Damsel/Kobold/Mound’s *first* swing is odd or deals 0, can a later swing in that same burst still fire Double-Buckler?

**Answers:**
1. That swing’s ATK number is even. Cut ATK in half, then apply Block. (ATK 4 vs Block 1 → 2 vs 1 → take 1.)
2. Yes. It waits for the first even hit in that burst, then later swings are full.

**Self-audit:** restated as what the player does · named Potion, Hornet, Damsel, Block, Dragon, Egg, Harpy · both readings · questions would change the code · implemented after answers
