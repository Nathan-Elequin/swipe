# Creative director brief — Boss Rush (working title)

**Paste this entire file into the Grokbot as the first message.** Do not summarize it first. The producer who wrote this has no story to protect. Everything that sounds like lore, voice, or theme below is scaffolding. Your job is to replace it.

You are being hired as **artist, creative director, narrative writer, and storyboarder** for a small digital dungeon that already plays. You have **zero** prior context. The person hiring you is the game designer / producer / engineer. They will implement your writing in Godot. They will not invent a story for you.

---

## 1. Your job

Think. Pitch. Write. Then hand back something the producer can drop into named files without guessing.

You own:

- Tone, setting, through-line, names (game title included), who talks, why anyone is here
- All player-facing words
- Tutorial voice and beat wording (the **sequence of actions** stays; the **script** is yours)
- Art direction: specific search keywords and phrases so the producer can find CC0 / itch / OpenGameArt assets that match **one** cohesive look — not a moodboard of five unrelated genres
- Storyboard notes for the few cinematic beats that already exist as empty shells (title, gate, fight, win, lose)

You do **not** own:

- Rules, numbers, item effects, monster math, who neighbors whom
- Control scheme, UI layout, or new screens
- Engine work, new systems, extra modes
- Renaming internal **ids** (`goblin`, `da_boot`, `shield`, …). Display names can change. Ids cannot.

If a line of copy currently teaches a rule, **keep teaching that rule**. You may say it in a new voice. You may not change what the player is being told to do.

The producer does **not** feel strongly about any of the existing text. Pip, the mill, relics, night watch, “Boss Rush,” gift-shop jokes, trophy-hunter monsters — all of that was typed so the game could be playtested. Treat it as lorem ipsum with verbs attached.

---

## 2. What the game is (player experience only)

One player. Mouse. A shrinking ring of enemies. A hand of items. Live or die.

It is **not** Mega Man (pick a boss, steal a weapon). It is closer to a solitaire dungeon: you assemble a circle of monsters and a bag of tools, then you spin the circle until it is empty or you are.

**Inputs**

- Left click: buttons, items in the bag, empty seats on the ring, Take / Pass at the door
- Hover: inspect a monster slice or an item card
- Hold **Shift** while hovering: swap the big number for the short math line
- Right click: opens an editor (developer only — ignore)
- **Escape**: pause (Resume / Quit / start-over modes)

**Outputs the player actually looks at**

- An **8-slice wheel** (compass seats: N, NE, E, SE, S, SW, W, NW). Occupied slices show a creature. Empty slices are dark alcoves.
- **Hearts** on the wheel hub (player HP, max 6)
- A gold **block** number during a fight (a pillow for this fight only; dumped when the fight ends)
- A **hotbar** of item cards along the bottom (icon, title, a live number or mark)
- An **inspect plate** (title, numbers, math, body, warnings)
- A **speech balloon** off the creature (or off the door) — first-person, short
- A **trophy plaque**: a skull and a number. **No English** on it. Do not write words for this object.
- Overlay screens: title, win, lose
- A talk box during How to Play (portrait + name + body + hint + continue / skip)
- A **gate panel** before the dungeon: a mystery door, a relic card, Take / Pass

**What the player is choosing**

- At the gate: take this tool and accept the matching-tier monster that comes with it, or pass (three passes, then the rest auto-fill)
- On the wheel: click an empty alcove to seat that monster
- In a fight: spend items now, or click the resolve button and take leftover attack as heart damage
- Order is not fully in their control. **Spin** picks a remaining monster at random.

**Win / lose**

- Win: every monster slice is gone, player still has at least one heart
- Lose: hearts hit 0
- Leftover hearts are not a grade. Alive is the only score.

---

## 3. The loop, in order

### Title overlay

Three player buttons (plus two developer buttons you may ignore):

| Button (current label) | What it does |
|---|---|
| **How to Play** | Scripted three-fight walkthrough on the live board |
| **Begin** | Full run: seat four starters, then the gate, then combat |
| **Dive In** | Skip the gate. Auto-fill eight monsters and four items, go straight to Spin |

Developer-only: Developer Test, Roster. Do not write story for those.

### Full run (`Begin`)

1. Four **starter** monsters auto-seat on N, E, S, W. Four starter items go into the bag. One of those items is always currently called Smoke Bomb.
2. **The gate** (up to four more packs). Each pack: one item + one monster, same metal tier (bronze / silver / gold). Door is a silhouette until you Take. Then it slams open, the monster is named, they speak, you click an empty alcove.
3. You may **Pass** three times. After that, remaining packs are forced in.
4. Wheel is full (8). Combat.

