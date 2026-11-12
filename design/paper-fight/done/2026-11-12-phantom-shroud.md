# Paper Fight — Phantom neighbor Shroud

**Pitch (Nathan’s words):** 6 HP, 6 ATK. Dark Matter: “I Always Shroud my Neighbors and the Dungeon Deck. When I enter, I Shuffle the wheel.” Shroud: “Hidden until Defeated, or until you resolve combat while facing them.”

**Restate (what the player does):** Phantom enters, slashes, and the wheel shuffles under covers. Phantom stays visible unless another Phantom covers it. The two neighbors and the top of the Dungeon Deck stay hidden. Take shows Take ?. Clicking it lifts the cover and plays the fight. A kill lifts the cover before the hit. Flee covers them again only if they are still beside Phantom.

**Where it happens in a round:** On enter (opening deal or a later draw). The cover keeps updating while Phantom is alive. The card is not used up. The player does not pick a target for the cover. Numbers on a covered monster stay hidden and keep updating in the background.

**Which existing cards this touches:**
- Protector, Refract, Fairy, Martyr, Wraith, Pocketwatch, Polymorph
- Phoenix Egg, Petty King, Commander, and other Flee
- Quiet Bell
- A second Phantom
- The old item Shroud on the hotbar (removed)

**Generous reading:** After you finish combat facing them, they stay visible even if they are still neighbors. Flee is the exception that covers them again when they are still beside Phantom.

**Stingy reading:** They would be covered again whenever they are neighbors, including right after combat. Nathan chose the generous reading, plus: Phantom’s Defeat drops every cover that Phantom caused. Quiet Bell lifts covers while it lasts. A Phantom can be covered by another Phantom.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- A covered monster’s name or HP showing on the wheel, the log, Take, or the deck top
- Undo putting the pre-shuffle seats back
- Item Shroud still firing on Use
- A kill playing under the cover

**What the player sees:** Covered seats are a dark veil with ?. Take ? while facing one. A ? callout when a covered monster has to act on something you can see.

**If we skip this:** Phantom keeps covering items.

**If we take the strongest reading:** One Phantom can hide two monsters for the whole fight, and a second Phantom can hide the first.

**Questions for Nathan:** Answered. Cover stays on those monsters until you defeat them or finish combat while facing them, even across the wheel. Neighbors never play an enter portrait. Quiet Bell lifts covers and puts them back. A Phantom can be covered. Phantom’s Defeat clears that Phantom’s covers.

**Self-audit:** restated as what the player does · named a live collision · both readings · questions answered · implemented
