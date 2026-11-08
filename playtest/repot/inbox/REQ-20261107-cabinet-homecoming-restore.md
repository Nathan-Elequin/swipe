---
id: REQ-20261107-cabinet-homecoming-restore
status: superseded
superseded_by: REQ-20261108-progress-menu
priority: high
branch: cursor/cabinet-homecoming-restore-9880
base: playtest/latest
created: 2026-11-07
created_by: cursor-agent
viewport: 1680x1040
entry: F5 playtest hub → campaign Verdant Hollow → extract Leave with new uniques
---

# Cabinet homecoming restoration — local runtime checklist

**SUPERSEDED** for between-run presentation by `REQ-20261108-progress-menu` (dedicated progress menu). Cabin remains; automatic S7 cabinet homecoming is no longer the required return UX. Ceremony ownership / ledger work from this REQ landed on `playtest/latest` (status was `done` there); keep this file for historical notes + ceremony QA runners only.

Scope was: **one system only** (S7 bank ceremony + Spin lessons + pending reveal queue). No room flips, door matrix, Outpost consolidation, ROOM_ORDER, map launch, or unlock-math changes.

## Source checks (CI / cloud OK) — not runtime proof

```bash
python3 tools/qa/check_cabinet_homecoming.py
# expect HOMECOMING_RESTORE_OK
# prints DISTINCTION source-qa-ok-does-not-equal-runtime-verified
```

## Engine checks (Nathan local Cursor — Godot required)

```bash
export GODOT="$HOME/godot/Godot_v4.7.2-stable_linux.x86_64"
./tools/qa/run_homecoming_ceremony.sh
./tools/qa/run_banking_contract.sh
```

Live matrix evidence (when captured) lives under `playtest/repot/outbox/REQ-20261107-cabinet-homecoming-restore/`.
