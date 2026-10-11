# Paper Fight — 2026-10-10 Saves (Damsel, Berserker, Commander, Ogre, Spider Queen)

Five redesigns from this Save. Ability vs Flow vs Notes disagree on several of them. Not implementing this turn.

---

## 1. Damsel in Distress (still id `two_headed_serpent`)

**Pitch (Nathan’s words):** Rename Two-Headed Serpent to Damsel in Distress. 9 HP, 0 ATK, Deadly. When this unit would Attack, instead its Neighbors Attack the player, left (clockwise) then right. Each neighbor is treated as clicking Done against that owner, with no chance for the player to act in between. Block carries. Those neighbors are not Defeated. Then Damsel Heals the player 3 HP and is Defeated. New art / sound.

**Restate (what the player does):** You Spin onto Damsel. Damsel’s plate shows 0 Attack and 9 HP. You can still click items (Boot if your HP is above 9, Fangs, heals, Block). When you click Done, you do not take Damsel’s 0. The living owner on Damsel’s left swings at you as if you had clicked Done on them, then the living owner on the right does the same. You cannot click items between those two hits. After that, you Heal 3 (cap 6) and Damsel leaves. The neighbors stay on the wheel.

**Where it happens in a round:** Fight, facing Damsel. Used up by leaving the wheel (Defeat, not HP to 0). No extra target click. Neighbor Attack numbers are whatever is on their plates at that moment (live, not a copy from an earlier Spin).

**Which existing cards this touches:**
- **Hornet Swarm** — Done vs Hornet is two swings, Block spent on the first. If Hornet is a neighbor, is that the whole Done, or one number?
- **Spider Queen** — two swings only if a neighbor is weaker. Same question if Queen sits beside Damsel (and Queen may be changing to eggs this Save).
- **Dragon** — Done vs Dragon ignores Block. Does a Dragon neighbor ignore Block here too?
- **Goblin** — Goblin’s swing still hits you. Goblin as Damsel’s neighbor is a normal hit, not “cannot receive ATK.”
- **Mimic** — Done vs Mimic: do you still get the gift / skip the swing, or does Damsel force a hit?
- **Slime** — ATK = current HP at the moment that neighbor swings.
- **Wraith / Commander / Lich** — neighbor plate already includes those bonuses. Damsel uses the number on the plate.
- **Quiet Bell** — if Damsel is silenced, do neighbors still swing, or does Damsel become a 0 ATK empty Done?
- **Da Boot / Fangs / Sledgehammer** — Sledgehammer cannot (0 ATK). Boot if your HP > 9. Fangs takes 0, then Defeats Damsel, then Heals Damsel’s 9. If those work, neighbors never swing.
- **Breastplate / Cursed Scroll** — neighbor hits are Attack (Block works). Damsel’s Heal 3 is Heal. Cursed Scroll’s Spin loss already happened before this fight.
- **Harpy** — Harpy already hits after every item. Damsel’s sequence is a Done replacement, not an extra Harpy loop, unless a Harpy neighbor is the one swinging.
- **Empty alcove / last owner / only one neighbor** — one side has nobody. Skip that side, or Damsel cannot exist there?
- **Tutorial kit** — tutorial does not seat Damsel today. Developer Test can.

**Generous reading:** Clicking Done facing Damsel runs a full Done against each living neighbor (extra swings, Dragon ignore-Block, Mimic’s special), Block leftover carries, then Heal 3 even if you were at 0 after the hits (you can live), then Damsel leaves. Missing neighbor = skip that side. Boot/Fangs can still skip the whole sequence.

**Stingy reading:** Each neighbor deals one Attack number from their plate. No extra swings, no Dragon pierce. If a hit drops you to 0, you die and never get Heal 3. Empty neighbor = skip. If both neighbors are empty, you Heal 3 and Damsel leaves for free. Quiet Bell: Damsel is just 0 ATK, click Done, nothing else.

**Ways it can fail:**
- Treating neighbor swings as a new Spin (Block would reset; you said Block carries).
- Defeating the neighbors after they hit (you said they stay).
- Leaving Damsel on the wheel after Heal 3.
- Auto-running this on Spin with no Done, so the player never gets to click Boot/Fangs/Shield.
- Hornet neighbor hitting twice while the Shift equation on Damsel still says 0.
- Player dies to the left neighbor, game still tries to swing the right neighbor and Heal.

