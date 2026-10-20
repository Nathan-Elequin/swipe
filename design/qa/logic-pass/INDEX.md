# Dense mill QA — index

Board: `http://127.0.0.1:8757/design/qa/logic-pass/board.html`

This pass is **every live item × every live monster**, plus empty/full hand, no neighbor, last monster, 1 HP, Undo, Keep-until-Done, Done-triggered specials, and order swaps. Dummy-only unique fires are retired as a method.

Progress lives in `dense/progress.json` while Godot is running. The board shows fails, blocked, and rulings — not thousands of passes.

## Fail

None. Spider Queen Egg Layer: spinning her Grants 1 Egg then she eats it. Local F5 only (itch frozen).

## Blocked (will retest with the real trigger)

Done-triggered specials (Martyr, Shambling Mound, Shark, Druid, Clockwork Knight, Damsel neighbors). Neighbor-HP snapshots (Lich, Commander, Wick, Bodyguard, Prism). Wrong-trigger setups (Ogre/Vampire without you losing HP, Pocketwatch/Leech with only one monster, Recycler without 5 discards). Title-screen wipes after Defeat (Knucklers, Fangs, Last Match, Miasma, Eel, Shield then Done).

## Unique abilities that did fire (sample)

Dire Wolf after Heal, Slime after a hit, Flask after a Defeat, two Sais 2 then 4, Napalm to 1, Polymorph into Wizard, Anvil Tough Blood, Harpy Impatient, Juggernaut Shield, Hydra Even Killer, Cultist Blood Pact, Death Bell Toll, Fairy Dust, Magicat Marble, Rust Bucket, Poison Frog Toxic Skin, Basilisk Flee, Mouse Scurry, Cube feed, Merchant upgrade, Great Axe cleave, Grappling Hook swap, Bag of Marbles, Arrow Head 6 and −2 HP, and the rest of the Passed tab.

## Retired — will not test again

Dagger, Helmet, Bandana, Caltrops.
