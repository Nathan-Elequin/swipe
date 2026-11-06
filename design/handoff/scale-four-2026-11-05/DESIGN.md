# Scale-four catalog design locks (Nathan 2026-11-05)

Art locked + facing staged by Pixel. Wire into tip `playtest/latest` catalog + assets. Do NOT change other catalog numbers.

## Cards

### venom_veins — item T2
- id: venom_veins
- Name: Venom Veins
- Tier: 2
- Ability (player-facing): Unplayable. When you lose HP, Gain 1 Poison and a Mark-3 Poison Flask in hand.
- Locks: every HP-loss event, no cap; spawned flask = live poison_flask item (same art/anim — do NOT redraw; reference existing poison_flask assets)
- Art: assets/venom_veins/venom_veins.png (64×64) → place per tip item art conventions

### kiss_of_death — item T2
- id: kiss_of_death
- Name: Kiss of Death
- Tier: 2
- Ability: Mark a random enemy with 4 Poison and change their ability to Lifelink (exact Wraith: on Defeat, set your HP to theirs just before Defeat). Subtooltip on hover for Lifelink = Wraith text.
- Art: assets/kiss_of_death/kiss_of_death.png (64×64)

### glass_asp — monster T2
- id: glass_asp
- Name: Glass Asp
- Tier: 2
- Stats: 9 HP / 2 ATK (under vs T2 vanilla budget 18.5)
- Ability: On every dungeon Spin while alive, I gain 1 Poison. Poison ticks each Spin and clears all Poison on tick (can restack). When I Attack, you gain Poison equal to mine.
- Art still: assets/glass_asp/glass_asp.png (56×64)
- Facing: assets/glass_asp/glass_asp_facing.png (64×64)
- Idle: assets/glass_asp/idle/f0.png … f3.png

### imp — monster T1
- id: imp
- Name: Imp
- Tier: 1
- Stats: 2 HP / 2 ATK (under vs T1 vanilla 14.5)
- Ability: When you Spin me, I force you to Move to the highest live/buffed Attack enemy (ties random; shortest path, else clockwise). Forced Move triggers Bear Trap / arrival effects.
- Art still: assets/imp/imp.png (64×64 burrow green)
- Facing: assets/imp/imp_facing.png (48×48)
- Idle: assets/imp/idle/f0.png … f3.png

## Done when
- All four live in data/catalog.json (or tip equivalent) with correct tiers/pools per tip conventions for new content
- Art files installed where tip expects item/monster/facing/idle assets
- Mark-3 flask spawn reuses live poison_flask — no new flask art
- PR opened against playtest/latest
- No silent nerfs/buffs to unrelated catalog numbers

## Tip art path conventions (playtest/latest)
- Item stills: `assets/dungeon/items/{id}.png` (+ Godot `.import` as tip usually generates)
- Monster stills: follow existing tip convention under `assets/dungeon/tiles/` (or wherever peer monsters like `poison_frog.png` / `goblin.png` live — match peers)
- Facing idle frames: `assets/dungeon/anim/facing/{id}_facing_idle_f0.png` … `_f3.png` (see basilisk / poison_frog / goblin / wraith)
- Facing hero still: place beside peers (discover `*_facing.png` or equivalent — match tip)
- Wire ids into ITEM_PNG / MONSTER_PNG (or current tip equivalent maps) per `.cursor/rules/art-handoff.mdc`
- Mark-3 Venom Veins spawn MUST reuse live `poison_flask` assets — do not add a second flask PNG
- Attach a contact sheet to the PR (LOCKED-CONTACT / CONTACT-facing from uploads ok)
- Do NOT edit `data/player-copy.json` (Jam owns); put player-facing ability into catalog fields only; flag copy gaps in PR body
- Branch off `playtest/latest`, open PR into `playtest/latest`
- Do not change unrelated catalog numbers
