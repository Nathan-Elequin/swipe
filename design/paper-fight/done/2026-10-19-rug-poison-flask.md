# Paper Fight — rug secret (Poison Flask)

**Pitch (Nathan’s words):** Pick one T2 item from buckets 1–3 that would be funny under the rug. Clicking the rug in the cabin plays a special animation that reveals that item for the first time. Nib remarks that Grandpa must have hidden it there, with a plausible quip, then says the only thing that can be done with it, pauses, and throws it off-screen to the right (it twirls, then a loud bang). Nib looks at you and says that one thing is to drop it directly in the dungeon so you can use it on your next dungeon delve. Then a non-Nib overlay says the item is unlocked and available in all future dungeon runs. Until that click, the item never shows up in the dungeon. After that click, it is as if it was always in the game. Do not change its bucket, trophy-cabinet silhouette, tier-list ranking, or mill counts. Silent toggle only.

**Restate (what the player does):** In the cabin they click the round rug (left of the fire, under the rocking chair). A one-time scene plays: the item is shown, Nib talks, he throws it off the right side of the screen with a bang, then a system line says it is unlocked. They do not get the card in hand or in the sack. Before they click the rug, the mill, Challenge, Merchant, Chaos Swap, and Echo never produce it. The trophy cabinet still shows its silhouette.

**Where it happens in a round:** Cabin only, not during a fight. Not an item click. Not used up in the hand sense. No target. No number. The unlock is copied once onto the save.

**Which existing cards this touches:**
- **Poison Flask** — the secret. T2, bucket 2. Mark a Neighbor; they lose 5 HP when you Spin them. Existing Flask rules are unchanged.
- **Mill / Challenge draft / Merchant / Mute Stone Chaos Swap / Echo Bell** — must not produce Flask until the rug click, then they treat it as a normal live card.
- **Smoke Bomb / Cube / Worm** — Cube cannot eat a card that is not in hand. Smoke cannot draft it until unlocked.
- **Hornet / Queen / Wraith / Commander / Dragon / Goblin / Mimic / Slime / empty alcove** — only collide once Flask is in a fight, using Flask’s existing mark rules.
- **Tutorial kit** — does not include Flask today. Unlocking does not inject it into the tutorial hand.
- **Developer Test / Roster** — can still place it before the rug click.
- **Trophy cabinet** — silhouette stays even before the click.
- **Bucket 2 unlock / tier list** — counted as they are now. No redistribution.

**Generous reading:** After the throw, Flask is in the mill the next time they enter a dungeon this session (including the next Adventure floor of a run already underway). Developer Test can still spawn it before the rug. Clicking the rug again does nothing.

**Stingy reading:** Flask only joins the mill on a brand-new adventure from the map. Every source, including Developer Test, refuses it until the rug. Clicking the rug again replays nothing.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Rug click during Nib’s other talk, or during the throw, queues a second scene.
- Unlock saves, but this run’s mill was already rolled, so they do not see Flask until a later dungeon and think it failed.
- Chaos Swap / Echo copies Flask before the rug because those paths skip the mill filter.
- Brand New playtest wipes cabin flags and Flask is secret again.
- Throw animation never finishes, cabin stays busy, they cannot leave.

**What the player sees:** Click the rug. Item appears. Nib talks, throws it right, bang. A system box says it is unlocked. Next new adventure from the map, Flask can show up in the mill. Rug does not look special after that.

**If we skip this:** The rug is just floor art. Flask is already in bucket 2 and can appear as soon as that bucket is open.

**If we take the strongest reading:** One rug click in the cabin between Adventure floors injects Flask into the very next mill of that same run.

**Answers (2026-10-19):**
1. Flask only joins the mill on a brand-new adventure from the map. Remaining floors of the current run stay Flask-free.
2. Clicking the rug again: Nib says one short line, no replay, Flask stays unlocked.
3. Middle Progress: still hidden. They can click the rug and see the gag.
4. Developer Test / Roster can still place it before the rug click.

**Self-audit:** restated as what the player does · named mill/Challenge/Chaos/Echo/Flask · both readings · questions answered · implemented that reading
