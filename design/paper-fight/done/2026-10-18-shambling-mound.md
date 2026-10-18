# Paper Fight — Shambling Mound (Self Deconstruct)

**Pitch (Nathan’s words):** Monster, Tier 1, Bucket 4, Shambling Mound (image: shambling mound). 4 HP, 1 Atk. Call: Self Deconstruct. Ability: I Attack repeatedly until I die. I lose 1 HP each time I Attack. How it works: Like Hornet Swarm, but should just have an infinity symbol for the number of attacks (or it could be 99 if you can't make the infinity symbol work).

**Restate (what the player does):** They land on Shambling Mound and fight it like anyone else. They can click items first. When they click Done, the mound Attacks them over and over with no click in between, Hornet-style. Each Attack is 1 (plus Commander if a neighbor is buffing them). After each Attack they lose 1 of their own HP. They keep going until that HP hits 0. The player cannot click between those hits. Healing Potion can still save a lethal swing the way it already does on Hornet. Flee skips the whole Attack, so they do not fall apart that fight. Quiet Bell: they Attack once for 1 and stay at 4 HP.

**Where it happens in a round:** Only their Attack on Done (unless Nathan says Damsel / Pocketwatch also count). They do not take a click from the hotbar to start it. The swing count is live remaining HP at Done, not a copy from fight start. The card is not used up — it is a monster. The × badge on the plate is ∞ (99 only if the font cannot draw ∞). Shift’s incoming math uses remaining HP, not 99, so 4 HP and 0 Block reads as 4, not infinity.

---

**Which existing cards this touches:**

- **Hornet Swarm** — two swings, Block leftover carries. This is the same movie with swing count = remaining HP, then they die. Hornet’s ×2 badge becomes ∞ here.
- **Kobold Trapper** — extra swings from items you used. Shambling Mound does not add those. If you are fighting Kobold, Mound is unrelated.
- **Damsel (Two-Headed Serpent)** — neighbors Attack you using that neighbor’s swing count. If Mound is a neighbor, either they hit once for 1 and live, or they run the full loop and can die on Damsel’s wheel.
- **Pocketwatch** — hypnotize uses the source’s swing count against the enemy you are facing. If that source is Mound, either one hit of 1, or HP-many hits and Mound can die as the weapon.
- **Wraith** — copies the higher neighbor ATK number, not extra swings. A Mound neighbor is a 1 (or Commander’s 3). Wraith does not inherit Self Deconstruct.
- **Commander / Lich** — Commander’s +2 ATK is last. Each remaining swing is 3, not 1. Four swings of 3 is 12 if you never chip them.
- **Dragon** — ignore Block. Mound is not Dragon. Your pierce items still pierce when you hit Mound.
- **Goblin** — cannot take ATK damage. You are not fighting Goblin. Mound’s self HP loss is not your Attack, so Goblin rules do not apply to the −1.
- **Mimic** — gift if they go down *before* they Attack. Mound going down *because* they Attack is not a Mimic gift. Killing Mound with items before Done is a normal kill.
- **Slime** — ATK = HP. Mound’s printed ATK stays 1 as their HP falls, unless Commander is buffing.
- **Needleback** — pokes you when they take Attack. Self Deconstruct is their own HP loss, not you Attacking them. No poke from the −1.
- **Twins** — even Attack hits them twice. Same: the −1 is not your Attack.
- **Prism** — dumps Attack onto neighbors. Same: the −1 is not your Attack.
- **Anvil** — HP floor 1 is Anvil’s own body. Mound can hit 0.
- **Cowardly King / Commander flee** — they leave after Attack, still alive. Mound dies from the loop, so this is a Defeat path, not a flee path, if they actually reach 0.
- **Quiet Bell** — special off: one swing, they live, then they leave the fight still on the wheel.
- **Flee / skip-swing items** — no Attack, no HP loss, they stay. Same as Hornet never swinging.
- **Healing Potion / Cleric** — Potion can save a lethal swing mid-burst. Cleric waits until the whole burst, then pays once per HP you actually lost.
- **Napalm / Bleed / your ATK items** — chip them first, fewer Done swings. Kill them before Done and they never Attack.
- **Empty alcove / last owner / tutorial / Developer Test** — after they die the seat is empty. Last-on-wheel is a dungeon win the same as any Defeat. Tutorial does not seat them. Developer Test can.

**Generous reading:** Self Deconstruct only runs when you click Done against Shambling Mound. Damsel neighbors and Pocketwatch just use the 1 ATK once. Blocked Attacks still count, they still fall apart, and hitting 0 is a normal Defeat with loot. The plate shows ∞; Shift shows remaining HP hits so the equation is true.

**Stingy reading:** Any time this monster Attacks (Done, Damsel neighbor, Pocketwatch) they loop until dead. Damsel plus a Mound neighbor can empty that slice in Damsel’s fight. Pocketwatch on a 4 HP Mound is four hits on the enemy and Mound dies. Blocked Attacks still cost them 1 HP. If “I die” is not a player kill, they vanish with no loot.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Hit count coded as 99: Shift says you will take 99, they actually swing 4 times, then the game hangs or they never die.
- HP never decrements: infinite Attack loop, fight stuck.
- Damsel / Pocketwatch inherit `_hit_count` = HP with no extra thought: a neighbor Mound suicides during someone else’s fight.
- Badge says ∞ and Shift also prints ∞ / 99: the equation does not match the hits.
- Quiet Bell still loops: Ability is on, 4 hits, they die, Bell did nothing.
- They die from the loop but combat takes the leave-alive path: they are at 0 HP on the wheel next Spin.
- Self −1 coded as your Attack: Needleback pokes, Twins double, Prism dumps, Goblin immune, every extra swing.

**What the player sees:** On the wheel: 1 ATK with an ∞ (or ×∞) mark like Hornet’s ×2, and 4 HP. During the fight the HP number they see is how many 1s they will eat if they tap Done. Done: lunge, lunge, lunge, lunge, mound HP 4→3→2→1→0, then the death movie. No click in between. If they had 4 Block, all four 1s are eaten and they still die.

**If we skip this:** Hornet already does extra swings you cannot click between. You do not have a monster that spends its own HP to keep Attacking and then dies from that.

**If we take the strongest reading:** Damsel or Pocketwatch plus a full-HP Mound is a multi-hit and a free extra corpse. Commander next to them makes Done 4×3. With no Block that can end a run from one Done. With full Block it is a free kill. Pocketwatch as a 4-hit weapon that also deletes Mound is a strong click.

**Questions for Nathan:**
1. Does Self Deconstruct run only when you are fighting Shambling Mound and they Attack on Done, or any time this monster Attacks (Damsel neighbor, Pocketwatch)?
2. When they hit 0 HP from this, is that a normal Defeat (loot, empty seat, walk-off) the same as if you had killed them with items?

**Answers:**
1. Any time this monster Attacks: Done, Damsel neighbor, and Pocketwatch. They loop until dead.
2. Normal Defeat: loot, empty seat, walk-off.

**Self-audit:** restated as what the player does · named Hornet, Damsel, Pocketwatch, Commander, Flee, Quiet Bell, Needleback · both readings · questions would change the code · implemented after answers
