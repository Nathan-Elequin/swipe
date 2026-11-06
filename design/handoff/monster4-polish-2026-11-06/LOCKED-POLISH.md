# Locked polish — scale-four-monsters (2026-11-06)

Pixel path inventory: `*/locked/slash/` + `phantom|collector/locked/facing_idle/` are the sources. Tip wire uses those.

## CRITICAL — slash loader

Tip `monster_slash_frames()` must **not** return `_facing_strip` only. Prefer:

`res://assets/dungeon/anim/slash/<id>_slash_f0..fN.png` until first gap.

If empty → facing / wheel (current fallback). Prefer **whenever files exist** (restores all catalog slash sets that already have plates) — **not allowlist-only**.

`ability_slash.gd` already calls `monster_slash_frames`; no change once the loader works.

Copying PNGs alone leaves cut-ins on frozen facing.

## Idle

Overwrite only `phantom` / `collector` `*_facing_idle_f0..f3`. Leave huntsman / quicksand_crab alone.

## Nathan locks

| id | slash | idle |
|---|---|---|
| huntsman | A | keep tip facing_idle |
| quicksand_crab | B | keep tip facing_idle |
| phantom | B | A new 64×64 |
| collector | A | A new 64×64 |

SFX already tip via Reel #426 — do not touch audio.
