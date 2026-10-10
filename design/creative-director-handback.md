# Creative director handback — Swipe

**For Cursor / producer:** implement from these tables only. Frozen **ids** win. Frozen **rules** win. Display names and all player-facing copy are below.

**Fantasy lock (impish cute):** You are a greedy little thief. At the door you see shiny loot. **Take** = you steal it; then the owner is revealed and they come to get it back. **Pass** = leave it. Fill eight seats. **Spin** = fight for the pile. Combat is still combat (block / attack / defeat / hearts).

---

## A. Pitch

**1. Place / player / ring / attraction**

You hid in a round stone room at the bottom of a dungeon — a loot nest with eight alcoves around a hub. You are an impish little thief with sticky fingers. A mystery door keeps offering glowing goods. Every time you Take one, its owner steps out of the dark, yells that you stole their stuff, and climbs into an alcove to fight you for it. When eight owners have seated, the room turns. You spend the pile to stay alive. Alive is the only score.

**2. Through-line**

Steal the shiny. Fight who owned it.

**3. Tone**

Write in: impish, cute, greedy, cheeky, short, smug, playful, a little mean to the monsters.  
Do not write in: epic, grimdark, mill/reliquary poetry, gift-shop Pip nostalgia, meme spam, purple fantasy sermons, gore-porn.

**4. Who speaks**

- **Creatures** — first person, one rule each (inspect body). Outraged owners, not tour guides.
- **Nib** — tutorial guide. Older fence / cousin-thief who let you stash loot here and is annoyed you invited half the dungeon home. Allowed to teach because they want you alive long enough to fence the leftovers.
- **The door** — gate chrome + slam/reveal. Shiny first; owner second.
- **Overlays** — title / win / lose. Short. Smug when you win.

**5. What not to chase**

- Mega Man weapon-steal
- Hades charming shopkeeper
- Binding of Isaac toilet humor
- Darkest Dungeon sermons
- Chapel / Wake / mill / night-watch scaffolding (retired)

---

## B. Title and mode labels

| slot | current | yours |
|---|---|---|
| game title | Boss Rush | Swipe |
| How to Play | How to Play | How to Play |
| Begin | Begin | Begin |
| Dive In | Dive In | Dive In |
| Again | Again | Again |
| win title | Cleared | Kept it |
| win sub | The mill is empty. | The pile is yours. |
| lose title | Down | Caught |
| lose sub | HP 0. | They took it all back. |
| Spin | Spin | Spin |

---

## C. Tutorial

**Speaker display name:** Nib  
**Skip label:** Skip  
**Portrait note:** Search `16x16 pixel imp thief cute` / `16x16 pixel goblin rogue scarf` / `pixel cute thief portrait dungeon` — nearest-neighbor, warm browns/greens, impish smile. Avoid armored knight and cute animal-crossing mascot. (Current `dwarf_f` is a stand-in.)

