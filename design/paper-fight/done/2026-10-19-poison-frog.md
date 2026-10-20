# Paper Fight — Poison Frog

**Pitch (Nathan’s words):** Poison Frog. Call name Toxic Skin. When you Spin me and when I take Atk damage from any source, you Gain 2 Poison. Yes, includes damage from other sources like Hired Hand, crossbow, prism, pocketwatch. Yes, this means that if the player has 6 poison when they next spin, they're essentially guaranteed dead unless they have healing potion.

**Restate (what the player does):** You Spin Poison Frog. You immediately Gain 2 Poison (the same player-poison Ale Flagon gives you). Then you fight. Every time this frog actually takes Attack damage — Boot, Crossbow into its seat, Prism bouncing a hit onto it, Pocketwatch making another owner hit it, Hired Hand bribing a neighbor into it — you Gain 2 Poison again. You do not click the frog. Poison sits on you. The next time you Spin anyone, that poison number hits your HP and clears. At 6 poison and 6 HP, that Spin kills you unless Healing Potion saves you.

**Where it happens in a round:** Automatic. On Spin of this slice, before the fight. Then again whenever Attack damage lands on this slice, from any Attack path. The +2 is added each time; it is not a copy of someone else’s number. The frog is not used up.

**Which existing cards this touches:**
- **Player poison (Ale Flagon)** — same counter. Frog +2 stacks with Flagon’s +3. On the next Spin, `_tick_player_poison` deals that total as HP loss and clears it. Healing Potion can save a 0 HP death.
- **Hired Hand** — bribe makes Hand Attack a neighbor through `_deal_atk_at`. If that neighbor is Frog, Toxic Skin pays.
- **Crossbow** — neighbor Attack. If the bolt’s seat is Frog, pays.
- **Prism** — Attack at Prism hits both neighbors instead. A Frog neighbor takes that Attack. Pays.
- **Pocketwatch** — hypnotize makes another owner Attack the one you spun, through `_deal_atk_at`. If the target is Frog, pays. If you hypnotize Frog into hitting someone else, Frog did not take damage; no pay from that.
- **Hornet / Queen / Kobold extra swings** — those extra swings hit you, not Frog. No extra poison unless something actually hits Frog twice (Hollow even-twice, Pocketwatch two hits, two Crossbows).
- **Commander / Dragon / Goblin / Mimic / Slime / Anvil / Bodyguard** — Commander is only the number. Dragon pierce still deals Attack to Frog. Goblin immunity is not on Frog. Anvil is not Frog. Bodyguard: if Bodyguard eats the hit, Frog did not take it, no pay. If Frog is the Bodyguard, it did take it, pay.
- **Full Block / 0 damage** — `_deal_atk_at` with 0 after Block / immune plays a clink and does not lower HP. Is that “take Atk damage” or not?
- **Quiet Bell** — skips On Spin gifts. Does it also skip the on-hit +2 while you fight a silenced Frog?
- **Two Frogs** — Spin one: +2. A Crossbow that hits the other Frog: another +2. Each Frog pays for its own Spin and its own hits.
- **Grappling Hook / Damsel** — not a Spin onto Frog. No Spin +2. Hitting Frog still pays.
- **Plague Doctor** — puts Poison on monsters, not on you. No collision except you can have both.
- **Empty alcove / tutorial** — Frog is not in the tutorial kit.
- **Poison Flask / Miasma** — monster poison, not player poison.

**Generous reading (easier on you):** +2 only when Frog’s HP actually drops. Quiet Bell turns off Spin and on-hit. Two hits that each deal 0 do nothing.

**Stingy reading (deadlier frog):** Any Attack that targets Frog pays +2 even at 0 damage. Quiet Bell skips only the Spin +2; hitting it still poisons you. Hollow / Pocketwatch two hits = +4. Spin + Boot + Boot on a 3 HP frog is +2+2+2 = 6, so the next Spin kills you unless Potion.

**Ways it can fail:**
- Hooking the combat log instead of `_deal_atk_at` misses Prism / Pocketwatch / Hired Hand.
- Hooking `_deal_atk_at` before redirect means attacking Prism pays on Prism (wrong) and maybe not on the Frog neighbor.
- Counting the Spin +2 and the first Boot as one event.
- Ticking player poison at the start of Spin before Frog’s On Spin +2 — already true today. You die from poison you already had, then Frog would have added more if you lived.
- Silenced Frog still paying on-hit when the Ability reads as the frog’s skin.

**What the player sees:** Spin Frog, poison badge goes up by 2. Each time Frog’s HP drops to Attack, +2 more. Next Spin, that number hits your hearts.

**If we skip this:** Ale Flagon is the only player-poison card. Nothing on the wheel punishes you for punching it.

**If we take the strongest reading:** Spin, then two Attacks, is 6 poison. Next Spin you die unless Potion. Crossbow / Prism / Hired Hand can stack that without ever spinning Frog again.

**Questions for Nathan:**
1. HP / ATK? The paste had no 4/4 line.
2. If an Attack hits Frog for 0 (full Block, or the clink): still Gain 2, or only when HP drops?
3. Two hits in one action (Hollow even-twice, Pocketwatch two swings): +2 once, or +2 per hit?
4. Quiet Bell: skip the Spin +2 only, or also skip on-hit while silenced?

**Self-audit:** restated as what the player does · named Ale Flagon / Hired Hand / Crossbow / Prism / Pocketwatch / poison tick · both readings · questions would change the code · not implementing this turn

## Answers

1. **4 HP / 2 ATK.**
2. **Any Attack that targets it, even for 0.**
3. **+2 per hit.**
4. **Quiet Bell before Spin:** 4 HP / 2 ATK golem, nothing happens. **Quiet Bell after Spin:** you already got the Spin +2; further hits do not poison.

Implemented 2026-10-19. Bucket 8, Tier 2. Art missing.
