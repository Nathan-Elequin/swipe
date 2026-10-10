# Paper Fight — Roster notes on wave 2 (ten redesigns)

**Pitch (Nathan’s words):** Roster review notes on the ten new cards. Chain Keep. Beads cycle 1–2–3–4. Last Match → Paci-Fist if zero Attack items. Tape → Scythe (double HP, Heal 2 Keep if they live). Mute → Chaos Stone (reroll two same-tier items, Adventure upgrade motion). Basilisk: discard on use. Hollow → Twins (even Attack or Block happens twice). Beggar copies leftmost Attack item. Wick +1 ATK −1 HP per item use anywhere, no Slay until Done. Anvil: max 1 HP lost from any source; extra Attacks chip extra 1s.

**Restate (what the player does):**

- **Chain:** Click in a fight. Deal Attack equal to Block you hold. Keep the Block and Keep the card.
- **Counting Beads:** Click in a fight. Deal the dungeon cycle (1→2→3→4→1). Every item use advances it. Used up. Shared number if two Beads.
- **Paci Fist:** Click in a fight. If you hold no items that deal Attack, Defeat them. This is not an Attack item. Used up when it works.
- **Scythe:** Click in a fight. Deal Attack equal to twice your current HP. If they still have HP (including Goblin), Heal 2 and Keep. If they die, used up, no Heal.
- **Chaos Stone:** Click, then click other items. One other item: reroll that one. Two or more: pick two. Cannot target itself. Unplayable if it is the only item.
- **Basilisk:** While you face them, every item you use is discarded immediately.
- **Twins:** Even Attack to them hits twice. Even Block gained while facing them is gained twice. Odd once.
- **Beggar:** Attack copies the live Attack number on the leftmost Attack item after sort. None: Attack 3.
- **Wick:** Every item use, every Wick on the wheel +1 Attack −1 HP immediately. Not removed until the current fight ends. Facing Wick at 0 HP: they do not Attack; Done Slays them.
- **Anvil:** Max 1 HP from one source. Poison Flask −1, not an Attack. Two Attacks chip 1 twice.

**Where it happens in a round:** Items click during a fight. Chaos Stone needs a second click on hotbar cards. Beads cycle carries fights, not dungeons.

**Which existing cards this touches:** Hornet extras vs Anvil; Goblin vs Scythe survive; Gargoyle vs Paci Fist Defeat; Quiet Bell strips uniques; Echo face counts as Attack for Paci Fist; Cube feed is not an item use.

**Generous reading:** Chosen. See restatement.

**Stingy reading:** Not used.

**Ways it can fail:** Chaos waiting after the stone is gone (cancel by clicking the stone). Wick 0 on the wheel until Done. Wick count still 0, so they do not mill.

**What the player sees:** Scythe shows 2×HP. Beads show 1–4. Chaos Stone purple reroll motion. Done stays up on a Wick at 0 HP.

**If we skip this:** (shipped anyway)

**If we take the strongest reading:** Shipped.

**Questions for Nathan:** answered 2026-10-08.

1. Chain: copy Block, keep Block, Keep the card.
2. Beads: every item use advances; click deals the current number; used up; shared dungeon number.
3. Paci Fist: not an Attack item. Zero Attack items → Defeat. Holding only this works.
4. Scythe: Goblin counts as survive. Heal 2 and Keep.
5. Chaos: one ok if that is all you have; two when you have two+; pick other items, not itself.
6. Twins: even Attack and even Gain Block twice.
7. Beggar: base is 3 (override locked atk_base). Leftmost after sort, skip no-Attack.
8. Wick: +1 Attack −1 HP globally; delay slay until this fight’s Done.
9. Anvil: Twins two hits = 2 HP. Poison −1, not an Attack.
10. Names: Paci Fist stays. Measuring Tape → Scythe (override locked blank ability). Mute Stone → Chaos Stone. Hollow → Twins. Wick count 0 stays. Beads locked ability/explainer stay.

**Self-audit:** implemented after answers
