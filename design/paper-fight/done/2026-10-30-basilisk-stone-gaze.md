# Paper Fight — Basilisk / Stone Gaze

**Pitch (Nathan’s words):** 5 HP 5 ATK. Call name Stone Gaze. Ability: Every time you Spin, I Petrify the next two items in your inventory. While in the dungeon, every time the player spins, Basilisk looks at the hotbar and selects 2 positions from left to right and petrifies them. First spin after spawning: positions 1 and 2. Second spin: positions 3 and 4, regardless of what items sit there. If the walk reaches the end of the player’s available items (7 items, 4th spin), petrify item 7 then wrap and petrify item 1. Animate one after the other, slash portrait once for both, existing petrify beams (the lines).

**Restate (what the player does):** While Basilisk is alive in the dungeon, the player clicks Spin. After the wheel lands, Basilisk petrifies two occupied hotbar seats in a left-to-right walk that remembers where it left off. First Spin after Basilisk appears: seat 1, then seat 2. Next Spin: 3 then 4. If the walk hits the last occupied seat, the second petrify wraps to seat 1. The player does not click a target. The two petrifies play one after the other (beam, then beam). The slash portrait plays once for the pair. Basilisk is a 5 ATK / 5 HP fight if they stay and fight. Nothing on this card is used up.

**Where it happens in a round:** On Spin, while Basilisk is in the dungeon. Auto — not a click-then-pick like Throwing Knife. Closest live cards: **Beggar** (Always while in the dungeon) plus **Gargoyle / Hydra / old Basilisk** (Petrify with the beam). The walk is a pointer over occupied seats, not “every other item once.” Number of petrifies per Spin is always two when the hand has at least one item, wrapping if needed. Duration of Petrify is not in the pitch (old Basilisk used a grey 3; Gargoyle lasts until the next Spin).

---

**Which existing cards this touches:**

- **Old Basilisk (live today)** — First Spin on me: Petrify even seats for 3 Spins, then Flee. This rewrite drops “first time,” “every other,” “for 3 Spins,” and (unless you keep it) Flee.
- **Gargoyle** — Petrify highest Attack until the next Spin, then fight. Same keyword, different pick, different duration. Same-Spin order: old Basilisk gaze ran before Gargoyle. If Stone Gaze is every Spin, both can Petrify on one landing.
- **Hydra** — Petrify until next Spin and gain ATK. Same keyword overlap. Old flow: Basilisk countdown hits 0 before Gargoyle / Hydra on that Spin.
- **Beggar** — Always while in the dungeon; marks an item including petrified. Stone Gaze can stone the marked card, or stone a card then Beggar discards it on a later Spin.
- **Quiet Bell** — Old Basilisk: silenced first Spin still spent the gaze. New Always-gaze: skip that Spin, and does the pointer still walk?
- **Smoke Bomb / extra Spin / Flee Spin** — Each is a Spin. If gaze is “every Spin while I am in the dungeon,” Smoke Bomb walks the pointer without landing on Basilisk. Old Flee Spin after gaze would also walk it.
- **Keep / Lantern / spent packing** — Using a card packs the hotbar left. The walk is positions, not item identity, so the next Spin’s “3 and 4” are whoever sits there now.
- **Draw / Catapult / Sling** — Hand grows at the end; wrap length changes mid-dungeon.
- **Recycler / Echo Bell / listening Potion / Half Flask** — Petrified cards cannot be clicked; listeners still listen today. Refresh vs skip on already-stone changes whether they stay unusable.
- **Curses / tokens / Smoke Bomb in seat 1** — Occupied seats count. Seat 1 is often Smoke Bomb in Adventure.
- **Hornet / Queen / extra swings** — No extra collision beyond “you cannot click a petrified Attack.” Skip unless duration leaves half the bar stone into the fight.
- **Wraith / Commander / Lich / Dragon pierce / Goblin / Slime / Mimic / empty alcove** — Gaze does not copy ATK or change the swing. They only matter if you land on Basilisk and stay to fight 5/5 with two cards stone.
- **Commander cancelled Flee / Chain** — Old Basilisk Fled after gaze. If Flee is gone, Chain’s “Basilisk still Petrifies, then stays if this is not petrified” needs the new stay-and-fight reading.
- **Two Basilisks** — Two Always walkers, or one shared pointer.
- **Empty hand / one item** — Wrap can pick the same seat twice in one Spin.
- **Tutorial kit** — Unlikely to see Basilisk (pool 5 / bucket 7). Developer Test can still land it with a short bar.

