# Paper Fight — Net last vs Always

**Pitch (Nathan’s words):** Applied modifiers that change an enemy’s Attack (Net: choose −1, −2, or −3) should always land last, after that monster’s own ability has set the number. Beggar is the example: he reads your leftmost Attack item, then Net still cuts that result, so Net is not wasted. The exception is Ability text with **always**. Slime Boss already says “My Attack always equals my HP,” so Net should not stick; the plate stays equal to current HP. Dire Wolf’s call is Kill Shot; he should get the same **always** word. Paint **always** bold and a darker hue so it stands out when you inspect. Index the rest of the roster for anyone else who should get that word.

**Restate (what the player does):** During a fight you click Net, then click −1, −2, or −3. The facing owner’s Attack number on the plate drops by that much, floors at 0, and Net is used up. For most owners, the game keeps running their own Attack rule first (Beggar’s leftmost item, Bandit’s items in hand, Vampire’s +1 after you lose HP, Commander’s +2 on a neighbor), then applies Net’s cut last. If the owner’s Ability uses **always**, the plate ignores Net and keeps following that sentence (Slime: Attack = this owner’s HP; Dire Wolf, if he gets the word: Attack = your HP). You do not pick a monster; it is the one you are fighting.

**Where it happens in a round:** Fighting only. Net is used up. No extra target click beyond the −1/−2/−3 pills (same as today’s Net). The cut is not a one-time snapshot of a printed number: it is a last step that keeps applying this fight, unless **always** throws that step out. Net’s own Flow already says the lock lasts for the rest of this fight, not the rest of the dungeon.

---

**Index — every live owner’s Attack vs Net**

Net only changes Attack. Owners whose special is HP, extra swings, pierce, immunity, or a click on Spin still take Net on the printed Attack number unless a row below says otherwise.

**Need a call (formula that can change Attack during this fight):**

| Owner | Ability now | What the plate does today | Reading without **always** (Net last) | Reading with **always** |
|---|---|---|---|---|
| **Slime Boss** | My Attack **always** equals my HP. | Code special-cases him around the lock; hitting him sets Attack = HP again. | Net would cut, then a hit would put Attack back to HP anyway. | **Named exception.** Plate = current HP. Net does nothing. Commander +2 is already overwritten to HP. |
| **Dire Wolf** (Kill Shot) | My Attack is your HP. | Net **sticks**. Losing HP later does **not** update him while locked. | Compute your HP, then −2. If you lose HP, recompute HP then −2 again. | **You named this.** Plate = your HP. Net does nothing. Losing HP updates him. Commander +2 is the leftover fork (he currently **adds** Commander; Slime does **not**). |
| **Beggar** | I gain Atk equal to your leftmost Atk Item | **Bug:** he ignores the lock, so Net is wiped the next time stats refresh. | **Named default.** Leftmost item (or 3), then Net. Spend the item, he rereads, then Net again. | Would make Net useless against him. You said no. |
| **Bandit** | +1 Atk for each Item you hold. | Net sticks (lock honored). | Same shape as Beggar: live item count, then Net. Spend an item, reread, then Net. | Plate = item count. Net useless. |
| **Vampire** | Every time you lose HP, I gain +1 HP and +1 ATK. | Lock **freezes** Attack, so later Bloodlust +1 ATK is skipped. | Current total (printed + Bloodlust so far), then Net. You lose HP: +1, then Net again. | Plate = printed + Bloodlust. Net useless; he still grows. |

**Recompute on Spin, not mid-fight.** If Net only lasts this fight, **always** does not change them; after they leave, the formula runs clean:

- **Wraith** — copies the higher neighbor’s Attack (with their complete modifiers), then Commander. During the fight he does not recopy. Net on Wraith is a cut of that copied number. Net on a neighbor is what he would have copied if you had Netted them before this Spin.
- **Berserker** — 3 / 4 / 8 on Spin, then Net this fight.
- **Spider Queen** — eggs add +2 HP and +2 Attack on Spin and freeze that bonus with the **same lock flag Net uses today**. That flag must stay a “keep the egg bonus” flag, not “ignore Beggar.” Net after eggs: egg total, then −1/−2/−3.
- **Skeleton / Ogre / Wick / Leech / Lich** — HP rules. Printed Attack still takes Net.

**Printed Attack, extra swings, or a verb that is not an Attack formula.** Net last is just “use the number on the plate”:

- Wizard, Golem — no special.
- Goblin — still cannot take Attack damage; Net only shrinks **his** swing at you.
- Hornet Swarm, Kobold Trapper — each swing uses the Netted number.
- Harpy — meet-hit and after-item pokes use the Netted number.
- Dragon — pierce of the Netted number (0 pierce is 0).
- Needleback — poke is still 1; his Done swing is Netted.
- Damsel, Mimic, Clockwork, Basilisk, Twins, Gargoyle, Cube, Bodyguard, Cowardly King, Merchant, Juggernaut, Cleric, Anvil, Commander (his own Attack, not the aura he gives).

**Commander / Lich auras:** Net’s Flow already says the cut is after every other formula including Commander. Neighbor of Commander: printed (or formula), then +2, then Net. Slime today then overwrites to HP, so Commander does not show. Dire Wolf today is `your HP + Commander`. That is the fork.