| # | wait | focus | go | hint | body |
|---|---|---|---|---|---|
| 1 | continue | "" | Let's go | --- | Name's Nib. You're the sticky-fingered one. You stole a pile and stuffed it in this round room. Get through three fights and I'll pretend this was always the plan. |
| 2 | continue | wheel | Got it | --- | This circle is your nest — eight alcoves, no polite exit. It turns. You fight whoever lands. I seated a Golem, a Wizard, and a Berserker. I'm steering. |
| 3 | continue | hearts | Alright | --- | Those hearts are you. Empty means the owners win. One heart left is still a win. Nobody grades on leftovers. |
| 4 | hover_item | hotbar | --- | (hover any item) | Your loot's along the bottom. Hover a card. Hold Shift if you want the equation instead of the number. |
| 5 | continue | item:helmet | Fine | --- | Helmet's number is alive — it changes with health. We probably won't tap it if you listen. Shield is the pillow. Flail gets ideas later. I also slipped a boot in. Don't ask. |
| 6 | spin | spin | --- | (click Spin) | Click Spin. I'll land the Golem. Big, slow, hits for three. |
| 7 | item:shield | item:shield | --- | (click Shield) | Golem. Three in the knuckles. Your Shield is four. Click the Shield. |
| 8 | continue | wheel | OK | --- | That gold in the hub is Block. It's a pillow. When this fight ends, the pillow goes in the trash. Hearts stay. |
| 9 | done | done | --- | (click Safe) | Click Safe. You blocked it all this time. If a heart had popped, we'd keep walking. Alive is the only score. |
| 10 | continue | trophy | Spin when ready | --- | Block's gone. Hearts aren't. That little plaque is your body count — the Flail is counting too. Two owners left. |
| 11 | spin | spin | --- | (click Spin) | Spin again. Wizard this time. Don't eat what they throw. |
| 12 | item:da_boot | item:da_boot | --- | (click the Boot) | Five attack, two health. You could hide and still get nicked — or you end it. Click the Boot. If they have less health than you, the fight just stops. |
| 13 | continue | item:helmet | Got it | --- | That's the other trick: finish the small ones. The Flail only grows when you bleed — you didn't, so it's still 2. Helmet's the pillow for this last one. |
| 14 | hover_slice:berserker | wheel | --- | (hover the Berserker) | Last alcove. Hover it. Owners have hobbies too — they tell you if you ask. This one gets stronger when you win. Rude. |
| 15 | spin | spin | --- | (click Spin) | Spin. Berserker hits 3. Helmet is the lower of your HP and theirs. |
| 16 | item:helmet | item:helmet | --- | (click Helmet) | Click the Helmet. Four block against three attack. |
| 17 | done | done | --- | (click Safe) | Click Safe. Block dumps after this. Hearts stay. That's how you keep a pile. |
| 18 | continue | "" | I'm good | --- | You lived. I get a cut later. Dive In is the real heist — I don't pick the order, and there are eight of them. Try not to need me. |

---

## D. Overlay, cues, gate chrome, inspect chrome

| key | yours |
|---|---|
| Title overlay title | Swipe |
| Title overlay subtitle | Steal the shiny. Fight who owned it. Begin is the door. Dive In skips it. |
| Buttons | How to Play \| Dive In \| Begin |
| Pause modes | How to Play \| Dive In \| Begin (plus Resume, Quit, Start over) |
| Win title | Kept it |
| Win sub | The pile is yours. |
| Win btn | Again |
| Lose title | Caught |
| Lose sub | They took it all back. |
| Lose btn | Again |
| In-run Spin | Spin |
| Done → Safe / Take N | Safe / Take {n} |
| Idle inspect title | Inspect |
| Idle inspect body | Hover an owner on the ring, or loot in your hand. |
| Shift hint | hold Shift to explain |
| cue draft/night watch | Starters take north, east, south, and west. |
| cue draft/force | No passes left — the door fills the rest. |
| cue draft/ask | Steal the {item} (Tier {n}) and wake a Tier {n} owner — or pass ({k} left). |
| cue draft/seat | Click an empty alcove. That's where they'll wait. |
| cue draft/filling | The nest is filling. |
| cue ready | Spin — the nest turns. |
| cue fighting | Click an item, or take the hit |
| cue fighting/mark | Click a neighboring enemy |
| cue devtest | (leave developer copy as-is) |
| Gate title | THE DOOR |
| Gate relic label | THE SHINY |
| Gate threat label | THE OWNER |
| Gate help | Hover the shiny. Hold Shift for the math. Same metal on both sides. |
| Gate hook | Steal {item}, and a matching-tier owner comes through that door. |
| Gate Take btn | Take it — wake a Tier {n} |
| Gate Pass btn | Pass  ·  {n} left |
| Gate seat prompt | Click a + alcove. |
| On-wheel flash | BLOCKED / SLAIN |
| Knife choice A | ATK 3, discard |
| Knife choice B | ATK 1, keep |

---

## E. Monsters

