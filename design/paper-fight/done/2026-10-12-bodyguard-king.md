# Paper Fight — Bodyguard and Cowardly King

**Pitch (Nathan’s words):**

Bodyguard. Picture is a secret service agent clutching his earpiece. Tier 1, bucket somewhere in 2–4 (I choose). 3 HP, 3 Attack. Call name Protector. “When my Neighbors would take Attack Damage, I take it instead.” If he is a neighbor of the current fight, he receives that attack damage. If that kills him and he is not the one you are facing, it is the same as killing someone with Crossbow. Double Axe while facing him resolves all at once: he is not dead before the attack begins, so his neighbors take 0.

Cowardly King. Picture is a little whining king. Tier 3, bucket somewhere in 3–5 (I choose). 2 Attack, 6 HP. Call name Guards! “When you Attack me, my Neighbor to the Right takes it instead. When I attack, I Flee before being Defeated.” Right means counterclockwise. He is still the target of Net, Da Boot, and other non-attack items. Poison Flask can kill him. Defeat items defeat him as usual. Crossbow, Longbow, and Double Axe still pass to the right neighbor. A chain of kings passes until a valid target. If only two kings remain, they take no attack damage. On Safe or Take, he attacks as usual, stays on the wheel, and the game spins again the way a finished fight already does. The pass has to be telegraphed.

**Restate (what the player does):**

Bodyguard, bucket 2. You deal attack damage as you already do. You do not click him. If that damage would hit a monster seated beside him, he loses the HP instead and they lose none. A single-target hit on Bodyguard himself still hits him. If he dies off to the side, the fight you are in keeps going and he leaves like a Crossbow kill. If he dies while you are facing him, the fight ends the normal way.

Cowardly King, bucket 5. You still click your attack item at the fight you are in, or you click Crossbow / Longbow at their usual target. If that attack damage would hit a King, it does not. It walks counterclockwise to the next monster who can actually take it. You see that walk before the HP changes. Poison Flask, Da Boot, Net, and other defeat or non-attack items still hit the King you aimed at. When you click Take or Safe, he hits you for 2 (Block still applies to that hit), then he stays in his seat, your Block clears, he is not counted as defeated, and the wheel spins again. If his hit drops you to 0, the run ends and he does not spin away.

**Where it happens in a round:** phase / used up or kept / must they click a target? / is the number copied once or does it keep updating?

Both are monsters on the wheel. They are not used up by the redirect. Bodyguard’s redirect happens by itself at the moment attack damage would land. The King’s pass happens by itself at that same moment, and his flee happens by itself after he has hit you from Take or Safe. The number is the attack damage of that one item, or his printed 2 when he hits you. It is not a stored copy that keeps updating later. Quiet Bell silencing either of them turns that one’s ability off.

**Which existing cards this touches:**

- Double Axe: one use hits the faced monster and each neighbor for 2, and the same owner is only hit once. Facing Bodyguard, neighbors take 0 because he is alive when the axe starts. Facing the King, his 2 is passed right, and the axe also hits that right neighbor on its own.
- Crossbow: 4 attack to a neighbor you click. If that neighbor is a King, the 4 is passed. If the monster who actually dies is not the one you are facing, the removal is the Crossbow removal already in the game.
- Longbow: 4 attack to the monster across, only when the living count is even. Same pass if that monster is a King.
- Poison Flask: marks a neighbor, and they lose 5 HP when you later spin them. That loss is not attack damage. A King keeps it. One flask leaves a 6 HP King at 1 HP.
- Da Boot and other defeat items: they defeat the King you are facing. He does not pass them and he does not flee, because he never got to attack.
- Net: lowers the faced monster’s Attack. It is not attack damage. The King keeps the penalty.
- Goblin: cannot take attack damage. “Would take” may or may not include a hit Goblin shrugs off.
- Twins: an even attack number hits them twice. The redirect may happen before or after that double.
- Anvil: loses at most 1 HP from one source. If the King passes a hit onto Anvil, Anvil’s own cap still applies to the hit he actually takes.
- Needleback, Slime Boss, Wick: they only react if they are the one who actually loses HP.
- Damsel: her neighbors attack you. If the King is one of those neighbors, he attacks, and “when I attack, I flee” may or may not fire outside his own Take / Safe.
- Commander: the first time Commander would leave, he flees, heals, and shuffles. The King does not shuffle, and he stays every time he attacks, not only the first time.
- Mimic: an off-facing Mimic who actually dies still gives the item, because that is already how an off-facing death works.
- Dragon: pierce is only when Dragon hits you. It does not change a hit passed onto him.
- Hornet, Queen, Wraith, Lich: Hornet and Queen do not deal attack damage to a neighbor. Wraith copies a neighbor’s Attack and does not move HP. Lich gives neighbors HP. None of those replace this redirect.
- Empty seats: a normal dungeon closes the gap when someone dies, so the right neighbor is the next monster. These two are not in the tutorial kit.
- Developer Test and Dive In can meet them once their bucket is open. Adventure is what opens buckets.