**What the player sees:** Damsel’s plate is 0 Attack, so Done looks free. The tell has to say the neighbors will hit. During the sequence, hotbar should look unusable.

**If we skip this:** Two-Headed Serpent (ATK 0 after two items) already exists. Damsel is a new kind of fight.

**If we take the strongest reading:** One Done against Damsel can be two full owner swings (Hornet + Dragon) with no items in between, then a Heal. That can kill you from a “0 Attack” plate, or let you farm Heal 3 off empty seats.

---

## 2. Berserker

**Pitch (Nathan’s words):** Redesign. Alternates between 3, 4, and 8 Attack on Spin. Unique sound and fiery look at 8, cool-down when leaving 8 back to 3.

**Restate (what the player does):** Berserker sits on the wheel. Each time you Spin, their Attack is the next number in 3 → 4 → 8 → 3. You fight the number on the plate. The card is not yours; it is not used up.

**Where it happens in a round:** On Spin, while Berserker is seated. Number keeps updating every Spin. No target click.

**Which existing cards this touches:**
- **Commander** — neighbor +2 Attack. On top of 3/4/8, or ignored?
- **Wraith** — copies the higher neighbor. Copies the 3/4/8 showing now, including Commander?
- **Quiet Bell** — printed Attack (3) while silenced?
- **Lich** — HP, not Attack. Berserker HP stays 4 unless you say otherwise.
- **Hornet / Queen / Dragon / Goblin** — no extra collision beyond “the number on the plate is the swing.”
- **Smoke Bomb** — new Spin, so Berserker steps even if you were not facing them.
- **Empty / last / tutorial** — no special target. Developer Test: first seat shows which number?

**Generous reading:** The 3/4/8 is the whole Attack; Commander does not add. Cycle only when you Spin onto Berserker.

**Stingy reading:** Cycle on every Spin in the dungeon while Berserker is alive (including Smoke and fights against someone else). Commander +2 still applies last (5/6/10). Quiet Bell freezes at printed 3.

**Ways it can fail:**
- Stepping twice in one Spin (once for the dungeon, once for landing on them).
- Animation at 8 that never plays if Commander already made it 10.
- Explainer still says “Attack and HP plus Defeat” (old card). Ability is the new sentence; I will not rewrite locked copy.

**What the player sees:** The plate number changes on Spin. At 8 it should look angry.

**If we skip this:** Old Berserker (Attack and HP plus each Defeat) is still in the live code.

**If we take the strongest reading:** Every Smoke steps them toward 8 while you fight someone else, then you land on 8.

---

## 3. Commander flee

**Pitch (Nathan’s words):** Still gives Neighbors +2 Attack. The first time Commander is Defeated, they flee and shuffle the dungeon. If that happens during another fight (Crossbow / Longbow), interrupt and skip straight to Spin. Callout / sprite must show whether the flee is already used. Review also says “whether Slain / blocked or anything.”

**Restate (what the player does):** Commander still buffs neighbors. The first time Commander would leave the wheel, they do not leave. The wheel is shuffled and a Spin starts. After that first time, a later Defeat/Slay removes them for real.

**Where it happens in a round:** When Commander would be removed. Not a player click on Commander. Crossbow/Longbow can cause this while you are facing someone else.

**Which existing cards this touches:**
- **Crossbow / Longbow / Throwing Knife** — can remove Commander from another fight. Interrupt or finish current fight first?
- **Da Boot / Sledgehammer / Fangs** — Defeat paths. First time: flee instead of leave?
- **Slay by HP 0** — same flee?
- **Clicking Done / Take** — that is not Defeating Commander. Review’s word “blocked” might mean something else.
- **Gargoyle** — cannot be Defeated. Irrelevant unless you meant Slay.
- **Quiet Bell** — silenced Commander: no +2, and no flee?
- **Count 2** — two Commanders, each flees once?
- **Harpy / Kobold** — mid-fight interrupt into Spin.
- **Damsel neighbors** — if Commander is a Damsel neighbor, they swing, they are not Defeated (Damsel’s note). No flee from that.
- **Tutorial** — Commander is not in the starter kit.

