# Paper Fight — full-hand throw-away: no curses, hover on the hotbar

**Pitch (Nathan’s words):** Whenever the tier zero token items (curses like Spider Egg, Toll, Rust) are in the inventory and the player gains their eleventh item (one more than capacity) and would be prompted to discard an item: (1) tier zero / curse items must not be eligible to select to discard — that would be far too strong; (2) no little pop-up additional buttons — instead a small glowing selector over the hotbar cards when the mouse moves over them, so it is obvious that clicking will discard that card; (3) this discard does not count as a discard for Item Recycler; (4) a text pop-up that says discard is okay.

**Answers (2026-10-28):**
1. Classify the bad items as Curses (still Tier 0). Implemented as `curse: true` on Spider Egg, Toll, Rust. Marble, Blood Pact, and Fairy are not Curses.
2. If every card in hand is a Curse, the incoming card is lost (Can't Gain). Keep the curses. The wait ends.
3. Same lock + hover on every click-an-item-to-throw-away: full-hand replace, Bell/Rust spawn, Bell Defeat, Cube, Worm, Hired Hand. Merchant upgrade is not a throw-away; Curses can still be upgraded.
4. Yes — override Recycler's locked Flow. A full-hand replace does not tick Recycler. Bell, Cube, Worm, bribe still do.

**Clustered while coding (did not stop):**
- Bell Defeat with only Curses: skip the tax (same as empty hand), Bell still rings.
- Cube with only Curses: cube ate nothing; the fight continues.
- Incoming Toll/Rust into a hand of only Curses: Can't Gain, the token does not sit down.
- Recycle skip is only the Adventure full-hand replace (`_challenge_discard_one`). Overlay tosses still tick Recycler.
