# QA report template

Save each run as `design/qa/reports/YYYY-MM-DD-<feature>.md`. Copy this file. Fill every heading. Do not claim PASS without evidence from the running game or `tools/qa/qa_probe.gd`.

## Feature

- Name / id:
- Spec it was built from: (board Flow/Notes, Paper Fight path, or chat)

## Result

PASS / FAIL / PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| | | | screenshot path, log line, or probe dump | |

## Bugs

For each bug:

1. **Repro** — exact clicks in the running game (Developer Test seats, items used, Spin / Resolve).
2. **Likely file + function**
3. **Suggested fix** (behavior, not copy rewrites)
4. **Severity** — crash / wrong rule / unreadable / polish

## Balance notes

Numbers you saw (HP, ATK, Block, items). How many fights. Always-win / always-lose if it showed up.

## Player-facing copy issues

Flag only. Include the copy key or card id. Do not edit `data/player-copy.json` or locked fields.

## What was fixed this loop

- Loop 1/2/3:
- Still left:

## Next agent: start here

1.
2.
3.