| id | display name | speech (I/My) | explainer | art search | one-line story function |
|---|---|---|---|---|---|
| wizard | Wizard | My spellbook was in that pile. | plain ATK/HP owner | `16x16 pixel wizard robe dungeon cute` | Soft opener; wants their book-adjacent loot back. |
| golem | Golem | My stone fists want that back. | plain ATK/HP owner | `16x16 pixel stone golem dungeon` | Slow bruiser who guarded the stash. |
| goblin | Goblin | I cannot take attack damage. | no attack damage | `16x16 pixel goblin thief smug` | Fellow thief energy; shrugs off steel. |
| skeleton | Skeleton | I copy the HP of the last enemy you faced. | last enemy HP | `16x16 pixel skeleton warrior dungeon` | Echo of whoever fell last. |
| hornet_swarm | Hornet Swarm | I attack twice. Your block is spent on each swing. | attacks twice | `16x16 pixel insect swarm yellow` | Nest pests; two stings. |
| lich | Lich | I give my neighbors +1 HP. | neighbors +1 HP | `16x16 pixel lich crown purple` | Props up other owners. |
| ogre | Ogre | My HP is your HP. | HP is yours | `16x16 pixel ogre club dungeon` | Mirror bulk. |
| berserker | Berserker | I gain one HP and attack with each monster you defeat. | attack and HP plus defeat | `16x16 pixel berserker axe rage` | Gets madder each time you keep a trophy. |
| dire_wolf | Dire Wolf | My attack is your HP. | attack is your HP | `16x16 pixel dire wolf dungeon` | Hunger scales with how alive you still are. |
| bandit | Bandit | My attack is how many items you hold. | attack is items | `16x16 pixel bandit hood dagger` | Counts your sticky fingers. |
| leech_league | Leech League | My HP is 1 plus how many of us are still on the wheel. | HP from monsters left | `16x16 pixel leech swarm pink` | Crowd that thins as seats empty. |
| wraith | Wraith | I copy the higher neighbor's attack. | copies neighbor attack | `16x16 pixel wraith ghost blue` | Borrows the strongest neighbor. |
| mimic | Mimic | If I go down before I attack, you gain an item. | item if I never swing | `16x16 pixel mimic chest teeth cute` | Fake chest; crack it first, get paid. |
| two_headed_serpent | Two-Headed Serpent | My attack drops to 0 if you use two items this fight. | two items, no attack | `16x16 pixel two headed snake` | Distracted when you’re busy with loot. |
| slime_boss | Slime Boss | My attack always equals my HP. | attack equals HP | `16x16 pixel slime green boss cute` | Soft mass; hurt = hit. |
| spider_queen | Spider Queen | I attack twice if a neighbor has less HP than I do. | double hit if a neighbor is weaker | `16x16 pixel spider queen crown` | Bullies the weak seat beside her. |
| commander | Commander | I give my neighbors +2 attack. | neighbors +2 attack | `16x16 pixel undead captain banner` | Drills the other owners. |
| dragon | Dragon | My attack ignores block. | ignores block | `16x16 pixel small dragon red cute` | Biggest owner; pillows don’t help. |

---

## F. Items

Ability = inspect body. Explainer = Shift math. Taunts = after door opens (owner reacts to the theft). Art = search phrase.

### throwing_knife · Throwing Knife
- **ability:** Throw for 3 and lose it, or nick for 1 and keep it.
- **explainer:** (3) or (1 and KEEP)
- **choices:** `ATK 3, discard` | `ATK 1, keep`
- **art:** `16x16 pixel throwing knife metal`
- **taunts:**
  1. Hey! That's my throwing knife — spit it out!
  2. Cute steal. I'm taking the knife back. Point first.
  3. You swiped my knife. I'll swipe you.
  4. One knife. Two of us. Put it down, thief.
  5. Don't throw it yet. I want it back in one piece.

### shield · Shield
- **ability:** Gain 4 block.
- **explainer:** (BLK 4)
- **art:** `16x16 pixel round wooden shield dungeon`
- **taunts:**
  1. That's MY Shield! Hide behind it — I'll wait.
  2. Sticky fingers on my Shield. Rude.
  3. Give it back. I'll still knock you over.
  4. Nice steal. Bad idea.
  5. Keep the Shield warm. I'm coming for it.

### sai · Sai
- **ability:** Starts at 2 each fight. Flips 2 ↔ 4 after any item is used.
- **explainer:** (2) or (4)
- **art:** `16x16 pixel sai weapon dual`
- **taunts:**
  1. Those Sai are mine! Pokey little thief.
  2. You grabbed my Sai. Now we dance.
  3. Put the prongs down. I said please. Kind of.
  4. Fancy steal. I'm still taking them home.
  5. My Sai. Your problem.

