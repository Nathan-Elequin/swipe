# Paper Fight — Knucklers rework (discard growth)

**Pitch (Nathan’s words):** +1 Atk for each Item you discard. Includes anything discarded for any reason WHILE you have the item (doesn't count retroactively). Base attack 0.

**Answers (2026-11-19):**
1. Counter lasts this dungeon only — resets when you leave the dungeon.
2. Punch does not include +1 for discarding Knucklers itself.
3. You can click at 0 Attack (card is used up).
4. Anything in a hotbar slot that is discarded counts, including tokens / Spider Eggs.

**Restate (what the player does):** Knucklers sits in the hotbar at 0 Attack. Every time a hotbar card is discarded while Knucklers is in your hand this dungeon, that Knucklers’ Attack goes up by 1. You click it during a fight to punch the monster you Spun for that number. The card is used up. Discards from before you took it do not count. A new dungeon zeroes the count.

**Where it happens in a round:** Count grows on discard while held. Punch is one click during a fight. Number keeps updating until you spend it or the dungeon ends. Most like Spiked Flail.

**Which existing cards this touches:** Spiked Flail, spent item uses, Beggar, Challenge cap, Death Knell, Recycler (copy starts at 0), Decay / Echo Bell / tokens / eggs, Keep (no +1 if the card stays), Goblin (0 ATK damage still spends), tutorial punch at 0.

**Clustered while coding:** If two Knucklers are in hand and you punch with one, the other still gets +1 for that discard. Recycler / Echo copies start at 0, not the donor’s count.

**Self-audit:** implemented after answers · not a second question round
