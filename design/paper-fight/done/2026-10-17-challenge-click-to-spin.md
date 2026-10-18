# Paper Fight — Challenge click-to-spin

**Pitch (Nathan’s words):** When you click on a monster, I no longer want players to have to confirm it before they spin. Spin pops up as capsule reminder text, not a button. Undo can go all the way back to before the spin. Challenge Mode only (tutorial depicts Challenge). Undo until the first fight action, then normal fight Undo.

**Restate (what the player does):** In Challenge ready, they click a live monster slice on the wheel. That click is the spin. There is no second Spin click. A capsule line reminds them this is the click-the-wheel step. If they have not yet clicked an item, taken the hit, or spent a card, Undo puts the board back to ready with no fight started. After that first fight action, Undo is the existing fight Undo.

**Where it happens in a round:** Challenge (and the tutorial’s Challenge beats) · phase ready · the click is the spin · magnet High/Low ATK still needs its extra choice click first.

**Which existing cards this touches:**
- Queen eggs / Juggernaut / Leech that fire on spin
- Magnet High/Low ATK (`pending_choice`) — still an extra click, then the slice click
- Tutorial forced landings (Wizard / Golem / Goblin)
- Empty slices — click does nothing
- Adventure Mode (Gatehouse) still uses a real Spin button

**Generous reading:** Clicking any live monster slice immediately spins that fight; Undo always available after spin even mid-fight.

**Stingy reading:** Only a filled live slice spins; Undo only if nothing else has been clicked yet.

**Nathan’s pick:** Generous on the click. Stingy on Undo: until the first fight action, then normal fight Undo.

**Ways it can fail (crash, stuck game, card text that does not match the hit):**
- Accidental click with no Undo
- Tutorial still waiting for a Spin button that is no longer a button
- `_undo_wall()` at spin start wiping the pre-spin snapshot
- Magnet choice skipped if slice click fires spin first

**What the player sees:** Ready. Capsule reminder, not a Spin plank. Click a slice, the wheel turns, fight starts. Undo is lit until they take a fight action.

**If we skip this:** Challenge still needs click-then-Spin, which is the accidental-click problem he named.

**If we take the strongest reading:** Undo mid-fight would un-spin after items already spent. He said no.

**Questions for Nathan:**
1. Override locked copy — yes.
2. Undo window — until first fight action.

**Self-audit:** restated as what the player does · named a live collision · both readings · questions would change the code · answers in · implemented 2026-10-17