**Quiet Bell:** unique ability off. No **always** formula left. Net is an ordinary −1/−2/−3 on the printed number.

**Caltrops (retired):** same lock as Net. Follows this rule if it ever comes back.

**Which existing cards this touches:**
- **Net** — the applied modifier. Today it freezes the plate (`atk_locked`). Beggar ignores that freeze. Slime and Queen eggs also touch that flag.
- **Beggar** — you said Net must still work after his leftmost-item math.
- **Dire Wolf** — you said he should get **always**. Today Net freezes him, which is the opposite.
- **Slime Boss** — already has **always**. Hitting him and Commander both fight the lock.
- **Bandit** — same live-hand shape as Beggar. Needs a yes/no on **always**.
- **Vampire** — grows Attack mid-fight. Freeze vs sticky last step changes whether Bloodlust still pays after Net.
- **Commander** — +2 after formulas. Does **always** beat this too (Slime today) or only player items like Net (Wolf today)?
- **Spider Queen** — eggs share the lock flag with Net. Implementation must not make Net freeze her egg bonus the wrong way, or make eggs wipe Net.
- **Wraith** — copies complete modifiers. Copies a Netted neighbor. Does not recopy during the fight.
- **Hornet / Kobold / Harpy** — extra swings / pokes use whatever number is on the plate after this rule.
- **Dragon** — pierce of that number.
- **Goblin** — Net does not make Attack damage land on him.
- **Sledgehammer** — “5 or more Attack” reads the plate after Net (easier to fire).
- **Pocketwatch** — uses the number already on the hypnotized owner.
- **Quiet Bell** — strips **always**.
- **Empty alcove** — Net needs a facing owner.
- **Tutorial kit** — no Net. No new click.
- **Developer Test** — full wheel; Net still only the facing owner.

**Generous reading:** Net is a sticky last step this fight: every time the owner’s own rule makes a new Attack, subtract Net again. Beggar, Bandit, and Vampire all stay cut. **always** (Slime, and Dire Wolf if you confirm) is the final plate: Net does nothing, Commander does nothing, the sentence is literally true. After the fight the cut is gone.

**Stingy reading:** Net freezes the number you saw when you clicked it. Beggar stops following the leftmost item. Vampire stops gaining Attack. Dire Wolf stops following your HP. **always** is only a paint word unless we special-case Slime. Commander can still +2 on top of an **always** owner.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Beggar stays as today: Net’s −2 flashes, then the plate jumps back to the item number. Shift math disagrees with Done.
- Dire Wolf gets **always** in copy but the lock still freezes him, so the word lies.
- One `atk_locked` flag means three jobs (Net, Queen eggs, “stop this formula”). Queen eggs and Net stomp each other.
- Slime takes a hit after Net: HP drops, Attack snaps back to HP, Net looked like it worked for one click.
- Vampire Netted, then you lose HP: either he grows (sticky) or he does not (freeze). Inspect will be wrong if code and Ability disagree.
- Commander next to Dire Wolf: plate is your HP, or your HP + 2. Inspect says **always** your HP in one of those.
- Wraith copies a neighbor before you Net that neighbor; the copy is the old number. Not a bug if we say copy-on-Spin.
- After the fight, `atk_locked` is never cleared today, so a Netted Bandit can stay cut for Bracers and Wraith the rest of the dungeon, against Net’s “this fight” Flow.

**What the player sees:** Net pills, plate ticks down, the cut is the last number before they Attack you (Harpy included). On Slime / Dire Wolf with **always**, the plate does not tick down, or it ticks then snaps back — that snap would feel like a bug, so **always** owners should refuse the cut with a clear plate. **always** in Ability is bold and darker than the rest of the sentence.

**If we skip this:** Net already exists. Against Beggar it is wasted. Against Dire Wolf it works, which you do not want if he is **always**. Players cannot tell who ignores Net.

**If we take the strongest reading:** Net is a real last step on everyone except **always**. Dire Wolf and Slime ignore Net, Commander, and any other Attack cut. One Net click cannot zero an **always** owner. Beggar with a 3-Attack item and Net −3 is 0 for the rest of this fight, including Harpy if you could face both (you cannot). Sledgehammer can fire after a −3 that drops someone from 5 to 2.

**Questions for Nathan:**
1. Besides Slime Boss and Dire Wolf, who else gets **always** (Net does nothing; the sentence is the final plate)?
2. Does **always** also ignore Commander’s +2, or only player cuts like Net?
3. Dire Wolf’s Ability is locked as “My Attack is your HP.” This message is an override to put **always** in that sentence — which wording?

**Self-audit:** restated as what the player does · named Beggar, Slime, Dire Wolf, Bandit, Vampire, Commander, Queen, Wraith, Hornet · both readings · questions would change the code · not implementing this turn

---

**Answers (2026-10-17):**
1. Only Slime Boss and Dire Wolf. Bandit and Vampire stay +1 language, so Net still cuts after their math.
2. **always** is the final number. Commander +2 does not add to Slime or Dire Wolf.
3. Override the locked Dire Wolf Ability to: “My Attack always equals your HP.”

**Shipped:** Net is a last-step cut this fight (`atk_mod`). Beggar / Bandit / Vampire keep calculating, then Net. Slime and Dire Wolf ignore Net and Commander. **always** is bold and darker on inspect. Queen eggs use `egg_atk`, not the old freeze flag.
