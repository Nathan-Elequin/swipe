# Paper Fight — Decay: Use to Keep, discard other Decay

**Pitch (Nathan’s words):**
Decay needs a Subtooltip, and should be written as (and actually work like) this: 'If you Use this, Keep it and Discard all other Items with Decay.' Remove the rule that if the player ends combat or uses other items, that ALL items with Decay are discarded regardless. That's too harsh.

**Restate (what the player does):**
Zombie still marks up to two Items with Decay on Spin. Those Items stay in the hotbar if you Spin away, finish the fight, or Use a different (non-Decay) Item. Hovering Decay shows: If you Use this, Keep it and Discard all other Items with Decay. Clicking a Decay Item uses it, it Keeps, and every other Decay-marked Item is discarded right then.

**Where it happens in a round:** Zombie Spin marks / Use of a marked Item spends that click / Keep on the used Item / discard the other marked Items immediately. No click-then-target. Marks stay until you Use one, Quiet Bell, or some other discard of that Item.

**Which existing cards this touches:**
- Zombie (applies Decay)
- Keep items (already ineligible to be marked)
- Recycler (discards from Decay still count)
- Quiet Bell (clears marks, does not discard)
- Bag of Holding fill (still counts as a Use of the marked bag)
- Beggar / Cube / over-capacity discards (throw one marked Item without discarding the rest)
- Basilisk Gaze (separate mark; both can sit on a hand)
- Hornet / Queen / Wraith / Commander / Dragon / Goblin / Mimic / Slime / empty alcove / tutorial kit: no extra Decay trigger

**Generous reading (shipped):** Marks persist across fights until you Use one Decay Item. Using one discards every other currently marked Item, not only a pair partner.

**Stingy reading:** Marks expire when combat ends, Items stay unmarked. Using one only discards its original pair partner.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Spin still calling leftover unused-Decay discard (the harsh rule returning)
- Using a Shield or other Item still wiping Decay marks
- Keyword hover still saying “linked pair / unused discarded”
- Second Zombie re-marking the same Items instead of two new ones

**What the player sees:**
Violet Decay pip stays after Spin if they did not Use a marked Item. Hover Decay: the new sentence. Use one marked Item: it stays, the other marked Items leave.

**If we skip this:**
Unused Decay still dumps the marked Items on the next Spin, which is the harsh rule.

**If we take the strongest reading:**
You can bank Decay marks and spend other Items first. Using one marked Item later still Keeps it and dumps the rest. Not a one-click fight win.

**Questions for Nathan:**
None. Both removals (combat end, using other Items) were named. The Subtooltip sentence is the Use trigger and the all-other discard.

**Shipped:** 2026-11-13. Removed unused-Decay discard on Spin. Using a Decay Item Keeps it and discards every other marked Item. Keyword / inspect / Shift use Nathan’s sentence.
