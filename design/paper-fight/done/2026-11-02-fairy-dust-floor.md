# Paper Fight — Fairy Dust (1 HP floor)

**Pitch (Nathan’s words):** Rework Fairy to 1/1. Ability Fairy Dust: My Neighbors Always have at least 1 HP. If a neighbor has 4 HP and loses 4 HP (poison or damage), they stay at 1 and are not slain. Defeat items still work. Eject and other utility still work. Louder telegraph: when an item would kill a Fairy neighbor, glow the Fairy line and show they will not die.

**Restate (what the player does):** Fairy sits on the wheel at 1 HP / 1 Attack. While she is alive, her two living neighbors cannot be dropped to 0 by Attack or Poison. The number still goes down; it stops at 1. Defeat items, Eject, and similar utility still remove or rewrite them. Hovering or aiming an Attack or Poison that would have taken that neighbor to 0 lights Fairy’s neighbor line and shows they will stay at 1.

**Where it happens in a round:** Passive while Fairy is alive. Not used up. No extra click. The floor is live until she dies or Quiet Bell silences her.

**Which existing cards this touches:**
- Quiet Bell — Nathan: silences Fairy Dust; neighbors can die again.
- Petty King / Commander first lethal / Phoenix rebirth — Nathan: damage and Poison never count as dying, so those replacements stay off until a Defeat item.
- Defeat items (Boot, Scythe, Hex, Fangs, Sledgehammer, bag_hold) — still kill / chip as Defeat.
- Eject / Catapult, Polymorph — still work.
- Poison Flask / Outbreak / Plague Doctor — HP loss floors at 1; that is not a Defeat.
- Goblin — still immune to Attack; Poison can still tick, then floor.
- Lich Undying — Defeat chips 1 and can kill; other HP loss already blocked.
- Martyr — any HP loss still fires Noble Death (their own Defeat), even if the chip was floored at 1.
- Hydra Devour — surviving at 1 after a drop to 3 or less is still a Defeat from Hydra.
- Shambling Mound — self-chip floors at 1; swing count is starting HP so the loop ends.
- Anvil — still loses at least 3, then floor at 1.
- Hornet / extra swings — each swing is HP loss; floor after the swing that would have killed.
- Dragon pierce / Wraith / Commander ATK — numbers only; floor is on HP remaining.
- Tutorial kit — Goblin / Boot / Net unchanged; Fairy is not Pool 1.
- Empty alcove — no neighbor, no floor.

**Generous reading:** The floor also blocks Defeat, silence, and death replacements.

**Stingy reading:** Only Attack and Poison HP loss floors at 1. Quiet Bell turns it off. Defeat / Eject / utility still work. Death replacements do not fire from floored hits.

**Ways it can fail:**
- Shambling Mound looping forever if swing count is live HP instead of starting HP.
- Preview still drawing a kill X on a floored neighbor.
- Killing Fairy still previewing −1 HP on neighbors (old +1 aura).
- Floor applied to Fairy herself, or to Lich Defeat chips.

**What the player sees:** Neighbor HP counts down and stops at 1. On a would-kill Attack or Poison hover/aim, Fairy’s dust line pulses and the plate shows 1, not a kill X.

**If we skip this:** Fairy stays as +1 max HP, which playtest #232 already said was hard to see and is not this rule.

**If we take the strongest reading:** Neighbors cannot be Defeated at all while Fairy lives, which would brick Boot/Scythe and ignore Nathan’s Defeat/Eject line.

**Questions for Nathan:** answered 2026-11-02 — Quiet Bell turns it off; floor-first vs Flee/rebirth; telegraph on lethal hover/aim.

**Self-audit:** restated as what the player does · named live collisions · both readings · questions would change the code · implementing after answers
