# Paper Fight — Quick Start skips Challenge draft

Locked from Nathan’s answers 2026-10-16 (browser polish plan). Implemented.

**Pitch (Nathan’s words):** Improve all title buttons (Challenge Mode, Quick Start) so they have higher contrast. Quick Start should now set up a dungeon in Challenge Mode (instead of Adventure Mode) with six monsters and six respective items, as if the player had completed the draft section of setup.

**Restate (what the player does):** On the title (or pause Start over), they click Quick Start. They do not pick loot. They do not walk the door. They land on a Challenge wheel with six living owners, six items already in the hand (one per seated owner), and Spin available. Challenge Mode is unchanged: they still seat six, pick-two six times, then click Begin.

**Where it happens in a round:** Title / pause. No card is used up. No target click. The six items are the opening Challenge drafts, auto-resolved, then the extra Begin is skipped.

**Which existing cards this touches:**
- **Smoke Bomb / Danger Magnet / Clockwork Knight** — still banned from Challenge pools. Quick Start must not give them.
- **Hornet Swarm / Goblin / Dire Wolf** — can sit on the opening six the same as Challenge Mode; Quick Start does not change their fight rules.
- **Queen / Wraith / Commander / Lich / Dragon pierce / Mimic / Slime** — same as a normal Challenge opening. They only matter after Spin.
- **Empty alcove** — opening seats six owners; no empty seats at ready.
- **Tutorial kit** — How to Play is a different button. Nib’s closer still says eight monsters (locked copy, not overwritten).
- **Developer Test** — unchanged.

**Generous reading:** For each seated owner, draw the same pick-two Challenge would, keep one at random, leave the other out of the unseen pool until reshuffle (a real reject). Skip the pick UI and skip Begin. Ready to Spin.

**Stingy reading:** Skip the pair. Take one matching-tier item from the pool per seat, no reject-half.

**Locked reading:** Generous. Nathan confirmed six owners + six respective items as if draft completed.

**Ways it can fail:**
- Still using the old 8-seat mill and starter kit (Smoke Bomb via `_ensure_starter_smoke`).
- Bucket-unlock cinema blocks the skip.
- Hand stays empty because auto-pick never commits.
- Rejected half is put back immediately, so later kill-loot repeats the same pair.
- Lands in `draft` waiting for Begin instead of `ready`.
- `adventure` stays false, so Continue / deck / 10-card hand never apply.

**What the player sees:** Title overlay gone. Six slices filled. Six item cards. Deck count on the right. Spin is the next click.

**If we skip this:** Quick Start still dumps eight mill owners and four starters. Friends on itch skip into the old short dungeon.

**If we take the strongest reading:** Auto-keep both cards of every pair (twelve items). That is not “completed the draft.”

**Questions for Nathan:**
1. Answered: Challenge Mode, six and six, skip draft.
2. Answered: keep one of each pick-two at random; rejected half stays out until reshuffle.

**Self-audit:** restated as what the player clicks · named Smoke Bomb / Hornet / tutorial · both readings · questions already answered on the plan · implemented after confirm.
