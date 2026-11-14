---
id: REQ-20261114-keyword-tips-reshoot
status: open
priority: high
tip_sha: b56074ff
created: 2026-11-14T07:35:00Z
created_by: pixel
viewport: 1680x1040
---

# Keyword tips reshoot (fixes for REQ-20261114-keyword-tips-audit)

The first pass is mostly unusable for design work, for three reasons:
1. The Beggar "Finders Keepers" slash intro is frozen over almost every frame.
2. The 2x crops miss the capsule.
3. The K09 tutorial beats don't show the tutorial talk box at all.

The code notes in audit/keyword-surfaces.md are good; keep them as they are.

Rules for this pass:
- Before each shot, let every monster intro slash / splash finish, or skip it. If a slash band or "<Name> <Title>" banner is visible, the shot fails.
- Take each crop around the actual capsule rect: read the `keyword_tip` global rect and pad it by 60px, then scale 2x with Nearest. Open each crop and check the gold capsule is fully inside it before saving.
- Use a real fight setup with 5–6 monsters and 6–8 hotbar items, not the dev "everything" board.

| id | capture |
|----|---------|
| R01 | Hotbar item hover: plate open + keyword capsule shown (Smoke Bomb, Spin) |
| R02 | Monster inspect plate on the wheel + Flee capsule (Commander) |
| R03 | Poison: wheel poison pip (note it has no hover) + Basilisk plate with Poison capsule |
| R04 | Shroud seat + Shroud capsule |
| R05 | Nib speech bubble with a highlighted keyword + its capsule |
| R06 | Tutorial: B01, B03 and B06 with the talk box visible, keyword paint readable |
| R07 | Combat log hint hover (the separate log hint panel) |
| R08 | Pinned capsule (click a keyword) next to an unpinned one, so the two can be compared |
| R09 | Busy frame: 6 monsters, 8 items, plate + capsule open, no slash |
| R10 | Unplayable stripe hover (Hex or petrified item) |

## Outbox
`playtest/repot/outbox/REQ-20261114-keyword-tips-reshoot/` with shots and a RESULT.md giving one line per row plus the capsule rect. Back up the save and restore it after. Commit only the outbox and push to playtest/latest. Never stash; commit any local edits first as a WIP checkpoint.
