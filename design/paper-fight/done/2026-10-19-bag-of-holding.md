# Paper Fight — Bag of Holding

**Pitch (Nathan’s words):** Bag of Holding. Ability: Bag an enemy with less HP than you. On Use, checks HP like The Boot. If successful, the hotbar card becomes a closed bag named Bag of (Monster Name), with that monster’s sprite on the bag and an HP badge of the HP they had when captured. Ability then reads: Bag an Enemy with Less HP than this. Later uses compare the captured HP to the current enemy and bag them the same way (new sprite, name, badge). Bagged is treated like Defeated; combat resolves as normal. When there are 0 monsters left, and before any victory or progression, the bag is automatically discarded (loud untie/open) and the most recently captured monster is released in the exact state it was bagged, including permanent HP/ATK gains and poison marks. Does nothing if never used before the dungeon finishes.

**Restate (what the player does):** During a fight you click this card. If the owner you spun has less current HP than you, they leave the wheel the way Boot would Defeat them. The card stays in the hotbar, now closed, titled Bag of that monster, showing their sprite and the HP they had. Next fight you click it again: if the new owner has less HP than the number on the bag, they replace whoever was inside. When the wheel has no owners left, the bag opens, is gone from the hotbar, and that last captive sits back down as they were. If you never clicked it, it just sits there through the clear.

**Where it happens in a round:** Only while you are fighting, on the owner you spun — same click as Boot, not a second pick like Throwing Knife. First check uses your current HP. Later checks use the frozen HP on the bag (copied once at capture, does not keep matching the captive’s live HP). The card is not tossed on a successful bag; it transforms. It is tossed only when the dungeon would clear and a monster is inside. A failed HP check does not spend it (Boot does not spend on fail).

**Which existing cards this touches:**
- **The Boot** — same first check (enemy current HP < your current HP). Equal HP fails. This card then keeps a frozen HP for later bags.
- **Sledgehammer / Hex / Fangs / Paci-Fist / Scythe / Polymorph / Napalm / Pocketwatch** — other Cheese. This one also skips a fight if you planned the number. Bucket 7 already has Napalm as its Cheese. Hole 01 on the shopping list was Utility.
- **Gargoyle** — Boot cannot Defeat them unless they are silenced. If bag is the same Defeat path, Gargoyle cannot be bagged.
- **Phoenix Egg / Phoenix** — Defeat runs hatch / rebirth instead of removing them. Boot on an Egg does not kill the Egg; it becomes a Phoenix. Same path would mean you cannot actually put them in the bag.
- **Commander** — can Flee on Defeat instead of leaving. Triclops can bail. Wick fires on Defeat. Death Bell taxes Defeat. Toll can kill you on death/Defeat. Mimic still gifts if Defeated before they attack.
- **Goblin** — ignores Attack damage; Defeat still works. 1 HP is an easy first bag.
- **Hornet / Queen** — extra swings never happen if they are Defeated. Bag skips the swing the same way.
- **Dragon** — pierce does not apply; this is not Attack.
- **Slime** — ATK = HP does not matter for the check. You compare HP. The bag stores the HP they had, not a live Slime formula.
- **Bodyguard / Hollow / neighbors** — they leave the slice. Neighbor formulas on whoever remains recalc as after a normal Defeat.
- **Wraith / last-in-calc** — stored ATK on the captive is the plate number at capture, not a neighbor that may be gone later.
- **Net / Quiet Bell / silence** — bag does not need them to attack. Silence would only matter if we reuse Gargoyle’s Defeat block.
- **Keep / toss / hotbar replace** — this stays in the same slot and changes art/name/ability. Not a mill Token. Marble / Spider Egg / Blood Pact / Toll are different.
- **Victory Flask / Counting Beads / Scythe / mobs_defeated** — “treated like Defeated” means those counters should tick when you bag, unless we say the captive is only gone for now.
- **Empty alcove / last owner / tutorial** — only legal while fighting a living owner. Tutorial kit does not include this card. Bagging the last living owner is the empty-dungeon case.
- **Challenge refill** — Defeat empties a seat and the deck may refill. Release happens only when the dungeon would otherwise be empty, so Challenge’s last bag still hits the 0-owners gate before a clear.

**Generous reading:** Bagging the last owner still clears the dungeon; they do not come back. Phoenix, Gargoyle, Commander, Triclops, Wick, and Death Bell do not intercept — the monster actually goes in the bag. Kill counters and Mimic gift still count. It fills shopping-list hole 01 in Bucket 7 even though it plays like Cheese.

**Stingy reading:** Bagging the last owner discards the bag and sits them back down as a new fight (you no longer have the bag). Same Defeat extras as Boot: Gargoyle immune, Egg hatches, Phoenix becomes Egg, Commander/Triclops can leave instead of being captured. It is Cheese, so it does not occupy Bucket 7’s Utility hole next to Napalm.

**Ways it can fail:**
- Bag the last owner → 0 left → bag opens → they sit down → you bag them again → loop, unless the bag is already gone.
- Treat as Defeat and Phoenix Egg never enters the bag (hatch instead); the card looks like it fired and nothing is inside.
- Gargoyle: click does nothing, same as Boot, but the closed-bag art might already have been drawn if we transform before the check.
- Release onto an empty Challenge wheel with an empty deck: nowhere to sit, or they sit in a hole and refill fights you already paid.
- Hotbar name/ability/art update while inspect still shows the empty-bag Ability.
- Two captures: only the latest is released; the first is gone forever. If kill counters already ticked for the first, they do not come back — correct unless we wanted a stack.
- Death (not a clear): bag still in hand, captive never released. Next dungeon would still be holding a monster from the last one unless we wipe it.

**What the player sees:** The empty bag is a Boot check with your HP. The closed bag shows a monster stamp and a heart number. Later clicks compare that heart to the owner you spun. When the last owner would end the dungeon, they see the bag open and that monster sit down before any clear screen.

**If we skip this:** Boot already Defeats on enemy HP < your HP. Net / Hex / Polymorph already change who is on the wheel. This card’s new job is “Defeat now, pay them back before you leave.”

**If we take the strongest reading:** Bag whoever is smaller than you (or smaller than the last captive), including the last owner, and they never return. One click can end a dungeon. Phoenix and Gargoyle cannot stop it. That is stronger than Boot, Hex, and Pocketwatch.

**Questions for Nathan:**
1. After you bag the last living owner: does the bag open and sit them back down as a new fight (bag is gone), or does the dungeon clear and they stay gone?
2. Do Phoenix Egg, Phoenix, Gargoyle, Commander, Triclops, Wick, and Death Bell treat this like Boot’s Defeat, or does the monster actually go in the bag and those extras wait until release?
3. This plays like Cheese (Boot). Hole 01 was Utility in Bucket 7, which already has Napalm as Cheese. Keep it as that Bucket 7 Utility hole, or place it as Cheese somewhere else?

**Self-audit:** restated as what the player does · named Boot/Phoenix/Gargoyle/Napalm/last owner · both readings · questions would change the code · not implementing this turn


**Answers:**
1. Bounce. The bag opens and is gone. That owner sits back down as a new fight. You cannot bag them with this card again.
2. Into the bag as they are. Phoenix / Gargoyle / Commander / Triclops / Wick / Death Bell wait until a later Defeat.
3. Keep hole 01: Bucket 7, Tier 2, Utility slot. Napalm stays the Cheese of that bucket.

