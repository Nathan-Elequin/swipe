# Paper Fight — Venom Veins: fill hand with 3-Poison Flasks

**Pitch (Nathan’s words):** Rework for Venom Veins: 'Fill your hand with 3-Poison Flasks. Gain 1 Poison for each Flask you gain'. The item is no longer Kept, it is discarded. Iconography on the item will need to be changed as well.

**Restate (what the player does):** During a fight, you click Venom Veins. It is used up and leaves the hand. Empty seats in the hand become Poison Flasks that already say they mark a Neighbor with 3 Poison (same flasks as today). You also gain 1 Poison on yourself for each of those flasks that actually appear. You then click those flasks one at a time and pick Neighbors, same as a normal Poison Flask.

**Where it happens in a round:** Click during a fight, same as today’s Venom Veins. No extra target click on Venom Veins itself. Used up (not Keep). Each flask’s 3 is copied once when that flask is created. Player Poison still pays when the wheel lands (enemy Poison first, then yours, before on-Spin), same as the 2026-11-12 ruling. HP loss does not fire this card.

**Which existing cards this touches:**
- Poison Flask — the gained cards are that same card, dose 3, click then pick a Neighbor.
- Player Poison / Plague Doctor / Miasma — more Poison on you this click, still pays on the land.
- Recycler's copy, Echo Bell, last-item copy — if they replay Venom Veins, the fill runs again.
- Wealth Tax / Harpy / forced use — a force-click fills the hand the same way.
- Bag of Holding / full-hand replace — Adventure already asks you to toss a card when a gain would go over 10. Filling past the live cap must not open that prompt mid-loop unless we mean it to.
- Decay — Venom Veins no longer says Keep, so Decay can mark it.
- Kiss of Death — still a separate poison-and-change card; flasks from this fill are ordinary flasks, not Kiss.
- Beggar / mute / petrify — an unplayable Venom Veins cannot fill. A playable one can dump flasks into a hand that already has curses.
- Challenge vs Adventure hand size — Adventure seats 10. Challenge/campaign `_hand_limit` is 50, with overflow past the 10-seat tray.

**Generous reading:** Click it. Discard Venom Veins. Every other card in the hand is also thrown away, and every seat (10, or 50 if we use the engine cap) becomes a 3-Poison Flask. You gain that many Poison on yourself. One click can load a full tray of flasks.

**Stingy reading:** Click it. Discard only Venom Veins. Put a 3-Poison Flask into each empty seat that is left, up to the 10 seats you can see. Keep the other cards you already had. Poison on you equals flasks that actually landed. A full 10-card hand that included Venom Veins becomes 9 other cards plus one flask, and 1 Poison.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Filling to the Challenge/campaign cap of 50 dumps flasks into overflow and can give 40+ Poison on you from one click.
- Filling before the discard leaves the hand one over the cap, or leaves Venom Veins sitting next to the flasks.
- Adventure’s replace prompt firing on flask 2 of a fill freezes the fight until you pick a card to toss.
- Echo Bell copies Venom Veins and fills again in the same fight.
- Ability still says Keep while the card is used up.
- Hotbar glyphs still show 1 Poison, one flask, and the Keep hand icon.

**What the player sees:** They click Venom Veins. It leaves. Empty seats become Poison Flask cards whose text is “Mark a Neighbor with 3 Poison.” A Poison number on the player goes up by the number of flasks that appeared. No Keep glyph.

**If we skip this:** Venom Veins stays “click: 1 Poison, one 3-Poison Flask, Keep.”

**If we take the strongest reading:** One click empties the rest of the hand and fills every legal seat with 3-Poison Flasks, then gives you that much Poison on yourself. In a 9-empty Adventure hand that is 9 flasks and 9 Poison; in Challenge overflow it can be much more.

**Questions for Nathan:**
1. After Venom Veins leaves, do the flasks only occupy empty seats, or do they replace the other cards you were holding?
2. How far does “fill” go — the 10 seats on the tray, or the engine cap (50 in Challenge/campaign)?

**Self-audit:** restated as what the player does · named Poison Flask, Echo Bell, Adventure replace, hand cap · both readings · questions would change the code · not implementing this turn