### medallion · Medallion
- **ability:** Block equal to the HP you are missing.
- **explainer:** (6 − HP)
- **art:** `16x16 pixel gold medallion amulet`
- **taunts:**
  1. Shiny Medallion — that's mine, sparkles!
  2. You stole my luck charm. Bad luck for you.
  3. Hand it over, sticky-fingers.
  4. Jewelry thief! I saw that!
  5. The Medallion called me. You just grabbed it.

### helmet · Helmet
- **ability:** Block equal to whoever has less HP — you or the enemy.
- **explainer:** (the lower of YOUR HP and ENEMY HP)
- **art:** `16x16 pixel iron helmet dungeon` — **replace flask stand-in**
- **taunts:**
  1. My Helmet! Cover your head — I'll aim anyway.
  2. You swiped my lid. Bold.
  3. That Helmet's mine. Your thoughts can stay.
  4. Cute. Wrong head.
  5. Take the Helmet. I'll take the rest of you.

### da_boot · the Boot
- **ability:** Defeat an enemy with less HP than you. Combat ends immediately.
- **explainer:** (ENEMY HP < YOUR HP)
- **warn meaning:** Can't — this enemy has as much HP as you, or more.
- **art:** `16x16 pixel leather boot dungeon`
- **taunts:**
  1. That's MY Boot! I'm kicking you with it!
  2. You stole a boot. I stole a seat. Guess who wins.
  3. My size. Your foot's optional.
  4. A boot heist? I'm laughing, then I'm winning.
  5. Keep it laced. I want it back clean.

### grimoire · Grimoire
- **ability:** Attack equal to the attack of the last monster you faced.
- **explainer:** (LAST ENEMY ATK)
- **art:** `16x16 pixel grimoire spellbook closed`
- **taunts:**
  1. My Grimoire! That's not light reading for you!
  2. Book thief! Homework's over — fight starts.
  3. Magic book. Sticky fingers. I can do that math.
  4. Don't dog-ear it. I'll end you either way.
  5. The Grimoire called. You just stole it.

### bloody_gauntlets · Bloody Gauntlets
- **ability:** Attack equal to the HP you are missing, counted from 7.
- **explainer:** (7 − HP)
- **art:** `16x16 pixel bloody gauntlets red`
- **taunts:**
  1. Those Gauntlets are mine — already my color!
  2. You put them on. I put on a smile. Only one lasts.
  3. Sticky red fingers. Cute.
  4. Give them back before they match the floor.
  5. My gloves. Our blood optional.

### breastplate · Breastplate
- **ability:** Gain 2 block. If you lose HP this combat, keep this item.
- **explainer:** (2) and KEEP if you bled
- **art:** `16x16 pixel breastplate armor dungeon`
- **taunts:**
  1. My Breastplate! Fancy tin on a thief!
  2. I'll dent it. Then I'll keep it.
  3. That plate's mine. Your ribs can commute.
  4. Armor theft. Bold. I brought teeth.
  5. Polish it. I'm taking it shiny.

### bracers · Bracers
- **ability:** Block equal to the weaker neighboring enemy's attack.
- **explainer:** (NEIGHBOR ATK)
- **warn meaning:** Can't — no neighboring enemy.
- **art:** `16x16 pixel leather bracers wrist`
- **taunts:**
  1. My Bracers! Wrist jewelry looks better on me.
  2. Snap them off later. After I win.
  3. You grabbed the Bracers. I grabbed a seat.
  4. Cute armor. Bad owner now.
  5. Keep them on. Makes the trophy shot nicer.

### smoke_bomb · Smoke Bomb
- **ability:** Abort this fight, spin again (not the same slice), and gain a random unseen item.
- **explainer:** re-roll + 1 random item
- **art:** `16x16 pixel smoke bomb pouch`
- **taunts:**
  1. My Smoke Bomb? Hiding already? I can wait.
  2. Puff — then me — then you, briefly.
  3. You stole my exit trick. Cute.
  4. Smoke's mine. The dark is mine too.
  5. Take it. I'll find you anyway. That's the fun.

### knucklers · Knucklers
- **ability:** Attack equal to 8 minus the items still in your hand.
- **explainer:** (8 − ITEMS)
- **art:** `16x16 pixel brass knuckles`
- **taunts:**
  1. My Knucklers! You want to punch ME with MY brass?
  2. Sticky fingers, brass knuckles. Adorable.
  3. Those are mine. Your plan is notes.
  4. Packed for a brawl with my stuff. Rude.
  5. Keep them warm. I'm reclaiming a pair.

