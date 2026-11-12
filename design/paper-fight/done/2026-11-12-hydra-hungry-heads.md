# Paper Fight — Hydra Hungry Heads rework

**Pitch (Nathan’s words):** Rework for Hydra - HP 7, Attack 3: 'Hungry Heads' - On Spin, I Attack one of my Neighbors. If I Defeat them, I gain an extra Attack. Also nerf Tyrant’s base attack down to 3 from 4.

**Restate (what the player does):** Every time the wheel lands (any Spin, while Hydra is still alive), Hydra picks one living Neighbor at random and hits them with Hydra’s Attack (3). The player does not click a target. If that bite Defeats that Neighbor, Hydra gains one extra Take swing at the player. That extra swing is already in force if you are facing Hydra this same landing. HP stays 7. Printed Attack stays 3. Tyrant’s printed Attack is 3.

**Where it happens in a round:** On Spin, after landing, while Hydra lives unsilenced on the wheel. Hydra is not used up. No extra click. Extra Attack means extra Take swings (`hydra_heads`), not a bigger printed Attack number. The number of swings keeps growing for the rest of this combat.

**Which existing cards this touches:**
- **Hornet Swarm / Queen** — extra swings on Take. Hydra’s neighbor bite is one Attack at 3, not those extra Take swings. Gained heads only add Take swings at you.
- **Wraith / Commander / Lich** — Hydra’s plate stays 3. Commander +2 on a Neighbor can make that Neighbor harder to eat. Lich does not take the 3. Commander Flee after a killing bite still counts as Defeat for the extra swing.
- **Dragon pierce** — does not apply; this is monster-on-monster Attack, not your Take.
- **Goblin** — still gets bitten; 0 Attack damage; no Defeat; no extra swing.
- **Bodyguard** — the chosen Neighbor’s hit can pass to Bodyguard. Extra swing only if the chosen Neighbor is Defeated, not if Bodyguard dies instead.
- **Prism** — Attack at Prism hits Prism’s Neighbors instead. Prism is not Defeated by that, so no extra swing.
- **Slime** — ATK = HP on the victim; Hydra still deals 3 to Slime’s HP.
- **Mimic** — a Hydra bite can Defeat Mimic before Mimic swings; gift still applies if Mimic never swung.
- **Phoenix / Triclops / Commander Flee** — leaving the seat or becoming an Egg after the bite counts as Defeat for the extra swing.
- **Empty alcove / last monster** — no living Neighbor: no bite this Spin.
- **Glass Asp / Plague Doctor / other On Spin** — Hydra bites every Spin like Glass Asp, after facing Poison, before facing-only land effects.
- **Quiet Bell** — silenced Hydra does not bite. Swings already gained stay.
- **Tutorial kit** — Hydra is not in the tutorial.
- **Tyrant (cowardly_king)** — printed Attack 4 → 3 only. Mockery unchanged.
- **Old Hungry Heads (Neighbor ≤3 survive → auto Defeat)** — this rework replaces that. No more 3-HP devour.

**Generous reading:** Every Spin, random Neighbor including the one you just landed on, extra Take swing immediately (this landing), Goblin still gets the wasted bite, old ≤3 devour gone.

**Stingy reading:** Only when you land on Hydra, clockwise Neighbor, extra swing starts next Spin, skip Goblin, cannot eat the facing seat.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Two Hydras eat each other and the facing seat dies mid-Spin without closing combat.
- Extra Take swings apply to the Neighbor bite and wipe the wheel in one Spin.
- Old ≤3 devour still fires after a non-killing hit and double-pays a head.
- Inspect still says the ≤3 sentence.
- Goblin bite grants a head anyway.

**What the player sees:** On every Spin, a Hungry Heads line from Hydra to one Neighbor, one Attack of 3, and if that seat dies a ×N pop on Hydra. Facing Hydra then Takes that many times at 3 each.

**If we skip this:** Live Hydra still auto-Defeats a Neighbor who survives at 3 HP or less, once per combat.

**If we take the strongest reading:** Hydra farms a head every Spin, can eat the monster you just landed on, and can Take many times at 3. The wheel can empty from the side.

**Questions for Nathan:**
1. Every Spin while Hydra lives, or only when you Spin Hydra? → **Every Spin while alive.**
2. Which Neighbor if two? → **Random.**
3. Extra Attack = printed +1, extra Take swing, or another bite? → **Extra Take swing.**
4. When do extra swings count? → **This same Spin, including Hydra’s Take at you.**
5. Goblin / immune target? → **Still bite; 0 damage; no extra swing.**
6. Can the bite kill the monster you just landed on? → **Yes.**

**Self-audit:** restated as what the player does · named Goblin/Bodyguard/Prism/Glass Asp/Hornet · both readings · questions would change the code · answers in; implementing this turn