### Combat

1. Click **Spin**. The wheel turns. One remaining monster lands at 6 o’clock.
2. Click items (some unusable; plate says why). Some items **Defeat** (remove without the usual hit). Some **Attack**. Some **Block**. Some mark a neighbor. Some abort the fight and spin again.
3. Click the resolve button. Label is **Safe** if block covers the hit, or **Take N** if N hearts would be lost.
4. If they die: slice vanishes, neighbors close the gap, block dumps, hearts stay. Repeat from Spin.
5. If you die: lose overlay.

Items are usually discarded after use. A few keep. Block never carries to the next fight.

**Neighbors matter.** Several items and monsters care who sits next door. Last monster has no neighbors; some tools turn off.

### How to Play (tutorial) — keep this sequence

The producer will not change the forced seats, the four items, or the wait flags. You rewrite **only** the spoken text, hints, speaker name, continue-button labels, and Skip label.

**Setup (code, not flavor):** seats Golem → slot 0, Wizard → slot 2, Berserker → slot 4. Bag: Shield, Helmet, Da Boot, Spiked Flail. Phase is already Spin-ready. The guide steers which Spin lands (Golem, then Wizard, then Berserker). Wrong items are blocked until the beat asks for them.

**Wait flags you must preserve** (these are code keys, not copy): `continue` | `hover_item` | `spin` | `item:shield` | `done` | `item:da_boot` | `hover_slice:berserker` | `item:helmet`

**Focus tags you must preserve:** `""` | `wheel` | `hearts` | `hotbar` | `item:helmet` | `spin` | `item:shield` | `done` | `trophy` | `item:da_boot`

Skip → title. Finish last beat → tutorial closes; they are left on the live board after three wins.

---

## 4. Surfaces that need words (and length)

Write short. These boxes are small.

| Surface | Soft cap | Notes |
|---|---|---|
| Overlay title | ~2 words | Title / win / lose |
| Overlay subtitle | one sentence | |
| Overlay buttons | 1–3 words | Must map 1:1 to How to Play, Begin, Dive In, Again |
| Cue line (under the wheel) | one sentence | Situational; see current list |
| Inspect title | card name | |
| Inspect value | numbers, not prose | Attack / HP / Block — keep as numbers |
| Inspect equation / explainer | short math, often in parentheses | Shift-line. Keep operators readable. English keywords OK if they stay scanable: KEEP, ATK, HP, ITEMS |
| Inspect body | 1–2 sentences | Player-facing ability |
| Inspect warn | one sentence | Why a click is illegal right now |
| Inspect hint | few words | currently `hold Shift to explain` |
| Speech balloon | one short sentence | First person. Must start with **I** or **My** or the engine falls back |
| Gate chrome | labels | currently THE MILL GATE / THE RELIC / THE THREAT |
| Gate hook | one sentence | Take X, matching-tier creature comes through |
| Gate buttons | short | Take… / Pass · N left |
| Item card title | display name | |
| Choice buttons (Throwing Knife) | short | currently `ATK 3, discard` and `ATK 1, keep` |
| Tutorial body | ~2–4 sentences | Talk box ~340px wide, 15px type |
| Tutorial hint | parenthetical prompt | e.g. `(click Spin)` — keep the verb the player must do |
| Tutorial continue button | 1–3 words | currently Let's go / Got it / Alright / Fine / OK / etc. |
| Draft taunt (after door opens) | one sentence | They came for that item. `{item}` placeholder available |
| Trophy | **none** | Number only |

**Do not write:** Roster column headers, editor chrome, log dump on the right, Developer Test copy. Those are tools.

---

## 5. Art you are walking into (not a story)

Locked for now, because the game already renders:

- Pixel dungeon, nearest-neighbor, 16×16 creatures
- Kenney RPG UI panels and long buttons (parchment, brown, gold ink)
- Kenney particles for hits
- Colorblind marks for Attack vs Block (never color-alone)
- Metal rims: bronze / silver / gold = tier 1 / 2 / 3. A pack’s item and monster share metal.
- Item cards: dark fill by job (attack-ish red, block-ish blue, defeat-ish purple, etc.) + metal rim
- Monster inspect plates: darker fill, thicker rim at higher tier

