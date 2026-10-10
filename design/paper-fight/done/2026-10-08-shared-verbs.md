# Paper Fight — shared verbs (Attack, Bleed, Heal, Block, Spend, Unplayable, exits)

**Pitch (Nathan’s words):** Phrases like Attack should always run the same package (animation, color, texture, item resolution) unless a card explicitly says otherwise. Harpy’s unique ability Attacks; even 0 damage should still use the Attack animation. Audit every similar flow. Ask at least 10 questions before restructuring.

**Restate (what the player does):** When an owner Attacks you, the fighting portrait always lunges. After that, Block and leftover HP decide the sound, flash color, and text — not whether the lunge happens. Fully blocked Attacks always use the same big blue flourish, including mid-fight (Harpy) and each extra swing. Extra swings (Hornet, Queen, Kobold) are each a full Attack, one after another, Block spent per swing. Needleback’s 1 is not an Attack. Fangs “take their hit” is the same Attack as Done, then Defeat, then Heal. You Attacking them is a second package (their take-hit). Grief Jar is Bleed, not an Attack. Da Boot Defeats with no Attack. Dragon is still an Attack that ignores Block, and therefore never plays Block sounds. Knife on Goblin still plays you-Attack-them, HP stays, immune/glass tell. Heal, Bleed, Gain Block, Spend an item, and Unplayable are also shared packages.

**Where it happens in a round:** Owner-Attacks-you: land (Harpy), after a spent item (Harpy), Done (every swing including extras), Fangs before Defeat. You-Attack-them: you click an Attack item. Bleed: Grief Jar at fight start, by itself. Defeat/Slay/Leave: after HP 0, after a Defeat card, or after Done Attacks finish. Spend: click an item that resolves (Cube feed is not Spend). Unplayable: Petrify, empty Echo, Quiet on a card with no unique (Golem). Numbers keep using live ATK/HP/Block; the package is the event, not a copied snapshot.

**Which existing cards this touches:**
- **Harpy** — interrupt is an Attack; currently does math and glass/chop, never lunges; fight stays open.
- **Hornet / Spider Queen / Kobold** — extra Attacks on Done; each must be a full Attack.
- **Dragon** — Attack that ignores Block; no Block sound even if you had Block.
- **Needleback** — “you take 1” is not an Attack (no lunge, separate poke).
- **Goblin** — cannot take Attack damage; you-Attack-them still animates + glass.
- **Da Boot / Sledge** — Defeat, no Attack.
- **Fangs** — Attack (same as Done) then Defeat then Heal.
- **Grief Jar** — Bleed 1 at start; Block does not stop it.
- **Smoke Bomb** — skip_swing; Done with no Attack (not Da Boot).
- **Lantern / Potion / Victory Flask / Fangs Heal** — Heal package.
- **Shield / Mirror / Helmet** — Gain Block package.
- **Quiet / Petrify / empty Echo / Golem** — Unplayable.
- **Cube feed** — not an item Spend.
- **Clockwork** — leave without Defeat/Slay; replace with 2 T2.
- **Mimic** — may never Attack if you end them first.
- **Wraith / Commander / Lich / Slime** — they still Attack using the number on the plate after formulas.
- **Tutorial / Developer Test / empty alcove** — same packages; empty seats do not Attack.

**Generous reading:** One `owner_attack` function owns lunge + Block math + flourish/chop/glass; Harpy, Done, extras, and Fangs all call it. One `you_attack_them` for Knife/Longbow/etc. One exit for “you ended them” (Defeat and Slay share gold) and a different exit for “they leave after Attacking.”

**Stingy reading:** Only Harpy starts calling the existing Done lunge; extra swings stay as they are; flourish stays end-of-Done only; Defeat/Slay/Leave keep whatever they do today.

Nathan already picked the generous side for Attack, extra swings, flourish, Fangs-as-Done-Attack, two Attack directions, Bleed, Goblin, Dragon (no Block SFX), and the five shared phrases.

**Ways it can fail:**
- Harpy Attack on land plus after each Spend, then Done Attacks again — player can die mid-item before the card finishes tossing.
- Hornet fully blocked: three full flourishes in a row if each swing is a complete Attack including flourish.
- Fangs: Attack flourish then gold Defeat stacked; or Attack downs the player and Defeat still tries to run.
- Clockwork coded as Slay gold even though they were not Defeated or Slain.
- Smoke Bomb Done calling the Attack package “for 0.”
- Needleback 1 accidentally going through `owner_attack`.
- Grief Jar counting as Attack for Breastplate/Flail or playing a lunge.
- Goblin you-Attack still spending Knife but skipping the hit anim (old stingy path).

**What the player sees:** Owner leans in every time the card says Attack. Blue flourish means Block ate that swing. Red chop means HP dropped. Glass/immune on Goblin when you Attack them. Hearts move the same on every Heal. Block pip the same on every Gain Block. Dim + no click on Unplayable. Gold gone beat when you ended them; a different collapse when they just leave.

**If we skip this:** Harpy keeps Attacking in the log and skipping the lunge. Extra swings keep sharing one motion. New cards that say Attack will keep getting one-off paths.

**If we take the strongest reading:** One click (Fangs) can run a full Done Attack, then Defeat, then Heal, and end the fight. Hornet Done can play several full Attacks including several flourishes. That is intended if each swing is a complete Attack.

**Answers already locked:**
1. Every enemy Attack lunges. Blocked vs unblocked only changes sound, flash, text.
2. Full-block flourish on every fully blocked swing, including Harpy and extras, not only end of Done.
3. Hornet / Queen / Kobold: each swing is a complete Attack. Block per swing.
4. Needleback’s 1 is not an Attack.
5. Fangs “take their hit” = same Attack as Done.
6. Two packages: owner-Attacks-you vs you-Attack-them.
7. Grief Jar = Bleed, not Attack. Block does not apply. No lunge.
8. Da Boot = Defeat with no Attack (not skip-swing).
9. Dragon = Attack that ignores Block; never play Block sounds on that Attack.
10. Goblin: you-Attack-them animation + no HP drop + immune/glass.
11. Shared packages also: Heal, Bleed, Gain Block, Spend an item, Unplayable.

**Second-pass answers:**
1. Gold = you ended them (Defeat or Slay). Collapse without gold = they Leave after Attacking, or Clockwork splits.
2. Fangs: full Attack, then Defeat gold, then Heal. If the Attack downs you, stop.
3. Fully blocked extra swings each get their own lunge and flourish.
4. Smoke Bomb Done: no Attack, they just Leave.
5. Heal motion only if HP actually goes up.
6. You-Attack for 0: same anim + glass as Goblin.
7. Clockwork Done: they Attack first (full package), then Leave-alive and split.
8. Gain Block motion only if Block actually went up.
9. Failed click is not Spend.
10. Bleed is not a hit. New Bleed animation and sound. Breastplate / Flail do not treat it as a hit.

**Self-audit:** restated as what the player does · named live collisions · both readings · questions would change the code · implemented after answers
