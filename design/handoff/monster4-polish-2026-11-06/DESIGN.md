# Monster4 polish tip wire (2026-11-06) — Nathan locks via Pixel

Tip base: `playtest/latest` (includes Reel combat SFX #426 @ 48c71c04). Open PR → `playtest/latest`. Always-merge when tip smoke green.

## Nathan locks
| id | slash | idle |
|---|---|---|
| huntsman | **A** | keep existing tip facing_idle |
| quicksand_crab | **B** | keep existing tip facing_idle |
| phantom | **B** | **A** new 64×64 — replace tip facing-dupes |
| collector | **A** | **A** new 64×64 — replace tip facing-dupes |

Combat SFX already tip via Reel #426 — do **not** touch audio.

## Assets (from tar; Nearest filter, lossless, no mipmaps)
Source locked dirs unpack to tip paths:

### Slash (48×48) — NEW files (none on tip yet)
`assets/dungeon/anim/slash/{id}_slash_base.png`
`assets/dungeon/anim/slash/{id}_slash_f0.png` … `_f3.png`

From tar:
- `huntsman/locked/slash/slash_{base,f0..f3}.png` → `huntsman_slash_*`
- same for quicksand_crab, phantom, collector

Attach `polish/SLASH-CONTACT.png` + `polish/IDLE-CONTACT.png` to PR.

### Facing idle — REPLACE tip dupes for phantom + collector only
`assets/dungeon/anim/facing/{id}_facing_idle_f{0..3}.png` (64×64)
From `phantom/locked/facing_idle/f0..f3.png` and `collector/locked/facing_idle/f0..f3.png`.
Do **not** touch huntsman/quicksand_crab facing_idle.

Godot will regenerate `.import` — commit them if tip smoke expects them (match peer monster4 catalog PR style).

## Code — `scripts/dungeon_art.gd` `monster_slash_frames`
**Pixel CRITICAL 2026-11-06:** tip previously returned `_facing_strip` and ignored `anim/slash/`, so PNG-only ships left cut-ins on frozen facing. Restore slash-strip load for **any** id when plates exist (not allowlist-only) — restores all catalog slash sets that already have plates.

```
func monster_slash_frames(card_id: String) -> Array:
	var id := str(card_id).strip_edges()
	var slash := _slash_strip(id)  # anim/slash/{id}_slash_f0..fN until first gap
	if not slash.is_empty():
		return slash
	var face := _facing_strip(id)
	if not face.is_empty():
		return face
	return monster_wheel_frames(id)
```
Add `_slash_strip` peer to `_facing_strip` (f0.. up to 12, break on null). `ability_slash.gd` already calls `monster_slash_frames` — no change once loader works. `slash_base` may sit unused (portrait uses f0..f3) — still commit the base PNG for peers.

## Do NOT
- Change catalog numbers / combat / SFX / player-copy
- Regenerate art
- Touch other monsters' slash or idle
- Wait on F5 / Affine

## Verify
- Tip smoke / Godot headless if repo has it
- PR body: lock table, asset sources, allowlist note for slash loader, SFX already tip via #426