Current creature sprites are **0x72 DungeonTileset II** slices, plus a Kenney Tiny Dungeon spider for Spider Queen, plus a handful of extra item PNGs (shield, helmet, boot, …). Several item icons are **wrong objects used as stand-ins** (a flask standing in for a helmet in the atlas fallback). Treat sprite **identity** as unassigned. Your keywords should tell the producer what to search for so replacements match one world.

Audio is Kenney interface/RPG + one CC0 dungeon ambience loop. You may keyword music/ambience. You are not scoring a film.

**Give the producer:** 8–15 concrete search phrases (style + subject + constraint), plus what to **avoid** so the set stays cohesive. Prefer CC0 / “credit not required” sources when you can.

---

## 6. Rules that affect writing (do not change the rules)

- Player HP max 6, starts 6, cannot go above 6
- Block is per-fight
- **Kill** (HP to 0 via attack) and **Defeat** (item removes them) are different words in the current copy. You may recast the **flavor**; keep the distinction understandable
- Goblin cannot take **attack** damage; other HP loss still works
- Hornet Swarm: two swings; block is spent on each swing
- Double-hit / neighbor KO (Crossbow) slays and recenters the wheel
- Smoke Bomb: abort this fight, spin again, not the same slice, gain a random unseen item
- Healing Potion: unplayable; if you would die, discard it and heal 3
- Commander and Lich buff neighbors (those two are last in variable stat calc — you do not need to mention that)
- Tutorial items and seats are fixed (see §3)

**Ids (frozen):**  
Monsters: `wizard` `golem` `goblin` `skeleton` `hornet_swarm` `lich` `ogre` `berserker` `dire_wolf` `bandit` `leech_league` `wraith` `mimic` `two_headed_serpent` `slime_boss` `spider_queen` `commander` `dragon`  
Items: `throwing_knife` `shield` `sai` `medallion` `helmet` `da_boot` `grimoire` `bloody_gauntlets` `breastplate` `bracers` `smoke_bomb` `knucklers` `fangs` `poison_flask` `spiked_flail` `healing_potion` `crossbow` `sledgehammer` `pocketwatch`  
Retired (do not write unless you pitch reviving them): `cursed_scroll` `dagger` `helmet_hidden` `bandana`

---

## 7. Current copy — verbatim, all of it

Again: **placeholders.** Rewrite freely. Quoted so you can see every line that currently reaches a player.

### 7.1 Overlay, buttons, cues, inspect chrome

```
Title overlay title:     Boss Rush
Title overlay subtitle:  Pip walks a fight. Begin is the mill gate: relics behind a door. Dive In skips it.
Buttons:                 How to Play | Dive In | Begin
Pause modes:             How to Play | Dive In | Begin   (plus Resume, Quit, Start over)
Win title / sub / btn:   Cleared  /  The mill is empty.  /  Again
Lose title / sub / btn:  Down     /  HP 0.               /  Again

In-run buttons:
  New | Place | Bribe | Spin | Done
  (Place/Bribe are leftover and hidden in the normal loop. Spin is the one they click.
   Done relabels to Safe or Take N.)

Idle inspect:            Inspect
                         Hover a monster on the wheel, or an item in your hand.
Shift hint:              hold Shift to explain

Cue lines:
  draft / night watch:   The mill's night watch takes north, east, south, and west.
  draft / force:         No passes left — the mill takes the rest.
  draft / ask:           Take the {item} (Tier {n}) and attract a Tier {n} — or pass ({k} left).
  draft / seat:          Click an empty alcove. That's where they'll wait to fight you.
  draft / filling:       The mill is filling.
  ready:                 Spin — the mill turns.
  fighting:              Click an item, or take the hit
  fighting / mark:       Click a neighboring enemy
  devtest:               Click a monster onto the wheel, an item into your hand. Enter when the wheel is full.

Gate chrome:
  THE MILL GATE
  THE RELIC
  THE THREAT
  Hover the relic. Hold Shift for the math. Same metal on both sides.
  Take {item}, and a matching-tier monster comes through that door.
  Take it — attract a Tier {n}
  Pass  ·  {n} left
  Click a + alcove.

On-wheel kill flash (not a sentence to rewrite for story, but it is English):
  BLOCKED   or   SLAIN
```

Throwing Knife choice buttons (combat): `ATK 3, discard` | `ATK 1, keep`

