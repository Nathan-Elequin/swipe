# Paper Fight — Toll hits 0: balloon, hotbar countdown, set HP to 0

**Pitch (Nathan’s words):** Whenever Toll triggers there should be a much louder animation and a speech-bubble dialogue over Death Bell’s character model that says “The bell toll...” At that point a large animation shows the counter on the hotbar Toll counting from one down to zero, then a purple emanating explosion aura, after which it should immediately show the player dropping to zero HP and killing them. Toll’s real effect of “die” does not simply mean the lose screen. It means set my HP to zero. The one save is Healing Potion.

**Restate (what the player does):** The player does not click Toll. Toll is an unplayable token. After an item use that ticks Beads, Toll’s number drops. When that number would go from 1 to 0, Death Bell speaks (“The bell toll...”), the hotbar Toll counts 1 → 0 in a big way, a purple explosion aura plays, then the player’s HP becomes 0. Hearts go empty. If Healing Potion is in hand, it discards and Heals 3. If it is not, the player is dead and the lose sequence runs. Toll is then gone.

**Answers (2026-10-29):**
1. Balloon over a Death Bell still on the wheel, even if you are not looking at them. If no Bell is left, skip the balloon and still do the hotbar 1→0 + purple burst.
2. Healing Potion only. Not a normal HP-loss event. Pacemaker / Ogres / Vampires do not fire. (Pacemaker also would not save anyway unless it healed after a true exact-2 loss; Toll slams to 0, so it never is “exactly 2” as a save.)
3. Hearts empty and the death pose play, then Potion discards and Heals 3 and you stay in the fight. No lose screen / defeat music.

**Shipped:** `_play_toll_zero_sequence` + HP set to 0 + death pose + Potion save or `_player_down(true)`.
