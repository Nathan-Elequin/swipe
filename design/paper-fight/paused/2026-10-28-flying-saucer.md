# Paper Fight — Flying Saucer

**Pitch (Nathan’s words):**

Item. Tier 2. Flying Saucer (he typed Fying). Image: a dinner saucer turned into a flying UFO. Ability: Gain 5 Block and Flee. The block retains throughout the upcoming Spin, like Stone Wall. Do not write that retain sentence on the card. It is assumed.

**Restate (what the player does):**

During a fight, you click Flying Saucer. You do not click a monster. The card is used up. You gain 5 Block, then Flee: the monster you are facing stays on the wheel, and the wheel spins to a random living monster. That monster does not get their swing before you leave. The Block from this card is still there when the next monster comes up, the way leftover Block from Stone Wall is there for the next fight. The card face says only "Gain 5 Block and Flee". Hold Shift does not add a retain sentence.

**Where it happens in a round:** phase / used up or kept / must they click a target? / is the number copied once or does it keep updating?

Fight, your item click, before you press Done. Used up. No target. The 5 is added to Block once. It does not keep updating. After the next fight ends, leftover Block clears. It does not keep carrying forever. Hollow does not double this 5, because only an even Block gain is doubled.

**Which existing cards this touches:**

- Stone Wall — the pattern for Block that survives one spin. Stone Wall saves the whole Block pile. This card's sentence says "this block", which can mean only the 5.
- Flee — the monster stays. The wheel spins at random. Ball and Chain can cancel that spin and show Can't Flee. Sandbag still does its other effect when that happens.
- Eel — gaining Block deals that much Attack to the Eel. If that drops the Eel to 0, that is a Defeat. The Eel leaves. The wheel still spins. Flee does not also keep a dead Eel on the wheel.
- Amalgam — using an item doubles Amalgam, then you leave. The doubled Amalgam is still on the wheel.
- Dragon — Attack ignores Block. The 5 can be sitting there and still not stop a pierce hit.
- Rust — while Rust is up, monsters ignore Block. The number can still be saved.
- Hornet and Queen — the next fight uses normal Block. Hornet's two swings share that one pile.
- Goblin — ignores Attack damage. Block does not matter against that.
- Smoke Bomb — also leaves the current monster by spinning. It does not grant Block.
- Empty seat / no one faced — you cannot play it, same as other fight items.
- Tutorial — Flee already has a tutorial exit. This card uses that path.

**Generous reading:**

You gain 5 Block, then Flee. When the wheel spins, all Block you have left is saved, including Block you already had. If Ball and Chain stops the Flee, the 5 is still gained, the card is used up, and the save stays armed until this fight eventually ends.

**Stingy reading:**

You gain 5 Block, then Flee. When the wheel spins, only what is left of that 5 is saved. Block you already had still clears. If Ball and Chain stops the Flee, you keep the 5 for this fight only, and it clears when the fight ends, because this card's spin did not happen.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**

- The card is on the board as hold, so a draft cannot offer a card whose click does nothing yet.
- Eel dies from the Block gain and the game tries to Flee and Defeat the same monster.
- Ball and Chain cancels the spin and the 5 is both saved and cleared.
- Stone Wall and this card both try to bank Block on the same spin and one overwrites the other.
- The next fight shows 5 Block, then a second spin keeps it again.
- Shift text mentions retain after he said not to put that on the card.

**What the player sees:**

The card says Gain 5 Block and Flee. Flee uses the existing hover: if you are facing them, the wheel spins at random, and they stay. After the click, Block goes up by 5, the current monster leaves the center without swinging, and the next monster is faced with that Block still up. The card is gone from the hotbar.

**If we skip this:**

Stone Wall already keeps leftover Block for one fight, and Smoke Bomb already spins you off the current monster. Nothing does both on one Tier 2 card.

**If we take the strongest reading:**

One click leaves the current monster and starts the next fight with every Block you had, plus 5, and that pile lasts the whole next fight. It does not kill the current monster by itself. Against Eel, the 5 Attack can Defeat them before the Flee.

**Questions for Nathan:**

1. When the wheel spins, what is saved for the next fight: only what is left of this card's 5, or the whole Block pile, including Block you already had?
2. If Ball and Chain stops the Flee, is the 5 ordinary Block for this fight only, or does it still get saved when the fight later ends?

**Self-audit:** restated as what the player does · named a live collision · both readings · questions would change the code · not implementing this turn
