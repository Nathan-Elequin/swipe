# Paper Fight — poison on every spin

**Pitch (Nathan’s words):** Poison procs every time you Spin, no matter which seat those monsters are in. Poison Flask, then a Spin: whichever monster had the poison takes it immediately. If that poison would kill them, it happens before any of their on-spin effects. They drop to 0 and those effects do not fire. They stay in the slice until every other on-spin has resolved. Then they are slain, the slice empties, and it fills again by the normal rules for slaying a monster who is not the one you are fighting.

**Restate (what the player does):** You mark someone the way you do now (Poison Flask on a Neighbor, Miasma on everyone). You do not have to land on them. The next Spin, every monster who still has a poison number loses that many HP at once, before anybody’s spin ability. If they hit 0, their own spin ability does not happen. Their portrait stays in the seat while the monsters who lived do their spin abilities. After that, a dead monster who is not the one you landed on leaves and the seat fills the way a neighbor death already does. The one you landed on, if the poison killed them, then ends the fight the way a normal kill does.

**Where it happens in a round:** Right after the wheel stops, before Basilisk, Death Bell, Mouse, Gargoyle, Hydra, Queen, Harpy, and the rest. The Flask and Miasma are still used up when you play them. The poison number is the number already on that monster (Flask adds 5, Miasma adds the lowest HP). This fight is about when that number is paid, not a new amount.

**Which existing cards this touches:**
- **Poison Flask** — today the 5 is paid only when you later Spin onto that neighbor. Locked Ability: “Mark a Neighbor. When you spin them, they lose 5 HP immediately.”
- **Miasma** — today the monster you are facing pays immediately when you play it, and everyone else pays when you later Spin onto them, then the mark clears. Plague Doctor neighbors stay at 2.
- **Plague Doctor** — neighbors Always have exactly 2 Poison. Today only the neighbor you landed on pays 2 before the heal. A 2 HP neighbor dies before the +2 heal. If every poison pays on every Spin, every neighbor pays 2 on every Spin, then the living ones are healed and set back to 2.
- **Hex** — locked Flow says Hex fires before poison on that landing. A Hex at 0 and a poison mark on the same monster you landed on cannot both go first.
- **Ale Flagon / Poison Frog (your poison)** — your droplet already pays on the Spin, after the faced monster’s poison, and is skipped if that Spin already killed the last monster. This pitch is about monster poison. Your droplet stays after all monster poison and before the survivors’ spin abilities. It is skipped only when nobody is left alive.
- **Basilisk, Death Bell, Mouse, Gargoyle, Hydra, Cursed Scroll, Berserker, Queen, Cultist, Juggernaut, Magicat, Poison Frog, Harpy, Leech, Cleric, Fairy, Cube, Merchant, Hired Hand, Almighty Worm** — if poison dropped that monster to 0, their spin effect does not run. A different living copy still does.
- **Goblin** — poison is not Attack, so it can kill Goblin. Unchanged.
- **Anvil** — one source still chips only 1, and Flask already counts as one source. A 5 still chips 1.
- **Cowardly King** — a non-killing poison loss still makes them hit you. They only Flee if they are the one you landed on. Unchanged hook, now possible off the faced seat.
- **Wick, Commander, Mimic, Phoenix, Triclops** — a neighbor at 0 uses the neighbor-death path (Commander can Flee, Wick can toll, Mimic can gift, Adventure fills the seat). Phoenix and Triclops run on the fight-end path, which is the monster you landed on.
- **Spider Queen** — a Queen at 0 does not lay an egg and does not eat eggs. A living Queen elsewhere still lays during the survivor step.
- **Hornet, Wraith, Commander aura, Dragon pierce, Slime, empty seat, tutorial, Developer Test** — poison is not an Attack and does not copy ATK. Empty seats are skipped. Tutorial does not include Flask. Developer Test can still place these cards.

**Generous reading:** One Spin pays every monster’s current poison number, once, then that number clears (Plague Doctor writes 2 again on neighbors who lived). The monster you landed on can sit at 0 while other living monsters still do their spin abilities. Then neighbor deaths fill, and if the faced monster is at 0 the normal kill plays (loot, Phoenix, Flee). Smoke, Flee, and auto-spin count, same as today.

**Stingy reading:** The mark never clears, so Flask’s 5 hits on every later Spin until they die. Plague Doctor is exempt and still only hurts the neighbor you landed on. If the monster you landed on dies to poison, the fight ends immediately and nobody else’s spin ability runs. Hex still fires before poison.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Faced monster dies, survivor spin abilities run, and a Queen or Cleric fills the hand or heals you during a fight that already looks over. Then the kill animation plays late.
- Two neighbors die, the seat fill runs in the middle of the survivor step, and a new arrival also does a spin ability they should not get.
- Plague Doctor plus “every poison, every spin” kills every 2 HP neighbor on every Spin, before the heal. The wheel refills in a loop if the fill itself is treated as a new Spin.
- Hex and poison both think they go first, so one of them never happens and the card text is wrong.
- Locked Flask line still says “when you spin them,” so the inspect plate describes the old rule.
- Anvil or a Cowardly King in an off seat takes the chip during the poison step and the Spin never reaches the survivors because you died to the King.

**What the player sees:** You Spin. Every poisoned portrait takes its number, including ones on the side of the wheel. Anyone who hits 0 stays there, greyed out, while the living ones do their usual spin moments. Then the side seats empty and fill. If the one in front of you hit 0, you then get the normal kill.

**If we skip this:** Poison Flask and Miasma still wait until you Spin onto that exact monster. Plague Doctor still only chips the neighbor you landed on.

**If we take the strongest reading:** One Flask on a 5 HP neighbor, then any Spin, kills them even if you landed on someone else, and a Plague Doctor wipes every 2 HP neighbor on every Spin before healing the rest.

**Answers (2026-10-23):**
1. The number clears. Flask’s 5 and Miasma’s number are paid once, on the next Spin, wherever they are sitting. Plague Doctor writes 2 back onto neighbors who lived.
2. Every Plague Doctor neighbor pays 2 on every Spin. A neighbor at 2 HP dies before the heal.
3. Other living monsters still do their spin abilities while a poison corpse sits there. Then the normal kill plays for the monster you landed on.
4. Poison hits first. If it kills the monster you landed on, Hex does not count down and does not Defeat.
5. Miasma pays nobody when you play it. Everyone, including the one you are facing, pays on the next Spin.
6. This message overrides those locked lines. Poison is a keyword with a hover line, same idea as Flee.

**Collisions written down while building:**
- A Cowardly King you landed on still flees during the poison payment, after the other seats have already paid. That landing ends there.
- Basilisk fleeing, or Hex defeating someone poison did not kill, still ends the landing before Queen and Cleric. Side poison corpses are cleared before that new spin or that kill, so they are not left in the seats.
- Your Ale / Frog droplet still pays after monster poison, and is skipped only when nobody is left alive.
- Anvil still loses 1 HP from one poison payment, then the mark clears.

**Self-audit:** restated as what the player does · named a live collision · both readings · questions answered · implemented that reading
