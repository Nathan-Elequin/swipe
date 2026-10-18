# Paper Fight — Almighty Worm (Hunger Pains)

**Pitch (Nathan’s words):** Monster, Tier 3, Bucket 3, Almighty Worm (image: sand worm like Dune, or giant purple worm). 9 Atk, 9 HP. Call: Hunger Pains. Ability: When you Spin me, you may Discard Items. Each sacrifice reduces my Atk and HP by 3. How it works: When spun, acts like Merchant or Hired Hand (dialogue, overlay so you cannot use items at this stage, a button to skip/continue when done). The player may sacrifice items, one at a time, and the unit loses atk/hp accordingly. If the enemy reaches 0 HP, they are slain which automatically triggers the end of the event and the current combat.

**Restate (what the player does):** They Spin onto Almighty Worm. Before they can click items to fight, an overlay pops like Hired Hand: hotbar is for feeding, not for attacking. They may click cards one at a time to Discard them. Each Discard makes the worm’s ATK and HP both drop by 3 (9/9 → 6/6 → 3/3 → 0/0). The plate numbers update as they go. A Continue/skip button ends the overlay. If HP hits 0 from a feed, they die immediately: loot, empty seat, combat over, no Done. If they Continue while the worm still has HP, it is an ordinary fight at the numbers left (Done hits them for that ATK). Empty hand: overlay with only Continue, then a 9/9 fight. They do not pick a target on the wheel.

**Where it happens in a round:** Right after Spin, same slot as Merchant / Hired Hand / Cube (after Queen eggs, Harpy poke, Cleric’s spin tax). Not a hotbar click. Each Discard is used up (not Keep). The −3 is live on that plate. Quiet Bell: no overlay, fight 9/9. Flee skips their Attack the way it already does, if you reached the fight.

---

**Which existing cards this touches:**

- **Hired Hand** — same overlay, click a card to Discard, not an item use, Decline/Continue to fight. Hired takes one card. Worm can take several, then Continue, or die at 0.
- **Merchant** — same “you must finish this before items or Done.” Merchant takes one upgrade. Worm takes zero or more Discards.
- **Gelatinous Cube** — feed overlay, two choices, one feed. Worm is open-ended until Continue or death.
- **Healing Potion / Hex / Egg / Marble / petrified / Double-Buckler** — Hired lets you Discard any of those. Worm might too, or only “real” unspent items.
- **Quiet Bell** — overlay off, 9/9 fight.
- **Harpy** — poke happens before this overlay. You can already be hurt, then feed.
- **Cleric** — currently Heals and steals your worst item on Spin *before* Merchant/Hired ask. A neighbor Cleric can eat a card before you can feed it to the worm.
- **Commander** — +2 ATK reapplies after each −3. HP still drops 9→6→3→0, so three feeds still kill. Leftover fight ATK is 8/5/2 instead of 6/3/0 if you Continue early.
- **Wraith** — copies the live ATK after feeds.
- **Slime** — not this body. ATK and HP both drop by 3; ATK does not track HP except that they start equal.
- **Hornet / Damsel / Kobold / Shambling Mound / Double-Buckler** — only if you Continue into a fight. Then remaining ATK is a normal swing (6 is even, Buckler can halve).
- **Dragon pierce / Goblin / Mimic** — Goblin skip (you’re not hitting them). Mimic gift is if they never Attack; feeding them to death is a kill before they Attack, so Mimic-style gift would not apply (they’re not Mimic). Dragon only if you Continue and they’re Dragon.
- **Grappling Hook / Damsel neighbors** — Merchant/Juggernaut: not a real Spin, no overlay. Same here unless Nathan says facing counts.
- **Zombie** — Discard is not Keep. Fine.
- **Needleback / Twins / Prism** — feeds are not your Attack.
- **Triclops** — can steal the Spin onto the worm, then overlay.
- **Flee** — if you Continue into a fight, Flee skips their Attack. Whether 6/6 stays on the wheel for the next Spin is a question.
- **Empty / last owner / tutorial / Developer Test** — three feeds can clear the last monster and win the dungeon. Tutorial does not seat them. Developer Test can.

**Generous reading:** Any card in hand, like Hired Hand. Numbers stay reduced on the wheel (Flee and come back at 6/6, overlay again). Three cheap cards (Egg, Hex, Potion) buy a free kill and loot. Continue at 3/3 for a small fight.

**Stingy reading:** Only unspent non-petrified “real” items. Stats reset to 9/9 next Spin if they lived. Cleric steals first. Hook does not trigger the overlay. Empty hand: 9 ATK in the face.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Overlay never clears: Done stays locked, fight stuck.
- Fourth feed after 0 HP, or −3 through 0 into negative ATK, Shift shows −3.
- Feeding counts as an item use: Harpy pokes, Kobold extra swings, Zombie eats, Cleric mid-feed.
- They hit 0 HP but take the leave-alive path: 0 HP worm still on the wheel.
- Continue at 0 HP instead of auto-slay.
- Quiet Bell still opens the overlay.
- Shift still says 9 after two feeds.

**What the player sees:** Land, worm talks, dim overlay, hotbar still visible. Click a card: it tosses, plate 9/9 becomes 6/6. Click another: 3/3. Third: death movie. Or press Continue at 6/6 and fight a 6 ATK Done. Cannot click Shield to Block during the overlay.

**If we skip this:** Merchant already pauses the fight for a hotbar pick. Cube already feeds. Nothing lets you pay items to shrink a 9/9 into a corpse or a 3/3.

**If we take the strongest reading:** Three Eggs or Hexes delete a Tier 3 9/9 and you never take the hit. Flee after one feed locks them at 6/6 forever. Last monster in the dungeon can be bought out.

**Questions for Nathan:**
1. After you feed and Continue (or Flee), do the new ATK/HP stay on that slice for later Spins, or do they go back to 9/9 next time you Spin them?
2. What can you Discard into the worm: any card in hand like Hired Hand (Hex, Potion, Egg, Marble, petrified), or only unspent items that are not petrified?

**Answers:**
1. The new ATK/HP stay on that slice. Next Spin they’re reduced and the overlay happens again.
2. Everything in hand can be discarded (Hex, Potion, Egg, Marble, petrified). Spent Keep cards should not exist yet because the fight just started.

**Self-audit:** restated as what the player does · named Hired Hand, Merchant, Cleric, Commander, Flee, Quiet Bell · both readings · questions would change the code · implemented after answers