**Generous reading (best for the player):** Gaze only when you land on this Basilisk. Petrify lasts until the next Spin (Gargoyle). Already-stone seats still take the walk but you get those cards back next Spin. Basilisk still Flees after the gaze, so you rarely fight 5/5 against a locked bar. Quiet Bell skips the gaze. One item in hand is petrified once. Two Basilisks share one walk.

**Stingy reading (smallest sentence that still matches):** Every Spin while Basilisk is alive on the wheel, including Smoke Bomb and landings on other owners. Petrify lasts until Basilisk is Defeated. Already-stone seats still count (refresh). No Flee: land on it and fight 5/5 with two more cards stone. Wrap can stone the same item twice in one Spin. Each Basilisk has its own pointer (4 cards per Spin). Quiet Bell skips the beams but the pointer still advances.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Ability says “every time you Spin” and the how-it-works says “while in the dungeon,” but the old card only fired when you landed on Basilisk. Shipping the old trigger would make the Ability a lie.
- Duration omitted: if it is “until Basilisk dies,” a long dungeon stones the whole bar; if it is “until next Spin,” only two cards are ever stone at once (a sliding window).
- Wrap with 1 item: two petrifies on the same uid in one animation — crash or a double pip if duration stacks.
- Pointer stored as a hotbar index after a spend: seats pack left, so the next pair can skip or double-hit the wrong cards.
- Two Basilisks both walking and both playing one slash — overlapping beams, or `_apply_basilisk_gaze` returning Flee and skipping the fight.
- Quiet Bell: gaze_done-style “first time spent” would disable Stone Gaze for the rest of the dungeon.
- Gargoyle / Hydra same Spin: `_clear_petrify` then `_tick_gaze_petrify` at the start of the next Spin can shatter Basilisk’s stones before Hydra’s, or tick a duration that this rewrite no longer uses.
- Slash portrait once vs two beams: if the announce waits on the first beam only, the second petrify is easy to miss.

**What the player sees:** After Spin, two beams left to right, one Basilisk slash, two hotbar cards go stone. Next Spin, the next two seats go stone. If duration is a sliding window, the previous two crack as the new two lock. If duration is until Basilisk dies, the stone pile grows. If they land on Basilisk and it stays, they fight 5 ATK / 5 HP with those cards unusable.

**If we skip this:** Live Basilisk already Petrifies half the bar once, for 3 Spins, then Flees. You keep that trap, not a walking Always tax.

**If we take the strongest reading:** Every Spin in the dungeon stones two more cards until Basilisk is dead, no Flee, 5/5 when you land. The hotbar can be fully unusable before you ever take the fight. That is a dungeon-long lock, not a one-landing trick.

**Questions for Nathan:**
1. How long does each Petrify last?
2. Which Spins fire Stone Gaze?
3. When you land on Basilisk, after the gaze: stay and fight, or Flee?
4. If the walk lands on a seat that is already Petrified: refresh that seat, or skip to the next unpetrified item?
5. Quiet Bell on: skip the gaze and freeze the pointer, or skip the gaze and still walk the pointer?
6. Two living Basilisks: one shared walk (2 items / Spin) or each has its own walk (up to 4 / Spin)?
7. One item in the hand, wrap would hit it twice in one Spin: Petrify once, or twice?

**Self-audit:** restated as what the player does · named Gargoyle / Hydra / Beggar / old Basilisk / Quiet Bell / Smoke Bomb · both readings · questions would change the code · not implementing this turn

## Answers (2026-10-30)

1. Duration: until the next Spin (Gargoyle sliding window).
2. Which Spins: every Spin while this Basilisk is alive on the wheel.
3. Land on Basilisk: stay and fight, no Flee.
4. Already Petrified: skip, take the next unpetrified item.
5. Quiet Bell: no gaze, pointer does not move.
6. Two Basilisks: each has its own walk.
7. One item wrap: Petrify once.
