# Paper Fight — Trapper rework (Bear Trap)

**Pitch (Nathan’s words):** Trapper, Tier 2, 2 HP 3 ATK. Call name Bear Trap. Ability: When I arrive, I place a Bear Trap on top of the Dungeon Deck. Token monster Bear Trap, 2 HP 4 ATK. Call name Bear Trap. Ability: When you Spin me or Move onto me, I immediately Attack you and then I am Defeated. Even if the player Moves onto the trap it activates (more reactive than Harpy). Jar O' Grease gets interrupted (if it was the 1st movement, the 2nd does not happen).

**Restate (what the player does):** Trapper sits on the wheel as a normal 2 HP / 3 Attack fight. When Trapper arrives, a Bear Trap token is put on top of the Dungeon Deck (same place Phoenix puts a Phoenix Egg). Later, when that trap is seated and you Spin onto it, or you Move onto it, it hits you for 4 Attack right then, then it is Defeated. You do not get a normal item fight against a trap you just landed on. If Jar O' Grease’s first slide lands on the trap, the second slide does not happen. Trapper himself does not snap; only the token does.

**Where it happens in a round:** Trapper’s place-on-deck is automatic when he arrives (no click). Bear Trap’s snap is automatic on Spin or Move onto that seat (no click, no target pick). The trap is used up by its own Defeat. The 4 Attack is the number on the trap’s plate at that moment (Commander / Lich can still rewrite plates before you land). Keep vs used-up does not apply; it is a monster, not an item.

---

**Which existing cards this touches:**

- **Harpy** — Spin onto Harpy: she Attacks, fight stays open, she Attacks again after items. Spin onto Bear Trap: it Attacks and is Defeated immediately. Move onto Harpy does nothing extra. Move onto the trap does. Issue #223 is the Harpy “only once on Spin” report; this card is meant to be the Move-reactive one.
- **Jar O' Grease** — click slides two living seats without Spinning and without spending an Adventure Move. Nathan: if the first landing is the trap, the second slide does not happen. Live Ability vs Flow on Grease already disagree (Move 2 and Keep vs Heal 2 plus a passive extra seat); the interrupt is about whichever path actually slides you.
- **Adventure Move arrows** — `_shift_facing` to a neighbor without Spinning. Nathan: this activates the trap.
- **Shuriken** (`atk_move`) — shifts facing, then deals 3. Live Move keyword is “shift to a Neighbor without Spinning,” which includes this. If that is Move, landing on the trap may cancel the 3 the same way Grease’s second seat is cancelled — or the 3 still happens after the snap.
- **Phoenix / Phoenix Egg** — already “put X on top of the Dungeon Deck.” Challenge and Adventure draw it as the next hole fill with loot. Mill does not draw that deck, so an Egg is installed into the vacated seat. Same seating question for Bear Trap when Trapper is still occupying a seat (trap waits on top; next empty / next draw).
- **Goblin** — Goblin ignores Attack you deal. The trap Attacks you, so Goblin’s ignore does not protect you.
- **Block / Shield / Buckler** — Harpy’s Spin swing spends Block. Does the trap’s 4?
- **Needleback** — when you Gain Block, Needleback takes that much. Not the trap’s swing. If you somehow Gain Block while facing the trap, Needleback still applies; the trap does not wait for that.
- **Dragon pierce** — pierce is about your Attack vs Block on them. Trap is attacking you.
- **Hornet / Queen** — extra swings on Done. You never reach Done if Spin/Move already Defeated the trap.
- **Wraith** — copy ATK. If you could stay in a fight with the trap, you would copy 4. Snap-on-land means you usually cannot click Wraith-style items into it.
- **Commander / Lich** — last in the formula. The 4 on the trap can be rewritten before you land. Trap self-Defeat is a Defeat: Commander may Flee instead of leaving; Lich may chip 1 and stay. That would leave a trap that already snapped, or snap again — a real collision.
- **Mimic** — gift on Defeat. Does trap self-Defeat count?
- **Clockwork Knight** — neighbors match on Defeat. Trap leaving can fire Synchronize.
- **Slime** — ATK = HP. Trap is 2/4, not Slime. No collision unless Polymorph.
- **Empty alcove** — Move walks to the next living monster, so you cannot “Move onto” an empty seat. Grease: if the second seat has no living monster you only slide one. A trap is living until it snaps.
- **Last owner** — Spin onto the last trap: 4 to you, trap Defeated, dungeon may clear. If that 4 kills you, the run ends on the snap.
- **Tutorial kit** — Trapper is Pool 5 today; tutorial does not seat him. Developer Test can.
- **Quiet Bell** — turns Phoenix Egg / other on-wheel specials off. Does a silenced Trapper still place a trap? Does a silenced trap still snap?
- **Net / Boot / Sledgehammer / Hex** — if snap is immediate on land, you cannot use these on a trap you just Spun or Moved onto. You could still use them if the trap is facing you without a snap (hole fill / start of fight).
- **Take / Done** — snap-on-land skips the item window. Done’s normal hit never happens for that landing.
- **Cleric / Grief Jar / Cursed Scroll / poison / leech / Queen eggs / Juggernaut** — On Spin order. If you Spin onto the trap, does the trap snap before those, after, or mixed? If the 4 kills you, later On Spin does not run.
- **Bag of Holding** — bagging Trapper: does “arrive” already have placed the trap? Bagging the trap: is that Defeat or a skip of the snap?
- **Eject / Polymorph / Flee** — not Spin, not Move. Do they seat you onto a trap without snapping?
- **Smoke Bomb / Flee Spin** — a Flee that Spins onto the trap is a Spin, so it should snap.
- **Bodyguard / Cowardly King** — King commands a neighbor Attack after your HP loss. Trap snapping is the trap Attacking you, then leaving. King’s “after you lose HP” could fire mid-snap.
- **Spider Egg** — auto damage token in a different way (Take damage). Not the same seating.
- **Marked (old Trapper)** — this rework deletes Hunter’s Mark. Existing Marked hover text (“upon Defeat, Trapper gains +2 HP and ATK”) must go or it will lie.

