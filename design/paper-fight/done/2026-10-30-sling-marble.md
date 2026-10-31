# Paper Fight — Sling rework (turn into a 0 Marble, then Draw 1)

**Pitch (Nathan’s words):** Sling rework. Ability: Turn any Item in your hand into a Marble, then Draw 1 Item. Creates a 0 Marble. Yes, this works on curse cards.

**Restate (what the player does):** During a fight you click Sling, then you click one card in your hotbar. That card is replaced by a Marble whose number is 0 (the same Marble token Bag of Marbles makes). Sling is used up. Then you draw 1 Item from the item deck into the hotbar, the same draw Catapult uses. Curses are legal (Spider Egg, Toll, Rust). The new Marble is clickable at 0 (Marble’s own rule: 0 can be clicked and is used up; each Spin it is still in hand it grows by 1).

**Where it happens in a round:** Fight, unless Nathan says Ready too. Used up. Click Sling, then click a hotbar card — same extra click as Throwing Knife, but the second click is a card in hand, not a monster. The Marble’s 0 is written once at convert; after that it grows on Spin like every other Marble. The draw is after the convert.

---

**Which existing cards this touches:**

- **Marble / Bag of Marbles** — Sling now *makes* a Marble instead of aiming an Attack. Bag fills empty seats with 0 Marbles. Sling overwrites an existing card in place. If you can convert a Marble that already grew, you reset it to 0.
- **Curses (Spider Egg, Toll, Rust)** — Nathan: legal. Toll’s countdown and Rust’s pierce-while-held both stop if that card is now a Marble. Cube / Worm / Bell / Hired Hand still cannot dump a curse; Sling is a way to get rid of them.
- **Cursed Scroll** — not tagged `curse`, but it is an Item that bleeds you on Spin until used. “Any Item” includes it unless Nathan narrows the list.
- **Recycler** — watches Discards. In-place morph is not a Discard. If we treat convert as discard-then-gain, Recycler ticks.
- **Beggar** — marks a random item including curses. If the marked card becomes a Marble, does the mark stay on that seat, or did you “use” the marked item (mark moves)?
- **Keep items (Boot, Net, …)** — converting them throws away Keep. Marble is used up when clicked.
- **Smoke Bomb** — opening extra, teaches Spin. Converting it removes the Spin teacher from the hand.
- **Petrified / Quiet Bell** — stoned cards cannot be used. Can they still be chosen as the thing that becomes a Marble?
- **Phoenix (token) / other tokens** — “any Item in your hand.” Tokens sit in the hotbar. Converting Phoenix removes the revive token.
- **Bag of Holding** (renamed bag) — still an Item in hand. Convert dumps the captive? Bag Flow says unused bag does nothing at a clear; morph mid-fight is a new dump path.
- **Chakram** — halves look at whether other cards deal Attack or grant Block. Replacing the last Attack with a 0 Marble (random Attack or Block on click) changes what Chakram shows.
- **Echo Bell** — echoing Sling would convert a second card and draw again, if Echo copies the whole resolve.
- **Catapult / Grappling Hook** — the Draw 1 Item already exists. Full hand: those cards already have a replace-a-card path. Same here or skip the draw?
- **Goblin / Hornet / Queen / Wraith / Commander / Dragon / Mimic / Slime** — Sling no longer aims their seats. They only matter if you later click the Marble as Attack. Goblin still ignores that Attack. Hornet’s two swings are not on the Marble. Empty alcove does not block convert (second click is the hand).
- **Tutorial kit** — Sling is not in the opening kit today. If the only other card is missing, Sling is unplayable (or you convert Sling itself).
- **Developer Test / one-card hand** — only Sling in hand: illegal unless converting Sling is allowed; then you get a 0 Marble plus a draw.

**Generous reading:** Click Sling, click any hotbar card including Sling, curses, Keep, Smoke Bomb, tokens, petrified cards, grown Marbles, and a filled Bag of Holding. That seat becomes a 0 Marble in place (not a Discard). Sling is spent unless it *was* the target, in which case that one card is the Marble. Then Draw 1, and if the hand is at 10 you pick something to throw away the same way a full-hand gain already works. Cancel before the second click leaves Sling unspent.

**Stingy reading:** Fight only. Second click must be a *different* card. Grown Marbles, tokens, Smoke Bomb, petrified cards, and Keep cards are illegal (curses still legal). Convert is discard + gain Marble, so Recycler ticks and a Beggar mark on that card is spent. Full hand: Draw is skipped. Cancel still spends Sling with no Marble and no draw.

**Ways it can fail:**
- Waiting for a hand pick after Sling is already gone (Throwing Knife bug).
- Converting Sling into a Marble and also tossing Sling — two removals, empty seat, crash.
- Toll / Rust still ticking because the curse flag survived on the new Marble.
- Bag of Holding captive lost with no rule, or duplicated onto the wheel.
- Draw with 10 cards and no replace picker: draw vanishes or overflows the bar.
- Tutorial / one-card hand: Sling looks usable, click does nothing.
- Echo Bell copies Sling forever if convert does not spend the echo source.

**What the player sees:** Click Sling, hotbar cards highlight, click one, it becomes a Marble showing 0, Sling leaves, a new Item flies in. If they wanted the old “load an Attack and hit anyone,” that click path is gone.

**If we skip this:** You already have Bag of Marbles (fill empties with 0 Marbles) and Catapult (Draw 1). You cannot spend a card to delete a curse into a Marble.

**If we take the strongest reading:** One click path deletes Toll, Rust, a grown Marble, Smoke Bomb, or a filled bag, replaces it with a 0 Marble, and draws a fresh mill card. Curses stop being sticky. Full-hand replace after the draw can dump a second card.

**Answers (2026-10-30):**
1. Any other hotbar card: Keep, Smoke Bomb, tokens, petrified, grown Marbles, filled Bag of Holding, plus curses.
2. Sling itself is not a legal second click.
3. In-place morph — not a Discard (Recycler does not tick; Beggar mark stays on that uid).
4. Full hand: same replace picker as other gains.
5. Cancel (click Sling again): Sling stays. No Marble. No draw.

**Built:** `_apply_sling_convert` / `_sling_morph_into_marble`. Filled Bag of Holding seats the captive on the wheel, then that card becomes the Marble. Petrify clears.

**Self-audit:** restated as what the player does · named Marble, curses, Recycler, Beggar · both readings · answers implemented