**Generous reading:** Only Boot / Fangs / Sledge / HP-to-0 count. Done with Block does not. After flee, Commander stays, wheel shuffles, Spin happens by itself. Crossbow killing them cancels the other fight.

**Stingy reading:** Any way Commander’s slice would clear counts, including a 0-HP chip from Poison. You click Spin yourself after the shuffle. Crossbow finishes the current owner, then shuffles.

**Ways it can fail:**
- Flee looping forever if shuffle always “defeats” them again.
- Flow on the board still says “Base ATK + 1” while Ability says +2. Live code is +2. I will follow Ability +2, not the stale Flow.
- No tell after they have already fled, so the second kill looks like a bug.

**What the player sees:** Neighbors still show the +2. After first removal, Commander is still on a random seat and the wheel moves.

**If we skip this:** Commander is only the +2 today.

**If we take the strongest reading:** Crossbow on Commander mid-Golem-fight yanks you out, shuffles, Spin. The Golem fight never finishes.

---

## 4. Ogre HP always matches yours

**Pitch (Nathan’s words):** Instead of updating Ogre HP on Spin, always match player HP when player HP updates, before modifiers (Lich).

**Restate (what the player does):** Ogre’s HP number on the wheel is your current HP, all the time. When you Heal, Bleed, or take a hit, Ogre’s plate changes even if you are not fighting them.

**Where it happens in a round:** Whenever your HP changes. Not used up. No click. Number keeps updating.

**Which existing cards this touches:**
- **Lich** — +1 HP to neighbors, after Ogre copies you (your note).
- **Cursed Scroll** — lose 1 on Spin; Ogre drops 1 too.
- **Healing Potion / Fangs Heal / Damsel Heal 3** — Ogre rises with you.
- **Breastplate** — cares that you lost HP, not Ogre’s HP.
- **Da Boot** — Boot needs enemy HP < your HP. If Ogre always equals you, Boot can never fire (equal is not less).
- **Slime** — separate card (ATK = own HP).
- **Quiet Bell** — printed HP while silenced?
- **Player at 0 HP** — Ogre at 0. Do they leave the wheel immediately?

**Generous reading:** Live match, including mid-fight. Lich can still add +1 after. Boot never works on Ogre. Player at 0 does not remove Ogre until you would have died anyway.

**Stingy reading:** Same live match, but if your HP hits 0, Ogre is Slain immediately even from another fight. Quiet Bell: printed 4.

**Ways it can fail:**
- Updating only on Spin (old card) so Heal in a fight does not change Ogre.
- Boot looking playable vs Ogre (it should be crossed out if HP is equal).
- Infinite loop: Ogre dies at 0 → something Heals you → Ogre returns.

**What the player sees:** Ogre HP ticks with the heart row.

**If we skip this:** Live Ogre already copies your HP when that slice is spun.

**If we take the strongest reading:** Cursed Scroll can delete Ogre from across the wheel by dropping you to 0, or a Heal can inflate Ogre during a different fight.

---

## 5. Spider Queen → Spider Egg

**Pitch (Nathan’s words):** Rework. On Spin while Queen is still alive, create Spider Egg directly into the hotbar (gross sound, highlight from Queen’s seat). Egg is a new black hatched item. On use: take 2 Attack damage. If it is in hand when you Spin Spider Queen: discard it and Queen gains +2 HP and +2 Attack. An egg is not generated when you Spin Spider Queen. Ask questions. Ability field on the board is currently empty. Old explainer/flow still describe the double hit.

**Restate (what the player does):** Each time you Spin onto someone who is not Queen, if Queen is on the wheel, an Egg appears in your hand. You may click Egg during a fight: you take 2 Attack (whether Block stops it is a question), Egg is used up. If you still hold Egg and the wheel lands on Queen, Egg is thrown away and Queen’s plate goes +2/+2. Landing on Queen does not give you a new Egg.

**Where it happens in a round:** Egg is created on Spin (not Queen). Egg is clicked in a fight, used up. The discard-on-Queen-Spin happens by itself.

