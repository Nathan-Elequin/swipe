# Paper Fight — Glass Asp: player Poison, not self-Poison

**Pitch (Nathan’s words):**

Rework for Glass Asp. Stats: 6 HP, 2 ATK. Call name stays Bitter Blood. Ability: When you Spin me, you Gain 4 Poison. When I lose HP, you lose Equal Poison. Ditch the self-poisoning thing it does, and the attack gain thing it does.

**Chosen reading (2026-11-19):**

- Spin onto me: you Gain 4 player Poison after this Spin’s payment, so it waits for a later Spin (Poison Frog).
- Equal = HP that actually left the bar. A 10 into 6 HP strips 6.
- Any living Glass Asp losing HP, including a side seat, strips your Poison.
- Plague Doctor freeze is obsolete; no special freeze case. Hitting the Asp always strips if you have Poison.

**Collisions written down while building:**

- Gain 4 is facing-only and skips a dead or silenced Asp, so a Flask that kills it on the land does not add 4.
- Attack and `_chip_hp` both call the same strip helper. Hydra eat / Hex Defeat with no HP loss do not strip.
- Self-Poison and Attack gain (and the Ogre-style slash on Attack) are gone.