**Generous reading:** Trapper places a trap the first time he sits on the wheel. The trap only snaps on a real Spin or a Move/slide onto that seat. Hole fill that leaves you already facing the trap is a normal 2/4 fight until you Spin or Move. Block works. Self-Defeat is a real Defeat (loot, Mimic, Clockwork). Quiet Bell turns the snap off so you can fight or Boot it. Shuriken is Move and also gets interrupted (no leftover 3). Mill installs the trap like a Phoenix Egg into the next vacated seat.

**Stingy reading:** “Arrive” is any time Trapper enters the dungeon deck or the wheel, even from mill. The trap snaps the instant it is the one you are facing, including hole fill with no Spin and no Move. Block does not help. Self-Defeat is only “leave the seat” with no loot and no on-Defeat gifts. Quiet Bell does nothing. Shuriken’s 3 still hits after the snap. Commander/Lich on the trap still use their Defeat exceptions (Flee / chip 1), so the trap might not actually leave.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Trap snaps on hole fill, then Defeat hole-fills another trap or the same draw loop, infinite fill.
- Commander Flee on trap self-Defeat: you take 4, Commander Flees, random Spin, maybe onto another trap, chain.
- Lich chip: trap Attacks, “Defeated” only hurts Lich for 1, trap still facing you, next item or Done hits you again — Ability said it is Defeated.
- Grease second slide still runs because snap is async after `_shift_facing` returns true.
- Mill: trap sits on a deck that never draws, so Trapper’s Ability is a lie in mill unless we install like the Egg.
- Two Trappers: two traps on top; next two fills are both traps. Easy to death-spiral if snap-on-fill is true.
- Inspect still shows Hunter’s Mark / extra swings per item (live Flow on Trapper already does not match live Ability).
- Keyword hover: `|Bear Trap|` has no definition yet. `|Defeated|` already maps to “They leave the wheel…” which matches the token sentence better than catalog `defeat` (Boot/Sledgehammer).

**What the player sees:** Trapper is a small 2/3 fight and a trap appears on the deck count. Later a Bear Trap seat shows 2 HP / 4 Attack. Spin or Move onto it: you take 4 (or Block soaks it), the trap leaves, no item window. Grease that lands on it on the first slide stops there.

**If we skip this:** Trapper stays Hunter’s Mark (on enter, Mark 2; marked Defeat +2/+2), which already disagrees with his Flow text (extra Done swings). Harpy remains the only Spin-interrupt. Move stays safe.

**If we take the strongest reading:** Hole fill seats a 4-Attack snap with no Block, no item window, and a real Defeat chain, possibly into another trap, in mill and Challenge. One Trapper arrival can kill you on the next empty seat without a click.

**Questions for Nathan:**
1. When does Trapper “arrive” (when he sits on the wheel, vs when he first enters this dungeon’s deck)?
2. If you are already facing the trap with no Spin and no Move (hole fill / fight start), does it snap now, or wait, or sit as a normal fight?
3. What counts as Move for the snap, and does the rest of that item cancel (Grease you already answered: yes cancel the 2nd slide)?
4. Does Block stop the trap’s 4 Attack (Harpy-style), then the trap is still Defeated?
5. Is “I am Defeated” a full Defeat (loot, Mimic, Clockwork, Commander/Lich exceptions) or does the trap just leave?
6. Quiet Bell: off for place, off for snap, off for both, or no effect?
7. Hover text for the `|Bear Trap|` keyword on Trapper’s Ability?

**Self-audit:** restated as what the player does · named Harpy, Jar O' Grease, Shuriken, Phoenix Egg, Commander, Lich, Mimic, Clockwork · both readings · questions would change the code · not implementing this turn