Hardcoded inspect bodies that appear if catalog ability is empty (then catalog ability overwrites). Current catalog abilities are in §7.4, so those bodies are backup:

```
Shield:           Gain 4 block.
Sai:              Starts at 2 each fight. Flips 2 ↔ 4 after any item is used.
Throwing Knife:   Throw for 3 and lose it, or nick for 1 and keep it.
Pocketwatch:      Attack 2, or 4 if the enemy's attack is even.   [live ops may differ; board says neighbor ATK]
Medallion:        Block equal to the HP you are missing.
Helmet:           Block equal to whoever has less HP — you or the enemy.
Da Boot:          Defeat an enemy with less HP than you. Combat ends immediately.
                  warn: Can't — this enemy has as much HP as you, or more.
Bloody Gauntlets: Attack equal to the HP you are missing, counted from 7.
Bracers:          Block equal to the weaker neighboring enemy's attack.
                  warn: Can't — no neighboring enemy.
Knucklers:        Attack equal to 7 minus the items still in your hand.   [board currently says 8]
Spiked Flail:     Get stronger. +1 attack for each monster defeated.     [board currently says +2 per bleed]
Sledgehammer:     Defeat an enemy with 5 or more attack. Combat ends immediately.
Fangs:            Take their hit (block still works), defeat them, then heal equal to the HP they had.
Poison Flask:     Mark a neighbor. When you spin them, they lose 5 HP immediately.
                  warn: Can't — no neighbor you can poison.
Crossbow:         Deal 4 attack to a neighboring enemy with 4 HP or less. Goblin cannot take attack damage.
                  warn: Can't — no neighbor at 4 HP or less that can take attack.
Healing Potion:   If you would die, discard this and heal 3.
Spent item warn:  Already used this fight.
```

If board `ability` is filled, **that** is what the inspect body shows. Prefer rewriting the board ability; keep the warn lines’ meaning.

### 7.2 Tutorial — full script (Pip)

Speaker name: `Pip`  
Skip: `Skip`  
Default continue: `Alright`

Beats in order (`scripts/tutorial_guide.gd` → `BEATS`):

1. wait=`continue` focus=`""` go=`Let's go`  
   *Name's Pip. I sold trinkets at the dungeon gift shop until the wheel ate my shift. Get through three fights and I'll pretend this was always educational.*

2. wait=`continue` focus=`wheel` go=`Got it`  
   *This circle is the mill — a dungeon with no door. It turns in place. You fight whoever lands. Tonight I seated a Golem, a Wizard, and a Berserker. I'm steering.*

3. wait=`continue` focus=`hearts` go=`Alright`  
   *Those hearts are you. Empty is a closed shop. One heart left is still a win. The dungeon does not grade on leftovers.*

4. wait=`hover_item` focus=`hotbar` hint=`(hover any item)`  
   *Bag's along the bottom. Hover a card. Hold Shift if you want the equation instead of the number.*

5. wait=`continue` focus=`item:helmet` go=`Fine`  
   *Helmet's number is alive — it changes with health. We probably won't tap it if you listen. Shield is the pillow. Flail gets ideas later. I also slipped a boot in. Don't ask.*

6. wait=`spin` focus=`spin` hint=`(click Spin)`  
   *Click Spin. I'll land the Golem. Big, slow, hits for three.*

7. wait=`item:shield` focus=`item:shield` hint=`(click Shield)`  
   *Golem. Three in the knuckles. Your Shield is four. Click the Shield.*

8. wait=`continue` focus=`wheel` go=`OK`  
   *That gold in the hub is Block. It's a pillow. When this fight ends, the pillow goes in the trash. Hearts stay.*

9. wait=`done` focus=`done` hint=`(click Safe)`  
   *Click Safe. You blocked it all this time. If a heart had popped, we'd keep walking. Alive is the only score.*

10. wait=`continue` focus=`trophy` go=`Spin when ready`  
    *Block's gone. Hearts aren't. That little plaque is your body count — the Flail is counting too. Two guests left.*

11. wait=`spin` focus=`spin` hint=`(click Spin)`  
    *Spin again. Wizard this time. Don't eat what they throw.*

12. wait=`item:da_boot` focus=`item:da_boot` hint=`(click Da Boot)`  
    *Five attack, two health. You could hide and still get nicked — or you end it. Click Da Boot. If they have less health than you, the fight just stops.*

13. wait=`continue` focus=`item:helmet` go=`Got it`  
    *That's the other door: kill the small ones. The Flail only grows when you bleed — you didn't, so it's still 2. Helmet's the pillow for this last one.*

