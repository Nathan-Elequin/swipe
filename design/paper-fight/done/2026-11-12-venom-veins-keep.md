# Paper Fight — Venom Veins: Gain 1 Poison and a 3-Poison Flask

**Pitch (Nathan’s words):** Rework Venom Veins: Gain 1 Poison and a 3-Poison Flask.

**Restate (what the player does):** Venom Veins is in the hand. The player does not click it. Something causes them to gain 1 Poison and also gain a Poison Flask that is already set to 3. They can click that flask and mark a Neighbor with 3 Poison. The veins card itself stays in the hand.

**Where it happens in a round:** Today the card is unplayable and fires on every HP loss while it is held (attack, Bleed, Poison paying on a Spin — any loss, no cap). The flask is the live Poison Flask card, pre-marked at 3. Player Poison from this card was removed on Nov 8. This rework puts a Poison gain back next to the flask. The number on the flask is copied once when the flask is created. It does not keep updating.

**Which existing cards this touches:**
- Poison Flask — the gained card is that same card, dose 3, click then pick a Neighbor.
- Player Poison — pays on the next Spin before the wheel lands, and that payment is itself an HP loss.
- Venom Veins today — `_note_hp_lost` calls `_venom_veins_on_hp_lost`, which only adds the Mark-3 flask.
- Pacemaker — also listens to HP loss (only when the loss is exactly 2).
- Grief Jar — also listens to HP loss.
- Plague Doctor — gives you Poison on Spin. A later payment of that Poison is an HP loss.
- A full hand — gaining the flask already opens the replace prompt, or drops the gain if the hand cannot take it.

**Generous reading:** Keep the current trigger. While Venom Veins is in your hand, every time you lose HP you gain 1 Poison on yourself and one 3-Poison Flask. That includes the HP you lose later when that Poison pays. The card stays unplayable and is not used up. Two copies in hand each fire.

**Stingy reading:** The card does this once. When it enters your hand you gain 1 Poison and one 3-Poison Flask, and later HP loss does nothing. Or: HP loss still fires, but the Poison this card gave you does not count as a new Venom Veins trigger when it pays.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Poison pays on Spin, that HP loss grants another Poison and another flask, and the hand fills with flasks every Spin until the card is gone.
- The Ability line still says only “When you Lose HP, Gain a 3-Poison Flask” while the hit also gives Poison. Ability, explainer, and flow are author-locked, so the new sentence waits on this answer.
- A full hand during the HP-loss animation opens the replace prompt in the middle of the hit.

**What the player sees:** Hearts drop. A poison mark appears on you. A Poison Flask appears in the hand, and its text says it marks a Neighbor with 3 Poison.

**If we skip this:** Venom Veins stays “unplayable, on HP loss, flask only.” No Poison on you.

**If we take the strongest reading:** Every HP loss, including Poison you already have, prints another Poison and another flask for as long as the card is in hand. One bad fight can fill the hand.

**Questions for Nathan:**
1. When does the Poison and the flask appear?
2. “Gain 1 Poison” — on you, or on the monster you are facing?
3. When that Poison later makes you lose HP, does Venom Veins fire again?

**Self-audit:** restated as what the player does · named Poison Flask and the Spin Poison payment · both readings · questions would change the code · not implementing this turn

**Answer (2026-11-12):** Click it. Ability: "Gain 1 Poison and a 3-Poison Flask, then Keep this." The Poison is on you and pays when the wheel lands (enemy Poison first, then you, before on-Spin effects). Keep means spent this fight, back next fight. HP loss does not fire it. Hotbar face: 1 Poison, Poison Flask, Keep hand glyph.