### fangs · Fangs
- **ability:** Take their hit (block still works), defeat them, then heal equal to the HP they had.
- **explainer:** (TAKE THEIR ATK) then DEFEAT then HEAL THEIR HP
- **art:** `16x16 pixel vampire fangs item`
- **taunts:**
  1. Those Fangs are copies — I'll show you the originals!
  2. Teeth thief! Brave. Stupid. Brave.
  3. My extras. Your mouth. No.
  4. Bite toys. Guess what they're for.
  5. Keep them handy. I'm collecting a matching pair.

### poison_flask · Poison Flask
- **ability:** Mark a neighbor. When you spin them, they lose 5 HP immediately.
- **explainer:** mark neighbor −5 HP on spin
- **warn meaning:** Can't — no neighbor you can poison.
- **art:** `16x16 pixel green poison flask`
- **taunts:**
  1. My Poison Flask! Classy steal. You first.
  2. Green vintage. Notes of sticky-fingers.
  3. Don't spill. I want all of it back.
  4. You packed my poison. I packed hunger.
  5. Cute vial. Keep the symptoms. Return the bottle.

### spiked_flail · Spiked Flail
- **ability:** Gets stronger. +2 attack each time you lose any HP.
- **explainer:** +2 ATK for each time you BLED
- **art:** `16x16 pixel spiked flail mace`
- **taunts:**
  1. My Flail! Spikes AND theft? You're speaking my language.
  2. That Flail's going back on my mantel.
  3. Finally someone with taste. Still a thief.
  4. You picked the mean one. Briefly respected.
  5. Don't get attached. I will.

### healing_potion · Healing Potion
- **ability:** Unplayable. If you would die, discard this and heal 3.
- **explainer:** on lethal: discard, heal 3
- **art:** `16x16 pixel red healing potion`
- **taunts:**
  1. My Healing Potion? Planning to live with MY juice?
  2. Second chance stolen. I'm taking it back.
  3. Red flask. Red ending. Consistent.
  4. Don't drink it yet. I want it full.
  5. Sweet steal. I'll take it off the corpse.

### crossbow · Crossbow
- **ability:** Deal 4 attack to a neighboring enemy with 4 HP or less. Goblin cannot take attack damage.
- **explainer:** (ATK 4) if (NEIGHBOR HP ≤ 4)
- **warn meaning:** Can't — no neighbor at 4 HP or less that can take attack.
- **art:** `16x16 pixel crossbow wood`
- **taunts:**
  1. My Crossbow! Point it at someone else — then give it back.
  2. Bolts thief. I'll keep the bow. You can keep the holes.
  3. You aimed MY Crossbow in MY room. Rude.
  4. Don't scratch the stock. I'm reclaiming it.
  5. Finally a thief with range. I have more.

### sledgehammer · Sledgehammer
- **ability:** Defeat an enemy with 5 or more attack. Combat ends immediately.
- **explainer:** (ENEMY ATK ≥ 5)
- **art:** `16x16 pixel sledgehammer tool`
- **taunts:**
  1. My Sledgehammer! Overkill theft. I like overkill.
  2. Big hammer. Small thief. This'll be short.
  3. You brought MY hammer to MY nest. Rude. Fun.
  4. The wall can keep the hole. I want the hammer.
  5. I'll take it back. You can keep the headache.

### pocketwatch · Pocketwatch
- **ability:** Attack equal to the attack of the strongest neighboring enemy.
- **explainer:** (Highest Neighbor ATK)
- **art:** `16x16 pixel pocket watch brass`
- **taunts:**
  1. My Pocketwatch! Time's up, thief — not a metaphor.
  2. Tick tock. That's me walking. That's you not.
  3. Nice steal. Time of death: soon.
  4. You grabbed a clock. I grabbed a seat.
  5. Stop winding it. I'll stop you.

**Shared warns (keep meaning):**
- Spent item: Already used this fight.
- Da Boot / Bracers / Poison / Crossbow: meanings above.

---

## G. Default door taunts

