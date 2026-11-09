# Paper Fight — open playtest issues (2026-11-08)

**Pitch (Nathan’s words):**

Show the open playtest issues and ask before changing rules.

- [#483](https://github.com/Nathan-Elequin/swipe/issues/483) — Spinning Top should let you target any monster, not only the one you are facing. Log: facing Collector at 9 HP, click Top, “Used cannot”.
- Saved Ability (already on the card): “Defeat an enemy with HP equal to this number. +1 each Spin.” The previous sentence also said it starts at 0 and only counts Spins while held.
- [#482](https://github.com/Nathan-Elequin/swipe/issues/482) — Death Bell’s Toll did not count Bag of Holding. Keep items and Bag still count as a Use even when the card is not discarded. The pasted log does not contain a Bag line.
- [#451](https://github.com/Nathan-Elequin/swipe/issues/451) — Eel turns Block you gain into Attack damage. Bodyguard (Protector) took that hit and should have died. Log: Grief Jar Block 3, then Helmet “BLK +4 to 4”, then “Bodyguard - Protector”.
- [#452](https://github.com/Nathan-Elequin/swipe/issues/452) — A wheel spin caused by a poison kill still counts as a Spin for Grief Jar, Marble, and Spinning Top. One reading. Not a question.

**Restate (what the player does):**

Spinning Top: during a fight you click Top, then you click a monster anywhere on the wheel. If that monster’s HP equals the number on Top, they are Defeated and Top is used up. If it does not equal, the click fails and Top stays.

Toll: you click Bag of Holding, or a Keep item, and the card stays in hand (Bag becomes the filled bag). Toll still counts down by 1 for that click.

Eel: you gain Block while facing Eel. Eel takes Attack damage. If a neighboring Bodyguard takes that hit instead, the Bodyguard can die from it.

**Where it happens in a round:** phase / used up or kept / must they click a target? / is the number copied once or does it keep updating?

- Top: fight, click card then click a monster, used up only on a successful equal-HP Defeat. The number still goes up on Spin.
- Toll: after the item click resolves, including a Bag that removes the monster. Toll is a countdown, not a copy.
- Eel: when Block is gained, that same moment. Bodyguard redirect happens before HP changes. Not a click-target.

**Which existing cards this touches:**

- Throwing Knife / Poison Flask (click, then click who)
- Boot and other Defeat items, Goblin (Defeat is not Attack), Lich undying, Quiet Bell
- Death Bell Toll, Counting Beads, Keep items, Bag of Holding, items that end the fight inside the click
- Eel Conductive, Helmet, Grief Jar, Bodyguard Protector, Block that does not raise your total by the full card number

**Generous reading:**

Top can Defeat any living monster whose HP equals its number, after you click that monster. Toll ticks on every successful item click, including Bag and Keep, even if that click removes the monster or the fight moves on inside the click. Eel’s Attack equals the Block the card grants (Helmet 4), and a Bodyguard who takes that whole hit dies if it is enough.

**Stingy reading:**

Top still only checks the monster you are facing; “any monster” waits. The shorter Ability is card text only: it still starts at 0 and only counts Spins while it is in the hotbar. Toll only ticks when the current “items this combat” path finishes; a Bag that changes the fight before that path finishes does not tick. Eel’s Attack equals only the Block you actually gained (3 then “+4 to 4” is +1), so a 3 HP Bodyguard lives.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**

- Top click with no legal monster, or a click on an empty seat, leaves the fight waiting for a target.
- Bag removes the last monster and the Use counter never runs, so Toll and Beads disagree with the card you just clicked.
- Bodyguard logs Protector and the HP never drops, so the player saw the call and not the death.

**What the player sees:**

A second click on a monster for Top. Toll’s number goes down after Bag or Keep. Bodyguard’s HP drops by the Eel hit, and they leave if that reaches 0.

**If we skip this:**

Top still prints “cannot” unless the facing monster’s HP matches. Bag can remove a monster without moving Toll. Bodyguard can announce Protector and stay alive.

**If we take the strongest reading:**

Any living monster is a legal Top target when their HP matches. Every real item click ticks Toll. Eel deals the card’s full Block number, and Bodyguard can die from the redirected hit.

**Questions for Nathan:**

1. Top target click, and what a wrong HP does.
2. Whether the shorter Top sentence changes “starts at 0” and “while held”.
3. Whether Bag and Keep tick Toll when the card is not discarded, including when the click removes the monster.
4. Whether Eel’s damage is the Block on the card, or only how much your Block total went up. Bodyguard death follows that number.

**Self-audit:** restated as what the player does · named a live collision · both readings · questions would change the code · not implementing this turn
