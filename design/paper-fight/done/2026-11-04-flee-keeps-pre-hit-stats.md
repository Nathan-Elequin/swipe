# Paper Fight — Flee keeps the stats from before the triggering event

**Pitch (Nathan’s words):** When a monster flees, they keep their stats exactly as those stats were prior to whatever event caused them to flee. Example: Commander at 2 HP takes a 4 damage attack that would defeat him. He flees at 2 HP. The killing damage does not stick. This matters for Petty King (Vindictive): if you already damaged him and he still attacks you and gets away, he leaves with that reduced health.

**Restate (what the player does):** You hit a monster, or you press Done and they attack. If that moment makes them Flee instead of dying or instead of staying, the wheel then spins at random, same as now. You do not pick a target for the Flee. The monster is not used up. The number you already dealt, before the moment that made them run, is still on them when you meet them again. The blow that would have defeated them is not.

**Where it happens in a round:** During the fight, at the moment Flee replaces Defeat, or at the moment a living monster’s own rule says they Flee (after their attack, on Spin, after a bribe). The monster stays on the wheel. HP and the other stats are the values from immediately before the triggering event, copied once at that moment. They do not keep updating back toward full, and they do not snap to printed max. No extra click.

**Which existing cards this touches:**
- **Commander** — First time he would be Defeated, he Flees. Today the code sets him back to full HP (his max). Ball and Chain already keeps him at the HP from before that Attack and cancels the Flee. The new rule makes a successful Flee use that same pre-blow HP instead of full HP. The second time he would be Defeated, he still dies.
- **Petty King** — Ability is Vindictive: when he loses HP, the monster on his right Attacks you. Separately, if the fight would end and he still has HP, he Flees. A killing blow still defeats him today (he does not Flee at 0). Chip damage already stays on him when he Flees after Done. He does not full-heal on Flee today. The new sentence is about keeping that chip, not about healing him.
- **Triclops** (retired, still in code) — If he would be Defeated and he is not at 3 HP, he loses 2 HP and Flees. That −2 is printed on the card. A snapshot that wipes the −2 makes the card lie.
- **Mouse** — On Spin, if you have more HP, he loses 2 HP and Flees. Same printed cost.
- **Sandbag** — If his Attack would kill you, he does not hit you. He loses 2 Attack and Flees. The would-be hit on you already does not land. The −2 Attack is printed.
- **Phoenix Egg** — When Defeated, Flees and hatches into a Phoenix. The egg body is replaced. A fresh Phoenix has Phoenix’s printed HP, not the egg’s leftover HP.
- **Fungal Colony** — After he deals Attack damage to you, he copies onto the weakest monster and Flees. If that same moment had dropped him to 0, the code already puts HP back (pre-hit, or full max if pre-hit is missing).
- **Hired Hand** — You discard an item. He Attacks a neighbor, then Flees. His own HP usually did not change. The neighbor still took the hit.
- **Shuriken / Flying Saucer / Energy Drink** — You Flee. The monster is not the one running. Damage you already dealt stays. This rule is about the monster who Flees.
- **Ball and Chain** — Cancels Flee. Commander stays in the fight at pre-Attack HP and is not Defeated. That part already matches this pitch.
- **Hydra (Hungry Heads)** — After an action, a living monster at 3 HP or less whose HP went down is Defeated, and Hydra gains that HP plus an extra swing. If the killing blow never lands, Hydra never sees that drop. If the blow lands and is then undone, Hydra may already have eaten them.
- **Bodyguard** — Can die taking the hit that would have defeated Commander. The pitch talks about the fleeing monster’s stats, not about bringing Bodyguard back.
- **Goblin** — Immune to Attack, so an Attack does not drop him and does not become a defeat-Flee.
- **Wraith / Slime / Dragon / Hornet / Queen** — Their numbers still apply to hits that actually land. A Flee does not copy them.
- **Lich** — A real Defeat still chips him. A Flee is not a Defeat (Clockwork’s note already says Flee does not count).
- **Tutorial / empty seat** — Flee still random-spins after 0 HP seats are cleared. A monster who Flees is not a 0 HP seat.

**Generous reading:** The triggering blow never changes the fleeing monster. HP, Attack, max HP, poison, and other marks on that monster go back to the instant before that blow. Printed Flee costs still happen after that (Triclops and Mouse still lose 2 HP, Sandbag still loses 2 Attack). Phoenix Egg still hatches into a normal Phoenix. Other people still take the action’s other results (Bodyguard can die, the King’s right-hand monster still hits you, your Shuriken damage on a living target stays). Petty King keeps earlier chip damage when he attacks and leaves. A blow that would drop the King to 0 still kills him. You never see the killing number on the fleeing monster. Hydra does not treat that undone blow as HP lost.

**Stingy reading:** Only Commander’s current HP is special. On his first Flee he leaves at the HP he had before the lethal hit, instead of full HP. Attack, poison, and max HP from that same hit stay if they changed. Mouse, Triclops, and Sandbag keep the losses their cards already name. Petty King is unchanged, because chip damage already stays and a killing blow already kills him. Phoenix is unchanged.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Commander still leaves at full HP, so the next fight is a fresh Commander.
- The killing blow is undone and also the printed −2 on Triclops or Mouse, so the card text is wrong.
- The blow is applied, Hydra eats the monster, then HP is restored and they also Flee.
- Petty King is full-healed on Flee, so Vindictive chip damage disappears.
- Ball and Chain and a successful Flee disagree about which HP he keeps.
- A 0 HP body is left on the wheel because the restore and the death sweep race.

**What the player sees:** Commander at 2 HP, hit for 4, leaves still showing 2. The wheel spins. Next time you land on him he is still at 2, and that first Flee is used up. Petty King you chipped to 5, who then attacks and runs, is still at 5 later.

**If we skip this:** Commander’s first Flee keeps putting him back to full HP. A chip that would have mattered is erased. Petty King’s non-lethal Flee already keeps the chip.

**If we take the strongest reading:** One lethal hit does not change the fleeing monster at all, and also does not change anyone else that hit touched. Bodyguard would not die, poison on that item would not stick, and the King’s killing blow would become a Flee at his old HP plus the right-hand attack. That is a bigger rule than the sentence. The sentence is about the fleeing monster’s own stats.

**Questions for Nathan:**
1. Printed Flee costs still happen. Answer: yes.
2. Petty King at 0 still dies. Answer: a killing blow still kills him. Flee is only when he survives, attacks, and gets away, and earlier damage stays.
3. Phoenix Egg still hatches into a normal Phoenix. Answer: printed Phoenix HP.
4. Same-blow poison, Attack, and Needleback. He asked for an example. Pick, written down: the killing chip does not stick. HP, Attack, and Poison go back to the moment before that chip. A Needleback chip that landed in that same HP loss comes off because Attack is in that snapshot. Damage from earlier in the fight stays. Bodyguard can still die. Hydra, if it already ate someone, stays eaten.
5. Show the hit, then the HP jumps back. Answer: yes. If Hydra already ate them, that still happened.

**Shipped:** Commander’s first Flee no longer sets him to full HP. The killing chip is shown, then HP, Attack, and Poison return to the moment before that chip, and he Flees. Ball and Chain uses the same restore. Triclops still loses the printed 2 after the restore. At 3 HP he is Defeated. Fungal Colony no longer falls back to full HP if that chip dropped him to 0. Petty King and Phoenix Egg are unchanged.

**Self-audit:** restated as what the player does · named Commander, Petty King, Hydra, Ball and Chain · both readings · questions answered · implementing this turn
