---
id: REQ-20261116-commitment-tiers-slice3
status: done
priority: high
branch: cursor/playtest-commitment-tiers-slice3-ecd9
tip_sha: bb1d1af9
created: 2026-11-16T23:55:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → pick Quick → finish one non-tutorial run → cabin homecoming. Or DevChrome Ctrl+Shift+1 then Ctrl+Shift+8 after cabin is up.
---

# Commitment tiers slice 3 — OFF-RAMP feedback panel

Milestone feedback modal after cabin homecoming for quick / deeper. Big victory is slice 4 (hook only).

## What to verify

- After homecoming with `should_offramp(quick|deeper)`, full-screen-ish Nathan-chrome modal opens once.
- Big milestone does **not** open this panel (`_maybe_open_commitment_victory` hook only).
- `offramp_shown_*` stamped immediately on show — dismiss / reload never re-asks that milestone.
- Rating 1–5, four optional prompts, Anything else, Send / Keep playing / Go deeper (hidden at BIG) / I'm done for now / Skip.
- Done → thank-you card + carrot, then cabin.
- Go deeper → existing upgrade picker.
- Typing does not fire F2 / Space / M.
- Send posts `type: offramp` via existing inbox; fail keeps typed text + retry line.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | cabin | quick milestone offramp | header + rating + 4 prompts + actions | 01-offramp-quick.png |
| 02 | cabin | deeper milestone offramp | Crystal Cavern header + deeper prompts | 02-offramp-deeper.png |
| 03 | cabin | I'm done for now | thank-you card + carrot | 03-offramp-thanks.png |

## Pass criteria

- All rows at 1680×1040 (or note viewport).
- Cloud outbox has headless plates; replace with headed F5 shots if they differ.
- `RESULT.md` marks each id pass/fail.

## Outbox path

`playtest/repot/outbox/REQ-20261116-commitment-tiers-slice3/`
