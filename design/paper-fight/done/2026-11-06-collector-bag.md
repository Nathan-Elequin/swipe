# Paper Fight — Collector bag on defeat

**Pitch (Nathan’s words):**

When you defeat an enemy by using a bag you already hold (Bag of Holding, or a filled bag such as Bag of Dire Wolf), Collector does not treat that as a Defeat for giving you another bag of that monster. In the Dire Wolf example, the bag you used already became Bag of Dire Wolf, and Collector still handed over a second one. He should not.

Separately: if Collector’s bag is placed into your hand because you ended the fight with Take, and the hand is already full, you are prompted to discard one item before anything else resolves. The new bag itself can be the discard. That prompt comes before the empty seat fills from the dungeon deck, before a draft, and before a spin. Same bar for any other resolution in that same ending.

Earlier in this same fight: when the discard-without-use tax fires, Collector’s slash portrait plays and the hearts leave him, the way Ogre’s empath loss already plays. That part is not a question.

**Restate (what the player does):**

You use a bag on the faced monster. The bag you clicked changes into a bag of that monster and the monster leaves. Collector does not give you a second copy.

You press Take, the fight ends, and a monster was defeated. Collector offers a bag of that monster at the HP it had before the killing hit. If your hand has a free slot, the bag goes in and the rest of the ending continues. If the hand is full, the game asks you to throw one card away. You may throw a card you were holding, or the new bag. Nothing else in that ending runs until you have picked. Then the seat fills, the draft opens, and spin can happen.

**Where it happens in a round:** fight end, after the monster is defeated, before the seat, the draft, and spin. The bag you used is kept (it transforms). The new bag is kept only if you do not throw it away to make room. No new number. Collector does not ask you to pick a target. The full-hand prompt does.

**Which existing cards this touches:**

- Bag of Holding, and any filled bag (Bag of Dire Wolf, Bag of Gargoyle, Bag of Leech League). Using one removes the faced monster and rewrites that same card. Collector’s reward runs from the same defeat step, which is why a second bag appears.
- Boot, Orb, and other defeat items. Those are not bags. Collector still bags the monster they remove.
- Take. Ending the fight this way still defeats the owner, and that is the path that granted Bag of Leech League into a 10-card hand.
- Draft gains already wait on the full-hand throw. Collector starts that same prompt and then lets the ending continue, so the seat fills while the extra bag is still hanging off the hand.
- Discard without Use. Throwing a held card in that prompt already goes through the unused-discard path, so Collector would lose 2 HP. Refusing the new bag itself does not, today.
- Trapper, Phoenix, Wraith, Martyr, Rust Bucket, Mimic. They still react to the defeat. This change only skips Collector’s extra bag when the removal was a bag you used.
- A second living Collector. Each one still offers a bag. Each full hand waits for its own throw before the ending continues.
- Curses and the other cards you are not allowed to throw. The new bag is a legal throw. If nothing can be thrown, the bag is refused and the ending continues.
- Adventure. Same wait before the hole closes and before spin. Challenge is the dungeon-deck seat the screenshot showed.

**Generous reading:**

Any removal that came from using a bag gives no Collector bag. A normal kill still gives one, even if you already hold a bag of that same monster. When the offered bag meets a full hand, every later step of that ending waits, and neither throwing a held card nor refusing the new bag costs Collector HP.

**Stingy reading:**

Only the bag-use case skips the extra bag. The full-hand throw is a real Discard without Use: throwing a held card or the new bag both cost him 2 HP, and the slash portrait plays, before the seat, the draft, and the spin.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**

- The ending waits forever because the throw prompt never clears.
- The seat fills, or a spin starts, while the extra bag is still waiting for a throw.
- Refusing the new bag, or throwing a held card, taxes Collector and he dies in the middle of the prompt, and the ending never resumes.
- Using a bag still creates a second bag of the monster you just bagged.
- A normal Take kill stops giving a bag even though you did not use a bag.
- Ability text still says every Defeat bags the enemy, while bag-use defeats do not. The Shift line would need the same exception, in his words, if he wants the card to say it.

**What the player sees:**

Bag use: one bag, now named for the monster you bagged. No second bag, no New Specimen line.

Take, hand not full: New Specimen, the bag lands, then the seat, the draft, and spin.

Take, hand full: the throw prompt, including the new bag. After the click, the seat, the draft, and spin. If the tax applies, his slash portrait and the 2 HP loss play before those.

**If we skip this:**

Bagging a monster with a bag you hold also gives you Collector’s copy. A full hand shows the new bag past the tenth card while the next monster is already seated.

**If we take the strongest reading:**

One bag use cannot fill the hand with two copies of the same specimen. A full-hand Collector bag cannot be skipped past: the fight ending is stuck on the throw until you pick, and that throw can drop his HP before anything else.

**Questions for Nathan:**

1. If you already hold a Bag of Dire Wolf, and you later defeat a Dire Wolf with Take, an attack, or Boot, does Collector still give you another Bag of Dire Wolf?
2. When the hand is full and you throw a card to settle his bag, does he lose 2 HP for Discard without Use? Same question if the card you throw is the new bag?

**Answers (2026-11-06):**

1. Yes. Only using a bag skips the extra bag. A normal kill still gives one.
2. Yes. Throwing a held card or the new bag both cost him 2 HP, and the slash plays, before the seat, the draft, and spin.

**Self-audit:** restated as what the player does · named a live collision · both readings · questions would change the code · implemented this turn
