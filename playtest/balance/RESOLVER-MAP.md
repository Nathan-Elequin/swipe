# Combat resolver map (read-only)

Where live combat resolution lives in Godot (for humans extending the sim).
This PR does **not** refactor these.

| Concern | Location |
|---|---|
| Item ops table | `scripts/main.gd` `ITEM_OPS` |
| Monster specials | `scripts/main.gd` `MONSTER_SPECIAL` |
| Done / enemy swing | `_apply_resolve_hits`, `_owner_attack`, `_swing` |
| Shark loop | `_blood_threshes`, `_shark_attack_player` |
| Item use body | `_use_item` (fangs, defeat_hp, …) |
| Bleed / potion | `_bleed`, `_try_potion` |
| Catalog flow text | `data/catalog.json` `combat_flow`, `rulings` |
| Constructed fights (editor) | `scripts/dev/logic_qa.gd` |

Offline sim twin: `tools/sim/combat_model.py`.
