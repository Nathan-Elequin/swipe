# Paper Fight — Adventure Mode Moves (executed from Nathan's brief)

**Pitch (Nathan’s words):** One mode, Adventure Mode (The Gatehouse): a single 6-seat dungeon with forced random spins, Challenge-style loot drafting, a visible next-monster deck, and 3 Moves per dungeon that let the hero walk left/right around the wheel. Moving is not a Spin. Reuse Grappling Hook’s leave/arrive treatment.

**Restate (what the player does):** Start The Gatehouse. Pick loot for each seated monster. The wheel spins on its own. After on-spin effects finish, spend a Move to walk one occupied seat left or right. Press Done against whoever you are facing.

**Where it happens in a round:** After the spin lands and on-spin effects finish, until Done. Items then Move is allowed. Moves are used up (no undo). Walking does not use an item.

**Which existing cards this touches:** Grappling Hook (leave/arrive + spin_locked). Anything that fires on Spin, reads “facing”, or stores damage on a left-behind monster. Listed in the chat, not guessed here.

**Generous reading:** Walk changes facing_index. Left monster keeps HP and marks. Arrive does not run on-spin. Same fight counters stay.

**Stingy reading:** Same, because the brief named Grappling Hook and forbade on-spin.

**Questions for Nathan:** None. The brief settled the collisions that would change the code.

**Self-audit:** Built from the brief in the same chat. Unclear cards listed, not patched.