14. wait=`hover_slice:berserker` focus=`wheel` hint=`(hover the Berserker)`  
    *Last slice. Hover it. Monsters have hobbies too — they tell you if you ask. This one gets stronger when you win. Rude.*

15. wait=`spin` focus=`spin` hint=`(click Spin)`  
    *Spin. Berserker hits 3. Helmet is the lower of your HP and theirs.*

16. wait=`item:helmet` focus=`item:helmet` hint=`(click Helmet)`  
    *Click the Helmet. Four block against three attack.*

17. wait=`done` focus=`done` hint=`(click Safe)`  
    *Click Safe. Block dumps after this. Hearts stay. That's a dungeon.*

18. wait=`continue` focus=`""` go=`I'm good`  
    *You lived. I get the shop back. Dive In is the real dungeon — I don't pick the order, and there are eight of them. Try not to need me.*

Nudge lines (if you add any, say so): the engine can replace the hint via `nudge(msg)` but currently does not ship extra nudges.

### 7.3 Gate taunts — after the door opens (`scripts/draft_lines.gd`)

Cycle of five per item id. `{item}` is replaced with the display name. Default if an id is missing:

```
That {item} is mine. I'll peel it off you when the mill turns.
Nice toy. Shame you're going to die holding it.
You grabbed the {item}. I noticed. That's a problem for you.
Keep it warm. I'll take it off the body.
The {item} called. I came. You're in the way.
```

**throwing_knife**
- A throwing knife? I'll send it back. Point first.
- Cute. You brought a snack. I'm taking the knife.
- That knife's leaving with me. You can keep the fingers.
- One knife. Two of us. Math isn't on your side.
- Don't throw it yet. I want it in one piece. Unlike you.

**shield**
- Nice Shield. I'll pry it off you when you stop moving.
- Hide behind that. I'll wait. I have all night.
- A Shield. Adorable. I'm still going to eat you.
- Keep the Shield. I'll take it as a trophy.
- That Shield's coming with me. You can keep the dent.

**sai**
- Two prongs. Fancy. I'll hang them on my wall.
- The Sai's mine. You can explain that to the next guy.
- Pokey little thing. I like it. I like you less.
- Grabbed the Sai, did you? Then I guess we're dancing.
- Those Sai look expensive. Your blood's free.

**medallion**
- Shiny Medallion. Goes with my collection of last words.
- That Medallion's humming. I want it. You're loud.
- Jewelry on a doomed person. Classic.
- Hand it over later. I'll be polite until I'm not.
- The Medallion called me. You just work here.

**helmet**
- Nice Helmet. I'll wear it. After.
- Cover the head. I'll aim elsewhere. Kidding. I'll aim there.
- That Helmet's mine. Your thoughts can stay.
- A Helmet. You think this is going well.
- Take the Helmet. I'll take the rest of you.

**da_boot**
- Da Boot? I'm kicking you with it. Full circle.
- You picked a boot. I picked a fight. Guess who wins.
- That's my size. I'll try it on. Your foot's optional.
- A boot. Bold. I'm going to laugh, then I'm going to kill you.
- Keep the Boot laced. I'll need it in good shape.

**bloody_gauntlets**
- Bloody Gauntlets. Already my color.
- Those gloves have seen things. They're about to see more.
- You put on the Gauntlets. I put on a smile. Only one of those lasts.
- Red looks good on you. It'll look better on the floor.
- The Gauntlets are mine. The blood we can share.

**bracers**
- Bracers. Cute armor. I'll snap them off later.
- Those Bracers are coming with me. The arms are negotiable.
- Wrist jewelry. I collect it. Also screams.
- You grabbed the Bracers. I grabbed a seat. See you soon.
- Keep those on. Makes the trophy shot nicer.

**knucklers**
- Knucklers. You want to punch me. That's adorable.
- Brass on the hands. I'll take them. Then the hands.
- Those Knucklers are mine. Your strategy is notes.
- Packed for a brawl. I packed for a murder. Close enough.
- Keep the Knucklers warm. I'll be needing a pair.

**spiked_flail**
- A Flail with spikes. You're speaking my language.
- That Flail's going on my mantel. You're going on the floor.
- Spikes. Finally someone with taste.
- You picked the mean one. I respect that. Briefly.
- The Flail's mine. Don't get attached. I will.