1. Hey! That {item} is mine — spit it out!
2. Cute steal. Shame you're going to lose holding it.
3. You swiped the {item}. I noticed. That's a problem for you.
4. Keep it warm. I'm taking it off you.
5. The {item} called. You just stole it. I'm coming.

---

## H. Storyboard (existing beats only)

| beat | on screen | who talks | camera / note |
|---|---|---|---|
| Title | Parchment overlay; three mode buttons; dark ring behind | Overlay | Top-down nest visible under UI; soft dungeon loop. Smug title energy, not epic. |
| Night-watch seating | Four starters land N/E/S/W; bag fills | Cue only | Pop into alcoves; hub hearts visible. |
| Gate mystery | Door silhouette + glowing shiny card + Take/Pass | Gate chrome (THE DOOR / THE SHINY / THE OWNER) | Shiny is the bright thing; owner still hidden. |
| Door slam / reveal | Silhouette → named owner + outraged balloon + seat prompt | Owner (draft taunt) | Slam/open → “that’s MINE” balloon → click empty alcove. |
| Spin | Nest turns; one slice lands at 6 o’clock | Cue: Spin — the nest turns. | Top-down rotate OK; land is the shot. |
| BLOCKED vs SLAIN | Flash on slice | Word only | BLOCKED = pillow held. SLAIN = alcove empties, neighbors close. |
| Win | Kept it / The pile is yours. / Again | Overlay | Empty ring; smug, not triumphant orchestra. |
| Lose | Caught / They took it all back. / Again | Overlay | Dark hearts; same parchment language. |

No new cutscenes. No new UI.

---

## I. Art keyword pack

**Searches:**
1. `16x16 pixel circular dungeon room top down alcoves`
2. `16x16 pixel cute imp thief portrait scarf`
3. `16x16 pixel glowing loot relic bronze silver gold rim`
4. `16x16 pixel monster dungeon fantasy nearest neighbor cohesive`
5. `pixel RPG UI parchment brown gold kenney-compatible`
6. `16x16 pixel iron helmet dungeon item` (**priority — replace flask-as-helmet**)
7. `16x16 pixel leather boot item`
8. `16x16 pixel wooden round shield`
9. `16x16 pixel green poison flask cork`
10. `16x16 pixel smoke bomb pouch`
11. `16x16 pixel spiked flail`
12. `16x16 pixel cute small dragon red`
13. `16x16 pixel mimic chest teeth`
14. `CC0 dungeon ambience loop low`

**Avoid:** grim chapel photoreal; cyberpunk neon; chibi anime eyes; Animal Crossing candy; Mega Man robot masters; mixing sci-fi guns into the loot set.

**License:** CC0 first (Kenney, 0x72, OGA CC0, itch CC0). Credit-ok only if CC0 fails for a stem.

**Replace first:** helmet-as-flask (and any item icon that is clearly the wrong object vs display name).

---

## J. Open questions

None blocking. Locked:

- Title **Swipe**
- Guide **Nib** (impish fence/cousin)
- Player fantasy **impish cute thief**
- Gate beat **see shiny → Take steals → owner reveals → seats to reclaim**
- Setting **round dungeon nest / circular room** (top-down spin OK)

---

## Producer file map (paste targets)

| Table | Lands in |
|---|---|
| C Tutorial | `scripts/tutorial_guide.gd` (`BEATS`, speaker name) |
| F/G Door taunts | `scripts/draft_lines.gd` (`LINES`, `DEFAULT`) |
| B/D Overlay, cues, Shift, knife choices | `scripts/main.gd` |
| D Gate chrome | `scripts/draft_gate.gd` |
| E/F Card names, ability, explainer | `data/content-board.json` (+ catalog on Save) |
| E Speech / reminders sync | `scripts/main.gd` (`MONSTER_SPEECH`, `MONSTER_REMINDER`) |
| B Pause labels | `scripts/settings_menu.gd` |
| D BLOCKED / SLAIN | `scripts/boss_wheel.gd` (keep words) |
| I Art keywords | producer search → `scripts/dungeon_art.gd` stems |

Engine: Godot 4.7.2 · `res://scenes/main.tscn` · viewport 1680×1040.

*Id wins. Rule wins. Impish cute wins.*
