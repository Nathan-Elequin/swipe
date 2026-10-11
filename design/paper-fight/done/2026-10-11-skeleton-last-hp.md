# Paper Fight — Skeleton copies last enemy HP after On Spin effects

**Answers (2026-10-11):**

1. Copy the HP they had after they were Spun, after all On Spin effects have concluded. Example: Spin Spider Queen, let the egg effect happen first, then store the Queen’s HP (higher if eggs were discarded into her).
2. Smoke still counts. You faced them, so Skeleton copies that owner.

Implemented from those answers.

---

**Pitch (Nathan’s words):**

I copy the HP of the last enemy you faced. On Spin (and after On Spin effects, especially Spider Queen’s Egg effect or Ogre’s Empath updates), immediately store the enemy’s HP in this value. Overwrite each On Spin. If this is the first unit faced, set HP to 3.

**Restate (what the player does):**

The player never clicks Skeleton for this. They Spin onto Skeleton and see an HP number. That number is the HP of the owner they Spun onto just before this one, after that Spin’s On Spin effects finished. First fight of the dungeon: 3. Smoke away still counts as facing them.

**Where it happens in a round:**

On Spin, after other On Spin effects on that Spin (Queen eggs into the Queen, Ogre Empath, poison, Grief Jar). Stored once per Spin onto an owner. Skeleton reads the previous store when you land on it.

**Which existing cards this touches:**
- Spider Queen eggs: if eggs were in hand, Queen HP/ATK go up, then that higher HP is stored.
- Ogre Empath: if you Spun onto the Ogre, Grief/bleed can change Ogre HP before the store.
- Smoke: you faced them; store happens at the end of that On Spin, before you Smoke.
- Quiet Bell on Skeleton: printed 3, not the echo.
- First fight: 3.

**What the player sees:**

Skeleton’s HP chip equals the last faced owner’s HP after that Spin’s On Spin effects (or 3 if first).
