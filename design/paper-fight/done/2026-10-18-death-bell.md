# Paper Fight — Death Bell / Toll

**Pitch (Nathan’s words):** Monster Tier 3, Bucket 9, Death Bell (giant evil sentient church bell). 12 HP 8 Atk. Call: Toll Of The Dead. When I Spawn, Gain 1 Toll. On Spin, I lose 2 HP. When I am Defeated, Discard 1 Item. Toll (token, Tier 0, black like Egg): Unplayable. On Item Use, decrease this by 1. When this reaches 0, Die. Starts at 6. When Bell appears, Toll is forced into the hotbar (player discards an Item if full). Toll counts down loudly; big scary animating aura at 1. When Death Bell dies, dialogue like Merchant. Player will want to discard Toll if they still have it; either way the Bell rings as it is defeated and leaves after the discard.

**Restate (what the player does):** When Death Bell is added to the wheel, Toll appears in the hand showing 6. If the hand is already full, they throw something away first so Toll can land. Each time they use an item, Toll’s number drops by 1. At 1 it looks like death is next. At 0 they Die. When they Spin Death Bell, the Bell loses 2 of its own HP (12 → 10 on the first Spin, and so on). They can still click Done and take 8 Attack. When they Defeat it, a Merchant-style line asks them to throw away one item (they will want that to be Toll), then a ring, then the Bell leaves.

**Where it happens in a round:** Spawn is when the slice is added to the wheel (Place / Challenge fill / Clockwork / Developer Test), not the Spin. Toll is Gain, forced, Keep-style stay in hand, Unplayable. The 6 is live and keeps updating on item uses, including later fights until it is gone or hits 0. On Spin −2 HP is automatic. Defeat discard is a click (pick one item), then ring, then leave. Toll is not used up by clicking it (you cannot click it).

**Locked answers:**
1. Full hand: player picks which item to throw, then Toll lands at 6.
2. Killing blow at Toll 1: the use ticks Toll, then the Defeat overlay happens before Die so they can dump Toll and live.
3. Second Death Bell: second Toll at 6.
4. Quiet Bell: skip the −2 HP and the Defeat discard. Tolls in hand still tick.
5. Toll at 0: Healing Potion can save.
6. Ticks = fight clicks that already increment Beads (including Bushido dummy). Not Potion auto, not Buckler auto, not Cube/Worm overlay picks.

**Self-audit:** restated · collisions named · answers locked · implemented that reading
