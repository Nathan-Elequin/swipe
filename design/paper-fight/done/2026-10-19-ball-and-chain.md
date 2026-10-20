# Paper Fight — Ball & Chain

**Pitch (Nathan’s words):** Ball & Chain. 2 Atk. The next time you or an Enemy would Flee, cancel it and this gains +2 Atk. When it activates, a large flashing capsule says Can't Flee with the name/icon of Ball & Chain, then the weapon shows +2 Atk. Yes, it interrupts Fleeing. Example: Basilisk tries to Flee when Spun; if Ball & Chain is not petrified, this procs, and you stay fighting Basilisk with petrified items still on 3 spins. This can proc as many times as it happens. The attack is used once and is discarded.

**Restate (what the player does):** The card sits in the hotbar at Attack 2. You can click it during a fight to deal its current Attack to the owner you spun, then it is discarded. Until you click it, whenever you or an enemy would Flee, that Flee does not happen, a Can't Flee banner shows this card, and its Attack goes up by 2. That can happen again on a later Flee. If this card is petrified, it does not interrupt.

**Where it happens in a round:** Attack click is during a fight, current enemy, used up. The interrupt is not a click — it happens by itself at Spin / Defeat / after Shuriken, whenever code would call a Flee. The Attack number is stored on this copy and keeps going up until you spend it. It is not a one-time “next time” despite that word in the Ability; the how-it-works bullets say every Flee.

**Which existing cards this touches:**
- **Basilisk** — first Spin: Petrify even-numbered items for 3, then Flee. Nathan: Petrify still happens, Flee is cancelled, you stay in the fight with those items on 3. If Ball & Chain itself is petrified (even slot), it does not proc.
- **Shuriken** — 2 Attack, if they live you Flee and Keep Shuriken. Cancel your Flee: you stay facing them, Shuriken still Keeps, Ball & Chain +2.
- **Commander** — first Defeat: heal to full and Flee (random Spin) instead of dying. Cancel Flee: they stay, not Defeated, at the HP they had before that Attack (not full HP).
- **Phoenix Egg / Phoenix** — Defeat: Flee and become the other form. Cancel Flee: still transform in this seat.
- **Triclops** — Defeat when not at 3 HP: lose 2 HP and Flee instead of dying. Cancel Flee: they take −2 and stay.
- **Mouse** — On Spin, if your HP is higher they lose 2 HP and Flee. Cancel Flee: they stay after the −2 (and can die from it).
- **Cowardly King** — on HP loss, Attack you then Flee (random Spin). Cancel Flee: they stay after hitting you.
- **Hired Hand** — after the bribe, Attack a Neighbor and Flee. Cancel Flee: they stay.
- **Quiet Bell** — silenced owners do not Flee. No proc.
- **Bag of Holding** — not a Flee.
- **Goblin** — ignores Attack when you finally click Ball & Chain. Interrupts are not Attack.
- **Hornet / Queen** — extra swings still happen if you stay in the fight (Basilisk case).
- **Hex / Smoke / Magnet** — those Spins are not Flees. No proc unless something Flees as a result.
- **Petrify / Bushido dummy** — a petrified Ball & Chain does not interrupt.
- **Two copies** — both gain +2. The Flee is cancelled once.
- **Empty alcove / tutorial** — no Flee, nothing happens. Not in the tutorial kit.

**Generous reading:** Every Flee spin is cancelled. The rest of the sentence still happens (Petrify, hatch in the same seat, Commander lives at full HP, Triclops −2 and lives). Every Ball & Chain in hand gains +2. You can dump it as a 2 Attack whenever you want.

**Stingy reading:** Only the random Spin is cancelled when Flee was extra (Basilisk, Shuriken, King, Hand, Mouse). When Flee was replacing death (Commander, Triclops, Phoenix), cancelling it means they actually die / no transform. Only one Ball & Chain procs per Flee.

**Ways it can fail:**
- Basilisk petrifies Ball & Chain (even slot) and it cannot save you — that is the example, not a bug.
- Phoenix hatch without Flee leaves you facing a new 6 ATK Phoenix with no Spin to think.
- Commander cancelled Flee with HP restored: you are stuck on a full-HP Commander who will not Flee again (fled_once).
- Two chains both fire, or the second sees no Flee and stays at 2.
- Ability says “the next time” but bullets say every time — inspect would lie if we coded once-only.
- Clicking it after several procs deals the live number; Shift must show 2 + 2 × Flees.
- Petrified overlay vs interrupt: grey 3 on the card but it still interrupts if we forget the petrify check.

**What the player sees:** The card shows 2, then 4, then 6 as Flees are stopped. A Can't Flee capsule with this card’s name and icon. Click once: that number hits, card gone.

**If we skip this:** Shuriken already Flees you. Commander / Basilisk / Phoenix already Flee. Nothing in the mill cancels Flee.

**If we take the strongest reading:** You can pin Basilisk, Commander, Phoenix, and King in the same dungeon, grow this to a huge Attack, then dump it. One hotbar slot answers every Flee on the roster.

**Questions for Nathan:**
1. When Flee was how they avoid dying (Commander, Triclops, Phoenix Egg / Phoenix): cancel only the Spin (they stay / transform in this seat), or the Defeat finishes (they die / no hatch)?
2. Two Ball & Chains in hand, one Flee: both gain +2, or only one?

**Self-audit:** restated as what the player does · named Basilisk/Shuriken/Commander/Phoenix/Triclops · both readings · questions would change the code · not implementing this turn

## Answers

1. **Cancel only the Spin.** They stay / transform in this seat. Commander does not go to full HP, is not Defeated, and stays at the HP they had before that Attack (2 HP taking 2 Attack stays at 2). Phoenix / Egg still change form here. Triclops still lose 2 HP and stay. Shuriken still Flees you unless a live Ball & Chain cancels that Flee too.
2. **Both copies gain +2.** The Flee is cancelled once.
3. **Commander leftover HP:** undo the killing damage.

Implemented 2026-10-19. Bucket 8, Tier 1, Attack. Art missing.