**Generous reading:**

Bodyguard steps in front of every neighbor hit, including a hit Goblin would have ignored, and he takes the raw number before Twins can double it. Double Axe hits him for 2 once. Two Bodyguards do not multiply the hit. The King’s pass stops on the first monster who is not a King, even if a Bodyguard is standing next to that monster. Double Axe’s passed hit and direct hit on that same neighbor count once. A King with nobody to his right takes the hit himself, so the last King can be killed with attack items. Damsel can make him swing without making him flee.

**Stingy reading:**

Bodyguard only steps in when the neighbor would really lose HP, so Goblin still ignores the hit. Twins double first and he takes the larger number. Double Axe piles every share onto him. Two Bodyguards beside the same target each take the full hit, and two Bodyguards next to each other pass it until a loop, then nobody takes it. The King’s pass is checked again by Bodyguard, so the damage can hop a second time. Double Axe facing the King deals 4 to the right neighbor. A King alone takes no attack damage at all. Any time he attacks, including for Damsel, he stays on the wheel.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**

- Two Bodyguards next to each other each say “I take it instead,” and the hit never lands.
- A wheel of only Kings, or one King left, cannot be hurt by attack items. With no Poison Flask and no defeat item, that dungeon cannot be cleared.
- A King’s pass walks into a loop and the game waits forever instead of stopping.
- The Take number still shows the King’s 2 on you, but the item damage preview still shows the King, so the telegraph is lying.
- Bodyguard dies from a side hit and the current fight also ends, or the reverse: he dies while faced and the fight keeps going.
- Poison’s 5 is treated as attack damage and jumps off the King, so the flask cannot kill him.
- His flee counts as a defeat, so Berserker and “per monster defeated” items tick even though he stayed.
- Quiet Bell is ignored and a silenced King still passes hits.

**What the player sees:**

Bodyguard’s call reads Protector. When a hit moves to him, he flashes and the neighbor does not. The damage number is unchanged. It just lands on him.

The King’s call reads Guards! Before attack damage lands, the seat it will actually hit flashes, walking counterclockwise if it passes through other Kings. Take or Safe still shows his 2 against you, after Block. After he hits, he stays put and the wheel spins.

**If we skip this:**

Crossbow already hits a neighbor. Commander already flees once and shuffles. Goblin already ignores attack damage. None of those put one monster in front of another, and none of them stay on the wheel after every attack.

**If we take the strongest reading:**

One Double Axe can dump every share onto one Bodyguard and kill him from full. A King who never has a legal neighbor cannot be killed with attack items, and every time you face him he attacks and you spin again. That can end a fight, or it can refuse to end the dungeon.

**Questions for Nathan:**

1. Facing Bodyguard, Double Axe: he takes 2 once, or 2 for himself plus 2 for each neighbor?
2. Two Bodyguards: the one beside the original target takes it, each of them takes the full hit, or a loop means nobody takes it?
3. The hit was aimed at Goblin, and Bodyguard is his neighbor. Does Bodyguard take it, or does Goblin ignore it?
4. The hit was aimed at the Twins. Does Bodyguard take the original number, or the doubled number?
5. One King is the last monster. Does he take attack damage, or none?
6. The King’s pass reaches someone, and a Bodyguard is that someone’s neighbor. Does the pass stop, or does Bodyguard take it?
7. Facing the King, Double Axe: the right neighbor takes 2 once, or 4?
8. The King’s pass reaches a Goblin. Does it stop for 0, skip Goblin, or hit Goblin for 0?
9. Damsel makes the King attack. Does he flee after that swing, or only after Take or Safe while you are facing him?

**Self-audit:** restated as what the player does · named a live collision · both readings · questions would change the code · not implementing this turn

**Answers:**

1. Double Axe on Bodyguard: he takes 2 for himself plus 2 for each neighbor. Neighbors take 0. The targets are chosen while he is still alive.
2. Each Bodyguard does this once per hit. The hit walks to the last Bodyguard in that line. Show the walk.
3. A hit aimed at Goblin still goes to Bodyguard. If the hit actually lands on Goblin, show "Immune to Attack Damage" and deal 0.
4. If the hit was aimed at the Twins, double the number first. Bodyguard takes that larger amount.
5. A King with nobody on his right takes the Attack himself.
6. King pass happens first. Then Bodyguard. Each ability once per hit.
7. Double Axe on the King: the right neighbor takes 4. The axe hit and the passed hit are both real.
8. A King pass that reaches Goblin hits Goblin for 0. It does not skip him.
9. "Flee" means he stays on the wheel after he attacks. Damsel's neighbors already stay, so nothing extra happens there.

Buckets chosen: Bodyguard 2, Cowardly King 5.
