# Paper Fight — Jar O' Grease / Swap

**Pitch (Nathan’s words):** Item Tier 2, Bucket 0, Jar O' Grease (image: jar of grease). Heal 2, randomly Swap an Item, and Keep this. How it works: 'Swap' is a new keyword, and it is the same mechanics as Chaos Ring/Gem (swapping items within their tier). Rewrite Chaos Gem so it uses this keyword, and ensure that both have the subtooltip explaining this: 'Swap: exchange for a random Item of the same Tier'. As far as item pool goes, it is the same as drafting - you can't Swap into an item if there are no counts of it left in the deck/pool.

**Restate (what the player does):** During a fight they click Jar O' Grease. They Heal 2 (cap 6). One item in the hand becomes a different random item of that item's tier, with the Chaos Stone transform motion. The Jar stays in the hand (Keep). They can click it again later. Shift on Swap shows: Swap: exchange for a random Item of the same Tier. The live Chaos Stone (catalog id mute_stone, name Chaos Stone) is rewritten to say Swap instead of “replace with random Items of the same Tier,” and that Swap reads from the leftover draft pile the same way taking loot does: if every copy of a card is already gone from the pile, that card cannot appear.

**Where it happens in a round:** Click during a fight. Heal is instant. Swap is random (Jar) or chosen (Chaos Stone today). Keep: the Jar is not thrown away. Chaos Stone today is used up. The swapped card’s new stats are live from that moment. The number is not a copy that keeps updating.

---

**Which existing cards this touches:**

- **Chaos Stone (mute_stone)** — live rule: click, then click 1 or 2 *other* items; each becomes a random catalog card of that tier; Stone cannot target itself; unplayable if it is the only card; used up. Live reroll does **not** consume the draft pile (Merchant paper fight locked that). This pitch makes Swap consume leftover counts like drafting. That is a real change to Stone, not just the word Swap.
- **Merchant** — upgrades by consuming a remaining copy of the next tier. Swap stays same-tier. Do not mix those piles.
- **Tokens (Spider Egg, Marble, Blood Pact)** — Tier 0, not drafted, count 0. Swap on an Egg has no Tier 0 pile to draw from unless we allow tokens to become other tokens. Swapping *into* Egg should be impossible if Egg is not in the draft pile.
- **Hex / Double-Buckler Unplayable** — still sitting in hand. Chaos Stone can already click them as pick targets. Jar’s random Swap can hit them.
- **Petrify** — stoned cards cannot be clicked as a use. Chaos pick currently does not skip petrified. Swap hitting a petrified card would unstone-by-replacing or fail.
- **Keep / Lantern / Breastplate / Lucky Nickel** — Jar Keep is that family. Zombie facing: no Keep, Jar would discard after the Heal+Swap.
- **Healing Potion** — Heal 2 is the small Heal, cap 6, not Potion’s death save.
- **Cursed Scroll** — Heal 6 then bleed on Spin. Different card. Same Heal family.
- **Counting Beads / Sai** — Jar counts as an item use. Dummy Bushido would dump Jar with no Heal and no Swap.
- **Echo Bell** — can copy Jar later: Heal 2, random Swap, Keep the Echo or the copy? Echo’s Keep is its own.
- **Bag of Marbles / Marble** — Marbles in hand are T0 tokens. Same token fork as Egg.
- **Gelatinous Cube / Almighty Worm overlays** — cannot click Jar as a fight use during overlay; Cube can eat it as a feed.
- **Quiet Bell / Hydra petrify** — Jar is Heal, not even ATK/BLK, Hydra does not petrify it. Stone is chaos color, also not ATK/BLK.
- **Hand full / only the Jar** — Stone is unplayable if it is the only item. Jar might still Heal 2 and Keep with nowhere to Swap.
- **Adventure vs Quick Start pools** — leftover counts only exist if that mode built an item_pool. Challenge consumes copies. Quick Start may refill differently.
- **Empty / last owner / tutorial / Developer Test** — tutorial kit has no Jar. Developer Test Bucket 0 can. Last owner: Heal then Swap still happens, then Done.

**Generous reading:** Jar Heals 2 even if Swap has nowhere to go. Random Swap is some other card in hand, never the Jar (Keep this). Replaced card goes back into the pile (true exchange). Chaos Stone stays click-then-pick-two; those two Swap using the pile. Petrified cards are skipped. Tokens with an empty Tier 0 pile just fail that Swap.

**Stingy reading:** Jar is unplayable if it cannot Swap (only card, or no pile copies of that tier). Random Swap can hit the Jar itself, so Keep is keeping whatever it became. Replaced card is destroyed, not returned to the pile. Chaos Stone also becomes a random auto-Swap like Jar (loses the pick-two). Petrified cards can be swapped. Egg can become another T0 token from the catalog, ignoring the pile.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Swap still uses the old catalog-wide reroll: pile is empty of Sledgehammers and you still get a Sledgehammer.
- Jar Swaps itself, Keep keeps a Helmet that used to be the Jar, card text said Keep this.
- Only Jar in hand: click does nothing, Heal 2 never happens.
- Chaos Stone Ability still says “replace them with random Items” while Shift explains Swap. Two sentences.
- Challenge pile empty of that tier: Swap hangs or returns the same card forever.
- Author-locked Chaos Stone name stays Chaos Stone while chat says Gem. Ability is not in that card’s locked_fields (only tier, count, priority, card_color), so Ability can change.

**What the player sees:** Click Jar: hearts go up by 2, one other card does the purple transform, Jar is still there. Hover Swap: Swap: exchange for a random Item of the same Tier. Chaos Stone: click it, click other cards, those cards transform, Stone is gone. Both inspects show the same Swap line.

**If we skip this:** Chaos Stone already rerolls chosen cards. You do not have a Keep Heal that also rerolls something at random, and Stone still ignores the leftover pile.

**If we take the strongest reading:** Click Jar every fight: Heal 2 forever, and keep fishing the pile for better T2s. If the replaced card does not return, you delete Shields into random T2s until the pile is only leftovers. Chaos Stone plus Jar can churn the whole hand.

**Questions for Nathan:**
1. Jar’s random Swap: a random *other* item in the hand (never the Jar), or it can hit the Jar itself?
2. If the Jar is the only item, or that Swap has no legal leftover copy in the pile: still Heal 2 and Keep, or the click is illegal?
3. The card that got swapped away: goes back into the leftover pile, or it is gone?
4. Chaos Stone: keep today’s click-then-pick-two, each pick is a Swap (pile rule + keyword), or change Stone to a random Swap like the Jar?

**Self-audit:** restated as what the player does · named Chaos Stone/Merchant/Egg/Keep/Zombie · both readings · questions would change the code · not implementing this turn
