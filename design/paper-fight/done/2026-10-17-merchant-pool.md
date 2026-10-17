# Paper Fight — Merchant remaining pile

Locked from Nathan’s answers 2026-10-17. Implemented.

**Pitch (Nathan’s words):**

We need to tweak the logic language for the merchant here. Merchant upgrades your item by one tier. It means that tier zero items should be upgraded strictly to tier one, and so on and so forth, with tier three items being replaced by another tier three. This should be treated like drawing a card from the available pool. Which means that. In the example on screen, it should be impossible for me to get a second breastplate because I already have one. Merchant should have randomly upgraded the item that I gave it, to an available card within the respective tier pool, that exists.

**Restate (what the player does):**

The wheel lands on Merchant. He still makes you pick an item before you can use anything or press Done. That card is replaced by a random remaining copy from this dungeon’s item pile of the next tier: Tier 0 becomes Tier 1, Tier 1 becomes Tier 2, Tier 2 becomes Tier 3, Tier 3 stays Tier 3. That copy is used up, so later drafts cannot offer it. You cannot go over a card’s copy count, so a second Breastplate is illegal while you already hold the one copy, and a second Sai is legal because Sai’s count is 2. Items with nothing legal left in that destination pile are not offered. If no item can upgrade, Merchant skips the ask. Merchant stays on the wheel and still attacks for 4 when you press Done.

**Where it happens in a round:** phase / used up or kept / must they click a target? / is the number copied once or does it keep updating?

Same moment as before: after Spin, after automatic On Spin, after Cleric, after Queen lays. You must click one of the offered items. The new card is a fresh item from the remaining pile, not a number that keeps updating. The given card is gone. Merchant is not used up.

**Which existing cards this touches:**
- **Chaos Stone** — still rerolls from the catalog at the same tier and can repeat a name you hold. Merchant does not. Merchant consumes a remaining dungeon copy of the next tier.
- **Gelatinous Cube** — same lock and buttons. Merchant’s buttons are only items that still have a legal remaining copy. Cube still offers up to two snacks.
- **Spider Egg / Spider Queen** — Egg is Tier 0, so it wants a remaining Tier 1 copy. A new egg laid on this spin can be picked only if that Tier 1 pile is not empty. The egg itself is not in the dungeon pile.
- **Juggernaut Shield / Mimic gift** — extra copies that were never taken from the remaining pile. Merchant still cannot mint a name past its copy count from the remaining pile. Mimic’s gift is unchanged.
- **Sai / Throwing Knife** — count 2. Holding one still leaves the second copy in the pile, so Merchant may give the second. A third is not in the pile.
- **Breastplate** — count 1. If it is already in hand, it is not in the remaining Tier 3 pile, so Knucklers cannot become a second Breastplate.
- **Quiet Bell** — silenced Merchant still skips. Bell in hand does not change the pile rule.
- **Basilisk** — you are facing Merchant, so Gain-lock does not apply. The swap is still not a Gain.
- **Cleric** — still takes the worst item before Merchant asks. If that emptying leaves no legal upgrades, Merchant skips.
- **Hornet, Queen (combat), Wraith, Commander/Lich, Dragon pierce, Goblin, empty alcove, last owner, tutorial kit, Developer Test** — combat formulas unchanged. Tutorial still does not seat Merchant.

**Generous reading:**

Merchant mints any live open-bucket card of the next tier that you do not currently hold. Later drafts can still offer that same card. If you spend Breastplate, Merchant can give it again this dungeon.

**Stingy reading:**

Merchant takes one remaining copy from this dungeon’s item pile of the destination tier, and that copy is used up. If you already drafted or started with the only copy, you cannot get another, even after you spend it. Items with an empty destination pile are not buttons. If none can upgrade, he skips.

**Locked answers:**
1. Remaining dungeon pile, copy used up. Later drafts cannot offer that card.
2. Up to the card’s copy count. Two Sais is legal. A third is not. Breastplate stays unique because its count is 1.
3. An item with nothing legal left stays as it is; you still must pick a different item that can upgrade. If none can, Merchant skips the ask.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Minting from the catalog again, which is how the screenshot got a second Breastplate.
- Offering every item as a button, then locking Done forever when the destination pile is empty.
- Returning the given card into the pile (not asked). The given card is gone.
- Reading tier through the metal helper and turning a Tier 0 egg into a Tier 2 item.
- Chaos Stone picking up this pile rule by accident.

**What the player sees:**

Merchant still says pick an item. Only items with a remaining destination copy glow and get an Upgrade button. Click one: that card becomes a different card of the next tier that was still in the dungeon pile. Breastplate already in hand cannot appear again.

**If we skip this:**

Merchant keeps minting extra copies from open buckets, so a Knucklers upgrade can print a second Breastplate while you already hold one.

**If we take the strongest reading:**

Landing on him spends a real remaining copy of the next tier, so that card is also gone from later drafts. One click still does not end the fight by itself.

**Questions for Nathan:**
1. Remaining dungeon pile vs catalog minus current hand. **Remaining pile, copy used up.**
2. Sai count 2: second copy legal? **Yes, up to copy count.**
3. Empty destination pile: **that item stays; pick a different legal item; skip if none.**

**Self-audit:** restated as what the player does · named a live collision · both readings · questions would change the code · answers locked · implemented