**sledgehammer**
- A Sledgehammer. Overkill. I like overkill.
- That hammer's coming with me. The wall can keep the hole.
- Big hammer. Small human. This'll be short.
- You brought a Sledgehammer to my mill. Rude. Fun, though.
- I'll take the hammer. You can keep the headache.

**grimoire**
- A Grimoire. Finally, light reading.
- That book's mine. Your homework's over.
- Magic book. Mortal owner. I can do that math.
- Don't dog-ear it. I'll kill you either way, but still.
- The Grimoire called. I came. You're a bookmark.

**breastplate**
- A Breastplate. I'll hang it in the hall. With you still in it, if needed.
- Fancy tin. I'll dent it. Then I'll keep it.
- That plate's mine. Your ribs can commute.
- Armor. Cute. I brought teeth.
- Keep it polished. Trophies look better shiny.

**smoke_bomb**
- A Smoke Bomb. Hiding already? I can wait.
- Puff of smoke. Then me. Then you, briefly.
- That bomb's mine. Your exit's cancelled.
- Smoke's a nice trick. I live in the dark.
- Take the Smoke Bomb. I'll find you anyway. That's the fun part.

**fangs**
- Fangs. Copies. I'll show you the originals.
- You brought teeth to a teeth fight. Brave. Stupid. Brave.
- Those Fangs are mine. I already have a set. I want extras.
- Bite toys. I'll use them. Guess on what.
- Keep the Fangs handy. I'll be collecting a matching pair.

**poison_flask**
- Poison. Classy. I'll drink to that. You first.
- A green flask. My favorite vintage. Notes of you.
- That Poison Flask is mine. Don't spill. I'll need all of it.
- You packed poison. I packed hunger. We should hang out.
- Cute vial. I'll keep it. You can keep the symptoms.

**healing_potion**
- A Healing Potion. You're planning to live. That's optimistic.
- That potion's mine. Your second chance just left.
- Red flask. Red ending. I'm consistent.
- Don't drink it yet. I want it full when I take it.
- A Healing Potion. Sweet. I'll take it off the corpse.

**crossbow**
- A Crossbow. Point it at someone else. I'll wait my turn.
- Bolts. Cute. I'll keep the bow. You can keep the holes.
- You aimed a Crossbow in my mill. Rude. Attractive, though.
- That Crossbow's mine. Try not to scratch the stock.
- A Crossbow. Finally a guest with range. I have more.

**pocketwatch**
- A Pocketwatch. Your time's up. That's not a metaphor.
- Tick tock. That's me, walking. That's you, not.
- Nice watch. I'll take it. Time of death: soon.
- You grabbed a clock. I grabbed a seat. See you on the hour.
- The Pocketwatch is mine. Stop winding it. I'll stop you.

### 7.4 Cards — display names, player text, hover math

From the live content board. `---` means no line. Engine may fall back to the speech/reminder tables in §7.5.

**Monsters** (id · Name · ability · explainer)

