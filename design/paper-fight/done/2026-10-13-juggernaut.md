# Paper Fight — Juggernaut

**Pitch (Nathan’s words):**

New monster. Tier 2 (Bucket 2). Name Juggernaut. Picture of a heavily armored melee fantasy guy. Call name Blockhead. Attack 9, HP 5. Ability: “When you face me, Gain a Shield.”

When the player Spins this unit, they gain the Item Shield. Animation: Juggernaut literally moves over directly to the player hotbar and gives them the item in the closest empty spot.

**Restate (what the player does):**

You click Spin. The wheel stops on Juggernaut. He walks from his seat to the hotbar, plants a Shield in the nearest empty slot, and walks back. You do not click a target for the gift. The fight is then a normal 9 Attack / 5 HP scrap. You may click that Shield this fight (4 Block, used up), save it, or spend other cards to kill the 5 HP. Juggernaut is not used up by the gift. When you later press Done, he still swings 9 unless you already killed or defeated him.

**Where it happens in a round:** phase / used up or kept / must they click a target? / is the number copied once or does it keep updating?

Same moment as Spider Queen’s egg and Merchant’s choice: the spin has landed, Cursed Scroll and the siphon jars have already had their chance to hurt you, then he walks. No click. The Shield is the live Shield card (Gain 4 Block, used up). It is a new card, not a number that keeps updating. He stays on the wheel. Quiet Bell on him skips the walk.

Bucket: **2**, as named.

---

**Which existing cards this touches:**

- **Shield** — this is that card. Click it for 4 Block, then it is gone. 4 Block vs his 9 leaves 5 through.
- **Spider Queen** — same Spin can lay an egg and then hand you a Shield.
- **Mimic** — gifts if he never swings. Juggernaut gifts on the Spin, then still swings 9 unless you kill the 5 HP.
- **Merchant** — you only get Juggernaut’s Shield when the wheel lands on Juggernaut.
- **Grappling Hook** — swaps a neighbor into the face seat without a new Spin. Does not pay.
- **Damsel** — a neighbor Juggernaut hits you. No Shield.
- **Wraith** — can copy his 9. You face Wraith, so you take 9 and get no Shield.
- **Quiet Bell** — no walk, no Shield. He is still 9 / 5.
- **Basilisk** — this Spin faces Juggernaut, so the Shield stays.
- **Tutorial kit** — do not seat him.
- **Hotbar sort** — after he plants it, the bar re-sorts and the Shield slides into the Block group.

**Generous reading:**

The Shield is a fresh extra copy. Grappling Hook him into the face seat and he walks. Damsel’s neighbor Juggernaut also hands you one. He stays in the slot he walked to.

**Stingy reading:**

Only a real Spin onto him. The Shield is taken from this dungeon’s leftover Shield copies. After he plants it, the bar re-sorts.

**Questions for Nathan:**

1. Grappling Hook: Shield or not?
2. Fresh extra copy, or leftover pile copy?
3. Stay in that slot, or re-sort into the Block group?

**Self-audit:** restated as what the player does · named Shield, Queen, Mimic, Merchant, Grappling Hook, Damsel, Wraith · both readings · questions would change the code · not implementing that turn

## Nathan's answers

- Grappling Hook: no. Only a real Spin onto him.
- Fresh extra copy, like Queen’s egg. The dungeon can still draft its normal Shield later.
- After he plants it, the bar re-sorts and the Shield slides into the Block group.
