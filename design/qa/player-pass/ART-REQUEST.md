# ART-REQUEST — first-look player pass (2026-10-20)

Pixel owns PNG bytes. Do not redraw in this chat.

Nathan’s board: do **not** redraw the hub hero to look less like Goblin. Explain it in copy instead (see JAM.md). Same for Goblin’s doubled name as its own Pixel ticket.

## 1. Opening will is lined paper with no words

- Card: Lucky Snatchwick will cutscene
- Path: will / deed art under `assets/dungeon/home/` (will overlay)
- Native: current will size
- Shipped: 4x nearest
- Frames / loop: still
- What is wrong: looks like body text that failed to load
- Must read as: a readable short will, **or** obviously blank lined stationery (no fake unreadable script)
- Screenshot: Brand New opening, “Your grandfather… has died inside Mount Grumblegurt.”

## 2. Challenge empty-hand slots are dashed placeholders

- Surface: 10-slot hotbar in Challenge draft
- Path: slot frame 9-slice / empty cell
- What is wrong: looks unfinished
- Must read as: a real empty pouch slot, same family as filled item cards
- Middle Progress now seeds the eight unlocked items into the bag (engine). Empty slots still need real art.

## 3. Inspect portraits sometimes have no frame

- Wizard inspect had a gold frame. Goblin / Golem portraits in the left plate were bare on a brick wall
- Must read as: the same framed plate every time

## 4. Gargoyle (already filed)

- GitHub [#56](https://github.com/Nathan-Elequin/swipe/issues/56): “Gargoyle needs a real piece of art, it looks nothing like a gargoyle”
- Path: `assets/dungeon/extra/gargoyle.png` (confirm against `MONSTER_PNG`)
- Unique art: must be a gargoyle, not a reused golem/statue

## 5. Cabin choice buttons

- Show me how / I’ll wing it are flat brown boxes on the dialog border
- If a 9-slice plank exists for choices, wire it; if not, draw two choice planks that match the talk bar

## 6. Six-monster wheel type (layout also in engine)

- Engine now treats 6+ slices as crowded (smaller plates, call hidden unless hover/face)
- Still Pixel if sprites themselves overflow the wedge (Hornet Swarm numbers on bees, Wraith wrap)