- `wizard` · Wizard · --- · ---
- `golem` · Golem · --- · ---
- `goblin` · Goblin · I cannot take attack damage. · no attack damage
- `skeleton` · Skeleton · I copy the HP of the last enemy you faced. · last enemy HP
- `hornet_swarm` · Hornet Swarm · I attack twice. · Double Attack
- `lich` · Lich · I give my neighbors +1 HP. · neighbors +1 HP
- `ogre` · Ogre · My HP is set to your HP (at the start of combat). · HP equals yours
- `berserker` · Berserker · I gain one HP and attack with each monster you defeat. · attack and HP plus defeat
- `dire_wolf` · Dire Wolf · My attack is your HP. · Ruthless Attack
- `bandit` · Bandit · My attack is how many items you hold. · attack is items
- `leech_league` · Leech League · My HP is 1 plus how many of us are still on the wheel. · HP from monsters left
- `wraith` · Wraith · I copy the higher neighbor's attack. · copies neighbor attack
- `mimic` · Mimic · If I go down before I attack, you gain an item. · Slay To Win ('win is the bolded keyword in the color of 'Item' keyword)
- `two_headed_serpent` · Two-Headed Serpent · My attack drops to 0 if you use two items this fight. · two items, no attack
- `slime_boss` · Slime Boss · My attack always equals my HP. · Attack equals its HP
- `spider_queen` · Spider Queen · I attack twice if a neighbor has less HP than I do. · double hit if a neighbor is weaker
- `commander` · Commander · I give my neighbors +2 attack. · neighbors +2 attack
- `dragon` · Dragon · My attack ignores block. · ignores block

Wizard and Golem currently have no speech; they only show Attack / HP. You should write them speech anyway (I / My).

**Items** (id · Name · ability · explainer)

- `throwing_knife` · Throwing Knife · (ATK 3), OR (ATK 1) and keep this item. · (3) or (1 and KEEP)
- `shield` · Shield · (BLK 4) · *(blank)*
- `sai` · Sai · Alternates upon using any item · (2) or (4)
- `medallion` · Medallion · Gains Block for each HP you are missing · (6 − HP)
- `helmet` · Helmet · Block equal to lowest HP between you and the enemy. · (the lower of YOUR HP and ENEMY HP)
- `da_boot` · Da Boot · Defeat an enemy with less HP than you. · (ENEMY HP < YOUR HP)
- `grimoire` · Grimoire · (ATK X) equal to the ATK of the last monster faced. · (LAST ENEMY ATK)
- `bloody_gauntlets` · Bloody Gauntlets · (ATK 7-X), where X is your HP. · (7 − HP)
- `breastplate` · Breastplate · (BLK 2). If you lose HP this combat, keep this item. · (2) and KEEP if you bled
- `bracers` · Bracers · (BLK X) equal to the ATK of the weakest neighboring enemy. · (NEIGHBOR ATK)
- `smoke_bomb` · Smoke Bomb · Re-roll the encounter, then Gain 1 Random Item. · *(blank)*
- `knucklers` · Knucklers · (ATK 8-X), where X is the number of items still in your hand. · (8 − ITEMS)
- `fangs` · Fangs · Receive DMG equal to enemy ATK, then Defeat the enemy and Heal equal to their HP (up to your Max HP). · (TAKE THEIR ATK) then DEFEAT then HEAL THEIR HP
- `poison_flask` · Poison Flask · Choose a neighbor. Once they appear in combat, they lose 5 HP instantly. · *(blank)*
- `spiked_flail` · Spiked Flail · Each time you lose any HP, this gains +2 ATK · +2 ATK for each time you BLED
- `healing_potion` · Healing Potion · Unplayable. When you would die, discard this and heal up to 3 HP. · *(blank)*
- `crossbow` · Crossbow · (ATK 4) to a neighboring enemy with 4 HP or less. · (ATK 4) if (NEIGHBOR HP ≤ 4)
- `sledgehammer` · Sledgehammer · Defeat an enemy with 5 or more ATK. · (ENEMY ATK ≥ 5)
- `pocketwatch` · Pocketwatch · Attack equal to the ATK of the strongest neighboring enemy. · (Highest Neighbor ATK)

### 7.5 Engine fallbacks (`scripts/main.gd`)

Used if board ability is empty or does not start with `I ` / `My `.

**MONSTER_SPEECH**

```
goblin:              I cannot take attack damage.
skeleton:            I copy the HP of the last enemy you faced.
hornet_swarm:        I attack twice. Your block is spent on each swing.
lich:                I give my neighbors +1 HP.
ogre:                My HP is your HP.
berserker:           I gain one HP and attack with each monster you defeat.
dire_wolf:           My attack is your HP.
bandit:              My attack is how many items you hold.
two_headed_serpent:  My attack drops to 0 if you use two items this fight.
slime_boss:          My attack always equals my HP.
leech_league:        My HP is 1 plus how many of us are still on the wheel.
wraith:              I copy the higher neighbor's attack.
mimic:               If I go down before I attack, you gain an item.
spider_queen:        I attack twice if a neighbor has less HP than I do.
commander:           I give my neighbors +2 attack.
dragon:              My attack ignores block.
```

**MONSTER_REMINDER** (Shift / inspect math-ish)

```
goblin: no attack damage
skeleton: last enemy HP
hornet_swarm: attacks twice
lich: neighbors +1 HP
ogre: HP is yours
berserker: attack and HP plus defeat
dire_wolf: attack is your HP
bandit: attack is items
two_headed_serpent: two items, no attack
slime_boss: attack equals HP
leech_league: HP from monsters left
wraith: copies neighbor attack
mimic: item if I never swing
spider_queen: double hit if a neighbor is weaker
commander: neighbors +2 attack
dragon: ignores block
```

Write **one** speech and **one** reminder per monster. The producer will put the speech on the board `ability` (must start with I/My) and the reminder on `explainer`.

---

## 8. How to hand this back (so it can be implemented)

Do not send a novel. Send **pitch first, then tables**.

### A. Pitch (short)

1. One paragraph: what this place is, who the player is, why the ring exists, why taking a tool attracts a creature. No mechanics recap.
2. Through-line in one sentence the player could feel without reading a codex.
3. Tone: 5–8 adjectives you will actually write in, and 5 you will not.
4. Who speaks besides the creatures (guide / door / overlay). If the guide is not Pip, name them and say why they are allowed to teach.
5. What **not** to chase (other games’ skins you almost used and rejected).

### B. Title and mode labels

Table: `slot` | `current` | `yours`  
Slots: game title, How to Play, Begin, Dive In, Again, win title, win sub, lose title, lose sub, Spin (only if you have a better verb that still means “turn the ring”).

### C. Tutorial

Same 18 beats. Columns: `#` | `wait` (unchanged) | `focus` (unchanged) | `go` | `hint` | `body`  
Plus: speaker display name, Skip label, 1-line note on portrait (search keywords; current sprite is 0x72 `dwarf_f`).

### D. Overlay, cues, gate chrome, inspect chrome

One table. `key` | `yours`  
Keys must match §7.1 (or name the file + string).

### E. Monsters

One row per frozen id: `id` | `display name` | `speech (I/My)` | `explainer` | `art search` | `one-line story function` (why they belong in *this* world, not a new rule).

### F. Items

One row per frozen id: `id` | `display name` | `ability (player sentence)` | `explainer (Shift math)` | `five door-taunts` | `art search`.  
Throwing Knife: also the two choice labels.

### G. Default door taunts

Five lines with `{item}` for ids you did not specialize.

### H. Storyboard (only existing beats)

Title · night-watch seating · gate mystery · door slam / reveal · Spin · BLOCKED vs SLAIN · win · lose.  
Each: what is on screen, who talks, one camera/note. No new cutscenes. No new UI.

### I. Art keyword pack

List of searches + avoid list + license preference (CC0 first). Call out which current stand-in sprites are the worst mismatches if you can tell from the names (helmet-as-flask, etc.).

### J. Open questions

At most five, and only if a missing answer would change every table. Otherwise pick and proceed.

---

## 9. Voice notes for *you*, not for the player

- Ordinary English. The player is clicking, hovering, waiting, committing. Do not invent a private vocabulary they must learn (`panic mill`, `reads / commits / bills`, etc.).
- Do not lead with “it’s fun.” Say what they are choosing, timing, or waiting through — then dress that in your world.
- Math lines stay scannable. Flavor lives in speech and tutorial, not inside `(ATK 4) if (NEIGHBOR HP ≤ 4)` unless a word there is doing a job.
- First-person monster lines are the inspect “body” the player hears. They are not flavor dumped on top of a third explanation. One idea per creature.
- If you rename Da Boot, the tutorial wait key is still `item:da_boot`. Put the new display name in the spoken line (“Click the ___”).

---

## 10. Files the producer will patch from your tables

You do not need to write GDScript. Use these keys.

| Your table | Lands in |
|---|---|
| Tutorial beats, speaker, Skip | `scripts/tutorial_guide.gd` (`BEATS`, `_name.text`) |
| Door taunts | `scripts/draft_lines.gd` (`LINES`, `DEFAULT`) |
| Overlay / cues / inspect idle / Shift hint / choice labels | `scripts/main.gd` (`_sync_overlay`, `_cue_text`, `_idle_inspect`, `_monster_rule` hint, knife options) |
| Gate chrome | `scripts/draft_gate.gd` |
| Card names, ability, explainer | `data/content-board.json` (and catalog on next in-game Save) |
| Speech fallbacks / reminders | `scripts/main.gd` (`MONSTER_SPEECH`, `MONSTER_REMINDER`) — keep in sync with the board |
| Pause button labels | `scripts/settings_menu.gd` |
| BLOCKED / SLAIN | `scripts/boss_wheel.gd` |
| Art keywords | producer searches; sprites wired in `scripts/dungeon_art.gd` (`MONSTER_STEM`, `ITEM_STEM`, extra PNGs) |

Engine: Godot 4.7.2, one scene `res://scenes/main.tscn`, viewport 1680×1040.

---

When you are done, the producer should be able to implement without asking what you meant. If a display name and an id disagree, **id wins**. If flavor and a rule disagree, **rule wins**, and you rewrite the flavor.
