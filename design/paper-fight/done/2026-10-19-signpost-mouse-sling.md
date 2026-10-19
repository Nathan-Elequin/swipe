# Paper Fight — Signpost, Mouse, Sling

**Pitch (Nathan’s words):** Item T1 Signpost: Block 7, then choose a Neighbor to Attack you. Monster T1 Mouse 4/2 Scurry: When you Spin me, if you have more HP than me I lose 2 HP and Flee. Item T1 Sling (bucket at least 1 after Bag of Marbles): Your next attack this fight can target Any monster. Forces the player to select an Item that deals Atk damage. Same choose-1 interface as Pocketwatch. Great Axe still works, but targets the neighbors of the newly-selected target.

**Restate (what the player does):**

- **Signpost:** During a fight they click Signpost, then click a living Neighbor. Signpost is used up. They Gain 7 Block, then that Neighbor Attacks them. They do not click Done. They are still fighting the facing enemy after this, unless the answer below says the Neighbor leaves.
- **Mouse:** The wheel lands on Mouse. Before they can use items, if their current HP is greater than Mouse’s current HP, Mouse loses 2 HP and Flee (random spin). If their HP is equal or lower, they fight the 4/2 (or whatever HP is left).
- **Sling:** During a fight they click Sling. If they have no other item that deals Attack, it is grey. Otherwise they pick one Attack item (one pick, same idea as clicking a Pocketwatch target). That attack can then go to Any living monster on the wheel. Great Axe still hits that monster and that monster’s Neighbors. Sling is used up. Bag of Marbles is bucket 5, so Sling is bucket 6.

**Where it happens in a round:**

- Signpost: fight, click then click a Neighbor. Used up. Block 7 is a Gain now. The Neighbor’s Attack is that plate’s live number (and maybe its full Attack specials).
- Mouse: On Spin, before the fight. They do not click. Mouse is not used up; they Flee or they sit and fight. The −2 is a current-HP change, not a copy.
- Sling: fight, click Sling, pick an Attack item, then (now or later) pick Any monster. Sling used up. The Attack item is used up when it actually hits, unless it Keeps.

---

**Which existing cards this touches:**

- **Pocketwatch** — click then pick. Signpost picks a Neighbor who Attacks *you*. Sling’s first pick is an Attack *item* in the hotbar, not a monster.
- **Hornet Swarm / Queen / Damsel / Kobold / Shambling Mound** — extra swings. Signpost: if the Neighbor’s Attack is a full plate, Hornet hits you twice into the new Block 7 (Block spent on the first swing). Damsel as the Neighbor would make *her* Neighbors Attack you, then Heal 3. Sling does not copy extra swings onto your item.
- **Wraith / Commander / Lich / Slime / Dire Wolf** — live ATK on that Neighbor’s plate is what hits you on Signpost.
- **Dragon / Arrow Head pierce** — a Dragon Neighbor ignores the Block 7.
- **Goblin** — Signpost: Goblin Attacking you still hits you. Sling: Goblin still cannot take the redirected Attack.
- **Mimic** — Signpost making them Attack you is an Attack, so the gift does not apply from that. Mouse Flee is not Defeat, so Mimic gift does not pay.
- **Anvil** — Mouse seats at 1 HP. Player almost always has more HP, so −2 goes to 0 on the first Spin.
- **Needleback / Harpy** — Signpost is you getting Attacked, not you Attacking. Sling’s redirected hit is an Attack, so Needleback pokes you.
- **Eel** — Signpost Gain 7 Block chips Eel for 7, then the Neighbor Attacks you.
- **Bodyguard / Cowardly King** — Signpost hit can redirect onto Bodyguard. King: lose HP then Attack+Flee is not this (Signpost is them Attacking you).
- **Quiet Bell** — Mouse: Scurry is the unique ability, so Quiet Bell skips it and you fight. Signpost/Sling items still work.
- **Flee / Shuriken / Phoenix / Commander** — Mouse uses the live Flee rule: 0 HP seats leave and fill, then Flee random-spins if they still have HP. Last Mouse on the wheel can Scurry into a spin that lands on themselves again.
- **Wick** — Flee does not chip. Defeat does. Mouse hitting 0 from the −2 is the fork below.
- **Healing Potion / HP 6** — first Spin on a 4 HP Mouse almost always Scurries.
- **Bag of Marbles / Marble / Chakram** — Sling’s Attack-item list uses the same “deals Attack” check as Chakram: Marble counts, Double-Buckler does not, Caltrops/Net do not, Defeat does not. Chakram counts only if its Attack half is live.
- **Great Axe** — with Sling, hits the chosen monster plus that monster’s Neighbors, each once. Two owners left: the other one still takes one hit if they neighbor the new target.
- **Crossbow / Longbow / Throwing Knife** — already have a pick or a facing hit. Sling lets that hit go to Any instead.
- **Last Match / Spiked Shield** — Sling itself does not deal Attack. Picking an Attack item does not change Last Match until that item is spent.
- **Bushido** — Sling is an item use. If the Attack fires as a second click, dummy can eat it.
- **Empty / last owner / tutorial / Developer Test** — Signpost with no Neighbor is unplayable. Sling with one owner: Any is that owner. Mouse last-on-wheel Scurry can loop. Tutorial kit does not include these unless Developer Test seats them.

