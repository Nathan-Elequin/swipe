# Paper Fight — Longbow even-count rule

**Pitch (Nathan’s words):**
Ability Save is now “Deal 4 Attack to the monster across from you.” The old player sentence said it only works with an even number of monsters. Flow on the same Save still says: usable only when living slice count is even; odd count cannot use; used up.

**Restate (what the player does):**
In a fight they click Longbow. It deals 4 Attack to the owner across the wheel from whoever they face. The card is used up. The open question is whether they can click it when the wheel has an odd number of living owners.

**Where it happens in a round:**
Fighting. Used up. No extra target click — “across” is automatic. Number is a flat 4, not a live formula.

**Which existing cards this touches:**
- Goblin: across-target takes no Attack damage.
- Dragon: this is Attack, not Block, so pierce does not matter on this click.
- Hornet / Queen: extra swings still happen after if the facing owner is still there; the across owner is a different seat.
- Empty alcove: opposite seat might be empty if we allow odd wheels.
- Last owner: one living owner — there is no “across.”
- Wraith / Commander / Slime: stats on the across owner still apply after other formulas.
- Tutorial kit: Longbow is not in the tutorial hand.
- Developer Test: easy to seat 2 vs 3 owners.

**Generous reading:**
Any living wheel. “Across” means the owner farthest around the ring from the one you face (half the seats away, rounded). Last owner / empty opposite: cannot use. Odd count still has a farthest seat.

**Stingy reading:**
Keep Flow. Even living count only. Opposite index is facing + n/2. Odd count: greyed out. Last owner: cannot use.

**Answer (2026-10-10):**
Keep Flow. Even number of living owners only. Odd wheel = cannot use. No code change.

**Self-audit:** restated as what the player does · named a live collision · both readings · questions would change the code · implemented after the answer (no-op)
