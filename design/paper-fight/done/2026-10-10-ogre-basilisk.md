# Paper Fight — Ogre listen-for-HP-loss + Basilisk cannot Gain or Keep

**Answers (2026-10-10):**

1. Ogre starting HP is the saved printed **10**.
2. If the Ogre would die from HP lost during another fight, wait until that whole fight is over, then slay the Ogre with the ability title fade.
3. Quiet Bell on that Ogre: keep the HP it had. Stop listening.
4. Smoke Bomb gives the item **before** Spin, after leaving the current fight, so Basilisk is not facing you and the item stays.
5. Spider Queen egg while facing Basilisk: the card appears in the hotbar, “Can't Gain Item” shows, then it is discarded immediately.

Implemented from those answers.

---

(Original write-up follows.)

**Pitch (Nathan’s words):**

Ogre: this unit no longer looks at the current value of Player HP. Instead, it listens for any time the player loses HP (from any source, at any time) and then this unit loses that much HP. If that would Slay the Ogre during another combat, finish that combat first, then show the Ogre slay with the ability title fading over it. If it is killed outside resolving combat, Slay immediately like Crossbow.

Basilisk: “While facing me, you cannot Gain or Keep any Items.” Whenever an ability or monster effect would cause the player to gain or keep anything (Throwing Dagger, Breastplate, Spider Egg, Smoke Bomb), it performs the remainder of its effect (1 Dmg, 2 Block) but is Discarded immediately.

**Restate (what the player does):**

Ogre: the player never clicks the Ogre for this. Whenever the player’s HP number goes down, that Ogre’s HP number goes down by the same amount. Printed HP is 10. Quiet Bell on that Ogre keeps its current HP and stops the listening.

Basilisk: while the player is fighting this Basilisk, they cannot Keep, and new items that would enter the hand appear then leave with “Can't Gain Item.” Smoke leaves the fight first, then gives the item, then Spins.

**Where it happens in a round:** Ogre always listens. Basilisk only while facing.

**Which existing cards this touches:** Grief Jar, Cursed Scroll, Damsel, Smoke Bomb, Spider Queen egg, Knife/Lantern/Breastplate Keep, Quiet Bell.

**Self-audit:** implemented after answers.