**Generous reading:** Signpost: full plate Attack into you, Neighbor stays, you keep fighting the facing enemy. Mouse: −2 to 0 is just Flee (they leave, wheel spins, Wick does not chip). Sling: pick the Attack item and it fires now at Any (one flow). Great Axe neighbors of the new target.

**Stingy reading:** Signpost: one ATK number once, no Hornet second swing, and/or the Neighbor leaves as if you clicked Done on them. Mouse: −2 to 0 is a Defeat (loot, Wick). Sling: used up as a mark; you must click that same Attack item later; a different Attack item stays facing-only; if you never click it, Sling is spent for nothing.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Signpost waiting for a Neighbor after the card is already gone.
- Signpost with no Neighbor still Grants 7 Block and hangs.
- Damsel Neighbor on Signpost Heals you 3 and leaves, or hits you with both neighbors and you die under Block 7.
- Mouse last-on-wheel: Scurry Flee lands on Mouse again, −2 to 0, infinite Flee.
- Mouse −2 to 0 counted as Flee so Wick never chips, or counted as Defeat so Phoenix/Triclops clauses fire.
- Sling pick overlay includes Shield / Boot / Caltrops.
- Sling then Great Axe still cleaves the *old* facing neighbors.
- Sling mark on Knife, they click Shield, Any is still armed on the next Attack and they did not expect it.
- Targeting Any still hanging after the Attack item is tossed.

**What the player sees:** Signpost: Block jumps to +7, then a Neighbor lunges at them. Mouse: they Spin a 4/2, it drops to 2 and the wheel moves by itself. Sling: pick an Attack item, then pick anyone on the wheel, that hit goes there. Great Axe fans out around whoever they picked.

**If we skip this:** Shield is Block 4. Damsel already makes neighbors Attack you. Basilisk / Phoenix already Flee on Spin. Crossbow already picks a Neighbor. Measuring Tape already picks Any for Defeat. Nothing is Block 7 then a chosen Neighbor hit, nothing Scurries on higher HP, nothing retargets your next Attack item to Any.

**If we take the strongest reading:** Signpost vs a 1 ATK Neighbor is free Block leftover. Signpost vs Dragon is suicide. Mouse at 4 HP never stays for a first fight against a healthy player; they only sit when you are at 4 HP or less, or after Quiet Bell. Sling + Great Axe can hit three seats from anywhere on the wheel, including killing the facing enemy without facing them.

**Questions for Nathan:**
1. Signpost: does the Neighbor use their full Attack (Hornet twice, Dragon pierce, Damsel neighbors) or only the ATK number once?
2. Signpost: after that Attack, does the Neighbor stay (you still fight the facing enemy) or leave as if you had clicked Done on them?
3. Mouse: if the −2 HP would drop them to 0, are they Defeated (loot, Wick) or do they Flee (0 HP seat leaves, then random spin)?
4. Sling: after you pick the Attack item, does that item fire now (then you pick Any), or is Sling spent as a mark and you click that item later?

**Answers (2026-10-19):**
1. Full plate (Hornet twice, Dragon pierce, Damsel neighbors, live Wraith/Wolf).
2. Neighbor stays. Still fighting the facing enemy.
3. Lose HP before Flee. If that kills them, death/slice removal immediately (Defeat: loot, Wick). If they still have HP, then Flee.
4. Fire now — pick Any monster and that Attack item fires in the same use. Sling and the item both spent unless the item Keeps.

**Shipped 2026-10-19.**
