---
id: REQ-20261104-catalog-art-flags
status: open
priority: low
pr: 394
tip_sha: 22713db4
branch: cursor/catalog-consistency-audit-dae9
created: 2026-11-04T19:20:00Z
created_by: cloud-agent-catalog-audit
viewport: 1680x1040
entry: F5 playtest hub → Brand New or Middle Progress → any fight that can face Damsel / Bear Trap
---

# Catalog art-flag sync (PR #394)

`flags.art` flipped to true for live monsters that already had registered PNGs: `two_headed_serpent` (Damsel) and `bear_trap`. No PNG bytes changed. Audit tool + reports also land in this PR.

## What to verify

- Damsel (`two_headed_serpent`) still shows its damsel.png sprite on the wheel / inspect (art flag was false; should still render the existing asset).
- Bear Trap still shows its facing idle frame when present (hide stays true; art flag now true).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | combat | face Damsel In Distress on the wheel | monster sprite visible (not missing/placeholder) | 01-damsel-art.png |
| 02 | combat | face or inspect Bear Trap token | trap art visible on slice/inspect | 02-bear-trap-art.png |

## Pass criteria

- Both shots at ~1680×1040.
- Sprites readable; no blank/magenta missing art.

## Outbox path

`playtest/repot/outbox/REQ-20261104-catalog-art-flags/`
