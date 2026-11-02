# Paper Fight — playtest todos that change a rule (Wick, Merchant)

**Pitch (Nathan’s words):** Open playtest Issues that are not already on `playtest/latest`. Two of them change a rule: Wick with one other monster should only lose 2 HP; Merchant should let you pick any item, not a short list.

**Restate (what the player does):**
- Wick: a Neighbor is Defeated. Wick loses 2 HP once for that Defeat. With two monsters on the wheel, that other monster is Wick’s only Neighbor even if it sits on both sides.
- Merchant: you Spin Merchant, then click one unspent item in your hand. It becomes a higher-tier item. You are not limited to a two-card subset.

**Where it happens in a round:** Spin / resolve, no extra click-target for Wick (automatic). Merchant: click a hotbar card. Number is a one-shot transform, not a live formula.

**Which existing cards this touches:**
- Wick, empty seats, two-alive wheels, Clockwork synchronize, collapse-dead
- Merchant, Smoke Bomb, cursed items, spent cards, empty dest-tier mill, Bag of Holding
- Hornet / Queen / extra swings: not involved
- Goblin unhittable: not involved
- Tutorial kit: Merchant can appear in later biomes; Wick is mill

**Generous reading:**
- Wick: unique living Neighbor seats only; one Defeat = one −2, even if left and right wrap to the same monster; if seats are empty, wrap to the next living monster so a two-monster wheel always counts them as Neighbors.
- Merchant: every unspent hotbar item is clickable. If that one has nothing in the mill to become, keep the picker open.

**Stingy reading:**
- Wick: only immediate adjacent seats; duplicate index already skipped in code, so maybe already −2 once when they sit next to each other, and 0 when they sit across empties.
- Merchant: only highlight items that already have a dest-tier card left in the mill (today’s filter).

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Wick −2 twice then dies and soft-locks collapse
- Merchant picker with zero legal items, Spin stuck
- Cursed / spent card upgraded anyway

**What the player sees:** Wick chip once. Merchant: whole hand lit, click one.

**If we skip this:** Wick stays double-counting or not counting across empties. Merchant still looks like a two-card draft.

**If we take the strongest reading:** Merchant upgrades any item including cursed; Wick wraps past empties.

**Questions for Nathan:**
1. Merchant: any unspent hand item, or only items that have an upgrade waiting in the mill?
2. Wick: one −2 per Defeat, wrapping to the next living monster on a two-alive wheel?

**Self-audit:** restated as what the player does · named a live collision · both readings · questions would change the code · not implementing this turn
