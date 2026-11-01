# Paper Fight — Basilisk / Stone Gaze (enter Gaze 3)

**Pitch (Nathan’s words):** 6 HP 5 ATK. Call name Stone Gaze. Ability: When I enter the Dungeon, I Gaze at 3 of your Items. As soon as you Use 1, the other 2 are Petrified until I am Defeated. On enter, a Gaze marker/aura with the Basilisk icon on the three items. Hovering one of those three makes the other two glow a warning that they will Petrify. Petrified pair: same hatch/grey, plus Basilisk sprite, plus tooltip “Petrified while the Basilisk remains.” Freed on standard Defeat / slain / escaped, and Polymorph. Not freed on Eject (Catapult).

**Restate (what the player does):** Basilisk arrives on the wheel (dungeon start or later). It marks three items in the hand. Those three stay clickable. The first time the player Uses one of those three, that card plays as normal, and the other two become unclickable stone until Basilisk is Defeated (or Polymorphed). The player does not pick the stone pair. Catapult does not free them. Hovering one marked card warns on the other two before the click.

**Where it happens in a round:** On enter (Always, like Beggar’s mark / Rust Bucket), not on Spin. Gaze is a mark, copied once onto those three cards. Petrify is auto after the first Use of a marked card. Closest live cards: **Beggar** (marks an item while in the dungeon) plus **Gargoyle** (Petrify overlay) with a new duration (until this Basilisk is Defeated, not until next Spin). This replaces the live “every Spin, next two seats” Stone Gaze.

---

**Which existing cards this touches:**

- **Live Stone Gaze (every Spin walk)** — this rewrite removes that.
- **Gargoyle / Hydra** — their Petrify clears on the next Spin. Basilisk stone does not.
- **Catapult** — does not free. Gaze id rides the ejected dict; no second Gaze on redraw.
- **Polymorph** — frees the facing Basilisk’s marks.
- **Flee** — keep stone (answered).
- **Oligarch** — Use counts (answered).
- **Echo Bell** — only if Echo Bell itself is Gazed (answered).
- **Quiet Bell** — skip Gaze on enter, still grant so no retry.
- **Two Basilisks** — each Gaze 3, prefer unmarked; Using any Gazed petrifies all other Gazed.
- **Bag of Holding** — not a free; stone stays.

**Answers (2026-10-30):**
1. Random any 3 (Keep, Smoke, curses, tokens).
2. Short hand: Gaze all.
3. Gaze: when one Item with Gaze is used, all others are Petrified until the Basilisk is Defeated.
4. After Catapult: free when that Basilisk is later Defeated or Polymorphed off the Dungeon Deck.
5. Flee: keep stone.
6. Oligarch yes. Echo only if Echo Bell itself is Gazed.
7. Each own 3; Use of any Gazed petrifies ALL other Gazed (up to 5 stone). Prefer unmarked so two can mark 6 unique.

**Tabled while coding:** Polymorph *into* a Basilisk does not Gaze (only mill/dev enter). Bag of Holding does not free. Sling/Marble Gaze stays on that uid.

**Self-audit:** implemented after answers · no second question round
