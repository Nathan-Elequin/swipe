# Paper Fight — Spiked Shield rework

**Pitch (Nathan’s words):**
Move Spiked Shield to Pool 2. Ability: "3 Attack or 3 Block. Alternates on Item Use." It is identical to Sai, but it alternates between Attack and Block. As that face changes, it can turn Chakram’s Attack half and Block half off or on.

**Restate (what the player does):**
During a fight, Spiked Shield is already showing one face: Attack 3, or Block 3. You click it. You do not pick which one. Attack 3 hits the monster you are facing, then the card is used up. Block 3 adds 3 Block, then the card is used up. Any item use flips the face, including this click and including a different item used while the shield is still in your hand. The new face is what you see before the next click. A spent shield still flips when later items are used, same as Sai, so the face it comes back with next fight is whatever it landed on after the last item use. It keeps that face from fight to fight. A new dungeon starts it on the opening face again, same as Sai starts back at 2.

**Where it happens in a round:** fight, after you have a hand. Used up on click. No second target click. The number is not copied from another card. It keeps updating every time an item is used.

**Which existing cards this touches:**
- Sai — same flip clock: every item use, carries between fights, resets on a new dungeon, click uses the face that is already showing.
- Chakram — a playable Attack face turns Chakram’s Attack 3 off and leaves Block 3 on (unless some other playable item is also blocking that half). A playable Block face does the opposite. A spent shield counts as neither, so Chakram stops seeing it until the shield comes back next fight.
- Pacifist — grey while any playable item deals Attack. An Attack-face shield does that. A Block-face shield does not.
- Basilisk — locks the highest Attack item after the spin. Attack 3 counts. Block face does not count as an Attack item.
- Wizard (the cat that turns Chakram-style Attack/Block items into marbles) — the current face is what puts the shield in that pool.
- Goblin — Attack 3 deals 0. Block 3 still adds Block.
- Hornet, pierce, Anvil — Attack 3 is a normal Attack hit. Block 3 is a normal Block gain (odd, so Hollow does not double it).
- Echo Bell — if it copies this item, the copy should be the face showing at the copy, then flip on its own item uses the way a second Sai does.
- Tutorial kit — this card is not in the opening four. No tutorial target problem.
- Pool 2 — already has 12 items (quota is 5). Moving only Spiked Shield does not drag anyone else. A legal five-card pool would move more than two cards, so that reshuffle is not part of this rework unless you say so.

**Generous reading:**
The face that is showing is the whole card. Attack face is only an Attack item. Block face is only a Block item. Chakram, Pacifist, Basilisk, and the cat all follow that. You can flip it mid-fight by using a different item first, then click Chakram while the shield is still unspent and see the other half.

**Stingy reading:**
Only Chakram watches the face. Every other “is this an Attack item?” check still treats Spiked Shield as both, or as whatever it used to be. That reading fights the sentence “3 Attack or 3 Block,” because the card would still be the verb it is not showing. I am not taking the stingy reading.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- The old inspect line still offers “deal 2 attack or gain 2 block” as a choice. This rework is not a choice. The click must match the face already on the card.
- The face flips before the hit, so you click Attack and get Block.
- Chakram checks the shield one frame before the flip, so using another item does not change Chakram until the next fight.
- A new dungeon forgets to put it back on the opening face, or a new fight resets it when Sai would have kept the number.
- Shift text still says “Block equal to your highest Attack item.”

**What the player sees:**
The hotbar number is 3, labeled Attack or Block, and it swaps when any item is used. Chakram’s available half swaps with it while the shield is still playable. One click does that one thing and the card is spent.

**If we skip this:**
Spiked Shield stays “Block equal to your highest Attack item” in Pool 7 on the catalog (Pool 5 on the board). Sai remains the only flip-after-item-use card. Chakram never gets a card that swaps which half it turns off.

**If we take the strongest reading:**
One click is either Attack 3 or Block 3, never both. It does not end a fight by itself unless the facing monster has 3 HP or less and you are on the Attack face. Chakram can be steered, not doubled, by the face.

**Questions for Nathan:**
1. New dungeon, first face: Attack 3, or Block 3? (Sai starts on the first number. Your sentence lists Attack first. Both are still a real choice.)
2. Pool 2 already has 12 items. Only Spiked Shield moves to Pool 2, tier stays 1, and nobody else is dragged. Confirm that, or say you want a cut list.

**Self-audit:** restated as what the player does · named a live collision · both readings · questions would change the code · not implementing this turn

**Answers (2026-10-28):**
1. A new dungeon starts on Attack 3.
2. Pool 3. He will tweak the pool later. Nobody else was dragged. Tier stays 1.

**What shipped:** Same flip clock as Sai. The click uses the face already showing, then the card is used up and leaves the hand. An unspent Spiked Shield keeps the new face into the next fight. Using it discards it, so that copy does not come back. Chakram, Gargoyle’s highest Attack, Sling, and the cat all read the current face only.
