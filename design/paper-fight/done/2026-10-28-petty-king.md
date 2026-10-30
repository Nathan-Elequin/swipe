# Paper Fight — Petty King (Cowardly King rework)

**Pitch (Nathan’s words):**

Rename Cowardly King to Petty King. 8 HP 2 ATK. Call Vindictive. Ability: "|Any| time I lose HP, I command the monster to my right to Attack you immediately". How it works: if the king loses any HP (including poison), look at the monster to its right (counter-clockwise on the wheel, as Right Bracer does) and make that unit Attack, identical to how Damsel would trigger it to attack. Defeat items ignore this (he doesn't lose HP).

**Restate (what the player does):**

They do not click this. The king sits on the wheel at 8 HP and 2 Attack. Whenever his HP number actually goes down, after the current item finishes, the living monster in the one seat counter-clockwise Attacks the hub the same way a Damsel neighbor Attacks. Boot and other Defeat cards skip this. He does not Flee.

**Answers (2026-10-28):**
1. Yes — overwrite locked fields.
2. Do not paint Any — plain English in “Any time”.
3. Killing blow still commands. Needleback still pokes if it dies to Attack damage.
4. Once per HP-loss event.
5. Empty or dead right seat: nobody.
6. Full Damsel-neighbor Attack.
7. Spiked Flail / Needleback chipping him again: command again.
8. After the current item fully finishes.

**Self-audit:** implemented after answers
