# Paper Fight — Clockwork Knight Synchronize

Answered 2026-10-27 in [Clockwork Knight ability rework](da2ef1d5-83d1-452d-941d-d94c14335c09). Rebuilt 2026-10-30 because that chat never committed.

**Pitch (Nathan’s words):**

5 HP, 4 ATK. Call name Synchronize. Ability: “When I am Defeated, my Neighbors gain HP until they are equal, and then gain ATK until they are equal.” When this unit is defeated in any way, look at the two neighbors. First compare HP. Heal the one with lower HP, one point at a time, until it matches the other, the way Leech League does. Then do the same with Attack. Monsters with an Always attack (Dire Wolf, Slime Boss) still take those gains. After both passes are finished, their Always traits apply again and may pull HP or Attack back. A small line over them says “Reset due to ability”.

**Questions for Nathan — answered 2026-10-27:**

1. Yes. This message replaces the locked Disassemble text. The plate says Attack, not the abbreviation, because players never see that abbreviation.
2. Quiet Bell turns Synchronize off.
3. HP to 0, defeat items, and Block. Not Eject, not Polymorph, not Flee.
4. He meant Wick. Synchronize finishes first, while the knight is still being defeated. Wick matches its other neighbor, then loses 2 HP.
5. Dire Wolf's Attack returns to your HP. Slime Boss's Attack becomes its HP, even if that raises it. The line shows when that changes a number. Bandit, Beggar, and Vampire keep the gift and do not get the line.
6. One pass on the numbers showing when the knight dies. Lich and Commander may change them again afterward.

**Built:** the old “two Tough monsters if I live” leave is gone. A gap bigger than 48 points finishes in one jump so the match cannot hang.

**Self-audit:** restated as what the player does · named a live collision · both readings · questions answered · implemented