**Which existing cards this touches:**
- **Hotbar size** — full hand: no Egg, or Egg anyway?
- **Block / Dragon / Goblin** — Egg deals Attack to *you*. Block should stop it unless you say it Bleeds. Dragon pierce is about their Attack, not this.
- **Breastplate** — if Egg damage gets through, you lost HP this combat.
- **Cursed Scroll** — separate Spin loss.
- **Smoke Bomb** — a Spin, so a new Egg if Queen is alive and you did not land on Queen.
- **Old Queen double hit** — explainer still says it. Ability is blank. Keep it, or eggs only?
- **Hornet / empty / last / tutorial** — Egg does not target a slice. Developer Test: Queen + Spin someone else.
- **Unique art** — Egg needs its own sprite (egg / egg sac), not Queen’s sprite.

**Generous reading:** Eggs only, old double hit gone. Egg damage is Attack, Block works. Full hand: no extra Egg. Only one Egg at a time.

**Stingy reading:** Every Spin of someone else adds another Egg even past a full hand. Using Egg ignores Block (always lose 2). Queen still double-hits *and* lays eggs.

**Ways it can fail:**
- Creating an Egg when you Spin Queen (you said not to).
- Egg stays in hand after Queen Spin (no +2/+2).
- Blank Ability on the player plate.
- Reusing another item’s art for Egg.

**What the player sees:** A new black card appears from Queen’s seat. Queen’s own Ability line is currently empty.

**If we skip this:** Live Queen is still “attack twice if a neighbor has less HP.”

**If we take the strongest reading:** Smoke farming fills the bar with Eggs; each is 2 damage you can dump; missing the discard timing inflates Queen every time you land on her with Eggs.

---

## Not in this Paper Fight

- **Beggar** — Ability / Flow / Notes already agree (leftmost Attack item, else 3, updates on Spin and item use, skip spent/petrified, Quiet Bell printed). No new collision question.
- **Cursed Scroll** — already fought and coded. Leftover: hotbar should show green 6.
- **Breastplate / Poison Flask / Smoke** — explainer-only this Save.
- **Tutorial.beat.01.body** — locked copy rewrite. Not a card rule.
- **Helmet / Quiet Bell / Basilisk / Twins / Needleback / Wizard / Golem / Anvil** — Ability prose on live cards, no Flow change this Save.

---

**Questions for Nathan:** (asked in the form; answers change the code)

1. Damsel: neighbors swing when you click Done, or automatically when you land on Damsel?
2. Damsel with a missing neighbor: skip that side, then Heal 3 and Damsel leaves?
3. Damsel: if a neighbor hit would drop you to 0, do you die before Heal 3?
4. Damsel: a Hornet/Dragon neighbor is a full Done against that owner, or one printed Attack number?
5. Commander: first flee is Defeat items and HP-to-0 only, or also clicking Done?
6. Commander flee during Crossbow: interrupt into Spin now, or finish the current fight first?
7. Berserker: 3 then 4 then 8 on every Spin while seated (including other fights / Smoke)? Commander +2 on top?
8. Ogre: live match whenever your HP changes. If you hit 0, does Ogre leave immediately?
9. Spider Egg: Block stops the 2 Attack? Old Queen double-hit gone? Full hand / extra Eggs?

**Self-audit:** restated as what the player does · named Hornet/Dragon/Boot/Crossbow/Lich/Queen · both readings · questions would change the code · implemented after answers

---

## Answers (2026-10-10)

1. Damsel neighbors hit when you click Done / Take. Items first.
2. Missing neighbor: skip that side, then Heal 3 and Damsel leaves.
3. If a neighbor would drop you to 0, you die. Heal 3 never happens.
4. Hornet / Dragon / Queen / Mimic neighbor is a full Done against that owner.
5. Commander flee: anything that would remove them, including Done / Take even if Block stopped the hit.
6. Crossbow / Longbow: interrupt now, shuffle, Spin.
7. Berserker steps on every Spin while seated (including Smoke and other fights). Commander +2 on top.
8. Ogre matches live HP. Player at 0: Ogre is Slain immediately.
9. Egg: Block stops the 2 Attack. Old Queen double-hit is gone. Always add an Egg on other Spins. Hand cap 50.
