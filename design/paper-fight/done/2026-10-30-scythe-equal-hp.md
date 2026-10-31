# Paper Fight — Scythe rework (equal HP) — done

**Pitch (Nathan’s words):** Scythe rework. Ability: Defeat any Monster with HP equal to yours. It’s pretty self-explanatory.

**Answer:** Click Scythe, then click one monster whose current HP equals yours (including the one you face). Same pick as today; only the match changed from 2× to equal. Also highlight Any as a keyword so it is obvious you can point at anybody.

**Restate:** During a fight click Scythe. Matching slices highlight. Click one. They are Defeated. Off-facing leaves; this fight keeps going. Used up. Grey if nobody matches.

**Where:** Fight only. Click then pick. Current plate HP, not printed.

**Collisions kept from the live Defeat path:** Lich chip, Commander Flee, Wraith last-HP, Goblin (Defeat not Attack), Bushido second item, Echo Bell copy, Phoenix Egg, Mimic gift, Amalgam after-item.

**Generous / stingy:** All matching vs facing-only. Nathan picked pick-one (today’s Scythe).

**Shipped:** `hp == player hp` in `_can_mark` / `_apply_scythe`. Inspect equation `Enemy HP = Your HP`. Ability `Defeat Any Monster with HP equal to yours`. Hover for Any: you may choose any Monster on the wheel, not only the one you are facing.
