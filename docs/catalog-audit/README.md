# Catalog consistency audit

Regenerate from repo tip:

```bash
python3 tools/catalog_consistency_audit.py
python3 tools/catalog_consistency_audit.py --fix   # safe mechanical fixes only
```

Outputs (identical twins):

- `docs/catalog-audit/REPORT.md` + `gaps.csv` + `truth-matrix.csv`
- `playtest/catalog-audit/` (same three files)

`--fix` only:

1. Sets `flags.art=true` when a live card already has a registered PNG on disk.
2. Adds `sfx-map` `lookup.card_id` use/ability entries when the matching cue already exists.

It does **not** invent art, change Token tiers, delete player-copy keys, or rewrite combat.