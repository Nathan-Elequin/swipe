# SCREEN — Collection Journey A (MVP) · Spinheritance · Godot 4.7

**Pass:** playable before pretty · **Viewport:** 1680×1040 · **Doop:** A-only (not B ledger)  
**Authority:** `docs/collection-journey-a/OWNER-CONTRACT.md` + `SOURCE-AUDIT.md`  
**Projection:** `scripts/collection_journey.gd`

## Goal

Make **seen / carried / banked** legible across in-run cues and the focused safe-return receipt, covering the 24 A journey moments without a persistent side ledger.

## Non-goals

- Persistent B ledger / gameplay width shrink
- New spend confirmation (A04 uses existing item action)
- Acquisition hints, protection, autorescue, Tier in UI
- Inheritance story / secret rooms / new art
- Doop reviewer chrome as game buttons

## Systems (this MVP slice)

| Slice | Status |
|-------|--------|
| State projection + selftest | This PR — `CollectionJourney` + `run_collection_journey.sh` |
| Progress catalogue known-not-banked | This PR — `seen` payload + cell kind |
| Quiet in-run provisional summary | Follow-up PR |
| Milestone queue ordering | Follow-up PR |
| Cabin optional nav polish | Follow-up PR |

## Catalogue cell states (pattern + text)

| Kind | Meaning | Copy key |
|------|---------|----------|
| `new` | Banked this return | `postrun.collection.item_new` |
| `collected` | Banked earlier | `postrun.collection.item_collected` |
| `seen` | Offered/revealed, not banked | `postrun.collection.item_seen` (**Spin gap** — placeholder until authored) |
| `missing` | Never recognized | `postrun.collection.item_missing` |

## Gate math

- Quota 5 from `data/campaign.json` / `CampaignShell.quota_of`
- Unlock uses **banked** only; `gate_projection.would_cross_on_bank` is display until Leave banks
- Roster totals = catalog live non-token pools (not Doop page fixtures)

## Acceptance (slice)

- Selftest green: offer→seen, carry/dup/spend, 4+1 not open, bank gate, banked repeat, cabinet_full ≠ quota
- Progress menu shows distinct seen-not-banked vs missing when `seen` payload present
- No real-save mutation in tests
- No player-facing Tier

## Screenshots (repot)

See `playtest/repot/inbox/REQ-20261108-collection-A.md`
