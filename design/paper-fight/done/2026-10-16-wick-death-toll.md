# Paper Fight — Wick Death Toll

Locked from Nathan’s gold box 2026-10-16. Implemented.

**Pitch (Nathan’s words):** REWORK - Loses 2 HP whenever one of its Neighbors is Defeated. This counts if they are Defeated, Slain, Blocked, etc. Does not count if that enemy Flees (eg King, Commander).

**Restate (what the player does):** Wick sits on the wheel. You do not click Wick for this. When a Neighbor’s fight ends as Defeated, Slain, or Blocked, Wick loses 2 HP. Commander / Cowardly King Flee does not chip Wick. If Wick hits 0 HP, Wick is Defeated.

**Where it happens in a round:** After a Neighbor’s fight resolves, before that Neighbor leaves. No extra click. Number is −2 each time, not a once-copy.

**Which existing cards this touches:**
- **Hornet / Queen** — one fight, one resolve; Wick chips once when that Neighbor is Defeated, not once per swing.
- **Commander / Cowardly King Flee** — named skip.
- **The Boot / Defeat** — the Neighbor is Defeated; Wick chips.
- **Blocked** — named count. In this game the faced owner still leaves after Done, so Blocked is a fight end.
- **Crossbow extra deaths** — those Neighbors are Defeated; Wick chips.
- **Anvil** — Wick is the one losing HP, not Anvil.
- **Empty alcove / last owner** — no Neighbor, no chip.
- **Tutorial kit** — Wick is not in How to Play.

**Generous reading:** Any Neighbor fight end except Flee (including take-hit and Blocked).

**Stingy reading:** Only when the Neighbor leaves from Slain/Boot, ignoring Blocked.

**Locked reading:** Generous. The note named Blocked and named Flee as the skip.

**Ways it can fail:** Old item-use +1 ATK / −1 HP still firing. Flee spinning still chipping Wick. Wick at 0 staying in the fight from the old wait. Index shift after the Neighbor is already removed, so the wrong slices chip.

**What the player sees:** After a Neighbor is Defeated, Wick’s HP badge drops by 2.

**If we skip this:** Inspect already says Death Toll; the code still ticks Wick on item use.

**If we take the strongest reading:** Take-hit also chips, because the fight ended. That matches “etc.”

**Questions for Nathan:** Answered on the gold box (Blocked counts, Flee does not).
