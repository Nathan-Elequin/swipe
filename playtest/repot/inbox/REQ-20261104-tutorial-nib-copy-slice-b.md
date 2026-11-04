---
id: REQ-20261104-tutorial-nib-copy-slice-b
status: open
priority: normal
pr: 384
tip_sha: b4d2b85c
branch: playtest/latest
created: 2026-11-04T19:15:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Brand New → Yes (tutorial combat spine)
---

# Tutorial Nib copy rewrite (Slice B — noon F5)

Rewrites `tutorial.line.*` Nib strings from the noon playtest transcript. Deletes obsolete Flail-pre-damage and move-arrow teach beats. Adds B27c Breastplate-path stub copy. Does **not** ship engine bugs, Fangs draft UI wiring, or Goblin branch logic (other slices).

## What to verify

- Brand New → Yes: no "arrows are Moves" / "Not yet" lines; Spin highlight says "It all comes down to this." / "Spin and fight whoever you land on."
- After Wizard: prefer-not-nearly-die → only 2 HP → hit first never swings; Sai still clickable.
- Deck teach bolds **dungeon deck**; loot from entering monster; "Take the shield."; no "Ready for the Golem" (auto-spin into Golem).
- Golem: 7 HP / only 3 ATK / we can block; breastplate "gains two block"; Block protects / lasts until next spin / then lost; shield COULD / recommend save; Keep keyword on breastplate keep line.
- **No** Spike Flail speak/highlight before Take 1. After Take 1: block prevented 2 / lost 1; then Flail hover → bleeding; Keep grayed until fight ends (not "on Spin"); Golem left still Defeated; multiple defeat ways.
- Fangs line prompts "Take the Fangs." with `wait: draft:fangs` (engine Slice C must wire the draft UI or this beat soft-locks).
- No "leave the big guy" — immediate spin to Goblin. Goblin: Cute!; hover any monster; evasive short; Boot / Breastplate / Take 3 choice; B27c breastplate-path lines exist for logic PR (`choice=breastplate`).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | road/tutorial | Brand New → Yes → Spin highlight (B04) | Nib: "It all comes down to this." / no move-arrow teach | 01-spin-open.png |
| 02 | road/tutorial | After shield take, into Golem teach (B14–B17) | New Golem/Block/Keep lines; no Flail spotlight yet | 02-golem-block-keep.png |
| 03 | road/tutorial | After Take 1 (B20) | Flail hover prompt then bleeding; Keep timing = fight ends | 03-post-take-flail.png |
| 04 | road/tutorial | Goblin choice (B26) | Boot / Breastplate / Take 3 prompt; no leave-big-guy line | 04-goblin-choice.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.
- Do not mark this request `done` from cloud.
- Note: Fangs draft UI and Breastplate branch rails are owned by other PRs — fail those rows only if copy text is wrong, not if the wait soft-locks.

## Outbox path

`playtest/repot/outbox/REQ-20261104-tutorial-nib-copy-slice-b/`
