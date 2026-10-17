# Paper Fight — Challenge loot on draw, not on slay

Locked from Nathan’s answers 2026-10-16. Implemented.

**Pitch (Nathan’s words):** Instead of Loot appearing and being tied to the Tier of the monster SLAIN, it should instead only happen upon the Tier of the monster DRAWN and ADDED into the dungeon. After the final card is drawn, the player gains no more loot while they are defeating the monsters in the dungeon (they still keep whatever they can retain). Mimic gives item on death. If Mimic arrives (is being seated), it would just be a standard item draft (ie Tier 2 pick-two).

**Restate (what the player does):** In Challenge, you still pick two loot cards when a monster is seated. Opening six: same six pick-twos as now, tied to those seated tiers. During play: you kill, then a face-down card sits in the empty seat. After you see who sat, you pick two loot cards of **that arriver’s** tier. Hornet (or pierce, extra swing) emptying two seats means two sits, so two pick-twos, each matching that arriver. After the last face-down card has sat and you have taken that pick, later kills only collapse empty seats. No more pick-twos. Keep cards stay. Mimic sitting is a normal Tier 2 pick-two. Mimic dying still gives its random gift; that is not a pick-two.

**Where it happens in a round:** After the fight ends, holes wait (facing first, then clockwise). Each hole: Mimic gift if that corpse was a Mimic who never swung; then draw-and-sit if the deck still has a card; then the pick-two of the arriver. Deck empty: collapse, no pick. Used up: the pick is a keep-or-spend item as usual. No extra target click. The loot tier is the arriver’s printed tier at sit, not a number that keeps updating.

**Which existing cards this touches:**
- **Hornet Swarm** — two empties in one fight. Each empty that still has a deck card sits someone and grants that arriver’s pick-two. If only one deck card is left, the second empty collapses with no loot.
- **Spider Queen** — eggs are items, not dungeon sits, so they do not grant Challenge pick-two. Queen dying is a hole like anyone else.
- **Dragon pierce / Crossbow / extra swings** — same as Hornet: loot is per arriver, not per fight.
- **Mimic** — death gift stays (random item, not pick-two). Mimic sitting from the deck is a standard Tier 2 pick-two.
- **Goblin** — no ATK damage; if Goblin still dies (Boot, Sledge, Fangs), that is a hole. Loot only if a replacement sits.
- **Wraith / Commander / Lich** — formulas on the arriver do not change the loot tier. Tier is the card’s pack tier.
- **Empty alcove / last seats / deck empty** — remaining kills collapse. No pick-two.
- **Flee / Cowardly King** — still no deck seating, so no loot from flee.
- **Hand at 10** — arriver pick-two still: pick two, then click a hotbar card to throw away. Mimic’s death gift at 10 still skips silent (forced gain).
- **Continue** — next dungeon still opens with six pick-twos for the newly seated six. The leftover hand is kept.
- **Tutorial / Developer Test** — not Challenge. Unchanged.

**Generous reading:** Every sit from the deck is a pick-two of that arriver, including the last deck card, plus Mimic’s death gift on top when Mimic dies.

**Stingy reading:** Loot only on the first sit of a fight, or Mimic’s gift replacing the pick-two. Rejected.

**Locked answers:**
1. Pick **after they sit** — you see who arrived, then you pick loot of their tier.
2. **One pick per arriver** — two sits means two pick-twos.
3. **Mimic death = random gift** (existing Mimic rule). **Mimic sitting = standard pick-two of Mimic’s tier (2).** If Mimic dies and a replacement sits, that is gift, then the replacement’s pick-two.

**Ways it can fail:**
- Still offering pick-two on collapse after the deck is empty.
- Using the slain monster’s tier instead of the arriver’s.
- Offering the pick before the slash/sit, so the player never sees who arrived.
- Hornet’s second hole skipping a remaining deck card, or granting loot with no sit.
- Mimic sit using a random gift instead of a Tier 2 pick-two.
- Opening six pick-twos removed by accident.

**What the player sees:** Kill, corpse, a face-down card walks in, name and call, then “Loot” with that name and tier. After the deck counter hits 0, later kills only shrink the wheel.

**If we skip this:** Kill still pays loot of the slain, including the last six with no deck left. That is the current rule.

**If we take the strongest reading:** Twelve pick-twos per dungeon (six opening sits + six deck sits), then a dry finish. Mimic can still gift on death during that dry finish.

**Questions for Nathan:**
1. After sit vs before sit — **after sit.**
2. Per arriver vs per fight — **per arriver.**
3. Mimic — **gift on death; standard pick-two on sit.**

**Self-audit:** restated as what the player does · named Hornet/Mimic/Queen/Flee/hand 10 · both readings · answers locked · implemented
